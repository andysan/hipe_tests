%% ====================================================================
%% Test module for the HiPE Ix test suite.
%%
%%  Filename : 	simpl_ne.erl
%%  Module   :	simpl_ne
%%  Purpose  :  Tests whether the translation of some guards works.
%%  History  :	* 2000-10-29 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2000/11/22 15:00:49 $
%%    $Revision: 1.1 $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(simpl_ne).
-export([test/0,compile/1]).

guard1(X) when X /= 0, float(X), constant(X) ->
     ok.

guard2(X) when constant(X) ->
    error1;
guard2(X) when reference(hd(X)) ->
    error2;
guard2(X) when integer(hd(X)) ->
    error3;
guard2(X) when hd(X) == foo ->
    ok.

test() ->
    {guard1(4.2),guard2([foo])}.

compile(Flags) ->
    ix:c(?MODULE,Flags).
