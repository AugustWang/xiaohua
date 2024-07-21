
-define(CMD_U2GS_RequestCreateGuild,301).
-record(pk_U2GS_RequestCreateGuild, {
	useToken,
	strGuildName
	}).
-define(CMD_U2GS_QueryGuildList,302).
-record(pk_U2GS_QueryGuildList, {
	bFirst
	}).
-define(CMD_U2GS_QueryGuildShortInfoEx,303).
-record(pk_U2GS_QueryGuildShortInfoEx, {
	vGuilds
	}).
-define(CMD_U2GS_GetMyGuildInfo,304).
-record(pk_U2GS_GetMyGuildInfo, {
	reserve
	}).
-define(CMD_U2GS_GetMyGuildApplicantShortInfo,305).
-record(pk_U2GS_GetMyGuildApplicantShortInfo, {
	reserve
	}).
-define(CMD_U2GS_RequestChangeGuildAffiche,306).
-record(pk_U2GS_RequestChangeGuildAffiche, {
	strAffiche
	}).
-define(CMD_U2GS_RequestGuildContribute,307).
-record(pk_U2GS_RequestGuildContribute, {
	nMoney,
	nGold,
	nItemCount
	}).
-define(CMD_U2GS_RequestGuildMemberRankChange,308).
-record(pk_U2GS_RequestGuildMemberRankChange, {
	nPlayerID,
	nRank
	}).
-define(CMD_U2GS_RequestGuildKickOutMember,309).
-record(pk_U2GS_RequestGuildKickOutMember, {
	nPlayerID
	}).
-define(CMD_U2GS_RequestGuildQuit,310).
-record(pk_U2GS_RequestGuildQuit, {
	reserve
	}).
-define(CMD_U2GS_RequestGuildStudySkill,311).
-record(pk_U2GS_RequestGuildStudySkill, {
	nSkillGroupID
	}).
-define(CMD_U2GS_RequestJoinGuld,312).
-record(pk_U2GS_RequestJoinGuld, {
	nGuildID
	}).
-define(CMD_U2GS_RequestGuildApplicantAllow,313).
-record(pk_U2GS_RequestGuildApplicantAllow, {
	nPlayerID
	}).
-define(CMD_U2GS_RequestGuildApplicantRefuse,314).
-record(pk_U2GS_RequestGuildApplicantRefuse, {
	nPlayerID
	}).
-define(CMD_U2GS_RequestGuildApplicantOPAll,315).
-record(pk_U2GS_RequestGuildApplicantOPAll, {
	nAllowOrRefuse
	}).
-define(CMD_GS2U_CreateGuildResult,316).
-record(pk_GS2U_CreateGuildResult, {
	result,
	guildID
	}).
-define(CMD_GS2U_GuildInfoSmall,317).
-record(pk_GS2U_GuildInfoSmall, {
	nGuildID,
	nChairmanPlayerID,
	nLevel,
	nMemberCount
	}).
-define(CMD_GS2U_GuildInfoSmallList,318).
-record(pk_GS2U_GuildInfoSmallList, {
	info_list
	}).
-define(CMD_GS2U_GuildShortInfoEx,319).
-record(pk_GS2U_GuildShortInfoEx, {
	nGuildID,
	nFaction,
	strGuildName,
	strChairmanPlayerName
	}).
-define(CMD_GS2U_GuildShortInfoExList,320).
-record(pk_GS2U_GuildShortInfoExList, {
	info_list
	}).
-define(CMD_GS2U_GuildAllShortInfo,321).
-record(pk_GS2U_GuildAllShortInfo, {
	nGuildID,
	nChairmanPlayerID,
	strChairmanPlayerName,
	nLevel,
	nMemberCount,
	nFaction,
	strGuildName
	}).
-define(CMD_GS2U_GuildAllShortInfoList,322).
-record(pk_GS2U_GuildAllShortInfoList, {
	info_list
	}).
-define(CMD_GS2U_GuildBaseData,323).
-record(pk_GS2U_GuildBaseData, {
	nGuildID,
	nChairmanPlayerID,
	nFaction,
	nLevel,
	nExp,
	memberCount,
	strChairmanPlayerName,
	strGuildName,
	strAffiche
	}).
-define(CMD_GS2U_GuildMemberData,324).
-record(pk_GS2U_GuildMemberData, {
	nPlayerID,
	strPlayerName,
	nPlayerLevel,
	nRank,
	nClass,
	nContribute,
	bOnline
	}).
-define(CMD_GS2U_GuildApplicantData,325).
-record(pk_GS2U_GuildApplicantData, {
	nPlayerID,
	strPlayerName,
	nPlayerLevel,
	nClass,
	nZhanLi
	}).
-define(CMD_GS2U_GuildFullInfo,326).
-record(pk_GS2U_GuildFullInfo, {
	stBase,
	member_list,
	applicant_list
	}).
-define(CMD_GS2U_GuildApplicantShortData,327).
-record(pk_GS2U_GuildApplicantShortData, {
	nPlayerID,
	nPlayerLevel,
	nZhanLi
	}).
-define(CMD_GS2U_GuildApplicantShortList,328).
-record(pk_GS2U_GuildApplicantShortList, {
	info_list
	}).
-define(CMD_GS2U_GuildLevelEXPChanged,329).
-record(pk_GS2U_GuildLevelEXPChanged, {
	nLevel,
	nEXP
	}).
-define(CMD_GS2U_GuildAfficheChanged,330).
-record(pk_GS2U_GuildAfficheChanged, {
	strAffiche
	}).
-define(CMD_GS2U_GuildMemberContributeChanged,331).
-record(pk_GS2U_GuildMemberContributeChanged, {
	nPlayerID,
	nContribute
	}).
-define(CMD_GS2U_GuildMemberLevelChanged,332).
-record(pk_GS2U_GuildMemberLevelChanged, {
	nPlayerID,
	nLevel
	}).
-define(CMD_GS2U_GuildMemberOnlineChanged,333).
-record(pk_GS2U_GuildMemberOnlineChanged, {
	nPlayerID,
	nOnline
	}).
-define(CMD_GS2U_GuildMemberRankChanged,334).
-record(pk_GS2U_GuildMemberRankChanged, {
	nPlayerID,
	nRank
	}).
-define(CMD_GS2U_GuildMemberAdd,335).
-record(pk_GS2U_GuildMemberAdd, {
	stData
	}).
-define(CMD_GS2U_GuildMemberQuit,336).
-record(pk_GS2U_GuildMemberQuit, {
	nPlayerID,
	bKickOut
	}).
-define(CMD_GS2U_JoinGuildSuccess,337).
-record(pk_GS2U_JoinGuildSuccess, {
	guildID,
	guildName
	}).
-define(CMD_GS2U_AllowOpComplete,338).
-record(pk_GS2U_AllowOpComplete, {
	playerID
	}).