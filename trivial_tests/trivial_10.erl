%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <99/12/16 11:48:43 happi>
%% ====================================================================
%% Test module for the HiPE Ix test suite.
%%
%%  Filename : trivial_10.erl
%%  Module   : trivial_10
%%  Purpose  :  
%%  Notes    : 
%%  History  : 1999-12-16 Erik Johansson (happi@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2001/02/13 16:49:27 $
%%    $ $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(trivial_10).
-export([test/0,compile/1]).

test() ->
  t(1,2,3,4,5,6,7,8,9,10).

t(A,B,C,D,E,G,H,I,J,K) -> 
  K.

compile(Flags) ->
  hipe:compile({?MODULE,t,10},Flags).
