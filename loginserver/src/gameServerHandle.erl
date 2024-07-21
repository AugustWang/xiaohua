%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(gameServerHandle).

%%
%% Include files
%%
-include("db.hrl").
-include("userDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("gameServerDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

onMsgGS2LS_Request_Login(#pk_GS2LS_Request_Login{}=Msg)->
	try
		ServerID = Msg#pk_GS2LS_Request_Login.serverID,
		ExistGameServer = gameServer:getGameServerRecord( ServerID ),
		put( "onMsgGS2LS_Request_Login_GameServer", ExistGameServer ),
		case ExistGameServer of
			{}->
				%%不存在，测试版，先注册
				GameServer = #gameServerRecord{ serverID=ServerID, 
												state=?GameServer_State_CheckPass, 
												showInUserGameList=Msg#pk_GS2LS_Request_Login.showInUserGameList, 
												name=Msg#pk_GS2LS_Request_Login.name, 
												ip=Msg#pk_GS2LS_Request_Login.ip, 
												port=Msg#pk_GS2LS_Request_Login.port, 
												socket=gameServer:getCurGameServerSocket(), 
												remmond=Msg#pk_GS2LS_Request_Login.remmond, 
												onlinePlayers=0,
												showState=-1,
												isnew=0,begintime="2013",hot = Msg#pk_GS2LS_Request_Login.hot },
				put( "onMsgGS2LS_Request_Login_GameServer", GameServer );
			_->
				case ExistGameServer#gameServerRecord.socket =:= 0 of
					true->ok;
					false->
						?ERROR_OUT( "onMsgGS2LS_Request_Login exist server[~p]", [ServerID] ),
						throw(-1)
				end,
				GameServer = setelement( #gameServerRecord.socket, ExistGameServer, gameServer:getCurGameServerSocket() ),
				%%GameServer2 = setelement( #gameServerRecord.name, GameServer, Msg#pk_GS2LS_Request_Login.name ),
				GameServer3 = setelement( #gameServerRecord.ip, GameServer, Msg#pk_GS2LS_Request_Login.ip ),
				GameServer4 = setelement( #gameServerRecord.port, GameServer3, Msg#pk_GS2LS_Request_Login.port ),
				%%GameServer5 = setelement( #gameServerRecord.remmond, GameServer4, Msg#pk_GS2LS_Request_Login.remmond ),
				%%GameServer6 = setelement( #gameServerRecord.hot, GameServer5, Msg#pk_GS2LS_Request_Login.hot ),
				%%put( "onMsgGS2LS_Request_Login_GameServer", GameServer6 ),
				put( "onMsgGS2LS_Request_Login_GameServer", GameServer4 ),
				gameServer:setCurGameServerState( ?GameServer_State_CheckPass ),
				ok
		end,
		
		put( "IsSocketCheckPass", true ),
		put( "ServerID", ServerID ),
		
		db:writeRecord( get("onMsgGS2LS_Request_Login_GameServer") ),
		?LOG_OUT( "regist gameserver[~p]", [get("onMsgGS2LS_Request_Login_GameServer")] ),
		db:changeFiled( gameServerRecord, gameServer:getCurGameServerID(), #gameServerRecord.onlinePlayers, 0 ),
		
		gameServer:sendToCurGameServer( #pk_LS2GS_LoginResult{reserve=0} ),
		
		?LOG_OUT( "onMsgGS2LS_Request_Login ~p check pass", [gameServer:getCurGameServerLog()] ),
		
		ok
	catch
		_->ok
	end.

onMsgGS2LS_ReadyToAcceptUser( #pk_GS2LS_ReadyToAcceptUser{}=Msg )->
	gameServer:setCurGameServerState( ?GameServer_State_Running ),
	?DEBUG_OUT( "onMsgGS2LS_ReadyToAcceptUser ~p GameServer_State_Running", [gameServer:getCurGameServerLog()] ),
	ok.

onMsgGS2LS_OnlinePlayers( #pk_GS2LS_OnlinePlayers{}=Msg )->
	db:changeFiled( gameServerRecord, gameServer:getCurGameServerID(), #gameServerRecord.onlinePlayers, Msg#pk_GS2LS_OnlinePlayers.playerCount ),
	ok.

on_GS2LS_QueryUserMaxLevelResult( #pk_GS2LS_QueryUserMaxLevelResult{}=Msg )->
	User = main:getGlobalLoginUser( Msg#pk_GS2LS_QueryUserMaxLevelResult.userID ),
	case User of
		{}->?DEBUG_OUT("on_GS2LS_QueryUserMaxLevelResult userID[~p] empty ", [Msg#pk_GS2LS_QueryUserMaxLevelResult.userID]);
		_->
			?DEBUG_OUT("on_GS2LS_QueryUserMaxLevelResult userid[~p] to userProcPID[~p]", [Msg#pk_GS2LS_QueryUserMaxLevelResult.userID, User#globalLoginUser.userProcPID] ),
			User#globalLoginUser.userProcPID ! { gameServer_QueryUserMaxLevelResult,
									gameServer:getCurGameServerID(), 
									Msg#pk_GS2LS_QueryUserMaxLevelResult.maxLevel }
	end,

	ok.

on_GS2LS_UserReadyLoginResult( #pk_GS2LS_UserReadyLoginResult{}=Msg )->
	try
		?DEBUG_OUT( "on_GS2LS_UserReadyLoginResult Msg[~p]", [Msg] ),
		UserID = Msg#pk_GS2LS_UserReadyLoginResult.userID,
		UserPID = etsBaseFunc:getRecordField(main:getGlobalLoginUserTable(), UserID, #globalLoginUser.userProcPID ),
		case UserPID of
			0->?DEBUG_OUT("on_GS2LS_UserReadyLoginResult false UserPID Msg[~p]", [Msg]);
			_->
				etsBaseFunc:insertRecord( gameServer:getGameServerUsersTable(), #gameServerUsers{userID=UserID,reserve=0} ),
				main_PID ! { loginGameServer, UserID, gameServer:getCurGameServerID() },
				UserPID ! { onGS2LS_UserReadyLoginResult, gameServer:getCurGameServerID(), Msg }
		end,

		ok
	catch
		_->ok
	end,
	ok.

on_GS2LS_UserLoginGameServer( #pk_GS2LS_UserLoginGameServer{userID=UserID} = Msg )->
	?DEBUG_OUT( "on_GS2LS_UserLoginGameServer Msg[~p]", [Msg] ),
	ok.

on_GS2LS_UserLogoutGameServer( #pk_GS2LS_UserLogoutGameServer{userID=UserID} = Msg )->
	?DEBUG_OUT( "on_GS2LS_UserLogoutGameServer Msg[~p]", [Msg] ),
	etsBaseFunc:deleteRecord( gameServer:getGameServerUsersTable(), UserID ),
	main_PID ! { gS2LS_UserLogoutGameServer, Msg, gameServer:getCurGameServerID() },
	ok.

on_GS2LS_ActiveCode(#pk_GS2LS_ActiveCode{pidStr=PidStr, activeCode=ActiveCode, retcode=ReturnCode } = Msg) ->
	?LOG_OUT( "----on_GS2LS_ActiveCode Msg:~p,will send to background553SocketPID", [Msg] ),
	Pid = list_to_pid(PidStr),
	case is_pid(Pid) of
		true->Pid ! {activeCodeProcComplete,Msg};
		false->
			?ERROR_OUT( "----on_GS2LS_ActiveCode Msg:~p,pid error,not send to background553 module", [Msg] )
	end,
	ok.

on_GS2LS_Command(#pk_GS2LS_Command{pidStr=PidStr} = Msg) ->
	?LOG_OUT( "----on_GS2LS_Command Msg:~p,will send to background553SocketPID ", [Msg] ),
	Pid = list_to_pid(PidStr),
	case is_pid(Pid) of
		true->Pid ! {commandComplete,Msg};
		false->
			?ERROR_OUT( "----on_GS2LS_Command Msg:~p,pid error,not send to background553 module", [Msg] )
	end,
	ok.

on_GS2LS_Recharge(#pk_GS2LS_Recharge{pidStr=PidStr} = Msg) ->
	?LOG_OUT( "----on_GS2LS_Recharge Msg:~p,will send to background553SocketPID ", [Msg] ),
	Pid = list_to_pid(PidStr),
	case is_pid(Pid) of
		true->Pid ! {rechargeComplete,Msg};
		false->
			?ERROR_OUT( "----on_GS2LS_Recharge Msg:~p,pid error,not send to background553 module", [Msg] )
	end,
	ok.

