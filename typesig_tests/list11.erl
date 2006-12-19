%%--------------------------------------------------------------
%% Puzzling: Why aren't refined success typings strong enough to
%% discover that the second argument of highest_label/2 is integer() ?
%%
%% Answer: Because the second parameter can be anything during
%% the loop due to the call to label_name/1 and then just before
%% the leaf call turn back to an integer.
%%--------------------------------------------------------------
-module(list11).
-export([highest_label/1]).

-include("list11.hrl").

highest_label(Code) ->
  highest_label(Code, 0).
                                                                                
highest_label([I|Is], Max) ->
  case is_label(I) of
    true ->
      L = label_name(I),
      NewMax = if L > Max -> L; true -> Max end,
      highest_label(Is, NewMax);
    false ->
      highest_label(Is, Max)
  end;
highest_label([], Max) when is_integer(Max) ->
  Max.

is_label(#label{}) -> true;
is_label(_) -> false.

label_name(#label{name=L}) -> L.
