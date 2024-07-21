%% Author: wenziyong
%% Created: 2013-1-28
%% Description: TODO: Add description to monster
-module(copyMap_23).

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

%%百毒潭

% 魑魅BOSS设定:
%	毒云:BOSS会一段时间内对任意敌对目标施放毒云,毒云为范围AOE.站在毒云内会持续掉血.毒云的持续到战斗结束. (暂时没有实现，可以考虑刷出一个新的skill object,来实现)
%		触发条件： 定时触发，进入战斗后首次t1秒触发，非首次t2秒触发，  
%	召唤乌鸦:BOSS进入战斗后每隔一段时间会召唤两只乌鸦加入战斗.
%       触发条件： 定时触发，进入战斗后首次t1秒触发，非首次t2秒触发，
%		召唤两只乌鸦加入战斗: 魑魅出生时注册召唤乌鸦效果，在技能效果中调用ObjectEvent来触发此效果


-record( copyMap_23_data, {
						    %%23号副本地图的DataID,将根据地图的配置文件进行调整
						   	copy_Map_23_ID =  23,
						   	%%BOSS魑魅
						   	boss_ID =  117,
							
							%%毒云，技能ID 
							poison_Cloud_Skill_Id = 5032,		
							%%毒云，进入战斗后多长时间首次触发
							poison_Cloud_First_Interval = 10000,		
							%%毒云，进入战斗后非首次触发的间隔时间
							poison_Cloud_Interval = 15000,
							
							%%召唤乌鸦，技能ID 
							crow_Summon_Skill_Id = 5033,
							%%召唤乌鸦，进入战斗后多长时间首次触发
							crow_Summon_First_Interval = 20000,		
							%%召唤乌鸦，进入战斗后非首次触发的间隔时间
							crow_Summon_Interval = 20000,
							%%召唤乌鸦，召唤出来的乌鸦的个数 
							crow_Summon_Crow_Num = 2,		
							%%召唤出来的乌鸦的ID
							crow_Id = 229,	
							%%召唤出来的乌鸦在boss周围以半径为R的随机范围
							crow_R = 150,
							%%召唤出乌鸦的位置
							crow_Pos = #posInfo{x=1371, y=1700},


							%%传送点ID，TransportDataID,
							transport_ID = 1,
							%%传送点坐标用boss死的位置
							%%传送点x坐标
							transport_PosX = 1178,
							%%传送点y坐标
							transport_PosY = 1791
						   } 
	   ).

	
-record( copyMap_23_time, {next_Poison_Cloud_Triger_time,next_Crow_Summon_Triger_Blood,last_Attack_Triger_time} ).

init()->
	%% 注意此函数的执行与副本进程不是在同一进程 
	CopyMap_23_data = #copyMap_23_data{},
	scriptManager:registerScript( ?Object_Type_Map, CopyMap_23_data#copyMap_23_data.copy_Map_23_ID, ?Map_Event_Init, 
								  ?MODULE, map_23_Map_Event_Init, 0 ),
	

	%%注册，BOSS魑魅的出生事件
	scriptManager:registerScript( ?Object_Type_Monster, CopyMap_23_data#copyMap_23_data.boss_ID, ?Monster_Event_Init, 
								  ?MODULE, copyMap_23__Boss__Monster_Event_Init, 0 ),

	%%注册，召唤出的乌鸦出生事件
	scriptManager:registerScript(?Object_Type_Monster, CopyMap_23_data#copyMap_23_data.crow_Id, ?Monster_Event_Init, 
								  ?MODULE, copyMap_23__Crow__Monster_Event_Init, 0),
	
	ok.

map_23_Map_Event_Init( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "map_23_Map_Event_Init" ),
	put( "copyMap_23_data", #copyMap_23_data{} ),
	put("copyMap_23__HasRefresh_Transport",false),
	put("copyMap_23_Crow_List", []),
	put("copyMap_23_Boss_ID", 0),
	
	ok.

%%BOSS 的出生事件的出生事件
copyMap_23__Boss__Monster_Event_Init( Object, _EventParam, _RegParam )->
	%%检查配置是否一致
	MonsterDataID = Object#mapMonster.monster_data_id,	
	CopyMap_23_data = get( "copyMap_23_data" ),
	put("copyMap_23_Boss_ID", Object#mapMonster.id),
	case MonsterDataID =:=CopyMap_23_data#copyMap_23_data.boss_ID of
		true->ok;
		false->?ERROR_OUT( "CopyMap_23_data#copyMap_23_data.boss_ID configure error" )
    end,
	
	%%注册，BOSS死亡事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_Dead, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_23__Boss__Monster_Event_Dead, 
									0 ),
	
	%%注册进入战斗状态事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_EnterFightState, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_23__Boss__Char_Event_EnterFightState, 
									0 ),
	%%注册boss离开战斗状态事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_LeaveFightState, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_23__Boss__Char_Event_LeaveFightState, 
									0 ),

	%%注册boss新增仇恨对象事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_Add_Hatred_Object, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_23__Boss__Add_Hatred_Object, 
									0 ),

	%%注册事件Monster_Event_FightHeart,战斗中来选择技能
	objectEvent:registerObjectEvent(Object, 
									?Monster_Event_FightHeart, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_23__Event_FightHeart, 
									0 ),	
	%% 注册事件  技能效果	
	%%  注册召唤乌鸦效果
	objectEvent:registerObjectEvent(Object, 
									?Monster_Event_RefreshSmallMonsters, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_23__Event_RefreshSmallMonsters, 
									0 ),
	
	ok.

%%boss召唤的乌鸦出生事件
copyMap_23__Crow__Monster_Event_Init( Object, _EventParam, _RegParam )->
	CrowList = get("copyMap_23_Crow_List"),
	put("copyMap_23_Crow_List", CrowList++[Object#mapMonster.id]),

	CnfData = get( "copyMap_23_data" ),
	BossHatred = objectHatred:getObjectAllHatredTargets(get("copyMap_23_Boss_ID")),
	Func = fun(HartredObj)->
					  objectHatred:addHatredIntoObject(map:getObjectID(Object), map:getObjectID(HartredObj), 1)
			   end,
	lists:foreach(Func, BossHatred),
	ok.



%%BOSS  召唤乌鸦效果
copyMap_23__Event_RefreshSmallMonsters( Object, _EventParam, _RegParam )->
	case mapActorStateFlag:isStateFlag( map:getObjectID(Object), ?Actor_State_Flag_Fighting ) of
		true->
			CnfData = get( "copyMap_23_data" ),
			scriptCommon:rand_Refresh_New_Monsters_Around_Pos(
											CnfData#copyMap_23_data.crow_Pos,CnfData#copyMap_23_data.crow_R,CnfData#copyMap_23_data.crow_Id,
											CnfData#copyMap_23_data.crow_Summon_Crow_Num),
			ok;
		false->ok
	end,
	ok.
	




%%BOSS魑魅 进入战斗状态事件
copyMap_23__Boss__Char_Event_EnterFightState( _Object, _EventParam, _RegParam )->
	CnfData = get( "copyMap_23_data" ),
	Now = common:milliseconds(),

	put( "copyMap_23_time", 
	 	#copyMap_23_time{next_Poison_Cloud_Triger_time=Now + CnfData#copyMap_23_data.poison_Cloud_First_Interval,
						 next_Crow_Summon_Triger_Blood=Now + CnfData#copyMap_23_data.crow_Summon_First_Interval,
							 last_Attack_Triger_time=Now}),
	ok.

%%BOSS魑魅 离开战斗状态事件
copyMap_23__Boss__Char_Event_LeaveFightState( _Object, _EventParam, _RegParam )->
	Fun = fun(ID)->
				map:despellObject(ID, 0)
				end,
	lists:foreach(Fun, get("copyMap_23_Crow_List")),
	ok.

%%boss 新增仇恨对象事件
copyMap_23__Boss__Add_Hatred_Object( _Object, _EventParam, _RegParam )->
	Monsters = get( "copyMap_23_Crow_List" ),
	MyFunc = fun( Record )->
					 Monster = map:getMapObjectByID( Record ),
					 case Monster of
						 {}->
							 Monsters2 = get( "copyMap_23_Crow_List" ),
							 Monsters3 = Monsters2 -- [Record],
							 put( "copyMap_23_Crow_List", Monsters3 );
						 _->
							 case objectHatred:isInHatred(Record, _EventParam) of
								 true->ok;
								 false->
									 objectHatred:addHatredIntoObject(Record, _EventParam, 0)
							 end
					 end
			 end,
	lists:foreach( MyFunc, Monsters ).

	

%%BOSS魑魅 选择技能 -> { eventCallBackReturn, {skillid,SkillID} } or { eventCallBackReturn, none }
copyMap_23__Event_FightHeart( _Object, _EventParam, _RegParam )->
	CfgData = get( "copyMap_23_data" ),
	Times = get( "copyMap_23_time" ),
	%Now = common:milliseconds(),
	NowTime = erlang:now(),
	Now = common:millisecondsByTime(NowTime),
	%put("copyMap_23__Event_FightHeart_ret",{ eventCallBackReturn, none }),
	try
		%% 判断公共
		CommonCD = timer:now_diff( NowTime, _Object#mapMonster.lastUsePhysicAttackTime )/1000,
		case CommonCD > array:get(?attack_speed, _Object#mapMonster.finalProperty) of
			true->
				ok;
			false->
				throw( none )
		end,
				
		%% 判断毒云能否可用
		case Now >= Times#copyMap_23_time.next_Poison_Cloud_Triger_time   of
			true->
				case etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), CfgData#copyMap_23_data.poison_Cloud_Skill_Id) of
					{}->ok;
					SkillCfg->
						case objectHatred:getRandomHatredPlayer(map:getObjectID(_Object)) of
							{}->ok;
							Target->
								Pos = map:getObjectPos(Target),
								case scriptCommon:scriptUseSkill(_Object, Target, SkillCfg, Pos#posInfo.x, Pos#posInfo.y, -1, false ) of
									true->
										NewTimes1 = Times#copyMap_23_time{next_Poison_Cloud_Triger_time = Now + CfgData#copyMap_23_data.poison_Cloud_Interval,
																		  last_Attack_Triger_time=Now},
										put( "copyMap_23_time", NewTimes1),
										throw(none);
									false->ok
								end
						end
				end;
			false->ok
		end,
		
		%% 判断召唤乌鸦能否可用
		case Now >= Times#copyMap_23_time.next_Crow_Summon_Triger_Blood of
			true->
				case etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), CfgData#copyMap_23_data.crow_Summon_Skill_Id) of
					{}->ok;
					SkillCfg2->
						case scriptCommon:scriptUseSkill(_Object, _Object, SkillCfg2, 0, 0, -1, false ) of
							true->
								NewTimes2 = Times#copyMap_23_time{next_Crow_Summon_Triger_Blood = Now + CfgData#copyMap_23_data.crow_Summon_Interval,
												  last_Attack_Triger_time=Now},
								put( "copyMap_23_time", NewTimes2),
								throw(none);
							false->ok
						end
				end;
			false->ok
		end,
		
		throw(-1)
	catch
		Return->{ eventCallBackReturn, Return } 
	end.


%%BOSS 死亡事件
copyMap_23__Boss__Monster_Event_Dead( Object, _EventParam, _RegParam )->
	%%刷传送点
	case get("copyMap_23__HasRefresh_Transport") of
		false->
			CnfData = get( "copyMap_23_data" ),

			%%设置无人地图销毁时间
			map:setCopyMapNoPlayerDetroyTime( 1 ),
				
			MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), CnfData#copyMap_23_data.copy_Map_23_ID ),

			scriptCommon:refresh_New_Transport( CnfData#copyMap_23_data.transport_ID,
												CnfData#copyMap_23_data.transport_PosX, 
												CnfData#copyMap_23_data.transport_PosY,
												MapCfg#mapCfg.quitMapID,
												MapCfg#mapCfg.quitMapPosX,
												MapCfg#mapCfg.quitMapPosY ),

			put("copyMap_23__HasRefresh_Transport",true),
			%%结算副本
			map:onCopyMapSettleAccounts();
		true->ok
	end,
	
	ok.
