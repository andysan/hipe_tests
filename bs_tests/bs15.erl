%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright (c) 2001 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <01/06/13 10:43:09 happi>
%% ====================================================================
%%  Filename : 	bs5.erl
%%  Module   :	bs5
%%  Purpose  :  
%%  Notes    : 
%%  History  :	* 2001-06-13 Erik Johansson (happi@csd.uu.se): 
%%               Created.
%%  CVS      :
%%              $Author: pergu $
%%              $Date: 2003/11/05 14:28:37 $
%%              $Revision: 1.1 $
%% ====================================================================
%%  Exports  :
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(bs15).
-export([test/0,compile/1]).

compile(O) ->
  hipe:c(?MODULE,O).

test() ->
N1=18,
A1=2, 
A1=match1(N1,<<1:12, 2:N1, A1:2>>),   
A1=match2(N1,<<1:12, 2:N1/integer-little, A1:2>>),   
N3=3,
A3= <<1,2,3>>, 
B3=2,
{A3,B3}=match3(N3,<<1:12, A3:N3/binary, B3:4>>),
N4=12,
B4= <<1,2,3>>, 
A4=2,
{A4,B4}=match4(N4,<<1:N4, A4:4, B4/binary>>),
ok.
   
match1(N, Bin) ->
<<1:12, 2:N, A:2>>=Bin,
A.

match2(N, Bin) ->
<<1:12, 2:N/integer-little, A:2>>=Bin,
A.

match3(N, Bin) ->
<<1:12, A:N/binary, B:4>>=Bin,
{A,B}.

match4(N, Bin) ->
<<1:N, A:4, B/binary>>=Bin,
{A,B}.
