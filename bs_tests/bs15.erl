% -*- erlang-indent-level: 2 -*-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Filename : 	bs15.erl
%%  Purpose  :  These tests are intended to test the construction and 
%%              matching of binaries using variable sizes 
%%  Notes    :  Added test that crashed beam compiler
%%  CVS      :
%%              $Author: pergu $
%%              $Date: 2004/01/29 16:43:46 $
%%              $Revision: 1.4 $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(bs15).
-export([test/0,compile/1]).

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
  ok.
   
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
