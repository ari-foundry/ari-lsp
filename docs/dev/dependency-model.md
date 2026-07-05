# ari-lsp Dependency Model

## Purpose

This document defines the initial dependency boundary for the standalone
`ari-lsp` split workspace.

This step does not implement compiler invocation, JSON-RPC handling, package
management, editor integration, or compatibility policy.

## Current Status

- `scripts/check.sh` is compiler-free.
- `scripts/build.sh` requires an explicit Ari compiler path or `ARI_COMPILER`.
- `scripts/smoke.sh` delegates to `scripts/build.sh` and runs only the minimal
  placeholder executable.
- No runtime dependency model for a real language server is implemented here.

## Ari Compiler Source Of Truth

The Ari compiler is owned by `ari-foundry/ari`.

This repository must not vendor, fork, download, or build the Ari compiler as a
side effect of lightweight checks.

Compiler, standard library, parser, semantic analysis, module resolution, and
toolchain bugs belong in `ari-foundry/ari`.

## Local Compiler Selection

The local build and smoke scripts accept:

- a positional compiler path, such as `scripts/build.sh /path/to/ari`
- `ARI_COMPILER` when no positional path is provided

The positional path takes precedence over `ARI_COMPILER`.

The scripts validate that the selected path exists and is executable. They do
not guess monorepo-relative paths and do not download a compiler.

## Future Server Dependencies

The current bundled LSP accepts Ari compiler and lint configuration options in
`ari-foundry/ari`. Future standalone behavior should be confirmed from that
reference before it is implemented or documented as a compatibility promise.

Likely future dependency topics include:

- explicit Ari compiler path selection
- include paths for module lookup
- lint config and rule override plumbing
- temporary files for unsaved editor buffers
- compiler identity recording for diagnostics and tests

Each topic needs tests before it becomes standalone behavior.

## Non-Goals

- Do not implement `--ari` parsing in this step.
- Do not invoke `ari --check` in this step.
- Do not invoke bundled `tools/lsp` in this step.
- Do not add compiler-backed CI in this step.
- Do not install package manager dependencies in this step.
- Do not claim compatibility with any Ari release in this step.
