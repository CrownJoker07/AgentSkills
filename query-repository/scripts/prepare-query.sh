#!/usr/bin/env bash

set -eu

usage() {
    echo "Usage: scripts/prepare-query.sh REPO_PATH [BRANCH_NAME]" >&2
}

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    usage
    exit 2
fi

REPO_INPUT=$1
BRANCH_NAME=${2:-main}

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

QUERY_REF="refs/remotes/origin/$BRANCH_NAME"
if ! git -C "$REPO_ROOT" fetch origin "+refs/heads/$BRANCH_NAME:$QUERY_REF" >/dev/null 2>&1; then
    echo "Error: unable to fetch origin/$BRANCH_NAME" >&2
    exit 1
fi

if ! COMMIT_ID=$(git -C "$REPO_ROOT" rev-parse --verify "$QUERY_REF^{commit}" 2>/dev/null); then
    echo "Error: remote branch does not exist: origin/$BRANCH_NAME" >&2
    exit 1
fi

printf 'REPO_ROOT=%s\n' "$REPO_ROOT"
printf 'BRANCH_NAME=%s\n' "$BRANCH_NAME"
printf 'QUERY_REF=%s\n' "$QUERY_REF"
printf 'COMMIT_ID=%s\n' "$COMMIT_ID"
