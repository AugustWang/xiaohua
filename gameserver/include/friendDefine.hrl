-ifndef (friendDefine_hrl).

%最大好友数量
-define(Max_Friend,100).
%区分好友类型 ：好友/临时好友/黑名单
-define(Friend_Type_N,0).			%% 不是好友
-define(Friend_Type_F,1).			%%好友
-define(Friend_Type_T,2).			%%临时好友
-define(Friend_Type_B,3).			%%黑名单

-define(Friend_Tips_OK,		0).			%%确认/正确
-define(Friend_Tips_Max,	-1).		%%达到最大数量
-define(Friend_Tips_Exist,	-2).		%%已经存在列表
-define(Friend_Tips_NotExist,-3).	%%不存在 无法删除
-define( Friend_Tips_NotMe, -4).	%%不能添加自己为好友，黑名单，临时好友
-define( Friend_Tips_NotPlayer, -5).	%%玩家不存在，不能添加好友
-define( Friend_Tips_TargetCloseApplicateFriend, -6).	%%对方关闭好友申请功能



-endif. % -ifdef(friendDefine_hrl).