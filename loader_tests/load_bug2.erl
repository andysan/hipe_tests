%%% -*- erlang-indent-level: 2 -*-
%%% $Id: load_bug2.erl,v 1.1 2004/06/16 15:49:40 mikpe Exp $
%%% Module loading fails to invalidate all paths
%%% to obsolete code.

-module(load_bug2).
-export([test/0, compile/1]).

compile(Flags) ->
  code:purge(tmp),
  code:delete(tmp),
  hipe:c(?MODULE,Flags).

test() ->
  true = write_compile_run(prog1()),
  case write_compile_run(prog2()) of
    {'EXIT',{undef,[{tmp,tmp,[]}|_]}} -> ok;
    true -> error % we get true from the stale code
  end.

write_compile_run(Prog) ->
  FN = "/tmp/tmp.erl",
  file:write_file(FN, Prog),
  c:c(FN, [native,{outdir, "/tmp/"}]),
  catch(tmp:tmp()).

prog1() ->
  <<"-module(tmp).\n",
    "-export([tmp/0, tmp2/0]).\n",
    "tmp() -> true.\n", % hipe_bifs:in_native() is currently broken
    "tmp2() -> 27.\n">>.

prog2() ->
  <<"-module(tmp).\n",
    "-export([tmp2/0]).\n",
    "tmp2() -> 27.\n">>.
