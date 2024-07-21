
-define(CMD_TopPlayerLevelInfo,1301).
-record(pk_TopPlayerLevelInfo, {
	top,
	playerid,
	name,
	camp,
	level,
	fightingcapacity,
	sex,
	weapon,
	coat
	}).
-define(CMD_TopPlayerFightingCapacityInfo,1302).
-record(pk_TopPlayerFightingCapacityInfo, {
	top,
	playerid,
	name,
	camp,
	level,
	fightingcapacity,
	sex,
	weapon,
	coat
	}).
-define(CMD_TopPlayerMoneyInfo,1303).
-record(pk_TopPlayerMoneyInfo, {
	top,
	playerid,
	name,
	camp,
	level,
	money,
	sex,
	weapon,
	coat
	}).
-define(CMD_GS2U_LoadTopPlayerLevelList,1304).
-record(pk_GS2U_LoadTopPlayerLevelList, {
	info_list
	}).
-define(CMD_GS2U_LoadTopPlayerFightingCapacityList,1305).
-record(pk_GS2U_LoadTopPlayerFightingCapacityList, {
	info_list
	}).
-define(CMD_GS2U_LoadTopPlayerMoneyList,1306).
-record(pk_GS2U_LoadTopPlayerMoneyList, {
	info_list
	}).
-define(CMD_U2GS_LoadTopPlayerLevelList,1307).
-record(pk_U2GS_LoadTopPlayerLevelList, {
	}).
-define(CMD_U2GS_LoadTopPlayerFightingCapacityList,1308).
-record(pk_U2GS_LoadTopPlayerFightingCapacityList, {
	}).
-define(CMD_U2GS_LoadTopPlayerMoneyList,1309).
-record(pk_U2GS_LoadTopPlayerMoneyList, {
	}).
-define(CMD_AnswerTopInfo,1310).
-record(pk_AnswerTopInfo, {
	top,
	playerid,
	name,
	core
	}).
-define(CMD_GS2U_AnswerQuestion,1311).
-record(pk_GS2U_AnswerQuestion, {
	id,
	num,
	maxnum,
	core,
	special_double,
	special_right,
	special_exclude,
	a,
	b,
	c,
	d,
	e1,
	e2
	}).
-define(CMD_GS2U_AnswerReady,1312).
-record(pk_GS2U_AnswerReady, {
	time
	}).
-define(CMD_GS2U_AnswerClose,1313).
-record(pk_GS2U_AnswerClose, {
	}).
-define(CMD_GS2U_AnswerTopList,1314).
-record(pk_GS2U_AnswerTopList, {
	info_list
	}).
-define(CMD_U2GS_AnswerCommit,1315).
-record(pk_U2GS_AnswerCommit, {
	num,
	answer,
	time
	}).
-define(CMD_U2GS_AnswerCommitRet,1316).
-record(pk_U2GS_AnswerCommitRet, {
	ret,
	score
	}).
-define(CMD_U2GS_AnswerSpecial,1317).
-record(pk_U2GS_AnswerSpecial, {
	type
	}).
-define(CMD_U2GS_AnswerSpecialRet,1318).
-record(pk_U2GS_AnswerSpecialRet, {
	ret
	}).