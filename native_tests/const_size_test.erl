%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename :  const_size_test.erl
%%  Purpose  :  Tests loading of constants into the runtime system and
%%		its interaction with constant propagation. The test is
%%		written so that it returns 42; a better explanation of
%%		the magic number that is printed appears below.
%%  History  :  * 2003-10-31 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2004/08/21 15:05:44 $
%%    $Revision: 1.5 $
%% ====================================================================

-module(const_size_test).
-export([test/0,compile/1,return_const_tuple/0]).

%% This is supposed to count the constants which are added in the
%% constant pool when compiling and loading native code.
%% These are:
%%
%%	Constant					Size (words)
%% --------------------------------------------------------------------
%% 1. [{const_size_test,return_const_tuple,0}]		   9 (6 + 3)
%% 2. {[501,502,503,504,505,506,507,508,509,510],
%%     {[501,502,503,504,505,506,507,508,509,510],
%%      {[501,502,503,504,505,506,507,508,509,510],
%%       3.14000,
%%       [501,502,503,504,505,506,507,508,509,510]},
%%      [501,502,503,504,505,506,507,508,509,510]},
%%     [501,502,503,504,505,506,507,508,509,510]}	 138
%% 3. [{const_size_test,compile,1}]			   9
%% 4. [{const_size_test,test,0}]			   9
%% 5. [o2]						   5 (2 + 3)
%% --------------------------------------------------------------------
%%                                                       170
%% Explanation
%% 1. size = 9 is 4 for the tuple, 2 for the list, and
%%		  3 header words (for the constant entry).
%% 2. size = 138 is 120 for the lists (6*20), 3 for the float,
%%		    12 (3*4) for the tuples, and 3 header words.

test() ->
  compile([o2]),
  ConstPoolSize = hipe_bifs:constants_size(),
  %% integer division below is just so that we return 42...
  ConstPoolSize div 4.

compile(Opts0) ->
  case proplists:get_bool(core, Opts0) of
    true ->
      %% Disable core compilation for now, since we get different
      %% constant pool size due to the presence of the two
      %% [{const_size_test,module_info,?}] entries (9 words each).
      %%
      %% Note: The following is written with atoms and a call to
      %%       lists:delete/1 so that no other constants are created
      test:note(?MODULE, 'disabling compilation from core - constant pool differs'),
      Opts = lists:delete(core, Opts0);
    false ->
      Opts = Opts0
  end,
  hipe:c(?MODULE, Opts).

return_const_tuple() ->
  Const = [501,502,503,504,505,506,507,508,509,510], %% size = 20
  {Const,{Const,{Const,3.14,Const},Const},Const}.
