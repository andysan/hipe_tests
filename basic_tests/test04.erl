%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <2004-08-20 14:33:29 richardc>
%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename : 	test04.erl
%%  Module   :	test04
%%  Purpose  :  Test calls between emulated and native code. 
%%  Notes    : 
%%  History  :	* 1999-12-05 Erik Johansson (happi@csd.uu.se): Created.
%% CVS:
%%    $Author: richardc $
%%    $Date: 2004/08/20 12:41:26 $
%%    $ $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(test04).
-export([test/0,compile/1]).

native(N) when N>0 ->
  emu(N-1);
native(_) ->
  0.

emu(N) ->
  N + native(N).

test() ->
  emu(10).

compile(Opts) ->
  %% compiling from Core does not make sense for this test
  test:note(?MODULE, "disabling compilation from core - no point"),
  hipe:c({test04,native,1}, [{core,false}|Opts]).
