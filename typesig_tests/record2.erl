%%%-------------------------------------------------------------------
%%% File    : record2.erl
%%% Author  : Tobias Lindahl <tobiasl@csd.uu.se>
%%% Description : Exposes a bug in the strict compilation of record tests.
%%%
%%% Created :  3 Jan 2006 by Tobias Lindahl <tobiasl@csd.uu.se>
%%%-------------------------------------------------------------------
-module(record2).

-export([t/0]).

-record(foo, {bar}).

t() ->
  R = {an, improper, record},
  bar(R).

bar(X) when X#foo.bar > 0 ->
  X.
