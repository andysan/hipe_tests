%% ====================================================================
%% Test module for the HiPE Ix test suite.
%%
%%  Filename : 	bif01.erl
%%  Module   :	bif01
%%  Purpose  :  Tests handling of bifs in guards and elsewhere.
%%  History  :	* 2000/10/24 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2000/11/22 15:00:48 $
%%    $Revision: 1.1 $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(bif01).
-export([test/0,compile/1,ba/1]).

ba(T) when element(1,T) == a ->
    element(2,T) == b;
ba(_) ->
    ok.

test() ->
    {ba({a,b}),ba({a,c}),ba(foo)}.

compile(Flags) ->
    ix:c(?MODULE,Flags).

