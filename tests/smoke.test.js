const test = require("node:test")
// RTM: REQ-FB-005, REQ-FB-007
const assert = require("node:assert/strict")
const fs = require("node:fs")
const os = require("node:os")
const path = require("node:path")
const { spawnSync } = require("node:child_process")
const Model = require("../Model.js")

const root = path.join(__dirname, "..")

test("QML calls only Model.js functions exported by the stock QML contract", () => {
  const qml = fs.readFileSync(path.join(root, "Panel.qml"), "utf8")
  const calls = [...qml.matchAll(/Model\.([A-Za-z][A-Za-z0-9_]*)\(/g)].map(match => match[1])
  assert.ok(calls.length > 0)
  for (const name of new Set(calls)) assert.equal(typeof Model[name], "function", name)
  assert.match(qml, /manageIpc:\s*false/)
  assert.match(qml, /KeyboardPanel\s*\{/)
  assert.match(qml, /anchorItem:root\.anchorItem/)
})

test("stock Perl helper starts against an empty private state root", () => {
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), "flow-boundary-smoke-"))
  try {
    const result = spawnSync(path.join(root, "bin", "flow-boundary"), ["--scan"], {
      encoding: "utf8",
      env: { ...process.env, HOME: temp, XDG_STATE_HOME: path.join(temp, "state") },
      timeout: 2000
    })
    assert.equal(result.status, 0, result.stderr)
    assert.deepEqual(JSON.parse(result.stdout), { events: [] })
  } finally {
    fs.rmSync(temp, { recursive: true, force: true })
  }
})
