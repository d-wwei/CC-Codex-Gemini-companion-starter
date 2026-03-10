#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

tmp_root="$(new_tmp_root im)"
workspace="$tmp_root/workspace"
home_dir="$tmp_root/home"
skill_dir="$home_dir/.codex/skills/codex-to-im/scripts"
runtime_home="$home_dir/.codex-to-im"
mkdir -p "$workspace/.assistant/unified-bootstrap" "$skill_dir" "$runtime_home/logs" "$runtime_home/runtime"

cat >"$workspace/.assistant/unified-bootstrap/state.env" <<EOF
PLATFORM="codex"
DISCLAIMER_ACCEPTED="true"
LAST_MODE="continue"
MEMORY_STATUS="configured"
INTERVIEW_STATUS="completed"
IM_STATUS="configured"
IM_PROVIDER="telegram"
IM_BRIDGE_REPO="https://github.com/d-wwei/Claude-Codex-Gemini-to-IM"
IM_BRIDGE_SOURCE_DIR="$tmp_root/source"
IM_BRIDGE_SKILL_DIR="$home_dir/.codex/skills/codex-to-im"
IM_BRIDGE_RUNTIME_HOME="$runtime_home"
MCP_STATUS="pending"
SKILLS_STATUS="pending"
PENDING_ITEMS="mcp,skills"
LAST_UPDATED="2026-03-11T00:00:00+0800"
EOF

cat >"$skill_dir/daemon.sh" <<'EOF'
#!/usr/bin/env bash
case "$1" in
  start) echo started ;;
  stop) echo stopped ;;
  status) echo running ;;
  logs) echo "log-$2" ;;
  *) echo "unknown-$1" ;;
esac
EOF

cat >"$skill_dir/doctor.sh" <<'EOF'
#!/usr/bin/env bash
echo doctor-ok
EOF

chmod +x "$skill_dir/daemon.sh" "$skill_dir/doctor.sh"

start_out="$(HOME="$home_dir" "$ROOT_DIR/bin/cccg-companion" im start --workspace "$workspace")"
status_out="$(HOME="$home_dir" "$ROOT_DIR/bin/cccg-companion" im status --workspace "$workspace")"
logs_out="$(HOME="$home_dir" "$ROOT_DIR/bin/cccg-companion" im logs --workspace "$workspace" 25)"
doctor_out="$(HOME="$home_dir" "$ROOT_DIR/bin/cccg-companion" im doctor --workspace "$workspace")"

assert_output_contains "$start_out" "started"
assert_output_contains "$status_out" "running"
assert_output_contains "$logs_out" "log-25"
assert_output_contains "$doctor_out" "doctor-ok"

echo "PASS: im control"
