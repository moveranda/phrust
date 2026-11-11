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

`cargo nextest`, `cargo deny`, `cargo typos`, `cargo machete` and `cargo mutants` are aliases defined in `src/.cargo/config.toml`. They run the pinned versions through `cargo-run-bin`. [`cargo-mutants`](https://mutants.rs/) is pinned as well, for mutation testing (`cargo mutants`).

## Lints

Lints are set once in `[workspace.lints]` in `src/Cargo.toml`, and each crate opts in with `[lints] workspace = true`.

- `unsafe_code` and `unsafe_op_in_unsafe_fn` are **denied**. Any future `unsafe` needs an explicit `allow` and a `// SAFETY:` comment (`undocumented_unsafe_blocks`).
- `missing_docs` warns, so every public item needs a doc comment.
- Selected pedantic Clippy lints are turned on, such as `std_instead_of_core`, `manual_let_else`, `doc_markdown` and pointer cast lints.
- `clippy.toml` limits functions to 120 lines and 8 arguments, and allows `unwrap`/`expect` in tests.

## Formatting

`rustfmt.toml` uses the 2024 style edition, Unix newlines, field-init and `?` shorthands, and `use_small_heuristics = "Max"`.

## Dependencies

`src/deny.toml` allows only crates licensed under MIT, Apache-2.0 or Unicode-3.0 (used by `unicode-ident`), denies yanked crates, wildcard versions and unknown registries or git sources, and warns on duplicate versions.

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

## Continuous integration

`.github/workflows/ci.yml` runs on every pull request, on pushes to `main` and in the merge queue:

- **Format, lint, licences:** typos, `cargo fmt`, Clippy for native and `wasm32-unknown-unknown`, `cargo doc` with warnings as errors, `cargo deny` and `cargo machete`.
- **Build and test:** builds the workspace and runs nextest and doc tests on Linux, Windows and macOS, on both x86_64 and aarch64.
- **Docs:** builds this site.
- **Mutation tests:** runs `cargo mutants` across the workspace and uploads the report.

### Security scanning and dependency updates

- `.github/workflows/codeql.yml` runs CodeQL on pull requests, pushes to `main` and weekly, for the Rust code, the docs site and the workflows. Findings appear under **Security → Code scanning**.
- `.github/workflows/osv-scanner.yml` checks `src/Cargo.lock` and `docs/pnpm-lock.yaml` against [osv.dev](https://osv.dev). On pull requests it fails only on vulnerabilities the change introduces.
- `.github/workflows/scorecard.yml` runs [OpenSSF Scorecard](https://scorecard.dev) weekly and on pushes to `main`, rating the repository's supply-chain practices.
- `.github/workflows/sonarqube.yml` runs [SonarQube Cloud](https://sonarcloud.io) on pull requests and `main`, with the Clippy report imported. Settings live in `sonar-project.properties`, and it needs the `SONAR_TOKEN` repository secret.
- `.github/dependabot.yml` checks Cargo crates, the docs' npm packages and GitHub Actions every Monday. All updates, including major versions and security fixes, are grouped into one pull request per ecosystem.

## Releases

`.github/workflows/release.yml` runs when a `v*` tag is pushed:

1. Builds the release binary on Ubuntu 24.04 for x86_64 and aarch64, and packages it as a tarball, DEB, RPM, AppImage and Flatpak.
2. Publishes a GitHub Release with those packages, an SPDX SBOM, a `SHA256SUMS` file and build provenance attestations. A tag with a suffix, such as `v0.2.0-rc.1`, becomes a pre-release.
3. Builds this site and deploys it to GitHub Pages at `https://moveranda.github.io/phrust/`, once the release is out.

```sh
git tag v0.1.0 && git push origin v0.1.0
```

Running the workflow by hand builds the packages and the site, but publishes nothing.

GitHub Pages must be set to deploy from **GitHub Actions** in the repository settings.

## Linux packaging

Everything about the Linux packages lives in `packaging/linux/`. `app.env` names what is packaged (the app id, the `phrust` command and the Cargo package whose binary ships), and `package.sh` builds every format from one staged tree. Each format has a small template next to it: `deb/control.in`, `rpm/package.spec.in`, `flatpak/manifest.yml.in` and `appimage/`. See `packaging/linux/README.md` for common changes and how to build the packages locally.

CI checks the packaging script with ShellCheck and validates the desktop entry and AppStream metainfo on every pull request.
