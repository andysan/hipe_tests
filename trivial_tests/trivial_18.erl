%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <99/12/16 11:46:26 happi>
%% ====================================================================
%% Test module for the HiPE Ix test suite.
%%
%%  Filename : 	trivial_18.erl
%%  Module   :	trivial_18
%%  Purpose  :  
%%  Notes    : 
%%  History  :	* 1999-12-16 Erik Johansson (happi@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2000/11/22 15:00:52 $
%%    $ $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(trivial_18).
-export([test/0,compile/1]).

test() ->
  i().

i() -> 
  ii().

ii() ->
  0.

compile(Flags) ->
  ix:compile({?MODULE,test,0},Flags),
  ix:compile({?MODULE,ii,0},Flags).
