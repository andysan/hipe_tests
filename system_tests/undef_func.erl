%% 
%%     $Id: undef_func.erl,v 1.3 2003/12/01 16:49:47 kostis Exp $
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
    % _ReallyUnusedExports = lists:subtract(UnusedExports, used_exports()),
    _ReallyUnusedExports = lists:subtract(exclude_exports(UnusedExports,[]),
					  used_exports()),
    % _H = _ReallyUnusedExports,
    _H = process_exports(_ReallyUnusedExports,[]),
    % io:format("~w\nTotal = ~w\n", [_H,length(_H)]),
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
		 io:format("~w\n", [UnusedLocals]),
		 lists:foreach(fun (MFA) ->
				       io:format("unused: ~s\n",
						 [format_mfa(MFA)])
			       end, UnusedLocals),
		 {unused_locals_in_hipe,UnusedLocals}
	 end,
    {U1,U2}.

%%% "(XC - UC) || (XU - X - B)"

format_mfa({M,F,A}) ->
    io_lib:format("~s:~s/~p", [M,F,A]).

process_exports([{hipe_x86,F,A}|Ex],FA) ->
    process_exports(Ex,[{F,A}|FA]);
process_exports([_|Ex],FA) ->
    process_exports(Ex,FA);
process_exports([],FA) ->
    FA.

exclude_exports([{hipe_icode,_,_}|Ex],FA) ->
    exclude_exports(Ex,FA);
exclude_exports([{hipe_icode_cfg,_,_}|Ex],FA) ->
    exclude_exports(Ex,FA);
exclude_exports([{hipe_rtl,_,_}|Ex],FA) ->
    exclude_exports(Ex,FA);
exclude_exports([{hipe_rtl_cfg,_,_}|Ex],FA) ->
    exclude_exports(Ex,FA);
exclude_exports([{hipe_sparc,_,_}|Ex],FA) ->
    exclude_exports(Ex,FA);
exclude_exports([{hipe_sparc_cfg,_,_}|Ex],FA) ->
    exclude_exports(Ex,FA);
exclude_exports([{hipe_sparc_op,_,_}|Ex],FA) ->
    exclude_exports(Ex,FA);
exclude_exports([{hipe_sparc_ra_cs,_,_}|Ex],FA) ->
    exclude_exports(Ex,FA);
exclude_exports([{hipe_x86,_,_}|Ex],FA) ->
    exclude_exports(Ex,FA);
exclude_exports([{hipe_x86_cfg,_,_}|Ex],FA) ->
    exclude_exports(Ex,FA);
exclude_exports([{hipe_gen_cfg,_,_}|Ex],FA) ->
    exclude_exports(Ex,FA);
exclude_exports([{erl_types,_,_}|Ex],FA) ->
    exclude_exports(Ex,FA);
exclude_exports([E|Ex],FA) ->
    exclude_exports(Ex,[E|FA]);
exclude_exports([],FA) ->
    FA.

used_exports() ->
    [
     {hipe,help,0},
     {hipe,help_option,1},
     {hipe,help_options,0},
     {hipe,compile,4},	%% used by compiler/src/compile.erl
     {hipe_tool,start,0}
    ].
