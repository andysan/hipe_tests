-module(list7).
-export([read_entity_body/6]).

read_entity_body(_SocketType, _Socket, _Timeout, _Max, 0, _BodyPart) ->
    {ok, []};
read_entity_body(_,_,_,_, Len, BodyPart) when Len == length(BodyPart) ->
    {ok, BodyPart}.
%read_entity_body(_, _, _, _, Len, BodyPart) when Len < length(BodyPart) ->
%    {ok, lists:sublist(BodyPart,Len)}.

