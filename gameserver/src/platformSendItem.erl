%% Author: yueliangyou
%% Created: 2013-4-1
%% Description: TODO: 
-module(platformSendItem).

%%
%% Include files
%%
-include("db.hrl").
-include("playerDefine.hrl").
-include("itemDefine.hrl").
-include("mailDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("logdb.hrl").
%%
%% Exported Functions   
%%
-compile(export_all).  

sendItemToPlayerByPlayerName(PlayerName,ItemList,Title,Content)->
	try
	PlayerID = mySqlProcess:isPlayerExistByName(PlayerName),
	case PlayerID =:= 0 of
        	true->throw({noPlayer});
        	false->ok
	end,

	?DEBUG_OUT("sendItemToPlayerByPlayerName PlayerName:~p,ItemList:~p,Title:~p,Content:~p",[PlayerName,ItemList,Title,Content]),
	%% 发物品
	case checkItemList(ItemList) of
		fail->throw({invalidItemList});
		ItemListForAdd->
			?DEBUG_OUT("platformSendItem sendItemToPlayerByName ItemListForAdd:~p",[ItemListForAdd]),
			case mailPlayerItemList(PlayerID,ItemListForAdd,Title,Content) of
				ok->ok;
				_->	
					?LOG_OUT("sendItemToPlayerByName mailPlayerItemList fail.ID:~p,Name:~p,ItemList:~p",[PlayerID,PlayerName,ItemList]),
					fail
			end;
			
		_->ok
	end
	catch
		{noPlayer}->noPlayer;
		_:Why->
			?DEBUG_OUT("sendItemToPlayerByName exception ...Why:~p",[Why]),
			exception
	end.

% %加载并且处理物品发放
loadAndSendItem()->
	?DEBUG_OUT("platformSendItem loadAndSendItem ...",[]),
	SendItemRecordList=mySqlProcess:get_platformSendItem(),
	?DEBUG_OUT("platformSendItem loadAndSendItem ...Info:~p",[SendItemRecordList]),
	MyFunc=fun(Record)->
		sendItemToCurPlayer(Record)
	end,
	lists:foreach( MyFunc, SendItemRecordList ).

sendItemToCurPlayer(#platform_sendItem{id=ID,levelMin=LevelMin,levelMax=LevelMax,itemList=ItemList,money=Money,money_b=MoneyB,gold=Gold,gold_b=GoldB,exp=Exp,title=Title,content=Content}=R)->
	?DEBUG_OUT("platformSendItem proc ...Info:~p",[R]),
	Player=player:getCurPlayerRecord(),
	try
	case Player of
		{}->throw({noPlayer});
		_->ok
	end,
	PlayerID=Player#player.id,
	Name=Player#player.name,
	Bin=Player#player.platSendItemBits,
	Level=Player#player.level,
	%% 检查玩家标志位
	case myBits:isBitOn(Bin,ID) of
		true->throw({alreadySend});
		_->ok
	end,
	%% 检查玩家等级范围
	case (Level>=LevelMin) and (Level=<LevelMax) of 
		true->ok;
		_->
			%% 应运营要求，未到达等级的玩家在期间达到等级也不能领取
			BinNew0=myBits:setBit(Bin,ID),
			player:setCurPlayerProperty(#player.platSendItemBits,BinNew0),
			?DEBUG_OUT("platformSendItem proc ...BinNew:~p",[BinNew0]),
			throw({outofLevelRange})
	end,

	%% 发钱
	case Money > 0 of
		true->	
			ParamTupleMoney = #token_param{changetype = ?Money_Change_PlatformSend},
			case playerMoney:addPlayerMoney(Money,?Money_Change_PlatformSend,ParamTupleMoney) of
				0->
					?LOG_OUT("sendItemToCurPlayer addPlayerMoney fail.ID:~p,Name:~p,Money:~p",[PlayerID,Name,Money]);
				_->ok
			end;
		_->ok
	end,
	case MoneyB > 0 of
		true->
			ParamTupleMoneyB = #token_param{changetype = ?Money_Change_PlatformSend},
			case playerMoney:addPlayerBindedMoney(MoneyB,?Money_Change_PlatformSend,ParamTupleMoneyB) of
				0->
					?LOG_OUT("sendItemToCurPlayer addPlayerBindedMoney fail.ID:~p,Name:~p,MoneyB:~p",[PlayerID,Name,MoneyB]);
				_->ok
			end;
		_->ok
	end,
	case Gold > 0 of
		true->
			ParamTupleGold = #token_param{changetype = ?Money_Change_PlatformSend},
			case playerMoney:addPlayerGold(Gold,?Money_Change_PlatformSend,ParamTupleGold) of
				fail->
					?LOG_OUT("sendItemToCurPlayer addPlayerGold fail.ID:~p,Name:~p,Gold:~p",[PlayerID,Name,Gold]);
				_->ok
			end;
		_->ok
	end,
	case GoldB > 0 of
		true->
			ParamTupleGoldB = #token_param{changetype = ?Money_Change_PlatformSend},
			case playerMoney:addPlayerBindedGold(GoldB,?Money_Change_PlatformSend,ParamTupleGoldB) of
				fail->
					?LOG_OUT("sendItemToCurPlayer addPlayerBindedGold fail.ID:~p,Name:~p,GoldB:~p",[PlayerID,Name,GoldB]);
				_->ok
			end;
		_->ok
	end,
	%% 发经验
	case Exp > 0 of
		true->
			ParamTupleExp = #exp_param{changetype = ?Exp_Change_PlatformSend},
			player:addPlayerEXP(Exp,?Exp_Change_PlatformSend,ParamTupleExp);
		_->ok
	end,
	
	?DEBUG_OUT("platformSendItem ItemList:~p",[ItemList]),
	%% 发物品
	case checkItemList(ItemList) of
		fail->ok;
		ItemListForAdd->
			?DEBUG_OUT("platformSendItem ItemListForAdd:~p",[ItemListForAdd]),
			case mailPlayerItemList(PlayerID,ItemListForAdd,Title,Content) of
				ok->ok;
				_->	
					?LOG_OUT("sendItemToCurPlayer mailPlayerItemList fail.ID:~p,ItemList:~p",[PlayerID,ItemList])
			end;
			%% 改为用邮件，注释下面代码
			%case addPlayerItemList(ItemListForAdd) of
			%	ok->ok;
			%	_->
			%		?LOG_OUT("sendItemToCurPlayer addPlayerItemList fail.ID:~p,Name:~p,ItemList:~p",[PlayerID,Name,ItemList])
			%end;
			
		_->ok
	end,
	%% set bit
	BinNew=myBits:setBit(Bin,ID),
	player:setCurPlayerProperty(#player.platSendItemBits,BinNew),
	?DEBUG_OUT("platformSendItem proc ...BinNew:~p",[BinNew])
	catch
		{noPlayer}->ok;
		{outofLevelRange}->ok;
		{alreadySend}->ok;
		_:Why->
			%% set bit
			case Player of
				{}->ok;
				_->
					PlayerExceptionID=Player#player.id,
					PlayerExceptionName=Player#player.name,
					PlayerExceptionBin=Player#player.platSendItemBits,
					PlayerExceptionBinNew=myBits:setBit(PlayerExceptionBin,ID),
					player:setCurPlayerProperty(#player.platSendItemBits,PlayerExceptionBinNew),
					?LOG_OUT("platformSendItem proc exception.ID:~p,Name:~p,Record:~p",[PlayerExceptionID,PlayerExceptionName,R]),
					?DEBUG_OUT("platformSendItem proc ...PlayerExceptionBinNew:~p",[PlayerExceptionBinNew])
			end,
			?DEBUG_OUT("platformSendItem exception ...Why:~p",[Why])

	end.

checkItemList(ItemList)->
	?DEBUG_OUT("platformSendItem checkItemList",[]),
	StringTokens=string:tokens(ItemList,"|"),
	ItemCount=length(StringTokens),
	?DEBUG_OUT("platformSendItem checkItemList:~p,~p",[ItemCount,StringTokens]),
	try
	case ItemCount of
		0->fail;
		1->
			[StringToken]=StringTokens,
			ItemTokens=string:tokens(StringToken,","),
			case length(ItemTokens) =:= 3 of
				true->ok;
				false->throw({invalidItemList})
			end,
			[ItemID_S,Cnt_S,Bind_S]=ItemTokens,
			{ItemID,_}=string:to_integer(ItemID_S),
                        {Cnt,_}=string:to_integer(Cnt_S),
                        {Bind,_}=string:to_integer(Bind_S),
			case Bind of
				0->Binded=false;
				_->Binded=true
			end,
			_ItemListForAdd=[#itemForAdd{id=ItemID,count=Cnt,binded=Binded}];
		2->
			[StringToken1,StringToken2]=StringTokens,
			ItemTokens1=string:tokens(StringToken1,","),
			ItemTokens2=string:tokens(StringToken2,","),
			case (length(ItemTokens1) =:= 3) and (length(ItemTokens2) =:= 3) of
				true->ok;
				false->throw({invalidItemList})
			end,
			[ItemID_S1,Cnt_S1,Bind_S1]=ItemTokens1,
			[ItemID_S2,Cnt_S2,Bind_S2]=ItemTokens2,
			{ItemID1,_}=string:to_integer(ItemID_S1),
                        {Cnt1,_}=string:to_integer(Cnt_S1),
                        {Bind1,_}=string:to_integer(Bind_S1),
			{ItemID2,_}=string:to_integer(ItemID_S2),
                        {Cnt2,_}=string:to_integer(Cnt_S2),
                        {Bind2,_}=string:to_integer(Bind_S2),
			case Bind1 of
				0->Binded1=false;
				_->Binded1=true
			end,

			case Bind2 of
				0->Binded2=false;
				_->Binded2=true
			end,
			ItemListForAdd1=#itemForAdd{id=ItemID1,count=Cnt1,binded=Binded1},
			ItemListForAdd2=#itemForAdd{id=ItemID2,count=Cnt2,binded=Binded2},
			_ItemListForAdd=[ItemListForAdd1,ItemListForAdd2];
		_->
			[StringToken1,StringToken2,_]=StringTokens,
			ItemTokens1=string:tokens(StringToken1,","),
			ItemTokens2=string:tokens(StringToken2,","),
			case (length(ItemTokens1) =:= 3) and (length(ItemTokens2) =:= 3) of
				true->ok;
				false->throw({invalidItemList})
			end,
			[ItemID_S1,Cnt_S1,Bind_S1]=ItemTokens1,
			[ItemID_S2,Cnt_S2,Bind_S2]=ItemTokens2,
			{ItemID1,_}=string:to_integer(ItemID_S1),
                        {Cnt1,_}=string:to_integer(Cnt_S1),
                        {Bind1,_}=string:to_integer(Bind_S1),
			{ItemID2,_}=string:to_integer(ItemID_S2),
                        {Cnt2,_}=string:to_integer(Cnt_S2),
                        {Bind2,_}=string:to_integer(Bind_S2),
			case Bind1 of
				0->Binded1=false;
				_->Binded1=true
			end,

			case Bind2 of
				0->Binded2=false;
				_->Binded2=true
			end,
			ItemListForAdd1=#itemForAdd{id=ItemID1,count=Cnt1,binded=Binded1},
			ItemListForAdd2=#itemForAdd{id=ItemID2,count=Cnt2,binded=Binded2},
			_ItemListForAdd=[ItemListForAdd1,ItemListForAdd2]
	end
	catch
		_:Why->
			?LOG_OUT("platformSendItem checkItemList exception.Why:~p,ItemList:~p",[Why,ItemList]),
			fail
	end.

addPlayerItemList(ItemList) ->
	PlayerID = player:getCurPlayerID(),
	%% 运营提出要修改，统一使用邮件发送
	case mailPlayerItemList(PlayerID,ItemList,"title","") of
		ok->ok;
		_->	
			?LOG_OUT("addPlayerItemList mailPlayerItemList fail.ID:~p,ItemList:~p",[PlayerID,ItemList])
	end.
	%% 背包空间够，直接给物品
%	case playerItems:getPlayerBagSpaceCellCount() >= length(ItemList) of
%		true->
%			lists:foreach(fun(I)->playerItems:addItemToPlayerByItemDataID(I#itemForAdd.id,I#itemForAdd.count,I#itemForAdd.binded,?Get_Item_Reson_PlatformSend) end,ItemList),
%			ok;
	%% 背包空间不够，发邮件
%		false->
%			MyFun=fun(ItemID,Count,Binded)->
%				Ret = mail:sendSystemMailToPlayer(PlayerID, "system", "title", "", ItemID,Count,Binded,0,0,true,0),
%				case Ret =:= ?SendMailResult_Succ of
%            		true->ok;
%                	false->
%						?LOG_OUT("sendItemToCurPlayer addItemToPlayer fail.ID:~p,ItemID:~p,Count:~p,Binded:~p",[PlayerID,ItemID,Count,Binded])
%            	end
%			end,
%			lists:foreach(fun(I)->MyFun(I#itemForAdd.id,I#itemForAdd.count,I#itemForAdd.binded) end, ItemList),
%			ok
%	end.

mailPlayerItemList(PlayerID,ItemList,Title,Content) ->
	put("TempItemList", []),
	Fun = fun(Item) -> 
		case itemModule:getItemCfgDataByID(Item#itemForAdd.id) of 
		  {} ->ok;
		  ItemData ->
			  case ItemData#r_itemCfg.maxAmount >= Item#itemForAdd.count of
				  true->put("TempItemList", get("TempItemList")++[Item]);
				  false->
					  Quo = Item#itemForAdd.count div ItemData#r_itemCfg.maxAmount,
					  case Item#itemForAdd.count rem ItemData#r_itemCfg.maxAmount of
						  0 ->ok;
						  Odd->
							  Item2 =  #itemForAdd{ id = Item#itemForAdd.id, count = Odd, binded = Item#itemForAdd.binded },
							  put("TempItemList", get("TempItemList")++[Item2])
					  end,
					  playerItems:for(1,Quo,
								fun(_)-> 
						  			Item3=#itemForAdd{id=Item#itemForAdd.id,count=ItemData#r_itemCfg.maxAmount,binded=Item#itemForAdd.binded},
						  			put("TempItemList", get("TempItemList")++[Item3]) 
								end)
			  end
		end
	end,
	lists:foreach(Fun, ItemList),

	ItemListNew = get("TempItemList"),	
	?DEBUG_OUT("mailPlayerItemList ready.Title:~p,Content:~p,ItemListNew:~p",[Title,Content,ItemListNew]),
	MyFun=fun(ItemID,Count,Binded)->
		Ret = mail:sendSystemMailToPlayer(PlayerID,"system", Title, Content, ItemID,Count,Binded,0,0,true,0),
		case Ret =:= ?SendMailResult_Succ of
       		true->ok;
           	false->
				?LOG_OUT("mailPlayerItemList fail.ID:~p,ItemID:~p,Count:~p,Binded:~p",[PlayerID,ItemID,Count,Binded])
       	end
	end,
	lists:foreach(fun(I)->MyFun(I#itemForAdd.id,I#itemForAdd.count,I#itemForAdd.binded) end, ItemList),
	ok.









