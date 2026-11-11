---
title: Project structure
description: How the repository and the Cargo workspace are laid out.
---

```
phrust/
├── docs/                    # This site (Astro + Starlight)
├── src/                     # Cargo workspace root
│   ├── .cargo/config.toml   # Aliases for pinned tools
│   ├── Cargo.toml           # Workspace, shared lints, profiles, pinned tools
│   ├── clippy.toml
│   ├── deny.toml
│   ├── rust-toolchain.toml
│   ├── rustfmt.toml
│   └── crates/
│       └── phrust_linux/    # Linux (Wayland) platform layer
├── phrust.code-workspace    # VS Code multi-root workspace
├── LICENSE-APACHE
└── LICENSE-MIT
```

## Crates

| Crate          | Status      | Description |
| :------------- | :---------- | :---------- |
| `phrust_linux` | Placeholder | Linux and FreeBSD platform layer. Depends on `wayland-client` (optional). It contains only template code for now. |

New crates go under `src/crates/`. Each one is added to `members` and `[workspace.dependencies]` in `src/Cargo.toml`, takes its package metadata from the workspace (`version.workspace = true` and so on), and opts in to the workspace lints.

## Licence

Phrust is dual licensed under [MIT](https://github.com/moveranda/phrust/blob/main/LICENSE-MIT) or [Apache-2.0](https://github.com/moveranda/phrust/blob/main/LICENSE-APACHE), at your option (`license = "MIT OR Apache-2.0"`).
