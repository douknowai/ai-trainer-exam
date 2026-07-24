# 系统架构

## 1. 边界

系统由学员端、教师端、管理端、Next.js BFF、PostgreSQL、Supabase Auth、S3 对象存储和媒体 Provider 组成。浏览器不持有 service-role、S3 密钥、正式答案或评分阈值。

```text
Browser
  -> Next.js API / Server routes
      -> Supabase Auth
      -> PostgreSQL (business + audit + frozen exam snapshots)
      -> S3-compatible object storage
      -> deterministic grading engine
      -> image2-api / mimo-lecture-audio-skill / Coze fallback (authoring only)
```

## 2. 题库物理隔离

练习和考试分别使用 `practice_question_items` / `exam_question_items` 与 `practice_task_templates` / `exam_task_templates`。正式组卷只接受已发布、允许正式考试、非 `practice_only` 且同机构的考试库内容。组卷时复制题干、配置、答案键、评分器、评分器版本和素材 checksum 到 `exam_paper_items`。

## 3. 考试状态

考试安排由草稿进入发布，再根据时间进入考试阶段，结束后完成评分和成绩发布。状态转换由服务端白名单控制。学员 attempt 使用 `in_progress -> grading -> graded -> released`，交卷在单个数据库事务中执行，并使用行锁和提交哈希实现幂等。

## 4. 自动保存与恢复

学员答案通过 `/api/student/exams/save` 增量保存，心跳更新最后在线时间。页面加载时从服务端恢复已保存答案，倒计时使用 `server_deadline`，刷新页面不会重置考试时长。

## 5. 评分

评分器位于 `src/server/grading/index.ts`，只接收服务器冻结的答案键。所有评分器返回 0—1 比例，业务层乘以试卷项目分值。正式成绩保存项目分、模块分、总分、评分详情、评分器版本、试卷版本和提交哈希。

## 6. 多租户

业务表以 `organization_id` 隔离。service-role 会绕过数据库 RLS，因此 API 同时执行对象级机构校验。教师通过 `teacher_cohort_grants` 访问授权班级；学员只能访问自己的报名、attempt、响应和成绩。

## 7. 媒体

媒体生成只用于内容生产，不参与考试实时评分。素材流程为：生成 → 存入对象存储 → 计算 SHA-256 → 人工审核 → 发布冻结 → 关联考试题。考试开始后不实时调用媒体模型。
