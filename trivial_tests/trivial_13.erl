%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <99/12/16 11:40:28 happi>
%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename : trivial_13.erl
%%  Module   : trivial_13
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

-module(trivial_13).
-export([test/0,compile/1]).

test() ->
    return_it(42).

return_it(X) ->
    R = (2 * X) / 2,
    round(R).

compile(Flags) ->
    hipe:compile({?MODULE,return_it,1},Flags).
