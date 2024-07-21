-ifndef(taskDefine_hrl).

%%玩家已经接收任务条件信息
-record(aimProgress, {type, index, maxCount, curCount} ).

%%玩家可以接收多少任务
-define( Max_Player_Accepte_Task, 20 ).

%%任务类型
-define(TASK_MAIN, 0).
-define(TASK_SUB, 1).
-define(TASK_DAILY, 3).
-define(TASK_LOOP, 4).
-define(TASK_OTHER, 5).

%% task base
-define(TASKSTATE_UNDO, 0).
-define(TASKSTATE_ACCEPT, 1).
-define(TASKSTATE_FINISH, 2).
-define(TASKSTATE_DONE, 3).

%%任务条件类型ETaskType
-define( TASKTYPE_TALK, 1 ). %%//对话
-define( TASKTYPE_MONSTER, 2). %%//杀怪
-define( TASKTYPE_COLLECT, 3). %%//采集
-define( TASKTYPE_ITEM, 4). %%//物品收集
-define( TASKTYPE_USEITEM, 5). %%//使用物品
-define( TASKTYPE_BUSINESS, 6). %%//跑商
-define( TASKTYPE_GUARD, 7). %%//守卫
-define( TASKTYPE_PRMRY_ESCORT, 8). %%//护送
-define( TASKTYPE_ADVN_ESCORT, 9). %%//高级护送
-define( TASKTYPE_SPECIAL, 10). %%//其他
-define( TASKTYPE_SHOP, 11). %%//商店
-define( TASKTYPE_TEACH, 12). %%//教学
-define( TASKTYPE_GUILD, 13). %%//帮会
-define( TASKTYPE_STORAGE, 14). %%//仓库
-define( TASKTYPE_COPYMAP, 15). %%//副本
-define( TASKTYPE_ACTIVEEQUIP, 16). %%//激活装备
-define( TASKTYPE_LEARNSKILL, 17). %%//学习技能
-define( TASKTYPE_BUYITEM, 21). %%//购买物品

%%归还任务情况
-define( Commit_Success, 0).%%成功
-define( Commit_FullBag, -1).%%背包满

%%随机日常相关,目前就一个茶馆任务，可扩展
%%随机任务记录
-define( RandomDailyResetTime, 14400). %%随机任务每天重置时间
-define( RandomDailyFinshTimePerDay, 3). %%随机任务每天可以完成的次数
-define( RandomDailyTeahousesGroupID, 1). %%茶馆任务给个ID

%%茶馆任务,前面5个是5组的开头，后面一个表示一组的任务个数，最后一个表示完成了多少组
%%改过
-define(RandomDailyTeahousesGroupInfo,[?RandomDailyTeahousesGroupID,[6500,6510,6520,6530,6540],10,3]).
-define(AllRandomDaily,[?RandomDailyTeahousesGroupInfo]).%%所有随机任务的记录
-define(RandomDailyMinID,6500).%%所有随机任务最小ID
-define(RandomDailyMaxID,6550).%%所有随机任务最大ID
-define(RandomDailyMinLevel,31).%%所有随机任务最小接受等级

%%---------------------start-------------------------------------
%%声望任务相关
-define( ReputationStartID, 5000). %%声望任务开始ID
-define( ReputationEndID, 5100). %%声望任务结束ID
-define( ReputationID, 2). %%声望任务给个ID
-define( ReputationMaxTime, 10). %%声望任务完成次数
-record(reputationInfo, {taskID,process} ).%%声望任务记录
-define( ReputationResetTime, 4*3600). %%声望任务重置时间
-define( PredeccessorTask , [[5007,5008],[5009,5010],[5011,5012],[5019,5020],[5021,5022],[5023,5024],[5033,5034],[5035,5036],[5037,5038]]). %%任务的后续任务
-define( ReputationMinLevel, 31). %%声望任务最低等级
%%------------------------end-------------------------------------

%%采集任务相关
-define( GatherTaskID, 7500). %%采集任务ID
-define( GatherTaskMaxTime, 3). %%采集任务完成次数
-define( GatherTaskStartTime, 41400). %%采集任务开始时间
-define( GatherTaskEndTime, 43200). %%采集任务结束时间
-define( GatherTaskMinLevel, 31). %%采集任务最低等级

-define( GatherResetTime, 14400). %%采集任务重置时间,这个是在采集活动时间段内重置吧

-define( ConvoyResetTime, 14400). %%护送任务重置时间.

-define( GatherTaskStartTime2, 70200). %%采集任务开始时间
-define( GatherTaskEndTime2, 72000). %%采集任务结束时间

-define( GatherTaskBroadCastInterval, 300). %%采集公告间隔



-endif. % -ifdef(taskDefine_hrl).
