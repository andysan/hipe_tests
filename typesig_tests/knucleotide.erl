-module(knucleotide).
-export([main/0]).

%% turn characters a..z to uppercase and strip out any newline
to_upper_no_nl(Str) -> to_upper_no_nl(Str, []).

to_upper_no_nl([C|Cs], Acc) when C >= $a, C =< $z ->
    to_upper_no_nl(Cs, [C-($a-$A)|Acc]);
to_upper_no_nl([C|Cs], Acc) when C == $\n ->
    to_upper_no_nl(Cs, Acc);
to_upper_no_nl([C|Cs], Acc) -> 
    to_upper_no_nl(Cs, [C|Acc]);
to_upper_no_nl([], Acc) ->
    lists:reverse(Acc).

% Read in lines from stdin and discard them until a line starting with
% >THREE are reached. 
seek_three() ->
    case io:get_line('') of
      ">TH" ++ _ -> found;
       eof       -> erlang:error(eof);
        _        -> seek_three()
    end.
  
%% Read in lines from stdin until eof.
%% Lines are converted to upper case and put into a single list. 
dna_seq() -> seek_three(), dna_seq([]).

dna_seq(Seq) ->
    case io:get_line('') of
        eof  -> list_to_binary(lists:reverse(Seq));
        Line -> Uline = to_upper_no_nl(Line),
                dna_seq([Uline|Seq])
    end.

%% Create a dictionary with the dna sequence as key and the number of
%% times it was in the original sequence as value.
%% Len is the number of base pairs to use as the key.
gen_freq(Dna, Len) ->
    gen_freq(Dna, Len, dict:new(),0,size(Dna)).

gen_freq(<<>>, _, Frequency, Acc, _) ->
    {Frequency, Acc};
gen_freq(Dna, Len, Frequency, Acc, Dec) when Dec >= Len ->
    <<Key:Len/binary, _/binary>> = Dna, 
    Freq = dict:update_counter(Key, 1, Frequency),
    <<_, T/binary>> = Dna,
    gen_freq(T, Len, Freq, Acc+1, Dec-1);
gen_freq(_, _, Frequency, Acc, _) ->
     {Frequency, Acc}.

%% Print the frequency table    
printf({Frequency, Tot}) ->
    printf(lists:reverse(lists:keysort(2,dict:to_list(Frequency))),Tot).

printf([], _) -> 
    io:fwrite("\n");
printf([H|T], Tot)->
    {Nucleoid, Cnt} = H,
    io:fwrite("~s ~.3f\n", [binary_to_list(Nucleoid), (Cnt*100.0)/Tot]),
    printf(T, Tot).

write_count(Dna, Pattern) ->
    {Freq ,_} = gen_freq(Dna, size(Pattern)),
    case dict:find(Pattern,Freq) of
        {ok,Value} -> io:fwrite("~w\t~s\n", [Value, binary_to_list(Pattern)]);
        error      -> io:fwrite("~w\t~s\n", [0, binary_to_list(Pattern)])
    end.

main() ->
    Seq = dna_seq(),
    lists:foreach(fun(H) -> printf(gen_freq(Seq,H)) end, [1,2]),
    lists:foreach(fun(H) -> write_count(Seq,H) end,
		  [<<"GGT">>,<<"GGTA">>,<<"GGTATT">>,
		   <<"GGTATTTTAATT">>,<<"GGTATTTTAATTTATAGT">>]),
    halt(0).

