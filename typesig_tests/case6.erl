%%%-------------------------------------------------------------------
%%% File    : case6.erl
%%% Author  : Tobias Lindahl <tobiasl@it.uu.se>
%%% Description : 
%%%
%%% Created : 12 Jan 2005 by Tobias Lindahl <tobiasl@it.uu.se>
%%%-------------------------------------------------------------------
-module(case6).

-compile(export_all).


t1(X, Y) ->
  case X of
    1 -> 3=4, Y + 1;
    2 -> list_to_atom(Y)
  end.

t2(X) when is_list(42) ->
  ok.

t3(X) ->
  t2(X),
  ok.
