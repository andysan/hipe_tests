%% ====================================================================
%% Test module for the HiPE Ix test suite.
%%
%%  Filename : 	simpl_tm.erl
%%  Module   :	simpl_tm
%%  Purpose  :  Tests whether the translation of timeout works; they
%%              were not handled correctly in some previous version
%%              of HiPE.
%%  History  :	* 2000-12-12 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2000/12/12 14:42:40 $
%%    $Revision: 1.1 $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(simpl_tm).
-export([test/0,compile/1]).

simpl_timeout() ->
    self() ! foo, self() ! another_foo,
    receive
	non_existent -> weird
    after 0 -> timeout
    end,
    receive 
	foo -> {answer,42}
    after 1000 -> timeout
    end.

test() ->
    simpl_timeout().

compile(Flags) ->
    ix:c(?MODULE,Flags).
