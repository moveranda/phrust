# Linux packaging

`package.sh` turns one prebuilt release binary into the Linux downloads
attached to each GitHub Release:

| Format   | File                                   | Install with                                   |
| :------- | :------------------------------------- | :--------------------------------------------- |
| Tarball  | `phrust-<version>-linux-<arch>.tar.gz` | extract anywhere, run `usr/bin/phrust`          |
| DEB      | `phrust_<version>-1_<deb-arch>.deb`    | `sudo apt install ./phrust_*.deb`              |
| RPM      | `phrust-<version>-1.<arch>.rpm`        | `sudo dnf install ./phrust-*.rpm`              |
| AppImage | `phrust-<version>-<arch>.AppImage`     | `chmod +x phrust-*.AppImage`, then run it      |
| Flatpak  | `phrust-<version>-<arch>.flatpak`      | `flatpak install --user ./phrust-*.flatpak`    |

`<arch>` is `x86_64` or `aarch64`; DEB uses `amd64` or `arm64`.

## Layout

```
packaging/linux/
├── app.env                  # what is packaged: app id, command, Cargo package, summary
├── package.sh               # builds every format from one staged tree
├── io.github.moveranda.Phrust.desktop
├── io.github.moveranda.Phrust.metainfo.xml
├── io.github.moveranda.Phrust.svg
├── deb/control.in           # DEB metadata and runtime dependencies
├── rpm/package.spec.in      # RPM metadata and runtime dependencies
├── flatpak/manifest.yml.in  # Flatpak runtime and sandbox permissions
└── appimage/
    ├── AppRun.in            # AppImage entry point
    ├── tools.lock           # appimagetool and runtime, pinned by SHA-256
    └── RUNTIME_LICENSE      # licence of the bundled AppImage runtime
```

`package.sh` installs the binary, desktop entry, icon, metainfo and licences
into one staging tree laid out like `/usr`, then hands that same tree to each
format. Templates use `@APP_ID@`, `@APP_NAME@`, `@APP_SUMMARY@`, `@VERSION@`,
`@DEB_ARCH@` and `@STAGE@` placeholders, filled in by the script.

## Common changes

- **Ship a different binary:** change `CARGO_PACKAGE` in `app.env`.
- **New runtime library:** a library the binary links directly is found
  automatically by RPM; add it to `Depends` in `deb/control.in`. A library
  loaded at runtime (`dlopen`, like Wayland and Vulkan today) must be listed
  in both `deb/control.in` and `rpm/package.spec.in`.
- **New sandbox permission** (network, files, audio): add it to `finish-args`
  in `flatpak/manifest.yml.in`.
- **Update the AppImage tools:** replace the URL and SHA-256 in
  `appimage/tools.lock` (`sha256sum <file>` gives the hash).
- **New file in the package:** install it in `stage_tree` in `package.sh`,
  and list it under `%files` in `rpm/package.spec.in`.

## Run it locally

On Ubuntu 24.04 or newer (matching the release runners):

```sh
sudo apt install rpm flatpak flatpak-builder
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

source packaging/linux/app.env
(cd src && cargo build --release --locked -p "$CARGO_PACKAGE")
packaging/linux/package.sh "src/target/release/$CARGO_PACKAGE" v0.1.0 dist
```

Pass format names after the output folder to build only some of them, for
example `... dist deb rpm`.
