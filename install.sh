#!/bin/sh
# filemem-dsh public installer (unix): fetch the current platform tarball from
# the dist repo's releases branch, verify the checksum, extract. Then follow
# the README's pnpm step in your DSH profile directory.
# Usage: install.sh [version]   (default: the newest version on the branch)
set -eu
BASE="https://raw.githubusercontent.com/stennyc/filemem-dsh-dist/releases"
VER="${1:-}"
if [ -z "$VER" ]; then
  VER=$(curl -fsSL "$BASE/SHA256SUMS" | sed -n 's/.*filemem-dsh-\([0-9.]*\)-\(linux-x64\|linux-arm64\|darwin-x64\|darwin-arm64\|windows-x64\)\.tar\.gz.*/\1/p' | sort -uV | tail -1)
fi
[ -n "$VER" ] || { echo "no version found on the releases branch"; exit 1; }
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$OS-$ARCH" in
  linux-x86_64|linux-amd64) TARGET="linux-x64" ;;
  linux-arm64|linux-aarch64) TARGET="linux-arm64" ;;
  darwin-arm64) TARGET="darwin-arm64" ;;
  darwin-x86_64) TARGET="darwin-x64" ;;
  *) echo "unsupported platform: $OS-$ARCH (the releases branch ships: linux-x64, linux-arm64, darwin-x64, darwin-arm64, windows-x64)"; exit 1 ;;
esac
F="filemem-dsh-$VER-$TARGET.tar.gz"
curl -fL -o "$F" "$BASE/$F"
curl -fL -o SHA256SUMS "$BASE/SHA256SUMS"
if command -v sha256sum >/dev/null; then
  grep " $F$" SHA256SUMS | sha256sum -c -
else
  WANT=$(grep " $F$" SHA256SUMS | cut -d' ' -f1)
  GOT=$(shasum -a 256 "$F" | cut -d' ' -f1)
  [ "$WANT" = "$GOT" ] || { echo "CHECKSUM MISMATCH for $F"; exit 1; }
  echo "$F: checksum ok"
fi
tar -xzf "$F"
rm -f "$F" SHA256SUMS
echo ""
echo "extracted: $(pwd)/filemem-dsh-$VER"
echo "next: cd <your-dsh-profile-dir> && pnpm add $(pwd)/filemem-dsh-$VER   (see README.md)"
