%% ====================================================================
%%  Filename :  catch_fp_bdarith.erl
%%  Module   :  catch_fp_bdarith
%%  Purpose  :  To test catching of floating point bad arithmetic.
%%  CVS      :
%%              $Author: kostis $
%%              $Date: 2002/05/15 09:14:11 $
%%              $Revision: 1.1 $
%% ====================================================================

-module(catch_fp_bdarith).
-export([test/0,compile/1]).

test() ->
   5.7 = f(2.56),
   {'EXIT',{badarith,_}} = bad_arith(9.9),
   ok.

f(F) when float(F) -> F + 3.14.

bad_arith(F) when float(F) ->
    catch F * 1.70000e+308.

compile(O) ->
  hipe:c(?MODULE,O).

