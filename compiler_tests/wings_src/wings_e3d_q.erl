%%
%%  e3d_q.erl --
%%
%%     Operations on unit quaternions.
%%
%%  Copyright (c) 2003 Dan Gudmundsson, Bjorn Gustavsson
%%
%%  See the file "license.terms" for information on usage and redistribution
%%  of this file, and for a DISCLAIMER OF ALL WARRANTIES.
%%
%%     $Id: wings_e3d_q.erl,v 1.1 2004/02/18 17:11:13 kostis Exp $
%%

%% Quaternions are represented as a {{Qx,Qy,Qz},Qw}
%% to differ them from Vectors.
%% The following is implemented from
%% "The Matrix and Quaternions FAQ".

-module(wings_e3d_q).

-export([identity/0,inverse/1,norm/1,mul/1,mul/2,
	 add/2, scale/2,
	 magnitude/1, conjugate/1,
	 to_rotation_matrix/1, from_rotation_matrix/1,
	 from_angle_axis/2, to_angle_axis/1,
	 vec_rotate/2]).

-compile(inline).

%% Multiplicative identity
identity() ->
    {{0.0,0.0,0.0},1.0}.

magnitude({{Qx,Qy,Qz},Qw})
  when is_float(Qx),is_float(Qy),is_float(Qz),is_float(Qw) ->
    math:sqrt(Qx*Qx+Qy*Qy+Qz*Qz+Qw*Qw).

conjugate({{Qx,Qy,Qz},Qw})
  when is_float(Qx), is_float(Qy), is_float(Qz), is_float(Qw) ->
    {{-Qx,-Qy,-Qz},Qw}.

inverse(Q) ->
    conjugate(Q).

norm(Q = {{Qx,Qy,Qz},Qw})
  when is_float(Qx),is_float(Qy),is_float(Qz),is_float(Qw) ->
    M = magnitude(Q),
    case catch {{Qx/M,Qy/M,Qz/M},Qw/M} of
	{'EXIT', _} -> {{0.0,0.0,0.0},0.0};
	R -> R
    end.

add({{X1,Y1,Z1},W1}, {{X2,Y2,Z2},W2})
  when is_float(X1),is_float(Y1),is_float(Z1),is_float(W1),
       is_float(X2),is_float(Y2),is_float(Z2),is_float(W2) ->
    {{X1+X2,Y1+Y2,Z1+Z2},W1+W2}.

scale({{Qx,Qy,Qz},Qw}, S)
  when is_float(Qx),is_float(Qy),is_float(Qz),is_float(Qw), is_float(S) ->
    {{Qx*S,Qy*S,Qz*S},Qw*S}.

mul([H|R]) ->
    mmult(R, H).

mmult([H|R], A) ->
    mmult(R, mul(A,H));
mmult([], A) -> A.

mul({{X1,Y1,Z1},W1}, {{X2,Y2,Z2},W2})
  when is_float(X1),is_float(Y1),is_float(Z1),is_float(W1),
       is_float(X2),is_float(Y2),is_float(Z2),is_float(W2) ->
    {{W1*X2+X1*W2+Y1*Z2-Z1*Y2,
      W1*Y2+Y1*W2+Z1*X2-X1*Z2,
      W1*Z2+Z1*W2+X1*Y2-Y1*X2},
     W1*W2-X1*X2-Y1*Y2-Z1*Z2}.

to_rotation_matrix({{Qx,Qy,Qz},Qw})
  when is_float(Qx),is_float(Qy),is_float(Qz),is_float(Qw) ->
    Zero = 0.0,    One  = 1.0,    Two = 2.0,
    XX = Qx*Qx,    XY = Qx*Qy,    XZ = Qx*Qz,    XW = Qx*Qw,
    YY = Qy*Qy,    YZ = Qy*Qz,    YW = Qy*Qw,
    ZZ = Qz*Qz,    ZW = Qz*Qw,

    M0=One-Two*(YY+ZZ), M1=Two*(XY-ZW),     M2=Two*(XZ+YW),
    M4=Two*(XY+ZW),     M5=One-Two*(XX+ZZ), M6=Two*(YZ-XW),
    M8=Two*(XZ-YW),     M9=Two*(YZ+XW),     M10=One-Two*(XX+YY),

    M3=M7=M11=Zero,
    {M0, M4, M8,
     M1, M5, M9,
     M2, M6, M10,
     M3, M7, M11}.

from_rotation_matrix({M0, M4, M8,
		      M1, M5, M9,
		      M2, M6, M10,
		      M3, M7, M11})
  when is_float(M0),is_float(M1),is_float(M2),is_float(M3),
       is_float(M4),is_float(M5),is_float(M6),is_float(M7),
       is_float(M8),is_float(M9),is_float(M10),is_float(M11) ->
    One = 1.0,  Two = 2.0, Eps = 0.000000001,
    T = One + M0 + M5 + M10,
    if T > Eps ->
	    S = math:sqrt(T) * Two,
	    {{(M9-M6)/S, (M2-M8)/S,(M4-M1)/S},0.25*S};
       (M0>M5) and (M0>M10) ->
	    S = math:sqrt(One+M0-M5-M10) * Two,
	    {{0.25*S,(M4+M1)/S,(M2+M8)/S},(M9-M6)/S};
       (M5>M10) ->
	    S = math:sqrt(One+M5-M0-M10),
	    {{(M4+M1)/S,0.25*S,(M9+M6)/S},(M2-M8)/S};
       true ->
	    S = math:sqrt(One+M10-M0-M5),
	    {{(M2+M8)/S,(M9+M6)/S,0.25*S},(M4-M1)/S}
    end;
from_rotation_matrix(M) when size(M) =:= 16 ->
    from_rotation_matrix(e3d_mat:compress(M)).

%% The Axis must be a unit-length vector.
from_angle_axis(Angle, Axis) ->
    HalfAngle = Angle*(3.14159/180.0/2.0),
    Sin = math:sin(HalfAngle),
    Cos = math:cos(HalfAngle),
    {X,Y,Z} = Axis,
    {{X*Sin,Y*Sin,Z*Sin},Cos}.

to_angle_axis(Q) ->
    {{Qx,Qy,Qz},Qw} = norm(Q),
    Cos = Qw,
    Angle = math:acos(Cos) * (2*180/3.14159),
    Sin0  = math:sqrt(1.0 - Cos*Cos),
    Sin   = if
		abs(Sin0) < 0.000005 -> 1.0;
		true -> Sin0
	    end,    
    {Angle,{Qx/Sin,Qy/Sin,Qz/Sin}}.

%% vec_rotate(Vec, Q)
%%  Rotate a vector or point using quaternion Q.
vec_rotate({X2,Y2,Z2}, {{X1,Y1,Z1},W1})
  when is_float(X1), is_float(Y1), is_float(Z1), is_float(W1),
       is_float(X2), is_float(Y2), is_float(Z2)  ->
    %% Calculate Q*{V,0}*^Q.
    X3 = W1*X2+Y1*Z2-Z1*Y2,
    Y3 = W1*Y2+Z1*X2-X1*Z2,
    Z3 = W1*Z2+X1*Y2-Y1*X2,
    W3 = -X1*X2-Y1*Y2-Z1*Z2,
    {-W3*X1+X3*W1-Y3*Z1+Z3*Y1,
     -W3*Y1+Y3*W1-Z3*X1+X3*Z1,
     -W3*Z1+Z3*W1-X3*Y1+Y3*X1}.
