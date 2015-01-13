unit footprint;
interface
uses vectorD,complex2,stringe,draw,varu;
type
 

Tfoot = object(tvars)
   nodei : integer;
   Nnode : integer;
   Anode : array of integer;
   Dnode : array of shortint;
   layer : integer;
   lable : string;
   value : Pdouble;
   constructor create(P : pointer); 
   Procedure getY(var Y : cmat;var RH : cvec); virtual;
   function loads(ss : tstrings) : boolean; virtual;
   Procedure load(Np : integer;P : Tparams); virtual;
  Procedure draw(var V0 : cvec;canvas : pdraw); virtual;
  function getparm(Np : integer;P : tparams;s : string;default : double) : Pdouble;
   function penalty : double; virtual;
  function Geterror(wat : integer) : double; virtual;
  end;
Pfoot = ^Tfoot;

Tfootcopy = object(tfoot)
    cmp : Pfoot;
   constructor create(P : pointer;C : pfoot); 
   Procedure getY(var Y : cmat;var RH : cvec); virtual;
   Procedure draw(var V0 : cvec;canvas : pdraw); virtual;
   function penalty : double; virtual;
  end;
Pfootcopy = ^Tfootcopy;

function getprm(s : string) : Tparam;
//function Tfoot.getparm(Np : integer;P : tparams;s : string;default : double) : double;


implementation
uses PCBlayout,sysutils,compu;
// **** Tfoot ***
constructor Tfoot.create(P : pointer);
begin
Nnode:=0;parent:=P;
end; 

function Tfoot.loads(ss : tstrings) : boolean; 
var
 Npm,x,y : integer;
 P : tparams;
 nuut : boolean;
begin
 loads:=false;
 NPm:=len(ss)-NNode-1;
// writeln('Param numbers=',Npm);
 if NPm<0 then begin;writeln(ss[1],' Not enough nodes');exit;end;
 setlength(Anode,NNode);
 setlength(Dnode,NNode);
 for x:=1 to NNode do begin
   Dnode[x-1]:=0;
   y:=pos('+',ss[x+1]);if y>0 then begin;delete(ss[x+1],y,1);Dnode[x-1]:= 1;end;
   y:=pos('-',ss[x+1]);if y>0 then begin;delete(ss[x+1],y,1);Dnode[x-1]:=-1;end;
   Anode[x-1]:=Playout(parent)^.getnode(ss[x+1],nuut);
   if Dnode[x-1]=0 then if nuut then Dnode[x-1]:=1 else Dnode[x-1]:=-1;
   write(Dnode[x-1]);
   end;   
//writeln('params...');
// for x:=1 to Nnode do write(node[x-1]);writeln;
 setlength(P,Npm);
 for x:=1 to Npm do P[x-1]:=getprm(ss[x+NNode+1]);
 load(Npm,P); 
 Layer:=round(getparm(Npm,P,'LAYER',layer).get);
 Value:=getparm(Npm,P,'VALUE',0);
//writeln('Value=',value.get);
 lable:='';
 for x:=1 to Npm do if P[x-1].name='LABEL' then lable:=P[x-1].value;
 loads:=true;
end;

Procedure Tfoot.getY(var Y : cmat;var RH : cvec); begin;end;

Procedure Tfoot.load(Np : integer;P : Tparams); begin;end;
Procedure Tfoot.draw(var V0 : cvec;canvas : pdraw); begin;end;

function Tfoot.penalty : double; begin;penalty:=0;end;

function Tfoot.Geterror(wat : integer) : double;
begin
Geterror:=0;
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

function Tfoot.getparm(Np : integer;P : tparams;s : string;default : double) : Pdouble;
var
 x,a : integer;
 b : double;
 res : pdouble;
begin
 x:=0;
 while (x<Np) and (P[x].name<>s) do inc(x);
 if x=Np then res.setd(default) else begin
  val(P[x].value,b,a);
  if a=0 then res.setd(b)
         else res.setd(P[x].value,Playout(parent)^.ckt);
  end;
    getparm:=res;
end;
//** comp copy ***

Procedure swapnodes(c1,c2 : pfoot);
var
   TANode : array of integer; 
   TDNode : array of shortint; 
   Tnodei : integer;
begin
with C1^ do begin
 TAnode   :=Anode   ;Anode   :=C2^.Anode;
 TDnode   :=Dnode   ;Dnode   :=C2^.Dnode;
 Tnodei   :=nodei;  ;nodei   :=C2^.nodei;
 end;
with C2^ do begin
 Anode  :=TAnode;
 Dnode  :=TDnode;
 nodei  :=Tnodei;
end; 
end;

constructor Tfootcopy.create(P : pointer;C : pfoot); 
begin 
 inherited create(P);
 cmp:=C;
// nodei:=cmp^.nodei;
 Nnode:=cmp^.Nnode;
end;

Procedure Tfootcopy.getY(var Y : cmat;var RH : cvec);
begin
swapnodes(@self,cmp);
cmp^.getY(Y,RH);
swapnodes(@self,cmp);
end;
Procedure Tfootcopy.draw(var V0 : cvec;canvas : pdraw);
begin
swapnodes(@self,cmp);
cmp^.draw(V0,canvas);
swapnodes(@self,cmp);
end;

function Tfootcopy.penalty : double; 
begin;
swapnodes(@self,cmp);
penalty:=cmp^.penalty;
swapnodes(@self,cmp);
end;


end.