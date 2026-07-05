# ari-lsp Protocol Contract

## Purpose

This document records the protocol boundary for the initial split workspace.

No JSON-RPC implementation exists in this repository yet.

## Current Status

- `src/main.ari` routes through placeholder server, config, JSON-RPC,
  protocol, and transport modules that return 0 and do not read stdin or write
  stdout/stderr.
- No JSON-RPC framing is implemented.
- No Language Server Protocol methods are implemented.
- Protocol compatibility is not claimed by this scaffold.

## Reference Behavior

Current behavior remains in `ari-foundry/ari`:

- bundled docs: `docs/lsp/`
- bundled source: `tools/lsp/`

The bundled docs currently describe a diagnostic-first server that speaks
JSON-RPC over stdio, tracks opened document text, and delegates diagnostics to
shared tooling. That is reference context, not behavior implemented here.

Reference methods documented in `ari-foundry/ari` include:

- `initialize`
- `shutdown`
- `exit`
- `textDocument/didOpen`
- `textDocument/didChange`
- `textDocument/didSave`
- `textDocument/didClose`
- `textDocument/publishDiagnostics`
- `textDocument/diagnostic`
- `textDocument/codeAction`
- `textDocument/documentSymbol`
- `textDocument/documentHighlight`
- `textDocument/foldingRange`
- `textDocument/selectionRange`
- `workspace/symbol`
- `textDocument/hover`
- `textDocument/definition`
- `textDocument/completion`

## Future Contract Direction

When protocol behavior moves here, it should be added in small, testable steps:

- document message framing before implementation
- add compiler-free parser or model tests before wiring stdio
- preserve behavior only after checking the bundled reference
- record non-goals and unsupported methods explicitly
- avoid claiming protocol stability before compatibility tests exist

## Non-Goals

- Do not implement JSON-RPC in this scaffold step.
- Do not read stdin or write protocol messages in this scaffold step.
- Do not claim parity with bundled `tools/lsp`.
- Do not claim replacement status for `ari-foundry/ari/tools/lsp`.
- Do not invent new Ari LSP methods or protocol extensions.
