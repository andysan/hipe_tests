%% ====================================================================
%% Test module for stress-testing the HiPE compiler.
%%
%%  Filename :  hc.erl
%%  Module   :  hc
%%  Purpose  :  Tests whether the HiPE compiler works by compiling and
%%		loading many files from the "otp/lib" directory.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2002/09/11 16:35:23 $
%%    $Revision: 1.3 $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(hc).
-export([test/0,test/1,compile/1]).

-include("excluded.inc").

test() ->
    [%comp1:test(), % test("hipe"),
     test("stdlib"),
     test("compiler"),
     test("kernel"),
     test("tools"),

     test("appmon"),
     test("asn1"),
     test("cosEvent"),
     test("cosEventDomain"),
     test("cosFileTransfer"),
     test("cosNotification"),
     test("cosProperty"),
     test("cosTime"),
     test("cosTransactions"),
     test("debugger"),
     %% test("etk"),
     test("eva"),
     test("gs"),
     test("ic"),
     test("inets"),
     test("megaco"),
     test("mesh"),
     test("mnemosyne"),
     test("mnesia"),
     test("mnesia_session"),
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
    io:format("Compiling ~w\n",[Mod]),
    {ok,Mod} = hipe:c(Mod,get_comp_opts()).

get_comp_opts() ->
    {ok,Tokens,_} = erl_scan:string(os:getenv("HiPE_COMP_OPTS") ++ "."),
    {ok,CompFlags} = erl_parse:parse_term(Tokens),
    CompFlags.

files(App) ->
    AppFile = os:getenv("OTP_DIR") ++ "/lib/" ++ App ++ "/ebin/"++App++".app",
    {ok,[Tuple]} = file:consult(AppFile),
    {value,{modules,Files}} = lists:keysearch(modules,1,element(3,Tuple)),
    Files.


compile(Flags) ->
    hipe:c(?MODULE,Flags).