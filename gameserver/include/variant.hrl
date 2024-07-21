-ifndef(variant_hrl).

%%变量类型，未初始化
-define( Variant_Type_Unvalid, 0 ).
%%变量类型，玩家
-define( Variant_Type_Player, 1 ).
%%变量类型，世界
-define( Variant_Type_World, 2 ).
%%变量类型，工会
-define( Variant_Type_Guild, 3 ).

%%玩家变量最大个数
-define( Max_PlayerVariant_Count, 100 ).
-define( Max_PlayerVariant_Syn_Client_Count, 50 ).

%%世界变量最大个数
-define( Max_WorldVariant_Count, 100 ).
-define( Max_WorldVariant_Syn_Client_Count, 50 ).


%%---------------------------------------------------玩家变量--------------------------------------------------------------
%% 玩家变量分为两类，1是客户端服务器共享；2是服务器专用
%% 每一类里面又分为三类，1是只在玩家进程使用(以_P结束)， 2是只在地图进程使用 (以_M结束) 3是即在地图进程中使用也在玩家进程使用(以_B结束,目前不支持)
%%1---Max_PlayerVariant_Syn_Client_Count, 客户端服务器共享，需要同步客户端
%%玩家充值礼包领取标志
-define( PlayerVariant_Index_CZLBLQ_P, 1 ).
%% 玩家充值礼包类型,每个类型对应第PlayerVariant_Index_CZLBLQ_P的玩家变量中的位
-define( RECHARGE_GIFT_BIT_0_P,0).
-define( RECHARGE_GIFT_BIT_1_P,1).
-define( RECHARGE_GIFT_BIT_2_P,2).
-define( RECHARGE_GIFT_BIT_3_P,3).
-define( RECHARGE_GIFT_BIT_4_P,4).
-define( RECHARGE_GIFT_BIT_5_P,5).
-define( RECHARGE_GIFT_BIT_6_P,6).
-define( RECHARGE_GIFT_BIT_7_P,7).
-define( RECHARGE_GIFT_BIT_8_P,8).
-define( RECHARGE_GIFT_BIT_9_P,9).
-define( RECHARGE_GIFT_BIT_10_P,10).
-define( RECHARGE_GIFT_BIT_11_P,11).
-define( RECHARGE_GIFT_BIT_12_P,12).
-define( RECHARGE_GIFT_BIT_13_P,13).
-define( RECHARGE_GIFT_BIT_14_P,14).
-define( RECHARGE_GIFT_BIT_15_P,15).
-define( RECHARGE_GIFT_MAX,16).

%% 玩家查看世界boss排名的最近的时间
-define( PlayerVariant_Index_WorldBossLastViewTime_P, 2 ).

%%活动相关属性位置，告诉客户端是否活动因为次数用完等原因不能做 1 表示能做，0表示不能做
-define( PlayerVariant_Index_3_Active_P,3).
-define( PlayerVariant_Index_3_Active_Escort,0).   %%护送双倍次数是否用完，占用PlayerVariant_Index_3_Active_P值的第1位
-define( PlayerVariant_Index_3_Active_Gather,1).   %%采集任务次数是否用完，占用PlayerVariant_Index_3_Active_P值的第2位


%%活动相关属性(次数)
-define( PlayerVariant_Index_Active_Times_Low_Escort_P,4).%%低级护送
-define( PlayerVariant_Index_Active_Times_High_Escort_P, 5). %%高级护送

%%声望相关
-define( PlayerVariant_Index4_Credit_Get_Today_P, 6). %%今天已经获得的声望，需要重置

%%多倍经验
-define( PlayerVariant_Index7_Multy_Exp_M, 7). %%玩家通过使用物品增加的多倍经验的时间

%%组队邀请状态
-define( PlayerVariant_Index_3_Team_P, 8).
-define( PlayerVariant_Index_3_Team_State,1). %%第一位

%%VIP数据记录
-define( PlayerVariant_Index_9_VIP_FLY_P, 9). %% VIP免费飞行次数记录
-define( PlayerVariant_Index_9_VIP_TRUMPET_P, 10). %% VIP免费小喇叭次数记录
-define( PlayerVariant_Index_9_VIP_FUBEN_P, 11). %% VIP免费副本收益次数记录

%%合成记录
-define( PlayerVariant_Index12_Compound_Exp_P, 12). %%合成经验
-define( PlayerVariant_Index12_Compound_Level_P, 13). %%合成等级

%%答题记录
-define( PlayerVariant_Index_14_Answer_Num, 14). %% 当前题目ID
-define( PlayerVariant_Index_14_Answer_State, 15). %% 答题状态
-define( PlayerVariant_Index_14_Answer_Score, 16). %% 答题分数
-define( PlayerVariant_Index_14_Answer_Special_Double, 17). %% 答题特殊功能双倍积分
-define( PlayerVariant_Index_14_Answer_Special_Right, 18). %% 答题特殊功能正确答案
-define( PlayerVariant_Index_14_Answer_Special_Exclude, 19). %% 答题特殊功能排除答案

%%2 Max_PlayerVariant_Syn_Client_Count以上，服务器专用，不同步客户端，
-define( PlayerVariant_Index_InPeaceKilledByPlayerTime_M, ?Max_PlayerVariant_Syn_Client_Count+1 ).
-define( PlayerVariant_Index_Ban_Relive_M, ?Max_PlayerVariant_Syn_Client_Count+2). %%禁止玩家复活
-define( PlayerVariant_Index_Honor_Get_Today_P, ?Max_PlayerVariant_Syn_Client_Count+3). %%今天已经获得的荣誉，需要重置


%%---------------------------------------------------玩家变量--------------------------------------------------------------


%%---------------------------------------------------世界变量--------------------------------------------------------------
%% 世界变量 (全局变量) 服务器存放在mainGlobal ets varArray, 不存档
%% 分为两类，1是客户端服务器共享；2是服务器专用
%%1---Max_WorldVariant_Syn_Client_Count, 客户端服务器共享，需要同步客户端
-define( WorldVariant_Index_1,1).
-define( WorldVariant_Index_1_PeriodPkProt_Bit0,0).   %%是否处于定时pk保护模式，占用WorldVariant_Index_1值的第1位
-define( WorldVariant_Index_1_Active_Escort,1).   %%护送双倍提示，先占位，占用WorldVariant_Index_1值的第2位
-define( WorldVariant_Index_1_Active_Gather,2).   %%采集任务，占用WorldVariant_Index_1值的第3位

-define( WorldVariant_Index_2_BazzarUpdateTime, 2).		%%商城下一次刷新的时间
-define( WorldVariant__Num_Of_Player_Can_Join_Battle, 3).		%%能够参加战场的玩家数量










%%2 Max_WorldVariant_Syn_Client_Count以上，服务器专用，不同步客户端
-define(WorldVariant_Index_51,?Max_WorldVariant_Syn_Client_Count+1).
-define(WorldVariant_Index_51_PingFlag_Bit0,0).

-endif.
