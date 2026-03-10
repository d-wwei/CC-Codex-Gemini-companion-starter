#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

WORKSPACE="$DEFAULT_WORKSPACE"
PLATFORM_ARG=""

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
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

load_state "$WORKSPACE"

if [[ -z "$PLATFORM_ARG" ]]; then
  PLATFORM_ARG="${PLATFORM:-unknown}"
fi

print_header "Doctor report"
echo "Workspace: $WORKSPACE"
echo "Platform: $PLATFORM_ARG"
echo "State file: $(state_file "$WORKSPACE")"

if [[ -f "$(state_file "$WORKSPACE")" ]]; then
  echo "State: present"
else
  echo "State: missing"
fi

if [[ -d "$WORKSPACE/.assistant" ]]; then
  echo ".assistant: present"
else
  echo ".assistant: missing"
fi

if [[ "$PLATFORM_ARG" != "unknown" ]]; then
  global_dir="$(platform_global_dir "$PLATFORM_ARG")"
  global_entry="$(platform_global_entry "$PLATFORM_ARG")"
  if [[ -f "$global_dir/$global_entry" ]]; then
    echo "Global config: present ($global_dir/$global_entry)"
  else
    echo "Global config: missing ($global_dir/$global_entry)"
  fi
fi

echo "Memory: ${MEMORY_STATUS}"
echo "Interview: ${INTERVIEW_STATUS}"
echo "IM: ${IM_STATUS}"
if [[ -n "${IM_PROVIDER}" ]]; then
  echo "IM provider: ${IM_PROVIDER}"
fi
if [[ -n "${IM_BRIDGE_SKILL_DIR}" ]]; then
  echo "IM skill dir: ${IM_BRIDGE_SKILL_DIR}"
fi
if [[ -n "${IM_BRIDGE_RUNTIME_HOME}" ]]; then
  echo "IM runtime home: ${IM_BRIDGE_RUNTIME_HOME}"
fi
echo "MCP: ${MCP_STATUS}"
echo "Skills: ${SKILLS_STATUS}"
echo "Pending: ${PENDING_ITEMS:-none}"

if [[ "${IM_STATUS}" == "configured" && "$PLATFORM_ARG" != "unknown" ]]; then
  print_header "IM bridge doctor"
  run_bridge_doctor "$PLATFORM_ARG" || true
fi
