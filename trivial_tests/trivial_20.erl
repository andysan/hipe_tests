%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <2001-03-22 18:41:56 richardc>
%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename : 	trivial_20.erl
%%  Module   :	trivial_20
%%  Purpose  :  
%%  Notes    : 
%%  History  :	* 30/7/2001 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2001/07/30 15:45:01 $
%%    $ $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(trivial_20).
-export([test/0,compile/1]).

test() ->
  {'EXIT',{{badmatch,b},[{?MODULE,F1,0}|_]}} = (catch badmatch()),
  {'EXIT',{{badmatch,b},[{?MODULE,F2,0}|_]}} = (catch inline_catch_badmatch()),
  {badmatch,inline_catch_badmatch} = {F1,F2},
  ok.

badmatch() ->
  a = b.

inline_catch_badmatch() ->
  catch a = b.

compile(Flags) ->
  hipe:c(?MODULE,Flags).
