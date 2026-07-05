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

non_protocol_input="$tmp_dir/non-protocol-input"
non_protocol_stdout="$tmp_dir/non-protocol-stdout"
non_protocol_stderr="$tmp_dir/non-protocol-stderr"

printf '%s' 'not-json-rpc' > "$non_protocol_input"

printf '%s\n' "smoke.sh: running non-protocol stdin smoke"
set +e
"$binary" < "$non_protocol_input" > "$non_protocol_stdout" 2> "$non_protocol_stderr"
non_protocol_status=$?
set -e

[ "$non_protocol_status" -eq 0 ] || fail "expected non-protocol smoke exit status 0, got $non_protocol_status"
[ ! -s "$non_protocol_stdout" ] || fail "expected no stdout from non-protocol stdin smoke"
[ ! -s "$non_protocol_stderr" ] || fail "expected no stderr from non-protocol stdin smoke"

incomplete_frame_input="$tmp_dir/incomplete-frame-input"
incomplete_frame_stdout="$tmp_dir/incomplete-frame-stdout"
incomplete_frame_stderr="$tmp_dir/incomplete-frame-stderr"

{
  printf 'Content-Length: 58\r\n\r\n'
  printf '%s' '{"jsonrpc":"2.0"'
} > "$incomplete_frame_input"

printf '%s\n' "smoke.sh: running incomplete-frame stdin smoke"
set +e
"$binary" < "$incomplete_frame_input" > "$incomplete_frame_stdout" 2> "$incomplete_frame_stderr"
incomplete_frame_status=$?
set -e

[ "$incomplete_frame_status" -eq 0 ] || fail "expected incomplete-frame smoke exit status 0, got $incomplete_frame_status"
[ ! -s "$incomplete_frame_stdout" ] || fail "expected no stdout from incomplete-frame stdin smoke"
[ ! -s "$incomplete_frame_stderr" ] || fail "expected no stderr from incomplete-frame stdin smoke"

protocol_input="$tmp_dir/protocol-input"
protocol_stdout="$tmp_dir/protocol-stdout"
protocol_stderr="$tmp_dir/protocol-stderr"
protocol_expected="$tmp_dir/protocol-expected"

{
  printf 'Content-Length: 58\r\n\r\n'
  printf '%s' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}'
  printf 'Content-Length: 44\r\n\r\n'
  printf '%s' '{"jsonrpc":"2.0","id":2,"method":"shutdown"}'
  printf 'Content-Length: 33\r\n\r\n'
  printf '%s' '{"jsonrpc":"2.0","method":"exit"}'
} > "$protocol_input"

{
  printf 'Content-Length: 53\r\n\r\n'
  printf '%s' '{"jsonrpc":"2.0","id":1,"result":{"capabilities":{}}}'
  printf 'Content-Length: 38\r\n\r\n'
  printf '%s' '{"jsonrpc":"2.0","id":2,"result":null}'
} > "$protocol_expected"

printf '%s\n' "smoke.sh: running protocol smoke"
set +e
"$binary" < "$protocol_input" > "$protocol_stdout" 2> "$protocol_stderr"
protocol_status=$?
set -e

[ "$protocol_status" -eq 0 ] || fail "expected protocol smoke exit status 0, got $protocol_status"
[ ! -s "$protocol_stderr" ] || fail "expected no stderr from protocol smoke"
cmp -s "$protocol_expected" "$protocol_stdout" || fail "unexpected protocol smoke stdout"

printf '%s\n' "smoke.sh: smoke checks passed"
