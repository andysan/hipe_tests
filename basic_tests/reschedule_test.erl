%%% $Id: reschedule_test.erl,v 1.1 2003/12/21 23:17:51 mikpe Exp $
%%% Check that RESCHEDULE returns from BIFs work.

-module(reschedule_test).
-export([test/0, compile/1]).

compile(Flags) ->
    hipe:c(?MODULE, Flags).

test() ->
    First = self(),
    Second = spawn(fun() -> doit(First) end),
    receive
	Second ->
	    []
    end,
    receive
    after 1000 ->
	    []
    end,
    erlang:resume_process(Second),
    ok.

doit(First) ->
    First ! self(),
    hipe_bifs:test_reschedule(1).
