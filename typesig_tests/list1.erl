%%%-------------------------------------------------------------------
%%% File    : list1.erl
%%% Author  : Tobias Lindahl <tobias@dhcp-12-242.it.uu.se>
%%% Description : 
%%%
%%% Created :  3 Mar 2003 by Tobias Lindahl <tobias@dhcp-12-242.it.uu.se>
%%%-------------------------------------------------------------------

-module(list1).

-export([doit/0]).

doit()->
  {len([1, 2, 3], 0)}.


len([_|T], Acc)->
  len(T, Acc+1);
len([], Acc) ->
  Acc+0.

reverse([H|T]) ->
  reverse(T) ++ [H];
reverse([]) ->
  [].

append([H|T], Z) ->
   [H|append(T, Z)];
append([], X) ->
   X.
