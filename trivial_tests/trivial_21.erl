%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <2001-03-22 18:41:56 richardc>
%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename : 	trivial_21.erl
%%  Module   :	trivial_21
%%  Purpose  :  
%%  Notes    : 
%%  History  :	* 30/7/2001 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2001/07/30 15:45:01 $
%%    $ $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(trivial_21).
-export([test/0,compile/1]).

test() ->
  matching_bigs([a,b,other]).

matching_bigs(Config) when list(Config) ->
  {matching1(3972907842873739),
   matching1(-389789298378939783333333333333333333784),
   matching1(42)}.

%% Big numbers, no select_val.

matching1(3972907842873739) -> a;
matching1(-389789298378939783333333333333333333784) -> b;
matching1(_) -> other.

compile(Flags) ->
  hipe:c(?MODULE,Flags).
