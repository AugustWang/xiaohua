%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(main).

%% add to support gen_server
-behaviour(gen_server).
-export([start_link/0,start/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%
%% Include files
%%
-include("pc_LS2GS.hrl").
-include("hdlt_logger.hrl").
-include("db.hrl").
-include("condition_compile.hrl").
-include("gameServerDefine.hrl").
-include("logindb.hrl").


-define(RecoverMnesiaGarbTimer,1200000). % 20 minutes


%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% API Functions
%%
start() ->
	loginServerSup:start_link(),
	timer:sleep(infinity).

start_link() ->
	gen_server:start_link({local,main_PID},?MODULE, [], [{timeout,?Start_Link_TimeOut_ms}]).


init([]) ->
	db:init(),
	createGlobalTables(),
	iniGameServerTable(),
	
	%% 创建支持平台的ets表
	ets:new( 'globalUserSocket', [protected, { keypos, #globalUserSocket.socket }] ),
	%% 保存LoginServerID
	LoginServerTable=ets:new( 'loginServerInfo', [named_table,protected, { keypos, #loginServerInfo.index}] ),
	LoginServerID = ini_ReadInt("LoginServer.txt","LoginServerId",1 ),
	ets:insert(LoginServerTable,#loginServerInfo{index=1,loginServerID=LoginServerID}),
	
	%%启动支持的平台模块
	platform:init(),
	timer:send_after(?RecoverMnesiaGarbTimer, {mainTimer_recoverMnesiaGarb} ),

	{ok, {}}.

handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

getLoginServerID()->
	Ret=ets:lookup('loginServerInfo',1),
	case Ret of
		[]->0;
		[Record|_]->Record#loginServerInfo.loginServerID
	end.

createGlobalTables() ->
	%%建立全局用户Socket表
	TableGlobalUserSocket = ets:new( 'globalUserSocket', [protected, { keypos, #globalUserSocket.socket }] ),
	put( "GlobalUseSocketTable", TableGlobalUserSocket ),
	db:changeFiled(globalMain, ?GlobalMainID, #globalMain.globalUserSocket, TableGlobalUserSocket),

	%%建立全局已登录用户表
	TableGlobalLoginUser = ets:new( 'globalLoginUser', [protected, { keypos, #globalLoginUser.userID }] ),
	put( "TableGlobalLoginUser", TableGlobalLoginUser ),
	db:changeFiled(globalMain, ?GlobalMainID, #globalMain.globalLoginUserTable, TableGlobalLoginUser).


iniGameServerTable()->
	?DEBUG_OUT("load gs config start..."),	
	ServerConfigList = loginMysqlProc:get_allGsConfig(),
	case ServerConfigList of
		[]->					
			ok;
		_->		
			FunSerCfg = fun( Record )->
							GameServer1 = #gameServerRecord{serverID=Record#gsConfig.serverID, 
									state=?GameServer_State_GSIni, 
									showInUserGameList=99,
									name=Record#gsConfig.name, 
									ip="", port=0, socket=0, remmond=Record#gsConfig.recommend, onlinePlayers=0, showState=-1,
									isnew=Record#gsConfig.isnew,
									begintime=Record#gsConfig.begintime,									
									hot = Record#gsConfig.hot},					
							db:writeRecord( GameServer1 )
		  	end,
			lists:foreach(FunSerCfg, ServerConfigList)
	end,	
	?DEBUG_OUT("load gs config end..."),	
	ok.

%% startTry()->
%% 
%% 
%% 	loginServerSup:start_link(),
%% 	db:init(),
%% 	createGlobalTables(),
%% 	
%% 	%%启动支持的平台模块
%% 	%% 创建支持平台的ets表
%% 	ets:new( 'globalUserSocket', [protected, { keypos, #globalUserSocket.socket }] ),
%% 	platform:init(),
%% 	mainRecieve().

%% startTry_Exception()->
%% 	?ERROR_OUT( "startTry_Exception" ).

linkProcess( Pid, Fun )->
	spawn( fun()->
				   process_flag( trap_exit, true ),
				   try
					   link( Pid ),
					   receive 
						   { 'EXIT', Pid, Why }->
							   Fun( Why )
					   end
				   catch
					   _->ok
				   end
			end
		  ).
  
getGlobalUseSocketTable()->
	UseSocketTable = get( "GlobalUseSocketTable" ),
	case UseSocketTable of
		undefined->db:getFiled( globalMain, ?GlobalMainID, #globalMain.globalUserSocket );
		_->UseSocketTable
	end.

getGlobalLoginUserTable()->
	GlobalLoginUser = get( "TableGlobalLoginUser" ),
	case GlobalLoginUser of
		undefined->db:getFiled( globalMain, ?GlobalMainID, #globalMain.globalLoginUserTable );
		_->GlobalLoginUser
	end.

getGlobalLoginUser( UserID )->
	GlobalLoginUserTable = getGlobalLoginUserTable(),
	case GlobalLoginUserTable of
		0->{};
		_->
			etsBaseFunc:readRecord( GlobalLoginUserTable, UserID )
	end.


handle_info(Info, StateData)->	
	put( "mainRecieve", true ),

	try
	case Info of
		{quit}->
			?LOG_OUT( "mainRecieve quit" ),
			put( "mainRecieve", false );
		{ acceptedUserSocket, Socket }->
			etsBaseFunc:insertRecord( getGlobalUseSocketTable(), #globalUserSocket{socket=Socket, userID=0} ),
			ok;
		{ closedUserSocket, Socket }->
			onUserSocketClose( Socket ),
			ok;
		{ loginUser, UserID, Socket, UserPID, RandIdentity }->
			etsBaseFunc:changeFiled( getGlobalUseSocketTable(), Socket, #globalUserSocket.userID, UserID ),
			GlobalLoginUser = #globalLoginUser{userID=UserID, loginGameServer=0, socket=Socket, userProcPID=UserPID, 
											   randIdentity=RandIdentity,
											   waitForKickoutUserPID=0,
											   waitForLoginGSID=0},
			etsBaseFunc:insertRecord( getGlobalLoginUserTable(), GlobalLoginUser ),
			?DEBUG_OUT( "insert user userid[~p] into globalLoginUser", [UserID] ),
			ok;
		{ loginGameServer, UserID, GameServerID }->
			etsBaseFunc:changeFiled( getGlobalLoginUserTable(), UserID, #globalLoginUser.loginGameServer, GameServerID ),
			ok;
		{ kickOutUser, FromUser, UserID }->
			onKickOutUser( FromUser, UserID ),
			ok;
		{ gS2LS_UserLogoutGameServer, Msg, ServerID }->
			ongS2LS_UserLogoutGameServer( Msg, ServerID );
		{ userReadyLoginWS, UserID, ServerID }->
			on_userReadyLoginWS( UserID, ServerID );
		{mainTimer_recoverMnesiaGarb} ->
			try
				mnesia_recover:allow_garb(),
				mnesia_recover:start_garb()	
			catch
				_:Why1->
					common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[mnesia_recover:start_garb] Why[~p] stack[~p]", 
						[?MODULE,Why1, erlang:get_stacktrace()] )
			end,
			timer:send_after(?RecoverMnesiaGarbTimer, {mainTimer_recoverMnesiaGarb} );
		_->
			?LOG_OUT( "mainRecieve error" )
	end,
	case get("mainRecieve") of
		true->{noreply, StateData};
		false->{stop, normal, StateData}
	end
	
	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[?MODULE,_Why, erlang:get_stacktrace()] ),
			{noreply, StateData}
	end.

onUserSocketClose( Socket )->
	try
		Record = etsBaseFunc:readRecord( getGlobalUseSocketTable(), Socket ),
		case Record of
			{}->throw(-1);
			_->ok
		end,

		etsBaseFunc:deleteRecord( getGlobalUseSocketTable(), Socket ),
		
		UserID = Record#globalUserSocket.userID,
		LoginUser = etsBaseFunc:readRecord( getGlobalLoginUserTable(), UserID ),
		case LoginUser of
			{}->throw(-1);
			_->
				case ( LoginUser#globalLoginUser.loginGameServer > 0 ) and ( gameServer:isGameServerStateRunning( LoginUser#globalLoginUser.loginGameServer ) ) of
					true->
						%%如果玩家已登录游戏服务器，等待该游戏服务器通知下线
						ok;
					false->
						%%直接下线
						case LoginUser#globalLoginUser.waitForLoginGSID > 0 of
							true->
								%%已经让GS准备登录，等待GS处理
								ok;
							false->
								%%直接清除登录记录
								?DEBUG_OUT( "onUserSocketClose delete GlobalLoginUserTable UserID[~p]", [UserID] ),
								etsBaseFunc:deleteRecord( getGlobalLoginUserTable(), UserID )
						end,
						ok
				end,

				ok
		end,

		ok
	catch
		_->ok
	end.

onKickOutUser( FromUser, UserID )->
	try
		LoginUser = etsBaseFunc:readRecord( getGlobalLoginUserTable(), UserID ),
		case LoginUser of
			{}->
				%%已经不存在，直接返回
				FromUser ! { kickOutUserComplete },
				ok;
			_->
				case LoginUser#globalLoginUser.loginGameServer =:= 0 of
					true->
						%%没有登录任何GameServer，踢掉该user
						case LoginUser#globalLoginUser.socket =:= 0 of
							true->ok;
							false->
								%%发个消息，
								%%关socket
								?DEBUG_OUT( "onKickOutUser shutdown UserID[~p]", [UserID] ),
								gen_tcp:close( LoginUser#globalLoginUser.socket )
						end,
						%%删除
						?DEBUG_OUT( "onKickOutUser delete GlobalLoginUserTable UserID[~p]", [UserID] ),
						etsBaseFunc:deleteRecord( getGlobalLoginUserTable(), UserID ),
						%%回复
						FromUser ! { kickOutUserComplete },
						ok;
					false->
						%%已经登录某游戏服务器，通知该游戏服务器踢掉
						LS2GS_KickOutUser = #pk_LS2GS_KickOutUser{userID=UserID, identity=LoginUser#globalLoginUser.randIdentity},
						gameServer:sendToGameServerByServerID( LoginUser#globalLoginUser.loginGameServer, LS2GS_KickOutUser ),
						
						%%记录正在等待踢人结果的用户PID，以便踢人结束后，通知该用户结果
						etsBaseFunc:changeFiled( getGlobalLoginUserTable(), UserID, #globalLoginUser.waitForKickoutUserPID, FromUser ),
						
						?DEBUG_OUT( "onKickOutUser send to gs[~p] kickout UserID[~p]", [LoginUser#globalLoginUser.loginGameServer, UserID] ),
						ok
				end,
				ok
		end,

		ok
	catch
		_->ok
	end.

ongS2LS_UserLogoutGameServer( #pk_GS2LS_UserLogoutGameServer{userID=UserID,identity=Identity}=_Msg, ServerID )->
	try
		LoginUser = etsBaseFunc:readRecord( getGlobalLoginUserTable(), UserID ),
		case LoginUser of
			{}->
				%%已经不存在
				ok;
			_->
				case LoginUser#globalLoginUser.randIdentity =:= Identity of
					false->
						%%不一样的identity，忽略
						?DEBUG_OUT( "ongS2LS_UserLogoutGameServer ServerID[~p] UserID[~p] randIdentity =:= Identity false ", [ServerID, UserID] ),
						ok;
					true->
						WaitUserPID = LoginUser#globalLoginUser.waitForKickoutUserPID,
						?DEBUG_OUT( "ongS2LS_UserLogoutGameServer ServerID[~p] UserID[~p] delete login ", [ServerID, UserID] ),
						%%删除
						etsBaseFunc:deleteRecord( getGlobalLoginUserTable(), UserID ),
						
						case WaitUserPID =:= 0 of
							true->ok;
							false->
								%%回复
								WaitUserPID ! { kickOutUserComplete }
						end,
						case LoginUser#globalLoginUser.socket =:= 0 of
							true->ok;
							false->
								%%发个消息，
								%%关socket
								?DEBUG_OUT( "ongS2LS_UserLogoutGameServer ServerID[~p] UserID[~p] close ", [ServerID, UserID] ),
								gen_tcp:close( LoginUser#globalLoginUser.socket )
						end,
						
						ok
				end,
				ok
		end,
		ok
	catch
		_->ok
	end.


on_userReadyLoginWS( UserID, ServerID )->
	try
		LoginUser = etsBaseFunc:readRecord( getGlobalLoginUserTable(), UserID ),
		case LoginUser of
			{}->ok;
			_->etsBaseFunc:changeFiled( getGlobalLoginUserTable(), UserID, #globalLoginUser.waitForLoginGSID, ServerID)
		end,
		ok
	catch
		_->ok
	end,
	ok.


ini_ReadKey( IniFile, File, Key )->
	case io:get_line(File, '') of
		eof->
			throw(-1);
		{error, Reason }->
			?LOG_OUT( "ini_ReadKey IniFile[~p] Key[~p] getline false[~p]", [IniFile, Key, Reason] ),
			throw(-1);
		LineString->
			Tokens = string:tokens(LineString, "=\n"),
			case length( Tokens ) >= 2 of
				true->
					[ReadKey|Tokens2] = Tokens,
					case length( Tokens2 ) > 1 of
						true->[ReadValue|_] = Tokens2;
						false->ReadValue=Tokens2
					end,
					case ReadKey =:= Key of
						true->ReadValue;
						false->ini_ReadKey(IniFile, File, Key)
					end;
				false->ini_ReadKey(IniFile, File, Key)
			end
	end.

ini_ReadString( IniFile, Key, Default )->
	try
		put( "ini_ReadString_File", 0 ),
		case file:open(IniFile, read ) of
			{ok, File }->
				put( "ini_ReadString_File", File ),
				ReadValue = ini_ReadKey( IniFile, File, Key ),
				file:close(File),
				[Return|_] = ReadValue,
				Return;
			{error, Reason}->
				?LOG_OUT( "ini_ReadString IniFile[~p] Key[~p] file open false[~p]", [IniFile, Key, Reason] ),
				throw(-1);
			_->
				throw(-1)
		end
	catch
		_->
			File2 = get( "ini_ReadString_File" ),
			case File2 of
				0->ok;
				_->file:close(File2)
			end,
			Default
	end.

ini_ReadInt( IniFile, Key, Default )->
	ReadString = ini_ReadString( IniFile, Key, Default ),
	case ReadString =:= Default of
		true->Default;
		false->
			{Return,_}=string:to_integer( ReadString ),
			Return
	end.
