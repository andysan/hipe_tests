%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <99/12/05 13:09:28 happi>
%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename : 	test04.erl
%%  Module   :	test04
%%  Purpose  :  Test calls between emulated and native code. 
%%  Notes    : 
%%  History  :	* 1999-12-05 Erik Johansson (happi@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2001/02/13 16:49:25 $
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

compile(Flags) ->
  hipe:compile({test04,native,1},Flags).
