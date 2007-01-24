-module(lfold1).
-export([lfold_sum/0, lfold_nil/0, lfold_none/0,
	 lfold_ignore_acc_nonempty/0, lfold_ignore_acc_nil/0,
	 lfold_ignore_acc_list/1]).

lfold_sum() ->
  F = fun (X, Sum) when is_integer(Sum) -> X + Sum end,
  lists:foldl(F, 0, [1,2,3]).

lfold_nil() ->
  F = fun (X, Sum) when is_atom(Sum) -> X + Sum end,
  lists:foldl(F, 0, []).

lfold_none() ->
  F = fun (X, Sum) when is_atom(Sum) -> X + Sum end,
  lists:foldl(F, 0, [a,b,c]).

%% Here the list is known, so accumulator plays no role
lfold_ignore_acc_nonempty() ->
  F = fun (X, _) when is_integer(X) -> X + 1 end,
  lists:foldl(F, gazonk, [1,2,3]).

%% ... but here obviously the accumulator cannot be ignored
lfold_ignore_acc_nil() ->
  F = fun (X, _) when is_integer(X) -> X + 1 end,
  lists:foldl(F, gazonk, []).

%% ... while here we have to be conservative and include both types
lfold_ignore_acc_list(List) ->
  F = fun (X, _) when is_integer(X) -> X + 1 end,
  lists:foldl(F, gazonk, List).
