%%Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(playerMap).

-include("db.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("vipDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("monsterDefine.hrl").
-include("itemDefine.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("taskDefine.hrl").
-include("mapView.hrl").
-include("logdb.hrl").
-include("TeamDfine.hrl").
-include("variant.hrl").
-include("guildDefine.hrl").
-include("textDefine.hrl").
-include("chat.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 


makeMapPlayer( #player{} = Player, PID, X, Y, ConvoyQuality, ConvoyFlags,Credit, EquipMinLevel, VIPInfo)->
	Result = gen_server:call(guildProcess_PID,{'getGuildInfo',Player#player.guildID, Player#player.id}),
	{ GuildInfo, MemberInfo}= Result,
	case GuildInfo /= {} andalso MemberInfo /= {} of
		true->
			GuildName = GuildInfo#guildBaseInfo.guildName,
			GulidID = GuildInfo#guildBaseInfo.id,
			Rank = MemberInfo#guildMember.rank;
		_->
			GuildName = [],
			GulidID = 0,
			Rank = -1
	end,
	
	{VIPLevel, VIPTimeExpire, _VIPTimeBuy} = VIPInfo,
	Now = common:getNowSeconds(),
	case Now < VIPTimeExpire of
		true->VIPLevel2 = VIPLevel;
		_->VIPLevel2 = 0
	end,
	
	#mapPlayer{ id=Player#player.id,
				event_array=undefined,
				objType=?Object_Type_Player,
				ets_table=0,
				timerList=undefined,
				moveState=?Object_MoveState_Stand,
				level=Player#player.level,
				pos=#posInfo{x=X, y=Y },
				name=Player#player.name,
				faction=Player#player.faction,
				sex=Player#player.sex,
				camp=Player#player.camp,
				weapon=0,
				coat=0,
				finalProperty = array:new( ?property_count, {default,0} ),
				skill_ProFix = array:new( ?property_count, {default,0} ),
				skill_ProPer = array:new( ?property_count, {default,[]} ),
				life=Player#player.life,
				stateFlag=Player#player.stateFlag,
				stateRefArray=array:new(?Buff_Effect_Type_Num, {default, 0}),
				pid=PID,
				moveTargetList = [],
				moveDir=?eDirection_NULL,
				moveRealDir=?eDirection_NULL,
				skillCommonCD = erlang:now(),
				nonceOutFightPetId=0,
				mapCDInfoList = Player#player.mapCDInfoList,				
				teamDataInfo=#teamData{teamID=0,leaderID=0,membersID=[]},
				mapViewCellIndex = 0,
				readyFastTeamCopyMap = 0,
				qieCuoPlayerID = 0,
				battleFieldID = 0,
				pK_Kill_Value = Player#player.pK_Kill_Value,
				pK_Kill_OpenTime = Player#player.pK_Kill_OpenTime,
				pk_Kill_Punish = Player#player.pk_Kill_Punish,
				playerMountView = #palyerMountView{mountDataID=0,mountSpeed=0},
			  	bloodPoolLife = Player#player.bloodPoolLife,
				attackSpeed = 0,
				petBloodPoolLife = Player#player.petBloodPoolLife,
				varArray = Player#player.varArray,
				covoyQuality = ConvoyQuality,
				convoyFlags = ConvoyFlags,
			  	credit=Credit,
				pkPunishing = 0,
				equipMinLevel = EquipMinLevel,
				guildID = GulidID,
				guildName = GuildName,
				guildRank = Rank,
				vipLevel=VIPLevel2,
				gameSetMenu=Player#player.gameSetMenu
			  }.
%%给玩家挂家族的多倍经验加成
on_ChangeMultyExpBuff( PlayerID,BuffID,IsAdd)->
	case etsBaseFunc:readRecord( main:getGlobalBuffCfgTable(), BuffID) of
		{}->ok;
		AddBuffCfg->
			case IsAdd of
				true->
					buff:addBuffer(PlayerID, AddBuffCfg, 0, 0, 0, 0);
				false->
					buff:removeBuff(PlayerID, BuffID)
			end
	end,
	ok.
%%Player进入地图
on_playerEnterMap( #mapPlayer{}=PlayerIn, PlayerSkillList, BuffData, PlayerProperty, WeaponID, CoatID )->
	try
		PlayerID = PlayerIn#mapPlayer.id,
		?LOG_OUT( "Player[~p] begin entermap[~p]", [PlayerID, map:getMapID()] ),
		
		etsBaseFunc:insertRecord( map:getMapPlayerTable(), PlayerIn ),
		etsBaseFunc:deleteRecord( map:getReadyEnterPlayerTable(), PlayerID ),

		{ Base_quip_ProFix, Base_quip_ProPer } = PlayerProperty,
		
		etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.base_quip_ProFix, Base_quip_ProFix ),
		etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.base_quip_ProPer, Base_quip_ProPer ),
		etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.ets_table, map:getMapPlayerTable() ),
		etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.weapon, WeaponID ),
		etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.coat, CoatID ),
		etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.readyFastTeamCopyMap, 0 ),
		
		MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), map:getMapDataID() ),
		%%玩家坐标验证
		case mapView:isBlock( map:getMapDataID(), PlayerIn#mapPlayer.pos#posInfo.x, PlayerIn#mapPlayer.pos#posInfo.y) of
			true->
				Pos = #posInfo{ x =MapCfg#mapCfg.initPosX, y = MapCfg#mapCfg.initPosY },
				etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerIn#mapPlayer.id, #mapPlayer.pos, Pos );
			false->ok
		end,		
		
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerIn#mapPlayer.id ),
		
		%%玩家技能初始化
		playerSkill:onPlayerEnterMapInitSkill(Player, PlayerSkillList ),

		%%buff初始化
		case BuffData of
			{}->
				etsBaseFunc:insertRecord( map:getObjectBuffTable(), #objectBuff{id=Player#mapPlayer.id, dataList=[] } );
			_->
				etsBaseFunc:insertRecord( map:getObjectBuffTable(), #objectBuff{id=Player#mapPlayer.id, dataList=BuffData#objectBuff.dataList } )
		end,

		%%玩家被动技能生效
		playerSkill:unDoAllPassiveSkill(Player),
		playerSkill:doAllPlayerPassiveSkill(Player),

		
		
		%%属性计算
		damageCalculate:calcFinaProperty( PlayerID ),
		
		%%添加状态
		mapActorStateFlag:addStateFlag( PlayerID, ?Actor_State_Flag_EnteredMap ),
		mapActorStateFlag:removeStateFlag( PlayerID, ?Player_State_Flag_ChangingMap ),
		
		%%先发送进入地图消息给玩家
		player:sendToPlayerByPID( Player#mapPlayer.pid, #pk_ChangeMap{ mapDataID=map:getMapDataID(),
																	   mapId=map:getMapID(),
																	   x=Player#mapPlayer.pos#posInfo.x,
																	   y=Player#mapPlayer.pos#posInfo.y } ),
		%%告诉玩家当前地图分先的ID
		MapCfg=map:getMapCfg(),
		case MapCfg#mapCfg.type of
			?Map_Type_Normal_World->
				LineInfo=#pk_GS2U_TellMapLineID{iLineID=get("MyLineID")},
				player:sendToPlayer(PlayerID, LineInfo);
			_->
				LineInfo=#pk_GS2U_TellMapLineID{iLineID=0},
				player:sendToPlayer(PlayerID, LineInfo),
				ok
		end,
		
		%%玩家进入格子
		mapView:charEnterCell(map:getPlayer(PlayerID), 0),

		?LOG_OUT("Player[~p] entered map[~p] charEnterCell", [Player#mapPlayer.id, map:getMapID()] ),
		
		%%脚本初始化
		scriptManager:onObjectCreateScript( etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID) ),
		
		%%响应玩家进入地图
		objectEvent:onEvent( etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID), ?Char_Event_Enter_Map, 0 ),
		
		%%地图响应，玩家进入地图
		objectEvent:onEvent( etsBaseFunc:readRecord( map:getMapObjectTable(), map:getMapID()), ?Map_Event_Player_Enter, PlayerIn ),
		
		%%通知玩家更换地图消息给组队进程
		TeamMemberMapInfo = #teamMemberMapInfo{ playerID = PlayerID,
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
												life_percent=charDefine:getObjectLifePercent(map:getPlayer(PlayerID)),
												playerPID = Player#mapPlayer.pid },
		
		teamThread ! {mapMsg_PlayerEnterMap, TeamMemberMapInfo },
		
		%%回复玩家进程，修改玩家状态，玩家已经进入地图
		PlayerPID = player:getPlayerPID( Player#mapPlayer.id ),
		case PlayerPID of
			0->ok;
			_->PlayerPID ! { playerEnteredMap, map:getMapDataID(), map:getMapID(), self() }
		end,
		%%告诉玩家，地图现在是否和平模式处于保护中
		%%PlayerPID ! { mapProctedStatus, get("InPKProct") },
		
		objectEvent:onEvent(Player, ?Player_Event_Online, 0),
		
		%%通知地图管理进程，玩家在线人数
		mapManagerPID ! { mapMsg_OnlinePlayers, map:getMapID(), ets:info(map:getMapPlayerTable(), size) },
		
		%%玩家进地图检测杀戮模式
		qieCuo:onPlayerEnterMap_ForPKKill( PlayerIn ),
		
		sendObjectLifeToClient(PlayerIn, true),

		%%如果进入的是阵营pk地图，要给提示
		case MapCfg#mapCfg.pkFlag_Camp =/= 0 of
			true->
				systemMessage:sendSysMessage(PlayerID, ?SYSTEM_MESSAGE_PROMPT, ?CAMP_BATTLE),
				systemMessage:sendSysMessage(PlayerID, ?SYSTEM_MESSAGE_TIPS, ?CAMP_BATTLE);
			false->
				ok
		end,
		
		
		%%非世界地图，记录玩家进入历史
		case MapCfg#mapCfg.type of
			?Map_Type_Normal_Copy->
				%%副本，记录玩家进入历史
				%%副本，进入后，如果是没有进入历史的，要加CD计数
				%%如果以后有需求，副本CD要另外计算，可走脚本
				Map = map:getMapObject(),
				{ Find, _ } = common:findInList( Map#mapObject.enteredPlayerHistory, PlayerID, 0 ),
				case Find of
					true->ok;
					false->
						playerChangeMap:updatePlayerMapCD(Player, map:getMapDataID(), 1),
						etsBaseFunc:changeFiled( map:getMapObjectTable(), map:getMapID(), #mapObject.enteredPlayerHistory, Map#mapObject.enteredPlayerHistory ++ [PlayerID] )
				end,
				ok,
				
				%%发送当前副本进度给玩家
				map:sendCopyMapProgressToPlayer();
			_->ok
		end,
		
		?LOG_OUT("Player[~p] entered map[~p] end", [Player#mapPlayer.id, map:getMapID()] ),

		ok
	catch
		_->ok
	end.

%%玩家离开地图
onExitedMap( #mapPlayer{}=Player )->
	PlayerID = Player#mapPlayer.id,
	
	%playerSkill:unDoAllPassiveSkill(Player),
	%%切磋
	case Player#mapPlayer.qieCuoPlayerID /= 0 of
		true->qieCuo:qieCuo_Fail(Player, false );
		_->ok
	end,
	
	?DEBUG_OUT( "onExitedMap ~s", [Player#mapPlayer.name] ),
	%%响应玩家离开地图
	objectEvent:onEvent( etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID), ?Char_Event_Leave_Map, 0 ),
		
	%%地图响应，玩家离开地图
	objectEvent:onEvent( etsBaseFunc:readRecord( map:getMapObjectTable(), map:getMapID()), ?Map_Event_Player_Leave, Player ),
	
	playerChangeMap:quitFastTeamCopyMap( PlayerID, true ),
	
	objectHatred:clearHatred( PlayerID ),
	
	Q = ets:fun2ms( fun(#playerSkill{id=SkillKey, playerId=DBPlayerID, skillId=_,coolDownTime=_}=Record) when DBPlayerID=:= PlayerID ->SkillKey end ),
	PlayerSkillList = ets:select(map:getPlayerSkillTable(), Q),
	
	MyFunc = fun( Record )->
					 etsBaseFunc:deleteRecord( map:getPlayerSkillTable(), Record )
			 end,
	
	lists:foreach( MyFunc, PlayerSkillList),
	
	etsBaseFunc:deleteRecord( map:getObjectBuffTable(), PlayerID ),

	etsBaseFunc:deleteRecord( map:getObjectHatredTable(), PlayerID ),
	
	?DEBUG_OUT( "onExitedMap getMapPlayerTable delete ~p", [PlayerID] ),
	etsBaseFunc:deleteRecord( map:getMapPlayerTable(), PlayerID ),
	
	teamThread ! { mapMsg_PlayerQuitMap, Player#mapPlayer.teamDataInfo#teamData.teamID, PlayerID },
	
	OnlinePlayers = ets:info( map:getMapPlayerTable(), size ),
	case OnlinePlayers =:= 0 of
		true->put( "LastNoPlayerTime", common:timestamp() );
		false->ok
	end,
	
	case Player#mapPlayer.nonceOutFightPetId =:= 0 of
		true->ok;
		false->
			map:despellObject(Player#mapPlayer.nonceOutFightPetId, erlang:now())
	end,

	mapManagerPID ! { mapMsg_OnlinePlayers, map:getMapID(), ets:info(map:getMapPlayerTable(), size) },
	
	%%如果地图是战场，那么检测是否已经没人了，
	MapCfg=map:getMapCfg(),
	case MapCfg#mapCfg.type of
		?Map_Type_Battle->
			?DEBUG_OUT("No Player Close"),
			map:on_mapNoPlayerTimer();
		_->
			ok
	end,

	ok.

%%返回坐标X
getPlayerPosX( Player )->
	Player#mapPlayer.pos#posInfo.x.
%%返回坐标Y
getPlayerPosY( Player )->
	Player#mapPlayer.pos#posInfo.y.

%%返回玩家是否有队伍
hasPlayerTeam( Player )->
	Player#mapPlayer.teamDataInfo#teamData.teamID /= 0.

%%返回玩家是否队长
isPlayerTeamLeader( Player )->
	Player#mapPlayer.teamDataInfo#teamData.leaderID == Player#mapPlayer.id.

%%返回玩家的TeamID
getPlayerTeamID( Player )->
	Player#mapPlayer.teamDataInfo#teamData.teamID.

%%返回是否已经死亡
isDead( PlayerID )->
	mapActorStateFlag:isStateFlag( PlayerID, ?Actor_State_Flag_Dead ).
	

%%响应玩家血量变化
onHPChanged( #mapPlayer{}=_Player )->
	ok.

%%执行死亡动作
doDead( #mapPlayer{}=Player, WhoKillMe, CombatID )->
	try
		case mapActorStateFlag:isStateFlag(Player#mapPlayer.id, ?Actor_State_Flag_Dead ) of
			true->throw(-1);%%重复死亡
			false->ok
		end,
		
		case playerMove:isMoving(Player) of
			true->playerMove:stopMove(Player);
			false->ok
		end,
		
		mapActorStateFlag:addStateFlag( Player#mapPlayer.id, ?Actor_State_Flag_Dead ),
		
		%%广播死亡消息
		%%?		
		case WhoKillMe of
			{}->KillerID = 0;
			_->
				case element( 1, WhoKillMe ) of
					mapPlayer->KillerID = WhoKillMe#mapPlayer.id;
					mapMonster->KillerID = WhoKillMe#mapMonster.id;
					mapPet->KillerID = WhoKillMe#mapPet.id;
					_->KillerID = 0
				end
				
		end,

		Msg = #pk_GS2U_CharactorDead{
									nDeadActorID = Player#mapPlayer.id,
									nKiller      = KillerID,
									nCombatNumber =CombatID
									},
		
		mapView:broadcast(Msg, Player, 0),
		
		%%清仇恨
		objectHatred:clearHatred( Player#mapPlayer.id ),
		
		%%清buff
		buff:deathClearBuff(Player#mapPlayer.id),
		
		%%响应死亡事件
		onDead( Player, WhoKillMe ),
		map:onObjectDead( ?Object_Type_Player, Player, WhoKillMe ),
		
		%%切换状态
		%%?

		case WhoKillMe of
			{}->
				?DEBUG_OUT( "player[~p] dead by whokillme={}", [map:getObjectLogName(Player)] );
			_->?DEBUG_OUT( "player[~p] dead by whokillme[~p]", [map:getObjectLogName(Player), map:getObjectLogName(WhoKillMe)] )
		end,

		
		
		ok
	catch
		_->ok
	end.

%%地图进程，响应死亡事件
onDead( #mapPlayer{}=Player, WhoKillMe )->
	try
		%%宠物处理主人死亡事件
		case Player#mapPlayer.nonceOutFightPetId of
			0 ->ok;
			PetId ->
				case etsBaseFunc:readRecord(map:getMapPetTable(), PetId) of
					{}->ok;
					Pet ->
						petMap:doMasterDead(Pet, Player)
				end
		end,
		%%下马处理
		case Player#mapPlayer.playerMountView#palyerMountView.mountDataID =:= 0 of
			true->ok;
			false->mount:on_ViewMount(Player#mapPlayer.pid, Player#mapPlayer.id,false)
		end,

		%%检测杀人者是在杀戮模式,被杀者不在杀戮模式
		case element( 1, Player ) of %% 只针对玩家，排除其它的
			mapPlayer ->
				case element( 1, WhoKillMe ) of %% 宠物和玩家
					mapPlayer ->
						case ( mapActorStateFlag:isStateFlag(WhoKillMe#mapPlayer.id, ?Player_State_Flag_PK_Kill ) ) andalso 
							 ( not mapActorStateFlag:isStateFlag(Player#mapPlayer.id, ?Player_State_Flag_PK_Kill ) ) of
							true->
								qieCuo:addPKKillValue(WhoKillMe, globalSetup:getGlobalSetupValue( #globalSetup.killPlayerPoint )),
								ok;
							false->ok
						end;
					mapPet ->
						MasterPlayer = etsBaseFunc:readRecord(map:getMapPlayerTable(), WhoKillMe#mapPet.masterId),
						case MasterPlayer of
							{}->ok;
							_->
								case ( mapActorStateFlag:isStateFlag(MasterPlayer#mapPlayer.id, ?Player_State_Flag_PK_Kill ) ) andalso 
									 ( not mapActorStateFlag:isStateFlag(Player#mapPlayer.id, ?Player_State_Flag_PK_Kill ) ) of
									true->
										qieCuo:addPKKillValue(MasterPlayer, globalSetup:getGlobalSetupValue( #globalSetup.killPlayerPoint )),
										ok;
									false->ok
								end	
						end;			
					_ -> ok
				end;			
			_ ->ok
		end,
		
		%%护送奖励任务
		case Player#mapPlayer.convoyFlags =:= 0 of
			true -> ok;
			false -> %% 正在护送中
				case element( 1, WhoKillMe ) of %% 只针对玩家，排除其它的
					mapPlayer ->
						case Player#mapPlayer.camp =:= WhoKillMe#mapPlayer.camp of
							true -> ok;
							false -> %% 敌队阵营才会有奖励
								PlayLevel = Player#mapPlayer.level,
								KillerLevel = WhoKillMe#mapPlayer.level,
								Scale = PlayLevel div 10,
								case (Scale*10 =< KillerLevel) andalso (Scale*10+9 >= KillerLevel) of
									true ->
										ok; %%奖励荣誉，目前暂时不奖励
									false ->ok
								end
						end;
					_ -> ok
				end
		end,
		
		%%设置是否复活后添加pk 保护
		addPkProctedMark(Player,WhoKillMe),
		%%通知玩家进程，玩家死亡
		Player#mapPlayer.pid ! { mapMsg_PlayerDead, WhoKillMe }
	catch
		_->ok
	end. 

%%玩家进程处理地图进程通知，玩家死亡
on_mapMsg_PlayerDead( _WhoKillMe )->
	
%% 	case _WhoKillMe of
%% 		{}->KillerType = 0,KillerID = 0,Killercamp = -1;
%% 		_->
%% 			case element( 1, _WhoKillMe ) of
%% 				mapPlayer->KillerType = 1,KillerID = _WhoKillMe#mapPlayer.id,Killercamp = _WhoKillMe#mapPlayer.camp;
%% 				mapMonster->KillerType = 2,KillerID = _WhoKillMe#mapMonster.monster_data_id, Killercamp = -1;
%% 				_->KillerType = 0,KillerID = 0,Killercamp = -1
%% 			end
%% 			
%% 	end,
%% 	
%% 	PlayerBase = player:getCurPlayerRecord(),
	%% 写死亡LOG 		 		
%% 	ParamLog = #dead_param{killertype = KillerType,
%% 						   killerid = KillerID,
%% 						   killercamp = Killercamp},
%% 		
%% 	logdbProcess:write_log_player_event(?EVENT_PLAYER_DEAD,ParamLog,PlayerBase),

	%%坐骑响应
	mount:onPlayerDead(),
	%%处理护送
	convoy:on_User_Dead_Msg_To_Convoy(),
	ok.

on_gmRandomAttack(PlayerID,SkillID)->
		Player = map:getMapObjectByID( PlayerID ),
		case Player of
			{}->
				ok;
			_->
				%%给选个目标，很没效率啊
				PlayerPosX=Player#mapPlayer.pos#posInfo.x,
				PlayerPosY=Player#mapPlayer.pos#posInfo.y,
				put("randomAttackMonster",{}),
				put("randomAttackMonsterDis",10000),
				Fun = fun(Monster)->
									MonsterPosX=Monster#mapMonster.pos#posInfo.x,
									MonsterPosY=Monster#mapMonster.pos#posInfo.y,
									case MonsterPosX<PlayerPosX of
										true->
											DisX=PlayerPosX-MonsterPosX;
										false->
											DisX=MonsterPosX-PlayerPosX
									end,
		
									case MonsterPosY<PlayerPosY of
										true->
											DisY=PlayerPosY-MonsterPosY;
										false->
											DisY=MonsterPosY-PlayerPosY
									end,
									  Dis=DisX+DisY,
									case Dis<get("randomAttackMonsterDis") of
										true->
											put("randomAttackMonster",Monster),
											put("randomAttackMonsterDis",Dis);
										false->
											ok
									end
						end,
				etsBaseFunc:etsFor(map:getMapMonsterTable(), Fun),
				TargetMonster=get("randomAttackMonster"),
				onMsgUseSkill(PlayerID,SkillID,[TargetMonster#mapMonster.id],0)
		end,
		
		ok.

%%处理客户端使用攻击技能请求
onMsgUseSkill( PlayerID, SkillID, TargetIDList, CombatID )->
	try
		Player = map:getMapObjectByID( PlayerID ),
		case Player of
			{}->throw(-1);
			_->ok
		end,
		
		case TargetIDList of
			[]->throw(-1);
			_->ok
		end,
		
		Fun = fun( ID )->
					  map:getMapObjectByID(ID)
			  end,
		TargetList2 = lists:map(Fun, TargetIDList),
		Fun2 = fun( Object )->
					   case Object of
						   {}->false;
						   _->
							   case element(1, Object) of
								   mapPlayer->true;
								   mapMonster->true;
								   mapPet->true;
								   _->false
							   end
					   end
			   end,
		TargetList = lists:filter(Fun2, TargetList2),
		case TargetList of
			[]->throw(-1);
			_->ok
		end,
		
		[TargetFirst|_] = TargetList,
		
		%%查找mapskill
		SkillID64 = playerSkill:getPlayerSkillID( PlayerID, SkillID ),
		case etsBaseFunc:readRecord(map:getPlayerSkillTable(), SkillID64 ) of
			{}->
				RuleBranch = ets:fun2ms(fun(#playerSkill{id=FilterSkillID, playerId=FilterPlayerID, curBindedSkillID=FilterBindedSkillID} = Record) 
							   when ((FilterBindedSkillID =:= SkillID) andalso (PlayerID =:= FilterPlayerID) ) ->Record end),
				SkillListBranch = ets:select(map:getPlayerSkillTable(), RuleBranch),
				case SkillListBranch of
					[]->PlayerSkill={};
					[PlayerSkill2|_]->PlayerSkill=PlayerSkill2
				end;
			FindSKill->
				PlayerSkill=FindSKill
		end,
		
		case PlayerSkill of
			{}->throw(-1);
			_->ok
		end,
		%%技能CD需要的SkillCfg
		SkillCfg = etsBaseFunc:readRecord( main:getGlobalSkillCfgTable(), PlayerSkill#playerSkill.skillId ),
		case SkillCfg of
			{}->throw(-1);
			_->ok
		end,
		%%本技能如果绑定了附加技能，使用附加技能
	   %%SkillCfgReal是真正使用的技能
		case PlayerSkill#playerSkill.curBindedSkillID of
			0->
				SkillCfgReal=SkillCfg;
			_->
				SkillCfgReal = etsBaseFunc:readRecord( main:getGlobalSkillCfgTable(), PlayerSkill#playerSkill.curBindedSkillID )
		end,
		
		case SkillCfgReal of
			{}->throw(-1);
			_->ok
		end,
		
		case SkillCfgReal#skillCfg.skill_GlobeCoolDown of
			0->ok;		%%不进行GCD判断
			_->
				CommonCD = timer:now_diff( erlang:now(), Player#mapPlayer.skillCommonCD )/1000,
				AttackSpeed = array:get(?attack_speed, Player#mapPlayer.finalProperty),
				case CommonCD <  AttackSpeed of
					true->throw(-1);
					false->ok
				end
		end,
		
		SkillCDing = playerSkill:isPlayerSkillCDing( Player#mapPlayer.id, PlayerSkill#playerSkill.skillId ),
		
		case SkillCDing of
			true->
				?DEBUG_OUT( "Player [~p] Skill [~p] is cding", [Player#mapPlayer.id, PlayerSkill#playerSkill.skillId] ),
				throw(-1);
			false->ok
		end,

		Pos = map:getObjectPos(TargetFirst),
		case skillUse:useSkill(Player, TargetList, SkillCfgReal, Pos#posInfo.x, Pos#posInfo.y, -1, CombatID) of
			true->
				%%技能使用成功写入 公共CD、技能CD
				case SkillCfgReal#skillCfg.skill_GlobeCoolDown of
					0->ok;  %%技能没有GCD
					_->
						etsBaseFunc:changeFiled( map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.skillCommonCD, erlang:now() )
				end,

				playerSkill:setPlayerSkillCDBegin( Player#mapPlayer.id , SkillCfg, SkillCfgReal#skillCfg.skillCoolDown);
			_->ok
		end,

		ok
	catch
		_->ok
	end.


%%技能使用成功事件响应
onUsedSkill( #mapPlayer{}=Player, _SkillCfg, _Target )->
	try
		objectEvent:onEvent( Player, ?Char_Event_Used_Skill, 0 ),
		ok
	catch
		_->ok
	end.

%%玩家下线退地图
on_mapPlayerOffline( PlayerID)->
	try
		Player = map:getMapObjectByID( PlayerID ),
		case Player of
			{}->throw(-1);
			_->ok
		end,
		
		ToDB = #playerMapDBInfo{id=PlayerID, 
								hp=Player#mapPlayer.life, 
								x=Player#mapPlayer.pos#posInfo.x, 
								y=Player#mapPlayer.pos#posInfo.y,
								mapCDInfoList=Player#mapPlayer.mapCDInfoList,
								bloodPoolLife=Player#mapPlayer.bloodPoolLife
								},
		dbProcess_PID ! { savePlayerMapDBInfo, ToDB },
		
		
		%MyFunc = fun( Record )->
		%				 etsBaseFunc:readRecord( map:getPlayerSkillTable(), Record#playerSkill.id )
		%		 end,	
		%SaveSkillList = lists:map( MyFunc, PlayerSkillList ),
		%% 技能CD只在map process里使用，由地图进程负责保存玩家的技能CD
		Q = ets:fun2ms( fun(#playerSkill{id=SkillKey, playerId=DBPlayerID, skillId=_,coolDownTime=CoolDown}=Record) 
							 when DBPlayerID=:= PlayerID ->
								Record#playerSkill{coolDownTime=CoolDown div 1000} 
						end ),
		PlayerSkillList = ets:select(map:getPlayerSkillTable(), Q),
		dbProcess_PID ! { savePlayerSkillCDInfo, PlayerID, PlayerSkillList },

		%%保存玩家的buff
		buff:onSaveObjectBuffData(PlayerID),
		
		map:despellObject(PlayerID, 0),
		petMap:onPlayerOffLine(Player),
		
		ok
	catch
		_->ok
	end.

%%玩家进程响应玩家杀死Monster
on_mapMsg_KillMonster( MonsterDataID, EXP, MapDataID, DropRadio )->
	%%更新任务
	task:on_mapMsg_KillMonster(MonsterDataID),
	case EXP > 0 of
		true->
			%% VIP玩家打怪经验加成 add by yueliangyou [2013-05-13]
			{_,EXP0} = vipFun:callVip(?VIP_FUN_EXP_KILLMONSTER,EXP),	
			?DEBUG_OUT("vipFun:callVip(?VIP_FUN_EXP_KILLMONSTER),EXP=~p,Exp0=~p",[EXP,EXP0]),
			%%更新玩家经验
			ParamTuple = #exp_param{changetype = ?Exp_Change_KillMonster,param1=MonsterDataID},
			player:addPlayerEXP(EXP0, ?Exp_Change_KillMonster,ParamTuple),
			%%更新宠物经验
			pet:addPetExp(EXP0, ?Exp_Change_KillMonster);
		false->ok
	end,
	%%杀怪掉落
	Reason = ?Get_Item_Reson_Pick,
	%%怪物掉落
	MonsterCfg = etsBaseFunc:readRecord( main:getGlobalMonsterCfgTable(), MonsterDataID ),
	case MonsterCfg of
		{}->ok;
		_->
			case drop:getDropListByDropId(MonsterCfg#monsterCfg.droplist, DropRadio) of
				[] ->
					false;
				ItemList ->
					playerItems:addItemToPlayerByItemList(ItemList, Reason)
			end
	end,
	%%地图掉落
	MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), MapDataID ),
	case MapCfg of
		{}->ok;
		_->
			case drop:getDropListByDropId(MapCfg#mapCfg.mapdroplist, DropRadio) of
				[]->
					false;
				ItemList_map ->
					playerItems:addItemToPlayerByItemList(ItemList_map, Reason)
			end
	end,
	%%世界掉落
	GlobalDropList = globalSetup:getGlobalSetupValue( #globalSetup.globalDropList ),
	case GlobalDropList > 0 of
		true->
			case drop:getDropListByDropId(GlobalDropList, DropRadio) of
				[]->
					false;
				ItemList_world ->
					playerItems:addItemToPlayerByItemList(ItemList_world, Reason)
			end;
		false->ok
	end,
	ok.

%%地图进程，发送一个Char的当前血量信息给客户端
sendObjectLifeToClient( ObjectIn, Broadcast )->
	Object = map:getMapObjectByID( element(?object_id_index, ObjectIn) ),
	case Object of
		{}->ok;
		_->
			Msg = #pk_ActorLifeUpdate{ nActorID=element(?object_id_index, ObjectIn),
									   nLife = charDefine:getObjectLife( Object ),
									   nMaxLife=charDefine:getObjectProperty(Object, ?max_life) },
	
			case Broadcast of
				true->
					mapView:broadcast(Msg, Object, 0);
				false->
					case element( 1, Object ) of
						mapPlayer->player:sendToPlayer(Msg#pk_ActorLifeUpdate.nActorID, Msg );
						_->ok
					end
					
			end
	end.


%%玩家进程，复活请求
on_Reborn( #pk_Reborn{}=P )->
	try
		case P#pk_Reborn.type of
			1->%%原地复活，需要检测复活道具，暂时固定100ID
				ItemDataID = 100,
				Result = playerItems:canDecItemInBag( ?Item_Location_Bag, ItemDataID, 1, "all" ),
				case Result of
					[true|LocalCellList]->
						[First|_] = LocalCellList,
						{Location, Cell, _Amount} = First,
						%%先将物品锁定，等待地图进程回复是否成功后操作
						playerItems:setLockPlayerBagCell(Location, Cell, 1),
						
						player:sendMsgToMap({playerMsg_Reborn, self(), player:getCurPlayerID(), P#pk_Reborn.type, First }),
						
						ok;
					[false|_]->throw(-1)
				end,

				ok;
			_->
%% 			   ParamLog = #relive_param{type = 0},
%% 			   PlayerBase = player:getCurPlayerRecord(),
%% 			   logdbProcess:write_log_player_event(?EVENT_PLAYER_RELIVE,ParamLog,PlayerBase),
			   player:sendMsgToMap({playerMsg_Reborn, self(), player:getCurPlayerID(), P#pk_Reborn.type, {} })
		end,
		ok
	catch
		_->ok
	end.

%%玩家进程，地图回复复活结果
on_mapMsg_ReviveResult( ItemLock, SuccOrFaile )->
	{Location, Cell, _Amount} = ItemLock,
	case SuccOrFaile of
		true->
			NewItemLock = {Location, Cell, 1},
			playerItems:setLockPlayerBagCell(Location, Cell, 0),
			playerItems:decItemInBag( [NewItemLock], ?Destroy_Item_Reson_Revive ),
			%% 写复活LOG			
%% 			ParamLog = #relive_param{type = 1},		
%% 			PlayerBase = player:getCurPlayerRecord(),
%% 			logdbProcess:write_log_player_event(?EVENT_PLAYER_RELIVE,ParamLog,PlayerBase),
			ok;
		false->
			playerItems:setLockPlayerBagCell(Location, Cell, 0),			
			ok
	end.

	

 
%%地图进程，玩家复活请求
on_playerMsg_Reborn( FromPID, PlayerID, ReviveTyp, ItemLock )->
	try
		Player = map:getMapObjectByID( PlayerID ),
		case Player of
			{}->throw(-1);
			_->ok
		end,
		PlayerVarArray=Player#mapPlayer.varArray,
		AllowReliveTime=variant:getPlayerVarValue(PlayerVarArray, ?PlayerVariant_Index_Ban_Relive_M),
		case (AllowReliveTime=/=undefined) and ( AllowReliveTime > common:getNowSeconds() ) of
			true->
				throw(-1);
			false->
				ok
		end,
		
		case mapActorStateFlag:isStateFlag(PlayerID, ?Actor_State_Flag_Dead) of
			true->ok;
			false->throw(-1)
		end,
		
		case ReviveTyp of
			1->%%原地复活
				RevivePosX = Player#mapPlayer.pos#posInfo.x,
				RevivePosY = Player#mapPlayer.pos#posInfo.y,
				ReviveHP   = array:get( ?max_life, Player#mapPlayer.finalProperty ),
				ok;
			0->%%城里复活
				MapCfg = map:getMapCfg(),
				RevivePosX = MapCfg#mapCfg.initPosX,
				RevivePosY = MapCfg#mapCfg.initPosY,
				%暂时满血，以后要改
				%ReviveHP   = erlang:trunc( array:get( ?max_life, Player#mapPlayer.finalProperty ) * 0.2 ),
				ReviveHP   = array:get( ?max_life, Player#mapPlayer.finalProperty )*?ReLiveHPPercentage  div 100+1 ,
				ok;
			_->RevivePosX=0,RevivePosY=0,ReviveHP=0,throw(-1)
		end,
		
		%%如果是被玩家砍死了，并且自己还处于和平模式，那么给个保护
		%%现在不管啥状态，都给个buff
		
		%%添加死亡复活buff，这功能不要了
		%%死的时候给加buff
		%%case etsBaseFunc:readRecord( main:getGlobalBuffCfgTable(), ?KillByPlayerReLiveBuffID ) of
		%%	{}->ok;
		%%	AddBuffCfg->
		%%		case pKProctLeftTime(PlayerID) of
		%%			0->
		%%				ok;
		%%			LeftTime->
		%%				buff:addBuffer( PlayerID, AddBuffCfg, 0, LeftTime, {},0 )
		%%		end
		%%end,
		
		
		Msg = #pk_GS2U_CharactorRevived{nActorID=PlayerID,
								  nLife=ReviveHP,
								  nMaxLife=array:get( ?max_life, Player#mapPlayer.finalProperty )
								  },
		
		mapView:broadcast(Msg, Player, 0),

		mapActorStateFlag:removeStateFlag(PlayerID, ?Actor_State_Flag_Dead),
		charDefine:changeSetLife(Player, ReviveHP, false),
		playerMove:setPos( Player, RevivePosX, RevivePosY ),
		
		case ItemLock of
			{}->ok;
			_->%%原地复活需要回复玩家结果
				FromPID ! { mapMsg_ReviveResult, ItemLock, true }
		end,
		ok
	catch
		_->
			case ItemLock of
				{}->ok;
				_->%%原地复活需要回复玩家结果
					FromPID ! { mapMsg_ReviveResult, ItemLock, false }
			end
	end.





%%玩家进程，响应玩家等级、装备、宠物变化通知地图
onPlayer_LevelEquipPet_Changed()->
	WeaponRecord = equipment:getPlayerEquipedEquipInfo( ?EquipType_Weapon ),
	case WeaponRecord of
		{}->WeaponID = 0;
		_->WeaponID = WeaponRecord#playerEquipItem.equipid
	end,
	CoatRecord = equipment:getPlayerEquipedEquipInfo( ?EquipType_Coat ),
	case CoatRecord of
		{}->CoatID = 0;
		_->CoatID = CoatRecord#playerEquipItem.equipid
	end,
	MinEquipLevel = equipment:getPlayerEquipMinLevel(),
	
	player:sendMsgToMap( { playerMsg_LevelEquipPet_Changed, 
						   player:getCurPlayerID(),
						   player:getCurPlayerProperty(#player.level),
						   WeaponID, CoatID,
						   [],
						   charDefine:getPlayerPropertyArray(),
						   MinEquipLevel }  ).

%%地图进程，玩家等级、装备、宠物变化通知地图
on_playerMsg_LevelEquipPet_Changed( PlayerID, Level, WeaponID, CoatID, _PetData, Property, MinEquipLevel )->
	try
		Player = map:getMapObjectByID( PlayerID ),
		case Player of
			{}->throw(-1);
			_->ok
		end,

		etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.level, Level ),
		etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.weapon, WeaponID ),
		etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.coat, CoatID ),
	
		{ Base_quip_ProFix, Base_quip_ProPer } = Property,
		etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.base_quip_ProFix, Base_quip_ProFix ),
		etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.base_quip_ProPer, Base_quip_ProPer ),
		etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.equipMinLevel, MinEquipLevel ),
		
		damageCalculate:calcFinaProperty( PlayerID ),
		case Player#mapPlayer.level =:= Level of
			true->ok;
			false->
				case playerMap:isDead(PlayerID) of
					true->ok;
					false->charDefine:changeSetLife(Player, charDefine:getObjectProperty(Player, ?max_life), true )
				end
		end,
		
		case Player#mapPlayer.weapon =:= WeaponID of
			false->
					GS2U_Player_ChangeEquipResult1 = #pk_GS2U_Player_ChangeEquipResult{playerID=PlayerID,
																					   equipID = WeaponID},
					mapView:broadcast(GS2U_Player_ChangeEquipResult1, Player, 0);
			true->ok
		end,
		case Player#mapPlayer.coat =:= CoatID of
			false->
					GS2U_Player_ChangeEquipResult2 = #pk_GS2U_Player_ChangeEquipResult{playerID=PlayerID,
																					   equipID = CoatID},
					mapView:broadcast(GS2U_Player_ChangeEquipResult2, Player, 0);
			true->ok
		end,
		
		case Player#mapPlayer.equipMinLevel =:= MinEquipLevel of
			true->ok;
			false->
					PlayerEquipMinLevelChange = #pk_PlayerEquipMinLevelChange{playerid=PlayerID,
																					   minEquipLevel = MinEquipLevel},
					mapView:broadcast(PlayerEquipMinLevelChange, Player, 0)
		end,

		ok
	catch
		_->ok
	end.	


%%地图进程，处理玩家请求属性信息
on_U2GS_QueryHeroProperty( PlayerID )->
	try
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->throw(-1);
			_->ok
		end,
		Array = Player#mapPlayer.finalProperty,
		
		PropertyIndexRecord = {?attack, ?defence, ?hit, ?hit_rate_rate, ?dodge, ?dodge_rate, ?crit, ?crit_rate, ?crit_damage_rate, 
							   ?block, ?block_rate,?tough,?tough_rate, ?block_dec_damage, ?attack_speed, ?attack_speed_rate,?pierce,?pierce_rate,
							   ?fire_def, ?ph_def, ?ice_def, ?hold_def, ?elec_def, ?move_def,?coma_def,?silent_def,?poison_def },
		
		MyFunc = fun( Index )->
						 PropertyIndex = element( Index, PropertyIndexRecord ),
						 NValue=array:get( PropertyIndex, Array ),
						 #pk_CharPropertyData{nPropertyType=PropertyIndex, nValue=NValue }
				 end,
		
		InfoList = common:for( 1, size(PropertyIndexRecord), MyFunc ),

		player:sendToPlayer(PlayerID, #pk_GS2U_HeroPropertyResult{info_list=InfoList} ),

		ok
	catch
		_->ok
	end.
%%地图进程，处理玩家队伍状况
on_playerTeamset(PlayerID,Vaule)->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerID) of
		{}->ok;
		_->
			?DEBUG_OUT( "on_playerTeamset PlayerID[~p] Vaule[~p]", [PlayerID, Vaule] ),
	 		etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.teamDataInfo, Vaule ),
			playerChangeMap:quitFastTeamCopyMap(PlayerID, false)
	end.
	
on_deletPlayerTeam(PlayerID)->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerID) of
		{}->ok;
		_->
			TeamData = #teamData{leaderID = 0,
								 teamID=0,
								 membersID=[]},
			etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.teamDataInfo, TeamData )
	end.


%%地图进程，处理玩家离开副本
on_PlayerLeaveCopyMap( PlayerID )->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerID) of
		{}->ok;
		Player->
			MapCfg = map:getMapCfg(),
			case MapCfg#mapCfg.type of
				?Map_Type_Battle->
					%%复制的下面的，很丑陋
					case etsBaseFunc:readRecord(main:getGlobalMapCfgTable(), MapCfg#mapCfg.quitMapID) of
						{}->ok;
						MapCfgTo->
							playerChangeMap:transPlayerByTransport( Player, 
																	MapCfgTo#mapCfg.mapID, 
																	MapCfg#mapCfg.quitMapPosX, 
																	MapCfg#mapCfg.quitMapPosY )
					end;
				?Map_Type_Normal_Copy->
					case etsBaseFunc:readRecord(main:getGlobalMapCfgTable(), MapCfg#mapCfg.quitMapID) of
						{}->ok;
						MapCfgTo->
							playerChangeMap:transPlayerByTransport( Player, 
																	MapCfgTo#mapCfg.mapID, 
																	MapCfg#mapCfg.quitMapPosX, 
																	MapCfg#mapCfg.quitMapPosY )
					end;
				_->ok
			end
	end.

%%地图进程，让玩家进入战场
on_playerEnterBattleScene(PlayerID,MapDataID,PosX,PosY,OwerPlayerID)->
	%%如果玩家是死的，直接原地复活
	Player=map:getPlayer(PlayerID),
	case Player of
		{}->
			Result=false,
			ok;
		_->
			case mapActorStateFlag:isStateFlag( PlayerID ,
						?Player_State_Flag_Convoy bor ?Player_State_Flag_ChangingMap ) of
				true->
					Result=fase;
				false->
					case mapActorStateFlag:isStateFlag( PlayerID , ?Actor_State_Flag_Dead ) of
						true->
							ReviveHP   = array:get( ?max_life, Player#mapPlayer.finalProperty ),
							Msg = #pk_GS2U_CharactorRevived{nActorID=Player#mapPlayer.id,
														  nLife=ReviveHP,
														  nMaxLife=array:get( ?max_life, Player#mapPlayer.finalProperty )
														  },
							mapView:broadcast(Msg, Player, 0),
							mapActorStateFlag:removeStateFlag(Player#mapPlayer.id, ?Actor_State_Flag_Dead),
							charDefine:changeSetLife(Player, ReviveHP, false),
							ok;
						false->ok
					end,
					%%Result=playerChangeMap:transPlayerByTransport( Player, 
					%%										MapDataID, 
					%%										PosX, 
					%%										PosY,
					%%										OwerPlayerID ),
					Result=playerChangeMap:on_playerMsg_EnterBattleCopyRequest(PlayerID,MapDataID,PosX,PosY,false,OwerPlayerID),
					ok
				end
	end,
	
	case Result of
		false->
			battleActivePID!{playerEnterBattleSceneFail,PlayerID,OwerPlayerID},
			ok;
		true->
			ok
	end,
	ok.

%%地图进程执行	,更改pk保护结束时间		
addPkProctedMark(MapPlayer,Attacker)->
	case Attacker of
			{}->
				ok;
			_->
				case element( 1, Attacker ) of
					mapPlayer->
						%%两个在切磋，不管
						case (MapPlayer#mapPlayer.qieCuoPlayerID=:= Attacker#mapPlayer.id) of
									true->
										ok;
							false->%%没切磋，加buff
								MystateFlag=MapPlayer#mapPlayer.stateFlag,
								PKKillState = ( ?Player_State_Flag_PK_Kill bor ?Player_State_Flag_PK_Kill_Value ),
								case ( MystateFlag band PKKillState ) /= 0 of
									true ->
										variant:setPlayerVarValueFromMap(MapPlayer,?PlayerVariant_Index_InPeaceKilledByPlayerTime_M,0);%%非和平，时间清掉
									false->
										%%给玩家加buff
										%%如果在战场，不加
										MapCfg=map:getMapCfg(),
										case MapCfg#mapCfg.type=:= ?Map_Type_Battle of
											true->
												ok;
											false->
												case etsBaseFunc:readRecord( main:getGlobalBuffCfgTable(), ?KillByPlayerReLiveBuffID ) of
													{}->ok;
													AddBuffCfg->
														buff:addBuffer( MapPlayer#mapPlayer.id, AddBuffCfg, 0, 0, {},0 )
												end,
												variant:setPlayerVarValueFromMap(MapPlayer,?PlayerVariant_Index_InPeaceKilledByPlayerTime_M,( ?PKProctedLastTime div 1000 )+common:getNowSeconds()),%%和平
												ok
										end
								end
						end;
					_->
					ok
				end
	end,
ok.

pKProctLeftTime(MapPlayerID)->
	MapPlayer=map:getPlayer(MapPlayerID),
	case MapPlayer of
		{}->
			LeftTime=0;
		_->
			PlayerVarArray=MapPlayer#mapPlayer.varArray,
			case  variant:getPlayerVarValue(PlayerVarArray,?PlayerVariant_Index_InPeaceKilledByPlayerTime_M) of
				undefined->
					ProctedEndTime=0;
				_Any->
					ProctedEndTime=_Any
			end,
			NowTime=common:getNowSeconds(),
			case NowTime< ProctedEndTime of
				true->
					LeftTime=ProctedEndTime-NowTime;
				false->
					LeftTime=0
			end
	end,
	LeftTime*1000.

%%地图进程，处理玩家请求查看其它玩家属性消息
on_LookPlayerInfo( PID, PlayerID, Msg )->
	try
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->throw(-1);
			_->ok
		end,
		Array = Player#mapPlayer.finalProperty,
		
		PropertyIndexRecord = {?max_life, ?attack, ?defence, ?hit, ?hit_rate_rate, ?dodge, ?dodge_rate, ?crit, ?crit_rate, ?crit_damage_rate, 
							   ?block, ?block_rate,?tough,?tough_rate, ?block_dec_damage, ?attack_speed, ?attack_speed_rate,?pierce,?pierce_rate,
							   ?fire_def, ?ph_def, ?ice_def, ?hold_def, ?elec_def, ?move_def,?coma_def,?silent_def,?poison_def },
		
		MyFunc = fun( Index )->
						 PropertyIndex = element( Index, PropertyIndexRecord ),
						 NValue=array:get( PropertyIndex, Array ),
						 #pk_CharPropertyData{nPropertyType=PropertyIndex, nValue=NValue }
				 end,
		
		InfoList = common:for( 1, size(PropertyIndexRecord), MyFunc ),
		
		Msg2= Msg#pk_RequestLookPlayer_Result{ propertyList = InfoList},
		
		player:sendToPlayerByPID(PID, Msg2),
		
		ok
	catch
		_->player:sendToPlayerByPID(PID, #pk_RequestLookPlayerFailed_Result{result=?LookPlayerInfo_Failed_UnKnow})
	end.

%%地图进程，请求改变玩家的声望值	
changePlayerCredit(PlayerID,Value,Reason)->
	
	try
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->throw(-1);
			_->ok
		end,
		player:sendMsgToPlayerProcess(Player#mapPlayer.id, {request_change_Credit,Value,Reason}),
		ok
	catch
			_-> ok
	end.

%%地图进程，获得玩家声望值
getPlayerCredit(PlayerID)->
	try
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->throw({-1,0});
			_->ok
		end,
		Result=Player#mapPlayer.credit,
		Result
	catch
		{_,Return}-> 
			Return
	end.

updatePlayerGuildInfo( PlayerID, GulidID, GuildName, GuildRank )->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerID) of
		{}->ok;
		Player->
			Player2 = Player#mapPlayer{guildID=GulidID, guildName=GuildName, guildRank=GuildRank},
			etsBaseFunc:insertRecord(map:getMapPlayerTable(), Player2),
			Msg = #pk_GS2U_UpdatePlayerGuildInfo{ player_id=PlayerID, guild_id=GulidID, guild_name=GuildName, guild_rank=GuildRank},
			mapView:broadcast( Msg, Player, 0 )
	end,
	ok.

onVIPLevelChange( PlayerID, VipLevel, VipTimeExpire, _VipTimeBuy)->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerID) of
		{}->ok;
		Player->
			Now = common:timestamp(),
			case Now > VipTimeExpire of
				true->RealVIPLevel = 0;
				_->RealVIPLevel=VipLevel
			end,
			
			etsBaseFunc:changeFiled(map:getMapPlayerTable(), PlayerID, #mapPlayer.vipLevel, RealVIPLevel),
			Msg = #pk_UpdateVIPLevelInfo{ playerID=PlayerID, vipLevel=RealVIPLevel},
			mapView:broadcast(Msg, Player, PlayerID)
	end.
	
onChangeGameSetup( PlayerID, GameSteup )->
	etsBaseFunc:changeFiled(map:getMapPlayerTable(), PlayerID, #mapPlayer.gameSetMenu, GameSteup).


  
  

