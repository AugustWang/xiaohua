%% Author: wenziyong
%% Created: 2013-1-25
%% Description: TODO: Add description to monster
-module(copyMap_20).

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

%% 地下龙城-囚龙圣殿副本

% 睚眦 BOSS设定:
%	龙息: 睚眦会对自身大范围内所有敌对目的造成一次火焰伤害.
%       AOE技能，触发条件： 定时触发，进入战斗后首次t1秒触发，非首次t2秒触发，
%	龙之怒: 睚眦会在每损失一定自身血量后获得增加自身攻击力可叠加. 
%        触发条件： 每损失一定自身血量后
%	龙之召唤:进入战斗每一段时间会刷新几只小龙.攻击附近玩家. 
%        触发条件： 定时触发，进入战斗后每t1秒触发
%		 刷新几只小龙: 睚眦出生时注册龙之召唤刷新几只小龙的效果，在技能效果中调用ObjectEvent来触发此效果
%        龙眠: 睚眦使用龙之召唤后一段时间内大量降低防御力和抗性. 给boss加debuff, 实现时不把它当技能，当作龙之召唤的一个buff效果
%   


-record( copyMap_20_data, {
						    %%20号副本地图的DataID,将根据地图的配置文件进行调整
						   	copy_Map_20_ID =  20,
						   	%%BOSS睚眦
						   	boss_ID =  105,
							
							%%龙息，技能ID 
							dragon_Breath_Skill_Id = 5021,		
							%%龙息，进入战斗后多长时间首次触发
							dragon_Breath_First_Interval = 20000,		
							%%龙息，进入战斗后非首次触发的间隔时间
							dragon_Breath_Interval = 15000,
							
							%%龙之怒80%buff
							dragon_Angry_80_BuffID = 12,
							dragon_Angry_80_Life = 80,
							%% 龙之怒60%buff
							dragon_Angry_60_BuffID = 13,
							dragon_Angry_60_Life = 60,
							%% 龙之怒40%buff
							dragon_Angry_40_BuffID = 14,
							dragon_Angry_40_Life = 40,
							%% 龙之怒20%buff
							dragon_Angry_20_BuffID = 15,
							dragon_Angry_20_Life = 20,
							
							%% 龙之召唤，技能ID
							dragon_Summon_Skill_Id = 5022,	
							%%龙之召唤，进入战斗后多长时间首次触发
							dragon_Summon_First_Interval = 20000,		
							%%龙之召唤，进入战斗后非首次触发的间隔时间
							dragon_Summon_Interval = 15000,	
							%%龙之召唤，召唤出来的小龙的个数 
							dragon_Summon_Small_Dragon_Num = 3,		
							%%召唤出来的小龙的ID
							small_Dragon_Id = 222,	
							%%召唤小龙出生的位置
							small_Dragon_Pos = #posInfo{x=1257, y=1203},
							%%召唤出来的小龙在固定点以半径为R的随机范围
							small_Dragon_R = 200,
							
							%%金凤凰怪物ID
							phoenix_ID	= 104,
							%%金凤凰触发回血buff血量
							phoenix_LifeBuff_Life = 50,
							%%金凤凰回血buffID
							phoenix_LifeBuff_ID = 11,

 							%%传送点ID，TransportDataID,
							transport_ID = 8,
							%%传送点坐标用boss死的位置
							%%传送点x坐标
							transport_PosX = 1260,
							%%传送点y坐标
							transport_PosY = 1550
						   } 
	   ).

	
-record( copyMap_20_time, {next_Dragon_Breath_Triger_time,next_Dragon_Summon_Triger_time,last_Attack_Triger_time} ).

init()->
	%% 注意此函数的执行与副本进程不是在同一进程 
	CopyMap_20_data = #copyMap_20_data{},
	scriptManager:registerScript( ?Object_Type_Map, CopyMap_20_data#copyMap_20_data.copy_Map_20_ID, ?Map_Event_Init, 
								  ?MODULE, map_20_Map_Event_Init, 0 ),
	

	%%注册，BOSS睚眦的出生事件
	scriptManager:registerScript( ?Object_Type_Monster, CopyMap_20_data#copyMap_20_data.boss_ID, ?Monster_Event_Init, 
								  ?MODULE, copyMap_20__Boss__Monster_Event_Init, 0 ),
	
	%%注册小龙的出生事件
	scriptManager:registerScript(?Object_Type_Monster, CopyMap_20_data#copyMap_20_data.small_Dragon_Id, ?Monster_Event_Init, 
								 ?MODULE, copyMap_20__SmallDragon__Monster_Event_Init, 0),
	
	%%注册金凤凰的出生事件
	scriptManager:registerScript(?Object_Type_Monster, CopyMap_20_data#copyMap_20_data.phoenix_ID, ?Monster_Event_Init, 
								 ?MODULE, copyMap_20__Phoenix__Monster_Event_Init, 0),
	
	ok.

map_20_Map_Event_Init( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "map_20_Map_Event_Init" ),
	put( "copyMap_20_data", #copyMap_20_data{} ),
	put("copyMap_20__HasRefresh_Transport",false),
	put( "copyMap_20_BossID", 0 ),
	put( "copyMap_20_SmallDragons", [] ),
	ok.

%%金凤凰的出生事件
copyMap_20__Phoenix__Monster_Event_Init( Object, _EventParam, _RegParam )->
	MonsterDataID = Object#mapMonster.monster_data_id,	
	%%注册进入战斗状态事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_EnterFightState, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_20__Phoenix__Char_Event_EnterFightState, 
									0 ),
	
	%%注册血量改变事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_Life_Changed, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_20__Phoenix__Char_Event_LifeChanged, 
									0 ),
	
	put("copyMap_20__Phoenix_IsDoLifeBuff", false).

%%金凤凰进入战斗
copyMap_20__Phoenix__Char_Event_EnterFightState( _Object, _EventParam, _RegParam )->
	put("copyMap_20__Phoenix_IsDoLifeBuff", false).

%%金凤凰血量改变
copyMap_20__Phoenix__Char_Event_LifeChanged( Object, _EventParam, _RegParam )->
	case _EventParam of
		false->
			CnfData = get( "copyMap_20_data" ),
			LifePercent = charDefine:getObjectLifePercent(Object),
			case LifePercent < CnfData#copyMap_20_data.phoenix_LifeBuff_Life of
				true->
					case get("copyMap_20__Phoenix_IsDoLifeBuff") of
						false->
							scriptCommon:scriptAddBuff(Object#mapMonster.id, Object#mapMonster.id, 
													   CnfData#copyMap_20_data.phoenix_LifeBuff_ID, 0),
							put("copyMap_20__Phoenix_IsDoLifeBuff", true);
						_->ok
					end;
				_->ok
			end;
		_->ok
	end.

%%小龙的出生事件
copyMap_20__SmallDragon__Monster_Event_Init( Object, _EventParam, _RegParam )->
	Dragons = get( "copyMap_20_SmallDragons" ),
	put( "copyMap_20_SmallDragons", Dragons ++ [Object#mapMonster.id]),
	%%小龙出生，跟boss共享仇恨
	BossHatred = objectHatred:getObjectAllHatredTargets(get("copyMap_20_BossID")),
	Func = fun(HartredObj)->
				   objectHatred:addHatredIntoObject(map:getObjectID(Object), map:getObjectID(HartredObj), 1)
		   end,
	lists:foreach(Func, BossHatred).

%%BOSS 的出生事件
copyMap_20__Boss__Monster_Event_Init( Object, _EventParam, _RegParam )->
	%%检查配置是否一致
	MonsterDataID = Object#mapMonster.monster_data_id,	
	CopyMap_20_data = get( "copyMap_20_data" ),
	put("copyMap_20_BossID", Object#mapMonster.id),
	case MonsterDataID =:= CopyMap_20_data#copyMap_20_data.boss_ID of
		true->ok;
		false->?ERROR_OUT( "CopyMap_20_data#copyMap_20_data.boss_ID configure error" )
    end,
	
	%%注册，BOSS死亡事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_Dead, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_20__Boss__Monster_Event_Dead, 
									0 ),
	
	%%注册进入战斗状态事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_EnterFightState, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_20__Boss__Char_Event_EnterFightState, 
									0 ),
	
	%%注册离开战斗事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_LeaveFightState, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_20__Boss__Char_Event_LeaveFightState, 
									0 ),
	%%注册新增仇恨对象事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_Add_Hatred_Object, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_20__Boss__Add_Hatred_Object, 
									0 ),
	
	%%注册事件Monster_Event_FightHeart,战斗中来选择技能
	objectEvent:registerObjectEvent(Object, 
									?Monster_Event_FightHeart, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_20__Event_FightHeart, 
									0 ),
	%% 注册事件  技能效果
	%% 注册龙之召唤刷新几只小龙的效果
	objectEvent:registerObjectEvent(Object, 
									?Monster_Event_RefreshSmallMonsters, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_20__Event_RefreshSmallMonsters, 
									0 ),
	
	%%注册boss血量改变事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_Life_Changed, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_20__Boss__Char_Event_LifeChange, 
									0),
	
	ok.



%%BOSS睚眦 进入战斗状态事件
copyMap_20__Boss__Char_Event_EnterFightState( _Object, _EventParam, _RegParam )->
	CnfData = get( "copyMap_20_data" ),
	Now = common:milliseconds(),

	put( "copyMap_20_time", 
	 	#copyMap_20_time{next_Dragon_Breath_Triger_time=Now + CnfData#copyMap_20_data.dragon_Breath_First_Interval,
						 next_Dragon_Summon_Triger_time=Now + CnfData#copyMap_20_data.dragon_Summon_First_Interval,
							 last_Attack_Triger_time=Now}),
	ok.

%%BOSS睚眦 离开战斗状态事件
copyMap_20__Boss__Char_Event_LeaveFightState(_Object, _EventParam, _RegParam )->
	%%将所有召唤的小龙删除
	Monsters = get( "copyMap_20_SmallDragons" ),
	put("copyMap_20_SmallDragons", []),
	Func = fun(MonsterID) ->
				   map:despellObject(MonsterID, 0)
		   end,
	lists:foreach(Func, Monsters),
	
	CnfData = get( "copyMap_20_data" ),
	ObjectID = map:getObjectID(_Object),
	%%删除buff
	case  buff:isObjectHaveBuff(ObjectID, CnfData#copyMap_20_data.dragon_Angry_20_BuffID) of
		true->
			buff:removeBuff(ObjectID, CnfData#copyMap_20_data.dragon_Angry_20_BuffID);
		_->ok
	end,
	
	case  buff:isObjectHaveBuff(ObjectID, CnfData#copyMap_20_data.dragon_Angry_40_BuffID) of
		true->
			buff:removeBuff(ObjectID, CnfData#copyMap_20_data.dragon_Angry_40_BuffID);
		_->ok
	end,
	
	case  buff:isObjectHaveBuff(ObjectID, CnfData#copyMap_20_data.dragon_Angry_60_BuffID) of
		true->
			buff:removeBuff(ObjectID, CnfData#copyMap_20_data.dragon_Angry_60_BuffID);
		_->ok
	end,
	
	case  buff:isObjectHaveBuff(ObjectID, CnfData#copyMap_20_data.dragon_Angry_80_BuffID) of
		true->
			buff:removeBuff(ObjectID, CnfData#copyMap_20_data.dragon_Angry_80_BuffID);
		_->ok
	end.

%%BOSS睚眦 血量改变事件
copyMap_20__Boss__Char_Event_LifeChange(_Object, _EventParam, _RegParam)->
	try
		CnfData = get( "copyMap_20_data" ),
		case _EventParam of
			false->
				LifePercent = charDefine:getObjectLifePercent(_Object),
				if LifePercent =< CnfData#copyMap_20_data.dragon_Angry_20_Life ->
					   case buff:isObjectHaveBuff(_Object#mapMonster.id, CnfData#copyMap_20_data.dragon_Angry_20_BuffID) of
						   false->
							   scriptCommon:scriptAddBuff(_Object#mapMonster.id, _Object#mapMonster.id, 
														  CnfData#copyMap_20_data.dragon_Angry_20_BuffID, 0);
						   _->ok
					   end;
				   LifePercent =< CnfData#copyMap_20_data.dragon_Angry_40_Life->
					   case buff:isObjectHaveBuff(_Object#mapMonster.id, CnfData#copyMap_20_data.dragon_Angry_40_BuffID) of
						   false->
							   scriptCommon:scriptAddBuff(_Object#mapMonster.id, _Object#mapMonster.id, 
														  CnfData#copyMap_20_data.dragon_Angry_40_BuffID, 0);
						   _->ok
					   end;
				   LifePercent =< CnfData#copyMap_20_data.dragon_Angry_60_Life->
					   case buff:isObjectHaveBuff(_Object#mapMonster.id, CnfData#copyMap_20_data.dragon_Angry_60_BuffID) of
						   false->
							   scriptCommon:scriptAddBuff(_Object#mapMonster.id, _Object#mapMonster.id, 
														  CnfData#copyMap_20_data.dragon_Angry_60_BuffID, 0);
						   _->ok
					   end;
				   LifePercent =< CnfData#copyMap_20_data.dragon_Angry_80_Life->
					   case buff:isObjectHaveBuff(_Object#mapMonster.id, CnfData#copyMap_20_data.dragon_Angry_80_BuffID) of
						   false->
							   scriptCommon:scriptAddBuff(_Object#mapMonster.id, _Object#mapMonster.id, 
														  CnfData#copyMap_20_data.dragon_Angry_80_BuffID, 0);
						   _->ok
					   end;
				   true->ok
				end;
			_->throw(-1)
		end
	catch
		_->ok
end.

%%BOSS睚眦 新增仇恨对象事件
copyMap_20__Boss__Add_Hatred_Object( _Object, EventParam, _RegParam )->
	Monsters = get( "copyMap_20_SmallDragons" ),
	MyFunc = fun( Record )->
					 Monster = map:getMapObjectByID( Record ),
					 case Monster of
						 {}->
							 Monsters2 = get( "copyMap_20_SmallDragons" ),
							 Monsters3 = Monsters2 -- [Record],
							 put( "copyMap_20_SmallDragons", Monsters3 );
						 _->
							 case objectHatred:isInHatred(Record, EventParam) of
								 true->ok;
								 false->
									 objectHatred:addHatredIntoObject(Record, EventParam, 1)
							 end
					 end
			 end,
	lists:foreach( MyFunc, Monsters ),
	ok.
	
	
%%BOSS睚眦 选择技能 -> { eventCallBackReturn, {skillid,SkillID} } or { eventCallBackReturn, none }
copyMap_20__Event_FightHeart( _Object, _EventParam, _RegParam )->
	CfgData = get( "copyMap_20_data" ),
	Times = get( "copyMap_20_time" ),
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
		
		%% 判断龙之召唤能否可用
		case Now >= Times#copyMap_20_time.next_Dragon_Summon_Triger_time  of
			true->
				case etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), CfgData#copyMap_20_data.dragon_Summon_Skill_Id) of
					{}->ok;
					SkillCfg->
						case scriptCommon:scriptUseSkill(_Object, _Object, SkillCfg, 
														 _Object#mapMonster.pos#posInfo.x, 
														 _Object#mapMonster.pos#posInfo.y, -1, false) of
							true->
								NewTimes2 = Times#copyMap_20_time{next_Dragon_Summon_Triger_time = Now + CfgData#copyMap_20_data.dragon_Summon_Interval,
																  last_Attack_Triger_time=Now},
								put( "copyMap_20_time", NewTimes2),
								throw(none);
							follow->throw(none);
							_->ok
						end
				end;
			false->ok
		end,
		
		%%判断龙息是否可用
		case Now >= Times#copyMap_20_time.next_Dragon_Breath_Triger_time  of
			true->
				case etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), CfgData#copyMap_20_data.dragon_Breath_Skill_Id) of
					{}->ok;
					SkillCfg2->
						case scriptCommon:scriptUseSkill(_Object, {}, SkillCfg2, 
														 _Object#mapMonster.pos#posInfo.x, 
														 _Object#mapMonster.pos#posInfo.y, -1, false) of
							true->
								NewTimes3 = Times#copyMap_20_time{next_Dragon_Breath_Triger_time = Now + CfgData#copyMap_20_data.dragon_Breath_Interval,
																  last_Attack_Triger_time=Now},
								put( "copyMap_20_time", NewTimes3),
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

%%BOSS睚眦  龙之召唤 刷新几只小龙
copyMap_20__Event_RefreshSmallMonsters( Object, _EventParam, _RegParam )->
	case mapActorStateFlag:isStateFlag( map:getObjectID(Object), ?Actor_State_Flag_Fighting ) of
		true->
			CnfData = get( "copyMap_20_data" ),
			scriptCommon:rand_Refresh_New_Monsters_Around_Pos(
			  CnfData#copyMap_20_data.small_Dragon_Pos,
			  CnfData#copyMap_20_data.small_Dragon_R,
			  CnfData#copyMap_20_data.small_Dragon_Id,
			  CnfData#copyMap_20_data.dragon_Summon_Small_Dragon_Num),
			ok;		
		false->ok
	end,
	ok.

%%BOSS 死亡事件
copyMap_20__Boss__Monster_Event_Dead( Object, _EventParam, _RegParam )->
	%%刷传送点
	case get("copyMap_20__HasRefresh_Transport") of
		false->
			CnfData = get( "copyMap_20_data" ),
			%%设置无人地图销毁时间
			map:setCopyMapNoPlayerDetroyTime( 1 ),
				
			MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), CnfData#copyMap_20_data.copy_Map_20_ID ),

			scriptCommon:refresh_New_Transport( CnfData#copyMap_20_data.transport_ID,
												CnfData#copyMap_20_data.transport_PosX, 
												CnfData#copyMap_20_data.transport_PosY,
												MapCfg#mapCfg.quitMapID,
												MapCfg#mapCfg.quitMapPosX,
												MapCfg#mapCfg.quitMapPosY ),
			put("copyMap_20__HasRefresh_Transport",true),
			%%结算副本
			map:onCopyMapSettleAccounts();
		true->ok
	end,
	
	ok.
	


