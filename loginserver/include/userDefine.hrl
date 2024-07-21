-ifndef(userDefine_hrl).



%%每一个用户数据
-record( userSocketRecord, {socket, userName, userID, randIdentity, ip,platId } ).

%% 登录验证返回数据
%-record( userDBLoginResult, {resultCode, msg, userID, userName } ).
-record( userDBLogin, {account,platformID,versionRes,versionExe,versionGame,versionPro} ).
-record( userDBLoginResult, {resultCode, account, userID,platId} ).

%% 登录验证返回码
-define( Login_LS_Result_Succ, 	0 ).					%%验证成功，可以登录游戏服务器
-define( Login_LS_Result_Fail_UserNameOrPassword, -1 ).			%%验证失败，用户名密码错误
-define( Login_LS_Result_Fail_OtherLogin,-2 ).				%%验证失败，重复登录
-define( Login_LS_Result_Fail_Kickout, 	-3 ).				%%被踢下线
-define( Login_LS_Result_Fail_Freeze,	-4 ).				%%该账户已经被冻结，禁止登录
-define( Login_LS_Result_Fail_Connect, 	-5 ).				%%尚未连接登录服务器
-define( Login_LS_Result_Fail_Empty, 	-6 ).				%%用户名密码不能为空
-define( Login_LS_Result_Fail_DbError, 	-7 ).				%%验证失败，写数据库失败
-define( Login_LS_Result_Fail_Unknown, 	-8 ).				%%验证失败，未知错误
-define( Login_LS_Result_Fail_Exception,-9 ).				%%验证失败，异常错误
-define( Login_LS_Result_Fail_Unsupport,-10 ).				%%验证失败，登录服务器不支持该平台验证
-define( Login_LS_Result_Fail_Timeout,-11 ).				%%验证失败，验证超时
-define( Login_LS_Result_Fail_Disconnect,-12 ).				%%验证失败，网络断开
-define( Login_LS_Result_Fail_Forbidden,-13 ).				%%验证失败，帐号被封


-define( UserState_UnCheckPass, 0 ).
-define( UserState_WaitCheckPass, 1 ).
-define( UserState_WaitKickOutOther, 2 ).
-define( UserState_WaitUserAskGameServerList, 3 ).
-define( UserState_WaitGameServerListAck, 4 ).
-define( UserState_WaitUserSelGameServer, 5 ).
-define( UserState_WaitSelGameServerResult, 6 ).
-define( UserState_WaitCloseUserSocket, 7 ).
-define( UserState_WaitGameServerAckMaxPlayerLevel, 8 ).
-define( UserState_WaitGameServerAckLogin, 9 ).

-endif. % -ifdef(userDefine_hrl).
