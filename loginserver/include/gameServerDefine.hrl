-ifndef(gameServerDefine_hrl).

-record( gameServerUsers,{userID,reserve} ).

-define( GameServer_State_UnCheckPass,	0 ).
-define( GameServer_State_CheckPass,	1 ).
-define( GameServer_State_Running,	2 ).
-define( GameServer_State_Closed,	4 ).
-define( GameServer_State_GSIni,	5 ).

%%服务器列表中游戏服务器状态
-define( GameServer_User_State_Normal,	0 ).%%正常
-define( GameServer_User_State_Hot,	1 ).%%火爆
-define( GameServer_User_State_Full,	2 ).%%爆满
-define( GameServer_User_State_Maintain,	3 ).%%维护
-define( GameServer_User_State_Set_Closed,	4 ).
-define( GameServer_User_State_SpecCanVisable,	5 ).%%测试人员可见


%%服务器在线人数状态显示
-define( GameServer_Online_State_Normal_Min,  0	).%%正常最小值
-define( GameServer_Online_State_Normal_Max,  10	).%%正常最大值

-define( GameServer_Online_State_Hot_Min,  11	).%%火爆最小值
-define( GameServer_Online_State_Hot_Max,  20	).%%火爆最大值

-define( GameServer_Online_State_Full_Min,  21	).%%爆满最小值
-define( GameServer_Online_State_Full_Max,  2000	).%%爆满最大值


-endif. % -ifdef(gameServerDefine_hrl).
