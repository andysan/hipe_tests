%% ====================================================================
%% Test module for stress-testing the HiPE compiler.
%%
%%  Filename :  hc.erl
%%  Purpose  :  Tests whether the HiPE compiler works by compiling and
%%		loading many files from the "otp/lib" directory.
%% CVS:
%%    $Author: kostis $
%%    $Date: 2003/11/03 20:33:04 $
%%    $Revision: 1.10 $
%% ====================================================================
%% Exported functions (short description):
%%  test()         - execute the test.
%%  compile(Flags) - Compile to native code with compiler flags Flags.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(hc).
-export([test/0,test/1,compile/1]).

-include("excluded.inc").

test() ->
    H1 = test("hipe"), % generate native code for the HiPE compiler
    CS = hipe_bifs:constants_size(),
    H2 = test("hipe"), % use this native code to compile the HiPE compiler
    %% test that there is no space leak in the constants pool area
    CS = hipe_bifs:constants_size(),
    R = [H1,
	 H2,
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
	],
    S = hipe_bifs:constants_size(),
    io:format("%%======================== Size of constants area: ~w\n", [S]),
    R.

test(Application) ->
    S1 = hipe_bifs:constants_size(),
    Delim = "========================",
    io:format("%%"++Delim++" Compiling "++Application++" "++Delim++"\n"),
    Opts = get_comp_opts(),
    [ hc_mod(Mod,Opts) || Mod <- files(Application) -- excluded(Application) ],
    S2 = hipe_bifs:constants_size(),
    io:format("%%=== Compiled "++Application++
	      ": size of constants area grew by ~w words\n",[S2-S1]),
    {ok,Application}.

hc_mod(Mod,Opts) ->
    S1 = hipe_bifs:constants_size(),
    io:format("Compiling ~w ...",[Mod]),
    T0 = time_now(),
    Res = hipe:c(Mod,Opts),
    T = time_since(T0) / 1000,
    S2 = hipe_bifs:constants_size(),
    io:format(" done in ~.2f secs (~w words)\n",[T,S2-S1]),
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
