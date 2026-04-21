---
name: export-bundle
description: 将项目中的 rules、skills、workflows 按最小可分发原则打包为 zip，用于分享给其他人；支持只打包指定子目录，并在完成后清理中间目录。
---

# Export Bundle

用于将仓库中的 `rules/`、`skills/`、`workflows/` 选择性打包给外部使用者，而不泄露整个项目。

## Inputs

- `project_root`: 项目根目录（必填）
- `bundle_name`: 压缩包名称前缀（必填）
- `rules_paths`: 需要导出的 rules 相对路径列表（可选）
- `skills_paths`: 需要导出的 skills 相对路径列表（可选）
- `workflows_paths`: 需要导出的 workflows 相对路径列表（可选）
- `include_readme`: 是否复制三个顶层 README（默认 `true`）
- `cleanup_staging`: 打包后是否删除中间目录（默认 `true`）

至少提供 `rules_paths / skills_paths / workflows_paths` 其中一项，支持任意组合。

## Staging Layout

在 `${project_root}/bundles/${bundle_name}/` 创建临时目录，结构如下：

```text
bundles/<bundle_name>/
├── rules/
├── skills/
└── workflows/
```

仅复制用户指定的子目录或文件。

## Packaging Steps

1. 准备 staging 目录（若存在同名目录，先删除重建）。
2. 按输入列表复制对应内容到 staging。
3. 可选复制：
   - `rules/README.md`
   - `skills/README.md`
   - `workflows/README.md`
4. **路径转换**：将 staging 目录中所有 `.md` 文件内的绝对路径转换为相对路径：
   - 将 `${project_root}/skills/` 替换为 `../../skills/`
   - 将 `${project_root}/workflows/` 替换为 `../../workflows/`
   - 将 `${project_root}/rules/` 替换为 `../../rules/`
5. 生成 zip：
   - 输出路径：`${project_root}/bundles/${bundle_name}-<timestamp>.zip`
6. 若 `cleanup_staging=true`，删除 staging 目录，仅保留 zip。

## Command Template

```bash
set -e
cd <project_root>

bundle_name="<bundle_name>"
staging="bundles/${bundle_name}"
archive="bundles/${bundle_name}-$(date +%Y%m%d-%H%M%S).zip"

rm -rf "$staging"
mkdir -p "$staging/rules" "$staging/skills" "$staging/workflows"

# 示例：复制指定内容（按需替换）
cp -R rules/<rule_path_a> "$staging/rules/"
cp -R skills/<skill_path_a> "$staging/skills/"
cp -R workflows/<workflow_path_a> "$staging/workflows/"

# 可选 README
cp rules/README.md "$staging/rules/README.md" || true
cp skills/README.md "$staging/skills/README.md" || true
cp workflows/README.md "$staging/workflows/README.md" || true

# 路径转换：将绝对路径替换为相对路径
# 获取项目根目录的绝对路径用于替换
project_root_abs="<project_root>"
find "$staging" -name "*.md" -type f -exec sed -i '' \
  -e "s|${project_root_abs}/skills/|../../skills/|g" \
  -e "s|${project_root_abs}/workflows/|../../workflows/|g" \
  -e "s|${project_root_abs}/rules/|../../rules/|g" {} \;

(cd bundles && zip -r "$(basename "$archive")" "$bundle_name" >/dev/null)

# 可选清理
rm -rf "$staging"

echo "$archive"
```

## Validation Checklist

打包后必须检查：

1. `unzip -l <archive>` 确认仅包含目标文件
2. 无无关源码、无 `.git`、无敏感配置
3. 路径完整可用（入口 workflow 和依赖 skill 都在）

## Copy-Paste Prompt

```text
请使用 export-bundle 打包以下内容：
- project_root: /absolute/path/to/project
- bundle_name: ui-prototype-restore-loop-bundle
- rules_paths: []
- skills_paths:
  - agent-browser-0.2.0
  - ui-prototype-restore
  - ui-gap-audit
  - ui-restore-implementation
- workflows_paths:
  - ui-prototype-restore-loop
- include_readme: true
- cleanup_staging: true
```

