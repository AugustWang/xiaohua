-module(equipment).


-include("package.hrl").
-include("db.hrl").
-include("taskDefine.hrl").
-include("hdlt_logger.hrl").
-include("itemDefine.hrl").
-include("playerDefine.hrl").
-include("mapDefine.hrl").
-include("logdb.hrl").
-include("textDefine.hrl").
-include("globalDefine.hrl").

-include_lib("stdlib/include/ms_transform.hrl").

-compile(export_all). 


%%---------------------------------------------------get equip--------------------------------------------------------------
%%返回某装备类型的装备树格子起始格子位置
getEquipTypeTreeCellBegin( EquipType )->
	case EquipType of
		?EquipType_Cap->6;
		?EquipType_Coat->0;
		?EquipType_Shoulder->12;
		?EquipType_Hand->12;
		?EquipType_Shoe->6;
		?EquipType_Belt->12;
		?EquipType_Ring->18;
		?EquipType_Accessories->18;
		?EquipType_Fashion->0;
		?EquipType_Pants->6;
		?EquipType_Wing->0;
		?EquipType_Weapon->0;
		_->0
	end.

getEquipType(Type)->
	case Type of 
		0	->	?EQUIP_TYPE_JZ;
		1 	-> 	?EQUIP_TYPE_WQ;
		2 	-> 	?EQUIP_TYPE_MZ;
		3 	-> 	?EQUIP_TYPE_JB;
		4 	-> 	?EQUIP_TYPE_KZ;
		5 	-> 	?EQUIP_TYPE_ST;
		6 	-> 	?EQUIP_TYPE_YF;
		7 	-> 	?EQUIP_TYPE_YD;
		8 	-> 	?EQUIP_TYPE_XZ;
		9 	-> 	?EQUIP_TYPE_XL;
		10 	-> 	?EQUIP_TYPE_CB;
		11 	-> 	?EQUIP_TYPE_SZ;
		_	->	?EQUIP_TYPE_UNKNOW
end.


%%返回装备树格子
getEquipTreeCell( CellIndex )->
	etsBaseFunc:readRecord( main:getGlobalEquipTreeCfgTable(), CellIndex).

%%返回某职业某装备类型某格子的装备数据
getEquipByClassTypeCell( ClassType_Param, EquipType_Param, CellIndex_Param )->
	Q = ets:fun2ms( fun( #equipitem{type=EquipType, camp=ClassType, name=_, cellInTree=CellIndex } = Record ) when (EquipType=:=EquipType_Param) andalso (ClassType=:=ClassType_Param) and (CellIndex=:=CellIndex_Param) ->Record end ),
	Result = ets:select(main:getGlobalEquipCfgTable(), Q),
	case Result of
		[]->
			?DEBUG_OUT( "getEquipByClassTypeCell ClassType[~p], EquipType[~p], CellIndex[~p] empty", [ClassType_Param, EquipType_Param, CellIndex_Param] ),
			{};
		_ ->
			[X|_] = Result,
			X
	end.

%%根据装备树格子数据，设置每件装备的前置装备ID
makeEquipPrevID( )->
	try
		MyFunc = fun( Record )->
						 case Record#equipitem.equipid of
							201->
								?DEBUG_OUT("");
							_->ok
						 end,
						 EquipTreeCell = getEquipTreeCell( Record#equipitem.cellInTree ),
						 case EquipTreeCell of
							 {}->
								 ?ERROR_OUT( "makeEquipPrevID equip[~p] ", [Record#equipitem.equipid] ),
								 throw(-1);
							 _->ok
						 end,
						 case ( EquipTreeCell#equipTreeCell.prevCell > 0 ) andalso ( EquipTreeCell#equipTreeCell.prevCell >= getEquipTypeTreeCellBegin(Record#equipitem.type) + 1 ) of
							 true->
								 PrevEquip = getEquipByClassTypeCell( Record#equipitem.camp, Record#equipitem.type, EquipTreeCell#equipTreeCell.prevCell ),
								 case PrevEquip of
									 {}->
										 ?ERROR_OUT( "makeEquipPrevID equip[~p] prevCell[~p]", [Record#equipitem.equipid, EquipTreeCell#equipTreeCell.prevCell] ),
										 throw(-1);
									 _->ok
								 end,
								 etsBaseFunc:changeFiled( main:getGlobalEquipCfgTable(), Record#equipitem.equipid, #equipitem.activePreEquipID, PrevEquip#equipitem.equipid);
							 false->ok
						 end
				 end,
		etsBaseFunc:etsFor( main:getGlobalEquipCfgTable(), MyFunc ),
		ok
	catch
		_->ok
	end.

%%加载装备配置文件数据
loadEquipmentConfig()->
	case db:openBinData( "equip_tree.bin" ) of
		[] ->
			?ERROR_OUT( "equipment openBinData item.bin false []" );
		CellData ->
			db:loadBinData( CellData, equipTreeCell ),
			

			ets:new( ?EquipTreeCfgTableAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #equipTreeCell.cellIndex  }] ),
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.equipTreeCellTable, EquipTreeCfgTable),
			
			EquipTreeCfgList = db:matchObject(equipTreeCell,  #equipTreeCell{_='_'} ),
			MyFunc = fun( Record )->
							 etsBaseFunc:insertRecord(?EquipTreeCfgTableAtom, Record)
					 end,
			lists:foreach( MyFunc, EquipTreeCfgList ),

			?DEBUG_OUT( "equip_tree.bin succ" )
	end,
	
	case db:openBinData( "equipment.bin" ) of
		[] ->
			?ERROR_OUT( "equipment openBinData item.bin false []" );
		EquipData ->
			db:loadBinData( EquipData, equipitem ),
			

			ets:new( ?EquipCfgTableAtom, [set,protected, named_table,{read_concurrency,true},  { keypos, #equipitem.equipid  }] ),
		
			
			EquipCfgList = db:matchObject(equipitem,  #equipitem{_='_'} ),
			MyFunc2 = fun( Record )->
							 etsBaseFunc:insertRecord(?EquipCfgTableAtom, Record)
					 end,
			lists:foreach( MyFunc2, EquipCfgList ),
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.equipCfgTable, EquipCfgTable),
			makeEquipPrevID(),
			?DEBUG_OUT( "equipment succ" )
	end,
	case db:openBinData( "equipmentactivebonus.bin" ) of
		[] ->
			?ERROR_OUT( "equipment openBinData equipmentactivebonus.bin false []" );
		EquipmentactivebonusData ->
			db:loadBinData( EquipmentactivebonusData, equipmentactivebonus_cfg ),
			
			ets:new( ?EquipmentActivebonusCfgTableAtom, [protected, named_table, {read_concurrency,true}, { keypos, #equipmentactivebonus_cfg.equipid }] ),
		
			
			Equipmentactivebonus_cfg_List = db:matchObject(equipmentactivebonus_cfg,  #equipmentactivebonus_cfg{_='_'} ),
			MyFunc3 = fun( Record )->
							 etsBaseFunc:insertRecord(?EquipmentActivebonusCfgTableAtom, Record)
					 end,
			lists:foreach( MyFunc3, Equipmentactivebonus_cfg_List ),
			?DEBUG_OUT( "equipmentactivebonus succ" )
	end,
	case db:openBinData( "Equiplevel.bin" ) of
		[] ->
			?ERROR_OUT( "equipment openBinData Equiplevel.bin false []" );
		EquiplevelData ->
			db:loadBinData( EquiplevelData, equipMinLevelPropertyCfg ),
			
			ets:new( ?EquipMinLevelPropertyCfgTableAtom, [protected, named_table,{read_concurrency,true},  { keypos, #equipMinLevelPropertyCfg.level }] ),
			
			EquipMinLevelPropertyCfg_List = db:matchObject(equipMinLevelPropertyCfg,  #equipMinLevelPropertyCfg{_='_'} ),
			MyFunc4 = fun( Record )->
							 etsBaseFunc:insertRecord(?EquipMinLevelPropertyCfgTableAtom, Record)
					 end,
			lists:foreach( MyFunc4, EquipMinLevelPropertyCfg_List ),
			?DEBUG_OUT( "Equiplevel.bin succ" )
	end.
%%返回当前进程的装备表
getEquipTable()->
	EquipTable = get( "EquipTable" ),
	case EquipTable of
		undefined->0;
		_->EquipTable
	end.


%%返回某装备配置数据记录
getEquipItemById( ID ) ->
	etsBaseFunc:readRecord( main:getGlobalEquipCfgTable(), ID).

%%返回玩家已激活装备数据列表
getPlayerActivedEquipList() ->
	Q = ets:fun2ms( fun(Record)->Record end ),
	ets:select(getEquipTable(), Q).

getPlayerEquipedEquipList() ->
	Q = ets:fun2ms( fun(#playerEquipItem{isEquiped=IsEquiped}=Record) when IsEquiped =:= 1 ->Record end ),
	ets:select(getEquipTable(), Q).

%%返回玩家某装备记录
getPlayerActivedEquip( EquipId )->
	Q = ets:fun2ms( fun(Record) when Record#playerEquipItem.equipid =:= EquipId ->Record end ),
	Result = ets:select(getEquipTable(), Q),
	case Result of
		[]->
			{};
		_->
			[X|_] = Result,
			X
	end.

%%返回玩家某已激活装备记录
getPlayerActivedEquipByDBID( EquipDBID )->
	etsBaseFunc:readRecord( getEquipTable(), EquipDBID).


%%返回玩家已装备在某位置的装备记录
getPlayerEquipedEquipInfo( EquipType )->
	Q = ets:fun2ms( fun(Record) when ( Record#playerEquipItem.type =:= EquipType ) andalso ( Record#playerEquipItem.isEquiped =:= 1 ) ->Record end ),
	Result = ets:select(getEquipTable(), Q),
	case Result of
		[]->
			{};
		_->
			[X|_] = Result,
			X
	end.

%%返回玩家已装备在某位置的装备DataID
getPlayerEquipedEquipDataID( EquipType )->
	Ret = getPlayerEquipedEquipInfo( EquipType ),
	case Ret of
		{}->0;
		_->Ret#playerEquipItem.equipid
	end.


%%返回某玩家已装备数据列表
getPlayerEquipedList() ->
	Q = ets:fun2ms( fun(Record) when ( Record#playerEquipItem.isEquiped =:= 1 ) ->Record end ),
	ets:select(getEquipTable(), Q).


onGM_RandomEquipWzy(PlayerID,PlayerClass )->
	%% just for test
	RandValue = random:uniform(6)+2,
	RandAdd = RandValue -1,
	
	try
		case PlayerClass of
			?Player_Class_Fighter->EquipID = 1+RandAdd;
			?Player_Class_Shooter->EquipID = 23+RandAdd;
			?Player_Class_Master->EquipID = 45+RandAdd;
			?Player_Class_Pastor->EquipID = 67+RandAdd;
			_->EquipID = 0, throw(-1)
		end,
		EquipData = getEquipItemById( EquipID ),
		case EquipData of
			{}->
				throw(-1);
			_->ok
		end,
		doneActiveEquip( PlayerID, EquipID, EquipData, 1, true ),
		playerPutonEquipment(EquipID),
		
		%%铠甲
		case PlayerClass of
			?Player_Class_Fighter->EquipID2 = 1001+RandAdd;
			?Player_Class_Shooter->EquipID2 = 1023+RandAdd;
			?Player_Class_Master->EquipID2 = 1045+RandAdd;
			?Player_Class_Pastor->EquipID2 = 1067+RandAdd;
			_->EquipID2 = 0, throw(-1)
		end,
		EquipData2 = getEquipItemById( EquipID2 ),
		case EquipData2 of
			{}->
				throw(-1);
			_->ok
		end,
		doneActiveEquip( PlayerID, EquipID2, EquipData2, 1, true ),
		playerPutonEquipment(EquipID2),

		%%头盔
		case PlayerClass of
			?Player_Class_Fighter->EquipID3 = 201+RandAdd;
			?Player_Class_Shooter->EquipID3 = 222+RandAdd;
			?Player_Class_Master->EquipID3 = 243+RandAdd;
			?Player_Class_Pastor->EquipID3 = 264+RandAdd;
			_->EquipID3 = 0, throw(-1)
		end,
		EquipData3 = getEquipItemById( EquipID3 ),
		case EquipData3 of
			{}->
				throw(-1);
			_->ok
		end,
		doneActiveEquip( PlayerID, EquipID3, EquipData3, 1, true ),
		playerPutonEquipment(EquipID3),
		
		%%肩甲
		case PlayerClass of
			?Player_Class_Fighter->EquipID4 = 401+RandAdd;
			?Player_Class_Shooter->EquipID4 = 421+RandAdd;
			?Player_Class_Master->EquipID4 = 441+RandAdd;
			?Player_Class_Pastor->EquipID4 = 461+RandAdd;
			_->EquipID4 = 0, throw(-1)
		end,
		EquipData4 = getEquipItemById( EquipID4 ),
		case EquipData4 of
			{}->
				throw(-1);
			_->ok
		end,
		doneActiveEquip( PlayerID, EquipID4, EquipData4, 1, true ),
		playerPutonEquipment(EquipID4),
		
		%%护膝
		case PlayerClass of
			?Player_Class_Fighter->EquipID5 = 601+RandAdd;
			?Player_Class_Shooter->EquipID5 = 622+RandAdd;
			?Player_Class_Master->EquipID5 = 643+RandAdd;
			?Player_Class_Pastor->EquipID5 = 664+RandAdd;
			_->EquipID5 = 0, throw(-1)
		end,
		EquipData5 = getEquipItemById( EquipID5 ),
		case EquipData5 of
			{}->
				throw(-1);
			_->ok
		end,
		doneActiveEquip( PlayerID, EquipID5, EquipData5, 1, true ),
		playerPutonEquipment(EquipID5),
		
		%%护手
		case PlayerClass of
			?Player_Class_Fighter->EquipID6 = 801+RandAdd;
			?Player_Class_Shooter->EquipID6 = 821+RandAdd;
			?Player_Class_Master->EquipID6 = 841+RandAdd;
			?Player_Class_Pastor->EquipID6 = 861+RandAdd;
			_->EquipID6 = 0, throw(-1)
		end,
		EquipData6 = getEquipItemById( EquipID6 ),
		case EquipData6 of
			{}->
				throw(-1);
			_->ok
		end,
		doneActiveEquip( PlayerID, EquipID6, EquipData6, 1, true ),
		playerPutonEquipment(EquipID6),
		
		%%腰带
		case PlayerClass of
			?Player_Class_Fighter->EquipID7 = 1201+RandAdd;
			?Player_Class_Shooter->EquipID7 = 1221+RandAdd;
			?Player_Class_Master->EquipID7 = 1241+RandAdd;
			?Player_Class_Pastor->EquipID7 = 1261+RandAdd;
			_->EquipID7 = 0, throw(-1)
		end,
		EquipData7= getEquipItemById( EquipID7 ),
		case EquipData7 of
			{}->
				throw(-1);
			_->ok
		end,
		doneActiveEquip( PlayerID, EquipID7, EquipData7, 1, true ),
		playerPutonEquipment(EquipID7),
		
		%%靴子
		case PlayerClass of
			?Player_Class_Fighter->EquipID8 = 1401+RandAdd;
			?Player_Class_Shooter->EquipID8 = 1421+RandAdd;
			?Player_Class_Master->EquipID8 = 1441+RandAdd;
			?Player_Class_Pastor->EquipID8 = 1461+RandAdd;
			_->EquipID8 = 0, throw(-1)
		end,
		EquipData8= getEquipItemById( EquipID8 ),
		case EquipData8 of
			{}->
				throw(-1);
			_->ok
		end,
		doneActiveEquip( PlayerID, EquipID8, EquipData8, 1, true ),
		playerPutonEquipment(EquipID8),
		
		%%项链
		case PlayerClass of
			?Player_Class_Fighter->EquipID9 = 1601+RandAdd;
			?Player_Class_Shooter->EquipID9 = 1620+RandAdd;
			?Player_Class_Master->EquipID9 = 1639+RandAdd;
			?Player_Class_Pastor->EquipID9 = 1658+RandAdd;
			_->EquipID9 = 0, throw(-1)
		end,
		EquipData9= getEquipItemById( EquipID9 ),
		case EquipData9 of
			{}->
				throw(-1);
			_->ok
		end,
		doneActiveEquip( PlayerID, EquipID9, EquipData9, 1, true ),
		playerPutonEquipment(EquipID9),
		
		ok
	catch
		_->ok
	end,

	ok.


%%GM 随即给玩家添加装备
on_RandomOneEquip(Type,Camp,[SouceHead|SourceTail],Dest)->
	%%EquipList=main:getGlobalEquipCfgTable(),
	%%FunFilt=fun(Equip)->
	%%	case (Equip#equipitem.camp =:= Camp) and (Equip#equipitem.type =:= Type) of
	%%		true->
	%%				[Equip#equipitem.equipid|FitConditionEquip];
	%%		false->ok
	%%	end
	%%end,
	%%lists:foreach(FunFilt, EquipList),
	%%FitConditionEquip.

	case (SouceHead#equipitem.camp =:= Camp) and (SouceHead#equipitem.type =:= Type) of
			true->
					on_RandomOneEquip(Type,Camp,SourceTail,[SouceHead|Dest]);
			false-> 
					on_RandomOneEquip(Type,Camp,SourceTail,Dest)
	end.
onGM_RandomEquip(PlayerID)->
	
	?DEBUG_OUT( "onGM_RandomEquip ~p~n",[PlayerID] ),
	PlayerRec=player:getPlayerRecord( PlayerID ),
	%%Sex = PlayerRec#player.sex,
	PlayerClass=PlayerRec#player.camp,
	%%EquipList=etsBaseFunc:getAllRecord( main:getGlobalEquipCfgTable()),
	%%EquipListRing=on_RandomOneEquip(?EquipType_Ring,PlayerClass,EquipList,[]),
	%%EquipDataRing = getEquipItemById( EquipIDRing ),
	
	%%_WeaponEquipCfg = etsBaseFunc:getAllRecord(main:getGlobalEquipCfgTable()),
	%%武器
	QRing = ets:fun2ms( fun(#equipitem{id=_, equipid=_, type=Type, camp = Camp, cellInTree=CellInTree} = Record ) 
						 when ( ( Camp=:=PlayerClass ) andalso ( Type=:=?EquipType_Weapon ) ) andalso (CellInTree<36) -> Record end),
	EquipListRing = ets:select(main:getGlobalEquipCfgTable(), QRing),
	
	
	ChosePosRing=crypto:rand_uniform(1, length(EquipListRing)),
	EquipDataRing=lists:nth(ChosePosRing,EquipListRing),
  try
		case EquipDataRing of
			{}->
				throw(-1);
			_->ok
		end,
		doneActiveEquip( PlayerID, EquipDataRing#equipitem.equipid, EquipDataRing, 1, true ),
		playerPutonEquipment(EquipDataRing#equipitem.equipid)
		%%doneActiveEquip( PlayerID, 1831, EquipDataRing, 1, true ),
		%%playerPutonEquipment(1831)
	catch
		_->ok
	end,
	
	%%衣服
	QCoat = ets:fun2ms( fun(#equipitem{id=_, equipid=_, type=Type, camp = Camp, cellInTree=CellInTree} = Record ) 
						 when ( ( Camp=:=PlayerClass ) andalso ( Type=:=?EquipType_Coat ) ) andalso (CellInTree<36) -> Record end),
	EquipListCoat = ets:select(main:getGlobalEquipCfgTable(), QCoat),
	
	
	ChosePosCoat=crypto:rand_uniform(1, length(EquipListCoat)),
	EquipDataCoat=lists:nth(ChosePosCoat,EquipListCoat),
  try
		case EquipDataCoat of
			{}->
				throw(-1);
			_->ok
		end,
		doneActiveEquip( PlayerID, EquipDataCoat#equipitem.equipid, EquipDataCoat, 1, true ),
		playerPutonEquipment(EquipDataCoat#equipitem.equipid)
		%%doneActiveEquip( PlayerID, 1831, EquipDataRing, 1, true ),
		%%playerPutonEquipment(1831)
	catch
		_->ok
	end,

	%%其他装备
	%%sendPlayerAllEquip(),
	ok.
%%---------------------------------------------------op equip--------------------------------------------------------------
%%角色创建赠送玩家装备
onCreatedPlayerToEquip( PlayerID, PlayerClass )->
	
	try
		case PlayerClass of
			?Player_Class_Fighter->EquipID = 1;
			?Player_Class_Shooter->EquipID = 23;
			?Player_Class_Master->EquipID = 45;
			?Player_Class_Pastor->EquipID = 67;
			_->EquipID = 0, throw(-1)
		end,
		EquipData = getEquipItemById( EquipID ),
		case EquipData of
			{}->
				throw(-1);
			_->ok
		end,
		doneActiveEquip( PlayerID, EquipID, EquipData, 1, false ),	
		ok
	catch
		_->ok
	end,
	ok.

%%角色创建赠送玩家装备
onCreatedPlayerToEquipRandom( PlayerID, PlayerClass )->
	%% just for test
	RandValue = random:uniform(6),
	RandAdd = RandValue -1,
	
	try
		case PlayerClass of
			?Player_Class_Fighter->EquipID = 1+RandAdd;
			?Player_Class_Shooter->EquipID = 23+RandAdd;
			?Player_Class_Master->EquipID = 45+RandAdd;
			?Player_Class_Pastor->EquipID = 67+RandAdd;
			_->EquipID = 0, throw(-1)
		end,
		EquipData = getEquipItemById( EquipID ),
		case EquipData of
			{}->
				throw(-1);
			_->ok
		end,
		doneActiveEquip( PlayerID, EquipID, EquipData, 1, false ),
		
		case PlayerClass of
			?Player_Class_Fighter->EquipID2 = 1001+RandAdd;
			?Player_Class_Shooter->EquipID2 = 1023+RandAdd;
			?Player_Class_Master->EquipID2 = 1045+RandAdd;
			?Player_Class_Pastor->EquipID2 = 1067+RandAdd;
			_->EquipID2 = 0, throw(-1)
		end,
		EquipData2 = getEquipItemById( EquipID2 ),
		case EquipData2 of
			{}->
				throw(-1);
			_->ok
		end,
		doneActiveEquip( PlayerID, EquipID2, EquipData2, 1, false ),
		
		ok
	catch
		_->ok
	end,
	ok.

%%激活某玩家某装备
activePlayerEquipment( EquipID ) ->
	try
		PlayerID = player:getCurPlayerID(),
		IsActived = getPlayerActivedEquip( EquipID ),
		case IsActived of
			{}->ok;
			_->
				?DEBUG_OUT( "activePlayerEquipment PlayerID[~p], EquipID[~p] is actived", [PlayerID, EquipID] ),
				throw(-1)
		end,
		
		EquipData = getEquipItemById( EquipID ),
		case EquipData of
			{}->
				?DEBUG_OUT( "activePlayerEquipment PlayerID[~p], EquipID[~p] is error equipid", [PlayerID, EquipID] ),
				throw(-1);
			_->ok
		end,
		
		%%职业
		case EquipData#equipitem.camp =:= player:getCurPlayerProperty( #player.camp) of
			true->ok;
			false->
				?DEBUG_OUT( "activePlayerEquipment PlayerID[~p], EquipID[~p] false camp", [PlayerID, EquipID] ),
				throw(-1)
		end,

		%%金钱
		PlayerMoney =equipProperty:getEquipwashupMoneyByEquipID( EquipID ),
		case playerMoney:canUsePlayerBindedMoney( PlayerMoney#equipwashupmoney.upgrade_white) of
			false->
				?DEBUG_OUT( "activePlayerEquipment PlayerID[~p], EquipID[~p] false money activeMoney[~p]", [PlayerID, EquipID, PlayerMoney#equipwashupmoney.upgrade_white] ),
				player:send(#pk_PlayerEquipActiveFailReason { reason = ?EquipActive_Fail_NotEnough_Money}),
				throw(-1);
			true->ok
		end,
		%%等级
		PlayerLevel = player:getCurPlayerProperty( #player.level),
		case EquipData#equipitem.activeLevel =< PlayerLevel of
			true->ok;
			false->
				?DEBUG_OUT( "activePlayerEquipment PlayerID[~p], EquipID[~p] false level activeLevel[~p] PlayerLevel[~p]", [PlayerID, EquipID, EquipData#equipitem.activeLevel, PlayerLevel] ),
				player:send(#pk_PlayerEquipActiveFailReason { reason = ?EquipActive_Fail_NotEnough_Level}),				
				throw(-1)
		end,
		%%前置装备
		case EquipData#equipitem.activePreEquipID > 0 of
			true->
				case getPlayerActivedEquip( EquipData#equipitem.activePreEquipID ) of
					{}->
						?DEBUG_OUT( "activePlayerEquipment PlayerID[~p], EquipID[~p] false activePreEquipID[~p]", [PlayerID, EquipID, EquipData#equipitem.activePreEquipID] ),
						player:send(#pk_PlayerEquipActiveFailReason { reason = ?EquipActive_Fail_NotEnough_BeforeEquip}),						
						throw(-1);
					_->ok
				end;
			false->ok
		end,
		%%激活声望值
		PlayerCredit = player:getCurPlayerProperty( #player.credit),
		case EquipData#equipitem.activeCredit > PlayerCredit of
			true->
				?DEBUG_OUT( "activePlayerEquipment PlayerID[~p], EquipID[~p] false credit activeCredit[~p] PlayerCredit[~p]", [PlayerID, EquipID, EquipData#equipitem.activeCredit, PlayerCredit] ),
				player:send(#pk_PlayerEquipActiveFailReason { reason = ?EquipActive_Fail_NotEnough_Credit}),	
				throw(-1);
			false->ok
		end,
		%%激活荣誉值
		PlayerHonour = player:getCurPlayerProperty( #player.honor),
		case EquipData#equipitem.activeHonour > PlayerHonour of
			true->
				?DEBUG_OUT( "activePlayerEquipment PlayerID[~p], EquipID[~p] false honor activeHonour[~p] PlayerHonour[~p]", [PlayerID, EquipID, EquipData#equipitem.activeHonour, PlayerHonour] ),
				player:send(#pk_PlayerEquipActiveFailReason { reason = ?EquipActive_Fail_NotEnough_Honor}),	
				throw(-1);
			false->ok
		end,
		%%激活物品

		ActiveItemNeedData = equipProperty:getEquipActiveItemNeedById( EquipID ),
		case ActiveItemNeedData of
			{}->
				?DEBUG_OUT( "activePlayerEquipment PlayerID[~p], EquipID[~p] is error equipid", [PlayerID, EquipID] ),
				throw(-1);
			_->ok
		end,
		QualityItemNeedAllArray1 = ActiveItemNeedData#equipmentActiveItemNeed.itemNeedArray,	
		QualityItemNeedArray = array:get(0, QualityItemNeedAllArray1),
		case QualityItemNeedArray#itemNeed.itemID_1 =:= 0 of
			true->
				ok;
			false->
				CanDecItemCount1  = playerItems:getItemCountByItemData(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_1, "all"),
				case CanDecItemCount1 >= QualityItemNeedArray#itemNeed.itemNum_1 of
					true->
						CanDecItemResult1 = playerItems:canDecItemInBag(?Item_Location_Bag, QualityItemNeedArray#itemNeed.itemID_1,QualityItemNeedArray#itemNeed.itemNum_1, "all" ),
						[CanDecItem1|DecItemData1] = CanDecItemResult1,
						put( "activePlayerEquipment_DecItemData_1", DecItemData1 );
					false->
						player:send(#pk_PlayerEquipActiveFailReason { reason = ?EquipActive_Fail_NotEnough_Item}),	
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
						put( "activePlayerEquipment_DecItemData_2", DecItemData2 );
					false->
						player:send(#pk_PlayerEquipActiveFailReason { reason = ?EquipActive_Fail_NotEnough_Item}),
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
						put( "activePlayerEquipment_DecItemData_3", DecItemData3 );
					false->
						player:send(#pk_PlayerEquipActiveFailReason { reason = ?EquipActive_Fail_NotEnough_Item}),
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
						put( "activePlayerEquipment_DecItemData_4", DecItemData4 );
					false->
						player:send(#pk_PlayerEquipActiveFailReason { reason = ?EquipActive_Fail_NotEnough_Item}),
						throw(-1)
					end
				end,
		
		%%激活需求检查完成，扣相关数据
		%%钱
		case PlayerMoney#equipwashupmoney.upgrade_white > 0 of
			true->
				ParamTuple = #token_param{changetype = ?Money_Change_Equip,param1=EquipID},
				playerMoney:usePlayerBindedMoney( PlayerMoney#equipwashupmoney.upgrade_white, ?Money_Change_Equip, ParamTuple);
			false->ok
		end,
		%%激活声望值
		case EquipData#equipitem.activeCredit > 0 of
			true->
				player:costCurPlayerCredit( EquipData#equipitem.activeCredit, 0);
			false->ok
		end,
		%%激活荣誉值
		case EquipData#equipitem.activeHonour > 0 of
			true->
				player:costCurPlayerHonor( EquipData#equipitem.activeHonour, 0);
			false->ok
		end,
		%%激活物品
		case QualityItemNeedArray#itemNeed.itemID_1 > 0 of
			true->playerItems:decItemInBag( get("activePlayerEquipment_DecItemData_1"), ?Destroy_Item_Reson_ActiveEquip );
			false->ok
		end,
		case QualityItemNeedArray#itemNeed.itemID_2 > 0 of
			true->playerItems:decItemInBag( get("activePlayerEquipment_DecItemData_2"), ?Destroy_Item_Reson_ActiveEquip );
			false->ok
		end,
		case QualityItemNeedArray#itemNeed.itemID_3 > 0 of
			true->playerItems:decItemInBag( get("activePlayerEquipment_DecItemData_3"), ?Destroy_Item_Reson_ActiveEquip );
			false->ok
		end,
		case QualityItemNeedArray#itemNeed.itemID_4 > 0 of
			true->playerItems:decItemInBag( get("activePlayerEquipment_DecItemData_4"), ?Destroy_Item_Reson_ActiveEquip );
			false->ok
		end,
	
		%%可以激活装备了
		NewPlayerEquip = doneActiveEquip( player:getCurPlayerID(), EquipID, EquipData, 0, true ),
		player:send( #pk_PlayerEquipActiveResult{equip=transPlayerEquipToMsg(NewPlayerEquip)} ),
		
		%%激活装备任务判断
		task:updateTaskProgress(?TASKTYPE_ACTIVEEQUIP, EquipID, 1),
		?DEBUG_OUT("activePlayerEquipment PlayerID[~p], EquipID[~p] succ dbID[~p]", [PlayerID, EquipID, NewPlayerEquip#playerEquipItem.id])
	catch
		_->ok
	end.


doneActiveEquip( PlayerID, EquipID, EquipData, IsEquiped, IsInsertToETS )->

		DefaultTypeValue = #propertyTypeValue{type=0,fixOrPercent=0, value=0},

		NewPlayerEquip = #playerEquipItem{
										  %%修改为EquipID，是因为玩家对于某件装备只可能拥有一个，实际上可以去掉，为了和数据库保持一致
										  id=EquipID,
										  playerId=PlayerID, 
										  equipid=EquipID, 
										  type = EquipData#equipitem.type,
										  quality=0, 
										  isEquiped=IsEquiped, 
										  propertyTypeValueArray=array:new( 5, {default, DefaultTypeValue} )
										  },
		mySqlProcess:insertOrReplacePlayerEquipItem(NewPlayerEquip,true),
		case IsInsertToETS of
			true->etsBaseFunc:insertRecord( getEquipTable(), NewPlayerEquip ),
				  player:send( #pk_PlayerEquipActiveResult{equip=transPlayerEquipToMsg(NewPlayerEquip)} );
			false->
				%player:send( #pk_PlayerEquipActiveResult{equip=transPlayerEquipToMsg1111(NewPlayerEquip)} )
				ok
		end,
		
		NewPlayerEquip.
	

%%穿上某装备	   
playerPutonEquipment( EquipDBID )->
	try
		PlayerID = player:getCurPlayerID(),
		PlayerEquip = getPlayerActivedEquipByDBID( EquipDBID ),
		case PlayerEquip of
			{}->
				?DEBUG_OUT( "playerPutonEquipment PlayerID[~p], EquipDBID[~p] unactived", [PlayerID, EquipDBID] ),
				throw (-1);
			_->
				ok		
		end,
		
		EquipItem = getEquipItemById( PlayerEquip#playerEquipItem.equipid ),
		case EquipItem of
			{}->
				?DEBUG_OUT( "playerPutonEquipment PlayerID[~p], EquipDBID[~p] EquipItem[~p] error", [PlayerID, EquipDBID, PlayerEquip#playerEquipItem.equipid] ),
				throw (-1);
			_->
				ok
		end,
		
		OldEquiped = getPlayerEquipedEquipInfo( EquipItem#equipitem.type ),
		case OldEquiped of
			{}->ok;
			_->
				etsBaseFunc:changeFiled( getEquipTable(), OldEquiped#playerEquipItem.id, #playerEquipItem.isEquiped, 0 ),
				player:send( #pk_PlayerEquipPutOnResult{ equip_dbID=OldEquiped#playerEquipItem.id, equiped=0 } )
		end,

		etsBaseFunc:changeFiled( getEquipTable(), PlayerEquip#playerEquipItem.id, #playerEquipItem.isEquiped, 1 ),
		player:send( #pk_PlayerEquipPutOnResult{ equip_dbID=PlayerEquip#playerEquipItem.id, equiped=1 } ),
		playerMap:onPlayer_LevelEquipPet_Changed()
	catch
		_->ok
	end.


%%---------------------------------------------------on equip--------------------------------------------------------------
%%玩家上线装备初始化
onPlayerOnlineToEquipInit( EquipedList )->
	case EquipedList of
		[]->ok;
		_->
			MyFunc = fun( Record )->
							 etsBaseFunc:insertRecord( getEquipTable(), Record )
					 end,
			
			lists:map( MyFunc, EquipedList )
	end,

	sendPlayerAllEquip().

%%遍历玩家所有已激活装备，计算出装备的所有属性，累加到两个array记录
makePlayerAllActivedEquipProperty()->
	EquipFix = array:new( ?property_count, {default, 0} ),
	EquipPer = array:new( ?property_count, {default, [] } ),
	
	InitRecord = {
					?attack,
					?defence,
					?max_life,
					?all_def,
					?ph_def,
					?fire_def,
					?ice_def,
					?elec_def,
					?poison_def,
					?hit,
					?dodge,
					?block,
					?crit,
					?pierce,
					?attack_speed,
					?tough,
					?all_exception,
					?coma_def_rate,
					?hold_def_rate,
					?silent_def_rate,
					?move_def_rate
				},

	put( "makePlayerAllActivedEquipProperty_fix", EquipFix ),
	put( "makePlayerAllActivedEquipProperty_per", EquipPer ),
	MyFunc = fun( Record )->
					 %%装备基本属性、扩展属性、宝石加成统计在Equip_CharProperty中
					 EquipCfg = etsBaseFunc:readRecord( main:getGlobalEquipCfgTable(), Record#playerEquipItem.equipid ),
					 case EquipCfg of
						 {}->ok;
						 _->
							 %%当前装备类型强化等级
							 EnhanceLevel = equipProperty:getPlayerEquipEnhanceByType( EquipCfg#equipitem.type ),
							 %%品质提升基础属性
							 BaseQuality = equipProperty:getEquipQualityBasalPropertyByQualityLevel( Record#playerEquipItem.quality ),
							 %%强化提升基础属性
 							 BaseEnhance = equipProperty:getequipEnhancePropertyByLevel( EnhanceLevel#playerEquipLevelInfo.level ),
							 
							 %%将品质、强化、基础加起来
							 put( "makePlayerAllActivedEquipProperty_Base+Quality", EquipCfg ),
							 BaseQuality_Func = fun(Index)->
														EquipBase = get( "makePlayerAllActivedEquipProperty_Base+Quality" ),
														BaseValue = element( Index, EquipBase ),
														QualityIndex = #equipmentquality.atkPower_Factor + (Index - (#equipitem.atk_Delay + 1) ),
														QualityValue = element( QualityIndex, BaseQuality ),
														QualitySetValue = erlang:trunc( ( BaseValue*QualityValue )/10000 ),
														
														EnhanceIndex = #equipEnhance.atkPower_Factor + (Index - (#equipitem.atk_Delay + 1) ),
														EnhanceValue = element( EnhanceIndex, BaseEnhance ),
														EnhanceSetValue = erlang:trunc( ( QualitySetValue + BaseValue )*EnhanceValue / 10000 ),
														
														EquipBase2 = setelement( Index, EquipBase, BaseValue + QualitySetValue + EnhanceSetValue ),
														put( "makePlayerAllActivedEquipProperty_Base+Quality", EquipBase2 )
												end,
							 common:for( #equipitem.atk_Delay+1, #equipitem.baseSlowRes_Value, BaseQuality_Func ),

							 PropertyArray = get( "makePlayerAllActivedEquipProperty_fix" ),
							 
							 PropertyArray2 = const:addRecordValueIntoArray( PropertyArray, 
											  get("makePlayerAllActivedEquipProperty_Base+Quality"), 
											  #equipitem.atk_Delay + 1, 
											  InitRecord ),
							 
							 put( "makePlayerAllActivedEquipProperty_fix", PropertyArray2 ),
							 
							 
							 RecordPropertyArray = Record#playerEquipItem.propertyTypeValueArray,
							 
							 %%附加属性
							 ExtenPropertyFunc = fun( RecordIndex )->
														 RecordExtenProperty = array:get( RecordIndex-1, RecordPropertyArray ),
														 case RecordExtenProperty#propertyTypeValue.value =:= 0 of
															 true->
																 ok;
															 false->
																 case RecordExtenProperty#propertyTypeValue.fixOrPercent =:= 0 of
																	 true->
																		 Array1 = get( "makePlayerAllActivedEquipProperty_fix" ),
																		 Index1 = RecordExtenProperty#propertyTypeValue.type,
																		 SetValue1 = RecordExtenProperty#propertyTypeValue.value + array:get( Index1, Array1 ),
																		 NewArray1 = array:set( Index1, SetValue1, Array1 ),
																		 put( "makePlayerAllActivedEquipProperty_fix", NewArray1 );
																	 false->
																		 Array2 = get( "makePlayerAllActivedEquipProperty_per" ),
																		 Index2 = RecordExtenProperty#propertyTypeValue.type,
																		 SetValue2 = [RecordExtenProperty#propertyTypeValue.value] ++ array:get( Index2, Array2 ),
																		 NewArray2 = array:set( Index2, SetValue2, Array2 ),
																		 put( "makePlayerAllActivedEquipProperty_per", NewArray2 )
																 end
														 end
												 end,
							 common:for( 1, ?Equip_Quality_count-1, ExtenPropertyFunc)
					 end,
					 ok
			 end,
	EquiptedList = getPlayerEquipedList(),
	lists:foreach( MyFunc, EquiptedList ),
	
	%%已激活，未装备的属性加成
	Q = ets:fun2ms( fun(Record) when ( Record#playerEquipItem.quality >= ?Equip_Quality_Green ) ->Record end ),
	ActivedNoEquipedList = ets:select(getEquipTable(), Q),
	MyFunc2 = fun( Record )->
					  Active = etsBaseFunc:readRecord( ?EquipmentActivebonusCfgTableAtom, Record#playerEquipItem.equipid ),
					  case Active of
						  {}->ok;
						  _->
							  Array_Fix = get( "makePlayerAllActivedEquipProperty_fix" ),
							  
							  case Record#playerEquipItem.quality of
								  ?Equip_Quality_Green->
									  Array_Fix2 = array:set( ?attack, Active#equipmentactivebonus_cfg.greenAtk_Power + array:get(?attack, Array_Fix), Array_Fix ),
									  Array_Fix3 = array:set( ?defence,Active#equipmentactivebonus_cfg.greenDef_Class + array:get(?defence, Array_Fix2), Array_Fix2 ),
									  Array_Fix4 = array:set( ?max_life, Active#equipmentactivebonus_cfg.greenMax_HP + array:get(?max_life, Array_Fix3), Array_Fix3 ),
									  Array_Fix5 = array:set( ?all_def, Active#equipmentactivebonus_cfg.greenALL_Res + array:get(?all_def, Array_Fix4), Array_Fix4 ),
									  ok;
								  ?Equip_Quality_Blue->
									  Array_Fix2 = array:set( ?attack, Active#equipmentactivebonus_cfg.blueAtk_Power + array:get(?attack, Array_Fix), Array_Fix ),
									  Array_Fix3 = array:set( ?defence,Active#equipmentactivebonus_cfg.blueDef_Class + array:get(?defence, Array_Fix2), Array_Fix2 ),
									  Array_Fix4 = array:set( ?max_life, Active#equipmentactivebonus_cfg.blueMax_HP + array:get(?max_life, Array_Fix3), Array_Fix3 ),
									  Array_Fix5 = array:set( ?all_def, Active#equipmentactivebonus_cfg.blueALL_Res + array:get(?all_def, Array_Fix4), Array_Fix4 ),
									  ok;
								  ?Equip_Quality_Purple->
									  Array_Fix2 = array:set( ?attack, Active#equipmentactivebonus_cfg.purpleAtk_Power + array:get(?attack, Array_Fix), Array_Fix ),
									  Array_Fix3 = array:set( ?defence,Active#equipmentactivebonus_cfg.purpleDef_Class + array:get(?defence, Array_Fix2), Array_Fix2 ),
									  Array_Fix4 = array:set( ?max_life, Active#equipmentactivebonus_cfg.purpleMax_HP + array:get(?max_life, Array_Fix3), Array_Fix3 ),
									  Array_Fix5 = array:set( ?all_def, Active#equipmentactivebonus_cfg.purpleALL_Res + array:get(?all_def, Array_Fix4), Array_Fix4 ),
									  ok;
								  ?Equip_Quality_Orange->
									  Array_Fix2 = array:set( ?attack,Active#equipmentactivebonus_cfg.orangeAtk_Power + array:get(?attack, Array_Fix), Array_Fix ),
									  Array_Fix3 = array:set( ?defence,Active#equipmentactivebonus_cfg.orangeDef_Class + array:get(?defence, Array_Fix2), Array_Fix2 ),
									  Array_Fix4 = array:set( ?max_life,Active#equipmentactivebonus_cfg.orangeMax_HP + array:get(?max_life, Array_Fix3), Array_Fix3 ),
									  Array_Fix5 = array:set( ?all_def, Active#equipmentactivebonus_cfg.orangeALL_Res + array:get(?all_def, Array_Fix4), Array_Fix4 ),
									  ok;
								  ?Equip_Quality_Red->
									  Array_Fix2 = array:set( ?attack,Active#equipmentactivebonus_cfg.redAtk_Power + array:get(?attack, Array_Fix), Array_Fix ),
									  Array_Fix3 = array:set( ?defence,Active#equipmentactivebonus_cfg.redDef_Class + array:get(?defence, Array_Fix2), Array_Fix2 ),
									  Array_Fix4 = array:set( ?max_life,Active#equipmentactivebonus_cfg.redMax_HP + array:get(?max_life, Array_Fix3), Array_Fix3 ),
									  Array_Fix5 = array:set( ?all_def,Active#equipmentactivebonus_cfg.redALL_Res + array:get(?all_def, Array_Fix4), Array_Fix4 ),
									  ok;
								  _->Array_Fix5 = Array_Fix
							  end,
							  put( "makePlayerAllActivedEquipProperty_fix", Array_Fix5 )
					  end
			  end,
	lists:foreach( MyFunc2, ActivedNoEquipedList ),
	
	%%装备等级加成
	MinEquipLevel = getPlayerEquipMinLevel(),
	EquipMinLevelPropertyCfg = etsBaseFunc:readRecord( ?EquipMinLevelPropertyCfgTableAtom, MinEquipLevel ),
	case EquipMinLevelPropertyCfg of
		{}->ok;
		_->
			case EquipMinLevelPropertyCfg#equipMinLevelPropertyCfg.value1 > 0 of
				true->
					case EquipMinLevelPropertyCfg#equipMinLevelPropertyCfg.fixOrPercent1 =:= 0 of
						true->
							Array_Fix = get( "makePlayerAllActivedEquipProperty_fix" ),
							OldValue = array:get( EquipMinLevelPropertyCfg#equipMinLevelPropertyCfg.propertyType1, Array_Fix ),
							Array_Fix2 = array:set( EquipMinLevelPropertyCfg#equipMinLevelPropertyCfg.propertyType1,
													EquipMinLevelPropertyCfg#equipMinLevelPropertyCfg.value1 + OldValue, Array_Fix ),
							put( "makePlayerAllActivedEquipProperty_fix", Array_Fix2 );
						false->
							 Array2 = get( "makePlayerAllActivedEquipProperty_per" ),
							 Index2 = EquipMinLevelPropertyCfg#equipMinLevelPropertyCfg.propertyType1,
							 SetValue2 = [EquipMinLevelPropertyCfg#equipMinLevelPropertyCfg.value1] ++ array:get( Index2, Array2 ),
							 NewArray2 = array:set( Index2, SetValue2, Array2 ),
							 put( "makePlayerAllActivedEquipProperty_per", NewArray2 )
					end;
				false->ok
			end,
			case EquipMinLevelPropertyCfg#equipMinLevelPropertyCfg.value2 > 0 of
				true->
					case EquipMinLevelPropertyCfg#equipMinLevelPropertyCfg.fixOrPercent2 =:= 0 of
						true->
							Array_Fix_2 = get( "makePlayerAllActivedEquipProperty_fix" ),
							OldValue_2 = array:get( EquipMinLevelPropertyCfg#equipMinLevelPropertyCfg.propertyType2, Array_Fix_2 ),
							Array_Fix2_2 = array:set( EquipMinLevelPropertyCfg#equipMinLevelPropertyCfg.propertyType2,
													EquipMinLevelPropertyCfg#equipMinLevelPropertyCfg.value2 + OldValue_2, Array_Fix_2 ),
							put( "makePlayerAllActivedEquipProperty_fix", Array_Fix2_2 );
						false->
							 Array2_2 = get( "makePlayerAllActivedEquipProperty_per" ),
							 Index2_2 = EquipMinLevelPropertyCfg#equipMinLevelPropertyCfg.propertyType2,
							 SetValue2_2 = [EquipMinLevelPropertyCfg#equipMinLevelPropertyCfg.value2] ++ array:get( Index2_2, Array2_2 ),
							 NewArray2_2 = array:set( Index2_2, SetValue2_2, Array2_2 ),
							 put( "makePlayerAllActivedEquipProperty_per", NewArray2_2 )
					end;
				false->ok
			end
	end,
	
	{ get( "makePlayerAllActivedEquipProperty_fix" ), get( "makePlayerAllActivedEquipProperty_per" ) }.
	

%%---------------------------------------------------msg equip--------------------------------------------------------------
%%服务器装备信息转化为网络消息记录
transPlayerEquipToMsg( PlayerEquip )->

	Equipid=PlayerEquip#playerEquipItem.equipid,
 	EquipItemcfg= getEquipItemById( Equipid ),
	
    EquipEnhancecfg=equipProperty:getPlayerEquipEnhanceByType(EquipItemcfg#equipitem.type),
	
	PropertyTypeArray = PlayerEquip#playerEquipItem.propertyTypeValueArray,
	
 	PropertyTypeValue1 = array:get( 0, PropertyTypeArray),
 	PropertyTypeValue2 = array:get( 1, PlayerEquip#playerEquipItem.propertyTypeValueArray ),
 	PropertyTypeValue3 = array:get( 2, PlayerEquip#playerEquipItem.propertyTypeValueArray ),
 	PropertyTypeValue4 = array:get( 3, PlayerEquip#playerEquipItem.propertyTypeValueArray ),
 	PropertyTypeValue5 = array:get( 4, PlayerEquip#playerEquipItem.propertyTypeValueArray ),

	#pk_PlayerEquipNetData{
						   	dbID=PlayerEquip#playerEquipItem.id,
							nEquip=PlayerEquip#playerEquipItem.equipid,
							nQuality=PlayerEquip#playerEquipItem.quality,
							isEquiped=PlayerEquip#playerEquipItem.isEquiped,
							type =PlayerEquip#playerEquipItem.type,
							
						  	enhanceLevel=EquipEnhancecfg#playerEquipLevelInfo.level,
							
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

						
 						   }.


transPlayerEquipToMsg1111( PlayerEquip )->
	#pk_PlayerEquipNetData{
						   	dbID=PlayerEquip#playerEquipItem.id,
							nEquip=PlayerEquip#playerEquipItem.equipid,
							nQuality=PlayerEquip#playerEquipItem.quality,
							isEquiped=PlayerEquip#playerEquipItem.isEquiped,
							type =PlayerEquip#playerEquipItem.type,
							
						  	enhanceLevel=1,
							
						  	property1Type =0,
							property1FixOrPercent= 0,
							property1Value=0,

							property2Type =0,
							property2FixOrPercent= 0,
							property2Value=0,

							property3Type =0,
							property3FixOrPercent= 0,
							property3Value=0,

							property4Type =0,
							property4FixOrPercent= 0,
							property4Value=0,

							property5Type =0,
							property5FixOrPercent= 0,
							property5Value=0

						
 						   }.


%%玩家上线，发送所有装备信息
sendPlayerAllEquip()->
	PlayerEquipList = getPlayerActivedEquipList(),
	case PlayerEquipList of
		[]->ok;
		_->
			PlayerEquipList2 = lists:map( fun ( Record )->transPlayerEquipToMsg( Record ) end, PlayerEquipList ),
			player:send( #pk_PlayerEquipInit{ equips=PlayerEquipList2 } )
	end.


%%查看玩家装备
onMsgQueryPlayerEquip( QueryTargetPlayerID )->
	try
		%GlobalPlayer = db:readRecord( playerGlobal, QueryTargetPlayerID),
		GlobalPlayer = etsBaseFunc:readRecord( ?PlayerGlobalTableAtom, QueryTargetPlayerID ),
		case GlobalPlayer of
			{}->throw(-1);
			_->ok
		end,

		%GlobalPlayer#playerGlobal.pid ! {},
		ok
	catch
		_->ok
	end,
	ok.

%%返回玩家所有已激活装备等级
getPlayerEquipMinLevel()->
	put( "getPlayerEquipMinLevel_Value", 11111111 ),
	MyFunc = fun( Record )->
					PlayerEquipLevelInfo = equipProperty:getPlayerEquipEnhanceByType( Record ),
					case PlayerEquipLevelInfo#playerEquipLevelInfo.level < get( "getPlayerEquipMinLevel_Value" ) of
						true->
							put( "getPlayerEquipMinLevel_Value", PlayerEquipLevelInfo#playerEquipLevelInfo.level );
						false->ok
					end
			 end,
	common:for( 0, ?EquipType_Accessories, MyFunc ),
	Value = get( "getPlayerEquipMinLevel_Value" ),
	Value.
	


