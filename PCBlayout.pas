unit PCBlayout;
interface
uses vectorD,complex2,stringe,footprint,draw,varu,s3Du;
type
Tlayout = object(Tfoot)
  Np : integer; //number of ports
  Nn : integer; //number of nodes
  Ne : integer; //number of equations
  Sn : array of string; //Node names
  Ddraw : Pdraw;
  Nfoot : integer;
  Afoot : array of Pfoot;
  hascalc2 : boolean; //if layout has been calc
//  YY : cmat;
//  RHS : cvec;
 YY : array of T3D;
 Yc : array of boolean;
  ckt : pointer;
   parmn : integer;
   parm : array of Tparm;
 errorD,errorA : double;
  constructor create(P : pointer);  overload;
  constructor create(P : pointer;ports : integer); overload; 
  function loadline(s : string) : Pfoot;
  function getnode(s : string;var nuut:boolean ) : integer;
  function findcomp(s : string) : Pfoot;
  function readfoot(s : string) : Pfoot;
  function newfoot(wt,Cname : string;ss : tstrings) : Pfoot;
  procedure calc;
  procedure drawlayout;
  Procedure readdraw(ss : Tstrings);
  function getsublayout(ss : tstrings) : Pfoot;
//   Procedure getY(var Y : cmat;var RH : cvec); virtual;
  procedure getDisp(x : integer;var DD : t3D); virtual;
  Procedure draw(L : T3D;canvas : pdraw); virtual;
  function nodePos(x : integer) : T3D;

function paramnum(s : string) : integer; virtual;
function paramstr(wat : integer) : string; virtual; 
function getD(wat : integer) : double; virtual; 
Procedure setD(z : double;wat : integer); virtual; 
function Geterror(wat : integer) : double;

  function penalty : double; virtual;
  end;
Playout=^Tlayout;

implementation
uses compu,sysutils,foots,sport,drawPCB,drawgbr;

// **** Tlayout ***
constructor Tlayout.create(P : pointer);
begin
inherited create(P);hascalc2:=false;Ddraw:=nil;
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
for x:=1 to Nn do Sn[x-1]:=inttostr(x);hascalc2:=false;
end;

procedure Tlayout.calc;
var
 x,y,z,Nt,yn : integer;
 finished : boolean;
// Y3 : Rmat;
 MR : T3mat;//Rotation matrix
 DD,D0 : t3D;
 D1 : t3D;
// DD,d0 : T3mat;//Direction matrix node 0
// DR,r0 : T3vec;
begin
//write('f');
//writeln(name,' Calc layout, Nfoot=',Nfoot);
hascalc2:=true;
hascalc:=true;
for x:=0 to Nfoot-1 do Afoot[x]^.hascalc:=false;
setlength(YY,Nn);
setlength(Yc,Nn);
for x:=0 to Nn-1 do Yc[x]:=false;
Yc[0]:=true;
YY[0].r:=t3vec0;
YY[0].d:=t3matI;
 errorD:=0;errorA:=0;
// write('Nfoot=',nfoot);
repeat
finished:=true;
 for y:=0 to Nfoot-1 do with Afoot[y]^ do if not(hascalc) then begin
    x:=0;
    while (x<nnode) and not(Yc[Anode[x]]) do inc(x);
//    writeln('Calc footprint ',name,' known node=',x);
    if x<nnode then begin 
      finished:=false;
      hascalc:=true;
      //Calc node 0 if unknown
      yn:=Anode[0];
      if x>0 then begin
//        write('gd');
        getDisp(x,DD);
        d0.d:=(YY[Anode[x]].d/Dnode[x])/DD.d;
        d0.r:=YY[Anode[x]].r-d0.d*Dnode[x]*DD.r;
        YY[yn]:=d0;
        end else begin
          if nnode=1 then getDisp(x,DD);
          D0:=YY[yn];
          end;
//      RM3write('D0.d=',D0.d);
//      write('nnode=',nnode);
//      RV3write('D0.r=',D0.r);
      //Calc other nodes
      for z:=1 to nnode-1 do if z<>x then begin
//        writeln('z=',z);
        getDisp(z,DD);
        yn:=Anode[z];
        if Yc[yn] then begin
         D1.d:=d0.d*Dnode[x];
         errorA:=errorA+RM3abs2(YY[yn].d-d1.d*DD.D);
         errorD:=errorD+RV3abs2(YY[yn].r-(d0.r+d1.d*DD.r));
         //add to error
         end else begin
           D1.r:=d0.r;
           D1.d:=d0.d*Dnode[x];
           YY[yn]:=T3Dadd(D1,DD);
//      RM3write('D1=',YY[yn].d);
//      RV3write('D1=',YY[yn].r);
           Yc[yn]:=true;
         end; //if Yc
      end; //for z
     end; //if x<
    end; // for y
until finished;
//writeln('Draw layout...');
drawlayout;
//writeln('Done');
end;


procedure Tlayout.getDisp(x : integer;var DD : t3D);
begin
//if not(hascalc2) then calc;
calc;
DD:=YY[x];
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
 L : T3D;
begin
if not(hascalc2) then calc;
if Ddraw=nil then exit;
for x:=0 to Nfoot-1 do with Afoot[x]^ do begin
  L:=YY[anode[0]];
  L.d:=L.d/Dnode[0];
  draw(L,Ddraw);
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
for x:=3 to len(ss) do if uppercase(ss[x])='SHOW' then Ddraw^.doshow:=true else
                       if uppercase(ss[x])='XZ' then Ddraw^.proj:=1 else
                       if uppercase(ss[x])='YZ' then Ddraw^.proj:=2;

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

function Tlayout.loadline(s : string) : Pfoot;
begin
loadline:=readfoot(s);
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
 if (C=nil) or (copy(C^.tiepe,1,3)<>'CKT') then begin
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

function Tlayout.newfoot(wt,Cname : string;ss : tstrings) : Pfoot;
var
 tmp : Pfoot;
 C : Pfoot;
begin;
newfoot:=nil;
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
else if wt='MSPAD' then C:=new(PFpad,create(@self))
else if wt='M2PNT' then C:=new(P2pnt,create(@self))
else if wt='M4PNT' then C:=new(P4pnt,create(@self))
else if wt='CKT'   then C:=getsublayout(ss)
else if wt='DRAW' then begin;readdraw(ss);exit;end
else begin if wt<>'' then writeln('Unknow component ',wt);exit; end;
//writeln('Comp ',wt,' created');
C^.name:=Cname;
C^.tiepe:=wt; 
//x:=pos('$',s);
//if x>0 then subset(ss,Nset,sets);
//write('loads..');
{newfoot:=}
C^.loads(ss);
//writeln('OK');
//newfoot:=true;

inc(Nfoot);
setlength(Afoot,Nfoot);
Afoot[Nfoot-1]:=C;
newfoot:=C;
end;

function Tlayout.readfoot(s : string) : Pfoot;
var
 ss : tstrings;
 wt,Cname : string;
 x : integer;
begin
readfoot:=nil;//false;
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

{Procedure Tlayout.getY(var Y : cmat;var RH : cvec);
var
 x : integer;
begin
calc;
for x:=0 to nnode-2 do begin
Y[2*Anode[0]   ,2*(nodeI+x)  ]:=YY[0,x*2+2];
Y[2*Anode[0]+1 ,2*(nodeI+x)  ]:=YY[1,x*2+2];
Y[2*Anode[x+1] ,2*(nodeI+x)  ]:=r2c(1,0);
//th1=th2
Y[2*Anode[0]    ,2*(nodeI+x)+1]:=YY[0,x*2+3];
Y[2*Anode[0]+1  ,2*(nodeI+x)+1]:=YY[1,x*2+3];
Y[2*Anode[x+1]+1,2*(nodeI+x)+1]:=r2c(1,0);
end;end;
}
Procedure Tlayout.draw(L : T3D;canvas : pdraw);
var
 x,yn : integer;
 L2 : T3D;
begin
if not(hascalc2) then calc;
for x:=0 to Nfoot-1 do with Afoot[x]^ do begin
 Yn:=Anode[0];
 L2.d:=(L.d*YY[yn].d)/Dnode[0];
 L2.r:=L.r+L.d*YY[yn].r;
 Afoot[x]^.draw(L2,canvas);
 end;
end;

function Tlayout.nodePos(x : integer) : t3D;
var
 L2 : T3D;
begin
if not(hascalc2) then calc;
if parent<>nil then begin;
  L2:=Playout(parent)^.nodepos(Anode[0]);
  L2:=T3Dadd(L2,YY[x]);
//  L2.d:=L2.d/Dnode[x];
end else
  L2:=YY[x];

nodepos:=L2;
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
//  C^.hascalc:=false;
  hascalc:=false;
//  if savedata then nsavedata:=0;
  end;
end;

end.