-module(active_battle).

%% add to support gen_server
-behaviour(gen_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-compile(export_all). 

-include("active_battle.hrl").
-include("hdlt_logger.hrl").
-include("active.hrl").
-include("textDefine.hrl").
-include("playerDefine.hrl").
-include("db.hrl").
-include("variant.hrl").
-include("pc_player.hrl").
-include("mapDefine.hrl").

start_link()->
 gen_server:start_link( {local,battleActivePID},?MODULE, [], [ {timeout,600000}] ).

init([]) ->
	initParam(),
	setBattleActiveProcessing(false),%%战斗活动是否正在进行
	initCampusList(),
	initBattleTable(),
	addTicker(),
	initMapOwerID(),
{ok, {}}.

handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.



terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

handle_info(Info, StateData)->			
	put("active_battle", true),
	try
	case Info of
		{quit}->
			?DEBUG_OUT( "active_battle Recieve quit" ),
			put( "active_battle", false );
		{enrollCampusBattle,PlayerID,Campus}->
			onEnrollBattleActive(PlayerID,Campus),
			ok;
		{leaveCampusBattle,PlayerID,Campus}->
			onLeaveBattleActive(PlayerID,Campus),
			ok;
		{msg_leaveBattleScene,PlayerID,OwerPlayerID,Campus}->
			%%来自地图进程的玩家离开消息不处理
			%%onleaveBattleScene(PlayerID,OwerPlayerID,Campus),
			ok;
		{msg_playerleaveBattle,PlayerID,Campus}->
			%%来自玩家，也不处理。是把玩家从地图弄出去
			%%onleaveBattleScene(PlayerID,getMapOwerIDByPlayerID(PlayerID),Campus),
			ok;
		{oneBattleEnd,MapPid,OwerPlayerID}->
			onBattleEnd(MapPid,OwerPlayerID),
			ok;
		{oneBattleNoPlayerClose,MapPid,OwerPlayerID}->
			onBattleNoPlayerClose(MapPid,OwerPlayerID),
			ok;
		{playerEnterBattleSceneFail,OwerPlayerID,Campus}->
			%%进入场景失败不处理，处理成缺人
			on_insertPlayerToFailList(OwerPlayerID,Campus),
			ok;
		{msg_requestEnrollInfo,PlayerID}->
			on_sendEnrollInfo(PlayerID),
			ok;
		{tellPlayerOnline,PlayerID,Campus}->
			on_playerOnline(PlayerID,Campus),
			ok;
		{forceOpenBattle}->
			onForceOpenBattle();
		{msg_requestEnterBattleMap,PlayerID,Campus}->
			on_SureEnterMap(PlayerID,Campus);	
		{active_battleTick}->
			handle_Tick(),
			ok;
		_->
			?LOG_OUT( "active_battle receive unkown" )
	end,
	
	case get("active_battle") of
		true->{noreply, StateData};
		false->{stop, normal, StateData}
	end
	
	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[?MODULE,_Why, erlang:get_stacktrace()] ),	

			{noreply, StateData}
	end.

initParam()->
	XianzonglinCfg=ets:lookup('globleBattleXianzonglinCfgTable',1 ),
	case XianzonglinCfg of
		[]->
			?DEBUG_OUT( "battle config error"),
			ok;
		[First|_]->
			put("win_honor",First#battleXianzonglinCfg.win_honor),
			put("lose_honor",First#battleXianzonglinCfg.lose_honor),
			put("normal_kill",First#battleXianzonglinCfg.normal_kill),
			put("kill_10",First#battleXianzonglinCfg.kill_10),
			put("kill_50",First#battleXianzonglinCfg.kill_50),
			put("kill_100",First#battleXianzonglinCfg.kill_100),
			put("time_each_battle",First#battleXianzonglinCfg.time_each_battle),
			put("win_point",First#battleXianzonglinCfg.win_point),
			put("flag_10s",First#battleXianzonglinCfg.flag_10s),
			put("boss_point",First#battleXianzonglinCfg.boss_point),
			%%put("min_join_level",First#battleXianzonglinCfg.min_join_level),
			put("norma_Open_Number",First#battleXianzonglinCfg.norma_Open_Number),
			put("min_open_Num",First#battleXianzonglinCfg.min_open_Num),
			put("reborn_delay",First#battleXianzonglinCfg.reborn_delay),
			put("waiting_time",First#battleXianzonglinCfg.waiting_time),
			put("fewer_Open_Minute",First#battleXianzonglinCfg.fewer_Open_Minute),
			?DEBUG_OUT( "battle config success"),
			ok
	end,
	ok.

getWinHonor()->
	get("win_honor").

getLoseHonor()->
	get("lose_honor").


getBattleTimeInfo()->
	?BattleJoinTimeInfo.

getBattleTotalScore()->
	get("win_point").

getJoinTimePerDay()->%%次数限制最开始说有后来没了，要玩家一天能刷这么多次，我也服了他了。
	_result=9999.

getMinJoinLevel()->
	%%get("min_join_level").
	_result=41.

getPlayerNumPerBattle()->
	get("norma_Open_Number").

getMinOpenBattlePlayerNum()->
	get("min_open_Num").

getBossKillScore()->
	get("boss_point").

getResourceIncreaseScore()->
	get("flag_10s").

getResIncreaseScoreInterval()->
	_result=100.

getScoreOfKillingOnePlayer()->
	_result=0.

getContinusKillHonor(ContinusKillNum)->
	case ContinusKillNum<10 of
		true->
			Result=get("normal_kill");
		false->
			case ContinusKillNum<50 of
				true->
					Result=get("kill_10");
				false->
					case ContinusKillNum<100 of
						true->
							Result=get("kill_50");
						false->
							Result=get("kill_100")
					end
			end
	end,
	Result.

getBattleMapDataID()->
	_result=?BattleSceneID.

getBattleReliveDelay()->
	get("reborn_delay").

getBattleWaitingInterval()->
	get("waiting_time").

getForceBattleInterval()->
	_result=get("fewer_Open_Minute")*60.

getBattleLastInterval()->
	get("time_each_battle").

%%当能参与战场的人数比这个值少，不参与战场
getMinPlayerNumCanJoinBattle()->
	_result=10.

getBirthPositionByCampus(Campus)->
	case Campus=:=?CAMP_TIANJI of
		true->
			Result=#posInfo{x=169,y=2565};
		false->
			Result=#posInfo{x=3774,y=451}
	end,
	Result.

getWaitingPositionByCampus(Campus)->
	case Campus=:=?CAMP_TIANJI of
		true->
			Result=#posInfo{x=169,y=2565};
		false->
			Result=#posInfo{x=3774,y=451}
	end,
	Result.

getBossIDByCampus(Campus)->
	case Campus=:=?CAMP_TIANJI of
		true->
			Result=310;
		false->
			case Campus=:=?CAMP_XUANZONG of
				true->
					Result=320;
				false->
					Result=286
			end
	end,
	Result.

getResourceIDByCampus(Campus)->
	case Campus=:=?CAMP_TIANJI of
		true->
			Result=580;
		false->
			case Campus=:=?CAMP_XUANZONG of
				true->
					Result=579;
				false->
					Result=578
			end
	end,
	Result.

getResourcePos()->
	_Result=[#posInfo{x=500,y=200},#posInfo{x=530,y=230},#posInfo{x=560,y=260}].


isBattleActiveProcessing()->%%战斗活动是否正在进行
	_result=get("BattleActiveProcessing").

setBattleActiveProcessing(NewStatus)->
	put("BattleActiveProcessing",NewStatus).

initCampusList()->
	put("xuanzongEnrollList",ets:new(xuanzongEnrollList, [private, { keypos, #playerEnroll.playerID }] )),
	put("tianjiEnrollList",ets:new(tianjiEnrollList, [private, { keypos, #playerEnroll.playerID }] )),
	ok.

actionBeforeActive()->
	ets:delete_all_objects(get("xuanzongEnrollList")),
	ets:delete_all_objects(get("tianjiEnrollList")),
	ets:delete_all_objects(get("lackPlayerTable")),
	ets:delete_all_objects(get("playerbattleTable")),
	put("NextBattleOpenTime",0),
	setBattleActiveProcessing(false),
	ok.

actionAfterActive()->
	
	ok.

%%初始化战斗场景缺人信息以及进入战场情况
initBattleTable()->
	put("lackPlayerTable",ets:new(battleLackPlayerTable, [private, { keypos, #battleLackPlayer.sceneowerActorID }] )),
	put("playerbattleTable",ets:new(playerbattleTable, [private, { keypos, #playerbattleInfo.playerID }] )),
	put("NextBattleOpenTime",0),
	ok.

insertToPlayerBattle(PlayerID,MapOwerID)->
	Record = etsBaseFunc:readRecord( get("playerbattleTable"), PlayerID ),
	case Record of 
		{}->
			ets:insert(get("playerbattleTable"), #playerbattleInfo{playerID=PlayerID,mapOwerID=MapOwerID});
		_->
			ets:update_element(get("playerbattleTable"), PlayerID, {#playerbattleInfo.mapOwerID,MapOwerID})
	end,
	ok.

removePlayerFromeBattleTable(PlayerID)->
	case etsBaseFunc:readRecord( get("playerbattleTable"), PlayerID ) of
		{}->
			ok;
		_->
			ets:delete(get("playerbattleTable"),PlayerID)
	end,
	ok.

%%是不是占了某个战场副本的坑
isInBattleTable(PlayerID)->
	case etsBaseFunc:readRecord( get("playerbattleTable"), PlayerID ) of
		{}->
			Result=false;
		_->
			Result=true
	end,
	%%?DEBUG_OUT("isInBattleTable ~p",[Result]),
	Result.

tellClientBattleEnd(MapOwerID)->
	PlayerList=ets:tab2list( get("playerbattleTable")),
	case PlayerList of
		[]->
			ok;
		_->
			Packet=#pk_GS2U_BattleEnd{unUsed=0},
			FunRemove=fun(#playerbattleInfo{playerID=PlayerID,mapOwerID=OwerID}= _Record )->
							  case OwerID=:=MapOwerID of
								  true->
										player:sendToPlayer(PlayerID, Packet);
								  _->
									  ok
							  end
					  end,
			lists:foreach(FunRemove, PlayerList),
			ok
	end,
	ok.

removeAllPlayerWithMapOwer(MapOwerID)->
	%%Query = ets:fun2ms(
	%%		   fun(#playerbattleInfo{mapOwerID=OwerID} = Record )
	%%				 when OwerID  =:= MapOwerID -> 
	%%				   Record 
	%%		   end),
	%%PlayerList=ets:select(get("playerbattleTable"), Query),
	PlayerList=ets:tab2list( get("playerbattleTable")),
	case PlayerList of
		[]->
			ok;
		_->
			FunRemove=fun(#playerbattleInfo{playerID=PlayerID,mapOwerID=OwerID}= _Record )->
							  case OwerID=:=MapOwerID of
								  true->
										removePlayerFromeBattleTable(PlayerID);
								  _->
									  ok
							  end
					  end,
			lists:foreach(FunRemove, PlayerList),
			ok
	end,
	ok.

getMapOwerIDByPlayerID(PlayerID)->
	case etsBaseFunc:readRecord( get("playerbattleTable"), PlayerID ) of
		{}->
			Result=0;
		Record->
			Result=Record#playerbattleInfo.mapOwerID
	end,
	Result.

getCampusEnrollList(Campus)->
	case 	Campus =:= ?CAMP_TIANJI of
		true->
			ResultList=ets:tab2list(get("tianjiEnrollList")),
			ok;
		false->
			ResultList=ets:tab2list(get("xuanzongEnrollList")),
			ok
	end,
	ResultList.

insertEnrollToList(PlayerID,Campus)->
	case 	Campus =:= ?CAMP_TIANJI of
		true->
			case ets:lookup(get("tianjiEnrollList"), PlayerID) of
				[]->
					%%插入
					ets:insert( get("tianjiEnrollList") , #playerEnroll{playerID=PlayerID,playerCampus=Campus}),
					ok;
				_->
					ok
			end,
			ok;
		false->
			ok
	end,
	
	case 	Campus =:= ?CAMP_XUANZONG of
		true->
			case ets:lookup(get("xuanzongEnrollList"), PlayerID) of
				[]->
					%%插入
					ets:insert( get("xuanzongEnrollList") , #playerEnroll{playerID=PlayerID,playerCampus=Campus}),
					ok;
				_->
					ok
			end,
			ok;
		false->
			ok
	end,
	
	ok.

removeFromeEnrollList(PlayerID)->
	ets:delete(get("xuanzongEnrollList"), PlayerID),
	ets:delete(get("tianjiEnrollList"), PlayerID),
	ok.

initMapOwerID()->
	put("MapOwerID",1234567890),%%随便给个值
ok.

assignMapOwerID()->
	put("MapOwerID",get("MapOwerID")+1),
	get("MapOwerID").
		
letPlayerEnterBattle(IsForce)->%%让玩家进入,玩家列表发送变化的时候
	%%先把玩家填充到缺人的地图 功能取消，留着说不定以后会用
	%%mendPlayerToMap(),
	case IsForce of
		false->
			case erlang:length( getCampusEnrollList(?CAMP_TIANJI) )>= getPlayerNumPerBattle() andalso
			erlang:length( getCampusEnrollList(?CAMP_XUANZONG) )>= getPlayerNumPerBattle() of
				true->
					OpenBattle=true;
				false->
					OpenBattle=false
			end;
		true->
			case erlang:length( getCampusEnrollList(?CAMP_TIANJI) )>= getMinOpenBattlePlayerNum() andalso
			erlang:length( getCampusEnrollList(?CAMP_XUANZONG) )>= getMinOpenBattlePlayerNum() of
				true->
					OpenBattle=true;
				false->
					OpenBattle=false
			end
	end,
	
	
	case OpenBattle of
		true->
			?DEBUG_OUT( "letPlayerEnterBattle "),
			%%把玩家强制拉进地图
			TianjiEnrollList=getCampusEnrollList(?CAMP_TIANJI ),
			XuanzongEnrollList=getCampusEnrollList(?CAMP_XUANZONG ),
			case IsForce of
				true->
					case length(TianjiEnrollList)>= getPlayerNumPerBattle() of
						true->
							{ListTopTupleTianji,_}=lists:split(getPlayerNumPerBattle(), TianjiEnrollList);
						false->
							ListTopTupleTianji=TianjiEnrollList
					end,
					case length(XuanzongEnrollList)>= getPlayerNumPerBattle() of
						true->
							{ListTopTupleXuanzong,_}=lists:split(getPlayerNumPerBattle(), XuanzongEnrollList);
						false->
							ListTopTupleXuanzong=XuanzongEnrollList
					end,
					ok;
				false->
					{ListTopTupleTianji,_}=lists:split(getPlayerNumPerBattle(), TianjiEnrollList),
					{ListTopTupleXuanzong,_}=lists:split(getPlayerNumPerBattle(), XuanzongEnrollList)
			end,
			%%OwerPlayerEnroll=lists:nth(1, ListTopTupleTianji),
			%%OwerPlayerID=OwerPlayerEnroll#playerEnroll.playerID,
			%%FunEnterMap=fun(#playerEnroll{playerID=PlayerID,playerCampus=PlayerCampus}=_EnrollInfo)->
			%%					MyEnterPos=active_battle:getWaitingPositionByCampus(PlayerCampus),
			%%					forceLetPlayerEnterMap(PlayerID, PlayerCampus,getBattleMapDataID(),
			%%												MyEnterPos#posInfo.x,MyEnterPos#posInfo.y,OwerPlayerID)
			%%					end,
			%%lists:foreach(FunEnterMap, ListTopTupleTianji),
			%%lists:foreach(FunEnterMap, ListTopTupleXuanzong),
			
			%%把这些玩家加入到进入战场的列表中，同时从报名列表中删掉
			%%OwerPlayerEnroll=lists:nth(1, ListTopTupleTianji),
			%%OwerPlayerID=OwerPlayerEnroll#playerEnroll.playerID,
			OwerPlayerID=assignMapOwerID(),
			FunRemoveEnroll=fun(#playerEnroll{playerID=PlayerID,playerCampus=Campus}=_EnrollInfo)->
							insertToPlayerBattle(PlayerID,OwerPlayerID),
							on_tellPlayerEnterBattle(PlayerID),
							removeFromeEnrollList(PlayerID)
					  end,
			
			lists:foreach(FunRemoveEnroll, ListTopTupleTianji),
			lists:foreach(FunRemoveEnroll, ListTopTupleXuanzong),
			
			%%开启了战场，添加强制开启战场倒计时
			addForceOpenBattleTimer(),
			
			letPlayerEnterBattle(IsForce);
		false->
			ok
	end,
	ok.

%%把玩家强制拉进战场
forceLetPlayerEnterMap(PlayerID,PlayerCampus,MapDataID,PosX,PosY,OwerPlayerID)->
	player:sendMsgToPlayerProcess(PlayerID, {msgletplayerEnterMap,PlayerCampus,MapDataID,
															PosX,PosY,OwerPlayerID}),
	ok.

%%玩家进程调用
letplayerEnterMap(PlayerID,PlayerCampus,MapDataID,PosX,PosY,OwerPlayerID)->

	PlayerPid=player:getPlayerProperty(PlayerID, #player.mapPID),
	
	case PlayerPid =/=0 of
		true->
			PlayerPid!{playerEnterBattleScene,PlayerID,MapDataID,PosX,PosY,OwerPlayerID};
		false->
			%%给自己发消息说玩家进入失败
			battleActivePID!{playerEnterBattleSceneFail,OwerPlayerID,PlayerCampus},
			ok
	end,
	
	%%想地图管理进程请求
	%%mapManagerPID ! { getReadyToEnterMap, self(), 0, [Player], TargetMapInfo },
	%%player:sendMsgToMap( {enterMapByGM, PlayerID, MapDataID} )
	ok.

battlebroadcast(_CurrentTime)->
	BattleTimeList=getBattleTimeInfo(),
	FunBroadCast=fun(OnePeriod)->
						 %%活动还没开始
						 case _CurrentTime>= erlang:element(5, OnePeriod) andalso _CurrentTime < erlang:element(6, OnePeriod) of
							 true->
								 BroadcastPastTime=(_CurrentTime-erlang:element(5, OnePeriod)) rem ?BattleBroadcastInterval,
								 case BroadcastPastTime<?TimerInterval of
									 true->
										 %%发准备期间公告
											?DEBUG_OUT( "battlebroadcast ~p",[_CurrentTime] ),
											systemMessage:sendSysMsgToAllPlayer(?BroadcastOfPapareBattle),
										 ok;
									 false->
										 ok
								 end,
								 ok;
							 false->
								 ok
						 end,
						 %%活动正在进行
						 case _CurrentTime>= erlang:element(7, OnePeriod) andalso _CurrentTime < erlang:element(8, OnePeriod) of
							 true->
								 BroadcastPastTime2=(_CurrentTime-erlang:element(7, OnePeriod)) rem ?BattleBroadcastInterval,
								 case BroadcastPastTime2<?TimerInterval of
									 true->
										 %%发准备期间公告
											?DEBUG_OUT( "battlebroadcast ~p ~p ~p ~p",[_CurrentTime,erlang:element(7, OnePeriod),BroadcastPastTime2,?TimerInterval] ),
											systemMessage:sendSysMsgToAllPlayer(?BroadcastOfBattleInProgress),
										 ok;
									 false->
										 ok
								 end,
								 ok;
							 false->
								 ok
						 end,
						 
						 ok
				 end,
		case enoughPlayerToJoinBattle() of
		true->
			lists:foreach(FunBroadCast, BattleTimeList);
		false->
			ok
	end,
	ok.

enoughPlayerToJoinBattle()->
	case variant:getWorldVarValue(?WorldVariant__Num_Of_Player_Can_Join_Battle) of
		undefined->
			Result=false;
		PlayerNumber->
			case PlayerNumber>= getMinPlayerNumCanJoinBattle() of
				true->
					Result=true;
				false->
					Result=false
			end
	end,
	%%?DEBUG_OUT( "oenoughPlayerToJoinBattle ~p",[Result] ),
	Result.

openBattleActive(_CurrentTime)->
	case isBattleActiveProcessing() of
		true->
			ok;
		false->
			case inBattleActivePeriod() of
				true->
					?DEBUG_OUT( "openBattleActive ~p",[_CurrentTime] ),
					actionBeforeActive(),
					setBattleActiveProcessing(true),
					BattleTimeList=getBattleTimeInfo(),
					FunOpenActive=fun(OnePeriod)->
									case _CurrentTime>= erlang:element(3, OnePeriod) andalso
											  _CurrentTime < erlang:element(4, OnePeriod)+3 of%%结束时间到了的后几s还是可以进
										true->
											%%根据报名情况创建副本
											letPlayerEnterBattle(false),
											
											%%如果比较衰没人打，开启低人数开启战场倒计时
											case get("NextBattleOpenTime") =:= 0 of
												true->
													addForceOpenBattleTimer();
												_->
													ok
											end,
											ok;
										false->
											ok
									end
								  end,
					lists:foreach(FunOpenActive, BattleTimeList),
					ok;
				false->
					ok
			end,
			ok
	end,
	ok.

stopBattleActive(_CurrentTime)->
	case isBattleActiveProcessing() of
		true->
			%%停掉活动
			case inBattleActivePeriod() of
				true->
					ok;
				false->
					?DEBUG_OUT( "stopBattleActive ~p",[_CurrentTime] ),
					setBattleActiveProcessing(false),
					actionAfterActive(),
					%%stopAllBattleActive(),
					ok
			end,
			ok;
		false->
			ok
	end,
	ok.
 
tellClientEnrollResult(PlayerID,Result)->
	%%现在就一个战场，等有多个战场再改
	%%?DEBUG_OUT( "tellClientEnrollResult ~p ~p",[PlayerID,Result] ),
	player:sendToPlayer(PlayerID, #pk_GS2U_BattleEnrollResult{enrollResult=Result,mapDataID=?BattleSceneID}),
	ok.

canEnrollBattleActive(_PlayerID)->%%玩家进程调用
	case enoughPlayerToJoinBattle() of
		true->
			case player:getCurPlayerProperty(#player.level) >= getMinJoinLevel() of
				true->
					%%次数限制取消
					%%PlayerVarArray=player:getCurPlayerProperty(#player.varArray),
					%%VarValue=variant:getPlayerVarValue(PlayerVarArray, ?PlayerVariant_Index_3_Active_P),
					%%BattleJoinTime=(VarValue rem 32) div  4,
					%%case BattleJoinTime>= getJoinTimePerDay() of
					%%	true->
					%%		Result=false;
					%%	false->
							%%检测是否在报名时间
					%%		Result=inBattleEnrollPeriod(),
					%%		ok
					%%end,
					case inBattleEnrollPeriod() of
						true->
							Result=?Cannot_Enroll_Success;
						false->
							?DEBUG_OUT( "canEnrollBattleActive not in period"),
							Result=?Cannot_Enroll_Not_Active_Period
					end,
					ok;
				false->
					?DEBUG_OUT( "canEnrollBattleActive level too low"),
					Result=?Cannot_Enroll_Level_Limit
			end;
		false->
			Result=?Cannot_Enroll_Num_Of_Player_Can_Join_Too_Few,
			ok
	end,
	Result.

inBattleEnrollPeriod()->
	CurrentTime=common:getNowSeconds() rem 86400,
	BattleTimeList=getBattleTimeInfo(),
	
	put("IsInActivePeriod",false),
	FunCheckInActive=fun(OnePeriod)->
						case CurrentTime>= erlang:element(1, OnePeriod) andalso CurrentTime < erlang:element(2, OnePeriod) of
						 true->
							put("IsInActivePeriod",true);
							
						 false->
							 ok
					 	end
					 end,
	lists:foreach(FunCheckInActive, BattleTimeList),
	get("IsInActivePeriod").

inBattleActivePeriod()->
	CurrentTime=common:getNowSeconds() rem 86400,
	BattleTimeList=getBattleTimeInfo(),
	
	put("IsInActivePeriod",false),
	FunCheckInActive=fun(OnePeriod)->
						case CurrentTime>= erlang:element(3, OnePeriod) andalso CurrentTime < erlang:element(4, OnePeriod) of
						 true->
							put("IsInActivePeriod",true);
						 false->
							 ok
					 	end
					 end,
	lists:foreach(FunCheckInActive, BattleTimeList),
	get("IsInActivePeriod").

gm_enrollBattleActive(_PlayerID)->%%玩家进程调用，没啥检测
	?DEBUG_OUT( "gm_enrollBattleActive"),
	battleActivePID!{enrollCampusBattle,player:getCurPlayerID(),player:getCurPlayerProperty(#player.faction)},
	ok.

%%地图进程，检测了npc距离后调用
enrollBattleActive(PlayerID,Campus)->
	battleActivePID!{enrollCampusBattle,PlayerID,Campus},
	ok.

leaveBattleActive(_PlayerID)->%%玩家进程调用
	put("EnrollBattleActive",false),
	battleActivePID!{leaveCampusBattle,player:getCurPlayerID(),player:getCurPlayerProperty(#player.faction)},
	ok.

onEnrollBattleActive(PlayerID,Campus)->
	?DEBUG_OUT( "onEnrollBattleActive player ~p ,Campus=~p" ,[PlayerID,Campus]),
	case isInBattleTable(PlayerID) of
		true->
			player:sendToPlayerProc(PlayerID, { mapMsg_EnrollAck,?Cannot_Enroll_Player_In_Battle_List });
		false->
			player:sendToPlayerProc(PlayerID, { mapMsg_EnrollAck,?Cannot_Enroll_Success }),
			insertEnrollToList(PlayerID,Campus),
			case inBattleActivePeriod() of
				true->
					letPlayerEnterBattle(false),
					ok;
				false->
					ok
			end,
			ok
	end,
	ok.

onRequestCheckEnrollNPC(NPCID)->
	player:sendMsgToMap({battleActiveEnrollCheck,player:getCurPlayerID(),
						 player:getCurPlayerProperty(#player.faction),self(),NPCID}),
	ok.

onCheckEnrollNPC(PlayerID,Campus,FromPID,NPCID)->
	try
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->
				?DEBUG_OUT( "onCheckEnrollNPC PlayerID[~p] = {}", [PlayerID] ),
				throw({return,?Cannot_Enroll_Player_NotExist});
			_->ok				
		end,
		
		Npc = etsBaseFunc:readRecord( map:getMapNpcTable(), NPCID ),
		case Npc of
			{}->
				?DEBUG_OUT( "on_playerMsg_U2GS_CompleteTaskRequest NpcActorID[~p] = {}", [NPCID] ),
				throw({return,?Cannot_Enroll_NPC_NotExist});
			_->ok
		end,
		
		DistSQ = monster:getDistSQFromTo( Player#mapPlayer.pos#posInfo.x,
											Player#mapPlayer.pos#posInfo.y,
											Npc#mapNpc.x,
											Npc#mapNpc.y
											),
		case DistSQ > ?TalkToNpc_Distance_SQ of
			true->
				?DEBUG_OUT( "on_playerMsg_U2GS_CompleteTaskRequest DistSQ[~p] false", [DistSQ] ),
				throw({return,?Cannot_Enroll_NPC_Too_Far});
			false->ok
		end,

		%%状态不允许
		NotAcceptState = ( ?Actor_State_Flag_Dead bor ?Player_State_Flag_ChangingMap ),
		case mapActorStateFlag:isStateFlag(Player#mapPlayer.id, NotAcceptState) of
			true->
				throw({return,?Cannot_Enroll_Player_State_Error});
			false->ok
		end,
		
		NpcCfg = etsBaseFunc:readRecord( main:getGlobalNpcCfgTable(), Npc#mapNpc.npc_data_id ),
		case NpcCfg of
			{}->
				throw({return,?Cannot_Enroll_Player_State_Error});
			_->ok
		end,
		
		%%发消息给战场进程，请求报名
		enrollBattleActive(PlayerID,Campus),
		%%FromPID ! { mapMsg_EnrollAck,?Cannot_Enroll_Success },
		%%onEnrollBattleActive(PlayerID,Campus),
		ok
	catch
		{return,Reason}->FromPID ! { mapMsg_EnrollAck,Reason }
	end.

onLeaveBattleActive(PlayerID,_Campus)->
	removeFromeEnrollList(PlayerID),
	ok.

%%地图进程调用,在战斗没结束的时候调用
leaveBattleScene(PlayerID,Campus)->
	battleActivePID!{msg_leaveBattleScene,PlayerID,get("OwnerID"),Campus},
ok.

%%玩家进程调用
leaveBattleScene()->
	%%battleActivePID!{msg_playerleaveBattle,player:getCurPlayerID(),player:getCurPlayerProperty(#player.faction)},
	player:getCurPlayerProperty(#player.mapPID)!{msg_playerleaveBattle,player:getCurPlayerID(),player:getCurPlayerProperty(#player.faction)},
	ok.

onleaveBattleScene(PlayerID,OwerPlayerID,Campus)->%%战场存的一个唯一ID，这里的意义为战斗场景ID
	%%重新从列表中选个人放到战场
	%%如果没人填补进去，那么记录下战场缺人，等有人了添加进去
	?DEBUG_OUT( "onleaveBattleScene "),
	%%把玩家从战场表中弄出去
	removePlayerFromeBattleTable(PlayerID),
	case 	Campus =:= ?CAMP_TIANJI of
		true->
			case ets:tab2list(get("tianjiEnrollList")) of
				[]->
					%%记录战场缺人
					?DEBUG_OUT( "onleaveBattleScene on_insertPlayerToFailList"),
					on_insertPlayerToFailList(OwerPlayerID,Campus);
				[_FirstEnrol|_]->
					%%往战场补充人的功能去掉
					%%?DEBUG_OUT( "onleaveBattleScene MendPlayer"),
					%%MyEnterPos=active_battle:getBirthPositionByCampus(_FirstEnrol#playerEnroll.playerCampus),
					%%forceLetPlayerEnterMap(_FirstEnrol#playerEnroll.playerID,_FirstEnrol#playerEnroll.playerCampus,getBattleMapDataID(),
					%%										MyEnterPos#posInfo.x,MyEnterPos#posInfo.y,OwerPlayerID),
					%%removeFromeEnrollList(FirstEnrol#playerEnroll.playerID),
					ok
			end;
		_->
			ok
	end,
	
	case 	Campus =:= ?CAMP_XUANZONG of
		true->
			case ets:tab2list(get("xuanzongEnrollList")) of
				[]->
					%%记录战场缺人
					on_insertPlayerToFailList(OwerPlayerID,Campus);
				[FirstEnrol2|_]->
					%%往战场补充人的功能去掉
					%%MyEnterPos2=active_battle:getBirthPositionByCampus(FirstEnrol2#playerEnroll.playerCampus),
					%%forceLetPlayerEnterMap(FirstEnrol2#playerEnroll.playerID,FirstEnrol2#playerEnroll.playerCampus,getBattleMapDataID(),
					%%										MyEnterPos2#posInfo.x,MyEnterPos2#posInfo.y,OwerPlayerID),
					%%removeFromeEnrollList(FirstEnrol2#playerEnroll.playerID),
					ok
			end;
		_->
			ok
	end,
ok.

%%战场脚本调用
gaveFinalBattleAward()->
	FunXuanzongID=fun(#mapPlayer{id=PlayerID}=Record)->
						  case Record#mapPlayer.faction=:=?CAMP_XUANZONG of
								true->
									  PlayerID;
								false->
									0
				  		end
				  end,
	
	FunTianjiID=fun(#mapPlayer{id=PlayerID}=Record)->
						  case Record#mapPlayer.faction=:=?CAMP_TIANJI of
								true->
									  PlayerID;
								false->
									0	
				  		end
				end,

	

	
	Xuanzonglist0=lists:map(FunXuanzongID, ets:tab2list( map:getMapPlayerTable() )),
	Tianjilist0=lists:map(FunTianjiID, ets:tab2list( map:getMapPlayerTable() )),
	MyFunc = fun( Record )->
					Record =/= 0
			 end,
	Xuanzonglist=lists:filter(MyFunc, Xuanzonglist0),
	Tianjilist=lists:filter(MyFunc, Tianjilist0),
	
	FunFailAward=fun(PlayerID)->
						Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
						case Player of
							{}->
								ok;
							_->
								%%?ERROR_OUT("~p failed",[PlayerID]),
								ConvoyAwardList=convoy:getAwardByLevel(Player#mapPlayer.level),
								Exp=ConvoyAwardList#convoyAwardCfg.battle_exp_lose,
								Player#mapPlayer.pid!{addEXP,Exp,?Exp_Change_Battle},
								player:addPlayerHonor(Player#mapPlayer.id, getLoseHonor(), true, 0),
								ok
						end
				 end,
	
	FunWinAward=fun(PlayerID)->
						Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
						case Player of
							{}->
								ok;
							_->
								%%?ERROR_OUT("~p win",[PlayerID]),
								ConvoyAwardList=convoy:getAwardByLevel(Player#mapPlayer.level),
								Exp=ConvoyAwardList#convoyAwardCfg.battle_exp_win,
								Player#mapPlayer.pid!{addEXP,Exp,?Exp_Change_Battle},
								player:addPlayerHonor(Player#mapPlayer.id, getWinHonor(), true, 0),
								ok
						end
				 end,
				
				
	case get("xuanzongScore") =:= get("tianjiScore") of
		true->
			%%平局
			lists:foreach(FunFailAward, Xuanzonglist),
			lists:foreach(FunFailAward, Tianjilist),
			ok;
		false->
			case get("xuanzongScore") > get("tianjiScore") of
				true->
					%%玄宗赢了
					lists:foreach(FunWinAward, Xuanzonglist),
					lists:foreach(FunFailAward, Tianjilist),
					ok;
				false->
					lists:foreach(FunFailAward, Xuanzonglist),
					lists:foreach(FunWinAward, Tianjilist),
					ok
			end,
			ok
	end,
	ok.

tellManagerbattleEnd()->%%地图进程调用
	?DEBUG_OUT( "tellManagerbattleEnd[~p] ", [self()] ),
	battleActivePID!{oneBattleEnd,self(),get("OwnerID")},
ok.
tellManagerNoPlayerClose()->
	?DEBUG_OUT( "tellManagerNoPlayerClose[~p] ", [self()] ),
	battleActivePID!{oneBattleNoPlayerClose,self(),get("OwnerID")},
	ok.

onBattleEnd(MapPid,OwerPlayerID)->
	onBattleNoPlayerClose(MapPid,OwerPlayerID),
	%%然后告诉地图进程进行结算
	?DEBUG_OUT( "onBattleEnd"),
	MapPid!{battleBalance},
ok.

onBattleNoPlayerClose(_MapPid,OwerPlayerID)->
	?DEBUG_OUT( "onBattleNoPlayerClose"),
	%%把战场的缺人清掉
	on_decLackPlayerList(OwerPlayerID,?CAMP_TIANJI,99999),%%怎么也不会这么缺人吧
	on_decLackPlayerList(OwerPlayerID,?CAMP_XUANZONG,99999),%%怎么也不会这么缺人吧
	
	%%告知玩家战场结束
	tellClientBattleEnd(OwerPlayerID),
	%%把玩家战场进入情况清掉
	removeAllPlayerWithMapOwer(OwerPlayerID),
	ok.

stopAllBattleActive()->
	?DEBUG_OUT( "stopAllBattleActive"),
	mapManagerPID!{battleBalance,getBattleMapDataID()},
ok.

on_insertPlayerToFailList(OwerPlayerID,Campus)->
	?DEBUG_OUT( "on_insertPlayerToFailList ~p",[OwerPlayerID] ),
	case ets:lookup(get("lackPlayerTable"), OwerPlayerID) of
		[]->
			case Campus=:= ?CAMP_TIANJI of
				true->
					ets:insert(get("lackPlayerTable"), 
							#battleLackPlayer{sceneowerActorID=OwerPlayerID,tianjilackNum=1,xuanzonglackNum=0});
				false->
					ets:insert(get("lackPlayerTable"), 
							#battleLackPlayer{sceneowerActorID=OwerPlayerID,tianjilackNum=0,xuanzonglackNum=1})
			end;
		[Record|_]->
			case Campus=:= ?CAMP_TIANJI of
				true->
					ets:update_element(get("lackPlayerTable"), OwerPlayerID,
						{#battleLackPlayer.tianjilackNum,Record#battleLackPlayer.tianjilackNum+1});
				false->
					ets:update_element(get("lackPlayerTable"), OwerPlayerID,
						{#battleLackPlayer.xuanzonglackNum,Record#battleLackPlayer.xuanzonglackNum+1})
			end
	end,
	ok.

on_decLackPlayerList(OwerPlayerID,Campus,DecNumber)->
	case ets:lookup(get("lackPlayerTable"), OwerPlayerID) of
		[]->
			ok;
		[Record|_]->
			case Campus=:= ?CAMP_TIANJI of
				true->
					case Record#battleLackPlayer.tianjilackNum =<DecNumber of
						true->
							ets:delete(get("lackPlayerTable"), OwerPlayerID);
						false->
							ets:update_element(get("lackPlayerTable"), OwerPlayerID,
								{#battleLackPlayer.tianjilackNum,Record#battleLackPlayer.tianjilackNum-DecNumber})
					end;
				false->
					case Record#battleLackPlayer.xuanzonglackNum =<DecNumber of
						true->
							ets:delete(get("lackPlayerTable"), OwerPlayerID);
						false->
							ets:update_element(get("lackPlayerTable"), OwerPlayerID,
								{#battleLackPlayer.xuanzonglackNum,Record#battleLackPlayer.xuanzonglackNum-DecNumber})
					end
			end
	end,
	ok.

mendPlayerToMap()->
	?DEBUG_OUT( "mendPlayerToMap" ),
	try
	LackPlayerTable=ets:tab2list(get("lackPlayerTable")),
	
	FunMend=fun(LackInfo)->
					XuanzongEnrollList=ets:tab2list(get("xuanzongEnrollList")),
					TianjiEnrollList=ets:tab2list(get("tianjiEnrollList")),
					case length(XuanzongEnrollList)=<0 andalso length(TianjiEnrollList) =<0  of
						true->
							throw({-1});
						false->
							ok
					end,
					
					?DEBUG_OUT( "mendPlayerToMap 22" ),
							
					case LackInfo#battleLackPlayer.xuanzonglackNum >0 of
						true->
							case length(XuanzongEnrollList)> LackInfo#battleLackPlayer.xuanzonglackNum of
								true->
									XuanzongMenderNumber=LackInfo#battleLackPlayer.xuanzonglackNum;
								false->
									XuanzongMenderNumber=length(XuanzongEnrollList)
							end,
							
							case XuanzongMenderNumber>0 of
								true->
									
									XuanzongMenFun=fun(_N)->
														   FirstEnrol=lists:nth(_N, XuanzongEnrollList),
														   MyEnterPos=active_battle:getBirthPositionByCampus(FirstEnrol#playerEnroll.playerCampus),
															%%player:sendMsgToPlayerProcess(FirstEnrol#playerEnroll.playerID, {msgletplayerEnterMap,FirstEnrol#playerEnroll.playerCampus,getBattleMapDataID(),
															%%	MyEnterPos#posInfo.x,MyEnterPos#posInfo.y,LackInfo#battleLackPlayer.sceneowerActorID}),
															forceLetPlayerEnterMap(FirstEnrol#playerEnroll.playerID,FirstEnrol#playerEnroll.playerCampus,getBattleMapDataID(),
																				   MyEnterPos#posInfo.x,MyEnterPos#posInfo.y,LackInfo#battleLackPlayer.sceneowerActorID),
															removeFromeEnrollList(FirstEnrol#playerEnroll.playerID)
														   end,
									common:for(1, XuanzongMenderNumber, XuanzongMenFun),
									ok;
								false->
									ok
							end,
							
							ok;
						false->
							ok
					end,
					
					
					case LackInfo#battleLackPlayer.tianjilackNum >0 of
						true->
							case length(TianjiEnrollList)> LackInfo#battleLackPlayer.tianjilackNum of
								true->
									TianjiMenderNumber=LackInfo#battleLackPlayer.tianjilackNum;
								false->
									TianjiMenderNumber=length(TianjiEnrollList)
							end,
							
							case TianjiMenderNumber>0 of
								true->
									
									TianjiMenFun=fun(_N)->
														   FirstEnrol=lists:nth(_N, TianjiEnrollList),
														   MyEnterPos=active_battle:getBirthPositionByCampus(FirstEnrol#playerEnroll.playerCampus),
															%%player:sendMsgToPlayerProcess(FirstEnrol#playerEnroll.playerID, {msgletplayerEnterMap,FirstEnrol#playerEnroll.playerCampus,getBattleMapDataID(),
															%%	MyEnterPos#posInfo.x,MyEnterPos#posInfo.y,LackInfo#battleLackPlayer.sceneowerActorID}),
															forceLetPlayerEnterMap(FirstEnrol#playerEnroll.playerID,FirstEnrol#playerEnroll.playerCampus,getBattleMapDataID(),
																				   MyEnterPos#posInfo.x,MyEnterPos#posInfo.y,LackInfo#battleLackPlayer.sceneowerActorID),
															removeFromeEnrollList(FirstEnrol#playerEnroll.playerID)
														   end,
									common:for(1, TianjiMenderNumber, TianjiMenFun),
									ok;
								false->
									ok
							end,
							
							ok;
						false->
							ok
					end,

					ok
			end,
	lists:foreach(FunMend, LackPlayerTable),
	
	ok
	catch
		_->
			ok
	end.

onRequestEnrollInfo(PlayerID)->
	battleActivePID!{msg_requestEnrollInfo,PlayerID},
	ok.

on_sendEnrollInfo(PlayerID)->
	player:sendToPlayer(PlayerID, #pk_GS2U_sendEnrollInfo{enrollxuanzong=ets:info(get("xuanzongEnrollList"),size),
						   enrolltianji=ets:info(get("tianjiEnrollList"),size)}
						),
	
	ok.

on_tellPlayerOnline(PlayerID,Campus)->
	case get("everEnterMaped") of
		undefined->
			put("everEnterMaped",true),
			battleActivePID!{tellPlayerOnline,PlayerID,Campus};
		_->
			ok
	end,
	ok.

on_playerOnline(PlayerID,Campus)->%%玩家上线，根据报名以及战场情况给出提醒
	%%如果在报名列表中，那么就告知报名成功，
	case Campus=:= ?CAMP_TIANJI of
		false->
			case etsBaseFunc:readRecord(get("xuanzongEnrollList"), PlayerID) of
				{}->
					ok;
				_->
					active_battle:tellClientEnrollResult(PlayerID,?Cannot_Enroll_Success),
					ok
			end,
			ok;
		true->
			case etsBaseFunc:readRecord(get("tianjiEnrollList"), PlayerID) of
				{}->
					ok;
				_->
					active_battle:tellClientEnrollResult(PlayerID,?Cannot_Enroll_Success),
					ok
			end,
			ok
	end,
	%%如果在等着进战场的列表，那么告知可以进战场
	case etsBaseFunc:readRecord( get("playerbattleTable"), PlayerID ) of
		{}->
			ok;
		_->
			on_tellPlayerEnterBattle(PlayerID)
	end,
	ok.

%%发消息告诉客户端可以进入战场了
on_tellPlayerEnterBattle(PlayerID)->
	player:sendToPlayer(PlayerID, #pk_GS2U_NowCanEnterBattle{battleID=?BattleSceneID}),
	ok.

on_SureEnterMap(PlayerID,Campus)->
	?DEBUG_OUT( "on_SureEnterMap"),
	case etsBaseFunc:readRecord( get("playerbattleTable"), PlayerID ) of
		{}->
			%%进入失败
			player:sendToPlayer(PlayerID, #pk_GS2U_EnterBattleResult{faileReason=?Cannot_EnterBattle_NoBattleInfo}),
			ok;
		Record->
			?DEBUG_OUT( "on_SureEnterMap success owerID=~p",[Record#playerbattleInfo.mapOwerID]),
			MyEnterPos=active_battle:getWaitingPositionByCampus(Campus),
			forceLetPlayerEnterMap(PlayerID, Campus, getBattleMapDataID(), MyEnterPos#posInfo.x,MyEnterPos#posInfo.y, Record#playerbattleInfo.mapOwerID)
	end,
	ok.

on_requestEnterBattleMap(PlayerID,Campus)->
	battleActivePID!{msg_requestEnterBattleMap,PlayerID,Campus}.	

addForceOpenBattleTimer()->
	case erlang:length( getCampusEnrollList(?CAMP_TIANJI) )>= getPlayerNumPerBattle() andalso
			erlang:length( getCampusEnrollList(?CAMP_XUANZONG) )>= getPlayerNumPerBattle() of
		true->
			ok;
		false->
			put("NextBattleOpenTime",common:getNowSeconds()+getForceBattleInterval()),
			timer:send_after(getForceBattleInterval()*1000, {forceOpenBattle}),
			ok
	end,
	ok.

onForceOpenBattle()->
	Current=common:getNowSeconds(),
	%%?DEBUG_OUT( "onForceOpenBattle ~p ~p",[Current,get("NextBattleOpenTime")]),
	case get("NextBattleOpenTime")=/= 0 of
		true->
			case Current>= get("NextBattleOpenTime") of
				true->
					%%开启战场
					?DEBUG_OUT( "onForceOpenBattle"),
					letPlayerEnterBattle(true),
					ok;
				false->
					ok
			end;
		false->
			ok
	end,
	ok.


addTicker()->
	Current=common:getNowSeconds() rem 86400,
	NextMinute=60- Current rem ?TimerInterval,
	timer:send_after(NextMinute*1000,{active_battleTick} ).

handle_Tick()->
	%%战场相关
	Current=common:getNowSeconds() rem 86400,
	
	battlebroadcast(Current),
	openBattleActive(Current),
	onForceOpenBattle(),
	stopBattleActive(Current),
	
	addTicker(),
	ok.

%%玩家进程调用
inBattleScene()->
	case get("InbattleScene") of
		true->
			Result=true;
		_->
			Result=false
	end,
	Result.

loadBattleCfg()->
	%%?ERROR_OUT( "loadBattleCfg begin" ),
	case db:openBinData( "battle.bin" ) of
		[] ->
			?ERROR_OUT( "loadBattleCfg error party_exp = []" );
		BattleDataBin ->
			db:loadBinData( BattleDataBin, battleXianzonglinCfg ),
			
			BattleCfgTable = ets:new( 'globleBattleXianzonglinCfgTable', [protected, named_table, {read_concurrency,true}, { keypos, #battleXianzonglinCfg.id }] ),
			
			BattleCfgList = db:matchObject(battleXianzonglinCfg,  #battleXianzonglinCfg{_='_'} ),
			
			MyFunc = fun( Record )->
							 etsBaseFunc:insertRecord(BattleCfgTable, Record)
					 end,
			lists:map( MyFunc, BattleCfgList ),
			?DEBUG_OUT( "load battle.bin succ" )
	end,
	ok.