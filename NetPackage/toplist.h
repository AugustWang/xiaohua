// -> client to server
// <- server to client
// <-> client & server
// 等级排名信息
struct TopPlayerLevelInfo
{
	int	top;
	int64	playerid;
	string	name;
	int	camp;
	int	level;
	int	fightingcapacity;
	int 	sex;
	int 	weapon;
	int 	coat;
};

// 战斗力排名信息
struct TopPlayerFightingCapacityInfo
{
	int	top;
	int64	playerid;
	string	name;
	int	camp;
	int	level;
	int	fightingcapacity;
	int 	sex;
	int 	weapon;
	int 	coat;
};

// 富豪排名信息
struct TopPlayerMoneyInfo
{
	int	top;
	int64	playerid;
	string	name;
	int	camp;
	int	level;
	int	money;
	int 	sex;
	int 	weapon;
	int 	coat;
};

struct GS2U_LoadTopPlayerLevelList <-
{
	vector<TopPlayerLevelInfo> info_list;
};

struct GS2U_LoadTopPlayerFightingCapacityList <-
{
	vector<TopPlayerFightingCapacityInfo> info_list;
};

struct GS2U_LoadTopPlayerMoneyList <-
{
	vector<TopPlayerMoneyInfo> info_list;
};

struct U2GS_LoadTopPlayerLevelList ->
{
};

struct U2GS_LoadTopPlayerFightingCapacityList ->
{
};

struct U2GS_LoadTopPlayerMoneyList ->
{
};


// answer.h 答题系统相关消息定义
// -> client to server
// <- server to client
// <-> client & server
// 答题排名信息
struct AnswerTopInfo
{
	int	top;
	int64	playerid;
	string	name;
	int	core;
};

// 题目信息
struct GS2U_AnswerQuestion <-
{
	int	id;		// 题目ID
	int8	num;		// 当前题目数量
	int8 	maxnum;		// 最大题目数量
	int 	core;		// 玩家当前得分
	int8 	special_double;	// 特殊功能双倍积分
	int8 	special_right;	// 特殊功能正确答案
	int8 	special_exclude;// 特殊功能排除
	int8	a;
	int8	b;
	int8	c;
	int8	d;
	int8	e1;
	int8	e2;
};

// 准备倒计时
struct GS2U_AnswerReady <-
{
	int time;		// 答题倒计时
};

// 答题结束
struct GS2U_AnswerClose <-
{
	
};

// 答题排名
struct GS2U_AnswerTopList <-
{
	vector<AnswerTopInfo> info_list;
};

// 提交答案
struct U2GS_AnswerCommit ->
{
	int 	num;		// 题目序号
	int 	answer;		// 答案
	int 	time;		// 用时 秒
};

// 提交答案返回
struct U2GS_AnswerCommitRet <-
{
	int8 	ret;
	int 	score;
};

// 使用特殊功能
struct U2GS_AnswerSpecial ->
{
	int 	type;
};

// 使用特殊功能返回
struct U2GS_AnswerSpecialRet <-
{
	int8 	ret;
};