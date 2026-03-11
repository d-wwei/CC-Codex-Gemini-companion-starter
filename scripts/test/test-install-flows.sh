#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

tmp_root="$(new_tmp_root install)"
workspace="$tmp_root/workspace"
home_dir="$tmp_root/home"
mkdir -p "$workspace" "$home_dir/.codex"

install_log="$tmp_root/install.log"

cat <<'EOF' | HOME="$home_dir" "$ROOT_DIR/bin/cccg-companion" install --workspace "$workspace" --platform codex --mode fresh --accept-disclaimer >"$install_log" 2>&1
Smoke Project
Install flow smoke test
testuser
English
assistant
conclusion first
inspect then edit
promote confirmed prefs only
n
y
y
y
y
EOF

assert_file_exists "$workspace/.assistant/unified-bootstrap/state.env"
assert_contains "$workspace/.assistant/unified-bootstrap/state.env" 'PLATFORM="codex"'
assert_contains "$workspace/.assistant/unified-bootstrap/state.env" 'INTERVIEW_STATUS="completed"'
assert_contains "$workspace/.assistant/unified-bootstrap/state.env" 'IM_STATUS="pending"'
assert_contains "$workspace/.assistant/unified-bootstrap/state.env" 'MCP_STATUS="configured"'
assert_contains "$workspace/.assistant/unified-bootstrap/state.env" 'SKILLS_STATUS="configured"'
assert_contains "$workspace/.assistant/unified-bootstrap/state.env" 'PENDING_ITEMS="im"'

partial_log="$tmp_root/partial.log"
printf '2\ny\n' | HOME="$home_dir" "$ROOT_DIR/bin/cccg-companion" install --workspace "$workspace" --platform codex --mode partial --accept-disclaimer >"$partial_log" 2>&1
assert_output_contains "$(cat "$partial_log")" "MCP entries are catalog-only in this repository."

doctor_log="$tmp_root/doctor.log"
HOME="$home_dir" "$ROOT_DIR/bin/cccg-companion" doctor --workspace "$workspace" --platform codex >"$doctor_log" 2>&1
assert_contains "$doctor_log" "Memory: configured"
assert_contains "$doctor_log" "Interview: completed"
assert_contains "$doctor_log" "MCP: configured"
assert_contains "$doctor_log" "Skills: configured"

echo "PASS: install flows"
