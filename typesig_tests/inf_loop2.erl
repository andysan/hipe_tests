%%======================================================================
%% Another test program (taken from snmp/src/compiler/snmpc.erl) that
%% used to send the analysis into an infinite loop
%%======================================================================
-module(inf_loop2).
-export([define_cols/4]).

-record(mc_object_type, {name,name_assign}).

define_cols(Rest, Index, [], _) when is_integer(Index) ->
    Rest;
define_cols([#mc_object_type{name        = NameOfCol,
			     name_assign = SubIndex}|Rest],
	    SubIndex2, [{NameOfCol,_Type2}|Fields], NameOfEntry) ->
    case SubIndex of
	{Parent,[_SI]} when Parent =/= NameOfEntry ->
	    false;
	{NameOfEntry,[SI]} when SI =/= SubIndex ->
	    false;
	{NameOfEntry,[SubIndex]} ->  %% Infinite loop due to the bug here
	    ok
    end,
    define_cols(Rest,SubIndex2+1,Fields,NameOfEntry).
