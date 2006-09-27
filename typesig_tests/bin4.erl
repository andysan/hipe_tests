-module(bin4).
-export([leaf_to_bin/1]).

leaf_to_bin(List) ->
    leaf_to_bin(List, []).

leaf_to_bin([N | L], Acc) ->
    leaf_to_bin(L, [<<N:32>> | Acc]);
leaf_to_bin([], Acc) ->
    Acc.

