#!/usr/bin/env bash
# Package a prebuilt Linux binary as a tarball, DEB, RPM, AppImage and Flatpak.
#
# Usage: packaging/linux/package.sh <binary> <version> <output-dir> [format...]
#
#   binary      the release executable, e.g. src/target/release/hello_triangle
#   version     a SemVer tag such as v0.1.0 or v0.2.0-rc.1
#   output-dir  where the finished packages are written
#   format      any of: tarball deb rpm appimage flatpak (default: all of them)
#
# Run it on the architecture you are packaging for. What gets packaged (app id,
# command name, summary) is set in app.env next to this script; each format
# has its own folder with the template it fills in.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
# shellcheck source=SCRIPTDIR/app.env
source "$HERE/app.env"

ALL_FORMATS=(tarball deb rpm appimage flatpak)

main() {
  if [[ $# -lt 3 ]]; then
    sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
    exit 2
  fi
  BINARY="$(realpath "$1")"
  # VERSION names the files; PKG_VERSION goes inside the DEB and RPM metadata.
  VERSION="${2#v}"
  PKG_VERSION="$(package_version "$VERSION")"
  OUTPUT="$(mkdir -p "$3" && realpath "$3")"
  shift 3
  local formats=("$@")
  [[ ${#formats[@]} -gt 0 ]] || formats=("${ALL_FORMATS[@]}")

  # Exported because appimagetool reads it too.
  export ARCH
  ARCH="$(uname -m)"
  case "$ARCH" in
    x86_64)  DEB_ARCH=amd64 ;;
    aarch64) DEB_ARCH=arm64 ;;
    *) die "unsupported architecture: $ARCH" ;;
  esac
  [[ -x "$BINARY" ]] || die "not an executable: $BINARY"

  WORK="$(mktemp -d)"
  trap 'rm -rf "$WORK"' EXIT

  # Every format ships the same tree: STAGE is laid out like the
  # filesystem root, so the files land under $STAGE/usr.
  STAGE="$WORK/stage"
  stage_tree "$STAGE/usr"

  for format in "${formats[@]}"; do
    case "$format" in
      tarball|deb|rpm|appimage|flatpak) ;;
      *) die "unknown format: $format (expected: ${ALL_FORMATS[*]})" ;;
    esac
    echo "==> Building $format"
    "build_$format"
  done

  echo "==> Packages in $OUTPUT"
  ls -l "$OUTPUT"
}

# --- Shared steps -----------------------------------------------------------

# 0.2.0-rc.1 -> 0.2.0~rc.1: "~" sorts before the final release in both
# dpkg and rpm, so a release candidate upgrades cleanly to the release.
package_version() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?$ ]] \
    || die "expected a version such as v0.1.0 or v0.2.0-rc.1, got: $1"
  echo "${1/-/\~}"
}

stage_tree() {
  local usr="$1"
  install -Dm755 "$BINARY" "$usr/bin/$APP_NAME"
  install -Dm644 "$HERE/$APP_ID.desktop"      "$usr/share/applications/$APP_ID.desktop"
  install -Dm644 "$HERE/$APP_ID.svg"          "$usr/share/icons/hicolor/scalable/apps/$APP_ID.svg"
  install -Dm644 "$HERE/$APP_ID.metainfo.xml" "$usr/share/metainfo/$APP_ID.metainfo.xml"
  install -Dm644 -t "$usr/share/licenses/$APP_NAME" "$ROOT/LICENSE-MIT" "$ROOT/LICENSE-APACHE"
}

# Fill the @NAME@ placeholders of a template.
render() {
  sed -e "s|@APP_ID@|$APP_ID|g" \
      -e "s|@APP_NAME@|$APP_NAME|g" \
      -e "s|@APP_SUMMARY@|$APP_SUMMARY|g" \
      -e "s|@VERSION@|$PKG_VERSION|g" \
      -e "s|@DEB_ARCH@|$DEB_ARCH|g" \
      -e "s|@STAGE@|$STAGE|g" \
      "$1"
}

die() {
  echo "error: $*" >&2
  exit 1
}

# --- Formats ----------------------------------------------------------------

# Plain archive: extract anywhere and run usr/bin/phrust.
build_tarball() {
  local name="$APP_NAME-$VERSION-linux-$ARCH"
  tar -C "$STAGE" --owner=0 --group=0 \
      --transform "s|^\.|$name|" -czf "$OUTPUT/$name.tar.gz" .
}

build_deb() {
  local root="$WORK/deb"
  mkdir -p "$root/DEBIAN"
  cp -a "$STAGE/usr" "$root/usr"
  # dpkg does not accept comments in a binary package's control file.
  render "$HERE/deb/control.in" | grep -v '^#' > "$root/DEBIAN/control"
  dpkg-deb --root-owner-group --build "$root" "$OUTPUT/${APP_NAME}_$VERSION-1_$DEB_ARCH.deb"
}

build_rpm() {
  local top="$WORK/rpm"
  mkdir -p "$top"
  render "$HERE/rpm/package.spec.in" > "$top/$APP_NAME.spec"
  rpmbuild -bb --quiet --target "$ARCH" \
    --define "_topdir $top" \
    --define "_build_id_links none" \
    --define "debug_package %{nil}" \
    "$top/$APP_NAME.spec"
  cp "$top"/RPMS/*/*.rpm "$OUTPUT/$APP_NAME-$VERSION-1.$ARCH.rpm"
}

build_appimage() {
  local appdir="$WORK/AppDir"
  cp -a "$STAGE" "$appdir"
  # appimagetool expects the launcher, icon and desktop entry at the top level.
  render "$HERE/appimage/AppRun.in" > "$appdir/AppRun"
  chmod 755 "$appdir/AppRun"
  cp "$HERE/$APP_ID.desktop" "$HERE/$APP_ID.svg" "$appdir/"
  install -Dm644 "$HERE/appimage/RUNTIME_LICENSE" \
    "$appdir/usr/share/licenses/$APP_NAME/APPIMAGE_RUNTIME_LICENSE"

  local tool runtime
  tool="$(fetch_pinned "appimagetool-$ARCH")"
  runtime="$(fetch_pinned "runtime-$ARCH")"
  # Extract the tool rather than mount it, so no FUSE is needed on CI.
  (cd "$WORK" && "$tool" --appimage-extract >/dev/null)
  "$WORK/squashfs-root/AppRun" --runtime-file "$runtime" \
    "$appdir" "$OUTPUT/$APP_NAME-$VERSION-$ARCH.AppImage"
}

build_flatpak() {
  local dir="$WORK/flatpak"
  mkdir -p "$dir"
  render "$HERE/flatpak/manifest.yml.in" > "$dir/$APP_ID.yml"
  flatpak-builder --user --install-deps-from=flathub --disable-rofiles-fuse \
    --arch="$ARCH" --repo="$dir/repo" --force-clean "$dir/build" "$dir/$APP_ID.yml"
  flatpak build-bundle --arch="$ARCH" \
    --runtime-repo=https://dl.flathub.org/repo/flathub.flatpakrepo \
    "$dir/repo" "$OUTPUT/$APP_NAME-$VERSION-$ARCH.flatpak" "$APP_ID"
}

# Download a tool listed in appimage/tools.lock and check its SHA-256.
fetch_pinned() {
  local name="$1" sha url
  read -r sha url < <(awk -v n="$name" '$1 == n { print $2, $3 }' "$HERE/appimage/tools.lock")
  [[ -n "${url:-}" ]] || die "$name is not listed in appimage/tools.lock"
  curl --fail --location --silent --show-error --retry 3 -o "$WORK/$name" "$url"
  echo "$sha  $WORK/$name" | sha256sum --check --quiet - >&2 || die "checksum mismatch for $name"
  chmod 755 "$WORK/$name"
  echo "$WORK/$name"
}

main "$@"
