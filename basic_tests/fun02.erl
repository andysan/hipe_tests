-module(fun02).
-export([test/0,compile/1,f/2]).

test() ->
  t2(?MODULE,f).

compile(Flags) ->
  hipe:c(?MODULE,Flags).

t2(M,F) ->
  M:F(bar,42).

f(_,_) ->
  ok.
