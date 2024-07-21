%% Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(copyMap_16).

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



%% 幽暗密林(副本)
% BOSS蜘蛛精(设定):
%	召唤小蜘蛛:进入战斗一定时间蜘蛛精身后会刷出一枚蜘蛛卵.蜘蛛蛋可以被攻击.如果蜘蛛蛋在一定时间内未被击杀,则会孵化出小蜘蛛.小蜘蛛关联蜘蛛精BOSS仇恨.可以被击杀.(精英难度此技能增加蜘蛛卵和小蜘蛛属性)
%       触发条件： 定时触发，进入战斗后每t1秒触发
%       在skill effect 中配置RefreshSmallMonsters event,将刷新出蜘蛛卵，在蜘蛛卵出生时注册一个变身timer,时间到时变身为小蜘蛛
%	蜘蛛结网:此技能可让玩家昏迷一段时间.昏迷状态无法使用任何技能和药品.
%     触发条件： 定时触发，进入战斗后首次t1秒触发，非首次t2秒触发，
-record( copyMap_16_data, {
						    %%16号副本地图的DataID,将根据地图的配置文件进行调整
						   	copy_Map_16_ID_TianJi =  16,
							copy_Map_16_ID_XuanZong =  22,
						   	%%蜘蛛精英看守(蜘蛛守卫精英)，MonsterDataID
						   	zhi_Zhu_Shou_Wei_JY_ID =  80,
						   	%%BOSS毒蛛精(蜘蛛精)，MonsterDataID
							boss_ID = 5,
							
							%% 召唤小蜘蛛,技能ID 
							summon_Small_zhi_Zhu_Skill_Id = 5001,
							%% phase 1
							%%刷出一枚蜘蛛卵，时间间隔，单位毫秒
							boss_create_chield_time = 10000,
							%%蜘蛛卵ID，MonsterDataID,
							zhi_Zhu_Chield_ID = 143,
							%%召唤出来的蜘蛛卵在boss周围以半径为R的随机范围
							zhi_Zhu_Chield_R = 20,
							%% phase 2
							%%蜘蛛卵，多少时间后变化为小蜘蛛
							zhi_Zhu_Luan_Change_time = 1000,
							%%蜘蛛卵，变化为小蜘蛛(蜘蛛精英)，小蜘蛛ID MonsterDataID
							small_Zhi_Zhu_ID = 220,
						  
						  	%% 蜘蛛结网,技能ID 
							zhi_Zhu_Spin_Skill_Id = 5002,
							%%蜘蛛结网，进入战斗后多长时间首次触发,
							zhi_Zhu_Spin_First_Interval = 8000,		
							%%蜘蛛结网，进入战斗后非首次触发的间隔时间
							zhi_Zhu_Spin_Interval = 8000,							
						  
						    %%传送点ID，TransportDataID,
							% 天玑
							tianji_Transport_ID = 1,
						  	% 玄宗
							xuanzong_Transport_ID = 4,
						    %%传送点坐标用boss死的位置
							%%传送点x坐标
							transport_PosX = 3180,
							%%传送点y坐标
							transport_PosY = 980
						  
						   } 
	   ).

-record( copyMap_16_time, {next_Summon_Small_zhi_Zhu_Triger_time,next_Zhi_Zhu_Spin_Triger_time,last_Attack_Triger_time} ).

init()->
	%% 注意此函数的执行与副本进程不是在同一进程 
	CopyMap_16_data = #copyMap_16_data{},
	scriptManager:registerScript( ?Object_Type_Map, CopyMap_16_data#copyMap_16_data.copy_Map_16_ID_TianJi, ?Map_Event_Init, ?MODULE, map_16_Map_Event_Init, CopyMap_16_data#copyMap_16_data.copy_Map_16_ID_TianJi ),

	scriptManager:registerScript( ?Object_Type_Map, CopyMap_16_data#copyMap_16_data.copy_Map_16_ID_XuanZong, ?Map_Event_Init, ?MODULE, map_16_Map_Event_Init, CopyMap_16_data#copyMap_16_data.copy_Map_16_ID_XuanZong ),

	%%注册蜘蛛守卫精英的出生事件
	scriptManager:registerScript( ?Object_Type_Monster, CopyMap_16_data#copyMap_16_data.zhi_Zhu_Shou_Wei_JY_ID,
								   ?Monster_Event_Init, ?MODULE, copyMap_16__zhi_Zhu_Shou_Wei_JY__Monster_Event_Init, 0 ),
	
	%%注册，BOSS蜘蛛精的出生事件
	scriptManager:registerScript( ?Object_Type_Monster, CopyMap_16_data#copyMap_16_data.boss_ID, 
								  ?Monster_Event_Init, ?MODULE, copyMap_16__Boss__Monster_Event_Init, 0 ),
	
	%%注册，蜘蛛卵的出生事件
	scriptManager:registerScript( ?Object_Type_Monster, CopyMap_16_data#copyMap_16_data.zhi_Zhu_Chield_ID, 
								  ?Monster_Event_Init, ?MODULE, copyMap_16__ZhiZhuLuan__Monster_Event_Init, 0 ),

	%%注册，蜘蛛卵，变化为小蜘蛛的出生事件
	scriptManager:registerScript( ?Object_Type_Monster, CopyMap_16_data#copyMap_16_data.small_Zhi_Zhu_ID,
								   ?Monster_Event_Init, ?MODULE, copyMap_16__Xiao_ZhiZhu__Monster_Event_Init, 0 ),

	ok.

map_16_Map_Event_Init( _Object, _EventParam, RegParam )->
	?DEBUG_OUT( "map_16_Map_Event_Init" ),
	put( "MapDataID", RegParam ),
	put( "copyMap_16_data", #copyMap_16_data{} ),
	put( "copyMap_16_zhi_Zhu_Shou_Wei_JY_Objects", [] ),
	put( "copyMap_16__Xiao_ZhiZhu_Objects", [] ),
	put("copyMap_16__HasRefresh_Transport",false),
	
	ok.

%%蜘蛛守卫精英，出生事件
copyMap_16__zhi_Zhu_Shou_Wei_JY__Monster_Event_Init( Object, _EventParam, _RegParam )->
	%%检查配置是否一致
	MonsterDataID = Object#mapMonster.monster_data_id,	
	CopyMap_16_data = get( "copyMap_16_data" ),
	case MonsterDataID =:= CopyMap_16_data#copyMap_16_data.zhi_Zhu_Shou_Wei_JY_ID of
		true->ok;
		false->?ERROR_OUT( "CopyMap_16_data#copyMap_16_data.zhi_Zhu_Shou_Wei_JY_ID configure error" )
    end,
	%%注册新增仇恨对象事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_Add_Hatred_Object, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_16__zhi_Zhu_Shou_Wei_JY__Add_Hatred_Object, 
									0 ),
	%%蜘蛛守卫精英，存放Monster对象的，
	New_Monster_List = get( "copyMap_16_zhi_Zhu_Shou_Wei_JY_Objects" ) ++ [map:getObjectID(Object)],
	put( "copyMap_16_zhi_Zhu_Shou_Wei_JY_Objects", New_Monster_List ),
	
	ok.

%%蜘蛛守卫精英，增仇恨对象事件, EventParam : 仇恨对象ID
copyMap_16__zhi_Zhu_Shou_Wei_JY__Add_Hatred_Object( _Object, EventParam, _RegParam )->
	try
		%%遍历所有的蜘蛛守卫精英，增加仇恨目标，达到仇恨连锁目的
		Monster_List = get( "copyMap_16_zhi_Zhu_Shou_Wei_JY_Objects" ),
		MyFunc = fun( Record )->
						 case objectHatred:isInHatred(Record, EventParam) of
							 true->ok;
							 false->
								 objectHatred:addHatredIntoObject(Record, EventParam, 0)
						 end
				 end,
		lists:foreach( MyFunc, Monster_List ),
		ok
	catch
		_->ok
	end.

%%BOSS蜘蛛精的出生事件
copyMap_16__Boss__Monster_Event_Init( Object, _EventParam, _RegParam )->
	%%检查配置是否一致
	MonsterDataID = Object#mapMonster.monster_data_id,	
	CopyMap_16_data = get( "copyMap_16_data" ),
	case MonsterDataID =:= CopyMap_16_data#copyMap_16_data.boss_ID of
		true->ok;
		false->?ERROR_OUT( "CopyMap_16_data#copyMap_16_data.boss_ID configure error" )
    end,
	
	put( "copyMap_16_BossID", map:getObjectID(Object) ),
	%%注册，BOSS蜘蛛精的死亡事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_Dead, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_16__Boss__Monster_Event_Dead, 
									0 ),

	%%注册新增仇恨对象事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_Add_Hatred_Object, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_16__Boss__Add_Hatred_Object, 
									0 ),
	%%注册进入战斗状态事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_EnterFightState, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_16__Boss__Char_Event_EnterFightState, 
									0 ),
	%%注册离开战斗状态事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_LeaveFightState, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_16__Boss__Char_Event_LeaveFightState, 
									0 ),
	%%注册事件Monster_Event_FightHeart,战斗中来选择技能
	objectEvent:registerObjectEvent(Object, 
									?Monster_Event_FightHeart, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_16__Event_FightHeart, 
									0 ),
	%% 注册事件  技能效果
	%% 注册召唤小蜘蛛 刷新一枚蜘蛛卵的效果
	objectEvent:registerObjectEvent(Object, 
									?Monster_Event_RefreshSmallMonsters, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_16__Event_RefreshSmallMonsters, 
									0 ),
	
	ok.




%%BOSS蜘蛛精的新增仇恨对象事件
copyMap_16__Boss__Add_Hatred_Object( _Object, EventParam, _RegParam )->
	Monsters = get( "copyMap_16__Xiao_ZhiZhu_Objects" ),
	MyFunc = fun( Record )->
					 Monster = map:getMapObjectByID( Record ),
					 case Monster of
						 {}->
							 Monsters2 = get( "copyMap_16__Xiao_ZhiZhu_Objects" ),
							 Monsters3 = Monsters2 -- [Record],
							 put( "copyMap_16__Xiao_ZhiZhu_Objects", Monsters3 );
						 _->
							 case objectHatred:isInHatred(Record, EventParam) of
								 true->ok;
								 false->
									 objectHatred:addHatredIntoObject(Record, EventParam, 0)
							 end
					 end
			 end,
	lists:foreach( MyFunc, Monsters ),
	
	ok.

%%蜘蛛卵出生事件
copyMap_16__ZhiZhuLuan__Monster_Event_Init( Object, _EventParam, _RegParam )->
	CnfData = get( "copyMap_16_data" ),
	%%注册蜘蛛卵变身定时器 
	objectEvent:registerTimerEvent(Object, CnfData#copyMap_16_data.zhi_Zhu_Luan_Change_time, false, ?MODULE, copyMap_16__ZhiZhuLuan_Change_Timer, 0 ),
	ok.

%%蜘蛛卵变身定时器
copyMap_16__ZhiZhuLuan_Change_Timer( Object, _ObjectTimer )->
	CnfData = get( "copyMap_16_data" ),
	StateFlag =  ( ?Actor_State_Flag_Dead ) bor (?Monster_State_Flag_GoBacking),
	case mapActorStateFlag:isStateFlag(get("copyMap_16_BossID"), StateFlag) of
		true->
			Bianshen = false;
		_->
			case mapActorStateFlag:isStateFlag(get("copyMap_16_BossID"), ?Actor_State_Flag_Fighting) of
				true->
					Bianshen = true;
				_->Bianshen = false
			end
	end,
		
	%%时间到，变身
	case Object#mapMonster.life > 0 andalso Bianshen of
		true->
			scriptCommon:createMonster( CnfData#copyMap_16_data.small_Zhi_Zhu_ID, 
										Object#mapMonster.pos#posInfo.x, 
										Object#mapMonster.pos#posInfo.y, 0 ),
			%%自己消失
			map:despellObject(Object#mapMonster.id, 0 );
		false->
			map:despellObject(Object#mapMonster.id, 0 )
	end,
	ok.

%%蜘蛛卵可变化为小蜘蛛，小蜘蛛出生事件
copyMap_16__Xiao_ZhiZhu__Monster_Event_Init( Object, _EventParam, _RegParam )->
	try
		Monsters = get( "copyMap_16__Xiao_ZhiZhu_Objects" ),
		put( "copyMap_16__Xiao_ZhiZhu_Objects", Monsters ++ [map:getObjectID(Object)] ),
		BossHatred = objectHatred:getObjectAllHatredTargets(get("copyMap_16_BossID")),
		Func = fun(HartredObj)->
					   objectHatred:addHatredIntoObject(map:getObjectID(Object), map:getObjectID(HartredObj), 1)
			   end,
		lists:foreach(Func, BossHatred)
	catch
		_->ok
end.


%%BOSS蜘蛛精的进入战斗状态事件
copyMap_16__Boss__Char_Event_EnterFightState( _Object, _EventParam, _RegParam )->
	CnfData = get( "copyMap_16_data" ),
	Now = common:milliseconds(),
	
	put( "copyMap_16_time", 
	 	#copyMap_16_time{next_Summon_Small_zhi_Zhu_Triger_time=Now + CnfData#copyMap_16_data.boss_create_chield_time,
						 next_Zhi_Zhu_Spin_Triger_time=Now +  CnfData#copyMap_16_data.zhi_Zhu_Spin_First_Interval,
							 last_Attack_Triger_time=Now}),
	ok.

%%BOSS蜘蛛精的离开战斗状态事件
copyMap_16__Boss__Char_Event_LeaveFightState( _Object, _EventParam, _RegParam )->
	Monsters = get( "copyMap_16__Xiao_ZhiZhu_Objects" ),
	put("copyMap_16__Xiao_ZhiZhu_Objects", []),
	Func = fun(MonsterID) ->
				   map:despellObject(MonsterID, 0)
		   end,
	lists:foreach(Func, Monsters).


%%BOSS蜘蛛精 选择技能 -> { eventCallBackReturn, -1 } or { eventCallBackReturn, none }
copyMap_16__Event_FightHeart( _Object, _EventParam, _RegParam )->
	CfgData = get( "copyMap_16_data" ),
	Times = get( "copyMap_16_time" ),
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
					
		%% 判断召唤小蜘蛛是否可用
		case Now >= Times#copyMap_16_time.next_Summon_Small_zhi_Zhu_Triger_time  of
			true->
				case etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), CfgData#copyMap_16_data.summon_Small_zhi_Zhu_Skill_Id) of
					{}->ok;
					SkillCfg->
						case scriptCommon:scriptUseSkill(_Object, _Object, SkillCfg, 
														 _Object#mapMonster.pos#posInfo.x, 
														 _Object#mapMonster.pos#posInfo.y, -1, false) of
							true->
								%%技能释放成功
								NewTimes2 = setelement(#copyMap_16_time.next_Summon_Small_zhi_Zhu_Triger_time, Times, Now + CfgData#copyMap_16_data.boss_create_chield_time),
								put( "copyMap_16_time", NewTimes2),
								throw( none );
							follow->throw( none );
							_->ok
						end
				end;
			false->ok
		end,
		
		%% 判断蜘蛛结网是否可用
		case Now >= Times#copyMap_16_time.next_Zhi_Zhu_Spin_Triger_time  of
			true->
				case etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), CfgData#copyMap_16_data.zhi_Zhu_Spin_Skill_Id) of
					{}->ok;
					SkillCfg2->
						Target = objectHatred:getObjectMaxHatredTarget(_Object#mapMonster.id),
						case scriptCommon:scriptUseSkill(_Object, Target, SkillCfg2, 0, 0, -1, true) of
							true->
								%%技能释放成功
								NewTimes3 = setelement(#copyMap_16_time.next_Zhi_Zhu_Spin_Triger_time, Times, Now + CfgData#copyMap_16_data.zhi_Zhu_Spin_Interval),
								put( "copyMap_16_time", NewTimes3),
								throw( none );
							follow->throw( none );
							_->ok
						end
				end;
			false->ok
		end,
		
		throw(-1)
	catch
		Return->{ eventCallBackReturn, Return } 
	end.


%%BOSS蜘蛛精  召唤小蜘蛛 刷新一枚蜘蛛卵
copyMap_16__Event_RefreshSmallMonsters( Object, _EventParam, _RegParam )->
	case mapActorStateFlag:isStateFlag( map:getObjectID(Object), ?Actor_State_Flag_Fighting ) of
		true->
			CnfData = get( "copyMap_16_data" ),
			scriptCommon:rand_Refresh_New_Monsters_Around_Monster(Object,CnfData#copyMap_16_data.zhi_Zhu_Chield_ID,
																  CnfData#copyMap_16_data.zhi_Zhu_Chield_R,1),
			ok;		
		false->ok
	end,
	ok.
	


%%BOSS蜘蛛精的死亡事件
copyMap_16__Boss__Monster_Event_Dead( _Object, _EventParam, _RegParam )->
	%%刷传送点
	try
		case get("copyMap_16__HasRefresh_Transport") of
			false->
				CnfData = get( "copyMap_16_data" ),
				PlayerTable = map:getMapPlayerTable(),
				PlayerId = ets:first(PlayerTable),
				case PlayerId of
					'$end_of_table'->throw(-1);
					_->ok
				end,

				case etsBaseFunc:readRecord(PlayerTable,PlayerId ) of
					{}->Faction = 0,throw(-1);
					Player->Faction = Player#mapPlayer.faction
				end,
				
				case Faction of
					?CAMP_TIANJI->Transport_ID=CnfData#copyMap_16_data.tianji_Transport_ID;
					_->Transport_ID=CnfData#copyMap_16_data.xuanzong_Transport_ID
				end,
				
				%%设置无人地图销毁时间
				map:setCopyMapNoPlayerDetroyTime( 1 ),
				
				MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), get( "MapDataID" ) ),

				scriptCommon:refresh_New_Transport( Transport_ID,
													CnfData#copyMap_16_data.transport_PosX, 
													CnfData#copyMap_16_data.transport_PosY,
													MapCfg#mapCfg.quitMapID,
													MapCfg#mapCfg.quitMapPosX,
													MapCfg#mapCfg.quitMapPosY ),
				put("copyMap_16__HasRefresh_Transport",true),

				%%结算副本
				map:onCopyMapSettleAccounts();
			true->ok
		end,
		ok
	catch
		_->ok
	end.


