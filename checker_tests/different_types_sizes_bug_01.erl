%% -*- erlang-indent-level: 2 -*-

%% @author Daniel Luna <luna@update.uu.se>
%% @copyright 2008 Daniel Luna
%% 
%% @doc 
%% 

-module(different_types_sizes_bug_01).
-export([test/0]).

test() ->
  case {atom, atom} of
    {atom, atom} -> ok
  end.

do_load_binary(Module,File,Binary,Db) ->
    case {modp(Module),modp(File)} of
	{true, true} when is_binary(Binary) ->
	    case erlang:module_loaded(code_aux:to_atom(Module)) of
		true ->
		    code_aux:do_purge(Module);
		false ->
		    ok
	    end,
	    try_load_module(File, Module, Binary, Db);
	_ ->
	    {error, badarg}
    end.

modp(Atom) when is_atom(Atom) -> true;
modp(List) when is_list(List) -> int_list(List);
modp(_)                       -> false.

int_list([H|T]) when is_integer(H) -> int_list(T);
int_list([_|_])                    -> false;
int_list([])                       -> true.

try_load_module(_, _, _, _) -> ok.

%%  catch code_server:a().
