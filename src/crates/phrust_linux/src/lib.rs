//! Linux platform layer for Phrust.
//!
//! Provides Linux-specific (Wayland) windowing and integration used by the
//! Phrust physics engine's WebGPU frontend.

/// Adds two numbers together.
///
/// Placeholder from the crate template, kept until real platform code lands.
#[must_use]
pub const fn add(left: u64, right: u64) -> u64 {
    left + right
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }
}
