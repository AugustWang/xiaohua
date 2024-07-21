
//坐骑信息
struct mountInfo
{
	int8   mountDataID;    //坐骑数据ID
	int8   level;          //坐骑等级
	int8   equiped;        //坐骑是否被装备,=0表示没有装备，!=0表示装备
	int8   progress;      //坐骑当前升级进度
	int	benison_Value; // 坐骑当前祝福值
};

//玩家第一次打开坐骑UI请求坐骑信息
struct U2GS_QueryMyMountInfo->
{
	int8	reserve;
};

//玩家第一次打开坐骑UI请求坐骑信息，回复
struct GS2U_QueryMyMountInfoResult<-
{
	vector<mountInfo> mounts; 
};

//坐骑数据新增、更新
struct GS2U_MountInfoUpdate<-
{
	mountInfo mounts;
};

//坐骑操作结果消息
struct GS2U_MountOPResult<-
{
	int8  mountDataID;    //坐骑数据ID
	int	  result;		  //结果码
};

//装备马请求
struct U2GS_MountEquipRequest->
{
	int8  mountDataID;    //坐骑数据ID
};

//取消装备马请求
struct U2GS_Cancel_MountEquipRequest->
{
	int8	reserve;
};

//上马请求
struct U2GS_MountUpRequest->
{
	int8 reserve;
};

//某玩家上马
struct GS2U_MountUp<-
{
	int64	actorID;	//上马玩家ID
	int8	mount_data_id;	//骑乘数据ID
};

//下马请求
struct U2GS_MountDownRequest->
{
	int8 reserve;
};

//某玩家下马
struct GS2U_MountDown<-
{
	int64	actorID;	//下马玩家ID
};

//喂养骑乘请求
struct U2GS_LevelUpRequest->
{
	int8  mountDataID;    //坐骑数据ID
	int8  isAuto;		 //是否自动，=0不，!=0要
};

