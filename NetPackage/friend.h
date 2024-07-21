// -> client to server
// <- server to client
// <-> client & server
struct FriendInfo
{
	int8	friendType;
	int64	friendID;
	string	friendName;
	int8	friendSex;
	int8	friendFace;
	int8	friendClassType;
	int16	friendLevel;
	int8	friendVip;
	int		friendValue;
	int8	friendOnline;
};

struct GS2U_LoadFriend <-
{
	vector<FriendInfo> info_list;
};

struct U2GS_QueryFriend ->
{
	int64 playerid;
};

struct GS2U_FriendTips<-
{
	int8	type;
	int8 tips;
};

struct GS2U_LoadBlack <-
{
	vector<FriendInfo> info_list;
};

struct U2GS_QueryBlack ->
{
	int64 playerid;
};

struct GS2U_LoadTemp <-
{
	vector<FriendInfo> info_list;
};

struct U2GS_QueryTemp ->
{
	int64 playerid;
};
struct GS2U_FriendInfo <-
{
	FriendInfo friendInfo;
};
struct U2GS_AddFriend ->
{
	int64 friendID;
	string friendName;
	int8 type;
};

struct GS2U_AddAcceptResult <-
{
	int8 isSuccess;
	int64 type;
	string fname;
};

struct U2GS_DeleteFriend ->
{
	int64 friendID;
	int8 type;
};

struct U2GS_AcceptFriend ->
{
	int8	 result;
	int64 friendID;
};

struct GS2U_DeteFriendBack <-
{
	int8 type;
	int64 friendID;
};

struct GS2U_Net_Message <->
{
	int mswerHead;
	int skno;
	int rel;
}


struct GS2U_OnHookSet_Mess <->
{
	int playerHP;
	int petHP;
	int skillID1;
	int skillID2;
	int skillID3;
	int skillID4;
	int skillID5;
	int skillID6;
	int getThing;
	int hpThing;
	int other;
	int isAutoDrug;
};
