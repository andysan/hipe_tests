%% ``The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved via the world wide web at http://www.erlang.org/.
%% 
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%% 
%% The Initial Developer of the Original Code is Ericsson Utvecklings AB.
%% Portions created by Ericsson are Copyright 1999, Ericsson Utvecklings
%% AB. All Rights Reserved.''
%% 
%%     $Id: undef_func.erl,v 1.1 2003/07/01 13:28:45 richardc Exp $
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
			       "/lib/gs/ebin"]],
    Server = hipe_testsuite,
    xref:start(Server),
    xref:set_default(Server, [{verbose,false},{warnings,false}]),
    xref:set_library_path(Server, Path),
    {ok,_App} = xref:add_application(Server, HiPE),
    {ok,Undef} = xref:analyze(Server, undefined_function_calls),
    catch xref:stop(Server),
    case Undef of
	[] -> no_undefined_functions;
	_ ->
	    lists:foreach(fun ({MFA1,MFA2}) ->
				  io:format("~s calls undefined ~s\n",
					    [format_mfa(MFA1),
					     format_mfa(MFA2)])
			  end, Undef),
	    {undefined_functions_in_hipe, Undef}
    end.

%%% "(XC - UC) || (XU - X - B)"

format_mfa({M,F,A}) ->
    io_lib:format("~s:~s/~p", [M,F,A]).
