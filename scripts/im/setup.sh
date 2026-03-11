#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

WORKSPACE="$DEFAULT_WORKSPACE"
PLATFORM_ARG=""
PROVIDER_ARG=""
RUN_DOCTOR="false"

usage() {
  cat <<'EOF'
Usage: setup.sh [--platform claude|codex|gemini] [--workspace PATH] [--provider telegram|discord|feishu] [--doctor]
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
    --provider)
      PROVIDER_ARG="$2"
      shift 2
      ;;
    --doctor)
      RUN_DOCTOR="true"
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

load_state "$WORKSPACE"

if [[ -z "$PLATFORM_ARG" ]]; then
  PLATFORM_ARG="${PLATFORM:-$(prompt_select "Select platform" "claude" "codex" "gemini")}"
fi

if [[ -z "$PROVIDER_ARG" ]]; then
  PROVIDER_ARG="$(prompt_select "Select IM channel" "telegram" "discord" "feishu")"
fi

print_header "IM bridge"
echo "Repository: $IM_BRIDGE_REPO"
echo "Platform host: $PLATFORM_ARG"
echo "Provider: $PROVIDER_ARG"
print_bridge_runtime_isolation_notice "$PLATFORM_ARG"

TARGET_CONFIG_FILE="$(bridge_config_file "$PLATFORM_ARG")"
TARGET_CONFIG_MISSING="false"
if [[ ! -f "$TARGET_CONFIG_FILE" ]]; then
  TARGET_CONFIG_MISSING="true"
fi

bridge_clone_or_update "$WORKSPACE"
bridge_install_for_platform "$WORKSPACE" "$PLATFORM_ARG"
ensure_bridge_config_template "$WORKSPACE" "$PLATFORM_ARG"
if [[ "$TARGET_CONFIG_MISSING" == "true" ]]; then
  handle_missing_target_config_with_sibling_runtimes "$PLATFORM_ARG"
  BRIDGE_FORCE_FRESH_CREDENTIALS="true"
else
  BRIDGE_FORCE_FRESH_CREDENTIALS="false"
fi
configure_bridge_base "$PLATFORM_ARG" "$WORKSPACE"

case "$PROVIDER_ARG" in
  telegram)
    echo "Guide: https://core.telegram.org/bots#how-do-i-create-a-bot"
    echo "Chat ID lookup: https://api.telegram.org/botYOUR_TOKEN/getUpdates"
    ;;
  discord)
    echo "Guide: https://discord.com/developers/applications"
    ;;
  feishu)
    echo "Guide: https://open.feishu.cn/app"
    echo "Lark guide: https://open.larksuite.com/app"
    ;;
esac

configure_bridge_provider "$PLATFORM_ARG" "$PROVIDER_ARG"
write_im_plan "$WORKSPACE" "$PLATFORM_ARG"
write_im_runtime_summary "$WORKSPACE" "$PLATFORM_ARG" "$PROVIDER_ARG"

PLATFORM="$PLATFORM_ARG"
IM_PROVIDER="$PROVIDER_ARG"
IM_BRIDGE_SOURCE_DIR="$(bridge_source_dir "$WORKSPACE")"
IM_BRIDGE_SKILL_DIR="$(bridge_skill_dir "$PLATFORM_ARG")"
IM_BRIDGE_RUNTIME_HOME="$(bridge_runtime_home "$PLATFORM_ARG")"

if [[ "$RUN_DOCTOR" == "true" ]] || prompt_yes_no "Run IM bridge doctor now?"; then
  if run_bridge_doctor "$PLATFORM_ARG"; then
    record_component_status "im" "configured"
  else
    record_component_status "im" "pending"
  fi
else
  record_component_status "im" "configured"
fi

save_state "$WORKSPACE"

print_header "IM bridge summary"
echo "Skill dir: $IM_BRIDGE_SKILL_DIR"
echo "Runtime home: $IM_BRIDGE_RUNTIME_HOME"
echo "Config: $(bridge_config_file "$PLATFORM_ARG")"
echo "Provider: $IM_PROVIDER"
