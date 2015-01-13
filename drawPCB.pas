unit drawPCB;
interface
uses vectorD,complex2,draw;
type
TPCBline = record
  name,data : string;
  layer : integer;
  end;
 TdwPCB = object(Tdraw)
 f : text;
 D : array of TPCBline;
 ro : tc;
  constructor create(filename : string);
  procedure poly(n : integer;v : cvec;nm : string); virtual;
  procedure via(r : tc;diam,diam2 : double;nm : string); virtual;
  Procedure rect(r0,r1 : tc;w : double;nm : string); virtual;
  procedure closedrw; virtual;
  procedure show; virtual;
  
  procedure addline(nm,s : string);
  end;
 PdwPCB = ^TdwPCB;
 
implementation
uses baseunix,unix,math,sysutils;

const
scale=3937000;
procedure TdwPCB.addline(nm,s : string);
var
 x : integer;
begin
 x:=length(D);
 setlength(D,x+1);
 D[x].name:=nm;
 D[x].data:=s;
 D[x].layer:=layer;
end;

constructor TdwPCB.create(filename : string);
  begin
  inherited create(filename);
  writeln('PCB file=',filename);
  shell('cp pcbheader.txt '+filename);
  assign(f,filestr);
  append(f);
  setlength(D,0);
  ro:=r2c(-100e-3,-100e-3);
  end;
  
  procedure TdwPCB.poly(n : integer;v : cvec;nm : string);
  var
   x : integer;
   s : string;
  begin
   s:=#9'Polygon("")'#10#9'(';
   for x:=0 to n-1 do begin
    if x mod 6=0 then s:=s+#10#9#9;
    s:=s+'['+inttostr(round(scale*(v[x,1]-ro[1])))+' '+inttostr(round(scale*(v[x,2]-ro[2])))+'] ';
    end;
    s:=s+#10#9+')';
   addline(nm,s);
  end;
  
  
Procedure TdwPCB.rect(r0,r1 : tc;w : double;nm : string);
var
 ra,rb,rm,dr : tc;
 l : double;
// w : double;
begin
if layer<>1 then inherited rect(r0,r1,w,nm)
 else begin
 r0:=r0-ro;
 r1:=r1-ro;
// if r1[1]-r0[2]
 ra:=r0;
 rb:=r1;
 dr:=ra-rb;
 l:=sqrt(cabs2(dr));
 dr:=dr/l;
 if l<w then begin
   rm:=(ra+rb)/2;
   dr:=dr*r2c(0,1);
   ra:=rm+dr*w/2;
   rb:=rm-dr*w/2;
   w:=l;
   end;
//   rm:=ra;
 ra:=ra-dr*w/2;
 rb:=rb+dr*w/2;
// w:=sqrt(cabs2(r0-ra))*2;
 rm:=(ra+rb)/2;
// rm:=ra;
 rb:=rb-rm;
 ra:=ra-rm;
writeln(f,'Element["" "',nm,'" "" "" ',round(scale*rm[1]),' ',round(scale*rm[2]),' -6500 4000 1 100 ""]');
writeln(f,'(');
writeln(f,#9'Pad[',round(scale*ra[1]),' ',round(scale*ra[2]),' ',round(scale*rb[1]),' ',round(scale*rb[2]),' ',round(scale*w),' 0 0 "1" "1" "square"]');
writeln(f,')');
end;end;
  

  procedure TdwPCB.closedrw;
  const
   layernm : array[1..10] of string=('component','solder','GND','power','signal1','signal2','signal3','signal4','silk','silk');
 var
 x,y : integer;

  begin
  for x:=1 to 10 do begin
    writeln(f,'Layer(',x,' "',layernm[x],'")');
    writeln(f,'(');
    if x=1 then begin
     for y:=1 to length(d) do {if d[y-1].layer=0 then} writeln(f,d[y-1].data);
    
    end;
    writeln(f,')');
    end;
  close(f);
  if doshow then show;
  end;

  procedure TdwPCB.show;
  begin
   shell('pcb '+filestr+' &');
  end;

  procedure TdwPCB.via(r : tc;diam,diam2 : double;nm : string);
  var
   x,y : integer;
  begin
  r:=r-ro;
  x:=round(diam*scale);
  y:=round(diam2*scale);
writeln(f,'Via[',round(scale*r[1]),' ',round(scale*r[2]), ' ',y,' ',x,' 0 ',x,' "',nm,'" ""]');

  end;



end.