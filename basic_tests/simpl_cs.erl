%% ====================================================================
%% Test module for the HiPE Ix test suite.
%%
%%  Filename : 	simpl_cs.erl
%%  Module   :	simpl_cs
%%  Purpose  :  Tests whether all labels of a function are local.
%%  History  :	* 2000-10-29 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2000/11/22 15:00:48 $
%%    $Revision: 1.1 $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(simpl_cs).
-export([test/0,compile/1]).

test() ->
    s(42).

compile(Flags) ->
    ix:c(?MODULE,Flags).

s(Key) ->
    case foo(Key) of
	17.1345 ->
	    really_weird;
	Other ->
	    exit({correct_result,Other})
    end.

foo(X) ->
    X.
