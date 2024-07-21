-module(reasureBowl).

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
-include("gamedatadb.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("daily.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

-define(CommonReasureBowlGive, 1). %%普通获取
-define(SmallCritReasureBowlGive, 2). %%小暴击获取
-define(BigCritReasureBowlGive, 3). %%大暴击获取

-define(ReasureBowlMaxCntOfDay, 20). %%每天能使用的最大值
-define(ReasureBowlResetTimer, 4*3600). %%每天重置时间


%%返回的错误信息
-define(Give_ReasureBowl_Succ, 1). %%成功
-define(Give_ReasureBowl_Failed_Of_Max_Cnt, 2). %%已达到最大值
-define(Give_ReasureBowl_Failed_Of_Cost, 3). %%手续费不足
-define(Give_ReasureBowl_Failed_Of_Max_Money, 4). %%铜币已经是最大值

initReasureBowlData() ->
	#reasureBowlData{curUseCnt=0, curExp=0, curLevel=0, resetTimer=0}.

initPlayerOnLine(ReasureBowlDataIn) ->
	case ReasureBowlDataIn of
		{}->ReasureBowlData=initReasureBowlData();
		_->ReasureBowlData=ReasureBowlDataIn
	end,
	ReasureBowlExp = ReasureBowlData#reasureBowlData.curExp,
	ReasureBowlLevel = ReasureBowlData#reasureBowlData.curLevel,
	ReasureBowlUseCnt = ReasureBowlData#reasureBowlData.curUseCnt,
	ReasureBowlResetTimer = ReasureBowlData#reasureBowlData.resetTimer,
	saveReasureBowlExpToWorkBook(ReasureBowlExp), %%当前经验
	saveReasureBowlUseCntToWorkBook(ReasureBowlUseCnt), %%当天聚宝盆使用次数
	case ReasureBowlLevel =:= 0 of
		true -> saveReasureBowlLevelToWorkBook(1); %%当前等级
		false -> saveReasureBowlLevelToWorkBook(ReasureBowlLevel)
	end,
	put("CheckTimer", ReasureBowlResetTimer),

	%%初始一些全局数据
	CommonReasureBowlScale = globalSetup:getGlobalSetupValue( #globalSetup.commonGold ),
	SmallCritReasureBowlScale = globalSetup:getGlobalSetupValue( #globalSetup.smallCritGold ),
	BigCritReasureBowlScale = globalSetup:getGlobalSetupValue( #globalSetup.bigCritGold ),
	CommonReasureBowlTimes = globalSetup:getGlobalSetupValue( #globalSetup.commonGoldScale ),
	SmallCritReasureBowlTimes = globalSetup:getGlobalSetupValue( #globalSetup.smallCritGoldScale ),
	BigCritReasureBowlTimes = globalSetup:getGlobalSetupValue( #globalSetup.bigCritGoldScale ),
	put("ReasureBowl_CommonScaleWorkBook", CommonReasureBowlScale),
	put("ReasureBowl_SmallScaleCritWorkBook", SmallCritReasureBowlScale),
	put("ReasureBowl_BigScaleCritWorkBook", BigCritReasureBowlScale),
	put("ReasureBowl_CommonTimesWorkBook", CommonReasureBowlTimes),
	put("ReasureBowl_SmallCritGoldTimesWorkBook", SmallCritReasureBowlTimes),
	put("ReasureBowl_BigCritGoldTimesWorkBook", BigCritReasureBowlTimes),
	player:send(#pk_U2GS_GoldLineInfo{useCnt = ReasureBowlUseCnt, exp = ReasureBowlExp, level = getReasureBowlLevel()}).

checkoutTimer() ->
	try
		CheckTimer = get("CheckTimer"),
		case CheckTimer of
			undefined -> 
				throw(-1);
			_ -> 
				TodayResetTime = common:getTodayBeginSeconds()+?ReasureBowlResetTimer,
				Now = common:getNowSeconds(),
				case Now > TodayResetTime of
					true ->ResetTime = TodayResetTime + 24*60*60;
					false ->ResetTime = TodayResetTime
				end,

				case CheckTimer =:= 0 of %%新角色
					true -> 
						put("CheckTimer", ResetTime),
						false;
					false ->
						case CheckTimer =< Now of %%重置
							true ->
								saveReasureBowlUseCntToWorkBook(0),
								put("CheckTimer", ResetTime),
								true;
							false -> false
						end
				end
		end						
	catch
		_ -> false
	end.

questGiveReasureBowlCheck(#pk_U2GS_QequestGiveGoldCheck{}) ->
	try		
		case checkoutTimer() of %%重置时间
			true ->
				ReasureBowlData = #reasureBowlData{curUseCnt=getReasureBowlUseCnt(), curExp=getReasureBowlExp(), 
												   curLevel=getReasureBowlLevel(), resetTimer=get("CheckTimer")},
				player:setCurPlayerProperty(#player.reasureBowlData, ReasureBowlData);
			false -> ok
		end,
		player:send(#pk_U2GS_GoldResetTimer{useCnt = getReasureBowlUseCnt()})		
	catch
		_ ->ok
	end.
  
useReasureBowl(#pk_U2GS_StartGiveGold{}) ->
	try
		checkoutTimer(),
		Player = player:getCurPlayerRecord(),
		case Player of
			{}->throw(-1);
			_-> ok
		end,
		CommonProbabilityScale = get("ReasureBowl_CommonScaleWorkBook"),
		SmallProbabilityScale = get("ReasureBowl_SmallScaleCritWorkBook")+CommonProbabilityScale,
		BigProbabilityScale = get("ReasureBowl_BigScaleCritWorkBook")+SmallProbabilityScale,
		CommonReasureBowlTimesValue = get("ReasureBowl_CommonTimesWorkBook"),
		SmallCritReasureBowlTimesValue = get("ReasureBowl_SmallCritGoldTimesWorkBook"),
		BigCritReasureBowlTimesValue = get("ReasureBowl_BigCritGoldTimesWorkBook"),
		
		CurUseReasureBowlCnt = getReasureBowlUseCnt(), %%当天使用的次数
		case CurUseReasureBowlCnt of
			undefined -> throw(-1);
			_ -> ok
		end,
		case CurUseReasureBowlCnt >= ?ReasureBowlMaxCntOfDay of %%超过使用次数
			true ->
				player:send(#pk_U2GS_StartGiveGoldResult{goldType = 0, useCnt = getReasureBowlUseCnt(), exp = 0, level = 0, awardMoney = 0, retCode = ?Give_ReasureBowl_Failed_Of_Max_Cnt}),
				throw(-1);
			false ->ok
		end,
		case CurUseReasureBowlCnt > 0 of
			true -> CurUseReasureBowlTempCnt = CurUseReasureBowlCnt+1;
			false -> CurUseReasureBowlTempCnt = 1
		end,
	
		%% 手续费检查
		GoldneedCfg = getGoldCntByTimes(CurUseReasureBowlTempCnt),
		case GoldneedCfg of
			{} -> throw(-1);
			_ ->
				CurCostReasureBowl = GoldneedCfg#goldneedCfg.goldneed,
				case CurCostReasureBowl > 0 of
					false -> ok; %%免费不用扣除
					true -> 
						CurPlayBindGold = Player#player.goldBinded, %%先检查绑定元宝
						case CurPlayBindGold >= CurCostReasureBowl of
							true -> ok;
							false ->
								CurPlayGold = Player#player.gold, %%绑定元宝不足时扣除普通元宝
								case CurPlayGold >= CurCostReasureBowl of
									false -> 
										case CurPlayBindGold+CurPlayGold >= CurCostReasureBowl of %%两个之和再进行比较
											true -> ok;
											false ->
												player:send(#pk_U2GS_StartGiveGoldResult{goldType = 0, useCnt = 0, exp = 0, level = 0, awardMoney = 0, retCode = ?Give_ReasureBowl_Failed_Of_Cost}),
												throw(-1)
										end;
									true -> ok
								end
						end
				end
		end,
		
		PlayReasureBowlRealLevel = getReasureBowlLevel(),
		case PlayReasureBowlRealLevel of
			undefined -> throw(-1);
			_ -> ok
		end,	
		GoldupgradeCfg = getGoldupgradeInfoByLevel(PlayReasureBowlRealLevel),
		case GoldupgradeCfg of
			{} -> throw(-1);
			_ -> ok
		end,
		
		Rand = random:uniform(10000),
		AwardRate = GoldneedCfg#goldneedCfg.goldrate, %%次数不同比例不同
		AwardReasureBowlByLevel = GoldupgradeCfg#goldupgradeCfg.givemoney, %%等级不同奖励不同
		case Rand < CommonProbabilityScale of
			true -> 
				CurAwardBindedMoney = (AwardRate*AwardReasureBowlByLevel*CommonReasureBowlTimesValue) div 10000, %%普通获取
				put("ReasureBowl_CurAwardBindedMoneyValue", CurAwardBindedMoney),
				put("ReasureBowl_CurType", ?CommonReasureBowlGive),
				put("ReasureBowl_AddExp", CommonReasureBowlTimesValue),
				ok;
			false ->
				case Rand < SmallProbabilityScale of
					true -> 
						CurAwardBindedMoney = (AwardRate*AwardReasureBowlByLevel*SmallCritReasureBowlTimesValue) div 10000, %%小暴击
						put("ReasureBowl_CurAwardBindedMoneyValue", CurAwardBindedMoney),
						put("ReasureBowl_CurType", ?SmallCritReasureBowlGive),
						put("ReasureBowl_AddExp", SmallCritReasureBowlTimesValue),
						ok;
					false ->
						case Rand =< BigProbabilityScale of
							true -> 
								CurAwardBindedMoney = (AwardRate*AwardReasureBowlByLevel*BigCritReasureBowlTimesValue) div 10000, %%大暴击
								put("ReasureBowl_CurAwardBindedMoneyValue", CurAwardBindedMoney),
								put("ReasureBowl_CurType", ?BigCritReasureBowlGive),
								put("ReasureBowl_AddExp", BigCritReasureBowlTimesValue),
								ok;
							false ->
								throw(-1)
						end
				end
		end,
		
		AwardBindedMoney = get("ReasureBowl_CurAwardBindedMoneyValue"), %%当前奖励的金钱
		case AwardBindedMoney of
			undefined -> throw(-1);
			_ -> ok
		end,
		CurAddExp = get("ReasureBowl_AddExp"), %%当前奖励的经验
		case CurAddExp of
			undefined -> throw(-1);
			_ -> ok
		end,
		PlayReasureBowlRealExp = getReasureBowlExp(), %%玩家聚宝盆真实经验
		case PlayReasureBowlRealExp of
			undefined -> throw(-1);
			_ -> ok
		end,
		PlayReasureBowlType = get("ReasureBowl_CurType"),
		case PlayReasureBowlType of
			undefined -> throw(-1);
			_ -> ok
		end,	
		
		case playerMoney:canAddPlayerBindedMoney(AwardBindedMoney) of %%检查是否能增加金钱
			true -> ok;
			false ->
				player:send(#pk_U2GS_StartGiveGoldResult{goldType = 0, useCnt = 0, exp = 0, level = 0, awardMoney = 0, retCode = ?Give_ReasureBowl_Failed_Of_Max_Money}),
				throw(-1)
		end,
		
		%%扣手续费
		ParamTuple1 = #token_param{changetype = ?Money_Change_Gold},
		PlayBagGold = Player#player.gold,
		PlayBagBindGold = Player#player.goldBinded,
		CostReasureBowlValue = GoldneedCfg#goldneedCfg.goldneed,
		case PlayBagBindGold >= CostReasureBowlValue of
			true -> playerMoney:decPlayerBindedGold(CostReasureBowlValue, ?Money_Change_Gold, ParamTuple1); %%绑定元宝足够
			false ->
				case PlayBagGold+PlayBagBindGold >= CostReasureBowlValue of
					true ->
						playerMoney:decPlayerBindedGold(PlayBagBindGold, ?Money_Change_Gold, ParamTuple1), %%先扣除绑定元宝
						RemainCostGold = CostReasureBowlValue-PlayBagBindGold, %%再扣除普通元宝
						playerMoney:decPlayerGold(RemainCostGold, ?Money_Change_Gold, ParamTuple1); %%普通元宝足够
					false -> 
						player:send(#pk_U2GS_StartGiveGoldResult{goldType = 0, useCnt = 0, exp = 0, level = 0, awardMoney = 0, retCode = ?Give_ReasureBowl_Failed_Of_Cost}),
						throw(-1)
				end
		end,
		
		%%日常检测
		daily:onDailyFinishCheck(?DailyType_JuBaoPen, 0),
		
		%%加奖励
		playerMoney:addPlayerBindedMoney(AwardBindedMoney, ?Money_Change_Gold, ParamTuple1), %%奖励金钱
		PlayReasureBowlCfgExpByLevel = GoldupgradeCfg#goldupgradeCfg.goldexp, %%升级所要的最大经验
		PlayAmoutExp = PlayReasureBowlRealExp+CurAddExp, %%奖励后的总经验
		case (PlayAmoutExp >= PlayReasureBowlCfgExpByLevel) andalso (PlayReasureBowlCfgExpByLevel > 0) of
			true ->
				saveReasureBowlLevelToWorkBook(PlayReasureBowlRealLevel+1),
				saveReasureBowlExpToWorkBook(PlayAmoutExp-PlayReasureBowlCfgExpByLevel);
			false ->
				saveReasureBowlExpToWorkBook(PlayAmoutExp)
		end,
		saveReasureBowlUseCntToWorkBook(CurUseReasureBowlCnt+1),
		SaveCnt = CurUseReasureBowlCnt+1,
		SaveExp = getReasureBowlExp(),
		SaveLevel = getReasureBowlLevel(),
		ReasureBowlData = #reasureBowlData{curUseCnt=SaveCnt, curExp=SaveExp, curLevel=SaveLevel, resetTimer=get("CheckTimer")},
		player:setCurPlayerProperty(#player.reasureBowlData, ReasureBowlData),
		player:send(#pk_U2GS_StartGiveGoldResult{goldType = PlayReasureBowlType, useCnt = SaveCnt, exp = SaveExp, level = SaveLevel, awardMoney = AwardBindedMoney, retCode = ?Give_ReasureBowl_Succ})	
	catch
		_ ->ok
	end.

%% 根据使用次数得到所扣元宝数量
getGoldCntByTimes(Times)->
	try
		Q = ets:fun2ms( fun(Record) when (Record#goldneedCfg.times =:= Times) ->Record end ),
		Result = ets:select(goldneedCfgTableAtom, Q),
		case Result of
		[]->
			{};
		_ ->
			[X|_] = Result,
			X
		end
	catch
		_ ->ok
	end.

%% 根据等级得到对应信息
getGoldupgradeInfoByLevel(Level)->
	try
		Q = ets:fun2ms( fun(Record) when (Record#goldupgradeCfg.goldlevel =:= Level) ->Record end ),
		Result = ets:select(goldupgradeCfgTableAtom, Q),
		case Result of
		[]->
			{};
		_ ->
			[X|_] = Result,
			X
		end
	catch
		_ ->ok
	end.

loadReasureBowlCfg() ->
	try		
		%%初始化聚宝盆相关数据
		case db:openBinData( "goldneed.bin" ) of  %%读取使用聚宝盆费用表
			[] ->
				?ERROR_OUT( "goldneedCfg openBinData goldneed.bin failed!" );
			GoldneedData ->
				db:loadBinData(GoldneedData, goldneedCfg),
				ets:new( goldneedCfgTableAtom, [set,protected,named_table, {read_concurrency,true}, { keypos, #goldneedCfg.id }] ),
				GoldneedCfgDataList = db:matchObject(goldneedCfg, #goldneedCfg{_='_'} ),
				
				Fun = fun( Record ) ->
							etsBaseFunc:insertRecord(goldneedCfgTableAtom, Record)
					  end,
				lists:foreach(Fun, GoldneedCfgDataList),
				?DEBUG_OUT( "goldneedCfgTable load succ" )
		end,
	
		case db:openBinData( "goldupgrade.bin" ) of  %%读取使用聚宝盆升级表
			[] ->
				?ERROR_OUT( "goldupgradeCfg openBinData goldupgrade.bin failed!" );
			GoldupgradeData ->
				db:loadBinData(GoldupgradeData, goldupgradeCfg),
				ets:new( goldupgradeCfgTableAtom, [set,protected,named_table, {read_concurrency,true}, { keypos, #goldupgradeCfg.id }] ),
				GoldupgradeCfgDataList = db:matchObject(goldupgradeCfg, #goldupgradeCfg{_='_'} ),
				
				Fun1 = fun( Record ) ->
							etsBaseFunc:insertRecord(goldupgradeCfgTableAtom, Record)
					  end,
				lists:foreach(Fun1, GoldupgradeCfgDataList),
				?DEBUG_OUT( "goldupgradeCfgTable load succ" )
		end
	catch
		_ ->ok
	end.

saveReasureBowlExpToWorkBook(CurReasureBowlExp) ->
	put("CurReasureBowlExp", CurReasureBowlExp).

saveReasureBowlLevelToWorkBook(CurReasureBowlLevel) ->
	put("CurReasureBowlLevel", CurReasureBowlLevel).

saveReasureBowlUseCntToWorkBook(CurDayReasureBowlUseCnt) ->
	put("CurDayReasureBowlUseCnt", CurDayReasureBowlUseCnt).

getReasureBowlExp() ->
	get("CurReasureBowlExp").

getReasureBowlLevel() ->
	get("CurReasureBowlLevel").

getReasureBowlUseCnt() ->
	get("CurDayReasureBowlUseCnt").