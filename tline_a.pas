unit tline_a; 
interface
uses vectorD,complex2,FET,consts,stringe,compu,savedata,mstrip,varu;
//pgourbet@rgm.fr

type
   
 Ttline3 = object(Tcomp)
   SR,cond,z0,k,k1,tand,tand0,alpha,rm,alphaz,temp,len : double;
//   open : boolean;
   YY,NN : cmat;
   Save : Tsave;
  l_m,c_m : double;
//   G_m,C_m,L_m,R_m  : double; 
   Procedure calcLCRG(w : double;var gm,Y0 : tc;var g_m,r_m,dl : double); virtual;

   constructor create(P : pointer); 
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
//   Procedure getdY(w : double;v0 : cvec;var Y : cvec;wat : integer); virtual;
   Procedure load(Np1 : integer;P : Tparams); virtual;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   function getYin(w : double;Z : cvec;prt : integer) : tc; virtual;
   Procedure calcNY(w : double); virtual;
   Procedure calcY(w : double;var gm,Y0 : tc;var g_m,r_m,dl : double);
   end; 
   
 TtlineR = object(Ttline3)
  R : double;
  discrete : boolean;
  Procedure calcLCRG(w : double;var gm,Y0 : tc;var g_m,r_m,dl : double); virtual;
  Procedure load(Np1 : integer;P : Tparams); virtual;
  function paramnum(s : string) : integer; virtual;
  function paramstr(wat : integer) : string; virtual;
  function getD(wat : integer) : double; virtual;
  Procedure setD(z : double;wat : integer); virtual;
   end; 

 Ttline3B = object(Tcomp)
   z0_e,k_e,tand_e,alpha_e,rm_e : double;
   z0_o,k_o,tand_o,alpha_o,rm_o : double;
   noise_e,noise_o : boolean;
   temp,len : double;
   YY,NN : cmat;
   Save : Tsave;
//   G_m,C_m,L_m,R_m  : double; 
   constructor create(P : pointer); 
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
   Procedure load(Np1 : integer;P : Tparams); virtual;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   end; 
   
 Ptline3 = ^Ttline3;
 PtlineR = ^TtlineR;
 Ptline3B = ^Ttline3B;

implementation
uses sysutils,sport,math;


constructor ttline3.create(P : pointer);
begin inherited create(P);Nnode:=3; end;

Procedure Ttline3.load(Np1 : integer;P : Tparams);
begin
 Z0   :=getparm(Np1,P,'Z0',50);
 k    :=getparm(Np1,P,'K',4);
 k1   :=getparm(Np1,P,'K1',0);
 len  :=getparm(Np1,P,'LEN',1e-3);
 tand0 :=getparm(Np1,P,'TAND',0.0);
 if (k1>1) then tand:=tand0*(1-1/k1)/(1-1/k) else tand:=tand0;
 alpha:=getparm(Np1,P,'ALPHA',0.0);
 rm:=getparm(Np1,P,'R_M',0.0);
// fopt :=getparm(Np,P,'fopt',1e9);
 temp :=getparm(Np1,P,'TEMP',0);
 SR  :=getparm(Np1,P,'SR',0);
 cond :=getparm(Np1,P,'COND',5.96e7);
 alpha:=alpha*0.11512926; //db/m to nepers/m
 alpha:=alpha/sqrt(1e9*twopi); //alpha given for 1GHz
// open :=getparm(Np1,P,'OPEN',0)<>0;
 rm:=rm/sqrt(1e9*twopi);
 if ((tand=0) and (alpha=0) and (rm=0)) or (temp=0) then Nnoise:=0 else Nnoise:=2;
// Nnoise:=0;
// calcLCR;
 Save.init(2,nnoise-1);
 CMsetsize(2,2,YY);
 CMsetsize(nnoise,nnoise,NN);
end;

Procedure Ttline3.calcLCRG(w : double;var gm,Y0 : tc;var g_m,r_m,dl : double);
const
 u0 = 1.256637061e-6;
var
al,bl : double;
sd,Kr : double;
begin
dl:=0;
if k1>1 then c_m:=sqrt(k1)/(Z0*c0)
        else c_m:=sqrt(k)/(Z0*c0);
 l_m:=(z0*z0)*c_m;
//writeln('l_m=',l_m,' c_m=',c_m);
if alpha<>0 then  r_m:=alpha*Z0*sqrt(w) else
if rm<>0 then r_m:=rm*sqrt(w) else r_m:=0;
if SR>1e-20 then begin
 sd:=sqrt(2/(w*u0*cond));
 Kr:=1+2/pi*arctan(1.4*sqr(SR/sd));
 r_m:=r_m*Kr;
 end;
 g_m:=tand*(w*c_m);
// writeln('c/m=',c_m,' l/m=',l_m,' r/m=',r_m,' g/m=',g_m);
 gm:=csqrt( R2c(r_m,w*l_m)*r2c(g_m,w*C_m) );
 Y0:=csqrt( R2c(g_m,w*c_m)/r2c(r_m,w*l_m) );
end;

Procedure Ttline3.calcY(w : double;var gm,Y0 : tc;var g_m,r_m,dl : double);
var  
//g_m,r_m,dl : double;
//gm,Y0,n,x,x1 : tc;
 n,x,x1 : tc;
Y12,Y11 : tc;
yy0,n1,n2,n3,n4,i0,i1,C : double;
begin
// write('gm=');cwrite(gm);//writeln;
//writeln;
// write('Y0=');cwrite(Y0);writeln(' len=',len);
{ al:=gm[1]*len; bl:=gm[2]*len;
 Y12:=1/r2c( sinh(al)*cos(bl) , cosh(al)*sin(bl) );
 Y11:=Y0*Y12*r2c( cosh(al)*cos(bl) , sinh(al)*sin(bl) );
 Y12:=-Y0*Y12;}
//writeln('tline getY l=',len,' dl=',dl);
x:=expc(gm*(len+dl));
x1:=1/x;
y12:=1/(x-x1);

if nnoise=2 then begin
 yy0:=cabs2(y12);
 n1:=yy0*(cabs2(x)-cabs2(x1))/gm[1]/2;
 Y11:=x*ccomp(x1);
 n2:=yy0*Y11[2]/gm[2];

 n3:=yy0*(x[1]-x1[1])/gm[1];
 n4:=yy0*(x[2]-x1[2])/gm[2]; 

//writeln('n1=',n1,' n2=',n2);
 i0:=k4*temp*(g_m*(n1-n2) +cabs2(Y0)*r_m*(n1+n2));
 C:= k4*temp*(g_m*(n3-n4) +cabs2(Y0)*r_m*(n3+n4));
 C:=C/i0;
// write('i0=',i0);
 i1:=i0*(1-C*C);
//writeln('i0=',i0,' i1=',i1);
if (i1<0) then i1:=0;
if (i0<0) then i0:=0;
 i1:=sqrt(i1);
 i0:=sqrt(i0);
 C:=-C*i0;
 end;

Y11:=Y0*(x+x1)*y12;
Y12:=-Y0*2*y12;

 YY[0,0]:=Y11;
 YY[0,1]:=Y12;
 YY[1,1]:=Y11;
 YY[1,0]:=Y12;

if nnoise=2 then begin
 NN[0,0]:=r2c(i0,0);
 NN[0,1]:=r2c(c,0);
 NN[1,1]:=r2c(i1,0);
 NN[1,0]:=czero;
 end;
end;

Procedure Ttline3.calcNY(w : double);
var  
g_m,r_m,dl : double;
gm,Y0 : tc;
begin
if save.getsaved(w,YY,NN) then begin
 end else begin
 calcLCRG(w,gm,Y0,g_m,r_m,dl);
 calcY(w,gm,Y0,g_m,r_m,dl);
 if nnoise=2 then save.savedata(w,YY,NN)
             else save.savedata(w,YY,YY); 
end;


end;

Procedure Ttline3.getY(w : double;var Y : cmat);
begin;
//writeln('Done');
//writeln;
{cwriteEng(YY[0,0]);
cwriteEng(YY[0,1]);writeln;
}

calcNY(w);
addblk(Y,node[0],node[0],node[1],node[1],YY[0,0]);
addblk(Y,node[0],node[0],node[1],node[2],YY[0,1]);
addblk(Y,node[0],node[0],node[2],node[1],YY[1,0]);
addblk(Y,node[0],node[0],node[2],node[2],YY[1,1]);
end;

function Ttline3.getYin(w : double;Z : cvec;prt : integer) : tc;
var
//v : cvec;
 a,b : array[1..2] of tc;
//i,j,k : integer;
zz : tc;
begin
calcNY(w);
// S:=F.kryY(w/twopi);
 case prt of 
  0 : begin
     b[1]:=YY[0,0]+YY[1,0];
     b[2]:=YY[0,1]+YY[1,1];   
     a[1]:=Z[0]*b[1]+Z[2]*b[2];
     a[2]:=Z[1]*b[1]+Z[3]*b[2];
     getYin:=YY[0,0]+YY[0,1]+YY[1,0]+YY[1,1] - YY[0,0]*a[1]-YY[1,0]*a[2] -YY[0,1]*a[1]-YY[1,1]*a[2];
     end;
  1 : begin
        a[1]:=Z[0]*YY[0,0]+Z[2]*YY[0,1];
        a[2]:=Z[1]*YY[0,0]+Z[3]*YY[0,1];
        getYin:=YY[0,0]-YY[0,0]*a[1]-YY[1,0]*a[2];
	end;
  2 : begin
        a[1]:=Z[0]*YY[1,0]+Z[2]*YY[1,1];
        a[2]:=Z[1]*YY[1,0]+Z[3]*YY[1,1];
        getYin:=YY[1,1]-YY[0,1]*a[1]-YY[1,1]*a[2];
	end;
 else getYin:=czero;
end;  
end;

Procedure Ttline3.getN(w : double;var N : cmat);
begin
if not(save.getsaved(w,YY,NN)) then begin
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
end;


function Ttline3.paramnum(s : string) : integer;
  begin 
  s:=uppercase(s);
   if s='Z0' then paramnum:=1 else 
   if s='LEN' then paramnum:=2 else
   if s='K' then paramnum:=3 else
   if s='R_M' then paramnum:=4 else
   if s='K1' then paramnum:=5 else
   if s='ALPHA' then paramnum:=6 else
    paramnum:=0;
  end;
function Ttline3.paramstr(wat : integer) : string; 
begin
 case wat of 
 1 : paramstr:='Z0';
 2 : paramstr:='LEN';
 3 : paramstr:='K';
 4 : paramstr:='R_M';
 5 : paramstr:='K1';
 6 : paramstr:='ALPHA';
 else paramstr:='';
 end;
end;

function Ttline3.getD(wat : integer) : double; 
   begin 
   case wat of
    1 : getD:=Z0;
    2 : getD:=LEN;
    3 : getD:=k;
    4 : getD:=RM*sqrt(1e9*twopi);
    5 : getD:=k1;
    6 : getD:=alpha/0.11512926*sqrt(1e9*twopi);
     end;
    end;
Procedure Ttline3.setD(z : double;wat : integer);
var
 diff : boolean;
 begin 
 diff:=false;
   case wat of
    1 : if Z0<>abs(z) then begin;Z0:=abs(z);diff:=true;end;
    2 : if len<>abs(z) then begin;len:=abs(z);diff:=true;end;
    3 : if k<>abs(z) then begin;k:=abs(z);diff:=true;end;
    4 : if rm*sqrt(1e9*twopi)<>abs(z) then begin;rm:=abs(z)/sqrt(1e9*twopi);diff:=true;end;
    5 : if k1<>abs(z) then begin;k1:=abs(z);if (k1>1) then tand:=tand0*(1-1/k1)/(1-1/k) else tand:=tand0;diff:=true;end;
    6 : begin;z:=abs(z)*0.11512926/sqrt(1e9*twopi);if z<>alpha then begin;alpha:=z;diff:=true;end;end;

    end;
 if diff then save.clear;
 end;


Procedure TtlineR.load(Np1 : integer;P : Tparams);
var
 x,y : integer;
 c : pcomp;
begin
inherited load(Np1, P);
discrete:=getparm(Np1,P,'DISCRETE',0)=1;
 R :=getparm(Np1,P,'R',100);
 if discrete then R:=getkode(R);
end;

Procedure TtlineR.calcLCRG(w : double;var gm,Y0 : tc;var g_m,r_m,dl : double);
begin
 inherited calcLCRG(w,gm,Y0,g_m,r_m,dl);
 r_m:=R/(len+dl);
 gm:=csqrt( R2c(r_m,w*l_m)*r2c(g_m,w*C_m) );
 Y0:=csqrt( R2c(g_m,w*c_m)/r2c(r_m,w*l_m) );
end;

function TtlineR.paramnum(s : string) : integer;
  begin 
  s:=uppercase(s);
   if s='R' then paramnum:=10 else
   if s='DISCRETE' then paramnum:=11 else
     paramnum:=inherited paramnum(s);
  end;

function TtlineR.paramstr(wat : integer) : string; 
begin
 case wat of 
 10 : paramstr:='R';
 11 : paramstr:='DISCRETE';
 else paramstr:=inherited paramstr(wat);
 end;
end;

function TtlineR.getD(wat : integer) : double; 
   begin 
   case wat of
    10 : getD:=R;
    11 : if discrete then getD:=1 else getD:=0;
    else getD:=inherited getD(wat);
     end;
    end;

Procedure TtlineR.setD(z : double;wat : integer);
var
 diff : boolean;
 begin 
 diff:=false;
   case wat of
    10 : begin
      if discrete then z:=getkode(abs(z));
      if R<>z then begin;r:=z;diff:=true;end;
      end;
    11 : begin
      discrete:=round(z)=1;
      if discrete then r:=getkode(abs(r));
      diff:=true;
      end;
      else inherited setD(z,wat);      
    end;
 if diff then save.clear;
 end;


constructor ttline3B.create(P : pointer);
begin inherited create(P);Nnode:=5; end;

Procedure Ttline3B.load(Np1 : integer;P : Tparams);
begin
 k_e    :=getparm(Np1,P,'K',4);k_o:=k_e;
 tand_e :=getparm(Np1,P,'TAND',0.0);tand_o:=tand_e;
 alpha_e:=getparm(Np1,P,'ALPHA',0.0);alpha_o:=alpha_e;
 Z0_e   :=getparm(Np1,P,'Z0',50);Z0_o:=Z0_e;

 Z0_e   :=getparm(Np1,P,'Z0_E',Z0_e)/2;
 k_e    :=getparm(Np1,P,'K_E',k_e);
 tand_e :=getparm(Np1,P,'TAND_E',tand_e);
 alpha_e:=getparm(Np1,P,'ALPHA_E',alpha_e);
 rm_e:=getparm(Np1,P,'R_M_E',0.0);

 Z0_o   :=getparm(Np1,P,'Z0_O',Z0_o)*2;
 k_o    :=getparm(Np1,P,'K_O',k_o);
 tand_o :=getparm(Np1,P,'TAND_O',tand_o);
 alpha_o:=getparm(Np1,P,'ALPHA_O',alpha_o);
 rm_o:=getparm(Np1,P,'R_M_O',0.0);
// fopt :=getparm(Np,P,'fopt',1e9);
 len  :=getparm(Np1,P,'LEN',1e-3);
 temp :=getparm(Np1,P,'TEMP',0);

 alpha_e:=alpha_e*0.11512926; //db/m to nepers/m
 alpha_e:=alpha_e/sqrt(1e9*twopi); //alpha given for 1GHz
 alpha_o:=alpha_o*0.11512926; //db/m to nepers/m
 alpha_o:=alpha_o/sqrt(1e9*twopi); //alpha given for 1GHz
 rm_e:=rm_e/sqrt(1e9*twopi);
 rm_o:=rm_o/sqrt(1e9*twopi);
 noise_e:=((tand_e<>0) or (alpha_e<>0) or (rm_e<>0)) and (temp<>0);
 noise_o:=((tand_o<>0) or (alpha_o<>0) or (rm_o<>0)) and (temp<>0);
 Nnoise:=0;
 if noise_e then inc(Nnoise,2);
 if noise_o then inc(Nnoise,2);
// writeln('nnoise=',nnoise);
// Nnoise:=0;
// calcLCR;
 Save.init(2,1);
 CMsetsize(2,2,YY);
 CMsetsize(2,2,NN);
end;

Procedure Ttline3B.getY(w : double;var Y : cmat);
var  
c_m,l_m,r_m,g_m,al,bl : double;
gm,Y0,n,x,x1 : tc;
Y12_e,Y11_e,Y12_o,Y11_o : tc;
yy0,n1,n2,n3,n4 : double;
i0_e,i1_e,C_e,i0_o,i1_o,C_o : double;
begin

if save.getsaved(w,YY,NN) then begin
// Y11_e:=YY[0,0];
// Y12_e:=YY[0,1];
// Y11_0:=YY[1,0];
// Y12_0:=YY[1,1];
 end else begin
//Even mode 
//writeln('Even mode');
 c_m:=sqrt(k_e)/(Z0_e*c0);
 l_m:=(z0_e*z0_e)*c_m;
if alpha_e<>0 then  r_m:=alpha_e*Z0_e*sqrt(w) else
if rm_e<>0 then r_m:=rm_e*sqrt(w) else r_m:=0;
 g_m:=tand_e*(w*c_m);
 gm:=csqrt( R2c(r_m,w*l_m)*r2c(g_m,w*C_m) );
 Y0:=csqrt( R2c(g_m,w*c_m)/r2c(r_m,w*l_m) );
 x:=expc(gm*len);
 x1:=1/x;
 y12_e:=1/(x-x1);

if noise_e then begin
 yy0:=cabs2(y12_e);
 n1:=yy0*(cabs2(x)-cabs2(x1))/gm[1]/2;
 Y11_e:=x*ccomp(x1);
 n2:=yy0*Y11_e[2]/gm[2];

 n3:=yy0*(x[1]-x1[1])/gm[1];
 n4:=yy0*(x[2]-x1[2])/gm[2]; 

 i0_e:=k4*temp*(g_m*(n1-n2) +cabs2(Y0)*r_m*(n1+n2));
 C_e:= k4*temp*(g_m*(n3-n4) +cabs2(Y0)*r_m*(n3+n4));
 C_e:=C_e/i0_e;
 i1_e:=i0_e*(1-C_e*C_e);
if (i1_e<0) then i1_e:=0;
if (i0_e<0) then i0_e:=0;
 i1_e:=sqrt(i1_e);
 i0_e:=sqrt(i0_e);
 C_e:=-C_e*i0_e;

 end;

Y11_e:=Y0*(x+x1)*y12_e;
Y12_e:=-Y0*2*y12_e;

//odd mode 
//writeln('Odd mode');
 c_m:=sqrt(k_o)/(Z0_o*c0);
 l_m:=(z0_o*z0_o)*c_m;
if alpha_o<>0 then  r_m:=alpha_o*Z0_o*sqrt(w) else
if rm_o<>0 then r_m:=rm_o*sqrt(w) else r_m:=0;
 g_m:=tand_o*(w*c_m);
 gm:=csqrt( R2c(r_m,w*l_m)*r2c(g_m,w*C_m) );
 Y0:=csqrt( R2c(g_m,w*c_m)/r2c(r_m,w*l_m) );
 x:=expc(gm*len);
 x1:=1/x;
 y12_o:=1/(x-x1);

if noise_o then begin
 yy0:=cabs2(y12_o);
 n1:=yy0*(cabs2(x)-cabs2(x1))/gm[1]/2;
 Y11_o:=x*ccomp(x1);
 n2:=yy0*Y11_o[2]/gm[2];

 n3:=yy0*(x[1]-x1[1])/gm[1];
 n4:=yy0*(x[2]-x1[2])/gm[2]; 

 i0_o:=k4*temp*(g_m*(n1-n2) +cabs2(Y0)*r_m*(n1+n2));
 C_o:= k4*temp*(g_m*(n3-n4) +cabs2(Y0)*r_m*(n3+n4));
 C_o:=C_o/i0_o;
 i1_o:=i0_o*(1-C_o*C_o);
if (i1_o<0) then i1_o:=0;
if (i0_o<0) then i0_o:=0;
 i1_o:=sqrt(i1_o);
 i0_o:=sqrt(i0_o);
 C_o:=-C_o*i0_o;

 end;

Y11_o:=Y0*(x+x1)*y12_o;
Y12_o:=-Y0*2*y12_o;

//writeln('Save');
//write('even: i0=',i0_e,' C=',C_e,' i1=',i1_e);
//write(' odd: i0=',i0_o,' C=',C_o,' i1=',i1_o);
if noise_e and noise_o then begin
 NN[0,0]:=r2c(i0_e/2,i0_o);
 NN[0,1]:=r2c(c_e/2,c_o);
 NN[1,1]:=r2c(i1_e/2,i1_o);
end else if noise_e  then begin
 NN[0,0]:=r2c(i0_e/2,0);
 NN[0,1]:=r2c(c_e/2,0);
 NN[1,1]:=r2c(i1_e/2,0);
end else if noise_o then begin
 NN[0,0]:=r2c(0,i0_o);
 NN[0,1]:=r2c(0,c_o);
 NN[1,1]:=r2c(0,i1_o);
end;



 YY[0,0]:=(Y11_e/4+Y11_o);
 YY[0,1]:=(Y11_e/4-Y11_o);
 YY[1,1]:=(Y12_e/4-Y12_o);
 YY[1,0]:=(Y12_e/4+Y12_o);
{writeln;
cwrite(YY[0,0]);
cwrite(YY[0,1]);
cwrite(YY[1,1]);
cwrite(YY[1,0]);
}
//writeln('Saving,,');
 save.savedata(w,YY,NN); 

// YY[0,0]:=Y11;
// YY[0,1]:=Y12;
// YY[1,1]:=Y11;
// YY[1,0]:=Y12;
{if nnoise=2 then begin
 NN[0,0]:=r2c(i0,0);
 NN[0,1]:=r2c(c,0);
 NN[1,1]:=r2c(i1,0);
 NN[1,0]:=czero;
 save.savedata(w,YY,NN); 
 end else}
//writeln('Done');
end;
//writeln('Y');

addblk(Y,node[0],node[0],node[1],node[1],YY[0,0]);
addblk(Y,node[0],node[0],node[2],node[1],YY[0,1]);
addblk(Y,node[0],node[0],node[3],node[1],YY[1,0]);
addblk(Y,node[0],node[0],node[4],node[1],YY[1,1]);

addblk(Y,node[0],node[0],node[1],node[2],YY[0,1]);
addblk(Y,node[0],node[0],node[2],node[2],YY[0,0]);
addblk(Y,node[0],node[0],node[3],node[2],YY[1,1]);
addblk(Y,node[0],node[0],node[4],node[2],YY[1,0]);

addblk(Y,node[0],node[0],node[1],node[3],YY[1,0]);
addblk(Y,node[0],node[0],node[2],node[3],YY[1,1]);
addblk(Y,node[0],node[0],node[3],node[3],YY[0,0]);
addblk(Y,node[0],node[0],node[4],node[3],YY[0,1]);

addblk(Y,node[0],node[0],node[1],node[4],YY[1,1]);
addblk(Y,node[0],node[0],node[2],node[4],YY[1,0]);
addblk(Y,node[0],node[0],node[3],node[4],YY[0,1]);
addblk(Y,node[0],node[0],node[4],node[4],YY[0,0]);
end;

Procedure Ttline3B.getN(w : double;var N : cmat);
begin
if not(save.getsaved(w,YY,NN)) then begin
  writeln('Tline Noise data not saved!!');
  halt(1);
  end;
//writeln('i0=',NN[0,0,1],' i1=',NN[1,1,1],' C=',NN[0,1,1]);
//odd mode
//writeln('Noise');

if noise_e and noise_o then begin
caddr(N[noiseI+2,node[1]],NN[0,0,2]);
caddr(N[noiseI+2,node[2]],-NN[0,0,2]);
caddr(N[noiseI+2,node[3]],NN[0,1,2]);
caddr(N[noiseI+2,node[4]],-NN[0,1,2]);
caddr(N[noiseI+3,node[3]],NN[1,1,2]);
caddr(N[noiseI+3,node[4]],-NN[1,1,2]);
end else if noise_o then begin
caddr(N[noiseI  ,node[1]],NN[0,0,2]);
caddr(N[noiseI  ,node[2]],-NN[0,0,2]);
caddr(N[noiseI  ,node[3]],NN[0,1,2]);
caddr(N[noiseI  ,node[4]],-NN[0,1,2]);
caddr(N[noiseI+1,node[3]],NN[1,1,2]);
caddr(N[noiseI+1,node[4]],-NN[1,1,2]);
end;
//even
if noise_e then begin
//writeln('Neven');
caddr(N[noiseI  ,node[1]],NN[0,0,1]);
caddr(N[noiseI  ,node[2]],NN[0,0,1]);
caddr(N[noiseI  ,node[0]],-2*NN[0,0,1]);
caddr(N[noiseI  ,node[3]],NN[0,1,1]);
caddr(N[noiseI  ,node[4]],NN[0,1,1]);
caddr(N[noiseI  ,node[0]],-2*NN[0,1,1]);
caddr(N[noiseI+1,node[3]],NN[1,1,1]);
caddr(N[noiseI+1,node[4]],NN[1,1,1]);
caddr(N[noiseI+1,node[0]],-2*NN[1,1,1]);
end;
end;


function Ttline3B.paramnum(s : string) : integer;
  begin 
  s:=uppercase(s);
   if s='LEN' then paramnum:=1 else
   if s='Z0' then paramnum:=2 else 
   if s='Z0_E' then paramnum:=3 else 
   if s='Z0_O' then paramnum:=4 else 
   if s='K' then paramnum:=5 else
   if s='R_M' then paramnum:=6 else
    paramnum:=0;
  end;
  
function Ttline3B.paramstr(wat : integer) : string; 
begin
 case wat of 
 1 : paramstr:='LEN';
 2 : paramstr:='Z0';
 3 : paramstr:='Z0_E';
 4 : paramstr:='Z0_O';
 5 : paramstr:='K';
 6 : paramstr:='R_M';
 else paramstr:='';
 end;
end;

function Ttline3B.getD(wat : integer) : double; 
   begin 
   case wat of
    1 : getD:=LEN;
    2,4 : getD:=Z0_o/2;
    3 : getD:=Z0_e*2;
    5 : getD:=k_o;
    6 : getD:=RM_o*sqrt(1e9*twopi);
     end;
    end;
Procedure Ttline3B.setD(z : double;wat : integer);
var
 diff : boolean;
 begin 
 z:=abs(z);
 diff:=false;
   case wat of
    1 : if len<>z then begin;len:=z;diff:=true;end;
    2 : if (Z0_o<>z*2) or (Z0_e<>z/2) then begin;Z0_o:=z*2;Z0_e:=z/2;diff:=true;end;
    3 : if Z0_e<>z/2 then begin;Z0_e:=z/2;diff:=true;end;
    4 : if Z0_o<>z*2 then begin;Z0_o:=z*2;diff:=true;end;
    5 : if (k_o<>z) or (k_e<>z) then begin;k_o:=z;k_e:=k_o;diff:=true;end;
    6 : if rm_o*sqrt(1e9*twopi)<>z then begin;rm_o:=z/sqrt(1e9*twopi);rm_e:=rm_o;diff:=true;end;
    end;
 if diff then save.clear;
 end;


end.