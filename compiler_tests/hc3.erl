%% ====================================================================
%% Test module for stress-testing the HiPE compiler.
%%
%%  Filename :  hc3.erl
%%  Module   :  hc3
%%  Purpose  :  Tests whether the HiPE compiler works by compiling and
%%		loading many files from the "otp/lib" directory.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2002/03/15 17:19:06 $
%%    $Revision: 1.2 $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(hc3).
-export([test/0,test/1,compile/1]).

test() ->
    [
     test("eva"),
     test("gs"),
     test("ic"),
     test("inets"),
     test("megaco"),
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

excluded("stdlib") ->
    [sofs];  % TEMPORARILY
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
    {ok,Mod} = hipe:c(Mod).

files(App) ->
    AppFile = os:getenv("OTP_DIR") ++ "/lib/" ++ App ++ "/ebin/"++App++".app",
    {ok,[Tuple]} = file:consult(AppFile),
    {value,{modules,Files}} = lists:keysearch(modules,1,element(3,Tuple)),
    Files.


compile(Flags) ->
    hipe:c(?MODULE,Flags).
