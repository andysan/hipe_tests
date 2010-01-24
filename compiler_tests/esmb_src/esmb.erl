-module(esmb).
%%% --------------------------------------------------------------------
%%% File    : esmb.erl
%%% Created : 10 Dec 2003 by Torbjorn Tornkvist <tobbe@bluetail.com>
%%% Purpose : Implementation of the NetBIOS/SMB protocol.
%%%
%%% $Id: esmb.erl,v 1.3 2010/01/24 13:12:09 kostis Exp $
%%% --------------------------------------------------------------------
-export([called_name/1, calling_name/1, ucase/1, lcase/1, check_dir/3,
	 connect/1, connect/2, connect/3, close/1, user_logon/3, emsg/3,
	 tree_connect/4, tree_connect/5, list_dir/3, called/1,
	 open_file_ro/3, open_file_rw/3, stream_read_file/3,
	 read_file/3, mkdir/3, rmdir/3, is_ok/2, unicode_p/1,
	 astart/0, istart/0, ustart/0, start/0, to_ucs2_and_null/2,
	 client/2, aclient/2, iclient/2, uclient/2, to_ucs2/2,
	 close_file/2, write_file/4, hexprint/1, b2l/1,
	 delete_file/3, caller/0, named_pipe_transaction/4,
	 named_pipe_transaction/3,
	 exit_if_error/2, list_shares/3, list_shares/5, l/3]).
-export([dec_smb/1, tt_name/1]).
-export([zeros/1,p14/1,s16x/1,s21_lm_session_key/1,ex/2,swab/1,
	 lm_challenge_response/2, nt_challenge_response/2, 
	 lmtest/0, nttest/0, e/2, s2k/1]).

-include("esmb_lib.hrl").


-define(PORT, 139).


start()->
    iconv:start(),
    md4:start().
    


%%%---------------------------------------------------------------------
%%% Interface to esmb_client:start/N
%%% Example, run it as:
%%%
%%%  erl -pa ./ebin -noshell -s esmb astart   % ASCII capable
%%%  erl -pa ./ebin -noshell -s esmb istart   % ISO-8859-1 capable
%%%
%%% or in a utf-8 Xterm (xterm -en utf8):
%%%
%%%  erl -pa ./ebin -noshell -s esmb ustart   % UTF-8 capable
%%% 
%%%---------------------------------------------------------------------
astart() -> aclient("//pungmes/tobbe", "tobbe"). % for testing !!
istart() -> iclient("//pungmes/tobbe", "tobbe"). % for testing !!
ustart() -> uclient("//pungmes/tobbe", "tobbe"). % for testing !!

client(Path, User)  -> iclient(Path, User).

aclient(Path, User) -> esmb_client:astart(Path, User).
iclient(Path, User) -> esmb_client:istart(Path, User).
uclient(Path, User) -> esmb_client:ustart(Path, User).
	    

%%%---------------------------------------------------------------------
%%% Holy cow ! It turns out ugly already from the beginning.
%%% 
%%% "list shares" is using the Lanman Remote API protocol
%%% which runs on top of SMB. So right now we do some
%%% special treatment for just this message.
%%%
%%% See also: <http://www.thursby.com/CIFS/rap/>
%%%
%%%---------------------------------------------------------------------
-define(DOLLAR, [36]).   

l(Host, User, Passwd) ->
    case catch list_shares(Host, User, Passwd) of
	{ok, Res} ->
	    io:format("\n~-15.s ~s~n",["SHARE","TYPE"]),
	    io:format("~s~n",[string:copies("-",30)]),
	    F = fun(X) -> io:format("~-15.s ~s~n",
				   [b2l(X#share_info.name),
				   share_type(X#share_info.type)])
		end,
	    lists:foreach(F, Res),
	    io:nl();
	Else ->
	    Else
    end.

share_type(?SHARETYPE_DISKTREE) -> "Directory tree";
share_type(?SHARETYPE_PRINTQ)   -> "Printer queue";
share_type(?SHARETYPE_DEVICE)   -> "Comm. device";
share_type(?SHARETYPE_IPC)      -> "IPC".
    

%%%
%%% NB: list_shares/N may throw an: {error,#smbpdu} | {error,Else}
%%%
list_shares(Host, User, Passwd) ->
    list_shares(Host, User, Passwd, ?DEFAULT_WORKGROUP, []).

list_shares(Host, User, Passwd, Workgroup, SockOpts) ->
    case connect(Host, SockOpts) of
	{ok,S,Neg} ->
	    U = #user{pw = Passwd, name = User, primary_domain = Workgroup},
	    Pdu0 = user_logon(S, Neg, U),
	    exit_if_error(Pdu0, "Login failed"),
	    %%Path = "\\\\*SMBSERVER\\IPC" ++ [$$], % make the Emacs mode happy...
	    Path = "\\\\" ++ h2s(Host) ++ "\\IPC" ++ [$$], % make the Emacs mode happy...
	    Pdu1 = tree_connect(S, Neg, Pdu0, ipc_path(Neg, Path), ?SERVICE_ANY_TYPE),
	    exit_if_error(Pdu1, "Tree connect failed"),
	    {Req, Pdu2} = smb_list_shares_pdu(Pdu1),
	    decode_list_shares_response(Req, nbss_session_service(S, Pdu2));
	Else ->
	    Else
    end.

h2s({A,B,C,D}) -> 
    lists:flatten(io_lib:format("~w.~w.~w.~w", [A,B,C,D]));
h2s(Host) when is_list(Host) -> 
    Host.

ipc_path(Neg, Path) when ?USE_UNICODE(Neg) ->    
    {ok, Cd}    = iconv:open(?CSET_UCS2, ?CSET_ASCII),
    {ok, Upath} = iconv:conv(Cd, Path),
    iconv:close(Cd),
    Upath;
ipc_path(_Neg, Path) ->    
    Path.


decode_list_shares_response(Req, {ok, _, ResPdu}) ->
    Res = safe_dec_smb(Req, ResPdu),   
    <<_TotParamCount:16/little,
      _TotDataCount:16/little,
      0:16/little,
      _ParamCount:16/little,
      _ParamOffset:16/little,
      _ParamDisplacement:16/little,
      _DataCount:16/little,
      _DataOffset:16/little,
      _DataDisplacement:16/little,
      _SetupCount,
      _/binary>> = Res#smbpdu.wp,
    <<_,                      % what is this ?
      Status:16/little,        % success(0), access_denied(5)
      _Convert:16/little,       
      EntryCount:16/little,    % # of entries returned
      AvailEntries:16/little,  % # of available entries
      Entries/binary>> = Res#smbpdu.bf,
    if (Status == ?SUCCESS) ->
	    warning(EntryCount, AvailEntries, 
		    "<Warning>: Buffer too small to fit all entries !"),
	    {ok, parse_entries(EntryCount, Entries)};
       true ->
	    {error, list_shares}
    end.

parse_entries(0, _) -> 
    [];
parse_entries(N, <<ShareName:13/binary,
		  _CstrNull,
		  ShareType:16/little,
		  _CharPtr:4/binary,
		  Rest/binary>>) -> 
    [#share_info{name = l2b(rm_trailing_nulls(b2l(ShareName))),
		 type = ShareType}|
     parse_entries(N-1, Rest)].

rm_trailing_nulls(Str) ->
    rm_nulls(lists:reverse(Str)).

rm_nulls([0|T]) -> rm_nulls(T);    
rm_nulls(L)     -> lists:reverse(L).
       
warning(X,X,_) -> true;
warning(_,_,S) -> io:format("~s~n", [S]).


%%% --------------------------------------------------------
%%% Named Pipe Transaction
%%% --------------------------------------------------------

named_pipe_transaction(S, InReq, Rpc) when is_binary(Rpc) ->
    Pipe = "\\PIPE\\",
    Path = to_ucs2_and_null(unicode_p(InReq), Pipe),
    named_pipe_transaction(S, InReq, Rpc, Path).

named_pipe_transaction(S, InReq, Rpc, PipeName) 
  when is_binary(PipeName), is_binary(Rpc) ->
    {Req, Pdu} = smb_named_pipe_transaction(InReq, PipeName, Rpc),
    decode_smb_response(Req, nbss_session_service(S, Pdu)).


smb_named_pipe_transaction(InReq, PipeName, Rpc) ->
    {Wc,Wp} = wp_named_pipe(InReq#smbpdu.fid, size(PipeName), size(Rpc)),
    Bf = bf_named_pipe(PipeName),
    Rec = #smbpdu{cmd = ?SMB_COM_TRANSACTION,
		  pid = InReq#smbpdu.pid,
		  uid = InReq#smbpdu.uid,
		  tid = InReq#smbpdu.tid,
		  fid = InReq#smbpdu.fid,
		  flags2 = InReq#smbpdu.flags2,
		  wc  = Wc,
		  wp  = Wp,
		  bc  = size(Bf) + size(Rpc),
		  bf  = Bf},
    B1 = enc_smb(Rec),
    {Rec, <<B1/binary, Rpc/binary>>}.

wp_named_pipe(Fid, NameLen, DataSize) ->
    %% How to compute the offset values (no.of bytes):
    %% ParamOffset = ?SMB_HEADER_LEN + ThisLen + WordCount + ByteCount + Pad + length(TransName)
    %%             = ?SMB_HEADER_LEN + 1 + 16*2 + 2 + 1 + NameLen
    %%             = ?SMB_HEADER_LEN + 36 + NameLen
    %%
    ParamOffset = ?SMB_HEADER_LEN + 36 + NameLen,
    ParamLen    = 0, 
    DataOffset  = ParamOffset + ParamLen,
    ParamCount  = DataOffset - ParamOffset,
    {16,                         % WordCount = 14+2
     <<ParamCount:16/little,     % Total parameter bytes sent
      DataSize:16/little,        % Total data bytes sent
      0:16/little,               % Max parameter bytes to return
      ?MAX_BUFFER_SIZE:16/little,% Max data bytes to return
      0,                         % Max setup words to return
      0,                         % reserved
      0:16/little,               % Flags
      0:32/little,               % timeout , 0 = return immediately
      0:16/little,               % reserved2
      ParamLen:16/little,        % Parameter bytes sent this buffer
      ParamOffset:16/little,     % Offset (from header start) to parameters
      DataSize:16/little,        % Data bytes sent this buffer
      DataOffset:16/little,      % Offset (from header start) to data
      2,                         % Count of setup words
      0,                         % reserved3 (pad above to word boundary)
      ?SUBCMD_TRANSACT_NM_PIPE:16/little,
      Fid:16/little
      >>}.

bf_named_pipe(PipeName) ->
    list_to_binary([0,          % Pad
		    PipeName    % Name of transaction
		    ]).




%%% ---------------------

smb_list_shares_pdu(InReq) ->
    {Wc,Wp} = wp_list_shares(),
    Bf = bf_list_shares("\\PIPE\\LANMAN"),
    Rec = #smbpdu{cmd = ?SMB_COM_TRANSACTION,
		  pid = InReq#smbpdu.pid,
		  uid = InReq#smbpdu.uid,
		  tid = InReq#smbpdu.tid,
		  flags2 = InReq#smbpdu.flags2,
		  wc  = Wc,
		  wp  = Wp,
		  bc  = size(Bf),
		  bf  = Bf},
    {Rec, enc_smb(Rec)}.


wp_list_shares() ->
    %% How to compute the offset values (no.of bytes):
    %% ParamOffset = ?SMB_HEADER_LEN + ThisLen + WordCount + ByteCount + length(TransName) + NullByte
    %%             = ?SMB_HEADER_LEN + 1 + 14*2 + 2 + 12 + 1
    %%             = ?SMB_HEADER_LEN + 44
    %% ParamLen    = <Length of the Lanman RAP block below>
    %% DataOffset  = ParamOffset + ParamLen + NullByte
    %%             = ParamOffset + ParamLen
    ParamOffset = ?SMB_HEADER_LEN + 44,
    ParamLen    = 19, % The Lanman RAP block
    DataOffset  = ParamOffset + ParamLen,
    ParamCount  = DataOffset - ParamOffset,
    {14,                         % WordCount = 14
     <<ParamCount:16/little,     % Total parameter bytes sent
      0:16/little,               % Total data bytes sent
      10:16/little,              % Max parameter bytes to return
      ?MAX_BUFFER_SIZE:16/little,% Max data bytes to return
      0,                         % Max setup words to return
      0,                         % reserved
      0:16/little,               % Flags
      0:32/little,               % timeout , 0 = return immediately
      0:16/little,               % reserved2
      ParamLen:16/little,        % Parameter bytes sent this buffer
      ParamOffset:16/little,     % Offset (from header start) to parameters
      0:16/little,               % Data bytes sent this buffer
      DataOffset:16/little,      % Offset (from header start) to data
      0,                         % Count of setup words
      0                          % reserved3 (pad above to word boundary)
      >>}.

bf_list_shares(TransName) ->
    list_to_binary([TransName,0, % Name of transaction
		    %% --- Start of Parameter Block (19 bytes) ---
		    <<0:16/little>>,% Function Code: NetShareEnum(0)
		    "WrLeh",0,   % Parameter Descriptor
		    "B13BWz",0,  % Return Descriptor
		    <<1:16/little>>, % Detail level
		    <<?MAX_BUFFER_SIZE:16/little>> % Receive buffer size
		    ]).



%%%---------------------------------------------------------------------
%%% Setup a socket, initiate an NBSS session and 
%%% negotiate the protocol dialect.
%%%---------------------------------------------------------------------
connect(Host)           -> connect(Host, []).
connect(Host, SockOpts) -> connect(Host, SockOpts, ?PORT).

connect(Host, SockOpts, Port) ->
    ?dbg("~w(~w): enter connect, Host=~p ~n", [?MODULE, ?LINE, Host]),
    Opts = [binary, {packet, 0}|SockOpts],
    case gen_tcp:connect(Host, Port, Opts) of
	{ok,S} ->
	    case nbss_session_request(S, "*SMBSERVER", caller()) of
		{ok,_} ->
		    {ok, S, negotiate(S)};
		_ ->
		    {error, nbss_session_request}
	    end;
	Else ->
	    Else
    end.

close(S) ->
    gen_tcp:close(S).


-define(LT_BUFSIZE(Neg, Bin), 
	(Neg#smb_negotiate_res.max_buffer_size >= size(Bin))).

write_file(S, Neg, InReq, Finfo) ->
    write_file(S, Neg, InReq, Finfo, list_to_binary(Finfo#file_info.data), 0).

write_file(S, Neg, InReq, Finfo, Bin, Written) when ?LT_BUFSIZE(Neg,Bin) -> 
    {Req, Pdu} = smb_write_andx_pdu(InReq, Finfo, Bin, Written),
    case decode_smb_response(Req, nbss_session_service(S, Pdu)) of
	{ok, Wrote} ->
	    {ok, Wrote + Written};
	_ ->
	    {error, write_file}
    end;
write_file(S, Neg, InReq, Finfo, Bin, Written) ->
    {B1,B2} = split_binary(Bin, Neg#smb_negotiate_res.max_buffer_size - ?HEADER_SIZE),
    case write_file(S, Neg, InReq, Finfo, B1, Written) of
	{ok, Wrote} ->
	    write_file(S, Neg, InReq, Finfo, B2, Wrote);
	_ ->
	    {error, write_file} 
    end.
	

-define(STREAM_READ,  true).
-define(READ_ALL,     false).

%%%
%%% Return the received chunk + a continuation:
%%% 
%%%   ok | {more, Bin, Cont} | {error, Emsg}
%%%
stream_read_file(S, InReq, Finfo) ->
    read_file(S, InReq, Finfo, true, []).

%%%
%%% Return when everything has been received.
%%%
%%%   {ok, Bin} | {error, Emsg}
%%%
read_file(S, InReq, Finfo) ->
    read_file(S, InReq, Finfo, false, []).

-define(READ_ENOUGH(F), (F#file_info.size =< F#file_info.data_len)).
-define(MORE_TO_READ(F), (F#file_info.size > F#file_info.data_len)).

read_file(_S, _InReq, Finfo, ?STREAM_READ, Acc) when ?READ_ENOUGH(Finfo) ->
    {ok, trim_binary(list_to_binary(lists:reverse(Acc)), 
		     Finfo#file_info.data_len - Finfo#file_info.size)};
read_file(_S, _InReq, Finfo, ?READ_ALL, Acc) when ?READ_ENOUGH(Finfo) ->
    {ok, trim_binary(list_to_binary(lists:reverse(Acc)), 
		     Finfo#file_info.size)};
read_file(S, InReq, Finfo, Rtype, Acc) when ?MORE_TO_READ(Finfo) ->
    {Req, Pdu} = smb_read_andx_pdu(InReq, Finfo),
    case decode_smb_response(Req, nbss_session_service(S, Pdu)) of
	{ok, _Res, Data} -> 
	    Dlen = Finfo#file_info.data_len + size(Data),
	    NewFinfo = Finfo#file_info{data_len = Dlen},
	    if (Rtype == ?STREAM_READ) ->
		    Cont = fun() ->
				   read_file(S, 
					     InReq, 
					     NewFinfo,
					     Rtype,
					     Acc)
			   end,
		    {more, Data, Cont};
	        true ->
		    read_file(S, 
			      InReq, 
			      NewFinfo, 
			      Rtype,
			      [Data | Acc])
	    end;
	_ ->
	    {error, decoding_read_andx}
    end.

trim_binary(Bin, Size) when size(Bin) > Size -> 
    element(1, split_binary(Bin, Size));
trim_binary(Bin, _) -> 
    Bin.
    

open_file_ro(S, InReq, Path) ->
    {Req, Pdu} = smb_open_file_ro_pdu(InReq, Path),
    decode_smb_response(Req, nbss_session_service(S, Pdu)).

open_file_rw(S, InReq, Path) ->
    {Req, Pdu} = smb_open_file_rw_pdu(InReq, Path),
    decode_smb_response(Req, nbss_session_service(S, Pdu)).

close_file(S, InReq) ->
    {Req, Pdu} = smb_close_file_pdu(InReq),
    decode_smb_response(Req, nbss_session_service(S, Pdu)).

mkdir(S, InReq, Path) ->
    {Req, Pdu} = smb_open_dir_pdu(InReq, Path),
    decode_smb_response(Req, nbss_session_service(S, Pdu)).

rmdir(S, InReq, Path) ->
    {Req, Pdu} = smb_delete_dir_pdu(InReq, Path),
    decode_smb_response(Req, nbss_session_service(S, Pdu)).
    
delete_file(S, InReq, Path) ->
    {Req, Pdu} = smb_delete_file_pdu(InReq, Path),
    decode_smb_response(Req, nbss_session_service(S, Pdu)).
    

list_dir(S, InReq, Path) ->
    {Req, Pdu} = smb_trans2_find_first2_pdu(InReq, Path),
    dbg_smb("list_dir: got trans2_find_first2", Req),
    case decode_smb_response(Req, nbss_session_service(S, Pdu)) of
	X when X#find_result.eos == true -> 
	    X#find_result.finfo;
	X -> 
	    list_dir_cont(S, Req, Path, X#find_result.sid, X#find_result.finfo)
    end.

list_dir_cont(S, InReq, Path, Sid, Finfo) ->
    {Req, Pdu} = smb_trans2_find_next2_pdu(InReq, Path, Sid),
    case decode_smb_response(Req, nbss_session_service(S, Pdu)) of
	X when X#find_result.eos == true -> 
	    Finfo ++ X#find_result.finfo;
	X -> 
	    list_dir_cont(S, Req, Path, Sid, Finfo ++ X#find_result.finfo)
    end.
    

check_dir(S, InReq, Path) ->
    {Req, Pdu} = smb_check_directory_pdu(InReq, Path),
    decode_smb_response(Req, nbss_session_service(S, Pdu)).

tree_connect(S, Neg, InReq, Path) ->
    tree_connect(S, Neg, InReq, Path, ?SERVICE_DISK_SHARE).

tree_connect(S, Neg, InReq, Path, Service) ->
    {Req, Pdu} = smb_tree_connect_andx_pdu(Neg, InReq, Path, Service),
    decode_smb_response(Req, nbss_session_service(S, Pdu)).

negotiate(S) ->
    ?dbg("~w(~w): enter negotiate~n", [?MODULE, ?LINE]),
    {Req, Pdu} = smb_negotiate_pdu(),
    decode_smb_response(Req, nbss_session_service(S, Pdu)).

user_logon(S, Neg, U) ->
    {Req, Pdu} = smb_session_setup_andx_pdu(Neg, U),
    decode_smb_response(Req, nbss_session_service(S, Pdu)).


dbg_smb(_What, _Res) ->
    ?dbg("~s ---"
	"  Eclass  = ~p"
	"  Ecode   = ~p"
	"  Uid     = ~p"
	"  Tid     = ~p"
	"  Fid     = ~p"
	"  Fsize   = ~p~n",
	[_What,
	 _Res#smbpdu.eclass,
	 _Res#smbpdu.ecode,
	 _Res#smbpdu.uid,
	 _Res#smbpdu.tid,
	 _Res#smbpdu.fid,
	 _Res#smbpdu.file_size
       ]).


%%% --------------------------------------------------------------------
%%% SMB decode routines
%%% --------------------------------------------------------------------

-define(IS(Req,Cmd), (Req#smbpdu.cmd == Cmd) ).
-define(SUB_CMD(Req, SubCmd), (Req#smbpdu.sub_cmd == SubCmd) ).

decode_smb_response(Req, {ok, _, ResPdu}) when  ?IS(Req, ?SMB_NEGOTIATE) ->
    Res = dec_smb(Req, ResPdu),
    <<Di:16/little, B/binary>> = Res#smbpdu.wp,
    case Di of
	?PCNET_1_0 ->
	    #smb_negotiate_res{dialect_index = Di};
	?LANMAN_1_0 ->
	    crypto:start(),
	    lanman_neg_resp(B, Res#smbpdu.bf, 
			    #smb_negotiate_res{dialect_index = Di});
	?NT_LM_0_12 ->
	    crypto:start(),
	    ?dbg("~w(~w): decode_neg_resp, size=~p , Buf=~p~n", 
		   [?MODULE, ?LINE, size(Res#smbpdu.bf), Res#smbpdu.bf]),
	    ntlm_neg_resp(B, Res#smbpdu.bf, 
			  #smb_negotiate_res{dialect_index = Di});
	_ ->
	    exit(nyi)
    end;
decode_smb_response(Req, {ok, _, ResPdu}) when  ?IS(Req, ?SMB_SESSION_SETUP_ANDX) ->
    dec_smb(Req, ResPdu);
decode_smb_response(Req, {ok, _, ResPdu}) when  ?IS(Req, ?SMB_TREE_CONNECT_ANDX) ->
    dec_smb(Req, ResPdu);
decode_smb_response(Req, {ok, _, ResPdu}) when  ?IS(Req, ?SMB_CHECK_DIRECTORY) ->
    dec_smb(Req, ResPdu);
decode_smb_response(Req, {ok, _, ResPdu}) when  ?IS(Req, ?SMB_DELETE_DIRECTORY) ->
    dec_smb(Req, ResPdu);
decode_smb_response(Req, {ok, _, ResPdu}) when  ?IS(Req, ?SMB_DELETE) ->
    dec_smb(Req, ResPdu);
decode_smb_response(Req, {ok, _, ResPdu}) when  ?IS(Req, ?SMB_CLOSE) ->
    dec_smb(Req, ResPdu);
decode_smb_response(Req, {ok, _, ResPdu}) when  ?IS(Req, ?SMB_NT_CREATE_ANDX) ->
    dec_nt_create_andx(Req, ResPdu);
decode_smb_response(Req, {ok, _, ResPdu}) when  ?IS(Req, ?SMB_READ_ANDX) ->
    dec_read_andx(Req, ResPdu);
decode_smb_response(Req, {ok, _, ResPdu}) when  ?IS(Req, ?SMB_WRITE_ANDX) ->
    dec_write_andx(Req, ResPdu);
decode_smb_response(Req, {ok, _, ResPdu}) 
  when  ?IS(Req, ?SMB_COM_TRANSACTION2), 
	?SUB_CMD(Req, ?SMB_TRANS2_FIND_FIRST2) ->
    dec_trans2_find_x2(Req, ResPdu, ?SMB_TRANS2_FIND_FIRST2);
decode_smb_response(Req, {ok, _, ResPdu}) 
  when  ?IS(Req, ?SMB_COM_TRANSACTION2), 
	?SUB_CMD(Req, ?SMB_TRANS2_FIND_NEXT2) ->
    dec_trans2_find_x2(Req, ResPdu, ?SMB_TRANS2_FIND_NEXT2);
decode_smb_response(Req, {ok, _, ResPdu}) when  ?IS(Req, ?SMB_COM_TRANSACTION) ->
    dec_transaction(Req, ResPdu).


lanman_neg_resp(<<SecurityMode:16/little,
		  MaxBufferSize:16/little,
		  _:2/binary,            % Max pending multiplexed requests
		  _:2/binary,            % Max VCs between client and server
		  _:2/binary,            % Raw modes supported
		  _:4/binary,            % Unique token identifying this session
		  _:2/binary,            % Current time at server
		  _:2/binary,            % Current date at server
		  _:2/binary,            % Current time zone at server
		  EncKeyLen:16/little,   % Encryption key length
		  _:2/binary>>,          % reserved
		  B,
		Neg) ->
    <<EncKey:EncKeyLen/binary, _/binary>> = B,
    Neg#smb_negotiate_res{security_mode   = SecurityMode,
			  max_buffer_size = MaxBufferSize,
			  encryption_key  = EncKey}.
    
ntlm_neg_resp(<<SecurityMode,
	      _:2/binary,            % Max pending outstanding requests
	      _:2/binary,            % Max VCs between client and server
	      MaxBufferSize:32/little,
	      _:4/binary,            % Max raw buffer size
	      _:4/binary,            % Unique token identifying this session
	      Cap:32/little,         % Server capabilities
	      _:4/binary,            % System (UTC) time of server (low)
	      _:4/binary,            % System (UTC) time of server (high)
	      _:2/binary,            % Time zone of server (minutes from UTC)
	      EncKeyLen>>,           % Encryption key length
	      B,
	      Neg) ->
    ?dbg("~w(~w): ntlm_neg_resp EncKeyLen=~p~n", 
	   [?MODULE, ?LINE, EncKeyLen]),
    <<EncKey:EncKeyLen/binary, _/binary>> = B,
    Neg#smb_negotiate_res{security_mode    = SecurityMode,
			  max_buffer_size  = MaxBufferSize,
			  srv_capabilities = Cap,
			  encryption_key   = EncKey}.



%%% ---

dec_write_andx(Req, Pdu) -> 
    Res = dec_smb(Req, Pdu),   
    <<?NoAndxCmd,              
    0,                         % reserved
    _:2/binary,                % offset to next command WC
    Count:16/little,           % Number of bytes written
    _:2/binary,                % Remaining (reserved)
    _:4/binary,                % reserved
    _/binary>> = Res#smbpdu.wp,
    {ok, Count}.
    

%%% ---

dec_read_andx(Req, Pdu) -> 
    Res = dec_smb(Req, Pdu),   
    <<?NoAndxCmd,              
    0,                         % reserved
    _:2/binary,                % offset to next command WC
    _:2/binary,                % Remaining (reserved) must be -1
    _DcompactMode:16/little,   % ???
    0:16/little,               % reserved
    DataLength:16/little,      % Number of data bytes
    DataOffset:16/little,      % Offset (from header start) to data
    _:2/binary,                % High 16 bits of number of data bytes if
                               % CAP_LARGE_READEX; else zero
    _/binary>> = Res#smbpdu.wp,
    <<_:DataOffset/binary,Data:DataLength/binary, _/binary>> = Pdu,
    {ok, Res, Data}.
    

%%% ---

dec_nt_create_andx(Req, Pdu) -> 
    Res = dec_smb(Req, Pdu),
    exit_if_error(Res, "dec_nt_create_andx"),
    <<?NoAndxCmd,              
    0,                         % reserved
    _:2/binary,                % offset to next command WC
    _OpLockLevel,              % The oplock level granted
    Fid:16/little,             % The file ID
    _CreateAction:32/little,   % The action taken (1 = file opened)
    _CreationTime:8/binary,    % When file was created
    _LastAccessTime:8/binary,  % When file was accessed
    _LastWriteTime:8/binary,   % When file was last written
    _ChangeTime:8/binary,      % When file was last changed
    _:4/binary,                % The file attributes
    _:8/binary,                % Allocation size
    EOF:8/binary,              % The file size 
    _FileType:16/little,       % 0 = Disk file or directory
    _:2/binary,                % State of IPC device (e.g pipe)
    _Directory,                % Boolean (0 = Not a directory)
    _/binary>> = Res#smbpdu.wp,
    %% NB: The TIME comes in units of 100 nano seconds !!
    %% Gsec = (CreationTime div 10000000) + ?GREG_SEC_0_TO_1601,
    %% GDT = calendar:gregorian_seconds_to_datetime(Gsec),
    %% io:format("CREATION TIME: ~w~n", [GDT]),
    %% Asec = (LastAccessTime div 10000000) + ?GREG_SEC_0_TO_1601,
    %% ADT = calendar:gregorian_seconds_to_datetime(Asec),
    %% io:format("LAST ACCESS TIME: ~w~n", [ADT]),
    %% Wsec = (LastWriteTime div 10000000) + ?GREG_SEC_0_TO_1601,
    %% WDT = calendar:gregorian_seconds_to_datetime(Wsec),
    %% io:format("LAST WRITE TIME: ~w~n", [WDT]),
    %% Csec = (ChangeTime div 10000000) + ?GREG_SEC_0_TO_1601,
    %% CDT = calendar:gregorian_seconds_to_datetime(Csec),
    %%io:format("LAST CHANGE TIME: ~w~n", [CDT]),
    FileSize = large_integer(EOF),
    Res#smbpdu{fid       = Fid,
	       file_size = FileSize}.
    
%%% ---

dec_transaction(Req, Pdu) ->
    Res = safe_dec_smb(Req, Pdu),
    <<_TotParamCount:16/little,
      _TotDataCount:16/little,
      _:16/little,                % reserved
      _ParamCount:16/little,
      _ParamOffset:16/little,
      _ParamDisplacement:16/little,
      _DataCount:16/little,
      DataOffset:16/little,
      _DataDisplacement:16/little,
      SetupCount,
      _/binary>> = Res#smbpdu.wp,
    Bf = Res#smbpdu.bf,
    {_SetupWords, B1} =
	if (SetupCount > 0) ->
		<<Xsw:SetupCount/binary,Xb1/binary>> = Bf,
		{Xsw, Xb1};
	   true ->
		{<<>>, Bf}
	end,
    %% We may have some pad bytes here between the
    %% ByteCount parameter and the actual data.
    %% Strip it off by computing how many bytes
    %% we have upto and including the ByteCount param,
    %% and subtract that from the DataOffset param.
    %% Whatever is left is the number of pad-bytes.
    Pad = DataOffset - 
	(?SMB_HEADER_LEN + 
	 1 +    % WordCount == 1 byte
	 ((Res#smbpdu.wc + SetupCount) * 2) + 
	 2),    % ByteCount == 2 bytes
    Data = if (Pad > 0) ->
		   <<_SS:Pad/binary,Xdata/binary>> = B1,
		   Xdata;
	      true ->
		   B1
	   end,
    {ok, Data}.
    



%%% ---

%%% Detta suger h�st...
-define(RESPONSE_DATA(SubCmd,    
		      Pad,
		      Sid,
		      SearchCount,
		      EndOfSearch,
		      EaErrorOffset,
		      LastNameOffset,
		      Buffer),
	if (SubCmd == ?SMB_TRANS2_FIND_FIRST2) ->
		<<Pad,
		Sid:16/little,            % Search handle
		SearchCount:16/little,    % # of entries returned
		EndOfSearch:16/little,    % Was last entry returned ?
		EaErrorOffset:16/little,  % Offset into EA list if EA error
		LastNameOffset:16/little, % Offset into Data holding the filename
		%%                          of the last entry, if server needs it 
		%%                          to resume search; else 0
		_/binary>> = Buffer;
	   true -> 
		%% SubCmd == ?SMB_TRANS2_FIND_NEXT2
		Sid = 0,
		<<Pad,
		SearchCount:16/little,    % # of entries returned
		EndOfSearch:16/little,    % Was last entry returned ?
		EaErrorOffset:16/little,  % Offset into EA list if EA error
		LastNameOffset:16/little, % Offset into Data holding the filename
		%%                          of the last entry, if server needs it 
		%%                          to resume search; else 0
		_/binary>> = Buffer
	end).
		
dec_trans2_find_x2(Req, Pdu, SubCmd) ->
    Res = safe_dec_smb(Req, Pdu),
    <<_TotParamCount:16/little,
      _TotDataCount:16/little,
      0:16/little,
      ParamCount:16/little,
      _ParamOffset:16/little,
      _ParamDisplacement:16/little,
      _DataCount:16/little,
      DataOffset:16/little,
      _DataDisplacement:16/little,
      _/binary>> = Res#smbpdu.wp,
    %%
    SMBheaderLen = ?SMB_HEADER_LEN,
    _Offset = DataOffset - (SMBheaderLen + (Res#smbpdu.wc * 2) + ParamCount),
    ?RESPONSE_DATA(SubCmd,    
		   _Pad,
		   Sid,
		   SearchCount,
		   EndOfSearch,
		   _EaErrorOffset,
		   _LastNameOffset,
		   Res#smbpdu.bf),
    %%<<_:DataOffset/unit:8, Data/binary>> = Pdu,
    <<_:DataOffset/binary, Data/binary>> = Pdu,
    ?dbg("dec_trans2_find_first2: ~n",[]),
    ?dbg("  Data offset   = ~p~n",[DataOffset]),
    ?dbg("  Search handle = ~p~n",[Sid]),
    ?dbg("  No.of entries = ~p~n",[SearchCount]),
    ?dbg("  EOF search ?  = ~p~n",[EndOfSearch]),
    ?dbg("  LastNameOset  = ~p~n",[LastNameOffset]),
    Finfo = dec_find_file_dir_info(Res, Data, SearchCount),
    %%print_fd_info(Finfo),
    #find_result{sid = Sid, eos = to_bool(EndOfSearch), finfo = Finfo}.

%%% ---

dec_find_file_dir_info(Req, Data, Max) ->
    Ucode = bytes_per_character(Req),
    dec_find_file_dir_info(Data, Ucode, Max, 1).

dec_find_file_dir_info(<<Offset:32/little,    % Offset to next struct
			 _FileIndex:32/little, 
			 CT:8/binary,         % File creation time
			 AT:8/binary,         % File access time
			 WT:8/binary,         % File write time
			 _HT:8/binary,        % File attribute change time
			 Size:8/binary,       % File size
			 _AllocSize:8/binary, % Allocation size
			 Attr:32/little,      % Extended file attributes
			 Len:32/little,       % Length of filename (in bytes)    
			 Filename:Len/binary, 
			 Rest/binary>>,  Ucode, Max, I) when I =< Max ->
    Strip = Offset - (64 + Len),    % Strip off trailing crap...
    F = #file_info{name = Filename,
		   size = large_integer(Size),
		   attr = Attr,
		   date_time = dec_dt_find_file(CT, AT, WT)},
    [F | dec_find_file_dir_info(strip(Strip, Rest), Ucode, Max, I+1)];
dec_find_file_dir_info(_Rest, _Ucode, Max, I) when I > Max ->
    [];
dec_find_file_dir_info(_Rest, _Ucode, _Max, I) ->
    io:format("dec_find_file_dir_info: <ERROR> Missing file info I=~p~n",[I]),
    %%hexprint(b2l(_Rest)),
    [].


strip(Strip, Rest0) when Strip>0, Strip<size(Rest0) ->
    <<_:Strip/binary, Rest/binary>> = Rest0,
    Rest;
strip(_, Rest) ->
    Rest.

bytes_per_character(Pdu) when is_record(Pdu,smbpdu),
			      ?F2_USE_UNICODE(Pdu) -> 
    2;
bytes_per_character(Neg) when is_record(Neg,smb_negotiate_res),
			    ?USE_UNICODE(Neg) ->  
    2;
bytes_per_character(_) -> 
    1.


dec_dt_find_file(CT,AT,WT) ->
    CTime = large_integer(CT),
    ATime = large_integer(AT),
    WTime = large_integer(WT),
    %% NB: The TIME comes in units of 100 nano seconds !!
    Csec = (CTime div 10000000) + ?GREG_SEC_0_TO_1601,
    Asec = (ATime div 10000000) + ?GREG_SEC_0_TO_1601,
    Wsec = (WTime div 10000000) + ?GREG_SEC_0_TO_1601,
    {Xd,Xt} = calendar:gregorian_seconds_to_datetime(Csec),
    {Yd,Yt} = calendar:gregorian_seconds_to_datetime(Asec),
    {Zd,Zt} = calendar:gregorian_seconds_to_datetime(Wsec),
    #dt{creation_date    = Xd,
	creation_time    = Xt,
	last_access_date = Yd,
	last_access_time = Yt,
	last_write_date  = Zd,
	last_write_time  = Zt}.


large_integer(<<LowPart:32/little, HiPart:32/little>>) ->
    if (HiPart == 0) -> LowPart;
       true          -> (HiPart * 16#100000000) + LowPart
    end.


%%% ---    

safe_dec_smb(Req, Pdu) ->
    case catch dec_smb(Req, Pdu) of
	R when R#smbpdu.eclass == ?SUCCESS -> R;
	R when is_record(R,smbpdu)         -> throw({error,R});
	Else                               -> throw({error,{dec_smb,Else}})
    end.


dec_smb(Pdu) ->
    dec_smb(#smbpdu{}, Pdu).

dec_smb(Req, 
	<<16#FF, $S, $M, $B,          % smb-header
	Cmd,
	Eclass, 
	_,                            % zero (not used)
	Ecode:16/little,    
	Flags, 					%
	Flags2:16/little,
	_:12/unit:8,                  % Pad (12 bytes)
	Tid:16/little, 
	Pid:16/little, 
	Uid:16/little,
	Mid:16/little,
	Wc,
	Rest/binary>>) ->
    <<Wp:Wc/binary-unit:16, Bc:16/little, Bf/binary>> = Rest,
    Req#smbpdu{cmd    = Cmd,
	       eclass = Eclass,
	       ecode  = Ecode,
	       flags  = Flags,
	       flags2 = Flags2,
	       tid    = Tid,
	       pid    = Pid,
	       uid    = Uid,
	       mid    = Mid,
	       wc     = Wc,
	       wp     = Wp,
	       bc     = Bc,
	       bf     = Bf}.
    
	
%%% --------------------------------------------------------------------
%%% SMB encode routines
%%% --------------------------------------------------------------------


smb_close_file_pdu(InReq) ->
    {Wc,Wp} = wp_close_file(InReq#smbpdu.fid),
    Rec = #smbpdu{cmd = ?SMB_CLOSE,
		  pid = InReq#smbpdu.pid,
		  uid = InReq#smbpdu.uid,
		  tid = InReq#smbpdu.tid,
		  flags2 = InReq#smbpdu.flags2,
		  wc = Wc,
		  wp = Wp},
    {Rec, enc_smb(Rec)}.

wp_close_file(Fid) ->
    {3,
     <<Fid:16/little,
     0:32/little>>}.     % Time of last write (set by local system)


%%% ---

smb_delete_file_pdu(InReq, Fname) ->
    {Wc,Wp} = wp_delete_file(),
    Bf = bf_delete_file(InReq, Fname),
    Rec = #smbpdu{cmd = ?SMB_DELETE,
		  pid = InReq#smbpdu.pid,
		  uid = InReq#smbpdu.uid,
		  tid = InReq#smbpdu.tid,
		  flags2 = InReq#smbpdu.flags2,
		  wc = Wc,
		  wp = Wp,
		  bc  = size(Bf),
		  bf  = Bf},
    {Rec, enc_smb(Rec)}.

wp_delete_file() ->
    {1,
     <<0:16/little>>}.   % SearchAttributes

bf_delete_file(InReq, Fname) ->
    list_to_binary([?BUF_FMT_ASCII,   % Buffer format
		    Fname, null(InReq)]).      % Filename 

%%% ---

smb_delete_dir_pdu(InReq, Dir) ->
    Bf = bf_delete_directory(InReq, Dir),
    Rec = #smbpdu{cmd = ?SMB_DELETE_DIRECTORY,
		  pid = InReq#smbpdu.pid,
		  uid = InReq#smbpdu.uid,
		  tid = InReq#smbpdu.tid,
		  flags2 = InReq#smbpdu.flags2,
		  bc  = size(Bf),
		  bf  = Bf},
    {Rec, enc_smb(Rec)}.

bf_delete_directory(InReq, Dir) ->
    list_to_binary([?BUF_FMT_ASCII,   % Buffer format
		    Dir, null(InReq)]).        % Dir path

%%% ---

smb_write_andx_pdu(InReq, Finfo, Data, Written) ->
    DataLen = size(Data),
    FileOffset = Finfo#file_info.offset + Written,
    {Wc,Wp} = wp_write_andx(InReq#smbpdu.fid, FileOffset, DataLen),
    Rec = #smbpdu{cmd = ?SMB_WRITE_ANDX,
		  pid = InReq#smbpdu.pid,
		  uid = InReq#smbpdu.uid,
		  tid = InReq#smbpdu.tid,
		  flags2 = InReq#smbpdu.flags2,
		  wc = Wc,
		  wp = Wp,
		  bc = DataLen,
		  bf = Data},  
    {Rec, enc_smb(Rec)}.

wp_write_andx(Fid, FileOffset, Dlen) ->
    Remaining = 0,
    %% How to compute the offset values (no.of bytes):
    %% ParamOffset = ?SMB_HEADER_LEN + ThisLen + WordCount + ByteCount 
    %%             = ?SMB_HEADER_LEN + 1 + 12*2 + 2
    %%             = ?SMB_HEADER_LEN + 27
    Offset = ?SMB_HEADER_LEN + 27,
    {12,                        % (ThisLen)
     <<?NoAndxCmd,              
     0,                         % reserved
     0:16/little,               % offset to next command WC
     Fid:16/little,             % File handle
     FileOffset:32/little,      % Offset in file to begin write
     0:32/little,               % reserved
     0:16/little,               % Write mode: 0 = write through
     Remaining:16/little,       % Bytes remaining to satisfy request
     0:16/little,               % DataLengthHigh, zero if not CAP_LARGE_WRITEX
     Dlen:16/little,            % Number of data bytes in buffer (>=0)
     Offset:16/little>>}.       % Offset to data bytes


%%% ---

smb_read_andx_pdu(InReq, Finfo) ->
    {Wc,Wp} = wp_read_andx(InReq#smbpdu.fid, Finfo#file_info.data_len),
    Rec = #smbpdu{cmd = ?SMB_READ_ANDX,
		  pid = InReq#smbpdu.pid,
		  uid = InReq#smbpdu.uid,
		  tid = InReq#smbpdu.tid,
		  flags2 = InReq#smbpdu.flags2,
		  wc = Wc,
		  wp = Wp},
    {Rec, enc_smb(Rec)}.

wp_read_andx(Fid, Offset) ->
    {10,
     <<?NoAndxCmd,              
     0,                         % reserved
     0:16/little,               % offset to next command WC
     Fid:16/little,             % File handle
     Offset:32/little,          % Offset in file to begin read
     ?MAX_BUFFER_SIZE:16/little,% Max number of bytes to return
     ?MAX_BUFFER_SIZE:16/little,% Reserved for obsolescent requests
     0:32/little,               % High 16 buts of MaxXount if CAP_LARGE READX;
                                % else must be zero
     0:16/little>>}.            % Remaining, obsolescent requests

%%% ---

-record(candx, {
	  type = file,     % file | dir
	  mode = ro}).     % ro | rw
	  

smb_open_file_ro_pdu(InReq, Path) ->
    smb_nt_create_andx_pdu(InReq, Path, #candx{type=file,mode=ro}).

smb_open_file_rw_pdu(InReq, Path) ->
    smb_nt_create_andx_pdu(InReq, Path, #candx{type=file,mode=rw}).

smb_open_dir_pdu(InReq, Path) ->
    smb_nt_create_andx_pdu(InReq, Path, #candx{type=dir}).


smb_nt_create_andx_pdu(InReq, Path, Opts) ->
    {Wc,Wp} = wp_nt_create_andx(sizeof(Path), Opts),
    Bf = bf_nt_create_andx(InReq, Path),
    Rec = #smbpdu{cmd = ?SMB_NT_CREATE_ANDX,
		  pid = InReq#smbpdu.pid,
		  uid = InReq#smbpdu.uid,
		  tid = InReq#smbpdu.tid,
		  flags2 = InReq#smbpdu.flags2,
		  wc = Wc,
		  wp = Wp,
		  bc  = size(Bf),
		  bf  = Bf},
    {Rec, enc_smb(Rec)}.

wp_nt_create_andx(NameLen, Opts) ->
    OpLock = oplock(Opts),
    AccessMask = access_mask(Opts),
    FileAttrs = file_attributes(Opts),
    ShareAccess = share_access(Opts),
    CreateOptions = create_options(Opts),
    CreateDisp = create_dispositions(Opts),
    {24,
     <<?NoAndxCmd,              
      0,                         % reserved
      0:16/little,               % offset to next command WC
      0,                         % reserved
      NameLen:16/little,         % Length of Name[] in bytes
      OpLock:32/little,          % Oplock Flags
      0:32/little,               % RootDirectoryFid
      AccessMask:32/little,      % Desired access
      0:32/little,               % Allocaton size MSW
      0:32/little,               %                LSW (64 bit)
      FileAttrs:32/little,       % File attributes
      ShareAccess:32/little,     % Type of share access
      CreateDisp:32/little,      % Create disposition
      CreateOptions:32/little,   % Create options
      ?SECURITY_IDENTIFICATION:32/little, % Security QOS info (?)
      0>>}.                      % Security tracking mode flag (?)

%%%
%%% When a string is passed in Unicode format, it must be
%%% word-aligned with respect to the beginning of the SMB !!
%%% Should the string not naturally fall on a two-byte boundary,
%%% a null byte of padding will be inserted, and the Unicode
%%% string will begin at the next address.
%%%

bf_nt_create_andx(InReq, Name) when ?F2_USE_UNICODE(InReq) ->
    list_to_binary([0,                   % pad !
		    Name, null(InReq)]); % filename
bf_nt_create_andx(InReq, Name) ->
    list_to_binary([                     % don't pad !
		    Name, null(InReq)]). % filename


oplock(_) -> ?NO_OPLOCK.

access_mask(X) when X#candx.mode == ro -> ?AM_READ;
access_mask(X) when X#candx.mode == rw -> ?AM_READ bor ?AM_WRITE.

file_attributes(X) when X#candx.type == file -> ?FILE_ATTR_NORMAL;
file_attributes(X) when X#candx.type == dir  -> ?FILE_ATTR_DIR.

share_access(X) when X#candx.type == file -> ?FILE_SHARE_READ;
share_access(X) when X#candx.type == dir  -> ?FILE_SHARE_RW.

create_dispositions(X) when X#candx.type == file,
			    X#candx.mode == rw   -> ?FILE_OPEN_IF;
create_dispositions(X) when X#candx.type == file -> ?FILE_OPEN;
create_dispositions(X) when X#candx.type == dir  -> ?FILE_CREATE.

create_options(X) when X#candx.type == file -> ?FILE_OPEN_OPTIONS;
create_options(X) when X#candx.type == dir  -> ?DIR_OPEN_OPTIONS.


%%% ---

smb_trans2_find_next2_pdu(InReq, Path, Sid) ->
    {Wc,Wp} = wp_trans2_find_x2(?SMB_TRANS2_FIND_NEXT2, 
				sizeof(Path), length(null(InReq))),
    Bf = bf_trans2_find_next2(InReq, Path, Sid),
    Rec = #smbpdu{cmd = ?SMB_COM_TRANSACTION2,
		  pid = InReq#smbpdu.pid,
		  uid = InReq#smbpdu.uid,
		  tid = InReq#smbpdu.tid,
		  flags2 = InReq#smbpdu.flags2,
		  wc  = Wc,
		  wp  = Wp,
		  bc  = size(Bf),
		  bf  = Bf,
		  sub_cmd = ?SMB_TRANS2_FIND_NEXT2},
    {Rec, enc_smb(Rec)}.

bf_trans2_find_next2(InReq, Path, Sid) ->
    %% Flags ::= DoNotClose,CloseAtEndOfSearch,ReturnResumeKey,ContinueSearch,NoBackupIntent
    %% ContinueSearch,Resume,CloseAtEOS,
    Flags = <<16#000e:16/little>>,
    list_to_binary([0,           % Must be null
		    0,0,         % Pad to SHORT or LONG
		    %% --- Start of Parameter Block (12 bytes) ---
		    <<Sid:16/little>>, % Search attribute or SID
		    <<512:16/little>>, % Max # of entries returned
		    <<?SMB_FIND_FILE_DIRECTORY_INFO:16/little>>, % What info to return in the result
		    <<0:32/little>>,   % Resume key
		    Flags,             % Flags
		    Path, null(InReq)  % Search pattern
		    ]).

%%% ---

smb_trans2_find_first2_pdu(InReq, Path) ->
    {Wc,Wp} = wp_trans2_find_x2(?SMB_TRANS2_FIND_FIRST2, 
				sizeof(Path), length(null(InReq))),
    Bf = bf_trans2_find_first2(InReq, Path),
    Rec = #smbpdu{cmd = ?SMB_COM_TRANSACTION2,
		  pid = InReq#smbpdu.pid,
		  uid = InReq#smbpdu.uid,
		  tid = InReq#smbpdu.tid,
		  flags2 = InReq#smbpdu.flags2,
		  wc  = Wc,
		  wp  = Wp,
		  bc  = size(Bf),
		  bf  = Bf,
		  sub_cmd = ?SMB_TRANS2_FIND_FIRST2},
    {Rec, enc_smb(Rec)}.


wp_trans2_find_x2(SubCmd, PathLen, NullLen) ->
    %% How to compute the offset values (no.of bytes):
    %% ParamOffset = ?SMB_HEADER_LEN + ThisLen + WordCount + ByteCount + Pad
    %%             = ?SMB_HEADER_LEN + 30 + 1 + 2 + 3
    %%             = ?SMB_HEADER_LEN + 36
    %% ParamLen    = ParameterBytesLen + PathLen + NullByteLen
    %%             = 12 + PathLen + NullByteLen
    %% DataOffset  = ParamOffset + ParamLen
    %%
    ParamOffset = ?SMB_HEADER_LEN + 36,
    ParamLen    = 12 + PathLen + NullLen,
    DataOffset  = ParamOffset + ParamLen,
    ParamCount  = DataOffset - ParamOffset,
    {15,                         % WordCount = 14 + SetupCount
     <<ParamCount:16/little,     % Total parameter bytes sent
      0:16/little,               % Total data bytes sent
      10:16/little,              % Max parameter bytes to return
      1024:16/little,            % Max data bytes to return
      0,                         % Max setup words to return
      0,                         % reserved
      0:16/little,               % Flags
      0:32/little,               % timeout , 0 = return immediately
      0:16/little,               % reserved2
      ParamLen:16/little,        % Parameter bytes sent this buffer
      ParamOffset:16/little,     % Offset (from header start) to parameters
      0:16/little,               % Data bytes sent this buffer
      DataOffset:16/little,      % Offset (from header start) to data
      1,                         % Count of setup words
      0,                         % reserved3 (pad above to word boundary)
      SubCmd:16/little           % Setup words (# = Setup word count)
      >>}.

bf_trans2_find_first2(InReq, Path) ->
    %% Sa ::= Archive,Directory,Volume,System,Hidden,ReadOnly
    %% Include: Hidden, System and Directory in search result
    Sa = <<16#0016:16/little>>,
    %% Flags ::= DoNotClose,CloseAtEndOfSearch,ReturnResumeKey,ContinueSearch,NoBackupIntent
    %% Resume,CloseAtEOS
    Flags = <<16#0006:16/little>>,
    list_to_binary([0,           % Must be null
		    0,0,         % Pad to SHORT or LONG
		    %% --- Start of Parameter Block (12 bytes) ---
		    Sa,          % Search attribute
		    <<512:16/little>>, % Max # of entries returned
		    Flags,       % Flags
		    <<?SMB_FIND_FILE_DIRECTORY_INFO:16/little>>, % What info to return in the result
		    <<0:32/little>>,  % Storage type
		    Path, null(InReq) % Search pattern
		    ]).

sizeof(B) when is_binary(B) -> size(B);
sizeof(L) when is_list(L)   -> length(L).

%%% ---

smb_check_directory_pdu(InReq, Path) ->
    Bf = bf_check_directory(InReq, Path),
    Rec = #smbpdu{cmd = ?SMB_CHECK_DIRECTORY,
		  pid = InReq#smbpdu.pid,
		  uid = InReq#smbpdu.uid,
		  tid = InReq#smbpdu.tid,
		  flags2 = InReq#smbpdu.flags2,
		  bc  = size(Bf),
		  bf  = Bf},
    {Rec, enc_smb(Rec)}.

bf_check_directory(InReq, Path) ->
    list_to_binary([?BUF_FMT_ASCII,      % Buffer format
		    Path, null(InReq)]). % Dir path

%%% ---
    
smb_tree_connect_andx_pdu(Neg, InReq, Path, Service) ->
    {Wc,Wp} = wp_tree_connect_andx(Neg),
    Bf = bf_tree_connect_andx(Neg, Path, Service),
    Rec = #smbpdu{cmd = ?SMB_TREE_CONNECT_ANDX,
		  pid = InReq#smbpdu.pid,
		  uid = InReq#smbpdu.uid,
		  flags2 = flags2(Neg),
		  wc = Wc,
		  wp = Wp,
		  bc  = size(Bf),
		  bf  = Bf},
    {Rec, enc_smb(Rec)}.

wp_tree_connect_andx(_Neg) ->
    {4,
     <<?NoAndxCmd,              
      0,                         % reserved
      0:16/little,               % offset to next command WC
      0:16/little,               % Flags
      1:16/little>>}.            % PasswordLength (incl. NULL)

bf_tree_connect_andx(Neg, Path, Service) ->
    list_to_binary([0,                    % password
		    Path, null(Neg),      % filesystem 
		    Service, 0]).         % service (never in Unicode !)


null(Neg) when is_record(Neg,smb_negotiate_res),
	       ?USE_UNICODE(Neg) -> 
    [0,0];
null(Pdu) when is_record(Pdu,smbpdu),
	       ?F2_USE_UNICODE(Pdu) -> 
    [0,0];
null(_) -> 
    [0].

%%% ---

%%%
%%% If the dialect is earlier than "NTLM 0.12" then the client computes
%%% the response using the "LM session key". If the dialect is "NTLM 0.12"
%%% then the client may compute the response either using the "LM session key",
%%% or the "NT session key", or both. The server may choose to refuse
%%% responses computed using the "LM session key".
%%%
smb_session_setup_andx_pdu(Neg, U) when ?PRE_DOS_LANMAN_2_1(Neg) ->
    {Passwd, PwLen}   = enc_lm_passwd(Neg, U#user.pw),
    {Wc,Wp} = wp_session_setup_andx(Neg, U, PwLen),
    Bf = bf_session_setup_andx(Neg, U, Passwd),
    Rec = #smbpdu{cmd = ?SMB_SESSION_SETUP_ANDX,
		  pid = mypid(),
		  mid = 1,
		  flags2 = flags2(Neg),
		  wc = Wc,
		  wp = Wp,
		  bc  = size(Bf),
		  bf  = Bf},
    {Rec, enc_smb(Rec)};
%%%
smb_session_setup_andx_pdu(Neg, U) when ?NTLM_0_12(Neg),
					?USE_UNICODE(Neg) ->
    {UPasswd, UPwLen} = enc_nt_passwd(Neg, U#user.pw, U#user.charset),
    {Wc,Wp} = wp_session_setup_andx(Neg, U, 0, UPwLen), 
    Bf = bf_session_setup_andx(Neg, U, UPasswd),
    Rec = #smbpdu{cmd = ?SMB_SESSION_SETUP_ANDX,
		  pid = mypid(),
		  mid = 1,
		  flags2 = flags2(Neg),
		  wc = Wc,
		  wp = Wp,
		  bc  = size(Bf),
		  bf  = Bf},
    {Rec, enc_smb(Rec)};
%%%
smb_session_setup_andx_pdu(Neg, U) when ?NTLM_0_12(Neg) ->
    {Passwd, PwLen} = enc_lm_passwd(Neg, U#user.pw),
    {Wc,Wp} = wp_session_setup_andx(Neg, U, PwLen, 0),
    Bf = bf_session_setup_andx(Neg, U, Passwd),
    Rec = #smbpdu{cmd = ?SMB_SESSION_SETUP_ANDX,
		  pid = mypid(),
		  mid = 1,
		  flags2 = flags2(Neg),
		  wc = Wc,
		  wp = Wp,
		  bc  = size(Bf),
		  bf  = Bf},
    {Rec, enc_smb(Rec)}.

flags2(Neg) when ?USE_UNICODE(Neg) -> ?FLAGS2_NTLM;
flags2(_)                          -> ?FLAGS2_LONG_NAMES.

wp_session_setup_andx(_Neg, _U, PwLen) ->
    {10,
     <<?NoAndxCmd,              
      0,                         % reserved
      0:16/little,               % offset to next command WC
      ?MAX_BUFFER_SIZE:16/little,
      ?MaxMpxCount:16/little,   
      ?VcNumber:16/little,
      0:32/little,               % session key
      PwLen:16/little,
      0:32/little>>}.            % reserved
%%%    
wp_session_setup_andx(_Neg, _U, PwLen, UPwLen) ->
    {13,
     <<?NoAndxCmd,              
      0,                         % reserved
      0:16/little,               % offset to next command WC
      ?MAX_BUFFER_SIZE:16/little,
      ?MaxMpxCount:16/little,   
      ?VcNumber:16/little,
      0:32/little,               % session key
      PwLen:16/little,           % ANSI password length
      UPwLen:16/little,          % UNICODE password length
      0:32/little,               % reserved
      ?CAP_UNICODE:32/little>>}. % client capabilities


bf_session_setup_andx(Neg, U, Passwd) when ?USE_UNICODE(Neg) ->
    {ok, Cd}    = iconv:open(?CSET_UCS2, ?CSET_ASCII),
    {ok, Uname} = iconv:conv(Cd, l2b(U#user.name)),
    {ok, Udom}  = iconv:conv(Cd, l2b(U#user.primary_domain)),
    {ok, Unos}  = iconv:conv(Cd, l2b(U#user.native_os)),
    {ok, Ulan}  = iconv:conv(Cd, l2b(U#user.native_lanman)),
    iconv:close(Cd),
    list_to_binary([Passwd,
		    [0],         % if Unicode, pad to even byte boundary
		    Uname,[0,0],
		    Udom,[0,0],
		    Unos,[0,0],
		    Ulan,[0,0]]);
%%%
bf_session_setup_andx(_Neg, U, Passwd) ->
    list_to_binary([Passwd,
		    U#user.name,[0],
		    U#user.primary_domain,[0],
		    U#user.native_os,[0],
		    U#user.native_lanman,[0]]).


-define(USE_ENCRYPTION(Neg), ((Neg#smb_negotiate_res.security_mode 
			       band ?SECMODE_CHALLENGE) > 0) ).

enc_lm_passwd(Neg, Passwd) when ?CORE_PROTOCOL(Neg) ->
    {Passwd, sizeof(Passwd)};
enc_lm_passwd(Neg, Passwd) when ?PRE_DOS_LANMAN_2_1(Neg), 
			     ?USE_ENCRYPTION(Neg) ->
    EncKey = Neg#smb_negotiate_res.encryption_key,
    EncPasswd = lm_challenge_response(Passwd, EncKey),
    {EncPasswd, sizeof(EncPasswd)};
enc_lm_passwd(_Neg, Passwd) ->
    {Passwd, sizeof(Passwd)}.

enc_nt_passwd(Neg, Passwd, Cset) when ?NTLM_0_12(Neg), 
				      ?USE_ENCRYPTION(Neg) ->
    {ok, Cd} = iconv:open(?CSET_UCS2, Cset),
    {ok, UCS2pw} = iconv:conv(Cd, l2b(Passwd)),
    iconv:close(Cd),
    EncKey = Neg#smb_negotiate_res.encryption_key,
    EncPasswd = nt_challenge_response(UCS2pw, EncKey),
    {EncPasswd, sizeof(EncPasswd)};
enc_nt_passwd(_Neg, Passwd, _) ->
    {Passwd, sizeof(Passwd)}.

%%%
%%% TEST LM-SessionKey: 
%%%
%%%  smbclient //pungmes/tobbe -U tobbe -m LANMAN1
%%%
%%%   EncKey = 1cb2c4dc19d52588
%%%
%%%   Passwd = qwe123
%%%
%%%   Response = b6c89e28077ada40648149220da0ca5c9f5aa481a3f88467
%%%
%%% TEST NT-SessionKey: 
%%%
%%%  smbclient //pungmes/tobbe -U tobbe
%%%
%%%   EncKey = 9d5d78803705c22e
%%%
%%%   Passwd = qwe123
%%%
%%%   Response = 75e19308dd287c1905f73e519ee5fd41b4ebaa262ed284f4
%%%

lmtest() ->
    EncKey = <<16#1c,16#b2,16#c4,16#dc,16#19,16#d5,16#25,16#88>>,
    Resp = lm_challenge_response(<<"qwe123">>, EncKey),
    {Resp == lmtest_response(),
     Resp,
     lmtest_response()}.

lmtest_response() ->
    <<16#b6,16#c8,16#9e,16#28,16#07,16#7a,16#da,16#40,16#64,
      16#81,16#49,16#22,16#0d,16#a0,16#ca,16#5c,16#9f,16#5a,
       16#a4,16#81,16#a3,16#f8,16#84,16#67>>.
    
nttest() ->
    EncKey = <<16#9d,16#5d,16#78,16#80,16#37,16#05,16#c2,16#2e>> ,
    {ok, Cd} = iconv:open(?CSET_UCS2, ?CSET_ASCII),
    {ok, UCS2pw} = iconv:conv(Cd, l2b("qwe123")),
    iconv:close(Cd),
    Resp = nt_challenge_response(UCS2pw, EncKey),
    {Resp == nttest_response(),
     Resp,
     nttest_response()}.

nttest_response() ->
    <<16#75,16#e1,16#93,16#08,16#dd,16#28,16#7c,16#19,16#05,
     16#f7,16#3e,16#51,16#9e,16#e5,16#fd,16#41,16#b4,16#eb,
     16#aa,16#26,16#2e,16#d2,16#84,16#f4>>.
    

lm_challenge_response(Passwd, Challenge) when is_binary(Passwd) -> 
    ex(s21_lm_session_key(Passwd), Challenge);
lm_challenge_response(Passwd, Challenge) when is_list(Passwd) -> 
    lm_challenge_response(list_to_binary(Passwd), Challenge).


nt_challenge_response(Passwd, Challenge) when is_binary(Passwd) -> 
    ex(s21_nt_session_key(Passwd), Challenge);
nt_challenge_response(Passwd, Challenge) when is_list(Passwd) -> 
    nt_challenge_response(list_to_binary(Passwd), Challenge).


ex(<<K0:7/binary,K1:7/binary>>, Data) when size(Data) =:= 8 ->
    list_to_binary([e(K0, Data), e(K1, Data)]);
ex(<<K0:7/binary,K1:7/binary,K2:7/binary>>, Data) when size(Data) =:= 8 ->
    list_to_binary([e(K0, Data), e(K1, Data), e(K2, Data)]);
ex(K, D)  ->
    io:format("<FATAL ERROR>: K=~p~nD=~p~n",[K,D]),
    exit("fatal_error").

e(K,D) -> 
    crypto:des_cbc_encrypt(s2k(K), null_vector(), D).

null_vector() -> <<0,0,0,0,0,0,0,0>>.

s21_lm_session_key(Passwd) -> 
    S16X  = s16x(Passwd),
    Zero5 = zeros(5),
    <<S16X/binary, Zero5/binary>>.

s21_nt_session_key(Passwd) -> 
    {ok, S16}  = md4:digest(Passwd),
    Zero5 = zeros(5),
    <<S16/binary, Zero5/binary>>.

%%%
%%% What does this function do ??
%%% According to the CIFS spec we should do
%%% bit reverse on each byte. But instead we
%%% do this...
%%%
%%% See libsmb/smbdes.c str_to_key(Str,Key)
%%%
%%% Here is an explanation from the samba.internals News group:
%%%
%%%   "str_to_key converts a 7 character string (7 bytes, 8 bits 
%%%    per byte, total56 bits) to a DES key (8 bytes, 7 bits per 
%%%    byte, total 56 bits). In an actual DES there is a parity 
%%%    involved in the low order bit but this is not used by smbdes."
%%%
s2k(<<S0,S1,S2,S3,S4,S5,S6>>) ->
    K0 = S0 bsr 1,
    K1 = ((S0 band 16#01) bsl 6) bor (S1 bsr 2),
    K2 = ((S1 band 16#03) bsl 5) bor (S2 bsr 3),
    K3 = ((S2 band 16#07) bsl 4) bor (S3 bsr 4),
    K4 = ((S3 band 16#0F) bsl 3) bor (S4 bsr 5),
    K5 = ((S4 band 16#1F) bsl 2) bor (S5 bsr 6),
    K6 = ((S5 band 16#3F) bsl 1) bor (S6 bsr 7),
    K7 = S6 band 16#7F,
    list_to_binary([X bsl 1 || X <- [K0,K1,K2,K3,K4,K5,K6,K7]]);
s2k(<<B0:7/binary,B1:7/binary>>) ->
    list_to_binary([s2k(B0),s2k(B1)]).

s16x(Passwd) -> 
    ex(p14(Passwd), n8()).

p14(Passwd) when size(Passwd) =< 14 ->
    Upasswd = list_to_binary(ucase(binary_to_list(Passwd))),
    Zeros = zeros(14 - size(Passwd)),
    <<Upasswd/binary, Zeros/binary>>.

n8() -> <<16#4b,16#47,16#53,16#21,16#40,16#23,16#24,16#25>>.

zeros(N) ->
    list_to_binary(zerosN(N)).

zerosN(0)          -> [];
zerosN(N) when N>0 -> [0 | zerosN(N-1)].

%%%
%%% Return a sequence of bytes where each byte
%%% has reversed its bit pattern.
%%%
swab(B) when is_binary(B) -> 
    list_to_binary(swab(binary_to_list(B)));
swab(L) when is_list(L)   -> 
    F = fun(X) -> bit_rev(X) end,
    lists:map(F, L).

bit_rev(N) when N < 256, N >= 0 ->
    <<B0:1,B1:1,B2:1,B3:1,B4:1,B5:1,B6:1,B7:1>> = <<N>> ,
    <<Rev>> = <<B7:1,B6:1,B5:1,B4:1,B3:1,B2:1,B1:1,B0:1>> ,
    Rev.

%%% ---

smb_negotiate_pdu() ->
    Bf = dialects(),
    Rec = #smbpdu{cmd = ?SMB_NEGOTIATE,
		  pid = mypid(),
		  mid = 1,
		  %% Assume "NT LM 0.12" dialect with Unicode !
		  flags2 = ?FLAGS2_NTLM, 
		  bc  = size(Bf),
		  bf  = Bf},
    {Rec, enc_smb(Rec)}.

enc_smb(Pdu) ->
    Cmd    = Pdu#smbpdu.cmd,
    Eclass = Pdu#smbpdu.eclass,
    Ecode  = Pdu#smbpdu.ecode,
    Flags  = Pdu#smbpdu.flags,
    Flags2 = Pdu#smbpdu.flags2,
    Tid    = Pdu#smbpdu.tid,
    Pid    = Pdu#smbpdu.pid,
    Uid    = Pdu#smbpdu.uid,
    Mid    = Pdu#smbpdu.mid,
    Wc     = Pdu#smbpdu.wc,
    Wp     = Pdu#smbpdu.wp,
    Bc     = Pdu#smbpdu.bc,
    Bf     = Pdu#smbpdu.bf,
    <<16#FF, $S, $M, $B,          % smb-header
     Cmd,
     Eclass, 
     0,                           % zero (not used)
     Ecode:16/little,    
     Flags, 
     Flags2:16/little,
     0:12/unit:8,                 % Pad (12 bytes)
     Tid:16/little, 
     Pid:16/little, 
     Uid:16/little,
     Mid:16/little,
     Wc, 
     Wp/binary,
     Bc:16/little, 
     Bf/binary>>. 


%%% See also the header file for dialect index.
dialects() ->
    %%<<?BUF_FMT_DIALECT, <<"PC NETWORK PROGRAM 1.0">>/binary, 0>>.
    %%<<?BUF_FMT_DIALECT, <<"PC NETWORK PROGRAM 1.0">>/binary, 0,
     %% ?BUF_FMT_DIALECT, <<"LANMAN1.0">>/binary, 0>>.
    <<?BUF_FMT_DIALECT, <<"PC NETWORK PROGRAM 1.0">>/binary, 0,
      ?BUF_FMT_DIALECT, <<"LANMAN1.0">>/binary, 0,
      ?BUF_FMT_DIALECT, <<"NT LM 0.12">>/binary, 0>>.

    
mypid() ->
    [_,Pid,_] = string:tokens(pid_to_list(self()),"."),
    list_to_integer(Pid).


%%% --------------------------------------------------------------------
%%% NetBIOS code
%%% --------------------------------------------------------------------

nbss_session_request(S, Called, Calling) ->
    send_recv(S, nbss_session_request_pdu(Called, Calling)).

nbss_session_service(S, SMB_pdu) ->
    send_recv(S, nbss_session_service_pdu(SMB_pdu)).

send_recv(S, Packet) ->
    gen_tcp:send(S, [Packet]),
    recv(S).

recv(S) ->
    receive 
	{tcp,S,Bin} ->
	    case dec_msg(Bin) of
		{ok, ?SESSION_KEEP_ALIVE} ->
		    recv(S);
		Else ->
		    Else
	    end
    end.

dec_msg(<<?POSITIVE_SESSION_RESPONSE,_Flags,_Length:16>>) ->
    {ok, ?POSITIVE_SESSION_RESPONSE};
dec_msg(<<?SESSION_SERVICE, _, Length:16, SMB_pdu/binary>>) ->
    {ok, ?SESSION_SERVICE, get_more(Length, sizeof(SMB_pdu), [SMB_pdu])};
dec_msg(<<?SESSION_KEEP_ALIVE, _/binary>>) ->
    {ok, ?SESSION_KEEP_ALIVE};
dec_msg(<<?NEGATIVE_SESSION_RESPONSE,_Flags,_Length:16,Ecode>>) ->
    _Emsg =  neg_sess_resp(Ecode),
    ?dbg("~w(~w): Got NEGATIVE_SESSION_RESPONSE: ~s~n",
	   [?MODULE, ?LINE, _Emsg]),
    {error, neg_sess_resp(Ecode)};
dec_msg(Bin) ->
    ?dbg("~w(~w): nbs_session_resp Got: ~p~n",[?MODULE, ?LINE, Bin]),
    {error, Bin}.

get_more(Expected, Got, Bins) when Got < Expected ->
    receive 
	{tcp,_,Bin} ->
	    get_more(Expected, Got + size(Bin), [Bin | Bins])
    end;
get_more(_, _, Bins) ->
    list_to_binary(lists:reverse(Bins)).

neg_sess_resp(16#80) -> "Not listening on called name";
neg_sess_resp(16#81) -> "Not listening for calling name";
neg_sess_resp(16#82) -> "Called name not present";
neg_sess_resp(16#83) -> "Called name present, but insufficient resources";
neg_sess_resp(16#8F) -> "Unspecified error";
neg_sess_resp(_)     -> "Unknown error code".


nbss_session_request_pdu(Called, Calling) ->
    CalledName = called_name(Called),
    CallingName = calling_name(Calling) ,
    Length = size(CalledName) + size(CallingName),
    <<?SESSION_REQUEST, 0, Length:16, CalledName/binary, CallingName/binary>>.

nbss_session_service_pdu(SMB_pdu) when is_binary(SMB_pdu) ->
    Length = size(SMB_pdu),
    <<?SESSION_SERVICE, 0, Length:16, SMB_pdu/binary>>.


%%% The NetBIOS naming convention allows for 16 character in a 
%%% NetBIOS name. Microsoft, however, limits NetBIOS names to 15
%%% characters and uses the 16th character as a NetBIOS suffix in
%%% order to identify functionality installed on the registered device.

-define(NETBIOS_NAME_LEN, 15).
-define(NETBIOS_SX_WORKSTATION,   16#00).  % Workstation service
-define(NETBIOS_SX_FILESERVER,    16#20).  % File server service

called_name({_,_,_,_} = IP) -> called_name(ip2str(IP));
called_name(Name) when length(Name) =< ?NETBIOS_NAME_LEN -> 
    nb_name(Name, ?NETBIOS_SX_FILESERVER).

calling_name({_,_,_,_} = IP) -> calling_name(ip2str(IP));
calling_name(Name) when length(Name) =< ?NETBIOS_NAME_LEN -> 
    nb_name(Name, ?NETBIOS_SX_WORKSTATION).

nb_name(Name, Sx) ->
    Len = 32,
    list_to_binary([Len | l1enc(Name, Sx, 0)]).

%%% test routine
tt_name(Name) ->
    l1enc(Name, $A, 0).

-define(SPACE, 16#20).

l1enc([H|T], Sx, N) when N < ?NETBIOS_NAME_LEN ->
    [l1msn(H),l1lsn(H)|l1enc(T, Sx, N+1)];
l1enc([], Sx, N) when N < ?NETBIOS_NAME_LEN ->
    [l1msn(?SPACE),l1lsn(?SPACE)|l1enc([], Sx, N+1)];
l1enc([], Sx, ?NETBIOS_NAME_LEN) ->
    [l1msn(Sx),l1lsn(Sx),0].

%%% Level 1 encoding, get most significant nibble
l1msn(B) -> (B bsr 4) + $A.

%%% Level 1 encoding, get least significant nibble
l1lsn(B) -> (B band 16#0F) + $A.


ucase([C|Cs]) when C>=$a,C=<$z -> [C-32|ucase(Cs)]; % a-z
ucase([C|Cs])                  -> [C|ucase(Cs)];
ucase([])                      -> [].

lcase([C|Cs]) when C>=$A,C=<$Z -> [C+32|lcase(Cs)]; % A-Z
lcase([C|Cs])                  -> [C|lcase(Cs)];
lcase([])                      -> [].

to_bool(0) -> false;
to_bool(_) -> true.

hexprint(L) ->
    F = fun(H, Acc) ->
		io:format("~c~s",[Acc,i2x(H)]),
		$,
	end,
    lists:foldl(F, $[, L),
    io:format("]~n",[]).

i2x(I) when I > 15 -> [x(I div 16),x(I rem 16)];
i2x(I)	           -> [$0,x(I)].

x(X) when X>=0,X=<9 -> X + $0;
x(10) -> $a;
x(11) -> $b;
x(12) -> $c;
x(13) -> $d;
x(14) -> $e;
x(15) -> $f.


%%%
%%% Error messages
%%%

is_ok(Pdu,_DefaultEmsg) when Pdu#smbpdu.eclass == ?SUCCESS -> ok;
is_ok(Pdu, DefaultEmsg) when is_record(Pdu, smbpdu) ->
    {error, emsg(Pdu#smbpdu.eclass, Pdu#smbpdu.ecode, DefaultEmsg)}.

emsg(Eclass, Ecode, DefaultEmsg) ->
    case catch emsg(Eclass, Ecode) of
	{'EXIT', _} -> DefaultEmsg;
	Emsg        -> Emsg
    end.

%%% See p.118 in CIFS/1.0 doc.
emsg(?ERRDOS, ?ERRbadfunc)  -> "Invalid function";
emsg(?ERRDOS, ?ERRbadfile)  -> "File not found";
emsg(?ERRDOS, ?ERRbadpath)  -> "Directory invalid";
emsg(?ERRDOS, ?ERRnofids)   -> "Too many open files";
emsg(?ERRDOS, ?ERRnoaccess) -> "Access denied".

caller() ->
    {ok, Host} = inet:gethostname(),
    ucase(Host).

called({A,B,C,D}) ->
    lists:flatten(io_lib:format("~w.~w.~w.~w", [A,B,C,D]));
called(Host) when is_list(Host) ->
    ucase(Host).

exit_if_error(Pdu, _Dmsg) when Pdu#smbpdu.eclass == ?SUCCESS -> true;
exit_if_error(Pdu, Dmsg) ->
    Emsg = emsg(Pdu#smbpdu.eclass, Pdu#smbpdu.ecode, Dmsg),
    throw({error, Emsg}).

l2b(L) when is_list(L)   -> list_to_binary(L);
l2b(B) when is_binary(B) -> B.

b2l(B) when is_binary(B) -> binary_to_list(B);
b2l(L) when is_list(L)   -> L.


ip2str({A,B,C,D}) -> 
    lists:flatten(io_lib:format("~w.~w.~w.~w",[A,B,C,D]));
ip2str(L) when is_list(L) -> 
    L.

to_ucs2_and_null(UnicodeP, Str) ->
    B = to_ucs2(UnicodeP, Str),
    N = null2(UnicodeP),
    <<B/binary,N/binary>>.

to_ucs2(UnicodeP, Str) when UnicodeP == true ->    
    {ok, Cd}    = iconv:open(?CSET_UCS2, ?CSET_ASCII),
    {ok, Ustr} = iconv:conv(Cd, Str),
    iconv:close(Cd),
    Ustr;
to_ucs2(_, Str) ->    
    Str.

null2(UnicodeP) when UnicodeP == true -> <<0,0>>;
null2(_)                              -> <<0>>.


unicode_p(Neg) when is_record(Neg,smb_negotiate_res),?USE_UNICODE(Neg) -> true;
unicode_p(Pdu) when is_record(Pdu,smbpdu),?F2_USE_UNICODE(Pdu)         -> true; 
unicode_p(_)                                                           -> false.

