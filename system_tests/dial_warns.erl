%% File   : dial_warns.erl
%% Author : Kostis Sagonas
%%
%% Purpose: To run Dialyzer on the HiPE application and test that
%%          there are no discrepancies that it identifies.
%%
%% $Id: dial_warns.erl,v 1.2 2004/10/03 11:14:37 kostis Exp $
%%

-module(dial_warns).

-export([test/0,compile/1]).

compile(_Options) ->
    ok. %% No native code compilation.

test() ->
    %% remember the current working directory
    {ok,CWD} = file:get_cwd(),

    %% set stuff needed by Dialyzer to work
    OTP_Dir = code:root_dir(),
    Base_Dir = filename:dirname(OTP_Dir),
    Dialyzer_Dir = Base_Dir ++ "/dialyzer",
    true = code:add_path(Dialyzer_Dir ++ "/ebin"),

    %% this is the application which is going to be analyzed
    HiPE_Dir = OTP_Dir ++ "/lib/hipe",
    %% the call to dialyzer changes the current working directory to
    %% the ebin dir of the application which is analyzed
    dialyzer:start({options,false,byte_code,[list_to_atom(HiPE_Dir)]}),

    %% so change the current working dir back to what we started from
    file:set_cwd(CWD),
    ok.

