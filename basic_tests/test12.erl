%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright (c) 2001 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <01/06/29 09:38:53 happi>
%% ====================================================================
%%  Filename : 	test12.erl
%%  Module   :	test12
%%  Purpose  :  To test refcounts for binaries
%%              and to test user invoced GC calls.
%%  Notes    :  Based on binary_SUITE from he emulator test suite.
%%  History  :	* 2001-06-28 Erik Johansson (happi@csd.uu.se): 
%%               Created.
%%  CVS      :
%%              $Author: happi $
%%              $Date: 2001/06/29 07:48:40 $
%%              $Revision: 1.1 $
%% ====================================================================
%%  Exports  :  test/0
%%              compile/1  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(test12).
-export([test/0,compile/1]).

-define(heap_binary_size, 64).

compile(O)->
  hipe:c(?MODULE,O).

test()->
    B = list_to_binary(lists:seq(0, ?heap_binary_size)),
    Self = self(),
    F = fun() ->
	    receive go -> ok end,
	    binary_to_list(B),
	    Self ! {self(),process_info(self(), binary)}
	end,
  c3(F).
c3(F) ->
    gc_test1(spawn_opt(erlang, apply, [F,[]], [])).

gc_test1(Pid) ->
  erlang:garbage_collect(),
  c(Pid).

c(Pid) ->
  Pid ! go,
  Result =
    receive
      {Pid,{binary,[{_,Size,Refs}]}} -> {Size,Refs}
    after 10000 -> exit(ooops)
    end,
  Result.
  
   



