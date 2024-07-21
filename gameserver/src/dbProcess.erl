%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(dbProcess).

%%
%% Include files
%%
-include("mysql.hrl").
-include("db.hrl").
-include("gamedatadb.hrl").
-include("playerDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("itemDefine.hrl").
-include("mapDefine.hrl").
-include("taskDefine.hrl").
-include("friendDefine.hrl").
-include("condition_compile.hrl").

%% add by wenziyong for gen server
-behaviour(gen_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).



%%
%% Exported Functions
%%
-compile(export_all).

start_link() ->
	gen_server:start_link({local,dbProcess_PID},?MODULE, [], [{timeout,2*?Start_Link_TimeOut_ms}]).



init([]) ->
	db:init(),
	%% 为了实现mysql是可重入的，下一步将register操作加到mysql.erl
	%mySqlProcess:register_prepared_stats(),
	%logdbProcess:register_prepared_stats(),
	
	
	setAllPlayerOnline( 0 ),
    {ok, {}}.


handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.



terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.



setAllPlayerOnline( SetOnline )->
	{ _SuccOrError, _Result } = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"UPDATE player_gamedata SET isOnline = "++integer_to_list(SetOnline),true ),

	ok.


handle_info(Info, StateData)->	
	put( "recvUserDB", true ),

	try
	case Info of
		%% modify for insert mysql directly
		%{getPlayerList, FromPID, UserID }->
		%	on_getPlayerList( FromPID, UserID ),
		%	ok;
		%{createPlayer, FromPID, UserID, Msg}->
		%	on_createPlayer(FromPID, UserID, Msg);
		%{deletePlayer, FromPID, UserID, Msg}->
		%	on_deletePlayer(FromPID, UserID, Msg);
		%{selPlayer, FromPID, UserID, Msg}->
		%	on_selPlayer(FromPID, UserID, Msg);
		%{savePlayer, PlayerInfo }->
		%	on_savePlayer(PlayerInfo);
		%{ queryPlayerNameEixt, FromPID, Msg }->
		%	on_queryPlayerNameEixt( FromPID, Msg );
		%{ savePlayerAll, PlayerOnlineDBData }->
		%	on_savePlayerAll( PlayerOnlineDBData );
		%{ savePlayerItem, ItemDBData }->
		%	on_savePlayerItem( ItemDBData );
		%{ deletePlayerItem, ItemDBID }->
		%	on_deletePlayerItem( ItemDBID );
		%{ savePlayerEquip, PlayerEquip }->
		%	on_savePlayerEquip( PlayerEquip );
		%{ savePlayerEquipEnchance, PlayerEquipEnchance }->
		%	on_savePlayerEquipEnchance( PlayerEquipEnchance );
		%{ playeroffline, PlayerID }->
		%	on_playeroffline( PlayerID );

		{ savePlayerMapDBInfo, SaveInfo }->
			mySqlProcess:updatePlayerGamedataByPlayerMapDBInfo(SaveInfo);
		{ savePlayerSkillCDInfo, PlayerID, SkillList }->
			on_savePlayerSkillCDInfo( PlayerID, SkillList );
		
		%{ checkPlayerGuildID, FromPID, PlayerID, GuildID, TargetPlayerID, IsSingleProcess}->
		%	on_checkPlayerGuildID(FromPID, PlayerID, GuildID, TargetPlayerID, IsSingleProcess);

		%{ kickoutPlayer, FromPID, PlayerID, GuildID, TargetPlayerID}->
		%	on_kickoutPlayer(FromPID, PlayerID, GuildID, TargetPlayerID);
		%{ playerSaveTask, PlayerID, AcceptedTaskList, CompletedTaskIDList }->
		%	on_playerSaveTask( PlayerID, AcceptedTaskList, CompletedTaskIDList );
		%{ playerSaveFriend, FriendList}->
		%	on_playerSaveFriendList(FriendList);
		%{ playerDelFriend, F_id} ->
		%	on_delete_Friend(F_id);
		%{ deleteRecord, Table, KeyIndex }->
		%	on_deleteRecord(Table, KeyIndex);

		%% map process use saveObjectBuffData
		{ saveObjectBuffData, ObjectBuffData }->
			on_saveObjectBuffData(ObjectBuffData);
		
		%{ getPetBuffData, Pid, Pet, PetCfg }->
		%	on_getPetBuffData(Pid, Pet, PetCfg);
		
		%% this msg from loginserver
		{ ls_LS2GS_QueryUserMaxLevel, FromPID, Msg }->
			on_ls_LS2GS_QueryUserMaxLevel( FromPID, Msg );
		{quit}->
			put( "recvUserDB", false );
		_->?LOG_OUT( "recvUserDB error" )
	end,
	case get( "recvUserDB" )of
		true->{noreply, StateData};
		false->{stop, normal, StateData}
	end
	
	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[?MODULE,_Why, erlang:get_stacktrace()] ),	

			{noreply, StateData}
	end.



%% modify for insert mysql directly
%on_getPlayerList( FromPID, UserID )->
on_getPlayerList( UserID )->
	try	
		
		%% add by wenziyong, need inprove, just select the useful fields
        {_SuccOrErr,PlayerList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"select * from player_gamedata 
					where userId = "++integer_to_list(UserID)++" and isDelete=0",true),
  	    PlayerGamedataList = lists:map(fun(List) -> mySqlProcess:player_gamedata_list_to_record(List) end, PlayerList1),

		MyFunc = fun( Record )->
						 #pk_UserPlayerData{
											   playerID = Record#player_gamedata.id,
											   name=Record#player_gamedata.name,
											   level=Record#player_gamedata.level,
											   classValue=Record#player_gamedata.camp,
											   sex=Record#player_gamedata.sex,
											   faction=Record#player_gamedata.faction
											   }
				 end,
		lists:map( MyFunc, PlayerGamedataList )
	catch
		_->
			?ERROR_OUT("on_getPlayerList exception -----"),
			[]
	end.

on_createPlayer(UserID, Msg)->
	try		
%% 		{_SuccOrErr,PlayerList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"select * from player_gamedata where userId = "++integer_to_list(UserID),true),
%%  		PlayerGamedataList = lists:map(fun(List) -> mySqlProcess:player_gamedata_list_to_record(List) end, PlayerList1),
%% 		PlayerCount = length( PlayerGamedataList ),
		PlayerCount = mySqlProcess:getPlayerCntByUserId(UserID),
		case PlayerCount >= ?MaxUserPlayerCount of
			true->
				put("createPlayerResult",{?CreatePlayer_Result_Fail_Full, {} }),
				throw( {return, -1} );
			false->ok
		end,
		
		Name = Msg#pk_U2GS_RequestCreatePlayer.name,
		NameLen = string:len( Name ),
		case ( NameLen < ?Min_CreatePlayerName_Len ) or ( NameLen > ?Max_CreatePlayerName_Len*3 ) of
			true->
				put("createPlayerResult",{?CreatePlayer_Result_Fail_Name_Unvalid, {} }),
				throw( {return, -2} );
			false->ok				
		end,
		case forbidden:checkForbidden(Name) of
			true->
				put("createPlayerResult",{?CreatePlayer_Result_Fail_Name_Forbidden, {} }),
				throw( {return, -3} );
			false->ok
		end,

		%% -> 0 or id  (0: mean not exist this player)
		case mySqlProcess:isPlayerExistByNameIncludeWithDeleteFlagPlayer(  Name ) of
			0 -> ok;
			_-> put("createPlayerResult",{?CreatePlayer_Result_Fail_Name_Exist, {} }),
				throw( {return, -4} )
		end,
		
		PlayerBaseCfg = player:getCurPlayerBaseCfg( 1, Msg#pk_U2GS_RequestCreatePlayer.classValue ),
		case PlayerBaseCfg of
			{}->
				put("createPlayerResult",{?CreatePlayer_Result_Fail_Name_Unvalid, {} }),
				throw( {return, -5} );
			_->ok				
		end,
		
		case Msg#pk_U2GS_RequestCreatePlayer.camp of
			?CAMP_TIANJI->
				MapDataID = 1,
				PosX = 2230,
				PosY = 1650;
			?CAMP_XUANZONG->
				MapDataID = 9,
				PosX = 3340,
				PosY = 2310;
			_->
				MapDataID = 1,
				PosX = 2230,
				PosY = 1650,
				put("createPlayerResult",{?CreatePlayer_Result_Fail_Full, {} }),
				throw( {return, -6} )
		end,
		
		Now = common:timestamp(),
		
		
		GameSetMenuInitValue = #pk_GSWithU_GameSetMenu_3{joinTeamOnoff=1, inviteGuildOnoff=1, tradeOnoff=1, 
												   applicateFriendOnoff=1, singleKeyOperateOnoff=1, musicPercent=100, 
												   soundEffectPercent=100, shieldEnermyCampPlayer=0, 
												   shieldSelfCampPlayer=0, shieldOthersPet=0, shieldOthersName=0,
												   shieldSkillEffect=0,dispPlayerLimit=100,
												   shieldOthersSoundEff=0,noAttackGuildMate=1,reserve1=0,reserve2=0},



		ReasureBowlData = reasureBowl:initReasureBowlData(),
		%%TaskSpecialData = #taskSpecialData{randomDailyID=0,randDailyFinishNum=0,randDailygroudID=0,randDailyProcess=0,
		%%								   reputationtaskID=0,reputationprocess=0,gatherFinshedTime=0},
		TaskSpecialData=task:taskSpecialInit(),
		%% use local time for lastOfflineTime
		Player = #player{id=db:memKeyIndex(player_gamedata), % persistent 
							 name=Name, userId=UserID,
			 				 map_data_id=MapDataID, mapId=1, mapPID=0,x=PosX,y=PosY,
							 level=1,camp=Msg#pk_U2GS_RequestCreatePlayer.classValue, faction=Msg#pk_U2GS_RequestCreatePlayer.camp, sex=Msg#pk_U2GS_RequestCreatePlayer.sex, crossServerHonor=0, unionContribute=0, 
							 competMoney=0, weekCompet=0, battleHonor=0, aura=0, charm=0, vip=0, maxEnabledBagCells=?PlayerCreateEnableBagCells,
							 maxEnabledStorageBagCells=?PlayerCreateEnableStorageBagCells,storageBagPassWord="",unlockTimes=0,
							 money=0, moneyBinded=0, gold=0, goldBinded=0, ticket=0, guildContribute=0, honor=0, credit=0,
							 life=PlayerBaseCfg#playerBaseCfg.max_life, exp=0,
						 	 lastOnlineTime=Now, lastOfflineTime=common:getNowSeconds(), isOnline=0, createTime=Now, stateFlag=0, guildID=0,
			 				 conBankLastFindTime=0, chatLastSpeakTime=0, outFightPet=0, mapCDInfoList=[],pK_Kill_Value=0,
						     pK_Kill_OpenTime=0,pk_Kill_Punish=0,bloodPoolLife=0,gmLevel=0, petBloodPoolLife=0,fightingCapacity=0,fightingCapacityTop=0,
						     platSendItemBits = <<>>,gameSetMenu=GameSetMenuInitValue,rechargeAmmount=0,varArray=array:new(),forbidChatFlag=0,
						 	 protectPwd="",reasureBowlData=ReasureBowlData,taskSpecialData=TaskSpecialData,exp15Add=0,exp20Add=0,exp30Add=0,
						 	 goldPassWord="",goldPassWordUnlockTimes=0,vipLevel=0,vipTimeExpire=0,vipTimeBuy=0
							},
		%%根据世界标志位修改pk保护
		
		PlayerMountInfo = [],
		PlayerItemCDInfo = [],
		PlayerItem_DailyCountInfo = [],
		
		{ _SuccOrError, _Result } = mySqlProcess:insertPlayerGamedata(Player,PlayerMountInfo,PlayerItemCDInfo,PlayerItem_DailyCountInfo),
		
		PlayerID = Player#player.id,
		

		playerItems:onPlayerCreatedToInitBag( PlayerID ),

		equipProperty:playerEquipEnhanceLevelInit( PlayerID ),
		
			
		%% if test robot with different cloth, please use the following lines
%%  		case ?Is_Debug_version of
%%  			true->equipment:onCreatedPlayerToEquipRandom( PlayerID, Player#player.camp );
%%  			false->equipment:onCreatedPlayerToEquip( PlayerID, Player#player.camp )
%%  		end,
		equipment:onCreatedPlayerToEquip( PlayerID, Player#player.camp ),
		

		Skill = playerSkill:onPlayerCreateSkillInit(PlayerID, Player#player.camp ),

		Shortcut = #shortcut{playerID=PlayerID, index1ID=( (?Short_Skill bsl 24) bor Skill#playerSkill.skillId ), index2ID=0, index3ID=0, index4ID=0, index5ID=0,
						index6ID=0, index7ID=0, index8ID=0, index9ID=0, index10ID=0, index11ID=0, index12ID=0},
		mySqlProcess:insertOrReplaceShortcut(Shortcut,false),
		

		task:onCreatePlayerToAcceptTask( Player ),

		petSealStore:onCreatePlayerSealStore(PlayerID),
		
		%%初始化日常记录
		daily:onPlayerCreatedDailyInit(PlayerID),

		?LOG_OUT( "created player id[~p] name[~p] userid[~p] succ", [PlayerID, Name, UserID] ),
		
		UserPlayerData = #pk_UserPlayerData{
						   playerID = PlayerID,
						   name=Player#player.name,
						   level=Player#player.level,
						   classValue=Player#player.camp,
						   sex=Player#player.sex,
						   faction=Player#player.faction
						   },
		%% modify for insert mysql directly
		{?CreatePlayer_Result_Succ, UserPlayerData }	
		%% modify for insert mysql directly, revoke on_getPlayerList in userHandle:on_createPlayerResult
		%on_getPlayerList( FromPID, UserID ),
		%ok
	catch
		{ return, ReturnCode }->
			?LOG_OUT( "user[~p] on_createPlayer faile ReturnCode[~p] Msg[~p]",
						[netUsers:getCurUserID(), ReturnCode, Msg] ),
			get("createPlayerResult")
	end.

%on_deletePlayer(FromPID, UserID, Msg)->
on_deletePlayer( UserID, Msg)->
	try
		PlayerID = Msg#pk_U2GS_RequestDeletePlayer.playerID,
		PlayerGamedataList = mySqlProcess:get_playerGamedata_list_by_id(PlayerID),
%%      PlayerList = db:matchObject(player, #player{ id=PlayerID, _='_' }),
		PlayerCount = length( PlayerGamedataList ),
		case PlayerCount =:= 1 of
			false->
				%FromPID ! { deletePlayerResult, ?DeletePlayer_Result_Fail, PlayerID },
				put("deletePlayerResult",{?DeletePlayer_Result_Fail, PlayerID }),
				throw( {return, -1} );
			true->ok
		end,
		
		[PlayerGamedata|_] = PlayerGamedataList,
%% 		case Player#player.isOnline =:= 0 of
%% 			false->
%% 				FromPID ! { deletePlayerResult, ?DeletePlayer_Result_Fail, PlayerID },
%% 				throw(-1);
%% 			true->ok
%% 		end,
		
		case UserID =:= PlayerGamedata#player_gamedata.userId of
			false->
				%FromPID ! { deletePlayerResult, ?DeletePlayer_Result_Fail, PlayerID },
				put("deletePlayerResult",{?DeletePlayer_Result_Fail, PlayerID }),
				throw(  {return, -2} );
			true->ok
		end,
		%mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"delete from player_gamedata where id="++integer_to_list(PlayerID),true),
		mySqlProcess:deletePlayerById(PlayerID),
		case PlayerGamedata#player_gamedata.guildID =:= 0 of
			true->ok;
			false->guildProcess_PID ! { msg_U2GS_RequestGuildQuit, 0, PlayerID, PlayerGamedata#player_gamedata.guildID }
		end,
		%%delete item,bag,equip,mail...
		
		?LOG_OUT( "deleted player id[~p]", [PlayerGamedata#player_gamedata.id] ),
		

		{?DeletePlayer_Result_Succ, PlayerID }		
		%on_getPlayerList( FromPID, UserID ),	
		%ok
	catch
		{ return, ReturnCode }->
			?LOG_OUT( "user[~p] on_deletePlayer fail ReturnCode[~p]",
					[UserID, ReturnCode] ),
			get("deletePlayerResult")
	end.



on_selPlayer( UserID, #pk_U2GS_SelPlayerEnterGame{}=Msg  )->
	try
		PlayerID = Msg#pk_U2GS_SelPlayerEnterGame.playerID,	
		PlayerGamedataList = mySqlProcess:get_playerGamedata_list_by_id(PlayerID),
		PlayerCount = length( PlayerGamedataList ),
		case PlayerCount =:= 1 of
			false->
				%FromPID ! { selPlayerResult, ?SelPlayer_Result_PlayerCount_Fail, {} },
				put( "on_selectPlayer_result", ?SelPlayer_Result_PlayerCount_Fail ),
				throw( {return, -1} );
			true->ok
		end,
		
		[PlayerGamedata|_] = PlayerGamedataList,
		Player = dataConv:fillPlayerByplayerGamedata(PlayerGamedata),
		case UserID =:= Player#player.userId of
			false->
				%FromPID ! { selPlayerResult, ?SelPlayer_Result_UserId_Fail, {} },
				put( "on_selectPlayer_result", ?SelPlayer_Result_UserId_Fail ),
				throw( {return, -1} );
			true->ok
		end,
		PlayerMountInfo = PlayerGamedata#player_gamedata.playerMountInfo,
		PlayerItemCDInfo = PlayerGamedata#player_gamedata.playerItemCDInfo,
		PlayerItem_DailyCountInfo = PlayerGamedata#player_gamedata.playerItem_DailyCountInfo,
%% 		case Player#player.isOnline of
%% 			1->
%% 				%FromPID ! { selPlayerResult, ?SelPlayer_Result_Player_IsOnline, {} },
%% 				put( "on_selectPlayer_result", ?SelPlayer_Result_Player_IsOnline ),
%% 				throw(-1);
%% 			0->ok
%% 		end,
	
		Now = common:timestamp(),
		
		Player2 = setelement( #player.lastOnlineTime, Player, Now ),
		case Player2#player.exp15Add > 0 of
			true->SetExp15Add = Player2#player.exp15Add + Now - Player2#player.lastOfflineTime;
			false->SetExp15Add = 0
		end,
		case Player2#player.exp20Add > 0 of
			true->SetExp20Add = Player2#player.exp20Add + Now - Player2#player.lastOfflineTime;
			false->SetExp20Add = 0
		end,
		case Player2#player.exp30Add > 0 of
			true->SetExp30Add = Player2#player.exp30Add + Now - Player2#player.lastOfflineTime;
			false->SetExp30Add = 0
		end,
		
		Player3 = setelement( #player.exp15Add, Player2, SetExp15Add ),
		Player4 = setelement( #player.exp20Add, Player3, SetExp20Add ),
		Player5 = setelement( #player.exp30Add, Player4, SetExp30Add ),
		
		Player6 = setelement( #player.isOnline, Player5, 1 ),
		
		
		
		mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, "UPDATE player_gamedata SET isOnline=1,lastOnlineTime="++integer_to_list(Now)++" where id="++integer_to_list(PlayerID),true),
		
		EquipedList = mySqlProcess:get_equipListByPlayerID(PlayerID),
		
		AllItemDBDataList = mySqlProcess:get_r_itemDBListByPlayerID(PlayerID),
		
		AllItemBagDataList = mySqlProcess:get_playerBagDataLisByPlayerID(PlayerID),

		AllAcceptedTaskDBDataList = mySqlProcess:get_allPlayerTaskByPlayerId(PlayerID),

		AllCompletedTaskDBDataList = mySqlProcess:get_playerCompletedTaskListByPlayerID(PlayerID),
		

		AllSkillList = mySqlProcess:get_playerSkillsByPlayerID(PlayerID),

		AllShortcutList = mySqlProcess:get_shortcutListByPlayerID(PlayerID),

		EquipEnhanceInfoList = mySqlProcess:get_playerEquipEnhanceLevelListByPlayerID(PlayerID),

		AllFriendGamedataList = mySqlProcess:get_friendGamedataListByPlayerID(PlayerID),
		
		%%玩家上线日常 		
		DailyList = mySqlProcess:get_playerDailyListByPlayerID(PlayerID),

		Buff = buff:loadObjectBuffDataFromDB(PlayerID),

		PlayerOnlineDBData = #playerOnlineDBData{ playerBase=Player6,
												  equipedList = EquipedList, 
												  allItemDBDataList = AllItemDBDataList,
												  allItemBagDataList = AllItemBagDataList,
												  allTaskDBDataList = {AllAcceptedTaskDBDataList, AllCompletedTaskDBDataList},
												  allSkillList = AllSkillList, 
												  allShortcutList = AllShortcutList,
												  equipEnhanceInfoList = EquipEnhanceInfoList,
												  allFriendGamedataList = AllFriendGamedataList,
												  allBuff=Buff,
												  playerMountInfo=PlayerMountInfo,
												  playerItemCDInfo=PlayerItemCDInfo,
												  playerItem_DailyCountInfo = PlayerItem_DailyCountInfo,
												  dailyCount_Info = DailyList
												},
		?LOG_OUT( "on_selPlayer player[~p]", [PlayerID] ),

		%FromPID ! { selPlayerResult, ?SelPlayer_Result_Succ, PlayerOnlineDBData },			
		{?SelPlayer_Result_Succ, PlayerOnlineDBData}
	catch
		{ return, ReturnCode }->
			?LOG_OUT( "user[~p] on_selPlayer fail ReturnCode[~p] PlayerID[~p]", [netUsers:getCurUserID(), ReturnCode, Msg#pk_U2GS_SelPlayerEnterGame.playerID] ),

			{get( "on_selectPlayer_result"),{}}
	end.

%on_savePlayer(_PlayerInfo)->
%	ok.





on_savePlayerAll( #playerOnlineDBData{}=PlayerOnlineDBData )->
	mySqlProcess:updatePlayerGamedataByPlayerAndOthers(PlayerOnlineDBData#playerOnlineDBData.playerBase,
													   PlayerOnlineDBData#playerOnlineDBData.playerMountInfo,
													   PlayerOnlineDBData#playerOnlineDBData.playerItemCDInfo,
													   PlayerOnlineDBData#playerOnlineDBData.playerItem_DailyCountInfo),
	
	lists:foreach( fun(Record)->mySqlProcess:insertOrReplacePlayerEquipItem(Record,true) end, 
			   PlayerOnlineDBData#playerOnlineDBData.equipedList ),
	

	lists:foreach( fun(Record)->mySqlProcess:insertOrReplaceR_itemDB(Record,true) end, PlayerOnlineDBData#playerOnlineDBData.allItemDBDataList ),


	lists:foreach( fun(Record)->mySqlProcess:insertOrReplaceR_playerBag(Record,true) end, PlayerOnlineDBData#playerOnlineDBData.allItemBagDataList ),
	
	{AcceptedTaskList, CompletedTaskIDList} = PlayerOnlineDBData#playerOnlineDBData.allTaskDBDataList,
	lists:foreach( fun(Record)->mySqlProcess:replacePlayerTaskGamedata(Record) end, AcceptedTaskList),


	mySqlProcess:replacePlayerCompletedTask(#playerCompletedTask{playerID=PlayerOnlineDBData#playerOnlineDBData.playerBase#player.id, 
 										 taskIDList=CompletedTaskIDList}),

	lists:foreach( fun(Record)->mySqlProcess:insertOrReplaceShortcut(Record,true) end, PlayerOnlineDBData#playerOnlineDBData.allShortcutList ),

	mySqlProcess:insertOrReplacePlayerDaily( PlayerOnlineDBData#playerOnlineDBData.dailyCount_Info, true),
	%% modified by wenziyong, add table friend_gamedata, not save friend here, update friend when add or delete friend
	%lists:map( fun(Record)->mySqlProcess:sqldb_write_record(Record) end, PlayerOnlineDBData#playerOnlineDBData.allFriendGamedataList),

	ok.
  
on_savePlayerItem( ItemDBData )->
	mySqlProcess:insertOrReplaceR_itemDB(ItemDBData,true).

on_deletePlayerItem( ItemDBID )->
	mySqlProcess:deleteRecordByTableNameAndId("r_itemdb",ItemDBID).

%% on_savePlayerEquip( PlayerEquip )->
%% 	mySqlProcess:sqldb_write_record(PlayerEquip).

%% on_savePlayerEquipEnchance( PlayerEquipEnchance )->
%% 	mySqlProcess:sqldb_write_record(PlayerEquipEnchance).

on_playeroffline( PlayerID )->
	{ _SuccOrError, _Result } = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, "UPDATE player_gamedata SET isOnline = 0 where id = " ++integer_to_list(PlayerID),true),
%% 	PlayerList = db:matchObject(player, #player{ id=PlayerID }),
%% 	PlayerList1 = sqldb_query("select * from player where id = "++integer_to_list(PlayerID)),
%%  	PlayerList = lists:map(fun(List) -> player_list_to_record(List) end, PlayerList1),
%% 	case PlayerList of
%% 		[]->
%% 			ok;
%% 		[Player|_]->
%% 				NewPlayer = setelement( #player.isOnline, Player, 0 ),
%% 				db:writeRecord( NewPlayer )
%% 	end,
	ok.

%on_checkPlayerGuildID(FromPID, PlayerID, GuildID, TargetPlayerID, IsSingleProcess)->
on_checkPlayerGuildID( PlayerID, GuildID, TargetPlayerID, IsSingleProcess)->
	PlayerGamedataList = mySqlProcess:get_playerGamedata_list_by_id(TargetPlayerID),
	case PlayerGamedataList of
		[]->
			%% maybe the TargetPlayer is deleted
			{ PlayerID, noPlayer, TargetPlayerID, GuildID, IsSingleProcess };
		[Player|_]->
			case Player#player_gamedata.guildID of
				0->
					NewPlayer = setelement(#player_gamedata.guildID, Player, GuildID),
					mySqlProcess:updateGuidIdOfPlayerGamedata(NewPlayer),
					
					%FromPID ! {checkPlayerGuildIDResult, PlayerID, 0, TargetPlayerID, GuildID, IsSingleProcess };
					{PlayerID, ok, TargetPlayerID, GuildID, IsSingleProcess };
				_->
					%FromPID ! {checkPlayerGuildIDResult, PlayerID, -1, TargetPlayerID, GuildID, IsSingleProcess }
					{ PlayerID, isGuildMember, TargetPlayerID, GuildID, IsSingleProcess }
			end
	end.

%on_kickoutPlayer(FromPID, PlayerID, GuildID, TargetPlayerID)->
on_kickoutPlayer( PlayerID, GuildID, TargetPlayerID)->
	PlayerGamedataList = mySqlProcess:get_playerGamedata_list_by_id(TargetPlayerID),
	case PlayerGamedataList of
		[]->
			{PlayerID,noPlayer,TargetPlayerID,GuildID};
		[Player|_]->
			case Player#player_gamedata.guildID of
				0->
					{PlayerID,notGuildMember,TargetPlayerID,GuildID };
				_->
					NewPlayer = setelement(#player_gamedata.guildID,Player,0),
					mySqlProcess:updateGuidIdOfPlayerGamedata(NewPlayer),
					{PlayerID,ok,TargetPlayerID,GuildID}
			end
	end.


on_savePlayerSkillCDInfo( PlayerID, SkillList )->
 	MyFunc = fun( Record )->
					mySqlProcess:updatePlayerSkillCD(PlayerID,Record#playerSkill.skillId,Record#playerSkill.coolDownTime)
 			 end,
 	lists:foreach( MyFunc, SkillList ).

on_playerSaveTask( PlayerID, AcceptedTaskList, CompletedTaskIDList )->
	MyFunc = fun( Record )->
			 		mySqlProcess:insertPlayerTaskGamedata(Record)
			 end,
	lists:foreach( MyFunc, AcceptedTaskList ),
	mySqlProcess:insertPlayerCompletedTask(#playerCompletedTask{playerID=PlayerID, taskIDList=CompletedTaskIDList}).
	
%% 	db:writeRecord( #playerCompletedTask{playerID=PlayerID, taskIDList=CompletedTaskIDList} ).

%% delete erlang table frienddb
%on_playerSaveFriendList(FriendList)->
%		MyFunc = fun( Record )->
%					db:writeRecord( Record )
%			 end,
%	lists:foreach( MyFunc, FriendList).

on_delete_Friend(Fr_Id) ->
	{Fid, Me} = Fr_Id,
%% 	[Finfo] = db:matchObject(friendDB, #friendDB{playerID=Fid, friendID=Me,_='_'}), %#friendDB{playerID = Fid,friendID=player:getCurPlayerID(),_='_'}); %好友不在线
%% 	case Finfo#friendDB.id of
%% 		0 -> off;
%% 		_ ->
%% 			?DEBUG_OUT("Delete fid = ~p , rid=~p",[Finfo#friendDB.friendID, Finfo#friendDB.id]),
%% 			db:delete(friendDB, Finfo#friendDB.id)
%% 	end.
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, "delete from friend_gamedata where playerID="++integer_to_list(Me)++" and friendID="++integer_to_list(Fid),true).
	

%on_deleteRecord(Table, KeyIndex)->
% 	db:delete(Table, KeyIndex).

on_saveObjectBuffData(ObjectBuffData)->
	buff:saveObjectBuffDataToDB(ObjectBuffData).

%on_getPetBuffData(Pid, Pet, PetCfg) ->
on_getPetBuffData( Pet, PetCfg) ->
	%Pid ! {getPetBuffData_Result, buff:loadObjectBuffDataFromDB(Pet#petProperty.id), Pet, PetCfg}. 
	{ buff:loadObjectBuffDataFromDB(Pet#petProperty.id), Pet, PetCfg}.


on_ls_LS2GS_QueryUserMaxLevel( FromPID, Msg )->
	MaxLevel = mySqlProcess:getMaxLevelByUserID(Msg#pk_LS2GS_QueryUserMaxLevel.userID),
	ToLS = #pk_GS2LS_QueryUserMaxLevelResult{userID=Msg#pk_LS2GS_QueryUserMaxLevel.userID, maxLevel=MaxLevel},
	FromPID ! { db_GS2LS_QueryUserMaxLevelResult, ToLS }.
	

