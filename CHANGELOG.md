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

- **Phone-ergonomics pass (owner phone feedback, same day):** the tarball
  top-level directory is unified to `filemem-dsh-<version>` across variants
  (the marker stays on the archive file name); `install.sh` gained the
  variant flag (`install.sh rc1host`) plus host-generation auto-detection;
  `install-node.mjs` is the pure-node fetch+verify+extract installer for
  proot userlands without curl/wget (node 24 preinstalled on the phone);
  the README carries the pnpm peer-warning note and the dsh-Go restart
  semantics (kill the engine process, the App supervisor relaunches it).
- **Delete-face safety fix (owner incident 2026-11-27):** the single-row
  delete leg (`id` / `key`) now carries the same dry-run-first posture as
  the scoped-predicate leg — a call without an explicit `dry_run=false`
  LOCATES the row and reports it (`found` + home shard(s)) without writing
  anything; the physical delete only happens on the explicit execute
  re-call. The incident: a dry-intent single-row delete returned
  `deleted: true` and the row was physically gone (the dry-run leg had
  only ever been spelled on the predicate leg). The selftest now covers
  both legs of the single-id path.
- **rc1host retrieve / handoff fix (owner incident 2026-11-27 #6):** on
  the rc.1-generation host the `llm` property ACCESS throws (`cannot get
  property "llm" without inject` — the reflect accessor does not return
  undefined for an undeclared token), so the previous `!ctx?.llm` value
  guard blew up before it could reach the deterministic floor. The
  single choke point (`oneShotLLM`) now wraps the access itself
  (the exported `llmFace`); every LLM face (the L1 handoff summary,
  the L2 reclassify, the L4 retrieve rescore) degrades to its coded
  floor on rc1host. Verified with a throwing-accessor simulation
  harness against the real tool executors.
- **Route d (owner ruling 2026-11-27): the model-issued LLM back-fill.**
  When the host LLM face is unavailable (the rc1host hosts: no `llm`
  inject token; the full hosts: a transient LLM miss), the
  `filemem_handoff_extract` floor response carries a `model_directive`:
  the calling model authors the handoff summary itself and back-fills it
  via the existing `filemem_llm_result op=handoff_summary` face — the Go
  data plane upgrades the pending handoff row and stamps `llm_used=true`.
  No host LLM API and no key management; any host generation. The
  tool-surface descriptions (the `handoff_extract` + `llm_result` faces)
  spell the channel so the model knows it before it ever hits the floor.
  Verified end-to-end under a throwing-accessor rc.1 simulation (floor
  + directive -> model back-fill -> the `llm_used=true` row in the pool).
- **Naming (owner ruling 2026-11-27): the display name is now 中枢省**
  (filemem-dsh stays the engineering anchor — the package / tool prefixes /
  daemon name / the store dir are unchanged, so installed phones migrate
  nothing). 中枢省 (the edict-drafting core organ) is chosen over
  memory-only names: the system is the agent's affairs hub (the records,
  the execution, the hand-offs, the adjudication, the cross-device
  consensus), not a memory store. The Chinese display surfaces (the
  locale meta title + the README) carry it; the English package
  descriptions keep the engineering framing.