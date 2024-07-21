//////////////////////////////////////////////////////////////////////////
// LoginServer 2 GameServer
struct LS2GS_LoginResult <->
{
	int		reserve;
};

struct LS2GS_QueryUserMaxLevel <->
{
	int64		userID;
};

struct LS2GS_UserReadyToLogin <->
{
	int64		userID;
	string	username;
	string	identity;
	int platId;
};

struct LS2GS_KickOutUser <->
{
	int64		userID;
	string	identity;
};

struct LS2GS_ActiveCode <->
{
	string  pidStr;
	string	activeCode;
	string	playerName;
	int		type;
};

//////////////////////////////////////////////////////////////////////////
// GameServer 2 LoginServer
struct GS2LS_Request_Login <->
{
	string	serverID;
	string  name;
	string	ip;
	int		port;
	int		remmond;
	int		showInUserGameList;
	int		hot;
};

struct GS2LS_ReadyToAcceptUser <->
{
	int		reserve;
};

struct GS2LS_OnlinePlayers <->
{
	int		playerCount;
};

struct GS2LS_QueryUserMaxLevelResult <->
{
	int64		userID;
	int		maxLevel;
};

struct GS2LS_UserReadyLoginResult <->
{
	int64		userID;
	int		result;
};

struct GS2LS_UserLoginGameServer <->
{
	int64		userID;
};

struct GS2LS_UserLogoutGameServer <->
{
	int64		userID;
	string	identity;
};

struct GS2LS_ActiveCode <->
{
	string  pidStr;
	string	activeCode;
	int		retcode;
};

struct LS2GS_Announce <->
{
	string  pidStr;
	string	announceInfo;
};

struct LS2GS_Command <->
{
	string  pidStr;
	int num;
	int cmd;
	string params;
};

struct GS2LS_Command <->
{
	string  pidStr;
	int num;
	int cmd;
	int retcode;
};

struct LS2GS_Recharge <->
{
	string  pidStr;
	string orderid;
	int platform;
	string account;
	int64 userid;
	int64 playerid;
	int ammount;
};

struct GS2LS_Recharge <->
{
	string  pidStr;
	string orderid;
	int platform;
	int retcode;
};