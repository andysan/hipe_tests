%%%-------------------------------------------------------------------
%%% File    : dataflow1.erl
%%% Author  : Miguel Jimenez <milingo83@gmail.com>
%%% Description : Dataflow analysis
%%%
%%% Created : 30 May 2007
%%%-------------------------------------------------------------------
-module(dataflow1).
-export([f3/0, f4/0]).

-spec (add/1 :: ((A) -> A)).
-spec (f3/0 :: (() -> byte())).
-spec (f4/0 :: (() -> byte())).

add(X) ->
    X + 1.

%% Will succeed. Not working yet (dataflow)!
f3() ->
    add(254).

%% Will fail. Not working yet (dataflow)!
f4() ->
    add(257).
