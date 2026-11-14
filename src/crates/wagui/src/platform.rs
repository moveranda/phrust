#[cfg(any(target_os = "linux", target_os = "freebsd"))]
bitflags::bitflags! {
    /// The windowing modes a platform may start in or switch to.
    #[derive(Clone, Copy, Debug, PartialEq, Eq)]
    pub struct WindowingModes: u8 {
        /// Connected to a Wayland compositor.
        const WAYLAND = 1 << 0;
    }
}

#[expect(missing_docs)]
pub trait Platform: 'static {}
