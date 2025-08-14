const fs = require("fs");
const path = require("path");
const puppeteer = require("puppeteer");

(async () => {
  const htmlPath = path.resolve("dist/ebook.html");
  if (!fs.existsSync(htmlPath)) {
    console.error("dist/ebook.html não encontrado. Rode o step do Pandoc primeiro.");
    process.exit(1);
  }

  const browser = await puppeteer.launch({ headless: "new" });
  const page = await browser.newPage();

  await page.goto("file://" + htmlPath, { waitUntil: "networkidle0" });

  await page.pdf({
    path: path.resolve("dist/ebook.pdf"),
    format: "A4",
    printBackground: true,
    margin: { top: "22mm", bottom: "18mm", left: "18mm", right: "18mm" },
    displayHeaderFooter: true,
    headerTemplate: `
      <style>section{font-size:8pt;font-family:system-ui;margin:0 18mm;width:calc(100% - 36mm);color:#6b7280;}</style>
      <section></section>`,
    footerTemplate: `
      <style>section{font-size:8pt;font-family:system-ui;margin:0 18mm;width:calc(100% - 36mm);color:#6b7280;display:flex;justify-content:space-between;}</style>
      <section><span class="date"></span><span class="pageNumber"></span>/<span class="totalPages"></span></section>`
  });

  await browser.close();
  console.log("OK → dist/ebook.pdf");
})();
