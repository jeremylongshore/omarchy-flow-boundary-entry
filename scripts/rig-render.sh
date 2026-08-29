#!/usr/bin/env bash
# Load this plugin into a REAL Omarchy shell on the rig, open its panel, and
# screenshot it.
#
# Why this exists, and why it is separate from rig-verify.sh:
#
#   rig-verify.sh proves the tree passes omarchy-plugin-validate and qmllint.
#   Both are static. Neither loads the plugin, so neither can see a contract
#   error: Bazaar shipped a PanelWindow where the first-party popup is a
#   KeyboardPanel, passed every gate AND qmllint, and only a running shell said
#   "Cannot assign to non-existent property contentHeight".
#
#   Until this script existed, every plugin here was submitted having never been
#   loaded. The repos' own VERIFICATION.md files said so in as many words: "the
#   plugin has not been loaded into a running Omarchy shell ... that is
#   provenance, not a rig run".
#
# It also produces the preview.png the marketplace listing shows, from a real
# render rather than a mockup.
#
# Requires: ssh access to the rig host, and a headless compositor running there.
# It starts sway on the headless wlroots backend if one is not already up.
#
# Usage: scripts/rig-render.sh [plugin-dir] [out.png]
set -uo pipefail

TARGET="$(cd "${1:-$(dirname "$0")/..}" && pwd)"
OUT="${2:-$TARGET/render.png}"
HOST="${OMARCHY_RIG_HOST:-intent-ops-buzz}"
CONTAINER="${OMARCHY_RIG_CONTAINER:-omarchy-rig}"
RES="${OMARCHY_RIG_RESOLUTION:-1280x720}"
SCALE="${OMARCHY_RIG_SCALE:-2}"

command -v jq >/dev/null 2>&1 || { echo "rig-render: jq is required" >&2; exit 2; }
command -v identify >/dev/null 2>&1 || { echo "rig-render: ImageMagick identify is required" >&2; exit 2; }
command -v convert >/dev/null 2>&1 || { echo "rig-render: ImageMagick convert is required" >&2; exit 2; }
[[ -f "$TARGET/manifest.json" ]] || { echo "rig-render: no manifest.json in $TARGET" >&2; exit 2; }

MOD="$(jq -r '.id // empty' "$TARGET/manifest.json")"
[[ -n "$MOD" ]] || { echo "rig-render: manifest.json has no id" >&2; exit 2; }
NAME="${MOD##*.}"
RUN_ID="${NAME}-$$"

fingerprint() {
  ( cd "$TARGET" && \
    find . -type f \
      -not -path './.git/*' -not -path './tests/*' \
      -not -path './scripts/*' -not -path './node_modules/*' \
      \( -name '*.qml' -o -name '*.js' -o -name 'manifest.json' -o -perm -u+x \) \
      -print0 2>/dev/null \
    | LC_ALL=C sort -z | xargs -0 cat 2>/dev/null | sha256sum | cut -d' ' -f1 )
}
FP="$(fingerprint)"
SOURCE_COMMIT="$(git -C "$TARGET" rev-parse HEAD 2>/dev/null || printf unknown)"
SOURCE_DIRTY=false
if [[ "$SOURCE_COMMIT" == "unknown" ]] || \
   [[ -n "$(git -C "$TARGET" status --porcelain --untracked-files=all -- \
     '*.qml' '*.js' manifest.json bin preview.png README.md assets/banner.svg scripts/rig-render.sh 2>/dev/null)" ]]; then
  SOURCE_DIRTY=true
fi

TGZ="$(mktemp -t rigrender-XXXXXX.tgz)"
trap 'rm -f "$TGZ"' EXIT
# tests/ and scripts/ are not shipped to a user, so they are not shipped here.
tar czf "$TGZ" -C "$TARGET" --exclude=.git --exclude=tests --exclude=scripts \
  --exclude=node_modules --exclude=reports --exclude=coverage \
  --exclude=.rig-proof.json --exclude=.render-proof.json . || {
  echo "rig-render: could not package the tree" >&2; exit 2; }
ARCHIVE_SHA="$(sha256sum "$TGZ" | cut -d' ' -f1)"

echo "rig-render: shipping $NAME to $HOST/$CONTAINER"
scp -q "$TGZ" "$HOST:/tmp/rigrender-$RUN_ID.tgz" || { echo "rig-render: cannot reach $HOST" >&2; exit 2; }

# The remote body is written to a file rather than inlined, because nesting
# quotes through ssh -> docker exec -> sh mangles them and fails silently.
REMOTE="$(mktemp -t rigrender-XXXXXX.sh)"
trap 'rm -f "$TGZ" "$REMOTE"' EXIT
cat > "$REMOTE" <<REMOTE_EOF
#!/bin/sh
set -eu
MOD="$MOD"; NAME="$NAME"; RUN_ID="$RUN_ID"; RES="$RES"; SCALE="$SCALE"
RUNTIME=/tmp/rigrender-runtime-\$RUN_ID
RIG_ROOT=/tmp/rigrender-home-\$RUN_ID
FLOW_STATE=/tmp/rigrender-state-\$RUN_ID
SWAY_CONFIG=/tmp/rigrender-sway-\$RUN_ID.conf
SWAY_LOG=/tmp/rigrender-sway-\$RUN_ID.log
QS_LOG=/tmp/rigrender-qs-\$RUN_ID.log
SHOT=/tmp/rigrender-\$RUN_ID.png
QS_PID=""; SWAY_PID=""
cleanup() {
  [ -z "\$QS_PID" ] || kill "\$QS_PID" 2>/dev/null || true
  [ -z "\$SWAY_PID" ] || kill "\$SWAY_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

# A renderer owns its complete session. Reusing /tmp/xdgrt allowed stale Sway
# and Quickshell processes to shadow the current package and made a green load
# claim about the wrong process. These explicit per-plugin roots are disposable.
for path in "\$RUNTIME" "\$RIG_ROOT" "\$FLOW_STATE"; do
  if [ -d "\$path" ]; then find "\$path" -depth -delete; fi
done
mkdir -p "\$RUNTIME" "\$RIG_ROOT/.config/omarchy/plugins/\$NAME" "\$FLOW_STATE/omarchy-flow-boundary"
chmod 700 "\$RUNTIME" "\$RIG_ROOT" "\$RIG_ROOT/.config" "\$RIG_ROOT/.config/omarchy" \
  "\$RIG_ROOT/.config/omarchy/plugins" "\$RIG_ROOT/.config/omarchy/plugins/\$NAME" \
  "\$FLOW_STATE" "\$FLOW_STATE/omarchy-flow-boundary"
tar xzf /tmp/rigrender-\$RUN_ID.tgz -C "\$RIG_ROOT/.config/omarchy/plugins/\$NAME"

# A minimal compositor config has no Sway bar, clock, or workspace chrome to
# leak into the product image. The output itself is the final 16:9 asset size.
cat > "\$SWAY_CONFIG" <<SWAY
output * resolution \$RES scale \$SCALE
seat * hide_cursor 1000
SWAY
export XDG_RUNTIME_DIR="\$RUNTIME"
WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 WLR_RENDERER=pixman \
  sway --config "\$SWAY_CONFIG" >"\$SWAY_LOG" 2>&1 &
SWAY_PID=\$!
WAYLAND_SOCKET=""
attempt=0
while [ \$attempt -lt 30 ]; do
  WAYLAND_SOCKET=\$(find "\$RUNTIME" -maxdepth 1 -type s -name 'wayland-*' | head -1)
  [ -z "\$WAYLAND_SOCKET" ] || break
  attempt=\$((attempt + 1)); sleep 1
done
[ -n "\$WAYLAND_SOCKET" ] || { echo "rig-render: isolated Wayland socket did not start" >&2; exit 1; }
export WAYLAND_DISPLAY="\${WAYLAND_SOCKET##*/}"
export SWAYSOCK=\$(find "\$RUNTIME" -maxdepth 1 -type s -name 'sway-ipc.*.sock' | head -1)
[ -n "\$SWAYSOCK" ] || { echo "rig-render: isolated Sway IPC socket did not start" >&2; exit 1; }

# Seed the same bounded inline widget setting the real plugin reads. This keeps
# the screenshot story populated without a test-only runtime path or helper.
now=\$(date +%s)
EVENTS_JSON=\$(printf '[{"kind":"arrive","at":%s},{"kind":"leave","at":%s},{"kind":"arrive","at":%s}]' \
  \$((now-7200)) \$((now-2700)) \$((now-720)))
export XDG_STATE_HOME="\$FLOW_STATE"

jq -n --arg mod "\$MOD" --arg events "\$EVENTS_JSON" \
  '{version:1,bar:{position:"top",transparent:false,centerAnchor:\$mod,
    layout:{left:[{id:"omarchy.workspaces"}],center:[],right:[{id:\$mod,eventsJson:\$events}]}},plugins:[]}' \
  > "\$RIG_ROOT/.config/omarchy/shell.json"

env HOME="\$RIG_ROOT" XDG_RUNTIME_DIR="\$RUNTIME" XDG_STATE_HOME="\$FLOW_STATE" \
  OMARCHY_PATH=/root/omarchy WAYLAND_DISPLAY="\$WAYLAND_DISPLAY" SWAYSOCK="\$SWAYSOCK" \
  qs -p /root/omarchy/shell >"\$QS_LOG" 2>&1 &
QS_PID=\$!
sleep 18
[ -d "/proc/\$QS_PID" ] || { echo "rig-render: isolated Quickshell exited before IPC" >&2; tail -80 "\$QS_LOG" >&2; exit 1; }

env HOME="\$RIG_ROOT" XDG_RUNTIME_DIR="\$RUNTIME" XDG_STATE_HOME="\$FLOW_STATE" \
  OMARCHY_PATH=/root/omarchy WAYLAND_DISPLAY="\$WAYLAND_DISPLAY" SWAYSOCK="\$SWAYSOCK" \
  qs -p /root/omarchy/shell ipc call "\$MOD" leave >/dev/null 2>&1
sleep 3
STORED=\$(jq -r --arg mod "\$MOD" \
  '.bar.layout.right[] | select(.id == \$mod) | .eventsJson // empty' \
  "\$RIG_ROOT/.config/omarchy/shell.json")
printf '%s' "\$STORED" | jq -e \
  'type == "array" and length == 4 and .[-1].kind == "leave" and (.[-1].at | type == "number")' \
  >/dev/null || { echo "rig-render: first-party settings write did not persist the boundary" >&2; exit 1; }

# Restart the real shell and open the panel from the same persisted settings.
# This is the user-visible contract: history must survive a shell restart, not
# merely remain in one QML object's memory for the duration of a screenshot.
kill "\$QS_PID" 2>/dev/null || true
wait "\$QS_PID" 2>/dev/null || true
QS_PID=""
env HOME="\$RIG_ROOT" XDG_RUNTIME_DIR="\$RUNTIME" XDG_STATE_HOME="\$FLOW_STATE" \
  OMARCHY_PATH=/root/omarchy WAYLAND_DISPLAY="\$WAYLAND_DISPLAY" SWAYSOCK="\$SWAYSOCK" \
  qs -p /root/omarchy/shell >>"\$QS_LOG" 2>&1 &
QS_PID=\$!
sleep 18
[ -d "/proc/\$QS_PID" ] || { echo "rig-render: restarted Quickshell exited before IPC" >&2; tail -80 "\$QS_LOG" >&2; exit 1; }
env HOME="\$RIG_ROOT" XDG_RUNTIME_DIR="\$RUNTIME" XDG_STATE_HOME="\$FLOW_STATE" \
  OMARCHY_PATH=/root/omarchy WAYLAND_DISPLAY="\$WAYLAND_DISPLAY" SWAYSOCK="\$SWAYSOCK" \
  qs -p /root/omarchy/shell ipc call "\$MOD" toggle >/dev/null 2>&1
sleep 8
[ -d "/proc/\$QS_PID" ] || { echo "rig-render: isolated Quickshell exited after IPC" >&2; tail -80 "\$QS_LOG" >&2; exit 1; }

echo "===QML WARNINGS==="
# DBus, PipeWire, UPower, Polkit, and Hyprland are deliberately absent from the
# isolated headless session. Fail on QML/scene diagnostics and crashes, which
# are the load-contract signals attributable to this plugin, while leaving the
# unrelated service warnings visible in the retained raw log.
grep -a -iE "(WARN|ERROR).*(qml|scene)|(qml|scene).*(WARN|ERROR)|cannot assign|is not a type|unable to|handler was registered|quickshell has crashed" "\$QS_LOG" \
  | grep -avE "libEGL|MESA|ZINK|failed to get driver|failed to create dri2" | head -20

# Capture the dedicated 1280x720 output directly. Region capture on the pixman
# headless backend can return only the latest damaged fragments, so the rig uses
# a purpose-sized 16:9 output and a full-frame capture: no crop, resize, or
# fabricated post-process, and no intermittent partial-frame screenshots.
grim "\$SHOT" 2>/dev/null
echo "===PACKAGE=== \$(sha256sum /tmp/rigrender-\$RUN_ID.tgz | awk '{print \$1}')"
echo "===SHOT=== \$(ls -l "\$SHOT" 2>/dev/null | awk '{print \$5}') bytes"
REMOTE_EOF

scp -q "$REMOTE" "$HOST:/tmp/rigrender-$RUN_ID.sh"
RESULT="$(ssh "$HOST" "docker cp /tmp/rigrender-$RUN_ID.tgz $CONTAINER:/tmp/ >/dev/null && \
  docker cp /tmp/rigrender-$RUN_ID.sh $CONTAINER:/tmp/ >/dev/null && \
  docker exec $CONTAINER sh /tmp/rigrender-$RUN_ID.sh" 2>&1)"

WARNINGS="$(printf '%s' "$RESULT" | sed -n '/===QML WARNINGS===/,/===SHOT===/p' | grep -vE '===' || true)"
SIZE="$(printf '%s' "$RESULT" | grep -oE '===SHOT=== [0-9]+' | grep -oE '[0-9]+' || true)"
REMOTE_SHA="$(printf '%s' "$RESULT" | grep -oE '===PACKAGE=== [a-f0-9]{64}' | awk '{print $2}' || true)"

if [[ -n "$WARNINGS" ]]; then
  echo "rig-render: the shell reported problems loading this plugin:"
  printf '%s\n' "$WARNINGS" | sed 's/^/  /'
fi

if [[ -z "$SIZE" || "$SIZE" -lt 4000 ]]; then
  echo "rig-render: no usable screenshot came back (size=${SIZE:-none})" >&2
  printf '%s\n' "$RESULT" >&2
  exit 1
fi
if [[ "$REMOTE_SHA" != "$ARCHIVE_SHA" ]]; then
  echo "rig-render: remote package hash does not match the source package" >&2
  exit 1
fi

ssh "$HOST" "docker cp $CONTAINER:/tmp/rigrender-$RUN_ID.png /tmp/rigrender-out-$RUN_ID.png >/dev/null" || exit 1
scp -q "$HOST:/tmp/rigrender-out-$RUN_ID.png" "$OUT" || exit 1

# Byte count alone accepted both blank and damaged frames in the old lane.
# Decode the unmodified PNG and carry a visual denominator: exact marketplace
# geometry plus enough nonblack coverage to prove the populated panel rendered.
DIMS="$(identify -format '%wx%h' "$OUT" 2>/dev/null || true)"
COVERAGE="$(convert "$OUT" -colorspace gray -threshold 3% -format '%[fx:mean]' info: 2>/dev/null || true)"
if [[ "$DIMS" != "1280x720" ]]; then
  echo "rig-render: preview dimensions are ${DIMS:-unreadable}, expected 1280x720" >&2
  exit 1
fi
if [[ -z "$COVERAGE" ]] || ! awk -v coverage="$COVERAGE" 'BEGIN { exit !(coverage >= 0.35) }'; then
  echo "rig-render: preview nonblack coverage is ${COVERAGE:-unreadable}, expected at least 0.35" >&2
  exit 1
fi

PREVIEW_SHA="$(sha256sum "$OUT" | cut -d' ' -f1)"
jq -n --arg fp "$FP" --arg commit "$SOURCE_COMMIT" --argjson dirty "$SOURCE_DIRTY" \
  --arg archive "$ARCHIVE_SHA" --arg remote "$REMOTE_SHA" --arg rig "$HOST/$CONTAINER" \
  --arg sha "$PREVIEW_SHA" --arg dimensions "${DIMS/x/ x }" --arg coverage "$COVERAGE" \
  --arg at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{fingerprint:$fp,sourceCommit:$commit,sourceDirty:$dirty,
    sourcePackageSha256:$archive,remotePackageSha256:$remote,rig:$rig,
    evidenceBoundary:"isolated real Omarchy shell and QML under a dedicated headless compositor; live plugin IPC writes through first-party inline widget settings; persisted history verified after a full shell restart; direct full-frame grim capture with no crop or image post-processing",
    previewSha256:$sha,dimensions:$dimensions,nonblackCoverage:($coverage|tonumber),capturedAt:$at}' \
  > "$TARGET/.render-proof.json"

echo "rig-render: wrote $OUT (${SIZE} bytes on the rig, ${DIMS}, coverage ${COVERAGE})"
[[ -n "$WARNINGS" ]] && exit 1
echo "rig-render: loaded clean, no QML warnings"
exit 0
