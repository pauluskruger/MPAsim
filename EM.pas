unit EM;
interface
uses compu,sport,vectorD,complex2,varu;
type
 TEM = object(Tsport)
//   S : Tsport;
//   function Nnode : integer; virtual;
//   Procedure getY(w : double;var V : cvec); virtual;
  Rad,cond,SR,temp,rm : double; //wire
  h,eps : double; //substrate
  diam,ang,ang2,dl,dw,dw2,dh : double; //loop
  ppw : integer;
  DD : array of tc;
  maxn : integer;
  constructor create(P : pointer); 
   Procedure load(Np1 : integer;P : Tparams); virtual;

  Procedure calcCRM(w : double;var c_m,r_m,l_m : double);
  Procedure makeY(w : double;var YYY : cmat); virtual;
  Procedure makeS(w : double;var SSS : cmat); virtual;
  Procedure init;

   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   end; 
PEM = ^TEM;   
   
implementation
uses consts,sysutils,math;

constructor tEM.create(P : pointer);
begin inherited create(P);Nnode:=3; end;

Procedure TEM.load(Np1 : integer;P : Tparams);
var
 x : integer;
begin
 Rad   :=getparm(Np1,P,'D',1e-3)/2;
 h     :=getparm(Np1,P,'h',1e-3);
 ang2   :=getparm(Np1,P,'ANG',360);
 diam  :=getparm(Np1,P,'DIA',10e-3);
 ppw   :=round(getparm(Np1,P,'PPW',4));
 dw2    :=getparm(Np1,P,'DW',3e-3);
 temp :=getparm(Np1,P,'TEMP',0);
 cond :=getparm(Np1,P,'COND',5.96e7);
 eps  :=getparm(Np1,P,'K',1)*8.854187817e-12;
 SR  :=getparm(Np1,P,'SR',0);
 if (temp=0) then Nnoise:=0 else Nnoise:=2;
 savedata:=true;
 maxn:=0;
 init;
 setlength(Sp,Np);setlength(xvars,0);
 for x:=0 to Np-1 do Sp[x]:=inttostr(x);
 pin.c:=nil;pout.c:=nil;
 Nprint:=0;parmn:=0;validzz:=0;
 PClayout:=nil;
 NoiseRes:=50;
 Lsavedata:=0;doinv:=false;
end;

Procedure TEM.init;
var
 x : integer;
begin
ang:=ang2/180*pi;
 Nc:=0;
 Np:=3;
 Nv:=ceil(ang/(2*pi)*ppw)+1;
 Ns:=1;
 Ni:=Nv-1; //number of inductors
 Nns:=Ni;
//writeln('ang=',ang2,' n=',nv,' nmax=',maxn);
 dl:=pi*diam/ppw;
 dw:=dw2/ppw;
 dh:=2*pi/ppw;
  
 Nt:=Np+Nv+Ni;

if (lsavedata>0) and (length(saveddata[0].YY)<Nt) then begin
// write('i');
 for x:=0 to lsavedata-1 do with saveddata[x] do begin
           CMclearsize(Np+maxn+maxn-1,YY);
	   CMclearsize(maxn,Sn);
	   end;
 setlength(saveddata,0);
 lsavedata:=0;
 end;
if length(DD)<Nv then setlength(DD,Nv);

if length(YY)<Nt then begin
 initY:=false;
 end;

 nsavedata:=0;
 
end;

Procedure TEM.calcCRM(w : double;var c_m,r_m,l_m : double);
const
 u0 = 1.256637061e-6;
var
 sd : double; //skin depth
 Kr : double; //effect of surface roughness
begin
//twin wire
 sd:=sqrt(2/(w*u0*cond));
 r_m:=1/(pi*rad*cond*sd);
if SR>1e-20 then begin
 Kr:=1+2/pi*arctan(1.4*sqr(SR/sd));
 r_m:=r_m*Kr;
 end;
l_m:=arcosh(h/rad);
//g_m:=0;
c_m:=pi*eps/l_m;
l_m:=l_m*u0/pi;
//single wire
c_m:=c_m*2;
l_m:=l_m/2;
r_m:=r_m/2;
end;

Function M_2arcw(w,R,ang,dl,h : double) : tc;
var
 ln,cs : double;
begin
//write('*');
cs:=cos(ang);
if cs>0.9999 then ln:=0 else ln:=sqrt(2*(1-cs))*R;
 ln:=sqrt(ln*ln+h*h);
//if ln<1e-12 then M_2arcw:=czero else
                 M_2arcw:=expi(w*ln/c0)*( 2e-7*dl*dl*cs / ln);
end;

Function M_2line(w : double;h,l,dl : double) : tc;
var
 l2 : double;
begin
if h>0 then l2:=sqrt(l*l+h*h) else l2:=l;
 M_2line:=expi(w*l2/c0)*(2e-7* dl*dl / l2);
// M_2line:=r2c(1,0)*( 2e-7*dl*dl / l2);
// end else
// M_2line:=r2c(1,0)*( 2e-7*dl*dl / l);
end;

function M_2line2(w : double;l,m,d,h : double) : double;
var
 a,b,g : double;
begin
 a:=l+m+h;b:=l+h;g:=m+h;
 M_2line2:=1e-7*( a*arsinh(a/d)-b*arsinh(b/d)-g*arsinh(g/d)+h*arsinh(h/d) - sqrt(a*a+d*d)+sqrt(b*b+d*d)+sqrt(g*g+d*d)-sqrt(h*h+d*d) );

end;

function L_wire_self(l,r : double) : double;
begin
 L_wire_self:=2e-7*l*( ln(2*l/r)-1 );
end;

function M_wire_par(l,d : double) : double;
begin
 M_wire_par:=2e-7*l*( ln(l/d+sqrt(1+sqr(l/d)))-sqrt(1+sqr(d/l))+d/l );
end;

function M_wire_parw(w : double;l,d : double) : tc;
begin
 M_wire_parw:=expi(d*w/c0)*M_wire_par(l,d);
// M_wire_parw:=r2c(1,0)*M_wire_par(l,d);
end;

Procedure TEM.makeY(w : double;var YYY : cmat);
const  max = 100;
var
 x,y,j : integer;
 cm,lm : double;
begin
//write('make Y');
//writeln('dw=',dw);
 for x:=0 to Nt-1 do for j:=0 to Nt-1 do YYY[x,j]:=czero;
 for x:=np to np+Ni-1 do begin
   YYY[nv+x,x]:=r2c(1,0);
   YYY[nv+x,x+1]:=r2c(-1,0);
   end;
 for x:=np to np+Ni-1 do begin
   YYY[x,nv+x]:=r2c(-1,0);
   YYY[x+1,nv+x]:=r2c(1,0);
   end;
// dl:=pi*diam*wnd/(wnd*ppw-1);
// dlc:=pi*diam/(ppw);
//writeln('CalcCRM');
 calcCRM(w,cm,rm,lm);
//end points
//   addblk(YYY,1,1,np,np,r2c(0,1/(lm*w*dl/2))); 
//   addblk(YYY,2,2,np+nv-1,np+nv-1,r2c(0,1/(lm*w*dl/2))); 
 addblk(YYY,1,1,np,np,r2c(1e6,0)); 
 addblk(YYY,2,2,np+nv-1,np+nv-1,r2c(1e6,0)); 
 //self caps
 for x:=1 to NV-2 do 
   addblk(YYY,0,0,np+x,np+x,r2c(0,cm*w*dl));
 //self ind+res
   addblk(YYY,0,0,np,np,r2c(0,cm*w*dl/2));
   addblk(YYY,0,0,np+nv-1,np+nv-1,r2c(0,cm*w*dl/2));

{ for x:=np+nv to np+nv+Ni-1 do 
   YYY[x,x]:=r2c(rm*dl,lm*w*dl);
 }
// writeln('make D');
 for x:=1 to Ni-1 do
  DD[x]:=(M_2arcw(w,diam/2,x*dh,dl,dw*x)-M_2arcw(w,diam/2,x*dh,dl,2*h))*r2c(0,w);
//  DD[x]:=(M_2line(w,0,x*dl,dl)-M_2line(w,2*h,x*dl,dl))*r2c(0,w);
//  DD[x]:=(M_2line(w,dw*x,x*dl,dl);
  DD[0]:=r2c(rm*dl,L_wire_self(dl,rad)*w)-M_wire_parw(w,dl,h*2)*r2c(0,w);
//  DD[0]:=r2c(rm*dl,L_wire_self(dl,rad)*w)-M_wire_parw(w,dl,h*2)*r2c(0,w);
// writeln('make Y');
  for x:=np+nv to np+nv+Ni-1 do
  for y:=np+nv to np+nv+Ni-1 do 
      YYY[x,y]:=DD[abs(x-y)];
//   if x=y then YYY[x,x]:=r2c(rm*dl,L_wire_self(dl,rad)*w)-M_wire_parw(w,dl,h*2)*r2c(0,w)
//          else YYY[x,y]:=(M_2line2(w,dl,dl,0,(abs(x-y)-0.9)*dl)-M_2line2(w,dl,dl,h*2,(abs(x-y)-0.9)*dl))*r2c(0,w);


rm:=rm*dl;    
//write('D ');
end;

Procedure TEM.makeS(w : double;var SSS : cmat);
const  max = 100;
var
// Y : cvec;
 z : double;
 x,{Nn,}i,j,k,Nn2 : integer;
begin
for i:=0 to Nns do for j:=0 to Nt-1 do SSS[i,j]:=czero;
z:=sqrt(rm*k4*temp);
 for x:=0 to Ni-1 do
   SSS[x+1,np+nv+x]:=r2c(z,0);
//for x:=0 to Nc-1 do comp[x]^.getS(w,SSS);
end;

function TEM.paramnum(s : string) : integer;
  begin 
  s:=uppercase(s);
  if s='ANG' then paramnum:=1 else 
  paramnum:=0;end;
function TEM.paramstr(wat : integer) : string; 
begin 
 case wat of 
  1 : paramstr:='ANG';
  else
  paramstr:='';
end;end;
function TEM.getD(wat : integer) : double; 
   begin
   case wat of 
    1 : getD:=ANG2;
    end;end;
Procedure TEM.setD(z : double;wat : integer);
   begin
   case wat of
   1 :  if ANG2<>abs(z) then begin;ANG2:=abs(z);init;end;
   end;
 end;

end. 