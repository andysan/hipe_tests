%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <99/12/16 11:41:47 happi>
%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename : 	trivial_15.erl
%%  Module   :	trivial_15
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

-module(trivial_15).
-export([test/0,compile/1]).

test() ->
    second(42,true).

second(X,Y) ->
    Y.

compile(Flags) ->
    hipe:compile({?MODULE,second,2},Flags).
