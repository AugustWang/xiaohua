%% Author: Administrator
%% Created: 2012-10-10
%% Description: TODO: Add description to npcStore
-module(npcStore).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-compile(export_all).

-include("db.hrl").
-include("hdlt_logger.hrl").
-include("itemDefine.hrl").
-include("package.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("playerDefine.hrl").
-include("logdb.hrl").
-include("globalDefine.hrl").
-include("vipDefine.hrl").
%%
%% API Functions
%%

%%读取商店列表，各商店物品列表
npcStoreCfgLoad()->
	case db:openBinData( "NPCStore/NpcStoreAll.bin" ) of
		[] ->
			?ERROR_OUT( "npcStoreCfgLoad openBinData NpcStoreAll.bin false []" );
		NpcStoreAll ->
			db:loadBinData( NpcStoreAll, r_AllStoreCfg ),

			ets:new( ?AllStoreTableAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #r_AllStoreTable.store_id }] ),

			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.allStoreTable, AllStoreTable),
			NpcStoreAllCfg = db:matchObject(r_AllStoreCfg,  #r_AllStoreCfg{_='_'} ),
			MyFunc = fun( Record )->
							 FileName = common:catStringID( "NPCStore/store_", Record#r_AllStoreCfg.store_id ) ++ ".bin",
							 case db:openBinData(FileName) of
								 [] ->
									 ?ERROR_OUT( "npcStoreCfgLoad openBinData[~p] false" ,[FileName]);
								 ItemList ->					
									 case Record#r_AllStoreCfg.store_type of
										 ?Item_NPCStore->
											 mnesia:clear_table( r_NpcStoreItemCfg ),
											 db:loadBinData( ItemList, r_NpcStoreItemCfg ),
											 NpcStoreItemTable = ets:new( 'NpcStoreItemTable', [protected, { keypos, #r_NpcStoreItemCfg.item_id }] ),									 
											 NpcStoreitemCfg = db:matchObject(r_NpcStoreItemCfg,  #r_NpcStoreItemCfg{_='_'} ),
											 case NpcStoreitemCfg of
												 []->
													  ?ERROR_OUT( "npcStoreCfgLoad loadBinData[~p] false" ,[FileName]);
												 _->
													 ok
											 end,	 
											 lists:map(fun(NpcR) ->
															   etsBaseFunc:insertRecord(NpcStoreItemTable, NpcR)
													   end, NpcStoreitemCfg),
											 NpcRecord2 = #r_AllStoreTable{store_id=Record#r_AllStoreCfg.store_id,store_type=Record#r_AllStoreCfg.store_type, itemTable=NpcStoreItemTable},
											 etsBaseFunc:insertRecord(?AllStoreTableAtom, NpcRecord2);
										 ?Item_TokenStore->
											 mnesia:clear_table( r_TokenStoreItemCfg ),
											 db:loadBinData( ItemList, r_TokenStoreItemCfg ),
											 TokenStoreItemTable = ets:new( 'TokenStoreItemTable', [protected, { keypos, #r_TokenStoreItemCfg.item_id }] ),
											 TokenStoreitemCfg = db:matchObject(r_TokenStoreItemCfg,  #r_TokenStoreItemCfg{_='_'} ),
											 case TokenStoreitemCfg of
												 []->
													 ?ERROR_OUT( "TokenStoreCfgLoad loadBinData [~p] false" ,[FileName]);
												 _->
													 ok
											 end,
											 lists:map(fun(TokenR) ->
															   etsBaseFunc:insertRecord(TokenStoreItemTable, TokenR)
													   end, TokenStoreitemCfg),
											 TokenRecord2 = #r_AllStoreTable{store_id=Record#r_AllStoreCfg.store_id,store_type=Record#r_AllStoreCfg.store_type, itemTable=TokenStoreItemTable},
											 etsBaseFunc:insertRecord(?AllStoreTableAtom, TokenRecord2)
									 end
							 end
					 end,
			lists:map( MyFunc, NpcStoreAllCfg ),
			?DEBUG_OUT( "npcStoreCfgLoad succ" )
			end.

%%商店的Table
getNpcStoreItemTableByID( ID )->
	try
		AllTable = etsBaseFunc:readRecord( main:getGlobalAllStoreTable(), ID),
		case AllTable of
			{}->
				throw(-1);
			_->
				ok
		end,
		Table = AllTable#r_AllStoreTable.itemTable,
		StoreType = AllTable#r_AllStoreTable.store_type,
		case StoreType of
			?Item_NPCStore->
				NpcStore = ets:fun2ms(fun(#r_NpcStoreItemCfg{} = Record) ->Record end),
				List = ets:select(Table, NpcStore),
				{List,StoreType};
			?Item_TokenStore->
				TokenStore = ets:fun2ms(fun(#r_TokenStoreItemCfg{} = Record) ->Record end),
				{ets:select(Table, TokenStore),StoreType}
		end
	catch
		_->{{},ID}
	end.

%%返回商店物品列表
onMsgRequestGetNpcStoreItemList( ID )->
	try
		{StoreItemList,StoreType} = getNpcStoreItemTableByID(ID),
		case StoreItemList of
			{}->
				throw(-1);
			_->
				ok
		end,		
		case StoreType of
			?Item_NPCStore->
				NpcItemList = lists:map(fun(Record)->
												#pk_NpcStoreItemData{id = Record#r_NpcStoreItemCfg.id,
																	 item_id = Record#r_NpcStoreItemCfg.item_id,
																	 price = Record#r_NpcStoreItemCfg.price,
																	 isbind= Record#r_NpcStoreItemCfg.isbind}
										end ,StoreItemList),
				NpcStoreMsg = #pk_GetNpcStoreItemListAck{ store_id = ID, itemList = NpcItemList},
				player:send(NpcStoreMsg);
			?Item_TokenStore->
				TokenItemList = lists:map(fun(Record)->
												  #pk_TokenStoreItemData{id = Record#r_TokenStoreItemCfg.id,
																		 item_id = Record#r_TokenStoreItemCfg.item_id,
																		 tokenType = Record#r_TokenStoreItemCfg.type,
																		 price = Record#r_TokenStoreItemCfg.price,
																		 isbind= Record#r_TokenStoreItemCfg.isbind}
										  end ,StoreItemList),
				TokenStoreMsg = #pk_GetTokenStoreItemListAck{ store_id = ID, itemList = TokenItemList},
				player:send(TokenStoreMsg)
		end
	catch
		_->ok
	end.


getNpcStoreItemInfoRecordByID( StoreID, ItemID )->
	AllTable = etsBaseFunc:readRecord( main:getGlobalAllStoreTable(), StoreID),
	case AllTable of
		{}->{};
		_->
			Table = AllTable#r_AllStoreTable.itemTable,
			StoreType = AllTable#r_AllStoreTable.store_type,
			case StoreType of
				?Item_NPCStore->
					NpcStoreRule = ets:fun2ms(fun(#r_NpcStoreItemCfg{id='_', item_id=NPCStoreItemIDInTable} = Record) 
												   when NPCStoreItemIDInTable=:= ItemID ->Record 
											  end),
					NpcStoreList = ets:select(Table, NpcStoreRule),
					case NpcStoreList of
						[]->{};
						[First|_]->{First,StoreType}
					end;
				?Item_TokenStore->
					TokenStoreRule = ets:fun2ms(fun(#r_TokenStoreItemCfg{id='_', item_id=TokenItemIDInTable} = Record) 
													 when TokenItemIDInTable=:= ItemID ->Record 
												end),
					TokenStoreList = ets:select(Table, TokenStoreRule),
					case TokenStoreList of
						[]->{};
						[First|_]->{First,StoreType}
					end
			end
	end.
	

onMsgRequestBuyItem( Item_id,Store_id,Amount)->
	try
		ItemData = itemModule:getItemCfgDataByID( Item_id ),
		case ItemData of
			{}->
				?LOG_OUT( "onMsgRequestBuyItem empty itemdata [~p] [~p] [~p]", [player:getCurPlayerID(), Item_id, Amount] );
			_->
				case playerItems:getPlayerBagSpaceCellCount(?Item_Location_Bag) >0 of
					true->
						{ItemTable,StoreType}= getNpcStoreItemInfoRecordByID(Store_id,Item_id),
						case StoreType of
							?Item_NPCStore->
								NpcPrice = ItemTable#r_NpcStoreItemCfg.price,
								NpcAllPrice = NpcPrice * Amount,
								case playerMoney:canUsePlayerBindedMoney(NpcAllPrice) of
									true->
										ParamTuple = #token_param{changetype = ?Money_Change_NPCStore,param1=Item_id,param2=Store_id,param3=NpcPrice,param4=Amount},
										playerMoney:usePlayerBindedMoney(NpcAllPrice,?Money_Change_NPCStore,ParamTuple),
										ParamLog = #buyitem_param{storeid = Store_id,
														itemid = Item_id,
														number = Amount,
														money = 0,
														money_b = NpcAllPrice},
										PlayerBase = player:getCurPlayerRecord(),
										logdbProcess:write_log_player_event(?EVENT_PLAYER_BUYITEM,ParamLog,PlayerBase);
									false->
										player:send(#pk_BuyItemAck{ count = ?BuyItem_Fail_Money}),
										throw(-1)
								end;
							?Item_TokenStore->
								TokenPrice = ItemTable#r_TokenStoreItemCfg.price,
								TokenAllPrice = TokenPrice * Amount,
 								case ItemTable#r_TokenStoreItemCfg.type of
									?TokenStore_ManToken->
										CanDecManTokenResult = playerItems:canDecItemInBag(?Item_Location_Bag, globalSetup:getGlobalSetupValue(#globalSetup.token_Man_id),TokenAllPrice, "all" ),
										[CanDecManToken|DecManTokenData] = CanDecManTokenResult,
										case CanDecManToken of
											true->put( "DecToken_TokenStore", DecManTokenData);
											false->
												player:send(#pk_BuyItemAck{ count = ?BuyItem_Fail_ManToken}),
												throw(-1)
										end;
									?TokenStore_LandToken->
										CanDecLandTokenResult = playerItems:canDecItemInBag(?Item_Location_Bag, globalSetup:getGlobalSetupValue(#globalSetup.token_Land_id),TokenAllPrice, "all" ),
										[CanDecLandToken|DecLandTokenData] = CanDecLandTokenResult,
										case CanDecLandToken of
											true->put( "DecToken_TokenStore", DecLandTokenData);
											false->
												player:send(#pk_BuyItemAck{ count = ?BuyItem_Fail_LandToken}),
												throw(-1)
										end;
									?TokenStore_SkyToken->
										CanDecSkyTokenResult = playerItems:canDecItemInBag(?Item_Location_Bag, globalSetup:getGlobalSetupValue(#globalSetup.token_Sky_id),TokenAllPrice, "all" ),
										[CanDecSkyToken|DecSkyTokenData] = CanDecSkyTokenResult,
										case CanDecSkyToken of
											true->put( "DecToken_TokenStore", DecSkyTokenData);
											false->
												player:send(#pk_BuyItemAck{ count = ?BuyItem_Fail_SkyToken}),
												throw(-1)
										end
								end,
								playerItems:decItemInBag( get("DecToken_TokenStore"), ?Destroy_Item_Reson_TokenStoreBuyItem )
						end,
						playerItems:addItemToPlayerByItemDataID( Item_id, Amount, true, ?Get_Item_Reson_BuyFromToken),
						
						Count = playerItems:getItemCountByItemData(?Item_Location_Bag, Item_id, true)
								+ playerItems:getItemCountByItemData( ?Item_Location_TempBag, Item_id, true),

								task:updateBuyItemTaskProcess(Item_id, Count),
						case StoreType of
							?Item_NPCStore->player:send(#pk_BuyItemAck{ count = ?BuyItem_Success_NPCStore});
							?Item_TokenStore->player:send(#pk_BuyItemAck{ count = ?BuyItem_Success_TokenStore})
						end;
					false->player:send(#pk_BuyItemAck{ count = ?BuyItem_Fail_Bag}),
						   throw(-1)
					end
		end
	catch
		_->ok
	end.

onMsgRequestSellItem (Item_cell)->
	try
		
		ItemDBData = itemModule:getItemDBDataByDBID(Item_cell),
		case ItemDBData of
			{}->throw(-1);
			_->ok
		end,
		
		case playerItems:canSell(ItemDBData#r_itemDB.item_data_id) of
			true->ok;
			_->throw(-1)
		end,
		
		case ( ItemDBData#r_itemDB.owner_type =:= ?item_owner_type_player ) andalso ( ItemDBData#r_itemDB.owner_id =:= player:getCurPlayerID() ) of
			false->throw(-1);
			_->ok
		end,
		case ItemDBData#r_itemDB.location of
			?Item_Location_Bag->ok;
			?Item_Location_Storage->ok;
			_->throw(-1)
		end,
		
		ItemCfgData = itemModule:getItemCfgDataByID(ItemDBData#r_itemDB.item_data_id),
		
		case ItemCfgData of
			{}->throw(-1);
			_->ok
		end,

		ParamTuple = #token_param{changetype = ?Money_Change_NPCStore,
								  param1=ItemCfgData#r_itemCfg.item_data_id},				
		case ItemDBData#r_itemDB.binded of
			true->
				playerMoney:addPlayerBindedMoney(ItemCfgData#r_itemCfg.price * ItemDBData#r_itemDB.amount,?Money_Change_NPCStore, ParamTuple),
				ok;
			false->
				playerMoney:addPlayerMoney(ItemCfgData#r_itemCfg.price * ItemDBData#r_itemDB.amount,?Money_Change_NPCStore, ParamTuple),
				ok
		end,
		playerItems:onSellItem(ItemDBData),
		player:send(#pk_BuyItemAck{ count = ?BuyItem_Success_NPCStore}),
		ok

	catch
		_->ok
	end.

onMsgGetNpcStoreBackBuyItemList ( _Count )->	
 		Cells = playerItems:getPlayerBagList(?Item_Location_BackBuy),
		Cells2 = lists:sort(fun(X,Y) -> 
								X#r_playerBag.cell < Y#r_playerBag.cell
						end, Cells),
		
		put("BackBuyItemList", []),
		lists:map( fun(Cell)-> 
						   case Cell#r_playerBag.itemDBID of
							   0 ->
								   ok;
							   _ ->
								   ItemDB = itemModule:getItemDBDataByDBID(Cell#r_playerBag.itemDBID),
								   put("BackBuyItemList", get("BackBuyItemList") ++ [itemModule:makeItemToMsgItemInfo(ItemDB)])
							 end
						 end, 
					 Cells2),
		Msg = #pk_GetNpcStoreBackBuyItemListAck{ itemList = get("BackBuyItemList")},
	
		player:send(Msg).

onMsgRequestBackBuyItem( ItemDBID )->
	case itemModule:getItemDBDataByDBID(ItemDBID) of
		{}->
			?LOG_OUT( "onMsgRequestBuyItem empty itemdata [~p] [~p] ", [player:getCurPlayerID(), ItemDBID] );
		ItemDBData->
			ItemCfgData = itemModule:getItemCfgDataByID(ItemDBData#r_itemDB.item_data_id),
			
			Price = ItemCfgData#r_itemCfg.price * ItemDBData#r_itemDB.amount,
			case playerMoney:canUsePlayerBindedMoney(Price ) of
				true->
					case playerItems:getPlayerBagSpaceCell(?Item_Location_Bag) of
						-1
						  ->ok;
						Cell
						  ->
							ParamTuple = #token_param{changetype = ?Money_Change_NPCStore_BackBuy,param1=ItemDBData#r_itemDB.item_data_id,param2=ItemCfgData#r_itemCfg.price,param3=ItemDBData#r_itemDB.amount},
							playerMoney:usePlayerBindedMoney(Price ,?Money_Change_NPCStore_BackBuy,ParamTuple),
							playerItems:setPlayerBagCell( ItemDBData#r_itemDB.location, ItemDBData#r_itemDB.cell, 0, 0 ),
							
							
							etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.location, ?Item_Location_Bag ),
							etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.binded, true ),
							
							etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.cell, Cell),
							ItemDBData2 = etsBaseFunc:readRecord( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id ),
							itemModule:saveItemDB( ItemDBData2 ),
							playerItems:setPlayerBagCell( ?Item_Location_Bag, Cell, ItemDBData2#r_itemDB.id, 0 ),
							
							
							player:send( #pk_PlayerItemLocationCellChanged{ itemDBID=ItemDBData2#r_itemDB.id, location=?Item_Location_Bag, cell=Cell } ),
							
							player:send(#pk_BuyItemAck{ count = ?BuyItem_Success_NPCStore}),
			
							onMsgGetNpcStoreBackBuyItemList( 0 )
				end;
			false->
				ok

			end
	end.

vipPlayerOpenVIPStoreRequest(Request)->
	case vipFun:callVip(?VIP_FUN_REMOTE_SHOP, 0) of
		{ok,ID}->
			onMsgRequestGetNpcStoreItemList(ID);
		{_,_}->
			player:send(#pk_VIPPlayerOpenVIPStoreFail{ fail = 0})
	end.
	

%%
%% Local Functions
%%

