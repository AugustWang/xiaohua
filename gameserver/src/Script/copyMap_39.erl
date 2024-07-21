%% Author: wenziyong
%% Created: 2013-1-28
%% Description: TODO: Add description to monster
-module(copyMap_39).

-include("db.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("monsterDefine.hrl").
-include("scriptDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 

%%碧潭梦境


-record( copyMap_39_data, {
						    %%39号副本地图的DataID,将根据地图的配置文件进行调整
						   	copy_Map_39_ID =  39,
						   	%%BOSS
						   	boss_ID =  272,

							%%传送点ID，TransportDataID,
							transport_ID = 1,
							%%传送点坐标用boss死的位置
							%%传送点x坐标
							transport_PosX = 2300,
							%%传送点y坐标
							transport_PosY = 310
						   } 
	   ).

	
init()->
	%% 注意此函数的执行与副本进程不是在同一进程 
	CopyMap_39_data = #copyMap_39_data{},
	scriptManager:registerScript( ?Object_Type_Map, CopyMap_39_data#copyMap_39_data.copy_Map_39_ID, ?Map_Event_Init, 
								  ?MODULE, map_39_Map_Event_Init, 0 ),
	

	%%注册，BOSS的出生事件
	scriptManager:registerScript( ?Object_Type_Monster, CopyMap_39_data#copyMap_39_data.boss_ID, ?Monster_Event_Init, 
								  ?MODULE, copyMap_39__Boss__Monster_Event_Init, 0 ),

	
	ok.

map_39_Map_Event_Init( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "map_39_Map_Event_Init" ),
	put( "copyMap_39_data", #copyMap_39_data{} ),
	put("copyMap_39__HasRefresh_Transport",false),
	
	ok.

%%BOSS 的出生事件的出生事件
copyMap_39__Boss__Monster_Event_Init( Object, _EventParam, _RegParam )->
	%%检查配置是否一致
	MonsterDataID = Object#mapMonster.monster_data_id,	
	CopyMap_39_data = get( "copyMap_39_data" ),
	put("copyMap_39_Boss_ID", Object#mapMonster.id),
	case MonsterDataID =:=CopyMap_39_data#copyMap_39_data.boss_ID of
		true->ok;
		false->?DEBUG_OUT( "CopyMap_39_data#copyMap_39_data.boss_ID configure error" )
    end,
	
	%%注册，BOSS死亡事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_Dead, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_39__Boss__Monster_Event_Dead, 
									0 ),
	ok.

%%BOSS 死亡事件
copyMap_39__Boss__Monster_Event_Dead( Object, _EventParam, _RegParam )->
	%%刷传送点
	case get("copyMap_39__HasRefresh_Transport") of
		false->
			CnfData = get( "copyMap_39_data" ),

			%%设置无人地图销毁时间
			map:setCopyMapNoPlayerDetroyTime( 1 ),
				
			MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), CnfData#copyMap_39_data.copy_Map_39_ID ),

			scriptCommon:refresh_New_Transport( CnfData#copyMap_39_data.transport_ID,
												CnfData#copyMap_39_data.transport_PosX, 
												CnfData#copyMap_39_data.transport_PosY,
												MapCfg#mapCfg.quitMapID,
												MapCfg#mapCfg.quitMapPosX,
												MapCfg#mapCfg.quitMapPosY ),

			put("copyMap_39__HasRefresh_Transport",true),
						%%结算副本
			map:onCopyMapSettleAccounts();
		true->ok
	end,
	
	ok.
