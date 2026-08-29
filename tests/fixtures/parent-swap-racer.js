// Rename the state directory away, install a same-UID symlink to a victim
// directory, then restore it. A helper that validates one pathname and later
// resolves another can publish into the victim; the descriptor-bound helper
// either keeps its pinned directory or fails closed before opening the symlink.
const fs = require("node:fs")
const [dir, victim] = process.argv.slice(2)
const parked = `${dir}.parked`
for (;;) {
  try {
    fs.renameSync(dir, parked)
    fs.symlinkSync(victim, dir)
    fs.unlinkSync(dir)
    fs.renameSync(parked, dir)
  } catch {
    try { if (fs.existsSync(parked) && !fs.existsSync(dir)) fs.renameSync(parked, dir) } catch {}
  }
}
