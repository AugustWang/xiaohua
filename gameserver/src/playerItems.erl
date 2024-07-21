%% Author: Zhangdong
%% Created: 2012-8-9
%% Description: TODO: Add description to itemDB
-module(playerItems).

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
-include("playerDefine.hrl").
-include("itemDefine.hrl").
-include("package.hrl").
-include("logdb.hrl").
-include("textDefine.hrl").
-include_lib("stdlib/include/ms_transform.hrl").

%%------------------------------------------------Player Bag------------------------------------------------
for(N,N,F)->
	[F(N)];
for(I,N,F)->
	[F(I)|for(I+1,N,F)].

%%玩家创建时创建背包格子、临时背包格子
onPlayerCreatedToInitBag( PlayerID )->
	FunCreatePlayerBag = fun ( Index )-> 
									 case Index =< ?PlayerCreateEnableBagCells of
										 true->
											 PlayerBag = #r_playerBag{ id = db:memKeyIndex(r_playerbag), % persistent
																	   location=?Item_Location_Bag,
																	   cell=Index-1,
																	   playerID=PlayerID,
																	   itemDBID=0,
																	   enable=true,
																	   lockID=0 },
											 mySqlProcess:insertOrReplaceR_playerBag(PlayerBag,false);
										 false->
											 PlayerBag = #r_playerBag{ id = db:memKeyIndex(r_playerbag), % persistent
																	   location=?Item_Location_Bag,
																	   cell=Index-1,
																	   playerID=PlayerID,
																	   itemDBID=0,
																	   enable=false,
																	   lockID=0 },
											 mySqlProcess:insertOrReplaceR_playerBag(PlayerBag,false)
									 end
							end,
	for( 1, ?Max_Bag_Cells, FunCreatePlayerBag ),
	
	FunCreatePlayerStorageBag = fun ( Index )-> 
									 case Index =< ?PlayerCreateEnableStorageBagCells of
										 true->
											 PlayerBag = #r_playerBag{ id = db:memKeyIndex(r_playerbag), % persistent
																	   location=?Item_Location_Storage,
																	   cell=Index-1,
																	   playerID=PlayerID,
																	   itemDBID=0,
																	   enable=true,
																	   lockID=0 },
											 mySqlProcess:insertOrReplaceR_playerBag(PlayerBag,false);
										 false->
											 PlayerBag = #r_playerBag{ id = db:memKeyIndex(r_playerbag), % persistent
																	   location=?Item_Location_Storage,
																	   cell=Index-1,
																	   playerID=PlayerID,
																	   itemDBID=0,
																	   enable=false,
																	   lockID=0 },
											 mySqlProcess:insertOrReplaceR_playerBag(PlayerBag,false)
									 end
							end,
	for( 1, ?Max_StorageBag_Cells, FunCreatePlayerStorageBag ),

	FunCreatePlayerTempBag = fun ( Index )-> 
								 PlayerBag = #r_playerBag{ id = db:memKeyIndex(r_playerbag), % persistent
														   location=?Item_Location_TempBag,
														   cell=Index-1,
														   playerID=PlayerID,
														   itemDBID=0,
														   enable=true,
														   lockID=0 },
								mySqlProcess:insertOrReplaceR_playerBag(PlayerBag,false)
							 end,
	for( 1, ?Max_TempBag_Cells, FunCreatePlayerTempBag ),
	
	FunCreateBackBuyBag = fun ( Index )-> 
								 PlayerBag = #r_playerBag{ id = db:memKeyIndex(r_playerbag), % persistent
														   location=?Item_Location_BackBuy,
														   cell=Index-1,
														   playerID=PlayerID,
														   itemDBID=0,
														   enable=true,
														   lockID=0 },
								 mySqlProcess:insertOrReplaceR_playerBag(PlayerBag,false)
							 end,
	for( 1, ?Max_BackBuy_Cells, FunCreateBackBuyBag ).

%%开启背包格子，从FromCell格子索引到ToCell格子的索引都会开启
openPlayerBagEnable( Location, FromCell, ToCell )->
	MyFunc = fun( Index )->
				setPlayerBagCellEnabled( Location, Index )
			 end,
	for( FromCell, ToCell - 1, MyFunc ),
	ok.

%%返回某背包所有格子列表
getPlayerBagList( Location_Param )->
	Q = ets:fun2ms( fun(#r_playerBag{id=_, location=Location} = Record ) when ( Location=:=Location_Param )-> Record end),
	ets:select(itemModule:getCurItemBagTable(), Q).

%%返回玩家所有背包格子列表
getPlayerAllBagList()->
	Q = ets:fun2ms( fun(#r_playerBag{id=_, location=Location} = Record ) when ( Location=:=?Item_Location_Bag ) or ( Location=:=?Item_Location_TempBag ) or ( Location=:=?Item_Location_Storage )or ( Location=:=?Item_Location_BackBuy ) -> Record end),
	ets:select(itemModule:getCurItemBagTable(), Q).


%%返回某背包格子记录
getPlayerBagByCell( Location_Param, Cell_Param )->
	Q = ets:fun2ms( fun(#r_playerBag{id=_, location=Location,cell=Cell} = Record ) when ( Location=:=Location_Param ) andalso (Cell=:=Cell_Param)-> Record end),
	Result = ets:select(itemModule:getCurItemBagTable(), Q),
	case Result of
		[]->{};
		[R|_]->R
	end.

%%返回某背包格子的LockID
getLockIDOfPlayerBag( Location, Cell )->
	PlayerBagCell = getPlayerBagByCell( Location, Cell ),
	case PlayerBagCell of
		{}->0;
		_->
			PlayerBagCell#r_playerBag.lockID
	end.

%%返回某背包格子是否空，空即没有物品
isPlayerBagCellEmpty( Location, Cell )->
	PlayerBagCell = getPlayerBagByCell( Location, Cell ),
	case PlayerBagCell of
		{}->
			true;
		_->
			PlayerBagCell#r_playerBag.itemDBID =:= 0
	end.
%%返回某背包格子是否有效，即是否开启
isPlayerBagCellEnabled( Location, Cell )->
	PlayerBagCell = getPlayerBagByCell( Location, Cell ),
	case PlayerBagCell of
		{}->
			false;
		_->
			PlayerBagCell#r_playerBag.enable
	end.
%%返回某背包格子是否有效，指玩家可以操作的格子，背包内没有开启的格子算无效
isValidPlayerBagCell( Location, Cell )->
	case Location of
		?Item_Location_Bag->
			case ( Cell >= 0 ) andalso ( Cell < ?Max_Bag_Cells ) of
				true->
					MaxPlayerBagCell = player:getCurPlayerProperty( #player.maxEnabledBagCells ),
					Cell < MaxPlayerBagCell;
				false->
					false
			end;
		?Item_Location_Storage->
			case ( Cell >= 0 ) andalso ( Cell < ?Max_Bag_Cells ) of
				true->
					MaxPlayerBagCell = player:getCurPlayerProperty( #player.maxEnabledStorageBagCells ),
					Cell < MaxPlayerBagCell;
				false->
					false
			end;
		?Item_Location_TempBag->
			case ( Cell >= 0 ) andalso ( Cell < ?Max_TempBag_Cells ) of
				true->true;
				false->false
			end;
		?Item_Location_BackBuy->
			case ( Cell >= 0 ) andalso ( Cell < ?Max_BackBuy_Cells ) of
				true->true;
				false->false
			end;
		_->false
	end.
%%返回背包位置是否有效
isValidLocation( Location )->
	case ( Location >= 0 ) andalso ( Location < ?Item_Location_Count ) of
		true->true;
		false->false
	end.
%%返回某背包格子是否已经锁定
isLockedPlayerBagCell( Location, Cell )->
	LockID = getLockIDOfPlayerBag( Location, Cell ),
	LockID > 0.
%%解锁玩家背包格子
setLockPlayerBagCell( Location, Cell, LockID )->
	PlayerBag = getPlayerBagByCell( Location, Cell ),
	setPlayerBagCell( Location, Cell, PlayerBag#r_playerBag.itemDBID, LockID ).

%%返回某背包所有格子是否有锁定情况
isLockedPlayerBag( Location )->
	PlayerBagList = getPlayerBagList( Location ),
	put( "isLockedPlayerBag_P1", false ),
	MyFunc = fun( Record )->
					 case isLockedPlayerBagCell( Location, Record#r_playerBag.cell ) of
						 true->put( "isLockedPlayerBag_P1", true );
						 false->ok
					 end
			 end,
	lists:foreach(MyFunc, PlayerBagList),
	get( "isLockedPlayerBag_P1" ).

%%返回某背包格子的物品DB记录
getItemDBDataByPlayerBagCell( Location, Cell )->
	PlayerBagCell = getPlayerBagByCell( Location, Cell ),
	case PlayerBagCell of
		{}->
			{};
		_->
			itemModule:getItemDBDataByDBID( PlayerBagCell#r_playerBag.itemDBID )
	end.

%%返回背包格子物品ID
getItemDBIDByPlayerBagCell( Location, Cell )->
	PlayerBagCell = getPlayerBagByCell( Location, Cell ),
	case PlayerBagCell of
		{}->
			0;
		_->
			PlayerBagCell#r_playerBag.itemDBID
	end.

%%返回某背包内所有物品的DB数据列表
getItemDBDataListByPlayerLocation( Location_Param )->
	Q = ets:fun2ms( fun(#r_itemDB{id=_, owner_type=_, owner_id=_, location=Location} = Record ) when ( Location=:=Location_Param ) -> Record end),
	ets:select(itemModule:getCurItemTable(), Q).

%%返回某背包内某物品的数量
getItemCountByItemData( Location, ItemDataID, Binded )->
	ItemDBDataList = getItemDBDataListByPlayerLocation( Location ),
	put( "getItemCountByItemData_P1", 0 ),
	MyFunc = fun( ItemDBData )->
				LocedCell = isLockedPlayerBagCell( Location, ItemDBData#r_itemDB.cell ),
				case ( ItemDBData#r_itemDB.item_data_id =:= ItemDataID ) andalso (not LocedCell) of
					true->
						case Binded of
							true->
								case ItemDBData#r_itemDB.binded =:= Binded of
									true->
										P1 = get( "getItemCountByItemData_P1" ),
										put( "getItemCountByItemData_P1", P1 + ItemDBData#r_itemDB.amount );
									false->ok
								end;
							false->
								case ItemDBData#r_itemDB.binded =:= Binded of
									true->
										P1 = get( "getItemCountByItemData_P1" ),
										put( "getItemCountByItemData_P1", P1 + ItemDBData#r_itemDB.amount );
									false->ok
								end;
							"all"->
									P1 = get( "getItemCountByItemData_P1" ),
									put( "getItemCountByItemData_P1", P1 + ItemDBData#r_itemDB.amount );
							_->
								ok
						end;
					false->ok
				end
			 end,
	lists:foreach(MyFunc, ItemDBDataList),
	get( "getItemCountByItemData_P1" ).

%%返回背包内是否能删除一定数量的物品
%%如果是Location主背包，会自动检测临时背包
%%返回值：[true, {location, cell, amount}]
%%		 [false,{}]
canDecItemInBag( Location, ItemDataID, Amount, Binded )->
	case Location of
		?Item_Location_Bag->
			ItemDBDataList1 = getItemDBDataListByPlayerLocation( Location ),
			ItemDBDataList2 = getItemDBDataListByPlayerLocation( ?Item_Location_TempBag ),
			case ItemDBDataList1 of
				[]->
					case ItemDBDataList2 of
						[]->ItemDBDataList = [];
						_->ItemDBDataList = ItemDBDataList2
					end;
				_->
					case ItemDBDataList2 of
						[]->ItemDBDataList = ItemDBDataList1;
						_->ItemDBDataList = ItemDBDataList1 ++ ItemDBDataList2
					end
			end;
		?Item_Location_TempBag->
			ItemDBDataList1 = getItemDBDataListByPlayerLocation( ?Item_Location_Bag ),
			ItemDBDataList2 = getItemDBDataListByPlayerLocation( Location ),
			case ItemDBDataList1 of
				[]->
					case ItemDBDataList2 of
						[]->ItemDBDataList = [];
						_->ItemDBDataList = ItemDBDataList2
					end;
				_->
					case ItemDBDataList2 of
						[]->ItemDBDataList = ItemDBDataList1;
						_->ItemDBDataList = ItemDBDataList1 ++ ItemDBDataList2
					end
			end;
		_->ItemDBDataList = getItemDBDataListByPlayerLocation( Location )
	end,

	put( "canDecItemInBag_P1", [] ),
	put( "canDecItemInBag_P2", Amount ),
	put( "canDecItemInBag_P3", 0 ),
	MyFunc = fun( ItemDBData )->
				LocedCell = isLockedPlayerBagCell( Location, ItemDBData#r_itemDB.cell ),
				case ( ItemDBData#r_itemDB.item_data_id =:= ItemDataID ) andalso (not LocedCell) andalso ( get("canDecItemInBag_P2") > 0 ) of
					true->
						case ItemDBData#r_itemDB.amount =< get( "canDecItemInBag_P2" ) of
							true->put( "canDecItemInBag_P3", ItemDBData#r_itemDB.amount );
							false->put( "canDecItemInBag_P3", get( "canDecItemInBag_P2" ) )
						end,
						
						NewRecord = [{ItemDBData#r_itemDB.location,ItemDBData#r_itemDB.cell, get("canDecItemInBag_P3") }],
						
						case Binded of
							true->
								case ItemDBData#r_itemDB.binded =:= Binded of
									true->
										put( "canDecItemInBag_P1", get( "canDecItemInBag_P1" ) ++ NewRecord ),
										put( "canDecItemInBag_P2", get("canDecItemInBag_P2") - get("canDecItemInBag_P3") );
									false->ok
								end;
							false->
								case ItemDBData#r_itemDB.binded =:= Binded of
									true->
										put( "canDecItemInBag_P1", get( "canDecItemInBag_P1" ) ++ NewRecord ),
										put( "canDecItemInBag_P2", get("canDecItemInBag_P2") - get("canDecItemInBag_P3") );
									false->ok
								end;
							"all"->
										put( "canDecItemInBag_P1", get( "canDecItemInBag_P1" ) ++ NewRecord ),
										put( "canDecItemInBag_P2", get("canDecItemInBag_P2") - get("canDecItemInBag_P3") );
							_->
								ok
						end;
					false->ok
				end
			 end,
	lists:foreach(MyFunc, ItemDBDataList),
	case get( "canDecItemInBag_P2" ) =< 0 of
		true->[true] ++ get( "canDecItemInBag_P1" );
		false->[false, {}]
	end.
%%减少背包内物品数量，参数是canDecItemInBag的返回
decItemInBag( CanDecItemInBagResult, Reson )->
	MyFunc = fun( Record )->
					 { Location, Cell, DecAmount } = Record,
					 doDecItemAmountByLocationCell( Location, Cell, DecAmount, Reson )
			 end,
	lists:foreach(MyFunc, CanDecItemInBagResult).
%%直接减少背包内某位置上的物品数量
doDecItemAmountByLocationCell( Location, Cell, DecAmount, Reson )->
	try
		ItemDBData = getItemDBDataByPlayerBagCell( Location, Cell ),
		case  ItemDBData of
			{}->throw(-1);
			_->ok
		end,
		
		case ItemDBData#r_itemDB.amount =< DecAmount of
			true->
				doneDestroyItemInBag( Location, Cell, Reson );
			false->
				etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.amount, ItemDBData#r_itemDB.amount - DecAmount),
				onPlayerItemAmountChanged( itemModule:getItemDBDataByDBID(ItemDBData#r_itemDB.id), DecAmount, Reson ),
				sendToPlayer_ItemAmountChanged( itemModule:getItemDBDataByDBID(ItemDBData#r_itemDB.id), Reson )
		end
	catch
		_->ok
	end.

%%设置某背包格子信息：物品DBID、LockID
setPlayerBagCell( Location, Cell, ItemDBID, LockID )->
	case isPlayerBagCellEnabled( Location, Cell ) of
		 true->
			PlayerBagCell = getPlayerBagByCell( Location, Cell ),
			case PlayerBagCell of
				{}->
					?ERROR_OUT( "setPlayerBagCell PlayerID[~p] Location[~p] Cell[~p] ItemDBID[~p] PlayerBagCell empty",
								[player:getCurPlayerID(), Location, Cell, ItemDBID] );
				_->
					etsBaseFunc:changeFiled( itemModule:getCurItemBagTable(), PlayerBagCell#r_playerBag.id, #r_playerBag.itemDBID, ItemDBID),
					etsBaseFunc:changeFiled( itemModule:getCurItemBagTable(), PlayerBagCell#r_playerBag.id, #r_playerBag.lockID, LockID)
			end;
		 false->
			?ERROR_OUT( "setPlayerBagCell PlayerID[~p] Location[~p] Cell[~p] ItemDBID[~p] LockID[~p] isPlayerBagCellEnabled false",
						[player:getCurPlayerID(), Location, Cell, ItemDBID, LockID] )
	end.
%%设置某背包格子是否有效
setPlayerBagCellEnabled( Location, Cell )->
	case isPlayerBagCellEnabled( Location, Cell ) of
		 false->
			PlayerBagCell = getPlayerBagByCell( Location, Cell ),
			case PlayerBagCell of
				{}->
					?ERROR_OUT( "setPlayerBagCellEnabled PlayerID[~p] Location[~p] Cell[~p] PlayerBagCell empty",
								[player:getCurPlayerID(), Location, Cell] );
				_->
					etsBaseFunc:changeFiled( itemModule:getCurItemBagTable(), PlayerBagCell#r_playerBag.id, #r_playerBag.enable, true)
			end;
		 true->
			?ERROR_OUT( "setPlayerBagCellEnabled PlayerID[~p] Location[~p] Cell[~p] isPlayerBagCellEnabled true",
						[player:getCurPlayerID(), Location, Cell] )
	end.
%%返回某背包内空格位置，返回<0表示没有空格
getPlayerBagSpaceCell( Location )->
	PlayerBagCells = getPlayerBagList( Location ),
	case PlayerBagCells of
		[]->
			-1;
		_->
			MyFunc = fun( Record )->
							 IsLocked = isLockedPlayerBagCell(  Location, Record#r_playerBag.cell ),
							 IsEnable = playerItems:isPlayerBagCellEnabled(Location, Record#r_playerBag.cell),
							 case ( IsEnable ) andalso 
								( Record#r_playerBag.cell < get( "getPlayerBagSpaceCell_cell" ) ) andalso 
								( not IsLocked ) andalso 
								( isPlayerBagCellEmpty( Location, Record#r_playerBag.cell ) ) of
								 true->put( "getPlayerBagSpaceCell_cell", Record#r_playerBag.cell );
								 false->ok
							 end
					 end,
			put( "getPlayerBagSpaceCell_cell", ?Max_Bag_Cells ),
			lists:foreach( MyFunc, PlayerBagCells ),
			Return = get( "getPlayerBagSpaceCell_cell" ),
			case (Return >= 0) andalso (Return < ?Max_Bag_Cells ) of
				true->Return;
				false->-1
			end
	end.
%%返回某背包内空格数量
getPlayerBagSpaceCellCount( Location )->
	PlayerBagCells = getPlayerBagList( Location ),
	case PlayerBagCells of
		[]->
			0;
		_->
			MyFunc = fun( Record )->
							 IsLocked = isLockedPlayerBagCell(  Location, Record#r_playerBag.cell ),
							 IsEnable = playerItems:isPlayerBagCellEnabled(Location, Record#r_playerBag.cell),
							 case ( IsEnable ) andalso ( not IsLocked ) andalso ( isPlayerBagCellEmpty( Location, Record#r_playerBag.cell ) ) of
								 true->put( "getPlayerBagSpaceCellCount_count", get("getPlayerBagSpaceCellCount_count") + 1 );
								 false->ok
							 end
					 end,
			put( "getPlayerBagSpaceCellCount_count", 0 ),
			lists:foreach( MyFunc, PlayerBagCells ),
			Return = get( "getPlayerBagSpaceCellCount_count" ),
			Return
	end.

getPlayerBagSpaceCellCount()->
	getPlayerBagSpaceCellCount( ?Item_Location_Bag ) + getPlayerBagSpaceCellCount( ?Item_Location_TempBag ). 
 
%%返回某背包某格子上是否能叠加某数量的物品
canPileByItemData( Location, PlayerBagCell, ItemDataID, Amount, IsBinded )->
	put( "canPileByItemData_P1", false ),
	put( "canPileByItemData_P2", 0 ),
	put( "canPileByItemData_P3", Amount ),
	try
		case isLockedPlayerBagCell( Location, PlayerBagCell ) of
			true->throw(-1);
			false->ok
		end,

		ItemDBData = getItemDBDataByPlayerBagCell( Location, PlayerBagCell ),
		case ItemDBData of
			{}->throw(-1);
			_->ok
		end,
		case ItemDBData#r_itemDB.item_data_id =:= ItemDataID of
			true->ok;
			false->throw(-1)
		end,

		ItemCfgData = itemModule:getItemCfgDataByID( ItemDataID ),
		case ItemCfgData of
			{}->throw(-1);
			_->ok
		end,
		case ItemCfgData#r_itemCfg.maxAmount =< 1 of
			true->throw(1);
			false->ok
		end,
		
		CanPileCount = ItemCfgData#r_itemCfg.maxAmount - ItemDBData#r_itemDB.amount,
		case CanPileCount =< 0 of
			true->throw(-1);
			false->ok
		end,
		
		case ( Amount =< 0 ) or ( Amount > ItemCfgData#r_itemCfg.maxAmount ) of
			true->throw(-1);
			false->ok
		end,
		
		case IsBinded =:= ItemDBData#r_itemDB.binded of
			true->ok;
			false->throw(-1)
		end,
		
		case CanPileCount >= Amount of
			true->
				put( "canPileByItemData_P2", Amount ),
				put( "canPileByItemData_P3", 0 );
			false->
				put( "canPileByItemData_P2", CanPileCount ),
				put( "canPileByItemData_P3", Amount - CanPileCount )
		end,
		{ true, get( "canPileByItemData_P2" ), get( "canPileByItemData_P3" ) }
	catch
		_->{ get( "canPileByItemData_P1" ), get( "canPileByItemData_P2" ), get( "canPileByItemData_P3" ) }
	end.
%%返回向背包(包括临时背包)内添加物品时，能放完该数量物品的所有格子列表，失败返回[]
%%每个格子可能是：{"space_cell", Location, SpaceCell, Amount}，表示放了多少数量在某空格
%%				 {"pile", cell, Location, PiledAmount}，表示在某格叠加了多少数量
getPlayerBagCellsByAddItemData( Location, ItemDataID, Amount, IsBinded )->
	PlayerBagCells = getPlayerBagList( Location ),
	case PlayerBagCells of
		[]->
			[];
		_->
			MyFunc = fun( Record )->
							 NeedPileAmount = get( "getPlayerBagCellsByAddItemData_P1" ),
							 case NeedPileAmount > 0 of
								 true->
									 { CanPile, PiledAmount, RemainAmount } = canPileByItemData( Location, Record#r_playerBag.cell, ItemDataID, NeedPileAmount, IsBinded ),
									 case CanPile of
										 true->
											 Result = get( "getPlayerBagCellsByAddItemData_P2" ),
											 put( "getPlayerBagCellsByAddItemData_P1", RemainAmount ),
											 case Result of
												 []->put( "getPlayerBagCellsByAddItemData_P2", [ {"pile", Location, Record#r_playerBag.cell, PiledAmount} ] );
												 _->put( "getPlayerBagCellsByAddItemData_P2", Result ++ [ {"pile", Location, Record#r_playerBag.cell, PiledAmount} ] )
											 end;
										 false->ok
									 end;
								 false->ok
							 end
					 end,
			put( "getPlayerBagCellsByAddItemData_P1", Amount ),
			put( "getPlayerBagCellsByAddItemData_P2", [] ),
			lists:foreach( MyFunc, PlayerBagCells ),
			Result = get( "getPlayerBagCellsByAddItemData_P2" ),
			case Result of
				[]->
					SpaceCell = getPlayerBagSpaceCell( Location ),
					case SpaceCell >= 0 of
						true->[{"space_cell", Location, SpaceCell, Amount}];
						false->
							case Location of
								?Item_Location_Bag->getPlayerBagCellsByAddItemData( ?Item_Location_TempBag, ItemDataID, Amount, IsBinded );
								_->[]
							end
					end;
				_->
					RemainAmount = get( "getPlayerBagCellsByAddItemData_P1" ),
					case RemainAmount > 0 of
						true->
							SpaceCell = getPlayerBagSpaceCell( Location ),
							case SpaceCell >= 0 of
								false->
									case Location of
										?Item_Location_Bag->
											Result2 = getPlayerBagCellsByAddItemData( ?Item_Location_TempBag, ItemDataID, Amount, IsBinded ),
											case Result2 of
												[]->[];
												_->Result ++ Result2
											end;
										_->[]
									end;
								true->[{"space_cell", Location, SpaceCell, RemainAmount}] ++ Result
							end;
						false->
							Result
					end
			end
	end.


addItemToPlayerByItemList(ItemList, Reason) ->
	
	put("TempItemList", []),
	Fun = fun(Item) -> 
				  case itemModule:getItemCfgDataByID(Item#itemForAdd.id) of 
					  {} ->
						  ok;
					  ItemData ->
						  case ItemData#r_itemCfg.maxAmount >= Item#itemForAdd.count of
							  true->
								  put("TempItemList", get("TempItemList")++[Item]);
							  false->
								  Quo = Item#itemForAdd.count div ItemData#r_itemCfg.maxAmount,
								  case Item#itemForAdd.count rem ItemData#r_itemCfg.maxAmount of
									  0 ->
										  ok;
									  Odd->
										  Item2 =  #itemForAdd{ id = Item#itemForAdd.id, count = Odd, binded = Item#itemForAdd.binded },
										  put("TempItemList", get("TempItemList")++[Item2])
								  end,
								  for(1, Quo, 
									  fun(_) -> 
											  Item3 =  #itemForAdd{ id = Item#itemForAdd.id, count = ItemData#r_itemCfg.maxAmount, binded = Item#itemForAdd.binded},
											  put("TempItemList", get("TempItemList")++[Item3])
									  end)
						  end
				  end
		  end,
	
	lists:foreach(Fun, ItemList),

	%% added by yueliangyou 2013-04-16
	ItemListNew=get("TempItemList"),
	case Reason of
		?Get_Item_Reson_ItemUse ->
			case getPlayerBagSpaceCellCount() >= length(ItemListNew) of
				true->
					lists:foreach(fun(I) ->
									  addItemToPlayerByItemDataID(I#itemForAdd.id, I#itemForAdd.count, I#itemForAdd.binded, Reason)
							  end,
							  ItemListNew),
					true;
				false->
					false
			end;
		?Get_Item_Reson_RechargeGift ->
			case getPlayerBagSpaceCellCount() >= length(ItemListNew) of
				true->
					lists:foreach(fun(I) ->
									  addItemToPlayerByItemDataID(I#itemForAdd.id, I#itemForAdd.count, I#itemForAdd.binded, Reason)
							  end,
							  ItemListNew),
					true;
				false->
					false
			end;
		_->
			lists:foreach(fun(I) -> 
							  addItemToPlayerByItemDataID(I#itemForAdd.id, I#itemForAdd.count, I#itemForAdd.binded, Reason)
					  end,
					  ItemListNew),
			true
	
	end.


%%向玩家背包内添加某物品，会自动叠加
addItemToPlayerByItemDataID( ItemDataID, Amount, IsBinded, GetReson )->
	case itemModule:isValidItemDataID( ItemDataID ) of
		true->
			SpaceCells = getPlayerBagCellsByAddItemData( ?Item_Location_Bag, ItemDataID, Amount, IsBinded ),
			case SpaceCells of
				[]->
					?DEBUG_OUT( "addItemToPlayerByItemDataID PlayerID[~p] ItemDataID[~p] Amount[~p] GetReson[~p] false bag cell full ", 
								[player:getCurPlayerID(), ItemDataID, Amount, GetReson] ),
					false;
				_->
					MyFunc2 = fun( Record )->
									{ CellType, Location, CellIndex, CellAmount } = Record,
									case CellType of
										"pile"->
											ItemDBData = getItemDBDataByPlayerBagCell( Location, CellIndex ),
											etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.amount, CellAmount+ItemDBData#r_itemDB.amount),
											onPlayerItemAmountChanged( itemModule:getItemDBDataByDBID(ItemDBData#r_itemDB.id), CellAmount, GetReson ),
											sendToPlayer_ItemAmountChanged( itemModule:getItemDBDataByDBID(ItemDBData#r_itemDB.id), GetReson );
										"space_cell"->
											ItemDBData = itemModule:createItemDBToPlayer(  
																			 Location,
																			 CellIndex,
																			 ItemDataID,
																			 CellAmount,
																			 IsBinded ),
											
											Player = player:getCurPlayerRecord(),	
											logdbProcess:write_log_item_change(?AddItemToPlayerByItemDataID,GetReson,{CellAmount},ItemDBData,Player),
											
											setPlayerBagCell( Location, CellIndex, ItemDBData#r_itemDB.id, 0 ),
											
											GetParam = [ GetReson, "", "" ],
											
											onPlayerGetItem( itemModule:getItemDBDataByDBID(ItemDBData#r_itemDB.id), GetParam ),
											
											sendToPlayer_GetItem( itemModule:getItemDBDataByDBID(ItemDBData#r_itemDB.id), GetReson )											
											
											
									end
							end,
					lists:foreach( MyFunc2, SpaceCells ),
					?DEBUG_OUT( "addItemToPlayerByItemDataID succ [~p] [~p] [~p] [~p]", [player:getCurPlayerID(), ItemDataID, Amount, GetReson] ),
					ItemCfg = itemModule:getItemCfgDataByID(ItemDataID),
					case ItemCfg#r_itemCfg.needBrodcast =:= 1 andalso GetReson =:= ?Get_Item_Reson_Pick of
						true->
							PlayerName = player:getPlayerProperty( player:getCurPlayerID(), #player.name ),
							ItemDataID = ItemCfg#r_itemCfg.item_data_id,
							Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_GET_ITEM, [PlayerName, ItemDataID]),
							systemMessage:sendSysMsgToAllPlayer(Str);
						false->ok
					end,
					
					
					true
			end;
		false->
			?ERROR_OUT( "addItemToPlayerByItemDataID PlayerID[~p] ItemDataID[~p] Amount[~p] GetReson[~p] false isValidItemDataID ", 
						[player:getCurPlayerID(), ItemDataID, Amount, GetReson] ),
			false
	end.

%%响应玩家获得物品
%%GetParam=[ GetReson, Bind, UsefulLife	]
%%GetReson->?Get_Item_Reson_xxx
%%Bind->"" or Get_Item_Param_Bind_xxx
%%UsefulLife->"" or Get_Item_Param_NotSet_UsefulLife
onPlayerGetItem( ItemDBData, GetParam )->
	put( ?ProcTempValue1, -1 ),
	put( ?ProcTempValue2, "" ),
	put( ?ProcTempValue3, "" ),

	case GetParam of
		[]->ok;
		_->
			[D1|Remain1] = GetParam,
			put( ?ProcTempValue1, D1 ),
			case Remain1 of
				[]->ok;
				_->
					[D2|Remain2] = Remain1,
					put( ?ProcTempValue2, D2 ),
					case Remain2 of
						[]->ok;
						_->
							[D3|_] = Remain2,
							put( ?ProcTempValue3, D3 )
					end
			end
	end,
	
	put( ?ProcTempValue4, ItemDBData ),
	
%% 	case get( ?ProcTempValue2 ) of
%% 		""->
%% 			GetReson = get( ?ProcTempValue1 ),
%% 			
%% 			put( ?ProcTempValue2, false ),
%% 			case GetReson of
%% 				?Get_Item_Reson_Pick->put( ?ProcTempValue2, true );
%% 				?Get_Item_Reson_BuyFromNpc->put( ?ProcTempValue2, true );
%% 				?Get_Item_Reson_GM->put( ?ProcTempValue2, true );
%% 				?Get_Item_Reson_Mail->put( ?ProcTempValue2, true );
%% 				?Get_Item_Reson_TradeFromPlayer->put( ?ProcTempValue2, true );
%% 				?Get_Item_Reson_Task->put( ?ProcTempValue2, true );
%% 				?Get_Item_Reson_ItemUse->put( ?ProcTempValue2, true );
%% 				?Get_Item_Reson_Split->put( ?ProcTempValue2, true );
%% 				_->ok
%% 			end,
%% 			
%% 			IsGetBinded = get( ?ProcTempValue2 ),
%% 			put( ?ProcTempValue2, false ),
%% 			case IsGetBinded of
%% 				true->
%% 					ItemData = itemModule:getItemCfgDataByID( ItemDBData#r_itemDB.item_data_id ),
%% 					case ItemData#r_itemCfg.bindType of
%% 						?Item_Bind_Geted->put( ?ProcTempValue2, true );
%% 						?Item_Bind_Pick->put( ?ProcTempValue2, true );
%% 						_->put( ?ProcTempValue2, false )
%% 					end;
%% 				false->ok
%% 			end,
%% 
%% 			case get( ?ProcTempValue2 ) of
%% 				true->
%% 					etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.binded, true),
%% 					put( ?ProcTempValue4, itemModule:getItemDBDataByDBID( ItemDBData#r_itemDB.id ) );
%% 				false->ok
%% 			end;
%% 		?Get_Item_Param_Bind_Set_Binded->
%% 			etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.binded, true),
%% 			put( ?ProcTempValue4, itemModule:getItemDBDataByDBID( ItemDBData#r_itemDB.id ) );
%% 		?Get_Item_Param_Bind_Set_UnBinded->
%% 			etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.binded, false),
%% 			put( ?ProcTempValue4, itemModule:getItemDBDataByDBID( ItemDBData#r_itemDB.id ) );
%% 		_->ok
%% 	end,
	
	case get( ?ProcTempValue3 ) of
		""->
			ItemData2 = itemModule:getItemCfgDataByID( ItemDBData#r_itemDB.item_data_id ),
			case ItemData2#r_itemCfg.usefulLife > 0 of
				true->
					etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.expiration_time, 1),
					put( ?ProcTempValue4, itemModule:getItemDBDataByDBID( ItemDBData#r_itemDB.id ) );
				false->ok
			end;
		?Get_Item_Param_NotSet_UsefulLife->ok;
		_->ok
	end,

	Final_ItemDBData = get( ?ProcTempValue4 ),
	?DEBUG_OUT( "onPlayerGetItem ItemDBData[~p] GetParam[~p]", [Final_ItemDBData, GetParam] ).
%%响应玩家物品数量变化
onPlayerItemAmountChanged( ItemDBData, ChangeAmount, Reson )->
	Player = player:getCurPlayerRecord(),
	logdbProcess:write_log_item_change(?OnPlayerItemAmountChanged,Reson,{ChangeAmount},ItemDBData,Player),	
	%%?DEBUG_OUT( "onPlayerItemAmountChanged [~p] [~p] [~p] [~p]", [player:getCurPlayerID(), ItemDBData, ChangeAmount, Reson] ),
	ok.
%%响应玩家物品销毁
onPlayerItemDestoyed( ItemDBData, DestroyReson )->
	case ItemDBData#r_itemDB.location of
		?Item_Location_Bag->
			setPlayerBagCell( ItemDBData#r_itemDB.location, ItemDBData#r_itemDB.cell, 0, 0 );
		?Item_Location_TempBag->
			setPlayerBagCell( ItemDBData#r_itemDB.location, ItemDBData#r_itemDB.cell, 0, 0 );
		?Item_Location_Storage->
			setPlayerBagCell( ItemDBData#r_itemDB.location, ItemDBData#r_itemDB.cell, 0, 0 );
		?Item_Location_BackBuy->
			setPlayerBagCell( ItemDBData#r_itemDB.location, ItemDBData#r_itemDB.cell, 0, 0 );
		_->ok
	end,

	
	Player = player:getCurPlayerRecord(),
	logdbProcess:write_log_item_change(?OnPlayerItemDestoyed,DestroyReson,{ItemDBData#r_itemDB.amount},ItemDBData,Player),
	?DEBUG_OUT( "onPlayerItemDestoyed PlayerID[~p], ItemDBData[~p], DestroyReson[~p]", [player:getCurPlayerID(), ItemDBData, DestroyReson] ).

%%------------------------------------------------Player Bag Msg------------------------------------------------
%%发送玩家获得物品消息
sendToPlayer_GetItem( ItemDBData, _GetReson )->
	ItemInfo = itemModule:makeItemToMsgItemInfo(ItemDBData),
	player:send( #pk_PlayerGetItem{ item_info=ItemInfo } ).

%%发送玩家物品参数变化消息
sendToPlayer_ItemParamChanged( ItemDBData, Reson )->
	player:send( #pk_PlayerItemParamChanged{ itemDBID=ItemDBData#r_itemDB.id, param1=ItemDBData#r_itemDB.param1, param2=ItemDBData#r_itemDB.param2,reson=Reson } ).


%%发送玩家物品数量变化消息
sendToPlayer_ItemAmountChanged( ItemDBData, Reson )->
	player:send( #pk_PlayerItemAmountChanged{ itemDBID=ItemDBData#r_itemDB.id, amount=ItemDBData#r_itemDB.amount, reson=Reson } ).
%%处理玩家销毁物品消息
onMsgDestroyItem( ItemDBID )->
	ItemDBData = itemModule:getItemDBDataByDBID(ItemDBID),
	try
		case ItemDBData of
			{}->throw(-1);
			_->ok
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

		%%是否能够丢弃
		case playerItems:canDiscard( ItemDBData#r_itemDB.item_data_id ) of	
			true->ok;
			_->throw(-1)
		end,

		doneDestroyItemInBag( ItemDBData#r_itemDB.location, ItemDBData#r_itemDB.cell, ?Destroy_Item_Reson_Player )
	catch
		_->ok
	end.

doneDestroyItemInBag( Location, Cell, DestroyReson )->
	ValidCell = isValidPlayerBagCell( Location, Cell ),
	IsLockedCell = isLockedPlayerBagCell( Location, Cell ),
	case (ValidCell) andalso (not IsLockedCell) of
		true->
			ItemDBData = getItemDBDataByPlayerBagCell( Location, Cell ),
			case ItemDBData of
				{}->?DEBUG_OUT( "doneDestroyItemInBag PlayerID[~p], Location[~p], Cell[~p], DestroyReson[~p] false empty", [player:getCurPlayerID(), Location, Cell, DestroyReson] );
				_->
					itemModule:deleteItemDB(ItemDBData),
					onPlayerItemDestoyed( ItemDBData, DestroyReson ),
					player:send( #pk_PlayerDestroyItem{ itemDBID=ItemDBData#r_itemDB.id, reson=DestroyReson } )
			end;
		false->
			?LOG_OUT( "doneDestroyItemInBag PlayerID[~p], Cell[~p], DestroyReson[~p] false cell", [player:getCurPlayerID(), Cell, DestroyReson] )
	end.
%%处理GM指令获得物品消息
onMsgGMGetItem( ItemDataID, Amount, Binded )->
	ItemData = itemModule:getItemCfgDataByID( ItemDataID ),
	case ItemData of
		{}->?DEBUG_OUT( "onMsgGMGetItem empty itemdata [~p] [~p] [~p]", [player:getCurPlayerID(), ItemDataID, Amount] );
		_->
			case (Amount > 0 ) andalso ( Amount =< ItemData#r_itemCfg.maxAmount ) of
				true->addItemToPlayerByItemDataID( ItemDataID, Amount, Binded, ?Get_Item_Reson_GM );
				false->addItemToPlayerByItemDataID( ItemDataID, ItemData#r_itemCfg.maxAmount, Binded, ?Get_Item_Reson_GM )
			end
	end.

%%处理背包或仓库整理消息
onMsgPlayerBagOrder( Location )->
	PlayerID = player:getCurPlayerID(),
	try
		%% firstly, check	
		case (Location =:= ?Item_Location_Bag) orelse (Location =:= ?Item_Location_Storage) of
			true->ok;
			false->
				?LOG_OUT("onMsgPlayerBagOrder fail, Location : ~p error,PlayerID:~p",[Location,PlayerID]),
				throw(-1)
		end,		
		%%背包内必须没有一个格子被锁定
		case isLockedPlayerBag( Location ) of
			true->
				?LOG_OUT("onMsgPlayerBagOrder fail,cell is locked, Location : ~p ,PlayerID:~p",[Location,PlayerID]),
				throw(-1);
			false->ok
		end,

		%% sort item list by item_data_id and binded
		ItemList = getPlayerItemDBDataList(Location),
		FunSort1 = fun(X,Y) ->
						  case X#r_itemDB.item_data_id =:= Y#r_itemDB.item_data_id of
							  true -> Y#r_itemDB.binded =< X#r_itemDB.binded;
							  false -> X#r_itemDB.item_data_id =< Y#r_itemDB.item_data_id
						  end				  
				  end,
		ItemSortList = lists:sort(FunSort1, ItemList),
		
		%% fold items		
		{FoldItemList,DeleteItemIdList} = foldItemBySortList(ItemSortList,[],[]),
		%% sort items 
		FunSort2 = fun(X,Y) ->
						  case X#r_itemDB.item_data_id =:= Y#r_itemDB.item_data_id of
							  true -> 
									case Y#r_itemDB.binded =:= X#r_itemDB.binded of
										true->
											X#r_itemDB.amount =< Y#r_itemDB.amount;
										false->
											Y#r_itemDB.binded =< X#r_itemDB.binded
									end;
							  false -> X#r_itemDB.item_data_id =< Y#r_itemDB.item_data_id
						  end				  
				  end,
		FoldItemSortList = lists:sort(FunSort2, FoldItemList),
		
		%% delete item,must before change item and bag 
		DeleteItemFunc = fun( Id )->
							itemModule:deleteItemDBById( Id ),
							?LOG_OUT("onMsgPlayerBagOrder delete item, id : ~p ",[Id]),
							player:send( #pk_PlayerDestroyItem{ itemDBID=Id, reson=?Destroy_Item_Reson_BagOrder } )
						end,
		lists:foreach( DeleteItemFunc, DeleteItemIdList ),
		
		
		%% change item and bag by FoldItemSortList
		put("onMsgPlayerBagOrder_cellIndex",0),
		UpdateItemAndBagCellFunc = fun( Record )->
							ItemDBID = Record#r_itemDB.id,
							Amount = Record#r_itemDB.amount,
							Cell = get("onMsgPlayerBagOrder_cellIndex"),
							put("onMsgPlayerBagOrder_cellIndex",Cell+1),
							ItemDBData = itemModule:getItemDBDataByDBID( ItemDBID ),	
							PlayerBagCell = getPlayerBagByCell( Location, Cell ),
							
							case (ItemDBData#r_itemDB.amount =:= Amount) andalso (PlayerBagCell#r_playerBag.itemDBID =:= ItemDBData#r_itemDB.id) of
								true->ok;
								false->
									case ItemDBData#r_itemDB.amount =:= Amount of
										true ->ok;
										false ->
											etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.amount, Amount),
											onPlayerItemAmountChanged( ItemDBData, Amount-ItemDBData#r_itemDB.amount, ?Get_Item_Reson_BagOrder ),
											?LOG_OUT("onMsgPlayerBagOrder ItemAmountChanged, Cell : ~p ,id:~p, amount: ~p",[Cell,ItemDBData#r_itemDB.id,Amount-ItemDBData#r_itemDB.amount]),
											sendToPlayer_ItemAmountChanged( itemModule:getItemDBDataByDBID( ItemDBData#r_itemDB.id ), ?Get_Item_Reson_BagOrder )
									end,
									case PlayerBagCell#r_playerBag.itemDBID =:= ItemDBData#r_itemDB.id of
										true -> ok;
										false ->
											setPlayerBagCell( Location, Cell, ItemDBData#r_itemDB.id, 0 ),								
											etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBID, #r_itemDB.cell, Cell),	
											?LOG_OUT("onMsgPlayerBagOrder cell change, Cell : ~p ,id:~p",[Cell,ItemDBData#r_itemDB.id]),
											ToUserMsg = #pk_ItemBagCellSet{ cells=[#pk_ItemBagCellSetData{location=Location, cell=Cell, itemDBID=ItemDBData#r_itemDB.id}] },			
											player:send( ToUserMsg )
									end								
							end
					end,
		lists:foreach( UpdateItemAndBagCellFunc, FoldItemSortList ),
			
		% reset the bag which cell (cell>=UsedCells) and (cell<MaxPlayerBagCell)	
		UsedCells = get("onMsgPlayerBagOrder_cellIndex"),
 		case Location of
 			?Item_Location_Bag ->MaxPlayerBagCell = player:getCurPlayerProperty( #player.maxEnabledBagCells );
 			?Item_Location_Storage ->MaxPlayerBagCell = player:getCurPlayerProperty( #player.maxEnabledStorageBagCells )
 		end,
		?LOG_OUT("onMsgPlayerBagOrder Location MaxPlayerBagCell: ~p ,UsedCells:~p",[MaxPlayerBagCell,UsedCells]),
		ResetBagFunc = fun( CellIndex )->
							 Bag = getPlayerBagByCell( Location, CellIndex ),
							 case (Bag =:= {}) orelse (Bag#r_playerBag.itemDBID =:= 0) of
								true->ok;
								false->
									setPlayerBagCell( Location, CellIndex, 0, 0 ),
									?LOG_OUT("onMsgPlayerBagOrder delete cell , Cell : ~p ",[CellIndex]),
									ToUserMsg = #pk_ItemBagCellSet{ cells=[#pk_ItemBagCellSetData{location=Location, cell=CellIndex, itemDBID=0}] },											
									player:send( ToUserMsg )											
							end
					 end,
		case UsedCells <  MaxPlayerBagCell of
			true ->common:for(UsedCells, MaxPlayerBagCell-1, ResetBagFunc);
			false ->ok
		end,

		Msg = #pk_PlayerBagOrderResult{ location=Location, cell = 0 },
		player:send(Msg),
		?LOG_OUT("onMsgPlayerBagOrder sucess,Location : ~p ,PlayerID:~p",[Location,PlayerID])
	
	catch
		_->
			?ERROR_OUT("onMsgPlayerBagOrder fail, PlayerID:~p",[PlayerID]),
			Msg2 = #pk_PlayerBagOrderResult{ location=Location, cell = -1 },
			player:send(Msg2),
			ok
	end.

%% 堆叠
foldItemBySortList([],FoldList,DeleteIdList) ->
	{FoldList,DeleteIdList};
foldItemBySortList(SortList,FoldList,DeleteIdList) ->	
	[ItemDBData|RemainItemList] = SortList,
	ItemCfg = itemModule:getItemCfgDataByID( ItemDBData#r_itemDB.item_data_id ),
	case ItemCfg of
		{}->
			?ERROR_OUT("foldItemBySortList,getItemCfgDataByID fail, item_data_id:~p",[ItemDBData#r_itemDB.item_data_id]),
			throw(-1);
 		_->ok
	end,
	Amount = ItemDBData#r_itemDB.amount,
	MaxAmount = ItemCfg#r_itemCfg.maxAmount,
	case ( Amount > 0 ) andalso (Amount =< MaxAmount ) of
		true->ok;
		false->
			?ERROR_OUT("foldItemBySortList,item_data_id:~p, Amount:~p error maxAmount:~p",[ItemDBData#r_itemDB.item_data_id,Amount,ItemCfg#r_itemCfg.maxAmount]),
			throw(-1)
	end,	
	case FoldList =:= [] of
		true->
			FoldList1 = [ItemDBData|FoldList],
			foldItemBySortList(RemainItemList,FoldList1,DeleteIdList);
		false->
			[ItemDBDataFromFold|RemainFoldList] = FoldList,
			case ItemDBDataFromFold#r_itemDB.item_data_id =:= ItemDBData#r_itemDB.item_data_id 
				andalso ItemDBDataFromFold#r_itemDB.binded =:= ItemDBData#r_itemDB.binded andalso ItemDBDataFromFold#r_itemDB.amount < MaxAmount of
				true ->
					%% fold
					case Amount =< (MaxAmount-ItemDBDataFromFold#r_itemDB.amount) of
						true -> NewItemDBDataFromFold=setelement( #r_itemDB.amount, ItemDBDataFromFold, ItemDBDataFromFold#r_itemDB.amount+Amount),
								NewFoldList1 = [NewItemDBDataFromFold|RemainFoldList],
								NewDeleteIdList = [ItemDBData#r_itemDB.id|DeleteIdList],
								foldItemBySortList(RemainItemList,NewFoldList1,NewDeleteIdList);
						false ->
								AddAmount = MaxAmount - ItemDBDataFromFold#r_itemDB.amount,
								NewItemDBDataFromFold=setelement( #r_itemDB.amount, ItemDBDataFromFold, MaxAmount),
								NewFoldList1 = [NewItemDBDataFromFold|RemainFoldList],
								NewItemDBData = setelement( #r_itemDB.amount, ItemDBData, Amount-AddAmount),
								NewFoldList2 = [NewItemDBData|NewFoldList1],
								foldItemBySortList(RemainItemList,NewFoldList2,DeleteIdList)
					end;					
				false->
					NewFoldList1 = [ItemDBData|FoldList],
					foldItemBySortList(RemainItemList,NewFoldList1,DeleteIdList)
			end
	end.
		

getPlayerItemDBDataList(Location_Param)->
	PlayerID = player:getCurPlayerID(),
	Q = ets:fun2ms( fun(#r_itemDB{id=_,owner_type=OwnerType, owner_id=OwnerID,location=Location} = Record ) 
						 when ( OwnerType=:=?item_owner_type_player ) andalso ( OwnerID=:=PlayerID ) andalso Location =:=Location_Param  -> Record end),
	ets:select(itemModule:getCurItemTable(), Q).
		

%%处理背包格子开启请求
onMsgPlayerBagCellOpen( Cell ,Location )->
	try
		
		case Location of
			?Item_Location_Bag->
				
				CurMaxEnabledBagCells = player:getCurPlayerProperty( #player.maxEnabledBagCells ),
		
				case ( Cell =< CurMaxEnabledBagCells ) orelse ( Cell > ?Max_Bag_Cells ) of
				true->
					player:send(#pk_PlayerBagCellOpenResult{ result=?PlayerBagCellOpen_Result_Full }),
					throw(-1);
				false->ok
				end,

				CellNum = Cell-CurMaxEnabledBagCells,
				LockItemCount = playerItems:getItemCountByItemData(
													?Item_Location_Bag, 
													globalSetup:getGlobalSetupValue(#globalSetup.bagCellLockItem), 
													"all"),
				case LockItemCount >= CellNum of
					true->
						NeedItemCount=CellNum,
						NeedGoldNum = 0;
					_->
						NeedItemCount=LockItemCount,
						NeedGoldNum = (CellNum-LockItemCount) * globalSetup:getGlobalSetupValue(#globalSetup.cellLockGoldNum)
				end,
				%%消耗物品
				[DecResult|DecItems] = playerItems:canDecItemInBag(
																	?Item_Location_Bag, 
																	globalSetup:getGlobalSetupValue(#globalSetup.bagCellLockItem), 
																	NeedItemCount, "all"),
				case NeedItemCount =:= 0 orelse DecResult of
					true->
						%%消耗元宝
						case NeedGoldNum =:=0 orelse playerMoney:canDecPlayerGoldAndBindGold(NeedGoldNum) of
							true ->
								case NeedGoldNum =:=0 of
									false->
										ParamTuple = #token_param{changetype = ?Gold_Change_BagOpenCell,
												  param1=Cell},
										playerMoney:decPlayerGoldAndBindGold(NeedGoldNum, ?Gold_Change_BagOpenCell,ParamTuple);
									_->ok
								end,
								case NeedItemCount =:= 0 of
									false->
										playerItems:decItemInBag(DecItems, ?Destroy_Item_Reson_LockBagCell);
									_->ok
								end,
								
								playerItems:openPlayerBagEnable(Location,CurMaxEnabledBagCells,Cell),
								player:setCurPlayerProperty(#player.maxEnabledBagCells, Cell),
								player:send( #pk_PlayerBagCellEnableChanged{ cell=Cell,location= Location, gold=0, item_count=0} ),
								player:send(#pk_PlayerBagCellOpenResult{ result=?PlayerBagCellOpen_Result_Succ }),
								?DEBUG_OUT( "onMsgPlayerBagCellOpen PlayerID[~p], Cell[~p],Location[~p]", [player:getCurPlayerID(), Cell,Location] );
							false ->
								player:send(#pk_PlayerBagCellOpenResult{ result=?PlayerBagCellOpen_Result_NotEnough })
						end;
					_->player:send(#pk_PlayerBagCellOpenResult{ result=?PlayerBagCellOpen_Result_NotEnough })
				end;

			?Item_Location_Storage->
				
				CurMaxEnabledStorageBagCells = player:getCurPlayerProperty( #player.maxEnabledStorageBagCells ),
				case ( Cell =< CurMaxEnabledStorageBagCells ) orelse ( Cell > ?Max_StorageBag_Cells ) of
				true->
					player:send(#pk_PlayerBagCellOpenResult{ result=?PlayerBagCellOpen_Result_Full }),
					throw(-1);
				false->ok
				end,

				CellNum = Cell-CurMaxEnabledStorageBagCells,
				LockItemCount = playerItems:getItemCountByItemData(
													?Item_Location_Bag, 
													globalSetup:getGlobalSetupValue(#globalSetup.storageCellLockItem), 
													"all"),
				case LockItemCount >= CellNum of
					true->
						NeedItemCount=CellNum,
						NeedGoldNum = 0;
					_->
						NeedItemCount=LockItemCount,
						NeedGoldNum = (CellNum-LockItemCount) * globalSetup:getGlobalSetupValue(#globalSetup.cellLockGoldNum)
				end,
				%%消耗物品
				[DecResult|DecItems] = playerItems:canDecItemInBag(
																	?Item_Location_Bag, 
																	globalSetup:getGlobalSetupValue(#globalSetup.storageCellLockItem), 
																	NeedItemCount, "all"),
				
				case NeedItemCount =:= 0 orelse DecResult of
					true->
						%%消耗元宝
						case NeedGoldNum =:= 0 orelse playerMoney:canDecPlayerGoldAndBindGold(NeedGoldNum) of
							true ->
								case NeedGoldNum =:= 0 of
									false->
										ParamTuple = #token_param{changetype = ?Gold_Change_StoreOpenCell,
												  param1=Cell},
										playerMoney:decPlayerGoldAndBindGold(NeedGoldNum, ?Gold_Change_StoreOpenCell, ParamTuple);
									_->ok
								end,
								
								case NeedItemCount =:= 0 of
									false->
										playerItems:decItemInBag(DecItems, ?Destroy_Item_Reson_LockStorageCell);
									_->ok
								end,
								
								playerItems:openPlayerBagEnable(Location,CurMaxEnabledStorageBagCells,Cell),
								player:setCurPlayerProperty(#player.maxEnabledStorageBagCells , Cell),
								player:send( #pk_PlayerBagCellEnableChanged{ cell=Cell,location=Location, gold=0, item_count=0 } ),
								player:send(#pk_PlayerBagCellOpenResult{ result=?PlayerBagCellOpen_Result_Succ }),
								?DEBUG_OUT( "onMsgPlayerBagCellOpen PlayerID[~p], Cell[~p],Location[~p]", [player:getCurPlayerID(), Cell,Location] );
							false ->
								player:send(#pk_PlayerBagCellOpenResult{ result=?PlayerBagCellOpen_Result_NotEnough })
						end;
					_->player:send(#pk_PlayerBagCellOpenResult{ result=?PlayerBagCellOpen_Result_NotEnough })
				end;
			_->
				ok
		end
	
	catch
		_->ok
	end,
	ok.
%%仓库密码改变
onMsgChangeStorageBagPassWord( OldPassWord,NewPassWord ,Status)->
	try
		case Status of 
			?PlayerSetStorageBagPassWord->
				player:setCurPlayerProperty(#player.storageBagPassWord, NewPassWord),
				put("PlayerImportPassWordResult",?PlayerPassWord_Success),
				Msg = #pk_PlayerStorageBagPassWordChanged{result = ?PlayerSetPassWordSuccess},
				player:send(Msg);
			?PlayerChangeStorageBagPassWord->
				PassWord  = player:getCurPlayerProperty( #player.storageBagPassWord ),
				case string:equal(OldPassWord,PassWord) of
					true->
						player:setCurPlayerProperty(#player.storageBagPassWord, NewPassWord),
						put("PlayerImportPassWordResult",?PlayerPassWord_Success),
						Msg = #pk_PlayerStorageBagPassWordChanged{result = ?PlayerChangePassWordSuccess},
						player:send(Msg);
					false->
						Msg = #pk_PlayerStorageBagPassWordChanged{result = ?PlayerChange_OldPassSuccessWrong},
						player:send(Msg)
				end;
			?PlayerUnlockStorageBagPassWord->
				UnlockTimes = player:getCurPlayerProperty( #player.unlockTimes ),
				case UnlockTimes > common:timestamp() of
					false->
						player:setCurPlayerProperty(#player.unlockTimes, 0),
						player:setCurPlayerProperty(#player.storageBagPassWord, ""),
						Msg = #pk_PlayerStorageBagPassWordChanged{result = ?PlayerClearPassWordSuccess},
						player:send(Msg);
					true->
						throw(-1)
				end	
		end
	catch
		_->ok
	end,
	ok.

%%元宝密码的改变
onMsgChangeGoldPassWord( OldPassWord,NewPassWord ,Status)->
	try
		case Status of 
			?PlayerSetGoldPassWord->
				player:setCurPlayerProperty(#player.goldPassWord, NewPassWord),
				put("PlayerImportGoldPassWordResult",?PlayerPassWord_Success),
				Msg = #pk_PlayerGoldPassWordChanged{result = ?PlayerSetGoldPassWordSuccess},
				player:send(Msg);
			?PlayerChangeGoldPassWord->
				PassWord  = player:getCurPlayerProperty( #player.goldPassWord ),
				case string:equal(OldPassWord,PassWord) of
					true->
						player:setCurPlayerProperty(#player.goldPassWord, NewPassWord),
						put("PlayerImportGoldPassWordResult",?PlayerPassWord_Success),
						Msg = #pk_PlayerGoldPassWordChanged{result = ?PlayerChangeGoldPassWordSuccess},
						player:send(Msg);
					false->
						Msg = #pk_PlayerGoldPassWordChanged{result = ?PlayerChange_OldGoldPassSuccessWrong},
						player:send(Msg)
				end;
			?PlayerUnlockGoldPassWord->
				UnlockTimes = player:getCurPlayerProperty( #player.unlockTimes ),
					case UnlockTimes > common:timestamp() of
					false->
						player:setCurPlayerProperty(#player.goldPassWordUnlockTimes , 0),
						player:setCurPlayerProperty(#player.goldPassWord, ""),
						Msg = #pk_PlayerGoldPassWordChanged{result = ?PlayerClearGoldPassWordSuccess},
						player:send(Msg);
					true->
						throw(-1)
				end;
			?PlayerCancelGoldPassWord->
				case get("PlayerImportGoldPassWordResult") == ?PlayerPassWord_Success of
					true->
						player:setCurPlayerProperty(#player.goldPassWordUnlockTimes , 0),
						player:setCurPlayerProperty(#player.goldPassWord, ""),
						Msg = #pk_PlayerGoldPassWordChanged{result = ?PlayerCancelGoldPassWordSuccess},
						player:send(Msg);
					false->
						PassWord  = player:getCurPlayerProperty( #player.goldPassWord ),
						case string:equal(OldPassWord,PassWord) of
							true->
								player:setCurPlayerProperty(#player.goldPassWordUnlockTimes , 0),
								player:setCurPlayerProperty(#player.goldPassWord, ""),
								Msg = #pk_PlayerGoldPassWordChanged{result = ?PlayerCancelGoldPassWordSuccess},
								player:send(Msg);
							false->
								Msg = #pk_PlayerGoldPassWordChanged{result = ?PlayerCancelGoldPassWordFail},
								player:send(Msg)
						end
				end
		end
	catch
		_->ok
	end,
	ok.


onPlayerReturnGoldPassWord()->
	%%判断密码是否正确
	PassWord  = player:getCurPlayerProperty( #player.goldPassWord ),
	case string:equal(PassWord,"") of
		true->true;
		false->
			case get("PlayerImportGoldPassWordResult") == ?PlayerPassWord_Success of
				true->true;
				false->
					Msg = #pk_PlayerImportGoldPassWordResult{ result  = ?PlayerImportPassWord},
					player:send(Msg),
					false
			end
	end.

onMsgPlayerImportPassWord (PassWord,PassWordType)->
	try
		case PassWordType of
			?StorageBagPassWord->
				OldPassWord  = player:getCurPlayerProperty( #player.storageBagPassWord ),
				case string:equal(OldPassWord,PassWord) of
					true->
						put("PlayerImportPassWordResult",?PlayerPassWord_Success),
						Msg = #pk_PlayerImportPassWordResult{ result  = ?PlayerPassWord_Success},
						player:send(Msg);
					false->
						put("PlayerImportPassWordResult",?PlayerPassWord_Fail),
						Msg = #pk_PlayerImportPassWordResult{ result  = ?PlayerPassWord_Fail},
						player:send(Msg)
				end;
			?GoldPassWord->
				OldGoldPassWord  = player:getCurPlayerProperty( #player.goldPassWord ),
				case string:equal(OldGoldPassWord,PassWord) of
					true->
						put("PlayerImportGoldPassWordResult",?PlayerPassWord_Success),
						Msg = #pk_PlayerImportGoldPassWordResult{ result  = ?PlayerPassWord_Success},
						player:send(Msg);
					false->
						put("PlayerImportGoldPassWordResult",?PlayerPassWord_Fail),
						Msg = #pk_PlayerImportGoldPassWordResult{ result  = ?PlayerPassWord_Fail},
						player:send(Msg)
				end
		end
	catch
		_->ok
	end,
	ok.

onMsgRequestUnlockingStorageBagPassWord( Type )->
	try
		case Type of
			?StorageBagPassWord->
				player:setCurPlayerProperty(#player.unlockTimes, common:timestamp() +72*3600 ),
				Msg = #pk_PlayerUnlockTimesChanged{unlockTimes = 72*3600},
				player:send(Msg);
			?GoldPassWord->
				player:setCurPlayerProperty(#player.goldPassWordUnlockTimes , common:timestamp() +72*3600 ),
				Msg = #pk_PlayerGoldUnlockTimesChanged{unlockTimes =72*3600},
				player:send(Msg)
		end
	catch
		_->ok
	end,
	ok.
	
onMsgRequestCancelUnlockingStorageBagPassWord( Type )->
	try
		case Type of
			?StorageBagPassWord->
				player:setCurPlayerProperty(#player.unlockTimes, 0 ),
				Msg = #pk_PlayerUnlockTimesChanged{unlockTimes = 0},
				player:send(Msg);
			?GoldPassWord->
				player:setCurPlayerProperty(#player.goldPassWordUnlockTimes, 0 ),
				Msg = #pk_PlayerGoldUnlockTimesChanged{unlockTimes = 0},
				player:send(Msg)
		end
	catch
		_->ok
	end,
	ok.
onPlayerOnlineToUnlockTimes()->
	UnlockTimes = player:getCurPlayerProperty( #player.unlockTimes ),
	case UnlockTimes > 0 of
		true->
			case UnlockTimes > common:timestamp() of
				true->
					Msg = #pk_PlayerUnlockTimesChanged{unlockTimes = UnlockTimes - common:timestamp() },
					player:send(Msg);
				false->
					player:setCurPlayerProperty(#player.unlockTimes, 0),
					player:setCurPlayerProperty(#player.storageBagPassWord, ""),
					Msg = #pk_PlayerStorageBagPassWordChanged{result = ?PlayerClearPassWordSuccess},
					player:send(Msg)
			end,
			ok;
		false->
			ok
	end.

onPlayerOnlineToGoldPassWordUnlockTimes()->

	UnlockTimes = player:getCurPlayerProperty( #player.goldPassWordUnlockTimes  ),
	case UnlockTimes > 0 of
		true->
			case UnlockTimes > common:timestamp() of
				true->
					Msg = #pk_PlayerGoldUnlockTimesChanged{unlockTimes = UnlockTimes - common:timestamp() },
					player:send(Msg);
				false->
					player:setCurPlayerProperty(#player.goldPassWordUnlockTimes , 0),
						player:setCurPlayerProperty(#player.goldPassWord, ""),
						Msg = #pk_PlayerGoldPassWordChanged{result = ?PlayerClearGoldPassWordSuccess},
						player:send(Msg)
			end;
		false->
			ok
	end.

%%背包内出售物品
onMsgPlayerBagSellItem( Cell )->
	try
		ItemDBData = getItemDBDataByPlayerBagCell( ?Item_Location_Bag, Cell ),
		case ItemDBData of
			{}->throw(-1);
			_->ok
		end,
		
		case isLockedPlayerBagCell( ?Item_Location_Bag, Cell) of
			true->throw(-1);
			_->ok
		end,
		
		PlayerVip = player:getPlayerProperty( #player.vip ),
		case PlayerVip < ?PlayerBag_SellItem_Vip_Level of
			true->throw(-1);
			_->ok
		end,
		
		doneDestroyItemInBag( ?Item_Location_Bag, Cell, ?Destroy_Item_Reson_Sell )

	catch
		_->ok
	end,
	ok.

%%临时背包清空请求
onMsgClearTempBag()->
	ItemDBList = getItemDBDataListByPlayerLocation( ?Item_Location_TempBag ),
	case ItemDBList of
		[]->ok;
		_->
			MyFunc = fun( Record )->
							 doneDestroyItemInBag( Record#r_itemDB.location, Record#r_itemDB.cell, ?Destroy_Item_Reson_Player_ClearTempBag )
					 end,
			lists:foreach(MyFunc, ItemDBList)
	end,
	ok.

%%将临时背包中的全部物品放入背包内请求
onMsgAllPutInBag( )->
	try
		ItemDBList = getItemDBDataListByPlayerLocation( ?Item_Location_TempBag ),
		case ItemDBList of
			[]->throw(-1);
			_->ok
		end,
		
		MyFunc = fun( Record )->
						 SpaceCell = getPlayerBagSpaceCell( ?Item_Location_Bag ),
						 case SpaceCell >= 0 of
							 false->throw(-1);
							 true->ok
						 end,
						 
						 setPlayerBagCell( Record#r_itemDB.location, Record#r_itemDB.cell, 0, 0 ),
						 
						 etsBaseFunc:changeFiled( itemModule:getCurItemTable(), Record#r_itemDB.id, #r_itemDB.location, ?Item_Location_Bag ),
						 etsBaseFunc:changeFiled( itemModule:getCurItemTable(), Record#r_itemDB.id, #r_itemDB.cell, SpaceCell ),
						 
						 setPlayerBagCell( ?Item_Location_Bag, SpaceCell, Record#r_itemDB.id, 0 ),
						 
						 player:send( #pk_PlayerItemLocationCellChanged{ itemDBID=Record#r_itemDB.id, location=?Item_Location_Bag, cell=SpaceCell } ),
						 ok
		 		 end,
		lists:foreach(MyFunc, ItemDBList)
	catch
		_->ok
	end,
	ok.

onMsgPutInBag( Cell )->
	try
		ItemDBData = getItemDBDataByPlayerBagCell( ?Item_Location_TempBag, Cell ),
		case ItemDBData of
			{}->throw(-1);
			_->ok
		end,
		
		case isLockedPlayerBagCell(?Item_Location_TempBag, Cell) of
			true->throw(-1);
			false->ok
		end,
		
		SpaceCell = getPlayerBagSpaceCell( ?Item_Location_Bag ),
		case SpaceCell >= 0 of
			false->throw(-1);
			true->ok
		end,
						 
		setPlayerBagCell( ItemDBData#r_itemDB.location, ItemDBData#r_itemDB.cell, 0, 0 ),
						 
		etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.location, ?Item_Location_Bag ),
		etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.cell, SpaceCell ),
						 
		setPlayerBagCell( ?Item_Location_Bag, SpaceCell, ItemDBData#r_itemDB.id, 0 ),
						 
		player:send( #pk_PlayerItemLocationCellChanged{ itemDBID=ItemDBData#r_itemDB.id, location=?Item_Location_Bag, cell=SpaceCell } ),

		ok
	catch
		_->ok
	end.
	


%%请求将仓库内某格子上物品移动到主背包
onMsgRequestMoveStorageBagItem( Cell )->
	try
		ItemDBData = getItemDBDataByPlayerBagCell( ?Item_Location_Storage, Cell ),
		case ItemDBData of
			{}->throw(-1);
			_->ok
		end,
		
		case isLockedPlayerBagCell(?Item_Location_Storage, Cell) of
			true->throw(-1);
			false->ok
		end,
		
		%%判断密码是否正确
		PassWord  = player:getCurPlayerProperty( #player.storageBagPassWord ),
		
		case string:equal(PassWord,"") of
			true->
				ok;
			false->
				case get("PlayerImportPassWordResult") == ?PlayerPassWord_Success of
					true->
						ok;
					false->
						Msg = #pk_PlayerImportPassWordResult{ result  = ?PlayerImportPassWord},
						player:send(Msg),
						throw(-1)
				end
		end,
		
		
		SpaceCell = getPlayerBagSpaceCell( ?Item_Location_Bag ),
		case SpaceCell >= 0 of
			false->throw(-1);
			true->ok
		end,
						 
		setPlayerBagCell( ItemDBData#r_itemDB.location, ItemDBData#r_itemDB.cell, 0, 0 ),
						 
		etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.location, ?Item_Location_Bag ),
		etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.cell, SpaceCell ),
						 
		setPlayerBagCell( ?Item_Location_Bag, SpaceCell, ItemDBData#r_itemDB.id, 0 ),
						 
		player:send( #pk_PlayerItemLocationCellChanged{ itemDBID=ItemDBData#r_itemDB.id, location=?Item_Location_Bag, cell=SpaceCell } ),

		ok
	catch
		_->ok
	end.

%%请求将主背包内某格子上物品移动到仓库
onMsgRequestMoveBagItemToStorage( Cell )->
	try
		ItemDBData = getItemDBDataByPlayerBagCell( ?Item_Location_Bag, Cell ),
		case ItemDBData of
			{}->throw(-1);
			_->ok
		end,
		
		case isLockedPlayerBagCell(?Item_Location_Bag, Cell) of
			true->throw(-1);
			false->ok
		end,
		
		SpaceCell = getPlayerBagSpaceCell( ?Item_Location_Storage ),
		case SpaceCell >= 0 of
			false->throw(-1);
			true->ok
		end,
						 
		setPlayerBagCell( ItemDBData#r_itemDB.location, ItemDBData#r_itemDB.cell, 0, 0 ),
						 
		etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.location, ?Item_Location_Storage ),
		etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.cell, SpaceCell ),
						 
		setPlayerBagCell( ?Item_Location_Storage, SpaceCell, ItemDBData#r_itemDB.id, 0 ),
						 
		player:send( #pk_PlayerItemLocationCellChanged{ itemDBID=ItemDBData#r_itemDB.id, location=?Item_Location_Storage, cell=SpaceCell } ),

		ok
	catch
		_->ok
	end.

%%拆分物品，返回成功，新物品的完整信息r_itemDB，失败{}
%%注意，一旦调用此函数，新物品已经生成，但是没有放在任何背包内，外部逻辑需要保证该物品放在正确位置
splitItem( ItemDBData, NewAmount )->
	try
		SetAmount = ItemDBData#r_itemDB.amount - NewAmount,
		case SetAmount =< 0 of
			true->throw(-1);
			false->ok
		end,
		
		etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.amount, SetAmount ),
		onPlayerItemAmountChanged( ItemDBData, NewAmount, ?Get_Item_Reson_Split ),
		sendToPlayer_ItemAmountChanged( itemModule:getItemDBDataByDBID( ItemDBData#r_itemDB.id ), ?Get_Item_Reson_Split ),
		
		NewItemDBData = itemModule:initItemDBData(),
		NewItemDBData2 = ItemDBData,
		NewItemDBData3 = setelement( #r_itemDB.amount, NewItemDBData2, NewAmount ),
		NewItemDBData4 = setelement( #r_itemDB.id, NewItemDBData3, NewItemDBData#r_itemDB.id ),
		NewItemDBData5 = setelement( #r_itemDB.location, NewItemDBData4, ?Item_Location_ErrorItem ),
		%itemModule:saveItemDB(NewItemDBData5),
		mySqlProcess:insertOrReplaceR_itemDB(NewItemDBData5,false),

		NewItemDBData5
	catch
		_->{}
	end.

%%玩家交易改变物品的位置(location,cell)，返回位置改变后的物品完整信息r_itemDB，不会失败
%%注意，一旦调用此函数，物品即从背包中移除，外部需保证保管好改物品实例
onTradeToChangeItemLocationCell( ItemDBData, NewLocation, NewCell, Reson )->
	setPlayerBagCell( ItemDBData#r_itemDB.location, ItemDBData#r_itemDB.cell, 0, getLockIDOfPlayerBag(ItemDBData#r_itemDB.location, ItemDBData#r_itemDB.cell) ),
						 
	etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.location, NewLocation ),
	etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.cell, NewCell ),
	ItemDBData2 = etsBaseFunc:readRecord( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id ),
	
	%%将物品从自己的ets表中删除，修复物品丢失的bug
	etsBaseFunc:deleteRecord(itemModule:getCurItemTable(), ItemDBData#r_itemDB.id),
	itemModule:saveItemDB( ItemDBData2 ),
	itemModule:onItemDBDeleted(ItemDBData2),
	player:send( #pk_PlayerDestroyItem{ itemDBID=ItemDBData2#r_itemDB.id, reson=Reson} ),
	ItemDBData2.

onSellItem( ItemDBData ) ->
	Cells = playerItems:getPlayerBagList(?Item_Location_BackBuy),
	Cells2 = lists:sort(fun(X,Y) -> 
								X#r_playerBag.cell < Y#r_playerBag.cell
						end, Cells),

	try
		FunFind = fun(Cell) ->
						  case Cell#r_playerBag.itemDBID of
							  0->
								  throw(Cell#r_playerBag.cell);
							  _->
								  ok
						  end
				  end,
		lists:foreach(FunFind, Cells2),
		case get("Next_Destory_Index_Because_Full") of
			undefined-> put("Next_Destory_Index_Because_Full",0);
			DestroyIndex->
				case (DestroyIndex < 0) or (DestroyIndex >= ?Max_BackBuy_Cells) of
					true -> put("Next_Destory_Index_Because_Full",0);
					false ->ok
				end
		end,					 		
		throw(-1)
	catch
		-1 ->
			WillDestroyIndex = get("Next_Destory_Index_Because_Full"),
			doneDestroyItemInBag(?Item_Location_BackBuy, WillDestroyIndex, ?Destroy_Item_Reson_BackBuyCellsFull),
			NextDestroyIndex = (WillDestroyIndex+1) rem ?Max_BackBuy_Cells,
			put("Next_Destory_Index_Because_Full",NextDestroyIndex),
			put(?ProcTempValue1, WillDestroyIndex);
		Index ->
			put(?ProcTempValue1, Index)
	end,
	setPlayerBagCell( ItemDBData#r_itemDB.location, ItemDBData#r_itemDB.cell, 0, getLockIDOfPlayerBag(ItemDBData#r_itemDB.location, ItemDBData#r_itemDB.cell) ),
	etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.location, ?Item_Location_BackBuy ),
	etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.binded, true ),
	etsBaseFunc:changeFiled( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id, #r_itemDB.cell, get(?ProcTempValue1) ),
	ItemDBData2 = etsBaseFunc:readRecord( itemModule:getCurItemTable(), ItemDBData#r_itemDB.id ),
	itemModule:saveItemDB( ItemDBData2 ),
	itemModule:onItemDBDeleted(ItemDBData2),
	setPlayerBagCell( ?Item_Location_BackBuy, get(?ProcTempValue1), ItemDBData#r_itemDB.id, 0 ),

	player:send( #pk_PlayerItemLocationCellChanged{ itemDBID=ItemDBData#r_itemDB.id, location=?Item_Location_BackBuy, cell= get(?ProcTempValue1) } ).

%%是否能够交易
canTrade(Item_Data_ID) ->
	case etsBaseFunc:readRecord(main:getGlobalItemCfgTable(), Item_Data_ID) of
		{}->false;
		ItemCfg->
			case ItemCfg#r_itemCfg.operate band ?ItemProtect_Cannot_Trade of
				0->true;
				_->false
			end
	end.

%%是否能够丢弃
canDiscard(Item_Data_ID) ->
	case etsBaseFunc:readRecord(main:getGlobalItemCfgTable(), Item_Data_ID) of
		{}->false;
		ItemCfg->
			case ItemCfg#r_itemCfg.operate band ?ItemProtect_Cannot_Discard of
				0->true;
				_->false
			end
	end.

%%是否能够邮寄
canMail(Item_Data_ID) ->
	case etsBaseFunc:readRecord(main:getGlobalItemCfgTable(), Item_Data_ID) of
		{}->false;
		ItemCfg->
			case ItemCfg#r_itemCfg.operate band ?ItemProtect_Cannot_Mail of
				0->true;
				_->false
			end
	end.

%%是否能够拍卖
canSale(Item_Data_ID) ->
	case etsBaseFunc:readRecord(main:getGlobalItemCfgTable(), Item_Data_ID) of
		{}->false;
		ItemCfg->
			case ItemCfg#r_itemCfg.operate band ?ItemProtect_Cannot_Sale of
				0->true;
				_->false
			end
	end.

%%是否能够出售
canSell(Item_Data_ID) ->
	case etsBaseFunc:readRecord(main:getGlobalItemCfgTable(), Item_Data_ID) of
		{}->false;
		ItemCfg->
			case ItemCfg#r_itemCfg.operate band ?ItemProtect_Cannot_Sell of
				0->true;
				_->false
			end
	end.
