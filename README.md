# ari-lsp

`ari-lsp` is the future standalone language-server workspace for the Ari
language.

This repository is an initial split scaffold. The current bundled LSP
implementation remains in `ari-foundry/ari` under `tools/lsp`, and that bundled
implementation remains the behavior reference until migration work is planned
and implemented.

## References

- Ari compiler/language project: https://github.com/ari-foundry/ari
- Current bundled LSP docs: https://github.com/ari-foundry/ari/tree/main/docs/lsp
- Current bundled LSP source: https://github.com/ari-foundry/ari/tree/main/tools/lsp
- Ari Foundry portal: https://ari-foundry.github.io

## Current Scope

This repository currently owns:

- split workspace documentation
- dependency and protocol boundary notes
- lightweight repository validation
- local build and smoke wrappers
- a minimal Ari entrypoint and source-level LSP module scaffold that returns 0

The repository does not yet own a working language server implementation.

## Current Capabilities

Run the compiler-free repository-shape check with:

```sh
scripts/check.sh
```

Build the minimal Ari entrypoint with an explicit Ari compiler path:

```sh
scripts/build.sh /path/to/ari
```

Run the local build plus zero-behavior smoke check with:

```sh
scripts/smoke.sh /path/to/ari
```

You may also set `ARI_COMPILER`; a positional compiler path takes precedence.

## Current Non-Goals

- No JSON-RPC request parsing or LSP method dispatch is implemented here yet.
- No Language Server Protocol request handling is implemented here yet.
- No diagnostics, document tracking, code actions, symbols, completion, hover,
  or editor integration are implemented here yet.
- No Ari compiler invocation contract is implemented here beyond the local
  build/smoke script compiler path.
- No compatibility matrix, stable release, install command, or replacement
  status is claimed.
- No code is copied from `ari-foundry/ari/tools/lsp`.

## Local Build Scaffold

`scripts/build.sh` compiles `src/main.ari` to `build/ari-lsp`. It validates that
the compiler path exists and is executable, creates `build/`, and does not
download or build the Ari compiler.

`scripts/smoke.sh` delegates to `scripts/build.sh`, then runs the resulting
`build/ari-lsp` executable with stdin from `/dev/null` and expects exit status
0 with no stdout or stderr. This checks only the current placeholder entrypoint
and JSON-RPC stdio loop scaffold.
