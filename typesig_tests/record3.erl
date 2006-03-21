-module(record3).
-export([m/1]).

-record(dict, {n=42, empty, segs}).

m(T) when is_integer(T#dict.n) ->
    T#dict{segs = expand_segs(T#dict.segs, T#dict.empty)}.

expand_segs(Segs, Empty) ->
    list_to_tuple(tuple_to_list(Segs) ++ lists:duplicate(size(Segs), Empty)).

