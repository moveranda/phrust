//! Linux backend for wagui: Wayland now, maybe X11 later.
//!
//! Compiles to an empty crate on other OSes.
#![cfg(any(target_os = "linux", target_os = "freebsd"))]

mod linux;

pub use linux::current_platform;
