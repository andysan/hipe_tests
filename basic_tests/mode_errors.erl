%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright (c) 2001 by Erik Johansson.  All Rights Reserved 
%% Time-stamp: <01/04/10 11:12:50 happi>
%% ====================================================================
%%  Filename : 	mode_errors.erl
%%  Module   :	mode_errors
%%  Purpose  :  
%%  Notes    : 
%%  History  :	* 2001-04-07 Erik Johansson (happi@csd.uu.se): 
%%               Created.
%%  CVS      :
%%              $Author: happi $
%%              $Date: 2001/04/10 09:19:48 $
%%              $Revision: 1.1 $
%% ====================================================================
%%  Exports  :
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(mode_errors).
-compile(export_all).

test() ->
  lists:map(fun (T) -> 
		FV = element(2,T),
		Trace = element(2,FV),
		FReason = element(1,FV),
		{FReason, [hd(Trace)]}
		end,
	    [t1n(),  
	     t2n(),
	     t3e(),
	     t4e(),
	     t5n(),
	     t6n(),
	     t7e(),
	     t8e(),
	     annn(),
	     anne(),
	     anen(),
	     anee(),
	     aenn(),
	     aene(),
	     aeen(),
	     aeee()]).

compile(O) ->
  hipe:c({?MODULE,t1n,0},O),
  hipe:c({?MODULE,t2n,0},O),
  hipe:c({?MODULE,t5n,0},O),  
  hipe:c({?MODULE,t6n,0},O),  
  hipe:c({?MODULE,annn,0},O),  
  hipe:c({?MODULE,anne,0},O),  
  hipe:c({?MODULE,anen,0},O),  
  hipe:c({?MODULE,anee,0},O),  
  hipe:c({?MODULE,bnn,0},O),  
  hipe:c({?MODULE,bne,0},O),  
  hipe:c({?MODULE,fn,1},O),  
  hipe:c({?MODULE,cn,1},O).

t1n() -> catch ?MODULE:fe([mud]).
t2n() -> catch ?MODULE:fn([mud]).
t3e() -> catch ?MODULE:fe([mud]).
t4e() -> catch ?MODULE:fn([mud]).

t5n() ->  catch apply(?MODULE, fe, [mud]).
t6n() ->  catch apply(?MODULE, fn, [mud]).
t7e() ->  catch apply(?MODULE, fe, [mud]).
t8e() ->  catch apply(?MODULE, fn, [mud]).

annn() -> catch bnn().
anne() -> catch bne().
anen() -> catch ben().
anee() -> catch bee().
aenn() -> catch bnn().
aene() -> catch bne().
aeen() -> catch ben().
aeee() -> catch bee().

bnn() -> {cn([])}.
bne() -> {ce([])}.
ben() -> {cn([])}.
bee() -> {ce([])}.
 
  
fe(dum) -> ok.
fn(dum) -> ok.

ce(X) ->
  case X of
    dum ->
      ok
  end.
cn(X) ->
  case X of
    dum ->
      ok
  end.
