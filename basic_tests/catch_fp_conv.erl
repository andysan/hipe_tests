%% ====================================================================
%%  Filename :  catch_big_to_fp.erl
%%  Module   :  catch_big_to_fp
%%  Purpose  :  To test catching of illegal converting of bignums to floating point numbers.
%%  CVS      :
%%              $Author: toli6207 $
%%              $Date: 2002/06/25 09:28:02 $
%%              $Revision: 1.1 $
%% ====================================================================

-module(catch_fp_conv).
-export([test/0,compile/1]).

test() ->
    big_arith(),
    big_const_float(),
    ok.

big_arith() ->
    %% F is a number very close to a maximum float.
    F = 1.7e308,
    I = trunc(F),
    {'EXIT', _} = big_arith(I).

big_arith(I) when integer(I)->
    catch(3.0 + 2*I).

big_const_float()->
    F = 1.7e308,
    I = trunc(F),
    {'EXIT', _} = (catch 1/(2*I)),
    _Ignore = 2/I,
    {'EXIT', _} = (catch 4/(2*I)),
    ok.

compile(O) ->
  hipe:c(?MODULE,O).
