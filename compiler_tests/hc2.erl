%% ====================================================================
%% Test module for stress-testing the HiPE compiler.
%%
%%  Filename :  hc2.erl
%%  Module   :  hc2
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

-module(hc2).
-export([test/0,test/1,compile/1]).

-include("excluded.inc").

test() ->
    [
     test("appmon"),
     test("asn1"),
     test("cosEvent"),
     test("cosEventDomain"),
     test("cosFileTransfer"),
     test("cosNotification"),
     test("cosProperty"),
     test("cosTime"),
     test("cosTransactions"),
     test("debugger")
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
