%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename :  proc_test3.erl
%%  Purpose  :  Checks correct exit of processes.
%%  History  :  * 2001-08-13 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: mikpe $
%%    $Date: 2001/09/17 15:35:55 $
%%    $Revision: 1.2 $
%% ====================================================================

-module(proc_test3).
-export([test/0,compile/1]).

test() ->
    exit_2_catch().
    
compile(Flags) ->
    hipe:c(?MODULE,Flags).

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
