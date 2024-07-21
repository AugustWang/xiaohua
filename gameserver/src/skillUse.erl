
-module(skillUse).

%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% Include files
%%
-include("db.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("package.hrl").
-include("playerDefine.hrl").

%%返回能否对目标使用技能
canUseSkillToTarget( Attacker, Target, SkillCfg, CheckDistance )->
	try
		case element(1, Attacker) of
			%%玩家
			mapPlayer->
				case SkillCfg#skillCfg.skillUseTargetType of
					?SkillUseTarget_Enemy->
						%%判断战斗关系
						case objectAttack:getAttackRelation(Attacker, Target) of
							{true, _} ->
								%%判断能否攻击目标
								throw(objectAttack:canAttack(Attacker, Target, SkillCfg, CheckDistance));
							_ ->
								throw(false)
						end;
					?SkillUseTarget_Self->
						%%判断自身能否使用技能
						NotAttackState = ( ?Actor_State_Flag_Dead ) bor 
											 ( ?Player_State_Flag_ChangingMap ) bor
									 		( ?Actor_State_Flag_Disable_Attack ) bor
									 		( ?Actor_State_Flag_Disable_Hold) ,
						case ( Attacker#mapPlayer.stateFlag band NotAttackState ) /= 0 of
							true->throw(false);%%不能使用技能
							false->throw(true)%%可以使用技能
						end;
					?SkillUseTarget_Pet->
						%%判断自身能否使用技能
						NotAttackState = ( ?Actor_State_Flag_Dead ) bor 
											 ( ?Player_State_Flag_ChangingMap ) bor
									 		( ?Actor_State_Flag_Disable_Attack ) bor
									 		( ?Actor_State_Flag_Disable_Hold) ,
						case ( Attacker#mapPlayer.stateFlag band NotAttackState ) /= 0 of
							true->throw(false);%%不能使用技能
							false->%%可以使用技能
									case (map:getObjectID(Target) =:= Attacker#mapPlayer.nonceOutFightPetId) andalso
											 map:isObjectDead(Target) =:= false of
										true->throw(true);
										false->throw(false)
									end
						end;
					?SkillUseTarget_Friend->
						%%判断战斗关系
						case objectAttack:getAttackRelation(Attacker, Target) of
							{true, _} -> %%敌对关系
								throw(false);
							_ ->
								ok
						end,
						%%判断自身能否使用技能
						NotAttackState = ( ?Actor_State_Flag_Dead ) bor 
											 ( ?Player_State_Flag_ChangingMap ) bor
									 		( ?Actor_State_Flag_Disable_Attack ) bor
									 		( ?Actor_State_Flag_Disable_Hold) ,
						case ( Attacker#mapPlayer.stateFlag band NotAttackState ) /= 0 of
							true->throw(false);%%不能使用技能
							false->%%可以使用技能
									%%目标是否死亡
									case map:isObjectDead(Target) of
										true->throw(false);  %%目标已经死亡
										false->throw(true)
									end
						end;
					?SkillUseTarget_Team->
						%%判断是否是队伍关系
						case objectAttack:getAttackRelation(Attacker, Target) of
							{false, ?Attack_Fail_Team} -> %%队伍关系
								ok;
							{false, ?Attack_Fail_Self}->		%%自身
								ok;
							
							{false, ?Attack_Fail_Friend}->
								%%战场中，友方目标
								MapCfg=map:getMapCfg(),
								case MapCfg#mapCfg.type=:= ?Map_Type_Battle of
									true->
										ok;
									false->
										throw(false),
										ok
								end,
								ok;
							_ ->
								throw(false)
						end,
						%%判断自身能否使用技能
						NotAttackState = ( ?Actor_State_Flag_Dead ) bor 
											 ( ?Player_State_Flag_ChangingMap ) bor
									 		( ?Actor_State_Flag_Disable_Attack ) bor
									 		( ?Actor_State_Flag_Disable_Hold) ,
						case ( Attacker#mapPlayer.stateFlag band NotAttackState ) /= 0 of
							true->throw(false);%%不能使用技能
							false->%%可以使用技能
									%%目标是否死亡
									case map:isObjectDead(Target) of
										true->throw(false);  %%目标已经死亡
										false->throw(true)
									end
						end;
					?SkillUseTarget_Guild->
						%%判断是否是帮会成员
						case element(1, Target) of
							mapPlayer->ok;
							mapPet->ok;
							_->throw(false)
						end,
						%%判断自身能否使用技能
						NotAttackState = ( ?Actor_State_Flag_Dead ) bor 
											 ( ?Player_State_Flag_ChangingMap ) bor
									 		( ?Actor_State_Flag_Disable_Attack ) bor
									 		( ?Actor_State_Flag_Disable_Hold) ,
						case ( Attacker#mapPlayer.stateFlag band NotAttackState ) /= 0 of
							true->throw(false);%%不能使用技能
							false->%%可以使用技能
									%%目标是否死亡
									case map:isObjectDead(Target) of
										true->throw(false);  %%目标已经死亡
										false->throw(true)
									end
						end;
					?SkillUseTarget_SelfPosEnemy->
						%%判断战斗关系
						case objectAttack:getAttackRelation(Attacker, Target) of
							{true, _} ->
								%%判断能否攻击目标
								throw(objectAttack:canAttack(Attacker, Target, SkillCfg, CheckDistance));
							_ ->
								throw(false)
						end;
					_->throw(false)
				end;
			
			
			%%宠物
			mapPet->
				case SkillCfg#skillCfg.skillUseTargetType of
					?SkillUseTarget_Enemy->
						%%判断战斗关系
						case objectAttack:getAttackRelation(Attacker, Target) of
							{true, _} ->	%%可以攻击
								ok;
							_ ->
								throw(false)
						end,
						%%判断能否攻击目标
						throw(objectAttack:canAttack(Attacker, Target, SkillCfg, CheckDistance));
					?SkillUseTarget_Self->
						%%判断自身能否使用技能
						NotAttackState = ( ?Actor_State_Flag_Dead ) bor 
											 ( ?Player_State_Flag_ChangingMap ) bor
									 		( ?Actor_State_Flag_Disable_Attack ) bor
									 		( ?Actor_State_Flag_Disable_Hold) ,
						case ( Attacker#mapPet.stateFlag band NotAttackState ) /= 0 of
							true->throw(false);%%不能使用技能
							false->throw(true)%%可以使用技能
						end;
					?SkillUseTarget_Master->
						%%判断主人是否死亡
						case Attacker#mapPet.masterId=:= map:getObjectID(Target) andalso 
												 map:isObjectDead(Target)=:= false of
							true->ok;
							false->throw(false)
						end,
						%%判断自身能否使用技能
						NotAttackState = ( ?Actor_State_Flag_Dead ) bor 
											 ( ?Player_State_Flag_ChangingMap ) bor
									 		( ?Actor_State_Flag_Disable_Attack ) bor
									 		( ?Actor_State_Flag_Disable_Hold) ,
						case ( Attacker#mapPet.stateFlag band NotAttackState ) /= 0 of
							true->throw(false);%%不能使用技能
							false->throw(true)%%可以使用技能
						end;
					?SkillUseTarget_Team->
						%%判断战斗关系
						case objectAttack:getAttackRelation(Attacker, Target) of
							{false, ?Attack_Fail_Team} -> %%队伍关系
								ok;
							{false, ?Attack_Fail_Friend}->
								%%战场中，友方目标
								MapCfg=map:getMapCfg(),
								case MapCfg#mapCfg.type=:= ?Map_Type_Battle of
									true->
										ok;
									false->
										throw(false),
										ok
								end,
								ok;
							_ ->
								throw(false)
						end,
						%%判断自身能否使用技能
						NotAttackState = ( ?Actor_State_Flag_Dead ) bor 
											 ( ?Player_State_Flag_ChangingMap ) bor
									 		( ?Actor_State_Flag_Disable_Attack ) bor
									 		( ?Actor_State_Flag_Disable_Hold) ,
						case ( Attacker#mapPet.stateFlag band NotAttackState ) /= 0 of
							true->throw(false);%%不能使用技能
							false->throw(true)%%可以使用技能
						end;
					?SkillUseTarget_SelfPosEnemy->
						%%判断战斗关系
						case objectAttack:getAttackRelation(Attacker, Target) of
							{true, _} ->
								%%判断能否攻击目标
								throw(objectAttack:canAttack(Attacker, Target, SkillCfg, CheckDistance));
							_ ->
								throw(false)
						end;
					_->throw(false)
				end;
			mapMonster->
				case SkillCfg#skillCfg.skillUseTargetType of
					?SkillUseTarget_Enemy->
						%%判断战斗关系
						case objectAttack:getAttackRelation(Attacker, Target) of
							{true, _} ->
								%%判断能否攻击目标
								throw(objectAttack:canAttack(Attacker, Target, SkillCfg, CheckDistance));
							_ ->
								throw(false)
						end;
					?SkillUseTarget_Self->
						%%判断自身能否使用技能
						NotAttackState = ( ?Actor_State_Flag_Dead ) bor 
											 ( ?Player_State_Flag_ChangingMap ) bor
									 		( ?Actor_State_Flag_Disable_Attack ) bor
									 		( ?Actor_State_Flag_Disable_Hold) ,
						case ( Attacker#mapMonster.stateFlag band NotAttackState ) /= 0 of
							true->throw(false);%%不能使用技能
							false->throw(true)%%可以使用技能
						end;
					?SkillUseTarget_Friend->
						case element( 1, Target ) of
							mapMonster->throw(true);
							_->throw(false)
						end;
					?SkillUseTarget_SelfPosEnemy->
						%%判断战斗关系
						case objectAttack:getAttackRelation(Attacker, Target) of
							{true, _} ->
								%%判断能否攻击目标
								throw(objectAttack:canAttack(Attacker, Target, SkillCfg, CheckDistance));
							_ ->
								throw(false)
						end;
					_->throw(false)
				end;
			_->ok
		end
	catch
		Return->Return
end.

%%使用技能
useSkill(AttackObj, TargetObjList, SkillCfg, PosX, PosY, SkillEffectCount, CombatID)->
	case AttackObj of
		{}->false;
		_->
			%%判断是否是群攻
			case SkillCfg#skillCfg.skillRangeSquare > 0 andalso SkillCfg#skillCfg.creatAOE /= 0 of
				true->
					useAOESKillToPos(AttackObj, SkillCfg, PosX, PosY, SkillEffectCount, CombatID);
				false->
					useSkillToTarget( AttackObj, SkillCfg, TargetObjList, PosX, PosY, SkillEffectCount, CombatID )
			end
	end.

%%使用技能
useSkillToTarget( Attacker, SkillCfg, TargetObjList, PosX, PosY, SkillEffectCount, CombatID )->
	%%?以后添加失败通知客户端
	try
		AttackerID = map:getObjectID(Attacker),
		put( "SkillUse_Nonce_Target_Num", 0 ),
		GetCanAtkTargetList = fun( Target )->
									  case Target of
										  {}->
											  {};
										  _->
											  case skillUse:canUseSkillToTarget(Attacker, Target, SkillCfg, false) of
												  true->Target;
												  false->{}
											  end
									  end
							  end,
		
		UseFunc = fun( Target )->
						  try
							  case Target of
									{}->
										throw(0);
									_->ok
							  end,

							  put( "SkillUse_Nonce_Target_Num", get("SkillUse_Nonce_Target_Num") + 1 ),
							  %%技能命中测试
							  case SkillCfg#skillCfg.maxEffectCount of
								  0-> 
									  IsHit = objectAttack:isHitSucc(Attacker, SkillCfg);
								  MaxEffectCount->
									  case get("SkillUse_Nonce_Target_Num") =< MaxEffectCount of
										  true->IsHit = objectAttack:isHitSucc(Attacker, SkillCfg);
										  _->IsHit = false
									  end
							  end,
							  %%技能使用成功事件响应
							  onUsedSkill( Attacker, SkillCfg, Target ),

							  TargetID = map:getObjectID(Target),
								  
							  case IsHit of
								  false->%%miss了
									mapView:broadcast(#pk_GS2U_AttackMiss{
																		  nActorID=AttackerID,
																		  nTargetID=TargetID,  
																		  nCombatID=CombatID}, 
													  Target, 0),
									throw(TargetID);
								  true->
										 %%闪避判断
										 case objectAttack:isDodgeSucc( Target, SkillCfg ) of
										  true->%%闪避成功，结束流程，不用进行伤害计算，客户端显示闪避
												mapView:broadcast(#pk_GS2U_AttackDodge{
																					   nActorID=AttackerID, 
																					   nTargetID=TargetID,  
																					   nCombatID=CombatID}, 
																  Target, 0),
											 objectAttack:onDodgeSucc(Target, SkillCfg, Attacker),
											 throw(TargetID);
										  false->%%闪避失败，进入伤害计算
											 ok
									  end
								 end,
								  
								 %%根据技能飞行做延迟伤害
								 %%?
							  FlyTime = 0,%%objectAttack:getSkillFlyTime( map:getObjectPos(Attacker), SkillCfg, map:getObjectPos( Target ) ),
							  case FlyTime > 0 of
								  true->
									  %%飞行
									  erlang:send_after( FlyTime,self(), {skillFlyTimer, 
																  AttackerID, 
																  SkillCfg, 
																  TargetID, 
																  SkillEffectCount,
																  CombatID } ),
									  ok;
								  false->
									  %%执行技能效果
									  objectAttack:doSkillEffect( Attacker, SkillCfg, Target, SkillEffectCount, CombatID )
							  end,
							  TargetID
						  
						  catch
							  ID->ID
						  end
				  end,

		%%根据目标类型判断真正的目标
		case SkillCfg#skillCfg.skillUseTargetType of
			?SkillUseTarget_Enemy->TargetObjListNew = TargetObjList;	
			?SkillUseTarget_Self->TargetObjListNew = [Attacker];
			?SkillUseTarget_Friend->TargetObjListNew = [];
			?SkillUseTarget_SelfPosEnemy->TargetObjListNew = TargetObjList;
			?SkillUseTarget_Master->
				case element( 1, Attacker ) of
					mapPet->
						case etsBaseFunc:readRecord(map:getMapPlayerTable(), Attacker#mapPet.masterId ) of
							{}->TargetObjListNew=[],throw(false);
							Master->TargetObjListNew=[Master]
						end;
					_->TargetObjListNew=[],throw(false)
				end;
			?SkillUseTarget_Pet->
				case element( 1, Attacker ) of
					mapPlayer->
						case etsBaseFunc:readRecord(map:getMapPetTable(), Attacker#mapPlayer.nonceOutFightPetId) of
							{}->TargetObjListNew=[],throw(false);
							Pet->TargetObjListNew=[Pet]
						end;
					_->TargetObjListNew=[],throw(false)
				end;
			?SkillUseTarget_Team->TargetObjListNew=[];
			?SkillUseTarget_Guild->TargetObjListNew=[];
			_->TargetObjListNew=[],throw(false)
		end,

		FuncIDList = fun( Target )->
								case Target of
									{}->0;
									_->map:getObjectID(Target)
								end
						end,

		case TargetObjListNew of
			[]->			
				case SkillCfg#skillCfg.skillRangeSquare > 0 of
					true->  %%如果没有目标列表并且是群攻技能，查找可以攻击到的目标
							CharList = mapView:getAroundCanAttackList(PosX, PosY, false),
							%%筛选可作用到的怪物，玩家，宠物
							Dis = SkillCfg#skillCfg.skillRangeSquare,
							CanUseFun = fun(Char) ->
												Pos = map:getObjectPos(Char),
												X = Pos#posInfo.x - PosX,
												Y = Pos#posInfo.y - PosY,
												X*X+Y*Y =< Dis
										   end,
							CanUseSkillObjectList = lists:filter(CanUseFun, CharList),

							%%先发使用技能消息
							
							RealObjectList = lists:map(GetCanAtkTargetList, CanUseSkillObjectList),
							Msg = #pk_GS2U_UseSkillToObject{
										nUserActorID=AttackerID,
										nSkillID = SkillCfg#skillCfg.skill_id,
										nTargetActorIDList = lists:filter(fun(ID)->ID /= 0 end, lists:map(FuncIDList, RealObjectList)),
										nCombatID = CombatID
									},
							mapView:broadcast(Msg, Attacker, 0),
							lists:foreach(UseFunc, RealObjectList);
					_->throw(false)
				end;
			_->
				%%先发使用技能消息
				RealObjectList = lists:map(GetCanAtkTargetList, TargetObjListNew),
				Msg = #pk_GS2U_UseSkillToObject{
							nUserActorID=AttackerID,
							nSkillID = SkillCfg#skillCfg.skill_id,
							nTargetActorIDList = lists:filter(fun(ID)->ID /= 0 end, lists:map(FuncIDList, RealObjectList)),
							nCombatID = CombatID
						},

				mapView:broadcast(Msg, Attacker, 0),

				case SkillCfg#skillCfg.skillRangeSquare > 0 of
					true->
						lists:foreach(UseFunc, RealObjectList);		%%如果有目标列表，对目标列表使用
					_->
						[Target|_] = RealObjectList,
						lists:foreach(UseFunc, [Target])
				end
		end,
		true
	catch
		ReturnValue->ReturnValue
	end.

%%使用对位置技能
useAOESKillToPos( Attacker, SkillCfg, PosX, PosY, _SkillEffectCount, CombatID )->
	%%广播使用技能
	MsgToUser = #pk_GS2U_UseSkillToPos{
									   nUserActorID=map:getObjectID(Attacker),
									   nSkillID=SkillCfg#skillCfg.skill_id,
									   x=PosX,
									   y=PosY,
									   nCombatID=CombatID,
									   id_list=[]},
	mapView:broadcast(MsgToUser, Attacker, 0),
	%%创建QOE技能特效
	createAOESkill(Attacker, SkillCfg, PosX, PosY, CombatID),
	true.  %%群攻技能使用肯定成功

useAOESkill( Attacker, SkillCfg, PosX_in, PosY_in, SkillEffectCount, CombatID )->
	try
		case SkillCfg#skillCfg.skillTriggerType of
			?SkillUseTarget_SelfPosEnemy-> %%如果技能是对自身位置使用
				Pos2 = map:getObjectPos(Attacker),
				PosX = Pos2#posInfo.x,
				PosY = Pos2#posInfo.y;
			_->
				PosX = PosX_in,
				PosY = PosY_in
		end,
		%%
		CharList = mapView:getAroundCanAttackList(PosX, PosY, false),
		%%筛选可作用到的怪物，玩家，宠物
		Dis = SkillCfg#skillCfg.skillRangeSquare,
		CanUseFun = fun(Char) ->
							Pos = map:getObjectPos(Char),
							X = Pos#posInfo.x - PosX,
							Y = Pos#posInfo.y - PosY,
							X*X+Y*Y =< Dis
					   end,
		CanUseSkillObjectList = lists:filter(CanUseFun, CharList),
		
		put( "SkillUse_Nonce_Target_Num", 0 ),
		UseSkillFun = fun(Target) ->
							  try
								  case skillUse:canUseSkillToTarget(Attacker, Target, SkillCfg, false) of
									  true->ok;
									  false->throw(0)
								  end,
								  put( "SkillUse_Nonce_Target_Num", get("SkillUse_Nonce_Target_Num") + 1 ),
								  %%技能命中测试
							 	 case SkillCfg#skillCfg.maxEffectCount of
									  0-> 
										  IsHit = objectAttack:isHitSucc(Attacker, SkillCfg);
									  MaxEffectCount->
										  case get("SkillUse_Nonce_Target_Num") =< MaxEffectCount of
											  true->IsHit = objectAttack:isHitSucc(Attacker, SkillCfg);
											  _->IsHit = false
										  end
								  end,
								  %%技能使用成功事件响应
								  onUsedSkill( Attacker, SkillCfg, Target ),

								  AttackerID = map:getObjectID(Attacker),
								  TargetID = map:getObjectID(Target),
								  
								  case IsHit of
									  false->%%miss了
										mapView:broadcast(#pk_GS2U_AttackMiss{
																			  nActorID=AttackerID,
																			  nTargetID=TargetID,  
																			  nCombatID=CombatID}, 
														  Target, 0),
										throw(TargetID);
									  true->
										  %%闪避判断
										  case objectAttack:isDodgeSucc( Target, SkillCfg ) of
											  true->%%闪避成功，结束流程，不用进行伤害计算，客户端显示闪避
													mapView:broadcast(#pk_GS2U_AttackDodge{
																						   nActorID=AttackerID, 
																						   nTargetID=TargetID,  
																						   nCombatID=CombatID}, 
																	  Target, 0),
												 objectAttack:onDodgeSucc(Target, SkillCfg, Attacker),
												 throw(TargetID);
											  false->%%闪避失败，进入伤害计算
												 ok
										  end
								  end,
								  
								  %%根据技能飞行做延迟伤害
								  %%?
								  FlyTime = 0, %%objectAttack:getSkillFlyTime( map:getObjectPos(Attacker), SkillCfg, map:getObjectPos( Target ) ),
								  case FlyTime > 0 of
									  true->
										  %%飞行
										  erlang:send_after( FlyTime,self(), {skillFlyTimer, 
																	  AttackerID, 
																	  SkillCfg, 
																	  TargetID, 
																	  SkillEffectCount,
																	  CombatID } ),
										  ok;
									  false->
										  %%执行技能效果
										  objectAttack:doSkillEffect( Attacker, SkillCfg, Target, SkillEffectCount, CombatID )
								  end
							  
							  catch
								  ID->ID
							  end
					  end,
		lists:foreach(UseSkillFun, CanUseSkillObjectList)
	catch
		_->ok
end.


createAOESkill( Attacker, SkillCfg, PosX, PosY, CombatID )->
	try
		case SkillCfg#skillCfg.effectTimes of
			0->throw(-1);
			_->ok
		end,
		
		ObjectCfg = etsBaseFunc:readRecord(main:getGlobalObjectCfgTable(), ?Global_Object_SkillEffect),
		case ObjectCfg of
			{}->throw(-1);
			_->ok
		end,
		
		Spawn = #mapSpawn{
						  id=0,
						  mapId=map:getMapID(),
						  type=?Object_Type_SkillEffect,
						  typeId=?Global_Object_SkillEffect,
						  x=PosX,
						  y=PosY,
						  param={
								 Attacker, %%param1存入Attacker数据用以计算伤害
								 SkillCfg, %%param2存入技能cfg用于计算伤害
								 CombatID%%param3存入伤害ID
								},
						  isExist=0},
		
		Object = objectActor:spawnObjectActor(Spawn),
		case Object of
			{}->throw(-1);
			_->ok
		end,
		
		objectEvent:registerTimerEvent(Object, SkillCfg#skillCfg.aoeDelay, true, ?MODULE, aoeAttackCallBackFunc, SkillCfg#skillCfg.effectTimes)
	
	catch
		_->ok
end.


%%skillObject产生效果回调函数
aoeAttackCallBackFunc(Object, Timer)->
	try
		Attacker = Object#mapObjectActor.param1,
		SkillCfg = Object#mapObjectActor.param2,
		
		%%产生一次群攻效果
		useAOESkill(Attacker, SkillCfg,
							Object#mapObjectActor.x, 
							Object#mapObjectActor.y, 
							1,
							Object#mapObjectActor.param3),
		
		case Timer#objectTimer.parama > 1 of
			true->
				 put( "on_objectTimer_param", Timer#objectTimer.parama-1 ),
				ok;
			false->
				%%删除技能特效object并且停止时间效果回调
				map:despellObject(Object#mapObjectActor.id, 0),
				stopTimer
		end
		
	catch
		_->ok
end.

%%攻击飞行时间到
onSkillFlyTime(AttackerID, SkillCfg, TargetID, SkillEffectCount, CombatID)->
	try
		Attacker = map:getMapObjectByID(AttackerID ),
		Target = map:getMapObjectByID(TargetID ),
		case ( Target =:= {} ) or ( Attacker =:= {}  )of
			true->throw(-1);
			false->ok
		end,
		
		case skillUse:canUseSkillToTarget(Attacker, Target, SkillCfg, false) of
			true->ok;
			false->throw(-1)
		end,

		objectAttack:doSkillEffect( Attacker, SkillCfg, Target, SkillEffectCount, CombatID ),
		
		ok
	catch
		_->ok
	end.


onUsedSkill( Attack, SkillCfg, Target )->
	case element(1, Attack) of
		mapPlayer->playerMap:onUsedSkill(Attack, SkillCfg, Target);
		mapPet->petMap:onUsedSkill(Attack, SkillCfg, Target);
		mapMonster->monster:onUsedSkill(Attack, SkillCfg, Target);
		_->ok
	end.