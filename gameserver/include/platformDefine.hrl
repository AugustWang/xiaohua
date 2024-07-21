-ifndef(platformDefine_hrl).

-record(platformTable, {platformID, isSupport, ip, port} ).


%% 与皮皮平台消息命令定义
-define( CMD_PLATFORM_PP_VERIFY,16#AA000022 ).
-define( CMD_PLATFORM_PP_VERIFY_RET,16#AA00F022 ).

%% 与皮皮平台验证消息请求
%% commmand = 0xAA000022
-record(pk_LS2PlatformPP_Verify, {
        len,
        commmand,
        token_key
        }).

%%与皮皮平台验证结果返回消息
%% commmand = 0xAA00F022 status = 0 成功，失败为其他值
-record(pk_LS2PlatformPP_Verify_Ret, {
        len,
        commmand,
        status,
        username
        }).

%%----------------------------------------------------------------------
%%-------以下是553平台--------------------------------------------------
%%----------------------------------------------------------------------

%%各个平台定义标识符
-define( PLATFORM_TEST,	100 ).
-define( PLATFORM_553, 	101 ).
-define( PLATFORM_PP, 	102 ).
-define( PLATFORM_APPS,	103 ).
-define( PLATFORM_360, 	111 ).
-define( PLATFORM_553_android, 	108 ).
-define( PLATFORM_UC_android, 	110 ).
-define( PLATFORM_91_IOS, 	104 ).
-define( PLATFORM_91_android, 	109 ).



%% 553平台
-define( KEY_PLATFORM_553_VERIFY, "shfihdqhwkhuskdgnlkjioajiwbjdnasce" ).
-define( KEY_PLATFORM_553_ANDROID_VERIFY, "weuhfwalkwjejahdauhdoqhdohqwoh" ).
-define( KEY_PLATFORM_553_RECHARGE,"as;djfw75d4fsdkfsd6^&w8a7a;4e52" ).
-define( KEY_PLATFORM_553_COMMAND, "daslkw75d4p;^fsadh6^&w8a7a;4d82" ).
-define( KEY_PLATFORM_APPS_VERIFY, "shfihdqhwkhuskdgnlkjioajiwbjdnasce" ).
%% 360 平台
-define( APP_ID_360, "200455331" ).
-define( APP_KEY_360, "ad5f4dd4a99318fa02d805878e3aa802" ).
-define( APP_PRIVATE_KEY_360, "925bea7aee1030525642e6af934b551e" ).
-define( APP_SECRET_360, "69b1fe3610f6e316fcfad2341a3f1b2d" ).

%%UC
-define( UC_Test_apiKey, "54520eb3c61318c120052da361684207" ).
-define( UC_Test_CPID, 1 ).
-define( UC_Test_GameID, 382 ).
-define( UC_Test_ServerID, 1366 ).
-define( UC_Test_ChannelID, "2" ).

-define( UC_Officially_apiKey, "7c3b2b17bba0bc56cef3ef0444ef7562" ).
-define( UC_Officially_CPID, 23184 ).
-define( UC_Officially_GameID, 506322 ).
-define( UC_Officially_ServerID, 1859 ).
-define( UC_Officially_ChannelID, "2" ).

%% 91平台
-define( APP_ID_91, "109132" ).
-define( APP_KEY_91, "f938a4baa3027903b077f418d112c83321f786a0d500d557" ).
-define( APP_ID_91_android, "109132" ).
-define( APP_KEY_91_android, "f938a4baa3027903b077f418d112c83321f786a0d500d557" ).

%% 与553平台消息长度定义
-define( CMD_PLATFORM_553_HEADER_SIZE,8 ).
-define( CMD_PLATFORM_553_MAX_SIZE,1024 ).
%% 公告消息的最大长度，200个汉字以内
-define( CMD_PLATFORM_553_ANNOUNCE_MAX_SIZE,212 ).

%% 与553平台消息命令定义
-define( CMD_PLATFORM_553_RECHARGE,16#0000AA01 ).
-define( CMD_PLATFORM_553_RECHARGE_RET,16#0000FF01 ).
-define( CMD_PLATFORM_553_ACTIVE_CODE,16#0000AA10 ).
-define( CMD_PLATFORM_553_ACTIVE_CODE_RET,16#0000FF10 ).
-define( CMD_PLATFORM_553_ANNOUNCE,16#0000AA20 ).
-define( CMD_PLATFORM_553_COMMAND,16#0000AA30 ).
-define( CMD_PLATFORM_553_COMMAND_RET,16#0000FF30 ).
-define( CMD_PLATFORM_553_ADD_GSCONFIG,16#0000AA40 ).
-define( CMD_PLATFORM_553_ADD_GSCONFIG_RET,16#0000FF40 ).
-define( CMD_PLATFORM_553_SUB_GSCONFIG,16#0000AA50 ).
-define( CMD_PLATFORM_553_SUB_GSCONFIG_RET,16#0000FF50 ).

-define( PLATFORM_RCODE_ACTIVE_CODE_OK,0 ).
-define( PLATFORM_RCODE_ACTIVE_CODE_NOGS,-1 ).
-define( PLATFORM_RCODE_ACTIVE_CODE_NOPLAYER,-2 ).
-define( PLATFORM_RCODE_ACTIVE_CODE_MAIL_FAILED,-3 ).

-define( PLATFORM_RCODE_COMMAND_OK,0 ).
-define( PLATFORM_RCODE_COMMAND_NOGS,-1 ).
-define( PLATFORM_RCODE_COMMAND_NOPLAYER,-2 ).
-define( PLATFORM_RCODE_COMMAND_FAILED,-3 ).
-define( PLATFORM_RCODE_COMMAND_ERROR_PARAMS,-4 ).

-define( PLATFORM_RCODE_RECHARGE_OK,0 ).
-define( PLATFORM_RCODE_RECHARGE_NOGS,-1 ).
-define( PLATFORM_RCODE_RECHARGE_NOPLAYER,-2 ).
-define( PLATFORM_RCODE_RECHARGE_FAILED,-3 ).	%% 操作失败

-define( PLATFORM_SENDITEM_COUNT,2 ).	%% 最多支持给玩家发放物品的数量

%% 指令定义
-define( PLATFORM_COMMAND_SENDITEM,1 ).		%% 给玩家发送物品
-define( PLATFORM_COMMAND_BAZZAR,2 ).		%% 通知商城重新加载数据
-define( PLATFORM_COMMAND_SENDITEM_EX,3 ).	%% 给玩家发放物品扩展
-define( PLATFORM_COMMAND_ADD_GM_USER, 4).  %% 设置某角色为gm用户
-define( PLATFORM_COMMAND_ADD_WHITE_USER, 5).  %% 设置白名单
-define( PLATFORM_COMMAND_ADD_FORBIDDEN_USER_LOGIN, 6).  %% 禁止帐户登陆
-define( PLATFORM_COMMAND_KILLOUT_USER, 7).  %% 踢角色下线
-define( PLATFORM_COMMAND_FORBIDDEN_USER_CHAT, 8).  %% 禁止角色聊天
-define( PLATFORM_COMMAND_FORBIDDEN_ACCOUNT, 9).  %% 限定帐号
-define( PLATFORM_COMMAND_SWITCH_USERID, 11).  %% 将某帐号下某角色的userid转换到某帐号下

%%与553平台通知游戏处理充值消息
%% commmand = 0x0000AA01 
-record(pk_LS2Platform553_Recharge, {
        len,
        commmand,
	orderid,
	platform,
	lsid,
	gsid,
	account,
	userid,
	playerid,
	ammount,
	time,
	sign
	}).

%%与553平台通知游戏处理充值返回消息
%% commmand = 0x0000FF01 retcode = 0 成功，失败为其他值
-record(pk_LS2Platform553_Recharge_Ret, {
        len,
        commmand,
	orderid,
	platform,
	retcode
	}).

%%与553平台通知游戏处理激活码消息
%% commmand = 0x0000AA10 
-record(pk_LS2Platform553_Active_Code, {
        len,
        commmand,
	activecode,
	gsid,
	player,
	type
	}).

%%与553平台通知游戏处理激活码返回消息
%% commmand = 0x0000FF10 retcode = 0 成功，失败为其他值
-record(pk_LS2Platform553_Active_Code_Ret, {
        len,
        commmand,
	activecode,
	retcode
	}).

%%与553平台通知游戏处理公告消息
%% commmand = 0x0000AA20 
-record(pk_LS2Platform553_Announce, {
        len,
        commmand,
	gsid,
	announceinfo
	}).

%%与553平台通知游戏处理GM命令消息
%% commmand = 0x0000AA30 
-record(pk_LS2Platform553_Command, {
        len,
        commmand,
	gsid,
	num,
	cmd,
	params,
	time,
	sign
	}).

%%与553平台通知游戏处理GM命令返回消息
%% commmand = 0x0000FF30 retcode = 0 成功，失败为其他值
-record(pk_LS2Platform553_Command_Ret, {
        len,
        commmand,
	num,
	cmd,
	retcode
	}).

-endif. % -ifdef(platformDefine_hrl).

-record(pk_LS2Platform553_Add_GsConfig, {
        len,
        commmand,
	serverid,
	name,
	isnew,
	begintime,
	recommend,
	hot
	}).

-record(pk_LS2Platform553_Add_GsConfig_Ret, {
        len,
        commmand,
	serverid,
	ret	
	}).

-record(pk_LS2Platform553_Sub_GsConfig, {
        len,
        commmand,
	serverid	
	}).
-record(pk_LS2Platform553_Sub_GsConfig_Ret, {
        len,
        commmand,
	serverid,
	ret	
	}).
