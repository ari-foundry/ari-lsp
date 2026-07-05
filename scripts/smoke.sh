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

method_free_input="$tmp_dir/method-free-input"
method_free_stdout="$tmp_dir/method-free-stdout"
method_free_stderr="$tmp_dir/method-free-stderr"

{
  printf 'Content-Length: 2\r\n\r\n{}'
  printf 'Content-Length: 2\r\n\r\n{}'
  printf 'Content-Length: 2\r\n\r\n{}'
} > "$method_free_input"

printf '%s\n' "smoke.sh: running method-free framed stdin smoke"
set +e
"$binary" < "$method_free_input" > "$method_free_stdout" 2> "$method_free_stderr"
method_free_status=$?
set -e

[ "$method_free_status" -eq 0 ] || fail "expected method-free framed smoke exit status 0, got $method_free_status"
[ ! -s "$method_free_stdout" ] || fail "expected no stdout from method-free framed stdin smoke"
[ ! -s "$method_free_stderr" ] || fail "expected no stderr from method-free framed stdin smoke"

request_id_free_input="$tmp_dir/request-id-free-input"
request_id_free_stdout="$tmp_dir/request-id-free-stdout"
request_id_free_stderr="$tmp_dir/request-id-free-stderr"

{
  printf 'Content-Length: 53\r\n\r\n'
  printf '%s' '{"jsonrpc":"2.0","method" : "initialize","params":{}}'
  printf 'Content-Length: 39\r\n\r\n'
  printf '%s' '{"jsonrpc":"2.0","method" : "shutdown"}'
  printf 'Content-Length: 35\r\n\r\n'
  printf '%s' '{"jsonrpc":"2.0","method" : "exit"}'
} > "$request_id_free_input"

printf '%s\n' "smoke.sh: running request-id-free framed stdin smoke"
set +e
"$binary" < "$request_id_free_input" > "$request_id_free_stdout" 2> "$request_id_free_stderr"
request_id_free_status=$?
set -e

[ "$request_id_free_status" -eq 0 ] || fail "expected request-id-free framed smoke exit status 0, got $request_id_free_status"
[ ! -s "$request_id_free_stdout" ] || fail "expected no stdout from request-id-free framed stdin smoke"
[ ! -s "$request_id_free_stderr" ] || fail "expected no stderr from request-id-free framed stdin smoke"

unsupported_id_input="$tmp_dir/unsupported-id-input"
unsupported_id_stdout="$tmp_dir/unsupported-id-stdout"
unsupported_id_stderr="$tmp_dir/unsupported-id-stderr"

{
  printf 'Content-Length: 63\r\n\r\n'
  printf '%s' '{"jsonrpc":"2.0","id" : 17,"method" : "initialize","params":{}}'
  printf 'Content-Length: 49\r\n\r\n'
  printf '%s' '{"jsonrpc":"2.0","id" : 18,"method" : "shutdown"}'
  printf 'Content-Length: 35\r\n\r\n'
  printf '%s' '{"jsonrpc":"2.0","method" : "exit"}'
} > "$unsupported_id_input"

printf '%s\n' "smoke.sh: running unsupported-id framed stdin smoke"
set +e
"$binary" < "$unsupported_id_input" > "$unsupported_id_stdout" 2> "$unsupported_id_stderr"
unsupported_id_status=$?
set -e

[ "$unsupported_id_status" -eq 0 ] || fail "expected unsupported-id framed smoke exit status 0, got $unsupported_id_status"
[ ! -s "$unsupported_id_stdout" ] || fail "expected no stdout from unsupported-id framed stdin smoke"
[ ! -s "$unsupported_id_stderr" ] || fail "expected no stderr from unsupported-id framed stdin smoke"

protocol_input="$tmp_dir/protocol-input"
protocol_stdout="$tmp_dir/protocol-stdout"
protocol_stderr="$tmp_dir/protocol-stderr"
protocol_expected="$tmp_dir/protocol-expected"

{
  printf 'Content-Length: 62\r\n\r\n'
  printf '%s' '{"jsonrpc":"2.0","id" : 7,"method" : "initialize","params":{}}'
  printf 'Content-Length: 48\r\n\r\n'
  printf '%s' '{"jsonrpc":"2.0","id" : 8,"method" : "shutdown"}'
  printf 'Content-Length: 35\r\n\r\n'
  printf '%s' '{"jsonrpc":"2.0","method" : "exit"}'
} > "$protocol_input"

{
  printf 'Content-Length: 53\r\n\r\n'
  printf '%s' '{"jsonrpc":"2.0","id":7,"result":{"capabilities":{}}}'
  printf 'Content-Length: 38\r\n\r\n'
  printf '%s' '{"jsonrpc":"2.0","id":8,"result":null}'
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
