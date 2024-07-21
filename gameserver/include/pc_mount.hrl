
-define(CMD_mountInfo,601).
-record(pk_mountInfo, {
	mountDataID,
	level,
	equiped,
	progress,
	benison_Value
	}).
-define(CMD_U2GS_QueryMyMountInfo,602).
-record(pk_U2GS_QueryMyMountInfo, {
	reserve
	}).
-define(CMD_GS2U_QueryMyMountInfoResult,603).
-record(pk_GS2U_QueryMyMountInfoResult, {
	mounts
	}).
-define(CMD_GS2U_MountInfoUpdate,604).
-record(pk_GS2U_MountInfoUpdate, {
	mounts
	}).
-define(CMD_GS2U_MountOPResult,605).
-record(pk_GS2U_MountOPResult, {
	mountDataID,
	result
	}).
-define(CMD_U2GS_MountEquipRequest,606).
-record(pk_U2GS_MountEquipRequest, {
	mountDataID
	}).
-define(CMD_U2GS_Cancel_MountEquipRequest,607).
-record(pk_U2GS_Cancel_MountEquipRequest, {
	reserve
	}).
-define(CMD_U2GS_MountUpRequest,608).
-record(pk_U2GS_MountUpRequest, {
	reserve
	}).
-define(CMD_GS2U_MountUp,609).
-record(pk_GS2U_MountUp, {
	actorID,
	mount_data_id
	}).
-define(CMD_U2GS_MountDownRequest,610).
-record(pk_U2GS_MountDownRequest, {
	reserve
	}).
-define(CMD_GS2U_MountDown,611).
-record(pk_GS2U_MountDown, {
	actorID
	}).
-define(CMD_U2GS_LevelUpRequest,612).
-record(pk_U2GS_LevelUpRequest, {
	mountDataID,
	isAuto
	}).