"""Lexical UnrealScript checks; comments and strings never create code blocks."""
import re
from collections import defaultdict

def mask(s):
 out=list(s);i=0
 while i<len(s):
  if s.startswith('//',i):
   z=s.find('\n',i);z=len(s) if z<0 else z
  elif s.startswith('/*',i):
   z=s.find('*/',i+2);assert z>=0;z+=2
  elif s[i] in ['"',"'"]:
   q=s[i];z=i+1
   while z<len(s):
    if s[z]=='\\':z+=2;continue
    if s[z]==q:z+=1;break
    z+=1
  else:i+=1;continue
  for j in range(i,z):
   if s[j]!='\n':out[j]=' '
  i=z
 return ''.join(out)

def blocks(source):
 m=mask(source);ranges=[]
 pat=r'(?im)^[ \t]*(?:(?:simulated|exec|final|static|native(?:\(\d+\))?|singular|latent)\s+)*(function|event)\s+(?:\w+\s+)?(\w+)\s*\('
 matches=[(match,match[1].lower(),match[2]) for match in re.finditer(pat,m)]
 matches += [(match,'state',match[1]) for match in re.finditer(r'(?im)^[ \t]*(?:auto\s+)?state(?:\(\))?\s+(\w+)(?:\s+extends\s+\w+)?\s*\{',m)]
 for match,kind,name in matches:
  b=m.find('{',match.start());semi=m.find(';',match.start())
  if b<0 or semi>=0 and semi<b:continue
  z=b+1;depth=1
  while depth:depth+=(m[z]=='{')-(m[z]=='}');z+=1
  ranges.append(dict(kind=kind,name=name,start=match.start(),body=b,end=z))
 return ranges

def calls(source):
 m=mask(source);ranges=blocks(source);found=[]
 pattern=r"\b(?:Logf?|Warn)\s*\(|class\s*'FlightVisualLog\.AutoLog'\s*\.\s*static\s*\.\s*(?:Start|Write|Close|SetEnabled)\s*\("
 for match in re.finditer(pattern,source,re.I):
  if m[match.start()].isspace():continue
  within=[r for r in ranges if r['body']<match.start()<r['end']]
  f=[r['name'] for r in within if r['kind']!='state'];st=[r['name'] for r in within if r['kind']=='state']
  if not f:continue
  b=source.index('(',match.start());z=b+1;depth=1
  while depth:depth+=(m[z]=='(')-(m[z]==')');z+=1
  end=z
  while end<len(source) and source[end].isspace():end+=1
  assert source[end]==';',(source[match.start():end+40]);end+=1
  assert f,(match[0],source[match.start():end])
  text=source[match.start():end];lits=re.findall(r'"(?:\\.|[^"\\])*"',text)
  found.append(dict(start=match.start(),end=end,function='.'.join(st+[f[-1]]),text=text,signature=lits[0] if lits else re.sub(r'\s+','',text)))
 return found

def method_map(s):
 bs=blocks(s);out=defaultdict(list)
 for b in bs:
  if b['kind']=='state':continue
  states=[x['name'] for x in bs if x['kind']=='state' and x['body']<b['start']<x['end']]
  key='.'.join(states+[b['name']]);out[key].append(b)
 return out

def read_source(path):
    from pathlib import Path
    data=Path(path).read_bytes()
    if data[:2] in [b"\xff\xfe",b"\xfe\xff"]: s=data.decode("utf16")
    else:
        try: s=data.decode("utf-8-sig")
        except UnicodeDecodeError: s=data.decode("gb18030")
    return s.replace("\r\r\n","\n").replace("\r\n","\n")
