%% Author: wenziyong
%% Created: 2013-1-28
%% Description: TODO: Add description to monster
-module(copyMap_JinYinDao).

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

%% 1）遗迹宝箱
%% 遗迹宝箱是一个不可移动且无任何攻击里的NPC，可以被玩家击杀。当玩家成功击杀一个遗迹宝箱后该宝箱会有几率掉落非绑定钱币，以及各种稀有道具等物品，也有几率在原地刷新出一个遗迹大将。每个遗迹宝箱击杀后都会额外掉落一个物品“遗迹圣物”
%% 
%% 
%% 2）遗迹守卫
%% 遗迹守卫是副本内的小怪，击杀后会固定掉落物品“遗迹残片”；
%% 
%% 3）遗迹大将
%% 遗迹大将是副本内的精英怪，击杀后会必定掉落一个“遗迹币”。玩家可以收集该“遗迹币”在副本内指定NPC处换取心仪的物品；
%% 
%% 4）神秘商人
%% 玩家在遗迹副本内可以收集到“遗迹币”，一定数量的遗迹币可以在神秘商人处换取各种心仪实用的道具；

-record( copyMap_JinYinDao_data, {
						    %%22号副本地图的DataID,将根据地图的配置文件进行调整
						   	copy_Map_ID,
							%%遗迹宝箱怪物ID
							box_ID,
							%%遗迹大将ID
							general_ID,
							%%传送点ID，TransportDataID,
							transport_ID = 1,
							%%传送点x坐标
							transport_PosX = 2000,
							%%传送点y坐标
							transport_PosY = 150
						   }  ).

-record( copyMap_JinYinDao_Cfg, {
								   jinYinDao_Lv30_Map = #copyMap_JinYinDao_data{
																						copy_Map_ID=34,
																						box_ID = 258,
																						general_ID=259},

								   jinYinDao_Lv40_Map = #copyMap_JinYinDao_data{
																						copy_Map_ID=35,
																						box_ID = 262,
																						general_ID=263},

								   jinYinDao_Lv50_Map = #copyMap_JinYinDao_data{
																						copy_Map_ID=36,
																						box_ID = 266,
																						general_ID=267},

								   jinYinDao_Lv60_Map = #copyMap_JinYinDao_data{
																						copy_Map_ID=37,
																						box_ID = 270,
																						general_ID=271}
			}).


init()->
	%% 注意此函数的执行与副本进程不是在同一进程 
	CopyMap_JinYinDao_Cfg = #copyMap_JinYinDao_Cfg{},
	Fun = fun(Index) ->
				Map_Data = element(Index, CopyMap_JinYinDao_Cfg),
				%%注册副本初始化事件，附加值为副本配置数据
				scriptManager:registerScript( ?Object_Type_Map, Map_Data#copyMap_JinYinDao_data.copy_Map_ID, ?Map_Event_Init, 
								  ?MODULE, map_JinYinDao_Map_Event_Init, Map_Data ),

				%%注册遗迹宝箱出生事件
				scriptManager:registerScript( ?Object_Type_Monster, Map_Data#copyMap_JinYinDao_data.box_ID, ?Monster_Event_Init, 
								  ?MODULE, copyMap_JinYinDao_Box_Monster_Event_Init, 0 )
			end,
	common:for( #copyMap_JinYinDao_Cfg.jinYinDao_Lv30_Map, #copyMap_JinYinDao_Cfg.jinYinDao_Lv60_Map, Fun),
	
	ok.

map_JinYinDao_Map_Event_Init( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "map_JinYinDao_Map_Event_Init" ),
	put( "copyMap_JinYinDao_data", _RegParam ),
	put("copyMap_JinYinDao_HasRefresh_Transport",false),
	
	objectEvent:registerObjectEvent(_Object, 
									?Map_Event_Char_Dead, 
									?Object_Type_Map, 
									_RegParam#copyMap_JinYinDao_data.copy_Map_ID, 
									?MODULE, 
									map_JinYinDao_Map_Event_Char_Dead, 0),
	ok.

map_JinYinDao_Map_Event_Char_Dead( _Object, _EventParam, _RegParam )->
	case get("copyMap_JinYinDao_HasRefresh_Transport") of
		false->
			try
				Fun = fun(Monster)->
							  case map:isObjectDead(Monster) of
								  false->throw(true);
								  _->ok
							  end
					  end,
				etsBaseFunc:etsFor(map:getMapMonsterTable(), Fun),
				throw(false)
			catch
				HaveNotDead->
					case HaveNotDead of
						false->
								%%
								map:setCopyMapNoPlayerDetroyTime( 1 ),
				
								MapData = get( "copyMap_JinYinDao_data" ),
				
								MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(),  MapData#copyMap_JinYinDao_data.copy_Map_ID),

								scriptCommon:refresh_New_Transport( MapData#copyMap_JinYinDao_data.transport_ID,
															MapData#copyMap_JinYinDao_data.transport_PosX, 
															MapData#copyMap_JinYinDao_data.transport_PosY,
															MapCfg#mapCfg.quitMapID,
															MapCfg#mapCfg.quitMapPosX,
															MapCfg#mapCfg.quitMapPosY ),
			
								put("copyMap_JinYinDao_HasRefresh_Transport", true),
								%%结算副本
								map:onCopyMapSettleAccounts();
						_->ok
					end
			end;
		_->ok
	end.

%%遗迹宝箱的出生事件
copyMap_JinYinDao_Box_Monster_Event_Init( Object, _EventParam, _RegParam )->
	MapData = get("copyMap_JinYinDao_data"),
		
	%%注册遗迹宝箱的死亡事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_Dead, 
									?Object_Type_Monster, 
									MapData#copyMap_JinYinDao_data.box_ID, 
									?MODULE, 
									copyMap_JinYinDao_Box_Monster_Event_Dead, 
									0 ).

%%遗迹宝箱死亡事件
copyMap_JinYinDao_Box_Monster_Event_Dead( Object, _EventParam, _RegParam )->
	MapData = get("copyMap_JinYinDao_data"),
	case random:uniform(1) =:= 1 of
		true->
			Pos = map:getObjectPos(Object),
			%%刷出一个遗迹大将
			scriptCommon:createMonster(MapData#copyMap_JinYinDao_data.general_ID, Pos#posInfo.x, Pos#posInfo.y, 0);
		_->ok
	end,
	ok.