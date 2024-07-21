%% Author: Zhangdong
%% Created: 2012-8-8
%% Description: TODO: Add description to itemDB
-module(itemModule).

%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% Include files
%%
-include("mysql.hrl").
-include("db.hrl").
-include("hdlt_logger.hrl").
-include("itemDefine.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("globalDefine.hrl").

-include_lib("stdlib/include/ms_transform.hrl").

%%------------------------------------------------common------------------------------------------------


%%------------------------------------------------itemCfg------------------------------------------------
%%加载物品配置表，和物品初始化
itemCfgLoad()->
	case db:openBinData( "item.bin" ) of
		[] ->
			?ERROR_OUT( "itemCfgLoad openBinData item.bin false []" );
		ItemData ->
			db:loadBinData( ItemData, r_itemCfg ),
			

			ets:new( ?ItemCfgTableAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #r_itemCfg.item_data_id }] ),

			
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.itemCfgTable, ItemCfgTable),
			
			ItemCfgList = db:matchObject(r_itemCfg,  #r_itemCfg{_='_'} ),
			MyFunc = fun( Record )->
							 etsBaseFunc:insertRecord(?ItemCfgTableAtom, Record)
					 end,
			lists:map( MyFunc, ItemCfgList ),
			?DEBUG_OUT( "itemCfgLoad succ" )
	end.


getNeedSaveLogByDataId(ItemDataId)->
	case ets:lookup(?ItemCfgTableAtom,ItemDataId) of
		[]->0;
		[R|_]->R#r_itemCfg.needSaveLog 
	end.

%%返回物品配置记录
getItemCfgDataByID( ID )->
	etsBaseFunc:readRecord( main:getGlobalItemCfgTable(), ID).

%%返回物品配置ID是否有效
isValidItemDataID( ItemDataID )->
	case getItemCfgDataByID( ItemDataID ) of
		{}->
			false;
		_ ->
			true
	end.
	

%%------------------------------------------------itemDB------------------------------------------------
%%返回当前进程的物品表
getCurItemTable()->
	ItemTable = get( "ItemTable" ),
	case ItemTable of
		undefined->0;
		_->ItemTable
	end.
%%返回当前进程的背包格子表
getCurItemBagTable()->
	ItemBagTable = get( "ItemBagTable" ),
	case ItemBagTable of
		undefined->0;
		_->ItemBagTable
	end.
%%生成一个默认的物品记录
initItemDBData()->
	ItemDBData = #r_itemDB{ id=db:memKeyIndex(r_itemdb), % persistent  
				owner_type=?item_owner_type_unkown,
				owner_id=0,
				location=0,
				cell=0,
				amount=0,
				item_data_id=0,
			    param1=0,
			    param2=0,
			    binded=false, 
			    expiration_time=0 },
	ItemDBData.
%%根据一个物品ID生成一个物品记录
initItemDBDataByItemID( ItemID )->
	ItemCfg = getItemCfgDataByID( ItemID ),
	case ItemCfg of
		{} ->
			?ERROR_OUT( "initItemDBDataByItemID ItemID[~p] false ", [ItemID] );
		_->
			ItemDBData = initItemDBData(),
			ItemDBData1 = setelement( #r_itemDB.amount, ItemDBData, ItemCfg#r_itemCfg.maxAmount ),
			ItemDBData2 = setelement( #r_itemDB.item_data_id, ItemDBData1, ItemCfg#r_itemCfg.item_data_id ),
			ItemDBData3 = setelement( #r_itemDB.param1, ItemDBData2, ItemCfg#r_itemCfg.useParam1),
			setelement( #r_itemDB.param2, ItemDBData3, ItemCfg#r_itemCfg.useParam2)
	end.

%%返回当前进程玩家物品列表
getCurItemDBDataList()->
	PlayerID = player:getCurPlayerID(),
	Q = ets:fun2ms( fun(#r_itemDB{id=_,owner_type=OwnerType, owner_id=OwnerID} = Record ) when ( OwnerType=:=?item_owner_type_player ) andalso ( OwnerID=:=PlayerID ) -> Record end),
	ets:select(getCurItemTable(), Q).
%%根据物品DBID，返回物品记录
getItemDBDataByDBID( ItemDBID )->
	ItemTable = getCurItemTable(),
	case ItemTable of
		undefined->{};
		_->etsBaseFunc:readRecord( ItemTable, ItemDBID )
	end.

%%根据物品DBID，从数据库返回物品记录
getItemDBDataByDBIDFromDB( ItemDBID )->
	ItemList = mySqlProcess:get_itemDbList_by_id(ItemDBID),	
	case ItemList of
		[]->{};
		[R|_]->R
	end.

%%创建一个物品给玩家
createItemDBToPlayer( Location, Cell, ItemID, Amount, Binded )->
	PlayerID = player:getCurPlayerID(),
	DB1 = initItemDBDataByItemID( ItemID ),
	ItemTable = getCurItemTable(),
	etsBaseFunc:insertRecord( ItemTable, DB1),
	etsBaseFunc:changeFiled( ItemTable, DB1#r_itemDB.id, #r_itemDB.owner_type, ?item_owner_type_player ),
	etsBaseFunc:changeFiled( ItemTable, DB1#r_itemDB.id, #r_itemDB.owner_id, PlayerID ),
	etsBaseFunc:changeFiled( ItemTable, DB1#r_itemDB.id, #r_itemDB.location, Location ),
	etsBaseFunc:changeFiled( ItemTable, DB1#r_itemDB.id, #r_itemDB.cell, Cell ),
	etsBaseFunc:changeFiled( ItemTable, DB1#r_itemDB.id, #r_itemDB.binded, Binded ),
	
	case Amount =< 0 of
		false ->
			etsBaseFunc:changeFiled( ItemTable, DB1#r_itemDB.id, #r_itemDB.amount, Amount );
		true ->
			ok
	end,

	%saveItemDB( etsBaseFunc:readRecord( ItemTable, DB1#r_itemDB.id) ),
	mySqlProcess:insertOrReplaceR_itemDB(etsBaseFunc:readRecord( ItemTable, DB1#r_itemDB.id),false),
	
	onItemDBCreated( getItemDBDataByDBID( DB1#r_itemDB.id ) ),
	getItemDBDataByDBID( DB1#r_itemDB.id ).

onItemDBCreated( _ItemDBData )->
	ok.

onItemDBDeleted( _ItemDBData )->
	ok.

onItemOwnerChanged( _ItemDBData )->
	ok.

saveItemDB( ItemDBData )->
	dbProcess:on_savePlayerItem( ItemDBData ),
	ItemDBData.

deleteItemDB( ItemDBData )->
	etsBaseFunc:deleteRecord( getCurItemTable(), ItemDBData#r_itemDB.id ),
	dbProcess:on_deletePlayerItem(ItemDBData#r_itemDB.id),
	onItemDBDeleted(ItemDBData).

deleteItemDBById( Id )->
	etsBaseFunc:deleteRecord( getCurItemTable(), Id ),
	dbProcess:on_deletePlayerItem(Id).


%%------------------------------------------------player item------------------------------------------------
%%玩家上线物品检查
checkPlayerItemDBData()->
	%%2013.4.8收费服bug导致背包、仓库格子上限不一致问题修正
	Player = player:getCurPlayerRecord(),
	MaxEnabledBagCells = Player#player.maxEnabledBagCells,
	MaxEnabledStorageBagCells = Player#player.maxEnabledStorageBagCells,
	
	case playerItems:isPlayerBagCellEnabled( ?Item_Location_Bag, MaxEnabledBagCells ) of
		true->%%bug，不应该为有效，如果有效，需要修正，将MaxEnabledBagCells+1
			case MaxEnabledBagCells + 1 =< ?Max_Bag_Cells of
				true->
					?DEBUG_OUT( "checkPlayerItemDBData Player[~p] MaxEnabledBagCells + 1", [Player] ),
					player:setCurPlayerProperty(#player.maxEnabledBagCells, MaxEnabledBagCells + 1);
				false->ok
			end;
		false->ok
	end,
	
	case playerItems:isPlayerBagCellEnabled( ?Item_Location_Storage, MaxEnabledStorageBagCells ) of
		true->%%bug，不应该为有效，如果有效，需要修正，将MaxEnabledStorageBagCells+1
			case MaxEnabledStorageBagCells + 1 =< ?Max_StorageBag_Cells of
				true->
					?DEBUG_OUT( "checkPlayerItemDBData Player[~p] MaxEnabledStorageBagCells + 1", [Player] ),
					player:setCurPlayerProperty(#player.maxEnabledStorageBagCells, MaxEnabledStorageBagCells + 1);
				false->ok
			end;
		false->ok
	end,

	ItemTable = getCurItemTable(),
	
	AllItemDBDataList = etsBaseFunc:getAllRecord(ItemTable),
	
	Fun_Proc_DBItemList = fun ( Record )->
							case Record#r_itemDB.location of
								?Item_Location_ErrorItem->ok;
								_->
									ItemData = getItemCfgDataByID( Record#r_itemDB.item_data_id ),
									case ItemData of
										{}->
											playerItems:setPlayerBagCell(Record#r_itemDB.location, Record#r_itemDB.cell, 0, 0),
											ets:update_element(ItemTable,  Record#r_itemDB.id, {#r_itemDB.location,?Item_Location_ErrorItem}),
											?ERROR_OUT( "checkPlayerItemDBData Record[~p] error item_data_id", [Record] );
										_->
											case Record#r_itemDB.location of
												?Item_Location_Bag->DoCheck=true;
												?Item_Location_Storage->DoCheck=true;
												?Item_Location_TempBag->DoCheck=true;
												_->DoCheck=false
											end,

											case DoCheck of
												true->
													MyItemDBID = Record#r_itemDB.id,
													ItemDBID = playerItems:getItemDBIDByPlayerBagCell( Record#r_itemDB.location, Record#r_itemDB.cell ),
													case ItemDBID of
														0->%%物品不在格子上面，设置在格子上
															?DEBUG_OUT( "checkPlayerItemDBData Record[~p] ItemDBID=0 ", [Record] ),
															playerItems:setPlayerBagCell(Record#r_itemDB.location, Record#r_itemDB.cell, Record#r_itemDB.id, 0);
														MyItemDBID->%%应该相等
															ok;
														_->%%重叠了，发邮件
															?DEBUG_OUT( "checkPlayerItemDBData Record[~p] location cell false to send mail",[Record] ),
															 mail:sendSystemMailToPlayer_ItemRecord( player:getCurPlayerID(), "", "", "", Record, 0),
															 etsBaseFunc:deleteRecord( getCurItemTable(), Record#r_itemDB.id )
													end;
												false->ok
											end
									end
							end
						  end,
	lists:foreach( Fun_Proc_DBItemList, AllItemDBDataList ),
	
	Fun_Proc_ItemBag = fun( Record )->
							   case Record#r_playerBag.itemDBID =:= 0 of
								   true->ok;
								   false->
									   ItemDBData = itemModule:getItemDBDataByDBID( Record#r_playerBag.itemDBID ),
									   case ItemDBData of
										   {}->
											   playerItems:setPlayerBagCell(Record#r_playerBag.location, Record#r_playerBag.cell, 0, 0),
											   ?ERROR_OUT( "checkPlayerItemDBData Record[~p] error ItemDBData={}", [Record] );
										   _->
											   case ( ItemDBData#r_itemDB.location =:= Record#r_playerBag.location ) andalso ( ItemDBData#r_itemDB.cell =:= Record#r_playerBag.cell ) of
												   true->ok;
												   false->
													   ?ERROR_OUT( "checkPlayerItemDBData Record[~p] error location cell ItemDBData=[~p]", [Record, ItemDBData] ),
													   playerItems:setPlayerBagCell(Record#r_playerBag.location, Record#r_playerBag.cell, 0, 0),
													   playerItems:setPlayerBagCell(ItemDBData#r_itemDB.location, ItemDBData#r_itemDB.cell, Record#r_playerBag.itemDBID, 0)
											   end
									   end
							   end
					   end,
	AllItemBagDataList = etsBaseFunc:getAllRecord( getCurItemBagTable() ),
	lists:foreach( Fun_Proc_ItemBag, AllItemBagDataList ),

	ok.
	

%%玩家上线物品初始化	
onPlayerOnlineLoadItemData( AllItemDBDataList, AllItemBagDataList )->
	ItemTable = getCurItemTable(),
	BagTable = getCurItemBagTable(),
	MyFunc = fun( Record )->
				etsBaseFunc:insertRecord(ItemTable, Record)	 
			 end,
	lists:map( MyFunc, AllItemDBDataList ),
	
	MyFunc2 = fun( Record )->
				Record2 = setelement( #r_playerBag.lockID, Record, 0 ),
				etsBaseFunc:insertRecord(BagTable, Record2)	 
			 end,
	lists:map( MyFunc2, AllItemBagDataList ),
	
	
	checkPlayerItemDBData(),
	sendAllBagItemToPlayer().



%%将一个物品记录转化为物品网络消息记录
makeItemToMsgItemInfo( ItemDBData )->
	case ItemDBData#r_itemDB.binded of
		true->Binded = 1;
		_->Binded = 0
	end,
	#pk_ItemInfo{ 
				id = ItemDBData#r_itemDB.id,
				owner_type = ItemDBData#r_itemDB.owner_type,
				owner_id = ItemDBData#r_itemDB.owner_id,
				location = ItemDBData#r_itemDB.location,
				cell = ItemDBData#r_itemDB.cell,
				amount = ItemDBData#r_itemDB.amount,
				item_data_id = ItemDBData#r_itemDB.item_data_id,
				param1 = ItemDBData#r_itemDB.param1,
				param2 = ItemDBData#r_itemDB.param2,
				binded = Binded,
				%modify here
				remain_time = ItemDBData#r_itemDB.expiration_time
				 }.

%%发送背包里所有物品信息给玩家
sendAllBagItemToPlayer()->
	AllItems = playerItems:getItemDBDataListByPlayerLocation( ?Item_Location_Bag ),
	case AllItems of
		[]->ok;
		_->
			AllItems2 = lists:map( fun ( Record )->makeItemToMsgItemInfo( Record ) end, AllItems ),
			player:send(#pk_PlayerBagInit{ items=AllItems2 } )
	end,
	AllItems3 = playerItems:getItemDBDataListByPlayerLocation( ?Item_Location_TempBag ),
	case AllItems3 of
		[]->ok;
		_->
			AllItems4 = lists:map( fun ( Record )->makeItemToMsgItemInfo( Record ) end, AllItems3 ),
			player:send(#pk_PlayerBagInit{ items=AllItems4 } )
	end,
	AllItems5 = playerItems:getItemDBDataListByPlayerLocation(?Item_Location_Storage ),
	case AllItems5 of
		[]->ok;
		_->
			AllItems6 = lists:map( fun ( Record )->makeItemToMsgItemInfo( Record ) end, AllItems5 ),
			player:send(#pk_PlayerBagInit{ items=AllItems6 } )
	end,
	AllItems7 = playerItems:getItemDBDataListByPlayerLocation(?Item_Location_BackBuy ),
	case AllItems7 of
		[]->ok;
		_->
			AllItems8 = lists:map( fun ( Record )->makeItemToMsgItemInfo( Record ) end, AllItems7 ),
			player:send(#pk_PlayerBagInit{ items=AllItems8 } )
	end.

%%将玩家某物品移除
changeItemOwner( ItemDBData, OwnerType, OwnerID, Reson )->
	etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.owner_type, OwnerType ),
	etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.owner_id, OwnerID ),
	ItemDBData2 = etsBaseFunc:readRecord( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id ),
	saveItemDB( ItemDBData2 ),
	playerItems:setPlayerBagCell(ItemDBData2#r_itemDB.location, ItemDBData2#r_itemDB.cell, 0, 0),
	etsBaseFunc:deleteRecord( itemModule:getCurItemTable(), ItemDBData2#r_itemDB.id ),
	itemModule:onItemDBDeleted(ItemDBData2),
	player:send( #pk_PlayerDestroyItem{ itemDBID=ItemDBData2#r_itemDB.id, reson=Reson } ),
	ItemDBData2.
	

