
-define(CMD_LS2GS_LoginResult,401).
-record(pk_LS2GS_LoginResult, {
	reserve
	}).
-define(CMD_LS2GS_QueryUserMaxLevel,402).
-record(pk_LS2GS_QueryUserMaxLevel, {
	userID
	}).
-define(CMD_LS2GS_UserReadyToLogin,403).
-record(pk_LS2GS_UserReadyToLogin, {
	userID,
	username,
	identity,
	platId
	}).
-define(CMD_LS2GS_KickOutUser,404).
-record(pk_LS2GS_KickOutUser, {
	userID,
	identity
	}).
-define(CMD_LS2GS_ActiveCode,405).
-record(pk_LS2GS_ActiveCode, {
	pidStr,
	activeCode,
	playerName,
	type
	}).
-define(CMD_GS2LS_Request_Login,406).
-record(pk_GS2LS_Request_Login, {
	serverID,
	name,
	ip,
	port,
	remmond,
	showInUserGameList,
	hot
	}).
-define(CMD_GS2LS_ReadyToAcceptUser,407).
-record(pk_GS2LS_ReadyToAcceptUser, {
	reserve
	}).
-define(CMD_GS2LS_OnlinePlayers,408).
-record(pk_GS2LS_OnlinePlayers, {
	playerCount
	}).
-define(CMD_GS2LS_QueryUserMaxLevelResult,409).
-record(pk_GS2LS_QueryUserMaxLevelResult, {
	userID,
	maxLevel
	}).
-define(CMD_GS2LS_UserReadyLoginResult,410).
-record(pk_GS2LS_UserReadyLoginResult, {
	userID,
	result
	}).
-define(CMD_GS2LS_UserLoginGameServer,411).
-record(pk_GS2LS_UserLoginGameServer, {
	userID
	}).
-define(CMD_GS2LS_UserLogoutGameServer,412).
-record(pk_GS2LS_UserLogoutGameServer, {
	userID,
	identity
	}).
-define(CMD_GS2LS_ActiveCode,413).
-record(pk_GS2LS_ActiveCode, {
	pidStr,
	activeCode,
	retcode
	}).
-define(CMD_LS2GS_Announce,414).
-record(pk_LS2GS_Announce, {
	pidStr,
	announceInfo
	}).
-define(CMD_LS2GS_Command,415).
-record(pk_LS2GS_Command, {
	pidStr,
	num,
	cmd,
	params
	}).
-define(CMD_GS2LS_Command,416).
-record(pk_GS2LS_Command, {
	pidStr,
	num,
	cmd,
	retcode
	}).
-define(CMD_LS2GS_Recharge,417).
-record(pk_LS2GS_Recharge, {
	pidStr,
	orderid,
	platform,
	account,
	userid,
	playerid,
	ammount
	}).
-define(CMD_GS2LS_Recharge,418).
-record(pk_GS2LS_Recharge, {
	pidStr,
	orderid,
	platform,
	retcode
	}).