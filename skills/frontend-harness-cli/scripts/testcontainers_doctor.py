#!/usr/bin/env python3
"""Diagnose frontend runtime readiness for frontend-harness QA."""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(description="Check frontend runtime prerequisites.")
    parser.add_argument("--target-dir", default=".", help="目标项目目录")
    parser.add_argument("--format", choices=("text", "json"), default="text", help="输出格式")
    parser.add_argument("--require-node", action="store_true", help="Node 不可用时返回非 0")
    return parser.parse_args()


def run(command: list[str], cwd: Path, timeout: int = 20) -> dict[str, object]:
    try:
        completed = subprocess.run(
            command,
            cwd=str(cwd),
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=timeout,
        )
        return {
            "command": command,
            "exit_code": completed.returncode,
            "stdout": completed.stdout[-4000:],
            "stderr": completed.stderr[-4000:],
        }
    except FileNotFoundError:
        return {"command": command, "exit_code": 127, "stdout": "", "stderr": "command not found"}
    except subprocess.TimeoutExpired as exc:
        return {
            "command": command,
            "exit_code": 124,
            "stdout": (exc.stdout or "")[-4000:] if isinstance(exc.stdout, str) else "",
            "stderr": "command timed out",
        }


def package_manager(root: Path) -> str:
    if (root / "pnpm-lock.yaml").exists():
        return "pnpm"
    if (root / "yarn.lock").exists():
        return "yarn"
    if (root / "bun.lock").exists() or (root / "bun.lockb").exists():
        return "bun"
    if (root / "package-lock.json").exists():
        return "npm"
    return "unknown"


def read_package_scripts(root: Path) -> dict[str, object]:
    package_json = root / "package.json"
    if not package_json.exists():
        return {}
    try:
        payload = json.loads(package_json.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    scripts = payload.get("scripts", {})
    return scripts if isinstance(scripts, dict) else {}


def diagnose(root: Path) -> dict[str, object]:
    node_binary = shutil.which("node")
    node_info = run(["node", "--version"], root) if node_binary else {
        "command": ["node", "--version"],
        "exit_code": 127,
        "stdout": "",
        "stderr": "node binary not found",
    }
    scripts = read_package_scripts(root)
    pm = package_manager(root)
    return {
        "target_dir": str(root),
        "node_binary": node_binary or "",
        "node_available": node_info.get("exit_code") == 0,
        "node_info": node_info,
        "package_json": (root / "package.json").exists(),
        "package_manager": pm,
        "scripts_detected": sorted(scripts.keys()),
        "has_lint": "lint" in scripts,
        "has_typecheck": "typecheck" in scripts,
        "has_unit_test": "test" in scripts,
        "has_build": "build" in scripts,
        "has_e2e": "e2e" in scripts or "test:e2e" in scripts,
    }


def render_text(result: dict[str, object]) -> str:
    lines = [
        "Frontend doctor:",
        f"- target_dir: {result.get('target_dir')}",
        f"- node_binary: {result.get('node_binary') or 'missing'}",
        f"- node_available: {result.get('node_available')}",
        f"- package_json: {result.get('package_json')}",
        f"- package_manager: {result.get('package_manager')}",
        f"- scripts_detected: {', '.join(result.get('scripts_detected') or []) or 'none'}",
        f"- has_lint: {result.get('has_lint')}",
        f"- has_typecheck: {result.get('has_typecheck')}",
        f"- has_unit_test: {result.get('has_unit_test')}",
        f"- has_build: {result.get('has_build')}",
        f"- has_e2e: {result.get('has_e2e')}",
    ]
    node_info = result.get("node_info", {}) if isinstance(result.get("node_info"), dict) else {}
    if node_info.get("exit_code") != 0:
        lines.append(f"- node_error: {node_info.get('stderr', '').strip()}")
    return "\n".join(lines)


def main():
    args = parse_args()
    root = Path(args.target_dir).resolve()
    if root.name == ".harness":
        root = root.parent
    result = diagnose(root)
    if args.format == "json":
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        print(render_text(result))
    if args.require_node and not result.get("node_available"):
        sys.exit(1)


if __name__ == "__main__":
    main()
