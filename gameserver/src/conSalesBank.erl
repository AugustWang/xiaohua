%% Author: Administrator
%% Created: 2012-9-27
%% Description: TODO: Add description to conSalesBank
-module(conSalesBank).


%% add by wenziyong for gen server
-behaviour(gen_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%%
%% Include files
%%
-include("mysql.hrl").
-include("db.hrl").
-include("hdlt_logger.hrl").
-include("conSalesBank.hrl").
-include("itemDefine.hrl").
-include("package.hrl").
-include("gamedatadb.hrl").
-include("condition_compile.hrl").
-include("globalDefine.hrl").

-include_lib("stdlib/include/qlc.hrl").
-include_lib("textDefine.hrl").


%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%

start_link() ->
	?DEBUG_OUT("consignment sales thread begin"),
	gen_server:start_link({local,conSalesPid},?MODULE, [], [{timeout,?Start_Link_TimeOut_ms}]).



init([]) ->
	loadConSalesDBItemToMem(),
	erlang:send_after(?ConBank_UpdateTimer_Time, self(),{timerUpdate}),
    {ok, {}}.


handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.



terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%载入存档数据库的数据到内存数据库
loadConSalesDBItemToMem() ->
	
	OrderTable = ets:new(playerOrderTable, [private, { keypos, #playerOrderTable.playerId }]),

	
	%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.playerConSalesOrderTable, OrderTable),
	put("playerOrderTable", OrderTable),
	put("Time_8H", []),
	put("Time_12H", []),
	put("Time_24H", []),
	put("ConTimeMeter", 0),
				
	ConItemDB = mySqlProcess:get_all_conSalesItemDB(),
	case ConItemDB of
		[] ->
			?LOG_OUT("consignment sales bank is empty!");
		_ ->
			Fun = fun(ConRecord) ->
						  %%ItemCfg = ItemDB#conSalesItemDB.itemDBId,
							PlayerList = mySqlProcess:get_playerGamedata_list_by_id(ConRecord#conSalesItemDB.playerId),
%% 							case db:readRecord(player, ConRecord#conSalesItemDB.playerId) of
							case PlayerList of
								[] ->
									?ERROR_OUT("loadDBItemToMem read player failed!  id= ~p", [ConRecord#conSalesItemDB.playerId]); 
								[Player]->
									ItemDBList = mySqlProcess:get_itemDbList_by_id(ConRecord#conSalesItemDB.itemDBId),
									case ItemDBList of
										[] ->
											?ERROR_OUT("loadDBItemToMem read r_itemDB failed!  id= ~p", [ConRecord#conSalesItemDB.itemDBId]); 
										[ItemDB] ->
											case itemModule:getItemCfgDataByID(ItemDB#r_itemDB.item_data_id) of
												[]->
													?ERROR_OUT("loadDBItemToMem getItemCfgDataByID failed!  id= ~p", [ItemDB#r_itemDB.item_data_id]); 
												ItemCfg ->
													
													%%构建玩家交易行订单table
													case etsBaseFunc:readRecord(OrderTable, Player#player_gamedata.id) of
														{}->
															Order = #playerOrderTable{playerId=Player#player_gamedata.id, 
																					 orderList=[ConRecord#conSalesItemDB.conSalesId]},
															etsBaseFunc:insertRecord(OrderTable, Order);
														A ->
															B = A#playerOrderTable.orderList ++ [ConRecord#conSalesItemDB.conSalesId],
															etsBaseFunc:changeFiled(OrderTable, A#playerOrderTable.playerId,  #playerOrderTable.orderList, B)
													end,
													
													
													%%将订单详细数据存入内存数据库
													Con = #conSalesItem{conSalesId=ConRecord#conSalesItemDB.conSalesId, 
																		conSalesMoney=ConRecord#conSalesItemDB.conSalesMoney,
																		groundingTime=ConRecord#conSalesItemDB.groundingTime, 
																		timeType=ConRecord#conSalesItemDB.timeType,
																		playerId=ConRecord#conSalesItemDB.playerId, 
																		playerName=Player#player_gamedata.name,
																		itemDB=ItemDB, 
																		itemType=ItemCfg#r_itemCfg.itemType, 
																		itemDetType=ItemCfg#r_itemCfg.detailedType,
																		itemQuality=ItemCfg#r_itemCfg.quality,
																		itemLevel=ItemCfg#r_itemCfg.level, 
																		itemOcc=ItemCfg#r_itemCfg.usePlayerClass,
																		lockPlayerId=0, lockTime=0},
													
													db:writeRecord(Con),
													
													case Con#conSalesItem.timeType of
														?ConSales_SellTime_Type_8H ->
															put("Time_8H", get("Time_8H") ++ [#itemTimer{startTime=Con#conSalesItem.groundingTime, dataID=Con#conSalesItem.conSalesId}] );
														?ConSales_SellTime_Type_12H ->
															put("Time_12H", get("Time_12H") ++ [#itemTimer{startTime=Con#conSalesItem.groundingTime, dataID=Con#conSalesItem.conSalesId}] );
														?ConSales_SellTime_Type_24H ->
															put("Time_24H", get("Time_24H") ++ [#itemTimer{startTime=Con#conSalesItem.groundingTime, dataID=Con#conSalesItem.conSalesId}] )
													end
											end 
									end
							end
				  end,
			lists:map(Fun, ConItemDB),
			FunSort = fun(X,Y) ->
							  X#itemTimer.startTime =< Y#itemTimer.startTime
					  end,
			put("Time_8H", lists:sort(FunSort, get("Time_8H"))),
			put("Time_12H", lists:sort(FunSort, get("Time_12H"))),
			put("Time_24H", lists:sort(FunSort, get("Time_24H"))),
			?DEBUG_OUT("loadConSalesDBItemToMem finish!"),
			%%先update一次
			updateTime()
	end.


handle_info(Info, StateData)->		
	
	put("ConRecieve", true),

	try
	case Info of
		{quit}->
			?LOG_OUT( "consignment sales bank Recieve quit" ),
			put( "ConRecieve", false );
		{timerUpdate} ->
			updateTime(),
			erlang:send_after(?ConBank_UpdateTimer_Time,self(), {timerUpdate});
		{groundingAsk, Pid, Id, Pk} ->
			groundingAsk(Pid, Id, Pk);
		%%上架
		{grounding, GroundingItem} ->
			groundingItem(GroundingItem);
		%%下架
		{takeDown, Pid, PlayerId, ConSalesId} ->
			takeDown(Pid, PlayerId, ConSalesId);
		%%购买请求
		{buyAsk, Pid, PlayerID, ConId} ->
			onBuyAsk(Pid, PlayerID, ConId);
		%%购买
		{buyItem, Pid, PlayerID, ConId} ->
			buyItem(Pid, PlayerID, ConId);
		%%查找
		{find, FindOption, Pid} ->
			findItem(FindOption, Pid);
		%%获取玩家出售的物品列表
		{getSellList, PlayerId} ->
			getSellList(PlayerId)
	end,
	
	case get("ConRecieve") of
		true->{noreply, StateData};
		false->{stop, normal, StateData}
	end

	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[?MODULE,_Why, erlang:get_stacktrace()] ),
			{noreply, StateData}
	end.


updateTime() ->
	NowTime = common:timestamp(),
	put("DecList", []),
	try
		FunTime_8H = fun(Timer) ->
							 case (Timer#itemTimer.startTime+?ConSales_Time_8H) < NowTime of
								 true->
									 takeDownTimeOut(Timer#itemTimer.dataID),
									 put("DecList", get("DecList") ++ [Timer]);
								 false ->
									 throw(0)
							 end 
					 end,
		lists:map(FunTime_8H, get("Time_8H")),
		put("Time_8H", get("Time_8H")--get("DecList"))
	catch
		_-> ok
	end,

	put("DecList", []),
	try
		FunTime_12H = fun(Timer) ->
							case (Timer#itemTimer.startTime+?ConSales_Time_12H) < NowTime of
								true->
									takeDownTimeOut(Timer#itemTimer.dataID),
									put("DecList", get("DecList") ++ [Timer]);
								false ->
									throw(0)
						 	end
					end,
		lists:map(FunTime_12H, get("Time_12H")),
		put("Time_12H", get("Time_12H")--get("DecList"))
	catch
		_->ok
	end,
		put("DecList", []),
	try
		FunTime_24H = fun(Timer) ->
							case (Timer#itemTimer.startTime+?ConSales_Time_24H) < NowTime of
								true->
									takeDownTimeOut(Timer#itemTimer.dataID),
									put("DecList", get("DecList") ++ [Timer]);
								false ->
									throw(0)
							end
					end,
		lists:map(FunTime_24H, get("Time_24H")),
		put("Time_24H", get("Time_24H")--get("DecList"))
	catch
		_-> ok
	end.

getPid() -> 
	conSalesPid.

getSellList(PlayerId) ->
	put("TempValue", []),
	case etsBaseFunc:readRecord(main:getCurPlayerOrderTable(), PlayerId) of
		{} ->
			ok;
		P ->
			MapFun = fun(Id) ->
							 case getConSalesItemByConSalesId(Id) of
								 {} ->
									 ok;
								 R ->
								   Item = #pk_ConSalesItem{conSalesId=R#conSalesItem.conSalesId,
													conSalesMoney=R#conSalesItem.conSalesMoney,
													groundingTime=R#conSalesItem.groundingTime,
													timeType=R#conSalesItem.timeType,
													playerId=R#conSalesItem.playerId,
									  				playerName=R#conSalesItem.playerName,
									  				itemDBId=R#conSalesItem.itemDB#r_itemDB.id,
									 				itemId=R#conSalesItem.itemDB#r_itemDB.item_data_id,
									 				itemCount=R#conSalesItem.itemDB#r_itemDB.amount,
									  				itemType=R#conSalesItem.itemType,
									  				itemQuality=R#conSalesItem.itemQuality,
									  				itemLevel=R#conSalesItem.itemLevel,
									  				itemOcc=R#conSalesItem.itemOcc},
								   put("TempValue", get("TempValue") ++ [Item] )
							 end
					 end,
			lists:map(MapFun, P#playerOrderTable.orderList)
	end,
	%%将查找到的订单发送给玩家
	player:sendToPlayer(PlayerId, #pk_ConSales_GetSelfSell_Result{itemList=get("TempValue")}),
	ok.

groundingAsk(Pid, Id, Pk) ->
	case etsBaseFunc:readRecord( main:getCurPlayerOrderTable(), Id) of
		{} ->
			Pid ! {groundingAskResult, 0, Pk};
		A ->
			Pid ! {groundingAskResult, length(A#playerOrderTable.orderList), Pk}
	end.

%%上架
groundingItem(GroundingItem) ->
	%%写入存档数据库
	ConDB = #conSalesItemDB{conSalesId = db:memKeyIndex(consalesitemdb), % persistent 
							conSalesMoney = GroundingItem#groundingItem.money,
							groundingTime = common:timestamp(),
							timeType = GroundingItem#groundingItem.timeType,
							playerId = GroundingItem#groundingItem.playerId, 
							itemDBId = GroundingItem#groundingItem.itemDB#r_itemDB.id},
	mySqlProcess:insert_conSalesItemDB(ConDB), 

	
	%%写入内存数据库
	Con = #conSalesItem{conSalesId = ConDB#conSalesItemDB.conSalesId, 
						conSalesMoney = ConDB#conSalesItemDB.conSalesMoney,
						groundingTime=ConDB#conSalesItemDB.groundingTime, 
						timeType=ConDB#conSalesItemDB.timeType,
						playerId=ConDB#conSalesItemDB.playerId, 
						playerName=GroundingItem#groundingItem.playerName,
						itemDB=GroundingItem#groundingItem.itemDB, 
						itemType=GroundingItem#groundingItem.itemCfg#r_itemCfg.itemType, 
						itemDetType=GroundingItem#groundingItem.itemCfg#r_itemCfg.detailedType,
						itemQuality=GroundingItem#groundingItem.itemCfg#r_itemCfg.quality,
						itemLevel=GroundingItem#groundingItem.itemCfg#r_itemCfg.level, 
						itemOcc=GroundingItem#groundingItem.itemCfg#r_itemCfg.usePlayerClass,
						lockPlayerId=0, lockTime=0},
	db:writeRecord(Con),
	
	%%写入计时列表
	case Con#conSalesItem.timeType of
		?ConSales_SellTime_Type_8H ->
			put("Time_8H", get("Time_8H") ++ [#itemTimer{startTime=Con#conSalesItem.groundingTime, dataID=Con#conSalesItem.conSalesId}] );
		?ConSales_SellTime_Type_12H ->
			put("Time_12H", get("Time_12H") ++ [#itemTimer{startTime=Con#conSalesItem.groundingTime, dataID=Con#conSalesItem.conSalesId}] );
		?ConSales_SellTime_Type_24H ->
			put("Time_24H", get("Time_24H") ++ [#itemTimer{startTime=Con#conSalesItem.groundingTime, dataID=Con#conSalesItem.conSalesId}] )
	end,
	
	%%写入玩家订单ets
	case etsBaseFunc:readRecord( main:getCurPlayerOrderTable(), GroundingItem#groundingItem.playerId) of
		{}->
			Order = #playerOrderTable{playerId=GroundingItem#groundingItem.playerId,
									  orderList=[ConDB#conSalesItemDB.conSalesId]},
			etsBaseFunc:insertRecord(main:getCurPlayerOrderTable(), Order);
		A ->
			B = A#playerOrderTable.orderList ++ [ConDB#conSalesItemDB.conSalesId],
			etsBaseFunc:changeFiled(main:getCurPlayerOrderTable(), A#playerOrderTable.playerId,  #playerOrderTable.orderList, B)
	end.

takeDownTimeOut(ConSalesId) ->
	case getConSalesItemByConSalesId(ConSalesId) of
		{} ->
			ok;
		R ->
			case R#conSalesItem.timeType of
				?ConSales_SellTime_Type_8H ->
					Time = 8;
				?ConSales_SellTime_Type_12H ->
					Time = 12;
				?ConSales_SellTime_Type_24H ->
					Time = 24
			end,
			
			Str = io_lib:format(?TEXT_CONSALESBANK_OUTTIME_CONTENT, [R#conSalesItem.itemDB#r_itemDB.item_data_id, Time]),
			%%将物品邮寄给卖家
			mail:sendSystemMailToPlayer_ItemRecord(
			  R#conSalesItem.playerId, 
			  ?TEXT_CONSALESBANK, 
			  ?TEXT_CONSALESBANK_OUTTIME, 
			  Str, 
			  R#conSalesItem.itemDB, 0),
			%%删除订单
			deleteConSalesOrder(ConSalesId, ?conSales_delete_Reason_timeOut)
	end.
			

takeDown(Pid, PlayerId, ConSalesId) ->
	case ConSalesId of
		0 ->
			%%下架所有订单
			case etsBaseFunc:readRecord( main:getCurPlayerOrderTable(), PlayerId) of
				{} ->
					ok;
				R ->
					Fun = fun(Id) ->
								  player:sendToPlayer(PlayerId, 
													   #pk_ConSales_TakeDown_Result{
																					allTakeDown=1,  
																					result=takeDownItem(Pid, PlayerId, Id, ?conSales_delete_Reason_takeDown)})
						  end,
					lists:map(Fun, R#playerOrderTable.orderList)
			end;
		_ ->
			%%下架单个订单
			player:sendToPlayer(PlayerId, #pk_ConSales_TakeDown_Result{
																	   allTakeDown=0, 
																	   result=takeDownItem(Pid, PlayerId, ConSalesId,?conSales_delete_Reason_takeDown)})
	end.

takeDownItem(_Pid, PlayerId, ConSalesId, Reson) ->
	case getConSalesItemByConSalesId(ConSalesId) of
		{} ->
			%%已经被买走
			?ConBank_TakeDown_AlreadySell;
		R ->
			case R#conSalesItem.playerId =:= PlayerId of
				true ->
					TimeNow = common:timestamp(),
					case (R#conSalesItem.groundingTime+?TakeDown_Protect_Time) < TimeNow of
						true ->
							case (R#conSalesItem.lockTime=:=0) orelse
									 ((TimeNow-R#conSalesItem.lockTime)>=?buyConSalesOvertime) of
								true ->
									Str = io_lib:format(?TEXT_CONSALESBANK_CANCELSELL_CONTENT, [R#conSalesItem.itemDB#r_itemDB.item_data_id]),
									%%将物品邮寄给卖家
									mail:sendSystemMailToPlayer_ItemRecord(
									  PlayerId, 
									  ?TEXT_CONSALESBANK, 
									  ?TEXT_CONSALESBANK_CANCELSELL, 
									  Str, 
									  R#conSalesItem.itemDB, 0),
									%%删除订单
									deleteConSalesOrder(ConSalesId, Reson),
									?ConBank_TakeDown_Succ;
								false ->
									%%正在被购买中。不能下架
									?ConBank_TakeDown_Buying
							end;
						false ->
							?ConBank_TakeDown_ProtectTime
						end;
				false->
					%%自己 不是本订单的卖家
					?ConBank_TakeDown_NotSeller
			end
	end.


onBuyAsk(Pid, PlayerID, ConId) ->
	case getConSalesItemByConSalesId(ConId) of
		{} ->
			Pid ! {buyAskReturn, {}};
		R ->
			case (R#conSalesItem.lockTime=:=0) orelse 
					 ((common:timestamp()-R#conSalesItem.lockTime)>=?buyConSalesOvertime) of
				true ->
					%%锁定订单
					db:changeFiled(conSalesItem, R, #conSalesItem.lockPlayerId, PlayerID),
					db:changeFiled(conSalesItem, R, #conSalesItem.lockTime, common:timestamp()),
					
					Pid ! {buyAskReturn, R};
				false ->
					Pid ! {buyAskReturn, {}}
			end
	end.


buyItem(Pid, PlayerID, ConId) ->
	case getConSalesItemByConSalesId(ConId) of
		{} ->
			?ERROR_OUT("buyItem getConSalesItemByConSalesId fail!  playerID = ~p, ConId = ~p", [PlayerID, ConId]);
		R ->
			Str = io_lib:format(?TEXT_CONSALESBANK_BUY_SUCC_CONTENT, [R#conSalesItem.conSalesMoney, R#conSalesItem.itemDB#r_itemDB.item_data_id]),
			%%购买成功，邮寄给物品给购买玩家并且邮寄金钱给出售玩家
			mail:sendSystemMailToPlayer_ItemRecord(
			  PlayerID, 
			  ?TEXT_CONSALESBANK, 
			  ?TEXT_CONSALESBANK_BUY_SUCC, 
			  Str, 
			  R#conSalesItem.itemDB, 0),

			%%mail:XXXXX
			case erlang:trunc(R#conSalesItem.conSalesMoney*?BankTrade_Money+0.5) of
				0 ->
					Str2 = io_lib:format(?TEXT_CONSALESBANK_SELL_SUCC_CONTENT, [R#conSalesItem.itemDB#r_itemDB.item_data_id, 1, R#conSalesItem.conSalesMoney-1]),
					mail:sendSystemMailToPlayer_Money(
					  R#conSalesItem.playerId, 
					  ?TEXT_CONSALESBANK, 
					  ?TEXT_CONSALESBANK_SELL_SUCC, 
					  Str2, 
					  R#conSalesItem.conSalesMoney-1);
				M ->
					Str2 = io_lib:format(?TEXT_CONSALESBANK_SELL_SUCC_CONTENT, [R#conSalesItem.itemDB#r_itemDB.item_data_id, M, R#conSalesItem.conSalesMoney-M]),
					mail:sendSystemMailToPlayer_Money(
					  R#conSalesItem.playerId, 
					  ?TEXT_CONSALESBANK, 
					  ?TEXT_CONSALESBANK_SELL_SUCC, 
					  Str2, 
					  R#conSalesItem.conSalesMoney-M)
			end,
			%%删除订单
			Pid ! {conBankDelOder, R},
			deleteConSalesOrder(ConId, ?conSales_delete_Reason_takeDown)
	end.


findItem(FindOption, Pid) ->
	
	%%排序函数
	OrderFun = fun(X,Y) ->
					   case X#conSalesItem.itemQuality > Y#conSalesItem.itemQuality of
						   true ->
							   true;
						   false ->
							   case X#conSalesItem.itemQuality =:= Y#conSalesItem.itemQuality of
								   true ->
									   case X#conSalesItem.itemDB#r_itemDB.item_data_id > Y#conSalesItem.itemDB#r_itemDB.item_data_id of
										   true ->
											   true;
										   false ->
											   case X#conSalesItem.itemDB#r_itemDB.item_data_id =:= Y#conSalesItem.itemDB#r_itemDB.item_data_id of
												   true ->
													   (X#conSalesItem.conSalesId >= Y#conSalesItem.conSalesId);
												   false ->
													   false
											   end
									   end;
								   false ->
									   false
							   end
					   end
			   end,
	
	%%读取函数
	Fun = fun() ->
				  QH = qlc:sort(qlc:q([X||X<-mnesia:table(conSalesItem),
										  
										  (case FindOption#findOption.ignoreOption /= 0 of
											  true ->
												  true;
											  false ->
												  false
										  end) orelse
										  ((case FindOption#findOption.type=:=?Item_Type_Count of
											  true ->
												  true;
											  false ->
												  case (X#conSalesItem.itemType=:=FindOption#findOption.type) of
													  true->
														  case FindOption#findOption.type of 
															  ?Item_HPMP->
																  case FindOption#findOption.detType =:= ?HPMP_Type_Count of
																	  true->true;
																	  false->(FindOption#findOption.detType=:= X#conSalesItem.itemDetType)
																  end;
															  ?Item_Func->													  
																  case FindOption#findOption.detType =:= ?Func_Type_Count of
																	  true->true;
																	  false->(FindOption#findOption.detType=:= X#conSalesItem.itemDetType)
																  end;
															  ?Item_GoldCard->
																  case FindOption#findOption.detType =:= ?GoldCard_Type_Count of
																	  true->true;
																	  false->(FindOption#findOption.detType=:= X#conSalesItem.itemDetType)
																  end;
															  ?Item_SkillBook->
																  case FindOption#findOption.detType =:= ?SkillBook_Type_Count of
																	  true->true;
																	  false->(FindOption#findOption.detType=:= X#conSalesItem.itemDetType)
																  end;
															  ?Item_Stone-> 
																  case FindOption#findOption.detType =:= ?Item_Stone_Type_Count of
																	  true->true;
																	  false->(FindOption#findOption.detType=:= X#conSalesItem.itemDetType)
																  end;
															  _ ->true 
														  end;
													  false->
														  false
												  end
										  end) andalso 
											  (case (FindOption#findOption.levelMin =:= 0) or (FindOption#findOption.levelMax =:= 0) of
												   true ->
													   true;
												   false ->
													   ((X#conSalesItem.itemLevel >= FindOption#findOption.levelMin) andalso
																(X#conSalesItem.itemLevel =< FindOption#findOption.levelMax))
											   end) andalso
											  (case FindOption#findOption.occ =:= 0 of
												   true ->
													   true;
												   false ->
													   (X#conSalesItem.itemOcc =:= FindOption#findOption.occ)
											   end) andalso
											  (case FindOption#findOption.quality =:= ?Item_Quality_Count of 
												   true ->
													   true;
												   false ->
													   (X#conSalesItem.itemQuality =:= FindOption#findOption.quality)
											   end) andalso 
											   (case FindOption#findOption.idLimit =:= 0 of
													true->
														true;
													false->
														lists:any(fun(Id) ->
																		  Id =:= X#conSalesItem.itemDB#r_itemDB.item_data_id
																  end, FindOption#findOption.idList)
												end))
									  
									  ]),[{order, OrderFun}]),
				  Qc=qlc:cursor(QH), 
				  
				  qlc:next_answers(Qc, all_remaining)
		  end,
	{atomic,L} = mnesia:transaction(Fun),
	
	Pid ! {findResult, L}.


getConSalesItemByConSalesId( ConSalesId ) ->
	case db:readRecord(conSalesItem, ConSalesId) of
		[] ->
			{};
		[Record|_] ->
			Record
	end.

getPlayerOrderListByPlayerId(PlayerId) ->
	case etsBaseFunc:readRecord( main:getCurPlayerOrderTable(), PlayerId) of
		{} ->
			[];
		A ->
			Fun = fun(R) ->
				  getConSalesItemByConSalesId(R)
		  	end,
			lists:map(Fun, A#playerOrderTable.orderList)
	end.


deleteConSalesOrder(ConSalesId, _Reason) ->
	case getConSalesItemByConSalesId(ConSalesId) of
		{} ->
			ok;
		R ->
			%%将订单从数据库删除
			db:delete(conSalesItem, ConSalesId),
			mySqlProcess:delete_conSalesItemDB(ConSalesId),
			
			%%将订单从玩家订单ets中删除
			case etsBaseFunc:readRecord( main:getCurPlayerOrderTable(), R#conSalesItem.playerId) of
				{} ->
					ok;
				A ->
					OderList = A#playerOrderTable.orderList -- [ConSalesId],
					etsBaseFunc:changeFiled(main:getCurPlayerOrderTable(), R#conSalesItem.playerId, #playerOrderTable.orderList, OderList)
			end
	end.

















