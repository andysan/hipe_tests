%%%----------------------------------------------------------------------
%%% File    : esmb_app.erl
%%% Author  : tobbe@bluetail.com
%%% Purpose : esmb handling
%%% Created : 6 Apr 2004
%%%
%%% $Id: esmb_app.erl,v 1.1 2004/11/15 17:40:46 kostis Exp $
%%%----------------------------------------------------------------------
-module(esmb_app).

-behaviour(application).

%% application callbacks
-export([start/2, stop/1]).

%%%----------------------------------------------------------------------
%%% Callback functions from application
%%%----------------------------------------------------------------------

%%----------------------------------------------------------------------
%% Func: start/2
%% Returns: {ok, Pid}        |
%%          {ok, Pid, State} |
%%          {error, Reason}   
%%----------------------------------------------------------------------
start(_Type, _StartArgs) ->
    case esmb_sup:start_link() of
	{ok, Pid} -> 
	    {ok, Pid};
	Error ->
	    Error
    end.

%%----------------------------------------------------------------------
%% Func: stop/1
%% Returns: any 
%%----------------------------------------------------------------------
stop(_State) ->
    ok.

%%%----------------------------------------------------------------------
%%% Internal functions
%%%----------------------------------------------------------------------