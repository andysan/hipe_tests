%% ====================================================================
%% Test module for stress-testing the HiPE compiler.
%%
%%  Filename :  hc.erl
%%  Module   :  hc
%%  Purpose  :  Tests whether the HiPE compiler works by compiling and
%%		loading many files from the "otp/lib" directory.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2003/10/14 12:09:17 $
%%    $Revision: 1.7 $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(hc).
-export([test/0,test/1,compile/1]).

-include("excluded.inc").

test() ->
    [
     test("hipe"), % generate native code for the HiPE compiler
     test("hipe"), % use this native code to compile the HiPE compiler
     test("stdlib"),
     test("compiler"),
     test("kernel"),
     test("tools"),

     test("appmon"),
     test("asn1"),
     test("cosEvent"),
     test("cosEventDomain"),
     %% test("cosFileTransfer"),
     test("cosNotification"),
     test("cosProperty"),
     test("cosTime"),
     test("cosTransactions"),
     test("debugger"),
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
    Opts = get_comp_opts(),
    [ hc_mod(Mod,Opts) || Mod <- files(Application) -- excluded(Application) ],
    {ok,Application}.

hc_mod(Mod,Opts) ->
    io:format("Compiling ~w ...",[Mod]),
    T0 = time_now(),
    Res = hipe:c(Mod,Opts),
    T = time_since(T0) / 1000,
    io:format(" done in ~.2f secs\n",[T]),
    {ok,Mod} = Res.

get_comp_opts() ->
    {ok,Tokens,_} = erl_scan:string(os:getenv("HiPE_COMP_OPTS") ++ "."),
    {ok,CompFlags} = erl_parse:parse_term(Tokens),
    CompFlags.

files(App) ->
    AppFile = os:getenv("OTP_DIR") ++ "/lib/" ++ App ++ "/ebin/"++App++".app",
    {ok,[Tuple]} = file:consult(AppFile),
    {value,{modules,Files}} = lists:keysearch(modules,1,element(3,Tuple)),
    Files.

time_now() ->
    T1 = hipe_bifs:get_hrvtime(),
    {time_now,T1}.

time_since({time_now,T1}) ->
    T2 = hipe_bifs:get_hrvtime(),
    T = T2-T1,
    trunc(T).

compile(Options) ->
    hipe:c(?MODULE,Options).
