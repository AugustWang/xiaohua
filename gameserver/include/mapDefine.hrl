-ifndef(mapDefine_hrl).

%%地图类型
-define( Map_Type_Normal_World, 1 ).	%%世界地图
-define( Map_Type_Normal_Copy, 2 ).	%%一般副本地图
-define( Map_Type_Normal_Guild, 3 ).	%%一般仙盟地图
-define( Map_Type_Battle, 4 ).	%%战场地图

%%物体类型，玩家
-define( Object_Type_Player, 1 ).
%%物体类型，npc
-define( Object_Type_Npc, 2 ).
%%物体类型，monster
-define( Object_Type_Monster, 3 ).
%%物体类型，系统
-define( Object_Type_System, 4 ).
%%物体类型，仙盟
-define( Object_Type_Guild, 5 ).
%%物体类型，队伍
-define( Object_Type_Team, 6 ).
%%物件类型，object
-define( Object_Type_Object, 7 ).
%%物件类型，传送点
-define( Object_Type_TRANSPORT, 8 ).
%%物件类型，采集
-define( Object_Type_COLLECT, 9 ).
%%物件类型，宠物
-define( Object_Type_Pet, 10 ).
%%物件类型，装备
-define(Object_Type_Equipment, 11).
%%物件类型，地图
-define(Object_Type_Map, 12).
%%物件类型，任务
-define(Object_Type_Task, 13).
%%物件类型，技能特效
-define(Object_Type_SkillEffect, 14).
%%物件类型，通用
-define(Object_Type_Normal, 15).
%%物件类型，日常
-define(Object_Type_Daily, 16).
%%物件类型，坐骑
-define(Object_Type_Mount,17).
%%物件类型，物品
-define(Object_Type_Item,18).
%%物件类型，邮件
-define(Object_Type_Mail,19).
%%镖车类型
-define(Object_Type_Convoy,20).

%% 交易行,上架记录
-define(Object_Type_consalesitemdb,20).
%% friend_gamedata记录
-define(Object_Type_friend_gamedata,21).
%% guildapplicant记录
-define(Object_Type_guildapplicant,22).
%% guildmember_gamedata记录
-define(Object_Type_guildmember_gamedata,23).
%% r_playerbag 记录
-define(Object_Type_r_playerbag,24).





%%全局物件ID
-define( Global_Object_System_ID, 1 ).
-define( Global_Object_Player, 1 ).
-define( Global_Object_SkillEffect, 2 ).
-define( Global_Object_QieCuo, 3 ).

%%地图Actor移动跟新计时器
-define( Map_Actor_Move_Timer, 300 ).
%%地图Player移动跟新计时器
-define( Map_Player_Move_Timer, 150 ).
%%地图MonsterAI跟新计时器
-define( Map_Monster_AI_Timer, 500 ).
%%地图buff更新计时器
-define( Map_Buff_Timer, 1000).
%%地图生命秒回更新计时器
-define( Map_LifeRecover_Timer, 2000).
%%地图无人检测计时器
-define( Map_NoPlayer_Timer, 5000 ).
%%副本无人多少时间后销毁地图
-define( CopyMap_NoPlayer_Destroy_Time, 300 ).
%%战场无人销毁时间
-define( BattleMap_NoPlayer_Destroy_Time, 3600 ).

%%地图向组队通信更新计时器
-define( Map_PlayerPosUpdate_Timer,1000*5).

%%地图准备进入玩家更新计时器
-define( Map_Player_Ready_Enter_Timer, 5000 ).

%%地图像素格子宽度
-define( Map_Pixel_Title_Width, 32 ).
-define(Map_Pixel_Title_Width_SQ,?Map_Pixel_Title_Width*?Map_Pixel_Title_Width).

%%地图像素格子高度
-define( Map_Pixel_Title_Height, 32 ).

%%进程攻击距离
-define( Melee_Attack_Dist, ?Map_Pixel_Title_Width*2 ).
%%进程攻击距离SQ
-define( Melee_Attack_DistSQ, ?Melee_Attack_Dist*?Melee_Attack_Dist ).

%%远程攻击距离
-define( Shoot_Attack_Dist, ?Map_Pixel_Title_Width*5 ).
%%远程攻击距离SQ
-define( Shoot_Attack_DistSQ, ?Shoot_Attack_Dist*?Shoot_Attack_Dist ).

%%objectMoveState
-define( Object_MoveState_Stand, 1). %%站立
-define( Object_MoveState_Moving, 2). %%移动中
-define( Object_FlyState_Land, 4). %%地面
-define( Object_FlyState_Flying, 8). %%飞行


%%客户端与服务端位置最大误差值,250/秒，允许6秒的误差
-define( Client_Server_Max_Deviation, 1500).

%%物件仇恨列表最大仇恨目标个数
-define( Max_Hatred_Count, 100 ).


-define(MAP_TILE_FLAG_PHY, 1 bsl 0).   %%物理层
-define(MAP_TILE_FLAG_TRANS, 1 bsl 1). %%半透明

-define( eDirection_NULL, 16#0000 ).
-define( eDirection_Left, 16#0001 ).
-define( eDirection_Right, 16#0002 ).
-define( eDirection_Up, 16#0004 ).
-define( eDirection_Down, 16#0008 ).
-define( eDirection_LeftUp, (?eDirection_Left bor ?eDirection_Up) ).
-define( eDirection_RightUp, (?eDirection_Right bor ?eDirection_Up) ).
-define( eDirection_LeftDown, (?eDirection_Left bor ?eDirection_Down) ).
-define( eDirection_RightDown, (?eDirection_Right bor ?eDirection_Down) ).
-define( eDirection_ArrayLength, 16 ).

%%物件对象记录公共索引
-define( object_id_index, 2 ).
-define( object_event_index, 3 ).
-define( object_type_index, 4 ).
-define( object_table_index, 5 ).
-define( object_timer_index, 6 ).

-record( mapCfg, {mapID, type, miniMap, mapScn, initPosX, initPosY, mapdroplist, maxPlayerCount, resetTime,
					playerEnter_MinLevel, playerEnter_MaxLevel, playerActiveEnter_Times, playerActiveTime_Item,playerEnter_Times,	
					dropItem1, dropItem2, dropItem3, dropItem4, dropItem5, dropItem6, dropItem7, dropItem8, 
					pkFlag_Camp, pkFlag_Kill, pkFlag_QieCuo, 
					quitMapID, quitMapPosX, quitMapPosY, mapSpawnTable, mapFaction, mapName } ).


%%地图实例
-record( mapObject, {id, event_array, objType, ets_table, map_data_id, ownerType, ownerID, pid, combatID, onlineplayers, enteredPlayerHistory, mapViewCellIndex } ).

%%地图View信息
-record( mapView, {map_data_id, width, height, widthCellCount, heightCellCount, phy, aroundCellIndexArray} ).

%%地图上monster、npc出生信息
-record( mapSpawn, {id, mapId,type,typeId,x,y,param,isExist } ).


-record(posInfo, {x, y}).

%%玩家在地图上的属性
-record( mapPlayer, {id, event_array, objType, ets_table, timerList, moveState, level, pos, name, faction, sex, camp, weapon, coat, life,
					 stateFlag, stateRefArray, finalProperty, base_quip_ProFix, base_quip_ProPer, skill_ProFix, skill_ProPer, pid,
					moveTargetList, moveDir, moveRealDir, skillCommonCD, isEnteredChangeTargetMap,
					nonceOutFightPetId, mapCDInfoList,teamDataInfo, mapViewCellIndex,
					 readyFastTeamCopyMap, qieCuoPlayerID, battleFieldID, pK_Kill_Value,pK_Kill_OpenTime,pk_Kill_Punish,playerMountView,bloodPoolLife,
					attackSpeed, petBloodPoolLife, varArray, covoyQuality, convoyFlags,credit, pkPunishing, equipMinLevel,
					guildID, guildName, guildRank, vipLevel, gameSetMenu} ).

%%宠物技能
-record( mapPetSkill, {skillId, coolDownTime, skillCfg }).
%%宠物在地图上的属性
-record( mapPet, {id, event_array, objType, ets_table, timerList, masterId, data_id, moveState, level, pos, name, titleid, modelId, life,
					finalProperty, base_quip_ProFix, base_quip_ProPer, skill_ProFix, skill_ProPer,
					stateFlag,  stateRefArray, aiState, moveTargetList, attackTargetId, 
					mapSkills, skillCommonCD, petCfg, mapViewCellIndex, laterUseSkill, lastUseSkill
				  } ).

%%npc实例
-record( mapNpc, {id, event_array, objType, ets_table, timerList, npc_data_id, map_data_id, spawnData, level, x, y, stateFlag, stateRefArray, mapViewCellIndex } ).

%%monster实例 
-record( mapMonster, {id, event_array, objType, ets_table, timerList, moveState, isSleeping, map_data_id, spawnData, monster_data_id, level, pos, life, 
					  stateFlag, stateRefArray, aiState, lastAITime, posBeginFollowX, posBeginFollowY, faction,
					  lastUsePhysicAttackTime, firstHatredObjectID, firstHatredObjectPos,deadTime, freeMoveTime,
					  finalProperty,base_quip_ProFix,  skill_ProFix, skill_ProPer, moveTargetList, mapViewCellIndex  } ).

%% 镖车实例
-record( mapConvoy, {quality}).

%%object实例
-record( mapObjectActor, {id, event_array, objType, ets_table, timerList, object_data_id, x, y, spawnData, param1, param2, param3, param4, mapViewCellIndex } ).

%%准备进入地图的玩家
-record( readyEnterMap, {playerID, timeOut} ).

%%地图回调事件
-record( mapEvent, {eventID, callBack, param1, param2, param3 } ).

%%仇恨
-record( hatred, { targetID, value, lastTime } ).
-record( objectHatred, {id, lockTarget, hatredList } ).

%%物件身上的buff数据
-record( objectBuffData, { buff_id, buffCfg, skillCfg, casterID, isEnable, startTime, allValidTime, lastDotEffectTime, remainTriggerCount, skillDamageID } ).
%%物件身上的buff记录
-record( objectBuff, { id, dataList } ).

%%技能效果类型
%%创建Buffer，Param1=Buffer的SkillID
-define( SkillEffectType_CreateBuffer,	1 ).
%%使用或者生效后移除目标的某个或多个状态，填写0则不移除，使用位运算可填写多个，Param1=值
-define( SkillEffectType_RemoveTargetState,	2 ).
%%执行script中的effect函数，主要用于副本中boss的技能效果, Param1为event ID, 调用方式为objectEvent:onEvent( Attacker, event_id, 0),
-define( SkillEffectType_RunScriptEvent,3 ).

%%最多可见buff个数
-define( Max_Visable_Buff_Count, 16 ).

%%伤害计算中间结果记录
-record( damageInfo, { attackerID, beenAttackerID, skillDamageID, damage, isBlocked, isCrited } ).

%%玩家技能数据
-record( playerSkillCD, { id, coolDownTime } ).

%%与Npc对话的距离，像素
-define( TalkToNpc_Distance, ?Map_Pixel_Title_Width*3 ).
%%与Npc对话的距离SQ，像素
-define( TalkToNpc_Distance_SQ, ?TalkToNpc_Distance*?TalkToNpc_Distance ).

%%玩家战斗ID段
-define( Player_CombatID, 100 ).
%%怪物战斗ID起始值
-define( Monster_CombatID_Begin, 10000*100 ).
%%怪物战斗ID段
-define( Monster_CombatID, 10000*10 ).

%%战斗ID表
-record( combatID, {index, key} ).

%%宠物与玩家的最大距离，超过之后就将宠物瞬移到玩家身边
-define( Pet_AND_Player_Jump_MaxDis, 1000).

%%宠物与玩家的最大距离，超过之后就将宠物移动到玩家身边
-define( Pet_AND_Player_Move_MaxDis, 100).

%%副本拥有信息
-record( ownerMap, { ownerID, mapIDList } ).

%%副本进入距离检测
-define( EnterMap_CheckDist_SQ, ?Map_Pixel_Title_Width * ?Map_Pixel_Title_Width * 25 ).

%%地图进入错误原因返回值
-define( EnterMap_Fail_Invalid_Call, -1 ).%%无效的操作
-define( EnterMap_Fail_Exist_Player, -2 ).%%已经在地图里
-define( EnterMap_Fail_Exist_Ready_Player, -3 ).%%已经在等待玩家进入
-define( EnterMap_Fail_CD, -4 ).%%进入副本CD不满足
-define( EnterMap_Fail_Distance, -5 ).%%距离副本入口不满足
-define( EnterMap_Fail_FightState, -6 ).%%战斗状态不能进入副本
-define( EnterMap_Fail_NotTeamLeader, -7 ).%%不是队长，不能创建副本
-define( EnterMap_Fail_PlayerLevel, -8 ).%%等级不满足
-define( EnterMap_Fail_HasTeam, -9 ).%%已经在队伍里
-define( EnterMap_Fail_ResetFail_HasPlayer, -10 ).%%副本中还有玩家，重置失败
-define( EnterMap_Fail_ResetSucc, -11 ).%%副本重置成功
-define( EnterMap_Fail_ResetNomap, -12 ).%%副本重置已经完成
-define( EnterMap_Fail_ForceTransOut, 13 ).%%秒后将被传送出副本
-define( EnterMap_Fail_In_Convoy, 14 ).%%正在护送中不能进入副本

%%攻击失败原因码
-define( Attack_Fail_Invalid_Call, -1 ).%%无效的操作
-define( Attack_Fail_Safe_Area, -2 ).%%安全区域
-define( Attack_Fail_Team, -3 ).%%队友
-define( Attack_Fail_Friend, -4). %%友方
-define( Attack_Fail_Self, -5). %%自己
-define( Attack_Fail_PK_Protect, -6 ).%%pk保护中
-define( Attack_Fail_OpenGuildProtect, -7 ).%%开启了帮会保护


%%增加副本活跃次数返回值
-define( AddCopyActiveTime_Succ,		1).			%%增加成功
-define( AddCopyActiveTime_NotMap, -1 ).		%%没有找到副本
-define( AddCopyActiveTime_NotItem, -2 ).			%%没有足够的道具
-define( AddCopyActiveTime_NotCopyMap, -3 ).			%%要增加次数的地图不是副本
-define( AddCopyActiveTime_NotNeed, -4 ).			%%此副本没有活跃次数限制，不需要增加
-define( AddCopyActiveTime_MaxCount, -5).			%%活跃次数已达上限，无法增加

%%复活
-define( ReLiveHPPercentage, 20).			%%死亡复活血量百分比
-define( KillByPlayerReLiveBuffID, 37).		%%被玩家杀死死亡复活Buff ID
-define( ReLiveBuffExistTime, 120).			%%死亡复活Buff 存在时间

%%免战保护
-define( EnterPkProct5, "服务器将会在5分钟后进入免战状态，进入免战状态后和平模式下的玩家将不会受到PVP影响").			%%进入免战保护倒计时
-define( EnterPkProct4, "服务器将会在4分钟后进入免战状态，进入免战状态后和平模式下的玩家将不会受到PVP影响").			%%进入免战保护倒计时
-define( EnterPkProct3, "服务器将会在3分钟后进入免战状态，进入免战状态后和平模式下的玩家将不会受到PVP影响").			%%进入免战保护倒计时
-define( EnterPkProct2, "服务器将会在2分钟后进入免战状态，进入免战状态后和平模式下的玩家将不会受到PVP影响").			%%进入免战保护倒计时
-define( EnterPkProct1, "服务器将会在1分钟后进入免战状态，进入免战状态后和平模式下的玩家将不会受到PVP影响").			%%进入免战保护倒计时
-define( EnterPkProct0, "服务器已进入免战状态，所有和平模式的玩家将不会受到PVP影响").			%%pk保护倒计时

-define( LeavePkProct5, "服务器将会在5分钟后进入普通状态，进入普通状态后PVP将恢复正常").			%%离开免战保护倒计时
-define( LeavePkProct4, "服务器将会在4分钟后进入普通状态，进入普通状态后PVP将恢复正常").			%%离开免战保护倒计时
-define( LeavePkProct3, "服务器将会在3分钟后进入普通状态，进入普通状态后PVP将恢复正常").			%%离开免战保护倒计时
-define( LeavePkProct2, "服务器将会在2分钟后进入普通状态，进入普通状态后PVP将恢复正常").			%%离开免战保护倒计时
-define( LeavePkProct1, "服务器将会在1分钟后进入普通状态，进入普通状态后PVP将恢复正常").			%%离开免战保护倒计时
-define( LeavePkProct0, "服务器已进入普通状态，PVP恢复正常").			%%离开免战保护倒计时

-define( PKProctedStartTime, 0).
-define( PKProctedEndTime, 8*3600).
-define( PKProctedBroadcastInterval, 60).
-define( PKProctedLastTime, 900000).%%保护持续最长时间


%%玩家瞬移最大距离
-define( MaxTeleportMoveDis, 1000 ).


%%快速组队下副本
-record( fastTeamCopyMap, {mapDataID, readyPlayerList, teamPlayerCount, checkNpcID} ).

%%正在切磋的玩家
-record( qieCuoPlayers, {playerID, myPlayer, target, objectID } ).

-record( sceneNumofonemap, {mapID,sceneNum } ).


-endif. % -ifdef(mapDefine_hrl).