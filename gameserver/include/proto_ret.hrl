-define(Login_GS_Result_Succ,0). 	    %%	成功
-define(Login_GS_Result_Fail_Full,-1).	%%服务器暴满
-define(Login_GS_Result_Fail_Check,-2).	%%身份验证失败
-define(Login_GS_Result_Fail_Unvalid, -3).	%%服务器无效
-define(Login_GS_Result_Fail_Connect, -4).	%%链接失败
-define(Login_GS_Result_Fail_ProtVerErr,-5).%%协议版本匹配错误


-define(AcceptMailItem_Success,0).
-define(AcceptMailItem_NoCell,1).
-define(AcceptMailItem_NotEnoughMoney,2).
-define(AcceptMailItem_NoThisMail,3).
-define(AcceptMailItem_NoThisItem,4).
