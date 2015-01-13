{$MODE DELPHI}

(*************************************************************************
Copyright (c) 1992-2007 The University of Tennessee.  All rights reserved.

Contributors:
    * Sergey Bochkanov (ALGLIB project). Translation from FORTRAN to
      pseudocode.

See subroutines comments for additional copyrights.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

- Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer listed
  in this license in the documentation and/or other materials
  provided with the distribution.

- Neither the name of the copyright holders nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*************************************************************************)
unit rotations;
interface
uses Math, Ap, Sysutils;

procedure ApplyRotationsFromTheLeft(IsForward : Boolean;
     M1 : Integer;
     M2 : Integer;
     N1 : Integer;
     N2 : Integer;
     const C : TReal1DArray;
     const S : TReal1DArray;
     var A : TReal2DArray;
     var WORK : TReal1DArray);
procedure ApplyRotationsFromTheRight(IsForward : Boolean;
     M1 : Integer;
     M2 : Integer;
     N1 : Integer;
     N2 : Integer;
     const C : TReal1DArray;
     const S : TReal1DArray;
     var A : TReal2DArray;
     var WORK : TReal1DArray);
procedure GenerateRotation(F : Double;
     G : Double;
     var CS : Double;
     var SN : Double;
     var R : Double);

implementation

(*************************************************************************
Application of a sequence of  elementary rotations to a matrix

The algorithm pre-multiplies the matrix by a sequence of rotation
transformations which is given by arrays C and S. Depending on the value
of the IsForward parameter either 1 and 2, 3 and 4 and so on (if IsForward=true)
rows are rotated, or the rows N and N-1, N-2 and N-3 and so on, are rotated.

Not the whole matrix but only a part of it is transformed (rows from M1 to
M2, columns from N1 to N2). Only the elements of this submatrix are changed.

Input parameters:
    IsForward   -   the sequence of the rotation application.
    M1,M2       -   the range of rows to be transformed.
    N1, N2      -   the range of columns to be transformed.
    C,S         -   transformation coefficients.
                    Array whose index ranges within [1..M2-M1].
    A           -   processed matrix.
    WORK        -   working array whose index ranges within [N1..N2].

Output parameters:
    A           -   transformed matrix.

Utility subroutine.
*************************************************************************)
procedure ApplyRotationsFromTheLeft(IsForward : Boolean;
     M1 : Integer;
     M2 : Integer;
     N1 : Integer;
     N2 : Integer;
     const C : TReal1DArray;
     const S : TReal1DArray;
     var A : TReal2DArray;
     var WORK : TReal1DArray);
var
    J : Integer;
    JP1 : Integer;
    CTEMP : Double;
    STEMP : Double;
    TEMP : Double;
begin
    if (M1>M2) or (N1>N2) then
    begin
        Exit;
    end;
    
    //
    // Form  P * A
    //
    if IsForward then
    begin
        if N1<>N2 then
        begin
            
            //
            // Common case: N1<>N2
            //
            J:=M1;
            while J<=M2-1 do
            begin
                CTEMP := C[J-M1+1];
                STEMP := S[J-M1+1];
                if (CTEMP<>1) or (STEMP<>0) then
                begin
                    JP1 := J+1;
                    APVMove(@WORK[0], N1, N2, @A[JP1][0], N1, N2, CTEMP);
                    APVSub(@WORK[0], N1, N2, @A[J][0], N1, N2, STEMP);
                    APVMul(@A[J][0], N1, N2, CTEMP);
                    APVAdd(@A[J][0], N1, N2, @A[JP1][0], N1, N2, STEMP);
                    APVMove(@A[JP1][0], N1, N2, @WORK[0], N1, N2);
                end;
                Inc(J);
            end;
        end
        else
        begin
            
            //
            // Special case: N1=N2
            //
            J:=M1;
            while J<=M2-1 do
            begin
                CTEMP := C[J-M1+1];
                STEMP := S[J-M1+1];
                if (CTEMP<>1) or (STEMP<>0) then
                begin
                    TEMP := A[J+1,N1];
                    A[J+1,N1] := CTEMP*TEMP-STEMP*A[J,N1];
                    A[J,N1] := STEMP*TEMP+CTEMP*A[J,N1];
                end;
                Inc(J);
            end;
        end;
    end
    else
    begin
        if N1<>N2 then
        begin
            
            //
            // Common case: N1<>N2
            //
            J:=M2-1;
            while J>=M1 do
            begin
                CTEMP := C[J-M1+1];
                STEMP := S[J-M1+1];
                if (CTEMP<>1) or (STEMP<>0) then
                begin
                    JP1 := J+1;
                    APVMove(@WORK[0], N1, N2, @A[JP1][0], N1, N2, CTEMP);
                    APVSub(@WORK[0], N1, N2, @A[J][0], N1, N2, STEMP);
                    APVMul(@A[J][0], N1, N2, CTEMP);
                    APVAdd(@A[J][0], N1, N2, @A[JP1][0], N1, N2, STEMP);
                    APVMove(@A[JP1][0], N1, N2, @WORK[0], N1, N2);
                end;
                Dec(J);
            end;
        end
        else
        begin
            
            //
            // Special case: N1=N2
            //
            J:=M2-1;
            while J>=M1 do
            begin
                CTEMP := C[J-M1+1];
                STEMP := S[J-M1+1];
                if (CTEMP<>1) or (STEMP<>0) then
                begin
                    TEMP := A[J+1,N1];
                    A[J+1,N1] := CTEMP*TEMP-STEMP*A[J,N1];
                    A[J,N1] := STEMP*TEMP+CTEMP*A[J,N1];
                end;
                Dec(J);
            end;
        end;
    end;
end;


(*************************************************************************
Application of a sequence of  elementary rotations to a matrix

The algorithm post-multiplies the matrix by a sequence of rotation
transformations which is given by arrays C and S. Depending on the value
of the IsForward parameter either 1 and 2, 3 and 4 and so on (if IsForward=true)
rows are rotated, or the rows N and N-1, N-2 and N-3 and so on are rotated.

Not the whole matrix but only a part of it is transformed (rows from M1
to M2, columns from N1 to N2). Only the elements of this submatrix are changed.

Input parameters:
    IsForward   -   the sequence of the rotation application.
    M1,M2       -   the range of rows to be transformed.
    N1, N2      -   the range of columns to be transformed.
    C,S         -   transformation coefficients.
                    Array whose index ranges within [1..N2-N1].
    A           -   processed matrix.
    WORK        -   working array whose index ranges within [M1..M2].

Output parameters:
    A           -   transformed matrix.

Utility subroutine.
*************************************************************************)
procedure ApplyRotationsFromTheRight(IsForward : Boolean;
     M1 : Integer;
     M2 : Integer;
     N1 : Integer;
     N2 : Integer;
     const C : TReal1DArray;
     const S : TReal1DArray;
     var A : TReal2DArray;
     var WORK : TReal1DArray);
var
    J : Integer;
    JP1 : Integer;
    CTEMP : Double;
    STEMP : Double;
    TEMP : Double;
    i_ : Integer;
begin
    
    //
    // Form A * P'
    //
    if IsForward then
    begin
        if M1<>M2 then
        begin
            
            //
            // Common case: M1<>M2
            //
            J:=N1;
            while J<=N2-1 do
            begin
                CTEMP := C[J-N1+1];
                STEMP := S[J-N1+1];
                if (CTEMP<>1) or (STEMP<>0) then
                begin
                    JP1 := J+1;
                    for i_ := M1 to M2 do
                    begin
                        WORK[i_] := CTEMP*A[i_,JP1];
                    end;
                    for i_ := M1 to M2 do
                    begin
                        WORK[i_] := WORK[i_] - STEMP*A[i_,J];
                    end;
                    for i_ := M1 to M2 do
                    begin
                        A[i_,J] := CTEMP*A[i_,J];
                    end;
                    for i_ := M1 to M2 do
                    begin
                        A[i_,J] := A[i_,J] + STEMP*A[i_,JP1];
                    end;
                    for i_ := M1 to M2 do
                    begin
                        A[i_,JP1] := WORK[i_];
                    end;
                end;
                Inc(J);
            end;
        end
        else
        begin
            
            //
            // Special case: M1=M2
            //
            J:=N1;
            while J<=N2-1 do
            begin
                CTEMP := C[J-N1+1];
                STEMP := S[J-N1+1];
                if (CTEMP<>1) or (STEMP<>0) then
                begin
                    TEMP := A[M1,J+1];
                    A[M1,J+1] := CTEMP*TEMP-STEMP*A[M1,J];
                    A[M1,J] := STEMP*TEMP+CTEMP*A[M1,J];
                end;
                Inc(J);
            end;
        end;
    end
    else
    begin
        if M1<>M2 then
        begin
            
            //
            // Common case: M1<>M2
            //
            J:=N2-1;
            while J>=N1 do
            begin
                CTEMP := C[J-N1+1];
                STEMP := S[J-N1+1];
                if (CTEMP<>1) or (STEMP<>0) then
                begin
                    JP1 := J+1;
                    for i_ := M1 to M2 do
                    begin
                        WORK[i_] := CTEMP*A[i_,JP1];
                    end;
                    for i_ := M1 to M2 do
                    begin
                        WORK[i_] := WORK[i_] - STEMP*A[i_,J];
                    end;
                    for i_ := M1 to M2 do
                    begin
                        A[i_,J] := CTEMP*A[i_,J];
                    end;
                    for i_ := M1 to M2 do
                    begin
                        A[i_,J] := A[i_,J] + STEMP*A[i_,JP1];
                    end;
                    for i_ := M1 to M2 do
                    begin
                        A[i_,JP1] := WORK[i_];
                    end;
                end;
                Dec(J);
            end;
        end
        else
        begin
            
            //
            // Special case: M1=M2
            //
            J:=N2-1;
            while J>=N1 do
            begin
                CTEMP := C[J-N1+1];
                STEMP := S[J-N1+1];
                if (CTEMP<>1) or (STEMP<>0) then
                begin
                    TEMP := A[M1,J+1];
                    A[M1,J+1] := CTEMP*TEMP-STEMP*A[M1,J];
                    A[M1,J] := STEMP*TEMP+CTEMP*A[M1,J];
                end;
                Dec(J);
            end;
        end;
    end;
end;


(*************************************************************************
The subroutine generates the elementary rotation, so that:

[  CS  SN  ]  .  [ F ]  =  [ R ]
[ -SN  CS  ]     [ G ]     [ 0 ]

CS**2 + SN**2 = 1
*************************************************************************)
procedure GenerateRotation(F : Double;
     G : Double;
     var CS : Double;
     var SN : Double;
     var R : Double);
var
    F1 : Double;
    G1 : Double;
begin
    if G=0 then
    begin
        CS := 1;
        SN := 0;
        R := F;
    end
    else
    begin
        if F=0 then
        begin
            CS := 0;
            SN := 1;
            R := G;
        end
        else
        begin
            F1 := F;
            G1 := G;
            R := SQRT(Sqr(F1)+Sqr(G1));
            CS := F1/R;
            SN := G1/R;
            if (ABSReal(F)>ABSReal(G)) and (CS<0) then
            begin
                CS := -CS;
                SN := -SN;
                R := -R;
            end;
        end;
    end;
end;


end.