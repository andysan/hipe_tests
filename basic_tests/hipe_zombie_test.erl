%%%-------------------------------------------------------------------
%%% File    : test.erl
%%% Author  : Per Gustafsson <pergu@jobberl>
%%% Description : 
%%%
%%% Created : 25 Oct 2007 by Per Gustafsson <pergu@jobberl>
%%%-------------------------------------------------------------------
-module(hipe_zombie_test).

-export([test/0,compile/1]).

compile(O) ->
  hipe:c(?MODULE,O).

test() ->
  L = length(processes()),
  hipe:c(?MODULE),
  L = length(processes()),
  ok.
