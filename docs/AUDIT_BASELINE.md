# ai-trainer-exam 深度 Review 与测试报告

- 仓库：`douknowai/ai-trainer-exam`
- 审查基线：`main` 最新提交 `e3294e354c5beb0233bdb03d47c9dbb6333f6c62`
- 审查日期：2026-07-23
- 方法：GitHub 全仓静态审查、关键 API 数据流追踪、数据库 Schema/迁移/种子脚本核对、评分算法定向可执行复现。
- 限制：当前执行容器无法解析 `github.com`，因此无法完整 clone 后运行 `pnpm install / build / test`。GitHub 当前提交也没有 CI 状态或 workflow run。本文不会把静态审查冒充完整环境测试。

## 总体结论

当前项目具有较完整的页面骨架、数据表设计和角色概念，但尚不具备正式职业考试系统的可交付可靠性。核心问题集中在四类：

1. 多个主要学员流程实际不可用；
2. 正式评分存在可绕过、可错判和不可审计问题；
3. 练习库/考试库隔离和多机构权限隔离被代码回退逻辑破坏；
4. 文档所定义的功能明显超前于真实实现。

建议当前状态定义为：**内部开发联调版，不可进入真实培训或正式考试。**

## P0 阻断问题

1. 登录 token 存在 `sessionStorage/examsys.access_token`，考试页面却读取 `localStorage/accessToken`，正常登录后考试 API 会携带 `Bearer null`。
2. 理论练习页面把请求体先 `JSON.stringify`，公共 `apiFetch` 又二次序列化，服务端收到字符串而不是对象，提交答案失败。
3. 实操页面误解 `apiFetch` 返回结构，服务端数据已被解包，页面却继续读取 `data.success/data.data`，任务加载与提交结果处理失败。
4. 实操评分比例为 0–1，但及格线按 60 分比较，任何正常提交都无法通过；数据库同时保存 `score=0–1`、`max_score=100`。
5. 客户端可自行提交 `graderId`。用 `true_false` 评分器评任何不相关任务，并提交空对象时，`undefined === undefined` 可得到满分。
6. 练习查询与提交 API 没有检查 `practice_lock_at`，考试时刻到达后仍可继续访问和提交练习。
7. 正式考试题目 API 没有校验学员是否属于该班级、是否已经开始考试；任意已登录学员可在时间窗口内用已知 scheduleId 读取题目。
8. 正式考试题目在考试库缺题时回退练习库；试卷为空时随机从练习库抽 20 题，破坏题库隔离、试卷冻结和可重复性。
9. 交卷先把 attempt 更新为 submitted，之后才保存答案和评分，且未使用事务。任何中途错误都会使考生被锁死，无法重交。
10. 正式考试交卷只实现单选/判断题评分，所有实操模块分数固定为 0；系统核心承诺尚未实现。
11. 考试页面交卷后立即显示分数和通过状态，绕过成绩发布时间策略。
12. 批量发布筛选状态为 `auto_scored`，而交卷写入的是 `auto_graded`，自动评分成绩无法被批量发布。
13. 成绩复核 GET 查询了 `exam_responses.score` 和 `graded_at`，但 Schema 中没有这两列，接口会运行时失败。
14. 成绩调整只用本次请求中提供的分项重新计算总分，未提供的原有分项被当作 0；只调整一项会错误覆盖总分。
15. service 级数据库连接绕过 RLS，但多个管理接口缺少组织过滤。学校管理员可按 ID 更新其他机构考试安排、读取或复核其他机构成绩和题库。
16. 试卷创建不验证题目是否来自考试库、是否已审核、是否允许正式考试、是否属于同一机构；练习专用题可以被直接装入正式试卷。
17. `seed-core.mts` 按旧 API 使用 `dbQuery/dbOne`：传参数数组而不是可变参数，并读取不存在的 `res.rows`；初始数据库种子流程会失败。
18. 图片标注示例引用 `/sample-street.jpg`，仓库没有该文件，任务页面将无图可标。
19. 运维统计种子题中，99.5%、99.8%、99.2%的“合计”应为298.5%，答案键却写99.50%。

## P1 高优先级问题

1. 考试倒计时每次刷新都重置为完整时长，不读取 attempt 的 server_deadline。
2. 考试答案仅保存在 React 内存，没有自动保存、心跳、掉线恢复或离线重传。
3. 登录只返回 access token，没有 refresh token 或刷新机制；token 失效后直接清空会话。
4. 考试开始接口未检查 exam_end_at 和合法状态；并发开始或过期 attempt 可能撞唯一约束。
5. 交卷比较答案时不 trim、不统一大小写。
6. 交卷把正确答案写入 exam_responses.response，扩大答案泄露面。
7. 及格线使用全局设置，而不是试卷自己的 pass_score。
8. 成绩没有写 engine_version、paper_version、original_total，重评分与审计链不完整。
9. 试卷每题分数用 floor(total/questionCount)，余数丢失，实际满分可能低于声明满分。
10. 评分实现与 GRADING_SPEC 严重不一致：缺少 point/polyline/polygon、红绿灯属性、可配置扣分、details 和 maxScore。
11. 图片框匹配是按标准框顺序的局部贪心，不是全局 IoU 降序或最优匹配，存在可复现少匹配情况。
12. 图片坐标使用页面容器 CSS 像素，未归一化到原图；不同屏幕、缩放和 object-contain 留白会导致错判。
13. Excel 删行评分反馈语义反了：保留了错误行却提示“多删”，误删正确行却提示“漏删”。
14. Excel 使用行下标而非稳定 row_id，排序或数据变化后答案失效，也无法检查非法单元格修改。
15. 音频评分只去空格和小写化，不按规范处理全半角、标点和必需语气词；长句中漏掉“嗯、啊”等仍可能达及格阈值。
16. 统计表使用 parseFloat，`123abc` 会被视为 123；额外修改的单元格不受处罚。
17. 文件分类用文件名作为主键，重名文件会互相覆盖。
18. 初始密码使用 Math.random，不适合作为正式账号凭据生成器。
19. 系统设置首次读取后永久缓存，后台 PATCH 更新不会让当前进程刷新缓存。
20. 考试状态字段允许任意字符串，PATCH 不验证合法状态迁移。
21. DOCX 上传无 MIME、扩展名和文件大小限制，也没有稳定错误处理。
22. 媒体接口直接调用 Coze ImageGenerationClient/TTSClient，没有使用约定的 image2-api 和 mimo-lecture-audio-skill，也没有素材持久化、审核、版本、checksum 和冻结流程。
23. 公开 README 与种子脚本包含固定管理员、教师和学员密码，若生产环境执行 seed 则形成默认凭据风险。

## P2 工程与文档问题

1. `pnpm validate` 只运行类型、ESLint、Stylelint，不运行单测或 build。
2. TypeScript 配置排除了 `scripts/db/*.mts`，因此种子脚本的明确类型错误未被发现。
3. GitHub 当前提交没有 CI 状态和 workflow run。
4. 现有 Vitest 主要覆盖评分器基础 happy path，未覆盖恶意输入、边界值、重复项、负坐标、语气词和 API 集成。
5. 没有 Playwright 依赖或端到端考试测试。
6. STATUS.md 仍写 Phase 2 进行中、暂无测试，与仓库现状不符。
7. README 声称的 12 个评分器名称与实际注册表不同。
8. README 写“未设开源许可”，仓库根目录却存在 Apache-2.0 LICENSE，发布口径冲突。
9. 多个路由直接 `request.json() as Type`，没有使用项目已有的 Zod parseBody。
10. `next/image` 远程域名配置为任意 HTTPS 主机，若后续把用户输入 URL 送入优化器，需要防 SSRF/内部网络探测。

## 定向可执行复现结果

| 测试 | 输入 | 实际结果 | 结论 |
|---|---|---|---|
| 客户端 grader 绕过 | 任意任务 answerKey + graderId=true_false + submission={} | score=1 | 确认 P0 |
| Excel 保留错误行 | 正确保留[0,2,4]，提交[0,1,2,4] | 提示“多删1行” | 反馈反向 |
| Excel 误删正确行 | 正确保留[0,2,4]，提交[0,4] | 提示“漏删1行” | 反馈反向 |
| 音频漏语气词 | 标准“嗯这个产品真的很好啊”，提交“这个产品真的很好” | 相似度0.8，可按默认阈值通过 | 不符合考试规则 |
| 图片贪心匹配 | IoU矩阵[[0.9,0.8],[0.8,0]]，阈值0.5 | 当前算法匹配1个，最优可匹配2个 | 错判风险 |
| 统计答案键 | 99.5+99.8+99.2 | 298.5，种子答案99.50 | 答案错误 |
| 实操及格线 | grader score=1，practice_pass_score=60 | 1>=60 为 false | 满分仍不通过 |

## 建议修复顺序

### 第一批：立即停止正式使用

- 统一 token 存储和 API 客户端。
- 修复请求体二次序列化及 apiFetch 解包误用。
- 服务端绑定 task_type -> grader，不接受客户端 graderId。
- 统一评分单位，数据库保存真实分值。
- 给所有练习 API 加服务端锁定守卫。
- 删除考试题目对练习库的全部 fallback。
- 给考试 questions/start/submit 加 enrollment、attempt、schedule 状态校验。
- 交卷、响应、成绩写入改为单事务和幂等提交。
- 修复成绩发布状态与结果发布策略。
- 修复所有跨机构 IDOR。

### 第二批：完成正式考试能力

- 把实操任务实例加入 exam_paper_items，并逐类调用确定性评分器。
- 按 GRADING_SPEC 实现稳定 ID、归一化坐标、点/线/多边形、属性、CER 与语气词规则。
- 实现服务端自动保存、heartbeat、server_deadline 和断线恢复。
- 成绩保存评分器、答案键、试卷和素材版本。
- 完成素材审核、checksum、版本冻结。

### 第三批：建立质量门禁

- 修复 seed-core，纳入 TypeScript 检查。
- CI 强制执行 install、typecheck、lint、unit、build、Playwright、迁移和种子冒烟。
- 增加权限矩阵测试、考试时间边界测试、作弊输入测试和评分回归金丝雀数据。
- 清除或强制轮换公开默认账号密码。

