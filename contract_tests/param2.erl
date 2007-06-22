%%%-------------------------------------------------------------------
%%% File    : param2.erl
%%% Author  : Miguel Jimenez <milingo83@gmail.com>
%%% Description : Types of the parameter differ
%%%
%%% Created : 31 May 2007
%%%-------------------------------------------------------------------
-module(param2).
-export([add/1, mystery/2, mystery2/2]).

%% Will fail
-spec (add/1::((A) -> A)). 
-spec (mul/1 :: ((non_neg_integer()) -> byte())).
%% Success type for mystery/2:
%% ((non_neg_integer(),number()) -> byte())
%% With contract:
%% ((non_neg_integer(),non_neg_integer()) -> byte())
%% OK since all are subtypes
-spec (mystery/2 :: ((B, B) -> B)).
%% Will fail since they are not subtypes
-spec (mystery2/2 :: ((B, B) -> B)).


add(X) ->
  two(X + 1).

two(2) ->
  ok.

mystery(X, Y)->
  Z = mul(X),
  Y + 5.0,
  Z div 2.

mul(0) -> 0;
mul(K) -> K*2 + mul(K-1).  

mystery2(X, Y)->
  mul(X),
  Y + 5.0.

mystery2_call() ->
    mystery2(3, 4).

