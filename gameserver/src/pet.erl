%% Author: Administrator
%% Created: 2012-12-5
%% Description: TODO: Add description to pet
-module(pet).

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
-include("textDefine.hrl").
-include("globalDefine.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
loadPetCfg() ->
	%%petCfg
	case db:openBinData( "pet.bin" ) of
		[] ->
			?ERROR_OUT( "loadPetCfg openBinData petCfg.bin failed!" );
		PetCfgData ->
			db:loadBinData(PetCfgData, petCfg),
			

			ets:new( ?PetCfgTableAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #petCfg.petID }] ),
			
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.petCfgTable, PetCfgTable),

			PetCfgDataList = db:matchObject(petCfg,  #petCfg{_='_'} ),
			
			Fun = fun( Record ) ->
								  etsBaseFunc:insertRecord(?PetCfgTableAtom, Record)
						  end,
			lists:map(Fun, PetCfgDataList),		
			?DEBUG_OUT( "petCfgTable load succ" )
	end,
	
	%%petLevelPropertyCfg
	case db:openBinData("petLevelProperty.bin") of
		[] ->
			?ERROR_OUT( "loadPetCfg openBinData petLevelPropertyCfg.bin failed!" );
		PetLevelCfgData ->
			db:loadBinData(PetLevelCfgData, petLevelPropertyCfg),
			

			ets:new( ?PetLevelPropertyCfgTableAtom, [set,protected, named_table,{read_concurrency,true},  { keypos, #petLevelPropertyCfg.level }] ),
			
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.petLevelPropertyCfgTable, PetLevelCfgTable),

			PetLevelCfgDatalist = db:matchObject(petLevelPropertyCfg, #petLevelPropertyCfg{ _='_' } ),
			
			Fun2 = fun(Record) ->
						  etsBaseFunc:insertRecord(?PetLevelPropertyCfgTableAtom, Record)
				  end,
			lists:map(Fun2, PetLevelCfgDatalist),
			?DEBUG_OUT( "PetLevelCfgTable load succ" )
	end,
	
	%%petSoulUpCfg
	case db:openBinData("petSoul.bin") of
		[] ->
			?ERROR_OUT( "loadPetCfg openBinData petSoulUpCfg.bin failed!" );
		PetSoulData ->
			db:loadBinData(PetSoulData, petSoulUpCfg),
			

			ets:new( ?PetSoulUpCfgTableAtom, [set,protected, named_table,{read_concurrency,true},  { keypos, #petSoulUpCfg.soul_Level  }] ),
			
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.petSoulUpCfgTable, PetSoulTable),

			PetSoulDataList = db:matchObject(petSoulUpCfg, #petSoulUpCfg{ _='_' } ),
			
			Fun3 = fun(Record) ->
						  etsBaseFunc:insertRecord(?PetSoulUpCfgTableAtom, Record)
				  end,
			lists:map(Fun3, PetSoulDataList),
			?DEBUG_OUT( "PetSoulTable load succ" )
	end.

getPetCfgTable() ->
	?PetCfgTableAtom.


getPetLevelPropertyCfgTable() ->
	?PetLevelPropertyCfgTableAtom.
	

getPetSoulUpCfgTable() ->
	?PetSoulUpCfgTableAtom.


getPetCfgItem(PetID)->
	etsBaseFunc:readRecord(pet:getPetCfgTable(),PetID).

getPetLevelPropertyItem(Level)->
	etsBaseFunc:readRecord(pet:getPetLevelPropertyCfgTable(),Level).

getPetSoulUpItem(Level)->
	etsBaseFunc:readRecord(pet:getPetSoulUpCfgTable(),Level).

%%玩家上线宠物初始化
onPlayerOnlineInitPet() ->
		put("PetList", []),    %%玩家自身的宠物列表
		put("OutFightTime", 0),%%出战时间，用于计算出战CD
		loadPlayerPet(),
		sendAllPetToClient(get("PetList")).


onPlayeEnterMapOutFight() ->
	%%如果有出战的宠物，召唤宠物
	case player:getCurPlayerProperty(#player.outFightPet) of
		0 ->ok;
		PetId ->
			case lists:keyfind(PetId, #petProperty.id, pet:getPlayerPetList()) of
				false->
					player:setCurPlayerProperty(#player.outFightPet, 0),
					player:send(#pk_PetOutFight_Result{ result=?Pet_OutFight_Result_Failed_NotPet, petId=PetId});
				Pet ->
					case etsBaseFunc:readRecord(pet:getPetCfgTable(), Pet#petProperty.data_id) of
						{}->
							player:setCurPlayerProperty(#player.outFightPet, 0),
							player:send(#pk_PetOutFight_Result{ result=?Pet_OutFight_Result_Failed_NotPet, petId=PetId});
						Cfg ->
							%dbProcess_PID ! { getPetBuffData, self(), Pet, Cfg }
							{BuffData, Pet, Cfg} = dbProcess:on_getPetBuffData( Pet, Cfg),
							petOutFight(BuffData, Pet, Cfg)
					end
			end
	end.

petOutFight(BuffData, Pet, Cfg) ->
	player:sendMsgToMap({petOutFight, player:getCurPlayerID(), self(),Pet, Cfg, BuffData }).

%%玩家下线处理
onPlayerOffline() ->
	petSealStore:savePlayerPetSealAhs(),
	savePlayerPet().

%%获取玩家的宠物列表
getPlayerPetList() ->
	get("PetList").

%%获取当前出战的宠物
getPlayerOutFightPetId() ->
	player:getCurPlayerProperty(#player.outFightPet).


%%载入宠物，玩家上线初始化的时候调用
loadPlayerPet() ->
	PetList2 = mySqlProcess:get_petsByMasterId(player:getCurPlayerID()),								

	case PetList2 of
		[] ->
			notHavePet;
		PetList->
			Fun = fun(Record) ->
						  %%如果从数据库中读取的最大成长率为0或者未定义，重新计算（临时代码）
						  case etsBaseFunc:readRecord(pet:getPetCfgTable(), Record#petProperty.data_id) of
							  {}->Record4=Record;
							  PetCfg->
								  case Record#petProperty.atkPowerGrowUp_Max =< 0 orelse 
															  Record#petProperty.atkPowerGrowUp_Max =:= undefined of
									  true->
										  Record2 = setelement(#petProperty.atkPowerGrowUp_Max, Record, calculateAttackGrowUpMaxValue(PetCfg));
									  _->Record2 = Record
								  end,
								  
								  case Record2#petProperty.defClassGrowUp_Max =< 0 orelse 
															  Record2#petProperty.defClassGrowUp_Max =:= undefined of
									  true->
										  Record3 = setelement(#petProperty.defClassGrowUp_Max, Record2, calculateDefGrowUpMaxValue(PetCfg));
									  _->Record3 = Record2
								  end,
								  
								  case Record3#petProperty.hpGrowUp_Max =< 0 orelse 
															   Record3#petProperty.hpGrowUp_Max =:=  undefined of
									  true->
										  Record4 = setelement(#petProperty.hpGrowUp_Max, Record3, calculateLifeGrowUpMaxValue(PetCfg));
									  _->Record4 = Record3
								  end
						  end,
						  setelement(#petProperty.propertyArray, Record4, calculatePetBaseProperty(Record4))
				  end,
			put("PetList",  lists:map(Fun, PetList))
	end.

%%保存宠物
savePlayerPet() ->
	case get("PetList") of
		[] ->
			ok;
		PetList->
			Fun = fun(Record) ->
						  mySqlProcess:replacePetPropertyGamedata(Record)
				  end,
			lists:map(Fun, PetList)
	end.

makePetSkillPackage(Pet) ->
	Fun = fun(Skill) ->
				  {M, S, MS} = Skill#petSkill.coolDownTime,
				  #pk_PetSkill{
							   id=Skill#petSkill.skillId, 
							   coolDownTime=(M*1000000+S)*1000+MS
							   }
		  end,
	lists:map(Fun, Pet#petProperty.skills).

makePetPropetryPackage(#petProperty{}=PetPropetry) ->
	#pk_PetProperty{
					db_id = PetPropetry#petProperty.id,
					data_id = PetPropetry#petProperty.data_id ,
					master_id = PetPropetry#petProperty.masterId,
					level = PetPropetry#petProperty.level,
					exp = PetPropetry#petProperty.exp,
					name = PetPropetry#petProperty.name,
					titleId = PetPropetry#petProperty.titleId,
					aiState = PetPropetry#petProperty.aiState,
					showModel = PetPropetry#petProperty.showModel,
					exModelId = PetPropetry#petProperty.exModelId,
					soulLevel = PetPropetry#petProperty.soulLevel,
					soulRate = PetPropetry#petProperty.soulRate,
					attackGrowUp = PetPropetry#petProperty.attackGrowUp,
					defGrowUp = PetPropetry#petProperty.defGrowUp,
					lifeGrowUp = PetPropetry#petProperty.lifeGrowUp,
					isWashGrow = PetPropetry#petProperty.isWashGrow,
					attackGrowUpWash = PetPropetry#petProperty.attackGrowUpWash,
					defGrowUpWash = PetPropetry#petProperty.defGrowUpWash, 
					lifeGrowUpWash = PetPropetry#petProperty.lifeGrowUpWash,
					convertRatio = PetPropetry#petProperty.convertRatio,
					exerciseLevel = PetPropetry#petProperty.exerciseLevel,
					moneyExrciseNum = PetPropetry#petProperty.moneyExrciseNum,
					exerciseExp = PetPropetry#petProperty.exerciseExp,
					maxSkillNum = PetPropetry#petProperty.maxSkillNum,
					skills = makePetSkillPackage(PetPropetry),
					life = PetPropetry#petProperty.life,
					maxLife = array:get(?max_life, PetPropetry#petProperty.propertyArray),
					attack=array:get(?attack, PetPropetry#petProperty.propertyArray),
					def=array:get(?defence, PetPropetry#petProperty.propertyArray),
					crit=array:get(?crit_rate, PetPropetry#petProperty.propertyArray),
					block=array:get(?block_rate, PetPropetry#petProperty.propertyArray),
					hit=array:get(?hit_rate_rate, PetPropetry#petProperty.propertyArray), 
					dodge=array:get(?dodge_rate, PetPropetry#petProperty.propertyArray),
					tough=array:get(?tough_rate, PetPropetry#petProperty.propertyArray),
					pierce=array:get(?pierce_rate, PetPropetry#petProperty.propertyArray),
					crit_damage_rate=array:get(?crit_damage_rate, PetPropetry#petProperty.propertyArray),
					attack_speed=array:get(?attack_speed_rate, PetPropetry#petProperty.propertyArray),
					ph_def=array:get(?ph_def, PetPropetry#petProperty.propertyArray),
					fire_def=array:get(?fire_def, PetPropetry#petProperty.propertyArray),
					ice_def=array:get(?ice_def, PetPropetry#petProperty.propertyArray),
					elec_def=array:get(?elec_def, PetPropetry#petProperty.propertyArray),
					poison_def=array:get(?poison_def, PetPropetry#petProperty.propertyArray),
					coma_def=array:get(?coma_def, PetPropetry#petProperty.propertyArray),
					hold_def=array:get(?hold_def, PetPropetry#petProperty.propertyArray),
					silent_def=array:get(?silent_def, PetPropetry#petProperty.propertyArray),
					move_def=array:get(?move_def, PetPropetry#petProperty.propertyArray),
					atkPowerGrowUp_Max=PetPropetry#petProperty.atkPowerGrowUp_Max,
					defClassGrowUp_Max=PetPropetry#petProperty.defClassGrowUp_Max,
					hpGrowUp_Max=PetPropetry#petProperty.hpGrowUp_Max,
					benison_Value=PetPropetry#petProperty.benison_Value
					}.

%%发送所有宠物数据给客户端
sendAllPetToClient(PetList) ->
	case PetList of
		[] ->ok;
		_ ->
			put("PetTmpValue", []),
			Fun = fun(R) ->
						  put("PetTmpValue", get("PetTmpValue") ++ [makePetPropetryPackage(R)])
				  end,
			lists:map(Fun, PetList),
			Msg = #pk_PlayerPetInfo{
									petSkillBag = petSealStore:getPlayerPetSealAhs(),
									petInfos = get("PetTmpValue")
									},
			player:send(Msg)
	end.

%%发送单个宠物数据给客户端
sendOnePetToClient(Pet) ->
	case Pet of
		{} ->ok;
		_ ->
			player:send(#pk_UpdatePetProerty{
											 petInfo = makePetPropetryPackage(Pet)
											 })
	end.

%%
onCreatePet(DataId) ->
	case length(get("PetList")) < ?Player_Pet_Max_Num of
		true->
			case createPetByDataId(DataId) of
				{} ->{};
				Pet->
					put("PetList", get("PetList") ++ [Pet]),
					mySqlProcess:insertPetPropertyGamedata(Pet),
					Pet
			end;
		false ->
			{}
	end.

%%根据dataid创建宠物
createPetByDataId(DataId) ->
	case etsBaseFunc:readRecord(pet:getPetCfgTable(), DataId) of
		{} ->
			{};
		PetCfg ->
			Property = #petProperty{
									id= db:memKeyIndex(petproperty_gamedata), % persistent
									data_id=DataId,
									masterId=player:getCurPlayerID(),
									level=1,
									exp=0,
									name="",
									titleId=0,
									aiState=?Pet_AI_State_PassiveFight,
									showModel=?PetShowModel_Model,
									exModelId=0,
									soulLevel=0, 
									soulRate=0,
									attackGrowUp=calculateAttackGrowUpValue(PetCfg),
									defGrowUp=calculateDefGrowUpValue(PetCfg), 
									lifeGrowUp=calculateLifeGrowUpValue(PetCfg),
									isWashGrow=?PetWashGrowUpValue_NO,
									attackGrowUpWash=0,
									defGrowUpWash=0,
									lifeGrowUpWash=0,
									convertRatio=?Pet_Base_ConvertRatio,
									exerciseLevel=0,
									moneyExrciseNum=0,
									exerciseExp=0,
									maxSkillNum=?Pet_SkillDefaultMax_Num,
									skills=createPetSkill(PetCfg),
									life=0,
									atkPowerGrowUp_Max=calculateAttackGrowUpMaxValue(PetCfg),
									defClassGrowUp_Max=calculateDefGrowUpMaxValue(PetCfg), 
									hpGrowUp_Max=calculateLifeGrowUpMaxValue(PetCfg),
									benison_Value=0,
									propertyArray=0
								   },
			Property2 = setelement(#petProperty.propertyArray, Property, calculatePetBaseProperty(Property)),
			Property3 = setelement(#petProperty.life, Property2, array:get(?max_life, Property2#petProperty.propertyArray)),
			Property3
	end.

%%创建宠物技能,随机一个技能给宠物
createPetSkill(PetCfg) ->
	case random:uniform(6) of
		1 ->
			Id = PetCfg#petCfg.petBorn_Skill1;
		2 ->
			Id = PetCfg#petCfg.petBorn_Skill2;
		3 ->
			Id = PetCfg#petCfg.petBorn_Skill3;
		4 ->
			Id = PetCfg#petCfg.petBorn_Skill4;
		5 ->
			Id = PetCfg#petCfg.petBorn_Skill5;
		6 ->
			Id = PetCfg#petCfg.petBorn_Skill6;
		_->
			Id = 0
	end,
	case etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), Id) of
		{}->[];
		_SkillCfg ->
			[#petSkill{skillId=Id, coolDownTime={0,0,0}}]
	end.

%%计算攻击成长率
calculateAttackGrowUpValue(PetCfg) ->
	case PetCfg#petCfg.atkPower_GUR1 >= PetCfg#petCfg.atkPower_GUR2 of
		true->PetCfg#petCfg.atkPower_GUR1;
		_->random:uniform(PetCfg#petCfg.atkPower_GUR2-PetCfg#petCfg.atkPower_GUR1)+PetCfg#petCfg.atkPower_GUR1
	end.

%%计算防御成长率
calculateDefGrowUpValue(PetCfg) ->
	case PetCfg#petCfg.defClass_GUR1 >= PetCfg#petCfg.defClass_GUR2 of
		true->PetCfg#petCfg.defClass_GUR1;
		_->
			random:uniform(PetCfg#petCfg.defClass_GUR2-PetCfg#petCfg.defClass_GUR1)+PetCfg#petCfg.defClass_GUR1
	end.

%%计算生命成长率
calculateLifeGrowUpValue(PetCfg) ->
	case PetCfg#petCfg.hp_GUR1 >= PetCfg#petCfg.hp_GUR2 of
		true->PetCfg#petCfg.hp_GUR1;
		_->random:uniform(PetCfg#petCfg.hp_GUR2-PetCfg#petCfg.hp_GUR1)+PetCfg#petCfg.hp_GUR1
	end.

%%计算攻击成长率最大值
calculateAttackGrowUpMaxValue(PetCfg) ->
	case PetCfg#petCfg.atkPower_MaxGUR1 >= PetCfg#petCfg.atkPower_MaxGUR2 of
		true->PetCfg#petCfg.atkPower_MaxGUR1;
		_->
			random:uniform(PetCfg#petCfg.atkPower_MaxGUR2-PetCfg#petCfg.atkPower_MaxGUR1)+PetCfg#petCfg.atkPower_MaxGUR1
	end.

%%计算防御成长率最大值
calculateDefGrowUpMaxValue(PetCfg) ->
	case PetCfg#petCfg.defClass_MaxGUR1 >= PetCfg#petCfg.defClass_MaxGUR2 of
		true->PetCfg#petCfg.defClass_MaxGUR1;
		_->random:uniform(PetCfg#petCfg.defClass_MaxGUR2-PetCfg#petCfg.defClass_MaxGUR1)+PetCfg#petCfg.defClass_MaxGUR1
	end.

%%计算生命成长率最大值
calculateLifeGrowUpMaxValue(PetCfg) ->
	case PetCfg#petCfg.hp_MaxGUR1 >= PetCfg#petCfg.hp_MaxGUR2 of
		true->PetCfg#petCfg.hp_MaxGUR1;
		_->
			random:uniform(PetCfg#petCfg.hp_MaxGUR2-PetCfg#petCfg.hp_MaxGUR1)+PetCfg#petCfg.hp_MaxGUR1
	end.

%%计算宠物基础属性
calculatePetBaseProperty(#petProperty{}=Pet) ->
	case etsBaseFunc:readRecord(pet:getPetLevelPropertyCfgTable(), Pet#petProperty.level) of
		{} ->
			array:new( ?property_count, {default, 0} );
		LevelCfg ->
			case etsBaseFunc:readRecord(pet:getPetCfgTable(), Pet#petProperty.data_id) of
				{} ->
					array:new( ?property_count, {default, 0} );
				PetCfg->
					case etsBaseFunc:readRecord(pet:getPetSoulUpCfgTable(), Pet#petProperty.soulLevel) of
						{}->
							array:new( ?property_count, {default, 0} );
						SoulCfg ->
							put("PetPropertyArray", charDefine:iniPetBasePropertyByLevel(LevelCfg)),
							%%攻击力
							put("PetPropertyArray", array:set(?attack, 
														  erlang:trunc(array:get(?attack, get("PetPropertyArray"))*
															  (Pet#petProperty.attackGrowUp/?Ratio_Value)*
															  (SoulCfg#petSoulUpCfg.soulAtkPower_Multi/?Ratio_Value)), 
														  get("PetPropertyArray"))),
							%%防御力
							put("PetPropertyArray", array:set(?defence, 
														   erlang:trunc(array:get(?defence, get("PetPropertyArray"))*
															  (Pet#petProperty.defGrowUp/?Ratio_Value)*
															  (SoulCfg#petSoulUpCfg.soulDefClass_Multi/?Ratio_Value)), 
														  get("PetPropertyArray"))),
							%%生命上限
							put("PetPropertyArray", array:set(?max_life, 
														   erlang:trunc(array:get(?max_life, get("PetPropertyArray"))*
															  (Pet#petProperty.lifeGrowUp/?Ratio_Value)*
															  (SoulCfg#petSoulUpCfg.soulMaxHp_Multi/?Ratio_Value)), 
														  get("PetPropertyArray"))),
							%%生命秒回
							put("PetPropertyArray", array:set(?life_recover_MaxLife, 
														   erlang:trunc(array:get(?life_recover_MaxLife, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.hpSecRate_Plus)), 
														  get("PetPropertyArray"))),
							%%击中回血
							put("PetPropertyArray", array:set(?been_attack_recover, 
														   erlang:trunc(array:get(?been_attack_recover, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.hPSteal_Plus)), 
														  get("PetPropertyArray"))),
							%%基础物抗
							put("PetPropertyArray", array:set(?ph_def, 
														   erlang:trunc(array:get(?ph_def, get("PetPropertyArray")) * 
															  (PetCfg#petCfg.physicRes_Multi/?Ratio_Value)), 
														  get("PetPropertyArray"))),
							%%基础火抗
							put("PetPropertyArray", array:set(?fire_def, 
														   erlang:trunc(array:get(?fire_def, get("PetPropertyArray")) * 
															  (PetCfg#petCfg.fireRes_Multi/?Ratio_Value)), 
														  get("PetPropertyArray"))),
							%%基础冰抗
							put("PetPropertyArray", array:set(?ice_def, 
														   erlang:trunc(array:get(?ice_def, get("PetPropertyArray")) * 
															  (PetCfg#petCfg.iceRes_Multi/?Ratio_Value)), 
														  get("PetPropertyArray"))),
							%%基础电抗
							put("PetPropertyArray", array:set(?elec_def, 
														   erlang:trunc(array:get(?elec_def, get("PetPropertyArray")) * 
															  (PetCfg#petCfg.lightingRes_Multi/?Ratio_Value)), 
														  get("PetPropertyArray"))),
							%%基础毒抗
							put("PetPropertyArray", array:set(?poison_def, 
														   erlang:trunc(array:get(?poison_def, get("PetPropertyArray")) * 
															  (PetCfg#petCfg.poisonRes_Multi/?Ratio_Value)), 
														  get("PetPropertyArray"))),
							%%命中率
							put("PetPropertyArray", array:set(?hit_rate_rate, 
														   erlang:trunc(array:get(?hit_rate_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.hitRate_Plus)), 
														  get("PetPropertyArray"))),
							%%闪避率
							put("PetPropertyArray", array:set(?dodge_rate, 
														   erlang:trunc(array:get(?dodge_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.dodgeRate_Plus)), 
														  get("PetPropertyArray"))),
							%%格挡率
							put("PetPropertyArray", array:set(?block_rate, 
														   erlang:trunc(array:get(?block_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.blockRate_Plus)), 
														  get("PetPropertyArray"))),
							%%暴击率
							put("PetPropertyArray", array:set(?crit_rate, 
														   erlang:trunc(array:get(?crit_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.criticalRate_Plus)), 
														  get("PetPropertyArray"))),
							%%穿透率
							put("PetPropertyArray", array:set(?pierce_rate, 
														   erlang:trunc(array:get(?pierce_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.penetrateRate_Plus)), 
														  get("PetPropertyArray"))),
							%%攻速率
							put("PetPropertyArray", array:set(?attack_speed_rate, 
														   erlang:trunc(array:get(?attack_speed_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.hasteRate_Plus)), 
														  get("PetPropertyArray"))),
							%%坚韧率
							put("PetPropertyArray", array:set(?tough_rate, 
														   erlang:trunc(array:get(?tough_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.toughRate_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础暴击伤害系数,加法
							put("PetPropertyArray", array:set(?crit_damage_rate, 
														   erlang:trunc(array:get(?crit_damage_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.criticalFactor_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础格挡减伤系数，加法
							put("PetPropertyArray", array:set(?block_dec_damage, 
														   erlang:trunc(array:get(?block_dec_damage, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.blockFactor_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础攻物理伤害系数，加法
							put("PetPropertyArray", array:set(?phy_attack_rate, 
														   erlang:trunc(array:get(?phy_attack_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.atkPhyFactor_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础攻火伤害系数，加法
							put("PetPropertyArray", array:set(?fire_attack_rate, 
														   erlang:trunc(array:get(?fire_attack_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.atkFireFactor_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础攻冰伤害系数，加法
							put("PetPropertyArray", array:set(?ice_attack_rate, 
														   erlang:trunc(array:get(?ice_attack_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.atkIceFactor_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础攻电伤害系数，加法
							put("PetPropertyArray", array:set(?elec_attack_rate, 
														   erlang:trunc(array:get(?elec_attack_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.atkLigFactor_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础攻毒伤害系数，加法
							put("PetPropertyArray", array:set(?poison_attack_rate, 
														   erlang:trunc(array:get(?poison_attack_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.atkPoiFactor_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础防物理伤害系数，加法
							put("PetPropertyArray", array:set(?phy_def_rate, 
														   erlang:trunc(array:get(?phy_def_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.defPhyFactor_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础防火伤害系数，加法
							put("PetPropertyArray", array:set(?fire_def_rate, 
														   erlang:trunc(array:get(?fire_def_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.defFireFactor_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础防冰伤害系数，加法
							put("PetPropertyArray", array:set(?ice_def_rate, 
														   erlang:trunc(array:get(?ice_def_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.defIceFactor_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础防电伤害系数，加法
							put("PetPropertyArray", array:set(?elec_def_rate, 
														   erlang:trunc(array:get(?elec_def_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.defLigFactor_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础防毒伤害系数，加法
							put("PetPropertyArray", array:set(?poison_def_rate, 
														   erlang:trunc(array:get(?poison_def_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.defPoiFactor_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础造成治疗效果系数，加法
							put("PetPropertyArray", array:set(?treat_rate, 
														   erlang:trunc(array:get(?treat_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.castHealFactor_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础受到治疗效果系数，加法
							put("PetPropertyArray", array:set(?treat_rate_been, 
														   erlang:trunc(array:get(?treat_rate_been, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.tagHealFactor_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础昏迷抵抗率，加法
							put("PetPropertyArray", array:set(?coma_def_rate, 
														   erlang:trunc(array:get(?coma_def_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.stunResRate_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础定身抵抗率，加法
							put("PetPropertyArray", array:set(?hold_def_rate, 
														   erlang:trunc(array:get(?hold_def_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.fastenResRate_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础沉默抵抗率，加法
							put("PetPropertyArray", array:set(?silent_def_rate, 
														   erlang:trunc(array:get(?silent_def_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.forbidResRate_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础减速抵抗率，加法
							put("PetPropertyArray", array:set(?move_def_rate, 
														   erlang:trunc(array:get(?move_def_rate, get("PetPropertyArray")) + 
															  (PetCfg#petCfg.slowResRate_Plus)), 
														  get("PetPropertyArray"))),
							%%宠物基础速度
							put("PetPropertyArray", array:set(?move_speed, 
														   erlang:trunc(array:get(?move_speed, get("PetPropertyArray")) * 
															  (PetCfg#petCfg.runSpeed_Multi/?Ratio_Value)), 
														  get("PetPropertyArray"))),
							get("PetPropertyArray")
					end
			end
	end.


%%宠物死亡
onPetDead(Pet) ->
	player:setCurPlayerProperty(#player.outFightPet, 0),
	case pet:getPet(Pet#mapPet.id) of
		{}->ok;
		Property->
			%%设置宠物生命为最大生命
			Property2 = setelement(#petProperty.life, Property, array:get(?max_life, Pet#mapPet.finalProperty)),
			put("PetList", lists:keyreplace(Pet#mapPet.id, #petProperty.id, get("PetList"), Property2) )
	end.

%%地图进程收回宠物
onMapPetTakeBack(Pet) ->
	player:send(#pk_PetTakeBack{petId=Pet#mapPet.id}),
	player:setCurPlayerProperty(#player.outFightPet, 0),
	case pet:getPet(Pet#mapPet.id) of
		{}->ok;
		Property->
			%%设置宠物生命为地图宠物的生命
			Property2 = setelement(#petProperty.life, Property, Pet#mapPet.life),
			put("PetList", lists:keyreplace(Pet#mapPet.id, #petProperty.id, get("PetList"), Property2) )
	end.

%%宠物出战
onPetLetOutFight(PetId) ->
	CoolTime = globalSetup:getGlobalSetupValue(#globalSetup.pet_Call_CoolDownTime),
	case get("OutFightTime") of
		0 ->
			TimeDiff = CoolTime;
		Time ->
			Now = erlang:now(),
			TimeDiff = timer:now_diff(Now, Time)/1000
	end,
	
	case TimeDiff >= CoolTime of
		false ->
			player:send(#pk_PetOutFight_Result{ result=?Pet_OutFight_Result_Failed_CoolDown, petId=PetId});
		true ->
			case PetId =:= getPlayerOutFightPetId() of
				true ->
					player:send(#pk_PetOutFight_Result{ result=?Pet_OutFight_Result_Failed_AlreadyOutFight, petId=PetId});
				false ->
					case lists:keyfind(PetId, #petProperty.id, pet:getPlayerPetList()) of
						false->
							%%将错误的宠物收回
							player:setCurPlayerProperty(#player.outFightPet, 0),
							player:sendMsgToMap({petTakeRest, player:getCurPlayerID(), self(),PetId}),
							player:send(#pk_PetOutFight_Result{ result=?Pet_OutFight_Result_Failed_NotPet, petId=PetId});
						Pet ->
							case etsBaseFunc:readRecord(pet:getPetCfgTable(), Pet#petProperty.data_id) of
								{}->
									%%将错误的宠物收回
									player:setCurPlayerProperty(#player.outFightPet, 0),
									player:sendMsgToMap({petTakeRest, player:getCurPlayerID(), self(),PetId}),
									player:send(#pk_PetOutFight_Result{ result=?Pet_OutFight_Result_Failed_NotPet, petId=PetId});
								Cfg ->
									case  getPlayerOutFightPetId() of
										0 ->ok;
										FightPetId ->
											%%先收回出战的宠物
											player:sendMsgToMap({petTakeRest, player:getCurPlayerID(), self(),FightPetId})
									end,
									
									%dbProcess_PID ! { getPetBuffData, self(), Pet, Cfg }
									{BuffData, Pet, Cfg} = dbProcess:on_getPetBuffData( Pet, Cfg),
									petOutFight(BuffData, Pet, Cfg)
							end
					end
			end
	end.

%%处理地图进程返回的宠物出战
onPetOutFight_result(PetId, Result)->
	case Result of
		true ->
			player:setCurPlayerProperty(#player.outFightPet, PetId),
			put("OutFightTime", erlang:now()),
			playerMap:onPlayer_LevelEquipPet_Changed(),
			player:send(#pk_PetOutFight_Result{ result=?Pet_OutFight_Result_Succ, petId=PetId});
		false ->
			player:send(#pk_PetOutFight_Result{ result=?Pet_OutFight_Result_Failed_UnKnow, petId=PetId})
	end.

%%宠物休息
onPetTakeRest(PetId) ->
	CoolTime = globalSetup:getGlobalSetupValue(#globalSetup.pet_Call_CoolDownTime),
	case get("OutFightTime") of
		0 ->
			TimeDiff = CoolTime;
		Time ->
			Now = erlang:now(),
			TimeDiff = timer:now_diff(Now, Time)/1000
	end,
	
	case TimeDiff >= CoolTime of
		false ->
			player:send(#pk_PetTakeRest_Result{result=?Pet_TakeRest_Result_Failed_CoolDown, petId=0 });
		true->
			case PetId =:= getPlayerOutFightPetId() of
				true ->
					case lists:keyfind(PetId, #petProperty.id, pet:getPlayerPetList()) of
						false ->
							player:send(#pk_PetTakeRest_Result{result=?Pet_TakeRest_Result_Failed_NotPet, petId=0 });
						_Pet ->
							player:sendMsgToMap({petTakeRest, player:getCurPlayerID(), self(),PetId})
					end;
				false ->
					player:send(#pk_PetTakeRest_Result{result=?Pet_TakeRest_Result_Failed_PetNotOutFight, petId=0 })
			end
	end.

%%宠物休息返回
onPetTakeRestResult_S2S(Pet, Result) ->
	case Result of
		false->ok;
		true->
			player:setCurPlayerProperty(#player.outFightPet, 0),
			playerMap:onPlayer_LevelEquipPet_Changed(),
			player:send(#pk_PetTakeRest_Result{result=?Pet_TakeRest_Result_Succ, petId=0 }),
			case pet:getPet(Pet#mapPet.id) of
				{}->ok;
				Property->
					%%设置宠物生命为地图宠物的生命
					Property2 = setelement(#petProperty.life, Property, Pet#mapPet.life),
					put("PetList", lists:keyreplace(Pet#mapPet.id, #petProperty.id, get("PetList"), Property2) ),
					put("OutFightTime", erlang:now())
			end
	end.

%%宠物放生
onPetFreeCaptiveAnimals(PetId) ->
	case lists:keyfind(PetId, #petProperty.id, pet:getPlayerPetList()) of
		false->
			player:send(#pk_PetFreeCaptiveAnimals_Result{result=?PetFreeCaptiveAnimals_Result_Failed_Not, petId=PetId});
		Pet->
			case pet:getPlayerOutFightPetId() =:= Pet#petProperty.id of
				true ->
					%%宠物正在出战，不能放生
					player:send(#pk_PetFreeCaptiveAnimals_Result{result=?PetFreeCaptiveAnimals_Result_Failed_OutFight, petId=PetId});
				false->
					PetBaseId = Pet#petProperty.data_id,
					mySqlProcess:deleteRecordByTableNameAndId("petProperty_gamedata",Pet#petProperty.id),
					put("PetList", get("PetList") -- [Pet] ),
					player:send(#pk_PetFreeCaptiveAnimals_Result{result=?PetFreeCaptiveAnimals_Result_Succ, petId=PetId}),
					
					PlayerBase = player:getCurPlayerRecord(),
					ParamLog = #petremove_param{petbaseid=PetBaseId},
					logdbProcess:write_log_player_event(?EVENT_PET_REMOVE,ParamLog,PlayerBase)

			end
	end.

%%宠物幻化
onPetCompoundModel(PetId) ->
	case lists:keyfind(PetId, #petProperty.id, get("PetList")) of
		false ->
			player:send(#pk_PetCompoundModel_Result{result=?PetCompoundModel_Result_Failed_Not, petId=PetId});
		Pet ->
			case Pet#petProperty.exModelId of
				0 ->
					player:send(#pk_PetCompoundModel_Result{result=?PetCompoundModel_Result_Failed_NotExModel, petId=PetId});
				_ ->
					case Pet#petProperty.showModel of
						?PetShowModel_Model->
							ShowModel = Pet#petProperty.exModelId,
							Pet2 = setelement(#petProperty.showModel, Pet, ?PetShowModel_ExModel),
							put("PetList", lists:keyreplace(PetId, #petProperty.id, get("PetList"), Pet2) ),
							player:send(#pk_PetCompoundModel_Result{result=?PetCompoundModel_Result_Succ, petId=PetId}),
							%%发送最新的宠物属性给客户端
							player:send(#pk_UpdatePetProerty{petInfo=pet:makePetPropetryPackage(Pet2)});
						?PetShowModel_ExModel->
							PetCfg = etsBaseFunc:readRecord(pet:getPetCfgTable(), Pet#petProperty.data_id),
							ShowModel = PetCfg#petCfg.petID,
							Pet2 = setelement(#petProperty.showModel, Pet, ?PetShowModel_Model),
							put("PetList", lists:keyreplace(PetId, #petProperty.id, get("PetList"), Pet2) ),
							player:send(#pk_PetCompoundModel_Result{result=?PetCompoundModel_Result_Succ, petId=PetId}),
							%%发送最新的宠物属性给客户端
							player:send(#pk_UpdatePetProerty{petInfo=pet:makePetPropetryPackage(Pet2)});
						_->
							ShowModel = 0,
							ok
					end,
				
					
					case PetId =:= player:getCurPlayerProperty(#player.outFightPet) andalso ShowModel /= 0  of
						true->
							player:sendMsgToMap( {petChangeModel, PetId, ShowModel} );
						_->ok
					end
			end
	end.

%%刷新攻击成长率
washAttackGrowUpValue(PetCfg, Pet) ->
	Value = random:uniform(PetCfg#petCfg.maxGUR-PetCfg#petCfg.minGUR)+PetCfg#petCfg.minGUR+Pet#petProperty.attackGrowUp,
	case Value < 0 of
		true->
			0;
		false->
			case Value >Pet#petProperty.atkPowerGrowUp_Max of
				true->Pet#petProperty.atkPowerGrowUp_Max;
				false->Value
			end
	end.

%%刷新防御成长率
washDefGrowUpValue(PetCfg, Pet) ->
	Value = random:uniform(PetCfg#petCfg.maxGUR-PetCfg#petCfg.minGUR)+PetCfg#petCfg.minGUR+Pet#petProperty.defGrowUp,
	case Value < 0 of
		true->
			0;
		false->
			case Value >Pet#petProperty.defClassGrowUp_Max of
				true->Pet#petProperty.defClassGrowUp_Max;
				false->Value
			end
	end.

%%刷新生命成长率
cwashLifeGrowUpValue(PetCfg, Pet) ->
	Value = random:uniform(PetCfg#petCfg.maxGUR-PetCfg#petCfg.minGUR)+PetCfg#petCfg.minGUR+Pet#petProperty.lifeGrowUp,
	case Value < 0 of
		true->
			0;
		false->
			case Value >Pet#petProperty.hpGrowUp_Max of
				true->Pet#petProperty.hpGrowUp_Max;
				false->Value
			end
	end.

%%宠物刷新成长率
onPetWashGrowUpValue(PetId) ->
	case lists:keyfind(PetId, #petProperty.id, get("PetList")) of
		false->
			player:send(#pk_PetWashGrowUpValue_Result{result=?PetWashGrowUpValue_Result_Failed_NotPet, petId=PetId, attackGrowUp=0, defGrowUp=0, lifeGrowUp=0});
		Pet->
			case etsBaseFunc:readRecord(pet:getPetCfgTable(), Pet#petProperty.data_id) of
				{} ->
					player:send(#pk_PetWashGrowUpValue_Result{result=?PetWashGrowUpValue_Result_Failed_NotPet, petId=PetId, attackGrowUp=0, defGrowUp=0, lifeGrowUp=0});
				PetCfg ->
					DecMoney = globalSetup:getGlobalSetupValue(#globalSetup.pet_ResetGUR_Money),
					case playerMoney:canUsePlayerBindedMoney(DecMoney) of
						false ->
							player:send(#pk_PetWashGrowUpValue_Result{result=?PetWashGrowUpValue_Result_Failed_Money, petId=PetId, attackGrowUp=0, defGrowUp=0, lifeGrowUp=0});
						true ->
							[DecResult|DecItems] = playerItems:canDecItemInBag(
													 ?Item_Location_Bag, 
													 globalSetup:getGlobalSetupValue(#globalSetup.pet_ResetGUR_Item), 
													 globalSetup:getGlobalSetupValue(#globalSetup.pet_ResetGUR_ItemNum), "all"),
							case DecResult of
								false ->
									player:send(#pk_PetWashGrowUpValue_Result{result=?PetWashGrowUpValue_Result_Failed_Item, petId=PetId, attackGrowUp=0, defGrowUp=0, lifeGrowUp=0});
								true ->
									AttackGrow = washAttackGrowUpValue(PetCfg, Pet),
									DefGrow = washDefGrowUpValue(PetCfg, Pet),
									LifeGrow = cwashLifeGrowUpValue(PetCfg, Pet),
									Pet2=setelement(#petProperty.isWashGrow, Pet, ?PetWashGrowUpValue_YES),
									Pet3=setelement(#petProperty.attackGrowUpWash, Pet2, AttackGrow),
									Pet4=setelement(#petProperty.defGrowUpWash, Pet3, DefGrow),
									Pet5=setelement(#petProperty.lifeGrowUpWash, Pet4, LifeGrow),
									
									%%保存进玩家宠物列表
									put("PetList", lists:keyreplace(PetId, #petProperty.id, get("PetList"), Pet5) ),

									%%立即存档
									mySqlProcess:replacePetPropertyGamedata(Pet5),
									
									%%扣除money
									ParamTuple = #token_param{changetype = ?Money_Change_PetWashGrowUp,param1=Pet#petProperty.data_id},
									playerMoney:usePlayerBindedMoney(DecMoney, ?Money_Change_PetWashGrowUp, ParamTuple),
									%%扣除道具
									playerItems:decItemInBag(DecItems, ?Destroy_Item_Reson_PetWashGrowUp),
									player:send(#pk_PetWashGrowUpValue_Result{
																			  result=?PetWashGrowUpValue_Result_Succ, 
																			  petId=PetId, 
																			  attackGrowUp=AttackGrow, 
																			  defGrowUp=DefGrow, 
																			  lifeGrowUp=LifeGrow}),
									%% 洗成长LOG 				
									ParamLog = #washgrow_param{	petbaseid = #petProperty.data_id,
															   	decitem = globalSetup:getGlobalSetupValue(#globalSetup.pet_ResetGUR_Item),
															  	number = globalSetup:getGlobalSetupValue(#globalSetup.pet_ResetGUR_ItemNum),
																money_b = DecMoney},
									
									PlayerBase = player:getCurPlayerRecord(),
									logdbProcess:write_log_player_event(?EVENT_PET_WASHGROW,ParamLog,PlayerBase)
							end
					end
			end
	end.

%%替换成长率
onPetReplaceGrowUpValue(PetId) ->
	case lists:keyfind(PetId, #petProperty.id, get("PetList")) of
		false ->
			player:send(#pk_PetReplaceGrowUpValue_Result{result=?PetReplaceGrowUpValue_Not, petId=PetId});
		Pet ->
			case Pet#petProperty.isWashGrow of
				?PetWashGrowUpValue_YES ->
					%%替换成长率
					Pet2=setelement(#petProperty.isWashGrow, Pet, ?PetWashGrowUpValue_NO),
					Pet3=setelement(#petProperty.attackGrowUp, Pet2, Pet#petProperty.attackGrowUpWash),
					Pet4=setelement(#petProperty.defGrowUp, Pet3, Pet#petProperty.defGrowUpWash),
					Pet5=setelement(#petProperty.lifeGrowUp, Pet4, Pet#petProperty.lifeGrowUpWash),
					%%重新计算宠物属性
					Pet6 = setelement(#petProperty.propertyArray, Pet5, calculatePetBaseProperty(Pet5)),
					
					%%保存至玩家宠物列表
					put("PetList", lists:keyreplace(PetId, #petProperty.id, get("PetList"), Pet6) ),
					
					%%如果当前宠物为出战宠物，将宠物属性更新至地图进程
					case getPlayerOutFightPetId() /=0 andalso PetId =:= getPlayerOutFightPetId() of
						true->
							petMap:onPlayerPetPropertyChanged();
						_->ok
					end,
					
					%%返回替换成功给客户端
					player:send(#pk_PetReplaceGrowUpValue_Result{result=?PetReplaceGrowUpValue_Succ, petId=PetId}),
					%%发送最新的宠物属性给客户端
					player:send(#pk_UpdatePetProerty{petInfo=pet:makePetPropetryPackage(Pet6)});
				_ ->
					%%没有洗过成长率
					player:send(#pk_PetReplaceGrowUpValue_Result{result=?PetReplaceGrowUpValue_NotWash, petId=PetId})
			end
	end.

%%宠物灵性强化
onPetIntensifySoul(PetId) ->
	case lists:keyfind(PetId, #petProperty.id, get("PetList")) of
		false ->
			player:send(#pk_PetIntensifySoul_Result{result=?PetIntensifySoul_Failed_Not, petId=PetId, soulLevel=0, soulRate=0, benison_Value=0});
		Pet ->
			case Pet#petProperty.soulLevel >= ?PetIntensifySoul_Max_Level of
				true ->
					%%强化失败，灵性已经到最大等级
					player:send(#pk_PetIntensifySoul_Result{
															result=?PetIntensifySoul_Failed_LevelMax, 
															petId=PetId, 
															soulLevel=Pet#petProperty.soulLevel, 
															soulRate=Pet#petProperty.soulRate, 
															benison_Value=Pet#petProperty.benison_Value});
				false ->
					case etsBaseFunc:readRecord(pet:getPetSoulUpCfgTable(), Pet#petProperty.soulLevel) of
						{} ->
							player:send(#pk_PetIntensifySoul_Result{result=?PetIntensifySoul_Failed_Not, petId=PetId, soulLevel=0, soulRate=0, benison_Value=0});
						SoulCfg ->
							case playerMoney:canUsePlayerBindedMoney(SoulCfg#petSoulUpCfg.soul_Money) of
								false ->
									%%强化失败，金钱不足
									player:send(#pk_PetIntensifySoul_Result{
																	result=?PetIntensifySoul_Failed_Money, 
																	petId=PetId, 
																	soulLevel=Pet#petProperty.soulLevel, 
																	soulRate=Pet#petProperty.soulRate, 
																	benison_Value=Pet#petProperty.benison_Value});
								true ->
									[DecResult|DecItems] = playerItems:canDecItemInBag(
													 ?Item_Location_Bag, 
													 globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_Item), 
													 globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_ItemNum), 
													 "all"),
									case DecResult of
										false ->
											%%强化失败，道具不足
											player:send(#pk_PetIntensifySoul_Result{
																			result=?PetIntensifySoul_Failed_Item, 
																			petId=PetId, 
																			soulLevel=Pet#petProperty.soulLevel, 
																			soulRate=Pet#petProperty.soulRate, 
																			benison_Value=Pet#petProperty.benison_Value});
										true ->
											%%扣除金钱和道具
											ParamTuple = #token_param{changetype = ?Money_Change_PetIntensifySoul,param1=Pet#petProperty.data_id},
											playerMoney:usePlayerBindedMoney(SoulCfg#petSoulUpCfg.soul_Money, ?Money_Change_PetIntensifySoul, ParamTuple),
											playerItems:decItemInBag(DecItems, ?Destroy_Item_Reson_PetIntensifySoul),
											PlayerBase = player:getCurPlayerRecord(),
											
											case (Pet#petProperty.benison_Value+1) >= SoulCfg#petSoulUpCfg.benison_Max of
												true->
													%%强化等级提升，强化进度归0，祝福值归0
													Pet3 = Pet#petProperty{ soulLevel=Pet#petProperty.soulLevel+1, soulRate=0, benison_Value=0},
																	
													%%重新计算宠物属性
													Pet4 = setelement(#petProperty.propertyArray, Pet3, calculatePetBaseProperty(Pet3)),
																	
													%%返回强化成功
													player:send(#pk_PetIntensifySoul_Result{
																							result=?PetIntensifySoul_BenisonSucc, 
																							petId=PetId, 
																							soulLevel=Pet4#petProperty.soulLevel, 
																							soulRate=Pet4#petProperty.soulRate, 
																							benison_Value=0}),
													%%发送宠物最新属性给客户端
													player:send(#pk_UpdatePetProerty{petInfo=pet:makePetPropetryPackage(Pet4)}),
																	
													PlayerName = player:getPlayerProperty( player:getCurPlayerID(), #player.name ),
													%% 是否满足全服通告条件
													case Pet3#petProperty.soulLevel of
														?PET_STRENGTHEN_15->
															Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_PET_STRENGTHEN_15, [PlayerName]),
															put("WorldBrodcaseString",Str);
														?PET_STRENGTHEN_19->
															Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_PET_STRENGTHEN_19, [PlayerName]),
															put("WorldBrodcaseString",Str);
														?PET_STRENGTHEN_20->
															Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_PET_STRENGTHEN_20, [PlayerName]),
															put("WorldBrodcaseString",Str);
														_->
															ok
													end,	
																																
													case BrodcaseString = get("WorldBrodcaseString") of
														false->	ok;
														undefined->	ok;
														_->	
															systemMessage:sendSysMsgToAllPlayer(BrodcaseString),
															put("WorldBrodcaseString",false)
													end,
													%% 强化宠物LOG 
													ParamLog = #petstrengthen_param{petbaseid = #petProperty.data_id,
																					level = Pet#petProperty.soulLevel,
																					result = 1,
																					soule = SoulCfg#petSoulUpCfg.soule_Step,
																					decitem = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_Item),
																					number = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_ItemNum),
																					money_b = SoulCfg#petSoulUpCfg.soul_Money},	
													logdbProcess:write_log_player_event(?EVENT_PET_STRENGTHEN,ParamLog,PlayerBase),
										
													%%保存至玩家宠物列表
													put("PetList", lists:keyreplace(PetId, #petProperty.id, get("PetList"), Pet4) ),
													
													%%如果当前宠物为出战宠物，将宠物属性更新至地图进程
													case getPlayerOutFightPetId() /=0 andalso PetId =:= getPlayerOutFightPetId() of
														true->
															petMap:onPlayerPetPropertyChanged();
														_->ok
													end;
												_->
													case random:uniform(10000) =< SoulCfg#petSoulUpCfg.soul_Rate of
														false ->
															%%强化失败，当前强化进度归0，当前祝福值+1
															Pet2 = Pet#petProperty{soulRate=0, benison_Value=Pet#petProperty.benison_Value+1},
															%%保存至玩家宠物列表
															put("PetList", lists:keyreplace(PetId, #petProperty.id, get("PetList"), Pet2) ),
															%%返回给客户端
															player:send(#pk_PetIntensifySoul_Result{
																									result=?PetIntensifySoul_Failed, 
																									petId=PetId, 
																									soulLevel=Pet2#petProperty.soulLevel, 
																									soulRate=0,
																									benison_Value=Pet2#petProperty.benison_Value}),
															
															%% 强化宠物LOG 
															ParamLog = #petstrengthen_param{petbaseid = #petProperty.data_id,
																						 	level = Pet#petProperty.soulLevel,
																						 	result = 0,
																							soule = 0,
																						 	decitem = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_Item),
																						 	number = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_ItemNum),
																						 	money_b = SoulCfg#petSoulUpCfg.soul_Money},										
															
															logdbProcess:write_log_player_event(?EVENT_PET_STRENGTHEN,ParamLog,PlayerBase);
														true ->
															%%强化成功，当前强化进度+1
															case (Pet#petProperty.soulRate+1) >= SoulCfg#petSoulUpCfg.soule_Step of
																true ->
																	%%强化等级提升，强化进度归0，祝福值归0
																	Pet3 = Pet#petProperty{ soulLevel=Pet#petProperty.soulLevel+1, soulRate=0, benison_Value=0},
																	
																	%%重新计算宠物属性
																	Pet4 = setelement(#petProperty.propertyArray, Pet3, calculatePetBaseProperty(Pet3)),
																	
																	%%返回强化成功
																	player:send(#pk_PetIntensifySoul_Result{
																											result=?PetIntensifySoul_Succ, 
																											petId=PetId, 
																											soulLevel=Pet4#petProperty.soulLevel, 
																											soulRate=Pet4#petProperty.soulRate, 
																											benison_Value=0}),
																	%%发送宠物最新属性给客户端
																	player:send(#pk_UpdatePetProerty{petInfo=pet:makePetPropetryPackage(Pet4)}),
																	
																	PlayerName = player:getPlayerProperty( player:getCurPlayerID(), #player.name ),
																	%% 是否满足全服通告条件
																	case Pet3#petProperty.soulLevel of
																		?PET_STRENGTHEN_15->
																			Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_PET_STRENGTHEN_15, [PlayerName]),
																			put("WorldBrodcaseString",Str);	
																		?PET_STRENGTHEN_19->
																			Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_PET_STRENGTHEN_19, [PlayerName]),
																			put("WorldBrodcaseString",Str);
																		?PET_STRENGTHEN_20->
																			Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_PET_STRENGTHEN_20, [PlayerName]),
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
		
																	%% 强化宠物LOG 
																	ParamLog = #petstrengthen_param{petbaseid = #petProperty.data_id,
																								 	level = Pet#petProperty.soulLevel,
																								 	result = 1,
																									soule = SoulCfg#petSoulUpCfg.soule_Step,	
																								 	decitem = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_Item),
																								 	number = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_ItemNum),
																								 	money_b = SoulCfg#petSoulUpCfg.soul_Money},										
																			
																			logdbProcess:write_log_player_event(?EVENT_PET_STRENGTHEN,ParamLog,PlayerBase);
																		false ->
																			Pet4 = Pet#petProperty{ 
																								   soulRate=Pet#petProperty.soulRate+1, 
																								   benison_Value=Pet#petProperty.benison_Value+1}, 
																			player:send(#pk_PetIntensifySoul_Result{
																											result=?PetIntensifySoul_Succ, 
																											petId=PetId, 
																											soulLevel=Pet4#petProperty.soulLevel, 
																											soulRate=Pet4#petProperty.soulRate, 
																											benison_Value=Pet4#petProperty.benison_Value}),
																	%% 强化宠物LOG 
																	ParamLog = #petstrengthen_param{petbaseid = #petProperty.data_id,
																								 	level = Pet#petProperty.soulLevel,
																								 	result = 1,
																									soule = Pet#petProperty.soulRate+1,
																								 	decitem = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_Item),
																								 	number = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_ItemNum),
																								 	money_b = SoulCfg#petSoulUpCfg.soul_Money},										
																	
																	logdbProcess:write_log_player_event(?EVENT_PET_STRENGTHEN,ParamLog,PlayerBase)
															end,
															%%保存至玩家宠物列表
															put("PetList", lists:keyreplace(PetId, #petProperty.id, get("PetList"), Pet4) ),
															%%立即存档
															mySqlProcess:replacePetPropertyGamedata(Pet4),
															
															%%如果当前宠物为出战宠物，将宠物属性更新至地图进程
															case getPlayerOutFightPetId() /=0 andalso PetId =:= getPlayerOutFightPetId() of
																true->
																	petMap:onPlayerPetPropertyChanged();
																_->ok
															end
													end
											end
									end
							end
					end
			end
	end.

%%一键灵性强化
onOneKeyIntensifySoul(PetId) ->
	case lists:keyfind(PetId, #petProperty.id, get("PetList")) of
		false ->
			player:send(#pk_PetIntensifySoul_Result{result=?PetIntensifySoul_Failed_Not, petId=PetId, soulLevel=0, soulRate=0, benison_Value=0});
		Pet ->
			case Pet#petProperty.soulLevel >= ?PetIntensifySoul_Max_Level of
				true ->
					%%强化失败，灵性已经到最大等级
					player:send(#pk_PetIntensifySoul_Result{
															result=?PetIntensifySoul_Failed_LevelMax, 
															petId=PetId, 
															soulLevel=Pet#petProperty.soulLevel, 
															soulRate=Pet#petProperty.soulRate, 
															benison_Value=Pet#petProperty.benison_Value});
				false ->
					case etsBaseFunc:readRecord(pet:getPetSoulUpCfgTable(), Pet#petProperty.soulLevel) of
						{} ->
							player:send(#pk_PetIntensifySoul_Result{result=?PetIntensifySoul_Failed_Not, petId=PetId, soulLevel=0, soulRate=0, benison_Value=0});
						SoulCfg->
							[Result,{PetNew, ItemCount, Money}] = recursionIntensifySoul(Pet, SoulCfg, 0, 0),
							%%从新计算属性
							Pet2 = setelement(#petProperty.propertyArray, PetNew, calculatePetBaseProperty(PetNew)),
							%%保存至玩家宠物列表
							put("PetList", lists:keyreplace(PetId, #petProperty.id, get("PetList"), Pet2) ),
							
							%%立即存档
							mySqlProcess:replacePetPropertyGamedata(Pet2),
							
							%%如果当前宠物为出战宠物，将宠物属性更新至地图进程
							case getPlayerOutFightPetId() /=0 andalso PetId =:= getPlayerOutFightPetId() of
								true->
									petMap:onPlayerPetPropertyChanged();
								_->ok
							end,
							player:send(#pk_PetOneKeyIntensifySoul_Result{petId=PetId, result=Result, itemCount=ItemCount, money=Money}),
							%%发送宠物最新属性给客户端
							player:send(#pk_UpdatePetProerty{petInfo=pet:makePetPropetryPackage(Pet2)})
					end
			end
	end.

%%递归强化灵性，直到强化到下一等级，或者强化道具和金钱不足
%%return  : [Result,{Pet, ItemCount, Money}]
recursionIntensifySoul(Pet, SoulCfg, Count, Money) ->
	PlayerBase = player:getCurPlayerRecord(),
	case playerMoney:canUsePlayerBindedMoney(SoulCfg#petSoulUpCfg.soul_Money) of
		false ->ParamLog = #petstrengall_param{petbaseid = Pet#petProperty.data_id,
											 	level = Pet#petProperty.soulLevel,
											 	result = 0,
												soule = Pet#petProperty.soulRate,
											 	decitem = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_Item),
											 	number = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_ItemNum)*Count,
											 	money_b = SoulCfg#petSoulUpCfg.soul_Money*Count},										
				
				logdbProcess:write_log_player_event(?EVENT_PET_STRANGALL,ParamLog,PlayerBase),
			%%强化失败，金钱不足
			[?PetIntensifySoul_Failed_Money, {Pet, Count, Money}];
		true ->
			ItemId = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_Item),
			ItemNum = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_ItemNum),
			[DecResult|DecItems] = playerItems:canDecItemInBag(
									 ?Item_Location_Bag,
									 ItemId, 
									 ItemNum,
									 "all"),
			case DecResult of
				false ->
						ParamLog = #petstrengall_param{petbaseid = Pet#petProperty.data_id,
												 	level = Pet#petProperty.soulLevel,
												 	result = 0,
													soule = Pet#petProperty.soulRate,
												 	decitem = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_Item),
												 	number = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_ItemNum)*Count,
												 	money_b = SoulCfg#petSoulUpCfg.soul_Money*Count},										
					
						logdbProcess:write_log_player_event(?EVENT_PET_STRANGALL,ParamLog,PlayerBase),
					%%强化失败，道具不足
					[?PetIntensifySoul_Failed_Item, {Pet, Count, Money}];
				true ->
					%%扣除金钱和道具
					ParamTuple = #token_param{changetype = ?Money_Change_PetIntensifySoul,param1=Pet#petProperty.data_id},
					playerMoney:usePlayerBindedMoney(SoulCfg#petSoulUpCfg.soul_Money, ?Money_Change_PetIntensifySoul, ParamTuple),
					playerItems:decItemInBag(DecItems, ?Destroy_Item_Reson_PetIntensifySoul),
					
					case (Pet#petProperty.benison_Value+1) >= SoulCfg#petSoulUpCfg.benison_Max of
						true->
							%%等级提升，强化进度归0，祝福值归0
							Pet3 = Pet#petProperty{ soulLevel=Pet#petProperty.soulLevel+1, soulRate=0, benison_Value=0},
							
							PlayerName = player:getPlayerProperty( player:getCurPlayerID(), #player.name ),									
							
							%% 是否满足全服通告条件
							case Pet3#petProperty.soulLevel of
								?PET_STRENGTHEN_15->
									Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_PET_STRENGTHEN_15, [PlayerName]),
									put("WorldBrodcaseString",Str);	
								?PET_STRENGTHEN_19->
									Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_PET_STRENGTHEN_19, [PlayerName]),
									put("WorldBrodcaseString",Str);
								?PET_STRENGTHEN_20->
									Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_PET_STRENGTHEN_20, [PlayerName]),
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
							
							%% 强化宠物LOG 
							ParamLog = #petstrengall_param{petbaseid = Pet#petProperty.data_id,
														 	level = Pet#petProperty.soulLevel,
														 	result = 1,
															soule = SoulCfg#petSoulUpCfg.soule_Step,
														 	decitem = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_Item),
														 	number = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_ItemNum)*Count,
														 	money_b = SoulCfg#petSoulUpCfg.soul_Money*Count},										
							
							logdbProcess:write_log_player_event(?EVENT_PET_STRANGALL,ParamLog,PlayerBase),
							%%强化完成，函数返回
							[?PetIntensifySoul_BenisonSucc, {Pet3, Count+ItemNum, Money+SoulCfg#petSoulUpCfg.soul_Money}];
						_->
							case random:uniform(10000) =< SoulCfg#petSoulUpCfg.soul_Rate of
								false ->
									%%强化失败，当前强化进度归0，祝福值+1
									Pet2 = Pet#petProperty{soulRate=0, benison_Value=Pet#petProperty.benison_Value+1 },
									%%继续强化
									recursionIntensifySoul(Pet2, SoulCfg, Count+ItemNum, Money+SoulCfg#petSoulUpCfg.soul_Money);
								true ->
									%%强化成功，当前强化进度+1
									case (Pet#petProperty.soulRate+1) >= SoulCfg#petSoulUpCfg.soule_Step of
										true ->
											%%等级提升，强化进度归0，祝福值归0
											Pet3 = Pet#petProperty{ soulLevel=Pet#petProperty.soulLevel+1, soulRate=0, benison_Value=0},
											
											PlayerName = player:getPlayerProperty( player:getCurPlayerID(), #player.name ),									
											
											%% 是否满足全服通告条件
											case Pet3#petProperty.soulLevel of
												?PET_STRENGTHEN_15->
													Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_PET_STRENGTHEN_15, [PlayerName]),
													put("WorldBrodcaseString",Str);	
												?PET_STRENGTHEN_19->
													Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_PET_STRENGTHEN_19, [PlayerName]),
													put("WorldBrodcaseString",Str);
												?PET_STRENGTHEN_20->
													Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_PET_STRENGTHEN_20, [PlayerName]),
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
											
											%% 强化宠物LOG 
											ParamLog = #petstrengall_param{petbaseid = Pet#petProperty.data_id,
																		 	level = Pet#petProperty.soulLevel,
																		 	result = 1,
																			soule = SoulCfg#petSoulUpCfg.soule_Step,
																		 	decitem = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_Item),
																		 	number = globalSetup:getGlobalSetupValue(#globalSetup.pet_Soul_ItemNum)*Count,
																		 	money_b = SoulCfg#petSoulUpCfg.soul_Money*Count},										
											
											logdbProcess:write_log_player_event(?EVENT_PET_STRANGALL,ParamLog,PlayerBase),
											%%强化完成，函数返回
											[?PetIntensifySoul_Succ, {Pet3, Count+ItemNum, Money+SoulCfg#petSoulUpCfg.soul_Money}];
										false ->
											Pet4 = Pet#petProperty{ soulRate=Pet#petProperty.soulRate+1, benison_Value=Pet#petProperty.benison_Value+1},
											%%继续强化
											recursionIntensifySoul(Pet4, SoulCfg, Count+ItemNum, Money+SoulCfg#petSoulUpCfg.soul_Money)
									end
							end
					end
			end
	end.

%%宠物融合
onPetFuse(PetSrcId, PetDestId) ->
	case PetSrcId=:=PetDestId of
		true ->
			player:send(#pk_PetFuse_Result{result=?PetFuse_Failed_SrcEqualDest, petSrcId=PetSrcId, petDestId=PetDestId});
		false ->
			OutFightPetID = player:getCurPlayerProperty(#player.outFightPet),
			case OutFightPetID =:= PetSrcId orelse OutFightPetID =:= PetDestId of
				true->
					player:send(#pk_PetFuse_Result{result=?PetFuse_Failed_OutFight, petSrcId=PetSrcId, petDestId=PetDestId});
				false->
					case lists:keyfind(PetSrcId, #petProperty.id, get("PetList")) of
						false ->
							player:send(#pk_PetFuse_Result{result=?PetFuse_Failed_NotSrc, petSrcId=PetSrcId, petDestId=PetDestId});
						PetSrc ->
							case lists:keyfind(PetDestId, #petProperty.id, get("PetList")) of
								false ->
									player:send(#pk_PetFuse_Result{result=?PetFuse_Failed_NotDest, petSrcId=PetSrcId, petDestId=PetDestId});
								PetDest ->
									%%等级取更高的，经验清零
									Pet2 = setelement(#petProperty.level, PetSrc, erlang:max(PetDest#petProperty.level, PetSrc#petProperty.level)),
									Pet3 = setelement(#petProperty.exp, Pet2, 0),
							
									%%灵性等级融合
									case Pet3#petProperty.soulLevel =:= PetDest#petProperty.soulLevel of
										true ->
											Pet4 = setelement(#petProperty.soulRate, Pet3, max(Pet3#petProperty.soulRate, PetDest#petProperty.soulRate));
										false ->
											case Pet3#petProperty.soulLevel > PetDest#petProperty.soulLevel of
												true ->
													Pet4 = Pet3;
												false ->
													Pet5 = setelement(#petProperty.soulRate, Pet3, PetDest#petProperty.soulRate),
													Pet4 = setelement(#petProperty.soulLevel, Pet5, PetDest#petProperty.soulLevel)
											end
									end,
							
									case Pet4#petProperty.exerciseLevel =:= PetDest#petProperty.exerciseLevel of
										true ->
											Pet7 = setelement(#petProperty.exerciseExp, Pet4, max(Pet4#petProperty.exerciseExp, PetDest#petProperty.exerciseExp));
										false ->
											case Pet4#petProperty.exerciseLevel > PetDest#petProperty.exerciseLevel of
												true ->
													Pet7 =  Pet4;
												false ->
													Pet6 = setelement(#petProperty.exerciseExp, Pet4, PetDest#petProperty.exerciseExp),
													Pet7 = setelement(#petProperty.exerciseLevel, Pet6, PetDest#petProperty.exerciseLevel)
											end
									end,					
									Pet8 = setelement(#petProperty.propertyArray, Pet7, calculatePetBaseProperty(Pet7)),
									%%写入宠物幻化ID
									case etsBaseFunc:readRecord(pet:getPetCfgTable(), PetDest#petProperty.data_id) of
										{}->
											Pet9 = Pet8;
										PetCfg ->
											Pet9 = setelement(#petProperty.exModelId, Pet8, PetCfg#petCfg.petID)
									end,
									%%删除目标宠物
									put("PetList", get("PetList") -- [PetDest] ),
									mySqlProcess:deleteRecordByTableNameAndId("petProperty_gamedata",PetDestId),

									%%保存源宠物
									put("PetList", lists:keyreplace(PetSrcId, #petProperty.id, get("PetList"), Pet9) ),
									%%立即存档
									mySqlProcess:replacePetPropertyGamedata(Pet9),
							
									%%如果当前宠物为出战宠物，将宠物属性更新至地图进程
									case getPlayerOutFightPetId() /=0 andalso PetSrcId =:= getPlayerOutFightPetId() of
										true->
											petMap:onPlayerPetPropertyChanged();
										_->ok
									end,
					
									%%返回成功给客户端
									player:send(#pk_PetFuse_Result{result=?PetFuse_Succ, petSrcId=PetSrcId, petDestId=PetDestId}),
									%%发送删除目标宠物消息给客户端
									player:send(#pk_DelPet{petId=PetDestId}),
									%%发送最新宠物属性给客户端
									player:send(#pk_UpdatePetProerty{petInfo=pet:makePetPropetryPackage(Pet9)})
							end
					end
			end
	end.

onChangePetAIState(State) ->
	case player:getCurPlayerProperty(#player.outFightPet) of
		0 ->ok;
		PetId ->
			case lists:keyfind(PetId, #petProperty.id, get("PetList")) of
				false ->ok;
				_Pet ->
					player:sendMsgToMap({petChangeAIState, player:getCurPlayerID(), self(), PetId, State})
			end
	end.

onChangePetAIState_S2S(Result, PetId, State) ->
	case Result of
		false->ok;
		true ->
			case lists:keyfind(PetId, #petProperty.id, get("PetList")) of
				false ->ok;
				Pet ->
					Pet2 = setelement(#petProperty.aiState, Pet, State),
					%%保存宠物
					put("PetList", lists:keyreplace(PetId, #petProperty.id, get("PetList"), Pet2) ),
					player:send(#pk_ChangePetAIState{state=State})
			end
	end.

getPet(PetId) ->
	case lists:keyfind(PetId, #petProperty.id, pet:getPlayerPetList()) of
		false ->{};
		Pet ->
			Pet
	end.

%%给宠物增加经验
addPetExp(ChangeEXP, Reson) ->
	case getPet(player:getCurPlayerProperty(#player.outFightPet)) of
		{} ->ok;
		Pet ->
			PetNew = doAddPetExp(Pet, ChangeEXP),
			case Pet#petProperty.level =:= PetNew#petProperty.level of
				false ->
					%%升级了重新计算宠物属性并更新给客户端
					Pet2 = setelement(#petProperty.propertyArray, PetNew, calculatePetBaseProperty(PetNew)),
					player:send(#pk_UpdatePetProerty{petInfo=pet:makePetPropetryPackage(Pet2)});
				true ->Pet2=PetNew
			end,
			%%保存宠物
			put("PetList", lists:keyreplace(Pet2#petProperty.id, #petProperty.id, get("PetList"), Pet2) ),
			%%经验变化通知
			player:send(#pk_PetExpChanged{petId=Pet#petProperty.id, curExp=Pet2#petProperty.exp, reason=Reson}),
			
			case Pet2#petProperty.level /= Pet#petProperty.level of
				true->petMap:onPlayerPetPropertyChanged();
				_->ok
			end
	end.

doAddPetExp(Pet, ChangeEXP) ->
	case ChangeEXP=<0 of
		true ->
			Pet;
		false ->
			case etsBaseFunc:readRecord(pet:getPetLevelPropertyCfgTable(), Pet#petProperty.level) of
				{}->
					setelement(#petProperty.exp, Pet, Pet#petProperty.exp+ChangeEXP);
				LevelCfg ->
					case Pet#petProperty.exp+ChangeEXP >= LevelCfg#petLevelPropertyCfg.exp of
						true ->
							%%升级
							case Pet#petProperty.level >= player:getCurPlayerProperty(#player.level) of
								true ->
									%%等级不能大于玩家
									setelement(#petProperty.exp, Pet, LevelCfg#petLevelPropertyCfg.exp);
								false ->
									Exp = Pet#petProperty.exp+ChangeEXP-LevelCfg#petLevelPropertyCfg.exp,
									Pet2 = setelement(#petProperty.level, Pet, Pet#petProperty.level+1),
									Pet3 = setelement(#petProperty.exp, Pet2, 0),
									doAddPetExp(Pet3, Exp)
							end;
						false ->
							setelement(#petProperty.exp, Pet, Pet#petProperty.exp+ChangeEXP)
					end
			end
	end.

%%获取宠物学会的组技能
getPetLearnedGroupSkill( Pet, Group )->
	try
		Fun = fun( PetSkill )->
					  case etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), PetSkill#petSkill.skillId) of
						  {}->ok;
						  SkillCfg->
							  case SkillCfg#skillCfg.skill_group =:= Group of
								  true->throw( {PetSkill, SkillCfg} );
								  _->ok
							  end
					  end
			  end,
		lists:map(Fun, Pet#petProperty.skills),
		{}
	catch
		Return->Return
	end.

%%学习技能
onPetLearnSkill(PetId, SkillId) ->
	{Result, OldSkillID} = learnPetSkill(PetId, SkillId),
	player:send(#pk_PetLearnSkill_Result{result=Result, petId=PetId, oldSkillId=OldSkillID, newSkillId=SkillId}),
	
	%%如果宠物在出战状态，将学会技能的信息发送给地图进程
	case player:getCurPlayerProperty(#player.outFightPet) =:= PetId andalso 
			 ((Result=:= ?Pet_LearnSkill_Succ) or (Result=:= ?Pet_LevelUpSkill_Succ)) of
		true->
			player:sendMsgToMap({petLearnSkill, player:getCurPlayerID(), PetId, OldSkillID, SkillId});
		false->ok
	end.

%%给宠物添加技能
learnPetSkill(PetId, SkillId) ->
	try
		Pet = getPet(PetId),
		case Pet of
			{} ->throw({?Pet_LearnSkill_Failed_NotPet, 0});
			_ ->ok
		end,
		case lists:keyfind(SkillId, #petSkill.skillId, Pet#petProperty.skills) of
			false ->
				%%技能未学习
				ok;
			_ ->
				%%技能已经学习，不能再次学习
				throw({?Pet_LearnSkill_Failed_AlreadyLearn, 0})	
		end,
		
		%%技能配置
		SkillCfg = etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), SkillId),
		case SkillCfg of
			{} ->throw({?Pet_LearnSkill_Failed_NotFindSkill, 0});
			_ ->ok
		end,
		
		%%技能类型判断
		case SkillCfg#skillCfg.skillClass =:= ?SkillClass_Pet of
			true->ok;
			false->throw({?Pet_LearnSkill_Failed_NotPetClass, 0})
		end,
		
		%%是否已经学习本组技能
		case getPetLearnedGroupSkill( Pet, SkillCfg#skillCfg.skill_group ) of
			{}->ok;
			{ _, SkillCfg2 }->
				case SkillCfg2#skillCfg.level >= SkillCfg#skillCfg.level of
					true->throw({?Pet_LearnSkill_Failed_AlreadyLearnMax, 0} );
					_->ok
				end
		end,
		
		%%等级判断
		case SkillCfg#skillCfg.studylevel =< Pet#petProperty.level of
			true ->ok;
			false ->throw({?Pet_LearnSkill_Failed_LevelNotEnough, 0})
		end,
		
		%%金钱判断
		case playerMoney:canUsePlayerBindedMoney(SkillCfg#skillCfg.castMoney) of
			true ->ok;
			false ->throw({?Pet_LearnSkill_Failed_MoneyNotEnough, 0})
		end,
		
		%%道具判断
		[DecResult|DecItems] = playerItems:canDecItemInBag(?Item_Location_Bag, SkillCfg#skillCfg.useItemID, 1, "all"),
		case DecResult of
			true ->ok;
			false ->throw({?Pet_LearnSkill_Failed_ItemNotEnough, 0})
		end,
		
		case SkillCfg#skillCfg.level > 1 of
			false ->
				%%增加新技能，判断是否有空位
				case Pet#petProperty.maxSkillNum > length(Pet#petProperty.skills) of
					true ->
						%%扣除金钱和道具
						ParamTuple = #token_param{changetype = ?Money_Change_PetLearnSkill,param1=Pet#petProperty.data_id},
						playerMoney:usePlayerBindedMoney(SkillCfg#skillCfg.castMoney, ?Money_Change_PetLearnSkill,ParamTuple),
						playerItems:decItemInBag(DecItems, ?Destroy_Item_Reason_PetLearnSkill),
						%%学习技能
						NewSkill = #petSkill{skillId=SkillCfg#skillCfg.skill_id, coolDownTime={0,0,0}},
						Pet2 = setelement(#petProperty.skills, Pet, Pet#petProperty.skills ++ [NewSkill] ),
						put("PetList", lists:keyreplace(Pet#petProperty.id, #petProperty.id, pet:getPlayerPetList(), Pet2)),
						
						%%立即存档
						mySqlProcess:replacePetPropertyGamedata(Pet2),
						{?Pet_LearnSkill_Succ, SkillCfg#skillCfg.skill_id};
					false ->
						throw({?Pet_LearnSkill_Failed_NotSpace, 0})
				end;
			true ->
				%%升级老技能
				%%判断本技能前一个等级有没有学习
				case main:getSkillCfgByGroupAndLevel(SkillCfg#skillCfg.skill_group, SkillCfg#skillCfg.level-1) of
					{} ->
						throw({?Pet_LearnSkill_Failed_NotLearnFrontSkill, 0});
					SkillCfgFront ->
						case lists:keyfind(SkillCfgFront#skillCfg.skill_id, #petSkill.skillId, Pet#petProperty.skills) of
							false ->
								throw({?Pet_LearnSkill_Failed_NotLearnFrontSkill, 0});
							SkillFront ->
								%%扣除金钱和道具
								ParamTuple = #token_param{changetype = ?Money_Change_PetLearnSkill,param1=Pet#petProperty.data_id},
								playerMoney:usePlayerBindedMoney(SkillCfg#skillCfg.castMoney, ?Money_Change_PetLearnSkill, ParamTuple),
								playerItems:decItemInBag(DecItems, ?Destroy_Item_Reason_PetLearnSkill),
								
								NewSkill = #petSkill{skillId=SkillCfg#skillCfg.skill_id, coolDownTime={0,0,0} },
								Fun = fun(Record) ->
											  case Record#petSkill.skillId =:= SkillFront#petSkill.skillId of
												  true ->NewSkill;
												  false ->Record
											  end
									  end,
								Pet2 = setelement(#petProperty.skills, Pet, lists:map(Fun, Pet#petProperty.skills)),
								put("PetList", lists:keyreplace(Pet#petProperty.id, #petProperty.id, pet:getPlayerPetList(), Pet2)),
								
								%%立即存档
								mySqlProcess:replacePetPropertyGamedata(Pet2),
								{?Pet_LevelUpSkill_Succ, SkillCfgFront#skillCfg.skill_id}
						end
				end
		end
	catch
		ReturnValue ->ReturnValue
end.

onPetDelSkill(PetId, SkillId) ->
	Result = delSkill(PetId, SkillId),
	player:send(#pk_PetDelSkill_Result{result=Result, petId=PetId, skillid=SkillId}),
	
	%%如果宠物在出战状态，将删除技能的消息发送给地图进程
	case player:getCurPlayerProperty(#player.outFightPet) =:= PetId andalso 
			 ((Result=:= ?Pet_DelSkill_Succ)) of
		true->
			player:sendMsgToMap({petDelSkill, player:getCurPlayerID(), PetId, SkillId});
		false->ok
	end,
	Result.

delSkill(PetId, SkillId) ->
	try
		Pet = getPet(PetId),
		case Pet of
			{}-> throw(?Pet_DelSkill_Failed_NotPet);
			_->ok
		end,
		
		SkillCfg = etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), SkillId ),
		case SkillCfg of
			{}->throw( ?Pey_DelSkill_Failed_NotFindSkill );
			_->ok
		end,
		
		case SkillCfg#skillCfg.petskill_del of
			0->ok;
			_->throw( ?Pet_DelSkill_Failed_CanNotDel )
		end,
		
		case lists:keyfind(SkillId, #petSkill.skillId, Pet#petProperty.skills) of
			false ->
				throw(?Pey_DelSkill_Failed_NotFindSkill);
			Skill->
				Pet2 = setelement(#petProperty.skills, Pet, Pet#petProperty.skills--[Skill]),
				put("PetList", lists:keyreplace(Pet#petProperty.id, #petProperty.id, pet:getPlayerPetList(), Pet2)),
				
				%%立即存档
				mySqlProcess:replacePetPropertyGamedata(Pet2),
				?Pet_DelSkill_Succ
		end
	catch
		Return->Return
end.

onPetUnLockSkillCell(PetId) ->
	{Result, CellNum} = petUnLockSkillCell(PetId),
	player:send(#pk_PetUnLoctSkillCell_Result{result=Result, petId=PetId, newSkillCellNum=CellNum}).

petUnLockSkillCell(PetId) ->
	try
		Pet = getPet(PetId),
		case Pet of
			{} ->throw({?Pet_UnLockSkillCell_Failed_NotPet, 0});
			_ ->ok
		end,
		
		case Pet#petProperty.maxSkillNum < ?Pet_MaxSkill_Num of
			false ->throw({?Pet_UnLockSkillCell_Failed_CellFull, 0});
			true ->ok
		end,
		
		case Pet#petProperty.maxSkillNum of
			3 -> 
				Money = globalSetup:getGlobalSetupValue(#globalSetup.pulsc_Money_1),
				NeedSoulLevel = globalSetup:getGlobalSetupValue(#globalSetup.pulsc_SoulLevel_1);
			4 -> 
				Money = globalSetup:getGlobalSetupValue(#globalSetup.pulsc_Money_2),
				NeedSoulLevel = globalSetup:getGlobalSetupValue(#globalSetup.pulsc_SoulLevel_2);
			5 -> 
				Money = globalSetup:getGlobalSetupValue(#globalSetup.pulsc_Money_3),
				NeedSoulLevel = globalSetup:getGlobalSetupValue(#globalSetup.pulsc_SoulLevel_3);
			_ ->
				Money =0,
				NeedSoulLevel = 0,
				throw({?Pet_UnLockSkillCell_Failed_UnKnow, 0})
		end,
		
		case playerMoney:canUsePlayerBindedMoney(Money) of
			true->ok;
			false->throw({?Pet_UnLockSkillCell_Failed_MoneyNot, 0})
		end,
		
		case Pet#petProperty.soulLevel < NeedSoulLevel of
			true->throw({?Pet_UnLockSkillCell_Failed_SoulLevelNot, 0});
			_->ok
		end,
		
		%%扣除金钱
		ParamTuple = #token_param{changetype = ?Money_Change_PetUnLockSkillCell,param1=Pet#petProperty.data_id},
		playerMoney:usePlayerBindedMoney(Money, ?Money_Change_PetUnLockSkillCell,ParamTuple),
		Pet2 = setelement(#petProperty.maxSkillNum, Pet, Pet#petProperty.maxSkillNum+1),
		put("PetList", lists:keyreplace(Pet#petProperty.id, #petProperty.id, getPlayerPetList(), Pet2)),
		
		%%立即存档
		mySqlProcess:replacePetPropertyGamedata(Pet2),
		{?Pet_UnLockSkillCell_Succ, Pet2#petProperty.maxSkillNum}
	catch
		Return->Return
end.


onPetlearnSealAhsSkill(PetId, SkillId) ->
	{Result, OldSkillID} = petlearnSealAhsSkill(PetId, SkillId),
	player:send(#pk_PetlearnSealAhsSkill_Result{result=Result, petId=PetId, oldSkillId=OldSkillID, newSkillId=SkillId}),
	
	%%如果宠物在出战状态，将学会技能的信息发送给地图进程
	case player:getCurPlayerProperty(#player.outFightPet) =:= PetId andalso 
			 ((Result=:= ?Pet_LearnSkill_Succ) or (Result=:= ?Pet_LevelUpSkill_Succ)) of
		true->
			player:sendMsgToMap({petLearnSkill, player:getCurPlayerID(), PetId, OldSkillID, SkillId});
		false->ok
	end.

petlearnSealAhsSkill(PetId, SkillId) ->
	try
		SkillCfg = etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), SkillId),
		case SkillCfg of
			{} ->throw({?Pet_LearnSealAhsSkill_Failed_NotCfg, 0});
			_ ->ok
		end,
			
		Pet = getPet(PetId),
		case Pet of
			{}->throw({?Pet_LearnSealAhsSkill_Failed_NotPet, 0});
			_->ok
		end,
		
		%%仓库是否有此技能
		case lists:member(SkillId, petSealStore:getPlayerPetSealAhs()) of
			true->ok;
			false->throw({?Pet_LearnSealAhsSkill_Failed_NotInStore, 0})
		end,
		
		%%技能是否已经学习
		case lists:keyfind(SkillId, #petSkill.skillId, Pet#petProperty.skills) of
			false ->
				%%技能未学习
				ok;
			_ ->
				%%技能已经学习，不能再次学习
				throw({?Pet_LearnSealAhsSkill_Failed_AlreadyLearn, 0})	
		end,
		
		%%技能类型判断
		case SkillCfg#skillCfg.skillClass =:= ?SkillClass_Pet of
			true->ok;
			false->throw({?Pet_LearnSealAhsSkill_Failed_NotPetClass, 0})
		end,
		
		%%等级判断
		case SkillCfg#skillCfg.studylevel =< Pet#petProperty.level of
			true ->ok;
			false ->throw({?Pet_LearnSealAhsSkill_Failed_LevelNotEnough, 0})
		end,
		
		%%是否已经学习本组技能
		case getPetLearnedGroupSkill( Pet, SkillCfg#skillCfg.skill_group ) of
			{}->SkillCfgOld={};
			{ _, SkillCfg2 }->
				case SkillCfg2#skillCfg.level >= SkillCfg#skillCfg.level of
					true->throw({?Pet_LearnSkill_Failed_AlreadyLearnMax, 0} );
					_->ok
				end,
				SkillCfgOld = SkillCfg2
		end,
		
		case SkillCfgOld of
			{}->
				%%增加新技能，判断是否有空位
				case Pet#petProperty.maxSkillNum > length(Pet#petProperty.skills) of
					true ->
						%%扣除仓库的技能
						put("PlayerPetSealAhsStore", petSealStore:getPlayerPetSealAhs() -- [SkillId]),
						%%学习技能
						NewSkill = #petSkill{skillId=SkillCfg#skillCfg.skill_id, coolDownTime={0,0,0}},
						Pet2 = setelement(#petProperty.skills, Pet, Pet#petProperty.skills ++ [NewSkill] ),
						put("PetList", lists:keyreplace(Pet#petProperty.id, #petProperty.id, pet:getPlayerPetList(), Pet2)),
						
						%%立即存档
						mySqlProcess:replacePetPropertyGamedata(Pet2),
						{?Pet_LearnSealAhsSkill_Succ, SkillCfg#skillCfg.skill_id};
					false ->
						throw({?Pet_LearnSealAhsSkill_Failed_NotSpace, 0})
				end;
			_->
				%%扣除仓库中的技能
				put("PlayerPetSealAhsStore", petSealStore:getPlayerPetSealAhs() -- [SkillId]),
				NewSkill = #petSkill{skillId=SkillCfg#skillCfg.skill_id, coolDownTime={0,0,0} },
				Fun = fun(Record) ->
							  case Record#petSkill.skillId =:= SkillCfgOld#skillCfg.skill_id of
								  true ->NewSkill;
								  false ->Record
							  end
					  end,
				Pet2 = setelement(#petProperty.skills, Pet, lists:map(Fun, Pet#petProperty.skills)),
				put("PetList", lists:keyreplace(Pet#petProperty.id, #petProperty.id, pet:getPlayerPetList(), Pet2)),
				%%立即存档
				mySqlProcess:replacePetPropertyGamedata(Pet2),
				{?Pet_LearnSealAhsSkill_Succ, SkillCfgOld#skillCfg.skill_id}
		end
		
	catch
		Return->Return
end.


%%宠物改名
petChangeName( PetId, NewName )->
	try
		Pet = getPet(PetId),
		case Pet of
			{}->
				player:send(#pk_PetChangeName_Result{
													 result=?Pet_ChangeName_Failed_Not,
													 petId=PetId,
													 newName=NewName
													 }),
				throw(-1);
			_->ok
		end,
		
		case NewName of
			[]->				
				player:send(#pk_PetChangeName_Result{
													 result=?Pet_ChangeName_Failed_NameError,
													 petId=PetId,
													 newName=NewName
													 }),
				throw(-1);
			_->ok
		end,
		
		PetNew = setelement(#petProperty.name, Pet, NewName),
		put("PetList", lists:keyreplace(PetNew#petProperty.id, #petProperty.id, pet:getPlayerPetList(), PetNew)),
		
		%%立即存档
		mySqlProcess:replacePetPropertyGamedata(PetNew),
		
		player:send(#pk_PetChangeName_Result{
											 result=?Pet_ChangeName_Succ,
											 petId=PetId,
											 newName=NewName
											}),
		
		case player:getCurPlayerProperty(#player.outFightPet) =:= PetId of
			true->		%%如果宠物正在出战，将新名字发送给地图进程
				player:sendMsgToMap( {petChangeName, PetId, NewName} ),
				ok;
			_->ok
		end
	
	catch
		_->ok
end.


%%增加成长率最大值
addPetMaxGrowUP( Value )->
	try
		Pet = pet:getPet(player:getCurPlayerProperty(#player.outFightPet)),
		case Pet of
			{}->throw(-1);
			_->ok
		end,
		
		PetCfg = etsBaseFunc:readRecord(pet:getPetCfgTable(), Pet#petProperty.data_id),
		case PetCfg of
			{}->throw(-1);
			_->ok
		end,
		
		%%判断最大成长率是否能继续增加
		case Pet#petProperty.atkPowerGrowUp_Max >= PetCfg#petCfg.atkPower_MaxGUR2 andalso
				Pet#petProperty.defClassGrowUp_Max >= PetCfg#petCfg.defClass_MaxGUR2 andalso
				Pet#petProperty.hpGrowUp_Max >= PetCfg#petCfg.hp_MaxGUR2 of
			true->throw(-1);
			_->ok
		end,
		
		case Pet#petProperty.atkPowerGrowUp_Max+Value >= PetCfg#petCfg.atkPower_MaxGUR2 of
			true->NewAtk = PetCfg#petCfg.atkPower_MaxGUR2;
			_->NewAtk = Pet#petProperty.atkPowerGrowUp_Max+Value
		end,
		
		case Pet#petProperty.defClassGrowUp_Max+Value >= PetCfg#petCfg.defClass_MaxGUR2 of
			true->NewDef = PetCfg#petCfg.defClass_MaxGUR2;
			_->NewDef = Pet#petProperty.defClassGrowUp_Max+Value
		end,
		
		case Pet#petProperty.hpGrowUp_Max+Value >= PetCfg#petCfg.hp_MaxGUR2 of
			true->NewLife = PetCfg#petCfg.hp_MaxGUR2;
			_->NewLife = Pet#petProperty.hpGrowUp_Max+Value
		end,
		
		Pet2 = setelement(#petProperty.atkPowerGrowUp_Max, Pet, NewAtk),
		Pet3 = setelement(#petProperty.defClassGrowUp_Max, Pet2, NewDef),
		Pet4 = setelement(#petProperty.hpGrowUp_Max, Pet3, NewLife),
		put("PetList", lists:keyreplace(Pet4#petProperty.id, #petProperty.id, pet:getPlayerPetList(), Pet4)),
				%%立即存档
		mySqlProcess:replacePetPropertyGamedata(Pet4),
		
		%%发送最新的宠物属性给客户端
		player:send(#pk_UpdatePetProerty{petInfo=pet:makePetPropetryPackage(Pet4)}),
		
		true
	catch
		_->false
end.








