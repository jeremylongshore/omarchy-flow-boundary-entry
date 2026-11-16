# Requirements Traceability Matrix: Flow Boundary
<!-- Managed by audit-tests. MoSCoW decisions are hash-pinned after review. -->

| Req ID | MoSCoW | Source | Description | Layers | Test files | Status |
|---|---|---|---|---|---|---|
| REQ-FB-001 | MUST | README.md | Record arrive and leave boundaries in bounded Omarchy-owned widget settings | L3, L4 | tests/model.test.js, tests/a11y.test.js | Covered |
| REQ-FB-002 | MUST | README.md | Make no network calls and inspect no calendar, project, or notification content | L2, L5 | scripts/gates, tests/smoke.test.js | Covered |
| REQ-FB-003 | MUST | Marketplace #2903 | Open no mutable state pathname and delegate persistence to the first-party shell API | L3, L5 | tests/model.test.js, tests/a11y.test.js, e2e/buzz.sh | Covered |
| REQ-FB-004 | MUST | Panel.qml | Parse only bounded valid events and render untrusted fields as plain text | L3, L5 | tests/model.test.js, tests/a11y.test.js | Covered |
| REQ-FB-005 | MUST | manifest.json | Run on stock Omarchy without Node or Python at runtime | L2, L6 | tests/smoke.test.js, scripts/rig-verify.sh | Covered |
| REQ-FB-006 | MUST | Panel.qml | Expose named button roles for both boundary actions | L5, L6 | tests/a11y.test.js | Covered |
| REQ-FB-007 | MUST | submission process | Validate, load, open, and render in the production-parity Buzz shell | L6, L7 | e2e/buzz.sh | Covered |
| REQ-FB-008 | SHOULD | marketplace presentation | Distinguish arrivals and departures with per-kind hues and a visual hierarchy | L3, L6 | tests/model.test.js, e2e/buzz.sh | Covered |
| REQ-FB-009 | MUST | tests/PERSONAS.md | Operate Arrive and Leave from the keyboard: Left and Right choose, Enter or Space marks, one record per press | L3, L5, L6 | tests/model.test.js, tests/a11y.test.js, scripts/rig-render.sh, e2e/buzz.sh | Covered |
| REQ-FB-010 | SHOULD | audit 2026-11-15 | Keep text and edges legible on light themes by choosing lightness from the popup surface | L3, L5, L6 | tests/model.test.js, tests/a11y.test.js, scripts/rig-render.sh | Covered |
