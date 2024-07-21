%% 系统消息定义
-define(SYSTEM_MESSAGE_ERROR, 1). 	%% 系统错误
-define(SYSTEM_MESSAGE_PROMPT, 2).	%% 系统提示
-define(SYSTEM_MESSAGE_BOX, 3).		%% 弹出对话框
-define(SYSTEM_MESSAGE_ANNOUNCE, 4).  	%% 公告
-define(SYSTEM_MESSAGE_TIPS, 5).  	%% 提示信息

-define(CHAT_CHANNEL_SYNTHESIZE, 0). %%综合
-define(CHAT_CHANNEL_WORD, 1). %%世界
-define(CHAT_CHANNEL_PRIVATE, 2). %%私聊
-define(CHAT_CHANNEL_TEAM, 3). %%队伍
-define(CHAT_CHANNEL_LEAGUE, 4). %%帮会
-define(CHAT_CHANNEL_SYSTEM, 5). %%系统
-define(CHAT_CHANNEL_COUNT, 6). %%
-define(CHAT_CHANNEL_Trumpet, 7). %%喇叭
-define(CHAT_CHANNEL_UNKNOW, 8). %%

%%speak间隔时间
-define(Speak_Space_Time, 5).

%%聊天错误返回
-define(Speak_Error_Colding, 1).  %%冷却中
-define(Speak_Error_TargetNotOnline, 2). %%
-define(Speak_Error_NotItem, 3). %%
%%player chat
-record(chat, {channel, sendID, sendName, receiveID, receiveName, content} ).
