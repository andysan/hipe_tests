%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Purpose: test support for UTF datatypes in binaries - incomplete
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(bs_utf).
-export([test/0, compile/1]).

test() ->
  <<65>> = <<65/utf8>>,
  ok = m(<<65>>).

m(<<65/utf8>>) ->
  ok.

compile(Opts) ->
  hipe:c(?MODULE, Opts).
