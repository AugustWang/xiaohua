// -> client to server
// <- server to client
// <-> client & server

//struct AcceptTask ->
//{
//	int 	playerID; 
//	int 	taskID;
//};
//
//
//struct AcceptTaskAck <-
//{
//	int 	playerID; 
//	int 	taskID;
//	int		result;
//};
//
//struct TaskProgess <-
//{
//	int		taskID;
//	int		aimIndex;
//	int		aimCount;
//};
//
//struct	TaskFinish <-
//{
//	int 	taskID;
//};
//
//struct	CompleteTask ->
//{
//	int taskID;
//};
//
//struct	CompleteTaskResult <-
//{
//	int taskID;
//	int result;
//};
//
//struct	DropTask ->
//{
//	int	taskID;
//};


//struct TaskState
//{
//	int taskID;
//	int state;
//}
//
//struct AllTaskState <-
//{
//	int playerID;
//	vector<TaskState> allState;
//};
//
//struct TaskProgressChange <-
//{
//	int taskID;
//	vector<int> progress;
//};

struct MsgCollectGoods ->
{
	int goodsID;
	int8 collectFlag;
	int collectTime;
};

struct GMTaskStateChange <-
{
	int taskID;
	int state;
};

struct GMRefreshAllTask <-
{
};

// 任务条件进度
struct TaskProgess
{
	int					nCurCount;
};
// 已接收任务信息
struct AcceptTask
{
	int16					nTaskID;
	vector<TaskProgess>		list_progress;
};
//	已接收任务列表
struct GS2U_AcceptedTaskList <-
{
	vector<AcceptTask>		list_accepted;
};
//	已完成任务列表
struct GS2U_CompletedTaskIDList <-
{
	vector<int16>		list_completed_id;
};
//	接收任务请求
struct U2GS_AcceptTaskRequest ->
{
	int16				nQuestID;
	int64				nNpcActorID;
};
//	任务条件变化通知
struct GS2U_PlayerTaskProgressChanged<-
{
	int16				nQuestID;
	vector<TaskProgess>	list_progress;
};
//	接收任务结果
struct GS2U_AcceptTaskResult<-
{
	int16				nQuestID;
	int					nResult;
};

//	玩家与Npc对话
struct U2GS_TalkToNpc->
{
	int64				nNpcActorID;
};

//	与npc对话的结果
struct GS2U_TalkToNpcResult<-
{
	int8 nResult;
	int nNpcDataID;
};

//	玩家采集请求
struct U2GS_CollectRequest->
{
	int64				nObjectActorID;
	int					nObjectDataID;
	int					nTaskID;
};

//	玩家归还任务请求
struct U2GS_CompleteTaskRequest->
{
	int64				nNpcActorID;
	int					nQuestID;	
};

//	归还任务结果
struct GS2U_CompleteTaskResult<-
{
	int					nQuestID;
	int					nResult;
};

//	玩家放弃任务
struct U2GS_GiveUpTaskRequest->
{
	int					nQuestID;
};

//	放弃任务结果
struct GS2U_GiveUpTaskResult<-
{
	int					nQuestID;
	int					nResult;
};

//	任务提示
struct GS2U_NoteTask<-
{
	int					nTaskID;
};

//	告知茶馆任务详情
struct GS2U_TellRandomDailyInfo<-
{
	int randDailyTaskID;//现在被随机到的任务ID
	int8 finishedTime;//完成次数
	int8 process;//当前组的进度
};

//	告知声望任务详情
struct GS2U_TellReputationTask<-
{
	int taskID;//给随机分配到的任务ID
	int process;
};
