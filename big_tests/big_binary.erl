-module(big_binary).
-export([test/0,compile/1]).

compile(O) ->
  hipe:c(?MODULE,O).

test()->
  Bin = <<0:80000000>>,
  Bin0 = list_to_binary([Bin,Bin,Bin,Bin,Bin]),
  Bin1 = list_to_binary([Bin0,Bin0,Bin0,Bin0,Bin0,Bin0]),
  Ans1 = start(Bin1),
  Bin2 = list_to_binary([Bin1,Bin1]),
  {Ans1,start(Bin2)}.

start(Bin) ->
  <<Start:15/binary,Rem/binary>> = Bin,
  {Start,size(Bin),size(Rem)}.
