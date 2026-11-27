#!/bin/sh
# filemem-dsh public installer (unix): download the matching platform tarball
# from the latest release, verify the checksum, extract. Then follow the
# README's pnpm step in your DSH profile directory.
set -eu
API="https://api.github.com"
REPO="stennyc/filemem-dsh-dist"
VER=$(curl -fsSL "$API/repos/$REPO/releases/latest" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')
[ -n "$VER" ] || { echo "latest release not found"; exit 1; }
VER_NUM=${VER#v}
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$OS-$ARCH" in
  linux-x86_64|linux-amd64) TARGET="linux-x64" ;;
  linux-arm64|linux-aarch64) TARGET="linux-arm64" ;;
  darwin-arm64) TARGET="darwin-arm64" ;;
  darwin-x86_64) TARGET="darwin-x64" ;;
  *) echo "unsupported platform: $OS-$ARCH (build the dev source for your platform)"; exit 1 ;;
esac
F="filemem-dsh-$VER_NUM-$TARGET.tar.gz"
curl -fL -o "$F" "$API/repos/$REPO/releases/latest/download/$F"
curl -fL -o SHA256SUMS "$API/repos/$REPO/releases/latest/download/SHA256SUMS"
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
echo "extracted: $(pwd)/filemem-dsh-$VER_NUM"
echo "next: cd <your-dsh-profile-dir> && pnpm add $(pwd)/filemem-dsh-$VER_NUM   (see README.md)"
