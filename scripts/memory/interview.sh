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
preferred_name="$(prompt_input_default "User preferred name" "${USER:-$(whoami)}")"
primary_language="$(prompt_input_default "Primary language" "English")"
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
- Quick recall trigger phrases include: continue, resume, what were we doing, 刚才做到哪里了, 继续刚才的任务, 恢复一下.
- Quick recall source priority: active-task.md first, then last-session.md, then any named resume checkpoints.
- Quick recall speed rule: for the first recovery reply, check active-task.md first and avoid deep scanning unless the user asks for more context.
- Quick recall language rule: prefer the user's default language for recovery replies unless the user explicitly switches language.
- Quick recall protocol: when a trigger phrase appears, the first recovery reply should use exactly three sections in order: A. current main task, B. other interrupted tasks, C. recovery options.
- Quick recall readability rule: insert a divider line `---` between sections A, B, and C.
- Quick recall section A rule: the main task section must contain exactly three lines in this order: task: ..., progress: ..., next step: ....
- Quick recall section B rule: if other interrupted tasks exist, list them in priority order, and for each task use the same structure: task: ..., priority: ..., progress: ..., next step: ....
- Quick recall formatting rule: the first recovery reply must stay short, re-anchor context fast, and only then expand or execute.
- Quick recall hard rule: do not start the first recovery reply with background explanation, file references, or secondary tasks.
- Recovery follow-up rule: after the first compact recovery reply, insert one blank line, then optionally show the interrupted task list with pause time and priority order.
- Recovery choice rule: when interrupted tasks exist, offer numbered choices so the user can continue the main task or switch directly to another paused task.
- Recovery language rule: when the reply is in Chinese, localize the recovery options into Chinese as well.
- Recovery formatting hard rule: do not use bullets or decorative prefixes before `task:`, `progress:`, or `next step:`.
- Keep active-task and resumable checkpoints current during multi-step work so a new session can recover fast.
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
- Task: Initial workspace memory bootstrap
- Status: completed
- Last completed step: Memory interview finished and base workspace scaffold created
- Next step: Continue any pending IM / MCP / skills setup from unified bootstrap state
- Blocking decision: none
- Summary: Completed initial memory interview and created the workspace memory scaffold.
EOF

cat >"$WORKSPACE/.assistant/runtime/active-task.md" <<EOF
# Active Task

- Task: none
- Status: idle
- Last completed step: none
- Next step: none
- Blocking decision: none
- Note: Update this file first when a live multi-step task starts or pauses.
EOF

cat >"$WORKSPACE/.assistant/runtime/interrupted-tasks.md" <<EOF
# Interrupted Tasks

Use this file to track paused tasks across sessions. Sort higher-priority items first.

| Priority | Paused At | Task | Status | Next Step |
|---|---|---|---|---|
| P1 | $(date '+%Y-%m-%d %H:%M') | Initial workspace bootstrap follow-up | pending | Continue any pending IM / MCP / skills setup from unified bootstrap state |

Preferred recovery options:
- 1. 继续当前主任务
- 2. 切换到最高优先级的中断任务
- 3. 按编号切换到其他中断任务
EOF

cat >"$WORKSPACE/.assistant/runtime/resume-checkpoint-template.md" <<EOF
# Resume Checkpoint Template

- Task:
- Paused at:
- Priority:
- Status:
- Last completed step:
- Next step:
- Blocking decision:
- Priority note: active-task.md should be checked before named checkpoints during resume.
- Resume answer format:
  A. Current main task
  task: ...
  progress: ...
  next step: ...
- Format hard rule:
  section A must start directly with task/progress/next step lines and must not use bullets or decorative prefixes
- Follow-up section:
  B. Other interrupted tasks
  task: ...
  priority: P2
  progress: ...
  next step: ...
- Choice section:
  C. Recovery options
  options:
  1. 继续当前主任务
  2. 切换到 [P2] ...
  3. 切换到 [P3] ...
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
