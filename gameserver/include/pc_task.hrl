
-define(CMD_MsgCollectGoods,1101).
-record(pk_MsgCollectGoods, {
	goodsID,
	collectFlag,
	collectTime
	}).
-define(CMD_GMTaskStateChange,1102).
-record(pk_GMTaskStateChange, {
	taskID,
	state
	}).
-define(CMD_GMRefreshAllTask,1103).
-record(pk_GMRefreshAllTask, {
	}).
-define(CMD_TaskProgess,1104).
-record(pk_TaskProgess, {
	nCurCount
	}).
-define(CMD_AcceptTask,1105).
-record(pk_AcceptTask, {
	nTaskID,
	list_progress
	}).
-define(CMD_GS2U_AcceptedTaskList,1106).
-record(pk_GS2U_AcceptedTaskList, {
	list_accepted
	}).
-define(CMD_GS2U_CompletedTaskIDList,1107).
-record(pk_GS2U_CompletedTaskIDList, {
	list_completed_id
	}).
-define(CMD_U2GS_AcceptTaskRequest,1108).
-record(pk_U2GS_AcceptTaskRequest, {
	nQuestID,
	nNpcActorID
	}).
-define(CMD_GS2U_PlayerTaskProgressChanged,1109).
-record(pk_GS2U_PlayerTaskProgressChanged, {
	nQuestID,
	list_progress
	}).
-define(CMD_GS2U_AcceptTaskResult,1110).
-record(pk_GS2U_AcceptTaskResult, {
	nQuestID,
	nResult
	}).
-define(CMD_U2GS_TalkToNpc,1111).
-record(pk_U2GS_TalkToNpc, {
	nNpcActorID
	}).
-define(CMD_GS2U_TalkToNpcResult,1112).
-record(pk_GS2U_TalkToNpcResult, {
	nResult,
	nNpcDataID
	}).
-define(CMD_U2GS_CollectRequest,1113).
-record(pk_U2GS_CollectRequest, {
	nObjectActorID,
	nObjectDataID,
	nTaskID
	}).
-define(CMD_U2GS_CompleteTaskRequest,1114).
-record(pk_U2GS_CompleteTaskRequest, {
	nNpcActorID,
	nQuestID
	}).
-define(CMD_GS2U_CompleteTaskResult,1115).
-record(pk_GS2U_CompleteTaskResult, {
	nQuestID,
	nResult
	}).
-define(CMD_U2GS_GiveUpTaskRequest,1116).
-record(pk_U2GS_GiveUpTaskRequest, {
	nQuestID
	}).
-define(CMD_GS2U_GiveUpTaskResult,1117).
-record(pk_GS2U_GiveUpTaskResult, {
	nQuestID,
	nResult
	}).
-define(CMD_GS2U_NoteTask,1118).
-record(pk_GS2U_NoteTask, {
	nTaskID
	}).
-define(CMD_GS2U_TellRandomDailyInfo,1119).
-record(pk_GS2U_TellRandomDailyInfo, {
	randDailyTaskID,
	finishedTime,
	process
	}).
-define(CMD_GS2U_TellReputationTask,1120).
-record(pk_GS2U_TellReputationTask, {
	taskID,
	process
	}).