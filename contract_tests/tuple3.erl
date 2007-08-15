%%%-------------------------------------------------------------------
%%% File    : tuple3.erl
%%% Author  : Tobias Lindahl <tobiasl@it.uu.se>
%%% Description : Exposed a bug in is_binary
%%%
%%% Created : 16 Mar 2005 by Tobias Lindahl <tobiasl@it.uu.se>
%%%-------------------------------------------------------------------
-module(tuple3).

-export([test/0,abstract/1]).

-type(my_tuple() :: {'tuple',0,[any()]}).

-spec (test/0 :: (() -> my_tuple())).
-spec (abstract/1 :: ((binary() | [] | tuple()) -> {'nil',0} | {'bin',0,[{_,_,_,_,_}]} | {'tuple',0,[{_,_} | {_,_,_}]})).
-spec (abstract_list/1 :: (([binary() | [] | tuple()]) -> [{'nil',0} | {'bin',0,[any()]} | my_tuple()])).

test() ->
    {tuple,_,_} = abstract({gazonk,42}).

abstract([]) -> {nil,0};
abstract(B) when is_binary(B) ->
    {bin, 0, lists:map(fun(Byte) ->
			       {bin_element, 0,
				{integer, 0, Byte}, default, default}
 		       end,
 		       binary_to_list(B))};
abstract(Tuple) when is_tuple(Tuple) ->
    {tuple,0,abstract_list(tuple_to_list(Tuple))}.

abstract_list([H|T]) ->
    [abstract(H)|abstract_list(T)];
abstract_list([]) ->
    [].
