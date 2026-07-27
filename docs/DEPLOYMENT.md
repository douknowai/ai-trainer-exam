# 部署说明

## 1. 环境

推荐 Coze Vibe Coding / Next.js App Router，Node.js 22.13+、pnpm 11.17+、Supabase PostgreSQL 和 S3 兼容对象存储。复制 `.env.example` 并填入环境变量，密钥不得提交到仓库。

## 2. 安装与质量门禁

```bash
pnpm install --frozen-lockfile
pnpm validate
```

`validate` 会依次执行离线安全门禁、TypeScript、ESLint、Stylelint、Vitest 和生产构建。

## 3. 数据库

```bash
pnpm db:migrate
pnpm db:seed-core
pnpm db:seed-tasks
```

生产执行 `db:seed-core` 前设置 `SEED_ADMIN_PASSWORD`。输出的随机初始密码应立即存入密码管理器，并要求首次登录修改。

## 4. 题库导入

后台可上传最大 10MB 的 DOCX，或运行：

```bash
pnpm db:seed-questions -- /path/to/questions.docx
```

导入内容进入 `imported_unreviewed`，必须人工审核后才能发布。法律法规题自动标记时效复核。

学员名册仅接受 `.xlsx`，不再接受旧版 `.xls`；这样可以使用受维护的 ExcelJS 解析并避免无修复版本解析器带来的安全风险。

## 5. 媒体 Provider

优先配置 `IMAGE2_API_*` 和 `MIMO_LECTURE_AUDIO_*`。未配置时，可在 Coze 环境使用 SDK Provider。所有素材仍需对象存储、checksum 和人工审核。

## 6. 上线验证

- 管理员创建机构、班级和用户。
- 练习题与考试题分别导入、审核、发布。
- 创建含理论及所有实操类型的试卷并发布。
- 创建考试安排，核对练习锁定、考试开放和成绩发布时间。
- 学员完成设备检查、刷新恢复、断线重连和交卷。
- 管理员复核并发布成绩。
- 导出审计和成绩报表。

## 7. 回滚

数据库迁移前必须备份。发生应用故障时回滚应用部署；涉及不可逆数据迁移时从备份恢复，禁止直接在生产库手工删除考试记录。
