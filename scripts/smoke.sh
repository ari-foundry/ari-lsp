#!/bin/sh

set -eu

fail() {
  printf '%s\n' "smoke.sh: $*" >&2
  exit 1
}

if [ "$#" -gt 1 ]; then
  fail "usage: scripts/smoke.sh [ARI_COMPILER_PATH] or set ARI_COMPILER"
fi

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
repo_root=$(CDPATH= cd "$script_dir/.." && pwd)

if [ "$#" -eq 1 ]; then
  "$script_dir/build.sh" "$1"
else
  "$script_dir/build.sh"
fi

binary="$repo_root/build/ari-lsp"
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/ari-lsp-smoke.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

if [ ! -x "$binary" ]; then
  fail "expected built ari-lsp binary to be executable: $binary"
fi

stdout_file="$tmp_dir/stdout"
stderr_file="$tmp_dir/stderr"

printf '%s\n' "smoke.sh: running $binary"
set +e
"$binary" < /dev/null > "$stdout_file" 2> "$stderr_file"
status=$?
set -e

[ "$status" -eq 0 ] || fail "expected exit status 0, got $status"
[ ! -s "$stdout_file" ] || fail "expected no stdout from minimal entrypoint"
[ ! -s "$stderr_file" ] || fail "expected no stderr from minimal entrypoint"

printf '%s\n' "smoke.sh: smoke checks passed"
