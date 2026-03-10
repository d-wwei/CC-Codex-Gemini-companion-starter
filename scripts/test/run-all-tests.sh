#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/run-smoke-tests.sh"
bash "$SCRIPT_DIR/test-im-install-chain.sh"

echo "PASS: smoke + semi-integration"
