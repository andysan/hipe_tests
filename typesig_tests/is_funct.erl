%%-------------------------------------------------------------------
%% File    : is_funct.erl
%% Author  : Kostis Sagonas <kostis@it.uu.se>
%% Description : Tests the handling of the new is_function/2 type guard.
%%
%% Created : 5 Jul 2005 by Kostis Sagonas <kostis@it.uu.se>
%%-------------------------------------------------------------------

-module(is_funct).
-export([f/1, f/2]).

f(F) when is_function(F,1) ->
  ok.

f(F,N) when is_function(F,N) ->
  case N of
    1 -> unary;
    2 -> binary
  end.
