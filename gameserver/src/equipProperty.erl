%% @author Administrator
%% @doc @todo Add description to equipProperty.

-module(equipProperty).

-include("db.hrl").
-include("hdlt_logger.hrl").
-include("itemDefine.hrl").
-include("playerDefine.hrl").
-include("package.hrl").
-include("logdb.hrl").
-include("textDefine.hrl").
-include("globalDefine.hrl").

-compile(export_all). 
%%新建角色时：装备强化等级和强化进度初始化
playerEquipEnhanceLevelInit( PlayerID )->
	case PlayerID of 
		0 ->
			%%?DEBUG_OUT( "sendToPlayerByPID PlayerPID[~p] = 0", [PlayerID] ),
			ok;
		_ ->
			
			LevelInfo = #playerEquipLevelInfo{level=0,progress=0,blessValue=0},
			
			DB = #playerEquipEnhanceLevel{playerId=PlayerID,
										  ring=LevelInfo,
										  weapon=LevelInfo,
										  cap=LevelInfo,
										  shoulder=LevelInfo,
										  pants=LevelInfo, 
										  hand=LevelInfo,
										  coat=LevelInfo,
										  belt=LevelInfo,
										  shoe=LevelInfo,
										  accessories=LevelInfo,
										  wing=LevelInfo,
										  fashion=LevelInfo
										 },
			mySqlProcess:insertOrReplacePlayerEquipEnhanceLevel(DB,false)
	end.

%%进入服务器初始化，读取装备数据表
equipPropertyCfgLoad( )->
	
	loadPropertyValueSizeCfg(),
	loadEqualityPropertyAddValueCfg(),
	loadPropertyWeightCfg(),
	loadEquipActiveItemNeed(),
	case db:openBinData( "equipmentenhance.bin" ) of
		[] ->
			?ERROR_OUT( "equipEnhancePropertyTable openBinData equipmentenhance.bin false []" );
		HanceBinData ->
			db:loadBinData( HanceBinData, equipEnhance ),

			ets:new( ?EquipEnhancePropertyTableAtom, [set,protected, named_table,{read_concurrency,true},  { keypos, #equipEnhance.level }] ),

			
			HanceBinDatalist = db:matchObject(equipEnhance, #equipEnhance{ _='_' } ),
			
			HanceFun = fun(HanceRecord) ->
						  etsBaseFunc:insertRecord(?EquipEnhancePropertyTableAtom, HanceRecord)
				  end,
			lists:map(HanceFun, HanceBinDatalist),
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.equipEnhancePropertyTable, HanceBinDataCfgTable),
			?DEBUG_OUT( "equipEnhancePropertyTable load succ" )
			
	end,
	case db:openBinData( "equipmentquality.bin" ) of
		[] ->
			?ERROR_OUT( "equipmentqualityTable openBinData equipmentquality.bin false []" );
		QualityBinData ->
			db:loadBinData( QualityBinData, equipmentquality ),

			ets:new( ?EquipmentqualityTableAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #equipmentquality.qualityLevel  }] ),
					
			QualityBinDatalist = db:matchObject(equipmentquality, #equipmentquality{ _='_' } ),
			
			QualityFun = fun(QualityRecord) -> 
						  etsBaseFunc:insertRecord(?EquipmentqualityTableAtom, QualityRecord)
				  end,
			lists:map(QualityFun, QualityBinDatalist),
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.equipmentqualityTable, QualityBinDataCfgTable),
			?DEBUG_OUT( "equipmentqualityTable load succ" )
			
	end,
	case db:openBinData( "equipWashupMoney.bin" ) of
		[] ->
			?ERROR_OUT( "equipwashupMoneyTable openBinData equipwashupmoney.bin false []" );
		WashupMoneyBinData ->
			db:loadBinData( WashupMoneyBinData, equipwashupmoney ),

			ets:new( ?EquipwashupMoneyTableAtom, [set,protected, named_table,{read_concurrency,true},  { keypos, #equipwashupmoney.equipid  }] ),
			
			WashupMoneyBinDatalist = db:matchObject(equipwashupmoney, #equipwashupmoney{ _='_' } ),
			
			WashupMoneyFun = fun(WashupMoneyRecord) ->
						  etsBaseFunc:insertRecord(?EquipwashupMoneyTableAtom, WashupMoneyRecord)
				  end,
			lists:map(WashupMoneyFun, WashupMoneyBinDatalist),
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.equipwashupMoneyTable, WashupMoneyBinDataCfgTable),
			?DEBUG_OUT( "equipwashupMoneyTable load succ" )
			end.

%%读取品质提升时附加属性提升:
loadEqualityPropertyAddValueCfg()->
	case db:openBinData( "equipmentqualityfactor.bin" ) of
		[] ->
			?ERROR_OUT( "equipmentqualityfactorTable openBinData equipmentqualityfactor.bin false []" );
		AddValueBinData ->
			db:loadBinData( AddValueBinData, propertyAddValueCfgRead ),
		
			ets:new( ?EquipmentqualityfactorTableAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #propertyAddValueCfg.quality_Level }] ),

			DefaultValue = #propertyAddValueExtern{ propertyType=0,fixOrPercent=0,relativeValue=0,absoluteValue =0,pointFactor=0},
			Array = array:new(?property_count * 2, {default, DefaultValue} ),
			MyFunc1 = fun( Index )->
				Record = #propertyAddValueCfg{ quality_Level=Index, propertyArray=Array},
				etsBaseFunc:insertRecord( ?EquipmentqualityfactorTableAtom, Record)
		  	end,
			common:for( 1, ?Equip_Quality_count-1, MyFunc1),
			MyFucn = fun( Record )->
							 PropertyAddValueCfg = etsBaseFunc:readRecord( ?EquipmentqualityfactorTableAtom, Record#propertyAddValueCfgRead.quality_Level ),
							 PropertyExtern = #propertyAddValueExtern{propertyType=Record#propertyAddValueCfgRead.propertyType,
															 fixOrPercent =Record#propertyAddValueCfgRead.fixOrPercent, 
															 relativeValue=Record#propertyAddValueCfgRead.relativeValue,
															 absoluteValue=Record#propertyAddValueCfgRead.absoluteValue,
															 pointFactor=Record#propertyAddValueCfgRead.point},
					
							NewArray = array:set( Record#propertyAddValueCfgRead.propertyType * 2 + Record#propertyAddValueCfgRead.fixOrPercent, PropertyExtern, PropertyAddValueCfg#propertyAddValueCfg.propertyArray ),
							etsBaseFunc:changeFiled( ?EquipmentqualityfactorTableAtom, Record#propertyAddValueCfgRead.quality_Level, #propertyAddValueCfg.propertyArray, NewArray)
					 end,
			AddValuelist = db:matchObject(propertyAddValueCfgRead, #propertyAddValueCfgRead{ _='_' } ),
			lists:foreach( MyFucn, AddValuelist ),
			ok
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.equipmentqualityfactorTable, AddValueBinDataCfgTable)
	end.

%%读取附加属性取值范围:
loadPropertyValueSizeCfg()->
	case db:openBinData( "equipmentqualityattribute.bin" ) of
		[] ->
			?ERROR_OUT( "equipmentqualityattributeTable openBinData equipmentqualityattribute.bin false []" );
		ValueSizeBinData ->
			db:loadBinData( ValueSizeBinData, propertyValueSizeCfgRead ),


			
			ets:new( ?EquipmentqualityattributeTableAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #propertyValueSizeCfg.equip_Level }] ),
	
			DefaultValue = #valueSizeExtern{propertyType=0,fixOrPercent=0, minValue=0, maxValue=0,mindivisor=0,point=0 },
			Array = array:new(?property_count*2, {default, DefaultValue} ),
			
			MyFunc1 = fun( Index )->
				Record = #propertyValueSizeCfg{ equip_Level=Index, propertyArray=Array  },
				etsBaseFunc:insertRecord( ?EquipmentqualityattributeTableAtom, Record)
		  	end,
			common:for( 0, ?Equip_Level_count-1, MyFunc1),
			MyFucn = fun( Record )->
							 ValueSizePropertyCfg = etsBaseFunc:readRecord( ?EquipmentqualityattributeTableAtom, Record#propertyValueSizeCfgRead.equip_Level ),
							 case ValueSizePropertyCfg of
								 {}->
									 ok;
								 _->
									 PropertyExtern = #valueSizeExtern{propertyType=Record#propertyValueSizeCfgRead.propertyType,
															   fixOrPercent =Record#propertyValueSizeCfgRead.fixOrPercent, 
															   minValue=Record#propertyValueSizeCfgRead.minValue, 
															   maxValue=Record#propertyValueSizeCfgRead.maxValue,
															   mindivisor=Record#propertyValueSizeCfgRead.mindivisor,
															   point=Record#propertyValueSizeCfgRead.point},
									 NewArray = array:set( Record#propertyValueSizeCfgRead.propertyType * 2 +Record#propertyValueSizeCfgRead.fixOrPercent, PropertyExtern, ValueSizePropertyCfg#propertyValueSizeCfg.propertyArray  ),
							 		 etsBaseFunc:changeFiled( ?EquipmentqualityattributeTableAtom, Record#propertyValueSizeCfgRead.equip_Level , #propertyValueSizeCfg.propertyArray , NewArray)
							 end
					 end,
			ValueSizeCfgList = db:matchObject(propertyValueSizeCfgRead,  #propertyValueSizeCfgRead{_='_'} ),
			lists:foreach( MyFucn, ValueSizeCfgList ),
			ok
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.equipmentqualityattributeTable, ValueSizeBinDataCfgTable)
	end.

%%读取附加属性出现几率:
loadPropertyWeightCfg()->
	case db:openBinData( "equipmentqualityweight.bin" ) of
		[] ->
			?ERROR_OUT( "equipmentqualityweightTable openBinData equipmentqualityweight.bin false []" );
		WeightBinData ->
			db:loadBinData( WeightBinData, propertyWeightCfgRead ),
	
			ets:new( ?EquipmentqualityweightTableAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #propertyWeightCfg.equip_Type }] ),
	
			DefaultValue = #weightExtern{propertyType=0,fixOrPercent=0, value=0 },
			Array = array:new(?property_count*2, {default, DefaultValue} ),
			
			MyFunc1 = fun( Index )->
				Record = #propertyWeightCfg{ equip_Type=Index, propertyArray=Array,ratetotal=0 },
				etsBaseFunc:insertRecord( ?EquipmentqualityweightTableAtom, Record)
		  	end,
			common:for( 0, ?EquipType_Max-1, MyFunc1),
			
		
			MyFucn = fun( Record )->
							 PropertyWeightCfg = etsBaseFunc:readRecord( ?EquipmentqualityweightTableAtom, Record#propertyWeightCfgRead.equip_Type ),

							 PropertyExtern = #weightExtern{propertyType=Record#propertyWeightCfgRead.propertyType,
												   fixOrPercent =Record#propertyWeightCfgRead.fixOrPercent,
												   value=Record#propertyWeightCfgRead.value},
							 NewArray = array:set( Record#propertyWeightCfgRead.propertyType * 2 + Record#propertyWeightCfgRead.fixOrPercent, PropertyExtern, PropertyWeightCfg#propertyWeightCfg.propertyArray ),
							 etsBaseFunc:changeFiled( ?EquipmentqualityweightTableAtom, Record#propertyWeightCfgRead.equip_Type, #propertyWeightCfg.propertyArray, NewArray),
							 
							 NewRatetotal = PropertyWeightCfg#propertyWeightCfg.ratetotal + Record#propertyWeightCfgRead.value,
							 etsBaseFunc:changeFiled( ?EquipmentqualityweightTableAtom, Record#propertyWeightCfgRead.equip_Type, #propertyWeightCfg.ratetotal, NewRatetotal)
					 end,
			WeightBinDatalist = db:matchObject(propertyWeightCfgRead, #propertyWeightCfgRead{ _='_' } ),
			lists:foreach( MyFucn, WeightBinDatalist ),
			ok
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.equipmentqualityweightTable, WeightBinDataCfgTable)
	end.

%%读取装备升品或激活时所需物品及数量：
loadEquipActiveItemNeed()->
	case db:openBinData( "ActiveEquipNeed.bin" )  of
		[] ->
			?ERROR_OUT( "equipmentActiveItemNeedTable openBinData ActiveEquipNeed.bin false []" );
		EquipNeedBinData ->
			db:loadBinData( EquipNeedBinData, equipmentActiveItem ),
	
			ets:new( ?EquipmentActiveItemNeedTableAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #equipmentActiveItemNeed.quality_ID  }] ),

			EquipNeedFun = fun(Record) ->
								   WhiteItemNeed = #itemNeed{itemID_1=Record#equipmentActiveItem.whiteID_1,itemNum_1=Record#equipmentActiveItem.whiteNum_1,
															 itemID_2=Record#equipmentActiveItem.whiteID_2,itemNum_2=Record#equipmentActiveItem.whiteNum_2,
															 itemID_3=Record#equipmentActiveItem.whiteID_3,itemNum_3=Record#equipmentActiveItem.whiteNum_3,
															 itemID_4=Record#equipmentActiveItem.whiteID_4,itemNum_4=Record#equipmentActiveItem.whiteNum_4},
								   GreenItemNeed = #itemNeed{itemID_1=Record#equipmentActiveItem.greenID_1,itemNum_1=Record#equipmentActiveItem.greenNum_1,
															 itemID_2=Record#equipmentActiveItem.greenID_2,itemNum_2=Record#equipmentActiveItem.greenNum_2,
															 itemID_3=Record#equipmentActiveItem.greenID_3,itemNum_3=Record#equipmentActiveItem.greenNum_3,
															 itemID_4=Record#equipmentActiveItem.greenID_4,itemNum_4=Record#equipmentActiveItem.greenNum_4},
								   BlueItemNeed = #itemNeed{itemID_1=Record#equipmentActiveItem.blueID_1,itemNum_1=Record#equipmentActiveItem.blueNum_1,
															 itemID_2=Record#equipmentActiveItem.blueID_2,itemNum_2=Record#equipmentActiveItem.blueNum_2,
															 itemID_3=Record#equipmentActiveItem.blueID_3,itemNum_3=Record#equipmentActiveItem.blueNum_3,
															 itemID_4=Record#equipmentActiveItem.blueID_4,itemNum_4=Record#equipmentActiveItem.blueNum_4},
								   PurItemNeed = #itemNeed{itemID_1=Record#equipmentActiveItem.purID_1,itemNum_1=Record#equipmentActiveItem.purNum_1,
															 itemID_2=Record#equipmentActiveItem.purID_2,itemNum_2=Record#equipmentActiveItem.purNum_2,
															 itemID_3=Record#equipmentActiveItem.purID_3,itemNum_3=Record#equipmentActiveItem.purNum_3,
															 itemID_4=Record#equipmentActiveItem.purID_4,itemNum_4=Record#equipmentActiveItem.purNum_4},
								   OrangeItemNeed = #itemNeed{itemID_1=Record#equipmentActiveItem.orangeID_1,itemNum_1=Record#equipmentActiveItem.orangeNum_1,
															 itemID_2=Record#equipmentActiveItem.orangeID_2,itemNum_2=Record#equipmentActiveItem.orangeNum_2,
															 itemID_3=Record#equipmentActiveItem.orangeID_3,itemNum_3=Record#equipmentActiveItem.orangeNum_3,
															 itemID_4=Record#equipmentActiveItem.orangeID_4,itemNum_4=Record#equipmentActiveItem.orangeNum_4},
								   RedItemNeed = #itemNeed{itemID_1=Record#equipmentActiveItem.redID_1,itemNum_1=Record#equipmentActiveItem.redNum_1,
															 itemID_2=Record#equipmentActiveItem.redID_2,itemNum_2=Record#equipmentActiveItem.redNum_2,
															 itemID_3=Record#equipmentActiveItem.redID_3,itemNum_3=Record#equipmentActiveItem.redNum_3,
															 itemID_4=Record#equipmentActiveItem.redID_4,itemNum_4=Record#equipmentActiveItem.redNum_4},

								   ItemNeedArray = array:new(?Equip_Quality_count, {default, 0} ),
								   NewArray1 = array:set( ?Equip_Quality_White , WhiteItemNeed, ItemNeedArray  ),
								   NewArray2 = array:set( ?Equip_Quality_Green , GreenItemNeed, NewArray1  ),
								   NewArray3 = array:set( ?Equip_Quality_Blue , BlueItemNeed, NewArray2  ),
								   NewArray4 = array:set( ?Equip_Quality_Purple , PurItemNeed, NewArray3  ),
								   NewArray5 = array:set( ?Equip_Quality_Orange , OrangeItemNeed, NewArray4  ),
								   NewArray6 = array:set( ?Equip_Quality_Red , RedItemNeed, NewArray5  ),
								   
								   NewRecord = #equipmentActiveItemNeed{ quality_ID=Record#equipmentActiveItem.quality_ID, itemNeedArray=NewArray6  },
								   etsBaseFunc:insertRecord( ?EquipmentActiveItemNeedTableAtom, NewRecord)
						   end,
			EquipNeedBinDatalist = db:matchObject(equipmentActiveItem, #equipmentActiveItem{ _='_' } ),
			lists:foreach(EquipNeedFun, EquipNeedBinDatalist),
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.equipmentActiveItemNeedTable, EquipNeedBinDataCfgTable),
			?DEBUG_OUT( "equipmentActiveItemNeedTable load succ" )
			end.

%%返回物品强化属性提升及所需次数和成功率，
getequipEnhancePropertyByLevel( Level ) ->
	etsBaseFunc:readRecord( main:getGlobalEquipEnhancePropertyTable(), Level).

%%返回装备当前品质所提升的基础属性
getEquipQualityBasalPropertyByQualityLevel( QualityLevel ) ->
	etsBaseFunc:readRecord( main:getGlobalequipmentqualityTable(), QualityLevel).

%%返回装备当前品质所提升的附加属性
getEquipQualityqualityfactorByQualityLevel( QualityLevel ) ->
	etsBaseFunc:readRecord( main:getGlobalequipmentqualityfactorTable(), QualityLevel).

%%返回当前装备等级生成附加属性时，附加属性的取值范围
getEquipAttributeByEquipLevel( EquipLevel ) ->
	etsBaseFunc:readRecord( main:getGlobalequipmentqualityattributeTable(), EquipLevel).

%%返回各类附加属性出现的几率列表
getEquipqualityweightByEquipType( EquipType ) ->
	etsBaseFunc:readRecord( main:getGlobalequipmentqualityweightTable(), EquipType).

%%返回某装备激活与升品的物品表
getEquipActiveItemNeedById( EquipID ) ->
	etsBaseFunc:readRecord( main:getGlobalequipmentActiveItemNeedTable(), EquipID).

%%返回装备升品及洗髓所消耗的游戏币列表
getEquipwashupMoneyByEquipID( EquipID ) ->
	etsBaseFunc:readRecord( main:getGlobalequipmentWashupMoneyTable(), EquipID).

%%-----------------------------------------------------------------装备强化-----------------------------------------------------
%%玩家上线时：装备强化情况初始化
onPlayerOnlineEquipEnhanceInfoInit( EquipEnhanceInfoList )->
	case EquipEnhanceInfoList of
		[]->ok;
		_->
			[Record|_] = EquipEnhanceInfoList,
			
			etsBaseFunc:insertRecord( get("EquipEnhanceInfoTable"), Record)
	end.

%%返回玩家装备强化情况
getEquipEnhanceInfoTable()->
	EquipEnhanceInfoTable = get( "EquipEnhanceInfoTable" ),
	case EquipEnhanceInfoTable of
		undefined->0;
		_->etsBaseFunc:readRecord( EquipEnhanceInfoTable, player:getCurPlayerID())
			
	end.
%%获取玩家当前装备部位的强化情况
getPlayerEquipEnhanceByType( EquipType )->
	try
		EquipEnhanceInfoTable = getEquipEnhanceInfoTable(),
		case EquipType of
			?EquipType_Ring ->
				EquipEnhanceInfoTable#playerEquipEnhanceLevel.ring;
			?EquipType_Weapon ->
				EquipEnhanceInfoTable#playerEquipEnhanceLevel.weapon;
			?EquipType_Cap->
				EquipEnhanceInfoTable#playerEquipEnhanceLevel.cap;
			?EquipType_Shoulder->
				EquipEnhanceInfoTable#playerEquipEnhanceLevel.shoulder;
			?EquipType_Pants->
				EquipEnhanceInfoTable#playerEquipEnhanceLevel.pants;
			?EquipType_Hand->
				EquipEnhanceInfoTable#playerEquipEnhanceLevel.hand;
			?EquipType_Coat->
				EquipEnhanceInfoTable#playerEquipEnhanceLevel.coat;
			?EquipType_Belt->
				EquipEnhanceInfoTable#playerEquipEnhanceLevel.belt;
			?EquipType_Shoe->
				EquipEnhanceInfoTable#playerEquipEnhanceLevel.shoe;
			?EquipType_Accessories->
				EquipEnhanceInfoTable#playerEquipEnhanceLevel.accessories;
			?EquipType_Wing->
				EquipEnhanceInfoTable#playerEquipEnhanceLevel.wing;
			?EquipType_Fashion->
				EquipEnhanceInfoTable#playerEquipEnhanceLevel.fashion;
			_->
				?ERROR_OUT("getPlayerEquipEnhanceByType,EquipType:~p error",[EquipType])
		end
	catch
		_->ok
	end.

%%返回玩家装备强化情况，强化进度，强化次数，强化成功率，及所需要消耗的金币数
getPlayerEquipEnHanceInfoByType (EquipType)->
	try
		LevelAddProgress = getPlayerEquipEnhanceByType(EquipType),
		EquipEnhanceInfo = getequipEnhancePropertyByLevel(LevelAddProgress#playerEquipLevelInfo.level),
		case EquipEnhanceInfo of
			undefined->ok;
			_->
				Level = LevelAddProgress#playerEquipLevelInfo.level,
				Progress = LevelAddProgress#playerEquipLevelInfo.progress,
				BlessValue = LevelAddProgress#playerEquipLevelInfo.blessValue,
				player:send(#pk_GetPlayerEquipEnhanceByTypeBack{ type = EquipType, level = Level,progress = Progress,blessValue = BlessValue})
		end
	catch
		_->ok
	end.

%%一键强化时保存新的强化到ets
onceEquipEnHanceSaveInfoToEts(EquipType,NewInfo)->
	EquipEnhanceInfoTable = get( "EquipEnhanceInfoTable" ),
	case EquipType of
		?EquipType_Ring ->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.ring, NewInfo);
		?EquipType_Weapon ->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.weapon, NewInfo);
		?EquipType_Cap->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.cap, NewInfo);
		?EquipType_Shoulder->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.shoulder, NewInfo);
		?EquipType_Pants->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.pants, NewInfo);
		?EquipType_Hand->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.hand, NewInfo);
		?EquipType_Coat->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.coat, NewInfo);
		?EquipType_Belt->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.belt, NewInfo);
		?EquipType_Shoe->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.shoe, NewInfo);
		?EquipType_Accessories->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.accessories, NewInfo);
		?EquipType_Wing->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.wing, NewInfo);
		?EquipType_Fashion->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.fashion, NewInfo)
		end.


%%保存新的强化信息
changeEquipEnHanceInfo ( EquipType,NewInfo)->
	try
		EquipEnhanceInfoTable = get( "EquipEnhanceInfoTable" ),
		case EquipType of
		?EquipType_Ring ->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.ring, NewInfo);
		?EquipType_Weapon ->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.weapon, NewInfo);
		?EquipType_Cap->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.cap, NewInfo);
		?EquipType_Shoulder->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.shoulder, NewInfo);
		?EquipType_Pants->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.pants, NewInfo);
		?EquipType_Hand->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.hand, NewInfo);
		?EquipType_Coat->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.coat, NewInfo);
		?EquipType_Belt->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.belt, NewInfo);
		?EquipType_Shoe->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.shoe, NewInfo);
		?EquipType_Accessories->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.accessories, NewInfo);
		?EquipType_Wing->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.wing, NewInfo);
		?EquipType_Fashion->
			etsBaseFunc:changeFiled(EquipEnhanceInfoTable,player:getCurPlayerID(), #playerEquipEnhanceLevel.fashion, NewInfo)
		end,

		mySqlProcess:insertOrReplacePlayerEquipEnhanceLevel(etsBaseFunc:readRecord( EquipEnhanceInfoTable, player:getCurPlayerID()),true),

		playerMap:onPlayer_LevelEquipPet_Changed(),
		equipment:sendPlayerAllEquip()
	catch
		_->ok
	end.

%%点击强化
playerEquipEnHance( EquipType )->
	try
		LevelAddProgress = getPlayerEquipEnhanceByType(EquipType),
		case LevelAddProgress#playerEquipLevelInfo.level<?Equip_Strengthen_MaxLevel of
			true->
				EquipEnhanceInfo = getequipEnhancePropertyByLevel(LevelAddProgress#playerEquipLevelInfo.level+1),
				case EquipEnhanceInfo of
					undefined->throw(-1);
					_->
						CanDecItemCount  = playerItems:getItemCountByItemData(?Item_Location_Bag, EquipEnhanceInfo#equipEnhance.enhanceItem, "all"),
						case CanDecItemCount >= EquipEnhanceInfo#equipEnhance.itemMunber of
							true->
								CanDecItemResult = playerItems:canDecItemInBag(?Item_Location_Bag, EquipEnhanceInfo#equipEnhance.enhanceItem, EquipEnhanceInfo#equipEnhance.itemMunber, "all" ),
								[CanDecItem|DecItemData] = CanDecItemResult,
								put( "equipment_DecItemData", DecItemData );
							false->
								player:send(#pk_EquipEnhanceByTypeBack{ result = ?EquipEnhance_Fail_NotEnough_Item}),
								throw(-1)
						end,
						case playerMoney:canUsePlayerBindedMoney( EquipEnhanceInfo#equipEnhance.enhanceCost) of
							true->
								ok;
							false->
								player:send(#pk_EquipEnhanceByTypeBack{ result = ?EquipEnhance_Fail_NotEnough_Money}),
								throw(-1)
						end,
						ParamTuple = #token_param{changetype = ?Money_Change_EquipEnHance,param1=EquipType},
						playerMoney:usePlayerBindedMoney( EquipEnhanceInfo#equipEnhance.enhanceCost, ?Money_Change_EquipEnHance, ParamTuple),
						playerItems:decItemInBag( get("equipment_DecItemData"), ?Destroy_Item_Reson_EquipEnHance ),
						
						PlayerBase = player:getCurPlayerRecord(),
						%%先判定进度，在判定祝福值，在失败的时候也要判断祝福值
						case random:uniform(10000) =< EquipEnhanceInfo#equipEnhance.enhanceRate of
							true->
								case (LevelAddProgress#playerEquipLevelInfo.progress + 1) >= EquipEnhanceInfo#equipEnhance.times of
									true->
										NewLevelAddProgress = #playerEquipLevelInfo{ level=LevelAddProgress#playerEquipLevelInfo.level + 1, progress=0,blessValue=0 },
										changeEquipEnHanceInfo(EquipType,NewLevelAddProgress),
										player:send(#pk_EquipEnhanceByTypeBack{ result = ?EquipEnhance_Success_Level});
									false->
										case (LevelAddProgress#playerEquipLevelInfo.blessValue + 1) >= EquipEnhanceInfo#equipEnhance.extra_times of
											true->
												NewLevelAddProgress = #playerEquipLevelInfo{ level=LevelAddProgress#playerEquipLevelInfo.level+1,progress= 0,blessValue = 0},
												changeEquipEnHanceInfo(EquipType,NewLevelAddProgress),
												player:send(#pk_EquipEnhanceByTypeBack{ result = ?EquipEnhance_Success_ByBless});
											false->
												NewLevelAddProgress = #playerEquipLevelInfo{ level=LevelAddProgress#playerEquipLevelInfo.level,
																					 progress= LevelAddProgress#playerEquipLevelInfo.progress + 1,
																					 blessValue = LevelAddProgress#playerEquipLevelInfo.blessValue + 1},
												changeEquipEnHanceInfo(EquipType,NewLevelAddProgress),
												player:send(#pk_EquipEnhanceByTypeBack{ result =?EquipEnhance_Success_Progress})
										end
								end;
							false->
								case (LevelAddProgress#playerEquipLevelInfo.blessValue + 1) >= EquipEnhanceInfo#equipEnhance.extra_times of
									true->
										NewLevelAddProgress = #playerEquipLevelInfo{ level=LevelAddProgress#playerEquipLevelInfo.level+1,progress= 0,blessValue = 0},
										changeEquipEnHanceInfo(EquipType,NewLevelAddProgress),
										player:send(#pk_EquipEnhanceByTypeBack{ result = ?EquipEnhance_Success_ByBless});
									false->
										NewLevelAddProgress = #playerEquipLevelInfo{ level=LevelAddProgress#playerEquipLevelInfo.level , progress=0,
																					 blessValue = LevelAddProgress#playerEquipLevelInfo.blessValue + 1 },
										changeEquipEnHanceInfo(EquipType,NewLevelAddProgress),
										player:send(#pk_EquipEnhanceByTypeBack{ result = ?EquipEnhance_Fail_Random})
								end
						end,
						%%根据结果来写log或者全服通告
						case NewLevelAddProgress#playerEquipLevelInfo.level > LevelAddProgress#playerEquipLevelInfo.level of
							true->
								PlayerName = player:getPlayerProperty( player:getCurPlayerID(), #player.name ),
								TypeName = equipment:getEquipType(EquipType),
								%%是否满足全服通告条件
								case NewLevelAddProgress#playerEquipLevelInfo.level of
									?STRENGTHEN_15->
										Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_STRENGTHEN_15, [PlayerName, TypeName]),
										put("WorldBrodcaseString",Str);	
									?STRENGTHEN_19->
										Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_STRENGTHEN_19, [PlayerName, TypeName]),
										put("WorldBrodcaseString",Str);
									?STRENGTHEN_20->
										Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_STRENGTHEN_20, [PlayerName, TypeName]),
										put("WorldBrodcaseString",Str);
									_->
										ok
								end,
								case BrodcaseString = get("WorldBrodcaseString") of
									false->	ok;
									undefined->	ok;
									_->	systemMessage:sendSysMsgToAllPlayer(BrodcaseString),
										put("WorldBrodcaseString",false)
								end,
								%% 写强化物品LOG
								ParamLog = #strengthen_param{equiptype = EquipType,
															 level = LevelAddProgress#playerEquipLevelInfo.level,
															 result = 1,
															 decitem = EquipEnhanceInfo#equipEnhance.enhanceItem,
															 number = EquipEnhanceInfo#equipEnhance.itemMunber,
															 money_b = EquipEnhanceInfo#equipEnhance.enhanceCost},
								logdbProcess:write_log_player_event(?EVENT_ITEM_STRENGTHEN,ParamLog,PlayerBase);
							false->
								ParamLog = #strengthen_param{equiptype = EquipType,
															 level = LevelAddProgress#playerEquipLevelInfo.level,
															 result = 0, 
															 decitem = EquipEnhanceInfo#equipEnhance.enhanceItem,
															 number = EquipEnhanceInfo#equipEnhance.itemMunber,
															 money_b = EquipEnhanceInfo#equipEnhance.enhanceCost},
								logdbProcess:write_log_player_event(?EVENT_ITEM_STRENGTHEN,ParamLog,PlayerBase)
						end,
						getPlayerEquipEnHanceInfoByType(EquipType)
				end;
			false->
				player:send(#pk_EquipEnhanceByTypeBack{ result = ?EquipEnhance_Fail_MaxLevel}),
				throw(-1)
		end
	catch
		_->ok
	end.

%%一键强化时的循环强化
enHance( EquipType,CurTimes)->
	try
		PlayerBase = player:getCurPlayerRecord(),

		LevelAddProgress = getPlayerEquipEnhanceByType(EquipType),
		EquipEnhanceInfo = getequipEnhancePropertyByLevel(LevelAddProgress#playerEquipLevelInfo.level+1),
	
		case random:uniform(10000) =< EquipEnhanceInfo#equipEnhance.enhanceRate of
			true->
				case LevelAddProgress#playerEquipLevelInfo.progress + 1 >= EquipEnhanceInfo#equipEnhance.times of
					true->
						NewLevelAddProgress = #playerEquipLevelInfo{ level=LevelAddProgress#playerEquipLevelInfo.level + 1, progress=0,blessValue = 0 },
						changeEquipEnHanceInfo(EquipType,NewLevelAddProgress),
						
						NeedItemCount = EquipEnhanceInfo#equipEnhance.itemMunber * CurTimes,
						NeedMoneyCount = EquipEnhanceInfo#equipEnhance.enhanceCost * CurTimes,
						
						CanDecItemResult = playerItems:canDecItemInBag(?Item_Location_Bag, EquipEnhanceInfo#equipEnhance.enhanceItem, NeedItemCount, "all" ),
						[_CanDecItem|DecItemData] = CanDecItemResult,
						playerItems:decItemInBag( DecItemData, ?Destroy_Item_Reson_EquipEnHance ),
						ParamTuple = #token_param{changetype = ?Money_Change_EquipEnHance,param1=EquipType},
						playerMoney:usePlayerBindedMoney( NeedMoneyCount, ?Money_Change_EquipEnHance, ParamTuple),
						
						player:send(#pk_EquipOnceEnhanceByTypeBack{ result = ?EquipOnceEnhance_Success_Level ,times = CurTimes,itemnumber = NeedItemCount,money =NeedMoneyCount}),
						getPlayerEquipEnHanceInfoByType(EquipType),
						
						PlayerName = player:getPlayerProperty( player:getCurPlayerID(), #player.name ),
						TypeName = equipment:getEquipType(EquipType),
						%%是否满足全服通告条件
						case NewLevelAddProgress#playerEquipLevelInfo.level of
							?STRENGTHEN_15->
								Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_STRENGTHEN_15, [PlayerName, TypeName]),
								put("WorldBrodcaseString",Str);	
							?STRENGTHEN_19->
								Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_STRENGTHEN_19, [PlayerName, TypeName]),
								put("WorldBrodcaseString",Str);
							?STRENGTHEN_20->
								Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_STRENGTHEN_20, [PlayerName, TypeName]),
								put("WorldBrodcaseString",Str);
							_->
								ok
						end,
						
						case BrodcaseString = get("WorldBrodcaseString") of
							false->	ok;
							undefined->	ok;
							_->	systemMessage:sendSysMsgToAllPlayer(BrodcaseString),
								put("WorldBrodcaseString",false)
						end,
						
						%% 写强化物品LOG
						ParamLog = #strengall_param{equiptype = EquipType,
													 level = LevelAddProgress#playerEquipLevelInfo.level,
													 result = 1,
													 decitem = EquipEnhanceInfo#equipEnhance.enhanceItem,
													 number = EquipEnhanceInfo#equipEnhance.itemMunber*CurTimes,
													 money_b = EquipEnhanceInfo#equipEnhance.enhanceCost*CurTimes},										
						logdbProcess:write_log_player_event(?EVENT_ITEM_STRANGALL,ParamLog,PlayerBase),
						throw(-1);
					false->
						case (LevelAddProgress#playerEquipLevelInfo.blessValue + 1) >= EquipEnhanceInfo#equipEnhance.extra_times of
							true->
								NewLevelAddProgress = #playerEquipLevelInfo{ level=LevelAddProgress#playerEquipLevelInfo.level+1,progress= 0,blessValue = 0},
								changeEquipEnHanceInfo(EquipType,NewLevelAddProgress),
								
								NeedItemCount = EquipEnhanceInfo#equipEnhance.itemMunber * CurTimes,
								NeedMoneyCount = EquipEnhanceInfo#equipEnhance.enhanceCost * CurTimes,
								CanDecItemResult = playerItems:canDecItemInBag(?Item_Location_Bag, EquipEnhanceInfo#equipEnhance.enhanceItem, NeedItemCount, "all" ),
								[_CanDecItem|DecItemData] = CanDecItemResult,
								playerItems:decItemInBag( DecItemData, ?Destroy_Item_Reson_EquipEnHance ),
								ParamTuple = #token_param{changetype = ?Money_Change_EquipEnHance,param1=EquipType},
								playerMoney:usePlayerBindedMoney( NeedMoneyCount, ?Money_Change_EquipEnHance, ParamTuple),
						
								player:send(#pk_EquipOnceEnhanceByTypeBack{ result = ?EquipOnceEnhance_Success_ByBless ,times = CurTimes,itemnumber = NeedItemCount,money =NeedMoneyCount}),
								getPlayerEquipEnHanceInfoByType(EquipType),
								
								PlayerName = player:getPlayerProperty( player:getCurPlayerID(), #player.name ),
								TypeName = equipment:getEquipType(EquipType),
								%% 是否满足全服通告条件
								case NewLevelAddProgress#playerEquipLevelInfo.level of
									?STRENGTHEN_15->
										Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_STRENGTHEN_15, [PlayerName, TypeName]),
										put("WorldBrodcaseString",Str);
									?STRENGTHEN_19->
										Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_STRENGTHEN_19, [PlayerName, TypeName]),
										put("WorldBrodcaseString",Str);
									?STRENGTHEN_20->
										Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_STRENGTHEN_20, [PlayerName, TypeName]),
										put("WorldBrodcaseString",Str);
									_->
										ok
								end,
								
								case BrodcaseString = get("WorldBrodcaseString") of
									false->	ok;
									undefined->	ok;
									_->	systemMessage:sendSysMsgToAllPlayer(BrodcaseString),
										put("WorldBrodcaseString",false)
								end,
								
								%% 写强化物品LOG
								ParamLog = #strengall_param{equiptype = EquipType,
															level = LevelAddProgress#playerEquipLevelInfo.level,
															result = 1,
															decitem = EquipEnhanceInfo#equipEnhance.enhanceItem,
															number = EquipEnhanceInfo#equipEnhance.itemMunber*CurTimes,
															money_b = EquipEnhanceInfo#equipEnhance.enhanceCost*CurTimes},
								logdbProcess:write_log_player_event(?EVENT_ITEM_STRANGALL,ParamLog,PlayerBase),
								throw(-1);
							false->
								NewLevelAddProgress = #playerEquipLevelInfo{ level=LevelAddProgress#playerEquipLevelInfo.level, 
																			 progress= LevelAddProgress#playerEquipLevelInfo.progress + 1,
																			 blessValue = LevelAddProgress#playerEquipLevelInfo.blessValue + 1},
								onceEquipEnHanceSaveInfoToEts(EquipType,NewLevelAddProgress),
								ifenHance( EquipType,CurTimes)
						end
				end;
			false->
				case (LevelAddProgress#playerEquipLevelInfo.blessValue + 1) >= EquipEnhanceInfo#equipEnhance.extra_times of
					true->
						NewLevelAddProgress = #playerEquipLevelInfo{ level=LevelAddProgress#playerEquipLevelInfo.level+1,progress= 0,blessValue = 0},
						changeEquipEnHanceInfo(EquipType,NewLevelAddProgress),
						
						NeedItemCount = EquipEnhanceInfo#equipEnhance.itemMunber * CurTimes,
						NeedMoneyCount = EquipEnhanceInfo#equipEnhance.enhanceCost * CurTimes,
						CanDecItemResult = playerItems:canDecItemInBag(?Item_Location_Bag, EquipEnhanceInfo#equipEnhance.enhanceItem, NeedItemCount, "all" ),
						[_CanDecItem|DecItemData] = CanDecItemResult,
						playerItems:decItemInBag( DecItemData, ?Destroy_Item_Reson_EquipEnHance ),
						ParamTuple = #token_param{changetype = ?Money_Change_EquipEnHance,param1=EquipType},
						playerMoney:usePlayerBindedMoney( NeedMoneyCount, ?Money_Change_EquipEnHance, ParamTuple),
						
						player:send(#pk_EquipOnceEnhanceByTypeBack{result =?EquipOnceEnhance_Success_ByBless ,times = CurTimes,itemnumber = NeedItemCount,money =NeedMoneyCount}),
						getPlayerEquipEnHanceInfoByType(EquipType),
						
						PlayerName = player:getPlayerProperty( player:getCurPlayerID(), #player.name ),
						TypeName = equipment:getEquipType(EquipType),
						
						%% 是否满足全服通告条件
						case NewLevelAddProgress#playerEquipLevelInfo.level of
							?STRENGTHEN_15->
								Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_STRENGTHEN_15, [PlayerName, TypeName]),
								put("WorldBrodcaseString",Str);
							?STRENGTHEN_19->
								Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_STRENGTHEN_19, [PlayerName, TypeName]),
								put("WorldBrodcaseString",Str);
							?STRENGTHEN_20->
								Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_STRENGTHEN_20, [PlayerName, TypeName]),
								put("WorldBrodcaseString",Str);
							_->
								ok
						end,
						case BrodcaseString = get("WorldBrodcaseString") of
							false->	ok;
							undefined->	ok;
							_->	systemMessage:sendSysMsgToAllPlayer(BrodcaseString),
								put("WorldBrodcaseString",false)
						end,
						
						%% 写强化物品LOG
						ParamLog = #strengall_param{equiptype = EquipType,
													level = LevelAddProgress#playerEquipLevelInfo.level,
													result = 1,
													decitem = EquipEnhanceInfo#equipEnhance.enhanceItem,
													number = EquipEnhanceInfo#equipEnhance.itemMunber*CurTimes,
													money_b = EquipEnhanceInfo#equipEnhance.enhanceCost*CurTimes},
						logdbProcess:write_log_player_event(?EVENT_ITEM_STRANGALL,ParamLog,PlayerBase),
						throw(-1);
					false->
						NewLevelAddProgress = #playerEquipLevelInfo{ level=LevelAddProgress#playerEquipLevelInfo.level , progress=0,
																    blessValue = LevelAddProgress#playerEquipLevelInfo.blessValue + 1},
						onceEquipEnHanceSaveInfoToEts(EquipType,NewLevelAddProgress),
						ifenHance( EquipType,CurTimes)
				end
		end
	catch
		_->ok
	end.

%%一键强化时的循环判断
ifenHance( EquipType,CurTimes)->
	try
		LevelAddProgress = getPlayerEquipEnhanceByType(EquipType),
		EquipEnhanceInfo = getequipEnhancePropertyByLevel(LevelAddProgress#playerEquipLevelInfo.level+1),
		CanDecItemCount = get("OnceEnHance_CanDecItem_Count"),
		CanDecMoney_Count = get("OnceEnHance_CanDecMoney_Count"),
		
		NextNeedItemCount = EquipEnhanceInfo#equipEnhance.itemMunber * (CurTimes+1),
		OldNeedItemCount = EquipEnhanceInfo#equipEnhance.itemMunber * CurTimes,
		
		NextNeedMoneyCount = EquipEnhanceInfo#equipEnhance.enhanceCost * (CurTimes+1),
		OldNeedMoneyCount = EquipEnhanceInfo#equipEnhance.enhanceCost * CurTimes,
		
		PlayerBase = player:getCurPlayerRecord(),
		ParamLog = #strengall_param{equiptype = EquipType,
									 level = LevelAddProgress#playerEquipLevelInfo.level,
									 result = 0,
									 decitem = EquipEnhanceInfo#equipEnhance.enhanceItem,
									 number = EquipEnhanceInfo#equipEnhance.itemMunber*CurTimes,
									 money_b = EquipEnhanceInfo#equipEnhance.enhanceCost*CurTimes},	
		
		case CanDecItemCount >= NextNeedItemCount  of
			true->ok;
			false->	
				CanDecItemResult = playerItems:canDecItemInBag(?Item_Location_Bag, EquipEnhanceInfo#equipEnhance.enhanceItem, OldNeedItemCount , "all" ),
				[_CanDecItem|DecItemData] = CanDecItemResult,
				playerItems:decItemInBag( DecItemData, ?Destroy_Item_Reson_EquipEnHance ),
				ParamTuple = #token_param{changetype = ?Money_Change_EquipEnHance,param1=EquipType},				
				playerMoney:usePlayerBindedMoney( OldNeedMoneyCount, ?Money_Change_EquipEnHance, ParamTuple),
				changeEquipEnHanceInfo(EquipType,LevelAddProgress),
				player:send(#pk_EquipOnceEnhanceByTypeBack{ result =?EquipOnceEnhance_Fail_NotEnough_Item ,times = CurTimes,itemnumber = OldNeedItemCount ,money =OldNeedMoneyCount}),
				getPlayerEquipEnHanceInfoByType(EquipType),
				throw({-1,ParamLog,PlayerBase})
		end,
		
		case CanDecMoney_Count >= NextNeedMoneyCount  of
			true->
				ok;
			false->
				CanDecItemResult2 = playerItems:canDecItemInBag(?Item_Location_Bag, EquipEnhanceInfo#equipEnhance.enhanceItem, OldNeedItemCount, "all" ),
				[_CanDecItem2|DecItemData2] = CanDecItemResult2,
				playerItems:decItemInBag( DecItemData2, ?Destroy_Item_Reson_EquipEnHance ),
				ParamTuple2 = #token_param{changetype = ?Money_Change_EquipEnHance,param1=EquipType},
				playerMoney:usePlayerBindedMoney( OldNeedMoneyCount, ?Money_Change_EquipEnHance, ParamTuple2),
				changeEquipEnHanceInfo(EquipType,LevelAddProgress),
				player:send(#pk_EquipOnceEnhanceByTypeBack{ result =?EquipOnceEnhance_Fail_NotEnough_Money  ,times = CurTimes,itemnumber = OldNeedItemCount ,money =OldNeedMoneyCount}),
				getPlayerEquipEnHanceInfoByType(EquipType),
				throw({-1,ParamLog,PlayerBase})
		end,
		enHance (EquipType,CurTimes+1)
	catch
		{-1,Log,Base}->
			logdbProcess:write_log_player_event(?EVENT_ITEM_STRANGALL,Log,Base);
		_->ok
	end.

%%点击一键强化
playerEquipOnceEnHance(PlayerID, EquipType )->
	try
		CurTimes=0,
		put("OnceEnHance_CanDecItem_Count",0),
		put("OnceEnHance_CanDecMoney_Count",0),
		
		LevelAddProgress = getPlayerEquipEnhanceByType(EquipType),
		case LevelAddProgress#playerEquipLevelInfo.level<?Equip_Strengthen_MaxLevel of
			true->
				EquipEnhanceInfo = getequipEnhancePropertyByLevel(LevelAddProgress#playerEquipLevelInfo.level+1),
				case EquipEnhanceInfo of
					undefined->throw(-1);
					_->
						CanDecItemCount  = playerItems:getItemCountByItemData(?Item_Location_Bag, EquipEnhanceInfo#equipEnhance.enhanceItem, "all"),
						case CanDecItemCount >= EquipEnhanceInfo#equipEnhance.itemMunber of
							true->
								put("OnceEnHance_CanDecItem_Count",CanDecItemCount),
								ok;
							false->
								player:send(#pk_EquipEnhanceByTypeBack{ result = ?EquipEnhance_Fail_NotEnough_Item }),
								throw(-1)
						end,
						
						
						CanDecMoney = player:getPlayerProperty(PlayerID, #player.money),
						CanDecMoneyBinded = player:getPlayerProperty(PlayerID, #player.moneyBinded),
						CanDecMoney_Count = CanDecMoney + CanDecMoneyBinded,
					
						case CanDecMoney_Count >= EquipEnhanceInfo#equipEnhance.enhanceCost of
							true->
								put("OnceEnHance_CanDecMoney_Count",CanDecMoney_Count),
								ok;
							false->
								player:send(#pk_EquipEnhanceByTypeBack{ result = ?EquipEnhance_Fail_NotEnough_Money}),
								throw(-1)
						end,
						enHance (EquipType,CurTimes+1)
				end;
			false->
					player:send(#pk_EquipEnhanceByTypeBack{ result = ?EquipEnhance_Fail_MaxLevel}),
					throw(-1)
		end
	catch
		_->ok
	end.
	
  
%%-----------------------------------------------------------------装备升品-----------------------------------------------------
%%根据物品id和品质等级返回其升品所需要的游戏币
getQualityUPNeedMoney(EquipID,QualityLevel)->
	QualityUPNeedMoney = getEquipwashupMoneyByEquipID(EquipID),
	case QualityLevel of
		?Equip_Quality_White->
			QualityUPNeedMoney#equipwashupmoney.upgrade_white;
		?Equip_Quality_Green->
			QualityUPNeedMoney#equipwashupmoney.upgrade_green;
		?Equip_Quality_Blue->
			QualityUPNeedMoney#equipwashupmoney.upgrade_blue;
		?Equip_Quality_Purple->
			QualityUPNeedMoney#equipwashupmoney.upgrade_pur;
		?Equip_Quality_Orange->
			QualityUPNeedMoney#equipwashupmoney.upgrade_orange;
		?Equip_Quality_Red->
			QualityUPNeedMoney#equipwashupmoney.upgrade_red
	end.

%%返回玩家当前位置装备上的装备的品质	
getPlayerEquipQuality(EquipType)->
	try
		Record = equipment:getPlayerEquipedEquipInfo( EquipType ),
		case Record of
		{}->throw(-1);
		_->
			player:send(#pk_GetPlayerEquipQualityByTypeBack{ type =EquipType ,quality = Record#playerEquipItem.quality})
		end
	catch
		_->ok
	end.

%%根据装备类型，读取附加属性权重表，随机生成附加属性类型
getNewPropertyTypeByEquipType(EquipType)->
	try
		PropertyTypeWeightInfo = getEquipqualityweightByEquipType(EquipType),
		PropertyArray = PropertyTypeWeightInfo#propertyWeightCfg.propertyArray,
		%%求随机值
		Value =  PropertyTypeWeightInfo#propertyWeightCfg.ratetotal,
		RandomValue = random:uniform( Value ),
		put("Random_Value",RandomValue),
		MyFunc = fun( Index )->
						 PropertyValue = array:get(Index-1, PropertyArray),
						 OldValue = get("Random_Value"),
						 case  OldValue >=PropertyValue#weightExtern.value of
							 true->
								 NewValue = OldValue -PropertyValue#weightExtern.value,
								 put("Random_Value",NewValue);
							 false->
								 %%在此检查新随机的属性是不是已经有了的，

								 OldPropertyType_Array = get("add-On_PropertyType_Array"), 
								 NewPropertyType = PropertyValue#weightExtern.propertyType*2 + PropertyValue#weightExtern.fixOrPercent,
								 MyFunc = fun( Index )->
												  OldPropertyType = array:get(Index-1,OldPropertyType_Array),
												  case OldPropertyType =:= NewPropertyType of
													  true->
														   throw(-1);
													  false->
														  ok
												  end
										  end,
								 common:for( 1, ?Equip_Quality_count-1, MyFunc),
								 throw(PropertyValue)
						 end
				 end,
		common:for( 1, ?property_count*2, MyFunc)
	catch
		Return->
				case Return =:= -1 of
					true->getNewPropertyTypeByEquipType(EquipType);
					false->Return
				end
end.

		
%%根据装备部位，读表，计算生成一条附加属性，
getNewPropertyByTypeAddQuality(PlayerEquip,QualityLevel)->
	try	
		PropertyTypeInfo = getNewPropertyTypeByEquipType(PlayerEquip#playerEquipItem.type),
		put("New_PropertyTypeInfo",PropertyTypeInfo),
		EquipIteminfo = equipment:getEquipItemById( PlayerEquip#playerEquipItem.equipid ),
		PropertypeIndex = PropertyTypeInfo#weightExtern.propertyType * 2 + PropertyTypeInfo#weightExtern.fixOrPercent,

		%%根据物品激活等级区间和范围表得出范围
		PropertyValueSizeInfo = getEquipAttributeByEquipLevel((EquipIteminfo#equipitem.activeLevel div 10)),
		PropertyValueSizeArray = PropertyValueSizeInfo#propertyValueSizeCfg.propertyArray,
		ValueSizeExtern = array:get(PropertypeIndex,PropertyValueSizeArray),
		
		%%根据品质等级和提升表得出提升率
		PropertyAddValueInfo = getEquipQualityqualityfactorByQualityLevel(QualityLevel),
		PropertyAddValueArray = PropertyAddValueInfo#propertyAddValueCfg.propertyArray,
		UPCoefficient = array:get(PropertypeIndex,PropertyAddValueArray),						
		
		MaxValue = ValueSizeExtern#valueSizeExtern.maxValue,
		MinValue = ValueSizeExtern#valueSizeExtern.minValue,
		AbsoluteValue =  UPCoefficient#propertyAddValueExtern.absoluteValue,	%%相对于生成附加属性时的值，当前品质下的成长系数

		case MaxValue =:= MinValue of
			true->
				 throw(MinValue  * AbsoluteValue div 10000 );
			false->
				ValueBoot = MaxValue - MinValue,
				case ValueBoot>0 of
					true->
						RandomValue = random:uniform( ValueBoot );
					false->
						RandomValue =  -random:uniform( erlang:abs(ValueBoot) )
				end,
				Value1 = RandomValue + MinValue,
				NewRandomValue = Value1 * AbsoluteValue  div 10000,
				Mindivisor = ValueSizeExtern#valueSizeExtern.mindivisor,
				NewRandomValue1 = NewRandomValue div Mindivisor * Mindivisor,
				throw(NewRandomValue1)
		end
	catch
		Value->
			case Value =:= 0 of
				true->
					getNewPropertyByTypeAddQuality(PlayerEquip,QualityLevel);
				false->
					{get("New_PropertyTypeInfo"),Value}
			end
	end.


getNewPropertyMaxValueByInfoAndQuality(PropertyTypeInfo,ActiveLevel,QualityLevel)->	
	%%根据物品激活等级区间和范围表得出范围
	PropertyValueSizeInfo = getEquipAttributeByEquipLevel((ActiveLevel div 10)),
	PropertyValueSizeArray = PropertyValueSizeInfo#propertyValueSizeCfg.propertyArray,
	ValueSizeExtern = array:get(PropertyTypeInfo#weightExtern.propertyType * 2 + PropertyTypeInfo#weightExtern.fixOrPercent,PropertyValueSizeArray),
	
	%%根据品质等级和提升表得出提升率
	PropertyAddValueInfo = getEquipQualityqualityfactorByQualityLevel(QualityLevel),
	PropertyAddValueArray = PropertyAddValueInfo#propertyAddValueCfg.propertyArray,
	UPCoefficient = array:get(PropertyTypeInfo#weightExtern.propertyType * 2 + PropertyTypeInfo#weightExtern.fixOrPercent,PropertyAddValueArray),						
	
	ValueSizeExtern#valueSizeExtern.maxValue  * UPCoefficient#propertyAddValueExtern.absoluteValue  div 10000.

getNewPropertyMinValueByInfoAndQuality(PropertyTypeInfo,ActiveLevel,QualityLevel)->	
	%%根据物品激活等级区间和范围表得出范围
	PropertyValueSizeInfo = getEquipAttributeByEquipLevel((ActiveLevel div 10)),
	PropertyValueSizeArray = PropertyValueSizeInfo#propertyValueSizeCfg.propertyArray,
	ValueSizeExtern = array:get(PropertyTypeInfo#weightExtern.propertyType * 2 + PropertyTypeInfo#weightExtern.fixOrPercent,PropertyValueSizeArray),
	
	%%根据品质等级和提升表得出提升率
	PropertyAddValueInfo = getEquipQualityqualityfactorByQualityLevel(QualityLevel),
	PropertyAddValueArray = PropertyAddValueInfo#propertyAddValueCfg.propertyArray,
	UPCoefficient = array:get(PropertyTypeInfo#weightExtern.propertyType * 2 + PropertyTypeInfo#weightExtern.fixOrPercent,PropertyAddValueArray),						
	
	ValueSizeExtern#valueSizeExtern.minValue  * UPCoefficient#propertyAddValueExtern.absoluteValue  div 10000.

		

%%改变附加属性
changePlayerEquipItem(EquipInfo)->
	try
		PropertyValueArray1 = EquipInfo#playerEquipItem.propertyTypeValueArray,
		put("PropertyValue_Array",PropertyValueArray1),
		MyFunc = fun( Index )->
						 PropertyValueArray = get("PropertyValue_Array"),
						 PropertyType = array:get(Index-1,PropertyValueArray),
						 case PropertyType#propertyTypeValue.value =:= 0 of
							 true->
								 %%根据配置表随即生成一个附加属性，并改变数组
 								{NewPropertyTypeInfo,NewPropertyValue} = getNewPropertyByTypeAddQuality(EquipInfo,EquipInfo#playerEquipItem.quality+1),
 								 NewProperty = #propertyTypeValue{type=NewPropertyTypeInfo#weightExtern.propertyType,fixOrPercent=NewPropertyTypeInfo#weightExtern.fixOrPercent, value=NewPropertyValue },
								 NewPropertyValueArray =array:set(Index-1,NewProperty,PropertyValueArray),
								
																
								%%判断是否是最大值，安排全服通告
								EquipIteminfo = equipment:getEquipItemById( EquipInfo#playerEquipItem.equipid ),
								MaxPropertyValue = getNewPropertyMaxValueByInfoAndQuality(NewPropertyTypeInfo,
																							EquipIteminfo#equipitem.activeLevel,
																							EquipInfo#playerEquipItem.quality+1),
								case NewPropertyValue =:= MaxPropertyValue of
									true->
										PlayerName = player:getPlayerProperty( player:getCurPlayerID(), #player.name ),
										BrodcaseString = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_QUALITYUP_CPROPERTY_RED, [PlayerName, EquipInfo#playerEquipItem.id,EquipInfo#playerEquipItem.quality + 1]),
										systemMessage:sendSysMsgToAllPlayer(BrodcaseString);
									false->
										ok
									end,
								throw(NewPropertyValueArray);
							 false->
								 %%根据品质提升表，改变已有的附加属性值，并改变数组
								 OldPropertyType_Array = get("add-On_PropertyType_Array"), 
								 PropertyTypeIndex = PropertyType#propertyTypeValue.type * 2 + PropertyType#propertyTypeValue.fixOrPercent,
								 NewPropertyType_Array = array:set(Index-1,PropertyTypeIndex,OldPropertyType_Array),
								 put("add-On_PropertyType_Array",NewPropertyType_Array),
								
								 PropertyAddValueInfo = getEquipQualityqualityfactorByQualityLevel(EquipInfo#playerEquipItem.quality+1),
								 PropertyAddValueArray = PropertyAddValueInfo#propertyAddValueCfg.propertyArray,
								 UPCoefficient = array:get(PropertyTypeIndex,PropertyAddValueArray),	
								 
								 OldPropertyAddValueInfo = getEquipQualityqualityfactorByQualityLevel(EquipInfo#playerEquipItem.quality),
								 OldPropertyAddValueArray = OldPropertyAddValueInfo#propertyAddValueCfg.propertyArray,
								 OldUPCoefficient = array:get(PropertyTypeIndex,OldPropertyAddValueArray),	

								 %%判断现在的属性是不是最大属性
								 EquipIteminfo = equipment:getEquipItemById( EquipInfo#playerEquipItem.equipid ),
								 NewPro = #weightExtern{propertyType=PropertyType#propertyTypeValue.type,
															fixOrPercent=PropertyType#propertyTypeValue.fixOrPercent,
															 value=PropertyType#propertyTypeValue.value},
								 MaxPropertyValue = getNewPropertyMaxValueByInfoAndQuality(NewPro,
																							EquipIteminfo#equipitem.activeLevel,
																							EquipInfo#playerEquipItem.quality),
								 case PropertyType#propertyTypeValue.value =:= MaxPropertyValue of
									 true->
										 NewValue = getNewPropertyMaxValueByInfoAndQuality(NewPro,
																							EquipIteminfo#equipitem.activeLevel,
																							EquipInfo#playerEquipItem.quality+1),
										 ok;
									 false->
										 RandomValue = PropertyType#propertyTypeValue.value * 10000 / OldUPCoefficient#propertyAddValueExtern.absoluteValue, 
										 FloatValue = RandomValue * UPCoefficient#propertyAddValueExtern.absoluteValue / 10000,
										 NewValue = erlang:trunc(FloatValue),
										 ok
								 end,
							
								 NewProperty = #propertyTypeValue{type=PropertyType#propertyTypeValue.type,fixOrPercent=PropertyType#propertyTypeValue.fixOrPercent, value=NewValue},
								 NewPropertyValueArray = array:set(Index-1,NewProperty,PropertyValueArray),
								 put("PropertyValue_Array",NewPropertyValueArray),
								 ok
						 end
				 end,
		common:for( 1, ?Equip_Quality_count-1, MyFunc)
	catch
		Return->Return
end.
	
%%升品
playerEquipQualityUP(EquipType)->
	try
		Equip = equipment:getPlayerEquipedEquipInfo( EquipType ),
		case Equip of
		{}->throw(-1);
		_->
			case Equip#playerEquipItem.quality =:= ?Equip_Quality_Red of
				true->
					player:send(#pk_EquipQualityUPByTypeBack{ result = ?EquipQuality_Fail_MaxQuality}),
					throw(-1);
				false->
					ok
			end,
			%%判断金钱
			NeedMoney = getQualityUPNeedMoney(Equip#playerEquipItem.equipid,Equip#playerEquipItem.quality+1),
			case playerMoney:canUsePlayerBindedMoney(NeedMoney) of
				true->
					ok;
				false->
					player:send(#pk_EquipQualityUPByTypeBack{ result = ?EquipQuality_Fail_NotEnough_Money}),
					throw(-1)
			end,
			QualityUPItemNeedDate = getEquipActiveItemNeedById(Equip#playerEquipItem.equipid),
			case QualityUPItemNeedDate of
				{}->throw(-1);
				_->ok
			end,
			ItemNeedArray = QualityUPItemNeedDate#equipmentActiveItemNeed.itemNeedArray,
			QualityItemNeedArray = array:get(Equip#playerEquipItem.quality+1,ItemNeedArray),	
			%%判断材料
			case QualityItemNeedArray#itemNeed.itemID_1 =:= 0 of
				true->
					ok;
				false->
					CanDecItemCount1  = playerItems:getItemCountByItemData(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_1, "all"),
					case CanDecItemCount1 >= QualityItemNeedArray#itemNeed.itemNum_1 of
						true->
							CanDecItemResult1 = playerItems:canDecItemInBag(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_1,QualityItemNeedArray#itemNeed.itemNum_1, "all" ),
							[CanDecItem1|DecItemData1] = CanDecItemResult1,
							put( "QualityUPPlayerEquipment_DecItemData_1", DecItemData1 );
						false->
							 player:send(#pk_EquipQualityUPByTypeBack{ result = ?EquipQuality_Fail_NotEnough_Item}),
							 throw(-1)
					end
			end,
			case QualityItemNeedArray#itemNeed.itemID_2 =:= 0 of
				true->
					ok;
				false->
					CanDecItemCount2  = playerItems:getItemCountByItemData(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_2, "all"),
					case CanDecItemCount2 >= QualityItemNeedArray#itemNeed.itemNum_2 of
						true->
							CanDecItemResult2 = playerItems:canDecItemInBag(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_2,QualityItemNeedArray#itemNeed.itemNum_2, "all" ),
							[CanDecItem2|DecItemData2] = CanDecItemResult2,
							put( "QualityUPPlayerEquipment_DecItemData_2", DecItemData2 );
						false->
							player:send(#pk_EquipQualityUPByTypeBack{ result = ?EquipQuality_Fail_NotEnough_Item}),
							throw(-1)
					end
			end,
			case QualityItemNeedArray#itemNeed.itemID_3 =:= 0 of
				true->
					ok;
				false->
					CanDecItemCount3  = playerItems:getItemCountByItemData(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_3, "all"),
					case CanDecItemCount3 >= QualityItemNeedArray#itemNeed.itemNum_3 of
						true->
							CanDecItemResult3 = playerItems:canDecItemInBag(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_3,QualityItemNeedArray#itemNeed.itemNum_3, "all" ),
							[CanDecItem3|DecItemData3] = CanDecItemResult3,
							put( "QualityUPPlayerEquipment_DecItemData_3", DecItemData3 );
						false->
							player:send(#pk_EquipQualityUPByTypeBack{ result = ?EquipQuality_Fail_NotEnough_Item}),
							throw(-1)
					end
			end,
			case QualityItemNeedArray#itemNeed.itemID_4 =:= 0 of
				true->
					ok;
				false->
					CanDecItemCount4  = playerItems:getItemCountByItemData(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_4, "all"),
					case CanDecItemCount4 >= QualityItemNeedArray#itemNeed.itemNum_4 of
						true->
							CanDecItemResult4 = playerItems:canDecItemInBag(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_4,QualityItemNeedArray#itemNeed.itemNum_4, "all" ),
							[CanDecItem4|DecItemData4] = CanDecItemResult4,
							put( "QualityUPPlayerEquipment_DecItemData_4", DecItemData4 );
						false->
							player:send(#pk_EquipQualityUPByTypeBack{ result = ?EquipQuality_Fail_NotEnough_Item}),
							throw(-1)
					end
			end,
			%%判断荣誉和声望值
			CreditAddHonor = equipment:getEquipItemById( Equip#playerEquipItem.equipid ),
			CreditAddHonorFactor = getEquipQualityBasalPropertyByQualityLevel(Equip#playerEquipItem.quality+1),
			
			NeedCredit = CreditAddHonor#equipitem.activeCredit * (CreditAddHonorFactor#equipmentquality.credit_Factor  div  10000),
			PlayerCredit = player:getCurPlayerProperty( #player.credit),
			case NeedCredit > PlayerCredit of
				true->
					 player:send(#pk_EquipQualityUPByTypeBack{ result = ?EquipQuality_Fail_NotEnough_Credit}),
					 throw(-1);
				false->ok
			end,
					
			PlayerHonor = player:getCurPlayerProperty( #player.honor),
			NeedHonor = CreditAddHonor#equipitem.activeHonour * (CreditAddHonorFactor#equipmentquality.honor_Factor  div 10000),
			case NeedHonor > PlayerHonor of
				true->
					player:send(#pk_EquipQualityUPByTypeBack{ result = ?EquipQuality_Fail_NotEnough_Honor}),
					throw(-1);
				false->ok
			end,
			
			%%扣除金钱,材料,声望值,荣誉值,
			ParamTuple = #token_param{changetype = ?Money_Change_EquipQualityUP,param1=EquipType},
			playerMoney:usePlayerBindedMoney( NeedMoney, ?Money_Change_EquipQualityUP, ParamTuple),
			case QualityItemNeedArray#itemNeed.itemID_1 > 0 of
				true->playerItems:decItemInBag( get("QualityUPPlayerEquipment_DecItemData_1"), ?Destroy_Item_Reson_EquipQualityUP );
				false->ok
			end,
			case QualityItemNeedArray#itemNeed.itemID_2 > 0 of
				true->playerItems:decItemInBag( get("QualityUPPlayerEquipment_DecItemData_2"), ?Destroy_Item_Reson_EquipQualityUP );
				false->ok
			end,
			case QualityItemNeedArray#itemNeed.itemID_3 > 0 of
				true->playerItems:decItemInBag( get("QualityUPPlayerEquipment_DecItemData_3"), ?Destroy_Item_Reson_EquipQualityUP );
				false->ok
			end,
			case QualityItemNeedArray#itemNeed.itemID_4 > 0 of
				true->playerItems:decItemInBag( get("QualityUPPlayerEquipment_DecItemData_4"), ?Destroy_Item_Reson_EquipQualityUP );
				false->ok
			end,
			
			player:costCurPlayerHonor( NeedHonor, 0),
			%%player:addCurPlayerCredit( -NeedCredit, 0),
			player:costCurPlayerCredit(NeedCredit, 0),
			
			%%升品成功
			etsBaseFunc:changeFiled(equipment:getEquipTable(),Equip#playerEquipItem.id, #playerEquipItem.quality, Equip#playerEquipItem.quality+1),
			%%改变附加属性并保存

			PropertyType_Array = array:new(?Equip_Quality_count - 1 , {default, -1} ),
			put("add-On_PropertyType_Array",PropertyType_Array),
			
			NewPropertyTypeValueArray = changePlayerEquipItem( Equip ),
			etsBaseFunc:changeFiled(equipment:getEquipTable(),Equip#playerEquipItem.id, #playerEquipItem.propertyTypeValueArray,NewPropertyTypeValueArray),
			player:send(#pk_EquipQualityUPByTypeBack{ result = ?EquipQuality_Success}),
			equipment:sendPlayerAllEquip(),
			playerMap:onPlayer_LevelEquipPet_Changed(),
			getPlayerEquipQuality(EquipType),
			
			%% 是否满足全服通告条件
			PlayerName = player:getPlayerProperty( player:getCurPlayerID(), #player.name ),
			TypeName = equipment:getEquipType(EquipType),
			case Equip#playerEquipItem.quality+1 of				
				?Equip_Quality_Red->
					Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_QUALITYUP_RED, [PlayerName, Equip#playerEquipItem.equipid,?Equip_Quality_Red]),
					put("WorldBrodcaseString",Str);
				_->
					ok
			end,				
			
			case BrodcaseString = get("WorldBrodcaseString") of
				false->	ok;
				undefined->	ok;
				_->	systemMessage:sendSysMsgToAllPlayer(BrodcaseString),
					put("WorldBrodcaseString",false)
			end,
			
			
			%% 写品质提升LOG 	
			ParamLog = #qualityup_param{equiptype = EquipType,
									  	quality = Equip#playerEquipItem.quality,
									  	result = 1,
									  	decitem1 = QualityItemNeedArray#itemNeed.itemID_1,
										number1 = QualityItemNeedArray#itemNeed.itemNum_1,
										decitem2 = QualityItemNeedArray#itemNeed.itemID_2,
										number2 = QualityItemNeedArray#itemNeed.itemNum_2,
										decitem3 = QualityItemNeedArray#itemNeed.itemID_3,
										number3 = QualityItemNeedArray#itemNeed.itemNum_3,
										decitem4 = QualityItemNeedArray#itemNeed.itemID_4,
										number4 = QualityItemNeedArray#itemNeed.itemNum_4,
										money_b = NeedMoney},
			
			PlayerBase = player:getCurPlayerRecord(),
			logdbProcess:write_log_player_event(?EVENT_ITEM_QUALITYUP,ParamLog,PlayerBase)
		
		end
	catch
		_->ok
	end.

%%快速升品
playerEquipFastQualityUP( EquipID)->
	try
		Equip = equipment:getPlayerActivedEquip( EquipID ),
		case Equip of
		{}->throw(-1);
		_->
			case Equip#playerEquipItem.quality =:= ?Equip_Quality_Red of
				true->
					player:send(#pk_EquipQualityFastUPByTypeBack{ result = ?EquipQuality_Fail_MaxQuality}),
					throw(-1);
				false->
					ok
			end,
			%%判断金钱
			NeedMoney = getQualityUPNeedMoney(Equip#playerEquipItem.equipid,Equip#playerEquipItem.quality+1),
			case playerMoney:canUsePlayerBindedMoney(NeedMoney) of
				true->
					ok;
				false->
					player:send(#pk_EquipQualityFastUPByTypeBack{ result = ?EquipQuality_Fail_NotEnough_Money}),
					throw(-1)
			end,
			QualityUPItemNeedDate = getEquipActiveItemNeedById(Equip#playerEquipItem.equipid),
			case QualityUPItemNeedDate of
				{}->throw(-1);
				_->ok
			end,
			ItemNeedArray = QualityUPItemNeedDate#equipmentActiveItemNeed.itemNeedArray,
			QualityItemNeedArray = array:get(Equip#playerEquipItem.quality+1,ItemNeedArray),	
			%%判断材料
			case QualityItemNeedArray#itemNeed.itemID_1 =:= 0 of
				true->
					ok;
				false->
					CanDecItemCount1  = playerItems:getItemCountByItemData(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_1, "all"),
					case CanDecItemCount1 >= QualityItemNeedArray#itemNeed.itemNum_1 of
						true->
							CanDecItemResult1 = playerItems:canDecItemInBag(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_1,QualityItemNeedArray#itemNeed.itemNum_1, "all" ),
							[CanDecItem1|DecItemData1] = CanDecItemResult1,
							put( "QualityUPPlayerEquipment_DecItemData_1", DecItemData1 );
						false->
							 player:send(#pk_EquipQualityFastUPByTypeBack{ result = ?EquipQuality_Fail_NotEnough_Item}),
							 throw(-1)
					end
			end,
			case QualityItemNeedArray#itemNeed.itemID_2 =:= 0 of
				true->
					ok;
				false->
					CanDecItemCount2  = playerItems:getItemCountByItemData(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_2, "all"),
					case CanDecItemCount2 >= QualityItemNeedArray#itemNeed.itemNum_2 of
						true->
							CanDecItemResult2 = playerItems:canDecItemInBag(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_2,QualityItemNeedArray#itemNeed.itemNum_2, "all" ),
							[CanDecItem2|DecItemData2] = CanDecItemResult2,
							put( "QualityUPPlayerEquipment_DecItemData_2", DecItemData2 );
						false->
							player:send(#pk_EquipQualityUPByTypeBack{ result = ?EquipQuality_Fail_NotEnough_Item}),
							throw(-1)
					end
			end,
			case QualityItemNeedArray#itemNeed.itemID_3 =:= 0 of
				true->
					ok;
				false->
					CanDecItemCount3  = playerItems:getItemCountByItemData(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_3, "all"),
					case CanDecItemCount3 >= QualityItemNeedArray#itemNeed.itemNum_3 of
						true->
							CanDecItemResult3 = playerItems:canDecItemInBag(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_3,QualityItemNeedArray#itemNeed.itemNum_3, "all" ),
							[CanDecItem3|DecItemData3] = CanDecItemResult3,
							put( "QualityUPPlayerEquipment_DecItemData_3", DecItemData3 );
						false->
							player:send(#pk_EquipQualityFastUPByTypeBack{ result = ?EquipQuality_Fail_NotEnough_Item}),
							throw(-1)
					end
			end,
			case QualityItemNeedArray#itemNeed.itemID_4 =:= 0 of
				true->
					ok;
				false->
					CanDecItemCount4  = playerItems:getItemCountByItemData(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_4, "all"),
					case CanDecItemCount4 >= QualityItemNeedArray#itemNeed.itemNum_4 of
						true->
							CanDecItemResult4 = playerItems:canDecItemInBag(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_4,QualityItemNeedArray#itemNeed.itemNum_4, "all" ),
							[CanDecItem4|DecItemData4] = CanDecItemResult4,
							put( "QualityUPPlayerEquipment_DecItemData_4", DecItemData4 );
						false->
							player:send(#pk_EquipQualityFastUPByTypeBack{ result = ?EquipQuality_Fail_NotEnough_Item}),
							throw(-1)
					end
			end,
			%%判断荣誉和声望值
			CreditAddHonor = equipment:getEquipItemById( Equip#playerEquipItem.equipid ),
			CreditAddHonorFactor = getEquipQualityBasalPropertyByQualityLevel(Equip#playerEquipItem.quality+1),
			
			NeedCredit = CreditAddHonor#equipitem.activeCredit * (CreditAddHonorFactor#equipmentquality.credit_Factor  div  10000),
			PlayerCredit = player:getCurPlayerProperty( #player.credit),
			case NeedCredit > PlayerCredit of
				true->
					 player:send(#pk_EquipQualityFastUPByTypeBack{ result = ?EquipQuality_Fail_NotEnough_Credit}),
					 throw(-1);
				false->ok
			end,
					
			PlayerHonor = player:getCurPlayerProperty( #player.honor),
			NeedHonor = CreditAddHonor#equipitem.activeHonour * (CreditAddHonorFactor#equipmentquality.honor_Factor  div 10000),
			case NeedHonor > PlayerHonor of
				true->
					player:send(#pk_EquipQualityFastUPByTypeBack{ result = ?EquipQuality_Fail_NotEnough_Honor}),
					throw(-1);
				false->ok
			end,
			
			%%扣除金钱,材料,声望值,荣誉值,
			ParamTuple = #token_param{changetype = ?Money_Change_EquipQualityUP,param1=EquipID},
			playerMoney:usePlayerBindedMoney( NeedMoney, ?Money_Change_EquipQualityUP, ParamTuple),
			case QualityItemNeedArray#itemNeed.itemID_1 > 0 of
				true->playerItems:decItemInBag( get("QualityUPPlayerEquipment_DecItemData_1"), ?Destroy_Item_Reson_EquipQualityUP );
				false->ok
			end,
			case QualityItemNeedArray#itemNeed.itemID_2 > 0 of
				true->playerItems:decItemInBag( get("QualityUPPlayerEquipment_DecItemData_2"), ?Destroy_Item_Reson_EquipQualityUP );
				false->ok
			end,
			case QualityItemNeedArray#itemNeed.itemID_3 > 0 of
				true->playerItems:decItemInBag( get("QualityUPPlayerEquipment_DecItemData_3"), ?Destroy_Item_Reson_EquipQualityUP );
				false->ok
			end,
			case QualityItemNeedArray#itemNeed.itemID_4 > 0 of
				true->playerItems:decItemInBag( get("QualityUPPlayerEquipment_DecItemData_4"), ?Destroy_Item_Reson_EquipQualityUP );
				false->ok
			end,
			
			player:costCurPlayerHonor( NeedHonor, 0),
			player:costCurPlayerCredit(NeedCredit, 0),
			
			%%升品成功
			etsBaseFunc:changeFiled(equipment:getEquipTable(),Equip#playerEquipItem.id, #playerEquipItem.quality, Equip#playerEquipItem.quality+1),
			%%改变附加属性并保存

			PropertyType_Array = array:new(?Equip_Quality_count - 1 , {default, -1} ),
			put("add-On_PropertyType_Array",PropertyType_Array),
			
			NewPropertyTypeValueArray = changePlayerEquipItem( Equip ),
			etsBaseFunc:changeFiled(equipment:getEquipTable(),Equip#playerEquipItem.id, #playerEquipItem.propertyTypeValueArray,NewPropertyTypeValueArray),
			equipment:sendPlayerAllEquip(),
			playerMap:onPlayer_LevelEquipPet_Changed(),
			player:send(#pk_EquipQualityFastUPByTypeBack{ result = ?EquipQuality_Success}),
			
			%% 是否满足全服通告条件
			PlayerName = player:getPlayerProperty( player:getCurPlayerID(), #player.name ),
			TypeName = equipment:getEquipType(Equip#playerEquipItem.type),
			case Equip#playerEquipItem.quality+1 of				
				?Equip_Quality_Red->
					Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_QUALITYUP_RED, [PlayerName, Equip#playerEquipItem.equipid,?Equip_Quality_Red]),
					put("WorldBrodcaseString",Str);
				_->
					ok
			end,				
			
			case BrodcaseString = get("WorldBrodcaseString") of
				false->	ok;
				undefined->	ok;
				_->	systemMessage:sendSysMsgToAllPlayer(BrodcaseString),
					put("WorldBrodcaseString",false)
			end,
			
			
			%% 写品质提升LOG 	
			ParamLog = #qualityup_param{equiptype = Equip#playerEquipItem.type,
									  	quality = Equip#playerEquipItem.quality,
									  	result = 1,
									  	decitem1 = QualityItemNeedArray#itemNeed.itemID_1,
										number1 = QualityItemNeedArray#itemNeed.itemNum_1,
										decitem2 = QualityItemNeedArray#itemNeed.itemID_2,
										number2 = QualityItemNeedArray#itemNeed.itemNum_2,
										decitem3 = QualityItemNeedArray#itemNeed.itemID_3,
										number3 = QualityItemNeedArray#itemNeed.itemNum_3,
										decitem4 = QualityItemNeedArray#itemNeed.itemID_4,
										number4 = QualityItemNeedArray#itemNeed.itemNum_4,
										money_b = NeedMoney},
			
			PlayerBase = player:getCurPlayerRecord(),
			logdbProcess:write_log_player_event(?EVENT_ITEM_QUALITYUP,ParamLog,PlayerBase)
		
		end
	catch
		_->ok
	end.

%%-----------------------------------------------------------------装备洗髓-----------------------------------------------------	
%%返回装备的现有属性
getEquipOldPropertyByType(EquipType)->
	PlayerEquip = equipment:getPlayerEquipedEquipInfo( EquipType ),
	case PlayerEquip of
		{}->throw(-1);
		_->
			PropertyTypeValue1 = array:get( 0, PlayerEquip#playerEquipItem.propertyTypeValueArray),
			PropertyTypeValue2 = array:get( 1, PlayerEquip#playerEquipItem.propertyTypeValueArray ),
			PropertyTypeValue3 = array:get( 2, PlayerEquip#playerEquipItem.propertyTypeValueArray ),
			PropertyTypeValue4 = array:get( 3, PlayerEquip#playerEquipItem.propertyTypeValueArray ),
			PropertyTypeValue5 = array:get( 4, PlayerEquip#playerEquipItem.propertyTypeValueArray ),
			player:send(#pk_GetEquipOldPropertyByType{type = EquipType,
													  property1Type =PropertyTypeValue1#propertyTypeValue.type,
													  property1FixOrPercent= PropertyTypeValue1#propertyTypeValue.fixOrPercent,
													  property1Value=PropertyTypeValue1#propertyTypeValue.value,
													  
													  property2Type =PropertyTypeValue2#propertyTypeValue.type,
													  property2FixOrPercent= PropertyTypeValue2#propertyTypeValue.fixOrPercent,
													  property2Value=PropertyTypeValue2#propertyTypeValue.value,
													  
													  property3Type =PropertyTypeValue3#propertyTypeValue.type,
													  property3FixOrPercent= PropertyTypeValue3#propertyTypeValue.fixOrPercent,
													  property3Value=PropertyTypeValue3#propertyTypeValue.value,
													  
													  property4Type =PropertyTypeValue4#propertyTypeValue.type,
													  property4FixOrPercent= PropertyTypeValue4#propertyTypeValue.fixOrPercent,
													  property4Value=PropertyTypeValue4#propertyTypeValue.value,
													  
													  property5Type =PropertyTypeValue5#propertyTypeValue.type,
													  property5FixOrPercent= PropertyTypeValue5#propertyTypeValue.fixOrPercent,
													  property5Value=PropertyTypeValue5#propertyTypeValue.value
											 })
	end.

getMoneyMultipleByPropertyLockNum(LockNum)->
	case LockNum of
		0->
			1;
		1->
			globalSetup:getGlobalSetupValue(#globalSetup.propertyLock_Money1);
		2->
			globalSetup:getGlobalSetupValue(#globalSetup.propertyLock_Money2);
		3->
			globalSetup:getGlobalSetupValue(#globalSetup.propertyLock_Money3);
		4->
			globalSetup:getGlobalSetupValue(#globalSetup.propertyLock_Money4)
	end.

getItemNumMultipleByPropertyLockNum(LockNum)->
	case LockNum of
		0->
			1;
		1->
			globalSetup:getGlobalSetupValue(#globalSetup.propertyLock_itemNum1);
		2->
			globalSetup:getGlobalSetupValue(#globalSetup.propertyLock_itemNum2);
		3->
			globalSetup:getGlobalSetupValue(#globalSetup.propertyLock_itemNum3);
		4->
			globalSetup:getGlobalSetupValue(#globalSetup.propertyLock_itemNum4)
	end.
	
getEquipChangePropertyMoney(EquipID,QualityLevel)->
	QualityUPNeedMoney = getEquipwashupMoneyByEquipID(EquipID),
	case QualityLevel of
		?Equip_Quality_White->
			QualityUPNeedMoney#equipwashupmoney.wash_white;
		?Equip_Quality_Green->
			QualityUPNeedMoney#equipwashupmoney.wash_green;
		?Equip_Quality_Blue->
			QualityUPNeedMoney#equipwashupmoney.wash_blue;
		?Equip_Quality_Purple->
			QualityUPNeedMoney#equipwashupmoney.wash_pur;
		?Equip_Quality_Orange->
			QualityUPNeedMoney#equipwashupmoney.wash_orange;
		?Equip_Quality_Red->
			QualityUPNeedMoney#equipwashupmoney.wash_red
	end.
%%根据要求改变属性，并返回新属性，如，Property1表示第一条属性保持不变
changeEquipPropertyByType(EquipType,Property1,Property2,Property3,Property4,Property5)->
try
	PlayerEquip = equipment:getPlayerEquipedEquipInfo( EquipType ),
	case PlayerEquip of
		{}->throw(-1);
		_->
			%%判断洗髓材料及金钱
			LockNum =PlayerEquip#playerEquipItem.quality - Property1-Property2-Property3-Property4-Property5,
	
			ItemNumMultiple =getItemNumMultipleByPropertyLockNum(LockNum),
			
			NeedItemID = globalSetup:getGlobalSetupValue(#globalSetup.changeProperty_item),
			NeedItemNumber = globalSetup:getGlobalSetupValue(#globalSetup.changeProperty_itemNum)*ItemNumMultiple,
			CanDecItemCount  = playerItems:getItemCountByItemData(?Item_Location_Bag, NeedItemID, "all"),
			case CanDecItemCount >= NeedItemNumber of
				true->ok;
				false->
					player:send(#pk_RequestEquipChangeAddSavePropertyByType{ result = ?EquipChangeProperty_NotEnough_Item}),
					throw(-1)
			end,
			NeedMoney = getEquipChangePropertyMoney(PlayerEquip#playerEquipItem.equipid,PlayerEquip#playerEquipItem.quality),
			NewNeedMoney = getMoneyMultipleByPropertyLockNum(LockNum)*NeedMoney,
			case playerMoney:canUsePlayerBindedMoney(NewNeedMoney) of
				true->
					ok;
				false->
					player:send(#pk_RequestEquipChangeAddSavePropertyByType{ result = ?EquipChangeProperty_NotEnough_Money}),
					throw(-1)
			end,
			ParamTuple = #token_param{changetype = ?Money_Change_EquipQualityUP,param1=EquipType},
			playerMoney:usePlayerBindedMoney( NewNeedMoney, ?Money_Change_EquipQualityUP, ParamTuple),
			CanDecItemResult = playerItems:canDecItemInBag(?Item_Location_Bag,NeedItemID ,NeedItemNumber, "all" ),
			[CanDecItem|DecItemData] = CanDecItemResult,
			playerItems:decItemInBag(DecItemData, ?Destroy_Item_Reson_EquipQualityUP ),

			%%写 洗练 记录
			PlayerBase = player:getCurPlayerRecord(),
			ParamLog = #ceproperty_param{equiptype = EquipType,
										 decitem = globalSetup:getGlobalSetupValue(#globalSetup.changeProperty_item),
										 number = globalSetup:getGlobalSetupValue(#globalSetup.changeProperty_itemNum)*ItemNumMultiple,										
										 money_b = NewNeedMoney},	
			logdbProcess:write_log_player_event(?EVENT_ITEM_CProperty,ParamLog,PlayerBase),

			
			PropertyType_Array = array:new(?Equip_Quality_Red , {default, -1} ),
			put("add-On_PropertyType_Array",PropertyType_Array),
			
			OldPropertyType_Array = PlayerEquip#playerEquipItem.propertyTypeValueArray,
			Biiii = array:size(OldPropertyType_Array),
%% 			%%判断是否有锁定的属性~~把锁定的元素填入数组对应
			case Property1 of
				0->
					PropertyType1 = array:get(0, OldPropertyType_Array),
					PropertyTypeIndex1 = PropertyType1#propertyTypeValue.type * 2 + PropertyType1#propertyTypeValue.fixOrPercent,
					OldPropertyType_Array1 = get("add-On_PropertyType_Array"),
					NewPropertyType_Array1 = array:set(0,PropertyTypeIndex1,OldPropertyType_Array1),
					put("add-On_PropertyType_Array",NewPropertyType_Array1);
				
				1->ok
			end,
			case Property2 of
				0->
					PropertyType2 = array:get(1, OldPropertyType_Array),
					PropertyTypeIndex2 = PropertyType2#propertyTypeValue.type * 2 + PropertyType2#propertyTypeValue.fixOrPercent,
					OldPropertyType_Array2 = get("add-On_PropertyType_Array"),
					NewPropertyType_Array2 = array:set(1,PropertyTypeIndex2,OldPropertyType_Array2),
					put("add-On_PropertyType_Array",NewPropertyType_Array2);
				1->ok
			end,
			case Property3 of
				0->
					PropertyType3 = array:get(2, OldPropertyType_Array),
					PropertyTypeIndex3 = PropertyType3#propertyTypeValue.type * 2 + PropertyType3#propertyTypeValue.fixOrPercent,
					OldPropertyType_Array3 = get("add-On_PropertyType_Array"),
					NewPropertyType_Array3 = array:set(2,PropertyTypeIndex3,OldPropertyType_Array3),
					put("add-On_PropertyType_Array",NewPropertyType_Array3);
				1->ok
			end,
			case Property4 of
				0->
					PropertyType4 = array:get(3, OldPropertyType_Array),
					PropertyTypeIndex4 = PropertyType4#propertyTypeValue.type * 2 + PropertyType4#propertyTypeValue.fixOrPercent,
					OldPropertyType_Array4 = get("add-On_PropertyType_Array"),
					NewPropertyType_Array4 = array:set(3,PropertyTypeIndex4,OldPropertyType_Array4),
					put("add-On_PropertyType_Array",NewPropertyType_Array4);
				1->ok
			end,
			case Property5 of
				0->
					PropertyType5 = array:get(4, OldPropertyType_Array),
					PropertyTypeIndex5 = PropertyType5#propertyTypeValue.type * 2 + PropertyType5#propertyTypeValue.fixOrPercent,
					OldPropertyType_Array5 = get("add-On_PropertyType_Array"),
					NewPropertyType_Array5 = array:set(4,PropertyTypeIndex5,OldPropertyType_Array5),
					put("add-On_PropertyType_Array",NewPropertyType_Array5);
				1->ok
			end,
			
			EquipIteminfo = equipment:getEquipItemById( PlayerEquip#playerEquipItem.equipid ),
			put("ChangeProperty_Array",PlayerEquip#playerEquipItem.propertyTypeValueArray),
			put("Need_World_Bordcrast",0),
			case Property1 of
				0->ok;
				1->
					PropertyArray1=get("ChangeProperty_Array"),
	
					{NewPropertyTypeInfo1,NewPropertyValue1} = getNewPropertyByTypeAddQuality(PlayerEquip,PlayerEquip#playerEquipItem.quality),
					
					NewPropertyTypeIndex1 = NewPropertyTypeInfo1#weightExtern.propertyType * 2 + NewPropertyTypeInfo1#weightExtern.fixOrPercent,
					Old_PropertyType_Array1 = get("add-On_PropertyType_Array"),
					New_PropertyType_Array1 = array:set(0,NewPropertyTypeIndex1,Old_PropertyType_Array1),
					put("add-On_PropertyType_Array",New_PropertyType_Array1),
					
					NewProperty1 = #propertyTypeValue{type=NewPropertyTypeInfo1#weightExtern.propertyType,fixOrPercent=NewPropertyTypeInfo1#weightExtern.fixOrPercent, value=NewPropertyValue1 },
					NewPropertyValueArray1 =array:set(0,NewProperty1,PropertyArray1),
					put("ChangeProperty_Array",NewPropertyValueArray1),
					
					MaxPropertyValue1 = getNewPropertyMaxValueByInfoAndQuality(NewPropertyTypeInfo1,EquipIteminfo#equipitem.activeLevel,PlayerEquip#playerEquipItem.quality),
					MinPropertyValue1 = getNewPropertyMinValueByInfoAndQuality(NewPropertyTypeInfo1,EquipIteminfo#equipitem.activeLevel,PlayerEquip#playerEquipItem.quality),
					
					%%if NewPropertyValue1 >= (MinPropertyValue1 + (MaxPropertyValue1 - MinPropertyValue1) / 5 * 4)
					if MaxPropertyValue1 =:= NewPropertyValue1
						 -> put("Need_World_Bordcrast",1);
					   true->ok
					end
			end,
			case Property2 of
				0->ok;
				1->
					PropertyArray2=get("ChangeProperty_Array"),

					{NewPropertyTypeInfo2,NewPropertyValue2} = getNewPropertyByTypeAddQuality(PlayerEquip,PlayerEquip#playerEquipItem.quality),
					
					NewPropertyTypeIndex2 = NewPropertyTypeInfo2#weightExtern.propertyType * 2 + NewPropertyTypeInfo2#weightExtern.fixOrPercent,
					Old_PropertyType_Array2 = get("add-On_PropertyType_Array"),
					New_PropertyType_Array2 = array:set(1,NewPropertyTypeIndex2,Old_PropertyType_Array2),
					put("add-On_PropertyType_Array",New_PropertyType_Array2),

					NewProperty2 = #propertyTypeValue{type=NewPropertyTypeInfo2#weightExtern.propertyType,fixOrPercent=NewPropertyTypeInfo2#weightExtern.fixOrPercent, value=NewPropertyValue2 },
					NewPropertyValueArray2 =array:set(1,NewProperty2,PropertyArray2),
					put("ChangeProperty_Array",NewPropertyValueArray2),
					
					MaxPropertyValue2 = getNewPropertyMaxValueByInfoAndQuality(NewPropertyTypeInfo2,EquipIteminfo#equipitem.activeLevel,PlayerEquip#playerEquipItem.quality),
					MinPropertyValue2 = getNewPropertyMinValueByInfoAndQuality(NewPropertyTypeInfo2,EquipIteminfo#equipitem.activeLevel,PlayerEquip#playerEquipItem.quality),
					
					%%if NewPropertyValue2 >= (MinPropertyValue2 + (MaxPropertyValue2 - MinPropertyValue2) / 5 * 4)
					if MaxPropertyValue2 =:= NewPropertyValue2 
						 -> put("Need_World_Bordcrast",1);
					   true->ok
					end
			end,
			case Property3 of
				0->ok;
				1->
					PropertyArray3=get("ChangeProperty_Array"),
					{NewPropertyTypeInfo3,NewPropertyValue3} = getNewPropertyByTypeAddQuality(PlayerEquip,PlayerEquip#playerEquipItem.quality),
					NewPropertyTypeIndex3 = NewPropertyTypeInfo3#weightExtern.propertyType * 2 + NewPropertyTypeInfo3#weightExtern.fixOrPercent,
					Old_PropertyType_Array3 = get("add-On_PropertyType_Array"),
					New_PropertyType_Array3 = array:set(2,NewPropertyTypeIndex3,Old_PropertyType_Array3),
					put("add-On_PropertyType_Array",New_PropertyType_Array3),

					NewProperty3 = #propertyTypeValue{type=NewPropertyTypeInfo3#weightExtern.propertyType,fixOrPercent=NewPropertyTypeInfo3#weightExtern.fixOrPercent, value=NewPropertyValue3 },
					NewPropertyValueArray3 =array:set(2,NewProperty3,PropertyArray3),
					put("ChangeProperty_Array",NewPropertyValueArray3),
					
					MaxPropertyValue3 = getNewPropertyMaxValueByInfoAndQuality(NewPropertyTypeInfo3,EquipIteminfo#equipitem.activeLevel,PlayerEquip#playerEquipItem.quality),
					MinPropertyValue3 = getNewPropertyMinValueByInfoAndQuality(NewPropertyTypeInfo3,EquipIteminfo#equipitem.activeLevel,PlayerEquip#playerEquipItem.quality),
					
					%%if NewPropertyValue3 >= (MinPropertyValue3 + (MaxPropertyValue3 - MinPropertyValue3) / 5 * 4)
					if MaxPropertyValue3 =:= NewPropertyValue3 
						 -> put("Need_World_Bordcrast",1);
					   true->ok
					end
			end,
			case Property4 of
				0->ok;
				1->
					PropertyArray4=get("ChangeProperty_Array"),
					{NewPropertyTypeInfo4,NewPropertyValue4} = getNewPropertyByTypeAddQuality(PlayerEquip,PlayerEquip#playerEquipItem.quality),
					NewPropertyTypeIndex4 = NewPropertyTypeInfo4#weightExtern.propertyType * 2 + NewPropertyTypeInfo4#weightExtern.fixOrPercent,
					Old_PropertyType_Array4 = get("add-On_PropertyType_Array"),
					New_PropertyType_Array4 = array:set(3,NewPropertyTypeIndex4,Old_PropertyType_Array4),
					put("add-On_PropertyType_Array",New_PropertyType_Array4),

					NewProperty4 = #propertyTypeValue{type=NewPropertyTypeInfo4#weightExtern.propertyType,fixOrPercent=NewPropertyTypeInfo4#weightExtern.fixOrPercent, value=NewPropertyValue4 },
					NewPropertyValueArray4 =array:set(3,NewProperty4,PropertyArray4),
					put("ChangeProperty_Array",NewPropertyValueArray4),
					
					MaxPropertyValue4 = getNewPropertyMaxValueByInfoAndQuality(NewPropertyTypeInfo4,EquipIteminfo#equipitem.activeLevel,PlayerEquip#playerEquipItem.quality),
					MinPropertyValue4 = getNewPropertyMinValueByInfoAndQuality(NewPropertyTypeInfo4,EquipIteminfo#equipitem.activeLevel,PlayerEquip#playerEquipItem.quality),
					
					%%if NewPropertyValue4 >= (MinPropertyValue4 + (MaxPropertyValue4 - MinPropertyValue4) / 5 * 4)
					if MaxPropertyValue4 =:= NewPropertyValue4 
						 -> put("Need_World_Bordcrast",1);
					   true->ok
					end
			end,
			case Property5 of
				0->ok;
				1->
					PropertyArray5=get("ChangeProperty_Array"),
					{NewPropertyTypeInfo5,NewPropertyValue5} = getNewPropertyByTypeAddQuality(PlayerEquip,PlayerEquip#playerEquipItem.quality),
					NewPropertyTypeIndex5 = NewPropertyTypeInfo5#weightExtern.propertyType * 2 + NewPropertyTypeInfo5#weightExtern.fixOrPercent,
					Old_PropertyType_Array5 = get("add-On_PropertyType_Array"),
					New_PropertyType_Array5 = array:set(4,NewPropertyTypeIndex5,Old_PropertyType_Array5),
					put("add-On_PropertyType_Array",New_PropertyType_Array5),

					NewProperty5 = #propertyTypeValue{type=NewPropertyTypeInfo5#weightExtern.propertyType,fixOrPercent=NewPropertyTypeInfo5#weightExtern.fixOrPercent, value=NewPropertyValue5 },
					NewPropertyValueArray5 =array:set(4,NewProperty5,PropertyArray5),
					put("ChangeProperty_Array",NewPropertyValueArray5),
					
					MaxPropertyValue5 = getNewPropertyMaxValueByInfoAndQuality(NewPropertyTypeInfo5,EquipIteminfo#equipitem.activeLevel,PlayerEquip#playerEquipItem.quality),
					MinPropertyValue5 = getNewPropertyMinValueByInfoAndQuality(NewPropertyTypeInfo5,EquipIteminfo#equipitem.activeLevel,PlayerEquip#playerEquipItem.quality),
					
					%%if NewPropertyValue5 >= (MinPropertyValue5 + (MaxPropertyValue5 - MinPropertyValue5) / 5 * 4)
					if MaxPropertyValue5 =:= NewPropertyValue5 
						 -> put("Need_World_Bordcrast",1);
					   true->ok
					end
			end,
			NewPropertyArray=get("ChangeProperty_Array"),
			NewPropertyTypeValue1 =  array:get(0,NewPropertyArray),
			NewPropertyTypeValue2 =  array:get(1,NewPropertyArray),
			NewPropertyTypeValue3 =  array:get(2,NewPropertyArray),
			NewPropertyTypeValue4 =  array:get(3,NewPropertyArray),
			NewPropertyTypeValue5 =  array:get(4,NewPropertyArray),			
			
			
			
			player:send(#pk_GetEquipNewPropertyByType{type = EquipType,
													  property1Type =NewPropertyTypeValue1#propertyTypeValue.type,
													  property1FixOrPercent= NewPropertyTypeValue1#propertyTypeValue.fixOrPercent,
													  property1Value=NewPropertyTypeValue1#propertyTypeValue.value,
													  property2Type =NewPropertyTypeValue2#propertyTypeValue.type,
													  property2FixOrPercent= NewPropertyTypeValue2#propertyTypeValue.fixOrPercent,
													  property2Value=NewPropertyTypeValue2#propertyTypeValue.value,
													  property3Type =NewPropertyTypeValue3#propertyTypeValue.type,
													  property3FixOrPercent= NewPropertyTypeValue3#propertyTypeValue.fixOrPercent,
													  property3Value=NewPropertyTypeValue3#propertyTypeValue.value,
													  property4Type =NewPropertyTypeValue4#propertyTypeValue.type,
													  property4FixOrPercent= NewPropertyTypeValue4#propertyTypeValue.fixOrPercent,
													  property4Value=NewPropertyTypeValue4#propertyTypeValue.value,
													  property5Type =NewPropertyTypeValue5#propertyTypeValue.type,
													  property5FixOrPercent= NewPropertyTypeValue5#propertyTypeValue.fixOrPercent,
													  property5Value=NewPropertyTypeValue5#propertyTypeValue.value
											 })
	
	end
catch
	_->ok
end.

%%保存新属性，	
saveNewProperty(EquipType)->
	PlayerEquip = equipment:getPlayerEquipedEquipInfo( EquipType ),
	case PlayerEquip of
		{}->throw(-1);
		_->
			etsBaseFunc:changeFiled(equipment:getEquipTable(),PlayerEquip#playerEquipItem.id, #playerEquipItem.propertyTypeValueArray,get("ChangeProperty_Array")),
			
			player:send(#pk_RequestEquipChangeAddSavePropertyByType{ result = ?EquipChangeProperty_Success}),
			equipment:sendPlayerAllEquip(),
			playerMap:onPlayer_LevelEquipPet_Changed(),
			getEquipOldPropertyByType(EquipType),
			
			case get("Need_World_Bordcrast") of
				1	->
					PlayerName = player:getPlayerProperty( player:getCurPlayerID(), #player.name ),
					BrodcaseString = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_CPROPERTY_RED, [PlayerName, PlayerEquip#playerEquipItem.id,PlayerEquip#playerEquipItem.quality]),
					systemMessage:sendSysMsgToAllPlayer(BrodcaseString);
				0	->	ok;
				undefined	-> ok
			end,
			put("Need_World_Bordcrast",0)
	end.
	
	
