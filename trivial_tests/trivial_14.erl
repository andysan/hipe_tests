%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <99/12/16 11:41:17 happi>
%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename : trivial_14.erl
%%  Module   : trivial_14
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

-module(trivial_14).
-export([test/0,compile/1]).

test() ->
    first(42,true).

first(X,Y) ->
    (X * X) div X.

compile(Flags) ->
    hipe:compile({?MODULE,test,0},Flags).
