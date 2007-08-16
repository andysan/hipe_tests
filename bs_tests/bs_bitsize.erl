-module(bs_bitsize).
-export([test/0, compile/1]).

-compile(bitlevel_binaries).

test() ->
  true = bitsize_in_body(<<1:42>>),
  true = bitsize_in_guard(<<1:7>>),
  ok.

bitsize_in_body(Bin) ->
  42 =:= erlang:bitsize(Bin).

bitsize_in_guard(Bin) when erlang:bitsize(Bin) rem 7 =:= 0 ->
  true;
bitsize_in_guard(Bin) when is_binary(Bin) ->
  false.

compile(Opts) ->
  hipe:c(?MODULE, Opts).
