unit ascolink;
interface
uses compu,vectorD,varu;

Procedure asco_readvars(vars : tvec;N : integer;filename : string);
Procedure asco_writefunc(filename,funcname : string;val : double);
Procedure asco_writeconfig(filename : string;vars : array of Tdvar);


implementation

Procedure asco_writefunc(filename,funcname : string;val : double);
var
 f : text;
begin
assign(f,filename);
{$i-}
//append(f);
rewrite(f);
{$i+}
if ioresult<>0 then rewrite(f);
writeln(f,funcname);
writeln(f,val);
writeln(f);
close(f);
end;

Procedure asco_readvars(vars : tvec;N : integer;filename : string);
var
 f : text;
 x : integer;
 z : double;
begin
assign(f,filename);
reset(f);
readln(f);
for x:=0 to N-1 do begin
 read(f,z);
 vars[x]:=z;
 end;
close(f);
end;

Procedure asco_writeconfig(filename : string;vars : array of Tdvar);
var
 f : text;
 x : integer;
begin
assign(f,filename+'.txt');
rewrite(f);
writeln(f,'Nslv');
for x:=0 to length(vars)-1 do writeln(f,'#',vars[x].C^.name,vars[x].wat,'#');
close(f);

assign(f,filename+'.cfg');
rewrite(f);
writeln(f,'#Optimization Flow#');
writeln(f,'Alter:no           $do we want to do corner analysis?');
writeln(f,'MonteCarlo:no      $do we want to do MonteCarlo analysis?');
writeln(f,'Minumum cost:0.00   $point at which we want to start ALTER and/or MONTECARLO');
writeln(f,'ExecuteRF:yes       $Execute or no the RF module to add RF parasitics?');
writeln(f,'SomethingElse:      $');
writeln(f,'#');
writeln(f,'#DE#');
writeln(f,'choice of method:3');
writeln(f,'maximum no. of iterations:50');
writeln(f,'Output refresh cycle:2');
writeln(f,'No. of parents NP:20');
writeln(f,'Constant F:0.85');
writeln(f,'Crossing Over factor CR:1');
writeln(f,'Seed for pseudo random number generator:3');
writeln(f,'Minimum Cost Variance:1e-6');
writeln(f,'Cost objectives:10');
writeln(f,'Cost constraints:100');
writeln(f,'#');
writeln(f,' ALTER #');
writeln(f,'*.protect');
writeln(f,'*.inc [../models/cmos035_slow.mod ../models/cmos035_typ.mod ../models/cmos035_fast.mod]');
writeln(f,'*.unprotect');
writeln(f,'*.temp [-40 +25 +85]');
writeln(f,'.param');
writeln(f,'+    V_SUPPLY=[2.0 2.1 2.2]');
writeln(f,'*.protect                                                $ As much as 6 variables can be swept at the same time.');
writeln(f,'*.lib hl49ciat57k5r200.mod [mos_wcs mos_nom mos_bcs]     $ Format is [a] or [a b] or ... [a b c d e f] =>1 space');
writeln(f,'*.unprotect                                              $ and not :[ a], [a ], [ a ] => space is not really necessary');
writeln(f,'*.temp [-40 +25 +85]                                     $ and not :[a  b]            => only 1 '' '' between ''a'' and ''b''');
writeln(f,'*.param                                                  $ Add ''*'' to skip a line');
writeln(f,'*+    vddd=[2.25 2.50 3.30]                              $');
writeln(f,'*+    kc=[0.95 1.05]:LIN:10        $ LIN not yet implemented');
writeln(f,'*+    kr=[0.87 1.13]:LOG:10        $ LOG not yet implemented');
writeln(f,'*+    Ierror=[0.7 1.3]');
writeln(f,'*+    k00=[0 1]');
writeln(f,'*+    k01=[0 1]');
writeln(f,'*+    k02=[0 1]');
writeln(f,'*+    k03=[0 1]');
writeln(f,'*+    k04=[0 1]');
writeln(f,'*+    k05=[0 1]');
writeln(f,'*+    k06=[0 1]');
writeln(f,'*+    k07=[0 1]');
writeln(f,'*+    k08=[0 1]');
writeln(f,'*+    k09=[0 1]');
writeln(f,'#');
writeln(f,'#Monte Carlo#');
writeln(f,'NMOS_AVT:12.4mV           $ This values will be divided by sqrt(2) by the program');
writeln(f,'NMOS_ABETA:7.3%           $ ''m'' parameter is taken into account');
writeln(f,'PMOS_AVT:10.9mV           $');
writeln(f,'PMOS_ABETA:3.7%           $');
writeln(f,'SMALL_LENGTH:0.0u         $ Small transistors if l<= SMALL_LENGTH');
writeln(f,'SMALL_NMOS_AVT:20mV       $ Small transistors parameters');
writeln(f,'SMALL_NMOS_ABETA:10%      $');
writeln(f,'SMALL_PMOS_AVT:10mV       $');
writeln(f,'SMALL_PMOS_ABETA:5%       $');
writeln(f,'R_DELTA:0.333%            $ Resistors matching at 1 sigma between two resistors');
writeln(f,'L_DELTA:0.333%            $ Inductors matching at 1 sigma between two inductors');
writeln(f,'C_DELTA:0.333%            $ Capacitors matching at 1 sigma between two capacitors');
writeln(f,'#');
writeln(f,'# Parameters #');
for x:=0 to length(vars)-1 do with vars[x] do writeln(f,C^.name,wat,':#',C^.name,wat,'#:',C^.getD(wat),':',min,':',max,':LIN_DOUBLE:OPT');
writeln(f,'#');
writeln(f,'# Measurements #');
writeln(f,'FF:---:MIN:---');
writeln(f,'#');
writeln(f,'# Post Processing #');
writeln(f,'#');
writeln(f,'#this is the last line');
close(f);

assign(f,'extract/FF');
rewrite(f);
writeln(f,'# Info #');
writeln(f,'Name:P_OUT');
writeln(f,'Symbol:ZP_OUT');
writeln(f,'Unit:W');
writeln(f,'Analysis type:TRAN');
writeln(f,'Definition:asd asd asd asd');
writeln(f,'Note:asd asd asd asd');
writeln(f,'#');
writeln(f,'# Commands #');
writeln(f,'#');
writeln(f,'# Post Processing #');
writeln(f,'MEASURE_VAR:   #SYMBOL#: SEARCH_FOR:''F'': S_COL:01: P_LINE:01: P_COL:01:25');
writeln(f,'#');
close(f);
end;

end.
