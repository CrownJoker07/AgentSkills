---
name: project-docs
description: Query, explain, create, update, or review authoritative Markdown documentation under this repository's docs/ directory, and perform evidence-grounded product or game-design analysis from project documentation and implementation evidence. Use when answering project questions, tracing documented behavior to code or configuration, maintaining documentation, or reviewing product value, game mechanics, balance, economy, monetization, or retention. Do not use generic design heuristics as evidence of project intent or behavior.
---

# Project Docs

Treat `docs/` as the repository's authoritative knowledge base. Choose a read-only **query** workflow or a **writing** workflow based on the request.

## Start Here

1. Read `AGENTS.md`, `docs/README.md`, and `docs/SUMMARY.md`.
2. Route the topic to its primary category:
   - `docs/product/` — feature pages: intent, behavior, implementation, configuration, values, acceptance.
   - `docs/engineering/` — architecture, boundaries, dependencies, data flow.
   - `docs/data/` — configuration or numerical knowledge reused by multiple features.
   - `docs/content/` — characters, story, copy, media, localization.
   - `docs/operations/` — build, release, review, monitoring, operations.
   - `docs/competitors/` — external competitor research; **not authoritative project knowledge**. No freshness check applies; cite competitor/version/captured_at, and never use it to answer "how does this project implement X".
   - `docs/design/` — internal design thinking and proposals; **not authoritative project knowledge**. No freshness check applies; never cite as evidence of current behavior.

## Product Analysis References

Read only the references required by the request:

- For game mechanics, core loops, player decisions, feedback, or system analysis, read `references/game-design-principles.md`.
- For balance, progression, pacing, difficulty, counter systems, cost curves, or dominant strategies, read `references/game-balance.md`.
- For feature or product review, first-time experience, user value, or feature completeness, read `references/product-review.md`.
- For currencies, resources, rewards, sinks, pricing, progression economy, IAP, or ads, read `references/economy-design.md`.
- For onboarding, retention, return loops, long-term engagement, content cadence, or cohort analysis, read `references/retention-design.md`.
- Before giving product, design, balance, economy, monetization, or retention recommendations, read `references/evidence-and-recommendations.md`.
- When provenance affects a conclusion, resolve reference IDs such as `[S011]` through `references/SOURCES.md`.

Authoritative project evidence takes precedence over generic reference material. Use generic references to structure analysis, generate hypotheses, identify missing evidence, and design validation. Never use them to overwrite confirmed project facts, infer undocumented intent as fact, or claim player, retention, or monetization outcomes without relevant evidence.

Distinguish the kind of claim before weighing evidence:

- Use current code, configuration, server data, and runtime observation for implemented behavior.
- Use approved project documents and decision records for intended behavior.
- Use telemetry, experiments, playtests, interviews, and surveys for player behavior or experience.
- Report intended and implemented behavior separately when they conflict.
- Label analysis as fact, inference, hypothesis, recommendation, or validation.

## Query Documentation

> Documents under `docs/competitors/` are external reference, not authoritative knowledge. They have no `sources` frontmatter, so `check_freshness.py` skips them — an `UNKNOWN`/missing-sources result is expected and is **not** a staleness signal. Cite competitor/version/captured_at, and never use them to answer "how does this project implement X"; that must come from the authoritative categories.
>
> Documents under `docs/design/` are internal design thinking and proposals, not authoritative knowledge. They have no `sources` frontmatter, so `check_freshness.py` skips them — an `UNKNOWN`/missing-sources result is expected and is **not** a staleness signal. Never cite them as evidence of current behavior; use them only as background for ongoing design discussions.

1. Search `docs/SUMMARY.md` and the relevant category with `rg` / `rg --files`.
2. Run `python3 .agents/skills/project-docs/scripts/check_freshness.py <document>` before relying on a business document.
3. When status is `FRESH`, answer from the authoritative page and cite the local path for verification.
4. When `STALE`, inspect declared sources and current code/config; warn `检测到功能相关代码或配置已更新，当前文档仅供参考，需要及时更新文档。`, name the stale doc and changed sources, and separate implementation-derived findings from documented facts.
5. When `PENDING`, the doc or its sources have uncommitted changes—treat as unverified. When `UNKNOWN`, explain why freshness cannot be verified; inspect code/config before answering, but do not claim a feature changed solely from these statuses.
6. Keep query tasks read-only. Do not create or update docs unless asked.

## Write Documentation

1. Identify the requested behavior or changed implementation; inspect current code/config with targeted searches and reads.
2. Reuse an existing authoritative page; update instead of creating overlapping docs.
3. Write only facts supported by the current repository. Reference repository paths in prose when they aid verification. Do not infer missing business intent.
4. Add YAML frontmatter with exact repository-relative sources:

   ```yaml
   ---
   sources:
     - path/to/source
   ---
   ```

   Documents under `docs/competitors/` use a separate frontmatter instead of `sources` (see `docs/competitors/README.md`); they are intentionally excluded from freshness checks.

   Documents under `docs/design/` have no `sources` frontmatter (see `docs/design/README.md`); they are intentionally excluded from freshness checks and are not project knowledge.

5. Keep one feature's behavior/implementation/config/values in a single primary feature page; do not split across category dirs merely to match taxonomy.
6. Extract a separate engineering/data page only when the knowledge is reused by multiple features; link feature pages to it instead of copying.
7. Update `docs/SUMMARY.md` only when adding/moving/removing a navigable page; keep navigation coarse until the doc set stabilizes.
8. Run the freshness checker. `PENDING` is expected while doc and sources update together; resolve `STALE`/`UNKNOWN` before completion.
9. Review the doc diff with any related code/config change; keep them in one commit when behavior changed.

## Documentation Style

- Optimize for **clarity and comprehension**.
- Prefer **tables** for parallel items (modules, options, fields, paths) for scannability.
- Tables are a means, not the goal: for sequential flows, causal loops, or a single mechanism needing detail, use prose or ordered lists when clearer.
- Keep consistent layout for the same kind of info within a document; avoid mixing tables and prose awkwardly.
- For a highly independent, complex mechanism (dedicated config + Prefab, can stand alone), write a separate md doc; in referencing tables or prose, summarize in one line and link to it—do not cram the mechanism into an overview table.

## Analysis Depth

Each feature page must cover all applicable analyses below, **evidence-grounded** by configuration, assets, protocols, and code. Do not silently omit an applicable analysis: mark it `Not applicable` with a reason, or `Blocked` with the missing source or extraction problem. Never fabricate values, behavior, or business intent.

1. **Monetization analysis** — for every pay point, write the concrete **price, reward, and unlock path**; an abstract "pay point / evidence / positioning" row alone is not acceptable.
   - **获取/解锁路径**:免费边界与付费起点、解锁货币类型、消耗递增曲线(首/中/末或全档)。
   - **具体价格**:消耗货币与数量(代币/钻石数值;真实付费须给出计价档位与金额,不得只写"付费解锁"四字)。
   - **奖励内容**:每档/每礼包给出的具体道具与数量;若主表仅含 `Id` 等无奖励字段,必须追踪关联表写出实际奖励,禁止只写"N 个档位/N 条"了事。
   - 在此基础上再做 layering/funnel(免费→付费→鲸鱼、IAP 加档、双轨通行证、货币沉淀、短促充值)。
2. **Values analysis** — **write extractable real numbers into the doc** (counts, durations, probabilities, level thresholds, scaling series, grid sizes). Do not leave a "needs parsing" placeholder.
   - 关键档位和条目逐条列出数值，不只写区间或条数。商业化与解锁相关曲线（解锁消耗、礼包价格、奖励数量、档位或成就条件阈值）必须完整提取首/中/末或全档，禁止只写首条后用省略号代替，也禁止只写条数或档位数而不列具体数值。
   - Prefer directly readable sources (JSON/text data files) over binary tables.
   - For binary config tables, **read the repo's loader/deserializer code first** to recover the schema, then extract values.
   - Only mark "needs parsing / unverifiable" after reading the loader code and still failing—and state the blocker (which table, which field). Never fabricate numbers.
3. **Implementation analysis** — document the behavior that configuration alone cannot explain.
   - **Global parameters**: search global or shared configuration for feature-specific constants such as unlock counts, refresh intervals, probability tiers, purchase limits, and thresholds. Record relevant names and values; do not assume one fixed filename or naming prefix across repositories.
   - **Runtime logic**: inspect configuration loaders, feature modules, state models, UI presenters/controllers, and client-server protocol handlers. Describe state transitions and their conditions, validation ownership, important feedback loops, and other behavior that materially changes the feature. Cite repository paths and line numbers when useful.
   - **Protocol flow**: trace the relevant request, response, event, or push-message chain when behavior depends on server interaction. Identify which decisions are client-side, server-authoritative, or unverifiable from the repository.
   - **Related-data traversal**: when a primary table contains only an identifier, follow loader code and referenced tables to recover the actual item, reward, price, or condition. If the value is supplied only at runtime and neither code nor repository data resolves it, mark it `Blocked` and state why.
4. **Mechanism highlights** — point out non-obvious design patterns (feedback loops, social hooks, retention mechanics, A/B schema variants, pity systems); separate documented facts from analytical inference.

> Separate fact from analysis: direct config/resource findings are facts; interpretations built on them are analysis. Do not exaggerate or infer business intent beyond the evidence.

## Knowledge Rules

- Do not treat non-authoritative sources (deleted files, git history, chat context, external docs, or private scratch dirs) as project knowledge unless the user explicitly asks to reconcile a named source against the current implementation.
- `docs/competitors/` is the designated home for external reference material. It is not authoritative project knowledge: freshness checks do not apply, and its contents must not be cited as evidence of how this project behaves. Keep competitor facts and "implications for our project" in separate sections.
- `docs/design/` is the designated home for internal design thinking and proposals. It is not authoritative project knowledge: freshness checks do not apply, and its contents must not be cited as evidence of current behavior. Design docs may contain unconfirmed proposals, open questions, and speculative analysis — treat them as discussion material only.
- Separate product behavior from implementation details and configuration rules; link across categories when needed.
- Prefer feature cohesion over category purity; do not create parallel product/data pages for one feature unless the extracted page holds genuinely shared knowledge.
- Preserve field order when documenting data parsed from configuration, so docs match configuration, parsing code, and runtime structures top-to-bottom.
- Never copy credentials, tokens, private keys, or secrets into docs.
- No speculative roadmaps, placeholders, sample values, compatibility behavior, or unrelated cleanup.
- Do not modify code, config, assets, or prefabs for documentation-only requests.
- Do not record commit SHAs in Markdown; the checker uses the doc's latest git commit as baseline, avoiding self-reference.

## Verify Writes

- Confirm every new or changed local Markdown link resolves.
- Confirm `docs/SUMMARY.md` points only to existing pages.
- Run `python3 .agents/skills/project-docs/scripts/check_freshness.py` and review every reported status.
- Run `git diff --check`; inspect the diff for unsupported claims and duplicated knowledge.
- Do not run builds to verify documentation-only changes.
