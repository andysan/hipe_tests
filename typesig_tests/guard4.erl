-module(guard4).
-export([test/0]).

test() ->
  f(42).

f(N) when integer(N) ->
  N + 1;
f(L) when list(L) ->
  size(L);	%% erroneous use which should not influence result
f(L) when binary(L) ->
  size(L).
