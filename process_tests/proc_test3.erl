%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename :  proc_test3.erl
%%  Purpose  :  Checks correct exit of processes.
%%  History  :  * 2001-08-13 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: pergu $
%%    $Date: 2004/07/30 13:26:54 $
%%    $Revision: 1.4 $
%% ====================================================================

-module(proc_test3).
-export([test/0,compile/1,my_exit/1]).

test() ->
    Res = exit_2_catch(),
    Res = exit_2_catch(),
    %% case my_exit(correctly) of
    %%   true ->
    %%     Res;
    %%   Other ->
    %%     io:format("Something very weird has happened\n"),
    %%     Other
    %% end.
    Res.
    
compile(Flags) ->
    hipe:c(?MODULE,[{core,false}|Flags]).

my_exit(Reason) ->
    exit(self(),Reason).

exit_2_catch() ->
    process_flag(trap_exit,true),
    Pid = fun_spawn(fun() -> catch exit(self(),die) end),
    receive
	{'EXIT',Pid,normal} ->
	    {error,catch_worked};
	{'EXIT',Pid,die} ->
	    ok;
	Other ->
            {error,{other_message,Other}}
    end.

fun_spawn(Fun) ->
    spawn_link(erlang, apply, [Fun,[]]).
