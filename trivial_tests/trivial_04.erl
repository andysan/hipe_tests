%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <99/12/16 11:28:00 happi>
%% ====================================================================
%% Test module for the HiPE Ix test suite.
%%
%%  Filename : trivial_04.erl
%%  Module   : trivial_04
%%  Purpose  :  
%%  Notes    : 
%%  History  : 1999-12-05 Erik Johansson (happi@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2000/11/22 15:00:51 $
%%    $ $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(trivial_04).
-export([test/0,compile/1]).

test() ->
  first(42,true).

first(X,Y) ->
  X.

compile(Flags) ->
  ix:compile({?MODULE,first,2},Flags).
