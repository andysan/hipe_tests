-module(equal1).
-export([eq/1, exact_eq/1]).

eq(B) when B == foo -> B.

exact_eq(B) when B =:= foo -> B.
