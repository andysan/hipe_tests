% -*- erlang-indent-level: 2 -*-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Filename : 	bs15.erl
%%  Purpose  :  These tests are intended to test the construction and 
%%              matching of binaries using variable sizes 
%%  Notes    :  Added test that crashed beam compiler
%%              Added some more test which crashed when segments of
%%              size zero were used and one that did not convert integers 
%%              to floats when constructing binaries
%%  CVS      :
%%              $Author: pergu $
%%              $Date: 2004/02/26 10:27:50 $
%%              $Revision: 1.6 $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(bs15).
-export([test/0,compile/1,c/0,t/0]).
-compile(export_all).

compile(Opts) ->
  hipe:c(?MODULE,Opts).

test() ->
  N1 = 18,
  A1 = 2, 
  A1 = match1(N1,<<1:12, 2:N1, A1:2>>),   
  A1 = match2(N1,<<1:12, 2:N1/integer-little, A1:2>>),   
  N3 = 3,
  A3 = <<1,2,3>>, 
  B3 = 2,
  {A3,B3} = match3(N3,<<1:12, A3:N3/binary, B3:4>>),
  N4 = 12,
  B4 = <<1,2,3>>, 
  A4 = 2,
  {A4,B4} = match4(N4,<<1:N4, A4:4, B4/binary>>),
  Y = <<5>>,
  Y = match5(a, Y),
  <<73>> = gen1(8, 0, <<73>>),
  <<171>> = gen2(8, 7, 2#10101010101010101),
  <<0:64>> = construct(),
  ok.

construct() ->
  <<0:64/float>>.
   
match1(N, Bin) ->
  <<1:12, 2:N, A:2>>=Bin,
  A.

match2(N, Bin) ->
  <<1:12, 2:N/integer-little, A:2>>=Bin,
  A.

match3(N, Bin) ->
  <<1:12, A:N/binary, B:4>>=Bin,
  {A,B}.

match4(N, Bin) ->
  <<1:N, A:4, B/binary>>=Bin,
  {A,B}.

match5(X, Y) ->
    case X of
        a ->
            Y2 = 8
    end,
    <<5:Y2>> = Y.
    
gen1(N, S, A) ->
  <<A:S/binary-unit:1, A:(N-S)/binary-unit:1>>.

gen2(N, S, A) ->
    <<A:S/little, A:(N-S)/little>>.

t() ->
  ok = in_guard(<<16#BCD:14,3:2>>, 16#BCD).

in_guard(Bin, A) when <<A:14,3:2>> == Bin -> ok;
in_guard(_, _) -> nope.

c() ->
  hipe:c({bs15,t,0}, [o2,rtl_ssa,pp_rtl_ssa,{regalloc,linear_scan}]).

