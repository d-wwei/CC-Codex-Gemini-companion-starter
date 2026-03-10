#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

WORKSPACE="$DEFAULT_WORKSPACE"
PLATFORM_ARG=""

usage() {
  cat <<'EOF'
Usage: interview.sh [--workspace PATH] [--platform claude|codex|gemini]
EOF
}

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
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

mkdir -p "$WORKSPACE/.assistant" "$WORKSPACE/.assistant/runtime" "$WORKSPACE/.assistant/templates" "$WORKSPACE/.assistant/memory/daily" "$WORKSPACE/.assistant/memory/projects"

if [[ -z "$PLATFORM_ARG" ]]; then
  load_state "$WORKSPACE"
  PLATFORM_ARG="${PLATFORM:-unknown}"
fi

project_name="$(prompt_input_default "Project name" "$(basename "$WORKSPACE")")"
project_focus="$(prompt_input_default "Project focus / description" "Personal assistant enhancement workspace")"
preferred_name="$(prompt_input_default "User preferred name" "eli")"
primary_language="$(prompt_input_default "Primary language" "Chinese")"
assistant_role="$(prompt_input_default "Assistant role in this workspace" "the user's assistant")"
answer_style="$(prompt_input_default "Answer style" "conclusion first, concise, execution-first")"
workflow_pref="$(prompt_input_default "Preferred workflow" "inspect first, then edit, then summarize verification")"
memory_boundary="$(prompt_input_default "Memory boundary rule" "promote only confirmed cross-project preferences")"

cat >"$WORKSPACE/.assistant/SYSTEM.md" <<EOF
# Project System

- Project: $project_name
- Platform: $PLATFORM_ARG
- Focus: $project_focus
- Constraint: Favor lightweight, auditable, incremental assistant enhancement.
EOF

cat >"$WORKSPACE/.assistant/USER.md" <<EOF
# User

- Preferred name: $preferred_name
- Primary language: $primary_language
- Assistant role: $assistant_role
EOF

cat >"$WORKSPACE/.assistant/STYLE.md" <<EOF
# Style

- Preferred answer pattern: $answer_style
- Keep structure short and scannable.
- Adapt detail to explicit user cues.
EOF

cat >"$WORKSPACE/.assistant/WORKFLOW.md" <<EOF
# Workflow

- Preferred workflow: $workflow_pref
- Prefer incremental updates over full rewrites.
- Check existing files before creating parallel structures.
EOF

cat >"$WORKSPACE/.assistant/MEMORY.md" <<EOF
# Memory

- This workspace is initialized through CC-Codex-Gemini Companion Starter.
- Stable memory rule: $memory_boundary
- Keep cross-project preferences separate from project-local decisions.
EOF

cat >"$WORKSPACE/.assistant/TOOLS.md" <<EOF
# Tools

- Primary platform: $PLATFORM_ARG
- Manage IM bridge through the unified repository when possible.
- Treat external MCPs and skills as self-managed Tier 3 components unless promoted later.
EOF

cat >"$WORKSPACE/.assistant/BOOTSTRAP.md" <<EOF
# Bootstrap Status

- status: initialized
- initialized_at: $(date '+%Y-%m-%d')
- initialized_by: CC-Codex-Gemini Companion Starter
- note: Memory interview completed and core workspace files created.
EOF

cat >"$WORKSPACE/.assistant/sync-policy.md" <<EOF
# Sync Policy

- mode: ask
- note: $memory_boundary
EOF

cat >"$WORKSPACE/.assistant/runtime/inbox.md" <<EOF
# Inbox

- Finish any pending IM / MCP / skills setup tracked by the unified bootstrap state.
EOF

cat >"$WORKSPACE/.assistant/runtime/last-session.md" <<EOF
# Last Session

- Date: $(date '+%Y-%m-%d')
- Summary: Completed initial memory interview and created the workspace memory scaffold.
EOF

cat >"$WORKSPACE/.assistant/templates/README.md" <<EOF
# Templates

Store reusable prompts, checklists, and delivery templates for $project_name here.
EOF

load_state "$WORKSPACE"
PLATFORM="$PLATFORM_ARG"
complete_interview
save_state "$WORKSPACE"

print_header "Memory interview summary"
echo "Workspace: $WORKSPACE"
echo "Project: $project_name"
echo "User: $preferred_name"
echo "Language: $primary_language"
