-module(bs_split).
-export([test/0, compile/1]).

test() ->
  {<<61,62,63>>, <<64,65,66>>} = z_split(<<61,62,63,0,64,65,66>>, 0),
  {<<61,62,63>>, <<64>>} = z_split(<<61,62,63,0,64>>, 0),
  {<<61,62,63>>, <<>>} = z_split(<<61,62,63,0>>, 0),
  <<61,62,63>> = z_split(<<61,62,63>>, 0),
  ok.

%% Splits a series of null terminated segments of a binary without
%% creating any new sub-binaries until the zero is found.

z_split(B, N) ->
  case B of
    <<B1:N/binary,0,B2/binary>> ->
      {B1,B2};
    <<_:N/binary>> = B ->
      B;
    <<_:N/binary,_/binary>> = B ->
      z_split(B, N+1)
  end.

compile(Opts) ->
  hipe:c(?MODULE, Opts).
