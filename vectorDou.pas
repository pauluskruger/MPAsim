unit vectorD;
interface
uses complex2;
type
 Tvec = array of double;
 Cvec = array of tc;
 Cmat = array of Cvec;

//Vector
function  Vmag  (N : integer;A : tvec) : double;
function  Vsum  (N : integer;A : tvec) : double;
procedure Vadd  (N : integer;var A : tvec;B : tvec;s : double);
procedure VRadd (N : integer;var A : tvec;s : double);
procedure VRmaal(N : integer;var A : tvec;s : double);
Procedure Vconst(N : integer;var A : tvec;s : double);
procedure Vwrite(N : integer;A : tvec);
function Vpntp  (N : integer;A,B : tvec) : double;
//Complex Vector
function CVRmag(N : integer;A : cvec) : double;
function CVmag(N : integer;A : cvec) : tvec;
function CVpntp  (N : integer;A,B : cvec) : tc;
function CVpntp  (N : integer;A : cvec;B : tvec) : tc;
procedure CVadd  (N : integer;var A : cvec;B : cvec;s : double);
function  CVreal  (N : integer;A : cvec) : tvec;
function  CVimag  (N : integer;A : cvec) : tvec;
function  CVCmult  (N : integer;A : cvec;C : tc) : cvec;
function CVplus(N : integer;A,B : cvec) : cvec;
procedure CVwrite(N : integer;A : cvec);

//Complex Matrix
Procedure CMsetsize(N,L : integer;var M : cmat);
Procedure CMPmult(N,L : integer;var M : cmat;dM : cmat);
procedure CMwrite(N,L : integer;A : cmat);
procedure CMwriteE(N,L : integer;A : cmat);

//Matrix+Vector
function CMVmult(N,L : integer;M : cmat;V : cvec) : cvec;
function CMtsVmult(N,L : integer;M : cmat;V : cvec) : cvec;
function CMVmult(N,L : integer;M : cmat;V : tvec) : cvec;
function CMtVmult(N,L : integer;M : cmat;V : cvec) : cvec;
function CMtVmult(N,L : integer;M : cmat;V : tvec) : cvec;
procedure CMVmultn(N,L,nn : integer;M : cmat;V : cvec;var V1 : cvec);

function CMelim(N : integer;M : cmat;a,b : integer;R : cmat;Nr : integer) : integer;
function CMinv(N : integer;M : cmat;a,b : integer;R : cmat) : integer;

implementation

function Vmag(N : integer;A : tvec) : double;
//A(1)^2+A(2)^2+...+A(N)^2
var z : double; x : integer;
begin z:=0;for x:=0 to N-1 do z:=z+A[x]*A[x];Vmag:=z;end;

function CVRmag(N : integer;A : cvec) : double;
//A(1)^2+A(2)^2+...+A(N)^2
var z : double; x : integer;
begin z:=0;for x:=0 to N-1 do z:=z+A[x,1]*A[x,1]+A[x,2]*A[x,2];CVRmag:=z;end;

function CVmag(N : integer;A : cvec) : tvec;
//A(1)^2+A(2)^2+...+A(N)^2
var z : tvec; x : integer;
begin 
setlength(z,N);
for x:=0 to N-1 do z[x]:=A[x,1]*A[x,1]+A[x,2]*A[x,2];CVmag:=z;end;

function Vsum(N : integer;A : tvec) : double;
//A(1)+A(2)+...+A(N)
var z : double; x : integer;
begin z:=0;for x:=0 to N-1 do z:=z+A[x];Vsum:=z;end;

procedure Vadd(N : integer;var A : tvec;B : tvec;s : double);
//A:=A+s*B;
var x : integer;
begin for x:=0 to N-1 do A[x]:=A[x]+B[x]*s;end;

procedure CVadd(N : integer;var A : cvec;B : cvec;s : double);
//A:=A+s*B;
var x : integer;
begin for x:=0 to N-1 do cadd(A[x],B[x],s);end;

procedure VRadd(N : integer;var A : tvec;s : double);
//A:=A+s;
var x : integer;
begin for x:=0 to N-1 do A[x]:=A[x]+s;end;

procedure VRmaal(N : integer;var A : tvec;s : double);
//A:=A*s;
var x : integer;
begin for x:=0 to N-1 do A[x]:=A[x]*s;end;

Procedure Vconst(N : integer;var A : tvec;s : double);
//A=0
var x : integer;
begin for x:=0 to N-1 do A[x]:=s;end;

Procedure CMPmult(N,L : integer;var M : cmat;dM : cmat);
var  x,y : integer;
begin for x:=0 to N-1-1 do for y:=x+1 to L do M[x,y]:=cmaal(M[x,y],dM[x,y]);end;

procedure CMwrite(N,L : integer;A : cmat);
var x,y : integer;
begin
 for y:=0 to L-1 do begin
  for x:=0 to N-1 do begin
   write(A[x,y,1]:5:2);
   if A[x,y,2]>=0 then write('+');
   write(A[x,y,2]:4:2,'i');
   end;
  writeln;
  end;
end;

procedure CMwriteE(N,L : integer;A : cmat);
var x,y : integer;
begin
 for y:=0 to L-1 do begin
  for x:=0 to N-1 do begin
   cwriteEng(A[x,y]);
   end;
  writeln;
  end;
end;

procedure Vwrite(N : integer;A : tvec);
var x : integer;
begin  for x:=0 to N-1 do write(A[x]:5:2);writeln;end;

procedure CVwrite(N : integer;A : cvec);
var x : integer;
begin  for x:=0 to N-1 do write(A[x,1]:7:3,'+',A[x,2]:7:3,'i');writeln;end;

function CMVmult(N,L : integer;M : cmat;V : cvec) : cvec;
var x,y : integer;
    Z : cvec;
begin;
setlength(Z,L);
for x:=0 to L-1 do Z[x]:=cmaal(M[0,x],V[0]);
for y:=1 to N-1 do for x:=0 to L-1 do cadd(Z[x],cmaal(M[y,x],V[y]));
CMVmult:=Z; end;

function CMVmult(N,L : integer;M : cmat;V : tvec) : cvec;
var x,y : integer;
    Z : cvec;
begin;
setlength(Z,L);
for x:=0 to L-1 do Z[x]:=crmaal(M[0,x],V[0]);
for y:=1 to N-1 do for x:=0 to L-1 do cadd(Z[x],crmaal(M[y,x],V[y]));
setlength(Z,L);
CMVmult:=Z; end;

function CMtVmult(N,L : integer;M : cmat;V : cvec) : cvec;
var x,y : integer;
    Z : cvec;
begin;
setlength(Z,L);
for x:=0 to L-1 do Z[x]:=cmaal(M[x,0],V[0]);
for y:=1 to N-1 do for x:=0 to L-1 do cadd(Z[x],cmaal(M[x,y],V[y]));
CMTVmult:=Z;
end;

function CMtVmult(N,L : integer;M : cmat;V : tvec) : cvec;
var x,y : integer;
    Z : cvec;
begin;
setlength(Z,L);
for x:=0 to L-1 do Z[x]:=crmaal(M[x,0],V[0]);
for y:=1 to N-1 do for x:=0 to L-1 do cadd(Z[x],crmaal(M[x,y],V[y]));
CMTVmult:=Z; end;


function CMtsVmult(N,L : integer;M : cmat;V : cvec) : cvec;
var x,y : integer;
    Z : cvec;
begin;
setlength(Z,L);
for x:=0 to L-1 do Z[x]:=csmaal(M[x,0],V[0]);
for y:=1 to N-1 do for x:=0 to L-1 do cadd(Z[x],csmaal(M[x,y],V[y]));
CMtsVmult:=Z; end;

procedure CMVmultn(N,L,nn : integer;M : cmat;V : cvec;var V1 : cvec);
var x,y : integer;
begin
for x:=0 to L-1 do V1[x]:=cmaal(M[x,0],V[0]);
for y:=1 to nn-1 do for x:=0 to L-1 do cadd(V1[x],cmaal(M[x,y],V[y]));
end; 

function Vpntp  (N : integer;A,B : tvec) : double;
var x : integer;z: double;
begin z:=A[0]*B[0];for x:=1 to N-1 do z:=z+A[x]*B[x];Vpntp:=z;end;

function CVpntp  (N : integer;A,B : cvec) : tc;
var x : integer;z: tc;
begin z:=cmaal(A[0],B[0]);for x:=1 to N-1 do cadd(z,cmaal(A[x],B[x]));CVpntp:=z;end;
function CVpntp  (N : integer;A : cvec;B : tvec) : tc;
var x : integer;z: tc;
begin z:=crmaal(A[0],B[0]);for x:=1 to N-1 do cadd(z,crmaal(A[x],B[x]));CVpntp:=z;end;

function  CVreal  (N : integer;A : cvec) : tvec;
var x : integer;z : tvec;
begin 
setlength(z,N);
for x:=0 to N-1 do z[x]:=A[x,1];CVreal:=z;end;

function  CVimag  (N : integer;A : cvec) : tvec;
var x : integer;z : tvec;
begin
setlength(z,N);
for x:=0 to N-1 do z[x]:=A[x,2];CVimag:=z;end;

function  CVCmult  (N : integer;A : cvec;C : tc) : cvec;
var x : integer;z : cvec;
begin
setlength(z,N);
for x:=0 to N-1 do z[x]:=cmaal(A[x],C);CVCmult:=z;end;

function CVplus(N : integer;A,B : cvec) : cvec;
var x : integer;z : cvec;
begin 
setlength(z,N);
for x:=0 to N-1 do z[x]:=cplus(A[x],B[x]);CVplus:=z;end;

function CMelim(N : integer;M : cmat;a,b : integer;R : cmat;Nr : integer) : integer;
var
 x,y,i : integer;
 z,z2 : tc;
begin
//writeln('a=',a,' b=',b);
CMelim:=0;
//writeln;
//cmwrite(N,N,M);
for x:=a to b-1 do begin
 if (M[x,x,1]=0) and (M[x,x,2]=0) then begin;CMelim:=x;exit;end;
 z2:=-1/M[x,x];
  for y:=x+1 to b do if ((M[x,y,1]<>0) or (M[x,y,2]<>0)) then begin
   z:=z2*M[x,y];
//   write('Z=');cwrite(z);writeln;
//   for i:=0 to N-1 do cadd(M[i,y],z*M[i,x]);
   for i:=0 to a-1 do if ((M[i,x,1]<>0) or (M[i,x,2]<>0)) then  cadd(M[i,y],z*M[i,x]);
   for i:=x+1 to b do if ((M[i,x,1]<>0) or (M[i,x,2]<>0)) then cadd(M[i,y],z*M[i,x]);
   M[x,y]:=czero;
   for i:=0 to Nr-1 do if ((R[i,x,1]<>0) or (R[i,x,2]<>0)) then cadd(R[i,y],z*R[i,x]);
  end;end;
for x:=b downto a+1 do begin
 if (M[x,x,1]=0) and (M[x,x,2]=0) then begin;CMelim:=x;exit;end;
 z2:=-1/M[x,x]; 
  for y:=x-1 downto a do if ((M[x,y,1]<>0) or (M[x,y,2]<>0)) then begin
   z:=z2*M[x,y];
   for i:=0 to a-1 do cadd(M[i,y],z*M[i,x]);
   for i:=x+1 to b do cadd(M[i,y],z*M[i,x]);
   M[x,y]:=czero;
   for i:=0 to Nr-1 do cadd(R[i,y],z*R[i,x]);
//   for i:=0 to N-1 do cadd(M[i,y],z*M[i,x]);
  end;end;
for x:=a to b do begin
 if (M[x,x,1]=0) and (M[x,x,2]=0) then begin;CMelim:=x;exit;end;
 z:=1/M[x,x];
 for i:=0 to a-1 do M[i,x]:=M[i,x]*z;
 for i:=0 to Nr-1 do R[i,x]:=z*R[i,x];

 M[x,x]:=R2C(1,0);
 end;
  
for x:=a to b do
 for y:=0 to a-1 do if ((M[x,y,1]<>0) or (M[x,y,2]<>0)) then begin
   z:=-M[x,y];
   for i:=0 to a-1 do cadd(M[i,y],z*M[i,x]);
   for i:=0 to Nr-1 do cadd(R[i,y],z*R[i,x]);
   M[x,y]:=R2C(0,0);
 end;
//cmwrite(N,N,M);
end;

{
function CMelim(N : integer;M : cmat;a,b : integer;R : cmat;Nr : integer) : integer;
var
 x,y,i : integer;
 z,z2 : tc;
begin
//writeln('a=',a,' b=',b);
CMelim:=0;
write('E');
//writeln;
//cmwrite(N,N,M);
for x:=a to b-1 do begin
 if (cabs2(M[x,x])<1e-50) or (cabs2(M[x,x])>1e50) then begin;CMelim:=x;exit;end;
 z2:=-1/M[x,x];
  for y:=x+1 to b do if ((M[x,y,1]<>0) or (M[x,y,2]<>0)) then begin
   z:=z2*M[x,y];
//   write('Z=');cwrite(z);writeln;
//   for i:=0 to N-1 do cadd(M[i,y],z*M[i,x]);
   for i:=0 to a-1 do if ((M[i,x,1]<>0) or (M[i,x,2]<>0)) then  cadd(M[i,y],z*M[i,x]);
   for i:=x+1 to b do if ((M[i,x,1]<>0) or (M[i,x,2]<>0)) then cadd(M[i,y],z*M[i,x]);
   M[x,y]:=czero;
   for i:=0 to Nr-1 do if ((R[i,x,1]<>0) or (R[i,x,2]<>0)) then cadd(R[i,y],z*R[i,x]);
  end;end;
for x:=b downto a+1 do begin
// if (M[x,x,1]=0) and (M[x,x,2]=0) then begin;CMelim:=x;exit;end;
 if (cabs2(M[x,x])<1e-50) or (cabs2(M[x,x])>1e50) then begin;CMelim:=x;exit;end;
 z2:=-1/M[x,x]; 
  for y:=x-1 downto a do if ((M[x,y,1]<>0) or (M[x,y,2]<>0)) then begin
   z:=z2*M[x,y];
   for i:=0 to a-1 do cadd(M[i,y],z*M[i,x]);
   for i:=x+1 to b do cadd(M[i,y],z*M[i,x]);
   M[x,y]:=czero;
   for i:=0 to Nr-1 do cadd(R[i,y],z*R[i,x]);
//   for i:=0 to N-1 do cadd(M[i,y],z*M[i,x]);
  end;end;
for x:=a to b do begin
// if (M[x,x,1]=0) and (M[x,x,2]=0) then begin;CMelim:=x;exit;end;
 if (cabs2(M[x,x])<1e-50) or (cabs2(M[x,x])>1e50) then begin;CMelim:=x;exit;end;
 z:=1/M[x,x];
 for i:=0 to a-1 do M[i,x]:=M[i,x]*z;
 for i:=0 to Nr-1 do R[i,x]:=z*R[i,x];

 M[x,x]:=R2C(1,0);
 end;
  
for x:=a to b do
 for y:=0 to a-1 do if ((M[x,y,1]<>0) or (M[x,y,2]<>0)) then begin
   z:=-M[x,y];
   for i:=0 to a-1 do cadd(M[i,y],z*M[i,x]);
   for i:=0 to Nr-1 do cadd(R[i,y],z*R[i,x]);
   M[x,y]:=R2C(0,0);
 end;
//cmwrite(N,N,M);
writeln('L');
end;
}
function CMinv(N : integer;M : cmat;a,b : integer;R : cmat) : integer;
var
 x,y,i : integer;
 z,z2 : tc;
begin
//writeln('a=',a,' b=',b);
CMinv:=0;
//writeln;
//cmwrite(N,N,M);
for x:=a to b do for y:=0 to x-1 do R[x,y]:=czero;
for x:=a to b-1 do begin
 if (M[x,x,1]=0) and (M[x,x,2]=0) then begin;CMinv:=x;exit;end;
 z2:=-1/M[x,x];
 R[x,x]:=r2c(1,0);
  for y:=x+1 to b do if ((M[x,y,1]<>0) or (M[x,y,2]<>0)) then begin
   z:=z2*M[x,y];
//   write('Z=');cwrite(z);writeln;
//   for i:=0 to N-1 do cadd(M[i,y],z*M[i,x]);
   for i:=0 to a-1 do if ((M[i,x,1]<>0) or (M[i,x,2]<>0)) then  cadd(M[i,y],z*M[i,x]);
   for i:=x+1 to b do if ((M[i,x,1]<>0) or (M[i,x,2]<>0)) then cadd(M[i,y],z*M[i,x]);
   M[x,y]:=czero;
   R[x,y]:=z;
   for i:=a to x-1  do if ((R[i,x,1]<>0) or (R[i,x,2]<>0)) then cadd(R[i,y],z*R[i,x]);
  end else R[x,y]:=czero;
  end;
//cmwrite(N,N,R);
R[b,b]:=r2c(1,0);
for x:=b downto a+1 do begin
 if (M[x,x,1]=0) and (M[x,x,2]=0) then begin;CMinv:=x;exit;end;
 z2:=-1/M[x,x]; 
  for y:=x-1 downto a do if ((M[x,y,1]<>0) or (M[x,y,2]<>0)) then begin
   z:=z2*M[x,y];
   for i:=0 to a-1 do cadd(M[i,y],z*M[i,x]);
   for i:=x+1 to b do cadd(M[i,y],z*M[i,x]);
   M[x,y]:=czero;
   for i:=a to N-1 do cadd(R[i,y],z*R[i,x]);
//   for i:=0 to N-1 do cadd(M[i,y],z*M[i,x]);
  end;end;
for x:=a to b do begin
 if (M[x,x,1]=0) and (M[x,x,2]=0) then begin;CMinv:=x;exit;end;
 z:=1/M[x,x];
 for i:=0 to a-1 do M[i,x]:=M[i,x]*z;
 for i:=a to N-1 do R[i,x]:=z*R[i,x];

 M[x,x]:=R2C(1,0);
 end;
  
for x:=a to b do
 for y:=0 to a-1 do if ((M[x,y,1]<>0) or (M[x,y,2]<>0)) then begin
   z:=-M[x,y];
   for i:=0 to a-1 do cadd(M[i,y],z*M[i,x]);
   for i:=a to N-1 do cadd(R[i,y],z*R[i,x]);
   M[x,y]:=R2C(0,0);
 end;
//cmwrite(N,N,M);
end;




Procedure CMsetsize(N,L : integer;var M : cmat);
var
x : integer;
begin
setlength(M,N);
for x:=0 to N-1 do setlength(M[x],L);
end;

end.
