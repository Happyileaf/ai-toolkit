#!/usr/bin/env python3
"""
Codex UserPromptSubmit hook: inject lightweight frontend project context.
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

HARNESS_DIR_NAME = ".harness"


def collect_keyed_strings(obj, target_keys):
    found = []
    if isinstance(obj, dict):
        for key, value in obj.items():
            if key.lower() in target_keys and isinstance(value, str) and value.strip():
                found.append(value.strip())
            found.extend(collect_keyed_strings(value, target_keys))
    elif isinstance(obj, list):
        for item in obj:
            found.extend(collect_keyed_strings(item, target_keys))
    return found


def extract_prompt_text(hook_input):
    target_keys = {"prompt", "user_prompt", "message", "text", "content", "input"}
    candidates = collect_keyed_strings(hook_input, target_keys)
    if not candidates:
        return ""
    return sorted(candidates, key=len, reverse=True)[0]


def detect_workspace(cwd: Path) -> Path:
    harness = cwd / HARNESS_DIR_NAME
    return harness if harness.exists() else cwd


def detect_package_manager(root: Path) -> str:
    if (root / "pnpm-lock.yaml").exists():
        return "pnpm"
    if (root / "yarn.lock").exists():
        return "yarn"
    if (root / "bun.lock").exists() or (root / "bun.lockb").exists():
        return "bun"
    if (root / "package-lock.json").exists():
        return "npm"
    return "unknown"


def read_package_scripts(root: Path) -> list[str]:
    package_json = root / "package.json"
    if not package_json.exists():
        return []
    try:
        payload = json.loads(package_json.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return []
    scripts = payload.get("scripts", {})
    if not isinstance(scripts, dict):
        return []
    return sorted(scripts.keys())


def get_git_branch(root: Path) -> str:
    try:
        out = subprocess.check_output(
            ["git", "-C", str(root), "rev-parse", "--abbrev-ref", "HEAD"],
            stderr=subprocess.DEVNULL,
            timeout=5,
        )
        return out.decode().strip()
    except (subprocess.CalledProcessError, FileNotFoundError, subprocess.TimeoutExpired):
        return "unknown"


def task_summary(workspace: Path) -> str:
    index = workspace / "task-harness" / "index.json"
    if not index.exists():
        return "task index not found"
    try:
        data = json.loads(index.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return "task index parse failed"
    mode = str(data.get("mode", "unknown"))
    globs = data.get("task_globs", [])
    return f"task mode={mode}, task_globs={len(globs) if isinstance(globs, list) else 0}"


def main():
    try:
        hook_input = json.loads(sys.stdin.read() or "{}")
    except (json.JSONDecodeError, ValueError):
        hook_input = {}

    prompt = extract_prompt_text(hook_input)
    cwd = Path.cwd()
    workspace = detect_workspace(cwd)
    repo_root = workspace.parent if workspace.name == HARNESS_DIR_NAME else workspace
    branch = get_git_branch(repo_root)
    pm = detect_package_manager(repo_root)
    scripts = read_package_scripts(repo_root)

    lines = [
        f"Git branch: {branch}",
        f"Package manager: {pm}",
        f"package.json scripts: {', '.join(scripts) if scripts else 'none'}",
        f"Harness: {task_summary(workspace)}",
        "Frontend gate reminder: lint + typecheck + unit + build + e2e + agent review.",
        "Accessibility reminder: keyboard flow, semantic tags, and image alt text.",
    ]

    if "quick fix" in prompt.lower() or "quick-fix" in prompt.lower():
        lines.append("Quick-fix reminder: keep diff <= 3 files and <= 100 lines, otherwise upgrade to standard flow.")

    message = (
        "Project context:\n"
        + "\n".join(lines)
        + "\n\nRead only relevant specs/contracts/tasks before editing."
    )
    print(json.dumps({"systemMessage": message}, ensure_ascii=False))


if __name__ == "__main__":
    main()
