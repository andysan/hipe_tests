%%%-------------------------------------------------------------------
%%% File    : compare_analyses.erl
%%% Author  : Tobias Lindahl <tobiasl@it.uu.se>
%%% Description : 
%%%
%%% Created : 21 Dec 2004 by Tobias Lindahl <tobiasl@it.uu.se>
%%%-------------------------------------------------------------------
-module(compare_analyses).

-export([doit/1]).

doit([Module]) when is_list(Module) ->
  wait_init(),
  {ok, _, Code} = compile:file(Module,[to_core,binary]), 
  TypeAnSigs = get_typean_sigs(Code),
  TypeSigSigs = dialyzer_typesig:get_top_level_signatures(Code),
  DFSigs = get_df_sigs(Code),
  compare_sigs(Module, TypeSigSigs, DFSigs, TypeAnSigs).

get_typean_sigs(Code0) ->
  Code = cerl_typean:core_transform(Code0, []),
  Tree = cerl:from_records(Code),
  Defs = cerl:module_defs(Tree),
  [{cerl:var_name(Var), 
    proplists:get_value(type, cerl:get_ann(Var))} || {Var, _} <- Defs].

get_df_sigs(Code) ->
  Tree = dialyzer_dataflow:annotate_module(Code),
  Defs = cerl:module_defs(Tree),
  [{cerl:var_name(Var), 
    proplists:get_value(type, cerl:get_ann(Var))} || {Var, _} <- Defs].

compare_sigs(Module, TypeSigSigs, DFSigs, TypeAnSigs) ->
  compare_sigs_1(list_to_atom(Module), 
		 lists:keysort(1, TypeSigSigs),
		 lists:keysort(1, DFSigs),
		 lists:keysort(1, TypeAnSigs)).

compare_sigs_1(M, 
	       [{{F, A}, TSType}|TSLeft], 
	       [{{F, A}, DFType}|DFLeft], 
	       [{{F, A}, TAType}|TALeft]) ->
  case (F == module_info andalso A =< 1) of
    true -> ok;	%% no need to show the module_info/[0,1] type signatures
    false ->
      case erl_types:t_is_subtype(TSType, DFType) 
	andalso erl_types:t_is_subtype(DFType, TAType) of
        true ->
          io:format("~w : OK\n typesig:  ~s\n dataflow: ~s\n   typean: ~s\n", 
		    [{M, F, A}, 
		     erl_types:t_to_string(TSType),
		     erl_types:t_to_string(DFType),
		     erl_types:t_to_string(TAType)]);
        false ->
          io:format("~w : differ!!!\n typesig:  ~s\n"
		    " dataflow: ~s\n   typean: ~s\n", 
		    [{M, F, A}, 
		     erl_types:t_to_string(TSType),
		     erl_types:t_to_string(DFType),
		     erl_types:t_to_string(TAType)])
      end
  end,
  compare_sigs_1(M, TSLeft, DFLeft, TALeft);
compare_sigs_1(_M, [], [], []) ->
  ok.

wait_init() ->
  case erlang:whereis(code_server) of
    undefined ->
      erlang:yield(),
      wait_init();
    _ ->
      ok
  end.
