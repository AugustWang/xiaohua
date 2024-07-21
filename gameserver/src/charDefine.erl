%% Author: Administrator
%% Created: 2012-12-6
%% Description: TODO: Add description to charDefine
-module(charDefine).

%%
%% Include files
%%
-include("db.hrl").
-include("hdlt_logger.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("vipDefine.hrl").
-include("globalDefine.hrl").


%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%


%%获取转换率，用于进行属性计算
getTransformRate(Level, Index) ->
	etsBaseFunc:getRecordField(getAttributeRegentCfgTable(), Level, Index).


%%载入属性转换率配置
loadAttributeRegentCfg() ->
	case db:openBinData("attributeRegent.bin") of
		[] ->
			?ERROR_OUT( "loadAttributeRegentCfg openBinData attributeRegent.bin failed!" );
		CfgData ->
			db:loadBinData(CfgData, attributeRegentCfg),
			

			ets:new( ?AttributeRegentCfgTableAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #attributeRegentCfg.level }] ),
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.attributeRegentCfgTable, CfgTable),

			CfgDatalist = db:matchObject(attributeRegentCfg, #attributeRegentCfg{ _='_' } ),
			
			Fun = fun(Record) ->
						  etsBaseFunc:insertRecord(?AttributeRegentCfgTableAtom, Record)
				  end,
			lists:map(Fun, CfgDatalist),
			?DEBUG_OUT( "attributeRegentCfgTable load succ" )
	end.
%%载入攻击因子
loadAttackFactorCfg()->
	case db:openBinData("attackFactor.bin") of
		[] ->
			?ERROR_OUT( "attackFatorCfg openBinData attackFactor.bin failed!" );
		CfgData ->
			db:loadBinData(CfgData, attackFatorCfg),
			

			ets:new( ?AttackFatorCfgTableAtom, [set,protected, named_table,{read_concurrency,true}, { keypos,  #attackFatorCfg.type }] ),
			
			
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.attackFactorCfgTable, CfgTable),

			CfgDatalist = db:matchObject(attackFatorCfg, #attackFatorCfg{ _='_' } ),
			
			Fun = fun(Record) ->
						  NewRecord1 = setelement(#attackFatorCfg.min, Record, Record#attackFatorCfg.min / 100 ),
						  NewRecord2 = setelement(#attackFatorCfg.max, NewRecord1, NewRecord1#attackFatorCfg.max / 100 ),
						  
						  etsBaseFunc:insertRecord(?AttackFatorCfgTableAtom, NewRecord2)
				  end,
			lists:map(Fun, CfgDatalist),
			?DEBUG_OUT( "attackFatorCfg load succ" )
	end.
	
%%返回攻击因子
getAttackFactor( Object )->
	case element( 1, Object ) of
		mapPlayer->
			Cfg = etsBaseFunc:readRecord( main:getAttackFactorCfgTable(), #mapPlayer.camp ),
			{Cfg#attackFatorCfg.min, Cfg#attackFatorCfg.max};
		mapMonster->
			Cfg = etsBaseFunc:readRecord( main:getAttackFactorCfgTable(), ?AttackFator_Monster ),
			{Cfg#attackFatorCfg.min, Cfg#attackFatorCfg.max};
		mapPet->
			Cfg = etsBaseFunc:readRecord( main:getAttackFactorCfgTable(), ?AttackFator_Pet ),
			{Cfg#attackFatorCfg.min, Cfg#attackFatorCfg.max};
		_->
			Cfg = etsBaseFunc:readRecord( main:getAttackFactorCfgTable(), ?AttackFator_Normal ),
			{Cfg#attackFatorCfg.min, Cfg#attackFatorCfg.max}
	end.


getAttributeRegentCfgTable() ->
	?AttackFatorCfgTableAtom.
%% 	Cfg = get("AttributeRegentCfgTable"),
%% 	case Cfg of
%% 		undefined ->db:getFiled(globalMain, ?GlobalMainID, #globalMain.attributeRegentCfgTable);
%% 		_->Cfg
%% 	end.


%%初始化玩家某等级的基础属性，返回属性数组
iniPlayerBasePropertyByLevel( Level, Class )->
	PropertyArray = array:new( ?property_count, {default, 0} ),
	PlayerBaseCfg = player:getCurPlayerBaseCfg( Level, Class ),
	PropertyArray2 = const:addRecordValueIntoArray( PropertyArray, 
											  PlayerBaseCfg, 
											  #playerBaseCfg.camp + 1, 
											  const:getPlayerBaseCfg_ProIndex() ),
	SetValue = 10000,
	InitRecord = { 
					?phy_attack_rate,
					?fire_attack_rate,
					?ice_attack_rate,
					?elec_attack_rate,
					?poison_attack_rate,
					?phy_def_rate,
					?fire_def_rate,
					?ice_def_rate,
					?elec_def_rate,
					?poison_def_rate,
					?treat_rate,
					?treat_rate_been
				   },
	PropertyArray3 = const:setArrayByRecord( PropertyArray2, InitRecord, SetValue ),
	PropertyArray4 = array:set(?move_speed, globalSetup:getGlobalSetupValue(#globalSetup.base_run_speed), PropertyArray3),
	%%PropertyArray5 = array:set(?attack_speed, 1200, PropertyArray4),
	PropertyArray4.

%%返回玩家宠物给玩家增加的属性数组，一个数值，一个list
getPlayerPetAddToProperty()->
	FixArray = array:new(?property_count, {default, 0} ),
	ListArray = array:new(?property_count, {default, []} ),
	
	case pet:getPet(player:getCurPlayerProperty(#player.outFightPet)) of
		{}->
			FixArrayNew = FixArray;
		Pet->
			PropArray = Pet#petProperty.propertyArray,
			FixArray2 = array:set(?attack, erlang:trunc(array:get(?attack, PropArray)*Pet#petProperty.convertRatio/10000), FixArray),
			FixArray3 = array:set(?defence, erlang:trunc(array:get(?defence, PropArray)*Pet#petProperty.convertRatio/10000), FixArray2),
			FixArrayNew = array:set(?max_life, erlang:trunc(array:get(?max_life, PropArray)*Pet#petProperty.convertRatio/10000), FixArray3)
			
	end,
	
	{ FixArrayNew, ListArray }.

%%返回玩家的等级属性、宠物属性、装备、骑乘，属性的累加属性数组，一个数值，一个list
getPlayerPropertyArray()->
	Player = player:getCurPlayerRecord(),
	LevelArray = iniPlayerBasePropertyByLevel( Player#player.level, Player#player.camp ),
	{ EquipFix, EquipList } = equipment:makePlayerAllActivedEquipProperty(),
	{ PetFix, PetList } = getPlayerPetAddToProperty(),
	{MountFix,MountList} = mount:getMountPropertyArray(),
	Fix1 = const:addPropertyArray(LevelArray, EquipFix),
	Fix2 = const:addPropertyArray(Fix1, PetFix),
	Fix3 = const:addPropertyArray(Fix2,MountFix),
	
	List = const:mergPropertyArray( EquipList, PetList ),
	List2 = const:mergPropertyArray( List, MountList),

	%% VIP增加属性 add by yueliangyou [2013-05-14]	
	case vipFun:callVip(?VIP_FUN_PROPERTY,0) of
		{ok,{VipFix,VipList}}->
			Fix4 = const:addPropertyArray(Fix3,VipFix),
			List3 = const:mergPropertyArray(List2,VipList),
			{Fix4,List3};
		{_,_}->{Fix3,List2}
	end.


%%返回Monster的基础属性
getMonsterBasePropertyArray(#monsterCfg{}=MonsterCfg)->
	PropertyArray = array:new( ?property_count, {default, 0} ),
	InitRecord = {
					?attack,
					?defence,
					?max_life,
					?ph_def,
					?fire_def,
					?ice_def,
					?elec_def,
					?poison_def,
					?hit_rate_rate,
					?dodge_rate,
					?block_rate,
					?crit_rate,
					?coma_def_rate,
					?hold_def_rate,
					?silent_def_rate,
					?move_def_rate,
					?move_speed
				},

	PropertyArray2 = const:addRecordValueIntoArray( PropertyArray, 
											  MonsterCfg, 
											  #monsterCfg.attack_speed + 1, 
											  InitRecord ),
	SetValue = 10000,
	InitRecord2 = { 
					?phy_attack_rate,
					?fire_attack_rate,
					?ice_attack_rate,
					?elec_attack_rate,
					?poison_attack_rate,
					?phy_def_rate,
					?fire_def_rate,
					?ice_def_rate,
					?elec_def_rate,
					?poison_def_rate,
					?treat_rate,
					?treat_rate_been
				   },
	PropertyArray3 = const:setArrayByRecord( PropertyArray2, InitRecord2, SetValue ),
	PropertyArray3.


%%返回Object的某项属性
getObjectProperty( Object, PropertyType )->
	case element( 1, Object ) of
		mapPlayer->
			Value = array:get( PropertyType, Object#mapPlayer.finalProperty ),
			Value;
		mapMonster->
			Value = array:get( PropertyType, Object#mapMonster.finalProperty ),
			Value;
		mapPet->
			array:get( PropertyType, Object#mapPet.finalProperty );
		_->0
	end.

%%返回Object的finalProperty
getObjectFinalProperty( Object )->
	case element( 1, Object ) of
		mapPlayer->
			Object#mapPlayer.finalProperty;
		mapMonster->
			Object#mapMonster.finalProperty;
		mapPet->
			Object#mapPet.finalProperty;
		_->0
	end.

%%返回Object的level
getObjectLevel( Object )->
	case element( 1, Object ) of
		mapPlayer->
			Object#mapPlayer.level;
		mapMonster->
			Object#mapMonster.level;
		mapPet->
			Object#mapPet.level;
		_->0
	end.

%%返回Object的Life
getObjectLife( Object )->
	case element( 1, Object ) of
		mapPlayer->
			Object#mapPlayer.life;
		mapMonster->
			Object#mapMonster.life;
		mapPet->
			Object#mapPet.life;
		_->0
	end.

%%返回Object的攻击速度
getObjectAttackSpeed( Object )->
	getObjectProperty( Object, ?attack_speed ).

%%初始化宠物某等级的基础属性，返回属性数组
iniPetBasePropertyByLevel( PetBaseCfg )->
	PropertyArray = array:new( ?property_count, {default, 0} ),
	PropertyArray2 = const:addRecordValueIntoArray( PropertyArray, 
											  PetBaseCfg, 
											  #petLevelPropertyCfg.fuseNeedMoney + 1, 
											  const:getPetBaseCfg_ProIndex() ),

	SetValue = 10000,
	InitRecord2 = { 
					?phy_attack_rate,
					?fire_attack_rate,
					?ice_attack_rate,
					?elec_attack_rate,
					?poison_attack_rate,
					?phy_def_rate,
					?fire_def_rate,
					?ice_def_rate,
					?elec_def_rate,
					?poison_def_rate,
					?treat_rate,
					?treat_rate_been
				   },
	PropertyArray3 = const:setArrayByRecord( PropertyArray2, InitRecord2, SetValue ),
	PropertyArray4 = array:set(?move_speed, globalSetup:getGlobalSetupValue(#globalSetup.base_run_speed), PropertyArray3),
	PropertyArray4.
	
%%改变血量
changeSetLife( Object, SetLife, BroadCast )->
	case element( 1, Object ) of
		mapPlayer->
			ObjLife = Object#mapPlayer.life,
			etsBaseFunc:changeFiled( map:getMapPlayerTable(), Object#mapPlayer.id, #mapPlayer.life, SetLife ),
			playerMap:onHPChanged(Object);
		mapMonster->
			ObjLife = Object#mapMonster.life,
			etsBaseFunc:changeFiled( map:getMapMonsterTable(), Object#mapMonster.id, #mapMonster.life, SetLife ),
			monster:onHPChanged(Object);
		mapPet->
			ObjLife = Object#mapPet.life,
			etsBaseFunc:changeFiled( map:getMapPetTable(), Object#mapPet.id, #mapPet.life, SetLife ),
			petMap:onHPChanged(Object);
		_->
			ObjLife = 0,
			ok
	end,
	objectEvent:onEvent(Object, ?Char_Event_Life_Changed, (ObjLife=<SetLife)),
	case BroadCast of
		true->playerMap:sendObjectLifeToClient(Object, true);
		false->ok
	end.

%%获取生命百分比，返回的百分比数值
getObjectLifePercent(Object)->
	case element(1, Object) of
		mapPlayer->
			MaxLife = array:get(?max_life, Object#mapPlayer.finalProperty),
			Life = Object#mapPlayer.life;
		mapMonster->
			MaxLife = array:get(?max_life, Object#mapMonster.finalProperty),
			Life = Object#mapMonster.life;
		mapPet->
			MaxLife = array:get(?max_life, Object#mapPet.finalProperty),
			Life = Object#mapPet.life;
		_->
			MaxLife = 1,
			Life = 1
	end,
	
	case MaxLife > 0 of
		true-> 
			Percent = erlang:trunc( Life / MaxLife * 100 ),
			case Percent =< 0 of
				true->
					case Life =< 0 of
						true->0;
						false->1
					end;
				false->Percent
			end;
		_->100
	end.
	
%%响应物件进入格子事件
on_ObjectEnterCell( _Object, _MapViewCell )->
	ok.
%%响应物件离开格子事件
on_ObjectLeaveCell( _Object, _MapViewCell )->
	ok.


