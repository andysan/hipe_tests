%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright (c) 2001 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <01/06/13 11:52:20 happi>
%% ====================================================================
%%  Filename : 	bs.erl
%%  Module   :	bs
%%  Purpose  :  
%%  Notes    : 
%%  History  :	* 2001-04-10 Erik Johansson (happi@csd.uu.se): 
%%               Created.
%%  CVS      :
%%              $Author: happi $
%%              $Date: 2001/06/14 12:08:41 $
%%              $Revision: 1.1 $
%% ====================================================================
%%  Exports  :
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(bs7).
-export([test/0,compile/1]).

-define(FAIL(Expr), {'EXIT',{badarg,_}} = (catch Expr)).

compile(O) ->
  hipe:c(?MODULE,O).

test()->
  1 = in_guard(<<16#74ad:16>>, 16#e95, 5),
  2 = in_guard(<<16#3A,16#F7,"hello">>, 16#3AF7, <<"hello">>),
  3 = in_guard(<<16#FBCD:14,3.1415/float,3:2>>, 16#FBCD, 3.1415),
  nope = in_guard(<<1>>, 42, b),
  nope = in_guard(<<1>>, a, b),
  nope = in_guard(<<1,2>>, 1, 1),
  nope = in_guard(<<4,5>>, 1, 2.71),
  nope = in_guard(<<4,5>>, 1, <<12,13>>),
  ok.


in_guard(Bin, A, B) when <<A:13,B:3>> == Bin -> 1;
in_guard(Bin, A, B) when <<A:16,B/binary>> == Bin -> 2;
in_guard(Bin, A, B) when <<A:14,B/float,3:2>> == Bin -> 3;
in_guard(Bin, A, B) -> nope.
