unit tom; 
interface
uses vectorD,complex2,FET,consts,stringe,compu,math,varu;

type
TtomOP = record
  {DC parms}
  Vgs,Vds,Ids,Qgd,Qgs,Igs,Igd : double;
  {AC parm}
  gd,gm,Cgs,Cgd,Ggs,Ggd : double;
  end;

 Ttom = object(Tcomp)

 wd,vto,alpha,beta,gamma,gammaDC,Q,delta,Vbi,Is_,N_,TAU,Cgs0,Cgd0,vdelta,delta1,delta2,fc,Vbr,Temp,XTI : double;
  RIG,Tg,Td : double;

   OP : TtomOP;
   function calc(Vgs,Vds : double) : TtomOP;
   constructor create(P : pointer); 
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
//   Procedure getdY(w : double;v0 : cvec;var Y : cmat); virtual;
//   Procedure getdN(w : double;v0 : cvec;var N : cmat); virtual;
   Procedure load(Np : integer;P : Tparams); virtual;
   end; 

   
 Ptom = ^Ttom;  


implementation
uses sysutils,sport;

constructor ttom.create(P : pointer);
begin inherited create(P);Nnode:=3; end;

procedure writeOP(OP : TtomOP); 
begin
with OP do begin
writeln('Vgs=',Vgs:5:1,'V Vds=',Vds:5:1,'V Ids=',Ids*1000:5:1,'mA');
//write('Cgd=');writeEng(Cgd);write('F Cgs=');writeEng(Cgs);writeln('F'); 
writeln(' gd=',gd*1000:5:1, 'm  gm=',gm*1000:5:1,'m Cgs=',Cgs*1e12:5:2,'pF Cgd=',Cgd*1e12:5:2,'pF');
writeln('Ggs=',ggs*1e6:5:1,'u Ggd=',ggd*1e6:5:1,'u Igs=',Igs*1e9:5:1,'nA Igd=',Igd*1e9:5:1,'nA');
end;
end;

Procedure Ttom.load(Np : integer;P : Tparams);
var
 Vds,Vgs : double;
begin
 vto:=  getparm(Np,P,'VTO', -0.798);
 alpha:=getparm(Np,P,'ALPHA',8);
 beta:= getparm(Np,P,'BETA', 0.0952);
 gamma:=getparm(NP,P,'GAMMA',0.072);
 gammaDC:=getparm(NP,P,'GAMMADC',0.065);
 Q:=getparm(NP,P,'Q',2.5);

 delta:=getparm(Np,P,'DELTA',0.5);
 Vbi:=getparm(Np,P,'VBI',0.6);
 Is_:=getparm(Np,P,'IS',1e-14);
 N_:=getparm(Np,P,'N',1);

 TAU:=getparm(Np,P,'TAU',4e-12);
// CDS:=getparm(Np,P,'CDS',0.12e-12);
// RDB:=getparm(Np,P,'RDB',5000);
// CBS:=getparm(Np,P,'CBS',1e-9);
 
 Cgs0:=getparm(Np,P,'CGS',0.36e-12);
 Cgd0:=getparm(Np,P,'CGD',0.014e-12);
 delta1:=getparm(Np,P,'DELTA1',0.3);
 delta2:=getparm(Np,P,'DELTA2',0.6);
 vdelta:=getparm(Np,P,'VDELTA',0.2);

 fc:=getparm(Np,P,'FC',0.5);
 Vbr:=getparm(Np,P,'VBR',1e100);

 Temp:=getparm(Np,P,'TEMP',290);
 XTI:=getparm(Np,P,'XTI',3);

 RIG:=getparm(Np,P,'RIG',1.5);
 TG:=getparm(Np,P,'TG',290);
 TD:=getparm(Np,P,'TD',5000);

 WD:=getparm(Np,P,'W',160)/200;

 Vds:=getparm(Np,P,'VDS',0);
 Vgs:=getparm(Np,P,'VGS',0);
 OP:=calc(Vgs,Vds);
 

//if (temp>0) then Nnoise:=2 else Nnoise:=0;
Nnoise:=2;
end;

function Ttom.calc(Vgs,Vds : double) : TtomOP;
var
del,del2,tmp1,tmp2,tmp3,tmp4,tmp5 : double;
Vg,vg_G,vg_D,Ids0,Ids0_G,Ids0_D : double;
Veff,Vnew : double;
Vgd,Vst : double;
x,F,dx_D,F_D : double;
 res : TtomOP;
begin
if Vds<0 then begin
  writeln('Vds<0 not implemented!');
  halt(1);
  end;
res.Vgs:=Vgs;
res.Vds:=Vds;
with res do begin
Vgd:=Vgs-Vds;
//Calc Ids
x:=alpha*Vds;     dx_D:=alpha;
F:=x/sqrt(1+x*x);  F_D:=1/power(1+x*x,3/2)*dx_D;
Vst:=temp*8.617e-5;
Vst:=0;

if abs(Vst)<1e-6 then begin
  Vg:=Vgs-Vto+gamma*Vds; Vg_G:=1; Vg_D:=gamma;
end else begin
  tmp1:=(Vgs-Vto+gamma*Vds)/(Q*Vst);
  Vg:=Q*Vst*ln(exp(temp)+1);  Vg_G:=1/(exp(tmp1)+1)*exp(tmp1); Vg_D:=vg_G*gamma;
end; 
Ids0:=wd*beta*power(Vg,Q)*F;   Ids0_G:=Q*Ids0/Vg*Vg_G; Ids0_D:=Q*Ids0/Vg*Vg_D+Ids0/F*F_D;

//writeln('Ids0=',Ids0,' F=',F,' Vg=',Vg);
tmp1:=1/(1+delta*Vds*Ids0);
Ids:=Ids0*tmp1; gm:=tmp1*tmp1*Ids0_G; gd:=tmp1*tmp1*Ids0_D;

tmp1:=(1-delta*Vds*Ids);
//gd:=gm*gamma+alpha*beta*power(Vg,Q)/power(1+sqr(alpha*Vds),3/2);
//gd:=gd*tmp1*tmp1-delta*Ids*Ids;
//Calc leak current
tmp1:=(11604/(n_*temp));
tmp2:=exp(tmp1*Vgs);
Igs:=wd*Is_*(tmp2-1);  Ggs:=wd*Is_*tmp1*tmp2;

tmp1:=(11604/(n_*temp));
tmp2:=exp(tmp1*Vgd);
Igd:=wd*Is_*(tmp2-1);  Ggd:=wd*Is_*tmp1*tmp2;

{Ig:=Igs+Igd;
Id:=Ids-Igd;  
}
  
//Calc Cap //Vgd = Vgs - Vds
del:=1/alpha;
del2:=vdelta;
tmp1:=Vds; //Vgs-Vgd;
tmp1:=sqrt(tmp1*tmp1+del*del); 
Veff:=0.5*(2*Vgs-Vds+tmp1);
tmp3:=veff-Vto;
tmp2:=sqrt(tmp3*tmp3+del2*del2);
Vnew :=0.5*(Veff+Vto+tmp2);
//writeln('Veff1=',Veff,' Vnew=',Vnew);

tmp3:=(veff-vto)/tmp2; 
tmp4:=Vds/tmp1;
{del:=1/alpha;
del2:=vdelta;
tmp1:=Vds; //Vgs-Vgd;
tmp1:=sqrt(tmp1*tmp1+del*del);  tmp1_D:=vds/tmp1;
Veff:=0.5*(2*Vgs-Vds+tmp1);       Veff_D:=0.5*(-1+tmp1_D); //Veff_G:=1;
tmp3:=veff1-Vto;
tmp2:=sqrt(tmp3*tmp3+del2*del2); tmp2_G:=tmp3/tmp2;           tmp2_D:=tmp2_G*Veff_D;
Vnew :=0.5*(Veff1+Vto+tmp2);     Vnew_G:=0.5*(Veff_G+tmp2_G); Vnew_D:=0.5*(Veff_D+tmp2_D);
writeln('Veff1=',Veff1,' Veff2=',Veff2,' Vnew=',Vnew,' Vmax=',vmax);

tmp3:=(veff1-vto)/tmp2;   tmp3_G:=(       tmp2-(veff1-vto)*tmp2_G )/(tmp2*tmp2);
                          tmp3_D:=(veff_D*tmp2-(veff1-vto)*tmp2_D )/(tmp2*tmp2);
tmp4:=Vds/tmp1;           tmp4_D:=(tmp1-Vds*tmp1_D)/(tmp1*tmp1);
}
tmp5:=1/sqrt(1-Vnew/Vbi);
//writeln('t5=',tmp5,' t4=',tmp4,' t3=',tmp3);
Cgs:=Cgs0*tmp5*(1+tmp3)*(1+tmp4)/4+Cgd0*(1-tmp4)/2;
Cgd:=Cgs0*tmp5*(1+tmp3)*(1-tmp4)/4+Cgd0*(1+tmp4)/2;
//writeln('Cgs=',Cgs,' Cgd=',Cgd);
end;

writeOP(res);
calc:=res;
end;

Procedure Ttom.getY(w : double;var Y : cmat);
var
 cm : tc;
begin

with OP do begin
 cm:=R2c(RIG,-1/(w*(Cgs+Cgd)));
addblk(Y,node[0],node[0],node[1],node[1],cinv(cm));
addblk(Y,node[0],node[0],node[2],node[1],R2c(0,-w*Cgd));
 cm:=expi(-w*tau)*gm+r2c(0,-w*Cgd);
// cm:=r2c(gm,-w*Cgd);
addblk(Y,node[0],node[0],node[1],node[2],cm);
addblk(Y,node[0],node[0],node[2],node[2],R2C(gd,w*Cgd));
{addblk(Y,node[0],node[0],node[1],node[1],R2c(Ggs+Ggd,w*(Cgs+Cgd)));
addblk(Y,node[0],node[0],node[2],node[1],R2c(-Ggd,-w*Cgd));
addblk(Y,node[0],node[0],node[1],node[2],R2C(gm,-w*Cgd));
addblk(Y,node[0],node[0],node[2],node[2],R2C(gd,w*Cgd));}
end;
end;

Procedure Ttom.getN(w : double;var N : cmat);
var
 ns : double;
begin
with OP do begin
Ns:=sqrt(k4*TG*RIG)/sqrt(RIG*RIG+1/(Cgs*Cgs*w*w));
caddr(N[noiseI,node[1]],Ns);
caddr(N[noiseI,node[0]],-Ns);
ns:=sqrt(k4*TD*gd);
caddr(N[noiseI+1,node[2]],Ns);
caddr(N[noiseI+1,node[0]],-Ns);
end;
end;

end.