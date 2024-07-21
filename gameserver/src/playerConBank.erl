%% Author: Administrator
%% Created: 2012-10-18
%% Description: TODO: Add description to playerConBank
-module(playerConBank).

%%
%% Include files
%%
-include("db.hrl").
-include("playerDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("conSalesBank.hrl").
-include("itemDefine.hrl").
-include("logdb.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%

%%------------------------------上架--------------------------------------------------

%%获取玩家总共可上架数量
getPlayerAllGroundingCount() ->
	10.

%%上架询问
onGroundingItemAsk(Pk) ->
	try
		ItemDB =  etsBaseFunc:readRecord(itemModule:getCurItemTable(), Pk#pk_ConSales_GroundingItem.dbId),
		case ItemDB of
			{} ->throw(-1);
			_->ok
		end,
		
		case ItemDB#r_itemDB.binded of
			true->throw(-1);
			_->ok
		end,
		
		case playerItems:canSale(ItemDB#r_itemDB.item_data_id) of
			true->ok;
			_->throw(-1)
		end,
		
		conSalesBank:getPid() !{ groundingAsk, self(), player:getCurPlayerID(), Pk}
	catch
		_->ok
end.

%%上架
onGroundingItemToConSale(Count, Pk) ->
	case getPlayerAllGroundingCount() > Count of
		true ->
			case etsBaseFunc:readRecord(itemModule:getCurItemTable(), Pk#pk_ConSales_GroundingItem.dbId) of
				{} ->
					player:send(#pk_ConSales_GroundingItem_Result{result=?Grounding_Result_Failed_NoItem});
				ItemDB ->
					case ((ItemDB#r_itemDB.amount < Pk#pk_ConSales_GroundingItem.count) or 
							  (Pk#pk_ConSales_GroundingItem.count =< 0)) of
						true ->
							player:send(#pk_ConSales_GroundingItem_Result{result=?Grounding_Result_Failed_CountError});
						false->
							case Pk#pk_ConSales_GroundingItem.money =< 0 of
								true ->
									player:send(#pk_ConSales_GroundingItem_Result{result=?Grounding_Result_Failed_MoneyError});
								false ->
									case Pk#pk_ConSales_GroundingItem.timeType of
										?ConSales_SellTime_Type_8H -> SellTime = ?Bank_LookMoney_8H;
										?ConSales_SellTime_Type_12H ->SellTime = ?Bank_LookMoney_12H;
										?ConSales_SellTime_Type_24H ->SellTime = ?Bank_LookMoney_24H;
										_->SellTime = ?Bank_LookMoney_8H
									end,
									case erlang:trunc(Pk#pk_ConSales_GroundingItem.money*SellTime+0.5) of
										0 ->
											SellMoney = 1;
										M ->
											SellMoney = M
									end,
									
									case playerMoney:canUsePlayerBindedMoney(SellMoney) of
										true ->
											ItemCfg = itemModule:getItemCfgDataByID(ItemDB#r_itemDB.item_data_id),
											case Pk#pk_ConSales_GroundingItem.count < ItemDB#r_itemDB.amount of
												true ->
													%%需要拆分
													ItemDB2 = playerItems:splitItem(ItemDB, Pk#pk_ConSales_GroundingItem.count),
													ItemDB3 = setelement( #r_itemDB.owner_type, ItemDB2, ?item_owner_type_conSales ),
													ItemDB4 = setelement( #r_itemDB.owner_id, ItemDB3, 0 ),

													itemModule:saveItemDB( ItemDB4 ),
													
													A = #groundingItem{itemDB=ItemDB4, 
																	   itemCfg=ItemCfg,
																	   count=ItemDB4#r_itemDB.amount,
																	   money=Pk#pk_ConSales_GroundingItem.money,
																	   timeType=Pk#pk_ConSales_GroundingItem.timeType,
																	   playerId=player:getCurPlayerID(),
																	   playerName=player:getCurPlayerProperty(#player.name)},
													%%发送上架消息到交易行进程													
													conSalesBank:getPid() !{ grounding, A};
												false ->
													%%不需要拆分
													itemModule:changeItemOwner(ItemDB,
																			   ?item_owner_type_conSales,
																			   0,
																			   ?Destroy_Item_Reson_groundingToConSalse),
													A = #groundingItem{itemDB=ItemDB, 
																	   itemCfg=ItemCfg,
																	   count=ItemDB#r_itemDB.amount,
																	   money=Pk#pk_ConSales_GroundingItem.money,
																	   timeType=Pk#pk_ConSales_GroundingItem.timeType,
																	   playerId=player:getCurPlayerID(),
																	   playerName=player:getCurPlayerProperty(#player.name)},
													%%发送上架消息到交易行进程
													conSalesBank:getPid() !{ grounding, A}
											end,
											ParamTuple = #token_param{changetype = ?Money_Change_ConSales_CustodianFee,param1=ItemDB#r_itemDB.item_data_id,param2=ItemDB#r_itemDB.amount},
											playerMoney:usePlayerBindedMoney(SellMoney, ?Money_Change_ConSales_CustodianFee, ParamTuple),
											player:send(#pk_ConSales_GroundingItem_Result{result=?Grounding_Result_Succ});
										false ->
											player:send(#pk_ConSales_GroundingItem_Result{result=?Grounding_Result_Failed_MoneyNotEnough})
									end,
									ok
							end
					end
			end;
		false ->
			player:send(#pk_ConSales_GroundingItem_Result{result=?Grounding_Result_Filed_Full})
	end.

%%购买请求，请求成功后将返回购买成功消息，然后扣除金钱。
buyAsk(ConSalesId) ->
	conSalesBank:getPid() ! {buyAsk, self(), player:getCurPlayerID(), ConSalesId}.

%%交易行对于player购买请求的返回
onBuyAskReturn(ConSalesItem) ->
	case ConSalesItem of
		{} ->
			player:send(#pk_ConSales_BuyItem_Result{result=?ConBank_Buy_Failed_Other});
		_ ->
			case playerMoney:canDecPlayerMoney(ConSalesItem#conSalesItem.conSalesMoney) of
				true ->
					%%购买
					conSalesBank:getPid() ! {buyItem, self(), player:getCurPlayerID(), ConSalesItem#conSalesItem.conSalesId},
					%%扣除费用
					ParamTuple = #token_param{changetype = ?Money_Change_ConSalesBuy,
												param1=ConSalesItem#conSalesItem.conSalesId,
												param2 = ConSalesItem#conSalesItem.itemDB#r_itemDB.item_data_id,
												param3 = ConSalesItem#conSalesItem.itemDB#r_itemDB.amount},
					playerMoney:decPlayerMoney(ConSalesItem#conSalesItem.conSalesMoney, ?Money_Change_ConSalesBuy, ParamTuple),
					player:send(#pk_ConSales_BuyItem_Result{result=?ConBank_Buy_Succ}),
					%% 交易行LOG 
					case erlang:trunc(ConSalesItem#conSalesItem.conSalesMoney*?BankTrade_Money+0.5) of
						0 -> 	Promoney = 1;
						M ->	Promoney = M
					end,
					ParamLog = #conbank_param{	tradid = ConSalesItem#conSalesItem.conSalesId,
											  	sellerid = ConSalesItem#conSalesItem.playerId,
											  	money = ConSalesItem#conSalesItem.conSalesMoney,
												promoney = Promoney,
								  				itemid = ConSalesItem#conSalesItem.itemDB#r_itemDB.item_data_id,
												amount = ConSalesItem#conSalesItem.itemDB#r_itemDB.amount},
					
					PlayerBase = player:getCurPlayerRecord(),
					logdbProcess:write_log_player_event(?EVENT_PALYER_CONBANK,ParamLog,PlayerBase);
				false ->
					player:send(#pk_ConSales_BuyItem_Result{result=?ConBank_Buy_Failed_MoneyNotEnough})
			end
	end.

%%
onFindResult(L) -> 
	put( "FindConBankOderList", L),
	put( "ConBankNoncePage", 1),
	sendPageOderListToPlayer(1).

sendPageOderListToPlayer(Page) ->
	Length = length(get("FindConBankOderList")),
	try
		put("OderIndex", 0),
		put("SendOderList", []),
		Fun = fun(R) ->
					  case get("OderIndex") < ?sendToPlayerMaxOrderCount of
						  true ->
							  put("SendOderList", get("SendOderList") ++ [#pk_ConSalesItem{
																				   conSalesId=R#conSalesItem.conSalesId,
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
																				   itemOcc=R#conSalesItem.itemOcc}]);
						  false ->
							  throw(0)
					  end,
					  put("OderIndex", get("OderIndex") +1)
			  end,
		case Page of
			1 ->
				lists:map(Fun, get("FindConBankOderList"));
			_ ->
				L2 = lists:nthtail((Page-1)*?sendToPlayerMaxOrderCount, get("FindConBankOderList")),
				lists:map(Fun, L2)
		end,
		throw(0)
	catch
		_->
			%%将查找到的订单发送给玩家
			player:send(#pk_ConSales_FindItems_Result{result=?conBank_Find_Succ, allCount=Length,page=Page, itemList=get("SendOderList")})
	end.

onConSalesTrunPage(Mode) ->
	Length = length(get("FindConBankOderList")),
	try
		case get("FindConBankOderList") of
			[] ->
				player:send(#pk_ConSales_FindItems_Result{result=?conBank_Find_Succ, allCount=1,page=0, itemList=[]});
			_ ->
				Page = get("ConBankNoncePage"),
				case Mode of
					?TrunPage_Mode_Front ->
						case Page of
							1 ->
								player:send(#pk_ConSales_FindItems_Result{result=?conBank_Find_Failed_CannotTrunPage, allCount=0,page=0, itemList=[]});
							_ ->
								throw(Page-1)
						end;
					?TrunPage_Mode_Next ->
						case Page*?sendToPlayerMaxOrderCount < Length of
							true ->
								throw(Page+1);
							false ->
								player:send(#pk_ConSales_FindItems_Result{result=?conBank_Find_Failed_CannotTrunPage, allCount=0,page=0, itemList=[]})
						end
				end
		end
	
	catch
		Page2 ->
			sendPageOderListToPlayer(Page2),
			put( "ConBankNoncePage", Page2)
	end.

onDelOder(Oder) ->
	put("FindConBankOderList", get("FindConBankOderList")--[Oder]),
	sendPageOderListToPlayer(get("ConBankNoncePage")).

onConbankClose()->
	put("FindConBankOderList", []),
	put( "ConBankNoncePage", 1).
%%
%% Local Functions
%%

