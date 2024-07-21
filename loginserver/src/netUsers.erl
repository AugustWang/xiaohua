%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(netUsers).

%% add by wenziyong for gen server
-behaviour(gen_server).
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-import(messageBase, [read_string/1, read_int/1,  read_int8/1,  read_int16/1, write_array/2,
                         write_string/1, write_int/1,  write_int8/1,  write_int16/1, write_int64/1,read_array/2, sendPackage/3] ).
%-record(state, {socket, addr}).
-record(state, {socket}).
-define(TIMEOUT, 120000).


%%
%% Include files
%%
-include("db.hrl").
-include("userDefine.hrl").
-include("pc_LS2User.hrl").
-include("hdlt_logger.hrl").
-include("condition_compile.hrl").
-include("globalDef.hrl").


%%
%% Exported Functions
%%
-compile(export_all).
start_link(Socket) ->
	gen_server:start_link(?MODULE, [Socket], [{timeout,?Start_Link_TimeOut_ms}]).



init([Socket]) ->
	%inet:setopts(Socket, ?TCP_OPTIONS),
	initUser( Socket ),
    %{ok, {IP, _Port}} = inet:peername(Socket),
    %{ok, #state{socket=Socket, addr=IP}}.
    {ok, #state{socket=Socket}}.

handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.



terminate(_Reason, #state{socket=Socket}) ->
    (catch gen_tcp:close(Socket)),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.






%%make原子，sameple: makeAtom( "socket", 1 )->socket1
makeAtom( PreName, Value ) ->
	StringValue = io_lib:format( "~p", [Value] ),
	StringValue2 = lists:flatten(StringValue),
	String = PreName ++ StringValue2,
	list_to_atom( String ).


%% %%开始面向用户的网络监听
%% beginNetUsers( Port )->
%% 	?DEBUG_OUT( "beginNetUsers start listen port:~p", [Port] ),
%% 
%% 	%%建立全局用户Socket表
%% 	TableGlobalUserSocket = ets:new( 'globalUserSocket', [protected, { keypos, #globalUserSocket.socket }] ),
%% 	put( "GlobalUseSocketTable", TableGlobalUserSocket ),
%% 	db:changeFiled(globalMain, ?GlobalMainID, #globalMain.globalUserSocket, TableGlobalUserSocket),
%% 
%% 	%%建立全局已登录用户表
%% 	TableGlobalLoginUser = ets:new( 'globalLoginUser', [protected, { keypos, #globalLoginUser.userID }] ),
%% 	put( "TableGlobalLoginUser", TableGlobalLoginUser ),
%% 	db:changeFiled(globalMain, ?GlobalMainID, #globalMain.globalLoginUserTable, TableGlobalLoginUser),
%% 
%% 	case gen_tcp:listen(Port, ?TCP_OPTIONS ) of
%%         {ok, ListenSock} ->
%%            	PID = proc_lib:spawn( ?MODULE, procAccetpNetUsers, [ListenSock] ),
%% 			?DEBUG_OUT( "beginNetUsers spawn acceptNetUsers PID[~p] ", [PID] );
%%         {error, Reson} ->
%%             ?ERROR_OUT( "beginNetUsers listen error ~p", [Reson] )
%%     end,
%% 	
%% 	ok.

%%面向用户监听的进程
%% procAccetpNetUsers( ListenSock )->
%% 	register( netUsers_Accept_PID, self() ),
%% 	
%% 	proc_lib:init_ack(self()),
%% 	acceptNetUsers( ListenSock ),
%% 	
%% 	unregister( netUsers_Accept_PID ),
%% 	?DEBUG_OUT( "procAccetpNetUsers return." ),
%% 	ok.

%%面向用户监听的socket接收函数
%% acceptNetUsers( ListenSock )->
%%    case gen_tcp:accept(ListenSock) of
%%         {ok, NewSocket} ->
%% 			PID = proc_lib:spawn( ?MODULE, procUser, [NewSocket] ),
%% 			gen_tcp:controlling_process(NewSocket, PID),	
%% 			acceptNetUsers(ListenSock);
%%         {error,closed} ->
%%             ?DEBUG_OUT( "acceptNetUsers closed" );
%% 		_ ->
%% 			?ERROR_OUT( "acceptNetUsers" )
%%     end,
%% 	ok.

%% modified by wenziyong, to support gen_server
%%每一个User的Socket进程
%procUser( UserSocket )->
initUser( UserSocket )->
	case inet:peername(UserSocket) of
		{ok, {IP, Port}}->
			{A,B,C,D}=IP,
			IPString=integer_to_list(A)++"."++integer_to_list(B)++"."++integer_to_list(C)++"."++integer_to_list(D),
			?LOG_OUT( "initUser self[~p] Socket[~p] IP[~p] Port[~p]",
					  [self(), UserSocket, IPString, Port] ),
			
			put( "UserIP", IPString ),
			
			ok;
		_->put( "UserIP", "0.0.0.0" ), ok
	end,

	%%当前进程可直接访问socket
	put( "UserSocket", UserSocket ),
	
	put( "NextRecvPackCount", 0 ),
	put( "NextSendPackCount", 0 ),

	%%建立socketData表
	TableUserSocket = ets:new( 'userSocketTable', [protected, { keypos, #userSocketRecord.socket }] ),
	Rand = random:uniform(),
	RandString = io_lib:format( "~w", [Rand] ),
	RandString2 = lists:flatten(RandString),

	etsBaseFunc:insertRecord( TableUserSocket, #userSocketRecord{socket=UserSocket, userName="", userID = 0, randIdentity = RandString2, ip=""} ),
	
	%%当前进程可直接访问socket表
	put( "TableUserSocket", TableUserSocket ),
	%%当前Socket是否已经通过验证
	put( "IsSocketCheckPass", false ),
	
	put( "UserID", 0 ),
	put( "UserState", ?UserState_UnCheckPass ),
	put( "GlobalUseSocketTable", main:getGlobalUseSocketTable() ),
	put( "TableGlobalLoginUser", main:getGlobalLoginUserTable() ),
	
	%%通知主进程，有用户连接进入
	main_PID ! { acceptedUserSocket, UserSocket },
	
	%proc_lib:init_ack(self()),
	
	%% 发送初始化消息
	sendInitMsg(),
		
	?DEBUG_OUT( "accept user socket[~p] userPID[~p] socketTable[~p]", [getCurUserSocket(), self(), getCurUserSocketTable()] ),
	%common:beginTryCatchFunc( netUsers, receiveUser, UserSocket, netUsers, receiveUser_ExceptionFunc ),

	%?DEBUG_OUT("procUser process exited socket[~p]", [getCurUserSocket()]),
	ok.

%% modified by wenziyong, to support gen_server
%%每一个User的recieve
handle_info(Info, StateData)->	
	put( "receiveUser", true ),

	try
	case Info of
   	{tcp,UserSocket,Data}->
%%         	Data1 = binary_to_list(Data),
			inet:setopts(UserSocket,[{active,once}]),
			doMsg(UserSocket,Data);
	{ dbLoginResult, #userDBLoginResult{}=UserDBLoginResult }->
		userHandle:on_dbLoginResult( UserDBLoginResult ),
		ok;
	{ kickOutUserComplete }->
		userHandle:onMsgKickOutUserComplete(),
		ok;
	 { gameServerClosed, ServerID }->
		 userHandle:on_gameServerClosed( ServerID ),
		 ok;
	 { gameServer_QueryUserMaxLevelResult, ServerID, MaxPlayerLevel }->
		 userHandle:on_gameServer_QueryUserMaxLevelResult( ServerID, MaxPlayerLevel ),
		 ok;
	 { onGS2LS_UserReadyLoginResult, ServerID, Msg }->
		 userHandle:on_GS2LS_UserReadyLoginResult( ServerID, Msg );
	 { timeOut_WaitUserAskGameServerList }->
		 userHandle:on_timeOut_WaitUserAskGameServerList();
	 {tcp_error, _Socket, Reason}->
		 ?ERROR_OUT( "user socket[~p] closed reson[~p]", [getCurUserSocket(), Reason] ),
		 doUserOffline( 0 ),
		 put( "receiveUser", false );
     {tcp_closed,_Socket}->
		 ?LOG_OUT( "user socket[~p] closed ", [getCurUserSocket()] ),
		 doUserOffline( 0 ),
		 put( "receiveUser", false )
	end,
	case get( "receiveUser" ) of
		%true->receiveUser( UserSocket );
		%false->ok
		true->{noreply, StateData};
		false->{stop, normal, StateData}
	end
	
	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:netUser ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[_Why, erlang:get_stacktrace()] ),
	
			doUserOffline( 0 ),
			{stop, normal, StateData}
	end.

%%user下线处理
doUserOffline( Reson )->
	userHandle:onUserOffline(),
	%%通知主进程，用户连接断开
	main_PID ! { closedUserSocket, getCurUserSocket() },
	?LOG_OUT( "doUserOffline self[~p] socket[~p] userid[~p] Reson[~p]", 
			  [self(), getCurUserSocket(), getCurUserID(), Reson] ),
	ok.

%% receiveUser_ExceptionFunc()->
%% 	?ERROR_OUT( "netUsers:receiveUser_ExceptionFunc" ),
%% 	doUserOffline( 0 ).
%% 	

doMsg(_S, <<>>) ->
	ok;

doMsg(S, Data) ->
	{Len,Count1} = common:binary_read_int16(0,Data),
	{CmdGet, Count2} = common:binary_read_int16(Count1,Data),
	
	RecvPackCount = ( CmdGet band 16#F800 ) bsr 11,
	Cmd = ( CmdGet band 16#7FF ),
	
	NextRecvPackCount = get( "NextRecvPackCount" ),
	case RecvPackCount =:= NextRecvPackCount of
		true->ok;
		false->
			?ERROR_OUT( "user:~p Cmd[~p] RecvPackCount[~p] =/= NextRecvPackCount[~p]",
						[Cmd, RecvPackCount, NextRecvPackCount] )
	end,
	
	case NextRecvPackCount + 1 > 31 of
		true->put( "NextRecvPackCount", 0 );
		false->put( "NextRecvPackCount", NextRecvPackCount + 1 )
	end,
	
	
	{_,<<Data1/binary>>} = split_binary(Data,Count1+Count2),
	%%检查是否第一个消息是CMD_Login
	case get( "IsSocketCheckPass" ) of
		true->ok;
		false->
			case Cmd of
				?CMD_U2LS_Login_553->ok;
				?CMD_U2LS_Login_PP->ok;
				?CMD_U2LS_Login_APPS->ok;
				?CMD_U2LS_Login_360->ok;
				?CMD_U2LS_Login_UC->ok;
				?CMD_U2LS_Login_91->ok;
				_->
					?LOG_OUT( "recve socket[~p] Cmd[~p] not check pass", [getCurUserSocket(), Cmd] ),
					throw ( {'Error Cmd', Cmd} )
			end,
			ok
	end,

	msg_LS2User:dealMsg(S, Cmd, Data1),
	
	Len2 = binary:referenced_byte_size(Data) - Len,
	if Len2 > 0 ->
		{_,<<Data2/binary>>} = split_binary(Data,Len),
		doMsg(S, Data2);
	true ->
		ok
	end.

%%------------------------------------------------cur proc get------------------------------------------------
%%返回当前进程的UserSocket
getCurUserSocket()->
	UserSocket = get( "UserSocket" ),
	case UserSocket of
		undefined->0;
		_->UserSocket
	end.

getCurUserIP()->
	get( "UserIP" ).


%%返回当前进程的UserSocketTable
getCurUserSocketTable()->
	TableUserSocket = get( "TableUserSocket" ),
	case TableUserSocket of
		undefined->0;
		_->TableUserSocket
	end.

%%返回当前进程的userid
getCurUserID()->
	UserID = get( "UserID" ),
	case UserID of
		undefined->0;
		_->UserID
	end.

getCurUserState()->
	UserState = get( "UserState" ),
	case UserState of
		undefined->0;
		_->UserState
	end.	
setCurUserState( UserState )->
	OldState = get( "UserState" ),
	?LOG_OUT( "user socket[~p] ~p change state old ~p new ~p", [getCurUserSocket(), getCurUserID(), OldState, UserState] ),
	put( "UserState", UserState ).

getCurUserSocketRecord()->
	SocketTable = getCurUserSocketTable(),
	case SocketTable of
		0->{};
		_->etsBaseFunc:readRecord( getCurUserSocketTable(), getCurUserSocket() )
	end.
	

send( Msg )->
	msg_LS2User:send( getCurUserSocket(), Msg ).

%% 给客户端发送初始化消息
sendInitMsg()->
	LSID=main:getLoginServerID(),
	Socket=getCurUserSocket(),
	
	msg_LS2User:send(Socket,#pk_LS2U_ServerInfo{lsid=LSID,client_ip=get("UserIP")}),
	ok.
	

