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
%%              $Author: pergu $
%%              $Date: 2004/02/26 10:27:50 $
%%              $Revision: 1.2 $
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
  X;
m({Y, Z}) ->
  Y + Z.
