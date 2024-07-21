-define( ResetTimeOfBattleJoinTime, 4*3600). %%
%% 活动报名开始时间，活动结束报名时间，开始战斗时间，结束时间(没真正结束，是不让报名，不开启战场了)，活动开始前公告开始时间，活动开始前公告结束时间  活动期间公告开始时间 活动期间公告
-define( BattleJoinTimeInfo, [{73500,79200,73800,79200,72000,73800,73800,79200}]).%%这个是正式的 
%%-define( BattleJoinTimeInfo, [{13500,79200,13800,79200,12000,13800,13800,79200}]).%%这个是测试用的  
-define( BattleBroadcastInterval, 300). %%

-define( XuanzongOccuping, [#posInfo{x=3103,y=765},#posInfo{x=3194,y=864},#posInfo{x=3329,y=483},
							#posInfo{x=3392,y=543},#posInfo{x=3453,y=606},#posInfo{x=3520,y=674},
							#posInfo{x=3589,y=744},#posInfo{x=3486,y=479},#posInfo{x=3549,y=548},
							#posInfo{x=3617,y=604},#posInfo{x=3686,y=672},#posInfo{x=3746,y=744},
							#posInfo{x=3615,y=452},#posInfo{x=2673,y=525},#posInfo{x=3748,y=578}]). %%
-define( TianjiOccuping, [#posInfo{x=636,y=2082},#posInfo{x=737,y=2137},#posInfo{x=289,y=2339},
							#posInfo{x=345,y=2406},#posInfo{x=423,y=2458},#posInfo{x=490,y=2534},
							#posInfo{x=543,y=2592},#posInfo{x=139,y=2375},#posInfo{x=223,y=2441},
							#posInfo{x=297,y=2510},#posInfo{x=353,y=2558},#posInfo{x=417,y=2632},
							#posInfo{x=156,y=2497},#posInfo{x=224,y=2564},#posInfo{x=292,y=2626}]). %%
-record(resourceTakeupInfo,{iID,takeupTime,campus}).%%采集点的被占情况
-record(playerContinusKill,{playerID,playerName,campus,continusKillNum,numOfBeKilled,numOfKill,harmed,harm}).%%玩家
-record(playerEnroll,{playerID,playerCampus}).%%玩家报名
-record(battleLackPlayer,{sceneowerActorID,xuanzonglackNum,tianjilackNum}).%%记录战场缺人情况
-record(playerbattleInfo,{playerID,mapOwerID}).%%记录战场进入情况

-define( Cannot_Enroll_Success, 1). %%报名成功
-define( Cannot_Enroll_Not_Active_Period, -1). %%不是活动时间，不能报名
-define( Cannot_Enroll_Level_Limit, -2). %%不符合等级现在
-define( Cannot_Enroll_NPC_Too_Far, -3). %%距离NPC太远
-define( Cannot_Enroll_NPC_NotExist, -4). %%npc 不存在
-define( Cannot_Enroll_Player_NotExist, -5). %%玩家 不存在
-define( Cannot_Enroll_Player_State_Error, -6). %%状态不允许
-define( Cannot_Enroll_Player_In_Battle_List, -7). %%某个战场在等着他进去
-define( Cannot_Enroll_Num_Of_Player_Can_Join_Too_Few, -8). %%满足参与战场最低等级的人太少

-define( Cannot_EnterBattle_Success, 1). %%成功
-define( Cannot_EnterBattle_NoBattleInfo, -1). %%没有战场信息

-define( BattleSceneID, 42). %%战场ID