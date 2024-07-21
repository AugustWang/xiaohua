// -> client to server
// <- server to client
// <-> client & server

//组队邀请
struct inviteCreateTeam->
{
	int64	targetPlayerID;
};
//队伍操作结果
struct teamOPResult<-
{
	int64	targetPlayerID;
	string	targetPlayerName;
	int		result;
};
//询问，有人邀请你组队
struct beenInviteCreateTeam<-
{
	int64	inviterPlayerID;
	string	inviterPlayerName;
};
//回复，邀请组队结果
struct ackInviteCreateTeam->
{
	int64	inviterPlayerID;
	int8	agree;
};
//队员信息
struct teamMemberInfo
{
	int64	playerID;
	string  playerName;
	int16	level;
	int16	posx;
	int16	posy;
	int8	map_data_id;
	int8	isOnline;
	int8	camp;
	int8	sex;
	int8	life_percent;
};
//队伍信息
struct teamInfo<-
{
	int64	teamID;
	int64	leaderPlayerID;
	vector<teamMemberInfo> info_list;
};
//队伍中有玩家下线
struct teamPlayerOffline<-
{
	int64	playerID;
};

//请求离队
struct teamQuitRequest->
{
	int8	reserve;
};
//队伍中有玩家离队
struct teamPlayerQuit<-
{
	int64	playerID;
};

//队长踢人请求
struct teamKickOutPlayer->
{
	int64	playerID;
};
//队伍中有玩家被踢
struct teamPlayerKickOut<-
{
	int64	playerID;
};

//队长邀请玩家入队
struct inviteJoinTeam->
{
	int64	playerID;
};
//询问，邀请你入队
struct beenInviteJoinTeam<-
{
	int64	playerID;
	string  playerName;
};
//回复，邀请入队接受还是拒绝
struct ackInviteJointTeam->
{
	int64	playerID;
	int8	agree;
};

//无队玩家申请入队
struct applyJoinTeam->
{
	int64	playerID;
};
//询问，有人要加入你的队伍
struct queryApplyJoinTeam<-
{
	int64	playerID;
	string  playerName;
};
//回复，有人要加入你的队伍
struct ackQueryApplyJoinTeam->
{
	int64	playerID;
	int8	agree;
};

//有新玩家入队
struct addTeamMember<-
{
	teamMemberInfo	info;
};

//玩家坐标、等级、在线情况定时更新
struct shortTeamMemberInfo
{
	int64	playerID;
	int16	level;
	int16	posx;
	int16	posy;
	int8	map_data_id;
	int8	isOnline;
	int8	life_percent;
};
struct updateTeamMemberInfo<-
{
	vector<shortTeamMemberInfo>	info_list;
};

//队伍解散
struct teamDisbanded<-
{
	int8	reserve;
};

//查询本地图队长玩家信息
struct teamQueryLeaderInfo
{
	int64	playerID;
	string  playerName;
	int16	level;
};
struct teamQueryLeaderInfoOnMyMap<-
{
	vector<teamQueryLeaderInfo> info_list;
};

//查询本地图队长玩家信息
struct teamQueryLeaderInfoRequest->
{
	int64	mapID;
}

//队长切换
struct teamChangeLeader<-
{
	int64	playerID;
};

//队长移交请求
struct teamChangeLeaderRequest->
{
	int64	playerID;
};

//被邀请状态设置
struct beenInviteState->
{
	int8 state;
}

//struct AddTeam ->
//{
//	int64 leaderId;
//	int64 memberId;
//};
//
//struct LeaveTeam ->
//{
//	int64 leaderId,
//};
//
//struct DelTeamMeber ->
//{
//	int64 memberId;
//};
//
//struct AckTeam ->
//{
//	int64 leaderId;
//	int64 memberId;
//	int8 flag;
//};
//
//struct MemberInfo
//{
//	int64	id;
//	int8 	sex;
//	string	name;
//	int     camp;
//	int     faction;
//	int     level;
//	int     life_max;
//	int     life;
//	int     map_id;
//	int     mapdata_id;
//	int     posX;
//	int     posY;
//
//	int linemark;
//	int64 leaderMark;
//};
//
//struct SelfTeamInfo <-
//{
//	vector<MemberInfo> members;
//};
//
//struct Teaminfo
//{
//	int64 teamID;
//	string team_name;
//	int64 leder_level;
//};
//
//struct lookforteam ->
//{
//	int player_level;
//};
//
//struct getALLteam<-
//{
//	vector<Teaminfo> value;
//};
//
//struct ACKjointheteam ->
//{
//	int64 leaderID;
//	int64 memberID;
//	int flag;
//};
//
//struct Requsetjointheteam ->
//{
//	int64 teamID;
//	int64 requseterID;
//};
//
//struct inviteListUpdata <-
//{
//	int flag_DeleteOrAdd;
//	int flag_ListType;
//	int64 inviterID;
//	string inviter_name;
//};
//
//struct abnormal_process<-
//{
//	string receptorName;
//	int    state_Type;
//};
//
//struct upDataMemberHPInfo<-
//{
//	int64 memberID;
//	int   memberlife;
//};
//
//struct upDataMemberMaxHp<-
//{
//	int64 memberID;
//	int   memberlifeMax;
//}
//struct upDataMemberLevel<-
//{
//	int64 memberID;
//	int   memberLevel;
//};
//struct upDataMemberLocInfo<-
//{
//	int64 memberID;
//	int64 mapID;
//	int mapDataID;
//	int loc_x;
//	int loc_y;
//};
//struct upDataMemberLineMark<-
//{
//	int64 memberID;
//	int   flag;
//};