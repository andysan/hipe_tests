%%----------------------------------------------------------------------------
%% Tests that binary constants can properly be treated in Icode
%%----------------------------------------------------------------------------
-module(bs_bitsize2).
-export([test/0, compile/1]).

test() ->
  8 = constant_binary(42),
  ok.

constant_binary(N) when N > 0 ->
  bit_size(<<42>>).

compile(Opts) ->
  hipe:c(?MODULE, Opts).
