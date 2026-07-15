#!/bin/sh

set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
install_dir="$HOME/.hermes/skills/ZZWAgentSkills"

mkdir -p "$install_dir"

for skill_file in "$repo_dir"/*/SKILL.md; do
    [ -e "$skill_file" ] || continue
    skill_dir=${skill_file%/SKILL.md}
    ln -sfn "$skill_dir" "$install_dir/${skill_dir##*/}"
done

printf 'Agent Skills installed to %s\n' "$install_dir"
