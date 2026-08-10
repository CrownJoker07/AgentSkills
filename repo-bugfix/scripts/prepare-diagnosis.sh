#!/usr/bin/env bash

set -eu

usage() {
    echo "Usage: scripts/prepare-diagnosis.sh REPO_PATH WORKSPACE_ROOT [BASE_REF]" >&2
}

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    usage
    exit 2
fi

REPO_INPUT=$1
WORKSPACE_INPUT=$2
BASE_REF=${3:-}

if [ ! -d "$REPO_INPUT" ] || [ ! -d "$WORKSPACE_INPUT" ]; then
    echo "Error: repository or workspace directory does not exist" >&2
    exit 1
fi

if ! REPO_ROOT=$(git -C "$REPO_INPUT" rev-parse --show-toplevel 2>/dev/null); then
    echo "Error: path is not inside a Git repository: $REPO_INPUT" >&2
    exit 1
fi

REPO_ROOT=$(cd "$REPO_ROOT" && pwd -P)
WORKSPACE_ROOT=$(cd "$WORKSPACE_INPUT" && pwd -P)

if ! git -C "$REPO_ROOT" remote get-url origin >/dev/null 2>&1; then
    echo "Error: Git remote 'origin' is not configured" >&2
    exit 1
fi

if ! git -C "$REPO_ROOT" fetch origin >/dev/null 2>&1; then
    echo "Error: unable to fetch origin" >&2
    exit 1
fi

if [ -z "$BASE_REF" ]; then
    if ! BASE_REF=$(git -C "$REPO_ROOT" symbolic-ref --quiet --short refs/remotes/origin/HEAD); then
        echo "Error: origin/HEAD is unavailable; provide BASE_REF explicitly" >&2
        exit 1
    fi
fi

if ! BASE_COMMIT=$(git -C "$REPO_ROOT" rev-parse --verify "$BASE_REF^{commit}" 2>/dev/null); then
    echo "Error: base ref does not resolve to a commit: $BASE_REF" >&2
    exit 1
fi

REPO_NAME=$(basename "$REPO_ROOT")
WORKTREE_PARENT="$WORKSPACE_ROOT/worktrees/bugfix/$REPO_NAME"
DIAGNOSTIC_PATH="$WORKTREE_PARENT/diagnosis-$(date +%Y%m%d-%H%M%S)-$$"

mkdir -p "$WORKTREE_PARENT"
if ! git -C "$REPO_ROOT" worktree add --detach "$DIAGNOSTIC_PATH" "$BASE_COMMIT" >/dev/null 2>&1; then
    echo "Error: unable to create diagnostic worktree" >&2
    exit 1
fi

printf 'REPO_ROOT=%s\n' "$REPO_ROOT"
printf 'BASE_REF=%s\n' "$BASE_REF"
printf 'BASE_COMMIT=%s\n' "$BASE_COMMIT"
printf 'DIAGNOSTIC_PATH=%s\n' "$DIAGNOSTIC_PATH"
