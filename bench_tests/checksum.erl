%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%			  INTERNET CHECKSUM
%
% inet_checksum/1 implements the internet checksum algorithm, as given in
% p. 110, Computer Networks (Davies & Peterson).
%
% Note: since fixnums are not 32 bits in Erlang, we'll fault into bignums
%  too often. A slight rewrite could avoid that.

-module(checksum).
-export([test/0,compile/1]).          % does not compile yet

-define(BNEG(X),-(X)+1).

test() ->
  case file:read_file('checksum.data') of
    {ok,Binary} ->
      statistics(runtime),
      R = loop(100,Binary),
      {_,Time} = statistics(runtime),
      io:format("\nruntime = ~p msecs\nresult = ~p\n",[Time,R]),
      R;
    {error,Reason} ->
      io:format('error: ~w~n',[Reason])
  end.

compile(Flags) ->
    hipe:c(?MODULE,Flags).

run() ->
    case file:read_file('checksum.data') of
	{ok,Binary} ->
	    loop(100,Binary);
	{error,Reason} ->
	    io:format('error: ~w~n',[Reason])
    end.

loop(0,B) -> ok;
loop(N,Binary) ->
    inet_checksum(Binary),
    loop(N-1,Binary).

inet_checksum(Binary) ->
    inet_chk(binary_to_list(Binary),0).

inet_chk([],Sum) -> ?BNEG(Sum band 16#FFFF);
inet_chk([X|Xs],Sum) ->
    Nxt = Sum+X,
    Item = Nxt band 16#FFFF0000,
    if
	Item =/= 0 ->
	    New = (Nxt band 16#FFFF)+1;
	true ->
	    New = Nxt
    end,
    inet_chk(Xs,New).
