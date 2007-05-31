%%%-------------------------------------------------------------------
%%% File    : lists1.erl
%%% Author  : Miguel Jimenez <milingo83@gmail.com>
%%% Description : some list functions examples
%%%
%%% Created : 30 May 2007
%%%-------------------------------------------------------------------
-module(lists1).
-export([nth/2, subtract/2, append/1, append/2, test1/0, test2/0]).

-spec (append/2 :: (([a()], [a()]) -> [a()])).
-spec (append/1 :: (([[a()]]) -> [a()])).
-spec (subtract/2 :: (([a()], [a()]) -> [a()])).
%% signature without contract:
%% ((pos_integer(),nonempty_possibly_improper_list()) -> any())
%% Are we loosing info here??
-spec (nth/2 :: ((non_neg_integer(), [a()]) -> a())).

test1() ->
  append([foo],[foo]).

test2() ->
  append([1],[foo]).

nth(1, [H|_]) -> H;
nth(N, [_|T]) when N > 1 ->
    nth(N - 1, T).


subtract(L1, L2) -> L1 -- L2.


append(L1, L2) -> L1 ++ L2.

append([E]) -> E;
append([H|T]) -> H ++ append(T);
append([]) -> [].
