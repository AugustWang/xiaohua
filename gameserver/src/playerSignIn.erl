-module(playerSignIn).

-include("db.hrl").
-include("hdlt_logger.hrl").
-include("pc_player.hrl").
-include("gamedatadb.hrl").
-include("textDefine.hrl").
-include("itemDefine.hrl").
-include("daily.hrl").

-define(Player_Signin_Result_Success,0).
-define(Player_Signin_Result_AlreadySign,1).
-define(Player_Signin_Reset_Secs,4*60*60).

%%
%% Exported Functions
%%
-compile(export_all). 


-record(processSaveSigninInfo, {isAlreadySign,days,lastSignTime}).

%% get signin from db, and send to user
onGetSigninInfo(PlayerID) ->
	case get("ProcessSaveSigninInfo") of
		undefined->
		 	case mySqlProcess:get_playerSignin(PlayerID) of
		 		[] ->
		 			PlayerSigninInfo = #pk_GS2U_PlayerSigninInfo{isAlreadySign=0,days=0},
					LastSignTime = 0;
		 		[Signin|_]->
		 			%PlayerSigninInfo = fillPlayerSigninInfoByDbRecord(Signin),
					%% ->pk_GS2U_PlayerSigninInfo
					PlayerSigninInfo = fillPlayerSigninInfo(Signin#playerSignin.lastSignTime,Signin#playerSignin.alreadyDays),
					LastSignTime = Signin#playerSignin.lastSignTime
		 	end,
			
		 	put("ProcessSaveSigninInfo",#processSaveSigninInfo{isAlreadySign=PlayerSigninInfo#pk_GS2U_PlayerSigninInfo.isAlreadySign,
															   days=PlayerSigninInfo#pk_GS2U_PlayerSigninInfo.days,
															   lastSignTime=LastSignTime});
		ProcessSaveSigninInfo->
			case ProcessSaveSigninInfo#processSaveSigninInfo.isAlreadySign =:= 1 of
				false->
					PlayerSigninInfo = #pk_GS2U_PlayerSigninInfo{isAlreadySign=ProcessSaveSigninInfo#processSaveSigninInfo.isAlreadySign,
						days=ProcessSaveSigninInfo#processSaveSigninInfo.days};
				true ->	
					PlayerSigninInfo = fillPlayerSigninInfo(ProcessSaveSigninInfo#processSaveSigninInfo.lastSignTime,ProcessSaveSigninInfo#processSaveSigninInfo.days),
					put("ProcessSaveSigninInfo",#processSaveSigninInfo{isAlreadySign=PlayerSigninInfo#pk_GS2U_PlayerSigninInfo.isAlreadySign,
																	   days=PlayerSigninInfo#pk_GS2U_PlayerSigninInfo.days,
																	   lastSignTime=ProcessSaveSigninInfo#processSaveSigninInfo.lastSignTime})
			end
	end,
								
	?DEBUG_OUT( "--------onGetSigninInfo,~p",[PlayerSigninInfo] ),	
 	player:send(PlayerSigninInfo).


%% ->pk_GS2U_PlayerSigninInfo
fillPlayerSigninInfo(LastSignTime,AlreadyDays) ->
	Now = common:getNowSeconds(),
	TodayResetSecs = common:getTodayBeginSeconds()+?Player_Signin_Reset_Secs,
	case Now > TodayResetSecs of
		true->TodayStartSecs=TodayResetSecs;
		false->TodayStartSecs=TodayResetSecs-86400
	end,
	YesterdayStartSecs = TodayStartSecs - 86400,
	if
		LastSignTime > TodayStartSecs -> %%今天已签到
			#pk_GS2U_PlayerSigninInfo{isAlreadySign=1,days=AlreadyDays};
		LastSignTime >= YesterdayStartSecs -> %%昨天签到了
			#pk_GS2U_PlayerSigninInfo{isAlreadySign=0,days=AlreadyDays};
		true-> %%昨天没有签到
			#pk_GS2U_PlayerSigninInfo{isAlreadySign=0,days=0}
	end.


	

%% 
%% 1）签到7天为一个周期，当签满7天之后将重置所有的签到重新开始。
%% 2）每天每名玩家只可以签到一次，签到之后可领取签到奖励。
%% 3）今日签到后，签到按钮变为不可点击。
%% 4）玩家点击签到按钮后立刻获得相应的签到礼包，如果玩家包满则以邮件的形式发送给玩家。
%% 5）玩家在签到过程中如果有一天未能签到则清空之前的签到累积天数，在下次签到的时候重新计算。
onSignin(PlayerID) ->
	case get("ProcessSaveSigninInfo") of
		undefined->
			?ERROR_OUT( "logical error,PlayerSigninInfo is undefined" ),
			ok;
		ProcessSaveSigninInfo->
			case ProcessSaveSigninInfo#processSaveSigninInfo.isAlreadySign =:= 1 of
				true ->
					SignInResult = #pk_GS2U_PlayerSignInResult{nResult=?Player_Signin_Result_AlreadySign,awardDays=0},
					?DEBUG_OUT( "--------onSignin,result ~p",[SignInResult] ),	
					player:send(SignInResult);
				false->
					case ProcessSaveSigninInfo#processSaveSigninInfo.days >= 7 of
						true->AwardDays0 = 0;
						false->AwardDays0 = ProcessSaveSigninInfo#processSaveSigninInfo.days
					end,
					AwardDays = (AwardDays0 + 1) rem 8,
					SignInResult = #pk_GS2U_PlayerSignInResult{nResult=?Player_Signin_Result_Success,awardDays=AwardDays},
					?DEBUG_OUT( "--------onSignin,result ~p",[SignInResult] ),	
					player:send(SignInResult),
					LastSignTime = common:getNowSeconds(),
					PlayerSignin = #playerSignin{playerId=PlayerID,alreadyDays=AwardDays,lastSignTime=LastSignTime},
					mySqlProcess:replacePlayerSignin(PlayerSignin),
					
					%%日常检测
					daily:onDailyFinishCheck(?DailyType_Sign, 0),
					%% award
					awardForSignin(PlayerID,AwardDays),	
					put("ProcessSaveSigninInfo",#processSaveSigninInfo{isAlreadySign=1,days=AwardDays,lastSignTime=LastSignTime})
			end
	end.

awardForSignin(PlayerID,AwardDays)->
	% get ItemDataID by AwardDays and cfg
	SignCfg = etsBaseFunc:readRecord( signCfgTable, AwardDays ),
	case SignCfg of
		{}->?ERROR_OUT( "cant find the sign cfg for awarddays:~p",[AwardDays] );
		_->
			%% award to bag
			?DEBUG_OUT( "--------awardForSignin,AwardDays ~p",[AwardDays] ),	
			%% send normal items
			IsBagFull1 = awardItemsToPlayer(PlayerID,AwardDays,false,
				SignCfg#signCfg.item_1, SignCfg#signCfg.num_1,SignCfg#signCfg.item_2, SignCfg#signCfg.num_2),
			IsBagFull2 = awardItemsToPlayer(PlayerID,AwardDays,IsBagFull1,
							SignCfg#signCfg.item_3, SignCfg#signCfg.num_3,SignCfg#signCfg.item_4, SignCfg#signCfg.num_4),
			%% award special items for vip player
 			case vip:isVipPlayer() of
 				true ->
 					?DEBUG_OUT( "--------awardForSignin, it's vip player" ),	
 					IsBagFull3 = awardItemsToPlayer(PlayerID,AwardDays,IsBagFull2,
 						SignCfg#signCfg.spitem_1, SignCfg#signCfg.spnum_1,SignCfg#signCfg.spitem_2, SignCfg#signCfg.spnum_2),
 					awardItemsToPlayer(PlayerID,AwardDays,IsBagFull3,SignCfg#signCfg.spitem_3, SignCfg#signCfg.spnum_3,0, 0);
 				false ->
					?DEBUG_OUT( "--------awardForSignin, it's not vip player" ),	
 					ok
 			end
	end.

%% -> true or false mean whether the bag is full
awardItemsToPlayer(PlayerID,AwardDays,IsBagFull,ItemId1,ItemNum1,ItemId2,ItemNum2) ->
	case IsBagFull of
		true ->
			Str = io_lib:format(?TEXT_SIGN_IN_CONTENT, [AwardDays]),
			?DEBUG_OUT( "--------awardItemsToPlayer,send mail" ),
			mail:sendSystemMailToPlayer( PlayerID, ?TEXT_SIGN_IN, ?TEXT_SIGN_IN_TITLE, 
									Str, ItemId1,ItemNum1, true, ItemId2,ItemNum2, true, 0 ),
			true;
		false ->
			case playerItems:addItemToPlayerByItemDataID( ItemId1,ItemNum1, true, ?Get_Item_Reson_Signin ) of
				true->
					IsBagFullNew = false;
				false->
					%% if bag is full, award by mail
					IsBagFullNew = true			
			end,
			
			case IsBagFullNew of
				true -> 
					?DEBUG_OUT( "--------awardItemsToPlayer,send mail" ),
					Str = io_lib:format(?TEXT_SIGN_IN_CONTENT, [AwardDays]),
					mail:sendSystemMailToPlayer( PlayerID, ?TEXT_SIGN_IN, ?TEXT_SIGN_IN_TITLE, 
											Str, ItemId1,ItemNum1, true, ItemId2,ItemNum2, true, 0 ),
					true;
				false ->
					case ItemId2 =:= 0 orelse ItemNum2 =:= 0 of
						true ->
							false;
						false ->
							%% has item2
							case playerItems:addItemToPlayerByItemDataID( ItemId2,ItemNum2, true, ?Get_Item_Reson_Signin ) of
								true->
									false; 
								false->
									%% if bag is full, award by mail
									Str = io_lib:format(?TEXT_SIGN_IN_CONTENT, [AwardDays]),
									?DEBUG_OUT( "--------awardItemsToPlayer,send mail" ),
									mail:sendSystemMailToPlayer( PlayerID, ?TEXT_SIGN_IN, ?TEXT_SIGN_IN_TITLE, 
															Str, ItemId2,ItemNum2, true, 0,0, true, 0 ),
									true			
							end
					end
			end
	end.
	



%%加载签到配置表
%-record(signCfg, {continuousDay,rewardItemId}).
loadSignCfgTable()->
	case db:openBinData( "sign.bin" ) of
		[] ->
			?ERROR_OUT( "loadSignCfgTable openBinData sign.bin false []" );
		SignCfgData ->
			db:loadBinDataNotAddExtrafield( SignCfgData, signCfg ),
			
			SignCfgTable = ets:new( 'signCfgTable', [protected, named_table, {read_concurrency,true}, { keypos, #signCfg.continuousDay }] ),
			
			SignCfgList = db:matchObject(signCfg,  #signCfg{_='_'} ),
			
			MyFunc = fun( Record )->
							 etsBaseFunc:insertRecord(SignCfgTable, Record)
					 end,
			lists:map( MyFunc, SignCfgList ),
			?DEBUG_OUT( "load sign.bin succ" )
	end.

