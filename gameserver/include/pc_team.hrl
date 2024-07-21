
-define(CMD_inviteCreateTeam,1201).
-record(pk_inviteCreateTeam, {
	targetPlayerID
	}).
-define(CMD_teamOPResult,1202).
-record(pk_teamOPResult, {
	targetPlayerID,
	targetPlayerName,
	result
	}).
-define(CMD_beenInviteCreateTeam,1203).
-record(pk_beenInviteCreateTeam, {
	inviterPlayerID,
	inviterPlayerName
	}).
-define(CMD_ackInviteCreateTeam,1204).
-record(pk_ackInviteCreateTeam, {
	inviterPlayerID,
	agree
	}).
-define(CMD_teamMemberInfo,1205).
-record(pk_teamMemberInfo, {
	playerID,
	playerName,
	level,
	posx,
	posy,
	map_data_id,
	isOnline,
	camp,
	sex,
	life_percent
	}).
-define(CMD_teamInfo,1206).
-record(pk_teamInfo, {
	teamID,
	leaderPlayerID,
	info_list
	}).
-define(CMD_teamPlayerOffline,1207).
-record(pk_teamPlayerOffline, {
	playerID
	}).
-define(CMD_teamQuitRequest,1208).
-record(pk_teamQuitRequest, {
	reserve
	}).
-define(CMD_teamPlayerQuit,1209).
-record(pk_teamPlayerQuit, {
	playerID
	}).
-define(CMD_teamKickOutPlayer,1210).
-record(pk_teamKickOutPlayer, {
	playerID
	}).
-define(CMD_teamPlayerKickOut,1211).
-record(pk_teamPlayerKickOut, {
	playerID
	}).
-define(CMD_inviteJoinTeam,1212).
-record(pk_inviteJoinTeam, {
	playerID
	}).
-define(CMD_beenInviteJoinTeam,1213).
-record(pk_beenInviteJoinTeam, {
	playerID,
	playerName
	}).
-define(CMD_ackInviteJointTeam,1214).
-record(pk_ackInviteJointTeam, {
	playerID,
	agree
	}).
-define(CMD_applyJoinTeam,1215).
-record(pk_applyJoinTeam, {
	playerID
	}).
-define(CMD_queryApplyJoinTeam,1216).
-record(pk_queryApplyJoinTeam, {
	playerID,
	playerName
	}).
-define(CMD_ackQueryApplyJoinTeam,1217).
-record(pk_ackQueryApplyJoinTeam, {
	playerID,
	agree
	}).
-define(CMD_addTeamMember,1218).
-record(pk_addTeamMember, {
	info
	}).
-define(CMD_shortTeamMemberInfo,1219).
-record(pk_shortTeamMemberInfo, {
	playerID,
	level,
	posx,
	posy,
	map_data_id,
	isOnline,
	life_percent
	}).
-define(CMD_updateTeamMemberInfo,1220).
-record(pk_updateTeamMemberInfo, {
	info_list
	}).
-define(CMD_teamDisbanded,1221).
-record(pk_teamDisbanded, {
	reserve
	}).
-define(CMD_teamQueryLeaderInfo,1222).
-record(pk_teamQueryLeaderInfo, {
	playerID,
	playerName,
	level
	}).
-define(CMD_teamQueryLeaderInfoOnMyMap,1223).
-record(pk_teamQueryLeaderInfoOnMyMap, {
	info_list
	}).
-define(CMD_teamQueryLeaderInfoRequest,1224).
-record(pk_teamQueryLeaderInfoRequest, {
	mapID
	}).
-define(CMD_teamChangeLeader,1225).
-record(pk_teamChangeLeader, {
	playerID
	}).
-define(CMD_teamChangeLeaderRequest,1226).
-record(pk_teamChangeLeaderRequest, {
	playerID
	}).
-define(CMD_beenInviteState,1227).
-record(pk_beenInviteState, {
	state
	}).