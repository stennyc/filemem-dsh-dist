# filemem-dsh (public build)

Cross-session file memory for the DSH agent: a Go data-plane daemon (persistent
memory pool, auto-injection, L1 handoff, the shared-memory faces) behind a thin
minified JS shell. This distribution is the **source-free public build** — the
daemon ships as a stripped native binary and the shell as minified modules.
Development source is not distributed.

## Requirements
- A DSH host (cordis bundle v0.2.2-rc.5 generation) with the `@deepseek-ai/dsh-*`
  packages installed in the profile workspace (the DSH host install provides them).
- Node >= 20 to run the shell; the daemon binary is native — no toolchain needed.

## Install
1. Download the tarball for your platform from the [latest release](https://github.com/stennyc/filemem-dsh-dist/releases/latest) (or run the bundled installer: `install.sh` / `install.ps1`).
2. Verify the checksum:
   ```sh
   sha256sum -c SHA256SUMS   # Windows: Get-FileHash, see install.ps1
   ```
3. Extract, then add the extracted directory as a file: dependency in your DSH
   profile's `package.json` and install:
   ```sh
   cd <your-dsh-profile-dir>
   pnpm add <path-to-extracted>/filemem-dsh-<version>
   ```
   The profile's `pnpm install` resolves the two public runtime deps
   (`@deepseek-ai/dsh-tools`, `@deepseek-ai/schemastery`) from the registry.
4. Restart the DSH host. The bundle patch row (`cordis.patch.yml`, shipped in
   the package) mounts the plugin: 14-face tool surface + L1 handoff + the
   settings panel. Store root defaults to `~/.dsh/filemem` (per-user isolated).

## Configure
All knobs are the volatile config fields restated in the package's
`cordis.patch.yml` (injected into the active profile row, patch-replaces-whole-config
semantics). The settings panel in the Web GUI's Plugins page edits the same
fields live (the mirror-into-decay.json knobs need no restart; the Go data
plane hot-reads them). `daemonPath` / `storePath` stay patch-row fields — point
`daemonPath` at `dist/filemem-go` inside the package if you move the install.

## Uninstall
`pnpm remove @stennyc/filemem-dsh` in the profile, then delete `~/.dsh/filemem`
if you also want the local memory pool gone.

## Security posture
- The daemon is a closed binary: verify the release checksums before use.
- The memory pool is local to your home; the central shared pool (PostgreSQL)
  is opt-in and off by default.
- The package carries no install scripts (`postinstall` etc.) — the host side
  executes nothing beyond the normal plugin load.
