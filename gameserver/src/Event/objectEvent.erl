%% Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(objectEvent).

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

%%返回TimerID，由24位地图ID+40数据库ID构成
makeTimerID( MapID )->
	ID = ( MapID bsl 40 ) bor db:memKeyIndex(objectTimer), % not persistent
	ID.

%%返回EventID，由24位地图ID+40数据库ID构成
makeEventID( MapID )->
	ID = ( MapID bsl 40 ) bor db:memKeyIndex(objectEventManager), % not persistent
	ID.

%%地图初始化，创建EventManager
onMapInitCreateEventManger()->
	EventMangerTable = ets:new( 'EventMangerTable', [protected, { keypos, #objectEventManager.event_id }] ),
	put( "EventMangerTable", EventMangerTable ).

%%返回事件对象，失败返回{}
getObjectEvent( EventID )->
	EventMangerTable = get( "EventMangerTable" ),
	case EventMangerTable of
		undefined->{};
		_->etsBaseFunc:readRecord( EventMangerTable, EventID )
	end.

%%返回物件对象的事件数组，注意：可能该物件对象没有事件数据，会返回undefined
getObjectEventArray( Object )->
	case element( 1, Object ) of
		mapObject->Object#mapObject.event_array;
		mapPlayer->Object#mapPlayer.event_array;
		mapPet->Object#mapPet.event_array;
		mapNpc->Object#mapNpc.event_array;
		mapMonster->Object#mapMonster.event_array;
		mapObjectActor->Object#mapObjectActor.event_array;
		_->undefined
	end.

%%返回某脚本对象类型的事件数量
getObjectEventCountByType( Type )->
	case Type of
		?Object_Type_Player->?Player_Event_Count;
		?Object_Type_Npc->?Npc_Event_Count;
		?Object_Type_Monster->?Monster_Event_Count;
		?Object_Type_Object->?Object_Event_Count;
		?Object_Type_Map->?Map_Event_Count;
		_->
			?ERROR_OUT("getScriptObjectTypeCount unkown type[~p]", [Type]),
			0
	end.
	

%%响应物件对象销毁时，销毁事件对象
onObjectDestroy( Object )->
	MyFunc = fun( Index, Parama )->
					 List = array:get( Index, Parama ),
					 
					 case List of
						 []->ok;
						 _->
							 MyFunc2 = fun( Record )->
											   etsBaseFunc:deleteRecord( get( "EventMangerTable" ), Record#objectEvent.event_id )
									   end,
							 lists:foreach( MyFunc2, List )
					 end
			 end,
	ObjectEventArray = getObjectEventArray( Object ),
	case ObjectEventArray of
		undefined->ok;
		_->
			common:for_parama( 0, array:size( ObjectEventArray ) - 1, MyFunc, ObjectEventArray )
	end.

%%注册物件的事件对象
registerObjectEvent( Object_In, Event, DataType, DataID, CallModule, CallBackFunc, Parama )->
	try
		ObjectID = element( ?object_id_index, Object_In ),
		Object = map:getMapObjectByID( ObjectID ),
		case Object of
			{}->throw(-1);
			_->ok
		end,
		
		EventCount = getObjectEventCountByType( element( ?object_type_index, Object ) ),
		case ( Event < 0 ) or ( Event >= EventCount ) of
			true->throw(-1);
			false->ok
		end,
	
		NewObjectEvent = #objectEvent{
									  event_id=makeEventID( map:getMapID() ), 
									  data_type = DataType,
									  data_id = DataID,
									  master_id = ObjectID,
									  call_module = CallModule,
									  call_func = CallBackFunc,
									  parama = Parama
									  },
		EventArray = element( ?object_event_index, Object ),										
		case EventArray of
			undefined->EventArray2 = array:new( EventCount, {default, []});
			_->EventArray2 = EventArray
		end,
				
		EventList = array:get( Event, EventArray2 ),
		case EventList of
			[]->EventList2 = [NewObjectEvent];
			_->
				MyFunc = fun( Record )->
								 case ( Record#objectEvent.call_module =:= CallModule ) andalso
										  ( Record#objectEvent.call_func =:= CallBackFunc ) of
									 true->throw(-1);%%已经存在相同的回调
									 false->ok
								 end
						 end,
				lists:foreach( MyFunc, EventList ),
				
				EventList2 = [NewObjectEvent] ++ EventList
		end,
		
		EventArray3 = array:set( Event, EventList2, EventArray2 ),

		etsBaseFunc:changeFiled( element( ?object_table_index, Object ), ObjectID, ?object_event_index, EventArray3 ),
		
		etsBaseFunc:insertRecord( get( "EventMangerTable" ), NewObjectEvent ),
		
		ok
	catch
		_->ok
	end.

%%注销物件的事件
removeObjectEvent( Object_In, EventID )->
	try
		Object = map:getMapObjectByID( map:getObjectID(Object_In) ),
		case Object of
			{}->throw(-1);
			_->ok
		end,
		EventArray = element( ?object_event_index, Object ),
		case EventArray of
			undefined->throw(-1);
			_->ok
		end,
		
		ObjectEvent = getObjectEvent( EventID ),
		case ObjectEvent of
			{}->throw(-1);
			_->
				etsBaseFunc:deleteRecord( get( "EventMangerTable" ), EventID )
		end,
		
		Event = ObjectEvent#objectEvent.event,
		case (Event < 0) or (Event >= array:size(EventArray) ) of
			true->throw(-1);
			false->ok
		end,

		EventList = array:get( Event, EventArray ),
		case EventList of
			[]->throw(-1);
			_->
				NewEventList = EventList -- [ObjectEvent],
				NewArray = array:set( Event, NewEventList, EventArray ),
				etsBaseFunc:changeFiled( element( ?object_table_index, Object ), element( ?object_id_index, Object ), ?object_event_index, NewArray )
		end,

		ok
	catch
		_->ok
	end.

%%注销物件的事件
removeObjectEvent( Object_In, Event, DataType, DataID, CallBackFunc )->
	try
		Object = map:getMapObjectByID( map:getObjectID(Object_In) ),
		case Object of
			{}->throw(-1);
			_->ok
		end,

		EventArray = element( ?object_event_index, Object ),
		case EventArray of
			undefined->throw(-1);
			_->ok
		end,
		
		case (Event < 0) or (Event >= array:size(EventArray) ) of
			true->throw(-1);
			false->ok
		end,

		ObjectID = element( ?object_id_index, Object ),
		
		EventList = array:get( Event, EventArray ),
		case EventList of
			[]->throw(-1);
			_->
				MyFunc2 = fun( List )->
								try
									MyFunc = fun( Record )->
													 case ( Record#objectEvent.master_id =:= ObjectID ) andalso 
														  ( Record#objectEvent.data_type =:= DataType ) andalso
														  ( Record#objectEvent.data_id =:= DataID ) andalso
														  ( Record#objectEvent.call_func =:= CallBackFunc ) of
														 true->
															 throw(Record);
														 false->ok
													 end
											 end,
									lists:foreach( MyFunc, List ),
									{}
								catch
									FindRecord->FindRecord
								end
						  end,
				FindRecord = MyFunc2( EventList ),

				case FindRecord of
					{}->throw(-1);
					_->
						NewEventList = EventList -- [FindRecord],
						NewArray = array:set( Event, NewEventList, EventArray ),
						etsBaseFunc:changeFiled( element( ?object_table_index, Object ), element( ?object_id_index, Object ), ?object_event_index, NewArray ),
						etsBaseFunc:deleteRecord( get( "EventMangerTable" ), FindRecord#objectEvent.event_id )
				end
		end,

		ok
	catch
		_->ok
	end.

%%响应物件事件
onEvent( Object_In, Event, EventParam )->
	try
		Object = map:getMapObjectByID( map:getObjectID(Object_In) ),
		case Object of
			{}->throw(-1);
			_->ok
		end,

		EventArray = element( ?object_event_index, Object ),
		case EventArray of
			undefined->throw(-1);
			_->ok
		end,
		
		case (Event < 0) or (Event >= array:size(EventArray) ) of
			true->throw(-1);
			false->ok
		end,

		ObjectID = element( ?object_id_index, Object ),
		
		EventList = array:get( Event, EventArray ),
		case EventList of
			[]->throw(-1);
			_->
				EventCount = length( EventList ),
				case EventCount > 1 of
					true->Check=true;
					false->Check=false
				end,
				
				MyFunc = fun( Record )->
								 Ret = callEvent( Object, Event, EventParam, Record ),
								 case Ret of
									 { eventCallBackReturn, _ }->put( "onEvent_return", Ret );
									 _->ok
								 end,

								 case Check of
									 true->
										 case etsBaseFunc:readRecord( element( ?object_table_index, Object ), ObjectID ) of
											 {}->throw(-1);
											 _->ok
										 end;
									 false->ok
								 end
						 end,
				lists:foreach( MyFunc, EventList ),
				get( "onEvent_return" )
		end
	catch
		_->ok
	end.

%%单独调用一个EventCallBack-record( objectEvent, {event_id, event, data_type, data_id, master_id, call_module, call_func, parama} ).
callEvent( Object, Event, EventParam, ObjectEvent )->
	try
		Module = ObjectEvent#objectEvent.call_module,
		CallBackFunc = ObjectEvent#objectEvent.call_func,
		Module:CallBackFunc( Object, EventParam, ObjectEvent#objectEvent.parama )
	catch
		_:_->
		  ?ERROR_OUT( "callEvent Object[~p] Event[~p] EventParam[~p], ObjectEvent[~p], [~p]",
				[Object, Event, EventParam, ObjectEvent, erlang:get_stacktrace()]),
		  { error, 0 }
	end.

%%注册一个计时器事件，TimeDist=多少毫秒后触发，IsLoop=true，表示自动循环，=false，表示不自动循环
%%成功，返回计时器的ID，失败返回0
registerTimerEvent( Object, TimeDist, IsLoop, CallModule, CallBackFunc, Parama )->
	try
		ObjectID = element( ?object_id_index, Object ),
		
		NewTimer = #objectTimer{
									  timer_id=makeTimerID( map:getMapID() ), 
									  timeDist = TimeDist,
									  isLoop = IsLoop,
									  master_id = ObjectID,
									  call_module = CallModule,
									  call_func = CallBackFunc,
									  parama = Parama
									  },
		
		TimerList = element( ?object_timer_index, Object ),
		case TimerList of
			undefined->TimerList2 = [NewTimer];
			_->
				MyFunc = fun( Record )->
								 case ( Record#objectTimer.call_module =:= CallModule ) andalso
										  ( Record#objectTimer.call_func =:= CallBackFunc ) of
									 true->throw(-1);%%已经存在相同的回调
									 false->ok
								 end
						 end,
				lists:foreach( MyFunc, TimerList ),
				
				TimerList2 = [NewTimer] ++ TimerList
		end,
		
		etsBaseFunc:changeFiled( element( ?object_table_index, Object ), ObjectID, ?object_timer_index, TimerList2 ),
		erlang:send_after( TimeDist,self(), { objectTimer, NewTimer } ),
		
		NewTimer#objectTimer.timer_id
	catch
		_->0
	end.

%%移除一个对象的计时器
removeObjectTimer( Object, CallModule, CallBackFunc )->
	try
		%% add by wenziyong, 由于在timer的回调函数中可能把此对象删除，所以Object可能已不存在了
		case Object =:= {} of
			true -> throw(-1);
			false->ok
		end,

		TimerList = element( ?object_timer_index, Object ),
		case TimerList of
			undefined->ok;
			_->
				put( "removeObjectTimer_find", {} ),
				MyFunc = fun( Record )->
								 case ( Record#objectTimer.call_module =:= CallModule ) andalso
										  ( Record#objectTimer.call_func =:= CallBackFunc ) of
									 true->put( "removeObjectTimer_find", Record );
									 false->ok
								 end
						 end,
				lists:foreach( MyFunc, TimerList ),
				
				case get( "removeObjectTimer_find" ) of
					{}->ok;
					Find->
						NewList = TimerList -- [Find],
						ObjectID = element( ?object_id_index, Object ),
						case NewList of
							[]->etsBaseFunc:changeFiled( element( ?object_table_index, Object ), ObjectID, ?object_timer_index, undefined );
							_->etsBaseFunc:changeFiled( element( ?object_table_index, Object ), ObjectID, ?object_timer_index, NewList )
						end
				end
		end,
		ok
	catch
		_->ok
	end.

%%地图进程响应物件计时器
on_objectTimer( ObjectTimer )->
	try
		Object = map:getMapObjectByID(ObjectTimer#objectTimer.master_id),
		case Object of
			{}->ok;
			_->
				TimerList = element( ?object_timer_index, Object ),
				case TimerList of
					undefined->throw(-1);
					_->ok
				end,
				MyFunc = fun( Record )->
								 case ( Record#objectTimer.call_module =:= ObjectTimer#objectTimer.call_module ) andalso
										  ( Record#objectTimer.call_func =:= ObjectTimer#objectTimer.call_func ) of
									 true->
										 put( "on_objectTimer_param", Record#objectTimer.parama ),
										 CallRecord = setelement( #objectTimer.parama, Record, ObjectTimer#objectTimer.parama ),
										 ReturnValue = callTimer( Object, CallRecord ),
										 case ReturnValue of
											 stopTimer->
												 Object2 = map:getMapObjectByID(ObjectTimer#objectTimer.master_id),
												 removeObjectTimer( Object2, ObjectTimer#objectTimer.call_module, ObjectTimer#objectTimer.call_func );
											 _->
												 case ObjectTimer#objectTimer.isLoop of
													 true->
														 New_Record = setelement( #objectTimer.parama, Record, get("on_objectTimer_param") ),
														 erlang:send_after( Record#objectTimer.timeDist,self(), { objectTimer, New_Record } ); 
													 false->
														 Object2 = map:getMapObjectByID(ObjectTimer#objectTimer.master_id),
														 removeObjectTimer( Object2, ObjectTimer#objectTimer.call_module, ObjectTimer#objectTimer.call_func )
												 end
										 end,
										 ok;
									 false->ok
								 end
						 end,
				lists:foreach( MyFunc, TimerList )
		end
	catch
		_->ok
	end.

%%单独调用一个objectTimer-record( objectTimer, { timer_id, timeDist, isLoop, master_id, call_module, call_func, parama } ).
callTimer( Object, ObjectTimer )->
	try
		Module = ObjectTimer#objectTimer.call_module,
		CallBackFunc = ObjectTimer#objectTimer.call_func,
		Module:CallBackFunc( Object, ObjectTimer )
	catch
		_:_Why->
		  ?ERROR_OUT( "callTimer Object[~p] ObjectTimer[~p], _Why[~p] stack[~p]",
				[Object, ObjectTimer, _Why, erlang:get_stacktrace()]),
		  { error, 0 }
	end.





