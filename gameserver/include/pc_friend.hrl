
-define(CMD_FriendInfo,201).
-record(pk_FriendInfo, {
	friendType,
	friendID,
	friendName,
	friendSex,
	friendFace,
	friendClassType,
	friendLevel,
	friendVip,
	friendValue,
	friendOnline
	}).
-define(CMD_GS2U_LoadFriend,202).
-record(pk_GS2U_LoadFriend, {
	info_list
	}).
-define(CMD_U2GS_QueryFriend,203).
-record(pk_U2GS_QueryFriend, {
	playerid
	}).
-define(CMD_GS2U_FriendTips,204).
-record(pk_GS2U_FriendTips, {
	type,
	tips
	}).
-define(CMD_GS2U_LoadBlack,205).
-record(pk_GS2U_LoadBlack, {
	info_list
	}).
-define(CMD_U2GS_QueryBlack,206).
-record(pk_U2GS_QueryBlack, {
	playerid
	}).
-define(CMD_GS2U_LoadTemp,207).
-record(pk_GS2U_LoadTemp, {
	info_list
	}).
-define(CMD_U2GS_QueryTemp,208).
-record(pk_U2GS_QueryTemp, {
	playerid
	}).
-define(CMD_GS2U_FriendInfo,209).
-record(pk_GS2U_FriendInfo, {
	friendInfo
	}).
-define(CMD_U2GS_AddFriend,210).
-record(pk_U2GS_AddFriend, {
	friendID,
	friendName,
	type
	}).
-define(CMD_GS2U_AddAcceptResult,211).
-record(pk_GS2U_AddAcceptResult, {
	isSuccess,
	type,
	fname
	}).
-define(CMD_U2GS_DeleteFriend,212).
-record(pk_U2GS_DeleteFriend, {
	friendID,
	type
	}).
-define(CMD_U2GS_AcceptFriend,213).
-record(pk_U2GS_AcceptFriend, {
	result,
	friendID
	}).
-define(CMD_GS2U_DeteFriendBack,214).
-record(pk_GS2U_DeteFriendBack, {
	type,
	friendID
	}).
-define(CMD_GS2U_Net_Message,215).
-record(pk_GS2U_Net_Message, {
	mswerHead,
	skno,
	rel
	}).
-define(CMD_GS2U_OnHookSet_Mess,216).
-record(pk_GS2U_OnHookSet_Mess, {
	playerHP,
	petHP,
	skillID1,
	skillID2,
	skillID3,
	skillID4,
	skillID5,
	skillID6,
	getThing,
	hpThing,
	other,
	isAutoDrug
	}).