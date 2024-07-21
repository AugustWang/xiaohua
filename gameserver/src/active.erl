-module(active).

-behaviour(gen_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-compile(export_all). 

-include("active.hrl").
-include("hdlt_logger.hrl").
-include_lib("stdlib/include/ms_transform.hrl"). 
-include("db.hrl").
-include("pc_player.hrl").
-include("taskDefine.hrl").
-include("mapDefine.hrl").
-include("vipDefine.hrl").
-include("variant.hrl").
-include("textDefine.hrl").
-include("active_battle.hrl").

start_link()->
 gen_server:start_link( {local,activeManagerPID},?MODULE, [], [ {timeout,600000}] ).
init([]) ->
	%%增加个定时器
	addTicker(),
	%%pk保护
	initPKProctedInfo(),
	%%世界boss 放这里
	worldBoss:start_link(),
	%%采集标志位初始化
	gatherFlagInit(),
	active_battle:start_link(), 
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
	put("active", true),
	try
	case Info of
		{quit}->
			?DEBUG_OUT( "active Recieve quit" ),
			put( "active", false );
		{mapManagerTickerID}->
			addTicker(),
			handle_Tick(),
			ok;
		_->
			?LOG_OUT( "active receive unkown" )
	end,
	
	case get("active") of
		true->{noreply, StateData};
		false->{stop, normal, StateData}
	end
	
	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[?MODULE,_Why, erlang:get_stacktrace()] ),	

			{noreply, StateData}
	end.
%%1分钟一次的定时器
addTicker()->
	Current=common:getNowSeconds() rem 86400,
	NextMinute=60- Current rem 60,
	erlang:send_after(NextMinute*1000,self(),{mapManagerTickerID} ).

handle_Tick()->
	sendNoPkProctBroadcast(),
	resetAllRandomDaily(),
	resetAllReputation(),
	resetVipData(),
	resetAllGather(),
	resetAllConvoy(),
	sendGatherBroadCast(),
	sendConvoyBroadCast(),
	openGatherActive(),
	closeGatherActive(),
	resetCreditLimit(),
	ok.

initPKProctedInfo()->
	{_,{Hour,Minute,Second}}=calendar:now_to_local_time(erlang:now()),
	Current=Hour*3600+Minute*60+Second,
	case (Current >=?PKProctedStartTime) and (Current <?PKProctedEndTime ) of
		true->
			put( "InPKProct", true );
		false->
			put( "InPKProct", false )
	end,
	ok.

%%发送pk保护公告
sendNoPkProctBroadcast()->
	Current=common:getNowSeconds() rem 86400,
	%%进入免战保护
	case (Current >=?PKProctedStartTime)  and (Current <?PKProctedEndTime)of
		true->
			case get("InPKProct") of
				true->
					ok;%%发过啦，不管
				false->
					%%进入免战保护
					put( "InPKProct", true ),
					%%改世界变量
					mainPID!{setWorldVarFlag,?WorldVariant_Index_1, ?WorldVariant_Index_1_PeriodPkProt_Bit0,1},
					ok
			end;
		false ->
			case get("InPKProct") of
				true->
					%%离开免战保护
					put( "InPKProct", false ),
					%%改世界变量
					mainPID!{setWorldVarFlag,?WorldVariant_Index_1, ?WorldVariant_Index_1_PeriodPkProt_Bit0,0},
					ok;
				false->
					%%不管
					ok
			end
	end,
	%%发送公告
	OneDaySecond=24*3600,
	
	EnterPkProctTime5= (OneDaySecond+?PKProctedStartTime- 5*?PKProctedBroadcastInterval)rem OneDaySecond,
	EnterPkProctTime4= (OneDaySecond+?PKProctedStartTime- 4*?PKProctedBroadcastInterval)rem OneDaySecond,
	EnterPkProctTime3= (OneDaySecond+?PKProctedStartTime- 3*?PKProctedBroadcastInterval)rem OneDaySecond,
	EnterPkProctTime2= (OneDaySecond+?PKProctedStartTime- 2*?PKProctedBroadcastInterval)rem OneDaySecond,
	EnterPkProctTime1= (OneDaySecond+?PKProctedStartTime- 1*?PKProctedBroadcastInterval)rem OneDaySecond,
	EnterPkProctTime0= (OneDaySecond+?PKProctedStartTime- 0*?PKProctedBroadcastInterval)rem OneDaySecond,
	EnterPkProctTime00= (OneDaySecond+?PKProctedStartTime+1*?PKProctedBroadcastInterval)rem OneDaySecond,
	case (Current >= EnterPkProctTime5) and (Current < EnterPkProctTime4)of
		true->
			%%发公告
			systemMessage:sendSysMsgToAllPlayer(?EnterPkProct5),
			ok;
		false->
			ok
	end,
	
	case (Current >= EnterPkProctTime4) and (Current < EnterPkProctTime3)of
		true->
			%%发公告
			systemMessage:sendSysMsgToAllPlayer(?EnterPkProct4),
			ok;
		false->
			ok
	end,
	
	case (Current >= EnterPkProctTime3) and (Current < EnterPkProctTime2)of
		true->
			%%发公告
			systemMessage:sendSysMsgToAllPlayer(?EnterPkProct3),
			ok;
		false->
			ok
	end,
	
	case (Current >= EnterPkProctTime2) and (Current < EnterPkProctTime1)of
		true->
			%%发公告
			systemMessage:sendSysMsgToAllPlayer(?EnterPkProct2),
			ok;
		false->
			ok
	end,
	
	case (Current >= EnterPkProctTime1) and (Current < EnterPkProctTime0)of
		true->
			%%发公告
			systemMessage:sendSysMsgToAllPlayer(?EnterPkProct1),
			ok;
		false->
			ok
	end,
	
	case (Current >= EnterPkProctTime0) and (Current < EnterPkProctTime00)of
		true->
			%%发公告
			systemMessage:sendSysMsgToAllPlayer(?EnterPkProct0),
			ok;
		false->
			ok
	end,
	%%离开免战

	LeavePkProctTime5= (OneDaySecond+?PKProctedEndTime- 5*?PKProctedBroadcastInterval)rem OneDaySecond,
	LeavePkProctTime4= (OneDaySecond+?PKProctedEndTime- 4*?PKProctedBroadcastInterval)rem OneDaySecond,
	LeavePkProctTime3= (OneDaySecond+?PKProctedEndTime- 3*?PKProctedBroadcastInterval)rem OneDaySecond,
	LeavePkProctTime2= (OneDaySecond+?PKProctedEndTime- 2*?PKProctedBroadcastInterval)rem OneDaySecond,
	LeavePkProctTime1= (OneDaySecond+?PKProctedEndTime- 1*?PKProctedBroadcastInterval)rem OneDaySecond,
	LeavePkProctTime0= (OneDaySecond+?PKProctedEndTime- 0*?PKProctedBroadcastInterval)rem OneDaySecond,
	LeavePkProctTime00= (OneDaySecond+?PKProctedEndTime+1*?PKProctedBroadcastInterval)rem OneDaySecond,
	case (Current >= LeavePkProctTime5) and (Current < LeavePkProctTime4)of
		true->
			%%发公告
			systemMessage:sendSysMsgToAllPlayer(?LeavePkProct5),
			ok;
		false->
			ok
	end,
	
	case (Current >= LeavePkProctTime4) and (Current < LeavePkProctTime3)of
		true->
			%%发公告
			systemMessage:sendSysMsgToAllPlayer(?LeavePkProct4),
			ok;
		false->
			ok
	end,
	
	case (Current >= LeavePkProctTime3) and (Current < LeavePkProctTime2)of
		true->
			%%发公告
			systemMessage:sendSysMsgToAllPlayer(?LeavePkProct3),
			ok;
		false->
			ok
	end,
	
	case (Current >= LeavePkProctTime2) and (Current < LeavePkProctTime1)of
		true->
			%%发公告
			systemMessage:sendSysMsgToAllPlayer(?LeavePkProct2),
			ok;
		false->
			ok
	end,
	
	case (Current >= LeavePkProctTime1) and (Current < LeavePkProctTime0)of
		true->
			%%发公告
			systemMessage:sendSysMsgToAllPlayer(?LeavePkProct1),
			ok;
		false->
			ok
	end,
	
	case (Current >= LeavePkProctTime0) and (Current < LeavePkProctTime00)of
		true->
			%%发公告
			systemMessage:sendSysMsgToAllPlayer(?LeavePkProct0),
			ok;
		false->
			ok
	end,
ok.

%%随机日常重置相关
resetAllRandomDaily()->
	ResetStartTime=?RandomDailyResetTime,
	ResetEndTime=ResetStartTime+60,%%60是定时器的时间间隔
	Current=common:getNowSeconds() rem 86400,
	case (Current>=ResetStartTime) andalso (ResetEndTime>Current) of
		true->
			%%发消息让所有在线玩家重置
			Broadcast={resetRandomDaily},
			player:sendToAllPlayerProc(Broadcast),
			ok;
		false->
		ok
	end,
ok.

%%VIP重置相关
resetVipData()->
	ResetStartTime=?VIP_RESET_TIME,
	ResetEndTime=ResetStartTime+60,%%60是定时器的时间间隔
	Current=common:getNowSeconds() rem 86400,
	case (Current>=ResetStartTime) andalso (ResetEndTime>Current) of
		true->
			%%发消息让所有在线玩家重置
			Broadcast={resetVipData},
			player:sendToAllPlayerProc(Broadcast),
			ok;
		false->
		ok
	end,
ok.

%%声望重置相关
resetAllReputation()->
	ResetStartTime=?ReputationResetTime,
	ResetEndTime=ResetStartTime+60,%%60是定时器的时间间隔
	Current=common:getNowSeconds() rem 86400,
	case (Current>=ResetStartTime) andalso (ResetEndTime>Current) of
		true->
			%%发消息让所有在线玩家重置
			Broadcast={resetReputation},
			player:sendToAllPlayerProc(Broadcast),
			ok;
		false->
		ok
	end,
ok.

%%采集重置相关，重置了也要把标志位设上
resetAllGather()->
	Current=common:getNowSeconds() rem 86400,
	ResetStartTime=?GatherResetTime,
	ResetEndTime=ResetStartTime+60,%%60是定时器的时间间隔
	case (Current>=ResetStartTime) andalso (ResetEndTime>Current) of
		true->
			%%发消息让所有在线玩家重置
			Broadcast={resetGatherTask},
			player:sendToAllPlayerProc(Broadcast),
			ok;
		false->
		ok
	end,
ok.

%%护送重置相关
resetAllConvoy() ->
	Current=common:getNowSeconds() rem 86400,
	ResetStartTime=?ConvoyResetTime,
	ResetEndTime=ResetStartTime+60,%%60是定时器的时间间隔
	case (Current>=ResetStartTime) andalso (ResetEndTime>Current) of
		true->
			%%发消息让所有在线玩家重置
			Broadcast={resetConvoyTask},
			player:sendToAllPlayerProc(Broadcast),
			ok;
		false->
		ok
	end,
ok.	

%%护送任务公告
sendConvoyBroadCast() ->
	try
		case task:isConvoyPeriod1() of
			false->
				ok;
			true->
				systemMessage:sendSysMsgToAllPlayer(?ConvoyTaskBroadCast)
		end,
		
		case task:isConvoyPeriod2() of
			false->
				ok;
			true->
				systemMessage:sendSysMsgToAllPlayer(?ConvoyTaskBroadCast)
		end
	catch
		_ ->ok
	end.	

%%采集任务公告
sendGatherBroadCast()->
	Current=common:getNowSeconds() rem 86400,
	case task:isGatherPeriod1() of
		false->
			ok;
		true->
			Interval=Current -?GatherTaskStartTime,
			TimePast=Interval rem ?GatherTaskBroadCastInterval,
			case TimePast<60 of %%60是tick 的时间间隔
				true->
					systemMessage:sendSysMsgToAllPlayer(?GatherTaskBroadCast),
					ok;
				false->
					ok
			end
	end,
	
	case task:isGatherPeriod2() of
		false->
			ok;
		true->
			%%采集有2个时间段
			Interval2=Current -?GatherTaskStartTime2,
			TimePast2=Interval2 rem ?GatherTaskBroadCastInterval,
			case TimePast2<60 of %%60是tick 的时间间隔
				true->
					systemMessage:sendSysMsgToAllPlayer(?GatherTaskBroadCast),
					ok;
				false->
					ok
			end
	end,

ok.

gatherFlagInit()->
	mainPID!{setWorldVarFlag,?WorldVariant_Index_1, ?WorldVariant_Index_1_Active_Gather,0},
	case task:isNowGahter() of
		false->
			ok;
	true->
		?DEBUG_OUT( "gatherFlagInit" ),
		mainPID!{setWorldVarFlag,?WorldVariant_Index_1, ?WorldVariant_Index_1_Active_Gather,1}
	end.

%%到了采集开启时间
openGatherActive()->
	Current=common:getNowSeconds() rem 86400,
	case task:isGatherPeriod1() of
		false->
			ok;
		true->
			EndTime=?GatherTaskStartTime+60,
			case (Current<EndTime ) andalso  (Current >= ?GatherTaskStartTime) of %%60是tick 的时间间隔
				true->
					mainPID!{setWorldVarFlag,?WorldVariant_Index_1, ?WorldVariant_Index_1_Active_Gather,1},
					?DEBUG_OUT( "openGatherActive 1" ),
					ok;
				false->
					ok
			end
	end,
	
	case task:isGatherPeriod2() of
		false->
			ok;
		true->
			%%采集有2个时间段
			EndTime2=?GatherTaskStartTime2+60,
			case (Current<EndTime2 ) andalso  (Current >= ?GatherTaskStartTime2) of %%60是tick 的时间间隔
				true->
					mainPID!{setWorldVarFlag,?WorldVariant_Index_1, ?WorldVariant_Index_1_Active_Gather,1},
					?DEBUG_OUT( "openGatherActive 2" ),
					ok;
				false->
					ok
			end
	end,
ok.

%%到了采集结束时间
closeGatherActive()->
	
	Current=common:getNowSeconds() rem 86400,
	EndTime=?GatherTaskEndTime+60,
			case (Current<EndTime ) andalso  (Current >= ?GatherTaskEndTime) of %%60是tick 的时间间隔
				true->
					mainPID!{setWorldVarFlag,?WorldVariant_Index_1, ?WorldVariant_Index_1_Active_Gather,0},
					?DEBUG_OUT( "closeGatherActive 1" ),
					ok;
				false->
					ok
			end,
	
	EndTime2=?GatherTaskEndTime2+60,
			case (Current<EndTime2 ) andalso  (Current >= ?GatherTaskEndTime2) of %%60是tick 的时间间隔
				true->
					mainPID!{setWorldVarFlag,?WorldVariant_Index_1, ?WorldVariant_Index_1_Active_Gather,0},
					?DEBUG_OUT( "closeGatherActive 2" ),
					ok;
				false->
					ok
			end,
ok.

%%每日声望限额重置
resetCreditLimit()->
	Current=common:getNowSeconds() rem 86400,
	ResetStartTime=?CreditAggressiveResetTime,
	ResetEndTime=ResetStartTime+60,%%60是定时器的时间间隔
	case (Current>=ResetStartTime) andalso (ResetEndTime>Current) of
		true->
			%%发消息让所有在线玩家重置
			Broadcast={resetCreditLimit},
			player:sendToAllPlayerProc(Broadcast),
			ok;
		false->
		ok
	end,
ok.
