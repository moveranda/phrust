# Phrust workspace

The Cargo workspace for Phrust. Run every Rust command from this folder.

## Crates

| Crate                                 | Description                                         |
| :------------------------------------ | :-------------------------------------------------- |
| [`phrust_linux`](crates/phrust_linux) | Linux (Wayland) platform layer. Placeholder for now. |

New crates go under `crates/`. Add each one to `members` and
`[workspace.dependencies]` in `Cargo.toml`, inherit the package metadata
(`version.workspace = true` and so on), and opt in to the shared lints with
`[lints] workspace = true`. Shared third-party versions live in
`[workspace.dependencies]` too.

## Build and test

```sh
cargo build
cargo test
cargo build --profile web-release --target wasm32-unknown-unknown   # browser build
```

## Project tools

Dev tools are pinned in `[workspace.metadata.bin]` and run through
[`cargo-run-bin`](https://github.com/dustinblackman/cargo-run-bin), so you use
the same versions as CI. Install them once:

```sh
cargo install cargo-run-bin --version 1.7.5 --locked
cargo bin --install
```

Then, before pushing:

```sh
cargo fmt --check
cargo clippy --all-targets --all-features -- -D warnings
cargo nextest run
cargo deny check      # licences, advisories, sources
cargo typos ..        # spelling, whole repository
cargo machete         # unused dependencies
cargo mutants         # mutation testing
```

The aliases are defined in `.cargo/config.toml`.

## Configuration files

| File                  | Purpose                                                               |
| :-------------------- | :-------------------------------------------------------------------- |
| `Cargo.toml`          | Workspace members, shared dependencies, lints, build profiles, pinned tools |
| `rust-toolchain.toml` | Pinned Rust version, components and the `wasm32-unknown-unknown` target |
| `rustfmt.toml`        | Formatting rules (2024 style edition)                                  |
| `clippy.toml`         | Clippy thresholds and allowed doc identifiers                          |
| `deny.toml`           | Allowed licences and dependency sources for `cargo deny`               |
| `.cargo/config.toml`  | Aliases for the pinned tools                                           |

## Lints

`unsafe_code` is denied workspace-wide, and `missing_docs` warns, so every
public item needs a doc comment. CI runs Clippy with `-D warnings` on native and
`wasm32-unknown-unknown`. See
[Development workflow](https://moveranda.github.io/phrust/guides/development/)
for the full list.
