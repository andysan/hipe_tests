%%% 2007/05/07 Compiles one function in a module consisting of several
%%% functions using compile/2 with the concurrent comp option. This
%%% used to cause the compiler to hang
 
-module(compile_one).

-export([test/0, compile/1]).
-export([ae/1, ee/1]).

compile(O) ->
  hipe:c(?MODULE, O).

test() ->
  {ok,{_Platform,_Code}} = hipe:compile({?MODULE, ee, 1}, [concurrent_comp,o2]), ok.
                                                                              
ae(X) -> if X rem 5 == 0 -> true; true -> false end.
                                                                              
ee(X) -> if X rem 5 =:= 0 -> true; true -> false end. 
