%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright (c) 2001 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <01/06/13 11:13:11 happi>
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

-module(bs1).
-export([test/0,compile/1]).

compile(O) ->
  hipe:c(?MODULE,O).

test()->
 m(<<12>>).

m(<<X>>) ->
  X.
