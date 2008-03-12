%% -*- erlang-indent-level: 2 -*-
-module(hipe_01).
-export([test/0]).

test() ->
  catch hipe:c(?MODULE, [{gazonk,42,bar}]).
