unit funcu;

interface
uses compu,sport,vectorD,varu,complex2;
type
  Tfunc = object(Tcomp)
   v1,v2 : double;
   vars,funksie : integer;
   dvars : array of Tdvar;
   Bmin,Bmax : double;
   FB : boolean;
   data : tmat;
   Dlen : integer;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer);virtual; 
   constructor create(P : pointer);
   Procedure load(Np : integer;P : Tparams);virtual;
   Procedure update;
  Procedure lookup(z : double;var x1,x2 : integer;var w1,w2 : double);
   Procedure exportQucs(var f : text);virtual;
  end;
  Tmeas= object(Tcomp)
   vars,funksie : integer;
   dvars : array of Toutvar;
   once : boolean;
   function getOutput(w : double;V0,Z0 : cvec;wat : integer) : tc; virtual;
   Procedure load(Np : integer;P : Tparams);virtual;
  
  
  end;  
  
Pfunc = ^Tfunc;
Pmeas = ^Tmeas;

   
procedure readDvar(var D : Tdvar;ss : string;sp : Psport);


implementation
uses sysutils,stringe,math;
var
 datas : array of tmat;
 sdata : array of string;
 ndata : integer;

procedure readDvar(var D : Tdvar;ss : string;Sp : Psport);
var
 i,x,j : integer;
 s,s2,s3 : string;
 C : pcomp;
begin
  D.lmin:=false;
  D.lmax:=false;
  D.lstp:=false;
  i:=pos('(',ss);if i>0 then begin
   s:=copy(ss,i+1,length(ss)-i-1);
   delete(ss,i,length(ss)-i+1);
   i:=pos(',',s);
   if i=0 then s2:='' else
      begin
      s2:=copy(s,i+1,length(s)-i);
      delete(s,i,length(s)-i+1);
      j:=pos(',',s2);
      if j>0 then begin
       s3:=copy(s2,j+1,length(s2)-j);
       delete(s2,j,length(s2)-j+1);
       D.stp:=strtofloat(s3);
       D.lstp:=(D.stp>0);
//       writeln('s=',s,' s2=',s2,' s3=',s3);
       end;
    end;
    if s<>''  then begin;D.lmin:=true;D.min:=strtofloat(s);end;
    if s2<>'' then begin;D.lmax:=true;D.max:=strtofloat(s2);end;
  end;

  s:=splitdp(ss);
  if s='FP' then C:=SP^.PClayout 
     else C:=SP^.findcomp(s);
  if c=nil then begin
    writeln(sp^.name,' Can not find component ',s);
    halt(1);
    end;
  D.C:=C;
  D.wat:=D.C^.Paramnum(ss);
//  if not(D.C^.paramdouble(d.wat)) then write('string');
  if D.wat=0 then begin
    writeln(sp^.name,' Can not find parameter ',ss,' of component ',s);
    halt(1);
    end;
end;




function readdata(fn : string) : tmat;
var
 f : text;
 s : string;
 s2 : tstrings;
 l1,l2,x,y : integer;
begin
for x:=0 to ndata-1 do if sdata[x]=fn then begin
    readdata:=datas[x];
//    writeln('Re-use ',x+1);
    exit;
    end;
setlength(datas,ndata+1);
setlength(sdata,ndata+1);
sdata[ndata]:=fn;

//writeln('funcion: loading ',fn);
write('Load: ',fn);
assign(f,fn);reset(f);
readln(f,s);
s2:=strtostrs(s);
l1:=len(s2);
l2:=1;
while not(eof(f)) do begin
 readln(f,s);
 inc(l2);
 end;
RMsetsize(l2,l1,datas[ndata]); 
reset(f);
for x:=0 to l2-1 do begin
  readln(f,s);
  s2:=strtostrs(s);
  if len(s2)<>l1 then begin;writeln('Error reading data file - not a matrix');halt(1);end;
  for y:=0 to l1-1 do datas[ndata,x,y]:=strtofloat(s2[y+1]);
  end;
//RMwriteE(l2,l1,data);
writeln(' ',l2,'x',l1);
close(f);
readdata:=datas[ndata];
inc(ndata);
end;


constructor tfunc.create(P : pointer);
begin inherited create(P);Nnode:=0; end;

Procedure Tfunc.load(Np : integer;P : Tparams);
var
 i : integer;
begin
//for i:=0 to Np-1 do writeln(P[i].name,'   ',P[i].value);
funksie:=round(getparm(Np,P,'TYPE',0));
vars:=0;
for i:=0 to Np-1 do if P[i].name='' then begin
 inc(vars);
 setlength(dvars,vars);
 readDvar(dvars[vars-1],P[i].value,psport(parent));
 with dvars[vars-1] do begin
  if not(lmax) then max:=0;
  if not(lmin) then min:=0;
  end;
// with dvars[vars-1] do writeln('Var ',vars,': ',C^.name,'=',C^.getD(wat));
 end; 
v1:=getparm(Np,P,'V1',0);
v2:=getparm(Np,P,'V2',0);
Bmin:=getparm(Np,P,'BMIN',0);
Bmax:=getparm(Np,P,'BMAX',0);

if funksie in [3,4] then for i:=0 to Np-1 do if P[i].name='DATA' then begin
  data:=readdata(P[i].value);
  Dlen:=length(data);
  end;

FB:=Bmax>Bmin;
//writeln('funksie=',funksie,' vars=',vars);
update;

end;

function Tfunc.paramnum(s : string) : integer;
begin
if s='1' then paramnum:=1 else
if s='2' then paramnum:=2 else
if s='BMIN' then paramnum:=3 else
if s='BMAX' then paramnum:=4 else paramnum:=0;
end;
function Tfunc.paramstr(wat : integer) : string; 
begin
 case wat of 
 1 : paramstr:='1';
 2 : paramstr:='2';
 3 : paramstr:='BMIN';
 4 : paramstr:='BMAX';
 else paramstr:='';
 end;
end;

function Tfunc.getD(wat : integer) : double; 
begin
case wat of 
 1 : getD:=v1;
 2 : getD:=v2;
 3 : getD:=Bmin;
 4 : getD:=Bmax;
 end;
end;

Procedure Tfunc.setD(z : double;wat : integer);
begin
//writeln('Set z=',z,' wat=',wat);
case wat of
 1 : if z<>v1 then begin;v1:=z;if fb then if v1<Bmin then v1:=Bmin else if v1>Bmax then v1:=Bmax;update;end;
 2 : if z<>v2 then begin;v2:=z;update;end;
 3 : if z<>bmin then begin;fb:=true;bmin:=z;update;end;
 4 : if z<>bmax then begin;fb:=true;bmax:=z;update;end;
 end;
end; 

Procedure Tfunc.lookup(z : double;var x1,x2 : integer;var w1,w2 : double);
var
 mid : integer;
begin
if z<=data[0,0] then begin;x1:=0;x2:=0;w1:=1;w2:=0;exit;end;
if z>=data[Dlen-1,0] then begin;x1:=Dlen-1;x2:=Dlen-1;w1:=1;w2:=0;exit;end;
 x1:=0;x2:=Dlen-1;
 while x2>x1+1 do begin
  mid:=(x2+x1) div 2;
  if data[mid,0]>z then x2:=mid else x1:=mid;
  end;
 w2:=(z-data[x1,0])/(data[x2,0]-data[x1,0]);
 w1:=1-w2;
end;

Procedure Tfunc.update;
var
 res,w1,w2 : double;
 i,x1,x2 : integer;
begin
{
for i:=1 to vars do
 with dvars[i-1] do writeln('Var ',i,': ',C^.name,'=',C^.getD(wat));
}
if funksie=3 then begin
  if v1<data[0,0] then v1:=data[0,0];
 // if v1>data[Dlen-1,0] then v1:=data[Dlen-1,0];
  lookup(v1,x1,x2,w1,w2); 
  end;
if funksie=4 then if v1<1 then v1:=1 else if v1>Dlen then v1:=Dlen;
//if funksie=3 then writeln('lookup ',v1,' : x1=',x1,' x2=',x2,' w1=',w1,' w2=',w2);
 for i:=0 to vars-1 do with dvars[i] do begin
  case funksie of 
   0 : res:=min*v1+max*v2;
   1 : res:=min*v1*power(v2,max);
   2 : if abs(v1)<1e-20 then res:=1e99 else res:=min/v1;
   3 : res:=data[x1,round(min)]*w1+data[x2,round(min)]*w2;
   4 : res:=data[round(v1)-1,round(min)-1];
   else res:=0;
   end;
   if FB then if res<Bmin then res:=Bmin else if res>Bmax then res:=Bmax;
   c^.setD(res,wat);
   end;
{for i:=1 to vars do
 with dvars[i-1] do writeln('Var ',i,': ',C^.name,'=',C^.getD(wat));
}
end;
   Procedure Tfunc.exportQucs(var f : text);
   begin
   end;

Procedure Tmeas.load(Np : integer;P : Tparams);
var
 i : integer;
begin
//for i:=0 to Np-1 do writeln(P[i].name,'   ',P[i].value);
funksie:=round(getparm(Np,P,'TYPE',0));
once:=(getparm(Np,P,'ONCE',0))=1;
vars:=0;
for i:=0 to Np-1 do if P[i].name='' then begin
 inc(vars);
 setlength(dvars,vars);
 dvars[vars-1]:=psport(parent)^.readoutvar(P[i].value);
 end;

case funksie of
 1 : if vars<>5 then begin;writeln('Measure ',name,' function ',funksie,' need 5 variables!');halt(1);end;
 2,3,4 : if vars<>2 then begin;writeln('Measure ',name,' function ',funksie,' need 5 variables!');halt(1);end;
 else begin;writeln('Measure ',name,' unkown function ',funksie);halt(1);end;
 end;
writeln('Measure ',name,' func=',funksie,' loaded!');
end;

function Tmeas.getOutput(w : double;V0,Z0 : cvec;wat : integer) : tc;
var
 x : integer;
begin
for x:=0 to vars-1 do  psport(parent)^.getoutvar(dvars[x],w,V0,Z0);
case funksie of
 1 : getOutput:=ccomp(dvars[0].oldv) * ((dvars[1].oldv)+dvars[2].oldv) / (ccomp(dvars[3].oldv)+dvars[4].oldv) ;
 2 : getOutput:=dvars[0].oldv / dvars[1].oldv;
 3 : getOutput:=dvars[0].oldv - dvars[1].oldv;
 4 : getOutput:=dvars[0].oldv * dvars[1].oldv;
 end;
end;

begin
 ndata:=0;
end.