# System Metrics HUD for Omarchy

Real-time CPU, GPU, Network graphs, circular RAM/VRAM progress meters, and temperature telemetry desktop HUD pinned to monitor DP-4.

## Features

- Pinned directly to portrait monitor `DP-4`.
- Circular progress rings for System RAM and GPU VRAM (used / total GB and percentage).
- Real-time sparkline graphs for CPU usage (with CPU temperature in °C).
- Real-time sparkline graphs for AMD GPU usage (with GPU temperature in °C).
- Real-time network throughput graph (Download/Upload rates).
- CLI helper: `system-metrics-collector once`.

## License

MIT
# Monitor selection

Set `targetScreen` in `~/.config/omarchy/system-metrics.json` to the desired
Hyprland connector name, for example `{"targetScreen": "HDMI-A-1"}`. Changes
reload automatically. When the target is absent or no target is configured,
the HUD uses the second connected screen, then the first. Zero screens creates
no window. Pin and auto-hide preferences remain in the existing state file.
Screen selection regression tests: `node tests/screen-target.test.cjs`.
