%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(simpl_fl).
-export([test/0,compile/1]).

test() ->
    mult(2.5617).

mult(X) ->
    3.1415 * X.

compile(Flags) ->
    hipe:c(?MODULE,Flags).
