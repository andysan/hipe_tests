%%% $Id: apptail_test.erl,v 1.1 2003/11/12 21:08:00 mikpe Exp $
%%% Check that apply is tail-recursive.

-module(apptail_test).
-export([test/0, compile/1]).
-export([app0/2]).

compile(Flags) ->
    hipe:c(?MODULE, Flags).

test() ->
    start(400),
    ok.

start(N) ->
    app0(N, hipe_bifs:nstack_used_size()).

app0(0, Size0) ->
    Size1 = hipe_bifs:nstack_used_size(),
    %io:format("Size0 ~w, Size1 ~w\n", [Size0, Size1]),
    if Size1 > Size0+20 ->
	    exit(?MODULE);
       true -> []
    end;
app0(N, Size) ->
    apply(?MODULE, app0, [N-1, Size]).
