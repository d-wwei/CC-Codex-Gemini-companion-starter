#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEFAULT_WORKSPACE="$(pwd)"

platform_global_dir() {
  case "$1" in
    claude) echo "$HOME/.claude" ;;
    codex) echo "$HOME/.codex" ;;
    gemini) echo "$HOME/.gemini" ;;
    *) return 1 ;;
  esac
}

platform_global_entry() {
  case "$1" in
    claude) echo "CLAUDE.md" ;;
    codex) echo "AGENTS.md" ;;
    gemini) echo "GEMINI.md" ;;
    *) return 1 ;;
  esac
}

normalize_platform() {
  local input
  input="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  case "$input" in
    claude|codex|gemini) echo "$input" ;;
    *) return 1 ;;
  esac
}

state_dir() {
  echo "$1/.assistant/unified-bootstrap"
}

state_file() {
  echo "$(state_dir "$1")/state.env"
}

ensure_state_dir() {
  mkdir -p "$(state_dir "$1")"
}

set_defaults() {
  PLATFORM=""
  DISCLAIMER_ACCEPTED="false"
  LAST_MODE=""
  MEMORY_STATUS="pending"
  INTERVIEW_STATUS="pending"
  IM_STATUS="pending"
  IM_PROVIDER=""
  IM_BRIDGE_REPO="https://github.com/d-wwei/Claude-Codex-Gemini-to-IM"
  IM_BRIDGE_SOURCE_DIR=""
  IM_BRIDGE_SKILL_DIR=""
  IM_BRIDGE_RUNTIME_HOME=""
  MCP_STATUS="pending"
  SKILLS_STATUS="pending"
  PENDING_ITEMS=""
  LAST_UPDATED=""
}

load_state() {
  local workspace="$1"
  set_defaults
  if [[ -f "$(state_file "$workspace")" ]]; then
    # shellcheck disable=SC1090
    source "$(state_file "$workspace")"
  fi
}

save_state() {
  local workspace="$1"
  ensure_state_dir "$workspace"
  LAST_UPDATED="$(date '+%Y-%m-%dT%H:%M:%S%z')"
  cat >"$(state_file "$workspace")" <<EOF
PLATFORM="${PLATFORM}"
DISCLAIMER_ACCEPTED="${DISCLAIMER_ACCEPTED}"
LAST_MODE="${LAST_MODE}"
MEMORY_STATUS="${MEMORY_STATUS}"
INTERVIEW_STATUS="${INTERVIEW_STATUS}"
IM_STATUS="${IM_STATUS}"
IM_PROVIDER="${IM_PROVIDER}"
IM_BRIDGE_REPO="${IM_BRIDGE_REPO}"
IM_BRIDGE_SOURCE_DIR="${IM_BRIDGE_SOURCE_DIR}"
IM_BRIDGE_SKILL_DIR="${IM_BRIDGE_SKILL_DIR}"
IM_BRIDGE_RUNTIME_HOME="${IM_BRIDGE_RUNTIME_HOME}"
MCP_STATUS="${MCP_STATUS}"
SKILLS_STATUS="${SKILLS_STATUS}"
PENDING_ITEMS="${PENDING_ITEMS}"
LAST_UPDATED="${LAST_UPDATED}"
EOF
}

append_pending_item() {
  local item="$1"
  if [[ -z "${PENDING_ITEMS}" ]]; then
    PENDING_ITEMS="$item"
  elif [[ ",${PENDING_ITEMS}," != *",$item,"* ]]; then
    PENDING_ITEMS="${PENDING_ITEMS},$item"
  fi
}

remove_pending_item() {
  local item="$1"
  local next=""
  local -a current=()
  if [[ -n "${PENDING_ITEMS}" ]]; then
    IFS=',' read -r -a current <<<"${PENDING_ITEMS}"
  fi
  for entry in "${current[@]-}"; do
    [[ -z "$entry" || "$entry" == "$item" ]] && continue
    if [[ -z "$next" ]]; then
      next="$entry"
    else
      next="${next},$entry"
    fi
  done
  PENDING_ITEMS="$next"
}

detect_existing_install() {
  local workspace="$1"
  local platform="$2"
  local global_dir global_entry exists="false"
  global_dir="$(platform_global_dir "$platform")"
  global_entry="$(platform_global_entry "$platform")"

  if [[ -f "$(state_file "$workspace")" ]]; then
    exists="true"
  fi
  if [[ -d "$workspace/.assistant" ]]; then
    exists="true"
  fi
  if [[ -f "$global_dir/$global_entry" ]]; then
    exists="true"
  fi

  printf '%s\n' "$exists"
}

print_header() {
  printf '\n== %s ==\n' "$1"
}

prompt_input() {
  local label="$1"
  local result
  read -r -p "$label" result
  printf '%s' "$result"
}

prompt_input_default() {
  local label="$1"
  local default_value="${2:-}"
  local result
  if [[ -n "$default_value" ]]; then
    read -r -p "$label [$default_value]: " result
    printf '%s' "${result:-$default_value}"
  else
    read -r -p "$label: " result
    printf '%s' "$result"
  fi
}

prompt_secret_default() {
  local label="$1"
  local default_value="${2:-}"
  local result
  if [[ -n "$default_value" ]]; then
    read -r -s -p "$label [stored]: " result
    echo >&2
    printf '%s' "${result:-$default_value}"
  else
    read -r -s -p "$label: " result
    echo >&2
    printf '%s' "$result"
  fi
}

prompt_select() {
  local title="$1"
  shift
  local options=("$@")
  local i choice
  print_header "$title" >&2
  for i in "${!options[@]}"; do
    printf '%s. %s\n' "$((i + 1))" "${options[$i]}" >&2
  done
  while true; do
    read -r -p "Choose [1-${#options[@]}]: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
      printf '%s' "${options[$((choice - 1))]}"
      return 0
    fi
  done
}

prompt_yes_no() {
  local label="$1"
  local answer
  while true; do
    read -r -p "$label [y/n]: " answer
    case "$(printf '%s' "$answer" | tr '[:upper:]' '[:lower:]')" in
      y|yes) return 0 ;;
      n|no) return 1 ;;
    esac
  done
}

copy_memory_assets() {
  local platform="$1"
  local workspace="$2"
  local source_dir=""
  local dest_dir
  dest_dir="$(state_dir "$workspace")/memory-source"

  case "$platform" in
    claude) source_dir="$ROOT_DIR/../claude-recall" ;;
    codex) source_dir="$ROOT_DIR/../codex-recall" ;;
    gemini) source_dir="$ROOT_DIR/../gemini-recall" ;;
  esac

  mkdir -p "$dest_dir"

  if [[ -d "$source_dir" ]]; then
    cat >"$dest_dir/README.md" <<EOF
# Memory Source

Platform: $platform
Local source: $source_dir

This unified installer reuses the existing memory repository as the source of truth.
EOF
    case "$platform" in
      claude|gemini)
        cp "$source_dir/BOOTSTRAP_PROMPT.md" "$dest_dir/${platform}-bootstrap-prompt.md"
        ;;
      codex)
        cp "$source_dir/SKILL.md" "$dest_dir/codex-skill.md"
        cp "$source_dir/README.md" "$dest_dir/codex-install-reference.md"
        ;;
    esac
  else
    cat >"$dest_dir/README.md" <<EOF
# Memory Source

Platform: $platform

No local sibling memory repository was found. Use the platform manifest in this repository to install from GitHub.
EOF
  fi
}

write_platform_plan() {
  local platform="$1"
  local workspace="$2"
  local global_dir global_entry output
  global_dir="$(platform_global_dir "$platform")"
  global_entry="$(platform_global_entry "$platform")"
  output="$(state_dir "$workspace")/platform-next-steps.md"

  case "$platform" in
    claude)
      cat >"$output" <<EOF
# Claude Setup Next Steps

1. Ensure Claude Code is installed.
2. Review the copied bootstrap prompt:
   - $(state_dir "$workspace")/memory-source/claude-bootstrap-prompt.md
3. Start Claude Code in the target workspace and paste the prompt.
4. Confirm global files in:
   - $global_dir/$global_entry
EOF
      ;;
    codex)
      cat >"$output" <<EOF
# Codex Setup Next Steps

1. Ensure Codex is installed and logged in.
2. Install the memory skill from the existing repository:

\`\`\`bash
python ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \\
  --repo d-wwei/codex-recall \\
  --path .
\`\`\`

3. Review local reference material:
   - $(state_dir "$workspace")/memory-source/codex-skill.md
4. Confirm global file in:
   - $global_dir/$global_entry
EOF
      ;;
    gemini)
      cat >"$output" <<EOF
# Gemini Setup Next Steps

1. Ensure Gemini CLI is installed.
2. Review the copied bootstrap prompt:
   - $(state_dir "$workspace")/memory-source/gemini-bootstrap-prompt.md
3. Start Gemini CLI in the target workspace and paste the prompt.
4. Confirm global file in:
   - $global_dir/$global_entry
EOF
      ;;
  esac
}

mark_memory_ready() {
  local platform="$1"
  local workspace="$2"
  mkdir -p "$workspace/.assistant"
  copy_memory_assets "$platform" "$workspace"
  write_platform_plan "$platform" "$workspace"
  PLATFORM="$platform"
  MEMORY_STATUS="configured"
  INTERVIEW_STATUS="pending"
  remove_pending_item "memory"
}

complete_interview() {
  INTERVIEW_STATUS="completed"
  remove_pending_item "interview"
}

handle_single_key_prompt() {
  local key_name="$1"
  local guide_url="$2"
  local item_name="$3"
  print_header "API key required for $item_name"
  echo "Key name: $key_name"
  echo "Guide: $guide_url"
  if prompt_yes_no "Do you want to provide the key in this shell session now?"; then
    read -r -s -p "Enter $key_name: " provided_key
    echo
    if [[ -n "$provided_key" ]]; then
      export "$key_name=$provided_key"
      echo "$key_name captured for the current shell session only."
    else
      echo "No key entered."
    fi
  else
    echo "Skipped key collection for now."
  fi
}

record_component_status() {
  local component="$1"
  local status="$2"
  case "$component" in
    im)
      IM_STATUS="$status"
      ;;
    mcp)
      MCP_STATUS="$status"
      ;;
    skills)
      SKILLS_STATUS="$status"
      ;;
  esac

  if [[ "$status" == "pending" || "$status" == "skipped" ]]; then
    append_pending_item "$component"
  else
    remove_pending_item "$component"
  fi
}

bridge_skill_name() {
  printf '%s-to-im' "$1"
}

bridge_skill_dir() {
  local platform="$1"
  printf '%s/%s' "$(platform_global_dir "$platform")/skills" "$(bridge_skill_name "$platform")"
}

bridge_runtime_home() {
  local platform="$1"
  printf '%s/.%s' "$HOME" "$(bridge_skill_name "$platform")"
}

bridge_config_file() {
  local platform="$1"
  printf '%s/config.env' "$(bridge_runtime_home "$platform")"
}

bridge_source_dir() {
  local workspace="$1"
  printf '%s/vendor/Claude-Codex-Gemini-to-IM' "$(state_dir "$workspace")"
}

bridge_doctor_script() {
  local platform="$1"
  printf '%s/scripts/doctor.sh' "$(bridge_skill_dir "$platform")"
}

bridge_clone_or_update() {
  local workspace="$1"
  local source_dir
  source_dir="$(bridge_source_dir "$workspace")"

  mkdir -p "$(dirname "$source_dir")"

  if [[ -d "$source_dir/.git" ]]; then
    git -C "$source_dir" pull --ff-only >/dev/null
  else
    rm -rf "$source_dir"
    git clone --depth 1 "$IM_BRIDGE_REPO" "$source_dir" >/dev/null
  fi

  IM_BRIDGE_SOURCE_DIR="$source_dir"
}

ensure_bridge_runtime_home() {
  local platform="$1"
  mkdir -p "$(bridge_runtime_home "$platform")"
  IM_BRIDGE_RUNTIME_HOME="$(bridge_runtime_home "$platform")"
}

ensure_bridge_config_template() {
  local workspace="$1"
  local platform="$2"
  local source_dir config_file
  source_dir="$(bridge_source_dir "$workspace")"
  config_file="$(bridge_config_file "$platform")"

  ensure_bridge_runtime_home "$platform"

  if [[ ! -f "$config_file" ]]; then
    cp "$source_dir/config.env.example" "$config_file"
    chmod 600 "$config_file"
  fi
}

upsert_env_file_value() {
  local file="$1"
  local key="$2"
  local value="$3"
  local escaped

  mkdir -p "$(dirname "$file")"
  touch "$file"

  escaped="$(printf '%s' "$value" | sed 's/[&/]/\\&/g')"
  if grep -q "^${key}=" "$file"; then
    sed -i.bak "s/^${key}=.*/${key}=${escaped}/" "$file"
    rm -f "$file.bak"
  else
    printf '%s=%s\n' "$key" "$value" >>"$file"
  fi
}

get_env_file_value() {
  local file="$1"
  local key="$2"
  if [[ -f "$file" ]]; then
    (grep "^${key}=" "$file" || true) | head -1 | cut -d= -f2- | sed "s/^['\"]//; s/['\"]$//"
  fi
}

bridge_install_for_platform() {
  local workspace="$1"
  local platform="$2"
  local source_dir skill_dir
  source_dir="$(bridge_source_dir "$workspace")"
  skill_dir="$(bridge_skill_dir "$platform")"

  if [[ ! -d "$source_dir" ]]; then
    echo "Bridge source is missing: $source_dir" >&2
    return 1
  fi

  if [[ -d "$skill_dir" ]]; then
    IM_BRIDGE_SKILL_DIR="$skill_dir"
    return 0
  fi

  bash "$source_dir/scripts/install-host.sh" --host "$platform"
  IM_BRIDGE_SKILL_DIR="$skill_dir"
}

write_im_runtime_summary() {
  local workspace="$1"
  local platform="$2"
  local provider="$3"
  local config_file
  config_file="$(bridge_config_file "$platform")"

  cat >"$(state_dir "$workspace")/im-runtime-summary.md" <<EOF
# IM Runtime Summary

Bridge repository: $IM_BRIDGE_REPO
Provider: $provider
Skill dir: $(bridge_skill_dir "$platform")
Runtime home: $(bridge_runtime_home "$platform")
Config file: $config_file

Common commands:

- $(bridge_skill_name "$platform") setup
- $(bridge_skill_name "$platform") start
- $(bridge_skill_name "$platform") stop
- $(bridge_skill_name "$platform") status
- $(bridge_skill_name "$platform") doctor
EOF
}

configure_bridge_base() {
  local platform="$1"
  local workspace="$2"
  local config_file runtime_value workdir_value mode_value channels
  config_file="$(bridge_config_file "$platform")"

  runtime_value="$(get_env_file_value "$config_file" "CTI_RUNTIME")"
  if [[ -z "$runtime_value" ]]; then
    runtime_value="$platform"
  fi
  runtime_value="$(prompt_input_default "Bridge runtime backend" "$runtime_value")"
  workdir_value="$(get_env_file_value "$config_file" "CTI_DEFAULT_WORKDIR")"
  if [[ -z "$workdir_value" ]]; then
    workdir_value="$workspace"
  fi
  workdir_value="$(prompt_input_default "Default workdir for bridge sessions" "$workdir_value")"
  mode_value="$(get_env_file_value "$config_file" "CTI_DEFAULT_MODE")"
  if [[ -z "$mode_value" ]]; then
    mode_value="code"
  fi
  mode_value="$(prompt_input_default "Default interaction mode (code/plan/ask)" "$mode_value")"
  channels="$(get_env_file_value "$config_file" "CTI_ENABLED_CHANNELS")"
  if [[ -z "$channels" ]]; then
    channels="telegram"
  fi

  upsert_env_file_value "$config_file" "CTI_RUNTIME" "$runtime_value"
  upsert_env_file_value "$config_file" "CTI_DEFAULT_WORKDIR" "$workdir_value"
  upsert_env_file_value "$config_file" "CTI_DEFAULT_MODE" "$mode_value"
}

configure_bridge_provider() {
  local platform="$1"
  local provider="$2"
  local config_file existing
  config_file="$(bridge_config_file "$platform")"

  case "$provider" in
    telegram)
      upsert_env_file_value "$config_file" "CTI_ENABLED_CHANNELS" "telegram"
      existing="$(get_env_file_value "$config_file" "CTI_TG_BOT_TOKEN")"
      upsert_env_file_value "$config_file" "CTI_TG_BOT_TOKEN" "$(prompt_secret_default "Telegram bot token" "$existing")"
      existing="$(get_env_file_value "$config_file" "CTI_TG_CHAT_ID")"
      upsert_env_file_value "$config_file" "CTI_TG_CHAT_ID" "$(prompt_input_default "Telegram chat ID" "$existing")"
      existing="$(get_env_file_value "$config_file" "CTI_TG_ALLOWED_USERS")"
      upsert_env_file_value "$config_file" "CTI_TG_ALLOWED_USERS" "$(prompt_input_default "Telegram allowed user IDs (optional)" "$existing")"
      ;;
    discord)
      upsert_env_file_value "$config_file" "CTI_ENABLED_CHANNELS" "discord"
      existing="$(get_env_file_value "$config_file" "CTI_DISCORD_BOT_TOKEN")"
      upsert_env_file_value "$config_file" "CTI_DISCORD_BOT_TOKEN" "$(prompt_secret_default "Discord bot token" "$existing")"
      existing="$(get_env_file_value "$config_file" "CTI_DISCORD_ALLOWED_USERS")"
      upsert_env_file_value "$config_file" "CTI_DISCORD_ALLOWED_USERS" "$(prompt_input_default "Discord allowed user IDs (optional)" "$existing")"
      existing="$(get_env_file_value "$config_file" "CTI_DISCORD_ALLOWED_CHANNELS")"
      upsert_env_file_value "$config_file" "CTI_DISCORD_ALLOWED_CHANNELS" "$(prompt_input_default "Discord allowed channel IDs (optional)" "$existing")"
      existing="$(get_env_file_value "$config_file" "CTI_DISCORD_ALLOWED_GUILDS")"
      upsert_env_file_value "$config_file" "CTI_DISCORD_ALLOWED_GUILDS" "$(prompt_input_default "Discord allowed guild IDs (optional)" "$existing")"
      ;;
    feishu)
      upsert_env_file_value "$config_file" "CTI_ENABLED_CHANNELS" "feishu"
      existing="$(get_env_file_value "$config_file" "CTI_FEISHU_APP_ID")"
      upsert_env_file_value "$config_file" "CTI_FEISHU_APP_ID" "$(prompt_secret_default "Feishu/Lark app ID" "$existing")"
      existing="$(get_env_file_value "$config_file" "CTI_FEISHU_APP_SECRET")"
      upsert_env_file_value "$config_file" "CTI_FEISHU_APP_SECRET" "$(prompt_secret_default "Feishu/Lark app secret" "$existing")"
      existing="$(get_env_file_value "$config_file" "CTI_FEISHU_DOMAIN")"
      if [[ -z "$existing" ]]; then
        existing="https://open.feishu.cn"
      fi
      upsert_env_file_value "$config_file" "CTI_FEISHU_DOMAIN" "$(prompt_input_default "Feishu/Lark domain" "$existing")"
      existing="$(get_env_file_value "$config_file" "CTI_FEISHU_ALLOWED_USERS")"
      upsert_env_file_value "$config_file" "CTI_FEISHU_ALLOWED_USERS" "$(prompt_input_default "Feishu/Lark allowed user IDs (optional)" "$existing")"
      ;;
    *)
      echo "Unsupported IM provider: $provider" >&2
      return 1
      ;;
  esac

  IM_PROVIDER="$provider"
}

run_bridge_doctor() {
  local platform="$1"
  local doctor_script output_file
  doctor_script="$(bridge_doctor_script "$platform")"
  output_file="$(bridge_runtime_home "$platform")/runtime/cccg-doctor.log"
  mkdir -p "$(dirname "$output_file")"

  if [[ -x "$doctor_script" || -f "$doctor_script" ]]; then
    bash "$doctor_script" | tee "$output_file"
  else
    echo "Bridge doctor script not found: $doctor_script"
    return 1
  fi
}

write_im_plan() {
  local workspace="$1"
  local platform="${2:-${PLATFORM:-unknown}}"
  cat >"$(state_dir "$workspace")/im-bridge-plan.md" <<EOF
# IM Bridge Plan

Bridge product: Claude-Codex-Gemini-to-IM
Repository: $IM_BRIDGE_REPO
Platform host: $platform
Skill dir: $(bridge_skill_dir "$platform")
Runtime home: $(bridge_runtime_home "$platform")
Provider: ${IM_PROVIDER:-pending}

Supported channels:

- Telegram
- Discord
- Feishu / Lark

This bridge is Tier 1 in this repository.
EOF
}

write_mcp_plan() {
  local workspace="$1"
  cat >"$(state_dir "$workspace")/mcp-plan.md" <<EOF
# MCP Catalog Plan

Review the curated catalog:
- $ROOT_DIR/catalogs/recommended-mcp-skills.md

MCP components are Tier 3 in this repository:

- recommended here
- self-managed by the user
- not lifecycle-managed by this installer

Track installed MCPs outside this repository's state file if the target platform uses its own package manager or config file.
EOF
}

write_skills_plan() {
  local workspace="$1"
  cat >"$(state_dir "$workspace")/skills-plan.md" <<EOF
# Skills Catalog Plan

Review the curated catalog:
- $ROOT_DIR/catalogs/recommended-mcp-skills.md

Skills are Tier 3 in this repository:

- recommended here
- self-managed by the user
- not lifecycle-managed by this installer

Track installed skills with the target platform's native installer.
EOF
}
