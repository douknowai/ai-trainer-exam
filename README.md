# 人工智能训练师五级零基础练习与考试系统

面向职业培训学校零基础学员的练习与考试一体化平台。服务三类角色：**零基础学员**、**教师**、**超级管理员**，覆盖理论练习、实操任务、在线考试、自动阅卷、成绩管理与数据报表全流程。

> 设计意象：培训教室里的护眼绿黑板 + 干净白色练习册 + 老师的大字板书。耐心、稳重、可信赖。

---

## 目录

- [功能概览](#功能概览)
- [技术栈](#技术栈)
- [项目结构](#项目结构)
- [快速开始](#快速开始)
- [环境变量](#环境变量)
- [测试账号](#测试账号)
- [核心设计](#核心设计)
- [开发命令](#开发命令)
- [文档索引](#文档索引)
- [许可协议](#许可协议)

---

## 功能概览

### 学员端

| 模块 | 说明 |
|------|------|
| 理论练习 | 按题型/知识点练习，即时判分，温和鼓励反馈 |
| 实操任务 | 数据清洗、图片标注、文本情感、音频转写等 12 类实操任务 |
| 错题本 | 自动收录错题，支持重做 |
| 在线考试 | 服务端时间锁、自动倒计时交卷、超时自动判 expired |
| 成绩查询 | 历次成绩与通过状态 |

### 教师端

| 模块 | 说明 |
|------|------|
| 仪表盘 | 班级概况与关键指标 |
| 考试管理 | 创建/管理考试安排 |
| 学员管理 | 查看班级学员列表与进度 |

### 管理端

| 模块 | 说明 |
|------|------|
| 系统统计 | 用户/组织/考试全局概览 |
| 用户管理 | 角色分配与账号管理 |
| 组织与班级 | 多层级组织 + 班级管理 |
| 考试安排 | 排期与试卷绑定 |
| 试卷管理 | 题目组卷 |
| 成绩管理 | 列表查看、复核调分、成绩发布 |
| 数据报表 | 成绩分布、通过率、班级对比、薄弱题型分析 |
| 审计日志 | 全操作可追溯 |
| AI 媒体生成 | 图片生成 / TTS 音频（用于实操题目素材） |
| 系统设置 | 全局配置项管理 |

---

## 技术栈

| 分类 | 技术 |
|------|------|
| 框架 | Next.js 16 (App Router) |
| 核心 | React 19 |
| 语言 | TypeScript 5 (strict) |
| UI 组件 | shadcn/ui (基于 Radix UI) |
| 样式 | Tailwind CSS 4 |
| 数据库 | Supabase PostgreSQL + RLS 行级安全 |
| 认证 | Supabase Auth (email/password) |
| 通知 | sonner |

---

## 项目结构

```
├── public/                     # 静态资源
├── scripts/                    # 构建/启动/校验脚本
│   └── db/                     # 数据库种子与迁移脚本
├── docs/                       # 项目文档（架构/数据模型/评分规范等）
├── drizzle/                    # Drizzle ORM 数据库迁移文件
├── src/
│   ├── app/                    # 页面路由与布局
│   │   ├── admin/              # 管理员端
│   │   ├── api/                # API 路由 (auth/student/teacher/admin)
│   │   ├── login/              # 登录页
│   │   └── student/            # 学员端 (exams/practice/results/task/wrong)
│   ├── components/             # 业务组件 + shadcn/ui 组件库
│   ├── hooks/                  # 自定义 Hooks
│   ├── lib/                    # 工具库 (api/session-client/utils)
│   ├── server/                 # 服务端逻辑
│   │   ├── auth.ts             # 认证与会话
│   │   ├── audit.ts            # 审计日志
│   │   ├── db.ts               # 数据库查询封装
│   │   ├── docx-importer.ts    # DOCX 题库导入解析
│   │   ├── grading/            # 12 个评分器 + gradeByType 统一入口
│   │   └── question-bank.ts    # 题库 CRUD
│   └── storage/                # 存储层 (Supabase 客户端)
├── .coze                       # 部署配置（构建与启动命令，必须入库）
├── AGENTS.md                   # AI 协作规范文件
├── DESIGN.md                   # 设计规范文件
└── README.md
```

---

## 快速开始

### 前置要求

- Node.js 24+
- pnpm（包管理器）
- Supabase 项目（需提供连接凭证）

### 安装与启动

```bash
# 安装依赖
pnpm install

# 启动开发服务器（默认端口 5000）
pnpm run dev
```

启动后在浏览器打开 `http://localhost:5000` 查看应用。开发服务器支持热更新。

### 生产构建

```bash
pnpm run build    # 构建
pnpm run start    # 启动生产服务器
```

---

## 环境变量

所有密钥与连接凭证通过环境变量注入，**绝不硬编码入库**。项目启动时会自动从运行时环境读取：

| 变量名 | 说明 |
|--------|------|
| `COZE_SUPABASE_URL` | Supabase 项目 URL |
| `COZE_SUPABASE_ANON_KEY` | Supabase 匿名密钥 |
| `COZE_SUPABASE_SERVICE_ROLE_KEY` | Supabase 服务端密钥（绕过 RLS） |
| `DEPLOY_RUN_PORT` | 服务监听端口（默认 5000） |

> 本地开发时可将变量写入 `.env.local`（已被 `.gitignore` 忽略，不会入库）。

---

## 测试账号

| 角色 | 邮箱 | 密码 |
|------|------|------|
| 超级管理员 | admin@exam.local | Admin@2026 |
| 学校管理员 | school@exam.local | School@2026 |
| 教师 | teacher01@exam.local | Teacher@2026 |
| 学员 | stu001@student.exam.local | abcd2345 |
| 学员 | stu002@student.exam.local | efgh6789 |
| 题库编辑 | editor01@exam.local | Editor@2026 |
| 题库审核 | reviewer01@exam.local | Review@2026 |

---

## 核心设计

### 评分引擎

采用 12 个纯函数确定性评分器，统一入口 `gradeByType(type, submission, answerKey)`：

```
singleChoice · trueFalse · excelDeleteRows · statsTableFill · fileClassification
imageCleaning · imageAnnotation · textSentiment · audioTranscription
dataComparison · labelConsistency · modelEvaluation
```

### 考试时间锁

- 开始考试时服务端校验 `exam_start_at <= NOW()`
- 交卷时服务端校验 `NOW() <= exam_end_at`，超时自动判为 `expired`
- 客户端倒计时到期自动提交

### 数据安全

- Supabase RLS 行级安全策略
- 所有敏感操作记录审计日志
- 密钥通过环境变量注入，不入库

---

## 开发命令

```bash
pnpm install          # 安装依赖
pnpm run dev          # 启动开发服务器
pnpm run build        # 生产构建
pnpm run start        # 启动生产服务器
pnpm ts-check         # TypeScript 类型检查
pnpm lint --quiet     # ESLint 检查
```

---

## 文档索引

| 文档 | 说明 |
|------|------|
| [AGENTS.md](AGENTS.md) | AI 协作规范（API 清单、编码约定、数据库约定） |
| [DESIGN.md](DESIGN.md) | 设计规范（配色、字体、交互、设计禁忌） |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 系统架构设计 |
| [docs/DATA_MODEL.md](docs/DATA_MODEL.md) | 数据模型设计 |
| [docs/GRADING_SPEC.md](docs/GRADING_SPEC.md) | 确定性评分引擎规范 |
| [docs/QUESTION_BANK_GUIDE.md](docs/QUESTION_BANK_GUIDE.md) | 题库建设与导入规范 |
| [docs/PROJECT_PLAN.md](docs/PROJECT_PLAN.md) | 项目计划与里程碑 |
| [docs/DECISIONS.md](docs/DECISIONS.md) | 工程决策记录 |
| [docs/STATUS.md](docs/STATUS.md) | 项目状态（持续更新） |
| [docs/USER_MANUAL.md](docs/USER_MANUAL.md) | 用户使用说明书 |

---

## 许可协议

本项目为内部教学使用，未设开源许可。
