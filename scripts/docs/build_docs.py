#!/usr/bin/env python3
"""Generate HTML and Wiki exports from Markdown. Needs mistune."""
import html,json,re,sys
from pathlib import Path
r=Path(__file__).resolve().parents[2] if Path(__file__).resolve().parent.name=='docs' and Path(__file__).resolve().parent.parent.name=='scripts' else Path(__file__).resolve().parents[1]
try:import mistune
except ImportError:sys.exit('Install mistune in a Python venv before rebuilding: python3 -m venv .venv && .venv/bin/pip install mistune')
nav=json.loads((r/'tools/navigation.json' if (r/'tools/navigation.json').exists() else r/'scripts/docs/navigation.json').read_text())
src=r/'docs/handbook';web=r/'docs/site';wiki=r/'docs/wiki-export';web.mkdir(parents=True,exist_ok=True);wiki.mkdir(parents=True,exist_ok=True)
css='''*{box-sizing:border-box}body{margin:0;background:#f5f7fb;color:#1b2938;font:16px/1.65 system-ui,sans-serif}header{background:#102c45;color:white;padding:19px 28px;font-weight:700;letter-spacing:.3px}header b{color:#54cfc4}.layout{max-width:1440px;margin:auto;display:grid;grid-template-columns:265px minmax(0,1fr)}aside{background:white;padding:25px 12px;border-right:1px solid #ddd;min-height:100vh}aside a{display:block;color:#234760;text-decoration:none;padding:9px 13px;border-radius:6px}aside a.active{background:#e4f4f5;font-weight:700;color:#006979}main{padding:30px;max-width:1090px}article{background:white;border:1px solid #e1e7ec;border-radius:9px;padding:36px 44px;box-shadow:0 4px 16px #102c450e}h1,h2,h3{line-height:1.28;color:#12344f}h2{margin-top:35px;border-bottom:1px solid #e8eef3;padding-bottom:7px}a{color:#076eaa}pre{padding:17px;background:#132436;color:#e7f3f9;overflow:auto;border-radius:8px;font-size:14px}code{font-family:Consolas,monospace;background:#edf1f3;padding:2px 4px}pre code{background:none;padding:0}blockquote{margin:20px 0;background:#eef9f8;border-left:4px solid #009b9b;padding:10px 17px}table{width:100%;border-collapse:collapse;font-size:14px}td,th{border:1px solid #dce5e9;padding:9px;text-align:left}th{background:#eef5f7}footer{font-size:12px;color:#667;margin-top:25px}@media(max-width:850px){.layout{display:block}aside{min-height:auto}main{padding:12px}article{padding:20px}}'''
(web/'style.css').write_text(css + '\n')
render=mistune.create_markdown(plugins=['table','url'])
for slug,title in nav:
 text=(src/(slug+'.md')).read_text();body=render(text)
 body=re.sub(r'href="([a-z0-9-]+)\.md"',r'href="\1.html"',body)
 menu=''.join(f'<a class="{"active" if k==slug else ""}" href="{k}.html">{html.escape(v)}</a>' for k,v in nav)
 (web/(slug+'.html')).write_text(f'<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>{html.escape(title)} | Aperion</title><link rel="stylesheet" href="style.css"></head><body><header>APERION <b>ROBOTICS</b> / Developer Handbook</header><div class="layout"><aside><strong>CONTENTS</strong>{menu}</aside><main><article>{body}</article><footer>Generated from docs/handbook Markdown.</footer></main></div></body></html>\n')
 wikibody=re.sub(r'\]\(([a-z0-9-]+)\.md\)',lambda m: ']('+('Home' if m.group(1)=='index' else m.group(1))+')',text)
 (wiki/(('Home' if slug=='index' else slug)+'.md')).write_text(wikibody)
(wiki/'_Sidebar.md').write_text('## Developer Handbook\n\n'+''.join(f'- [{title}]({"Home" if slug=="index" else slug})\n' for slug,title in nav))
print(f'Generated {len(nav)} HTML and Wiki pages.')
