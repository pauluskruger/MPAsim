unit savedata;
interface
uses vectorD,complex2;
type
 Tsavedata = record
   freq : double;
   YY,SN,DSN : cmat;
   end;
 Tsave = object
    private
    saveddata : array of Tsavedata;
    Nt,Nns : integer;
    Nsavedata,Lsavedata : integer;
    public
    function GetSaved(w : double;var YY1,SN1 : cmat) : boolean; 
    procedure savedata(w : double;YY1,SN1 : cmat);
    Procedure clear;
    procedure init(na,nb : integer);
 end;

 Tsave2 = object
   private
  saveddata : array of cvec;
  savefreq : array of double;
  Nv,Nsavedata,Lsavedata : integer;
    public
  procedure init(nv2 : integer);
  function GetSaved(w : double;var YY1 : cvec) : boolean; 
  procedure savedata(w : double;YY1 : cvec);
  Procedure clear;
  end;

 Tsave1 = object
   private
  saveddata : array of tc;
  savefreq : array of double;
  Nsavedata,Lsavedata : integer;
    public
  procedure init;
  function GetSaved(w : double;var YY1 : tc) : boolean; 
  procedure savedata(w : double;YY1 : tc);
  Procedure clear;
  end;
  
implementation
procedure Tsave.init(na,nb : integer);
begin
 Nt:=na;
 Nns:=nb;
 Nsavedata:=0;
nsavedata:=0;
lsavedata:=0;
end;

Procedure Tsave.clear;
var
 i,j : integer;
begin
nsavedata:=0;
end;


function Tsave.getSaved(w : double;var YY1,SN1 : cmat) : boolean;
var
 i,j,k : integer;
 saved : boolean;
begin 
//writeln('GetY:w=',w);
saved:=false;
for i:=0 to nsavedata-1 do if saveddata[i].freq=w then begin
      saved:=true;
      for j:=0 to Nt-1 do for k:=0 to Nt-1 do YY1[j,k]:=saveddata[i].YY[j,k];
      for k:=0 to Nt-1 do for j:=0 to Nns do Sn1[j,k]:=saveddata[i].Sn[j,k];
//      writeln('Get Y w=',w,' use save calc ',i);
      end;
getSaved:=saved;
end;

procedure Tsave.savedata(w : double;YY1,SN1 : cmat);
var
i,j,k : integer;
begin
for i:=0 to nsavedata-1 do if saveddata[i].freq=w then begin
      for j:=0 to Nt-1 do for k:=0 to Nt-1 do saveddata[i].YY[j,k]:=YY1[j,k];
      for k:=0 to Nt-1 do for j:=0 to Nns do saveddata[i].Sn[j,k]:=Sn1[j,k];
      exit;
//      writeln('Get Y w=',w,' use save calc ',i);
  end;
if nsavedata>=lsavedata then begin
  inc(lsavedata,10);
  setlength(saveddata,lsavedata);
  for j:=lsavedata-10 to lsavedata-1 do with saveddata[j] do begin
           CMsetsize(Nt,Nt,YY);
	   CMsetsize(Nns+1,Nt,Sn);
	   end;
  end;
      for j:=0 to Nt-1 do for k:=0 to Nt-1 do saveddata[nsavedata].YY[j,k]:=YY1[j,k];
      for k:=0 to Nt-1 do for j:=0 to Nns do saveddata[nsavedata].Sn[j,k]:=Sn1[j,k];
      saveddata[nsavedata].freq:=w;
      inc(nsavedata);   
end;

procedure Tsave2.init(nv2 : integer);
begin
nv:=nv2;
lsavedata:=0;
nsavedata:=0;
end;

Procedure Tsave2.clear;
begin
 Nsavedata:=0;
end;


function Tsave2.getSaved(w : double;var YY1 : cvec) : boolean;
var
 i,j : integer;
begin 
for i:=0 to nsavedata-1 do if savefreq[i]=w then begin
      for j:=0 to Nv-1 do YY1[j]:=saveddata[i,j];
      getsaved:=true;
//      writeln('savedata get w=',w);
      exit;
      end;
//writeln('savedat not found w=',w);
getSaved:=false;
end;

procedure Tsave2.savedata(w : double;YY1 : cvec);
var
i,j,k : integer;
begin
for i:=0 to nsavedata-1 do if savefreq[i]=w then begin
      for j:=0 to Nv-1 do saveddata[i,j]:=YY1[j];
      exit;
      end;
//writeln('savedate set w=',w);
if nsavedata>=lsavedata then begin
  inc(lsavedata,10);
  setlength(saveddata,lsavedata);
  setlength(savefreq,lsavedata);
  for j:=lsavedata-10 to lsavedata-1 do setlength(saveddata[j],nv);
  end;

for j:=0 to Nv-1 do saveddata[nsavedata,j]:=YY1[j];
savefreq[nsavedata]:=w;
inc(nsavedata);
end;

function Tsave1.getSaved(w : double;var YY1 : tc) : boolean;
var
 i : integer;
begin 
for i:=0 to nsavedata-1 do if savefreq[i]=w then begin
      YY1:=saveddata[i];
      getsaved:=true;
      exit;
      end;
getSaved:=false;
end;

procedure Tsave1.savedata(w : double;YY1 : tc);
var
i,k : integer;
begin
for i:=0 to nsavedata-1 do if savefreq[i]=w then begin
      saveddata[i]:=YY1;
      exit;
      end;
//writeln('savedate set w=',w);
if nsavedata>=lsavedata then begin
  inc(lsavedata,10);
  setlength(saveddata,lsavedata);
  setlength(savefreq,lsavedata);
  end;

saveddata[nsavedata]:=YY1;
savefreq[nsavedata]:=w;
inc(nsavedata);
end;
Procedure Tsave1.clear;
begin
 Nsavedata:=0;
end;

Procedure Tsave1.init;
begin
lsavedata:=0;
nsavedata:=0;
end;

end.