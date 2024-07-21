-ifndef(teamDfine_hrl).

%%队伍信息
-record( teamInfo, {teamID, leaderPlayerID, memberList } ).

%%队伍临时信息(邀请者列表)
-record( inviteList, {playerID, inviteID}).

%%队员在地图中的信息
-record( teamMemberMapInfo, { playerID, playerName, level, camp, fation, sex, life_percent, x, y, map_data_id, mapID, mapPID, playerPID } ).

%%队员信息
-record( teamMemberInfo, {
						  teamMemberMapInfo,
						  isOnline,
  						  joinTime
						  } ).

%%队伍进程玩家信息
-record( teamPlayerInfo, {
						  playerID,
						  teamID,
						  teamMemberMapInfo,
						  isOnline,
						  offlineTime,
  						  inviteTargetList
						  } ).

%%邀请有效时间，单位：秒
-define( TeamInviteTime, 45 ).
%%定时更新队伍成员简单信息
-define( TeamUpdateShortInfo, 5*1000 ).
%%定时更新邀请列表
-define( TeamUpdateInviteList, 10*1000 ).
%%队伍最大成员数量
-define( TeamMember_MaxCount, 4 ).
%%定时删除无队玩家
-define( TeamDeletePlayerTimer, 60*1000 ).

%%邀请目标信息
-record( teamInviteTargetInfo, { playerID, time } ).

%%队伍操作结果码
-define( Team_OP_Result_Succ, 0 ).	%%操作成功
-define( Team_OP_Result_Fail_InvalidCall, -1 ).	%%无效的操作
-define( Team_OP_Result_Fail_HasTeamSelf, -2 ).	%%你已经有队
-define( Team_OP_Result_Fail_HasTeamTarget, -3 ).	%%对方已经有对
-define( Team_OP_Result_Fail_ExistInvite, -4 ).	%%重复邀请
-define( Team_OP_Result_Fail_InviteTimeOut, -5 ).	%%邀请回复超时
-define( Team_OP_Result_Fail_RefuseCreate, -6 ).	%%对方拒绝组队
-define( Team_OP_Result_Fail_NotOnline, -7 ).	%%对方不在线
-define( Team_OP_Result_Fail_NeedTeamLeader, -8 ).	%%需要队长操作
-define( Team_OP_Result_Fail_FullMember, -9 ).	%%队伍满员
-define( Team_OP_Result_Fail_TargetIsNotLeader, -10 ).	%%对方已经在队伍里且不是队长
-define( Team_OP_Result_Fail_NotSameCamp, -11 ).	%%不是同一个阵营
%-define( Team_OP_Result_Fail_TargetCloseJoinTeamFunc, -11 ). %%对方关闭了组队申请功能


%% %%ç©å®¶ç»éåè¡¨å é¤æ¶é
%% -define(Player_AddTeamList_DeleteTime,10).
%% -define(TeamOffLine_DeleteTime,20).
%% 
-define(TeamList_UpdataTime,1000).
-define(TeamMemberLoc_UPdataTime,1000).
%% 
%% %%ç©å®¶ç»éæåµæä¸¾
%% -define( Player_is_in_the_group, true ).
%% -define( Player_is_not_have_group, false).
%% 
%% %%ç©å®¶éé¿flag
%% -define( Player_is_leader,true).
%% -define( Player_is_not_leader,false).
%% 
%% %%ç©å®¶å¨çº¿flag
%% -define( Player_is_online,true).
%% -define( Player_is_not_online,false).
%% 
%% %%ç©å®¶æ¯å¦å¯ä»¥éè¯·flag
%% -define( Player_can_invite,true).
%% -define( Player_can_not_invite,false).
%% 
%% -define(LineMark_on,1).
%% -define(LineMark_off,0).
%% %%ç»ééè¯·æ¯å¦ææflag
%% -define(Invite_Occupy,true).
%% -define(Invite_UnOccupy,false).
%% 
%% %%邀请列表 flag add or delete
%% -define(InviteList_add,1).
%% -define(InviteList_delete,2).
%% 
%% -define(ListType_invite,1).
%% -define(ListType_requst,2).
%% 
%% %%邀请列表flag invite or requste
%% -define(InviteList_invite,inviteList).
%% -define(InviteList_requst,requstList).
%% 
%% -define(RecordInviteListName(Vaule),Vaule). %%inviteList
%% 
%% -define(RecordInviteVauleName,inviter).
%% -define(RecordrequstVauleName,requster).
%% 
%% -define(CallFuncWhitThreeParameter(FuncName,Vaule,Vaule2,Vaule3),FuncName(Vaule,Vaule2,Vaule3)).
%% -define(GetRecordVaule(RcordName,RcordVaule),#RcordName.RcordVaule).
%% %%更换队长状态  更换并保留原队长在队伍  or 更换并踢出原队长 
%% 
%% -define(ChangeLeader_WithOldLedaerOutGroup,oldLeaderOutGroup).
%% -define(ChangeLeader_WithKeepOldLeaderInTheGroup,keepOldLeaderInGroup).
%% 
%% %%异常状态枚举
%% -define(TeamMsg_HaveTeam,1).       %%玩家已经拥有组队
%% -define(TeamMsg_NotHaveTeam,2).    %%玩家没有队伍
%% -define(TeamMsg_KickOut,3).        %%被踢出队伍
%% -define(TeamMsg_NotLeader,4).      %%玩家不是队长
%% -define(TeamMsg_VetoInvite,5).     %%玩家拒绝邀请
%% -define(TeamMsg_VetoRequst,6).     %%玩家拒绝申请
%% -define(TeamMsg_PlayerOffline,7).  %%玩家离线
%% -define(TeamMsg_ListTimeOut,8).    %%列表超时
%% -define(TeamMsg_WrongMap,9).       %%该地图不支持组队
%% -define(TeamMsg_non_existent,10).  %%队伍不存在
%% %%%%%%%%%%%%%%%%%%%%%以下策划暂未提出要求，预留异常状态抛出枚举%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% -define(TeamMsg_PlayerLeveTeam,11).     %%玩家离队                
%% -define(TeamMsg_LeaderChange,12).       %%队长移交
%% -define(TeamMsg_TeamMemberoffline,13)   %%队友离线
%% -define(TeamMsg_TeamMemberBackOnline,14)%%队友重新上线
%% -define(TeamMsg_Playerdie,15).          %%玩家死亡
%% -define(TeamMsg_TeamFull,16).           %%队伍已满
-endif.
