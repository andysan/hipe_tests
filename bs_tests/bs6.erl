%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Filename : 	bs6.erl
%%  Purpose  :  Tests construction of "bad" binaries
%%  Notes    : 
%%  History  :	* 2001-04-10 Erik Johansson (happi@csd.uu.se): Created.
%%  CVS      :
%%              $Author: kostis $
%%              $Date: 2005/02/02 15:12:24 $
%%              $Revision: 1.4 $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(bs6).
-export([test/0,compile/1]).

-define(FAIL(Expr), {'EXIT',{badarg,_}} = (catch Expr)).

compile(O) ->
  hipe:c(?MODULE,O).

test() ->
  PI = math:pi(),
  ?FAIL(<<PI>>),
  ?FAIL(<<<<1,2>>>>),

  E = 2.71,
  ?FAIL(<<E/binary>>),
  Int = 24334,
  BigInt = 24334344294788947129487129487219847,
  ?FAIL(<<Int/binary>>),
  ?FAIL(<<BigInt/binary>>),

  ?FAIL(<<<<1,2,3>>/float>>),

  ok.

