%% ====================================================================
%% Test module for the HiPE test suite.  Taken from process_SUITE.erl
%%
%%  Filename :  proc_test4.erl
%%  Purpose  :  Checks correct exit of processes.
%%  History  :  * 2001-08-13 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: pergu $
%%    $Date: 2004/07/30 13:26:54 $
%%    $Revision: 1.3 $
%% ====================================================================

-module(proc_test4).
-export([test/0,compile/1]).
%% the following is used in a remote call context
-export([fun_init/1]).

test() ->
    {normal_suicide_exit(foo),abnormal_suicide_exit(bar)}.
    
compile(Flags) ->
    hipe:c(?MODULE,[{core,false}|Flags]).

%% Tests exit(self(), Term) is equivalent to exit(Term) for a process
%% that doesn't trap exits.

normal_suicide_exit(suite) -> [];
normal_suicide_exit(_) ->
    process_flag(trap_exit, true),
    Pid = fun_spawn(fun() -> exit(self(), normal) end),
    receive
	{'EXIT', Pid, normal} -> ok;
	Other -> exit({normal_suicide_exit,bad_message,Other})
    end.

%% Tests exit(self(), Term) is equivalent to exit(Term) for a process
%% that doesn't trap exits.

abnormal_suicide_exit(suite) -> [];
abnormal_suicide_exit(_) ->
    Garbage = eight_kb(),
    process_flag(trap_exit, true),
    Pid = fun_spawn(fun() -> exit(self(), Garbage) end),
    receive
	{'EXIT', Pid, Garbage} -> ok;
	Other -> exit({abnormal_suicide_exit,bad_message,Other})
    end.

%% AUXILIARY FUNCTIONS USED BY THE TEST

fun_init(Fun) ->
    Fun().
fun_spawn(Fun) ->
    spawn_link(?MODULE, fun_init, [Fun]).

eight_kb() ->
    B64 = lists:seq(1, 64),
    B512 = {B64, B64, B64, B64, B64, B64, B64, B64},
    lists:duplicate(8, {B512, B512}).
