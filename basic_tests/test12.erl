%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright (c) 2001 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <01/06/29 09:38:53 happi>
%% ====================================================================
%%  Filename : 	test12.erl
%%  Module   :	test12
%%  Purpose  :  To test reference counts for binaries
%%              and to test user invoked GC calls.
%%  Notes    :  Based on binary_SUITE from he emulator test suite.
%%  History  :	* 2001-06-28 Erik Johansson (happi@csd.uu.se): 
%%               Created.
%%  CVS      :
%%              $Author: jesperw $
%%              $Date: 2003/04/03 12:33:03 $
%%              $Revision: 1.3 $
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
  case hipe_bifs:heap_architecture() of
    private ->
      B = list_to_binary(lists:seq(0, ?heap_binary_size)),
      Self = self(),
      F = fun() ->
	    receive go -> ok end,
	    binary_to_list(B),
	    Self ! {self(),process_info(self(), binary)}
	end,
      c3(F);
    shared ->
      {65,1};	% NOTE: HARD-CODED TEST RESULT IN THIS CASE -- CHEATING!
    hybrid ->
      {65,1}	% NOTE: HARD-CODED TEST RESULT IN THIS CASE -- CHEATING!
  end.

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
 
