%% -*- erlang-indent-level: 2 -*-

%% @author Daniel Luna <luna@update.uu.se>
%% @copyright 2008 Daniel Luna
%% 
%% @doc 
%% 

-module(code_server_bug_01).
-export([test/0]).

test() ->
  catch code_server:a().
