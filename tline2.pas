unit tline2;
interface
uses compu,sport,vectorD,complex2,varu;
type
 Ttline2 = object(Tsport)
//   S : Tsport;
//   function Nnode : integer; virtual;
//   Procedure getY(w : double;var V : cvec); virtual;
  r_per_m,l_per_m,c_per_m,len : double;
  constructor create(P : pointer); 
   Procedure load(Np1 : integer;P : Tparams); virtual;

   Procedure getdY(w : double;v0 : cvec;var Y : cvec;wat : integer); virtual;
   function paramnum(s : string) : integer; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   end; 
Ptline2 = ^Ttline2;   
   
implementation
uses consts;
function fstr(f : double) : string;
var
 s : string;
begin
 str(f,s);
 while (s<>'') and (s[1]=' ') do delete(s,1,1);
fstr:=s;
end;


constructor ttline2.create(P : pointer);
begin inherited create(P);Nnode:=4; end;



Procedure Ttline2.load(Np1 : integer;P : Tparams);
var
 Z0,k,tand,alpha,temp : double;
 c,l,r,g : double;
 nsect,x : integer;
 f : text;
 ls : string;
begin
 Z0   :=getparm(Np1,P,'Z0',50);
 k    :=getparm(Np1,P,'K',4);
 len  :=getparm(Np1,P,'LEN',1e-3);
 tand :=getparm(Np1,P,'TAND',0.02);
 alpha:=getparm(Np1,P,'ALPHA',0.01);
// fopt :=getparm(Np,P,'fopt',1e9);
 temp :=getparm(Np1,P,'TEMP',0);
 nsect:=round(getparm(Np1,P,'NSECT',2));
 alpha:=alpha*0.11512926; //db/m to nepers/m
 len:=len / nsect;

 c_per_m:=sqrt(k)/(Z0*c0);
 l_per_m:=(z0*z0)*c_per_m;
 r_per_m:=2*alpha*Z0;
 r:=r_per_m*len;
 c:=c_per_m*len;
 l:=l_per_m*len/2;
// oldname:=name;
 assign(f,'tline.tmp');
 rewrite(f);
 writeln(f,'subck ',name,' 0 L0 ',nsect,' L',nsect);
 for x:=1 to nsect do begin
   writeln(f,'l:la',x,' ',x-1  ,' ',x,' l=',fstr(l),' r=',fstr(r),' temp=',fstr(temp));
   writeln(f,'l:lb',x,' L',x-1  ,' L',x,' l=',fstr(l),' r=',fstr(r),' temp=',fstr(temp));
   writeln(f,'c:c',x,' ',x,' L',x,' c=',fstr(c),' tand=',fstr(tand),' temp=',fstr(temp));
 end; 
 writeln(f,'.ends');
 close(f);
 assign(f,'tline.tmp');
 reset(f);
 readfile(f);
 close(f);
// name:=oldname;
end;

{Procedure Ttline.makeDS(w : double;var SSS : cmat;S0 : cmat);
const  max = 100;
var
// Y,dY,dn : cvec;
 x,Nn,i,j,k,Nn2,l : integer;
begin
//setlength(Y,max);
//CMsetsize(dY,max);
//setlength(dn,max);
//S matrix
Ns:=0;
for x:=0 to Ndc-1 do NS:=Ns+dcomp[x].C^.Nsrc;
Ndns:=Ndc;
for x:=0 to Ndc-1 do NdnS:=Ndns+dcomp[x].C^.Nnoise;
writeln(name,' Construct DSN matrix (',Ndc,',',Ndns,')');
CMsetsize(Ndns,Nt,SSS);
for i:=0 to Ndns-1 do for j:=0 to Nt-1 do SSS[i,j]:=czero;

k:=Ndc-1;
for i:=0 to Ndc-1 do with dcomp[i].C^ do begin
    Nn:=Nnode;

    getdY(w,S0[0],SSS[i]);
    getdS(w,S0[0],SSS[i]);
{    
    Nn2:=Nnoise;
//!!    getDN(w,Y,dN);
   for l:=1 to Nn2 do begin
     for j:=0 to Nn-1 do Y[j]:=S0[noiseI+l-1,node[j]];
//!!     getdY(w,Y,dY);
     inc(k);  
     for j:=1 to Nn-1 do begin
       SSS[k,node[j]]:=dN[(l-1)*Nn2+j-1]-dY[j-1];
       cadd(SSS[k,node[0]],dY[j-1]-dN[(l-1)*Nn2+j-1]);
       end;
     end;} {l}
    end; {i}
end;
}
Procedure Ttline2.getdY(w : double;v0 : cvec;var Y : cvec;wat : integer); 
var
 YY2 : cvec;
 i,j : integer;
begin
 setlength(aplV,nt);
 CMVmultn(nt,nt,np,YY,SN[0],aplV);

 makeY(optw,YY);
 CMsetsize(2,nt,DSN);
 for j:=0 to 1 do for i:=0 to nt-1 do DSN[j,i]:=czero;
 for i:=0 to Nc-1 do with comp[i]^ do  if tiepe='C' then getdY(w,aplV,DSN[0],1)
                                  else if tiepe='L' then getdY(w,aplV,DSN[1],1); 


{ 
 writeln('DSN=');
 CMwrite(Ndns,Np+Nv,DSN);
 writeln('YY=');
 cmwrite(Np+Nv,Np+Nv,YY);

 writeln('SN=');
 cmwrite(Nns+1,Np+Nv,SN);
} 
// writeln(name,' Solve system ...');
 CMelim(Nt,YY,np,nt-1,DSn,2);
// writeln('DSN=');
// CMwrite(Ndns,Np+Nv,DSN);
setlength(YY2,np);
 CMVmultn(nt,np,np,YY,Dsn[0],YY2);
if wat=1 then
 for i:=0 to np-1 do cadd(Y[node[i]],YY2[i],c_per_m);

 CMVmultn(nt,np,np,YY,Dsn[1],YY2);
if wat=1 then
 for i:=0 to np-1 do cadd(Y[node[i]],YY2[i],l_per_m);

{for i:=0 to np-1 do begin
  v0[i]:=Dsn[0,i];
  for j:=0 to np-1 do cadd(vo[i],YY[i,j],v0[j]);
  end;}
end;

function Ttline2.paramnum(s : string) : integer; 
begin
if s='LEN' then paramnum:=1 else paramnum:=0;
end;

function Ttline2.getD(wat : integer) : double; 
begin
getD:=len;
end;
Procedure Ttline2.setD(z : double;wat : integer); 
begin
len:=z;
end;


end. 