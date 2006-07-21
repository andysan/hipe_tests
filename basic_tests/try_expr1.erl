%% ====================================================================
%%  Filename :  try_expr1.erl
%%  Purpose  :  Checks correct handling of try expressions.
%%  History  :  2003-02-28 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2006/07/21 11:59:51 $
%%    $Revision: 1.2 $
%% ====================================================================

-module(try_expr1).
-export([test/0, compile/1]).

test() ->
  try 'non existing module':t() of
    a -> ok
  catch error:_Reason ->
    exception_caught_properly;
  Exception ->
    {caught_a_weird_exception,Exception}
  end.

compile(Flags) ->
  hipe:c(?MODULE,Flags).
