unit sport;
interface
uses baseunix,complex2,vectorD,stringe,compu,sysutils,varu;

const
 printSN=15;
 printS : array[0..printSN] of string=('SIGNAL','NOISE','TEMP','Y','Z','REFLECT','GAIN','ZIN1','NCOR','TEMPA','ZIN2','M4','AM4','NP','S','YM4');
 optmax = 99;
type   
Tparm = record
 C : Pvars;
 W : integer;
 end;
Toutvar = record
 node,refnode,wat,RI : integer;
 oldw : double;
 oldv,oldv2 : tc;
 varnm : string;
 comp : Pcomp;
 end;
Tprint = record
 name : string;
 f : text;
 N : integer;
 plt : integer;
 vars : array of Toutvar;
 end;
Toptdata2 = record
  N : integer;
  F,D : array of double;
  end;
Tset = record
 name,value : string;
 end;
Tsavedata = record
   freq : double;
   YY,SN,DSN : cmat;
   end;
   Tsport = object(Tcomp)
   cktname : string;
   Nc,  {number of child components}
   Ndc, {number of diff variables}
   Nset,{number of set vars}
//LHS
   Np,  {number of nodes}
   Nv,  {number internal v}
   Ni,  {number extra vars}
   Nt,  {Np+Nv+Ni=vector length}
//RHS
   Ns,  {number of internal sources}
   Nns, {number of internal noise sources}
   Ndns, {number of internal diff sources} 

   Nprint {number of print lines}  : integer;
   Nsavedata,Lsavedata {number of savedata}: integer;
   initY : boolean;
   Sp : array of string; //Node names
   Spi : array of string;//Ekstra var names
   comp : array of Pcomp;  {len=Nc}
   Dcomp : array of Tdvar;{len=Ndc}
//Matrikse
   YY {LHS = Nt x Nt},
   YYI {max(NT,SN) x Nt},
   SN{RHS = Nns+1 x Nt},
   DSN {SN}: cmat;
   currentw : double; //frek in YY / SN
   work,work2,work3,ZZ,YZ : cvec; //work vector Nt*Nt
   saveddata : array of Tsavedata;
   doinv : boolean; //Solve by inversion (true) or direct (false - default)
   Print : array of Tprint; {len=Np}
   Sets : array of Tset; {len=Nset}
   NoiseRes : double;
   Pnodes : array[0..3,0..1] of integer;
//optim
//   opvar,opvar2,opvar3,opvar4,opvar5 : toutvar;
   optn1,optn2 : array[1..optmax] of integer;
   opvar : array[1..optmax] of toutvar;
   optdata : array[1..optmax] of Toptdata2;
   optwgh,optx : array[1..optmax] of double; 
   optavg,optnorm : array[1..optmax] of integer;
   calclayout,calcfreq : boolean;
   AplV,aplZ : cvec; //Applied voltage,impedance
   optw,optdw : double;
   //,optwgh,optwgh2,optwgh3,optwgh4,optwgh5 : double;
   optwn,optn : integer;
   //,optavg,optavg2,optavg3,optavg4,optavg5 : integer;
   optparam1,optparam2,optparam3 : double;
   validZZ  : integer;
   //footprint
   PClayout : pointer;
   //params
   parmn : integer;
   parm : array of Tparm;
   xvars : array of toutvar;   
   Procedure readfile(var f : text);
   Procedure readfile2(var f : text);
   function readcomp(s : string;var C : Pcomp) : boolean;
   function getnode(s : string) : integer;
   function getnodei(s : string) : integer;
   Procedure calcY(w : double);
   Procedure calcN(w : double);
   
   //Print
   procedure readprint(ss : tstrings;plot : integer);
   procedure readset(s : string;ss : Tstrings);
   Procedure readsetparam(ss : Tstrings);
   Procedure readloadparam(ss : Tstrings);
   Procedure readsaveparam(ss : Tstrings);
   Procedure printout(V0,Z0 : cvec;w : double);
   Procedure gnuplot(PR : Tprint);
   Procedure gnuplotxy(PR : Tprint);

   function solveS(nd : integer;V0 : cvec) : tc;
   function solveZ(ni1,nd : integer;Z : cvec) : tc;
   procedure solveDS(nd : integer;V0 : cvec;var C : tc);
   procedure calcTZ(Z0 : cvec);
   Procedure solveNoise(nd,rnd : integer;V0 : cvec;var NV0 : cvec);
   function solveN(nd,rnd : integer;V0,Z0 : cvec) : tr;
   function solveNC(nd,rnd : integer;V0,Z0 : cvec) : tc;
   function solveNC2(nd,nd2,rnd,rnd2 : integer;V0,Z0 : cvec) : tc;
  procedure solveDN(nd : integer;V0 : cvec;var C : double);
  function solveMmin(M1 : Pcomp;V0,Z0 : cvec;eig : boolean;w : double) : double;
//   function solveT(node : integer;V0 : cvec) : tc;
  Procedure readanal(ss : tstrings);
  
  Procedure CompZ(Xcomp : Pcomp;w : double;Z0 : cvec;var Zvec : cvec);
  Procedure CompN(Xcomp : Pcomp;w : double;V0,Z0 : cvec;var Nvec : cvec);


//  procedure readDvar(var D : Tdvar;ss : string);
  Procedure readoptim(ss : tstrings);
  function optim_eval(P : tvec) : double;
  Procedure optim_getdiff(P : tvec;var res : double;ver : integer);

 Procedure ACanal(w0,w1,dw : double);

  Procedure closecomp; virtual;
 Procedure addlayout(s : string);

 //From compu
//   function Nnode : integer; virtual;
//   function Nsrc : integer; virtual;
//   function Nnoise : integer; virtual;
   Procedure loadY(w : double);

   Procedure getY(w : double;var Y : cmat); virtual;
   Procedure getS(w : double;var S : cmat); virtual;
   Procedure getN(w : double;var N : cmat); virtual;
   Procedure calcNI;
   Procedure load(Np1 : integer;P : Tparams); virtual;
  function calcK(w : double;V0 : cvec) : double;
  function calc2PMmin(wat : integer) : tc;

   function getZ(nm,i : integer;var Z : cvec) : boolean; virtual;
   Procedure saveZ(nm,i : integer;var Z : cvec); virtual;

  function readoutvar(S : string) : toutvar;
  function getoutvar(var vr : toutvar;w : double;V0,Z0 : cvec) : double;
  function getoutvar2(var vr : toutvar;w : double) : double;
  procedure doUpdate(w : double;V0,Z0 : cvec;cnt : integer); virtual;
  procedure calcRPC(var f : text;vr : toutvar;w : double;V0,Z0 : cvec);
  procedure calcMmin(var f : text;vr : toutvar;w : double;V0,Z0 : cvec);

  procedure getDoutvar(vr : toutvar;w : double;V0 : cvec;var V : double;ver : integer);
  function findcomp(s : string) : Pcomp;
  function findcomp2(s : string) : Pcomp;

 Procedure makeY(w : double;var YYY : cmat); virtual;
 Procedure makeS(w : double;var SSS : cmat); virtual;
 Procedure makeDS(w : double;var SSS : cmat;S0 : cmat;ver : integer);
 function loads(ss : tstrings) : boolean; virtual;


 Procedure readspecial(ss : tstrings);
 Procedure DoInitY;
 

Procedure calcFmin(var Fmin,Rn,Gn : tr;var Ycor : tc);
function var2str(vr : toutvar) : string;

Procedure readnodes(ss : tstrings);

   function paramnum(s : string) : integer; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   Procedure setD2(s : string;wat : integer); virtual;

 Procedure closeprint;

  function addoutvar(s : string;var wt : integer) : integer; //in subcircuit save in optvar
 function getFoot(var wt,par : string;var pars : integer) : boolean;  virtual;
 Procedure exportckt(ss : tstrings);
 Procedure exportQucs(var f : text);virtual;
 Procedure exportVars(var f : text;prnt : string);virtual;
end;

type
 PSport = ^Tsport;   

var
   Pin,Pout,Pin2,Pout2 : Tdvar;

implementation
uses consts,tline,tline2,compnt,compnt2,tline_a,tline_ms,tline_t,tline_s,unix,statz,tom,HJ,math,ascolink,mminu,PCBlayout,funcu,EM;
// *********** OTHER ***********


Procedure subset(var ss : tstrings;n : integer;V : array of tset);
var
 s2 : tstrings;
 nm : string;
 x,y,l,i : integer;
begin
x:=1;l:=len(ss);
while (x<=l) do begin
 if ss[x][1]='$' then begin
    nm:=ss[x];
    delete(nm,1,1);
    y:=0;
    while (y<n) and (V[y].name<>nm) do inc(y);
    if y=n then begin
      writeln('Can not find $',nm);
      halt(1);
      end;
    s2:=strtostrs(V[y].value);
    y:=len(s2);
    if y=0 then ss[x]:='' else begin
//      ss[x]:=s2[1];
//      l:=len(ss);
//      for i:=1 to y-1 do ss[l+i]:=s2[i+1];
      for i:=l downto x+1 do ss[i+y-1]:=ss[i];
      for i:=1 to y do ss[x+i-1]:=s2[i];

      ss[l+y]:=#0;
      l:=l+y-1;
      end;
   end else inc(x);
 end;
end;


Procedure addblk(Y : cmat;x0,y0,x1,y1 : integer;Z : tc);
begin
//writeln(x0:4,y0:4,x1:4,y1:4);
cadd(Y[x0,y0],Z);
cadd(Y[x1,y1],Z);
Z:=-Z;
cadd(Y[x1,y0],Z);
cadd(Y[x0,y1],Z);
end;

Procedure Tsport.gnuplot(PR : Tprint);
var
 x,y : integer;
begin
with pr do begin
if (N<2) or (vars[0].wat<>-1) then begin
  writeln('First column must be frequency for plot');
  exit;
  end;
 assign(f,name+'.plt');
 rewrite(f);
 writeln(f,'set zero 1e-15; set grid; set style data linespoints');
 writeln(f,'set xlabel "Frequency (Hz)"');
 if vars[1].wat=38 then begin
   y:=Pmmin(vars[1].comp)^.nr;
  write(f,'plot '''+name+''' using ($1):($2**2+$3**2) title "A1"');
  for x:=2 to y do write(f,', '''' using ($1):($',2*x,'**2+$',2*x+1,'**2) title "A',x,'"');
   end else begin
  write(f,'plot '''+name+''' using 1:2 title "',vars[1].varnm,'"');
  for x:=2 to N-1 do {if vars[x].node>=0 then} write(f,', '''' using 1:',x+1,' title "',vars[x].varnm,'"');
   end;
// writeln('printcard n=',n);
 writeln(f);
 writeln(f,'set term post eps color');
 writeln(f,'set output "'+name+'.eps"');
 writeln(f,'replot');

 close(f);
 shell('gnuplot -persist '+name+'.plt');
end;
end;

Procedure Tsport.gnuplotxy(PR : Tprint);
var
 x,y : integer;
begin
with pr do begin
if ((N mod 2>0) or (N<2)) and (vars[0].wat<>38) then begin
  writeln('Multiple of 2 columns needed (N=',N,')');
  exit;
  end;


 assign(f,name+'.plt');
 rewrite(f);
 writeln(f,'set zero 1e-15; set grid; set style data linespoints');
 if vars[0].wat=38 then begin
   y:=Pmmin(vars[0].comp)^.nr;
  write(f,'plot '''+name+''' using 1:2 title "A1"');
  for x:=2 to y do write(f,', '''' using ($1):($',2*x-1,'**2+$',2*x,'**2) title "A',x,'"');
   end else begin
  write(f,'plot '''+name+''' using 1:2 title "',vars[0].varnm,' - ',vars[1].varnm,'"');
  for x:=2 to N div 2 do {if vars[x].node>=0 then} write(f,', '''' using ',2*x-1,':',2*x,' title "',vars[2*x-2].varnm,' - ',vars[2*x-1].varnm,'"');
   end;
// writeln('printcard n=',n);
 writeln(f);
 close(f);
// writeln('gnuplot -persist '+name+'.plt');
 shell('gnuplot -persist '+name+'.plt');
end;
end;


{
function Tsport.findcomp(nm : string) : Pcomp;
var x : integer;
begin
x:=0;
while (x<Nc) and (comp[x]^.name<>nm) do inc(x);
if x=Nc then findcomp:=nil else findcomp:=comp[x]; 
end;}
// *************** Constructing matrixes *************
Procedure Tsport.makeY(w : double;var YYY : cmat);
const  max = 100;
var
// Y : cvec;
 x,j : integer;
begin
// writeln(name,' Construct Y matrix (',Nt,'x',Nt,')');
 for x:=0 to Nt-1 do for j:=0 to Nt-1 do YYY[x,j]:=czero;
// writeln(name,' Construct Y matrix (',Nt,'x',Nt,')');

 for x:=0 to Nc-1 do begin
// writeln('get Y');
// write(comp[x]^.tiepe,':',comp[x]^.name);
// writeln('get Y from ',comp[x]^.name,' p=',integer(comp[x]));
 comp[x]^.getY(w,YYY);
// write('; ');
 end;
//writeln('makeY');
//CMwriteE(nt,nt,YYY);
end;

Procedure Tsport.makeS(w : double;var SSS : cmat);
const  max = 100;
var
// Y : cvec;
 x,{Nn,}i,j,k,Nn2 : integer;
begin
//setlength(Y,max);
//S matrix
//writeln(name,' Construct S matrix (',Ns,')');
for i:=0 to Nns do for j:=0 to Nt-1 do SSS[i,j]:=czero;
for x:=0 to Nc-1 do comp[x]^.getS(w,SSS);

//N matrix
//writeln(name,' Construct N matrix (',Nns,')');

k:=0;
for x:=0 to Nc-1 do with comp[x]^ do if Nnoise>0 then begin
// Nn:=Nnode;
// write(comp[x]^.tiepe,':',comp[x]^.name,'; ');
 Nn2:=Nnoise;
 noiseI:=k+1;
 getN(w,SSS);
 k:=k+Nn2;
end;
end;


Procedure Tsport.makeDS(w : double;var SSS : cmat;S0 : cmat;ver : integer);
const  max = 100;
var
// Y,dY,dn : cvec;
 x,Nn,i,j,k,Nn2,l : integer;
begin
//setlength(Y,max);
//CMsetsize(dY,max);
//setlength(dn,max);
//S matrix
//Ns:=0;
//for x:=0 to Ndc-1 do NS:=Ns+dcomp[x].C^.Nsrc;
Ns:=1;
Ndns:=Nns+1;
//for x:=0 to Ndc-1 do NdnS:=Ndns+dcomp[x].C^.Nnoise*Ndc;
writeln(name,' Construct DSN matrix');
CMsetsize(Ndns,Nt,SSS);
for i:=0 to Ndns-1 do for j:=0 to Nt-1 do SSS[i,j]:=czero;

with dcomp[ver].C^ do begin
    Nn:=Nnode;
    getdY(w,S0[0],SSS[0],dcomp[I].wat);
    getdS(w,S0[0],SSS[0],dcomp[I].wat);
    
    for i:=1 to Nns do 
     getdY(w,S0[i],SSS[i],dcomp[I].wat);
     
    
    Nn2:=Nnoise;
//!!    getDN(w,Y,dN);
    getdN(w,S0,SSS,dcomp[I].wat);
//   for l:=1 to Nn2 do begin
//     for j:=0 to Nn-1 do Y[j]:=S0[noiseI+l-1,node[j]];
//!!     getdY(w,Y,dY);
//    getdY(w,S0[noiseI+l-1],SSS[i+(noiseI+l-1)*Ndc],dcomp[I].wat);
//     inc(k);  
//     for j:=1 to Nn-1 do begin
//       SSS[k,node[j]]:=dN[(l-1)*Nn2+j-1]-dY[j-1];
//       cadd(SSS[k,node[0]],dY[j-1]-dN[(l-1)*Nn2+j-1]);
//       end;
//     end; {l}
    end; {i}
end;


// *************** Calculations *************
Procedure Tsport.DoInitY;
var
 x : integer;
begin
if initY then exit;
//write(name,' Init: ports=',np-1,' noise src=',nns,' nodes=',np+nv-1,' comp=',nc);
//if doinv then write(' Invert');
//writeln;
//writeln(name,' Get mem for matrix');
initY:=true;
if nc>0 then begin
 Ns:=0;
 for x:=0 to Nc-1 do NS:=Ns+comp[x]^.Nsrc;
 Nns:=0;
 for x:=0 to Nc-1 do NnS:=Nns+comp[x]^.Nnoise;
 Nt:=Np+Nv+Ni;
 for x:=0 to Nc-1 do comp[x]^.calclinks;
end;
 CMsetsize(Nt,Nt,YY);
{if 1+Nns>Nt then CMsetsize(1+Nns,Nt,YYI) else} CMsetsize(Nt,Nt,YYI);
 CMsetsize(1+Nns,Nt,SN);
 if nt>nns then x:=nt else x:=nns;
 setlength(work,nt*x);
// setlength(workn,nt*nt);
// writeln('nt=',nt);
 setlength(work2,nt*x);
 setlength(work3,nt*x);
 setlength(ZZ,nt*nt);
 setlength(YZ,np*nv);
end;

procedure Tsport.calcY(w : double);
//************* NOT VERY EFFECTIVE ***********
var
x,y,z : integer;
begin
//if doInv then writeln(name,' CalcY*') else writeln(name,' CalcY');
//dorecalc:=false;
//inc(validzz);

//initY:=false;
//DoInitY;
//writeln(name,':',cktname,' make Y...');
//write('Cy');
makeY(w,YY);
//writeln(name,': make Y YY=');cmwriteE(Nt,Nt,YY);

//write('Cs');
//writeln('np=',np,' nt=',nt,' nns=',nns);
//write(name,' Solve system ...');
//write('s');
//for x:=np to nt-1 do for y:=x+1 to nt-1 do if x=y then YYI[x,y]:=r2c(1,0) else YYI[x,y]:=czero;
//writeln(name,':',cktname,' make S	...');
if doInv then begin
 makeS(w,SN);  
// writeln('Sn=');cmwriteE(Nns+1,Nt,Sn);
//writeln(name,':',cktname,' Inverting	...');
// for x:=0 to nt-1 do for y:=0 to nt-1 do YYI[x,y]:=czero;
 x:=CMinv(Nt,YY,np,nt-1,YYI);
 if x<>0 then begin
  writeln(name,':',cktname,': Error Solving Node ',SP[x]);
  halt(1);
  end;
// write('*');
 for x:=np to nt-1 do for y:=0 to nt-1 do YY[x,y]:=YYI[x,y];
  for x:=0 to nns do begin
   for y:=0 to nt-1 do YYI[0,y]:=SN[x,y];
   for y:=0 to nt-1 do begin
     if y>=np then SN[x,y]:=czero;
     for z:=np to nt-1 do if (YYI[0,z,1]<>0) or (YYI[0,z,2]<>0) then SN[x,y]:=SN[x,y]+YYI[0,z]*YY[z,y];
     end;
  end;
 end else begin
  makeS(w,SN);
// writeln('Sn=');cmwriteE(Nns+1,Nt,Sn);
//  write('*');  
//writeln(name,':',cktname,' Eliminating	...');
  x:=CMelim(Nt,YY,np,nt-1,Sn,Nns+1);
//writeln('YY=');cmwriteE(Nt,Nt,YY);
  if x<>0 then begin
   writeln(name,':',cktname,': Error Solving Node ',SP[x]);
    halt(1);
   end; 
 end;
currentw:=w;
//writeln(name,' YY=');cmwriteE(Nt,Nt,YY);
//writeln(' Done');
//writeln(name,' System solved');
//writeln('Sn=');cmwriteE(Nns+1,Nt,Sn);
end;   

function Tsport.solveS(nd : integer;V0 : cvec) : tc;
var
 z : tc;
 x : integer;
begin
if nd<Np then begin
  solveS:=V0[nd];
  exit;
  end;
z:=Sn[0,nd];
for x:=0 to Np-1 do z:=z+V0[x]*YY[x,nd];
solveS:=z;
end;


function Tsport.solveZ(ni1,nd : integer;Z : cvec) : tc; //use work3
var
// V0 : cvec;
 res : tc;
 x,y : integer;
begin
 res:=czero; 
 if (ni1=0) or (nd=0) then begin;solveZ:=czero;exit;end;
// setlength(V0,nt);
//write('np=',np,' ni1=',ni1,' nd=',nd,' Z=');
 if ni1<np then 
   if nd<np then res:=Z[(ni1-1)*(np-1)+nd-1]
            else for x:=1 to np-1 do res:=res-YY[x,nd]*Z[(ni1-1)*(np-1)+x-1]
else if nd<np then for x:=1 to np-1 do res:=res+YY[ni1,x]*Z[(x-1)*(np-1)+nd-1]
            else begin
              res:=YY[ni1,nd];
              for x:=1 to np-1 do work3[x]:=czero;
              for x:=1 to np-1 do
                for y:=1 to np-1 do work3[x]:=work3[x]+YY[ni1,y]*Z[(y-1)*(np-1)+(x-1)];
              for x:=1 to np-1 do res:=res-YY[x,nd]*work3[x];
              end;
//write(ni1,' ',nd,' ');cwrite(res);writeln;
solveZ:=res;
end;

procedure Tsport.solveDS(nd : integer;V0 : cvec;var C : tc);
var
 i : integer;
begin
if np>1 then begin
 writeln('solveDS np>1 not implemented!');halt(1);
 end;
 C:=dSn[0,nd];
end;


procedure Tsport.calcTZ(Z0 : cvec);
//Calculate YY21 x Z0
//YY[c,r], YZ[c*nv + r], Z0[c * np + r] ??
var
 i,j,k : integer;
 Zn : tc;
begin
if Np=1 then exit;
for j:=0 to Nv-1 do
 for i:=1 to Np-1 do begin
     zN:=czero;
     for k:=1 to Np-1 do zN:=zN+YY[k,np+j]*Z0[(i-1)*(np-1)+(k-1)];
     YZ[j+i*nv]:=Zn;
     end;
//writeln('Y');
//CMwriteE(nt,nt,YY);
//writeln('Z ',np-1,'x',np-1);
//CVwriteM(np-1,np-1,Z0);
//writeln('YZ ',np-1,'x',nv);
//CVwriteM(np,nv,YZ);
end;

Procedure Tsport.solveNoise(nd,rnd : integer;V0 : cvec;var NV0 : cvec);
var
 i,x : integer;
 z : tc;
begin
//write(name,': SolveNoise:X nd=',nd,' np=',np);
for i:=1 to Np-1 do begin
  z:=czero;
  if rnd>0 then for x:=0 to Np-1 do z:=z+V0[i*np+x]*(YY[x,nd]-YY[x,rnd])
           else for x:=0 to Np-1 do z:=z+V0[i*np+x]*(YY[x,nd]);
  NV0[i]:=z;
  end;
//write('I');
for i:=1 to Nns do begin
 if rnd>0 then Z:=Sn[i,nd]-Sn[i,rnd]
	  else Z:=Sn[i,nd];
 if rnd>0 then for x:=1 to Np-1 do z:=z-(YZ[(x)*nv+(nd-np)]-YZ[(x-1)*nv+(rnd-np)])*Sn[i,x]
//          else for x:=1 to Np-1 do z:=z-YZ[(nd-np)*np+x]*Sn[i,x];
          else for x:=1 to Np-1 do z:=z-YZ[(x)*nv+(nd-np)]*Sn[i,x];
  Nv0[np+i-1]:=z;
 end;
//CMwriteE(nt,nns+1,Sn);
NV0[0]:=czero;
//writeln(name,' NV0: ',np-1,'+',Nns);
//CVwrite(np+nns,NV0);
//writeln('YY');
//CMwriteE(nt,nt,YY);
end;


function Tsport.solveN(nd,rnd : integer;V0,Z0 : cvec) : tr;
var
 z : tr;
 i : integer;
 zN : tc;
begin
if nd<Np then begin
  solveN:=0;
  exit;
  end;
if Np=1 then begin
  z:=0;
  if rnd>0 then for i:=1 to Nns do z:=z+cabs2(Sn[i,nd]-Sn[i,rnd])
           else for i:=1 to Nns do z:=z+cabs2(Sn[i,nd]);
  //for x:=1 to Nns do writeln('N',x,'=',cabs2(Sn[x,nd]-Sn[x,rnd]));
  solveN:=z;
  end else begin
//writeln(name,' solveN: np=',np,' Nns=',nns,' Noise src=',Np+Nns-1);
//writeln('solveN: calcTZ');
calcTZ(Z0);
//writeln('solveN: solveNoise');
solveNoise(nd,rnd,V0,work2);
//writeln('solveN: sum');
//cvwrite(Np+Nns,work2);
z:=0;
for i:=1 to Np+Nns-1 do z:=z+cabs2(work2[i]);
//writeln('solveN: z=',z);
solveN:=z;
end;
end;

function Tsport.solveNC(nd,rnd : integer;V0,Z0 : cvec) : tc;
var
 z : tc;
 x : integer;
 Z1n,Zn2 : tc;
begin
//writeln('solveNC');
if nd<Np then begin
  solveNC:=czero;
  exit;
  end;
z:=czero;
calcTZ(Z0);
solveNoise(nd,0,V0,work2);
solveNoise(rnd,0,V0,work);
for x:=1 to Np+Nns-1 do z:=z+(work2[x])*ccomp(work[x]);
solveNC:=z;
end;

function Tsport.solveNC2(nd,nd2,rnd,rnd2 : integer;V0,Z0 : cvec) : tc;
var
 z : tc;
 x : integer;
 zN1,zN2 : tc;
begin
//writeln('solveNC2');
if nd<Np then begin
  solveNC2:=czero;
  exit;
  end;
z:=czero;
calcTZ(Z0);
solveNoise(nd,rnd,V0,work2);
solveNoise(nd2,rnd2,V0,work);
for x:=1 to Np+Nns-1 do z:=z+(work2[x])*ccomp(work[x]);
solveNC2:=z;
end;


procedure Tsport.solveDN(nd : integer;V0 : cvec;var C : double);
var
 x,i,j,k,Nn2 : integer;
 z : double;
begin
if Np>1 then begin
 writeln('solve DN np>1 not implemented!');
 halt(1);
 end;
c:=0;
for x:=1 to Nns do c:=c+cinner(Sn[x,nd],Dsn[x,nd]);
c:=c*2;
end;
function tmin(w : double) : double;
begin
w:=w/1e9/twopi;
if w<=1 then tmin:=4.7 
else if w<=2 then tmin:=(w-1)*6.75+(2-w)*4.6 
else if w<=3 then tmin:=(w-2)*13.67+(3-w)*6.75
else tmin:=13.67;
end; 

function Tsport.solveMmin(M1 : Pcomp;V0,Z0 : cvec;eig : boolean;w : double) : double;
var
 x,y,n1,n2 : integer;
 M2 : Pmmin;
 t : double;
begin
solveMmin:=0;
if M1=nil then exit;
//writeln('solveMmin');
if Pin.C<>nil then with pin do begin;t:=C^.getD(wat);end else t:=noiseres;
t:=sqrt(t);
M2:=Pmmin(M1);
with M2^ do begin
 for x:=0 to NR-1 do MC[x,x]:=r2c(solveN(nds[x],rnds[x],V0,Z0),0);
 for x:=0 to NR-1 do VS[x]:=(solveS(nds[x],V0)-solveS(rnds[x],V0))*t;
//Normalised phase (for testing)
 
//
 for x:=0 to NR-1 do
  for y:=x+1 to NR-1 do begin
    MC[x,y]:=solveNC2(nds[x],nds[y],rnds[x],rnds[y],V0,Z0);
    MC[y,x]:=ccomp(MC[x,y]);
    end;
//   n1:=nds[x];
//   C[0,0]:-
t:=calcMmin(eig,w);
//if t<0 then t:=1e99;
solveMmin:=t;
 end;    
end;

function Tsport.calc2PMmin(wat : integer) : tc;
var
 res : tc;
 i1,i2 : double;
 C : tc;
 x : integer;
begin
if np<>3 then begin;writeln('Mmin only implemented for 2 port!');calc2PMmin:=r2c(inf,0);exit;end;
 i1:=0;i2:=0;C:=czero;
 for x:=1 to Nns do i1:=i1+cabs2(Sn[x,1]);
 for x:=1 to Nns do i2:=i2+cabs2(Sn[x,2]);
 i2:=sqrt(i2);
c:=czero;
 for x:=1 to Nns do C:=C+Sn[x,1]*ccomp(Sn[x,2]);
  c:=c/i2;
  i1:=i1-cabs2(C);	
  if i1<0 then i1:=0 else i1:=sqrt(i1);
case wat of 
 1 : res:=r2c(P2MminA(YY[1,1],YY[1,2],YY[2,1],YY[2,2],C,r2c(i2,0),r2c(i1,0),czero),0);
 2 : res:=(P2MminY(YY[1,1],YY[1,2],YY[2,1],YY[2,2],C,r2c(i2,0),r2c(i1,0),czero));
else
    res:=r2c(P2Mmin(YY[1,1],YY[1,2],YY[2,1],YY[2,2],C,r2c(i2,0),r2c(i1,0),czero),0);
end;
//if (i1<=0) then if wat=0 then i1:=1e99 else i1:=abs(i1);
//if (i1<=0) then i1:=1e99;
if wat=1 then begin
 if res[1]<0 then res[1]:=0;
 res[1]:=sqrt(res[1]);
 end;
 calc2PMmin:=res;
end;


 
function Tsport.calcK(w : double;V0 : cvec) : double; //user work3
var
 Z : array[0..1,0..1] of tc;
begin
if np=3 then begin
  Z[0,1]:=YY[1,2]*YY[2,1];
  if (Z[0,1,1]<>0) or (Z[0,1,2]<>0) then calcK:=(2*YY[1,1,1]*YY[2,2,1]-Z[0,1,1] ) / sqrt(cabs2(Z[0,1])) else calcK:=inf;
 end else begin
// writeln(pnodes[0,1]:3,pnodes[0,0]:3,pnodes[1,1]:3,pnodes[1,0]:3);
 Z[0,0]:=SolveZ(Pnodes[0,1],Pnodes[0,1],V0)-SolveZ(Pnodes[0,0],Pnodes[0,1],V0)-SolveZ(Pnodes[0,1],Pnodes[0,0],V0)+SolveZ(Pnodes[0,0],Pnodes[0,0],V0); //use work3
 Z[0,1]:=SolveZ(Pnodes[0,1],Pnodes[1,1],V0)-SolveZ(Pnodes[0,0],Pnodes[1,1],V0)-SolveZ(Pnodes[0,1],Pnodes[1,0],V0)+SolveZ(Pnodes[0,0],Pnodes[1,0],V0);
 Z[1,0]:=SolveZ(Pnodes[1,1],Pnodes[0,1],V0)-SolveZ(Pnodes[1,0],Pnodes[0,1],V0)-SolveZ(Pnodes[1,1],Pnodes[0,0],V0)+SolveZ(Pnodes[1,0],Pnodes[0,0],V0);
 Z[1,1]:=SolveZ(Pnodes[1,1],Pnodes[1,1],V0)-SolveZ(Pnodes[1,0],Pnodes[1,1],V0)-SolveZ(Pnodes[1,1],Pnodes[1,0],V0)+SolveZ(Pnodes[1,0],Pnodes[1,0],V0);
// Z[0,0]:=cinv(cinv(Z[0,0])-cinv(r2c(50,0)));
// Z[1,1]:=cinv(cinv(Z[1,1])-cinv(r2c(50,0)));
 cwriteEng(z[0,0]); cwriteEng(z[0,1]);cwriteEng(z[1,1]);cwriteEng(z[1,0]);writeln;
 z[0,1]:=Z[0,1]*Z[1,0];
 if (Z[0,1,1]<>0) or (Z[0,1,2]<>0) then calcK:=(2*Z[0,0,1]*Z[1,1,1]-Z[0,1,1] ) / sqrt(cabs2(Z[0,1])) else calcK:=inf;
 end;
end;

Procedure Tsport.CompN(Xcomp : Pcomp;w : double;V0,Z0 : cvec;var Nvec : cvec);
//Use work and work3
var
 i,ii,x,y,j : integer;
 i2,i1 : tr;
 C : tc;
 begin
 i:=Xcomp^.nnode-1;
 if i=0 then exit;
 ii:=i+1;
// writeln(name,' CompN for ',Xcomp^.name,': ports=',i,' noisesrc=',np+Nns-1);
 calcTZ(Z0);
 j:=np+Nns-1-Xcomp^.Nnoise;
 if j<=i then with Xcomp^ do begin
// writeln('Direct j=',j,' NoiseI=',NoiseI);
  for x:=0 to ii*ii-1 do Nvec[ii+x]:=czero;
  for x:=1 to i do begin 
     solveNoise(node[x],node[0],V0,work);
     if Nnoise>0 then begin
      for y:=1 to np+noiseI-2 do Nvec[(y)*ii+(x)]:=work[y];
      for y:=np+noiseI-1 to j do Nvec[(y)*ii+(x)]:=work[y+Nnoise];
     end else
      for y:=1 to j do Nvec[(y)*ii+(x)]:=work[y];
   end;
//   writeln('Done');
//   for y:=1 to ii*ii-1 do cwriteEng(Nvec[0]);
  end else
 if i=1 then with Xcomp^ do begin
     solveNoise(node[1],node[0],V0,work);
     for x:=0 to Nnoise-1 do work[np+NoiseI+x-1]:=czero;//Exclude own noise
     i2:=0;for x:=1 to Np+Nns-1 do i2:=i2+cabs2(work[x]);
     Nvec[ii+1]:=r2c(sqrt(i2),0);
   end else if i=2 then with Xcomp^ do begin
//     writeln('Make 2 noise sources exclude NoiseI=',NoiseI);
//     writeln('Solve port 1');
     solveNoise(node[1],node[0],V0,work);
//     writeln('Solve port 2');
     solveNoise(node[2],node[0],V0,work3);
     for x:=0 to Nnoise-1 do work[np+NoiseI-1+x]:=czero;//Exclude own noise
     for x:=0 to Nnoise-1 do work3[np+NoiseI-1+x]:=czero;//Exclude own noise
     i1:=0;i2:=0;C:=czero;
     for x:=1 to Np+Nns-1 do i1:=i1+cabs2(work[x]);
     for x:=1 to Np+Nns-1 do i2:=i2+cabs2(work3[x]);
     i2:=sqrt(i2);
//     write('i2=',i2);
     Nvec[2*ii+2]:=r2c(i2,0);
     c:=czero;
     for x:=1 to Np+Nns-1 do C:=C+work[x]*ccomp(work3[x]);
     if i2=0 then begin;write('*1');c:=czero;end else
       c:=c/i2;
//     write('C=');cwrite(C);
     Nvec[2*ii+1]:=C;
    i1:=i1-cabs2(C);	
    if i1<0 then i1:=0 else i1:=sqrt(i1);
//    write('i1=',i1);
    Nvec[ii+1]:=r2c(i1,0);
    Nvec[ii+2]:=czero;
   end else begin
//    writeln(name,': Subckt noise not implemented for ports=',i);
//write('~');
    for x:=0 to ii*ii-1 do Nvec[ii+x]:=czero;
//    halt(1);
   end;
//    writeln('Nvec:');
//    CVwriteM(ii,ii,Nvec);
//    CVwrite(i*i,Nvec);

end;



Procedure Tsport.CompZ(Xcomp : Pcomp;w : double;Z0 : cvec;var Zvec : cvec);//use work3
var i,j,k : integer;
     z,ii : tc;
begin
//    with vr do begin
//writeln('Compz validzz=',validzz);
        i:=Xcomp^.nnode-1;
//        if i=0 then exit;
        if (Xcomp^.tiepe<>'CKT') or not(psport(Xcomp)^.getZ(validzz,i,Zvec)) then begin
           if not(doInv) then begin;writeln(name,' must do matrix inversion!!');halt(1);end;
//    	    writeln('Comp...');
	   with Xcomp^ do begin
//	    writeln('comp z: Z0=');
//	    CVwriteM(np-1,np-1,Z0);
	     z:=SolveZ(node[0],node[0],Z0); //use work3
	     for j:=0 to i-1 do begin
	       ii:=SolveZ(node[j+1],node[0],Z0)-z;
	       for k:=0 to i-1 do
	           Zvec[j*i+k]:=SolveZ(node[j+1],node[k+1],Z0)-SolveZ(node[0],node[k+1],Z0)-ii;
	       end;end;
	     if Xcomp^.tiepe='CKT' then psport(Xcomp)^.saveZ(validzz,i,Zvec);
	     end;
//write(name,': ',Xcomp^.name,': ');
//CVwrite(i*i,Zvec);
//    end;
end;
procedure Tsport.doUpdate(w : double;V0,Z0 : cvec;cnt : integer);
var
 x,i,j : integer;
begin
// writeln(name,' Updating...');
 if currentw<>w then loady(w);
 for x:=0 to Nc-1 do with comp[x]^ do if AlwaysUpdate or dorecalc then begin
	    comp[x]^.dorecalc:=false;
//	    writeln('Update ',comp[x]^.name);
            i:=comp[x]^.nnode;
            if i>0 then begin
//            write(' ',name,':',length(work),':',length(work3));
 	     for j:=0 to i-1 do work2[j]:=solveS(comp[x]^.node[j],V0);
//	     writeln('CompN');
	     compn(comp[x],w,V0,Z0,work2);
//	     writeln('Compz');
	     compz(comp[x],w,Z0,work); //use work3
//	     writeln('Do update');
	    doUpdate(w,work2,work,cnt);
	     end else doUpdate(w,V0,Z0,cnt);
//	    writeln('new V0:');
//	    CVwriteM(i,i,work2);
//	    writeln('new Z0:');
//	    CVwriteM(i-1,i-1,work);
 end;
//writeln('Done');
end;
function Tsport.getoutvar2(var vr : toutvar;w : double) : double;
begin
case vr.wat of 
 35,135  : getoutvar2:=getoutvar(vr,w,work,work2);
 else begin
 getoutvar2:=0;
 writeln('getoutvar2 not implemented for ',vr.wat);
 end;
 end;
end;



function Tsport.getoutvar(var vr : toutvar;w : double;V0,Z0 : cvec) : double;
var
 Z,z2,ii : tc;
 s,s2,t : double;
 i,j,k : integer;
// V1 : cvec;
begin
//writeln(name,': getoutvar ',vr.wat);
//writeln(name,' V0=');
//CVwriteM(nnode,nnode,V0);
//writeln(name,' Z0=');
//CVwriteM(nnode-1,nnode-1,Z0);
if currentw<>w then loady(w);
//loadY(w);
 with vr do begin
   case wat of
    -1 : if node=1 then getoutvar:=log10(w/twopi) else getoutvar:=w/twopi;
     0 : Z:=solveS(node,V0)-solveS(refnode,V0);
     1 : getoutvar:=sqrt(solveN(node,refnode,V0,Z0));
    13 : begin
      s:=solveN(node,refnode,V0,Z0);
       if Pin.C<>nil then with pin do begin;t:=C^.getD(wat);end else t:=noiseres;
       getoutvar:=s/t;
      end;
     2 : begin
       s:=cabs2(solveS(node,v0)-solveS(refnode,v0));
//       if Pin<>nil then noiseres:=Pin.getD(1);
//       if Pin.C<>nil then with pin do begin;t:=C^.getD(wat);t:=(noiseres*noiseres)/t;end else t:=noiseres;
       if Pin.C<>nil then with pin do begin;t:=C^.getD(wat);end else t:=noiseres;
//       writeln('Get N w=',w,' s=',s,' n=',solveN(node,refnode,v0,z0),' t=',t);
//       writeln('n=',node,' ref=',refnode);
       if s<>0 then t:=solveN(node,refnode,v0,z0)/s/k4/t*4
               else t:=inf;
        if RI=1 then t:=t/tmin(w)-1;
//        write('*');
        getoutvar:=t;
       end;
     5 : begin
       z:=solveS(node,v0)-solveS(refnode,v0);
       ii:=1-(2-z)*ccomp(z);
//      write(' z=');cwrite(z);
//      write('ii=');cwrite(ii);writeln;
//       s:=cabs2(z);
//       t:=sqr(sqrt(s/12.5)-1);
//       writeln('Get N s=',s,' n=',solveN(node,refnode,v0),' t=',t);
        getoutvar:=ii[1];
    //           else getoutvar:=inf;
       end;
       
     3,4,14 : begin
//           loadY(w);
           i:=node mod 10;
	   j:=node div 10;
	   if (i<1) or (j<1) or (i>np) or (j>np) then begin
	     writeln('Can''t calc Y/Z/S',node);
	     halt(1);
	     end; 
	   //writeln('Y',i,' ',j);     
	   case wat of 
	    3 : Z:=YY[i,j];
	    4 : z:=1/YY[i,j];
	    14 : begin
	         t:=1/50;z2:=(t+YY[1,1])*(t+YY[2,2])-(YY[1,2])*YY[2,1];
	         case node of
	           11 : z:=(t-YY[1,1])*(t+YY[2,2])+(YY[2,1])*YY[1,2];
	           22 : z:=(t+YY[1,1])*(t-YY[2,2])+(YY[2,1])*YY[1,2];
	           21 : z:=-2*YY[1,2]*t;
	           12 : z:=-2*YY[2,1]*t;
	           end;
	          z:=z/z2;
	         end;
	   end;end;
     6 : begin
          Z:=solveS(node,V0)-solveS(refnode,V0);
          if Pin.C<>nil then with pin do Z:=Z*sqrt(C^.getD(wat));
          if Pout.C<>nil then with pout do Z:=Z/sqrt(C^.getD(wat));
          end;  
     7 : begin
        //write('*');
{        if (node<1) or (node>=np) then begin;writeln('Can''t calc Yin',node);halt(1);end;
        z:=czero;
        for i:=0 to np-1 do z:=z+YY[i,node]*V0[i];
        //write('-');
        if (abs(V0[node][1])<1e-10) and (abs(V0[node][2])<1e-10) then Z:=czero else z:=Z/V0[node];}
        z:=solveZ(node,node,Z0);
        //writeln('+');
         end;
     8 : begin
           z:=solveNC(node,refnode,v0,z0);
//           write('getoutvar 8: ');cwriteEng(z);writeln;
           z:=z/sqrt(solveN(node,0,V0,Z0)*solveN(refnode,0,V0,Z0));
         end;
    9 : begin
       s:=cabs2(solveS(node,v0)-solveS(refnode,v0));
       if Pin.C<>nil then with pin do begin;t:=C^.getD(wat);end else t:=noiseres;
       if s<>0 then t:=solveN(node,refnode,v0,z0)/s/k4/t*4
               else t:=inf;

        if Pin.C<>nil then with pin do s:=s*(C^.getD(wat));
        if Pout.C<>nil then with pout do s:=s/(C^.getD(wat));
        if (s>1) then getoutvar:=t/(1-1/s)
                           else if s>0 then getoutvar:=1e10/s else getoutvar:=inf;
    
        end;
    10 : z:=solveZ(node,node,Z0)-solveZ(node,refnode,Z0)-solveZ(refnode,node,Z0)+solveZ(refnode,refnode,Z0);
    11 : begin;z:=calc2PMmin(0);if z[1]<0 then z[1]:=1e99;getoutvar:=z[1];end;
    12 : z:=calc2PMmin(1);
    15 : z:=calc2PMmin(2); //Yopt
     20 : begin;compz(comp,w,Z0,work);z:=comp^.getYin(w,work,node);end;
     23 : begin;compz(comp,w,Z0,work);z:=cinv(comp^.getYin(w,work,node));end;
     21 : begin;compz(comp,w,Z0,work);z:=comp^.getReflect(w,work,node);end;
     22 : begin;compz(comp,w,Z0,work);
             i:=comp^.node[node];
             ii:=solveZ(i,i,Z0);
             z:=comp^.getYin(w,work,node);
             z:=csqrt(1-4*z*ii);      
          end;
     30 : getoutvar:=calcK(w,V0);
     35 : begin
       calcFmin(s,s2,t,z2); //Fmin,Rn,Gn,Ycor
       case node of 
        1 : z:=r2c(s*290,0);
        10 : z:=r2c(log10(s+1)*10,0);
        2 : z:=r2c(s2,0);//Rn
        9 : z:=r2c(s2/50,0);//Rn/50
        3 : z:=r2c(t,0);
        4 : z:=z2;
        5 : z:=r2c(sqrt(t/s2+sqr(z2[1])),-z2[2]); //Yopt
        6,7 : begin;
              z2:=r2c(sqrt(t/s2+sqr(z2[1])),-z2[2]); //Yopt
              z:=r2c(290*s2*z2[1],0);//Tn
              if node=7 then z:=z*2;//2Tn
              end;
        8 : begin
            z:=r2c(sqrt(t/s2+sqr(z2[1])),-z2[2]); //Yopt
            //cwriteEng(z);
            if Pin.C<>nil then with pin do begin;t:=1/C^.getD(wat);end else t:=1/noiseres;
            z:=-(z-t)/(z+t);
           end;
        else z:=r2c(s,0);
       end; 
       end;
     36 : begin
       case node of 
        1 : z:=r2c(cabs2(SN[1,1])+cabs2(SN[2,1]),0);
        2 : z:=r2c(cabs2(SN[1,2])+cabs2(SN[2,2]),0);
        3 : z:=SN[1,1]*ccomp(SN[1,2])+SN[2,1]*ccomp(SN[2,2])/sqrt(cabs2(SN[1,1])+cabs2(SN[2,1])*cabs2(SN[1,2])+cabs2(SN[2,2]));
        end;
       end;
     37,38 : getoutvar:=solveMmin(comp,V0,Z0,wat=38,w);
     39 : begin
        solveMmin(comp,V0,Z0,true,w);
        if refnode=0 then z:=Pmmin(comp)^.signal
                     else z:=Pmmin(comp)^.EV[refnode-1];
       end;
     40 : z:=comp^.getoutput(w,V0,Z0,refnode);
     41 : begin
            i:=comp^.nnode;
	    for j:=0 to i-1 do work2[j]:=solveS(comp^.node[j],V0);
	    compn(comp,w,V0,Z0,work2);
	    compz(comp,w,Z0,work);
            z:=comp^.getoutput(w,work2,work,refnode);
       end;
     50 : begin
        getoutvar:=Playout(PClayout)^.getError(node);
       end;
//     110..140 : begin;compz;getoutvar:=Psport(comp)^.getoutvar(Psport(comp)^.xvars[RI],w,work2,work);end;
     100..108,110..140 :   begin
            i:=comp^.nnode;
    	    if wat in [100..108,137..140] then begin
		    for j:=0 to i-1 do work2[j]:=solveS(comp^.node[j],V0);
		    end;
	    if wat in [101,102,137..140] then compn(comp,w,V0,Z0,work2);
	    if wat in [101,102,110..113,115..129,137..140] then compz(comp,w,Z0,work); //use work3
//	    writeln('new V0:');
//	    CVwriteM(i,i,work2);
//	    writeln('new Z0:');
//	    CVwriteM(i-1,i-1,work);
	    getoutvar:=Psport(comp)^.getoutvar(Psport(comp)^.xvars[RI],w,work2,work);
	    z:=Psport(comp)^.xvars[RI].oldv;
	    end;

     else getoutvar:=0;
     end;
//     write('wat=',wat,' RI=',RI);
if (RI in [0..3]) or (wat in [100..140]) then oldv:=z;
if (RI in [23]) then oldv:=r2c(cabs2(z),0);
if wat in [0,3,4,6,7,8,12,14..15,20..23,10,35,36,39,40,41] then case RI of
 0,3 : getoutvar:=sqrt(cabs2(Z));
 23 : getoutvar:=cabs2(z);
 1 : getoutvar:=z[1];
 10 : begin;s:=crad(z)/pi*180;if s<-180 then s:=s+360;getoutvar:=s;end;
 12 : begin;
      s:=crad(z)/pi*180;
      if (oldw<=0) or (w<=oldw) then begin
        if s<-180 then s:=s+360;
        end else begin
        while s<oldv[1]-180 do s:=s+360;
        while s>oldv[1]+180 do s:=s-360;
        end;
      getoutvar:=s;
      oldv[1]:=s;
      oldw:=w;
      end;
 11 : begin;z:=cinv(z);getoutvar:=z[1];end;
 13 : begin;z:=cinv(z);getoutvar:=z[2];end;
 2 : getoutvar:=z[2];
 14 : getoutvar:=-z[2];
 4 : if (z[1]=0) and (z[2]=0) then getoutvar:=-1e+99 else getoutvar:=4.342944819*ln(cabs2(Z));
 5 : begin
   if (oldw<=0) or (w<=oldw) then getoutvar:=0 else begin
      s:=crad(z)-oldv[1];
      if s<-pi then s:=s+2*pi;
      if s>pi then s:=s-2*pi;
           getoutvar:=-s/(w-oldw);
      end;
   oldv[1]:=crad(z);
   oldw:=w;
   end;
 6 : begin
   if (oldw<=0) or (w<=oldw) then getoutvar:=0 else begin
      if (z[2]*oldv[2]<=0)  then getoutvar:=z[1]-(z[1]-oldv[1])*z[2]/(z[2]-oldv[2])
                            else getoutvar:=0;
      end;
   oldv:=z;
   oldw:=w;
   end;
 7 : begin
   if (oldw<=0) or (w<=oldw) then getoutvar:=0 else begin
      if (z[2]*oldv[2]<=0)  then getoutvar:=z[1]-(z[1]-oldv[1])*z[2]/(z[2]-oldv[2]) else
      if abs(z[2])<abs(z[1])/10 then getoutvar:=z[1] 
                            else getoutvar:=0;
      end;
   oldv:=z;
   oldw:=w;
   end;
 8 : begin
   if (oldw<=0) or (w<=oldw) then getoutvar:=0 else begin
      z:=cinv(z);
      if (z[2]*oldv[2]<=0)  then getoutvar:=z[1]-(z[1]-oldv[1])*z[2]/(z[2]-oldv[2]) else
      if abs(z[2])<abs(z[1])/10 then getoutvar:=z[1] 
                            else getoutvar:=0;
      end;
   oldv:=z;
   oldw:=w;
   end;
{ 9 : begin
   if (oldw<=0) or (w<=oldw) then getoutvar:=0 else begin
      if (z[2]*oldv[2]<=0)  then s:=z[1]-(z[1]-oldv[1])*z[2]/(z[2]-oldv[2]) else
      if abs(z[2])<abs(z[1])/10 then s:=z[1] 
                            else s:=0;
      if (oldv[2]>z[2]) and (s<>0) and (z[2]*oldv[2]<=0) and (oldv[1]>z[1]) then getoutvar:=1/s else getoutvar:=s;
      end;
   oldv2:=oldv;
   oldv:=z;
   oldw:=w;
  end;}
 9 : begin
   if (oldw<=0) or (w<=oldw) then getoutvar:=0 else begin
      if (z[2]*oldv[2]<=0)  then getoutvar:=(z[1]-(z[1]-oldv[1])*z[2]/(z[2]-oldv[2]))/w*1e9 else
      if abs(z[2])<abs(z[1])/10 then getoutvar:=z[1]/w*1e9
                            else getoutvar:=0;
      end;
   oldv:=z;
   oldw:=w;
   end;


 end;
//writeln('*');
end;end;

{procedure Tsport.calcRPC(var f : text;vr : toutvar;w : double;V0,Z0 : cvec);
var
 P,R,S : tr;
 C : tc;
begin
with vr do begin
R:=solveN(node,0,v0,z0);
P:=solveN(refnode,0,v0,z0);
C:=solveNC(node,refnode,v0,z0);
C:=C/solveS(node,V0);
C:=C/solveS(refnode,V0)/k4;
S:=cabs2(solveS(node,V0));
R:=R/s/k4;
S:=cabs2(solveS(refnode,V0));
P:=P/s/k4;
//C:=C/R/P;
C:=C/sqrt(R*P);
write(f,R:8:1,P:8:1,C[1]:6:2,C[2]:6:2,2*sqrt(R*P)*(sqrt(1-sqr(C[2]))+C[1]):5:1);
end;end;
}
procedure Tsport.calcRPC(var f : text;vr : toutvar;w : double;V0,Z0 : cvec);
var
 P,R,S,t : tr;
 C : tc;
begin
 if (np<>3) then begin;writeln('Noise parameters only for 2 ports! (',np-1,')');halt(1);end;
 writeln('N=');
 cwriteEng(SN[1,1]);cwriteEng(SN[2,1]);writeln;
 cwriteEng(SN[1,2]);cwriteEng(SN[2,2]);writeln;
 writeln('Y=');
 cwriteEng(YY[1,1]);cwriteEng(YY[2,1]);writeln;
 cwriteEng(YY[1,2]);cwriteEng(YY[2,2]);writeln;
 R:=cabs2(SN[1,1])+cabs2(SN[2,1]);
 P:=cabs2(SN[1,2])+cabs2(SN[2,2]);
 C:=SN[1,1]*ccomp(SN[1,2])+SN[2,1]*ccomp(SN[2,2]);
 S:=YY[1,2,1];

//  if Pin.C<>nil then with pin do begin;t:=C^.getD(wat);end else t:=noiseres;
 R:=R/k4;
 P:=P/k4;
 writeln('gm=',S,' R=',R,' P=',P,' C=');cwrite(C);writeln;
 writeln('Fmin=',2/S*sqrt(R*P)*(sqrt(1-sqr(C[2]))+C[1]));
{with vr do begin
R:=solveN(node,0,v0,z0);
P:=solveN(refnode,0,v0,z0);
C:=solveNC(node,refnode,v0,z0);
C:=C/solveS(node,V0);
C:=C/solveS(refnode,V0)/k4;
S:=cabs2(solveS(node,V0));
R:=R/s/k4;
S:=cabs2(solveS(refnode,V0));
P:=P/s/k4;
//C:=C/R/P;
C:=C/sqrt(R*P);
write(f,R:8:1,P:8:1,C[1]:6:2,C[2]:6:2,2*sqrt(R*P)*(sqrt(1-sqr(C[2]))+C[1]):5:1);
end;}
end;


procedure Tsport.getDoutvar(vr : toutvar;w : double;V0 : cvec;var V : double;ver : integer);
var
 Vc : tc;
 Vc2,Vc3 : double;
 x : integer;
 sc,z : tc;
 ss,nn : double;
begin
  with vr do case wat of
   0 :  begin
         solveDS(node,V0,Vc);
	 sc:=solveS(node,V0);
         V:=2*cinner(sc,Vc);
         end;  
   1 :  begin
          solveDN(node,V0,Vc2);
          V:=Vc2;
	end;
   2 :  begin
         solveDS(node,V0,Vc);
	 sc:=solveS(node,V0);
	 Vc3:=2*cinner(Vc,sc);
         ss:=cabs2(sc);

         solveDN(node,V0,Vc2);
//         nn:=solveN(node,0,V0);

         V:=(ss*Vc2-nn*Vc3)/(ss*ss);
	 writeln('D temp: S=',ss,' N=',nn,' dS=',Vc3,' dN=',Vc2); 
	end;
    else V:=0;
     end;
end;

//*************** Runs ***************
Procedure Tsport.ACanal(w0,w1,dw : double);
var
 w : double;
 v0,z0 : cvec;
 tm : tdatetime;
 x,y,i : integer;
begin
initY:=false;
if Np>1 then begin
  writeln(name,' Unknown ports - asuming shorted!');
  end;
setlength(V0,Np*(Np+1));
for y:=0 to NP do
 for x:=0 to Np-1 do v0[y*np+x]:=czero;
setlength(Z0,Np);
for x:=0 to Np-1 do z0[x]:=czero;
tm:=now;
w:=w0;
write(name,' AC calc f=');
DoInitY;
w1:=w1*1.00001;
while w<=w1 do begin
// writeln;
 writeEng(w/twopi);write(' ');
// write('Y');
    i:=0;
    repeat
     inc(validzz);
     inc(i);
     dorecalc:=false;
     calcY(w);
     if (dorecalc) or (AlwaysUpdate) then begin;doUpdate(w,V0,Z0,i);{writeln(name,': recalc');}end;
    until not(dorecalc) or (i>10);
    if i>10 then writeln('ERROR SOLVING: Recalculating more than 10 times!!!');
// write('N');
 calcN(w);
// write('P');
 printout(V0,Z0,w);
 w:=w+dw;
 end;
tm:=now-tm;
writeln(tm*24*60*60:1:2,'sec ');
end;


function Tsport.optim_eval(P : tvec) : double;
type
 Toptdata = record
  f0,f1,fmin,fmax,fgrad,vz,cx : double;
  end;
var
 OptD : array[1..optmax] of Toptdata;
// f0,w,f1,z,f0b,f1b,fmax,fmin,fmaxb,fminb,fgrad,z2,f0c,f1c,f0d,f1d,f0e,f1e : double;
 w,z,z2 : double;
 x,i,j,k,l,num : integer;
 zz1 : tc;
begin
//write('Eval..');
for j:=1 to optn do with optD[j] do begin
 fmax:=-1;fmin:=0;fgrad:=0;opvar[j].oldw:=0;
 f0:=0;f1:=0;vz:=0;cx:=0;
 end;
 for x:=0 to Ndc-1 do Dcomp[x].c^.setD(P[x],dcomp[X].wat);
  w:=optw;
//  f0:=0;f1:=0;f0b:=0;f1b:=0;f0c:=0;f1c:=0;f0d:=0;f1d:=0;f0e:=0;f1e:=0;
 for i:=1 to optwn do begin
// inc(validzz);
//    write('f');
 if calcfreq then begin
//    write(name,':Y ');
    k:=0;
    repeat
     inc(validzz);
     inc(k);
     dorecalc:=false;
     calcY(w);
     if dorecalc or AlwaysUpdate then doUpdate(w,aplV,aplZ,k);
    until not(dorecalc) or (k>10);
    if k>10 then writeln('ERROR SOLVING: Recalculating more than 10 times!!!');
    //write('w');
    calcN(w);
    //write('e');
    end;
//    write('l');
 if calclayout and (i=1) then Playout(PClayout)^.calc;
//    write('o');
  for j:=1 to optn do if (i>=optn1[j]) and (i<=optn2[j]) then with optD[j] do begin
//    write('g');
//repeat
    z:=(getoutvar(opvar[j],w,aplV,aplZ));
//    if dorecalc then inc(validzz);
//until not(dorecalc);
    if optnorm[j]>0 then begin
      z2:=(getoutvar(opvar[optnorm[j]],w,aplV,aplZ));
      z:=abs(z-z2);
      if abs(z2)>1e-20 then z:=z/z2 else z:=1e99;
      //zz1:=opvar[optnorm[j]].oldv;
      //z:=cabs2( (opvar[j].oldv+zz1) ); 
      //if z=0 then z:=1e99 else z:=cabs2( (opvar[j].oldv-zz1) )/z;
      end;
//    writeln(j,' ',z);
    if optdata[j].N<>0 then begin
       z2:=-1;
       with optdata[j] do
        for l:=0 to N do 
         if (abs(F[l]-w)/w<1e-4) and (D[l]<>-1) then
           z2:=abs((D[l]-z)/D[l]);
//           z2:=abs((D[l]-z));
       //writeln('data:',w/twopi,z2);
       if z2>0 then z:=z2 else z:=0;
       end;

    f0:=f0+z;
    f1:=f1+z*z;
    case optavg[j] of
     4,5,6,7,14,15,16,17,26,27 : begin
                 if fmax<fmin then begin;fmax:=z;fmin:=z;end else
                 if z>fmax then fmax:=z else
                 if z<fmin then fmin:=z;
                 z2:=abs((z-vz)/(z+vz));
                 if fmax>=fmin then fgrad:=fgrad+z2;
                 vz:=z;
                 if z2>optx[j] then cx:=cx+(z2-optx[j]);
                 end;
    11 : if z>optx[j] then cx:=cx+(z-optx[j]);
    21 : if z<optx[j] then cx:=cx+(optx[j]-z);
    end; //case
   end; //for j

  w:=w+optdw;
  end; //for i
//write('Avg...');  
z:=0;
//exit;
for j:=1 to optn do with optD[j] do begin 
//write('Avg',j);  
 num:=optn2[j]-optn1[j]+1;
 if opvar[j].Ri=5 then dec(num);
  f0:=f0/num;
  f1:=f1/num;
// writeln(name,' Value:',f0);
case optavg[j] of
 1,51 : z:=z+f0*optwgh[j];
 2 : z:=z+sqrt(f1)*optwgh[j];
 3 : if (f0<>0) then z:=z+(f1/(f0*f0)-1)*optwgh[j]; 
 4 : z:=z+(fmax-fmin)/(fmax+fmin)*optwgh[j]/2;
 5 : z:=z+fgrad*optwgh[j]/num/2;
 6 : z:=z+fmax*optwgh[j];
 7 : z:=z+fmin*optwgh[j];
 11,15,21 : z:=z+optwgh[j]*cx/num;
 13 : if (f0<>0) and ((f1/(f0*f0)-1)>optx[j]) then z:=z+optwgh[j]*(f1/(f0*f0)-1-optx[j]);
 14 : if (fmax-fmin)/(f0)>optx[j] then z:=z+optwgh[j]*( (fmax-fmin)/f0-optx[j]);
 16 : if fmax>optx[j] then z:=z+optwgh[j]*(fmax-optx[j]);
 17 : if fmin<optx[j] then z:=z+optwgh[j]*(optx[j]-fmin);
 26 : if fmax<optx[j] then z:=z-optwgh[j]*(fmax-optx[j]);
 27 : if fmin>optx[j] then z:=z-optwgh[j]*(optx[j]-fmin);
-1 : if f0<>0 then z:=z+optwgh[j]/f0;
-2 : if f1<>0 then z:=z+optwgh[j]/f1;
// else
// z:=0;
 end;
//writeln('done');
end;
//writeln('done');

optim_eval:=z;
end;

function avg2str(x : integer;z : double) : string;
begin
 case x of
  -1 : avg2str:='AVG(1/x)';
  -2 : avg2str:='AVG(1/x2)';
   1 : avg2str:='AVG';
   2 : avg2str:='AVG_sqr';
   3 : avg2str:='DEV';
   4 : avg2str:='RANGE';
   5 : avg2str:='GRAD';
   6 : avg2str:='MAX';
   7 : avg2str:='MIN';
   11: avg2str:='AVG(x>'+floattostr(z)+')';
   21: avg2str:='AVG(x<'+floattostr(z)+')';
   13: avg2str:='DEV>'+floattostr(z)+'';
   14: avg2str:='RANGE>'+floattostr(z)+'';
   16: avg2str:='MAX>'+floattostr(z)+'';
   17: avg2str:='MIN<'+floattostr(z)+'';
   26: avg2str:='MAX<'+floattostr(z)+'';
   27: avg2str:='MIN>'+floattostr(z)+'';
   15: avg2str:='AVG(GRAD>'+floattostr(z)+')';
 else avg2str:='?';
 end;
end;
   
  

Procedure Tsport.optim_getdiff(P : tvec;var res : double;ver : integer);
var
 x,i : integer;
 res2 : double;
 w : double;
begin
res2:=0;
  w:=optw;
 for i:=1 to optwn do begin

 makeY(w,YY);
 makeDS(w,DSN,SN,ver);  
{ 
 writeln('DSN=');
 CMwrite(Ndns,Np+Nv,DSN);
 writeln('YY=');
 cmwrite(Np+Nv,Np+Nv,YY);

 writeln('SN=');
 cmwrite(Nns+1,Np+Nv,SN);
} 
// writeln(name,' Solve system ...');
 CMelim(Np+Nv,YY,np,np+nv-1,DSn,Nns+1);
// writeln('DSN=');
// CMwrite(Ndns,Np+Nv,DSN);

//setlength(dV,Ndc);
//getDoutvar(opvar,w,aplV,res2,ver);
{writeln('Dv:');
for x:=1 to Ndc do writeln(res[x-1]);}
  w:=w+optdw;
 res:=res+res2/optwn;
 end;
end;


Procedure Tsport.readoptim(ss : tstrings);
var
 max : integer;
 x,i,cnt1,cnt2,j : integer;
 s,s2 : string;
 C : pcomp;
 f0,f1,f2,f3,step,toll : double;
 P0,dv,P1,P2 : tvec;
 method,maxstep : integer;
 tm : tdatetime;
Procedure method0;
begin
//for x:=1 to 10 do begin
//while (step*max>1e-20) do begin
{
//*** all vars together ***
cnt:=0;
repeat
for i:=0 to Ndc-1 do optim_getdiff(P0,dV[i],i);
 write('Dv  =');for i:=0 to Ndc-1 do write(dV[i],' ');writeln;
//write('Dv/V=');for i:=0 to Ndc-1 do write(dV[i]/P0[i],' ');writeln;
 //exit;
//line seach
 f2:=f0;
// f1:=f0;step:=step*2;
step:=0.1*max;
repeat
 for i:=0 to Ndc-1 do P1[i]:=p0[i]+dv[i]*step;
 f1:=optim_eval(P1);
 if f1*max>f0*max then begin
   f0:=f1;
   for i:=0 to Ndc-1 do P0[i]:=p1[i];
   end else step:=step/2;
 inc(cnt);

 write(' [');for i:=0 to Ndc-1 do write(P1[i],' ');writeln(f1,' ',f0,']');
until (step*Max<1e-6) or (cnt>1e3);

 write('*[');for i:=0 to Ndc-1 do write(P0[i],' ');writeln(f2,' ',f0,']');

until (f2=f0) or (cnt>1e3);
}
{
//*** vars one at time ***
cnt2:=0;
repeat
inc(cnt2);
 f2:=f0;
for i:=0 to Ndc-1 do begin
  optim_getdiff(P0,dV[i],i);
 writeln('Dv',i,' =',dV[i],' ');
//line seach
// f1:=f0;step:=step*2;
 step:=max;
 for j:=0 to Ndc-1 do P1[j]:=P0[j];
 cnt1:=0;
repeat
 P1[i]:=p0[i]+dv[i]*step;
 f1:=optim_eval(P1);
 if f1*max>f0*max then begin
   f0:=f1;
   P0[i]:=p1[i];
   end else step:=step/2;
 inc(cnt1);
 writeln(' [',P1[i],' ',f1,' ',f0,']');
until (step*Max<1e-6) or (cnt1>1e2);

end; //one var

 write('*[');for i:=0 to Ndc-1 do write(P0[i],' ');writeln(f2,' ',f0,']');
until (f2=f0) or (cnt2>1e2);
}
end;

Procedure methodComplex;
const
 kmax = 100;
var
 D  : array[1..kmax] of tvec;
 F  : array[1..kmax] of double;
 c,xr : tvec;
 Fr : double;
 i,j,k,nmin,nmax,st,st2 : integer;
begin
k:=30;st:=0;
randomize;
for j:=1 to k do setlength(D[j],Ndc);
setlength(c,Ndc);
setlength(xr,Ndc);
for i:=0 to Ndc-1 do D[1,i]:=P0[i];
for i:=0 to Ndc-1 do c[i]:=P0[i];
F[1]:=optim_eval(D[1]);
for j:=2 to k do begin
  for i:=0 to Ndc-1 do with Dcomp[i] do if lmin and lmax then D[j,i]:=min+random()*(max-min) else begin;writeln('Complex: Spesify max & min!');halt(1);end;
  F[j]:=optim_eval(D[j]);
  while F[j]>1e3 do begin
    for i:=0 to Ndc-1 do D[j,i]:=(D[j,i]+P0[i])/2;
    F[j]:=optim_eval(D[j]);
    end;
 writeln(j,' ',F[j]);
 end;

nmin:=1;nmax:=1;
for j:=2 to k do if F[j]<F[nmin] then nmin:=j;
for j:=2 to k do if F[j]>F[nmax] then nmax:=j;

for i:=0 to Ndc-1 do c[i]:=D[1,i];
for j:=2 to k do Vadd(Ndc,c,D[j],1);
vrmaal(Ndc,c,1/(k-1));

repeat
//if st mod 100=0 then begin
  write(st:5);writeEng(F[nmax]);writeEng(F[nmin]);writeln;
//  end;
for i:=0 to Ndc-1 do c[i]:=c[i]-D[nmax,i]/(k-1);

 for i:=0 to Ndc-1 do xr[i]:=D[nmax,i]+2*(c[i]-D[nmax,i]);
 for i:=0 to Ndc-1 do with Dcomp[i] do if xr[i]<min then xr[i]:=min else if xr[i]>max then xr[i]:=max;

 Fr:=optim_eval(xr);
 st2:=0;
 while (Fr>=F[nmax]) and (st2<5) do begin
// writeEng(Fr);write('>');writeEng(F[nmax]);writeln;
  for i:=0 to Ndc-1 do xr[i]:=(xr[i]+c[i])/2;
  for i:=0 to Ndc-1 do with Dcomp[i] do if xr[i]<min then xr[i]:=min else if xr[i]>max then xr[i]:=max;
  Fr:=optim_eval(xr);
  inc(st2);
 end;
if st2=5 then begin
  for i:=0 to Ndc-1 do xr[i]:=c[i]+(5-random()*10)*(xr[i]-c[i]);
  for i:=0 to Ndc-1 do with Dcomp[i] do if xr[i]<min then xr[i]:=min else if xr[i]>max then xr[i]:=max;
  end;

 for i:=0 to Ndc-1 do c[i]:=c[i]+(xr[i])/(k-1);
 for i:=0 to Ndc-1 do D[nmax,i]:=xr[i];
 F[nmax]:=Fr;

 nmin:=1;nmax:=1;
 for j:=2 to k do if F[j]<F[nmin] then nmin:=j;
 for j:=2 to k do if F[j]>F[nmax] then nmax:=j;
 inc(st);

until (st>maxstep);// or ( (F[nmax]-F[nmin])/(F[nmax]+F[nmin]) < 2 );
  
end;

function randm() : double;
var
 z : double;
 i : integer;
begin
z:=0;
for i:=1 to 100 do z:=z+random();
randm:=z/100-0.5;
end;

function randn() : double;
var
 z : double;
 i : integer;
begin
z:=0;
for i:=1 to 100 do z:=z+random();
randn:=(z-50)/2.3; //7.3 vir 1000
end;

Procedure testVarminMax(var Dcomp : Tdvar;var z : double);
begin
  if (Dcomp.lstp) then z:=round(z/Dcomp.stp)*Dcomp.stp;
  if (Dcomp.lmin) and (z<Dcomp.min) then begin;z:=Dcomp.min;end;
  if (Dcomp.lmax) and (z>Dcomp.max) then begin;z:=Dcomp.max;end;
end;

Procedure methodEv;
const 
 MaxE = 1000;
var
 D  : array[1..maxE] of tvec;
 Vl : array[1..maxE] of double;
 i,j,k,l,m,Nev,Nkeep,s,s0 : integer;
 z,mx,f0: double;
begin
randomize;
if optparam2=0 then begin
  Nev:=Ndc*5;
  if Nev<50 then Nev:=50;
  end else Nev:=round(optparam2);
if optparam3=0 then begin
   Nkeep:=Ndc;
   if Nkeep<10 then Nkeep:=10;
   end else Nkeep:=round(optparam3);
 
 for i:=1 to Nev do setlength(D[i],Ndc);
 for j:=0 to Ndc-1 do D[1,j]:=P0[j];
 for i:=2 to Nev do
  for j:=0 to Ndc-1 do if random()>optParam1 then begin 
       z:=randm()*10; 
      //writeln('z=',z);
      if z>0 then D[i,j]:=P0[j]*(1+z)
             else D[i,j]:=P0[j]/(1-z);
      testVarminMax(Dcomp[j],D[i,j]);
    end; 

 for i:=1 to Nev do Vl[i]:=optim_eval(D[i]);
//sort - slow
   

// mx:=vl[1];
// for i:=2 to Nev do if vl[i]*max>mx*max then mx:=vl[i];
s:=0;s0:=0;
f0:=vl[1];
repeat
 for i:=1 to Nev do for j:=Nev downto i+1 do if Vl[j]*max>vl[j-1]*max then begin
   vl[Nev+1]:=vl[j];vl[j]:=vl[j-1];vl[j-1]:=vl[nev+1];D[Nev+1]:=D[j];D[j]:=D[j-1];D[j-1]:=D[nev+1];end;
// z:=0;
// for i:=1 to Nev do z:=z+vl[i];
// z:=z/Nev;
 
{ 
 j:=0;
 for i:=Nev downto 1 do if vl[i]*max<z*max then begin
  vl[Nev+1]:=vl[i];vl[i]:=vl[Nev-j];vl[Nev-j]:=vl[nev+1];
  D[Nev+1]:=D[i];D[i]:=D[Nev-j];D[Nev-j]:=D[nev+1];
  inc(j);
  end;
}
// writeEng(mx);write(':');
// for i:=1 to 1 do writeEng(vl[i]);
  writeEng(vl[1]);
// write('(',s0,',',f0,')');
// writeln;
if (f0<>0) and ( abs( vl[1]/f0-1 )>1e-5 ) then begin;s0:=s;f0:=vl[1];end;
  
 for i:=Nkeep+1 to Nev do begin
   k:=floor(random()*(Nkeep))+1;
   l:=floor(random()*(Nkeep-1))+1;
   if l>=k then l:=l+1;
   z:=random();
   for m:=0 to Ndc-1 do begin
     D[i,m]:=z*D[k,m]+(1-z)*D[l,m];
     z:=random();
     if z<0.05 then begin
       z:=randm()*3; 
      //writeln('z=',z);
      if z>0 then D[i,m]:=D[i,m]*(1+z)
             else D[i,m]:=D[i,m]/(1-z);
      end;
      testVarminMax(Dcomp[m],D[i,m]);

      end; //for m
   vl[i]:=optim_eval(D[i]);
//   if vl[i]*max>mx*max then mx:=vl[i];
   end; //for i
inc(s);
if (f0<>0) and ( abs( vl[1]/f0-1 )>toll ) then begin;s0:=s;f0:=vl[1];end;
until (s=maxstep) or (s>s0+5);

for i:=0 to Ndc-1 do P0[i]:=D[1,i];
writeln;
end;

Procedure methodRnd;
var
 N : array[0..1000] of double;
 f0,f1,f1b,f2 : double;
 i,sp,sp2,nexit : integer;
begin
 setlength(P2,Ndc);
 for i:=0 to Ndc-1 do N[i]:=abs(P0[i])/10;
 f0:=optim_eval(P0);
 randomize;
sp:=0;sp2:=0;
nexit:=round(optparam2);
if nexit<500 then nexit:=500;
repeat
 for i:=0 to Ndc-1 do if random()>optParam1 then begin
  P1[i]:=randn()*N[i]+P0[i];
      testVarminMax(Dcomp[i],P1[i]);
  end else P1[i]:=P0[i];
 f1:=optim_eval(P1);
 
 
 if (f1*max>f0*max) then begin
 sp2:=sp;
 repeat
  for i:=0 to Ndc-1 do begin
   P2[i]:=2*P1[i]-P0[i];
      testVarminMax(Dcomp[i],P2[i]);
   end;
  f2:=optim_eval(P2);
  f1b:=f1;
  if f2*max>f1*max then begin
     for i:=0 to Ndc-1 do P1[i]:=P2[i];
     f1:=f2;//write('x');
     end;
 until f2*max<=f1b*max;
 
// for i:=0 to Ndc-1 do N[i]:=P0[i]/10;
//  for i:=0 to Ndc-1 do if abs((P1[i]-P0[i])/N[i])>1 then 
  for i:=0 to Ndc-1 do N[i]:=( N[i]+abs(P1[i]-P0[i]) ) /2;
  for i:=0 to Ndc-1 do P0[i]:=P1[i];
  f0:=f1;
//  writeln(sp,':',f0);
  end else begin
   for i:=0 to Ndc-1 do if abs((P1[i]-P0[i])/N[i])>1 then N[i]:=N[i]/1.01;
  end;
//  if random()<0.005 then for i:=0 to Ndc-1 do N[i]:=abs(P1[i])/10;
if sp mod 100=0 then  begin
// writeEng(f0);
 write(sp div 100:5,'[');for i:=0 to Ndc-1 do writeEng(P0[i]);write(']=');writeEng(f0);writeEng(f1);writeln;
// for i:=0 to Ndc-1 do write(N[i]/P0[i]:7:3);
// writeln;
 end;
inc(sp);
until (sp>=maxstep*100) or (sp>sp2+nexit);
writeln;
end;

Procedure method1;
var
 i,j : integer;
begin
 setlength(P2,Ndc);
cnt2:=0;
repeat
inc(cnt2);
 f3:=f0;
for i:=0 to Ndc-1 do begin
 step:=P0[i]/2;
 if step<1e-15 then step:=1e-15;
 for j:=0 to Ndc-1 do P1[j]:=P0[j];
 for j:=0 to Ndc-1 do P2[j]:=P0[j];
// cnt1:=0;
 for j:=1 to 5 do begin
   P1[i]:=p0[i]+step;
      testVarminMax(Dcomp[i],P1[i]);
//   writeln('p1=',P1[i]);
   f1:=optim_eval(P1);
   P2[i]:=p0[i]-step;
      testVarminMax(Dcomp[i],P2[i]);
//   writeln('p2=',P2[i]);
   f2:=optim_eval(P2);
 if (f1*max>f0*max) and (f1*max>f2*max) then begin
   f0:=f1;
   P0[i]:=p1[i];
   end else 
 if (f2*max>f0*max) then begin
   f0:=f2;
   P0[i]:=p2[i];
   end;
   step:=step/2;
//  writeln(' [',step,' ',f1,' ',f2,' ',f0,']');
 end; //for f
end; //one var

 write(cnt2:5,'[');for i:=0 to Ndc-1 do writeEng(P0[i]);write(']=');writeEng(f0);writeln;
// write('*[');for i:=0 to Ndc-1 do write(P0[i],' ');writeln(f3,' ',f0,']');
until (f0=0) or (abs((f3-f0)/f0)<toll) or (cnt2>maxstep);
if cnt2>maxstep then writeln('  Count=max') else writeln('  Solution has Converged!');
end; {method 1}

Procedure step2;
var
 i,j,m : integer;
begin
m:=0;
for i:=0 to Ndc-1 do begin
 step:=Dcomp[i].step;
// if step<1e-15 then step:=1e-15;
 for j:=0 to Ndc-1 do P1[j]:=P0[j];
// for j:=0 to Ndc-1 do P2[j]:=P0[j];
// cnt1:=0;
 for j:=1 to 3 do begin
  f2:=f0;
if m<>1 then begin
   if (abs(p0[i])<1e-20) and Dcomp[i].lmax then P1[i]:=Dcomp[i].max/10*step else
   P1[i]:=p0[i]*step;
      testVarminMax(Dcomp[i],P1[i]);
   f1:=optim_eval(P1);
   if (f1*max>f0*max) then begin
     if m=-1 then step:=step*2-1;
     f2:=f0;m:=-1;
     f0:=f1;
     P0[i]:=p1[i];
     end;
end;
if m<>-1 then begin
//   writeln('p1=',P1[i]);
   if (abs(p0[i])<1e-20) and Dcomp[i].lmin then P1[i]:=Dcomp[i].min/10*step else
   P1[i]:=p0[i]/step;
      testVarminMax(Dcomp[i],P1[i]);
//   writeln('p2=',P2[i]);
   f1:=optim_eval(P1);
  if (f1*max>f0*max) then begin
    if m=1 then step:=step*2-1;
    f1:=f0;m:=1;
    f0:=f1;
    P0[i]:=p1[i];
   end;
end;
 if f2=f0 then begin
   step:=0.5+step/2;
   m:=0;
   end;
   
//  writeln(' [',step,' ',f1,' ',f2,' ',f0,']');
 end; //for f
 Dcomp[i].step:=step;
end; //one var
end;

Procedure method2;
var
 i,j,cnt3,cnt4 : integer;
begin
 setlength(P2,Ndc);
cnt2:=0;cnt4:=0;
for i:=0 to Ndc-1 do Dcomp[i].step:=2;
repeat
inc(cnt2);
 f3:=f0;
 for j:=0 to Ndc-1 do P2[j]:=P0[j];
 step2;
// write(' s:',f0:0:0);
 for j:=0 to Ndc-1 do P2[j]:=P0[j]-P2[j];
// while f0*max>f4*max do begin
 f1:=f0;cnt3:=0;
repeat 
  f0:=f1;
   for j:=0 to Ndc-1 do begin
     P1[j]:=P0[j]+P2[j];
      testVarminMax(Dcomp[j],P1[j]);
     end;
   f1:=optim_eval(P1);
// write(' x:',f1:0:0);
   if (f1*max)>(f0*max) then begin
    for j:=0 to Ndc-1 do P0[j]:=P1[j];
    inc(cnt4);
    end;
  inc(cnt3);
until (f1*max<=f0*max) or (cnt3=10);
 
 
 write(cnt2:5,'[');for i:=0 to Ndc-1 do writeEng(P0[i]);write(']=');writeEng(f0);writeln;
until (f0=0) or ( (abs((f3-f0)/f0)<toll) and (cnt2>2) ) or (cnt2>maxstep);
writeln('   Extrapolation steps=',cnt4);
if cnt2>maxstep then writeln('  Count=max') else writeln('  Solution has Converged!');
end; {method 2}
 

Procedure method3;
var
 i,j,m : integer;
begin
 setlength(P2,Ndc);
cnt2:=0;
m:=0;
for i:=0 to Ndc-1 do Dcomp[i].step:=2;
repeat
inc(cnt2);
 f3:=f0;
for i:=0 to Ndc-1 do begin
 step:=Dcomp[i].step;
// if step<1e-15 then step:=1e-15;
 for j:=0 to Ndc-1 do P1[j]:=P0[j];
 for j:=0 to Ndc-1 do P2[j]:=P0[j];
// cnt1:=0;
 for j:=1 to 3 do begin
if m<>1 then begin
   P1[i]:=p0[i]*step;
      testVarminMax(Dcomp[i],P1[i]);
   f1:=optim_eval(P1);
end;
if m<>-1 then begin
//   writeln('p1=',P1[i]);
   P2[i]:=p0[i]/step;
      testVarminMax(Dcomp[i],P2[i]);
//   writeln('p2=',P2[i]);
   f2:=optim_eval(P2);
end;
 if (f1*max>f0*max) and (f1*max>f2*max) then begin
   if m=-1 then step:=step*2-1;
   f2:=f0;m:=-1;
   f0:=f1;
   P0[i]:=p1[i];
   end else 
 if (f2*max>f0*max) then begin
   if m=1 then step:=step*2-1;
   f1:=f0;m:=1;
   f0:=f2;
   P0[i]:=p2[i];
   end else begin
   step:=0.5+step/2;
   m:=0;
   end;
   
//  writeln(' [',step,' ',f1,' ',f2,' ',f0,']');
 end; //for f
 Dcomp[i].step:=step;
end; //one var

 write(cnt2:5,'[');for i:=0 to Ndc-1 do writeEng(P0[i]);write(']=');writeEng(f0);writeln;
until (f0=0) or (abs((f3-f0)/f0)<toll) or (cnt2>maxstep);
if cnt2>maxstep then writeln('  Count=max') else writeln('  Solution has Converged!');
end; {method 3}

Procedure methodasco;
const
 filename='ascos';
var
 fin,fout : cint;
 fds : tfdset;
 f1 : double;
 x,i : integer;
begin
writeln('Write asco config');
asco_writeconfig(filename,Dcomp);

//exec('rm ascowait');
//exec('mkfifo ascowait');
writeln('Opening pipe');
x:=0;
repeat
 fout:=fpopen('ascowait2',O_WrOnly);
 if fout=0 then begin;writeln('Can''t open out!');halt(1);end;
// fpwrite(fin,x,sizeof(x));
//fin :=fpopen('ascowait' ,O_RdOnly);
//if fin=0 then begin;writeln('Can''t open in!');halt(1);end;
// fpClose(fout);
// write('W');
// fpfd_zero(fds);
// fpfd_set(fin,fds);
// fpselect(fin+1,@fds,nil,nil,0);
// x:=fpread(fin,x,sizeof(x));
// write('R');
 asco_readvars(P1,Ndc,'fskppk.txt');
for i:=0 to Ndc-1 do begin
      testVarminMax(Dcomp[i],P1[i]);
 end;
 f1:=optim_eval(P1);
 inc(x);
if x mod 10=0 then begin
 write(x:5,'[');for i:=0 to Ndc-1 do writeEng(P1[i]);write(']=');writeEng(f1);writeln;
//  writeEng(f1);
  end;
// write('F');
 asco_writefunc('fskppk.out','FF',f1);
//  fpClose(fin);
 fpClose(fout);
 fpselect(1,nil,nil,nil,10);
until x>maxstep;
end;

Procedure methodX;
procedure swap(var d : double);
type
 Tp = array[1..8] of byte;
 pp = ^Tp;
var
 p : PP;
 b : byte;
begin
 p:=PP(@d);
 b:=p^[1];p^[1]:=p^[8];p^[8]:=b;
 b:=p^[2];p^[2]:=p^[7];p^[7]:=b;
 b:=p^[3];p^[3]:=p^[6];p^[6]:=b;
 b:=p^[4];p^[4]:=p^[5];p^[5]:=b;
end;

var
 fin,fout : cint;
 s : string;
 a,i,j : longint;
 z,min : double;
 N : longint;
 fds : tfdset;
begin
write('Opening pipes: Res ...');
fout:=fpopen('nslv2_res',O_WrOnly);
write(' Vr ...');
fin :=fpopen('nslv2_vr' ,O_RdOnly);
if fout=0 then begin;writeln('Can''t open out!');halt(1);end;
if fin=0 then begin;writeln('Can''t open in!');halt(1);end;
writeln(' Done!');

N:=Ndc;
writeln('Writing num variables ',sizeof(N));
fpwrite(fout,N,sizeof(N));

writeln('Writing initial values,lower,upper');
fpwrite(fout,P0[0],sizeof(z)*N);

for i:=0 to Ndc-1 do 
  if (Dcomp[i].lmin) then P1[i]:=Dcomp[i].min else P1[i]:=1e20;
fpwrite(fout,P1[0],sizeof(z)*N);
  
for i:=0 to Ndc-1 do 
  if (Dcomp[i].lmax) then P1[i]:=Dcomp[i].max else P1[i]:=1e20;
fpwrite(fout,P1[0],sizeof(z)*N);

writeln('Waiting ...');
j:=0;
repeat
inc(j);
//writeln('Waiting ...');
fpfd_zero(fds);
fpfd_set(fin,fds);
fpselect(fin+1,@fds,nil,nil,0);

//writeln('Reading ',j);
i:=fpread(fin,P1[0],sizeof(z)*N);
for a:=0 to N-1 do swap(P1[a]);

if i<sizeof(z)*N then begin
  writeln('Closing ...');
  fpClose(fout);
  fpClose(fin);
  exit;
  end;
//for a:=1 to N do write(d[a],' ');writeln;

if j mod 10=0 then begin;write(j:5);writeEng(min);end;
z:=optim_eval(P1);
if (j=1) or (z<min) then begin
  min:=z;
  for a:=0 to N-1 do P0[a]:=P1[a];
  end;
fpwrite(fout,z,sizeof(z));
until false;

end;

procedure readoptdata(j : integer;f : string);
var
 fn : text;
 x,c : integer;
 z : double;
 n : integer;
begin
x:=pos(':',f);c:=2;
if x>0 then begin;c:=ord(f[x+1])-ord('0');delete(f,x,2);end;
writeln('loaddata from',f,' col',c);
assign(fn,f);
reset(fn);
read(fn,n);
setlength(optdata[j].F,n);
setlength(optdata[j].D,n);
optdata[j].N:=N;
n:=0;
while not(eof(fn)) do begin
 read(fn,z);
 optdata[j].F[n]:=z*twopi;
 write(n,z);
 for x:=1 to c-1 do read(fn,z);
 optdata[j].D[n]:=z;
 writeln(z);
 readln(fn);
 inc(n);
 end;
close(fn);
end;

Procedure saveoptim(f : string;s : string;z : double);
var
 fn : text;
begin
assign(fn,f);append(fn);writeln(fn,s,'=',z);close(fn);
end;

//Main readoptim 
var
P : tparams;
saveD,loadD : string;
z,freq1,freq2 : double;
begin
subset(ss,Nset,sets);
//for x:=1 to len(ss) do write(ss[x],' ');writeln;
loadD:='';saveD:='';
 tm:=now;optn:=0;
 initY:=false;
 for x:=1 to optmax do opvar[x].wat:=-99;
//setlength(P,l);
 i:=0;
 calclayout:=false;
 calcfreq:=false;
 for x:=2 to len(ss) do if pos('=',ss[x])>0 then begin
//  writeln('Reading ',ss[x]);
  inc(i);
  setlength(P,i);
  P[i-1]:=getprm(ss[x]);
  with P[i-1] do
    if (name[1]='F') and (name[2] in ['1'..'9']) then begin
      j:=ord(name[2])-ord('0');
      if name[3] in ['0'..'9'] then j:=j*10+(ord(name[3])-ord('0'));
//      writeln('loading optf',j);
      if (j>optn) then optn:=j;
      if (j>optmax) then begin;writeln('number of optimisation variables larger than maximum (',optmax,')');halt(1);end;
      opvar[j]:=readoutvar(value); 
      optdata[j].N:=0;
      if opvar[j].wat=50 then calclayout:=true else calcfreq:=true;
     end else 
    if name='LOADVAR' then loadD:=value else
    if name='SAVEVAR' then saveD:=value else
    if (name[1]='D') and (name[2] in ['1'..'9']) then begin
      j:=ord(name[2])-ord('0');
      if name[3] in ['0'..'9'] then j:=j*10+(ord(name[3])-ord('0'));
      readoptdata(j,value);
      end;
end;
//writeln('Optim tst');

optParam1:=getparm(i,P,'P1',0);
optParam2:=getparm(i,P,'P2',0);
optParam3:=getparm(i,P,'P3',0);
Ndc:=len(ss)-1-i;
freq1:=getparm(i,P,'START',1e9);
freq2:=getparm(i,P,'STOP',1e9);
optw:=freq1*twopi;
optdw:=freq2*twopi-optw;
optwn:=round(optdw/(getparm(i,P,'STEP',1e9)*twopi))+1;
if optwn>1 then optdw:=optdw/(optwn-1) else optdw:=0;
max:=round(getparm(i,P,'DIR',1));
for j:=1 to optn do optavg[j]:=round(getparm(i,P,'AVG'+inttostr(j),0));
for j:=1 to optn do optnorm[j]:=round(getparm(i,P,'N'+inttostr(j),0));
for j:=1 to optn do optx[j]:=(getparm(i,P,'EX'+inttostr(j),0));
for j:=1 to optn do optwgh[j]:=(getparm(i,P,'WGH'+inttostr(j),1));
for j:=1 to optn do begin
  Z:=getparm(i,P,'START'+inttostr(j),freq1);
  if optwn>1 then optn1[j]:=round((z-freq1)*twopi/optdw)+1 else optn1[j]:=1;
  Z:=getparm(i,P,'STOP'+inttostr(j),freq2);
  if optwn>1 then optn2[j]:=round((z-freq1)*twopi/optdw)+1 else optn2[j]:=1;
  end;
maxstep:=round(getparm(i,P,'MAXSTEPS',100));
toll:=getparm(i,P,'TOLL',1e-3);
for j:=1 to optn do 
 if opvar[j].wat=-99 then begin
  writeln('Optimizing variable ',j,' not found!');
  exit;
 end;
// else writeln('Optimizing ',opvar.wat);
// opvar:=readoutvar(ss[2]);
// opvar2:=readoutvar('SIGNAL:U);'
 delete(ss[1],1,6);ss[1]:=uppercase(ss[1]);
if ss[1]='STEP1' then method:=1 else
if ss[1]='STEP2' then method:=2 else 
if ss[1]='RAND' then method:=3 else 
if ss[1]='RANDS' then method:=5 else 
if ss[1]='EXTERNAL' then method:=6 else
if ss[1]='COMP' then method:=4 else 
if ss[1]='ASCO' then method:=7 else method:=0;
//Reading input card
// Ndc:=len(ss)-2;
 setlength(Dcomp,Ndc);
 i:=0;
 if loadD<>'' then write(name,' Loading: ');
 for x:=2 to len(ss) do if pos('=',ss[x])=0 then begin
   readDvar(Dcomp[i],ss[x],@self);
   if loadD<>'' then with Dcomp[i] do begin
     if loadvar(loadD,Dcomp[i],z) then begin
       c^.setD(z,wat);
       write(' ',c^.name,':',c^.paramstr(wat),'=');writeEng(z);
     end;end;
   inc(i);
   end;
if loadD<>'' then writeln;

 if max>0 then write(name,' Maximizing ') 
  else write(name,' Minimizing');
write(' vars=',Ndc,'  functions=',optn,' freq steps=',optwn,' (from ');writeEng(optw/twopi);write(' stepsize=');writeEng(optdw/twopi);writeln(')'); 
write('  Optimizing function=');
for j:=1 to optn do begin
  write('  ');
  writeEng(optwgh[j]);
  write('*',var2str(opvar[j]),':',avg2str(optavg[j],optx[j]));
  end;
writeln;
case method of 
 1 : writeln('  Using step method 1');
 2 : writeln('  Using step method 2');
 3 : writeln('  Using random method');
 4 : writeln('  Using complex method');
 5 : writeln('  Using random step method');
 6 : writeln('  Using external method: Reading "nslv_vr", Writing "nslv_res"  ');
 7 : writeln('  Using ASCO');
 else begin
  writeln('  Unknown optimisation method ',ss[1]);
  exit;
  end;
 end;

   
setlength(aplV,np*(np+1));
for j:=0 to np do
 for i:=0 to np-1 do aplV[j*np+i]:=czero;
setlength(aplZ,np);
for i:=0 to np-1 do aplZ[i]:=czero;
//for i:=0 to nc-1 do Comp[i]^.savedata:=true;
//for i:=0 to nc-1 do if comp[i]^.tiepe='CKT' then comp[i]^.savedata:=false;
//for i:=0 to nc-1 do if comp[i]^.tiepe='CKT' then psport(comp[i])^.nsavedata:=0;

setlength(Dv,Ndc);
//optw:=twopi*1e9;
//Initial value
 setlength(P0,Ndc);
 setlength(P1,Ndc);
for x:=0 to Ndc-1 do P0[x]:=Dcomp[x].c^.getD(Dcomp[x].wat);

//optim(@self,P0,Ndc);
//First point
//writeln('First point,,,');
DoInitY;
for i:=0 to Ndc-1 do testVarminMax(Dcomp[i],P0[i]);

 write('    0[');for i:=0 to Ndc-1 do writeEng(P0[i]);write(']=');

f0:=optim_eval(P0);
//exit; 
 writeEng(f0);writeln;
{f0:=optim_eval(P0);
 write('[');for i:=0 to Ndc-1 do write(P0[i],' ');writeln(f0,']');
}
if maxstep>0 then
case method of 
 1 : method1;
 2 : method2;
// 3 : method3;
 3 : methodEv;
 4 : methodComplex;
 5 : methodRnd;
 6 : methodX;
 7 : methodasco;
 end; 

tm:=now-tm;

//Write output
 f0:=optim_eval(P0);
 Writeln('  Optimum = ',f0,' Time=',tm*24*60*60:1:2,'sec '); 
 writeln('  Solution=');
for i:=1 to Ndc do with Dcomp[i-1] do begin
   write('     ',c^.tiepe,':',c^.name,':',C^.paramstr(wat),'=');
   writeEng(c^.getD(wat));writeln;
 end;
if saveD<>'' then begin
 writeln('Saving variables to ',saveD);
 for i:=1 to Ndc do with Dcomp[i-1] do savevar(saveD,Dcomp[i-1],c^.getD(wat),i=1);
 saveoptim(saveD,'*Optim',f0);
 for j:=optn downto 2 do if optwgh[j]<>0 then begin
   dec(optn);
   if optavg[j]<10 then begin
    f1:=optim_eval(P0);
    saveoptim(saveD,'*'+inttostr(j)+') '+var2str(opvar[j])+':'+avg2str(optavg[j],optx[j]),(f0-f1)/optwgh[j]);
    f0:=f1;
    end;
   end;
   if optwgh[1]<>0 then saveoptim(saveD,'*1) '+var2str(opvar[1])+':'+avg2str(optavg[1],optx[j]),f0/optwgh[1]);

  end; //if saveD
end;//readoptim


// *************** Reading components ****************
function Tsport.getnode(s : string) : integer;
var
 x : integer;
begin
//writeln(name,' getnode: ',s);
if s[1] in ['+','-'] then delete(s,1,1);
x:=0;
while (x<Nv+Np) and (s<>Sp[x]) do inc(x); 
if x=Nv+Np then begin
 inc(Nv);
 setlength(Sp,Nv+Np);
 Sp[x]:=s;
 end;
getnode:=x;
end;

function Tsport.getnodei(s : string) : integer;
var
 x : integer;
begin
x:=0;
while (x<Ni) and (s<>Spi[x]) do inc(x); 
if x=Ni then begin
 inc(Ni);
 setlength(Spi,Ni);
 Spi[x]:=s;
 end;
getnodei:=x;
end;

function ReadRI(s3 : string) : integer;
begin
    if s3='RE' then readRI:=1 else
    if s3='IM' then readRI:=2 else
    if s3='MAG' then readRI:=3 else
    if s3='DB' then readRI:=4 else
    if s3='DELAY' then readRI:=5 else
    if s3='OSC' then readRI:=6 else
    if s3='OSC2' then readRI:=7 else 
    if s3='OSC2I' then readRI:=8 else 
    if s3='OSCS' then readRI:=9 else 
    if s3='ANG' then readRI:=10 else
    if s3='ANG2' then readRI:=12 else
    if s3='IRE' then readRI:=11 else 
    if s3='IIM' then readRI:=13 else 
    if s3='CIM' then readRI:=14 else //-IM = complex conj 
    if s3='MAG2' then readRI:=23 else
    readRI:=0;
end;


function Tsport.readoutvar(S : string) : toutvar;
var
 j,i : integer;
 r : toutvar;
 s1,s2,s3 : string;
begin
//writeln('readoutvar ',s);
   j:=pos(':',s);
   R.Ri:=0;
   r.oldw:=0;
   r.Comp:=@self;
with r do
   if j=0 then begin
    s:=uppercase(s);
    wat:=-1;
    if s='K' then begin;doinv:=true;wat:=30;end else
    if s='NPARAM' then begin;wat:=35;node:=0;end else
    if s='FMIN' then begin;wat:=35;node:=10;end else
    if s='RN' then begin;wat:=35;node:=2;end else
    if s='RN50' then begin;wat:=35;node:=9;end else
    if s='TOPT' then begin;wat:=35;node:=8;end else
    if s='REFLECT_OPT' then begin;wat:=35;node:=2;end else
    if s='TN' then begin;wat:=35;node:=6;end else
    if s='2TN' then begin;wat:=35;node:=7;end else
    if s='NIPARAM' then wat:=34 else
    if s='YPARAM' then wat:=32 else 
    if s='SPARAM' then wat:=33 else 
    if s='FREQ' then begin;wat:=-1;node:=0;end else
    if s='LOG_FREQ' then begin;wat:=-1;node:=1;end else writeln(name,' unknown print card ',s); 
    end else begin
    s1:=copy(s,1,j-1);
    s2:=copy(s,j+1,length(s)-j);
   r.Comp:=findcomp(s1);
  if (r.comp<>nil) then if ( copy(s2,1,3)='YIN' ) then wat:=20
                   else if ( copy(s2,1,7)='REFLECT') then wat:=21
                   else if ( copy(s2,1,3)='REF') then wat:=22
                   else if ( copy(s2,1,3)='ZIN') then wat:=23;
  if wat in [20..23] then begin
   delete(s2,1,4);
    j:=pos(':',s2);
    if j=0 then s3:='' else begin
      s3:=uppercase(copy(s2,j+1,length(s2)-j));
      s2:=copy(s2,1,j-1);
      end;
    RI:=readRI(s3);
    val(s2,node,i);     
//   writeln('Yin: Comp=',comp^.name,' port=',node);
   doinv:=true;nsavedata:=0;savedata:=true;//writeln(name,' use invertion');
   end
   else if (r.Comp<>nil) and (R.Comp^.tiepe='CKT') then begin
        //r.wat:=99;
        r.RI:=Psport(R.comp)^.addoutvar(s2,i);
        r.wat:=i;
//      writeln(name,' READOUTVAR - EXTERNAL wat=',i);
        if i in [101,102,107,110,120..122] then begin;doinv:=true;nsavedata:=0;savedata:=true;{writeln(name,' use invertion');}end;
        if i in [101,102]  then with Psport(R.comp)^ do begin;doinv:=true;nsavedata:=0;savedata:=true;{writeln(name,' use invertion');}end;
     end else begin
    r.Comp:=@self;
    s1:=uppercase(s1);
//    s2:=copy(s,j+1,length(s)-j);
//     writeln('READOUTVAR - INTERNAL=',s1,' : ',s2);
    if s1='MMINA' then wat:=39;
    if s1='COMP' then wat:=40;
    if s1='COMP2' then wat:=41;
    j:=pos(':',s2);
    if j=0 then s3:='' else begin
      s3:=uppercase(copy(s2,j+1,length(s2)-j));
      s2:=copy(s2,1,j-1);
      end;
    j:=pos('-',s2);
    if j>0 then begin
//      writeln('s=',copy(s2,j+1,length(s2)-j));
      if wat in [39,40,41] then refnode:=strtoint(copy(s2,j+1,length(s2)-j)) 
        else refnode:=getnode(copy(s2,j+1,length(s2)-j));
      s2:=copy(s2,1,j-1);
      end else refnode:=0;
//     writeln('refnode=',refnode);
    RI:=readRI(s3);
//    writeln('RI=',RI);
    wat:=0;
    if s1='NPARAM' then wat:=35 else
    if s1='RPC' then wat:=36 else
    if s1='MMIN' then wat:=37 else
    if s1='MMINV' then wat:=38 else
    if s1='MMINA' then wat:=39 else
    if s1='COMP' then wat:=40 else
    if s1='COMP2' then wat:=41 else
    if s1='LAYOUT' then wat:=50 else
//    if s1='ZIN' then wat:=10 else
//    if s1='M4' then wat:=11 else
    for i:=0 to printSN do if printS[i]=s1 then wat:=i;
    if s1='NOISETERM' then wat:=5; //Just for old circuits
    if (wat=50) and (PClayout=nil) then begin;writeln('No layout!');halt(1);end;
    if wat=50 then val(s2,node,i) else
    if wat in [37,38,39,40,41] then comp:=findcomp(s2) else
    if wat in [35,36,3,4,14] then val(s2,node,i)
                    else node:=getnode(s2);
    if wat in [7,10] then begin;doinv:=true;nsavedata:=0;savedata:=true;end;
    end;end;
//writeln(name,' readoutvar wat=',r.wat);
readoutvar:=r;
end;



function Tsport.findcomp(s : string) : Pcomp;
var
 x : integer;
begin
//if Nc>0 then writeln('Nc=',Nc,' Comp[nc].name=',comp[nc-1]^.name);
 x:=0;
 while (x<Nc) and (comp[x]^.name<>s) do inc(x);
 if x=Nc then findcomp:=nil else findcomp:=comp[x];
end;

function Tsport.findcomp2(s : string) : Pcomp;
var
 x,y : integer;
 s2 : string;
begin
y:=pos(':',s);
if y>0 then begin
 s2:=copy(s,1,y-1);
 delete(s,1,y);
// writeln('Findcomp2 get ',s,' from ',s2);
 end else begin
 s2:=s;
 end;

  x:=0;
  while (x<Nc) and (comp[x]^.name<>s2) do inc(x);
  if x=Nc then findcomp2:=nil else 
  if y<=0 then findcomp2:=comp[x] else begin
   if comp[x]^.tiepe<>'CKT' then begin;writeln(s2,' not a subcircuit!!');halt(1);end;
   findcomp2:=Psport(comp[x])^.findcomp2(s); 
  end;
end;


Procedure Tsport.readspecial(ss : tstrings);
var
 FET : Ptom;
 f : text;
 vds,vgs : double;
begin
FET:=Ptom(findcomp('T'));
if FET=nil then begin
 writeln('Can not find transistor');
 exit;
 end;
assign(f,'DC.txt');
rewrite(f);
vds:=1;
while vds<=3 do begin
vgs:=-0.63;
write(f,vds);
while vgs<=-0.2 do begin
   FET^.OP:=FET^.calc(vgs,vds);
   write(f,' ',FET^.op.ids);
  vgs:=vgs+0.09;
  end;
  writeln(f);
  vds:=vds+0.5;
  end;
close(f);
end;


Procedure Tsport.readanal(ss : tstrings);
var
 P : Tparams;
 x,l : integer;
begin
subset(ss,Nset,sets);
delete(ss[1],1,5);
ss[1]:=uppercase(ss[1]);
if ss[1]='AC' then begin
   l:=len(ss)-1;
   setlength(P,l);
   for x:=1 to l do P[x-1]:=getprm(ss[x+1]);
   ACanal(getparm(l,P,'START',1e9)*twopi,getparm(l,P,'STOP',1e9)*twopi,getparm(l,P,'STEP',1e9)*twopi);
 end else
if ss[1]='LAYOUT' then begin
 if PClayout<>nil then Playout(PClayout)^.calc;
 end else 
  writeln(name,' Can only do AC/LAYOUT analysis');
end;

Procedure Tsport.readset(s : string;ss : Tstrings);
var
 x : integer;
 adds : string;
begin
delete(s,1,4);
x:=pos(' ',s);
if x=0 then exit;
inc(Nset);
setlength(sets,nset);
with sets[nset-1] do begin
 name:=copy(s,1,x-1);
 delete(s,1,x);
 x:=pos('+',name);
 if x>0 then begin
   adds:=name;
   name:=copy(name,1,x-1);
   delete(adds,1,x);
   subset(ss,Nset-1,sets);
   s:='';
   for x:=2 to len(ss) do
     s:=s+adds+ss[x]+' ';
//   writeln('Added ',adds,' s=',s);
   end;
 value:=s;
 end;
if uppercase(sets[nset-1].name)='NOISE-INPUT' then begin
  noiseres:=strtofloat(sets[nset-1].value);
  dec(nset);
  writeln('Setting noise resistant to ',noiseres);
  exit;
  end else
if uppercase(sets[nset-1].name)='SAVEDATA' then begin
  savedata:=true;
  dec(nset);
  writeln('SAVEDATA true');
  exit;
  end;
if uppercase(sets[nset-1].name)='NOSAVEDATA' then begin
  savedata:=false;
  dec(nset);
  writeln(name,' SAVEDATA off');
  exit;
  end;
if uppercase(sets[nset-1].name)='INVERT' then begin
  doInv:=true;
  dec(nset);
  exit;
//  writeln(name,'Invert');
  end;
if uppercase(sets[nset-1].name)='UPDATE' then begin
  AlwaysUpdate:=true;
  dec(nset);
  writeln(name,' Update');
  exit;
  end;
end;

Procedure Tsport.readsetparam(ss : Tstrings);
var
 D : Tdvar;
 z : double;
 x  : integer;
begin
 if len(ss)<3 then begin
   writeln('SETPARAM needs 3 parameters: ',SS[1],' ',ss[2]);
   exit;
   end;
//   writeln('SETPARAM ',SS[1],' ',ss[2],' ',ss[3]);
//writeln(ss[1]);
if ss[1]='SETPARAM:POWER-SCALE' then begin
  readDvar(Pin,ss[2],@self);
  readDvar(Pout,ss[3],@self);
  Pnodes[0,0]:=Pcomp(Pin.C)^.node[0];
  Pnodes[0,1]:=Pcomp(Pin.C)^.node[1];
  Pnodes[1,0]:=Pcomp(Pout.C)^.node[0];
  Pnodes[1,1]:=Pcomp(Pout.C)^.node[1];
  if len(ss)>=5 then begin
    readDvar(Pin2,ss[4],@self);
    readDvar(Pout2,ss[5],@self);
    Pnodes[2,0]:=Pcomp(Pin.C)^.node[0];
    Pnodes[2,1]:=Pcomp(Pin.C)^.node[1];
    Pnodes[3,0]:=Pcomp(Pout.C)^.node[0];
    Pnodes[3,1]:=Pcomp(Pout.C)^.node[1];
    end;
  exit;
  end;
 readDvar(D,ss[2],@self);
// if not(D.c^.paramdouble(D.wat)) then write('*str');
 val(ss[3],z,x);
 if D.c^.paramdouble(D.wat) and (x=0) then begin
//  z:=strtofloat(ss[3]);
  write('SETTING ',ss[2],'=');writeEng(z);writeln;
  with D do c^.setD(z,D.wat)
  end else begin
  writeln('SETTING ',ss[2],'=',ss[3]);
  with D do c^.setD2(ss[3],D.wat)  
  end;
end;


Procedure Tsport.readloadparam(ss : Tstrings);
var
 D : Tdvar;
 z : double;
 x,del : integer;
 S0 : string;
begin
subset(ss,Nset,sets);
 if len(ss)<3 then begin
   writeln('LOADPARAM needs at least 3 parameters: ',SS[1],' ',ss[2]);
   exit;
   end;
//   writeln('SETPARAM ',SS[1],' ',ss[2],' ',ss[3]);
S0:='';del:=0;
for x:=3 to len(ss) do 
// if SS[x,1]='+' then begin;S0:=SS[3];delete(S0,1,1);end else
 if SS[x,1]='-' then begin;del:=length(SS[x])-1;S0:=SS[3];delete(S0,1,1);end else begin
 readDvar(D,ss[x],@self);
 if del>0 then delete(ss[x],1,del);
if loadvar2(ss[2],ss[x],z) then begin
//  z:=strtofloat(ss[3]);
  write('SETTING ',ss[x],'=');writeEng(z);writeln;
  with D do c^.setD(z,D.wat); 
  end;// else writeln('Parameter ',D.c^.name,':',D.wat,' not found in ',ss[2]);
 end;  
end;

Procedure Tsport.readsaveparam(ss : Tstrings);
var
 D : Tdvar;
 z : double;
 x : integer;
begin
subset(ss,Nset,sets);
 if len(ss)<3 then begin
   writeln('SAVEPARAM needs at least 3 parameters: ',SS[1],' ',ss[2]);
   exit;
   end;
for x:=3 to len(ss) do begin   
 readDvar(D,ss[x],@self);
 z:=D.c^.getD(D.wat);
 savevar(ss[2],D,z,false);
// write('SAVING ',ss[x],'=');writeEng(z);writeln(' in ',ss[2]);
 end;
end;

function Tsport.var2str(vr : toutvar) : string;
begin
 with vr do begin
   varnm:='';
   if wat<100 then case RI of 
    1 : varnm:='Re[';
    2 : varnm:='Im[';
    3 : varnm:='Mag[';
    4 : varnm:='DB[';
    5 : varnm:='Delay[';
    6 : varnm:='Osc[';
    7 : varnm:='Osc2[';
    8 : varnm:='Osc2I[';
    9 : varnm:='OscS[';
    10 : varnm:='Ang[';
    12 : varnm:='Ang2[';
    11 : varnm:='Re 1/[';
    13 : varnm:='Im 1/[';
    14 : varnm:='-Im[';
    23 : varnm:='Sqr[';
    end;
   case wat of
   41 : varnm:=varnm+comp^.name+'('+inttostr(refnode)+')';
   40 : varnm:=varnm+comp^.name+'('+inttostr(refnode)+')';
   39 : varnm:=varnm+'Mmin_A';
   38 : varnm:=varnm+'Mmin_vec';
   37 : varnm:=varnm+'Mmin';
   36 : varnm:=varnm+'Temp('+Sp[node]+') Temp('+Sp[refnode]+') Corr Fmin';
   35 : case node of 
       0 : varnm:=varnm+'Nparam(Tmin,Rn,Gn,Gcor,Bcor)';
       1 : varnm:=varnm+'Tmin';
       2 : varnm:=varnm+'Rn';
       3 : varnm:=varnm+'Gn';
       4 : varnm:=varnm+'Ycor';
       5 : varnm:=varnm+'Yopt';
       6 : varnm:=varnm+'Tn';
       7 : varnm:=varnm+'2Tn';
       8 : varnm:=varnm+'Yopt_reflect';
       9 : varnm:=varnm+'Rn/50';
       10 : varnm:=varnm+'Fmin';
       end;
   34 : varnm:=varnm+'Ni_param';
   33 : varnm:=varnm+'Zparam';
   32 : varnm:=varnm+'Yparam';
   50 : varnm:=varnm+'Layout ('+inttostr(node)+')';
   -1 : varnm:=varnm+'FREQ';
    0 : varnm:=varnm+'Vs('+Sp[node]+','+Sp[refnode]+')';
    1 : varnm:=varnm+'Vn('+Sp[node]+','+Sp[refnode]+')';
    2 : varnm:=varnm+'Temp('+Sp[node]+','+Sp[refnode]+')';
    9 : varnm:=varnm+'M ('+Sp[node]+','+Sp[refnode]+')';
    3 : varnm:=varnm+'Y('+inttostr(node)+')';
    4 : varnm:=varnm+'Z('+inttostr(node)+')';
    5 : varnm:=varnm+'Reflect('+Sp[node]+','+Sp[refnode]+')';
    6 : varnm:=varnm+'Gain('+Sp[node]+','+Sp[refnode]+')';
    7 : varnm:=varnm+'Zin('+Sp[node]+')';
    8 : varnm:=varnm+'Corr('+Sp[node]+','+Sp[refnode]+')';
    10 : varnm:=varnm+'Zin('+Sp[node]+','+Sp[refnode]+')';
    11 : varnm:=varnm+'M4('+Sp[node]+','+Sp[refnode]+')';
    12 : varnm:=varnm+'AM('+Sp[node]+','+Sp[refnode]+')';
    14 : varnm:=varnm+'S('+inttostr(node)+')';
    15 : varnm:=varnm+'YM4('+SP[node]+')';
    16 : varnm:=varnm+'Vs^2('+Sp[node]+','+Sp[refnode]+')';
    30 : varnm:=varnm+'K';
    20 : varnm:=varnm+'Yin('+comp^.name+','+inttostr(node)+')';
    21 : varnm:=varnm+'Reflect('+comp^.name+','+inttostr(node)+')';
    22 : varnm:=varnm+'Ref('+comp^.name+','+inttostr(node)+')';
    23 : varnm:=varnm+'Zin('+comp^.name+','+inttostr(node)+')';
    100..199 : varnm:=varnm+comp^.name+':'+psport(comp)^.var2str(psport(comp)^.xvars[RI]);
    end;
  if (wat<99) and (RI>0) then varnm:=varnm+']';
end;
var2str:=vr.varnm;
end;

Procedure Tsport.readprint(ss : tstrings;plot : integer);
var
 x : integer;
begin
inc(Nprint);
setlength(Print,Nprint);
delete(ss[1],1,6);
with Print[Nprint-1] do begin
 name:=ss[1];
  if name[1]=':' then delete(name,1,1);
  if name[1]='"' then delete(name,1,1);
  if name[length(name)]='"' then delete(name,length(name),1);
  plt:=plot;
 assign(f,name);
 rewrite(f);
 N:=len(ss)-1;
 setlength(vars,N);
 for x:=1 to N do begin
//   writeln(ss[x+1]);
 vars[x-1]:=readoutvar(ss[x+1]);
 vars[x-1].varnm:=var2str(vars[x-1]);
// with vars[x-1] do 
   write(f,vars[x-1].varnm);	
 if x<N then write(f,#9) else writeln(f); 
// writeln('printcard ',Nprint,' n=',n);
 end;{for}
 close(f);
 end;{with}
end;

Procedure Tsport.readnodes(ss : tstrings);
var
 x : integer;
begin
writeln(name,' Read Nodes');
 for x:=2 to len(ss) do getNode(ss[x]);
end;

Procedure Tsport.closeprint;
var
 x : integer;
begin
 for x:=0 to Nprint-1 do begin
//   close(print[x].f);
case  print[x].plt of 
 1 : gnuplot(print[x]);
 2 : gnuplotxy(print[x]);
 end;
   end;
 Nprint:=0;
end;


function Tsport.readcomp(s : string;var C : Pcomp) : boolean;
var
 ss : tstrings;
 wt,Cname : string;
 x,NPm,NN,l : integer;
 P : Tparams;
 tmp : Pcomp;
begin
readcomp:=false;
x:=pos(#9,s);
while x<>0 do begin
 s[x]:=' ';
 x:=pos(#9,s);
 end;

ss:=strtostrsc(s);
x:=pos(':',ss[1]);
if x<0 then exit;
wt:=uppercase(copy(ss[1],1,x-1));
Cname:=uppercase(copy(ss[1],x+1,length(ss[1])-x));
//writeln('Tiepe=',wt,' name=',Cname);
tmp:=findcomp(Cname);
if tmp<>nil then begin
   writeln(name,': Copy ',Cname); 
   C:=new(Pcompcopy,create(@self,tmp));
   wt:='COPY';
   end
else if wt='R' then C:=new(Pres,create(@self))
else if wt='RW' then C:=new(PresW,create(@self))
else if wt='FNOISE' then C:=new(PFNOISE,create(@self))
else if wt='A' then C:=new(Pgain,create(@self))
else if wt='LOSS' then C:=new(Ploss,create(@self))
else if wt='C' then C:=new(Pcap,create(@self))
else if wt='L' then C:=new(Pind,create(@self))
else if wt='VIA' then C:=new(Pmvia,create(@self))
else if wt='TL' then C:=new(Ptline,create(@self))
else if wt='TL2' then C:=new(Ptline2,create(@self))
else if wt='TL3' then C:=new(Ptline3,create(@self))
else if wt='LEM' then C:=new(PEM,create(@self))
else if wt='TSW' then C:=new(Ptwire,create(@self))
else if wt='TLR' then C:=new(PtlineR,create(@self))
else if wt='TMS' then C:=new(Pmstrip3,create(@self))
else if wt='TMSR' then C:=new(PmstripR,create(@self))
else if wt='TMSCNR' then C:=new(Pmcorner,create(@self))
else if wt='TMSTEE' then C:=new(PmTee,create(@self))
else if wt='TMSGAP' then C:=new(PmGap,create(@self))
else if wt='TLB' then C:=new(Ptline3B,create(@self))
else if wt='TLT' then C:=new(PtlineT,create(@self))
else if wt='T' then C:=new(PFET,create(@self))
else if wt='P2LU' then C:=new(PFETLU,create(@self))
else if wt='P2' then C:=new(P2port,create(@self))
else if wt='P1' then C:=new(P1port,create(@self))
else if wt='P2N' then C:=new(P2portNoise,create(@self))
else if wt='VCCS' then C:=new(PVCCS,create(@self))
else if wt='STATZ' then C:=new(Pstatz,create(@self))
else if wt='TOM' then C:=new(Ptom,create(@self))
else if wt='CKT' then C:=new(Psport,create(@self))
else if wt='FUNC' then C:=new(Pfunc,create(@self))
else if wt='MEASURE' then C:=new(PMeas,create(@self))
else if wt='MMIN' then C:=new(PMmin,create(@self))
else if wt='MPA' then C:=new(PMPA,create(@self))
else if wt='RATIO' then C:=new(PRatio,create(@self))
else if wt='FILTER' then C:=new(PFilter,create(@self))
else if wt='FILTERS' then C:=new(PFilter2,create(@self))
else if wt='CALC' then begin;readanal(ss);exit;end
else if wt='SPECIAL' then begin;readspecial(ss);exit;end
else if wt='OPTIM' then begin;readoptim(ss);exit;end
else if wt='PRINT' then begin;readprint(ss,0);exit;end
else if wt='PLOT' then begin;readprint(ss,1);exit;end
else if wt='PLOTXY' then begin;readprint(ss,2);exit;end
else if wt='CLOSEPRINT' then begin;closeprint;exit;end
else if wt='SET' then begin;readset(s,ss);exit;end
else if wt='SETPARAM' then begin;readsetparam(ss);exit;end
else if wt='LOADPARAM' then begin;readloadparam(ss);exit;end
else if wt='SAVEPARAM' then begin;readsaveparam(ss);exit;end
else if wt='NODES' then begin;readnodes(ss);exit;end
else if wt='EXPORT' then begin;exportckt(ss);exit;end
else begin if wt<>'' then writeln('Unknow component ',wt);exit; end;
//writeln('Comp ',wt,' created');
C^.name:=Cname;
C^.tiepe:=wt;

     inc(Nc);
     setlength(Comp,Nc);
     Comp[Nc-1]:=C;

x:=pos('$',s);
if x>0 then subset(ss,Nset,sets);
readcomp:=C^.loads(ss);
//writeln(C^.name,' nnode=',C^.nnode);
 
{if wt='CKT' then NN:=len(ss)-2 else NN:=C^.Nnode;
NPm:=len(ss)-NN-1;
if NPm<0 then begin;writeln(ss[1],' Not enough nodes');exit;end;
setlength(C^.node,NN);
for x:=1 to NN do C^.node[x-1]:=getnode(ss[x+1]);
setlength(P,Npm);
for x:=1 to Npm do P[x-1]:=getprm(ss[x+NN+1]);
C^.load(Npm,P); }

readcomp:=true;
end;
Procedure Tsport.addlayout(s : string);
begin
     if PClayout=nil then PClayout:=new(Playout,create(@self,Np));
     Playout(PClayout)^.name:='FP';
     Playout(PClayout)^.loadline(s);
end;
Procedure Tsport.readfile2(var f : text);
var
 f2 : text;
 s : string;
 C : pcomp;
begin
s:='';
 while not(eof(f)) and (s<>'.ends') do begin
   repeat
    readln(f,s);
//    writeln('readfile: ',s);
  until (eof(f)) or ((s<>'') and (s[1]<>'*'));
   if uppercase(copy(s,1,8))='#INCLUDE' then begin
     delete(s,1,9);
     writeln(name,': Including ',s);
     assign(f2,s);
     reset(f2);
     readfile2(f2);
     close(f2);
     end else
  if uppercase(copy(s,1,3))='FP:' then begin
    delete(s,1,3);
    addlayout(s);
    end else
   if readcomp(s,C) then begin
     //writeln('Comp added:',C^.name);
     end; 
 end;{while}
end;   
   
Procedure Tsport.readfile(var f : text);
var
 s : string;
 ss : tstrings;
 C : pcomp;
 x : integer;
begin
 ss[1]:='';
 while not(eof(f)) and (ss[1]<>'subck') do begin
   readln(f,s);
   ss:=strtostrs(s);
   end;
 name:=ss[2];
//writeln(name,' Loading');
 Np:=len(ss)-2;
 if Np<1 then halt(1);
 setlength(Sp,Np);setlength(xvars,0);
 for x:=0 to Np-1 do Sp[x]:=ss[x+3];
 Nc:=0;
 Nv:=0;
 Ni:=0;
 //pin.c:=nil;pout.c:=nil;
 Nprint:=0;parmn:=0;validzz:=0;
 PClayout:=nil;
 initY:=false;NoiseRes:=50;
 nsavedata:=0;Lsavedata:=0;doinv:=false;
 readfile2(f);
//writeln('readfile2 finished'); 
 if Nnode <> Np then begin;writeln(name,' Number of nodes must be ',np);end;

 Ns:=0;
 for x:=0 to Nc-1 do NS:=Ns+comp[x]^.Nsrc;
 Nns:=0;
 for x:=0 to Nc-1 do NnS:=Nns+comp[x]^.Nnoise;


 if Ns>0 then Nsrc:=1 else Nsrc:=0;
 if Nns>0 then Nnoise:=Np-1 else Nnoise:=0;
 Nt:=Np+Nv+Ni;
// writeln(name,' loaded:',np,' nodes, ',nv,' internal nodes, ',Ni,' adds vars, ',Ns,' src ',Nns,' noise src'); 
end;

procedure Tsport.calcMmin(var f : text;vr : toutvar;w : double;V0,Z0 : cvec);
begin
 getoutvar(vr,w,V0,Z0);
 PMMin(Vr.Comp)^.writeVec(f); 
end;


Procedure Tsport.calcFmin(var Fmin,Rn,Gn : tr;var Ycor : tc);
var
 u,i : array[1..2] of Tc;
 k,ii : integer;
// Rn,Gn,Fmin : Tr;
// Ycor : Tc;
begin
 
 if (np<>3) then begin;writeln('Noise parameters only for 2 ports! (',np-1,')');halt(1);end;

// writeln('Calc F min');
// write('i1=');for k:=1 to 2 do cwrite(Sn[k,1]);writeln;
// write('i2=');for k:=1 to 2 do cwrite(Sn[k,2]);writeln;
if nns=2 then begin
 for k:=1 to 2 do u[k]:=SN[k,2]/YY[1,2];
 for k:=1 to 2 do i[k]:=SN[k,1]-YY[1,1]*u[k];
 end else begin
// writeln('calcNI');
 calcNI;//work
 ii:=np-1;
// writeln('u,i');
 if cabs2(YY[1,2])<1e-20 then for k:=1 to 2 do u[k]:=r2c(1e10,0) else
  for k:=1 to 2 do u[k]:=work[(k-1)*ii+1]/YY[1,2];
 for k:=1 to 2 do i[k]:=work[(k-1)*ii+0]-YY[1,1]*u[k];
 end;
// write('u =');for k:=1 to 2 do cwrite(u[k]);writeln;
// write('i =');for k:=1 to 2 do cwrite(i[k]);writeln;
// write('Y =');for k:=1 to 2 do cwrite(YY[1,k]);writeln;
// writeln('Ycor');
 Ycor:=-(u[1]*i[1]+u[2]*i[2])/(u[1]*u[1]+u[2]*u[2]);
 for k:=1 to 2 do i[k]:=i[k]+u[k]*Ycor;
// write('in=');for k:=1 to 2 do cwrite(i[k]);writeln;
 Rn:=(cabs2(u[1])+cabs2(u[2]))/k4/290;
 Gn:=(cabs2(i[1])+cabs2(i[2]))/k4/290;
 Fmin:=2*(Rn*Ycor[1]+sqrt(Rn*Gn+sqr(Rn*Ycor[1])));
// writeln('Fmin=',Fmin:8:5,'(',Fmin*290:3:0,') Rn=',Rn:8:5,' Gn=',Gn*1e3:8:5,' Ycor=',Ycor[1]*1e3:8:5,' ',Ycor[2]*1e3:8:5);
end;


// ************ OTHER **************
Procedure Tsport.printout(V0,Z0 : cvec;w : double);
var
 x,j,nx,i,k : integer;
 V1 : cvec;
// Rn,Gn,Fmin : Tr;
// Ycor : Tc;
begin
//writeln(name,' Print output (',Nprint,')');
for j:=0 to Nprint-1 do with print[j] do begin
// writeln('outputfile=',name);
 assign(f,name);
 append(f);
 for x:=0 to N-1 do begin
//     write(' P:',j,':',x);
    if vars[x].wat=32 then for i:=1 to np-1 do for k:=1 to np-1 do write(f,YY[i,k,1]:8:5,' ',YY[i,k,2]:8:5,' ') else
    if vars[x].wat=33 then begin
      //Sparm...
      end else
    if vars[x].wat=34 then for i:=1 to nns do for k:=1 to np-1 do write(f,SN[i,k,1]:8:5,' ',SN[i,k,2]:8:5,' ') else
//    if vars[x].wat=35 then begin;calcFmin(Fmin,Rn,Gn,Ycor);write(f,Fmin*290:5:2,#9,Rn:8:5,#9,Gn:8:5,#9,Ycor[1]:8:5,#9,Ycor[2]:8:5);end else
    if vars[x].wat=36 then calcRPC(f,vars[x],w,V0,Z0) else
//    if vars[x].wat=39 then begin;getoutvar(vars[x],w,V0);write(f, sqrt(cabs2(PMmin(vars[x].comp)^.signal)));end else
    if vars[x].wat=38 then calcMmin(f,vars[x],w,V0,Z0) 
      else write(f,getoutvar(vars[x],w,V0,Z0));
//    writeln(getoutvar(vars[x],w,V0));
    if x<N-1 then write(f,#9)
             else writeln(f);
//    if dorecalc then calcY(w);
  end;
  close(f);
  end;
//writeln(name,': Print subckt');
for x:=0 to Nc-1 do if comp[x]^.tiepe='CKT' then if Psport(comp[x])^.Nprint>0 then begin
 nx:=comp[x]^.nnode;
 for j:=0 to nx-1 do work2[j]:=solveS(comp[x]^.node[j],V0);
 compn(comp[x],w,V0,Z0,work2);
 compz(comp[x],w,Z0,work);
 Psport(comp[x])^.printout(work2,work,w);
  end;
//writeln(name,': Done');
end;



//*********** INHERITED ************
Procedure Tsport.closecomp;
var
 x : integer;
begin
//savedata - free?
 for x:=0 to nc-1 do comp[x]^.closecomp;
 for x:=0 to Nprint-1 do begin
//   close(print[x].f);
   case print[x].plt of
    1 : gnuplot(print[x]);
    2 : gnuplotxy(print[x]);
    end;
   end;
// writeln(name,' END');
end;

Procedure Tsport.calcN(w : double);
//var
// In : cvec;
begin
{ setlength(In,Nn-1);
 for i:=1 to Nn-1 do begin
  z:=R2C(0,0);
  for j:=1 to Nns do z:=z+cabs2(Sn[j,i]);
  In[i-1]:=z;
 CMsetsize(NN,Nn-1,Nn-1);
 for i:=Nn-1 downto 1 do begin
   end;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
end;
}   
end;

Procedure Tsport.loadY(w : double);
var
 i,j,k : integer;
 docalc : boolean;
begin
//savedata:=false;
//writeln('loadY:w=',w,' nt=',nt,' np=',np);
docalc:=true;
if savedata then for i:=0 to nsavedata-1 do if saveddata[i].freq=w then begin
      docalc:=false;
//      DoInitY;
//      calcY(w);
//   makeY(w,YY);
//   makeS(w,SN);
      for j:=0 to Nt-1 do for k:=0 to Nt-1 do YY[j,k]:=saveddata[i].YY[j,k];
      for k:=0 to Nt-1 do for j:=0 to Nns do Sn[j,k]:=saveddata[i].Sn[j,k];
      currentw:=w;
      //for k:=0 to Nt-1 do for j:=0 to Nns do DSn[j,k]:=saveddata[i].Dsn[j,k];
//      writeln(name,': Get Y w=',w,' use save calc ',i);
//  writeln(name,' YY=');cmwriteE(Nt,Nt,YY);

      end;
//docalc:=true;
//if not(docalc) then write(name,' using savedata');
 if docalc then begin
//    writeln('Get Y w=',w,' do calc ',i);
//   writeln('calcY');
  doinitY;
   calcY(w);
//  writeln('calcN');
   calcN(w);
   //writeln('save data');
{if savedata then for i:=0 to nsavedata-1 do if saveddata[i].freq=w then begin
      for j:=0 to Nt-1 do for k:=0 to Nt-1 do if cabs2(YY[j,k]-saveddata[i].YY[j,k])>1e-20 then writeln('DIFF Y! ',j,' ',k);
      for k:=0 to Nt-1 do for j:=0 to Nns do if cabs2(Sn[j,k]-saveddata[i].Sn[j,k])>1e-20 then writeln('DIFF SN! ',j,' ',k);
      for j:=0 to Nt-1 do for k:=0 to Nt-1 do YY[j,k]:=saveddata[i].YY[j,k];
      for k:=0 to Nt-1 do for j:=0 to Nns do Sn[j,k]:=saveddata[i].Sn[j,k];
      //for k:=0 to Nt-1 do for j:=0 to Nns do DSn[j,k]:=saveddata[i].Dsn[j,k];
//      writeln('Get Y w=',w,' use save calc ',i);
      end;
}

   if not(dorecalc) and savedata then begin
//      writeln(name,': save data ',nsavedata);
     if nsavedata+1>lsavedata then begin
         lsavedata:=nsavedata+1;
         setlength(saveddata,lsavedata);
         with saveddata[nsavedata] do begin
           CMsetsize(Nt,Nt,YY);
	   CMsetsize(Nns+1,Nt,Sn);
//	   CMsetsize(Nns+1,Nt,DSn);
	   end;
         end;
//      writeln('save data - get mem');
//      writeln('save data - saving');
      for j:=0 to Nt-1 do for k:=0 to Nt-1 do saveddata[nsavedata].YY[j,k]:=YY[j,k];
      for k:=0 to Nt-1 do for j:=0 to Nns do saveddata[nsavedata].Sn[j,k]:=Sn[j,k];
      //for k:=0 to Nt-1 do for j:=0 to Nns do saveddata[nsavedata].DSn[j,k]:=Dsn[j,k];
      //saveddata[nsavedata].YY:=YY;
      //saveddata[nsavedata].Sn:=Sn;
      //saveddata[nsavedata].Dsn:=Dsn;
      saveddata[nsavedata].freq:=w;
      inc(nsavedata);   
     end;
   end;
//writeln('Dome');

end;


Procedure Tsport.getY(w : double;var Y : cmat);
var i,j : integer;
begin 
loadY(w);
// write('Add Y Np=',Np);
//write('Y=',integer(@y[1,1]));
//writeln;
//write(name);for i:=0 to Np-1 do write(' N',i,'=',node[i]);
 for i:=1 to Np-1 do 
    for j:=1 to Np-1 do addblk(Y,node[0],node[0],node[i],node[j],YY[i,j]);
//if nnode=3 then begin;write(name,' YY[2,2]=');cwrite(YY[2,2]);write(' ',length(Y),'x',length(Y[1]));end;
//writeln('getY done');
// write('GetY');cvwrite(j,V);writeln;
end;

Procedure Tsport.getS(w : double;var S : cmat);
var
 x : integer;
begin
//write('GetY');
 for x:=1 to Np-1 do begin
   cadd(S[0,node[x]],Sn[0,x]);
   cadd(S[0,node[0]],-Sn[0,x]);
  end;
 // write('GetS');cvwrite(Np-1,V);
//writeln(' - Done');
end;

Procedure Tsport.calcNI;
var
 i1,i2 : double;
 C : tc;
 x,y,i,j,ii : integer;
begin
if (Np<2) {or (Np>3)} then begin
  writeln(name,' Noise for ',Np-1,' port network not implemented!!');
  halt(1);
  end;
//writeln('GetN np=',np);
if Np=2 then begin
 i2:=0;
 for x:=1 to Nns do i2:=i2+cabs2(Sn[x,1]);
// v[0]:=R2C(sqrt(i2),0);
 i2:=sqrt(i2);
 work[0]:=r2c(i2,0);
 end else 
 if Np=3 then begin
// writeln(name,' Nns=',Nns);
 i1:=0;i2:=0;C:=czero;
 for x:=1 to Nns do i1:=i1+cabs2(Sn[x,1]);
 for x:=1 to Nns do i2:=i2+cabs2(Sn[x,2]);
// for x:=1 to Nns do begin;cwrite(Sn[x,1]);cwrite(Sn[x,2]);writeln;end;
// writeln(sqrt(i1),sqrt(i2));
 i2:=sqrt(i2);
 work[3]:=r2c(i2,0);
//  caddr(N[noiseI+1,node[2]],i2);
//  caddr(N[noiseI+1,node[0]],-i2);
// V[0]:=R2C(i1,0);
// V[2]:=Czero;
c:=czero;
 for x:=1 to Nns do C:=C+Sn[x,1]*ccomp(Sn[x,2]);
  c:=c/i2;
  work[2]:=C;
//  cadd(N[noiseI+1,node[1]],C);
//  cadd(N[noiseI+1,node[0]],-C);
// Writeln('Noise:');
// writeln('i2 =',i2);
// writeln('i1c=');cwrite(C);writeln;
  i1:=i1-cabs2(C);	
  if i1<0 then i1:=0 else i1:=sqrt(i1);
  work[0]:=r2c(i1,0);
  work[1]:=czero;
//  caddr(N[noiseI,node[1]],i1);
//  caddr(N[noiseI,node[0]],-i1);
// writeln(i1);
// for x:=0 to 2 do begin
//  for y:=0 to 1 do CwriteEng(N[noiseI+y,node[x]]);
//  writeln;
//  end;
//for x:=0 to 3 do cwriteEng(work[x]);writeln;
 end 
 
 else begin
 ii:=Np-1;
//  writeln('calcN');
//  CMsetsize(Np-1,Np-1,V);
  for y:=ii-1 downto 0 do begin
    for x:=ii-1 downto y+1 do begin
//       writeln('calc ',y,' ',x);//calc ixiy
       C:=czero;for i:=1 to Nns do C:=C+ccomp(Sn[i,x+1])*(Sn[i,y+1]);
       for j:=np-2 downto x+1 do C:=C-ccomp(work[j*ii+x])*work[j*ii+y];
//       cwrite(C);cwrite(V[x,x]);writeln;
       if work[x*ii+x,1]=0 then C:=czero else
                     C:=C/work[x*ii+x,1]; 
//       V[x,y]:=C;
       work[x*(np-1)+y]:=C;
//       cadd(N[noiseI+x,node[y+1]],C);
//       cadd(N[noiseI+x,node[0]],-C);
       end;
   //calc ix^2
//    writeln('calc ',y,'^2');
    i1:=0;for i:=1 to Nns do i1:=i1+cabs2(Sn[i,y+1]);
    for x:=np-2 downto y+1 do i1:=i1-cabs2(work[x*ii+y]);
//    writeln('i',y,'=',i1);
    if i1<0 then i1:=0 else i1:=sqrt(i1);
//    if i1=0 then writeln('Subckt Noise port ',Sp[y+1],' error');
//    V[y,y]:=R2C(i1,0);
    work[y*(np-1)+y]:=R2c(i1,0);
//    caddr(N[noiseI+y,node[y+1]],i1);
//    caddr(N[noiseI+y,node[0]],-i1);
    end;
{ for x:=0 to NP-2 do begin
  for y:=0 to NP-2 do CwriteEng(N[noiseI+y,node[x+1]]);
  writeln;
  end;
}
// Write('Noise:');CMwrite(np-1,np-1,V);writeln;
 end;
// write('GetN');cvwrite((Np-1)*(Np-1),V);
//writeln(' - Done');

end;

Procedure Tsport.getN(w : double;var N : cmat);
var
 x,y,ii : integer;
begin
//write('GetN');
calcNI;//work
ii:=np-1;
for x:=0 to ii-1 do
 for y:=0 to ii-1 do begin
   cadd(N[noiseI+x,node[y+1]],work[x*ii+y]);
   cadd(N[noiseI+x,node[0]],-work[x*ii+y]);
   end;
end;

Procedure Tsport.load(Np1 : integer;P : Tparams);
var
 s,oldname : string;
 f : text;
begin
 oldname:=name;
 s:=P[0].value;
 cktname:=s;
 writeln(name,' = subckt ',s);
 if s[1]='"' then delete(s,1,1);
 if s[length(s)]='"' then delete(s,length(s),1);
// writeln(name,' Loading subckt ',s);
 assign(f,s);
 reset(f);
 readfile(f);
 close(f);
 name:=oldname;
// name:=s;
end;


function Tsport.loads(ss : tstrings) : boolean;
var
 Npm,x,l : integer;
 P : tparams;
 s : string;
begin
if Nnode>0 then begin
 inherited loads(ss);
 exit;
 end;
 l:=len(ss);
 if ss[l]='FOOTPRINT' then dec(l);
// writeln('Loading sport.loads');
 loads:=false;
 Nnode:=l-2;
// writeln(name,' nnode=',nnode);
 NPm:=1;
 if NPm<0 then begin;writeln(ss[1],' Not enough nodes');exit;end;
 setlength(node,NNode);
 for x:=1 to NNode do node[x-1]:=Psport(parent)^.getnode(ss[x+1]);
 setlength(P,Npm);
 for x:=1 to Npm do P[x-1]:=getprm(ss[x+NNode+1]);
 load(Npm,P); 
 loads:=true;
 

 if ss[l+1]='FOOTPRINT' then begin
    s:='CKT:'+name;
    for x:=2 to Nnode do s:=s+' '+ss[x+1];
    s:=s+' '+name;
//   writeln('Autofootprint ',s);
    Psport(parent)^.addLayout(s);
   end;
 
end;

function Tsport.paramnum(s : string) : integer;
var
 s2 : string;
  C : pvars;
  x,y : integer;
begin
  s2:=splitdp(s);
  if s2='FP' then C:=PClayout 
    else C:=findcomp(s2);
  if c=nil then begin
//    writeln('Can not find component ',);
    paramnum:=0;
    exit;
    end;
 x:=C^.paramnum(s);
 if x=0 then begin;
  paramnum:=0;
  exit;
  end;
for y:=0 to parmn-1 do 
 if (parm[y].C=C) and (parm[y].W=x) then begin
   paramnum:=y+1;
   exit;
   end;
inc(parmn);
setlength(parm,parmn);
parm[parmn-1].C:=C;
parm[parmn-1].W:=x;
paramnum:=parmn;
//savedata:=false;
end;

function Tsport.paramstr(wat : integer) : string; 
begin
if (wat<1) or (wat>parmn) then begin;paramstr:='';exit;end;
with parm[wat-1] do
 paramstr:=C^.name+':'+C^.paramstr(W);
end;


function Tsport.getD(wat : integer) : double; 
begin
if (wat<1) or (wat>parmn) then exit;
with parm[wat-1] do getD:=C^.getD(W);
end;

Procedure Tsport.setD(z : double;wat : integer); 
begin
if (wat<1) or (wat>parmn) then exit;
with parm[wat-1] do begin
  if C^.getD(W)=z then exit;
  C^.setD(z,W);
  if savedata then nsavedata:=0;
  end;
end;


Procedure Tsport.setD2(s : string;wat : integer); 
begin
if (wat<1) or (wat>parmn) then exit;
with parm[wat-1] do begin
  C^.setD2(s,W);
  if savedata then nsavedata:=0;
  end;
end;


function Tsport.addoutvar(s : string;var wt : integer) : integer; //in subcircuit save in optvar
var
 x : integer;
begin
 x:=length(xvars);
 setlength(xvars,x+1);
 xvars[x]:=readoutvar(s);
 if xvars[x].wat<100 then wt:=xvars[x].wat+100 else
                          wt:=xvars[x].wat;
 addoutvar:=x;
end;


function Tsport.getZ(nm,i : integer;var Z : cvec) : boolean; 
var x : integer;
begin
//writeln('getz: nm=',nm,' validz=',validzz);
if nm=validzz then for x:=0 to i*i-1 do Z[x]:=ZZ[x];
getZ:=nm=validzz;
//getZ:=false;
end;

Procedure Tsport.saveZ(nm,i : integer;var Z : cvec); 
var x : integer;
begin
//validzz:=nm;
//writeln('i=',i,' l=',length(ZZ),';',length(Z));
//for x:=0 to i*i-1 do ZZ[x]:=Z[x];
end;

function Tsport.getFoot(var wt,par : string;var pars : integer) : boolean; 
begin
wt:='CKT';
par:=name;
getFoot:=true;
end;

Procedure Tsport.exportckt(ss : tstrings);
var
f : text;
s : string;
x : integer;
begin
if ss[1]='EXPORT:QUCS' then begin
 s:=ss[2];
 assign(f,s);
 rewrite(f);
 writeln('Exporting to Qucs netlist');
 writeln(f,'# Qucs generated by DACAD');
 for x:=0 to Nc-1 do
   comp[x]^.exportqucs(f);
 for x:=3 to len(ss) do begin
   if ss[x,1]='''' then delete(ss[x],1,1);
   if ss[x,length(ss[x])]='''' then delete(ss[x],length(ss[x]),1);
   writeln(f,ss[x]);
   end;
 close(f);  
 end else begin
  s:=ss[2];
  assign(f,s);
  rewrite(f);
  for x:=0 to Nc-1 do
   comp[x]^.exportVars(f,'');
 close(f);
 end;
end;

Procedure Tsport.exportVars(var f : text;prnt : string);
var
x : integer;
begin
prnt:=prnt+name+':';
for x:=0 to Nc-1 do comp[x]^.exportVars(f,prnt);
end;

Procedure Tsport.exportQucs(var f : text);
var
 x : integer;
 c : char;
 s : string;
begin
s:='';
for x:=1 to 5 do begin
 c:=chr(round(random(25))+ord('a'));
 s:=s+c;
 end;
writeln(f);
write(f,'Sub:',name);
for x:=0 to np-1 do write(f,' ',expnode(node[x]));
writeln(f,' Type="subck_',name,s,'"');
write(f,'.Def:subck_',name,s,' gnd');
for x:=1 to np-1 do write(f,' _',SP[x]);
writeln(f);

for x:=0 to Nc-1 do
  comp[x]^.exportqucs(f);

writeln(f,'.Def:End');
writeln(f);
end;

end.
   