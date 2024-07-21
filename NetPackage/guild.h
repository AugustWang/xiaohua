//////////////////////////////////////////////////////////////////////////
//User 2 GameServer
//仙盟创建请求
struct U2GS_RequestCreateGuild ->
{
	int8 			useToken;
	string			strGuildName;
};

//客户端查询仙盟列表
struct U2GS_QueryGuildList ->
{
	//是否上线后第一次query，是第一次bFirst=1，否则=0
	int8			bFirst;
};

//查询仙盟简略扩展信息
struct U2GS_QueryGuildShortInfoEx->
{
	vector<int64>		vGuilds;
};

//查询自己仙盟的信息
struct U2GS_GetMyGuildInfo->
{
	int8			reserve;
};

//查询仙盟申请成员列表实时信息
struct U2GS_GetMyGuildApplicantShortInfo->
{
	int8			reserve;
};

//修改仙盟公告
struct U2GS_RequestChangeGuildAffiche->
{
	string			strAffiche;
};

//贡献度捐献
struct U2GS_RequestGuildContribute->
{
	int				nMoney;
	int				nGold;
	int				nItemCount;
};

//职位调整
struct U2GS_RequestGuildMemberRankChange->
{
	int64			nPlayerID;
	int8			nRank;
};

//踢成员
struct U2GS_RequestGuildKickOutMember->
{
	int64			nPlayerID;
};

//退出
struct U2GS_RequestGuildQuit->
{
	int				reserve;
};

//技能学习
struct U2GS_RequestGuildStudySkill->
{
	int				nSkillGroupID;
};

//申请入盟
struct U2GS_RequestJoinGuld->
{
	int64			nGuildID;
};

//批准申请者入盟
struct U2GS_RequestGuildApplicantAllow->
{
	int64			nPlayerID;
};

//拒绝申请者入盟
struct U2GS_RequestGuildApplicantRefuse->
{
	int64			nPlayerID;
};

//申请列表全部操作
struct U2GS_RequestGuildApplicantOPAll->
{
	int				nAllowOrRefuse;
};


//////////////////////////////////////////////////////////////////////////
struct GS2U_CreateGuildResult<-
{
	//	GS2U_CreateGuildResult_Type
	int				result;
	int64			guildID;
};

//仙盟简略信息
struct GS2U_GuildInfoSmall
{
	//	工会ID
	int64			nGuildID;
	//	会长ID
	int64			nChairmanPlayerID;
	//	等级
	int8		nLevel;
	//	人数
	int16		nMemberCount;
};
struct GS2U_GuildInfoSmallList<-
{
	vector<GS2U_GuildInfoSmall>	info_list;
};

//仙盟简略扩展信息
struct GS2U_GuildShortInfoEx
{
	//	工会ID
	int64		nGuildID;
	//	阵营
	int8		nFaction;
	//	仙盟名字
	string		strGuildName;
	//	会长名字
	string		strChairmanPlayerName;
};
struct GS2U_GuildShortInfoExList<-
{
	vector<GS2U_GuildShortInfoEx> info_list;
};

//第一次查询仙盟列表
struct GS2U_GuildAllShortInfo
{
	//	工会ID
	int64			nGuildID;
	//	会长ID
	int64			nChairmanPlayerID;
	//	会长名字
	string		strChairmanPlayerName;
	//	等级
	int8		nLevel;
	//	人数
	int16		nMemberCount;
	//	阵营
	int8		nFaction;
	//	仙盟名字
	string		strGuildName;
};
struct GS2U_GuildAllShortInfoList<-
{
	vector<GS2U_GuildAllShortInfo>	info_list;
};

//仙盟基本信息
struct GS2U_GuildBaseData
{
	//	工会ID
	int64		nGuildID;
	//	会长ID
	int64		nChairmanPlayerID;

	//	阵营
	int8		nFaction;

	//	等级
	int8		nLevel;

	//	经验
	int16		nExp;
	
	//	成员数
	int memberCount;

	//	会长名字
	string		strChairmanPlayerName;
	//	仙盟名字
	string		strGuildName;
	//	公告
	string		strAffiche;
};

//仙盟成员信息
struct GS2U_GuildMemberData
{
	//	玩家ID
	int64			nPlayerID;
	//	玩家名字
	string		strPlayerName;
	//	玩家等级
	int16		nPlayerLevel;
	//	职位
	int8		nRank;
	//	职业
	int8		nClass;
	//	贡献度
	int			nContribute;
	//	是否在线
	int8		bOnline;
};

//仙盟申请列表成员信息
struct GS2U_GuildApplicantData
{
	//	玩家ID
	int64			nPlayerID;
	//	玩家名字
	string		strPlayerName;
	//	玩家等级
	int16		nPlayerLevel;
	//	职业
	int8		nClass;
	//	战力
	int			nZhanLi;
};

//仙盟完整信息
struct GS2U_GuildFullInfo<-
{
	GS2U_GuildBaseData		stBase;
	vector<GS2U_GuildMemberData>	member_list;
	vector<GS2U_GuildApplicantData>	applicant_list;
};

//仙盟申请成员实时信息
struct GS2U_GuildApplicantShortData
{
	//	玩家ID
	int64			nPlayerID;
	//	玩家等级
	int16		nPlayerLevel;
	//	战力
	int			nZhanLi;
};

//仙盟申请成员实时信息列表
struct GS2U_GuildApplicantShortList<-
{
	vector<GS2U_GuildApplicantShortData> info_list;
};

//仙盟等级经验变化
struct GS2U_GuildLevelEXPChanged<-
{
	int16		nLevel;
	int			nEXP;
};

//仙盟公告变化
struct GS2U_GuildAfficheChanged<-
{
	string			strAffiche;
};

//成员贡献度变化
struct GS2U_GuildMemberContributeChanged<-
{
	int64				nPlayerID;
	int				nContribute;
};

//成员等级变化
struct GS2U_GuildMemberLevelChanged<-
{
	int64				nPlayerID;
	int16			nLevel;
};

//成员上线下线变化
struct GS2U_GuildMemberOnlineChanged<-
{
	int64				nPlayerID;
	int8			nOnline;
};

//成员职位变化
struct GS2U_GuildMemberRankChanged<-
{
	int64				nPlayerID;
	int8			nRank;
};

//新加入成员
struct GS2U_GuildMemberAdd<-
{
	GS2U_GuildMemberData stData;
};

//成员退出
struct GS2U_GuildMemberQuit<-
{
	int64				nPlayerID;
	int8			bKickOut;
};

//加入仙盟成功
struct GS2U_JoinGuildSuccess<-
{
	int64 guildID;
	string guildName;
};

//批准操作完成
struct GS2U_AllowOpComplete<-
{
	int64 playerID;
};