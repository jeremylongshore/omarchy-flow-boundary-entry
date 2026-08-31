# Marketplace contract

Flow Boundary ships one bar widget whose listing copy and runtime behavior tell
the same product story.

- Root and bar-widget descriptions are identical and exactly 500 characters.
- Copy names the Arrive and Leave actions, FLOW and PAUSE pill states, the eight
  newest color-coded transitions, 30-second age refresh, and 32-record cap.
- `assets/banner.svg` identifies Flow Boundary and depicts an intentional
  boundary between focused and unfocused work.
- `preview.png` is accepted only with current-tree Buzz provenance, exact
  1280x720 dimensions, a clean shell-log hash, and visual approval.
- State contains timestamps only in local widget settings. The plugin has no
  helper, inference, account, telemetry, or network path.

`tests/contract.test.js` and gate C43 enforce the machine-checkable portions.
