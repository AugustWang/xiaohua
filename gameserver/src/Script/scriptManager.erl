%% Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(scriptManager).

-include("db.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("monsterDefine.hrl").
-include("scriptDefine.hrl").
-include("globalDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 

%%返回所有脚本的Module
getAllScriptModule()->
	{ worldMap_1, copyMap_16,copyMap_17,  copyMap_18, copyMap_19, copyMap_20, copyMap_21, 
	  copyMap_23,copyMap_24, copyMap_25, copyMap_26, copyMap_27, copyMap_28, copyMap_29, 
	  copyMap_ChonWuDao, copyMap_JinYinDao, copyMap_39, copyMap_40,copyMap_8,copyMap_Battle}.

%%脚本初始化
initScript()->

	ets:new( ?ScriptObjectTableAtom, [set,protected, named_table,{read_concurrency,true}, { keypos, #scriptObject.id }] ),

	%put( "ScriptObjectTable", ?ScriptObjectTableAtom ),
	%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.scriptObjectTable, ScriptObjectTable),

	AllScriptModule = getAllScriptModule(),
	MyFunc = fun( Index )->
				Module = element( Index, AllScriptModule ),
				Module:init()
			 end,
	common:for( 1, size(AllScriptModule), MyFunc ),

	ok.

%%返回脚本对象ID，由Type占8位，DataID占24位
makeScriptObjectID( Type, DataID )->
	ID = ( Type bsl 24 ) bor DataID,
	ID.



%%注册脚本事件回调
registerScript( Type, DataID, Event, Module, CallBackFunc, Parama )->
try
	ID = makeScriptObjectID(Type, DataID),
	ScriptEvent = #scriptEvent{event=Event, call_module=Module, call_func=CallBackFunc, parama = Parama },

	TypeEventCount = objectEvent:getObjectEventCountByType( Type ),
	case ( Event < 0 ) or ( Event >= TypeEventCount ) of
		true->
			?ERROR_OUT("registerScript Type[~p], DataID[~p], Event[~p], Module[~p], CallBackFunc[~p] error event", 
				[Type, DataID, Event, Module, CallBackFunc]),
			throw(-1);
		false->ok
	end,

	ScriptObject = etsBaseFunc:readRecord( main:getScriptObjectTable(), ID ),
	case ScriptObject of
		{}->
			ScriptObject2 = #scriptObject{
										id=ID,
										type = Type,
										data_id = DataID,
										event_array = array:new( TypeEventCount, {default, {}} )
										},
			etsBaseFunc:insertRecord( main:getScriptObjectTable(), ScriptObject2 ),
			ok;
		_->ScriptObject2 = ScriptObject
	end,
	NewArray = array:set( Event, ScriptEvent, ScriptObject2#scriptObject.event_array ),
	etsBaseFunc:changeFiled( main:getScriptObjectTable(), ID, #scriptObject.event_array, NewArray ),
	ok
catch
	_->ok
end.

%%返回某脚本对象的某事件，没有事件，返回{}
getScriptObjectEvent( Type, DataID, Event )->
	ID = makeScriptObjectID(Type, DataID),
	ScriptObject = etsBaseFunc:readRecord( main:getScriptObjectTable(), ID ),
	case ScriptObject of
		{}->{};
		_->
			case (Event < 0 ) or (Event >= array:size( ScriptObject#scriptObject.event_array ) ) of
				true->{};
				_->
					array:get( Event, ScriptObject#scriptObject.event_array )
			end
	end.

%%物件初始化时，搜索脚本全局对象，将已注册的脚本事件回调注册进对象里去，-record( scriptEvent, {event, call_module, call_func} ).
onObjectCreateScript( Object )->
	try
		case element( 1, Object ) of
			mapObject->ObjectType = ?Object_Type_Map, ObjectDataID=Object#mapObject.map_data_id;
			mapPlayer->ObjectType = ?Object_Type_Player, ObjectDataID=?Global_Object_Player;
			mapPet->ObjectType = ?Object_Type_Pet, ObjectDataID=Object#mapPet.data_id;
			mapNpc->ObjectType = ?Object_Type_Npc, ObjectDataID=Object#mapNpc.npc_data_id;
			mapMonster->ObjectType = ?Object_Type_Monster, ObjectDataID=Object#mapMonster.monster_data_id;
			mapObjectActor->ObjectType = ?Object_Type_Object, ObjectDataID=Object#mapObjectActor.object_data_id;
			_->ObjectType=0, ObjectDataID=0, throw(-1)
		end,

		ScriptID = makeScriptObjectID( ObjectType, ObjectDataID ),
		ScriptObject = etsBaseFunc:readRecord(main:getScriptObjectTable(), ScriptID),
		case ScriptObject of
			{}->throw(-1);
			_->
				MyFunc = fun( Index )->
								 ScriptEvent = array:get( Index, ScriptObject#scriptObject.event_array ),
								 case ScriptEvent of
									 {}->ok;
									 _->
										 objectEvent:registerObjectEvent(Object, 
																		 ScriptEvent#scriptEvent.event, 
																		 element( ?object_type_index, Object),
																		 ObjectDataID, 
																		 ScriptEvent#scriptEvent.call_module, 
																		 ScriptEvent#scriptEvent.call_func, 
																		 ScriptEvent#scriptEvent.parama )
								 end
						 end,
				common:for( 0, array:size(ScriptObject#scriptObject.event_array) - 1, MyFunc )
		end,
		ok
	catch
		_->ok
	end.





