%%%-------------------------------------------------------------------
%%% File    : load_bug3.erl
%%% Author  : Per Gustafsson <pergu@dhcp-12-245.it.uu.se>
%%% Description : This test case uncovers a bug which makes native 
%%%               compiled code call a generation too old beam code.
%%%               When apply is used to make the call.     
%%% Created : 15 Jun 2004 by Per Gustafsson <pergu@dhcp-12-245.it.uu.se>
%%%-------------------------------------------------------------------
-module(load_bug3).

-export([test/0, compile/1]).

compile(Flags) ->
  hipe:c(?MODULE,Flags).

test() ->
  ModNameString = form_unique_modname(),
  ModName = list_to_atom(ModNameString),
  FN = write_file(ModNameString, <<"old">>),
  old = compile_and_run(FN, ModName),
  FN = write_file(ModNameString, <<"new">>),
  new = compile_and_run(FN, ModName),
  ok = file:delete(list_to_atom(FN)),
  ok.

form_unique_modname() ->
  {N1,N2,N3} = erlang:now(),
  "mod_" ++ integer_to_list(N1) ++ integer_to_list(N2) ++ integer_to_list(N3).

compile_and_run(FN, ModName) ->
  c:c(FN, [{outdir, "/tmp/"}]),
  ModName:tmp().

write_file(ModNameString, Ret) ->
  ModBin = list_to_binary(ModNameString),
  Prog = <<"-module(", ModBin/binary, ").\n",
	   "-export([tmp/0]).\n",
	   "tmp() ->\n", Ret/binary,".\n">>,
  FN = "/tmp/" ++ ModNameString ++ ".erl",
  file:write_file(FN, Prog),
  FN.

