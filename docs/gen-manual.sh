#!/bin/bash
# Generate complete manual HTML by concatenating fragments
OUT=/workspace/projects/docs/manual.html

cat > "$OUT" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<title>人工智能训练师五级零基础练习与考试系统 — 使用说明书</title>
<style>
@page { size: A4; margin: 20mm 18mm 20mm 18mm; }
@page :first { margin: 0; }
* { box-sizing: border-box; }
html { font-size: 14px; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
body { font-family: "PingFang SC","Microsoft YaHei","Noto Sans SC","Helvetica Neue",Arial,sans-serif; color:#1a1a1a; line-height:1.75; margin:0; padding:0; }
.cover { page-break-after:always; width:210mm; height:297mm; display:flex; flex-direction:column; justify-content:center; align-items:center; background:linear-gradient(160deg,#1a3d3a 0%,#2d6a5f 55%,#3a8a7a 100%); color:#fff; text-align:center; padding:0 40mm; position:relative; }
.cover .logo-area { width:120px; height:120px; border-radius:50%; border:4px solid rgba(255,255,255,0.3); display:flex; align-items:center; justify-content:center; margin-bottom:40px; }
.cover .logo-area span { font-size:52px; font-weight:900; }
.cover h1 { font-size:30px; font-weight:800; line-height:1.4; margin:0 0 16px; letter-spacing:2px; }
.cover .subtitle { font-size:17px; font-weight:400; opacity:0.85; margin-bottom:60px; letter-spacing:1px; }
.cover .version-badge { display:inline-block; padding:6px 24px; border:2px solid rgba(255,255,255,0.5); border-radius:50px; font-size:14px; margin-bottom:30px; }
.cover .date { font-size:14px; opacity:0.7; position:absolute; bottom:40mm; }
.cover .divider { width:60px; height:4px; background:rgba(255,255,255,0.4); border-radius:2px; margin:0 auto 30px; }
.toc { page-break-after:always; }
.toc h2 { font-size:24px; font-weight:800; color:#1a3d3a; border-bottom:3px solid #2d6a5f; padding-bottom:12px; margin-bottom:24px; }
.toc ol { list-style:none; padding:0; counter-reset:tc; }
.toc>ol>li { counter-increment:tc; margin-bottom:8px; font-weight:700; font-size:15px; color:#1a3d3a; }
.toc>ol>li::before { content:counter(tc) ". "; color:#2d6a5f; }
.toc ol ol { counter-reset:ts; padding-left:24px; margin-top:4px; margin-bottom:8px; }
.toc ol ol li { counter-increment:ts; font-weight:400; font-size:13px; color:#444; margin-bottom:4px; }
.toc ol ol li::before { content:counter(tc) "." counter(ts) " "; color:#888; }
h2.ch { font-size:22px; font-weight:800; color:#1a3d3a; border-left:6px solid #2d6a5f; padding-left:14px; margin-top:36px; margin-bottom:20px; page-break-after:avoid; }
h3 { font-size:17px; font-weight:700; color:#2d6a5f; margin-top:28px; margin-bottom:14px; page-break-after:avoid; }
h4 { font-size:15px; font-weight:700; color:#333; margin-top:20px; margin-bottom:10px; page-break-after:avoid; }
p { margin:8px 0; text-align:justify; }
ul,ol { margin:8px 0; padding-left:22px; }
li { margin-bottom:5px; }
table.d { width:100%; border-collapse:collapse; margin:12px 0; font-size:13px; page-break-inside:avoid; }
table.d th,table.d td { border:1px solid #d0d8d6; padding:7px 10px; text-align:left; }
table.d th { background:#2d6a5f; color:#fff; font-weight:700; }
table.d tr:nth-child(even) td { background:#f5f9f8; }
.tip { background:#eef7f4; border-left:4px solid #2d6a5f; padding:12px 16px; margin:12px 0; border-radius:0 6px 6px 0; font-size:13px; page-break-inside:avoid; }
.tip b { color:#2d6a5f; }
.warn { background:#fef9eef5; border-left:4px solid #d48806; padding:12px 16px; margin:12px 0; border-radius:0 6px 6px 0; font-size:13px; page-break-inside:avoid; }
.warn b { color:#d48806; }
.flow { background:#f5f9f8; border:1px solid #d0d8d6; border-radius:8px; padding:16px 20px; margin:14px 0; font-size:13px; page-break-inside:avoid; text-align:center; }
.flow .s { display:inline-block; padding:6px 14px; background:#2d6a5f; color:#fff; border-radius:6px; font-weight:600; margin:4px 0; }
.flow .a { margin:0 6px; color:#888; font-weight:700; }
code { font-family:"Courier New",monospace; background:#f0f4f3; padding:2px 6px; border-radius:3px; font-size:12px; color:#1a3d3a; }
.pb { page-break-before:always; }
p,li { orphans:3; widows:3; }
</style>
</head>
<body>
HTMLEOF

# ====== COVER ======
cat >> "$OUT" << 'HTMLEOF'
<div class="cover">
  <div class="logo-area"><span>AI</span></div>
  <div class="divider"></div>
  <h1>人工智能训练师五级<br>零基础练习与考试系统</h1>
  <div class="subtitle">使 用 说 明 书</div>
  <div class="version-badge">Version 1.0</div>
  <div class="date">2026 年 7 月</div>
</div>
HTMLEOF

# ====== TOC ======
cat >> "$OUT" << 'HTMLEOF'
<div class="toc">
  <h2>目 录</h2>
  <ol>
    <li>系统简介
      <ol><li>产品定位</li><li>系统角色与职责</li><li>技术架构</li><li>设计理念</li></ol>
    </li>
    <li>系统环境与要求
      <ol><li>浏览器要求</li><li>屏幕分辨率</li><li>网络要求</li></ol>
    </li>
    <li>快速开始
      <ol><li>访问系统</li><li>登录与退出</li><li>测试账号一览</li></ol>
    </li>
    <li>学员操作指南
      <ol><li>学员首页</li><li>理论练习</li><li>实操任务（7 种题型）</li><li>正式考试（完整流程）</li><li>成绩查询</li><li>错题本</li><li>帮助中心</li></ol>
    </li>
    <li>教师操作指南
      <ol><li>教师仪表盘</li><li>考试管理</li><li>学员管理</li><li>教学建议</li></ol>
    </li>
    <li>管理员操作指南
      <ol><li>管理首页与数据概览</li><li>用户管理（含角色权限矩阵）</li><li>组织与班级管理</li><li>考试安排</li><li>试卷管理</li><li>成绩管理与复核流程</li><li>考试实时监控</li><li>数据报表与分析</li><li>系统设置（参数说明）</li><li>审计日志</li><li>媒体素材工坊</li><li>题库管理</li></ol>
    </li>
    <li>安全与合规
      <ol><li>数据安全</li><li>考试防作弊机制</li><li>用户隐私保护</li></ol>
    </li>
    <li>故障排查与常见问题</li>
    <li>附录
      <ol><li>术语表</li><li>角色权限矩阵</li><li>版本历史</li></ol>
    </li>
  </ol>
</div>
HTMLEOF

echo "CSS + Cover + TOC done."
