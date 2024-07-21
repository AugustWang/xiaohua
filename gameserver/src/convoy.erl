-module(convoy).

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
-include("variant.hrl").
-include("textDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

-define( CarriageQuality_Normal, 1).  %镖车的品质 普通
-define( CarriageQuality_Excellent, 2). %镖车的品质 优秀
-define( CarriageQuality_Polish , 3).  %镖车的品质 精良
-define( CarriageQuality_Epic , 4).  %镖车的品质 史诗
-define( CarriageQuality_Legend , 5).  %镖车的品质 传说
-define( CarriageQuality_Max , 5).

-define( ConvoyType_Low , 1). %护送类型
-define( ConvoyType_High , 2). %护送类型


-define( LowConvoy_CD_MAX , 2). %初级护送次数
-define( HighConvoy_CD_MAX , 1). %高级护送次数

-define( Convoy_User_Level_Low, 30). %初级护送,玩家等级
-define( Convoy_User_Level_High, 50). %高级护送,玩家等级

-define( Convoy_Refresh_Free, 3). %免费护送次数

-define( Convoy_Notice_Left_Timer, 60*1000). %定时器
-define( ConvoyResetTimer, 4*3600). %%每天重置时间

-define( Open_Convoy_Succ, 1).
%% 刷新错误消息
-define( Convoy_Refresh_Quality_Succ, 0). %刷新成功
-define( Convoy_Refresh_Quality_Is_High, 1). %品质已经是最高了
-define( Convoy_Refresh_Quality_Low_Is_High, 2). %初级护送已达到最高值
-define( Convoy_Refresh_Quality_High_Is_High, 3). %高级护送已达到最高值
-define( Convoy_Refresh_Quality_Level_Error, 4). %等级不足
-define( Convoy_Refresh_Quality_Item_Is_Lack, 5). %物品不存在或者个数不够
-define( Convoy_Refresh_Quality_Failed, 6). %刷新失败

%% 护送错误消息
-define( Start_Convoy_Succ, 0). %护送成功
-define( Start_Convoy_Quality_And_Quality_No_Match, 1). %客户端和服务端品质或者类型或者任务不匹配
-define( Start_Convoy_Level_Error, 2). %开始护送等级不足
-define( Start_Convoy_Low_Is_High, 3). %初级护送已达到最高值
-define( Start_Convoy_High_Is_High, 4). %高级护送已达到最高值
-define( Start_Convoy_NoHave_Task, 5). %无此任务
-define( Start_Convoy_Have_Task, 6). %此任务已接受

%% revoke it when player online
initPlayerConvoyAndSendCurConvoy(PlayerID) ->
	try
		case mySqlProcess:get_playerConvoy(PlayerID) of
	 		[] ->
	 			PlayerConvoy = #playerConvoy{playerId = PlayerID, taskID = 0, beginTime = 0, remainTime = 0, lowConvoyCD = ?LowConvoy_CD_MAX,
										highConvoyCD = ?HighConvoy_CD_MAX, curConvoyType = 0,
										curCarriageQuality = 0, deadCnt = 0, remainConvoyFreeRefreshCnt = ?Convoy_Refresh_Free},
				put("ConvoyCheckTimer", 0),
				set_Convoy_Info(PlayerConvoy);
	 		[DbConvoy|_]->
					put("ConvoyCheckTimer", DbConvoy#playerConvoy.beginTime),
					case checkConvoyOutTimer() of %%第二天
						true ->
							PlayerConvoy = setelement( #playerConvoy.lowConvoyCD, DbConvoy, ?LowConvoy_CD_MAX),
							PlayerConvoy11 = setelement( #playerConvoy.highConvoyCD, PlayerConvoy, ?HighConvoy_CD_MAX),
							PlayerConvoy22 = setelement( #playerConvoy.remainConvoyFreeRefreshCnt, PlayerConvoy11, ?Convoy_Refresh_Free),
							set_Convoy_Info(PlayerConvoy22);
						false ->
							set_Convoy_Info(DbConvoy)
					end
	 	end,
		
		case get_Convoy_Info() of
			undefined ->
				throw(-1);
			PlayerConvoy0 ->
				put("Convoy_Cur_Type", PlayerConvoy0#playerConvoy.curConvoyType), %% 保存当前类型
				put("Convoy_Cur_Quality", PlayerConvoy0#playerConvoy.curCarriageQuality), %% 保存品质
				put("ConvoyRealType", PlayerConvoy0#playerConvoy.curConvoyType),
				put("ConvoyRealQulity", PlayerConvoy0#playerConvoy.curCarriageQuality),
				put("ConvoyRemainTime", PlayerConvoy0#playerConvoy.remainTime),
				set_Convoy_Free_Refresh_Cnt(PlayerConvoy0#playerConvoy.remainConvoyFreeRefreshCnt),
				set_User_Convoy_Task_ID(PlayerConvoy0#playerConvoy.taskID),
				sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_Low_Escort_P, PlayerConvoy0#playerConvoy.lowConvoyCD),
				sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_High_Escort_P, PlayerConvoy0#playerConvoy.highConvoyCD),		
				
				ConvoyCfg = getConvoyByTypeAndQuality(PlayerConvoy0#playerConvoy.curConvoyType, PlayerConvoy0#playerConvoy.curCarriageQuality),
				case ConvoyCfg of
					{} -> ok;
					_ ->
						case PlayerConvoy0#playerConvoy.remainTime > 0 of
							true -> % 当前有押镖,设置玩家押镖状态
								set_Timer_Cnt(PlayerConvoy0#playerConvoy.remainTime*1000),
								erlang:send_after( ?Convoy_Notice_Left_Timer,self(), {netUsersTimer_noticeConvoyLeftTime} );
							false ->
								ok
						end
				end,
		  		
				% 把当前护送信息通知客户端
				player:send(#pk_GS2U_CurConvoyInfo{isDead = PlayerConvoy0#playerConvoy.deadCnt,
												   convoyType = PlayerConvoy0#playerConvoy.curConvoyType,
												   carriageQuality = PlayerConvoy0#playerConvoy.curCarriageQuality,
												   remainTime = PlayerConvoy0#playerConvoy.remainTime*1000,
												   lowCD = PlayerConvoy0#playerConvoy.lowConvoyCD,
												   highCD = PlayerConvoy0#playerConvoy.highConvoyCD,
												   freeCnt = PlayerConvoy0#playerConvoy.remainConvoyFreeRefreshCnt})
		end		
	catch
		_ ->ok
	end.

%% 下线保存
savePlayerConvoyWhenOffline()->	 
	case get_Convoy_Info() of
		undefined ->
 			PlayerConvoy = #playerConvoy{playerId = player:getCurPlayerID(), taskID = 0, beginTime = 0, remainTime = 0, lowConvoyCD = ?LowConvoy_CD_MAX,
										highConvoyCD = ?HighConvoy_CD_MAX, curConvoyType = 0,
										curCarriageQuality = 0, deadCnt = 0, remainConvoyFreeRefreshCnt = ?Convoy_Refresh_Free};
		PlayerConvoy0->
			PlayerConvoy = PlayerConvoy0
	end,
	mySqlProcess:replacePlayerConvoy(PlayerConvoy).

checkConvoyOutTimer() ->
	try
		CheckTimer = get("ConvoyCheckTimer"),
		case CheckTimer of
			undefined -> 
				throw(-1);
			_ -> 
				TodayResetTime = common:getTodayBeginSeconds()+?ConvoyResetTimer,
				Now = common:getNowSeconds(),
				case Now > TodayResetTime of
					true ->ResetTime = TodayResetTime + 24*60*60;
					false ->ResetTime = TodayResetTime
				end,

				case CheckTimer =:= 0 of %%新角色
					true -> 
						put("ConvoyCheckTimer", ResetTime),
						false;
					false ->
						case CheckTimer =< Now of %%重置
							true ->
								put("ConvoyCheckTimer", ResetTime),
								true;
							false -> false
						end
				end
		end						
	catch
		_ -> false
	end.

%% 上线时同步消息
sendOnlineMsgToMap() ->
	case get_Convoy_Info() of
		undefined ->
			throw(-1);
		PlayerConvoy->
			case PlayerConvoy#playerConvoy.remainTime > 0 of
				true -> ConvoyFlags = 1;
				false -> ConvoyFlags = 0
			end,
			sendConvoyStateToMap(PlayerConvoy#playerConvoy.curCarriageQuality, ConvoyFlags)
	end.

resetConvoyTimer() ->
	case get_Convoy_Info() of
		undefined -> ok;
		PlayerConvoy->
			PlayerConvoy1 = setelement( #playerConvoy.lowConvoyCD, PlayerConvoy, ?LowConvoy_CD_MAX),
			PlayerConvoy2 = setelement( #playerConvoy.highConvoyCD, PlayerConvoy1, ?HighConvoy_CD_MAX),
			PlayerConvoy3 = setelement( #playerConvoy.remainConvoyFreeRefreshCnt, PlayerConvoy2, ?Convoy_Refresh_Free),
			set_Convoy_Info(PlayerConvoy3)
	end.	

resetConvoy() ->
	sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_Low_Escort_P, ?LowConvoy_CD_MAX),
	sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_High_Escort_P, ?HighConvoy_CD_MAX),
	resetConvoyTimer().

sendConvoyDetailToClient(Type, Times) ->
	variant:setPlayerVarValueFromPlayer(Type, Times).

requestConvoyCD(#pk_U2GS_ConvoyCDRequst{}) ->
	try		
		case get_Convoy_Info() of
			undefined ->
	 			PlayerConvoy = #playerConvoy{playerId = player:getCurPlayerID(), taskID = 0, beginTime = 0, remainTime = 0, lowConvoyCD = ?LowConvoy_CD_MAX,
										highConvoyCD = ?HighConvoy_CD_MAX, curConvoyType = 0, curCarriageQuality = 0, 
									    deadCnt = 0, remainConvoyFreeRefreshCnt = ?Convoy_Refresh_Free},
				set_Convoy_Info(PlayerConvoy),
				player:send(#pk_GS2U_ConvoyCDResult{retCode = ?Open_Convoy_Succ});	
			PlayerConvoy0 ->
				case checkConvoyOutTimer() of %%第二天
					true ->
						PlayerConvoyTemp = setelement( #playerConvoy.lowConvoyCD, PlayerConvoy0, ?LowConvoy_CD_MAX),
						PlayerConvoyTemp1 = setelement( #playerConvoy.highConvoyCD, PlayerConvoyTemp, ?HighConvoy_CD_MAX),
						PlayerConvoyTemp2 = setelement( #playerConvoy.remainConvoyFreeRefreshCnt, PlayerConvoyTemp1, ?Convoy_Refresh_Free),
						set_Convoy_Info(PlayerConvoyTemp2),
						player:send(#pk_GS2U_ConvoyCDResult{retCode = ?Open_Convoy_Succ});	
					false -> 
						player:send(#pk_GS2U_ConvoyCDResult{retCode = ?Open_Convoy_Succ})
				end
		end	
	catch
		_ ->ok
	end.

%% 刷新品质
refreshCarriageQuality(#pk_U2GS_CarriageQualityRefresh{isRefreshLegend = IsRefreshLegend, isCostGold = IsCostGold, curConvoyType = Type, curCarriageQuality = QualityMsgValue, curTaskID = TaskID}) ->
	%% check
	%% 低级护送
	try
		%% 免费刷新
		PreFreeCnt = get_Convoy_Free_Refresh_Cnt(),
		case PreFreeCnt of
			undefined ->
				throw(-1);
			_ ->
				ok
		end,
		QualityValue = get("Convoy_Cur_Quality"), %%第一次以客户端为准，后面都以服务端为准
		case QualityValue =:= 0 of
			true -> 
				Quality = QualityMsgValue,
				put("Convoy_Cur_Quality", QualityMsgValue);
			false -> Quality = QualityValue
		end,
		
		case get_Convoy_Info() of
			undefined ->
	 			PlayerConvoy = #playerConvoy{playerId = player:getCurPlayerID(), taskID = 0, beginTime = 0, remainTime = 0, lowConvoyCD = ?LowConvoy_CD_MAX,
										highConvoyCD = ?HighConvoy_CD_MAX, curConvoyType = 0, curCarriageQuality = 0, 
									    deadCnt = 0, remainConvoyFreeRefreshCnt = ?Convoy_Refresh_Free};
			PlayerConvoy0 ->
				case checkConvoyOutTimer() of %%第二天
					true ->
						PlayerConvoyTemp = setelement( #playerConvoy.lowConvoyCD, PlayerConvoy0, ?LowConvoy_CD_MAX),
						PlayerConvoyTemp1 = setelement( #playerConvoy.highConvoyCD, PlayerConvoyTemp, ?HighConvoy_CD_MAX),
						PlayerConvoyTemp2 = setelement( #playerConvoy.remainConvoyFreeRefreshCnt, PlayerConvoyTemp1, ?Convoy_Refresh_Free),
						PlayerConvoy = PlayerConvoyTemp2,
						set_Convoy_Info(PlayerConvoyTemp2);
					false ->
						PlayerConvoy = PlayerConvoy0
				end
		end,
		
		Player = player:getCurPlayerRecord(),
		Level = Player#player.level,
		
		case ?ConvoyType_Low =:= Type of
			false ->
				ok;
			true ->
				case PlayerConvoy#playerConvoy.lowConvoyCD =:= 0 of
					true ->
						?DEBUG_OUT( "Low Convoy Is High"),
						player:send(#pk_GS2U_CarriageQualityRefreshResult{retCode = ?Convoy_Refresh_Quality_Low_Is_High, newConvoyType = Type, newCarriageQuality = Quality, freeCnt = PreFreeCnt}),
						throw(-1);
					false ->
						ok
				end,
				%% 等级判断，不满足护送要求的最低等级(30)
				case Level < ?Convoy_User_Level_Low of
					false 
						-> ok;
					true ->
						?DEBUG_OUT( "Convoy Failed Level：~p", [Level] ),
					 	player:send(#pk_GS2U_CarriageQualityRefreshResult{retCode = ?Convoy_Refresh_Quality_Level_Error, newConvoyType = Type, newCarriageQuality = Quality, freeCnt = PreFreeCnt}),
						throw(-1)
				end
		end,
		
		%% 高级护送
		case ?ConvoyType_High =:= Type of
			false ->
				ok;
			true ->
				case PlayerConvoy#playerConvoy.highConvoyCD =:= 0 of
					false ->
						ok;
					true ->
						?DEBUG_OUT( "High Convoy Is High"),
						player:send(#pk_GS2U_CarriageQualityRefreshResult{retCode = ?Convoy_Refresh_Quality_High_Is_High, newConvoyType = Type, newCarriageQuality = Quality, freeCnt = PreFreeCnt}),
						throw(-1)
				end,
				%% 等级判断，不满足护送要求的最低等级(50)
				case Level < ?Convoy_User_Level_High of
					false ->
						ok;
					true ->
						?DEBUG_OUT( "Convoy Failed Level：~p", [Level] ),
					 	player:send(#pk_GS2U_CarriageQualityRefreshResult{retCode = ?Convoy_Refresh_Quality_Level_Error, newConvoyType = Type, newCarriageQuality = Quality, freeCnt = PreFreeCnt}),
						throw(-1)
				end
		end,
		
		case Quality >= ?CarriageQuality_Max of
			true->
				?DEBUG_OUT( "Quality Is High" ),
				player:send(#pk_GS2U_CarriageQualityRefreshResult{retCode = ?Convoy_Refresh_Quality_Is_High,
					newConvoyType = Type, newCarriageQuality = Quality, freeCnt = PreFreeCnt}),
				throw(-1);
			false -> ok
		end,
		
		%% 根据类型和品质得出对应列表
		ConvoyList = getConvoyByTypeAndQuality(Type, Quality),
		case ConvoyList of
			{} ->
				ok;
			_ ->
				case IsRefreshLegend =:= 1 of
					true -> %直接升级到传说品质去
						set_User_Convoy_Task_ID(TaskID),
						costForGoldOrItem(Type, Quality, IsCostGold, PreFreeCnt);%%循环扣除刷新消耗
					%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					false -> %% 不是直接到传说品质
						%% 处理概率
						%% 免费刷新
						RefreshCnt = get_Convoy_Free_Refresh_Cnt(),
						case get_Convoy_Free_Refresh_Cnt() of
							undefined ->
								set_Convoy_Free_Refresh_Cnt(2); %% 这里永远不会出现，因为之前已经设置过一次了
							RefreshCnt ->
								case RefreshCnt > 0 of %% 是否还有免费的刷新 
									false ->
										%% 据配置消耗
										ItemID = ConvoyList#convoyCfg.refreshConsumeID,
										ItemCnt = ConvoyList#convoyCfg.refreshConsumeCnt,
										Money = ConvoyList#convoyCfg.refreshMoney,
										case costGoldOrItem(ItemID, ItemCnt, Money, IsCostGold) of %% 扣除消耗品
											true -> true;
											false ->
												player:send(#pk_GS2U_CarriageQualityRefreshResult{retCode = ?Convoy_Refresh_Quality_Item_Is_Lack,
													newConvoyType = Type, newCarriageQuality = Quality, freeCnt = 0}),
												throw(-1)
										end;
									true ->  %% 还有免费的刷新
										set_Convoy_Free_Refresh_Cnt(RefreshCnt-1)
								end,
								%% 此时算概率
								case probabilityResult(ConvoyList#convoyCfg.refreshPercent) of
									true -> true;
									false ->
										case RefreshCnt > 0 of
											true -> SendFreshCnt = RefreshCnt-1;
											false -> SendFreshCnt = RefreshCnt
										end,
										%% 失败时也要把刷新次数记录到数据库中，主要是记录刷新次数
										PlayerConvoyFailed = setelement( #playerConvoy.remainConvoyFreeRefreshCnt, PlayerConvoy, SendFreshCnt),
										Now0 = common:getNowSeconds(),
										PlayerConvoyFailed1 = setelement( #playerConvoy.beginTime, PlayerConvoyFailed, Now0),
										set_Convoy_Info(PlayerConvoyFailed1),
										mySqlProcess:replacePlayerConvoy(PlayerConvoyFailed1),
										player:send(#pk_GS2U_CarriageQualityRefreshResult{retCode = ?Convoy_Refresh_Quality_Failed,
											newConvoyType = Type, newCarriageQuality = Quality, freeCnt = SendFreshCnt}),
										throw(-1)
						end,
						
						%% send refresh result to client
						case Quality+1 =< ?CarriageQuality_Max of
							true -> NewQuality = Quality+1;
							false -> NewQuality = ?CarriageQuality_Max
						end,
						
						set_User_Convoy_Task_ID(TaskID),
						PlayerConvoy1 = setelement( #playerConvoy.curConvoyType, PlayerConvoy, Type),
						PlayerConvoy2 = setelement( #playerConvoy.curCarriageQuality, PlayerConvoy1, NewQuality),
						PlayerConvoy3 = setelement( #playerConvoy.remainConvoyFreeRefreshCnt, PlayerConvoy2, RefreshCnt-1),
						PlayerConvoy4 = setelement( #playerConvoy.beginTime, PlayerConvoy3, get("ConvoyCheckTimer")),
						put("Convoy_Cur_Type", Type), %% 保存当前类型
						put("Convoy_Cur_Quality", NewQuality), %% 保存品质
						set_Convoy_Info(PlayerConvoy4),
								
						mySqlProcess:replacePlayerConvoy(PlayerConvoy4),
						Result = #pk_GS2U_CarriageQualityRefreshResult{
									retCode = ?Convoy_Refresh_Quality_Succ,
									newConvoyType = Type,
									newCarriageQuality = NewQuality,
									freeCnt = RefreshCnt-1},
						player:send(Result)
				end
			end
		end
	catch
		_ ->ok
	end.

%% 开始护送
beginConvoy(#pk_U2GS_BeginConvoy{nTaskID = TaskID, curConvoyType = Type, curCarriageQuality = QualityMsgValue, nNpcActorID = NpcActorID} = _BeginConvoy)->
	%% check
	try
		mount:on_U2GS_MountDownRequest(),
		case get_Convoy_Info() of
			undefined ->
	 			PlayerConvoy = #playerConvoy{playerId = player:getCurPlayerID(), taskID = 0, beginTime = 0, remainTime = 0, lowConvoyCD = ?LowConvoy_CD_MAX,
										highConvoyCD = ?HighConvoy_CD_MAX, curConvoyType = 0,
										curCarriageQuality = 0, deadCnt = 0, remainConvoyFreeRefreshCnt = ?Convoy_Refresh_Free};
			PlayerConvoy0 ->
				PlayerConvoy = PlayerConvoy0
		end,
		
		QualityValue = get("Convoy_Cur_Quality"),
		case QualityValue =:= 0 of %%第一次以客户端为准，后面都以服务端为准
			true -> 
				Quality = QualityMsgValue,
				put("Convoy_Cur_Quality", QualityMsgValue);
			false -> Quality = QualityValue
		end,
		case Quality > ?CarriageQuality_Max of
			true->
				?DEBUG_OUT( "Quality Is High" ),
				throw(-1);
			false -> ok
		end,

		Player = player:getCurPlayerRecord(),
		Level = Player#player.level,
		%% 低级护送
		case ?ConvoyType_Low =:= Type of
			false ->
				ok;
			true ->
				case Level < 30 of
					false ->
						ok;
					true ->
						?DEBUG_OUT( "Convoy Failed Level：~p", [Level] ),
						player:send(#pk_GS2U_BeginConvoyResult{retCode = ?Start_Convoy_Level_Error,
										curConvoyType = PlayerConvoy#playerConvoy.curConvoyType,
										curCarriageQuality = PlayerConvoy#playerConvoy.curCarriageQuality,
										remainTime = PlayerConvoy#playerConvoy.remainTime,
										lowCD = PlayerConvoy#playerConvoy.lowConvoyCD,
										highCD = PlayerConvoy#playerConvoy.highConvoyCD	
										}),
						throw(-1)
				end,
				case PlayerConvoy#playerConvoy.lowConvoyCD =:= 0 of
					false ->
						ok;
					true ->
						?DEBUG_OUT( "Low Convoy Is High"),
						player:send(#pk_GS2U_BeginConvoyResult{retCode = ?Start_Convoy_Low_Is_High,
										curConvoyType = PlayerConvoy#playerConvoy.curConvoyType,
										curCarriageQuality = PlayerConvoy#playerConvoy.curCarriageQuality,
										remainTime = PlayerConvoy#playerConvoy.remainTime,
										lowCD = PlayerConvoy#playerConvoy.lowConvoyCD,
										highCD = PlayerConvoy#playerConvoy.highConvoyCD
										}),
						throw(-1)
				end
		end,
		
		%% 高级护送
		case ?ConvoyType_High =:= Type of
			false ->
				ok;
			true ->
				case Level < 50 of
					false ->
						ok;
					true ->
						?DEBUG_OUT( "Convoy Failed Level：~p", [Level] ),
						player:send(#pk_GS2U_BeginConvoyResult{retCode = ?Start_Convoy_Level_Error,
										curConvoyType = PlayerConvoy#playerConvoy.curConvoyType,
										curCarriageQuality = PlayerConvoy#playerConvoy.curCarriageQuality,
										remainTime = PlayerConvoy#playerConvoy.remainTime,
										lowCD = PlayerConvoy#playerConvoy.lowConvoyCD,
										highCD = PlayerConvoy#playerConvoy.highConvoyCD	
										}),
						throw(-1)
				end,
				case PlayerConvoy#playerConvoy.highConvoyCD =:= 0 of
					false ->
						ok;
					true ->
						?DEBUG_OUT( "High Convoy Is High"),
						player:send(#pk_GS2U_BeginConvoyResult{retCode = ?Start_Convoy_High_Is_High,
										curConvoyType = PlayerConvoy#playerConvoy.curConvoyType,
										curCarriageQuality = PlayerConvoy#playerConvoy.curCarriageQuality,
										remainTime = PlayerConvoy#playerConvoy.remainTime,
										lowCD = PlayerConvoy#playerConvoy.lowConvoyCD,
										highCD = PlayerConvoy#playerConvoy.highConvoyCD	
										}),
						throw(-1)
				end
		end,
		
		QuestBase = etsBaseFunc:readRecord( main:getGlobalTaskBaseTable(), TaskID ),
		case QuestBase of
			{}->
				?DEBUG_OUT( "Convoy on_U2GS_AcceptTaskRequest QuestBase[~p] = {}", [TaskID] ),
				player:send(#pk_GS2U_BeginConvoyResult{retCode = ?Start_Convoy_NoHave_Task,
								curConvoyType = PlayerConvoy#playerConvoy.curConvoyType,
								curCarriageQuality = PlayerConvoy#playerConvoy.curCarriageQuality,
								remainTime = PlayerConvoy#playerConvoy.remainTime,
								lowCD = PlayerConvoy#playerConvoy.lowConvoyCD,
								highCD = PlayerConvoy#playerConvoy.highConvoyCD	
								}),			
				throw(-1);
			_ -> ok
		end,
		
		case task:canAcceptQuest( player:getCurPlayerRecord(), QuestBase ) of
			false->
				player:send(#pk_GS2U_BeginConvoyResult{retCode = ?Start_Convoy_Have_Task,
								curConvoyType = PlayerConvoy#playerConvoy.curConvoyType,
								curCarriageQuality = PlayerConvoy#playerConvoy.curCarriageQuality,
								remainTime = PlayerConvoy#playerConvoy.remainTime,
								lowCD = PlayerConvoy#playerConvoy.lowConvoyCD,
								highCD = PlayerConvoy#playerConvoy.highConvoyCD	
								}),				
				throw(-1);
			true -> ok
		end,
		
		put("Convoy_Cur_Type", Type),
		set_User_Convoy_Task_ID(TaskID),
		%% 接受任务
		TaskMsg = {pk_U2GS_AcceptTaskRequest, TaskID, NpcActorID},
		player:sendMsgToMap( {playerMsg_U2GS_AcceptTaskRequest, self(), player:getCurPlayerID(), TaskMsg})	
	catch
		_ ->ok
	end.

%% 保存护送信息
saveConvoyInfoToWorkBook() ->
	try
		CurType = get("Convoy_Cur_Type"),
		CurQuality = get("Convoy_Cur_Quality"),
		CurTaskID = get_User_Convoy_Task_ID(),
		case CurType of
			undefined -> throw(-1);
			_ -> ok
		end,
		case CurQuality of
			undefined -> throw(-1);
			_ -> ok
		end,
		case CurTaskID of
			undefined -> throw(-1);
			_ -> ok
		end,

		case get_Convoy_Info() of
			undefined ->
				ok;
			PlayerConvoy ->
				ConvoyCfg = getConvoyByTypeAndQuality(CurType, CurQuality),
				case  ConvoyCfg of
					{} ->
						ok;
					_ ->
						TaskRemainTimer = ConvoyCfg#convoyCfg.taskTime,
						case CurType of
							?ConvoyType_Low ->	
								NewCD = PlayerConvoy#playerConvoy.lowConvoyCD - 1,
								PlayerConvoy1 = setelement( #playerConvoy.lowConvoyCD, PlayerConvoy, NewCD),
								PlayerConvoy2 = setelement( #playerConvoy.beginTime, PlayerConvoy1, get("ConvoyCheckTimer")),
								PlayerConvoy3 = setelement( #playerConvoy.remainTime, PlayerConvoy2, TaskRemainTimer);
							?ConvoyType_High ->
								NewCD = PlayerConvoy#playerConvoy.highConvoyCD - 1,
								PlayerConvoy1 = setelement( #playerConvoy.highConvoyCD, PlayerConvoy, NewCD),
								PlayerConvoy2 = setelement( #playerConvoy.beginTime, PlayerConvoy1, get("ConvoyCheckTimer")),
								PlayerConvoy3 = setelement( #playerConvoy.remainTime, PlayerConvoy2, TaskRemainTimer)
						end,
						PlayerConvoy4 = setelement( #playerConvoy.deadCnt, PlayerConvoy3, 0),
						PlayerConvoy5 = setelement( #playerConvoy.curConvoyType, PlayerConvoy4, CurType),
						PlayerConvoy6 = setelement( #playerConvoy.curCarriageQuality, PlayerConvoy5, CurQuality),
						PlayerConvoy7 = setelement( #playerConvoy.taskID, PlayerConvoy6, CurTaskID),
						sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_Low_Escort_P, PlayerConvoy7#playerConvoy.lowConvoyCD),
						sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_High_Escort_P, PlayerConvoy7#playerConvoy.highConvoyCD),							
						
						set_Convoy_Info(PlayerConvoy7),
						set_Timer_Cnt(TaskRemainTimer*1000), %% 设置定时器时间
						erlang:send_after( ?Convoy_Notice_Left_Timer,self(), {netUsersTimer_noticeConvoyLeftTime} ),
						%% 更新数据库
						mySqlProcess:replacePlayerConvoy(PlayerConvoy7),
						%% send result
						Result = #pk_GS2U_BeginConvoyResult{retCode = ?Start_Convoy_Succ,
										curConvoyType = CurType,
										curCarriageQuality = CurQuality,
										remainTime = PlayerConvoy7#playerConvoy.remainTime*1000,
										lowCD = PlayerConvoy7#playerConvoy.lowConvoyCD,
										highCD = PlayerConvoy7#playerConvoy.highConvoyCD
										},
						player:send(Result),
						sendConvoyStateToMap(CurQuality, 1)
				end,
				ok
			end
	catch
		_ ->ok
	end.

%% 护送完成
finish_Convoy(TaskId) ->
	try
		case get_Convoy_Info() of
			undefined ->
				throw(-1);
			PlayerConvoy ->	
				%%remoe_User_Dead_Event(), %% 销毁死亡事件				
				ConvoyCfg = getConvoyByTypeAndQuality(PlayerConvoy#playerConvoy.curConvoyType, PlayerConvoy#playerConvoy.curCarriageQuality),
				case ConvoyCfg of
					{} ->
						ok;
					_ ->
						case PlayerConvoy#playerConvoy.remainTime =< 0 of %超出护送时间
							false ->
								ok;
							true ->
								throw(-1)
						end
				end,
				awardConvoyResult(TaskId), %% 奖励
				set_Timer_Cnt(-1),
				put("Convoy_Cur_Quality", 0),									
				PlayerConvoy1 = setelement( #playerConvoy.curConvoyType, PlayerConvoy, 0),	
				PlayerConvoy2 = setelement( #playerConvoy.deadCnt, PlayerConvoy1, 0),	
				PlayerConvoy3 = setelement( #playerConvoy.remainTime, PlayerConvoy2, 0),
				PlayerConvoy4 = setelement( #playerConvoy.taskID, PlayerConvoy3, 0),
				PlayerConvoy5 = setelement( #playerConvoy.curCarriageQuality, PlayerConvoy4, 0),
				case checkConvoyOutTimer() of %% 第二天
					true ->
						PlayerConvoy6 = setelement( #playerConvoy.lowConvoyCD, PlayerConvoy5, ?LowConvoy_CD_MAX),
						PlayerConvoy7 = setelement( #playerConvoy.highConvoyCD, PlayerConvoy6, ?HighConvoy_CD_MAX),
						PlayerConvoy8 = setelement( #playerConvoy.remainConvoyFreeRefreshCnt, PlayerConvoy7, ?Convoy_Refresh_Free),
						sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_Low_Escort_P, PlayerConvoy8#playerConvoy.lowConvoyCD),
						sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_High_Escort_P, PlayerConvoy8#playerConvoy.highConvoyCD),						
						set_Convoy_Info(PlayerConvoy8),
						mySqlProcess:replacePlayerConvoy(PlayerConvoy8);
					false ->
						sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_Low_Escort_P, PlayerConvoy5#playerConvoy.lowConvoyCD),
						sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_High_Escort_P, PlayerConvoy5#playerConvoy.highConvoyCD),
						set_Convoy_Info(PlayerConvoy5),
						mySqlProcess:replacePlayerConvoy(PlayerConvoy5)
				end,
				player:send(#pk_GS2U_FinishConvoyResult{curConvoyType = 0, curCarriageQuality = 0}),
				sendConvoyStateToMap(0,0)
		end		
	catch
		_ ->ok
	end.

%% 放弃护送
giveUp_Convoy_Task() ->
	try
		case get_Convoy_Info() of
			undefined ->
				ok;
			PlayerConvoy ->
				set_Timer_Cnt(-1),
				put("Convoy_Cur_Quality", 0),				
				PlayerConvoy1 = setelement( #playerConvoy.curConvoyType, PlayerConvoy, 0),	
				PlayerConvoy2 = setelement( #playerConvoy.deadCnt, PlayerConvoy1, 0),	
				PlayerConvoy3 = setelement( #playerConvoy.remainTime, PlayerConvoy2, 0),
				PlayerConvoy4 = setelement( #playerConvoy.taskID, PlayerConvoy3, 0),
				PlayerConvoy5 = setelement( #playerConvoy.curCarriageQuality, PlayerConvoy4, 0),
				case checkConvoyOutTimer() of %% 第二天
					true ->
						PlayerConvoy6 = setelement( #playerConvoy.lowConvoyCD, PlayerConvoy5, ?LowConvoy_CD_MAX),
						PlayerConvoy7 = setelement( #playerConvoy.highConvoyCD, PlayerConvoy6, ?HighConvoy_CD_MAX),
				  		PlayerConvoy8 = setelement( #playerConvoy.remainConvoyFreeRefreshCnt, PlayerConvoy7, ?Convoy_Refresh_Free),
						sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_Low_Escort_P, PlayerConvoy8#playerConvoy.lowConvoyCD),
						sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_High_Escort_P, PlayerConvoy8#playerConvoy.highConvoyCD),
						set_Convoy_Info(PlayerConvoy8),
						mySqlProcess:replacePlayerConvoy(PlayerConvoy8);
					false ->
						sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_Low_Escort_P, PlayerConvoy5#playerConvoy.lowConvoyCD),
						sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_High_Escort_P, PlayerConvoy5#playerConvoy.highConvoyCD),
						set_Convoy_Info(PlayerConvoy5),
						mySqlProcess:replacePlayerConvoy(PlayerConvoy5)
				end,
				player:send(#pk_GS2U_GiveUpConvoyResult{curConvoyType = 0, curCarriageQuality = 0}),
				sendConvoyStateToMap(0,0)
		end
	catch
		_ ->ok
	end.

%% 设置定时器
set_Timer() ->
	try
		case get_Timer_Cnt() of
			undefined ->
				ok;
			TimerValue ->
				CurRemainTime = TimerValue-?Convoy_Notice_Left_Timer,
				case get_Convoy_Info() of
					undefined ->
						throw(-1);
					PlayerConvoy ->	
						case PlayerConvoy#playerConvoy.curConvoyType > 0 of
							true -> %% 有护送任务
								case CurRemainTime > 0 of
									true ->
										set_Timer_Cnt(CurRemainTime),
										erlang:send_after( ?Convoy_Notice_Left_Timer,self(), {netUsersTimer_noticeConvoyLeftTime} ),
										PlayerConvoy1 = setelement( #playerConvoy.remainTime, PlayerConvoy, CurRemainTime/1000),
										set_Convoy_Info(PlayerConvoy1),
										player:send(#pk_GS2U_ConvoyNoticeTimerResult{isDead = PlayerConvoy1#playerConvoy.deadCnt,
														remainTime = CurRemainTime
														});
									false ->
										case CurRemainTime =:= 0 of
											true ->
												set_Timer_Cnt(0),
												time_out_Convoy(),
												put("Convoy_Cur_Quality", 0),
												PlayerConvoy1 = setelement( #playerConvoy.remainTime, PlayerConvoy, 0),
												set_Convoy_Info(PlayerConvoy1),
												player:send(#pk_GS2U_ConvoyNoticeTimerResult{isDead = PlayerConvoy1#playerConvoy.deadCnt,
																remainTime = 0
																});
											false ->
												ok
										end
								end;
							false ->ok
						end
				end
		end
	catch
		_ -> ok
	end.

%% 护送时间到达
time_out_Convoy() ->
	try
		case get_User_Convoy_Task_ID() of
			undefined ->
				throw(-1);
			_Value -> 
				?DEBUG_OUT( "Convoy Failed, Timer Out" ),
				case get_Convoy_Info() of
					undefined ->
						throw(-1);
					PlayerConvoy ->	
						%%set_Timer_Cnt(0),					
						task:giveUp_Convory_Task_Of_Online(_Value), %% 从任务列表中清除此任务
						PlayerConvoy1 = setelement( #playerConvoy.curConvoyType, PlayerConvoy, 0),	
						PlayerConvoy2 = setelement( #playerConvoy.deadCnt, PlayerConvoy1, 0),	
						PlayerConvoy3 = setelement( #playerConvoy.remainTime, PlayerConvoy2, 0),
						PlayerConvoy4 = setelement( #playerConvoy.taskID, PlayerConvoy3, 0),
						PlayerConvoy5 = setelement( #playerConvoy.curCarriageQuality, PlayerConvoy4, 0),
						case checkConvoyOutTimer() of %% 第二天
							true ->
								PlayerConvoy6 = setelement( #playerConvoy.lowConvoyCD, PlayerConvoy5, ?LowConvoy_CD_MAX),
								PlayerConvoy7 = setelement( #playerConvoy.highConvoyCD, PlayerConvoy6, ?HighConvoy_CD_MAX),
								PlayerConvoy8 = setelement( #playerConvoy.remainConvoyFreeRefreshCnt, PlayerConvoy7, ?Convoy_Refresh_Free),
								sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_Low_Escort_P, PlayerConvoy8#playerConvoy.lowConvoyCD),
								sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_High_Escort_P, PlayerConvoy8#playerConvoy.highConvoyCD),
								set_Convoy_Info(PlayerConvoy8),
								mySqlProcess:replacePlayerConvoy(PlayerConvoy8);
							false ->
								sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_Low_Escort_P, PlayerConvoy5#playerConvoy.lowConvoyCD),
								sendConvoyDetailToClient(?PlayerVariant_Index_Active_Times_High_Escort_P, PlayerConvoy5#playerConvoy.highConvoyCD),
								set_Convoy_Info(PlayerConvoy5),
								mySqlProcess:replacePlayerConvoy(PlayerConvoy5)
						end,
						sendConvoyStateToMap(0,0)
				end
		end		
	catch
		_ ->ok
	end.

%% 玩家死亡
on_User_Dead_Msg_To_Convoy() ->
	try
		case get_Convoy_Info() of
			undefined ->
				ok;
			PlayerConvoy ->
				case PlayerConvoy#playerConvoy.curConvoyType > 0 of %% 有护送任务
					false ->
						ok;
					true ->
						DeadCnt = #playerConvoy.deadCnt,
						PlayerConvoy1 = setelement( #playerConvoy.deadCnt, PlayerConvoy, DeadCnt+1),	
						set_Convoy_Info(PlayerConvoy1)
				end
		end		
	catch
		_ ->ok
	end.

%%
sendConvoyStateToMap(CurConvoyQuality, ConvoyFlags) ->
	player:sendMsgToMap( {playerConvoyStateChange, player:getCurPlayerID(), CurConvoyQuality, ConvoyFlags}).

%% 奖励
awardConvoyResult(TaskId) ->
	try
		case get_Convoy_Info() of
			undefined ->
				ok;
			PlayConvoy ->	
				Player = player:getCurPlayerRecord(),
				Level = Player#player.level,
				Type = PlayConvoy#playerConvoy.curConvoyType,
				Quality = PlayConvoy#playerConvoy.curCarriageQuality,
				ConvoyList = getConvoyByTypeAndQuality( Type, Quality ),
				case ConvoyList of
					{} -> throw(-1);
					_ -> ok
				end,
				ConvoyAwardList = getAwardByLevel(Level),
				case ConvoyAwardList of
					{} -> ok;
					_ ->
						case Quality =:= ?CarriageQuality_Excellent of
							true ->
								case Type =:= ?ConvoyType_Low of
									true ->
										put("AwardExp", ConvoyAwardList#convoyAwardCfg.task30_exp1),
										put("AwardMoney", ConvoyAwardList#convoyAwardCfg.task30_money1);
									false ->
										put("AwardExp", ConvoyAwardList#convoyAwardCfg.task50_exp1),
										put("AwardMoney", ConvoyAwardList#convoyAwardCfg.task50_money1)
								end;
							false -> ok
						end,
	
						case Quality =:= ?CarriageQuality_Polish of
							true ->
								case Type =:= ?ConvoyType_Low of
									true ->
										put("AwardExp", ConvoyAwardList#convoyAwardCfg.task30_exp2),
										put("AwardMoney", ConvoyAwardList#convoyAwardCfg.task30_money2);
									false ->
										put("AwardExp", ConvoyAwardList#convoyAwardCfg.task50_exp2),
										put("AwardMoney", ConvoyAwardList#convoyAwardCfg.task50_money2)
								end;
							false -> ok
						end,
	
						case Quality =:= ?CarriageQuality_Epic of
							true ->
								case Type =:= ?ConvoyType_Low of
									true ->
										put("AwardExp", ConvoyAwardList#convoyAwardCfg.task30_exp3),
										put("AwardMoney", ConvoyAwardList#convoyAwardCfg.task30_money3);
									false ->
										put("AwardExp", ConvoyAwardList#convoyAwardCfg.task50_exp3),
										put("AwardMoney", ConvoyAwardList#convoyAwardCfg.task50_money3)
								end;
							false -> ok
						end,
	
						case Quality =:= ?CarriageQuality_Legend of
							true ->
								case Type =:= ?ConvoyType_Low of
									true ->
										put("AwardExp", ConvoyAwardList#convoyAwardCfg.task30_exp4),
										put("AwardMoney", ConvoyAwardList#convoyAwardCfg.task30_money4);
									false ->
										put("AwardExp", ConvoyAwardList#convoyAwardCfg.task50_exp4),
										put("AwardMoney", ConvoyAwardList#convoyAwardCfg.task50_money4)
								end;
							false -> ok
						end,
	
						AwardExp = get("AwardExp"),
						AwardBindMoney = get("AwardMoney"),
						case PlayConvoy#playerConvoy.deadCnt > 0 of %% 此角色在护送任务中死亡过, 只奖励百分之四十
							false ->
								AwardExp1 = AwardExp,
								AwardBindMoney1 = AwardBindMoney;
							true ->
								AwardExp1 = (AwardExp*4) div 10, %% 只奖励百分之四十
								AwardBindMoney1 = (AwardBindMoney*4) div 10
						end,
						
						CurHour = common:getNowHour(),
						%% 在特殊时段奖励
						case (CurHour >= ConvoyList#convoyCfg.specialHourMin1) andalso (CurHour < ConvoyList#convoyCfg.specialHourMax1) of
							true ->
								Scale = ConvoyList#convoyCfg.specialAward1 div 100,
								AwardExp2 = Scale*AwardExp1,
								AwardBindMoney2 = Scale*AwardBindMoney1;
							false ->
								AwardExp2 = AwardExp1,
								AwardBindMoney2 = AwardBindMoney1
						end,
					
						%% 在特殊时段奖励
						case (CurHour >= ConvoyList#convoyCfg.specialHourMin2) andalso (CurHour < ConvoyList#convoyCfg.specialHourMax2) of
							true ->
								Scale1 = ConvoyList#convoyCfg.specialAward2 div 100,
								AwardExp3 = Scale1*AwardExp2,
								AwardBindMoney3 = Scale1*AwardBindMoney2;
							false ->
								AwardExp3 = AwardExp2,
								AwardBindMoney3 = AwardBindMoney2
						end,
					
						case AwardExp3 > 0 of
							false ->
								ok;
							true ->
								ParamTuple2 = #exp_param{changetype = ?Exp_Change_Convoy, param1 = TaskId},
								player:addPlayerEXP(AwardExp3, ?Exp_Change_Convoy, ParamTuple2)
						end,
					
						case AwardBindMoney3 > 0 of
							false ->
								ok;
							true ->
								ParamTuple1 = #token_param{changetype = ?Money_Change_Convoy, param1 = TaskId},
								playerMoney:addPlayerBindedMoney(AwardBindMoney3, ?Money_Change_Convoy, ParamTuple1)
						end,
						
						case (AwardExp3 > 0) andalso (AwardBindMoney3 > 0) of
							true ->
								Str = io_lib:format(?TEXT_CONVOY_AWARD_MONEY_AND_EXP, [AwardBindMoney3, AwardExp3]),
								systemMessage:sendTipsMessage(Player#player.id, Str);
							false ->
								case AwardExp3 > 0 of
									true ->
										StrExp = io_lib:format(?TEXT_CONVOY_AWARD_EXP, [AwardExp3]),
										systemMessage:sendTipsMessage(Player#player.id, StrExp);
									false ->
										case AwardBindMoney3 > 0 of
											true ->
												StrMoney = io_lib:format(?TEXT_CONVOY_AWARD_MONEY, [AwardBindMoney3]),
												systemMessage:sendTipsMessage(Player#player.id, StrMoney);
											false -> ok
										end
								end
						end
				end
		  end	
	catch
		_ ->ok
	end.

canCompleteConvoyTask() ->
	try
		case get_Convoy_Info() of
			undefined ->
				false;
			PlayerConvoy ->
				ConvoyCfg = getConvoyByTypeAndQuality(PlayerConvoy#playerConvoy.curConvoyType, PlayerConvoy#playerConvoy.curCarriageQuality),
				case  ConvoyCfg of
					{} ->
						false;
					_ ->
						case PlayerConvoy#playerConvoy.remainTime =< 0 of %超出护送时间
							true ->
								false;
							false ->
								true
						end
				end
		end
	catch
		_ ->false
	end.

probabilityResult( RefreshPercent ) ->
	try
		case RefreshPercent =:= 0 of
			false ->
				true;
			true ->
				?DEBUG_OUT( "Convoy Failed, Quality Is High"),
				throw(-1)
		end,
		
		case random:uniform(10000) > RefreshPercent*10000/100 of
			false ->
				true;
			true ->
				?DEBUG_OUT( "Refresh Failed"),
				throw(-1)
		end,
		true
	catch
		_ -> false
	end.

costForGoldOrItem( Type, Quality, IsCostGold, FreeCnt ) ->
	try
		put("TempQuality", Quality),
		put("costForGoldOrItem_RandState", now()),
		MyFunc = fun(_Index)->
			CurQuality = get("TempQuality"),
			case CurQuality of
				undefined ->
					throw(-1);
				_ ->
					ConvoyList = getConvoyByTypeAndQuality(Type, CurQuality),
						case ConvoyList of
							{} ->
								throw(-1);
							_ ->
								case CurQuality < ?CarriageQuality_Max of
									true ->
										ConvoyList0 = getConvoyByTypeAndQuality(Type, CurQuality),
										case ConvoyList0 of
											{} ->
												throw(-1);
											_ ->
												case ConvoyList#convoyCfg.refreshPercent =:= 0 of
													false ->
														ok;
													true ->
														throw(-1)
												end,
												
												ItemID = ConvoyList0#convoyCfg.refreshConsumeID,
												ItemCnt = ConvoyList0#convoyCfg.refreshConsumeCnt,
												Money = ConvoyList0#convoyCfg.refreshMoney,
												case costGoldOrItem(ItemID, ItemCnt, Money, IsCostGold) of
													true ->
														true;
													false -> 
														case CurQuality =:= Quality of %% 第一次就失败
															true -> sendHighQuality(Type, CurQuality, FreeCnt, ?Convoy_Refresh_Quality_Item_Is_Lack);
															false -> sendHighQuality(Type, CurQuality, FreeCnt, ?Convoy_Refresh_Quality_Succ)
														end,
														throw(-1)
												end,

												{Rand, State1} = random:uniform_s(10, get("costForGoldOrItem_RandState") ),
												put("costForGoldOrItem_RandState", State1),
												Percent = ConvoyList#convoyCfg.refreshPercent div 10,
												case Rand > Percent of
													false ->
														put("TempQuality", CurQuality+1),
														true;
													true ->
														ok
												end
										end;
									false ->
										sendHighQuality(Type, CurQuality, FreeCnt, ?Convoy_Refresh_Quality_Succ),
										throw(-1)
								end
						end
				 end					
			end,
		 common:for( Quality, 10000, MyFunc ),
		 true
	catch
		_ -> false
	end.

sendHighQuality(Type, Quality, FreeCnt, SuccOrFailed) ->
	case get_Convoy_Info() of
		undefined ->
 			PlayerConvoy = #playerConvoy{playerId = player:getCurPlayerID(), taskID = 0, beginTime = 0, remainTime = 0, lowConvoyCD = ?LowConvoy_CD_MAX,
									highConvoyCD = ?HighConvoy_CD_MAX, curConvoyType = 0, curCarriageQuality = 0, 
								    deadCnt = 0, remainConvoyFreeRefreshCnt = ?Convoy_Refresh_Free};
		PlayerConvoy0 ->
			PlayerConvoy = PlayerConvoy0
	end,
	PlayerConvoy1 = setelement( #playerConvoy.curConvoyType, PlayerConvoy, Type),
	PlayerConvoy2 = setelement( #playerConvoy.curCarriageQuality, PlayerConvoy1, Quality),
	put("Convoy_Cur_Type", Type), %% 保存当前类型
	put("Convoy_Cur_Quality", Quality), %% 保存品质
	set_Convoy_Info(PlayerConvoy2),
	
	mySqlProcess:replacePlayerConvoy(PlayerConvoy2),
	Result = #pk_GS2U_CarriageQualityRefreshResult{
				retCode = SuccOrFailed,
				newConvoyType = Type,
				newCarriageQuality = Quality,
				freeCnt = FreeCnt},
	player:send(Result).

costBindedGold(BindGold) ->
	try
		Player = player:getCurPlayerRecord(),
		PlayBagGold = Player#player.gold,
		PlayBagBindGold = Player#player.goldBinded,
		ParamTuple1 = #token_param{changetype = ?Gold_Change_Convoy, param1 = get_User_Convoy_Task_ID()},
		case  PlayBagBindGold >= BindGold of
			true -> 
				playerMoney:decPlayerBindedGold(BindGold, ?Gold_Change_Convoy, ParamTuple1),
				true; %%绑定元宝足够
			false ->
				case PlayBagGold+PlayBagBindGold >= BindGold of
					true ->
						playerMoney:decPlayerBindedGold(PlayBagBindGold, ?Gold_Change_Convoy, ParamTuple1), %%先扣除绑定元宝
						RemainCostGold = BindGold-PlayBagBindGold, %%再扣除普通元宝
						ParamTuple2 = #token_param{changetype = ?Gold_Change_Convoy, param1 = get_User_Convoy_Task_ID()},
						playerMoney:decPlayerGold(RemainCostGold, ?Gold_Change_Convoy, ParamTuple2); %%普通元宝足够
					false -> throw(-1)
				end
		end,
		true
	catch
		_ ->false
	end.

costGoldOrItem( ItemID, ItemCnt, Gold, IsCostGold ) ->
	try
		%% 据配置消耗
		case ItemID > 0 of %% 优先扣除物品
			true ->
				[CanDec|CanDecItemInBagResult] = playerItems:canDecItemInBag(?Item_Location_Bag, ItemID,											
																			 ItemCnt, "all" ),
				case CanDec of
						true->
							playerItems:decItemInBag(CanDecItemInBagResult, ?Destroy_Item_Reson_CommitTask);
						false-> %% 扣除物品失败时
							case IsCostGold =:= 1 of %材料不足时,直接扣元宝
								true ->
									GoldValue = globalSetup:getGlobalSetupValue( #globalSetup.convoyGold ),
									case costBindedGold(GoldValue) of
										true -> true;
										false ->
											?DEBUG_OUT( "Convoy Gold Is Little"),
											throw(-1)
									end;
								false -> %% 失败
									?DEBUG_OUT( "Item Is Not Exit, Or Count Is Little" ),
									throw(-1)
							end
				end;	
			false ->
				case Gold > 0 of %% 优先检查绑定金钱
					false ->
						?DEBUG_OUT( "Convoy Cfg Is Failed "),
						throw(-1);
					true ->
						case costBindedGold(Gold) of
							true -> true;
							false ->
								?DEBUG_OUT( "Convoy Gold Is Little"),
								throw(-1)
						end
				end			
		end,
		true
	catch
		_ ->false
	end.

getConvoyStartActiveTimer1() ->
	try
		StartActiveTimer1 = get("StartActiveTimer1"),
		case StartActiveTimer1 of
			undefined ->
				ConvoyCfg = getConvoyByTypeAndQuality(?ConvoyType_Low, ?CarriageQuality_Excellent),
				case ConvoyCfg of
					{} -> throw(-1);
					_ ->
						put("StartActiveTimer1", ConvoyCfg#convoyCfg.specialHourMin1),
						ConvoyCfg#convoyCfg.specialHourMin1
				end;
			_ -> StartActiveTimer1
		end
	catch
		_ -> -1
	end.

getConvoyEndActiveTimer1() ->
	try
		EndActiveTimer1 = get("EndActiveTimer1"),
		case EndActiveTimer1 of
			undefined ->
				ConvoyCfg = getConvoyByTypeAndQuality(?ConvoyType_Low, ?CarriageQuality_Excellent),
				case ConvoyCfg of
					{} -> throw(-1);
					_ ->
						put("EndActiveTimer1", ConvoyCfg#convoyCfg.specialHourMax1),
						ConvoyCfg#convoyCfg.specialHourMax1
				end;
			_ -> EndActiveTimer1
		end
	catch
		_ -> -1
	end.

getConvoyStartActiveTimer2() ->
	try
		StartActiveTimer2 = get("StartActiveTimer2"),
		case StartActiveTimer2 of
			undefined ->
				ConvoyCfg = getConvoyByTypeAndQuality(?ConvoyType_Low, ?CarriageQuality_Excellent),
				case ConvoyCfg of
					{} -> throw(-1);
					_ ->
						put("StartActiveTimer2", ConvoyCfg#convoyCfg.specialHourMin2),
						ConvoyCfg#convoyCfg.specialHourMin2
				end;
			_ -> StartActiveTimer2
		end
	catch
		_ -> -1
	end.

getConvoyEndActiveTimer2() ->
	try
		EndActiveTimer2 = get("EndActiveTimer2"),
		case EndActiveTimer2 of
			undefined ->
				ConvoyCfg = getConvoyByTypeAndQuality(?ConvoyType_Low, ?CarriageQuality_Excellent),
				case ConvoyCfg of
					{} -> throw(-1);
					_ ->
						put("EndActiveTimer2", ConvoyCfg#convoyCfg.specialHourMax2),
						ConvoyCfg#convoyCfg.specialHourMax2
				end;
			_ -> EndActiveTimer2
		end
	catch
		_ -> -1
	end.

loadCarriageCfg() ->
	try
		case db:openBinData( "convoy.bin" ) of
			[] ->
				?ERROR_OUT( "loadConvoyCfg openBinData convoy.bin failed!" );
			ConvoyCfgData ->
				db:loadBinData(ConvoyCfgData, convoyCfg),
				ets:new( convoyCfgTableAtom, [set,protected,named_table, { keypos, #convoyCfg.id }] ),
				ConvoyCfgDataList = db:matchObject(convoyCfg, #convoyCfg{_='_'} ),
				
				Fun = fun( Record ) ->
							etsBaseFunc:insertRecord(convoyCfgTableAtom, Record)
					  end,
				lists:foreach(Fun, ConvoyCfgDataList),
				?DEBUG_OUT( "convoyCfgTable load succ" )
		end,

		case db:openBinData("guardbonus.bin") of
			[] ->
				?ERROR_OUT( "loadGuardbonusCfg openBinData guardbonus.bin failed!" );
			ConvoyAwardCfgData ->
				db:loadBinData(ConvoyAwardCfgData, convoyAwardCfg),
				ets:new( convoyAwardCfgTableAtom, [set,protected,named_table, { keypos, #convoyAwardCfg.id }] ),
				ConvoyAwardDataList = db:matchObject(convoyAwardCfg, #convoyAwardCfg{_='_'} ),
				
				Fun1 = fun( Record ) ->
							etsBaseFunc:insertRecord(convoyAwardCfgTableAtom, Record)
					  end,
				lists:foreach(Fun1, ConvoyAwardDataList),
				?DEBUG_OUT( "guardbonusCfgTable load succ" )
		end
	catch
		_ ->ok
	end.

%% 根据护送类型和品质输出对应列表
getConvoyByTypeAndQuality( Type, Quality )->
	try
		Q = ets:fun2ms( fun(Record) when (Record#convoyCfg.convoyType =:= Type) andalso (Record#convoyCfg.carriageQuality =:= Quality) ->Record end ),
		Result = ets:select(convoyCfgTableAtom, Q),
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

%% 根据护送类型和品质输出对应列表
getAwardByLevel( Level )->
	try
		Q = ets:fun2ms( fun(Record) when (Record#convoyAwardCfg.level =:= Level) ->Record end ),
		Result = ets:select(convoyAwardCfgTableAtom, Q),
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

set_Timer_Cnt( TimerValue ) ->
	put("NoticeConvoyLeftTimer", TimerValue).

get_Timer_Cnt() ->
	get("NoticeConvoyLeftTimer").

get_Convoy_Flag() ->
	try
		case get_Convoy_Info() of
			undefined ->
				throw(-1);
			PlayerConvoy ->
				case PlayerConvoy#playerConvoy.remainTime > 0 of
					true -> true;
					false -> false
				end
		end
	catch
		_ -> false
	end.

%% 记录免费刷新次数
set_Convoy_Free_Refresh_Cnt( ConvoyFreeRefreshCnt ) ->
	put("ConvoyFreeRefreshCnt", ConvoyFreeRefreshCnt).

%% 取出记录免费次数
get_Convoy_Free_Refresh_Cnt() ->
	get("ConvoyFreeRefreshCnt").

%% 保存护送信息
set_Convoy_Info( PlayerConvoy ) ->
	put("Carriage_PlayerConvoy", PlayerConvoy).

%% 取得护送信息
get_Convoy_Info() ->
	get("Carriage_PlayerConvoy").

%% 保存任务id,用于玩家下线时(玩家未正式开始接受护送任务)
set_User_Convoy_Task_ID( TaskID ) ->
    put("CovoryTaskID", TaskID).

%% 获取当前护送任务ID
get_User_Convoy_Task_ID() ->
	get("CovoryTaskID").