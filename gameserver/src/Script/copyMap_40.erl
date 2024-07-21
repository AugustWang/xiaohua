%% Author: wenziyong
%% Created: 2013-1-28
%% Description: TODO: Add description to monster
-module(copyMap_40).

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
%%boss剧毒蟾王 永久保持自身周围带中毒AOE.


-record( copyMap_40_data, {
						    %%40号副本地图的DataID,将根据地图的配置文件进行调整
						   	copy_Map_40_ID =  40,
						   	%%BOSS
						   	boss_ID =  280,
							
							%%群攻AOE技能ID
							skill_ID = 5038,
							%%技能释放间隔
							skill_Interval = 1500,

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
	CopyMap_40_data = #copyMap_40_data{},
	scriptManager:registerScript( ?Object_Type_Map, CopyMap_40_data#copyMap_40_data.copy_Map_40_ID, ?Map_Event_Init, 
								  ?MODULE, map_40_Map_Event_Init, 0 ),
	

	%%注册，BOSS的出生事件
	scriptManager:registerScript( ?Object_Type_Monster, CopyMap_40_data#copyMap_40_data.boss_ID, ?Monster_Event_Init, 
								  ?MODULE, copyMap_40__Boss__Monster_Event_Init, 0 ),

	
	ok.

map_40_Map_Event_Init( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "map_40_Map_Event_Init" ),
	put( "copyMap_40_data", #copyMap_40_data{} ),
	put("copyMap_40__HasRefresh_Transport",false),
	
	ok.

%%BOSS 的出生事件的出生事件
copyMap_40__Boss__Monster_Event_Init( Object, _EventParam, _RegParam )->
	%%检查配置是否一致
	MonsterDataID = Object#mapMonster.monster_data_id,	
	CopyMap_40_data = get( "copyMap_40_data" ),
	put("copyMap_40_Boss_ID", Object#mapMonster.id),
	put("boss_Skill_UseTime", 0),
	case MonsterDataID =:=CopyMap_40_data#copyMap_40_data.boss_ID of
		true->ok;
		false->?DEBUG_OUT( "CopyMap_40_data#copyMap_40_data.boss_ID configure error" )
    end,
	
	%%注册，BOSS死亡事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_Dead, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_40__Boss__Monster_Event_Dead, 
									0 ),
	
	%%注册事件Monster_Event_FightHeart,战斗中来选择技能
	objectEvent:registerObjectEvent(Object, 
									?Monster_Event_FightHeart, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_40__Event_FightHeart, 
									0 ),
	ok.

copyMap_40__Event_FightHeart( Object, _EventParam, _RegParam )->
	CopyMap_40_data = get( "copyMap_40_data" ),
	Time = get("boss_Skill_UseTime"),
	Now = common:milliseconds(),
	try
		%%本boss的群攻技能没有不计算GCD

		case Now - Time >= CopyMap_40_data#copyMap_40_data.skill_Interval of
			true->
				SkillCfg = etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), CopyMap_40_data#copyMap_40_data.skill_ID),
				case SkillCfg of
					{}->throw(none);
					_->ok
				end,
				Pos = map:getObjectPos(Object),
				case scriptCommon:scriptUseSkill(Object, {}, SkillCfg, Pos#posInfo.x, Pos#posInfo.y, -1, false) of
					true->
						put("boss_Skill_UseTime", Now),
						throw(none);
					_->throw(none)
				end;
			_->throw(none)
		end,
		
		throw(none)

	catch
		Return->{ eventCallBackReturn, Return }
end.


%%BOSS 死亡事件
copyMap_40__Boss__Monster_Event_Dead( Object, _EventParam, _RegParam )->
	%%刷传送点
	case get("copyMap_40__HasRefresh_Transport") of
		false->
			CnfData = get( "copyMap_40_data" ),

			%%设置无人地图销毁时间
			map:setCopyMapNoPlayerDetroyTime( 1 ),
				
			MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), CnfData#copyMap_40_data.copy_Map_40_ID ),

			scriptCommon:refresh_New_Transport( CnfData#copyMap_40_data.transport_ID,
												CnfData#copyMap_40_data.transport_PosX, 
												CnfData#copyMap_40_data.transport_PosY,
												MapCfg#mapCfg.quitMapID,
												MapCfg#mapCfg.quitMapPosX,
												MapCfg#mapCfg.quitMapPosY ),

			put("copyMap_40__HasRefresh_Transport",true),
						%%结算副本
			map:onCopyMapSettleAccounts();
		true->ok
	end,
	
	ok.
