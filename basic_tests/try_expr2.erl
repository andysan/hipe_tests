%% -*- erlang-indent-level: 2 -*-
%% ====================================================================
%%  Filename : try_expr2.erl
%%  Purpose  : Checks correct handling of try expressions.
%%  Creator  : Erik Stenman <Erik.Stenman@epfl.ch>
%% CVS:
%%    $Author: kostis $
%%    $Date: 2003/02/28 11:25:32 $
%%    $Revision: 1.1 $
%% ====================================================================

-module(try_expr2).
-export([test/0,compile/1]).

test() ->
  {[c(foo),
    c('exit'),
    c('fault'),
    c(other),
    c('throw')],
   [t(foo),
    t('exit'),
    t('fault'),
    t(other),
    t('throw')]}.

t(V) ->
  try seq(V) of
    foo -> bar;
    Other -> Other
  catch
    {'EXIT',Reason} -> Reason;
    {'ERROR',{What,TraceList}} -> [Head|_] = TraceList, {What,[Head]};
    OtherException -> OtherException
  end.

c(V) ->
  case catch seq(V) of
    foo -> bar;
    {'EXIT',{What,TraceList}} -> [Head|_] = TraceList, {What,[Head]};
    {'EXIT',Reason} when atom(Reason) -> Reason;
    OtherException -> OtherException
  end.

seq(foo) ->
  foo;
seq(exit) ->
  exit(foo);
seq(throw) ->
  throw('throwing');
seq(Y=fault) ->
  x = Y;
seq(_) ->
  other.

compile(Flags) ->
  hipe:c(?MODULE,Flags).
