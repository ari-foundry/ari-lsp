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
require_grep "complete_frame_count >= 3" src/json_rpc.ari
require_grep "next_method_key_match_index" src/json_rpc.ari
require_grep "next_initialize_method_value_match_index" src/json_rpc.ari
require_grep "next_shutdown_method_value_match_index" src/json_rpc.ari
require_grep "next_exit_method_value_match_index" src/json_rpc.ari
require_grep "is_json_whitespace" src/json_rpc.ari
require_grep "saw_initialize_method && saw_shutdown_method && saw_exit_method" src/json_rpc.ari
require_grep "body_remaining = pending_content_length" src/json_rpc.ari
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
require_grep "protocol smoke" scripts/smoke.sh
require_grep "Content-Length: 60" scripts/smoke.sh
require_grep '"method" : "initialize"' scripts/smoke.sh
require_grep '"method" : "shutdown"' scripts/smoke.sh
require_grep '"method" : "exit"' scripts/smoke.sh

printf '%s\n' "check.sh: repository checks passed"
