%% Author: Administrator
%% Created: 2012-7-9
%% Description: TODO: Add description to db
-module(map).

%% add by wenziyong for gen server
-behaviour(gen_server).
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).



%%
%% Include files
%%
-include("package.hrl").
-include("db.hrl").
-include("hdlt_logger.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("playerDefine.hrl").
-include("mapDefine.hrl").
-include("mapView.hrl").
-include("TeamDfine.hrl").
-include("worldBoss.hrl").
-include("variant.hrl").
-include("logdb.hrl").
-include("daily.hrl").
-include("textDefine.hrl").
-include("chat.hrl").


%%
%% Exported Functions
%%
-compile(export_all). 

start_link(MapObject) ->
	gen_server:start_link(?MODULE, [MapObject], [{timeout,60000}]).



init([MapObject]) ->	
	onMapInit( MapObject ),
	?DEBUG_OUT( "mapProcess[~p] started ~p", [self(), getMapLog()] ),
	
	erlang:send_after( ?Map_Actor_Move_Timer,self(), {mapActorMoveTimer} ),
	erlang:send_after( ?Map_Player_Move_Timer, self(),{mapPlayerMoveTimer} ),
	erlang:send_after( ?Map_Monster_AI_Timer,self(), {mapMonsterAITimer} ),
	erlang:send_after(?Map_PlayerPosUpdate_Timer,self(), {mapPlayerUpdataPos}),
	erlang:send_after( ?Map_Player_Ready_Enter_Timer,self(), {mapPlayerReadyEnterTimer} ),
	erlang:send_after( ?Map_Buff_Timer, self(),{mapBuffUpdateTimer} ),
	erlang:send_after( ?Map_LifeRecover_Timer,self(), {map_Life_Recover_Timer} ),
	erlang:send_after( 60*1000, self(),{timer_onMapTimerCheckPKKillPunishing} ),
	put("WorldBossID",-1),
	put("SmallMonsterList",[]),
	put("MapLeftSmallMonsterNum",0),
	%%put("InPKProct",false),
	{S1,S2,S3} = erlang:now(),
	random:seed(S1,S2,S3),
	{ok, {}}.




handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

handle_cast({'reloadPassiveSkill',PlayerID},State)->
    ?DEBUG_OUT("reloadPassiveSkill,PlayerID:~p",[PlayerID]),
    %Player = etsBaseFunc:readRecord( map:getMapPlayerTable(),PlayerID),
    case etsBaseFunc:readRecord( map:getMapPlayerTable(),PlayerID) of
		{}->ok;
		Player ->
			playerSkill:unDoAllPassiveSkill(Player),
			playerSkill:doAllPlayerPassiveSkill(Player)
	end,
    {noreply, State};
handle_cast(_Msg, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.



%%地图进程
%%返回地图ID
getMapID()->
	get( "MapID" ).
%%返回地图Cfg
getMapCfg()->
	get( "MapCfg" ).
%%返回地图DataID
getMapDataID()->
	get( "MapDataID" ).
%%返回地图对象MapObject
getMapObject()->
	etsBaseFunc:readRecord( getMapObjectTable(), getMapID() ).


%%返回地图log
getMapLog()->
	StringValue = io_lib:format( "map[~p ~p]", [getMapID(), getMapDataID()] ),
	lists:flatten(StringValue).

%%返回地图玩家table
getMapPlayerTable()->
	get( "PlayerTable" ).
%%返回地图monster table
getMapMonsterTable()->
	get( "MonsterTable" ).
%%返回地图npc table
getMapNpcTable()->
	get( "NpcTable" ).
%%返回地图pet table
getMapPetTable()->
	get("PetTable").
%%返回仇恨table
getObjectHatredTable()->
	get( "ObjectHatredTable" ).
%%返回bufftable
getObjectBuffTable()->
	get( "ObjectBuffTable" ).
%%返回玩家技能表
getPlayerSkillTable()->
	get( "PlayerSkillTable" ).
%%返回ObjectTable
getObjectTable()->
	get( "ObjectTable" ).
%%返回MapObjectTable
getMapObjectTable()->
	get( "MapObjectTable" ).

getReadyEnterPlayerTable()->
	get( "ReadyEnterPlayerTable" ).
%% Return MapViewCellTable
getMapViewCellsTable()->
	get("MapViewCellsTable").

getMapPlayerTeamInfo()->
	get("MapPlayerTeamInfo").

getFastTeamCopyMap()->
	get( "FastTeamCopyMapTable" ).

getQieCuoPlayersTable()->
	get( "QieCuoPlayersTable" ).



%%构建物件ID，64位(前1位永为0保持正数(64)，11位服务器ID(53-63)，6位类型ID(47-52)，5位预留(42-46), 41位ID值(1-41))
makeObjectID( ObjType, ID )->
	%%2047=11位服务器IDMask
	%%63=6位类型IDMask
	%%16#1FFFFFFFFFF=41位ID值Mask
	OutID = ( ( main:getServerID() band 2047 ) bsl 52 ) bor ( ( ObjType band 63 ) bsl 46 ) bor ( ID band 16#1FFFFFFFFFF ),
	OutID.
%%返回物件ID所在服务器ID
getObjectID_ServerID( ID )->
	ServerID = ID band 16#7FF0000000000000,
	(ServerID bsr 52).

%%返回物件ID的类型ID
getObjectID_TypeID( ID )->
	TypeID = ID band (16#FC00000000000),
	(TypeID bsr 46).

%%返回物件ID的数值ID
getObjectID_Value( ID )->
	ValueID = ID band (16#1FFFFFFFFFF),
	ValueID.

%%根据ID返回相应类型的数据记录
getMapObjectByID( ID )->
	ObjType = getObjectID_TypeID( ID ),
	case ObjType of
		?Object_Type_Player->
			etsBaseFunc:readRecord( getMapPlayerTable(), ID );
		?Object_Type_Npc->
			etsBaseFunc:readRecord( getMapNpcTable(), ID );
		?Object_Type_Monster->
			etsBaseFunc:readRecord( getMapMonsterTable(), ID );
		?Object_Type_Object->
			etsBaseFunc:readRecord( getObjectTable(), ID );
		?Object_Type_TRANSPORT->
			etsBaseFunc:readRecord( getObjectTable(), ID );
		?Object_Type_COLLECT->
			etsBaseFunc:readRecord( getObjectTable(), ID );
		?Object_Type_Normal->
			etsBaseFunc:readRecord( getObjectTable(), ID );
		?Object_Type_Pet->
			etsBaseFunc:readRecord(map:getMapPetTable(), ID);
		?Object_Type_Map->
			etsBaseFunc:readRecord( map:getMapObjectTable(), ID );
		?Object_Type_SkillEffect->
			etsBaseFunc:readRecord( getObjectTable(), ID);
		_->{}
	end.

%%返回对象ID
getObjectID( Object )->
	case element( 1, Object ) of
		mapPlayer->
			Object#mapPlayer.id;
		mapNpc->
			Object#mapNpc.id;
		mapMonster->
			Object#mapMonster.id;
		mapObjectActor->
			Object#mapObjectActor.id;
		mapPet->
			Object#mapPet.id;
		mapObject->
			Object#mapObject.id;
		_->0
	end.
%%返回对象log名字
getObjectLogName( Object )->
	case element( 1, Object ) of
		mapPlayer->
			Object#mapPlayer.name ++ " " ++ common:formatString( Object#mapPlayer.id );
		mapNpc->
			common:formatString( Object#mapNpc.npc_data_id ) ++ " " ++ common:formatString( Object#mapNpc.id );
		mapMonster->
			common:formatString( Object#mapMonster.map_data_id ) ++ " " ++ common:formatString( Object#mapMonster.id );
		mapObjectActor->
			common:formatString( Object#mapObjectActor.object_data_id ) ++ " " ++ common:formatString( Object#mapObjectActor.id );
		mapPet->
			common:formatString( Object#mapPet.data_id ) ++ " " ++ common:formatString( Object#mapPet.id );
		_->"unkown"
	end.

%%是否已经死亡
isObjectDead( Object )->
	case element( 1, Object ) of
		mapPlayer->
			playerMap:isDead(Object#mapPlayer.id);
		mapNpc->
			false;
		mapMonster->
			monster:isDead(Object#mapMonster.id);
		mapPet->
			petMap:isDead(Object#mapPet.id);
		_->false
	end.
%%返回对象坐标pos
getObjectPos( Object )->	
	case element( 1, Object ) of
		mapPlayer->
			Object#mapPlayer.pos;
		mapNpc->
			#posInfo{x=Object#mapNpc.x,y=Object#mapNpc.y};
		mapMonster->
			Object#mapMonster.pos;
		mapObjectActor->
			#posInfo{x=Object#mapObjectActor.x,y=Object#mapObjectActor.y};
		mapPet->
			Object#mapPet.pos;
		_->#posInfo{x=0,y=0}
	end.

%%返回玩家对象
getPlayer( PlayerID )->
	Player = etsBaseFunc:readRecord( ?MODULE:getMapPlayerTable(), PlayerID ),
	case Player of
		{}->{};
		_->
			case element( 1, Player ) of
				mapPlayer->Player;
				_->{}
			end
	end.

isExistPlayer( PlayerID )->
	Player = etsBaseFunc:readRecord( ?MODULE:getMapPlayerTable(), PlayerID ),
	case Player of
		{}->false;
		_->
			case element( 1, Player ) of
				mapPlayer->true;
				_->false
			end
	end.

%%返回Monster对象
getMonster( ID )->
	Monster = etsBaseFunc:readRecord( ?MODULE:getMapMonsterTable(), ID ),
	case Monster of
		{}->{};
		_->
			case element( 1, Monster ) of
				mapMonster->Monster;
				_->{}
			end
	end.
%%返回Npc对象
getNpc( ID )->
	Npc = etsBaseFunc:readRecord( ?MODULE:getMapNpcTable(), ID ),
	case Npc of
		{}->{};
		_->
			case element( 1, Npc ) of
				mapNpc->Npc;
				_->{}
			end
	end.

%%返回Object对象
getObjectActor( ID )->
	ObjectActor = etsBaseFunc:readRecord( ?MODULE:getObjectTable(), ID ),
	case ObjectActor of
		{}->{};
		_->
			case element( 1, ObjectActor ) of
				mapObjectActor->ObjectActor;
				_->{}
			end
	end.

%%返回Pet对象
getPet( ID )->
	Pet = etsBaseFunc:readRecord( ?MODULE:getMapPetTable(), ID ),
	case Pet of
		{}->{};
		_->
			case element( 1, Pet ) of
				mapObjectActor->Pet;
				_->{}
			end
	end.

%%返回两个对象的距离SQ
getObjectDistanceSQ( FromObject, ToObject )->
	PosFrom = getObjectPos( FromObject ),
	PosTo = getObjectPos( ToObject ),
	monster:getDistSQFromTo(PosFrom#posInfo.x, PosFrom#posInfo.y, PosTo#posInfo.x, PosTo#posInfo.y).

%%发送消息给本地图上的所有玩家
senMsgToAllMapPlayer(Msg)->
	Func = fun(Player)->
				   player:sendToPlayerByPID(Player#mapPlayer.pid, Msg)
		   end,
	etsBaseFunc:etsFor(map:getMapPlayerTable(), Func),
	ok.

%%地图主循环
handle_info(Info, StateData)->	
	put( "loopMap", true ),

	try
	case Info of
		{quit}->
			?LOG_OUT( "recv quit ~p", [getMapLog()] ),
			put( "loopMap", false ),
			destroyMap();
		{mapActorMoveTimer}->
			erlang:send_after( ?Map_Actor_Move_Timer,self(), {mapActorMoveTimer} ),
			onMapActorMoveTimer();
		{mapPlayerMoveTimer}->
			erlang:send_after( ?Map_Player_Move_Timer,self(), {mapPlayerMoveTimer} ),
			onMapPlayerMoveTimer();
		{mapMonsterAITimer}->
			erlang:send_after( ?Map_Monster_AI_Timer,self(), {mapMonsterAITimer} ),
			onMapMonsterAITimer();
		{mapPlayerUpdataPos}->
			erlang:send_after(?Map_PlayerPosUpdate_Timer,self(), {mapPlayerUpdataPos}),
			sendplayerPosInfoToteamMoulde();
		{mapPlayerReadyEnterTimer}->
			erlang:send_after( ?Map_Player_Ready_Enter_Timer,self(), {mapPlayerReadyEnterTimer} ),
			on_mapPlayerReadyEnterTimer();
		{mapBuffUpdateTimer}->
			erlang:send_after( ?Map_Buff_Timer,self(), {mapBuffUpdateTimer} ),
			on_mapBuffUpdateTimer();
		{map_Life_Recover_Timer} ->
			erlang:send_after( ?Map_LifeRecover_Timer, self(),{map_Life_Recover_Timer} ),
			on_mapLifeRecoverTimer();
		{ objectTimer, NewTimer }->
			objectEvent:on_objectTimer(NewTimer);
		{playerMove, PlayerId, P} ->
			playerMove:onPlayerMoveTo(PlayerId, P);
		{playerDirMove,PlayerID, P}->
			playerMove:onPlayerDirMove(PlayerID, P);
		{playerTeleportMove, PlayerID, P}->
			playerMove:onPlayerTeleportMove(PlayerID, P);
		{playerStopMove,PlayerId, P} ->
			playerMove:onPlayerStopMove(PlayerId, P);
		{playerChangeFlyState,PlayerId, P} ->
			playerMove:onChangeFlyState(PlayerId, P);
		{ mapMonsterRespawnTimer, SpawnCfg }->
			monster:onMapMonsterRespawnTimer( SpawnCfg );
		{ skillFlyTimer,  AttackerID, SkillCfg, TargetID, SkillEffectCount,CombatID}->
			skillUse:onSkillFlyTime(AttackerID, SkillCfg, TargetID, SkillEffectCount, CombatID);
		{ playerEnterMap, MapPlayer, PlayerSkillList, BuffData, PlayerProperty, WeaponID, CoatID }->
			playerMap:on_playerEnterMap( MapPlayer, PlayerSkillList, BuffData, PlayerProperty, WeaponID, CoatID );
		{changeMultyExpBuff,PlayerID,BuffID,IsAdd}->
			playerMap:on_ChangeMultyExpBuff( PlayerID,BuffID,IsAdd );
		{ mapPlayerOffline, PlayerID }->
			playerMap:on_mapPlayerOffline( PlayerID );
		{msgplayerUseSkill,PlayerID, Res}->
			playerMap:onMsgUseSkill(PlayerID, Res#pk_U2GS_UseSkillRequest.nSkillID, Res#pk_U2GS_UseSkillRequest.nTargetIDList, Res#pk_U2GS_UseSkillRequest.nCombatID );
		{ objectReSpawn, SpawnData }->
			objectActor:spawnObjectActor(SpawnData);
		{ playerMsg_U2GS_TalkToNpc, PlayerID, Msg}->
			task:on_playerMsg_U2GS_TalkToNpc(PlayerID, Msg);
		{ playerMsg_U2GS_AcceptTaskRequest, FromePID, PlayerID, Msg}->
			task:on_playerMsg_U2GS_AcceptTaskRequest(FromePID, PlayerID, Msg);
		{ playerMsg_U2GS_CollectRequest, PlayerID, Msg}->
			task:on_playerMsg_U2GS_CollectRequest(PlayerID, Msg);
		{ playerMsg_U2GS_CompleteTaskRequest, FromPID, PlayerID, Msg }->
			task:on_playerMsg_U2GS_CompleteTaskRequest( FromPID, PlayerID, Msg );
		{petOutFight, PlayerId, Pid, Pet, PetCfg, BuffData } ->
			petMap:onPlayerCallPet(PlayerId, Pid, Pet, PetCfg, BuffData);
		{ playerMsg_Reborn, FromPID, PlayerID, ReviveTyp, ItemLock }->
			playerMap:on_playerMsg_Reborn( FromPID, PlayerID, ReviveTyp, ItemLock );
		{petTakeRest, _PlayerId, Pid, PetId} ->
			petMap:onPetTakeRest(PetId, Pid);
		{petChangeAIState, PlayerId, Pid, PetId, State} ->
			petMap:onPetChangeAIState(PlayerId, Pid, PetId, State);
		{petLearnSkill, PlayerId, PetId, SkillId, NewSkillId}->
			petMap:onPetLearnSkill(PlayerId, PetId, SkillId, NewSkillId);
		{petDelSkill, PlayerId, PetId, SkillId}->
			petMap:onPetDelSkill(PlayerId, PetId, SkillId);
		{petChangeModel, PetId, ShowModel} ->
			petMap:onPetChangeModel(PetId, ShowModel);
		 {petChangeName, PetId, NewName} ->	
			petMap:onPlayerMSG_PetChangeName(PetId, NewName);
		{playerMsg_PetChanged, PetID, PetProperty}->
			petMap:onPlayerMsg_PetChanged(PetID, PetProperty);
		{playerMsg_UseBloodbag,FromPID,PlayerID,Location, Cell, ItemCfg, ItemDBData, UseCount}->
			playerUseItem:on_playerMsg_UseBloodbag( FromPID,PlayerID,Location, Cell, ItemCfg, ItemDBData, UseCount);
		{playerMsg_UsePetBloodbag,FromPID,PlayerID,Location, Cell, ItemCfg, ItemDBData, UseCount}->
			playerUseItem:on_playerMsg_UsePetBloodbag( FromPID,PlayerID,Location, Cell, ItemCfg, ItemDBData, UseCount);
		{playerMsg_UseBloodPool,FromPID,PlayerID}->
			playerUseItem:on_playerMsg_UseBloodPool(FromPID,PlayerID);
		{playerMsg_UsePetBloodPool,FromPID,PlayerID}->
			playerUseItem:on_playerMsg_UsePetBloodPool(FromPID,PlayerID);

		{playerUseItem_Msg_CreateBuff,FromPID,PlayerID,Location, Cell, UseCount, ItemCfg, ItemDBData }->
			playerUseItem:on_playerUseItem_Msg_CreateBuff( FromPID,PlayerID,Location, Cell, UseCount, ItemCfg, ItemDBData );
		
		{playerMsg_UseHpMp,FromPID,PlayerID,Location, Cell, ItemCfg, ItemDBData, UseCount}->
			playerUseItem:on_playerMsg_UseHpMp(FromPID,PlayerID,Location, Cell, ItemCfg, ItemDBData, UseCount);
		{msg_u2gs_PlayerStudySkill, FromPID, PlayerID, SkillID }->
			playerSkill:playerHasStudySkill(FromPID, PlayerID, SkillID);
		{msg_PlayerStudySkill, FromPID, PlayerID, SkillID}->
			playerSkill:onMsgPlayerStudySkill(FromPID, PlayerID, SkillID);
		{msg_PlayerSkillActive, FromPID, PlayerID, TrunkID, BranchID, WhichBranch}->
			playerSkill:mapPlayerSkillActived(FromPID, PlayerID, TrunkID, BranchID, WhichBranch);
		{msg_PlayerAddSkillBranch, FromPID, PlayerID, TrunkID, BranchID}->
			playerSkill:mapPlayerAddSkillBranch(FromPID, PlayerID, TrunkID, BranchID);
		{msg_PlayerRemoveSkillBranch, FromPID, PlayerID, SkillID}->
			playerSkill:mapPlayerRemoveSkillBranch(FromPID, PlayerID, SkillID );

		{on_playerMountSet,PlayerID,MountDataID,FlagofRide,MountSpeed}->
			playerMap:on_PlayerMountSet(PlayerID,MountDataID,FlagofRide,MountSpeed);
			
		{teamMsg_TeamMemberUPdata,PlayerID,Vaule}->
			playerMap:on_playerTeamset(PlayerID,Vaule);
		
		{ playerMsg_LevelEquipPet_Changed, PlayerID, Level, WeaponID, CoatID, PetData, Property, MinEquipLevel }->
			playerMap:on_playerMsg_LevelEquipPet_Changed( PlayerID, Level, WeaponID, CoatID, PetData, Property, MinEquipLevel );
		
		{ enterMapByGM, PlayerID, MapDataID }->
			playerChangeMap:on_enterMapByGM( PlayerID, MapDataID );
		{gm_RandomAttack,PlayerID,SkillID}->
			playerMap:on_gmRandomAttack(PlayerID,SkillID);
		{ timeOutOfTransPlayer, PlayerID }->
			playerChangeMap:on_timeOutOfTransPlayer( PlayerID );
		{ getReadyToEnterMap_CanEnter, FromPID, OwnerID, EnterPlayerList, TargetMapInfo }->
			playerChangeMap:on_getReadyToEnterMap_CanEnter( FromPID, OwnerID, EnterPlayerList, TargetMapInfo );
		{ getReadyToEnterMap_Result, TargetMapPID, OwnerID, EnterPlayerList, TargetMapInfo, Result }->
			playerChangeMap:on_getReadyToEnterMap_Result( TargetMapPID, OwnerID, EnterPlayerList, TargetMapInfo, Result );

		{playerOnMount, PID, PlayerID,MountDataID, MoveSpeed_Percent}->
			mount:on_ViewMount(PID, PlayerID,MountDataID, MoveSpeed_Percent);
		{playerDownMount,PID, PlayerID}->
			mount:on_ViewMount(PID, PlayerID,true);	

		{playerConvoyStateChange, PlayerID, CurConvoyQuality, ConvoyFlags}->
			changeConvoyState(PlayerID, CurConvoyQuality, ConvoyFlags);
	
		{ msgFromPlayerSocket, PlayerID, Msg }->
			map_Msg:on_msgFromPlayerSocket( PlayerID, Msg );
		{playerMap_Level, PlayerID, _NewLevel}->
			objectEvent:onEvent(map:getMapObjectByID(PlayerID),?Player_Event_Level_Change, 0);
		{playerMap_Credit, PlayerID, _NewCredit}->
			on_mapPlayerCreditChange(PlayerID,_NewCredit);
		{mapNoPlayerTimer}->
			on_mapNoPlayerTimer();

		{ playerMsg_U2GS_TransForSameScence, FromPID, PlayerID, CanDecItemInBagResult, Msg }->
			playerChangeMap:transForSameScence( FromPID, PlayerID, CanDecItemInBagResult, Msg );
		{ playerMsg_U2GS_TransForWroldMap, _FromPID, PlayerID, _CanDecItemInBagResult, Msg}->
			playerChangeMap:transPlayerByWorldMap(PlayerID, Msg);

		{ mapManagerMsg_ResetCopyMap, PlayerID }->
			playerChangeMap:on_mapManagerMsg_ResetCopyMap( PlayerID );
		{ playerMsg_CreateMonsterByGM, PlayerID, MonsterID }->
			monster:on_playerMsg_CreateMonsterByGM(PlayerID, MonsterID);
		{ playerLeaveCopyMap, PlayerID }->
			playerMap:on_PlayerLeaveCopyMap(PlayerID);
		{ playerAddActiveCount, PID, PlayerID, DecItemData, MapCfg, IsVIPCount }->
			playerChangeMap:on_PlayerMsgAddActiveCount( PID, PlayerID, DecItemData, MapCfg, IsVIPCount);
		
		{ fastTeamCopyMap_Result, CanEnterPlayers, Param, LeaderPlayerID }->
			playerChangeMap:on_fastTeamCopyMap_Result(CanEnterPlayers, Param, LeaderPlayerID);

		{ woldBossBegin}->
			on_worldBossActiveBegin();
		{woldBossComeout}->
			on_worldBossComeout();
		{ worldBossAddExp}->
			on_worldBossAddExp();
		{ killWorldBoss,BossID}->
			on_killWorldBoss(BossID);
		{worldBossSmallMonsterReborn,Object}->
			rebornworldBossSmallMonser(Object);
		{ teamMsg_KickOut, TeamID, PlayerID }->
			playerChangeMap:on_teamMsg_KickOut( TeamID, PlayerID );
		{ teamMemberForceTransOut, PlayerID, TeamID, TimeRemain }->
			playerChangeMap:on_teamMemberForceTransOut( PlayerID, TeamID, TimeRemain );
		{lookPlayerInfo, PID, PlayerID, Msg}->
			playerMap:on_LookPlayerInfo( PID, PlayerID, Msg );
		{timer_onMapTimerCheckPKKillPunishing}->
			qieCuo:onMapTimerCheckPKKillPunishing();
		{updateGuildInfo, PlayerID, GuildID, GuildName, GuildRank}->
			playerMap:updatePlayerGuildInfo(PlayerID, GuildID, GuildName, GuildRank);
		{tellSelfLineID,MyLineID}->
			put("MyLineID",MyLineID);
		{msg_PlayerVipChanged, PlayerID, VipLevel, VipTimeExpire, VipTimeBuy}->
			playerMap:onVIPLevelChange(PlayerID, VipLevel, VipTimeExpire, VipTimeBuy);
		{ requestOutFightPetPropetry, PID, PetID }->
			petMap:onPlayerRequestPetPropetry( PID, PetID );
		%%战场相关
		{battleActiveAddScore}->
			copyMap_Battle:onAddScoreTimer();
		{playerEnterBattleScene,PlayerID,MapDataID,PosX,PosY,OwerPlayerID}->
			playerMap:on_playerEnterBattleScene(PlayerID,MapDataID,PosX,PosY,OwerPlayerID);
		{battleMapRelive,Object}->
			copyMap_Battle:relive(Object);
		{banPlayerRelive,Player,BanTime}->
			onBanPlayerRelive(Player,BanTime);
		{battleBalance}->
			copyMap_Battle:calculateFinalResult();
		{battleTimeout}->
			copyMap_Battle:onBattleTimeOut();
		{msgrequestLeaveBattle,PlayerID}->
			copyMap_Battle:onRequestLeaveMap(PlayerID);
		{battleBeginFight}->
			copyMap_Battle:onbattleBeginFight();
		{battleActiveEnrollCheck,PlayerID,Campus,FromPID,NPCID}->
			active_battle:onCheckEnrollNPC(PlayerID,Campus,FromPID,NPCID);
		{msg_request_Battle_Result_list,PlayerID}->
			copyMap_Battle:on_request_Battle_Result_list(PlayerID),
			ok;
		{msg_playerleaveBattle,Player,_Campus}->
			copyMap_Battle:onRequestLeaveMap(Player),
			ok;

		
		{ gameSetupChanged, PlayerID, GameSteup }->
			playerMap:onChangeGameSetup(PlayerID, GameSteup);
		
		Unkown->
			?ERROR_OUT( "loopMap recv unkown msg: ~p, map: ~p", [Unkown,getMapLog()] )
	end,

	case get( "loopMap" ) of
		true->{noreply, StateData};
		false->
			doMapProcExit(),
			{stop, normal, StateData}
	end

	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] stack[~p] ExceptionFunc[hande_info] Why[~p]", 
						[?MODULE, erlang:get_stacktrace(),_Why] ),	

			{noreply, StateData}
	end.

doMapProcExit()->
	?LOG_OUT( "map[~p] doMapProcExit", [map:getMapLog()] ),
	mapManagerPID ! { mapProcExited, getMapID() }.

%%返回是否在地图进程
isPlayerProcess()->
	case get( "IsMapProcess" ) of
		true->true;
		_->false
	end.

%%地图初始化
onMapInit( #mapObject{}=MapObject )->
	try
		?DEBUG_OUT( "begin create map id[~p] dataid[~p] pid[~p]", [MapObject#mapObject.id, MapObject#mapObject.map_data_id, self()] ),
		
		put( "IsMapProcess", true ),
%% 		put( "MonsterCfgTable", main:getGlobalMonsterCfgTable() ),
%% 		put( "NpcCfgTable", main:getGlobalNpcCfgTable() ),
%% 		put( "MapCfgTable", main:getGlobalMapCfgTable() ),
%% 		
%% 		put("SkillCfgTable",main:getGlobalSkillCfgTable()),
%% 		put("BuffCfgTable",main:getGlobalBuffCfgTable()),
%% 		put("SkillEffectCfgTable",main:getGlobalSkillEffectCfgTable()),
%% 		
%% 		put( "AttackFactorCfgTable", main:getAttackFactorCfgTable() ),
%% 		put( "AttributeRegentCfgTable", main:getAttributeRegentCfgTable() ),
%% 		put( "ScriptObjectTable", main:getScriptObjectTable() ),

		put( "MapID", MapObject#mapObject.id ),
		put( "MapDataID", MapObject#mapObject.map_data_id ),
		MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), getMapDataID() ),
		put( "MapCfg", MapCfg ),

		MapObjectTable = ets:new( 'MapObjectTable', [private, { keypos, #mapObject.id }] ),
		put( "MapObjectTable", MapObjectTable ),
		NewMapObject = setelement( ?object_table_index, MapObject, MapObjectTable ),
		etsBaseFunc:insertRecord( MapObjectTable, NewMapObject ),
		
		PlayerTable = ets:new( 'playerMapTable', [private, { keypos, #mapPlayer.id }] ),
		put( "PlayerTable", PlayerTable ),
		
		NpcTable = ets:new( 'NpcTable', [private, { keypos, #mapNpc.id }] ),
		put( "NpcTable", NpcTable ),

		MonsterTable = ets:new( 'MonsterTable', [private, { keypos, #mapMonster.id }] ),
		put( "MonsterTable", MonsterTable ),

		PetTable = ets:new( 'PetTable', [protected, { keypos, #mapMonster.id }] ),
		put( "PetTable", PetTable ),

		ObjectHatredTable = ets:new( 'ObjectHatredTable', [private, { keypos, #objectHatred.id }] ),
		put( "ObjectHatredTable", ObjectHatredTable ),

		ObjectBuffTable = ets:new( 'ObjectBuffTable', [private, { keypos, #objectBuff.id }] ),
		put( "ObjectBuffTable", ObjectBuffTable ),
		
		PlayerSkillTable = ets:new( 'PlayerSkillTable', [private, { keypos, #playerSkill.id }] ),
		put( "PlayerSkillTable", PlayerSkillTable ),

		ObjectTable = ets:new( 'ObjectTable', [private, { keypos, #mapObjectActor.id }] ),
		put( "ObjectTable", ObjectTable ),
		
		ReadyEnterPlayerTable = ets:new( 'ReadyEnterPlayerTable', [private, { keypos, #readyEnterMap.playerID }] ),
		put( "ReadyEnterPlayerTable", ReadyEnterPlayerTable ),
		
		FastTeamCopyMapTable = ets:new( 'FastTeamCopyMapTable', [private, { keypos, #fastTeamCopyMap.mapDataID }] ),
		put( "FastTeamCopyMapTable", FastTeamCopyMapTable ),
		
		QieCuoPlayersTable = ets:new( 'qieCuoPlayers', [private, { keypos, #qieCuoPlayers.playerID }] ),
		put( "QieCuoPlayersTable", QieCuoPlayersTable ),

		put( "MapCombatID_Begin", MapObject#mapObject.combatID ),
		put( "MapCombatID_Cur", MapObject#mapObject.combatID ),
		put( "LastNoPlayerTime", common:timestamp() ),

		MapDataID = getMapDataID(),	
		mapView:onMapInit( MapDataID ),		

		case MapCfg#mapCfg.type of
			?Map_Type_Normal_Copy->
				%%副本，创建计时器，无人超时结束副本
				put( "Map_NoPlayer_Time", ?CopyMap_NoPlayer_Destroy_Time ),
				erlang:send_after( ?Map_NoPlayer_Timer,self(), {mapNoPlayerTimer} ),
				ok;
			?Map_Type_Battle->
				%%战场副本，创建计时器，无人超时结束副本
				put( "Map_NoPlayer_Time", ?BattleMap_NoPlayer_Destroy_Time ),
				timer:send_after( ?Map_NoPlayer_Timer, {mapNoPlayerTimer} ),
				ok;
			_->ok
		end,

		case MapCfg#mapCfg.mapID =:= 1 of
			true->
					ok;
			false->ok
		end,
		
		objectEvent:onMapInitCreateEventManger(),
		
		scriptManager:onObjectCreateScript( NewMapObject ),
		
		MapObject2 = etsBaseFunc:readRecord(getMapObjectTable(), MapObject#mapObject.id),
		objectEvent:onEvent( MapObject2, ?Map_Event_Init, 0),

		monster:loadMapMonster(),
		%%地图怪物最大数量，用以计算副本进度
		put( "MaxMonsterCount",  ets:info(map:getMapMonsterTable(), size) ),
		%%地图创建时间，用以计算副本结算
		put( "MapInitTime", erlang:now() ),
		%%怪物击杀数，用于副本结算
		put( "KilledMonsterCount", 0 ),
		
		npc:loadMapNpc(),
		
		objectActor:loadMapObject(),
		
		%%初始化玩家移动方向的向量
		DirArray = array:new(?eDirection_ArrayLength, {default, {}}),
		DirArray2 = array:set(?eDirection_Left, #posInfo{x=-1,y=0}, DirArray),
		DirArray3 = array:set(?eDirection_Right, #posInfo{x=1,y=0}, DirArray2),
		DirArray4 = array:set(?eDirection_Up, #posInfo{x=0,y=1}, DirArray3),
		DirArray5 = array:set(?eDirection_Down, #posInfo{x=0,y=-1}, DirArray4),
		DirArray6 = array:set(?eDirection_LeftUp, #posInfo{ x=-0.707107, y=0.707107 }, DirArray5),
		DirArray7 = array:set(?eDirection_RightUp, #posInfo{ x=0.707107, y=0.707107 }, DirArray6),
		DirArray8 = array:set(?eDirection_LeftDown, #posInfo{ x=-0.707107, y=-0.707107 }, DirArray7),
		DirArray9 = array:set(?eDirection_RightDown, #posInfo{ x=0.707107, y=-0.707107 }, DirArray8),
		put( "PlayerDirArray", DirArray9 ),
		
		ok
	catch
		_->ok
	end.

%%方向数组
getPlayerDirArray()->
	get( "PlayerDirArray" ).

%%方向值
getPlayerDirValue( Dir )->
	case Dir < ?eDirection_ArrayLength of
		true->
			array:get( Dir, getPlayerDirArray() );
		_->{}
	end.

%%怪物数量
getMaxMonsterCount()->
	get( "MaxMonsterCount" ).

%%击杀怪物数量
getKilledMonsterCount()->
	get( "KilledMonsterCount" ).

%%地图创建时间
getMapInitTime()->
	get( "MapInitTime" ).

%%地图销毁
onMapDestroy()->
	try
		objectEvent:onEvent(etsBaseFunc:readRecord(getMapObjectTable(), getMapID()), ?Map_Event_Destroy, 0),
		ok
	catch
		_->ok
	end.
	
%%销毁地图
destroyMap()->
	try
		onMapDestroy(),
		
		mapManagerPID ! { mapDestroyed, getMapID() },
		
		ok
	catch
		_->ok
	end.

makeLookInfoMonster( #mapMonster{}=Monster )->
		MoveTarget = monsterMove:getCurMoveTargetPos(Monster),
		case MoveTarget of
			{}->MoveTargetX = 0, 
				MoveTargetY = 0;
			_->
				MoveTargetX = MoveTarget#posInfo.x,
			    MoveTargetY = MoveTarget#posInfo.y
		end,
		
		LifePercent = erlang:trunc( Monster#mapMonster.life / charDefine:getObjectProperty(Monster, ?max_life) * 100 ),
		
		#pk_LookInfoMonster{id=Monster#mapMonster.id,
											  x=erlang:trunc( Monster#mapMonster.pos#posInfo.x ),
											  y=erlang:trunc( Monster#mapMonster.pos#posInfo.y ),
						   					  move_target_x=MoveTargetX,
						   					  move_target_y=MoveTargetY,
											  move_speed=array:get(?move_speed, Monster#mapMonster.finalProperty),
											  monster_data_id=Monster#mapMonster.monster_data_id,
											  lifePercent=LifePercent,
											  faction=Monster#mapMonster.faction,
											  charState=Monster#mapMonster.stateFlag,
											  buffList=buff:makeObjectBuffPackage(Monster#mapMonster.id)
											  }.
	
%%Monster进入地图
enterMapMonster( #mapMonster{}=Monster )->
	try
		ActorID = Monster#mapMonster.id,
		etsBaseFunc:insertRecord( getMapMonsterTable(), Monster ),
		
		damageCalculate:calcFinaProperty(Monster#mapMonster.id),
		
		Monster2 = etsBaseFunc:readRecord(map:getMapMonsterTable(), Monster#mapMonster.id),

		%%添加状态
		mapActorStateFlag:addStateFlag( ActorID, ?Actor_State_Flag_EnteredMap ),
		
		%%进入地图格子
		mapView:charEnterCell(Monster2, 0),
		
		%%脚本初始化
		scriptManager:onObjectCreateScript( etsBaseFunc:readRecord( map:getMapMonsterTable(), ActorID) ),
		objectEvent:onEvent( Monster2, ?Monster_Event_Init, 0 ),
		
		%%响应Monster进入地图
		objectEvent:onEvent( etsBaseFunc:readRecord( map:getMapMonsterTable(), ActorID), ?Char_Event_Enter_Map, 0 ),
		
		ok
	catch
		_->ok
	end.

makeLookInfoNpc( #mapNpc{}=Npc )->
	%%Npc暂时没有移动
	MoveTarget = {},
	case MoveTarget of
		{}->MoveTargetX = 0, MoveTargetY = 0;
		_->MoveTargetX = MoveTarget#posInfo.x,
		   MoveTargetY = MoveTarget#posInfo.y
	end,
	#pk_LookInfoNpc{id=Npc#mapNpc.id,
											  x=erlang:trunc( Npc#mapNpc.x ),
											  y=erlang:trunc( Npc#mapNpc.y ),
						   					  move_target_x=MoveTargetX,
						   					  move_target_y=MoveTargetY,
											  npc_data_id=Npc#mapNpc.npc_data_id
											  }.
	
%%Npc进入地图
enterMapNpc( #mapNpc{}=Npc )->
	try
		ActorID = Npc#mapNpc.id,
		
		etsBaseFunc:insertRecord( getMapNpcTable(), Npc ),
		
		%%添加状态
		mapActorStateFlag:addStateFlag( Npc#mapNpc.id, ?Actor_State_Flag_EnteredMap ),
		
		%%进入地图格子
		mapView:charEnterCell(Npc, 0),
		
		%%脚本初始化
		scriptManager:onObjectCreateScript( etsBaseFunc:readRecord( map:getMapNpcTable(), ActorID) ),
		
		objectEvent:onEvent(Npc, ?Npc_Event_Init, 0 ),
		%%响应Monster进入地图
		objectEvent:onEvent( etsBaseFunc:readRecord( map:getMapNpcTable(), ActorID), ?Char_Event_Enter_Map, 0 ),
		
		ok
	catch
		_->ok
	end.

makeLookInfoPet(#mapPet{}=Pet) ->
	MoveTarget = petMove:getCurMoveTargetPos(Pet),
		case MoveTarget of
			{}->MoveTargetX = 0, MoveTargetY = 0;
			_->MoveTargetX = MoveTarget#posInfo.x,
			   MoveTargetY = MoveTarget#posInfo.y
		end,

		#pk_LookInfoPet{
						id=Pet#mapPet.id,
						masterId=Pet#mapPet.masterId,
						data_id=Pet#mapPet.data_id,
						name=Pet#mapPet.name,
						titleid=Pet#mapPet.titleid,
						modelId=Pet#mapPet.modelId,
						lifePercent=erlang:trunc( Pet#mapPet.life / charDefine:getObjectProperty(Pet, ?max_life) * 100 ),
						level=Pet#mapPet.level,
						x=Pet#mapPet.pos#posInfo.x,
						y=Pet#mapPet.pos#posInfo.y,
						move_target_x=MoveTargetX,
						move_target_y=MoveTargetY,
						move_speed=array:get(?move_speed, Pet#mapPet.finalProperty),
						charState=Pet#mapPet.stateFlag,
					   buffList=buff:makeObjectBuffPackage(Pet#mapPet.id)
					   }.

changeConvoyState(PlayerID, CurConvoyQuality, ConvoyFlags) ->
	try
		Player = map:getPlayer(PlayerID),
		case Player of
			{}->
				throw(-1);
			_->	
				case ConvoyFlags =:= 0 of
					true -> mapActorStateFlag:removeStateFlag(PlayerID, ?Player_State_Flag_Convoy);	
					false -> mapActorStateFlag:addStateFlag(PlayerID, ?Player_State_Flag_Convoy)
				end,
				etsBaseFunc:changeFiled(map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.covoyQuality, CurConvoyQuality),
				etsBaseFunc:changeFiled(map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.convoyFlags, ConvoyFlags),
				MsgToUser = #pk_GS2U_ConvoyState{convoyFlags = ConvoyFlags, quality = CurConvoyQuality, actorID = PlayerID},
				mapView:broadcast(MsgToUser, Player, 0)
		end
	catch
		_->ok
	end.

%%宠物进入地图
enterMapPet(#mapPet{}=Pet, Player) ->
	try
		etsBaseFunc:insertRecord( getMapPetTable(), Pet ),
		
		%%计算属性
		damageCalculate:calcFinaProperty(Pet#mapPet.id),
		
		Pet2 = etsBaseFunc:readRecord(map:getMapPetTable(), Pet#mapPet.id),
		
		%%添加状态
		mapActorStateFlag:addStateFlag( Pet2#mapPet.id, ?Actor_State_Flag_EnteredMap ),
		
		etsBaseFunc:changeFiled(map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.nonceOutFightPetId, Pet2#mapPet.id),
		
		%%进入地图格子
		mapView:charEnterCell(Pet2, 0),
		
		%%响应宠物进入地图
		petMap:onEnterMap(Pet2),
		
		ok
	catch
		_->ok
	end.

makeLookInfoObject( #mapObjectActor{}=Object )->
	%%Object没有移动
	case Object#mapObjectActor.objType of
		?Object_Type_SkillEffect->
			Param = Object#mapObjectActor.param2#skillCfg.aoeEffect;
		?Object_Type_TRANSPORT->
			Param = Object#mapObjectActor.param1;
		_->
			Param = 0
	end,
	#pk_LookInfoObject{id=Object#mapObjectActor.id,
											  x=Object#mapObjectActor.x,
											  y=Object#mapObjectActor.y,
											  object_data_id=Object#mapObjectActor.object_data_id,
					   						 object_type=Object#mapObjectActor.objType,
					   						 param=Param
											  }.
	
%%Object进入地图
enterMapObject( #mapObjectActor{}=Object )->
	try
		etsBaseFunc:insertRecord( getObjectTable(), Object ),
		
		%%进入地图格子
		mapView:charEnterCell(Object, 0),
		
		scriptManager:onObjectCreateScript( Object),
		objectEvent:onEvent( Object, ?Object_Event_Init, 0),
		
		objectEvent:onEvent( Object, ?Char_Event_Enter_Map, 0),
		ok
	catch
		_->ok
	end.

makeLookInfoPlayer( #mapPlayer{}=Player )->
		MoveTarget = playerMove:getCurMoveTargetPos(Player),
		case MoveTarget of
			{}->MoveTargetX = 0, MoveTargetY = 0;
			_->MoveTargetX = erlang:trunc( MoveTarget#posInfo.x ),
			   MoveTargetY = erlang:trunc( MoveTarget#posInfo.y )
		end,

		RideID = Player#mapPlayer.playerMountView#palyerMountView.mountDataID,
		BattleFriendOrEnemy = 0,	
		
		%%1=faction，2=sex，3-4=camp, 5-8=movestate, 9=battleFriendOrEnemy, 10-14=rideID,15-17=covoyQuality 18=pk 19-23=equip_min_level
		Value_flags = ( ( Player#mapPlayer.faction band 1 ) bor
						( ( Player#mapPlayer.sex band 1 ) bsl 1 ) bor
						( ( Player#mapPlayer.camp band 3 ) bsl 2 ) bor	
						( ( Player#mapPlayer.moveState band 31 ) bsl 4 ) bor
						( ( BattleFriendOrEnemy band 1 ) bsl 8 ) bor
						( ( RideID band 31 ) bsl 9 ) bor
						( ( Player#mapPlayer.covoyQuality band 7 ) bsl 14 ) bor
						( ( Player#mapPlayer.pk_Kill_Punish band 1) bsl 17) bor
						( ( Player#mapPlayer.equipMinLevel band 31) bsl 18)
					  ),

		#pk_LookInfoPlayer{id=Player#mapPlayer.id,
											name=Player#mapPlayer.name,
											level=Player#mapPlayer.level,
						   					lifePercent = erlang:trunc( Player#mapPlayer.life / charDefine:getObjectProperty(Player, ?max_life) * 100 ),
											x=erlang:trunc( Player#mapPlayer.pos#posInfo.x ),
											y=erlang:trunc( Player#mapPlayer.pos#posInfo.y ),
						   					move_target_x=MoveTargetX,
						   					move_target_y=MoveTargetY,
						   					move_dir=Player#mapPlayer.moveDir,
						   					move_speed=playerMove:getMoveSpeed(Player),
											charState=Player#mapPlayer.stateFlag,
						   					value_flags=Value_flags,
											weapon=Player#mapPlayer.weapon,
											coat=Player#mapPlayer.coat,
						   					buffList=buff:makeObjectBuffPackage(Player#mapPlayer.id),
						   					convoyFlags=Player#mapPlayer.convoyFlags,
											guild_id=Player#mapPlayer.guildID,
						   					guild_name=Player#mapPlayer.guildName,
						   					guild_rank=Player#mapPlayer.guildRank,
						   					vip=Player#mapPlayer.vipLevel
											}.

%%地图player移动更新计时器
onMapPlayerMoveTimer()->
	Now = erlang:now(),
	case get("PlayerMoveUpdateTime") of
		undefined->
			put("PlayerMoveUpdateTime", Now),
			TimeDt = 0;
		FrontTime ->
			TimeDt = timer:now_diff(Now, FrontTime)/(1000*1000),
			put("PlayerMoveUpdateTime", Now)
	end,
	
	%% 	Q = ets:fun2ms( fun(#mapPlayer{id=_,moveState=MoveState} = Record ) when ( (MoveState bsr 2)/=?Object_MoveState_Stand ) -> Record end),
%% 	PlayerList = ets:select(getMapPlayerTable(), Q),
%% 	MyFunc = fun( Record )->
%% 					 playerMove:moveUpdate( Record, TimeDt )
%% 			 end,
%% 	lists:foreach( MyFunc, PlayerList ),

	MyFunc1 = fun( Record,_AccIn )->
					 case (Record#mapPlayer.moveState bsr 2) of
						 ?Object_MoveState_Stand->{};
						 _->
							playerMove:moveUpdate( Record, TimeDt ),
							{}
					 end
			 end,
	ets:foldl(MyFunc1, {}, getMapPlayerTable()),
	ok.

%%地图Actor移动跟新计时器
onMapActorMoveTimer()->
	Now = erlang:now(),
	case get("MoveUpdateTime") of
		undefined->
			put("MoveUpdateTime", Now),
			TimeDt = 0;
		FrontTime ->
			TimeDt = timer:now_diff(Now, FrontTime)/(1000*1000),
			put("MoveUpdateTime", Now)
	end,
	
%% 	Q2 = ets:fun2ms( fun(#mapMonster{id=_,moveState=MoveState} = Record ) when ( MoveState/=?Object_MoveState_Stand ) -> Record end),
%% 	MonsterList = ets:select(getMapMonsterTable(), Q2),
%% 	MyFunc2 = fun( Record )->
%% 					 monsterMove:moveUpdate( Record, TimeDt )
%% 			  end,
%% 	lists:foreach( MyFunc2, MonsterList ),
	
	MyFunc2 = fun( Record,_AccIn )->
					 case Record#mapMonster.moveState of
						 ?Object_MoveState_Stand->{};
						 _->
							monsterMove:moveUpdate( Record, TimeDt ),
							{}
					 end
			 end,
	ets:foldl(MyFunc2, {}, getMapMonsterTable()),
	
	
%% 	Q3 = ets:fun2ms( fun(#mapPet{id=_, moveState=MoveState} = Record) when (MoveState/=?Object_MoveState_Stand) -> Record end ),
%% 	PetList = ets:select(getMapPetTable(), Q3 ),
%% 	MyFunc3 = fun(Record) ->
%% 					  petMove:moveUpdate(Record, TimeDt)
%% 			  end,
%% 	lists:foreach( MyFunc3, PetList ),
	
	MyFunc3 = fun( Record,_AccIn )->
					 case Record#mapPet.moveState of
						 ?Object_MoveState_Stand->{};
						 _->
							petMove:moveUpdate( Record, TimeDt ),
							{}
					 end
			 end,
	ets:foldl(MyFunc3, {}, getMapPetTable()),
	
	ok.

%%地图MonsterAI跟新计时器
onMapMonsterAITimer()->
	Now = erlang:now(),
	
%% 	Q = ets:fun2ms( fun(#mapMonster{id=_,moveState=_, isSleeping=IsSleeping} = Record ) when ( IsSleeping =:= 0 ) -> Record end),
%% 	MonsterList = ets:select(getMapMonsterTable(), Q),
%% 	MyFunc = fun( Record )->
%% 					 monster:onHeart( Record, Now )
%% 			 end,
%% 	lists:foreach( MyFunc, MonsterList ),
	
	MyFunc1 = fun( Record,_AccIn )->
					 case Record#mapMonster.isSleeping of
						 0->
							monster:onHeart( Record, Now ),
							{};
						 _->
							{}
					 end
			 end,
	ets:foldl(MyFunc1, {}, getMapMonsterTable()),
	
	
%% 	Q2 = ets:fun2ms( fun(#mapPet{} = Record ) -> Record end),
%% 	PetList = ets:select(getMapPetTable(), Q2),
%% 	MyFunc2 = fun( Record )->
%% 					 petMap:onHeart(Record, Now)
%% 			 end,
%% 	lists:foreach( MyFunc2, PetList ),
	
	MyFunc2 = fun( Record,_AccIn )->
					 petMap:onHeart(Record, Now)
			 end,
	ets:foldl(MyFunc2, {}, getMapPetTable()),
	
	ok.

%%移除物件
despellObject( ObjectID, _DelayTime )->
	try
		ObjType = getObjectID_TypeID( ObjectID ),
		Object = getMapObjectByID( ObjectID ),
		case Object of
			{}->throw(-1);
			_->ok
		end,
		
		%%地图响应有物件移除
		onObjectExited( Object ),

		%%物件响应从地图移除了
		case ObjType of
			?Object_Type_Player->
				playerMap:onExitedMap( Object ),
				ok;
			?Object_Type_Npc->
				npc:onExitedMap( Object ),
				ok;
			?Object_Type_Monster->
				monster:onExitedMap( Object ),
				ok;
			?Object_Type_Pet->
				petMap:onExitedMap(Object),
				ok;
			?Object_Type_Object->
				objectActor:onExitedMap(Object),
				ok;
			_->ok
		end,
		ok
	catch
		_->ok
	end.

%%事件响应，有物件从地图中消失
onObjectExited( Object )->
	try
		objectEvent:onEvent( Object, ?Char_Event_Leave_Map, 0),
		objectEvent:onObjectDestroy(Object),
		
		%%离开格子
		mapView:charLeaveCell(Object, 0),

		ok
	catch
		_->ok
	end.

%%事件响应，有物件在地图中死亡
onObjectDead( ObjType, Object, Killer )->
	try
		MapCfg = map:getMapCfg(),
		case MapCfg#mapCfg.type of
			?Map_Type_Normal_Copy->
				case ObjType of
					?Object_Type_Monster->
						%%怪物击杀数+1，用于副本结算
						put( "KilledMonsterCount", get("KilledMonsterCount")+1 ),
						sendCopyMapProgressToPlayer();
					_->ok
				end;
			_->ok
		end,
		
		objectEvent:onEvent( Object, ?Char_Event_Dead, Killer),
		objectEvent:onEvent( ?MODULE:getMapObject(), ?Map_Event_Char_Dead, {Object,Killer} ),
		ok
	catch
		_->ok
	end.

%%返回一个地图战斗ID
getMapCombatID()->
	CurID = get( "MapCombatID_Cur" ) + 1,
	MaxID = get( "MapCombatID_Begin" ) + ?Monster_CombatID,
	case CurID > MaxID of
		true->
			put( "MapCombatID_Cur", get( "MapCombatID_Begin" ) ),
			get( "MapCombatID_Begin" );
		false->
			put( "MapCombatID_Cur", CurID ),
			CurID
	end.


%%向组队进程发送一个玩家最新的坐标信息
sendplayerPosInfoToteamMoulde()->
	Rule = ets:fun2ms(fun(#mapPlayer{_ = '_', teamDataInfo=TeamDataInfo} = Record) 
						   when( TeamDataInfo#teamData.teamID =/= 0 ) -> Record end),
 	MapPlayerTable = ets:select(map:getMapPlayerTable(), Rule),
	MyFunc = fun( Player )->
					 		TeamMemberMapInfo = #teamMemberMapInfo{ playerID = Player#mapPlayer.id,
								playerName = Player#mapPlayer.name, 
								level = Player#mapPlayer.level, 
								camp = Player#mapPlayer.camp, 
								fation = Player#mapPlayer.faction, 
								sex = Player#mapPlayer.sex,
								x = Player#mapPlayer.pos#posInfo.x, 
								y = Player#mapPlayer.pos#posInfo.y, 
								map_data_id = map:getMapDataID(), 
								mapID = map:getMapID(), 
								mapPID = self(), 
								life_percent=charDefine:getObjectLifePercent(Player),
								playerPID = Player#mapPlayer.pid },

							%%?DEBUG_OUT( "TeamMemberMapInfo [~p]", [TeamMemberMapInfo] ),

							teamThread ! { mapMsg_PlayerMapInfo, Player#mapPlayer.teamDataInfo#teamData.teamID, TeamMemberMapInfo }
			 end,
	
	lists:foreach(MyFunc, MapPlayerTable),
	ok.

on_mapPlayerReadyEnterTimer()->
	Now = common:timestamp(),
	Q = ets:fun2ms( fun(#readyEnterMap{playerID=PlayerID,timeOut=TimeOut} = Record ) when ( Now >= TimeOut )-> PlayerID end),
	List = ets:select(?MODULE:getReadyEnterPlayerTable(), Q),
	
	MyFunc = fun( Record )->
					 etsBaseFunc:deleteRecord( ?MODULE:getReadyEnterPlayerTable(), Record )
			 end,
	lists:foreach( MyFunc, List).

on_mapLifeRecoverTimer() ->
	FunPlayer = fun(Player) ->
						damageCalculate:onUpdateLifeRecover(Player)
				end,
	etsBaseFunc:etsFor(map:getMapPlayerTable(), FunPlayer),
	
	FunMonster = fun(Monster) ->
						 damageCalculate:onUpdateLifeRecover(Monster)
				 end,
	etsBaseFunc:etsFor(map:getMapMonsterTable(), FunMonster),
	
	FunPet = fun(Pet)->
					 damageCalculate:onUpdateLifeRecover(Pet)
			 end,
	etsBaseFunc:etsFor(map:getMapPetTable(), FunPet),
	ok.

on_mapBuffUpdateTimer()->
	Now = erlang:now(),
	
%% 	Q = ets:fun2ms( fun(#objectBuff{id=_, dataList=BuffList} = Record ) when ( BuffList /= [] )-> Record end),
%% 	List = ets:select(map:getObjectBuffTable(), Q),
%% 	
%% 	MyFunc = fun( Record )->
%% 					 buff:onUpdateBuff(Record, Now)
%% 			 end,
%% 	lists:foreach( MyFunc, List).

	MyFunc = fun( Record,_AccIn )->
					 case Record#objectBuff.dataList of
						 []->{};
						 _->
							buff:onUpdateBuff(Record, Now),
							{}
					 end
			 end,
	ets:foldl(MyFunc, {}, getObjectBuffTable()).


%%玩家声望发生变化
on_mapPlayerCreditChange(PlayerID,NewCredit)->
	MapObj=map:getMapObjectByID(PlayerID),
	objectEvent:onEvent(MapObj,?Player_Event_Level_Credit, NewCredit),
	ObjType = getObjectID_TypeID( PlayerID ),
	case ObjType of
		?Object_Type_Player->
			etsBaseFunc:changeFiled(getMapPlayerTable(), PlayerID, #mapPlayer.credit, NewCredit);
		_->
			ok
	end,
	ok.

%%定时检测副本地图中无玩家，超时结束副本
on_mapNoPlayerTimer()->
	try
		OnlinePlayers = ets:info( map:getMapPlayerTable(), size ),
		case OnlinePlayers > 0 of
			true->
				erlang:send_after( ?Map_NoPlayer_Timer,self(), {mapNoPlayerTimer} );
			false->
				LastNoPlayerTime = get( "LastNoPlayerTime" ),
				Now = common:timestamp(),
				TimeDist = Now - LastNoPlayerTime,
				
				case TimeDist >= get( "Map_NoPlayer_Time" ) of
					true->%%超时了，销毁地图
						?DEBUG_OUT( "map[~p] on_mapNoPlayerTimer quit", [map:getMapLog()] ),
						self() ! { quit },
						ok;
					false->erlang:send_after( ?Map_NoPlayer_Timer,self(), {mapNoPlayerTimer} )
				end
		end,

		ok
	catch
		_->ok
	end.

%%设置无人地图销毁时间
setCopyMapNoPlayerDetroyTime( TimeSeconds )->
	put( "Map_NoPlayer_Time", TimeSeconds ).

worldBossDie( _Object, _EventParam, _RegParam )->

	?DEBUG_OUT( " map worldBossDie"),
	%%发公告
	systemMessage:sendSysMsgToAllPlayer(?BroadcastAfterWorldBoss),
	put("WorldBossID",-1),
	removeSmallMonsterofBossActive(),
	%%发消息给伤害排行奖励物品
	worldBossManagerPID!{worldBossDieMsg,self()}.

%%worldBossSmallMonsterDie( Object, _EventParam, _RegParam )->
%%	case get("MapLeftSmallMonsterNum") >0 of
%%		false->
%%			ok;
%%		_->
%%			BossInfo=worldBoss:getBossInfo(),
%%			RecomeOutTime=BossInfo#worldBossCfg.refreshtime*1000,
%%			erlang:send_after(RecomeOutTime,self(),{worldBossSmallMonsterReborn,Object})
%%	end,
%%ok.

rebornworldBossSmallMonser(Object)->
	%%?DEBUG_OUT( "rebornworldBossSmallMonser enter leftmonsternum ~p SmallMonsterList size=~p",
	%%			[ get("MapLeftSmallMonsterNum"),length( get("SmallMonsterList") ) ]),
	case get("MapLeftSmallMonsterNum") >0 of
		false->
			ok;
		_->
			%%?DEBUG_OUT( "rebornworldBossSmallMonser reborn"),
			%%重生
			Monster = monster:createMonster( Object#mapMonster.spawnData ),
			map:enterMapMonster(Monster),
			put("SmallMonsterList",[Monster#mapMonster.id]++get("SmallMonsterList")),
			%%注册小怪的死亡事件，死亡之痕要重生
			%%?DEBUG_OUT( "rebornworldBossSmallMonser "),
			%%objectEvent:registerObjectEvent(Monster, ?Char_Event_Dead, 
			%%									?Object_Type_Monster, Monster#mapMonster.monster_data_id,
			%%									 map, worldBossSmallMonsterDie, 0),
			ok
	end,
	ok.


removeSmallMonsterofBossActive()->
	%%刷boss，同时把小怪都杀掉
	FunRemoveSmallMonster=
		fun(MonsterID)->
			Monster=map:getMapObjectByID( MonsterID ),
			case Monster of
				{}->
					ok;
				_->
					map:despellObject(MonsterID,0)
			end
		end,
		SmallMonsterList=get("SmallMonsterList"),
		lists:foreach(FunRemoveSmallMonster, SmallMonsterList),
		put("SmallMonsterList",[]),
ok.

on_worldBossActiveBegin()->
	case length( get("SmallMonsterList") )>0 of
		true->
			%%刷过小怪了
			ok;
		_->
			put("SmallMonsterList",[]),
			%%先刷一波小怪
			BossInfo=worldBoss:getBossInfo(),
			RefreshWorldBossMonster=
				fun(N)->
						ComeoutPos=lists:nth(N, BossInfo#worldBossCfg.resfreshxy1),
						RealPosX=ComeoutPos#posInfo.x,
						RealPosY=ComeoutPos#posInfo.y,
						MapSpawn = #mapSpawn{
						id = 0,
						 mapId=map:getMapDataID(),
						 type=?Object_Type_Monster,
						 typeId = BossInfo#worldBossCfg.incident1,
						 x = RealPosX,
						 y = RealPosY,
						 param = 0,
						 isExist = true
						},
						Monster = monster:createMonster( MapSpawn ),
						map:enterMapMonster(Monster),
						put( "SmallMonsterList",[Monster#mapMonster.id]++get("SmallMonsterList") ),
						%%注册小怪的死亡事件，死亡之痕要重生
						%%objectEvent:registerObjectEvent(Monster, ?Char_Event_Dead, 
						%%									?Object_Type_Monster, Monster#mapMonster.monster_data_id,
						%%									 map, worldBossSmallMonsterDie, 0),
						ok
				end,
			%%有多少个刷怪点，刷了多少个怪
			common:for(1, length( BossInfo#worldBossCfg.resfreshxy1 ), RefreshWorldBossMonster),
			%%设置需要击杀的剩余小怪数量
			?DEBUG_OUT( "MapLeftSmallMonsterNum =~p",[BossInfo#worldBossCfg.incnum1]),
			put("MapLeftSmallMonsterNum",BossInfo#worldBossCfg.incnum1),
			
			%%配置的小怪数量为0，那么不刷小怪，直接下一个阶段
			case get("MapLeftSmallMonsterNum")=:=0 of
				true->
					worldBossManagerPID!{firstStageAllMonsterKill,self()};
				_->
					ok
			end,
			copyMap_8:sendFirstStageLeftSmallMonsterNum(BossInfo#worldBossCfg.incnum1),
			put("WorldBossID",0)
	end,
ok.

on_worldBossComeout()->
	?DEBUG_OUT( "worldBossComeout"),
	BossInfo=worldBoss:getBossInfo(),
	MapSpawn = #mapSpawn{
				id = 0,
				 mapId=map:getMapDataID(),
				 type=?Object_Type_Monster,
				 typeId = BossInfo#worldBossCfg.bossid,
				 x = BossInfo#worldBossCfg.posx,
				 y = BossInfo#worldBossCfg.posy,
				 param = 0,
				 isExist = true
				},

	Monster = monster:createMonster( MapSpawn ),
	map:enterMapMonster(Monster),
	worldBossManagerPID!{activeOneBoss,self()},
	objectEvent:registerObjectEvent(Monster, ?Char_Event_Dead, 
											?Object_Type_Monster, Monster#mapMonster.monster_data_id,
											 map, worldBossDie, 0),
	%% 发公告告诉地图玩家
	MapCfg = getMapCfg(),
	BroadcastText = io_lib:format(?BroadcastForWorldBossComeout, [MapCfg#mapCfg.mapName]),
	map:senMsgToAllMapPlayer(#pk_SysMessage{type=?SYSTEM_MESSAGE_ANNOUNCE,text = BroadcastText}),
	%%objectEvent:registerObjectEvent(Monster, ?Char_Event_OnDamage, 
	%%										?Object_Type_Monster, Monster#mapMonster.monster_data_id,
	%%										 map, worldBossHarmed, 0),
	%%charDefine:changeSetLife( Monster, BossBlood, false ),%%把血量改成活动保存的血量
	
	put("WorldBossID",Monster#mapMonster.id),%%设置boss 没死
	put("MapLeftSmallMonsterNum",0),
	copyMap_8:sendFirstStageLeftSmallMonsterNum(0),
	removeSmallMonsterofBossActive(),
	%%boss 的伤害不立即发往统计
	ok.

on_worldBossAddExp()->
			case  get("WorldBossID")>=0 of
				false->
					ok;
				_->
					Q = ets:fun2ms( fun(Record ) -> Record end),
					PlayerList = ets:select(getMapPlayerTable(), Q),
					lists:foreach(fun(Record)-> 
									CanNotState = ( ?Actor_State_Flag_Dead ) ,
									case ( mapActorStateFlag:isStateFlag(Record#mapPlayer.id, CanNotState ) ) of
										true->
											ok;
										false->
											worldBoss:worldBossGaveExp(Record,erlang:self())
									end
								end, PlayerList),
					ok
				end.

on_killWorldBoss(_MonsterCfgID)->
	Monster=map:getMapObjectByID( get("WorldBossID") ),
	case  Monster of
		{} ->ok;
		Monster ->
			copyMap_8:copyMap_8__Boss_Dead_Event(Monster, 0, 0),
			map:despellObject( Monster#mapMonster.id, 0 )
	end,
	put("WorldBossID",-1),
	removeSmallMonsterofBossActive(),
	copyMap_8:sendFirstStageLeftSmallMonsterNum(0),
	ok.%%设置boss 死了

%%发送副本进度给玩家
sendCopyMapProgressToPlayer()->
	case getMaxMonsterCount() of
		0->Radio = 100;
		_->
			Radio = 100-erlang:trunc(map:getKilledMonsterCount() / getMaxMonsterCount()*100)
	end,
	Msg = #pk_GS2U_CopyProgressUpdate{progress=Radio},
	senMsgToAllMapPlayer(Msg).

%%副本结算
onCopyMapSettleAccounts()->
	try
		MapCfg = getMapCfg(),
		case MapCfg of
			{}->throw(-1);
			_->ok
		end,
		
		case MapCfg#mapCfg.type of
			?Map_Type_Normal_Copy->ok;
			_->throw(-1)
		end,
		
		CopyMapSACfg = etsBaseFunc:readRecord(globalSetup:getGlobalCopyMapSATable(), MapCfg#mapCfg.mapID),
		case CopyMapSACfg of
			{}->throw(-1);
			_->ok
		end,
		
		CostTime = erlang:trunc( timer:now_diff(erlang:now(), map:getMapInitTime()) / 1000000),
		case CostTime =< CopyMapSACfg#copyMapSettleAccounts.time4 of
			true->
				Level=4;
			_->
				case CostTime =< CopyMapSACfg#copyMapSettleAccounts.time3 of
					true->
						Level=3;
					_->
						case CostTime =< CopyMapSACfg#copyMapSettleAccounts.time2 of
							true->
								Level=2;
							_->
								Level=1
						end
				end
		end,
		try
			Fun = fun(Monster)->
						  case map:isObjectDead(Monster) of
							  false->throw(0);
							  _->ok
						  end
				  end,
			etsBaseFunc:etsFor(map:getMapMonsterTable(), Fun),
			throw(1)
		catch
			IsPerfect->
				case IsPerfect of
					0->
						case Level of
							4->Money = CopyMapSACfg#copyMapSettleAccounts.money4,Exp = CopyMapSACfg#copyMapSettleAccounts.exp4;
							3->Money = CopyMapSACfg#copyMapSettleAccounts.money3,Exp = CopyMapSACfg#copyMapSettleAccounts.exp3;
							2->Money = CopyMapSACfg#copyMapSettleAccounts.money2,Exp = CopyMapSACfg#copyMapSettleAccounts.exp2;
							1->Money = CopyMapSACfg#copyMapSettleAccounts.money1,Exp = CopyMapSACfg#copyMapSettleAccounts.exp1
						end;
					_->
						case Level of
							4->Money = CopyMapSACfg#copyMapSettleAccounts.p_money4,Exp = CopyMapSACfg#copyMapSettleAccounts.p_exp4;
							3->Money = CopyMapSACfg#copyMapSettleAccounts.p_money3,Exp = CopyMapSACfg#copyMapSettleAccounts.p_exp3;
							2->Money = CopyMapSACfg#copyMapSettleAccounts.p_money2,Exp = CopyMapSACfg#copyMapSettleAccounts.p_exp2;
							1->Money = CopyMapSACfg#copyMapSettleAccounts.p_money1,Exp = CopyMapSACfg#copyMapSettleAccounts.p_exp1
						end
				end,
			
				FinishRate2 = erlang:trunc(map:getKilledMonsterCount() / map:getMaxMonsterCount()*100),

				case FinishRate2 > 100 of
					true->FinishRate=100;
					_->FinishRate = FinishRate2
				end,
				KilledCount = map:getKilledMonsterCount(),
			
				%% 副本 LOG  				
				ParamLog = #copy_param{	mapId = MapCfg#mapCfg.mapID,	finishRate = FinishRate, costTime = CostTime,level= Level, isPerfect=IsPerfect },	

				%%如果是副本并且有活跃次数判定
				case MapCfg#mapCfg.type =:= ?Map_Type_Normal_Copy andalso MapCfg#mapCfg.playerActiveEnter_Times > 0 of
					true->
						IsActive = true;
					_->IsActive = false
				end,
				%%发放奖励
				FuncSend=fun(Player)->
										case IsActive of
											true->
												case lists:keyfind(map:getMapDataID(), #playerMapCDInfo.map_data_id, Player#mapPlayer.mapCDInfoList) of
													false->
														ActiveRatio=10000;
													MapCDInfo->
														case MapCDInfo#playerMapCDInfo.sys_active_count < 0 of
															true->
																case MapCDInfo#playerMapCDInfo.player_active_count < 0 of
																	true->
																		ActiveRatio = globalSetup:getGlobalSetupValue(#globalSetup.copyMap_NotActiveRatio);
																	_->
																		ActiveRatio = 10000
																end;
															_->
																ActiveRatio = 10000
														end
												end;
											_->ActiveRatio=10000
										end,

										RealExp = erlang:trunc(Exp*ActiveRatio/10000),
										RealMoney = erlang:trunc(Money*ActiveRatio/10000),

										Msg = #pk_GS2U_CopyMapSAData{
															map_id=MapCfg#mapCfg.mapID,
															killed_count=KilledCount,
															finish_rate=FinishRate,
															cost_time=CostTime,
															exp=RealExp,
															money=RealMoney,
															level=Level,
															is_perfect=IsPerfect},

										player:sendToPlayerByPID(Player#mapPlayer.pid, Msg),

										Player#mapPlayer.pid ! {  addEXP, RealExp, 0 },
										Player#mapPlayer.pid ! { addMoney, RealMoney, true, ?Money_Change_CopymapFinish, #token_param{changetype = ?Money_Change_CopymapFinish}},
										Player#mapPlayer.pid ! {  writelog, ?EVENT_PALYER_TRAD, ParamLog },
										%%日常检测
										Player#mapPlayer.pid ! {  dailyCheck, ?DailyType_CopyMap, MapCfg#mapCfg.mapID }
								end,
				etsBaseFunc:etsFor(map:getMapPlayerTable(), FuncSend)
		end

	catch
		_->ok
end.

onBanPlayerRelive(Player,BanTime)->
	variant:setPlayerVarValueFromMap(Player, ?PlayerVariant_Index_Ban_Relive_M, common:getNowSeconds()+BanTime),
	ok.


