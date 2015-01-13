unit varu;

interface
//uses compu,sport,vectorD;
type
 Tvars = object
   name,tiepe : string;
   parent : pointer;
   function paramnum(s : string) : integer; virtual;
   function paramdouble(wat : integer) : boolean; virtual;
   function paramstr(wat : integer) : string; virtual;
   function getD(wat : integer) : double; virtual;
   Procedure setD(z : double;wat : integer); virtual;
   Procedure setD2(s : string;wat : integer); virtual;
   constructor create(P : pointer);
  end;
 Pvars = ^Tvars;

Tdvar = record
  C : Pvars;
  wat : integer;
  lmin,lmax,lstp : boolean;
  min,max : double;
  step,stp : double;
  end;

Pdouble = object
  tiepe,wat : integer;
  d : double;
  C : pvars;
  function get : double;
  procedure setd(z : double); overload;
  procedure setd(s : string;p : pointer); overload;
  procedure setval(z : double);
  end;
 Tparam = record
       name,value : string;
       end;
 Tparams = array of Tparam;
Tparm = record
 C : Pvars;
 W : integer;
 end;


implementation
uses stringe,math,sport,compu,sysutils;

procedure readDvar2(var C : Pvars;var wat: integer;ss : string;Sp : Psport);
var
 i,x : integer;
 s,s2 : string;
begin
  s:=splitdp(ss);
//writeln('readDvar2 s="',s,'"');
  if s='FP' then C:=SP^.PClayout 
    else C:=SP^.findcomp(s);
  if c=nil then begin
    writeln(sp^.name,' Can not find component ',s);
    halt(1);
    end;
  wat:=C^.Paramnum(ss);
  if wat=0 then begin
    writeln(sp^.name,' Can not find parameter ',ss,' of component ',s);
    halt(1);
    end;
end;

constructor Tvars.create(P : pointer); 
begin
end;
function Tvars.paramnum(s : string) : integer; 
begin; 
paramnum:=0;
end;

function Tvars.getD(wat : integer) : double;
begin
getD:=0;
end;

Procedure Tvars.setD(z : double;wat : integer);
begin
end;
Procedure tvars.setD2(s : string;wat : integer);
begin
end;

function tvars.paramstr(wat : integer) : string; 
begin
paramstr:=inttostr(wat);
end;

function tvars.paramdouble(wat : integer) : boolean;
begin
paramdouble:=true;
end;

function Pdouble.get : double;
begin
case tiepe of
 0 : get:=d;
 1 : get:=C^.getD(wat);
 else
 get:=0;
 end;
end;

procedure Pdouble.setd(z : double);
Begin;
tiepe:=0;
d:=z;
end;

procedure Pdouble.setd(s : string;p : pointer); 
begin
tiepe:=1;
readDvar2(C,wat,s,Psport(p));
end;

procedure Pdouble.setval(z : double);
begin
case tiepe of
 0 : d:=z;
 1 : C^.setD(z,wat);
 end;
end;

end.