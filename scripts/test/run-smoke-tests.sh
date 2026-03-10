#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/test-memory.sh"
bash "$SCRIPT_DIR/test-install-flows.sh"
bash "$SCRIPT_DIR/test-im.sh"

echo "PASS: all smoke tests"
