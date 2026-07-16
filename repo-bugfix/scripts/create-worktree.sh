#!/usr/bin/env bash

set -eu

usage() {
    echo "Usage: scripts/create-worktree.sh REPO_PATH BRANCH_NAME [BASE_REF]" >&2
}

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    usage
    exit 2
fi

REPO_INPUT=$1
BRANCH_NAME=$2
BASE_REF=${3:-}

if [ ! -d "$REPO_INPUT" ]; then
    echo "Error: repository directory does not exist: $REPO_INPUT" >&2
    exit 1
fi

if ! REPO_ROOT=$(git -C "$REPO_INPUT" rev-parse --show-toplevel 2>/dev/null); then
    echo "Error: path is not inside a Git repository: $REPO_INPUT" >&2
    exit 1
fi

REPO_ROOT=$(cd "$REPO_ROOT" && pwd -P)

if ! git -C "$REPO_ROOT" remote get-url origin >/dev/null 2>&1; then
    echo "Error: Git remote 'origin' is not configured" >&2
    exit 1
fi

if ! git check-ref-format --branch "$BRANCH_NAME" >/dev/null 2>&1; then
    echo "Error: invalid branch name: $BRANCH_NAME" >&2
    exit 1
fi

echo "Fetching origin"
git -C "$REPO_ROOT" fetch origin

if [ -z "$BASE_REF" ]; then
    if ! BASE_REF=$(git -C "$REPO_ROOT" symbolic-ref --quiet --short refs/remotes/origin/HEAD); then
        echo "Error: origin/HEAD is unavailable; provide BASE_REF explicitly" >&2
        exit 1
    fi
fi

if ! git -C "$REPO_ROOT" rev-parse --verify "$BASE_REF^{commit}" >/dev/null 2>&1; then
    echo "Error: base ref does not resolve to a commit: $BASE_REF" >&2
    exit 1
fi

if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    echo "Error: local branch already exists: $BRANCH_NAME" >&2
    exit 1
fi

REMOTE_BRANCH_STATUS=0
git -C "$REPO_ROOT" ls-remote --exit-code --heads origin "$BRANCH_NAME" >/dev/null 2>&1 || REMOTE_BRANCH_STATUS=$?
case "$REMOTE_BRANCH_STATUS" in
    0)
        echo "Error: remote branch already exists: origin/$BRANCH_NAME" >&2
        exit 1
        ;;
    2)
        ;;
    *)
        echo "Error: unable to check remote branch: origin/$BRANCH_NAME" >&2
        exit 1
        ;;
esac

REPO_NAME=$(basename "$REPO_ROOT")
BRANCH_SLUG=$(printf '%s' "$BRANCH_NAME" | tr '/' '-')
WORKTREE_PATH="$HOME/.worktrees/$REPO_NAME/$BRANCH_SLUG"

if [ -e "$WORKTREE_PATH" ]; then
    echo "Error: worktree path already exists: $WORKTREE_PATH" >&2
    exit 1
fi

mkdir -p "$(dirname "$WORKTREE_PATH")"
git -C "$REPO_ROOT" worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" "$BASE_REF"

printf 'REPO_ROOT=%s\n' "$REPO_ROOT"
printf 'BASE_REF=%s\n' "$BASE_REF"
printf 'BRANCH_NAME=%s\n' "$BRANCH_NAME"
printf 'WORKTREE_PATH=%s\n' "$WORKTREE_PATH"
