-module(redundant1).
-export([a/1, b/1, c/1]).

-record(rec, {a}).

a(T) when is_tuple(T) -> tuple;
a(R) when is_record(R, rec) -> record.

b(I) when is_number(I) -> number;
b(I) when is_integer(I) -> integer.

c(0) -> first_zero;
c(0) -> another_zero.
