#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

tmp_root="$(new_tmp_root memory)"
workspace="$tmp_root/workspace"
mkdir -p "$workspace"

printf 'Smoke Project\nMemory smoke test\neli\nChinese\nassistant\nconclusion first\ninspect then edit\npromote confirmed prefs only\n' \
  | "$ROOT_DIR/scripts/memory/interview.sh" --workspace "$workspace" --platform codex >/tmp/cccg-memory.out 2>&1

assert_file_exists "$workspace/.assistant/SYSTEM.md"
assert_file_exists "$workspace/.assistant/USER.md"
assert_file_exists "$workspace/.assistant/STYLE.md"
assert_contains "$workspace/.assistant/SYSTEM.md" "Project: Smoke Project"
assert_contains "$workspace/.assistant/USER.md" "Preferred name: eli"
assert_contains "$workspace/.assistant/WORKFLOW.md" "Preferred workflow: inspect then edit"

echo "PASS: memory interview"
