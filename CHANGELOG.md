# Changelog

Notable changes to this plugin.

Entries are derived from this repository's commit history, so every line
corresponds to a real change. The format follows Keep a Changelog and the
project uses Semantic Versioning.

Regenerate after a release with:

```bash
scripts/gen-changelog.py . "<Plugin Name>" "<version>"
```

The generator normalises em and en dashes, because a changelog is shipped prose
and gate c28 refuses them.

## [Unreleased]

Nothing yet.

## [0.2.0] - 2026-08-29

### Changed

- Replaced the Perl state helper with Omarchy-owned inline widget settings.
- Reframed the live marketplace preview around a populated, readable panel.
- Expanded the marketplace description to the full 500-character allowance.
- Isolated each Buzz render in its own compositor, home, and runtime namespace.

## [0.1.0] - 2026-08-27

### Added

- Initial plugin.
