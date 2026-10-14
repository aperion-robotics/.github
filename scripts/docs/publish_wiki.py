#!/usr/bin/env python3
"""Publish generated GitHub wiki files explicitly after review/merge."""
import argparse,subprocess,tempfile,shutil
from pathlib import Path
r=Path(__file__).resolve().parents[2] if Path(__file__).resolve().parent.name=='docs' and Path(__file__).resolve().parent.parent.name=='scripts' else Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--publish',action='store_true');a=p.parse_args()
def cmd(*args,cwd=None):
 print('+',' '.join(args));return subprocess.run(args,cwd=cwd,check=True)
with tempfile.TemporaryDirectory() as temp:
 w=Path(temp)/'wiki';cmd('git','clone','https://github.com/aperion-robotics/.github.wiki.git',str(w))
 for f in (r/'docs/wiki-export').glob('*.md'):shutil.copy2(f,w/f.name)
 cmd('git','add','--all',cwd=w)
 if subprocess.run(['git','diff','--cached','--quiet'],cwd=w).returncode==0:print('No wiki changes');raise SystemExit
 cmd('git','diff','--cached','--stat',cwd=w)
 if not a.publish:print('Preview only; append --publish after review and main merge.');raise SystemExit
 cmd('git','commit','-m','docs: publish Developer Handbook',cwd=w);cmd('git','push','origin','HEAD',cwd=w)
