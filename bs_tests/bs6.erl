%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright (c) 2001 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <01/06/13 11:16:37 happi>
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

-module(bs6).
-export([test/0,compile/1]).

-define(FAIL(Expr), {'EXIT',{badarg,_}} = (catch Expr)).

compile(O) ->
  hipe:c(?MODULE,O).

test()->
     ?FAIL(<<3.14>>),
    ?FAIL(<<<<1,2>>>>),

    ?FAIL(<<2.71/binary>>),
    ?FAIL(<<24334/binary>>),
    ?FAIL(<<24334344294788947129487129487219847/binary>>),

    ?FAIL(<<24334344294788947129487129487219847/float>>),
    ?FAIL(<<<<1,2,3>>/float>>),

    ok.

