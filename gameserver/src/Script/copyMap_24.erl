%% Author: wenziyong
%% Created: 2013-1-23
%% Description: TODO: Add description to monster
-module(copyMap_24).

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

%% 树海副本 （英雄）

%   树根缠绕:会残绕仇恨列表内所有玩家和宠物目标.让目标长时间无法移动,但可以攻击和释放技能. 触发条件： 定时触发，进入战斗后首次t1秒触发，非首次t2秒触发，
%        仇恨列表内所有玩家和宠物目标add buff(无法移动)  
%	大地震击:古树老人施放大地震击,对自己周围范围内的目标造成伤害,并眩晕目标. 触发条件： 定时触发，进入战斗后首次t1秒触发，非首次t2秒触发。
%         AOE内的目标造成伤害，add buff(眩晕)

%	巨石投掷:古树老人会在释放树根缠绕后t内对仇恨列表内随机目标投掷石头.石头为定点范围AOE伤害.石头的飞行速度较慢.玩家可以移动躲避.
%		对目标点释放的范围攻击技能


-record( copyMap_24_data, {
						    %%24号副本地图的DataID,将根据地图的配置文件进行调整
						   	copy_Map_24_ID =  24,
						   	%%古树老人的幻象（ID：23）(BOSS)
						   	boss_ID =  188,
							
							%%树根缠绕，技能ID
							tree_Root_Bind_Skill_Id = 5006,		
							%%树根缠绕，进入战斗后多长时间首次触发
							tree_Root_Bind_First_Interval = 3000,		
							%%树根缠绕，进入战斗后非首次触发的间隔时间
							tree_Root_Bind_Interval = 3000,
							
							%%大地震击，技能ID
							earth_Shake_Skill_Id = 5007,	
							%%大地震击，进入战斗后多长时间首次触发
							earth_Shake_First_Interval = 30000,		
							%%大地震击，进入战斗后非首次触发的间隔时间
							earth_Shake_Interval = 20000,

							%%巨石投掷，技能ID
							stone_Cast_Skill_Id = 5009,		
							%%巨石投掷，在释放树根缠绕多长时间后触发
							stone_Cast_After_Bind_Interval = 3000,
						  
						    %%传送点ID，TransportDataID,
							transport_ID = 5,
							%%传送点坐标用boss死的位置
							%%传送点x坐标
							transport_PosX = 835,
							%%传送点y坐标
							transport_PosY = 1055
						   } 
	   ).



-record( copyMap_24_time, {next_tree_Root_Bind_Triger_time,	next_Earth_Shake_Triger_time,next_Stone_Cast_Triger_time,
						    last_Attack_Triger_time} 
	   ).

init()->
	%% 注意此函数的执行与副本进程不是在同一进程 
	CopyMap_24_data = #copyMap_24_data{},
	scriptManager:registerScript( ?Object_Type_Map, CopyMap_24_data#copyMap_24_data.copy_Map_24_ID, ?Map_Event_Init, 
								  ?MODULE, map_24_Map_Event_Init, 0 ),
	

	%%注册，古树老人的幻象(BOSS)的出生事件
	scriptManager:registerScript( ?Object_Type_Monster, CopyMap_24_data#copyMap_24_data.boss_ID, ?Monster_Event_Init, 
								  ?MODULE, copyMap_24__Boss__Monster_Event_Init, 0 ),
	
	ok.

map_24_Map_Event_Init( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "map_24_Map_Event_Init" ),
	put( "copyMap_24_data", #copyMap_24_data{} ),
	put("copyMap_24__HasRefresh_Transport",false),

	
	ok.

%%BOSS 古树老人的幻象的出生事件的出生事件
copyMap_24__Boss__Monster_Event_Init( Object, _EventParam, _RegParam )->
	%%检查配置是否一致
	MonsterDataID = Object#mapMonster.monster_data_id,	
	CopyMap_24_data = get( "copyMap_24_data" ),
	case MonsterDataID =:= CopyMap_24_data#copyMap_24_data.boss_ID of
		true->ok;
		false->?ERROR_OUT( "CopyMap_24_data#copyMap_24_data.boss_ID configure error" )
    end,	

	%%注册，BOSS古树老人的死亡事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_Dead, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_24__Boss__Monster_Event_Dead, 
									0 ),
	
	%%注册进入战斗状态事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_EnterFightState, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_24__Boss__Char_Event_EnterFightState, 
									0 ),
	%%注册事件Monster_Event_FightHeart,战斗中来选择技能
	objectEvent:registerObjectEvent(Object, 
									?Monster_Event_FightHeart, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_24__Event_FightHeart, 
									0 ),
	ok.


%%BOSS古树老人的幻象 进入战斗状态事件
copyMap_24__Boss__Char_Event_EnterFightState( _Object, _EventParam, _RegParam )->
	CnfData = get( "copyMap_24_data" ),
	Now = common:milliseconds(),

	put( "copyMap_24_time", 
	 	#copyMap_24_time{next_tree_Root_Bind_Triger_time=Now + CnfData#copyMap_24_data.tree_Root_Bind_First_Interval,	
	 	next_Earth_Shake_Triger_time=Now + CnfData#copyMap_24_data.earth_Shake_First_Interval,
	 	next_Stone_Cast_Triger_time=0,last_Attack_Triger_time=Now}),
	
	ok.

%%BOSS古树老人的幻象 选择技能 -> { eventCallBackReturn, {skillid,SkillID} } or { eventCallBackReturn, none }
copyMap_24__Event_FightHeart( _Object, _EventParam, _RegParam )->
	CfgData = get( "copyMap_24_data" ),
	Times = get( "copyMap_24_time" ),
	%Now = common:milliseconds(),
	NowTime = erlang:now(),
	Now = common:millisecondsByTime(NowTime),
	%put("copyMap_24__Event_FightHeart_ret",{ eventCallBackReturn, none }),
	try
		%% 判断公共
		CommonCD = timer:now_diff( NowTime, _Object#mapMonster.lastUsePhysicAttackTime )/1000,
		case CommonCD > array:get(?attack_speed, _Object#mapMonster.finalProperty) of
			true->
				ok;
			false->
				throw( none )
		end,
		
		%% 判断巨石投掷能否可用，巨石投掷（对仇恨列表中一个随机目标使用的群攻技能）
		case (Times#copyMap_24_time.next_Stone_Cast_Triger_time =/= 0) andalso (Now >= Times#copyMap_24_time.next_Stone_Cast_Triger_time) of
			true->
				case etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), CfgData#copyMap_24_data.stone_Cast_Skill_Id) of
					{}->ok;
					SkillCfg->
						Target = objectHatred:getRandomHatredTarget(map:getObjectID(_Object)),
						case Target of
							{}->ok;
							_->
								TargetPos = map:getObjectPos(Target),
								case scriptCommon:scriptUseSkill(_Object, Target, SkillCfg, 
														 TargetPos#posInfo.x, 
														 TargetPos#posInfo.y, -1, false) of
									true->
										%%技能释放成功
										NewTimes1 = Times#copyMap_24_time{next_Stone_Cast_Triger_time=0,last_Attack_Triger_time=Now},
										put( "copyMap_24_time", NewTimes1),
										throw( none );
									follow->throw( none );
									_->ok
								end
						end
				end;
			false->ok
		end,
		
		
		%% 判断树根缠绕能否可用，树根缠绕（以自身为中心，对固定范围内的敌对目标产生效果）
		case Now >=  Times#copyMap_24_time.next_tree_Root_Bind_Triger_time of
			true->
				case etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), CfgData#copyMap_24_data.tree_Root_Bind_Skill_Id) of
					{}->ok;
					SkillCfg2->
						SelfPos = map:getObjectPos(_Object),
						case scriptCommon:scriptUseSkill(_Object, {}, SkillCfg2, 
														 SelfPos#posInfo.x, 
														 SelfPos#posInfo.y, -1, false) of
							true->
								%%技能释放成功
								NewTimes2 = Times#copyMap_24_time{next_tree_Root_Bind_Triger_time = Now + CfgData#copyMap_24_data.tree_Root_Bind_Interval,
																  next_Stone_Cast_Triger_time = Now + CfgData#copyMap_24_data.stone_Cast_After_Bind_Interval,
																   last_Attack_Triger_time=Now},
								put( "copyMap_24_time", NewTimes2),
								throw( none );
							follow->
								throw(none);
							_->ok
						end
				end;
			false->ok
		end,
		

		%% 判断大地震击能否可用，大地震击（以自身为中心的对敌对目标使用的群攻技能）
		case Now >= Times#copyMap_24_time.next_Earth_Shake_Triger_time  of
			true->
				case etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), CfgData#copyMap_24_data.earth_Shake_Skill_Id) of
					{}->ok;
					SkillCfg3->
						SelfPos3 = map:getObjectPos(_Object),
						case scriptCommon:scriptUseSkill(_Object, _Object, SkillCfg3, 
														 SelfPos3#posInfo.x, 
														 SelfPos3#posInfo.y, -1, false) of
							true->
								NewTimes3 = Times#copyMap_24_time{
																  next_Earth_Shake_Triger_time = Now + CfgData#copyMap_24_data.earth_Shake_Interval,
																  last_Attack_Triger_time=Now},
								put( "copyMap_24_time", NewTimes3),
								throw(none);
							follow->
								throw(none);
							_->ok
						end
				end;
			false->ok
		end,
		
		throw(-1)
	
	catch
		Return->{ tree_Root_Bind_Skill_Id, Return }
	end.


%%返回Monster与Target的距离SQ
getTargetPos( Target )->
	case element(1, Target) of
		mapPlayer->
			X = Target#mapPlayer.pos#posInfo.x,
			Y = Target#mapPlayer.pos#posInfo.y,
			{X,Y};
		mapMonster->
			X = Target#mapMonster.pos#posInfo.x,
			Y = Target#mapMonster.pos#posInfo.y,
			{X,Y};
		mapPet->
			X = Target#mapPet.pos#posInfo.x,
			Y = Target#mapPet.pos#posInfo.y,
			{X,Y};
		_->{}
			
	end.



%%BOSS死亡事件
copyMap_24__Boss__Monster_Event_Dead( Object, _EventParam, _RegParam )->
	%%刷传送点
	case get("copyMap_24__HasRefresh_Transport") of
		false->
			CnfData = get( "copyMap_24_data" ),
			%%设置无人地图销毁时间
			map:setCopyMapNoPlayerDetroyTime( 1 ),
				
			MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), CnfData#copyMap_24_data.copy_Map_24_ID ),

			scriptCommon:refresh_New_Transport( CnfData#copyMap_24_data.transport_ID,
												CnfData#copyMap_24_data.transport_PosX, 
												CnfData#copyMap_24_data.transport_PosY,
												MapCfg#mapCfg.quitMapID,
												MapCfg#mapCfg.quitMapPosX,
												MapCfg#mapCfg.quitMapPosY ),
			put("copyMap_24__HasRefresh_Transport",true),
						%%结算副本
			map:onCopyMapSettleAccounts();
		true->ok
	end,
	
	ok.







