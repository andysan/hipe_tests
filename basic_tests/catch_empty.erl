%% ====================================================================
%%  Filename :  catch_empty.erl
%%  Module   :  catch_empty
%%  Purpose  :  To test whether the HiPE compiler optimizes catches in
%%		a way that does not result in an infinite loop.
%%  CVS      :
%%              $Author: kostis $
%%              $Date: 2001/03/23 18:53:24 $
%%              $Revision: 1.1 $
%% ====================================================================

-module(catch_empty).
-export([test/0,compile/1]).

compile(O) ->
  hipe:c(?MODULE,O).

test() ->
  badmatch().

-define(line, io:format("~p:~p\n", [?MODULE,?LINE]),).

badmatch() ->
    Big = 32984798729847892498297824872982972978239874,
    Float = 3.1415927,
    catch a = Big,
    catch b = Float,
    case Big of
         Big -> ok
    end,
    case Float of
        Float -> ok
    end,
    ok.

