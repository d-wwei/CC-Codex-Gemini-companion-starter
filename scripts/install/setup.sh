#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

WORKSPACE="$DEFAULT_WORKSPACE"
PLATFORM_ARG=""
MODE_ARG=""
ACCEPT_DISCLAIMER="false"

usage() {
  cat <<'EOF'
Usage: setup.sh [--platform claude|codex|gemini] [--workspace PATH] [--mode fresh|continue|partial] [--accept-disclaimer]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform)
      PLATFORM_ARG="$(normalize_platform "$2")"
      shift 2
      ;;
    --workspace)
      WORKSPACE="$2"
      shift 2
      ;;
    --mode)
      MODE_ARG="$2"
      shift 2
      ;;
    --accept-disclaimer)
      ACCEPT_DISCLAIMER="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

mkdir -p "$WORKSPACE"
ensure_state_dir "$WORKSPACE"

if [[ -z "$PLATFORM_ARG" ]]; then
  choice="$(prompt_select "Select platform" "claude" "codex" "gemini")"
  PLATFORM_ARG="$choice"
fi

load_state "$WORKSPACE"

if [[ "$(detect_existing_install "$WORKSPACE" "$PLATFORM_ARG")" == "true" && -z "$MODE_ARG" ]]; then
  choice="$(prompt_select "Existing installation detected" \
    "fresh" \
    "continue" \
    "partial")"
  MODE_ARG="$choice"
fi

if [[ -z "$MODE_ARG" ]]; then
  MODE_ARG="fresh"
fi

if [[ "$ACCEPT_DISCLAIMER" != "true" ]]; then
  print_header "Open source disclaimer"
  cat "$ROOT_DIR/docs/disclaimer.md"
  echo
  if ! prompt_yes_no "Do you agree and want to continue?"; then
    echo "Installation aborted."
    exit 1
  fi
fi

DISCLAIMER_ACCEPTED="true"
LAST_MODE="$MODE_ARG"

if [[ "$MODE_ARG" == "fresh" ]]; then
  set_defaults
  DISCLAIMER_ACCEPTED="true"
  LAST_MODE="$MODE_ARG"
  mark_memory_ready "$PLATFORM_ARG" "$WORKSPACE"
elif [[ "$MODE_ARG" == "continue" ]]; then
  if [[ "${MEMORY_STATUS}" != "configured" ]]; then
    mark_memory_ready "$PLATFORM_ARG" "$WORKSPACE"
  else
    PLATFORM="$PLATFORM_ARG"
  fi
elif [[ "$MODE_ARG" == "partial" ]]; then
  PLATFORM="$PLATFORM_ARG"
  save_state "$WORKSPACE"
  exec "$ROOT_DIR/scripts/reconfigure/setup.sh" --workspace "$WORKSPACE" --platform "$PLATFORM_ARG"
else
  echo "Unknown mode: $MODE_ARG" >&2
  exit 1
fi

print_header "Memory interview"
echo "The memory layer is prepared."
echo "Next, run the platform-specific memory bootstrap shown in:"
echo "  $(state_dir "$WORKSPACE")/platform-next-steps.md"
if [[ "${INTERVIEW_STATUS}" == "completed" ]]; then
  echo "Memory interview already marked as completed."
else
  save_state "$WORKSPACE"
  "$ROOT_DIR/scripts/memory/interview.sh" --workspace "$WORKSPACE" --platform "$PLATFORM_ARG"
  load_state "$WORKSPACE"
fi

save_state "$WORKSPACE"

if [[ "${IM_STATUS}" == "configured" ]]; then
  echo "IM bridge already configured."
elif prompt_yes_no "Configure IM bridge now?"; then
  "$ROOT_DIR/scripts/reconfigure/setup.sh" --workspace "$WORKSPACE" --platform "$PLATFORM_ARG" --module im
  load_state "$WORKSPACE"
else
  record_component_status "im" "pending"
fi

if [[ "${MCP_STATUS}" == "configured" ]]; then
  echo "MCP already configured."
elif prompt_yes_no "Configure MCP now?"; then
  save_state "$WORKSPACE"
  "$ROOT_DIR/scripts/reconfigure/setup.sh" --workspace "$WORKSPACE" --platform "$PLATFORM_ARG" --module mcp
  load_state "$WORKSPACE"
else
  record_component_status "mcp" "pending"
fi

if [[ "${SKILLS_STATUS}" == "configured" ]]; then
  echo "Skills already configured."
elif prompt_yes_no "Configure skills now?"; then
  save_state "$WORKSPACE"
  "$ROOT_DIR/scripts/reconfigure/setup.sh" --workspace "$WORKSPACE" --platform "$PLATFORM_ARG" --module skills
  load_state "$WORKSPACE"
else
  record_component_status "skills" "pending"
fi

save_state "$WORKSPACE"

print_header "Installation summary"
echo "Workspace: $WORKSPACE"
echo "Platform: $PLATFORM_ARG"
echo "State file: $(state_file "$WORKSPACE")"
echo "Pending items: ${PENDING_ITEMS:-none}"
if [[ -n "${IM_BRIDGE_SKILL_DIR}" ]]; then
  echo "IM bridge skill dir: ${IM_BRIDGE_SKILL_DIR}"
fi
echo
cat "$ROOT_DIR/docs/greeting.txt"
