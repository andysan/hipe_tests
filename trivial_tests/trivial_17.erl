%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <99/12/16 11:47:18 happi>
%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename : 	trivial_17.erl
%%  Module   :	trivial_17
%%  Purpose  :  
%%  Notes    : 
%%  History  :	* 1999-12-16 Erik Johansson (happi@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2001/02/13 16:49:27 $
%%    $ $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(trivial_17).
-export([test/0,compile/1]).

test() ->
  i(),i().

i() -> 0.

compile(Flags) ->
  hipe:compile({?MODULE,i,0},Flags).
