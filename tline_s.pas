unit tline_s; 
interface
uses vectorD,complex2,FET,consts,stringe,compu,savedata,tline_a,varu;

type
   
 Ttwire = object(Ttline3)
    d,h,eps : double;
   ang : double; //implemented only footprint!
    
   Procedure calcLCRG(w : double;var gm,Y0 : tc;var g_m,r_m,dl : double); virtual;

   Procedure load(Np1 : integer;P : Tparams); virtual;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   function getFoot(var wt,par : string;var pars : integer) : boolean; virtual;
   end; 
      
 Ptwire = ^Ttwire;

implementation
uses sysutils,sport,math;

Procedure Ttwire.load(Np1 : integer;P : Tparams);
begin
 d    :=getparm(Np1,P,'D',0.5e-3);
 h    :=getparm(Np1,P,'H',1e-3);
 cond :=getparm(Np1,P,'COND',5.96e7);
 eps  :=getparm(Np1,P,'K',1)*8.854187817e-12;
 len  :=getparm(Np1,P,'LEN',1e-3);
 temp :=getparm(Np1,P,'TEMP',0);
 ang    :=getparm(Np1,P,'ANG',0.5e-3);
 SR  :=getparm(Np1,P,'SR',0);
 if (temp=0) then Nnoise:=0 else Nnoise:=2;
 Save.init(2,nnoise-1);
 CMsetsize(2,2,YY);
 CMsetsize(nnoise,nnoise,NN);
end;

Procedure Ttwire.calcLCRG(w : double;var gm,Y0 : tc;var g_m,r_m,dl : double);
const
 u0 = 1.256637061e-6;
var
 sd : double; //skin depth
 Kr : double; //effect of surface roughness
begin
//twin wire
 sd:=sqrt(2/(w*u0*cond));
 r_m:=2/(pi*d*cond*sd);
if SR>1e-20 then begin
 Kr:=1+2/pi*arctan(1.4*sqr(SR/sd));
 r_m:=r_m*Kr;
 end;
l_m:=arcosh(2*h/d);
//g_m:=pi*cond/l_m;
g_m:=0;
c_m:=pi*eps/l_m;
l_m:=l_m*u0/pi;
//single wire
c_m:=c_m*2;
//g_m:=g_m*2;
l_m:=l_m/2;
r_m:=r_m/2;
// writeln('cm=',c_m,' rm=',r_m,' lm=',l_m);
 gm:=csqrt( R2c(r_m,w*l_m)*r2c(g_m,w*C_m) );
 Y0:=csqrt( R2c(g_m,w*c_m)/r2c(r_m,w*l_m) );
 dl:=0;
// writeln('h=',h,' d=',d);
// write('c_m=',c_m*1e12:3:3,'pF/m l_m=',l_m*1e9:3:3,'nH/m r_m=',r_m,'ohm/m g_m=',g_m,' 1/mOhm w=',w,' Z0=');cwriteEng(cinv(Y0));writeln;
//// alpha:=r_m*Y0[1]/sqrt(w);
// alpha:=gm[2]/0.11512;
// alpha:=alpha/0.11512926*sqrt(1e9*twopi);
// writeln('alpha=',alpha);
end;

function Ttwire.paramnum(s : string) : integer;
  begin 
  s:=uppercase(s);
   if s='D' then paramnum:=1 else 
   if s='H' then paramnum:=2 else
   if s='LEN' then paramnum:=3 else
    paramnum:=0;
  end;
function Ttwire.paramstr(wat : integer) : string; 
begin
 case wat of 
 1 : paramstr:='D';
 2 : paramstr:='H';
 3 : paramstr:='LEN';
 else paramstr:='';
 end;
end;

function Ttwire.getD(wat : integer) : double; 
   begin 
   case wat of
    1 : getD:=D;
    2 : getD:=H;
    3 : getD:=LEN;
     end;
    end;
Procedure Ttwire.setD(z : double;wat : integer);
var
 diff : boolean;
 begin 
 diff:=false;
   case wat of
    1 : if D<>abs(z) then begin;D:=abs(z);diff:=true;end;
    2 : if H<>abs(z) then begin;H:=abs(z);diff:=true;end;
    3 : if LEN<>abs(z) then begin;LEN:=abs(z);diff:=true;end;
    end;
 if diff then save.clear;
 end;

function Ttwire.getFoot(var wt,par : string;var pars : integer) : boolean; 
begin
pars:=2;
getFoot:=true;
if ang=0 then begin
 wt:='MS';
 par:='LEN='+name+':LEN W1='+name+':D';
 end else begin
 wt:='MSBEND';
 par:='LEN='+name+':LEN W='+name+':D ANG='+floattostr(ang);
 end;
end;

end.