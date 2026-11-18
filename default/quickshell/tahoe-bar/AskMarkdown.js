.pragma library

// Claude's Markdown answers -> Qt rich text, styled like the Golden Gate answer window: spaced
// paragraphs, bold headings, and tables with small grey capitals over hairline rows (Qt's own
// MarkdownText draws a boxed grid with no paragraph spacing). Covers what answers use:
// headings, paragraphs, emphasis, code, fenced code, lists, tables, quotes, rules and links.
// Tests: ~/claude/archy-cleanup/search/test_ask_markdown.mjs (node --test).

const P = "margin-top:0px; margin-bottom:10px;";
const PRE = "margin-top:0px; margin-bottom:10px; font-family:monospace; font-size:13px; "
          + "background-color:rgba(255,255,255,0.08);";
const CODE = "font-family:monospace; background-color:rgba(255,255,255,0.10);";
const TH = "padding:2px 12px 6px 0px; color:rgba(255,255,255,0.55); font-size:11px; font-weight:600; "
         + "border-bottom:1px solid rgba(255,255,255,0.14);";
const TD = "padding:6px 12px 6px 0px; vertical-align:top; border-bottom:1px solid rgba(255,255,255,0.08);";
const LINK = "color:#6cb4ff; text-decoration:none;";
const ITEM = /^\s*([-*+]|\d+[.)])\s+(.*)$/;

function esc(s) {
    return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

function inline(s) {
    const codes = [];   // code spans wait outside, so emphasis can't reach into them
    s = s.replace(/`([^`]+)`/g, (m, c) => { codes.push(c); return "\u0000" + (codes.length - 1) + "\u0000"; });
    s = esc(s);
    s = s.replace(/\[([^\]]+)\]\(([^)\s]+)\)/g,
                  (m, t, u) => /^(https?:|mailto:)/i.test(u) ? `<a href="${u}" style="${LINK}">${t}</a>` : t);
    s = s.replace(/\*\*(.+?)\*\*/g, "<b>$1</b>").replace(/__(.+?)__/g, "<b>$1</b>");
    s = s.replace(/(^|[^*\w])\*(?!\s)(.+?)\*(?!\w)/g, "$1<i>$2</i>");
    s = s.replace(/(^|[^_\w])_(?!\s)(.+?)_(?!\w)/g, "$1<i>$2</i>");
    s = s.replace(/~~(.+?)~~/g, "<s>$1</s>");
    return s.replace(/\u0000(\d+)\u0000/g, (m, i) => `<code style="${CODE}">${esc(codes[+i])}</code>`);
}

function cells(line) {
    return line.trim().replace(/^\|/, "").replace(/\|$/, "").split("|").map(c => c.trim());
}

function toHtml(md) {
    const lines = (md || "").replace(/\r/g, "").split("\n");
    const out = [];
    let para = [];
    const flush = () => {
        if (para.length) out.push(`<p style="${P}">${inline(para.join(" "))}</p>`);
        para = [];
    };
    let i = 0;
    while (i < lines.length) {
        const line = lines[i];
        let m;
        if (/^\s*```/.test(line)) {
            flush();
            const code = [];
            for (i++; i < lines.length && !/^\s*```/.test(lines[i]); i++) code.push(lines[i]);
            i++;
            out.push(`<pre style="${PRE}">${esc(code.join("\n"))}</pre>`);
        } else if (line.trim() === "") {
            flush();
            i++;
        } else if ((m = line.match(/^\s{0,3}(#{1,6})\s+(.*?)\s*#*\s*$/))) {
            flush();
            const size = m[1].length <= 2 ? 21 : m[1].length === 3 ? 17 : 15;
            out.push(`<p style="margin-top:6px; margin-bottom:8px; font-size:${size}px;"><b>${inline(m[2])}</b></p>`);
            i++;
        } else if (/^\s*([-*_])(\s*\1){2,}\s*$/.test(line)) {
            flush();
            out.push("<hr/>");
            i++;
        } else if (/^\s*\|/.test(line) && /^\s*\|?\s*:?-{2,}/.test(lines[i + 1] ?? "")) {
            flush();
            const head = cells(line);
            const body = [];
            for (i += 2; i < lines.length && /^\s*\|/.test(lines[i]); i++) body.push(cells(lines[i]));
            const row = (cs, style, up) => "<tr>" + cs.map(c => `<td style="${style}">${inline(up ? c.toUpperCase() : c)}</td>`).join("") + "</tr>";
            out.push(`<table border="0" cellspacing="0" cellpadding="0" width="100%" style="margin-bottom:10px;">`
                     + row(head, TH, true) + body.map(r => row(r, TD, false)).join("") + "</table>");
        } else if ((m = line.match(ITEM))) {
            flush();
            const ordered = /\d/.test(m[1]);
            const items = [];
            while (i < lines.length && (m = lines[i].match(ITEM)) && /\d/.test(m[1]) === ordered) {
                items.push(m[2]);
                for (i++; i < lines.length && /^\s{2,}\S/.test(lines[i]) && !ITEM.test(lines[i]); i++)
                    items[items.length - 1] += " " + lines[i].trim();
            }
            const tag = ordered ? "ol" : "ul";
            out.push(`<${tag} style="margin-top:0px; margin-bottom:10px;">`
                     + items.map(t => `<li style="margin-bottom:3px;">${inline(t)}</li>`).join("") + `</${tag}>`);
        } else if (/^\s*>/.test(line)) {
            flush();
            const quote = [];
            for (; i < lines.length && /^\s*>/.test(lines[i]); i++) quote.push(lines[i].replace(/^\s*>\s?/, ""));
            out.push(`<p style="${P} color:rgba(255,255,255,0.65);">${inline(quote.join(" "))}</p>`);
        } else {
            para.push(line.trim());
            i++;
        }
    }
    flush();
    return out.join("");
}
