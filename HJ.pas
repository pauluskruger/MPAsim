unit HJ;

// Hooke And Jeeves
interface
type
Tf = function(s : array of double) : double;
TCc = function(s : array of double;i : integer;z : double) : double;

function optim(f : Tf;Fc : TCc;var x0 : array of double;n : integer) : boolean;

implementation
uses crt;
const
 Max = 100;
type 
vector = array[1..Max] of double;

function optim(f : Tf;Fc : TCc;var x0 : array of double;n : integer) : boolean;
const
 hmin = 1e-3;
 reduction = 0.1;
 smallvalue = 1e-12;
 fwx=10;dpx=4;
 fwf=14;
 fws=14;dps=8;
type
 str = packed array [1..12] of char;
 point = record
   x : vector;f : real;
   end;
var
 fe : integer;
 B1,B2,B3 : point;
 P : point;
 h : double;

  Procedure outputline (step : double;s : str;p : point);
  var
   i : integer;
  begin
//   write(step:fws:dps,' ',p.f:fwf,' ',s);
//   for i:=1 to 2 do write(p.x[i]:fwx:dpx);writeln;
  end; 
   
  Procedure initialise;
  var i :integer;
   begin; fe:=0; 
    for i:=1 to n do b1.x[i]:=x0[i-1];
     b1.f:=f(b1.x); end;
 
  Procedure exploration(oldbase:point;var newbase:point);
  var
   i : integer;fval : double;
  begin 
   newbase:=oldbase;
   for i:=1 to n do begin
     newbase.x[i]:=Fc(oldbase.x,i,oldbase.x[i]+h);   fval:=f(newbase.x);
     if fval<newbase.f then newbase.f:=fval
       else begin
         newbase.x[i]:=Fc(oldbase.x,i,oldbase.x[i]-h); fval:=f(newbase.x);
	 if fval<newbase.f then newbase.f:=fval
	                   else newbase.x[i]:=oldbase.x[i];
	 end;
     end;
  for i:=1 to n do newbase.x[i]:=Fc(newbase.x,i,newbase.x[i]);

  outputline(h,'exploration',newbase);
  end;
  
  Procedure patternmove (b1,b2:point;var P:point);
  var i : integer;
  begin
   for i:=1 to n do P.x[i]:=Fc(P.x,i,2*b2.x[i]-b1.x[i]);
   P.f:=f(P.x);
   outputline(h,'pattern move',P);
  end;

var
 improvement : boolean;
 i : integer;
begin
h:=0.1;
initialise;
repeat
 exploration(b1,b2);
 improvement:=b2.f < b1.f - smallvalue;
 if not improvement then h:=h*reduction
 else repeat
  patternmove(b1,b2,P);
  exploration(P,b3);
  improvement:=b3.f<b2.f-smallvalue;
  if improvement then begin; b1:=b2; b2:=b3; end
    else begin b1:=b2;outputline(h,'Base change',b1);end;
  until not improvement;
until (h<hmin) or keypressed;
optim:=true;
 for i:=1 to n do x0[i-1]:=b1.x[i];
end;

end.