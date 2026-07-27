# AGENTS.md — 项目规范

## 项目概览

人工智能训练师五级零基础练习与考试系统。服务三类用户：零基础学员、教师、超级管理员。

### 版本技术栈

- **Framework**: Next.js 16 (App Router)
- **Core**: React 19
- **Language**: TypeScript 5
- **UI 组件**: shadcn/ui (基于 Radix UI)
- **Styling**: Tailwind CSS 4
- **Database**: Supabase PostgreSQL + RLS
- **Auth**: Supabase Auth (email/password)
- **Toast**: sonner (not useToast)

## 目录结构

```
├── public/                     # 静态资源
├── scripts/db/                 # 数据库种子脚本
│   ├── seed-core.mts           # 组织/班级/用户种子
│   ├── seed-questions.mts      # 题库导入脚本
│   ├── seed-tasks.mts          # 实操任务模板种子
│   └── seed-questions-batch.mts # 理论题批量种子（30+题, practice+exam 双写）
├── src/
│   ├── app/                    # 页面路由与布局
│   │   ├── admin/              # 管理员端
│   │   ├── api/                # API 路由
│   │   │   ├── admin/          # 管理员 API
│   │   │   ├── auth/           # 认证 API
│   │   │   ├── student/        # 学员 API
│   │   │   ├── teacher/        # 教师 API
│   │   │   └── supabase-config/ # Supabase 配置
│   │   ├── login/              # 登录页
│   │   └── student/            # 学员端
│   │       ├── exams/          # 考试列表+答题
│   │       ├── home/           # 学员首页
│   │       ├── practice/       # 理论练习
│   │       ├── results/        # 成绩查询
│   │       ├── task/           # 实操任务
│   │       └── wrong/          # 错题本
│   ├── components/ui/          # Shadcn UI 组件库
│   ├── components/             # 业务组件
│   │   ├── app-shell.tsx       # 角色识别 Shell
│   │   ├── role-layout.tsx     # 通用角色布局
│   │   └── student-topbar.tsx  # 学员顶栏
│   ├── hooks/                  # 自定义 Hooks
│   ├── lib/                    # 工具库
│   │   ├── api.ts              # ok()/fail() 响应助手
│   │   ├── session-client.ts   # apiFetch (带 auth header)
│   │   └── utils.ts            # cn() 等
│   ├── server/                 # 服务端逻辑
│   │   ├── auth.ts             # 认证: getSessionUser/requireUser/requireRole
│   │   ├── audit.ts            # 审计日志: insertAudit/bulkInsertAudit
│   │   ├── db.ts                # dbQuery<T>/dbExec/dbOne/dbTx/dbNow
│   │   ├── docx-importer.ts    # DOCX 题库导入解析
│   │   ├── grading/            # 12个评分器 + gradeByType 统一入口
│   │   ├── question-bank.ts    # 题库 CRUD (VIEW读/实际表写)
│   │   └── users.ts            # 用户管理
│   └── storage/                # 存储层
│       └── database/
│           └── supabase-client.ts  # Supabase 客户端
├── next.config.ts
├── package.json
└── tsconfig.json
```

## 构建和测试命令

```bash
pnpm install          # 安装依赖
pnpm lint --quiet     # ESLint 检查
pnpm ts-check         # TypeScript 类型检查
pnpm run dev          # 开发启动 (端口 5000)
pnpm run build        # 生产构建
```

## 关键约定

### 数据库

- **dbQuery\<T\>(sql, ...params)**: 返回 `T[]`（展开参数，非数组）
- **dbExec(sql, ...params)**: 返回 `number`（rowCount）
- 题库读用 `question_items` VIEW（UNION practice + exam），写操作路由到实际表
- **题库同源是有意设计**（2026-07-26 豆哥确认）：驾考科目一模式——题库公开、考试题从练习库抽取（`copyToExamBank`），学员刷题备考是设计目标。练习接口显示答案、练习与考试题干一致均**不是缺陷**，审查时不要再报
- `SessionUser.roles` 是数组（非 `.role` 单值）
- `profiles.id` 即用户 ID（无 `user_id` 列）
- `enrollments.user_id`（非 `student_id`）
- `exam_schedules` 的时间列是 `exam_start_at`/`exam_end_at`（非 open/close）
- 角色类型: `'super_admin'`|`'school_admin'`|`'teacher'`|`'question_editor'`|`'question_reviewer'`|`'invigilator'`|`'student'`|`'auditor'`

### API 响应

- `ok(data)` → `Response.json({ success: true, data })`
- `fail(status, message)` → **status 在前**, message 在后

### 前端

- 使用 `apiFetch(path, options)` 自动带 Authorization header
- Toast 使用 `import { toast } from 'sonner'`
- 学员页面用 `'use client'` + `useEffect`/`useState` 防 hydration 错误
- 禁止 JSX 中直接用 `Date.now()`/`Math.random()`

### 评分引擎

- 17 个纯函数评分器（src/server/grading/index.ts 注册表）: single_choice, true_false, fill_in_blank, excel_delete_rows, stats_table, file_classify, image_clean, image_annotation, point_annotation, polyline_annotation, polygon_annotation, text_sentiment, audio_transcription, data_labeling, dataset_quality, prompt_description, composite_task, excel_comprehensive
- 任务类型 → 评分器映射 `TASK_GRADER_MAP`（15 种, bounding_box 复用 image_annotation）
- 统一入口: `gradeByType(graderId, submission, answerKey)`（理论题）/ `gradeTaskByType(taskType, ...)`（实操题）
- 三种标注评分器机制（均只接收 `(submission, answerKey)` 参数，标准答案和图片地址存储在数据库 config/answer_key 字段）:
  - **方框标注 image_annotation**: IoU 重叠度算法，默认阈值 **45%**，支持类别 + 属性匹配（v2.1.0）
  - **折线标注 polyline_annotation**: 双向 Chamfer 距离，默认阈值 **8% 图片尺寸**，等距重采样（64 点）消除点密度差异（v2.0.0）
  - **轮廓标注 polygon_annotation**: 网格栅格化多边形 IoU（80×80 采样），默认阈值 **40%**（v2.0.0）
  - 换图片换坐标只需更新数据库 answer_key，评分逻辑无需修改
- **提示词描述 prompt_description**: 学员根据图片素材撰写自然语言提示词，评分器按关键词命中率评分。answer_key 格式 `{ keywords: string[], referencePrompt?: string, passThreshold?: number }`，关键词支持 `|` 分隔同义词（如 `"猫|猫咪|小猫"`），默认通过阈值 **60%**。图片 URL 存储在 `options.image` 字段。
- **Excel 综合操作 excel_comprehensive** (v1.0.0): 模拟真实 Excel 场景，学员需完成边框设置、公式求班级、排序、分类汇总、标题着色、小数格式等操作。config 格式 `{ columns, rowIds, dataRows, classColumnIndex, scoreColumnIndices, totalColumnIndex, colorOptions }`。answer_key 格式 `{ classColumnIndex, formulaResults: Record<rowId, string>, sortedRowOrder: string[], headerColor, decimalPlaces, summaryAverages: Array<{key, averages}>, numericTolerance? }`。6 项检查等权评分（v1.0.0）。

### API 端点清单

**认证**
- `POST /api/auth/session` - 登录(返回accessToken+user)
- `GET /api/auth/session` - 获取当前用户

**学员端**
- `GET /api/student/home` - 学员首页统计
- `GET /api/student/practice/questions` - 练习题目列表
- `POST /api/student/practice/check` - 提交答案判分
- `GET /api/student/practice/wrong` - 错题本
- `GET /api/student/practice/task` - 实操任务列表
- `POST /api/student/practice/submit` - 提交实操任务
- `GET /api/student/exams` - 可参加的考试列表
- `POST /api/student/exams/start` - 开始考试(创建attempt)
- `GET /api/student/exams/questions` - 获取试卷题目
- `POST /api/student/exams/submit` - 交卷(含服务端时间锁)
- `GET /api/student/results` - 成绩查询

**教师端**
- `GET /api/teacher/dashboard` - 教师仪表盘
- `GET /api/teacher/exams` - 考试列表
- `POST /api/teacher/exams` - 创建考试
- `GET /api/teacher/students` - 学员列表

**管理端**
- `GET /api/admin/stats` - 系统统计
- `GET /api/admin/users` - 用户管理
- `GET /api/admin/organizations` - 组织列表
- `GET /api/admin/cohorts` - 班级列表
- `POST /api/admin/cohorts/import-roster` - 名册导入(Excel解析+批量注册学员+关联班级)
- `POST /api/admin/cohorts/parse-roster` - 名册预览解析(不写库)
- `GET /api/admin/cohorts/[id]/students` - 班级学员列表
- `GET/POST /api/admin/exam-schedules` - 考试安排
- `GET/POST/PUT/PATCH /api/admin/task-templates` - 实操任务模板(列表/创建/PUT更新answer_key/PATCH上下架)
- `GET/POST /api/admin/papers` - 试卷管理(手动组卷)
- `GET/POST /api/admin/papers/auto-compose` - 一键智能组卷(随机抽题+自动均分, school_admin/super_admin)
- `GET /api/admin/results` - 成绩列表
- `GET/PATCH /api/admin/scores/review` - 成绩复核(查详情+调整)
- `POST /api/admin/scores/publish` - 发布成绩
- `POST /api/admin/media/generate-image` - AI图片生成
- `POST /api/admin/media/generate-audio` - TTS音频生成
- `GET /api/admin/reports/overview` - 报表概览(成绩分布/考试通过率/班级对比/薄弱题型)
- `GET /api/admin/audit-logs` - 审计日志(分页+过滤)
- `GET/PATCH /api/admin/settings` - 系统设置(获取/更新配置项)
- `POST /api/admin/seed-theory` - 一键导入初级理论考试题(100题, 清旧+写新, super_admin/school_admin)
- `POST /api/admin/seed-prompt-questions` - 一键导入提示词描述题(5题, 跳过已存在, super_admin/school_admin)

### 考试时间锁

- 开始考试时服务端校验 `exam_start_at <= NOW()`
- 交卷时服务端校验 `NOW() <= exam_end_at`，超时自动判为 `expired`
- 客户端倒计时到期自动提交
- 成绩复核支持调整分数、通过/不通过标记、发布

## 编码规范

- TypeScript strict 模式，禁止隐式 any / as any
- 函数参数、返回值必须有类型标注
- 中文标点仅出现在中文字符串内容中，代码标点一律半角
- 禁止使用 `@/hooks/use-toast`（不存在），用 sonner

## 设计规范

详见 DESIGN.md — 核心要点:
- 墨青绿主色、暖白纸背景、18px 学员正文字号
- 状态绝不只用颜色表达：必须图标+文字
- 练习反馈温和鼓励("✓ 做对了！", "✗ 答错了，没关系")
- 考试模式克制严肃
- 禁止科技蓝+蓝紫渐变、小于14px正文、纯图标关键按钮

## 测试账号

| 角色 | 邮箱 | 密码 |
|------|------|------|
| 超级管理员 | admin@exam.local | 首次运行随机生成 |
| 学校管理员 | school@exam.local | 首次运行随机生成 |
| 教师 | teacher01@exam.local | 首次运行随机生成 |
| 学员 | stu001@student.exam.local | 首次运行随机生成 |
| 学员 | stu002@student.exam.local | 首次运行随机生成 |
| 题库编辑 | editor01@exam.local | 首次运行随机生成 |
| 题库审核 | reviewer01@exam.local | 首次运行随机生成 |

> 密码由 `seed-core` 脚本生成并输出到控制台。验证脚本通过 `.env.local` 中的 `VERIFY_*_PASSWORD` 环境变量读取，不在源码中硬编码。
