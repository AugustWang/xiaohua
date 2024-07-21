-module(team).

%% add by wenziyong for gen server
-behaviour(gen_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%
%% Include files
%%
-include("db.hrl").
-include("package.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("playerDefine.hrl").
-include("hdlt_logger.hrl").
-include("mapDefine.hrl").
-include("TeamDfine.hrl").
-include("condition_compile.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%%record define
%%

%% %%组队邀请列表
%% -record(inviteList,{inviter,timeOut}).
%% 
%% %%组队申请列表
%% -record(requstList,{requster,timeOut}).
%% 
%% %%当前队伍进程里保存的玩家信息
%% -record(teamPlayerList,{playerMapPiD,     %%玩家所在地图进程ID
%% 						playerPID,        %%玩家进程ID
%% 						playerId,         %%玩家ID 作为key值
%% 						playerTeamId,     %%玩家所在队伍ID
%% 						playerName,       %%玩家名字
%% 						sex,              %%玩家性别
%% 						career,           %%玩家职业
%% 						faction,          %%玩家阵营
%% 						level,            %%玩家等级
%% 						life_max,         %%玩家最大生命
%% 						life,             %%玩家当前生命
%% 						map_id,           %%玩家所在地图ID
%% 						mapdata_id,       %%玩家所在地图数据ID
%% 						posX,             %%玩家X坐标
%% 						posY,             %%玩家Y坐标
%% 						inviteList,       %%当前玩家被邀请列表
%% 						requstList}).     %%当前玩家被请求列表     
%% 
%% %%当前队伍进程里保存的队伍信息
%% -record(teamInfo, {teamId,teamLeaderId,teamMemberInfo}).


start_link() ->
	gen_server:start_link({local,teamThread},?MODULE, [], [{timeout,?Start_Link_TimeOut_ms}]).



init([]) ->
	teamProcessInit(),
    {ok, {}}.


handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.



terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%队伍进程初始化
teamProcessInit()->
	_TeamPlayerInfoTable = ets:new( 'teamPlayerInfoTable', [protected, named_table, { keypos, #teamPlayerInfo.playerID }] ),
	
	_TeamInfoTable = ets:new( 'teamInfoTable', [protected, named_table, { keypos, #teamInfo.teamID }] ),
	
	_InviteListInfoTable = ets:new( 'inviteListInfoTable', [protected, named_table, { keypos, #inviteList.playerID }] ),
	
	erlang:send_after( ?TeamUpdateInviteList,self(), {updateInviteListTimer} ),
	erlang:send_after( ?TeamDeletePlayerTimer, self(),{teamDeletePlayerTimer} ),
	
	put("TeamMoudle",true),
	ok.

%%返回队伍玩家Table
getTeamPlayerTable()->
	teamPlayerInfoTable.

%%返回邀请者列表
getInviteListTable() ->
	inviteListInfoTable.

%%构建队伍64位唯一ID
ceartTeamId()->
	TeamId=map:makeObjectID(?Object_Type_Team, db:memKeyIndex(teamInfo)), % not persistent
	TeamId.

%%返回队伍信息Table
getTeamInfoTable()->
	teamInfoTable.

%%队伍进程消息处理
handle_info(Info, StateData)->	
	put("TeamMoudle",true),

	try
	case Info of
		{quit}->
		  ?DEBUG_OUT("TeamMoudle recv quit"),
		  put( "TeamMoudle", false );
		{updateTeamMemberShortInfo, TeamID}->
			on_updateTeamMemberShortInfo( TeamID );
		{updateInviteListTimer}->
			on_updateInviteListTimer();
		{teamDeletePlayerTimer}->
			on_teamDeletePlayerTimer();
		
		{ playerMsg_Offline, PlayerID }->
			on_playerMsg_Offline( PlayerID );
		{ mapMsg_PlayerEnterMap, TeamMemberMapInfo }->
			on_mapMsg_PlayerEnterMap( TeamMemberMapInfo );
		{ mapMsg_PlayerQuitMap, TeamID, PlayerID }->
			on_mapMsg_PlayerQuitMap( TeamID, PlayerID );
		{ mapMsg_PlayerMapInfo, TeamID, TeamMemberMapInfo }->
			updateTeamPlayerMapInfo( TeamID, TeamMemberMapInfo );
		{ fastTeamCopyMap, FromPID, CanEnterPlayers, Param }->
			on_fastTeamCopyMap( FromPID, CanEnterPlayers, Param );

		{chat, TeamID, Msg}->
			sendMsgToAllMemberByTeamID(TeamID, Msg);
		
		{ u2s_msg_Team, PlayerID, Msg }->
			case element( 1, Msg ) of
				pk_inviteCreateTeam->
					on_inviteCreateTeam( PlayerID, Msg#pk_inviteCreateTeam.targetPlayerID );
				pk_ackInviteCreateTeam->
					on_ackInviteCreateTeam( PlayerID, Msg );
				pk_inviteJoinTeam->
					on_inviteJoinTeam( PlayerID, Msg );
				pk_ackInviteJointTeam->
					on_ackInviteJointTeam( PlayerID, Msg );
				pk_applyJoinTeam->
					on_applyJoinTeam( PlayerID, Msg );
				pk_ackQueryApplyJoinTeam->
					on_ackQueryApplyJoinTeam( PlayerID, Msg );
				pk_teamQuitRequest->
					on_teamQuitRequest( PlayerID, Msg );
				pk_teamKickOutPlayer->
					on_teamKickOutPlayer( PlayerID, Msg );
				pk_teamQueryLeaderInfoRequest->
					on_teamQueryLeaderInfoRequest( PlayerID, Msg );
				pk_teamChangeLeaderRequest->
					on_teamChangeLeaderRequest( PlayerID, Msg );
				_->ok
			end,
			ok;
		
		Unkown->
			?LOG_OUT("TeamMoudle receive unkown[~p]", [Unkown])
		end,

	case get("TeamMoudle") of
		true->{noreply, StateData};
		false->{stop, normal, StateData}
	end

	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[?MODULE,_Why, erlang:get_stacktrace()] ),
			{noreply, StateData}
	end.

%%返回一个玩家是否是某队伍的成员
isPlayerInTeam( TeamInfo, PlayerID )->
	try
		MyFunc = fun( Record )->
					case Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerID =:= PlayerID of
						true->throw( {return, true} );
						false->ok
					end
				 end,
		lists:foreach( MyFunc, TeamInfo#teamInfo.memberList ),
		false
	catch
		{ return, Return }->Return
	end.

deleteRecordFormInvite(InviteID) ->
	Q = ets:fun2ms( fun(#inviteList{playerID=CurInviteeID, 
										inviteID=CurInviteID} = Record ) 
						 when ( CurInviteID =:= InviteID ) -> Record end),
	Players = ets:select(?MODULE:getInviteListTable(), Q),
	
	MyFunc = fun( Record )->
					etsBaseFunc:deleteRecord(?MODULE:getInviteListTable(), Record)
			 end,
	lists:foreach( MyFunc, Players ).

resetInviteTeamTable(PlayerID) ->
	InviteListInfo = etsBaseFunc:readRecord(?MODULE:getInviteListTable(), PlayerID),
	case InviteListInfo of
		{}->ok;
		_->
			Q = ets:fun2ms( fun(#teamPlayerInfo{playerID=DB_PlayerID, 
												teamID=TeamID, 
												teamMemberMapInfo=_,
												isOnline=IsOnline, 
												offlineTime=OfflineTime,
												inviteTargetList=InviteTargetList} = Record ) 
								 when ( DB_PlayerID =:= InviteListInfo#inviteList.inviteID ) -> Record end),
			Players = ets:select(?MODULE:getTeamPlayerTable(), Q),
			
			MyFunc = fun( Record )->
						MyFunc = fun( TargetRecord )->
									 case TargetRecord#teamInviteTargetInfo.playerID =:= PlayerID of %%被邀请者
										 true->
											 TargetRecord1 = setelement( #teamInviteTargetInfo.time, TargetRecord, 0 ),
											 setelement( #teamInviteTargetInfo.playerID, TargetRecord1, 0 );
										 false-> TargetRecord
									 end
								 end,
						InviteTargetListInfo = lists:map( MyFunc, Record#teamPlayerInfo.inviteTargetList ),							 
						etsBaseFunc:changeFiled(?MODULE:getTeamPlayerTable(), Record#teamPlayerInfo.playerID, #teamPlayerInfo.inviteTargetList, InviteTargetListInfo)
					 end,
			lists:foreach( MyFunc, Players )
	end.

%%玩家下线
on_playerMsg_Offline( PlayerID )->
	TeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), PlayerID ),
	case TeamPlayerInfo of
		{}->ok;
		_->
			TeamMemberMapInfo = #teamMemberMapInfo{
												   playerID = PlayerID, 
												   playerName = TeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.playerName,
												   level = TeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.level, 
												   camp = TeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.camp, 
												   fation = TeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.fation,
												   sex = TeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.sex, 
												   life_percent=0,
												   x = 0, 
												   y = 0, 
												   map_data_id = 0, 
												   mapID = 0, 
												   mapPID = 0, 
												   playerPID = 0
												   },
			
			etsBaseFunc:changeFiled( ?MODULE:getTeamPlayerTable(), PlayerID, #teamPlayerInfo.isOnline, 0 ),
			etsBaseFunc:changeFiled( ?MODULE:getTeamPlayerTable(), PlayerID, #teamPlayerInfo.offlineTime, common:timestamp() ),
			?DEBUG_OUT( "on_playerMsg_Offline PlayerID[~p] TeamPlayerInfo[~p]", [PlayerID, TeamPlayerInfo] ),
			updateTeamPlayerMapInfo( TeamPlayerInfo#teamPlayerInfo.teamID, TeamMemberMapInfo ),
			
			case TeamPlayerInfo#teamPlayerInfo.teamID =/= 0 of
				true->
					TeamInfo = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), TeamPlayerInfo#teamPlayerInfo.teamID ),
					case TeamInfo of
						{}->ok;
						_->
							Msg = #pk_teamPlayerOffline{playerID=PlayerID},
							?MODULE:sendMsgToAllMember(TeamInfo, Msg),
							
							%%队伍所有队员下线，队伍解散，gaofushuai,2013.3.30
							put( "on_playerMsg_Offline_find", 0 ),
							put( "on_playerMsg_Offline_time", 0 ),
							MyFunc = fun( Record )->
											 case Record#teamMemberInfo.isOnline =:= 0 of
												 true->ok;
												 false->
													 case get( "on_playerMsg_Offline_find" ) =:= 0 of
														 true->
															 put( "on_playerMsg_Offline_find", Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerID ),
															 put( "on_playerMsg_Offline_time", Record#teamMemberInfo.joinTime );
														 false->
															 case Record#teamMemberInfo.joinTime < get( "on_playerMsg_Offline_time" ) of
																 true->
																	 put( "on_playerMsg_Offline_find", Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerID ),
																	 put( "on_playerMsg_Offline_time", Record#teamMemberInfo.joinTime );
																 false->ok
															 end
													 end
											 end
									 end,
							lists:foreach(MyFunc, TeamInfo#teamInfo.memberList ),
							case get("on_playerMsg_Offline_find") =/= 0 of
								true->%%还有人在线，如果是队长，考虑移交
									case TeamInfo#teamInfo.leaderPlayerID =:= PlayerID of
										true->%%是队长离线，移交
											%%修改队长
											etsBaseFunc:changeFiled( ?MODULE:getTeamInfoTable(), 
																	 TeamPlayerInfo#teamPlayerInfo.teamID, 
																	 #teamInfo.leaderPlayerID, 
																	 get("on_playerMsg_Offline_find") ),
											%%通知地图
											TeamInfo2 = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), TeamPlayerInfo#teamPlayerInfo.teamID ),
											?MODULE:sendTeamInfoToMap(TeamInfo2, false),
											%%通知玩家
											MsgToUser = #pk_teamChangeLeader{ playerID=get("on_playerMsg_Offline_find") },
											?MODULE:sendMsgToAllMember(TeamInfo2, MsgToUser),
											
											?DEBUG_OUT( "PlayerID[~p] offline to change team leader [~p]",
														[PlayerID, get("on_playerMsg_Offline_find")] ),
											ok;
										false->ok
									end,
									ok;
								false->%%全都不在线了，解散队伍
									?MODULE:disbandTeam(TeamInfo)
							end
					end;
				false->ok
			end,
			resetInviteTeamTable(PlayerID)
	end,
	ok.

%%定时删除已离线的无队玩家
on_teamDeletePlayerTimer()->
	erlang:send_after( ?TeamDeletePlayerTimer, self(),{teamDeletePlayerTimer} ),
	Now = common:timestamp() - 60,
	Q = ets:fun2ms( fun(#teamPlayerInfo{playerID=DB_PlayerID, 
										teamID=TeamID, 
										teamMemberMapInfo=_,
										isOnline=IsOnline, 
										offlineTime=OfflineTime } = _Record ) 
						 when ( IsOnline =:= 0 ) andalso 
							  ( TeamID =:= 0 ) andalso
							  ( OfflineTime + 60 =< Now )-> DB_PlayerID end),
	Players = ets:select(?MODULE:getTeamPlayerTable(), Q),
	
	MyFunc = fun( Record )->
					 ?DEBUG_OUT( "on_teamDeletePlayerTimer Record[~p]", [Record] ),
					 etsBaseFunc:deleteRecord(?MODULE:getTeamPlayerTable(), Record)
			 end,
	lists:foreach( MyFunc, Players ).

%%更新队伍玩家地图信息，如果有队，也会更新队伍里的成员地图信息
updateTeamPlayerMapInfo( _TeamID, TeamMemberMapInfo )->
	PlayerID = TeamMemberMapInfo#teamMemberMapInfo.playerID,

	etsBaseFunc:changeFiled( ?MODULE:getTeamPlayerTable(), PlayerID, #teamPlayerInfo.teamMemberMapInfo, TeamMemberMapInfo ),
	
	TeamPlayerInfo = etsBaseFunc:readRecord( getTeamPlayerTable(), PlayerID ),
	TeamID = TeamPlayerInfo#teamPlayerInfo.teamID,
	case TeamID =:= 0 of
		true->ok;
		false->
			TeamInfo = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), TeamID ),
			case TeamInfo of
				{}->ok;
				_->
					MyFunc = fun( Record )->
								case Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerID =:= PlayerID of
									true-> 
										PlayerTeamInfo = etsBaseFunc:readRecord(?MODULE:getTeamPlayerTable(), Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerID),
										#teamMemberInfo{
														isOnline=PlayerTeamInfo#teamPlayerInfo.isOnline,
														joinTime=Record#teamMemberInfo.joinTime,
														teamMemberMapInfo = TeamMemberMapInfo };
									false->Record
								end
							 end,
					MemberList = lists:map( MyFunc, TeamInfo#teamInfo.memberList ),
					
					%?DEBUG_OUT( "updateTeamPlayerMapInfo TeamID[~p] [~p]", [TeamID, MemberList] ),
					
					etsBaseFunc:changeFiled( ?MODULE:getTeamInfoTable(), TeamInfo#teamInfo.teamID, #teamInfo.memberList, MemberList)
			end
	end,
	ok.

%%玩家进入地图，注意，可能玩家是新上线，TeamID指向的队伍不存在
on_mapMsg_PlayerEnterMap( TeamMemberMapInfo )->
	PlayerID = TeamMemberMapInfo#teamMemberMapInfo.playerID,
	TeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), PlayerID ),
	case TeamPlayerInfo of
		{}->%%队伍玩家信息还没有，应该是新上线，新建
			TeamPlayerInfo_New = #teamPlayerInfo{ 
												 playerID = PlayerID,
												 teamID = 0,
												 teamMemberMapInfo = TeamMemberMapInfo,
												 isOnline = 1,
												 offlineTime = 0,
												 inviteTargetList=[]
												},
			etsBaseFunc:insertRecord( ?MODULE:getTeamPlayerTable(), TeamPlayerInfo_New ),
			
			?DEBUG_OUT( "on_mapMsg_PlayerEnterMap TeamMemberMapInfo[~p] new", [TeamMemberMapInfo] ),
			
			ok;
		_->
			case TeamPlayerInfo#teamPlayerInfo.isOnline =:= 0 of
				true->%%上线
					etsBaseFunc:changeFiled( ?MODULE:getTeamPlayerTable(), PlayerID, #teamPlayerInfo.isOnline, 1 ),
					etsBaseFunc:changeFiled( ?MODULE:getTeamPlayerTable(), PlayerID, #teamPlayerInfo.offlineTime, 0 ),
					OldOnline = false;
				false->OldOnline = true
			end,
			
			TeamID = TeamPlayerInfo#teamPlayerInfo.teamID,
			case TeamID =:= 0 of
				true->
					etsBaseFunc:changeFiled( ?MODULE:getTeamPlayerTable(), PlayerID, #teamPlayerInfo.teamMemberMapInfo, TeamMemberMapInfo ),
					?DEBUG_OUT( "on_mapMsg_PlayerEnterMap TeamMemberMapInfo[~p] teamID=0", [TeamMemberMapInfo] ),
					ok;
				false->%%玩家原来就有队
					?DEBUG_OUT(  "on_mapMsg_PlayerEnterMap TeamMemberMapInfo[~p] OldOnline[~p]", [TeamMemberMapInfo, OldOnline]  ),
					updateTeamPlayerMapInfo( TeamID, TeamMemberMapInfo ),
					
					TeamInfo = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), TeamID ),
					case TeamInfo of
						{}->ok;
						_->
							case OldOnline of
								true->ok;
								false->%%原来有队，新上线，发送队伍信息给玩家
									sendTeamInfoToPlayer( TeamInfo, PlayerID )
							end,
							%%发送队伍信息给玩家地图
							sendTeamInfoToMap( TeamInfo, false )
					end
			end
	end,
	ok.

%%玩家退出地图
on_mapMsg_PlayerQuitMap( TeamID, PlayerID )->
	TeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), PlayerID ),
	case TeamPlayerInfo of
		{}->ok;
		_->
			TeamMemberMapInfo = #teamMemberMapInfo{
												   playerID = PlayerID, 
												   playerName = TeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.playerName,
												   level = TeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.level, 
												   camp = TeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.camp, 
												   fation = TeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.fation, 
												   life_percent=TeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.life_percent,
												   sex=TeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.sex,
												   x = 0, 
												   y = 0, 
												   map_data_id = 0, 
												   mapID = 0, 
												   mapPID = 0, 
												   playerPID = TeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.playerPID
												   },
			?DEBUG_OUT( "on_mapMsg_PlayerQuitMap TeamPlayerInfo[~p]", [TeamPlayerInfo] ),
			updateTeamPlayerMapInfo( TeamID, TeamMemberMapInfo )
	end,
	ok.	

%%队伍进程，处理组队邀请,inviteCreateTeam
on_inviteCreateTeam( InvitePlayerID, TargetPlayerID )->
	try
		InviteTeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), InvitePlayerID ),
		case InviteTeamPlayerInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,

		TargetTeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), TargetPlayerID ),
		case TargetTeamPlayerInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		case TargetTeamPlayerInfo#teamPlayerInfo.teamID =:= 0 of
			true->ok;
			false->
				%%目标有队，服务器模拟无队玩家申请加入
				ToMe = #pk_applyJoinTeam{playerID=TargetPlayerID},
				on_applyJoinTeam( InvitePlayerID, ToMe ),
				throw({return})
		end,

		CanInvite = canInviteCreateTeam( InviteTeamPlayerInfo, TargetTeamPlayerInfo, true ),
		case CanInvite =:= ?Team_OP_Result_Succ of
			true->ok;
			false->throw( {return, CanInvite} )
		end,

		insertIntoInviteList( InviteTeamPlayerInfo, TargetPlayerID ),
		
		Msg = #pk_beenInviteCreateTeam{ inviterPlayerID=InvitePlayerID, inviterPlayerName=InviteTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.playerName },
		player:sendToPlayer(TargetPlayerID, Msg),

		?DEBUG_OUT( "on_inviteCreateTeam InvitePlayerID[~p], TargetPlayerID[~p]", [InvitePlayerID, TargetPlayerID] ),
		
		ok
	catch
		{return}->ok;
		{ return, ReturnCode }->
			Msg2 = #pk_teamOPResult{ targetPlayerID=TargetPlayerID, targetPlayerName="", result=ReturnCode },
			player:sendToPlayer(InvitePlayerID, Msg2),
			ok
	end.

%%返回能否两人都无对邀请建立队伍
canInviteCreateTeam( InviteTeamPlayerInfo, TargetTeamPlayerInfo, CheckInviteList )->
	try
		case InviteTeamPlayerInfo#teamPlayerInfo.teamID =:= 0 of
			true->ok;
			false->throw( {return, ?Team_OP_Result_Fail_HasTeamSelf } )
		end,
		case InviteTeamPlayerInfo#teamPlayerInfo.isOnline =:= 1 of
			true->ok;
			false->throw( {return, ?Team_OP_Result_Fail_NotOnline } )
		end,
		
		case TargetTeamPlayerInfo#teamPlayerInfo.teamID =:= 0 of
			true->ok;
			false->throw( {return, ?Team_OP_Result_Fail_HasTeamTarget } )
		end,
		case TargetTeamPlayerInfo#teamPlayerInfo.isOnline =:= 1 of
			true->ok;
			false->throw( {return, ?Team_OP_Result_Fail_NotOnline } )
		end,
		
		%%如果被邀请玩家在战场地图，那么就不能组队	
		TargetPlayerID=TargetTeamPlayerInfo#teamPlayerInfo.playerID,
		TargetInBattleScene=gen_server:call(player:getPlayerPID(TargetPlayerID),{'isinBattleScene'}),
		
		InviterPlayerID=InviteTeamPlayerInfo#teamPlayerInfo.playerID,
		InviterInBattleScene=gen_server:call(player:getPlayerPID(InviterPlayerID),{'isinBattleScene'}),
		
		case TargetInBattleScene=:=true orelse InviterInBattleScene=:=true of
			true->
				throw( {return, ?Team_OP_Result_Fail_NotSameCamp } ),
				%%MyCampus=player:getPlayerProperty(TargetTeamPlayerInfo#teamPlayerInfo.playerID, #player.faction),
				%%如果2个人不同阵营，不让
				%%MemberCampus=player:getPlayerProperty(InviteTeamPlayerInfo#teamPlayerInfo.playerID, #player.faction),
				%%case MemberCampus=/= MyCampus of
				%%	 true->
				%%		 throw( {return, ?Team_OP_Result_Fail_NotSameCamp } );
				%%	false->
				%%		ok
				%%end,
				ok;
			false->
				ok
		end,


		%% check the target whether 关闭组队申请
%% 		case player:getPlayerProperty( TargetTeamPlayerInfo#teamPlayerInfo.playerID, #player.gameSetMenu )  of
%% 			0 ->%% can't find the trade target player
%% 				throw( {return, ?Team_OP_Result_Fail_NotOnline } );
%% 			GameSetMenu->
%% 				case GameSetMenu#pk_GSWithU_GameSetMenu_3.joinTeamOnoff =:= 0 of
%% 					%% 目标玩家关闭了组队申请
%% 					true ->
%% 						throw( {return, ?Team_OP_Result_Fail_TargetCloseJoinTeamFunc });										
%% 					false ->
%% 						ok		
%% 				end
%% 		end,	

		
		case CheckInviteList of
			true->
				Now = common:timestamp(),
				MyFunc = fun( Record )->
								 case Record#teamInviteTargetInfo.playerID =:= TargetTeamPlayerInfo#teamPlayerInfo.playerID of
									 true->
										 case Now < Record#teamInviteTargetInfo.time + ?TeamInviteTime of
											 true->throw( {return, ?Team_OP_Result_Fail_ExistInvite } );
											 false->ok
										 end;
									 false->ok
								 end
						 end,
				lists:foreach( MyFunc, InviteTeamPlayerInfo#teamPlayerInfo.inviteTargetList );
			false->
				Now = common:timestamp(),
				MyFunc = fun( Record )->
								 case Record#teamInviteTargetInfo.playerID =:= TargetTeamPlayerInfo#teamPlayerInfo.playerID of
									 true->
										 case Now < Record#teamInviteTargetInfo.time + ?TeamInviteTime of
											 true->throw( {return, ?Team_OP_Result_Succ } );
											 false->ok
										 end;
									 false->ok
								 end
						 end,
				lists:foreach( MyFunc, InviteTeamPlayerInfo#teamPlayerInfo.inviteTargetList ),
				throw( {return, ?Team_OP_Result_Fail_InviteTimeOut } )
		end,

		?Team_OP_Result_Succ
	catch
		{ return, ReturnValue }->ReturnValue
	end.

%%队伍进程，插入邀请列表
insertIntoInviteList( InviteTeamPlayerInfo, TargetPlayerID )->
	put( "insertIntoInviteList_find", false ),
	Now = common:timestamp(),
	MyFunc = fun( Record )->
					 case Record#teamInviteTargetInfo.playerID =:= TargetPlayerID of
						 true->put( "insertIntoInviteList_find", true ), setelement( #teamInviteTargetInfo.time, Record, Now );
						 false->Record
					 end
			 end,
	InviteTargetList = lists:map( MyFunc, InviteTeamPlayerInfo#teamPlayerInfo.inviteTargetList ),
	case get("insertIntoInviteList_find") of
		true->etsBaseFunc:changeFiled(?MODULE:getTeamPlayerTable(), InviteTeamPlayerInfo#teamPlayerInfo.playerID, #teamPlayerInfo.inviteTargetList, InviteTargetList);
		false->
			InviteTargetList2 = InviteTeamPlayerInfo#teamPlayerInfo.inviteTargetList ++ [#teamInviteTargetInfo{playerID=TargetPlayerID, time=Now}],
			etsBaseFunc:changeFiled(?MODULE:getTeamPlayerTable(), InviteTeamPlayerInfo#teamPlayerInfo.playerID, #teamPlayerInfo.inviteTargetList, InviteTargetList2)
	end,
	InviteListInfo = etsBaseFunc:readRecord( ?MODULE:getInviteListTable(), TargetPlayerID ),
	case InviteListInfo of
		{}->
			InviteListTable = #inviteList{playerID = TargetPlayerID, inviteID = InviteTeamPlayerInfo#teamPlayerInfo.playerID},
			etsBaseFunc:insertRecord(?MODULE:getInviteListTable(), InviteListTable);
		_-> ok
	end.

%%队伍进程，删除邀请列表
removeInviteList( InviteTeamPlayerInfo, TargetPlayerID )->
	put( "removeInviteList_find", {} ),
	MyFunc = fun( Record )->
					 case Record#teamInviteTargetInfo.playerID =:= TargetPlayerID of
						 true->put( "removeInviteList_find", Record );
						 false->ok
					 end
			 end,
	lists:foreach( MyFunc, InviteTeamPlayerInfo#teamPlayerInfo.inviteTargetList ),
	case get("removeInviteList_find") of
		{}->ok;
		Find->
			InviteTargetList2 = InviteTeamPlayerInfo#teamPlayerInfo.inviteTargetList -- [Find],
			etsBaseFunc:changeFiled(?MODULE:getTeamPlayerTable(), InviteTeamPlayerInfo#teamPlayerInfo.playerID, #teamPlayerInfo.inviteTargetList, InviteTargetList2)
	end.


%%队伍进程，处理回复，邀请组队结果
on_ackInviteCreateTeam( AckPlayerID, #pk_ackInviteCreateTeam{inviterPlayerID=InviterPlayerID, agree=Agree}=_Msg )->
	try
		InviteTeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), InviterPlayerID ),
		case InviteTeamPlayerInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		TargetTeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), AckPlayerID ),
		case TargetTeamPlayerInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,

		CanInvite = canInviteCreateTeam( InviteTeamPlayerInfo, TargetTeamPlayerInfo, false ),
		
		removeInviteList( InviteTeamPlayerInfo, AckPlayerID ),

		case CanInvite =:= ?Team_OP_Result_Succ of
			true->ok;
			false->throw( {return, CanInvite} )
		end,
		%%清除邀请列表
		deleteRecordFormInvite(InviterPlayerID),
		
		case Agree =:= 0 of
			true->%%拒绝
				?DEBUG_OUT( "on_ackInviteCreateTeam InviterPlayerID[~p] AckPlayerID[~p] refuse", [InviterPlayerID, AckPlayerID] ),
				MsgToTarget = #pk_teamOPResult{ targetPlayerID=AckPlayerID, targetPlayerName=InviteTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.playerName, result=?Team_OP_Result_Fail_RefuseCreate },
				player:sendToPlayer(InviterPlayerID, MsgToTarget);
			false->%%接受，建队
				Now = common:timestamp(),
				
				%%建队伍ID
				TeamID = map:makeObjectID( ?Object_Type_Team, db:memKeyIndex(teamInfo) ), % not persistent
				%%建队伍成员信息
				TeamMemberInfo_Target = #teamMemberInfo{isOnline = 1, joinTime=Now, teamMemberMapInfo=InviteTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo },
				%%建队伍成员信息
				TeamMemberInfo_Ack = #teamMemberInfo{isOnline = 1, joinTime=Now, teamMemberMapInfo=TargetTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo },
				%%建队伍信息
				TeamInfo = #teamInfo{
									 teamID = TeamID, 
									 leaderPlayerID = InviterPlayerID, 
									 memberList=[TeamMemberInfo_Target, TeamMemberInfo_Ack]
									 },
				%%插入队伍表
				etsBaseFunc:insertRecord(?MODULE:getTeamInfoTable(), TeamInfo),
				
				%%修改队伍玩家记录中的队伍ID
				etsBaseFunc:changeFiled( ?MODULE:getTeamPlayerTable(), InviterPlayerID, #teamPlayerInfo.teamID, TeamID ),
				%%发送队伍信息给玩家客户端
				sendTeamInfoToPlayer( TeamInfo, InviterPlayerID ),
				
				%%修改队伍玩家记录中的队伍ID
				etsBaseFunc:changeFiled( ?MODULE:getTeamPlayerTable(), AckPlayerID, #teamPlayerInfo.teamID, TeamID ),
				%%发送队伍信息给玩家客户端
				sendTeamInfoToPlayer( TeamInfo, AckPlayerID ),
				
				%%发送队伍信息给玩家所在地图
				TeamInfo2 = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), TeamID ),
				sendTeamInfoToMap( TeamInfo2, false ),
				
				%%定时发送玩家简略信息
				erlang:send_after(?TeamUpdateShortInfo,self(), {updateTeamMemberShortInfo, TeamID} ),
				
				mapManagerPID ! { teamMsg_Created, TeamID, InviterPlayerID },
				mapManagerPID ! { teamMsg_Join, TeamID, AckPlayerID },
				
				?DEBUG_OUT( "create team[~p]", [TeamInfo2] )
		end,
		
		ok
	catch
		{return, ReturnValue }->
			Msg = #pk_teamOPResult{ targetPlayerID=InviterPlayerID, targetPlayerName="", result=ReturnValue },
			player:sendToPlayer(AckPlayerID, Msg),
			ok
	end.

%%发送队伍信息给某玩家
sendTeamInfoToPlayer( TeamInfo, PlayerID )->
	MyFunc = fun( Record )->
				#pk_teamMemberInfo{ 
									playerID=Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerID,
									playerName=Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerName,
									level=Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.level,
									camp=Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.camp,
									sex=Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.sex,
									posx=Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.x,
									posy=Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.y,
									map_data_id=Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.map_data_id,
									isOnline=Record#teamMemberInfo.isOnline,
								  	life_percent=Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.life_percent
									}
			 end,
	MsgMemberInfo = lists:map( MyFunc, TeamInfo#teamInfo.memberList ),

	Msg = #pk_teamInfo{ teamID=TeamInfo#teamInfo.teamID,
						leaderPlayerID = TeamInfo#teamInfo.leaderPlayerID,
						info_list = MsgMemberInfo
						},
	player:sendToPlayer( PlayerID, Msg ).


%%发送队伍信息给队伍所有玩家所在地图
sendTeamInfoToMap( TeamInfo, ClearOrUpdate )->
	case ClearOrUpdate of
		true->
			TeamData = #teamData{teamID = 0,
								leaderID = 0,
								membersID = [] };
		false->
			MyFunc2 = fun( Record )->
							  Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerID
					  end,
			MemberIDList = lists:map(MyFunc2, TeamInfo#teamInfo.memberList),
			TeamData = #teamData{teamID = TeamInfo#teamInfo.teamID,
								leaderID = TeamInfo#teamInfo.leaderPlayerID,
								membersID = MemberIDList }
	end,

	MyFunc = fun( Record )->
					 TeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), 
															  Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerID ),
					 case TeamPlayerInfo of
						 {}->ok;
						 _->
							 MapPID = TeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.mapPID,
							 case MapPID =:= 0 of
								true->ok;
								false->
									MapPID ! {teamMsg_TeamMemberUPdata, 
											Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerID,
											TeamData
											}
							 end
					 end
			 end,
	lists:foreach(MyFunc, TeamInfo#teamInfo.memberList),
	ok.				 


%%发送某消息给队伍中所有玩家
sendMsgToAllMember( TeamInfo, Msg )->
	MyFunc = fun( Record )->
					 case Record#teamMemberInfo.isOnline =:= 0 of
						 true->ok;
						 false->player:sendToPlayer(Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerID, Msg)
					 end
			 end,
	lists:foreach( MyFunc, TeamInfo#teamInfo.memberList ).

%%发送某消息给队伍中所有玩家
sendMsgToAllMemberByTeamID( TeamID, Msg )->
	case etsBaseFunc:readRecord(getTeamInfoTable(), TeamID) of
		{}->ok;
		TeamInfo->
			sendMsgToAllMember(TeamInfo, Msg)
	end.
	
%%发送队伍玩家坐标、等级、在线情况定时更新
sendTeamMemberShortInfo( TeamInfo )->
	MyFunc = fun( Record )->
				Data = #pk_shortTeamMemberInfo{ 
									playerID=Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerID,
									level=Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.level,
									posx=Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.x,
									posy=Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.y,
									map_data_id=Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.map_data_id,
									life_percent=Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.life_percent,
									isOnline=Record#teamMemberInfo.isOnline
									},
				%%?DEBUG_OUT( "Data [~p]",[Data] ),
				Data
			 end,
	ShortTeamMemberInfo = lists:map( MyFunc, TeamInfo#teamInfo.memberList ),
	Msg = #pk_updateTeamMemberInfo{ info_list=ShortTeamMemberInfo },
	sendMsgToAllMember( TeamInfo, Msg ).
	
%%定时更新队伍成员简单信息
on_updateTeamMemberShortInfo( TeamID )->
	TeamInfo = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), TeamID ),
	case TeamInfo of
		{}->ok;
		_->
			erlang:send_after(?TeamUpdateShortInfo,self(), {updateTeamMemberShortInfo, TeamID} ),
			sendTeamMemberShortInfo( TeamInfo )
	end.

%%定时检测队伍邀请列表
on_updateInviteListTimer()->
	Now = common:timestamp(),
	
	erlang:send_after( ?TeamUpdateInviteList,self(), {updateInviteListTimer} ),
	
	MyFunc = fun( Record )->
					 case Record#teamPlayerInfo.inviteTargetList of
						 []->ok;
						 _->
							 put( "on_updateInviteListTimer_find", false ),
							 MyFunc2 = fun( Record2 )->
											   case Now < Record2#teamInviteTargetInfo.time + ?TeamInviteTime of
												   true->Record2;
												   false->put("on_updateInviteListTimer_find", true), {}
											   end
									   end,
					 		NewList = lists:map( MyFunc2, Record#teamPlayerInfo.inviteTargetList ),
							case get( "on_updateInviteListTimer_find" ) of
								true->
									MyFunc3 = fun( Record )->
													  Record =/= {}
											  end,
									NewList2 = lists:filter(MyFunc3, NewList),
									etsBaseFunc:changeFiled(?MODULE:getTeamPlayerTable(), Record#teamPlayerInfo.playerID, #teamPlayerInfo.inviteTargetList, NewList2);
								false->ok
							end
					 end
			 end,
	etsBaseFunc:etsFor(?MODULE:getTeamPlayerTable(), MyFunc).

%%队长邀请玩家入队，inviteJoinTeam
on_inviteJoinTeam( TeamLeaderID, #pk_inviteJoinTeam{playerID=TargetPlayerID}=_Msg )->
	try
		InviteTeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), TeamLeaderID ),
		case InviteTeamPlayerInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,

		TargetTeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), TargetPlayerID ),
		case TargetTeamPlayerInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		CanInvite = canInviteJoinTeam( InviteTeamPlayerInfo, TargetTeamPlayerInfo, true ),
		case CanInvite =:= ?Team_OP_Result_Succ of
			true->ok;
			false->throw( {return, CanInvite} )
		end,

		insertIntoInviteList( InviteTeamPlayerInfo, TargetPlayerID ),
		
		Msg = #pk_beenInviteJoinTeam{ playerID=TeamLeaderID, playerName=InviteTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.playerName },
		player:sendToPlayer(TargetPlayerID, Msg),

		?DEBUG_OUT( "on_inviteJoinTeam InvitePlayerID[~p], TargetPlayerID[~p]", [TeamLeaderID, TargetPlayerID] ),
		
		ok
	catch
		{return, ReturnCode}->
			Msg2 = #pk_teamOPResult{ targetPlayerID=TargetPlayerID, targetPlayerName="", result=ReturnCode },
			player:sendToPlayer(TeamLeaderID, Msg2),
			ok			
	end.

%%返回能否队长邀请玩家入队
canInviteJoinTeam( InviteTeamPlayerInfo, TargetTeamPlayerInfo, CheckInviteList )->
	try
		case InviteTeamPlayerInfo#teamPlayerInfo.teamID =:= 0 of
			true->TeamInfo = {}, throw( {return, ?Team_OP_Result_Fail_NeedTeamLeader } );
			false->
				TeamInfo = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), InviteTeamPlayerInfo#teamPlayerInfo.teamID ),
				case TeamInfo of
					{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall } );
					_->ok
				end
		end,
		case InviteTeamPlayerInfo#teamPlayerInfo.isOnline =:= 1 of
			true->ok;
			false->throw( {return, ?Team_OP_Result_Fail_NotOnline } )
		end,
		
		case TargetTeamPlayerInfo#teamPlayerInfo.teamID =:= 0 of
			true->ok;
			false->throw( {return, ?Team_OP_Result_Fail_HasTeamTarget } )
		end,
		case TargetTeamPlayerInfo#teamPlayerInfo.isOnline =:= 1 of
			true->ok;
			false->throw( {return, ?Team_OP_Result_Fail_NotOnline } )
		end,
		
		case TeamInfo#teamInfo.leaderPlayerID =:= InviteTeamPlayerInfo#teamPlayerInfo.playerID of
			true->ok;
			false->throw( {return, ?Team_OP_Result_Fail_NeedTeamLeader } )
		end,
		
		TemMemberSize = length( TeamInfo#teamInfo.memberList ),
		case TemMemberSize >= ?TeamMember_MaxCount of
			true->throw( {return, ?Team_OP_Result_Fail_FullMember } );
			false->ok
		end,
	
		%%如果被邀请玩家在战场地图，那么不能组队
		TargetPlayerID=TargetTeamPlayerInfo#teamPlayerInfo.playerID,
		TargetInBattleScene=gen_server:call(player:getPlayerPID(TargetPlayerID),{'isinBattleScene'}),
		case TargetInBattleScene of
			true->
				throw( {return, ?Team_OP_Result_Fail_NotSameCamp } ),
				%%MyCampus=player:getPlayerProperty(TargetTeamPlayerInfo#teamPlayerInfo.playerID, #player.faction),
				%%如果队伍中有其他阵营的，不让
				%%MyFunc2 = fun( Record )->
				%%				 MemberCampus=player:getPlayerProperty(Record#teamPlayerInfo.playerID, #player.faction),
				%%				 case MemberCampus=/= MyCampus of
				%%					 true->
				%%						 throw( {return, ?Team_OP_Result_Fail_NotSameCamp } );
				%%					false->
				%%						ok
				%%				end
				%%			 end,
				%%
				%%lists:foreach( MyFunc2, TeamInfo#teamInfo.memberList ),
				ok;
			false->
				ok
		end,
		
		case CheckInviteList of
			true->
				Now = common:timestamp(),
				MyFunc = fun( Record )->
								 case Record#teamInviteTargetInfo.playerID =:= TargetTeamPlayerInfo#teamPlayerInfo.playerID of
									 true->
										 case Now < Record#teamInviteTargetInfo.time + ?TeamInviteTime of
											 true->throw( {return, ?Team_OP_Result_Fail_ExistInvite } );
											 false->ok
										 end;
									 false->ok
								 end
						 end,
				lists:foreach( MyFunc, InviteTeamPlayerInfo#teamPlayerInfo.inviteTargetList );
			false->
				Now = common:timestamp(),
				MyFunc = fun( Record )->
								 case Record#teamInviteTargetInfo.playerID =:= TargetTeamPlayerInfo#teamPlayerInfo.playerID of
									 true->
										 case Now < Record#teamInviteTargetInfo.time + ?TeamInviteTime of
											 true->throw( {return, ?Team_OP_Result_Succ } );
											 false->ok
										 end;
									 false->ok
								 end
						 end,
				lists:foreach( MyFunc, InviteTeamPlayerInfo#teamPlayerInfo.inviteTargetList ),
				throw( {return, ?Team_OP_Result_Succ } )
		end,

		?Team_OP_Result_Succ
	catch
		{ return, ReturnValue }->ReturnValue
	end.

%%回复，邀请入队接受还是拒绝，ackInviteJointTeam
on_ackInviteJointTeam( AckPlayerID, #pk_ackInviteJointTeam{playerID=InvitePlayerID, agree=Agree}=_Msg )->
	try
		InviteTeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), InvitePlayerID ),
		case InviteTeamPlayerInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		TargetTeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), AckPlayerID ),
		case TargetTeamPlayerInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		CanInvite = canInviteJoinTeam( InviteTeamPlayerInfo, TargetTeamPlayerInfo, false ),
		?MODULE:removeInviteList(InviteTeamPlayerInfo, AckPlayerID),

		case CanInvite =:= ?Team_OP_Result_Succ of
			true->ok;
			false->throw( {return, CanInvite} )
		end,

		case Agree =:= 0 of
			true->%%拒绝
				?DEBUG_OUT( "on_ackInviteJointTeam InvitePlayerID[~p] AckPlayerID[~p] refuse", [InvitePlayerID, AckPlayerID] ),
				Msg2 = #pk_teamOPResult{ targetPlayerID=AckPlayerID, targetPlayerName=TargetTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.playerName, result=?Team_OP_Result_Fail_RefuseCreate },
				player:sendToPlayer(InvitePlayerID, Msg2);
			false->
				TeamInfo = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), InviteTeamPlayerInfo#teamPlayerInfo.teamID ),
				Now = common:timestamp(),
				
				%%新队员设置队伍ID
				etsBaseFunc:changeFiled( ?MODULE:getTeamPlayerTable(), AckPlayerID, #teamPlayerInfo.teamID, InviteTeamPlayerInfo#teamPlayerInfo.teamID ),
				%%新成员加入
				TeamMemberInfo = #teamMemberInfo{isOnline=1, joinTime=Now, teamMemberMapInfo=TargetTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo },
				New_MemberList = TeamInfo#teamInfo.memberList ++ [TeamMemberInfo],
				etsBaseFunc:changeFiled( ?MODULE:getTeamInfoTable(), InviteTeamPlayerInfo#teamPlayerInfo.teamID, #teamInfo.memberList, New_MemberList ),
				
				MsgAddMember = #pk_addTeamMember{
												 info = #pk_teamMemberInfo{
																		   playerID=AckPlayerID,
																		   playerName=TargetTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.playerName,
																		   level=TargetTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.level,
																		   posx=TargetTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.x,
																		   posy=TargetTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.y,
																		   map_data_id=TargetTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.map_data_id,
																		   sex=TargetTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.sex,
																		   isOnline=1,
																		   life_percent=TargetTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.life_percent,
																		   camp=TargetTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.camp
																		   }
												 },
				%%通知有新玩家入队
				?MODULE:sendMsgToAllMember(TeamInfo, MsgAddMember),
				
				%%发送队伍信息给玩家所在地图
				TeamInfo2 = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), InviteTeamPlayerInfo#teamPlayerInfo.teamID ),
				sendTeamInfoToMap( TeamInfo2, false ),
				
				%%通知新玩家，队伍信息
				?MODULE:sendTeamInfoToPlayer(TeamInfo2, AckPlayerID ),
				
				mapManagerPID ! { teamMsg_Join, TeamInfo#teamInfo.teamID, AckPlayerID },
				
				?DEBUG_OUT( "on_ackInviteJointTeam InvitePlayerID[~p] AckPlayerID[~p] join team[~p]", [InvitePlayerID, AckPlayerID, TeamInfo2] )
		end,

		ok
	catch
		{return, ReturnCode}->
			Msg = #pk_teamOPResult{ targetPlayerID=InvitePlayerID, targetPlayerName="", result=ReturnCode },
			player:sendToPlayer(AckPlayerID, Msg),
			ok			
	end.

%%无队玩家申请入队applyJoinTeam
on_applyJoinTeam( ApplyPlayerID, #pk_applyJoinTeam{playerID=TeamLeaderID}=_Msg )->
	try
		TeamLeaderPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), TeamLeaderID ),
		case TeamLeaderPlayerInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,

		ApplyTeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), ApplyPlayerID ),
		case ApplyTeamPlayerInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		CanInvite = canApplyJoinTeam( ApplyTeamPlayerInfo, TeamLeaderPlayerInfo, true ),
		case CanInvite =:= ?Team_OP_Result_Succ of
			true->ok;
			false->throw( {return, CanInvite} )
		end,

		insertIntoInviteList( ApplyTeamPlayerInfo, TeamLeaderID ),
		
		Msg2 = #pk_queryApplyJoinTeam{ playerID=ApplyPlayerID, playerName=ApplyTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.playerName },
		player:sendToPlayer(TeamLeaderID, Msg2),

		?DEBUG_OUT( "on_applyJoinTeam ApplyPlayerID[~p], TeamLeaderID[~p]", [ApplyPlayerID, TeamLeaderID] ),
		
		ok
	catch
		{return, ReturnCode}->
			Msg = #pk_teamOPResult{ targetPlayerID=TeamLeaderID, targetPlayerName="", result=ReturnCode },
			player:sendToPlayer(ApplyPlayerID, Msg),
			ok			
	end.

%%返回能否申请加入队伍
canApplyJoinTeam( ApplyTeamPlayerInfo, TeamLeaderPlayerInfo, CheckInviteList )->
	try
		case TeamLeaderPlayerInfo#teamPlayerInfo.teamID =:= 0 of
			true->TeamInfo = {}, throw( {return, ?Team_OP_Result_Fail_NeedTeamLeader } );
			false->
				TeamInfo = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), TeamLeaderPlayerInfo#teamPlayerInfo.teamID ),
				case TeamInfo of
					{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall } );
					_->ok
				end
		end,
		case TeamLeaderPlayerInfo#teamPlayerInfo.isOnline =:= 1 of
			true->ok;
			false->throw( {return, ?Team_OP_Result_Fail_NotOnline } )
		end,
		
		case ApplyTeamPlayerInfo#teamPlayerInfo.teamID =:= 0 of
			true->ok;
			false->throw( {return, ?Team_OP_Result_Fail_HasTeamTarget } )
		end,
		case ApplyTeamPlayerInfo#teamPlayerInfo.isOnline =:= 1 of
			true->ok;
			false->throw( {return, ?Team_OP_Result_Fail_NotOnline } )
		end,
		
		case TeamInfo#teamInfo.leaderPlayerID =:= TeamLeaderPlayerInfo#teamPlayerInfo.playerID of
			true->ok;
			false->throw( {return, ?Team_OP_Result_Fail_TargetIsNotLeader } )
		end,
		
		TemMemberSize = length( TeamInfo#teamInfo.memberList ),
		case TemMemberSize >= ?TeamMember_MaxCount of
			true->throw( {return, ?Team_OP_Result_Fail_FullMember } );
			false->ok
		end,
		
		%%如果被邀请玩家在战场地图
		ApplyerPlayerID=ApplyTeamPlayerInfo#teamPlayerInfo.playerID,
		ApplyerInBattleScene=gen_server:call(player:getPlayerPID(ApplyerPlayerID),{'isinBattleScene'}),
		case ApplyerInBattleScene of
			true->
				throw( {return, ?Team_OP_Result_Fail_NotSameCamp } ),
				%%MyCampus=player:getPlayerProperty(ApplyTeamPlayerInfo#teamPlayerInfo.playerID, #player.faction),
				%%如果队伍中有其他阵营的，不让
				%%MyFunc2 = fun( Record )->
				%%				 MemberCampus=player:getPlayerProperty(Record#teamPlayerInfo.playerID, #player.faction),
				%%				 case MemberCampus=/= MyCampus of
				%%					 true->
				%%						 throw( {return, ?Team_OP_Result_Fail_NotSameCamp } );
				%%					false->
				%%						ok
				%%				end
				%%			 end,
				%%lists:foreach( MyFunc2, TeamInfo#teamInfo.memberList ),
				ok;
			false->
				ok
		end,
		
		case CheckInviteList of
			true->
				Now = common:timestamp(),
				MyFunc = fun( Record )->
								 case Record#teamInviteTargetInfo.playerID =:= TeamLeaderPlayerInfo#teamPlayerInfo.playerID of
									 true->
										 case Now < Record#teamInviteTargetInfo.time + ?TeamInviteTime of
											 true->throw( {return, ?Team_OP_Result_Fail_ExistInvite } );
											 false->ok
										 end;
								 	false->ok
								 end
						 end,
				lists:foreach( MyFunc, ApplyTeamPlayerInfo#teamPlayerInfo.inviteTargetList );
			false->
				Now = common:timestamp(),
				MyFunc = fun( Record )->
								 case Record#teamInviteTargetInfo.playerID =:= TeamLeaderPlayerInfo#teamPlayerInfo.playerID of
									 true->
										 case Now < Record#teamInviteTargetInfo.time + ?TeamInviteTime of
											 true->throw( {return, ?Team_OP_Result_Succ } );
											 false->ok
										 end;
									 false->ok
								 end
						 end,
				lists:foreach( MyFunc, ApplyTeamPlayerInfo#teamPlayerInfo.inviteTargetList ),
				throw( {return, ?Team_OP_Result_Succ } )
		end,

		?Team_OP_Result_Succ
	catch
		{ return, ReturnValue }->ReturnValue
	end.

%%回复，邀请入队接受还是拒绝，ackInviteJointTeam
on_ackQueryApplyJoinTeam( TeamLeaderID, #pk_ackQueryApplyJoinTeam{playerID=ApplyPlayerID, agree=Agree}=_Msg )->
	try
		TeamLeaderPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), TeamLeaderID ),
		case TeamLeaderPlayerInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,

		ApplyTeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), ApplyPlayerID ),
		case ApplyTeamPlayerInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		CanInvite = canApplyJoinTeam( ApplyTeamPlayerInfo, TeamLeaderPlayerInfo, false ),
		?MODULE:removeInviteList(ApplyTeamPlayerInfo, TeamLeaderID),
		
 		case CanInvite =:= ?Team_OP_Result_Succ of
			true->ok;
			false->throw( {return, CanInvite} )
		end,

		case Agree =:= 0 of
			true->%%拒绝
				?DEBUG_OUT( "on_ackQueryApplyJoinTeam ApplyPlayerID[~p] TeamLeaderID[~p] refuse", [ApplyPlayerID, TeamLeaderID] ),
				Msg2 = #pk_teamOPResult{ targetPlayerID=TeamLeaderID, targetPlayerName=TeamLeaderPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.playerName, result=?Team_OP_Result_Fail_RefuseCreate },
				player:sendToPlayer(ApplyPlayerID, Msg2);
			false->
				TeamInfo = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), TeamLeaderPlayerInfo#teamPlayerInfo.teamID ),
				Now = common:timestamp(),

				%%新队员设置队伍ID
				etsBaseFunc:changeFiled( ?MODULE:getTeamPlayerTable(), ApplyPlayerID, #teamPlayerInfo.teamID, TeamLeaderPlayerInfo#teamPlayerInfo.teamID ),
				%%新成员加入
				TeamMemberInfo = #teamMemberInfo{isOnline=1, joinTime=Now, teamMemberMapInfo=ApplyTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo },
				New_MemberList = TeamInfo#teamInfo.memberList ++ [TeamMemberInfo],
				etsBaseFunc:changeFiled( ?MODULE:getTeamInfoTable(), TeamLeaderPlayerInfo#teamPlayerInfo.teamID, #teamInfo.memberList, New_MemberList ),
				
				MsgAddMember = #pk_addTeamMember{
												 info = #pk_teamMemberInfo{
																		   playerID=ApplyPlayerID,
																		   playerName=ApplyTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.playerName,
																		   level=ApplyTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.level,
																		   posx=ApplyTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.x,
																		   posy=ApplyTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.y,
																		   map_data_id=ApplyTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.map_data_id,
																		   isOnline=1,
																		   life_percent=ApplyTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.life_percent,
																		   camp=ApplyTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.camp,
																		   sex=ApplyTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.sex
																		   }
												 },
				%%通知有新玩家入队
				?MODULE:sendMsgToAllMember(TeamInfo, MsgAddMember),
				
				%%发送队伍信息给玩家所在地图
				TeamInfo2 = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), TeamLeaderPlayerInfo#teamPlayerInfo.teamID ),
				sendTeamInfoToMap( TeamInfo2, false ),
				
				%%通知新玩家，队伍信息
				?MODULE:sendTeamInfoToPlayer(TeamInfo2, ApplyPlayerID ),
				
				mapManagerPID ! { teamMsg_Join, TeamInfo#teamInfo.teamID, ApplyPlayerID },
				
				?DEBUG_OUT( "on_ackQueryApplyJoinTeam TeamLeaderID[~p] ApplyPlayerID[~p] join team[~p]", [TeamLeaderID, ApplyPlayerID, TeamInfo2] )
		end,

		ok
	catch
		{return, ReturnCode}->
			Msg = #pk_teamOPResult{ targetPlayerID=ApplyPlayerID, targetPlayerName="", result=ReturnCode },
			player:sendToPlayer(TeamLeaderID, Msg),
			ok			
	end.

%%队伍解散
disbandTeam( TeamInfo )->
	sendTeamInfoToMap( TeamInfo, true ),
	MyFunc = fun( Record )->
					 PlayerID = Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerID,
					etsBaseFunc:changeFiled( ?MODULE:getTeamPlayerTable(), 
												PlayerID, 
												#teamPlayerInfo.teamID, 0 ),
					ToUser = #pk_teamDisbanded{reserve=0},
					player:sendToPlayer(PlayerID, ToUser)
			 end,
	lists:foreach(MyFunc, TeamInfo#teamInfo.memberList ),
	
	etsBaseFunc:deleteRecord( ?MODULE:getTeamInfoTable(), TeamInfo#teamInfo.teamID ),
	
	mapManagerPID ! { teamMsg_Disband, TeamInfo#teamInfo.teamID, TeamInfo#teamInfo.leaderPlayerID },

	?DEBUG_OUT( "disbandTeam TeamInfo[~p]", [TeamInfo] ),
	
	ok.

%%请求离队
on_teamQuitRequest( PlayerID, _Msg )->
	try
		TeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), PlayerID ),
		case TeamPlayerInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		case TeamPlayerInfo#teamPlayerInfo.teamID =:= 0 of
			true->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			false->ok
		end,
		
		TeamInfo = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), TeamPlayerInfo#teamPlayerInfo.teamID ),
		case TeamInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		put( "on_teamQuitRequest_find", {} ),
		MyFunc = fun( Record )->
						 case Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerID =:= PlayerID of
							 true->put( "on_teamQuitRequest_find", Record );
							 false->ok
						 end
				 end,
		lists:foreach( MyFunc, TeamInfo#teamInfo.memberList ),
		
		Find = get( "on_teamQuitRequest_find" ),
		case Find of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		case TeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.mapPID =:= 0 of
			true->ok;
			false->
				TeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.mapPID ! {teamMsg_TeamMemberUPdata, 
													PlayerID,
													#teamData{teamID = 0,
																leaderID = 0,
																membersID = [] }
													},
				
				TeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.mapPID ! { teamMsg_KickOut, TeamPlayerInfo#teamPlayerInfo.teamID, PlayerID }
		end,
		
		MemberSize = length( TeamInfo#teamInfo.memberList ),
		case MemberSize =< 2 of
			true->
				disbandTeam( TeamInfo ),
				throw( {return} );
			false->ok
		end,
		
		ToUser = #pk_teamPlayerQuit{ playerID=PlayerID },
		?MODULE:sendMsgToAllMember(TeamInfo, ToUser ),
		
		NewList = TeamInfo#teamInfo.memberList -- [Find],
		etsBaseFunc:changeFiled( ?MODULE:getTeamInfoTable(), 
								 TeamPlayerInfo#teamPlayerInfo.teamID, 
								 #teamInfo.memberList, 
								 NewList ),
		
		etsBaseFunc:changeFiled( ?MODULE:getTeamPlayerTable(), 
								 PlayerID, 
								 #teamPlayerInfo.teamID, 
								 0 ),
		
		TeamInfo2 = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), TeamPlayerInfo#teamPlayerInfo.teamID ),
		sendTeamInfoToMap( TeamInfo2, false ),
		
		?DEBUG_OUT( "player[~p] quited team[~p]", [PlayerID, TeamPlayerInfo#teamPlayerInfo.teamID] ),

		case TeamInfo2#teamInfo.leaderPlayerID =:= PlayerID of
			true->%%队长离开，移交队长
				put( "on_teamQuitRequest_find", 0 ),
				put( "on_teamQuitRequest_time", 0 ),
				MyFunc2 = fun( Record )->
								 case Record#teamMemberInfo.isOnline =:= 0 of
									 true->ok;
									 false->
										 case get( "on_teamQuitRequest_find" ) =:= 0 of
											 true->
												 put( "on_teamQuitRequest_find", Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerID ),
												 put( "on_teamQuitRequest_time", Record#teamMemberInfo.joinTime );
											 false->
												 case Record#teamMemberInfo.joinTime < get( "on_teamQuitRequest_time" ) of
													 true->
														 put( "on_teamQuitRequest_find", Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerID ),
														 put( "on_teamQuitRequest_time", Record#teamMemberInfo.joinTime );
													 false->ok
												 end
										 end
								 end
						 end,
				lists:foreach(MyFunc2, TeamInfo2#teamInfo.memberList ),
				FindNewPlayerID = get( "on_teamQuitRequest_find" ),
				case FindNewPlayerID =:= 0 of
					true->%%没有找到一个在线的队员，解散
						disbandTeam( TeamInfo2 ),
						throw( {return} ),
						ok;
					false->
						%%修改队长
						etsBaseFunc:changeFiled( ?MODULE:getTeamInfoTable(), 
												 TeamInfo2#teamInfo.teamID, 
												 #teamInfo.leaderPlayerID, 
												 FindNewPlayerID ),
						%%通知地图
						TeamInfo3 = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), TeamInfo2#teamInfo.teamID ),
						?MODULE:sendTeamInfoToMap(TeamInfo3, false),
						%%通知玩家
						MsgToUser = #pk_teamChangeLeader{ playerID=FindNewPlayerID },
						?MODULE:sendMsgToAllMember(TeamInfo3, MsgToUser),
						
						?DEBUG_OUT( "PlayerID[~p] quit team to change team leader [~p]",
									[PlayerID, FindNewPlayerID] ),
						ok
				end,
				ok;
			 false->ok
		end,

		ok
	catch
		{return}->ok;
		{return, ReturnCode }->
			Msg2 = #pk_teamOPResult{ targetPlayerID=PlayerID, targetPlayerName="", result=ReturnCode },
			player:sendToPlayer(PlayerID, Msg2),
			ok			
	end.

%%队长踢人请求
on_teamKickOutPlayer( PlayerID, #pk_teamKickOutPlayer{playerID=TargetPlayerID} = _Msg )->
	try
		TeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), PlayerID ),
		case TeamPlayerInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		case TeamPlayerInfo#teamPlayerInfo.teamID =:= 0 of
			true->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			false->ok
		end,
		
		TeamInfo = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), TeamPlayerInfo#teamPlayerInfo.teamID ),
		case TeamInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		case TeamInfo#teamInfo.leaderPlayerID =:= PlayerID of
			true->ok;
			false->throw( {return, ?Team_OP_Result_Fail_NeedTeamLeader} )
		end,
		
		TargetTeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), TargetPlayerID ),
		case TargetTeamPlayerInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,

		put( "on_teamKickOutPlayer_find", {} ),
		MyFunc = fun( Record )->
						 case Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerID =:= TargetPlayerID of
							 true->put( "on_teamKickOutPlayer_find", Record );
							 false->ok
						 end
				 end,
		lists:foreach( MyFunc, TeamInfo#teamInfo.memberList ),
		
		Find = get( "on_teamKickOutPlayer_find" ),
		case Find of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		case TargetTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.mapPID =:= 0 of
			true->ok;
			false->
				%%被踢玩家要单独通知地图
				TargetTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.mapPID ! {teamMsg_TeamMemberUPdata, 
													TargetPlayerID,
													#teamData{teamID = 0,
																leaderID = 0,
																membersID = [] }
													},
				
				TargetTeamPlayerInfo#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.mapPID ! { teamMsg_KickOut, TeamPlayerInfo#teamPlayerInfo.teamID, TargetPlayerID }
		end,
		
		MemberSize = length( TeamInfo#teamInfo.memberList ),
		case MemberSize =< 2 of
			true->
				disbandTeam( TeamInfo ),
				throw( {return} );
			false->ok
		end,
		
		ToUser = #pk_teamPlayerKickOut{ playerID=TargetPlayerID },
		?MODULE:sendMsgToAllMember(TeamInfo, ToUser ),
		
		NewList = TeamInfo#teamInfo.memberList -- [Find],
		etsBaseFunc:changeFiled( ?MODULE:getTeamInfoTable(), 
								 TeamPlayerInfo#teamPlayerInfo.teamID, 
								 #teamInfo.memberList, 
								 NewList ),
		
		etsBaseFunc:changeFiled( ?MODULE:getTeamPlayerTable(), 
								 TargetPlayerID, 
								 #teamPlayerInfo.teamID, 
								 0 ),
		
		TeamInfo2 = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), TeamPlayerInfo#teamPlayerInfo.teamID ),
		sendTeamInfoToMap( TeamInfo2, false ),
		
		?DEBUG_OUT( "player[~p] kickout target[~p] team[~p]", [PlayerID, TargetPlayerID, TeamPlayerInfo#teamPlayerInfo.teamID] ),

		ok
	catch
		{return}->ok;
		{return, ReturnCode }->
			Msg = #pk_teamOPResult{ targetPlayerID=PlayerID, targetPlayerName="", result=ReturnCode },
			player:sendToPlayer(PlayerID, Msg),
			ok			
	end.

on_teamQueryLeaderInfoRequest( PlayerID, Msg )->
	try
		TeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), PlayerID ),
		case TeamPlayerInfo of
			{}->throw( {return} );
			_->ok
		end,

		MyTeamID = TeamPlayerInfo#teamPlayerInfo.teamID,
		MapID = Msg#pk_teamQueryLeaderInfoRequest.mapID,
		
		Q = ets:fun2ms( fun(#teamPlayerInfo{playerID=DB_PlayerID, teamID=TeamID, teamMemberMapInfo=TeamMemberMapInfo } = _Record ) 
							 when ( TeamMemberMapInfo#teamMemberMapInfo.mapID =:= MapID ) andalso 
								  ( TeamID =/= 0 ) andalso
								  ( TeamID =/= MyTeamID )-> { DB_PlayerID, TeamID } end),
		Players2 = ets:select(?MODULE:getTeamPlayerTable(), Q),
		
		MyFunc = fun( Record )->
						 { DB_PlayerID, TeamID } = Record,
						 TeamInfo = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), TeamID ),
						 case TeamInfo of
							 {}->false;
							 _->
								 MemberCount = length( TeamInfo#teamInfo.memberList ),
								 case MemberCount >= ?TeamMember_MaxCount of
									 true->false;
									 false->TeamInfo#teamInfo.leaderPlayerID =:= DB_PlayerID
								 end
						 end
				 end,
		Players = lists:filter(MyFunc, Players2),
		
		MyFunc2 = fun( Record )->
						 { DB_PlayerID, _TeamID } = Record,
						 Player = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), DB_PlayerID ),
						 #pk_teamQueryLeaderInfo{ playerID=DB_PlayerID, 
											   playerName=Player#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.playerName,
											   level=Player#teamPlayerInfo.teamMemberMapInfo#teamMemberMapInfo.level }
				 end,
		TeamQueryLeaderInfoList = lists:map(MyFunc2, Players),
		
		MsgToUser = #pk_teamQueryLeaderInfoOnMyMap{info_list=TeamQueryLeaderInfoList},
		player:sendToPlayer(PlayerID, MsgToUser),
		
		ok
	catch
		{return}->
				Msg = #pk_teamQueryLeaderInfoOnMyMap{info_list=[]},
				player:sendToPlayer(PlayerID, Msg),
				ok
	end.

%%队长移交请求
on_teamChangeLeaderRequest( PlayerID, #pk_teamChangeLeaderRequest{playerID=TargetPlayerID}= _Msg )->
	try
		TeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), PlayerID ),
		case TeamPlayerInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		case TeamPlayerInfo#teamPlayerInfo.teamID =:= 0 of
			true->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			false->ok
		end,
		
		TeamInfo = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), TeamPlayerInfo#teamPlayerInfo.teamID ),
		case TeamInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		case TeamInfo#teamInfo.leaderPlayerID =:= PlayerID of
			true->ok;
			false->throw( {return, ?Team_OP_Result_Fail_NeedTeamLeader} )
		end,
		
		TargetTeamPlayerInfo = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), TargetPlayerID ),
		case TargetTeamPlayerInfo of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,

		put( "on_teamChangeLeaderRequest_find", {} ),
		MyFunc = fun( Record )->
						 case ( Record#teamMemberInfo.teamMemberMapInfo#teamMemberMapInfo.playerID =:= TargetPlayerID ) andalso
							   ( Record#teamMemberInfo.isOnline =:= 1 ) andalso
							   ( TeamInfo#teamInfo.leaderPlayerID =/= TargetPlayerID ) of
							 true->put( "on_teamChangeLeaderRequest_find", Record );
							 false->ok
						 end
				 end,
		lists:foreach( MyFunc, TeamInfo#teamInfo.memberList ),
		
		Find = get( "on_teamChangeLeaderRequest_find" ),
		case Find of
			{}->throw( {return, ?Team_OP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		etsBaseFunc:changeFiled( ?MODULE:getTeamInfoTable(), 
								 TeamPlayerInfo#teamPlayerInfo.teamID, 
								 #teamInfo.leaderPlayerID, TargetPlayerID ),
		
		ToUser = #pk_teamChangeLeader{ playerID=TargetPlayerID },
		?MODULE:sendMsgToAllMember(TeamInfo, ToUser ),
		
		TeamInfo2 = etsBaseFunc:readRecord( ?MODULE:getTeamInfoTable(), TeamPlayerInfo#teamPlayerInfo.teamID ),
		sendTeamInfoToMap( TeamInfo2, false ),
		
		?DEBUG_OUT( "player[~p] chage team leader to target[~p] team[~p]", [PlayerID, TargetPlayerID, TeamPlayerInfo#teamPlayerInfo.teamID] ),

		ok
	catch
		{return}->ok;
		{return, ReturnCode }->
			Msg = #pk_teamOPResult{ targetPlayerID=PlayerID, targetPlayerName="", result=ReturnCode },
			player:sendToPlayer(PlayerID, Msg),
			ok			
	end.	

%%请求将一些玩家组队进副本
on_fastTeamCopyMap( FromPID, CanEnterPlayers, Param )->
	try
		case length( CanEnterPlayers ) > ?TeamMember_MaxCount of
			true->throw( { return } );
			false->ok
		end,

		MyFunc = fun( Record )->
						 TeamInfoPlayer = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), Record ),
						 case TeamInfoPlayer of
							 {}->throw( { return } );
							 _->ok
						 end,
						 case ( TeamInfoPlayer#teamPlayerInfo.teamID =/= 0 ) or
							   ( TeamInfoPlayer#teamPlayerInfo.isOnline =/= 1 ) of
							 true->throw( { return } );
							 false->ok
						 end,

						 ok
				 end,
		lists:foreach( MyFunc, CanEnterPlayers ),
		
		Now = common:timestamp(),
		%%队长
		[LeaderPlayerID|_] = CanEnterPlayers,
		
		%%建队伍ID
		TeamID = map:makeObjectID( ?Object_Type_Team, db:memKeyIndex(teamInfo) ), % not persistent
		
		MyFunc2 = fun( Record )->
						  TeamInfoPlayer = etsBaseFunc:readRecord( ?MODULE:getTeamPlayerTable(), Record ),
						  #teamMemberInfo{isOnline = 1, 
										  joinTime=Now, 
										  teamMemberMapInfo=TeamInfoPlayer#teamPlayerInfo.teamMemberMapInfo }
				  end,
		MemberList = lists:map( MyFunc2, CanEnterPlayers ),
		%%建队伍信息
		TeamInfo = #teamInfo{
							 teamID = TeamID, 
							 leaderPlayerID = LeaderPlayerID, 
							 memberList=MemberList
							 },
		%%插入队伍表
		etsBaseFunc:insertRecord(?MODULE:getTeamInfoTable(), TeamInfo),
		
		MyFunc3 = fun( Record )->
						%%修改队伍玩家记录中的队伍ID
						etsBaseFunc:changeFiled( ?MODULE:getTeamPlayerTable(), Record, #teamPlayerInfo.teamID, TeamID ),
						%%发送队伍信息给玩家客户端
						sendTeamInfoToPlayer( TeamInfo, Record )
				  end,
		lists:foreach( MyFunc3, CanEnterPlayers ),
		
		%%发送队伍信息给玩家所在地图
		sendTeamInfoToMap( TeamInfo, false ),
		
		%%定时发送玩家简略信息
		erlang:send_after(?TeamUpdateShortInfo,self(), {updateTeamMemberShortInfo, TeamID} ),
		
		%%回复地图
		FromPID ! { fastTeamCopyMap_Result, CanEnterPlayers, Param, LeaderPlayerID },
		
		mapManagerPID ! { teamMsg_Created, TeamID, LeaderPlayerID },
		
		?DEBUG_OUT( "on_fastTeamCopyMap create team[~p]", [TeamInfo] ),
		ok
	catch
		{ return }->FromPID ! { fastTeamCopyMap_Result, CanEnterPlayers, Param, 0 }
	end.



