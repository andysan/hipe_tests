%%%-------------------------------------------------------------------
%%% File    : cons.erl
%%% Author  : Tobias Lindahl <tobiasl@it.uu.se>
%%% Description : 
%%%
%%% Created : 11 Aug 2004 by Tobias Lindahl <tobiasl@it.uu.se>
%%%-------------------------------------------------------------------
-module(cons).

-compile(export_all).

doit()->
  t(1).

t(X) ->
  [X].




