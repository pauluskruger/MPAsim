unit statz; 
interface
uses vectorD,complex2,FET,consts,stringe,compu,varu;

type
TstatzOP = record
  {DC parms}
  Vgs,Vds,Ids,Qgd,Qgs,Igs,Igd : double;
  {AC parm}
  gd,gm,Cgs,Cgd : double;
  end;

 Tstatz = object(Tcomp)
   vto,beta,lambda,alpha,b,temp,idstc,vbi,Is,vbr : double;
   delta,delta2,Cgs0,Cgd0,fc,vmax : double;
   noiseR,noiseP,noiseC : double;
   OP : TstatzOP;
   function calc(Vgs,Vds : double) : TstatzOP;
   constructor create(P : pointer); 
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
//   Procedure getdY(w : double;v0 : cvec;var Y : cmat); virtual;
//   Procedure getdN(w : double;v0 : cvec;var N : cmat); virtual;
   Procedure load(Np : integer;P : Tparams); virtual;
   end; 

   
 Pstatz = ^Tstatz;  


implementation
uses sysutils,sport;

constructor tstatz.create(P : pointer);
begin inherited create(P);Nnode:=3; end;

procedure writeOP(OP : TstatzOP); 
begin
with OP do begin
writeln('Vgs=',Vgs:5:1,'V Vds=',Vds:5:1,'V Ids=',Ids*1000:5:1,'mA');
write('Qgd=');writeEng(Qgd);write('C Qgs=');writeEng(Qgs);writeln('C'); 
writeln('gd=',gd*1000:5:1,'m gm=',gm*1000:5:1,' Cgs=',Cgs*1e12:5:2,'pF Cgd=',Cgd*1e12:5:2);
end;
end;

Procedure Tstatz.load(Np : integer;P : Tparams);
var
 Vds,Vgs : double;
begin
 vto:=getparm(Np,P,'VTO',-2);
 beta:=getparm(Np,P,'BETA',1e-4);
 lambda:=getparm(Np,P,'LAMBDA',0);
 alpha:=getparm(Np,P,'ALPHA',2);
 B:=getparm(Np,P,'B',0);
 temp:=getparm(Np,P,'TNOM',25+273);
 idstc:=getparm(Np,P,'IDSTC',0);
 Vbi:=getparm(Np,P,'VBI',0.85);

 delta:=getparm(Np,P,'DELTA',0.3);
 delta2:=getparm(Np,P,'DELTA2',0.2);
 Cgs0:=getparm(Np,P,'CGS',0);
 Cgd0:=getparm(Np,P,'CGD',0);

 fc:=getparm(Np,P,'FC',0.5);
 Vmax:=getparm(Np,P,'VMAX',0.5);
 Is:=getparm(Np,P,'IS',1e-14);
 Vbr:=getparm(Np,P,'VBR',1e100);

 noiseR:=getparm(Np,P,'R',0.5);
 noiseP:=getparm(Np,P,'P',1);
 noiseC:=getparm(Np,P,'C',0.9);


 Vds:=getparm(Np,P,'VDS',0);
 Vgs:=getparm(Np,P,'VGS',0);
 OP:=calc(Vgs,Vds);
 

if (temp>0) then Nnoise:=2 else Nnoise:=0;
end;

function Tstatz.calc(Vgs,Vds : double) : TstatzOP;
var
tmp1,tmp2,tmp3 : double;
Veff1,Veff2,Vnew : double;
Vt,Vgd,d1,d2,d3 : double;
 res : TstatzOP;
begin
if Vds<0 then begin
  writeln('Vds<0 not implemented!');
  halt(1);
  end;
res.Vgs:=Vgs;
res.Vds:=Vds;
with res do begin
//Calc Ids
tmp1:=Vgs-Vto;
gd:=beta*tmp1*tmp1/(1+B*tmp1);
gm:=(2*beta*tmp1-B*gd) / (1+B*tmp1);
Ids:=gd*(1+lambda*vds);
gm :=gm*(1+lambda*vds);
if Vgs<Vto then begin
   Ids:=0;
   gd:=0;
   gm:=0;
   end else begin
   if Vds<3/alpha then begin
     tmp2:=1-alpha*Vds/3;
     tmp3:=tmp2*tmp2*tmp2;
     gd:=gd*lambda*(1-tmp3)+Ids*alpha*tmp2*tmp2;
     Ids:=Ids*(1-tmp3);
     gm := gm*(1-tmp3);
     end else
      gd:=gd*lambda;
  end;
  
//Calc Cap
Vgd:=Vgs-Vds;
tmp1:=Vgs-Vgd;
tmp1:=sqrt(tmp1*tmp1+delta*delta);
Veff1:=0.5*(Vgs+Vgd+tmp1);
Veff2:=0.5*(Vgs+Vgd-tmp1);
tmp2:=veff1-Vto;
tmp2:=sqrt(tmp2*tmp2+delta2*delta2);
Vnew :=0.5*(Veff1+Vto+tmp2);
writeln('Veff1=',Veff1,' Veff2=',Veff2,' Vnew=',Vnew,' Vmax=',vmax);
if fc*vbi<vmax then vmax:=fc*vbi;
Qgd:=Cgd0*Veff2;

   {dveff1/dvgs}d1 := 0.5*(1+(vgs-vgd)/tmp1); {dveff1/dvgd}
   {dveff1/dvgd}d2 := 0.5*(1-(vgs-vgd)/tmp1); {dveff2/dvgs}
   {dvnew/deff1}d3 := 0.5*(1+(veff1-Vto)/tmp2);

if Vnew>Vmax then begin
   tmp3:=sqrt(1-vmax/vbi);
   Qgs:=Cgs0*(2*Vbi*(1-tmp3)+(Vnew-Vmax)/tmp3);
  end else begin
   tmp3:=sqrt(1-vnew/vbi);
   Qgs:=Cgs0*(2*Vbi*(1-tmp3));
  end;
 writeln('d1=',d1,' d2=',d2,' d3=',d3,' Cgs0=',Cgs0,' tmp3=',tmp3);
   Cgs:= Cgs0/tmp3*d3*d1 + Cgd0*d2;
   Cgd:= Cgs0/tmp3*d3*d2 + Cgd0*d1;

//Calc leak current
Vt:=Temp*86.17385692e-6; //Nvt=1,kT/q
if Vgs>-10*Vt then Igs:=Is*(exp(Vgs/vt)-1) 
  else  begin
   tmp1:=Is*4.539992976e-5/vt;
   Igs:=Is*(4.539992976e-5-1)+tmp1*(Vgs-10*Vt);
   if Vgs<-Vbr+50*vt then
         Igs:=Igs-Is*(exp((-vbr+vgs)/vt));
   end;

if Vgd>-10*Vt then Igd:=Is*(exp(Vgd/vt)-1) 
  else  begin
   tmp1:=Is*4.539992976e-5/vt;
   Igd:=Is*(4.539992976e-5-1)+tmp1*(Vgd-10*Vt);
   if Vgd<-Vbr+50*vt then
         Igd:=Igd-Is*(exp((-vbr+vgd)/vt));
   end;
end;
writeOP(res);
calc:=res;
end;

Procedure Tstatz.getY(w : double;var Y : cmat);
begin
with OP do begin
addblk(Y,node[0],node[0],node[1],node[1],R2c(0,w*(Cgs+Cgd)));
addblk(Y,node[0],node[0],node[2],node[1],R2c(0,-w*Cgd));
addblk(Y,node[0],node[0],node[1],node[2],R2C(gm,-w*Cgd));
addblk(Y,node[0],node[0],node[2],node[2],R2C(gd,w*Cgd));
end;
end;

Procedure Tstatz.getN(w : double;var N : cmat);
var
 V : array[0..3] of tc;
 id,ig : double;
 C : tc;
begin
with OP do begin
id:=k4*temp*gm*noiseP;
ig:=k4*temp*cgs*cgs*w*w*noiseR/gm;
C:=R2C(0,k4*temp*Cgs*w*sqrt(noiseP*noiseR)*noiseC);

ig:=sqrt(ig);
C:=C/ig; {i2 correlated with i1}
id:=sqrt(id-cabs2(C));
end;

caddR(N[noiseI  ,node[1]],ig);
caddR(N[noiseI  ,node[0]],-ig);
cadd(N[noiseI  ,node[2]],C);
cadd(N[noiseI  ,node[0]],-C);
caddR(N[noiseI+1,node[2]],id);
caddR(N[noiseI+1,node[0]],-id);
write('ig=',ig:5:3,' idu=',id:5:3,' idc=');cwrite(C);writeln; 
end;
{
Procedure Tstatz.getdY(w : double;v0 : cvec;var Y : cmat);
begin
//addblk(Y,node[0],node[0],node[1],node[1],-1/(r*r)*(V0[1]-V0[0]));
end;

Procedure Tstatz.getdN(w : double;v0 : cvec;var N : cmat);
var
 d : double;
begin
d:=-Noise/(2*r);
caddr(N[noiseDI,node[1]],d);
caddr(N[noiseDI,node[0]],-d);
end;
}
end.