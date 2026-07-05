# ari-lsp Protocol Contract

## Purpose

This document records the protocol boundary for the initial split workspace.

A minimal JSON-RPC stdio loop scaffold exists in this repository. It reads
stdin until EOF, flushes stdout at EOF, and returns 0 for clean EOF. Empty
stdin, non-protocol stdin, incomplete framed stdin, and framed stdin without the
smoke method fields and request ids emit no protocol messages. The local
protocol smoke stream gets fixed-result initialize and shutdown responses after
the scaffold observes three complete Content-Length-framed messages containing
`method` string fields for `initialize`, `shutdown`, and `exit`, with
one-digit numeric `id` fields for the initialize and shutdown smoke requests.

## Current Status

- `src/main.ari` routes through placeholder server, config, JSON-RPC,
  protocol, and transport modules.
- The JSON-RPC loop currently reads stdin byte-by-byte until EOF and flushes
  stdout. While reading, it scans `Content-Length:` header prefixes, parses
  decimal length digits, detects the header/body separator, and consumes the
  declared body byte count.
- For the local protocol smoke stream only, three complete framed messages
  containing literal `method` string fields for `initialize`, `shutdown`, and
  `exit`, plus one-digit numeric `id` fields for the initialize and shutdown
  smoke requests, produce initialize and shutdown responses with fixed result
  payloads and copied one-digit ids; `exit` produces no response.
- No complete JSON-RPC framing or body parsing is implemented.
- General JSON-RPC request-id propagation is not implemented.
- No general Language Server Protocol method dispatch is implemented.
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

- Do not implement complete JSON-RPC framing or request parsing in this
  scaffold step.
- Do not claim general JSON-RPC message handling in this scaffold step.
- Do not claim parity with bundled `tools/lsp`.
- Do not claim replacement status for `ari-foundry/ari/tools/lsp`.
- Do not invent new Ari LSP methods or protocol extensions.
