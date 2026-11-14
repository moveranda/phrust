use wagui::{Platform, WindowingModes};

/// Wagui's platform for Linux and FreeBSD.
pub(crate) struct LinuxPlatform {
    allowed_modes: WindowingModes,
}

impl LinuxPlatform {
    /// Creates the platform with the given `allowed_modes`.
    pub(crate) fn new(allowed_modes: WindowingModes) -> Self {
        Self { allowed_modes }
    }
}

impl Platform for LinuxPlatform {}
