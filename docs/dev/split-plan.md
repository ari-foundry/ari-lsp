# ari-lsp Split Plan

## Purpose

This document tracks the first standalone split step for `ari-lsp`.

It records repository boundaries and planned migration direction. It does not
move, replace, or copy the bundled `tools/lsp` implementation from
`ari-foundry/ari`.

## Current Status

- This repository is an initial split scaffold.
- `src/main.ari` is intentionally minimal and routes through placeholder
  server, config, JSON-RPC, protocol, and transport modules. The JSON-RPC
  scaffold reads stdin until EOF, returns 0 on clean EOF, and has a
  Content-Length frame-count plus method/id-field-gated fixed-result local
  initialize/shutdown/exit smoke response path.
- Local repository-shape validation exists through `scripts/check.sh`.
- Local compiler-backed build and smoke wrappers exist through
  `scripts/build.sh` and `scripts/smoke.sh`.
- JSON-RPC and Language Server Protocol handling are not implemented here yet.
- Current user-facing LSP behavior remains bundled in `ari-foundry/ari`.

## Ownership Direction

This repository should eventually own the standalone Ari LSP implementation,
focused LSP documentation, local validation scripts, and split-specific release
notes.

`ari-foundry/ari` remains the source of truth for:

- Ari language syntax
- compiler behavior
- standard library APIs
- compiler diagnostics
- current bundled `tools/lsp` behavior

## Smallest Useful Next Steps

Future pull requests should stay narrow. Good next steps include:

- adding source-only models for LSP configuration or process boundaries
- adding compiler-free tests for repository invariants
- documenting migration decisions confirmed from `ari-foundry/ari`
- adding build or smoke checks only when the Ari compiler path is explicit
- adding JSON-RPC framing/parser scaffolding after the stdio loop boundary is
  ready

## Non-Goals

- Do not implement JSON-RPC request parsing or LSP method dispatch in this
  scaffold step.
- Do not copy `tools/lsp` wholesale.
- Do not delete, move, or replace bundled `tools/lsp`.
- Do not claim stable release, compatibility, install, or replacement status.
- Do not invent Ari syntax, standard library APIs, or protocol behavior.
- Do not modify `ari-foundry/ari` or `ari-foundry/ari-foundry.github.io` from
  this repository.
