%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <99/12/16 11:25:54 happi>
%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename : trivial_02.erl
%%  Module   : trivial_02
%%  Purpose  :  
%%  Notes    : 
%%  History  : 1999-12-05 Erik Johansson (happi@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2001/02/13 16:49:27 $
%%    $ $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(trivial_02).
-export([test/0,compile/1]).

test() ->
  42.

compile(Flags) ->
  hipe:compile({?MODULE,test,0},Flags).
