%%Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(playerChangeMap).

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
-include("logdb.hrl").
-include("textDefine.hrl").


%%
%% Exported Functions
%%
-compile(export_all). 

%%地图进程超时释放玩家地图切换状态
on_timeOutOfTransPlayer( PlayerID )->
	try
		case mapActorStateFlag:isStateFlag( PlayerID, ?Player_State_Flag_ChangingMap ) of
			true->
				?DEBUG_OUT( "player[~p] trans to map[~p] time out", [PlayerID, self()] ),
				%%解除无敌
				%%?
				mapActorStateFlag:removeStateFlag( PlayerID, ?Player_State_Flag_ChangingMap );
			false->ok
		end,

		ok
	catch
		_->ok
	end.

%%玩家请求进入地图，通过GM指令
on_enterMapByGM( PlayerID, MapDataID )->
	try
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->throw(-1);
			_->ok
		end,
		
		MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), MapDataID ),
		case MapCfg of
			{}->throw(-1);
			_->ok
		end,
		
		case MapCfg#mapCfg.type of
			?Map_Type_Normal_World->
				transPlayerByTransport( Player, MapDataID, playerMap:getPlayerPosX(Player), playerMap:getPlayerPosY(Player) );
			?Map_Type_Normal_Copy->
				on_playerMsg_EnterCopyMapRequest( PlayerID, MapDataID, playerMap:getPlayerPosX(Player), playerMap:getPlayerPosY(Player), false );
			?Map_Type_Battle->
				on_playerMsg_EnterCopyMapRequest( PlayerID, MapDataID, playerMap:getPlayerPosX(Player), playerMap:getPlayerPosY(Player), false );
			_->ok
		end,

		ok
	catch
		_->ok
	end.


%%地图进程，处理玩家切换地图请求，通过传送点传送
transPlayerByTransport( Player, MapDataID, EnterMapPosX, EnterMapPosY )->
	try
		PlayerID = Player#mapPlayer.id,
		
		NotTransState = ?Actor_State_Flag_Dead bor
						?Player_State_Flag_ChangingMap,
		case mapActorStateFlag:isStateFlag( PlayerID , NotTransState ) of
			true->throw(-1);
			false->ok
		end,
		
		case map:getMapDataID() =:= MapDataID of
			true->throw(-1);%%相同地图ID不需要走这里切换
			false->ok
		end,
		
		MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), MapDataID ),
		case MapCfg of
			{}->throw(-1);
			_->
				%%传送点目的地一定是世界地图，张龙说，2013.1.17
				case MapCfg#mapCfg.type =:= ?Map_Type_Normal_World of
					true->ok;
					false->throw(-1)
				end
		end,
		
		%%设定玩家准备切换地图
		setPlayerReadyToChangeMap( Player ),

		%%想地图管理进程请求
		Param = { EnterMapPosX, EnterMapPosY },
		CallBack = #call_back{module=?MODULE, call_func=transPlayerByTransport_CallBack },
		TargetMapInfo = {0, MapDataID, CallBack, false, Param},
		mapManagerPID ! { getReadyToEnterMap, self(), 0, [Player], TargetMapInfo },
		
		?DEBUG_OUT( "player[~p] trans to map[~p ~p] request", [PlayerID, self(), TargetMapInfo] ),
		
		true
	catch
		_->false
	end.

transPlayerByTransport_CallBack( TargetMapPID, _OwnerID, EnterPlayerList, TargetMapInfo, Result )->
	try
		{_MapID, _MapDataID, _ReadyResult_CallBack, _NotCreate, Param} = TargetMapInfo,
		{ EnterMapPosX, EnterMapPosY } = Param,
		
		{ CanEnter, _Fail_Code } = Result,
		case CanEnter of
			true->%%可以进入
				[Player|_] = EnterPlayerList,
				doTransMap( TargetMapPID, Player, EnterMapPosX, EnterMapPosY );
			false->ok
		end,
		ok
	catch
		_->ok
	end.


%%设定玩家准备切换地图
setPlayerReadyToChangeMap( Player )->
	%%增加无敌
	%%?
	mapActorStateFlag:addStateFlag(Player#mapPlayer.id, ?Player_State_Flag_ChangingMap),
	
	%%要超时释放玩家的状态Player_State_Flag_ChangingMap，否则一旦切换失败，并未返回，这个状态会导致玩家所有操作无法进行
	erlang:send_after( 5000,self(), {timeOutOfTransPlayer, Player#mapPlayer.id} ),
	ok.


%%地图进程，处理地图管理进程转发过来的，玩家请求准备进入地图
%%OwnerID=队伍ID、玩家ID...
%%{MapID, MapDataID, ReadyResult_CallBack, NotCreate, Param} = TargetMapInfo,
%%[Player1,Player2...]=EnterPlayerList
on_getReadyToEnterMap_CanEnter( FromPID, OwnerID, EnterPlayerList, TargetMapInfo )->
	try
		put( "OwnerID", OwnerID ),
		
		Map = map:getMapObject(),
		
		MyFunc = fun( Player )->
					PlayerID = Player#mapPlayer.id,
					
					case etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ) of
						{}->ok;
						_->throw( {?EnterMap_Fail_Exist_Player, Player} )%%已经在地图里了
					end,
					
					case etsBaseFunc:readRecord( map:getReadyEnterPlayerTable(), PlayerID ) of
						{}->
							Return = objectEvent:onEvent( map:getMapObject(), ?Map_Event_Player_CanEnter, {Player, TargetMapInfo} ),
							case Return of
								{ eventCallBackReturn, CanEnterMapReturn }->
									case CanEnterMapReturn >= 0 of
										true->ok;
										false->throw(-1)
									end,
									ok;
								_->ok
							end,	
					
							%%加入准备进入地图的玩家，以便于统计已经进入地图的玩家人数和准备进入地图的玩家人数，做人数限定
							etsBaseFunc:insertRecord( map:getReadyEnterPlayerTable(), #readyEnterMap{playerID=PlayerID, timeOut=common:timestamp() + 5 } ),
							ok;
						_->ok%%已经在准备进入队列里了
					end,
					
					{ IsEntered, _ } = common:findInList( Map#mapObject.enteredPlayerHistory, PlayerID, 0 ),
					setelement( #mapPlayer.isEnteredChangeTargetMap, Player, IsEntered )
				 end,
		New_EnterPlayerList = lists:map( MyFunc, EnterPlayerList ),
		
		FromPID ! { getReadyToEnterMap_Result, self(), OwnerID, New_EnterPlayerList, TargetMapInfo, { true, 0 } },

		ok
	catch
		{ Fail_Code, Player }->FromPID ! { getReadyToEnterMap_Result, self(), OwnerID, EnterPlayerList, TargetMapInfo, {false, Fail_Code, Player} };
		_->FromPID ! { getReadyToEnterMap_Result, self(), OwnerID, EnterPlayerList, TargetMapInfo, {false, ?EnterMap_Fail_Invalid_Call } }
	end.

%%地图进程，处理玩家请求地图切换结果
on_getReadyToEnterMap_Result( TargetMapPID, OwnerID, EnterPlayerList, TargetMapInfo, Result )->
	try
		%%先解除状态
		MyFunc = fun( Record )->
					PlayerID = Record#mapPlayer.id,
					
					Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
					case Player of
						{}->ok;
						_->
							%%解除无敌
							%%?
					
							mapActorStateFlag:removeStateFlag( PlayerID, ?Player_State_Flag_ChangingMap )
					end
				 end,
		lists:foreach( MyFunc, EnterPlayerList ),
		
		%%如果有回调，先调回调
		{_MapID, _MapDataID, ReadyResult_CallBack, _NotCreate, _Param} = TargetMapInfo,
		case ReadyResult_CallBack =:= 0 of
			true->ok;
			false->
				Call_Module = ReadyResult_CallBack#call_back.module,
				Call_Func = ReadyResult_CallBack#call_back.call_func,
				Call_Module:Call_Func( TargetMapPID, OwnerID, EnterPlayerList, TargetMapInfo, Result )
		end,

		?DEBUG_OUT("result =~p",[Result]),
		case Result of
			{ true, _ }->ok;
			{ false, FailCode }->
				?LOG_OUT( "OwnerID[~p] trans to map[~p ~p] return false[~p]", [OwnerID, TargetMapPID, TargetMapInfo, FailCode] ),
				throw(-1);
			%%有可能返回是下面格式的 见{false, Fail_Code, Player }
			{false, FailCode, _Player }->
				?LOG_OUT( "OwnerID[~p] trans to map[~p ~p] return false[~p]", [OwnerID, TargetMapPID, TargetMapInfo, FailCode] ),
				throw(-1)
		end,

		ok
	catch
		_->ok
	end.

%%玩家进程，出来玩家同一地图闪烁请求
on_U2GS_TransForSameScence( #pk_U2GS_TransForSameScence{} = Msg )->
	try
		case get("InbattleScene") of
			true->
				?MessageTipsMe(?ForbiddenTransInBattle),
				throw(-1),
				ok;
			_->
				ok
		end,
		%% VIP玩家免费飞行 add by yueliangyou [2013-05-13]
		case vipFun:callVip(?VIP_FUN_FLY,0) of
			{ok,_}->
				%%通知地图进程
				player:sendMsgToMap({playerMsg_U2GS_TransForSameScence, self(),player:getCurPlayerID(), [], Msg });
			{_,_}->
				ItemDataID = 103,%%飞行符
				[CanDec|CanDecItemInBagResult] = playerItems:canDecItemInBag(?Item_Location_Bag, ItemDataID, 1, "all"),
				case CanDec of
					true->
						%%够扣物品
						[{Location, Cell, _}|_] = CanDecItemInBagResult,
						%%锁定物品格子
						playerItems:setLockPlayerBagCell(Location, Cell, 1),
						%%通知地图进程
						player:sendMsgToMap({playerMsg_U2GS_TransForSameScence, self(),player:getCurPlayerID(), CanDecItemInBagResult, Msg });
					false->?MessageTipsMe("没有足够的飞行符"),throw(-1)
				end
		end
	catch
		_->ok
	end.


%%同一地图闪烁
transForSameScence( FromPID, PlayerID, CanDecItemInBagResult, #pk_U2GS_TransForSameScence{posX=DstPosX, posY=DstPosY}=_Msg)->
	try
		Player = etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerID),
		case Player of
			{}->throw(-1);
			_->ok
		end,
		
		NotTransState = ?Actor_State_Flag_Dead bor
						?Player_State_Flag_ChangingMap bor
						?Actor_State_Flag_Disable_Move bor
						?Actor_State_Flag_Disable_Hold,%% bor
						%%?Actor_State_Flag_Fighting,
		case mapActorStateFlag:isStateFlag( PlayerID , NotTransState ) of
			true->throw(-1);
			false->ok
		end,
		case mapActorStateFlag:isStateFlag(Player#mapPlayer.id, ?Player_State_Flag_Convoy) of
			true->
				systemMessage:sendTipsMessage(PlayerID, ?TEXT_NOT_TRAN_IN_CONVOY),
				throw(-1);
			false->ok
		end,		
		
		%%DstPosX、DstPosY坐标检测，
		%%魏进龙？？？？？？
		playerMove:setPos(Player, DstPosX, DstPosY),
		
		FromPID ! { playerMapMsg_U2GS_TransForSameScence_Result, CanDecItemInBagResult, true },
		
		?DEBUG_OUT("transForSameScence PlayerID[~p] success", [PlayerID])
	catch
		_->FromPID ! { playerMapMsg_U2GS_TransForSameScence_Result, CanDecItemInBagResult, false }
	end.

%%玩家进程，处理地图进程，同一地图闪烁结果
on_playerMapMsg_U2GS_TransForSameScence_Result( CanDecItemInBagResult, SuccOrFail )->
	case CanDecItemInBagResult of
		[]->ok;
		_->
			[{Location, Cell, _}|_] = CanDecItemInBagResult,
			playerItems:setLockPlayerBagCell(Location, Cell, 0),
			case SuccOrFail of
				true->
					NewItemLock = {Location, Cell, 1},
					playerItems:decItemInBag( [NewItemLock], ?Destroy_Item_Reson_Teleporte);
				false->ok
			end
	end.

%%玩家进程，处理玩家世界地图传送请求
on_U2GS_TransByWorldMap( #pk_U2GS_TransByWorldMap{mapDataID=MapDataID, posX=_EnterMapPosX, posY=_EnterMapPosY}=_Msg )->
	try
		case get("InbattleScene") of
			true->
				?MessageTipsMe(?ForbiddenTransInBattle),
				throw(-1),
				ok;
			_->
				ok
		end,
		%% VIP玩家免费飞行 add by yueliangyou [2013-05-13]
		case vipFun:callVip(?VIP_FUN_FLY,0) of
			{ok,_}->
				%%通知地图进程
				player:sendMsgToMap({playerMsg_U2GS_TransForWroldMap, self(),player:getCurPlayerID(),[], _Msg });
			{_,_}->
				ItemDataID = 103,%%飞行符
				[CanDec|CanDecItemInBagResult] = playerItems:canDecItemInBag(?Item_Location_Bag, ItemDataID, 1, "all"),
				case CanDec of
					true->
						%%够扣物品
						[{Location, Cell, _}|_] = CanDecItemInBagResult,
						%%锁定物品格子
						playerItems:setLockPlayerBagCell(Location, Cell, 1),
				
						%%先存下来
						Save = { CanDecItemInBagResult, MapDataID },
						put( "U2GS_TransByWorldMap_Save", Save ),
						%%定时，超时解锁
						erlang:send_after( 3000, self(),{playerTimeOut_TransByWorldMap_DecItem} ),
				
						%%通知地图进程
						player:sendMsgToMap({playerMsg_U2GS_TransForWroldMap, self(),player:getCurPlayerID(), CanDecItemInBagResult, _Msg });
					false->?MessageTipsMe("没有足够的飞行符"),throw(-1)
				end
		end
	catch
		_->ok
	end.

%%玩家进程，超时处理世界地图传送，扣物品
on_playerTimeOut_TransByWorldMap_DecItem()->
	Save = get( "U2GS_TransByWorldMap_Save" ),
	case Save of
		undefined->ok;
		{}->ok;
		_->
			{ CanDecItemInBagResult, _MapDataID } = Save,
			[{Location, Cell, _}|_] = CanDecItemInBagResult,
			playerItems:setLockPlayerBagCell(Location, Cell, 0),
			put( "U2GS_TransByWorldMap_Save", {} )
	end.

%%玩家进程，当玩家进入地图后，检测是否需要删除物品
on_playerEnteredMap_TransByWorldMap_DecItem( MapDataID )->
	Save = get( "U2GS_TransByWorldMap_Save" ),
	case Save of
		undefined->ok;
		{}->ok;
		_->
			{ CanDecItemInBagResult, MapDataID_Save } = Save,
			case MapDataID_Save =:= MapDataID of
				true->
					[{Location, Cell, _}|_] = CanDecItemInBagResult,
					playerItems:setLockPlayerBagCell(Location, Cell, 0),
					
					NewItemLock = {Location, Cell, 1},
					playerItems:decItemInBag( [NewItemLock], ?Destroy_Item_Reson_Teleporte),
					
					%% 写使用物品LOG 		 				
					ParamLog = #fly_param{nullparam = "NULL"},		
					PlayerBase = player:getCurPlayerRecord(),			
					logdbProcess:write_log_player_event(?EVENT_PLAYER_FLY,ParamLog,PlayerBase),

					put( "U2GS_TransByWorldMap_Save", {} );
			

				false->ok
			end
	end.

%%地图进程，处理玩家传送请求，世界地图传送
transPlayerByWorldMap( PlayerID, #pk_U2GS_TransByWorldMap{mapDataID=MapDataID, posX=EnterMapPosX, posY=EnterMapPosY}=_Msg )->
	try
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->throw(-1);
			_->ok
		end,
		
		NotTransState = ?Actor_State_Flag_Dead bor
						?Player_State_Flag_ChangingMap,
		case mapActorStateFlag:isStateFlag( PlayerID , NotTransState ) of
			true->throw(-1);
			false->ok
		end,
		case mapActorStateFlag:isStateFlag(Player#mapPlayer.id, ?Player_State_Flag_Convoy) of
			true->
				systemMessage:sendTipsMessage(PlayerID, ?TEXT_NOT_TRAN_IN_CONVOY),
				throw(-1);
			false->ok
		end,
		
		case map:getMapDataID() =:= MapDataID of
			true->throw(-1);%%相同地图ID不需要走这里切换
			false->ok
		end,
		
		MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), MapDataID ),
		case MapCfg of
			{}->throw(-1);
			_->
				%%传送点目的地一定是世界地图，张龙说，2013.1.17
				case MapCfg#mapCfg.type =:= ?Map_Type_Normal_World of
					true->ok;
					false->throw(-1)
				end
		end,
		
		%%设定玩家准备切换地图
		setPlayerReadyToChangeMap( Player ),

		%%想地图管理进程请求
		Param = { EnterMapPosX, EnterMapPosY },
		CallBack = #call_back{module=?MODULE, call_func=transPlayerByTransport_CallBack },
		TargetMapInfo = {0, MapDataID, CallBack, false, Param},
		mapManagerPID ! { getReadyToEnterMap, self(), 0, [Player], TargetMapInfo },
		
		?DEBUG_OUT( "player[~p] trans to map[~p ~p] request", [PlayerID, self(), TargetMapInfo] ),
		
		true
	catch
		_->false
	end.

%%执行传送
doTransMap( TargetMapPID, Player, TargetPosX, TargetPosY )->
	try
		PlayerID = Player#mapPlayer.id,
		
		Q = ets:fun2ms( fun(#playerSkill{id=SkillKey, playerId=DBPlayerID, skillId=_,coolDownTime=_}=Record) when DBPlayerID=:= PlayerID ->SkillKey end ),
		PlayerSkillKeyList = ets:select(map:getPlayerSkillTable(), Q),
		MyFunc = fun( Record )->
						 etsBaseFunc:readRecord( map:getPlayerSkillTable(), Record )
				 end,
		PlayerSkillList = lists:map( MyFunc, PlayerSkillKeyList),
		
		playerSkill:unDoAllPassiveSkill(Player),
		BuffData = etsBaseFunc:readRecord(map:getObjectBuffTable(), PlayerID),

		PlayerProperty = { Player#mapPlayer.base_quip_ProFix, Player#mapPlayer.base_quip_ProPer },
		
		TransPlayer = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case TransPlayer of
			{}->throw(-1);
			_->ok
		end,
		TransPlayer2 = setelement( #mapPlayer.pos, TransPlayer, #posInfo{x=TargetPosX, y=TargetPosY} ),
		
		Msg = { playerEnterMap, TransPlayer2, PlayerSkillList, BuffData, PlayerProperty, Player#mapPlayer.weapon, Player#mapPlayer.coat },
		
		map:despellObject( PlayerID, 0 ),
		
		TargetMapPID ! Msg,
		
		?DEBUG_OUT( "player[~p] doTransMap map[~p] complete", [PlayerID, TargetMapPID] ),
		
		ok
	catch
		_->ok
	end.

%%更新玩家玩家的地图CD次数，已经进入的次数（次数可正可负）
updatePlayerMapCD( Player, MapDataID, UpdateCount )->
	try
		MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), MapDataID ),
		case MapCfg of
			{}->throw(-1);
			_->ok
		end,
		
		case MapCfg#mapCfg.resetTime > 0 of
			true->ok;
			false->throw(-1)
		end,

		TodayBegin = common:getTodayBeginSeconds(),
		CfgMapCDTime = TodayBegin + MapCfg#mapCfg.resetTime,
		Now = common:getNowSeconds(),
		%% 检查是否已经过了今天的reset time
		case Now >= CfgMapCDTime of
			true ->NextResetMapCDTime = CfgMapCDTime + 24*60*60;
			false ->NextResetMapCDTime = CfgMapCDTime
		end,
				
		case MapCfg#mapCfg.playerActiveEnter_Times >0 of
			false->		%%没有活跃次数限制
				Sys_active_count = 0;
			_->
				Sys_active_count = MapCfg#mapCfg.playerActiveEnter_Times-UpdateCount
		end,
			
		%case Find_playerMapCDInfo of
		case lists:keyfind(MapDataID, #playerMapCDInfo.map_data_id, Player#mapPlayer.mapCDInfoList) of
			false->%%新的
				Find_playerMapCDInfo = {},
				New_playerMapCDInfo = #playerMapCDInfo{map_data_id=MapDataID, cur_count=UpdateCount, cd_time=NextResetMapCDTime,
																		sys_active_count=Sys_active_count, player_active_count=0};
			Find_playerMapCDInfo->%%已经存在的，要检测是否已经过期
				case Now >= Find_playerMapCDInfo#playerMapCDInfo.cd_time of
					true->%%已经过期，直接赋予新值
						New_playerMapCDInfo = #playerMapCDInfo{map_data_id=MapDataID, cur_count=UpdateCount, cd_time=NextResetMapCDTime,
															   %%系统活跃次数需要重置，自身活跃次数不需要重置
															   sys_active_count=Sys_active_count, 
															   player_active_count=Find_playerMapCDInfo#playerMapCDInfo.player_active_count};
					false->%%在CD范围内，要检测上限值
						NewCount = Find_playerMapCDInfo#playerMapCDInfo.cur_count + UpdateCount,
						case NewCount > MapCfg#mapCfg.playerEnter_Times of
							true->%%超上限了，返回失败
								throw(-1);
							false->ok
						end,
								
						case Find_playerMapCDInfo#playerMapCDInfo.sys_active_count > 0 of
							true->
								NewSysActiveCount = Find_playerMapCDInfo#playerMapCDInfo.sys_active_count-UpdateCount,
								NewPlayerActiveCount = Find_playerMapCDInfo#playerMapCDInfo.player_active_count;
							false->
								NewSysActiveCount = -1,
								
								case Find_playerMapCDInfo#playerMapCDInfo.player_active_count > 0 of
									true->
										NewPlayerActiveCount = Find_playerMapCDInfo#playerMapCDInfo.player_active_count-UpdateCount;
									false->
										NewPlayerActiveCount = -1
								end
						end,
								
						New_playerMapCDInfo = #playerMapCDInfo{map_data_id=MapDataID, cur_count=NewCount, cd_time=Find_playerMapCDInfo#playerMapCDInfo.cd_time,
															   sys_active_count=NewSysActiveCount, player_active_count=NewPlayerActiveCount
															   }
				end
		end,
		
		case New_playerMapCDInfo#playerMapCDInfo.cur_count < 0 of
			true->New_playerMapCDInfo2 = setelement( #playerMapCDInfo.cur_count, New_playerMapCDInfo, 0 );	
			false->New_playerMapCDInfo2 = New_playerMapCDInfo
		end,
	
		case Player#mapPlayer.mapCDInfoList of
			[]->New_mapCDInfoList = [New_playerMapCDInfo2];
			_->
				case Find_playerMapCDInfo of
					{}->
						New_mapCDInfoList = Player#mapPlayer.mapCDInfoList ++ [New_playerMapCDInfo2],
						ok;
					_->
						MyFunc2 = fun( Record )->
										  case Record#playerMapCDInfo.map_data_id =:= MapDataID of
											  true->New_playerMapCDInfo2;
											  false->Record
										  end
								  end,
						New_mapCDInfoList = lists:map( MyFunc2, Player#mapPlayer.mapCDInfoList )
				end
		end,
		
		etsBaseFunc:changeFiled( map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.mapCDInfoList, New_mapCDInfoList ),

		true
	catch
		_->false
	end.

%%返回玩家副本CD数据
getMapCDData( Player, MapDataID )->
	case lists:keyfind(MapDataID, #playerMapCDInfo.map_data_id, Player#mapPlayer.mapCDInfoList) of
		false->{};
		CDInfo->CDInfo
	end.

%%返回玩家的副本活跃数据 返回{ SysActiveCount, PlayerActiveCount }
getMapActiveData( Player, MapDataID )->
	try
		MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), MapDataID ),
		case MapCfg of
			{}->throw( {0,0} );
			_->ok
		end,
		
		case MapCfg#mapCfg.resetTime > 0 of
			true->ok;
			false->throw( {0,0} )
		end,
		
		CDInfo = lists:keyfind(MapDataID, #playerMapCDInfo.map_data_id, Player#mapPlayer.mapCDInfoList),
		case CDInfo of
			false->
				throw( { MapCfg#mapCfg.playerActiveEnter_Times,  0 } );		%%没有活跃数据，返回系统数据
			_->ok
		end,
		
		case CDInfo#playerMapCDInfo.player_active_count < 0 of
			true->PlayerActiveCount = 0;
			_->PlayerActiveCount = CDInfo#playerMapCDInfo.player_active_count
		end,
		
		case CDInfo#playerMapCDInfo.sys_active_count < 0 of
			true->SysActiveCount = 0;
			_->SysActiveCount = CDInfo#playerMapCDInfo.sys_active_count
		end,
		
		Now = common:getNowSeconds(),
		case Now >= CDInfo#playerMapCDInfo.cd_time of
			true->	%%已经过期
				throw( { MapCfg#mapCfg.playerActiveEnter_Times, PlayerActiveCount} );
			_->throw( { SysActiveCount, PlayerActiveCount } )
		end
	
	catch
		Return->Return
end.

%%返回玩家已经进入副本次数和能否再进，返回值{ 已经进入副本次数, 能否再进(true、false) }
getMapCDCount( Player, MapDataID )->
	try
		MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), MapDataID ),
		case MapCfg of
			{}->throw({-1,false});
			_->ok
		end,
		
		case MapCfg#mapCfg.resetTime > 0 of
			true->ok;
			false->throw({0,true})
		end,

%% 		put( "getMapCDCount_find", {} ),
%% 		MyFunc = fun( Record )->
%% 						 case Record#playerMapCDInfo.map_data_id =:= MapDataID of
%% 							 true->put( "getMapCDCount_find", Record );
%% 							 false->ok
%% 						 end
%% 				 end,
%% 		lists:foreach( MyFunc, Player#mapPlayer.mapCDInfoList ),
%% 		
%% 		Find_playerMapCDInfo = get( "getMapCDCount_find" ),
%% 		case Find_playerMapCDInfo of
%% 			{}->throw({0,true});
%% 			_->ok
%% 		end,
		
		case lists:keyfind(MapDataID, #playerMapCDInfo.map_data_id, Player#mapPlayer.mapCDInfoList) of
			false->
				Find_playerMapCDInfo={},
				throw({0,true});
			Find_playerMapCDInfo->ok
		end,
		
		Now = common:getNowSeconds(),
		case Now >= Find_playerMapCDInfo#playerMapCDInfo.cd_time of
			true->%%已经过期
				{0,true};
			false->
				case Find_playerMapCDInfo#playerMapCDInfo.cur_count >= MapCfg#mapCfg.playerEnter_Times of
					true->%%超上限了
						{ Find_playerMapCDInfo#playerMapCDInfo.cur_count, false };
					false->
						{ Find_playerMapCDInfo#playerMapCDInfo.cur_count, true }
				end
		end
	catch
		Return->Return
	end.

%%U2GS_EnterCopyMapRequest
on_U2GS_EnterCopyMapRequest( PlayerID, #pk_U2GS_EnterCopyMapRequest{ npcActorID= _NpcActorID, enterMapID=EnterMapID } = _Msg )->
	try
		{ CanEnter, Npc } = npc:canEnterCopyMapIDListAroundPlayer( PlayerID, EnterMapID, ?EnterMap_CheckDist_SQ ),
		case CanEnter of
			true->
				on_playerMsg_EnterCopyMapRequest( PlayerID, EnterMapID, Npc#mapNpc.x, Npc#mapNpc.y, true );
			false->ok
		end,
		
%% 		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
%% 		on_playerMsg_EnterCopyMapRequest( PlayerID, EnterMapID, Player#mapPlayer.pos#posInfo.x, Player#mapPlayer.pos#posInfo.y ),

		ok
	catch
		{ return, Fail_Code_Return }->
			ToUser = #pk_GS2U_EnterMapResult{ result=Fail_Code_Return },
			player:sendToPlayer(PlayerID, ToUser )
	end.

%%处理玩家进入战场请求
on_playerMsg_EnterBattleCopyRequest( PlayerID, MapDataID, PosX,PosY,NotCreate,OwerPlayerID  )->
	try
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->throw( { return, ?EnterMap_Fail_Invalid_Call } );
			_->ok
		end,
		
		%%设定玩家准备切换地图
		setPlayerReadyToChangeMap( Player ),

		%%想地图管理进程请求
		Param = { false, PosX,PosY },
		CallBack = #call_back{module=?MODULE, call_func=on_playerMsg_EnterBattleCopyRequest_CallBack },
		TargetMapInfo = {0, MapDataID, CallBack, NotCreate, Param},
		mapManagerPID ! { getReadyToEnterMap, self(), OwerPlayerID, [Player], TargetMapInfo },
		
		true
	catch
		{ return, Fail_Code_Return }->
			ToUser = #pk_GS2U_EnterMapResult{ result=Fail_Code_Return },
			player:sendToPlayer(PlayerID, ToUser ),
			false
	end.

%%玩家进入副本请求结果检查
on_playerMsg_EnterBattleCopyRequest_CallBack( TargetMapPID, _OwnerID, EnterPlayerList, TargetMapInfo, Result )->
	try
		{_MapID, MapDataID, _ReadyResult_CallBack, _NotCreate, Param} = TargetMapInfo,
		{ IsCreateNewCopyMap, CheckEnterPosX, CheckEnterPosY } = Param,
		
		MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), MapDataID ),
		
		case size(Result) of
			2->{ CanEnter, Fail_Code } = Result;
			3->{ CanEnter, Fail_Code, _FailPlayerID } = Result;
			_->CanEnter=0, Fail_Code = 0, throw(-1)
		end,

		case CanEnter of
			true->%%可以进入
				MyFunc = fun( Player )->
								 PlayerFind = etsBaseFunc:readRecord( map:getMapPlayerTable(), Player#mapPlayer.id ),
								 case PlayerFind of
									 {}->ok;
									 _->
										 CheckMapCD=false,%%战场，不用检测cd
										 CanEnter2 = checkPlayerCanEnterBattleCopyMap( PlayerFind, 
																								 MapDataID),
										 case CanEnter2 of
											 true->
												 	doTransMap( TargetMapPID, PlayerFind, CheckEnterPosX, CheckEnterPosY );
											 false->%%失败，要通知玩家？
												 ok
										 end
								 end
						 end,
				lists:foreach( MyFunc, EnterPlayerList );
			false->%%失败，要通知玩家？
				MyFunc = fun( Player )->
							ToUser = #pk_GS2U_EnterMapResult{ result=Fail_Code },
							player:sendToPlayer(Player#mapPlayer.id, ToUser )
						 end,
				lists:foreach( MyFunc, EnterPlayerList )
		end,
		
		ok
	catch
		_->ok
	end.

checkPlayerCanEnterBattleCopyMap( Player, _MapDataID )->
	try
		PlayerID = Player#mapPlayer.id,
		
		%%其他状态
		NoState = ?Actor_State_Flag_Dead bor 
				  ?Actor_State_Flag_Disable_Move bor
				  ?Actor_State_Flag_Disable_Hold bor
				  ?Player_State_Flag_ChangingMap,
		case mapActorStateFlag:isStateFlag( PlayerID, NoState ) of
			true->throw( {return, ?EnterMap_Fail_Invalid_Call} );
			false->ok
		end,
		case mapActorStateFlag:isStateFlag( PlayerID, ?Player_State_Flag_Convoy ) of
			true->throw( {return, ?EnterMap_Fail_In_Convoy} );
			false->ok
		end,
		true
	catch
		{ return, _Fail_Code_Return }->
			false
	end.


%%处理玩家进入副本请求
on_playerMsg_EnterCopyMapRequest( PlayerID, MapDataID, CheckEnterPosX, CheckEnterPosY, CheckMapCD )->
	try
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->throw( { return, ?EnterMap_Fail_Invalid_Call } );
			_->ok
		end,
		
		%%检测某玩家能否进入副本
		{ CanEnter, Fail_Code } = checkPlayerCanEnterCopyMap( Player, MapDataID, CheckEnterPosX, CheckEnterPosY, CheckMapCD ),
		case CanEnter of
			true->ok;
			false->throw( { return, Fail_Code } )
		end,
		
		%%如果是由队伍的，副本拥有者是队伍ID
		TeamID = playerMap:getPlayerTeamID(Player),
		case playerMap:hasPlayerTeam(Player) of
			true->OwnerID = TeamID;
			false->OwnerID = PlayerID
		end,
		%%如果是队长或单人，则要求没有副本的话，要创建，否则不要求创建
		case playerMap:isPlayerTeamLeader(Player) of
			true->%%是队长，求没有副本的话，要创建
				NotCreate = false;
			false->%%不是队长，要看是否单人
				case playerMap:hasPlayerTeam(Player) of
					true->NotCreate = true;
					false->NotCreate = false
				end
		end,
		
		%%设定玩家准备切换地图
		setPlayerReadyToChangeMap( Player ),

		%%想地图管理进程请求
		Param = { false, CheckEnterPosX, CheckEnterPosY },
		CallBack = #call_back{module=?MODULE, call_func=playerMsg_EnterCopyMapRequest_CallBack },
		TargetMapInfo = {0, MapDataID, CallBack, NotCreate, Param},
		mapManagerPID ! { getReadyToEnterMap, self(), OwnerID, [Player], TargetMapInfo },
		
		ok
	catch
		{ return, Fail_Code_Return }->
			ToUser = #pk_GS2U_EnterMapResult{ result=Fail_Code_Return },
			player:sendToPlayer(PlayerID, ToUser )
	end.

%%玩家进入副本请求结果检查
playerMsg_EnterCopyMapRequest_CallBack( TargetMapPID, _OwnerID, EnterPlayerList, TargetMapInfo, Result )->
	try
		{_MapID, MapDataID, _ReadyResult_CallBack, _NotCreate, Param} = TargetMapInfo,
		{ IsCreateNewCopyMap, CheckEnterPosX, CheckEnterPosY } = Param,
		
		MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), MapDataID ),
		
		case size(Result) of
			2->{ CanEnter, Fail_Code } = Result;
			3->{ CanEnter, Fail_Code, _FailPlayerID } = Result;
			_->CanEnter=0, Fail_Code = 0, throw(-1)
		end,

		case CanEnter of
			true->%%可以进入
				%%如果是队长初次创建副本，全队广播确认进副本
				case ( length( EnterPlayerList ) =:= 1 ) of
					true->
						[TeamLeader|_] = EnterPlayerList,
						case ( playerMap:isPlayerTeamLeader(TeamLeader) ) andalso
							 ( IsCreateNewCopyMap =:= true ) of
							true->
								ToUser = #pk_GS2U_TeamCopyMapQuery{nReadyEnterMapDataID=MapDataID,
																   nCurMapID=map:getMapDataID(),
																   nPosX=CheckEnterPosX,
																   nPosY=CheckEnterPosY,
																   nDistanceSQ=?EnterMap_CheckDist_SQ
																   },
								MyFunc2 = fun( Record )->
												 player:sendToPlayer(Record, ToUser)
										 end,
								lists:foreach( MyFunc2, TeamLeader#mapPlayer.teamDataInfo#teamData.membersID ),
								throw(-1);
							false->ok
						end;
					false->ok
				end,
				MyFunc = fun( Player )->
								 PlayerFind = etsBaseFunc:readRecord( map:getMapPlayerTable(), Player#mapPlayer.id ),
								 case PlayerFind of
									 {}->ok;
									 _->
										 %%是否检测地图CD，由isEnteredChangeTargetMap决定，已经进入过副本的，不用检查CD
										 case Player#mapPlayer.isEnteredChangeTargetMap of
											 true->CheckMapCD = false;
											 false->CheckMapCD = true
										 end,
										 { CanEnter2, _Fail_Code2 } = checkPlayerCanEnterCopyMap( PlayerFind, 
																								 MapDataID, 
																								 CheckEnterPosX, 
																								 CheckEnterPosY, 
																								 CheckMapCD ),
										 case CanEnter2 of
											 true->
												 	%%成功，传送玩家进入副本
													%%PlayerBase = player:getCurPlayerRecord(),
													%%ParamTuple = #copy_param{	action = 1},
													%%logdbProcess:write_log_player_event(?EVENT_PALYER_COPY, ParamTuple, PlayerBase),

												 	doTransMap( TargetMapPID, PlayerFind, MapCfg#mapCfg.initPosX, MapCfg#mapCfg.initPosY );
											 false->%%失败，要通知玩家？
												 ok
										 end
								 end
						 end,
				lists:foreach( MyFunc, EnterPlayerList );
			false->%%失败，要通知玩家？
				MyFunc = fun( Player )->
							ToUser = #pk_GS2U_EnterMapResult{ result=Fail_Code },
							player:sendToPlayer(Player#mapPlayer.id, ToUser )
						 end,
				lists:foreach( MyFunc, EnterPlayerList )
		end,
		
		ok
	catch
		_->ok
	end.


%%检测某玩家能否进入副本，返回：{ 能否进入副本(true、false), 失败原因码  }
checkPlayerCanEnterCopyMap( Player, MapDataID, CheckEnterPosX, CheckEnterPosY, CheckMapCD )->
	try
		PlayerID = Player#mapPlayer.id,
		
		DistSQ = monster:getDistSQFromTo( playerMap:getPlayerPosX(Player), 
									  		playerMap:getPlayerPosY(Player),
										  CheckEnterPosX, CheckEnterPosY ),
		%%距离副本入口太远
		case DistSQ < ?EnterMap_CheckDist_SQ of
			true->ok;
			false->throw( {return, ?EnterMap_Fail_Distance} )
		end,

		Mapcfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), MapDataID ),
		%%等级检测
		case ( Mapcfg#mapCfg.playerEnter_MinLevel > 0 ) andalso  ( Mapcfg#mapCfg.playerEnter_MaxLevel > 0 ) of
			true->
				case ( Player#mapPlayer.level >= Mapcfg#mapCfg.playerEnter_MinLevel ) andalso 
					 ( Player#mapPlayer.level =< Mapcfg#mapCfg.playerEnter_MaxLevel ) of
					true->ok;
					false->throw( {return, ?EnterMap_Fail_PlayerLevel} )
				end,
				ok;
			false->ok
		end,

		
		%%战斗状态不能进入副本
%% 		case mapActorStateFlag:isStateFlag( PlayerID, ?Actor_State_Flag_Fighting ) of
%% 			true->throw( {return, ?EnterMap_Fail_FightState} );
%% 			false->ok
%% 		end,
		
		%%其他状态
		NoState = ?Actor_State_Flag_Dead bor 
				  ?Actor_State_Flag_Disable_Move bor
				  ?Actor_State_Flag_Disable_Hold bor
				  ?Player_State_Flag_ChangingMap,
		case mapActorStateFlag:isStateFlag( PlayerID, NoState ) of
			true->throw( {return, ?EnterMap_Fail_Invalid_Call} );
			false->ok
		end,
		case mapActorStateFlag:isStateFlag( PlayerID, ?Player_State_Flag_Convoy ) of
			true->throw( {return, ?EnterMap_Fail_In_Convoy} );
			false->ok
		end,
		
		%%副本CD
		case CheckMapCD of
			true->
				{ _Count, CanEnter } = getMapCDCount( Player, MapDataID ),
				case CanEnter of
					true->ok;
					false->throw( {return, ?EnterMap_Fail_CD} )
				end;
			false->ok
		end,

		{ true, 0 }
	catch
		{ return, Fail_Code }->
			{ false, Fail_Code }
	end.

%%U2GS_QueryMyCopyMapCD
on_U2GS_QueryMyCopyMapCD( PlayerID, _Msg )->
	try
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->throw(-1);
			_->ok
		end,
		
		put( "on_U2GS_QueryMyCopyMapCD", [] ),
		
		MyFunc = fun( Record )->
						 case Record#mapCfg.type of
							 ?Map_Type_Normal_Copy->
								 case Record#mapCfg.playerEnter_Times > 0 of
									 true->
										 { EnteredCount, CanEnter } = getMapCDCount( Player, Record#mapCfg.mapID ),
										 case CanEnter of
											 true->
												 RemainCount = Record#mapCfg.playerEnter_Times - EnteredCount;
											 false->
												 RemainCount = 0
										 end,
										 
										 {SysActiveCount, PlayerActiveCount } = getMapActiveData(Player, Record#mapCfg.mapID),
										 ActiveCount = SysActiveCount+PlayerActiveCount,
										 
										 MyCopyMapCDInfo = #pk_MyCopyMapCDInfo{
																			   mapDataID=Record#mapCfg.mapID, 
																			   mapEnteredCount=RemainCount,
																			   mapActiveCount=ActiveCount},
										 put( "on_U2GS_QueryMyCopyMapCD", get("on_U2GS_QueryMyCopyMapCD") ++ [MyCopyMapCDInfo] );
									 false->ok
								 end;
							 _->ok
						 end
				 end,
		etsBaseFunc:etsFor( main:getGlobalMapCfgTable(), MyFunc ),

		player:sendToPlayer(PlayerID, #pk_GS2U_MyCopyMapCDInfo{info_list=get("on_U2GS_QueryMyCopyMapCD")} ),
		ok
	catch
		_->ok
	end.

on_U2GS_FastTeamCopyMapRequest( PlayerID, Msg )->
	case Msg#pk_U2GS_FastTeamCopyMapRequest.enterOrQuit of
		0->%%enterOrQuit=0表示进入
			on_U2GS_FastTeamCopyMapRequest_Join( PlayerID, Msg#pk_U2GS_FastTeamCopyMapRequest.npcActorID, Msg#pk_U2GS_FastTeamCopyMapRequest.mapDataID );
		_->%%退出
			quitFastTeamCopyMap( PlayerID, true )
	end.

%%处理玩家快速组队进入副本请求
on_U2GS_FastTeamCopyMapRequest_Join( PlayerID, NpcID, MapDataID )->
	try
		{ CanFastTeamCopyMap, FailCode } = canFastTeamCopyMap( PlayerID, NpcID, MapDataID, true, true ),
		case CanFastTeamCopyMap of
			true->ok;
			_->throw({return, FailCode})
		end,
		
		{ InsertOK, FailCode2 } = insertIntoFastTeamCopyMap( PlayerID, NpcID, MapDataID ),
		case InsertOK of
			true->ok;
			_->throw({return, FailCode2})
		end,
	
		etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.readyFastTeamCopyMap, MapDataID ),
		
		checkFastTeamCopyMap( PlayerID, NpcID, MapDataID ),
		
		ToUser = #pk_GS2U_FastTeamCopyMapResult{ mapDataID=MapDataID, result=0, enterOrQuit=1 },
		player:sendToPlayer(PlayerID, ToUser ),
		
		ok
	catch
		{ return, Fail_Code }->
			ToUser2 = #pk_GS2U_FastTeamCopyMapResult{ mapDataID=MapDataID, result=Fail_Code, enterOrQuit=0 },
			player:sendToPlayer(PlayerID, ToUser2 );
		_->ok
	end.

insertIntoFastTeamCopyMap( PlayerID, NpcID, MapDataID )->
	try
		FastTeamCopyMap = etsBaseFunc:readRecord( map:getFastTeamCopyMap(), MapDataID ),
		case FastTeamCopyMap of
			{}->
				MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), MapDataID ),
				New_FastTeamCopyMap = #fastTeamCopyMap{mapDataID=MapDataID, 
													   readyPlayerList=[PlayerID],
													   teamPlayerCount=MapCfg#mapCfg.maxPlayerCount,
													   checkNpcID = NpcID },
				etsBaseFunc:insertRecord(map:getFastTeamCopyMap(), New_FastTeamCopyMap);
			_->
				MyFunc = fun( Value, Find )->
								 Value =:= Find
						 end,
				{ Find, _ } = common:findInList(FastTeamCopyMap#fastTeamCopyMap.readyPlayerList, PlayerID, MyFunc ),
				case Find of
					true->throw( {return, ?EnterMap_Fail_Exist_Ready_Player} );
					false->
						New_List = FastTeamCopyMap#fastTeamCopyMap.readyPlayerList ++ [PlayerID],
						
						etsBaseFunc:changeFiled(map:getFastTeamCopyMap(), 
												MapDataID, 
												#fastTeamCopyMap.readyPlayerList, 
												New_List)
				end
		end,
		{ true, 0 }
	catch
		{ return, Fail_Code }->{false, Fail_Code}
	end.

%%玩家退出副本快速组队
quitFastTeamCopyMap( PlayerID, Quit )->
	Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
	case Player of
		{}->ok;
		_->
			case Player#mapPlayer.readyFastTeamCopyMap =:= 0 of
				true->ok;
				false->
					case ( Player#mapPlayer.teamDataInfo#teamData.teamID =/= 0 ) or
						 ( Quit =:= true )of
						false->ok;
						true->
							FastTeamCopyMap = etsBaseFunc:readRecord( map:getFastTeamCopyMap(), Player#mapPlayer.readyFastTeamCopyMap ),
							case FastTeamCopyMap of
								{}->ok;
								_->
									New = FastTeamCopyMap#fastTeamCopyMap.readyPlayerList -- [Player#mapPlayer.id],
									etsBaseFunc:changeFiled(map:getFastTeamCopyMap(), 
															Player#mapPlayer.readyFastTeamCopyMap, 
															#fastTeamCopyMap.readyPlayerList, New ),
									etsBaseFunc:changeFiled(map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.readyFastTeamCopyMap, 0)
							end,
							ToUser = #pk_GS2U_FastTeamCopyMapResult{ mapDataID=Player#mapPlayer.readyFastTeamCopyMap, result=0, enterOrQuit=0 },
							player:sendToPlayer(Player#mapPlayer.id, ToUser )
					end
			end
	end.

%%检查快速组队进副本的列表，并删除无效的玩家，并
checkFastTeamCopyMap( PlayerID, NpcID, MapDataID )->
	try
		put( "checkFastTeamCopyMap_canEnterPlayers", [] ),
		put( "checkFastTeamCopyMap_delEnterPlayers", [] ),
		
		FastTeamCopyMap = etsBaseFunc:readRecord( map:getFastTeamCopyMap(), MapDataID ),
		%%
		MyFunc = fun( Record )->
						 Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), Record ),
						 case Player of
							 {}->
								 put( "checkFastTeamCopyMap_delEnterPlayers", get("checkFastTeamCopyMap_delEnterPlayers") ++ [Record] );
							 _->
								{ CanFastTeamCopyMap, FailCode } = canFastTeamCopyMap( PlayerID, NpcID, MapDataID, false, true ),
								case CanFastTeamCopyMap of
									true->
										CanEnterPlayerCount = length( get("checkFastTeamCopyMap_canEnterPlayers") ),
										case CanEnterPlayerCount >= FastTeamCopyMap#fastTeamCopyMap.teamPlayerCount of
											true->ok;
											_->put( "checkFastTeamCopyMap_canEnterPlayers", get("checkFastTeamCopyMap_canEnterPlayers") ++ [Record] )
										end;
									_->
										case FailCode of
											?EnterMap_Fail_Distance->ok;
											_->
												put( "checkFastTeamCopyMap_delEnterPlayers", get("checkFastTeamCopyMap_delEnterPlayers") ++ [Record] )
										end
								end
						 end
				 end,
		lists:foreach( MyFunc, FastTeamCopyMap#fastTeamCopyMap.readyPlayerList ),
		
		CanEnterPlayers = get( "checkFastTeamCopyMap_canEnterPlayers" ),
		DelEnterPlayers = get( "checkFastTeamCopyMap_delEnterPlayers" ),
		%%删除无效的玩家
		MyFunc2 = fun( Record )->
						  Read_FastTeamCopyMap = etsBaseFunc:readRecord( map:getFastTeamCopyMap(), MapDataID ),
						  case Read_FastTeamCopyMap of
							  {}->ok;
							  _->
								  New_List = Read_FastTeamCopyMap#fastTeamCopyMap.readyPlayerList--[Record],
								  etsBaseFunc:changeFiled( map:getFastTeamCopyMap(), MapDataID, #fastTeamCopyMap.readyPlayerList, New_List ),
								  
								  Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), Record ),
								  case Player of
										{}->ok;
										_->
											case Player#mapPlayer.readyFastTeamCopyMap =:= MapDataID of
												 true->%%重置mapPlaeyr上的readyFastTeamCopyMap，还要通知客户端吧？
													ToUser = #pk_GS2U_FastTeamCopyMapResult{ mapDataID=MapDataID, result=0, enterOrQuit=0 },
													player:sendToPlayer(Player#mapPlayer.id, ToUser ),

													etsBaseFunc:changeFiled( map:getMapPlayerTable(), Record, #mapPlayer.readyFastTeamCopyMap, 0 );
												 false->ok
											 end
								  end
						  end
				  end,
		lists:foreach( MyFunc2, DelEnterPlayers ),
		
		CanEnterPlayerCount = length( CanEnterPlayers ),
		case CanEnterPlayerCount >= FastTeamCopyMap#fastTeamCopyMap.teamPlayerCount of
			true->ok;
			_->throw(-1)
		end,
		%%能组队的玩家要从原排队列表中删除
		MyFunc3 = fun( Record )->
						  Read_FastTeamCopyMap = etsBaseFunc:readRecord( map:getFastTeamCopyMap(), MapDataID ),
						  case Read_FastTeamCopyMap of
							  {}->ok;
							  _->
								  New_List = Read_FastTeamCopyMap#fastTeamCopyMap.readyPlayerList--[Record],
								  etsBaseFunc:changeFiled( map:getFastTeamCopyMap(), 
														   MapDataID,
														   #fastTeamCopyMap.readyPlayerList, 
														   New_List ),
								  
								  etsBaseFunc:changeFiled( map:getMapPlayerTable(), 
														   Record, 
														   #mapPlayer.readyFastTeamCopyMap, 
														   0)
						  end
				  end,
		lists:foreach( MyFunc3, CanEnterPlayers ),
		%%请求队伍进程，将这些玩家组队
		Param = { NpcID, MapDataID },
		teamThread ! { fastTeamCopyMap, self(), CanEnterPlayers, Param }
	catch
		_->ok
	end.

%%组队进程返回快速组队结果
on_fastTeamCopyMap_Result( CanEnterPlayers, Param, TeamLeader )->
	try
		{ NpcID, MapDataID } = Param,
		
		case TeamLeader =:= 0 of
			true->%%组队失败，将这些玩家重新进排队
				MyFunc = fun( Record )->
								 Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), Record ),
								 case Player of
									 {}->ok;
									 _->
										 { CanFastTeamCopyMap, _FailCode } = canFastTeamCopyMap( Record, NpcID, MapDataID, false, true ),
										 case CanFastTeamCopyMap of
											 true->%%能进，插入队列，因为先前从队列里删除了的
													insertIntoFastTeamCopyMap( Record, NpcID, MapDataID );
											 false->%%不能进了
												 case Player#mapPlayer.readyFastTeamCopyMap =:= MapDataID of
													 true->%%重置mapPlaeyr上的readyFastTeamCopyMap，还要通知客户端吧？
														ToUser = #pk_GS2U_FastTeamCopyMapResult{ mapDataID=MapDataID, result=0, enterOrQuit=0 },
														player:sendToPlayer(Player#mapPlayer.id, ToUser ),

														 etsBaseFunc:changeFiled( map:getMapPlayerTable(), Record, #mapPlayer.readyFastTeamCopyMap, 0 );
													 false->ok
												 end
										 end
								 end
						 end,
				lists:foreach( MyFunc, CanEnterPlayers );
			 false->%%组队成功，检测一下是否所有人都能进，能进则由队长进
				put( "on_fastTeamCopyMap_Result_all_ok", true ),
				MyFunc = fun( Record )->
								 Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), Record ),
								 case Player of
									 {}->put( "on_fastTeamCopyMap_Result_all_ok", false );
									 _->
										 { CanFastTeamCopyMap, _FailCode } = canFastTeamCopyMap( Record, NpcID, MapDataID, false, false ),
										 case CanFastTeamCopyMap of
											 true->ok;
											 false->
												 	put( "on_fastTeamCopyMap_Result_all_ok", false ),
													etsBaseFunc:changeFiled( map:getMapPlayerTable(), Record, #mapPlayer.readyFastTeamCopyMap, 0 )
										 end
								 end
						 end,
				lists:foreach( MyFunc, CanEnterPlayers ),
				
				case get( "on_fastTeamCopyMap_Result_all_ok" ) of
					true->%%所有人都能进，队长进
						Msg = #pk_U2GS_EnterCopyMapRequest{ npcActorID= NpcID, enterMapID=MapDataID },
						on_U2GS_EnterCopyMapRequest( TeamLeader, Msg ),
						ok;
					false->ok
				end,

				ok
		end,

		ok
	catch
		_->ok
	end.

%%返回玩家能否快速组队进入副本
canFastTeamCopyMap( PlayerID, NpcID, MapDataID, CheckPlayer, CheckTeam )->
	try
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->throw( {return, ?EnterMap_Fail_Invalid_Call} );
			_->ok
		end,
		
		case CheckPlayer andalso ( Player#mapPlayer.readyFastTeamCopyMap /= 0 ) of
			true->
				FastTeamCopyMap = etsBaseFunc:readRecord( map:getFastTeamCopyMap(), Player#mapPlayer.readyFastTeamCopyMap ),
				case FastTeamCopyMap of
					{}->ok;
					_->
						{ Find, _ } = common:findInList( FastTeamCopyMap#fastTeamCopyMap.readyPlayerList, PlayerID, 0),
						case Find of
							true->ok;
							false->%%已经不在等待列表里了，要删除
								New = FastTeamCopyMap#fastTeamCopyMap.readyPlayerList -- [PlayerID],
								etsBaseFunc:changeFiled( map:getFastTeamCopyMap(), 
														 Player#mapPlayer.readyFastTeamCopyMap, 
														 #fastTeamCopyMap.readyPlayerList, 
														 New ),
								etsBaseFunc:changeFiled( map:getMapPlayerTable(), 
														 PlayerID, 
														 #mapPlayer.readyFastTeamCopyMap, 
														 0)
						end
				end,
				throw({return, ?EnterMap_Fail_Exist_Ready_Player});
			false->ok
		end,
		
		case CheckTeam andalso playerMap:hasPlayerTeam(Player) of
			true->throw({return, ?EnterMap_Fail_HasTeam});
			false->ok
		end,
		
		Npc = etsBaseFunc:readRecord( map:getMapNpcTable(), NpcID ),
		case Npc of
			{}->throw( {return, ?EnterMap_Fail_Invalid_Call} );
			_->ok
		end,
		
		MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), MapDataID ),
		case MapCfg of
			{}->throw( {return, ?EnterMap_Fail_Invalid_Call} );
			_->ok
		end,
		
		case MapCfg#mapCfg.type of
			?Map_Type_Normal_Copy->ok;
			_->throw( {return, ?EnterMap_Fail_Invalid_Call} )
		end,
		case MapCfg#mapCfg.maxPlayerCount =< 1 of
			true->throw( {return, ?EnterMap_Fail_Invalid_Call} );
			false->ok
		end,
		
		{ CanEnter, FailCode } = checkPlayerCanEnterCopyMap( Player, MapDataID, Npc#mapNpc.x, Npc#mapNpc.y, true ),
		case CanEnter of
			true->ok;
			false->throw({return, FailCode})
		end,
		{ true, 0 }
	catch
		{ return, Fail_Code }->
			{ false, Fail_Code }
	end.

%%玩家请求重置副本
on_U2GS_RestCopyMapRequest( PlayerID, #pk_U2GS_RestCopyMapRequest{nMapDataID=MapDataID, nNpcID=_NpcID}=_Msg )->
	try
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->throw( {return, ?EnterMap_Fail_Invalid_Call} );
			_->ok
		end,
		
		MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), MapDataID ),
		case MapCfg of
			{}->throw( {return, ?EnterMap_Fail_Invalid_Call} );
			_->ok
		end,
		
		case MapCfg#mapCfg.type =:= ?Map_Type_Normal_Copy of
			true->ok;
			false->throw( {return, ?EnterMap_Fail_Invalid_Call} )
		end,
		
		case playerMap:hasPlayerTeam(Player) of
			true->
				case playerMap:isPlayerTeamLeader(Player) of
					true-> OwnerID = Player#mapPlayer.teamDataInfo#teamData.teamID;
					false->OwnerID = PlayerID, throw( {return, ?EnterMap_Fail_NotTeamLeader} )
				end;
			false->OwnerID = PlayerID
		end,
		
		mapManagerPID ! { playerMapMsg_ResetCopyMap, PlayerID, OwnerID, MapDataID },
		
		ok
	catch
		{ return, Fail_Code }->
			ToUser = #pk_GS2U_EnterMapResult{ result=Fail_Code },
			player:sendToPlayer(PlayerID, ToUser )
	end.

%%地图管理进程通知重置副本
on_mapManagerMsg_ResetCopyMap( PlayerID )->
	try
		PlayerCount = ets:info( map:getMapPlayerTable(), size ),
		case PlayerCount > 0 of
			true->throw( {return, ?EnterMap_Fail_ResetFail_HasPlayer} );
			false->ok
		end,
		
		?DEBUG_OUT( "on_mapManagerMsg_ResetCopyMap PlayerID[~p] map[~p ~p]", [PlayerID, map:getMapDataID(), map:getMapID()] ),
		
		self() ! { quit },
		
		throw( {return, ?EnterMap_Fail_ResetSucc} )
	catch
		{ return, Fail_Code }->
			ToUser = #pk_GS2U_EnterMapResult{ result=Fail_Code },
			player:sendToPlayer(PlayerID, ToUser )
	end.


%%玩家进程，请求增加副本活跃次数
on_PlayerCopyAddActiveCount( MapDataID )->
	try
		MapCfg = etsBaseFunc:readRecord(main:getGlobalMapCfgTable(), MapDataID),
		case MapCfg of
			{}->throw( ?AddCopyActiveTime_NotMap );
			_->ok
		end,
		
		case  vipFun:callVip(?VIP_FUN_FUBEN,0) of
			{ ok, _ }->
				IsVIPCount=true,
				DecItemData={};
			_->
				IsVIPCount=false,
				[CanDecItem|DecItemData] = playerItems:canDecItemInBag(?Item_Location_Bag, MapCfg#mapCfg.playerActiveTime_Item, 1, "all"),
				case CanDecItem of
					false->throw( ?AddCopyActiveTime_NotItem );
					_->ok
				end,
				
				[{Location, Cell, _}] = DecItemData,
				playerItems:setLockPlayerBagCell(Location, Cell, 1)
		end,
		
		player:sendMsgToMap( {playerAddActiveCount, self(), player:getCurPlayerID(), DecItemData, MapCfg, IsVIPCount} )
	
	catch
		Value->player:send(#pk_U2GS_CopyMapAddActiveCountResult{result=Value})
end.

%%地图进程，处理玩家增加副本活跃次数的请求
on_PlayerMsgAddActiveCount( PID, PlayerID, DecItemData, MapCfg, IsVIPCount )->
	try
		Player = etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerID),
		case Player of
			{}->throw( 0 );
			_->ok
		end,
		
		case MapCfg#mapCfg.type =:= ?Map_Type_Normal_Copy of
			false->throw( ?AddCopyActiveTime_NotCopyMap );
			_->ok
		end,
		
		case MapCfg#mapCfg.playerActiveEnter_Times =:= 0 of
			true->throw(?AddCopyActiveTime_NotNeed);
			_->ok
		end,
		
		MapDataID = MapCfg#mapCfg.mapID,
		case getMapCDData(Player, MapDataID ) of
			{}->
				%%没有CD信息，创建一个
				TodayBegin = common:getTodayBeginSeconds(),
				CfgMapCDTime = TodayBegin + MapCfg#mapCfg.resetTime,
				Now = common:getNowSeconds(),
				%% 检查是否已经过了今天的reset time
				case Now >= CfgMapCDTime of
					true ->NextResetMapCDTime = CfgMapCDTime + 24*60*60;
					false ->NextResetMapCDTime = CfgMapCDTime
				end,
				MapCDInfo = #playerMapCDInfo{
													   map_data_id=MapDataID, 
													   cur_count=0, 
													   cd_time=NextResetMapCDTime,
													   sys_active_count=MapCfg#mapCfg.playerActiveEnter_Times, 
													   player_active_count=0},
				CDList = Player#mapPlayer.mapCDInfoList ++ [MapCDInfo],
				etsBaseFunc:changeFiled(map:getMapPlayerTable(), PlayerID, #mapPlayer.mapCDInfoList, CDList);
			_->ok
		end,
		
		Player2 = etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerID),
		case Player2 of
			{}->throw( 0 );
			_->ok
		end,
		
		{ SysActiveCount, PlayerActiveCount } = getMapActiveData(Player2, MapDataID),
		{ CDCount, _} = getMapCDCount(Player2, MapDataID),
		case (SysActiveCount+PlayerActiveCount) >= MapCfg#mapCfg.playerEnter_Times-CDCount of
			true->throw( ?AddCopyActiveTime_MaxCount );
			_->ok
		end,
		
		CDData = getMapCDData(Player2, MapDataID ),
		
		NewCDLIst = lists:keyreplace(MapDataID, #playerMapCDInfo.map_data_id, 
						 Player2#mapPlayer.mapCDInfoList, CDData#playerMapCDInfo{player_active_count=PlayerActiveCount+1}),
		etsBaseFunc:changeFiled(map:getMapPlayerTable(), PlayerID, #mapPlayer.mapCDInfoList, NewCDLIst),
		%%发送副本新的CD信息给玩家
		on_U2GS_QueryMyCopyMapCD(PlayerID, 0),
		throw( ?AddCopyActiveTime_Succ )

	catch
		Value->PID ! { addActiveCount_Result, Value, DecItemData, IsVIPCount }
end.

%%玩家进程，处理地图进程对副本活跃次数增加的返回
on_AddActiveCountResult( Result, DecItemData, IsVIPCount )->
	%%判断是否是消耗VIP次数
	case IsVIPCount of
		true->
			case Result of
				?AddCopyActiveTime_Succ->
					vipFun:callVip(?VIP_FUN_FUBEN,1);
				_->ok
			end;
		_->
			[{Location, Cell, _}] = DecItemData,
			playerItems:setLockPlayerBagCell(Location, Cell, 0),
			case Result of
				?AddCopyActiveTime_Succ->
					playerItems:decItemInBag(DecItemData, ?Destroy_Item_Reson_AddCopyMapActiveCount);
				_->ok
			end,
			player:send(#pk_U2GS_CopyMapAddActiveCountResult{result=Result})
	end.

%%地图进程，处理队伍进程通知踢人
on_teamMsg_KickOut( TeamID, PlayerID )->
	try
		Player = map:getPlayer( PlayerID ),
		case Player of
			{}->throw( {return} );
			_->ok
		end,
		
		MapCfg = map:getMapCfg(),
		case MapCfg#mapCfg.type of
			?Map_Type_Normal_Copy->ok;
			_->throw( {return} )
		end,
		
		erlang:send_after( 1000,self(), { teamMemberForceTransOut, PlayerID, TeamID, 10 } ),

		?DEBUG_OUT( "on_teamMsg_KickOut TeamID[~p], PlayerID[~p]", [TeamID, PlayerID] ),
		
		ok
	catch
		{ return }->ok
	end.

%%地图进程，定时处理检测玩家在副本中离开队伍被强制传送出副本
on_teamMemberForceTransOut( PlayerID, TeamID, TimeRemain )->
	try
		Player = map:getPlayer( PlayerID ),
		case Player of
			{}->throw( {return} );
			_->ok
		end,
		
		case Player#mapPlayer.teamDataInfo#teamData.teamID =:= TeamID of
			true->
				?DEBUG_OUT( "on_teamMemberForceTransOut teamID= PlayerID[~p], TeamID[~p], TimeRemain[~p]", [PlayerID, TeamID, TimeRemain] ),
				throw( {return} );
			false->ok
		end,
		
		case TimeRemain =< 0 of
			true->
				MapCfg = map:getMapCfg(),
				Ret = transPlayerByTransport( Player, 
										MapCfg#mapCfg.quitMapID, 
										MapCfg#mapCfg.quitMapPosX, 
										MapCfg#mapCfg.quitMapPosY ),
				case Ret of
					true->throw( {return} );
					false->ok
				end;
			_->ok
		end,

		erlang:send_after( 1000,self(), { teamMemberForceTransOut, PlayerID, TeamID, TimeRemain-1 } ),
		
		case TimeRemain < 0 of
			true->TimeRemain2 = 0;
			false->TimeRemain2 = TimeRemain
		end,

		MakeResult = ( TimeRemain2 bsl 16 ) bor ( ?EnterMap_Fail_ForceTransOut ),
		ToUser = #pk_GS2U_EnterMapResult{ result=MakeResult },
		player:sendToPlayer(Player#mapPlayer.id, ToUser ),

		?DEBUG_OUT( "on_teamMemberForceTransOut TeamID[~p], PlayerID[~p] TimeRemain[~p]", [TeamID, PlayerID, TimeRemain] ),
		
		ok
	catch
		{ return }->ok
	end.



