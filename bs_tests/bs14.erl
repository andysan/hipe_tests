%%% File    : split.erl
%%% Author  : Per Gustafsson <pergu@dhcp-12-245.it.uu.se>
%%% Description : 
%%% Taken from Dan Wallins and Kostis e-mails, this module tests 
%%% Using size fields specified within the binary
%%% Created : 22 May 2003 by Per Gustafsson <pergu@dhcp-12-245.it.uu.se>

-module(bs14).

-export([test/0, compile/1]).

test() ->
    <<42>> = construct_1(8),
    <<42:8/little>> = construct_2(8),
    <<55>> = x(1, 3, 1, 7, 4),
    ok.

compile(O) ->
  hipe:c(?MODULE,O).

construct_1(S) ->
    <<42:S>>.
construct_2(S) ->
    <<42:S/little>>.
x(A,Head,FB,C,Tail) ->
  << A:Head, FB:1, C:Tail >>.
