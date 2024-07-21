%% Author: Administrator
%% Created: 2012-10-18
%% Description: TODO: Add description to playerTrade
-module(playerTrade).

%%
%% Include files
%%
-include("db.hrl").
-include("playerDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("conSalesBank.hrl").
-include("itemDefine.hrl").
-include("trade.hrl").
-include("logdb.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
%%--------------------------------交易-------------------------------------------

%%下线处理
onPlayerOffLine() ->
	%%有交易主动取消交易
	case get("TradeTargetPid") of
		0 ->
			ok;
		_ ->
			cancelTrade(?tradePerson_Self, ?tradeCancel_PlayerOffLine)
	end.

tradeLockItem(ItemDB, Lock) ->
	playerItems:setLockPlayerBagCell(ItemDB#r_itemDB.location, ItemDB#r_itemDB.cell, Lock).

on_TradeAsk_C2S(_Socket,Pk) ->
	case get("TradeTargetPid") of
		%%当前没有交易，可以继续
		0 ->
			case player:getCurPlayerID() /= Pk#pk_TradeAsk.playerID of
				true ->
					case player:getPlayerPID(Pk#pk_TradeAsk.playerID) of
						0 ->
							%%发送交易请求失败给客户端
							player:send(#pk_TradeAskResult{playerID=Pk#pk_TradeAsk.playerID, playerName=Pk#pk_TradeAsk.playerName, result=?tradeAskResult_Fail});
						Pid ->
							%%向目标玩家进程发送交易请求
							Pid ! {tradeAsk, self(), player:getCurPlayerID(), player:getCurPlayerProperty(#player.name)}		
					end;
				false ->
					ok
			end;
		_ ->
			ok
	end.


onTradeAsk_S2S(PID, PlayerID, PlayerName) ->
	case get("TradeTargetPid") of
		0->
			%%发送交易请求给玩家
			player:send(#pk_TradeAsk{playerID=PlayerID, playerName=PlayerName});
		_->
			%%正在交易返回失败
			PID ! {tradeAskReturn, player:getCurPlayerID(), player:getCurPlayerProperty(#player.name), ?tradeAskResult_busy}
	end.

on_TradeAskResult_C2S(_Socket,Pk) ->
	case get("TradeTargetPid") of
		%%当前没有交易，可以继续
		0 ->
			case player:getPlayerPID(Pk#pk_TradeAskResult.playerID) of
				0 ->
					ok;
				Pid ->
					%%向目标玩家进程返回交易请求的回复
					Pid ! {tradeAskReturn, player:getCurPlayerID(), player:getCurPlayerProperty(#player.name), Pk#pk_TradeAskResult.result}
			end;
		_->
			ok
	end.

onTradeAskResult_S2S(PlayerID, PlayerName, Result) -> 
	case get("TradeTargetPid") of
		0->
			%%发送交易请求回执给玩家
			player:send(#pk_TradeAskResult{playerID=PlayerID, playerName=PlayerName, result=Result}),
			case Result of
				%%建立交易
				?tradeAskResult_Agree->
					createTrade( PlayerID, PlayerName );
					%%trade:createTrade(player:getCurPlayerID(), PlayerID);
				_ ->
					ok
			end;
		_ ->
			ok
	end.

createTrade( TargetPlayerID, PlayerName )->
	%%等待对方进程返回
	case player:getPlayerPID(TargetPlayerID) of
		0->ok;
		TargetPID->
			Result = player:callPlayerProcessByPID(TargetPID, {createTrade, {self(), player:getCurPlayerID(), player:getCurPlayerProperty(#player.name)}}),
			case Result of
				{ok, true}->
					put( "TradeTargetPid", TargetPID ),
					put( "TradePlayerID", TargetPlayerID),
					put( "TradePlayerName", PlayerName),
					put( "SelfTradeItem", []),
					put( "SelfTradeMoney", 0),
					put( "SelfLockTrade", false),
					put( "SelfAffirmTrade", false),
					%%进入交易状态
					playerStateFlag:addStateFlag(?Player_State_Flag_TradeWithPlayer),
					%%像客户端发送建立交易消息
					player:send(#pk_CreateTrade{playerID=TargetPlayerID, playerName=PlayerName, result=?createTrade_success}),
					ok;
				_->
					player:send(#pk_CreateTrade{playerID=TargetPlayerID, playerName=PlayerName, result=?createTrade_Fail}),
					ok
			end
	end.

createTradeAsk( TargetPID, TargetPlayerID, PlayerName )->
	case get("TradeTargetPid") of
		0->
			put( "TradeTargetPid", TargetPID ),
			put( "TradePlayerID", TargetPlayerID),
			put( "TradePlayerName", PlayerName),
			put( "SelfTradeItem", []),
			put( "SelfTradeMoney", 0),
			put( "SelfLockTrade", false),
			put( "SelfAffirmTrade", false),
			%%进入交易状态
			playerStateFlag:addStateFlag(?Player_State_Flag_TradeWithPlayer),
			%%像客户端发送建立交易消息
			player:send(#pk_CreateTrade{playerID=TargetPlayerID, playerName=PlayerName, result=?createTrade_success}),
			true;
		_->
			player:send(#pk_CreateTrade{playerID=TargetPlayerID, playerName=PlayerName, result=?createTrade_Fail}),
			false
	end.

%%结束交易
cancelTrade(Reason) ->
	cancelTrade( ?tradePerson_Self, Reason ).

%%结束交易
cancelTrade(Person, Reason) ->
	%%将自己放入交易栏的物品解锁
	UnLockFunc = fun(R) ->
						 tradeLockItem(R#tradeItem.itemDB, 0)
				 end,
	case get("SelfTradeItem") of
		[] ->
			ok;
		SelfItem ->
			lists:map(UnLockFunc, SelfItem)
	end,
	player:send(#pk_CancelTrade_S2C{person=Person, reason=Reason}),
	case Person of
		?tradePerson_Self->
			case get( "TradeTargetPid" ) of
				0->ok;
				TargetPID->
					%%自身取消交易，发送取消交易给对方
					TargetPID ! {targetCancelTrage, Reason}
			end;
		_->ok
	end,
	put( "TradeTargetPid", 0 ),
	put( "TradePlayerID", 0),
	put( "TradePlayerName", ""),
	put( "SelfTradeItem", []),
	put( "SelfTradeMoney", 0),
	put( "SelfLockTrade", false),
	put( "SelfAffirmTrade", false).



%%结束错误的交易
cancelTradeByErrorTarget(PID) ->
	%%将自己放入交易栏的物品解锁
	UnLockFunc = fun(R) ->
						 tradeLockItem(R#tradeItem.itemDB, 0)
				 end,
	case get("SelfTradeItem") of
		[] ->
			ok;
		SelfItem ->
			lists:map(UnLockFunc, SelfItem)
	end,
	player:send(#pk_CancelTrade_S2C{person=?tradePerson_Self, reason=?tradeCancel_UnKnow}),
	case get( "TradeTargetPid" ) of
		0->ok;
		TargetPID->
			%%自身取消交易，发送取消交易给对方
			TargetPID ! {targetCancelTrage, ?tradeCancel_UnKnow}
	end,
	PID ! {targetCancelTrage, ?tradeCancel_UnKnow},
	put( "TradeTargetPid", 0 ),
	put( "TradePlayerID", 0),
	put( "TradePlayerName", ""),
	put( "SelfTradeItem", []),
	put( "SelfTradeMoney", 0),
	put( "SelfLockTrade", false),
	put( "SelfAffirmTrade", false).


%%对方取消交易处理
onTargetCancelTrade_S2S( Reason) ->
	cancelTrade(?tradePerson_Other, Reason).

%%自己放入物品处理
onTradeInputItem_C2S(#pk_TradeInputItem_C2S{}=Pk) ->
	case get("TradeTargetPid") of
		0 ->
			%%交易不存在,结束交易
			cancelTrade(?tradePerson_Self, ?tradeCancel_UnKnow);
		TargetPID->
			case playerItems:getItemDBDataByPlayerBagCell(?Item_Location_Bag, Pk#pk_TradeInputItem_C2S.cell) of
				{} ->
					%%放入失败，物品不存在
					player:send(#pk_TradeInputItemResult_S2C{
															 cell=Pk#pk_TradeInputItem_C2S.cell, 
															 itemDBID=Pk#pk_TradeInputItem_C2S.itemDBID, 
															 count=0,
															 item_data_id=0,
															 result=?putInItem_Fail_NonExistent});
				ItemDB ->
					case ItemDB#r_itemDB.binded of
						true->					
							%%放入失败，不能交易
							player:send(#pk_TradeInputItemResult_S2C{
																	 cell=Pk#pk_TradeInputItem_C2S.cell, 
																	 itemDBID=Pk#pk_TradeInputItem_C2S.itemDBID, 
																	 count=0,
																	 item_data_id=0,
																	 result=?putInItem_Fail_CannotTrade});
						_->
							case playerItems:canTrade(ItemDB#r_itemDB.item_data_id) of
								false->
									%%放入失败，不能交易
									player:send(#pk_TradeInputItemResult_S2C{
																			 cell=Pk#pk_TradeInputItem_C2S.cell, 
																			 itemDBID=Pk#pk_TradeInputItem_C2S.itemDBID, 
																			 count=0,
																			 item_data_id=0,
																			 result=?putInItem_Fail_CannotTrade});
								_->
									case ItemDB#r_itemDB.amount >= Pk#pk_TradeInputItem_C2S.count of
										true ->
											case playerItems:getLockIDOfPlayerBag(?Item_Location_Bag, ItemDB#r_itemDB.cell) of
												0 ->
													case length(get("SelfTradeItem")) >= ?tradeItemMaxCount of
														true->
															%%交易栏已满
															player:send(#pk_TradeInputItemResult_S2C{ 
																									 cell=ItemDB#r_itemDB.cell,
																									 itemDBID=ItemDB#r_itemDB.id,
																									 item_data_id=ItemDB#r_itemDB.item_data_id,
																									 count=Pk#pk_TradeInputItem_C2S.count,
																									 result=?putInItem_Fail_Full});
														_->
															onTradeInputItemResult( ItemDB, Pk#pk_TradeInputItem_C2S.count, TargetPID )
													end;
												_ ->
													ok
											end;
										false ->
											%%放入失败，物品不数量不足
											player:send(#pk_TradeInputItemResult_S2C{
																			 		cell=Pk#pk_TradeInputItem_C2S.cell, 
																			 		itemDBID=Pk#pk_TradeInputItem_C2S.itemDBID, 
																					count=0,
																					item_data_id=0,
																			 		result=?putInItem_Fail_Notenough})
									end
							end
					end
			end
	end.

%%自己放入物品
onTradeInputItemResult(ItemDB, Count, TargetPID) ->
	
	%%向客户端发送放入物品的返回
	player:send(#pk_TradeInputItemResult_S2C{ 
											 cell=ItemDB#r_itemDB.cell,
											 itemDBID=ItemDB#r_itemDB.id,
											 item_data_id=ItemDB#r_itemDB.item_data_id,
											 count=Count,
											 result=?putInItem_Success}),
	put("SelfTradeItem", get("SelfTradeItem") ++ [#tradeItem{itemDBID=ItemDB#r_itemDB.id, itemDB=ItemDB, count=Count}]),
	tradeLockItem(ItemDB,1),
	setTradeLock( false ),
	%%发送自己放入物品的消息给对方客户端
	player:sendToPlayerByPID(TargetPID, #pk_TradeInputItem_S2C{itemDBID=ItemDB#r_itemDB.id, item_data_id=ItemDB#r_itemDB.item_data_id, count=Count}).
		

%%自己取出物品处理
onTradeTakeOutItem_C2S(#pk_TradeTakeOutItem_C2S{}=Pk) ->
	case get("TradeTargetPid") of
		0 ->
			%%交易不存在,结束交易
			cancelTrade(?tradePerson_Self, ?tradeCancel_UnKnow);
		TargetPID ->
			case lists:keyfind(Pk#pk_TradeTakeOutItem_C2S.itemDBID, #tradeItem.itemDBID, get("SelfTradeItem")) of
				false ->
					%%取下物品失败，物品不存在
					player:send(#pk_TradeTakeOutItemResult_S2C{cell=0, itemDBID=0, result=0} );
				TradeItem ->
					%%自己解除锁定
					setTradeLock( false ),
					
					%%取下物品成功，解锁物品所在格子
					ItemDB = TradeItem#tradeItem.itemDB,
					tradeLockItem(ItemDB,0),
					%%给自己返回取下物品成功的消息
					player:send(#pk_TradeTakeOutItemResult_S2C{cell=ItemDB#r_itemDB.cell, itemDBID=ItemDB#r_itemDB.id, result=1} ),
					%%给对方发送取下物品的消息
					player:sendToPlayerByPID(TargetPID, #pk_TradeTakeOutItem_S2C{itemDBID=ItemDB#r_itemDB.id}),
					put("SelfTradeItem", get("SelfTradeItem") -- [TradeItem])
			end
	end.



%%自己改变金钱
onTradeChangeMoney_C2S(#pk_TradeChangeMoney_C2S{}=Pk) ->
	case get("TradeTargetPid") of
		0 ->
			%%交易不存在,结束交易
			cancelTrade(?tradePerson_Self, ?tradeCancel_UnKnow);
		TargetPID ->
			case playerMoney:canDecPlayerMoney(Pk#pk_TradeChangeMoney_C2S.money) of
				true ->
					put( "SelfTradeMoney", Pk#pk_TradeChangeMoney_C2S.money),
					%%向自己客户端发送改变成功消息
					player:send(#pk_TradeChangeMoneyResult_S2C{money=Pk#pk_TradeChangeMoney_C2S.money, result=1}),
					%%向对方客户端发送改变金钱的消息
					player:sendToPlayerByPID(TargetPID, #pk_TradeChangeMoney_S2C{money=Pk#pk_TradeChangeMoney_C2S.money}),
					%%自己解除锁定
					setTradeLock( false );
				false ->
					player:send(#pk_TradeChangeMoneyResult_S2C{money=Pk#pk_TradeChangeMoney_C2S.money, result=0})
			end
	end.   


%%自己锁定交易
onTradeLock_C2S(#pk_TradeLock_C2S{}=Pk) ->
	case get("TradeTargetPid") of
		0 ->
			%%交易不存在,结束交易
			cancelTrade(?tradePerson_Self, ?tradeCancel_UnKnow);
		_Pid ->
			case Pk#pk_TradeLock_C2S.lock of
				0->Lock = false;
				_->Lock = true
			end,
			setTradeLock( Lock )
	end.

setTradeLock( Lock )->
	case get("TradeTargetPid") of
		0->ok;
		Pid->
			put( "SelfLockTrade", Lock),
			case Lock of
				true->Lock2 = 1;
				_->Lock2 = 0
			end,
			%%向自己发送自己锁定
			player:send(#pk_TradeLock_S2C{person=?tradePerson_Self, lock=Lock2}),
			%%向对方发送对方锁定
			player:sendToPlayerByPID(Pid, #pk_TradeLock_S2C{person=?tradePerson_Other, lock=Lock2})
	end.

isAffirmTrade()->
	get( "SelfAffirmTrade" ).

%%点下交易按钮
onTradeAffirm_C2S(#pk_TradeAffirm_C2S{}=Pk) ->
	case get("TradeTargetPid") of
		0 ->
			%%交易不存在,结束交易
			cancelTrade(?tradePerson_Self, ?tradeCancel_UnKnow);
		Pid ->
			case Pk#pk_TradeAffirm_C2S.bAffrim of
				0->Affirm = false;
				_->Affirm = true
			end,
			put("SelfAffirmTrade", Affirm),
			%%向自己发送自己确认交易
			player:send(#pk_TradeAffirm_S2C{person=?tradePerson_Self, bAffirm=Pk#pk_TradeAffirm_C2S.bAffrim}),
			%%向对方发送对方确认交易
			player:sendToPlayerByPID(Pid, #pk_TradeAffirm_S2C{person=?tradePerson_Other, bAffirm=Pk#pk_TradeAffirm_C2S.bAffrim}),
			
			case isAffirmTrade()  of
				true->
					case player:callPlayerProcessByPID(Pid, {isAffirmTrade}) of
						{ok, true}->
							%%双方都同意交易，开始交换物品
							startSwap();
						_->ok
					end;
				_->ok
			end
	end.

startSwap()->
	TargetPID = get("TradeTargetPid"),
	case player:callPlayerProcessByPID(TargetPID, {testCanSwap, get("SelfTradeItem")}) of
		{ok, ReCode, OtherCellList, OtherItem}->	%%对方可以继续交易
			case ReCode of
				?tradeAffirmAskResult_Success->
					case testCanSwap( get("SelfTradeItem"), OtherItem, get("SelfTradeMoney")) of
						{?tradeAffirmAskResult_Success, SelfCellList}-> %%自身可以继续交易
							%%交换物品
							%%先删除自身物品
							case onTradeDeleteSelf(get("SelfTradeItem"), get("SelfTradeMoney")) of
								{true, SelfDelMoney, SelfDelItem}->		%%自身删除成功，对方删除物品
									case player:callPlayerProcessByPID(TargetPID, {delTradeItem}) of
										{ok, {true, OtherDelMoney, OtherDelItem}}->	%%对方删除物品成功，自身添加物品
											case onAddTradeItem( OtherDelItem, OtherDelMoney, SelfCellList ) of
												true->
													%%对方添加物品和金钱
													case player:callPlayerProcessByPID(TargetPID, {addTradeItem, SelfDelItem, SelfDelMoney, OtherCellList }) of
														{ok,true}->	%%交易完成，结束交易
															cancelTrade(?tradePerson_Self, ?tradeCancel_Finish);
														_->ok
													end;
												_->ok
											end;
										_->
											%%对方删除失败，回滚自身物品并且结束交易
											mail:sendSystemMailToPlayer_Money(player:getCurPlayerID(), "System", "Trade return", "", SelfDelMoney),
											SendFunc = fun(R)->
															   mail:sendSystemMailToPlayer_ItemRecord(player:getCurPlayerID(), "System", "Trade return", "", R, 0)
													   end,
											lists:map(SendFunc, SelfDelItem)
									end,
									ok;
								_->ok
							end;
						_->ok
					end;
				_->ok
			end;
		_->ok
	end.


testCanSwap( SelfItem, OtherItem, SelfMoney )->
	ItemHaveFunc = fun(R) -> 
						   case playerItems:getItemDBDataByPlayerBagCell(?Item_Location_Bag, 
																		 R#tradeItem.itemDB#r_itemDB.cell) of
							   {} ->
								   false;
							   ItemDB ->
								   case (ItemDB#r_itemDB.id =:= R#tradeItem.itemDB#r_itemDB.id) andalso
											(ItemDB#r_itemDB.amount >= R#tradeItem.count) of
									   true ->
										   true;
									   false ->
										   false
								   end 
						   end
				   end,
	
	case (case SelfItem of
					   [] ->
						   true;
					   _ ->
						   lists:all(ItemHaveFunc, SelfItem)
				   end) of
		true ->
			CellList = getCanPutItemCells(SelfItem, OtherItem), 
			case (case OtherItem of
					  [] ->
						  true;
					  _ ->
						  case CellList of
							  [] ->
								  false;
							  _ ->
								  true
						  end
				  end) of
				true ->
					case playerMoney:canDecPlayerMoney(SelfMoney) of
						true ->
							%%将即将放物品的格子锁定
							lists:map(fun(Cell) ->
											  playerItems:setLockPlayerBagCell(?Item_Location_Bag, Cell, 1)
									  end, CellList),
							%%可以进行交易
							{?tradeAffirmAskResult_Success, CellList};
						false ->
							%%不可以进行交易,自身金钱不足
							cancelTrade(?tradePerson_Self, ?tradeCancel_PlayerMoneyNotEnough),
							{?tradeAffirmAskResult_MoneyNotEnough, []}
					end;
				 false ->
					 %%不可以进行交易,背包空格不足
					 cancelTrade(?tradePerson_Self, ?tradeCancel_PlayerBagNotEnough),
					 {?tradeAffirmAskResult_BagNotEnough, []}
			 end;
		false ->
			%%不可以进行交易,自身物品不足
			 cancelTrade(?tradePerson_Self, ?tradeCancel_PlayerItemNotEnough),
			{?tradeAffirmAskResult_ItemNotEnough, []}
	end.
	
 
%%返回可放物品的格子
getCanPutItemCells(SelfItem, OtherItem) ->
	try
		case OtherItem of
			[] ->
				throw(0);
			_ ->
				ok
		end,
		
		put("SelfCanPutCells", []),
		lists:map(fun(R) ->
						  case R#tradeItem.itemDB#r_itemDB.amount =:= R#tradeItem.count of 
							  true ->
								  put("SelfCanPutCells", get("SelfCanPutCells")++[R#tradeItem.itemDB#r_itemDB.cell]);
							  false ->
								  ok
						  end
				   end, 
				  SelfItem),
		put("SelfCanPutCells",lists:sort(fun(X,Y)-> X<Y end, get("SelfCanPutCells"))),
		
		Length1 = length(get("SelfCanPutCells")),
		Length2 = length(OtherItem),
		case Length1 >=  Length2 of
			true ->
				case Length1 == Length2 of
					true ->
						throw(1);
					false ->
						playerItems:for(1, Length1-Length2, 
										fun(_)->
												put("SelfCanPutCells", get("SelfCanPutCells")--[lists:last(get("SelfCanPutCells"))])
										end),
						throw(1)
				end;
			false ->
				BagSapseCellCount = playerItems:getPlayerBagSpaceCellCount(?Item_Location_Bag),
				case (BagSapseCellCount+Length1) >= Length2 of
					true ->
						playerItems:for(1, Length2-Length1,
										 fun(_)->
												 Cell = playerItems:getPlayerBagSpaceCell(?Item_Location_Bag),
												 playerItems:setLockPlayerBagCell(?Item_Location_Bag, Cell, 1),
												 case Cell >= 0 of
													 true -> 
														 put("SelfCanPutCells", get("SelfCanPutCells")++[Cell]);
													 false ->
														 throw(0)
												 end
										end), 
						throw(1);
					false ->
						throw(0)
				end
		end
	
	catch
		0 ->[];
		1 ->get("SelfCanPutCells")
	end.

%%删除自身交易的物品
onTradeDeleteSelf(SelfItem, SelfMoney) ->
	try
		case SelfItem of
			[] ->
				ok;
			_ ->
				ok
		end,
		Func = fun(R) ->
					   case R#tradeItem.itemDB#r_itemDB.amount =:= R#tradeItem.count of
						   true ->
							   playerItems:onTradeToChangeItemLocationCell(R#tradeItem.itemDB,?Item_Location_Trade,0, ?Destroy_Item_Reson_TradeToPlayer);
						   false -> 
							   case playerItems:splitItem(R#tradeItem.itemDB, R#tradeItem.count) of
								   {} ->
									   throw(0);
								   ItemDB ->
									   ItemDB
							   end
					   end
			   end,
	

		ItemList2 = lists:map(Func, SelfItem),
		
		ParamTuple = #token_param{changetype = ?Money_Change_Player_Trade},
		playerMoney:decPlayerMoney(SelfMoney, ?Money_Change_Player_Trade, ParamTuple),
		
		%% 交易 交易出物品金钱 LOG  				
		ParamLog = #tard_param{	action = 0,	money = SelfMoney},		
		PlayerBase = player:getCurPlayerRecord(),
		logdbProcess:write_log_player_event(?EVENT_PALYER_TRAD,ParamLog,PlayerBase),
		
		{true, SelfMoney, ItemList2}
	
	catch
		_ ->{false, 0, []}
end.

%%添加对方交易过来的物品
onAddTradeItem(ItemList, Money, Cells) ->
	
	case ItemList of 
		[] ->
			ok;
		_ ->
			Func = fun(R, Cell) ->
						   R2 = setelement(#r_itemDB.owner_id, R, player:getCurPlayerID()),
						   R3 = setelement(#r_itemDB.cell, R2, Cell),
						   R4 = setelement(#r_itemDB.location, R3, ?Item_Location_Bag),
						   etsBaseFunc:insertRecord( itemModule:getCurItemTable(), R4 ),
						   %%立即存盘
						   itemModule:saveItemDB( R4 ),
						   playerItems:setPlayerBagCell( R4#r_itemDB.location, R4#r_itemDB.cell, R4#r_itemDB.id, 0),
						   
						   GetParam = [ ?Get_Item_Reson_TradeFromPlayer, "", "" ],
						   playerItems:onPlayerGetItem(R4, GetParam),
						   ItemData1 = etsBaseFunc:readRecord(itemModule:getCurItemTable(), R4#r_itemDB.id),
						   playerItems:sendToPlayer_GetItem( ItemData1, ?Get_Item_Reson_TradeFromPlayer )
				   end,
			lists:zipwith(Func, ItemList, Cells)
	end,
	
	case Money of 
		0 ->
			ok;
		_ ->
			ParamTuple = #token_param{changetype = ?Money_Change_Player_Trade},
			playerMoney:addPlayerMoney(Money, ?Money_Change_Player_Trade, ParamTuple)
	end,
	%% 交易 交易出物品金钱 LOG  				
	ParamLog = #tard_param{	action = 1,	money = Money},		
	PlayerBase = player:getCurPlayerRecord(),
	logdbProcess:write_log_player_event(?EVENT_PALYER_TRAD,ParamLog,PlayerBase),
	%%向交易进程返回添加物品成功的消息
	true.
%%--------------------------------交易-------------------------------------------


