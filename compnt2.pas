unit compnt2; 
interface
uses vectorD,complex2,FET,consts,stringe,compu,savedata,varu,sport;

type

 T1port = object(Tcomp)
   D : Tsave1;
   temp : double; 
   Zvar1,Zvar2 : Toutvar;
   z,z2 : tc;
   oldw : double;
   constructor create(P : pointer); 
   Procedure getY(w : double;var Y : cmat); virtual;
//   Procedure getN(w : double;var N : cmat); virtual;
   Procedure load(Np : integer;P : Tparams); virtual;
   procedure doUpdate(w : double;V0,Z0 : cvec;cnt : integer); virtual;
   end; 

 P1port = ^T1port;

 
implementation
uses sysutils,math;




constructor t1port.create(P : pointer);
begin inherited create(P);Nnode:=2;AlwaysUpdate:=true; end;

Procedure T1port.load(Np : integer;P : Tparams);
var
 s : string;
begin
D.init;
 Zvar1:=Psport(parent)^.readoutvar(P[0].value);
 Zvar2:=Psport(parent)^.readoutvar(P[1].value);
 temp:=getparm(Np,P,'TEMP',0);
 if temp>0 then Nnoise:=1 else Nnoise:=0;
 z:=czero;z2:=czero;
end;

Procedure T1port.getY(w : double;var Y : cmat);
begin
D.getsaved(w,z);
addblk(Y,node[0],node[0],node[1],node[1],z);
end;

procedure T1port.doUpdate(w : double;V0,Z0 : cvec;cnt : integer);
begin
z2:=r2c(psport(parent)^.getoutvar2(Zvar1,w),psport(parent)^.getoutvar2(Zvar2,w));
if (z2[1]<>z[1]) or (z2[2]<>z[2]) then begin
 z:=z2;
 D.savedata(w,z);
 recalc(w);
// write(name,': T1port recalc z=');cwriteEng(z);writeln;
 end;
end;

end.