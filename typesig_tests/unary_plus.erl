%%%-------------------------------------------------------------------
%%% File    : unary_plus.erl
%%% Author  : Tobias Lindahl <tobiasl@it.uu.se>
%%% Description : 
%%%
%%% Created : 11 Aug 2004 by Tobias Lindahl <tobiasl@it.uu.se>
%%%-------------------------------------------------------------------
-module(unary_plus).
-export([t/1]).
-export([error/1]).

t() ->
  t(3.14) + t(42).

t(X) ->
  +(X).

error(_) ->
  +(gazonk).
