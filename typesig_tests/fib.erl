%%%-------------------------------------------------------------------
%%% File    : fib.erl
%%% Author  : Tobias Lindahl <toli6207@fan.it.uu.se>
%%% Description : Fibonacci numbers
%%%
%%% Created : 17 Feb 2003 by Tobias Lindahl <toli6207@fan.it.uu.se>
%%%-------------------------------------------------------------------
-module(fib).

-compile(export_all).

doit()->
  fib(10).

fib(0)->
  1;
fib(1)->
  1;
fib(N)->
  fib(N-1) + fib(N-2).
