-module(catch_crash).
-export([test/0,compile/1]).

-define(try_match(E),
      catch ?MODULE:bar(),
	{'EXIT', {{badmatch, nomatch}, _}} = (catch E = nomatch)).

test() ->
    ?try_match(a),
    ?try_match(42),
    ?try_match({a, b, c}),
    ?try_match([]),
    ?try_match(1.0),
    ok.

%% small_test() ->
%%    catch crash:bar(),
%%    io:format("Before\n",[]),
%%    hipe_bifs:show_nstack(self()),
%%    io:format("After\n",[]),
%%    garbage_collect().

compile(Flags) ->
    hipe:c(?MODULE,Flags).
