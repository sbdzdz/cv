#!/usr/bin/env node
// Renders cv.json -> cv.html -> cv.pdf (via headless Chrome).
// Usage: node build.mjs [--html-only]

import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { resolve } from "node:path";

const cv = JSON.parse(readFileSync("cv.json", "utf8"));
const icons = JSON.parse(readFileSync("icons.json", "utf8"));
const css = readFileSync("cv.css", "utf8");

const icon = (name, cls = "") => {
  const g = icons[name];
  if (!g) throw new Error(`unknown icon: ${name}`);
  return `<span class="icon icon--${name} ${cls}"><svg viewBox="${g.viewBox}" aria-hidden="true"><path d="${g.d}"/></svg></span>`;
};

const section = (iconName, title, inner) => `
      <section class="section">
        <h2 class="section__title">${icon(iconName)}${title}</h2>
        ${inner}
      </section>`;

const def = (d) =>
  `<div class="def"><div class="def__label">${d.label}</div><div class="def__text">${d.text}</div></div>`;

const pub = (p) => `
          <div class="pub">
            <a class="pub__title" href="${p.url}">${p.title}${icon("external", "pub__ext")}</a>
            <div class="pub__venue">${p.venue}</div>
            <div class="pub__authors">${p.authors}</div>
          </div>`;

const html = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>${cv.name.first} ${cv.name.last} — CV</title>
<style>
${css}</style>
</head>
<body>

<div class="page">
  <header class="header">
    <div>
      <h1 class="name">${cv.name.first} ${cv.name.last}</h1>
      <p class="blurb">${cv.blurb}</p>
    </div>
    <div class="contact">
${cv.contact.map((c) => `      <a href="${c.url}">${icon(c.icon)}<span>${c.label}</span></a>`).join("\n")}
    </div>
  </header>

  <div class="body">
${section("briefcase", "Experience", `<div class="timeline">
${cv.experience.map((e) => `          <article class="entry">
            <div class="entry__dates">${e.dates}</div>
            <div class="entry__rail"></div>
            <div>
              <div class="entry__head">
                <div><span class="entry__role">${e.role},</span> <span class="entry__org">${e.org}</span></div>
                <div class="entry__loc">${e.location}</div>
              </div>
              <p class="entry__text">${e.text}</p>
            </div>
          </article>`).join("\n")}
        </div>`)}
${section("education", "Education", `<div class="rows">
${cv.education.map((e) => `          <div class="row">
            <div class="row__dates">${e.dates}</div>
            <div class="row__main"><strong>${e.degree},</strong> <span>${e.school}</span>${e.note ? `<div class="row__note">${e.note}</div>` : ""}</div>
            <div class="row__loc">${e.location}</div>
          </div>`).join("\n")}
        </div>`)}
${section("gear", "Expertise", `<div class="defs">
${cv.expertise.map((d) => "          " + def(d)).join("\n")}
        </div>`)}
  </div>
</div>

<div class="page page--continued">
  <div class="body">
${section("book", "Selected publications", `${cv.publicationsNote ? `<p class="section__note">${cv.publicationsNote}</p>` : ""}
        <div class="pubs">${cv.publications.map(pub).join("")}
        </div>`)}
${section("award", "Patents", `<div class="pubs">${cv.patents.map(pub).join("")}
        </div>`)}
${section("users", "Academic service", `<ul class="bullets">
${cv.service.map((s) => `          <li><span><strong>${s.label}:</strong> ${s.text}</span></li>`).join("\n")}
        </ul>`)}
  </div>
</div>

</body>
</html>
`;

writeFileSync("cv.html", html);
console.log(`cv.html   ${(html.length / 1024).toFixed(0)} KB`);

if (process.argv.includes("--html-only")) process.exit(0);

const CHROME = [
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
  "/Applications/Chromium.app/Contents/MacOS/Chromium",
].find(existsSync);
if (!CHROME) {
  console.error("No Chrome found — run with --html-only, or print cv.html from a browser.");
  process.exit(1);
}

execFileSync(CHROME, [
  "--headless=new",
  "--disable-gpu",
  "--no-sandbox",
  "--no-pdf-header-footer",
  "--virtual-time-budget=4000",
  `--print-to-pdf=${resolve("cv.pdf")}`,
  `file://${resolve("cv.html")}`,
], { stdio: ["ignore", "ignore", "pipe"] });

console.log(`cv.pdf    ${(readFileSync("cv.pdf").length / 1024).toFixed(0)} KB`);
