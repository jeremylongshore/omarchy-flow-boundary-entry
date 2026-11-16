# Test Audit: Flow Boundary

Scored: 2026-08-29. Counts and evidence re-derived: 2026-11-15, for 0.2.2.
Classification: frontend Omarchy QML plugin
Audit harness: 1.4.0
Registry: `sha256:ffbc75700fb5eb501cb47f1e4038f47ab95ae1fba534b38095e1fe7820c80ed1`

## Result

Grade: A (96/100), as scored on 2026-08-29. The grade was not re-scored for
0.2.2; the numbers below were re-measured and replace the old ones.

The initial deterministic audit found four testing-depth gaps: accessibility,
E2E, smoke, and a conditional web-contract heuristic. The contract heuristic is
not applicable because Flow Boundary has no API or network boundary. E2E and
smoke pass the harness. Accessibility is implemented with QML roles, names,
keyboard wiring and static assertions; audit-harness 1.4.0 reports the
accessibility, contract, crap-score, e2e, smoke and unit gates as PASS. Most of
those are presence checks, not measurements.

## Layer coverage

| Layer | Status | Evidence |
|---|---|---|
| L1 hooks and CI | Implemented | pre-push gates; exact npm test, race, mutation, audit, and ShellCheck in Actions |
| L2 static | Implemented | ShellCheck, actionlint, osv-scanner, markdownlint, gitleaks, vendored gates |
| L3 unit | Implemented | node:test, c8, Stryker, race stability. CRAP is not enforced, see below |
| L4 integration | Implemented | QML-to-Model contract plus live Omarchy inline-settings persistence |
| L5 system/security/a11y | Implemented | bounded setting parsing, no plugin-owned state path or helper, QML accessibility and keyboard contract |
| L6 smoke/E2E/visual | Implemented | rig validator, live write, shell restart, IPC open, keyboard step, focused 1280x720 screenshot |
| L7 acceptance | Implemented | two critical journeys, both 100% mapped |

## Gaps

P0: 0
P1: 0
P2: 0

One known measurement gap, not counted above: under audit-harness 1.4.0 the
crap-score gate scores zero functions for a root-level `Model.js` and still
reports PASS (jeremylongshore/intent-audit-harness#248). Complexity is
therefore not measured here. The `crap.*` thresholds in `tests/TESTING.md` are
policy only until that is fixed.

## Traceability

Ten requirements are mapped: eight MUST and two SHOULD. All are covered. Both
personas and both critical journeys have 100% mapped coverage. No tests are
orphaned.

## Final evidence

- 21/21 tests; `Model.js` at 100% statements, branches, functions and lines
- Three consecutive model-suite passes (11 tests each) with zero flake
- 99.35% mutation score with a 90% blocking floor (151 killed, 2 timed out, 1
  survived; the survivor is the equivalent mutant that empties a catch block)
- 13 vendored Omarchy gates (c28 to c44), in sync with canonical `611efde`
- osv-scanner reports 0 advisories; actionlint, ShellCheck, gitleaks and
  markdownlint are clean
- Rig (omarchy `74de10479d3bf7aa7865408e33219064cfe45432`, Qt 6.12.0): validator
  0, qmllint 0 errors, live settings write, restart persistence, IPC panel open,
  Enter and Right then Enter marking through the live shell, curated render
  inspected, and a catppuccin-latte render for the light-surface check

The rig's compositor is headless sway, not Hyprland. This plugin calls no
Hyprland command, so nothing here depends on that difference.
