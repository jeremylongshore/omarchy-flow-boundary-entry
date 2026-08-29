// Same-UID adversary used only by the lifecycle regression suite. It replaces
// final and temporary names with a victim symlink as quickly as the filesystem
// allows; the assertion belongs in the parent test, which verifies the victim
// stays byte-identical.
const fs = require("node:fs")
const [dir, victim] = process.argv.slice(2)
for (;;) {
  try {
    for (const name of fs.readdirSync(dir)) {
      if (name !== "boundaries.jsonl" && !name.startsWith(".boundaries.")) continue
      const candidate = `${dir}/${name}`
      try { fs.unlinkSync(candidate) } catch {}
      try { fs.symlinkSync(victim, candidate) } catch {}
    }
  } catch {}
}
