%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(userHandle).

%%
%% Include files
%%
-include("db.hrl").
-include("playerDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("proto_ret.hrl").
-include("version.hrl").
-include("globalDefine.hrl").
-include("logdb.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

on_U2GS_RequestLogin( #pk_U2GS_RequestLogin{}=Msg )->
	put("on_U2GS_RequestLogin_ret",?Login_GS_Result_Fail_Full),
	try
		
		case netUsers:getCurUserState() =:= ?User_State_UnCheckPass of
			false->throw( {return, -1} );
			true->ok
		end,
		
		%% check globle flag:is_forbid_login
		case main:getIsForbidLogin() of
			true ->throw( {return, -2} );
			_->ok
		end,
		
		%% check protocol version
		%ProtoVer = main:getProtocolVersion(),
		case Msg#pk_U2GS_RequestLogin.protocolVer >=  ?MIN_PROTOCOL_VERSION  of
			true -> ok;
			false->
				put("on_U2GS_RequestLogin_ret",?Login_GS_Result_Fail_ProtVerErr),
				throw( {return, -3} )
		end,
	
		UserID = Msg#pk_U2GS_RequestLogin.userID, 
		ReadyLoginUser = main:getReadyLoginUserRecord( UserID ),
		case ReadyLoginUser of
			{}->throw( {return, -4} );
			_->ok
		end,
		
		case ReadyLoginUser#readyLoginUser.unable_time =< common:timestamp() of
			true->throw( {return, -5} );
			_->ok
		end,
		
		case ReadyLoginUser#readyLoginUser.identitity =:= Msg#pk_U2GS_RequestLogin.identity of
			false->throw( {return, -6} );
			_->ok
		end,
		
		?LOG_OUT( "userid[~p] name[~p] socket[~p] login begin.", [UserID, ReadyLoginUser#readyLoginUser.name, netUsers:getCurUserSocket()] ),
		
		put( "UserID", UserID ),
		put( "UserName", ReadyLoginUser#readyLoginUser.name ),
		put( "IsSocketCheckPass", true ),
		put( "Identity", ReadyLoginUser#readyLoginUser.identitity ),	
		put("netUsers_platId",ReadyLoginUser#readyLoginUser.platId),
		put("PlayerProtocolVersion",Msg#pk_U2GS_RequestLogin.protocolVer),
		
		%db:changeFiled( socketData, netUsers:getCurUserSocket(), #socketData.userId, UserID ),
		main:changeSocketData_rpc({netUsers:getCurUserSocket(), #socketData.userId, UserID}),
		
		netUsers:setCurUserState( ?User_State_WaitPlayerList ),
		
		
		SendMsg = #pk_GS2U_LoginResult{result=0},
		netUsers:sendToUser( SendMsg ),
		
		mainPID ! { userLogin, UserID },
		%% modify for insert mysql directly
		%dbProcess_PID ! { getPlayerList, self(), UserID },
		PlayerList = dbProcess:on_getPlayerList(UserID),
		%% should handle PlayerList is []
		on_getPlayerList( PlayerList ),

		
		?LOG_OUT( "userid[~p] name[~p] socket[~p] login succ.", [UserID, ReadyLoginUser#readyLoginUser.name, netUsers:getCurUserSocket()] ),
		ok
	catch
		{ return, ReturnCode }->
			?LOG_OUT( "user ~p login false ReturnCode [~p]", [netUsers:getCurUserSocket(), ReturnCode] ),
			SendMsg2 = #pk_GS2U_LoginResult{result=get("on_U2GS_RequestLogin_ret")},
			netUsers:sendToUser( SendMsg2 ),
			gen_tcp:close(netUsers:getCurUserSocket()),
			%netUsers:doUserOffline( 0 ),
			put( "receiveUser", false ),
			throw ( {'Login fail', -1} )
			
			%gen_tcp:shutdown( netUsers:getCurUserSocket(), read )
	end.

on_getPlayerList( PlayerList )->
	try
		case ( netUsers:getCurUserState() =:= ?User_State_WaitPlayerList ) or 
			 ( netUsers:getCurUserState() =:= ?User_State_LobbyChar ) of
			false->throw(-1);
			true->ok
		end,
		
		netUsers:sendToUser( #pk_GS2U_UserPlayerList{info=PlayerList} ),
		
		netUsers:setCurUserState( ?User_State_LobbyChar ),
		
		ok
	catch
		_->ok
	end.

on_U2GS_RequestCreatePlayer( #pk_U2GS_RequestCreatePlayer{} = Msg )->
	try
		case netUsers:getCurUserState() =:= ?User_State_LobbyChar of
			false->throw( {return, -1} );
			true->ok
		end,
		
		Class = Msg#pk_U2GS_RequestCreatePlayer.classValue,
		case ( Class < 0 ) or ( Class >= ?Player_Class_Count ) of
			true->throw( {return, -2} );
			false->ok				
		end,
		Camp = Msg#pk_U2GS_RequestCreatePlayer.camp,
		case ( Camp < 0 ) or ( Camp >= ?CAMP_COUNT ) of
			true->throw( {return, -3} );
			false->ok				
		end,
		Sex = Msg#pk_U2GS_RequestCreatePlayer.sex,
		case ( Sex < 0 ) or ( Sex >= 2 ) of
			true->throw( {return, -4} );
			false->ok				
		end,
		
		%% modify for insert mysql directly
		%dbProcess_PID ! { createPlayer, self(), netUsers:getCurUserID(), Msg },
		netUsers:setCurUserState( ?User_State_WaitCreatePlayer ),
		UserID = netUsers:getCurUserID(),
		{Result, PlayerInfo} = dbProcess:on_createPlayer(UserID, Msg),
		on_createPlayerResult(UserID, Result, PlayerInfo ),
		
		
		
		
		ok
	catch
		{ return, ReturnCode }->
			?LOG_OUT( "on_U2GS_RequestCreatePlayer user[~p] fail ReturnCode[~p] Msg[~p]", [netUsers:getCurUserID(), ReturnCode, Msg] ),
			ok
	end.


on_U2GS_ChangePlayerName( #pk_U2GS_ChangePlayerName{id=PlayerID,name=Name} = _Msg ) ->
	try
		put("changePlayerNameResult",?ChangePlayerName_Result_Fail_Error),
		case netUsers:getCurUserState() =:= ?User_State_LobbyChar of
			false->
				put("changePlayerNameResult",?ChangePlayerName_Result_Fail_Error ),
				throw(-1);
			true->ok
		end,
	
		NameLen = string:len( Name ),
		case ( NameLen < ?Min_CreatePlayerName_Len ) or ( NameLen > ?Max_CreatePlayerName_Len*3 ) of
			true->
				put("changePlayerNameResult",?ChangePlayerName_Result_Fail_Name_Unvalid),
				throw(-1);
			false->ok				
		end,

		case forbidden:checkForbidden(Name) of
			true->
				put("changePlayerNameResult",?ChangePlayerName_Result_Fail_Name_Forbidden),
				throw(-1);
			false->ok
		end,
		
		%% -> 0 or id  (0: mean not exist this player)
		case mySqlProcess:isPlayerExistByName(  Name ) of
			0 -> ok;
			_-> put("changePlayerNameResult",?ChangePlayerName_Result_Fail_Name_Exist),
				throw(-1)
		end,
		
		UserID = netUsers:getCurUserID(),
		case mySqlProcess:update_playerNameByPlayerID(PlayerID,UserID,Name) of
			{error, _ } ->
				put("changePlayerNameResult",?ChangePlayerName_Result_Fail_Error),
				throw(-1);
			_->ok
		end,
		
		?LOG_OUT( "user[~p] on_U2GS_ChangePlayerName PlayerID[~p] Name[~p] succ", [UserID, PlayerID, Name] ),
		
		netUsers:sendToUser( #pk_GS2U_ChangePlayerNameResult{retCode=?ChangePlayerName_Result_Succ} ),
		PlayerList = dbProcess:on_getPlayerList(UserID),
		%% should handle PlayerList is []
		on_getPlayerList( PlayerList )
	catch
		_->netUsers:sendToUser( #pk_GS2U_ChangePlayerNameResult{retCode=get("changePlayerNameResult")} ) 
	end.


on_U2GS_SetProtectPwd( #pk_U2GS_SetProtectPwd{id=PlayerID,oldpwd= OldPwd,pwd=Pwd} = _Msg ) ->
	try
		put("SetProtectPwdResult",?SetProtectPwd_Result_Fail_Error),		
	
		PwdLen = string:len( Pwd ),
		case ( PwdLen < ?Min_CreatePlayerName_Len ) or ( PwdLen > ?Max_CreatePlayerName_Len*3 ) of
			true->
				put("SetProtectPwdResult",?SetProtectPwd_Result_Fail_Length),
				throw(-1);
			false->ok				
		end,			
		
		UserID = netUsers:getCurUserID(),
		case mySqlProcess:isRightOldProtectPwd(PlayerID,UserID,OldPwd) of
			0 -> ok;
			_-> put("SetProtectPwdResult",?SetProtectPwd_Result_Fail_Old_Error),
				throw(-1)
		end,
		
		case mySqlProcess:update_playerProtectPwdByPlayerID(PlayerID,UserID,Pwd) of
			{error, _ } ->
				put("SetProtectPwdResult",?ChangePlayerName_Result_Fail_Error),
				throw(-1);
			_->ok
		end,
		
		netUsers:sendToUser( #pk_GS2U_SetProtectPwdResult{retCode=?SetProtectPwd_Result_Succ} )
		
	catch
		_->netUsers:sendToUser( #pk_GS2U_SetProtectPwdResult{retCode=get("SetProtectPwdResult")} ) 
	end.


		



on_createPlayerResult(UserID, Result, PlayerInfo )->
	try
		case netUsers:getCurUserState() =:= ?User_State_WaitCreatePlayer of
			false->throw(-1);
			true->ok
		end,
		
		netUsers:sendToUser( #pk_GS2U_CreatePlayerResult{errorCode=Result} ),
		netUsers:setCurUserState( ?User_State_LobbyChar ),
		case Result =:= ?CreatePlayer_Result_Succ of
			false->ok;
			true->
				Name = PlayerInfo#pk_UserPlayerData.name,
				Camp = PlayerInfo#pk_UserPlayerData.classValue,
				Sex = PlayerInfo#pk_UserPlayerData.sex,
				logdbProcess:write_log_player(UserID,Name,Camp,Sex),			
		
				%% modify for insert mysql directly
				PlayerList = dbProcess:on_getPlayerList(UserID),
				%% should handle PlayerList is []
				on_getPlayerList( PlayerList )
				
		end,
		ok
	catch
		_->ok
	end.

on_U2GS_RequestDeletePlayer( #pk_U2GS_RequestDeletePlayer{}=Msg )->
	try
		case netUsers:getCurUserState() =:= ?User_State_LobbyChar of
			false->throw(-1);
			true->ok
		end,
		
		%% modify for insert mysql directly
		%dbProcess_PID ! { deletePlayer, self(), netUsers:getCurUserID(), Msg },
		netUsers:setCurUserState( ?User_State_WaitDeletePlayer ),
		UserID = netUsers:getCurUserID(),
		{Result, PlayerID} = dbProcess:on_deletePlayer( UserID, Msg),
		on_deletePlayerResult(UserID, Result, PlayerID ),
		
		
		
		ok
	catch
		_->ok
	end.

on_deletePlayerResult(UserID, Result, PlayerID )->
	try
		case netUsers:getCurUserState() =:= ?User_State_WaitDeletePlayer of
			false->throw(-1);
			true->ok
		end,
		
		netUsers:sendToUser( #pk_GS2U_DeletePlayerResult{playerID=PlayerID, errorCode=Result} ),
		netUsers:setCurUserState( ?User_State_LobbyChar ),
		case Result =:= ?DeletePlayer_Result_Succ of
			false->
				ok;
			true->
				PlayerList = dbProcess:on_getPlayerList(UserID),
				%% should handle PlayerList is []
				on_getPlayerList( PlayerList )
		end,
		
		ok
	catch
		_->ok
	end.

on_U2GS_SelPlayerEnterGame( #pk_U2GS_SelPlayerEnterGame{}=Msg, IsFirst )->
	put( "on_U2GS_SelPlayerEnterGame", ?SelPlayer_Result_PlayerCount_Fail ),
	try
		case netUsers:getCurUserState() =:= ?User_State_LobbyChar of
			false->throw(-2);
			true->ok
		end,
		 
		%% whether should remind the player to transfer old recharge
		?LOG_OUT("on_U2GS_SelPlayerEnterGame user[~p] socket[~p] playerid[~p] begin",[netUsers:getCurUserID(), netUsers:getCurUserSocket(), Msg#pk_U2GS_SelPlayerEnterGame.playerID] ),
		case IsFirst of
			true ->
				case mySqlProcess:getOldRechargeRmbByAccount(get( "UserName"),get("netUsers_platId") ) of
					0->
						netUsers:setCurUserState( ?User_State_WaitSelPlayer ),
						{Result,PlayerOnlineDBData} = dbProcess:on_selPlayer( netUsers:getCurUserID(), Msg),
						on_selPlayerResult( Result, PlayerOnlineDBData ),					
						%% player enter game success, then start timer to save player data
						erlang:send_after(?SavePlayerDataTimer, self(),{netUsersTimer_savePlayerData} );
					OldRechargeRmb->
						case  mySqlProcess:get_playerName_by_id(Msg#pk_U2GS_SelPlayerEnterGame.playerID) of
							[]->throw(-1);
							Name->
								?DEBUG_OUT("--has old recharge,OldRechargeRmb:~p",[OldRechargeRmb]),
								WhetherMsg = #pk_GS2U_WhetherTransferOldRecharge{playerID=Msg#pk_U2GS_SelPlayerEnterGame.playerID,
																		name=Name,
																		rechargeRmb=OldRechargeRmb},
								player:send( WhetherMsg )
								%% will selPlayer when recv the pk_U2GS_TransferOldRechargeToPlayer
						end
				end;
			false ->
				netUsers:setCurUserState( ?User_State_WaitSelPlayer ),
				{Result,PlayerOnlineDBData} = dbProcess:on_selPlayer( netUsers:getCurUserID(), Msg),
				on_selPlayerResult( Result, PlayerOnlineDBData ),					
				%% player enter game success, then start timer to save player data
				erlang:send_after(?SavePlayerDataTimer,self(), {netUsersTimer_savePlayerData} )
		end				
	catch
		-2->
			?LOG_OUT( "on_selPlayer userid ~p error state~p", [netUsers:getCurUserID(), netUsers:getCurUserState()] );
		_->
			Msg2 = #pk_GS2U_SelPlayerResult{result=get( "on_U2GS_SelPlayerEnterGame")},
			player:send( Msg2 ),
			%gen_tcp:shutdown( netUsers:getCurUserSocket(), read ),
			?DEBUG_OUT( "on_selPlayer userid ~p Result ~p", [netUsers:getCurUserID(), get( "on_U2GS_SelPlayerEnterGame")] ),
			gen_tcp:close(netUsers:getCurUserSocket()),
			put( "receiveUser", false ),
			throw ( {'enterGame fail', -1} )
	end.

on_selPlayerResult( Result, #playerOnlineDBData{}=PlayerOnlineDBData )->
	case netUsers:getCurUserState() =:= ?User_State_WaitSelPlayer of
		false->throw(-1);
		true->ok
	end,
	
	case Result >= 0 of
		true->ok;
		false->
			netUsers:setCurUserState( ?User_State_LobbyChar ),
			put( "on_U2GS_SelPlayerEnterGame", Result ),
			throw(-1)
	end,
	
	%% send selPlayer success to player
	Msg = #pk_GS2U_SelPlayerResult{result=?SelPlayer_Result_Succ},
	player:send( Msg ),
	
	player:onPlayerOnline(PlayerOnlineDBData),
	
	ok.


onKickOut( Reson )->
	Msg = #pk_PlayerKickOuted{reserve=0},
 	player:send( Msg ),
 	%gen_tcp:shutdown( netUsers:getCurUserSocket(), read ),
	gen_tcp:close(netUsers:getCurUserSocket()),
	?DEBUG_OUT( "onKickOut userid ~p Reson ~p", [netUsers:getCurUserID(), Reson] ),
	ok.

on_U2GS_PlayerClientInfo( #pk_U2GS_PlayerClientInfo{playerid=PlayerID,platform= Platform,machine=Machine} = _Msg ) ->
	try
		PlayerInfo = player:getPlayerRecord(PlayerID),
		case PlayerInfo of
			{} -> throw(-1);
			_  ->	
			UserID = netUsers:getCurUserID(),
			logdbProcess:write_log_player_machine(PlayerID,UserID,Platform,Machine)
		end
	catch
		_->ok
	end.	



on_U2GS_TransferOldRechargeToPlayer( #pk_U2GS_TransferOldRechargeToPlayer{playerId=PlayerID,isTransfer=IsTransfer} ) ->
	case IsTransfer of
		0->ok;
		_->%%转钱
			transferOldRechargeById(PlayerID)
	end,
	on_U2GS_SelPlayerEnterGame( #pk_U2GS_SelPlayerEnterGame{playerID=PlayerID},false).
	

transferOldRechargeById(PlayerID)->
	try
		case netUsers:getCurUserState() =:= ?User_State_LobbyChar of
			true->ok;
			false->throw(-1)
		end,
				
		case mySqlProcess:isPlayerExistByIdAndUserId(PlayerID,get( "UserID" )) of
			0->throw(-1);
			_->ok
		end,
		
		case mySqlProcess:getOldRechargeRmbByAccount(get( "UserName"),get("netUsers_platId") ) of
			0->throw(-1);
			Ammount->
				Gold_Mod=Ammount*?RMB_GOLD_RATIO,
				Gold_Old = 0,
				%% 更改金币数量
				case mySqlProcess:addGoldForChargeByPlayerID(PlayerID,Gold_Mod) of
					{error,_}->
						throw(-1);
					{ok,_}->
						%% delete the related record in transfer_account_recharge
						mySqlProcess:deleteTransferAccountRechargeRecord(get( "UserName"),get("netUsers_platId") ),
						Gold_New=Gold_Old+Gold_Mod,
						%% 留日志
						logdbProcess:write_log_recharge_succ("transferOldRecharge",get("netUsers_platId"),get( "UserName"),get( "UserID" ),PlayerID,Ammount),
						%% 更改金币日志
						logdbProcess:write_log_gold_add(PlayerID,Gold_Old,Gold_Mod,Gold_New,?Money_Change_Recharge,"transferOldRecharge"),
											
						Msg1 = #pk_GS2U_TransferOldRechargeResult{errorCode=0},
						player:send( Msg1 )					
				end		
		end
	catch
		_->
			Msg2 = #pk_GS2U_TransferOldRechargeResult{errorCode=-1},
			player:send( Msg2 )
	end.
	



