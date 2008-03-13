-module(dialyzer_01).
-export([test/0]).

-spec(test/0 :: () -> {'ok',[_]}).
test() ->
  Files = filelib:wildcard("di*.erl"),
  dialyzer:run([{files,Files},{from,src_code}]).

%% test() ->
%%   Ebins = filelib:wildcard(filename:join(code:lib_dir(), "typer/ebin")),
%%   dialyzer:run([{files,Ebins}]).
