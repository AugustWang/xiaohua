%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(gameServer).

%% add by wenziyong for gen server
-behaviour(gen_server).
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-record(state, {socket, addr}).
-define(TIMEOUT, 120000).



%%
%% Include files
%%
-include("db.hrl").
-include("userDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("gameServerDefine.hrl").
-include("condition_compile.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include_lib("stdlib/include/qlc.hrl").
-include("logindb.hrl").
-include("platformDefine.hrl").
-include("globalDef.hrl").


%%
%% Exported Functions
%%
-compile(export_all).

%-define(TCP_OPTIONS, [binary, {packet, 0}, {active, false} ] ). 
start_link(Socket) ->
	gen_server:start_link(?MODULE, [Socket], [{timeout,?Start_Link_TimeOut_ms}]).



init([Socket]) ->
	inet:setopts(Socket, ?TCP_OPTIONS),
	initGameServer( Socket ),

	case inet:peername(Socket) of
		{ok, {IP, _Port}}->ok;
		_->IP="0.0.0.0"
	end,
    {ok, #state{socket=Socket, addr=IP}}.

handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.



terminate(_Reason, #state{socket=Socket}) ->
    (catch gen_tcp:close(Socket)),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.





%% init( Port )->
%% 	loadGameServerSetup(),
%% 	beginNetGameServers( Port ),
%% 	
%% 	ok.
%% 
%% loadGameServerSetup()->
%% 	try
%% 		ok
%% 	catch
%% 		_->ok
%% 	end.

%%开始面向游戏服务器的网络监听
%% beginNetGameServers( Port )->
%% 	?DEBUG_OUT( "procAccetpGameServers start listen port:~p", [Port] ),
%% 
%% 	case gen_tcp:listen(Port, ?TCP_OPTIONS ) of
%%         {ok, ListenSock} ->
%%            	PID = proc_lib:spawn( ?MODULE, procAccetpGameServers, [ListenSock] ),
%% 			?DEBUG_OUT( "procAccetpGameServers spawn procAccetpGameServers PID[~p] ", [PID] );
%%         {error, Reson} ->
%%             ?ERROR_OUT( "procAccetpGameServers listen error ~p", [Reson] )
%%     end,
%% 	
%% 	ok.

%%面向游戏服务器监听的进程
%% procAccetpGameServers( ListenSock )->
%% 	register( netGameServers_Accept_PID, self() ),
%% 	
%% 	proc_lib:init_ack(self()),
%% 	acceptNetGameServers( ListenSock ),
%% 	
%% 	unregister( netGameServers_Accept_PID ),
%% 	?DEBUG_OUT( "procAccetpGameServers return." ),
%% 	ok.

%%面向游戏服务器监听的socket接收函数
%% acceptNetGameServers( ListenSock )->
%%    case gen_tcp:accept(ListenSock) of
%%         {ok, NewSocket} ->
%% 			PID = proc_lib:spawn( ?MODULE, procGameServer, [NewSocket] ),
%% 			gen_tcp:controlling_process(NewSocket, PID),	
%% 			acceptNetGameServers(ListenSock);
%%         {error,closed} ->
%%             ?DEBUG_OUT( "acceptNetGameServers closed" );
%% 		_ ->
%% 			?ERROR_OUT( "acceptNetGameServers" )
%%     end,
%% 	ok.

%% modified by wenziyong, to support gen_server
%%每一个游戏服务器的Socket进程
%procGameServer( Socket )->
initGameServer( Socket )->
	%%当前进程可直接访问socket
	put( "GameServerSocket", Socket ),

	%%当前Socket是否已经通过验证
	put( "IsSocketCheckPass", false ),
	
	put( "ServerID", 0 ),
	put( "ServerState", ?GameServer_State_UnCheckPass ),
	
	%%建立gameServerUsers表
	GameServerUsers = ets:new( 'gameServerUsers', [protected, { keypos, #gameServerUsers.userID }] ),
	put( "GameServerUsersTable", GameServerUsers ),

	%proc_lib:init_ack(self()),
	
	?LOG_OUT( "accept gameServer socket[~p] gameServerPID[~p] ", [Socket, self()] ),
	%common:beginTryCatchFunc( gameServer, receiveGameServer, Socket, gameServer, receiveLoginServer_Exception ),

	%?DEBUG_OUT("procGameServer process exited socket[~p]", [Socket]),
	ok.

%% modified by wenziyong, to support gen_server
%%每一个游戏服务器的recieve
%receiveGameServer( Socket )->
handle_info(Info, StateData)->	
	put( "receiveGameServer", true ),
	try
	case Info of
   	{tcp,Socket,Data}->
%%         	Data1 = binary_to_list(Data),
			inet:setopts(Socket,[{active,once}]),
			case catch doMsg(Socket,Data) of  
			{'EXIT', What} ->	
				?LOG_OUT( "gameserver socket[~p] doMsg error[~p]", [getCurGameServerSocket(), What] ),
				doGameServerSocketClose( 0 ),
				put( "receiveGameServer", false );
				%throw ( {'EXIT', What} );
			_ ->  
			    ok
			end;
	{dbLoginResult, #userDBLoginResult{}=UserDBLoginResult }->
		userHandle:on_dbLoginResult( UserDBLoginResult ),
		ok;
	{kickOutUserComplete }->
		userHandle:onMsgKickOutUserComplete(),
		ok;
	{tcp_error, _Socket, Reason}->
		?ERROR_OUT( "gameserver socket[~p] closed reson[~p]", [getCurGameServerSocket(), Reason] ),
		doGameServerSocketClose( 0 ),
		put( "receiveGameServer", false );
	{tcp_closed,_Socket}->
		?LOG_OUT( "gameserver socket[~p] closed ", [getCurGameServerSocket()] ),
		doGameServerSocketClose( 0 ),
		put( "receiveGameServer", false )
	end,

	case get( "receiveGameServer" ) of
		%true->receiveGameServer( Socket );
		%false->ok
		true->{noreply, StateData};
		false->{stop, normal, StateData}
	end
	
	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:netUser ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[_Why, erlang:get_stacktrace()] ),
			doGameServerSocketClose(0),
			{stop, normal, StateData}
	end.

receiveGameServer_Exception()->
	?ERROR_OUT("receiveGameServer_Exception").

%%GameServer断线处理
doGameServerSocketClose( Reson )->
	%%通知所有在该服务器上的玩家
	Q = ets:fun2ms( fun(#gameServerUsers{userID=UserID} = _Record ) -> UserID end),
	AllUserList = ets:select(getGameServerUsersTable(), Q),

	MyFunc = fun( Record )->
		User = main:getGlobalLoginUser( Record ),
		case User of
			{}->ok;
			_->
				ToMainMsg = #pk_GS2LS_UserLogoutGameServer{userID=User#globalLoginUser.userID,identity=User#globalLoginUser.randIdentity},
				main_PID ! { gS2LS_UserLogoutGameServer, ToMainMsg, getCurGameServerID() }
		end
	end,

	lists:map( MyFunc, AllUserList ),

	db:changeFiled( gameServerRecord, getCurGameServerID(), #gameServerRecord.state, ?GameServer_State_Closed ),
	db:changeFiled( gameServerRecord, getCurGameServerID(), #gameServerRecord.socket, 0 ),
	
	%% 检查此服务器是否存在数据库中  不存在增加此记录
	Serverid = getCurGameServerID(),
	case Serverid of
		0->ok;
		_->
			GameServer = gameServer:getGameServerRecord( Serverid ),
			IsExist = loginMysqlProc:isGSConfigExistById(Serverid ),
			case IsExist of
				false ->
					GSConfig1 = #gsConfig{serverID = GameServer#gameServerRecord.serverID, 
										  name = GameServer#gameServerRecord.name, 
										  isnew = GameServer#gameServerRecord.isnew, 
										  begintime = GameServer#gameServerRecord.begintime, 
										  recommend = GameServer#gameServerRecord.remmond, 
										  hot = GameServer#gameServerRecord.hot},
					loginMysqlProc:insert_gsConfig(GSConfig1),
					ok;
				true ->
					GSConfigUpdate = #gsConfigUpdate{name = GameServer#gameServerRecord.name, 
													 isnew = GameServer#gameServerRecord.isnew, 
													 begintime = GameServer#gameServerRecord.begintime,  
													 recommend = GameServer#gameServerRecord.remmond, 
													 hot = GameServer#gameServerRecord.hot, 
													 serverID = GameServer#gameServerRecord.serverID },
					loginMysqlProc:update_gsConfig(GSConfigUpdate),
					ok
			end
		end,
	
	

	timer:sleep( 5*1000 ),
	%%通知主进程，GameServer连接断开
	%main_PID ! { closedGameServerSocket, getCurGameServerID() },
	?DEBUG_OUT( "doGameServerSocketClose socket[~p] Reson[~p]", [getCurGameServerSocket(), Reson] ),
	ok.

doMsg(_S, <<>>) ->
	ok;

doMsg(S, Data) ->
	{Len,Count1} = common:binary_read_int16(0,Data),
	{CmdGet, Count2} = common:binary_read_int16(Count1,Data),
	Cmd = ( CmdGet band 16#7FF ),
	{_,<<Data1/binary>>} = split_binary(Data,Count1+Count2),
	%%检查是否第一个消息是CMD_Login
	case get( "IsSocketCheckPass" ) of
		true->ok;
		false->
			case Cmd of
				?CMD_GS2LS_Request_Login->ok;
				_->
					?LOG_OUT( "recve socket[~p] Cmd[~p] not check pass", [getCurGameServerSocket(), Cmd] ),
					throw ( {'Error Cmd', Cmd} )
			end,
			ok
	end,
	msg_LS2GS:dealMsg(S, Cmd, Data1),
	Len2 = binary:referenced_byte_size(Data) - Len,
	if Len2 > 0 ->
		{_,<<Data2/binary>>} = split_binary(Data,Len), 
		doMsg(S,Data2);
	true ->
		ok
	end.



%%------------------------------------------------cur proc get------------------------------------------------
%%返回当前进程的GameServerSocket
getCurGameServerSocket()->
	GameServerSocket = get( "GameServerSocket" ),
	case GameServerSocket of
		undefined->0;
		_->GameServerSocket
	end.

%%返回当前进程的GameServerRecord
getCurGameServerRecord()->
	List = db:readRecord( gameServerRecord, getCurGameServerID() ),
	case List of
		[]->{};
		[R|_]->R
	end.

%%返回当前进程的serverid
getCurGameServerID()->
	ServerID = get( "ServerID" ),
	case ServerID of
		undefined->0;
		_->ServerID
	end.

getCurGameServerState()->
	ServerState = get( "ServerState" ),
	case ServerState of
		undefined->0;
		_->ServerState
	end.	
setCurGameServerState( State )->
	db:changeFiled( gameServerRecord, getCurGameServerID(), #gameServerRecord.state, State ),
	put( "ServerState", State ).

getGameServerUsersTable()->
	GameServerUsersTable = get( "GameServerUsersTable" ),
	case GameServerUsersTable of
		undefined->0;
		_->GameServerUsersTable
	end.	

getCurGameServerLog()->
	GameServer = getCurGameServerRecord(),
	case GameServer of
		{}->"";
		_->
			String = io_lib:format( "GameServer ~p Name ~p", [GameServer#gameServerRecord.serverID, GameServer#gameServerRecord.name] ),
			String2 = lists:flatten(String),
			String2
	end.


getGameServerRecord( ServerID )->
	GameServerTableList = db:matchObject( gameServerRecord, #gameServerRecord{serverID=ServerID,_='_'} ),
	case GameServerTableList of
		[]->{};
		[R|_]->R
	end.

isGameServerStateRunning( ServerID )->
	GameServerRecord = getGameServerRecord( ServerID ),
	case GameServerRecord of
		{}->false;
		_->
			case GameServerRecord#gameServerRecord.state =:= ?GameServer_State_Running of
					true->true;
					false->false
			end
	end.


getAllGameServerList()->
	db:matchObject( gameServerRecord, #gameServerRecord{_='_'} ).
	
getAllRunningGameServerList()->
	db:matchObject( gameServerRecord, #gameServerRecord{_='_', state=?GameServer_State_Running} ).

getAllUnRunningGameServerList()->
	%%Q = qlc:q([X || X <- mnesia:table(gameServerRecord),X#gameServerRecord.state =/=?GameServer_State_Running,X#gameServerRecord.hot =/=?GameServer_User_State_Set_Closed]),
	Q = qlc:q([X || X <- mnesia:table(gameServerRecord),X#gameServerRecord.state =/=?GameServer_State_Running]),
    Fun = fun() -> qlc:e(Q) end,
    case mnesia:transaction(Fun) of
		{atomic, Result} ->
			Result;
		_ ->
		  []
    end.

getAllSetClosdGameServerList()->
	db:matchObject( gameServerRecord, #gameServerRecord{_='_', hot=?GameServer_User_State_Set_Closed} ).

getAllRunningGameServerIDList()->
	ServerList = getAllRunningGameServerList(),
	lists:map( fun(Record)-> Record#gameServerRecord.serverID end, ServerList ).

sendToCurGameServer( Msg )->
	msg_LS2GS:send(getCurGameServerSocket(), Msg).

sendToGameServer( #gameServerRecord{}=GameServer, Msg )->
	case GameServer#gameServerRecord.socket =:= 0 of
		true->
			?LOG_OUT( "sendToGameServer server[~p] Msg[~p] socket=0", [GameServer#gameServerRecord.serverID, Msg] );
		false->
			msg_LS2GS:send(GameServer#gameServerRecord.socket, Msg)
	end.

sendToGameServerByServerID( ServerID, Msg )->
	GameServer = getGameServerRecord( ServerID ),
	case GameServer#gameServerRecord.socket =:= 0 of
		true->
			?LOG_OUT( "sendToGameServer server[~p] Msg[~p] socket=0", [GameServer#gameServerRecord.serverID, Msg] );
		false->
			%?LOG_OUT( "----sendToGameServer server[~p] Msg[~p] ", [ServerID,Msg] ),
			msg_LS2GS:send(GameServer#gameServerRecord.socket, Msg)
	end.

sendToAllGameServer( Msg )->
	AllRunningGameServerList = getAllRunningGameServerList(),
	lists:map( fun(Record)-> msg_LS2GS:send(Record#gameServerRecord.socket, Msg) end, AllRunningGameServerList ).
	
getGameServerUserState( GameServer )->
	put( "getGameServerUserState", ?GameServer_User_State_Normal ),
	try
		case GameServer#gameServerRecord.state =:= ?GameServer_State_Running of
			false->
				put( "getGameServerUserState", ?GameServer_User_State_Maintain ),
				throw(-1);
			true->ok
		end,

		case GameServer#gameServerRecord.showState >= 0 of
			true->
				put( "getGameServerUserState", GameServer#gameServerRecord.showState ),
				throw(-1);
			false->
				ok
		end,
		
		case ( GameServer#gameServerRecord.onlinePlayers >= ?GameServer_Online_State_Normal_Min ) and
			 ( GameServer#gameServerRecord.onlinePlayers =< ?GameServer_Online_State_Normal_Max ) of
			true->
				put( "getGameServerUserState", ?GameServer_User_State_Normal ),
				throw(-1);
			false->ok	
		end,

		case ( GameServer#gameServerRecord.onlinePlayers >= ?GameServer_Online_State_Hot_Min ) and
			 ( GameServer#gameServerRecord.onlinePlayers =< ?GameServer_Online_State_Hot_Max ) of
			true->
				put( "getGameServerUserState", ?GameServer_User_State_Hot ),
				throw(-1);
			false->ok	
		end,

		case ( GameServer#gameServerRecord.onlinePlayers >= ?GameServer_Online_State_Full_Min ) and
			 ( GameServer#gameServerRecord.onlinePlayers =< ?GameServer_Online_State_Full_Max ) of
			true->
				put( "getGameServerUserState", ?GameServer_User_State_Full ),
				throw(-1);
			false->ok	
		end,
		
		?GameServer_User_State_Normal
	catch
		_->get( "getGameServerUserState" )
	end.

addGsConfig( Serverid, Name, Isnew, Begintime,Recommend,Hot)->
	?DEBUG_OUT( "gameserver add config [~p] [~p] [~p] [~p][~p] [~p]", [Serverid, Name, Isnew, Begintime, Recommend, Hot] ),
	try
		ExistGameServer = gameServer:getGameServerRecord( Serverid ),			
		case ExistGameServer of			
			{}->
				GameServer1 = #gameServerRecord{serverID=Serverid, 
												state=?GameServer_State_GSIni, 
												showInUserGameList=99,
												name=Name, 
												ip="", port=0, socket=0, remmond=Recommend, onlinePlayers=0, showState=-1,
												isnew=Isnew,
												begintime=Begintime,hot=Hot},					
				db:writeRecord( GameServer1 ),
				%% 保存数据	
				GSConfig1 = #gsConfig{serverID = Serverid, name = Name, isnew = Isnew, begintime = Begintime, recommend = Recommend, hot = Hot },
				loginMysqlProc:insert_gsConfig(GSConfig1),
				ok;
			_->
				%% 如果存在就修改状态  根据ServerID 
				db:changeFiled( gameServerRecord, Serverid, #gameServerRecord.name, Name ),
				db:changeFiled( gameServerRecord, Serverid, #gameServerRecord.isnew, Isnew ),
				db:changeFiled( gameServerRecord, Serverid, #gameServerRecord.begintime, Begintime ),
				db:changeFiled( gameServerRecord, Serverid, #gameServerRecord.remmond, Recommend ),
				db:changeFiled( gameServerRecord, Serverid, #gameServerRecord.hot, Hot ),
				
				%% 如果只是数据库中的配置 可以修改数据库  已经正常运行的不保存到数据库中 重启的时候还是会重置  mofidy by nada 20130427
				%%case ExistGameServer#gameServerRecord.state =:= ?GameServer_State_GSIni of
				%%		true->
				%%			GSConfigUpdate = #gsConfigUpdate{name = Name, isnew = Isnew, begintime = Begintime, recommend = Recommend, hot = Hot, serverID = Serverid },
				%%			loginMysqlProc:update_gsConfig(GSConfigUpdate),
				%%			ok;
				%%		false->throw(-1)
				%%end,
				
				GSConfigUpdate = #gsConfigUpdate{name = Name, isnew = Isnew, begintime = Begintime, recommend = Recommend, hot = Hot, serverID = Serverid },
				loginMysqlProc:update_gsConfig(GSConfigUpdate),
							
				ok
			
		end,
		
		
		PlatformSocket = get( "PlatformSocket" ),
		
		Pkt = #pk_LS2Platform553_Add_GsConfig_Ret{ len=string:len(Serverid)+12+2,commmand=?CMD_PLATFORM_553_ADD_GSCONFIG_RET,
					serverid=Serverid,
					ret=0},
		?DEBUG_OUT( "------addGsConfig Complete relust 0------[~p]",[Pkt]),
		msg_LS2Platform:sendMsg(PlatformSocket,Pkt)
	catch
		-1->
			PlatformSocket2 = get( "PlatformSocket" ),		
			Pkt2 = #pk_LS2Platform553_Add_GsConfig_Ret{ len=string:len(Serverid)+12+2,commmand=?CMD_PLATFORM_553_ADD_GSCONFIG_RET,
						serverid=Serverid,
						ret=-1},
			?DEBUG_OUT( "------addGsConfig Complete relust -1------[~p]",[Pkt2]),
			msg_LS2Platform:sendMsg(PlatformSocket2,Pkt2),		
			false
	end.

subGsConfig( Serverid )->
	?DEBUG_OUT( "gameserver sub config [~p] ", [Serverid] ),
	try	
		ExistGameServer = gameServer:getGameServerRecord( Serverid ),			
		case ExistGameServer of
			{}->throw(-1);
			_->ok
		end,
		case ExistGameServer#gameServerRecord.state =:= ?GameServer_State_Running of			
			true->throw(-2);
			false->ok
		end,
		
		%% del tes biao
		db:delete(gameServerRecord, Serverid),			
		%% del mysql table
		loginMysqlProc:delete_gsConfig(Serverid),

		PlatformSocket = get( "PlatformSocket" ),		
		Pkt = #pk_LS2Platform553_Sub_GsConfig_Ret{ len=16,commmand=?CMD_PLATFORM_553_SUB_GSCONFIG_RET,
					serverid=Serverid,
					ret=0},
		?DEBUG_OUT( "------subGsConfig Complete relust 0------[~p]",[Pkt]),
		msg_LS2Platform:sendMsg(PlatformSocket,Pkt)

	catch
		-1->
			PlatformSocket2 = get( "PlatformSocket" ),		
			Pkt2 = #pk_LS2Platform553_Sub_GsConfig_Ret{ len=16,commmand=?CMD_PLATFORM_553_SUB_GSCONFIG_RET,
						serverid=Serverid,
						ret=-1},
			?DEBUG_OUT( "------subGsConfig Complete relust -1------[~p]",[Pkt2]),
			msg_LS2Platform:sendMsg(PlatformSocket2,Pkt2),
			false;
		-2->
			PlatformSocket3 = get( "PlatformSocket" ),		
			Pkt3 = #pk_LS2Platform553_Sub_GsConfig_Ret{ len=16,commmand=?CMD_PLATFORM_553_SUB_GSCONFIG_RET,
						serverid=Serverid,
						ret=-2},
			?DEBUG_OUT( "------subGsConfig Complete relust -2------[~p]",[Pkt3]),
			msg_LS2Platform:sendMsg(PlatformSocket3,Pkt3),
			false
	end.

