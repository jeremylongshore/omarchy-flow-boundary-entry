const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const os = require("node:os")
const path = require("node:path")
const { spawnSync } = require("node:child_process")
const helper = path.join(__dirname, "..", "bin", "flow-boundary")

function setup() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "flow-boundary-"))
  return { root, env: { ...process.env, HOME: root, XDG_STATE_HOME: path.join(root, "state") } }
}
function run(env, ...args) { const r = spawnSync(helper, args, { encoding: "utf8", env }); assert.equal(r.status, 0, r.stderr); return JSON.parse(r.stdout) }
const dirOf = (x) => path.join(x.env.XDG_STATE_HOME, "omarchy-flow-boundary")

test("record and scan round-trip, capped at 32 events", () => {
  const x = setup()
  for (let i = 0; i < 40; i++) run(x.env, i % 2 ? "--leave" : "--arrive")
  const s = run(x.env, "--scan")
  assert.equal(s.events.length, 32)
  assert.equal(s.events.at(-1).kind, "leave")
  fs.rmSync(x.root, { recursive: true, force: true })
})

// Marketplace security review (#2903) regression tests: state hygiene.
test("state dir and ledger are created private (0700/0600)", () => {
  const x = setup(); run(x.env, "--arrive")
  assert.equal(fs.statSync(dirOf(x)).mode & 0o777, 0o700)
  assert.equal(fs.statSync(path.join(dirOf(x), "boundaries.jsonl")).mode & 0o777, 0o600)
  fs.rmSync(x.root, { recursive: true, force: true })
})
test("a symlinked ledger is never followed, read or written through", () => {
  const x = setup()
  fs.mkdirSync(dirOf(x), { recursive: true })
  const victim = path.join(x.root, "victim"); fs.writeFileSync(victim, "precious")
  fs.symlinkSync(victim, path.join(dirOf(x), "boundaries.jsonl"))
  // scan treats the symlink as an empty ledger instead of parsing the target
  assert.deepEqual(run(x.env, "--scan"), { events: [] })
  // record replaces the symlink via rename; the victim file is untouched
  run(x.env, "--arrive")
  assert.equal(fs.readFileSync(victim, "utf8"), "precious")
  assert.equal(fs.lstatSync(path.join(dirOf(x), "boundaries.jsonl")).isSymbolicLink(), false)
  fs.rmSync(x.root, { recursive: true, force: true })
})
test("an oversized ledger scans as empty instead of being parsed", () => {
  const x = setup()
  fs.mkdirSync(dirOf(x), { recursive: true })
  fs.writeFileSync(path.join(dirOf(x), "boundaries.jsonl"), '{"kind":"arrive","at":1}\n'.repeat(2000))
  assert.deepEqual(run(x.env, "--scan"), { events: [] })
  fs.rmSync(x.root, { recursive: true, force: true })
})
test("no predictable .tmp path is left behind or used", () => {
  const x = setup()
  fs.mkdirSync(dirOf(x), { recursive: true })
  const victim = path.join(x.root, "victim2"); fs.writeFileSync(victim, "precious")
  // the OLD code wrote through the predictable boundaries.jsonl.tmp; plant it
  fs.symlinkSync(victim, path.join(dirOf(x), "boundaries.jsonl.tmp"))
  run(x.env, "--arrive")
  assert.equal(fs.readFileSync(victim, "utf8"), "precious")
  fs.rmSync(x.root, { recursive: true, force: true })
})
