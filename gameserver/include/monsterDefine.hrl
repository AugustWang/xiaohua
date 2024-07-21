-ifndef(monsterDefine_hrl).

%%MonsterAI状态
%%闲
-define( Monster_AI_State_Idle, 0 ).
%%战斗
-define( Monster_AI_State_Fighting, 1 ).
%%往回跑
-define( Monster_AI_State_GoBack, 2 ).
%%尸体
-define( Monster_AI_State_Body, 3 ).
%% sleep
-define( Monster_AI_State_Sleep, 4 ).

%%从死亡到从地图消失时间
-define( Monster_Dead_Disapear_Time, 2*1000*1000 ).

%%不会主动攻击，也不会还击，就是木桩
-define( Monster_Attack_Mode_Stake, 0 ).
%%会攻击所有玩家
-define( Monster_Attack_Mode_AllPlayer, 1 ).
%%只会攻击敌对阵营玩家，不会攻击本阵营玩家，也会被敌对阵营玩家攻击，也不会被本阵营玩家攻击
-define( Monster_Attack_Mode_Faction, 2 ).


-endif. % -ifdef(monsterDefine_hrl).