%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright (c) 2001 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <01/02/23 15:02:22 happi>
%% ====================================================================
%%  Filename : fun01.erl
%%  Module   : fun01
%%  Purpose  :  
%%  Notes    : 
%%  History  : * 2001-01-10 Erik Johansson (happi@csd.uu.se): 
%%               Created.
%%  CVS      :
%%              $Author: kostis $
%%              $Date: 2001/02/23 16:09:21 $
%%              $Revision: 1.1 $
%% ====================================================================
%%  Exports  :
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(fun01).
-export([test/0, compile/1]).

test() ->
  EF = e_mk_fun(1,2,3),
  NF = n_mk_fun(1,2,3),
  EF2 = e_mk_fun2(1,2,3),
  EBA = c_barity(),
  NBA = c_barity(),
  EBF = b_fun(),  
  NBF = b_fun(),  
  {e_call_fun(EF),
   n_call_fun(NF),
   e_call_fun(NF),
   n_call_fun(EF),
   n_call_fun2(EF2),
   EBA,
   NBA,
   EBF,
   NBF,
  l()}.
   
compile(O) ->
  hipe:compile({?MODULE,test,0}, O),
  hipe:compile({?MODULE,n_mk_fun,3}, O),
  hipe:compile({?MODULE,n_call_fun,1}, O),
  hipe:compile({?MODULE,n_call_fun2,1}, O),  
  hipe:compile({?MODULE,b_arity,0}, O),
  hipe:compile({?MODULE,c_barity,0}, O),
  hipe:compile({?MODULE,b_fun,0}, O),
  hipe:compile({?MODULE,l,0}, O),
  hipe:compile({?MODULE,l2,2}, O).


l() ->
  {T,_} = erlang:statistics(runtime),

  F =
    fun (_, 0) ->
 ok;
 (F2, N) -> (F2)(F2,N-1)
    end, 
  %% fun(X,Y) -> [T] end,
  {T1,_} = erlang:statistics(runtime),
  l2(F,1000),
  {T2,_} = erlang:statistics(runtime),
  io:format("Runtime: ~w ms\n",[T2-T1]).


l2(_,0) ->
  done;
l2(F,N) ->
  (F)(F,500),
  l2(F,N-1).


e_mk_fun(A,B,C) ->
  D = A+C,
  fun (E, F, G) ->
      {A, B, C, D, E, F, G}
  end.

n_mk_fun(A,B,C) ->
  D = A+C,
  fun (E, F, G) ->
      {A, B, C, D, E, F, G}
  end.

e_call_fun(F) ->
  F(5,6,7).

n_call_fun(F) ->
  F(5,6,7).

e_mk_fun2(A,B,C) ->
  D = A+C,
  fun (E, F, G, H, I, J) ->
      {A, B, C, D, E, F, G, H, I, J}
  end.

n_call_fun2(F) ->
  F(5,6,7,8,9,10).

b_arity() ->
  fun (A) ->
      A
  end.

c_barity() ->
  F = b_arity(),
  {case catch F() of
       {'EXIT',_BadSomething} -> {'EXIT',bad_something};
       Other -> Other
   end,
   case catch F(1) of
       {'EXIT',_BadSomething} -> {'EXIT',bad_something};
       Other -> Other
   end,
   case catch F(1,2) of
      {'EXIT',_BadSomething} -> {'EXIT',bad_something};
       Other -> Other
   end}.

b_fun() ->
  A = 1,
  case catch A(2) of
      {'EXIT',_BadSomething} -> {'EXIT',bad_something};
      Other -> Other
  end.
