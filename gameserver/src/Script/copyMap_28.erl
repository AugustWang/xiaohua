%% Author: wenziyong
%% Created: 2013-1-28
%% Description: TODO: Add description to monster
-module(copyMap_28).

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

%% 船舶坟墓副本（英雄）
% 钩蛇BOSS设定
%	蛇钩:钩蛇在一定时间周期内会使用蛇钩攻击任意目标.对目标造成禁止移动效果.持续一段时间.
%       触发条件： 定时触发，进入战斗后首次t1秒触发，非首次t2秒触发，  
%       效果：add buf(禁止移动)
%	毒液:钩蛇会对任意目标施放毒液,毒液为范围AOE.站在毒液里的敌对目标持续掉血.持续一段时间.
%       触发条件： 定时触发，进入战斗后首次t1秒触发，非首次t2秒触发，
%       效果：AOE add buf(掉血)


-record( copyMap_28_data, {
						    %%28号副本地图的DataID,将根据地图的配置文件进行调整
						   	copy_Map_28_ID =  28,
						   	%%BOSS钩蛇的怨灵
						   	boss_ID =  212,
							
							%%蛇钩，技能ID 
							snake_Hook_Skill_Id = 5026,		
							%%蛇钩，进入战斗后多长时间首次触发
							snake_Hook_First_Interval = 20000,		
							%%蛇钩，进入战斗后非首次触发的间隔时间
							snake_Hook_Interval = 15000,
							
							%%毒液 ，技能ID 
							poison_Liquid_Skill_Id = 5027,
							%%毒液，进入战斗后多长时间首次触发
							poison_Liquid_First_Interval = 30000,		
							%%毒液，进入战斗后非首次触发的间隔时间
							poison_Liquid_Interval = 30000,

							%%传送点ID，TransportDataID,
							transport_ID = 9,
							%%传送点坐标用boss死的位置
							%%传送点x坐标
							transport_PosX = 2740,
							%%传送点y坐标
							transport_PosY = 1130
						   } 
	   ).

	
-record( copyMap_28_time, {next_Snake_Hook_Triger_time,next_Poison_Liquid_Triger_Blood,last_Attack_Triger_time} ).

init()->
	%% 注意此函数的执行与副本进程不是在同一进程 
	CopyMap_28_data = #copyMap_28_data{},
	scriptManager:registerScript( ?Object_Type_Map, CopyMap_28_data#copyMap_28_data.copy_Map_28_ID, ?Map_Event_Init, 
								  ?MODULE, map_28_Map_Event_Init, 0 ),
	

	%%注册，BOSS钩蛇的出生事件
	scriptManager:registerScript( ?Object_Type_Monster, CopyMap_28_data#copyMap_28_data.boss_ID, ?Monster_Event_Init, 
								  ?MODULE, copyMap_28__Boss__Monster_Event_Init, 0 ),
	
	ok.

map_28_Map_Event_Init( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "map_28_Map_Event_Init" ),
	put( "copyMap_28_data", #copyMap_28_data{} ),
	put("copyMap_28__HasRefresh_Transport",false),
	
	ok.

%%BOSS 的出生事件的出生事件
copyMap_28__Boss__Monster_Event_Init( Object, _EventParam, _RegParam )->
	%%检查配置是否一致
	MonsterDataID = Object#mapMonster.monster_data_id,	
	CopyMap_28_data = get( "copyMap_28_data" ),
	case MonsterDataID =:=CopyMap_28_data#copyMap_28_data.boss_ID of
		true->ok;
		false->?ERROR_OUT( "copyMap_28_data#copyMap_28_data.boss_ID configure error" )
    end,
	
	%%注册，BOSS死亡事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_Dead, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_28__Boss__Monster_Event_Dead, 
									0 ),
	
	
	%%注册进入战斗状态事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_EnterFightState, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_28__Boss__Char_Event_EnterFightState, 
									0 ),
	%%注册事件Monster_Event_FightHeart,战斗中来选择技能
	objectEvent:registerObjectEvent(Object, 
									?Monster_Event_FightHeart, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_28__Event_FightHeart, 
									0 ),
	%% 注册事件  技能效果,	
	
	ok.





%%BOSS钩蛇 进入战斗状态事件
copyMap_28__Boss__Char_Event_EnterFightState( _Object, _EventParam, _RegParam )->
	CnfData = get( "copyMap_28_data" ),
	Now = common:milliseconds(),

	put( "copyMap_28_time", 
	 	#copyMap_28_time{next_Snake_Hook_Triger_time=Now + CnfData#copyMap_28_data.snake_Hook_First_Interval,
						 next_Poison_Liquid_Triger_Blood=Now + CnfData#copyMap_28_data.poison_Liquid_First_Interval,
							 last_Attack_Triger_time=Now}),
	ok.



%%BOSS钩蛇 战斗AI
copyMap_28__Event_FightHeart( _Object, _EventParam, _RegParam )->
	CfgData = get( "copyMap_28_data" ),
	Times = get( "copyMap_28_time" ),
	%Now = common:milliseconds(),
	NowTime = erlang:now(),
	Now = common:millisecondsByTime(NowTime),
	try
		%% 判断公共
		CommonCD = timer:now_diff( NowTime, _Object#mapMonster.lastUsePhysicAttackTime )/1000,
		case CommonCD > array:get(?attack_speed, _Object#mapMonster.finalProperty) of
			true->
				ok;
			false->
				throw( none )
		end,
				

		%% 判断蛇钩能否可用
		case Now >= Times#copyMap_28_time.next_Snake_Hook_Triger_time   of
			true->
				case objectHatred:getRandomHatredTarget(map:getObjectID(_Object)) of
					{}->ok;
					Target->
						case etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), CfgData#copyMap_28_data.snake_Hook_Skill_Id) of
							{}->ok;
							SkillCfg->
								case scriptCommon:scriptUseSkill(_Object, Target, SkillCfg, 0, 0, -1, false) of
									true->
										NewTimes1 = Times#copyMap_28_time{next_Snake_Hook_Triger_time = Now + CfgData#copyMap_28_data.snake_Hook_Interval,
																		  last_Attack_Triger_time=Now},
										put( "copyMap_28_time", NewTimes1),
										throw( none );
									follow->throw( none );
									_->ok
								end
						end
				end;
			false->ok
		end,
		
		%% 判断毒液能否可用
		case Now >= Times#copyMap_28_time.next_Poison_Liquid_Triger_Blood  of
			true->
				case objectHatred:getRandomHatredTarget(map:getObjectID(_Object)) of
					{}->ok;
					Target2->
						case etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), CfgData#copyMap_28_data.poison_Liquid_Skill_Id) of
							{}->ok;
							SkillCfg2->
								TargetPos = map:getObjectPos(Target2),
								case scriptCommon:scriptUseSkill(_Object, Target2, SkillCfg2, 
																 TargetPos#posInfo.x, 
																 TargetPos#posInfo.y, -1, false) of
									true->
										NewTimes2 = Times#copyMap_28_time{next_Poison_Liquid_Triger_Blood = Now + CfgData#copyMap_28_data.poison_Liquid_Interval,
																		  last_Attack_Triger_time=Now},
										put( "copyMap_28_time", NewTimes2),
										throw(none);
									follow->throw(none);
									_->ok
								end
						end
				end;
			false->ok
		end,

		throw(-1)
	catch
		Return->{ eventCallBackReturn, Return }
	end.


%%BOSS 死亡事件
copyMap_28__Boss__Monster_Event_Dead( Object, _EventParam, _RegParam )->
	%%刷传送点
	case get("copyMap_28__HasRefresh_Transport") of
		false->
			CnfData = get( "copyMap_28_data" ),

			%%设置无人地图销毁时间
			map:setCopyMapNoPlayerDetroyTime( 1 ),
				
			MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), CnfData#copyMap_28_data.copy_Map_28_ID ),

			scriptCommon:refresh_New_Transport( CnfData#copyMap_28_data.transport_ID,
												CnfData#copyMap_28_data.transport_PosX, 
												CnfData#copyMap_28_data.transport_PosY,
												MapCfg#mapCfg.quitMapID,
												MapCfg#mapCfg.quitMapPosX,
												MapCfg#mapCfg.quitMapPosY ),
			
			put("copyMap_28__HasRefresh_Transport",true),
						%%结算副本
			map:onCopyMapSettleAccounts();
		true->ok
	end,
	
	ok.


