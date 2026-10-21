from unreal_package import *
def tags(p,d,start=0):
 r=Reader(d,start);out=[]
 while True:
  begin=r.p;idx=r.compact();assert 0<=idx<len(p.names)
  name=p.names[idx][0]
  if name=='None':return out,r.p
  info=d[r.p];r.p+=1;typ=info&15;assert 1<=typ<=15
  structname=None
  if typ==10:
   sn=r.compact();assert 0<=sn<len(p.names);structname=p.names[sn][0]
  sc=(info>>4)&7
  if sc<5:size=[1,2,4,12,16][sc]
  elif sc==5:size=d[r.p];r.p+=1
  elif sc==6:size=struct.unpack_from('<H',d,r.p)[0];r.p+=2
  else:size=r.u32()
  index=None
  if info&128 and typ!=3:index=r.compact()
  if typ==3:size=0
  data=d[r.p:r.p+size];assert len(data)==size;r.p+=size
  out.append(dict(name=name,type=typ,index=index,struct=structname,data=data,info=info,start=begin,end=r.p))
_property_types=None
def class_defaults(p,e):
 global _property_types
 if _property_types is None: raise ValueError("Supply the runtime property type map before parsing defaults")
 d=p.payload(e);candidates=[]
 for i in range(len(d)):
  try:
   t,end=tags(p,d,i)
   if t and end==len(d) and all(x['type'] in _property_types.get(x['name'],set()) for x in t):candidates.append((i,t))
  except (AssertionError,IndexError,struct.error):pass
 assert candidates
 return min(candidates,key=lambda x:x[0])
