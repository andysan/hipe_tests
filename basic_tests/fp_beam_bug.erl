%%-------------------------------------------------------------------
%% File    : fp_beam_bug.erl
%% Purpose : Test which shows that BEAM's splitting of basic blocks
%%	     should take into account that arithmetic operations
%%	     implemented as bifs can also cause exceptions and thus
%%	     calls to bifs should end basic blocks.
%%	     The problem was fixed on April 6th by Bjorn G.
%%
%% Created : 6 April 2004 by Kostis S. (after a mail by Mikael P.)
%%-------------------------------------------------------------------

-module(fp_beam_bug).
-export([test/0,compile/1]).

test()->
  X = (catch bad_arith(2.0, 1.7)),
  case X of
    {'EXIT', {badarith, _}} ->
      ok;
    _ ->
      error
  end.

bad_arith(X, Y) when float(X) ->
  X1 = X * 1.7e+308,
  X2 = X1 + 1.0,
  Y1 = Y * 2,
  {X2, Y1}.

compile(O) ->
  hipe:c(?MODULE,O).
