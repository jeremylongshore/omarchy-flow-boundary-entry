# Flow Boundary

![Flow Boundary banner](assets/banner.svg)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/U5S225PTME)

Flow Boundary marks the moment you enter or leave a focus block without handing
your schedule, projects, or notifications to another service. Its Omarchy bar
widget gives you explicit Arrive and Leave actions and a color-coded timeline of
recent context changes, helping you close one task cleanly before opening the
next and reconstruct where the day changed direction.

It does not inspect calendar events, project contents, or notification history.
The bounded history is stored through Omarchy's own inline widget-settings API,
so Flow Boundary opens no state pathname and needs no helper interpreter. There
is no account, cloud sync, telemetry, or background network access.

## Install

```bash
omarchy plugin add https://github.com/jeremylongshore/omarchy-flow-boundary-entry --enable
```

Use the panel's Arrive and Leave actions to create a local boundary record.

## Verify

```bash
npm test
bash scripts/run-plugin-gates.sh
bash scripts/check-lane-freshness.sh
bash scripts/rig-verify.sh .
bash scripts/rig-render.sh . preview.png
```

## License

MIT
