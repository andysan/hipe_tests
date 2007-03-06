%% Module from Zoltan Toth that crashed the HiPE compiler (in R11B-3).
%% The problem was that the binary matching produces a pretty large
%% integer and we tried to find the range for this integer in a bad way.
%% Fixed on the same day -- 6th March 2007.

-module(bs_binmatch).
-export([test/0, compile/1]).

test() ->
  case crypto:start() of
    ok -> ok;
    {error,{already_started,crypto}} -> ok
  end,
  "DF58248C414F342C81E056B40BEE12D17A08BF61" = checksum(<<42>>),
  ok.

checksum(Bin) ->
  Context = crypto:sha_init(),
  checksum(Context, Bin).

checksum(Context, <<>>) ->
  bin_to_hex(crypto:sha_final(Context));
checksum(Context, <<Bin:20480,Rest>>) ->
  checksum(crypto:sha_update(Context, Bin), Rest);
checksum(Context,Bin) ->
  checksum(crypto:sha_update(Context, Bin), <<>>).

bin_to_hex(Bin) ->
  lists:flatten([byte_to_hex(X) || X <- binary_to_list(Bin)]).
byte_to_hex(Byte) -> 
  [int_to_hex(Byte div 16), int_to_hex(Byte rem 16)].

int_to_hex(Int) when Int < 10 -> $0 + Int;
int_to_hex(Int) when Int > 9 -> $A + Int - 10.

compile(Opts) ->
  hipe:c(?MODULE, Opts).
