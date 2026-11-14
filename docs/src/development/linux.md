---
title: Building Phrust for Linux
description: "Guide to building Phrust for linux for development."
---

# Building Phrust for Linux

## Repository

Clone the [Phrust repository](https://github.com/moveranda/phrust).

## Dependencies

- Install [rustup](https://www.rust-lang.org/tools/install)
- Install the necessary system libraries from `scripts/linux`

## Building from source

Once the dependencies are installed, you can build Phrust using [Cargo](https://doc.rust-lang.org/cargo/).

For a debug build of the editor:

```sh
cargo run
```

And to run the tests:

```sh
cargo nextest run
```

## Wayland & X11

Currently, Phrust supports Wayland only.
