%% Author: wenziyong
%% Created: 2013-1-25
%% Description: TODO: Add description to monster
-module(copyMap_26).

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

%% 地下龙城-熔岩古城副本（英雄）

% 獬豸BOSS设定:
%	獬豸的眼神:BOSS一定时间会对玩家释放獬豸的眼神,技能对目标造成一个DEBUFF.BOSS会强制攻击中这个DEBUFF的玩家.中这个DEBUFF的玩家很容易被杀死.但BOSS释放这个技能一定时间内移动速度降低.
%           给boss add buff(移动速度降低), 通过通用技能buff实现，从仇恨列表里随机选择一个中debuff (BOSS会强制攻击中这个debuff的玩家)也用通用debuff来实现，
%			  增加了objectHatred:lockObjectHatred unlockObjectHatred getRandomHatredTargetID去实现这个debuff
%			  这个debuff由脚本来实现添加，无需在技能效果表中配置，原因为了实现锁定仇恨和解锁仇恨功能
%           触发条件： 定时触发，进入战斗后首次t1秒触发，非首次t2秒触发，

%	爪击:BOSS一段时间对目标使用爪击.爪击会对目标造成极强的流血效果.
%           触发条件： 定时触发，进入战斗后首次t1秒触发，非首次t2秒触发，

-record( copyMap_26_data, {
						    %%26号副本地图的DataID,将根据地图的配置文件进行调整
						   	copy_Map_26_ID =  26,
						   	%%BOSS獬豸
						   	boss_ID =  200,
							
							%%獬豸的眼神，技能ID
							xieZhi_Eye_Skill_Id = 5017,		
							%%獬豸的眼神，进入战斗后多长时间首次触发
							xieZhi_Eye_First_Interval = 20000,		
							%%獬豸的眼神，进入战斗后非首次触发的间隔时间
							xieZhi_Eye_Interval = 15000,
							%%獬豸的眼神debuff 
							xieZhi_Eye_Force_Buff_Id = 8,
							
							

							%%爪击，技能ID
							claw_Attack_Skill_Id = 5018,	
							%%爪击，进入战斗后多长时间首次触发
							claw_Attack_First_Interval = 20000,		
							%%爪击，进入战斗后非首次触发的间隔时间
							claw_Attack_Interval = 15000,
													  
						    %%传送点ID，TransportDataID,
							transport_ID = 7,
							%%传送点坐标用boss死的位置
							%%传送点x坐标
							transport_PosX = 2540,
							%%传送点y坐标
							transport_PosY = 2775
						   } 
	   ).



-record( copyMap_26_time, {next_XieZhi_Eye_Triger_time,next_Claw_Attack_Triger_time,last_Attack_Triger_time} ).

init()->
	%% 注意此函数的执行与副本进程不是在同一进程 
	CopyMap_26_data = #copyMap_26_data{},
	scriptManager:registerScript( ?Object_Type_Map, CopyMap_26_data#copyMap_26_data.copy_Map_26_ID, ?Map_Event_Init, 
								  ?MODULE, map_26_Map_Event_Init, 0 ),
	

	%%注册，BOSS獬豸的出生事件
	scriptManager:registerScript( ?Object_Type_Monster, CopyMap_26_data#copyMap_26_data.boss_ID, ?Monster_Event_Init, 
								  ?MODULE, copyMap_26__Boss__Monster_Event_Init, 0 ),
	
	ok.

map_26_Map_Event_Init( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "map_26_Map_Event_Init" ),
	put( "copyMap_26_data", #copyMap_26_data{} ),
	put( "copyMap_26_Force_Attack_Target_Id", 0 ),
	put("copyMap_26__HasRefresh_Transport",false),
	
	ok.

%%BOSS 獬豸的出生事件
copyMap_26__Boss__Monster_Event_Init( Object, _EventParam, _RegParam )->
	%%检查配置是否一致
	MonsterDataID = Object#mapMonster.monster_data_id,	
	CopyMap_26_data = get( "copyMap_26_data" ),
	case MonsterDataID =:= CopyMap_26_data#copyMap_26_data.boss_ID of
		true->ok;
		false->?ERROR_OUT( "CopyMap_26_data#copyMap_26_data.boss_ID configure error" )
    end,
	

	%%注册，BOSS死亡事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_Dead, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_26__Boss__Monster_Event_Dead, 
									0 ),
	
	%%注册进入战斗状态事件
	objectEvent:registerObjectEvent(Object, 
									?Char_Event_EnterFightState, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_26__Boss__Char_Event_EnterFightState, 
									0 ),
	%%注册事件Monster_Event_FightHeart,战斗中来选择技能
	objectEvent:registerObjectEvent(Object, 
									?Monster_Event_FightHeart, 
									?Object_Type_Monster, 
									MonsterDataID, 
									?MODULE, 
									copyMap_26__Event_FightHeart, 
									0 ),
	%%注册事件  技能效果
	
	ok.


%%BOSS獬豸 进入战斗状态事件
copyMap_26__Boss__Char_Event_EnterFightState( _Object, _EventParam, _RegParam )->
	CnfData = get( "copyMap_26_data" ),
	Now = common:milliseconds(),

	put( "copyMap_26_time", 
	 	#copyMap_26_time{next_XieZhi_Eye_Triger_time=Now + CnfData#copyMap_26_data.xieZhi_Eye_First_Interval,	
	 	next_Claw_Attack_Triger_time=Now + CnfData#copyMap_26_data.claw_Attack_First_Interval,last_Attack_Triger_time=Now}),
	
	ok.


%%BOSS獬豸 选择技能 or { eventCallBackReturn, none }
copyMap_26__Event_FightHeart( _Object, _EventParam, _RegParam )->
	CfgData = get( "copyMap_26_data" ),
	Times = get( "copyMap_26_time" ),
	%Now = common:milliseconds(),
	NowTime = erlang:now(),
	Now = common:millisecondsByTime(NowTime),
	%put("copyMap_26__Event_FightHeart_ret",{ eventCallBackReturn, none }),
	try
		%% 判断公共
		CommonCD = timer:now_diff( NowTime, _Object#mapMonster.lastUsePhysicAttackTime )/1000,
		case CommonCD > array:get(?attack_speed, _Object#mapMonster.finalProperty) of
			true->
				ok;
			false->
				throw( none )
		end,
		
		MyID = map:getObjectID(_Object),
		%%如果当前目标没有獬豸的眼神debuff，解锁仇恨锁定
		case objectHatred:getLockHatredObject(MyID) of
			{}->ok;
			LockTarget->
				LockID = map:getObjectID(LockTarget),
				case map:isObjectDead(LockTarget) of
					true->
						%%锁定目标死亡，直接解除锁定
						objectHatred:unlockObjectHatred(MyID, LockID);
					false->
						case buff:isObjectHaveBuff(MyID, CfgData#copyMap_26_data.xieZhi_Eye_Force_Buff_Id) of
							true->ok;
							false->
								objectHatred:unlockObjectHatred(MyID, LockID)
						end
				end
		end,
		
				
		%% 判断獬豸的眼神能否可用
		case Now >= Times#copyMap_26_time.next_XieZhi_Eye_Triger_time  of
			true->
				case etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), CfgData#copyMap_26_data.xieZhi_Eye_Skill_Id) of
					{}->ok;
					SkillCfg->
						%%随机选择一个玩家
						case objectHatred:getRandomHatredPlayer(MyID) of
							{}->ok;
							Target->
								case scriptCommon:scriptUseSkill(_Object, Target, SkillCfg, 0, 0, -1, false) of
									true->
										NewTimes1 = Times#copyMap_26_time{next_XieZhi_Eye_Triger_time = Now + CfgData#copyMap_26_data.xieZhi_Eye_Interval,
																		  last_Attack_Triger_time=Now},
										put( "copyMap_26_time", NewTimes1),
										case etsBaseFunc:readRecord( main:getGlobalBuffCfgTable(), CfgData#copyMap_26_data.xieZhi_Eye_Force_Buff_Id ) of
											{}->
												ok;
											BuffCfg->
												%%锁定仇恨
												OtherID = map:getObjectID(Target),
												objectHatred:lockObjectHatred(MyID, OtherID),
												%%添加buff
												buff:addBuffer(OtherID, BuffCfg, MyID, 0, 0, 0)
										end,
										throw(none);
									follow->throw(none);
									_->ok
								end
						end
				end;
			false->ok
		end,	
	
		%% 判断爪击能否可用
		case Now >= Times#copyMap_26_time.next_Claw_Attack_Triger_time of
			true->
				case etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), CfgData#copyMap_26_data.claw_Attack_Skill_Id) of
					{}->ok;
					SkillCfg2->
						case objectHatred:getObjectMaxHatredTarget(map:getObjectID(_Object)) of
							{}->ok;
							Target2->
								case scriptCommon:scriptUseSkill(_Object, Target2, SkillCfg2, 0, 0, -1, true) of
									true->
										NewTimes2 = Times#copyMap_26_time{next_Claw_Attack_Triger_time = Now + CfgData#copyMap_26_data.claw_Attack_Interval,
																		  last_Attack_Triger_time=Now},
										put( "copyMap_26_time", NewTimes2),
										throw( none );
									follow->throw( none );
									_->ok
								end
						end
				end;
			false->ok
		end,
		
		throw( -1 )
	catch
		Return->{ eventCallBackReturn, Return }
	end.

%%BOSS 死亡事件
copyMap_26__Boss__Monster_Event_Dead( Object, _EventParam, _RegParam )->
	%%刷传送点
	case get("copyMap_26__HasRefresh_Transport") of
		false->
			CnfData = get( "copyMap_26_data" ),

			%%设置无人地图销毁时间
			map:setCopyMapNoPlayerDetroyTime( 1 ),
				
			MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), CnfData#copyMap_26_data.copy_Map_26_ID ),

			scriptCommon:refresh_New_Transport( CnfData#copyMap_26_data.transport_ID,
												CnfData#copyMap_26_data.transport_PosX, 
												CnfData#copyMap_26_data.transport_PosY,
												MapCfg#mapCfg.quitMapID,
												MapCfg#mapCfg.quitMapPosX,
												MapCfg#mapCfg.quitMapPosY ),
			
			put("copyMap_26__HasRefresh_Transport",true),
						%%结算副本
			map:onCopyMapSettleAccounts();
		true->ok
	end,
	
	ok.



