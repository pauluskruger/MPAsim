unit tline_ms; 
interface
uses vectorD,complex2,FET,consts,stringe,compu,savedata,mstrip,varu,tline_a;

type
 Tmsstep = object
   Cs,calcw1,calcw2 : double;
   L : array[1..2] of double;
   AMS : array[1..2] of pmstrip;
   ac : array[1..2] of pcomp;
//   nodes : array[1..2] of integer;
   procedure calc(w : double);
   function stepcalc(wie : pointer;Tnode : integer;w2 : double;var TC,TL : double):double;
   end;
         
 Tmstrip3 = object(Ttline3)
  MS : Tmstrip;
  term1,term2 : Fterm;
  term1changed,term2changed : Ftermchanged;
  TC1,TC2,TL1,TL2 : double; //termination caps and inds
  ang : double; //implemented only footprint!
//  l_m,c_m : double;
  open : integer;
  step : array[1..2] of Tmsstep;
  Procedure calcLCRG(w : double;var gm,Y0 : tc;var g_m,r_m,dl : double); virtual;
  Procedure calcNY(w : double); virtual;
  Procedure load(Np1 : integer;P : Tparams); virtual;
  function paramnum(s : string) : integer; virtual;
  function paramstr(wat : integer) : string; virtual;
  function getD(wat : integer) : double; virtual;
  Procedure setD(z : double;wat : integer); virtual;
  function getFoot(var wt,par : string;var pars : integer) : boolean; virtual;
  Procedure exportQucs(var ff : text); virtual;
  Procedure exportVars(var f : text;prnt : string);virtual;

  
   end; 

 TmstripR = object(Tmstrip3)
  R : double;
  discrete : boolean;
  Procedure calcLCRG(w : double;var gm,Y0 : tc;var g_m,r_m,dl : double); virtual;
  Procedure load(Np1 : integer;P : Tparams); virtual;
  function paramnum(s : string) : integer; virtual;
  function paramstr(wat : integer) : string; virtual;
  function getD(wat : integer) : double; virtual;
  Procedure setD(z : double;wat : integer); virtual;
  Procedure exportQucs(var ff : text); virtual;
  Procedure exportVars(var f : text;prnt : string);virtual;
   end; 


 Tmcorner = object(Tcomp)
   Wd,b,er : double;
   vorm : byte;
   L,C : double;
  constructor create(P : pointer); 
  Procedure load(Np1 : integer;P : Tparams); virtual;
  Procedure calc;
  Procedure getY(w : double;var Y : cmat); virtual;
  function paramnum(s : string) : integer; virtual;
  function paramstr(wat : integer) : string; virtual;
  function getD(wat : integer) : double; virtual;
  Procedure setD(z : double;wat : integer); virtual;
  function getFoot(var wt,par : string;var pars : integer) : boolean; virtual;
  Procedure exportQucs(var ff : text); virtual;
   end; 

 TmTee = object(Tcomp)
  LL : array[1..3] of double;
  Ta,Tb,Bt : double;
  AMS : array[1..3] of Pmstrip;
  nodei : array[0..2] of integer;
  nodeC : array[1..3] of pointer;
  calcw : double;
  layoutstr : string;
  YY : cvec;
  Save : Tsave2;

  constructor create(P : pointer); 
  Procedure load(Np1 : integer;P : Tparams); virtual;
  Procedure calc(w : double);
  Procedure getY(w : double;var Y : cmat); virtual;
  function getFoot(var wt,par : string;var pars : integer) : boolean; virtual;

  function calclen(wie : pointer;Tnode : integer;w2 : double;var TC,TL : double):double ;
  function haschanged(w2: double) : boolean;
  Procedure exportQucs(var ff : text); virtual;
   end; 

 TmGap = object(Tcomp)
  AMS : array[1..2] of Pmstrip;
  h,gap,w1,w2 : double;
  Cs,cp1,cp2 : double;
  constructor create(P : pointer); 
  Procedure load(Np1 : integer;P : Tparams); virtual;
  Procedure calc(w : double);
  Procedure getY(w : double;var Y : cmat); virtual;
   end; 

 Tmvia = object(Tcomp)
   h,rad,t,wd,rpad,R0,rho,tmp,l,er,cap : double;
   constructor create(P : pointer); 
   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
   Procedure load(Np : integer;P : Tparams); virtual;
   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   function getFoot(var wt,par : string;var pars : integer) : boolean;  virtual;
  Procedure exportQucs(var ff : text); virtual;
   Procedure exportVars(var f : text;prnt : string);virtual;
   end; 

   
 Pmcorner = ^Tmcorner;
 Pmstrip3 = ^Tmstrip3;
 PmstripR = ^TmstripR;
 PmTee = ^TmTee;
 PmGap = ^TmGap;
 Pmvia = ^Tmvia;
 
implementation
uses sysutils,sport,math;



Procedure Tmstrip3.load(Np1 : integer;P : Tparams);
var
 x,y : integer;
 c : pcomp;
begin
// writeln('Z0=',Z0F:0:1,'   e=',EeffF:0:3,' ad=',ad:0:5,' ac=',ac:0:5);
MS.name:=name;
with MS do begin
 with sub do begin
   er  :=getparm(Np1,P,'ER',2.2);
   B   :=getparm(Np1,P,'B',0.78e-3)*1e3;
   tand:=getparm(Np1,P,'TAND',0.0009);
   Th  :=getparm(Np1,P,'TH',0.017e-3)*1e3;
   SR  :=getparm(Np1,P,'SR',0.4e-6);
   rho :=getparm(Np1,P,'RHO',1.72e-8);
 end;
 setwidth(getparm(Np1,P,'W',1e-3)*1e3);
 end;
 temp :=getparm(Np1,P,'TEMP',0);
 ANG :=getparm(Np1,P,'ANG',0);
 len  :=getparm(Np1,P,'LEN',1e-3);
 term1:=nil;
 term2:=nil;
 term1changed:=nil;
 term2changed:=nil;
 open :=round(getparm(Np1,P,'OPEN',0));
 if open and 1=1 then term1:=@MS.calcopen;
 if open and 2=2 then term2:=@MS.calcopen;
step[1].AC[1]:=nil;
step[2].AC[1]:=nil;
for x:=0 to length(P)-1 do 
 if (P[x].name='M1') or (P[x].name='M2') then begin
     c:=Psport(parent)^.findcomp2(P[x].value);
     if (c=nil) then begin;writeln('Can not find component ',P[x].value);halt(1);end;
     if (c^.tiepe<>'TMS') then begin;writeln('Can not find microstrip ',P[x].value);halt(1);end;
     y:=ord( P[x].name[2] )-ord('0');
     with step[y] do begin
       calcw1:=0;
       AC[1]:=@self;
       AC[2]:=c;
        AMS[1]:=@MS;
        AMS[2]:=@(Pmstrip3(c)^.MS);
        case y of 
          1 : begin;term1:=@stepcalc;term1changed:=@AMS[2]^.haschanged;end;
          2 : begin;term2:=@stepcalc;term2changed:=@AMS[2]^.haschanged;end;
        end;
//        nodes[1]:=node[y];
//        if node[y]=Pmstrip3(c)^.node[1] then nodes[2]:=node[y] else
//        if node[y]=Pmstirp3(c)^.node[2] then nodes[2]:=node[y] else
//          node[y]:=Pmstrip3(c)^.node[1];
     if (parent<>Pmstrip3(c)^.parent) or 
        (node[y]=Pmstrip3(c)^.node[1]) then with Pmstrip3(c)^ do begin;term1:=@stepcalc;term1changed:=@AMS[1]^.haschanged;end else
     if (node[y]=Pmstrip3(c)^.node[2]) then with Pmstrip3(c)^ do begin;term2:=@stepcalc;term2changed:=@AMS[1]^.haschanged;end else
                                   begin; with Pmstrip3(c)^ do begin;term1:=@stepcalc;term1changed:=@AMS[1]^.haschanged;end;
                                          writeln('MS ',name,': Can not find common node, asuming first node!');halt(1);end;
    end;//with step
//     writeln('Loading port ',y,' connected to ',c^.name);
//     writeln('Set MS');
    end;

 
 if (temp=0) then Nnoise:=0 else Nnoise:=2;
// Nnoise:=0;
// calcLCR;
 save.init(2,nnoise-1);
 CMsetsize(2,2,YY);
 CMsetsize(nnoise,nnoise,NN);
end;

Procedure Tmstrip3.exportQucs(var ff : text);
var
 s1,s2 : string;
begin
with MS.sub do
 writeln(ff,'SUBST:Subst_',name,' er="',er,'" h="',B,' mm" t="',th,' mm" tand="',tand,'" rho="',rho,'" D="',SR,'"');
s1:=expnode(node[1]);
s2:=expnode(node[2]);
if step[1].AC[1]=@self then with step[1] do begin
  writeln(ff,'MSTEP:',name,'_S1 ',s1,'_X1 ',s1,' Subst="Subst_',name,'" W1="',AMS[1]^.w,' mm" W2="',AMS[2]^.w,' mm" MSModel="Hammerstad" MSDispModel="Kirschning"');
  s1:=s1+'_X1';
  end;
if step[2].AC[2]=@self then with step[1] do begin
  writeln(ff,'MSTEP:',name,'_S2 ',s2,'_X2 ',s2,' Subst="Subst_',name,'" W1="',AMS[1]^.w,' mm" W2="',AMS[2]^.w,' mm" MSModel="Hammerstad" MSDispModel="Kirschning"');
  s2:=s2+'_X2';
  end;
writeln(ff,'MLIN:',name,' ',s1,' ',s2,' Subst="Subst_',name,'" W="',MS.w,' mm" L="',len,'" Model="Hammerstad" DispModel="Kirschning" Temp="26.85"');
if open and 1=1 then writeln(ff,'MOPEN:',name,'_O1 ',expnode(node[1]),' Subst="Subst_',name,'" W="',MS.w,' mm" MSModel="Hammerstad" MSDispModel="Kirschning" Model="Kirschning"');
if open and 2=2 then writeln(ff,'MOPEN:',name,'_O2 ',expnode(node[2]),' Subst="Subst_',name,'" W="',MS.w,' mm" MSModel="Hammerstad" MSDispModel="Kirschning" Model="Kirschning"');
end;

Procedure Tmstrip3.exportVars(var f : text;prnt : string);
begin
writeln(f,prnt+name+':LEN=',len);
writeln(f,prnt+name+':W=',MS.w/1000);
end;

Procedure Tmstrip3.calcLCRG(w : double;var gm,Y0 : tc;var g_m,r_m,dl : double);
var
al,bl : double;
tmp : tc;
begin
//writeln('Mstrip calcLCRG... freq=',w/2/pi(),' w=',MS.w,' l=',len);
MS.calc(w/(2*pi));
//write('a');
Z0:=MS.Z0F;
k:=MS.EeffF;
//alpha:=0;
c_m:=sqrt(k)/(Z0*c0);
l_m:=(z0*z0)*c_m;
r_m:=MS.RC;
//(MS.ad+MS.ac)*Z0;
 g_m:=MS.tande*(w*c_m);

//writeln('c/m=',c_m,' l/m=',l_m,' r/m=',r_m,' g/m=',g_m);
//writeln('l_m*w=',w*L_m);
//writeln(' r/m=',r_m,' g/m=',g_m);
//gm:=r2c(alpha,w/c0*sqrt(k));
 gm:=csqrt( R2c(r_m,w*l_m)*r2c(g_m,w*C_m) );
 Y0:=csqrt( R2c(g_m,w*c_m)/r2c(r_m,w*l_m) );
// Y0:= gm/r2c(r_m,w*l_m) ;
 tmp:=cinv(Y0);
//writeln('Z0=',Z0,' Zl=',tmp[1],'+i',tmp[2]);
dl:=0;TC1:=0;TC2:=0;TL1:=0;TL2:=0;
//writeln('Mstrip terms: ',word(term1),';',word(term2));
if term1<>nil then dl:=dl+term1(@self,node[1],w,TC1,TL1);
if term2<>nil then dl:=dl+term2(@self,node[2],w,TC2,TL2);
//writeln('Done');
//if open then dl:=MS.calcopen else dl:=0;
//writeln('MS ',name,' calcLCRG: dl=',dl,' TC1=',TC1,' TC2=',TC2,' TL1=',TL1,' TL2=',TL2);
end;

Procedure Tmstrip3.calcNY(w : double);
var  
g_m,r_m,dl : double;
gm,Y0,XL,A : tc;
begin
if ((term1changed<>nil) and term1changed(w)) or 
   ((term2changed<>nil) and term2changed(w)) or
    not(save.getsaved(w,YY,NN)) then begin
// writeln('MS ',name,': calc');
 calcLCRG(w,gm,Y0,g_m,r_m,dl);
 calcY(w,gm,Y0,g_m,r_m,dl);
 if TL1<>0 then begin
   XL:=r2c(1,-1/(w*TL1));
   A:=cinv(YY[0,0]+XL);
   YY[1,1]:=YY[1,1]-A*YY[0,1]*YY[1,0];
   YY[1,0]:=YY[1,0]*XL*A;
   YY[0,1]:=YY[0,1]*XL*A;
   YY[0,0]:=XL*(1-XL*A);
   end;
 if TL2<>0 then begin
   XL:=r2c(1,-1/(w*TL2));
   A:=cinv(YY[1,1]+XL);
   YY[0,0]:=YY[0,0]-A*YY[0,1]*YY[1,0];
   YY[1,0]:=YY[1,0]*XL*A;
   YY[0,1]:=YY[0,1]*XL*A;
   YY[1,1]:=XL*(1-XL*A);
   end;
 if TC1<>0 then YY[0,0]:=YY[0,0]+r2c(0,w*TC1);
 if TC2<>0 then YY[1,1]:=YY[1,1]+r2c(0,w*TC2);

 if nnoise=2 then save.savedata(w,YY,NN)
             else save.savedata(w,YY,YY); 
 end;
end;

procedure Tmsstep.calc(w : double);
var
 w1,w2,er,LW1,LW2,Ls : double;
 swap : boolean;
 i : integer;
begin
//write('C');
 w1:=AMS[1]^.w/1e3;
 w2:=AMS[2]^.w/1e3;
 if (w1=calcw1) and (w2=calcw2) then exit;
 calcw1:=w1;calcw2:=w2;
 for i:=1 to 2 do AMS[i]^.calc(w/(2*pi));
//write('D');
 with AMS[1]^ do LW1:=Z0*sqrt(Eeff0)/c0;
 with AMS[2]^ do LW2:=Z0*sqrt(Eeff0)/c0;
 swap:=w2>w1;
 if swap then begin
   er:=w1;w1:=w2;w2:=er;
   end;
 er:=AMS[1]^.sub.er;
 Cs:=1e-12*sqrt(w1*w2)*( (10.1*log10(er)+2.33)*w1/w2 - 12.6*log10(er) - 3.17 );
 Ls:=40.5*(W1/W2-1)-75*log10(W1/W2)+0.2*sqr(w1/w2-1);
 Ls:=1e-9*AMS[1]^.sub.B/1e3*Ls;
 if Cs<0 then Cs:=0;
 L[1]:=LW1/(LW1+LW2)*Ls;
 L[2]:=LW2/(LW1+LW2)*Ls;
//write('E');
// writeln('MS step : calc w1=',w1,'w2=',w2,' Cs=',Cs,' L1=',L[1],' L2=',L[2]);
end;

function Tmsstep.stepcalc(wie : pointer;Tnode : integer;w2 : double;var TC,TL : double):double ;
var
 b : integer;
begin
if (ac[1]=wie) then b:=1 else 
if (ac[2]=wie) then b:=2 else begin;writeln('stepcalc error!');halt(1);end;
 calc(w2);
 TL:=L[b];
 TC:=Cs/2;
// writeln('MS step: stepcalc side=',b,' w=',w2,' L=',Tl,' C=',Tc);
 stepcalc:=0;
end;

function Tmstrip3.paramnum(s : string) : integer;
  begin 
  s:=uppercase(s);
   if s='W' then paramnum:=1 else 
   if s='LEN' then paramnum:=2 else
   if s='T1' then paramnum:=10 else
   if s='T2' then paramnum:=11 else
    paramnum:=0;
  end;
function Tmstrip3.paramstr(wat : integer) : string; 
begin
 case wat of 
 1 : paramstr:='W';
 2 : paramstr:='LEN';
 10 : paramstr:='T1';
 11 : paramstr:='T2';
 else paramstr:='';
 end;
end;

function Tmstrip3.getD(wat : integer) : double; 
   begin 
   case wat of
    1 : getD:=MS.W/1e3;
    2 : getD:=LEN;
    10 : if term1=nil then getD:=0 else if term1=@MS.calcopen then getD:=1 else getD:=2;
    11 : if term2=nil then getD:=0 else if term2=@MS.calcopen then getD:=1 else getD:=2;
     end;
    end;
Procedure Tmstrip3.setD(z : double;wat : integer);
var
 diff : boolean;
 begin 
 diff:=false;
   case wat of
    1 : if MS.W<>abs(z)*1e3 then begin;MS.setwidth(abs(z)*1e3);diff:=true;end;
    2 : if len<>abs(z) then begin;len:=abs(z);diff:=true;end;
    end;
 if diff then save.clear;
 end;

function Tmstrip3.getFoot(var wt,par : string;var pars : integer) : boolean; 
begin
pars:=2;
getFoot:=true;
if ang=0 then begin
 wt:='MS';
 par:='LEN='+name+':LEN W1='+name+':W T1='+name+':T1 T2='+name+':T2';
 end else begin
 wt:='MSBEND';
 par:='LEN='+name+':LEN W='+name+':W ANG='+floattostr(ANG)+' T1='+name+':T1 '+name+':T2=T2';
//FP:MSBEND:FTL1  a2b a1a  Len=TL1:LEN W1=TL1:W ANG=10
 end;
end;


Procedure TmstripR.load(Np1 : integer;P : Tparams);
var
 x,y : integer;
 c : pcomp;
begin
inherited load(Np1, P);
discrete:=getparm(Np1,P,'DISCRETE',0)=1;
 R :=getparm(Np1,P,'R',100);
 if discrete then R:=getkode(R);
end;

Procedure TmstripR.exportQucs(var ff : text);
begin
with MS.sub do
 writeln(ff,'SUBST:Subst_',name,' er="',er,'" h="',B,' mm" t="',th,' mm" tand="',tand,'" rho="',rho,'" D="',SR,'"');
writeln(ff,'R:',   name,'_R1 ',expnode(node[1]),' _',name,'_1 R="',R/3,' Ohm" Temp="26.85" Tc1="0.0" Tc2="0.0" Tnom="26.85"');
writeln(ff,'MLIN:',name,'_1  _',name,'_1 _',         name,'_2 Subst="Subst_',name,'" W="',MS.w,' mm" L="',len/2,'" Model="Hammerstad" DispModel="Kirschning" Temp="26.85"'); 
writeln(ff,'R:',   name,'_R2 _',name,'_2 _',         name,'_3 R="',R/3,' Ohm" Temp="26.85" Tc1="0.0" Tc2="0.0" Tnom="26.85"');
writeln(ff,'MLIN:',name,'_2  _',name,'_3 _',         name,'_4 Subst="Subst_',name,'" W="',MS.w,' mm" L="',len/2,'" Model="Hammerstad" DispModel="Kirschning" Temp="26.85"'); 
writeln(ff,'R:',   name,'_R3 _',name,'_4 ',expnode(node[2]),' R="',R/3,' Ohm" Temp="26.85" Tc1="0.0" Tc2="0.0" Tnom="26.85"');
end;
Procedure TmstripR.exportVars(var f : text;prnt : string);
begin
writeln(f,prnt+name+':LEN=',len);
writeln(f,prnt+name+':W=',MS.w/1000);
//writeln(f,prnt+name+':R=',R);
writeln(f,prnt+name+':RS=',R/len*MS.w/1000);
end;

Procedure TmstripR.calcLCRG(w : double;var gm,Y0 : tc;var g_m,r_m,dl : double);
begin
 inherited calcLCRG(w,gm,Y0,g_m,r_m,dl);
 r_m:=R/(len+dl);
 gm:=csqrt( R2c(r_m,w*l_m)*r2c(g_m,w*C_m) );
 Y0:=csqrt( R2c(g_m,w*c_m)/r2c(r_m,w*l_m) );
end;

function TmstripR.paramnum(s : string) : integer;
  begin 
  s:=uppercase(s);
   if s='W' then paramnum:=1 else 
   if s='LEN' then paramnum:=2 else
   if s='R' then paramnum:=3 else
   if s='DISCRETE' then paramnum:=4 else
    paramnum:=0;
  end;
function TmstripR.paramstr(wat : integer) : string; 
begin
paramstr:=inherited paramstr(wat);
 case wat of 
 1 : paramstr:='W';
 2 : paramstr:='LEN';
 3 : paramstr:='R';
 4 : paramstr:='DISCRETE';
 else paramstr:='';
 end;
end;

function TmstripR.getD(wat : integer) : double; 
   begin 
   case wat of
    1 : getD:=MS.W/1e3;
    2 : getD:=LEN;
    3 : getD:=R;
    4 : if discrete then getD:=1 else getD:=0;
     end;
    end;
Procedure TmstripR.setD(z : double;wat : integer);
var
 diff : boolean;
 begin 
 diff:=false;
   case wat of
    1 : if MS.W<>abs(z)*1e3 then begin;MS.setwidth(abs(z)*1e3);diff:=true;end;
    2 : if len<>abs(z) then begin;len:=abs(z);diff:=true;end;
    3 : begin
      if discrete then z:=getkode(abs(z));
      if R<>z then begin;r:=z;diff:=true;end;
      end;
    4 : begin
      discrete:=round(z)=1;
      if discrete then r:=getkode(abs(r));
      diff:=true;
      end;      
    end;
 if diff then save.clear;
 end;

constructor Tmcorner.create(P : pointer); 
  begin inherited create(P);Nnode:=3; end;


Procedure Tmcorner.load(Np1 : integer;P : Tparams);
begin
   er  :=getparm(Np1,P,'ER',2.2);
   B   :=getparm(Np1,P,'B',0.78e-3);
   wd:=getparm(Np1,P,'W',1e-3);
   vorm:=round(getparm(Np1,P,'TYPE',0));
   nnoise:=0;
  calc;
end;

Procedure Tmcorner.exportQucs(var ff : text);
begin
//with MS.sub do
// writeln(ff,'SUBST:Subst_',name,' er="',er,'" h="',B,' mm" t="',th,' mm" tand="',tand,'" rho="',rho,'" D="',SR,'"');
 writeln(ff,'SUBST:Subst_',name,' er="',er,'" h="',B,'" t="0.017 mm" tand="9e-4" rho="1.72e-8" D="4e-7"');
writeln(ff,'MCORN:',name,' ',expnode(node[1]),' ',expnode(node[2]),' Subst="Subst_',name,'" W="',wd,'"');
end;

Procedure Tmcorner.calc;
begin
  case vorm of
   0 : begin
      L:=220*b*(1-1.35*exp(-0.18*power(wd/b,1.39)));
      C:=Wd*((10.35*er+2.5)*wd/b+(2.6*er+5.64));
      end;
   1 : begin
      L:=440*b*(1-1.062*exp(-0.177*power(wd/b,0.947)));
      C:=wd*((3.93*er+0.62)*wd/b+(7.6*er+3.8));
     end;
end;
L:=L*1e-9;
C:=C*1e-12;
//writeln('Bend: L=',L,' C=',C);
end;


Procedure Tmcorner.getY(w : double;var Y : cmat);
var
 Y11,Y12,Z12,Z11 : tc;
begin
//L:=1e-9;
//C:=1e-12;
Z12:=r2c(0,-1/(w*C));
Z11:=r2c(0,w*L-1/(w*C));
Y11:=cinv(Z11*Z11-Z12*Z12);
Y12:=-Z12*Y11;
Y11:=Z11*Y11;
  addblk(Y,node[0],node[0],node[1],node[1],Y11);
  addblk(Y,node[0],node[0],node[1],node[2],Y12);
  addblk(Y,node[0],node[0],node[2],node[1],Y12);
  addblk(Y,node[0],node[0],node[2],node[2],Y11);
end;
  
  function Tmcorner.paramnum(s : string) : integer;
  begin 
  s:=uppercase(s);
   if s='W' then paramnum:=1 else 
    paramnum:=0;
  end;
  function Tmcorner.paramstr(wat : integer) : string; 
begin
 case wat of 
 1 : paramstr:='W';
 else paramstr:='';
 end;
end;
  function Tmcorner.getD(wat : integer) : double; 
   begin 
   case wat of
    1 : getD:=Wd;
     end;
    end;
  Procedure Tmcorner.setD(z : double;wat : integer); 
var
 diff : boolean;
 begin 
 diff:=false;
   case wat of
    1 : if Wd<>abs(z) then begin;wd:=abs(z);diff:=true;end;
    end;
 if diff then calc;
 end;


function Tmcorner.getFoot(var wt,par : string;var pars : integer) : boolean; 
begin
pars:=2;
getFoot:=true;
 wt:='MSCNR';
 par:='W1='+name+':W';
//FP:MSCNR:MD E F W1=0.55e-3 dir=-1  layer=1
end;

constructor TmTee.create(P : pointer); 
  begin inherited create(P);Nnode:=4; end;


Procedure TmTee.load(Np1 : integer;P : Tparams);
var
 c : pcomp;
 x,y : integer;
 
begin
//writeln('Tee load..');
for x:=1 to 3 do AMS[x]:=nil;
layoutstr:='';
for x:=0 to length(P)-1 do 
 if (P[x].name='M1') or (P[x].name='M2') or (P[x].name='M3') then begin
     layoutstr:=layoutstr+'W'+P[x].name[2]+'='+P[x].value+':W ';
     c:=Psport(parent)^.findcomp2(P[x].value);
     if (c=nil) then begin;writeln('Can not find component ',P[x].value);halt(1);end;
     if (c^.tiepe<>'TMS') then begin;writeln('Can not find microstrip ',P[x].value);halt(1);end;
     y:=ord( P[x].name[2] )-ord('0');
//     writeln('Loading port ',y,' connected to ',c^.name);
     nodeC[y]:=c;
     if node[y]=Pmstrip3(c)^.node[1] then with Pmstrip3(c)^ do begin;term1:=@calclen;term1changed:=@haschanged;end else
     if node[y]=Pmstrip3(c)^.node[2] then with Pmstrip3(c)^ do begin;term2:=@calclen;term2changed:=@haschanged;end else
                                   begin; with Pmstrip3(c)^ do begin;term1:=@calclen;term1changed:=@haschanged;end;
                                          writeln('TEE ',name,': Can not find common node, asuming first node!');end;
//     writeln('Set MS');
      AMS[y]:=@(Pmstrip3(c)^.MS);
    end;
//writeln('All?');
for x:=1 to 3 do if AMS[x]=nil then begin;writeln('Microstrip ',x,' not spesified!');halt(1);end;
   nnoise:=0;
//   setlength(nodei,3);
   nodei[0]:=Psport(parent)^.getnodei(uppercase(name)+'_1');
   nodei[1]:=Psport(parent)^.getnodei(uppercase(name)+'_2');
   nodei[2]:=Psport(parent)^.getnodei(uppercase(name)+'_3');
//writeln('Done!');
calcw:=-1;
save.init(4);
setlength(yy,4);
end;

Procedure Tmtee.exportQucs(var ff : text);
var
 x : integer;
begin
with AMS[1]^.sub do
 writeln(ff,'SUBST:Subst_',name,' er="',er,'" h="',B,' mm" t="',th,' mm" tand="',tand,'" rho="',rho,'" D="',SR,'"');
write(ff,'MTEE:',name,' ',expnode(node[1]),' ',expnode(node[2]),' ',expnode(node[3]),' Subst="Subst_',name,'"');
for x:=1 to 3 do write(ff,' W',x,'="',AMS[x]^.w,' mm"');
writeln(ff,' MSModel="Hammerstad" MSDispModel="Kirschning" Temp="26.85"');
end;


Procedure TmTee.calc(w : double);
const 
 Z0 = 376.73;
var
 DD,Z,d : array[1..3] of double;
 fp,l : array[1..2] of double;
 DDa,DDb,DD2,R,Q,da,db,d2 : double;
 h,ZF0,er : double;
 x,n0 : integer;
begin
//write('c');
if calcw=-1 then begin
  with psport(parent)^ do n0:=np+nv;
  for x:=0 to 2 do nodei[x]:=nodei[x]+n0;
  end;
if calcw=w then exit;
//writeln('Tee ',name,': calc w=',w);
calcw:=w;
w:=w/(2*pi);
for x:=1 to 3 do AMS[x]^.calc(w);
//write('Tee calc...');
h:=AMS[3]^.sub.B/1e3;
er:=AMS[3]^.sub.er;
for x:=1 to 3 do begin
 Z[x] :=AMS[x]^.Z0F;
// Z0[x]:=AMS[x]^.Z0v;
 DD[x]:=Z0*h /( sqrt(AMS[x]^.EeffF)*Z[x] );
// writeln('   Z',x,'=',Z[x],' D',x,'=',DD[x]);
 end;
//write('D'); 
for x:=1 to 2 do begin
 fp[x]:=4e5*Z[x]/h;
 l[x]:=c0/( sqrt(AMS[x]^.EeffF)*w );
 d[x]:=0.055*DD[3]*Z[x]/Z[3]*(1-2*Z[x]/Z[3]*sqr(w/fp[x]));
// writeln('fp',x,'=',fp[x],' Z',x,'=',Z[x],' Z3=',Z[3],' d',x,'=',d[x]);
 if d[x]<0 then d[x]:=0;
 LL[x]:=0.5*AMS[3]^.w/1e3-d[x];
//  writeln('   LL',x,'=',LL[x],' fp',x,'=',fp[x],' d',x,'=',d[x],' l',x,'=',l[x]);
 end;
//write('L'); 

R:=sqrt(Z[1]*Z[2])/Z[3];
Q:=w*w/(fp[1]*fp[2]);
//write('Q'); 

d[3]:=sqrt(DD[1]*DD[2])*( 0.5-R*(0.05+0.7*exp(-1.6*R)+0.25*R*Q-0.17*ln(R)) );
if AMS[1]^.w>AMS[2]^.w then LL[3]:=0.5*AMS[1]^.w/1e3-d[3]
                       else LL[3]:=0.5*AMS[2]^.w/1e3-d[3];
//writeln('   LL3=',LL[3],' d3=',d[3],'  R=',R,'  Q=',Q);
//write('D');
Ta:=1-pi*(w/fp[1])*(1/12*sqr(Z[1]/Z[3])+sqr(0.5-d[3]/DD[1]));
Tb:=1-pi*(w/fp[2])*(1/12*sqr(Z[2]/Z[3])+sqr(0.5-d[3]/DD[2]));
//write('Ta=',Ta,' Tb=',Tb,' ');
if (Ta<0) or (Tb<0) then begin;{write('*');}Bt:=1e6;Ta:=1;Tb:=1;exit;end;
Ta:=sqrt(Ta);
Tb:=sqrt(Tb);
//write('B');
//write('DD1=',DD[1],' DD2=',DD2,' DD3=',DD[3],' l1=',l[1],' l2=',l[2],' d1=',d[1],' d2=',d[2],' d3=',d[3],' Ta=',Ta,' Tb=',Tb,' R=',R,' Q=',Q);
Bt:=5.5*sqrt(DD[1]*DD[2]/(l[1]*l[2]))*(er+2)*sqrt(d[1]*d[2])/( er*(Z[3]*Ta*Tb)*dd[3] ) * ( 1+0.9*ln(R)+4.5*R*Q-4.4*exp(-1.3*R)-20*sqr(Z[3]/Z0) );
//write('Bt=',Bt);
//writeln(' Ta=',Ta,' Tb=',Tb,' Bt=',Bt,' LL1=',LL[1],' LL2=',LL[2],' LL3=',LL[3]);
if abs(Bt)<1e-6 then BT:=1e6 else Bt:=-1/Bt;  
//write('E');
ta:=1/ta;
tb:=1/tb;
//writeln('O');
end;

function TmTee.calclen(wie : pointer;Tnode : integer;w2 : double;var TC,TL : double):double ;
var
 x : integer;
begin
//writeln('calclen');
if Haschanged(w2) then
 if  not(save.getsaved(w2,YY)) then begin
  calc(w2);
   YY[0]:=r2c(Bt,0);
   YY[1]:=r2c(ta,tb);
   YY[2]:=r2c(LL[1],LL[2]);
   YY[3]:=r2c(LL[3],0);
//   writeln('save');
   save.savedata(w2,YY);
   end else begin
   LL[1]:=YY[2,1];   LL[2]:=YY[2,2];
   LL[3]:=YY[3,1];   Bt:=YY[0,1];
   ta:=YY[1,1];      Tb:=YY[1,2];
   end;
//writeln('res');
for x:=1 to 3 do if nodeC[x]=wie then begin;
  calclen:=LL[x];
//  writeln('Tee ',name,': calclen port=',x,' Len=',LL[x],' w=',w2);
  end;
end;

function TmTee.haschanged(w2 : double) : boolean;
begin
//if ams[1]^.haschanged(w2) or ams[2]^.haschanged(w2) or ams[3]^.haschanged(w2) then writeln('Tee has changed') else writeln('Tee has NOT changed');
//haschanged:=ams[1]^.haschanged(w2) or ams[2]^.haschanged(w2) or ams[3]^.haschanged(w2);
//haschanged:=true;
end;

Procedure TmTee.getY(w : double;var Y : cmat);
var
 x,n0 : integer;
begin
if Haschanged(w) or not(save.getsaved(w,YY)) then begin
   calc(w);
   YY[0]:=r2c(Bt,0);
   YY[1]:=r2c(ta,tb);
   YY[2]:=r2c(LL[1],LL[2]);
   YY[3]:=r2c(LL[3],0);
   save.savedata(w,YY);
   end else begin
   Bt:=yy[0,1];
   ta:=yy[1,1];
   tb:=yy[1,2];
   LL[1]:=yy[2,1];
   LL[2]:=yy[2,2];
   LL[3]:=yy[3,1];
   end;
//for x:=0 to 2 do writeln('nodei ',x,'=',nodei[x]);
//for x:=0 to 3 do writeln('node  ',x,'=',node[x]);
//write('Y');
for x:=0 to 2 do begin
  n0:=nodei[x];
  caddr(Y[n0,node[0]],-1);
  caddr(Y[n0,node[x+1]],1);
  caddr(Y[node[x+1],n0],-1);
  end;
caddc(Y[nodei[0],nodei[0]],ta*ta*Bt);
caddc(Y[nodei[1],nodei[1]],tb*tb*Bt);
caddc(Y[nodei[2],nodei[2]],Bt);

caddc(Y[nodei[0],nodei[1]],ta*tb*Bt);
caddc(Y[nodei[1],nodei[0]],ta*tb*Bt);

caddc(Y[nodei[0],nodei[2]],ta*Bt);
caddc(Y[nodei[2],nodei[0]],ta*Bt);

caddc(Y[nodei[1],nodei[2]],tb*Bt);
caddc(Y[nodei[2],nodei[1]],tb*Bt);

end;

function TmTee.getFoot(var wt,par : string;var pars : integer) : boolean;
begin
//FP:MSTEE:FTB2  a2a a2b a2c W1=TL2:W W2=TL1:W W3=TS2:W dir=1
wt:='MSTEE';
//par:='W1='+AMS[1]^.name+':W W2='+AMS[2]^.name+':W W3='+AMS[3]^.name+':W';
par:=layoutstr;
pars:=2;
getFoot:=true;
end;

  
constructor TmGap.create(P : pointer); 
begin inherited create(P);Nnode:=3; end;


Procedure TmGap.load(Np1 : integer;P : Tparams);
var
 c : pcomp;
 x,y : integer;
begin
//writeln('Tee load..');
for x:=2 to 3 do AMS[x]:=nil;
for x:=0 to length(P)-1 do 
 if (P[x].name='M1') or (P[x].name='M2') then begin
     c:=Psport(parent)^.findcomp(P[x].value);
     if (c=nil) then begin;writeln('Can not find component ',P[x].value);halt(1);end;
     if (c^.tiepe<>'TMS') then begin;writeln('Can not find microstrip ',P[x].value);halt(1);end;
     y:=ord( P[x].name[2] )-ord('0');
//     if (node[y]<>Pmstrip3(c)^.node[1]) and (node[y]<>Pmstrip3(c)^.node[2]) then begin;writeln('Can not find common node!');halt(1);end;
      AMS[y]:=@(Pmstrip3(c)^.MS);
    end;
for x:=1 to 2 do if AMS[x]=nil then begin;writeln('Microstrip ',x,' not spesified!');halt(1);end;
   nnoise:=0;
 gap :=getparm(Np1,P,'GAP',0);
w1:=-1;
//save.init(2);
//setlength(yy,2);
end;

Procedure TmGap.calc(w : double);
const 
 ZL = 376.73;
var
Q1,Q2,Q3,Q4,Q5,z1,z2 : double;
x : integer;
swap : boolean;
begin
//write('Gap calc');
if (w1=AMS[1]^.w/1e3) and (w2=AMS[2]^.w/1e3) then exit;
//writeln('w1=',AMS[1]^.w/1e3,'-',w1,' w2=',AMS[2]^.w/1e3,'-',w2);
if w1<>AMS[1]^.w/1e3 then AMS[1]^.calc(w);
if w2<>AMS[2]^.w/1e3 then AMS[2]^.calc(w);
w1:=AMS[1]^.w/1e3; w2:=AMS[2]^.w/1e3;
swap:=w1>w2;
if swap then begin;Q1:=w1;w1:=w2;w2:=Q1;end;
h:=AMS[1]^.sub.b/1e3;
Q5:=1.23/(1+0.12*power(w2/w1-1,0.9));
Q4:=exp(-0.5978*power(w1/w2,1.35))-0.55;
Q3:=exp(-0.5978*power(w2/w1,1.35))-0.55;
Q2:=0.107*(W1/h+9)*power(gap/h,3.23)+2.09*power(gap/h,1.05)*(1.5+0.3*w1/h)/(1+0.6*w1/h);
Q1:=0.04598*(0.03+power(w1/h,Q5))*(0.272+0.07*AMS[1]^.sub.er);
Cs:=1e-12*500*h*exp(-1.86*gap/h)*Q1*(1+4.19*(1-exp(-0.785*sqrt(h/W1)*W2/W1)));
Cp1:=AMS[1]^.calcopen(AMS[1],0,w,z1,z2)*sqrt(AMS[1]^.Eeff0)/(c0*Zl)*(Q2+Q3)/(Q2+1);
Cp2:=AMS[2]^.calcopen(AMS[2],0,w,z1,z2)*sqrt(AMS[2]^.Eeff0)/(c0*Zl)*(Q2+Q4)/(Q2+1);
if swap then begin;Q1:=CP1;CP1:=CP2;CP2:=Q1;Q1:=w1;w1:=w2;w2:=Q1;end;
//writeln('Gap Cs=',Cs*1e15:0:0,'fF Cp1=',cp1*1e15:0:0,'fF Cp2=',cp2*1e15:0:0,'fF');
//YY[0]:=r2c(cs,0);
//YY[1]:=r2c(cp1,cp2);
//save.savedata
//writeln('OK');
end;


Procedure TmGap.getY(w : double;var Y : cmat);
var
 cx : tc;
begin
calc(w);
addblk(Y,node[1],node[1],node[2],node[2],r2c(0,w*cs));
addblk(Y,node[0],node[0],node[1],node[1],r2c(0,w*cp1));
addblk(Y,node[0],node[0],node[2],node[2],r2c(0,w*cp2));
end;

  

constructor Tmvia.create(P : pointer);
begin inherited create(P);Nnode:=2; end;

Procedure Tmvia.load(Np : integer;P : Tparams);
var
 s : string;
 x : integer;
begin
h:=getparm(Np,P,'B',1e-3);
h:=getparm(Np,P,'THICK',h);
rad:=getparm(Np,P,'D',1e-3)/2;

t:=getparm(Np,P,'TH',0);
rpad:=getparm(Np,P,'RPAD',0.2e-3);
er:=getparm(Np,P,'ER',0);
rho:=getparm(Np,P,'RHO',1.72e-8);
if t>0 then begin
  R0:=rho*h/(6.283195*rad*t);
  wd:=rho/(t*t)*1.5915494e6; //2/u0
//  writeln('R0=',R0,' wd=',wd);
  end;
//writeln('r0=',r0,' wd=',wd);
tmp:=getparm(Np,P,'TEMP',0);
if (tmp>0) and (t>0) then Nnoise:=1 else Nnoise:=0;
l:=sqrt(rad*rad+h*h);
//writeln('l=',l);
l:=2e-7*( h*ln((h+l)/rad)+1.5*(rad-l) );
//writeln('Via r=',rad,' h=',h,' l=',l);
cap:=2.781625e-12*rpad*(2*rad+rpad)/h*er;
end;
Procedure Tmvia.exportQucs(var ff : text);
begin
writeln(ff,'SUBST:Subst_',name,' er="',er,'" h="',h,' " t="',t,'" rho="',rho,'" tand="0.0002" D="0.15e-6"');
writeln(ff,'MVIA:',name,' ',expnode(node[1]),' ',expnode(node[0]),' Subst="Subst_',name,'" D="',rad*2,'" Temp="26.85"'); 
end;
Procedure Tmvia.exportVars(var f : text;prnt : string);
begin
writeln(f,prnt+name+':D=',rad*2);
end;

Procedure Tmvia.getY(w : double;var Y : cmat);
var c : tc;
r : double;
begin
   if t>0 then begin
       r:=R0*sqrt(1+w/wd); 
       c:=1/r2c(r,w*L) 
       end 
       else c:=r2c(0,-1/(w*L));
c[2]:=c[2]+w*cap;
   addblk(Y,node[0],node[0],node[1],node[1],c);
end;

Procedure Tmvia.getN(w : double;var N : cmat);
var  rn : double;
r : double;
begin
r:=R0*sqrt(1+w/wd); 
 rn:=sqrt(k4*tmp*r/cabs2(r2c(r,w*L)));
 caddr(N[noiseI,node[1]],rn);
 caddr(N[noiseI,node[0]],-rn);
end;


function Tmvia.paramnum(s : string) : integer;
  begin if uppercase(s)='D' then paramnum:=1 else 
        if uppercase(s)='THICK' then paramnum:=2 else
        if uppercase(s)='RPAD' then paramnum:=3 else paramnum:=0;end;

function Tmvia.paramstr(wat : integer) : string; 
begin if wat=1 then paramstr:='D' else 
      if wat=2 then paramstr:='THICK' else 
      if wat=3 then paramstr:='RPAD' else 
      paramstr:='';end;

function Tmvia.getD(wat : integer) : double; 
   begin case wat of 
    1 : getD:=rad*2;
    2 : getD:=h;
    3 : getD:=rpad;
 end;end;
 
Procedure Tmvia.setD(z : double;wat : integer);
   begin case wat of 
   1 : rad:=z/2;
   2 : h:=z;
   3 : rpad:=z;
   end;
  l:=sqrt(rad*rad+h*h);
  l:=2e-7*( h*ln((h+l)/rad)+1.5*(rad-l) );
cap:=2.781625e-12*rpad*(2*rad+rpad)/h*er;
 end;

function TmVia.getFoot(var wt,par : string;var pars : integer) : boolean;
begin
wt:='MVIA';
par:='D='+name+':D RPAD='+name+':RPAD';
pars:=2;
getFoot:=true;
end;


end.