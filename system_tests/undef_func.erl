%% 
%%     $Id: undef_func.erl,v 1.2 2003/11/30 23:40:20 kostis Exp $
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
