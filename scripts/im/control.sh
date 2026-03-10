#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

WORKSPACE="$DEFAULT_WORKSPACE"
PLATFORM_ARG=""
ACTION="${1:-}"
shift || true

usage() {
  cat <<'EOF'
Usage: control.sh <start|stop|status|logs|doctor> [--workspace PATH] [--platform claude|codex|gemini] [log_lines]
EOF
}

if [[ -z "$ACTION" ]]; then
  usage
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace)
      WORKSPACE="$2"
      shift 2
      ;;
    --platform)
      PLATFORM_ARG="$(normalize_platform "$2")"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

load_state "$WORKSPACE"

if [[ -z "$PLATFORM_ARG" ]]; then
  PLATFORM_ARG="${PLATFORM:-}"
fi

if [[ -z "$PLATFORM_ARG" ]]; then
  echo "Platform is required. Pass --platform or configure the workspace first." >&2
  exit 1
fi

skill_dir="${IM_BRIDGE_SKILL_DIR:-$(bridge_skill_dir "$PLATFORM_ARG")}"
daemon_script="$skill_dir/scripts/daemon.sh"

if [[ "$ACTION" == "doctor" ]]; then
  run_bridge_doctor "$PLATFORM_ARG"
  exit $?
fi

if [[ ! -f "$daemon_script" ]]; then
  echo "Bridge daemon script not found: $daemon_script" >&2
  exit 1
fi

case "$ACTION" in
  start|stop|status)
    bash "$daemon_script" "$ACTION"
    ;;
  logs)
    lines="${1:-50}"
    bash "$daemon_script" logs "$lines"
    ;;
  *)
    usage
    exit 1
    ;;
esac
