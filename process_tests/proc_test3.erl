%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename :  proc_test3.erl
%%  Purpose  :  Checks correct exit of processes.
%%  History  :  * 2001-08-13 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2001/08/20 12:34:33 $
%%    $Revision: 1.1 $
%% ====================================================================

-module(proc_test3).
-export([test/0,compile/1]). %,exit_2_catch/0]).

test() ->
    my_exit(correctly).
    
compile(Flags) ->
    hipe:c(?MODULE,Flags).

my_exit(Reason) ->
    exit(self(),Reason).

%exit_2_catch() ->
%    process_flag(trap_exit,true),
%    Pid = fun_spawn(fun() -> catch exit(self(),die) end),
%    receive
%	{'EXIT',Pid,normal} ->
%	    {error,catch_worked};
%	{'EXIT',Pid,die} ->
%	    ok;
%	Other ->
%            {error,{other_message,Other}}
%    end.

%fun_spawn(Fun) ->
%    spawn_link(erlang, apply, [Fun,[]]).
