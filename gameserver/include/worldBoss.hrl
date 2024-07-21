
-ifndef(WorldBoss_hrl).
-define(GaveExpInterval,10).
-define(BroadcastAheadTime,-600).%%公告相对于刷boss 提前多少s
-define(BroadcastInterval,300).%%公告间隔
-define(WorldBossDailyCfg,3).%%世界boss 在daily表格中的配置
-define(AwardPlayerNum,10).%%能够领奖的玩家数量
-define(RandAwardNum,5).%%随机抽奖的玩家数量
-define(WorldBossAwardItemofJoin,3103).

-record(worldBossharmInfo, {playerID, harmData,mapPID,playerName}).
-record(worldBossStatus, {mapPID,isKilled,bossleftBlood,gS2U_RankList}).%%某个地图的boss 是否被杀掉了

-endif.
