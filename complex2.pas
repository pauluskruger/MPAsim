unit complex2;
interface
type
Tr = double;
Tc = array[1..2] of Tr;
const
 Czero : tc = (0,0);

function cmaal(a,b : tc) : tc;
operator *(a,b:tc) Z:tc; 
operator +(a,b:tc) Z:tc; 
operator -(a,b:tc) Z:tc; 
operator /(a,b:tc) Z:tc; 

operator *(a : tc;b:tr) Z:tc; 
operator *(a : tr;b:tc) Z:tc; 
operator +(a : tc;b:tr) Z:tc; 
operator +(a : tr;b:tc) Z:tc; 
operator -(a : tc;b:tr) Z:tc; 
operator -(a : tr;b:tc) Z:tc; 
operator -(a : tc) Z:tc; 
operator /(a : tc;b:tr) Z:tc; 
operator /(a : tr;b:tc) Z:tc; 

function csmaal(a,b : tc) : tc;
function cplus(a,b : tc) : tc;
function cabs2(a : tc) : Tr;
function crad(a : tc) : Tr;
function cdeel(a,b : tc) : tc;
function r2c(a,b : Tr) : tc;
function rh2c(a,b : Tr) : tc;
function crmaal(a : tc;b : Tr) : tc;
function cinv(a : tc): tc;
function expi(a : Tr) : tc;
function expc(a : Tc) : tc;
function ccomp(a : Tc) : tc;
procedure cadd(var a : tc;b : tc);
procedure caddr(var a : tc;b : tr);
procedure caddc(var a : tc;b : tr);
procedure cadd(var a : tc;b : tc;s : Tr);
function cinner(a,b : tc):tr; 
function csqrt(a : tc): tc;

Procedure cwrite(a : tc);
Procedure writeEng(a : tr);
Procedure cwriteEng(a : tc);

function getkode(x : double) : double;
function FloatToEng2(x : double) : string;
implementation
uses math;
function getkode(x : double) : double;
const
 vals : array[1..24] of integer=(10,11,12,15,16,18,20,22,24,27,30,33,36,39,43,47,51,56,62,68,75,82,91,100);
var
n,i : integer;
z : double;
begin
n:=floor(log10(x))-1;
z:=power(10,n);
x:=x/z;
i:=1;
while (i<=34) and (abs(vals[i]-x)>abs(vals[i+1]-x)) do inc(i);
getkode:=vals[i]*z;
end;

function FloatToEng2(x : double) : string;
const
 s : array[-5..4] of char = ('f','p','n','u','m','.','k','M','G','T');
var
n,n2,i : integer;
z : double;
c1,c2 : char;
c3 : string;
begin
n:=floor(log10(x)-0.001);
z:=power(10,n-1);
i:=round(x/z);
if i>=100 then begin;i:=i div 10;n:=n+1;end;

c1:=chr(i div 10+ord('0'));
c2:=chr(i mod 10+ord('0'));
n2:=floor(n/3);
n:=n-n2*3;
if (n2<-5) or (n2>4) then c3:='e' else c3:=s[n2];
if (n2=0) and (n>0) then c3:='';
//writeln('n2=',n2,' n=',n,' c1=',c1,' c2=',c2,' i=',i);
case n of
 0 : FloattoEng2:=c1+c3+c2;
 1 : FloattoEng2:=c1+c2+c3;
 2 : FloattoEng2:=c1+c2+'0'+c3;
 end;
end;

operator *(a,b:tc) z:tc; 
begin 
 z[1]:=a[1]*b[1]-a[2]*b[2];
 z[2]:=a[2]*b[1]+a[1]*b[2];
end;
operator +(a,b:tc) z:tc; 
begin
 z[1]:=a[1]+b[1];
 z[2]:=a[2]+b[2];
end;
operator -(a,b:tc) z:tc; 
begin
 z[1]:=a[1]-b[1];
 z[2]:=a[2]-b[2];
end;

operator /(a,b:tc) z:tc; 
var
 ab : Tr;
begin
 ab:=cabs2(b);
 assert(ab=0);
 z[1]:=(a[1]*b[1]+a[2]*b[2])/ab;
 z[2]:=(a[2]*b[1]-a[1]*b[2])/ab;
end;

operator *(a : tc;b:tr) Z:tc; 
begin
 Z[1]:=a[1]*b;
 Z[2]:=a[2]*b;
end;

operator *(a : tr;b:tc) Z:tc; 
begin
 Z[1]:=b[1]*a;
 Z[2]:=b[2]*a;
end;

operator +(a : tc;b:tr) Z:tc; 
begin
 Z[1]:=a[1]+b;
 Z[2]:=a[2];
end;

operator +(a : tr;b:tc) Z:tc; 
begin
 Z[1]:=b[1]+a;
 Z[2]:=b[2];
end;

operator -(a : tc;b:tr) Z:tc; 
begin
 Z[1]:=a[1]-b;
 Z[2]:=a[2];
end;
operator -(a : tc) Z:tc; 
begin
 Z[1]:=-a[1];
 Z[2]:=-a[2];
end;

operator -(a : tr;b:tc) Z:tc; 
begin
 Z[1]:=a-b[1];
 Z[2]:=-b[2];
end;

operator /(a : tc;b:tr) Z:tc; 
begin
 b:=1/b;
 z:=a*b;
end;

operator /(a : tr;b:tc) Z:tc; 
begin
 b:=cinv(b);
 z:=b*a;
end;


function cmaal(a,b : tc) : tc;
begin cmaal:=a*b; end;

function cplus(a,b : tc) : tc;
begin cplus:=a+b; end;

function cmin(a,b : tc) : tc;
begin cmin:=a-b; end;

function cdeel(a,b : tc) : tc;
begin cdeel:=a/b; end;

function csmaal(a,b : tc) : tc;
var  z : tc;
begin
 z[1]:=a[1]*b[1]+a[2]*b[2];
 z[2]:=-a[2]*b[1]+a[1]*b[2];
 csmaal:=z;
end;

function cabs2(a : tc) : Tr;
begin cabs2:=a[1]*a[1]+a[2]*a[2]; end;

function r2c(a,b : Tr) : tc;
var  z : tc;
begin  z[1]:=a; z[2]:=b; r2c:=z; end;

function rh2c(a,b : Tr) : tc;
var  z : tc;
begin  z[1]:=a*cos(b); z[2]:=a*sin(b); rh2c:=z; end;


function crmaal(a : tc;b : Tr) : tc;
begin crmaal:=a*b; end;

function cinv(a : tc): tc;
var  r : Tr;
begin  r:=cabs2(a);{if r<1e-100 then cinv:=r2c(1e99,1e99) else} cinv:=r2c(a[1]/r,-a[2]/r);end;

function expi(a : Tr) : tc;
begin  expi:=r2c(cos(a),sin(a)); end;

function expc(a : Tc) : tc;
begin  expc:=exp(a[1])*r2c(cos(a[2]),sin(a[2])); end;

function ccomp(a : Tc) : tc;
begin
ccomp[1]:=a[1];
ccomp[2]:=-a[2];
end;

procedure cadd(var a : tc;b : tc);
begin; a[1]:=a[1]+b[1];a[2]:=a[2]+b[2];end;

procedure caddr(var a : tc;b : tr);
begin; a[1]:=a[1]+b;end;
procedure caddc(var a : tc;b : tr);
begin; a[2]:=a[2]+b;end;

procedure cadd(var a : tc;b : tc;s : Tr);
begin; a[1]:=a[1]+b[1]*s;a[2]:=a[2]+b[2]*s;end;

function cinner(a,b : tc):tr; 
begin
cinner:=a[1]*b[1]+a[2]*b[2];
end;

Procedure cwrite(a : tc);
begin
write(a[1]:8:4,a[2]:8:4);
end;

function csqrt(a : tc): tc;
var
 r,c,b : double;
begin
 r:=sqrt(cabs2(a));
 c:=sqrt((r+a[1])/2);
 b:=sqrt((r-a[1])/2);
   if a[2]>=0 then csqrt:=r2c(c,b)
           else csqrt:=r2c(c,-b);
end;


Procedure writeEng(a : tr);
const
 nm : array[-6..4] of char = ('a','f','p','n','u','m',' ','k','M','G','T');
var
 n : integer;
 b : double;
 c,x : integer;
begin
if a=0 then begin
  write('+0.00 ');
  exit;
  end;
b:=abs(a);
n:=0;
while b>10 do begin;inc(n);b:=b/10;end;
while b<1 do begin;dec(n);b:=b*10;end;
c:=floor(n/3);
n:=n-c*3;
for x:=1 to n do b:=b*10;
if a<0 then write('-') else write('+');
case n of
 0 : write(b:4:2);
 1 : write(b:4:1);
 2 : write(b:4:0);
 end;
 if (c<-6) or (c>4) then write('e'{,c*3}) else write(nm[c]);
end;

Procedure cwriteEng(a : tc);
begin
writeEng(a[1]);
writeEng(a[2]);
write('i ');
end;
{
function crad(a : tc) : Tr;
var
 r : tr;
begin
//cwriteEng(a);
 if (a[1]=0) then 
   if (a[2]=0) then r:=0 else
   if a[2]<0 then r:=-pi/2 else 
                  r:=pi/2
  else   begin
    r:=arctan(a[1]/a[2]);
//    if a[1]<0 then r:=r+pi;
 if a[2]<0 then r:=r-pi;
 end;
crad:=r;
//writeln('*');
end;
}
function crad(a : tc) : Tr;
var
 r : tr;
begin
//cwriteEng(a);
 if (a[1]=0) then 
   if (a[2]=0) then r:=0 else
   if a[2]<0 then r:=-pi/2 else 
                  r:=pi/2
  else  begin
    r:=arctan(a[2]/a[1]);
//    if a[1]<0 then r:=r+pi;
 if a[1]<0 then r:=r-pi;
 end;
crad:=r;
//writeln('*');
end;

end.