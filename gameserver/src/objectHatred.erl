%% Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(objectHatred).

-include("db.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("monsterDefine.hrl").
%%
%% Exported Functions
%%
-compile(export_all). 

%%返回某物件的仇恨记录
getObjectHatred( ID )->
	etsBaseFunc:readRecord( map:getObjectHatredTable(), ID ).




%%锁定仇恨 在MyID对应的对象的仇恨列表里锁定OtherID -> true or false  add by wenziyong
lockObjectHatred( MyID, OtherID )->
	try
		HatredRecord = getObjectHatred( MyID ),
		case HatredRecord of
			{}->throw(-1);
			_->ok
		end,
		
		case HatredRecord#objectHatred.lockTarget =/= OtherID of
			true->etsBaseFunc:changeFiled( map:getObjectHatredTable(), MyID, #objectHatred.lockTarget, OtherID );
			false->ok
		end,
		true
	catch
		_->false
	end.

%%解除对某对象的仇恨锁定  add by wenziyong
unlockObjectHatred( MyID, OtherID )->
	try
		HatredRecord = getObjectHatred( MyID ),
		case HatredRecord of
			{}->throw(-1);
			_->ok
		end,
		
		case HatredRecord#objectHatred.lockTarget =:= OtherID of
			true->etsBaseFunc:changeFiled( map:getObjectHatredTable(), MyID, #objectHatred.lockTarget, 0 );
			false->ok
		end,
		ok
	catch
		_->ok
	end.

%%获得仇恨锁定的目标记录
getLockHatredObject(ID) ->
	try
		HatredRecord = getObjectHatred( ID ),
		case HatredRecord of
			{}->throw( {} );
			_->ok
		end,
		
		case HatredRecord#objectHatred.lockTarget of
			0->throw( {} );
			LockID->
				case map:getMapObjectByID( LockID ) of
					{}->
						etsBaseFunc:changeFiled( map:getObjectHatredTable(), ID, #objectHatred.lockTarget, 0 ),
						throw( {} );
					Target->throw(Target)
				end
		end
	
	catch
		Return->Return
end.

%%返回某物件的最大仇恨目标记录
getObjectMaxHatredTarget( ID )->
	put( "getObjectMaxHatredTarget_return", {} ),
	put( "getObjectMaxHatredTarget_max", 0 ),
	try
		HatredRecord = getObjectHatred( ID ),
		case HatredRecord of
			{}->throw(-1);
			_->ok
		end,
		
		case HatredRecord#objectHatred.lockTarget /= 0 of
			true->
				Target = map:getMapObjectByID( HatredRecord#objectHatred.lockTarget ),
				case Target of
					{}->ok;
					_->put( "getObjectMaxHatredTarget_return", Target ),throw(-1)
				end;
			false->ok
		end,
		
		MyFunc = fun( Record )->
						 case Record#hatred.value >= get( "getObjectMaxHatredTarget_max" ) of
							 true->
								 Target2 = map:getMapObjectByID( Record#hatred.targetID ),
								 case Target2 of
									 {}->ok;
									 _->
										 put( "getObjectMaxHatredTarget_return", Target2 ),
										 put( "getObjectMaxHatredTarget_max", Record#hatred.value )
								 end;
							 false->ok
						 end
				 end,
		lists:foreach( MyFunc, HatredRecord#objectHatred.hatredList ),
		get( "getObjectMaxHatredTarget_return" )
	catch
		_->get( "getObjectMaxHatredTarget_return" )
	end.

%%返回某物件的仇恨列表中随机获取player
getRandomHatredPlayer(ID) ->
	try
		HatredRecord = getObjectHatred( ID ),
		case HatredRecord of
			{}->throw(-1);
			_->ok
		end,
		
		FunPlayer = fun(Record) ->
							case map:getObjectID_TypeID(Record#hatred.targetID) of
								?Object_Type_Player->
									true;
								_->false
							end
					end,
		PlayerList = lists:filter(FunPlayer, HatredRecord#objectHatred.hatredList),
		Len = length(PlayerList),
		case Len < 1 of
			true->throw({});
			false->ok
		end,
		
		SelectIndex = random:uniform(Len),
		Record2 = lists:nth(SelectIndex,PlayerList),
		map:getMapObjectByID( Record2#hatred.targetID )
	catch
		Return->Return
end.

%%返回某物件的仇恨列表中随机获取target -> target or {}  add by wenziyong
getRandomHatredTarget( ID )->
	put( "getRandomHatredTargetID_return",  {}  ),
	try
		HatredRecord = getObjectHatred( ID ),
		case HatredRecord of
			{}->throw(-1);
			_->ok
		end,

		Len = length(HatredRecord#objectHatred.hatredList),
		case Len < 1 of
			true->throw(-1);
			false->ok
		end,
		
		SelectIndex = random:uniform(Len),
		Record = lists:nth(SelectIndex,HatredRecord#objectHatred.hatredList),
		map:getMapObjectByID( Record#hatred.targetID )
	catch
		_->get( "getRandomHatredTargetID_return" )
	end.

%%返回某物件的所有仇恨目标记录  -> [] or [targes]   add by wenziyong
getObjectAllHatredTargets( ID )->
	put( "getObjectAllHatredTargets_Return", [] ),
	try
		HatredRecord = getObjectHatred( ID ),
		case HatredRecord of
			{}->throw(-1);
			_->ok
		end,
		
		MyFunc = fun( Record )->
						 Target = map:getMapObjectByID( Record#hatred.targetID ),
						 case Target of
							 {}->ok;
							 _->
								 OldTargets = get( "getObjectAllHatredTargets_Return"),
								 NewTargets = [Target | OldTargets],
								 put( "getObjectAllHatredTargets_Return", NewTargets )

						 end
				 end,
		lists:foreach( MyFunc, HatredRecord#objectHatred.hatredList ),
		get( "getObjectAllHatredTargets_Return" )
	catch
		_->get( "getObjectAllHatredTargets_Return" )
	end.

%% -> true(有仇恨对象) or false 
existHatredTarget( ID )->
	case getObjectHatred( ID ) of
		{}->false;
		HatredRecord->
			case HatredRecord#objectHatred.hatredList of
				[]->false;
				_->true
			end
	end.	

%%返回某物件的最小仇恨目标记录
getObjectMinHatredTarget( ID )->
	put( "getObjectMinHatredTarget_return", {} ),
	put( "getObjectMinHatredTarget_min", -1 ),
	try
		HatredRecord = getObjectHatred( ID ),
		case HatredRecord of
			{}->throw(-1);
			_->ok
		end,
		
		MyFunc = fun( Record )->
						 case ( get( "getObjectMinHatredTarget_min" ) =:= -1 ) or ( Record#hatred.value < get( "ggetObjectMinHatredTarget_min" ) ) of
							 true->
								 Target2 = map:getMapObjectByID( Record#hatred.targetID ),
								 case Target2 of
									 {}->ok;
									 _->
										 put( "getObjectMinHatredTarget_return", Target2 ),
										 put( "getObjectMinHatredTarget_min", Record#hatred.value )
								 end;
							 false->ok
						 end
				 end,
		lists:foreach( MyFunc, HatredRecord#objectHatred.hatredList ),
		get( "getObjectMinHatredTarget_return" )
	catch
		_->get( "getObjectMinHatredTarget_return" )
	end.

%%返回是否在仇恨列表里
isInHatred( MyID, OtherID )->
	put( "isInHatred_return", false ),
	try
		HatredRecord = getObjectHatred( MyID ),
		case HatredRecord of
			{}->throw(-1);
			_->ok
		end,
		
		MyFunc = fun( Record )->
						 case Record#hatred.targetID =:= OtherID of
							true->put( "isInHatred_return", true ),throw(-1);
							false->ok
						 end
				 end,
		lists:foreach( MyFunc, HatredRecord#objectHatred.hatredList ),
		get( "isInHatred_return" )
	catch
		_->get( "isInHatred_return" )
	end.

%%向某物件仇恨列表里增加仇恨
addHatredIntoObject( MyID, OtherID, Value )->
	put( "addHatredIntoObject_find", false ),
	try
		case MyID =:= OtherID of
			true->throw(-1);
			false->ok
		end,
		
		case map:getMapObjectByID(MyID) of
			{}->throw(-1);
			_->ok
		end,
		case map:getMapObjectByID(OtherID) of
			{}->throw(-1);
			_->ok
		end,

		MyState = mapActorStateFlag:getStateFlag( MyID ),
		NotAddState = ( ?Actor_State_Flag_Dead ) bor
						  ( ?Monster_State_Flag_GoBacking ) bor
						  ( ?Actor_State_Flag_God ) bor
						  ( ?Player_State_Flag_ChangingMap ),
		case ( MyState band NotAddState ) /= 0 of
			true->
				%%?LOG_OUT( "addHatredIntoObject state false MyID[~p], OtherID[~p], Value[~p]", [MyID, OtherID, Value] ),
				throw(-1);
			false->ok
		end,
		
		HatredRecord1 = getObjectHatred( MyID ),
		case HatredRecord1 of
			{}->
				%%没有，新建
				HatredRecord = #objectHatred{ id=MyID, lockTarget=0, hatredList=[] },
				etsBaseFunc:insertRecord( map:getObjectHatredTable(), HatredRecord ),
				ok;
			_->HatredRecord = HatredRecord1
		end,
		
		MyFunc = fun( Record )->
						 case Record#hatred.targetID =:= OtherID of
							true->
								put( "addHatredIntoObject_find", true ),
								NewValue = Record#hatred.value+Value,
								put( "addHatredIntoObject_NewValue", NewValue ),
								case NewValue < 0 of
									true->NewValue1 = 0;
									false->NewValue1 = NewValue
								end,

								NewRecord =  setelement( #hatred.value, Record, NewValue1 ),
								NewRecord2 = setelement( #hatred.lastTime, NewRecord, erlang:now() ),
								NewRecord2;
							false->Record
						 end
				 end,
		NewHatredList = lists:map( MyFunc, HatredRecord#objectHatred.hatredList ),

		case get( "addHatredIntoObject_find" ) of
			true->
				NeedUpdate = false, 
				%%忘了改变
				etsBaseFunc:changeFiled( map:getObjectHatredTable(), MyID, #objectHatred.hatredList, NewHatredList ),
				ok;%%已经找到添加了
			false->%%没有找到，新增
				Len = length( HatredRecord#objectHatred.hatredList ),
				case Len >= ?Max_Hatred_Count of
					true->
						NeedUpdate = true,
						
						%%满了，删掉仇恨值最小的
						MinTarget = getObjectMinHatredTarget( MyID ),
						case MinTarget of
							{}->ok;
							_->removeObjectHatred( MyID, element( ?object_id_index, MinTarget ) )
						end;
					false->NeedUpdate = false, ok
				end,
				NewHatred = #hatred{ targetID=OtherID, value=Value, lastTime=erlang:now() },
				case HatredRecord#objectHatred.hatredList of
					[]->%%原先是空的
						etsBaseFunc:changeFiled( map:getObjectHatredTable(), MyID, #objectHatred.hatredList, [NewHatred] );
					_->%%++
						etsBaseFunc:changeFiled( map:getObjectHatredTable(), MyID, #objectHatred.hatredList, HatredRecord#objectHatred.hatredList ++ [NewHatred] )
				end,
				%%事件响应，有新仇恨对象进入
				onAddHatred( MyID, OtherID, Value ),
				%%事件响应，我(OtherID)进入了别人(MyID)的仇恨列表
				onMeInsertToAnotherHatredList( OtherID, MyID, Value )
		end,
		
		case NeedUpdate of
			true->
				temp_UpdateHatredList( MyID );
			false->ok
		end,
		
		case map:getObjectID_TypeID( MyID ) of
			?Object_Type_Monster->
				%%Monster的首仇恨目标即该Monster的归属
				Object = map:getMapObjectByID( MyID ),
				case Object of
					{}->ok;
					_->
						case Object#mapMonster.firstHatredObjectID =:= 0 of
							true->
								%%这里没有考虑目标是玩家有队的情况
								%%?
								etsBaseFunc:changeFiled( map:getMapMonsterTable(), MyID, #mapMonster.firstHatredObjectID, OtherID ),
								FirstPos = #posInfo{ x=Object#mapMonster.pos#posInfo.x, y=Object#mapMonster.pos#posInfo.y },
								etsBaseFunc:changeFiled( map:getMapMonsterTable(), MyID, #mapMonster.firstHatredObjectPos, FirstPos ),
								ok;
							false->ok
						end
				end,

				ok;
			_->ok
		end,

		ok
	catch
		_->ok
	end.

%%临时解决方案，有可能有仇恨对象消失的时候，没有从别的仇恨列表中删除
temp_UpdateHatredList( MyID )->
	HatredRecord = getObjectHatred( MyID ),
	case HatredRecord of
		{}->ok;
		_->
			put( "temp_UpdateHatredList_TargetIDList", [] ),
			MyFunc = fun( Record )->
							 Target = map:getMapObjectByID( Record#hatred.targetID ),
							 case Target of
								 {}->put( "temp_UpdateHatredList_TargetIDList", get( "temp_UpdateHatredList_TargetIDList" ) ++ [Record#hatred.targetID] );
								 _->ok
							 end
					 end,
			lists:foreach( MyFunc, HatredRecord#objectHatred.hatredList ),
			MyFunc2 = fun( Record )->
							  removeObjectHatred( MyID, Record )
					  end,
			lists:foreach( MyFunc2, get( "temp_UpdateHatredList_TargetIDList" ) )
	end.

%%事件响应，有新仇恨对象进入
onAddHatred( MyID, OtherID, _Value )->
	try
		Object = map:getMapObjectByID(MyID),
		objectEvent:onEvent( Object, ?Char_Event_Add_Hatred_Object, OtherID ),
		IsOldFighting = mapActorStateFlag:isStateFlag( MyID, ?Actor_State_Flag_Fighting ),
		case IsOldFighting of
			true->%%已经进入了战斗状态
				ok;
			false->%%进入战斗状态
				%%事件触发，进入战斗状态
				enterFightingState( MyID )
		end,
		case element( 1, Object ) of
			mapPlayer->
				ToUserMsg = #pk_GS2U_AddOrRemoveHatred{ nActorID=OtherID, nAddOrRemove=1 },
				player:sendToPlayer(MyID, ToUserMsg),
				ok;
			_->ok
		end,

		ok
	catch
		_->ok
	end.

%%事件响应，我(MyID)进入了别人(OtherID)的仇恨列表
onMeInsertToAnotherHatredList( MyID, OtherID, _Value )->
	try
		case isInHatred( MyID, OtherID ) of
			true->%%已经在我的仇恨列表里
				throw(-1);
			false->ok
		end,

		%%不在我的仇恨列表里，进
		addHatredIntoObject( MyID, OtherID, 0 ),
		
		ok
	catch
		_->ok
	end.


%%删除仇恨
removeObjectHatred( MyID, OtherID )->
	put( "removeObjectHatred_find", {} ),
	try
		HatredRecord = getObjectHatred( MyID ),
		case HatredRecord of
			{}->throw(-1);
			_->ok
		end,
		
		MyFunc = fun( Record )->
						 case Record#hatred.targetID =:= OtherID of
							true->put( "removeObjectHatred_find", Record ),Record;
							false->Record
						 end
				 end,
		lists:foreach( MyFunc, HatredRecord#objectHatred.hatredList ),
		
		case get( "removeObjectHatred_find" ) of
			{}->throw(-1);
			_->
				NewList = HatredRecord#objectHatred.hatredList -- [get( "removeObjectHatred_find" )],
				etsBaseFunc:changeFiled( map:getObjectHatredTable(), MyID, #objectHatred.hatredList, NewList ),
				
				case HatredRecord#objectHatred.lockTarget =:= OtherID of
					true->etsBaseFunc:changeFiled( map:getObjectHatredTable(), MyID, #objectHatred.lockTarget, 0 );
					false->ok
				end,

				%%事件响应，有仇恨对象从我的列表中删除
				onRemoveHatred( MyID, OtherID ),
				%%事件响应，我从别人的仇恨列表中删除了
				onMeLeaveAnotherHatredList( OtherID, MyID )
		end,

		ok
	catch
		_->ok
	end.

%%事件响应，有仇恨对象从我的列表中删除
onRemoveHatred( MyID, OtherID )->
	try
		Object = map:getMapObjectByID(MyID),
		objectEvent:onEvent( Object, ?Char_Event_Remove_Hatred_Object, 0),
		%%buff响应，仇恨移除的时候，buff中，由OtherID施加的buff，也应该移除
		%%onRemoveHatredForBuff( MyID, OtherID )

		%%如果仇恨列表空了，要离开战斗状态
		HatredRecord = getObjectHatred( MyID ),
		case HatredRecord of
			{}->throw(-1);
			_->ok
		end,
		case HatredRecord#objectHatred.hatredList of
			[]->
				%%事件触发，离开战斗状态
				leaveFightingState( MyID );
			_->ok
		end,

		case element( 1, Object ) of
			mapPlayer->
				ToUserMsg = #pk_GS2U_AddOrRemoveHatred{ nActorID=OtherID, nAddOrRemove=0 },
				player:sendToPlayer(MyID, ToUserMsg),
				ok;
			_->ok
		end,
		ok
	catch
		_->ok
	end.

%%事件响应，我从别人的仇恨列表中删除了
onMeLeaveAnotherHatredList( MyID, OtherID )->
	removeObjectHatred( MyID, OtherID ).


%%事件触发，进入战斗状态
enterFightingState( MyID )->
	try
		mapActorStateFlag:addStateFlag( MyID, ?Actor_State_Flag_Fighting ),
		
		%%事件响应，进入战斗状态
		onEnterFightingState( MyID ),
		
		ObjType = map:getObjectID_TypeID( MyID ),
		objectEvent:onEvent( map:getMapObjectByID(MyID), ?Char_Event_EnterFightState, 0),
		case ObjType of
			?Object_Type_Monster->
				Monster = map:getMapObjectByID(MyID),
				case Monster of
					{}->ok;
					_->monster:changeAIState( Monster, ?Monster_AI_State_Fighting )
				end,
				ok;
			_->ok
		end,
		
		ok
	catch
		_->ok
	end.

%%事件触发，离开战斗状态
leaveFightingState( MyID )->
	try
		mapActorStateFlag:removeStateFlag( MyID, ?Actor_State_Flag_Fighting ),
		objectEvent:onEvent( map:getMapObjectByID(MyID), ?Char_Event_LeaveFightState, 0),
		buff:clearAllDebuff(MyID),  %%脱离战斗，清除所有debuff
		%%事件响应，离开战斗状态
		onLeaveFightingState( MyID ),
		
		ObjType = map:getObjectID_TypeID( MyID ),
		case ObjType of
			?Object_Type_Monster->
				Monster = map:getMapObjectByID(MyID),
				case Monster of
					{}->ok;
					_->monster:goBackToBeginTargetPos( Monster )
				end,
				ok;
			_->ok
		end,

		ok
	catch
		_->ok
	end.	

%%事件响应，进入战斗状态
onEnterFightingState( _MyID )->
	try
		ok
	catch
		_->ok
	end.

%%事件响应，离开战斗状态
onLeaveFightingState( _MyID )->
	try
		ok
	catch
		_->ok
	end.


%%清除仇恨
clearHatred( ObjectID )->
	ObjectHatred = etsBaseFunc:readRecord( map:getObjectHatredTable(), ObjectID ),
	case ObjectHatred of
		{}->ok;
		_->
			MyFunc = fun( Record )->
							 removeObjectHatred( ObjectID, Record#hatred.targetID )
					 end,
			lists:foreach( MyFunc, ObjectHatred#objectHatred.hatredList )
	end.


