%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(mapManager).

%% add by wenziyong for gen server
-behaviour(gen_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%
%% Include files
%%
-include("db.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("mapDefine.hrl").
-include("playerDefine.hrl").
-include("condition_compile.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("scriptDefine.hrl").
-include("mapView.hrl").
-include("variant.hrl").
-include("taskDefine.hrl").
-include("globalDefine.hrl").
-include("guildDefine.hrl").




%%
%% Exported Functions
%%
-compile(export_all).

start_link() ->
	gen_server:start_link({local,mapManagerPID},?MODULE, [], [{timeout,?Start_Link_TimeOut_ms}]).



init([]) ->	
%% 	put( "MonsterCfgTable", main:getGlobalMonsterCfgTable() ),
%% 	put( "NpcCfgTable", main:getGlobalNpcCfgTable() ),
%% 	put( "MapCfgTable", main:getGlobalMapCfgTable() ),
	
	
	MapTable = ets:new( 'MapTable', [protected, { keypos, #mapObject.id }] ),
	put( "MapTable", MapTable ),

	OwnerIDTable = ets:new( 'ownerMap', [protected, { keypos, #ownerMap.ownerID }] ),
	put( "OwnerIDTable", OwnerIDTable ),
	
	initCombatID(),

	scriptManager:initScript(),
	
	ets:new( etsSceneNumofonemap, [set,private, named_table, { keypos, #sceneNumofonemap.mapID }] ),
	
	on_createMap( 1, ?Object_Type_System, ?Global_Object_System_ID ),
	?LOG_OUT( "mapManagerProcess started [~p]", [self()] ),
	
	
    {ok, {}}.


handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.



terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%地图配置信息加载
loadMapCfg()->
			%%先加载到db
			case db:openBinData( "monster.bin" ) of
				[]->ok;
				A->db:loadBinData( A, monsterCfg )
			end,
			case db:openBinData( "npc.bin" ) of
				[]->ok;
				A1->db:loadBinData( A1, npcCfg )
			end,
			db:loadOffsetString("mapsetting.str"),
			case db:openBinData( "mapsetting.bin" ) of
				[]->ok;
				A2->db:loadBinData( A2, mapSetting )
			end,
			case db:openBinData( "object.bin" ) of
				[]->ok;
				A3->db:loadBinData( A3, objectCfg )
			end,
			case db:openBinData( "monsterDeadEXP.bin" ) of
				[]->ok;
				A4->db:loadBinData( A4, monsterDeadEXP )
			end,
			
			%%monsterDeadEXP建ets表
			MonsterDeadEXPTable = ets:new( 'MonsterDeadEXPTable', [protected, named_table, { keypos, #monsterDeadEXP.levelDist }] ),
			
			MonsterDeadEXPList = db:matchObject(monsterDeadEXP,  #monsterDeadEXP{_='_'} ),
			MyFuncMonsterDeadEXP = fun( Record )->
							 etsBaseFunc:insertRecord(MonsterDeadEXPTable, Record)
					 end,
			lists:map( MyFuncMonsterDeadEXP, MonsterDeadEXPList ),
			
			%%monster建ets表
			ets:new( ?MonsterCfgTableAtom, [set,protected, named_table,{read_concurrency,true}, { keypos, #monsterCfg.monsterID }] ),
			
			
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.monsterCfgTable, MonsterCfgTable),
			
			MonsterCfgList = db:matchObject(monsterCfg,  #monsterCfg{_='_'} ),
			MyFunc = fun( Record )->
							 etsBaseFunc:insertRecord(?MonsterCfgTableAtom, Record)
					 end,
			lists:map( MyFunc, MonsterCfgList ),

			%%npc建ets表

			ets:new( ?NpcCfgTableAtom, [set,protected, named_table, {read_concurrency,true},{ keypos, #npcCfg.npcID }] ),
			
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.npcCfgTable, NpcCfgTable),
			
			NpcCfgList = db:matchObject(npcCfg,  #npcCfg{_='_'} ),
			MyFunc2 = fun( Record )->
							 etsBaseFunc:insertRecord(?NpcCfgTableAtom, Record)
					 end,
			lists:map( MyFunc2, NpcCfgList ),
			
			%%建MapView表
			ets:new( 'MapViewTable', [protected, named_table, {read_concurrency,true},{ keypos, #mapView.map_data_id }] ),
			
			%%map建ets表

			ets:new( ?MapCfgTableAtom, [set,protected, named_table,{read_concurrency,true}, { keypos,#mapCfg.mapID }] ),
			
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.mapCfgTable, MapCfgTable),
			
            %%MapCfgList = db:matchObject(mapSetting,  #mapSetting{id='_', mapID=1, _='_'} ),
            MapCfgList = db:matchObject(mapSetting,  #mapSetting{_='_'} ),
			MyFunc3 = fun( Record0 )->
							  String = db:getOffsetString(Record0#mapSetting.name, "mapsetting.str"),
							  Record = setelement( #mapSetting.name, Record0, String),	
							  MapSpawnTable = ets:new( 'MapSpawnTable', [protected, { keypos, #mapSpawn.id }] ),
							  MapCfg0 = #mapCfg{mapID=Record#mapSetting.mapID,
											   type=Record#mapSetting.type,
											   miniMap=Record#mapSetting.miniMap, 
											   mapScn=Record#mapSetting.mapScn, 
											   initPosX=Record#mapSetting.initPosX,
											   initPosY=Record#mapSetting.initPosY,
											   mapdroplist=Record#mapSetting.mapdroplist,
											   maxPlayerCount=Record#mapSetting.maxPlayerCount,
											   resetTime = Record#mapSetting.resetTime,
											   playerEnter_MinLevel=Record#mapSetting.playerEnter_MinLevel, 
											   playerEnter_MaxLevel=Record#mapSetting.playerEnter_MaxLevel, 
											   playerActiveEnter_Times=Record#mapSetting.playerActiveEnter_Times,
											   playerActiveTime_Item=Record#mapSetting.playerActiveTime_Item,
											   playerEnter_Times=Record#mapSetting.playerEnter_Times,	
						 					   dropItem1=Record#mapSetting.dropItem1, 
											   dropItem2=Record#mapSetting.dropItem2, 
											   dropItem3=Record#mapSetting.dropItem3,
											   dropItem4=Record#mapSetting.dropItem4,
											   dropItem5=Record#mapSetting.dropItem5, 
											   dropItem6=Record#mapSetting.dropItem6, 
											   dropItem7=Record#mapSetting.dropItem7, 
											   dropItem8=Record#mapSetting.dropItem8,
											   mapSpawnTable=MapSpawnTable,
											   quitMapID=Record#mapSetting.quitMapID, 
											   quitMapPosX=Record#mapSetting.quitMapPosX, 
											   quitMapPosY=Record#mapSetting.quitMapPosY,
												pkFlag_Camp=Record#mapSetting.pkFlag_Camp,
												pkFlag_Kill=Record#mapSetting.pkFlag_Kill,
												pkFlag_QieCuo=Record#mapSetting.pkFlag_QieCuo,
											   mapFaction=Record#mapSetting.mapFaction
											   },
							 MapCfg = setelement( #mapCfg.mapName, MapCfg0, String), 
							 etsBaseFunc:insertRecord(?MapCfgTableAtom, MapCfg),
							  
							 loadMapData( MapCfg )
					 end,
			lists:map( MyFunc3, MapCfgList ),
			
			%%建object表

			ets:new( ?ObjectCfgTableAtom, [set,protected, named_table,{read_concurrency,true}, { keypos, #objectCfg.objectID }] ),
			
			
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.objectCfgTable, ObjectCfgTable),
			
			ObjectCfgTableList = db:matchObject(objectCfg,  #objectCfg{_='_'} ),
			MyFunc4 = fun( Record )->
							 etsBaseFunc:insertRecord(?ObjectCfgTableAtom, Record)
					 end,
			lists:map( MyFunc4, ObjectCfgTableList ),
			
			ok.

%%技能、buff配置初始化
loadSkillBuff()->
	try
 		SkillDataBin = db:openBinData( "skill.bin" ),
		case SkillDataBin of
			[]->?ERROR_OUT( "SkillDataBin = []" );
			_->
				db:loadBinData( SkillDataBin, skillCfg ),
				
				%%skill建ets表

				ets:new( ?SkillCfgTableAtom, [set,protected, named_table,{read_concurrency,true}, { keypos, #skillCfg.skill_id }] ),
				
				%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.skillCfgTable, SkillCfgTable),
				
				SkillCfgList = db:matchObject(skillCfg,  #skillCfg{_='_'} ),
				MyFunc = fun( Record )->							 
						 		 NewRecord = setelement( #skillCfg.rangerSquare, Record, Record#skillCfg.rangerSquare*Record#skillCfg.rangerSquare),
								 NewRecord2 = setelement( #skillCfg.skillRangeSquare, NewRecord, Record#skillCfg.skillRangeSquare*Record#skillCfg.skillRangeSquare),
								 etsBaseFunc:insertRecord(?SkillCfgTableAtom, NewRecord2)
						 end,
				lists:foreach( MyFunc, SkillCfgList )
		end,

 		SkillEffectDataBin = db:openBinData( "skill_effect.bin" ),
		case SkillEffectDataBin of
			[]->?ERROR_OUT( "SkillEffectDataBin = []" );
			_->
				db:loadBinData( SkillEffectDataBin, skill_effect_data ),
				
				%%skill_effect建ets表

				ets:new( ?SkillEffectCfgTableAtom, [set,protected, named_table, {read_concurrency,true},{ keypos, #skill_effect.skill_id }] ),
				
				
				%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.skillEffectCfgTable, SkillEffectCfgTable),
				
				SkillEffectCfgList = db:matchObject(skill_effect_data,  #skill_effect_data{_='_'} ),
				MyFunc2 = fun( Record )->
								 OldEffect = etsBaseFunc:readRecord( ?SkillEffectCfgTableAtom, Record#skill_effect_data.skill_id ),
								 case OldEffect of
									 {}->
										 etsBaseFunc:insertRecord(?SkillEffectCfgTableAtom, #skill_effect{ skill_id=Record#skill_effect_data.skill_id, effect_list=[Record]} );
									 _->
										 etsBaseFunc:changeFiled( ?SkillEffectCfgTableAtom, 
																  Record#skill_effect_data.skill_id, 
																  #skill_effect.effect_list, 
																  OldEffect#skill_effect.effect_list ++ [Record] )
								 end
						 end,
				lists:foreach( MyFunc2, SkillEffectCfgList )
		end,
		
		
 		BuffDataBin = db:openBinData( "buff.bin" ),
		case BuffDataBin of
			[]->?ERROR_OUT( "BuffDataBin = []" );
			_->
				db:loadBinData( BuffDataBin, buffCfg ),
				
				%%buff建ets表

				ets:new( ?BuffCfgTableAtom, [set,protected, named_table,{read_concurrency,true}, { keypos, #buffCfg.buff_id}] ),

				
				%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.buffCfgTable, BuffCfgTable),
				
				BuffCfgList = db:matchObject(buffCfg,  #buffCfg{_='_'} ),
				MyFunc3 = fun( Record )->
								 etsBaseFunc:insertRecord(?BuffCfgTableAtom, Record)
						 end,
				lists:foreach( MyFunc3, BuffCfgList )
		end,
		ok
	catch
		_->ok
	end.

%%开服创建地图
onServerStartToCreateMap()->
	MyFunc = fun( Record )->
				case Record#mapCfg.type of
					?Map_Type_Normal_World->
						on_createMap( Record#mapCfg.mapID, ?Object_Type_System, ?Global_Object_System_ID ),
						ok;
					_->ok
				end
			 end,
	etsBaseFunc:etsFor( main:getGlobalMapCfgTable(), MyFunc ).



getMapTable()->
	get( "MapTable" ).

getOwnerIDTable()->
	get( "OwnerIDTable" ).

%%地图管理进程
%%地图管理进程主循环
handle_info(Info, StateData)->	
	put( "loopMapManager", true ),

	try
	case Info of
		{quit}->
			?LOG_OUT("loopMapManager recv quit"),
			put( "loopMapManager", false );
		{createMap, MapDataID, CreaterType, CreaterID }->
			on_createMap( MapDataID, CreaterType, CreaterID );
		{playerOnlineToEnterMap, Player, PlayerPID, PlayerSkillList, BuffData, PlayerProperty, WeaponID, CoatID, ConvoyQuality, ConvoyFlags,Credit, EquipMinLevel, VIPInfo}->
			on_playerOnlineToEnterMap( Player, PlayerPID, PlayerSkillList, BuffData, PlayerProperty, WeaponID, CoatID, ConvoyQuality, ConvoyFlags,Credit, EquipMinLevel, VIPInfo);
		{ playerSendMsgToAllMap, Msg }->
			on_playerSendMsgToAllMap( Msg );
		{ playerOffeLine, PlayerID }->
			releasePlayerCombatID( PlayerID );
		{ mapProcExited, MapID }->
			releaseMapCombatID( MapID );
		{ getReadyToEnterMap, FromPID, OwnerID, EnterPlayerList, TargetMapInfo }->
			on_getReadyToEnterMap( FromPID, OwnerID, EnterPlayerList, TargetMapInfo );
		{ mapMsg_OnlinePlayers, MapID, OnlinePlayers }->
			on_mapMsg_OnlinePlayers( MapID, OnlinePlayers );
		{ mapDestroyed, MapID }->
			on_mapDestroyed( MapID );
		{ teamMsg_Created, TeamID, TeamLeader }->
			on_teamMsg_Created( TeamID, TeamLeader );
		{ teamMsg_Join, TeamID, JoinPlayerID }->
			on_teamMsg_Join( TeamID, JoinPlayerID );
		{ teamMsg_Disband, TeamID, TeamLeader }->
			on_teamMsg_Disband( TeamID, TeamLeader );
		{ playerMapMsg_ResetCopyMap, PlayerID, OwnerID, MapDataID }->
			on_playerMapMsg_ResetCopyMap( PlayerID, OwnerID, MapDataID );
		{ woldBossBegin, MapID}->
			on_WorldBossBegin(MapID);
		
		{ killWorldBoss, MapID,BossID}->
			on_KillWorldBoss( BossID,MapID);
		
		{ worldBossAddExp, MapID }->
			on_WorldBossAddExp( MapID );
		{worldBossKill,MapID}->
			on_WorldBossKill( MapID );
		{battleBalance,MapID}->
			on_BattleBalance(MapID);
		%%{changeMultyExpBuff,PlayerID,BuffID,IsAdd}->
		%%	on_ChangeMultyExpBuff( PlayerID,BuffID,IsAdd );
		_->
			?LOG_OUT( "loopMapManager receive unkown" )
	end,

	case get( "loopMapManager" ) of
		true->{noreply, StateData};
		false->{stop, normal, StateData}
	end

	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[?MODULE,_Why, erlang:get_stacktrace()] ),	

			{noreply, StateData}
	end.


%%地图创建
on_createMap( MapDataID, CreaterType, CreaterID )->
	try
		MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), MapDataID ),
		case MapCfg of
			{}->throw(-1);
			_->ok
		end,
		
		MapID = map:makeObjectID( ?Object_Type_Map, db:memKeyIndex(mapObject) ), % not persistent
		NewMap = #mapObject{ id=MapID,
							 event_array=undefined,
							 objType = ?Object_Type_Map,
							 ets_table = getMapTable(),
							 map_data_id=MapDataID,
							 ownerType=CreaterType, 
							 ownerID=CreaterID, 
							 pid=0,
							 combatID = getMapCombatID(MapID),
							 onlineplayers=0,
							 enteredPlayerHistory=[] },
		
		
		%MapPID = proc_lib:start( map, mapProcess, [NewMap], ?ProcessTimeOut ),
		StartRet = mapSup:start_child(NewMap),
		case StartRet of
			{ok, MapPID}->ok;
			_->
				?ERROR_OUT( "on_createMap StartRet[~p]", [StartRet] ),
				MapPID = 0,
				throw(-1)
		end,

		
		NewMap2 = setelement( #mapObject.pid, NewMap, MapPID ),

		case worldBoss:isWorldBossMap(NewMap2#mapObject.map_data_id) of
		true->
			worldBossManagerPID!{requestBossActive,NewMap2#mapObject.pid},
			ok;
		false->
			ok
		end,
		%%告诉场景，自己是第几线

		SceneNumberList = ets:lookup(etsSceneNumofonemap, MapDataID),
		case SceneNumberList of
			[]->
				NewRecord=#sceneNumofonemap{mapID=MapDataID,sceneNum=1},
				ets:insert(etsSceneNumofonemap, NewRecord),
				NewMap2#mapObject.pid!{tellSelfLineID,1},
				SceneNum = 1,
				ok;
			[Result|_]->
				ets:update_element(etsSceneNumofonemap, MapDataID, {#sceneNumofonemap.sceneNum,Result#sceneNumofonemap.sceneNum+1}),
				NewMap2#mapObject.pid!{tellSelfLineID,Result#sceneNumofonemap.sceneNum+1},
				SceneNum = Result#sceneNumofonemap.sceneNum+1,
				ok
		end,
		%%告诉场景，总共多少线，没弄
		
		etsBaseFunc:insertRecord( getMapTable(), NewMap2 ),

		
		?LOG_OUT( "on_createMap MapID[~p] MapPID[~p] SceneNum[~p] MapDataID[~p] CreaterType[~p] CreaterID[~p] combatID[~p]", 
				  [MapID, NewMap2#mapObject.pid, SceneNum, MapDataID, CreaterType, CreaterID, NewMap2#mapObject.combatID] ),

		NewMap2
	catch
		_->{}
	end.

on_mapDestroyed( MapID )->
	try
		?LOG_OUT( "on_mapDestroyed MapID[~p]", [MapID] ),
		
		etsBaseFunc:deleteRecord( getMapTable(), MapID ),
		
		MyFunc = fun( Record )->
						 { Find, _ } = common:findInList( Record#ownerMap.mapIDList, MapID, 0 ),
						 case Find of
							 true->
								 New_mapIDList = Record#ownerMap.mapIDList -- [MapID],
								 
								 ?DEBUG_OUT( "on_mapDestroyed MapID[~p], New_mapIDList[~p]", [MapID, New_mapIDList] ),
								 
								 etsBaseFunc:changeFiled( getOwnerIDTable(), Record#ownerMap.ownerID, #ownerMap.mapIDList, New_mapIDList );
							 false->ok
						 end
				 end,
		etsBaseFunc:etsFor(getOwnerIDTable(), MyFunc ),
		ok
	catch
		_->ok
	end.


%%返回一个世界地图，如果该地图已经满员，则新建，参数：地图MapDataID，一定是世界地图
getNormalWorldMap( MapDataID )->
	MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), MapDataID ),
	case MapCfg#mapCfg.type of
		?Map_Type_Normal_World->
				Q = ets:fun2ms( fun(#mapObject{id='_', map_data_id=MapDataIDDB} = Record ) when ( MapDataIDDB=:=MapDataID ) -> Record end),
				Ret = ets:select(getMapTable(), Q),
				case Ret of
					[]->on_createMap( MapDataID, ?Object_Type_System, ?Global_Object_System_ID );
					_->
						case MapCfg#mapCfg.maxPlayerCount > 0 of
							false->[R|_]=Ret, R;
							true->
								put( "getNormalWorldMap_max", 0 ),
								put( "getNormalWorldMap_map", {} ),
								MyFunc = fun( Record2 )->
												 CurMax = get( "getNormalWorldMap_max" ),
												 case ( Record2#mapObject.onlineplayers >= CurMax ) andalso
													  ( Record2#mapObject.onlineplayers < MapCfg#mapCfg.maxPlayerCount )  of
													 true->
														 put( "getNormalWorldMap_max", Record2#mapObject.onlineplayers ),
														 put( "getNormalWorldMap_map", Record2 );
													 false->ok
												 end
										 end,
								lists:foreach( MyFunc, Ret ),
								
								FindMap = get( "getNormalWorldMap_map" ),
								
								case FindMap of
									{}->
										%?DEBUG_OUT( "getNormalWorldMap MapDataID[~p] FindMap={}", [MapDataID] ),
										%%没有找到合适的，新建
										NewMap = on_createMap( MapDataID, ?Object_Type_System, ?Global_Object_System_ID );
									_->
									   %?DEBUG_OUT( "getNormalWorldMap MapDataID[~p] FindMap=[~p]", [MapDataID, FindMap] ),
									   NewMap = FindMap
								end,
								
								NewMap
						end
					
				end;
		_->{}
	end.


%%返回地图实例
getMapByID( MapID )->
	etsBaseFunc:readRecord( getMapTable(), MapID ).

%%返回地图ViewTable
getMapViewTable()->
	'MapViewTable'.

%%返回mapView
getMapView( MapDataId ) ->
	etsBaseFunc:readRecord(getMapViewTable(), MapDataId).


%%返回地图Spawn
getMapSpawnTable( MapDataID )->
	MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), MapDataID ),
	case MapCfg of
		{}->{};
		_->MapCfg#mapCfg.mapSpawnTable
	end.

readUInt(Bin, Pos) ->
	A0 = binary:at(Bin, Pos + 0 ),
	A1 = binary:at(Bin, Pos + 1 ),
	A2 = binary:at(Bin, Pos + 2 ),
	A3 = binary:at(Bin, Pos + 3 ),
	
	A3 * 256 * 256 * 256 + A2 * 256 * 256 + A1 * 256 + A0.

%%地图monster npc信息加载
loadMapData(MapCfg ) ->
	MapIDStringValue = io_lib:format( "Map~p", [MapCfg#mapCfg.mapScn] ),
	MapIStringValue2 = lists:flatten(MapIDStringValue),
	Name = MapIStringValue2 ++ ".scn",
	
	case file:read_file( Name  ) of
		{ok,Bin} ->
			Len = readUInt( Bin, 0 ),

			Width  = readUInt( Bin, Len + 4 ),
			Height = readUInt( Bin, Len + 8 ),

			Pos = Len+12,
			Size = Width*Height,			
		
			PosObj = Pos + Size,
			Count = readUInt( Bin, PosObj ),

			%%初始化全局的地图格子信息表
			{ CellWidthCount, CellHeightCount, AroundCellIndexArray } = mapView:makeMapViewCellArea( Width*?Map_Pixel_Title_Width, Height*?Map_Pixel_Title_Height ),
			
			MapView = #mapView{map_data_id=MapCfg#mapCfg.mapID,
								width=Width*?Map_Pixel_Title_Width,
								height=Height*?Map_Pixel_Title_Height,
								phy=binary:part(Bin, Pos, Size),
								widthCellCount = CellWidthCount, 
								heightCellCount = CellHeightCount,
							    aroundCellIndexArray=AroundCellIndexArray
								},

			etsBaseFunc:insertRecord( getMapViewTable(), MapView ),

			loadMonster( MapCfg#mapCfg.mapID, Bin, Count, PosObj + 4 ),
			
			MapSpawnTable = getMapSpawnTable( MapCfg#mapCfg.mapID ),
			
			Q_Monster = ets:fun2ms( fun(#mapSpawn{id=_,mapId=_, type=Type} = Record ) when ( Type=:=?Object_Type_Monster )-> Record end),
			MonsterList = ets:select(MapSpawnTable, Q_Monster),
			
			Q_Npc = ets:fun2ms( fun(#mapSpawn{id=_,mapId=_, type=Type} = Record ) when ( Type=:=?Object_Type_Npc )-> Record end),
			NpcList = ets:select(MapSpawnTable, Q_Npc),
			
			Q_Object = ets:fun2ms( fun(#mapSpawn{id=_,mapId=_, type=Type} = Record ) when ( ( Type=:=?Object_Type_TRANSPORT ) or
																							 ( Type=:=?Object_Type_COLLECT )  )-> Record end),
			ObjectList = ets:select(MapSpawnTable, Q_Object),
			
			?DEBUG_OUT( "load map id[~p] scn[~p] monster[~p] npc[~p] object[~p]", [MapCfg#mapCfg.mapID, Name, length(MonsterList),length(NpcList),length(ObjectList)] ),
			
			ok;
		_ ->
			?ERROR_OUT( "loadMapData ~p false", [MapCfg#mapCfg.mapID] )
	end.

loadMonster( _, _, 0, _ ) ->
	ok;

loadMonster( MapDataID, Bin, Count, PosObj ) ->
	Type = readUInt( Bin, PosObj + 0 ),
	TypeId = readUInt( Bin, PosObj + 4 ),
	X =  readUInt( Bin, PosObj + 8 ),
	Y =  readUInt( Bin, PosObj + 12 ),
	
	{Params, Pos} = loadParam( Bin, PosObj + 16  ),
	
	MapView = etsBaseFunc:readRecord( getMapViewTable(), MapDataID ),
	
	MapSpawn = #mapSpawn{id=db:memKeyIndex(mapObject), % not persistent
						 mapId=MapDataID,
						 type=Type,
						 typeId=TypeId,
						 x=X,
						 y=MapView#mapView.height - Y,
						 param = Params,
						 isExist = 1
						 },
	etsBaseFunc:insertRecord( getMapSpawnTable( MapDataID ), MapSpawn ),
	
	loadMonster(MapDataID, Bin, Count-1, Pos).


loadParamData( _, 0, _Pos ) ->
	[];	

loadParamData( Bin, Count, Pos ) ->
	Data1 =  readUInt( Bin, Pos ),
	[Data1] ++ loadParamData(Bin,Count-1,Pos+4) .
	
loadParam( Bin, Pos) ->
	Count =  readUInt( Bin, Pos + 0 ),	
	{loadParamData( Bin, Count, Pos + 4 ), Pos + Count*4 + 4 }.


%%玩家上线进入地图
on_playerOnlineToEnterMap( Player, Player_PID, PlayerSkillList, BuffData, PlayerProperty, WeaponID, CoatID, ConvoyQuality, ConvoyFlags,Credit, EquipMinLevel, VIPInfo)->
	try
		setPlayerCombatID( Player#player.id ),
		PlayerID = Player#player.id,
		
		MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), Player#player.map_data_id ),
		case MapCfg of
			{}->%%所在地图不存在，回默认出生点
				?ERROR_OUT( "Player[~p] on_playerOnlineToEnterMap map_data_id[~p] MapCfg={}",
							 [Player#player.id, Player#player.map_data_id] ),
				throw(-1);
			_->ok
		end,
		
		case MapCfg#mapCfg.type of
			?Map_Type_Normal_World->
				EnterMapID = Player#player.map_data_id,
				EnterMapPosX = Player#player.x,
				EnterMapPosY = Player#player.y,
				ok;
			?Map_Type_Battle->
				%%下面的代码复制了一遍，很丑
				OwnerMap = etsBaseFunc:readRecord( ?MODULE:getOwnerIDTable(), PlayerID ),
				case OwnerMap of
					{}->%%副本已经不存在，回到副本退出点
						EnterMapID = MapCfg#mapCfg.quitMapID,
						EnterMapPosX = MapCfg#mapCfg.quitMapPosX,
						EnterMapPosY = MapCfg#mapCfg.quitMapPosY;
					_->
						MyFunc = fun( Value, FindValue )->
										 Map = etsBaseFunc:readRecord( ?MODULE:getMapTable(), Value ),
										 case Map of
											 {}->false;
											 _->Map#mapObject.map_data_id =:= FindValue
										 end
								 end,
						{ Find, FindValue } = common:findInList( OwnerMap#ownerMap.mapIDList, MapCfg#mapCfg.mapID, MyFunc),
						case Find of
							true->
								Map2 = etsBaseFunc:readRecord( ?MODULE:getMapTable(), FindValue ),
								NewPlayer=playerMap:makeMapPlayer(Player, Player_PID, Player#player.x, Player#player.y, ConvoyQuality, ConvoyFlags,Credit, EquipMinLevel, VIPInfo),
								Map2#mapObject.pid ! { playerEnterMap,NewPlayer, PlayerSkillList, BuffData, PlayerProperty, WeaponID, CoatID },
								EnterMapID = 0,EnterMapPosX=0,EnterMapPosY=0,
								throw(return);
							false->
								EnterMapID = MapCfg#mapCfg.quitMapID,
								EnterMapPosX = MapCfg#mapCfg.quitMapPosX,
								EnterMapPosY = MapCfg#mapCfg.quitMapPosY
						end
				end,
				ok;
			?Map_Type_Normal_Copy->
				OwnerMap = etsBaseFunc:readRecord( ?MODULE:getOwnerIDTable(), PlayerID ),
				case OwnerMap of
					{}->%%副本已经不存在，回到副本退出点
						EnterMapID = MapCfg#mapCfg.quitMapID,
						EnterMapPosX = MapCfg#mapCfg.quitMapPosX,
						EnterMapPosY = MapCfg#mapCfg.quitMapPosY;
					_->
						MyFunc = fun( Value, FindValue )->
										 Map = etsBaseFunc:readRecord( ?MODULE:getMapTable(), Value ),
										 case Map of
											 {}->false;
											 _->Map#mapObject.map_data_id =:= FindValue
										 end
								 end,
						{ Find, FindValue } = common:findInList( OwnerMap#ownerMap.mapIDList, MapCfg#mapCfg.mapID, MyFunc),
						case Find of
							true->
								Map2 = etsBaseFunc:readRecord( ?MODULE:getMapTable(), FindValue ),
								NewPlayer=playerMap:makeMapPlayer(Player, Player_PID, Player#player.x, Player#player.y, ConvoyQuality, ConvoyFlags,Credit, EquipMinLevel, VIPInfo),
								Map2#mapObject.pid ! { playerEnterMap,NewPlayer, PlayerSkillList, BuffData, PlayerProperty, WeaponID, CoatID },
								EnterMapID = 0,EnterMapPosX=0,EnterMapPosY=0,
								
								?LOG_OUT( "Player[~p] on_playerOnlineToEnterMap playerpos[~p ~p ~p] EnterMap Map_Type_Normal_Copy[~p ~p ~p ~p]", 
										  [PlayerID,
										   Player#player.map_data_id,
										   Player#player.x,
										   Player#player.y,
										   EnterMapID,
										   EnterMapPosX,
										   EnterMapPosY,
										   Map2#mapObject.pid
										   ] ),
								
								throw(return);
							false->
								EnterMapID = MapCfg#mapCfg.quitMapID,
								EnterMapPosX = MapCfg#mapCfg.quitMapPosX,
								EnterMapPosY = MapCfg#mapCfg.quitMapPosY
						end
				end,
				ok;
			_->
				?ERROR_OUT( "Player[~p] on_playerOnlineToEnterMap MapCfg#mapCfg.type[~p]", [PlayerID, MapCfg#mapCfg.type] ),
				EnterMapID = 0,EnterMapPosX=0,EnterMapPosY=0,
				throw(-1)
		end,
		
		NormalWorldMap = getNormalWorldMap( EnterMapID ),
		case NormalWorldMap of
			{}->%%世界地图不存在？，应该不可能
				?ERROR_OUT( "Player[~p] on_playerOnlineToEnterMap EnterMapID[~p] = {}", [PlayerID, EnterMapID] ),
				throw(-1);
			_->ok
		end,
		
		NewPlayer2=playerMap:makeMapPlayer(Player, Player_PID, EnterMapPosX, EnterMapPosY, ConvoyQuality, ConvoyFlags,Credit, EquipMinLevel, VIPInfo),
		NormalWorldMap#mapObject.pid ! { playerEnterMap,NewPlayer2 , PlayerSkillList, BuffData, PlayerProperty, WeaponID, CoatID },

		?LOG_OUT( "Player[~p] on_playerOnlineToEnterMap playerpos[~p ~p ~p] EnterMap[~p ~p ~p ~p]", 
				  [PlayerID,
				   Player#player.map_data_id,
				   Player#player.x,
				   Player#player.y,
				   EnterMapID,
				   EnterMapPosX,
				   EnterMapPosY,
				   NormalWorldMap#mapObject.pid
				   ] ),
		
		ok
	catch
		return->ok;
		_->ok
	end.

on_playerSendMsgToAllMap( Msg )->
	MyFunc = fun( Record )->
					 Record#mapObject.pid ! Msg
			 end,
	etsBaseFunc:etsFor( getMapTable(), MyFunc ).

%%初始化战斗ID
initCombatID()->
	CombatID_Player = ets:new( 'CombatID_Player', [protected, { keypos, #combatID.index }] ),
	put( "CombatID_Player", CombatID_Player ),
	CombatID_Map = ets:new( 'CombatID_Map', [protected, { keypos, #combatID.index }] ),
	put( "CombatID_Map", CombatID_Map ),
	
	MyFunc = fun( Index )->
					 etsBaseFunc:insertRecord( CombatID_Player, #combatID{index = Index*?Player_CombatID, key=0 } )
			 end,
	playerItems:for( 1, ?MaxOnlineUsers*2, MyFunc ),
	
	MyFunc2 = fun( Index )->
					  etsBaseFunc:insertRecord( CombatID_Map, #combatID{index = ?Monster_CombatID_Begin+Index*?Monster_CombatID, key=0 } )
			 end,
	playerItems:for( 0, 5000, MyFunc2 ).

%%设置一个玩家的战斗ID
setPlayerCombatID( PlayerID )->
	Q = ets:fun2ms( fun(#combatID{index=_,key=Key} = Record ) when Key=:=0 -> Record end),
	case ets:select( get("CombatID_Player"), Q,1) of
		'$end_of_table'->0;
		{[First|_],_Continuation}->
			etsBaseFunc:changeFiled( get("CombatID_Player"), First#combatID.index, #combatID.key, PlayerID ),
			Msg = #pk_PlayerCombatIDInit{nBeginCombatID=#combatID.index},
			player:sendToPlayer(PlayerID, Msg)
	end.
			

%%释放一个玩家战斗ID
releasePlayerCombatID( PlayerID )->
	Q = ets:fun2ms( fun(#combatID{index=_,key=Key} = Record ) when Key=:=PlayerID -> Record end),
	case ets:select( get("CombatID_Player"), Q,1) of
		'$end_of_table'->ok;
		{[First|_],_Continuation}->
			etsBaseFunc:changeFiled( get("CombatID_Player"), First#combatID.index, #combatID.key, 0 )
	end.
%%返回一个地图战斗ID
getMapCombatID( MapID )->
	Q = ets:fun2ms( fun(#combatID{index=_,key=Key} = Record ) when Key=:=0 -> Record end),
	case ets:select( get("CombatID_Map"), Q,1) of
		'$end_of_table'->0;
		{[First|_],_Continuation}->
			etsBaseFunc:changeFiled( get("CombatID_Map"), First#combatID.index, #combatID.key, MapID ),
			First#combatID.index
	end.

%%释放一个地图战斗ID
releaseMapCombatID( MapID )->
	Q = ets:fun2ms( fun(#combatID{index=_,key=Key} = Record ) when Key=:=MapID -> Record end),

	case ets:select( get("CombatID_Map"), Q,1) of
		'$end_of_table'->ok;
		{[First|_],_Continuation}->
			etsBaseFunc:changeFiled( get("CombatID_Map"), First#combatID.index, #combatID.key, 0 )
	end.
	
%%地图在线人数更新
on_mapMsg_OnlinePlayers( MapID, OnlinePlayers )->
	MapObject = getMapByID( MapID ),
	case MapObject of
		{}->ok;
		_->
			etsBaseFunc:changeFiled( getMapTable(), MapID, #mapObject.onlineplayers, OnlinePlayers )
	end.


%%返回一个准备进入的地图，如果副本不存在，创建副本，如果世界地图超上限，新建世界地图分线
%%OwnerID=队伍ID、玩家ID...
%%{MapID, MapDataID, ReadyResult_CallBack, NotCreate, Param} = TargetMapInfo,
%%[Player1,Player2...]=EnterPlayerList
on_getReadyToEnterMap( FromPID, OwnerID, EnterPlayerList, TargetMapInfo )->
	try
		%%目标地图信息，MapID/=0的话，是指进入指定地图，=0，表示根据MapDataID，由系统自动分配
		{MapID, MapDataID, _ReadyResult_CallBack, NotCreate, Param} = TargetMapInfo,
		
		case MapID /= 0 of
			true->
				Map = ?MODULE:getMapByID( MapID ),
				case Map of
					{}->%%进入指定地图，不存在的话，是直接返回的，不会自动分配
						?LOG_OUT( "on_getReadyToEnterMap MapID[~p] OwnerID[~p] can not find", [MapID, OwnerID] ),
						throw(-1);
					_->%%向指定地图请求检测是否能进入
						Map#mapObject.pid ! { getReadyToEnterMap_CanEnter, FromPID, OwnerID, EnterPlayerList, TargetMapInfo }
				end;
			false->
				MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), MapDataID ),
				case MapCfg of
					{}->throw(-1);
					_->ok
				end,
				
				case MapCfg#mapCfg.type of
					?Map_Type_Normal_World->%%世界地图
						Map = ?MODULE:getNormalWorldMap( MapDataID ),
						case Map of
							{}->throw(-1);%%世界地图应该存在
							_->Map#mapObject.pid ! { getReadyToEnterMap_CanEnter, FromPID, OwnerID, EnterPlayerList, TargetMapInfo }
						end,
						ok;
					?Map_Type_Battle->
						%%继续复制下面的代码，很丑
						%%检测是否已经拥有
						OwnerMap = etsBaseFunc:readRecord( ?MODULE:getOwnerIDTable(), OwnerID ),
						case OwnerMap of
							{}->ok;
							_->
								FindFunc = fun( ListValue, FindValue )->
												   Map = ?MODULE:getMapByID( ListValue ),
												   case Map of
													   {}->false;
													   _->Map#mapObject.map_data_id =:= FindValue
												   end
										   end,
								
								Find = common:findInList( OwnerMap#ownerMap.mapIDList, MapDataID, FindFunc ),
								case Find of
									{ true, Return }->%%找到已经存在的副本，直接向该副本询问
										Map = ?MODULE:getMapByID( Return ),
										Map#mapObject.pid ! { getReadyToEnterMap_CanEnter, FromPID, OwnerID, EnterPlayerList, TargetMapInfo },
										throw(return);
									_->ok
								end
						end,
						
						%%如果要求没有副本的话，不创建，则返回
						case NotCreate of
							true->
								FromPID ! { getReadyToEnterMap_Result, self(), OwnerID, EnterPlayerList, TargetMapInfo, {false, ?EnterMap_Fail_NotTeamLeader } },
								throw(return);
							false->ok
						end,
						
						%%新建副本
						NewMap = on_createMap( MapDataID, map:getObjectID_TypeID(OwnerID), map:getObjectID_Value(OwnerID) ),
						%%新副本进拥有者队列
						case OwnerMap of
							{}->New_OwnerMap = #ownerMap{ ownerID=OwnerID, mapIDList=[NewMap#mapObject.id] };
							 _->
								 New_OwnerMap = setelement( #ownerMap.mapIDList, OwnerMap, OwnerMap#ownerMap.mapIDList ++ [NewMap#mapObject.id] )
						end,

						etsBaseFunc:insertRecord( ?MODULE:getOwnerIDTable(), New_OwnerMap ),

						?DEBUG_OUT( "New_OwnerMap[~p] EnterPlayerList[~p]", [New_OwnerMap, EnterPlayerList] ),
						
						NewParam = setelement( 1, Param, true ),
						NewTargetMapInfo = setelement( 5, TargetMapInfo, NewParam ),
						NewMap#mapObject.pid ! { getReadyToEnterMap_CanEnter, FromPID, OwnerID, EnterPlayerList, NewTargetMapInfo },
						ok;
					?Map_Type_Normal_Copy->%%一般副本地图
						%%检测是否已经拥有
						OwnerMap = etsBaseFunc:readRecord( ?MODULE:getOwnerIDTable(), OwnerID ),
						case OwnerMap of
							{}->ok;
							_->
								FindFunc = fun( ListValue, FindValue )->
												   Map = ?MODULE:getMapByID( ListValue ),
												   case Map of
													   {}->false;
													   _->Map#mapObject.map_data_id =:= FindValue
												   end
										   end,
								
								Find = common:findInList( OwnerMap#ownerMap.mapIDList, MapDataID, FindFunc ),
								case Find of
									{ true, Return }->%%找到已经存在的副本，直接向该副本询问
										Map = ?MODULE:getMapByID( Return ),
										Map#mapObject.pid ! { getReadyToEnterMap_CanEnter, FromPID, OwnerID, EnterPlayerList, TargetMapInfo },
										throw(return);
									_->ok
								end
						end,
						
						%%如果要求没有副本的话，不创建，则返回
						case NotCreate of
							true->
								FromPID ! { getReadyToEnterMap_Result, self(), OwnerID, EnterPlayerList, TargetMapInfo, {false, ?EnterMap_Fail_NotTeamLeader } },
								throw(return);
							false->ok
						end,
						
						%%新建副本
						NewMap = on_createMap( MapDataID, map:getObjectID_TypeID(OwnerID), map:getObjectID_Value(OwnerID) ),
						%%新副本进拥有者队列
						case OwnerMap of
							{}->New_OwnerMap = #ownerMap{ ownerID=OwnerID, mapIDList=[NewMap#mapObject.id] };
							 _->
								 New_OwnerMap = setelement( #ownerMap.mapIDList, OwnerMap, OwnerMap#ownerMap.mapIDList ++ [NewMap#mapObject.id] )
						end,

						etsBaseFunc:insertRecord( ?MODULE:getOwnerIDTable(), New_OwnerMap ),

						?DEBUG_OUT( "New_OwnerMap[~p] EnterPlayerList[~p]", [New_OwnerMap, EnterPlayerList] ),
						
						NewParam = setelement( 1, Param, true ),
						NewTargetMapInfo = setelement( 5, TargetMapInfo, NewParam ),
						NewMap#mapObject.pid ! { getReadyToEnterMap_CanEnter, FromPID, OwnerID, EnterPlayerList, NewTargetMapInfo },
						ok;
					?Map_Type_Normal_Guild->%%一般仙盟地图
						ok;
					_->throw(-1)
				end,

				ok
		end,
		
		ok
	catch
		return->ok;
		_->FromPID ! { getReadyToEnterMap_Result, self(), OwnerID, EnterPlayerList, TargetMapInfo, {false, ?EnterMap_Fail_Invalid_Call } }
	end.

%%队伍建立
on_teamMsg_Created( TeamID, TeamLeader )->
	try
		OldOwnerMap = etsBaseFunc:readRecord( ?MODULE:getOwnerIDTable(), TeamID ),
		case OldOwnerMap of
			{}->ok;
			_->throw(-1)
		end,
		
		LeaderOwnerMap = etsBaseFunc:readRecord( ?MODULE:getOwnerIDTable(), TeamLeader ),
		case LeaderOwnerMap of
			{}->ok;
			_->
				etsBaseFunc:deleteRecord( ?MODULE:getOwnerIDTable(), TeamLeader ),
				
				NewOwnerMap = setelement( #ownerMap.ownerID, LeaderOwnerMap, TeamID ),
				
				?DEBUG_OUT( "on_teamMsg_Created NewOwnerMap[~p]", [NewOwnerMap] ),
				
				etsBaseFunc:insertRecord( ?MODULE:getOwnerIDTable(), NewOwnerMap )
		end,

		ok
	catch
		_->ok
	end.

%%队伍新进入
on_teamMsg_Join( TeamID, JoinPlayerID )->
	try
		mergeOwnerMap( JoinPlayerID, TeamID ),
		ok
	catch
		_->ok
	end.

%%队伍解散
on_teamMsg_Disband( TeamID, TeamLeader )->
	try
		mergeOwnerMap( TeamID, TeamLeader ),
		ok
	catch
		_->ok
	end.

%%合并两个副本拥有者
mergeOwnerMap( FromOwnerID, ToOwnerID )->
	try
		FromOwnerMap = etsBaseFunc:readRecord( ?MODULE:getOwnerIDTable(), FromOwnerID ),
		case FromOwnerMap of
			{}->throw(-1);
			_->ok
		end,
		
		ToOwnerMap = etsBaseFunc:readRecord( ?MODULE:getOwnerIDTable(), ToOwnerID ),
		case ToOwnerMap of
			{}->
				etsBaseFunc:deleteRecord( ?MODULE:getOwnerIDTable(), FromOwnerID ),
				
				NewOwnerMap = setelement( #ownerMap.ownerID, FromOwnerMap, ToOwnerID ),
				
				?DEBUG_OUT( "mergeOwnerMap FromOwnerID[~p], ToOwnerID[~p] ToOwnerMap={} NewOwnerMap[~p]", 
							[FromOwnerID, ToOwnerID, NewOwnerMap] ),
				
				etsBaseFunc:insertRecord( ?MODULE:getOwnerIDTable(), NewOwnerMap ),
				ok;
			_->
				put( "mergeOwnerMap_ToOwnerMap", ToOwnerMap#ownerMap.mapIDList ),
				put( "mergeOwnerMap_FromOwnerMap", FromOwnerMap#ownerMap.mapIDList ),
				
				MyFunc = fun( Record )->
								 FromMap = etsBaseFunc:readRecord( ?MODULE:getMapTable(), Record ),
								 case FromMap of
									 {}->DeleteFrom=true;
									 _->
										 MyFunc2 = fun( Value, FindValue )->
														   ValueMap = etsBaseFunc:readRecord( ?MODULE:getMapTable(), Value ),
														   case ValueMap of
															   {}->false;
															   _->ValueMap#mapObject.map_data_id =:= FindValue
														   end
												   end,
										 New_ToOwnerMap = get( "mergeOwnerMap_ToOwnerMap" ),
										 { Find, _FindValue } = common:findInList( New_ToOwnerMap, FromMap#mapObject.map_data_id, MyFunc2 ),
										 case Find of
											 true->DeleteFrom=false;
											 false->DeleteFrom=true	 
										 end
								 end,
								 case DeleteFrom of
									 true->
										 New_FromOwnerMap = get( "mergeOwnerMap_FromOwnerMap" ),
										 put( "mergeOwnerMap_FromOwnerMap", New_FromOwnerMap -- [Record] ),
										 
										 New_ToOwnerMap2 = get( "mergeOwnerMap_ToOwnerMap" ),
										 put( "mergeOwnerMap_ToOwnerMap", New_ToOwnerMap2 ++ [Record] );
									 false->ok
								 end
						 end,
				lists:foreach( MyFunc, FromOwnerMap#ownerMap.mapIDList ),
				
				case get( "mergeOwnerMap_FromOwnerMap" ) of
					[]->
						?DEBUG_OUT( "mergeOwnerMap FromOwnerID[~p], ToOwnerID[~p] deleteRecord FromOwnerID", [FromOwnerID, ToOwnerID] ),
						etsBaseFunc:deleteRecord( ?MODULE:getOwnerIDTable(), FromOwnerID );
					New->
						?DEBUG_OUT( "mergeOwnerMap FromOwnerID[~p], ToOwnerID[~p] changeFiled FromOwnerID[~p]", [FromOwnerID, ToOwnerID, New] ),
						etsBaseFunc:changeFiled( ?MODULE:getOwnerIDTable(), FromOwnerID, #ownerMap.mapIDList, New )
				end,
				
				?DEBUG_OUT( "mergeOwnerMap FromOwnerID[~p], ToOwnerID[~p] changeFiled mergeOwnerMap_ToOwnerMap[~p]", [FromOwnerID, ToOwnerID, get( "mergeOwnerMap_ToOwnerMap" )] ),
				
				etsBaseFunc:changeFiled( ?MODULE:getOwnerIDTable(), ToOwnerID, #ownerMap.mapIDList, get( "mergeOwnerMap_ToOwnerMap" ) )
		end,
		ok
	catch
		_->ok
	end.


%%杀死世界boss
on_KillWorldBoss(BossID,MapID)->
	?DEBUG_OUT( "mapManager on_KillWorldBoss"),
	Q = ets:fun2ms( fun(#mapObject{id='_', map_data_id=MapDataIDDB} = Record ) when ( MapDataIDDB=:=MapID ) -> Record end),
	Ret = ets:select(getMapTable(), Q),
	case Ret of
		[]->
			ok;
		_->
			lists:foreach(fun(MapObject)->
				MapObject#mapObject.pid!{killWorldBoss,BossID}
			end
			, Ret)
	end.


%%刷新世界boss
on_WorldBossBegin(MapID)->
	?DEBUG_OUT( "mapManager on_WorldBossBegin"),
	Q = ets:fun2ms( fun(#mapObject{id='_', map_data_id=MapDataIDDB} = Record ) when ( MapDataIDDB=:=MapID ) -> Record end),
	Ret = ets:select(getMapTable(), Q),
	case Ret of
		[]->
			MapObject=on_createMap( MapID, ?Object_Type_System, ?Global_Object_System_ID ),
			MapObject#mapObject.pid!{woldBossBegin};
		_->
			lists:foreach(fun(MapObject)->
				MapObject#mapObject.pid!{woldBossBegin}
			end
			, Ret)
	end.
on_WorldBossAddExp( MapID )->
	%%?DEBUG_OUT( " mapManager on_WorldBossAddExp"),
	MapObject = getMapByID( MapID ),
	Q = ets:fun2ms( fun(#mapObject{id='_', map_data_id=MapDataIDDB} = Record ) when ( MapDataIDDB=:=MapID ) -> Record end),
	Ret = ets:select(getMapTable(), Q),
	case Ret of
		[]->
			MapObject=on_createMap( MapID, ?Object_Type_System, ?Global_Object_System_ID ),
			MapObject#mapObject.pid!{worldBossAddExp};
		_->
			lists:foreach(fun(MapObject)->
				MapObject#mapObject.pid!{worldBossAddExp}
			end
			, Ret)
	end.

on_WorldBossKill( MapID )->
?DEBUG_OUT( " mapManager on_WorldBossKill"),
	MapObject = getMapByID( MapID ),
	Q = ets:fun2ms( fun(#mapObject{id='_', map_data_id=MapDataIDDB} = Record ) when ( MapDataIDDB=:=MapID ) -> Record end),
	Ret = ets:select(getMapTable(), Q),
	case Ret of
		[]->
			MapObject=on_createMap( MapID, ?Object_Type_System, ?Global_Object_System_ID ),
			MapObject#mapObject.pid!{on_WorldBossKill};
		_->
			lists:foreach(fun(MapObject)->
				MapObject#mapObject.pid!{on_WorldBossKill}
			end
			, Ret)
	end.

on_BattleBalance(MapID)->
	Q = ets:fun2ms( fun(#mapObject{id='_', map_data_id=MapDataIDDB} = Record ) when ( MapDataIDDB=:=MapID ) -> Record end),
	Ret = ets:select(getMapTable(), Q),
	case Ret of
		[]->
			ok;
		_->
			lists:foreach(fun(MapObject)->
				MapObject#mapObject.pid!{battleBalance}
			end
			, Ret)
	end,
	ok.

on_playerMapMsg_ResetCopyMap( PlayerID, OwnerID, MapDataID )->
	try
		OwnerMap = etsBaseFunc:readRecord( ?MODULE:getOwnerIDTable(), OwnerID ),
		case OwnerMap of
			{}->throw( {return, ?EnterMap_Fail_ResetNomap} );
			_->ok
		end,
		case OwnerMap#ownerMap.mapIDList of
			[]->throw( {return, ?EnterMap_Fail_ResetNomap} );
			_->ok
		end,
		
		MyFunc = fun( Record )->
						 FromMap = etsBaseFunc:readRecord( ?MODULE:getMapTable(), Record ),
						 case FromMap of
							 {}->ok;
							 _->
								 case FromMap#mapObject.map_data_id =:= MapDataID of
									 true->
										 FromMap#mapObject.pid ! { mapManagerMsg_ResetCopyMap, PlayerID },
										 ?DEBUG_OUT( "on_playerMapMsg_ResetCopyMap PlayerID[~p], OwnerID[~p], MapDataID[~p] to map[~p]",
													 [PlayerID, OwnerID, MapDataID, FromMap] ),
										 throw( { return } );
									 false->ok
								 end
						 end
				 end,
		lists:foreach( MyFunc, OwnerMap#ownerMap.mapIDList ),
		
		?DEBUG_OUT( "on_playerMapMsg_ResetCopyMap PlayerID[~p], OwnerID[~p], MapDataID[~p] can not find map",
					 [PlayerID, OwnerID, MapDataID] ),
		ok
	catch
		{ return, Fail_Code }->
			ToUser = #pk_GS2U_EnterMapResult{ result=Fail_Code },
			player:sendToPlayer(PlayerID, ToUser );
		{ return }->ok
	end.






