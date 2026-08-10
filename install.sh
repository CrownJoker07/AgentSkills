#!/bin/sh

set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if ! command -v openclaw >/dev/null 2>&1; then
    echo "Error: openclaw is not installed or not in PATH" >&2
    exit 1
fi

for skill_file in "$repo_dir"/*/SKILL.md; do
    [ -e "$skill_file" ] || continue
    openclaw skills install "${skill_file%/SKILL.md}"
done

printf 'Agent Skills installed into the active OpenClaw workspace\n'
