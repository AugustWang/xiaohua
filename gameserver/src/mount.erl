-module(mount).

%%
%% Include files
%%
-include("mysql.hrl").
-include("db.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("package.hrl").
-include("itemDefine.hrl").
-include("mapDefine.hrl").
-include("logdb.hrl").
-include("textDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all).


%%返回坐骑基础属性mountCfgTable
getMountCfgTable()->
	mountCfgTable.
%%返回坐骑等级信息mountLevelCfgTable
getMountLevelCfgTable()->
	mountLevelCfgTable.
%%返回坐骑升级消耗表mountHanceCfgTable
getMountHanceCfgTable()->
	mountHanceCfgTable.
%%返回坐骑升级消耗表playerMountInfoTable
getPlayerMountInfoTable()->
	get("PlayerMountInfoTable").

%%返回已装备的坐骑ID
getEquipedMountID()->
	get( "Mount_Equiped_ID" ).

%%返回已骑上的坐骑ID
getUpMountID()->
	get( "Mount_Up_ID" ).


%%初始化坐骑数据
loadMountBinTable()->
	case db:openBinData( "mount.bin" ) of
		[] ->
			?ERROR_OUT( "loadMountBinTable openBinData mount.bin false []" );
		MountCfgData ->
			db:loadBinData( MountCfgData, mountCfg ),
			
			MountCfgTable = ets:new( 'mountCfgTable', [protected, named_table,{read_concurrency,true},  { keypos, #mountCfg.mount_data_id }] ),
			
			MountCfgList = db:matchObject(mountCfg,  #mountCfg{_='_'} ),
			MyFunc = fun( Record )->
							 etsBaseFunc:insertRecord(MountCfgTable, Record)
					 end,
			lists:map( MyFunc, MountCfgList ),
			?DEBUG_OUT( "load mount.bin succ" )
	end,
	
	case db:openBinData( "mountLevelProperty.bin" ) of
		[] ->
			?ERROR_OUT( "loadMountBinTable openBinData mountLevelProperty.bin false []" );
		MountLevelCfgData ->
			db:loadBinData( MountLevelCfgData, mountLevelCfg ),
			
			MountLevelCfgTable = ets:new( 'mountLevelCfgTable', [protected, named_table,{read_concurrency,true},  { keypos, #mountLevelCfg.mountLevel }] ),
			
			MountLevelCfgList = db:matchObject(mountLevelCfg,  #mountLevelCfg{_='_'} ),
			MyFunc2 = fun( Record )->
							 etsBaseFunc:insertRecord(MountLevelCfgTable, Record)
					 end,
			lists:map( MyFunc2, MountLevelCfgList ),
			?DEBUG_OUT( "load mountLevelProperty.bin succ" )
	end,
	case db:openBinData( "mountenhance.bin" ) of
		[] ->
			?ERROR_OUT( "loadMountBinTable openBinData mountenhance.bin false []" );
		MountHanceCfgData ->
			db:loadBinData( MountHanceCfgData, mountHanceCfg ),
			
			MountHanceCfgTable = ets:new( 'mountHanceCfgTable', [protected, named_table, {read_concurrency,true}, { keypos, #mountHanceCfg.mountlevel }] ),
			
			MountHanceCfgList = db:matchObject(mountHanceCfg,  #mountHanceCfg{_='_'} ),
			MyFunc3 = fun( Record )->
							 etsBaseFunc:insertRecord(MountHanceCfgTable, Record)
					 end,
			lists:map( MyFunc3, MountHanceCfgList ),
			?DEBUG_OUT( "load mountenhance.bin succ" )
	end,
	ok.	

%%玩家上线初始化坐骑
onPlayerOnlineInitMount( MountList )->
	put( "Mount_Equiped_ID", 0 ),
	put( "Mount_Up_ID", 0 ),
	put( "MountPropertyArray_MoveSpeed", 0 ),
	
	PlayerMountInfoTable = ets:new( 'playerMountInfoTable', [protected, { keypos, #playerMountInfo.mount_data_id }] ),
	put( "PlayerMountInfoTable", PlayerMountInfoTable ),
	
	case MountList of
		[]->ok;
		_->
			MyFunc = fun( Record )->
							 etsBaseFunc:insertRecord( PlayerMountInfoTable, Record),
							 case Record#playerMountInfo.equiped =:= 0 of
								 true->ok;
								 false->put( "Mount_Equiped_ID", Record#playerMountInfo.mount_data_id )
							 end
					 end,
			lists:foreach( MyFunc, MountList ),
			
			ok
	end.

%%获取玩家指定坐骑信息	
getPlayerMountInfo(MountID)->
	etsBaseFunc:readRecord( ?MODULE:getPlayerMountInfoTable(), MountID ).

%%返回玩家坐骑信息
getPlayerMountInfoList()->
	etsBaseFunc:getAllRecord(?MODULE:getPlayerMountInfoTable()).

%%玩家第一次打开坐骑UI请求坐骑信息
on_U2GS_QueryMyMountInfo()->
	PlayerMountInfoList = etsBaseFunc:getAllRecord( ?MODULE:getPlayerMountInfoTable() ),
	
	MyFunc = fun( Record )->
					 #pk_mountInfo{
									mountDataID=Record#playerMountInfo.mount_data_id,
									level=Record#playerMountInfo.level,
									equiped=Record#playerMountInfo.equiped,
									progress=Record#playerMountInfo.progress,
									benison_Value = Record#playerMountInfo.benison_Value
									}
			 end,
	MountInfoList = lists:map(MyFunc, PlayerMountInfoList),
	player:send( #pk_GS2U_QueryMyMountInfoResult{mounts=MountInfoList}).


%%物品使用获得坐骑
onUseItemGetMount( ItemCfg )->
	try
		MountDataID = ItemCfg#r_itemCfg.useParam1,
		MountCfg = etsBaseFunc:readRecord( ?MODULE:getMountCfgTable(), MountDataID ),
		case MountCfg of
			{}->throw( {return, false} );
			_->ok
		end,
		
		%%与策划（林海、武置）商定，玩家只会拥有一个相同ID的坐骑
		ExistMount = etsBaseFunc:readRecord( ?MODULE:getPlayerMountInfoTable(), MountDataID ),
		case ExistMount of
			{}->ok;
			_->throw( {return, false} )
		end,
		
		PlayerMountInfo = #playerMountInfo{mount_data_id = MountDataID,
						   playerID = player:getCurPlayerID(),
						   level = 1,
						   progress = 0,
						   equiped = 0,
						   benison_Value=0},
		etsBaseFunc:insertRecord(?MODULE:getPlayerMountInfoTable(), PlayerMountInfo),
		
		MsgToUser = #pk_GS2U_MountInfoUpdate{ mounts=#pk_mountInfo{
																   mountDataID=MountDataID,
																   level=1,
																   equiped=0,
																   progress=0,
																   benison_Value = 0
																   } },
		player:send( MsgToUser ),
		
		?DEBUG_OUT( "player[~p] get mount[~p] by item[~p]", [player:getCurPlayerID(), PlayerMountInfo, ItemCfg#r_itemCfg.item_data_id] ),

		true
	catch
		{ return, false }->false
	end.

%%装备马请求
on_U2GS_MountEquipRequest( #pk_U2GS_MountEquipRequest{mountDataID=MountDataID}=_Msg)->
	try
		%%检测是否存在
		ExistMount = etsBaseFunc:readRecord( ?MODULE:getPlayerMountInfoTable(), MountDataID ),
		case ExistMount of
			{}->throw( {return, ?PlayerMountOP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		%%检测是否已经装备
		EquipedMountID = getEquipedMountID(),
		case EquipedMountID =:= MountDataID of
			true->throw( {return, ?PlayerMountOP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		%%先将已装备的修改掉
		case EquipedMountID =:= 0 of
			true->ok;
			_->
				EquipedMount = etsBaseFunc:readRecord(?MODULE:getPlayerMountInfoTable(), EquipedMountID),
				
				etsBaseFunc:changeFiled(?MODULE:getPlayerMountInfoTable(), EquipedMountID, #playerMountInfo.equiped, 0 ),
				
				MsgToUser = #pk_GS2U_MountInfoUpdate{ mounts=#pk_mountInfo{
																		   mountDataID=EquipedMountID,
																		   level=EquipedMount#playerMountInfo.level,
																		   equiped=0,
																		   progress=EquipedMount#playerMountInfo.progress,
																		   benison_Value = EquipedMount#playerMountInfo.benison_Value
																		   } },
				player:send( MsgToUser )
		end,

		%%如果已经上马，先下马
		 case getUpMountID() of
			0->ok;
			_->		
				%%属性更新通知
				player:sendMsgToMap( {playerDownMount, self(), player:getCurPlayerID()} )
		end,
		
		%%将新的装备坐骑修改
		etsBaseFunc:changeFiled(?MODULE:getPlayerMountInfoTable(), MountDataID, #playerMountInfo.equiped, 1 ),
		
		MsgToUser2 = #pk_GS2U_MountInfoUpdate{ mounts=#pk_mountInfo{
																   mountDataID=MountDataID,
																   level=ExistMount#playerMountInfo.level,
																   equiped=1,
																   progress=ExistMount#playerMountInfo.progress,
																   benison_Value = ExistMount#playerMountInfo.benison_Value
																   } },
		player:send( MsgToUser2 ),
		%%要记得更新
		put( "Mount_Equiped_ID", MountDataID ),
		

		%%属性更新通知
		playerMap:onPlayer_LevelEquipPet_Changed(),
		
		ok
	catch
		{return, ReturnCode}->player:send( #pk_GS2U_MountOPResult{mountDataID=MountDataID, result=ReturnCode})
	end.

%%取消装备马请求
on_U2GS_Cancel_MountEquipRequest()->
	EquipedMountID = getEquipedMountID(),
	
	try
		%%检测是否已经装备
		case EquipedMountID =:= 0 of
			true->throw( {return, ?PlayerMountOP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		EquipedMount = etsBaseFunc:readRecord(?MODULE:getPlayerMountInfoTable(), EquipedMountID),
		
		%%将新的装备坐骑修改
		etsBaseFunc:changeFiled(?MODULE:getPlayerMountInfoTable(), EquipedMountID, #playerMountInfo.equiped, 0 ),
		
		MsgToUser = #pk_GS2U_MountInfoUpdate{ mounts=#pk_mountInfo{
																   mountDataID=EquipedMountID,
																   level=EquipedMount#playerMountInfo.level,
																   equiped=0,
																   progress=EquipedMount#playerMountInfo.progress,
																   benison_Value = EquipedMount#playerMountInfo.benison_Value
																   } },
		player:send( MsgToUser ),
		%%要记得更新
		put( "Mount_Equiped_ID", 0 ),
		
		%%如果已经上马，先下马
		 case getUpMountID() of
			0->ok;
			_->		
				%%属性更新通知
				player:sendMsgToMap( {playerDownMount, self(), player:getCurPlayerID()} )
		end,

		%%属性更新通知
		playerMap:onPlayer_LevelEquipPet_Changed(),
		
		ok
	catch
		{return, ReturnCode}->player:send( #pk_GS2U_MountOPResult{mountDataID=EquipedMountID, result=ReturnCode})
	end.


%%上马请求
on_U2GS_MountUpRequest()->
	EquipedMountID = getEquipedMountID(),
	
	try
		case etsBaseFunc:readRecord(main:getGlobalMapCfgTable(), player:getCurPlayerProperty(#player.map_data_id)) of
			{}->ok;
			MapCfg->
				%%战场允许上马
				case MapCfg#mapCfg.type =:= ?Map_Type_Normal_Copy  of
					true->	%%如果是副本地图，不能上马
						throw( {return, ?PlayerMountOP_Result_Fail_Copy} );
					_->ok
				end
		end,
		case convoy:get_Convoy_Flag() of
			true -> throw( {return, ?PlayerMountOP_Result_Fail_Convoy} );
			false -> ok
		end,
		%%检测是否已经装备
		case EquipedMountID =:= 0 of
			true->throw( {return, ?PlayerMountOP_Result_Fail_EquipedFirst} );
			_->ok
		end,
		
		%%检测是否已经骑上坐骑
		UpMountID = getUpMountID(),
		case EquipedMountID =:= UpMountID of
			true->throw( {return, ?PlayerMountOP_Result_Fail_ExistUP} );
			false->ok
		end,
		
		%%属性更新通知
		player:sendMsgToMap( {playerOnMount, self(), player:getCurPlayerID(), EquipedMountID, get("MountPropertyArray_MoveSpeed")} ),
		
		ok
	catch
		{return, ReturnCode}->player:send( #pk_GS2U_MountOPResult{mountDataID=EquipedMountID, result=ReturnCode})
	end.

on_M2U_MountUpResult(Result, MountDataID)->
	case Result of
		?PlayerMountOP_Result_Succ->
			put( "Mount_Up_ID", MountDataID );
		_->ok
	end,
	ok.

%%地图进程，上马
on_ViewMount(PID, PlayerID,MountDataID, MoveSpeed_Percent)->
	Player = map:getPlayer(PlayerID),
	case Player of
		{}-> PID ! { playerOnMountResult, ?PlayerMountOP_Result_Fail_InvalidCall, MountDataID};
		_->
			CanNotState = ( ?Actor_State_Flag_Dead ) bor ( ?Player_State_Flag_ChangingMap ),
			New_PalyerMountView = #palyerMountView{mountDataID=MountDataID, mountSpeed=MoveSpeed_Percent},
			etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.playerMountView, New_PalyerMountView),
			case mapActorStateFlag:isStateFlag( PlayerID, CanNotState ) of
				true->
					PID ! { playerOnMountResult, ?PlayerMountOP_Result_Fail_InvalidCall, MountDataID};%%这些状态下不更新属性
				false->
					damageCalculate:calcFinaProperty(PlayerID),
					%%广播上马消息
					MsgToUser = #pk_GS2U_MountUp{ actorID=PlayerID, mount_data_id=MountDataID  },
					mapView:broadcast(MsgToUser, Player, 0),
					PID ! { playerOnMountResult, ?PlayerMountOP_Result_Succ, MountDataID}
			end
	end,

	ok.

%%下马请求
on_U2GS_MountDownRequest()->
	EquipedMountID = getEquipedMountID(),
	
	try
		%%检测是否已经装备
		case EquipedMountID =:= 0 of
			true->throw( {return, ?PlayerMountOP_Result_Fail_NoTip} );
			_->ok
		end,
		
		%%检测是否已经骑上坐骑
		UpMountID = getUpMountID(),
		case EquipedMountID =:= UpMountID of
			true->ok;
			false->throw( {return, ?PlayerMountOP_Result_Fail_NoTip} )
		end,
		
		%%属性更新通知
		player:sendMsgToMap( {playerDownMount, self(), player:getCurPlayerID()} ),
		
		ok
	catch
		{return, ReturnCode}->player:send( #pk_GS2U_MountOPResult{mountDataID=EquipedMountID, result=ReturnCode})
	end.

on_M2U_MountDownResult(Result)->
	case Result of
		?PlayerMountOP_Result_Succ->
			put( "Mount_Up_ID", 0 );
		_->ok
	end.

%%地图进程，下马
on_ViewMount(PID, PlayerID,WithdCheck)->
	Player = map:getPlayer(PlayerID),
	case Player of
		{}->
			PID ! { playerDownMountResult, ?PlayerMountOP_Result_Fail_InvalidCall};
		_->
			
			CanNotState = ( ?Actor_State_Flag_Dead ) bor ( ?Player_State_Flag_ChangingMap ),
			New_PalyerMountView = #palyerMountView{mountDataID=0, mountSpeed=0},
			etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.playerMountView, New_PalyerMountView),
			case WithdCheck of
				true->
					case mapActorStateFlag:isStateFlag( PlayerID, CanNotState ) of
						true->
							PID ! { playerDownMountResult, ?PlayerMountOP_Result_Fail_InvalidCall};%%这些状态下不更新属性
						false->
							damageCalculate:calcFinaProperty(PlayerID),
							PID ! { playerDownMountResult, ?PlayerMountOP_Result_Succ},
							%%广播下马消息
							MsgToUser = #pk_GS2U_MountDown{ actorID=PlayerID },
							mapView:broadcast(MsgToUser, Player, 0)
					end;
				_->
					damageCalculate:calcFinaProperty(PlayerID),
					PID ! { playerDownMountResult, ?PlayerMountOP_Result_Succ},
					%%广播下马消息
					MsgToUser = #pk_GS2U_MountDown{ actorID=PlayerID },
					mapView:broadcast(MsgToUser, Player, 0)
			end
	end,
	ok.

%%玩家进程，响应玩家死亡
onPlayerDead()->
	%%如果在马上，要下马
	put( "Mount_Up_ID", 0 ),
	ok.


%%坐骑喂养
on_U2GS_LevelUpRequest( #pk_U2GS_LevelUpRequest{mountDataID=MountDataID, isAuto=IsAuto}=_Msg )->
	case IsAuto =:= 0 of
		true->
			Return = doMountLevelUp( MountDataID ),
			%%坐骑是当前装备的坐骑，并且提升了等级，通知玩家更新属性
			case getEquipedMountID() =:= MountDataID andalso Return =:= ?PlayerMountOP_Result_LevelUP of
				true->
					playerMap:onPlayer_LevelEquipPet_Changed(),
					ok;
				_->ok
			end,
			
			player:send( #pk_GS2U_MountOPResult{mountDataID=MountDataID, result=Return});
		false->
			Return =doOneKeyLevelUP( MountDataID ),
			player:send( #pk_GS2U_MountOPResult{mountDataID=MountDataID, result=Return}),
			%%坐骑是当前装备的坐骑，并且提升了等级，通知玩家更新属性
			case getEquipedMountID() =:= MountDataID andalso Return =:= ?PlayerMountOP_Result_LevelUP of
				true->
					playerMap:onPlayer_LevelEquipPet_Changed(),
					ok;
				_->ok
			end
	end,
	
	case etsBaseFunc:readRecord( getPlayerMountInfoTable(), MountDataID ) of
		{}->ok;
		Mount->
			MsgToUser3 = #pk_GS2U_MountInfoUpdate{ mounts=#pk_mountInfo{
																mountDataID=MountDataID,
																level=Mount#playerMountInfo.level,
																equiped=Mount#playerMountInfo.equiped,
																progress=Mount#playerMountInfo.progress,
																benison_Value=Mount#playerMountInfo.benison_Value
															   } },
			player:send( MsgToUser3 )
	end,
	
	ok.

%%执行一键喂养
doOneKeyLevelUP( MountDataID )->
	Return = doMountLevelUp( MountDataID ),
	case Return of
		?PlayerMountOP_Result_Succ->doOneKeyLevelUP( MountDataID );
		?PlayerMountOP_Result_Fail_LevelUp_Rate->doOneKeyLevelUP( MountDataID );
		_->Return
	end.


%%执行骑乘喂养
doMountLevelUp( MountDataID )->
	try
		%%检测是否存在
		ExistMount = etsBaseFunc:readRecord( ?MODULE:getPlayerMountInfoTable(), MountDataID ),
		case ExistMount of
			{}->throw( {return, ?PlayerMountOP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		MountCfg = etsBaseFunc:readRecord( ?MODULE:getMountCfgTable(), MountDataID ),
		case MountCfg of
			{}->throw( {return, ?PlayerMountOP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		MountHanceCfg = etsBaseFunc:readRecord( ?MODULE:getMountHanceCfgTable(), ExistMount#playerMountInfo.level ),
		case MountHanceCfg of
			{}->throw( {return, ?PlayerMountOP_Result_Fail_InvalidCall} );
			_->ok
		end,
		
		CanAddProgress = MountHanceCfg#mountHanceCfg.progress - ExistMount#playerMountInfo.progress,
		%%检测是否达到最高级
		case ( ExistMount#playerMountInfo.level >= ?MaxMountLevel ) of
			true->throw( {return, ?PlayerMountOP_Result_Fail_MaxLevel} );
			false->ok
		end,

		%%检测是否物品需求
		case ( MountHanceCfg#mountHanceCfg.itemId > 0 ) andalso
			  ( MountHanceCfg#mountHanceCfg.itemnumber > 0 )of
			true->
				[CanDecItem|DecItems] = playerItems:canDecItemInBag( ?Item_Location_Bag, MountHanceCfg#mountHanceCfg.itemId, MountHanceCfg#mountHanceCfg.itemnumber, "all" ),
				case CanDecItem of
					true->ok;
					false->throw( {return, ?PlayerMountOP_Result_Fail_LevelUp_Item} )
				end;
			false->CanDecItem=false,DecItems={}
		end,

		%%检测是否需要铜币
		case MountHanceCfg#mountHanceCfg.enhanceCost > 0 of
			true->
				CanUseMoney = playerMoney:canUsePlayerBindedMoney(MountHanceCfg#mountHanceCfg.enhanceCost),
				case CanUseMoney of
					true->ok;
					false->throw( {return, ?PlayerMountOP_Result_Fail_LevelUp_Money} )
				end;
			false->CanUseMoney = false
		end,
		
		%%祝福值
		case (ExistMount#playerMountInfo.benison_Value+1) >= MountHanceCfg#mountHanceCfg.benison_Max of
			true->
				IsBenison = true,
				LevelUp = true,
				ok;
			_->
				%%概率
				%%检测是否会升级
				LevelUp = ( CanAddProgress =< 1 ),
				IsBenison = false,
				case MountHanceCfg#mountHanceCfg.enhanceRate > 0 of
					true->
						%%扣除道具和金钱
						case CanDecItem of
							true->
								playerItems:decItemInBag( DecItems, ?Destroy_Item_Reson_MountLevelUp );
							false->ok
						end,
		
						case CanUseMoney of
							true->
									ParamTuple = #token_param{changetype = ?Money_Change_MountLevelUp,param1=MountDataID},		
									playerMoney:usePlayerBindedMoney(MountHanceCfg#mountHanceCfg.enhanceCost, ?Money_Change_MountLevelUp, ParamTuple);
							false->ok
						end,
						RandValue = random:uniform( 10000 ),
						case RandValue =< MountHanceCfg#mountHanceCfg.enhanceRate of
							true->ok;
							false->
								%%强化失败，进度降为0
								etsBaseFunc:changeFiled(?MODULE:getPlayerMountInfoTable(), MountDataID, #playerMountInfo.benison_Value, ExistMount#playerMountInfo.benison_Value+1),
								etsBaseFunc:changeFiled(?MODULE:getPlayerMountInfoTable(), MountDataID, #playerMountInfo.progress, 0 ),
								throw( {return, ?PlayerMountOP_Result_Fail_LevelUp_Rate} )
						end;
					false->ok
				end
		end,

		%%检测成功，开始升级、扣物品、钱
		case LevelUp of
			true->
				PlayerName = player:getPlayerProperty( player:getCurPlayerID(), #player.name ),
				%% 是否满足全服通告条件 坐骑也没名字 ~_~
				case ExistMount#playerMountInfo.level+1 of
					?MOUNT_STRENGTHEN_15->
						Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_MOUNT_STRENGTHEN_15, [PlayerName]),
						put("WorldBrodcaseString",Str);	
					?MOUNT_STRENGTHEN_19->
						Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_MOUNT_STRENGTHEN_19, [PlayerName]),
						put("WorldBrodcaseString",Str);
					?MOUNT_STRENGTHEN_20->
						Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_MOUNT_STRENGTHEN_20, [PlayerName]),
						put("WorldBrodcaseString",Str);
					_->
						ok
				end,	
				
				case BrodcaseString = get("WorldBrodcaseString") of
					false->	ok;
					undefined->	ok;
					_->	systemMessage:sendSysMsgToAllPlayer(BrodcaseString),
						put("WorldBrodcaseString",false)
				end,

				etsBaseFunc:changeFiled(?MODULE:getPlayerMountInfoTable(), MountDataID, #playerMountInfo.progress, 0 ),
				etsBaseFunc:changeFiled(?MODULE:getPlayerMountInfoTable(), MountDataID, #playerMountInfo.benison_Value, 0 ),
				etsBaseFunc:changeFiled(?MODULE:getPlayerMountInfoTable(), MountDataID, #playerMountInfo.level, ExistMount#playerMountInfo.level+1 );
			false->
				etsBaseFunc:changeFiled(?MODULE:getPlayerMountInfoTable(), MountDataID, 
										#playerMountInfo.benison_Value, ExistMount#playerMountInfo.benison_Value+1),
				etsBaseFunc:changeFiled(?MODULE:getPlayerMountInfoTable(), MountDataID, #playerMountInfo.progress, ExistMount#playerMountInfo.progress+1 )
		end,
		
		case LevelUp of
			true->
				case IsBenison of
					true->
						throw( { return, ?PlayerMountOP_Result_BenisonLevelUP} );
					_->
						throw( { return, ?PlayerMountOP_Result_LevelUP} )
				end;
			_->ok
		end,

		?PlayerMountOP_Result_Succ
	catch
		{return, ReturnCode}->ReturnCode
	end.	

%%返回骑乘属性
getMountPropertyArray()->
 	FixArray = array:new(?property_count, {default, 0} ),
	ListArray = array:new(?property_count, {default, []} ),
	
	put("MountPropertyArray_fix",FixArray),
	put("MountPropertyArray_List",ListArray),
	
	put( "MountPropertyArray_MoveSpeed", 0 ),

	try
		EquipedMountID = getEquipedMountID(),
		case EquipedMountID =:= 0 of
			true->throw( {return} );
			_->ok
		end,
		
		EquipedMount = etsBaseFunc:readRecord(?MODULE:getPlayerMountInfoTable(), EquipedMountID),
		MountCfg = etsBaseFunc:readRecord( ?MODULE:getMountCfgTable(), EquipedMountID ),
		MountLevelCfg = etsBaseFunc:readRecord( ?MODULE:getMountLevelCfgTable(), EquipedMount#playerMountInfo.level ),
		
		case MountCfg of
			{}->throw( {return} );
			_->ok
		end,
		
		case MountLevelCfg of
			{}->throw( {return} );
			_->ok
		end,
		
		%%先将需要MountCfg和MountLevelCfg相乘计算的计算掉
		put( "getMountPropertyArray_MountCfg", MountCfg ),
		
		MyFunc1 = fun( Index )->
						  Cur_MountCfg = get( "getMountPropertyArray_MountCfg" ),
						  MountCfg_Value = element( Index, Cur_MountCfg ),
						  
						  MountLevel_Index = Index - #mountCfg.attack + #mountLevelCfg.attack,
						  MountLevel_Value = element( MountLevel_Index, MountLevelCfg ),
						  
						  Value = MountCfg_Value*MountLevel_Value div 10000,
						  New_MountCfg = setelement( Index, Cur_MountCfg, Value ),
						  put( "getMountPropertyArray_MountCfg", New_MountCfg )
				  end,
		common:for( #mountCfg.attack, #mountCfg.move_speed, MyFunc1 ),
		
		%%再将MountCfg和MountLevelCfg所有的属性值加起来
		MyFunc2 = fun( Index )->
						  case ( Index >= #mountCfg.attack ) andalso
								( Index =< #mountCfg.poison_def ) of
							  true->ok;%%attack---poison_def之间的属性是上面已经乘过的
							  false->
								  Cur_MountCfg = get( "getMountPropertyArray_MountCfg" ),
								  MountCfg_Value = element( Index, Cur_MountCfg ),
								  
								  MountLevel_Index = Index - #mountCfg.life_recover_MaxLife + #mountLevelCfg.life_recover_MaxLife,
								  MountLevel_Value = element( MountLevel_Index, MountLevelCfg ),
								  
								  Value = MountCfg_Value + MountLevel_Value,
								  New_MountCfg = setelement( Index, Cur_MountCfg, Value ),
								  put( "getMountPropertyArray_MountCfg", New_MountCfg )
						  end
				  end,
		common:for( #mountCfg.life_recover_MaxLife, #mountCfg.treat_rate_been, MyFunc2 ),
		
		%%再将Fix的数据加到FixArray
		FixPropertyRecord = {
								?life_recover_MaxLife,
								?damage_recover,
								?hit_rate_rate,
								?dodge_rate,
								?block_rate,
								?crit_rate,
								?pierce_rate,
								?attack_speed_rate,
								?tough_rate,
								?crit_damage_rate,
								?block_dec_damage,
								?coma_def_rate,
								?hold_def_rate,
								?silent_def_rate,
								?move_def_rate,
								 
								?attack,
								?defence,
								?max_life,
								?ph_def,
								?fire_def,
								?ice_def,
								?elec_def,
								?poison_def
							},
		
		Final_MountCfg = get( "getMountPropertyArray_MountCfg" ),
		
		MyFunc3 = fun( Index )->
						  Cur_Fix = get( "MountPropertyArray_fix" ),
						  
						  Pro_Index = element( Index, FixPropertyRecord ),
						  
						  MountCfgIndex = #mountCfg.life_recover_MaxLife + Index - 1,
						  MountCfg_Value = element( MountCfgIndex, Final_MountCfg ),
						  
						  New_Fix = array:set( Pro_Index, MountCfg_Value, Cur_Fix ),
						  
						  put( "MountPropertyArray_fix", New_Fix )
				  end,
		common:for( 1, size(FixPropertyRecord), MyFunc3 ),
		
		%%再将Percent的数据加到ListArray
		ListPropertyRecord = {
								?move_speed,
								?phy_attack_rate,
								?fire_attack_rate,
								?ice_attack_rate,
								?elec_attack_rate,
								?poison_attack_rate,
								?phy_def_rate,
								?fire_def_rate,
								?ice_def_rate,
								?elec_def_rate,
								?poison_def_rate,
								?treat_rate,
								?treat_rate_been
							},
		
		MyFunc4 = fun( Index )->
						  Cur_List = get( "MountPropertyArray_List" ),
						  
						  Pro_Index = element( Index, ListPropertyRecord ),
						  
						  MountCfgIndex = #mountCfg.move_speed + Index - 1,
						  MountCfg_Value = element( MountCfgIndex, Final_MountCfg ),
						  
						  New_List = array:set( Pro_Index, [MountCfg_Value], Cur_List ),
						  
						  put( "MountPropertyArray_List", New_List )
				  end,
		common:for( 1, size(ListPropertyRecord), MyFunc4 ),
		
		%%move_speed要单独处理，装备的时候不加，骑上去才加，所以这里先清0，保存
		MountPropertyArray_List = get( "MountPropertyArray_List" ),
		[MoveSpeed] = array:get(?move_speed , MountPropertyArray_List),
		New_MountPropertyArray_List = array:set( ?move_speed, [] , MountPropertyArray_List ),
		
		put( "MountPropertyArray_MoveSpeed", MoveSpeed ),
		put( "MountPropertyArray_List", New_MountPropertyArray_List ),
		
		throw( {return} )
	catch
		_->{ get( "MountPropertyArray_fix" ), get( "MountPropertyArray_List" ) }
	end.


onChangeMap(MapDataID)->
	case etsBaseFunc:readRecord(main:getGlobalMapCfgTable(), MapDataID) of
		{}->ok;
		MapCfg->
			%%战场允许上马
			case MapCfg#mapCfg.type =:= ?Map_Type_Normal_Copy  of
				true->	%%如果是副本地图，进行下马操作
					mount:on_U2GS_MountDownRequest();
				_->ok
			end
	end,
	ok.


