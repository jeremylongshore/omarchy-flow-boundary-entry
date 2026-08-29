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
