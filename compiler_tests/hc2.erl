%% ====================================================================
%% Test module for stress-testing the HiPE compiler.
%%
%%  Filename :  hc2.erl
%%  Module   :  hc2
%%  Purpose  :  Tests whether the HiPE compiler works by compiling and
%%		loading many files from the "otp/lib" directory.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2002/03/20 14:06:36 $
%%    $Revision: 1.2 $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(hc2).
-export([test/0,test/1,compile/1]).

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

excluded("stdlib") ->
    [dets_v9, sofs];  % TEMPORARILY
excluded("kernel") ->
    [erl_prim_loader, erlang, error_handler, group,
     init, otp_ring0, prim_file, prim_inet];
excluded("megaco") ->
    [megaco_text_parser]; % times out
excluded("cosNotification") ->
    [oe_CosEvent]; % no such file
excluded("etk") ->
    [tk, etk_menu, tkbutton, tkentry, tklistbox, tkmenu, tkscale, tkscrlbar,
     tktext, tkconsole, tkdialog, tkfocus, tkoptmenu, tktearoff
    ]; % bump in beam_disasm for some reason
excluded(_) ->
    [].

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
