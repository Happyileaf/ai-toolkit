# Step 01: Bootstrap Local Frontend

## Goal

启动本地前端项目并确认 `local_url` 可访问。

## Actions

1. 进入 `local_project_root`。
2. 探测可用启动命令，优先：
   1. `npm run dev`
   2. `pnpm dev`
   3. `yarn dev`
   4. `npm start`
3. 若端口冲突，使用实际启动端口更新 `local_url`。
4. 访问 `local_url` 验证页面可打开。

## Output

- 启动命令
- 实际 `local_url`
- 启动异常（如有）

