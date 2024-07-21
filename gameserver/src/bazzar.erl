%% Author: yqf
%% Created: 2013-3-19
-module(bazzar).

%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% Include files
%%
-include("db.hrl").
-include("hdlt_logger.hrl").
-include("condition_compile.hrl").
-include("bazzar.hrl").
-include("itemDefine.hrl").
-include("playerDefine.hrl").
-include("package.hrl").
-include("logdb.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("variant.hrl").


start_link() ->
	?DEBUG_OUT("bazzar thread begin"),
	gen_server:start_link({local,bazzarPid},?MODULE, [], [{timeout,?Start_Link_TimeOut_ms}]).



init([]) ->
	%%读取商城数据
	BazzarItemList = mySqlProcess:get_AllBazzarItem(),
	
	ItemTable = ets:new(bazzarItemTable, [private, { keypos, #bazzarItem.db_id }]),
	put( "BazzarItemTable",  ItemTable ),
	
	%%读取配置文件
	case db:openBinData( "bazzar.bin" ) of
		[] ->
			?ERROR_OUT( "bazzar openBinDatabazzar.bin false []" );
		ItemCfgDataList ->
			db:loadBinData(ItemCfgDataList, bazzarItemCfg),
			
			ItemCfgList = db:matchObject(bazzarItemCfg,  #bazzarItemCfg{_='_'} ),
			CfgTable = ets:new(bazzarItemCfgTable, [private, named_table,{ keypos, #bazzarItemCfg.item_data_id }]),
			FunCfg = fun( Cfg )->
							 etsBaseFunc:insertRecord( CfgTable, Cfg )
					 end,
			lists:foreach(FunCfg, ItemCfgList)
	end,
			
	case BazzarItemList of
		[]->		%%数据库中没有商城数据，更新一次商城数据
			updateBazzarData();
		_->		%%数据库中有商城数据，读取商城的数据
			FunItem = fun( Record )->
							   etsBaseFunc:insertRecord(ItemTable, Record)
					  end,
			lists:foreach(FunItem, BazzarItemList)
	end,
	
	%%判断是否需要初始化刷新时间
	case variant:getWorldVarValue(?WorldVariant_Index_2_BazzarUpdateTime) of
		0->
			initBazzarUpdateTime();
		undefined->
			initBazzarUpdateTime();
		_->ok
	end,
	
	{S1,S2,S3} = erlang:now(),
	random:seed(S1, S2, S3),
	%%先检查一次刷新时间
	checkUpdateTime(),
			
	put( "BazzarSeed", 1 ),
	
    {ok, {}}.

getItemTable() ->
	case get("BazzarItemTable") of
		undefined->0;
		Table->Table
	end.

getItemCfgTable()->
	bazzarItemCfgTable.


%%初始为中午12点
initBazzarUpdateTime()->
	variant:setWorldVarValue(?WorldVariant_Index_2_BazzarUpdateTime, common:getTodayBeginSeconds()+12*60*60).

%%检查刷新时间
checkUpdateTime()->
	erlang:send_after(?Bazzar_CheckUpdateTime,self(), {checkUpdate}),
	Now = common:getNowSeconds(),
	UpdateTime = variant:getWorldVarValue(?WorldVariant_Index_2_BazzarUpdateTime),
	case Now >= UpdateTime of
		true->
			updateBazzarData(),
			variant:setWorldVarValue(?WorldVariant_Index_2_BazzarUpdateTime, 
									 globalSetup:getGlobalSetupValue(#globalSetup.bazzar_UpdateTime)+common:getTodayBeginSeconds()+12*60*60),
			ok;
		_->ok
	end,
	ok.

%%刷新商城数据
updateBazzarData()->
	put( "ID_Counter", 0),
	ets:delete_all_objects( getItemTable()),
	Now = common:timestamp(),
	FunItem = fun( Record )-> 
					  case Record#bazzarItemCfg.remain_time =< 0 of
						  true->EndTime = -1;
						  _->EndTime = Record#bazzarItemCfg.remain_time+Now
					  end,
					  Record2 = #bazzarItem{
													   db_id = get("ID_Counter")+1,
													   item_data_id = Record#bazzarItemCfg.item_data_id,
													   item_column = Record#bazzarItemCfg.item_column,
													   gold = Record#bazzarItemCfg.gold,
													   binded_gold = Record#bazzarItemCfg.binded_gold,
													   init_count = Record#bazzarItemCfg.remain_count,
													   remain_count = Record#bazzarItemCfg.remain_count,
													   end_time =  EndTime
													   },
					  put("ID_Counter", get("ID_Counter")+1),
					  
					  case Record2#bazzarItem.item_column of
						  ?BazzarColumn_RandomPrice->
							  ok;
						  _->
							  etsBaseFunc:insertRecord(getItemTable(), Record2),
							  %%存档
							  mySqlProcess:replaceBazzarItem(Record2)
					  end
			  end,
	etsBaseFunc:etsFor(getItemCfgTable(), FunItem),
	
	Q = ets:fun2ms( fun(Record) when ( (Record#bazzarItemCfg.item_column =:= ?BazzarColumn_RandomPrice)) ->Record end ),
	RandomList = ets:select(getItemCfgTable(), Q),
	RandPriceList = randomPriceList(RandomList, globalSetup:getGlobalSetupValue(#globalSetup.bazzar_RandomPrice_Count)),
	FunRand = fun( Record )->
					  case Record#bazzarItemCfg.remain_time =< 0 of
						  true->EndTime = -1;
						  _->EndTime = Record#bazzarItemCfg.remain_time+Now
					  end,
					  Record2 = #bazzarItem{
													   db_id = get("ID_Counter")+1,
													   item_data_id = Record#bazzarItemCfg.item_data_id,
													   item_column = Record#bazzarItemCfg.item_column,
													   gold = Record#bazzarItemCfg.gold,
													   binded_gold = Record#bazzarItemCfg.binded_gold,
													   init_count = Record#bazzarItemCfg.remain_count,
													   remain_count = Record#bazzarItemCfg.remain_count,
													   end_time =  EndTime
													   },
					  put("ID_Counter", get("ID_Counter")+1),
					  etsBaseFunc:insertRecord(getItemTable(), Record2),
					  %%存档
					  mySqlProcess:replaceBazzarItem(Record2)
			  end,
	lists:foreach(FunRand, RandPriceList).

randomPriceList( RandomList, Count )->
	case Count =< 0 of
		true->[];
		_->
			put( "Weight", 0 ),
			Fun = fun( ItemCfg )->
						  put( "Weight", get("Weight")+ItemCfg#bazzarItemCfg.weight )
				  end,
			lists:foreach(Fun, RandomList),
			
			Max = get("Weight"),
			
			case Max > 0 of
				true->
					Value = random:uniform( Max ),
					put( "tempWeight", 0 ),
					try
						FunWeight = fun( Item )->
											NonceWeight = get( "tempWeight" )+Item#bazzarItemCfg.weight,
											case (Value =< NonceWeight) andalso  (Value>get( "tempWeight" )) of
												true->throw(Item);
												_->put( "tempWeight", NonceWeight )
											end
									end,
						lists:foreach(FunWeight, RandomList),
						[]
					catch
						ThrowItem->
							[ThrowItem] ++ randomPriceList( RandomList--[ThrowItem], Count-1 )
					end;
				_->
					[]
			end
	end.


loadBazzarItemListFrom_DB()->
	ItemTable = getItemTable(),
	ets:delete_all_objects(ItemTable),
	
	%%读取商城数据
	BazzarItemList = mySqlProcess:get_AllBazzarItem(),
	FunItem = fun( Record )->
					  etsBaseFunc:insertRecord(ItemTable, Record)
			  end,
	lists:foreach(FunItem, BazzarItemList),
	put( "BazzarSeed", get("BazzarSeed")+1 ),
	ok.


handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.



terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

getPid() -> 
	bazzarPid.


%%
%% API Functions
%%
handle_info(Info, StateData)->			
	put("BazzarRecieve", true),

	try
	case Info of
		{quit}->
			?LOG_OUT( "Bazzar Recieve quit" ),
			put( "BazzarRecieve", false );
		{ reloadDBItem }->
			loadBazzarItemListFrom_DB();
		{ buyAsk, PID, ItemDBID, ItemCount, IsBindGold }->
			onPlayerMsgBuyAsk( PID, ItemDBID, ItemCount, IsBindGold );
		{ buyResult, PlayerID, IsSucc, ItemDBID, ItemCount, IsBindGold }->
			onPlayerMsgBuyResult( PlayerID, IsSucc, ItemDBID, ItemCount, IsBindGold );
		{ itemRequest, PlayerID, PID, Seed }->
			onPlayerMsgItemListRequest( PlayerID, PID, Seed );
		{ requestBazzarItemPrice, PlayerPID, ItemID }->
			onPlayerMsgRequestBazzarItemPrice( PlayerPID, ItemID );
		{ checkUpdate}->
			checkUpdateTime();
		
		
		_->ok
	end,
	case get("BazzarRecieve") of
		true->{noreply, StateData};
		false->{stop, normal, StateData}
	end

	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[?MODULE,_Why, erlang:get_stacktrace()] ),	

			{noreply, StateData}
	end.

%%商城进程，处理玩家请求物品价格
onPlayerMsgRequestBazzarItemPrice( PlayerPID, ItemID )->
	Q = ets:fun2ms( fun(Record) when (Record#bazzarItem.item_data_id =:= ItemID) ->Record end ),
	ItemList = ets:select(getItemTable(), Q),
	case ItemList of
		[]->
			Msg = #pk_U2GS_RequestBazzarItemPrice_Result{ item=[] };
		[Item|_]->
			Now = common:timestamp(),
			Msg = #pk_U2GS_RequestBazzarItemPrice_Result{ item = [						  
																  #pk_BazzarItem{
																				 db_id = Item#bazzarItem.db_id,
																				 item_id = Item#bazzarItem.item_data_id,
																				 item_column = Item#bazzarItem.item_column,
																				 gold = Item#bazzarItem.gold,
																				 binded_gold = Item#bazzarItem.binded_gold,
																				 remain_count = Item#bazzarItem.remain_count,
																				 remain_time = Item#bazzarItem.end_time-Now
																				}] }
	end,
	
	player:sendToPlayerByPID(PlayerPID, Msg),
	ok.

%%商城进程，处理玩家申请物品列表请求
onPlayerMsgItemListRequest( PlayerID, _PID, Seed )->
	case Seed =:= get("BazzarSeed") of
		true->
			Q = ets:fun2ms( fun(Record) when ((Record#bazzarItem.item_column =:= ?BazzarColumn_Favorable_Price) orelse 
												  (Record#bazzarItem.item_column =:= ?BazzarColumn_RandomPrice)) ->Record end ),
			ItemList = ets:select(getItemTable(), Q),
			Now = common:timestamp(),
			Fun = fun( R )->
						  case R#bazzarItem.end_time =< 0 of
							  true->Remain_time = -1; 
							  _->Remain_time = R#bazzarItem.end_time-Now
						  end,
						  #pk_BazzarItem{
										 db_id = R#bazzarItem.db_id,
										 item_id = R#bazzarItem.item_data_id,
										 item_column = R#bazzarItem.item_column,
										 gold = R#bazzarItem.gold,
										 binded_gold = R#bazzarItem.binded_gold,
										 remain_count = R#bazzarItem.remain_count,
										 remain_time = Remain_time
										 }
				  end,
			Msg = #pk_BazzarPriceItemList{ itemList=lists:map(Fun, ItemList)},
			player:sendToPlayer(PlayerID, Msg),


			ok;
		
		_->
			Q = ets:fun2ms( fun(Record) ->Record end ),
			ItemList = ets:select(getItemTable(), Q),
			Now = common:timestamp(),
			Fun = fun( R )->
						  #pk_BazzarItem{
										 db_id = R#bazzarItem.db_id,
										 item_id = R#bazzarItem.item_data_id,
										 item_column = R#bazzarItem.item_column,
										 gold = R#bazzarItem.gold,
										 binded_gold = R#bazzarItem.binded_gold,
										 remain_count = R#bazzarItem.remain_count,
										 remain_time = R#bazzarItem.end_time-Now
										 }
				  end,
			Msg = #pk_BazzarItemList{ seed=get("BazzarSeed"), itemList=lists:map(Fun, ItemList)},
			player:sendToPlayer(PlayerID, Msg)
	end.

%%商城进程，处理玩家购买请求
onPlayerMsgBuyAsk( PID, ItemID, ItemCount, IsBindGold )->
	try
		case ItemCount =< 0 of
			true->throw(-1);
			_->
				ok
		end,
		Item = etsBaseFunc:readRecord(getItemTable(), ItemID),
		case Item of
			{}->throw( {?Bazzar_Buy_Return_NotItem, 0}  );
			_->ok
		end,
		
		case etsBaseFunc:readRecord(main:getGlobalItemCfgTable(), Item#bazzarItem.item_data_id) of
			{}->throw( { ?Bazzar_Buy_Return_ItemMax, 0});
			ItemCfg->
				case ItemCount > ItemCfg#r_itemCfg.maxAmount of
					true->throw( { ?Bazzar_Buy_Return_ItemMax, 0});%%超过物品堆叠数量
					_->ok
				end
		end,
		
		%%元宝卡不能通过绑定元宝购买
		case Item#bazzarItem.item_column of
			?BazzarColumn_YuanBaoKa->
				case IsBindGold of
					true->throw( {?Bazzar_Buy_Return_NotBindGold, 0} );
					_->ok
				end;
			_->ok
		end,
		
		%%优惠道具不能通过绑定元宝购买
		case (Item#bazzarItem.item_column =:= ?BazzarColumn_Favorable_Price) orelse 
				 (Item#bazzarItem.item_column =:= ?BazzarColumn_RandomPrice) of
			true->
				case IsBindGold of
					true->throw( {?Bazzar_Buy_Return_NotBindGold, 0} );
					_->ok
				end,
				
				Now = common:timestamp(),
				case Item#bazzarItem.end_time /=-1 andalso Item#bazzarItem.end_time < Now of
					true->throw( {?Bazzar_Buy_Return_TimeOut, 0} );
					_->ok
				end,
				
				case Item#bazzarItem.remain_count /= -1 andalso Item#bazzarItem.remain_count < ItemCount of
					true->throw( { ?Bazzar_Buy_Return_NotEnough, 0} );
					_->ok
				end,
				ok;
			_->ok
		end,
		
		throw( {?Bazzar_Buy_Return_Succ, Item} )
	catch
		{ReturnValue, ReturnItem}->
				PID ! { buyAskResult, ReturnValue, ReturnItem, ItemCount, IsBindGold}
end.

%%商城进程，处理玩家购买返回
onPlayerMsgBuyResult( PlayerID, IsSucc, ItemDBID, ItemCount, IsBindGold )->
	try
		case IsSucc of
			true->ok;
			_->throw(-1)
		end,
		
		Item = etsBaseFunc:readRecord(getItemTable(), ItemDBID),
		case Item of
			{}->throw( -1 );
			_->ok
		end,
		
		case (Item#bazzarItem.item_column=:=?BazzarColumn_Favorable_Price) orelse
				 (Item#bazzarItem.item_column=:=?BazzarColumn_RandomPrice)  of
			true->
				case Item#bazzarItem.remain_count /= -1 of
					true->
						%%写入最新数量到数据库
						mySqlProcess:reduceRemainCountForBazzarItem(ItemDBID, ItemCount),
						etsBaseFunc:changeFiled(getItemTable(), ItemDBID, #bazzarItem.remain_count, Item#bazzarItem.remain_count-ItemCount);
					_->ok
				end;
			_->ok
		end,
		
		case IsBindGold of
			true-> UseGold = ItemCount*Item#bazzarItem.binded_gold;
			_->UseGold = ItemCount*Item#bazzarItem.gold
		end,
		
		?LOG_OUT("【Bazzar】Player [~p] Buy Item [~p] * [~p], Use Gold [~p]]", 
				   [PlayerID, Item#bazzarItem.item_data_id, ItemCount, UseGold] )
		
	catch
		_->ok
end.

%%玩家进程，处理玩家申请商城物品列表消息
onNetMsgRequestItemList( Seed )->
	getPid() ! { itemRequest, player:getCurPlayerID(), self(), Seed }.

%%玩家进程，处理购买消息
onNetMsgBuyItemFromBazzar( ItemDBID, Count, IsBindGold )->
	case IsBindGold of
		0->Bind = false;
		_->Bind = true
	end,
	
	getPid() ! { buyAsk, self(), ItemDBID, Count, Bind},
	ok.

%%玩家进程，处理商城返回
onBazzarMsgBuyAskResult( ReturnValue, ReturnItem, ItemCount, IsBindGold ) ->
	try
		case ReturnValue of
			?Bazzar_Buy_Return_Succ->
				ok;
			_->throw( ReturnValue )
		end,
		
		case playerItems:getPlayerBagSpaceCellCount(?Item_Location_Bag) > 0  of
			true->ok;
			_->throw( ?Bazzar_Buy_Return_BagFull )
		end,
		case playerItems:onPlayerReturnGoldPassWord() of
			true->
				ok;
			false->throw( ?Bazzar_Buy_Return_GoldPassWord )
		end,	
			
		case IsBindGold of
			true->
				UseGold = ReturnItem#bazzarItem.binded_gold * ItemCount,
				case playerMoney:canDecPlayerBindedGold(UseGold) of
					true->
						ParamTuple = #token_param{	changetype = ?Money_Change_BazzarBuy,
												  	param1=ReturnItem#bazzarItem.item_data_id,
												  	param2=ReturnItem#bazzarItem.item_column},
						playerMoney:decPlayerBindedGold(UseGold, ?Money_Change_BazzarBuy, ParamTuple);
					_->
						throw( ?Bazzar_Buy_Return_BindGold_NotEnough )
				end;
			_->
				UseGold = ReturnItem#bazzarItem.gold * ItemCount,
				case playerMoney:canDecPlayerGold(UseGold) of
					true->
						ParamTuple = #token_param{changetype = ?Money_Change_BazzarBuy,
												  param1=ReturnItem#bazzarItem.item_data_id,
												  param2=ReturnItem#bazzarItem.item_column},
						playerMoney:decPlayerGold(UseGold, ?Money_Change_BazzarBuy, ParamTuple);
					_->
						throw( ?Bazzar_Buy_Return_Gold_NotEnough )
				end
		end,
		
		%%绑定元宝购买的物品绑定，元宝购买的物品不绑定
		playerItems:addItemToPlayerByItemDataID(
		  ReturnItem#bazzarItem.item_data_id, 
		  ItemCount, 
		  IsBindGold, 
		  ?Get_Item_Reson_BazzarBuy),
		
		throw( ?Bazzar_Buy_Return_Succ )
	
	catch
		Value->
			case Value of
				?Bazzar_Buy_Return_Succ->
					IsSucc=true,
					OrderID = ReturnItem#bazzarItem.db_id;
				_->
					IsSucc=false,
					OrderID = 0
			end,
			%%发送购买返回给商城进程
			getPid() ! { buyResult, player:getCurPlayerID(), IsSucc, OrderID, ItemCount, IsBindGold }, 


			Msg = #pk_BazzarBuyResult{result=Value},
			player:send(Msg)
end.