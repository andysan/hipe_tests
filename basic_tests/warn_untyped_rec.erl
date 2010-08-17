%%===========================================================================
%% Checks that there are no spurious warnings for untyped records
%% (at some point there used to be a warning for #rec0{} being untyped).
%%===========================================================================
-module(warn_untyped_rec).
-export([test/0, compile/1]).

-compile(warn_untyped_record).

-record(rec0, {}).
-record(rec1, {a :: integer()}).

test() ->
  foo(#rec0{}, #rec1{}).

foo(R0, R1) when tuple_size(R0) < tuple_size(R1) -> ok;
foo(_, _) -> not_ok.

compile(Opts) ->
  hipe:c(?MODULE, Opts).
