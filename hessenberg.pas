{$MODE DELPHI}

(*************************************************************************
Copyright (c) 1992-2007 The University of Tennessee. All rights reserved.

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
unit hessenberg;
interface
uses Math, Ap, Sysutils, reflections;

procedure RMatrixHessenberg(var A : TReal2DArray;
     N : Integer;
     var Tau : TReal1DArray);
procedure RMatrixHessenbergUnpackQ(const A : TReal2DArray;
     N : Integer;
     const Tau : TReal1DArray;
     var Q : TReal2DArray);
procedure RMatrixHessenbergUnpackH(const A : TReal2DArray;
     N : Integer;
     var H : TReal2DArray);
procedure ToUpperHessenberg(var A : TReal2DArray;
     N : Integer;
     var Tau : TReal1DArray);
procedure UnpackQFromUpperHessenberg(const A : TReal2DArray;
     N : Integer;
     const Tau : TReal1DArray;
     var Q : TReal2DArray);
procedure UnpackHFromUpperHessenberg(const A : TReal2DArray;
     N : Integer;
     const Tau : TReal1DArray;
     var H : TReal2DArray);

implementation

(*************************************************************************
Reduction of a square matrix to  upper Hessenberg form: Q'*A*Q = H,
where Q is an orthogonal matrix, H - Hessenberg matrix.

Input parameters:
    A       -   matrix A with elements [0..N-1, 0..N-1]
    N       -   size of matrix A.

Output parameters:
    A       -   matrices Q and P in  compact form (see below).
    Tau     -   array of scalar factors which are used to form matrix Q.
                Array whose index ranges within [0..N-2]

Matrix H is located on the main diagonal, on the lower secondary  diagonal
and above the main diagonal of matrix A. The elements which are used to
form matrix Q are situated in array Tau and below the lower secondary
diagonal of matrix A as follows:

Matrix Q is represented as a product of elementary reflections

Q = H(0)*H(2)*...*H(n-2),

where each H(i) is given by

H(i) = 1 - tau * v * (v^T)

where tau is a scalar stored in Tau[I]; v - is a real vector,
so that v(0:i) = 0, v(i+1) = 1, v(i+2:n-1) stored in A(i+2:n-1,i).

  -- LAPACK routine (version 3.0) --
     Univ. of Tennessee, Univ. of California Berkeley, NAG Ltd.,
     Courant Institute, Argonne National Lab, and Rice University
     October 31, 1992
*************************************************************************)
procedure RMatrixHessenberg(var A : TReal2DArray;
     N : Integer;
     var Tau : TReal1DArray);
var
    I : Integer;
    AII : Double;
    V : Double;
    T : TReal1DArray;
    WORK : TReal1DArray;
    i_ : Integer;
    i1_ : Integer;
begin
    Assert(N>=0, 'RMatrixHessenberg: incorrect N!');
    
    //
    // Quick return if possible
    //
    if N<=1 then
    begin
        Exit;
    end;
    SetLength(Tau, N-2+1);
    SetLength(T, N+1);
    SetLength(WORK, N-1+1);
    I:=0;
    while I<=N-2 do
    begin
        
        //
        // Compute elementary reflector H(i) to annihilate A(i+2:ihi,i)
        //
        i1_ := (I+1) - (1);
        for i_ := 1 to N-I-1 do
        begin
            T[i_] := A[i_+i1_,I];
        end;
        GenerateReflection(T, N-I-1, V);
        i1_ := (1) - (I+1);
        for i_ := I+1 to N-1 do
        begin
            A[i_,I] := T[i_+i1_];
        end;
        Tau[I] := V;
        T[1] := 1;
        
        //
        // Apply H(i) to A(1:ihi,i+1:ihi) from the right
        //
        ApplyReflectionFromTheRight(A, V, T, 0, N-1, I+1, N-1, WORK);
        
        //
        // Apply H(i) to A(i+1:ihi,i+1:n) from the left
        //
        ApplyReflectionFromTheLeft(A, V, T, I+1, N-1, I+1, N-1, WORK);
        Inc(I);
    end;
end;


(*************************************************************************
Unpacking matrix Q which reduces matrix A to upper Hessenberg form

Input parameters:
    A   -   output of RMatrixHessenberg subroutine.
    N   -   size of matrix A.
    Tau -   scalar factors which are used to form Q.
            Output of RMatrixHessenberg subroutine.

Output parameters:
    Q   -   matrix Q.
            Array whose indexes range within [0..N-1, 0..N-1].

  -- ALGLIB --
     Copyright 2005 by Bochkanov Sergey
*************************************************************************)
procedure RMatrixHessenbergUnpackQ(const A : TReal2DArray;
     N : Integer;
     const Tau : TReal1DArray;
     var Q : TReal2DArray);
var
    I : Integer;
    J : Integer;
    V : TReal1DArray;
    WORK : TReal1DArray;
    i_ : Integer;
    i1_ : Integer;
begin
    if N=0 then
    begin
        Exit;
    end;
    
    //
    // init
    //
    SetLength(Q, N-1+1, N-1+1);
    SetLength(V, N-1+1);
    SetLength(WORK, N-1+1);
    I:=0;
    while I<=N-1 do
    begin
        J:=0;
        while J<=N-1 do
        begin
            if I=J then
            begin
                Q[I,J] := 1;
            end
            else
            begin
                Q[I,J] := 0;
            end;
            Inc(J);
        end;
        Inc(I);
    end;
    
    //
    // unpack Q
    //
    I:=0;
    while I<=N-2 do
    begin
        
        //
        // Apply H(i)
        //
        i1_ := (I+1) - (1);
        for i_ := 1 to N-I-1 do
        begin
            V[i_] := A[i_+i1_,I];
        end;
        V[1] := 1;
        ApplyReflectionFromTheRight(Q, Tau[I], V, 0, N-1, I+1, N-1, WORK);
        Inc(I);
    end;
end;


(*************************************************************************
Unpacking matrix H (the result of matrix A reduction to upper Hessenberg form)

Input parameters:
    A   -   output of RMatrixHessenberg subroutine.
    N   -   size of matrix A.

Output parameters:
    H   -   matrix H. Array whose indexes range within [0..N-1, 0..N-1].

  -- ALGLIB --
     Copyright 2005 by Bochkanov Sergey
*************************************************************************)
procedure RMatrixHessenbergUnpackH(const A : TReal2DArray;
     N : Integer;
     var H : TReal2DArray);
var
    I : Integer;
    J : Integer;
    V : TReal1DArray;
    WORK : TReal1DArray;
    IP1 : Integer;
    NMI : Integer;
begin
    if N=0 then
    begin
        Exit;
    end;
    SetLength(H, N-1+1, N-1+1);
    I:=0;
    while I<=N-1 do
    begin
        J:=0;
        while J<=I-2 do
        begin
            H[I,J] := 0;
            Inc(J);
        end;
        J := Max(0, I-1);
        APVMove(@H[I][0], J, N-1, @A[I][0], J, N-1);
        Inc(I);
    end;
end;


(*************************************************************************
Obsolete 1-based subroutine.
See RMatrixHessenberg for 0-based replacement.
*************************************************************************)
procedure ToUpperHessenberg(var A : TReal2DArray;
     N : Integer;
     var Tau : TReal1DArray);
var
    I : Integer;
    IP1 : Integer;
    NMI : Integer;
    AII : Double;
    V : Double;
    T : TReal1DArray;
    WORK : TReal1DArray;
    i_ : Integer;
    i1_ : Integer;
begin
    Assert(N>=0, 'ToUpperHessenberg: incorrect N!');
    
    //
    // Quick return if possible
    //
    if N<=1 then
    begin
        Exit;
    end;
    SetLength(Tau, N-1+1);
    SetLength(T, N+1);
    SetLength(WORK, N+1);
    I:=1;
    while I<=N-1 do
    begin
        
        //
        // Compute elementary reflector H(i) to annihilate A(i+2:ihi,i)
        //
        IP1 := I+1;
        NMI := N-I;
        i1_ := (IP1) - (1);
        for i_ := 1 to NMI do
        begin
            T[i_] := A[i_+i1_,I];
        end;
        GenerateReflection(T, NMI, V);
        i1_ := (1) - (IP1);
        for i_ := IP1 to N do
        begin
            A[i_,I] := T[i_+i1_];
        end;
        Tau[I] := V;
        T[1] := 1;
        
        //
        // Apply H(i) to A(1:ihi,i+1:ihi) from the right
        //
        ApplyReflectionFromTheRight(A, V, T, 1, N, I+1, N, WORK);
        
        //
        // Apply H(i) to A(i+1:ihi,i+1:n) from the left
        //
        ApplyReflectionFromTheLeft(A, V, T, I+1, N, I+1, N, WORK);
        Inc(I);
    end;
end;


(*************************************************************************
Obsolete 1-based subroutine.
See RMatrixHessenbergUnpackQ for 0-based replacement.
*************************************************************************)
procedure UnpackQFromUpperHessenberg(const A : TReal2DArray;
     N : Integer;
     const Tau : TReal1DArray;
     var Q : TReal2DArray);
var
    I : Integer;
    J : Integer;
    V : TReal1DArray;
    WORK : TReal1DArray;
    IP1 : Integer;
    NMI : Integer;
    i_ : Integer;
    i1_ : Integer;
begin
    if N=0 then
    begin
        Exit;
    end;
    
    //
    // init
    //
    SetLength(Q, N+1, N+1);
    SetLength(V, N+1);
    SetLength(WORK, N+1);
    I:=1;
    while I<=N do
    begin
        J:=1;
        while J<=N do
        begin
            if I=J then
            begin
                Q[I,J] := 1;
            end
            else
            begin
                Q[I,J] := 0;
            end;
            Inc(J);
        end;
        Inc(I);
    end;
    
    //
    // unpack Q
    //
    I:=1;
    while I<=N-1 do
    begin
        
        //
        // Apply H(i)
        //
        IP1 := I+1;
        NMI := N-I;
        i1_ := (IP1) - (1);
        for i_ := 1 to NMI do
        begin
            V[i_] := A[i_+i1_,I];
        end;
        V[1] := 1;
        ApplyReflectionFromTheRight(Q, Tau[I], V, 1, N, I+1, N, WORK);
        Inc(I);
    end;
end;


(*************************************************************************
Obsolete 1-based subroutine.
See RMatrixHessenbergUnpackH for 0-based replacement.
*************************************************************************)
procedure UnpackHFromUpperHessenberg(const A : TReal2DArray;
     N : Integer;
     const Tau : TReal1DArray;
     var H : TReal2DArray);
var
    I : Integer;
    J : Integer;
    V : TReal1DArray;
    WORK : TReal1DArray;
    IP1 : Integer;
    NMI : Integer;
begin
    if N=0 then
    begin
        Exit;
    end;
    SetLength(H, N+1, N+1);
    I:=1;
    while I<=N do
    begin
        J:=1;
        while J<=I-2 do
        begin
            H[I,J] := 0;
            Inc(J);
        end;
        J := Max(1, I-1);
        APVMove(@H[I][0], J, N, @A[I][0], J, N);
        Inc(I);
    end;
end;


end.