%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright (c) 2000 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <00/12/13 13:50:31 happi>
%% ====================================================================
%%  Filename :  test_catches.erl
%%  Module   : test_catches
%%  Purpose  :  
%%  Notes    : 
%%  History  : * 2000-11-29 Erik Johansson (happi@csd.uu.se): 
%%               Created.
%%  CVS      :
%%              $Author: kostis $
%%              $Date: 2000/12/19 14:55:31 $
%%              $Revision: 1.1 $
%% ====================================================================
%%  Exports  :
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


-module(catches).
-export([test/0,compile/1]).

compile(O) ->
  ix:c(?MODULE,O).

test() ->
  catch [t1(),t2(),t3(),t4(),t5(a,b),t5(1,2),t6(),t7(),t8()].

t1() ->
  catch foo().

t2() ->
  V = (catch ok()),
  s(),
  V.

t3() ->
  V = (catch foo()),
  V.

t4() ->
  V1 = ok(),
  V2 = (catch foo()),
  {V1,V2}.

t5(A,B) ->
  catch A + B.

t6() ->
  catch {no_exception, ok(), foo()}.

t7() ->
  catch {no_exception, foo(), ok()}.

t8() ->
  catch {no_exception, ok()}.

foo() ->
  s(),
  exit(bar).

ok() ->
  s(),
  ok.

s() ->
  nada.
%%  hipe:show_nstack(self()).
