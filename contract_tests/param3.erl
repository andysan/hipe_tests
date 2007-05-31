%%%-------------------------------------------------------------------
%%% File    : param3.erl
%%% Author  : Tobias Lindahl <tobiasl@csd.uu.se>
%%% Description : 
%%%
%%% Created : 31 May 2007 by Tobias Lindahl <tobiasl@csd.uu.se>
%%%-------------------------------------------------------------------
-module(param3).

-export([t1/2, t2/2]).

-spec(t1/2 :: ((a(), a())-> [a()])).
-spec(t2/2 :: ((a(), a())-> [a()])).
-spec(t3/1 :: ((a())-> a())).

t1(A = foo, B = 1) ->
  [A, B].

t2(A = 1, B) when is_integer(B) ->
  [A, B].

t3(X) when X =:= 1 ->
  X + 1.
