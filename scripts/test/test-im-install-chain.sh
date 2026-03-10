#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

tmp_root="$(new_tmp_root im-install-chain)"
home_dir="$tmp_root/home"
source_dir="$tmp_root/bridge-source"
fake_bin="$tmp_root/fake-bin"
npm_log="$tmp_root/npm.log"

mkdir -p "$home_dir" "$fake_bin"

cat >"$fake_bin/npm" <<EOF
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "\$*" >> "$npm_log"
case "\$1" in
  install)
    mkdir -p node_modules/@openai/codex-sdk
    ;;
  run)
    if [[ "\${2:-}" == "build" ]]; then
      mkdir -p dist
      printf 'export default {};\n' > dist/daemon.mjs
    fi
    ;;
  prune)
    ;;
esac
EOF
chmod +x "$fake_bin/npm"

git clone --depth 1 https://github.com/d-wwei/Claude-Codex-Gemini-to-IM "$source_dir" >/dev/null 2>&1

PATH="$fake_bin:$PATH" HOME="$home_dir" bash "$source_dir/scripts/install-host.sh" --host codex >"$tmp_root/install-chain.log" 2>&1

skill_root="$home_dir/.codex/skills/codex-to-im"

assert_dir_exists "$skill_root"
assert_file_exists "$skill_root/SKILL.md"
assert_file_exists "$skill_root/scripts/daemon.sh"
assert_file_exists "$skill_root/scripts/render-host-templates.mjs"
assert_file_exists "$skill_root/dist/daemon.mjs"
assert_dir_exists "$skill_root/node_modules/@openai/codex-sdk"
assert_contains "$npm_log" "install"
assert_contains "$npm_log" "run build"
assert_contains "$npm_log" "prune --production"
assert_contains "$tmp_root/install-chain.log" "Installing codex-to-im for codex..."
assert_contains "$tmp_root/install-chain.log" "Done. Command:"

echo "PASS: im install chain"
