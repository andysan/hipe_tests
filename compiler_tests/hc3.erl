%% ====================================================================
%% Test module for stress-testing the HiPE compiler.
%%
%%  Filename :  hc3.erl
%%  Module   :  hc3
%%  Purpose  :  Tests whether the HiPE compiler works by compiling and
%%		loading many files from the "otp/lib" directory.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2003/04/22 18:03:05 $
%%    $Revision: 1.7 $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(hc3).
-export([test/0,test/1,compile/1]).

-include("excluded.inc").

test() ->
    [
     test("et"),
     test("eva"),
     test("gs"),
     test("ic"),
     test("inets"),
     test("megaco"),
     test("mnemosyne"),
     test("mnesia"),
     test("mnesia_session"),
     test("observer"),
     test("orber"),
     test("os_mon"),
     test("parsetools"),
     test("pman"),
     test("runtime_tools"),
     test("sasl"),
     test("snmp"),    
     test("toolbar"),
     test("tv"),
     test("webtool")
    ].

test(Application) ->
    Delim = "========================",
    io:format("%%"++Delim++" Compiling "++Application++" "++Delim++"\n"),
    [ hc_mod(Mod) || Mod <- files(Application) -- excluded(Application) ],
    {ok,Application}.

hc_mod(Mod) ->
    io:format("Compiling ~w ...",[Mod]),
    T0 = time_now(),
    Res = hipe:c(Mod,get_comp_opts()),
    T = time_since(T0) / 1000,
    io:format(" done in ~.2f secs\n",[T]),
    {ok,Mod} = Res.

get_comp_opts() ->
    {ok,Tokens,_} = erl_scan:string(os:getenv("HiPE_COMP_OPTS") ++ "."),
    {ok,CompFlags} = erl_parse:parse_term(Tokens),
    CompFlags.

files(App) ->
    AppFile = os:getenv("OTP_DIR") ++ "/lib/" ++ App ++ "/ebin/"++App++".app",
    case catch file:consult(AppFile) of
	{ok,[Tuple]} ->
	    {value,{modules,Files}} = lists:keysearch(modules,1,element(3,Tuple)),
	    Files;
	{error,enoent} ->
	    %% this can happen for orber if no C++ compiler was found
	    []
    end.

time_now() ->
    T1 = hipe_bifs:get_hrvtime(),
    {time_now,T1}.

time_since({time_now,T1}) ->
    T2 = hipe_bifs:get_hrvtime(),
    T = T2-T1,
    trunc(T).

compile(Flags) ->
    hipe:c(?MODULE,Flags).
