%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename : 	simpl_nf.erl
%%  Module   :	simpl_nf
%%  Purpose  :  Tests whether the translation of is_function works.
%%  History  :	* 2000-11-21 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2001/02/13 16:49:25 $
%%    $Revision: 1.2 $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(simpl_fn).
-export([test/0,compile/1]).

foo(_,_,_,_) ->
    ok.

guard(X) when function(X) ->
     ok.

if_test(X) ->
    if
	function(X) ->
	    ok;
	true ->
	    weird
    end.

test() ->
    Fun = fun(X, 'foo') -> foo(X, mnesia_lib, db_first, [X]) end,
    {guard(Fun),if_test(Fun)}.

compile(Flags) ->
    hipe:c(?MODULE,Flags).
