-module(copyMap_Battle).

-include("db.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("monsterDefine.hrl").
-include("scriptDefine.hrl").
-include("active_battle.hrl").
-include("textDefine.hrl").
-include("chat.hrl").
-include("variant.hrl").

-record(battleOccuping,{iID,posX,posY,playerID}).%%记录战场进入情况
-record(continusKillBroadcast,{continusKillNum,broadcastContent}).%%战场连杀公告


-compile(export_all). 


init()->
	?DEBUG_OUT( "copyMap_Battle init"),
	MapRegisterFun=fun(MapID)->
						   scriptManager:registerScript( ?Object_Type_Map, MapID, ?Map_Event_Init, ?MODULE, map_Battle_Map_Event_Init, MapID ),
				   			%%玩家进入地图
						   %%scriptManager:registerScript( ?Object_Type_Map, MapID, ?Map_Event_Player_Enter, ?MODULE, map_Battle_PlayerEnter_Init, MapID ),
							%%玩家离开地图
							%%scriptManager:registerScript( ?Object_Type_Map, MapID, ?Map_Event_Player_Leave, ?MODULE, map_Battle_PlayerLeave_Init, MapID ),
						   ok
				end,
	lists:foreach(MapRegisterFun, getRegisterMapList()),

	
	%%玩家离开
	%%scriptManager:registerScript( ?Object_Type_Player, ?Global_Object_Player,
	%%							   ?Char_Event_Leave_Map, ?MODULE, copyMap_Battle_Player_LeaveMapEvent, 0 ),
	
	%%玩家死亡
	%%scriptManager:registerScript( ?Object_Type_Player, ?Global_Object_Player,
	%%							   ?Char_Event_Dead, ?MODULE, copyMap_Battle_Player_DeadEvent, 0 ),
	
	%%阵营boss死亡
	scriptManager:registerScript( ?Object_Type_Monster, active_battle:getBossIDByCampus(?CAMP_TIANJI),
								   ?Char_Event_Dead, ?MODULE, copyMap_Battle_Tianji_DeadEvent, 0 ),
	scriptManager:registerScript( ?Object_Type_Monster, active_battle:getBossIDByCampus(?CAMP_XUANZONG),
								   ?Char_Event_Dead, ?MODULE, copyMap_Battle_Xuanzong_DeadEvent, 0 ),
	
	?DEBUG_OUT( "copyMap_Battle init success"),
	ok.

getRegisterMapList()->
	_Result=[active_battle:getBattleMapDataID()].



map_Battle_Map_Event_Init( _Object, _EventParam, _RegParam )->

	active_battle:initParam(),
	put("xuanzongScore",0),
	put("tianjiScore",0),
	put("ResourceTakeupTable",ets:new(resourceTakeupTable, [private, { keypos, #resourceTakeupInfo.iID }] )),
	put("ContinusKillInfo",ets:new(playerContinusKillTable, [private, { keypos, #playerContinusKill.playerID }] )),
	put("BattleInProcessing",true),
	put("IamBattleScene",true),
	put("LimitPlayerMove",true),
	setAddScoreTimer(),
	initOccuping(),
	initContinusKill(),
	
	
	%%玩家死亡，阵营boss 丝袜网
	objectEvent:registerObjectEvent(_Object, 
									?Map_Event_Char_Dead, 
									?Object_Type_Map, 
									_RegParam, 
									?MODULE, 
									copyMap_Battle_Player_DeadEvent, 0),
	%%玩家离开
	objectEvent:registerObjectEvent(_Object, 
									?Map_Event_Player_Leave, 
									?Object_Type_Map, 
									_RegParam, 
									?MODULE, 
									copyMap_Battle_Player_LeaveMapEvent, 0),
	%%玩家进入
	objectEvent:registerObjectEvent(_Object, 
									?Map_Event_Player_Enter, 
									?Object_Type_Map, 
									_RegParam, 
									?MODULE, 
									copyMap_Battle_Player_EnterMapEvent, 0),
	%%玩家在战场受伤
	objectEvent:registerObjectEvent(_Object, 
									?Map_Event_Char_Harmed, 
									?Object_Type_Map, 
									_RegParam, 
									?MODULE, 
									copyMap_Battle_Player_HarmedEvent, 0),
	%%玩家在战场造成伤害
	objectEvent:registerObjectEvent(_Object, 
									?Map_Event_Char_Damage, 
									?Object_Type_Map, 
									_RegParam, 
									?MODULE, 
									copyMap_Battle_Player_DamageEvent, 0),
	
	%%采集点被采集
	objectEvent:registerObjectEvent(_Object, 
									?Map_Event_Object_Interact, 
									?Object_Type_Map, 
									_RegParam, 
									?MODULE, 
									copyMap_Battle__Collected_Event, 0),
	
	
	%%CollectRegisterFun=fun(CollectDataID)->
	%%		scriptManager:registerScript( ?Object_Type_COLLECT, CollectDataID,
	%%							   ?Object_Event_Interact, ?MODULE, copyMap_Battle__Collected_Event, CollectDataID )
	%%				 	end,
	%%lists:foreach(CollectRegisterFun, getCollectList()),

	%%副本开启后，加个定时器，一定时间内开启战场
	timer:send_after(active_battle:getBattleWaitingInterval()*1000, {battleBeginFight}),
	put("BattleOpenTime",common:getNowSeconds()+active_battle:getBattleWaitingInterval()),
	?DEBUG_OUT( "waiting open battle for ~p s",[active_battle:getBattleWaitingInterval()]),
	
	%%战场没结束，无人销毁时间很长，相当于不销毁。战场结束后无人销毁时间便为0
	map:setCopyMapNoPlayerDetroyTime( ?BattleMap_NoPlayer_Destroy_Time ),
	ok.

map_Battle_PlayerEnter_Init( _Object, _EventParam, _RegParam )->
	
	ok.

map_Battle_PlayerLeave_Init( _Object, _EventParam, _RegParam )->
	
	ok.


copyMap_Battle__Collected_Event( _Object, EventParam, _RegParam )->
	?DEBUG_OUT( "copyMap_Battle__Collected_Event"),
	{Object,PlayerID}=EventParam,
	ObjDataID=Object#mapObjectActor.object_data_id,
	GatherIDList=[active_battle:getResourceIDByCampus(?CAMP_COUNT),active_battle:getResourceIDByCampus(?CAMP_TIANJI),
				  active_battle:getResourceIDByCampus(?CAMP_XUANZONG)],
	SpawnData=Object#mapObjectActor.spawnData,
	BornPos=#posInfo{x=SpawnData#mapSpawn.x,y=SpawnData#mapSpawn.y},
	FunRebornResource=fun(ResourceID)->
							  case ResourceID=:=ObjDataID of
								  true->
									  case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerID) of
										  {}->
											?DEBUG_OUT( "copyMap_Battle__Collected_Event 1"),
											  bornResource(BornPos,?CAMP_COUNT),
											  ok;
										  MapPlayer->
											?DEBUG_OUT( "copyMap_Battle__Collected_Event 2"),
											
											%%如果采集点的所属没变化，不发消息了
											case  active_battle:getResourceIDByCampus(MapPlayer#mapPlayer.faction)=:= ObjDataID of
												true->
													ok;
												false->
													case MapPlayer#mapPlayer.faction of
														?CAMP_TIANJI->
															CampusText=?CampusTianji;
														_->
															CampusText=?CampusXuanzong
													end,
											
													Msg=#pk_SysMessage{type=?SYSTEM_MESSAGE_TIPS,
														text=io_lib:format(?BroadcastResourceTakeup, [CampusText,MapPlayer#mapPlayer.name])},
													broadCastWholeScene(Msg)
											end,
											bornResource(BornPos,MapPlayer#mapPlayer.faction),
											  ok
									  end,
									  ok;
								  false->
									  ok
							  end
					  end,
	lists:foreach(FunRebornResource, GatherIDList),
	ok.

copyMap_Battle_Player_LeaveMapEvent( _Object, _EventParam, _RegParam )->
	%%战场中玩家人跑光了，等time out 吧 orz
	%%?DEBUG_OUT( "copyMap_Battle_Player_LeaveMapEvent"),
	case element( 1, _EventParam ) of
		mapPlayer->
			player:sendMsgToPlayerProcess(_EventParam#mapPlayer.id, {playerNowLeaveBattleScene}),
			case get("BattleInProcessing") of
				true->
					?DEBUG_OUT( "copyMap_Battle_Player_LeaveMapEvent"),
					%%不往战场里面补充人员，这里不执行
					%%active_battle:leaveBattleScene(_EventParam#mapPlayer.id, _EventParam#mapPlayer.faction);
					noLimitMove(_EventParam),
					ok;
				_->
					ok
			end,
			
			%%检测玩家数量，如果没人，那么发消息说关闭
			%%在处理事件的时候，玩家还没删掉
			%%功能不要
			%%OnlinePlayers = ets:info( map:getMapPlayerTable(), size ),
			%%case OnlinePlayers =<1  andalso get("BattleInProcessing") =:=true of
			%%	true->
			%%		?DEBUG_OUT("No Player request Shutdown "),
			%%		active_battle:tellManagerNoPlayerClose(),
			%%		ok;
			%%	false->ok
			%%end,
			ok;
		_->
			ok
	end,
	ok.

copyMap_Battle_Player_HarmedEvent( _Object, _EventParam, _RegParam )->
	{Object,_Killer,DamageHP}=_EventParam,
	case element( 1, Object )=:=mapPlayer of
		true->
			case ets:lookup(get("ContinusKillInfo"),Object#mapPlayer.id ) of
				[]->
					ets:insert(get("ContinusKillInfo"), #playerContinusKill{playerID=Object#mapPlayer.id,playerName=Object#mapPlayer.name,
							continusKillNum=0,numOfBeKilled=0,numOfKill=0,campus=Object#mapPlayer.faction,harmed=DamageHP,harm=0}),
					ok;
				[ContinusKill|_]->
					ets:update_element(get("ContinusKillInfo"),Object#mapPlayer.id, 
							{#playerContinusKill.harmed,ContinusKill#playerContinusKill.harmed+DamageHP}),
					%%?DEBUG_OUT( "harmed ~p ~p",[Object#mapPlayer.id,ContinusKill#playerContinusKill.harmed+DamageHP]),
					ok
			end;
		_->
			ok
	end,
	ok.

copyMap_Battle_Player_DamageEvent( _Object, _EventParam, _RegParam )->
	{__Object,Killer,DamageHP}=_EventParam,
	case element( 1, Killer )=:=mapPlayer of
		true->
			case ets:lookup(get("ContinusKillInfo"),Killer#mapPlayer.id ) of
				[]->
					ets:insert(get("ContinusKillInfo"), #playerContinusKill{playerID=Killer#mapPlayer.id,playerName=Killer#mapPlayer.name,
							continusKillNum=0,numOfBeKilled=0,numOfKill=0,campus=Killer#mapPlayer.faction,harmed=0,harm=DamageHP}),
					ok;
				[ContinusKill|_]->
					ets:update_element(get("ContinusKillInfo"),Killer#mapPlayer.id, 
							{#playerContinusKill.harm,ContinusKill#playerContinusKill.harm+DamageHP}),
					%%?DEBUG_OUT( "Damage ~p ~p",[Killer#mapPlayer.id,ContinusKill#playerContinusKill.harm+DamageHP]),
					ok
			end;
		_->
			ok
	end,
	ok.

copyMap_Battle_Player_EnterMapEvent( _Object, _EventParam, _RegParam )->
	case element( 1, _EventParam )=:=mapPlayer of
		true->
			?DEBUG_OUT( "copyMap_Battle_Player_EnterMapEvent ~p ~p",[self(),_EventParam#mapPlayer.id] ),
			case ets:lookup(get("ContinusKillInfo"),_EventParam#mapPlayer.id ) of
				[]->
					ets:insert(get("ContinusKillInfo"), #playerContinusKill{playerID=_EventParam#mapPlayer.id,playerName=_EventParam#mapPlayer.name,
							continusKillNum=0,numOfBeKilled=0,numOfKill=0,campus=_EventParam#mapPlayer.faction,harmed=0,harm=0}),
					ok;
				_->
					ok
			end,
			%%解散队伍
			player:sendMsgToPlayerProcess(_EventParam#mapPlayer.id, {playerNowEnterBattleScene}),
			
			takeupOccuping(_EventParam#mapPlayer.id),
			player:sendToPlayer(_EventParam#mapPlayer.id, #pk_GS2U_EnterBattleResult{faileReason=?Cannot_EnterBattle_Success}),
			%%qieCuo:changePKKillTime(_EventParam, 0),
			qieCuo:close_PK(_EventParam#mapPlayer.id),
			limitMove(_EventParam),
			
			%%进入战场，pk 保护取消掉
			buff:removeBuffByEffectType(_EventParam#mapPlayer.id, ?Buff_Effect_Type_PKProcted),
			variant:setPlayerVarValueFromMap(_EventParam,?PlayerVariant_Index_InPeaceKilledByPlayerTime_M,0),
			%%告知玩家剩余时间
			LeftOpenTime=get("BattleOpenTime") -common:getNowSeconds(),
			case LeftOpenTime> 0 of
				true->
					Packet=#pk_GS2U_LeftOpenTime{leftOpenTime=LeftOpenTime};
				_->
					Packet=#pk_GS2U_LeftOpenTime{leftOpenTime=0}
			end,
			player:sendToPlayer(_EventParam#mapPlayer.id, Packet),
			ok;
		false->
			ok
	end,
ok.

copyMap_Battle_Player_DeadEvent( _Object, _EventParam, _RegParam )->
	{Object,Killer}=_EventParam,
	%%?DEBUG_OUT( "copyMap_Battle_Player_DeadEvent _EventParam=~p",[_EventParam] ),
	
	%%被杀的玩家死亡次数更新
	case element( 1, Object )=:=mapPlayer of
	%%清掉玩家的连杀，统计被杀
		true->
			%%统计被杀
			case ets:lookup(get("ContinusKillInfo"),Object#mapPlayer.id ) of
				[]->
					ets:insert(get("ContinusKillInfo"), #playerContinusKill{playerID=Object#mapPlayer.id,playerName=Object#mapPlayer.name,
							continusKillNum=0,numOfBeKilled=1,numOfKill=0,campus=Object#mapPlayer.faction,harmed=0,harm=0}),
					ok;
				[BeenKill|_]->
					ets:update_element(get("ContinusKillInfo"),Object#mapPlayer.id, 
							{#playerContinusKill.numOfBeKilled,BeenKill#playerContinusKill.numOfBeKilled+1}),
					ok
			end;
		_->
			ok
	end,
	
	%%杀死玩家的得是玩家才进行分数计算
	case element( 1, Killer )=:=mapPlayer andalso element( 1, Object )=:=mapPlayer of
		true->
			%%?DEBUG_OUT( "copyMap_Battle_Player_DeadEvent kill by mapplayer" ),
			%%清掉玩家的连杀
			case ets:lookup(get("ContinusKillInfo"),Object#mapPlayer.id ) of
				[]->
					
					ok;
				_->
					ets:update_element(get("ContinusKillInfo"),Object#mapPlayer.id, {#playerContinusKill.continusKillNum,0}),
					ok
			end,
			
			
			%%统计杀人玩家的连杀，统计杀人数量
			case ets:lookup(get("ContinusKillInfo"),Killer#mapPlayer.id ) of
				[]->
					ets:insert(get("ContinusKillInfo"), #playerContinusKill{playerID=Killer#mapPlayer.id,playerName=Killer#mapPlayer.name,
							continusKillNum=1,numOfBeKilled=0,numOfKill=1,campus=Killer#mapPlayer.faction,harmed=0,harm=0}),
					broadcastContinusKill(Killer#mapPlayer.name,1),
					ContinusKillNum=1,
					%%?DEBUG_OUT("continus kill insert ~p",[Killer#mapPlayer.id]),
					ok;
				[ContinusKill|_]->
					ets:update_element(get("ContinusKillInfo"),Killer#mapPlayer.id, 
									   {#playerContinusKill.continusKillNum,ContinusKill#playerContinusKill.continusKillNum+1}),
					ets:update_element(get("ContinusKillInfo"),Killer#mapPlayer.id, 
							{#playerContinusKill.numOfKill,ContinusKill#playerContinusKill.numOfKill+1}),
					%%?DEBUG_OUT("kill update ~p ~p",[Killer#mapPlayer.id,ContinusKill#playerContinusKill.numOfKill+1]),
					broadcastContinusKill(Killer#mapPlayer.name,ContinusKill#playerContinusKill.numOfKill+1),
					ContinusKillNum=ContinusKill#playerContinusKill.numOfKill+1,
					%%?DEBUG_OUT("continus kill update ~p ~p",[Killer#mapPlayer.id,ContinusKillNum]),
					ok
			end,
			
			%%根据玩家的连杀给分
			AddScore=calculateKillScore(),
			case Killer#mapPlayer.faction =:= ?CAMP_TIANJI of
				true->
					%%put("tianjiScore",get("tianjiScore")+AddScore),
					addCampusScore(?CAMP_TIANJI,AddScore),
					ok;
				false->
					%%put("xuanzongScore",get("xuanzongScore")+AddScore),
					addCampusScore(?CAMP_XUANZONG,AddScore),
					ok
			end,
			%%根据连杀给荣誉
			addContinusKillHonor(Killer,ContinusKillNum),
		
		
			%%分数改变了，检测是否战斗结束
			whetherBatterEnd(),
			
			ok;
		_->
			ok
	end,
	
	case element( 1, Object )=:=mapPlayer of
		true->
			%%把死亡玩家放到复活点复活
			timer:send_after(active_battle:getBattleReliveDelay()*1000, {battleMapRelive,Object}),
			%%一定时间内禁止复活
			self()!{banPlayerRelive,Object,active_battle:getBattleReliveDelay()},
			ok;
		false->
			ok
	end,
	ok.

relive(Object)->
	?DEBUG_OUT( "player ~p relive " ,[Object#mapPlayer.id]),
	ReviveHP   = array:get( ?max_life, Object#mapPlayer.finalProperty ),
	Msg = #pk_GS2U_CharactorRevived{nActorID=Object#mapPlayer.id,
								  nLife=ReviveHP,
								  nMaxLife=array:get( ?max_life, Object#mapPlayer.finalProperty )
								  },
	mapView:broadcast(Msg, Object, 0),
	mapActorStateFlag:removeStateFlag(Object#mapPlayer.id, ?Actor_State_Flag_Dead),
	charDefine:changeSetLife(Object, ReviveHP, true),
	
	MyEnterPos=active_battle:getBirthPositionByCampus(Object#mapPlayer.faction),
	playerMove:setPos(Object, MyEnterPos#posInfo.x, MyEnterPos#posInfo.y),
	%%如果战斗结束了，丢出去
	%%case get("BattleInProcessing") of
	%%	true->
	%%		ok;
	%%	false->
	%%		playerMap:on_PlayerLeaveCopyMap(Object#mapPlayer.id),
	%%		ok
	%%end,
ok.


calculateKillScore()->
	_Score=active_battle:getScoreOfKillingOnePlayer().

addContinusKillHonor(Killer,ContinusKillNum)->
	%%?DEBUG_OUT( "addContinusKillHonor ~p ~p",[Killer#mapPlayer.id,ContinusKillNum]),
	player:addPlayerHonor(Killer#mapPlayer.id,active_battle:getContinusKillHonor(ContinusKillNum),true, 0),
	ok.

whetherBatterEnd()->
	broadCastBattleScore(),
	case get("xuanzongScore")>=active_battle:getBattleTotalScore() orelse
		  get("tianjiScore")>=active_battle:getBattleTotalScore() of
		true->
			case get("BattleInProcessing") of
				true->
					%%发了消息告诉管理器战场结束。那么就结束了
					active_battle:tellManagerbattleEnd(),
					put("BattleInProcessing",false);
				_->
					ok
			end,
			ok;
		false->
			ok
	end,
	ok.

onBattleTimeOut()->
	case get("BattleInProcessing") of
		true->
			%%发了消息告诉管理器战场结束。那么就结束了
			active_battle:tellManagerbattleEnd(),
			put("BattleInProcessing",false);
		_->
			ok
	end.

calculateFinalResult()->
	?DEBUG_OUT( "calculateFinalResult"),
	put("BattleInProcessing",false),
	%%把战场整个击杀情况广播
	broadcastBattleResult(),
	%%给奖励
	active_battle:gaveFinalBattleAward(),
	%%把玩家弄出去
	%%FunLetActorLeave=fun(MapPlayer)->
	%%						 playerMap:on_PlayerLeaveCopyMap(MapPlayer#mapPlayer.id)
	%%				 end,
	%%etsBaseFunc:etsFor(map:getMapPlayerTable(), FunLetActorLeave),
	
	%%战场结束了，无人立马销毁
	map:setCopyMapNoPlayerDetroyTime( 0 ),
	ok.

requestLeaveBattle()->%%玩家进程调用
	player:getCurPlayerProperty(#player.mapPID)!{msgrequestLeaveBattle,player:getCurPlayerID()},
	ok.

onRequestLeaveMap(PlayerID)->
	case get("IamBattleScene") of
		true->
			playerMap:on_PlayerLeaveCopyMap(PlayerID);
		_->
			ok
	end,
	ok.
			


setAddScoreTimer()->
	case active_battle:inBattleActivePeriod() of
		true->
			%%put("BattleInProcessing",true),
			case get("BattleInProcessing") of
				true->
					timer:send_after(active_battle:getResIncreaseScoreInterval()*1000,{battleActiveAddScore} );
				false->
					ok
			end,
			ok;
		false->
			ok
	end,
	ok.

onAddScoreTimer()->
	%%根据占用情况加分
	FunAddScore=fun(ResInfo)->
							case ResInfo#resourceTakeupInfo.campus=:=?CAMP_TIANJI of
								true->
									AddScore=active_battle:getResourceIncreaseScore(),
									%%put("tianjiScore",get("tianjiScore")+AddScore),
									addCampusScore(?CAMP_TIANJI,AddScore),
									ok;
								false->
									ok
							end,
							case ResInfo#resourceTakeupInfo.campus=:=?CAMP_XUANZONG of
								true->
									AddScore2=active_battle:getResourceIncreaseScore(),
									%%put("xuanzongScore",get("xuanzongScore")+AddScore2),
									addCampusScore(?CAMP_XUANZONG,AddScore2),
									ok;
								false->
									ok
							end,
							ok
				end,
	lists:foreach(FunAddScore, ets:tab2list(get("ResourceTakeupTable"))),
	whetherBatterEnd(),
	setAddScoreTimer(),
	ok.

addCampusScore(Campus,AddScore)->
	case get("BattleInProcessing") of 
		false->
			ok;
		true->
			case Campus=:=?CAMP_XUANZONG of
				true->
					put("xuanzongScore",get("xuanzongScore")+AddScore),
					?DEBUG_OUT("xuanzong new score ~p",[get("xuanzongScore")]),
					ok;
				_->
					put("tianjiScore",get("tianjiScore")+AddScore),
					?DEBUG_OUT("tianjiScore new score ~p",[get("tianjiScore")]),
					ok
			end,
			ok
	end,
	ok.

copyMap_Battle_Xuanzong_DeadEvent( _Object, _EventParam, _RegParam )->
	%%玄宗boss 死了给天机加分
	AddScore=active_battle:getBossKillScore(),
	%%put("tianjiScore",get("tianjiScore")+AddScore),
	addCampusScore(?CAMP_TIANJI,AddScore),
	whetherBatterEnd(),
	ok.

copyMap_Battle_Tianji_DeadEvent( _Object, _EventParam, _RegParam )->
	AddScore=active_battle:getBossKillScore(),
	%%put("xuanzongScore",get("xuanzongScore")+AddScore),
	addCampusScore(?CAMP_XUANZONG,AddScore),
	whetherBatterEnd(),
	ok.

broadcastBattleResult()->
	BattleResult=#pk_BattleResultList{resultList=make_Battle_Result_list()},
	Func=fun(MapPlayer)->
				 player:sendToPlayer(MapPlayer#mapPlayer.id, BattleResult)
		 end,
	%%?DEBUG_OUT("broadcastBattleResult"),
	etsBaseFunc:etsFor(map:getMapPlayerTable(), Func),
	%%?DEBUG_OUT("broadcastBattleResult success"),
	ok.
	
make_Battle_Result_list()->
	FunBattleList=fun(Record)->
						  #pk_battleResult{playerID=Record#playerContinusKill.playerID,name=Record#playerContinusKill.playerName,campus=Record#playerContinusKill.campus,
										   killPlayerNum=Record#playerContinusKill.numOfKill,beenKiiledNum=Record#playerContinusKill.numOfBeKilled,
										   harm=Record#playerContinusKill.harm,harmed=Record#playerContinusKill.harmed}
				  end,
	BattleResultList0=lists:map(FunBattleList, ets:tab2list(get("ContinusKillInfo"))),
	MyFunc = fun( Record )->
					Record =/= {}
			 end,
	lists:filter(MyFunc, BattleResultList0).

%%玩家进程调用
request_Battle_Result_list()->
	player:getCurPlayerProperty(#player.mapPID)!{msg_request_Battle_Result_list,player:getCurPlayerProperty(#player.id)},
	ok.


on_request_Battle_Result_list(PlayerID)->
	case get("IamBattleScene") of
		true->
			BattleResult=#pk_BattleResultList{resultList=make_Battle_Result_list()},
			player:sendToPlayer(PlayerID, BattleResult);
		_->
			ok
	end.

onbattleBeginFight()->
	?DEBUG_OUT( "onbattleBeginFight"),
	%%不再把玩家移动了
	%%FunLetBeginFight=fun(MapPlayer)->
	%%						 MyEnterPos=active_battle:getBirthPositionByCampus(MapPlayer#mapPlayer.faction),
	%%						 playerMove:setPos(MapPlayer, MyEnterPos#posInfo.x, MyEnterPos#posInfo.y)
	%%				 end,
	%%etsBaseFunc:etsFor(map:getMapPlayerTable(), FunLetBeginFight),
	%%然后刷资源出来,地图直接种
	%%FunBurnResource=fun(Position)->
	%%						bornResource(Position,?CAMP_COUNT)
	%%				end,
	%%lists:foreach(FunBurnResource, active_battle:getResourcePos()),

	%%解散队伍,改到进入地图
	%%bradCastLeaveTeam(),
	%%发送初始分数
	broadCastBattleScore(),	
	%%添加定时器，战斗结束
	timer:send_after(active_battle:getBattleLastInterval()*1000, {battleTimeout}),
	
	%%之后进来的玩家不再定身了
	put("LimitPlayerMove",false),
	
	%%解除定身
	FunNoLimitMove=fun(MapPlayer)->
							 noLimitMove(MapPlayer)
					 end,
	etsBaseFunc:etsFor(map:getMapPlayerTable(), FunNoLimitMove),
	
	%%公告
	%%Msg=#pk_SysMessage{type=?SYSTEM_MESSAGE_TIPS,text=?BattleFormalOpen},
	%%broadCastWholeScene(Msg),
	
	ok.

broadCastBattleScore()->
	broadCastWholeScene(#pk_GS2U_BattleScore{xuanzongScore=get("xuanzongScore"),tianjiScore=get("tianjiScore")}),
	ok.

%%bradCastLeaveTeam()->
%%得发往玩家进程
%%	broadCastWholeScene({battleLetPlayerLeaveTeam}).

broadCastWholeScene(Msg)->
	Func=fun(#mapPlayer{id=PlayerID}=_Record)->
				 player:sendToPlayer(PlayerID, Msg)
		 end,
	etsBaseFunc:etsFor(map:getMapPlayerTable(), Func),
	ok.

bornResource(Position,Campus)->
	MapSpawn = #mapSpawn{
			id = 0,
			 mapId=map:getMapDataID(),
			 type=?Object_Type_COLLECT,
			 typeId = active_battle:getResourceIDByCampus(Campus),
			 x = Position#posInfo.x,
			 y = Position#posInfo.y,
			 param = 0,
			 isExist = true
			},
	?DEBUG_OUT( "bornResource"),
	objectActor:spawnObjectActor(MapSpawn),
	%%更新资源的占用情况
	ID=Position#posInfo.x*10000+Position#posInfo.y,
	case ets:lookup(get("ResourceTakeupTable"),ID ) of
		[]->
			ets:insert(get("ResourceTakeupTable"), #resourceTakeupInfo{iID=ID,takeupTime=common:getNowSeconds(),campus=Campus}),
			ok;
		[_Any|_]->
			ets:update_element(get("ResourceTakeupTable"), ID, {#resourceTakeupInfo.takeupTime,common:getNowSeconds()}),
			ets:update_element(get("ResourceTakeupTable"), ID, {#resourceTakeupInfo.campus,Campus}),
			ok
	end,
	ok.

initOccuping()->
	put("xuanzongOccupingTable",ets:new(xuanzongOccupingTable, [private, { keypos, #battleOccuping.iID }] )),
	put("tianjiOccupingTable",ets:new(tianjiOccupingTable, [private, { keypos, #battleOccuping.iID }] )),
	
	FunXuanzongInsert=fun(#posInfo{x=X,y=Y})->
							  ets:insert(get("xuanzongOccupingTable"), #battleOccuping{iID=X*10000+Y,posX=X,posY=Y,playerID=0})
					  end,
	lists:foreach(FunXuanzongInsert, ?XuanzongOccuping),
	
	FunTianjiInsert=fun(#posInfo{x=X,y=Y})->
							  ets:insert(get("tianjiOccupingTable"), #battleOccuping{iID=X*10000+Y,posX=X,posY=Y,playerID=0})
					  end,
	lists:foreach(FunTianjiInsert, ?TianjiOccuping),
	
	ok.

takeupOccuping(PlayerID)->
	%%?DEBUG_OUT( "takeupOccuping [~p]", [PlayerID] ),
	try
		Player=etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerID),
		 case Player of
			 {}->
				 %%?DEBUG_OUT( "takeupOccuping 2 [~p]", [PlayerID] ),
				 ok;
			 _->
				 %%?DEBUG_OUT( "takeupOccuping 3 [~p]", [PlayerID] ),
				case get("LimitPlayerMove") of
					%%活动开启了再进来，到哪里算哪里，不站队
						false->
							throw({return});
						true->
							ok
				end,
				%% ?DEBUG_OUT( "takeupOccuping 4 [~p]", [PlayerID] ),
				 case Player#mapPlayer.faction =:= ?CAMP_TIANJI of
					 true->
						 Func=fun(#battleOccuping{iID=ID,playerID=OccupingPlayerID}=Record)->
							 case OccupingPlayerID=:=0 of 
								 true->
									 ?DEBUG_OUT( "Player[~p] takeup [~p]", [PlayerID, ID] ),
									 ets:update_element(get("tianjiOccupingTable"), ID, {#battleOccuping.playerID,PlayerID}),
									 playerMove:setPos(Player, Record#battleOccuping.posX, Record#battleOccuping.posY),
									 throw({return});
								 false->
									 ok
							 end
						 end,
						etsBaseFunc:etsFor(get("tianjiOccupingTable"), Func),
						 ok;
					 false->
						 Func=fun(#battleOccuping{iID=ID,playerID=OccupingPlayerID}=Record)->
							 case OccupingPlayerID=:=0 of 
								 true->
									 ?DEBUG_OUT( "Player[~p] takeup22 [~p]", [PlayerID, ID] ),
									 ets:update_element(get("xuanzongOccupingTable"), ID, {#battleOccuping.playerID,PlayerID}),
									 playerMove:setPos(Player, Record#battleOccuping.posX, Record#battleOccuping.posY),
									 throw({return});
								 false->
									 ok
							 end
						 end,
						etsBaseFunc:etsFor(get("xuanzongOccupingTable"), Func),
						 ok
				 end
		 end,
	ok
	catch
		_->
			ok
	end.

removeOccuping(PlayerID)->
	Func=fun(#battleOccuping{iID=ID,playerID=OccupingPlayerID})->
					 case OccupingPlayerID=:=PlayerID of 
						 true->
							 ets:update_element(get("battleOccupingTable"), ID, {#battleOccuping.playerID,0}),
							 throw({return});
						 false->
							 ok
					 end
			 end,
		etsBaseFunc:etsFor(get("battleOccupingTable"), Func),
	ok.

initContinusKill()->
	put("continusKillBroadcastTable",ets:new(continusKillBroadcastTable, [private, { keypos, #continusKillBroadcast.continusKillNum }] )),
	ets:insert(get("continusKillBroadcastTable"),
			    #continusKillBroadcast{continusKillNum=5,broadcastContent=?ContinusKillBroadcast1}),
	ets:insert(get("continusKillBroadcastTable"),
			    #continusKillBroadcast{continusKillNum=10,broadcastContent=?ContinusKillBroadcast2}),
	ets:insert(get("continusKillBroadcastTable"),
			    #continusKillBroadcast{continusKillNum=20,broadcastContent=?ContinusKillBroadcast3}),
	ets:insert(get("continusKillBroadcastTable"),
			    #continusKillBroadcast{continusKillNum=30,broadcastContent=?ContinusKillBroadcast4}),
	ets:insert(get("continusKillBroadcastTable"),
			    #continusKillBroadcast{continusKillNum=50,broadcastContent=?ContinusKillBroadcast5}),
	ok.

broadcastContinusKill(PlayerName,ContinusKill)->
	%%?DEBUG_OUT( "broadcastContinusKill ~p",[ContinusKill]),
	Func=fun(#continusKillBroadcast{continusKillNum=KillNun,broadcastContent=Content})->
				 case KillNun=:=ContinusKill of
					 true->
						 Msg=#pk_SysMessage{type=?SYSTEM_MESSAGE_TIPS,
												text=io_lib:format(Content, [PlayerName])},
											broadCastWholeScene(Msg),
						 ok;
					 _->
						 ok
				 end
		 end,
	etsBaseFunc:etsFor(get("continusKillBroadcastTable"),Func),
	ok.

limitMove(MapPlayer)->
	case get("LimitPlayerMove") of
		true->
			?DEBUG_OUT( "limitMove ~p",[MapPlayer#mapPlayer.id]),
			mapActorStateFlag:addStateFlag(MapPlayer#mapPlayer.id, ?Player_State_Flag_Just_Disable_Move),
			ok;
		false->
			ok
	end,
ok.

noLimitMove(MapPlayer)->
	?DEBUG_OUT( "noLimitMove"),
	mapActorStateFlag:removeStateFlag(MapPlayer#mapPlayer.id, ?Player_State_Flag_Just_Disable_Move),
ok.