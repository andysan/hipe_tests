%%%-------------------------------------------------------------------
%%% File    : fp_ebb.erl
%%% Author  : Tobias Lindahl <tobiasl@csd.uu.se>
%%% Description : Test the construction ov overlapping fp extended 
%%%               basic blocks where BEAM has constructed one and 
%%%               hipe_icode_fp constructs the other one.
%%%
%%% Created : 18 Aug 2003 by Tobias Lindahl <tobias@dhcp-12-248.it.uu.se>
%%%-------------------------------------------------------------------
-module(fp_ebb).

-export([test/0,compile/1]).

test()->
  1.0 == foo(2*math:pi()),
  ok.

foo(X) ->
  X / (2 * math:pi()).

compile(O) ->
  hipe:c(?MODULE,O).
