%%%-------------------------------------------------------------------
%%% File    : guard3.erl
%%% Author  : Tobias Lindahl <tobiasl@it.uu.se>
%%% Description : 
%%%
%%% Created : 26 Jan 2005 by Tobias Lindahl <tobiasl@it.uu.se>
%%%-------------------------------------------------------------------
-module(guard3).

-compile(export_all).

t1(X) when X == 1 -> ok.

t2(X) when X =:= 1 -> ok.

t3(X) when X == foo -> ok.

t4(X) when X =:= foo -> ok.
  
