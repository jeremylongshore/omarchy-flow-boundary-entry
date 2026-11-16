# Testing Context: Flow Boundary
<!-- TESTING.md schema v1. Policy defaults were scaffolded by implement-tests for engineer review. -->

## Classification (policy)

Repo type: frontend (Omarchy QML bar widget with first-party settings persistence)
Primary language(s): QML, JavaScript ES5, Bash
Applicable layers: L1, L2, L3, L4-integration, L5-security, L5-a11y, L6-smoke, L6-e2e, L6-visual, L7-UAT
Waived layers: L4-contract (no network or API), L4-migration (no schema migration), L5-perf (bounded local state), L5-chaos (single-user desktop plugin)
Compliance overlay: none

## Thresholds (policy, hash-pinned)

coverage.line: 95
coverage.branch: 90
coverage.function: 95
mutation.kill_rate: 90
crap.prod_max: 30
crap.test_max: 15
crap.project_avg: 10
flaky.tolerance: 0/3runs
test.complexity_ceiling: 15
personas.flow_coverage_min: 100
journeys.step_coverage_min: 100

## Installed gates (observational)

L0: @intentsolutions/audit-harness 1.4.0
L1: pre-push gate lane (13 vendored gates, c28 to c44, in sync with canonical f79d8c7) + GitHub Actions test/gates workflows
L2: ShellCheck, actionlint, vendored Omarchy gates, gitleaks, osv-scanner, npm audit, markdownlint
L3: node:test + c8 coverage + Stryker mutation + three-run race stability. CRAP is NOT enforced: under harness 1.4.0 crap-score scores zero functions for root-level Model.js and still reports PASS (jeremylongshore/intent-audit-harness#248), and the crap.* thresholds above are policy only until that is fixed
L4-integration: QML-to-Model contract plus a real first-party settings write on the rig
L5-security: bounded settings input, no plugin-owned mutable state path, no helper interpreter
L5-a11y: QML accessibility names/roles, keyboard activation wiring, light-surface contrast contract, and bounded plain-text assertions
L6-smoke: stock QML-to-Model contract tests
L6-e2e: rig validator, qmllint, live settings write, full shell restart, IPC open, keyboard Enter and Right then Enter through the live shell, and screenshot
L6-visual: curated 1280x720 live render on tokyo-night, plus a catppuccin-latte render for the light-surface check, inspected before submission
L7-UAT: primary boundary journey mapped in tests/JOURNEYS.md

## Frameworks (observational)

unit: node:test
coverage: c8 12
mutation: Stryker 10
policy: @intentsolutions/audit-harness 1.4.0
e2e: scripts/rig-verify.sh + scripts/rig-render.sh on intent-ops-buzz/omarchy-rig

## Last audit (observational)

date: 2026-08-29
grade: A (96/100) (last scored then; counts and evidence were re-derived on 2026-11-15 for 0.2.2 but the grade was not re-scored)
auditor: audit-tests + omarchy-ship
p0_gaps: 0 after implementation
p1_gaps: 0 after QML-specific adaptation
p2_gaps: 0

## Traceability (observational, updated by audit-tests)

rtm.total_requirements: 10
rtm.by_moscow:
  must: 8 (8 covered, 0 uncovered)
  should: 2 (2 covered, 0 uncovered)
  could: 0
  wont: 0
rtm.orphaned_tests: 0
personas.declared: 2
personas.under_threshold: 0
journeys.declared: 2
journeys.fully_covered: 2
journeys.partial: 0

## Hash manifest

<!-- The indented list below is the audit-tests manifest format, so lint is paused for it. -->
<!-- markdownlint-disable MD007 MD032 -->
version: 1
last_init: 2026-11-15 re-pinned with the 0.2.2 documentation corrections (first pinned 2026-08-29)
protected_files:
  - tests/TESTING.md policy sections
  - tests/RTM.md MoSCoW tiers
  - tests/JOURNEYS.md criticality
  - stryker.config.json thresholds
<!-- markdownlint-enable MD007 MD032 -->
