%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename : 	comp1.erl
%%  Module   :	comp1
%%  Purpose  :  Tests whether the HiPE compiler works.
%%  History  :	* 2000-10-31 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2003/04/17 13:36:05 $
%%    $Revision: 1.8 $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(comp1).
-export([test/0,fast_test/0,compile/1]).


test() ->
    %% statistics(runtime),
    t(),
    %% {_,Time1} = statistics(runtime),
    t(),
    %% {_,Time2} = statistics(runtime),
    %% io:format("Time1 = ~w\nTime1 = ~w\n Diff = ~w\n",[Time1,Time2,Time1-Time2]),
    {ok,"hipe"}.

t() ->
    [ do_me(Mod) || Mod <- simple_ones() ++ mk_fun() ].

do_me(Mod) ->
    hipe:c(Mod,[verbose] ++ get_comp_opts()).

get_comp_opts() ->
    {ok,Tokens,_} = erl_scan:string(os:getenv("HiPE_COMP_OPTS") ++ "."),
    {ok,CompFlags} = erl_parse:parse_term(Tokens),
    CompFlags. 

fast_test() ->
%%    file:set_cwd('../../otp/lib/hipe/ebin/'),
    [ do_it(Mod) || Mod <- simple_ones() ++ mk_fun() ].

do_it(Mod) ->
    case catch hipe:load_file(Mod) of
	{module,Mod} ->
	    io:format("Loaded module ~p~n",[Mod]),
	    {ok,Mod};
        _ ->
	    hipe:c(Mod)
    end.

compile(Flags) ->
    hipe:c(?MODULE,Flags).

simple_ones() ->
    [hipe_adj_list, hipe_adj_set,
     hipe_bb, hipe_beam_vectors, hipe_bif, hipe_bwd_cprop,
     hipe_ceach, hipe_coalescing_regalloc, hipe_converters,
     hipe_data_pp, hipe_dead_code, hipe_degree, hipe_df, hipe_dict_hash,
     hipe_domtree, % WAS COMMENTED OUT
     hipe_gb_hash, hipe_gen_cfg, hipe_gensym, hipe_graph_coloring_regalloc,
     hipe_hash,
     hipe_icode, hipe_icode2rtl, hipe_icode_binary_pass,
     hipe_icode_cfg, hipe_icode_cleanup, hipe_icode_ebb, hipe_icode_heap_test,
     hipe_icode_liveness, hipe_icode_pp, hipe_icode_primops,
     hipe_icode_prop, hipe_icode_ssa, hipe_icode_ssa_check,
     hipe_icode_ssa_copy_prop, hipe_icode_ssa_phi, hipe_icode_ssa_propagate,
     hipe_icode_ssa_rename, hipe_icode_type,
     hipe_ig, hipe_ig_moves,
     %% hipe_internal, % SHOULD NEVER BE COMPILED TO NATIVE CODE
     hipe_jit,
     hipe_ls_regalloc,
     hipe_moves,
     hipe_node_sets,
     hipe_profile, hipe_pure_hash, hipe_pure_ufind, hipe_pure_vectors,
     hipe_rtl2sparc, hipe_rtl_arch, hipe_rtl_arith, hipe_rtl_arith_32,
     hipe_rtl_bs_ops, hipe_rtl_exceptions, hipe_rtl_gctests, hipe_rtl_guardops,
     hipe_rtl_inline_bs_ops, hipe_rtl_mk_switch, hipe_rtl_primops,
     hipe_rtl_prop, hipe_rtl_ssa_check, hipe_rtl_varmap,
     hipe_schedule_prio, hipe_sparc_assemble, hipe_sparc_assert,
     hipe_sparc_caller_saves, hipe_sparc_ebb, hipe_sparc_frame,
     hipe_sparc_linker, hipe_sparc_multimove,
     hipe_sparc_op, hipe_sparc_opt_frame,
     hipe_sparc_pp, hipe_sparc_prop, hipe_sparc_prop_env,
     hipe_sparc_ra, hipe_sparc_ra_coalescing, hipe_sparc_ra_cs,
     hipe_sparc_ra_fp_ls, hipe_sparc_ra_fp_naive, hipe_sparc_ra_graph_color,
     hipe_sparc_ra_ls, hipe_sparc_ra_memory, hipe_sparc_ra_post_cs,
     hipe_sparc_ra_post_ls, hipe_sparc_ra_post_ls_fp,
     hipe_sparc_ra_postconditions, hipe_sparc_registers, hipe_sparc_size,
     hipe_sparc_specific, hipe_sparc_specific_fp, hipe_sparc_stack_descriptors,
     hipe_spill_minimize, hipe_spillcost,
     hipe_tagscheme, hipe_target_machine, hipe_temp_map,
     hipe_timer, hipe_timing, hipe_tool,
     hipe_ufind, hipe_ultra_mod2, hipe_ultra_prio, hipe_update_catches,
     hipe_vector, hipe_vector_ufind, hipe_vectors, hipe_vectors_wrapper,
     hipe_vhash,
     hipe_rtl_to_x86, hipe_x86, hipe_x86_assemble, hipe_x86_cfg,
     hipe_x86_defuse, hipe_x86_encode, hipe_x86_finalise, hipe_x86_float,
     hipe_x86_frame, hipe_x86_liveness, hipe_x86_pp, hipe_x86_ra_coalescing,
     hipe_x86_ra_dummy, hipe_x86_ra_fp_ls, hipe_x86_ra_graph_color,
     hipe_x86_ra_ls, hipe_x86_ra_ls_postconditions,
     hipe_x86_ra_measure_live_regs, hipe_x86_ra_postconditions,
     hipe_x86_registers, hipe_x86_specific, hipe_x86_specific_fp,
     cerl_closurean, cerl_hipeify, cerl_lambdalift,
     cerl_pmatch, cerl_to_icode, cerl_typean,
     erl_bif_types, erl_types
    ].

mk_fun() ->
    [hipe, hipe_main,
     hipe_beam_to_icode,
     hipe_consttab,
     hipe_finalize,
     hipe_hot_cold,
     hipe_reg_worklists,
     hipe_rtl, hipe_rtl_cfg, hipe_rtl_cse, hipe_rtl_ebb, hipe_rtl_liveness,
     hipe_schedule, hipe_sparc, hipe_sparc_cfg, hipe_sparc_liveness,
     hipe_sparc_saver  % WHY IS THIS ALWAYS COMPILED ??
    ].
