unit foots;
interface
uses footprint,vectorD,complex2,draw,varu;
type
TfL = object(Tfoot)
  L,LEN : Pdouble;  
  Wp : Pdouble;
  constructor create(P : pointer);
  Procedure load(Np : integer;P : Tparams); virtual;
  Procedure getY(var Y : cmat;var RH : cvec); virtual;
  function penalty : double; virtual;
  end;
PfL = ^TfL;

TFMS = object(Tfoot)
  Len,W1,W2,ang,offL,offW,offW2,T1,T2,WP : Pdouble;  
  constructor create(P : pointer);
  Procedure load(Np : integer;P : Tparams); virtual;
  Procedure getY(var Y : cmat;var RH : cvec); virtual;
  Procedure draw(var V0 : cvec;canvas : pdraw); virtual;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
  function penalty : double; virtual;
  end;
PfMS = ^TfMS;

TFEQ = object(Tfoot)
  ANG,XX,YY : Pdouble;  
  constructor create(P : pointer);
  Procedure load(Np : integer;P : Tparams); virtual;
  Procedure getY(var Y : cmat;var RH : cvec); virtual;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
  end;
PfEQ = ^TfEQ;

TFMSB = object(Tfoot)
  W1,len,ang,rad,YY : Pdouble;
  XX,h1,hk : double;  
  constructor create(P : pointer);
  Procedure load(Np : integer;P : Tparams); virtual;
  Procedure getY(var Y : cmat;var RH : cvec); virtual;
  Procedure draw(var V0 : cvec;canvas : pdraw); virtual;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
  end;
PfMSB = ^TfMSB;

TFSTUB = object(Tfoot)
  Len,W1,W2,ang : Pdouble;  
  constructor create(P : pointer);
  Procedure load(Np : integer;P : Tparams); virtual;
  Procedure draw(var V0 : cvec;canvas : pdraw); virtual;
  end;
PfSTUB = ^TfSTUB;

TFPAD = object(Tfoot)
  W,H,offW,offH : Pdouble;  
  constructor create(P : pointer);
  Procedure load(Np : integer;P : Tparams); virtual;
  Procedure getY(var Y : cmat;var RH : cvec); virtual;
  Procedure draw(var V0 : cvec;canvas : pdraw); virtual;
  end;
PfPAD = ^TfPAD;


TFVIA = object(Tfoot)
  D,Rpad : Pdouble;  
  constructor create(P : pointer);
  Procedure load(Np : integer;P : Tparams); virtual;
  Procedure draw(var V0 : cvec;canvas : pdraw); virtual;
  end;
PFVIA = ^TfVIA;

TFTee = object(Tfoot)
  W1,W2,W3 : Pdouble;
  dir : shortint;  
  constructor create(P : pointer);
  Procedure load(Np : integer;P : Tparams); virtual;
  Procedure getY(var Y : cmat;var RH : cvec); virtual;
  Procedure draw(var V0 : cvec;canvas : pdraw); virtual;
  end;
PfTee = ^TfTee;

TFcorner = object(Tfoot)
  W1,W2 : Pdouble;
  dir : shortint;  
  constructor create(P : pointer);
  Procedure load(Np : integer;P : Tparams); virtual;
  Procedure getY(var Y : cmat;var RH : cvec); virtual;
  Procedure draw(var V0 : cvec;canvas : pdraw); virtual;
  end;
PFcorner = ^TFcorner;

TFBend = object(Tfoot)
  W,Len,ang,ang2,ang3,Len0,len1,len2,len3,Rmin : Pdouble;
  constructor create(P : pointer);
  Procedure load(Np : integer;P : Tparams); virtual;
  Procedure getY(var Y : cmat;var RH : cvec); virtual;
  Procedure draw(var V0 : cvec;canvas : pdraw); virtual;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
  function penalty : double; virtual;

  end;
PFBend = ^TFBend;


T2pad = object(Tfoot)
  W,B,Len : Pdouble; //Pad W*B, len distance between pads
  dir1,dir2 : shortint; 
  constructor create(P : pointer);
  Procedure load(Np : integer;P : Tparams); virtual;
  Procedure getY(var Y : cmat;var RH : cvec); virtual;
  Procedure draw(var V0 : cvec;canvas : pdraw); virtual;
  end;
P2pad = ^T2pad;

T2padm = object(Tfoot)
  W,B,Len : Pdouble; //Pad W*B, len distance between pads
  dir1,dir2 : shortint; 
  constructor create(P : pointer);
  Procedure load(Np : integer;P : Tparams); virtual;
  Procedure getY(var Y : cmat;var RH : cvec); virtual;
  Procedure draw(var V0 : cvec;canvas : pdraw); virtual;
  end;
P2padm = ^T2padm;

T2pad2 = object(Tfoot)
  W,B,Len : Pdouble; //Pad W*B, len distance between pads
  dir1,dir2 : shortint; 
  constructor create(P : pointer);
  Procedure load(Np : integer;P : Tparams); virtual;
  Procedure getY(var Y : cmat;var RH : cvec); virtual;
  Procedure draw(var V0 : cvec;canvas : pdraw); virtual;
  end;
P2pad2 = ^T2pad2;

T2pnt = object(Tfoot)
  len,dir1,dir2 : Pdouble; 
  constructor create(P : pointer);
  Procedure load(Np : integer;P : Tparams); virtual;
  Procedure getY(var Y : cmat;var RH : cvec); virtual;
//  Procedure draw(var V0 : cvec;canvas : pdraw); virtual;
  end;
P2pnt = ^T2pnt;

T4pnt = object(Tfoot)
  len1,len2,dir1,dir2,dir3,dir4 : Pdouble; 
  constructor create(P : pointer);
  Procedure load(Np : integer;P : Tparams); virtual;
  Procedure getY(var Y : cmat;var RH : cvec); virtual;
//  Procedure draw(var V0 : cvec;canvas : pdraw); virtual;
  Procedure draw(var V0 : cvec;canvas : pdraw); virtual;
  end;
P4pnt = ^T4pnt;


{TFcorner = object(Tfoot)
  W1,W2 : double;
  dir : shortint;  
  constructor create(P : pointer);
  Procedure load(Np : integer;P : Tparams); virtual;
  Procedure getY(var Y : cmat;var RH : cvec); virtual;
  Procedure draw(var V0 : cvec;canvas : pdraw); virtual;
  end;
PFcorner = ^TfTee;}

implementation
uses math;
constructor tfL.create(P : pointer);
begin inherited create(P);Nnode:=2;layer:=0; end;

Procedure TfL.load(Np : integer;P : Tparams);
begin
L:=getparm(Np,P,'L',1e-10);
LEN:=getparm(Np,P,'LEN',1e-3);
WP:=getparm(Np,P,'WP',1)
end;

Procedure TfL.getY(var Y : cmat;var RH : cvec);
begin
//r1-r2+l.exp(th1)=0
Y[2*Anode[0]  ,2*nodeI  ]:=r2c(1,0);
Y[2*Anode[1]  ,2*nodeI  ]:=r2c(-1,0);
Y[2*Anode[0]+1,2*nodeI  ]:=r2c((len.get),0)*Dnode[0];
//th1=th2
Y[2*Anode[0]+1,2*nodeI+1]:=r2c(Dnode[0],0);
Y[2*Anode[1]+1,2*nodeI+1]:=r2c(Dnode[1],0);
end;

function TfL.penalty : double;
begin
 penalty:=L.get*WP.get;
end;

constructor tfMS.create(P : pointer);
begin inherited create(P);Nnode:=2;layer:=0; end;


Procedure TfMS.load(Np : integer;P : Tparams);
begin
Len:=getparm(Np,P,'LEN',1e-3);
OFfL:=getparm(Np,P,'OFFL',0);
OFfW:=getparm(Np,P,'OFFW',0);
OFfW2:=getparm(Np,P,'OFFW2',0);
W1:=getparm(Np,P,'W1',1e-3);
W2:=getparm(Np,P,'W2',0);
T1:=getparm(Np,P,'T1',0);
T2:=getparm(Np,P,'T2',0);
WP:=getparm(Np,P,'WP',1);
if W2.get=0 then W2:=W1;
end;

Procedure TfMS.getY(var Y : cmat;var RH : cvec);
begin
//r1-r2+l.exp(th1)=0
Y[2*Anode[0]  ,2*nodeI  ]:=r2c(1,0);
Y[2*Anode[1]  ,2*nodeI  ]:=r2c(-1,0);
Y[2*Anode[0]+1,2*nodeI  ]:=r2c((len.get-OffL.get),OffW.get+offW2.get)*Dnode[0];
//th1=th2
Y[2*Anode[0]+1,2*nodeI+1]:=r2c(Dnode[0],0);
Y[2*Anode[1]+1,2*nodeI+1]:=r2c(Dnode[1],0);
end;


Procedure TfMS.draw(var V0 : cvec;canvas : pdraw);
var
// pnts : cvec;
 r,d,r0,r1 : tc;
 ww : double;
 x : integer;
begin
canvas^.layer:=layer;
r:=V0[2*Anode[0]];
d:=V0[2*Anode[0]+1]*Dnode[0];
//r:=r-d*offL.get;
//write('r=');cwrite(r);write(' d=');cwrite(d);writeln;
//r0:=r+r2c(0,0.5)*d*w1.get;
//r1:=r-r2c(0,0.5)*d*w2.get+len.get*d;
ww:=w1.get;
r:=r+r2c(0,1)*d*offW2.get;
canvas^.rect(r,r+len.get*d,ww,name);

canvas^.layer:=6;
canvas^.fontsize:=0.5e-3;
//writeln('T1=',T1.get,' T2=',T2.get);
x:=round(t1.get);
r:=r+len.get*d*0.1;
if x=1 then canvas^.lable(r,d,'o',name) else
if x=2 then canvas^.lable(r,d,'-',name);
r:=r+len.get*d*0.8;
x:=round(t2.get);
if x=1 then canvas^.lable(r,d,'o',name) else
if x=2 then canvas^.lable(r,d,'-',name);
end;

function TfMS.paramnum(s : string) : integer;
begin
 if s='LEN' then paramnum:=1 else paramnum:=0;
end;

function TfMS.paramstr(wat : integer) : string;
begin
 case wat of 
  1 : paramstr:='LEN';
  end;
end;
function TfMS.getD(wat : integer) : double;
begin
case wat of 
 1 : getD:=len.get;
 else
 getD:=0;
 end;
end;
Procedure TfMS.setD(z : double;wat : integer);
begin
 case wat of 
 1 : len.setval(z);
 end;
end;

function TfMS.penalty : double;
begin
 penalty:=WP.get*len.get;
end;

constructor tfEQ.create(P : pointer);
begin inherited create(P);Nnode:=2;writeln('New EQ');end;


Procedure TfEQ.load(Np : integer;P : Tparams);
begin
ANG:=getparm(Np,P,'ANG',1e9);
XX:=getparm(Np,P,'X',1e9);
YY:=getparm(Np,P,'Y',1e9);
If ang.get<>1e9 then writeln('Eq ang=',ang.get);
end;

Procedure TfEQ.getY(var Y : cmat;var RH : cvec);
begin
if ANG.get<>1e9 then begin
  Y[2*Anode[0]+1,2*nodeI+1]:=r2c(Dnode[0],0);
  Y[2*Anode[1]+1,2*nodeI+1]:=r2c(Dnode[1],0)*expi(ang.get/180*pi);
 end;
if (XX.get<>1e9) and (YY.get<>1e9) then begin
//r1-r2+l.exp(th1)=0
Y[2*Anode[0]  ,2*nodeI  ]:=r2c(10,0);
Y[2*Anode[1]  ,2*nodeI  ]:=r2c(-10,0);
Y[2*Anode[0]+1,2*nodeI  ]:=10*r2c(XX.get,YY.get)*Dnode[0];
//th1=th2
end;
end;

function TfEQ.paramnum(s : string) : integer;
begin
// s:=uppercase(s);
 if s='X' then paramnum:=1 else 
 if s='Y' then paramnum:=2 else 
 if s='ANG' then paramnum:=3 else 
 paramnum:=0;
end;

function TfEQ.paramstr(wat : integer) : string;
begin
 case wat of 
  1 : paramstr:='X';
  2 : paramstr:='Y';
  3 : paramstr:='ANG';
  end;
end;
function TfEQ.getD(wat : integer) : double;
begin
case wat of 
 1 : getD:=XX.get;
 2 : getD:=YY.get;
 3 : getD:=ANG.get;
 else
 getD:=0;
 end;
end;
Procedure TfEQ.setD(z : double;wat : integer);
begin
 case wat of 
 1 : xx.setval(z);
 2 : yy.setval(z);
 3 : ang.setval(z);
 end;
end;


constructor Tfstub.create(P : pointer);
begin inherited create(P);Nnode:=1;layer:=0; end;


Procedure Tfstub.load(Np : integer;P : Tparams);
begin
Len:=getparm(Np,P,'LEN',1);
W1:=getparm(Np,P,'W1',1);
W2:=getparm(Np,P,'W2',0);
if W2.get=0 then W2:=W1;
end;


Procedure Tfstub.draw(var V0 : cvec;canvas : pdraw);
var
 pnts : cvec;
 r,d : tc;
 x : integer;
begin
canvas^.layer:=layer;
setlength(pnts,5);
r:=V0[2*Anode[0]];
d:=V0[2*Anode[0]+1]*Dnode[0];
//write('r=');cwrite(r);write(' d=');cwrite(d);writeln;
pnts[0]:=r+r2c(0,0.5)*d*w1.get;
pnts[1]:=r-r2c(0,0.5)*d*w1.get;
pnts[2]:=r-r2c(0,0.5)*d*w2.get+len.get*d;
pnts[3]:=r+r2c(0,0.5)*d*w2.get+len.get*d;
pnts[4]:=pnts[0];
//for x:=0 to 3 do begin;write(' pnt',x+1,'=');cwrite(pnts[x]);end;writeln;
canvas^.poly(5,pnts,name);
//canvas^.layer:=6;
//canvas^.
end;

constructor TfVia.create(P : pointer);
begin inherited create(P);Nnode:=1;layer:=0; end;


Procedure TfVia.load(Np : integer;P : Tparams);
begin
D:=getparm(Np,P,'D',1e-3);
Rpad:=getparm(Np,P,'RPAD',0);
end;


Procedure TfVia.draw(var V0 : cvec;canvas : pdraw);
var
 r,dr : tc;
begin
canvas^.layer:=layer;
r:=V0[2*Anode[0]];
if Rpad.get>0 then begin
  dr:=V0[2*Anode[0]+1]*Dnode[0];
  r:=r+dr*Rpad.get;
  canvas^.via(r,D.get,D.get+2*Rpad.get,name);
  end else
 canvas^.hole(r,D.get,name);
end;

constructor TfTee.create(P : pointer);
begin inherited create(P);Nnode:=3;layer:=0; end;


Procedure TfTee.load(Np : integer;P : Tparams);
begin
W1:=getparm(Np,P,'W1',1);
W2:=getparm(Np,P,'W2',1);
W3:=getparm(Np,P,'W3',1);
dir:=round(getparm(Np,P,'DIR',1).get);
end;

Procedure TfTee.getY(var Y : cmat;var RH : cvec);
var
 wm : double;
begin
if w1.get>w2.get then wm:=w1.get else wm:=w2.get;
//r1-r2+l.exp(th1)=0
Y[2*Anode[0]  ,2*nodeI+2]:=r2c(1,0);
Y[2*Anode[2]  ,2*nodeI+2]:=r2c(-1,0);
Y[2*Anode[0]+1,2*nodeI+2]:=r2c(w3.get*Dnode[0],dir*wm)/2;
//r1-r2+l.exp(th1)=0
Y[2*Anode[0]  ,2*nodeI+0]:=r2c(1,0);
Y[2*Anode[1]  ,2*nodeI+0]:=r2c(-1,0);
Y[2*Anode[0]+1,2*nodeI+0]:=r2c(w3.get*Dnode[0],0);
//th1 loodreg th2
Y[2*Anode[0]+1,2*nodeI+3]:=r2c(Dnode[0],0);
Y[2*Anode[2]+1,2*nodeI+3]:=r2c(Dnode[2],0)*r2c(0,1)*dir;
//th1=th3
Y[2*Anode[0]+1,2*nodeI+1]:=r2c(Dnode[0],0);
Y[2*Anode[1]+1,2*nodeI+1]:=r2c(Dnode[1],0);
end;


Procedure TfTee.draw(var V0 : cvec;canvas : pdraw);
var
 pnts : cvec;
 r,d : tc;
 x : integer;
 wm : double;
begin
canvas^.layer:=layer;
if w1.get>w2.get then wm:=w1.get/2 else wm:=w2.get/2;
setlength(pnts,5);
r:=V0[2*Anode[0]];
d:=V0[2*Anode[0]+1]*Dnode[0];
pnts[0]:=r+r2c(0,1)*d*wm;
pnts[1]:=r-r2c(0,1)*d*wm;
pnts[2]:=pnts[1]+w3.get*d;
pnts[3]:=pnts[0]+w3.get*d;
pnts[4]:=pnts[0];
canvas^.poly(5,pnts,name);
end;

constructor TFcorner.create(P : pointer);
begin inherited create(P);Nnode:=2;layer:=0; end;


Procedure TFcorner.load(Np : integer;P : Tparams);
begin
W1:=getparm(Np,P,'W1',1e-3);
W2:=getparm(Np,P,'W2',0);
if W2.get=0 then W2:=W1;
dir:=round(getparm(Np,P,'DIR',1).get);
end;

Procedure TFcorner.getY(var Y : cmat;var RH : cvec);
begin
//r1-r2+l.exp(th1)=0
Y[2*Anode[0]  ,2*nodeI  ]:=r2c(1,0);
Y[2*Anode[1]  ,2*nodeI  ]:=r2c(-1,0);
Y[2*Anode[0]+1,2*nodeI  ]:=r2c(w2.get*Dnode[0],dir*w1.get)/2;
//th1 loodreg th2
Y[2*Anode[0]+1,2*nodeI+1]:=r2c(Dnode[0],0);
Y[2*Anode[1]+1,2*nodeI+1]:=r2c(Dnode[1],0)*r2c(0,1)*dir;
end;


Procedure TFcorner.draw(var V0 : cvec;canvas : pdraw);
var
// pnts : cvec;
 r,d : tc;
begin
canvas^.layer:=layer;
r:=V0[2*Anode[0]];
d:=V0[2*Anode[0]+1]*Dnode[0];
canvas^.rect(r,r+w2.get*d,w1.get,name);
end;

constructor TFbend.create(P : pointer);
begin inherited create(P);Nnode:=2;layer:=0; end;


Procedure TFbend.load(Np : integer;P : Tparams);
begin
W:=getparm(Np,P,'W',1e-3);
LEN:=getparm(Np,P,'LEN',1e-3);
ANG:=getparm(Np,P,'ANG',1e-3);
ANG2:=getparm(Np,P,'ANG2',0);
ANG3:=getparm(Np,P,'ANG3',0);
LEN0:=getparm(Np,P,'LEN0',0);
LEN1:=getparm(Np,P,'LEN1',0);
LEN2:=getparm(Np,P,'LEN2',0);
LEN3:=getparm(Np,P,'LEN3',0);
Rmin:=getparm(Np,P,'RMIN',3);
end;

function Tfbend.penalty : double;
var
 l,l0,l1,l2,l3,h1,h2,h3,hk,ww,z,rr : double;
begin
l:=len.get;
l0:=len0.get;if l0>l then l0:=l;
l:=l-l0;
l1:=len1.get;if l1>l then l1:=l;
l:=l-l1;
l2:=len2.get;if l2>l then l2:=l;
l:=l-l2;
l3:=len3.get;if l3>l then l3:=l;
l:=l-l3;
h1:=ang.get/180*pi;
h2:=ang2.get/180*pi;
h3:=ang3.get/180*pi;
hk:=abs(h1)+abs(h2)+abs(h3);
ww:=w.get;
if (hk>=1e-6) then begin
 rr:=l/hk;
 if rr<rmin.get*ww then begin
   rr:=rmin.get*ww;
   z:=l/rr;
   h1:=h1*z/hk;
   h2:=h2*z/hk;
   h3:=h3*z/hk;
   hk:=z;
   end;end;
if (hk<1e-6) then penalty:=0 else penalty:=ww/rr;
end;


Procedure TFbend.getY(var Y : cmat;var RH : cvec);
var
 d,r0,r1,d2 : tc;
 hk,z,r,h1,h2,h3,l,l0,l1,l2,l3 : double;
begin
l:=len.get;
l0:=len0.get;if l0>l then l0:=l;
l:=l-l0;
l1:=len1.get;if l1>l then l1:=l;
l:=l-l1;
l2:=len2.get;if l2>l then l2:=l;
l:=l-l2;
l3:=len3.get;if l3>l then l3:=l;
l:=l-l3;

  Y[2*Anode[0]  ,2*nodeI  ]:=r2c(1,0);
  Y[2*Anode[1]  ,2*nodeI  ]:=r2c(-1,0);

  Y[2*Anode[0]+1,2*nodeI+1]:=r2c(Dnode[0],0);
h1:=ang.get/180*pi;
h2:=ang2.get/180*pi;
h3:=ang3.get/180*pi;
hk:=abs(h1)+abs(h2)+abs(h3);
if (hk>=1e-6) then begin
 r:=l/hk;
 if r<rmin.get*w.get then begin
   r:=rmin.get*w.get;
   z:=l/r;
   h1:=h1*z/hk;
   h2:=h2*z/hk;
   h3:=h3*z/hk;
   hk:=z;
   end;end;
if hk<1e-6 then begin
  Y[2*Anode[0]+1,2*nodeI  ]:=r2c(len.get,0)*Dnode[0];
  Y[2*Anode[1]+1,2*nodeI+1]:=r2c(Dnode[1],0);

  end else begin
  //offset
//  r:=l/hk;
  r1:=r2c(l0,0);
  d:=expi(-h1);
  if h1<0 then r0:=r2c( d[2],1-d[1])
          else r0:=r2c(-d[2],d[1]-1);
  if l1>0 then r1:=r1+r2c(l1,0)*d;
  if h2<>0 then begin
   d2:=expi(-h2);
   if h2<0 then r0:=r0+r2c( d2[2],1-d2[1])*d 
           else r0:=r0+r2c(-d2[2],d2[1]-1)*d;
   d:=d*d2;
  end;
  if l2>0 then r1:=r1+r2c(l2,0)*d;
  if h3<>0 then begin
   d2:=expi(-h3);
   if h3<0 then r0:=r0+r2c( d2[2],1-d2[1])*d 
           else r0:=r0+r2c(-d2[2],d2[1]-1)*d;
   d:=d*d2;
  end;
  if l3>0 then r1:=r1+r2c(l3,0)*d;
  r0:=r*r0+r1;
  Y[2*Anode[0]+1,2*nodeI  ]:=r0*Dnode[0];
  //diretion
//  d:=expi(h1+h2+h3);
  Y[2*Anode[1]+1,2*nodeI+1]:=Dnode[1]*ccomp(d);
 end;
end;


Procedure TFbend.draw(var V0 : cvec;canvas : pdraw);
var
 pnts : cvec;
 r,d,d2 : tc;
 x : integer;
 hk,z,RR,h1,h2,h3,l,l0,l1,l2,l3,ww : double;
begin
canvas^.layer:=layer;
l:=len.get;
l0:=len0.get;if l0>l then l0:=l;
l:=l-l0;
l1:=len1.get;if l1>l then l1:=l;
l:=l-l1;
l2:=len2.get;if l2>l then l2:=l;
l:=l-l2;
l3:=len3.get;if l3>l then l3:=l;
l:=l-l3;
h1:=ang.get/180*pi;
h2:=ang2.get/180*pi;
h3:=ang3.get/180*pi;
hk:=abs(h1)+abs(h2)+abs(h3);
ww:=w.get;
if (hk>=1e-6) then begin
 rr:=l/hk;
 if rr<rmin.get*ww then begin
   rr:=rmin.get*ww;
   z:=l/rr;
   h1:=h1*z/hk;
   h2:=h2*z/hk;
   h3:=h3*z/hk;
   hk:=z;
   end;end;
//hk:=ang.get/180*pi;
r:=V0[2*Anode[0]];
d:=V0[2*Anode[0]+1]*Dnode[0];
if hk<1e-6 then begin
// setlength(pnts,5);
 canvas^.rect(r,r+len.get*d,ww,name);
 end else begin
  RR:=l/hk;
  if l0>0 then begin
    canvas^.rect(r,r+l0*d,ww,name);
    r:=r+l0*d;
    end;
  if h1<0 then canvas^.arc2(r,d,RR,h1,ww,1,name)
          else canvas^.arc2(r,d,RR,h1,ww,-1,name);
  if l1>0 then begin
    canvas^.rect(r,r+l1*d,ww,name);
    r:=r+l1*d;
    end;
  if h2<>0 then
  if h2<0 then canvas^.arc2(r,d,RR,h2,ww,1,name)
          else canvas^.arc2(r,d,RR,h2,ww,-1,name);
  if l2>0 then begin
    canvas^.rect(r,r+l2*d,ww,name);
    r:=r+l2*d;
    end;
  if h3<>0 then
  if h3<0 then canvas^.arc2(r,d,RR,h3,ww,1,name)
          else canvas^.arc2(r,d,RR,h3,ww,-1,name);
  if l3>0 then begin
    canvas^.rect(r,r+l3*d,ww,name);
    r:=r+l3*d;
    end;
 end;
end;

function TfBend.paramnum(s : string) : integer;
begin
 if s='ANG' then paramnum:=1 else
 if s='ANG2' then paramnum:=2 else
 if s='ANG3' then paramnum:=3 else 
 if s='LEN0' then paramnum:=4 else 
 if s='LEN1' then paramnum:=5 else 
 if s='LEN2' then paramnum:=6 else 
 if s='LEN3' then paramnum:=7 else paramnum:=0;
end;

function TfBend.paramstr(wat : integer) : string;
begin
 case wat of 
  1 : paramstr:='ANG';
  2 : paramstr:='ANG2';
  3 : paramstr:='ANG3';
  4 : paramstr:='LEN0';
  5 : paramstr:='LEN1';
  6 : paramstr:='LEN2';
  7 : paramstr:='LEN3';
  end;
end;
function TfBend.getD(wat : integer) : double;
begin
case wat of 
 1 : getD:=ang.get;
 2 : getD:=ang2.get;
 3 : getD:=ang3.get;
 4 : getD:=len0.get;
 5 : getD:=len1.get;
 6 : getD:=len2.get;
 7 : getD:=len3.get;
 else
 getD:=0;
 end;
end;
Procedure TfBend.setD(z : double;wat : integer);
begin
 case wat of 
 1 : ang.setval(z);
 2 : ang2.setval(z);
 3 : ang3.setval(z);
 4 : len0.setval(z);
 5 : len1.setval(z);
 6 : len2.setval(z);
 7 : len3.setval(z);
 end;
end;


constructor T2pad.create(P : pointer);
begin inherited create(P);Nnode:=2;layer:=1; end;



Procedure T2pad.load(Np : integer;P : Tparams);
begin
W:=getparm(Np,P,'W',1e-3);
B:=getparm(Np,P,'B',1e-3);
Len:=getparm(Np,P,'D',1e-3);
dir1:=round(getparm(Np,P,'DIR1',0).get);
dir2:=round(getparm(Np,P,'DIR2',0).get);
end;

Procedure T2pad.getY(var Y : cmat;var RH : cvec);
var
 r : tc;
 ww,bb : double;
begin
r:=r2c(len.get,0);
ww:=w.get;bb:=b.get;
case dir2 of
 0 : r:=r+r2c(bb,0);
 1 : r:=r+r2c(bb/2,-ww/2);
-1 : r:=r+r2c(bb/2, ww/2);
end;
case dir1 of
 0 : r:=r+r2c(bb,0);
 1 : r:=r-r2c(-bb/2,ww/2);
-1 : r:=-r-r2c(bb/2,ww/2);
end;
if dir1<>0 then r:=r*r2c(0,1);
//r1-r2+l.exp(th1)=0
Y[2*Anode[0]  ,2*nodeI  ]:=r2c(1,0);
Y[2*Anode[1]  ,2*nodeI  ]:=r2c(-1,0);
Y[2*Anode[0]+1,2*nodeI  ]:=r*Dnode[0];
//th1=th2
case dir1-dir2 of
 0 : r:=r2c(1,0);
 1 : r:=r2c(0,-1);
 -2,2 : r:=r2c(-1,0);
 -1 : r:=r2c(0,1);
 end;
Y[2*Anode[0]+1,2*nodeI+1]:=r2c(Dnode[0],0);
Y[2*Anode[1]+1,2*nodeI+1]:=Dnode[1]*r;
end;


Procedure T2pad.draw(var V0 : cvec;canvas : pdraw);
var
 r,d : tc;
 x : integer;
 wm : double;
 ww,dd : double;
begin
canvas^.layer:=layer;
ww:=w.get;
dd:=b.get;
r:=V0[2*Anode[0]];
d:=V0[2*Anode[0]+1]*Dnode[0];
case dir1 of
 1 : begin;
   r:=r+r2c(ww/2,-dd/2)*d;
   d:=d*r2c(0,1);
   end;
 -1 : begin;
   r:=r+r2c(ww/2,dd/2)*d;
   d:=d*r2c(0,-1);
   end;
  end;
 
canvas^.rect(r,r+dd*d,ww,name);
r:=r+(len.get+dd)*d;
canvas^.rect(r,r+dd*d,ww,name);
r:=r-(len.get)/2*d;
if (value.get<>0) or (lable<>'') then begin
 canvas^.layer:=5;
 canvas^.fontsize:=dd;
 if value.get<>0 then canvas^.lable(r,d,FloatToEng2(value.get),name)
                 else canvas^.lable(r,d,lable,name);
 end;
end;

constructor T2padM.create(P : pointer);
begin inherited create(P);Nnode:=2;layer:=1; end;



Procedure T2padM.load(Np : integer;P : Tparams);
begin
W:=getparm(Np,P,'W',1e-3);
B:=getparm(Np,P,'B',1e-3);
Len:=getparm(Np,P,'D',1e-3);
dir1:=round(getparm(Np,P,'DIR1',0).get);
dir2:=round(getparm(Np,P,'DIR2',0).get);
end;

Procedure T2padM.getY(var Y : cmat;var RH : cvec);
var
 r : tc;
 ll : double;
begin
ll:=len.get+b.get;
//r1-r2+l.exp(th1)=0
case dir1 of
 0 : r:=r2c(ll,0);
 1 : r:=r2c(0,ll);
-1 : r:=r2c(0,-ll);
end;
Y[2*Anode[0]  ,2*nodeI  ]:=r2c(1,0);
Y[2*Anode[1]  ,2*nodeI  ]:=r2c(-1,0);
Y[2*Anode[0]+1,2*nodeI  ]:=r*Dnode[0];

case dir1-dir2 of
 0 : r:=r2c(1,0);
 1 : r:=r2c(0,-1);
 -2,2 : r:=r2c(-1,0);
 -1 : r:=r2c(0,1);
 end;
Y[2*Anode[0]+1,2*nodeI+1]:=r2c(Dnode[0],0);
Y[2*Anode[1]+1,2*nodeI+1]:=Dnode[1]*r;
end;


Procedure T2padM.draw(var V0 : cvec;canvas : pdraw);
var
 r,d,ll : tc;
 x : integer;
 wm : double;
 ww,dd : double;
begin
canvas^.layer:=layer;
ww:=w.get;
dd:=b.get;
r:=V0[2*Anode[0]];
d:=V0[2*Anode[0]+1]*Dnode[0];
case dir1 of
 0 :    begin
	    canvas^.rect(r-(dd*d/2),r+(dd*d/2),ww,name);
	    ll:=(len.get+dd)*d;
	    r:=r+ll;
	    canvas^.rect(r-(dd*d/2),r+(dd*d/2),ww,name);
	    end;
 1 : begin
	    canvas^.rect(r-(ww*d/2),r+(ww*d/2),dd,name);
	    ll:=(len.get+dd)*d*r2c(0,1);
	    r:=r+ll;
	    canvas^.rect(r-(ww*d/2),r+(ww*d/2),dd,name);
	    end;
 -1 : begin
	    canvas^.rect(r-(ww*d/2),r+(ww*d/2),dd,name);
	    ll:=(len.get+dd)*d*r2c(0,-1);
	    r:=r+ll;
	    canvas^.rect(r-(ww*d/2),r+(ww*d/2),dd,name);
	    end;
  end;

if (value.get<>0) or (lable<>'') then begin
 canvas^.layer:=5;
 canvas^.fontsize:=dd;
 r:=r-ll/2;
 if value.get<>0 then canvas^.lable(r,d,FloatToEng2(value.get),name)
                 else canvas^.lable(r,d,lable,name);
 end;
end;

constructor T2pad2.create(P : pointer);
begin inherited create(P);Nnode:=2;layer:=1; end;



Procedure T2pad2.load(Np : integer;P : Tparams);
begin
W:=getparm(Np,P,'W',1e-3);
B:=getparm(Np,P,'B',1e-3);
Len:=getparm(Np,P,'D',1e-3);
end;

Procedure T2pad2.getY(var Y : cmat;var RH : cvec);
var
 r : tc;
 ww,bb : double;
begin
r:=r2c(len.get,0);
//r1-r2+l.exp(th1)=0
Y[2*Anode[0]  ,2*nodeI  ]:=r2c(1,0);
Y[2*Anode[1]  ,2*nodeI  ]:=r2c(-1,0);
Y[2*Anode[0]+1,2*nodeI  ]:=r*Dnode[0];
//th1=th2
Y[2*Anode[0]+1,2*nodeI+1]:=r2c(Dnode[0],0);
Y[2*Anode[1]+1,2*nodeI+1]:=Dnode[1]*r2c(1,0);
end;


Procedure T2pad2.draw(var V0 : cvec;canvas : pdraw);
var
 r,d : tc;
 x : integer;
 wm : double;
 ww,dd : double;
begin
canvas^.layer:=layer;
ww:=w.get;
dd:=b.get;
r:=V0[2*Anode[0]];
d:=V0[2*Anode[0]+1]*Dnode[0];
 
canvas^.rect(r-dd*d,r,ww,name);
r:=r+(len.get)*d;
canvas^.rect(r,r+dd*d,ww,name);
r:=r-(len.get)/2*d;
if (value.get<>0) or (lable<>'') then begin
 canvas^.layer:=5;
 canvas^.fontsize:=dd;
 if value.get<>0 then canvas^.lable(r,d,FloatToEng2(value.get),name)
                 else canvas^.lable(r,d,lable,name);
 end;
end;


constructor T2pnt.create(P : pointer);
begin inherited create(P);Nnode:=2;layer:=0; end;

Procedure T2pnt.load(Np : integer;P : Tparams);
begin
Len:=getparm(Np,P,'LEN',1e-3);
Dir1:=getparm(Np,P,'DIR1',0);
Dir2:=getparm(Np,P,'DIR2',0);
end;

Procedure T2pnt.getY(var Y : cmat;var RH : cvec);
var
 r : tc;
 ww,bb : double;
begin
r:=expi((dir2.get-dir1.get)*pi/180);
Y[2*Anode[0]+1,2*nodeI+1]:=r2c(Dnode[0],0);
Y[2*Anode[1]+1,2*nodeI+1]:=Dnode[1]*r;
//r1-r2+l.exp(th1)=0
r:=expi(dir1.get*pi/180)*len.get;
Y[2*Anode[0]  ,2*nodeI  ]:=r2c(1,0);
Y[2*Anode[1]  ,2*nodeI  ]:=r2c(-1,0);
Y[2*Anode[0]+1,2*nodeI  ]:=r*Dnode[0];
end;

constructor T4pnt.create(P : pointer);
begin inherited create(P);Nnode:=4;layer:=0; end;

Procedure T4pnt.load(Np : integer;P : Tparams);
var
 dir : double;
begin
Len1:=getparm(Np,P,'LEN1',1e-3);
Len2:=getparm(Np,P,'LEN2',1e-3);
dir:=getparm(Np,P,'DIR',0).get;
Dir1:=getparm(Np,P,'DIR1',dir);
Dir2:=getparm(Np,P,'DIR2',dir);
Dir3:=getparm(Np,P,'DIR3',dir);
Dir4:=getparm(Np,P,'DIR4',dir);
end;

Procedure T4pnt.getY(var Y : cmat;var RH : cvec);
var
 r,d : tc;
 ww,bb : double;
begin
Y[2*Anode[0]+1,2*nodeI+1]:=r2c(Dnode[0],0);
Y[2*Anode[1]+1,2*nodeI+1]:=Dnode[1]*expi((-dir2.get-dir1.get)*pi/180);

Y[2*Anode[0]+1,2*nodeI+3]:=r2c(Dnode[0],0);
Y[2*Anode[2]+1,2*nodeI+3]:=-Dnode[1]*expi((-dir3.get-dir1.get)*pi/180);

Y[2*Anode[0]+1,2*nodeI+5]:=r2c(Dnode[0],0);
Y[2*Anode[3]+1,2*nodeI+5]:=Dnode[1]*expi((dir4.get-dir1.get)*pi/180);

d:=expi(dir1.get*pi/180);
r:=d*r2c(len1.get,0);
Y[2*Anode[0]  ,2*nodeI  ]:=r2c(1,0);
Y[2*Anode[1]  ,2*nodeI  ]:=r2c(-1,0);
Y[2*Anode[0]+1,2*nodeI  ]:=r*Dnode[0];

r:=d*r2c(0,len2.get);
Y[2*Anode[0]  ,2*nodeI+2]:=r2c(1,0);
Y[2*Anode[2]  ,2*nodeI+2]:=r2c(-1,0);
Y[2*Anode[0]+1,2*nodeI+2]:=r*Dnode[0];

r:=d*r2c(len1.get,len2.get);
Y[2*Anode[0]  ,2*nodeI+4]:=r2c(1,0);
Y[2*Anode[3]  ,2*nodeI+4]:=r2c(-1,0);
Y[2*Anode[0]+1,2*nodeI+4]:=r*Dnode[0];
end;

Procedure T4pnt.draw(var V0 : cvec;canvas : pdraw);
var
 r0,r,d : tc;
 dd : double;
begin
if lable='' then exit;
r0:=V0[2*Anode[0]];
d:=V0[2*Anode[0]+1]*Dnode[0];
d:=d*expi(dir1.get*pi/180);

dd:=len1.get/2;
r:=r0+d*r2c(len1.get/2,len2.get/2);

 canvas^.layer:=5;
 canvas^.fontsize:=dd;
 canvas^.lable(r,d,lable,name);
end;


constructor TfPAD.create(P : pointer);
begin inherited create(P);Nnode:=2;layer:=1; end;


Procedure TfPAD.load(Np : integer;P : Tparams);
begin
H:=getparm(Np,P,'H',1e-3);
W:=getparm(Np,P,'W',1e-3);
offH:=getparm(Np,P,'OFFH',0);
offW:=getparm(Np,P,'OFFW',0);
end;

Procedure TfPAD.getY(var Y : cmat;var RH : cvec);
begin
//r1-r2+l.exp(th1)=0
Y[2*Anode[0]  ,2*nodeI  ]:=r2c(1,0);
Y[2*Anode[1]  ,2*nodeI  ]:=r2c(-1,0);
Y[2*Anode[0]+1,2*nodeI  ]:=r2c((H.get/2+offH.get)*Dnode[0],0);
//th1=th2
Y[2*Anode[0]+1,2*nodeI+1]:=r2c(Dnode[0],0);
Y[2*Anode[1]+1,2*nodeI+1]:=r2c(Dnode[1],0);
end;


Procedure TfPAD.draw(var V0 : cvec;canvas : pdraw);
var
 r,d,r1,r2 : tc;
 x : integer;
begin
canvas^.layer:=layer;
r:=V0[2*Anode[0]];
d:=V0[2*Anode[0]+1]*Dnode[0];
//write('r=');cwrite(r);write(' d=');cwrite(d);writeln;
r1:=r+r2c(0,1)*d*(offW.get)-(h.get/2+offH.get)*d;
r2:=r+r2c(0,1)*d*(offW.get)+(h.get/2-offH.get)*d;
//for x:=0 to 3 do begin;write(' pnt',x+1,'=');cwrite(pnts[x]);end;writeln;
canvas^.rect(r1,r2,w.get,name);
end;


constructor TfMSB.create(P : pointer);
begin inherited create(P);Nnode:=2;layer:=0; end;


Procedure TfMSB.load(Np : integer;P : Tparams);
begin
W1:=getparm(Np,P,'W1',1e-3);
Len:=getparm(Np,P,'LEN',1e-3);
Ang:=getparm(Np,P,'DIR',0);
Rad:=getparm(Np,P,'R',1);
YY:=getparm(Np,P,'Y',0);
//W2:=getparm(Np,P,'W2',0);
//if Rad.get=0 then Rad:=W1;
end;

Procedure TfMSB.getY(var Y : cmat;var RH : cvec);
var
 k1,k2,k3,D,sh1,ang2,Y2 : double;
begin
Y2:=YY.get;
ang2:=ang.get/180*pi;
hk:=(len.get/rad.get-ang2)/2;
if hk>pi then hk:=pi;
k1:=2*(1-cos(hk));
k2:=2*sin(hk);
k3:=1-Y2/rad.get-cos(ang2);
sh1:=-k3*k2;
//write(' sh1=',sh1,' hk=',hk,' k3=',k3);
{if sh1>1e-20 then begin
  k3:=0;
  sh1:=0;
  end;}
k1:=k1*k1;
k2:=k2*k2;
k3:=k3*k3;
D:=k3*k2-(k2+k1)*(k3-k1);
if D<0 then begin
  write('[D<0]');
  D:=0;
  end;
sh1:=(sh1+sqrt(D))/(k2+k1);
//writeln(' D=',D,' sh1=',sh1);
h1:=arcsin(sh1);

if (ang2+len.get/rad.get < 2*h1) then begin
//  write('e');
//  hk:=h1-ang2;
//  Y2:=rad.get*(1+cos(hk-h1)-2*cos(h1));
  Y[2*Anode[0]  ,2*nodeI  ]:=r2c(1,0);
  Y[2*Anode[1]  ,2*nodeI  ]:=r2c(-1,0);
  Y[2*Anode[0]+1,2*nodeI  ]:=r2c(len.get,0)*Dnode[0];
  Y[2*Anode[0]+1,2*nodeI+1]:=r2c(Dnode[0],0);
  Y[2*Anode[1]+1,2*nodeI+1]:=r2c(Dnode[1],0);
  end else begin
 XX:=rad.get*(2*sh1+2*sin(hk-h1)+sin(ang2));

//r1-r2+l.exp(th1)=0
Y[2*Anode[0]  ,2*nodeI  ]:=r2c(1,0);
Y[2*Anode[1]  ,2*nodeI  ]:=r2c(-1,0);
Y[2*Anode[0]+1,2*nodeI  ]:=r2c(XX,Y2)*Dnode[0];
//th1=th2
Y[2*Anode[0]+1,2*nodeI+1]:=r2c(Dnode[0],0);
Y[2*Anode[1]+1,2*nodeI+1]:=r2c(Dnode[1],0)*expi(-ang2);
end;
//h3:=ang2+hk-h1;
//h3:=ang2/2-h1+len.get/rad.get/2 > 0;
end;


Procedure TfMSB.draw(var V0 : cvec;canvas : pdraw);
var
 pnts : cvec;
 r,d,r0 : tc;
 ang2,rr,h2,h3 : double;
 x : integer;
begin
canvas^.layer:=layer;
ang2:=ang.get/180*pi;
rr:=rad.get;
setlength(pnts,3);
r:=V0[2*Anode[0]];
d:=V0[2*Anode[0]+1]*Dnode[0];
h3:=ang2+hk-h1;
if h3<0 then begin
 rr:=w1.get;
 canvas^.rect(r,r+len.get*d,rr,name);
 end else begin
 canvas^.arc2(r,d,rr,-h1,w1.get,1,name);
 canvas^.arc2(r,d,rr,hk,w1.get,-1,name);
 //writeln('r=',rr,' h1=',h1,' h2=',hk,' h3=',h3);
 canvas^.arc2(r,d,rr,-h3,w1.get,1,name);
 end;
end;

function TfMSB.paramnum(s : string) : integer;
begin
 if s='W1' then paramnum:=1 else 
 if s='LEN' then paramnum:=2 else 
 if s='DIR' then paramnum:=3 else 
 if s='R' then paramnum:=4 else 
 if s='Y' then paramnum:=5 else 
 paramnum:=0;
end;

function TfMSB.paramstr(wat : integer) : string;
begin
 case wat of 
  1 : paramstr:='W1';
  2 : paramstr:='LEN';
  3 : paramstr:='DIR';
  4 : paramstr:='R';
  5 : paramstr:='Y';
  end;
end;
function TfMSB.getD(wat : integer) : double;
begin
case wat of 
 1 : getD:=w1.get;
 2 : getD:=len.get;
 3 : getD:=ang.get;
 4 : getD:=Rad.get;
 5 : getD:=YY.get;
 else
 getD:=0;
 end;
end;
Procedure TfMSB.setD(z : double;wat : integer);
begin
 case wat of 
 1 : w1.setval(z);
 2 : len.setval(z);
 3 : ang.setval(z);
 4 : Rad.setval(z);
 5 : YY.setval(z);
 end;
end;


end.