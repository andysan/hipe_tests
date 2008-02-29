%% -*- erlang-indent-level: 2 -*-

%% @author Daniel Luna <luna@update.uu.se>
%% @copyright 2008 Daniel Luna
%% 
%% @doc 
%% 

-module(fail_02).
-export([test/0]).

-spec(test/0 :: () -> ok).
test() ->
  fail_01:test().
