%% vip definitions 
%% add by yueliangyou [2013-05-07]

%% VIP数据重置时间
-define(VIP_RESET_TIME,4*3600).

%% 非VIP会员
-define(VIP_LEVEL_NONE,0).
%% 试用VIP会员
-define(VIP_LEVEL_TRIAL,1).
%% 青铜VIP会员
-define(VIP_LEVEL_BRONZE,2).
%% 白银VIP会员
-define(VIP_LEVEL_SILVER,3).
%% 黄金VIP会员
-define(VIP_LEVEL_GOLD,4).
%% 钻石VIP会员
-define(VIP_LEVEL_DIAMOND,5).

%% 3天时长VIP卡，体验VIP
-define(VIP_CARD_TRIAL,0).
%% 10天时长VIP卡
-define(VIP_CARD_10,1).
%% 30天时长VIP卡
-define(VIP_CARD_30,2).
%% 180天时长VIP卡
-define(VIP_CARD_180,3).
%% 360天时长VIP卡 
-define(VIP_CARD_360,4).

-define(VIP_NONE_TIME,0).
-define(VIP_TRIAL_TIME,3*24*3600).
-define(VIP_BRONZE_TIME,10*24*3600).
-define(VIP_SILVER_TIME,30*24*3600).
-define(VIP_GOLD_TIME,180*24*3600).
-define(VIP_DIAMOND_TIME,360*24*3600).

%% vip信息,等级，失效时间，总购买时长
-record(vipInfo,{level,timeExpire,timeBuy}).
-record(vipCard,{type,time}).

%%------------VIP功能相关--------------------------
-record(vipFunParam,{value,param}).

%% 测试功能
-define(VIP_FUN_TEST,0).
%% VIP礼包
-define(VIP_FUN_GIFT,0).
%% VIP定时礼包
-define(VIP_FUN_GIFT_TIMER,0).
%% VIP经验加成
-define(VIP_FUN_EXP_KILLMONSTER,10).	%% 打怪经验加成
-define(VIP_FUN_EXP_ACTIVE,11).		%% 活跃度经验加成
%% 喇叭免费
-define(VIP_FUN_TRUMPET,20).
%% 飞行符免费
-define(VIP_FUN_FLY,30).
%% 远程商店
-define(VIP_FUN_REMOTE_SHOP,40).
%% 远程仓库
-define(VIP_FUN_REMOTE_STORE,41).
%% 副本收益次数
-define(VIP_FUN_FUBEN,50).
%% 加玩家属性
-define(VIP_FUN_PROPERTY,60).
%% 提升强化成功率
-define(VIP_FUN_RATE1,90).
%% 提升宠物升品成功率
-define(VIP_FUN_RATE2,100).
%% 提升宠物升灵成功率
-define(VIP_FUN_RATE3,110).










