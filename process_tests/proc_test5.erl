%% ====================================================================
%% Test module for the HiPE test suite.  Taken from process_SUITE.erl.
%%
%%  Filename :  proc_test5.erl
%%  Purpose  :  Tests the process info BIF.
%%  History  :  * 2001-09-19 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2001/09/19 10:28:37 $
%%    $Revision: 1.1 $
%% ====================================================================

-module(proc_test5).
-export([test/0,compile/1]).

test() ->
    t_process_info().
    
compile(Flags) ->
    hipe:c(?MODULE,Flags).

t_process_info() ->
    %% [] = process_info(self(), registered_name),
    %% register(my_name, self()),
    %% {registered_name, my_name} = process_info(self(), registered_name),
    %% {status, running} = process_info(self(), status),
    {current_function, {?MODULE,t_process_info,0}} =
        process_info(self(), current_function),
    %% Gleader = group_leader(),
    %% {group_leader, Gleader} = process_info(self(), group_leader),
    %% {'EXIT',{badarg,Info}} = (catch process_info('not_a_pid')),
    ok.

