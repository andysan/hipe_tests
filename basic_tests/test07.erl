%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <99/12/06 13:57:37 happi>
%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename : 	test07.erl
%%  Module   :	test07
%%  Purpose  :  Forces floating point exceptions and tests that subsequent, 
%%              legal, operations are calculated correctly.  
%% 
%%  Notes    : Original version by Sebastian Strollo.
%%             Second version by 'bjorn@erix.ericsson.se'
%%  History  :	* 1999-12-05 Erik Johansson (happi@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2001/02/13 16:49:25 $
%%    $ $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(test07).
-export([test/0,compile/1]).

test() ->
    0.0 = math:log(1.0),
    {'EXIT', _} = (catch math:log(-1.0)),
    0.0 = math:log(1.0),
    {'EXIT', _} = (catch math:log(0.0)),
    0.0 = math:log(1.0),
    {'EXIT',_} = (catch 3.23e133 * 3.57e257),
    0.0 = math:log(1.0),
    {'EXIT',_} = (catch 5.0/0.0),
    0.0 = math:log(1.0),
    ok.

compile(Flags) ->
    hipe:c(?MODULE,Flags).
