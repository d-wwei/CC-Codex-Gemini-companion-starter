#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

WORKSPACE="$DEFAULT_WORKSPACE"

while [[ $# -gt 0 ]]; do
  case "$1" in
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

print_header "Reset"
echo "This removes only the unified bootstrap state for the workspace."
echo "It does not delete platform-global config, installed IM bridge skills, or the source repositories."

if prompt_yes_no "Delete $(state_dir "$WORKSPACE") ?"; then
  rm -rf "$(state_dir "$WORKSPACE")"
  echo "Unified bootstrap state removed."
else
  echo "Reset cancelled."
fi
