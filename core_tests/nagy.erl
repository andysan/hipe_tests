-module(nagy).
-export([test/0, compile/1]).

-record(rec, {field1,field2,field3,field4}).

test() ->
     [#rec{field1 = A, field2 = B}]
   = [TRec] = [#rec{field1=a,field2=b}],
     TRec1 = TRec#rec{field3 = something3, field4 = something4},
     {TRec1,TRec,A,B}.

compile(Opts) ->
    hipe:c(?MODULE, [core|Opts]).
