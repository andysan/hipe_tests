%% 
%%     $Id: undef_func.erl,v 1.4 2003/12/07 23:21:25 kostis Exp $
%%

-module(undef_func).

-export([test/0,compile/1]).

compile(_Options) ->
    ok. %% No native code compilation.

test() ->
    Root = code:root_dir(),
    HiPE = Root ++ "/lib/hipe",
    Path = [Root ++ D || D <- ["/lib/kernel/ebin",
			       "/lib/stdlib/ebin",
			       "/lib/compiler/ebin",
			       %% gs is needed for the hipe_tool
			       "/lib/gs/ebin"]],
    Server = hipe_testsuite,
    xref:start(Server),
    xref:set_default(Server, [{verbose,false},{warnings,false}]),
    xref:set_library_path(Server, Path),
    {ok,_App} = xref:add_application(Server, HiPE),
    {ok,Undef} = xref:analyze(Server, undefined_function_calls),
    {ok,UnusedLocals} = xref:analyze(Server, locals_not_used),
    {ok,UnusedExports} = xref:analyze(Server, exports_not_used),
    ReallyUnusedExports = lists:subtract(UnusedExports, used_exports()),
    catch xref:stop(Server),
    U1 = case Undef of
	     [] -> no_undefined_functions;
	     _ ->
		 lists:foreach(fun ({MFA1,MFA2}) ->
				  io:format("~s calls undefined ~s\n",
					    [format_mfa(MFA1),
					     format_mfa(MFA2)])
			       end, Undef),
		 {undefined_functions_in_hipe,Undef}
	 end,
    U2 = case UnusedLocals of
	     [] -> no_unused_local_functions;
	     _ ->
		 lists:foreach(fun (MFA) ->
				  io:format("unused: ~s\n", [format_mfa(MFA)])
			       end, UnusedLocals),
		 {unused_locals_in_hipe,UnusedLocals}
	 end,
    U3 = case ReallyUnusedExports of
	     [] -> no_unused_exported_functions;
	     _ ->
		 lists:foreach(fun (MFA) ->
				  io:format("exported but unused: ~s\n",
					    [format_mfa(MFA)])
			       end, UnusedLocals),
		 {unused_locals_in_hipe,UnusedLocals}
	 end,
    {U1,U2,U3}.

%%% "(XC - UC) || (XU - X - B)"

format_mfa({M,F,A}) ->
    io_lib:format("~s:~s/~p", [M,F,A]).

%%=====================================================================
%% Below appears some hard-coded information about exported functions
%% which are used either outside the hipe application, or are used
%% in the form of apply calls and xref does not discover this fact.
%%=====================================================================

used_exports() ->
    application_interface() ++ exports_used_as_remote_apply_calls().

%%
%% This is the list of all functions which are supposed to be
%% accessible by the user or by other applications.
%%
application_interface() ->
    [
     {hipe,help,0},
     {hipe,help_option,1},
     {hipe,help_options,0},
     {hipe,compile,1},
     {hipe,compile,2},
     {hipe,compile,4},	%% used by compiler/src/compile.erl
     {hipe,f,1},
     {hipe,f,2},
     {hipe,file,1},
     {hipe,file,2},
     {hipe,load,1},
     {hipe,load,2},
     {hipe,has_hipe_code,1},
     {hipe,help_debug_options,0},
     {hipe,version,0},
     {hipe_ceach,c,1},
     {hipe_ceach,c,2},
     {hipe_ceach,c,3},
     {hipe_jit,start,0},
     {hipe_tool,start,0},
     {erl_bif_types,type,3}, %% exported for testing purposes
     {cerl_typean,analyze,1} %% exported for testing purposes
    ].

%%
%% I would love if there were a way for the following to be discovered
%% automatically, but currently there does not appear to be any...
%%
exports_used_as_remote_apply_calls() ->
    [
     {hipe_sparc_specific,analyze,1},
     {hipe_sparc_specific,bb,2},
     {hipe_sparc_specific,args,1},
     {hipe_sparc_specific,labels,1},
     {hipe_sparc_specific,livein,2},
     {hipe_sparc_specific,liveout,2},
     {hipe_sparc_specific,succ_map,1},
     {hipe_sparc_specific,uses,1},
     {hipe_sparc_specific,defines,1},
     {hipe_sparc_specific,def_use,1},
     {hipe_sparc_specific,is_arg,1},   %% used by hipe_ls_regalloc
     {hipe_sparc_specific,is_move,1},
     {hipe_sparc_specific,is_fixed,1}, %% used by hipe_graph_coloring_regalloc
     {hipe_sparc_specific,is_global,1},
     {hipe_sparc_specific,is_precolored,1},
     {hipe_sparc_specific,reg_nr,1},
     {hipe_sparc_specific,non_alloc,1},
     {hipe_sparc_specific,allocatable,0},
     {hipe_sparc_specific,physical_name,1},
     {hipe_sparc_specific,all_precolored,0},
     {hipe_sparc_specific,new_spill_index,1},
     {hipe_sparc_specific,var_range,1},
     {hipe_sparc_specific,breadthorder,1},
     {hipe_sparc_specific,postorder,1},
     {hipe_sparc_specific,reverse_postorder,1},
     {hipe_sparc_specific,preorder,1},
     {hipe_sparc_specific,inorder,1},
     {hipe_sparc_specific,reverse_inorder,1},
     {hipe_sparc_specific,predictionorder,1},

     {hipe_sparc_specific_fp,analyze,1},
     {hipe_sparc_specific_fp,bb,2},
     {hipe_sparc_specific_fp,args,1},
     {hipe_sparc_specific_fp,labels,1},
     {hipe_sparc_specific_fp,livein,2},
     {hipe_sparc_specific_fp,liveout,2},
     {hipe_sparc_specific_fp,succ_map,1},
     {hipe_sparc_specific_fp,uses,1},
     {hipe_sparc_specific_fp,defines,1},
     {hipe_sparc_specific_fp,is_arg,1},
     {hipe_sparc_specific_fp,is_global,1},
     {hipe_sparc_specific_fp,reg_nr,1},
     {hipe_sparc_specific_fp,physical_name,1},
     {hipe_sparc_specific_fp,new_spill_index,1},
     {hipe_sparc_specific_fp,breadthorder,1},
     {hipe_sparc_specific_fp,postorder,1},
     {hipe_sparc_specific_fp,reverse_postorder,1},

     {hipe_x86_specific,analyze,1},
     {hipe_x86_specific,bb,2},
     {hipe_x86_specific,args,1},
     {hipe_x86_specific,labels,1},
     {hipe_x86_specific,livein,2},
     {hipe_x86_specific,liveout,2},
     {hipe_x86_specific,succ_map,1},
     {hipe_x86_specific,uses,1},
     {hipe_x86_specific,defines,1},
     {hipe_x86_specific,def_use,1},
     {hipe_x86_specific,is_arg,1},    %% used by hipe_ls_regalloc
     {hipe_x86_specific,is_move,1},
     {hipe_x86_specific,is_fixed,1},  %% used by hipe_graph_coloring_regalloc
     {hipe_x86_specific,is_global,1},
     {hipe_x86_specific,is_precolored,1},
     {hipe_x86_specific,reg_nr,1},
     {hipe_x86_specific,non_alloc,1},
     {hipe_x86_specific,allocatable,0},
     {hipe_x86_specific,physical_name,1},
     {hipe_x86_specific,all_precolored,0},
     {hipe_x86_specific,new_spill_index,1},
     {hipe_x86_specific,var_range,1},
     {hipe_x86_specific,breadthorder,1},
     {hipe_x86_specific,postorder,1},
     {hipe_x86_specific,reverse_postorder,1},

     {hipe_x86_specific_fp,analyze,1},
     {hipe_x86_specific_fp,bb,2},
     {hipe_x86_specific_fp,args,1},
     {hipe_x86_specific_fp,labels,1},
     {hipe_x86_specific_fp,livein,2},
     {hipe_x86_specific_fp,liveout,2},
     {hipe_x86_specific_fp,succ_map,1},
     {hipe_x86_specific_fp,uses,1},
     {hipe_x86_specific_fp,defines,1},
     {hipe_x86_specific_fp,is_global,1},
     {hipe_x86_specific_fp,reg_nr,1},
     {hipe_x86_specific_fp,physical_name,1},
     {hipe_x86_specific_fp,breadthorder,1},
     {hipe_x86_specific_fp,postorder,1},
     {hipe_x86_specific_fp,reverse_postorder,1}
    ].
