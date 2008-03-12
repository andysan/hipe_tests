-module(higher_order01).
-export([test/0]).

-spec(test/0 :: () -> fun(() -> 'ok')).
test() ->
   fun () -> 'ok' end.
