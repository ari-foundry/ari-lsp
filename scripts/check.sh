#!/bin/sh

set -eu

fail() {
  printf '%s\n' "check.sh: $*" >&2
  exit 1
}

require_file() {
  [ -f "$1" ] || fail "missing file: $1"
}

require_dir() {
  [ -d "$1" ] || fail "missing directory: $1"
}

require_grep() {
  grep -q -- "$1" "$2" || fail "missing expected text in $2: $1"
}

require_no_grep() {
  if grep -q -- "$1" "$2"; then
    fail "unexpected text in $2: $1"
  fi
}

require_file AGENTS.md
require_file README.md
require_file .gitignore
require_file docs/README.md
require_file docs/dev/split-plan.md
require_file docs/dev/dependency-model.md
require_file docs/dev/protocol-contract.md
require_file scripts/check.sh
require_file scripts/build.sh
require_file scripts/smoke.sh
require_file src/main.ari
require_file src/server.ari
require_file src/config.ari
require_file src/json_rpc.ari
require_file src/protocol.ari
require_file src/transport.ari
require_file .github/workflows/check.yml

require_dir docs/dev
require_dir scripts
require_dir src

[ -x scripts/check.sh ] || fail "scripts/check.sh is not executable"
[ -x scripts/build.sh ] || fail "scripts/build.sh is not executable"
[ -x scripts/smoke.sh ] || fail "scripts/smoke.sh is not executable"

src_readme=$(find src -name README.md -print -quit)
[ -z "$src_readme" ] || fail "source directory contains README.md: $src_readme"

non_ari_source=$(find src -type f ! -name '*.ari' -print -quit)
[ -z "$non_ari_source" ] || fail "source directory contains non-Ari file: $non_ari_source"

if grep -R -q -- "Metadata entry:" src; then
  fail "source directory contains generated metadata marker"
fi

require_grep "fn main() -> i64" src/main.ari
require_grep "mod server;" src/main.ari
require_grep "return server::run_placeholder_entry();" src/main.ari
require_grep "pub fn run_placeholder_entry() -> i64" src/server.ari
require_grep "pub fn default_exit_code() -> i64" src/config.ari
require_grep "pub fn run_stdio_loop() -> i64" src/json_rpc.ari
require_grep "std::io::stdin()" src/json_rpc.ari
require_grep "std::io::read_one<std::io::Stdin>" src/json_rpc.ari
require_grep "std::io::flush<std::io::Stdout>" src/json_rpc.ari
require_grep "write_protocol_smoke_responses" src/json_rpc.ari
require_grep "next_content_length_header_match_index" src/json_rpc.ari
require_grep "next_header_end_match_index" src/json_rpc.ari
require_grep "scan_content_length_header_start" src/json_rpc.ari
require_grep "scan_content_length_digit" src/json_rpc.ari
require_grep "scan_content_length_header_end" src/json_rpc.ari
require_grep "complete_frame_count >= 3" src/json_rpc.ari
require_grep "next_id_key_match_index" src/json_rpc.ari
require_grep "next_method_key_match_index" src/json_rpc.ari
require_grep "next_initialize_method_value_match_index" src/json_rpc.ari
require_grep "next_shutdown_method_value_match_index" src/json_rpc.ari
require_grep "next_exit_method_value_match_index" src/json_rpc.ari
require_grep "is_json_whitespace" src/json_rpc.ari
require_grep "saw_initialize_request && saw_shutdown_request && saw_exit_notification" src/json_rpc.ari
require_grep "initialize_request_id" src/json_rpc.ari
require_grep "shutdown_request_id" src/json_rpc.ari
require_grep "ScannedSmokeRequestId" src/json_rpc.ari
require_grep "finalize_scanned_smoke_request_id" src/json_rpc.ari
require_grep "ScannedSmokeMethodValue" src/json_rpc.ari
require_grep "finalize_scanned_smoke_method_value" src/json_rpc.ari
require_grep "SmokeMethodValueScanReset" src/json_rpc.ari
require_grep "reset_smoke_method_value_scan" src/json_rpc.ari
require_grep "SmokeMethodValueScanFinish" src/json_rpc.ari
require_grep "finish_smoke_method_value_scan" src/json_rpc.ari
require_grep "SmokeMethodColonWaitStart" src/json_rpc.ari
require_grep "start_smoke_method_colon_wait" src/json_rpc.ari
require_grep "SmokeMethodValueWaitStart" src/json_rpc.ari
require_grep "start_smoke_method_value_wait" src/json_rpc.ari
require_grep "SmokeMethodValueWaitFallback" src/json_rpc.ari
require_grep "fallback_smoke_method_value_wait" src/json_rpc.ari
require_grep "SmokeMethodValueScanFallback" src/json_rpc.ari
require_grep "fallback_smoke_method_value_scan" src/json_rpc.ari
require_grep "SmokeMethodValueScanStart" src/json_rpc.ari
require_grep "start_smoke_method_value_scan" src/json_rpc.ari
require_grep "SmokeMethodValueScanUpdate" src/json_rpc.ari
require_grep "scan_smoke_method_value_byte" src/json_rpc.ari
require_grep "SmokeRequestIdValueScanReset" src/json_rpc.ari
require_grep "reset_smoke_request_id_value_scan" src/json_rpc.ari
require_grep "SmokeRequestIdValueScanFinish" src/json_rpc.ari
require_grep "finish_smoke_request_id_value_scan" src/json_rpc.ari
require_grep "SmokeRequestIdValueScanStart" src/json_rpc.ari
require_grep "start_smoke_request_id_value_scan" src/json_rpc.ari
require_grep "SmokeRequestIdValueScanUpdate" src/json_rpc.ari
require_grep "scan_smoke_request_id_value_digit" src/json_rpc.ari
require_grep "SmokeRequestIdValueScanFallback" src/json_rpc.ari
require_grep "fallback_smoke_request_id_value_scan" src/json_rpc.ari
require_grep "SmokeRequestIdValueWaitStart" src/json_rpc.ari
require_grep "start_smoke_request_id_value_wait" src/json_rpc.ari
require_grep "SmokeRequestIdValueWaitFallback" src/json_rpc.ari
require_grep "fallback_smoke_request_id_value_wait" src/json_rpc.ari
require_grep "SmokeRequestIdColonWaitStart" src/json_rpc.ari
require_grep "start_smoke_request_id_colon_wait" src/json_rpc.ari
require_grep "finalize_body_end_smoke_request_id" src/json_rpc.ari
require_grep "complete_body_end_smoke_frame" src/json_rpc.ari
require_grep "JsonRpcFrameProgress" src/json_rpc.ari
require_grep "complete_json_rpc_frame" src/json_rpc.ari
require_grep "consume_json_rpc_body_byte" src/json_rpc.ari
require_grep "ContentLengthParseResult" src/json_rpc.ari
require_grep "finalize_content_length_parse" src/json_rpc.ari
require_grep "apply_content_length_parse_to_frame_progress" src/json_rpc.ari
require_grep "ParsedContentLengthHeaderState" src/json_rpc.ari
require_grep "apply_content_length_parse_to_header_state" src/json_rpc.ari
require_grep "CompletedSmokeFrame" src/json_rpc.ari
require_grep "complete_smoke_frame" src/json_rpc.ari
require_grep "SmokeFrameScanState" src/json_rpc.ari
require_grep "initial_smoke_frame_scan_state" src/json_rpc.ari
require_grep "ContentLengthHeaderScanState" src/json_rpc.ari
require_grep "initial_content_length_header_scan_state" src/json_rpc.ari
require_grep "SmokeProtocolState" src/json_rpc.ari
require_grep "initial_smoke_protocol_state" src/json_rpc.ari
require_grep "BodyEndSmokeFrameState" src/json_rpc.ari
require_grep "apply_completed_smoke_frame_to_body_end_state" src/json_rpc.ari
require_grep "apply_body_end_protocol_state" src/json_rpc.ari
require_grep "apply_body_end_frame_progress" src/json_rpc.ari
require_grep "BodyEndScanResetState" src/json_rpc.ari
require_grep "initial_body_end_scan_reset_state" src/json_rpc.ari
require_grep "apply_body_end_scan_reset_state" src/json_rpc.ari
require_grep "apply_body_end_header_scan_reset" src/json_rpc.ari
require_grep "apply_body_end_frame_scan_reset" src/json_rpc.ari
require_grep "apply_body_end_header_scan_fields" src/json_rpc.ari
require_grep "apply_body_end_frame_scan_fields" src/json_rpc.ari
require_grep "apply_completed_smoke_frame_to_protocol_state" src/json_rpc.ari
require_grep "frame_has_supported_smoke_request_id" src/json_rpc.ari
require_grep "is_supported_smoke_request_id" src/json_rpc.ari
require_grep "write_supported_smoke_request_id" src/json_rpc.ari
require_grep "body_end_request_id.present" src/json_rpc.ari
require_grep "let completed_frame = complete_body_end_smoke_frame" src/json_rpc.ari
require_grep "let applied_protocol_state = apply_body_end_protocol_state" src/json_rpc.ari
require_grep "let body_end_completed_progress = apply_body_end_frame_progress" src/json_rpc.ari
require_grep "let frame_end_header_scan = apply_body_end_header_scan_reset" src/json_rpc.ari
require_grep "let applied_body_end_header_scan = apply_body_end_header_scan_fields" src/json_rpc.ari
require_grep "let next_frame_scan = apply_body_end_frame_scan_reset" src/json_rpc.ari
require_grep "let applied_body_end_frame_scan = apply_body_end_frame_scan_fields" src/json_rpc.ari
require_grep "scanned_header_start.content_length_match" src/json_rpc.ari
require_grep "pending_content_length = digit_header_scan.pending_content_length" src/json_rpc.ari
require_grep "header_end_match = header_end_scan.header_end_match" src/json_rpc.ari
require_grep "parsed_header_state.header_scan" src/json_rpc.ari
require_grep "parsed_header_state.frame_progress" src/json_rpc.ari
require_grep "scanned_method_value.saw_initialize_method" src/json_rpc.ari
require_grep "reading_method_value = method_value_scan_finish.reading_method_value" src/json_rpc.ari
require_grep "waiting_method_colon = method_colon_wait_start.waiting_method_colon" src/json_rpc.ari
require_grep "waiting_method_value = method_value_wait_start.waiting_method_value" src/json_rpc.ari
require_grep "method_key_match = method_value_wait_fallback.method_key_match" src/json_rpc.ari
require_grep "method_key_match = method_value_scan_fallback.method_key_match" src/json_rpc.ari
require_grep "reading_method_value = method_value_scan_start.reading_method_value" src/json_rpc.ari
require_grep "shutdown_value_match = method_value_scan_update.shutdown_value_match" src/json_rpc.ari
require_grep "frame_request_id = request_id_value_scan_finish.request_id" src/json_rpc.ari
require_grep "reading_id_value = request_id_value_scan_finish.reading_id_value" src/json_rpc.ari
require_grep "id_value = request_id_value_scan_update.id_value" src/json_rpc.ari
require_grep "reading_id_value = request_id_value_scan_start.reading_id_value" src/json_rpc.ari
require_grep "id_key_match = request_id_value_scan_fallback.id_key_match" src/json_rpc.ari
require_grep "waiting_id_value = request_id_value_wait_start.waiting_id_value" src/json_rpc.ari
require_grep "id_key_match = request_id_value_wait_fallback.id_key_match" src/json_rpc.ari
require_grep "waiting_id_colon = request_id_colon_wait_start.waiting_id_colon" src/json_rpc.ari
require_grep "body_remaining = consumed_body_progress.body_remaining" src/json_rpc.ari
require_grep "body_remaining = parsed_frame_progress.body_remaining" src/json_rpc.ari
require_grep "Content-Length: 53" src/json_rpc.ari
require_grep "Content-Length: 38" src/json_rpc.ari
require_grep "pub fn initial_protocol_status() -> i64" src/protocol.ari
require_grep "pub fn initial_transport_status() -> i64" src/transport.ari
require_no_grep "JSON-RPC" src/main.ari
require_no_grep "Language Server Protocol" src/main.ari

require_grep "A minimal JSON-RPC stdio loop scaffold exists." docs/dev/protocol-contract.md
require_grep "Do not implement JSON-RPC request parsing" docs/dev/split-plan.md
require_grep "Do not invoke bundled .tools/lsp. in this step." docs/dev/dependency-model.md
require_grep "scripts/check.sh" .github/workflows/check.yml
require_no_grep "scripts/build.sh" .github/workflows/check.yml
require_no_grep "ari --check" .github/workflows/check.yml
require_no_grep "npm " .github/workflows/check.yml
require_no_grep "cargo " .github/workflows/check.yml
require_no_grep "tools/lsp" scripts/build.sh
require_no_grep "tools/lsp" scripts/smoke.sh
require_grep "< /dev/null" scripts/smoke.sh
require_grep "non-protocol stdin smoke" scripts/smoke.sh
require_grep "not-json-rpc" scripts/smoke.sh
require_grep "incomplete-frame stdin smoke" scripts/smoke.sh
require_grep "method-free framed stdin smoke" scripts/smoke.sh
require_grep "request-id-free framed stdin smoke" scripts/smoke.sh
require_grep "unsupported-id framed stdin smoke" scripts/smoke.sh
require_grep "string-id framed stdin smoke" scripts/smoke.sh
require_grep "protocol smoke" scripts/smoke.sh
require_grep "Content-Length: 66" scripts/smoke.sh
require_grep "Content-Length: 52" scripts/smoke.sh
require_grep "Content-Length: 63" scripts/smoke.sh
require_grep "Content-Length: 49" scripts/smoke.sh
require_grep "Content-Length: 62" scripts/smoke.sh
require_grep "Content-Length: 48" scripts/smoke.sh
require_grep '"id" : "abc"' scripts/smoke.sh
require_grep '"id" : 17' scripts/smoke.sh
require_grep '"id" : 18' scripts/smoke.sh
require_grep '"id" : 7' scripts/smoke.sh
require_grep '"id" : 8' scripts/smoke.sh
require_grep '"id":7' scripts/smoke.sh
require_grep '"id":8' scripts/smoke.sh
require_grep '"method" : "initialize"' scripts/smoke.sh
require_grep '"method" : "shutdown"' scripts/smoke.sh
require_grep '"method" : "exit"' scripts/smoke.sh

printf '%s\n' "check.sh: repository checks passed"
