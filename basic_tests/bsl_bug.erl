%%%-------------------------------------------------------------------
%%% File    : bsl_bug.erl
%%% Author  : Per Gustafsson <pergu@it.uu.se>
%%% Description : This triggers a bug in the emulator as one
%%%               of the arguments to bsl is not an integer.
%%%
%%% Created : 28 Sep 2006 by Per Gustafsson <pergu@it.uu.se>
%%%-------------------------------------------------------------------
-module(bsl_bug).
-export([test/0,compile/1]).

test() ->
  {'EXIT',{'badarith',_}} = (catch (t1(0,pad,0))),
  {'EXIT',{'badarith',_}} = (catch (t2(0,pad,0))),
  ok.

t1(_,X,_) ->
  (1 bsl X) + 1.

t2(_,X,_) ->
  (X bsl 1) + 1.

compile(O) -> 
  hipe:c(?MODULE,O).

