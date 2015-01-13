unit draw;
interface
uses vectorD,complex2;
type
 Tdraw = object
  filestr : string;
  doshow : boolean;
  layer : integer;
  fontsize : double;
  constructor create(filename : string);
  procedure poly(n : integer;v : cvec;nm : string); virtual;
//  Procedure line(r0,r1 : tc;w : double;nm : string); virtual;
  procedure hole(r : tc;diam : double;nm : string); virtual;
  procedure via(r : tc;diam,diamp : double;nm : string); virtual;
  procedure arc(r0 : tc;r,th1,th2 : double;nm : string); virtual;
  procedure arc2(var r1,d : tc;r,th,w,dir : double;nm : string); virtual;
  procedure circle(r0 : tc;r : double;nm : string); virtual;
  Procedure rect(r0,r1 : tc;w : double;nm : string); virtual;
  procedure lable(r0,dir : tc;s,nm : string); virtual;
  procedure closedrw; virtual;
  procedure show; virtual;
  end;
 Pdraw=^Tdraw;

 Tfig = object(Tdraw)
 f : text;
  constructor create(filename : string);
  procedure poly(n : integer;v : cvec;nm : string); virtual;
//  Procedure line(r0,r1 : tc;w : double;nm : string); virtual;
  procedure hole(r : tc;diam : double;nm : string); virtual;
  procedure arc(r0 : tc;r,th1,th2 : double;nm : string); virtual;
  procedure arc2(var r1,d : tc;r,th,w,dir : double;nm : string); virtual;
  procedure lable(r0,dir : tc;s,nm : string); virtual;
  procedure closedrw; virtual;
  procedure show; virtual;
  end;
 Pfig = ^Tfig;
 
implementation
uses baseunix,unix,math;
const
 figscale = 450000;

  constructor Tdraw.create(filename : string); begin;doshow:=false;filestr:=filename;layer:=0;end;
  procedure Tdraw.poly(n : integer;v : cvec;nm : string); begin;end;
  Procedure Tdraw.rect(r0,r1 : tc;w : double;nm : string);
  var 
   v : cvec;
   d : tc;
  begin
  setlength(v,5);
  d:=r1-r0;
  d:=d/sqrt(cabs2(d));
  d:=d*r2c(0,0.5);
  v[0]:=r0+d*w;
  v[1]:=r0-d*w;
  v[2]:=r1-d*w;
  v[3]:=r1+d*w;
  v[4]:=v[0];
  poly(5,v,nm);
  end;
  procedure Tdraw.closedrw; begin;end;
  procedure Tdraw.show; begin;end;
  procedure Tdraw.hole(r : tc;diam : double;nm : string);begin;end;
  procedure Tdraw.via(r : tc;diam,diamp : double;nm : string); 
  begin
   circle(r,diamp/2,nm);
   layer:=2;
   hole(r,diam,nm);
  end;

  procedure Tdraw.arc(r0 : tc;r,th1,th2 : double;nm : string); begin;end;
 
  procedure Tdraw.arc2(var r1,d : tc;r,th,w,dir : double;nm : string); 
  var
   d2,d0,r0 : tc;
   x,N : integer;
   v : cvec;
  begin;
//  writeln('arc');
  w:=w/2;
  N:=ceil(abs(r*th)/0.1e-3);
  if N<4 then N:=4;
  d0:=-d*r2c(0,dir);
  r0:=r1-r*d0;
  d2:=expi(-th/(N-1));
  setlength(v,2*N+1);
  for x:=0 to N-1 do begin
    v[x]:=r0+(r-w)*d0;        
    v[2*N-x-1]:=r0+(r+w)*d0;
    d0:=d0*d2;
    end;
  V[2*N]:=V[0];
  poly(2*N+1,V,nm);
     
//writeln('th=',th);
  d2:=expi(-th);
{  if abs(th)<0.1 then begin
    d2:=r2c(1-th*th,-th);
    r1:=r1+r*d*r2c(d2[2],th*th);
    d:=d*d2;
  end else begin}
    r1:=r1+dir*r*d*r2c(d2[2],(1-d2[1]));
    d:=d*d2;
//  cwriteEng(d2);cwriteEng(d);cwriteEng(r1);writeln;
//end;
//  writeln('done');
  end;

procedure Tdraw.circle(r0 : tc;r : double;nm : string); 
const 
 N = 30;
var
 v : cvec;
 d,d0 : tc;
 x : integer;
begin
d:=r2c(1,0);
d0:=expi(2*pi/N);
setlength(v,N+1);
for x:=0 to N-1 do begin
  v[x]:=r0+r*d;
  d:=d*d0;
  end;
v[N]:=v[0];
poly(N+1,v,nm);

end;

procedure Tdraw.lable(r0,dir : tc;s,nm : string);
begin
end;

  constructor Tfig.create(filename : string);
  begin
  inherited create(filename);
  assign(f,filestr);
  rewrite(f);
  writeln(f,'#FIG 3.2  Produced by draw unit');
  writeln(f,'Landscape');
  writeln(f,'Center');
  writeln(f,'Metric');
  writeln(f,'A4    ');  
  writeln(f,'100.00');
  writeln(f,'Single');
  writeln(f,'-2');
  writeln(f,'1200 2');
  end;
  
  procedure Tfig.poly(n : integer;v : cvec;nm : string);
  var
   x : integer;
  begin
  write(f,'2 3 0 1 ',layer,' 7 ',50-layer,' -1 41 0.000 0 0 -1 0 0 ',n);
  for x:=0 to n-1 do begin
    if x mod 6=0 then begin;writeln(f);write(f,'     ');end;
    write(f,' ',round(v[x,1]*figscale),' ',round(v[x,2]*figscale));
    end;
   writeln(f);
  end;
  
  procedure Tfig.closedrw;
  begin
  close(f);
  if doshow then show;
  end;

  procedure Tfig.show;
  begin
   shell('xfig -nosplash '+filestr+' &');
  end;

  procedure Tfig.hole(r : tc;diam : double;nm : string);
  var
   x,y,d : longint;
  begin
  x:=round(r[1]*figscale);
  y:=round(r[2]*figscale);
  d:=round(diam*figscale/2);
  writeln(f,'1 3 0 1 0 ',layer,' ',50-layer,' -1 20 0.000 1 0.0000 ',x,' ',y,' ',d,' ',d,' ',x,' ',y,' ',x+d,' ',y);
  end;

  procedure Tfig.arc(r0 : tc;r,th1,th2 : double;nm : string);
  var
   x,y,thm : double;
  begin
  x:=(r0[1]*figscale);
  y:=(r0[2]*figscale);
  r:=r*figscale;
  thm:=(th1+th2)/2;
  write(f,'5 1 0 1 0 7 ',50-layer,' -1 -1 0.000 0 1 0 0 ',x:0:3,' ',y:0:3);
  write(f,' ',round(x+r*cos(th1)),' ',round(y+r*sin(th1)));
  write(f,' ',round(x+r*cos(thm)),' ',round(y+r*sin(thm)));
  write(f,' ',round(x+r*cos(th2)),' ',round(y+r*sin(th2)));
  writeln;
  end;

  procedure Tfig.arc2(var r1,d : tc;r,th,w,dir : double;nm : string);
  const
   N=10;
  var
   r0,d2 : tc;
   v : cvec;
  begin
//   writeln('th=',th);
if w=0 then begin
   r1:=r1*figscale;
   r:=r*figscale;
   d:=d*r2c(0,1);
   r0:=r1-r*d;
   d2:=expi(-th/2);
   write(f,'5 1 0 1 0 7 ',50-layer,' -1 -1 0.000 0 ');
   if th>0 then write(f,'1') else write(f,'0');
   write(f,' 0 0 ',r0[1]:0:3,' ',r0[2]:0:3);
   write(f,' ',round(r1[1]),' ',round(r1[2]));
   d:=d*d2;
   r1:=r0+r*d;
   write(f,' ',round(r1[1]),' ',round(r1[2]));
   d:=d*d2;
   r1:=r0+r*d;
   writeln(f,' ',round(r1[1]),' ',round(r1[2]));
   r1:=r1/figscale;
   d:=d*r2c(0,1);
   end else inherited arc2(r1,d,r,th,w,dir,nm);
end;

  procedure Tfig.lable(r0,dir : tc;s,nm : string);
  var 
  dr : double;
  begin
  dir:=dir*r2c(0,1);
  dr:=-crad(dir);
  if dr>pi/2 then begin
    dr:=dr-pi;
    dir:=-dir;
    end;
  if dr<=-pi/2+0.0001 then begin
    dr:=dr+pi;
    dir:=-dir;
    end;
  r0:=(r0+dir*r2c(0,1)*fontsize/2)*figscale;
//  dr:=0;
//  r0:=(r0+r2c(0,1)*fontsize/2)*figscale;
//  r0:=r0*figscale;
    writeln(f,'4 1 4 ',50-layer,' -1 16 ',round(fontsize*37038),' ',dr:0:4,' 4 0 0 ',round(r0[1]),' ',round(r0[2]),' ',s,'\001');
  end;


end.