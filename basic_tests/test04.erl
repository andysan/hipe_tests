%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <2001-03-22 18:37:23 richardc>
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
%%    $Date: 2001/03/23 09:40:35 $
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
  hipe:c({test04,native,1},Flags).
