-module(comp_tmout).
-export([test/0,compile/1]).

test() ->
    Self = self(),	%% get the parent process
    c:c(?MODULE,[native,{hipe,[{timeout,1}]}]),	%% This will kill the process
    Self == self().	%% make sure the parent process stays the same

compile(_Flags) ->
    ok.		%% no reason for native code compilation, really
