#!/usr/bin/env bash
set -euo pipefail

# CocoaPods/Ruby can crash if the terminal encoding isn't UTF-8.
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

cd "$(dirname "$0")"

echo "[pod_install.sh] LANG=$LANG"
echo "[pod_install.sh] LC_ALL=$LC_ALL"
echo "[pod_install.sh] Running pod install..."

pod install



