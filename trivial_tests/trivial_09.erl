%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <2001-03-22 18:41:03 richardc>
%% ====================================================================
%% Test module for the HiPE trivial test suite.
%%
%%  Filename : trivial_09.erl
%%  Module   : trivial_09
%%  Purpose  :  
%%  Notes    : 
%%  History  : 1999-12-16 Erik Johansson (happi@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2002/05/07 13:06:34 $
%%    $ $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(trivial_09).
-export([test/0,compile/1]).

test() ->
  t(1,2,3,4,5,6,7,8,9,10).

t(_A,_B,_C,_D,_E,G,_H,_I,_J,_K) -> 
  G.


compile(Flags) ->
  hipe:c({?MODULE,t,10},Flags).
