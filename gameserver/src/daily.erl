
-module(daily).

-include("db.hrl").
-include("mapDefine.hrl").
-include("vipDefine.hrl").
-include("hdlt_logger.hrl").
-include("daily.hrl").
-include("package.hrl").
-include("playerDefine.hrl").
-include("logdb.hrl").
-include("textDefine.hrl").
-include("globalDefine.hrl").


-compile(export_all).

loadDailyCfg()->
	case db:openBinData( "daily.bin" ) of
		[] ->
			?ERROR_OUT( "loadDaily openBinData daily.bin failed!" );
		Data ->
			db:loadBinData(Data, dailyCfg),

			ets:new( ?DailyCfgTableAtom, [set,protected, named_table,{read_concurrency,true},  { keypos, #dailyCfg.id }] ),
			DailyCfgList = db:matchObject(dailyCfg, #dailyCfg{_='_'}),
			MyFun = fun(Record) ->
							etsBaseFunc:insertRecord(?DailyCfgTableAtom, Record)
					end,
			lists:map(MyFun, DailyCfgList),
			%db:changeFiled(globalMain, ?GlobalMainID, #globalMain.dailyCfgTable, DailyCfgTable),
			?DEBUG_OUT( "daily daily.bin load succ" )
	end,
	
	case db:openBinData("active_type.bin") of
		[]->
			?ERROR_OUT( "loadDaily openBinData active_type.bin failed!" );
		TypeData->
			db:loadBinData(TypeData, dailyTargetCfg),
			DailyTargetCfgList = db:matchObject(dailyTargetCfg, #dailyTargetCfg{_='_'}),
			
			put( "TempArray", array:new(?DailyType_Num+1, {default, 0})),
			FunFor = fun( Index )->
							 Table = ets:new(?MODULE, [protected, {keypos, #daliyTargetTypeCfg.dailyID}]),
							 put( "TempArray", array:set(Index, Table, get("TempArray") ) )
					 end,
			common:for(1, ?DailyType_Num, FunFor),
			
			TypeArray = get( "TempArray" ),
			etsBaseFunc:changeFiled(?GlobalMainAtom, ?GlobalMainID, #globalMain.dailyTargetTypeTable, TypeArray),
			
			FunCfg = fun( TypeCfg )->
							 case TypeCfg#dailyTargetCfg.type > ?DailyType_Num of
								 false->
									 Table = array:get(TypeCfg#dailyTargetCfg.type, TypeArray),
									 case etsBaseFunc:readRecord(Table, TypeCfg#dailyTargetCfg.dailyID) of
										 {}->
											 Data2 = #daliyTargetTypeCfg{dailyID=TypeCfg#dailyTargetCfg.dailyID, dailyList=[TypeCfg]},
											 etsBaseFunc:insertRecord(Table, Data2);
										 DailyTypeData->
											 Data2 = DailyTypeData#daliyTargetTypeCfg{dailyList=DailyTypeData#daliyTargetTypeCfg.dailyList ++ [TypeCfg] },
											 etsBaseFunc:insertRecord(Table, Data2)
									 end;
								 _->ok
							 end
					 end,
			lists:foreach(FunCfg, DailyTargetCfgList),
			?DEBUG_OUT( "daily active_type.bin load succ" )
	end.

%%创建玩家初始化一条日常玩家日常
onPlayerCreatedDailyInit(PlayerID)->
	put( "DailyFinishList", [] ),
	FunFor = fun( DailyCfg )->
					 Data = #dailyFinishCount{
									   dailyID=DailyCfg#dailyCfg.dailyID,
									   count=0},
					 put( "DailyFinishList", get( "DailyFinishList" )++[Data] )
			 end,
	etsBaseFunc:etsFor(main:getGlobalDailyCfgTable(), FunFor),
	
	TodayBegin = common:getTodayBeginSeconds(),
	Now = common:getNowSeconds(),
	case Now >= (TodayBegin+4*60*60) of
		true->
			ResetTime = TodayBegin + 28*60*60;
		_->
			ResetTime = TodayBegin + 4*60*60
	end,
	PlayerDaily = #playerDaily{
							   playerID = PlayerID,
							   activeValue = 0,
							   resetTime = ResetTime,
							   dailyList = get( "DailyFinishList" )},
	mySqlProcess:insertOrReplacePlayerDaily(PlayerDaily,true).

%%玩家上线初始化日常数据
onPlayerOnLineDailyInit(DailyList)->
	case DailyList of
		[]->%%没有日常数据，初始化
			onPlayerCreatedDailyInit(player:getCurPlayerID()),
			[Daily|_] = mySqlProcess:get_playerDailyListByPlayerID(player:getCurPlayerID()),
			put( "PlayerDaliyCountInfo",  Daily),
			ok;
		_->
			[Daily|_] = DailyList,
			put( "DailyFinishList", [] ),
			FunFor = fun( DailyCfg )->
							 case lists:keyfind( DailyCfg#dailyCfg.dailyID, #dailyFinishCount.dailyID, Daily#playerDaily.dailyList ) of
								 false->
									 Data = #dailyFinishCount{
															  dailyID=DailyCfg#dailyCfg.dailyID,
															  count=0},
									 put( "DailyFinishList", get("DailyFinishList") ++ [Data] );
								 DailyCount->
									 put( "DailyFinishList", get("DailyFinishList") ++ [DailyCount] )
							 end
					 end,
			etsBaseFunc:etsFor(main:getGlobalDailyCfgTable(), FunFor),
			put( "PlayerDaliyCountInfo", #playerDaily{playerID=Daily#playerDaily.playerID, activeValue=Daily#playerDaily.activeValue, resetTime=Daily#playerDaily.resetTime, dailyList=get("DailyFinishList")} )
	end.

getDailyCountInfo()->
	PlayerDailyData = get( "PlayerDaliyCountInfo" ),
	Now = common:getNowSeconds(),
	case PlayerDailyData#playerDaily.resetTime =< Now of
		true-> %%已经过了重置时间，重置日常数据
			Func = fun(Count)->
						   #dailyFinishCount{ dailyID=Count#dailyFinishCount.dailyID, count=0}
				   end,
			List = lists:map(Func, PlayerDailyData#playerDaily.dailyList),
			TodayBegin = common:getTodayBeginSeconds(),
			Now = common:getNowSeconds(),
			case Now >= (TodayBegin+4*60*60) of
				true->
					ResetTime = TodayBegin + 28*60*60;
				_->
					ResetTime = TodayBegin + 4*60*60
			end,
			PlayerDailyData2 = PlayerDailyData#playerDaily{resetTime=ResetTime, dailyList=List},
			put( "PlayerDaliyCountInfo",  PlayerDailyData2);
		_->ok
	end,
	get( "PlayerDaliyCountInfo" ).

%%日常完成检测
onDailyFinishCheck( TypeID, DataID )->
	try
		Table = main:getDailyTargetCfgByType(TypeID),
		case Table of
			0->throw(-1);
			_->ok
		end,
		
		PlayerDailyData = getDailyCountInfo(),
		
		Max_ActiveValue = globalSetup:getGlobalSetupValue(#globalSetup.max_ActiveValue),
		
		Fun = fun( Daily )->
					  case lists:keyfind(DataID, #dailyTargetCfg.data_id, Daily#daliyTargetTypeCfg.dailyList) of
						  false->ok;
						  TargetCfg->
							  DailyID = TargetCfg#dailyTargetCfg.dailyID,
							  DailyCfg = etsBaseFunc:readRecord(main:getGlobalDailyCfgTable(), DailyID ),
							  case DailyCfg of
								  {}->throw(-1);
								  _->ok
							  end,
							  case lists:keyfind(DailyID, #dailyFinishCount.dailyID, PlayerDailyData#playerDaily.dailyList) of
								  false->throw(-1);
								  PlayerDailyCount->
									  case PlayerDailyCount#dailyFinishCount.count >= DailyCfg#dailyCfg.protimes of
										  true->	%%收益次数已满，不再增加活跃度
											  throw(-1);
										  _->
											  %%增加活跃度，并且增加收益次数

											  %%活跃度上限判定
											  case (PlayerDailyData#playerDaily.activeValue + DailyCfg#dailyCfg.active) >= Max_ActiveValue of
												  true->ActiveValue = Max_ActiveValue;
												  _->
													  ActiveValue = PlayerDailyData#playerDaily.activeValue + DailyCfg#dailyCfg.active
											  end,
											  PlayerDailyCount2 = PlayerDailyCount#dailyFinishCount{count=PlayerDailyCount#dailyFinishCount.count+1},
											  NewList = lists:keyreplace(DailyID, #dailyFinishCount.dailyID, PlayerDailyData#playerDaily.dailyList, PlayerDailyCount2),
											  put( "PlayerDaliyCountInfo", PlayerDailyData#playerDaily{activeValue=ActiveValue, dailyList=NewList} ),
											  throw(-1)
									  end
							  end,
							  ok
					  end
			  end,
		etsBaseFunc:etsFor(Table, Fun),
		ok
	catch
		_ ->
			ok
	end.

%%处理玩家请求活跃值数据
on_U2GS_RequestActiveCount()->
	PlayerDailyData = getDailyCountInfo(),
	Fun = fun(Count)->
				  #pk_ActiveCountData{daily_id=Count#dailyFinishCount.dailyID, count=Count#dailyFinishCount.count}
		  end,
	List = lists:map(Fun, PlayerDailyData#playerDaily.dailyList),
	Msg = #pk_GS2U_ActiveCount{ activeValue=PlayerDailyData#playerDaily.activeValue, dailyList=List},
	player:send(Msg).

%%处理玩家请求兑换活跃值
on_U2GS_RequestConvertActive()->
	try
		Cfg = etsBaseFunc:readRecord(main:getGlobalPartyCfgTable(), player:getCurPlayerProperty(#player.level)),
		case Cfg of
			{}->throw(-1);
			_->ok
		end,
		
		PlayerDailyData = getDailyCountInfo(),
		case PlayerDailyData#playerDaily.activeValue =< 0 of
			true->		%%没有活跃值进行兑换
				systemMessage:sendErrMessageToMe(?DAILYCONVERT_NOTHAVEACTIVEVALUE),
				throw(-1);
			_->ok
		end,
		
		Exp = PlayerDailyData#playerDaily.activeValue * Cfg#partyCfg.active_exp,
	
		%% VIP活跃度经验加成 add by yueliangyou [2013-05-13]	
		{Result,Exp0} = vipFun:callVip(?VIP_FUN_EXP_ACTIVE,Exp),
		?DEBUG_OUT("vipFun:callVip(?VIP_FUN_EXP_ACTIVE),Exp=~p,Exp0=~p",[Exp,Exp0]),
		%%增加经验
		ParamTuple = #exp_param{changetype = ?Exp_Change_Active},	
		player:addPlayerEXP(Exp0, ?Exp_Change_Active, ParamTuple),
		
		case Result =:= ok of
			false->
				Text = io_lib:format(?DAILYCONVERT_ADDEXP, [Exp0]),
				Text2 = lists:flatten(Text),
				systemMessage:sendTipsMessageToMe(Text2);
			_->
				Text = io_lib:format(?DAILYCONVERT_ADDEXPVIP, [vip:getVipName(), Exp, Exp0-Exp, Exp0]),
				Text2 = lists:flatten(Text),
				systemMessage:sendTipsMessageToMe(Text2)
		end,
		
		%%扣除活跃值
		PlayerDailyData2 = PlayerDailyData#playerDaily{activeValue=0},
		put( "PlayerDaliyCountInfo", PlayerDailyData2 ),
		
		%%发送新的活跃值数据
		on_U2GS_RequestActiveCount(),
		ok
	catch
		_->ok
end.
