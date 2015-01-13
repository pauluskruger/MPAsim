unit mstrip;
interface
type
 Tsubs = record
  er : double; //relative permeability
  B : double;  //Substrate thickness
  tand : double; //dielectric loss

  Th : double; //Conductor thickness
  SR : double; //Surface roughness
  rho : double; //conductivity
  end;
  
 Tmstrip = object
   W : double; //track width (m) + thickness correction
   name : string;
   sub : Tsubs;
   
   EeffF : double; //effective permeability
   Z0F   : double; //effective impedance
   ad    : double; //dielectric loss
   ac,Rc : double; //copper loss
   Eeff0,Z0 : double; //Effective perm, Z0 without freq effect
   Z0v : double; //Vacuum Z0
   tande : double; //effective tand
   calcf,changef : double;
   changew: boolean;
//   procedure jensen(F : double);
   procedure dloss(freq : double);
   procedure rloss(freq : double);
   procedure calc(freq : double);
//   Procedure calcZ0(freq : double);
   function calcopen(wie : pointer;Tnode : integer;w2 : double;var TC,TL : double):double ;
   Procedure setwidth(w0 : double);
   function haschanged(w2 : double) : boolean;
   end;
 Pmstrip = ^Tmstrip;

Fterm = function(wie : pointer;Tnode : integer;w2 : double;var TC,TL : double):double of object;
Pterm = ^Fterm;

Ftermchanged = function(w : double) : boolean of object;
Ptermchanged = ^Ftermchanged;

implementation
uses math;
const 
// c = 299.792; //speed of light mm/ns 
 e = 2.1718291828;
 nu = 376.73;
 pi = 3.141592654;
 c = 2.99792e8; //speed of light m/s 
 mu = 1.256637e-6;

{function jenthick(w,h,t,er : double) : double;
var
 ww : double;
begin
ww:=t/(h*pi)*ln(1+4*e/(t/h*sqr(coth(sqrt(6.517*W)))));
ww:=ww*0.5*(1+sech(sqrt(er-1)));
jenthick:=ww;
end;
}
Procedure tmstrip.setwidth(w0 : double);
begin
w:=w0;
//changef:=calcf;
changew:=true;
changef:=0;
//writeln('mstrip ',name,' width change. changef=',changef);
//dw:=Jenthich(W/1e3,sub.b,sub.th,sub.er)*1e3;
//writeln('dw=',dw);
end;

function Tmstrip.haschanged(w2 : double) : boolean;
var
 fr : double;
begin
//haschanged:=true;exit;
fr:=w2/(2*pi);
if fr<changef then changew:=false;
haschanged:=changew;
//if changew then writeln('mstrip ',name,' changed ')
//           else writeln('mstrip ',name,' NOT changed w=',w2); 
end;

function Tmstrip.calcopen(wie : pointer;Tnode : integer;w2 : double;var TC,TL : double) : double;
var
  X : double;
begin
//write('calcopen=');
X:=W/sub.B;
X:=0.102*(X+0.106)/(X+0.264)*(1.166+(1+1/sub.er)*(0.9*ln(X+2.475)));
//writeln(X*sub.B/1e3);
calcopen:=X*sub.B/1e3;
end;

function Z01(x : double) : double;
begin
Z01:=nu*ln( (6+(2*pi-6)*exp(-power(30.666/x,0.7528)))/x + sqrt(4/(x*x)+1) )/(2*pi);
end;

procedure jensen(W,F : double;sub : Tsubs;var Eeff0,Z0,EeffF,Z0F : double);

var
T : double; //ratio conductor thickness to substrate thickness
U : double; //ratio trace width to substrate thickness


P,P1,P2,P3,P4 : double; //filling factor
U1,Ur,Ur2,Au,Ber,Y : double;
begin
T:=sub.Th/sub.B;
U:=W/sub.B;

U1:=U+T*ln(1+4*e/T*sqr(tanh(sqrt(6.517*U))));
Ur:=U+(U1-U)*(1+1/cosh(sqrt(sub.er-1)))/2;

Ur2:=Ur*Ur;
Au:=1+ln( Ur2*(Ur2+1/2704)/(Ur2*Ur2+0.432) )/49+ln(Ur2*Ur/(18.1*18.1*18.1)+1)/18.7;
Ber:=0.564*power((sub.er-0.9)/(sub.er+3),0.053);
Y:=(sub.er+1)/2+(sub.er-1)/(2*power(1+10/Ur,Au*Ber));

Z0:=Z01(Ur)/sqrt(Y);
Eeff0:=Y*sqr(Z01(U1)/Z01(Ur));
//writeln('jen: Z0=',Z0,' E0=',Eeff0);
P1:=0.27488+U*(0.6315+0.525*power(0.0157*F*sub.B+1,-20))-0.065683*exp(-87513*U);
P2:=0.33622*(1-exp(-0.03442*sub.er));
P3:=0.0363*exp(-4.6*U)*(1-exp(-power(F*sub.B/38.7,4.97)));
P4:=2751*(1-exp(-power(sub.er/15.916,8)))+1;
P :=P1*P2*power(F*sub.B*(0.1844+P3*P4),1.5763); 

EeffF:=sub.Er-(sub.Er-Eeff0)/(1+P);
//writeln('jen: Z0=',Z0,' E0f=',EeffF);
if EeffF=Eeff0 then Z0F:=Z0 else
  Z0F  :=Z0*sqrt(Eeff0/EeffF)*(EeffF-1)/(Eeff0-1);
//writeln('jen: Z0F=',Z0F,' E0f=',EeffF);

end;

procedure jensenvac(W,F : double;sub : Tsubs;var Z0 : double);


var
T : double; //ratio conductor thickness to substrate thickness
U : double; //ratio trace width to substrate thickness


P,P1,P2,P3,P4 : double; //filling factor
U1,Ur,Ur2,Au,Ber,Y : double;
begin
 T:=sub.Th/sub.B;
 U:=W/sub.B;
 U1:=U+T*ln(1+4*e/T*sqr(tanh(sqrt(6.517*U))));
 Z0:=Z01(Ur);
end;

Procedure tmstrip.dloss(freq : double);
begin
tande:=(1-1/EeffF)/(1-1/sub.Er)*sub.tand;
ad:=tande*pi/(c/freq)*sqrt(EeffF);
//writeln('tand=',sub.tand,' tande=',tande);
//writeln('Er  =',sub.er  ,' EeffG=',EeffF);
end;

Procedure tmstrip.rloss(freq : double);
var
 R,Ki,Kr,del,Zf0 : double;
 subv : tsubs;
begin
subv:=sub;subv.er:=1;
//jensen(W,freq/1e9,subv,R,Zf0,Ki,Kr);
//writeln('Vac Z0=',Zf0);
del:=sqrt(sub.rho/(pi*freq*mu));
//writeln('Skindepth=',del);
R:=sub.rho/del;
//Ki:=exp(-1.2*power(Z0/Zf0,0.7));
Kr:=1+2/pi*arctan(1.4*sqr(sub.SR/del));
Rc:=R*Kr{*Ki}/(W/1e3);
//writeln('Ki=',Ki,' Kr=',Kr);
ac:=Rc/Z0;
end;

Procedure Tmstrip.calc(freq : double);
begin
if freq=calcf then exit;
if freq<changef then changew:=false;
//write('MS..');
//if freq<calcf then 
calcf:=freq;
changef:=freq*0.99999;
//changef:=freq;
//if calcf>=changef then changew:=false; 
//writeln('Mstrip ',name,' calc f=',freq,' calcf=',calcf,' changef=',changef);
jensen(W,freq/1e9,sub,Eeff0,Z0,EeffF,Z0F);
jensenvac(W,freq/1e9,sub,Z0v);
//writeln('Z0F=',Z0F);
dloss(freq);
rloss(freq);
//writeln('OK');
end;
{Procedure Tmstrip.calcZ0(freq : double);
begin
jensen(W,freq/1e9,sub,Eeff0,Z0,EeffF,Z0F);
jensenvac(W,freq/1e9,sub,Z0v);
end;}
end.