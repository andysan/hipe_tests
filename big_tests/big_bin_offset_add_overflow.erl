%%======================================================================
%% From: Per Gustafsson
%% Date: 2 Jun 23, 2009
%%
%% Bug in HiPE big binary matching, offset additions are not handled
%% correctly.
%% 
%%======================================================================

-module(big_bin_offset_add_overflow).

-export([test/0, compile/1]).

test() ->
  bug(1, <<0:1200>>).

compile(Opts) -> hipe:c(?MODULE, Opts).

bug(X, Bin) ->
  <<_:X/bytes, _:16#fffffffff, _/bits>> = Bin.
