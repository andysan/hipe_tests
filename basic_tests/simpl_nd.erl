%% ====================================================================
%% Test module for the HiPE Ix test suite.
%%
%%  Filename : 	simpl_nd.erl
%%  Module   :	simpl_nd
%%  Purpose  :  Tests whether the translation of some guards works.
%%  History  :	* 2000-10-25 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2000/11/22 15:00:48 $
%%    $Revision: 1.1 $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(simpl_nd).
-export([test/0,compile/1]).

test() ->
    If = (catch if_end_error()),
    Case = (catch case_end_error()),
    [If,Case].

if_end_error() ->
    Zero = zero(),
    if 42 < Zero ->
	    ok
    end.

zero() ->
    0.

case_end_error() ->
    case 42 of
	17 -> weird
    end.

compile(Flags) ->
    ix:c(?MODULE,Flags).
