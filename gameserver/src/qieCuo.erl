%% Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(qieCuo).

-include("db.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("variant.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("textDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 

-define( QIE_CUO_FAIL_LEVEL_MY, -1 ).%%切磋邀请失败，己方等级不够
-define( QIE_CUO_FAIL_LEVEL_TARGET, -2 ).%%切磋邀请失败，对方等级不够
-define( QIE_CUO_FAIL_MAP, -3 ).%%切磋邀请失败，地图限制
-define( QIE_CUO_FAIL_FIGHTSTATE, -4 ).%%切磋邀请失败，不能在战斗状态
-define( QIE_CUO_FAIL_INVALID_CALL, -5 ).%%切磋邀请失败，无效的操作
-define( QIE_CUO_FAIL_DISTANCE, -6 ).%%切磋邀请失败，距离太远
-define( QIE_CUO_FAIL_REFUSE, -7 ).%%切磋邀请失败，对方拒绝
-define( QIE_CUO_FAIL_IN_CONVOY, -8 ).%%切磋邀请失败，正在护送
-define( QIE_CUO_FAIL_DES_IN_CONVOY, -9 ).%%切磋邀请失败，对方在护送中

-define( QIE_CUO_DISTANCE, ?Map_Pixel_Title_Width*30 ).%%切磋检测距离
-define( QIE_CUO_DISTANCE_SQ, ?QIE_CUO_DISTANCE*?QIE_CUO_DISTANCE ).%%切磋检测距离
-define( QIE_CUO_TIME, 5*60*1000 ).	%%切磋时间

-define( SHALU_OPENED, 1 ).%%杀戮模式打开
-define( SHALU_CLOSED, 2 ).%%杀戮模式关闭
-define( SHALU_OP_FAIL_INVALID_CALL, -1 ).%%杀戮模式开关操作无效
-define( SHALU_OP_FAIL_CDING, -2 ).%%杀戮模式关闭冷却中
-define( SHALU_OP_UPDATE_VALUE, -3 ).%%杀戮值更新



%%切磋邀请
on_U2GS_QieCuoInvite( PlayerID, Msg )->
	try
		Player = map:getPlayer(PlayerID),
		case Player of
			{}->throw( {return, ?QIE_CUO_FAIL_INVALID_CALL} );
			_->ok
		end,
		
		Target = map:getPlayer( Msg#pk_U2GS_QieCuoInvite.nActorID ),
		case Target of
			{}->throw( {return, ?QIE_CUO_FAIL_INVALID_CALL} );
			_->ok
		end,
		
		ReturnCode = canQieCuo( Player, Target ),
		case ReturnCode < 0 of
			true->throw( {return, ReturnCode} );
			false->ok
		end,

		ToUserMsg = #pk_GS2U_QieCuoInviteQuery{ nActorID=PlayerID, strName=Player#mapPlayer.name },
		player:sendToPlayer( Msg#pk_U2GS_QieCuoInvite.nActorID, ToUserMsg ),
		ok
	catch
		{ return, ReturnCode2 }->
			ToUserMsg2 = #pk_GS2U_QieCuoInviteResult{ nActorID=Msg#pk_U2GS_QieCuoInvite.nActorID,
														result=ReturnCode2},
			player:sendToPlayer(PlayerID, ToUserMsg2)
	end.

%%返回玩家是否能与某玩家切磋
canQieCuo( Player, Target )->
	try
		%%检测是否正在切磋
		case Player#mapPlayer.qieCuoPlayerID /= 0 of
			true->throw( {return, ?QIE_CUO_FAIL_INVALID_CALL} );
			_->ok	
		end,
		case Target#mapPlayer.qieCuoPlayerID /= 0 of
			true->throw( {return, ?QIE_CUO_FAIL_INVALID_CALL} );
			_->ok	
		end,
		
		%%检测护送状态
		case mapActorStateFlag:isStateFlag(Player#mapPlayer.id, ?Player_State_Flag_Convoy) of
			true->throw( {return, ?QIE_CUO_FAIL_IN_CONVOY} );
			false->ok
		end,
		%%检测护送状态
		case mapActorStateFlag:isStateFlag(Target#mapPlayer.id, ?Player_State_Flag_Convoy) of
			true->throw( {return, ?QIE_CUO_FAIL_DES_IN_CONVOY} );
			false->ok
		end,		

		%%检测死亡、切地图状态
		NotQieCuoState = ?Actor_State_Flag_Dead bor ?Player_State_Flag_ChangingMap,
		case mapActorStateFlag:isStateFlag(Player#mapPlayer.id, NotQieCuoState) of
			true->throw( {return, ?QIE_CUO_FAIL_INVALID_CALL} );
			_->ok	
		end,
		case mapActorStateFlag:isStateFlag(Target#mapPlayer.id, NotQieCuoState) of
			true->throw( {return, ?QIE_CUO_FAIL_INVALID_CALL} );
			_->ok	
		end,
		
		%%检测战斗状态
		case mapActorStateFlag:isStateFlag(Player#mapPlayer.id, ?Actor_State_Flag_Fighting) of
			true->throw( {return, ?QIE_CUO_FAIL_FIGHTSTATE} );
			_->ok	
		end,
		case mapActorStateFlag:isStateFlag(Target#mapPlayer.id, ?Actor_State_Flag_Fighting) of
			true->throw( {return, ?QIE_CUO_FAIL_FIGHTSTATE} );
			_->ok	
		end,
		
		%%检测距离
		DistSQ = map:getObjectDistanceSQ( Player, Target ),
		case DistSQ > ?QIE_CUO_DISTANCE_SQ of
			true->throw( {return, ?QIE_CUO_FAIL_DISTANCE} );
			_->ok	
		end,
		
		%%检测地图
		MapCfg = map:getMapCfg(),
		case MapCfg#mapCfg.pkFlag_QieCuo =:= 0 of
			true->throw( {return, ?QIE_CUO_FAIL_MAP} );
			_->ok	
		end,

		ok
	catch
		{ return, ReturnCode }->ReturnCode
	end.

%%切磋邀请回复
on_U2GS_QieCuoInviteAck( PlayerID, Msg )->
	try
		Player = map:getPlayer( Msg#pk_U2GS_QieCuoInviteAck.nActorID ),
		case Player of
			{}->throw( {return, ?QIE_CUO_FAIL_INVALID_CALL} );
			_->ok
		end,
		
		Target = map:getPlayer(PlayerID),
		case Target of
			{}->throw( {return, ?QIE_CUO_FAIL_INVALID_CALL} );
			_->ok
		end,
		
		ReturnCode = canQieCuo( Player, Target ),
		case ReturnCode < 0 of
			true->throw( {return, ReturnCode} );
			false->ok
		end,
		
		case Msg#pk_U2GS_QieCuoInviteAck.agree =:= 0 of
			true->throw( {return, ?QIE_CUO_FAIL_REFUSE} );
			false->ok
		end,
		
		beginQieCuo( Player, Target ),

		ok
	catch
		{ return, ReturnCode2 }->
			ToUserMsg2 = #pk_GS2U_QieCuoInviteResult{ nActorID=PlayerID,
														result=ReturnCode2},
			player:sendToPlayer(Msg#pk_U2GS_QieCuoInviteAck.nActorID, ToUserMsg2)
	end.

%%开始切磋
beginQieCuo( Player, Target )->
	try
		%%创建旗帜
		MapSpawn = #mapSpawn{id=0, mapId=map:getMapDataID(),type=?Object_Type_Normal,typeId=?Global_Object_QieCuo,
							 x=playerMap:getPlayerPosX(Player),
							 y=playerMap:getPlayerPosY(Player),
							 param=0,
							 isExist=0 },
		ObjectActor = objectActor:createObject( MapSpawn ),
		map:enterMapObject(ObjectActor),
		
		%%创建切磋玩家记录
		QieCuoPlayers1 = #qieCuoPlayers{ playerID=Player#mapPlayer.id, myPlayer=Player, target=Target, objectID=ObjectActor#mapObjectActor.id  },
		QieCuoPlayers2 = #qieCuoPlayers{ playerID=Target#mapPlayer.id, myPlayer=Target, target=Player, objectID=ObjectActor#mapObjectActor.id  },
		etsBaseFunc:insertRecord( map:getQieCuoPlayersTable(), QieCuoPlayers1 ),
		etsBaseFunc:insertRecord( map:getQieCuoPlayersTable(), QieCuoPlayers2 ),
		%%修改玩家切磋目标
		etsBaseFunc:changeFiled( map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.qieCuoPlayerID, Target#mapPlayer.id ),
		etsBaseFunc:changeFiled( map:getMapPlayerTable(), Target#mapPlayer.id, #mapPlayer.qieCuoPlayerID, Player#mapPlayer.id ),	
		%%通知玩家切磋目标
		GS2U_QieCuoInviteResult = #pk_GS2U_QieCuoInviteResult{ nActorID=Target#mapPlayer.id, result=0 },
		player:sendToPlayer( Player#mapPlayer.id, GS2U_QieCuoInviteResult ),
		
		GS2U_QieCuoInviteResult_Target = #pk_GS2U_QieCuoInviteResult{ nActorID=Player#mapPlayer.id, result=0 },
		player:sendToPlayer( Target#mapPlayer.id, GS2U_QieCuoInviteResult_Target ),
		%%注册计时器给Object
		Parama = { Player, Target, common:timestamp() },
		objectEvent:registerTimerEvent(ObjectActor, 1000, true, ?MODULE, on_QieCuoObject_Time, Parama ),
		
		?DEBUG_OUT( "beginQieCuo Player[~p] Target[~p] Object[~p]", [Player#mapPlayer.name, Target#mapPlayer.name, ObjectActor#mapObjectActor.id] ),
		
		ok
	catch
		_->ok
	end.

%%切磋结束
qieCuo_Fail( Player, IsTimeOut )->
	try
		QieCuoPlayers = etsBaseFunc:readRecord( map:getQieCuoPlayersTable(), Player#mapPlayer.id ),
		case QieCuoPlayers of
			{}->ok;
			_->
				%%清仇恨
				objectHatred:clearHatred( Player#mapPlayer.id ),
				%%血量重置
				PlayerLife = QieCuoPlayers#qieCuoPlayers.myPlayer#mapPlayer.life,
				charDefine:changeSetLife(Player, PlayerLife, true),
				
				etsBaseFunc:changeFiled( map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.qieCuoPlayerID, 0 ),

				%%删除Object
				map:despellObject( QieCuoPlayers#qieCuoPlayers.objectID, 0),
				
				%%删除切磋表记录
				etsBaseFunc:deleteRecord( map:getQieCuoPlayersTable(), Player#mapPlayer.id )
		end,

		%%对方
		QieCuoPlayers_Target = etsBaseFunc:readRecord( map:getQieCuoPlayersTable(), Player#mapPlayer.qieCuoPlayerID ),
		case QieCuoPlayers_Target of
			{}->ok;
			_->
				%%删除切磋表记录
				etsBaseFunc:deleteRecord( map:getQieCuoPlayersTable(), Player#mapPlayer.qieCuoPlayerID ),
				
				Target = map:getPlayer( Player#mapPlayer.qieCuoPlayerID ),
				case Target of
					{}->ok;
					_->
						%%清仇恨
						objectHatred:clearHatred( Target#mapPlayer.id ),
						%%血量重置
						PlayerLife_Target = QieCuoPlayers_Target#qieCuoPlayers.myPlayer#mapPlayer.life,
						charDefine:changeSetLife(Target, PlayerLife_Target, true),
						
						etsBaseFunc:changeFiled( map:getMapPlayerTable(), Target#mapPlayer.id, #mapPlayer.qieCuoPlayerID, 0 ),
						
						%%广播结果
						case IsTimeOut of
							true->Result=1;
							false->Result=0
						end,
						GS2U_QieCuoResult = #pk_GS2U_QieCuoResult{ nWinner_ActorID=Target#mapPlayer.id,
																   strWinner_Name=Target#mapPlayer.name,
																   nLoser_ActorID=Player#mapPlayer.id, 
																   strLoser_Name=Player#mapPlayer.name,
																   reson=Result },
						mapView:broadcast(GS2U_QieCuoResult, Target, 0),
						
						?DEBUG_OUT( "qieCuo_Fail IsTimeOut[~p] winner[~p] loser[~p]", [IsTimeOut, Target#mapPlayer.name, Player#mapPlayer.name] )
				end
		end,
		
		etsBaseFunc:changeFiled( map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.qieCuoPlayerID, 0 ),
		
		ok
	catch
		_->ok
	end.

%%切磋Object计时器回调
on_QieCuoObject_Time( ObjectOld, ObjectTimer )->
	try
		Object = map:getObjectActor(ObjectOld#mapObjectActor.id),
		case Object of
			{}->throw( {return, stopTimer} );
			_->ok
		end,

		{ Player_Old, Target_Old, BeginTime } = ObjectTimer#objectTimer.parama,
		Player = map:getPlayer( Player_Old#mapPlayer.id ),
		case Player of
			{}->throw( {return, stopTimer} );
			_->ok
		end,
		case Player#mapPlayer.qieCuoPlayerID /= Target_Old#mapPlayer.id of
			true->throw( {return, stopTimer} );
			_->ok
		end,

		Target = map:getPlayer( Target_Old#mapPlayer.id ),
		case Target of
			{}->throw( {return, stopTimer} );
			_->ok
		end,
		case Target#mapPlayer.qieCuoPlayerID /= Player#mapPlayer.id of
			true->throw( {return, stopTimer} );
			_->ok
		end,
		
		Now = common:timestamp(),
		case Now - BeginTime >= ?QIE_CUO_TIME of
			true->
				qieCuo_Fail( Player, true ),
				throw( {return, stopTimer} );
			false->ok
		end,
		
		Player_DistSQ = map:getObjectDistanceSQ( Object, Player ),
		case Player_DistSQ >= ?QIE_CUO_DISTANCE_SQ of
			true->
				qieCuo_Fail( Player, false ),
				throw( {return, stopTimer} );
			false->ok
		end,
		
		Target_DistSQ = map:getObjectDistanceSQ( Object, Target ),
		case Target_DistSQ >= ?QIE_CUO_DISTANCE_SQ of
			true->
				qieCuo_Fail( Target, false ),
				throw( {return, stopTimer} );
			false->ok
		end,
		ok
	catch
		{ return, ReturnCode }->ReturnCode
	end.

%%关闭杀戮
close_PK(PlayerID) ->
	try
		Player = map:getPlayer(PlayerID),
		case Player of
			{}->throw(-1);
			_->ok
		end,
		changePKKillTime(Player, 0),
		mapActorStateFlag:removeStateFlag(PlayerID, ?Player_State_Flag_PK_Kill),
		ToUserMsg = #pk_GS2U_PK_KillOpenResult{result=?SHALU_CLOSED, pK_Kill_RemainTime=0, pk_Kill_Value=Player#mapPlayer.pK_Kill_Value},
		player:sendToPlayer(PlayerID, ToUserMsg)			
	catch
		_-> ?DEBUG_OUT("close_PK Failed PalyerID error, not find player, PlayerID: ~p", [PlayerID])
	end.
	
%%杀戮模式开启请求
on_U2GS_PK_KillOpenRequest( PlayerID, _Msg )->
	try
		Player = map:getPlayer(PlayerID),
		case Player of
			{}->throw( {return, ?SHALU_OP_FAIL_INVALID_CALL, 0, 0} );
			_->ok
		end,

		Pk_KillTime = globalSetup:getGlobalSetupValue( #globalSetup.pk_KillTime ),

		Now = common:timestamp(),
		case ( Player#mapPlayer.pK_Kill_OpenTime /= 0 ) andalso
			 ( Now < Player#mapPlayer.pK_Kill_OpenTime + Pk_KillTime )of
			true->throw( {return, ?SHALU_OP_FAIL_CDING, Pk_KillTime - ( Now - Player#mapPlayer.pK_Kill_OpenTime ), Player#mapPlayer.pK_Kill_Value} );
			false->ok
		end,
		
		case mapActorStateFlag:isStateFlag(PlayerID, ?Player_State_Flag_PK_Kill ) of
			true->%%本来是开启状态，那么是要关闭
				changePKKillTime( Player, 0 ),
				mapActorStateFlag:removeStateFlag(PlayerID, ?Player_State_Flag_PK_Kill),			
				throw( {return, ?SHALU_CLOSED, 0, Player#mapPlayer.pK_Kill_Value} );
			false->%%本来是关闭的，要开启
				changePKKillTime( Player, Now ),
				mapActorStateFlag:addStateFlag(PlayerID, ?Player_State_Flag_PK_Kill),			
				throw( {return, ?SHALU_OPENED, Pk_KillTime, Player#mapPlayer.pK_Kill_Value} )
		end,
		
		ok
	catch
		{return, ReturnCode, PK_Kill_RemainTime, PK_Kill_Value}->
			ToUserMsg = #pk_GS2U_PK_KillOpenResult{result=ReturnCode, pK_Kill_RemainTime=PK_Kill_RemainTime, pk_Kill_Value=PK_Kill_Value},
			player:sendToPlayer(PlayerID, ToUserMsg)
	end.

%%玩家进地图检测杀戮模式
onPlayerEnterMap_ForPKKill( Player )->
	PlayerID = Player#mapPlayer.id,
	Pk_KillTime = globalSetup:getGlobalSetupValue( #globalSetup.pk_KillTime ),
	Now = common:timestamp(),

	CurKillPlayerKillValue = Player#mapPlayer.pK_Kill_Value,
	KillPalyerPoint_Red = globalSetup:getGlobalSetupValue( #globalSetup.killPlayerPoint_Red ),
	case CurKillPlayerKillValue >= KillPalyerPoint_Red of
		true ->
			case mapActorStateFlag:isStateFlag(PlayerID, ?Player_State_Flag_PK_Kill_Value ) of
				false -> 
					mapActorStateFlag:addStateFlag(PlayerID, ?Player_State_Flag_PK_Kill_Value);
				true -> ok
			end;			
		false ->
			case mapActorStateFlag:isStateFlag(PlayerID, ?Player_State_Flag_PK_Kill_Value ) of
				true ->
					Min_KillPlayerPoint = globalSetup:getGlobalSetupValue( #globalSetup.min_KillPlayerPoint ),
					case CurKillPlayerKillValue < Min_KillPlayerPoint of
						true ->
							mapActorStateFlag:removeStateFlag(PlayerID, ?Player_State_Flag_PK_Kill_Value);
						false -> ok
					end;
				false -> ok
			end
	end,			

	case (Player#mapPlayer.pK_Kill_OpenTime /= 0) andalso
		 (Now < Player#mapPlayer.pK_Kill_OpenTime + Pk_KillTime) of
		true->
			case mapActorStateFlag:isStateFlag(PlayerID, ?Player_State_Flag_PK_Kill ) of
				true->ok;
				false->
					mapActorStateFlag:addStateFlag(PlayerID, ?Player_State_Flag_PK_Kill),
					ToUserMsg = #pk_GS2U_PK_KillOpenResult{result=?SHALU_OPENED, 
														   pK_Kill_RemainTime=Pk_KillTime - ( common:timestamp() - Player#mapPlayer.pK_Kill_OpenTime ),
														   pk_Kill_Value=Player#mapPlayer.pK_Kill_Value
														  },
					player:sendToPlayer(PlayerID, ToUserMsg)
			end;
		false->
			case mapActorStateFlag:isStateFlag(PlayerID, ?Player_State_Flag_PK_Kill ) of
				true->
					changePKKillTime( Player, 0 ),
					
					mapActorStateFlag:removeStateFlag(PlayerID, ?Player_State_Flag_PK_Kill),

					ToUserMsg = #pk_GS2U_PK_KillOpenResult{result=?SHALU_CLOSED, pK_Kill_RemainTime=0, pk_Kill_Value=Player#mapPlayer.pK_Kill_Value},
					player:sendToPlayer(PlayerID, ToUserMsg);
				false->ok
			end
	end,

	case (Player#mapPlayer.pk_Kill_Punish =/= 0) andalso ( Player#mapPlayer.pkPunishing =:= 0 ) of
		true->%%玩家变量设置要惩罚，但#mapPlayer.pk_Kill_Punishing还没有设置，应该是在玩家上线时初始化
			doPKKillPunish( Player ),
			ok;
		false->ok
	end,	

	ok.


changePKKillTime( Player, PK_Kill_OpenTime )->
	case PK_Kill_OpenTime =:= 0 of
		true->PK_Kill_RemainTime = 0;
		false->PK_Kill_RemainTime = globalSetup:getGlobalSetupValue( #globalSetup.pk_KillTime ) - ( common:timestamp() - PK_Kill_OpenTime )
	end,

	ToUserMsg = #pk_GS2U_PK_KillOpenResult{result=?SHALU_OP_FAIL_CDING, 
										   pK_Kill_RemainTime=PK_Kill_RemainTime,
										   pk_Kill_Value=Player#mapPlayer.pK_Kill_Value },
	player:sendToPlayer(Player#mapPlayer.id, ToUserMsg),

	etsBaseFunc:changeFiled( map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.pK_Kill_OpenTime, PK_Kill_OpenTime ),
	Player#mapPlayer.pid ! { playerMapMsg_changePKKillTime, PK_Kill_OpenTime }.

addPKKillValue( Player, Value )->
	KillPlayerPoint_Red = globalSetup:getGlobalSetupValue( #globalSetup.killPlayerPoint_Red ),
	Max_KillPlayerPoint = globalSetup:getGlobalSetupValue( #globalSetup.max_KillPlayerPoint ),
	
	CurPK_Kill_Value = Player#mapPlayer.pK_Kill_Value,
	NewValue = Value + CurPK_Kill_Value,
	case NewValue < 0 of
		true->NewValue2 = 0;
		false->NewValue2 = NewValue
	end,
	
	case NewValue2 >= Max_KillPlayerPoint of
		true->NewValue3 = Max_KillPlayerPoint;
		false->NewValue3 = NewValue2
	end,

	case ( NewValue3 >= KillPlayerPoint_Red ) andalso ( Player#mapPlayer.pk_Kill_Punish =:= 0 ) of
		true->%%值超过了红名，但还没惩罚，惩罚
			doPKKillPunish( Player ),
			ok;
		false->ok
	end,
	
	ToUserMsg = #pk_GS2U_PK_KillOpenResult{result=?SHALU_OP_UPDATE_VALUE, 
										   pK_Kill_RemainTime=0,
										   pk_Kill_Value=NewValue3 },
	player:sendToPlayer(Player#mapPlayer.id, ToUserMsg),
	
	etsBaseFunc:changeFiled( map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.pK_Kill_Value, NewValue3 ),
	Player#mapPlayer.pid ! { playerMapMsg_changePKKillValue, NewValue3 }.

%%杀戮惩罚
doPKKillPunish( Player )->
	etsBaseFunc:changeFiled( map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.pk_Kill_Punish, 1),
	etsBaseFunc:changeFiled( map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.pkPunishing, 1),
	
	AddBuffCfg = etsBaseFunc:readRecord( main:getGlobalBuffCfgTable(), 38 ),
	case AddBuffCfg of
		{}->ok;
		_->
			?DEBUG_OUT( "doPKKillPunish player[~p] pk_Kill_Value[~p]", [Player#mapPlayer.id, Player#mapPlayer.pK_Kill_Value] ),
			
			mapActorStateFlag:addStateFlag(Player#mapPlayer.id, ?Player_State_Flag_PK_Kill_Value),
			buff:addBuffer(Player#mapPlayer.id, AddBuffCfg, Player#mapPlayer.id, 0, 0, 0),
			PlayerName = Player#mapPlayer.name,
			MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), map:getMapDataID() ),
			Str = io_lib:format(?TEXT_SYSTEM_SHALU, [PlayerName, MapCfg#mapCfg.mapName]),
			systemMessage:sendSysMsgToAllPlayer(Str),
			Player#mapPlayer.pid ! { playerMapMsg_changePKKillPunish, 1}
	end,
	ok.

%%取消杀戮惩罚
undoPKKillPunish( Player )->
	etsBaseFunc:changeFiled( map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.pk_Kill_Punish, 0),
	etsBaseFunc:changeFiled( map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.pkPunishing, 0),
	
	?DEBUG_OUT( "undoPKKillPunish player[~p] pk_Kill_Value[~p]", [Player#mapPlayer.id, Player#mapPlayer.pK_Kill_Value] ),
	
	buff:removeBuff(Player#mapPlayer.id, 38),
	mapActorStateFlag:removeStateFlag(Player#mapPlayer.id, ?Player_State_Flag_PK_Kill_Value),
	Player#mapPlayer.pid ! { playerMapMsg_changePKKillPunish, 0},
	
	ok.
	
%%定时检测本地图上玩家杀戮惩罚
onMapTimerCheckPKKillPunishing()->
	erlang:send_after( 60*1000,self(), {timer_onMapTimerCheckPKKillPunishing} ),
	Rule = ets:fun2ms(fun(#mapPlayer{_ = '_', pK_Kill_Value=PK_Kill_Value} = Record) 
						   when(PK_Kill_Value > 0) -> Record end),
 	MapPlayerList = ets:select(map:getMapPlayerTable(), Rule),
	
	Min_KillPlayerPoint = globalSetup:getGlobalSetupValue( #globalSetup.min_KillPlayerPoint ),
	OnlineDec_KillPlayerPoint = globalSetup:getGlobalSetupValue( #globalSetup.onlineDec_KillPlayerPoint ),
	
	MyFunc = fun( Record )->
					 CurValue = Record#mapPlayer.pK_Kill_Value,
					 NewValue = CurValue - OnlineDec_KillPlayerPoint,
					 case NewValue < 0 of
						 true->NewValue2 = 0;
						 false->NewValue2 = NewValue
					 end,
	
					 Player = setelement( #mapPlayer.pK_Kill_Value, Record, NewValue2 ),
					 etsBaseFunc:changeFiled( map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.pK_Kill_Value, NewValue2 ),
					 Player#mapPlayer.pid ! { playerMapMsg_changePKKillValue, NewValue2 },
					 case NewValue2 < Min_KillPlayerPoint of
						 true->%%已经低于惩罚最低值，取消惩罚
							undoPKKillPunish( Player ),
							 ok;
						 false->ok
					 end,
					 ToUserMsg = #pk_GS2U_PK_KillOpenResult{result=?SHALU_OP_UPDATE_VALUE, 
														   pK_Kill_RemainTime=0,
														   pk_Kill_Value=NewValue2 },
					 player:sendToPlayer(Player#mapPlayer.id, ToUserMsg),					 
					 
					 ok
			 end,
	lists:foreach( MyFunc, MapPlayerList),
	
	ok.



