#!/usr/bin/env python3
"""bookfix: receives text corrections from the KOReader plugin, queues them for
review in a small web UI, and applies approved ones to the EPUBs in the
Calibre library.  Standard library only.

Environment:
  BOOKFIX_LIBRARY    calibre library dir (contains metadata.db)
  BOOKFIX_STATE      state dir (queue db, token, backups)
  BOOKFIX_PORT       listen port (bound to 127.0.0.1)
  BOOKFIX_BASE_PATH  URL prefix the reverse proxy strips, e.g. /bookfix
  BOOKFIX_CONVERT    path to calibre's ebook-convert (optional; regenerates
                     other formats such as MOBI after an EPUB is edited)
"""

import datetime
import difflib
import html
import json
import os
import re
import secrets
import shutil
import sqlite3
import subprocess
import tempfile
import threading
import traceback
import urllib.parse
import zipfile
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

LIBRARY = os.environ.get("BOOKFIX_LIBRARY", "/calibre-library")
STATE = os.environ.get("BOOKFIX_STATE", "/var/lib/bookfix")
PORT = int(os.environ.get("BOOKFIX_PORT", "8091"))
BASE = os.environ.get("BOOKFIX_BASE_PATH", "").rstrip("/")
CONVERT = os.environ.get("BOOKFIX_CONVERT", "")

DB_PATH = os.path.join(STATE, "bookfix.db")
TOKEN_PATH = os.path.join(STATE, "token")
BACKUPS = os.path.join(STATE, "backups")

apply_lock = threading.Lock()


# --------------------------------------------------------------------------
# storage

def db():
    conn = sqlite3.connect(DB_PATH, timeout=30)
    conn.row_factory = sqlite3.Row
    return conn


def init_state():
    os.makedirs(BACKUPS, exist_ok=True)
    if not os.path.exists(TOKEN_PATH):
        fd = os.open(TOKEN_PATH, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(fd, "w") as f:
            f.write(secrets.token_urlsafe(24) + "\n")
    with db() as conn:
        conn.executescript("""
            CREATE TABLE IF NOT EXISTS edits (
                id INTEGER PRIMARY KEY,
                uid TEXT UNIQUE NOT NULL,
                device TEXT,
                created_at TEXT,
                received_at TEXT NOT NULL,
                status TEXT NOT NULL DEFAULT 'pending', -- pending|applied|rejected|failed
                book_id INTEGER,
                book_title TEXT, book_authors TEXT, identifiers TEXT, filename TEXT,
                pos0 TEXT, pos1 TEXT,
                original TEXT NOT NULL,
                replacement TEXT NOT NULL,
                ctx_before TEXT, ctx_after TEXT,
                note TEXT,
                error TEXT,
                applied_at TEXT
            );
            CREATE INDEX IF NOT EXISTS edits_book ON edits(book_id, status);
        """)


def token():
    with open(TOKEN_PATH) as f:
        return f.read().strip()


def now():
    return datetime.datetime.now().astimezone().isoformat(timespec="seconds")


# --------------------------------------------------------------------------
# calibre library

def calibre_db(write=False):
    path = os.path.join(LIBRARY, "metadata.db")
    if write:
        conn = sqlite3.connect(path, timeout=30)
    else:
        conn = sqlite3.connect(f"file:{path}?mode=ro", uri=True, timeout=30)
    conn.row_factory = sqlite3.Row
    # metadata.db uses custom functions in triggers; stub the ones that fire on
    # the columns we update so writes don't fail outside calibre.
    conn.create_function("title_sort", 1, lambda s: s)
    conn.create_function("uuid4", 0, lambda: str(__import__("uuid").uuid4()))
    return conn


def all_books():
    with calibre_db() as c:
        rows = c.execute("""
            SELECT b.id, b.title, b.uuid,
                   (SELECT group_concat(a.name, ' & ') FROM books_authors_link l
                      JOIN authors a ON a.id = l.author WHERE l.book = b.id) AS authors
            FROM books b ORDER BY b.title COLLATE NOCASE""").fetchall()
    return [dict(r) for r in rows]


def book_info(book_id):
    with calibre_db() as c:
        b = c.execute("""
            SELECT b.id, b.title, b.path, b.uuid,
                   (SELECT group_concat(a.name, ' & ') FROM books_authors_link l
                      JOIN authors a ON a.id = l.author WHERE l.book = b.id) AS authors
            FROM books b WHERE b.id = ?""", (book_id,)).fetchone()
        if not b:
            return None
        formats = {r["format"]: os.path.join(LIBRARY, b["path"], r["name"] + "." + r["format"].lower())
                   for r in c.execute("SELECT format, name FROM data WHERE book = ?", (book_id,))}
    info = dict(b)
    info["formats"] = formats
    info["epub"] = formats.get("EPUB")
    return info


def _norm_title(s):
    s = (s or "").lower()
    s = re.sub(r"[^\w\s]", "", s)
    return re.sub(r"\s+", " ", s).strip()


UUID_RE = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", re.I)


def match_book(title, authors, identifiers, filename):
    """Return a calibre book id or None."""
    books = all_books()
    by_uuid = {b["uuid"].lower(): b["id"] for b in books if b["uuid"]}
    # 1. calibre uuid embedded in the EPUB (dc:identifier calibre:<uuid>)
    for u in UUID_RE.findall(identifiers or ""):
        if u.lower() in by_uuid:
            return by_uuid[u.lower()]
    # 2. title (+ author) match
    for t in (title, os.path.splitext(os.path.basename(filename or ""))[0].split(" - ")[0]):
        nt = _norm_title(t)
        if not nt:
            continue
        cands = [b for b in books if _norm_title(b["title"]) == nt]
        if len(cands) > 1 and authors:
            na = _norm_title(authors)
            narrowed = [b for b in cands if b["authors"] and
                        set(_norm_title(b["authors"]).split()) & set(na.split())]
            cands = narrowed or cands
        if len(cands) == 1:
            return cands[0]["id"]
    return None


# --------------------------------------------------------------------------
# EPUB text model
#
# An XHTML file is tokenised into tags and text.  The visible text is
# flattened into a list of chars, each carrying the source [start, end) it came
# from (entities map several source chars to one text char).  Whitespace runs
# collapse to a single space and block-level tag boundaries count as a space,
# so the flattened text lines up with what KOReader shows and hands us.

TOKEN_RE = re.compile(
    r"<!--.*?-->|<!\[CDATA\[.*?\]\]>|<\?.*?\?>|<![^>]*>|<[^>]+>|&#?\w+;|[^<&]+|&",
    re.S)
TAGNAME_RE = re.compile(r"</?\s*([\w:-]+)")
BLOCK_TAGS = {
    "p", "div", "br", "h1", "h2", "h3", "h4", "h5", "h6", "li", "ul", "ol", "tr",
    "td", "th", "table", "blockquote", "section", "article", "aside", "header",
    "footer", "hr", "dt", "dd", "dl", "pre", "figure", "figcaption", "body",
    "nav", "img",
}
SKIP_TAGS = {"head", "script", "style", "title"}
WS = set(" \t\n\r\f\v              　")
INVISIBLE = set("­​‌‍⁠﻿")


def _local(name):
    return name.split(":")[-1].lower()


def flatten(src):
    """Return (text, spans) where spans[i] = (start, end) in src for text[i]."""
    chars, spans = [], []
    skip = 0

    def push(ch, s, e):
        if ch in INVISIBLE:
            return
        if ch in WS:
            if chars and chars[-1] == " ":
                ps, pe = spans[-1]
                if ps == pe:          # previous was a virtual space: adopt real ws
                    spans[-1] = (s, e)
                elif e > s:
                    spans[-1] = (ps, e)
                return
            if not chars:
                return            # drop leading whitespace
            chars.append(" ")
            spans.append((s, e))
            return
        chars.append(ch)
        spans.append((s, e))

    for m in TOKEN_RE.finditer(src):
        tok, s, e = m.group(0), m.start(), m.end()
        if tok.startswith("<"):
            if tok.startswith(("<!", "<?")):
                continue
            nm = TAGNAME_RE.match(tok)
            if not nm:
                continue
            name = _local(nm.group(1))
            closing = tok.startswith("</")
            selfclosing = tok.endswith("/>")
            if name in SKIP_TAGS and not selfclosing:
                skip += -1 if closing else 1
                skip = max(skip, 0)
                continue
            if skip:
                continue
            if name in BLOCK_TAGS:
                push(" ", s, s)   # virtual space, empty span
            continue
        if skip:
            continue
        if tok.startswith("&") and len(tok) > 1:
            ch = html.unescape(tok)
            for c in ch:
                push(c, s, e)
            continue
        for i, c in enumerate(tok):
            push(c, s + i, s + i + 1)
    return "".join(chars), spans


def norm(s):
    s = "".join(c for c in (s or "") if c not in INVISIBLE)
    s = "".join(" " if c in WS else c for c in s)
    return re.sub(r" +", " ", s).strip()


def _nows(s):
    return "".join(c for c in s if c != " ")


def find_unique(text, before, original, after):
    """Locate `original` (with optional context) in flattened `text`.
    Matching ignores whitespace.  Returns ((start, end), method) in text
    coordinates, or (None, reason)."""
    idx = [i for i, c in enumerate(text) if c != " "]
    tn = "".join(text[i] for i in idx)
    b, o, a = _nows(norm(before)), _nows(norm(original)), _nows(norm(after))
    if not o:
        return None, "empty selection"
    attempts = [("context", b, a), ("context-before", b, ""), ("context-after", "", a), ("text-only", "", "")]
    ambiguous = False
    for method, pre, post in attempts:
        if (pre or post) == "" and method != "text-only":
            continue
        needle = pre + o + post
        hits = [m.start() for m in re.finditer(re.escape(needle), tn)]
        if len(hits) == 1:
            st = hits[0] + len(pre)
            en = st + len(o)
            return (idx[st], idx[en - 1] + 1), method
        if len(hits) > 1:
            ambiguous = True
    return None, ("ambiguous" if ambiguous else "not found")


def plan_edit(src, text, spans, rng, replacement):
    """Build (start, end, new_src) source patches that turn text[rng] into
    `replacement` while keeping any markup inside the changed ranges."""
    s0, e0 = rng
    cur = text[s0:e0]
    new = norm(replacement)
    ops = difflib.SequenceMatcher(None, cur, new, autojunk=False).get_opcodes()
    patches = []
    for tag, i1, i2, j1, j2 in ops:
        if tag == "equal":
            continue
        ins = html.escape(new[j1:j2], quote=False)
        a, b = s0 + i1, s0 + i2
        if tag == "insert":
            pos = spans[a - 1][1] if a > 0 else spans[a][0]
            patches.append((pos, pos, ins))
            continue
        rs, re_ = spans[a][0], spans[b - 1][1]
        if rs >= re_:
            # only virtual (block-boundary) spaces: nothing to delete
            if ins:
                patches.append((rs, rs, ins))
            continue
        # keep tags inside the region, drop text
        kept = "".join(t for t in TOKEN_RE.findall(src[rs:re_]) if t.startswith("<"))
        # but if the region starts in the middle of a tag-free run that's fine;
        # new text goes first, surviving tags after it
        patches.append((rs, re_, ins + kept))
    return patches


def apply_patches(src, patches):
    for s, e, rep in sorted(patches, key=lambda p: p[0], reverse=True):
        src = src[:s] + rep + src[e:]
    return src


FRAG_RE = re.compile(r"DocFragment\[(\d+)\]")


class Epub:
    def __init__(self, path):
        self.path = path
        with zipfile.ZipFile(path) as z:
            self.infos = z.infolist()
            self.data = {i.filename: z.read(i.filename) for i in self.infos}
        self.changed = set()
        self.spine = self._spine()
        self._cache = {}

    def _spine(self):
        container = self.data.get("META-INF/container.xml", b"").decode("utf-8", "replace")
        m = re.search(r'full-path="([^"]+)"', container)
        opf_path = m.group(1) if m else next((n for n in self.data if n.endswith(".opf")), None)
        if not opf_path:
            return [n for n in self.data if n.endswith((".html", ".xhtml", ".htm"))]
        opf = self.data[opf_path].decode("utf-8", "replace")
        base = os.path.dirname(opf_path)
        manifest = {}
        for item in re.finditer(r"<(?:\w+:)?item\b[^>]*>", opf):
            t = item.group(0)
            i = re.search(r'\bid="([^"]+)"', t)
            h = re.search(r'\bhref="([^"]+)"', t)
            if i and h:
                href = urllib.parse.unquote(h.group(1))
                manifest[i.group(1)] = os.path.normpath(os.path.join(base, href)).replace("\\", "/")
        spine = []
        for ref in re.finditer(r'<(?:\w+:)?itemref\b[^>]*\bidref="([^"]+)"', opf):
            p = manifest.get(ref.group(1))
            if p and p in self.data:
                spine.append(p)
        return spine

    def text_of(self, name):
        if name not in self._cache:
            src = self.data[name].decode("utf-8", "replace")
            text, spans = flatten(src)
            self._cache[name] = (src, text, spans)
        return self._cache[name]

    def set_src(self, name, src):
        self.data[name] = src.encode("utf-8")
        self.changed.add(name)
        self._cache.pop(name, None)

    def locate(self, edit):
        """Find the edit's text.  Returns dict(name, range, method) or error."""
        names = list(self.spine)
        m = FRAG_RE.search(edit["pos0"] or "")
        if m:
            n = int(m.group(1)) - 1
            if 0 <= n < len(names):
                names.insert(0, names.pop(n))
        reasons = []
        # try the fragment the xpointer names first, then the whole book
        for first, scope in ((True, names[:1]), (False, names)):
            found = []
            for name in scope:
                _, text, _ = self.text_of(name)
                rng, method = find_unique(text, edit["ctx_before"], edit["original"], edit["ctx_after"])
                if rng:
                    found.append((name, rng, method))
                else:
                    reasons.append(method)
            if len(found) == 1:
                name, rng, method = found[0]
                return {"name": name, "range": rng, "method": method + ("" if first else ", other chapter")}
            if len(found) > 1:
                return {"error": "matches in several chapters"}
        return {"error": "ambiguous" if "ambiguous" in reasons else "text not found in book"}

    def preview(self, edit):
        loc = self.locate(edit)
        if "error" in loc:
            return loc
        src, text, spans = self.text_of(loc["name"])
        s, e = loc["range"]
        loc["current"] = text[s:e]
        loc["before"] = text[max(0, s - 120):s]
        loc["after"] = text[e:e + 120]
        return loc

    def apply(self, edit):
        loc = self.locate(edit)
        if "error" in loc:
            raise ValueError(loc["error"])
        src, text, spans = self.text_of(loc["name"])
        patches = plan_edit(src, text, spans, loc["range"], edit["replacement"])
        self.set_src(loc["name"], apply_patches(src, patches))
        # verify
        _, text2, _ = self.text_of(loc["name"])
        if _nows(norm(edit["replacement"])) not in _nows(text2):
            raise ValueError("verification failed after patching")
        return loc["method"]

    def save(self):
        if not self.changed:
            return
        d = os.path.dirname(self.path)
        fd, tmp = tempfile.mkstemp(prefix=".bookfix-", suffix=".epub", dir=d)
        os.close(fd)
        try:
            with zipfile.ZipFile(tmp, "w") as z:
                order = sorted(self.infos, key=lambda i: i.filename != "mimetype")
                for info in order:
                    zi = zipfile.ZipInfo(info.filename, date_time=info.date_time)
                    zi.external_attr = info.external_attr
                    zi.compress_type = zipfile.ZIP_STORED if info.filename == "mimetype" else zipfile.ZIP_DEFLATED
                    z.writestr(zi, self.data[info.filename])
            st = os.stat(self.path)
            os.chmod(tmp, st.st_mode & 0o777)
            os.replace(tmp, self.path)
        finally:
            if os.path.exists(tmp):
                os.unlink(tmp)


# --------------------------------------------------------------------------
# applying

def apply_book_edits(book_id, edit_ids):
    info = book_info(book_id)
    if not info or not info["epub"] or not os.path.exists(info["epub"]):
        raise ValueError("book has no EPUB in the library")
    with apply_lock:
        with db() as conn:
            q = f"SELECT * FROM edits WHERE book_id = ? AND id IN ({','.join('?' * len(edit_ids))}) ORDER BY id"
            edits = [dict(r) for r in conn.execute(q, (book_id, *edit_ids))]
        ep = Epub(info["epub"])
        results = {}
        for e in edits:
            try:
                results[e["id"]] = ("applied", ep.apply(e))
            except Exception as ex:  # noqa: BLE001
                results[e["id"]] = ("failed", str(ex))
        if ep.changed:
            bdir = os.path.join(BACKUPS, str(book_id))
            os.makedirs(bdir, exist_ok=True)
            stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
            shutil.copy2(info["epub"], os.path.join(bdir, f"{stamp}.epub"))
            ep.save()
            touch_calibre(book_id, "EPUB", info["epub"])
        with db() as conn:
            for eid, (status, msg) in results.items():
                if status == "applied":
                    conn.execute("UPDATE edits SET status='applied', error=NULL, note=?, applied_at=? WHERE id=?",
                                 (msg, now(), eid))
                else:
                    conn.execute("UPDATE edits SET status='failed', error=? WHERE id=?", (msg, eid))
    if ep.changed:
        others = [f for f in info["formats"] if f != "EPUB"]
        if others and CONVERT:
            threading.Thread(target=reconvert, args=(book_id, info, others), daemon=True).start()
    return results


def touch_calibre(book_id, fmt, path):
    """Update size and last_modified so calibre-web/OPDS notice the change."""
    try:
        with calibre_db(write=True) as c:
            c.execute("UPDATE data SET uncompressed_size=? WHERE book=? AND format=?",
                      (os.path.getsize(path), book_id, fmt))
            c.execute("UPDATE books SET last_modified=? WHERE id=?",
                      (datetime.datetime.now(datetime.timezone.utc).isoformat(sep=" "), book_id))
    except Exception:  # noqa: BLE001
        traceback.print_exc()


def reconvert(book_id, info, formats):
    for fmt in formats:
        target = info["formats"][fmt]
        try:
            with tempfile.TemporaryDirectory() as td:
                out = os.path.join(td, "out." + fmt.lower())
                subprocess.run([CONVERT, info["epub"], out], check=True,
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=1800)
                shutil.copyfile(out, target)
            touch_calibre(book_id, fmt, target)
            print(f"reconverted book {book_id} -> {fmt}", flush=True)
        except Exception:  # noqa: BLE001
            traceback.print_exc()


# --------------------------------------------------------------------------
# web UI

CSS = """
:root{--bg:#faf8f4;--fg:#222;--mut:#6b665e;--card:#fff;--line:#e4dfd6;--del:#fbd9d6;--delfg:#8a1c12;
--ins:#d5f0d9;--insfg:#15541f;--acc:#3a5f8f;--warn:#9a5b00}
@media (prefers-color-scheme:dark){:root{--bg:#1b1a18;--fg:#e8e4dc;--mut:#9d978c;--card:#252320;--line:#3a3732;
--del:#5a2320;--delfg:#ffb4ac;--ins:#1f4526;--insfg:#a9e6b3;--acc:#8fb3e0;--warn:#e0a24a}}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--fg);font:15px/1.5 system-ui,sans-serif;padding:0 16px}
main{max-width:860px;margin:0 auto;padding:24px 0 64px}a{color:var(--acc)}h1{font-size:1.4em;margin:.2em 0}
.mut{color:var(--mut);font-size:.9em}table{width:100%;border-collapse:collapse}td,th{padding:8px 6px;border-bottom:1px solid var(--line);text-align:left;vertical-align:top}
.card{background:var(--card);border:1px solid var(--line);border-radius:10px;padding:14px 16px;margin:14px 0}
.ctx{font-family:Georgia,serif;font-size:1.02em}.ctx .c{color:var(--mut)}
del{background:var(--del);color:var(--delfg);text-decoration:line-through}ins{background:var(--ins);color:var(--insfg);text-decoration:none}
textarea{width:100%;font:inherit;font-family:Georgia,serif;min-height:3.2em;padding:6px;border:1px solid var(--line);border-radius:6px;background:var(--bg);color:var(--fg)}
.row{display:flex;gap:12px;flex-wrap:wrap;align-items:center;margin-top:8px}
.badge{font-size:.8em;padding:1px 7px;border-radius:9px;border:1px solid var(--line)}.warn{color:var(--warn)}
button{font:inherit;padding:6px 14px;border-radius:6px;border:1px solid var(--line);background:var(--card);color:var(--fg);cursor:pointer}
button.primary{background:var(--acc);color:var(--bg);border-color:var(--acc)}
.bar{position:sticky;bottom:0;background:var(--bg);padding:12px 0;border-top:1px solid var(--line);display:flex;gap:10px;flex-wrap:wrap}
label.opt{display:inline-flex;gap:5px;align-items:center}input[type=text]{font:inherit;padding:5px;width:100%;max-width:420px}
"""


def page(title, body):
    return f"""<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{html.escape(title)}</title><style>{CSS}</style></head><body><main>{body}</main></body></html>"""


def esc(s):
    return html.escape(s or "")


def diff_html(a, b):
    out = []
    # word-level is easier to read
    aw, bw = re.findall(r"\s+|\w+|[^\w\s]", a), re.findall(r"\s+|\w+|[^\w\s]", b)
    sm = difflib.SequenceMatcher(None, aw, bw, autojunk=False)
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == "equal":
            out.append(esc("".join(aw[i1:i2])))
        if tag in ("delete", "replace"):
            out.append(f"<del>{esc(''.join(aw[i1:i2]))}</del>")
        if tag in ("insert", "replace"):
            out.append(f"<ins>{esc(''.join(bw[j1:j2]))}</ins>")
    return "".join(out)


def render_index():
    with db() as conn:
        rows = conn.execute("""
            SELECT book_id, max(book_title) t, max(book_authors) a,
                   sum(status='pending') p, sum(status='failed') f, sum(status='applied') ap,
                   max(received_at) last
            FROM edits GROUP BY coalesce(book_id, -id) ORDER BY (sum(status IN ('pending','failed'))>0) DESC, last DESC""").fetchall()
    books = {}
    try:
        books = {b["id"]: b for b in all_books()}
    except Exception:  # noqa: BLE001
        pass
    trs = []
    for r in rows:
        b = books.get(r["book_id"])
        title = b["title"] if b else r["t"]
        authors = b["authors"] if b else r["a"]
        link = f"{BASE}/book/{r['book_id']}" if r["book_id"] else f"{BASE}/unmatched"
        flag = "" if b else ' <span class="badge warn">not matched</span>'
        trs.append(f"""<tr><td><a href="{link}">{esc(title)}</a>{flag}<div class="mut">{esc(authors)}</div></td>
<td>{r['p'] or 0}</td><td>{('<span class=warn>' + str(r['f']) + '</span>') if r['f'] else 0}</td><td>{r['ap'] or 0}</td>
<td class="mut">{esc((r['last'] or '')[:16].replace('T', ' '))}</td></tr>""")
    body = f"""<h1>Book fixes</h1><p class="mut">Corrections sent from KOReader. Pick a book to review.</p>
<table><tr><th>Book</th><th>Pending</th><th>Failed</th><th>Applied</th><th>Last received</th></tr>
{''.join(trs) or '<tr><td colspan=5 class=mut>Nothing yet.</td></tr>'}</table>"""
    return page("Book fixes", body)


def render_book(book_id, flash=""):
    info = book_info(book_id)
    with db() as conn:
        edits = [dict(r) for r in conn.execute(
            "SELECT * FROM edits WHERE book_id = ? ORDER BY status='applied', status='rejected', id", (book_id,))]
    if not info:
        return page("Not found", "<p>No such book.</p>")
    ep, ep_err = None, ""
    try:
        ep = Epub(info["epub"]) if info["epub"] else None
    except Exception as ex:  # noqa: BLE001
        ep_err = str(ex)
    cards = []
    open_count = 0
    for e in edits:
        st = e["status"]
        is_open = st in ("pending", "failed")
        open_count += is_open
        if is_open and ep:
            pv = ep.preview(e)
        else:
            pv = {}
        if pv.get("current") is not None:
            cur = pv["current"]
            ctx = (f'<div class="ctx"><span class="c">…{esc(pv["before"])}</span>'
                   f'{diff_html(cur, norm(e["replacement"]))}<span class="c">{esc(pv["after"])}…</span></div>')
            where = f'<span class="badge">matched: {esc(pv["method"])}</span>'
            if norm(cur) != norm(e["original"]):
                where += ' <span class="badge warn">book text differs slightly from selection</span>'
        else:
            ctx = (f'<div class="ctx"><span class="c">…{esc(e["ctx_before"])}</span>'
                   f'{diff_html(norm(e["original"]), norm(e["replacement"]))}<span class="c">{esc(e["ctx_after"])}…</span></div>')
            where = f'<span class="badge warn">{esc(pv.get("error"))}</span>' if pv.get("error") else ""
        meta = f'<span class="mut">#{e["id"]} · {esc(e["device"])} · {esc((e["created_at"] or e["received_at"])[:16].replace("T", " "))}</span>'
        if is_open:
            err = f'<div class="warn">Last attempt failed: {esc(e["error"])}</div>' if st == "failed" else ""
            cards.append(f"""<div class="card">{ctx}{err}
<details><summary class="mut">edit replacement</summary><textarea name="rep_{e['id']}">{esc(e['replacement'])}</textarea></details>
<div class="row">{meta} {where}<span style="flex:1"></span>
<label class="opt"><input type="radio" name="act_{e['id']}" value="approve" {'checked' if pv.get('current') is not None else ''}> approve</label>
<label class="opt"><input type="radio" name="act_{e['id']}" value="reject"> reject</label>
<label class="opt"><input type="radio" name="act_{e['id']}" value="skip" {'' if pv.get('current') is not None else 'checked'}> later</label>
</div></div>""")
        else:
            label = {"applied": "applied", "rejected": "rejected"}[st]
            cards.append(f"""<div class="card" style="opacity:.65">{ctx}<div class="row">{meta}
<span class="badge">{label}{(' · ' + esc(e['applied_at'][:16].replace('T', ' '))) if e['applied_at'] else ''}</span>
{f'<button name="reopen" value="{e["id"]}">reopen</button>' if st == 'rejected' else ''}</div></div>""")
    fmts = ", ".join(info["formats"]) or "none"
    body = f"""<p><a href="{BASE}/">← all books</a></p><h1>{esc(info['title'])}</h1>
<div class="mut">{esc(info['authors'])} · formats: {esc(fmts)}{' · <span class=warn>' + esc(ep_err) + '</span>' if ep_err else ''}</div>
{f'<div class="card">{flash}</div>' if flash else ''}
<form method="post" action="{BASE}/book/{book_id}">{''.join(cards) or '<p class=mut>No edits.</p>'}
{'<div class="bar"><button class="primary" name="do" value="apply">Apply approved &amp; save rejections</button><span class="mut">A backup of the EPUB is kept before writing.</span></div>' if open_count else ''}
</form>"""
    return page(info["title"], body)


def render_unmatched():
    with db() as conn:
        edits = [dict(r) for r in conn.execute("SELECT * FROM edits WHERE book_id IS NULL ORDER BY id")]
    opts = "".join(f'<option value="{b["id"]}">{esc(b["title"])} — {esc(b["authors"])}</option>' for b in all_books())
    cards = "".join(f"""<div class="card"><b>{esc(e['book_title'])}</b> <span class="mut">{esc(e['book_authors'])} · {esc(e['filename'])}</span>
<div class="ctx">{diff_html(norm(e['original']), norm(e['replacement']))}</div>
<div class="row"><select name="book_{e['id']}"><option value="">— assign to book —</option>{opts}</select>
<label class="opt"><input type="checkbox" name="del_{e['id']}" value="1"> discard</label></div></div>""" for e in edits)
    body = f"""<p><a href="{BASE}/">← all books</a></p><h1>Unmatched edits</h1>
<p class="mut">These couldn't be tied to a library book automatically.</p>
<form method="post" action="{BASE}/unmatched">{cards or '<p class=mut>None.</p>'}
{'<div class="bar"><button class="primary">Save</button></div>' if edits else ''}</form>"""
    return page("Unmatched", body)


# --------------------------------------------------------------------------
# HTTP

class Handler(BaseHTTPRequestHandler):
    server_version = "bookfix/1"

    def log_message(self, fmt, *args):
        print("%s %s" % (self.address_string(), fmt % args), flush=True)

    # auth: bearer token for the API, basic auth (any user, token as
    # password) for the browser UI.
    def authed(self):
        tok = token()
        h = self.headers.get("Authorization", "")
        if h.startswith("Bearer "):
            return secrets.compare_digest(h[7:].strip(), tok)
        if h.startswith("Basic "):
            import base64
            try:
                _, _, pw = base64.b64decode(h[6:]).decode().partition(":")
            except Exception:  # noqa: BLE001
                return False
            return secrets.compare_digest(pw, tok)
        return False

    def deny(self):
        self.send_response(401)
        self.send_header("WWW-Authenticate", 'Basic realm="bookfix"')
        self.send_header("Content-Length", "0")
        self.end_headers()

    def send(self, code, body, ctype="text/html; charset=utf-8"):
        data = body.encode() if isinstance(body, str) else body
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(data)

    def json(self, code, obj):
        self.send(code, json.dumps(obj), "application/json")

    def redirect(self, path):
        self.send_response(303)
        self.send_header("Location", BASE + path)
        self.send_header("Content-Length", "0")
        self.end_headers()

    def body(self):
        n = int(self.headers.get("Content-Length") or 0)
        if n > 5_000_000:
            raise ValueError("too large")
        return self.rfile.read(n)

    def path_only(self):
        p = urllib.parse.urlsplit(self.path).path
        if BASE and p.startswith(BASE):
            p = p[len(BASE):]
        return p or "/"

    def do_GET(self):
        if not self.authed():
            return self.deny()
        p = self.path_only()
        try:
            if p == "/api/ping":
                return self.json(200, {"ok": True})
            if p == "/":
                return self.send(200, render_index())
            if p == "/unmatched":
                return self.send(200, render_unmatched())
            m = re.fullmatch(r"/book/(\d+)", p)
            if m:
                return self.send(200, render_book(int(m.group(1))))
            self.send(404, page("Not found", "<p>Not found.</p>"))
        except Exception:  # noqa: BLE001
            traceback.print_exc()
            self.send(500, page("Error", f"<pre>{esc(traceback.format_exc())}</pre>"))

    def do_POST(self):
        if not self.authed():
            return self.deny()
        p = self.path_only()
        try:
            if p == "/api/edits":
                return self.api_edits()
            # browser form posts: refuse cross-site
            origin = self.headers.get("Origin")
            if origin and urllib.parse.urlsplit(origin).netloc != self.headers.get("Host"):
                return self.send(403, "cross-origin post refused", "text/plain")
            form = urllib.parse.parse_qs(self.body().decode(), keep_blank_values=True)
            f = {k: v[-1] for k, v in form.items()}
            if p == "/unmatched":
                return self.post_unmatched(f)
            m = re.fullmatch(r"/book/(\d+)", p)
            if m:
                return self.post_book(int(m.group(1)), f)
            self.send(404, "not found", "text/plain")
        except Exception:  # noqa: BLE001
            traceback.print_exc()
            self.send(500, page("Error", f"<pre>{esc(traceback.format_exc())}</pre>"))

    def api_edits(self):
        payload = json.loads(self.body() or b"{}")
        accepted = []
        with db() as conn:
            for e in payload.get("edits", []):
                uid = str(e.get("uid") or "")
                if not uid or not e.get("original") or e.get("replacement") is None:
                    continue
                if conn.execute("SELECT 1 FROM edits WHERE uid=?", (uid,)).fetchone():
                    accepted.append(uid)
                    continue
                bid = match_book(e.get("title"), e.get("authors"), e.get("identifiers"), e.get("filename"))
                conn.execute("""INSERT INTO edits (uid, device, created_at, received_at, book_id, book_title,
                    book_authors, identifiers, filename, pos0, pos1, original, replacement, ctx_before, ctx_after)
                    VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
                             (uid, payload.get("device"), e.get("created_at"), now(), bid, e.get("title"),
                              e.get("authors"), e.get("identifiers"), e.get("filename"), e.get("pos0"),
                              e.get("pos1"), e["original"], e["replacement"], e.get("ctx_before"),
                              e.get("ctx_after")))
                accepted.append(uid)
        self.json(200, {"accepted": accepted})

    def post_book(self, book_id, f):
        if "reopen" in f:
            with db() as conn:
                conn.execute("UPDATE edits SET status='pending' WHERE id=? AND book_id=?", (int(f["reopen"]), book_id))
            return self.redirect(f"/book/{book_id}")
        approve, reject = [], []
        with db() as conn:
            for k, v in f.items():
                if not k.startswith("act_"):
                    continue
                eid = int(k[4:])
                rep = f.get(f"rep_{eid}")
                if rep is not None:
                    conn.execute("UPDATE edits SET replacement=? WHERE id=? AND book_id=?", (rep, eid, book_id))
                if v == "approve":
                    approve.append(eid)
                elif v == "reject":
                    reject.append(eid)
            for eid in reject:
                conn.execute("UPDATE edits SET status='rejected' WHERE id=? AND book_id=?", (eid, book_id))
        flash = ""
        if approve:
            res = apply_book_edits(book_id, approve)
            ok = sum(1 for s, _ in res.values() if s == "applied")
            bad = {k: m for k, (s, m) in res.items() if s != "applied"}
            flash = f"Applied {ok} edit(s)."
            if bad:
                flash += " <span class=warn>Failed: " + "; ".join(f"#{k}: {esc(m)}" for k, m in bad.items()) + "</span>"
            if ok and CONVERT and len(book_info(book_id)["formats"]) > 1:
                flash += " Other formats are being regenerated in the background."
        elif reject:
            flash = f"Rejected {len(reject)} edit(s)."
        self.send(200, render_book(book_id, flash))

    def post_unmatched(self, f):
        with db() as conn:
            for k, v in f.items():
                if k.startswith("del_") and v:
                    conn.execute("DELETE FROM edits WHERE id=? AND book_id IS NULL", (int(k[4:]),))
                elif k.startswith("book_") and v:
                    conn.execute("UPDATE edits SET book_id=? WHERE id=? AND book_id IS NULL", (int(v), int(k[5:])))
        self.redirect("/")


def main():
    init_state()
    srv = ThreadingHTTPServer(("127.0.0.1", PORT), Handler)
    print(f"bookfix listening on 127.0.0.1:{PORT}{BASE or '/'} library={LIBRARY}", flush=True)
    srv.serve_forever()


if __name__ == "__main__":
    main()
