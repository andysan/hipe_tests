%% ====================================================================
%%  Filename : test.erl
%%  Module   : test
%%  Purpose  : To run a HiPE test module and write the result to a file
%%  Notes    : 
%%  History  : 1999-12-02 Erik Johansson (happi@csd.uu.se): Created.
%% CVS:
%%    $Author: richardc $
%%    $Date: 2001/04/19 17:47:04 $
%%    $Revision: 1.2 $
%% ====================================================================
%% Exported functions (short description):
%%
%% start(Module,CompilerOptions,File) 
%% 
%%  Executes a test module in htis way:
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
    JC = (catch compile:file(Module)),
    J1 = (catch Module:test()),

    Result = 
	case property_lists:is_defined(no_native,CompilerOptions) of
	    false ->
		HC = (catch Module:compile(CompilerOptions)),
		H1 = (catch Module:test()),
		{{{emu_result,J1},{native_result,H1}},
		 {{emu_compile,JC},{native_compile,HC}}};
	    true ->
		{{{emu_result,J1},{native_result,J1}},
		 {{emu_compile,JC},{native_compile,JC}}}
	end,
    write(File,Result).

write(File,Result) ->
    case file:open(File,write) of
	{ok,Dev} ->
	    io:write(Dev,Result),
	    file:close(Dev);
	_ ->
	    true
    end.

