#!/usr/bin/env bash

set -eu

usage() {
    echo "Usage: scripts/cleanup-diagnosis.sh REPO_PATH WORKSPACE_ROOT DIAGNOSTIC_PATH" >&2
}

if [ "$#" -ne 3 ]; then
    usage
    exit 2
fi

REPO_INPUT=$1
WORKSPACE_INPUT=$2
DIAGNOSTIC_INPUT=$3

if ! REPO_ROOT=$(git -C "$REPO_INPUT" rev-parse --show-toplevel 2>/dev/null); then
    echo "Error: path is not inside a Git repository: $REPO_INPUT" >&2
    exit 1
fi

if [ ! -d "$WORKSPACE_INPUT" ] || [ ! -d "$DIAGNOSTIC_INPUT" ]; then
    echo "Error: workspace or diagnostic worktree directory does not exist" >&2
    exit 1
fi

REPO_ROOT=$(cd "$REPO_ROOT" && pwd -P)
WORKSPACE_ROOT=$(cd "$WORKSPACE_INPUT" && pwd -P)
DIAGNOSTIC_PATH=$(cd "$DIAGNOSTIC_INPUT" && pwd -P)
REPO_NAME=$(basename "$REPO_ROOT")
BUGFIX_ROOT="$WORKSPACE_ROOT/worktrees/bugfix/$REPO_NAME"

case "$DIAGNOSTIC_PATH" in
    "$BUGFIX_ROOT"/diagnosis-*) ;;
    *)
        echo "Error: refusing to remove path outside diagnostic worktree root" >&2
        exit 1
        ;;
esac

if ! git -C "$REPO_ROOT" worktree list --porcelain | grep -Fqx "worktree $DIAGNOSTIC_PATH"; then
    echo "Error: path is not a registered worktree for this repository" >&2
    exit 1
fi

if [ -n "$(git -C "$DIAGNOSTIC_PATH" status --porcelain)" ]; then
    echo "Error: diagnostic worktree is not clean; preserving it" >&2
    exit 1
fi

git -C "$REPO_ROOT" worktree remove "$DIAGNOSTIC_PATH"
git -C "$REPO_ROOT" worktree prune
