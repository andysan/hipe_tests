-module(compile_one).

-export([test/0, compile/1]).
-export([ae/1, ee/1]).

compile(O) ->
  hipe:c(?MODULE, O).

test() ->
  {ok,{_Platform,_Code}} = hipe:compile({?MODULE, ee, 1}), ok.
                                                                              
ae(X) -> if X rem 5 == 0 -> true; true -> false end.
                                                                              
ee(X) -> if X rem 5 =:= 0 -> true; true -> false end. 
