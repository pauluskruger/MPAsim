unit PCBlayout;
interface
uses vectorD,complex2,stringe,footprint,draw,varu;
type
Tlayout = object(Tfoot)
  Np : integer; //number of ports
  Nn : integer; //number of nodes
  Ne : integer; //number of equations
  Sn : array of string; //Node names
  Ddraw : Pdraw;
  Nfoot : integer;
  Afoot : array of Pfoot;
  YY : cmat;
  RHS : cvec;
  ckt : pointer;
   parmn : integer;
   parm : array of Tparm;
 errorD,errorA : double;
  constructor create(P : pointer);  overload;
  constructor create(P : pointer;ports : integer); overload; 
  Procedure loadline(s : string);
  function getnode(s : string;var nuut:boolean ) : integer;
  function findcomp(s : string) : Pfoot;
  function readfoot(s : string) : boolean;
  function newfoot(wt,Cname : string;ss : tstrings) : boolean;
  procedure calc;
  procedure drawlayout;
  Procedure readdraw(ss : Tstrings);
  function getsublayout(ss : tstrings) : Pfoot;
   Procedure getY(var Y : cmat;var RH : cvec); virtual;
  Procedure draw(var V0 : cvec;canvas : pdraw); virtual;

function paramnum(s : string) : integer; virtual;
function paramstr(wat : integer) : string; virtual; 
function getD(wat : integer) : double; virtual; 
Procedure setD(z : double;wat : integer); virtual; 
function Geterror(wat : integer) : double; virtual;

  function penalty : double; virtual;
  end;
Playout=^Tlayout;

implementation
uses compu,sysutils,foots,sport,drawPCB,drawgbr;

// **** Tlayout ***
constructor Tlayout.create(P : pointer);
begin
inherited create(P);
end; 

constructor Tlayout.create(P : pointer;ports : integer);
var
 x : integer;
begin
ckt:=p;parmn:=0;
Np:=ports;
//Nn:=0;
Nn:=ports-1;
setlength(Sn,ports-1);
for x:=1 to Nn do Sn[x-1]:=inttostr(x);
end;

procedure Tlayout.calc;
var
 x,y,Nt : integer;
begin
Ne:=1;
for x:=0 to Nfoot-1 do begin
 Afoot[x]^.Nodei:=Ne;
 Ne:=Ne+Afoot[x]^.Nnode-1;
 end;
//writeln(name,': solving layout: ports=',Np,' nodes=',Nn,' eq=',Ne,'...');
//write(name,':L ');
CMsetsize(2*Nn,2*Ne,YY);
for x:=0 to 2*Nn-1 do for y:=0 to 2*Ne-1 do YY[x,y]:=czero;
setlength(RHS,2*Ne);
errorD:=0;errorA:=0;
for x:=0 to Nfoot-1 do begin
//   writeln(Afoot[x]^.name,' get');
   Afoot[x]^.getY(YY,RHS);
   errorD:=errorD+sqr(Afoot[x]^.geterror(1));
   errorA:=errora+sqr(Afoot[x]^.geterror(2));
   end;
//CMwrite(2*Nn,2*Ne,YY);
//Nt:=Nn;
//if Ne+Np<Nt then Nt:=Ne+Np;
//write(name,': solving layout ...');
x:=CMelim2(2*Nn,YY,2,2*nn-1,2*Ne-1);
  if x<>0 then begin
  writeln(name,': solving layout: ports=',Np,' nodes=',Nn,' eq=',Ne,'...');
   writeln(name,': Error Solving Node ',Sn[x div 2]);
//   CMwrite(2*Nn,2*Ne,YY);
    halt(1);
   end;
//   CMwrite(2*Nn,2*Ne,YY);
if Ne>Nn then begin
 for x:=nn to Ne-1 do begin
//  cwriteEng(YY[0,2*x]);
//  cwriteEng(YY[1,2*x]);
//  cwriteEng(YY[0,2*x+1]);
//  cwriteEng(YY[1,2*x+1]);
  errorD:=errorD+cabs2(YY[1,2*x]);
  errorA:=errorA+cabs2(YY[1,2*x+1]);
  end;
  errorA:=sqrt(errorA{/(ne-nn)});
  errorD:=sqrt(errorD{/(ne-nn)});
// writeln('RMS error: Distance =',sqrt(er)*1000:0:2,'mm Angle=',sqrt(eth)*180/pi:0:2,' grade');
  end;
//writeln(name,': DONE'); 
//CMwrite(2*Nn,2*Ne,YY);
drawlayout;
end;
function Tlayout.Geterror(wat : integer) : double;
begin
case wat of
 1 : Geterror:=errorD;
 2 : Geterror:=errorA;
 3 : Geterror:=errorD+errorA;
 4 : Geterror:=penalty;
 end;
end;


procedure Tlayout.drawlayout;
var
 x : integer;
 V0 : cvec;
begin
if Ddraw=nil then exit;
//writeln(name,' ',length(Dnode));
setlength(V0,2*ne);
YY[0,0]:=czero;
YY[0,1]:=czero;
YY[1,0]:=czero;
YY[1,1]:=-r2c(1,0){*Dnode[0]};
for x:=0 to Ne-1 do begin
  V0[2*x  ]:=-YY[0,2*x  ]*0-YY[1,2*x  ]*1;
  V0[2*x+1]:=-YY[0,2*x+1]*0-YY[1,2*x+1]*1;
  end;
//CVwrite(2*ne,V0);
for x:=0 to Nfoot-1 do begin
// writeln(Afoot[x]^.name);
 Afoot[x]^.draw(V0,Ddraw);
 end;
Ddraw^.closedrw;
//Ddraw^.show;
end;

function Tlayout.penalty : double; 
var
z : double;
x : integer;
begin
//write('Penalty ...');
z:=0;
for x:=0 to Nfoot-1 do
 z:=z+Afoot[x]^.penalty;
penalty:=z;
//writeln('Done');
end;

Procedure Tlayout.readdraw(ss : Tstrings);
var 
 x : integer;
begin
delete(ss[1],1,5);
ss[1]:=uppercase(ss[1]);
if ss[1]='XFIG' then begin
  Ddraw:=new(Pfig,create(ss[2]));
  writeln('Drawing to xfig "',ss[2],'"');
  end else
if ss[1]='PCB' then begin
  Ddraw:=new(PdwPCB,create(ss[2]));
  writeln('Drawing to PCB "',ss[2],'"');
  end else
if ss[1]='GERBER' then begin
  Ddraw:=new(Pgerber,create(ss[2]));
  writeln('Drawing to gerber format "',ss[2],'"');
  end else exit;
for x:=3 to len(ss) do if uppercase(ss[x])='SHOW' then Ddraw^.doshow:=true;
end;

function Tlayout.getnode(s : string;var nuut:boolean) : integer;
var
 x : integer;
begin
x:=0;
while (x<Nn) and (s<>Sn[x]) do inc(x); 
if x=Nn then begin
 inc(Nn);
 setlength(Sn,Nn);
 Sn[x]:=s;
 nuut:=true
 end else nuut:=false;
getnode:=x;
end;

function Tlayout.findcomp(s : string) : Pfoot;
var
 x : integer;
begin
 x:=0;
 while (x<Nfoot) and (Afoot[x]^.name<>s) do inc(x);
 if x=Nfoot then findcomp:=nil else findcomp:=Afoot[x];
end;

Procedure Tlayout.loadline(s : string);
var
 C : Pfoot;
begin
readfoot(s);
end;

function Tlayout.getsublayout(ss : tstrings) : Pfoot;
var
 s : string;
 l : integer;
 C : Pcomp;
 P : Pfoot;
begin
 l:=len(ss)-2;
// writeln('ports=',l);
 C:=Psport(ckt)^.findcomp(ss[l+2]);
 if (C=nil) or (C^.tiepe<>'CKT') then begin
    writeln(ss[l+2],' not a subcircuit!');
    halt(1);
    end;
 if Psport(C)^.PClayout=nil then begin
  writeln(Psport(C)^.name,': Subcircuit does not have a layout!');
  halt(1);
  end;
 if l<>C^.nnode-1 then begin
   writeln('Different number of nodes ',l,'<>',C^.nnode-1);
   halt(1);
   end;
 P:=Psport(C)^.PClayout;
 P^.nnode:=C^.nnode-1;
 P^.parent:=@self;
// writeln('Settings nodes ',P^.nnode);
 getsublayout:=P;
end;

function Tlayout.newfoot(wt,Cname : string;ss : tstrings) : boolean;
var
 tmp : Pfoot;
 C : Pfoot;
begin;
newfoot:=false;
tmp:=findcomp(Cname);
if tmp<>nil then begin
//   writeln('Copy: FP:',Cname);
    C:=new(Pfootcopy,create(@self,tmp));
    wt:='COPY';
//   exit; 
//   C:=new(Pcompcopy,create(@self,tmp));
//   wt:='COPY';
   end
else if wt='L'    then C:=new(PfL,create(@self))
else if wt='MS'    then C:=new(PFMS,create(@self))
else if wt='EQ'  then   C:=new(PFEQ,create(@self))
else if wt='MSTUB' then C:=new(PFSTUB,create(@self))
else if wt='MSARC' then C:=new(PFMSB,create(@self))
else if wt='MVIA' then C:=new(PFVIA,create(@self))
else if wt='MSTEE' then C:=new(PFTee,create(@self))
else if wt='MSCNR' then C:=new(PFcorner,create(@self))
else if wt='MSBEND' then C:=new(PFbend,create(@self))
else if wt='M2PAD' then C:=new(P2pad,create(@self))
else if wt='M2PAD2' then C:=new(P2pad2,create(@self))
else if wt='M2PADM' then C:=new(P2padM,create(@self))
else if wt='MSPAD' then C:=new(PFpad,create(@self))
else if wt='M2PNT' then C:=new(P2pnt,create(@self))
else if wt='M4PNT' then C:=new(P4pnt,create(@self))
else if wt='CKT'   then C:=getsublayout(ss)
else if wt='DRAW' then begin;readdraw(ss);exit;end
else begin if wt<>'' then writeln('Unknow component ',wt);exit; end;
writeln('Comp ',wt,' created');
C^.name:=Cname;
C^.tiepe:=wt; 
//x:=pos('$',s);
//if x>0 then subset(ss,Nset,sets);
write('loads..');
newfoot:=C^.loads(ss);
writeln('OK');
newfoot:=true;

inc(Nfoot);
setlength(Afoot,Nfoot);
Afoot[Nfoot-1]:=C;

end;

function Tlayout.readfoot(s : string) : boolean;
var
 ss : tstrings;
 wt,Cname : string;
 x : integer;
begin
readfoot:=false;
x:=pos(#9,s); 
while x<>0 do begin
 s[x]:=' ';
 x:=pos(#9,s);
 end;

ss:=strtostrs(s);
x:=pos(':',ss[1]);
if x<0 then exit;
wt:=uppercase(copy(ss[1],1,x-1));
Cname:=uppercase(copy(ss[1],x+1,length(ss[1])-x));
//writeln('Tiepe=',wt,' name=',Cname);
readfoot:=newfoot(wt,Cname,ss);
end;

Procedure Tlayout.getY(var Y : cmat;var RH : cvec);
var
 x : integer;
begin
calc;
for x:=0 to nnode-2 do begin
Y[2*Anode[0]   ,2*(nodeI+x)  ]:=YY[0,x*2+2];
Y[2*Anode[0]+1 ,2*(nodeI+x)  ]:=YY[1,x*2+2]*Dnode[0];
Y[2*Anode[x+1] ,2*(nodeI+x)  ]:=r2c(1,0);
//th1=th2
Y[2*Anode[0]    ,2*(nodeI+x)+1]:=YY[0,x*2+3];
Y[2*Anode[0]+1  ,2*(nodeI+x)+1]:=YY[1,x*2+3]*Dnode[0];
Y[2*Anode[x+1]+1,2*(nodeI+x)+1]:=r2c(1,0)*Dnode[x+1];
end;end;

Procedure Tlayout.draw(var V0 : cvec;canvas : pdraw);
var
 x : integer;
 V1 : cvec;
begin
//CVwrite(6,V0);
//writeln('AN ',Anode[0],' ',Anode[1]);
setlength(V1,2*ne);
YY[0,0]:=-r2c(1,0);
YY[0,1]:=czero;
YY[1,0]:=czero;
YY[1,1]:=-r2c(1,0);
for x:=0 to Ne-1 do begin
  V1[2*x  ]:=-YY[0,2*x  ]*V0[2*Anode[0]]-YY[1,2*x  ]*V0[2*Anode[0]+1]*Dnode[0];
  V1[2*x+1]:=-YY[0,2*x+1]*V0[2*Anode[0]]-YY[1,2*x+1]*V0[2*Anode[0]+1]*Dnode[0];
  end;
//CVwrite(2*ne,V1);
for x:=0 to Nfoot-1 do begin
// writeln(Afoot[x]^.name);
 Afoot[x]^.draw(V1,canvas);
 end;
end;

function Tlayout.paramnum(s : string) : integer;
var
 s2 : string;
  C : pvars;
  x,y : integer;
begin
//writeln('layout paramnum ',s);
  s2:=splitdp(s);
//  if s='FP' then C:=@self else
   C:=findcomp(s2);
  if c=nil then begin
    paramnum:=0;
    exit;
    end;
 x:=C^.paramnum(s);
 if x=0 then begin;
  paramnum:=0;
  exit;
  end;
for y:=0 to parmn-1 do 
 if (parm[y].C=C) and (parm[y].W=x) then begin
   paramnum:=y+1;
   exit;
   end;
inc(parmn);
setlength(parm,parmn);
parm[parmn-1].C:=C;
parm[parmn-1].W:=x;
paramnum:=parmn;
//savedata:=false;
end;

function Tlayout.paramstr(wat : integer) : string; 
begin
if (wat<1) or (wat>parmn) then begin;paramstr:='';exit;end;
with parm[wat-1] do
 paramstr:=C^.name+':'+C^.paramstr(W);
end;


function Tlayout.getD(wat : integer) : double; 
begin
if (wat<1) or (wat>parmn) then exit;
with parm[wat-1] do getD:=C^.getD(W);
end;

Procedure Tlayout.setD(z : double;wat : integer); 
begin
if (wat<1) or (wat>parmn) then exit;
with parm[wat-1] do begin
  if C^.getD(W)=z then exit;
  C^.setD(z,W);
//  if savedata then nsavedata:=0;
  end;
end;

end.