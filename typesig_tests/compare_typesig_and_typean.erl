%%%-------------------------------------------------------------------
%%% File    : compare_typesig_and_typean.erl
%%% Author  : Tobias Lindahl <tobiasl@it.uu.se>
%%% Description : 
%%%
%%% Created : 21 Dec 2004 by Tobias Lindahl <tobiasl@it.uu.se>
%%%-------------------------------------------------------------------
-module(compare_typesig_and_typean).

-export([doit/1]).

doit([Module]) ->
  wait_init(),
  {ok, _, Code} = compile:file(Module,[to_core,binary,export_all]), 
  TypeAnSigs = get_typean_sigs(Code),
  TypeSigSigs = cerl_typesig:get_export_signatures(Code),
  compare_sigs(Module, TypeSigSigs, TypeAnSigs).

get_typean_sigs(Code0) ->
  Code = cerl_typean:core_transform(Code0, []),
  Tree = cerl:from_records(Code),
  Exports = cerl:module_exports(Tree),
  [{cerl:var_name(Fun), 
    proplists:get_value(type, cerl:get_ann(Fun))} || Fun <- Exports].

compare_sigs(Module, TypeSigSigs, TypeAnSigs) ->
  compare_sigs_1(list_to_atom(Module), 
		 lists:keysort(1, TypeSigSigs),
		 lists:keysort(1, TypeAnSigs)).

compare_sigs_1(M, [{{F, A}, Type1}|Left1], [{{F, A}, Type2}|Left2]) ->
  case (F == module_info andalso A =< 1) of
    true -> ok;	%% no need to show the module_info/[0,1] type signatures
    false ->
      case erl_types:t_is_subtype(Type1, Type2) of
        true ->
          io:format("~w : OK\n typesig: ~s\n  typean: ~s\n", 
		    [{M, F, A}, 
		     erl_types:t_to_string(Type1),
		     erl_types:t_to_string(Type2)]);
        false ->
          io:format("~w : differ!!!\n typesig: ~s\n  typean: ~s\n", 
		    [{M, F, A}, 
		     erl_types:t_to_string(Type1),
		     erl_types:t_to_string(Type2)])
      end
  end,
  compare_sigs_1(M, Left1, Left2);
compare_sigs_1(_M, [], []) ->
  ok.

wait_init() ->
  case erlang:whereis(code_server) of
    undefined ->
      erlang:yield(),
      wait_init();
    _ ->
      ok
  end.
