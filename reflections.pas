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
unit reflections;
interface
uses Math, Ap, Sysutils;

procedure GenerateReflection(var X : TReal1DArray;
     N : Integer;
     var Tau : Double);
procedure ApplyReflectionFromTheLeft(var C : TReal2DArray;
     Tau : Double;
     const V : TReal1DArray;
     M1 : Integer;
     M2 : Integer;
     N1 : Integer;
     N2 : Integer;
     var WORK : TReal1DArray);
procedure ApplyReflectionFromTheRight(var C : TReal2DArray;
     Tau : Double;
     const V : TReal1DArray;
     M1 : Integer;
     M2 : Integer;
     N1 : Integer;
     N2 : Integer;
     var WORK : TReal1DArray);

implementation

(*************************************************************************
Generation of an elementary reflection transformation

The subroutine generates elementary reflection H of order N, so that, for
a given X, the following equality holds true:

    ( X(1) )   ( Beta )
H * (  ..  ) = (  0   )
    ( X(n) )   (  0   )

where
              ( V(1) )
H = 1 - Tau * (  ..  ) * ( V(1), ..., V(n) )
              ( V(n) )

where the first component of vector V equals 1.

Input parameters:
    X   -   vector. Array whose index ranges within [1..N].
    N   -   reflection order.

Output parameters:
    X   -   components from 2 to N are replaced with vector V.
            The first component is replaced with parameter Beta.
    Tau -   scalar value Tau. If X is a null vector, Tau equals 0,
            otherwise 1 <= Tau <= 2.

This subroutine is the modification of the DLARFG subroutines from
the LAPACK library. It has a similar functionality except for the
fact that it doesn’t handle errors when the intermediate results
cause an overflow.


MODIFICATIONS:
    24.12.2005 sign(Alpha) was replaced with an analogous to the Fortran SIGN code.

  -- LAPACK auxiliary routine (version 3.0) --
     Univ. of Tennessee, Univ. of California Berkeley, NAG Ltd.,
     Courant Institute, Argonne National Lab, and Rice University
     September 30, 1994
*************************************************************************)
procedure GenerateReflection(var X : TReal1DArray;
     N : Integer;
     var Tau : Double);
var
    J : Integer;
    Alpha : Double;
    XNORM : Double;
    V : Double;
    Beta : Double;
    MX : Double;
begin
    
    //
    // Executable Statements ..
    //
    if N<=1 then
    begin
        Tau := 0;
        Exit;
    end;
    
    //
    // XNORM = DNRM2( N-1, X, INCX )
    //
    Alpha := X[1];
    MX := 0;
    J:=2;
    while J<=N do
    begin
        MX := Max(AbsReal(X[J]), MX);
        Inc(J);
    end;
    XNORM := 0;
    if MX<>0 then
    begin
        J:=2;
        while J<=N do
        begin
            XNORM := XNORM+Sqr(X[J]/MX);
            Inc(J);
        end;
        XNORM := Sqrt(XNORM)*MX;
    end;
    if XNORM=0 then
    begin
        
        //
        // H  =  I
        //
        TAU := 0;
        Exit;
    end;
    
    //
    // general case
    //
    MX := Max(AbsReal(Alpha), AbsReal(XNORM));
    Beta := -MX*Sqrt(Sqr(Alpha/MX)+Sqr(XNORM/MX));
    if Alpha<0 then
    begin
        Beta := -Beta;
    end;
    TAU := (BETA-ALPHA)/BETA;
    V := 1/(Alpha-Beta);
    APVMul(@X[0], 2, N, V);
    X[1] := Beta;
end;


(*************************************************************************
Application of an elementary reflection to a rectangular matrix of size MxN

The algorithm pre-multiplies the matrix by an elementary reflection transformation
which is given by column V and scalar Tau (see the description of the
GenerateReflection procedure). Not the whole matrix but only a part of it
is transformed (rows from M1 to M2, columns from N1 to N2). Only the elements
of this submatrix are changed.

Input parameters:
    C       -   matrix to be transformed.
    Tau     -   scalar defining the transformation.
    V       -   column defining the transformation.
                Array whose index ranges within [1..M2-M1+1].
    M1, M2  -   range of rows to be transformed.
    N1, N2  -   range of columns to be transformed.
    WORK    -   working array whose indexes goes from N1 to N2.

Output parameters:
    C       -   the result of multiplying the input matrix C by the
                transformation matrix which is given by Tau and V.
                If N1>N2 or M1>M2, C is not modified.

  -- LAPACK auxiliary routine (version 3.0) --
     Univ. of Tennessee, Univ. of California Berkeley, NAG Ltd.,
     Courant Institute, Argonne National Lab, and Rice University
     September 30, 1994
*************************************************************************)
procedure ApplyReflectionFromTheLeft(var C : TReal2DArray;
     Tau : Double;
     const V : TReal1DArray;
     M1 : Integer;
     M2 : Integer;
     N1 : Integer;
     N2 : Integer;
     var WORK : TReal1DArray);
var
    T : Double;
    I : Integer;
    VM : Integer;
begin
    if (Tau=0) or (N1>N2) or (M1>M2) then
    begin
        Exit;
    end;
    
    //
    // w := C' * v
    //
    VM := M2-M1+1;
    I:=N1;
    while I<=N2 do
    begin
        WORK[I] := 0;
        Inc(I);
    end;
    I:=M1;
    while I<=M2 do
    begin
        T := V[I+1-M1];
        APVAdd(@WORK[0], N1, N2, @C[I][0], N1, N2, T);
        Inc(I);
    end;
    
    //
    // C := C - tau * v * w'
    //
    I:=M1;
    while I<=M2 do
    begin
        T := V[I-M1+1]*TAU;
        APVSub(@C[I][0], N1, N2, @WORK[0], N1, N2, T);
        Inc(I);
    end;
end;


(*************************************************************************
Application of an elementary reflection to a rectangular matrix of size MxN

The algorithm post-multiplies the matrix by an elementary reflection transformation
which is given by column V and scalar Tau (see the description of the
GenerateReflection procedure). Not the whole matrix but only a part of it
is transformed (rows from M1 to M2, columns from N1 to N2). Only the
elements of this submatrix are changed.

Input parameters:
    C       -   matrix to be transformed.
    Tau     -   scalar defining the transformation.
    V       -   column defining the transformation.
                Array whose index ranges within [1..N2-N1+1].
    M1, M2  -   range of rows to be transformed.
    N1, N2  -   range of columns to be transformed.
    WORK    -   working array whose indexes goes from M1 to M2.

Output parameters:
    C       -   the result of multiplying the input matrix C by the
                transformation matrix which is given by Tau and V.
                If N1>N2 or M1>M2, C is not modified.

  -- LAPACK auxiliary routine (version 3.0) --
     Univ. of Tennessee, Univ. of California Berkeley, NAG Ltd.,
     Courant Institute, Argonne National Lab, and Rice University
     September 30, 1994
*************************************************************************)
procedure ApplyReflectionFromTheRight(var C : TReal2DArray;
     Tau : Double;
     const V : TReal1DArray;
     M1 : Integer;
     M2 : Integer;
     N1 : Integer;
     N2 : Integer;
     var WORK : TReal1DArray);
var
    T : Double;
    I : Integer;
    VM : Integer;
begin
    if (Tau=0) or (N1>N2) or (M1>M2) then
    begin
        Exit;
    end;
    
    //
    // w := C * v
    //
    VM := N2-N1+1;
    I:=M1;
    while I<=M2 do
    begin
        T := APVDotProduct(@C[I][0], N1, N2, @V[0], 1, VM);
        WORK[I] := T;
        Inc(I);
    end;
    
    //
    // C := C - w * v'
    //
    I:=M1;
    while I<=M2 do
    begin
        T := WORK[I]*TAU;
        APVSub(@C[I][0], N1, N2, @V[0], 1, VM, T);
        Inc(I);
    end;
end;


end.