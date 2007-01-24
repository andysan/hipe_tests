-module(lflatmap1).
-export([fm1/0, fm2/0, fm_nil/0, fm_none/0]).

fm1() ->
  lists:flatmap(fun(X) -> [X,X] end, [a,b]).

fm2() ->
  lists:flatmap(fun(X) when is_integer(X) -> [X+1] end, [1,2]).

fm_nil() ->
  lists:flatmap(fun(X) when is_atom(X) -> [X+1] end, []).

fm_none() ->
  lists:flatmap(fun(X) when is_atom(X) -> [X+1] end, [a,b]).
