%% Author: Zhangdong
%% Created: 2012-8-8
%% Description: TODO: Add description to itemDB
-module(damageCalculate).

%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% Include files
%%
-include("db.hrl").
-include("hdlt_logger.hrl").
-include("itemDefine.hrl").
-include("package.hrl").
-include("playerDefine.hrl").
-include("mapDefine.hrl").

%%先将全属性抗性加到各个抗性属性里base_quip_ProFix
addAllDefineIntoProperty_FixArray( FixArray )->
	AllDef = array:get( ?all_def, FixArray ),
	case AllDef > 0 of
		true->
			FixArray2 = array:set( ?ph_def, AllDef + array:get(?ph_def, FixArray), FixArray ),
			FixArray3 = array:set( ?fire_def, AllDef + array:get(?fire_def, FixArray), FixArray2 ),
			FixArray4 = array:set( ?ice_def, AllDef + array:get(?ice_def, FixArray), FixArray3 ),
			FixArray5 = array:set( ?elec_def, AllDef + array:get(?elec_def, FixArray), FixArray4 ),
			FixArray6 = array:set( ?poison_def, AllDef + array:get(?poison_def, FixArray), FixArray5 ),
			FixArray6;
		false->FixArray
	end.

%%先将全属性抗性加到各个抗性属性里base_quip_ProFix
addAllDefineIntoProperty_PerArray( PerArray )->
	AllDef = array:get( ?all_def, PerArray ),
	case AllDef =/= [] of
		true->
			PerArray2 = array:set( ?ph_def, AllDef ++ array:get(?ph_def, PerArray), PerArray ),
			PerArray3 = array:set( ?fire_def, AllDef ++ array:get(?fire_def, PerArray), PerArray2 ),
			PerArray4 = array:set( ?ice_def, AllDef ++ array:get(?ice_def, PerArray), PerArray3 ),
			PerArray5 = array:set( ?elec_def, AllDef ++ array:get(?elec_def, PerArray), PerArray4 ),
			PerArray6 = array:set( ?poison_def, AllDef ++ array:get(?poison_def, PerArray), PerArray5 ),
			PerArray6;
		false->PerArray
	end.

%%把全攻击属性加进去all_damage
addAllDamageIntoProperty_FixArray( FixArray )->
	AllDef = array:get( ?all_damage, FixArray ),
	case AllDef > 0 of
		true->
			FixArray2 = array:set( ?phy_attack_rate, AllDef + array:get(?phy_attack_rate, FixArray), FixArray ),
			FixArray3 = array:set( ?fire_attack_rate, AllDef + array:get(?fire_attack_rate, FixArray), FixArray2 ),
			FixArray4 = array:set( ?ice_attack_rate, AllDef + array:get(?ice_attack_rate, FixArray), FixArray3 ),
			FixArray5 = array:set( ?elec_attack_rate, AllDef + array:get(?elec_attack_rate, FixArray), FixArray4 ),
			FixArray6 = array:set( ?poison_attack_rate, AllDef + array:get(?poison_attack_rate, FixArray), FixArray5 ),
			FixArray6;
		false->FixArray
	end.

%%把全攻击属性加进去all_damage
addAllDamageIntoProperty_PerArray( PerArray )->
	AllDef = array:get( ?all_damage, PerArray ),
	case AllDef =/= [] of
		true->
			PerArray2 = array:set( ?phy_attack_rate, AllDef ++ array:get(?phy_attack_rate, PerArray), PerArray ),
			PerArray3 = array:set( ?fire_attack_rate, AllDef ++ array:get(?fire_attack_rate, PerArray), PerArray2 ),
			PerArray4 = array:set( ?ice_attack_rate, AllDef ++ array:get(?ice_attack_rate, PerArray), PerArray3 ),
			PerArray5 = array:set( ?elec_attack_rate, AllDef ++ array:get(?elec_attack_rate, PerArray), PerArray4 ),
			PerArray6 = array:set( ?poison_attack_rate, AllDef ++ array:get(?poison_attack_rate, PerArray), PerArray5 ),
			PerArray6;
		false->PerArray
	end.

%%把全攻击属性加进去all_def_damage
addAllDefDamageIntoProperty_FixArray( FixArray )->
	AllDef = array:get( ?all_def_damage, FixArray ),
	case AllDef > 0 of
		true->
			FixArray2 = array:set( ?phy_def_rate, AllDef + array:get(?phy_def_rate, FixArray), FixArray ),
			FixArray3 = array:set( ?fire_def_rate, AllDef + array:get(?fire_def_rate, FixArray), FixArray2 ),
			FixArray4 = array:set( ?ice_def_rate, AllDef + array:get(?ice_def_rate, FixArray), FixArray3 ),
			FixArray5 = array:set( ?elec_def_rate, AllDef + array:get(?elec_def_rate, FixArray), FixArray4 ),
			FixArray6 = array:set( ?poison_def_rate, AllDef + array:get(?poison_def_rate, FixArray), FixArray5 ),
			FixArray6;
		false->FixArray
	end.

%%把全攻击属性加进去all_def_damage
addAllDefDamageIntoProperty_PerArray( PerArray )->
	AllDef = array:get( ?all_def_damage, PerArray ),
	case AllDef =/= [] of
		true->
			PerArray2 = array:set( ?phy_def_rate, AllDef ++ array:get(?phy_def_rate, PerArray), PerArray ),
			PerArray3 = array:set( ?fire_def_rate, AllDef ++ array:get(?fire_def_rate, PerArray), PerArray2 ),
			PerArray4 = array:set( ?ice_def_rate, AllDef ++ array:get(?ice_def_rate, PerArray), PerArray3 ),
			PerArray5 = array:set( ?elec_def_rate, AllDef ++ array:get(?elec_def_rate, PerArray), PerArray4 ),
			PerArray6 = array:set( ?poison_def_rate, AllDef ++ array:get(?poison_def_rate, PerArray), PerArray5 ),
			PerArray6;
		false->PerArray
	end.



%%根据PropertyCalc，重算物件的最终值
calcFinaProperty( ObjectID )->
	try
		Object = map:getMapObjectByID(ObjectID),
		ActorID = map:getObjectID(Object),
		
		ActorType = element( 1, Object ),
		
		case ActorType of
			mapPlayer->
				AttributeRegentCfg = etsBaseFunc:readRecord( main:getAttributeRegentCfgTable(), Object#mapPlayer.level ),
				
				FixArray2 = const:addPropertyArray( Object#mapPlayer.base_quip_ProFix, Object#mapPlayer.skill_ProFix),
				FixArray21=addAllDamageIntoProperty_FixArray(FixArray2),
				FixArray22=addAllDefDamageIntoProperty_FixArray(FixArray21),
				FixArray = addAllDefineIntoProperty_FixArray( FixArray22 ),
				
				_Base_quip_ProFix = Object#mapPlayer.base_quip_ProFix,
				_Skill_ProFix = Object#mapPlayer.skill_ProFix,
				
				PerArray2 = const:mergPropertyArray( Object#mapPlayer.base_quip_ProPer, Object#mapPlayer.skill_ProPer),
				
				_Base_quip_ProPer = Object#mapPlayer.base_quip_ProPer,
				_Skill_ProPer = Object#mapPlayer.skill_ProPer,
				
				MountInfo =Object#mapPlayer.playerMountView,
				case MountInfo#palyerMountView.mountSpeed > 0 of
					true->
						MountList = array:get( ?move_speed, PerArray2 ) ++ [MountInfo#palyerMountView.mountSpeed],
						PerArray3 = array:set( ?move_speed, MountList, PerArray2 );
					false->PerArray3 = PerArray2
				end,
				
				PerArray31=addAllDamageIntoProperty_PerArray(PerArray3),
				PerArray32=addAllDefDamageIntoProperty_PerArray(PerArray31),
				PerArray = addAllDefineIntoProperty_PerArray( PerArray32),

				FinalArray = array:new( ?property_count, {default, 0} ),
				put( "calcFinaProperty", FinalArray ),
				MyFunc = fun( Index )->
								 Value = calcOneProperty( ActorType, Index, array:get(Index,FixArray), array:get(Index,PerArray) ),
								 case Index of
									 ?coma_def_rate->FixValueIndex=?coma_def, Factor=AttributeRegentCfg#attributeRegentCfg.stunRes_Regent;
									 ?hold_def_rate->FixValueIndex=?hold_def, Factor=AttributeRegentCfg#attributeRegentCfg.fastenRes_Regent;
									 ?silent_def_rate->FixValueIndex=?silent_def, Factor=AttributeRegentCfg#attributeRegentCfg.forbidRes_Regent;
									 ?move_def_rate->FixValueIndex=?move_def, Factor=AttributeRegentCfg#attributeRegentCfg.flowRes_Regent;
									 ?hit_rate_rate->FixValueIndex=?hit, Factor=AttributeRegentCfg#attributeRegentCfg.hit_Regent;
									 ?dodge_rate->FixValueIndex=?dodge, Factor=AttributeRegentCfg#attributeRegentCfg.dodge_Regent;
									 ?block_rate->FixValueIndex=?block, Factor=AttributeRegentCfg#attributeRegentCfg.block_Regent;
									 ?crit_rate->FixValueIndex=?crit, Factor=AttributeRegentCfg#attributeRegentCfg.critical_Regent;
									 ?pierce_rate->FixValueIndex=?pierce, Factor=AttributeRegentCfg#attributeRegentCfg.penetrate_Regent;
									 ?attack_speed_rate->FixValueIndex=?attack_speed, Factor=AttributeRegentCfg#attributeRegentCfg.haste_Regent;
									 ?tough_rate->FixValueIndex=?tough, Factor=AttributeRegentCfg#attributeRegentCfg.tough_Regent;
									 _->FixValueIndex=-1, Factor=1
								 end,
								 
								 case FixValueIndex >= 0 of
									 true->
										 Value2 = array:get( FixValueIndex, get("calcFinaProperty") ),
										 Value3 = erlang:trunc( Value2 * 10000 / Factor + Value );
									 false->
										 Value3 = Value
								 end,

								 NewArray = array:set( Index, Value3, get("calcFinaProperty") ),
								 put( "calcFinaProperty", NewArray )
						 end,
				common:for(0, ?property_count-1, MyFunc),
				
				FinalArray2 = get("calcFinaProperty"),

				%%攻速计算攻击间隔=攻击间隔/（1+攻速率/10000）
				WeaponEquipCfg = etsBaseFunc:readRecord( main:getGlobalEquipCfgTable(), Object#mapPlayer.weapon ),
				case WeaponEquipCfg of
					{}->AttackSpeed = 1000;
					_->
						AttackSpeedRate = array:get(?attack_speed_rate, FinalArray2),
						AttackSpeed = erlang:trunc( WeaponEquipCfg#equipitem.atk_Delay/(1+AttackSpeedRate/10000) )
				end,
				FinalArray3 = array:set( ?attack_speed, AttackSpeed, FinalArray2 ),
				
				etsBaseFunc:changeFiled( map:getMapPlayerTable(), ActorID, #mapPlayer.finalProperty, FinalArray3 ),
				
				MyFunc2 = fun( Index )->
								  onObjectPropertyChanged( ActorID, Index, array:get(Index, FinalArray3) )
						  end,
				common:for(0, ?property_count-1, MyFunc2),
				ok;
			mapMonster->
				AttributeRegentCfg = etsBaseFunc:readRecord( main:getAttributeRegentCfgTable(), Object#mapMonster.level ),
				
				FixArray2 = const:addPropertyArray( Object#mapMonster.base_quip_ProFix, Object#mapMonster.skill_ProFix),
				PerArray2 = Object#mapMonster.skill_ProPer,
				FixArray21=addAllDamageIntoProperty_FixArray(FixArray2),
				FixArray22=addAllDefDamageIntoProperty_FixArray(FixArray21),
				FixArray = addAllDefineIntoProperty_FixArray( FixArray22 ),
				PerArray21=addAllDamageIntoProperty_PerArray(PerArray2),
				PerArray22=addAllDefDamageIntoProperty_PerArray(PerArray21),
				PerArray = addAllDefineIntoProperty_PerArray( PerArray22 ),
				
				FinalArray = array:new( ?property_count, {default, 0} ),
				put( "calcFinaProperty", FinalArray ),
				MyFunc = fun( Index )->
								 Value = calcOneProperty( ActorType, Index, array:get(Index,FixArray), array:get(Index,PerArray) ),
								 case Index of
									 ?coma_def_rate->FixValueIndex=?coma_def, Factor=AttributeRegentCfg#attributeRegentCfg.stunRes_Regent;
									 ?hold_def_rate->FixValueIndex=?hold_def, Factor=AttributeRegentCfg#attributeRegentCfg.fastenRes_Regent;
									 ?silent_def_rate->FixValueIndex=?silent_def, Factor=AttributeRegentCfg#attributeRegentCfg.forbidRes_Regent;
									 ?move_def_rate->FixValueIndex=?move_def, Factor=AttributeRegentCfg#attributeRegentCfg.flowRes_Regent;
									 ?hit_rate_rate->FixValueIndex=?hit, Factor=AttributeRegentCfg#attributeRegentCfg.hit_Regent;
									 ?dodge_rate->FixValueIndex=?dodge, Factor=AttributeRegentCfg#attributeRegentCfg.dodge_Regent;
									 ?block_rate->FixValueIndex=?block, Factor=AttributeRegentCfg#attributeRegentCfg.block_Regent;
									 ?crit_rate->FixValueIndex=?crit, Factor=AttributeRegentCfg#attributeRegentCfg.critical_Regent;
									 ?pierce_rate->FixValueIndex=?pierce, Factor=AttributeRegentCfg#attributeRegentCfg.penetrate_Regent;
									 ?attack_speed_rate->FixValueIndex=?attack_speed, Factor=AttributeRegentCfg#attributeRegentCfg.haste_Regent;
									 ?tough_rate->FixValueIndex=?tough, Factor=AttributeRegentCfg#attributeRegentCfg.tough_Regent;
									 _->FixValueIndex=-1, Factor=1
								 end,
								 
								 case FixValueIndex >= 0 of
									 true->
										 Value2 = array:get( FixValueIndex, get("calcFinaProperty") ),
										 Value3 = erlang:trunc( Value2 * 10000 / Factor + Value );
									 false->
										 Value3 = Value
								 end,

								 NewArray = array:set( Index, Value3, get("calcFinaProperty") ),
								 put( "calcFinaProperty", NewArray )
						 end,
				common:for(0, ?property_count-1, MyFunc),
				
				FinalArray2 = get("calcFinaProperty"),
				
				MonsterCfg = etsBaseFunc:readRecord( main:getGlobalMonsterCfgTable(), Object#mapMonster.monster_data_id ),
				case MonsterCfg of
					{}->AttackSpeed = 1000;
					_->
						AttackSpeedRate = array:get(?attack_speed_rate, FinalArray2),
						AttackSpeed = erlang:trunc( MonsterCfg#monsterCfg.attack_speed/(1+AttackSpeedRate/10000) )
				end,
				FinalArray3 = array:set( ?attack_speed, AttackSpeed, FinalArray2 ),
				
				etsBaseFunc:changeFiled( map:getMapMonsterTable(), ActorID, #mapMonster.finalProperty, FinalArray3 ),
				
				MyFunc2 = fun( Index )->
								  onObjectPropertyChanged( ActorID, Index, array:get(Index, FinalArray3) )
						  end,
				common:for(0, ?property_count-1, MyFunc2),
				ok;
			mapPet->
				AttributeRegentCfg = etsBaseFunc:readRecord( main:getAttributeRegentCfgTable(), Object#mapPet.level ),
				
				FixArray2 = const:addPropertyArray( Object#mapPet.base_quip_ProFix, Object#mapPet.skill_ProFix),
				PerArray2 = const:mergPropertyArray( Object#mapPet.base_quip_ProPer, Object#mapPet.skill_ProPer),
				FixArray21=addAllDamageIntoProperty_FixArray(FixArray2),
				FixArray22=addAllDefDamageIntoProperty_FixArray(FixArray21),
				FixArray = addAllDefineIntoProperty_FixArray( FixArray22 ),
				PerArray21=addAllDamageIntoProperty_PerArray( PerArray2),
				PerArray22=addAllDefDamageIntoProperty_PerArray(PerArray21),
				PerArray = addAllDefineIntoProperty_PerArray( PerArray22 ),
				
				FinalArray = array:new( ?property_count, {default, 0} ),
				put( "calcFinaProperty", FinalArray ),
				MyFunc = fun( Index )->
								 Value = calcOneProperty( ActorType, Index, array:get(Index,FixArray), array:get(Index,PerArray) ),
								 case Index of
									 ?coma_def_rate->FixValueIndex=?coma_def, Factor=AttributeRegentCfg#attributeRegentCfg.stunRes_Regent;
									 ?hold_def_rate->FixValueIndex=?hold_def, Factor=AttributeRegentCfg#attributeRegentCfg.fastenRes_Regent;
									 ?silent_def_rate->FixValueIndex=?silent_def, Factor=AttributeRegentCfg#attributeRegentCfg.forbidRes_Regent;
									 ?move_def_rate->FixValueIndex=?move_def, Factor=AttributeRegentCfg#attributeRegentCfg.flowRes_Regent;
									 ?hit_rate_rate->FixValueIndex=?hit, Factor=AttributeRegentCfg#attributeRegentCfg.hit_Regent;
									 ?dodge_rate->FixValueIndex=?dodge, Factor=AttributeRegentCfg#attributeRegentCfg.dodge_Regent;
									 ?block_rate->FixValueIndex=?block, Factor=AttributeRegentCfg#attributeRegentCfg.block_Regent;
									 ?crit_rate->FixValueIndex=?crit, Factor=AttributeRegentCfg#attributeRegentCfg.critical_Regent;
									 ?pierce_rate->FixValueIndex=?pierce, Factor=AttributeRegentCfg#attributeRegentCfg.penetrate_Regent;
									 ?attack_speed_rate->FixValueIndex=?attack_speed, Factor=AttributeRegentCfg#attributeRegentCfg.haste_Regent;
									 ?tough_rate->FixValueIndex=?tough, Factor=AttributeRegentCfg#attributeRegentCfg.tough_Regent;
									 _->FixValueIndex=-1, Factor=1
								 end,
								 
								 case FixValueIndex >= 0 of
									 true->
										 Value2 = array:get( FixValueIndex, get("calcFinaProperty") ),
										 Value3 = erlang:trunc( Value2 * 10000 / Factor + Value );
									 false->
										 Value3 = Value
								 end,

								 NewArray = array:set( Index, Value3, get("calcFinaProperty") ),
								 put( "calcFinaProperty", NewArray )
						 end,
				common:for(0, ?property_count-1, MyFunc),
				
				FinalArray2 = get("calcFinaProperty"),
				PetCfg = etsBaseFunc:readRecord( pet:getPetCfgTable(), Object#mapPet.data_id ),
				case PetCfg of
					{}->AttackSpeed = 1000;
					_->
						AttackSpeedRate = array:get(?attack_speed_rate, FinalArray2),
						AttackSpeed = erlang:trunc( PetCfg#petCfg.baseAtk_Delay/(1+AttackSpeedRate/10000) )
				end,
				FinalArray3 = array:set( ?attack_speed, AttackSpeed, FinalArray2 ),
				
				etsBaseFunc:changeFiled( map:getMapPetTable(), ActorID, #mapPet.finalProperty, FinalArray3 ),
				
				MyFunc2 = fun( Index )->
								  onObjectPropertyChanged( ActorID, Index, array:get(Index, FinalArray3) )
						  end,
				common:for(0, ?property_count-1, MyFunc2),
				ok;
			_->throw(-1)
		end,
		
		ok
	catch
		_->ok
	end.

%%计算某项属性
calcOneProperty( _ActorType, _PropertyType, FixValue, PerList )->
	case FixValue =< 0 of
		true->0;
		false->
			case PerList of
				[]->FixValue;
				_->
					put( "calcOneProperty", FixValue ),
					MyFunc = fun( Record )->
										NewValue = get( "calcOneProperty" ) * ( 1 + Record / 10000 ),
										put( "calcOneProperty", erlang:trunc( NewValue ) )
							 end,
					lists:foreach( MyFunc, PerList ),
					get( "calcOneProperty" )
			end
	end.

%%响应某属性变化了
onObjectPropertyChanged( ObjectID, PropertyType, ChangedValue )->
	try
		ActorType = map:getObjectID_TypeID( ObjectID ),
		case ActorType of
			?Object_Type_Player->
				case PropertyType of
					?max_life->
						Object = map:getMapObjectByID(ObjectID),
						case ( map:isObjectDead( Object ) /= true ) andalso
							 ( Object#mapPlayer.life > ChangedValue ) of
							true->
								charDefine:changeSetLife( Object, ChangedValue, false ),
								ok;
							false->ok
						end,
						
						playerMap:sendObjectLifeToClient(Object, true),
 						
						ok;
					?move_speed->
						Object = map:getMapObjectByID(ObjectID),
						Msg = #pk_ActorMoveSpeedUpdate{
													   nActorID=ObjectID,
													   nSpeed=array:get(?move_speed, Object#mapPlayer.finalProperty)},
						mapView:broadcast(Msg, Object, 0),
						ok;
					?attack_speed->
						Object = map:getMapObjectByID(ObjectID),
						Msg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_AttackSpeed, value=array:get(?attack_speed, Object#mapPlayer.finalProperty)}] },
						player:sendToPlayer(ObjectID, Msg);
					_->ok
				end,

				ok;
			
			?Object_Type_Pet->
				case PropertyType of
					?max_life->
						Object = map:getMapObjectByID(ObjectID),
						case ( map:isObjectDead( Object ) /= true ) andalso
							 ( Object#mapPet.life > ChangedValue ) of
							true->
								etsBaseFunc:changeFiled( map:getMapPetTable(), ObjectID, #mapPet.life, ChangedValue ),
								ok;
							false->ok
						end,
						
						playerMap:sendObjectLifeToClient(Object, true),
 						
						ok;
					?move_speed->
						Object = map:getMapObjectByID(ObjectID),
						Msg = #pk_ActorMoveSpeedUpdate{
													   nActorID=ObjectID,
													   nSpeed=array:get(?move_speed, Object#mapPet.finalProperty)},
						mapView:broadcast(Msg, Object, 0),
						ok;
					_->ok
				end,
				ok;
			?Object_Type_Monster->
				case PropertyType of
					?move_speed->
						Object = map:getMapObjectByID(ObjectID),
						Msg = #pk_ActorMoveSpeedUpdate{
													   nActorID=ObjectID,
													   nSpeed=array:get(?move_speed, Object#mapMonster.finalProperty)},
						mapView:broadcast(Msg, Object, 0),
						ok;
					_->ok
				end,
				ok;
			_->ok
		end,

		ok
	catch
		_->ok
	end.

%%计算计算目标防御力免伤
cal_Target_Def_NoDamage( Target_Pro_Array, Attacker_Pro_Array, AttackerLevel )->
	Rate = etsBaseFunc:readRecord( main:getAttributeRegentCfgTable(), AttackerLevel ),
	case Rate of
		{}->0;
		_->
			AttackPierce = array:get( ?pierce_rate, Attacker_Pro_Array ) * globalSetup:getGlobalSetupValue( #globalSetup.pierce_tiaozhen ) /10000 * Rate#attributeRegentCfg.def_Regent / 10000 ,
			TargetDef = array:get( ?defence, Target_Pro_Array ),
			
			TargetDef2 = TargetDef * globalSetup:getGlobalSetupValue( #globalSetup.attackDefence ) / 10000,
			DefValue = ( TargetDef - AttackPierce ) / ( TargetDef2 + Rate#attributeRegentCfg.def_Regent ),
			
			%%免伤最大值
			Max = globalSetup:getGlobalSetupValue( #globalSetup.def_NoDamage ) / 10000,
			case DefValue > Max of
				true->Max;
				false->
					case DefValue < -Max of
						true->-Max;
						false->DefValue
					end
			end
	end.

%%计算计算目标抗性免伤
calc_Target_Resist_NoDamage( DamageType, Target_Pro_Array, AttackerLevel )->
	Rate = etsBaseFunc:readRecord( main:getAttributeRegentCfgTable(), AttackerLevel ),
	case Rate of
		{}->0;
		_->
			AttackResistance = globalSetup:getGlobalSetupValue( #globalSetup.attackResistance ) / 10000,
			case DamageType of
				?DamageType_All->
					DefValue = 0;
				?DamageType_Phy->
					DefValue = array:get( ?ph_def, Target_Pro_Array ) / ( array:get( ?ph_def, Target_Pro_Array )*AttackResistance + Rate#attributeRegentCfg.physicRes_Regent );
				?DamageType_Fire->
					DefValue = array:get( ?fire_def, Target_Pro_Array ) / ( array:get( ?fire_def, Target_Pro_Array )*AttackResistance + Rate#attributeRegentCfg.fireRes_Regent );
				?DamageType_Ice->
					DefValue = array:get( ?ice_def, Target_Pro_Array ) / ( array:get( ?ice_def, Target_Pro_Array )*AttackResistance + Rate#attributeRegentCfg.iceRes_Regent );
				?DamageType_Elec->
					DefValue = array:get( ?elec_def, Target_Pro_Array ) / ( array:get( ?elec_def, Target_Pro_Array )*AttackResistance + Rate#attributeRegentCfg.lightingRes_Regent );
				?DamageType_Poison->
					DefValue = array:get( ?poison_def, Target_Pro_Array ) / ( array:get( ?poison_def, Target_Pro_Array )*AttackResistance + Rate#attributeRegentCfg.poisonRes_Regent );
				_->DefValue = 0
			end,
			%%免伤最大值
			Max = globalSetup:getGlobalSetupValue( #globalSetup.def_NoDamage ) / 10000,
			case DefValue > Max of
				true->Max;
				false->
					case DefValue < 0.0001 of
						true->0;
						false->DefValue
					end
			end
	end.

%%计算攻击者攻击力
calc_Attacker_AttackPower( Attacker )->
	case element( 1, Attacker ) of
		mapPlayer->
			%%玩家的武器攻击间隔时间，理论上玩家必然有武器
			case Attacker#mapPlayer.weapon =/= 0 of
				true->
					WeaponCfg = etsBaseFunc:readRecord( main:getGlobalEquipCfgTable(), Attacker#mapPlayer.weapon ),
					case WeaponCfg of
						{}->
							Weapon_All_Attack = 0,
							Weapon_Attack_Time = 1;
						_->
							Weapon_All_Attack = WeaponCfg#equipitem.baseAtk_Power,
							Weapon_Attack_Time = WeaponCfg#equipitem.atk_Delay
					end;
				false->
					Weapon_All_Attack = 0,
					Weapon_Attack_Time = 1
			end,

			%%攻击因子
			AttackFactor = etsBaseFunc:readRecord( main:getAttackFactorCfgTable(), Attacker#mapPlayer.camp ),

			%%标准攻击间隔
			Default_Attack_Time = globalSetup:getGlobalSetupValue( #globalSetup.attack_dist_time ),

			%%武器总攻击，暂时用装备的配置
			%Weapon_All_Attack = WeaponCfg#equipitem.baseAtk_Power,

			%%玩家总攻击力
			Attack_Final = array:get( ?attack, Attacker#mapPlayer.finalProperty ),
			AttackPower = Weapon_All_Attack + ( Attack_Final - Weapon_All_Attack ) * Weapon_Attack_Time / Default_Attack_Time;
		mapMonster->
			AttackFactor = etsBaseFunc:readRecord( main:getAttackFactorCfgTable(), ?AttackFator_Monster ),
			AttackPower = array:get( ?attack, Attacker#mapMonster.finalProperty );
		mapPet->
			AttackFactor = etsBaseFunc:readRecord( main:getAttackFactorCfgTable(), ?AttackFator_Pet ),
			AttackPower = array:get( ?attack, Attacker#mapPet.finalProperty );
		_->
			AttackFactor = 0,
			AttackPower = 0
	end,
	
	%%计算攻击因子
	case AttackPower =< 0 of
		true->0;
		false->
			Min_AttackPower = AttackPower * AttackFactor#attackFatorCfg.min,
			Max_AttackPower = AttackPower * AttackFactor#attackFatorCfg.max,
			Dist = erlang:trunc( Max_AttackPower - Min_AttackPower ),
			case Dist > 0 of
				true->
					Attack_Return = erlang:trunc( Min_AttackPower ) + random:uniform( Dist ),
					Attack_Return;
				false->
					Attack_Return =erlang:trunc( Min_AttackPower ),
					Attack_Return
			end
	end.

%%计算伤害值
calc_Damage_Value( DamageType, DamagePercent, DamageFixValue, Attacker_Pro_Array, Attacker_Power, Target_Pro_Array, Target_Def_NoDamage, Target_Resist_NoDamage )->
	case DamageType of
		?DamageType_All->
			DamageValue = Attacker_Power * DamagePercent / 10000 + DamageFixValue;
		?DamageType_Phy->
			DamageValue = ( Attacker_Power*DamagePercent/10000 + DamageFixValue )*( 1 - Target_Def_NoDamage ) * ( 1 - Target_Resist_NoDamage ) * array:get( ?phy_attack_rate, Attacker_Pro_Array ) / 10000 * array:get( ?phy_def_rate, Target_Pro_Array ) / 10000;
		?DamageType_Fire->
			DamageValue = ( Attacker_Power*DamagePercent/10000 + DamageFixValue )*( 1 - Target_Def_NoDamage ) * ( 1 - Target_Resist_NoDamage ) * array:get( ?fire_attack_rate, Attacker_Pro_Array ) / 10000 * array:get( ?fire_def_rate, Target_Pro_Array ) / 10000;
		?DamageType_Ice->
			DamageValue = ( Attacker_Power*DamagePercent/10000 + DamageFixValue )*( 1 - Target_Def_NoDamage ) * ( 1 - Target_Resist_NoDamage ) * array:get( ?ice_def_rate, Attacker_Pro_Array ) / 10000 * array:get( ?ice_def_rate, Target_Pro_Array ) / 10000;
		?DamageType_Elec->
			DamageValue = ( Attacker_Power*DamagePercent/10000 + DamageFixValue )*( 1 - Target_Def_NoDamage ) * ( 1 - Target_Resist_NoDamage ) * array:get( ?elec_attack_rate, Attacker_Pro_Array ) / 10000 * array:get( ?elec_def_rate, Target_Pro_Array ) / 10000;
		?DamageType_Poison->
			DamageValue = ( Attacker_Power*DamagePercent/10000 + DamageFixValue )*( 1 - Target_Def_NoDamage ) * ( 1 - Target_Resist_NoDamage ) * array:get( ?poison_attack_rate, Attacker_Pro_Array ) / 10000 * array:get( ?poison_def_rate, Target_Pro_Array ) / 10000;
		_->DamageValue = 0
	end,
	case DamageValue =< 0.00001 of
		true->1;
		false->erlang:trunc( DamageValue )
	end.

%%计算最终伤害
calc_Damage_Revise( SkillCfg, DamageValue, Attacker, Target )->
	case ( Attacker =:= {} ) or ( Target =:= {} ) of
		true->DamageValue;
		false->
			NoBlockState = ?Actor_State_Flag_Disable_Hold bor ?Actor_State_Flag_Disable_Move,
			case mapActorStateFlag:isStateFlag( element( ?object_id_index, Target ), NoBlockState ) of
				true->DoBlockTest=false;%%如果目标有昏迷，定身中的任一个状态，则跳过格挡判定
				false->%%判断技能是否做格挡判定
					case ( SkillCfg#skillCfg.hit_Spec band ?SkillHitSpec_Not_Block) /= 0 of
						true->DoBlockTest=false;
						false->DoBlockTest=true
					end
			end,
			
			case DoBlockTest of
				true->
					Rand = random:uniform(10000),
					BlockRate = array:get( ?block_rate, charDefine:getObjectFinalProperty(Target) ),
					case Rand =< BlockRate of
						true->IsBlocked = true;
						false->IsBlocked = false
					end;
				false->
					IsBlocked = false
			end,

			case IsBlocked of
				true->
					Block_dec_damage = charDefine:getObjectProperty(Target, ?block_dec_damage ),
					Blocke = 1 - Block_dec_damage/10000;
				false->
					Blocke = 1
			end,
			
			%%判断技能是否做暴击判定
			case ( SkillCfg#skillCfg.hit_Spec band ?SkillHitSpec_Not_Crit) /= 0 of
				true->IsCrited=false;
				false->
					RandCrite = random:uniform(10000),
					CriteRate = array:get( ?crit_rate, charDefine:getObjectFinalProperty(Attacker) ),
					case RandCrite =< CriteRate of
						true->IsCrited = true;
						false->IsCrited = false
					end
			end,

			case IsCrited of
				true->
					Crit_damage_rate = charDefine:getObjectProperty(Attacker, ?crit_damage_rate ),
					Crite = 1 + Crit_damage_rate/10000;
				false->
					Crite = 1
			end,
			
			DamageValue2 = DamageValue * Blocke * Crite,
			
			case element( 1, Attacker ) of
				mapPlayer->Attacker_PP = true;
				mapMonster->Attacker_PP = false;
				mapPet->Attacker_PP = true;
				_->Attacker_PP = false
			end,

			case element( 1, Target ) of
				mapPlayer->Target_PP = true;
				mapMonster->Target_PP = false;
				mapPet->Target_PP = true;
				_->Target_PP = false
			end,

			case ( Attacker_PP ) andalso ( Target_PP ) of
				true->
					DamageValue3 = DamageValue2 * ( 1 - charDefine:getObjectProperty(Target, ?tough_rate )/10000 );
				false->
					DamageValue3 = DamageValue2
			end,
			case DamageValue3 < 1 of
				true->DamageValue4 = 1;
				false->DamageValue4 = DamageValue3
			end,
			{ IsBlocked, IsCrited, erlang:trunc( DamageValue4 ) }
	end.

%%计算技能伤害
calc_Skill_Damage( Attacker, SkillCfg, Target, DamageInfo )->
	Attacker_Pro_Array = charDefine:getObjectFinalProperty(Attacker),
	Target_Pro_Array = charDefine:getObjectFinalProperty(Target),
	
	%%计算计算目标防御力免伤
	Target_Def_NoDamage2 = cal_Target_Def_NoDamage( Target_Pro_Array, Attacker_Pro_Array, charDefine:getObjectLevel(Attacker) ),
	Target_Def_NoDamage = common:testZero(Target_Def_NoDamage2),
	%%计算计算目标抗性免伤
	Target_Resist_NoDamage2 = calc_Target_Resist_NoDamage( SkillCfg#skillCfg.damageType, Target_Pro_Array, charDefine:getObjectLevel(Attacker) ),
	Target_Resist_NoDamage = common:testZero(Target_Resist_NoDamage2),
	%%计算攻击者攻击力
	Attacker_AttackPower2 = calc_Attacker_AttackPower( Attacker ),
	Attacker_AttackPower = common:testZero(Attacker_AttackPower2),
	%%计算伤害值
	Damage_Value = calc_Damage_Value( SkillCfg#skillCfg.damageType, 
									  SkillCfg#skillCfg.damagePercent, 
									  SkillCfg#skillCfg.damageFixValue, 
									  Attacker_Pro_Array, 
									  Attacker_AttackPower, 
									  Target_Pro_Array, 
									  Target_Def_NoDamage, 
									  Target_Resist_NoDamage ),
	
	%%计算最终伤害
	{ IsBlocked, IsCrited, DamageFinal } = calc_Damage_Revise( SkillCfg, Damage_Value, Attacker, Target ),
	DamageInfo2 = setelement( #damageInfo.isBlocked, DamageInfo, IsBlocked ),
	DamageInfo3 = setelement( #damageInfo.isCrited, DamageInfo2, IsCrited ),
	DamageInfo4 = setelement( #damageInfo.damage, DamageInfo3, DamageFinal ),
	DamageInfo4.


%%更新生命秒回
onUpdateLifeRecover( Object )->
	try
		case map:isObjectDead(Object) of
			true->throw(-1);
			_->ok
		end,
		
		case element(1, Object) of
			mapPlayer->
				LifeRecover = array:get(?life_recover, Object#mapPlayer.finalProperty),
				LifeRecoverMaxLife = array:get(?life_recover_MaxLife, Object#mapPlayer.finalProperty),
				Life =Object#mapPlayer.life,
				MaxLife = array:get(?max_life, Object#mapPlayer.finalProperty);
			mapMonster->
				LifeRecover = array:get(?life_recover, Object#mapMonster.finalProperty),
				LifeRecoverMaxLife = array:get(?life_recover_MaxLife, Object#mapMonster.finalProperty),
				Life =Object#mapMonster.life,
				MaxLife = array:get(?max_life, Object#mapMonster.finalProperty);
			mapPet->
				LifeRecover = array:get(?life_recover, Object#mapPet.finalProperty),
				LifeRecoverMaxLife = array:get(?life_recover_MaxLife, Object#mapPet.finalProperty),
				Life =Object#mapPet.life,
				MaxLife = array:get(?max_life, Object#mapPet.finalProperty)
		end,
		
		case Life >= MaxLife of
			true->throw(-1);
			_->ok
		end,
		
		case LifeRecover =:=0 andalso LifeRecoverMaxLife =:= 0 of
			true->throw(-1);
			_->ok
		end,
		
		%%改变血量并且广播给客户端
		NewLife = erlang:trunc(Life+LifeRecoverMaxLife/10000*MaxLife + LifeRecover),
		case NewLife > MaxLife of
			true->
				charDefine:changeSetLife(Object, MaxLife, true);
			_->
				charDefine:changeSetLife(Object, NewLife, true)
		end,
		
		ok
	
	catch
		_->ok
end.


