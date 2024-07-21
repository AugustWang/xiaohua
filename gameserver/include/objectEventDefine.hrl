
%%------------------------------------------所有物件公共事件--------------------------------------------------------------------
-define( Object_Event_Timer, 0 ).%%定时器

%%------------------------------------------地图事件--------------------------------------------------------------------
-define( Map_Event_Init, 1 ).%%地图创建初始化
-define( Map_Event_Destroy, 2 ).%%地图销毁
-define( Map_Event_Player_CanEnter, 3).%%玩家能否进入地图
-define( Map_Event_Player_Enter, 4).%%玩家进入地图
-define( Map_Event_Player_Leave, 5).%%玩家离开地图
-define( Map_Event_Char_Dead, 6).%%地图中Char死亡
-define( Map_Event_Object_Interact,7).%%地图物件交互
-define( Map_Event_Char_Harmed,8).%%地图char受伤
-define( Map_Event_Char_Damage,9).%%地图char造成伤害
-define( Map_Event_Count, 10).%%地图事件数量


%%------------------------------------------Charactor公共事件--------------------------------------------------------------------
-define( Char_Event_Life_Changed, 1 ).%%Char的血量改变
-define( Char_Event_EnterFightState, 2 ).%%Char进入战斗状态
-define( Char_Event_LeaveFightState, 3 ).%%Char离开战斗状态
-define( Char_Event_Used_Skill, 4 ).%%Char使用了技能
-define( Char_Event_Add_Buff, 5 ).%%Char的Buff增加
-define( Char_Event_Remove_Buff, 6 ).%%Char的Buff减少
-define( Char_Event_Add_Hatred_Object, 7 ).%%Char的仇恨对象增加
-define( Char_Event_Remove_Hatred_Object, 8 ).%%Char的仇恨对象减少
-define( Char_Event_OnDamage, 9 ).%%Char受到伤害
-define( Char_Event_Damage_Target, 10 ).%%Char伤害了目标
-define( Char_Event_Dead, 11 ).%%Char死亡
-define( Char_Event_Enter_Map, 12 ).%%Char进入地图
-define( Char_Event_Leave_Map, 13 ).%%Char离开了地图


%%------------------------------------------Monster事件--------------------------------------------------------------------
-define( Monster_Event_Init, 14 ).%%Monster初始化
-define( Monster_Event_DeadEXP, 15 ).%%Monster死亡经验
-define( Monster_Event_FightHeart, 16 ).%%Monster战斗心跳事件 在此事件中，为怪物选择技能
-define( Monster_Event_RefreshSmallMonsters, 17 ).%%Monster刷新新怪物 monster技能效果事件
-define( Monster_Event_AddTimer, 18 ).%%Monster 增加timer,目前用于延时触发另一技能

-define( Monster_Event_Count, 19 ).%%Monster事件数量



%%------------------------------------------Npc事件--------------------------------------------------------------------
-define( Npc_Event_Init, 14 ).%%Npc初始化
-define( Npc_Event_CanGetTask, 15 ).%%能否从Npc获得任务
-define( Npc_Event_GetedTask, 16 ).%%从Npc获得了任务
-define( Npc_Event_GiveBackTask, 17 ).%%从Npc归还了任务
-define( Npc_Event_Talk, 18 ).%%与Npc交互对话
-define( Npc_Event_EnterCopyMapID, 19 ).%%返回从该Npc进入副本的MapDataID
-define( Npc_Event_Count, 20 ).%%Npc事件数量

%%------------------------------------------Player事件--------------------------------------------------------------------
-define( Player_Event_Online, 14 ).%%玩家上线
-define( Player_Event_Level_Change, 15 ).%%玩家等级变化
-define( Player_Event_Level_Credit, 16 ).%%玩家声望变化
-define( Player_Event_Count, 17 ).%%玩家事件数量

%%------------------------------------------Item事件--------------------------------------------------------------------
-define( Item_Event_CanUse, 1 ).%%能否使用物品
-define( Item_Event_Use, 2 ).%%使用物品
-define( Item_Event_Count, 3 ).%%物品事件数量

%%------------------------------------------Task事件--------------------------------------------------------------------
-define( Task_Event_CanAccept, 1 ).%%能否接取任务
-define( Task_Event_Accepted, 2 ).%%接取了任务
-define( Task_Event_GiveBack, 3 ).%%归还了任务
-define( Task_Event_GiveUp, 4 ).%%放弃了任务
-define( Task_Event_Count, 5 ).%%任务事件数量

%%------------------------------------------Object事件--------------------------------------------------------------------
-define( Object_Event_Init, 1 ).%%物件初始化
-define( Object_Event_Interact, 2 ).%%物件交互
-define( Object_Event_Count, 3 ).%%物件事件数量

-record( objectEvent, {event_id, event, data_type, data_id, master_id, call_module, call_func, parama} ).
-record( objectEventManager, {event_id, objectEvent} ).

-record( objectTimer, { timer_id, timeDist, isLoop, master_id, call_module, call_func, parama } ).



