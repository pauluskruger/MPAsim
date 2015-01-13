const mask = 10; sqmask = mask*mask; clf = #10;
var s,t	: string;


function s2c: string;
begin
    s2c:= copy(s,1,2);
end;
function s3c: string;
begin
    s3c:= copy(s,1,3);
end;
function s1sc: string;
var i : LongInt;
begin
    i:= 4;
    while (i < length(s)) and (s[i+1] <> ' ') do inc(i);
    s1sc:= copy(s,4,i-3);
end;
function sb1s: string;          {string before 1'st space}
var i : LongInt;
begin
    i:= 3;
    while (i <= length(s)) and (s[i] <> ' ') do inc(i);
    sb1s:= copy(s,4,i-4);
end;

function gettext: string;
var i,j,k : LongInt;
begin
    i:= pos('\001',s);
    k:= 1;
    for j:= 1 to 13 do begin while s[k] <> ' ' do inc(k); inc(k) end;
    j:=i-k;
    gettext:= copy(s,k,j);
end;

function nxy: LongInt;		{vertex count of line}
var 	i,l : LongInt;
begin
    l:= length(s);
    i:= l-1;
    while s[i] <> ' ' do dec(i);
    val(copy(s,i+1,l-i),i,l);
    nxy:= LongInt(i);
end;

function npin: LongInt;
var 	i,l : LongInt;
begin
    l:= length(s);
    i:= 3;
    while (i < l) and (s[i] <> ' ') do inc(i);
    val(copy(s,4,i-3),i,l);
    npin:= LongInt(i);
end;

{--------------------------------------------}
type	pxyr= 	record x,y : LongInt end;

	lnvp=	^lnvr;                  { lines/tracks }
	lnvr=	record                  {}
            pxy     : pxyr;             {}
            nvp     : lnvp              {}
        end;                            {}
	linp=   ^linr;                  {}
	linr=	record                  {}
	    fln,lnn : LongInt;  	{fig line no, line node no}
	    nnm	    : string;		{node name}
	    pv0     : lnvp;		{ptr for vertex, ref ptr }
	    nlp	    : linp;		{next line ptr}
	end;


	pinp=	^pinr;                  { components }
	pinr=	record                  {}
            pxy     : pxyr;             {}
            nn      : LongInt;          {}
            nnm     : string[11];       {}
            npp     : pinp;             {}
        end;                            {}
	compp=	^compr;                 {}
	compr= 	record                  {}
	    fln	    : LongInt;		{fig line no, line node no}
            cn	    : LongInt;		{comp instance}
            cl      : string[11];       {component label}
            spice   : string;
	    pin0    : pinp;		{ptr to pins, ref ptr}
	    ncp     : compp;		{next comp ptr}
	end;

        cllp=   ^cllr;
        cllr=   record n: LongInt; ls: string[11]; lp: cllp; end; {comp label list}

var lnr	        : LongInt;
    cmp,cmp0    : compp;		{comp ptr, ref ptr}
    lin0,lin    : linp;                 {line ref ptr}
    xpp         : pinp;                 {extra pinpointer}
    f1          : text;
    cll,cll0    : cllp;                 {comp list ptr, ref ptr}
    prlnn       : LongInt;
{-------------------------------------------}
(* debug
procedure printlines;
var lp  : linp;
    pv  : lnvp;
begin
        inc(prlnn);
        write(clf,'node  no name   xy--',prlnn);
    lp := lin0;
    while lp <> nil do
    with lp^ do
    begin
        write(clf,fln:4,lnn:4,' ',nnm,#9);
        pv:= pv0;
        while pv <> nil do
        begin
            with pv^.pxy do write(x,#9,y,#9);
            pv:= pv^.nvp;
        end;
        lp:= nlp
    end;
end;

procedure printcompinfo;
var cmp : compp;
    pin : pinp;
begin

        inc(prlnn);
        write(clf,'* devLBL nodes  name/mdl--',prlnn);
    cmp:= cmp0;
    while cmp <> nil do
    with cmp^ do
    begin
        if (length(cl) > 1) and (cn = 1) then write(clf,cl)
	else write(clf,cl,cn);

        pin:= pin0;
        while pin <> nil do
        begin
            write(#9,pin^.nnm,'(',pin^.pxy.x,':',pin^.pxy.y,')');
            pin:= pin^.npp;
        end;
        write(#9,spice);
        cmp:= cmp^.ncp;
    end;
    write(clf,'.end');
end;
debug *)

procedure printcomponents;
var cmp : compp;
    pin : pinp;
begin

        inc(prlnn);
        write(clf,'* devLBL nodes  name/mdl--',prlnn);
    cmp:= cmp0;
    while cmp <> nil do
    with cmp^ do
    begin
        if (length(cl) > 1) and (cn = 1) then write(clf,cl)
	else write(clf,cl,cn);

        pin:= pin0;
        while pin <> nil do
        begin
            write(#9,pin^.nnm);
            pin:= pin^.npp;
        end;
        write(#9,spice);
        cmp:= cmp^.ncp;
    end;
    write(clf,'.end');
end;

procedure nogap; 			{ remove gaps in numeric lable sequence }

    function nnf(nns:string):string; 	{ Node Name Find -set to nns if found-}
    var cmp : compp;
	pin : pinp;
    begin
	nnf:='?';
	cmp:= cmp0;
	while cmp <> nil do
	with cmp^ do
	begin
    	    pin:= pin0;
    	    while (pin <> nil) and (pin^.nnm <> nns)  do pin:= pin^.npp;

	    if (pin <> nil) then 
	    begin
		nnf:=nns;
		cmp:=nil;
	    end
	    else cmp:= cmp^.ncp;
	
	end;
    end;

    function nnls(nns:string):string; 	{Next Numeric Lable String}
    var i,k : integer;
    begin
	val(nns,k,i);
	inc(k);
	str(k,nns);
	nnls:= nns
    end;

    function fnnl(nns:string):string; 	{Find Next Numeric Lable}
    var cmp : compp;
	pin : pinp;
	nnn : string;
	i,k,l : integer;
    begin
	val(nns,l,i);
    
	nnn:='';
	cmp:= cmp0;
	while cmp <> nil do
	with cmp^ do
	begin
    	    pin:= pin0;
	    repeat
		val(pin^.nnm,k,i);
		if (i = 0) then
		begin
		    if (nnn='') and (l < k)  then nnn:= pin^.nnm;

		    if nnn = pin^.nnm then 
		    begin
			pin^.nnm:= nns;
		    end;
		end;	
		pin:= pin^.npp;
	    until pin = nil;  	
    	    cmp:= cmp^.ncp;
	end;
	fnnl:= nnn;
	
    end;

var nns : string;    
begin
    nns:= '0';
    repeat

	while nnf(nns) = nns do 
	begin
	    nns:= nnls(nns);
	end;
//    if nns = '16' then printcomponents;	
    until fnnl(nns) = '';
end;

{------------------------------------}


function checklist: LongInt;
var ss : string[11];
begin
//    ss:= s1sc;
    ss:= sb1s;
    cll:= cll0;
    while (ss <> cll^.ls) and (cll^.n <> 0) do
    begin
        if cll^.lp = nil then
        begin
            new(cll^.lp);
            cll:= cll^.lp;
            cll^.lp:= nil;
            cll^.n:= 0;
        end
        else cll:= cll^.lp;
    end;

    with cll^ do
    begin
        inc(n); ls:= ss;
        checklist:= n;
    end
end;

procedure getcomp;
var	i,q	: LongInt;
        pin     : pinp;
begin
    if cmp0 = nil then
    begin 
	new(cll); cll0:= cll; cll^.n:= 0; cll^.lp:= nil; 
	new(cmp); cmp0:= cmp; cmp^.ncp:= nil; 
    end
    else  
    begin new(cmp^.ncp); cmp:= cmp^.ncp; cmp^.ncp:= nil; end;


    with cmp^ do
    begin
	cn:= checklist; cl:= cll^.ls; pin0:= nil; fln:= lnr;
	
	while s2c <> '-6' do
	begin
    	    q:= 1;

	    readln(f1,s); inc(lnr);
    	    if s2c = '4 ' then spice := gettext;
	    if s3c = '# p' then
	    begin
		i:= npin; { pinnum from s }
		if pin0 = nil then  
		begin new(pin); pin0:= pin; pin^.nn:= -1; pin^.npp:= nil end;

		pin:= pin0;
		while q < i do
		begin
	    	    if pin^.npp <> nil then pin:= pin^.npp
		    else
		    begin 
			new(pin^.npp); pin:= pin^.npp; 
			pin^.nn:= -1; pin^.npp:= nil 
		    end;
		    inc(q);
		end;

		with pin^ do
		begin
		    readln(f1,s); inc(lnr);
		    with pxy do readln(f1,x,y); inc(lnr);
		    nn:= i;
		end;
	    end;
	end;
    end;
end;

var llin : LongInt;   {labelled  line ?}

procedure getline;
var	q	: LongInt;
        c       : char;
        pv      : lnvp;
begin
    if lin0 = nil then  
	begin new(lin); lin^.pv0:= nil; lin0:= lin; lin^.nlp:= nil end
    else  
	begin new(lin^.nlp); lin:= lin^.nlp; lin^.pv0:= nil; lin^.nlp:= nil end;

    q:= nxy;		{ vertex count of line from s}
    with lin^ do
    begin
	lnn:= 0;
        c:= ' ';
	fln:= lnr;
        while q > 0 do
	begin
	    dec(q);
	    if pv0 = nil then  begin new(pv); pv0:= pv; pv^.nvp:= nil; end
	    else begin new(pv^.nvp); pv:= pv^.nvp; pv^.nvp:= nil; end;

	    with pv^.pxy do read(f1,x,y,c);
            if ((c = #10) or (eoln(f1))) then inc(lnr);
	end;
    end;
end;

function sq2p(a,b:pxyr) : double;	{sqare of line length}
begin sq2p:= sqr(a.x-b.x)+sqr(a.y-b.y); end;

function l2p(a,b:pxyr) : double;	{line length}
begin l2p:= sqrt(sqr(abs(a.x-b.x))+sqr(abs(a.y-b.y))); end;

function dif3p(a,b,c: pxyr): double;
var aa,bb,cc,k : double;
begin
    aa:= sq2p(a,b); 
    bb:= sq2p(b,c);
    cc:= sq2p(a,c);

    if (aa < bb) then k:= aa else k:= bb;
    
    if (k > sqmask) and (cc > sqmask) then 
    begin
	k:= abs((1+(aa - bb)/cc)/2);
	k:= abs(aa-cc*k*k);

	if (k < sqmask) then
	    if (aa > cc) or (bb > cc) then k:= sqmask+sqmask;
    end;
    k:= sqrt(k);
    dif3p:= k;
//writeln;
end;

var ndc		: LongInt;                              {node counter}

function dif2l(av,bv:linp):real;
var a,a1,a2,b,b1,b2 	: lnvp;
    v       		: real;
begin
    a1:= av^.pv0; a2:= a1;
    while a2^.nvp <> nil do a2:= a2^.nvp;                 { first & last vertex}
    b1:= bv^.pv0; b2:= b1;
    while b2^.nvp <> nil do b2:= b2^.nvp;                 { first & last vertex}
    
  
    v:= mask+1;
    b:= b1;
    while (b^.nvp <> nil) and (v >mask) do
    begin
        v:= dif3p(b^.pxy, a1^.pxy, b^.nvp^.pxy);
        if v >mask then
            v:= dif3p(b^.pxy, a2^.pxy, b^.nvp^.pxy);
        b:= b^.nvp;
    end;
    a:= a1;

    while (a^.nvp <> nil) and (v >mask) do
    begin
        v:= dif3p(a^.pxy, b1^.pxy, a^.nvp^.pxy);
        if v >mask then
            v:= dif3p(a^.pxy, b2^.pxy, a^.nvp^.pxy);
        a:= a^.nvp;
    end;
    dif2l:= v;
//    write(clf,'<',v:0:0)
end;

procedure findlnks(lp:linp);
var lp1 :linp;
begin
    if (lp <> nil) and (lp^.lnn = 0)  then
    begin
        lp1:= lin0;
        with lp^ do
        begin
            lnn:= ndc;
	    
            while lp1 <> nil do
            begin
                while (lp1 <> nil) and (lp1^.lnn > 0) do lp1:= lp1^.nlp;

                if lp1 <> nil then
                begin

                    if dif2l(lp1,lp) < mask then
                    begin
//writeln('>',fln,'_',lp1^.fln,'!');
                        lp1^.nnm:=nnm;
                        findlnks(lp1);
                    end;
//else		    
//writeln('>',fln,'_',lp1^.fln);

                    lp1:= lp1^.nlp
                end;
            end;
        end;
    end;
end;

function findlxy(oo:pxyr; lp1: linp):pointer;
var v	: real;
    pv  : lnvp;
begin
    v:= mask+1;
    while (lp1 <> nil) and (v >mask) do
    begin
        with lp1^ do
        begin
            pv:= pv0;
            if pv^.nvp = nil then v:= l2p(pv^.pxy,oo);
							    {for shortlines}
            while (pv^.nvp <> nil) and (v >mask) do         {for multinodes}
            with pv^.nvp^ do
            begin
                v:= dif3p(pxy,oo,pv^.pxy);
        	pv:=pv^.nvp;
            end;
            if v > mask then  lp1:= lp1^.nlp
        end;
    end;
    findlxy:= lp1;
end;

procedure findpin(p: pointer; oo: pxyr);
var v	: real;
    cp  : compp;
begin
    v:= mask+1;
    cp:= cmp0;
    while (cp <> nil) and (v >mask) do
    begin
        with cp^ do
        begin
            xpp:= pin0;
            while (xpp <> nil) and (v >mask) do
            begin
                if (xpp <> p) then
                with xpp^ do
                begin
                    v:= l2p(pxy,oo);

                    if (v >mask) then xpp:= xpp^.npp
                    else if nnm = '' then
                        begin xpp:= xpp^.npp; v:= mask+1 end;
                end
                else  xpp:= xpp^.npp;
            end;
        end;
        cp:= cp^.ncp;
    end;
end;

procedure fixnodes;
var lp,lp1      :linp;
    pin         :pinp;
begin
    ndc:= 1;

    lp:= lin0;
    prlnn:=0;

    repeat
        while (lp <> nil) and (lp^.pv0^.nvp <> nil) do lp:= lp^.nlp;
        if lp <> nil then
        begin
            findlnks(lp);
            lp:= lp^.nlp;
            while (lp <> nil) and (lp^.lnn <> 0) do lp:= lp^.nlp;
            if lp <> nil then with lp^ do
            begin
                if lnn = 0 then begin inc(ndc); end;
            end;
        end;
    until lp = nil;
    inc(ndc);
    lp:= lin0;

    repeat

        while (lp <> nil) and (lp^.pv0^.nvp = nil) do lp:= lp^.nlp;
        if lp <> nil then
        begin
            findlnks(lp);
            lp:= lp^.nlp;
            while (lp <> nil) and (lp^.lnn <> 0) do lp:= lp^.nlp;
            if lp <> nil then with lp^ do
            begin
                if lnn = 0 then begin inc(ndc); end;
            end;
        end;

    until lp = nil;

    cmp:= cmp0;
    while cmp <> nil do
    with cmp^ do
    begin
        pin:= pin0;
        while pin <> nil do
        with pin^ do
        begin
            if nnm = '' then
            begin
//printlines;
//printcomponents;
//printcompinfo;
                lp1:= lin0; lp1:= findlxy(pxy,lp1);

                if lp1 <> nil then
                begin
                    if lp1^.nnm <> '' then nnm:= lp1^.nnm
                    else str(lp1^.lnn,nnm);
                end
                else
                repeat
                    findpin(pin,pxy);

                    if (xpp = nil) then
                    begin
                       inc(ndc); str(ndc,nnm);
                    end
                    else
                        if (xpp^.nnm <> '') then nnm:= xpp^.nnm;
                until nnm <> '';
            end;
//writeln(pin^.nnm);
//readln;
            pin:= pin^.npp
        end;
        cmp:= cmp^.ncp;
    end;
end;



{--------------------------------------------}

begin
    llin:= 0;
    lnr:= 0;
    assign(f1, paramstr(1)); reset(f1);

    write('circuit figsim');

    repeat
    	readln(f1,s); inc(lnr);
	case pos(s2c,' # 2 4 6 -6') shr 1 of
	    1	:
            case pos(s3c,'   # % # @ # ?') shr 2 of
                1   : t:= copy(s,4,length(s)-3);
                2   : begin t:= s; getcomp; end;
                3   : repeat readln(f1,s); inc(lnr); until s2c = '-6';
	    else
                 write(clf,copy(s,3,length(s)-2));
	    end;
	    2	: if s3c = '2 1' then getline;
	    3	: t:= gettext;
	    4	: llin:= 1;
	    5	: if llin = 1 then begin lin^.nnm:=t; llin:=0; t:= '' end;
	end;
    until eof(f1);
//printlines;
//printcompinfo;
//writeln(#10,'-------------------');    
   fixnodes;
//    printlines;
//    printcomponents;
    nogap;
    printcomponents;
end.
