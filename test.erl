%% ====================================================================
%%  Filename : test.erl
%%  Module   : test
%%  Purpose  : To run a HiPE test module and write the result to a file
%%  Notes    : 
%%  History  : 1999-12-02 Erik Johansson (happi@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2004/01/19 15:32:48 $
%%    $Revision: 1.7 $
%% ====================================================================
%% Exported functions (short description):
%%
%% start(Module,CompilerOptions,File) 
%% 
%%  Executes a test module in this way:
%%   1. Compiles the module Module.erl to Module.beam. 
%%   2. Then the function test/0 in Module is called.
%%   3. Then Module is compiled to native code with the flags CompilerOptions
%%   4. Then the function test/0 in Module is called.
%%   5. Finally the a tuple with the results from both Module:test() executions
%%      are written to the file File.
%%
%% start(Module,File) 
%%
%%  Does the same as start/3 but with default compiler options.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(test).
-export([start/3,start/2]).

start(Module,File) ->
    start(Module,[o2],File).

start(Module,CompilerOptions,File) ->
    IC = (catch compile:file(Module)),
    IR = (catch Module:test()),

    case proplists:get_bool(no_native,CompilerOptions) of
	false ->
	    HC = (catch Module:compile(CompilerOptions)),
	    HR = (catch Module:test());
	true ->
	    {ok,HostName} = inet:gethostname(),
	    FullHostName = HostName ++ "." ++ inet_db:res_option(domain),
	    {ok,Bin} = file:read_file(atom_to_list(Module) ++ "_old@" ++ FullHostName),
	    {ok,Tokens,_} = erl_scan:string(binary_to_list(Bin) ++ "."),
	    {ok,{{{_,_IR},{native_result,HR}},
		{{_,_IC},{native_compile,HC}}}} = erl_parse:parse_term(Tokens)
    end,
    Result = {{{emu_result,IR},{native_result,HR}},
              {{emu_compile,IC},{native_compile,HC}}},
    write(File,Result).

write(File,Result) ->
    case file:open(File,write) of
	{ok,Dev} ->
	    io:write(Dev,Result),
	    file:close(Dev);
	_ ->
	    true
    end.

