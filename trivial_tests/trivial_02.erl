%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <2001-03-22 18:40:18 richardc>
%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename : trivial_02.erl
%%  Module   : trivial_02
%%  Purpose  :  
%%  Notes    : 
%%  History  : 1999-12-05 Erik Johansson (happi@csd.uu.se): Created.
%% CVS:
%%    $Author: richardc $
%%    $Date: 2001/03/23 09:40:36 $
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
  hipe:c({?MODULE,test,0},Flags).
