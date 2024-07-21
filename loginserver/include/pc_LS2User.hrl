
-define(CMD_LS2U_LoginResult,501).
-record(pk_LS2U_LoginResult, {
	result,
	userID
	}).
-define(CMD_GameServerInfo,502).
-record(pk_GameServerInfo, {
	serverID,
	name,
	state,
	showIndex,
	remmond,
	maxPlayerLevel,
	isnew,
	begintime,
	hot
	}).
-define(CMD_LS2U_GameServerList,503).
-record(pk_LS2U_GameServerList, {
	gameServers
	}).
-define(CMD_LS2U_SelGameServerResult,504).
-record(pk_LS2U_SelGameServerResult, {
	userID,
	ip,
	port,
	identity,
	errorCode
	}).
-define(CMD_U2LS_Login_553,505).
-record(pk_U2LS_Login_553, {
	account,
	platformID,
	time,
	sign,
	versionRes,
	versionExe,
	versionGame,
	versionPro
	}).
-define(CMD_U2LS_Login_PP,506).
-record(pk_U2LS_Login_PP, {
	account,
	platformID,
	token1,
	token2,
	versionRes,
	versionExe,
	versionGame,
	versionPro
	}).
-define(CMD_U2LS_RequestGameServerList,507).
-record(pk_U2LS_RequestGameServerList, {
	reserve
	}).
-define(CMD_U2LS_RequestSelGameServer,508).
-record(pk_U2LS_RequestSelGameServer, {
	serverID
	}).
-define(CMD_LS2U_ServerInfo,509).
-record(pk_LS2U_ServerInfo, {
	lsid,
	client_ip
	}).
-define(CMD_U2LS_Login_APPS,510).
-record(pk_U2LS_Login_APPS, {
	account,
	platformID,
	time,
	sign,
	versionRes,
	versionExe,
	versionGame,
	versionPro
	}).
-define(CMD_U2LS_Login_360,511).
-record(pk_U2LS_Login_360, {
	account,
	platformID,
	authoCode,
	versionRes,
	versionExe,
	versionGame,
	versionPro
	}).
-define(CMD_LS2U_Login_360,512).
-record(pk_LS2U_Login_360, {
	account,
	userid,
	access_token,
	refresh_token
	}).
-define(CMD_U2LS_Login_UC,513).
-record(pk_U2LS_Login_UC, {
	account,
	platformID,
	authoCode,
	versionRes,
	versionExe,
	versionGame,
	versionPro
	}).
-define(CMD_LS2U_Login_UC,514).
-record(pk_LS2U_Login_UC, {
	account,
	userid,
	nickName
	}).
-define(CMD_U2LS_Login_91,515).
-record(pk_U2LS_Login_91, {
	account,
	platformID,
	uin,
	sessionID,
	versionRes,
	versionExe,
	versionGame,
	versionPro
	}).
-define(CMD_LS2U_Login_91,516).
-record(pk_LS2U_Login_91, {
	account,
	userid,
	access_token,
	refresh_token
	}).