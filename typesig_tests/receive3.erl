-module(receive3).
-export([start/0]).

-record(state, {mode=start, time=1000}).

%% @spec start() -> pid()
start() ->
  spawn(fun() -> loop(#state{}) end).

loop(State) ->
  case State#state.mode of
    start ->
      start(State);
    wait ->
      wait(State);
    sleep ->
      ok
  end.

start(State) ->
  loop(State#state{mode=wait}).

wait(State) ->
  receive 
    quit -> ok
  after State#state.time ->
    lists:foreach(fun(M) -> hipe:c(M) end, [foo])
  end,
  loop(State#state{mode=sleep}).
