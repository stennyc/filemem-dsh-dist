# Changelog

## 0.1.0 — 2026-11-27
- First public source-free build: stripped Go data-plane daemon + minified
  JS shell. No .go / .ts source ships in any artifact (the packaging step
  aborts on a single source-artifact leak in the archive listing).
- Targets: linux-x64, linux-arm64 (aarch64), darwin-x64, darwin-arm64
  (Apple Silicon), windows-x64.
- The daemon gained windows portability: the unix signal-0 pid probes and
  the cross-daemon flock pair moved to build-tagged primitives (the
  windows legs use OpenProcess / LockFileEx+UnlockFileEx, same advisory
  semantics, fail-open posture unchanged).
- Delivery: the dist repo's `releases` branch (fetch + checksum via
  install.sh / install.ps1); the GitHub release page carries the same
  artifacts as a cosmetic extra.
