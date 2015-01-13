unit compu; 
interface
uses vectorD,complex2,FET,consts,stringe,varu;

type

 Tcomp = object(Tvars)
   Node : array of integer; //Node indeks
   NoiseI : integer; //Noise indeks
   Nnode,Nsrc,Nnoise,Nvar : integer;
   savedata,dorecalc,AlwaysUpdate : boolean;
   constructor create(P : pointer); 
   Procedure closecomp; virtual;
   Procedure load(Np : integer;P : Tparams); virtual;
   Procedure calclinks; virtual;
   function loads(ss : tstrings) : boolean; virtual;
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getS(w : double;var S : cmat); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
   Procedure getdY(w : double;v0 : cvec;var Y : cvec;wat : integer); virtual;
   Procedure getdS(w : double;v0 : cvec;var S : cvec;wat : integer); virtual;
   Procedure getdN(w : double;v0 : cmat;var N : cmat;wat : integer); virtual;
   function getparm(Np : integer;P : tparams;s : string;default : double) : double;
   function getYin(w : double;Z : cvec;prt : integer) : tc; virtual;
   function getReflect(w : double;Z : cvec;prt : integer) : tc; virtual;
   function getOutput(w : double;V0,Z0 : cvec;wat : integer) : tc; virtual;
   function getFoot(var wt,par : string;var pars : integer) : boolean; virtual;
   Procedure exportQucs(var f : text);virtual;
   Procedure exportVars(var f : text;prnt : string);virtual;
   Procedure recalc(w : double); virtual;
   procedure doUpdate(w : double;V0,Z0 : cvec;cnt : integer); virtual;
   function expnode(i : integer) : string;
   end;

 Pcomp = ^Tcomp;

 TCompcopy = object(Tcomp)
    cmp : Pcomp;
   constructor create(P : pointer;C : pcomp); 
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getS(w : double;var S : cmat); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
   Procedure getdY(w : double;v0 : cvec;var Y : cvec;wat : integer); virtual;
   Procedure getdS(w : double;v0 : cvec;var S : cvec;wat : integer); virtual;
   Procedure getdN(w : double;v0 : cmat;var N : cmat;wat : integer); virtual;
   function getFoot(var wt,par : string;var pars : integer) : boolean; virtual;
   Procedure exportQucs(var f : text);virtual;
  end;    

   
 Pcompcopy = ^Tcompcopy;
   

function getprm(s : string) : Tparam;
Procedure addblk(Y : cmat;x0,y0,x1,y1 : integer;Z : tc);
Procedure addblkR(Y : cmat;x0,y0,x1,y1 : integer;Z : tr);
Procedure savevar(f : string;D : tdvar;z : double;clear : boolean);
function loadvar(f : string;D : tdvar;var z : double) : boolean;
function loadvar2(f : string;D : string;var z : double) : boolean;


implementation
uses sysutils,sport,math;

function loadvar2(f : string;D : string;var z : double) : boolean;
var
 fn : text;
 s,s2,s3,s4 : string;
 x : integer;
begin
 x:=pos('(',D);
 if x>0 then D:=copy(D,1,x-1);
// writeln('D=',D);
 loadvar2:=false;
 assign(fn,f);
 {$i-}
 reset(fn);
 {$i+}
 if ioresult<>0 then exit;
 while not(eof(fn)) do begin
  readln(fn,s);
  x:=pos('=',s);
  if (x>0) and ( (copy(s,1,x-1)=D) ) then begin
      z:=strtofloat(copy(s,x+1,length(s)-x));
//      writeln('loadvar: ',s3,'=',z);
      loadvar2:=true;
      end;
 end;
close(fn);
 end;

function loadvar(f : string;D : tdvar;var z : double) : boolean;
var
 fn : text;
 s,s2,s3,s4 : string;
 x : integer;
begin
// writeln('loadvar');
 loadvar:=false;
 s3:=D.c^.name+':'+inttostr(D.wat);
// writeln('s3=',s3);
 s4:=D.C^.name+':'+D.C^.paramstr(D.wat);
// writeln('           s4=',s4);
 assign(fn,f);
 {$i-}
 reset(fn);
 {$i+}
 if ioresult<>0 then exit;
 while not(eof(fn)) do begin
  readln(fn,s);
  x:=pos('=',s);
  if (x>0) and ( (copy(s,1,x-1)=s3) or (copy(s,1,x-1)=s4) ) then begin
      z:=strtofloat(copy(s,x+1,length(s)-x));
//      writeln('loadvar: ',s3,'=',z);
      loadvar:=true;
      end;
 end;
close(fn);
 end;
 

Procedure savevar(f : string;D : tdvar;z : double;clear : boolean);
var 
 fn : text;
begin;
assign(fn,f);
{$i-}
if clear then rewrite(fn) else append(fn);
{$i+}
if ioresult<>0 then rewrite(fn);
with D do begin
//  writeln('Savevar ',c^.name,':',wat,'=',z);
//  writeln(fn,c^.name,':',wat,'=',z);
  writeln(fn,c^.name,':',c^.paramstr(wat),'=',z);
  end;
close(fn);
end;


function getprm(s : string) : Tparam;
var
 x : integer;
 z : Tparam;
begin
x:=pos('=',s);
if x=0 then begin
 Z.name:='';
 Z.value:=s;
 end else begin
 Z.name:=uppercase(copy(s,1,x-1));
 Z.value:=copy(s,x+1,length(s)-x);
 end;
getprm:=Z;
end;

Procedure addblk(Y : cmat;x0,y0,x1,y1 : integer;Z : tc);
begin
//writeln(x0:4,y0:4,x1:4,y1:4);
cadd(Y[x0,y0],Z);
cadd(Y[x1,y1],Z);
Z:=-Z;
cadd(Y[x1,y0],Z);
cadd(Y[x0,y1],Z);
end;

Procedure addblkR(Y : cmat;x0,y0,x1,y1 : integer;Z : tr);
begin
//writeln(x0:4,y0:4,x1:4,y1:4);
caddr(Y[x0,y0],Z);
caddr(Y[x1,y1],Z);
caddr(Y[x1,y0],-Z);
caddr(Y[x0,y1],-Z);
end;


constructor Tcomp.create(p : pointer);
begin
parent:=P;dorecalc:=false;AlwaysUpdate:=false;
Nnode:=0;Nsrc:=0;Nnoise:=0;Nvar:=0;
savedata:=false;
end;


function Tcomp.loads(ss : tstrings) : boolean;
var
 Npm,x,y,z : integer;
 P : tparams;
 s,s2 : string;
begin
 loads:=false;
 NPm:=len(ss)-NNode-1;
 if NPm<0 then begin;writeln(ss[1],' Not enough nodes');exit;end;
 setlength(node,NNode);
 for x:=1 to NNode do node[x-1]:=Psport(parent)^.getnode(ss[x+1]);
// for x:=1 to Nnode do write(node[x-1]);writeln;
 setlength(P,Npm);
 for x:=1 to Npm do P[x-1]:=getprm(ss[x+NNode+1]);
 load(Npm,P); 
 for x:=1 to Npm do if (P[x-1].name='FOOTPRINT') or (P[x-1].value='FOOTPRINT') then begin
   deletechar('"',P[x-1].value);
   z:=1;
   if getfoot(s,s2,z) then begin
    s:=s+':'+name;
    s:=uppercase(s);
    for y:=z to Nnode do s:=s+' '+ss[y+1];
    s:=s+' '+P[x-1].value+' '+uppercase(s2);
//    writeln('Autofootprint ',s);
    Psport(parent)^.addLayout(s);
   end;end;
 loads:=true;
end;

function Tcomp.getparm(Np : integer;P : tparams;s : string;default : double) : double;
var
 x : integer;
begin
 x:=0;
 while (x<Np) and (P[x].name<>s) do inc(x);
// writeln('Getparm: x=',x,' s=',s);
// for x:=1 to Np do writeln('P',x,' ',P[x-1].name,'=',P[x-1].value);
 if x=Np then getparm:=default else getparm:=strtofloat(P[x].value);
// if x=Np then begin;write(name,' ',s,'=');writeEng(default);writeln('Default');end;
end;

procedure Tcomp.load(Np : integer;P : Tparams);
begin
end;

Procedure Tcomp.getY(w : double;var Y : cmat);
begin
end;
Procedure Tcomp.getS(w : double;var S : cmat);
begin
end;
Procedure Tcomp.getN(w : double;var N : cmat);
begin
end;
Procedure Tcomp.getdY(w : double;v0 : cvec;var Y : cvec;wat : integer); 
begin
end;
Procedure Tcomp.getdS(w : double;v0 : cvec;var S : cvec;wat : integer); 
begin
end;
Procedure Tcomp.getdN(w : double;v0 : cmat;var N : cmat;wat : integer); 
begin
end;

Procedure Tcomp.calclinks; 
begin
end;

Procedure Tcomp.closecomp;
begin
end;

function Tcomp.getYin(w : double;Z : cvec;prt : integer) : tc;
begin
GetYin:=czero;
end;


function Tcomp.getReflect(w : double;Z : cvec;prt : integer) : tc;
begin
GetReflect:=czero;
end;


function Tcomp.getOutput(w : double;V0,Z0 : cvec;wat : integer) : tc;
begin
getOutput:=czero;
end;

function Tcomp.getFoot(var wt,par : string;var pars : integer) : boolean;
begin
getFoot:=false;
end;

Procedure Tcomp.exportQucs(var f : text);
begin
writeln(name,': Qucs export not implemented!');
writeln(f,'# ',name,': Qucs export not implemented!');
end;


function Tcomp.expnode(i : integer) : string;
begin
if i=0 then expnode:='gnd' else expnode:='_'+Psport(parent)^.SP[i];
end;

Procedure Tcomp.recalc(w : double);
begin
dorecalc:=true;
if parent<>nil then Pcomp(parent)^.recalc(w);
end;

procedure Tcomp.doUpdate(w : double;V0,Z0 : cvec; cnt : integer); 
begin
end;

Procedure Tcomp.exportVars(var f : text;prnt : string);
begin
end;

// *********** comp copy ***********
Procedure swapnodes(c1,c2 : pcomp);
var
   TNode : array of integer; //Node indeks
   TNoiseI : integer; //Noise indeks
begin
with C1^ do begin
 Tnode   :=node   ;node   :=C2^.node;
 TnoiseI :=noiseI ;noiseI :=C2^.noiseI;
 end;
with C2^ do begin
 node  :=Tnode;
 noiseI :=TnoiseI;
end; 
end;

constructor Tcompcopy.create(P : pointer;C : pcomp); 
begin 
 inherited create(P);
// writeln('Compcopy create ',C^.name);
 cmp:=C;
 C^.savedata:=true;
 Nnode:=cmp^.Nnode;
 Nsrc:=cmp^.Nnode;
 Nnoise:=cmp^.Nnoise;
 Nvar:=cmp^.Nvar;
end;

Procedure Tcompcopy.getY(w : double;var Y : cmat);
begin
//write(name,' compcopy getY');
swapnodes(@self,cmp);
cmp^.getY(w,Y);
swapnodes(@self,cmp);
//writeln(' - Done');
end;

Procedure Tcompcopy.getS(w : double;var S : cmat);
begin
//write(name,' compcopy getY');
swapnodes(@self,cmp);
cmp^.getS(w,S);
swapnodes(@self,cmp);
//writeln(' - Done');
end;

Procedure Tcompcopy.getN(w : double;var N : cmat);
begin
//write(name,' compcopy getN');
swapnodes(@self,cmp);
cmp^.getN(w,N);
swapnodes(@self,cmp);
//writeln(' - Done');
end;

Procedure Tcompcopy.getdY(w : double;v0 : cvec;var Y : cvec;wat : integer);
begin
swapnodes(@self,cmp);
cmp^.getdY(w,v0,Y,wat);
swapnodes(@self,cmp);
end;

Procedure Tcompcopy.getdS(w : double;v0 : cvec;var S : cvec;wat : integer);
begin
swapnodes(@self,cmp);
cmp^.getdS(w,v0,S,wat);
swapnodes(@self,cmp);
end;

Procedure Tcompcopy.getdN(w : double;v0 : cmat;var N : cmat;wat : integer);
begin
swapnodes(@self,cmp);
cmp^.getdN(w,v0,N,wat);
swapnodes(@self,cmp);
end;


function Tcompcopy.getFoot(var wt,par : string;var pars : integer) : boolean;
begin
getFoot:=cmp^.getFoot(wt,par,pars);
end;

Procedure Tcompcopy.exportQucs(var f : text);
begin
swapnodes(@self,cmp);
cmp^.name:=cmp^.name+'_c';
cmp^.exportQucs(f);
delete(cmp^.name,length(cmp^.name)-1,2);
swapnodes(@self,cmp);
end;


end.