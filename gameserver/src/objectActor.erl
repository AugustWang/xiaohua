%% Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(objectActor).

-include("db.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 

%%加载地图配置表中的object
loadMapObject()->
	try
		MapCfg = map:getMapCfg(),
		MyFunc = fun( Record )->
						 case Record#mapSpawn.type of
							 ?Object_Type_TRANSPORT->
								 Create = true;
							 ?Object_Type_COLLECT->
								 Create = true;
							 _->Create = false
						 end,
				 		 case Create of
							true->
								spawnObjectActor( Record ),
								 ok;
							false->ok
						 end
				 end,
		etsBaseFunc:etsFor( MapCfg#mapCfg.mapSpawnTable, MyFunc ),
		ok
	catch
		_->ok
	end.


%%创建一个Object
createObject( #mapSpawn{} = Spawn )->
	try
		ObjectCfg = etsBaseFunc:readRecord( main:getGlobalObjectCfgTable(), Spawn#mapSpawn.typeId ),
				case ObjectCfg of
					{}->throw(-1);
					_->ok
				end,
		case Spawn#mapSpawn.type of
			?Object_Type_TRANSPORT->
				case length(Spawn#mapSpawn.param) >= 3 of
					true->ok;
					false->throw(-1)
				end,
				
				MapObjectActor = #mapObjectActor{id=map:makeObjectID( ?Object_Type_Object, db:memKeyIndex(mapObjectActor) ), % not persistent
								 event_array=undefined,
								 objType = ?Object_Type_TRANSPORT,
								 ets_table=map:getObjectTable(),
								 timerList=undefined,
								 spawnData=Spawn,
								 object_data_id = Spawn#mapSpawn.typeId,										 
								 x = Spawn#mapSpawn.x,
								 y = Spawn#mapSpawn.y,
							     param1 = lists:nth(1, Spawn#mapSpawn.param),
								 param2 = lists:nth(2, Spawn#mapSpawn.param), 
								 param3 = lists:nth(3, Spawn#mapSpawn.param), 
								 param4 = 0
								 };
			?Object_Type_SkillEffect->
				MapObjectActor = #mapObjectActor{id=map:makeObjectID( ?Object_Type_Object, db:memKeyIndex(mapObjectActor) ), % not persistent
								 event_array=undefined,
								 objType = ?Object_Type_SkillEffect,
								 ets_table=map:getObjectTable(),
								 timerList=undefined,
								 spawnData=Spawn,
								 object_data_id = Spawn#mapSpawn.typeId,										 
								 x = Spawn#mapSpawn.x,
								 y = Spawn#mapSpawn.y,
							     param1 = element(1,  Spawn#mapSpawn.param),
								 param2 = element(2,  Spawn#mapSpawn.param), 
								 param3 = element(3,  Spawn#mapSpawn.param), 
								 param4 = 0
								 };
			_->
				MapObjectActor = #mapObjectActor{id=map:makeObjectID( ?Object_Type_Object, db:memKeyIndex(mapObjectActor) ), % not persistent
								 event_array=undefined,
								 objType = ?Object_Type_Object,
								 ets_table=map:getObjectTable(),
								 timerList=undefined,
								 spawnData=Spawn,
								 object_data_id = Spawn#mapSpawn.typeId,										 
								 x = Spawn#mapSpawn.x,
								 y = Spawn#mapSpawn.y,
							     param1 = 0,
								 param2 = 0, 
								 param3 = 0, 
								 param4 = 0
								 }
				end,
		MapObjectActor
	catch
		_->{}
	end.

spawnObjectActor( SpawnData )->
	Object = createObject( SpawnData ),
	case Object of
		 {}->?ERROR_OUT( "~p create Object[~p] false", [map:getMapLog(), SpawnData] );
		 _->
			 %%脚本初始化
			 map:enterMapObject(Object)
	end,
	Object.

%%响应物件离开地图
onExitedMap( Object )->
	etsBaseFunc:deleteRecord( map:getObjectTable(), Object#mapObjectActor.id ),
	ok.

%%返回一个ObjectActor的类型
getObjectActorType( Object )->
	ObjectCfg = etsBaseFunc:readRecord( main:getGlobalObjectCfgTable(), Object#mapObjectActor.object_data_id ),
	case ObjectCfg#objectCfg.type of
		?Object_Type_TRANSPORT->ObjectCfg#objectCfg.type;
		?Object_Type_COLLECT->ObjectCfg#objectCfg.type;
		?Object_Type_Normal->ObjectCfg#objectCfg.type;
		?Object_Type_SkillEffect->ObjectCfg#objectCfg.type;
		_->0
	end.

%%返回能否被玩家采集
canBeenCollect( #mapPlayer{}=_Player, #mapObjectActor{}=Object )->
	case Object#mapObjectActor.spawnData#mapSpawn.type =:= ?Object_Type_COLLECT of
		true->true;
		false->false
	end.

%%被采集了
onCollected( #mapObjectActor{}=Object,PlayerID )->
	ObjectCfg = etsBaseFunc:readRecord( main:getGlobalObjectCfgTable(), Object#mapObjectActor.object_data_id ),
	case ObjectCfg of
		{}->ok;
		_->
			objectEvent:onEvent( Object, ?Object_Event_Interact, 0),
			objectEvent:onEvent( map:getMapObject(), ?Map_Event_Object_Interact, {Object,PlayerID} ),
			case ObjectCfg#objectCfg.param2 > 0 of
				true->
					erlang:send_after(ObjectCfg#objectCfg.param2*1000, self(),{ objectReSpawn, Object#mapObjectActor.spawnData } ),
					ok;
				false->ok
			end,
			map:despellObject(Object#mapObjectActor.id, 0 )
	end,
	ok.

%%Object交互
onMsg_U2GS_InteractObject( PlayerID, Msg )->
	try
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->throw(-1);
			_->ok
		end,
		
		ObjectActor = map:getObjectActor( Msg#pk_U2GS_InteractObject.nActorID ),
		case ObjectActor of
			{}->throw(-1);
			_->ok
		end,
		
		case getObjectActorType( ObjectActor ) of
			?Object_Type_TRANSPORT->
				MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), ObjectActor#mapObjectActor.param1 ),
				case MapCfg of
					{}->ok;
					_->
						playerChangeMap:transPlayerByTransport( Player, MapCfg#mapCfg.mapID, ObjectActor#mapObjectActor.param2, ObjectActor#mapObjectActor.param3 )
				end,
				throw(-1);
			_->ok
		end,

		ObjectCfg = etsBaseFunc:readRecord( main:getGlobalObjectCfgTable(), ObjectActor#mapObjectActor.object_data_id ),
		case ObjectCfg of
			{}->throw(-1);
			_->ok
		end,
		
		ok
	catch
		_->ok
	end.




