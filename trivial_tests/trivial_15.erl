%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <2001-03-22 18:41:32 richardc>
%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename : 	trivial_15.erl
%%  Module   :	trivial_15
%%  Purpose  :  
%%  Notes    : 
%%  History  :	* 1999-12-16 Erik Johansson (happi@csd.uu.se): Created.
%% CVS:
%%    $Author: richardc $
%%    $Date: 2001/03/23 09:40:36 $
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
    hipe:c({?MODULE,second,2},Flags).
