# Changelog

## Unreleased
- **Pitfall markers for resolved mistake memories (owner 2026-11-27
  「消解即坑位」ruling, D-LESSON-2 — amends the ②c "resolved/stale
  → relevance-gated" clause)**: a CONFIRMED lesson that is later
  stale / resolved / superseded now stays on the per-turn lesson lane
  as the compact 坑位 marker instead of dropping out — rendered as
  `· 坑位（已修正，别再犯）: 被 <corrected_by> 修正/替代 — <content>`
  + the tool-guidance line (point at the correction row via
  `filemem_read`, the `filemem_retrieve` fallback when the link target
  is swept). Tiers: the active open mistakes first, the pitfall ones
  after (both under the `injection.lesson.perturn_max` cap). The dream
  contradiction verdict now stamps the structured correction link
  (`corrected_by` on the stale row, the `correction_of` reverse marker
  on the winner — skipped for failure-exempt winners, the ①A red line
  keeps every LLM touch off a mechanical row). Settled rows and
  explicitly `valid_until`-expired pitfall rows fold out. The P3
  replay re-trim mirrors the two-tier admission (the live/replay
  zero-divergence rule, the lane predicate).

## 0.2.0 — 2026-11-27
- **First-class `lesson` memory lane (owner 2026-11-27「人会记错，filemem
  要记错」三判词 ①A/②c/③ + 复盘修复批)**: `lesson` is the 7th
  first-class type (`memories/lesson.json`) — the mistake / negative-
  example lane. ①A: the supersede red line keys on the
  `failure_type` METADATA (mechanical tool-failure rows stay exempt
  across every face — user supersede, dream merge/contradiction,
  supersede_confirm), so a bad turn never pollutes durable memory;
  model-authored lessons keep a normal open→resolved/stale lifecycle.
  ②c: hybrid delivery — VERIFIED lessons that are global or scoped to
  the current workspace ride a dedicated per-turn lane (top-N capped
  by `injection.lesson.perturn_max`, default 4; content never
  truncated; rides the 0-hit face too); everything else stays
  relevance-gated (the 人会记错 trust gate). ③: the minimal
  mechanical surface set (recall pool / supersede / failureFlush /
  export / scoped-delete / archive / P3 replay re-trim). The
  mechanical failure_flush lane re-lands on the lesson shard; the LLM
  reclass face accepts lesson as a target (single + batch prompts,
  both shell back-fill legs). Golden zero-regression (two
  design-driven golden updates, byte-stability proven at the binary
  level) + a reviewer 复盘修复批 (P1-1 red-line gate on the LLM
  consolidation verdicts, P2-1 catch-floor whitelist, P2-2 replay
  re-trim predicate, P2-3 hard-row dedup, P3 smalls + the P3-4 TTL
  posture ruling: default-L1 lessons never TTL-sweep — a long-lived
  mistake stays in the per-turn lane until lifecycle-folded or
  owner-deleted; an explicit L0 lesson archives out at its 30-day TTL).
- **Phone settings card completed (owner 2026-11-27「dsh-go 手机端 filemem
  设置卡完善」)**: every `Config` schema field now carries its own
  `description` — a Chinese 「title（hint）」phrase the dsh-Go phone host's
  generated card (`settings/describe` form) splits into the row title and its
  one-line hint — plus an `en` locale entry via `.i18n()` for the English UI.
  The phone card previously fell back to humanized English keys with no hint;
  it now shows labeled, hinted rows on both the volatile-only projection
  (relay / bridge fallback) and the full bridge form. The loader plumbing
  field `client` is `.hidden()` so it no longer renders as a raw JSON row.
  Web card untouched (its labels come from the shipped client.js dictionaries);
  the Go data plane and all golden paths untouched.
  Verified: `tsc` clean, the serialized schema carries 27 described fields
  (probe of `Config.toJSON()`), every zh hint ≤ 40 runes (no app-side
  ellipsize), `client_smoke` + `verify-fixes` + the local e2e batteries pass
  (the pre-existing auto_face / repeat_guard / c5 / workspace_gate drift
  fails identically at the untouched HEAD).

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
- **Pool-hygiene fix (owner phone check 2026-11-27): the auto-catch
  no longer pollutes the confirmed pool with host frames or user
  questions.** The phone store had two confirmed noise facts riding the
  every-round global injection: (a) a runtime-context snapshot (the
  harness GUI URL / approval-policy / skill-catalog frames — the L0
  url keyword hit inside the host frame, the whole block was saved and
  auto-confirmed); (b) the user QUESTION "完成了，这次安装有没有遇到什么
  问题…" (an ellipsis-terminated question slipped the ?/？ endings). Three
  guards: the host-frame opener list now includes the DSH harness /
  dsh-Go runtime frames (Current runtime context / Current DSH / the
  approval-policy notice / the AGENTS instructions / the skill catalog /
  the [filemem-memory] self-injection block / the elapsed-time line);
  a lane-keyword hit inside a question-shaped utterance is SKIPPED (the
  question shape wins over the keyword, the explainable
  skipped_interrogative floor); the fact-candidate aperture rejects a
  terminal ellipsis + the interrogative particles (吗/呢/吧 anywhere;
  是否/有没有/能不能/为什么/怎么/可否 in the last 10 runes — a negated
  assertion like "没有遇到任何问题" stays a fact). Selftest covers all
  four shapes.