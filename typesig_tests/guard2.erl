%%%-------------------------------------------------------------------
%%% File    : guard2.erl
%%% Author  : Tobias Lindahl <tobiasl@it.uu.se>
%%% Description : 
%%%
%%% Created : 12 Jan 2005 by Tobias Lindahl <tobiasl@it.uu.se>
%%%-------------------------------------------------------------------
-module(guard2).

-compile(export_all).

t1(X) when is_atom(X); length(X) > 1 -> ok.

t2(X) when is_atom(X), length(X) > 1 -> ok.

t3(X) when X =:= foo, is_atom(X) -> ok.

t4(X) when X =:= foo; X =:= bar -> ok.

t5(X, Y) when X =:= Y, length(X) > 1 -> ok.
  
t6(X) when X -> ok.

t7(X) when not X -> ok.

t8(X) when size(X) -> ok.
  
