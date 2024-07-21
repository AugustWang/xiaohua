%% Author: wenziyong
%% Created: 2013-1-25
%% Description: TODO: Add description to monster
-module(copyMap_18).

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

%% 醉晴天副本

% BOSS月华的剑鞘(设定)
% 治愈剑阵:月华的剑鞘会在固定范围内随机位置施放一个范围治疗技能,技能持续一段时间，在剑气乱舞结束时结束 
%		触发条件： 定时触发，进入战斗后首次t1秒触发，非首次t2秒触发，
% 剑气乱舞:月华的剑鞘会在释放治愈剑阵后一段时间内释放 剑气乱舞.释放此技能时剑鞘会停止所有攻击定在原地，然后定时对大范围内的每个敌对目标造成伤害，持续一段时间.
%        给boss本身加buff(停止所有攻击定在原地), 然后给对大范围内的每个敌对目标(仇恨列表里的玩家)增加debuff: reduce blood
%        触发条件： 释放治愈剑阵后多长时间触发



-record( copyMap_18_data, {
						    %%18号副本地图的DataID,将根据地图的配置文件进行调整
						   	copy_Map_18_ID =  18,
						   	%%BOSS月华的剑鞘
						   	boss_ID =  32,
							
							%%治愈剑阵，技能ID
							sword_Rescue_Skill_Id = 5013,
							%%治愈剑阵，进入战斗后多长时间首次触发
							sword_Rescue_First_Interval = 20000,		
							%%治愈剑阵，进入战斗后非首次触发的间隔时间
							sword_Rescue_Interval = 15000,
							%%治愈剑阵，释放的固定点
							sword_Rescue_Pos = #posInfo{x=2479, y=2656},
							%%治愈剑阵，释放的半径
							sword_Rescue_Radius = 200,
							

							%%剑气乱舞，技能ID
							sword_Kill_Skill_Id = 5014,	
							%%剑气乱舞，在释放治愈剑阵多长时间后触发
							sword_Kill_After_Rescue_Interval = 500,
							
							%%传送点ID，TransportDataID,
							transport_ID = 6,
							%%传送点坐标用boss死的位置
							%%传送点x坐标
							transport_PosX = 2730,
							%%传送点y坐标
							transport_PosY = 2520
						   } 
	   ).



-record( copyMap_18_time, {next_Sword_Rescue_Triger_time,next_Sword_Kill_Triger_time,last_Attack_Triger_time} ).

init()->
	%% 注意此函数的执行与副本进程不是在同一进程 
	CopyMap_18_data = #copyMap_18_data{},
	scriptManager:registerScript( ?Object_Type_Map, CopyMap_18_data#copyMap_18_data.copy_Map_18_ID, ?Map_Event_Init, 
								  ?MODULE, map_18_Map_Event_Init, 0 ),
	

	%%注册，BOSS月华的剑鞘的出生事件
	scriptManager:registerScript( ?Object_Type_Monster, CopyMap_18_data#copyMap_18_data.boss_ID, ?Monster_Event_Init, 
								  ?MODULE, copyMap_18__Boss__Monster_Event_Init, 0 ),
	
	ok.

map_18_Map_Event_Init( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "map_18_Map_Event_Init" ),
	put( "copyMap_18_data", #copyMap_18_data{} ),
	put("copyMap_18__HasRefresh_Transport",false),
	
	ok.

%%BOSS BOSS月华的剑鞘的出生事件
copyMap_18__Boss__Monster_Event_Init( Object, _EventParam, _RegParam )->
	%%检查配置是否一致
	MonsterDataID = Object#mapMonster.monster_data_id,	
	CopyMap_18_data = get( "copyMap_18_data" ),
	case MonsterDataID =:= CopyMap_18_data#copyMap_18_data.boss_ID of
		true->ok;
		false->?ERROR_OUT( "CopyMap_18_data#copyMap_18_data.boss_ID configure error" )
    end,
	
	%%注册，BOSS的死亡事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_Dead, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_18__Boss__Monster_Event_Dead, 
									0 ),
	
	%%注册进入战斗状态事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_EnterFightState, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_18__Boss__Char_Event_EnterFightState, 
									0 ),
	%%注册事件Monster_Event_FightHeart,战斗中来选择技能
	objectEvent:registerObjectEvent(Object, 
									?Monster_Event_FightHeart, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_18__Event_FightHeart, 
									0 ),

	ok.


%%BOSS月华的剑鞘的出生事件 进入战斗状态事件
copyMap_18__Boss__Char_Event_EnterFightState( _Object, _EventParam, _RegParam )->
	CnfData = get( "copyMap_18_data" ),
	Now = common:milliseconds(),

	put( "copyMap_18_time", 
	 	#copyMap_18_time{next_Sword_Rescue_Triger_time=Now + CnfData#copyMap_18_data.sword_Rescue_First_Interval,	
	 	next_Sword_Kill_Triger_time=0,last_Attack_Triger_time=Now}),
	
	ok.

%%BOSS月华的剑鞘 攻击事件
copyMap_18__Event_FightHeart( _Object, _EventParam, _RegParam )->
	CfgData = get( "copyMap_18_data" ),
	Times = get( "copyMap_18_time" ),
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
				
		%% 判断剑气乱舞能否可用
		case (Times#copyMap_18_time.next_Sword_Kill_Triger_time =/= 0) andalso (Now >= Times#copyMap_18_time.next_Sword_Kill_Triger_time  ) of
			true->
				case etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), CfgData#copyMap_18_data.sword_Kill_Skill_Id ) of
					{}->ok;
					SkillCfg->
						SelfPos = map:getObjectPos(_Object),
						case scriptCommon:scriptUseSkill(_Object, _Object, SkillCfg, 
														 SelfPos#posInfo.x, 
														 SelfPos#posInfo.y, -1, false) of
							true->
								NewTimes1 = Times#copyMap_18_time{next_Sword_Kill_Triger_time=0,last_Attack_Triger_time=Now},
								put( "copyMap_18_time", NewTimes1),
								throw(none);
							follow->throw(none);
							_->ok
						end
				end;
			false->ok
		end,
		
		%% 判断治愈剑阵能否可用
		case Now >= Times#copyMap_18_time.next_Sword_Rescue_Triger_time   of
			true->
				case etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), CfgData#copyMap_18_data.sword_Rescue_Skill_Id) of
					{}->ok;
					SkillCfg2->
						%%随机一个位置
						Pos = scriptCommon:rand_Pos_ByPosAndRadius(
								CfgData#copyMap_18_data.sword_Rescue_Pos, 
								CfgData#copyMap_18_data.sword_Rescue_Radius ),
						case scriptCommon:scriptUseSkill(_Object, _Object, SkillCfg2, 
														 erlang:trunc(Pos#posInfo.x), erlang:trunc(Pos#posInfo.y), 
														 -1, false) of
							true->
								NewTimes2 = Times#copyMap_18_time{next_Sword_Rescue_Triger_time = Now + CfgData#copyMap_18_data.sword_Rescue_Interval,
																  next_Sword_Kill_Triger_time = Now + CfgData#copyMap_18_data.sword_Kill_After_Rescue_Interval, 
																  last_Attack_Triger_time=Now},
								put( "copyMap_18_time", NewTimes2),
								throw(none);
							follow->throw(none);
							_->ok
						end
				end;
			false->ok
		end,	
		
		throw( -1 )

	catch
		Return->{ eventCallBackReturn, Return }
	end.

%%BOSS 死亡事件
copyMap_18__Boss__Monster_Event_Dead( Object, _EventParam, _RegParam )->
	%%刷传送点
	case get("copyMap_18__HasRefresh_Transport") of
		false->
			CnfData = get( "copyMap_18_data" ),
			
			%%设置无人地图销毁时间
			map:setCopyMapNoPlayerDetroyTime( 1 ),
				
			MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), CnfData#copyMap_18_data.copy_Map_18_ID ),

			scriptCommon:refresh_New_Transport( CnfData#copyMap_18_data.transport_ID,
												CnfData#copyMap_18_data.transport_PosX, 
												CnfData#copyMap_18_data.transport_PosY,
												MapCfg#mapCfg.quitMapID,
												MapCfg#mapCfg.quitMapPosX,
												MapCfg#mapCfg.quitMapPosY ),
			
			put("copyMap_18__HasRefresh_Transport",true),
			%%结算副本
			map:onCopyMapSettleAccounts();
		true->ok
	end,
	
	ok.

