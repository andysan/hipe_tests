%%======================================================================
%% Contains code which confuses the icode_type analysis and results
%% in a compiler crash.  Stipped down from code sent by Paul Guyot.
%% Compiles alright with the option 'no_icode_type' but that defeats
%% the purpose of the test.
%%======================================================================
-module(fp_icode_type_crash).

-export([test/0, compile/1]).

test() ->
  Fun = f(1, 2, 3),
  42.0 = Fun(),
  ok.

f(A, B, C) ->
    fun () ->
	X = case A of
		0 -> 1 / B;
		_ -> A / C
	    end,
	Y = case B of
		a -> 1.0;
		b -> 2.0;
        	_ -> 6.0
            end,
	Z = case C of
		c -> 0.1 * X;
		_ -> 7.0
	    end,
	Y * Z
   end.

compile(Opts) ->
  hipe:c(?MODULE, Opts).
