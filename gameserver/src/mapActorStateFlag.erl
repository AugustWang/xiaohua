%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(mapActorStateFlag).

%%
%% Include files
%%
-include("db.hrl").
-include("playerDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("mapDefine.hrl").


%%
%% Exported Functions
%%
-compile(export_all).

%%返回某ID对象的state_flag
getStateFlag( ObjectID )->
	ObjectData = map:getMapObjectByID( ObjectID ),
	case ObjectData of
		{}->0;
		_->
			ObjType = map:getObjectID_TypeID( ObjectID ),
			case ObjType of
				?Object_Type_Player->
					ObjectData#mapPlayer.stateFlag;
				?Object_Type_Npc->
					ObjectData#mapNpc.stateFlag;
				?Object_Type_Monster->
					ObjectData#mapMonster.stateFlag;
				?Object_Type_Pet->
					ObjectData#mapPet.stateFlag;
				_->0
			end
	end.

%%返回某状态是否存在，存在则返回为true，否则为false
isStateFlag( ObjectID, StateFlag )->
	ObjectData = map:getMapObjectByID( ObjectID ),
	case ObjectData of
		{}->false;
		_->
			ObjType = map:getObjectID_TypeID( ObjectID ),
			case ObjType of
				?Object_Type_Player->
					State = StateFlag band ( ObjectData#mapPlayer.stateFlag ),
					State > 0;
				?Object_Type_Npc->
					State2 = StateFlag band ( ObjectData#mapNpc.stateFlag ),
					State2 > 0;
				?Object_Type_Monster->
					State3 = StateFlag band ( ObjectData#mapMonster.stateFlag ),
					State3 > 0;
				?Object_Type_Pet->
					State3 = StateFlag band ( ObjectData#mapPet.stateFlag ),
					State3 > 0;
				_->false
			end
	end.

%%返回某状态是否存在，存在则返回为true，否则为false
isStateFlagByObject( Object, StateFlag )->
	case element( 1, Object ) of
		mapPlayer->State = StateFlag band ( Object#mapPlayer.stateFlag );
		mapMonster->State = StateFlag band ( Object#mapMonster.stateFlag );
		mapNpc->State = StateFlag band ( Object#mapNpc.stateFlag );
		mapPet->State = StateFlag band ( Object#mapPet.stateFlag );
		_->State = 0
	end,
	State > 0.

%%增加一状态，见%%//	生物状态标签，逻辑或关系Actor_State_Flag_Type
addStateFlag( ObjectID, StateFlag )->
	Object = map:getMapObjectByID( ObjectID ),
	ObjType = map:getObjectID_TypeID( ObjectID ),

	case Object of
		{}->ok;
		_->
			case ObjType of
				?Object_Type_Player->
					NewStateFlag = ( Object#mapPlayer.stateFlag ) bor StateFlag,
					etsBaseFunc:changeFiled( map:getMapPlayerTable(), ObjectID, #mapPlayer.stateFlag, NewStateFlag ),

					checkNeedBroad( Object, NewStateFlag, StateFlag ),
			
					Object#mapPlayer.pid ! { actorStateFlag, ?Actor_State_Flag_OP_Add, StateFlag };
				?Object_Type_Npc->
					NewStateFlag = ( Object#mapNpc.stateFlag ) bor StateFlag,
					etsBaseFunc:changeFiled( map:getMapNpcTable(), ObjectID, #mapNpc.stateFlag, NewStateFlag );
				?Object_Type_Monster->
					NewStateFlag = ( Object#mapMonster.stateFlag ) bor StateFlag,
					etsBaseFunc:changeFiled( map:getMapMonsterTable(), ObjectID, #mapMonster.stateFlag, NewStateFlag ),
					checkNeedBroad( Object, NewStateFlag, StateFlag );
				?Object_Type_Pet->
					NewStateFlag = ( Object#mapPet.stateFlag ) bor StateFlag,
					etsBaseFunc:changeFiled( map:getMapPetTable(), ObjectID, #mapPet.stateFlag, NewStateFlag ),
					checkNeedBroad( Object, NewStateFlag, StateFlag );
				_->ok
			end,
	
			onStateFlagChanged( ObjectID, StateFlag, true ),
			ok
	end.

%%删除一状态，见%%//	生物状态标签，逻辑或关系Actor_State_Flag_Type
removeStateFlag( ObjectID, StateFlag )->
	Object = map:getMapObjectByID( ObjectID ),
	ObjType = map:getObjectID_TypeID( ObjectID ),
	case ObjType of
		?Object_Type_Player->
			NewStateFlag = ( Object#mapPlayer.stateFlag ) band ( bnot StateFlag ),
			etsBaseFunc:changeFiled( map:getMapPlayerTable(), ObjectID, #mapPlayer.stateFlag, NewStateFlag ),

			checkNeedBroad( Object, NewStateFlag, StateFlag ),

			Object#mapPlayer.pid ! { actorStateFlag, ?Actor_State_Flag_OP_Remove, StateFlag };
		?Object_Type_Npc->
			NewStateFlag = ( Object#mapNpc.stateFlag ) band ( bnot StateFlag ),
			etsBaseFunc:changeFiled( map:getMapNpcTable(), ObjectID, #mapNpc.stateFlag, NewStateFlag );
		?Object_Type_Monster->
			NewStateFlag = ( Object#mapMonster.stateFlag ) band ( bnot StateFlag ),
			etsBaseFunc:changeFiled( map:getMapMonsterTable(), ObjectID, #mapMonster.stateFlag, NewStateFlag ),
			checkNeedBroad( Object, NewStateFlag, StateFlag );
		?Object_Type_Pet->
			NewStateFlag = ( Object#mapPet.stateFlag ) band ( bnot StateFlag ),
			etsBaseFunc:changeFiled( map:getMapPetTable(), ObjectID, #mapPet.stateFlag, NewStateFlag ),
			checkNeedBroad( Object, NewStateFlag, StateFlag );
		_->ok
	end,
	
	onStateFlagChanged( ObjectID, StateFlag, false ),
	ok.

%%检测是否需要广播，如果需要，就在内部广播掉
checkNeedBroad( Object, NewState, ChangeStateFlag )->
	case ChangeStateFlag of
		?Player_State_Flag_PK_Kill->SendedAround=true;
		?Actor_State_Flag_Dead->SendedAround=true;
		?Actor_State_Flag_God->SendedAround=true;
		?Actor_State_Flag_Disable_Attack->SendedAround=true;
		?Actor_State_Flag_Disable_Move->SendedAround=true;
		?Actor_State_Flag_Disable_Hold->SendedAround=true;
		?Player_State_Flag_ChangingMap->SendedAround=true;
		?Player_State_Flag_PK_Kill_Value->SendedAround=true;
		_->SendedAround=false
	end,
	case SendedAround of
		true->
			mapView:broadcast( #pk_ActorStateFlagSet_Broad{nActorID=element( ?object_id_index, Object), 
															nSetStateFlag=NewState}, 
															Object, 0 );
		false->ok
	end.

%%某状态改变响应回调
onStateFlagChanged( ObjectID, ChangeStateFlag, AddOrRemove )->
	case AddOrRemove of
		true->
			case ChangeStateFlag of
				?Actor_State_Flag_Dead->
					IsStopMove = true;
				?Actor_State_Flag_Disable_Move->
					IsStopMove = true;
				?Actor_State_Flag_Disable_Hold->
					IsStopMove = true;
				_->IsStopMove = false
			end,
			case IsStopMove of
				true->
					ObjectData = map:getMapObjectByID( ObjectID ),
					case ObjectData of
						{}->ok;
						_->
							ObjType = map:getObjectID_TypeID( ObjectID ),
							case ObjType of
								?Object_Type_Player->
									case playerMove:isMoving(ObjectData) of
										true->
											playerMove:stopMove(ObjectData);
										false->
											ok
									end;
								?Object_Type_Npc->
									ok;
								?Object_Type_Monster->
									case monsterMove:isMoving(ObjectData) of
										true->
											monsterMove:stopMove(ObjectData);
										false->
											ok
									end;
								?Object_Type_Pet->
									case petMove:isMoving(ObjectData) of
										true->
											petMove:stopMove(ObjectData);
										false->
											ok
									end;
								_->ok
							end
					end;
				false->ok
			end;
		false->ok
	end.

	
%%返回某ID对象的stateRefArray
getStateResfArray(ObjectID) ->
	ObjectData = map:getMapObjectByID( ObjectID ),
	case ObjectData of
		{}->0;
		_->
			ObjType = map:getObjectID_TypeID( ObjectID ),
			case ObjType of
				?Object_Type_Player->
					ObjectData#mapPlayer.stateRefArray;
				?Object_Type_Npc->
					ObjectData#mapNpc.stateRefArray;
				?Object_Type_Monster->
					ObjectData#mapMonster.stateRefArray;
				?Object_Type_Pet->
					ObjectData#mapPet.stateRefArray;
				_->0
			end
	end.

%%返回某ID对象的某异常状态引用计数
getStateRes(ObjectID, StateIndex)->
	ObjectData = map:getMapObjectByID(ObjectID),
	case ObjectData of
		{}->0;
		_->
			ObjType = map:getObjectID_TypeID( ObjectID ),
			case ObjType of
				?Object_Type_Player->
					array:get(StateIndex, ObjectData#mapPlayer.stateRefArray);
				?Object_Type_Npc->
					array:get(StateIndex, ObjectData#mapNpc.stateRefArray);
				?Object_Type_Monster->
					array:get(StateIndex, ObjectData#mapMonster.stateRefArray);
				?Object_Type_Pet->
					array:get(StateIndex, ObjectData#mapPet.stateRefArray);
				_->0
			end
	end.

%%增加某对象异常状态引用计数
addStateRes(ObjectID, StateIndex) ->
	ObjectData = map:getMapObjectByID(ObjectID),
	case ObjectData of
		{}->0;
		_->
			ObjType = map:getObjectID_TypeID( ObjectID ),
			case ObjType of
				?Object_Type_Player->
					Value = array:get(StateIndex, ObjectData#mapPlayer.stateRefArray),
					Array = array:set(StateIndex, Value+1, ObjectData#mapPlayer.stateRefArray),
					etsBaseFunc:changeFiled(map:getMapPlayerTable(), ObjectID, #mapPlayer.stateRefArray, Array);
				?Object_Type_Npc->
					Value = array:get(StateIndex, ObjectData#mapNpc.stateRefArray),
					Array = array:set(StateIndex, Value+1, ObjectData#mapNpc.stateRefArray),
					etsBaseFunc:changeFiled(map:getMapNpcTable(), ObjectID, #mapNpc.stateRefArray, Array);
				?Object_Type_Monster->
					Value = array:get(StateIndex, ObjectData#mapMonster.stateRefArray),
					Array = array:set(StateIndex, Value+1, ObjectData#mapMonster.stateRefArray),
					etsBaseFunc:changeFiled(map:getMapMonsterTable(), ObjectID, #mapMonster.stateRefArray, Array);
				?Object_Type_Pet->
					Value = array:get(StateIndex, ObjectData#mapPet.stateRefArray),
					Array = array:set(StateIndex, Value+1, ObjectData#mapPet.stateRefArray),
					etsBaseFunc:changeFiled(map:getMapPetTable(), ObjectID, #mapPet.stateRefArray, Array);
				_->Value=-1
			end,
			
			%%第一次增加引用计数，给object添加状态
			case Value =:= 0 of
				true->
					case StateIndex of
						?Buff_Effect_Type_Stun->  %%昏迷
							mapActorStateFlag:addStateFlag(ObjectID, ?Actor_State_Flag_Disable_Hold);
						?Buff_Effect_Type_Forbid->  %%沉默
							mapActorStateFlag:addStateFlag(ObjectID, ?Actor_State_Flag_Disable_Attack);
						?Buff_Effect_Type_Fasten->   %%定身
							mapActorStateFlag:addStateFlag(ObjectID, ?Actor_State_Flag_Disable_Move);
						?Buff_Effect_Type_Immortal->   %%无敌
							mapActorStateFlag:addStateFlag(ObjectID, ?Actor_State_Flag_God);
						_->ok
					end;
				false->ok
			end
	end.

%%减少某对象异常状态引用计数
reduceStateRes(ObjectID, StateIndex) ->
	ObjectData = map:getMapObjectByID(ObjectID),
	case ObjectData of
		{}->0;
		_->
			ObjType = map:getObjectID_TypeID( ObjectID ),
			case ObjType of
				?Object_Type_Player->
					Value = array:get(StateIndex, ObjectData#mapPlayer.stateRefArray),
					case Value > 0 of
						true ->
							Array = array:set(StateIndex, Value-1, ObjectData#mapPlayer.stateRefArray),
							etsBaseFunc:changeFiled(map:getMapPlayerTable(), ObjectID, #mapPlayer.stateRefArray, Array);
						false ->
							ok
					end;
				?Object_Type_Npc->
					Value = array:get(StateIndex, ObjectData#mapNpc.stateRefArray),
					case Value > 0 of
						true->
							Array = array:set(StateIndex, Value-1, ObjectData#mapNpc.stateRefArray),
							etsBaseFunc:changeFiled(map:getMapNpcTable(), ObjectID, #mapNpc.stateRefArray, Array);
						false->
							ok
					end;
				?Object_Type_Monster->
					Value = array:get(StateIndex, ObjectData#mapMonster.stateRefArray),
					case Value > 0 of
						true->
							Array = array:set(StateIndex, Value-1, ObjectData#mapMonster.stateRefArray),
							etsBaseFunc:changeFiled(map:getMapMonsterTable(), ObjectID, #mapMonster.stateRefArray, Array);
						false->
							ok
					end;
				?Object_Type_Pet->
					Value = array:get(StateIndex, ObjectData#mapPet.stateRefArray),
					case Value > 0 of
						true->
							Array = array:set(StateIndex, Value-1, ObjectData#mapPet.stateRefArray),
							etsBaseFunc:changeFiled(map:getMapPetTable(), ObjectID, #mapPet.stateRefArray, Array);
						false->
							ok
					end;
				_->Value=-1
			end,
			
			%%引用计数归零，给object删除状态
			case Value =:= 1 of
				true->
					case StateIndex of
						?Buff_Effect_Type_Stun->  %%昏迷
							mapActorStateFlag:removeStateFlag(ObjectID, ?Actor_State_Flag_Disable_Hold);
						?Buff_Effect_Type_Forbid->  %%沉默
							mapActorStateFlag:removeStateFlag(ObjectID, ?Actor_State_Flag_Disable_Attack);
						?Buff_Effect_Type_Fasten->   %%定身
							mapActorStateFlag:removeStateFlag(ObjectID, ?Actor_State_Flag_Disable_Move);
						?Buff_Effect_Type_Immortal->   %%无敌
							mapActorStateFlag:removeStateFlag(ObjectID, ?Actor_State_Flag_God);
						_->ok
					end;
				false->ok
			end
	end.




