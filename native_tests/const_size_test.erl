%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename :  const_size_test.erl
%%  Purpose  :  Tests loading of constants into the runtime system and
%%		its interaction with constant propagation. The test is
%%		written so that it returns 42.
%%  History  :  * 2003-10-31 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2004/03/16 00:55:45 $
%%    $Revision: 1.4 $
%% ====================================================================

-module(const_size_test).
-export([test/0,compile/1,return_const_tuple/0]).

test() ->
  compile([o2]),
  %% integer division below is just so that we return 42...
  hipe_bifs:constants_size() div 4.

compile(Flags) ->
  hipe:c(?MODULE,Flags).

return_const_tuple() ->
  Const = [501,502,503,504,505,506,507,508,509,510],
  {Const,{Const,{Const,3.14,Const},Const},Const}.
