%%%-------------------------------------------------------------------
%%% File    : load_bug1.erl
%%% Author  : Per Gustafsson <pergu@dhcp-12-245.it.uu.se>
%%% Description : This test case uncovers a bug which makes native 
%%%               compiled code call a generation too old beam code 
%%% Created : 15 Jun 2004 by Per Gustafsson <pergu@dhcp-12-245.it.uu.se>
%%%-------------------------------------------------------------------
-module(load_bug1).

-export([test/0, compile/1]).

compile(Flags) ->
  code:purge(tmp),
  code:delete(tmp),
  hipe:c(?MODULE,Flags).

test() ->
  old=compile_and_run(write_file(<<"old">>)),
  new=compile_and_run(write_file(<<"new">>)),
  ok.

compile_and_run(FN) ->
  c:c(FN, [{outdir, "/tmp/"}]),
  tmp:tmp().

write_file(Ret) ->  
  Prog = <<"-module(tmp).\n",
	  "-export([tmp/0]).\n",
	  "tmp() ->\n",
	  Ret/binary,".\n">>,
  FN="/tmp/tmp.erl",
  file:write_file(FN,Prog),
  FN.


