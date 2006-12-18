%%--------------------------------------------------------------
%% Puzzling: Why aren't refined success typings strong enough to
%% discover that the second argument of highest_label/2 is integer() ?
%%--------------------------------------------------------------
-module(list11).
-export([highest_label/1]).

highest_label(Code) ->
  highest_label(Code, 0).
                                                                                
highest_label([I|Is], Max) ->
  case foo:is_label(I) of
    true ->
      L = foo:label_name(I),
      NewMax = if L > Max -> L; true -> Max end,
      highest_label(Is, NewMax);
    false ->
      highest_label(Is, Max)
  end;
highest_label([], Max) when is_integer(Max) ->
  Max.
