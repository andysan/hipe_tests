%%%-------------------------------------------------------------------
%%% File    : cont_union2.erl
%%% Author  : Miguel Jimenez <milingo83@gmail.com>
%%% Description : Union of subset (not disjointed) contracts
%%%
%%% Created : 30 May 2007
%%%-------------------------------------------------------------------
-module(cont_union2).
-export([t1/0, t2/0]).

%% We should consider both contracts if called with an integer()
%% since number() > integer()  
-spec(t/1 :: (([number()]) -> [atom()]) , 
             (([integer()]) -> [integer()])).


t(P) -> 
  lists:map(
    fun(X) -> case X*X of
		1 -> 2;
		_ -> foo
	      end
    end, 
    P).

%% Range is [atom()] since it matches the first union of the contract
t1() ->
    t([3.0,4.0,5.0]).

%% Range is ([atom()] | [integer()]) since it matches both contracts
t2() ->
    t([1,1,1]).


