%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename : trivial_00.erl
%%  Module   : trivial_00
%%  Purpose  : To test the native code loader whether a file can be
%%		loaded a number of times without hanging the system.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2001/10/08 11:05:26 $
%%    $ $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(trivial_00).
-export([test/0,compile/1]).

test() ->
  Mod = trivial_00_input,
  [ {ok,Mod} = c:c(Mod,[native]) || N <- lists:seq(1,10) ],
  ok.

compile(Flags) ->
  hipe:c(?MODULE,Flags).
