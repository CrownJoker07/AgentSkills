#!/usr/bin/env python3

import subprocess
import sys
from pathlib import Path


def run_git(repo: Path, *args: str) -> tuple[int, str]:
    result = subprocess.run(
        ["git", *args],
        cwd=repo,
        capture_output=True,
        text=True,
        check=False,
    )
    return result.returncode, result.stdout.strip()


def find_repo() -> Path:
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError("not inside a Git repository")
    return Path(result.stdout.strip()).resolve()


def read_sources(document: Path) -> list[str]:
    lines = document.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0] != "---":
        return []

    sources: list[str] = []
    in_sources = False
    for line in lines[1:]:
        if line == "---":
            break
        if line == "sources:":
            in_sources = True
            continue
        if in_sources and line.startswith("  - "):
            source = line[4:].strip().strip('"\'')
            if source:
                sources.append(source)
            continue
        if in_sources and line and not line.startswith(" "):
            in_sources = False
    return sources


def resolve_documents(repo: Path, arguments: list[str]) -> list[Path]:
    if arguments:
        return [(repo / argument).resolve() for argument in arguments]

    documents = []
    for document in sorted((repo / "docs").rglob("*.md")):
        if read_sources(document):
            documents.append(document)
    return documents


def relative_path(repo: Path, target: Path) -> str:
    try:
        return target.relative_to(repo).as_posix()
    except ValueError as error:
        raise RuntimeError(f"path is outside repository: {target}") from error


def changed_paths(repo: Path, arguments: list[str], sources: list[str]) -> set[str]:
    code, output = run_git(repo, *arguments, "--", *sources)
    if code != 0:
        raise RuntimeError("Git change check failed")
    return {line for line in output.splitlines() if line}


def check_document(repo: Path, document: Path) -> tuple[str, list[str]]:
    document_path = relative_path(repo, document)
    if not document.is_file():
        return "UNKNOWN", ["document does not exist"]

    sources = read_sources(document)
    if not sources:
        return "UNKNOWN", ["missing sources frontmatter"]

    invalid_sources = []
    for source in sources:
        source_path = Path(source)
        if source_path.is_absolute() or ".." in source_path.parts:
            invalid_sources.append(source)
            continue
        code, tracked = run_git(repo, "ls-files", "--", source)
        if code != 0 or not tracked:
            invalid_sources.append(source)
    if invalid_sources:
        return "UNKNOWN", [f"invalid or untracked source: {source}" for source in invalid_sources]

    code, tracked_document = run_git(repo, "ls-files", "--error-unmatch", document_path)
    if code != 0 or not tracked_document:
        return "UNKNOWN", ["document has no committed Git baseline"]

    code, baseline = run_git(repo, "log", "-1", "--format=%H", "--", document_path)
    if code != 0 or not baseline:
        return "UNKNOWN", ["document has no committed Git baseline"]

    historical = changed_paths(repo, ["diff", "--name-only", f"{baseline}..HEAD"], sources)
    staged = changed_paths(repo, ["diff", "--cached", "--name-only"], sources)
    unstaged = changed_paths(repo, ["diff", "--name-only"], sources)

    code, untracked_output = run_git(
        repo,
        "ls-files",
        "--others",
        "--exclude-standard",
        "--",
        *sources,
    )
    if code != 0:
        raise RuntimeError("Git untracked-file check failed")
    untracked = {line for line in untracked_output.splitlines() if line}

    source_changes = historical | staged | unstaged | untracked
    code, document_status = run_git(repo, "status", "--short", "--", document_path)
    if code != 0:
        raise RuntimeError("Git document status check failed")

    if source_changes and document_status:
        return "PENDING", sorted(source_changes)
    if source_changes:
        return "STALE", sorted(source_changes)
    if document_status:
        return "PENDING", ["document has uncommitted changes"]
    return "FRESH", []


def main() -> int:
    try:
        repo = find_repo()
        documents = resolve_documents(repo, sys.argv[1:])
        if not documents:
            print("No source-aware documents found.")
            return 0

        failed = False
        for document in documents:
            status, details = check_document(repo, document)
            print(f"{status} {relative_path(repo, document)}")
            for detail in details:
                print(f"  {detail}")
            if status == "STALE":
                print("  WARNING 检测到功能相关代码或配置已更新，当前文档仅供参考，需要及时更新文档。")
            if status in {"STALE", "UNKNOWN"}:
                failed = True
        return 1 if failed else 0
    except (OSError, RuntimeError, UnicodeError) as error:
        print(f"ERROR {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
