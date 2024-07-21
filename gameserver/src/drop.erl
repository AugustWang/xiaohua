%% Author: Administrator
%% Created: 2012-9-25
%% Description: TODO: Add description to drop
-module(drop).

%%
%% Include files
%%
-include("db.hrl").
-include("hdlt_logger.hrl").
-include("drop.hrl").
-include("itemDefine.hrl").
-include("globalDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% API Functions
%%
loadDrop() ->
	
	%%载入掉落包列表
	case db:openBinData( "drop_package.bin" ) of
		[] ->
			?ERROR_OUT( "loadDrop openBinData drop_package.bin false []" );
		PackageItem ->
			db:loadBinData(PackageItem, dropPackageItem),
			
			%PackageTable = ets:new(dropPackageTable, [protected, { keypos, #dropPackage.id }]),
			ets:new( ?DropPackageTableAtom, [set,protected, named_table,{read_concurrency,true},  { keypos, #dropPackage.id }] ),
			
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.dropPackageTable, PackageTable),
			
			PackItemList = db:matchObject(dropPackageItem,  #dropPackageItem{_='_'} ),
			
			Fun = fun( Record ) ->
						  case etsBaseFunc:readRecord(?DropPackageTableAtom, Record#dropPackageItem.packageId) of
							  {}->
								  Data = #dropPackage{
													  id = Record#dropPackageItem.packageId, 
													  maxWeight = Record#dropPackageItem.weight,
													  itemList = [Record] },
								  etsBaseFunc:insertRecord(?DropPackageTableAtom, Data);
							  A ->
								  NewList=A#dropPackage.itemList ++ [Record],
								  NewMaxWeight=A#dropPackage.maxWeight + Record#dropPackageItem.weight,
								  etsBaseFunc:insertRecord(?DropPackageTableAtom, #dropPackage{
																					  id = A#dropPackage.id,
																					  maxWeight=NewMaxWeight,
																					   itemList=NewList
																					  })
						  end
						  end,
			lists:foreach(Fun, PackItemList),		
			?DEBUG_OUT( "dropPackageTable succ" )
	end,
	%%载入掉落列表
	case db:openBinData("drop.bin") of
		[] ->
			?ERROR_OUT( "loadDrop openBinData drop.bin false []" );
		DropElement ->
			db:loadBinData(DropElement, dropElement),
			

			ets:new( ?DropTableAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #drop.id }] ),
			
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.dropTable, DropTable),
			
			DropElementList = db:matchObject(dropElement,  #dropElement{_='_'} ),
			
			Fun2 = fun( Record ) ->
						   case Record#dropElement.itemBinded =:= 0 of
							   true->Record2 = setelement( #dropElement.itemBinded, Record, false );
							   false->Record2 = setelement( #dropElement.itemBinded, Record, true )
						   end,

						  case etsBaseFunc:readRecord(?DropTableAtom, Record2#dropElement.dropId) of
							  {}->
								  Data = #drop{id = Record2#dropElement.dropId, dropList = [Record2] },
								  etsBaseFunc:insertRecord(?DropTableAtom, Data);
							  A ->
								  B=A#drop.dropList ++ [Record2],
								  etsBaseFunc:changeFiled(?DropTableAtom, A#drop.id,  #drop.dropList, B)
						  end
				  end,
			lists:foreach(Fun2, DropElementList),
			?DEBUG_OUT( "dropTable succ" )
			
			
			%%--------测试代码-----------
			%%{S1,S2,S3} = erlang:now(),
			%%random:seed(S1, S2, S3),
			%%DropList = getDropListByDropId(1),
			%%DropList
	        %%--------测试代码-----------
	end.


%%
%% Local Functions
%%

getDropById( ID ) ->
	etsBaseFunc:readRecord( main:getGlobalDropTable(), ID).

getDropPackageById( ID ) ->
	etsBaseFunc:readRecord( main:getGlobalDropPackageTable(), ID).

%%计算掉落元素产生的物品
getItemByDropElement(#dropElement{}=E, Radio) ->
	RandNumber = random:uniform(10000),
	case RandNumber =< (E#dropElement.probability*(Radio/10000))  of
		true->
			case E#dropElement.dropType of
				?DROP_TYPE_ITEM ->
					case E#dropElement.max =< E#dropElement.min of
						true ->
							#itemForAdd{id = E#dropElement.dataId, count = E#dropElement.min, binded = E#dropElement.itemBinded};
						false ->
							#itemForAdd{id = E#dropElement.dataId, count = random:uniform(E#dropElement.max-E#dropElement.min+1)-1+E#dropElement.min, binded = E#dropElement.itemBinded }
					end;
				?DROP_TYPE_PACKAGE ->
					case getDropPackageById(E#dropElement.dataId) of
						{} ->
							{};
						DropPack ->
							RandNumber2 = random:uniform(DropPack#dropPackage.maxWeight),
							put( "Weight", 0 ),
							WeightFunc = fun( Record ) ->
											 case (Record#dropPackageItem.weight+get("Weight") > RandNumber2) andalso (RandNumber2 >= get("Weight")) of
												true ->
													put( "Weight", Record#dropPackageItem.weight+get("Weight")),
													true;
											 	false ->
													put( "Weight", Record#dropPackageItem.weight+get("Weight")),
													false
											 end
								 		end,
							%%
							case lists:filter(WeightFunc, DropPack#dropPackage.itemList) of
								[] ->
									{};
								[PackItem|_] ->
									case PackItem#dropPackageItem.max =< PackItem#dropPackageItem.min of
										true ->
											#itemForAdd{id=PackItem#dropPackageItem.itemId, count = PackItem#dropPackageItem.min, binded = E#dropElement.itemBinded};
										false ->
											#itemForAdd{
													 id=PackItem#dropPackageItem.itemId, 
													 count = random:uniform(PackItem#dropPackageItem.max-PackItem#dropPackageItem.min+1)-1+PackItem#dropPackageItem.min, binded = E#dropElement.itemBinded}
									end
							end
					end
			end;
		false ->
			{}
	end.

%%根据掉落ID计算掉落列表
getDropListByDropId( DropId ) ->
	getDropListByDropId( DropId, 10000).

%%根据掉落ID计算掉落列表
getDropListByDropId( DropId, Radio ) ->
	case getDropById(DropId) of
		{} ->
			[];
		Drop ->
			put("ReturnDropList", []),
			Fun = fun(Record) ->
						  case getItemByDropElement(Record, Radio) of 
							  {} ->
								  ok;
							  A ->
								  put("ReturnDropList", get("ReturnDropList")++[A])
						  end
				  end,
			lists:map(Fun, Drop#drop.dropList),
			get("ReturnDropList")
	end.

gmDropTest( DropId, DropCount ) ->
	case getDropById(DropId) of
		{} ->
			?DEBUG_OUT( "not have this drop id!" );
		Drop ->
			?DEBUG_OUT( "--------------------------drop start--------------------------" ),
			ForFunc = fun(Index) ->
							  ?DEBUG_OUT("----------index [~p] ", [Index]),
							  lists:map(fun(Record)->
												case getItemByDropElement(Record, 10000) of 
													{} ->
														ok;
													A ->
														?DEBUG_OUT("{ Id = ~p , Count = ~p}", [A#itemForAdd.id, A#itemForAdd.count]) 
												end 
										end, 
										Drop#drop.dropList)
					  end,
			
			playerItems:for(1, DropCount, ForFunc),
			?DEBUG_OUT( "--------------------------drop end--------------------------" )
	end.

dropIemsToPlayer(DropIDList, MonsterId) ->
	FunAdd = fun(Add) ->
					 playerItems:addItemToPlayerByItemDataID(Add#itemForAdd.id, Add#itemForAdd.count, Add#itemForAdd.binded, ?Get_Item_Reson_Pick),
					 ?DEBUG_OUT("Add Item by Monster [~p] drop", [MonsterId])
			 end,
	MapFun = fun(ID) ->
				  L = getDropListByDropId(ID),
				  lists:map(FunAdd, L)
		  end,
	lists:map(MapFun, DropIDList).
		
		
		