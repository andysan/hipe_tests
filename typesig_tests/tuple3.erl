-module(tuple3).
-export([test/0,abstract/1]).

test() ->
    {tuple,_,_} = abstract({gazonk,42}).

% abstract(T) when integer(T) -> {integer,0,T};
% abstract(T) when float(T) -> {float,0,T};
% abstract(T) when atom(T) -> {atom,0,T};
abstract([]) -> {nil,0};
abstract(B) when binary(B) ->
    {bin, 0, lists:map(fun(Byte) ->
			       {bin_element, 0,
				{integer, 0, Byte}, default, default}
 		       end,
 		       binary_to_list(B))};
% abstract([C|T]) when integer(C), 0 =< C, C < 256 ->
%     abstract_string(T, [C]);
% abstract([H|T]) ->
%     {cons,0,abstract(H),abstract(T)};
abstract(Tuple) when tuple(Tuple) ->
    {tuple,0,abstract_list(tuple_to_list(Tuple))}.

abstract_string([C|T], String) when integer(C), 0 =< C, C < 256 ->
    abstract_string(T, [C|String]);
abstract_string([], String) ->
    {string, 0, lists:reverse(String)};
abstract_string(T, String) ->
    not_string(String, abstract(T)).

not_string([C|T], Result) ->
    not_string(T, {cons, 0, {integer, 0, C}, Result});
not_string([], Result) ->
    Result.

abstract_list([H|T]) ->
    [abstract(H)|abstract_list(T)];
abstract_list([]) ->
    [].
