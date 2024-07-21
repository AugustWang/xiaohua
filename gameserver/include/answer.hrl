%% 答题相关
-record(answer_top,{playerid,name,score}).

%% 答题排名数量限制
-define(TOP_ANSWER_LIMIT,10).

%% 答题准备时间 1分钟
-define(READY_TIME,60*1000).
%% 答题时间间隔 1分钟
-define(QUESTION_INTERVAL,25*1000).

%% 答题题目数量限制
-define(QUESTION_LIMIT,20).
%% 游戏相关题目数量
-define(QUESTION_GAME,2).

%% 答题系统状态
-define(ANSWER_STATUS_NONE,0).		%% 未开启
-define(ANSWER_STATUS_READY,1).		%% 准备答题
-define(ANSWER_STATUS_QUESTION,2).	%% 答题中...

%% 题目类型
-define(QUESTION_TYPE_GAME,1).	%% 游戏相关题目
-define(QUESTION_TYPE_OTHER,2).	%% 其他

%% 玩家答题状态
-define(ANSWER_USER_STATE_NONE,0).		%% 无
-define(ANSWER_USER_STATE_WAITCOMMIT,1).	%% 等待玩家提交答案
-define(ANSWER_USER_STATE_COMMITED,1).		%% 已提交答案

%% 特殊功能定义
-define(ANSWER_SPECIAL_RIGHT,0).		%% 正确答案
-define(ANSWER_SPECIAL_EXCLUDE,1).		%% 排除两项错误
-define(ANSWER_SPECIAL_DOUBLE,2).		%% 双倍积分

%% 排名奖励
-define(ANSWER_TOP_AWARD_ITEMID,5229).		%% 排名奖励物品ID
-define(ANSWER_TOP_AWARD_COUNT1,3).		%% 排名1奖励物品个数
-define(ANSWER_TOP_AWARD_COUNT2,2).		%% 排名2奖励物品个数
-define(ANSWER_TOP_AWARD_COUNT10,1).		%% 排名3-10奖励物品个数
-define(ANSWER_TOP_AWARD_MAIL_TITLE,"答题排名奖励").		%% 排名1奖励物品邮件标题
-define(ANSWER_TOP_AWARD_MAIL1,"你参加答题获得第一名！请查收奖励").		%% 排名1奖励物品邮件内容
-define(ANSWER_TOP_AWARD_MAIL2,"你参加答题获得第二名！请查收奖励").		%% 排名2奖励物品邮件内容
-define(ANSWER_TOP_AWARD_MAIL10,"你参加答题获得前十的名次！请查收奖励").		%% 排名3-10奖励物品邮件内容

