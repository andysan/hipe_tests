%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename :  simpl_co.erl
%%  Purpose  :  Tests loading of constants into the runtime system and
%%		its interaction with constant propagation. The test is
%%		written so that it returns 42.
%%  History  :  * 2003-10-31 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2003/12/16 15:51:09 $
%%    $Revision: 1.1 $
%% ====================================================================

-module(const_size_test).
-export([test/0,compile/1,return_const_tuple/0]).

test() ->
  compile([o2]),
  %% division and round() calls below is just to that we return 42...
  S = hipe_bifs:constants_size() / 4,
  round(S).

compile(Flags) ->
  hipe:c(?MODULE,Flags).

return_const_tuple() ->
  Const = [501,502,503,504,505,506,507,508,509,510],
  {Const,Const,Const,Const,Const,Const}.
