%%-------------------------------------------------------------------
%% File    : arith1.erl
%% Author  : Kostis Sagonas <kostis@it.uu.se>
%% Description : Tests 'backwards' propagation of arithmetic constraints.
%%
%% Created : 31 Jan 2005 by Kostis Sagonas <kostis@it.uu.se>
%%-------------------------------------------------------------------
-module(arith1).
-compile(export_all).

next_random(N) -> (N * 1713) rem 1001.