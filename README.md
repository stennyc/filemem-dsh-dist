# filemem-dsh (public build)

Cross-session file memory for the DSH agent: a Go data-plane daemon (persistent
memory pool, auto-injection, L1 handoff, the shared-memory faces) behind a thin
minified JS shell. This distribution is the **source-free public build** — the
daemon ships as a stripped native binary and the shell as minified modules.
Development source is not distributed.

## Requirements
- A DSH host with the `@deepseek-ai/dsh-*` packages in the host install (the
  DSH host provides them — see the peer-note under Install).
  - the **full build** runs on the rc.5-generation host (`0.2.2-rc.5`);
  - the **rc1host build** runs on the rc.1-generation host (the dsh-Go phone
    engine, `0.2.2-rc.1`) — the LLM-dependent faces take their deterministic
    floors there, everything else is fully active.
- Node >= 20 to run the shell; the daemon binary is native — no toolchain needed.
- The builds are **self-contained**: the two runtime deps (dsh-tools,
  schemastery) are inlined into the bundle, so a folder-copy / `file:` install
  needs no registry access.

## Install
One-liner (the installer lives on the dist repo's main branch; it fetches the
tarball + `SHA256SUMS` from the releases branch, verifies, extracts):

```sh
# unix — the variant is auto-detected from the running DSH host generation
# (rc.1..rc.4 hosts get the rc1host build automatically):
curl -fsSL https://raw.githubusercontent.com/stennyc/filemem-dsh-dist/main/install.sh | sh

# force a variant explicitly (the second argument):
curl -fsSL https://raw.githubusercontent.com/stennyc/filemem-dsh-dist/main/install.sh | sh rc1host
```

**No curl/wget available?** (the dsh-Go phone proot userland: node is
preinstalled, the download tools are not) — the pure-node installer does the
fetch + the checksum (node:crypto) + the extract (tar):

```sh
node -e "fetch('https://raw.githubusercontent.com/stennyc/filemem-dsh-dist/main/install-node.mjs').then(r=>r.arrayBuffer()).then(b=>require('fs').writeFileSync('/tmp/install-node.mjs', Buffer.from(b)))"
node /tmp/install-node.mjs rc1host    # the phone host; omit the arg on rc.5 desktops
```

```powershell
# windows
powershell -c "irm https://raw.githubusercontent.com/stennyc/filemem-dsh-dist/main/install.ps1 | iex"
```

Manual: download `filemem-dsh-<version>[-rc1host]-<platform>.tar.gz` from
https://github.com/stennyc/filemem-dsh-dist/tree/releases and verify with the
branch's `SHA256SUMS`. The top-level directory inside every tarball is
`filemem-dsh-<version>` (the variant marker is on the archive FILE name only,
not the directory). Then add the extracted directory as a `file:` dependency in
your DSH profile's `package.json` and install:

```sh
cd <your-dsh-profile-dir>
pnpm add <path-to-extracted>/filemem-dsh-<version>
```

> **Peer warning note:** when installing by path, pnpm prints
> "The linked dependency will not resolve the peer dependencies…" — the peers
> (`@deepseek-ai/cordis`, the `dsh-*` services) are provided by the DSH host
> install (e.g. `/opt/dsh` on the phone). The warning is expected and harmless;
> the plugin loads from the host's tree.

Finally, the host must reload the plugin (desktop: restart the DSH host
process). On the **dsh-Go phone** there is no "restart the host" button — see
the phone section's last step.

The bundle patch row (`cordis.patch.yml`, shipped in the package) mounts the
plugin: 14-face tool surface + L1 handoff + the settings panel. Store root
defaults to `~/.dsh/filemem` (per-user isolated).

## On a phone (dsh-Go, the 0.2.2-rc.1 host generation)

The phone engine ships the rc.1 DSH generation, which has no `llm` inject
token. Use the **rc1host** build: it declares only the tokens rc.1 resolves,
and every LLM-dependent face (the L1 handoff summary, the L2 reclassify,
the L4 rescore) takes its coded deterministic floor there. The data plane
(the 14-face tool surface) and the guidance section are fully active —
verified on a real rc.1 host.

The steps (all in the App's "terminal" page):

```sh
# 1. get the tarball (proot has no curl/wget — use the node one-liner):
node -e "fetch('https://raw.githubusercontent.com/stennyc/filemem-dsh-dist/releases/filemem-dsh-0.1.0-rc1host-linux-arm64.tar.gz').then(r=>r.arrayBuffer()).then(b=>require('fs').writeFileSync('/tmp/fm.tar.gz', Buffer.from(b)))"

# 2. extract + place it under the plugins directory (the directory name is
#    filemem-dsh-0.1.0 — no variant suffix):
tar -xzf /tmp/fm.tar.gz -C /tmp
cp -r /tmp/filemem-dsh-0.1.0 /root/.dsh/dsh-go/plugins/filemem-rc1

# 3. install into the profile the App's engine runs (usually `web` — the
#    App boots its engine with that profile; check yours with
#    `ls /root/.dsh/profiles/`): dsh plugin add takes effect without a restart
dsh plugin --profile web add /root/.dsh/dsh-go/plugins/filemem-rc1

# 4. make the running engine pick it up: kill the engine process — the App's
#    supervisor relaunches it automatically (or simply close and reopen the
#    App). There is no user-facing "restart the host" on the phone.
#    (the engine process is the `dsh web` / bin.js web one, visible with `ps`)
```

Desktop hosts on the rc.5 generation: use the plain `filemem-dsh-<version>-*`
tarballs (the full LLM faces are active there).

## Configure
All knobs are the volatile config fields restated in the package's
`cordis.patch.yml` (injected into the active profile row, patch-replaces-whole-config
semantics). The settings panel in the Web GUI's Plugins page edits the same
fields live (the mirror-into-decay.json knobs need no restart; the Go data
plane hot-reads them). `daemonPath` / `storePath` stay patch-row fields — point
`daemonPath` at `dist/filemem-go` inside the package if you move the install.

## Uninstall
`pnpm remove @stennyc/filemem-dsh` in the profile (on dsh-Go:
`dsh plugin --profile web remove @stennyc/filemem-dsh` + delete the plugins
directory), then delete `~/.dsh/filemem` if you also want the local memory
pool gone.

## Security posture
- The daemon is a closed binary: verify the release checksums before use.
- The memory pool is local to your home; the central shared pool (PostgreSQL)
  is opt-in and off by default.
- The package carries no install scripts (`postinstall` etc.) — the host side
  executes nothing beyond the normal plugin load.
