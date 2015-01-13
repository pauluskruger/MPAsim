unit stringe;
interface
const 
 MAXSTR = 10000;
type
 Tstrings = array[1..MAXSTR] of string;

function len(ss : Tstrings) : integer;
function strtostrs(s : string) : Tstrings;
function strtostrsc(s : string) : Tstrings;
function splitdp(var s : string) : string;
procedure subs(var s : string;c1,c2 : char);
Procedure deletechar(c : char;var ss : string);



implementation

function len(ss : Tstrings) : integer;
var
 x : integer;
begin
 x:=1;
 while (x<=MAXSTR) and (ss[x]<>#0) do inc(x);
 if x>MAXSTR then len:=-1
             else len:=x-1
end;

procedure subs(var s : string;c1,c2 : char);
var
 x : integer;
 begin
for x:=1 to length(s) do if s[x]=c1 then s[x]:=c2;
end;


function strtostrs(s : string) : Tstrings;
var
 x,y : integer;
 ss : Tstrings;
begin
 x:=1;
 y:=pos(' ',s);
 while y=1 do begin
        delete(s,1,1);
        y:=pos(' ',s);
        end;
 while (y>0) and (x<=MAXSTR) do begin
    ss[x]:=copy(s,1,y-1);
    delete(s,1,y);
    y:=pos(' ',s);
    while y=1 do begin
        delete(s,1,1);
        y:=pos(' ',s);
        end;
    inc(x);
    end;
  if (length(s)>0) and (x<=MAXSTR) then begin
      ss[x]:=s;
      inc(x);
      end;
  if x<=MAXSTR then ss[x]:=#0;
  strtostrs:=ss;
end;

function strtostrsc(s : string) : Tstrings;
const 
 c = ' ';
var
 x,y,l,a,b : integer;
 ss : Tstrings;
 kw,kw2 : boolean;
begin
 x:=1;
 l:=length(s);
 kw:=false;kw2:=false;
 y:=1;a:=1;
 while (y<=l) and (x<=MAXSTR) do begin
 a:=y;
 while (y<=l) and (s[y]=c) do begin;inc(y);a:=y;end; //a = Find first non-c
 while (y<=l) and ((s[y]<>c) or kw or kw2) do begin;
   if s[y]='"' then kw:=not(kw);
   if s[y]='''' then kw2:=not(kw2);
   inc(y);
   end; //y = next c

 if a<=l then begin
   ss[x]:=copy(s,a,y-a);
{   b:=pos('"',ss[x]); //delete '"'
   while b>0 do begin
     delete(ss[x],b,1);
     b:=pos('"',ss[x]);
     end;}
   inc(x);
   end;
 
 end;
// writeln('x=',x);
  if x<=MAXSTR then ss[x]:=#0;
  strtostrsc:=ss;
end;
Procedure deletechar(c : char;var ss : string);
var
 b : integer;
begin
   b:=pos(c,ss); //delete '"'
   while b>0 do begin
     delete(ss,b,1);
     b:=pos(c,ss);
     end;
end;
function splitdp(var s : string) : string;
var
 y : integer;
begin
 y:=pos(':',s);
 if y=0 then begin
   splitdp:=s;
   s:='';
   end else begin
   splitdp:=copy(s,1,y-1);
   delete(s,1,y);
   end;
end;

end.