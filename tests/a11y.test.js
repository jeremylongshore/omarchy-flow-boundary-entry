const test = require("node:test")
// RTM: REQ-FB-006
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")

const panel = fs.readFileSync(path.join(__dirname, "..", "Panel.qml"), "utf8")

test("both boundary actions expose stable accessibility names and button roles", () => {
  assert.match(panel, /Accessible\.name:\s*"Mark context arrival"/)
  assert.match(panel, /Accessible\.name:\s*"Mark context departure"/)
  assert.equal((panel.match(/Accessible\.role:\s*Accessible\.Button/g) || []).length, 2)
})

test("every dynamic event label is rendered as bounded plain text", () => {
  assert.match(panel, /text:Model\.kindLabel\(modelData\.kind\)/)
  assert.match(panel, /textFormat:Text\.PlainText; width:[^;]+; elide:Text\.ElideRight/)
})

test("history uses Omarchy-owned inline settings without an interpreter process", () => {
  assert.match(panel, /import Quickshell\.Io/)
  assert.doesNotMatch(panel, /\bProcess\s*\{|helperPath/)
  assert.match(panel, /bar\.shell\.updateEntryInline/)
  assert.match(panel, /Model\.appendEvent\(eventsJson,kind,Date\.now\(\)\)/)
})

test("the keyboard marks the highlighted boundary and fires once per Enter", () => {
  // PanelKeyCatcher emits returnRequested and then activateRequested for one
  // Return press, so only activateRequested may be wired.
  assert.match(panel, /onActivateRequested:root\.mark\(Model\.choiceKind\(root\.choice\)\)/)
  assert.doesNotMatch(panel, /onReturnRequested/)
  assert.match(panel, /onMoveRequested:function\(dx,dy\)\{root\.choice=Model\.moveChoice\(root\.choice,dx!==0\?dx:dy\)\}/)
  // A click highlights what it marks, so Enter afterwards repeats the same action.
  assert.match(panel, /onClicked:\{root\.choice=0;root\.mark\("arrive"\)\}/)
  assert.match(panel, /onClicked:\{root\.choice=1;root\.mark\("leave"\)\}/)
  // The panel has no inline editor, so the catcher never needs to be blocked.
  assert.doesNotMatch(panel, /TextField|TextInput|FilterInput/)
})

test("every tinted colour adapts to the surface it is drawn on", () => {
  assert.match(panel, /readonly property real surfaceLightness: Commons\.Color\.popups\.background\.hslLightness/)
  // Fixed-lightness text and edges were 1.3 to 1.8:1 on light themes.
  const hsla = panel.match(/Qt\.hsla\([^)]*\)?[^;\n}]*/g) || []
  const tinted = hsla.filter(call => /(?:0\.\d+,){2}(?:0\.6|0\.7)\d*,1\)/.test(call.replace(/\s/g, "")))
  assert.deepEqual(tinted, [], "text-weight colours must go through Model.toneLightness")
  assert.ok((panel.match(/Model\.toneLightness\(/g) || []).length >= 6)
})
