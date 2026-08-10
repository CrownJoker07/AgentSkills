#!/usr/bin/env bash

set -eu

usage() {
    echo "Usage: scripts/cleanup-query.sh REPO_PATH WORKSPACE_ROOT WORKTREE_PATH" >&2
}

if [ "$#" -ne 3 ]; then
    usage
    exit 2
fi

REPO_INPUT=$1
WORKSPACE_INPUT=$2
WORKTREE_INPUT=$3

if ! REPO_ROOT=$(git -C "$REPO_INPUT" rev-parse --show-toplevel 2>/dev/null); then
    echo "Error: path is not inside a Git repository: $REPO_INPUT" >&2
    exit 1
fi

if [ ! -d "$WORKSPACE_INPUT" ] || [ ! -d "$WORKTREE_INPUT" ]; then
    echo "Error: workspace or worktree directory does not exist" >&2
    exit 1
fi

REPO_ROOT=$(cd "$REPO_ROOT" && pwd -P)
WORKSPACE_ROOT=$(cd "$WORKSPACE_INPUT" && pwd -P)
WORKTREE_PATH=$(cd "$WORKTREE_INPUT" && pwd -P)
REPO_NAME=$(basename "$REPO_ROOT")
QUERY_ROOT="$WORKSPACE_ROOT/worktrees/query/$REPO_NAME"

case "$WORKTREE_PATH" in
    "$QUERY_ROOT"/*) ;;
    *)
        echo "Error: refusing to remove worktree outside query root" >&2
        exit 1
        ;;
esac

if ! git -C "$REPO_ROOT" worktree list --porcelain | grep -Fqx "worktree $WORKTREE_PATH"; then
    echo "Error: path is not a registered worktree for this repository" >&2
    exit 1
fi

if [ -n "$(git -C "$WORKTREE_PATH" status --porcelain)" ]; then
    echo "Error: query worktree is not clean; preserving it" >&2
    exit 1
fi

git -C "$REPO_ROOT" worktree remove "$WORKTREE_PATH"
git -C "$REPO_ROOT" worktree prune
