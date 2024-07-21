-module(worldBoss).

-behaviour(gen_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-compile(export_all). 

-include("worldBoss.hrl").
-include("playerDefine.hrl").
-include("hdlt_logger.hrl").
-include("mapDefine.hrl").
-include_lib("stdlib/include/ms_transform.hrl"). 
-include("db.hrl").
-include("pc_player.hrl").
-include("daily.hrl").
-include("textDefine.hrl").

start_link()->
 gen_server:start_link( {local,worldBossManagerPID},?MODULE, [], [ {timeout,600000}] ).  

init([]) -> 
	?DEBUG_OUT( "worldBoss Init"),
	
	
	%%伤害表格
	put("HarmTableInit", false),
	initHarmTable(),
	initBossStautsTable(),
	
	
	put("HavingActive",false),
	
	%%增加个定时器
	addTicker(),
	?DEBUG_OUT( "worldBoss Init Success"),
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
	put("WorldBoss", true),

	try
	case Info of
		{quit}->
			?DEBUG_OUT( "WorldBoss Recieve quit" ),
			put( "WorldBoss", false );

		{worldbossTickerID}->
			handle_Tick(),
			ok;
		%%场景统计有多少个boss 刷出来了
		{activeOneBoss,_MapPID}->
			on_activeOneBoss(_MapPID);
		{worldBossGaveExpTimer}->
			nowWorldBossGaveExp();
		{worldBossHarm,MapPID,PlayerID,DamageHP}->
			upDatePlayerHarm(MapPID,PlayerID,DamageHP);
		{sendRankList,PlayerID,MapPID,Viewed,Socket}->
			on_sendRankInfo(PlayerID,MapPID,Viewed,Socket);
		{worldBossDieMsg,MapPID}->
			bossDieAward(MapPID);
		{requestBossActive,MapPID}->
			on_requestBossActive(MapPID);
		{firstStageAllMonsterKill,MapPID}->
			onFirstStageSmallMonsterKill(MapPID)
	end,
	
	case get("WorldBoss") of
		true->{noreply, StateData};
		false->{stop, normal, StateData}
	end

	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[?MODULE,_Why, erlang:get_stacktrace()] ),	

			{noreply, StateData}
	end.

%%改为boss 共享血量，判定一个地图如果是刷boss的地图，那么创建的时候会去boss活动进程询问是否需要刷个boss 出来
isWorldBossMap(MapID)->
	BossInfo=getBossInfo(),
	_Result=BossInfo#worldBossCfg.mapid=:=MapID.

%%获取boss配置
getBossInfo()->
	%%初始化boss信息，这个测试数据要修改的
	{Date,{_Hour,_Minute,_Second}}=calendar:now_to_local_time(erlang:now()),
	WeekDay=calendar:day_of_the_week(Date),
	[ConfigOfThisDay|_]=ets:lookup('globleBossCfgTable',WeekDay ),
	ConfigOfThisDay.
	%%_BossInfo = #worldBossInfo{mapID=8,posX=1660,posY=1195,refreshSecond=72000,existTime=1800,bossID=286}.
	
isWorldBoss(Monster)->
	BossInfo=getBossInfo(),
	case  Monster#mapMonster.monster_data_id=:=BossInfo#worldBossCfg.bossid of
			true->true;
			false->false
	end.

%%根据玩家等级给经验
worldBossGaveExp(MapPlayer,_MapPID)->
	case MapPlayer of
		{}->ok;
		_->
			ExpToGave=ets:lookup('globlePartyCfgTable',MapPlayer#mapPlayer.level ),
			case ExpToGave of
				[]->
					ok;
				[FirstMapExp|_]->
					MapPlayer#mapPlayer.pid!{addEXP,FirstMapExp#partyCfg.bossinvade_35,?Exp_Change_KillMonster}
			end
	end.

%%给玩家最终经验
gaveFinalExp(MapPlayer)->
	case MapPlayer of
		{}->ok;
		_->
			MapPlayer#mapPlayer.pid!{addEXP,MapPlayer#mapPlayer.level*5000,?Exp_Change_KillMonster}
	end.

%%更新玩家伤害记录
upDatePlayerHarm(MapPID,PlayerID,DamageHP)->
	HarmInfo=ets:lookup(get("HarmTable"), PlayerID),
	case HarmInfo of
		[]->
			PlayerName=player:getPlayerProperty(PlayerID,#player.name),
			ets:insert(get("HarmTable"), 
			   #worldBossharmInfo{playerID=PlayerID,harmData=(DamageHP),mapPID=MapPID,playerName=PlayerName});
		_->
			HarmFirst=lists:nth(1, HarmInfo),
			case etsBaseFunc:getRecordField(get("worldBossDetailTable"), HarmFirst#worldBossharmInfo.mapPID, #worldBossStatus.isKilled) of
				true->
					ok;
				_->
					OldHarm=HarmFirst#worldBossharmInfo.harmData,
					NewHarm=DamageHP+OldHarm,
					%%ets:update_element(get("HarmTable"), PlayerID, {#worldBossharmInfo.mapPID,MapPID}),
					ets:update_element(get("HarmTable"), PlayerID, {#worldBossharmInfo.harmData,NewHarm})
			end
	end,
	ok.

%%激活世界boss
activeWorldBoss(CurrentTime)->
	WorldBossInfo=getBossInfo(),
	FirstBroadcastTime=WorldBossInfo#worldBossCfg.starttime,%%公告开始时间
	EndBroadcastTime=WorldBossInfo#worldBossCfg.overtime,
	case (CurrentTime>=FirstBroadcastTime) and (CurrentTime<EndBroadcastTime) of
		false ->
			ok;
		true->
			case get("HavingActive") of
				true->
					ok;
				false->
					%%在活动时间段，怪没刷，那么就刷一个
					%%重置表格
					initHarmTable(),
					initBossStautsTable(),
					
					%%发消息告诉场景管理器，活动开始
					mapManagerPID!{woldBossBegin,WorldBossInfo#worldBossCfg.mapid},
					
					put("HavingActive",true),%%可以给经验了
	
					%%添加定时器，给经验
					addExpTimer(),
					
					?DEBUG_OUT( "worldBoss  activeWorldBoss");
				_->ok
			end
	end,
  ok.

onFirstStageSmallMonsterKill(MapPID)->
	tellMaptoBornBoss(MapPID),
ok.


tellMaptoBornBoss(MapPID)->
	%%开始刷boss
			WorldBossInfo=getBossInfo(),
			ActiveBeginTime=WorldBossInfo#worldBossCfg.starttime,%%公告开始时间
			ActiveEndTime=WorldBossInfo#worldBossCfg.overtime,
			Current=common:getNowSeconds() rem 86400,
			case (Current>=ActiveBeginTime) andalso (Current<ActiveEndTime) of
				true->
					MapPID!{woldBossComeout};
				_->
					ok
			end,
	ok.


%%定时器活动结束，要重新初始化表格
worldBossEnd(CurrentTime)->
	%%结束给经验以及物品，走这里结束的都是没有的
	%%发消息杀掉boss
	WorldBossInfo=getBossInfo(),
	EndBroadcastTime=WorldBossInfo#worldBossCfg.overtime,%%公告结束时间
	case CurrentTime>= EndBroadcastTime of
		false->
			ok;
		true->
			case get("HavingActive") of
				true->
					
					mapManagerPID!{worldBossKill,WorldBossInfo#worldBossCfg.mapid},
					put("HavingActive",false),
				
					%%全服告知活动结束
					LeftTime=#pk_GS2U_WordBossCmd{m_iCmd=2,m_iParam=0},
					player:bostcast(player:getAllOnlinePlayerIDs(),LeftTime ),
					
					%%判定是不是所有场景的怪都被打死了，没打死发消息说结束
					IsAllBossKill=isAllBossKill(),
					if 
						IsAllBossKill=:=false->
							systemMessage:sendSysMsgToAllPlayer(?BroadcastWorldBossNoAllKill);
						IsAllBossKill=:=true-> ok
					end,
					%%发消息杀掉没死掉的boss
					mapManagerPID!{killWorldBoss,WorldBossInfo#worldBossCfg.mapid,WorldBossInfo#worldBossCfg.bossid},
					?DEBUG_OUT( "worldBoss  worldBossEnd");
				_->
					ok
			end
	end,
	ok.

	%%给经验的回调函数
nowWorldBossGaveExp()->
	WorldBossInfo=getBossInfo(),
	case get("HavingActive") of%%这种标记地图也搞个，然后就活动结束可以不给经验了
		true->
			mapManagerPID!{worldBossAddExp,WorldBossInfo#worldBossCfg.mapid},
			addExpTimer(),
			rankHarmTopten();
		false->
			ok
	end,
	ok.

%%初始化伤害表
initHarmTable()->
  %%ets:delete(worldBossharmTable),
	case get("HarmTableInit") of
		true->
  			ets:delete_all_objects( get("HarmTable")  );
		false->
			put("HarmTable",ets:new(worldBossharmTable, [private, { keypos, #worldBossharmInfo.playerID }])),
			put("HarmTableInit",true)
	end.

%%初始化地图场景boss 被杀掉情况
initBossStautsTable()->
	case get("worldBossDetailTable") of
		undefined->
			put("worldBossDetailTable",ets:new(worldBossKillTable, [private, { keypos, #worldBossStatus.mapPID }])),
			ok;
		_->
  			ets:delete_all_objects( get("worldBossDetailTable")  )
	end.

%%活动之前发消息
sendBroadCastBeforeActive(CurrentTime)->
	WorldBossInfo=getBossInfo(),
	FirstBroadcastTime=WorldBossInfo#worldBossCfg.starttime+?BroadcastAheadTime,%%公告开始时间
	EndBroadcastTime=WorldBossInfo#worldBossCfg.starttime,%%公告结束时间
	
	case (CurrentTime<EndBroadcastTime) andalso (CurrentTime>= FirstBroadcastTime  ) of
		true->
			PastTimeBeweenLastCast=(CurrentTime-FirstBroadcastTime) rem ?BroadcastInterval,
			case PastTimeBeweenLastCast<60 of %% 60是定时器间隔
						false->
							ok;
						true->
							MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), WorldBossInfo#worldBossCfg.mapid),
							BroadcastText = io_lib:format(?BroadcastBeforeWorldBoss, [MapCfg#mapCfg.mapName]),
							systemMessage:sendSysMsgToAllPlayer(BroadcastText)
			end,
			ActiveLeftSecond=WorldBossInfo#worldBossCfg.overtime-CurrentTime,
			WeekDay=WorldBossInfo#worldBossCfg.number,
			SendArg=WeekDay*65536+ActiveLeftSecond,
			LeftTime=#pk_GS2U_WordBossCmd{m_iCmd=1,m_iParam=SendArg},
			player:bostcast(player:getAllOnlinePlayerIDs(),LeftTime );
		false->
			ok
	end,
	ok.

%%活动之前发消息
sendBroadCastDuringActive(CurrentTime)->
	?DEBUG_OUT("sendBroadCastDuringActive  00"),
	WorldBossInfo=getBossInfo(),
	FirstBroadcastTime=WorldBossInfo#worldBossCfg.starttime,%%公告开始时间
	EndBroadcastTime=WorldBossInfo#worldBossCfg.overtime,%%公告结束时间

	?DEBUG_OUT("sendBroadCastDuringActive  ~p ~p ~p",[CurrentTime,FirstBroadcastTime,EndBroadcastTime]),

	case (CurrentTime<EndBroadcastTime) andalso (CurrentTime>= FirstBroadcastTime  ) of
		true->
			case isAllBossKill() of
				true->
					ok;
				_->
					PastTimeBeweenLastCast=(CurrentTime-FirstBroadcastTime) rem ?BroadcastInterval,
					case PastTimeBeweenLastCast<60 of %% 60是定时器间隔
						false->
							ok;
						true->

							MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), WorldBossInfo#worldBossCfg.mapid),
							BroadcastText = io_lib:format(?BroadcastDuringWorldBoss, [MapCfg#mapCfg.mapName]),
							systemMessage:sendSysMsgToAllPlayer(BroadcastText)
					end,
					ActiveLeftSecond=WorldBossInfo#worldBossCfg.overtime-CurrentTime,
					WeekDay=WorldBossInfo#worldBossCfg.number,
					SendArg=WeekDay*65536+ActiveLeftSecond,
					LeftTime=#pk_GS2U_WordBossCmd{m_iCmd=1,m_iParam=SendArg},
					?DEBUG_OUT("sendBroadCastDuringActive"),
					player:bostcast(player:getAllOnlinePlayerIDs(),LeftTime )
			end;
		false->
			ok
	end,
	ok.

on_requestBossActive(MapPID)->
	%%在活动期间，就开启活动
	WorldBossInfo=getBossInfo(),
	ActiveBeginTime=WorldBossInfo#worldBossCfg.starttime,%%公告开始时间
	ActiveEndTime=WorldBossInfo#worldBossCfg.overtime-30,%%最后半分钟不刷鸟，反正也打不完，也省得出事儿
	CurrentTime=common:getNowSeconds() rem 86400,
	case (CurrentTime>=ActiveBeginTime) andalso (CurrentTime<ActiveEndTime) of
		true->
			%%	这个地图没刷boss
			%%活动需要先开了
			case get("HavingActive") of
				false->
					ok;
				_->
					MapPID!{ woldBossBegin}
			end,
			ok;
		false->
			ok
	end.
	

bossDieAward(MapPID)->
	?DEBUG_OUT( "worldBoss worldBossDie"),
	%%更新杀死记录
	 case ets:lookup(get("worldBossDetailTable"), MapPID) of
		 []->
			 %%这个不该存在的
			ets:insert(get("worldBossDetailTable"), #worldBossStatus{mapPID=MapPID,isKilled=true,gS2U_RankList={}});
		 _->
			ets:update_element( get("worldBossDetailTable"), MapPID, {#worldBossStatus.isKilled,true} )
	end,
			%%本地图的进行排行，经验在地图直接给了
			HarmList=rankHarmTopten(MapPID),
			?DEBUG_OUT( "worldBoss worldBossDie HarmList come out"),
			
			%%根据排名发邮件
			put("HarmRankID",1),
			%%随即生成
			case erlang:length(HarmList)>?AwardPlayerNum of
				true->
					case  erlang:length(HarmList)<?AwardPlayerNum+?RandAwardNum of
						%%人人都有
						true->
							UsefullLen=erlang:length(HarmList)-?AwardPlayerNum,
							RandAward=lists:sublist(HarmList, ?AwardPlayerNum+1, UsefullLen);
						false->
							UsefullLen=erlang:length(HarmList)-?AwardPlayerNum,
							RandAward=[
										lists:nth(?AwardPlayerNum+              				   random:uniform(UsefullLen div ?RandAwardNum), HarmList),
										lists:nth(?AwardPlayerNum+  (UsefullLen div ?RandAwardNum)+random:uniform(UsefullLen div ?RandAwardNum), HarmList),
										lists:nth(?AwardPlayerNum+(2*UsefullLen div ?RandAwardNum)+random:uniform(UsefullLen div ?RandAwardNum), HarmList),
										lists:nth(?AwardPlayerNum+(3*UsefullLen div ?RandAwardNum)+random:uniform(UsefullLen div ?RandAwardNum), HarmList),
										lists:nth(?AwardPlayerNum+(4*UsefullLen div ?RandAwardNum)+random:uniform(UsefullLen div ?RandAwardNum), HarmList)
									  ]
					end;
					
				false->
					RandAward=[]
			end,
			BossInfo = getBossInfo(),
			%%前10的奖励
			put("tempName",""),
			lists:foreach(
			  fun(#worldBossharmInfo{playerID=_PlayerID,playerName=PlayerName})->
				%%PlayerPID = player:getPlayerPID(_PlayerID),
				RandID=get("HarmRankID"),
				if	
					RandID =:=1 ->
						mail:sendSystemMailToPlayer(_PlayerID, ?WorldBossMailSender,?WorldBossMailHead, ?WorldBossMailHarmofFirst,
													 BossInfo#worldBossCfg.firstitem, BossInfo#worldBossCfg.firstnum, true, 0, 0, 0, 0),
						BroadcastAwardBest=io_lib:format("~s~s", [PlayerName,?BroadcastWorldBossAwardFirst]),
						systemMessage:sendSysMsgToAllPlayer(BroadcastAwardBest),
						put("HarmRankID",get("HarmRankID")+1);
					(RandID>=2) andalso (RandID=<?AwardPlayerNum ) ->
						mail:sendSystemMailToPlayer(_PlayerID, ?WorldBossMailSender,?WorldBossMailHead, ?WorldBossMailHarmofOther,
													 BossInfo#worldBossCfg.seconditem, BossInfo#worldBossCfg.secondnum, true, 0, 0, 0, 0),
						case get("tempName") of
							[]->
								put("tempName",  io_lib:format("~s", [PlayerName]) );
							_->
								put("tempName",  io_lib:format("~s,~s", [get("tempName"),PlayerName]) )
						end,
						put("HarmRankID",get("HarmRankID")+1);
					RandID>?AwardPlayerNum -> 
						ok
				end
			  end
						, HarmList),
			BroadcastAwardSecond=io_lib:format("~s ~s", [get("tempName"),?BroadcastWorldBossAwardSecond]),
			systemMessage:sendSysMsgToAllPlayer(BroadcastAwardSecond),
	
	
			put("tempName",""),
			%%随机奖励
			case erlang:length(HarmList)> ?AwardPlayerNum of
				false ->
					ok;
				true->
					HarmListTail=lists:sublist(HarmList, ?AwardPlayerNum+1, erlang:length(HarmList)-?AwardPlayerNum),
					lists:foreach(
							fun(#worldBossharmInfo{playerID=_PlayerID,playerName=PlayerName} =LowHarmPlayer)->
									case lists:member(LowHarmPlayer, RandAward) of
											true->
													case get("tempName") of
														[]->
															put("tempName",  io_lib:format("~s", [PlayerName]) );
														_->
															put("tempName",  io_lib:format("~s,~s", [get("tempName"),PlayerName]) )
													end,
													mail:sendSystemMailToPlayer(_PlayerID, ?WorldBossMailSender,?WorldBossMailHead, ?WorldBossMailRandom,
															 BossInfo#worldBossCfg.luckitem, BossInfo#worldBossCfg.lucknum, true, 0, 0, 0, 0);
											_->
											mail:sendSystemMailToPlayer(_PlayerID, ?WorldBossMailSender,?WorldBossMailHead, ?WorldBossMailRandom,
															 ?WorldBossAwardItemofJoin, 1, true, 0, 0, 0, 0)
									end
							end,HarmListTail),
					BroadcastAwardLast=io_lib:format("~s ~s", [get("tempName"),?BroadcastWorldBossAwardGoodLucky]),
					systemMessage:sendSysMsgToAllPlayer(BroadcastAwardLast),
					ok
			end,

	QHarmList = ets:fun2ms( 
	fun(#worldBossharmInfo{playerID=_PlayerID, harmData=_HarmData,mapPID=_MapPID}=_HarmInfo)
			when MapPID=:=_MapPID ->
				_HarmInfo
				end
			),
	HarmTable=get("HarmTable"),
	HarmListOriginal = ets:select(HarmTable, QHarmList),
	
	FuncDaily = fun( PlayerInfo )->
						case player:getPlayerPID(PlayerInfo#worldBossharmInfo.playerID) of
							0->ok;
							PlayerPID->
								%%日常检测
								PlayerPID ! {  dailyCheck, ?DailyType_WordBoss, BossInfo#worldBossCfg.bossid }
						end
				end,
	lists:foreach(FuncDaily, HarmListOriginal),
	

	ok.
on_activeOneBoss(MapPID)->
	case ets:lookup(get("worldBossDetailTable"), MapPID) of
		[]->
			ets:insert( get("worldBossDetailTable") , #worldBossStatus{mapPID=MapPID,isKilled=false,gS2U_RankList={}});
		_->
			ok
	end,
	ok.

on_sendRankInfo(PlayerID,MapPID,Viewed,Socket)->
	?DEBUG_OUT( "on_sendRankInfo enter" ),
	WorldBossLastViewMark=Viewed,
	NowMark=bossViewTimeMark(),
	case WorldBossLastViewMark of
		undefined->
			sendRankInfoFun(PlayerID,MapPID,Socket);
		_->
			case WorldBossLastViewMark<NowMark of
				true->
					sendRankInfoFun(PlayerID,MapPID,Socket);
				false->
					case get("HavingActive") of
					 	true->
							sendRankInfoFun(PlayerID,MapPID,Socket);
						false->
							ok
					end
			end
	end,
	ok.

rankHarmTopten()->
	QBossAppearMap = ets:fun2ms( 
								fun(#worldBossStatus{mapPID=_MapPID,isKilled=_IsKilled}=_KillInfo)->
									_MapPID
								end
								),
	BossAppearList = ets:select(get("worldBossDetailTable"), QBossAppearMap),
	Fun=fun(MapPid)->
			rankHarmTopten(MapPid)
		end,
	lists:foreach(Fun, BossAppearList),
	ok.

rankHarmTopten(MapPID)->
	
	QHarmList = ets:fun2ms( 
		fun(#worldBossharmInfo{playerID=_PlayerID, harmData=_HarmData,mapPID=_MapPID}=_HarmInfo)
				when MapPID=:=_MapPID ->
				_HarmInfo
				end
			),
	HarmTable=get("HarmTable"),
	HarmListOriginal = ets:select(HarmTable, QHarmList),
				
	HarmList=lists:sort(fun( #worldBossharmInfo{harmData=_HarmData1}=_Record1, #worldBossharmInfo{harmData=_HarmData2}=_Record2)-> 
									 _HarmData1 >=_HarmData2  
								 end  
								   , HarmListOriginal),
	%%排名数量
	case erlang:length(HarmList)>=?AwardPlayerNum of
		true->
			RecordNum=?AwardPlayerNum;
		false->
			RecordNum=erlang:length(HarmList)
	end,
	
	%%排出top10

				case erlang:length(HarmList)>=1 of
					true->
						Unit1=lists:nth(1, HarmList),
						Name1=Unit1#worldBossharmInfo.playerName,
						%%Name1="",
						Harm1=Unit1#worldBossharmInfo.harmData;
					false->
						Name1="",
						Harm1=0
				end,
	
				case erlang:length(HarmList)>=2 of
					true->
						Unit2=lists:nth(2, HarmList),
						Name2=Unit2#worldBossharmInfo.playerName,
						%%Name2="",
						Harm2=Unit2#worldBossharmInfo.harmData;
					false->
						Name2="",
						Harm2=0
				end,
	
				case erlang:length(HarmList)>=3 of
					true->
						Unit3=lists:nth(3, HarmList),
						Name3=Unit3#worldBossharmInfo.playerName,
						%%Name3="",
						Harm3=Unit3#worldBossharmInfo.harmData;
					false->
						Name3="",
						Harm3=0
				end,
	
				case erlang:length(HarmList)>=4 of
					true->
						Unit4=lists:nth(4, HarmList),
						Name4=Unit4#worldBossharmInfo.playerName,
						%%Name4="",
						Harm4=Unit4#worldBossharmInfo.harmData;
					false->
						Name4="",
						Harm4=0
				end,
	
				case erlang:length(HarmList)>=5 of
					true->
						Unit5=lists:nth(5, HarmList),
						Name5=Unit5#worldBossharmInfo.playerName,
						%%Name5="",
						Harm5=Unit5#worldBossharmInfo.harmData;
					false->
						Name5="",
						Harm5=0
				end,
	
				case erlang:length(HarmList)>=6 of
					true->
						Unit6=lists:nth(6, HarmList),
						Name6=Unit6#worldBossharmInfo.playerName,
						%%Name6="",
						Harm6=Unit6#worldBossharmInfo.harmData;
					false->
						Name6="",
						Harm6=0
				end,
	
				case erlang:length(HarmList)>=7 of
					true->
						Unit7=lists:nth(7, HarmList),
						Name7=Unit7#worldBossharmInfo.playerName,
						%%Name7="",
						Harm7=Unit7#worldBossharmInfo.harmData;
					false->
						Name7="",
						Harm7=0
				end,
	
				case erlang:length(HarmList)>=8 of
					true->
						Unit8=lists:nth(8, HarmList),
						Name8=Unit8#worldBossharmInfo.playerName,
						%%Name8="",
						Harm8=Unit8#worldBossharmInfo.harmData;
					false->
						Name8="",
						Harm8=0
				end,
	
				case erlang:length(HarmList)>=9 of
					true->
						Unit9=lists:nth(9, HarmList),
						Name9=Unit9#worldBossharmInfo.playerName,
						%%Name9="",
						Harm9=Unit9#worldBossharmInfo.harmData;
					false->
						Name9="",
						Harm9=0
				end,
	
				case erlang:length(HarmList)>=10 of
					true->
						Unit10=lists:nth(10, HarmList),
						Name10=Unit10#worldBossharmInfo.playerName,
						%%Name10="",
						Harm10=Unit10#worldBossharmInfo.harmData;
					false->
						Name10="",
						Harm10=0
				end,
	case ets:lookup(get("worldBossDetailTable"), MapPID) of
		[]->
			%%都没记录，不管
			ok;
		[FirstRecord|_]->
			ets:delete(get("worldBossDetailTable"), MapPID),
			SendList=#pk_GS2U_RankList{mapID=0,rankNum=RecordNum,
										   name1=Name1,harm1=Harm1,name2=Name2,harm2=Harm2,name3=Name3,harm3=Harm3,name4=Name4,harm4=Harm4,name5=Name5,harm5=Harm5,
										   name6=Name6,harm6=Harm6,name7=Name7,harm7=Harm7,name8=Name8,harm8=Harm8,name9=Name9,harm9=Harm9,name10=Name10,harm10=Harm10},
			
			NewRecord=FirstRecord#worldBossStatus{ gS2U_RankList=SendList},
			ets:insert(get("worldBossDetailTable") , NewRecord)
	end,
	HarmList.

sendRankInfoFun(PlayerID,MapPID,Socket)->
	PlayerPID = player:getPlayerPID(PlayerID),
	
	WorldBossInfo=getBossInfo(),	
	MapID=WorldBossInfo#worldBossCfg.mapid,
	
	%%具体的排名信息
	case ets:lookup(get("worldBossDetailTable"), MapPID) of
		[]->
			%%都没记录,给发 个空的排名过去
			 SendList=#pk_GS2U_RankList{mapID=MapID,rankNum=0,
										   name1="",harm1=0,name2="",harm2=0,name3="",harm3=0,name4="",harm4=0,name5="",harm5=0,
										   name6="",harm6=0,name7="",harm7=0,name8="",harm8=0,name9="",harm9=0,name10="",harm10=0},
			 msg_player:send(Socket, SendList),
			ok;
		[FirstRecord|_]->
			 case 	FirstRecord#worldBossStatus.gS2U_RankList of
				 {}->
					 SendList=#pk_GS2U_RankList{mapID=MapID,rankNum=0,
										   name1="",harm1=0,name2="",harm2=0,name3="",harm3=0,name4="",harm4=0,name5="",harm5=0,
										   name6="",harm6=0,name7="",harm7=0,name8="",harm8=0,name9="",harm9=0,name10="",harm10=0};
				_->
				SendList=FirstRecord#worldBossStatus.gS2U_RankList#pk_GS2U_RankList{mapID=MapID}
			end,
			
			msg_player:send(Socket, SendList),
			%% 活动结束了，那么发消息说世界boss 榜单你看过了

			FirstBroadcastTime=WorldBossInfo#worldBossCfg.starttime,%%公告开始时间
			EndBroadcastTime=WorldBossInfo#worldBossCfg.overtime,
			CurrentTime=common:getNowSeconds() rem 86400,
			case CurrentTime=<EndBroadcastTime andalso CurrentTime>= FirstBroadcastTime of
				true->
					ok;
				false->
					PlayerPID!{viewedWorldBoss,bossViewTimeMark()}
			end
	end,
	ok.

bossViewTimeMark()->
	{{Year,Month,Day},{_Hour,_Minute,_Second}}=calendar:now_to_local_time(erlang:now()),
	WorldBossInfo=getBossInfo(),
	CurrentTime=common:getNowSeconds() rem 86400,
	case CurrentTime<WorldBossInfo#worldBossCfg.starttime of
		true->
			Date=Year*365+Month*12+Day;%%数值唯一就行，不一定要正确
		false->
			Date=Year*365+Month*12+Day+1
	end,
	Date.

%%活动配置
loadPartyCfg()->
	case db:openBinData( "party_exp.bin" ) of
		[] ->
			?ERROR_OUT( "loadActiveCfg error party_exp = []" );
		PartyDataBin ->
			db:loadBinData( PartyDataBin, partyCfg ),
			
			PartyCfgTable = ets:new( 'globlePartyCfgTable', [protected, named_table, {read_concurrency,true}, { keypos, #partyCfg.level }] ),
			
			PartyCfgList = db:matchObject(partyCfg,  #partyCfg{_='_'} ),
			
			MyFunc = fun( Record )->
							 etsBaseFunc:insertRecord(PartyCfgTable, Record)
					 end,
			lists:map( MyFunc, PartyCfgList ),
			?DEBUG_OUT( "load party_exp.bin succ" )
	end,

	db:loadOffsetString("party_boss.str"),
	case db:openBinData( "party_boss.bin" ) of
		[] ->
			?ERROR_OUT( "loadActiveCfg error party_boss = []" );
		BossConfigDataBin ->
			db:loadBinData( BossConfigDataBin, worldBossCfg ),
			
			BossCfgTable = ets:new( 'globleBossCfgTable', [protected, named_table,{read_concurrency,true},  { keypos, #worldBossCfg.number }] ),
			
			
			BossCfgList = db:matchObject(worldBossCfg,  #worldBossCfg{_='_'} ),
			
			MyFunc2 = fun( Record )->
							  put("tempPosList",[]),
							  
							  Position1=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy1),
							  put("tempPosList",[Position1]++get("tempPosList")),
							  
							  Position2=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy2),
							  put("tempPosList",[Position2]++get("tempPosList")),
							  
							  Position3=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy3),
							  put("tempPosList",[Position3]++get("tempPosList")),
							  
							  Position4=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy4),
							  put("tempPosList",[Position4]++get("tempPosList")),
							  
							  Position5=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy5),
							  put("tempPosList",[Position5]++get("tempPosList")),
							  
							  Position6=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy6),
							  put("tempPosList",[Position6]++get("tempPosList")),
							  
							  Position7=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy7),
							  put("tempPosList",[Position7]++get("tempPosList")),
							  
							  Position8=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy8),
							  put("tempPosList",[Position8]++get("tempPosList")),
							  
							  Position9=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy9),
							  put("tempPosList",[Position9]++get("tempPosList")),
							  
							  Position10=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy10),
							  put("tempPosList",[Position10]++get("tempPosList")),
							  
							  Position11=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy11),
							  put("tempPosList",[Position11]++get("tempPosList")),
							  
							  Position12=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy12),
							  put("tempPosList",[Position12]++get("tempPosList")),
							  
							  Position13=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy13),
							  put("tempPosList",[Position13]++get("tempPosList")),
							  
							  Position14=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy14),
							  put("tempPosList",[Position14]++get("tempPosList")),
							  
							  Position15=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy15),
							  put("tempPosList",[Position15]++get("tempPosList")),
							  
							  Position16=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy16),
							  put("tempPosList",[Position16]++get("tempPosList")),
							  
							  Position17=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy17),
							  put("tempPosList",[Position17]++get("tempPosList")),
							  
							  Position18=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy18),
							  put("tempPosList",[Position18]++get("tempPosList")),
							  
							  Position19=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy19),
							  put("tempPosList",[Position19]++get("tempPosList")),
							  
							  Position20=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy20),
							  put("tempPosList",[Position20]++get("tempPosList")),
							  
							  Position21=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy21),
							  put("tempPosList",[Position21]++get("tempPosList")),
							  
							  Position22=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy22),
							  put("tempPosList",[Position22]++get("tempPosList")),
							  
							  Position23=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy23),
							  put("tempPosList",[Position23]++get("tempPosList")),
							  
							  Position24=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy24),
							  put("tempPosList",[Position24]++get("tempPosList")),
							  
							  Position25=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy25),
							  put("tempPosList",[Position25]++get("tempPosList")),
							  
							  Position26=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy26),
							  put("tempPosList",[Position26]++get("tempPosList")),
							  
							  Position27=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy27),
							  put("tempPosList",[Position27]++get("tempPosList")),
							  
							  Position28=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy28),
							  put("tempPosList",[Position28]++get("tempPosList")),
							  
							  Position29=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy29),
							  put("tempPosList",[Position29]++get("tempPosList")),
							  
							  Position30=parseSmallMonsterComePos("party_boss.str",Record#worldBossCfg.resfreshxy30),
							  put("tempPosList",[Position30]++get("tempPosList")),
							  
							  %%把这些坐标都保存到resfreshxy1
							  _Record2=Record#worldBossCfg{resfreshxy1=get("tempPosList")},
							  etsBaseFunc:insertRecord(BossCfgTable, _Record2)
					 end,
			lists:map( MyFunc2, BossCfgList ),
			?DEBUG_OUT( "load party_boss.bin succ" )
	end.

	%%小怪位置解析
parseSmallMonsterComePos(StringInput,StringPos)->
	
	StringPosx = db:getOffsetString(StringPos,StringInput),
	PosTokenList=string:tokens(StringPosx, ","),
	case length(PosTokenList) >=2 of
		true->
			{PosX,_}=string:to_integer( lists:nth(1, PosTokenList) ),
			{PosY,_}=string:to_integer( lists:nth(2, PosTokenList) );
		_->
			PosX=0,
			PosY=0
	end,
	Result=#posInfo{x=PosX,y=PosY},
	Result.

isAllBossKill()->
	%%有多少个boss 被杀掉
	QBossKill = ets:fun2ms( 
				  			fun(#worldBossStatus{mapPID=_MapPID,isKilled=_IsKilled}=_KillInfo)
								 
								 when  _IsKilled=:= true ->
									_KillInfo
							 end
							   ),
	BossKillList = ets:select(get("worldBossDetailTable"), QBossKill),
	BossKillNum=erlang:length(BossKillList),
	
	%%总共刷了多少个boss
	QBossAll = ets:fun2ms( 
				  			fun(#worldBossStatus{mapPID=_MapPID,isKilled=_IsKilled}=_KillInfo)->
								 
								 _KillInfo
							 end
							   ),
	BossAllList = ets:select(get("worldBossDetailTable"), QBossAll),
	BossRereshNum=erlang:length(BossAllList),
	case BossRereshNum=<0 of 
		true->
			Result=false;
		false->
			Result=BossKillNum>=BossRereshNum
	end,
	Result.

addTicker()->
	Current=common:getNowSeconds() rem 86400,
	NextMinute=60- Current rem 60,
	erlang:send_after(NextMinute*1000,self(),{worldbossTickerID} ).

handle_Tick()->
	addTicker(),
	Current=common:getNowSeconds() rem 86400,
	sendBroadCastBeforeActive(Current),
	activeWorldBoss(Current),
	sendBroadCastDuringActive(Current),
	worldBossEnd(Current),
	ok.
addExpTimer()->
	case get("HavingActive") of
		true->
			erlang:send_after(?GaveExpInterval*1000, worldBossManagerPID, {worldBossGaveExpTimer});
		false->
			ok
	end.