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
One-liner (fetches the matching platform tarball from the dist repo's
`releases` branch, verifies the checksum, extracts):

```sh
# unix (the installer lives on the dist repo main branch; it fetches the
# tarball + SHA256SUMS from the releases branch, verifies, extracts)
curl -fsSL https://raw.githubusercontent.com/stennyc/filemem-dsh-dist/main/install.sh | sh
```

```powershell
# windows
powershell -c "irm https://raw.githubusercontent.com/stennyc/filemem-dsh-dist/main/install.ps1 | iex"
```

Manual: download `filemem-dsh-<version>-<platform>.tar.gz` from
https://github.com/stennyc/filemem-dsh-dist/tree/releases and verify with the
branch's `SHA256SUMS`, then add the extracted directory as a file: dependency
in your DSH profile's `package.json` and install:

```sh
cd <your-dsh-profile-dir>
pnpm add <path-to-extracted>/filemem-dsh-<version>
```

The profile's `pnpm install` resolves the two public runtime deps
(`@deepseek-ai/dsh-tools`, `@deepseek-ai/schemastery`) from the registry.

Finally restart the DSH host. The bundle patch row (`cordis.patch.yml`,
shipped in the package) mounts the plugin: 14-face tool surface + L1 handoff
+ the settings panel. Store root defaults to `~/.dsh/filemem` (per-user
isolated).

## On a phone (dsh-Go, the 0.2.2-rc.1 host generation)

The phone engine ships the rc.1 DSH generation, which has no `llm` inject
token. Use the **rc1host** build (the `filemem-dsh-0.1.0-rc1host-*` tarballs
on this branch): it declares only the tokens rc.1 resolves, and every
LLM-dependent face (the L1 handoff summary, the L2 reclassify, the L4
rescore) takes its coded deterministic floor there. The data plane (the
14-face tool surface) and the guidance section are fully active — verified
on a real rc.1 host.

The builds are **self-contained**: the two runtime deps are inlined into
the bundle, so no registry resolution happens at install (the stale
`schemastery` constraint that broke registry installs is also fixed).

1. Fetch the tarball for your phone architecture (arm64 on common phones)
   and verify it against this branch's `SHA256SUMS`:
   ```sh
   curl -fL -O https://raw.githubusercontent.com/stennyc/filemem-dsh-dist/releases/filemem-dsh-0.1.0-rc1host-linux-arm64.tar.gz
   ```
2. Get the folder into the phone's built-in Linux environment (any of the
   three ways in the dsh-Go docs: the agent writes it, `curl`/`git clone`
   in the App's terminal, or copy to the phone's Downloads + enable
   "access phone files" then `cp -r`):
   ```sh
   tar -xzf filemem-dsh-0.1.0-rc1host-linux-arm64.tar.gz
   cp -r filemem-dsh-0.1.0-rc1host /root/.dsh/dsh-go/plugins/filemem-rc1
   ```
3. Install it into the App's web profile (takes effect without a restart):
   ```sh
   dsh plugin --profile web add /root/.dsh/dsh-go/plugins/filemem-rc1
   ```

Desktop hosts on the rc.5 generation: use the plain `filemem-dsh-0.1.0-*`
tarballs (the full LLM faces are active there).

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
