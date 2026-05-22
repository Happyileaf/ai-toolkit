#!/usr/bin/env python3
"""
Codex hook/CLI: check frontend conventions on changed files.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

FRONTEND_EXTENSIONS = {
    ".ts",
    ".tsx",
    ".js",
    ".jsx",
    ".css",
    ".scss",
    ".less",
    ".html",
    ".vue",
    ".svelte",
}

IGNORED_PARTS = {
    ".git",
    ".idea",
    ".vscode",
    "node_modules",
    ".next",
    "dist",
    "build",
    "coverage",
    "storybook-static",
}

RULE_CARD = [
    "前端门禁：",
    "1. 禁止硬编码 URL、token、秘钥；环境差异必须来自配置或 env。",
    "2. React 列表渲染禁止使用 index 作为 key（静态列表除外）。",
    "3. 非装饰性图片必须有可读 alt 文本；交互元素必须可键盘触达。",
    "4. 颜色、间距、字号禁止散落魔法值，优先使用 design token/CSS 变量。",
    "5. 删除调试代码（console/debugger/临时注释掉逻辑）后才能收口。",
    "6. 不在业务代码里直接操作 localStorage/sessionStorage 关键路径而无错误兜底。",
    "7. 修改 UI 状态流时，必须明确加载态、空态、错误态。",
]


@dataclass
class Finding:
    severity: str
    rule: str
    path: str
    line: int
    message: str
    snippet: str

    def to_dict(self):
        return {
            "severity": self.severity,
            "rule": self.rule,
            "path": self.path,
            "line": self.line,
            "message": self.message,
            "snippet": self.snippet,
        }


def repo_root() -> Path:
    try:
        output = subprocess.check_output(
            ["git", "rev-parse", "--show-toplevel"],
            stderr=subprocess.DEVNULL,
            timeout=5,
        )
        return Path(output.decode().strip())
    except (subprocess.CalledProcessError, FileNotFoundError, subprocess.TimeoutExpired):
        return Path.cwd()


def is_relevant(path: Path) -> bool:
    return path.suffix.lower() in FRONTEND_EXTENSIONS


def is_ignored(path: Path) -> bool:
    return any(part in IGNORED_PARTS for part in path.parts)


def git_changed_files(root: Path) -> list[Path]:
    commands = [
        ["git", "diff", "--name-only", "--diff-filter=ACMRT", "HEAD"],
        ["git", "diff", "--name-only", "--cached", "--diff-filter=ACMRT", "HEAD"],
        ["git", "ls-files", "--others", "--exclude-standard"],
    ]
    seen = set()
    files = []
    for command in commands:
        try:
            output = subprocess.check_output(command, cwd=root, stderr=subprocess.DEVNULL, timeout=10)
        except (subprocess.CalledProcessError, FileNotFoundError, subprocess.TimeoutExpired):
            continue
        for raw in output.decode().splitlines():
            rel = raw.strip()
            if not rel or rel in seen:
                continue
            seen.add(rel)
            path = root / rel
            if path.is_file() and is_relevant(path) and not is_ignored(path):
                files.append(path)
    return files


def all_relevant_files(root: Path) -> list[Path]:
    files = []
    for path in root.rglob("*"):
        if not path.is_file() or not is_relevant(path):
            continue
        if is_ignored(path):
            continue
        files.append(path)
    return files


def rel_path(root: Path, path: Path) -> str:
    try:
        return str(path.relative_to(root))
    except ValueError:
        return str(path)


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return path.read_text(encoding="utf-8", errors="ignore")


def add_finding(
    findings: list[Finding],
    severity: str,
    rule: str,
    root: Path,
    path: Path,
    line_no: int,
    message: str,
    line: str,
):
    findings.append(
        Finding(
            severity=severity,
            rule=rule,
            path=rel_path(root, path),
            line=line_no,
            message=message,
            snippet=line.strip()[:180],
        )
    )


URL_RE = re.compile(r"https?://[^\s\"')]+", re.IGNORECASE)
TOKEN_RE = re.compile(r"(token|secret|api[_-]?key|access[_-]?key)\s*[:=]\s*['\"][^'\"]+['\"]", re.IGNORECASE)
CSS_MAGIC_RE = re.compile(r"\b\d+(?:px|rem|em|vh|vw)\b")
HEX_COLOR_RE = re.compile(r"#[0-9a-fA-F]{3,8}\b")


def scan_file(root: Path, path: Path, findings: list[Finding]) -> None:
    text = read_text(path)
    lines = text.splitlines()
    suffix = path.suffix.lower()
    path_lower = str(path).lower()

    for index, line in enumerate(lines, start=1):
        lowered = line.lower()

        if "console.log(" in lowered or "debugger;" in lowered:
            add_finding(
                findings,
                "warn",
                "FE_DEBUG_REMAINS",
                root,
                path,
                index,
                "请在收口前移除调试输出/断点。",
                line,
            )

        if TOKEN_RE.search(line):
            add_finding(
                findings,
                "fail",
                "FE_HARDCODED_SECRET",
                root,
                path,
                index,
                "发现疑似硬编码 token/secret/apiKey，请改为环境配置。",
                line,
            )

        if URL_RE.search(line) and "localhost" not in lowered and "127.0.0.1" not in lowered:
            if ".md" not in path_lower and "test" not in path_lower:
                add_finding(
                    findings,
                    "warn",
                    "FE_HARDCODED_URL",
                    root,
                    path,
                    index,
                    "业务代码中出现硬编码 URL，请确认是否应走配置层。",
                    line,
                )

        if suffix in {".ts", ".tsx", ".js", ".jsx"}:
            if "map(" in line and "key={index}" in line:
                add_finding(
                    findings,
                    "fail",
                    "FE_REACT_INDEX_KEY",
                    root,
                    path,
                    index,
                    "React 列表渲染不要使用 index 作为 key（静态列表除外）。",
                    line,
                )

            if "<img" in line and "alt=" not in line:
                add_finding(
                    findings,
                    "warn",
                    "FE_IMG_ALT_MISSING",
                    root,
                    path,
                    index,
                    "图片元素缺少 alt，非装饰图片应提供可读替代文本。",
                    line,
                )

            if "localstorage." in lowered or "sessionstorage." in lowered:
                if "try" not in "\n".join(lines[max(0, index - 3): index + 2]).lower():
                    add_finding(
                        findings,
                        "warn",
                        "FE_STORAGE_NO_GUARD",
                        root,
                        path,
                        index,
                        "localStorage/sessionStorage 访问建议加异常兜底与不可用场景处理。",
                        line,
                    )

        if suffix in {".css", ".scss", ".less"}:
            if CSS_MAGIC_RE.search(line) and "var(" not in line and "--" not in line:
                add_finding(
                    findings,
                    "warn",
                    "FE_CSS_MAGIC_VALUE",
                    root,
                    path,
                    index,
                    "样式出现裸尺寸，建议使用 token/CSS 变量收口。",
                    line,
                )
            if HEX_COLOR_RE.search(line) and "var(" not in line:
                add_finding(
                    findings,
                    "warn",
                    "FE_CSS_MAGIC_COLOR",
                    root,
                    path,
                    index,
                    "样式出现裸色值，建议使用设计系统变量。",
                    line,
                )


def scan_files(root: Path, files: list[Path]) -> list[Finding]:
    findings: list[Finding] = []
    for path in files:
        scan_file(root, path, findings)
    return findings


def format_text(findings: list[Finding], files: list[Path]) -> str:
    if not findings:
        return f"Convention check passed ({len(files)} changed relevant files scanned)."

    fails = [item for item in findings if item.severity == "fail"]
    warns = [item for item in findings if item.severity == "warn"]
    lines = [*RULE_CARD, "", f"规范检查在 {len(files)} 个相关文件中发现 {len(fails)} 个 FAIL、{len(warns)} 个 WARN。"]
    for item in findings[:80]:
        label = "FAIL" if item.severity == "fail" else "WARN"
        lines.append(f"- [{label}] {item.path}:{item.line} {item.rule}: {item.message}")
        if item.snippet:
            lines.append(f"  `{item.snippet}`")
    if len(findings) > 80:
        lines.append(f"- ... 还有 {len(findings) - 80} 个问题未展示。")
    if fails:
        lines.append("")
        lines.append("现在不要结束任务。请先修复 FAIL 项，重新运行检查后再继续。")
    if warns:
        lines.append("WARN 项建议修复，或在最终回复里说明风险接受原因。")
    return "\n".join(lines)


def emit_hook(findings: list[Finding], files: list[Path]) -> None:
    text = format_text(findings, files)
    fails = [item for item in findings if item.severity == "fail"]
    warns = [item for item in findings if item.severity == "warn"]
    if fails:
        print(json.dumps({"decision": "block", "reason": text}, ensure_ascii=False))
        return
    if warns:
        print(json.dumps({"systemMessage": text}, ensure_ascii=False))
        return
    print(json.dumps({}))


def parse_args():
    parser = argparse.ArgumentParser(description="Check frontend coding conventions.")
    parser.add_argument("--changed-only", action="store_true", help="scan changed files only")
    parser.add_argument("--format", choices=["text", "json", "hook"], default="text")
    return parser.parse_args()


def should_run_hook() -> bool:
    raw = sys.stdin.read()
    if not raw.strip():
        return True
    try:
        payload = json.loads(raw)
    except (json.JSONDecodeError, ValueError):
        return True
    if payload.get("hook_event_name") == "Stop":
        return True
    if payload.get("tool_name") == "TaskUpdate":
        tool_input = payload.get("tool_input", {})
        return isinstance(tool_input, dict) and tool_input.get("status") == "completed"
    return True


def main():
    args = parse_args()
    if args.format == "hook" and not should_run_hook():
        print(json.dumps({}))
        return

    root = repo_root()
    files = git_changed_files(root) if args.changed_only else all_relevant_files(root)
    findings = scan_files(root, files)

    if args.format == "json":
        print(
            json.dumps(
                {
                    "files_scanned": [rel_path(root, path) for path in files],
                    "findings": [item.to_dict() for item in findings],
                },
                ensure_ascii=False,
                indent=2,
            )
        )
    elif args.format == "hook":
        emit_hook(findings, files)
    else:
        print(format_text(findings, files))

    if args.format != "hook" and any(item.severity == "fail" for item in findings):
        sys.exit(1)


if __name__ == "__main__":
    main()
