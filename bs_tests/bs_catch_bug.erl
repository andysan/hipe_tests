%%%-------------------------------------------------------------------
%%% File    : bs_catch_bug.erl
%%% Author  : Per Gustafsson <pergu@dhcp-12-245.it.uu.se>
%%% Description : Tests a catch related bug which might
%%%               destroy properties of icodecfgs
%%%               assumed by the binary pass
%%% Created : 22 Jan 2004 by Per Gustafsson <pergu@dhcp-12-245.it.uu.se>
%%%-------------------------------------------------------------------
-module(bs_catch_bug).
-export([test/0, compile/1]).

compile(O) ->
  hipe:c(?MODULE,O).

test()->
    catch (<<_/binary>> = foo),
    foo = case foo of
            <<_/binary>> -> bar
          end.



