# 人工智能训练师五级练习与考试系统

面向职业培训学校、失业人员、高校毕业生及其他零基础社会学员的完整 Web 培训考试系统。练习库与正式考试库物理分离，覆盖理论题与 13 种实操题型，全部使用确定性评分器自动判分（正式成绩不依赖任何 LLM/网络/随机数）。

## 当前版本

`1.0.0-rc.2`。已经过多轮全角色层深度审核与自动化回归（API 安全、评分正确性、越权、事务、信息泄露、强制改密）。正式上线前仍需在目标环境执行完整安装、迁移、构建与并发验收，详见 `docs/TEST_REPORT.md`。

## 核心能力

- 零基础学员友好界面：大字号、少步骤、温和鼓励式反馈。
- 理论题：单选、判断，即时练习与正式考试。
- 实操题（练习与考试同构，13 种）：
  - 数据清洗：Excel 删行、图片数据清洗、数据集质量体检
  - 图片标注：矩形框（含属性）、点、折线、多边形
  - 文本标注：情感标注、通用图文数据分类
  - 其他：文件分类、音频转写（校验语气助词）、统计填表、综合任务
- 考试安全：服务端时间权威、心跳、自动保存（含关页 keepalive 兜底）、断线续考、幂等交卷。
- 组卷即冻结：题目快照、答案键、素材 checksum、评分器版本全部固化，改题库不影响已发试卷。
- 多机构 RBAC（8 种角色）、职责分离（编辑不能审自己的题）、审计日志、成绩复核与发布门禁。
- 账号安全：初始密码一次性展示、首次登录强制改密（服务端 428 门控 + 改密页闭环）、停用/启用、角色回收事务化。

## 技术栈

Next.js 16 (App Router) · React 19 · TypeScript 5 (strict) · Tailwind CSS 4 · shadcn/ui · Supabase (Postgres + Auth, RLS 全表 deny) · node-pg · Vitest · ExcelJS

## 本地启动

```bash
cp .env.example .env.local   # 填入 Supabase / PGDATABASE_URL 等配置
pnpm install --frozen-lockfile
pnpm db:migrate
pnpm db:seed-core            # 生产环境必须先设 SEED_ADMIN_PASSWORD
pnpm db:seed-questions       # 可选: 从 DOCX 导入理论题
pnpm db:seed-tasks           # 实操题种子(练习库+考试库)
pnpm dev                     # http://localhost:5000
```

新建账号的初始密码由加密安全随机数生成，只在创建时输出一次，首次登录强制修改。仓库不包含固定默认密码。

## 测试账号（种子环境）

| 角色 | 邮箱 | 说明 |
|------|------|------|
| 学员 | `stu001@student.exam.local` / `stu002@student.exam.local` | 密码见种子输出 |
| 超级管理员 | `admin@exam.local` | 密码为首次运行 `seed-core` 时输出（或 `SEED_ADMIN_PASSWORD`） |
| 学校管理员 | `school@exam.local` | 同上 |
| 教师 / 编辑 / 审核 / 监考 / 审计 | `teacher01` / `editor01` / `reviewer01` / `invig01` / `auditor01@exam.local` | 同上 |

## 质量检查与回归验证

```bash
pnpm ts-check          # TypeScript 严格检查
pnpm lint:build        # ESLint
pnpm test              # 评分器单元测试(Vitest)
pnpm validate          # 完整质量门禁(含构建)

# 端到端回归矩阵(需 dev server 运行在 5000 端口, 连真实数据库)
pnpm tsx scripts/db/verify-api.mts         # 管理/教师端 45 例: 权限/越权/用户生命周期/强制改密门控/导出
pnpm tsx scripts/db/verify-student.mts     # 学员端 19 例: 练习闭环/考试入口/防刷分/信息泄露探针
pnpm tsx scripts/db/verify-tasks.mts       # 题库契约 32 例: 满分提交必须满分/空卷不得分
pnpm tsx scripts/db/verify-exam-flow.mts   # 交卷全链路 21 例: 组卷→开考→交卷→DB 层核验, 自动清理
```

验证脚本在共享数据库上遵循严格纪律：临时数据自动清理，真实业务数据零污染。

## 目录结构

```text
src/app/                    页面(学员/教师/管理/登录/改密)与 API 路由
src/components/             业务组件(exam-task-input 实操作答组件库)与 shadcn/ui
src/lib/                    apiFetch(带 auth/428 跳改密)/constants/api 助手
src/server/                 认证/DB/审计/题库/用户管理/考试安全
src/server/grading/         确定性评分引擎(15 个评分器)
src/server/media/           图片/音频 Provider 适配器
src/storage/                Supabase 客户端(service role, 仅服务端)
drizzle/                    数据库迁移
scripts/db/                 迁移/种子/回归验证脚本(_env.mjs 公共环境加载)
public/training/            演示素材(SVG/AI 生成图/TTS 音频)
docs/                       架构/部署/安全/评分规范/用户手册/测试报告
.github/workflows/          CI 质量门禁
```

## 关键安全原则

- 正式考试不读取练习库，不存在回退抽题。
- 客户端不能决定评分器、答案键、分值或及格线。
- 正式评分不调用 LLM、ASR 或图像识别模型。
- 试卷快照在组卷时冻结，考试进行中不下发答案与解析。
- 成绩在管理员发布前对学员不可见（学员端三重门禁）。
- service-role 数据库操作必须附带机构范围校验；RLS 对 anon/authenticated 全表拒绝。
- 强制改密由服务端 428 门控保证，不依赖前端自觉。

## 文档

- `docs/ARCHITECTURE.md` — 架构与数据流
- `docs/DEPLOYMENT.md` — 部署手册
- `docs/SECURITY.md` — 安全设计
- `docs/GRADING_SPEC.md` — 评分器规范
- `docs/QUESTION_BANK_GUIDE.md` — 题库管理指南
- `docs/USER_MANUAL_STUDENT.md` / `docs/USER_MANUAL_ADMIN.md` — 用户手册
- `docs/TEST_REPORT.md` — 测试报告
