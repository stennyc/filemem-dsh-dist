# Changelog

## 0.1.0 — 2026-11-27
- First public source-free build: stripped Go data-plane daemon + minified
  JS shell. No .go / .ts source ships in any artifact (the packaging step
  aborts on a single source-artifact leak in the archive listing).
- Targets: linux-x64, linux-arm64 (aarch64), darwin-x64, darwin-arm64
  (Apple Silicon), windows-x64.
- **rc1host variants** (the dsh-Go phone host, the 0.2.2-rc.1 DSH
  generation): `filemem-dsh-0.1.0-rc1host-{linux-arm64,linux-x64}` — the
  inject list drops the `llm` token (absent in the rc.1 generation; the
  .rc1probe audit), the LLM-dependent faces take their deterministic
  floors, and the data plane + guidance section run fully active. Verified
  on a real rc.1 host (the headless boot + the guidance contribution).
- **Self-contained builds**: the two runtime deps (dsh-tools, schemastery)
  are inlined into the bundle; a folder-copy / file:-link install needs no
  registry. The stale `schemastery@^0.2.2-rc.5` constraint (unresolvable
  on the public registry — the true root cause of the 2026-11-27 phone
  install failures) is gone.
- The daemon gained windows portability: the unix signal-0 pid probes and
  the cross-daemon flock pair moved to build-tagged primitives (the
  windows legs use OpenProcess / LockFileEx+UnlockFileEx).
- The host-generation install gate: `engines.dsh` (full: `>=0.2.2-rc.5`;
  rc1host: `>=0.2.2-rc.1`).
- Delivery: the dist repo's `releases` branch (fetch + checksum via
  install.sh / install.ps1; the rc1host variant selects
  `install.sh 0.1.0-rc1host`); the GitHub release page carries the same
  artifacts as a cosmetic extra.
