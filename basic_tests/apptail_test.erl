%%% $Id: apptail_test.erl,v 1.2 2004/02/17 09:29:07 kostis Exp $
%%% Check that apply is tail-recursive.
%%
%%% NOTE: Increased the SIZE_INCREASE from 20 to 30 so that it
%%%	  can also be tested with the naive register allocator.

-module(apptail_test).
-export([test/0, compile/1]).
-export([app0/2]).

-define(SIZE_INCREASE, 30).

compile(Flags) ->
    hipe:c(?MODULE, Flags).

test() ->
    start(400),
    ok.

start(N) ->
    app0(N, hipe_bifs:nstack_used_size()).

app0(0, Size0) ->
    Size1 = hipe_bifs:nstack_used_size(),
    %% io:format("Size0 ~w, Size1 ~w\n", [Size0, Size1]),
    if Size1 > Size0+?SIZE_INCREASE ->
	 exit(?MODULE);
       true -> []
    end;
app0(N, Size) ->
    apply(?MODULE, app0, [N-1, Size]).
