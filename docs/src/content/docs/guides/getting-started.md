---
title: Getting started
description: Set up a development environment and build Phrust.
---

## Prerequisites

- [rustup](https://rustup.rs/). The toolchain is pinned in `src/rust-toolchain.toml` (Rust 1.99.1 with `clippy`, `rustfmt` and the `wasm32-unknown-unknown` target), so rustup installs the right version for you.
- On Linux: the Wayland client development libraries (for example `libwayland-dev` on Debian and Ubuntu, `wayland-devel` on Fedora), plus `pkg-config`.
- For the docs site: Node.js and [pnpm](https://pnpm.io/).

## Clone and build

```sh
git clone https://github.com/moveranda/phrust.git
cd phrust/src
cargo build
```

All Rust commands are run from `src/`, which is the root of the Cargo workspace.

## Install the project tools

Dev tools such as nextest, cargo-deny and typos are pinned in `Cargo.toml` and run through [`cargo-run-bin`](https://github.com/dustinblackman/cargo-run-bin), so everyone uses the same versions as CI:

```sh
cargo install cargo-run-bin --version 1.7.5 --locked
cargo bin --install
```

Then run the tests:

```sh
cargo nextest run
```

## Run the docs locally

```sh
cd docs
pnpm install
pnpm dev
```

The site is served at `http://localhost:4321`.

## Editor setup

Open `phrust.code-workspace` in VS Code. It is a multi-root workspace (`docs`, `src` and the repo root), with format-on-save and per-language formatters. Install the recommended extensions when prompted, including rust-analyzer and Even Better TOML.
