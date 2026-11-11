---
title: Development workflow
description: Checks to run before pushing, and the conventions they enforce.
---

Run these from `src/` before pushing:

```sh
cargo fmt --check                # formatting (rustfmt.toml)
cargo clippy --all-targets       # lints (workspace lints + clippy.toml)
cargo nextest run                # tests
cargo deny check                 # licences, advisories, banned sources
cargo typos                      # spelling
cargo machete                    # unused dependencies
```

`cargo nextest`, `cargo deny`, `cargo typos` and `cargo machete` are aliases defined in `src/.cargo/config.toml`. They run the pinned versions through `cargo-run-bin`. [`cargo-mutants`](https://mutants.rs/) is pinned as well, for mutation testing (`cargo bin cargo-mutants`).

## Lints

Lints are set once in `[workspace.lints]` in `src/Cargo.toml`, and each crate opts in with `[lints] workspace = true`.

- `unsafe_code` and `unsafe_op_in_unsafe_fn` are **denied**. Any future `unsafe` needs an explicit `allow` and a `// SAFETY:` comment (`undocumented_unsafe_blocks`).
- `missing_docs` warns, so every public item needs a doc comment.
- Selected pedantic Clippy lints are turned on, such as `std_instead_of_core`, `manual_let_else`, `doc_markdown` and pointer cast lints.
- `clippy.toml` limits functions to 120 lines and 8 arguments, and allows `unwrap`/`expect` in tests.

## Formatting

`rustfmt.toml` uses the 2024 style edition, Unix newlines, field-init and `?` shorthands, and `use_small_heuristics = "Max"`.

## Dependencies

`src/deny.toml` allows only crates licensed under MIT or Apache-2.0, denies yanked crates, wildcard versions and unknown registries or git sources, and warns on duplicate versions.

## Build profiles

| Profile       | Purpose                                                                 |
| :------------ | :---------------------------------------------------------------------- |
| `dev`         | Our crates unoptimised for fast rebuilds. Dependencies at `opt-level = 2`, because GPU setup is slow unoptimised. |
| `release`     | Thin LTO, one codegen unit, stripped symbols.                            |
| `web-release` | Based on `release`, with `opt-level = "s"` and `panic = "abort"` for small wasm. Symbols are kept for wasm-bindgen. |

Build for the browser with:

```sh
cargo build --profile web-release --target wasm32-unknown-unknown
```
