%% ====================================================================
%% Test module for the HiPE Ix test suite.
%%
%%  Filename : 	simpl_wt.erl
%%  Module   :	simpl_wt
%%  Purpose  :  Tests whether the translation of wait_timeout works.
%%  History  :	* 2000-10-30 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2000/11/22 15:00:49 $
%%    $Revision: 1.1 $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(simpl_wt).
-export([test/0,compile/1]).

simpl_wait_timeout() ->
    receive after 10 -> ok end.

test() ->
    simpl_wait_timeout().

compile(Flags) ->
    ix:c(?MODULE,Flags).
