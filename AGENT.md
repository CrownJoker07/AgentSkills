# Repository Agent Instructions

## Authoritative Specification

All skills in this repository MUST strictly comply with the [Agent Skills Specification](https://agentskills.io/specification).

Treat the specification as the sole authority for skill format, directory structure, metadata fields, naming constraints, file references, and validation. If this file, repository documentation, existing skills, tooling, examples, or prior conventions conflict with the specification, follow the specification and update the conflicting repository content when it is within the requested scope.

## Skill Requirements

When creating or modifying a skill:

- Store the skill in a directory whose name exactly matches the `name` field in `SKILL.md`.
- Include a `SKILL.md` containing YAML frontmatter followed by Markdown instructions.
- Require `name` and `description` and enforce every constraint defined for them by the specification.
- Use optional frontmatter fields only as defined by the specification.
- Create `scripts/`, `references/`, `assets/`, or other files only when the skill actually needs them.
- Keep `SKILL.md` focused and use progressive disclosure for detailed resources.
- Reference skill files with paths relative to the skill root and avoid deep reference chains.
- Do not invent fields, structures, or conventions that contradict the specification.
- Keep changes limited to the requested capability.

## Sensitive Information

Sensitive information MUST NOT appear anywhere in this repository. This prohibition applies to skill instructions, frontmatter, scripts, references, assets, examples, fixtures, configuration, comments, logs, command output, documentation, and commit content.

- Do not add or expose credentials, passwords, access tokens, API keys, private keys, session data, cookies, connection strings, personal data, internal addresses, or other confidential information.
- Use clearly synthetic placeholders when an example requires a credential-like value.
- Do not copy sensitive values from the environment, local files, tool output, conversation context, or external systems into repository files or responses.
- Before completing a change, inspect the changed content for sensitive information.
- If sensitive information is found, do not repeat or display it. Remove it from the requested changes when safe and within scope; otherwise stop and report only its location and category in redacted form.

## Validation

Validate every created or modified skill with the official reference validator when it is available:

```bash
skills-ref validate ./<skill-directory>
```

Fix all reported specification violations before considering the work complete. If the validator is unavailable, manually check the skill against the current authoritative specification and clearly report that automated validation was not run.

## Hard Rules for Skill Execution

When executing any skill in this repository, the following hard rules apply globally. They capture failure modes that have occurred in past runs and MUST be enforced by the agent on every invocation, regardless of how natural it feels to relax them.

### Must-activate Trigger

If the user's input matches a skill's activation conditions (for example, sending or pasting a resume for `interview-questions`), the agent MUST activate that skill immediately. It MUST NOT treat the input as a plain chat question and summarize the material, list key points, or ask "do you want me to continue?". The first reply MUST begin with the skill's first skeleton section, not a confirmation prompt.

### No Confirmation Loops

Once a skill is activated and the input material is sufficient, the agent MUST run the skill's full workflow end-to-end in one reply. The agent MUST NOT ask any of the following mid-flow or at the end:

- "Do you want me to generate …?"
- "Should I write this to Feishu / a document / a file?"
- "Do you want to continue to the next step?"
- "Is the inferred direction correct, shall I continue?"

Asking for confirmation is only allowed when material is genuinely missing and the next step is blocked. Otherwise, produce the final output directly.

### No Free-form Skeleton Replacement

When a skill defines a fixed skeleton (for example, fixed one-level headings, fixed two-level category headings, or a fixed list of items), the agent MUST use the skeleton verbatim. It MUST NOT replace fixed category headings with free-form titles (for example, replacing fixed categories like "4.1 … / 4.2 … / … / 4.6 …" with topic headings like "Engine Core / Language Basics / Networking / Architecture / Debugging"). It MUST NOT skip, merge, reorder, or rename required sections.

### Required Items Must Appear

When a skill defines a "must-ask list", "required items", "fixed checklist", or any item explicitly marked as required, those items MUST appear verbatim in every run. They MUST appear in the category or position the skill assigns, and MUST NOT be rewritten, merged into another item, or omitted even when the agent thinks alternative items are more relevant.

### Item Format Must Be Preserved

When a skill specifies a per-item format (for example, Markdown task checkboxes `- [ ]`, numbered lists, tables, or block structures for external documents), every item in the output MUST follow that format exactly. The agent MUST NOT fall back to plain numbered lists (`1. …`), plain bullet lists (`- …`), or any other format when the skill specifies `- [ ]`. Required-item markers (for example, `★` for must-ask items) MUST be preserved at the position the skill defines.

### No Domain-specific Narrowing of Generic Skills

Unless the skill's own description or body explicitly narrows the scope to a specific domain (for example, a specific programming language, engine, industry, or product), the agent MUST keep the skill's instructions, examples, and generated output domain-agnostic. It MUST NOT inject domain-specific terminology, product names, or example scenarios into a generic skill's output just because the current resume or input happens to belong to a particular domain.

### Default Parameters Must Be Used When Unspecified

When a skill defines default parameters (for example, default pacing, default total count, default duration, default sampling rule), the agent MUST apply those defaults when the user does not specify otherwise. It MUST NOT silently choose a different default (for example, generating 12 or 34 items when the skill's default is 10). If the user specifies a different value, the agent MUST apply the skill's documented scaling rule instead of inventing a new one.

