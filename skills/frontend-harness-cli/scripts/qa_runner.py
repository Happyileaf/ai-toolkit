#!/usr/bin/env python3
"""
Run frontend-harness QA commands and generate gate reports.

This runner is the single entry point intended for local use and future CI jobs.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

import qa_report  # noqa: E402
import testcontainers_doctor  # noqa: E402

STATUS_PASS = "PASS"
STATUS_FAIL = "FAIL"
STATUS_SKIP = "SKIP"
GATE_REQUIRED = "required"
GATE_ADVISORY = "advisory"


def parse_args():
    parser = argparse.ArgumentParser(description="Run frontend-harness QA gate.")
    parser.add_argument("--target-dir", default=".", help="目标项目目录")
    parser.add_argument("--contract", default="", help="契约文件路径；为空时选择最新 contract")
    parser.add_argument("--feature-id", default="", help="任务/feature ID")
    parser.add_argument("--output-md", default="", help="输出 Markdown QA 报告路径")
    parser.add_argument("--output-json", default="", help="输出机器可读 QA result JSON 路径")
    parser.add_argument("--skip-convention", action="store_true", help="跳过 convention-check")
    parser.add_argument("--skip-lint", action="store_true", help="跳过前端 lint")
    parser.add_argument("--skip-typecheck", action="store_true", help="跳过前端 typecheck")
    parser.add_argument("--skip-unit", action="store_true", help="跳过前端单元测试")
    parser.add_argument("--skip-build", action="store_true", help="跳过前端构建")
    parser.add_argument("--skip-e2e", action="store_true", help="跳过前端 e2e")
    parser.add_argument("--skip-test", action="store_true", help="兼容参数：等价于 --skip-unit")
    parser.add_argument("--skip-verify", action="store_true", help="兼容参数：等价于 --skip-build")
    parser.add_argument(
        "--agent-review",
        default=os.environ.get("FRONTEND_HARNESS_AGENT_REVIEW", "auto"),
        choices=("auto", "codex", "claude", "off"),
        help="运行 Agent Review Closeout；默认 auto",
    )
    parser.add_argument("--agent-review-required", action="store_true", help="将 agent review 作为 required 门禁")
    parser.add_argument(
        "--agent-review-mode",
        default="auto",
        choices=("auto", "local", "branch", "commit"),
        help="agent review target selection",
    )
    parser.add_argument("--agent-review-base", default="", help="agent review branch base ref")
    parser.add_argument("--agent-review-commit", default="", help="agent review commit ref")
    parser.add_argument("--agent-review-full-access", action="store_true", help="agent review 使用完整本地权限")
    parser.add_argument("--skip-agent-review", action="store_true", help="跳过 agent review closeout")
    parser.add_argument("--no-fail", action="store_true", help="即使 gate FAIL 也返回 0")
    return parser.parse_args()


def repo_root(target_dir: Path) -> Path:
    current = target_dir.resolve()
    return current.parent if current.name == ".harness" else current


def resolve_path(target_dir: Path, raw: str) -> Path:
    return qa_report.resolve_path(target_dir, raw)


def tail(text: str, limit: int = 6000) -> str:
    return (text or "")[-limit:]


def run_command(name: str, command: list[str], cwd: Path, timeout: int | None = None) -> dict[str, object]:
    try:
        completed = subprocess.run(
            command,
            cwd=str(cwd),
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=timeout,
        )
        status = STATUS_PASS if completed.returncode == 0 else STATUS_FAIL
        return {
            "name": name,
            "command": command,
            "exit_code": completed.returncode,
            "status": status,
            "summary": command_summary(name, completed.returncode),
            "stdout_tail": tail(completed.stdout),
            "stderr_tail": tail(completed.stderr),
        }
    except FileNotFoundError:
        return {
            "name": name,
            "command": command,
            "exit_code": 127,
            "status": STATUS_FAIL,
            "summary": "command not found",
            "stdout_tail": "",
            "stderr_tail": "command not found",
        }
    except subprocess.TimeoutExpired as exc:
        return {
            "name": name,
            "command": command,
            "exit_code": 124,
            "status": STATUS_FAIL,
            "summary": "command timed out",
            "stdout_tail": tail(exc.stdout if isinstance(exc.stdout, str) else ""),
            "stderr_tail": "command timed out",
        }


def skipped_command(name: str, reason: str, command: list[str] | None = None) -> dict[str, object]:
    return {
        "name": name,
        "command": command or [],
        "exit_code": None,
        "status": STATUS_SKIP,
        "gate": GATE_ADVISORY,
        "summary": reason,
        "stdout_tail": "",
        "stderr_tail": "",
    }


def command_summary(name: str, exit_code: int) -> str:
    if exit_code == 0:
        return f"{name} passed"
    return f"{name} failed"


def convention_command(root: Path) -> list[str] | None:
    candidates = [
        root / ".codex" / "hooks" / "convention-check.py",
        root / ".claude" / "hooks" / "convention-check.py",
    ]
    for path in candidates:
        if path.exists():
            return [sys.executable, str(path), "--changed-only"]
    return None


def read_package_scripts(root: Path) -> dict[str, object]:
    package_json = root / "package.json"
    if not package_json.exists():
        return {}
    try:
        payload = json.loads(package_json.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    scripts = payload.get("scripts")
    return scripts if isinstance(scripts, dict) else {}


def detect_package_manager(root: Path) -> str:
    if (root / "pnpm-lock.yaml").exists():
        return "pnpm"
    if (root / "yarn.lock").exists():
        return "yarn"
    if (root / "bun.lockb").exists() or (root / "bun.lock").exists():
        return "bun"
    return "npm"


def run_script_command(package_manager: str, script: str) -> list[str]:
    if package_manager == "yarn":
        return ["yarn", script]
    if package_manager == "bun":
        return ["bun", "run", script]
    if package_manager == "pnpm":
        return ["pnpm", "run", script]
    return ["npm", "run", script]


def write_commands_json(root: Path, commands: list[dict[str, object]]) -> Path:
    output = root / ".harness" / "docs" / "qa" / "last-commands.json"
    output.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "generated_by": "qa_runner.py",
        "generated_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "commands": commands,
    }
    output.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return output


def has_required_matrix(contract_path: Path | None) -> bool:
    if not contract_path or not contract_path.exists():
        return False
    markdown = contract_path.read_text(encoding="utf-8")
    return any(item.get("gate") == "required" for item in qa_report.parse_integration_matrix(markdown))


def run_doctor(root: Path, required: bool) -> dict[str, object]:
    result = testcontainers_doctor.diagnose(root)
    status = STATUS_PASS if result.get("node_available") and result.get("package_json") else (
        STATUS_FAIL if required else STATUS_SKIP
    )
    return {
        "name": "frontend_doctor",
        "command": [sys.executable, str(SCRIPT_DIR / "testcontainers_doctor.py"), "--target-dir", str(root)],
        "exit_code": 0 if status == STATUS_PASS else 1,
        "status": status,
        "gate": GATE_REQUIRED if required else GATE_ADVISORY,
        "summary": (
            "Node runtime and package.json available"
            if status == STATUS_PASS
            else "Frontend runtime prerequisites missing"
        ),
        "stdout_tail": json.dumps(result, ensure_ascii=False)[-6000:],
        "stderr_tail": "",
    }


def build_outputs(target_dir: Path, contract_path: Path | None, args) -> tuple[Path, Path]:
    default_md, default_json = qa_report.default_output_paths(target_dir, contract_path)
    output_md = resolve_path(target_dir, args.output_md) if args.output_md else default_md
    output_json = resolve_path(target_dir, args.output_json) if args.output_json else default_json
    return output_md, output_json


def load_json(path: Path) -> dict[str, object]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    return payload if isinstance(payload, dict) else {}


def run_agent_review(root: Path, args) -> dict[str, object]:
    gate = GATE_REQUIRED if args.agent_review_required else GATE_ADVISORY
    if args.skip_agent_review or args.agent_review == "off":
        if gate == GATE_REQUIRED:
            return {
                "name": "agent_review",
                "command": [],
                "exit_code": 1,
                "status": STATUS_FAIL,
                "gate": gate,
                "summary": "required agent review disabled",
                "stdout_tail": "",
                "stderr_tail": "",
            }
        return skipped_command("agent_review", "agent review disabled")

    result_json = root / ".harness" / "docs" / "qa" / "agent-review-last.result.json"
    raw_output = root / ".harness" / "docs" / "qa" / "agent-review-last.txt"
    command = [
        sys.executable,
        str(SCRIPT_DIR / "agent_review.py"),
        "--target-dir",
        str(root),
        "--backend",
        args.agent_review,
        "--mode",
        args.agent_review_mode,
        "--gate",
        gate,
        "--result-json",
        str(result_json),
        "--output",
        str(raw_output),
    ]
    if args.agent_review_base:
        command.extend(["--base", args.agent_review_base])
    if args.agent_review_commit:
        command.extend(["--commit", args.agent_review_commit])
    if args.agent_review_full_access:
        command.append("--full-access")

    for path in (result_json, raw_output):
        try:
            path.unlink()
        except FileNotFoundError:
            pass

    completed = subprocess.run(
        command,
        cwd=str(root),
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    result = load_json(result_json)
    result_status = str(result.get("status") or "")
    if completed.returncode != 0:
        status = STATUS_FAIL
    elif result_status in {STATUS_PASS, STATUS_FAIL, STATUS_SKIP}:
        status = result_status
    else:
        status = STATUS_FAIL
    return {
        "name": "agent_review",
        "command": command,
        "exit_code": completed.returncode,
        "status": status,
        "gate": gate,
        "summary": str(result.get("summary") or command_summary("agent_review", completed.returncode)),
        "backend": result.get("backend", args.agent_review),
        "target": result.get("target", {}),
        "result_json": str(result_json),
        "raw_output": str(raw_output),
        "accepted_findings": result.get("accepted_findings", []),
        "rejected_findings": result.get("rejected_findings", []),
        "stdout_tail": tail(completed.stdout or str(result.get("stdout_tail", ""))),
        "stderr_tail": tail(completed.stderr or str(result.get("stderr_tail", ""))),
    }


def main():
    args = parse_args()
    target_dir = Path(args.target_dir).resolve()
    root = repo_root(target_dir)
    contract_path = qa_report.resolve_contract(target_dir, args.contract)
    if args.contract and contract_path and not contract_path.exists():
        print(f"Error: contract not found: {contract_path}", file=sys.stderr)
        sys.exit(2)

    required_matrix = has_required_matrix(contract_path)
    scripts = read_package_scripts(root)
    package_manager = detect_package_manager(root)
    commands: list[dict[str, object]] = []
    commands.append(run_doctor(root, required_matrix))

    convention = convention_command(root)
    if args.skip_convention:
        commands.append(skipped_command("convention_check", "skipped by --skip-convention"))
    elif convention:
        result = run_command("convention_check", convention, root)
        result["gate"] = GATE_REQUIRED
        commands.append(result)
    else:
        commands.append(skipped_command("convention_check", "convention-check hook not found"))

    if args.skip_lint:
        commands.append(skipped_command("frontend_lint", "skipped by --skip-lint"))
    elif "lint" in scripts:
        result = run_command("frontend_lint", run_script_command(package_manager, "lint"), root)
        result["gate"] = GATE_REQUIRED
        commands.append(result)
    else:
        commands.append(skipped_command("frontend_lint", "package.json scripts.lint not found"))

    if args.skip_typecheck:
        commands.append(skipped_command("frontend_typecheck", "skipped by --skip-typecheck"))
    elif "typecheck" in scripts:
        result = run_command("frontend_typecheck", run_script_command(package_manager, "typecheck"), root)
        result["gate"] = GATE_REQUIRED
        commands.append(result)
    else:
        commands.append(skipped_command("frontend_typecheck", "package.json scripts.typecheck not found"))

    skip_unit = args.skip_unit or args.skip_test
    if skip_unit:
        commands.append(skipped_command("frontend_unit", "skipped by --skip-unit/--skip-test"))
    elif "test" in scripts:
        result = run_command("frontend_unit", run_script_command(package_manager, "test"), root)
        result["gate"] = GATE_REQUIRED
        commands.append(result)
    else:
        commands.append(skipped_command("frontend_unit", "package.json scripts.test not found"))

    skip_build = args.skip_build or args.skip_verify
    if skip_build:
        commands.append(skipped_command("frontend_build", "skipped by --skip-build/--skip-verify"))
    elif "build" in scripts:
        result = run_command("frontend_build", run_script_command(package_manager, "build"), root)
        result["gate"] = GATE_REQUIRED
        commands.append(result)
    else:
        commands.append(skipped_command("frontend_build", "package.json scripts.build not found"))

    e2e_gate = GATE_REQUIRED if required_matrix else GATE_ADVISORY
    if args.skip_e2e:
        skipped = skipped_command("frontend_e2e", "skipped by --skip-e2e")
        skipped["gate"] = e2e_gate
        commands.append(skipped)
    elif "e2e" in scripts:
        result = run_command("frontend_e2e", run_script_command(package_manager, "e2e"), root)
        result["gate"] = e2e_gate
        commands.append(result)
    elif "test:e2e" in scripts:
        result = run_command("frontend_e2e", run_script_command(package_manager, "test:e2e"), root)
        result["gate"] = e2e_gate
        commands.append(result)
    else:
        skipped = skipped_command("frontend_e2e", "package.json scripts.e2e/test:e2e not found")
        skipped["gate"] = e2e_gate
        commands.append(skipped)

    commands.append(run_agent_review(root, args))

    commands_json = write_commands_json(root, commands)
    output_md, output_json = build_outputs(target_dir, contract_path, args)
    result = qa_report.build_result(target_dir, contract_path, args.feature_id, commands)
    qa_report.dump_json(output_json, result)
    qa_report.dump_text(output_md, qa_report.render_markdown(result))

    print(f"Commands JSON: {commands_json}")
    print(f"QA result JSON: {output_json}")
    print(f"QA report: {output_md}")
    print(f"QA gate: {result.get('gate_status')}")
    if result.get("gate_status") != STATUS_PASS and not args.no_fail:
        sys.exit(1)


if __name__ == "__main__":
    main()
