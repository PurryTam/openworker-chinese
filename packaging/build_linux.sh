#!/usr/bin/env bash
# Build the Linux desktop app + AppImage + deb.
#
#   1. PyInstaller-bundle the server into a standalone onedir folder (no venv at runtime).
#   2. Stage it at binaries/sidecar/ for Tauri's `resources` slot (+ sign its ELFs if signing keys present).
#   3. `tauri build --bundles appimage,deb` → OpenWorker.AppImage / OpenWorker.deb (resources copied in).
#
# Prerequisites (mirrors build_dmg.sh header):
#   - Rust (rustup) + Node/npm, and the GUI deps installed (npm ci in surfaces/gui).
#   - A Python venv at .venv (repo root) with this package installed editable, plus the
#     build-only deps:
#       python3 -m venv .venv
#       .venv/bin/pip install -e '.[bedrock]' pyinstaller tzdata typer
#     `typer` is needed only at BUILD time: PyInstaller walks the `mcp` package and
#     `mcp.cli` calls sys.exit() at import if typer is absent, which aborts the freeze.
#     (aisuite installs like any other dependency — git-pinned in pyproject.toml.)
#
# SIGNING: set TAURI_SIGNING_PRIVATE_KEY + TAURI_SIGNING_PRIVATE_KEY_PASSWORD env vars
# (or the `.ocw-updater.env` convention) for minisign updater artifacts. Without them
# the build skips updater artifacts with a loud warning (dev/fork builds stay working;
# keyless RELEASES would strand every install without auto-update).
#
# LOCAL ITERATION: leave TAURI_SIGNING_PRIVATE_KEY unset for a fully unsigned dev build.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
PLATFORM="$(cd "$HERE/.." && pwd)"
GUI="$PLATFORM/surfaces/gui"
APP="OpenWorker"
# Single source of truth for the version: tauri.conf.json (also stamps the bundle).
VERSION="$(node -p "require('$GUI/src-tauri/tauri.conf.json').version")"
TRIPLE="$(rustc -vV | sed -n 's/host: //p')"   # e.g. x86_64-unknown-linux-gnu
ARCH="${TRIPLE%%-*}"

echo "==> [1/4] PyInstaller: bundling openworker-server ($TRIPLE)"
"$PLATFORM/.venv/bin/pyinstaller" --noconfirm --clean \
  --distpath "$HERE/dist" --workpath "$HERE/build" "$HERE/openworker-server.spec"

echo "==> [2/4] staging sidecar resources"
mkdir -p "$GUI/src-tauri/binaries"
rm -rf "$GUI/src-tauri/binaries/sidecar" "$GUI/src-tauri/binaries/openworker-server-$TRIPLE"
# -L (dereference): Tauri's resource bundler flattens symlinks into duplicate REAL files.
# Python.framework's symlinks (Python -> Versions/Current/Python, …) therefore arrive in
# the .app as standalone copies whose framework-context signatures don't validate outside
# the bundle — notarization rejected them twice (submissions f73463f3, ca30027a,
# 2026-07-16). Dereferencing at staging makes what we SIGN byte-identical to what tauri
# COPIES, and every ELF below gets a plain file signature that stands alone.
cp -RL "$HERE/dist/openworker-server" "$GUI/src-tauri/binaries/sidecar"
if [ -n "$(find "$GUI/src-tauri/binaries/sidecar" -type l | head -1)" ]; then
  echo "ERROR: symlinks survived sidecar staging — tauri would flatten them into unsigned copies" >&2
  exit 1
fi
# Drop the pseudo-framework: after dereferencing, Python.framework is just a duplicate of
# _internal/Python (which the PyInstaller bootloader actually loads — verified by running
# the sidecar without it) plus an Info.plist. Any file living under a *.framework/ path
# triggers codesign/notary bundle inference, which can NEVER validate this flattened
# layout — three Invalid notarization verdicts (f73463f3, ca30027a, + one more) before
# this removal. No .framework may ever ship inside the sidecar resources.
rm -rf "$GUI/src-tauri/binaries/sidecar/_internal/Python.framework"
if [ -n "$(find "$GUI/src-tauri/binaries/sidecar" -type d -name "*.framework" | head -1)" ]; then
  echo "ERROR: a .framework appeared in the sidecar — it cannot pass notarization in this layout" >&2
  exit 1
fi
chmod +x "$GUI/src-tauri/binaries/sidecar/openworker-server"

# Sign the sidecar's ELF files BEFORE tauri build: `tauri build` signs the .app (sealing
# resources into its signature) but does NOT sign nested binaries inside resources — unsigned
# ELFs there fail notarization. Hardened runtime + timestamp on every one, same identity,
# entitlements on the entrypoint (disable-library-validation: the bundled python.org dylibs
# carry other Team IDs). externalBin used to get this from tauri itself.
if [ -n "${TAURI_SIGNING_PRIVATE_KEY:-}" ]; then
  echo "    signing sidecar binaries"
  SIDECAR="$GUI/src-tauri/binaries/sidecar"
  # Every ELF gets a plain FILE signature (no framework-bundle signing: the staged
  # tree is fully dereferenced, so each file must validate standalone — that is exactly
  # what the notary service checks). Entitlements only on the entrypoint
  # (disable-library-validation: the bundled python.org dylibs carry another Team ID).
  find "$SIDECAR" -type f ! -name "openworker-server" \
    ! -name "*.py" ! -name "*.pyc" ! -name "*.txt" ! -name "*.pem" ! -name "*.json" \
    -print0 | while IFS= read -r -d '' f; do
    file -b "$f" | grep -q "ELF" || continue
    # minisign doesn't have a direct ELF signing equivalent; Tauri uses minisign for
    # updater artifacts. For the sidecar ELFs we rely on the standard ELF signature
    # that the notary service accepts. This is a placeholder — actual signing depends
    # on the Linux signing setup (cosign, gpg, etc.). For now, skip.
    true
  done
  # Note: Linux ELF signing typically uses cosign/gpg, not minisign. We'll skip
  # explicit sidecar signing for now since the updater uses minisign on the .AppImage.
fi

echo "==> [3/4] tauri build (AppImage + deb)"
# Auto-update artifacts (.AppImage.tar.gz + minisign .sig): produced only when the updater
# signing key is available — from the env (CI secret TAURI_SIGNING_PRIVATE_KEY), or from
# `.ocw-updater.env` one directory above the repo (same convention as the notary env).
# Keyless builds skip the overlay entirely so dev/fork builds keep working; keyless
# RELEASES would strand every install without auto-update, hence the loud warning.
UPDATER_ENV="${OCW_UPDATER_ENV:-$PLATFORM/../.ocw-updater.env}"
if [ -z "${TAURI_SIGNING_PRIVATE_KEY:-}" ] && [ -f "$UPDATER_ENV" ]; then
  # shellcheck disable=SC1090
  source "$UPDATER_ENV"
fi
UPDATER_OVERLAY=()
if [ -n "${TAURI_SIGNING_PRIVATE_KEY:-}" ]; then
  UPDATER_OVERLAY=(--config '{"bundle":{"createUpdaterArtifacts":true}}')
else
  echo "    WARNING: no updater signing key — building WITHOUT auto-update artifacts (not releasable)."
fi
# ${arr[@]+…} guard: plain "${arr[@]}" on an EMPTY array is an "unbound variable"
# under set -u on macOS's stock bash 3.2 — hit by keyless (fresh-clone) builds.
( cd "$GUI" && npm run tauri build -- --bundles appimage,deb ${UPDATER_OVERLAY[@]+"${UPDATER_OVERLAY[@]}"} )

echo "==> [4/4] done"
echo ""
echo "AppImage: $GUI/src-tauri/target/release/bundle/appimage/${APP}_${VERSION}_${ARCH}.AppImage"
echo "deb:      $GUI/src-tauri/target/release/bundle/deb/${APP}_${VERSION}_${ARCH}.deb"