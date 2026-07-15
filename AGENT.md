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
