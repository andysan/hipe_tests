%% ====================================================================
%%  Filename :  try_expr1.erl
%%  Purpose  :  Checks correct handling of try expressions.
%%  History  :  2003-02-28 Kostis Sagonas (kostis@csd.uu.se): Created.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2003/02/28 11:25:31 $
%%    $Revision: 1.1 $
%% ====================================================================

-module(try_expr1).
-export([test/0,compile/1]).

test() ->
  try non_existing_module:t() of
    a -> ok
  catch {'EXIT',_R} ->
    exception_caught_properly;
  Exception ->
    {caught_a_weird_exception,Exception}
  end.

compile(Flags) ->
  hipe:c(?MODULE,Flags).
