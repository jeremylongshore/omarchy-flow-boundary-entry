# User Journeys: Flow Boundary
<!-- Managed by audit-tests. Journey criticality is hash-pinned after review. -->

## Journey: mark a clean context boundary

Personas: keyboard-first Omarchy operator
Trigger: operator opens Flow Boundary from the Omarchy bar
Critical: true
Linked RTM: REQ-FB-001, REQ-FB-004, REQ-FB-006, REQ-FB-007

| # | Step | Layer | Test file | Status |
|---|---|---|---|---|
| 1 | Plugin loads in the stock shell | L6 | e2e/buzz.sh | Covered |
| 2 | Panel opens through IPC | L6 | e2e/buzz.sh | Covered |
| 3 | Arrive and Leave expose named button roles | L5 | tests/a11y.test.js | Covered |
| 4 | Selection publishes a bounded private event | L3, L4 | tests/helper.test.js | Covered |
| 5 | Timeline renders the event as bounded plain text | L3, L6 | tests/model.test.js, tests/a11y.test.js | Covered |

Coverage: 5/5 steps (100%)

## Journey: recover safely from hostile local state

Personas: privacy-conscious operator
Trigger: the state path, ledger, or publication entry is replaced by a same-UID process
Critical: true
Linked RTM: REQ-FB-002, REQ-FB-003, REQ-FB-005

| # | Step | Layer | Test file | Status |
|---|---|---|---|---|
| 1 | Traverse every state-path component without following symlinks | L5 | tests/helper.test.js | Covered |
| 2 | Reject symlink, FIFO, oversized, or foreign state input without blocking | L5 | tests/helper.test.js | Covered |
| 3 | Retain temp identity through rename and fsync the directory | L3, L5 | tests/helper.test.js | Covered |
| 4 | Preserve unrelated victims during final, temp, and parent racing | L5 | tests/helper.test.js, tests/fixtures | Covered |
| 5 | Continue to run with stock Omarchy dependencies only | L2, L6 | tests/smoke.test.js, e2e/buzz.sh | Covered |

Coverage: 5/5 steps (100%)
