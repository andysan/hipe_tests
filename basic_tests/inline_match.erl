%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(inline_match).
-export([test/0,compile/1]).

-compile({inline, [{to_objects,3}]}).

compile(O) ->
  hipe:c(?MODULE,O).

test() ->
  {test1(a,{binary, foo, set},c),
   test2(a,{binary, foo, set},c),
   test3(a,{binary, foo, set},c)}.

%% Inlined.
to_objects(Bin, {binary, _, set}, Ts) ->
  <<ObjSz0:32, T/binary>> = Bin,
  %% {A,B} = Bin,
  ok;
to_objects(<<ObjSz0:32, T/binary>> ,_,_) ->
  ok;
to_objects(Bin, _, Ts) ->
  ok.

%% Not Inlined.
fto_objects(Bin, {binary, _, set}, Ts) ->
  <<ObjSz0:32, T/binary>> = Bin,
  %% {A,B} = Bin,
  ok;
fto_objects(<<ObjSz0:32, T/binary>> ,_,_) ->
  ok;
fto_objects(Bin, _, Ts) ->
  ok.


%% Inlined
test1(KeysObjs, C, Ts) ->
  case catch to_objects(KeysObjs, C, Ts) of
     {'EXIT', _} ->
      bad_object;
    ok ->
      ok
  end.

%% "Inlined" by hand
test2(KeysObjs, C, Ts) ->
  case catch (case C of
  {binary, _, set} ->
    <<ObjSz0:32, T/binary>> = KeysObjs;
  _ -> ok
       end) of
     {'EXIT', _} ->
      bad_object;
    ok ->
      ok
  end.

%% Not inlined
test3(KeysObjs, C, Ts) ->
  case catch fto_objects(KeysObjs, C, Ts) of
     {'EXIT', _} ->
      bad_object;
    ok ->
      ok
  end.
