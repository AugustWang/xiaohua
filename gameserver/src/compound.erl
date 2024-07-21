-module(compound).

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

-define(CompoundItem, 0). %非绑定
-define(CompoundBindedItem, 1). %绑定

%%错误码
-define(Msg_Not_Find_Rune, 1). %%无双倍符
-define(Msg_Level_Lack, 2). %%等级不够
-define(Msg_Money_Lack, 3). %%铜币不够
-define(Msg_Honor_Lack, 4). %%荣誉不够
-define(Msg_Credit_Lack, 5). %%声望不够
-define(Msg_Item_Lack, 6). %%物品不够
-define(Msg_Bag_Space_Lack, 7). %%背包空间不足

%%
%% Exported Functions
%%
-compile(export_all).

initPlayerOnLine() ->
	try
		PlayerVarArray = player:getCurPlayerProperty(#player.varArray),
		CurExp = variant:getPlayerVarValue(PlayerVarArray, ?PlayerVariant_Index12_Compound_Exp_P),
		case CurExp of
			undefined -> variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index12_Compound_Exp_P, 0);
			_ -> ok
		end,
		PlayerVarArray1 = player:getCurPlayerProperty(#player.varArray),
		CurLevel = variant:getPlayerVarValue(PlayerVarArray1, ?PlayerVariant_Index12_Compound_Level_P),
		case CurLevel of
			undefined -> variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index12_Compound_Level_P, 1);
			_ -> ok
		end
	catch
		_ -> ok
	end.

startCompound(#pk_StartCompound{makeItemID = MakeItemID, compounBindedType = CompounBindedType, isUseDoubleRule = IsUseDoubleRule}) ->
	try
		Player = player:getCurPlayerRecord(),
		CompoundList = getItemBySelectType(MakeItemID),
		case CompoundList of
			{} ->
				?DEBUG_OUT( "not Find Compound Item [MakeItemID]: ~p", [MakeItemID]),
				throw(-1);
			_ ->				
				%%判断等级
				CurCompoundLevel = getCompundCurLevel(),				
				case CompoundList#compoundCfg.mixLevel > 0 of
					true ->
						case CurCompoundLevel >= CompoundList#compoundCfg.mixLevel of
							true -> ok;
							false ->
								?DEBUG_OUT( "level is lack CurLevel: ~p, NeedLevel : ~p", [CurCompoundLevel, CompoundList#compoundCfg.mixLevel]),
								LevelResult = #pk_StartCompoundResult{retCode = ?Msg_Level_Lack},
								player:send(LevelResult),								
								throw(-1)
						end;
					false -> ok
				end,
				
				%%判断荣誉
				case CompoundList#compoundCfg.mixHonour > 0 of
					true ->
						case Player#player.honor >= CompoundList#compoundCfg.mixHonour of
							true -> ok;
							false ->
								?DEBUG_OUT( "honor is lack CurHonor: ~p, NeedHonor: ~p", [Player#player.honor, CompoundList#compoundCfg.mixHonour]),
								HonorResult = #pk_StartCompoundResult{retCode = ?Msg_Honor_Lack},
								player:send(HonorResult),								
								throw(-1)
						end;
					false -> ok
				end,	
				
				%%判断声望
				case CompoundList#compoundCfg.mixCredit > 0 of
					true ->
						case Player#player.credit >= CompoundList#compoundCfg.mixCredit of
							true -> ok;
							false ->
								?DEBUG_OUT( "credit is lack CurCredit: ~p NeedCredit: ~p", [Player#player.credit, CompoundList#compoundCfg.mixCredit]),
								CreditResult = #pk_StartCompoundResult{retCode = ?Msg_Credit_Lack},
								player:send(CreditResult),								
								throw(-1)
						end;
					false -> ok
				end,
				
				%%判断金钱
				case CompoundList#compoundCfg.mixMoney > 0 of
					true ->
						case Player#player.money >= CompoundList#compoundCfg.mixMoney of
							true -> ok;
							false ->
								?DEBUG_OUT( "money is lack CurMoney: ~p NeedMoney: ~p", [Player#player.money, CompoundList#compoundCfg.mixMoney]),
								MoneyResult = #pk_StartCompoundResult{retCode = ?Msg_Money_Lack},
								player:send(MoneyResult),								
								throw(-1)
						end;
					false -> ok
				end,

				%%判断背包格子数
				case playerItems:getPlayerBagSpaceCellCount(?Item_Location_Bag) =< 0 of
					true ->
						?DEBUG_OUT( "bag Space is lack"),
						BagSpaceLackResult = #pk_StartCompoundResult{retCode = ?Msg_Bag_Space_Lack},
						player:send(BagSpaceLackResult),							
						throw(-1);
					false -> ok
				end,
				
				%%判断物品
				MixMaterial1ID = CompoundList#compoundCfg.mixMaterial1ID,
				Material1Amount = CompoundList#compoundCfg.material1Amount,
				MixMaterial2ID = CompoundList#compoundCfg.mixMaterial2ID,
				Material2Amount = CompoundList#compoundCfg.material2Amount,
				MixMaterial3ID = CompoundList#compoundCfg.mixMaterial3ID,
				Material3Amount = CompoundList#compoundCfg.material3Amount,
				
				case (MixMaterial1ID > 0) andalso (Material1Amount > 0) of
					true ->
						case canDeleteItem(MixMaterial1ID, Material1Amount, CompounBindedType) of
							true -> ok;
							false ->
								?DEBUG_OUT( "item is lack"),
								ItemResult1 = #pk_StartCompoundResult{retCode = ?Msg_Item_Lack},
								player:send(ItemResult1),								
								throw(-1)
						end;
					false -> ok
				end,

				case (MixMaterial2ID > 0) andalso (Material2Amount > 0) of
					true ->
						case canDeleteItem(MixMaterial2ID, Material2Amount, CompounBindedType) of
							true -> ok;
							false ->
								?DEBUG_OUT( "item is lack"),
								ItemResult2 = #pk_StartCompoundResult{retCode = ?Msg_Item_Lack},
								player:send(ItemResult2),								
								throw(-1)
						end;
					false -> ok
				end,
				
				case (MixMaterial3ID > 0) andalso (Material3Amount > 0) of
					true ->
						case canDeleteItem(MixMaterial3ID, Material3Amount, CompounBindedType) of
							true -> ok;
							false ->
								?DEBUG_OUT( "item is lack"),
								ItemResult3 = #pk_StartCompoundResult{retCode = ?Msg_Item_Lack},
								player:send(ItemResult3),								
								throw(-1)
						end;
					false -> ok
				end,
				
				%%扣除消耗
				case IsUseDoubleRule > 0 of %%双倍符(针对生成合成的物品)
					true ->
						case deleteRune(CompoundList#compoundCfg.runeID, 1) of
							true -> ok;
							false ->
								?DEBUG_OUT( "nof Find Double Item"),
								Result = #pk_StartCompoundResult{retCode = ?Msg_Not_Find_Rune},
								player:send(Result),								
								throw(-1)
						end;
					false -> ok
				end,
				ParamTuple = #token_param{changetype = ?Gold_Change_Convoy},
				playerMoney:decPlayerMoneyAndBindMoney(CompoundList#compoundCfg.mixMoney, ?Money_Change_Compound, ParamTuple),
				deleteItem(MixMaterial1ID, Material1Amount, CompounBindedType),
				deleteItem(MixMaterial2ID, Material2Amount, CompounBindedType),
				deleteItem(MixMaterial3ID, Material3Amount, CompounBindedType),
				updateHonor(Player#player.honor-CompoundList#compoundCfg.mixHonour),
				updateCredit(Player#player.credit-CompoundList#compoundCfg.mixCredit),				
				
				%%生成物个数
				case IsUseDoubleRule > 0 of %%使用双倍符，直接生成最大个数
					true -> MakeItemAmount = CompoundList#compoundCfg.maxAmount;
					false -> MakeItemAmount = makeCompoundItemAmount(CompoundList#compoundCfg.minAmount, CompoundList#compoundCfg.maxAmount)
				end,
				%%生成物品
				?DEBUG_OUT( "Compound makeItemAmount : ~p", [MakeItemAmount]),
				makeItemByID(CompoundList#compoundCfg.makeItemID, MakeItemAmount, getMakeItemBindedType(CompounBindedType)),
				%%等级和经验奖励
				CfgExp = getExpByLevel(CurCompoundLevel),
				CurCompoundExp = getCompundCurExp()+CompoundList#compoundCfg.mixExp,
				case (CurCompoundExp >= CfgExp) andalso (CfgExp > 0) of
					true ->
						CompoundLevelValue = CurCompoundLevel+1,
						CompoundExperienceValue = 0,
						variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index12_Compound_Level_P, CompoundLevelValue),
						variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index12_Compound_Exp_P, CompoundExperienceValue);
					false ->
						CompoundLevelValue = CurCompoundLevel,
						case CfgExp =:= 0 of
							true -> CompoundExperienceValue1 = 0;
							false -> CompoundExperienceValue1 = CurCompoundExp
						end,
						CompoundExperienceValue = CompoundExperienceValue1,						
						variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index12_Compound_Level_P, CompoundLevelValue),
						variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index12_Compound_Exp_P, CompoundExperienceValue)
				end,
				%%发送成功消息
				?DEBUG_OUT( "Compound Succ"),
				CompoundResult = #pk_CompoundBaseInfo{exp = CompoundExperienceValue, level = CompoundLevelValue, makeItemID = CompoundList#compoundCfg.makeItemID},
				player:send(CompoundResult)					
		end
	catch
		_ -> ok
	end.

%%获取当前经验
getCompundCurExp() ->
	try
		PlayerVarArray1 = player:getCurPlayerProperty(#player.varArray),
		CurExp = variant:getPlayerVarValue(PlayerVarArray1, ?PlayerVariant_Index12_Compound_Exp_P),
		case CurExp of
			undefined -> 0;
			_ -> CurExp
		end
	catch
		_ -> 0
	end.

%%获取当前等级
getCompundCurLevel() ->
	try
		PlayerVarArray1 = player:getCurPlayerProperty(#player.varArray),
		CurLevel = variant:getPlayerVarValue(PlayerVarArray1, ?PlayerVariant_Index12_Compound_Level_P),
		case CurLevel of
			undefined -> 1;
			_ -> CurLevel
		end
	catch
		_ -> 1
	end.

%%降低荣誉
updateHonor(Value) ->
	player:setCurPlayerProperty(#player.honor, Value),
	SendMsg = #pk_PlayerPropertyChanged{changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_honor, value=Value}]},
	player:send( SendMsg ).	

%%降低声望
updateCredit(Value) ->
	player:setCurPlayerProperty(#player.credit, Value),
	SendMsg = #pk_PlayerPropertyChanged{changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_credit, value=Value}]},
	player:send( SendMsg ).		
	
%%生成物品
makeItemByID(ItemID, Amount, IsBinded) ->
	playerItems:addItemToPlayerByItemDataID(ItemID, Amount, IsBinded, ?Get_Item_Reson_Compound).

%% 得到合成数个数
makeCompoundItemAmount(MinAmount, MaxAmount) ->
	MakeItemAmount = random:uniform(MaxAmount),
	case MakeItemAmount < MinAmount of
		true -> MakeItemAmountValue = MinAmount;
		false -> MakeItemAmountValue = MakeItemAmount
	end,
	MakeItemAmountValue.

%%得到生成物品类型(绑定，非绑定)
getMakeItemBindedType(CompounBindedType) ->
	case CompounBindedType of
		?CompoundItem -> false;
		?CompoundBindedItem -> true
	end.

%% 从背包中删除双倍符
deleteRune(ItemID, ItemCnt) ->
	try
		[CanDec|CanDecItemInBagResult] = playerItems:canDecItemInBag(?Item_Location_Bag, ItemID, ItemCnt, "all" ),
		case CanDec of
			true ->
				playerItems:decItemInBag(CanDecItemInBagResult, ?Destroy_Item_Reson_CommitTask);
			false -> throw(-1)
		end,
		true
	catch
		_ -> false
	end.

%% 能否从背包中删除合成所需的物品
canDeleteItem(ItemID, ItemCnt, CostItemType) ->
	try
		case ItemCnt > 0 of
			true -> 
				case CostItemType of
					?CompoundItem ->
						[CanDec|_CanDecItemInBagResult] = playerItems:canDecItemInBag(?Item_Location_Bag, ItemID, ItemCnt, false),
						put("CanDec", CanDec);			
					?CompoundBindedItem ->
						[CanDec|_CanDecItemInBagResult] = playerItems:canDecItemInBag(?Item_Location_Bag, ItemID, ItemCnt, "all" ),
						put("CanDec", CanDec);			
					_ -> throw(-1)
				end,
				case get("CanDec") of
					true -> ok;
					false -> throw(-1)
				end;
			false -> true
		end,
		true
	catch
		_ -> false
	end.	

%% 从背包中删除合成所需的物品
deleteItem(ItemID, ItemCnt, CostItemType) ->
	try
		case ItemCnt > 0 of
			true -> 
				case CostItemType of
					?CompoundItem -> %%只扣除非绑定物品
						[CanDec|CanDecItemInBagResult] = playerItems:canDecItemInBag(?Item_Location_Bag, ItemID, ItemCnt, false),
						case CanDec of
							true ->
								playerItems:decItemInBag(CanDecItemInBagResult, ?Destroy_Item_Reson_CommitTask);
							false -> throw(-1)
						end;			
					?CompoundBindedItem -> %%先扣除绑定物品(不够时再扣除非绑定物品)
						BindedItemAmount = playerItems:getItemCountByItemData(?Item_Location_Bag, ItemID, true),
						CommonItemAmount = playerItems:getItemCountByItemData(?Item_Location_Bag, ItemID, false),
						case BindedItemAmount >= ItemCnt of %%直接扣除绑定物品(绑定物品足够)
							true ->
								[CanDec|CanDecItemInBagResult] = playerItems:canDecItemInBag(?Item_Location_Bag, ItemID, ItemCnt, true),
								case CanDec of
									true ->
										playerItems:decItemInBag(CanDecItemInBagResult, ?Destroy_Item_Reson_CommitTask);
									false -> throw(-1)
								end;
							false -> %%绑定物品不够
								case BindedItemAmount+CommonItemAmount >= ItemCnt of %%先扣除绑定物品
									true ->
										[BindedCanDec|CanDecBindedItemInBagResult] = playerItems:canDecItemInBag(?Item_Location_Bag, ItemID, BindedItemAmount, true),
										case BindedCanDec of
											true ->
												playerItems:decItemInBag(CanDecBindedItemInBagResult, ?Destroy_Item_Reson_CommitTask),
												RemainItemAmount = ItemCnt-BindedItemAmount, %%再扣除非绑定物品
												[CanDec|CanDecItemInBagResult] = playerItems:canDecItemInBag(?Item_Location_Bag, ItemID, RemainItemAmount, false),
												case CanDec of
													true -> playerItems:decItemInBag(CanDecItemInBagResult, ?Destroy_Item_Reson_CommitTask);
													false -> throw(-1)
												end;
											false -> throw(-1)
										end;
									false -> throw(-1)
								end		
						end;
					_ -> throw(-1)
				end;
			false -> true
		end,
		true
	catch
		_ -> false
	end.
	

%% 根据指定类型取得指定合成项
getItemBySelectType(MakeItemID)->
	try
		Q = ets:fun2ms( fun(Record) 
							 when (Record#compoundCfg.makeItemID =:= MakeItemID) ->Record end ),
		Result = ets:select(compoundCfgTableAtom, Q),
		case Result of
		[]-> {};
		_ ->
			[X|_] = Result,
			X
		end
	catch
		_ -> {}
	end.

%% 根据等级取得所需熟练度
getExpByLevel(Level)->
	try
		Q = ets:fun2ms( fun(Record) 
							 when ( Record#compoundLevelCfg.level =:= Level ) ->Record end ),
		Result = ets:select(compoundLevelCfgTableAtom, Q),
		case Result of
		[]-> 0;
		_ ->
			[X|_] = Result,
			X#compoundLevelCfg.exp
		end
	catch
		_ -> 0
	end.

loadCompoundCfg() ->
	try
		case db:openBinData( "compound.bin" ) of
			[] ->
				?ERROR_OUT( "loadCompoundCfg openBinData compound.bin failed!" );
			CompoundCfgData ->
				db:loadBinData(CompoundCfgData, compoundCfg),
				ets:new( compoundCfgTableAtom, [set,protected,named_table, { keypos, #compoundCfg.id }] ),
				CompoundCfgDataList = db:matchObject(compoundCfg, #compoundCfg{_='_'} ),
				
				CompoundFun = fun( Record ) ->
							etsBaseFunc:insertRecord(compoundCfgTableAtom, Record)
					  end,
				lists:foreach(CompoundFun, CompoundCfgDataList),
				?DEBUG_OUT( "compoundCfgTable load succ" )
		end,
		
		case db:openBinData( "compoundLevel.bin" ) of
			[] ->
				?ERROR_OUT( "loadCompoundLevelCfg openBinData compoundLevel.bin failed!" );
			CompoundLevelCfgData ->
				db:loadBinData(CompoundLevelCfgData, compoundLevelCfg),
				ets:new( compoundLevelCfgTableAtom, [set,protected,named_table, { keypos, #compoundLevelCfg.id }] ),
				CompoundLevelCfgDataList = db:matchObject(compoundLevelCfg, #compoundLevelCfg{_='_'} ),
				
				CompoundLevelFun = fun( Record ) ->
							etsBaseFunc:insertRecord(compoundLevelCfgTableAtom, Record)
					  end,
				lists:foreach(CompoundLevelFun, CompoundLevelCfgDataList),
				?DEBUG_OUT( "compoundLevelCfgTable load succ" )
		end		
	catch
		_ -> ok
	end.