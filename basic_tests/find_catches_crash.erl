%%======================================================================
%% File that results in a native code compiler crash in the code of
%% hipe_icode_exceptions:find_catches/1 when compiling foo/2.
%%======================================================================
-module(find_catches_crash).
-export([test/0, compile/1]).

test() ->
    42 = foo(a, false),
    ok.

foo(X, Y) ->
    case X of
	a when Y =:= true ->
	    catch bar(X),
	    X;
	b when Y =:= true ->
	    catch bar(X),
	    X;
	a ->
	    catch bar(X),
	    42;
	b ->
	    catch bar(X),
	    42
    end.

bar(X) -> X.

compile(Opts) ->
    hipe:c(?MODULE, Opts).
