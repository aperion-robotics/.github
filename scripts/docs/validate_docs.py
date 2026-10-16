#!/usr/bin/env python3
import re,json,sys
from pathlib import Path
r=Path(__file__).resolve().parents[2] if Path(__file__).resolve().parent.name=='docs' and Path(__file__).resolve().parent.parent.name=='scripts' else Path(__file__).resolve().parents[1]
nav=json.loads((r/'tools/navigation.json' if (r/'tools/navigation.json').exists() else r/'scripts/docs/navigation.json').read_text());errors=[]
for slug,title in nav:
 p=r/'docs/handbook'/f'{slug}.md'
 if not p.exists():errors.append(f'Missing {p}');continue
 for link in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  if link.startswith(('http://','https://','#','mailto:')):continue
  if not (p.parent/link.split('#')[0]).exists():errors.append(f'Broken link {p}: {link}')
 for q in [r/'docs/site'/f'{slug}.html',r/'docs/wiki-export'/f'{"Home" if slug=="index" else slug}.md']:
  if not q.exists():errors.append(f'Missing {q}')
if errors:print('\n'.join(errors));sys.exit(1)
print(f'Validation passed: {len(nav)} handbook pages and exports.')
