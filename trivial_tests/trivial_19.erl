%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <99/12/16 11:46:58 happi>
%% ====================================================================
%% Test module for the HiPE Ix test suite.
%%
%%  Filename : 	trivial_19.erl
%%  Module   :	trivial_19
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

-module(trivial_19).
-export([test/0,compile/1]).

test() ->
  t(1,2,3,4,5,6,7,8,9,10).

t(A,B,C,D,E,G,H,I,J,K) -> 
  G.

compile(Flags) ->
  ix:compile({?MODULE,test,0},Flags).
