const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

// ========== CSS ==========
const CSS = `
@page { size: A4; margin: 20mm 18mm; }
@page :first { margin: 0; }
* { box-sizing: border-box; }
html { font-size: 14px; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
body { font-family: "PingFang SC","Microsoft YaHei","Noto Sans SC","Helvetica Neue",Arial,sans-serif; color:#1a1a1a; line-height:1.8; margin:0; }
.cover { page-break-after:always; width:210mm; height:297mm; display:flex; flex-direction:column; justify-content:center; align-items:center; background:linear-gradient(160deg,#1a3d3a 0%,#2d6a5f 55%,#3a8a7a 100%); color:#fff; text-align:center; padding:0 40mm; position:relative; }
.cover .logo-area { width:120px; height:120px; border-radius:50%; border:4px solid rgba(255,255,255,0.3); display:flex; align-items:center; justify-content:center; margin-bottom:40px; }
.cover .logo-area span { font-size:52px; font-weight:900; }
.cover h1 { font-size:30px; font-weight:800; line-height:1.4; margin:0 0 16px; letter-spacing:2px; }
.cover .subtitle { font-size:17px; opacity:0.85; margin-bottom:60px; }
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
p,li { orphans:3; widows:3; }
`;

// ========== HTML BODY ==========
const html = fs.readFileSync(path.join(__dirname, 'manual-body.html'), 'utf8');

async function main() {
  const fullHtml = `<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><style>${CSS}</style></head><body>${html}</body></html>`;
  const browser = await puppeteer.launch({
    executablePath: '/root/.cache/puppeteer/chrome/linux-150.0.7871.24/chrome-linux64/chrome',
    headless: true,
    args: ['--no-sandbox','--disable-setuid-sandbox','--disable-gpu']
  });
  const page = await browser.newPage();
  await page.setContent(fullHtml, { waitUntil: 'networkidle0', timeout: 60000 });
  const outPath = path.join(__dirname, '人工智能训练师五级练习与考试系统-使用说明书.pdf');
  await page.pdf({
    path: outPath,
    format: 'A4',
    printBackground: true,
    margin: { top:'20mm', bottom:'20mm', left:'18mm', right:'18mm' },
    displayHeaderFooter: true,
    headerTemplate: '<div></div>',
    footerTemplate: '<div style="width:100%;text-align:center;font-size:10px;color:#999;padding:0 18mm;">第 <span class="pageNumber"></span> 页 / 共 <span class="totalPages"></span> 页</div>'
  });
  await browser.close();
  console.log('PDF generated:', outPath);
}
main().catch(e => { console.error(e); process.exit(1); });
