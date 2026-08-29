# Personas: Flow Boundary
<!-- Managed by audit-tests. -->

## Keyboard-first Omarchy operator

Tier: local desktop user
Permissions: local plugin, local state only
Key flows: open panel, mark arrival, mark departure, read recent boundaries
Test coverage:
  - open panel: e2e/buzz.sh
  - mark arrival and departure: tests/model.test.js and tests/a11y.test.js
  - read recent boundaries: tests/model.test.js and e2e/buzz.sh
Coverage: 3/3 flows (100%)

## Privacy-conscious operator

Tier: local desktop user
Permissions: local plugin, no account or network
Key flows: run without credentials, keep state inside Omarchy settings, avoid plugin-owned state paths
Test coverage:
  - no credentials or network: scripts/gates and tests/smoke.test.js
  - bounded settings state: tests/model.test.js
  - no plugin-owned path or helper process: tests/a11y.test.js and e2e/buzz.sh
Coverage: 3/3 flows (100%)
