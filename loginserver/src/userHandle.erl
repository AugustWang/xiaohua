%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(userHandle).

%%
%% Include files
%%
-include("db.hrl").
-include("userDefine.hrl").
-include("platformDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("gameServerDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

onUserOffline()->
	ok.

%%-------------------------------------------------------------------------------------
%%-------------------------------------------------------------------------------------
%%-------------------------------------------------------------------------------------
on_Login_553( #pk_U2LS_Login_553{}=Msg )->
	Account = Msg#pk_U2LS_Login_553.account,
        PlatformID = Msg#pk_U2LS_Login_553.platformID,
        Time = Msg#pk_U2LS_Login_553.time,
        Sign = Msg#pk_U2LS_Login_553.sign,
        VersionRes = Msg#pk_U2LS_Login_553.versionRes,
        VersionExe = Msg#pk_U2LS_Login_553.versionExe,
        VersionGame = Msg#pk_U2LS_Login_553.versionGame,
        VersionPro = Msg#pk_U2LS_Login_553.versionPro,
	try
		case netUsers:getCurUserState() =:= ?UserState_UnCheckPass of
			false->throw(-1);
			true->ok
		end,

		netUsers:setCurUserState( ?UserState_WaitCheckPass ),

?DEBUG_OUT("PlatformID:[~p],isTestSupport:[~p],is553Support:[~p]",[PlatformID,platform553:isTestSupport(),platform553:is553Support()]),
			
		case ((PlatformID =:= ?PLATFORM_TEST) and (platform553:isTestSupport() =:= yes)) or 
			((PlatformID =:= ?PLATFORM_553) and (platform553:is553Support() =:= yes)) or 
			((PlatformID =:= ?PLATFORM_553_android) and (platform553:is553AndroidSupport() =:= yes))of
			true->ok;
			false->throw(-2)
		end,


		case ((PlatformID =:= ?PLATFORM_553) and (success =:= verify:verify553(Account,Time,Sign))) or
			((PlatformID =:= ?PLATFORM_TEST) and (success =:= verify:verifyTest(Account,netUsers:getCurUserIP())))  or
			((PlatformID =:= ?PLATFORM_553_android) and (success =:= verify:verify553_android(Account,Time,Sign))) of
			true->
				Params=#userDBLogin{account=Account,platformID=PlatformID,versionRes=VersionRes,versionExe=VersionExe,versionGame=VersionGame,versionPro=VersionPro},
				Result = userDB:onUserLogin(netUsers:getCurUserSocket(),Params),	
				on_dbLoginResult(Result);
			false->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_UserNameOrPassword,account=Account,userID=0,platId=PlatformID})
		end
	catch
		-2->
			on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Unsupport,account=Account,userID=0,platId=PlatformID});

		_->
			on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Exception,account=Account,userID=0,platId=PlatformID})
	end.

%%-------------------------------------------------------------------------------------
on_Login_APPS( #pk_U2LS_Login_APPS{}=Msg )->
	Account = Msg#pk_U2LS_Login_APPS.account,
        PlatformID = Msg#pk_U2LS_Login_APPS.platformID,
        Time = Msg#pk_U2LS_Login_APPS.time,
        Sign = Msg#pk_U2LS_Login_APPS.sign,
        VersionRes = Msg#pk_U2LS_Login_APPS.versionRes,
        VersionExe = Msg#pk_U2LS_Login_APPS.versionExe,
        VersionGame = Msg#pk_U2LS_Login_APPS.versionGame,
        VersionPro = Msg#pk_U2LS_Login_APPS.versionPro,
	try
		case netUsers:getCurUserState() =:= ?UserState_UnCheckPass of
			false->throw(-1);
			true->ok
		end,

		netUsers:setCurUserState( ?UserState_WaitCheckPass ),

		case ((PlatformID =:= ?PLATFORM_APPS) and (platformAPPS:isAPPSSupport() =:= yes)) of
			true->ok;
			false->throw(-2)
		end,

		case success =:= verify:verifyAPPS(Account,Time,Sign) of
			true->
				Params=#userDBLogin{account=Account,platformID=PlatformID,versionRes=VersionRes,versionExe=VersionExe,versionGame=VersionGame,versionPro=VersionPro},
				Result = userDB:onUserLogin(netUsers:getCurUserSocket(),Params),	
				on_dbLoginResult(Result);
			false->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_UserNameOrPassword,account=Account,userID=0,platId=PlatformID})
		end
	catch
		-2->
			on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Unsupport,account=Account,userID=0,platId=PlatformID});

		_->
			on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Exception,account=Account,userID=0,platId=PlatformID})
	end.

%%-------------------------------------------------------------------------------------
on_Login_PP( #pk_U2LS_Login_PP{}=Msg )->
	Account = Msg#pk_U2LS_Login_PP.account,
    PlatformID = Msg#pk_U2LS_Login_PP.platformID,
    Token1 = Msg#pk_U2LS_Login_PP.token1,
    Token2 = Msg#pk_U2LS_Login_PP.token2,
    VersionRes = Msg#pk_U2LS_Login_PP.versionRes,
    VersionExe = Msg#pk_U2LS_Login_PP.versionExe,
    VersionGame = Msg#pk_U2LS_Login_PP.versionGame,
    VersionPro = Msg#pk_U2LS_Login_PP.versionPro,
	try
		case netUsers:getCurUserState() =:= ?UserState_UnCheckPass of
			false->throw(-1);
			true->ok
		end,

		netUsers:setCurUserState( ?UserState_WaitCheckPass ),

		case ((PlatformID =:= ?PLATFORM_PP) and (platformPP:isPPSupport() =:= yes)) of
			true->ok;
			false->throw(-2)
		end,

		case verify:verifyPP(Account,Token1,Token2) of 
			success->
				Params=#userDBLogin{account=Account,platformID=PlatformID,versionRes=VersionRes,versionExe=VersionExe,versionGame=VersionGame,versionPro=VersionPro},
				Result = userDB:onUserLogin(netUsers:getCurUserSocket(),Params),	
				on_dbLoginResult(Result);
			error->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Disconnect,account=Account,userID=0,platId=PlatformID});
			failed->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_UserNameOrPassword,account=Account,userID=0,platId=PlatformID});
			timeout->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Timeout,account=Account,userID=0,platId=PlatformID});
			closed->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Disconnect,account=Account,userID=0,platId=PlatformID});
			_->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Unknown,account=Account,userID=0,platId=PlatformID})
		end
	catch
		-2->
			on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Unsupport,account=Account,userID=0,platId=PlatformID});
		_->
			on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Exception,account=Account,userID=0,platId=PlatformID})
	end.
%%-------------------------------------------------------------------------------------
on_Login_91( #pk_U2LS_Login_91{}=Msg )->
	Account = Msg#pk_U2LS_Login_91.account,
    PlatformID = Msg#pk_U2LS_Login_91.platformID,
	Uin = Msg#pk_U2LS_Login_91.uin,
    SessionID = Msg#pk_U2LS_Login_91.sessionID,
    VersionRes = Msg#pk_U2LS_Login_91.versionRes,
    VersionExe = Msg#pk_U2LS_Login_91.versionExe,
    VersionGame = Msg#pk_U2LS_Login_91.versionGame,
    VersionPro = Msg#pk_U2LS_Login_91.versionPro,
	try
		case netUsers:getCurUserState() =:= ?UserState_UnCheckPass of
			false->throw(-1);
			true->ok
		end,

		netUsers:setCurUserState( ?UserState_WaitCheckPass ),

		case ((PlatformID =:= ?PLATFORM_91_IOS) and (platform91:isSupport() =:= yes)) or 
			((PlatformID =:= ?PLATFORM_91_android) and (platform91:isSupportAndroid() =:= yes))of
			true->ok;
			false->throw(-2)
		end,

		case verify:verify91(PlatformID,Uin,SessionID) of 
			%{success,UserID,Account0,AccessToken,RefreshToken}->
			%	?DEBUG_OUT("verify360 ok.Account:~p,AccessToken:~p,RefreshToken:~p",[Account0,AccessToken,RefreshToken]),
				%% 通知客户端，用户名,access_token,refreshToken
			%	netUsers:send( #pk_LS2U_Login_91{account=Account0,userid=UserID,access_token=AccessToken,refresh_token=RefreshToken} ),
			success->
				?DEBUG_OUT("verify91 ok.Account:~p,SessionID:~p",[Account,SessionID]),
				Params=#userDBLogin{account=Account,platformID=PlatformID,versionRes=VersionRes,versionExe=VersionExe,versionGame=VersionGame,versionPro=VersionPro},
				Result = userDB:onUserLogin(netUsers:getCurUserSocket(),Params),	
				on_dbLoginResult(Result);
			error->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Disconnect,account=Account,userID=0,platId=PlatformID});
			failed->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_UserNameOrPassword,account=Account,userID=0,platId=PlatformID});
			timeout->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Timeout,account=Account,userID=0,platId=PlatformID});
			closed->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Disconnect,account=Account,userID=0,platId=PlatformID});
			_->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Unknown,account=Account,userID=0,platId=PlatformID})
		end
	catch
		-2->
			on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Unsupport,account=Account,userID=0,platId=PlatformID});
		_->
			on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Exception,account=Account,userID=0,platId=PlatformID})
	end.

%%-------------------------------------------------------------------------------------
on_Login_360( #pk_U2LS_Login_360{}=Msg )->
	Account = Msg#pk_U2LS_Login_360.account,
    PlatformID = Msg#pk_U2LS_Login_360.platformID,
    AuthoCode = Msg#pk_U2LS_Login_360.authoCode,
    VersionRes = Msg#pk_U2LS_Login_360.versionRes,
    VersionExe = Msg#pk_U2LS_Login_360.versionExe,
    VersionGame = Msg#pk_U2LS_Login_360.versionGame,
    VersionPro = Msg#pk_U2LS_Login_360.versionPro,
	try
		case netUsers:getCurUserState() =:= ?UserState_UnCheckPass of
			false->throw(-1);
			true->ok
		end,

		netUsers:setCurUserState( ?UserState_WaitCheckPass ),

		case ((PlatformID =:= ?PLATFORM_360) and (platform360:is360Support() =:= yes)) of
			true->ok;
			false->throw(-2)
		end,

		case verify:verify360(AuthoCode) of 
			{success,UserID,Account0,AccessToken,RefreshToken}->
				?DEBUG_OUT("verify360 ok.Account:~p,AccessToken:~p,RefreshToken:~p",[Account0,AccessToken,RefreshToken]),
				%% 通知客户端，用户名,access_token,refreshToken
				netUsers:send( #pk_LS2U_Login_360{account=Account0,userid=UserID,access_token=AccessToken,refresh_token=RefreshToken} ),
				
				Params=#userDBLogin{account=Account0,platformID=PlatformID,versionRes=VersionRes,versionExe=VersionExe,versionGame=VersionGame,versionPro=VersionPro},
				Result = userDB:onUserLogin(netUsers:getCurUserSocket(),Params),	
				on_dbLoginResult(Result);
			error->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Disconnect,account=Account,userID=0,platId=PlatformID});
			failed->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_UserNameOrPassword,account=Account,userID=0,platId=PlatformID});
			timeout->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Timeout,account=Account,userID=0,platId=PlatformID});
			closed->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Disconnect,account=Account,userID=0,platId=PlatformID});
			_->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Unknown,account=Account,userID=0,platId=PlatformID})
		end
	catch
		-2->
			on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Unsupport,account=Account,userID=0,platId=PlatformID});
		_->
			on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Exception,account=Account,userID=0,platId=PlatformID})
	end.

on_U2LS_Login_UC( #pk_U2LS_Login_UC{}=Msg )->
	Account = Msg#pk_U2LS_Login_UC.account,
    PlatformID = Msg#pk_U2LS_Login_UC.platformID,
    AuthoCode = Msg#pk_U2LS_Login_UC.authoCode,
    VersionRes = Msg#pk_U2LS_Login_UC.versionRes,
    VersionExe = Msg#pk_U2LS_Login_UC.versionExe,
    VersionGame = Msg#pk_U2LS_Login_UC.versionGame,
    VersionPro = Msg#pk_U2LS_Login_UC.versionPro,
	try
		case netUsers:getCurUserState() =:= ?UserState_UnCheckPass of
			false->throw(-1);
			true->ok
		end,

		netUsers:setCurUserState( ?UserState_WaitCheckPass ),

		case ((PlatformID =:= ?PLATFORM_UC_android) and (platformUC:isUCSupport() =:= yes)) of
			true->ok;
			false->throw(-2)
		end,

		case verify:verifyUC(AuthoCode) of 
			{success,State_code,Data_ucid,Data_nickName}->
				?DEBUG_OUT("verifyUC ok.State_code[~p],Data_ucid[~p],Data_nickName[~s]",[State_code,Data_ucid,Data_nickName]),
				%% 通知客户端，用户名,access_token,refreshToken
				netUsers:send( #pk_LS2U_Login_UC{account=Account,userid=Data_ucid,nickName=Data_nickName} ),
				
				Params=#userDBLogin{account=common:formatString(Data_ucid),platformID=PlatformID,versionRes=VersionRes,versionExe=VersionExe,versionGame=VersionGame,versionPro=VersionPro},
				Result = userDB:onUserLogin(netUsers:getCurUserSocket(),Params),	
				on_dbLoginResult(Result);
			error->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Disconnect,account=Account,userID=0,platId=PlatformID});
			failed->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_UserNameOrPassword,account=Account,userID=0,platId=PlatformID});
			timeout->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Timeout,account=Account,userID=0,platId=PlatformID});
			closed->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Disconnect,account=Account,userID=0,platId=PlatformID});
			_->
				on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Unknown,account=Account,userID=0,platId=PlatformID})
		end
	catch
		-2->
			on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Unsupport,account=Account,userID=0,platId=PlatformID});
		_->
			on_dbLoginResult(#userDBLoginResult{resultCode=?Login_LS_Result_Fail_Exception,account=Account,userID=0,platId=PlatformID})
	end.

%%-------------------------------------------------------------------------------------
%%-------------------------------------------------------------------------------------
%%-------------------------------------------------------------------------------------

on_dbLoginResult( #userDBLoginResult{account=Account}=UserDBLoginResult )->
	try
		case netUsers:getCurUserState() =:= ?UserState_WaitCheckPass of
			false->throw(-1);
			true->ok
		end,
		
		case UserDBLoginResult#userDBLoginResult.resultCode of
			?Login_LS_Result_Succ->
				%%验证成功，检查是否有被封号
				case forbidden:forbiddenCheck(Account) of
					true->throw({forbiddenAccount});
					false->ok
				end,
				%%验证成功，检查是否有重复登录
				OtherLoginUser = main:getGlobalLoginUser( UserDBLoginResult#userDBLoginResult.userID ),
				case OtherLoginUser of
					{}->
						%%没有重复登录，登录成功
						%%设置用户表，
						etsBaseFunc:changeFiled( netUsers:getCurUserSocketTable(), netUsers:getCurUserSocket(), #userSocketRecord.userID, UserDBLoginResult#userDBLoginResult.userID ),
						etsBaseFunc:changeFiled( netUsers:getCurUserSocketTable(), netUsers:getCurUserSocket(), #userSocketRecord.userName, UserDBLoginResult#userDBLoginResult.account ),
						etsBaseFunc:changeFiled( netUsers:getCurUserSocketTable(), netUsers:getCurUserSocket(), #userSocketRecord.platId, UserDBLoginResult#userDBLoginResult.platId ),
						%%修改用户状态
						netUsers:setCurUserState( ?UserState_WaitUserAskGameServerList ),
						%%修改Socket检查验证
						put( "IsSocketCheckPass", true ),
						put( "UserID", UserDBLoginResult#userDBLoginResult.userID ),
						%%通知main，用户登录验证成功
						UserSocketRecord = netUsers:getCurUserSocketRecord(),
						main_PID ! { loginUser, UserDBLoginResult#userDBLoginResult.userID, netUsers:getCurUserSocket(), self(), UserSocketRecord#userSocketRecord.randIdentity },
						%%发送验证成功消息
						netUsers:send( #pk_LS2U_LoginResult{result=?Login_LS_Result_Succ,userID=UserDBLoginResult#userDBLoginResult.userID} ),
						?LOG_OUT( "username[~p] userid[~p] socket[~p] ip[~p] check pass to wait next ask",
									[UserDBLoginResult#userDBLoginResult.account,
									 UserDBLoginResult#userDBLoginResult.userID,
									 netUsers:getCurUserSocket(),
									 get("UserIP") ] ),
						ok;
					_->
						%%存在已登录用户，通知main，踢掉
						main_PID ! { kickOutUser, self(), UserDBLoginResult#userDBLoginResult.userID },
						%%修改用户状态
						netUsers:setCurUserState( ?UserState_WaitKickOutOther ),
						%%设置用户表，
						etsBaseFunc:changeFiled( netUsers:getCurUserSocketTable(), netUsers:getCurUserSocket(), #userSocketRecord.userID, UserDBLoginResult#userDBLoginResult.userID ),
						etsBaseFunc:changeFiled( netUsers:getCurUserSocketTable(), netUsers:getCurUserSocket(), #userSocketRecord.userName, UserDBLoginResult#userDBLoginResult.account ),
						%%重复了，main_PID会踢掉后再通知
						%%netUsers:send(#pk_LS2U_LoginResult{result=?Login_LS_Result_Fail_OtherLogin,userID=0}),
						?LOG_OUT( "username[~p] userid[~p] socket[~p] ip[~p] check pass to kick out old",
									[UserDBLoginResult#userDBLoginResult.account,
									 UserDBLoginResult#userDBLoginResult.userID,
									 netUsers:getCurUserSocket(),
									 get("UserIP")] ),
						ok
				end,
				ok;
			?Login_LS_Result_Fail_UserNameOrPassword->
				netUsers:send( #pk_LS2U_LoginResult{result=?Login_LS_Result_Fail_UserNameOrPassword,userID=0} ),
				%%设置状态
				netUsers:setCurUserState( ?UserState_WaitCloseUserSocket ),
				%%关socket
				gen_tcp:close( netUsers:getCurUserSocket() ),
				?LOG_OUT( "user sokcet[~p] check fail [~p]", [netUsers:getCurUserSocket(), UserDBLoginResult#userDBLoginResult.resultCode] ),
				ok;
			_->
				netUsers:send( #pk_LS2U_LoginResult{result=UserDBLoginResult#userDBLoginResult.resultCode,userID=0} ),
				%%设置状态
				netUsers:setCurUserState( ?UserState_WaitCloseUserSocket ),
				%%关socket
				gen_tcp:close( netUsers:getCurUserSocket() ),
				?LOG_OUT( "user socket[~p] check fail [~p]", [netUsers:getCurUserSocket(), UserDBLoginResult#userDBLoginResult.resultCode] ),
				ok
		end,
		ok
	catch
		{forbiddenAccount}->
			netUsers:send( #pk_LS2U_LoginResult{result=?Login_LS_Result_Fail_Forbidden,userID=0} ),
			%%设置状态
			netUsers:setCurUserState( ?UserState_WaitCloseUserSocket ),
			%%关socket
			gen_tcp:close( netUsers:getCurUserSocket() ),
			?LOG_OUT( "user socket[~p],account[~p] is forbidden", [netUsers:getCurUserSocket(),Account] ),
			ok;
		_->
			netUsers:send( #pk_LS2U_LoginResult{result=?Login_LS_Result_Fail_Exception,userID=0} ),
			%%设置状态
			netUsers:setCurUserState( ?UserState_WaitCloseUserSocket ),
			%%关socket
			gen_tcp:close( netUsers:getCurUserSocket() ),
			?LOG_OUT( "user socket[~p] check fail [~p]", [netUsers:getCurUserSocket(), UserDBLoginResult#userDBLoginResult.resultCode] ),
			ok
	end.

onMsgKickOutUserComplete()->
	try
		%%修改用户状态
		netUsers:setCurUserState( ?UserState_WaitCloseUserSocket ),
		%%通知用户，已踢掉上一个在线
		netUsers:send( #pk_LS2U_LoginResult{result=?Login_LS_Result_Fail_OtherLogin,userID=0} ),
		%%关socket
		gen_tcp:close( netUsers:getCurUserSocket() ),
		?LOG_OUT( "onMsgKickOutUserComplete user socket[~p]", [netUsers:getCurUserSocket()] ),
		ok
	catch
		_->ok
	end.

onMsgRequestGameServerList()->
	try
		case netUsers:getCurUserState() =:= ?UserState_WaitUserAskGameServerList of
			false->throw(-1);
			true->ok
		end,
		
		AllRunningServerList = gameServer:getAllRunningGameServerIDList(),
		case AllRunningServerList of
			[]->
				UnrunningList = gameServer:getAllUnRunningGameServerList(),
				case UnrunningList of
					[]->throw(-1);					
					_->ok
				end,
				ToMsgFunc = fun( GameServer )->			
					#pk_GameServerInfo{
								serverID=GameServer#gameServerRecord.serverID,
								name=GameServer#gameServerRecord.name,
								state=gameServer:getGameServerUserState( GameServer ),
								showIndex=GameServer#gameServerRecord.showInUserGameList,
								remmond=GameServer#gameServerRecord.remmond,
								maxPlayerLevel=0,
								isnew=GameServer#gameServerRecord.isnew,
								begintime=GameServer#gameServerRecord.begintime,
								hot=GameServer#gameServerRecord.hot
								}					
			 	end,
				UnrunningMsgList = lists:map( ToMsgFunc, UnrunningList ),		
				
				SetClosedList = gameServer:getAllSetClosdGameServerList(),
				ToFun= fun( GS )->			
					#pk_GameServerInfo{
								serverID=GS#gameServerRecord.serverID,
								name=GS#gameServerRecord.name,
								state=gameServer:getGameServerUserState( GS ),
								showIndex=GS#gameServerRecord.showInUserGameList,
								remmond=GS#gameServerRecord.remmond,
								maxPlayerLevel=0,
								isnew=GS#gameServerRecord.isnew,
								begintime=GS#gameServerRecord.begintime,
								hot=GS#gameServerRecord.hot
								}					
			 	end,
				SetClosedMsgList = lists:map( ToFun, SetClosedList ),	
				
				ToUser = #pk_LS2U_GameServerList{ gameServers=UnrunningMsgList--SetClosedMsgList},
				%%netUsers:send( ToUser ),
				sendGameServerListToUser( ToUser ),
				
				netUsers:setCurUserState( ?UserState_WaitUserSelGameServer ),
				
				throw(-1);
			
				%% 老版本 直接丢掉了  不在线的也不给发下去
				%%netUsers:send( #pk_LS2U_GameServerList{ gameServers=[] } ),
				%%throw(-1);
			_->ok
		end,
		
		put( "WaitGameServerAck_MaxPlayerLevel_List", AllRunningServerList ),
		netUsers:setCurUserState( ?UserState_WaitGameServerAckMaxPlayerLevel ),
		
		Msg = #pk_LS2GS_QueryUserMaxLevel{ userID = netUsers:getCurUserID() },
		
		MyFunc = fun( Record )->
						 gameServer:sendToGameServerByServerID( Record, Msg )
				 end,
		lists:map( MyFunc, AllRunningServerList ),
		
		put( "GameServerList", [] ),
		
		timer:send_after(2000,  {timeOut_WaitUserAskGameServerList}),
		
		?DEBUG_OUT( "onMsgRequestGameServerList usrid[~p] AllRunningServerList[~p]", [netUsers:getCurUserID(), AllRunningServerList] ),
		
		ok
	catch
		_->ok
	end.



on_gameServerClosed( ServerID )->
	%%用户所在GameServer断开，踢掉
	?LOG_OUT( "on_gameServerClosed ServerID[~p] socket[~p] UserID[~p]", [ServerID, netUsers:getCurUserSocket(), netUsers:getCurUserID()] ),
	gen_tcp:close( netUsers:getCurUserSocket() ),
	ok.

on_gameServer_QueryUserMaxLevelResult( ServerID, MaxPlayerLevel )->
	try
		?DEBUG_OUT( "on_gameServer_QueryUserMaxLevelResult userid[~p] ServerID[~p] MaxPlayerLevel[~p] begin", [netUsers:getCurUserID(), ServerID, MaxPlayerLevel] ),
		
		case netUsers:getCurUserState() =:= ?UserState_WaitGameServerAckMaxPlayerLevel of
			false->throw(-1);
			true->ok
		end,
		
		AllRunningServerList = get( "WaitGameServerAck_MaxPlayerLevel_List" ),
		case AllRunningServerList of
			[]->throw(-1);
			undefined->throw(-1);
			_->ok
		end,
		
		GameServer = gameServer:getGameServerRecord( ServerID ),
		case GameServer of
			{}->throw(-1);
			_->ok
		end,
		
		GameServerInfo = #pk_GameServerInfo{
											serverID=ServerID,
											name=GameServer#gameServerRecord.name,
											state=gameServer:getGameServerUserState( GameServer ),
											showIndex=GameServer#gameServerRecord.showInUserGameList,
											remmond=GameServer#gameServerRecord.remmond,
											maxPlayerLevel=MaxPlayerLevel,
											isnew=GameServer#gameServerRecord.isnew,
											begintime=GameServer#gameServerRecord.begintime,
											hot=GameServer#gameServerRecord.hot 
											},
		GameServerList = get( "GameServerList" ),
		case GameServerList of
			[]->
				case GameServer#gameServerRecord.hot =/= ?GameServer_User_State_Set_Closed of
					true->put( "GameServerList", [GameServerInfo] );
					false->ok
				end;
				
				
			undefined->
				case GameServer#gameServerRecord.hot =/= ?GameServer_User_State_Set_Closed of
					true->put( "GameServerList", [GameServerInfo] );
					false->ok
				end;
				
			_->
				case GameServer#gameServerRecord.hot =/= ?GameServer_User_State_Set_Closed of
					true->put( "GameServerList", GameServerList ++ [GameServerInfo] );
					false->ok
				end				
		end,
		
		AllRunningServerList2 = AllRunningServerList -- [ServerID],
		case AllRunningServerList2 of
			[]->
				%%GameServer回复完了，发消息给客户端
				UnrunningList = gameServer:getAllUnRunningGameServerList(),
				ToMsgFunc = fun( GameServer )->			
					#pk_GameServerInfo{
								serverID=GameServer#gameServerRecord.serverID,
								name=GameServer#gameServerRecord.name,
								state=gameServer:getGameServerUserState( GameServer ),
								showIndex=GameServer#gameServerRecord.showInUserGameList,
								remmond=GameServer#gameServerRecord.remmond,
								maxPlayerLevel=0,
								isnew=GameServer#gameServerRecord.isnew,
								begintime=GameServer#gameServerRecord.begintime,
								hot=GameServer#gameServerRecord.hot
								}					
			 	end,
				UnrunningMsgList = lists:map( ToMsgFunc, UnrunningList ),
				
				SetClosedList = gameServer:getAllSetClosdGameServerList(),
				ToFun= fun( GS )->			
					#pk_GameServerInfo{
								serverID=GS#gameServerRecord.serverID,
								name=GS#gameServerRecord.name,
								state=gameServer:getGameServerUserState( GS ),
								showIndex=GS#gameServerRecord.showInUserGameList,
								remmond=GS#gameServerRecord.remmond,
								maxPlayerLevel=0,
								isnew=GS#gameServerRecord.isnew,
								begintime=GS#gameServerRecord.begintime,
								hot=GS#gameServerRecord.hot
								}					
			 	end,
				SetClosedMsgList = lists:map( ToFun, SetClosedList ),
				
				AllMsgList = get( "GameServerList" ) ++ UnrunningMsgList -- SetClosedMsgList,
				ToUser = #pk_LS2U_GameServerList{ gameServers=AllMsgList},
				%%netUsers:send( ToUser ),
				sendGameServerListToUser( ToUser ),

				netUsers:setCurUserState( ?UserState_WaitUserSelGameServer ),
				?DEBUG_OUT( "on_gameServer_QueryUserMaxLevelResult userid[~p] send GameServerInfo[~p]", [netUsers:getCurUserID(), ToUser#pk_LS2U_GameServerList.gameServers] ),
				ok;
			_->
				put( "WaitGameServerAck_MaxPlayerLevel_List", AllRunningServerList2 ),
				?DEBUG_OUT( "on_gameServer_QueryUserMaxLevelResult userid[~p] continue AllRunningServerList2[~p]", [netUsers:getCurUserID(), AllRunningServerList2] ),
				ok
		end,

		ok
	catch
		_->?LOG_OUT( "on_gameServer_QueryUserMaxLevelResult userid[~p] ServerID[~p] MaxPlayerLevel[~p] throw", [netUsers:getCurUserID(), ServerID, MaxPlayerLevel] )
	end,
	ok.

on_U2LS_RequestSelGameServer( #pk_U2LS_RequestSelGameServer{}=Msg )->
	try
		?DEBUG_OUT( "on_U2LS_RequestSelGameServer userid[~p] Msg[~p] begin", [netUsers:getCurUserID(), Msg] ),
		
		case netUsers:getCurUserState() =:= ?UserState_WaitUserSelGameServer of
			false->throw(-1);
			true->ok
		end,
		
		ServerID = Msg#pk_U2LS_RequestSelGameServer.serverID,
		GameServer = gameServer:getGameServerRecord( ServerID ),
		case GameServer of
			{}->
				netUsers:send( #pk_LS2U_SelGameServerResult{ userID=0,ip="", port=0, identity="", errorCode=-3 } ),
				throw(-1);
			_->ok
		end,

		case GameServer#gameServerRecord.state of
			?GameServer_State_Running->ok;
			_->
				netUsers:send( #pk_LS2U_SelGameServerResult{ userID=0,ip="", port=0, identity="", errorCode=-6 } ),
				throw(-1)
		end,
%% 		case GameServer#gameServerRecord.state =:= ?GameServer_State_Running of
%% 			true->ok;
%% 			false->
%% 				netUsers:send( #pk_LS2U_SelGameServerResult{ userID=0,ip="", port=0, identity="", errorCode=-3 } ),
%% 				throw(-1)
%% 		end,
		
		case GameServer#gameServerRecord.hot =:= ?GameServer_User_State_Maintain  of
			true->
				Userid = netUsers:getCurUserID(),
				case loginMysqlProc:isUser4TestById(Userid) of 
					false ->
						netUsers:send( #pk_LS2U_SelGameServerResult{ userID=0,ip="", port=0, identity="", errorCode=-6 } ),
						throw(-1);
					true->ok
				end;
			false->ok
		end,

		User = netUsers:getCurUserSocketRecord(),

		gameServer:sendToGameServer( GameServer, #pk_LS2GS_UserReadyToLogin{userID=netUsers:getCurUserID(),
																			username= User#userSocketRecord.userName,
																			identity=User#userSocketRecord.randIdentity,
																		    platId=User#userSocketRecord.platId} ),
		netUsers:setCurUserState( ?UserState_WaitSelGameServerResult ),
		?DEBUG_OUT( "on_U2LS_RequestSelGameServer userid[~p] wait sel GameServer[~p]", [netUsers:getCurUserID(), GameServer] ),
		ok
	catch
		_->?LOG_OUT( "on_U2LS_RequestSelGameServer userid[~p] Msg[~p] throw", [netUsers:getCurUserID(), Msg] )
	end.

on_GS2LS_UserReadyLoginResult( ServerID, #pk_GS2LS_UserReadyLoginResult{}=Msg )->
	try
		?DEBUG_OUT( "on_GS2LS_UserReadyLoginResult Msg[~p] begin", [Msg] ),
		
		case netUsers:getCurUserState() =:= ?UserState_WaitSelGameServerResult of
			false->throw(-1);
			true->ok
		end,
		
		GameServer = gameServer:getGameServerRecord( ServerID ),
		case GameServer of
			{}->throw(-1);
			_->ok
		end,
		
		UserData = netUsers:getCurUserSocketRecord(),
		
		SendMsg = #pk_LS2U_SelGameServerResult{ userID=netUsers:getCurUserID(),
											    ip=GameServer#gameServerRecord.ip, 
												port=GameServer#gameServerRecord.port, 
												identity=UserData#userSocketRecord.randIdentity, 
												errorCode=Msg#pk_GS2LS_UserReadyLoginResult.result },
		netUsers:send( SendMsg ),
		
		case Msg#pk_GS2LS_UserReadyLoginResult.result >= 0 of
			true->
				main_PID ! { userReadyLoginWS, netUsers:getCurUserID(), ServerID },
				netUsers:setCurUserState( ?UserState_WaitGameServerAckLogin );
			false->
				netUsers:setCurUserState( ?UserState_WaitUserSelGameServer )
		end,

		?DEBUG_OUT( "on_GS2LS_UserReadyLoginResult userid[~p] SendMsg[~p] ", [netUsers:getCurUserID(), SendMsg] ),
		ok
	catch
		_->
			?LOG_OUT( "on_GS2LS_UserReadyLoginResult Msg[~p] throw", [Msg] ),
			SendMsg2 = #pk_LS2U_SelGameServerResult{ userID=0,ip="", port=0, identity="", errorCode=-1 },
			netUsers:send( SendMsg2 )
	end.

on_timeOut_WaitUserAskGameServerList()->
	try
		case netUsers:getCurUserState() =:= ?UserState_WaitGameServerAckMaxPlayerLevel of
			false->throw(-1);
			true->ok
		end,
		
%% 		AllRunningServerList = get( "WaitGameServerAck_MaxPlayerLevel_List" ),
%% 		case AllRunningServerList of
%% 			[]->throw(-1);
%% 			undefined->throw(-1);
%% 			_->ok
%% 		end,
%% 		
%% 		MyFunc = fun( ServerID )->
%% 					GameServer = gameServer:getGameServerRecord( ServerID ),
%% 					case GameServer of
%% 						{}->throw(-1);
%% 						_->ok
%% 					end,
%% 					
%% 					GameServerInfo = #pk_GameServerInfo{
%% 														serverID=ServerID,
%% 														name=GameServer#gameServerRecord.name,
%% 														state=gameServer:getGameServerUserState( GameServer ),
%% 														showIndex=GameServer#gameServerRecord.showInUserGameList,
%% 														remmond=GameServer#gameServerRecord.remmond,
%% 														maxPlayerLevel=0,
%% 														isnew=GameServer#gameServerRecord.isnew,
%% 														begintime=GameServer#gameServerRecord.begintime
%% 														},
%% 					GameServerList = get( "GameServerList" ),
%% 					case GameServerList of
%% 						[]->
%% 							put( "GameServerList", [GameServerInfo] );
%% 						undefined->
%% 							put( "GameServerList", [GameServerInfo] );
%% 						_->
%% 							put( "GameServerList", GameServerList ++ [GameServerInfo] )
%% 					end
%% 				 end,
%% 		lists:map( MyFunc, AllRunningServerList ),
%% 		ToUser = #pk_LS2U_GameServerList{ gameServers=get( "GameServerList" ) },
		
		GameServerList = gameServer:getAllGameServerList(),	
		ToMsgFunc = fun( GameServer )->			
					#pk_GameServerInfo{
									serverID=GameServer#gameServerRecord.serverID,
									name=GameServer#gameServerRecord.name,
									state=gameServer:getGameServerUserState( GameServer ),
									showIndex=GameServer#gameServerRecord.showInUserGameList,
									remmond=GameServer#gameServerRecord.remmond,
									maxPlayerLevel=0,
									isnew=GameServer#gameServerRecord.isnew,
									begintime=GameServer#gameServerRecord.begintime,
									hot=GameServer#gameServerRecord.hot
									}		
				 end,
		GameServerMsgList = lists:map( ToMsgFunc, GameServerList ),
		ToUser = #pk_LS2U_GameServerList{ gameServers=GameServerMsgList },
		%%netUsers:send( ToUser ),
		sendGameServerListToUser( ToUser ),
		
		netUsers:setCurUserState( ?UserState_WaitUserSelGameServer ),
		?DEBUG_OUT( "on_timeOut_WaitUserAskGameServerList userid[~p] send GameServerInfo[~p]", [netUsers:getCurUserID(), ToUser#pk_LS2U_GameServerList.gameServers] ),
		ok
	catch
		_->ok
	end,
	ok.

sendGameServerListToUser( #pk_LS2U_GameServerList{} = MsgToUser )->
	Userid = netUsers:getCurUserID(),
	IsSpecUser = loginMysqlProc:isUser4TestById(Userid),
	
	MyFunc = fun( Record )->
					case Record#pk_GameServerInfo.hot of
						?GameServer_User_State_SpecCanVisable->
							case IsSpecUser of
								true->Record;
								false->{}
							end;
						_->Record
					end
			 end,
	GameServerList = lists:map( MyFunc, MsgToUser#pk_LS2U_GameServerList.gameServers ),
	
	MyFunc2 = fun( Record )->
					  Record =/= {}
			  end,
	GameServerList2 = lists:filter( MyFunc2, GameServerList ),
	
	MsgToUser2 = setelement( #pk_LS2U_GameServerList.gameServers, MsgToUser, GameServerList2 ),
	netUsers:send( MsgToUser2 ),
	ok.
	
