%%%-------------------------------------------------------------------
%%% File    : sequence.erl
%%% Author  : Tobias Lindahl <tobiasl@it.uu.se>
%%% Description : 
%%%
%%% Created : 15 Dec 2004 by Tobias Lindahl <tobiasl@it.uu.se>
%%%-------------------------------------------------------------------
-module(sequence).

-compile(export_all).

t() ->
  add(100, 5, 5),
  add(200, 10, 10).


add(0, _, _) -> ok;
add(Iter, A, B) ->
  A + B,
  add(Iter-1, A, B).
