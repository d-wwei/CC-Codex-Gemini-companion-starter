#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEST_TMP_ROOT="${TEST_TMP_ROOT:-/tmp/cccg-smoke}"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file_exists() {
  local path="$1"
  [[ -f "$path" ]] || fail "Expected file to exist: $path"
}

assert_dir_exists() {
  local path="$1"
  [[ -d "$path" ]] || fail "Expected directory to exist: $path"
}

assert_contains() {
  local path="$1"
  local pattern="$2"
  rg -n --fixed-strings "$pattern" "$path" >/dev/null || fail "Expected '$pattern' in $path"
}

assert_output_contains() {
  local output="$1"
  local pattern="$2"
  printf '%s' "$output" | rg -n --fixed-strings "$pattern" >/dev/null || fail "Expected output to contain: $pattern"
}

new_tmp_root() {
  local name="$1"
  local dir="$TEST_TMP_ROOT/$name"
  rm -rf "$dir"
  mkdir -p "$dir"
  printf '%s' "$dir"
}

run_cmd() {
  local log_file="$1"
  shift
  "$@" >"$log_file" 2>&1
}
