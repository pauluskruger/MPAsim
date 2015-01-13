unit Mminu;

interface
uses compu,sport,stringe,complex2,vectorD,FET;
type
 tc4 = array[1..4] of tc;
 
 TMmin = object(Tcomp)
   Rs : array of Pcomp;
   MC : cmat;
   MS : cmat;
   VS,EV : cvec;
   Nphase,Ndelay,Ndesp,Ftemp,Utemp,Nsignal : double;
   nds,rnds : array of integer;
   Vres  : tvec;
   MM,VL,VR : tmat;
   wr,wi : tvec;
   NR,N2,Fx : integer;
   signal : tc;
   signals : cvec;
   calcw : double;
   min : double;
   Numeig : integer;
   norm : ^transistor;
   updateA : boolean; //update gain and recalc?
   constructor create(P : pointer);
   function loads(ss : tstrings) : boolean; virtual;
   function calcMmin(eig: boolean;w : double) : double;
   procedure writeVec(var F : text);
   function paramnum(s : string) : integer; virtual;
   function paramdouble(wat : integer) : boolean; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   Procedure setD2(s : string;wat : integer); virtual;

   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;

   function getOutput(w : double;V0,Z0 : cvec;wat : integer) : tc; virtual;
   function getOutputx(w : double;V0,Z0 : cvec) : tc;
   procedure doUpdate(w : double;V0,Z0 : cvec;cnt : integer); virtual;
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getInput(V0,Z0 : cvec);
  end;

TRatio = object(Tcomp)
   RA,RB : array of Pcomp;
   RN : integer;
   function getVolt(RR,R2 : Pcomp) : tc;
   function loads(ss : tstrings) : boolean; virtual;
   function getOutput(w : double;V0,Z0 : cvec;wat : integer) : tc; virtual;
  end;
  
TMPA = object(Tcomp)
  Nr : integer; //number of amp paths
  NI,NO : pcomp;
  AP : array of Pcomp;
 yy,YYR,YA : cmat;
 yv,a1,a2 : cvec;
 lastw : double;
 lasti : integer;
 node1,node2 : array of integer;
   constructor create(P : pointer);
   function loads(ss : tstrings) : boolean; virtual;
//   function paramnum(s : string) : integer; virtual;
//   function paramstr(wat : integer) : string; virtual;
//   Procedure setD(z : double;wat : integer); virtual;
//   function getD(wat : integer) : double; virtual;
   function getOutput(w : double;V0,Z0 : cvec;wat : integer) : tc; virtual;
   function getYopt(w : double) : tc;
   function getAopt(w : double) : tc;
   function getWB(w : double) : tc;
   Procedure getAY(w : double;var v : cvec;x1,y1 : integer);
end;
  
PMmin = ^TMmin;
PRatio = ^TRatio;
PMPA = ^TMPA;
function P2Mmin(YY,NI : tc4) : double; overload;
function P2Mmin(Y1,Y2,Y3,Y4,N1,N2,N3,N4 : tc) : double; overload;
function P2MminA(Y1,Y2,Y3,Y4,N1,N2,N3,N4 : tc) : double;
function P2MminY(Y1,Y2,Y3,Y4,N1,N2,N3,N4 : tc) : tc;

implementation
uses sysutils,math,varu,nsevd,compnt,consts;

constructor tMPA.create(P : pointer);
begin inherited create(P);Nnode:=0;lastw:=0;lasti:=0; end;

function TMPA.loads(ss : tstrings) : boolean;
var
 x : integer;
begin
Nr:=len(ss)-3;
write('MPA load ',nr,' paths ... ');
//writeln(NR);
//for x:=1 to NR do writeln(x,' ',ss[x+1]);
NI:=psport(Parent)^.findcomp(ss[2]);
NO:=psport(Parent)^.findcomp(ss[3+Nr]);
setlength(AP,Nr);
for x:=1 to NR do AP[x-1]:=psport(Parent)^.findcomp(ss[2+x]);
for x:=0 to NR-1 do 
if AP[x]=nil then begin;writeln('Error loading amp ',x+1);halt(1);end;
if NI=nil    then begin;writeln('Error loading input network');halt(1);end;
if NO=nil    then begin;writeln('Error loading output network');halt(1);end;
for x:=0 to NR-1 do 
if AP[x]^.nnode<>2+1 then begin;writeln('Amp ',x+1,' have ',AP[x]^.nnode-1,' nodes, must be 2');halt(1);end;
if NI^.nnode<>nr+2 then begin;writeln('Input network have ',NI^.nnode-1,' nodes, must be ',nr+1);halt(1);end;
if NO^.nnode<>nr+2 then begin;writeln('Output network have ',NO^.nnode-1,' nodes, must be ',nr+1);halt(1);end;
CMsetsize(Nr+2,Nr+2,YY);
CMsetsize(Nr+2,Nr+2,YYR);
CMsetsize(3,3,YA);
setlength(yv,nr);
setlength(a1,nr);
setlength(a2,nr);
writeln('Done');
loads:=true;
end;

function TMPA.getAopt(w : double) : tc;
var
 J,z : tc;
 x : integer;
 diff : tr;
begin
if (lastw=w) and (lasti=1) then exit;
lastw:=w;lasti:=1;
J:=getYopt(w)+psport(parent)^.YY[1,1];
J:=(J)/psport(parent)^.YY[1,2];
//J:=cinv(J);
for x:=0 to nr-1 do a1[x]:=psport(parent)^.YY[3+x,2]*J;
for x:=0 to nr-1 do a2[x]:=psport(parent)^.YY[3+x,1]+yv[x];
//for x:=0 to nr-1 do a2[x]:=a2[x]*J;
//writeln;
//cvwrite(nr,a1);
//cvwrite(nr,a2);
{z:=czero;
for x:=0 to nr-1 do z:=z+a1[x]*YY[1,x+2];
writeln;
write('Y21=');cwriteEng(psport(parent)^.YY[1,2]);
write('AYi=');cwriteEng(z);}

diff:=0;
//for x:=0 to nr-1 do diff:=diff+cabs2( (a1[x]-a2[x])/(a1[x]+a2[x]) );
for x:=0 to nr-1 do diff:=diff+cabs2( (a1[x]-a2[x]) );
diff:=diff/nr;
getAopt:=r2c(diff,0); 
end;

function TMPA.getYopt(w : double) : tc;
var
 I,J : tc;
 x,y : integer;
begin
//writeln('MPA getoutput');
//1 = Yopt
setlength(node2,nr+2);
for x:=0 to nr+1 do for y:=0 to nr+1 do yy[x,y]:=czero;
for x:=0 to nr+1 do node2[x]:=x;
node1:=NI^.node;
NI^.node:=node2;
NI^.getY(w,YY);
NI^.node:=node1;

for x:=1 to nr do begin
 yy[x+1,x+1]:=yy[x+1,x+1]-Psport(AP[x-1])^.calc2PMmin(2);
// write(x,': ');cwriteEng(Psport(AP[x-1])^.calc2PMmin(2));writeln;
 end;
//writeln('YY=');
//CMwrite(Nr+2,Nr+2,YY);
CMinv(Nr+2,YY,2,1+nr,YYR);

for x:=0 to nr+1 do for y:=0 to nr+1 do yy[x,y]:=czero;
for x:=0 to nr+1 do node2[x]:=x;
node1:=NI^.node;
NI^.node:=node2;
NI^.getY(w,YY);
NI^.node:=node1;

{writeln('YY=');
CMwrite(Nr+2,Nr+2,YY);
writeln('YYR=');
CMwrite(Nr+2,Nr+2,YYR);

with psport(parent)^ do begin
 writeln('YY''=');
 CMwrite(Nt,Nt,YY);
 end;
} 
 
//write('YYR(4,2)=');cwriteEng(YYR[3,1]);writeln;
J:=-YY[1,1];
//J:=czero;
for x:=1 to nr do begin
  I:=czero;
  for y:=1 to nr do I:=I+YYR[x+1,y+1]*YY[y+1,1];
  J:=J+I*YY[1,x+1];
  yv[x-1]:=I;
  end;
//cvwrite(nr,yv);
//cwriteEng(J);
getYopt:=J;
end;

Procedure TMPA.getAY(w : double;var v : cvec;x1,y1 : integer);
var
x : integer;
begin
 setlength(node1,3);
 setlength(node2,3);
 for x:=0 to 2 do node2[x]:=x; 
for x:=0 to nr-1 do begin
 YA[x1,y1]:=czero;
{ YA[1,1]:=czero;
 YA[1,2]:=czero;
 YA[2,1]:=czero;
 YA[2,2]:=czero;
 YA[0,0]:=czero;}
 node1:=AP[x]^.node;
 AP[x]^.node:=node2;
 AP[x]^.getY(w,YA); 
 AP[x]^.node:=node1;
 v[x]:=YA[x1,y1];
//write('YA=');CMwrite(4,4,YA);writeln;
//write('YA=',integer(@ya[1,1]));
 end;
end;

function TMPA.getWB(w : double) : tc;
var
 I,J1,J2 : tc;
 x,y : integer;
 diff,Z : double;
begin
if (lastw=w) and (lasti=2) then exit;
lastw:=w;lasti:=2;
//writeln;
J2:=1/(getYopt(w)+psport(parent)^.YY[1,1]);
J1:=1/psport(parent)^.YY[1,2];

//getYopt(w); //yv=Ysi/(Yii-Yopt)
//*** calc A = 1/(Yoo+Y22) * Y21

setlength(node2,nr+2);
for x:=0 to nr+1 do for y:=0 to nr+1 do yy[x,y]:=czero;
for x:=0 to nr+1 do node2[x]:=x; //output, amp 1 ... nr
node1:=NO^.node;
NO^.node:=node2;
NO^.getY(w,YY); //YY=Yoo
NO^.node:=node1;

getAY(w,a1,2,2);
for x:=1 to nr do YY[x+1,x+1]:=YY[x+1,x+1]+a1[x-1]; //YY=Yoo+Y22
//write('Y22:  ');cvwrite(nr,a1);

//writeln('YY=');
//CMwrite(Nr+2,Nr+2,YY);
CMinv(Nr+2,YY,2,1+nr,YYR);// YY = 1/(Yoo+Y22)

for x:=0 to nr+1 do for y:=0 to nr+1 do yy[x,y]:=czero;
for x:=0 to nr+1 do node2[x]:=x; //output, amp 1 ... nr
node1:=NO^.node;
NO^.node:=node2;
NO^.getY(w,YY); //YY=Yoo
NO^.node:=node1;

getAY(w,a1,1,2); //Y21
//write('Y21 ');cvwrite(nr,a1);
for x:=1 to nr do
 for y:=1 to nr do YYR[x+1,y+1]:=YYR[x+1,y+1]*a1[x-1]; //YYR=1/(Yoo+Y22) * Y21

//writeln('YR*Y21=');
//CMwrite(Nr+2,Nr+2,YYR);
 
//w = a2 = Ylo*YYR

for x:=1 to nr do begin
  I:=czero;
  for y:=1 to nr do I:=I+YYR[x+1,y+1]*YY[y+1,1];
  a2[x-1]:=I*J1;
  end;

//YYR = - Y12 * YYR
getAY(w,a1,2,1);
//write('Y12 ');cvwrite(nr,a1);
for x:=1 to nr do
 for y:=1 to nr do YYR[x+1,y+1]:=-YYR[x+1,y+1]*a1[y-1];

//YYR = YYR + Y11 + Yopt
getAY(w,a1,1,1);
for x:=1 to nr do YYR[x+1,x+1]:=YYR[x+1,x+1]+a1[x-1]+Psport(AP[x-1])^.calc2PMmin(2);

//b' = -yv YYR
for x:=1 to nr do begin
  I:=czero;
  for y:=1 to nr do I:=I+YYR[x+1,y+1]*yv[y-1];
  a1[x-1]:=-I*J2;
  end;


//cvwrite(nr,yv);
//cvwrite(nr,a1);
//cvwrite(nr,a2);
// test * (Yii+Yin)-1 = same as getAopt!
{for x:=1 to nr do begin
  I:=czero;
  for y:=1 to nr do I:=I+psport(parent)^.YY[x+2,y+2]*a2[y-1];
  a1[x-1]:=-I;
  end;}

//Normalise
{Z:=0;
for x:=0 to nr-1 do Z:=Z+cabs2(a1[x]);
Z:=1/sqrt(Z);
for x:=0 to nr-1 do a1[x]:=a1[x]*Z; 
J:=r2c(1,0);
for x:=0 to nr-1 do J:=J*a1[x];
z:=crad(J);}
{
J:=czero;
for x:=0 to nr-1 do J:=J+a1[x];
J:=nr/J;
for x:=0 to nr-1 do a1[x]:=a1[x]*J; 
J:=czero;
for x:=0 to nr-1 do J:=J+a2[x];
J:=nr/J;
for x:=0 to nr-1 do a2[x]:=a2[x]*J; 
}

diff:=0;
for x:=0 to nr-1 do diff:=diff+cabs2( (a1[x]-a2[x])/(a1[x]+a2[x]) );
//for x:=0 to nr-1 do diff:=diff+cabs2( (a1[x]-a2[x]) );
diff:=diff/nr;
getWB:=r2c(diff,0); 

end;

{function getG(w : double;x : integer) : tc;
begin
end;
 psport(parent)^.YY[3+x+nr,2]*
}
function TMPA.getOutput(w : double;V0,Z0 : cvec;wat : integer) : tc;
var 
 J : tc;
begin
case wat of
 0 : getOutput:=getYopt(w);
 1 : begin
   J:=getYopt(w);
 //  cwriteEng(J);
   getoutput:=(0.02-J)/(0.02+J);
   end;
 2 : getOutput:=getAopt(w);
 3 : getOutput:=getWB(w);
// 3 : getOutput:=psport(parent)^.YY[1,2];
// 4 : getOutput:=psport(parent)^.YY[2,1];
 101..199 : if wat-101<nr then begin;getWB(w);getOutput:=a1[wat-101];end;
 201..299 : if wat-201<nr then begin;getWB(w);getOutput:=a2[wat-201];end;
 301..399 : if wat-301<nr then begin;getAopt(w);getOutput:=a1[wat-301]/psport(parent)^.YY[1,2];end;
 401..499 : if wat-401<nr then begin;getAopt(w);getOutput:=a2[wat-401]/psport(parent)^.YY[1,2];end;
 else
 getOutput:=czero;
 end;
end;

constructor tMmin.create(P : pointer);
begin inherited create(P);Nnode:=0;norm:=nil;updateA:=false; end;

procedure Tmmin.writeVec(var F : text);
var
 x : integer;
begin
write(f,' ');
for x:=0 to Nr-1 do begin
 write(f,EV[x,1],' ');
 write(f,EV[x,2],' ');
 end;
end;

Procedure Tmmin.getY(w : double;var Y : cmat);
begin
//writeln(name,': MMin getY');
if (calcw<>w) and updateA then begin;recalc(w);end;
end;

function tMmin.calcMmin(eig : boolean;w : double) : double;
var
 x,y,wie : integer;
 res,validEig : boolean;
 Emin : double;
 Ep : tc;
{ aa,bb : cvec; 
 cc : cmat;
 MM2 : tmat;
 z : double;}
begin
if (w=calcw) then begin
  calcMmin:=4*min;
  end;
for x:=0 to Nr-1 do Vres[x]:=sqrt(PGain(RS[x])^.ri);
for x:=0 to Nr-1 do Vs[x]:=Vs[x]/Vres[x];
for x:=0 to Nr-1 do
 for y:=0 to Nr-1 do MC[x,y]:=MC[x,y]/Vres[x]/Vres[y];
{//test
cmsetsize(Nr,Nr,cc);
for x:=0 to Nr-1 do for y:=0 to Nr-1 do cc[x,y]:=MC[x,y];
//**}

//for x:=0 to Nr-1 do writeln(Vres[x]);
for x:=0 to Nr-1 do
 for y:=0 to Nr-1 do
  MS[x,y]:=Vs[x]*ccomp(VS[y]);
for x:=0 to Nr-1 do MS[x,x]:=MS[x,x]-1;
{
for x:=0 to Nr-1 do
 for y:=0 to Nr-1 do
  MC[x,y]:=MC[x,y]*4;
}
{
writeln('MC');
CMwriteE(Nr,Nr,MC);
writeln('MS');
CMwriteE(Nr,Nr,MS);
writeln('Elim...');
}
CMelim(Nr,MS,0,Nr-1,MC,Nr);
{writeln('ME');
CMwriteE(Nr,Nr,MC);
writeln('Eigen...');
}


for x:=0 to Nr-1 do for y:=0 to Nr-1 do begin
 MM[x*2,y*2  ]:= MC[y,x,1];
 MM[x*2,y*2+1]:=-MC[y,x,2];
 MM[x*2+1,y*2  ]:= MC[y,x,2];
 MM[x*2+1,y*2+1]:= MC[y,x,1];
 end;
{//test
RMsetsize(N2,N2,MM2);
for x:=0 to N2-1 do for y:=0 to N2-1 do MM2[x,y]:=MM[x,y];
eig:=true;
//}
{writeln('MM');
RMwriteE(N2,N2,MM);}
if eig then res:=RMatrixEVD(MM,N2,1,WR,WI,VL,VR)
       else res:=RMatrixEVD(MM,N2,0,WR,WI,VL,VR);
if not(res) then writeln('Not converse!!!');
min:=1e9;wie:=-1;
for x:=0 to N2-1 do if (WR[x]>0) and (WR[x]<min) then begin
   min:=WR[x];
   wie:=x;
  end;
numeig:=0;
for x:=0 to N2-1 do if (WR[x]>0) and (abs(WR[x]/min-1)<0.5) then inc(numeig);  
if eig then begin
 if wie<0 then for x:=0 to Nr-1 do EV[x]:=czero else
   for x:=0 to Nr-1 do EV[x]:=r2c(VR[2*x,wie],VR[2*x+1,wie]);
//  writeln('S=',cabs2(Ep));
//  Emin:=sqrt(cabs2(Ep))/1000;
  signal:=czero;
  for x:=0 to Nr-1 do signal:=signal+2/sqrt(Nr)*EV[x]*(Vs[x]);
  //Normalise
//  Emin:=cabs2(signal)/10000;
//  if norm>0 then Emin:=Emin*norm/10000;
//  EP:=EV[0]*sqrt(Emin/cabs2(EV[0]));
  EP:=signal/Nsignal;
{  if Ftemp>0 then begin
    Emin:=cabs2(EV[0]);
    for x:=1 to Nr-1 do if cabs2(EV[x])>Emin then Emin:=cabs2(EV[x]);
    Ep:=r2c(sqrt(Emin)/Nsignal,0);
    end;}
  EP:=EP*expi(NPhase+Ndelay*w+Ndesp*w*w);
  if (EP[1]<>0) or (EP[2]<>0) then begin
   for x:=Nr-1 downto 0 do EV[x]:=EV[x]/EP;
   for x:=0 to Nr-1 do signals[x]:=2/sqrt(Nr)*EV[x]*(Vs[x]);
   signal:=signal/sqrt(cabs2(EP));
   end;
 end;
//for x:=0 to N2-1 do writeln('E',x,'=',WR[x]:0:2);
{writeln('Eigen val');
for x:=0 to N2-1 do write(WR[x]:5:0);}
//writeln('Eigen val I');
//for x:=0 to N2-1 do write(WI[x]:5:0);
{if eig then begin 
 writeln('Eigen vec');
 RMwrite(N2,N2,VR);
 end;}
{writeln('Best w=',w);
for x:=0 to Nr-1 do Cwrite(EV[x]);

//test

writeln('Solution??');
setlength(aa,Nr);
setlength(bb,Nr);
for x:=0 to Nr-1 do
 for y:=0 to Nr-1 do
  MS[x,y]:=Vs[x]*ccomp(VS[y]);
for x:=0 to Nr-1 do MS[x,x]:=MS[x,x]-1;

for x:=0 to Nr-1 do aa[x]:=czero;
for x:=0 to Nr-1 do bb[x]:=czero;
for x:=0 to Nr-1 do 
 for y:=0 to Nr-1 do
   aa[x]:=aa[x]+EV[y]*CC[y,x];
for x:=0 to Nr-1 do 
 for y:=0 to Nr-1 do
   bb[x]:=bb[x]+EV[y]*MS[y,x]*min;
   
for x:=Nr-1 downto 0 do aa[x]:=aa[x]/aa[0];
for x:=Nr-1 downto 0 do bb[x]:=bb[x]/bb[0];
   
for x:=0 to Nr-1 do cwriteEng(aa[x]);writeln;   
for x:=0 to Nr-1 do cwriteEng(bb[x]);writeln;   

writeln('Test eigenvector');
for x:=0 to N2-1 do begin
 z:=0;
 for y:=0 to N2-1 do z:=z+VR[y,w]*MM2[x,y];
 writeEng(z);
 end;
writeln;
for y:=0 to N2-1 do writeEng(VR[y,w]*WR[w]);
writeln; 
//end test

}
if eig then calcw:=w else calcw:=-1;
calcMmin:=4*min;
end;

procedure Tmmin.doUpdate(w : double;V0,Z0 : cvec;cnt : integer);
var
 t2 : double;
 y  : integer;
begin
//if not(updateA) then exit;
//writeln('UD');
// writeln(name,': MMin getY');
 getInput(V0,Z0);
 t2:=calcMmin(true,w);
 for y:=0 to nr-1 do if RS[y]<>nil then PGain(RS[y])^.setA(w,EV[y]);
end;


function TMmin.loads(ss : tstrings) : boolean;
var
 x : integer;
begin
writeln('Mmin loads...');
Nr:=len(ss)-1;
//writeln(NR);
CMsetsize(Nr,Nr,MC);
CMsetsize(Nr,Nr,MS);
setlength(Rs,NR);
setlength(Nds,Nr);
setlength(RNds,Nr);
setlength(VS,NR);
setlength(EV,NR);
setlength(Vres,NR);
setlength(signals,NR);
N2:=2*Nr;
Ftemp:=0;Utemp:=0;
RMsetsize(N2,N2,MM);
RMsetsize(N2,N2,VL);
RMsetsize(N2,N2,VR);
setlength(WR,N2);
setlength(WI,N2);
Ndelay:=0;
Ndesp:=0;
Nphase:=0;
calcw:=-1;
Nsignal:=1000;
writeln('Loading ',nr,' ports');
//for x:=1 to NR do writeln(x,' ',ss[x+1]);
for x:=1 to NR do RS[x-1]:=psport(Parent)^.findcomp(ss[x+1]);
for x:=0 to NR-1 do if RS[x]<>nil then nds[x]:=RS[x]^.node[1];
for x:=0 to NR-1 do if RS[x]<>nil then rnds[x]:=RS[x]^.node[0];
loads:=true;
end;


function Tmmin.paramnum(s : string) : integer;
begin
if uppercase(s)='LOAD' then paramnum:=1 else 
if uppercase(s)='DELAY' then paramnum:=2 else
if uppercase(s)='DISPERSE' then paramnum:=3 else
if uppercase(s)='NSIGNAL' then paramnum:=6 else
if uppercase(s)='FTEMP' then paramnum:=4 else 
if uppercase(s)='UTEMP' then paramnum:=5 else
if uppercase(s)='UPDATE' then paramnum:=7 else paramnum:=0;
end;
function Tmmin.paramdouble(wat : integer) : boolean;
begin
 paramdouble:=wat<>1;
end;
Procedure Tmmin.setD(z : double;wat : integer);
begin
case wat of
 2 : Ndelay:=z;
 3 : Ndesp:=z;
 4 : Ftemp:=z;
 5 : Utemp:=z;
 6 : Nsignal:=z;
 7 : begin;updateA:=round(z)<>0;if updateA then writeln(name,' update A (recalc)') else writeln(name, ' no update');end;
 end;
end;
function Tmmin.paramstr(wat : integer) : string;
begin 
case wat of 
 6 : paramstr:='NSIGNAL';
 end;
end;
function Tmmin.getD(wat : integer) : double;
begin
case wat of 
 6 : getD:=Nsignal;
 else getD:=0;
 end;
end;

Procedure Tmmin.setD2(s : string;wat : integer);
var
 freq : tvec;
 data : cmat;
 N,x,y,l : integer;
 s2 : string;
 ss : Tstrings;
 f : text;
begin
if wat<>1 then exit;
//writeln('load file="',s,'"');
assign(f,s);
reset(f);
x:=0;
setlength(data,nr);
N:=40;
setlength(freq,N);
for y:=0 to nr-1 do setlength(data[y],N);

while not(eof(f)) do begin
 readln(f,s2);
 ss:=strtostrs(s2);
 l:=len(ss);
// writeln('l=',l,' s=',s2);
 if l>=2*nr+1 then begin
  inc(x);
  if x>N then begin
    N:=N+20;
    setlength(freq,N);
    for y:=0 to nr-1 do setlength(data[y],N);
    end;
  freq[x-1]:=strtofloat(ss[1])*twopi;
//  writeln('freq=',freq[x-1]);
  for y:=0 to nr-1 do begin
    data[y,x-1]:=r2c(strtofloat(ss[y*2+2]),strtofloat(ss[y*2+3]));
    end;
  end; // if l
{  else begin
   for y:=1 to l do write(ss[y],'; ');
   writeln;
   end;}
end; //while
//cmwriteE(nr,x,data);
if x>0 then
 for y:=0 to nr-1 do if RS[y]<>nil then PGain(RS[y])^.loadA(x,freq,data[y],-1);
close(f);
end;
function Tmmin.getOutputx(w : double;V0,Z0 : cvec) : tc;
var
 x,y : integer;
 t : double;
 Sp : Psport;
 a : array of Tc;
 b,d : tc;
 Max : double;
begin
Max:=cabs2(Ev[0]);
for x:=1 to Nr-1 do if cabs2(Ev[x])>max then max:=cabs2(Ev[x]);
if Max<1 then Max:=1;
//solveMmin:=0;
Sp:=Psport(parent);
if Sp=nil then exit;
//writeln('solveMmin');
with sp^ do
 if Pin.C<>nil then with pin do begin;t:=C^.getD(wat);end else t:=noiseres;
t:=sqrt(t);
setlength(a,nr);
 for x:=0 to NR-1 do a[x]:=r2c(sp^.solveN(nds[x],rnds[x],V0,Z0),0)*Ev[x]/Vres[x];
 for x:=0 to NR-1 do
  for y:=x+1 to NR-1 do begin
    b:=sp^.solveNC2(nds[x],nds[y],rnds[x],rnds[y],V0,Z0);
    b:=ccomp(b);
    a[x]:=a[x]+b       *Ev[y]/Vres[y];
    a[y]:=a[y]+ccomp(b)*Ev[x]/Vres[x];
    end;
d:=czero;
for x:=0 to Nr-1 do d:=d+a[x]*ccomp(Ev[x])/Vres[x];
for x:=0 to Nr-1 do d:=d+Ftemp*(Max-cabs2(Ev[x]))/4;
d:=d+Utemp*Max/4;
 b:=czero;
 for x:=0 to NR-1 do b:=b+Ev[x]*(sp^.solveS(nds[x],V0)-sp^.solveS(rnds[x],V0))*t/Vres[x];
 b[1]:=cabs2(b);
// for x:=0 to NR-1 do b[1]:=b[1]-cabs2(Ev[x]);
 b[1]:=b[1]-Nr*Max;
// writeln('N=',d[1],' ',d[2],' S=',b[1]);
getOutputx:=4*d/b[1];
end;

Procedure Tmmin.getInput(V0,Z0 : cvec);
var
 SP : Psport;
 x,y : integer;
 t : double;
begin
Sp:=Psport(parent);
if Sp=nil then exit;
with sp^ do
 if Pin.C<>nil then with pin do begin;t:=C^.getD(wat);end else t:=noiseres;
t:=sqrt(t);
 for x:=0 to NR-1 do MC[x,x]:=r2c(sp^.solveN(nds[x],rnds[x],V0,Z0),0);
 for x:=0 to NR-1 do VS[x]:=(sp^.solveS(nds[x],V0)-sp^.solveS(rnds[x],V0))*t;
//Normalised phase (for testing)
 
//
 for x:=0 to NR-1 do
  for y:=x+1 to NR-1 do begin
    MC[x,y]:=sp^.solveNC2(nds[x],nds[y],rnds[x],rnds[y],V0,Z0);
    MC[y,x]:=ccomp(MC[x,y]);
    end;
//writeln('Noise matrix:');
//CMwriteE(Nr,Nr,MC);
//writeln('Signal matrix:');
//CVwrite(NR,VS);
//writeln('V0:');
//CVwrite(5,V0);
//   n1:=nds[x];
//   C[0,0]:-

end;

function Tmmin.getOutput(w : double;V0,Z0 : cvec;wat : integer) : tc;
var
 x,y : integer;
 t,t2 : double;
 Sp : Psport;
begin
//solveMmin:=0;
Sp:=Psport(parent);
if Sp=nil then exit;
//writeln('solveMmin');

if wat=200 then begin 
  t2:=0;
  for x:=0 to Nr-1 do t2:=t2+(cabs2(sp^.solveS(nds[x],V0)-sp^.solveS(rnds[x],V0))/PGain(RS[x])^.ri);
  getoutput:=r2c(sqrt(t2*t),0);
  exit;
 end else if wat>200 then begin
  getoutput:=r2c(sqrt(cabs2(sp^.solveS(nds[wat-201],V0)-sp^.solveS(rnds[wat-201],V0))*t/PGain(RS[wat-201])^.ri),0);
  exit;
 end;

getInput(V0,Z0);
 
t2:=calcMmin(wat>=0,w);
if Ftemp>0 then t2:=getOutputx(w,V0,Z0)[1];
case wat of
 0  : GetOutput:=r2c(t2,0);
 -1 : getOutput:=signal/2;
 -100 : getOutput:=r2c(numeig,0);
 else
 if wat>100 then getoutput:=signals[wat-101] else
      getOutput:=EV[wat-1];
end;

end;

function Tratio.loads(ss : tstrings) : boolean;
var
 x : integer;
begin
 RN:=(len(ss)-1) div 2;
 if RN<3 then begin;writeln('Ratio need 6 or more resistors!');halt(1);end;
 setlength(Ra,RN);
 setlength(Rb,RN);
 for x:=1 to RN do begin
   RA[x-1]:=psport(Parent)^.findcomp(ss[2*x]);
   if (RA[x-1]=nil) or (RA[x-1]^.tiepe<>'R') then begin;writeln('Ratio: ',ss[2*x],' not a resistor!');halt(1);end;
   if x>1 then with Pres(RA[x-1])^ do if (nnoise<1) or (tmp<=0) then begin;writeln('Ratio: ',ss[2*x],' need temp>0');halt(1);end;
   RB[x-1]:=psport(Parent)^.findcomp(ss[2*x+1]);
   if (RB[x-1]=nil) or (RB[x-1]^.tiepe<>'R') then begin;writeln('Ratio: ',ss[2*x+1],' not a resistor!');halt(1);end;
   if x>1 then with Pres(RB[x-1])^ do if (nnoise<1) or (tmp<=0) then begin;writeln('Ratio: ',ss[2*x+1],' need temp>0');halt(1);end;
 end;
loads:=true;
end;

function Tratio.getVolt(RR,R2 : Pcomp) : tc;
var
 z : tc;
begin
z:=psport(parent)^.SN[Pres(RR)^.noiseI,Pres(R2)^.node[1]]-psport(parent)^.SN[Pres(RR)^.noiseI,Pres(R2)^.node[0]];
if cabs2(z)<1e-10 then z:=r2c(1e-10,0);
getVolt:=z;
end;

function Tratio.getOutput(w : double;V0,Z0 : cvec;wat : integer) : tc;
var
 a1,a2 : integer;
 z : tc;
begin
if wat<0 then begin
  a1:=(-wat) div 2;
  a2:=(-wat) mod 2;
  if a1<1 then a1:=1;
  if a1>RN then a1:=RN;
  if a2=0 then getOutput:=getVolt(RA[a1],RA[0]) 
          else getOutput:=getVolt(RB[a1],RB[0]); 
  exit;
  end;
if wat>=800 then begin
  wat:=wat-800;
  if wat<2 then wat:=2;
  if wat>RN then wat:=RN;
  getOutput:=(getvolt(RB[wat],RB[0]))/(getvolt(RB[wat-1],RB[0]));
  exit;
  end;
if wat>=700 then begin
  wat:=wat-700;
  if wat<2 then wat:=2;
  if wat>RN then wat:=RN;
  getOutput:=(getvolt(RA[wat],RA[0]))/(getvolt(RA[wat-1],RA[0]));
  exit;
  end;
if wat>=600 then begin
  wat:=wat-600;
  if wat<1 then wat:=1;
  if wat>RN then wat:=RN;
  getOutput:=(getvolt(RB[wat],RB[0]))/(getvolt(RB[1],RB[0]));
  exit;
  end;
if wat>=500 then begin
  wat:=wat-500;
  if wat<1 then wat:=1;
  if wat>RN then wat:=RN;
  getOutput:=(getvolt(RA[wat],RA[0]))/(getvolt(RA[1],RA[0]));
  exit;
  end;
if wat>=400 then begin
  wat:=wat-400;
  if wat<1 then wat:=1;
  if wat>RN then wat:=RN;
  getOutput:=r2c(sqrt(cabs2(getvolt(RA[wat],RA[0])))-sqrt(cabs2(getvolt(RB[wat],RB[0]))),0);
  exit;
  end;
if wat>=300 then begin
  wat:=wat-300;
  if wat<1 then wat:=1;
  if wat>RN then wat:=RN;
  getOutput:=getvolt(RA[wat],RA[0])-getvolt(RB[wat],RB[0]);
  exit;
  end;
if wat>=200 then begin
  wat:=wat-200;
  if wat<1 then wat:=1;
  if wat>RN then wat:=RN;
  getOutput:=r2c(sqrt(cabs2(getvolt(RA[wat],RA[0]))/cabs2(getvolt(RB[wat],RB[0])))-1,0);
  exit;
  end;
if wat>=100 then begin
  wat:=wat-100;
  if wat<1 then wat:=1;
  if wat>RN then wat:=RN;
  getOutput:=getvolt(RA[wat],RA[0])/getvolt(RB[wat],RB[0])-1;
  exit;
  end;
if wat=0 then begin;a1:=1;a2:=2;end else begin
 a1:=wat div 2;
 a2:=wat mod 2;
 a1:=a1+2;
 if a2=0 then a2:=1 else a2:=a1+1;
// writeln('a1=',a1,' a2=',a2);
 end;
// writeln;
//write('Getvolt A',a1,'-0 = ');cwriteEng(getVolt(RA[a1],RA[0]));writeln;
//write('Getvolt A',a2,'-0 = ');cwriteEng(getVolt(RA[a2],RA[0]));writeln;
//write('Getvolt B',a1,'-0 = ');cwriteEng(getVolt(RB[a1],RB[0]));writeln;
//write('Getvolt B',a2,'-0 = ');cwriteEng(getVolt(RB[a2],RB[0]));writeln;

//getOutput:=getVolt(RA[a1],RA[0])/getVolt(RA[a2],RA[0])-getVolt(RB[a1],RB[0])/getVolt(RB[a2],RB[0]);
//z:=1-getVolt(RA[a1],RA[0])*getVolt(RB[a2],RB[0])/(getVolt(RA[a2],RA[0])*getVolt(RB[a1],RB[0]));
z:=(getVolt(RA[a1],RA[0])*getVolt(RB[a2],Rb[0])-(getVolt(RA[a2],RA[0])*getVolt(RB[a1],RB[0]))) * sqrt(sqrt( cabs2(getVolt(RA[a1],RA[0]))*cabs2(getVolt(RA[a2],RA[0]))/cabs2(getVolt(RB[a1],RB[0]))/cabs2(getVolt(RB[a2],RB[0]))   ));
//write('Z=');cwriteEng(z);writeln;
getOutput:=z;
end;


function P2Mmin(Y1,Y2,Y3,Y4,N1,N2,N3,N4 : tc) : double;
var
 C,B : array[1..4] of tc;
 xa,xb,xc,x1,x2 : tc;
begin
C[1]:=r2c(cabs2(N1)+cabs2(N3),0);
C[4]:=r2c(cabs2(N2)+cabs2(N4),0);
C[3]:=( N1*ccomp(N2)+N3*ccomp(N4) ); 
C[2]:=ccomp(C[3]); 
B[1]:=-2*( Y1+ccomp(Y1) );
B[2]:=-2*( Y2+ccomp(Y3) );
B[3]:=-2*( Y3+ccomp(Y2) );
B[4]:=-2*( Y4+ccomp(Y4) );
xa:=B[1]*B[4]-B[2]*B[3];
xb:=-( c[1]*b[4]+c[4]*b[1] - c[2]*b[3]-c[3]*b[2]  );
xc:=c[1]*c[4]-c[2]*c[3];

x1:=(-xb+csqrt(xb*xb-4*xa*xc) ) / xa / 2;
x2:=(-xb-csqrt(xb*xb-4*xa*xc) ) / xa / 2;
P2Mmin:=X2[1]/k4*4;
//writeln('T1=',-C[1,1]/B[1,1]*4:10:2);
{yy[1]:=(C[3]-x2[1]*B[3]);
yy[2]:=-(C[1]-x2[1]*B[1]);

xa:=ccomp(yy[2]/yy[1]);
Zs:=xa;}
end;

function P2MminY(Y1,Y2,Y3,Y4,N1,N2,N3,N4 : tc) : tc;
var
 C,B : array[1..4] of tc;
 xa,xb,xc,x1,x2 : tc;
 YY : array[1..2] of tc;
begin
C[1]:=r2c(cabs2(N1)+cabs2(N3),0);
C[4]:=r2c(cabs2(N2)+cabs2(N4),0);
C[3]:=( N1*ccomp(N2)+N3*ccomp(N4) ); 
C[2]:=ccomp(C[3]); 
B[1]:=-2*( Y1+ccomp(Y1) );
B[2]:=-2*( Y2+ccomp(Y3) );
B[3]:=-2*( Y3+ccomp(Y2) );
B[4]:=-2*( Y4+ccomp(Y4) );
xa:=B[1]*B[4]-B[2]*B[3];
xb:=-( c[1]*b[4]+c[4]*b[1] - c[2]*b[3]-c[3]*b[2]  );
xc:=c[1]*c[4]-c[2]*c[3];

x1:=(-xb+csqrt(xb*xb-4*xa*xc) ) / xa / 2;
x2:=(-xb-csqrt(xb*xb-4*xa*xc) ) / xa / 2;
//P2Mmin:=X2[1]/k4*4;
//writeln('T1=',-C[1,1]/B[1,1]*4:10:2);
yy[1]:=(C[3]-x2[1]*B[3]);
yy[2]:=(C[1]-x2[1]*B[1]);
P2MminY:=ccomp(yy[2]/yy[1])*Y2-Y1;
//Zs:=xa;}
end;

function P2MminA(Y1,Y2,Y3,Y4,N1,N2,N3,N4 : tc) : double;
var
 C,B : array[1..4] of tc;
 yy : array[1..2] of tc;
 xa,xb,xc,x1,x2 : tc;
 A : double;
begin
C[1]:=r2c(cabs2(N1)+cabs2(N3),0);
C[4]:=r2c(cabs2(N2)+cabs2(N4),0);
C[3]:=( N1*ccomp(N2)+N3*ccomp(N4) ); 
C[2]:=ccomp(C[3]); 
B[1]:=-2*( Y1+ccomp(Y1) );
B[2]:=-2*( Y2+ccomp(Y3) );
B[3]:=-2*( Y3+ccomp(Y2) );
B[4]:=-2*( Y4+ccomp(Y4) );
xa:=B[1]*B[4]-B[2]*B[3];
xb:=-( c[1]*b[4]+c[4]*b[1] - c[2]*b[3]-c[3]*b[2]  );
xc:=c[1]*c[4]-c[2]*c[3];

x1:=(-xb+csqrt(xb*xb-4*xa*xc) ) / xa / 2;
x2:=(-xb-csqrt(xb*xb-4*xa*xc) ) / xa / 2;
//P2Mmin:=X2[1]/k4*4;
//writeln('T1=',-C[1,1]/B[1,1]*4:10:2);
yy[1]:=(C[3]-x2[1]*B[3]);
yy[2]:=-(C[1]-x2[1]*B[1]);//cheched


x1:=ccomp(Y2*yy[1])*yy[2];
x2:=Y3*ccomp(yy[1])*yy[2];
A:=   (2*Y1[1]*cabs2(yy[1])+2*x1[1]);
A:=-A/(2*Y4[1]*cabs2(yy[2])+2*x2[1]);
P2MminA:=A;


{xa:=-ccomp(yy[2]/yy[1])*Y2-Y1;  //Ys - checked
xc:=xa+Y1; //Y1
xb:=Y4-Y2*Y3/xc; //Yout
xb:=ccomp(xb); //Yl opt - checked

P2MminA:=cabs2(Y2)/cabs2(xc)*xa[1]/xb[1];
xa:=1/xa; 
cwriteEng(xa);
}
//Zs:=xa;}
end;

function P2Mmin(YY,NI : tc4) : double;
var
// NI : array[1..4] of tc;
 C,B : array[1..4] of tc;
// yy : array[1..2] of tc;
// x : integer;
 xa,xb,xc,x1,x2 : tc;
// Yopt,Ycor : tc;
// gn,rn : double;
// Fmin,A : tc;
begin
C[1]:=r2c(cabs2(NI[1])+cabs2(NI[3]),0);
C[4]:=r2c(cabs2(NI[2])+cabs2(NI[4]),0);
C[3]:=( NI[1]*ccomp(NI[2])+NI[3]*ccomp(NI[4]) ); 
C[2]:=ccomp(C[3]); 
B[1]:=-2*( YY[1]+ccomp(YY[1]) );
B[2]:=-2*( YY[2]+ccomp(YY[3]) );
B[3]:=-2*( YY[3]+ccomp(YY[2]) );
B[4]:=-2*( YY[4]+ccomp(YY[4]) );
xa:=B[1]*B[4]-B[2]*B[3];
xb:=-( c[1]*b[4]+c[4]*b[1] - c[2]*b[3]-c[3]*b[2]  );
xc:=c[1]*c[4]-c[2]*c[3];

x1:=(-xb+csqrt(xb*xb-4*xa*xc) ) / xa / 2;
x2:=(-xb-csqrt(xb*xb-4*xa*xc) ) / xa / 2;
P2Mmin:=X2[1]/k4*4;
//writeln('T1=',-C[1,1]/B[1,1]*4:10:2);
{yy[1]:=(C[3]-x2[1]*B[3]);
yy[2]:=-(C[1]-x2[1]*B[1]);

xa:=ccomp(yy[2]/yy[1]);
Zs:=xa;}
end;




end.
