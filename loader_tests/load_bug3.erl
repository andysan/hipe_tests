%%%-------------------------------------------------------------------
%%% File    : load_bug3.erl
%%% Author  : Kostis Sagonas <kostis@it.uu.se>
%%% Description : This test case uncovers a bug which makes native 
%%%               compiled apply calls call BEAM code which is a
%%%               generation too old.
%%% Created : 18 Jun 2004 by Kostis Sagonas <kostis@it.uu.se>
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
  ModName:tmp(). % NOTE: Modname is statically unknown: this is an apply call

write_file(ModNameString, Ret) ->
  ModBin = list_to_binary(ModNameString),
  Prog = <<"-module(", ModBin/binary, ").\n",
	   "-export([tmp/0]).\n",
	   "tmp() ->\n", Ret/binary,".\n">>,
  FN = "/tmp/" ++ ModNameString ++ ".erl",
  file:write_file(FN, Prog),
  FN.

