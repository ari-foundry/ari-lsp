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
require_grep "return 0;" src/main.ari
require_no_grep "JSON-RPC" src/main.ari
require_no_grep "Language Server Protocol" src/main.ari

require_grep "No JSON-RPC implementation exists in this repository yet." docs/dev/protocol-contract.md
require_grep "Do not implement JSON-RPC in this scaffold step." docs/dev/split-plan.md
require_grep "Do not invoke bundled .tools/lsp. in this step." docs/dev/dependency-model.md
require_grep "scripts/check.sh" .github/workflows/check.yml
require_no_grep "scripts/build.sh" .github/workflows/check.yml
require_no_grep "ari --check" .github/workflows/check.yml
require_no_grep "npm " .github/workflows/check.yml
require_no_grep "cargo " .github/workflows/check.yml
require_no_grep "tools/lsp" scripts/build.sh
require_no_grep "tools/lsp" scripts/smoke.sh

printf '%s\n' "check.sh: repository checks passed"
