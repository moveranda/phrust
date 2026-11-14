mod platform;
#[cfg(feature = "wayland")]
mod wayland;

pub(crate) use platform::*;
#[cfg(feature = "wayland")]
pub(crate) use wayland::*;

use std::rc::Rc;

use wagui::WindowingModes;

/// Returns a platform that may switch among `allowed_modes`.
#[must_use]
pub fn current_platform(allowed_modes: WindowingModes) -> Rc<dyn wagui::Platform> {
    Rc::new(LinuxPlatform::new(allowed_modes))
}
