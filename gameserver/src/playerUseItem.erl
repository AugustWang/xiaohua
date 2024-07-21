%% Author: Zhangdong
%% Created: 2012-8-9
%% Description: TODO: Add description to itemDB
-module(playerUseItem).

%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% Include files
%%
-include("mysql.hrl").
-include("db.hrl").
-include("taskDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("itemDefine.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("logdb.hrl").
-include("variant.hrl").
-include("globalDefine.hrl").

%%玩家上线初始化物品CD
onPlayerOnlineInitItemCD( ItemCDList )->
	put( "PlayerItemCDInfoList", ItemCDList ),
	
	Now = common:getNowSeconds(),
	
	MyFunc = fun( Record )->
					 RemainTime = Record#playerItemCDInfo.cd_time - Now,
					 case RemainTime > 0 of
						 true->
							 #pk_PlayerItemCDInfo{cdTypeID=Record#playerItemCDInfo.cdTypeID,remainTime=RemainTime, allTime=Record#playerItemCDInfo.all_time};
						 false->{}
					 end
			 end,
	MsgToUser_List = lists:map( MyFunc, ItemCDList ),
	MyFunc2 = fun( Record )->
					  Record =/= {}
			  end,
	MsgToUser_List2 = lists:filter( MyFunc2, MsgToUser_List ),
	case MsgToUser_List2 of
		[]->ok;
		_->
			player:send( #pk_GS2U_PlayerItemCDInit{info_list=MsgToUser_List2} )
	end,

	ok.

%%返回玩家物品CD存盘信息
getPlayerItemCDInfoSaveDB()->
	ItemCDList = get( "PlayerItemCDInfoList" ),
	Now = common:getNowSeconds(),
	
	MyFunc = fun( Record )->
					 RemainTime = Record#playerItemCDInfo.cd_time - Now,
					 case RemainTime > 0 of
						 true->Record;
						 false->{}
					 end
			 end,
	MsgToUser_List = lists:map( MyFunc, ItemCDList ),
	MyFunc2 = fun( Record )->
					  Record =/= {}
			  end,
	MsgToUser_List2 = lists:filter( MyFunc2, MsgToUser_List ),
	MsgToUser_List2.

%%返回能否使用某物品，检测CD
canUseItemByCD( ItemCfg )->
	try
		case ( ItemCfg#r_itemCfg.cdTypeID > 0 ) andalso
			  ( ItemCfg#r_itemCfg.cdTime > 0 ) of
			true->
				ItemCDList = get( "PlayerItemCDInfoList" ),
				Now = common:getNowSeconds(),
				
				MyFunc = fun( Record )->
								 case Record#playerItemCDInfo.cdTypeID =:= ItemCfg#r_itemCfg.cdTypeID of
									 true->
										 case Record#playerItemCDInfo.cd_time > Now of
											true->throw( {return, false} );
											false->throw( {return, true} )
										 end;
									 false->ok
								 end
						 end,
				lists:foreach( MyFunc, ItemCDList ),
				true;
			false->true
		end
	catch
		{return, Return}->Return
	end.


%%某物品CD类型开始CD
beginItemCD( ItemCfg )->
	case ( ItemCfg#r_itemCfg.cdTypeID > 0 ) andalso
		  ( ItemCfg#r_itemCfg.cdTime > 0 ) of
		true->
			ItemCDList = get( "PlayerItemCDInfoList" ),
			Now = common:getNowSeconds(),
			
			put( "beginItemCD_find", false ),
			MyFunc = fun( Record )->
							 case Record#playerItemCDInfo.cdTypeID =:= ItemCfg#r_itemCfg.cdTypeID of
								 true->
									 put( "beginItemCD_find", true ),
									 setelement( #playerItemCDInfo.cd_time, Record, Now + ItemCfg#r_itemCfg.cdTime );
								 false->Record
							 end
					 end,
			ItemCDList2 = lists:map( MyFunc, ItemCDList ),
			case get( "beginItemCD_find" ) of
				true->put( "PlayerItemCDInfoList", ItemCDList2 );
				false->
					ItemCDList3 = [#playerItemCDInfo{cdTypeID=ItemCfg#r_itemCfg.cdTypeID, cd_time=Now + ItemCfg#r_itemCfg.cdTime, all_time=ItemCfg#r_itemCfg.cdTime}] ++ ItemCDList2,
					put( "PlayerItemCDInfoList", ItemCDList3 )
			end,
			MsgToUser = #pk_GS2U_PlayerItemCDUpdate{ info = #pk_PlayerItemCDInfo{cdTypeID=ItemCfg#r_itemCfg.cdTypeID, remainTime=ItemCfg#r_itemCfg.cdTime, allTime=ItemCfg#r_itemCfg.cdTime} },
			player:send( MsgToUser );
		false->ok
	end.

%%玩家上线初始化每日使用物品次数CD	
onPlayerOnlineInitItemDailyCountCD( ItemDailyCountCDList )->
	put( "ItemDailyCountCDList", ItemDailyCountCDList ),
	
	NowSeconds=common:getNowSeconds(),
	
	MyFunc = fun( Record )->
					 case NowSeconds =< Record#playerItem_DailyCountInfo.cd_time of
						 true->Record;
						 false->{}
					 end
			 end,
	ItemDailyCountCDList2 = lists:map( MyFunc, ItemDailyCountCDList ),
	MyFunc2 = fun( Record )->
					  Record =/= {}
			  end,
	ItemDailyCountCDList3 = lists:filter( MyFunc2, ItemDailyCountCDList2 ),
	put( "ItemDailyCountCDList", ItemDailyCountCDList3 ),
	
	%%?DEBUG_OUT( "onPlayerOnlineInitItemDailyCountCD ... [~p]",[ItemDailyCountCDList3] ),

	ok.

%%返回玩家每日使用物品次数CD存盘信息
getPlayerItemDailyCountCDInfoSaveDB()->
	ItemDailyCountCDList = get( "ItemDailyCountCDList" ),
	NowSeconds=common:getNowSeconds(),
	
	MyFunc = fun( Record )->
					 case NowSeconds =< Record#playerItem_DailyCountInfo.cd_time of
						 true->Record;
						 false->{}
					 end
			 end,
	ItemDailyCountCDList2 = lists:map( MyFunc, ItemDailyCountCDList ),
	MyFunc2 = fun( Record )->
					  Record =/= {}
			  end,
	ItemDailyCountCDList3 = lists:filter( MyFunc2, ItemDailyCountCDList2 ),
	%%?DEBUG_OUT( "getPlayerItemDailyCountCDInfoSaveDB ... [~p]",[ItemDailyCountCDList3] ),
	ItemDailyCountCDList3.

%%返回能否使用某物品，检测每日使用物品次数CD
canUseItemByDailyCountCD( ItemCfg )->
	try
		case ( ItemCfg#r_itemCfg.dailyCDTypeID > 0 ) andalso
			  ( ItemCfg#r_itemCfg.dailyCDCount > 0 ) of
			true->
				ItemDailyCountCDList = get( "ItemDailyCountCDList" ),
				%%TodayBeginSecond= common:getTodayBeginSeconds() + ?ItemUsedCountCdTime,
				NowSeconds=common:getNowSeconds(),
				%%?DEBUG_OUT( "canUseItemByDailyCountCD ... [~p] [~p]",[ItemDailyCountCDList,NowSeconds] ),
				
				MyFunc = fun( Record )->
								 case Record#playerItem_DailyCountInfo.cdTypeID =:= ItemCfg#r_itemCfg.dailyCDTypeID of
									 true->
										 case NowSeconds =< Record#playerItem_DailyCountInfo.cd_time of
											true->
												case Record#playerItem_DailyCountInfo.curCount < Record#playerItem_DailyCountInfo.maxCount of
													true->throw( {return, true} );
													false->throw( {return, false} )
												end;
											false->throw( {return, true} )
										 end;
									 false->ok
								 end
						 end,
				lists:foreach( MyFunc, ItemDailyCountCDList ),
				true;
			false->true
		end
	catch
		{return, Return }->Return
	end.

%%增加物品每日使用次数
addItemDailyCount( ItemCfg, AddCount )->
	ItemDailyCountCDList = get( "ItemDailyCountCDList" ),
	put( "addItemDailyCount_find", false ),
	
	TodayBeginSecond= common:getTodayBeginSeconds() ,
	NowSeconds=common:getNowSeconds(),
	%%?DEBUG_OUT( "addItemDailyCount ... [~p] [~p]",[ItemDailyCountCDList,NowSeconds] ),
	case NowSeconds=<TodayBeginSecond+?ItemUsedCountCdTime of
		true->
			CdSeconds=TodayBeginSecond+?ItemUsedCountCdTime;
		false->
			CdSeconds=TodayBeginSecond+?ItemUsedCountCdTime+24*3600
	end,
	MyFunc = fun( Record )->
				 case Record#playerItem_DailyCountInfo.cdTypeID =:= ItemCfg#r_itemCfg.dailyCDTypeID of
					 true->
						 put( "addItemDailyCount_find", true ),
						 case NowSeconds =< Record#playerItem_DailyCountInfo.cd_time of
							true->NewRecord = setelement( #playerItem_DailyCountInfo.curCount, Record, Record#playerItem_DailyCountInfo.curCount + AddCount ),
								  NewRecord;
							false->
								NewRecord = setelement( #playerItem_DailyCountInfo.curCount, Record, AddCount ),
								NewRecord2 = setelement( #playerItem_DailyCountInfo.cd_time, NewRecord, CdSeconds ),
								NewRecord2
						 end;
					 false->Record
				 end
			 end,
	ItemDailyCountCDList2 = lists:map( MyFunc, ItemDailyCountCDList ),
	
	case get( "addItemDailyCount_find" ) of
		true->ItemDailyCountCDList3 = ItemDailyCountCDList2;
		false->
			PlayerItem_DailyCountInfo = #playerItem_DailyCountInfo{
																   cdTypeID=ItemCfg#r_itemCfg.dailyCDTypeID,
																   curCount = AddCount,
																   maxCount = ItemCfg#r_itemCfg.dailyCDCount,
																   cd_time = CdSeconds
																   },
			ItemDailyCountCDList3 = ItemDailyCountCDList2 ++ [PlayerItem_DailyCountInfo]
	end,
	%%?DEBUG_OUT( "addItemDailyCount2 ... [~p] [~p]",[ItemDailyCountCDList3,NowSeconds] ),
	put( "ItemDailyCountCDList", ItemDailyCountCDList3 ).

%%返回玩家物品每日使用剩余次数
getRemainItemDailyCount( ItemCfg )->
	try
		case ( ItemCfg#r_itemCfg.dailyCDTypeID > 0 ) andalso
			  ( ItemCfg#r_itemCfg.dailyCDCount > 0 ) of
			true->
				ItemDailyCountCDList = get( "ItemDailyCountCDList" ),
				%%CdSeconds = common:getTodayBeginSeconds() + ?ItemUsedCountCdTime+24*3600,
				NowSeconds=common:getNowSeconds(),
				%%?DEBUG_OUT( "getRemainItemDailyCount ... [~p] [~p]",[ItemDailyCountCDList,NowSeconds] ),
				
				MyFunc = fun( Record )->
								 case Record#playerItem_DailyCountInfo.cdTypeID =:= ItemCfg#r_itemCfg.dailyCDTypeID of
									 true->
										 case NowSeconds =< Record#playerItem_DailyCountInfo.cd_time of
											true->
												RemainCount = Record#playerItem_DailyCountInfo.maxCount - Record#playerItem_DailyCountInfo.curCount,
												throw( {return, RemainCount} );
											false->throw( {return, ItemCfg#r_itemCfg.dailyCDCount} )
										 end;
									 false->ok
								 end
						 end,
				lists:foreach( MyFunc, ItemDailyCountCDList ),
				ItemCfg#r_itemCfg.dailyCDCount;
			false->0
		end
	catch
		{ return, Count }->Count
	end.


%%返回玩家能否使用某位置上的物品，返回值[true or false, Item_OP_Result]
canPlayerUseItem( Location, Cell, UseCount )->
	try
		case Location =:= ?Item_Location_Bag of
			true->ok;
			false->throw(?Item_OP_Result_False_InvalidCall)
		end,
		case playerItems:isValidPlayerBagCell( Location, Cell ) of
			true->ok;
			false->throw(?Item_OP_Result_False_InvalidCall)
		end,
		case playerItems:isLockedPlayerBagCell( Location, Cell ) of
			false->ok;
			true->throw(?Item_OP_Result_False_Locked)
		end,
		ItemDBData = playerItems:getItemDBDataByPlayerBagCell( Location, Cell ),
		case ItemDBData of
			{}->throw(?Item_OP_Result_False_InvalidCall);
			_->ok
		end,
		ItemCfg = itemModule:getItemCfgDataByID( ItemDBData#r_itemDB.item_data_id ),
		case ItemCfg of
			{}->throw(?Item_OP_Result_False_InvalidCall);
			_->ok
		end,
		
		Player = player:getCurPlayerRecord(),
		case ItemCfg#r_itemCfg.level > Player#player.level of
			true->throw(?Item_OP_Result_False_Level);
			false->ok
		end,
		
		%%检测物品使用CD
		case canUseItemByCD( ItemCfg ) of
			false->throw(?Item_OP_Result_False_CDIng);
			true->ok
		end,
		
		%%检测物品每日使用次数CD
		case canUseItemByDailyCountCD( ItemCfg ) of
			false->throw(?Item_OP_Result_False_CDIng);
			true->ok
		end,
		
		case ( UseCount > ItemDBData#r_itemDB.amount ) or
			  ( UseCount > ItemCfg#r_itemCfg.useMaxCount ) of
			true->throw(?Item_OP_Result_False_InvalidCall);
			_->ok
		end,
		
		[true, ?Item_OP_Result_Succ, ItemDBData, ItemCfg]
	catch
		Result->[false, Result]
	end.


%%处理物品使用消息
onMsgPlayerUseItem( Location, Cell, UseCount )->
	try
		[CanUse|Result1] = canPlayerUseItem( Location, Cell, UseCount ),
		case CanUse of
			true->ok;
			false->[ResultCode|_]=Result1,throw({ return, ResultCode})
		end,
		[_|Result2]=Result1,
		[ItemDBData|Result3] = Result2,
		[ItemCfg|_] = Result3,
		
		
		
		
		case ItemCfg#r_itemCfg.useType of
			?Item_Use_PrepareHPMP->
				on_UseBloodbag(Location, Cell, ItemCfg, ItemDBData, UseCount),

				ok;
			?Item_Use_HPMP->
				on_UseHpMp(Location, Cell, ItemCfg, ItemDBData, UseCount),						
				ok;
			?Item_Use_PetEgg ->
				onUsePetEgg(Location, Cell, ItemCfg, ItemDBData, UseCount),				
				ok;
			?Item_Use_MountEgg->
				playerUseMountEgg(Location, Cell, ItemCfg, ItemDBData, UseCount),				
				ok;
			?Item_Use_LiBao->
				playerUseLiBao(Location,Cell, ItemCfg, ItemDBData, UseCount ),				
				ok;
			?Item_Use_Buffer->
				playerItems:setLockPlayerBagCell(Location, Cell, 1),
				player:sendMsgToMap({playerUseItem_Msg_CreateBuff, self(),player:getCurPlayerID(),Location, Cell, ItemCfg, ItemDBData, UseCount}),
				ok;
			?Item_Use_GetTask->
				on_playerUseItem_Msg_GetTask( Location,Cell,ItemCfg, ItemDBData, UseCount ),
				ok;
			?Item_Use_GetMoney->
				on_playerUseItem_Msg_GetMoney( Location,Cell,ItemCfg, ItemDBData, UseCount ),				
				ok;
			?Item_Use_GetEXP->
				on_playerUseItem_Msg_GetEXP( Location,Cell,ItemCfg, ItemDBData, UseCount ),				
				ok;
			?Item_Use_Pet_GetEXP->
				on_playerUseItem_Msg_Pet_GetEXP( Location,Cell,ItemCfg, ItemDBData, UseCount ),				
				ok;
			?Item_Use_PetPrepareHPMP->
				on_UsePetBloodbag(Location, Cell, ItemCfg, ItemDBData, UseCount),				
				ok;
			?Item_Use_AddPetMapGrowUP->
				case on_UseAddPetMaxGrowUPItem( ItemCfg, UseCount ) of
					true->
						playerItems:doDecItemAmountByLocationCell(Location, Cell, UseCount, ?Destroy_Item_Reson_Player),
						onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount ),
						ok;
					_->sendUseItemResult(player:getCurPlayerID(), Location, Cell, ?Item_OP_Result_False_PetAddGrowUP)
				end,
				ok;
			?Item_Use_GetBindedGold->
				on_playerUseItem_Msg_GetBindedGold( Location,Cell,ItemCfg, ItemDBData, UseCount ),
				ok;
			?Item_Use_AddVIPDay->
				on_playerUseItem_Msg_AddVIPDays( Location,Cell,ItemCfg, ItemDBData, UseCount ),
				ok;
			?Item_Use_AddReputation->
				on_playerUseItem_Msg_AddReputation( Location,Cell,ItemCfg, ItemDBData, UseCount ),
				ok;
			?Item_Use_AddHonor->
				on_playerUseItem_Msg_AddHonor( Location,Cell,ItemCfg, ItemDBData, UseCount ),
				ok;
			?Item_Use_AddExpByLevel->
				on_playerUseItem_Msg_AddExpByLevel( Location,Cell,ItemCfg, ItemDBData, UseCount ),
				ok;
			?Item_Use_MultyExp->
				on_playerUseItem_Msg_MultyExp(Location,Cell,ItemCfg, ItemDBData, UseCount ),
				ok;
			_->throw(?Item_OP_Result_False_InvalidCall)
		end,
		
		ok
	catch
		?Item_OP_Result_False_InvalidCall->sendUseItemResult( player:getCurPlayerID(), Location, Cell, ?Item_OP_Result_False_InvalidCall);
		{ return, Result}->sendUseItemResult( player:getCurPlayerID(), Location, Cell, Result )
	end.

%%发送玩家使用物品结果消息
sendUseItemResult( PlayerID, Location, Cell, Result )->
	player:sendToPlayer( PlayerID, #pk_PlayerUseItemResult{ location=Location, 
			cell=Cell,
			result=Result } ).

%%玩家进程，使用物品成功事件响应
onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount )->
	player:send( #pk_PlayerUseItemResult{ location=ItemDBData#r_itemDB.location, 
					cell=ItemDBData#r_itemDB.cell,
					result=?Item_OP_Result_Succ } ),
	beginItemCD(ItemCfg),
	Player = player:getCurPlayerRecord(),
	task:updateTaskProgress(?TASKTYPE_USEITEM, ItemCfg#r_itemCfg.item_data_id, 1),
	
	%% 写使用物品LOG 		 				
	ParamLog = #useitem_param{itemid = ItemCfg#r_itemCfg.item_data_id,
							  number = 1,
							  usetype = ItemCfg#r_itemCfg.useType},		
				
	case ItemCfg#r_itemCfg.needSaveLog =:= 1 of
		true->logdbProcess:write_log_player_event(?EVENT_PLAYER_USEITEM,ParamLog,Player);
		false->ok
	end,	
	
	?DEBUG_OUT( "onPlayerUseItemSucc playe[~p] item[~p] UseCount[~p]", [Player#player.name, ItemCfg#r_itemCfg.item_data_id, UseCount] ).

%%地图进程，使用物品脚本事件，询问能否使用
%%返回true，表示可以使用
%%返回false，表示脚本阻止使用，并带原因码
onUseItemCanUse_Script( _FromPID,_PlayerID,_Location, _Cell, _ItemCfg, _ItemDBData, _UseCount )->
	{true,0}.


%%玩家进程，使用药品请求
on_UseHpMp(Location, Cell, ItemCfg, ItemDBData, UseCount)->
	%%先将物品锁定，等待地图进程回复是否成功后操作
	playerItems:setLockPlayerBagCell(Location, Cell, 1),
	player:sendMsgToMap({playerMsg_UseHpMp, self(),player:getCurPlayerID(),Location, Cell, ItemCfg, ItemDBData, UseCount}),	
	ok.

%%地图进程，使用药品
on_playerMsg_UseHpMp(FromPID,PlayerID,Location, Cell, ItemCfg, ItemDBData, UseCount)->
	try
		{ScriptUseResult, FailCode } = onUseItemCanUse_Script(FromPID,PlayerID,Location, Cell, ItemCfg, ItemDBData, UseCount),
		case ScriptUseResult of
			true->ok;
			false->throw( {return, false, FailCode} )
		end,

		Player = map:getPlayer(PlayerID),
		case Player of
			{}->throw( {return, false, ?Item_OP_Result_False_InvalidCall} );
			_->ok
		end,
		
		CanNotState = ( ?Actor_State_Flag_Dead ) bor ( ?Actor_State_Flag_Disable_Hold ) bor ( ?Player_State_Flag_ChangingMap ),
		case mapActorStateFlag:isStateFlag(PlayerID, CanNotState) of
			true->throw( {return, false, ?Item_OP_Result_False_Dead} );
			false->ok
		end,

		AddBlood = ItemCfg#r_itemCfg.useParam2 * UseCount,
		case AddBlood =< 0 of
			true->throw( {return, false, ?Item_OP_Result_False_InvalidCall} );
			false->ok
		end,

		CurHp =Player#mapPlayer.life,
		MaxHp = array:get( ?max_life, Player#mapPlayer.finalProperty),
		DecHP = MaxHp - CurHp,
		case DecHP < 0 of
			true->throw( {return, false, ?Item_OP_Result_False_Full_Life} ); %%不需要加血
			false->
				case DecHP-AddBlood>=0 of
					true->
						NewHp = CurHp+AddBlood,
						charDefine:changeSetLife(Player, NewHp, true),
						FromPID ! { mapMsg_UseHpMpResult,true, ItemCfg, ItemDBData,Location, Cell, UseCount,AddBlood};
					false->
						charDefine:changeSetLife(Player, MaxHp, true),
						FromPID ! { mapMsg_UseHpMpResult,true, ItemCfg, ItemDBData,Location, Cell, UseCount,DecHP}
				end,
				
				MsgToUser = #pk_GS2U_AddLifeByItem{ actorID=PlayerID,addLife=AddBlood, percent=charDefine:getObjectLifePercent( map:getMapObjectByID( PlayerID ) ) },
				mapView:broadcast(MsgToUser, Player, 0)
		end
	catch
		{return, false, Fail_Code}->FromPID ! { mapMsg_UseHpMpResult,false,ItemCfg, ItemDBData,Location, Cell, UseCount,Fail_Code}
	end.

%%玩家进程，地图使用药品结果
on_mapMsg_UseHpMpResult( SuccOrFaile,ItemCfg, ItemDBData,Location, Cell, UseCount,RealAddBood)->
	%%物品解锁
	playerItems:setLockPlayerBagCell(Location, Cell, 0),
	
	case SuccOrFaile of
		true->
			NewItemLock = {Location, Cell, UseCount},
			playerItems:decItemInBag( [NewItemLock], ?Destroy_Item_Reson_UseHpMp),

			onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount );
		false->
			sendUseItemResult( player:getCurPlayerID(), Location, Cell, RealAddBood )
	end.

%%使用坐骑蛋
playerUseMountEgg(Location, Cell, ItemCfg, ItemDBData, UseCount)->
	case mount:onUseItemGetMount( ItemCfg ) of
		true->
			playerItems:doDecItemAmountByLocationCell(Location, Cell, 1, ?Destroy_Item_Reson_Player),
			playerUseItem:onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount );
		false->
			sendUseItemResult( player:getCurPlayerID(), Location, Cell, ?Item_OP_Result_False_InvalidCall )%%添加坐骑失败
	end.

%%玩家进程，使用血池请求
on_UseBloodPool()->
	ItemCfg = itemModule:getItemCfgDataByID( 99 ),%%写死的持续类恢复药品的cd，只为计算cd，无别的功能，策划说id绝对不变
	case canUseItemByCD(ItemCfg) of
		true->
			player:sendMsgToMap({playerMsg_UseBloodPool, self(),player:getCurPlayerID()});
		false->
			ok
	end.
%%地图进程处理使用血池
on_playerMsg_UseBloodPool(FromPID,PlayerID)->
	try
		Player = map:getPlayer(PlayerID),
		case Player of
			{}->throw( {return, false, -1} );
			_->ok
		end,
		
		CanNotState = ( ?Actor_State_Flag_Dead ) bor ( ?Actor_State_Flag_Disable_Hold ) bor ( ?Player_State_Flag_ChangingMap ),
		case mapActorStateFlag:isStateFlag(PlayerID, CanNotState) of
			true->throw( {return, false, -1} );
			false->ok
		end,
		
		CurHp =Player#mapPlayer.life,
		MaxHp = array:get( ?max_life, Player#mapPlayer.finalProperty),
		DecHP = MaxHp - CurHp,
		case DecHP =< 0 of
			true->throw( {return, false, -1} ); %%不需要加血
			_->ok
		end,
		
		HPValueCfg = etsBaseFunc:readRecord(globalSetup:getGlobalHPContainerTable(), Player#mapPlayer.level),
		case HPValueCfg of
			{}->throw( {return, false, -1} );
			_->ok
		end,
		
		BuffCfg = etsBaseFunc:readRecord(main:getGlobalBuffCfgTable(), 99),
		case BuffCfg of
			{}->throw( {return, false, -1} );
			_->ok
		end,
		
		%%一次扣除本次需要回血的数量
		DecBoolPoolValue = erlang:trunc(HPValueCfg#hpContainerCfg.player_value * (BuffCfg#buffCfg.bUFF_AllTime / BuffCfg#buffCfg.bUFF_SingleTime)),
		HaveBloodPoolValue = Player#mapPlayer.bloodPoolLife,
		case HaveBloodPoolValue =< 0 of
			true->throw( {return, false, -1} );
			_->ok
		end,
		
		buff:addBuffer(Player#mapPlayer.id, BuffCfg, Player#mapPlayer.id, 0, 0, 0),
				
		BloodPoolSetValue = HaveBloodPoolValue-DecBoolPoolValue,
		case BloodPoolSetValue < 0 of
			true->BloodPoolSetValue2 = 0;
			_->BloodPoolSetValue2 = BloodPoolSetValue
		end,
		etsBaseFunc:changeFiled(map:getMapPlayerTable(), PlayerID, #mapPlayer.bloodPoolLife, BloodPoolSetValue2 ),
		FromPID ! { mapMsg_UseBloodPoolResult,true, BloodPoolSetValue2 }
	
	catch
		{return, false, _Fail_Code}->FromPID ! { mapMsg_UseBloodPoolResult,false, 0}
	end.

%%地图进程反馈玩家进程处理宠物血池
on_mapMsg_UseBloodPoolResult(SuccOrFaile, BloodPoolSetValue)->
	case SuccOrFaile of
		true->
			ItemCfg = itemModule:getItemCfgDataByID( 99 ),%%写死的持续类恢复药品的cd，只为计算cd，无别的功能，策划说id绝对不变
			case ItemCfg of
				{}->
					ok;
				_->
					beginItemCD(ItemCfg),
					player:changePlayerBloodPool(BloodPoolSetValue, 0)
			end;
		false->ok
	end,
	
	ok.

%%玩家进程，使用宠物血池请求
on_UsePetBloodPool()->
	ItemCfg = itemModule:getItemCfgDataByID( 98 ),%%写死的持续类恢复药品的cd，只为计算cd，无别的功能，策划说id绝对不变
	case canUseItemByCD(ItemCfg) of
		true->
			player:sendMsgToMap({playerMsg_UsePetBloodPool, self(),player:getCurPlayerID()});
		false->
			ok
	end.
%%地图进程处理使用宠物血池
on_playerMsg_UsePetBloodPool(FromPID,PlayerID)->
	try
		Player = map:getPlayer(PlayerID),
		case Player of
			{}->throw( {return, false, -1} );
			_->ok
		end,
		
		Pet = map:getMapObjectByID(Player#mapPlayer.nonceOutFightPetId),
		case Pet of
			{}->throw( {return, false, -1} );
			_->ok
		end,
		PetID = Pet#mapPet.id,
		
		CanNotState = ( ?Actor_State_Flag_Dead ) bor ( ?Actor_State_Flag_Disable_Hold ) bor ( ?Player_State_Flag_ChangingMap ),
		case mapActorStateFlag:isStateFlag(PetID, CanNotState) of
			true->throw( {return, false, -1} );
			false->ok
		end,
		
		CurHp =Pet#mapPet.life,
		MaxHp = array:get( ?max_life, Pet#mapPet.finalProperty),
		DecHP = MaxHp - CurHp,

		case DecHP =< 0 of
			true->throw( {return, false, -1} ); %%不需要加血
			_->ok
		end,
		
		HPValueCfg = etsBaseFunc:readRecord(globalSetup:getGlobalHPContainerTable(), Pet#mapPet.level),
		case HPValueCfg of
			{}->throw( {return, false, -1} );
			_->ok
		end,
		
		BuffCfg = etsBaseFunc:readRecord(main:getGlobalBuffCfgTable(), 99),
		case BuffCfg of
			{}->throw( {return, false, -1} );
			_->ok
		end,
		
		%%一次扣除本次需要回血的数量
		DecBoolPoolValue = erlang:trunc(HPValueCfg#hpContainerCfg.pet_value * (BuffCfg#buffCfg.bUFF_AllTime / BuffCfg#buffCfg.bUFF_SingleTime)),
		HaveBloodPoolValue = Player#mapPlayer.petBloodPoolLife,
		
		case HaveBloodPoolValue =< 0 of
			true->throw( {return, false, -1} );
			_->ok
		end,
		
		buff:addBuffer(Pet#mapPet.id, BuffCfg, Pet#mapPet.id, 0, 0, 0),
		
		BloodPoolSetValue = HaveBloodPoolValue-DecBoolPoolValue,
		case BloodPoolSetValue < 0 of
			true->BloodPoolSetValue2 = 0;
			_->BloodPoolSetValue2 = BloodPoolSetValue
		end,
		
		etsBaseFunc:changeFiled(map:getMapPlayerTable(), PlayerID, #mapPlayer.petBloodPoolLife, BloodPoolSetValue2 ),
		FromPID ! { mapMsg_UsePetBloodPoolResult,true, BloodPoolSetValue2 }

	catch
		{return, false, _Fail_Code}->FromPID ! { mapMsg_UsePetBloodPoolResult,false, 0}
	end.
%%地图进程反馈玩家进程处理血池
on_mapMsg_UsePetBloodPoolResult(SuccOrFaile, BloodPoolSetValue)->
	case SuccOrFaile of
		true->
			ItemCfg = itemModule:getItemCfgDataByID( 98 ),%%写死的持续类恢复药品的cd，只为计算cd，无别的功能，策划说id绝对不变
			case ItemCfg of
				{}->
					ok;
				_->
					beginItemCD(ItemCfg),
					player:changePlayerPetBloodPool(BloodPoolSetValue, 0)
			end;
		false->ok
	end,
	
	ok.

%%玩家进程，使用血包物品请求
on_UseBloodbag(Location, Cell, ItemCfg, ItemDBData, UseCount)->
	playerItems:setLockPlayerBagCell(Location, Cell, 1),
	player:sendMsgToMap({playerMsg_UseBloodbag, self(),player:getCurPlayerID(),Location, Cell, ItemCfg, ItemDBData, UseCount}),	
	ok.

%%玩家进程，使用宠物血包物品请求
on_UsePetBloodbag(Location, Cell, ItemCfg, ItemDBData, UseCount)->
	playerItems:setLockPlayerBagCell(Location, Cell, 1),
	player:sendMsgToMap({playerMsg_UsePetBloodbag, self(),player:getCurPlayerID(),Location, Cell, ItemCfg, ItemDBData, UseCount}),	
	ok.

%%玩家进程，使用增加宠物最大成长率道具请求
on_UseAddPetMaxGrowUPItem( ItemCfg, UseCount )->
	case pet:addPetMaxGrowUP(ItemCfg#r_itemCfg.useParam1*UseCount) of
		true->true;
		_->false
	end.


%%地图进程处理使用血包物品
on_playerMsg_UseBloodbag(FromPID,PlayerID,Location, Cell, ItemCfg, ItemDBData, UseCount)->
    try
		{ScriptUseResult, FailCode } = onUseItemCanUse_Script(FromPID,PlayerID,Location, Cell, ItemCfg, ItemDBData, UseCount),
		case ScriptUseResult of
			true->ok;
			false->throw( {return, false, FailCode} )
		end,

		Player = map:getPlayer(PlayerID),
		case Player of
			{}->throw( {return, false, ?Item_OP_Result_False_InvalidCall} );
			_->ok
		end,
		
		CanNotState = ( ?Actor_State_Flag_Dead ) bor ( ?Actor_State_Flag_Disable_Hold ) bor ( ?Player_State_Flag_ChangingMap ),
		case mapActorStateFlag:isStateFlag(PlayerID, CanNotState) of
			true->throw( {return, false, ?Item_OP_Result_False_Dead} );
			false->ok
		end,

		AddBlood = ItemCfg#r_itemCfg.useParam1 * UseCount,
		case AddBlood =< 0 of
			true->throw( {return, false, ?Item_OP_Result_False_InvalidCall} );
			false->ok
		end,
		
		%%暂时用life
		CurBloodPool =Player#mapPlayer.bloodPoolLife,
		MaxBloodPool = globalSetup:getGlobalSetupValue( #globalSetup.maxPlayerBloodPool ),
		CanAddBP = MaxBloodPool - CurBloodPool,
		
		NewBP = CurBloodPool + AddBlood,
		
		case ( CanAddBP =< 0 ) or (NewBP > MaxBloodPool) of
			true->throw( {return, false, ?Item_OP_Result_False_Full_BloodPool} ); %%不需要加血
			false->
%% 				etsBaseFunc:changeFiled(map:getMapPlayerTable(), PlayerID, #mapPlayer.life, NewBP),
				etsBaseFunc:changeFiled(map:getMapPlayerTable(), PlayerID, #mapPlayer.bloodPoolLife, NewBP),
				FromPID ! { mapMsg_UseBoolbagResult,true,ItemCfg, ItemDBData,Location, Cell, UseCount,NewBP}
		end
	catch
		{return, false, Fail_Code}->FromPID ! { mapMsg_UseBoolbagResult,false,ItemCfg, ItemDBData,Location, Cell, UseCount,Fail_Code}
	end.


%%地图进程处理使用宠物血包物品
on_playerMsg_UsePetBloodbag(FromPID,PlayerID,Location, Cell, ItemCfg, ItemDBData, UseCount)->
    try
		{ScriptUseResult, FailCode } = onUseItemCanUse_Script(FromPID,PlayerID,Location, Cell, ItemCfg, ItemDBData, UseCount),
		case ScriptUseResult of
			true->ok;
			false->throw( {return, false, FailCode} )
		end,

		Player = map:getPlayer(PlayerID),
		case Player of
			{}->throw( {return, false, ?Item_OP_Result_False_InvalidCall} );
			_->ok
		end,
		
		CanNotState = ( ?Actor_State_Flag_Dead ) bor ( ?Actor_State_Flag_Disable_Hold ) bor ( ?Player_State_Flag_ChangingMap ),
		case mapActorStateFlag:isStateFlag(PlayerID, CanNotState) of
			true->throw( {return, false, ?Item_OP_Result_False_Dead} );
			false->ok
		end,

		AddBlood = ItemCfg#r_itemCfg.useParam1 * UseCount,
		case AddBlood =< 0 of
			true->throw( {return, false, ?Item_OP_Result_False_InvalidCall} );
			false->ok
		end,
		
		%%暂时用life
		CurBloodPool =Player#mapPlayer.petBloodPoolLife,
		MaxBloodPool = globalSetup:getGlobalSetupValue( #globalSetup.maxPlayerBloodPool ),
		CanAddBP = MaxBloodPool - CurBloodPool,
		
		NewBP = CurBloodPool + AddBlood,
		
		case ( CanAddBP =< 0 ) or (NewBP > MaxBloodPool) of
			true->throw( {return, false, ?Item_OP_Result_False_Full_BloodPool} ); %%不需要加血
			false->
%% 				etsBaseFunc:changeFiled(map:getMapPlayerTable(), PlayerID, #mapPlayer.life, NewBP),
				etsBaseFunc:changeFiled(map:getMapPlayerTable(), PlayerID, #mapPlayer.petBloodPoolLife, NewBP),
				FromPID ! { mapMsg_UsePetBoolbagResult,true,ItemCfg, ItemDBData,Location, Cell, UseCount,NewBP}
		end
	catch
		{return, false, Fail_Code}->FromPID ! { mapMsg_UsePetBoolbagResult,false,ItemCfg, ItemDBData,Location, Cell, UseCount,Fail_Code}
	end.

%%地图进程反馈玩家进程处理血包物品
on_mapMsg_UseBoolbagResult( SuccOrFaile,ItemCfg, ItemDBData,Location, Cell, UseCount,RealAddBood)->
	playerItems:setLockPlayerBagCell(Location, Cell, 0),
	
	case SuccOrFaile of
		true->
			NewItemLock = {Location, Cell, UseCount},
			playerItems:decItemInBag( [NewItemLock], ?Destroy_Item_Reson_Player),
			player:changePlayerBloodPool(RealAddBood,0),
			onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount );
		false->
			sendUseItemResult( player:getCurPlayerID(), Location, Cell, RealAddBood )
	end.

%%地图进程反馈玩家进程处理宠物血包物品
on_mapMsg_UsePetBoolbagResult( SuccOrFaile,ItemCfg, ItemDBData,Location, Cell, UseCount,RealAddBood)->
	playerItems:setLockPlayerBagCell(Location, Cell, 0),
	
	case SuccOrFaile of
		true->
			NewItemLock = {Location, Cell, UseCount},
			playerItems:decItemInBag( [NewItemLock], ?Destroy_Item_Reson_Player),
			player:changePlayerPetBloodPool(RealAddBood,0),
			onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount );
		false->
			sendUseItemResult( player:getCurPlayerID(), Location, Cell, RealAddBood )
	end.

%%玩家进程，使用宠物蛋请求
onUsePetEgg(Location, Cell, ItemCfg, ItemDBData, UseCount) ->
	case pet:onCreatePet(ItemCfg#r_itemCfg.useParam1) of
		{}->sendUseItemResult( player:getCurPlayerID(), Location, Cell, ?Item_OP_Result_False_Full_Pet );
		Pet ->
			playerItems:doDecItemAmountByLocationCell(Location, Cell, UseCount, ?Destroy_Item_Reson_Player),
			onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount ),
			pet:sendOnePetToClient(Pet)
	end.


%%玩家进程，玩家使用礼包
playerUseLiBao(Location,Cell,ItemCfg, ItemDBData, UseCount)->
	DropId = ItemCfg#r_itemCfg.useParam1,
	
	DropItemList = drop:getDropListByDropId(DropId),
	
	case DropItemList of
		[]->%%礼包掉落为空？不会吧
			ok;
		_->
			SpaceCellCount = playerItems:getPlayerBagSpaceCellCount(),
			DropItemCount = length( DropItemList ),
			case SpaceCellCount < DropItemCount of
				true->sendUseItemResult( player:getCurPlayerID(), Location, Cell, ?Item_OP_Result_False_Full_Bag );
				false->
					playerItems:addItemToPlayerByItemList(DropItemList, ?Get_Item_Reson_ItemUse),
					onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount ),
					playerItems:doDecItemAmountByLocationCell(Location, Cell, UseCount, ?Destroy_Item_Reson_Player)
			end
	end,
	ok.
	

%%地图进程，玩家使用物品，创建Buff
on_playerUseItem_Msg_CreateBuff( FromPID,PlayerID,Location, Cell, ItemCfg, ItemDBData, UseCount )->
    try
		{ScriptUseResult, FailCode } = onUseItemCanUse_Script(FromPID,PlayerID,Location, Cell, ItemCfg, ItemDBData, UseCount),
		case ScriptUseResult of
			true->ok;
			false->throw( {return, false, FailCode} )
		end,

		Player = map:getPlayer(PlayerID),
		case Player of
			{}->throw( {return, false, ?Item_OP_Result_False_InvalidCall} );
			_->ok
		end,
		
		CanNotState = ( ?Actor_State_Flag_Dead ) bor ( ?Actor_State_Flag_Disable_Hold ) bor ( ?Player_State_Flag_ChangingMap ),
		case mapActorStateFlag:isStateFlag(PlayerID, CanNotState) of
			true->throw( {return, false, ?Item_OP_Result_False_Dead} );
			false->ok
		end,

%% 		BuffCfg = main:getGlobalBuffCfgTable(),
		BuffCfg = etsBaseFunc:readRecord(main:getGlobalBuffCfgTable(), ItemCfg#r_itemCfg.useParam1),
%% 		BuffCfg = main:getGlobalBuffCfgTable( ItemCfg#r_itemCfg.useParam1 ),
		case BuffCfg of
			{}->throw( {return, false, ?Item_OP_Result_False_InvalidCall} );
			_->ok
		end,
		
		AddBuffResult = buff:addBuffer(PlayerID, BuffCfg, PlayerID, 0, 0, 0 ),
		case AddBuffResult of
			true->FromPID ! { on_playerUseItem_Msg_CreateBuff_Result,true,ItemCfg, ItemDBData,Location, Cell, UseCount,0};
			false->throw( {return, false, ?Item_OP_Result_False_InvalidCall} )
		end,
		ok
	catch
		{return, false, Fail_Code}->FromPID ! { on_playerUseItem_Msg_CreateBuff_Result,false,ItemCfg, ItemDBData,Location, Cell, UseCount,Fail_Code}
	end.

%%玩家进程，使用物品创建buff结果
on_playerUseItem_Msg_CreateBuff_Result( SuccOrFaile,ItemCfg, ItemDBData,Location, Cell, UseCount,FailCode)->
	playerItems:setLockPlayerBagCell(Location, Cell, 0),
	
	case SuccOrFaile of
		true->
			NewItemLock = {Location, Cell, UseCount},
			playerItems:decItemInBag( [NewItemLock], ?Destroy_Item_Reson_Player),

			onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount );
		false->
			sendUseItemResult( player:getCurPlayerID(), Location, Cell, FailCode )
	end.

%%玩家进程，使用物品获得任务
on_playerUseItem_Msg_GetTask( Location,Cell,ItemCfg, ItemDBData, UseCount )->
	Return = task:on_mapMsg_U2GS_AcceptTaskRequest( #pk_U2GS_AcceptTaskRequest{nQuestID=ItemCfg#r_itemCfg.useParam1, nNpcActorID=0}, true ),
	case Return of
		true->
			NewItemLock = {Location, Cell, UseCount},
			playerItems:decItemInBag( [NewItemLock], ?Destroy_Item_Reson_Player),

			onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount ),
			
			%%增加每日使用计数
			addItemDailyCount( ItemCfg, 1 ),
			%%通知剩余使用次数
			RemainCout = getRemainItemDailyCount( ItemCfg ),
			%%?魏进龙请补充
			RemainCountMsg = #pk_GS2U_ItemDailyCount{remainCount = RemainCout,
													 task_data_id = ItemCfg#r_itemCfg.useParam1},
			player:send(RemainCountMsg),

			ok;
		false->
			sendUseItemResult( player:getCurPlayerID(), Location, Cell, ?Item_OP_Result_False_GetTask )
	end.

%%玩家进程，使用物品获得金钱
on_playerUseItem_Msg_GetMoney( Location,Cell,ItemCfg, ItemDBData, UseCount )->
	case ItemCfg#r_itemCfg.useParam1 > 0 of
		true->
			ParamTuple = #token_param{changetype = ?Money_Change_UseItem,
									  param1=ItemCfg#r_itemCfg.item_data_id},
			case ItemCfg#r_itemCfg.useParam2 =:= 0 of
				true->%%绑定
					playerMoney:addPlayerBindedMoney(ItemCfg#r_itemCfg.useParam1, ?Money_Change_UseItem, ParamTuple);
				false->%%不绑定
					playerMoney:addPlayerMoney(ItemCfg#r_itemCfg.useParam1, ?Money_Change_UseItem, ParamTuple)
			end,

			NewItemLock = {Location, Cell, UseCount},
			playerItems:decItemInBag( [NewItemLock], ?Destroy_Item_Reson_Player),

			onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount ),
			
			ok;
		false->
			sendUseItemResult( player:getCurPlayerID(), Location, Cell, ?Item_OP_Result_False_GetTask )
	end.

%%玩家进程，使用物品获得绑定金钱
on_playerUseItem_Msg_GetBindedGold( Location,Cell,ItemCfg, ItemDBData, UseCount )->
	case ItemCfg#r_itemCfg.useParam1 > 0 of
		true->
			ParamTuple = #token_param{changetype = ?Money_Change_UseItem,
									  param1=ItemCfg#r_itemCfg.item_data_id},
			
			playerMoney:addPlayerBindedGold(ItemCfg#r_itemCfg.useParam1, ?Money_Change_UseItem, ParamTuple),

			NewItemLock = {Location, Cell, UseCount},
			playerItems:decItemInBag( [NewItemLock], ?Destroy_Item_Reson_Player),

			onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount ),
			
			ok;
		false->
			sendUseItemResult( player:getCurPlayerID(), Location, Cell, ?Item_OP_Result_False_InvalidCall )
	end.

%%玩家进程，使用物品获得经验
on_playerUseItem_Msg_GetEXP( Location,Cell,ItemCfg, ItemDBData, UseCount )->
	case ItemCfg#r_itemCfg.useParam1 > 0 of
		true->
			ParamTuple = #exp_param{changetype = ?Exp_Change_UseItem,param1=ItemCfg#r_itemCfg.item_data_id},
			player:addPlayerEXP( ItemCfg#r_itemCfg.useParam1, ?Exp_Change_UseItem, ParamTuple),
			NewItemLock = {Location, Cell, UseCount},
			playerItems:decItemInBag( [NewItemLock], ?Destroy_Item_Reson_Player),

			onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount ),
			
			ok;
		false->
			sendUseItemResult( player:getCurPlayerID(), Location, Cell, ?Item_OP_Result_False_GetTask )
	end.

%%玩家进程，使用物品出战宠物获得经验
on_playerUseItem_Msg_Pet_GetEXP( Location,Cell,ItemCfg, ItemDBData, UseCount )->
	case ItemCfg#r_itemCfg.useParam1 > 0 of
		true->
			OutFightPet  = player:getCurPlayerProperty( #player.outFightPet ),
			case OutFightPet =:= 0 of
				true->
					sendUseItemResult( player:getCurPlayerID(), Location, Cell, ?Item_OP_Result_False_PetGetEXP );
				false->
					pet:addPetExp(ItemCfg#r_itemCfg.useParam1, ?Exp_Change_UseItem ),
					
					NewItemLock = {Location, Cell, UseCount},
					playerItems:decItemInBag( [NewItemLock], ?Destroy_Item_Reson_Player),
		
					onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount )
			end,
			
			ok;
		false->
			sendUseItemResult( player:getCurPlayerID(), Location, Cell, ?Item_OP_Result_False_GetTask )
	end.

%%玩家进程，使用物品获得VIP天数
on_playerUseItem_Msg_AddVIPDays( Location,Cell,ItemCfg, ItemDBData, UseCount )->
	case ItemCfg#r_itemCfg.useParam1 > 0 of
		true->
			?LOG_OUT( "Player id = ~p Use VipCard ~p days", [player:getCurPlayerID(), ItemCfg#r_itemCfg.useParam1] ),
			vip:useVipCard(ItemCfg#r_itemCfg.useParam1),

			NewItemLock = {Location, Cell, UseCount},
			playerItems:decItemInBag( [NewItemLock], ?Destroy_Item_Reson_Player),

			onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount ),
			
			ok;
		false->
			sendUseItemResult( player:getCurPlayerID(), Location, Cell, ?Item_OP_Result_False_InvalidCall )
	end.

%%玩家进程，使用物品获得声望
on_playerUseItem_Msg_AddReputation( Location,Cell,ItemCfg, ItemDBData, UseCount )->
	case ItemCfg#r_itemCfg.useParam1 > 0 of
		true->
			?LOG_OUT( "Player id = ~p use item toadd reputation ~p ", [player:getCurPlayerID(), ItemCfg#r_itemCfg.useParam1] ),
			player:addCurPlayerCredit(ItemCfg#r_itemCfg.useParam1,false, ""),

			NewItemLock = {Location, Cell, UseCount},
			playerItems:decItemInBag( [NewItemLock], ?Destroy_Item_Reson_Player),

			onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount ),
			
			ok;
		false->
			sendUseItemResult( player:getCurPlayerID(), Location, Cell, ?Item_OP_Result_False_InvalidCall )
	end,
ok.

%%玩家进程，使用物品获得荣誉
on_playerUseItem_Msg_AddHonor( Location,Cell,ItemCfg, ItemDBData, UseCount )->
	case ItemCfg#r_itemCfg.useParam1 > 0 of
		true->
			?LOG_OUT( "Player id = ~p use item toadd Honor ~p ", [player:getCurPlayerID(), ItemCfg#r_itemCfg.useParam1] ),
			player:addCurPlayerHonor(ItemCfg#r_itemCfg.useParam1,false, ""),

			NewItemLock = {Location, Cell, UseCount},
			playerItems:decItemInBag( [NewItemLock], ?Destroy_Item_Reson_Player),

			onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount ),
			
			ok;
		false->
			sendUseItemResult( player:getCurPlayerID(), Location, Cell, ?Item_OP_Result_False_InvalidCall )
	end,
ok.

%%玩家进程，使用物品根据等级获得经验
on_playerUseItem_Msg_AddExpByLevel( Location,Cell,ItemCfg, ItemDBData, UseCount )->
	Level=player:getCurPlayerProperty(#player.level),
	ConvoyAwardList=convoy:getAwardByLevel(Level),
	case ConvoyAwardList of
		{} ->
			?DEBUG_OUT( "on_playerUseItem_Msg_AddExpByLevelno level cfg Level= ~p",[Level] ),
			sendUseItemResult( player:getCurPlayerID(), Location, Cell, ?Item_OP_Result_False_InvalidCall ),
			ok;
		_->
			ExpConfig=ConvoyAwardList#convoyAwardCfg.item_exp,
			ExpRatio=ItemCfg#r_itemCfg.useParam1,
			ChangeEXP=( ExpConfig* ExpRatio) div 10000,
			ParamTuple = #exp_param{changetype = ?Exp_Change_UseItem,param1=ItemCfg#r_itemCfg.item_data_id},
			player:addPlayerEXP( ChangeEXP, ?Exp_Change_UseItem, ParamTuple),

			NewItemLock = {Location, Cell, UseCount},
			playerItems:decItemInBag( [NewItemLock], ?Destroy_Item_Reson_Player),

			onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount ),
			
			ok
	end,
ok.

%%玩家进程，修改多倍经验
on_playerUseItem_Msg_MultyExp( Location,Cell,ItemCfg, ItemDBData, UseCount )->
case ItemCfg#r_itemCfg.useParam1 > 0 of
		true->
			?LOG_OUT( "Player id = ~p use item toadd MultyExp time ~p ", [player:getCurPlayerID(), ItemCfg#r_itemCfg.useParam1] ),
			player:addMultyExpTimeByItem(ItemCfg#r_itemCfg.useParam1),

			NewItemLock = {Location, Cell, UseCount},
			playerItems:decItemInBag( [NewItemLock], ?Destroy_Item_Reson_Player),

			onPlayerUseItemSucc( ItemCfg, ItemDBData, UseCount ),
			
			ok;
		false->
			sendUseItemResult( player:getCurPlayerID(), Location, Cell, ?Item_OP_Result_False_InvalidCall )
	end,
ok.


%%玩家上线初始化player var array,并发送玩家变量和世界变量给客户端
onPlayerOnlineInitVarArray( VarArray )->	
	MyFunc1 = fun( Index )->
					case array:get(Index, VarArray) of
						undefined -> {};
						0 -> {};
						Value ->  #pk_VariantData{index=Index,value=Value}
					end
			  end,
	VariantData_List = common:for( 1, ?Max_PlayerVariant_Syn_Client_Count+1, MyFunc1 ),

	MyFunc2 = fun( Record )->
					  Record =/= {}
			  end,

	VariantData_List2 = lists:filter( MyFunc2, VariantData_List ),
	case VariantData_List2 of
		[]->ok;
		_->
			player:send( #pk_GS2U_VariantDataSet{variant_type=?Variant_Type_Player,
										info_list=VariantData_List2} )
	end,

	%%发送世界变量给客户端
	WorldVarArray = etsBaseFunc:getRecordField( ?GlobalMainAtom, ?GlobalMainID, #globalMain.varArray ),
	MyFunc3 = fun( Index )->
					case array:get(Index, WorldVarArray) of
						undefined -> {};
						0 -> {};
						Value ->  #pk_VariantData{index=Index,value=Value}
					end
			  end,
	WorldVariantData_List = common:for( 1, ?Max_WorldVariant_Syn_Client_Count+1, MyFunc3 ),
	MyFunc4 = fun( Record )->
					  Record =/= {}
			  end,

	WorldVariantData_List2 = lists:filter( MyFunc4, WorldVariantData_List ),
	case WorldVariantData_List2 of
		[]->ok;
		_->
			player:send( #pk_GS2U_VariantDataSet{variant_type=?Variant_Type_World,
										info_list=WorldVariantData_List2} )
	end,


	ok.
