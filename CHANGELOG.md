# Changelog

## 0.1.0 — 2026-11-27
- First public source-free build: stripped Go data-plane daemon
  (linux/darwin/windows x64, linux arm64, darwin arm64) + minified JS shell.
- Source-leak guard in the packaging pipeline (the archive listing must not
  contain a single .go / .ts / dev-toolchain entry).
