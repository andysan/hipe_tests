% file: "fib.erl"

-module(fib).
-export([test/0,compile/1]).

fib(0) -> 0;
fib(1) -> 1;
fib(X) -> fib(X-1) + fib(X-2).

loop(0,R) -> R;
loop(N,R) -> loop(N-1,fib(30)).

test() ->
    statistics(runtime),
    R = loop(50,0),
    {_,Time} = statistics(runtime),
    io:format("\nruntime = ~p msecs\nresult = ~p\n",[Time,R]),
    R.

compile(Flags) ->
    hipe:c(?MODULE,Flags).
