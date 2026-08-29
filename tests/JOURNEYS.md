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
| 4 | Selection publishes a bounded event through Omarchy's settings owner | L3, L4 | tests/model.test.js, tests/a11y.test.js, e2e/buzz.sh | Covered |
| 5 | Timeline renders the event as bounded plain text | L3, L6 | tests/model.test.js, tests/a11y.test.js | Covered |

Coverage: 5/5 steps (100%)

## Journey: preserve a private bounded history across shell restarts

Personas: privacy-conscious operator
Trigger: the operator records a boundary and restarts the Omarchy shell
Critical: true
Linked RTM: REQ-FB-002, REQ-FB-003, REQ-FB-005

| # | Step | Layer | Test file | Status |
|---|---|---|---|---|
| 1 | Reject malformed, oversized, or unrecognized setting values | L3, L5 | tests/model.test.js | Covered |
| 2 | Keep at most 32 valid timestamped boundaries | L3, L5 | tests/model.test.js | Covered |
| 3 | Open no plugin-owned state path and launch no helper process | L2, L5 | tests/a11y.test.js, scripts/gates | Covered |
| 4 | Persist through Omarchy's first-party inline settings API | L4, L6 | tests/a11y.test.js, e2e/buzz.sh | Covered |
| 5 | Reload the persisted timeline after a real shell restart | L6 | e2e/buzz.sh | Covered |

Coverage: 5/5 steps (100%)
