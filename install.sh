#!/bin/sh
# filemem-dsh public installer (unix): fetch the current platform tarball
# from the dist repo's releases branch, verify the checksum, extract. Then
# follow the README's install step in your DSH host (profile dir / the dsh-Go
# phone terminal).
#
# Usage: install.sh [version|variant]
#   (no arg)          the newest version, the variant auto-detected from the
#                    running DSH host generation: rc.1..rc.4 hosts (the dsh-Go
#                    phone engine) get the rc1host build; rc.5+ get the full
#                    build. A host without a `dsh` CLI on PATH gets the full
#                    build (the desktop default).
#   install.sh rc1host
#                    the newest version, the rc1host build forced (dsh-Go
#                    phone host, the 0.2.2-rc.1 generation)
#   install.sh 0.1.0  that exact version, the full build
#   install.sh 0.1.0-rc1host
#                    that exact version, the rc1host build
# Note: environments without curl (the dsh-Go proot userland) use
# install-node.mjs instead — see the README's phone section.
set -eu
BASE="https://raw.githubusercontent.com/stennyc/filemem-dsh-dist/releases"
ARG="${1:-}"
VARIANT=""
VER=""

case "$ARG" in
  rc1host) VARIANT="rc1host" ;;
  *)
    case "$ARG" in
      *-rc1host) VARIANT="rc1host" ; VER="${ARG%-rc1host}" ;;
      *) VER="$ARG" ;;
    esac
    ;;
esac

# auto-detect the host generation (the 2a explicit flag above wins over this).
if [ -z "$ARG" ] && command -v dsh >/dev/null 2>&1; then
  HOSTV=$(dsh --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+-rc\.[0-9]+' | head -1 || true)
  if [ -n "$HOSTV" ]; then
    RCNUM="${HOSTV##*.}"
    # an rc number below 5 = the rc.1-generation host (the dsh-Go phone
    # engine): the full build's `llm` inject token does not resolve there.
    if [ "$RCNUM" -lt 5 ]; then VARIANT="rc1host"; fi
  fi
fi

if [ -z "$VER" ]; then
  # the newest version on the branch (the full-build filenames; the rc1host
  # files pair with the same version line via the VARIANT marker).
  VER=$(curl -fsSL "$BASE/SHA256SUMS" | sed -n 's/.*filemem-dsh-\([0-9][0-9.]*\)\(-rc1host\)\?-\(linux-x64\|linux-arm64\|darwin-x64\|darwin-arm64\|windows-x64\)\.tar\.gz.*/\1/p' | sort -uV | tail -1)
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
if [ -n "$VARIANT" ]; then F="filemem-dsh-$VER-$VARIANT-$TARGET.tar.gz"; else F="filemem-dsh-$VER-$TARGET.tar.gz"; fi
echo "installing $F (variant: ${VARIANT:-full})"
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
DIR="filemem-dsh-$VER"
echo ""
echo "extracted: $(pwd)/$DIR"
if [ "$OS" = "linux" ] && [ -d /root/.dsh/dsh-go ]; then
  echo "dsh-Go phone host detected:"
  echo "  cp -r $DIR /root/.dsh/dsh-go/plugins/filemem-rc1"
  echo "  dsh plugin --profile <your-app-profile> add /root/.dsh/dsh-go/plugins/filemem-rc1"
  echo "  then kill the running engine process (the App supervisor relaunches it) — see the README's dsh-Go note"
else
  echo "next: cd <your-dsh-profile-dir> && pnpm add $(pwd)/$DIR   (see README.md)"
fi
