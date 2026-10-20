import struct,pathlib
class Reader:
 def __init__(self,d,p=0):self.d=d;self.p=p
 def i32(self):v=struct.unpack_from('<i',self.d,self.p)[0];self.p+=4;return v
 def u32(self):v=struct.unpack_from('<I',self.d,self.p)[0];self.p+=4;return v
 def compact(self):
  b=self.d[self.p];self.p+=1;v=b&63;sign=b&128;more=b&64;shift=6
  while more:
   b=self.d[self.p];self.p+=1;v|=(b&127)<<shift;more=b&128;shift+=7
  return -v if sign else v
 def string(self):
  n=self.compact();k=abs(n)*(2 if n<0 else 1);v=self.d[self.p:self.p+k];self.p+=k
  return v.decode('utf-16le' if n<0 else 'latin1').rstrip('\0')
def compact(v):
 n=abs(v);b=(n&63)|(128 if v<0 else 0);n>>=6;out=bytearray([b|(64 if n else 0)])
 while n:
  b=n&127;n>>=7;out.append(b|(128 if n else 0))
 return bytes(out)
class Package:
 def __init__(self,p):
  self.path=pathlib.Path(p);self.d=self.path.read_bytes()
  self.nc,self.no,self.ec,self.eo,self.ic,self.io=struct.unpack_from('<6i',self.d,12)
  r=Reader(self.d,self.no);self.names=[]
  for _ in range(self.nc):self.names.append((r.string(),r.u32()))
  r=Reader(self.d,self.io);self.imp=[]
  for _ in range(self.ic):self.imp.append(dict(cp=r.compact(),cn=r.compact(),outer=r.i32(),name=r.compact()))
  r=Reader(self.d,self.eo);self.exp=[]
  for _ in range(self.ec):
   start=r.p;e=dict(cls=r.compact(),super=r.compact(),outer=r.i32(),name=r.compact(),flags=r.u32(),size=r.compact())
   e['offset']=r.compact() if e['size'] else 0;e['start']=start;e['end']=r.p;self.exp.append(e)
 def obj(self,i):
  if not i:return ''
  e=self.exp[i-1] if i>0 else self.imp[-i-1];s=self.names[e['name']][0]
  return (self.obj(e['outer'])+'.' if e['outer'] else '')+s
 def payload(self,e):return self.d[e['offset']:e['offset']+e['size']]
