#!/usr/bin/env bash

set -eu

usage() {
    echo "Usage: scripts/create-worktree.sh UNITY_PROJECT_PATH BRANCH_NAME [BASE_REF]" >&2
}

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    usage
    exit 2
fi

UNITY_PROJECT_INPUT=$1
BRANCH_NAME=$2
BASE_REF=${3:-}

if [ ! -d "$UNITY_PROJECT_INPUT" ]; then
    echo "Error: Unity project directory does not exist: $UNITY_PROJECT_INPUT" >&2
    exit 1
fi

UNITY_PROJECT_PATH=$(cd "$UNITY_PROJECT_INPUT" && pwd -P)

if [ ! -d "$UNITY_PROJECT_PATH/Assets" ] || [ ! -f "$UNITY_PROJECT_PATH/ProjectSettings/ProjectVersion.txt" ]; then
    echo "Error: path is not a Unity project: $UNITY_PROJECT_PATH" >&2
    exit 1
fi

if ! REPO_ROOT=$(git -C "$UNITY_PROJECT_PATH" rev-parse --show-toplevel 2>/dev/null); then
    echo "Error: Unity project is not inside a Git repository: $UNITY_PROJECT_PATH" >&2
    exit 1
fi

REPO_ROOT=$(cd "$REPO_ROOT" && pwd -P)

case "$UNITY_PROJECT_PATH" in
    "$REPO_ROOT")
        PROJECT_RELATIVE_PATH=.
        ;;
    "$REPO_ROOT"/*)
        PROJECT_RELATIVE_PATH=${UNITY_PROJECT_PATH#"$REPO_ROOT"/}
        ;;
    *)
        echo "Error: Unity project is outside its reported Git repository" >&2
        exit 1
        ;;
esac

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

if [ "$PROJECT_RELATIVE_PATH" = . ]; then
    BASE_ASSETS_PATH=Assets
    BASE_VERSION_PATH=ProjectSettings/ProjectVersion.txt
else
    BASE_ASSETS_PATH="$PROJECT_RELATIVE_PATH/Assets"
    BASE_VERSION_PATH="$PROJECT_RELATIVE_PATH/ProjectSettings/ProjectVersion.txt"
fi

if ! git -C "$REPO_ROOT" cat-file -e "$BASE_REF:$BASE_ASSETS_PATH" 2>/dev/null ||
   ! git -C "$REPO_ROOT" cat-file -e "$BASE_REF:$BASE_VERSION_PATH" 2>/dev/null; then
    echo "Error: Unity project is not tracked in base ref: $BASE_REF" >&2
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

if [ "$PROJECT_RELATIVE_PATH" = . ]; then
    WORKTREE_UNITY_PROJECT_PATH=$WORKTREE_PATH
else
    WORKTREE_UNITY_PROJECT_PATH="$WORKTREE_PATH/$PROJECT_RELATIVE_PATH"
fi

if [ ! -d "$WORKTREE_UNITY_PROJECT_PATH/Assets" ] || [ ! -f "$WORKTREE_UNITY_PROJECT_PATH/ProjectSettings/ProjectVersion.txt" ]; then
    echo "Error: Unity project is missing from the created worktree: $WORKTREE_UNITY_PROJECT_PATH" >&2
    exit 1
fi

printf 'REPO_ROOT=%s\n' "$REPO_ROOT"
printf 'PROJECT_RELATIVE_PATH=%s\n' "$PROJECT_RELATIVE_PATH"
printf 'BASE_REF=%s\n' "$BASE_REF"
printf 'BRANCH_NAME=%s\n' "$BRANCH_NAME"
printf 'WORKTREE_PATH=%s\n' "$WORKTREE_PATH"
printf 'WORKTREE_UNITY_PROJECT_PATH=%s\n' "$WORKTREE_UNITY_PROJECT_PATH"
