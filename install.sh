#!/usr/bin/env bash
set -euo pipefail
dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "$dir/bin/system-metrics-collector"
mkdir -p "$HOME/.local/bin"
ln -sf "$dir/bin/system-metrics-collector" "$HOME/.local/bin/system-metrics-collector"
