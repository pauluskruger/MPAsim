unit FET;
interface
uses complex2,stringe,math;

type
 sparm = array[1..4] of Tc;
 Tdata = record
    parm : Sparm;
    freq : real;
  end;
  
 Tnoise = record
   freq,Fmin,Rn : real;
   Topt : tc;
   Gn : real;
   Ycor : tc;
   n1,n2 : double;
   nC : tc;
   V0,V2,V3 : tc;
    end; 
  
transistor = object
      Re,Rc,Rb : tc;
      data : array[1..3000] of Tdata;
      noise : array[1..1000] of Tnoise;
      hoefdata,hoefNoise : integer;
      filename : string;
      procedure laaiS(leer : string);
      function kryfreq(freq : double) : sparm;
      function kryY(freq : double) : sparm;
      function kryNfreq(freq : double) : Tnoise;
      Procedure DAnoise(freq : real;var ki,ku : double;var C : tc);
      function ZZb(Sp : sparm) : Tc;
      function ZZe(Sp : sparm) : Tc;
      function ZZc(Sp : sparm) : Tc;

     Procedure Isrc(w : double;var V : array of tc);
     Procedure calcnoise(var N1 : tnoise);
  end;

Ptransistor = ^transistor;

function loadFET(s : string) : transistor;

implementation
uses consts,sysutils;
var
 FETS : array of Transistor;
 nFET : integer;

function loadFET(s : string) : transistor;
var
 x : integer;
begin
 for x:=0 to nFET-1 do if FETS[x].filename=s then begin
     loadFET:=FETS[x];
     exit;
     end;
 setlength(FETS,nFET+1);
 FETS[nFET].laaiS(s);
 loadFET:=FETS[nFET];
 inc(nFET);
end;

function inverse(Z : sparm) : sparm;
var
 res : sparm;
 Q : Tc;
begin
 Q:=1.0/(Z[1]*Z[4]-z[2]*z[3]);
 res[1]:=Z[4]*Q;
 res[2]:=-z[3]*Q;
 res[3]:=-z[2]*Q;
 res[4]:=Z[1]*Q;
 inverse:=res;
end;
  
function SnaZ(Z : sparm) : sparm;
var
 S : sparm;
 a,Z11m,z11p,z22m,z22p,onder : tc;
begin
// for i:=1 to 4 do Z[i]:=crmaal(z2[i],1/50.0);
 a:=Z[2]*Z[3];
 z11m := 1-Z[1];
 Z11p := Z[1]+1;
 z22m := 1-Z[4];
 Z22p := 1+Z[4];
 onder:=1/(z11m*z22m-a);
 S[1]:=(z11p*z22m+a)*onder;
 S[2]:=Z[2]*2*onder;
 S[3]:=Z[3]*2*onder;
 S[4]:=(z11m*z22p+a)*onder;
 SnaZ:=S;
end;

function SnaY(S : sparm) : sparm;
var 
 Y : sparm;
 onder : tc;
begin
 onder:=(1+S[1])*(1+S[4])-S[2]*S[3];
 onder:=1/50/onder;
 Y[1]:=(S[2]*S[3]+(1-S[1])*(1+S[4]))*onder;
 Y[4]:=(S[2]*S[3]+(1+S[1])*(1-S[4]))*onder;
 Y[2]:=S[2]*onder*(-2);
 Y[3]:=S[3]*onder*(-2);
 SnaY:=Y;
end;


Procedure Nparam2RG(var Rn,Gn : double;var Ycor : tc;x,y : real;A : tc);
var
 Ymin : tc;
begin
 Ymin:=(1-A)/(1+A)/50;
// Cwrite(Ymin*1000);writeln;
// x:=(power(10,(x/10))-1);
// writeln('Fmin=',x);
 Rn:=y{*50};
 if Rn=0 then Ycor:=czero else 
 if Rn<0 then begin
  Gn:=-1;
  rn:=-rn;
  Ycor:=czero;
  end else begin
   Ycor[1]:=x/(2*Rn)-Ymin[1];
   Ycor[2]:=-Ymin[2];
//   Cwrite(Ycor*1000);writeln;
   Gn:=(sqr(Ymin[1])-sqr(Ycor[1]))*Rn;
   if Gn<0 then Gn:=0;
  end;
// writeln({freq:3:1,}' Rn=',Rn:3:1,' Gn=',Gn*1e3:6:4,'Gcor=',Ycor[1]*1e3:6:4,' Bcor=',Ycor[2]*1e3:6:4,' fmin=',2*(rn*Ycor[1]+sqrt(rn*gn+sqr(Rn*Ycor[1]))):6:4);
end;

Procedure transistor.calcnoise(var N1 : tnoise);
var
// N : tnoise2;
 i,u : double;
 Y : sparm;
begin
with N1 do begin
Y:={SnaY}(kryfreq(freq));
 Nparam2RG(Rn,Gn,Ycor,Fmin,Rn,Topt);
u:=sqrt(k4*Rn*290);
if Gn<0 then begin
 V0:=czero;
 V2:=czero;
 V3:=-r2c(u,0);//*Y[2];
 end else begin
 i:=sqrt(k4*Gn*290);
 V0:=r2c(i,0);
 V2:=u*Ycor-u*Y[1];
 V3:=-r2c(u,0)*Y[2];
 end;
n1:=sqrt(cabs2(V0)+cabs2(V2));
n2:=sqrt(cabs2(V3));
nc:=V2*ccomp(V3);
end;end;

Procedure transistor.Isrc(w : double;var V : array of tc);
var
 Y : sparm; 
// N : Tnoise2;
 N1 : tnoise;
 i,u,A : double;
// Cor : tc;
 x : integer;
begin
//write('Isrc; ');
w:=w/twopi/1e9;
//write('kryfreq; ');
Y:={SnaY}(kryfreq(w));
//write('kryNfreq; ');
N1:=kryNfreq(w);
//with N1 do Nparam2RG(N,Fmin,Rn,Topt);
with N1 do begin
// Nparam2RG(Rn,Gn,Ycor,Fmin,Rn,Topt);
//write('N1=',N1,' N2=',N2,' NC=');cwrite(NC);writeln;
{ A:=N1*N1-cabs2(NC)/(N2*N2);
 if A<=0 then V[0]:=czero else V[0]:=r2c(sqrt(N1*N1-cabs2(NC)/(N2*N2)),0);
 V[1]:=czero;
 V[2]:=NC/N2;
 V[3]:=r2c(N2,0);
write('Inoise=');
for x:=0 to 3 do cwrite(V[x]);writeln;}
//Ycor:=Y[1]-nC/rn/ccomp(Y[2]);
//write('Rn=',Rn,' Gn=',Gn,' Ycor=');cwrite(Ycor);writeln;
 u:=sqrt(k4*Rn*290);
 if Gn<0 then begin
    V[0]:=czero;
    V[1]:=czero;
    V[2]:=czero;
    V[3]:=-r2c(u,0)*Y[2];
   end else begin
    i:=sqrt(k4*Gn*290);
    V[0]:=r2c(i,0);
    V[1]:=czero;
    V[2]:=u*Ycor-u*Y[1];
    V[3]:=-r2c(u,0)*Y[2];
    end;
{write('Inoise=');
for x:=0 to 3 do cwrite(V[x]);writeln;}
// V[2]:=V[2]/V[3]*sqrt(cabs2(v[3]));
// V[3]:=r2c(sqrt(cabs2(V[3])),0); 
 //V[0]:=V0;
 //V[1]:=czero;
 //V[2]:=V2;
 //V[3]:=V3;
end;
//write('Inoise=');
//for x:=0 to 3 do cwrite(V[x]);writeln;

//Cor:=V[0]*V[1]+V[2]*V[3];
//Cor:=Cor/sqrt( (cabs2(V[0])+cabs2(V[2])) * (cabs2(V[1])+cabs2(V[3])));
//write('Cor=');cwrite(Cor); 
//write('Y=');
//for x:=1 to 4 do cwrite(Y[x]);writeln;
end;

function par(A,B : tc) : tc;
begin  par:=A*B/(A+B); end;

Procedure Transistor.DAnoise(freq : real;var ki,ku : double;var C : tc);
{var
 Y : Sparm;
 N1 : Tnoise;
 N : Tnoise2;
 x : integer;
 Cgs,C1,w : double;
 Zin,Zin2,ZL,ZLC,Zuit,Zt : tc;
 Zloss,L : tc;
 kig,kir,kug,kur : tc;
 X1,XF : tc;
 vv,vg : tc;
 Zu,Zi,onder,L2 : double;
}begin
{Zu:=1;
Zi:=50;

{Y:=kryfreq(freq);
for x:=1 to 4 do cwrite(Y[x]);
writeln;
}
Y:={SnaY}(kryfreq(freq));
{for x:=1 to 4 do cwrite(Y[x]);
writeln;
}
N1:=kryNfreq(freq);
//cwrite(N1.Topt);writeln(N1.fmin:6:4);
w:=freq*2*pi*1e9;
with n1 do Nparam2RG(N,Fmin,Rn,Topt);
with N do begin
Cgs:=1e-12;
C1:=10e-12;
X1:=R2C(0,-1/(W*C1));
X1:=R2C(0,0);

Zin:=1/(Y[1]+Zu*Y[2]*Y[3]/(2-Y[4]*Zu));
Y[1,2]:=Y[1,2]-w*Cgs;
Zin2:=1/(Y[1]+Zu*Y[2]*Y[3]/(2-Y[4]*Zu));

XF:=R2C(0,-1/(W*Cgs));
ZL:=par(R2C(Zi/2,0),-X1-Xf);
ZLC:=ZL+X1;
Zuit:=par(ZLC,Xf); //Impedansie as vanaf hek kyk na intree voerlyn
Zt:=par(Zin,ZLC);

//Vg:=zt*I
//I=sqrt(gn)+(Ycor-1/Zin)sqrt(Rn)
Vv:=Zt*ZLC/(ZLC+X1);
//I-bron na v-bron, v-bron na voerlyn. Sein v2=kTBZi vs i2=4kTBGn
kig:=2/sqrt(Zi)*{vv=}Zl/(Zlc+Zin)*{v=}Zin*sqrt(gn);
//I-bron na v-bron - vbron
kir:=2/sqrt(Zi)*Zl/(Zl+x1+Zin)*sqrt(rn)*(Ycor*Zin-1);

vg:=Zin/(Zin+ZLC);//*V=ZLC*sqrt(gn)+(ZLC*Ycor+1)sqrt(Rn)
cwrite((Zin)/Zt);writeln;
write('Zin=');cwrite(Zin);writeln;
write('ZL =');cwrite( ZL);writeln;
write('ZLC=');cwrite(ZLC);writeln;
write('Zt =');cwrite( Zt);writeln;
write('Vv =');cwrite( vv);writeln;
//vgs = Zin / (Zin + X1) sqrt(kTBZi)
//Vgi = Zin / (Zin + ZLc)* ZLC * sqrt(4kTBGn)
//I-bron na v-bron, verg vg a.g.v. sein
kug:=2/sqrt(Zi)*(Zin+X1)/(Zin+Zlc)*{v=}ZLC*sqrt(gn);
kur:=2/sqrt(Zi)*(Zin+X1)/(Zin+Zlc)*(ZLC*Ycor+1)*sqrt(Rn);

ki:=sqrt(cabs2(kig)+cabs2(kir));
ku:=sqrt(cabs2(kug)+cabs2(kur));

C:=(kig*kug+kir*kur)/(ki*ku);

write(' kir=');cwrite(kir/ki);
write(' kig=');cwrite(kig/ki);writeln;
write(' kur=');cwrite(kur/ku);
write(' kug=');cwrite(kug/ku);writeln;
write(' ki=',ki:5:2,' ku=',ku:5:2,' C=');cwrite(C);
writeln;
writeln('Tg=',ki*ki*290:5:1);
writeln('Td=',ku*ku*290:5:1);

//loss
Zloss:=par(par(Zin+X1,-X1-Xf),R2C(Zi,0));
L:=2*Zloss/(Zloss+Zi);
L2:=sqrt(cabs2(L));
write('L=',L2:8:4,' = ');cwrite(l);writeln;
//halt;
end;}
end;

procedure Transistor.laaiS(leer : string);
var
  f : text;
  s : string;
  s2 : Tstrings;
  vv,ii : string;
  x,y : real;
  d : integer;
  A : tc;
  freqfac : double;
  db : boolean;
begin
 assign(f,leer);
 filename:=leer;
{$i-}
 reset(f);
{$i+}
if ioresult<>0 then begin
 writeln('Can''t load ',leer);
 halt(1);
 end;
 writeln('Load: ',leer);
 hoefdata:=0;hoefnoise:=0;
 freqfac:=1;db:=false;
 while not(eof(f)) do begin
      readln(f,s);
      if (s<>'') and (s[1]='#') then begin
        s:=uppercase(s);
        if pos('GHZ',s)>0 then freqfac:=1e9;
        if pos('MHZ',s)>0 then freqfac:=1e6;
	if pos('DB',s)>0 then db:=true;
	//writeln('freqfac=',freqfac);
	//if db then writeln('DB');  
        end;
      subs(s,#9,' ');
      s2:=strtostrs(s);
      //writeln('l=',len(s2));
      if (s='') or (s[1]='!') then else
      if len(s2)=2 then begin
            vv:=s2[1];
            ii:=s2[2];
            end else
      if len(s2)=5 then begin
        inc(hoefnoise);
	with noise[hoefnoise] do begin
         val(s2[3],x,d); val(s2[4],y,d); Topt:=rh2c(x,y/180*pi);
	 val(s2[2],x,d); Fmin:=power(10,x/10)-1;
	 val(s2[5],y,d); Rn:=y*50;
	 val(s2[1],freq,d);
	 freq:=freq*(freqfac/1e9);
        end;
	calcnoise(noise[hoefnoise]);
	end else
      if len(s2)>=11 then begin
             inc(hoefdata);
             with data[hoefdata] do begin
	         val(s2[2],x,d);if db then x:=power(10,(x/20)); val(s2[3],y,d); parm[1]:=rh2c(x,y/180*pi);
		 //write('-',s2[2],'-',x,'    ');
	         val(s2[5],x,d);if db then x:=power(10,x/20); val(s2[6],y,d); parm[2]:=rh2c(x,y/180*pi);
		 val(s2[8],x,d);if db then x:=power(10,x/20); val(s2[9],y,d); parm[3]:=rh2c(x,y/180*pi);
		  val(s2[10],x,d);if db then x:=power(10,x/20); val(s2[11],y,d); parm[4]:=rh2c(x,y/180*pi);
		  val(s2[1],freq,d);
                   freq:=freq*(freqfac/1e9);
		  parm:=SnaY(parm);
		  //    V:=vv;i:=ii;
		   end;
             end else
      if len(s2)>=9 then begin
             inc(hoefdata);
             with data[hoefdata] do begin
	         val(s2[2],x,d);if db then x:=power(10,x/20);val(s2[3],y,d); parm[1]:=rh2c(x,y/180*pi);
		 //write('-',s2[2],'-',x,'    ');
	         val(s2[4],x,d);if db then x:=power(10,x/20); val(s2[5],y,d); parm[2]:=rh2c(x,y/180*pi);
		 //writeln('p2=',parm[2,1],' x=',x,' y=',y,' hd=',hoefdata);
		 val(s2[6],x,d);if db then x:=power(10,x/20); val(s2[7],y,d); parm[3]:=rh2c(x,y/180*pi);
		  val(s2[8],x,d);if db then x:=power(10,x/20); val(s2[9],y,d); parm[4]:=rh2c(x,y/180*pi);
		  val(s2[1],freq,d);
		  freq:=freq*(freqfac/1e9);

		  parm:=SnaY(parm);
		  //    V:=vv;i:=ii;
		   end;
             end;
      end;
  close(f);
//if hoefnoise=0 then nnoise:=0;
//  writeln('loaded: S = ',hoefdata);
//  writeln('        N = ',hoefnoise);
end;

function transistor.kryfreq(freq : double) : sparm;
var
 min,max,i : integer;
 P1,P2,P : sparm;
 w,w1,w2 : double;
begin
 min:=0;

 while (min<hoefdata) and (data[min+1].freq<=freq) do inc(min);
 max:=hoefdata+1;
 while (max>1) and (data[max-1].freq>=freq) do dec(max);
// writeln('min=',min,' max=',max);

 if min=0          then kryfreq:=data[1].parm else
 if max=hoefdata+1 then kryfreq:=data[hoefdata].parm else
 if min>=max        then kryfreq:=data[min].parm else
   begin
    P1:=data[min].parm;
    P2:=data[max].parm;
    w:=data[max].freq-data[min].freq;
    w1:=(data[max].freq-freq)/w;
    w2:=(freq-data[min].freq)/w;
    for i:=1 to 4 do
      P[i]:=P1[i]*w1+P2[i]*w2;
    kryfreq:=P;
   end;
end;
Function transistor.kryY(freq : double) : sparm;
var
 S : sparm;
 x : integer;
begin
S:=kryfreq(freq/1e9);
//writeln('freq=',freq/1e9,'GHz');
//S:=SnaY(S);
kryY:=S;
//for x:=1 to 4 do cwrite(S[x]);writeln;
//writeln('done');
end;

function Cinter(C1,C2 : tc;w1,w2 : double) : tc;
begin
Cinter:=C1*w1+C2*w2;
end;

function transistor.kryNfreq(freq : double) : Tnoise;
var
 min,max,i : integer;
 P1,P2,P : Tnoise;
 w,w1,w2,tmp : double;
 Z : Tnoise;
begin
 min:=0;
 Z.freq:=freq;
 while (min<hoefnoise) and (noise[min+1].freq<=freq) do inc(min);
 max:=hoefnoise+1;
 while (max>1) and (noise[max-1].freq>=freq) do dec(max);
 if min=0          then kryNfreq:=noise[1] else
 if max=hoefnoise+1 then kryNfreq:=noise[hoefnoise] else
 if min>=max        then kryNfreq:=noise[min] else
   with z do begin
    w:=noise[max].freq-noise[min].freq;
    w1:=(noise[max].freq-freq)/w;
    w2:=(freq-noise[min].freq)/w;
    P1:=noise[min];
    P2:=noise[max];
//    Fmin:=p1.Fmin*w1+p2.Fmin*w2;
//    Rn:=p1.Rn*w1+p2.Rn*w2;
    Topt:=p1.Topt*w1+p2.Topt*w2;
// V0:=p1.V0*w1+p2.V0*w2;
// V2:=p1.V2*w1+p2.V2*w2;
//V3:=p1.V3*w1+p2.V3*w2;
 N1:=p1.N1*w1+p2.N1*w2;
 N2:=p1.N2*w1+p2.N2*w2;
 NC:=czero;
 if P1.N1>0 then NC:=NC+p1.NC*w1/(p1.N1*p1.N2);
 if P2.N1>0 then NC:=NC+p2.NC*w2/(p2.N1*p2.N2);
 NC:=Nc*N1*N2;

 Rn:=p1.Rn*w1+p2.Rn*w2;
 Fmin:=p1.Fmin*w1+p2.Fmin*w2;
// Gn:=p1.Gn*w1+p2.Gn*w2;
// Ycor:=p1.Ycor*w1+p2.Ycor*w2;
 Ycor:=(p1.Ycor*w1*p1.Rn+p2.Ycor*w2*P2.Rn)/Rn;
with p1 do tmp:=w1*sqrt(Gn*Rn+sqr(Rn*Ycor[1]));
with p2 do tmp:=tmp+w2*sqrt(Gn*Rn+sqr(Rn*Ycor[1]));
 Gn:=(sqr(tmp)-sqr(Rn*Ycor[1]))/Rn;
 kryNfreq:=z;
   end;
end;

{
function transistor.kryN2freq(freq : double) : Tnoise2;
var
 min,max,i : integer;
 P1,P2,P : Tnoise;
 w,w1,w2 : double;
 Z : Tnoise;
begin
//with N1 do Nparam2RG(N,Fmin,Rn,Topt);
 min:=0;
 Z.freq:=freq;
 while (min<hoefnoise) and (noise[min+1].freq<=freq) do inc(min);
 max:=hoefnoise+1;
 while (max>1) and (noise[max-1].freq>=freq) do dec(max);
 if min=0          then kryNfreq:=noise[1] else
 if max=hoefdata+1 then kryNfreq:=noise[hoefdata] else
 if min>=max        then kryNfreq:=noise[min] else
   with z do begin
    w:=noise[max].freq-noise[min].freq;
    w1:=(noise[max].freq-freq)/w;
    w2:=(freq-noise[min].freq)/w;
    P1:=noise[min];
    P2:=noise[max];
    Fmin:=p1.Fmin*w1+p2.Fmin*w2;
    Rn:=p1.Rn*w1+p2.Rn*w2;
    Topt:=p1.Topt*w1+p2.Topt*w2;
    kryNfreq:=z;
   end;
end;
}
function form1(zb,ze,S11,S12,S21,S22 : TC) : Tc;
const
 w = 1;
var
 a,b,c,d,v,i : Tc;
begin
 a:= (zb+ze-w)-S11*(zb+ze+w)-S12*ze;
 b:= Ze - S11*(Ze) - S12*(Ze+w);
 c:= Ze - S21*(Zb+Ze+w)-S22*(Ze);
 d:= Ze-w-S21*(Ze)-S22*(Ze+w);
 V:=B*C - D*A;
 I:=S12*C - A*(S22-1);
 form1:=V/I;
end;

function form2(zb,zc,S11,S12,S21,S22 : Tc) : Tc;
const
 w = 1;
var
 x1,x2,x3,x4,a,b,c,d,v,i : Tc;
begin
 x1:=w-Zb;
 x2:=-w-zb;
 x3:=Zc+w;
 x4:=Zc-w;
 b :=x1-S11*x2;
 //
    //(-zb+W)-S11(-Zb-w) 
 a :=b-S12*x3;
    //(-zb+W)-S11(-Zb-w)-S12(Zc+w)
 d :=S21*(Zb+w);
 c :=x4-S21*x2-S22*x3;   //  (Zx-w)-S21(-Zb-w)-S22(Zc+w)
 V := A*D - B*C;
 I := C*(S11+S12-1) - A*(S21+S22-1);
 form2:=V/I;
end;

function ZnaS(Z : sparm) : sparm;
var
 S,S2 : sparm;
 a,Z11m1,z11p1,z22m1,z22p1,onder : tc;
 i : integer;
begin 
 a:=Z[2]*Z[3];
 z11m1 := Z[1]-1;
 Z11p1 := Z[1]+1;
 z22m1 := Z[4]-1;
 Z22p1 := Z[4]+1;
 onder:=1/(z11p1*z22p1-a);
 S[1]:= (z11m1*z22p1-a)*onder;
 S[2]:= Z[2]*2*onder;
 S[3]:= Z[3]*2*onder;
 S[4]:=(z11p1*z22m1-a)*onder;
 ZnaS:=S;
end;



function transistor.ZZb(Sp : sparm) : tc;
begin
 ZZb:=form1(Rc,Re,sp[4],sp[3],sp[2],sp[1]);
end;


function transistor.ZZe(Sp : sparm) : tc;
begin
 ZZe:=form2(Rb,Rc,sp[1],sp[2],sp[3],sp[4]);
end;


function transistor.ZZc(Sp : sparm) : tc;
begin
 ZZc:=form1(Rb,Re,sp[1],sp[2],sp[3],sp[4]);
end;
function Z12naZ13(Z : sparm) : sparm;
var
 res : sparm;
begin
 res[1]:=Z[4]+Z[1]-(Z[2]+Z[3]);
 res[2]:=Z[4]-Z[2];
 res[3]:=Z[4]-Z[3];
 res[4]:=Z[4];
 Z12naZ13:=res;
end;



{var
 NE : transistor;
 ki,ku : double;
 C : tc;
begin
 NE.laaiS('atf38143l.s2p');
 NE.DAnoise(1,ki,ku,C);
 write('ki=',ki*1000:5:3,'k ku=',ku:3:2,' C=');cwrite(C);writeln;
}
begin
 nFET:=0;
end.