%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <99/12/16 11:42:15 happi>
%% ====================================================================
%% Test module for the HiPE Ix test suite.
%%
%%  Filename : 	trivial_16.erl
%%  Module   :	trivial_16
%%  Purpose  :  
%%  Notes    : 
%%  History  :	* 1999-12-16 Erik Johansson (happi@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2000/11/22 15:00:51 $
%%    $ $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(trivial_16).
-export([test/0,compile/1]).

test() ->
  const(42,true).

const(X,Y) ->
  z.

compile(Flags) ->
  ix:compile({?MODULE,test,0},Flags).
