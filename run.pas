uses sport,complex2,vectorD,consts,sysutils;
var
 S : Psport;
 f : text;  
 tm : tdatetime;
begin;
writeln('**** NB ****');
writeln('Subckt compN n>2 error disabled');
writeln('Subckt saveZ disabled');
writeln('************');

 if paramcount<1 then begin
   writeln('run filename');
   exit;
   end;
 tm:=now;
 assign(f,paramstr(1));
 reset(f);
 S:=new(psport,create(nil)); 
 pin.c:=nil;pout.c:=nil;
 S^.readfile(f);
 close(f);
 S^.closecomp;
 tm:=now-tm;
 writeln('TOTAL RUN TIME=',tm*24*60*60:0:1,'sec');
end.
   