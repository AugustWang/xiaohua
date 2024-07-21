%% Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(objectAttack).

-include("db.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("monsterDefine.hrl").
-include("variant.hrl").
-include("globalDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 

getObjectLifePer( Object )->
	case  map:getMapObjectByID( element( ?object_id_index, Object ) ) of
		{}->100;
		NewObject->
			HP = charDefine:getObjectLife( NewObject ),
			MaxHP = charDefine:getObjectProperty( NewObject, ?max_life ),
			case HP>MaxHP of
				true-> 100;
				_->
					erlang:trunc(HP / MaxHP * 100)
			end
	end.

%%返回能否攻击目标
canAttack( Attacker, Target, SkillCfg, CheckDistance )->
	put( "object_canAttack_return", false ),
	try
		case map:getObjectID( Attacker ) =:= map:getObjectID( Target ) of
			true->throw(-1);%%自己永远不能攻击自己
			false->ok
		end,

		case element( 1, Attacker ) of
			mapMonster->
				NotAttackState = ( ?Actor_State_Flag_Dead ) bor 
									 ( ?Monster_State_Flag_GoBacking ) bor
									 ( ?Actor_State_Flag_Disable_Attack ) bor
									 ( ?Actor_State_Flag_Disable_Hold) ,
				case ( Attacker#mapMonster.stateFlag band NotAttackState ) /= 0 of
					true->throw(-1);%%自己不能攻击
					false->ok
				end;
			mapPlayer->
				NotAttackState = ( ?Actor_State_Flag_Dead ) bor 
									 ( ?Player_State_Flag_ChangingMap ) bor
									 ( ?Actor_State_Flag_Disable_Attack ) bor
									 ( ?Actor_State_Flag_Disable_Hold) ,
				case ( Attacker#mapPlayer.stateFlag band NotAttackState ) /= 0 of
					true->throw(-1);%%自己不能攻击
					false->ok
				end;
			mapPet ->
				NotAttackState = ( ?Actor_State_Flag_Dead ) bor 
									 ( ?Player_State_Flag_ChangingMap ) bor
									 ( ?Actor_State_Flag_Disable_Attack ) bor
									 ( ?Actor_State_Flag_Disable_Hold) ,
				case (Attacker#mapPet.stateFlag band NotAttackState) /= 0 of
					true ->throw(-1); %%自己不能攻击
					false ->ok
				end;
			_->throw(-1)
		end,		

		case CheckDistance of
			true->
				AttackerPos = map:getObjectPos( Attacker ),
				TargetPos = map:getObjectPos( Target ),
				%%攻击距离检测
				DistSQ = monster:getDistSQFromTo(AttackerPos#posInfo.x, 
												AttackerPos#posInfo.y, 
												TargetPos#posInfo.x, 
												 TargetPos#posInfo.y ),
				SkillRangerSQ = SkillCfg#skillCfg.rangerSquare,
				case SkillRangerSQ > DistSQ of
					true->ok;
					false->throw(-1)
				end;
			false->ok
		end,

		case canBeenAttack(Attacker, Target, SkillCfg) of
			true->ok;
			false->throw(-1)
		end,
		
		{ CanAttack, _FailCode } = getAttackRelation( Attacker, Target ),
		
		CanAttack
	catch
		_->get( "object_canAttack_return" )
	end.

%%返回玩家是否能被攻击
canBeenAttack( Attacker, Target, _SkillCfg )->
	put( "object_canBeenAttack_return", false ),
	try
		case map:getObjectID( Attacker ) =:= map:getObjectID( Target ) of
			true->throw(-1);%%自己永远不能攻击自己
			false->ok
		end,

		case element( 1, Target ) of
			mapMonster->
				NotBeenAttackState = ( ?Actor_State_Flag_Dead ) bor 
									( ?Actor_State_Flag_God ),
				case ( Target#mapMonster.stateFlag band NotBeenAttackState ) /= 0 of
					true->throw(-1);%%Monster不能被攻击
					false->ok
				end;
			mapPlayer->
				NotBeenAttackState = ( ?Actor_State_Flag_Dead ) bor 
									( ?Actor_State_Flag_God ) bor
									( ?Player_State_Flag_ChangingMap ),
		
				case ( Target#mapPlayer.stateFlag band NotBeenAttackState ) /= 0 of
					true->throw(-1);%%玩家不能被攻击
					false->ok
				end;
			mapPet->
				NotBeenAttackState = ( ?Actor_State_Flag_Dead ) bor 
									( ?Actor_State_Flag_God ) bor
									( ?Player_State_Flag_ChangingMap ),
		
				case ( Target#mapPet.stateFlag band NotBeenAttackState ) /= 0 of
					true->throw(-1);%%宠物不能被攻击
					false->ok
				end;
			_->throw(-1)
		end,
		true
	catch
		_->get( "object_canBeenAttack_return" )
	end.

%%返回两个物件之间的战斗关系
%%返回{ true(false), reson }->true表示可以攻击，false表示不可以攻击，reson表示不可以攻击的原因
getAttackRelation( SrcObject, TargetObject )->
	try
		SrcObjectType = element( 1, SrcObject ),
		TargetObjectType = element( 1, TargetObject ),
		SrcObjectID = element( ?object_id_index, SrcObject ),
		TargetObjectID = element( ?object_id_index, TargetObject ),
		
		case SrcObjectID =:= TargetObjectID of
			true->throw( { return, {false, ?Attack_Fail_Self }});
			false->ok
		end,
		
		case SrcObjectType of
			mapPlayer->%%攻击者是玩家
				case TargetObjectType of
					mapPlayer->%%目标是玩家
						SrcObjectID = element( ?object_id_index, SrcObject ),
						TargetObjectID = element( ?object_id_index, TargetObject ),
		
						%%第二步，检测是否正在切磋
						case ( SrcObject#mapPlayer.qieCuoPlayerID =:= TargetObjectID ) andalso
							 ( TargetObject#mapPlayer.qieCuoPlayerID =:= SrcObjectID )of
							true->throw( { return, {true, 0} } );
							false->ok
						end,
						MapCfg = map:getMapCfg(),
						%%第三步，检测是否在战场地图中，并是战斗关系
						case ( ?Map_Type_Battle =:= MapCfg#mapCfg.type ) andalso
							 ( battleMap:isBattleEnemy( SrcObject#mapPlayer.battleFieldID, TargetObject#mapPlayer.battleFieldID ) )of
							true->throw( { return,{ true, 0} } );
							false->ok
						end,
						%%检测是否队友，队友不能攻击
						case ( SrcObject#mapPlayer.teamDataInfo#teamData.teamID /= 0 ) andalso
							 ( SrcObject#mapPlayer.teamDataInfo#teamData.teamID =:= TargetObject#mapPlayer.teamDataInfo#teamData.teamID ) of
							true->throw( { return, {false, ?Attack_Fail_Team} } );
							false->ok
						end,
						%%第四步，检测PK保护
						case buff:hasPkProcted(TargetObjectID) of
							true ->throw( {return, {false, ?Attack_Fail_PK_Protect}});
							false->ok
						end,
						%%免战保护，并且是和平模式，不能被攻击
						case variant:getWorldVarFlag(?WorldVariant_Index_1, ?WorldVariant_Index_1_PeriodPkProt_Bit0) of
							true->
								%PKKillState = ( ?Player_State_Flag_PK_Kill bor ?Player_State_Flag_PK_Kill_Value ),
								case ( mapActorStateFlag:isStateFlag(SrcObjectID, ?Player_State_Flag_PK_Kill) andalso
									 ( mapActorStateFlag:isStateFlag(TargetObjectID, ?Player_State_Flag_PK_Kill) orelse
									  mapActorStateFlag:isStateFlag(TargetObjectID, ?Player_State_Flag_PK_Kill_Value) ) ) of
									true ->ok;
									false->throw({return, {false, ?Attack_Fail_PK_Protect}} ) %%不能攻击
								end;
							false-> ok
						end,


						%%检测是否开启了帮会保护，并且目标是帮会成员，0代表可以攻击，1代表不可以攻击
						case SrcObject#mapPlayer.guildID /=0 andalso SrcObject#mapPlayer.guildID =:= TargetObject#mapPlayer.guildID of
							true->
								case SrcObject#mapPlayer.gameSetMenu#pk_GSWithU_GameSetMenu_3.noAttackGuildMate of
									0->ok;
									_->
										throw( {return, {false, ?Attack_Fail_OpenGuildProtect}} )
								end;
							_->ok
						end,
						
						%%战场中同一个阵营，算友方目标
						MapCfg=map:getMapCfg(),
						case MapCfg#mapCfg.type of
							?Map_Type_Battle->
								case SrcObject#mapPlayer.faction =:=  TargetObject#mapPlayer.faction of
									true->
										throw( {return, {false, ?Attack_Fail_Friend}} );
									_->
										ok
								end,
								ok;
							_->
								ok
						end,
							
						%%第五步，检测是否地图允许阵营PK
						case ( MapCfg#mapCfg.pkFlag_Camp /= 0 ) andalso
							 ( SrcObject#mapPlayer.faction /= TargetObject#mapPlayer.faction )of
							true->throw( { return, {true, 0} } );
							false->ok
						end,
						%%第六步，检测是否地图允许杀戮
						case ( MapCfg#mapCfg.pkFlag_Kill /= 0 ) andalso
							 ( mapActorStateFlag:isStateFlag(SrcObjectID, ?Player_State_Flag_PK_Kill)
							 orelse mapActorStateFlag:isStateFlag(TargetObjectID, ?Player_State_Flag_PK_Kill_Value)) of
							true->throw( { return, {true, 0} } );
							false->ok
						end,	

						%%首先，如果仇恨列表里，一定可攻击
						case objectHatred:isInHatred(SrcObjectID, TargetObjectID) of
							true->throw( { return,{ true, 0} } );
							false->ok
						end,
						
						throw( { return, { false, ?Attack_Fail_Safe_Area } } );
					
					mapPet->		%%目标是宠物
						%%取得目标宠物的主人
						Master = map:getMapObjectByID(TargetObject#mapPet.masterId),
						case Master of
							{}->throw({return, {false, ?Attack_Fail_Invalid_Call}});
							_->ok
						end,
				
						case map:getObjectID(Master) =:= map:getObjectID(SrcObject) of
							true-> %%自身宠物，不能攻击（默认自身与自身宠物为队友关系）
								throw( {return, {false, ?Attack_Fail_Team}});
							false->ok
						end,
						
						throw( {return, getAttackRelation(SrcObject, Master)});
						%%目标是怪，检测如果是同一个阵营，不能攻击
					mapMonster->
						Attack_mode=etsBaseFunc:getRecordField(?MonsterCfgTableAtom, TargetObject#mapMonster.monster_data_id, #monsterCfg.attack_mode),
						case Attack_mode =:= ?Monster_Attack_Mode_Faction of
							true->
								case SrcObject#mapPlayer.faction=:=etsBaseFunc:getRecordField(?MonsterCfgTableAtom, TargetObject#mapMonster.monster_data_id, #monsterCfg.faction) of
									true->
										throw({return, {false, ?Attack_Fail_Friend}}),
										ok;%%同一个阵营不能攻击
									_->
										ok
								end,
								ok;
							false->
								ok
						end,
						ok;
					_->ok
				end,
				ok;
			
			%%攻击者是宠物
			mapPet->
				case TargetObjectType of
					%%目标是玩家
					mapPlayer->
						%%取得自身的主人
						%MasterID = SrcObject#mapPet.masterId,
						Master = map:getMapObjectByID(SrcObject#mapPet.masterId),
				
						case Master of
							{}->throw({return, {false, ?Attack_Fail_Invalid_Call}});
							_->ok
						end,
				
						case map:getObjectID(Master) =:= map:getObjectID(TargetObject) of
							true-> %%自身宠物，不能攻击（默认自身与自身宠物为队友关系）
								throw( {return, {false, ?Attack_Fail_Team}});
							false->ok
						end,
		
						throw( { return, getAttackRelation(Master, TargetObject)});
					%%目标是宠物
					mapPet->
						%%取得自身的主人
						MasterSrc = map:getMapObjectByID(SrcObject#mapPet.masterId),
						case MasterSrc of
							{}->throw({return, {false, ?Attack_Fail_Invalid_Call}});
							_->ok
						end,
						
						%%取得目标的主人
						MasterTar = map:getMapObjectByID(TargetObject#mapPet.masterId),
						case MasterTar of
							{}->throw({return, {false, ?Attack_Fail_Invalid_Call}});
							_->ok
						end,
						
						throw({ return, getAttackRelation(MasterSrc, MasterTar)});
						%%目标是怪，检测如果是同一个阵营，不能攻击
					mapMonster->
							
							Attack_mode=etsBaseFunc:getRecordField(?MonsterCfgTableAtom, TargetObject#mapMonster.monster_data_id, #monsterCfg.attack_mode),
							case Attack_mode =:= ?Monster_Attack_Mode_Faction of
								true->
									MasterID = SrcObject#mapPet.masterId,
									Master = map:getMapObjectByID(SrcObject#mapPet.masterId),
							
									case Master of
										{}->throw({return, {false, ?Attack_Fail_Invalid_Call}});
										_->ok
									end,
									case Master#mapPlayer.faction=:=etsBaseFunc:getRecordField(?MonsterCfgTableAtom, TargetObject#mapMonster.monster_data_id, #monsterCfg.faction) of
										true->
											throw({return, {false, ?Attack_Fail_Friend}}),
											ok;%%同一个阵营不能攻击
										_->
											ok
									end,
									ok;
								false->
									ok
							end,
							ok;
					_->ok
				end;
			
			%%攻击者是怪物
			mapMonster->
				case TargetObjectType of
					%%目标是怪物
					mapMonster->
						throw({ return , {false, ?Attack_Fail_Friend}});
					%%目标是人，检测如果是同一个阵营，不能攻击
					mapPlayer->
						Attack_mode=etsBaseFunc:getRecordField(?MonsterCfgTableAtom, SrcObject#mapMonster.monster_data_id, #monsterCfg.attack_mode),
						%%?DEBUG_OUT("Relation1 Attack_mode ~p  dataid ~p",[Attack_mode,SrcObject#mapMonster.monster_data_id]),
						case Attack_mode =:= ?Monster_Attack_Mode_Faction of
							true->
								%%?DEBUG_OUT("Relation2"),
								case TargetObject#mapPlayer.faction=:=etsBaseFunc:getRecordField(?MonsterCfgTableAtom, SrcObject#mapMonster.monster_data_id, #monsterCfg.faction) of
									true->
										%%?DEBUG_OUT("Relation3"),
										throw({return, {false, ?Attack_Fail_Friend}}),
										ok;%%同一个阵营不能攻击
									_->
										ok
								end,
								ok;
							false->
								ok
						end,
						ok;
					mapPet->
							
							Attack_mode=etsBaseFunc:getRecordField(?MonsterCfgTableAtom, SrcObject#mapMonster.monster_data_id, #monsterCfg.attack_mode),
							case Attack_mode =:= ?Monster_Attack_Mode_Faction of
								true->
									MasterID = TargetObject#mapPet.masterId,
									Master = map:getMapObjectByID(TargetObject#mapPet.masterId),
							
									case Master of
										{}->throw({return, {false, ?Attack_Fail_Invalid_Call}});
										_->ok
									end,
									case Master#mapPlayer.faction=:=etsBaseFunc:getRecordField(?MonsterCfgTableAtom, SrcObject#mapMonster.monster_data_id, #monsterCfg.faction) of
										true->
											throw({return, {false, ?Attack_Fail_Friend}}),
											ok;%%同一个阵营不能攻击
										_->
											ok
									end,
									ok;
								false->
									ok
							end,
							ok;
					_->ok
				end;
			_->ok
		end,

		{ true, 0 }
	catch
		{ return, {CanAttack, FailCode} }->{ CanAttack, FailCode }
	end.


%%返回技能释放者与目标间的飞行时间
getSkillFlyTime( #posInfo{}=_PosFrom, _SkillCfg, #posInfo{}=_PosTo )->
	try
		%%暂时固定，计算后面添加
%		SkillFlySpeed = 100,
		
%		DistSQ = monster:getDistSQFromTo(PosFrom#posInfo.x, 
%									     PosFrom#posInfo.y, 
%										 PosTo#posInfo.x, 
%										 PosTo#posInfo.y ),
		
	   600
	catch
		_->ok
	end.

%%执行被动技能效果
doPassiveSkillEffect( Attacker, SkillCfg, Target) ->
	try
		case SkillCfg#skillCfg.skillTriggerType of
			?SkillTrigger_Passive->ok;
			_->throw(-1)
		end,

		%%遍历技能效果列表
		case etsBaseFunc:readRecord(main:getGlobalSkillEffectCfgTable(), SkillCfg#skillCfg.skill_id) of
			{} ->ok;
			SkillEffect->
				MyFunc = fun( #skill_effect_data{}=Record )->
								 doSkillEffectData( Attacker, SkillCfg, Target, {}, Record )
						 end,
				lists:foreach( MyFunc, SkillEffect#skill_effect.effect_list )
		end
	
	catch
		_->ok
end.

%%执行删除被动技能效果
doRemovePassiveSkillEffect(Object, SkillCfg) ->
	try
		%%遍历技能效果列表
		case etsBaseFunc:readRecord(main:getGlobalSkillEffectCfgTable(), SkillCfg#skillCfg.skill_id) of
			{} ->ok;
			SkillEffect->
				MyFunc = fun( #skill_effect_data{}=Record )->
								 removeSkillEffectData(Object, SkillCfg, Record)
						 end,
				lists:foreach( MyFunc, SkillEffect#skill_effect.effect_list )
		end
	catch
		_->ok
end.

%%执行技能效果
%%SkillEffectCount=技能作用次数，=-1，表示根据SkillID配置作用次数，
doSkillEffect( Attacker, SkillCfg, Target, SkillEffectCount, SkillDamageID )->
	try
		%%先计算伤害
		DamageInfo = #damageInfo{ attackerID=element( ?object_id_index, Attacker ),
								 	beenAttackerID=element( ?object_id_index, Target ),
								  skillDamageID=SkillDamageID,
								  damage=0,
								  isBlocked=false,
								  isCrited=false
								  },

		DamageInfo2 =  damageCalculate:calc_Skill_Damage(Attacker, SkillCfg, Target, DamageInfo),
		
		case SkillCfg#skillCfg.damagePercent =:= 0 andalso SkillCfg#skillCfg.damageFixValue =:= 0 of
			true->ok; %%不进行伤害计算
			_->
				doSkillDamage( Attacker, SkillCfg, Target, DamageInfo2,SkillDamageID)
		end,
		
		%%如果自己已经死亡或目标已经死亡，跳出
		case map:isObjectDead( Attacker ) or map:isObjectDead( Target ) of
			true->throw(-1);
			false->ok
		end,

		%%遍历技能效果列表
		case etsBaseFunc:readRecord(main:getGlobalSkillEffectCfgTable(), SkillCfg#skillCfg.skill_id) of
			{} ->ok;
			SkillEffect->
				MyFunc = fun( #skill_effect_data{}=Record )->
								 doSkillEffectData( Attacker, SkillCfg, Target, DamageInfo2, Record )
						 end,
				lists:foreach( MyFunc, SkillEffect#skill_effect.effect_list )
		end,

		%%如果效果次数不只一次，再执行
		case SkillEffectCount =:= -1 of
			true->%%根据技能配置
				case SkillCfg#skillCfg.effectTimes > 1 of
					true->
						case canAttack( Attacker, Target, SkillCfg, false ) of
							true->doSkillEffect( Attacker, SkillCfg, Target, SkillCfg#skillCfg.effectTimes-1, SkillDamageID );
							false->ok
						end;
					false->ok	
				end;
			false->
				case SkillEffectCount > 1 of
					true->
						case canAttack( Attacker, Target, SkillCfg, false ) of
							true->doSkillEffect( Attacker, SkillCfg, Target, SkillEffectCount-1, SkillDamageID );
							false->ok
						end;
					false->ok
				end
		end,

		ok
	catch
		_->ok
	end.

%%执行伤害效果
doSkillDamage( Attacker, SkillCfg, Target, DamageInfo,SkillDamageID)->
	try
		AttackerType = element( 1, Attacker ),
		TargetType = element( 1, Target ),
		
		DamageHP = DamageInfo#damageInfo.damage,
		case DamageHP > 0 of
			true->
				case TargetType of
					mapPlayer->
						case Target#mapPlayer.life > DamageHP of
							true->
								charDefine:changeSetLife( Target, Target#mapPlayer.life - DamageHP, false ),
								TargetIsDead = false,
								RealDamageHP = DamageHP;
							false->
								TargetIsDead = true,
								case Target#mapPlayer.qieCuoPlayerID /= 0 of
									true->RemainLife = 1;
									false->RemainLife = 0
								end,
								charDefine:changeSetLife( Target, RemainLife, false ),
								RealDamageHP = Target#mapPlayer.life
						end,
						ok;
					mapMonster->
						case Target#mapMonster.life > DamageHP of
							true->
								charDefine:changeSetLife( Target, Target#mapMonster.life - DamageHP, false ),
								TargetIsDead = false,
								RealDamageHP = DamageHP;
							false->
								TargetIsDead = true,
								charDefine:changeSetLife( Target, 0, false ),
								RealDamageHP = Target#mapMonster.life
						end,
						%%是npc的话，直接去统计世界boss 伤害
						case worldBoss:isWorldBoss(Target) of 
								true->
									case AttackerType of
										mapPlayer->
											AttackerID = Attacker#mapPlayer.id,
											worldBossManagerPID!{worldBossHarm,self(),AttackerID,DamageHP};
										_->
											ok
									end;
								false->ok
						end,
						ok;
					mapPet->
						case Target#mapPet.life > DamageHP of
							true->
								charDefine:changeSetLife( Target, Target#mapPet.life - DamageHP, false ),
								TargetIsDead = false,
								RealDamageHP = DamageHP;
							false->
								TargetIsDead = true,
								charDefine:changeSetLife( Target, 0, false ),
								RealDamageHP = Target#mapPet.life
						end,
						ok;
					_->					
						% TargetType error, log it, add by wenziyong for dummy monster
						?ERROR_OUT("---for dummy monster,TargetType error,TargetType:~p",
									[TargetType]),
						TargetIsDead=0,RealDamageHP=0,throw(-1)
				end,
				ok;
			false->
				% no any damage, log it, add by wenziyong for dummy monster
				case TargetType of
					mapMonster->
						?ERROR_OUT("---for dummy monster,no any damage,monster_data_id:~p,life:~p,stateFlag:~p",
							[Target#mapMonster.monster_data_id,Target#mapMonster.life,Target#mapMonster.stateFlag]);
					_->
						?ERROR_OUT("---for dummy monster,no any damage,not monster,TargetType:~p",
							[TargetType])
				end,
				TargetIsDead=false,RealDamageHP=0,ok
		end,
		
		%%广播伤害消息，
		%%?
		case DamageInfo#damageInfo.isBlocked of
			true->
				Blocked = 1;
			_->
				Blocked = 0
		end,
		case DamageInfo#damageInfo.isCrited of
			true->
				Crited = 1;
			_->
				Crited = 0
		end,
		
		case TargetType of
			mapPlayer->
				%TargetName = Target#mapPlayer.name,
				
				Msg = #pk_GS2U_AttackDamage{	nDamageTarget       =Target#mapPlayer.id,
													nCombatID  =DamageInfo#damageInfo.skillDamageID,
													nSkillID        =SkillCfg#skillCfg.skill_id,
													nDamageLife     =DamageHP,
													nTargetLifePer100 =getObjectLifePer(Target),
													isBlocked=Blocked,
													isCrited=Crited};
			
			mapMonster->
				%TargetName = "Monster[" ++ common:formatString( Target#mapMonster.id ) ++ "]",
				
			   Msg = #pk_GS2U_AttackDamage {	nDamageTarget       =Target#mapMonster.id,
													nCombatID  =DamageInfo#damageInfo.skillDamageID,
													nSkillID        =SkillCfg#skillCfg.skill_id,
													nDamageLife     =DamageHP,
													nTargetLifePer100 =getObjectLifePer(Target),
													isBlocked=Blocked,
													isCrited=Crited };
			mapPet ->
			   %TargetName = Target#mapPet.name,
				
			   Msg = #pk_GS2U_AttackDamage {	nDamageTarget       =Target#mapPet.id,
													nCombatID  =DamageInfo#damageInfo.skillDamageID,
													nSkillID        =SkillCfg#skillCfg.skill_id,
													nDamageLife     =DamageHP,
													nTargetLifePer100 =getObjectLifePer(Target),
													isBlocked=Blocked,
													isCrited=Crited };
			_->%TargetName = "unkown", 
				Msg = 0
		end,
		
%% 		case AttackerType of
%% 			mapPlayer->
%% 				AttackerName = Attacker#mapPlayer.name;
%% 			mapMonster->
%% 				AttackerName = "Monster[" ++ common:formatString( Attacker#mapMonster.id ) ++ "]";
%% 			mapPet ->
%% 				AttackerName = Attacker#mapPet.name;
%% 			_->AttackerName = "unkown"
%% 		end,
		
		mapView:broadcast(Msg, Attacker, 0),
		
%% 		?DEBUG_OUT( "attacker[~p] target[~p] nCombatID[~p] nSkillID[~p] nDamageLife[~p] nTargetLifePer100[~p]",
%% 					[AttackerName, 
%% 					 TargetName, 
%% 					 Msg#pk_GS2U_AttackDamage.nCombatID,
%% 					 Msg#pk_GS2U_AttackDamage.nSkillID,
%% 					 Msg#pk_GS2U_AttackDamage.nDamageLife,
%% 					 Msg#pk_GS2U_AttackDamage.nTargetLifePer100
%% 					 ] ),
		
		%%加仇恨
		AddHatred = RealDamageHP + SkillCfg#skillCfg.skill_Hate,
		objectHatred:addHatredIntoObject( map:getObjectID( Target ), 
										  map:getObjectID( Attacker ), 
										  AddHatred ),
		
		case RealDamageHP > 0 of
			true->
				%%事件响应伤害了目标
				onDamageTarget( Attacker, SkillCfg, Target, RealDamageHP, TargetIsDead ),
				%%事件响应受到了伤害
				onDamage( Target, SkillCfg, Attacker, RealDamageHP, TargetIsDead );
			false->ok
		end,
		
		%%死亡
		case TargetIsDead of
			true->
				case TargetType of
					mapPlayer->
						%%切磋
						case Target#mapPlayer.qieCuoPlayerID /= 0 of
							true->qieCuo:qieCuo_Fail(Target, false);
							_->playerMap:doDead( Target, Attacker, SkillDamageID)
						end;
					mapMonster->
						monster:doDead( Target, Attacker,SkillDamageID );
					mapPet ->
						petMap:doDead( Target, Attacker,SkillDamageID);
					_->ok
				end;
			false->ok
		end,
		ok
	catch
		_->ok
	end.

%%响应伤害了目标事件
onDamageTarget( Attacker, SkillCfg, Target, DamageHP, TargetIsDead )->
	try
		%%buffer列表响应
		buff:onDamageTargetForBufferList( map:getObjectID( Attacker ), SkillCfg, map:getObjectID( Target ) ),
		%%其他一些事情，受到伤害时怎么怎么样。。。
		objectEvent:onEvent( Attacker, ?Char_Event_Damage_Target, 0),
		objectEvent:onEvent( etsBaseFunc:readRecord( map:getMapObjectTable(), map:getMapID()), ?Map_Event_Char_Damage, 
							{Target,Attacker,DamageHP} ),
		case element(1, Attacker) of
			mapPlayer ->
				case etsBaseFunc:readRecord(map:getMapPetTable(), Attacker#mapPlayer.nonceOutFightPetId) of
					{} ->ok;
					Pet ->
						%%如果有出战的宠物，执行宠物响应主人攻击目标
						petMap:onMasterDamageTarget(Pet, Attacker, Target, DamageHP, TargetIsDead)
				end,
				case element(1, Target) of
					mapPlayer->%%是玩家打玩家
						case mapActorStateFlag:isStateFlagByObject(Attacker, ?Player_State_Flag_PK_Kill ) of
							true->
								qieCuo:changePKKillTime(Attacker, common:timestamp());
							false->ok
						end,
						ok;
					_->ok
				end,

				ok;
			_ ->
				ok
		end
	catch
		_->ok
	end.

%%响应受到伤害事件
onDamage( Target, SkillCfg, Attacker, DamageHP, TargetIsDead )->
	try
		%%buffer列表响应
		buff:onDamageForBufferList( map:getObjectID( Target ), SkillCfg, map:getObjectID( Attacker ), DamageHP, TargetIsDead ),
		%%其他一些事情，受到伤害时怎么怎么样。。。
		objectEvent:onEvent( Target, ?Char_Event_OnDamage, 0),
		objectEvent:onEvent( etsBaseFunc:readRecord( map:getMapObjectTable(), map:getMapID()), ?Map_Event_Char_Harmed, 
							{Target,Attacker,DamageHP} ),

		case element(1, Target) of
			mapPlayer ->
				%%如果被攻击的人有pk 保护buff 取消掉
				case element(1, Attacker) of
					mapPlayer->
						AttackerID=map:getObjectID(Attacker),
						case buff:hasPkProcted(AttackerID) of
							true->
								case (Target#mapPlayer.qieCuoPlayerID=:= Attacker#mapPlayer.id) of
									true->
										ok;
									false->
										%%如果不是切磋,那么保护时间取消掉
										buff:removeBuffByEffectType(AttackerID, ?Buff_Effect_Type_PKProcted),
										variant:setPlayerVarValueFromMap(Attacker,?PlayerVariant_Index_InPeaceKilledByPlayerTime_M,0)%%非和平，时间清掉
								end;
							false->
								ok
						end;
					_->
						ok
				end,
				case etsBaseFunc:readRecord(map:getMapPetTable(), Target#mapPlayer.nonceOutFightPetId) of
					{} ->ok;
					Pet ->
						%%如果有出战的宠物，执行宠物响应主人被攻击
						petMap:onTargetDamageMaster(Pet, Target, Attacker, DamageHP, TargetIsDead)
				end;
			_ ->
				ok
		end,
		ok
	catch
		_->ok
	end.

%%响应闪避了攻击
onDodgeSucc( _Target, _SkillCfg, _Attacker )->
	try
		ok
	catch
		_->ok
	end.


%%执行技能效果配置数据
doSkillEffectData( Attacker, SkillCfg, Target, DamageInfo, 
				   #skill_effect_data{}=Skill_effect_data )->
	try
		case DamageInfo of
			{}->SkillDamageID = 0;
			_->SkillDamageID = DamageInfo#damageInfo.skillDamageID
		end,

		case Skill_effect_data#skill_effect_data.effect_type of
			?SkillEffectType_CreateBuffer->
				%%创建Buffer
				case etsBaseFunc:readRecord( main:getGlobalBuffCfgTable(), Skill_effect_data#skill_effect_data.param1 ) of
					{}->ok;
					AddBuffCfg->
						case Skill_effect_data#skill_effect_data.effect_target_type of
							?Effect_Target_Type_Target->
								buff:addBuffer( map:getObjectID( Target ), AddBuffCfg, map:getObjectID( Attacker ), 0, SkillCfg, SkillDamageID );
							?Effect_Target_Type_Self->
								buff:addBuffer( map:getObjectID( Attacker ), AddBuffCfg, map:getObjectID( Attacker ), 0, SkillCfg, SkillDamageID )
						end
				end,
				case etsBaseFunc:readRecord( main:getGlobalBuffCfgTable(), Skill_effect_data#skill_effect_data.param2 ) of
					{}->ok;
					AddBuffCfg2->
						case Skill_effect_data#skill_effect_data.effect_target_type of
							?Effect_Target_Type_Target->
								buff:addBuffer( map:getObjectID( Target ), AddBuffCfg2, map:getObjectID( Attacker ), 0, SkillCfg, SkillDamageID );
							?Effect_Target_Type_Self->
								buff:addBuffer( map:getObjectID( Attacker ), AddBuffCfg2, map:getObjectID( Attacker ), 0, SkillCfg, SkillDamageID )
						end
				end,
				
				case etsBaseFunc:readRecord( main:getGlobalBuffCfgTable(), Skill_effect_data#skill_effect_data.param3 ) of
					{}->ok;
					AddBuffCfg3->
						case Skill_effect_data#skill_effect_data.effect_target_type of
							?Effect_Target_Type_Target->
								buff:addBuffer( map:getObjectID( Target ), AddBuffCfg3, map:getObjectID( Attacker ), 0, SkillCfg, SkillDamageID );
							?Effect_Target_Type_Self->
								buff:addBuffer( map:getObjectID( Attacker ), AddBuffCfg3, map:getObjectID( Attacker ), 0, SkillCfg, SkillDamageID )
						end
				end,
				
				case etsBaseFunc:readRecord( main:getGlobalBuffCfgTable(), Skill_effect_data#skill_effect_data.param4 ) of
					{}->ok;
					AddBuffCfg4->
						case Skill_effect_data#skill_effect_data.effect_target_type of
							?Effect_Target_Type_Target->
								buff:addBuffer( map:getObjectID( Target ), AddBuffCfg4, map:getObjectID( Attacker ), 0, SkillCfg, SkillDamageID );
							?Effect_Target_Type_Self->
								buff:addBuffer( map:getObjectID( Attacker ), AddBuffCfg4, map:getObjectID( Attacker ), 0, SkillCfg, SkillDamageID )
						end
				end;
			?SkillEffectType_RunScriptEvent->
				objectEvent:onEvent( Attacker,Skill_effect_data#skill_effect_data.param1,Target);
			_->ok
		end,

		DamageInfo
	catch
		_->DamageInfo
	end.

%%删除技能效果配置数据
removeSkillEffectData(Object, _SkillCfg, #skill_effect_data{}=Skill_effect_data) ->
	try
		case Skill_effect_data#skill_effect_data.effect_type of
			?SkillEffectType_CreateBuffer->
				%%移除Buffer
				buff:removeBuff(map:getObjectID(Object), Skill_effect_data#skill_effect_data.param1);
			_->ok
		end
	catch
		_->ok
end.

%%返回能否命中，返回值=true表示命中了，=false表示没有命中
isHitSucc( Attacker, SkillCfg )->
	case ( SkillCfg#skillCfg.hit_Spec band ?SkillHitSpec_Not_HitTest) /= 0 of
		true->true;
		_->
			Rand = random:uniform(10000),
			case Rand =< charDefine:getObjectProperty(Attacker, ?hit_rate_rate ) of
				true->true;
				false->false
			end
	end.

%%返回是否闪避，返回值=true表示闪避了，=false表示没有闪避
isDodgeSucc( Target, SkillCfg )->
	case ( SkillCfg#skillCfg.hit_Spec band ?SkillHitSpec_Not_DodgeTest) /= 0 of
		true->false;
		_->
			NotDodgeState = ( ?Actor_State_Flag_Disable_Hold ) bor ( ?Actor_State_Flag_Disable_Move ),
			case mapActorStateFlag:isStateFlag( map:getObjectID(Target), NotDodgeState ) of
				true->false;
				false->
					Rand = random:uniform(10000),
					case Rand =< charDefine:getObjectProperty(Target, ?dodge_rate ) of
						true->true;
						false->false
					end
			end
	end.

