%% Copyright (c) 1999 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <99/12/09 12:40:18 happi>
%% ====================================================================
%% Test module for the HiPE test suite.
%%
%%  Filename : 	test09.erl
%%  Module   :	test09
%%  Purpose  :  Tests nested constructions.
%%  Notes    :  Original author: bjorn@erix.ericsson.se
%%  History  :	* 1999-12-05 Erik Johansson (happi@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2001/02/13 16:49:26 $
%%    $Revision: 1.2 $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(test09).
-export([test/0,compile/1]).

test() ->
    {case_in_case(),case_in_after()}.

compile(Flags) ->
    {hipe:compile({?MODULE,case_in_case,0},Flags),
     hipe:compile({?MODULE,search_any,2},Flags),
     hipe:compile({?MODULE,case_in_after,0},Flags), % used to cause strange error
     hipe:compile({?MODULE,keysearch,3},Flags)
    }.

case_in_case() ->
    done = search_any([a], [{a,1}]),
    done = search_any([x], [{a,1}]),
    ok.

search_any([Key|Rest], List) ->
    case case keysearch(Key, 1, List) of
	     {value, _} -> 
		 true;
	     _ ->
		 false
	 end of
	true ->
	    ok;
	false ->
	    error;
	Other ->
	    exit({other_result, Other})
    end,
    search_any(Rest, List);
search_any([], _) ->
    done.

case_in_after() ->
    receive
    after case {x, y, z} of
	      {x, y, z} -> 0
	  end ->
	    ok
    end,
    ok.

keysearch(Key, N, [H|T]) when element(N,H) == Key ->
    {value, H};
keysearch(Key, N, [H|T]) ->
    keysearch(Key, N, T);
keysearch(Key, N, []) -> false.
