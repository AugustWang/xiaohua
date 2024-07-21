//////////////////////////////////////////////////////////////////////////
// LoginServer 2 User
struct LS2U_LoginResult <-
{
	int8	result;
	int64		userID;
};

struct GameServerInfo
{
	string  serverID;
	string	name;
	int8	state;
	int8	showIndex;
	int8	remmond;
	int16	maxPlayerLevel;
	int8    isnew;     //是否为新服
	string  begintime;//开服时间
	int8	hot;		
};

struct LS2U_GameServerList <-
{
	vector<GameServerInfo>	gameServers;
};

struct LS2U_SelGameServerResult <-
{
	int64		userID;
	string	ip;
	int		port;
	string	identity;
	int		errorCode;
};

//////////////////////////////////////////////////////////////////////////
// User 2 LoginServer
struct U2LS_Login_553 ->
{
	string	account;
	int16	platformID;
	int64	time;
	string	sign;
	int		versionRes;
	int		versionExe;
	int		versionGame;
	int		versionPro;
};

struct U2LS_Login_PP ->
{
	string	account;
	int16	platformID;
	int64	token1;
	int64	token2;
	int		versionRes;
	int		versionExe;
	int		versionGame;
	int		versionPro;
};

struct U2LS_RequestGameServerList ->
{
	int		reserve;
};

struct U2LS_RequestSelGameServer ->
{
	string	serverID;
};

struct LS2U_ServerInfo<-
{
	int16	lsid;
	string	client_ip;
};

struct U2LS_Login_APPS ->
{
	string	account;
	int16	platformID;
	int64	time;
	string	sign;
	int		versionRes;
	int		versionExe;
	int		versionGame;
	int		versionPro;
};

struct U2LS_Login_360 ->
{
	string	account;
	int16	platformID;
	string	authoCode;
	int		versionRes;
	int		versionExe;
	int		versionGame;
	int		versionPro;
};

struct LS2U_Login_360 <-
{
	string account;
	string userid;
	string access_token;
	string refresh_token;
};

struct U2LS_Login_UC ->
{
	string	account;
	int16	platformID;
	string	authoCode;
	int		versionRes;
	int		versionExe;
	int		versionGame;
	int		versionPro;
};

struct LS2U_Login_UC <-
{
	string account;
	int64 userid;
	string nickName;
};

struct U2LS_Login_91 ->
{
	string	account;
	int16	platformID;
	string 	uin;
	string	sessionID;
	int		versionRes;
	int		versionExe;
	int		versionGame;
	int		versionPro;
};

struct LS2U_Login_91 <-
{
	string account;
	string userid;
	string access_token;
	string refresh_token;
};