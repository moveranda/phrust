# Phrust

[![CI](https://github.com/moveranda/phrust/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/moveranda/phrust/actions/workflows/ci.yml)
[![Release](https://github.com/moveranda/phrust/actions/workflows/release.yml/badge.svg)](https://github.com/moveranda/phrust/actions/workflows/release.yml)
[![CodeQL](https://github.com/moveranda/phrust/actions/workflows/codeql.yml/badge.svg?branch=main)](https://github.com/moveranda/phrust/actions/workflows/codeql.yml)
[![OSV Scanner](https://github.com/moveranda/phrust/actions/workflows/osv-scanner.yml/badge.svg?branch=main)](https://github.com/moveranda/phrust/actions/workflows/osv-scanner.yml)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/moveranda/phrust/badge)](https://scorecard.dev/viewer/?uri=github.com/moveranda/phrust)

[![Docs](https://img.shields.io/badge/docs-moveranda.github.io%2Fphrust-blue)](https://moveranda.github.io/phrust/)
[![Rust](https://img.shields.io/badge/rust-1.99.1-orange?logo=rust)](src/rust-toolchain.toml)
[![License: MIT OR Apache-2.0](https://img.shields.io/badge/license-MIT%20OR%20Apache--2.0-blue)](#license)

An experimental game and physics engine written in Rust, rendered with WebGPU.

Phrust is a learning project: the physics follows *University Physics with
Modern Physics* (Young & Freedman), and each topic is turned into engine code
with tests and runnable examples. The same code is meant to run natively and in
the browser (`wasm32-unknown-unknown`).

> **Status:** foundations. The workspace, tooling, CI, docs and Linux
> packaging are in place; engine code is next.

📖 **Documentation:** <https://moveranda.github.io/phrust/>

## Repository layout

| Folder                                      | What's inside                                          |
| :------------------------------------------ | :----------------------------------------------------- |
| [`src/`](src/README.md)                     | The Cargo workspace: engine crates and their tooling   |
| [`docs/`](docs/README.md)                   | The documentation site (Astro + Starlight)             |
| [`packaging/linux/`](packaging/linux/README.md) | Linux release packages: tarball, DEB, RPM, AppImage, Flatpak |
| [`.github/workflows/`](.github/workflows/)  | CI and release workflows                               |

Open `phrust.code-workspace` in VS Code for a multi-root workspace with the
recommended extensions and formatters.

## Quick start

You need [rustup](https://rustup.rs/); the toolchain is pinned in
`src/rust-toolchain.toml` and installs itself on first use. On Linux you also
need the Wayland client libraries and `pkg-config`.

```sh
git clone https://github.com/moveranda/phrust.git
cd phrust/src
cargo build
cargo test
```

See [Getting started](https://moveranda.github.io/phrust/guides/getting-started/)
for the pinned dev tools, and
[Development workflow](https://moveranda.github.io/phrust/guides/development/)
for the checks CI runs.

## Releases

Pushing a `v*` tag builds the Linux packages, publishes them as a GitHub
Release with checksums and build provenance, and deploys the docs.

```sh
git tag v0.1.0 && git push origin v0.1.0
```

## License

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or <https://www.apache.org/licenses/LICENSE-2.0>)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or <https://opensource.org/licenses/MIT>)

at your option.

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.
