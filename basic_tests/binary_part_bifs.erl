%%---------------------------------------------------------------------------
%% Checks that 2-ary as well as 3-ary BIFs can be compiled to native code.
%%---------------------------------------------------------------------------

-module(binary_part_bifs).
-export([test/0, compile/1]).

test() ->
  Bin = <<1,2,3,4,5,6,7,8,9,10>>,
  BinPart = bp3(Bin),
  <<7,8>> = bp2(BinPart),
  ok.

bp2(Bin) ->
  binary_part(Bin, {1, 2}).

bp3(Bin) ->
  binary_part(Bin, byte_size(Bin), -5).

compile(Opts) ->
  hipe:c(?MODULE, Opts).
