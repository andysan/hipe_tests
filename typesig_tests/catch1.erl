%%%-------------------------------------------------------------------
%%% File    : catch1.erl
%%% Author  : Tobias Lindahl <tobiasl@it.uu.se>
%%% Description : 
%%%
%%% Created : 24 Jan 2005 by Tobias Lindahl <tobiasl@it.uu.se>
%%%-------------------------------------------------------------------
-module(catch1).
-export([t/1]).

t(X) ->
  catch X + 1.
