-module(esmb_client).
%%% --------------------------------------------------------------------
%%% File    : esmb_client.erl
%%% Created : 30 Jan 2004 by Torbjorn Tornkvist <tobbe@bluetail.com>
%%% Purpose : Somewhat similar to Sambas 'smbclient' program
%%%
%%% $Id: esmb_client.erl,v 1.2 2007/08/28 11:39:10 kostis Exp $
%%% --------------------------------------------------------------------
-export([start/2, start/4, astart/2, istart/2, ustart/2]).
-export([swap/3, to_ucs2/3, ucs2_to_charset/2]).

-ifdef(tobbe).
-export([trun/0,ttinit/6]). %%  testing !!
-endif.

-import(esmb, [ucase/1, lcase/1]).

-include("esmb_lib.hrl").


%%%
%%% Example: start("//korp/tobbe", "tobbe").
%%%
start(Path, User) -> istart(Path, User).

astart(Path, User) -> start(Path, User, "WORKGROUP", ?CSET_ASCII).
istart(Path, User) -> start(Path, User, "WORKGROUP", ?CSET_ISO_8859_1).
ustart(Path, User) -> start(Path, User, "WORKGROUP", ?CSET_UTF8).


start(Path, User, Wgroup, Charset) ->
    md4:start(),
    iconv:start(),
    case host_share(Path) of
	{Host, Share} ->
	    spawn(fun() -> init(Host, Share, User, Wgroup, Charset) end);
	Else ->
	    Else
    end.

init(Host, _Share, User, Wgroup, Charset) ->
    put(charset, Charset),
    {ok,S,Neg} = esmb:connect(Host),
    Pw = get_passwd(),
    U = #user{pw = Pw, name = User, primary_domain = Wgroup},
    Pdu0 = esmb:user_logon(S, Neg, U),
    esmb:exit_if_error(Pdu0, "Login failed"),
    WinPath = mk_winpath(Neg, "//"++Host++"/"++User, Charset),
    Path = to_ucs2(Neg, WinPath, Charset),
    Pdu1 = esmb:tree_connect(S, Neg, Pdu0, Path),
    esmb:exit_if_error(Pdu1, "Tree connect failed"),
    shell(S, Neg, {Pdu1, "\\\\"}).


shell(S, Neg, {_Pdu, Cwd} = State) ->
    shell(S, Neg, cmd(read_line(Cwd), S, Neg, State)).

cmd("cat" ++ Cs, S, Neg, State)   -> cat(S, Neg, State, Cs);
cmd("cd" ++ Cs, S, Neg, State)    -> cd(S, Neg, State, Cs);
cmd("get" ++ Cs, S, Neg, State)   -> fetch(S, Neg, State, Cs);
cmd("help", S, Neg, State)        -> help(S, Neg, State);
cmd("ls", S, Neg, State)          -> ls(S, Neg, State);
cmd("mkdir" ++ Cs, S, Neg, State) -> mkdir(S, Neg, State, Cs);
cmd("put" ++ Cs, S, Neg, State)   -> store(S, Neg, State, Cs);
cmd("quit", _S, _Neg, _State)     -> exit(normal);
cmd("rmdir" ++ Cs, S, Neg, State) -> rmdir(S, Neg, State, Cs);
cmd("rm" ++ Cs, S, Neg, State)    -> delete(S, Neg, State, Cs);
cmd("?", S, Neg, State)           -> help(S, Neg, State);
cmd(Cmd, _S, _Neg, State)         -> 
    io:format("Unknown command: ~s~n", [Cmd]),
    State.

help(_S, _Neg, State) ->
    io:format("Commands: '?', cat, cd, get, help, ls, mkdir, quit,"
	      " put, rm, rmdir~n",[]),
    State.

cd(_S, _Neg, {Pdu, Cwd}, Dir0) ->
    {Pdu, cwd(Cwd, rm_space(Dir0))}.

cwd(Cwd, [$.,$.])            -> rm_last_dir(Cwd);
cwd(Cwd, [$.,$.,$/|T])       -> cwd(rm_last_dir(Cwd), T);
cwd(_Cwd, [$/,$/ |_T] = Dir) -> swap(Dir, $/, $\\);
cwd(_Cwd, [$/ |_T] = Dir)    -> swap([$/|Dir], $/, $\\);
cwd(Cwd, Dir)                -> Cwd ++ swap(Dir, $/, $\\).

rm_last_dir(P) ->
    rm_until(tl(lists:reverse(P)), $\\).

%%% Shouldn't reach end of list !
rm_until([C,C] = P, C) -> P;
rm_until([H|_] = P, H) -> lists:reverse(P);
rm_until([_|T], C)     -> rm_until(T, C).

swap([H], H, N)   -> [N];
swap([H|T], H, N) -> [N|swap(T, H, N)];
swap([H|T], C, N) -> [H|swap(T, C, N)];
swap([], _, N)    -> [N].  


cat(S, Neg, State, Fname) ->
    get_file(S, Neg, State, Fname, 
	     fun(B,_F) -> io:format("~s~n", [binary_to_list(B)]) end).

fetch(S, Neg, State, Fname) ->
    get_file(S, Neg, State, Fname, 
	     fun(B, F) -> file:write_file(F,B) end).

get_file(S, Neg, {Pdu0, Cwd}, Fname0, Fun) ->
    Cset = get(charset),
    File = rm_space(Fname0),
    WinPath = mk_winpath(Neg, Cwd ++ slash(Cset) ++ File, Cset),
    Fname = to_ucs2(Neg, WinPath, Cset),
    Pdu1 = esmb:open_file_ro(S, Pdu0, Fname),
    Finfo = #file_info{name = Fname, size = Pdu1#smbpdu.file_size},
    io:format("Reading....~n", []),
    {Time, {ok, Bin}} = timer:tc(esmb, read_file, [S, Pdu1, Finfo]),
    Size = size(Bin),
    io:format("Read ~p bytes (~p bytes/sec)~n", 
	      [Size, Size/(Time/1000000)]),
    Fun(Bin, File),
    Pdu = esmb:close_file(S, Pdu1),
    {Pdu, Cwd}.


store(S, Neg, {Pdu0, Cwd}, Fname0) ->
    Cset = get(charset),
    File = rm_space(Fname0),
    {ok, Bin} = file:read_file(File),
    WinPath = mk_winpath(Neg, Cwd ++ slash(Cset) ++ File, Cset),
    Fname = to_ucs2(Neg, WinPath, Cset),
    Pdu1 = esmb:open_file_rw(S, Pdu0, Fname),
    Finfo = #file_info{name = Fname, data = [Bin]},
    io:format("Writing....~n", []),
    {Time,Res} = timer:tc(esmb, write_file, [S, Neg, Pdu1, Finfo]),
    io:format("Wrote ~p bytes/sec,  res=~p~n", 
	      [size(Bin)/(Time/1000000), Res]),
    Pdu = esmb:close_file(S, Pdu1),
    {Pdu, Cwd}.


mkdir(S, Neg, {Pdu0, Cwd}, Fname0) ->
    Cset = get(charset),
    File = rm_space(Fname0),
    WinPath = mk_winpath(Neg, Cwd ++ slash(Cset) ++ File, Cset),
    Fname = to_ucs2(Neg, WinPath, Cset),
    Pdu1 = esmb:mkdir(S, Pdu0, Fname),
    Pdu = esmb:close_file(S, Pdu1),
    {Pdu, Cwd}.

rmdir(S, Neg, {Pdu0, Cwd}, Dir0) ->
    Cset = get(charset),
    Dir = rm_space(Dir0),
    WinPath = mk_winpath(Neg, Cwd ++ slash(Cset) ++ Dir, Cset),
    Dname = to_ucs2(Neg, WinPath, Cset),
    Pdu = esmb:rmdir(S, Pdu0, Dname),
    {Pdu, Cwd}.

delete(S, Neg, {Pdu0, Cwd}, File0) ->
    Cset = get(charset),
    File = rm_space(File0),
    WinPath = mk_winpath(Neg, Cwd ++ slash(Cset) ++ File, Cset),
    Fname = to_ucs2(Neg, WinPath, Cset),
    Pdu = esmb:delete_file(S, Pdu0, Fname),
    {Pdu, Cwd}.


ls(S, Neg, {Pdu, Cwd} = State) ->
    Cset = get(charset),
    WinPath = mk_winpath(Neg, Cwd, Cset),
    Udir = to_ucs2(Neg, add_wildcard(Neg, Cset, WinPath), Cset),
    Finfo = esmb:list_dir(S, Pdu, Udir),
    print_file_info(Neg, Finfo),
    State.

print_file_info(Neg, L) ->
    F = fun(X) ->
		io:format("~-20s ~-20s SIZE ~-15w IS ~p~n", 
			  [b2l(to_charset(Neg, X#file_info.name)),
			   dt(X#file_info.date_time),
			   X#file_info.size,
			   check_attr(X#file_info.attr)])
	end,
    lists:foreach(F, L).

dt(X) ->
    {Y,M,D} = X#dt.last_access_date,
    {H,I,S} = X#dt.last_access_time,
    i2l(Y) ++ "-" ++ two(M) ++ "-" ++ two(D) ++ " " ++
	two(H) ++ ":" ++ two(I) ++ ":" ++ two(S).

two(I) ->
    case i2l(I) of
	[X] -> [$0,X];
	X   -> X
    end.

i2l(I) when is_integer(I) -> integer_to_list(I);
i2l(L) when is_list(L)    -> L.


check_attr(A) ->
    check_attr(A, [dir,hidden]).

check_attr(A, [dir | T]) when ?IS_DIR(A) ->
    [dir | check_attr(A, T)];
check_attr(A, [hidden | T]) when ?IS_HIDDEN(A) ->
    [hidden | check_attr(A, T)];
check_attr(A, [_ | T])  ->
    check_attr(A, T);
check_attr(_A, [])  ->
    [].


read_line(Cwd) ->
    rm_last_char(io:get_line(list_to_atom(swap(Cwd, $\\, $/) ++ "> "))).

get_passwd() ->
    rm_last_char(io:get_line('Password: ')).

rm_last_char([_])   -> [];
rm_last_char([H|T]) -> [H|rm_last_char(T)].

rm_space([$\s|T]) -> rm_space(T);
rm_space(Cs)      -> Cs.

%%% Extract the Host and Share part
host_share([$\s|T])   -> 
    host_share(T);
host_share("//" ++ T) -> 
    {Host, Share} = eat_until(T, $/),
    {Host, Share}.

eat_until(Cs, X) ->
    eat_until(Cs, X, []).

eat_until([X|_] = Cs, X, Acc) -> {lists:reverse(Acc), Cs};
eat_until([H|T], X, Acc)      -> eat_until(T, X, [H|Acc]).
    
l2b(L) when is_list(L)   -> list_to_binary(L);
l2b(B) when is_binary(B) -> B.

b2l(B) when is_binary(B) -> binary_to_list(B);
b2l(L) when is_list(L)   -> L.

%%%
%%% We are using slash ('/') as a directory separator 
%%% for the HTML link. Since SMB wants backslash ('\') 
%%% the separator, we need to convert to the Win format.
%%%
%%% NB: The slash may be multibyte, depending on the
%%%     character set used by the portal !
%%%
mk_winpath(Neg, Path, Cset) when ?USE_UNICODE(Neg) -> 
    mk_uwinpath(Path, Cset);
mk_winpath(_Neg, Path, _Cset) -> 
    bslash2slash(Path).

bslash2slash([$/|T]) -> [$\\ | bslash2slash(T)];
bslash2slash([H|T])  -> [H | bslash2slash(T)];
bslash2slash([])     -> [].

mk_uwinpath(Path, Cset) ->
    Bslash = backslash(Cset),
    Slash = slash(Cset),
    mk_uwinpath(Path, Bslash, Slash, length(Slash)).

mk_uwinpath([H|T] = Path, Bslash, Slash, Len) ->
    case lists:prefix(Slash, Path) of
	true  -> Bslash ++ mk_uwinpath(eat(Path,Len), Bslash, Slash, Len);
	false -> [H | mk_uwinpath(T, Bslash, Slash, Len)]
    end;
mk_uwinpath([], _, _, _) ->
    [].

eat([_|T], N) when N>0 -> eat(T, N-1);
eat(L, 0)              -> L;
eat([], _)             -> [].

backslash(Cset) ->  get_char(Cset, backslash, "\\").
slash(Cset)     ->  get_char(Cset, slash, "/").
star(Cset)      ->  get_char(Cset, star, "*").

%%% Return an ASCII <character>, represented in <character-set>
get_char(Cset, Cname, Char) ->
    case get({Cname,Cset}) of
	undefined ->
	    C = b2l(ascii_to_charset(Char, Cset)),
	    put({Cname,Cset}, C),
	    C;
	C ->
	    C
end.

%%%
%%% NB: We assume a Win-path here !!
%%%
add_wildcard(Neg, Cset, Path) when ?USE_UNICODE(Neg) ->
    Star = star(Cset),
    Bslash = backslash(Cset),
    case lists:prefix(lists:reverse(Bslash), lists:reverse(Path)) of % ouch...
	true  -> Path ++ Star;
	false -> Path ++ Bslash ++ Star
    end;
add_wildcard(_Neg, _, Path) ->
    case lists:reverse(Path) of
	"\\" ++ _ -> Path ++ "*";
	_         -> Path ++ "\\*"
    end.

%%% -------------------------------------------------------------------- 
%%% Unicode handling
%%% -------------------------------------------------------------------- 


to_ucs2(Neg, Str, Cset) when ?USE_UNICODE(Neg) -> to_ucs2(Str, Cset);
to_ucs2(_, Str, _)                             -> Str.

to_ucs2(Str, Cset) ->
    case iconv:open(?CSET_UCS2LE, esmb:ucase(Cset)) of
	{ok, Cd} ->
	    Rstr = case iconv:conv(Cd, l2b(Str)) of
		       {ok, Ustr}      -> Ustr;
		       {error,_Reason} ->
			   Str
		   end,
	    iconv:close(Cd),
	    Rstr;
	{error,_Reason} ->
	    Str
    end.

to_charset(Neg, Str) ->
    to_charset(Neg, Str, get(charset)).

to_charset(Neg, Ustr, Cset) when ?USE_UNICODE(Neg), is_binary(Ustr)  ->
    ucs2_to_charset(Ustr, Cset);
to_charset(_, Str, _) ->
    Str.

ucs2_to_charset(Ustr, Cset) ->
    case iconv:open(esmb:ucase(Cset), ?CSET_UCS2LE) of
	{ok, Cd} ->
	    case iconv:conv(Cd, Ustr) of
		{ok, Res}       -> Res;
		{error,_Reason} -> 
		    mk_unconv_name(Ustr, Cset)
	    end;
	{error,_Reason} ->
	    mk_unconv_name(Ustr, Cset)
    end.

mk_unconv_name(Ustr, Cset) ->
    Qstr = l2b(string:copies("?", length(b2l(Ustr)) div 2)),
    ascii_to_charset(Qstr, Cset).

ascii_to_charset(Str, Cset) ->
    case iconv:open(esmb:ucase(Cset), ?CSET_ASCII) of
	{ok, Cd} ->
	    case iconv:conv(Cd, Str) of
		{ok, Res}       -> Res;
		{error,_Reason} -> 
		    "" % not much else we can do here...
	    end;
	{error,_Reason} ->
	    "" % not much else we can do here...
    end.


%%%
%%% This test case measures the performance, when retreiving a 20 MB file.
%%% Start it as:
%%%
%%%     erl -pa ../ebin -noshell -s esmb_client trun
%%%
%%% It can be compared with: 
%%%
%%%     time smbclient //pungmes/tobbe <passwd> -U <user> -c 'get 20M.file'
%%% 
%%% To enable this, compile as: 
%%%
%%%     erlc -Dtobbe -o ../ebin esmb_client.erl
%%%
-ifdef(tobbe). 
trun() -> 
    tstart("//pungmes/tobbe", "tobbe", "WORKGROUP", ?CSET_ISO_8859_1, "20M.file").

tstart(Path, User, Wgroup, Charset, Fname) ->
    md4:start(),
    iconv:start(),
    case host_share(Path) of
	{Host, Share} ->
	    spawn(fun() -> tinit(Host, Share, User, Wgroup, Charset, Fname) end);
	Else ->
	    Else
    end.

tinit(Host, Share, User, Wgroup, Charset, Fname) ->
    {Time, {ok, Size}} = timer:tc(esmb_client, ttinit, 
				 [Host, Share, User, Wgroup, Charset, Fname]),
    io:format("Read and Wrote ~p bytes (~p bytes/sec)~n", 
	      [Size, Size/(Time/1000000)]).
    
ttinit(Host, Share, User, Wgroup, Charset, Fname) ->
    put(charset, Charset),
    {ok,S,Neg} = esmb:connect(Host),
    Pw = "qwe123",
    U = #user{pw = Pw, name = User, primary_domain = Wgroup},
    Pdu0 = esmb:user_logon(S, Neg, U),
    esmb:exit_if_error(Pdu0, "Login failed"),
    WinPath = mk_winpath(Neg, "//"++Host++"/"++User, Charset),
    Path = to_ucs2(Neg, WinPath, Charset),
    Pdu1 = esmb:tree_connect(S, Neg, Pdu0, Path),
    esmb:exit_if_error(Pdu1, "Tree connect failed"),
    g20M(S, Neg, {Pdu1, "\\\\"}, Fname).

g20M(S, Neg, State, Fname) ->
    g20get_file(S, Neg, State, Fname, 
	       fun(B, F) -> file:write_file(F,B) end).

g20get_file(S, Neg, {Pdu0, Cwd}, Fname0, Fun) ->
    Cset = get(charset),
    File = rm_space(Fname0),
    WinPath = mk_winpath(Neg, Cwd ++ slash(Cset) ++ File, Cset),
    Fname = to_ucs2(Neg, WinPath, Cset),
    Pdu1 = esmb:open_file_ro(S, Pdu0, Fname),
    Finfo = #file_info{name = Fname, size = Pdu1#smbpdu.file_size},
    {ok, Bin} = esmb:read_file(S, Pdu1, Finfo),
    Fun(Bin, File),
    Pdu = esmb:close_file(S, Pdu1),
    {ok, size(Bin)}.
-endif.
