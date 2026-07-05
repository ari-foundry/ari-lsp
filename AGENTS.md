# ari-lsp Agent Guide

## Repository Role

This repository owns the future standalone `ari-lsp` split workspace only.

Ari language syntax, compiler behavior, standard library APIs, and current
tooling behavior remain owned by `ari-foundry/ari`.

The current `tools/lsp` implementation in `ari-foundry/ari` is the bundled
reference implementation for behavior and protocol notes. Do not copy it
wholesale into this repository.

Ari language syntax and idioms must be checked against `ari-foundry/ari` docs,
examples, and tests before adding Ari source beyond the minimal scaffold.

Do not invent Ari syntax. Do not add Ari examples unless they are verified
against current Ari usage.

Broad Ari language, compiler, standard library, lint, editor, or package
manager docs must not be copied here. Keep docs focused on the `ari-lsp` split,
dependency boundaries, protocol contracts, local validation, and future LSP
implementation work.

## Current Split Status

- This repository is an initial standalone split scaffold.
- Ari-language implementation source is limited to a minimal `src/main.ari`
  entrypoint plus placeholder server, config, JSON-RPC, protocol, and transport
  modules that return 0.
- JSON-RPC request parsing and general Language Server Protocol handling are
  not implemented here yet. A minimal stdin EOF loop and Content-Length
  frame-count plus method/id-field-gated fixed protocol smoke response
  scaffold exist.
- Local build and smoke scripts require an explicit Ari compiler path.
- Compiler-free repository-shape validation is available through
  `scripts/check.sh`.

## Boundaries

Do not modify `ari-foundry/ari` from this repository.

Do not delete, move, or replace `tools/lsp` in `ari-foundry/ari`.

Do not modify `ari-foundry/ari-foundry.github.io` from this repository.

Do not invent compatibility claims before releases exist.

Before making compatibility or release claims, check Ari releases and tags as
read-only references:

- https://github.com/ari-foundry/ari/releases
- https://github.com/ari-foundry/ari/tags

Compatibility claims must not be invented. The `ari-lsp` release/version policy
is not established yet.

Do not copy broad Ari language, compiler, standard library, lint, editor, or
package-manager docs into this repository.

## Issue Routing

Compiler bugs belong in `ari-foundry/ari` issues.

Standard library bugs belong in `ari-foundry/ari` issues.

Ari language/toolchain limitations belong in `ari-foundry/ari` issues.

Bundled `tools/lsp` bugs belong in `ari-foundry/ari` until ownership moves.

`ari-lsp` issues are for split workspace docs, standalone validation,
repository wiring, future Ari-language LSP implementation, protocol contracts,
and split-specific migration work.

If a bug crosses the boundary, file the root cause in `ari-foundry/ari` and
link it from `ari-lsp` if needed.

## Workflow

Keep pull requests small and scoped.

Run the available validation before creating a pull request.

Before changing split-related content, read the relevant Ari reference docs and
the focused local notes:

- `docs/dev/split-plan.md`
- `docs/dev/dependency-model.md`
- `docs/dev/protocol-contract.md`

Before adding protocol behavior, inspect the current bundled `ari-foundry/ari`
LSP docs and `tools/lsp` behavior as read-only references.
