unit tline_t; 
interface
uses vectorD,complex2,FET,consts,stringe,compu,savedata,varu;

type
   
TtlineT = object(Tcomp)
   z1,z2,sk,tand,alpha,rm,temp,len,toll : double;
   taper : integer;
   YY,NN : cmat;
   Save : Tsave;
//   G_m,C_m,L_m,R_m  : double; 
   constructor create(P : pointer); 
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
//   Procedure getdY(w : double;v0 : cvec;var Y : cvec;wat : integer); virtual;
   Procedure load(Np1 : integer;P : Tparams); virtual;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   end; 

   
   
 PtlineT = ^TtlineT;

implementation
uses sysutils,sport,math;


constructor ttlineT.create(P : pointer);
begin inherited create(P);Nnode:=3; end;

Procedure TtlineT.load(Np1 : integer;P : Tparams);
begin
 Z1   :=getparm(Np1,P,'Z0',50);
 Z2   :=getparm(Np1,P,'Z2',Z1);
 Z1   :=getparm(Np1,P,'Z1',Z1);
 sk    :=getparm(Np1,P,'K',4);
 sk:=sqrt(sk);
 len  :=getparm(Np1,P,'LEN',1e-3);
 tand :=getparm(Np1,P,'TAND',0.0);
 alpha:=getparm(Np1,P,'ALPHA',0.0);
 rm:=getparm(Np1,P,'R_M',0.0);
// fopt :=getparm(Np,P,'fopt',1e9);
 temp :=getparm(Np1,P,'TEMP',0);
 toll :=getparm(Np1,P,'TOLL',3e-2);
 taper :=round(getparm(Np1,P,'TAPER',3));
 alpha:=alpha*0.11512926; //db/m to nepers/m
 alpha:=alpha/sqrt(1e9*twopi); //alpha given for 1GHz
 rm:=rm/sqrt(1e9*twopi);
 if ((tand=0) and (alpha=0) and (rm=0)) or (temp=0) then Nnoise:=0 else Nnoise:=2;
 Nnoise:=0;
// calcLCR;
 Save.init(2,nnoise-1);
 CMsetsize(2,2,YY);
 CMsetsize(nnoise,nnoise,NN);
end;

Procedure TtlineT.getY(w : double;var Y : cmat);
var  
c_1,l_1,r_1,g_1 : double;
c_2,l_2,r_2,g_2 : double;
s,s2,a2: double;
MA,MB : array[0..1,0..1] of tc;
x : integer;
N : longint;
Zx,Yx,YZ1,YZ2,ZZ1,ZZ2,a1 : tc;
begin

if save.getsaved(w,YY,NN) then begin
// Y11:=YY[0,0];
// Y12:=YY[0,1];
 end else begin
// writeln(name,' ',w,' ',Z1,' ',Z2);
 c_1:=sk/(Z1*c0);
 l_1:=(z1*z1)*c_1;
if alpha<>0 then  r_1:=alpha*Z1*sqrt(w)
{ else if rm<>0 then r_1:=rm*sqrt(w)} else r_1:=0;
 g_1:=tand*(w*c_1);
 
 c_2:=sk/(Z2*c0);
 l_2:=(z2*z2)*c_2;
if alpha<>0 then  r_2:=r_1/Z1*Z2
{else if rm<>0 then r_2:=r_1} else r_2:=0;
 g_2:=tand*(w*c_2);
 


 MA[0,0]:=r2c(1,0);
 MA[1,1]:=MA[0,0];
 MA[1,0]:=czero;MA[0,1]:=czero;
// d0:=len/N; 
// s:=sqrt(sqrt(cabs2(z1)/cabs2(y1)));
 s:=(l_2/c_1);
 s2:=(l_1/c_2);
 if s2>s then begin
   s:=sqrt(s2);
   s2:=w*c_2*s*len;
   end else begin
   s:=sqrt(s);
   s2:=w*c_1*s*len;
   end;
// writeln(s,' ',sqrt(l_m/c_m));
// s2:=sqrt(cabs2(y1))*s;
// s2:=w*c_m*s*len;
 N:=round(s2/toll);
 if N<1 then N:=1;
// write(w,' ',s2/toll,' ',N);
 YZ1:=r2c(g_1,w*C_1)*len*s/(N+1);
 ZZ1:=r2c(r_1,w*L_1)*len/s/(N+1);
 YZ2:=r2c(g_2,w*C_2)*len*s/(N+1);
 ZZ2:=r2c(r_2,w*L_2)*len/s/(N+1);
// writeln(sqrt(cabs2(yZ1)),' ',sqrt(cabs2(ZZ1)),' ',sqrt(cabs2(yZ2)),' ',sqrt(cabs2(zz2)),' ');
case taper of
 1 : begin //linear first order
 YZ1:=cinv(YZ1);
 YZ2:=cinv(YZ2);
 for x:=0 to N do begin
 Yx:=cinv( YZ1*(1-x/N)+YZ2*(x/N) );
 Zx:=ZZ1*(1-x/N)+ZZ2*(x/N);
  MB[0,0]:=MA[0,0]+MA[0,1]*Yx;
  MB[1,0]:=MA[1,0]+MA[1,1]*Yx;
  MA[0,1]:=MA[0,1]+MA[0,0]*Zx;
  MA[1,1]:=MA[1,1]+MA[1,0]*Zx;
  MA[0,0]:=MB[0,0];
  MA[1,0]:=MB[1,0];
 end; end;//1
 2 : begin //linear second order
 YZ1:=cinv(YZ1);
 YZ2:=cinv(YZ2);
 for x:=0 to N do begin
 Yx:=cinv( YZ1*(1-x/N)+YZ2*(x/N) );
 Zx:=ZZ1*(1-x/N)+ZZ2*(x/N);
  a1:=1+Yx*Zx/2;
  MB[0,0]:=MA[0,0]*a1+MA[0,1]*Yx;
  MB[1,0]:=MA[1,0]*a1+MA[1,1]*Yx;
  MA[0,1]:=MA[0,1]*a1+MA[0,0]*Zx;
  MA[1,1]:=MA[1,1]*a1+MA[1,0]*Zx;
  MA[0,0]:=MB[0,0];
  MA[1,0]:=MB[1,0];
 end; end;//2
 3 : begin //exponential;
 //Yx = k/C * (tand*w,1) * 1/Z0
 //Zx = (alpha*sqr(w),k/c) * Z0
 //Z0 = Z1.a^x met a=exp( ln(Z2/Z1) /N)
 a2:=exp( ln(Z2/Z1) / N );
// a2:=power(Z2/Z1,1/N);
 Yx:=YZ1;Zx:=ZZ1;
 a1:=1+Yx*Zx/2;
// write('S ',a2,' ',sqrt(cabs2(Yx)));
 for x:=0 to N do begin
  MB[0,0]:=MA[0,0]*a1+MA[0,1]*Yx;
  MB[1,0]:=MA[1,0]*a1+MA[1,1]*Yx;
  MA[0,1]:=MA[0,1]*a1+MA[0,0]*Zx;
  MA[1,1]:=MA[1,1]*a1+MA[1,0]*Zx;
  MA[0,0]:=MB[0,0];
  MA[1,0]:=MB[1,0];
  Yx:=Yx/a2;
  Zx:=Zx*a2;
 end; end;//3
 else begin;write('Taper=',taper,' not implemented!!');halt(1);end;
end;
 
{ writeln;
cwriteEng(MA[0,0]);
cwriteEng(MA[0,1]);writeln;
cwriteEng(MA[1,0]);
cwriteEng(MA[1,1]);writeln;}

//write('S ');
//cwriteEng(Ma[0,1]);
if cabs2(Ma[0,1])<1e-10 then MA[0,1]:=r2c(1e+99,0)
                       else MA[0,1]:=cinv(MA[0,1]);
 s:=1/s;
 YY[0,0]:=s*(MA[1,1]*MA[0,1]);
 YY[0,1]:=s*(MA[1,0]-MA[0,0]*MA[1,1]*MA[0,1]);
 YY[1,0]:=s*(-MA[0,1]);
 YY[1,1]:=s*(MA[0,0]*MA[0,1]);

// writeln;
{ writeln;
cwriteEng(YY[0,0]);
cwriteEng(YY[0,1]);writeln;
cwriteEng(YY[1,0]);
cwriteEng(YY[1,1]);writeln;}
 save.savedata(w,YY,YY); 
//writeln('Done');
end;
//cwrite(YY[0,0]);
//cwrite(YY[0,1]);


addblk(Y,node[0],node[0],node[1],node[1],YY[0,0]);
addblk(Y,node[0],node[0],node[1],node[2],YY[0,1]);
addblk(Y,node[0],node[0],node[2],node[1],YY[1,0]);
addblk(Y,node[0],node[0],node[2],node[2],YY[1,1]);
end;

Procedure TtlineT.getN(w : double;var N : cmat);
begin
{if not(save.getsaved(w,YY,NN)) then begin
  writeln('Tline Noise data not saved!!');
  halt(1);
  end;
//writeln('i0=',NN[0,0,1],' i1=',NN[1,1,1]);
//writeln('i0=',NN[0,0,1],' i1=',NN[1,1,1],' C=',NN[0,1,1]);
caddr(N[noiseI  ,node[1]],NN[0,0,1]);
caddr(N[noiseI  ,node[0]],-NN[0,0,1]);
caddr(N[noiseI  ,node[2]],NN[0,1,1]);
caddr(N[noiseI  ,node[0]],-NN[0,1,1]);
//cadd(N[noiseI+1,node[1]],0);
//cadd(N[noiseI+1,node[0]],-0);
caddr(N[noiseI+1,node[2]],NN[1,1,1]);
caddr(N[noiseI+1,node[0]],-NN[1,1,1]);
}
end;


function TtlineT.paramnum(s : string) : integer;
  begin 
  s:=uppercase(s);
   if s='Z1' then paramnum:=1 else 
   if s='Z2' then paramnum:=2 else 
   if s='Z0' then paramnum:=6 else 
   if s='LEN' then paramnum:=3 else
   if s='K' then paramnum:=4 else
   if s='R_M' then paramnum:=5 else
    paramnum:=0;
  end;
function TtlineT.paramstr(wat : integer) : string; 
begin
 case wat of 
 1 : paramstr:='Z1';
 2 : paramstr:='Z2';
 3 : paramstr:='LEN';
 4 : paramstr:='K';
 5 : paramstr:='R_M';
 6 : paramstr:='Z0';
 else paramstr:='';
 end;
end;

function TtlineT.getD(wat : integer) : double; 
   begin 
   case wat of
    1 : getD:=Z1;
    2 : getD:=Z2;
    3 : getD:=LEN;
    4 : getD:=sk*sk;
    5 : getD:=RM*sqrt(1e9*twopi);
    6 : getD:=Z1;
     end;
    end;
Procedure TtlineT.setD(z : double;wat : integer);
var
 diff : boolean;
 begin 
 diff:=false;
   case wat of
    1 : if Z1<>abs(z) then begin;Z1:=abs(z);diff:=true;end;
    2 : if Z2<>abs(z) then begin;Z2:=abs(z);diff:=true;end;
    3 : if len<>abs(z) then begin;len:=abs(z);diff:=true;end;
    4 : if sk*sk<>abs(z) then begin;sk:=sqrt(abs(z));diff:=true;end;
    5 : if rm*sqrt(1e9*twopi)<>abs(z) then begin;rm:=abs(z)/sqrt(1e9*twopi);diff:=true;end;
    6 : if (Z1<>abs(z)) or (Z2<>Z1) then begin;Z1:=abs(z);Z2:=Z1;diff:=true;end;
    end;
 if diff then save.clear;
 end;


end.