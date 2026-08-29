# Personas: Flow Boundary
<!-- Managed by audit-tests. -->

## Keyboard-first Omarchy operator

Tier: local desktop user
Permissions: local plugin, local state only
Key flows: open panel, mark arrival, mark departure, read recent boundaries
Test coverage:
  - open panel: e2e/buzz.sh
  - mark arrival and departure: tests/helper.test.js
  - read recent boundaries: tests/model.test.js and e2e/buzz.sh
Coverage: 3/3 flows (100%)

## Privacy-conscious operator

Tier: local desktop user
Permissions: local plugin, no account or network
Key flows: run without credentials, keep state private, survive hostile local state entries
Test coverage:
  - no credentials or network: scripts/gates and tests/smoke.test.js
  - private state: tests/helper.test.js
  - hostile state handling: tests/helper.test.js and tests/fixtures
Coverage: 3/3 flows (100%)
