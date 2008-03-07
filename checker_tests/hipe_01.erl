-module(hipe_01).
-export([test/0]).

test() ->
  hipe:c(?MODULE, [{gazonk,42,bar}]).
