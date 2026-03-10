#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

WORKSPACE="$DEFAULT_WORKSPACE"
PLATFORM_ARG=""
MODULE_ARG=""

usage() {
  cat <<'EOF'
Usage: setup.sh [--platform claude|codex|gemini] [--workspace PATH] [--module im|mcp|skills]
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
    --module)
      MODULE_ARG="$2"
      shift 2
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
  if [[ -n "${PLATFORM}" ]]; then
    PLATFORM_ARG="${PLATFORM}"
  else
    PLATFORM_ARG="$(prompt_select "Select platform" "claude" "codex" "gemini")"
  fi
fi

if [[ -z "$MODULE_ARG" ]]; then
  MODULE_ARG="$(prompt_select "Select setup module" "im" "mcp" "skills")"
fi

case "$MODULE_ARG" in
  im)
    "$ROOT_DIR/scripts/im/setup.sh" --workspace "$WORKSPACE" --platform "$PLATFORM_ARG"
    load_state "$WORKSPACE"
    ;;
  mcp)
    print_header "MCP setup"
    write_mcp_plan "$WORKSPACE"
    echo "MCP entries are catalog-only in this repository."
    echo "Review the catalog and install selected MCPs with their native instructions:"
    echo "  $ROOT_DIR/catalogs/recommended-mcp-skills.md"
    if prompt_yes_no "Mark MCP as self-managed for now?"; then
      record_component_status "mcp" "configured"
    else
      record_component_status "mcp" "pending"
    fi
    ;;
  skills)
    print_header "Skills setup"
    write_skills_plan "$WORKSPACE"
    echo "Skills are catalog-only in this repository."
    echo "Review the catalog and install selected skills with their native instructions:"
    echo "  $ROOT_DIR/catalogs/recommended-mcp-skills.md"
    if prompt_yes_no "Mark skills as self-managed for now?"; then
      record_component_status "skills" "configured"
    else
      record_component_status "skills" "pending"
    fi
    ;;
  *)
    echo "Unknown module: $MODULE_ARG" >&2
    exit 1
    ;;
esac

PLATFORM="$PLATFORM_ARG"
save_state "$WORKSPACE"

print_header "Reconfigure summary"
echo "Workspace: $WORKSPACE"
echo "Platform: $PLATFORM_ARG"
echo "Module: $MODULE_ARG"
echo "Pending items: ${PENDING_ITEMS:-none}"
