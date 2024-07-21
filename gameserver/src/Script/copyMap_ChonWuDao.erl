%% Author: wenziyong
%% Created: 2013-1-28
%% Description: TODO: Add description to monster
-module(copyMap_ChonWuDao).

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



-record( copyMap_ChonWuDao_Cfg, {
								  chonWuDao_Lv30_Map = 30,

								   chonWuDao_Lv40_Map = 31,

								  chonWuDao_Lv50_Map = 32,

								   chonWuDao_Lv60_Map = 33,
								  
								  transport_ID	= 1,
								  
								  transport_PosX = 1833,
								  
								  transport_PosY = 1181
			}).


init()->
	%% æ³¨ææ­¤å½æ°çæ§è¡ä¸å¯æ¬è¿ç¨ä¸æ¯å¨åä¸è¿ç¨ 
	CopyMap_ChonWuDao_Cfg = #copyMap_ChonWuDao_Cfg{},
	Fun = fun(Index) ->
				Map_DataID = element(Index, CopyMap_ChonWuDao_Cfg),
				%%æ³¨åå¯æ¬åå§åäºä»¶ï¼éå å¼ä¸ºå¯æ¬éç½®æ°æ®
				scriptManager:registerScript( ?Object_Type_Map, Map_DataID, ?Map_Event_Init, 
								  ?MODULE, map_ChonWuDao_Map_Event_Init, Map_DataID )
			end,
	common:for(#copyMap_ChonWuDao_Cfg.chonWuDao_Lv30_Map, #copyMap_ChonWuDao_Cfg.chonWuDao_Lv60_Map, Fun),
	
	ok.

map_ChonWuDao_Map_Event_Init( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "map_ChonWu_Map_Event_Init" ),
	put( "copyMap_ChonWu_data", _RegParam ),
	put("copyMap_ChonWu_HasRefresh_Transport",false),
	
	objectEvent:registerObjectEvent(_Object, 
									?Map_Event_Char_Dead, 
									?Object_Type_Map, 
									_RegParam, 
									?MODULE, 
									map_ChonWuDao_Map_Event_Char_Dead, 0),

	ok.

map_ChonWuDao_Map_Event_Char_Dead( _Object, _EventParam, _RegParam )->
	case get("copyMap_ChonWu_HasRefresh_Transport") of
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
								%%è®¾ç½®æ äººå°å¾éæ¯æ¶é´
								map:setCopyMapNoPlayerDetroyTime( 1 ),
				
								MapData = #copyMap_ChonWuDao_Cfg{},
				
								MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), get( "copyMap_ChonWu_data" ) ),

								scriptCommon:refresh_New_Transport( MapData#copyMap_ChonWuDao_Cfg.transport_ID,
															MapData#copyMap_ChonWuDao_Cfg.transport_PosX, 
															MapData#copyMap_ChonWuDao_Cfg.transport_PosY,
															MapCfg#mapCfg.quitMapID,
															MapCfg#mapCfg.quitMapPosX,
															MapCfg#mapCfg.quitMapPosY ),
			
								put("copyMap_ChonWu_HasRefresh_Transport", true),
								%%结算副本
								map:onCopyMapSettleAccounts();
						_->ok
					end
			end;
		_->ok
	end.
