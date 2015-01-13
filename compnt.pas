unit compnt; 
interface
uses vectorD,complex2,FET,consts,stringe,compu,savedata,varu;

type
 Tres = object(Tcomp)
   r,tmp,iac,noise : double;
   neg,discrete : boolean;
   port : integer;
   constructor create(P : pointer); 
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getS(w : double;var S : cmat); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
   Procedure getdY(w : double;v0 : cvec;var Y : cvec;wat : integer); virtual;
   Procedure getdN(w : double;v0 : cmat;var N : cmat;wat : integer); virtual;
   function getYin(w : double;Z : cvec;prt : integer) : tc; virtual;
   function getReflect(w : double;Z : cvec;prt : integer) : tc; virtual;
   Procedure load(Np : integer;P : Tparams); virtual;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   function getOutput(w : double;V0,Z0 : cvec;wat : integer) : tc; virtual;
   Procedure exportQucs(var f : text);virtual;
   Procedure exportVars(var f : text;prnt : string);virtual;
   end; 
 TresW = object(Tres)
   pwr,R0 : double;
   Procedure load(Np : integer;P : Tparams); virtual;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   Procedure getY(w : double;var Y : cmat); virtual;
   end;
   

 Tcap = object(Tcomp)
   c,tand,tmp,l,rskin,r,ESRF,ESR : double;
   constructor create(P : pointer); 
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
   Procedure getdY(w : double;v0 : cvec;var Y : cvec;wat : integer); virtual;
//   function getYin(w : double;Z : cvec;prt : integer) : tc; virtual;
   Procedure load(Np : integer;P : Tparams); virtual;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   Procedure exportQucs(var f : text);virtual;
   Procedure exportVars(var f : text;prnt : string);virtual;
   end; 

 Tind = object(Tcomp)
   l,r,rskin,tmp,Q : double;
   nk : integer;
   kpl : array of double;
   Nodei : array of integer; 
   kcomp : array of pcomp;
   constructor create(P : pointer); 
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getdY(w : double;v0 : cvec;var Y : cvec;wat : integer); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
   function getYin(w : double;Z : cvec;prt : integer) : tc; virtual;
   Procedure load(Np : integer;P : Tparams); virtual;
   Procedure calclinks; virtual;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   Procedure exportQucs(var f : text);virtual;
   Procedure exportVars(var f : text;prnt : string);virtual;
   function getFoot(var wt,par : string;var pars : integer) : boolean; virtual;
   end; 


 TFET = object(Tcomp)
   F : transistor;
   gainvar : tc; 
   constructor create(P : pointer); 
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
   Procedure load(Np : integer;P : Tparams); virtual;
   function paramnum(s : string) : integer; virtual;
 //  function paramdouble(wat : integer) : boolean; virtual;
   Procedure setD2(s : string;wat : integer); virtual;
   Procedure setD(z : double;wat : integer); virtual;
   function getYin(w : double;Z : cvec;prt : integer) : tc;virtual;
   function getOutput(w : double;V0,Z0 : cvec;wat : integer) : tc; virtual;
   Procedure exportQucs(var ff : text);virtual;
   end; 

 TFETLU = object(TFET) //Lookup FET
   AF : Array of transistor;
   select,ns : integer;
   Procedure load(Np : integer;P : Tparams); virtual;
   function paramnum(s : string) : integer; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   function getD(wat : integer) : double; virtual;
   function paramstr(wat : integer) : string; virtual;
   end; 

TVCCS = object(Tcomp)
  gm,ru,td : double;
  IP3,wprev,Vprev : double;
//  Vprev : tc;
  constructor create(P : pointer); 
  Procedure getY(w : double;var Y : cmat); virtual;
  Procedure load(Np : integer;P : Tparams); virtual;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   procedure doUpdate(w : double;V0,Z0 : cvec; cnt : integer); virtual;
  end;

T2portNoise = object(Tcomp)
  I1,I2 : double;    //Noise at 1GHz
  I1W,I2W,ICW : double; //power dependance on frequency\
  IC : tc;
  constructor create(P : pointer); 
  Procedure load(Np : integer;P : Tparams); virtual;
  Procedure getN(w : double;var N : cmat); virtual;
  end;
  
 T2port = object(Tcomp)
   F : transistor;
   temp : double; 
   constructor create(P : pointer); 
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
   Procedure load(Np : integer;P : Tparams); virtual;
//   function paramnum(s : string) : integer; virtual;
//   function paramdouble(wat : integer) : boolean; virtual;
//   Procedure setD2(s : string;wat : integer); virtual;
   end; 


 Tgain = object(Tcomp)
   ri,ru,tmpI,tmpU,A,M,Ph,AW,PW,OIP3,p_in,w_old : double;
   p_ic : tc;
   noise : double;
   AN : integer;
   Afreq : tvec;
   Adata : cvec;
   constructor create(P : pointer); 
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
   Procedure load(Np : integer;P : Tparams); virtual;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   Procedure loadA(N : integer;F : tvec;D : cvec;MM : double);
  function getA(w : double) : tc;
  procedure setA(w : double;AA : tc);
  procedure doUpdate(w : double;V0,Z0 : cvec; cnt : integer); virtual; 
   end; 
 Tloss = object(Tcomp)
   ri,temp,A,Aw : double;
   noise : double;
   constructor create(P : pointer); 
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
   Procedure load(Np : integer;P : Tparams); virtual;
   end; 

 Tfilter = object(Tcomp)
   ri,ru,A,temp,Delay : double;
   ZD,PD : array of tc;
   ZN,PN : integer;
   constructor create(P : pointer); 
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
   Procedure load(Np : integer;P : Tparams); virtual;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   function getA(w : double) : tc;
   end; 

 Tfilter2 = object(Tcomp)
   ri,ru,A,temp,Delay,offset : double;
   AD,BD : tvec;
   AN,BN : integer;
   constructor create(P : pointer); 
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
   Procedure load(Np : integer;P : Tparams); virtual;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   function getA(w : double) : tc;
   end; 

 TFnoise = object(Tcomp)
   Fnc,temp : double;
   constructor create(P : pointer); 
   Procedure getN(w : double;var N : cmat); virtual;
   Procedure load(Np : integer;P : Tparams); virtual;
   end; 

 PVCCS = ^TVCCS;  
 Pres = ^Tres;  
 PresW = ^TresW;  
 Pcap = ^Tcap;  
 Pind = ^Tind;  
 PFET = ^TFET;
 PFETLU = ^TFETLU;
 P2port = ^T2port;
 Pgain = ^Tgain;
 Ploss = ^Tloss;
 Pfilter = ^Tfilter;
 Pfilter2 = ^Tfilter2;
 P2portNoise = ^T2portNoise;
 PFnoise = ^TFnoise;  

 
implementation
uses sysutils,sport,math;


constructor tres.create(P : pointer);
begin inherited create(P);Nnode:=2; end;


Procedure Tres.load(Np : integer;P : Tparams);
begin
neg:=false;
r:=getparm(Np,P,'R',1);
neg:=r<0;r:=abs(r);
port:=round(getparm(Np,P,'PORT',0));
tmp:=getparm(Np,P,'TEMP',0);
iac:=getparm(Np,P,'VAC',0);
discrete:=getparm(Np,P,'DISCRETE',0)=1;
if discrete then r:=getkode(r);
if tmp>0 then Noise:=sqrt(k4*tmp/r);
if iac>0 then Nsrc:=1 else Nsrc:=0;
if tmp>0 then Nnoise:=1 else Nnoise:=0;
end;
function Tres.getOutput(w : double;V0,Z0 : cvec;wat : integer) : tc;
begin
//power
//writeln('P');
getOutput:=r2c(cabs2(V0[1]-V0[0])/r,0);
end;

Procedure Tres.getY(w : double;var Y : cmat);
begin
if neg then addblkR(Y,node[0],node[0],node[1],node[1],-1/(r))
else addblkR(Y,node[0],node[0],node[1],node[1],1/(r));
end;

Procedure Tres.getS(w : double;var S : cmat);
begin
caddr(S[0,node[1]],iac/r);
caddr(S[0,node[0]],-iac/r);
end;

Procedure Tres.getN(w : double;var N : cmat);
begin
caddr(N[noiseI,node[1]],Noise);
caddr(N[noiseI,node[0]],-Noise);
end;

function Tres.getYin(w : double;Z : cvec;prt : integer) : tc;
begin getYin:=(-1/(r*r))*z[0]+1/r; end;

function Tres.getReflect(w : double;Z : cvec;prt : integer) : tc;
begin getReflect:=(-2/r)*z[0]+1; end;

{Procedure Tres.getdY(w : double;v0 : cvec;var Y : cmat);
begin
addblk(Y,node[0],node[0],node[1],node[1],-1/(r*r)*(V0[1]-V0[0]));
end;}
Procedure Tres.getdY(w : double;v0 : cvec;var Y : cvec;wat : integer);
var
 z : tc;
begin
z:=-1/(r*r)*(V0[1]-V0[0]);
if neg then z:=z*-1;
cadd(Y[node[1]],z);
cadd(Y[node[0]],-z);
end;

Procedure Tres.getdN(w : double;v0 : cmat;var N : cmat;wat : integer);
var
 d : double;
begin
d:=-Noise/(2*r);
caddr(N[noiseI,node[1]],d);
caddr(N[noiseI,node[0]],-d);
end;

function Tres.paramnum(s : string) : integer;
  begin if uppercase(s)='R' then paramnum:=1 else 
        if uppercase(s)='VAC' then paramnum:=2 else 
        if uppercase(s)='TEMP' then paramnum:=4 else 
        if uppercase(s)='DISCRETE' then paramnum:=3 else paramnum:=0;end;

function Tres.paramstr(wat : integer) : string; 
begin
 case wat of 
  1 : paramstr:='R';
  2 : paramstr:='VAC'; 
  3 : paramstr:='DISCRETE';
  4 : paramstr:='TEMP';
  else paramstr:='';end;
end;
function Tres.getD(wat : integer) : double; 
   begin case wat of
    1 : if neg then getD:=-r else getD:=r;
    2 : getD:=iac;
    3 : if discrete then getD:=1 else getD:=0;
    4 : getD:=tmp;
    else getD:=0; end;
 end;
Procedure Tres.setD(z : double;wat : integer);
   begin case wat of
    1: begin;  neg:=z<0;r:=abs(z);if discrete then r:=getkode(r);Noise:=sqrt(k4*tmp/r);end;
    2 : iac:=z;
    3 : begin;discrete:=z=1;if discrete then r:=getkode(r);Noise:=sqrt(k4*tmp/r);end;
    4 : begin;tmp:=z;Noise:=sqrt(k4*tmp/r);end;
    end;
 end;

Procedure Tres.exportQucs(var f : text);
begin
if port>0 then 
 if iac>0 then writeln(f,'Pac:',name,' ',expnode(node[1]),' ',expnode(node[0]),' Num="',port,'" Z="',R,' Ohm" P="',10*log10(iac*iac/R),' dB" f="1 GHz" Temp="',tmp-273,'"')
          else writeln(f,'Pac:',name,' ',expnode(node[1]),' ',expnode(node[0]),' Num="',port,'" Z="',R,' Ohm" P="0 dB" f="1 GHz" Temp="',tmp-273,'"')
   else writeln(f,'R:',name,' ',expnode(node[0]),' ',expnode(node[1]),' R="',R,' Ohm" Temp="',tmp-273,'" Tc1="0.0" Tc2="0.0" Tnom="26.85"');
end;

Procedure Tres.exportVars(var f : text;prnt : string);
begin
writeln(f,prnt+name+':R=',R);
end;


Procedure TresW.load(Np : integer;P : Tparams);
begin
inherited load(Np,p);
pwr:=getparm(Np,P,'P',1);
R0:=R;
end;

Procedure TresW.getY(w : double;var Y : cmat);
begin
R:=R0*power(w,pwr);
inherited getY(w,Y);
end;
function TresW.paramnum(s : string) : integer;
begin 
if uppercase(s)='P' then paramnum:=10 else paramnum:= inherited paramnum(s);
end;
function TresW.paramstr(wat : integer) : string; 
begin
if wat=10 then paramstr:='P' else paramstr:=inherited paramstr(wat);
end;
function TresW.getD(wat : integer) : double; 
begin
if wat=10 then getD:=Pwr else begin;r:=R0;getD:=inherited getD(wat);end;
end;
Procedure TresW.setD(z : double;wat : integer);
begin
if wat=10 then pwr:=z else begin;r:=R0;inherited setD(z,wat);R0:=r;end;
end;

constructor tcap.create(P : pointer);
begin inherited create(P);Nnode:=2; end;

Procedure Tcap.load(Np : integer;P : Tparams);
begin
c:=getparm(Np,P,'C',1e-9);
tand:=getparm(Np,P,'TAND',0);
l:=getparm(Np,P,'L',0);
tmp:=getparm(Np,P,'TEMP',0);
rskin:=getparm(Np,P,'RSKIN',0)/sqrt(2*pi); //Ohm / sqrt(f) -> Ohm / sqrt(w)
ESRf:=getparm(Np,P,'ESRF',1e8); //Hz 
ESR:=getparm(Np,P,'ESR',0); //ESR @ ESRF
if (ESR>0) then begin //ESR at w=1
 r:=ESR-rskin*sqrt(ESRf*2*pi)-tand/(2*pi*ESRf*C);
 end; 
   
if (tmp>0) and (tand>0) then Nnoise:=1 else Nnoise:=0;
end;

Procedure Tcap.getY(w : double;var Y : cmat);
var  cx : tc;
rr : double;
begin
{if tand>0 then cx:=r2c(w*c*tand,w*C)
          else cx:=r2c(0,w*c);
if L>0 then cx:=cx / (cx*r2c(0,w*L)+r2c(1,0));
if (rskin>0) or (r>0) then begin
 rr:=r+rskin*sqrt(w);
 cx:=cx / (cx*rr+r2c(1,0) );
 end;}
RR:=r+rskin*sqrt(w)+tand/(w*C);
cx:=cinv(r2c(RR,w*L-1/(w*C)));
addblk(Y,node[0],node[0],node[1],node[1],cx);
end;
Procedure Tcap.getdY(w : double;v0 : cvec;var Y : cvec;wat : integer);
var  z : tc;
begin
if tand>0 then z:=r2c(w*tand,-w)
          else z:=r2c(0,-w);
z:=z*(V0[node[1]]-V0[node[0]]);
cadd(Y[node[1]],z);
cadd(Y[node[0]],-z);
end;

Procedure Tcap.getN(w : double;var N : cmat);
var
RR,cx : double;
begin
RR:=r+rskin*sqrt(w)+tand/(w*C);
cx:=w*L-1/(w*C);
rr:=sqrt(k4*tmp*rr/(rr*rr+cx*cx));
//g:=w*c*tand;
//g:=sqrt(k4*tmp*g);
 caddr(N[noiseI,node[1]],rr);
 caddr(N[noiseI,node[0]],-rr);
end;

Procedure Tcap.exportQucs(var f : text);
var
 s,s2 : string;
begin
s:=expnode(node[0]);
if r>0 then begin
  s2:='_'+name+'_R';
  writeln(f,'R:',name,'_R ',s,' ',s2,' R="',R,' Ohm" Temp="',tmp-273,'" Tc1="0.0" Tc2="0.0" Tnom="26.85"');
  s:=s2;
  end;
if l>0 then begin
  s2:='_'+name+'_L';
  writeln(f,'L:',name,'_L ',s,' ',s2,' L="',L,' H" I=""');
  s:=s2;
  end;
 writeln(f,'C:',name,' ',s,' ',expnode(node[1]),' C="',C,' F" V=""');
end;

Procedure Tcap.exportVars(var f : text;prnt : string);
begin
writeln(f,prnt+name+':C=',C);
if r>0 then writeln(f,prnt+name+':R=',R);
if l>0 then writeln(f,prnt+name+':L=',L);
end;


function Tcap.paramnum(s : string) : integer;
  begin if uppercase(s)='C' then paramnum:=1 else 
        if uppercase(s)='ESR' then paramnum:=2 else 
        if uppercase(s)='ESRF' then paramnum:=3 else 
  paramnum:=0;end;
function Tcap.paramstr(wat : integer) : string; 
begin if wat=1 then paramstr:='C' else 
      if wat=2 then paramstr:='ESR' else
      if wat=3 then paramstr:='ESRF' else
      paramstr:='';end;
function Tcap.getD(wat : integer) : double; 
   begin
   case wat of 
    1 : getD:=c;
    2 : getD:=ESR;
    3 : getD:=ESRF;
    end;end;
Procedure Tcap.setD(z : double;wat : integer);
   begin
   case wat of
   1 :  c:=z;//abs(z);
   2 :  ESR:=abs(z);
   3 : ESRF:=abs(z);
   end;
   if (ESR>0) and (rskin>0) then begin //ESR at w=1
 r:=ESR-rskin*sqrt(ESRf*2*pi)-tand/(2*pi*ESRf*C);
 end; 
 end;

constructor tind.create(P : pointer);
begin inherited create(P);Nnode:=2; end;

Procedure Tind.load(Np : integer;P : Tparams);
var
 s : string;
 x : integer;
begin
l:=getparm(Np,P,'L',1e-9);
r:=getparm(Np,P,'R',0);
q:=getparm(Np,P,'Q',0);
rskin:=getparm(Np,P,'RSKIN',0);
tmp:=getparm(Np,P,'TEMP',0);
if (tmp>0) and ((r>0) or (rskin>0) or (q>0)) then Nnoise:=1 else Nnoise:=0;
//writeln('test1...');
for x:=0 to Np-1 do if P[x].name[1]='K' then begin
//  writeln('test...');
   if Nvar=0 then begin
      Nvar:=1;
      setlength(nodei,nvar);
      setlength(Kpl,nvar);
      nodei[0]:=Psport(parent)^.getnodei(uppercase(name));
      Kpl[0]:=1;
      end;
  s:=P[x].name;
  splitdp(s);
  inc(Nvar);
  setlength(nodei,nvar);
  setlength(kpl,Nvar);
  nodei[nvar-1]:=Psport(parent)^.getnodei(s);
  kpl[nvar-1]:=strtofloat(P[x].value);
  end;
//  writeln(name,' coupled to ',nvar);
end;

Procedure Tind.calclinks;
var
 n0,x : integer;
 C : pcomp;
begin
//writeln(name,' calclink...');
if Nvar=0 then exit;
with psport(parent)^ do n0:=np+nv;
setlength(kcomp,nvar);
for x:=0 to Nvar-1 do begin
 with psport(parent)^ do
   C:=findcomp(Spi[nodei[x]]);
   if c=nil then begin
     writeln(name,' linked to unknown induktor ',psport(parent)^.Spi[nodei[x]]);
     halt(1);
     end;
  nodei[x]:=nodei[x]+n0;
//  Kpl[x]:=Kpl[x]*Pind(C)^.L; 
  kcomp[x]:=C;
//  writeln(name,' links calculated');
  end;
end; 


Procedure Tind.getY(w : double;var Y : cmat);
var c : tc;
 n0,x : integer;
 rr : double;
begin
if nvar=0 then begin
   if q>0 then r:=w*L/q;
   if rskin>0 then c:=1/r2c(r+rskin*sqrt(w)/79266,w*L) else
   if r>0 then c:=1/r2c(r,w*L) 
          else c:=r2c(0,-1/(w*L));
   addblk(Y,node[0],node[0],node[1],node[1],c);
 end else begin
  n0:=nodei[0];
  caddr(Y[n0,node[0]],-1);
  caddr(Y[n0,node[1]],1);
  
  caddr(Y[node[0],n0],1);
  caddr(Y[node[1],n0],-1);
//  for x:=0 to nvar-1 do writeln(name,' ' ,x,' ',nodei[x],' ',n0,' ',kpl[x],' ',node[0],' ',node[1]);
//  for x:=0 to nvar-1 do cadd(Y[nodei[x],n0],R2C(0,w*kpl[x]));
//    for x:=0 to 0      do cadd(Y[nodei[x],n0],R2C(0,w*kpl[x]*sqrt( L*Pind(kcomp[x])^.L ) ));
    for x:=0 to nvar-1 do cadd(Y[nodei[x],n0],R2C(0,w*kpl[x]*sqrt( L*Pind(kcomp[x])^.L ) ));
  if q>0 then r:=w*L/q;
  if rskin>0 then caddr(Y[n0,n0],r+rskin*sqrt(w)/79266) else
    if r>0 then caddr(Y[n0,n0],r);
 end;
end;

function Tind.getYin(w : double;Z : cvec;prt : integer) : tc;
var c : tc;
begin
if nvar<>0 then begin;writeln('getYin for L not implemented');halt(1);end;
   if q>0 then r:=w*L/q;
   if rskin>0 then c:=1/r2c(r+rskin*sqrt(w)/79266,w*L) else
   if r>0 then c:=1/r2c(r,w*L) 
          else c:=r2c(0,-1/(w*L));
 getYin:=(1-c*z[0])*c;
end;

Procedure Tind.getdY(w : double;v0 : cvec;var Y : cvec;wat : integer);
var  z : tc;
begin
if nvar=0 then begin
   if r>0 then begin;z:=1/r2c(r,w*L);z:=r2c(0,-w)*z*z;end 
          else z:=r2c(0,-1/(w*L*L));
 end else begin
  writeln('Optimization of coupled induktors not implemented');
  halt(1);
  end;
z:=z*(V0[node[1]]-V0[node[0]]);
cadd(Y[node[1]],z);
cadd(Y[node[0]],-z);
end;

Procedure Tind.getN(w : double;var N : cmat);
var  rn : double;
begin
if nvar=0 then begin
 if q>0 then r:=w*L/q;
 if rskin>0 then begin
    rn:=r+rskin*sqrt(w)/79266;
    rn:=sqrt(k4*tmp*rn/cabs2(r2c(rn,w*L)));
    end else 
    rn:=sqrt(k4*tmp*r/cabs2(r2c(r,w*L)));
 caddr(N[noiseI,node[1]],rn);
 caddr(N[noiseI,node[0]],-rn);
end else begin
 rn:=sqrt(k4*tmp*r);
 caddr(N[noiseI,nodei[0]],rn);
end;
end;


function Tind.paramnum(s : string) : integer;
  begin if uppercase(s)='L' then paramnum:=1 else 
        if uppercase(s)='R' then paramnum:=2 else 
        if uppercase(s)='RSKIN' then paramnum:=3 else
        if uppercase(s)='Q' then paramnum:=4 else
        if uppercase(s)='K1' then paramnum:=11 else 
        if uppercase(s)='K2' then paramnum:=12 else 
           paramnum:=0;end;
function Tind.paramstr(wat : integer) : string; 
begin if wat=1 then paramstr:='L' else 
      if wat=2 then paramstr:='R' else 
      if wat=3 then paramstr:='RSKIN' else 
      if wat=4 then paramstr:='Q' else 
      if wat=11 then paramstr:='K1' else 
      if wat=12 then paramstr:='K2' else 
      paramstr:='';end;
function Tind.getD(wat : integer) : double; 
   begin case wat of 
    1 : getD:=l;
    2 : getD:=r;
    3 : getD:=rskin;
    4 : getD:=q;
    11 : getD:=kpl[1];
    12 : getD:=kpl[2];
 end;end;
Procedure Tind.setD(z : double;wat : integer);
   begin case wat of 
   1 : l:=z;
   2 : r:=z;
   3 : rskin:=z;
   4 : q:=z;
   11 : kpl[1]:=z;
   12 : kpl[2]:=z;
   end; end;

Procedure Tind.exportQucs(var f : text);
var
 s,s2 : string;
begin
s:=expnode(node[0]);
if r>0 then begin
  s2:='_'+name+'_R';
  writeln(f,'R:',name,'_R ',s,' ',s2,' R="',R,' Ohm" Temp="',tmp-273,'" Tc1="0.0" Tc2="0.0" Tnom="26.85"');
  s:=s2;
  end;
  writeln(f,'L:',name,'_L ',s,' ',expnode(node[1]),' L="',L,' H" I=""');
end;


Procedure Tind.exportVars(var f : text;prnt : string);
begin
writeln(f,prnt+name+':L=',L);
if r>0 then writeln(f,prnt+name+':R=',R);
end;

function Tind.getFoot(var wt,par : string;var pars : integer) : boolean; 
begin
//pars:=2;
getFoot:=true;
 wt:='L';
 par:='L='+name+':L';
end;


constructor tfet.create(P : pointer);
begin inherited create(P);Nnode:=3; end;

Procedure Tfet.exportQucs(var ff : text);
begin
writeln(ff,'SPfile:',name,' ',expnode(node[1]),' ',expnode(node[2]),' ',expnode(node[0]),' File="{',F.filename,'}" Data="rectangular" Interpolator="linear" duringDC="open"');
end;

Procedure Tfet.load(Np : integer;P : Tparams);
var
 s : string;
begin
 gainvar:=r2c(1,0);
 s:=P[0].value;
 if s[1]='"' then delete(s,1,1);
 if s[length(s)]='"' then delete(s,length(s),1);
// writeln('Filename=',s);
 F:=LoadFet(s);
// F.laaiS(s);
 if F.hoefnoise=0 then Nnoise:=0 else Nnoise:=2;
//Nnoise:=2;
end;

Procedure Tfet.getY(w : double;var Y : cmat);
var 
 S : sparm;
 x : integer;
begin
 S:=F.kryY(w/twopi);
 S[3]:=S[3]*gainvar;
addblk(Y,node[0],node[0],node[1],node[1],S[1]);
addblk(Y,node[0],node[0],node[1],node[2],S[2]);
addblk(Y,node[0],node[0],node[2],node[1],S[3]);
addblk(Y,node[0],node[0],node[2],node[2],S[4]);
{ writeln('w=',w);
 for x:=0 to 3 do V[x]:=S[x+1];}
// writeln(node[0],' ',node[1],' ',node[2]);
// write('Y=');
// for x:=0 to 3 do cwrite(S[x]);writeln;
end;

Procedure Tfet.getN(w : double;var N : cmat); 
var
 V : array[0..3] of tc;
begin
//writeln('FET=',longint(F));
F.Isrc(w,V);
cadd(N[noiseI  ,node[1]],V[0]);
cadd(N[noiseI  ,node[0]],-V[0]);
cadd(N[noiseI  ,node[2]],V[1]);
cadd(N[noiseI  ,node[0]],-V[1]);
cadd(N[noiseI+1,node[1]],V[2]);
cadd(N[noiseI+1,node[0]],-V[2]);
cadd(N[noiseI+1,node[2]],V[3]);
cadd(N[noiseI+1,node[0]],-V[3]);
//cvwrite(4,V);
end;

function Tfet.getYin(w : double;Z : cvec;prt : integer) : tc;
var
//v : cvec;
 S : sparm;
 a,b : array[1..2] of tc;
i,j,k : integer;
zz : tc;
begin
 S:=F.kryY(w/twopi);
 case prt of 
  0 : begin
     b[1]:=S[1]+S[3];
     b[2]:=S[2]+S[4];   
     a[1]:=Z[0]*b[1]+Z[2]*b[2];
     a[2]:=Z[1]*b[1]+Z[3]*b[2];
     getYin:=S[1]+S[2]+S[3]+S[4] - S[1]*a[1]-S[3]*a[2] -S[2]*a[1]-S[4]*a[2];
     end;
  1 : begin
        a[1]:=Z[0]*S[1]+Z[2]*S[2];
        a[2]:=Z[1]*S[1]+Z[3]*S[2];
        getYin:=S[1]-S[1]*a[1]-S[3]*a[2];
	end;
  2 : begin
        a[1]:=Z[0]*S[3]+Z[2]*S[4];
        a[2]:=Z[1]*S[3]+Z[3]*S[4];
        getYin:=S[4]-S[2]*a[1]-S[4]*a[2];
	end;
 else getYin:=czero;
end;  
end;

function Tfet.paramnum(s : string) : integer;
begin
//writeln('FET paramnum');
if s='SPARAM' then paramnum:=1 else 
if s='GAINVAR_MAG' then paramnum:=2 else 
if s='GAINVAR_ANG' then paramnum:=3 else 
paramnum:=0;
end;
{
function Tfet.paramdouble(wat : integer) : boolean;
begin
//inherited paramdouble(wat);
writeln('FET paramdouble');
paramdouble:=false;
end;
}
Procedure Tfet.setD2(s : string;wat : integer);
begin
//writeln('FET setD2');
//inherited setD2(s,wat);
if wat=1 then  F.laaiS(s);
end;
Procedure Tfet.setD(z : double;wat : integer);
begin
if wat=2 then gainvar:=r2c(z,0);
if wat=3 then gainvar:=r2c(1,z);
end;
function tfet.getOutput(w : double;V0,Z0 : cvec;wat : integer) : tc;
var 
 NN : tnoise;
begin
NN:=F.kryNfreq(w/twopi/1e9);
case wat of 
 2: getOutput:=r2c(NN.rn,0);
 3: getOutput:=r2c(NN.gn,0);
 4: getOutput:=NN.Ycor;
 5 : with NN do getOutput:=r2c(sqrt(gn/rn+sqr(Ycor[1])),-Ycor[2]);
else
 getOutput:=r2c(NN.fmin*290,0);
end;
//writeln(w/twopi/1e9,' ',F.kryNfreq(w/twopi/1e9).fmin*290);
end;

Procedure TfetLU.load(Np : integer;P : Tparams);
var
 l,l2 : integer;
 s : string;
 ff : text;
begin
 gainvar:=r2c(1,0);
 s:=P[0].value;
 if s[1]='"' then delete(s,1,1);
 if s[length(s)]='"' then delete(s,length(s),1);
 assign(ff,s);
 reset(ff);
 l:=0;l2:=0;
 write('Loading S-params from list ',s,'...');
 while not(eof(ff)) do begin
   if l=l2 then begin
     l2:=l2+10;
     setlength(AF,l2);
     end;
  readln(ff,s);
  AF[l]:=Loadfet(s);
  inc(l);
 end;
 close(ff);
 setlength(AF,l);
 writeln(' DONE n=',l);
 Nnoise:=0; //NB !!!!!
 select:=0;ns:=l; 
 F:=AF[0];
// if F.hoefnoise=0 then Nnoise:=0 else Nnoise:=2;
end;

function TfetLU.paramnum(s : string) : integer;
begin
if s='N' then paramnum:=10 else paramnum:=inherited paramnum(s);
end;
Procedure TfetLU.setD(z : double;wat : integer);
var
 i : integer;
begin
if wat=10 then begin
  i:=round(z);
  if i<0 then i:=0 else if i>=ns then i:=ns-1;
  F:=AF[i];
  select:=i;
  end else inherited setD(z,wat);
end;

function TfetLU.getD(wat : integer) : double; 
begin
 if wat=10 then getD:=select else getD:=inherited getD(wat);
end;
function TfetLU.paramstr(wat : integer) : string;
begin
 if wat=10 then paramstr:='N' else paramstr:=inherited paramstr(wat);
end;

{
function T2port.paramnum(s : string) : integer;
begin
if s='SPARAM' then paramnum:=1 else paramnum:=0;
end;
function T2port.paramdouble(wat : integer) : boolean;
begin
paramdouble:=false;
end;
Procedure T2port.setD2(s : string;wat : integer);
begin
writeln('Reload FET!');
if wat=1 then  F.laaiS(s);
end;
}


constructor t2port.create(P : pointer);
begin inherited create(P);Nnode:=2; end;

Procedure T2port.load(Np : integer;P : Tparams);
var
 s : string;
begin
 s:=P[0].value;
 if s[1]='"' then delete(s,1,1);
 if s[length(s)]='"' then delete(s,length(s),1);
// writeln('Filename=',s);
 F.laaiS(s);
 temp:=getparm(Np,P,'TEMP',0);
 if temp>0 then Nnoise:=1 else Nnoise:=0;
//Nnoise:=2;
end;

Procedure T2port.getY(w : double;var Y : cmat);
var 
 S : sparm;
// x : integer;
begin
 S:=F.kryY(w/twopi);
// writeln;
// write('Y11=');cwrite(S[1]);write('Y12=');cwrite(s[2]);
// writeln;
//addblk(Y,node[0],node[0],node[1],node[1],S[1]);
{ writeln('w=',w);
 for x:=0 to 3 do V[x]:=S[x+1];
 write('Y=');
 for x:=0 to 3 do cwrite(V[x]);writeln;}
end;

Procedure T2port.getN(w : double;var N : cmat); 
var
 S : sparm;
 ns : double;
begin
 S:=F.kryY(w/twopi);
Ns:=sqrt(k4*temp*S[1,1]);
//writeln('N=',ns);
caddr(N[noiseI  ,node[1]],ns);
caddr(N[noiseI  ,node[0]],-ns);
//cvwrite(4,V);
end;


constructor tgain.create(P : pointer);
begin inherited create(P);Nnode:=4; end;


Procedure Tgain.load(Np : integer;P : Tparams);
begin
ri:=getparm(Np,P,'RIN',50);
ru:=getparm(Np,P,'ROUT',50);
A:=getparm(Np,P,'A',10);
Aw:=getparm(Np,P,'AW',0)/1e9;
Ph:=getparm(Np,P,'PHASE',0);
PW:=getparm(Np,P,'DELAY',0);
PW:=getparm(Np,P,'PW',PW)/1e9;
M:=getparm(Np,P,'M',290);
tmpI:=getparm(Np,P,'TEMPIN',290);
tmpU:=getparm(Np,P,'TEMPOUT',290)/290;
if (tmpI>0) or (tmpU>0) then Nnoise:=2 else Nnoise:=0;
AN:=0;
w_old:=0;
OIP3:=getparm(Np,P,'OIP3',0);
alwaysupdate:=OIP3<>0;
end;

function Tgain.getA(w : double) : tc;
var
 x : integer;
begin
//writeln('GetA w=',w);
getA:=r2c(1,0);
if AN<1 then exit else
if AN=1 then begin;getA:=Adata[0];exit;end;
if w<=Afreq[0] then getA:=Adata[0] else
if w>=Afreq[AN-1] then getA:=Adata[AN-1] else
for x:=1 to AN-1 do
 if Afreq[x]>w then begin
  getA:=(Adata[x-1]*(Afreq[x]-w)+Adata[x]*(w-Afreq[x-1]) ) / (Afreq[x]-Afreq[x-1]);
  exit;
  end;
end;

procedure Tgain.setA(w : double;AA : tc);
var
 x : integer;
 y : integer;
begin
//writeln('SetA w=',w,' A=',AA[1],' ',AA[2]);
if AN<0 then AN:=0;
y:=0;
while (y<AN) and (Afreq[y]<w) do inc(y);
if (y=AN) or (Afreq[y]<>w) then begin;
 setlength(Afreq,AN+1);
 setlength(Adata,AN+1);
 for x:=AN downto y+1 do begin
    Afreq[x]:=Afreq[x-1];
    Adata[x]:=Adata[x-1];
    end;
 AN:=AN+1;
 end;
// writeln('y=',y,' AN=',AN);
Adata[y]:=AA;
Afreq[y]:=w;
end;
   
Procedure Tgain.getY(w : double;var Y : cmat);
var
 A2 :tc;
 begin
if AN>0 then A2:=getA(w) else A2:=sqrt(A+AW*w)*expi( (Ph+Pw*w) );
if OIP3>0 then begin
  if w<>w_old then begin;p_in:=0;p_ic:=czero;w_old:=w;end;
  A2:=A2*(1-p_in/OIP3*cabs2(A2));
//  A2:=A2*(1-p_ic/OIP3*A2*A2);
//  if fr<0 then fr:=0;
//  A2:=A2*fr;
  end;
//if A2<1 then A2:=1;
addblkR(Y,node[0],node[0],node[1],node[1],1/(ri));
addblkR(Y,node[2],node[2],node[3],node[3],1/(ru));
addblk( Y,node[0],node[2],node[1],node[3],-2*sqrt(1/(ru*ri))*A2);
//if AN>0 then write(name,': GetA w=',w,' A=');cwriteEng(getA(w));writeln;
//if AN>0 then addblk(Y,node[0],node[2],node[1],node[3],-2*sqrt( 1 / (ru*ri)) * getA(w) )
//        else addblk(Y,node[0],node[2],node[1],node[3],-2*sqrt( A2 / (ru*ri))*expi( (Ph+PW*w) ));
end;

Procedure Tgain.getN(w : double;var N : cmat);
var
 A2 : double;
begin
Noise:=sqrt(k4*tmpI/Ri);
caddr(N[noiseI,node[1]],Noise);
caddr(N[noiseI,node[0]],-Noise);
if AN>0 then A2:=cabs2(getA(w)) 
        else A2:=A+AW*w;
//if A2<1 then A2:=1;
if A2>=1 then noise:=sqrt(k4*tmpU*M*( A2 -1)/Ru)
         else noise:=sqrt(k4*tmpU*290*(1- A2)/Ru);
caddr(N[noiseI+1,node[3]],Noise);
caddr(N[noiseI+1,node[2]],-Noise);
end;

procedure Tgain.doUpdate(w : double;V0,Z0 : cvec; cnt : integer); 
var
 d,p2 : double;
begin
 p2:=cabs2(v0[1])/ri;
// if (p_in+p2)<1e-50 then d:=1 else d:=abs ( (p_in-p2) / (p_in+p2) );
d:=abs(p_in-p2);
// writeln('VCCS c=',cnt,' w=',w,' d=',d);
 p_in:=p2;
 p_ic:=v0[1]*v0[1]/ri;
 if {(cnt<5) and} (d>1e-20) then recalc(w);
end;


function Tgain.paramnum(s : string) : integer;
  begin if uppercase(s)='A' then paramnum:=1 else 
        if uppercase(s)='RIN' then paramnum:=2 else
        if uppercase(s)='ROUT' then paramnum:=3 else
        if uppercase(s)='M' then paramnum:=4 else
        if uppercase(s)='PHASE' then paramnum:=5 else
        if uppercase(s)='AW' then paramnum:=6 else
        if uppercase(s)='PW' then paramnum:=7 else
        if uppercase(s)='DELAY' then paramnum:=7 else
        if uppercase(s)='DB' then paramnum:=8 else
        paramnum:=0;
        end;
function Tgain.paramstr(wat : integer) : string; 
begin 
case wat of 
 1 : paramstr:='A';
 2 : paramstr:='RIN';
 3 : paramstr:='ROUT';
 4 : paramstr:='M';
 5 : paramstr:='PHASE';
 6 : paramstr:='AW';
 7 : paramstr:='PW';
 8 : paramstr:='DB';
 else paramstr:='';end;end;
 
function Tgain.getD(wat : integer) : double; 
   begin 
  case wat of
   1 : getD:=A;
   2 : getD:=Ri;
   3 : getD:=Ru;
   4 : getD:=M;
   5 : getD:=Ph;
   6 : getD:=AW*1e9;
   7 : getD:=PW*1e9;
   8 : getD:=10*log10(A);
   else getD:=0;
   end;end;
Procedure Tgain.setD(z : double;wat : integer);
   begin  
   case wat of 
    1 : A:=z;
    2 : Ri:=z;
    3 : Ru:=z;
    4 : M:=z;
    5 : Ph:=z;
    6 : AW:=z/1e9;
    7 : PW:=z/1e9;
    8 : A:=power(10,z/10);
end;end;
Procedure Tgain.loadA(N : integer;F : tvec;D : cvec;MM : double);
var
 x : integer;
begin
AN:=N;
if MM>0 then M:=MM;
setlength(Afreq,N);
setlength(Adata,N);
for x:=0 to N-1 do Afreq[x]:=F[x];
for x:=0 to N-1 do Adata[x]:=D[x];
//for x:=0 to N-1 do cwriteEng(D[x]);
//writeln;
end;

constructor tloss.create(P : pointer);
begin inherited create(P);Nnode:=3; end;


Procedure Tloss.load(Np : integer;P : Tparams);
begin
ri:=getparm(Np,P,'RIN',50);
A:=getparm(Np,P,'A',0.99);
Aw:=getparm(Np,P,'AW',0)/1e9/twopi;
temp:=getparm(Np,P,'TEMPIN',290);
if (temp>0) then Nnoise:=3;
end;

   
Procedure Tloss.getY(w : double;var Y : cmat);
var
 A2,RR :double;
begin
A2:=A+AW*w;
A2:=sqrt(A2);

RR:=ri*(1+A2)/(1-A2);
//write('R1=',RR);
addblkR(Y,node[0],node[0],node[1],node[1],1/(RR));
addblkR(Y,node[0],node[0],node[2],node[2],1/(RR));

RR:=ri*(1/A2-A2)/2;
//writeln('  R2=',RR);
addblkR(Y,node[1],node[1],node[2],node[2],1/RR );
end;

Procedure Tloss.getN(w : double;var N : cmat);
var
 A2,RR : double;
begin
A2:=A+AW*w;
A2:=sqrt(A2);
RR:=ri*(1+A2)/(1-A2);
Noise:=sqrt(k4*temp/RR);
caddr(N[noiseI+0,node[1]],Noise);
caddr(N[noiseI+0,node[0]],-Noise);
caddr(N[noiseI+1,node[2]],Noise);
caddr(N[noiseI+1,node[0]],-Noise);
RR:=ri*(1/A2-A2)/2;
Noise:=sqrt(k4*temp/RR);
caddr(N[noiseI+2,node[1]],Noise);
caddr(N[noiseI+2,node[2]],-Noise);
end;

constructor tVCCS.create(P : pointer);
begin inherited create(P);Nnode:=4; end;

Procedure TVCCS.load(Np : integer;P : Tparams);
begin
gm:=getparm(Np,P,'GM',1);
ru:=getparm(Np,P,'R',0);
td:=getparm(Np,P,'TD',0);
IP3:=getparm(Np,P,'IIP3',0);
alwaysupdate:=IP3<>0;
if IP3<>0 then IP3:=1/(IP3*IP3);
wprev:=0;
Nsrc:=0;Nnoise:=0;
end;

Procedure TVCCS.getY(w : double;var Y : cmat);
var
 gm2 : tr;
begin
if IP3=0 then
  if td>0 then addblk(Y,node[0],node[2],node[1],node[3],gm*expi(-w*td) )
   else addblkR(Y,node[0],node[2],node[1],node[3],gm )
else begin
// write('+ Vprev=',sqrt(cabs2(Vprev)));
 if w<>wprev then begin;Vprev:=0;wprev:=w;end;
 gm2:=gm*(1-IP3*Vprev);
  if td>0 then addblk(Y,node[0],node[2],node[1],node[3],gm2*expi(-w*td) )
   else addblkR(Y,node[0],node[2],node[1],node[3],gm2 );
// recalc(w);
 end;
if Ru>0 then addblkR(Y,node[2],node[2],node[3],node[3],1/(ru));
end;

procedure TVCCS.doUpdate(w : double;V0,Z0 : cvec; cnt : integer); 
var
 d,V2 : double;
begin
 V2:=cabs2(v0[1]);
 d:=abs ( (vprev-V2) / (vprev+V2) );
// writeln('VCCS c=',cnt,' w=',w,' d=',d);
 Vprev:=V2;
 if (cnt<5) and (d>1e-4) then recalc(w);
end;


function TVCCS.paramnum(s : string) : integer;
  begin if uppercase(s)='GM' then paramnum:=1 else
        if uppercase(s)='TD' then paramnum:=2 else paramnum:=0;end;
function TVCCS.paramstr(wat : integer) : string; 

begin
 case wat of 
  1 : paramstr:='GM';
  2 : paramstr:='TD';
  else paramstr:='';end;
end;
function TVCCS.getD(wat : integer) : double; 
   begin case wat of
    1 : getD:=gm;
    2 : getD:=td;
    else getD:=0; end;
 end;
Procedure TVCCS.setD(z : double;wat : integer);
   begin case wat of
    1: gm:=z;
    2: td:=z;
    end;
 end;

constructor t2portNoise.create(P : pointer);
begin inherited create(P);Nnode:=4; end;

Procedure t2portNoise.load(Np : integer;P : Tparams);
var
 s : string;
begin
 I1:=getparm(Np,P,'I1',1);
 I2:=getparm(Np,P,'I2',1);
 IC:=r2c( getparm(Np,P,'CR',0),getparm(Np,P,'CI',0) );
 I1w:=getparm(Np,P,'I1W',0);
 I2w:=getparm(Np,P,'I2W',0);
 ICw:=getparm(Np,P,'CW',0);
 Nnoise:=2;
end;


Procedure t2portNoise.getN(w : double;var N : cmat); 
var
 II : double;
 CC : tc;
begin
if I1w=0 then II:=I1 else II:=I1*power(w/twopi/1e9,I1w);
caddr(N[noiseI,node[0]],-II);
caddr(N[noiseI,node[1]],II);

if I2w=0 then II:=I2 else II:=I2*power(w/twopi/1e9,I2w);
if ICw=0 then CC:=IC else CC:=IC*power(w/twopi/1e9,ICw);
CC:=CC*II;
cadd(N[noiseI,node[2]],-CC);
cadd(N[noiseI,node[3]],CC);

II:=II*II-cabs2(CC);
if II<0 then II:=0;
II:=sqrt(II);
caddr(N[noiseI+1,node[2]],-II);
caddr(N[noiseI+1,node[3]],II);

//cvwrite(4,V);
end;


constructor tfilter.create(P : pointer);
begin inherited create(P);Nnode:=4; end;


Procedure tfilter.load(Np : integer;P : Tparams);
var
 z : tc;
begin
ri:=getparm(Np,P,'RIN',50);
ru:=getparm(Np,P,'ROUT',50);

A:=getparm(Np,P,'A',1);
DELAY:=getparm(Np,P,'DELAY',1);
temp:=getparm(Np,P,'TEMP',0);
ZN:=0;
z:=r2c( getparm(Np,P,'ZR1',0), getparm(Np,P,'ZI1',0) );
while (z[1]<>0) or (z[2]<>0) do begin
 inc(ZN);
 setlength(ZD,ZN);
 ZD[ZN-1]:=z;
 z:=r2c( getparm(Np,P,'ZR'+inttostr(ZN+1),0), getparm(Np,P,'ZI'+inttostr(ZN+1),0) );
 end;
PN:=0;
z:=r2c( getparm(Np,P,'PR1',0), getparm(Np,P,'PI1',0) );
while (z[1]<>0) or (z[2]<>0) do begin
 inc(PN);
 setlength(PD,PN);
 PD[PN-1]:=z;
 z:=r2c( getparm(Np,P,'ZR'+inttostr(PN+1),0), getparm(Np,P,'ZI'+inttostr(PN+1),0) );
 end;
writeln('ZN=',ZN,' PN=',PN);
if (temp>0)  then Nnoise:=2 else Nnoise:=0;
end;

function tfilter.getA(w : double) : tc;
var
 x : integer;
 z,z2,s : tc;
begin
//writeln('getA..');
z:=A*expi(-delay*w);
w:=w/(twopi*1e9);
s:=r2c(0,w);
for x:=0 to ZN-1 do begin
 if abs(ZD[x,2])<=1e-4 then Z:=z*(s-ZD[x,1]) else z:=z*(s-ZD[x]);
 if abs(ZD[x,2])<1e-4 then z:=z*(s-ccomp(ZD[x]));
 end;
for x:=0 to PN-1 do begin
  if abs(PD[x,2])<=1e-4 then z2:=(s-PD[x,1]) else
                            z2:=(s-PD[x]);
  if cabs2(z2)>1e-10 then begin
    z:=z/z2;
    if abs(PD[x,2])>1e-4 then z:=z/(s-ccomp(PD[x]));
    end else z:=r2c(1e99,0);
  end; 
getA:=z;
//write('getA=');cwriteEng(z);writeln;
//getA:=r2c(0.6,0);
end;

Procedure tfilter.getY(w : double;var Y : cmat);
var
 S : tc;
begin
S:=getA(w);
addblkR(Y,node[0],node[0],node[1],node[1],1/(ri));
addblkR(Y,node[2],node[2],node[3],node[3],1/(ru));
addblk(Y,node[0],node[2],node[1],node[3],2*sqrt( 1 / (ru*ri)) * S )
end;

Procedure tfilter.getN(w : double;var N : cmat);
var
 S :tc;
 Ns : double;
begin
Ns:=sqrt(k4*temp/Ri);
caddr(N[noiseI,node[1]],Ns);
caddr(N[noiseI,node[0]],-Ns);
ns:=sqrt(k4*temp/Ru);
caddr(N[noiseI+1,node[3]],Ns);
caddr(N[noiseI+1,node[2]],-Ns);

end;

function tfilter.paramnum(s : string) : integer;
var
wat,x,y : integer;
begin
if uppercase(s)='RIN' then paramnum:=100 else
if uppercase(s)='ROUT' then paramnum:=101 else 
if uppercase(s)='A' then paramnum:=102 else
if uppercase(s)='DELAY' then paramnum:=103 else
begin
paramnum:=0;
if length(s)<3 then exit;
if s[1]='Z' then wat:=1 else 
if s[1]='P' then wat:=-1 else exit;
if s[2]='R' then y:=1 else
if s[2]='I' then y:=2 else exit;
delete(s,1,2);
x:=strtoint(s);
paramnum:=wat*(x*2-2+y);
end;end;


function tfilter.paramstr(wat : integer) : string; 
var
 s : string;
 x,y,l : integer;
begin 
case wat of
 100 : paramstr:='RIN';
 101 : paramstr:='ROUT';
 102 : paramstr:='A';
 103 : paramstr:='DELAY';
  else begin
if wat>0 then begin;s:='Z';l:=ZN;end else begin;s:='P';l:=PN;end;

y:=abs(wat);
x:=(y-1) div 2;
y:=(y-1) mod 2 + 1;

x:=x+1;
if x>l then x:=l;
if y=1 then s:=s+'R' else s:=s+'I';
s:=s+inttostr(x);

paramstr:=s;
end;end;
end; 
 
 
function tfilter.getD(wat : integer) : double; 
var
x,y : integer;
begin
case wat of 
 100 : getD:=ri;
 101 : getD:=ru;
 102 : getD:=A;
 103 : getD:=delay;
 else begin
y:=abs(wat);
x:=(y-1) div 2;
y:=(y-1) mod 2 + 1;
if wat>0 then getD:=ZD[x,y] else 
if wat<0 then getD:=PD[x,y] else getD:=0;
end;end;end;

Procedure tfilter.setD(z : double;wat : integer);
var
x,y : integer;
begin
case wat of 
 100 : ri:=z;
 101 : ru:=z;
 102 : A:=z;
 103 : delay:=z;
 else begin
y:=abs(wat);
x:=(y-1) div 2;
y:=(y-1) mod 2 + 1;
if wat>0 then ZD[x,y]:=z else
if wat<0 then PD[x,y]:=z;
end;
end;end;

constructor tfilter2.create(P : pointer);
begin inherited create(P);Nnode:=4; end;


Procedure tfilter2.load(Np : integer;P : Tparams);
var
 x : integer;
begin
ri:=getparm(Np,P,'RIN',50);
ru:=getparm(Np,P,'ROUT',50);

A:=getparm(Np,P,'A',1);
DELAY:=getparm(Np,P,'DELAY',1);
temp:=getparm(Np,P,'TEMP',0);

offset:=getparm(Np,P,'OFFSET',0);

AN:=round(getparm(Np,P,'AN',0));
BN:=round(getparm(Np,P,'BN',0));
setlength(AD,AN+1);
setlength(BD,BN+1);

for x:=0 to AN do AD[x]:=getparm(NP,P,'A'+inttostr(x),0);
for x:=0 to BN do BD[x]:=getparm(NP,P,'B'+inttostr(x),0);
//writeln('Filter loaded ');
//write('A=');for x:=0 to AN do write(AD[x]:4:1);writeln;
//write('B=');for x:=0 to BN do write(BD[x]:4:1);writeln;

if (temp>0)  then Nnoise:=2 else Nnoise:=0;
end;

function tfilter2.getA(w : double) : tc;
var
 x : integer;
 z,z2,s : tc;
begin
//writeln('getA..');
z:=A*expi(-delay*w);
w:=w/(twopi*1e9);
s:=r2c(0,w);

z2:=r2c((AD[AN]-offset),0);
for x:=AN-1 downto 0 do z2:=(AD[x]-offset)+z2*s;
z:=z*z2;

z2:=r2c((BD[BN]-offset),0);
for x:=BN-1 downto 0 do z2:=(BD[x]-offset)+z2*s;
if (abs(z2[1])>1e-10) or (abs(z2[2])>1e-10) then z:=z/z2 else z:=r2c(1e99,0);
//cwriteEng(z);
getA:=z;
end;

Procedure tfilter2.getY(w : double;var Y : cmat);
var
 S : tc;
begin
S:=getA(w);
addblkR(Y,node[0],node[0],node[1],node[1],1/(ri));
addblkR(Y,node[2],node[2],node[3],node[3],1/(ru));
addblk(Y,node[0],node[2],node[1],node[3],2*sqrt( 1 / (ru*ri)) * S )
end;

Procedure tfilter2.getN(w : double;var N : cmat);
var
 S :tc;
 Ns : double;
begin
Ns:=sqrt(k4*temp/Ri);
caddr(N[noiseI,node[1]],Ns);
caddr(N[noiseI,node[0]],-Ns);
ns:=sqrt(k4*temp/Ru);
caddr(N[noiseI+1,node[3]],Ns);
caddr(N[noiseI+1,node[2]],-Ns);

end;

function tfilter2.paramnum(s : string) : integer;
var
wat,x,y : integer;
begin
if uppercase(s)='RIN' then paramnum:=100 else
if uppercase(s)='ROUT' then paramnum:=101 else 
if uppercase(s)='A' then paramnum:=102 else
if uppercase(s)='DELAY' then paramnum:=103 else
begin
paramnum:=0;
if length(s)<2 then exit;
if s[1]='A' then wat:=1 else 
if s[1]='B' then wat:=-1 else exit;
delete(s,1,1);
x:=strtoint(s);
//writeln('paramnum ',s,' = ',wat*(x+1));
paramnum:=wat*(x+1);
end;end;


function tfilter2.paramstr(wat : integer) : string; 
var
 s : string;
 x,y,l : integer;
begin 
case wat of
 100 : paramstr:='RIN';
 101 : paramstr:='ROUT';
 102 : paramstr:='A';
 103 : paramstr:='DELAY';
  else begin
if wat>0 then begin;s:='A';l:=AN;end else 
if wat<0 then begin;s:='B';l:=BN;end else exit;

x:=abs(wat)-1;
if x>l then x:=l;
paramstr:=s+inttostr(x);
end;end;
end; 
 
 
function tfilter2.getD(wat : integer) : double; 
var
x,y : integer;
begin
case wat of 
 100 : getD:=ri;
 101 : getD:=ru;
 102 : getD:=A;
 103 : getD:=delay;
 else begin
x:=abs(wat)-1;
if wat>0 then getD:=AD[x] else 
if wat<0 then getD:=BD[x] else getD:=0;
end;end;end;

Procedure tfilter2.setD(z : double;wat : integer);
var
x,y : integer;
begin
case wat of 
 100 : ri:=z;
 101 : ru:=z;
 102 : A:=z;
 103 : delay:=z;
 else begin
x:=abs(wat)-1;
if wat>0 then AD[x]:=z else
if wat<0 then BD[x]:=z;
end;
end;end;


constructor TFnoise.create(P : pointer); 
begin inherited create(P);Nnode:=2; end;

Procedure TFnoise.load(Np : integer;P : Tparams);
begin
Fnc:=getparm(Np,P,'FNC',1e6)*twopi;
Temp:=getparm(Np,P,'TEMP',290);
nnoise:=1;
end;

Procedure TFnoise.getN(w : double;var N : cmat); 
var
 Ns : double;
begin
Ns:=sqrt(k4*temp*Fnc/w);
caddr(N[noiseI,node[1]],Ns);
caddr(N[noiseI,node[0]],-Ns);
end;

end.