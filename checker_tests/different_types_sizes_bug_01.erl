%% -*- erlang-indent-level: 2 -*-

%% @author Daniel Luna <luna@update.uu.se>
%% @copyright 2008 Daniel Luna
%% 
%% @doc 
%% 

-module(different_types_sizes_bug_01).
-export([test/0]).

test() ->
  case {atom, atom} of
    {atom, atom} -> ok
  end.

%%  catch code_server:a().
