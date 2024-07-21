%% Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(npc).

-include("db.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% API Functions
%%

%%------------------------------------------------NpcStoreCfg------------------------------------------------

%%加载地图配置表中的npc
loadMapNpc()->
	try
		MapCfg = map:getMapCfg(),
		MyFunc = fun( Record )->
						 case Record#mapSpawn.type of
							 ?Object_Type_Npc->
								 Npc = createNpc( Record ),
								 case Npc of
									 {}->?ERROR_OUT( "~p create npc[~p] false", [map:getMapLog(), Record] );
									 _->
										 map:enterMapNpc(Npc)
								 end,
								 ok;
							 _->ok
						 end
				 end,
		etsBaseFunc:etsFor( MapCfg#mapCfg.mapSpawnTable, MyFunc ),
		ok
	catch
		_->ok
	end.


%%创建一个Npc
createNpc( #mapSpawn{} = Spawn )->
	try
		NpcCfg = etsBaseFunc:readRecord( main:getGlobalNpcCfgTable(), Spawn#mapSpawn.typeId ),
		case NpcCfg of
			{}->throw(-1);
			_->ok
		end,
		
		MapNpc = #mapNpc{id=map:makeObjectID( ?Object_Type_Npc, db:memKeyIndex(mapNpc) ), % not persistent
								 event_array=undefined,
								 objType = ?Object_Type_Npc,
								 ets_table=map:getMapNpcTable(),
						 		 timerList=undefined,
								 map_data_id=Spawn#mapSpawn.mapId,
								 spawnData=Spawn,
								 npc_data_id = Spawn#mapSpawn.typeId,										 
								 level =  1,
								 x = Spawn#mapSpawn.x,
								 y = Spawn#mapSpawn.y,
						 		 stateFlag=?Actor_State_Flag_Unkown
								 },
		MapNpc
	catch
		_->{}
	end.

%%退地图
onExitedMap( #mapNpc{}=Npc )->
	objectEvent:onEvent( Npc, ?Char_Event_Leave_Map, 0 ),	
	ok.

%%返回从Npc进入副本的MapIDList
getEnterCopyMapIDListFromNpc( Npc )->
	Return = objectEvent:onEvent( Npc, ?Npc_Event_EnterCopyMapID, 0 ),
	case Return of
		{ eventCallBackReturn, MapIDList }->
			MapIDList;
		_->[]
	end.

%%返回从Npc进入副本的MapID，以玩家为中心
canEnterCopyMapIDListAroundPlayer( PlayerID, MapDataID, DistSQ )->
	try
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->throw( { return, {false, 0} } );
			_->ok
		end,

		NpcList = mapView:getAroundNpcList( Player, false ),
		MyFunc = fun( Record )->
						 DistSQ_Player_Npc = monster:getDistSQFromTo( playerMap:getPlayerPosX(Player), 
																	  playerMap:getPlayerPosY(Player),
																	  Record#mapNpc.x,
																	  Record#mapNpc.y ),
						 case DistSQ_Player_Npc =< DistSQ of
							 true->
								 MapIDList = getEnterCopyMapIDListFromNpc( Record ),
								 { Find, _ } = common:findInList( MapIDList, MapDataID, 0),
								 case Find of
									 true->throw( { return, {true, Record} } );
									 _->ok
								 end;
							 false->ok
						 end
				 end,
		lists:foreach( MyFunc, NpcList ),
		{ false, 0 }
	catch
		{return, Return}->Return
	end.




