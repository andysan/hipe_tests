-module(lfold1).
-export([lfold_ok/0, lfold_nil/0, lfold_none/0]).

lfold_ok() ->
  F = fun (X, Sum) when is_integer(Sum) -> X + Sum end,
  lists:foldl(F, 0, [1,2,3]).

lfold_nil() ->
  F = fun (X, Sum) when is_atom(Sum) -> X + Sum end,
  lists:foldl(F, 0, []).

lfold_none() ->
  F = fun (X, Sum) when is_atom(Sum) -> X + Sum end,
  lists:foldl(F, 0, [a,b,c]).
