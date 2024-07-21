%% Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(petMap).

-include("db.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("monsterDefine.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("taskDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 

onPlayerCallPet(PlayerId, PID, Pet, PetCfg, _BuffData ) ->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerId) of
		{} ->
			PID ! {petOutFight_Result, Pet#petProperty.id, false};
		Player ->
			MapPet = makeMapPet(Pet, PetCfg, Player),
			map:enterMapPet(MapPet, Player),
			PID ! {petOutFight_Result, Pet#petProperty.id, true}
	end.

makeMapPetSkill( #petProperty{} = Pet ) ->
	case Pet#petProperty.skills of
		[] ->[];
		Skills ->
			put( "TempPetSkillList", [] ),
			Func = fun(Record) ->
						   case  etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), Record#petSkill.skillId) of
							   {}->
								   ?ERROR_OUT("[petskill], data_id = [~p] undefined, please check config", [Record#petSkill.skillId]);
							   SkillCfg->
								   PetSkill = #mapPetSkill{
														   skillId = Record#petSkill.skillId,
														   coolDownTime=Record#petSkill.coolDownTime,
														   skillCfg = SkillCfg
														  },
								   put( "TempPetSkillList", get( "TempPetSkillList" )++[PetSkill] )
						   end
				   end,
			lists:foreach(Func, Skills),
			get( "TempPetSkillList" )
	end.

makeMapPet( #petProperty{} = Pet, PetCfg, Player )->
	case Pet#petProperty.showModel of
		?PetShowModel_Model->
			ModelId = PetCfg#petCfg.petID;
		?PetShowModel_ExModel->
			ModelId = Pet#petProperty.exModelId
	end,

	#mapPet{
			id=Pet#petProperty.id, 
			event_array=undefined,
			objType = ?Object_Type_Pet,
			ets_table=map:getMapPetTable(),
			timerList=undefined,
			masterId=Pet#petProperty.masterId, 
			data_id=Pet#petProperty.data_id, 
			moveState=?Object_MoveState_Stand, 
			aiState=Pet#petProperty.aiState,
			level=Pet#petProperty.level, 
			pos=#posInfo{x=Player#mapPlayer.pos#posInfo.x,y=Player#mapPlayer.pos#posInfo.y}, 
			name=Pet#petProperty.name, 
			titleid=Pet#petProperty.titleId, 
			modelId=ModelId, 
			life=Pet#petProperty.life, 
			finalProperty=array:new(?property_count, {default, 0}),
			base_quip_ProFix=Pet#petProperty.propertyArray,
			base_quip_ProPer=array:new(?property_count, {default, []}),
			skill_ProFix=array:new(?property_count, {default, 0}),
			skill_ProPer=array:new(?property_count, {default, []}),
			stateFlag=0, 
			stateRefArray=array:new(?Buff_Effect_Type_Num, {default, 0}),
			moveTargetList=[], 
			attackTargetId=0,
			mapSkills = makeMapPetSkill(Pet),
			skillCommonCD = 0,
			petCfg = PetCfg,
			laterUseSkill=0,
			lastUseSkill=0
			}.

%%宠物学习技能
onPetLearnSkill(PlayerId, PetId, SkillId, NewSkillId)->
	try
		Pet = etsBaseFunc:readRecord(map:getMapPetTable(), PetId),
		case  Pet of
			{} ->throw(-1);
			_->ok
		end,
		
		SkillCfg = etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), NewSkillId),
		case SkillCfg of
			{}->throw(-1);
			_->ok
		end,
		
		%%如果是升级老技能，先删除老技能
		case SkillId =:= NewSkillId of
			false->
				onPetDelSkill(PlayerId, PetId, SkillId);
			true->ok
		end,
		
		%%将技能写入宠物地图数据
		etsBaseFunc:changeFiled(map:getMapPetTable(), PetId, #mapPet.mapSkills, 
								Pet#mapPet.mapSkills++[#mapPetSkill{skillId=NewSkillId, coolDownTime={0,0,0}, skillCfg=SkillCfg}]),
		
		%%如果是被动技能立即生效
		case SkillCfg#skillCfg.skillTriggerType of
			?SkillTrigger_Passive->
				doPassiveSkill( etsBaseFunc:readRecord(map:getMapPetTable(), PetId), NewSkillId);
			_->throw(-1)
		end
		
	catch
		_->ok
end.

%%宠物删除技能
onPetDelSkill(_PlayerId, PetId, SkillId )->
	try
		Pet = etsBaseFunc:readRecord(map:getMapPetTable(), PetId),
		case Pet of
			{}->throw(-1);
			_->ok
		end,
		
		Skill = lists:keyfind(SkillId, #mapPetSkill.skillId, Pet#mapPet.mapSkills),
		case Skill of
			false->throw(-1);
			_->ok
		end,
		
		etsBaseFunc:changeFiled(map:getMapPetTable(), PetId, #mapPet.mapSkills, 
								lists:keydelete(SkillId, #mapPetSkill.skillId, Pet#mapPet.mapSkills)),
		
		%%如果删除的是被动技能，删除此技能所添加的buff
		case Skill#mapPetSkill.skillCfg#skillCfg.skillTriggerType of
			?SkillTrigger_Passive->
				unDoPassiveSkill(Pet, SkillId);
			_->throw(-1)
		end
	
	catch
		_->ok
end.

%%宠物幻化
onPetChangeModel( PetId, ShowModel )->
	try
		Pet = etsBaseFunc:readRecord(map:getMapPetTable(), PetId),
		case Pet of
			{}->throw(-1);
			_->ok
		end,
		
		etsBaseFunc:changeFiled(map:getMapPetTable(), PetId, #mapPet.modelId, ShowModel),
		
		Msg = #pk_PetChangeModel{ petId=PetId, modelID=ShowModel},
		mapView:broadcast(Msg, Pet, 0)
	catch
		_->ok
end.

%%宠物离开地图
onExitedMap( #mapPet{}=Pet )->
	PetId = Pet#mapPet.id,
	
	%%删除宠物所有的被动技能效果
	unDoAllPassiveSkill(Pet),
	
	%%保存宠物buff
	buff:onSaveObjectBuffData(PetId),
	
 	objectHatred:clearHatred( PetId ),
 	
 	etsBaseFunc:deleteRecord( map:getObjectBuffTable(), PetId ),
 
 	etsBaseFunc:deleteRecord( map:getObjectHatredTable(), PetId ),
	
	etsBaseFunc:changeFiled(map:getMapPlayerTable(), Pet#mapPet.masterId, #mapPlayer.nonceOutFightPetId, 0),
	
	etsBaseFunc:deleteRecord( map:getMapPetTable(), PetId),

	ok.

%%删除宠物所有的被动技能效果
unDoAllPassiveSkill(#mapPet{}=Pet) ->
	case Pet#mapPet.mapSkills of
		[]->ok;
		_->
			Player = etsBaseFunc:readRecord(map:getMapPlayerTable(), Pet#mapPet.masterId),
			Fun = fun(Skill)-> 
						  case Skill#mapPetSkill.skillCfg#skillCfg.skillTriggerType of
							  ?SkillTrigger_Passive-> 
								  case Skill#mapPetSkill.skillCfg#skillCfg.skillUseTargetType of
									  ?SkillUseTarget_Self->%%对自己使用
										  objectAttack:doRemovePassiveSkillEffect(Pet, Skill#mapPetSkill.skillCfg);
									  ?SkillUseTarget_Master->%%对主人使用
										  case Player of
											  {}->ok;
											  _->objectAttack:doRemovePassiveSkillEffect(Player, Skill#mapPetSkill.skillCfg)
										  end;
									  _->ok
								  end;
							  _->ok
						  end 
				  end,
			lists:foreach(Fun, Pet#mapPet.mapSkills)
	end.
					   

%%删除宠物一个被动技能的效果
unDoPassiveSkill(#mapPet{}=Pet, SkillId)->
	case lists:keyfind(SkillId, #mapPetSkill.skillId, Pet#mapPet.mapSkills) of
		false->ok;
		Skill->
			case Skill#mapPetSkill.skillCfg#skillCfg.skillTriggerType of
				?SkillTrigger_Passive->  
					case Skill#mapPetSkill.skillCfg#skillCfg.skillUseTargetType of 
						?SkillUseTarget_Self->%%对自己使用
							objectAttack:doRemovePassiveSkillEffect(Pet, Skill#mapPetSkill.skillCfg);
						?SkillUseTarget_Master->
							%%对主人使用
							case etsBaseFunc:readRecord(map:getMapPlayerTable(), Pet#mapPet.masterId) of
								{}->ok;
								Player->
									objectAttack:doRemovePassiveSkillEffect(Player, Skill#mapPetSkill.skillCfg)
							end;
						_->ok
					end;
				_->ok
			end 
	end.

%%宠物进入地图
onEnterMap(#mapPet{}=Pet) ->
	try
		%%执行所有被动技能效果
		doAllPassiveSkill(Pet),
		%%设置宠物血量满值
		case etsBaseFunc:readRecord(map:getMapPetTable(), Pet#mapPet.id) of
			{}->ok;
			Pet2->
				charDefine:changeSetLife(Pet2, array:get(?max_life, Pet2#mapPet.finalProperty), true)
		end
	
	catch
		_->ok
end.


%%执行宠物的所有被动技能
doAllPassiveSkill(#mapPet{}=Pet) ->
	%%被动技能生效
	case Pet#mapPet.mapSkills of
		[]->ok;
		_->
			Player = etsBaseFunc:readRecord(map:getMapPlayerTable(), Pet#mapPet.masterId),
			Fun = fun(Skill) ->
						  case Skill#mapPetSkill.skillCfg#skillCfg.skillTriggerType of
							  ?SkillTrigger_Passive-> 
								  case Skill#mapPetSkill.skillCfg#skillCfg.skillUseTargetType of
									  ?SkillUseTarget_Self->%%对自己使用
										  objectAttack:doPassiveSkillEffect(Pet, Skill#mapPetSkill.skillCfg, Pet);
									  ?SkillUseTarget_Master->%%对主人使用
										  case Player of
											  {}->ok;
											  _->objectAttack:doPassiveSkillEffect(Pet, Skill#mapPetSkill.skillCfg, Player)
										  end;
									  _->ok
								  end;
							  _->ok
						  end
				  end,
			lists:foreach(Fun, Pet#mapPet.mapSkills)
	end.

%%执行宠物的一个被动技能
doPassiveSkill(#mapPet{}=Pet, SkillId)->
	case lists:keyfind(SkillId, #mapPetSkill.skillId, Pet#mapPet.mapSkills) of
		false->ok;  %%没有学会技能
		Skill->
			case Skill#mapPetSkill.skillCfg#skillCfg.skillTriggerType of
				?SkillTrigger_Passive->
					case Skill#mapPetSkill.skillCfg#skillCfg.skillUseTargetType of
						?SkillUseTarget_Self->		%%对自己使用
							objectAttack:doPassiveSkillEffect(Pet, Skill#mapPetSkill.skillCfg, Pet);
						?SkillUseTarget_Master-> %%对主人使用
							case etsBaseFunc:readRecord(map:getMapPlayerTable(), Pet#mapPet.masterId) of
								{}->ok;
								Player->
									objectAttack:doPassiveSkillEffect(Pet, Skill#mapPetSkill.skillCfg, Player)
							end;
						_->ok
					end;
				_->ok			%%不是被动技能
			end
	end.


onMasterDamageTarget( Pet, _Master, Target, _DamageHP, TargetIsDead ) ->
	case Pet#mapPet.aiState of
		?Pet_AI_State_InitiativeFight ->
			case TargetIsDead of
				true ->ok;
				false ->
					%%设置宠物的攻击目标为主人的当前目标
					case element(1, Target) of
						mapPlayer ->
							TargetId = Target#mapPlayer.id;
						mapMonster ->
							TargetId = Target#mapMonster.id;
						mapPet ->
							TargetId = Target#mapPet.id;
						_->
							TargetId = 0
					end,
					etsBaseFunc:changeFiled(map:getMapPetTable(), Pet#mapPet.id, #mapPet.attackTargetId, TargetId),
					ok
			end;
		_ ->ok
	end.

onTargetDamageMaster( Pet, _Master, Target, _DamageHP, TargetIsDead ) ->
	case Pet#mapPet.aiState of
		?Pet_AI_State_PassiveFight ->
			case element(1, Target) of
				mapPlayer ->
					TargetId = Target#mapPlayer.id;
				mapMonster ->
					TargetId = Target#mapMonster.id;
				mapPet ->
					TargetId = Target#mapPet.id;
				_->
					TargetId = 0
			end,
			case map:getMapObjectByID(Pet#mapPet.attackTargetId) of
				{}->
					case TargetIsDead of
						true ->ok;
						false ->
							%%设置宠物的攻击目标为攻击主人的目标
							etsBaseFunc:changeFiled(map:getMapPetTable(), Pet#mapPet.id, #mapPet.attackTargetId, TargetId),
							ok
					end;
				%%宠物有当前目标
				NonceTarget ->
					case element(1, NonceTarget) of
						mapPlayer ->
							IsDead = playerMap:isDead(NonceTarget#mapPlayer.id);
						mapMonster ->
							IsDead = monster:isDead(NonceTarget#mapMonster.id);
						mapPet ->
							IsDead = petMap:isDead(NonceTarget#mapPet.id)
					end,
					
					%%如果目标已经死亡，切换目标
					case IsDead of
						true->
							%%设置宠物的攻击目标为攻击主人的目标
							etsBaseFunc:changeFiled(map:getMapPetTable(), Pet#mapPet.id, #mapPet.attackTargetId, TargetId);
						false->
							ok
					end
			end;
		_ ->ok
	end.

onPetChangeAIState(PlayerId, Pid, PetId, State) ->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerId) of
		{} ->
			Pid ! {petChangeAIState, false, PetId, State};
		Player ->
			case Player#mapPlayer.nonceOutFightPetId =:= PetId of
				false ->
					Pid ! {petChangeAIState, false, PetId, State};
				true ->
					case etsBaseFunc:readRecord(map:getMapPetTable(), PetId) of
						{} ->
							Pid ! {petChangeAIState, false, PetId, State};
						_Pet ->
							etsBaseFunc:changeFiled(map:getMapPetTable(), PetId, #mapPet.aiState, State),
							Pid ! {petChangeAIState, true, PetId, State}
					end
			end
	end.


%%宠物心跳,
onHeart(#mapPet{}=Pet, _Now) ->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), Pet#mapPet.masterId) of
		{}->
			map:despellObject(Pet#mapPet.id, erlang:now()),
			ok;
		Player ->
			onPetAndPlayerDisDispose(Pet, Player),
			Pet2 = etsBaseFunc:readRecord(map:getMapPetTable(), Pet#mapPet.id),
			case Pet2#mapPet.aiState of
				?Pet_AI_State_Follow ->
					onFollowAI(Pet2, Player);
				?Pet_AI_State_PassiveFight ->
					onPassiveFightAI(Pet2, Player);
				?Pet_AI_State_InitiativeFight ->
					onInitiativeFightAI(Pet2, Player);
				_ ->
					ok
			end
	end.

%%宠物和主人之间的距离处理
onPetAndPlayerDisDispose(Pet, Player) ->
	case (erlang:abs(Pet#mapPet.pos#posInfo.x - Player#mapPlayer.pos#posInfo.x) >= ?Pet_AND_Player_Jump_MaxDis) orelse
			 (erlang:abs(Pet#mapPet.pos#posInfo.y - Player#mapPlayer.pos#posInfo.y) >= ?Pet_AND_Player_Jump_MaxDis) of
		true ->
			objectHatred:clearHatred( Pet#mapPet.id ),
			etsBaseFunc:changeFiled(map:getMapPetTable(), Pet#mapPet.id, #mapPet.attackTargetId, 0),
			petMove:jumpTo(Pet, Player#mapPlayer.pos#posInfo.x, Player#mapPlayer.pos#posInfo.y),
			ok;
		false ->
			ok
	end.


%%主动战斗AI
onInitiativeFightAI(Pet, Player) ->
	try
		case map:getMapObjectByID(Pet#mapPet.attackTargetId) of
			{}->
				%%没有目标就查找玩家仇恨列表
				case objectHatred:getObjectMaxHatredTarget(Player#mapPlayer.id) of
					{}->throw({});
					Target ->
						throw(Target)
				end;
			Target2 ->
				throw(Target2)
			end
	catch
		{}->
			%%没有查找到目标，执行跟随AI
			onFollowAI(Pet, Player);
		Target3->
			case element(1, Target3) of
				mapPlayer ->
					IsDead = playerMap:isDead(Target3#mapPlayer.id);
				mapMonster ->
					IsDead = monster:isDead(Target3#mapMonster.id);
				mapPet ->
					IsDead = petMap:isDead(Target3#mapPet.id);
				_ ->IsDead = true
			end,
			
			case IsDead of
				true ->
					onFollowAI(Pet, Player);
				false ->
					%%执行攻击AI
					onAttactAI(Pet, Target3)
			end
end.

%%被动战斗AI
onPassiveFightAI(Pet, Player) ->
	case map:getMapObjectByID(Pet#mapPet.attackTargetId) of
		{} ->
			onFollowAI(Pet, Player);
		Target->
			case element(1, Target) of
				mapPlayer ->
					IsDead = playerMap:isDead(Target#mapPlayer.id);
				mapMonster ->
					IsDead = monster:isDead(Target#mapMonster.id);
				mapPet ->
					IsDead = petMap:isDead(Target#mapPet.id);
				_ ->IsDead = true
			end,
			
			case IsDead of
				false ->
					onAttactAI(Pet, Target);
				true ->
					onFollowAI(Pet, Player)
			end
	end.

%%返回是否有攻击能力
hasAttackMode( #mapPet{}=_Pet )->
	true.

%%技能是否CD
isPetSkillCoolDown( PetSKill, Now )->
	timer:now_diff(Now, PetSKill#mapPetSkill.coolDownTime)/1000 >= PetSKill#mapPetSkill.skillCfg#skillCfg.skillCoolDown.

%%设置技能CD
setPetSkillCDBegin( Pet, SkillId, Now )->
	case lists:keyfind(SkillId, #mapPetSkill.skillId, Pet#mapPet.mapSkills) of
		false->ok;
		PetSkill->
			PetSkillNew = PetSkill#mapPetSkill{coolDownTime=Now},
			NewSkillList = lists:keyreplace(SkillId, #mapPetSkill.skillId, Pet#mapPet.mapSkills, PetSkillNew),
			etsBaseFunc:changeFiled(map:getMapPetTable(), Pet#mapPet.id, #mapPet.mapSkills, NewSkillList),
			ok
	end.

%%获取可使用的技能
getCanUseSkillCfg(#mapPet{}=Pet, Now) ->
	put( "MapPetSkillTemp", 0 ),
	case Pet#mapPet.laterUseSkill of
		0->
			case Pet#mapPet.lastUseSkill =:= 0 orelse Pet#mapPet.lastUseSkill =:= Pet#mapPet.petCfg#petCfg.baseSkill_ID of
				true->  %%上次使用的是普通攻击，需要选择技能
					FuncSelectSkill = fun(Skill)->
											  case Skill#mapPetSkill.skillCfg#skillCfg.skillTriggerType /= ?SkillTrigger_Passive andalso
																						   isPetSkillCoolDown(Skill, Now) andalso 
																						   Skill#mapPetSkill.skillId > get("MapPetSkillTemp")  of
												  true->
													  put( "MapPetSkillTemp", Skill#mapPetSkill.skillId );
												  _->ok
											  end
									  end,
					lists:foreach(FuncSelectSkill, Pet#mapPet.mapSkills),
					ok;
				_->
					FuncSelectSkill2 = fun(Skill)->
											  case Skill#mapPetSkill.skillCfg#skillCfg.skillTriggerType /= ?SkillTrigger_Passive andalso
																						   isPetSkillCoolDown(Skill, Now) andalso 
																						   Skill#mapPetSkill.skillId < Pet#mapPet.lastUseSkill andalso
																						   Skill#mapPetSkill.skillId > get("MapPetSkillTemp")  of
												  true->
													  put( "MapPetSkillTemp", Skill#mapPetSkill.skillId );
												  _->ok
											  end
									  end,
					lists:foreach(FuncSelectSkill2, Pet#mapPet.mapSkills)
			end,
			etsBaseFunc:changeFiled(map:getMapPetTable(), Pet#mapPet.id, #mapPet.laterUseSkill, get("MapPetSkillTemp")),
			ok;
		_->
			put( "MapPetSkillTemp", Pet#mapPet.laterUseSkill )
	end,

	case get("MapPetSkillTemp") of
		0->
			etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), Pet#mapPet.petCfg#petCfg.baseSkill_ID);
		_->
			etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), get("MapPetSkillTemp"))
	end.

%%获取宠物到目标的距离SQ
getDistSQToTarget(Pet, Target) ->
	case element(1, Target) of
		mapPlayer->
			X = Target#mapPlayer.pos#posInfo.x,
			Y = Target#mapPlayer.pos#posInfo.y;
		mapMonster->
			X = Target#mapMonster.pos#posInfo.x,
			Y = Target#mapMonster.pos#posInfo.y;
		mapPet->
			X = Target#mapPet.pos#posInfo.x,
			Y = Target#mapPet.pos#posInfo.y
	end,
	
	XDis = Pet#mapPet.pos#posInfo.x - X,
	YDis = Pet#mapPet.pos#posInfo.y - Y,
	XDis*XDis + YDis*YDis.

%%攻击AI，
onAttactAI(Pet, Target) ->
	try
		case hasAttackMode(Pet) of
			true ->ok;
			false ->throw(-1)
		end,
		
		case objectHatred:isInHatred(Pet#mapPet.masterId, map:getObjectID(Target)) of
			true->ok;
			_->
				etsBaseFunc:changeFiled(map:getMapPetTable(), Pet#mapPet.id, #mapPet.attackTargetId, 0),
				throw(-1)
		end,
		
		Now = erlang:now(),
		_PetCfg = Pet#mapPet.petCfg,
		
		%%获取可使用的技能Cfg
		SkillCfg = getCanUseSkillCfg(Pet, Now),
		case SkillCfg of
			{} ->throw(-1);
			_ ->ok
		end,
		
		case SkillCfg#skillCfg.skillUseTargetType of
			?SkillUseTarget_Self->
				CheckDis = false,
				TargetNew = Pet,
				ok;
			?SkillUseTarget_Master->
				CheckDis = false,
				TargetNew = map:getMapObjectByID(Pet#mapPet.masterId),
				ok;
			?SkillUseTarget_Enemy->
				CheckDis = true,
				TargetNew = Target,
				ok;
			_->
				TargetNew = Target,
				CheckDis = true,
				throw(-1),
				ok
		end,
		
		%%判断攻击距离
		Dis = getDistSQToTarget(Pet, TargetNew),
		SkillDis = SkillCfg#skillCfg.rangerSquare,
		
		case CheckDis=:=false orelse SkillDis >= Dis of
			true -> %%在可攻击范围内
				%%公CD判断
				case Pet#mapPet.skillCommonCD of
					0 ->
						ok;
					_ ->
						%%公共CD
						CommonCD = array:get(?attack_speed, Pet#mapPet.finalProperty),
						case (timer:now_diff(Now, Pet#mapPet.skillCommonCD)/1000) >= CommonCD of
							true ->ok;
							false ->throw(-1)
						end
				end,
				case SkillCfg#skillCfg.skillRangeSquare > 0 of
					true->
						TargetList = [], 
						Pos = map:getObjectPos(TargetNew),
						PosX = Pos#posInfo.x,
						PosY = Pos#posInfo.y;
					_->
						TargetList = [TargetNew],
						PosX = 0,
						PosY = 0
				end,
				
				case skillUse:useSkill(Pet, TargetList, SkillCfg, PosX, PosY, -1, map:getMapCombatID()) of
					true->
						%%写入公共CD 和技能CD
						setPetSkillCDBegin( Pet, SkillCfg#skillCfg.skill_id, Now),
						etsBaseFunc:changeFiled(map:getMapPetTable(), Pet#mapPet.id, #mapPet.lastUseSkill, SkillCfg#skillCfg.skill_id),
						etsBaseFunc:changeFiled(map:getMapPetTable(), Pet#mapPet.id, #mapPet.laterUseSkill, 0),
						etsBaseFunc:changeFiled(map:getMapPetTable(), Pet#mapPet.id, #mapPet.skillCommonCD, Now);
					_->ok
				end,
				ok;
			false -> %%不在可攻击范围内
				case element(1, TargetNew) of
					mapPlayer->
						TargetPos = TargetNew#mapPlayer.pos;
					mapMonster->
						TargetPos = TargetNew#mapMonster.pos;
					mapPet->
						TargetPos = TargetNew#mapPet.pos
				end,
				moveAttackFollow(Pet, TargetPos, SkillDis)
		end
			
		
	catch 
		_->ok
end.

moveAttackFollow( #mapPet{}=Pet, TargetPos, DistAttackSQ )->
	try
		%%追击到距离目标DistAttackSQ少一点的位置
		FollowTargetDist = math:sqrt( DistAttackSQ )*0.81,
		CurTargetPos = petMove:getCurMoveTargetPos(Pet),
		case CurTargetPos of	
			{}->
				MoveTo = monsterMove:getDingBiFengDian( Pet#mapPet.pos, TargetPos, 0, FollowTargetDist ),
				petMove:moveTo(Pet, MoveTo#posInfo.x, MoveTo#posInfo.y);
			_->
				CurTargetDistSQ = monster:getDistSQFromTo( CurTargetPos#posInfo.x, CurTargetPos#posInfo.y, 
											   TargetPos#posInfo.x, TargetPos#posInfo.y ),
				case CurTargetDistSQ < DistAttackSQ of
					true->
						case petMove:isMoving(Pet) of
							true->ok;
							false->petMove:moveTo(Pet, CurTargetPos#posInfo.x, CurTargetPos#posInfo.y)
						end;
					false->
						MoveTo2 = monsterMove:getDingBiFengDian( Pet#mapPet.pos, TargetPos, 0, FollowTargetDist ),
						petMove:moveTo(Pet, MoveTo2#posInfo.x, MoveTo2#posInfo.y )
				end
		end,

		ok
	catch
		_->ok
	end.

%%跟随AI
onFollowAI(#mapPet{}=Pet, #mapPlayer{}=Player) ->
	case petMove:isMoving(Pet) of
		true ->ok;
		false ->
			case (erlang:abs(Pet#mapPet.pos#posInfo.x - Player#mapPlayer.pos#posInfo.x) >= ?Pet_AND_Player_Move_MaxDis) orelse
					 (erlang:abs(Pet#mapPet.pos#posInfo.y - Player#mapPlayer.pos#posInfo.y) >= ?Pet_AND_Player_Move_MaxDis) of
				true ->
					MoveTo = monsterMove:getDingBiFengDian( Pet#mapPet.pos, Player#mapPlayer.pos, 0, ?Pet_AND_Player_Move_MaxDis/2 ),
					petMove:moveTo(Pet, MoveTo#posInfo.x, MoveTo#posInfo.y),
					ok;
				false ->
					ok
			end
	end.

%%宠物休息
onPetTakeRest(PetId, Pid) ->
	case etsBaseFunc:readRecord(map:getMapPetTable(), PetId) of
		{}->
			Pid ! {petTakeRestResult, {}, false};
		Pet->
			Pid ! {petTakeRestResult, Pet, true}
	end,
	map:despellObject(PetId, erlang:now()).

%%返回是否已经死亡
isDead( PetId )->
	mapActorStateFlag:isStateFlag( PetId, ?Actor_State_Flag_Dead ).


%%响宠物血量变化
onHPChanged( #mapPet{}=_Pet )->
	ok.

%%执行主人死亡动作
doMasterDead(Pet, Player ) ->
	Player#mapPlayer.pid ! {petTakeBack, Pet},
	map:despellObject(Pet#mapPet.id, erlang:now()).

%%执行死亡动作
doDead( #mapPet{}=Pet, WhoKillMe, CombatID )->
	try
		case mapActorStateFlag:isStateFlag(Pet#mapPet.id, ?Actor_State_Flag_Dead ) of
			true->throw(-1);%%重复死亡
			false->ok
		end,
		
		case petMove:isMoving(Pet) of
			true->petMove:stopMove(Pet);
			false->ok
		end,
		
		%%清buff
		buff:deathClearBuff(Pet#mapPet.id),
		
		%%清仇恨
		objectHatred:clearHatred( Pet#mapPet.id ),
		
		mapActorStateFlag:addStateFlag( Pet#mapPet.id, ?Actor_State_Flag_Dead ),

		
		%%广播死亡消息
		%%?		
		case WhoKillMe of
			{}->KillerID = 0;
			_->
				case element( 1, WhoKillMe ) of
					mapPlayer->KillerID = WhoKillMe#mapPlayer.id;
					mapMonster->KillerID = WhoKillMe#mapMonster.id;
					mapPet->KillerID = WhoKillMe#mapPet.id;
					_->KillerID = 0
				end
		end,

		Msg = #pk_GS2U_CharactorDead{
									nDeadActorID = Pet#mapPet.id,
									nKiller      = KillerID,
									nCombatNumber =CombatID
									},
		
		mapView:broadcast(Msg, WhoKillMe, 0),
		%%响应死亡事件
		onDead( Pet, WhoKillMe ),
		map:onObjectDead( ?Object_Type_Pet, Pet, WhoKillMe ),
		
		
		map:despellObject(Pet#mapPet.id, 0),
		
		%%切换状态
		%%?
		
		ok
	catch
		_->ok
	end.

%%响应死亡事件
onDead( #mapPet{}=Pet, _WhoKillMe )->
	try
		etsBaseFunc:changeFiled(map:getMapPlayerTable(), Pet#mapPet.masterId, #mapPlayer.nonceOutFightPetId, 0),
		%%向玩家进程发送宠物死亡消息
		case etsBaseFunc:readRecord(map:getMapPlayerTable(), Pet#mapPet.masterId) of
			{} ->ok;
			Player ->
				Player#mapPlayer.pid ! {petDead, Pet}
		end
	catch
		_->ok
	end.

onPlayerOffLine(Player) ->
	case Player#mapPlayer.nonceOutFightPetId of
		0->
			ok;
		PetId ->
			map:despellObject(PetId, 0)
	end,
	ok.

%%技能使用响应
onUsedSkill(_Pet, _SkillCfg, _Target )->
	ok.


%%玩家进程响应出战宠物属性改变
onPlayerPetPropertyChanged() ->
	case pet:getPet(pet:getPlayerOutFightPetId()) of
		{}->ok;
		Pet->
			player:sendMsgToMap({playerMsg_PetChanged, Pet#petProperty.id, Pet})
	end.

%%地图进程响应出战宠物属性改变
onPlayerMsg_PetChanged( PetID, PetProperty ) ->
	case etsBaseFunc:readRecord( map:getMapPetTable(), PetID ) of
		{}->ok;
		Pet->
			PetNew = Pet#mapPet{
								level=PetProperty#petProperty.level,
								titleid=PetProperty#petProperty.titleId,
								base_quip_ProFix=PetProperty#petProperty.propertyArray},
			etsBaseFunc:insertRecord(map:getMapPetTable(), PetNew),
			damageCalculate:calcFinaProperty(PetID),
			case etsBaseFunc:readRecord(map:getMapPetTable(), PetID) of
				{}->ok;
				Pet2->
					case Pet#mapPet.level < Pet2#mapPet.level of
						true->		%%宠物升级，血量回满
							charDefine:changeSetLife(Pet2, array:get(?max_life, Pet2#mapPet.finalProperty), true);
						_->ok
					end
			end
	end.

%%地图进程响应宠物名字改变
onPlayerMSG_PetChangeName(PetId, Name) ->
	try
		Pet = etsBaseFunc:readRecord(map:getMapPetTable(), PetId),
		case Pet of
			{}->throw(-1);
			_->ok
		end,
		
		etsBaseFunc:changeFiled(map:getMapPetTable(), PetId, #mapPet.name, Name),
	
		%%同步给客户端
		Msg = #pk_PetChangeName{ petId = PetId,
								 newName = Name},
		mapView:broadcast(Msg, Pet, 0)
	
	catch
		_->ok
end.

%%客户端请求宠物属性
onPlayerRequestPetPropetry( PlayerPID, PetID )->
	try
		Pet = etsBaseFunc:readRecord(map:getMapPetTable(), PetID),
		case Pet of
			{}->throw( -1 );
			_->ok
		end,
		PropetryArray = Pet#mapPet.finalProperty,
		Msg = #pk_GS2U_RequestOutFightPetPropetryResult{
														pet_id = PetID,
														attack = array:get(?attack, PropetryArray),		
														defence = array:get(?defence, PropetryArray),
														hit = array:get(?hit_rate_rate, PropetryArray),
														dodge = array:get(?dodge_rate, PropetryArray),
														block = array:get(?block_rate, PropetryArray),	
														tough = array:get(?tough_rate, PropetryArray),
														crit = array:get(?crit_rate, PropetryArray),	
														crit_damage_rate = array:get(?crit_damage_rate, PropetryArray),
														attack_speed = array:get(?attack_speed_rate, PropetryArray),
														pierce = array:get(?pierce_rate, PropetryArray),
														ph_def = array:get(?ph_def, PropetryArray),	
														fire_def = array:get(?fire_def, PropetryArray),	
														ice_def = array:get(?ice_def, PropetryArray),				
														elec_def = array:get(?elec_def, PropetryArray),
														poison_def = array:get(?poison_def, PropetryArray),
														coma_def = array:get(?coma_def, PropetryArray),		
														hold_def = array:get(?hold_def, PropetryArray),
														silent_def = array:get(?silent_def, PropetryArray),
														move_def = array:get(?move_def, PropetryArray),
														max_life = array:get(?max_life, PropetryArray)
														},
		player:sendToPlayerByPID(PlayerPID, Msg)
	catch
		_->ok
end.
 
  
  
  