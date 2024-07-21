%% Author: yueliangyou
%% Created: 2013-3-29
%% Description: TODO: 
-module(playerFightingCapacity).

%%
%% Include files
%%

-include("db.hrl").
-include("taskDefine.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("monsterDefine.hrl").
-include("itemDefine.hrl").
-include("globalDefine.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("logdb.hrl").

%%
%% Exported Functions
%%
-compile(export_all).


%% 获取角色基本战斗力评分
get_Fighting_Capacity_Base(Level,Cls)->
	PlayerBaseCfg = player:getCurPlayerBaseCfg(Level,Cls),
	?DEBUG_OUT("PlayerPoint:~p",[PlayerBaseCfg#playerBaseCfg.point]),
	PlayerBaseCfg#playerBaseCfg.point.

%% 计算装备扩展属性的战斗力评分
get_Fighting_Capacity_Equip_Ex(EquipLevel,QualityLevel,#propertyTypeValue{type=Type,fixOrPercent=Fix,value=Value}=PropertyTypeValue)->
	?DEBUG_OUT("ELV:~p,QLV:~p,PRO:~p",[EquipLevel,QualityLevel,PropertyTypeValue]),
	QualityAttr=equipProperty:getEquipAttributeByEquipLevel(EquipLevel div 10),
	%%?DEBUG_OUT("Attr:~p",[QualityAttr]),
	QualityAttrArray=QualityAttr#propertyValueSizeCfg.propertyArray,
	%%?DEBUG_OUT("AttrArray:~p",[QualityAttrArray]),
	QualityAttrExtern=array:get(Type*2+Fix,QualityAttrArray),
	%%?DEBUG_OUT("AttrExtern:~p",[QualityAttrExtern]),
	MaxValue = QualityAttrExtern#valueSizeExtern.maxValue,
	BasePoint = QualityAttrExtern#valueSizeExtern.point,
	%QualityFactor=equipProperty:getEquipQualityqualityfactorByQualityLevel(QualityLevel),
	%%?DEBUG_OUT("Factor:~p",[QualityFactor]),
	%QualityFactorArray =QualityFactor#propertyAddValueCfg.propertyArray,
	%%?DEBUG_OUT("FactorArray:~p",[QualityFactorArray]),
	%QualityFactorExtern=array:get(Type*2+Fix,QualityFactorArray),
	%%?DEBUG_OUT("FactorExtern:~p",[QualityFactorExtern]),
	%PointFactor=QualityFactorExtern#propertyAddValueExtern.pointFactor,
	%?DEBUG_OUT("BasePoint:~p,PointFactor:~p,Value:~p,MaxValue:~p",[BasePoint,PointFactor,Value,MaxValue]),
	?DEBUG_OUT("BasePoint:~p,Value:~p,MaxValue:~p",[BasePoint,Value,MaxValue]),
	%BasePoint*PointFactor/10000*Value/MaxValue.
	case MaxValue =:= 0 of
		true->
			EquipPointEx=0;
		false->
			EquipPointEx=BasePoint*Value/MaxValue
	end,
	?DEBUG_OUT("EquipPointEx:~p",[EquipPointEx]),
	EquipPointEx.

%% 获取角色装备战斗力评分
get_Fighting_Capacity_Equip()->
	FNCountEquipPoint = fun(Record)->
		put("EquipPointCurr",0),
		EquipCfg = etsBaseFunc:readRecord(main:getGlobalEquipCfgTable(),Record#playerEquipItem.equipid),
		case EquipCfg of
			{}->ok;
			_->
			%%装备等级
			ActiveLevel=EquipCfg#equipitem.activeLevel,
			%%当前装备类型强化等级
			EnhanceLevel = equipProperty:getPlayerEquipEnhanceByType( EquipCfg#equipitem.type ),
			%%品质提升基础属性
			BaseQuality = equipProperty:getEquipQualityBasalPropertyByQualityLevel( Record#playerEquipItem.quality ),
			%%强化提升基础属性
 			BaseEnhance = equipProperty:getequipEnhancePropertyByLevel( EnhanceLevel#playerEquipLevelInfo.level ),
							 
			%%将品质、强化、基础战斗力评分加起来
			BasePoint = element(#equipitem.basePoint,EquipCfg),

			QualityFactor = element(#equipmentquality.point_Factor,BaseQuality),
			EnhanceFactor = element(#equipEnhance.point_Factor, BaseEnhance ),
			EquipPointCurr = erlang:trunc((BasePoint*QualityFactor*EnhanceFactor)/10000/10000),
						
			put("EquipPointCurr",EquipPointCurr),
			%%?DEBUG_OUT("EquipPointCurr NO EX:~p",[EquipPointCurr]),

			%% 计算装备品质增加的战斗力
			Active = etsBaseFunc:readRecord( ?EquipmentActivebonusCfgTableAtom, Record#playerEquipItem.equipid ),
			case Active of
				{}->ok;
				 _->
					case Record#playerEquipItem.quality of
						?Equip_Quality_Green->
							put("EquipPointCurr",EquipPointCurr+Active#equipmentactivebonus_cfg.green_point);
						?Equip_Quality_Blue->
							put("EquipPointCurr",EquipPointCurr+Active#equipmentactivebonus_cfg.blue_point);
						?Equip_Quality_Purple->
							put("EquipPointCurr",EquipPointCurr+Active#equipmentactivebonus_cfg.purple_point);
						?Equip_Quality_Orange->
							put("EquipPointCurr",EquipPointCurr+Active#equipmentactivebonus_cfg.orange_point);
						?Equip_Quality_Red->
							put("EquipPointCurr",EquipPointCurr+Active#equipmentactivebonus_cfg.red_point);
						_->ok
					end
			end,
			
			%%?DEBUG_OUT("EquipPointActive NO EX:~p",[get("EquipPointCurr")]),

			%%附加属性 战斗力评分
			RecordPropertyArray = Record#playerEquipItem.propertyTypeValueArray,
			ExtendPropertyFunc = fun(QualityLevel)->
				%% 获取附加属性
				ExtendProperty=array:get(QualityLevel-1,RecordPropertyArray),
				ExtendValue=ExtendProperty#propertyTypeValue.value,
				case ExtendValue =:= 0 of
					true->ok;
					false->
						EquipPointNew=get("EquipPointCurr")+get_Fighting_Capacity_Equip_Ex(ActiveLevel,QualityLevel,ExtendProperty),
						put("EquipPointCurr",EquipPointNew)
					
				end
			end,
			common:for( 1, ?Equip_Quality_count-1, ExtendPropertyFunc),
			%%?DEBUG_OUT("EquipPointCurr:~p",[get("EquipPointCurr")]),
			EquipPointTotal=get("EquipPoint")+get("EquipPointCurr"),
			put("EquipPoint",EquipPointTotal),
			%%?DEBUG_OUT("EquipPoint Total:~p",[get("EquipPoint")])
			ok
		end
	end,
	put("EquipPoint",0),
	EquiptedList = equipment:getPlayerEquipedList(),
    lists:foreach(FNCountEquipPoint,EquiptedList),
	?DEBUG_OUT("EquipPoint:~p",[get("EquipPoint")]),
	trunc(get("EquipPoint")).

%% 获取角色技能战斗力评分
get_Fighting_Capacity_Skill()->
	put("SkillPoint",0),
	FNCountSkillPoint = fun(Skill)->
		SkillID=Skill#playerSkill.skillId,
		SkillActID1=Skill#playerSkill.activationSkillID1,
		SkillActID2=Skill#playerSkill.activationSkillID2,
		SkillCfg=etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(),SkillID),
		SkillCfg1=etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(),SkillActID1),
		SkillCfg2=etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(),SkillActID2),
		case SkillCfg of
			{}->ok;
			_->
				PointNew0=get("SkillPoint")+SkillCfg#skillCfg.point,
				put("SkillPoint",PointNew0)
		end,
		case SkillCfg1 of
			{}->ok;
			_->
				PointNew1=get("SkillPoint")+SkillCfg1#skillCfg.point,
				put("SkillPoint",PointNew1)
		end,
		case SkillCfg2 of
			{}->ok;
			_->
				PointNew2=get("SkillPoint")+SkillCfg2#skillCfg.point,
				put("SkillPoint",PointNew2)
		end
	end,
	SkillList = playerSkill:getSkillList(),
    lists:foreach(FNCountSkillPoint,SkillList),
	?DEBUG_OUT("SkillPoint:~p",[get("SkillPoint")]),
	get("SkillPoint").

%% 获取角色总战斗力评分 基本战斗评分+装备战斗力评分+技能战斗力评分
get_Fighting_Capacity_Player()->
	Player = player:getCurPlayerRecord(),
	get_Fighting_Capacity_Base(Player#player.level,Player#player.camp)+get_Fighting_Capacity_Equip()+get_Fighting_Capacity_Skill().

%% 获取角色宠物技能战斗力评分
get_Fighting_Capacity_PetSkill(PetProperty)->
	put("PetSkillPoint",0),
	FNCountPetSkillPoint = fun(PetSkill)->
		SkillCfg=etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(),PetSkill#petSkill.skillId),
		case SkillCfg of
			{}->ok;
			_->
				PointNew=get("PetSkillPoint")+SkillCfg#skillCfg.point,
				put("PetSkillPoint",PointNew)
		end
	end,
	PetSkillList = PetProperty#petProperty.skills,
    	lists:foreach(FNCountPetSkillPoint,PetSkillList),
	?DEBUG_OUT("PetSkillPoint:~p",[get("PetSkillPoint")]),
	get("PetSkillPoint").
	

%% 获取角色宠物战斗力评分
get_Fighting_Capacity_Pet(PetID)->
	try
	put("PetPoint",0),
	PetProperty=pet:getPet(PetID),
	case PetProperty of
		{}->ok;
		_->
			Level=PetProperty#petProperty.level,
			SoulLevel=PetProperty#petProperty.soulLevel,
			AtkGrowUp=PetProperty#petProperty.attackGrowUp,
			LifeGrowUp=PetProperty#petProperty.lifeGrowUp,
			DefGrowUp=PetProperty#petProperty.defGrowUp,
			PetDataID=PetProperty#petProperty.data_id,
			
			PetCfg=pet:getPetCfgItem(PetDataID),
			case PetCfg of 
				{}->throw({notfound_PetCfg});
				_->ok
			end,
			PetLevelCfg=pet:getPetLevelPropertyItem(Level),
			case PetLevelCfg of 
				{}->throw({notfound_PetLevelCfg});
				_->ok
			end,
			PetSoulCfg=pet:getPetSoulUpItem(SoulLevel),
			case PetSoulCfg of 
				{}->throw({notfound_PetSoulCfg});
				_->ok
			end,

			BasePoint=PetLevelCfg#petLevelPropertyCfg.basePoint,
			PetFactor=PetCfg#petCfg.pointFactor,
			PetSoulFactor=PetSoulCfg#petSoulUpCfg.soul_pointFactor,
			PetPoint=get_Fighting_Capacity_PetSkill(PetProperty)+BasePoint*(AtkGrowUp+(DefGrowUp+LifeGrowUp)/2)/10000*PetFactor/10000*PetSoulFactor/10000,
			put("PetPoint",PetPoint)
	end
	catch
		_:Why->?DEBUG_OUT("get_Fighting_Capacity_Pet exception.Why:~p",[Why])
	end,
	?DEBUG_OUT("PetPoint:~p",[get("PetPoint")]),
	trunc(get("PetPoint")).

%% 获取角色坐骑战斗力评分
get_Fighting_Capacity_Mount(MountID,Level)->
	try
		MountCfg = etsBaseFunc:readRecord(mount:getMountCfgTable(),MountID),
		case MountCfg of
    		{}->throw( {return} );
    		_->ok
		end,

		MountLevelCfg = etsBaseFunc:readRecord(mount:getMountLevelCfgTable(),Level),
		case MountLevelCfg of
    		{}->throw( {return} );
    		_->ok
		end,

		MountPoint=MountLevelCfg#mountLevelCfg.point*MountCfg#mountCfg.point_factor/10000,
		?DEBUG_OUT("MountPoint:~p",[MountPoint]),
		trunc(MountPoint)
		
	catch
		_:_->0
	end.

%% 获取角色坐骑战斗力评分
get_Fighting_Capacity_MountList()->
	MountList=mount:getPlayerMountInfoList(),
	put("MountPoint",0),
    FnCountMountPoint = fun( Mount )->
		MountID=Mount#playerMountInfo.mount_data_id,
		Level=Mount#playerMountInfo.level,
		NewPoint=get_Fighting_Capacity_Mount(MountID,Level)+get("MountPoint"),
		put("MountPoint",NewPoint)
	end,
    lists:map(FnCountMountPoint, MountList).


%% 获取角色装备坐骑战斗力评分
get_Fighting_Capacity_MountEquiped()->
	MountID=mount:getEquipedMountID(),
	Mount=mount:getPlayerMountInfo(MountID),
	case Mount of
		{}->0;
		_->get_Fighting_Capacity_Mount(MountID,Mount#playerMountInfo.level)
	end.

%% 获取指定坐骑战斗力评分
get_Fighting_Capacity_MountByID(MountID)->
	Mount=mount:getPlayerMountInfo(MountID),
	case Mount of
		{}->0;
		_->get_Fighting_Capacity_Mount(MountID,Mount#playerMountInfo.level)
	end.

%% 获取角色已出战宠物战斗力评分
get_Fighting_Capacity_PetActive()->	
	OutFightPetID = player:getCurPlayerProperty(#player.outFightPet),
	case OutFightPetID of
		0->0;
		_->get_Fighting_Capacity_Pet(OutFightPetID)
	end.
	
%% 获取角色排名战斗评分 角色总战斗力评分+宠物战斗力评分+坐骑战斗力评分
get_Fighting_Capacity_Top()->
	get_Fighting_Capacity_Player()+get_Fighting_Capacity_PetActive()+get_Fighting_Capacity_MountEquiped().

%% 客户端请求战斗力
on_Request_Fighting_Capacity_Player()->
	FC=get_Fighting_Capacity_Player(),
	?DEBUG_OUT("FC:~p",[FC]),
	Pkt=#pk_U2GS_RequestPlayerFightingCapacity_Ret{fightingcapacity=FC},
	player:send(Pkt).

on_Request_Fighting_Capacity_Pet(#pk_U2GS_RequestPetFightingCapacity{petid=PetID}=_P)->
	FC=get_Fighting_Capacity_Pet(PetID),
	Pkt=#pk_U2GS_RequestPetFightingCapacity_Ret{fightingcapacity=FC},
	player:send(Pkt).

on_Request_Fighting_Capacity_Mount(#pk_U2GS_RequestMountFightingCapacity{mountid=MountID}=_P)->
	FC=get_Fighting_Capacity_MountByID(MountID),
	Pkt=#pk_U2GS_RequestMountFightingCapacity_Ret{fightingcapacity=FC},
	player:send(Pkt).
