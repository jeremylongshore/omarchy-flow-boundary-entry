# Changelog

Notable changes to this plugin.

Entries are derived from this repository's commit history, so every line
corresponds to a real change. The format follows Keep a Changelog and the
project uses Semantic Versioning.

Regenerate after a release with:

```bash
scripts/gen-changelog.sh . "<Plugin Name>" "<version>"
```

The generator normalises em and en dashes, because a changelog is shipped prose
and gate c28 refuses them.

## [Unreleased]

### Changed

- Refresh the vendored gate lane to canonical `f79d8c7`, which adds the Perl arm
  to gate c42. Tooling only: the shipped tree and its receipts are unchanged.

## [0.2.2] - 2026-11-15

### Fixed

- Keep text and edges legible on light themes. The fixed-lightness colors were
  1.3 to 1.8:1 on catppuccin-latte, white and flexoki-light, and now pick their
  lightness from the popup surface (5.3:1 or better for text).
- Correct the security text. It described a descriptor-bound state lifecycle
  that went away with the helper in 0.2.0; state is bounded timestamp-only
  records written through Omarchy's inline widget settings.
- Correct the test audit, testing context and requirements matrix: test counts,
  the audit-harness version, the gate lane, the rig receipt status, and the
  claim that the hues are theme-derived (the hues are fixed, the lightness is
  not).
- Point the marketplace contract at `tests/smoke.test.js`, which enforces it,
  and the changelog regeneration note at `scripts/gen-changelog.sh`.
- Drop the leftover template comment from the bar widget.

### Added

- Arrive and Leave work from the keyboard: Left and Right (or `h` and `l`)
  choose, Enter or Space marks. The chosen button is outlined.
- README sections for the keys, where the history is stored (a note for people
  who commit `shell.json` to dotfiles), and what the preview image shows.
- Rig receipts record the Omarchy revision and the Qt version they ran on, and
  `OMARCHY_RIG_THEME` renders on another theme. The render also drives the
  keyboard through the live shell.

### Changed

- Resolve the development-tool advisories (brace-expansion, fast-uri, glob,
  minimatch, qs, zod) and refresh the vendored gate lane to the current
  canonical revision.
- Add a markdownlint configuration for the legitimate cases (tables, the
  partner badge, issue templates, per-release changelog headings) and fix the
  list formatting errors.
- Label the MiniMax review pin as the fork's main, two commits after v0.5.0.

## [0.2.1] - 2026-11-15

### Fixed

- Qualify Omarchy's palette as `Commons.Color`, as the shell contract requires
  now that Qt 6.12 has its own `Color` type. A smoke test fails on any bare
  `Color.` in the shipped QML.

### Changed

- Seed the rig render's isolated home with the current-theme state a real
  Omarchy install has, so first-party shell plugins on current Omarchy do not
  log warnings the render would read as plugin warnings.
- Bump `actions/setup-node` to 7.1.0 and the MiniMax review action to the
  fork's current main (`cfb2c72`), with the audit harness re-pinned.

## [0.2.0] - 2026-08-29

### Changed

- Replaced the Perl state helper with Omarchy-owned inline widget settings.
- Reframed the live marketplace preview around a populated, readable panel.
- Expanded the marketplace description to the full 500-character allowance.
- Isolated each Buzz render in its own compositor, home, and runtime namespace.

## [0.1.0] - 2026-08-27

### Added

- Initial plugin.
