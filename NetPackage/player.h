// -> client to server
// <- server to client
// <-> client & server

//角色属性
struct CharProperty
{
	int	attack;
	int	defence;
	int	ph_def;
	int	fire_def;
	int	ice_def;
	int	elec_def;
	int	poison_def; 
	int	max_life;
	int	life_recover;
	int	been_attack_recover;
	int	damage_recover;
	int	coma_def; 
	int	hold_def;
	int	silent_def;
	int	move_def;
	int	hit;
	int	dodge;
	int	block;
	int	crit;
	int	pierce; 
	int	attack_speed;
	int	tough;
	int	crit_damage_rate;
	int	block_dec_damage;
	int	phy_attack_rate;
	int	fire_attack_rate;
	int	ice_attack_rate;
	int	elec_attack_rate;
	int	poison_attack_rate;
	int	phy_def_rate;
	int	fire_def_rate;
	int	ice_def_rate;
	int	elec_def_rate;
	int	poison_def_rate;
	int	treat_rate;
	int	on_treat_rate;
	int	move_speed;
};

struct  ObjectBuff
{
	int16	buff_id;
	int16	allValidTime;
	int8	remainTriggerCount;
};

struct PlayerBaseInfo <-
{
	int64 id;

	string name;

	int16 x;   // in tile
	int16 y;   // in tile

	int8 	sex;
	int8 	face;
	int8 	weapon;

	int16	level;	//等级
	int8	camp;	//职业
	int8	faction;	//阵营
	int8	vip;	//VIP

	int16	maxEnabledBagCells;	//	背包有效格子数
	int16	maxEnabledStorageBagCells;	//	仓库有效格子数
	string	storageBagPassWord； //仓库密码

	int		unlockTimes;//解锁时间，即，还有多少秒解锁
	int		money;	//铜币
	int		moneyBinded;	//绑定铜币
	int		gold;	//元宝
	int		goldBinded;	//绑定元宝
	int 		rechargeAmmount; // 充值总金额
	int		ticket;	//点券
	int		guildContribute;	//帮贡
	int		honor;	//荣誉
	int		credit;	//声望
	int		exp;	//经验
	int 	bloodPool;	//血池
	int	petBloodPool;//宠物血池

	//////////////////////////////////////////////////////////////////////////
	//battle 
	int		life;	//生命
	int		lifeMax;	//最大生命
	
	int64 	guildID;	//仙盟ID

	int     mountDataID;  //当前装备的坐骑ID
	int		pK_Kill_RemainTime;//开启杀戮模式时间
	int		exp15Add;	//经验加成 1.5倍 单位时间
	int		exp20Add;	//经验加成 2倍
	int		exp30Add;	//经验加成 3倍

	int		pk_Kill_Value;	//杀戮值
	int8    pkFlags; //用于红名标记（杀戮值达到一定数值）
	int8	minEquipLevel;	//装备最小等级
	string	guild_name;	//仙盟名字
	int8		guild_rank;	//仙盟职位
	string	goldPassWord; //仓库密码
};

struct rideInfo
{
	int mountDataID;
	int rideFlage;
};

// 玩家外观信息
struct LookInfoPlayer
{
	int64 id;

	string name;

	int8	lifePercent;
	int16	x;   // in pixel
	int16	y;   // in pixel
	int16	move_target_x;
	int16	move_target_y;
	int8		move_dir;
	int16	move_speed;
//	int8	movestate;

	int16	level;

	//1=faction，2=sex，3-4=camp, 5-8=movestate, 9=battleFriendOrEnemy, 10-14=rideID
	int	value_flags;

//	int8	faction;
//	int8	sex;
//	int8	camp;
//	int8	battleFriendOrEnemy;

	int		charState;

//	rideInfo	rideID;

	int16 	weapon;
	int16	coat;
	vector<ObjectBuff>	buffList;
	int8     convoyFlags;
	int64	guild_id;
	string	guild_name;
	int8		guild_rank;
	int8		vip;
};
struct LookInfoPlayerList    <-
{
	vector<LookInfoPlayer> info_list;
};

//宠物外观信息
struct LookInfoPet
{
	int64 id;
	int64	masterId;
	int16	data_id;
	string name;
	int16	titleid;
	int16	modelId;
	int8	lifePercent;
	int16	level;
	int16	x;   // in pixel
	int16	y;   // in pixel
	int16	move_target_x;
	int16	move_target_y;
	int16	move_speed;
	int		charState;
	vector<ObjectBuff>	buffList;
};

struct LookInfoPetList <- 
{
	vector<LookInfoPet> info_list;
};

// monster外观信息
struct LookInfoMonster
{
	int64	id;
	int16	move_target_x;
	int16	move_target_y;
	int16	move_speed;
	int16	x;   // in pixel
	int16	y;   // in pixel

	int16	monster_data_id;
	int8	lifePercent;
	int8	faction;
	int		charState;
	vector<ObjectBuff>	buffList;
};
struct LookInfoMonsterList    <-
{
	vector<LookInfoMonster> info_list;
};

// npc外观信息
struct LookInfoNpc
{
	int64		id;
	int16	x;   // in pixel
	int16	y;   // in pixel
	int16	npc_data_id;
	int16	move_target_x;
	int16	move_target_y;
};
struct LookInfoNpcList    <-
{
	vector<LookInfoNpc> info_list;
};

// object外观信息
struct LookInfoObject
{
	int64		id;
	int16	x;
	int16	y;
	int16	object_data_id;
	int16	object_type;
	int		param;
};
struct LookInfoObjectList <-
{
	vector<LookInfoObject>	info_list;
};

// 物件消失
struct ActorDisapearList<-
{
	vector<int64>		info_list;
};

struct PosInfo   
{
	int16 x;
	int16 y;
};

struct PlayerMoveTo    ->
{
	int16 posX;
	int16 posY;
	vector<PosInfo> posInfos;
};

struct PlayerStopMove ->
{
	int16 posX;
	int16 posY;
};

struct PlayerStopMove_S2C <-
{
	int64 id;
	int16 posX;
	int16 posY;
};


struct MoveInfo	
{
	int64 	id;
	int16    posX;
	int16    posY;
	vector<PosInfo> posInfos;
};

struct PlayerMoveInfo    <-
{
	vector<MoveInfo> ids;
};

struct ChangeFlyState ->
{
	int flyState;
};

struct ChangeFlyState_S2C <-
{
	int64 id;
	int flyState;
};


struct MonsterMoveInfo    <-
{
	vector<MoveInfo> ids;
};

struct MonsterStopMove <-
{
	int64 id;
	int16 x;
	int16 y;
};

struct PetMoveInfo    <-
{
	vector<MoveInfo> ids;
};

struct PetStopMove <-
{
	int64 id;
	int16 x;
	int16 y;
};


struct ChangeMap <->
{
	int mapDataID;
	int64 mapId;
	int16 x;
	int16 y;
};

struct CollectFail <-
{
};
//////////////////////////////////////////////////////////////////////////
//Player
struct RequestGM ->
{
	string	strCMD;
};

struct PlayerPropertyChangeValue
{
	int8	proType;
	int		value;
};
struct PlayerPropertyChanged <-
{
	vector<PlayerPropertyChangeValue>	changeValues;
};

struct PlayerMoneyChanged <-
{
	int8	changeReson;
	int8	moneyType;
	int		moneyValue;
};

struct PlayerKickOuted <-
{
	int		reserve;
};

struct ActorStateFlagSet <-
{
	int		nSetStateFlag;
};

struct ActorStateFlagSet_Broad <-
{
	int64	nActorID;
	int		nSetStateFlag;
};

//player skill
struct PlayerSkillInitData
{
	int16	nSkillID;
	int		nCD;
	int16	nActiveBranch1;
	int16	nActiveBranch2;
	int16 	nBindedBranch;
};
struct PlayerSkillInitInfo <-
{
	vector<PlayerSkillInitData>	info_list;
};

struct U2GS_StudySkill ->
{
	int nSkillID;
};

struct GS2U_StudySkillResult <-
{
	int nSkillID;
	int nResult;
};

struct activeBranchID->
{
	int8 nWhichBranch;
	int nSkillID;
	int branchID;
};

struct activeBranchIDResult<-
{
	int result;
	int nSkillID;
	int branckID;
};

struct U2GS_AddSkillBranch->
{
	int nSkillID;
	int nBranchID;
};

struct GS2U_AddSkillBranchAck<-
{
	int result;
	int nSkillID;
	int nBranchID;
};



//	使用技能请求
struct U2GS_UseSkillRequest ->
{
	int					nSkillID;
	vector<int64>	nTargetIDList;
	int					nCombatID;
};

// 向对象使用技能
struct GS2U_UseSkillToObject<-
{
	//	技能释放者
	int64		nUserActorID;
	//	技能ID
	int16	nSkillID;
	//	目标对象ID
	vector<int64>	nTargetActorIDList;
	//	客户端上传的技能使用时的值
	int		nCombatID;
};

// 向指定地点使用技能
struct GS2U_UseSkillToPos<-
{
	//	技能释放者
	int64		nUserActorID;
	//	技能ID
	int16	nSkillID;
	//	目标坐标X
	int16	x;
	//	目标坐标Y
	int16	y;
	//	客户端上传的技能使用时的值
	int		nCombatID;
	//
	vector<int64>  id_list;
};

//	攻击伤害消息
struct GS2U_AttackDamage<-
{
	//	伤害目标
	int64		nDamageTarget;
	//	客户端上传的技能使用时的值
	int		nCombatID;
	//	SkillID(可能是Skill(1---10000)，也可能是Buff的SkillID(10001---20000)
	int16	nSkillID;
	//	伤血数值
	int		nDamageLife;
	//	目标当前血量百分比
	int8	nTargetLifePer100;
	//是否格挡
	int8	isBlocked;
	//是否暴击
	int8	isCrited;
};

//	对象死亡消息
struct GS2U_CharactorDead <-
{
	//	死亡者
	int64		nDeadActorID;
	//	杀人者
	int64		nKiller;
	//技能释放唯一ID
	int			nCombatNumber;
};

//	攻击未命中
struct GS2U_AttackMiss<-
{
	//	攻击者ID
	int64	nActorID;
	//	目标ID
	int64 nTargetID;
	//	客户端上传的技能使用时的值
	int		nCombatID;
};

//	攻击时目标闪避了
struct GS2U_AttackDodge<-
{
	//	攻击者ID
	int64	nActorID;
	//	目标ID
	int64 nTargetID;
	//	客户端上传的技能使用时的值
	int		nCombatID;
};

//	攻击时目标暴击了
struct GS2U_AttackCrit<-
{
	//	攻击者ID
	int64	nActorID;
	//	客户端上传的技能使用时的值
	int		nCombatID;
};

//	攻击时目标格挡了
struct GS2U_AttackBlock<-
{
	//	攻击者ID
	int64	nActorID;
	//	客户端上传的技能使用时的值
	int		nCombatID;
};


struct PlayerAllShortcut <-
{
	int index1ID;
	int index2ID;
	int index3ID;
	int index4ID;
	int index5ID;
	int index6ID;
	int index7ID;
	int index8ID;
	int index9ID;
	int index10ID;
	int index11ID;
	int index12ID;
};

struct ShortcutSet ->
{
	int8 index;
	int data;
};

struct PlayerEXPChanged <-
{
	int		curEXP;
	int8	changeReson;
};

struct ActorLifeUpdate <-
{
	int64	nActorID;
	int		nLife;
	int		nMaxLife;
};

struct	ActorMoveSpeedUpdate<- 
{
	int64	nActorID;
	int		nSpeed;
};

struct PlayerCombatIDInit<-
{
	int		nBeginCombatID;
};

struct GS2U_CharactorRevived<-
{
	int64	nActorID;
	int		nLife;
	int		nMaxLife;
};

//物件交互
struct U2GS_InteractObject->
{
	int64	nActorID;
};

//客户端查询玩家主角属性
struct U2GS_QueryHeroProperty->
{
	int8	nReserve;
};

//服务器回复角色主角属性
struct CharPropertyData
{
	int8	nPropertyType;
	int		nValue;
};

struct GS2U_HeroPropertyResult<-
{
	vector<CharPropertyData>	info_list;
};

//////////////////////////////////////////////////////////////////////////
//PlayerItem
struct ItemInfo
{
	int64		id;
	int8		owner_type;
	int64		owner_id;
	int8	location;
	int16	cell;
	int		amount;
	int		item_data_id;

	int		param1;
	int		param2;
	int8	binded;
	int		remain_time;
};
//上线物品初始化
struct PlayerBagInit <-
{
	vector<ItemInfo> items;
};

//获得物品通知
struct PlayerGetItem <-
{
	ItemInfo	item_info;
};

//物品销毁通知
struct PlayerDestroyItem <-
{
	int64		itemDBID;
	int8		reson;
};

//物品位置变化
struct PlayerItemLocationCellChanged <-
{
	int64		itemDBID;
	int8		location;
	int16		cell;
};


//物品销毁请求
struct RequestDestroyItem ->
{
	int64		itemDBID;
};

//GM获得物品请求
struct RequestGetItem ->
{
	int			itemDataID;
	int			amount;
};

//玩家物品数量变化
struct PlayerItemAmountChanged <-
{
	int64		itemDBID;
	int			amount;
	int			reson;
};

//玩家物品参数变化
struct PlayerItemParamChanged <-
{
	int64		itemDBID;
	int			param1;
	int			param2;
	int			reson;
};

struct PlayerBagOrderData
{
	int64		itemDBID;
	int			amount;
	int			cell;
};


//背包整理请求
struct RequestPlayerBagOrder ->
{
	int			location;
	//vector<PlayerBagOrderData>	orderDatas; 
};

//背包整理结束回馈
struct PlayerBagOrderResult <-
{
	int		location;
	int		cell;//可以不用参数的
};


//	使用物品请求
struct PlayerRequestUseItem ->
{
	int16	location;
	int16	cell;
	int16	useCount;
};

//	使用物品结果
struct PlayerUseItemResult <-
{
	int16	location;
	int16	cell;
	int		result;
};

//	开启格子请求
struct RequestPlayerBagCellOpen ->
{
	int		cell;
	int   location;
};
//密码变化请求
struct RequestChangeStorageBagPassWord ->
{
	string  oldStorageBagPassWord;
	string  newStorageBagPassWord;
	int status ;
};

struct PlayerStorageBagPassWordChanged <-
{
	int	result; 	
};
//	玩家格子有效个数变化
struct PlayerBagCellEnableChanged <-
{
	int		cell;
	int		location;
	int		gold;
	int		item_count;
};


//	背包内出售物品
struct RequestPlayerBagSellItem ->
{
	int		cell;
};

//	请求将临时背包内物品清空
struct RequestClearTempBag ->
{
	int		reserve;
};

//	请求将临时背包内物品放到主背包
struct RequestMoveTempBagItem ->
{
	int		cell;
};

//	请求将临时背包内物品全部放到主背包
struct RequestMoveAllTempBagItem ->
{
	int		reserve;
};

//	请求将仓库内某格子上物品移动到主背包
struct RequestMoveStorageBagItem ->
{
	int		cell;
};

//	请求将主背包内某格子上物品移动到仓库
struct RequestMoveBagItemToStorage ->
{
	int		cell; 
};
//	请求强制解锁仓库密码的请求，即72小时之后开始解锁
struct RequestUnlockingStorageBagPassWord ->
{
	int		passWordType;
};
//	请求取消强制解锁仓库密码
struct RequestCancelUnlockingStorageBagPassWord ->
{
	int		passWordType;
};
//返回强制解锁的剩余时间
struct PlayerUnlockTimesChanged <-
{
	int	unlockTimes;
};

// 背包内某格子位置上设置为
struct ItemBagCellSetData
{
	int		location;
	int		cell;
	int64	itemDBID;
};
struct ItemBagCellSet <-
{
	vector<ItemBagCellSetData> cells;
};

//////////////////////////////////////////////////////////////////////////
//NpcStore
struct NpcStoreItemData
{
	int64		id;					//服务器保存id
	int		item_id;			//物品id
	int		price;				//售价
	int		isbind;				//是否购买后绑定  1是绑定，0是不绑定
};


//请求商店物品列表
struct RequestGetNpcStoreItemList ->
{
	int		store_id;
};

struct GetNpcStoreItemListAck <-
{
	int		store_id;
	vector<NpcStoreItemData>	itemList;
};

struct RequestBuyItem ->   //购买物品请求
{
	int		item_id;
	int		amount;
	int		store_id;
};
struct BuyItemAck <- //这是交易结束后的回调，包含，出售，购买，回购，兑换
{
	int		count;
}
struct RequestSellItem ->   //出售物品请求
{
	int64		item_cell;
};

struct GetNpcStoreBackBuyItemList ->
{
	int		count;
};
struct GetNpcStoreBackBuyItemListAck <-
{
	vector<ItemInfo>	itemList;
};
struct RequestBackBuyItem ->   //回购物品请求
{
	int64		item_id;
};

//////////////////////////////////////////////////////////////////////////
// PlayerEquip
struct PlayerEquipNetData
{
	int		dbID;					//服务器装备dbID;
	int		nEquip;						//配置文件装备Id;
	int8	type;						//装备类型
	int8	nQuality;					//品质
	int8	isEquiped;					//是否已经装备上
	int16	enhanceLevel;				//强化等级


	int8		property1Type;				//附加属性1的类型
	int8		property1FixOrPercent;		//附加属性1FixOrPercent
	int			property1Value;				//附加属性1的值
	int8		property2Type;				//附加属性2的类型
	int8		property2FixOrPercent;		//附加属性2FixOrPercent
	int			property2Value;				//附加属性2的值
	int8		property3Type;				//附加属性3的类型
	int8		property3FixOrPercent;		//附加属性3FixOrPercent
	int			property3Value;				//附加属性3的值
	int8		property4Type;				//附加属性4的类型
	int8		property4FixOrPercent;		//附加属性4FixOrPercent
	int			property4Value;				//附加属性4的值
	int8		property5Type;				//附加属性5的类型
	int8		property5FixOrPercent;		//附加属性5FixOrPercent
	int			property5Value;				//附加属性5的值
	
};

// 玩家主角装备初始化
struct PlayerEquipInit <-
{
	vector<PlayerEquipNetData>	equips;
};

//	装备激活请求
struct RequestPlayerEquipActive ->
{
	int		equip_data_id;				//装备数据id
};

//	装备激活结果
struct PlayerEquipActiveResult <-
{
	PlayerEquipNetData	equip;
};

//	穿上装备
struct RequestPlayerEquipPutOn ->
{
	int		equip_dbID;					//	装备dbID
};

//	穿上装备结果
struct PlayerEquipPutOnResult <-
{
	int		equip_dbID;					//	装备dbID
	int8	equiped;
};

//	查询玩家装备
struct RequestQueryPlayerEquip ->
{
	int64		playerid;
};

//	查询玩家装备结果
struct QueryPlayerEquipResult <-
{
	vector<PlayerEquipNetData>	equips;
};

struct StudySkill ->
{
	int id;
	int lvl;
};

struct StudyResult <-
{
	int8 result; // 0. failed 1. ok;
	int id;
	int lvl;
};

struct Reborn ->
{
	int8 type;
};

struct RebornAck <-
{
	int x;
	int y;
};

//chat
struct Chat2Player <-
{
	int8 channel;
	int64 sendID;
	int64 receiveID;
	string sendName;
	string receiveName;
	string content;
	int8	vipLevel;
};

struct Chat2Server ->
{
	int8 channel;
	int64 sendID;
	int64 receiveID;
	string sendName;
	string receiveName;
	string content;
};

struct Chat_Error_Result<-
{
	int reason;
};

//////////////////////////////////////////////////////////////////////////
// Mail
struct RequestSendMail ->
{
	int64		targetPlayerID;
	string  targetPlayerName;
	string	strTitle;
	string	strContent;
	int64		attachItemDBID1;
	int			attachItem1Cnt;
	int64		attachItemDBID2;
	int			attachItem2Cnt;
	int		moneySend;
	int		moneyPay;
};

struct RequestSendMailAck <-
{
	int8 result;
};

struct RequestRecvMail ->
{
	int64		mailID;
	int		deleteMail;
};

struct RequestUnReadMail ->
{
	int64 playerID;
};

struct RequestUnReadMailAck <-
{
	int unReadCount;
};

struct RequestMailList ->
{
	int64 playerID;
};

struct MailInfo
{
	int64 id;
	int type;
	int64 recvPlayerID;
	int isOpen;
	int timeOut;
	int senderType;
	string senderName;
	string title;
	string content;
	int8 haveItem;
	int moneySend;
	int moneyPay;
	int mailTimerType;
	int mailRecTime;
};

struct RequestMailListAck <-
{
	vector<MailInfo> mailList;
};

struct RequestMailItemInfo ->
{
	int64 mailID;
};

struct RequestMailItemInfoAck <-
{
	int64 mailID;
	vector<ItemInfo> mailItem;
};

struct RequestAcceptMailItem ->
{
	int64 mailID;
	int isDeleteMail;
};

struct RequestAcceptMailItemAck <-
{
	int result;
};

struct MailReadNotice ->
{
	int64 mailID;
};

struct RequestDeleteMail ->
{
	int64 mailID;
};

struct InformNewMail <-
{
};

struct RequestDeleteReadMail ->
{
	vector<int64> readMailID;
};

//////测试指令，以后删除
struct RequestSystemMail ->
{
};

//////////////////////////////////////////////////////////////////////////
// User 2 GameServer
struct U2GS_RequestLogin ->
{
	int64		userID;
	string	identity;
	int protocolVer;
};

struct U2GS_SelPlayerEnterGame ->
{
	int64		playerID;
};

struct U2GS_RequestCreatePlayer ->
{
	string	name;
	int8	camp;
	int8	classValue;
	int8	sex;
};

struct U2GS_RequestDeletePlayer ->
{
	int64		playerID;
};

//////////////////////////////////////////////////////////////////////////
// GameServer 2 User
struct GS2U_LoginResult <-
{
	int		result;
};

struct GS2U_SelPlayerResult <-
{
	int result;
};

struct UserPlayerData
{
	int64		playerID;
	string	name;
	int		level;
	int8	classValue;
	int8	sex;
	int8	faction
};

struct GS2U_UserPlayerList <-
{
	vector<UserPlayerData>	info;
};

struct GS2U_CreatePlayerResult <-
{
	int		errorCode;
};

struct GS2U_DeletePlayerResult <-
{
	int64		playerID;
	int		errorCode;
};

//////////////////////////////////////////////////////////////////////////

//////////////////////////////交易行/////////////////////////////////////

struct ConSales_GroundingItem ->
{
	int64 dbId;
	int count;
	int money;
	int timeType, 
};

struct ConSales_GroundingItem_Result <-
{
	int result;
};

struct ConSales_TakeDown ->
{
	int64 conSalesId;
};

struct ConSales_TakeDown_Result <-
{
	int allTakeDown;
	int result;
};

struct ConSales_BuyItem ->
{
	int64 conSalesOderId;
};

struct ConSales_BuyItem_Result <-
{
	int8 result;
};

struct ConSales_FindItems ->
{
	int offsetCount;
	int8 ignoreOption;
	int8 type;
	int8 detType;
	int levelMin;
	int levelMax;
	int occ; 
	int quality; 
	int idLimit;
	vector<int> idList;
};

struct ConSalesItem
{
	int64 conSalesId;
	int conSalesMoney;
	int groundingTime;
	int timeType;
	int playerId; 
	string playerName;
	int itemDBId;
	int itemId; 
	int itemCount;
	int itemType; 
	int itemQuality; 
	int itemLevel; 
	int itemOcc;
};

struct ConSales_FindItems_Result <-
{
	int result;
	int allCount;
	int page;
	vector<ConSalesItem>	 itemList;
};

struct ConSales_TrunPage ->
{
	int mode;
};

struct ConSales_Close ->
{
	int n;
};

struct ConSales_GetSelfSell ->
{
	int n;
};

struct ConSales_GetSelfSell_Result<-
{
	vector<ConSalesItem>	 itemList;
};

//////////////////////////////////////////////////////////////////////////

/////////////////////////////////交易/////////////////////////////////////
struct TradeAsk <->
{
	int64 playerID;
	string playerName;
};

struct TradeAskResult <->
{
	int64 playerID;
	string playerName;
	int8 result;
};

struct CreateTrade <-
{
	int64 playerID;
	string playerName;
	int8 result;
};

struct TradeInputItem_C2S->
{
	int cell;
	int64 itemDBID;
	int count;
};

struct  TradeInputItemResult_S2C<-
{
	int64 itemDBID;
	int item_data_id;
	int count;
	int cell;
	int8 result;
};

struct TradeInputItem_S2C<-
{
	int64 itemDBID;
	int item_data_id;
	int count;
};

struct TradeTakeOutItem_C2S->
{
	int64 itemDBID;
};

struct TradeTakeOutItemResult_S2C<-
{
	int cell;
	int64 itemDBID;
	int8 result;
};

struct TradeTakeOutItem_S2C<-
{
	int64 itemDBID;
};

struct TradeChangeMoney_C2S->
{
	int money;
};

struct TradeChangeMoneyResult_S2C<-
{
	int money;
	int8 result;
};

struct TradeChangeMoney_S2C<-
{
	int money;
};

struct TradeLock_C2S->
{
	int8 lock;
};

struct TradeLock_S2C<-
{
	int8 person;
	int8 lock;
};

struct CancelTrade_S2C <-
{
	int8 person;
	int8 reason;
};

struct CancelTrade_C2S ->
{
	int8 reason;
};

struct TradeAffirm_C2S->
{
	int bAffrim;
};

struct TradeAffirm_S2C<-
{
	int8 person;
	int8 bAffirm;
};
//////////////////////////////////////////////////////////////////////////


///////////////////////////////////宠物//////////////////////////////////

struct	PetSkill 
{
	int64	id;
	int	coolDownTime;
};

struct PetProperty
{
	int64	db_id;
	int	data_id;
	int64	master_id;
	int	level;
	int	exp;
	string	name;
	int	titleId;
	int8	aiState;
	int8	showModel;
	int	exModelId;
	int	soulLevel;
	int	soulRate;
	int	attackGrowUp;
	int	defGrowUp;
	int	lifeGrowUp;
	int8	isWashGrow;
	int	attackGrowUpWash;
	int	defGrowUpWash;
	int	lifeGrowUpWash;
	int	convertRatio;
	int	exerciseLevel;
	int	moneyExrciseNum;
	int	exerciseExp;
	int	maxSkillNum;
	vector<PetSkill>	skills;

	int	life;
	int	maxLife;
	int	attack;
	int	def;
	int	crit;
	int	block;
	int	hit;
	int	dodge;
	int	tough;
	int	pierce;

	int	crit_damage_rate;
	int	attack_speed;
	int	ph_def;
	int	fire_def;
	int	ice_def;
	int	elec_def;
	int	poison_def;
	int	coma_def;
	int	hold_def;
	int	silent_def;
	int	move_def;

	int	atkPowerGrowUp_Max;
	int	defClassGrowUp_Max;
	int	hpGrowUp_Max;
	int	benison_Value;
};

struct PlayerPetInfo <- 
{
	vector<int>		petSkillBag;
	vector<PetProperty>	petInfos;
};

struct UpdatePetProerty<- 
{
	PetProperty		petInfo;
};

struct	DelPet<-
{
	int64	petId;
};

struct  PetOutFight ->
{
	int64	petId;
};

struct  PetOutFight_Result<-
{
	int8	result;
	int64	petId;
};

struct	PetTakeRest -> 
{
	int64	petId;
};

struct	PetTakeRest_Result<-
{
	int8	result;
	int64	petId;
};

struct	PetFreeCaptiveAnimals->
{
	int64	petId;
};

struct	PetFreeCaptiveAnimals_Result<-
{
	int8	result;
	int64	petId;
};


struct	PetCompoundModel-> 
{
	int64	petId;
};

struct	PetCompoundModel_Result<-
{
	int8	result;
	int64	petId;
};

struct	PetWashGrowUpValue-> 
{
	int64	petId;
};

struct	PetWashGrowUpValue_Result <- 
{
	int8	result;
	int64	petId;
	int	attackGrowUp;
	int	defGrowUp;
	int	lifeGrowUp;
};

struct	PetReplaceGrowUpValue -> 
{
	int64	petId;
};

struct	PetReplaceGrowUpValue_Result<-
{
	int8	result;
	int64	petId;
};

struct	PetIntensifySoul	-> 
{
	int64	petId;
};

struct	PetIntensifySoul_Result<- 
{
	int8	result;
	int64	petId;
	int	soulLevel;
	int	soulRate;
	int	benison_Value;
};

struct	PetOneKeyIntensifySoul	-> 
{
	int64	petId;
};

struct	PetOneKeyIntensifySoul_Result	<- 
{
	int64	petId;
	int8	result;
	int	itemCount;
	int	money;
};

struct	PetFuse-> 
{
	int64	petSrcId;
	int64	petDestId;
};

struct	PetFuse_Result<- 
{
	int8	result;
	int64	petSrcId;
	int64	petDestId;
};

struct	PetJumpTo <- 
{
	int64	petId;
	int	x;
	int	y;
};

struct	ActorSetPos<- 
{
	int64	actorId;
	int	x;
	int	y;
};

struct	PetTakeBack<-
{
	int64	petId;
};

struct	ChangePetAIState <-> 
{
	int8	state;
};

struct	PetExpChanged<-
{
	int64	petId;
	int	curExp;
	int8	reason;
};

struct	PetLearnSkill->
{
	int64	petId;
	int		skillId;
};

struct	PetLearnSkill_Result<-
{
	int8		result;
	int64	petId;
	int		oldSkillId;
	int		newSkillId;
};

struct	PetDelSkill-> 
{
	int64	petId;
	int		skillId;
};

struct	PetDelSkill_Result <- 
{
	int8		result;
	int64	petId;
	int		skillid;
};

struct	PetUnLockSkillCell-> 
{
	int64	petId;
};

struct	PetUnLoctSkillCell_Result <- 
{
	int8		result;
	int64	petId;
	int		newSkillCellNum;
};

struct	PetSkillSealAhs->
{
	int64	petId;
	int		skillid;
};

struct	PetSkillSealAhs_Result<-
{
	int8		result;
	int64	petId;
	int		skillid;
};

struct	PetUpdateSealAhsStore<- 
{
	vector<int>		petSkillBag;
};

struct	PetlearnSealAhsSkill-> 
{
	int64	petId;
	int		skillId;
};

struct	PetlearnSealAhsSkill_Result<-
{
	int8		result;
	int64	petId;
	int		oldSkillId;
	int		newSkillId;
};

/////////////////////////////////////////////////////////////////////////





//////////////////////////装备强化///////////////////////////////////////////////

//请求装备强化情况及其返回
struct	RequestGetPlayerEquipEnhanceByType->
{
	int	type;
};
struct	GetPlayerEquipEnhanceByTypeBack <-
{
	int	type;
	int	level;
	int	progress;
	int	blessValue;
};
//强化请求及其返回
struct	RequestEquipEnhanceByType ->
{
	int	type;
};

struct	EquipEnhanceByTypeBack <-
{
	int	result;
};
//一键强化请求及其返回
struct	RequestEquipOnceEnhanceByType ->
{
	int	type;
};

struct	EquipOnceEnhanceByTypeBack <-
{
	int	result;
	int	times;
	int	itemnumber;
	int	money;
};

//////////////////////////装备升品///////////////////////////////////////////////

//请求装备品质及其返回
struct	RequestGetPlayerEquipQualityByType->
{
	int	type;
}；
struct	GetPlayerEquipQualityByTypeBack <-
{
	int type;
	int	quality;
};

//强化请求及其返回
struct	RequestEquipQualityUPByType ->
{
	int	type;
};

struct	EquipQualityUPByTypeBack <-
{
	int result;
};


/////////////////////////////////////////////////装备洗髓///////////////////////////////////////////////
//请求旧属性~及其返回
struct	RequestEquipOldPropertyByType ->
{
	int	type;
};

struct	GetEquipOldPropertyByType <-
{
	int	type;
	int8		property1Type;				//附加属性1的类型
	int8		property1FixOrPercent;		//附加属性1FixOrPercent
	int			property1Value;				//附加属性1的值
	int8		property2Type;				//附加属性2的类型
	int8		property2FixOrPercent;		//附加属性2FixOrPercent
	int			property2Value;				//附加属性2的值
	int8		property3Type;				//附加属性3的类型
	int8		property3FixOrPercent;		//附加属性3FixOrPercent
	int			property3Value;				//附加属性3的值
	int8		property4Type;				//附加属性4的类型
	int8		property4FixOrPercent;		//附加属性4FixOrPercent
	int			property4Value;				//附加属性4的值
	int8		property5Type;				//附加属性5的类型
	int8		property5FixOrPercent;		//附加属性5FixOrPercent
	int			property5Value;				//附加属性5的值
};
//洗髓请求及其返回的新属性
struct	RequestEquipChangePropertyByType ->
{
	int	type;
	int8	property1;//0表示不改变（即锁定），1表示要改变
	int8	property2;
	int8	property3;
	int8	property4;
	int8	property5;
};

struct	GetEquipNewPropertyByType <-
{
	int	type;
	int8		property1Type;				//附加属性1的类型
	int8		property1FixOrPercent;		//附加属性1FixOrPercent
	int			property1Value;				//附加属性1的值
	int8		property2Type;				//附加属性2的类型
	int8		property2FixOrPercent;		//附加属性2FixOrPercent
	int			property2Value;				//附加属性2的值
	int8		property3Type;				//附加属性3的类型
	int8		property3FixOrPercent;		//附加属性3FixOrPercent
	int			property3Value;				//附加属性3的值
	int8		property4Type;				//附加属性4的类型
	int8		property4FixOrPercent;		//附加属性4FixOrPercent
	int			property4Value;				//附加属性4的值
	int8		property5Type;				//附加属性5的类型
	int8		property5FixOrPercent;		//附加属性5FixOrPercent
	int			property5Value;				//附加属性5的值
};

//保存新属性
struct	RequestEquipSaveNewPropertyByType ->
{
	int	type;

};
//洗髓和保存结果
struct	RequestEquipChangeAddSavePropertyByType <-
{
	int	result;
};



//请求进入副本，与npc对话
struct U2GS_EnterCopyMapRequest->
{
	int64	npcActorID;
	int		enterMapID;
};
//地图切换结果
struct GS2U_EnterMapResult<-
{
	int		result;
};

//查询副本CD
struct U2GS_QueryMyCopyMapCD->
{
	int		reserve;
};

//副本CD信息
struct MyCopyMapCDInfo
{
	//地图DataID
	int16	mapDataID;
	//该地图已经进入次数
	int8	mapEnteredCount;
	//剩余活跃次数
	int8	mapActiveCount;
};

struct GS2U_MyCopyMapCDInfo<-
{
	vector<MyCopyMapCDInfo>	info_list;
};

//buff
struct	AddBuff<-
{
	int64	actor_id;
	int16	buff_data_id;
	int16	allValidTime;
	int8	remainTriggerCount;
};

struct	DelBuff<-
{
	int64	actor_id;
	int16	buff_data_id;
};

struct	UpdateBuff<-
{
	int64	actor_id;
	int16	buff_data_id;
	int8	remainTriggerCount;
};

struct	HeroBuffList<- 
{
	vector<ObjectBuff>	buffList;
};

//世界地图传送
struct	U2GS_TransByWorldMap->
{
	int mapDataID;
	int posX;
	int posY;
};

struct	U2GS_TransForSameScence->
{
	int mapDataID;
	int posX;
	int posY;
};

//副本快速组队请求
struct U2GS_FastTeamCopyMapRequest->
{
	int64	npcActorID;
	int		mapDataID;
	// enterOrQuit=0表示进入，enterOrQuit=1表示退出
	int8	enterOrQuit; 
};
//副本快速组队请求结果
struct GS2U_FastTeamCopyMapResult<-
{
	int		mapDataID;
	// 结果码，>=0表示enterOrQuit有效，<0表示操作错误，值类型见EnterMap_Fail_Type
	int		result;
	int8	enterOrQuit; 
};

//组队进入副本确认
struct GS2U_TeamCopyMapQuery<-
{
	int		nReadyEnterMapDataID;
	int		nCurMapID;
	int		nPosX;
	int		nPosY;
	int		nDistanceSQ;
};

//副本重置
struct U2GS_RestCopyMapRequest->
{
	int64	nNpcID;
	int		nMapDataID;
};

//仇恨对象在玩家主角中增加或删除
struct GS2U_AddOrRemoveHatred<-
{
	int64	nActorID;
	int8	nAddOrRemove;
};

//切磋邀请
struct U2GS_QieCuoInvite->
{
	int64	nActorID;
};
//切磋邀请询问
struct GS2U_QieCuoInviteQuery<-
{
	int64	nActorID;
	string	strName;
};
//切磋邀请回复
struct U2GS_QieCuoInviteAck->
{
	int64	nActorID;
	int8	agree;		
};
//切磋邀请结果
struct GS2U_QieCuoInviteResult<-
{
	int64	nActorID;
	int8	result;
};
//切磋结果
struct GS2U_QieCuoResult<-
{
	int64	nWinner_ActorID;
	string	strWinner_Name;

	int64	nLoser_ActorID;
	string	strLoser_Name;

	int8	reson;
};

//杀戮模式开启请求
struct U2GS_PK_KillOpenRequest->
{
	int8	reserve;
};
//杀戮模式开启结果
struct GS2U_PK_KillOpenResult<-
{
	int		result;
	int		pK_Kill_RemainTime;
	int		pk_Kill_Value;
};
//换装备时的全图广播
struct GS2U_Player_ChangeEquipResult<-
{
	int64	playerID;
	int		equipID;
};

//系统广播
struct	SysMessage<- 
{
	int 	type;
	string	text;
};

//喝药加血
struct GS2U_AddLifeByItem<-
{
	int64	actorID;
	int		addLife;
	int8	percent;
};

//技能加血
struct GS2U_AddLifeBySkill<-
{
	int64	actorID;
	int		addLife;
	int8	percent;
	// 是否暴击，=0表示没有暴击，!=0表示暴击
	int8	crite;
};

//物品CD信息
struct PlayerItemCDInfo
{
	//物品CD类型ID，ItemData::m_cdTypeID
	int8	cdTypeID;
	//剩余时间，单位：秒，<= 0表示cd结束
	int		remainTime;
	//总时间，单位：秒
	int		allTime;
};

//玩家上线初始化物品CD
struct GS2U_PlayerItemCDInit<-
{
	vector<PlayerItemCDInfo>	info_list;
};

//物品CD更新
struct GS2U_PlayerItemCDUpdate<-
{
	PlayerItemCDInfo	info;
};


struct	U2GS_BloodPoolAddLife->
{
	int64	actorID;
};

struct GS2U_ItemDailyCount<-
{
	int		remainCount;
	int		task_data_id;
};

//玩家签到
struct U2GS_GetSigninInfo ->
{
};
//玩家签到信息
struct GS2U_PlayerSigninInfo<-
{
	//今天是否已签到，1为已签到,0为还没有签到
	int8	isAlreadySign;
	//已连续签到的天数(0 ~7)
	int8    days; 
};
//玩家签到
struct U2GS_Signin ->
{
};

//玩家签到结果
struct GS2U_PlayerSignInResult<-
{
	int	nResult;
	int8   awardDays; 
};


struct	U2GS_LeaveCopyMap -> 
{
	int8 reserve;
};

//宠物幻化
struct	PetChangeModel<-
{
	int64	petId;
	int		modelID;
};

//宠物改名
struct	PetChangeName <->
{
	int64	petId;
	string	newName;
};

struct	PetChangeName_Result<-
{
	int8		result;
	int64	petId;
	string	newName;
};


//商城协议
struct BazzarItem
{
	//物品DBID
	int		db_id;
	//	物品ID
	int16	item_id;
	//类型，取值为（0，优惠；1，常用道具；2，宠物坐骑；3装备强化,	
	int8		item_column;
	//	金币
	int16	gold;
	//	绑定金币
	int16	binded_gold;
	//	剩余数量(-1表示无数量限制）
	int16	remain_count;
	//	剩余时间（单位：秒）(-1表示无时间限制）
	int		remain_time;
};

//商城物品列表请求
struct  BazzarListRequest->
{
	int	seed;		//客户端种子，用于判断是否更新所有物品列表给客户端
};

//优惠商城列表
struct BazzarPriceItemList<-
{
	vector<BazzarItem> itemList;
};

//所有商城物品列表
struct BazzarItemList<-
{
	int	seed;		//客户端种子，用于判断是否更新所有物品列表给客户端
	vector<BazzarItem> itemList;
};

//更新单个物品，适用于优惠商城数量更新
struct BazzarItemUpdate<-
{
	BazzarItem item;
};

//物品购买请求
struct	BazzarBuyRequest->
{
	int	db_id;
	int16	isBindGold;
	int16	count;
};

//物品购买返回
struct  BazzarBuyResult<- 
{
	int8 result;
};

//开启格子返回
struct PlayerBagCellOpenResult<-
{
	int8 result;
};

//移除分支技能
struct U2GS_RemoveSkillBranch->
{
	int nSkillID;
}

//移除分支技能回包
struct GS2U_RemoveSkillBranch<-
{
	int result;
	int nSkillID;
}

struct	U2GS_PetBloodPoolAddLife->
{
	int8	n;
};

//增加活跃次数
struct	U2GS_CopyMapAddActiveCount->
{
	int16 map_data_id;
};

//增加活跃次数返回
struct	U2GS_CopyMapAddActiveCountResult<-
{
	int16 result;
};

//护送相关
//玩家当前的护送信息
struct GS2U_CurConvoyInfo<-
{
	int8 isDead;
	int convoyType;
	int carriageQuality;
	int remainTime;
	int lowCD;
	int highCD;
	int freeCnt;
};
//镖车品质刷新
struct U2GS_CarriageQualityRefresh->
{
	int isRefreshLegend;
	int isCostGold;
	int curConvoyType;
	int curCarriageQuality;
	int curTaskID;
};
//镖车品质刷新结果
struct GS2U_CarriageQualityRefreshResult<-
{
	int retCode;
	int newConvoyType;
	int newCarriageQuality;
	int freeCnt;
};

//请求护送CD信息
struct U2GS_ConvoyCDRequst->
{
};
struct GS2U_ConvoyCDResult<-
{
	int8 retCode;
};

//开始护送
struct U2GS_BeginConvoy->
{
	int	nTaskID;
	int curConvoyType;
	int curCarriageQuality;
	int64 nNpcActorID;
};
struct GS2U_BeginConvoyResult<-
{
	int retCode;
	int curConvoyType;
	int curCarriageQuality;
	int remainTime;
	int lowCD;
	int highCD;
};
struct GS2U_FinishConvoyResult<-
{
	int curConvoyType;
	int curCarriageQuality;
};
struct GS2U_GiveUpConvoyResult<-
{
	int curConvoyType;
	int curCarriageQuality;
};
struct GS2U_ConvoyNoticeTimerResult<-
{
	int8 isDead;
	int remainTime;
};
struct GS2U_ConvoyState<-
{
	int8 convoyFlags;
	int quality;
	int64 actorID;
};




struct GSWithU_GameSetMenu <->
{
	int8 joinTeamOnoff;
	int8 inviteGuildOnoff;
	int8 tradeOnoff;
	int8 applicateFriendOnoff;
	int8 singleKeyOperateOnoff;
	int8 musicPercent;
	int8 soundEffectPercent;
	int8 shieldEnermyCampPlayer;
	int8 shieldSelfCampPlayer;
	int8 shieldOthersPet;
	int8 shieldOthersName;
	int8 shieldSkillEffect;
	int8 dispPlayerLimit;
};

// 领取充值礼包
struct U2GS_RequestRechargeGift->
{
	int8 type;
};

// 领取充值礼包返回
struct U2GS_RequestRechargeGift_Ret<-
{
	int8 retcode;
};

// 请求角色战斗力
struct U2GS_RequestPlayerFightingCapacity->
{

};

// 请求角色战斗力返回
struct U2GS_RequestPlayerFightingCapacity_Ret<-
{
	int fightingcapacity;
};

// 请求宠物战斗力
struct U2GS_RequestPetFightingCapacity->
{
	int petid;
};

// 请求宠物战斗力返回
struct U2GS_RequestPetFightingCapacity_Ret<-
{
	int fightingcapacity;
};

// 请求坐骑战斗力
struct U2GS_RequestMountFightingCapacity->
{
	int mountid;
};

// 请求坐骑战斗力返回
struct U2GS_RequestMountFightingCapacity_Ret<-
{
	int fightingcapacity;
};

//变量设置
struct VariantData
{
	int16	index;
	int		value;
};
struct GS2U_VariantDataSet<-
{
	int8	variant_type;
	vector<VariantData>	info_list;
};


// world boss
struct U2GS_GetRankList->
{
	int mapDataID;
};

struct GS2U_RankList<-

{
	
	int mapID;
	int rankNum;
	string name1;
	int harm1;
	string name2;
	int harm2;
	string name3;
	int harm3;

	string	name4;
	int harm4;
	string name5;
	int harm5;
	string name6;
	int harm6;

	string name7;
	int harm7;
	string name8;
	int harm8;
	string name9;
	int harm9;
	string name10;
	
	int harm10;

};



struct GS2U_WordBossCmd<-
{
	int m_iCmd;
	int m_iParam;
};



//角色改名
struct U2GS_ChangePlayerName->
{
	int64 id;
	string name;
};
struct GS2U_ChangePlayerNameResult<-
{
	int retCode;
};


struct U2GS_SetProtectPwd->
{
	int64 id;
	string oldpwd;
	string pwd;
};
struct GS2U_SetProtectPwdResult<-
{
	int retCode;
};

struct U2GS_HeartBeat->
{
};

struct GS2U_CopyProgressUpdate<-
{
	int8	progress;
};

struct U2GS_QequestGiveGoldCheck->
{
};
struct U2GS_StartGiveGold->
{
};
struct U2GS_StartGiveGoldResult<-
{
	int8 goldType;
	int8 useCnt;
	int  exp;
	int  level;
	int  awardMoney;
	int  retCode;
};
struct U2GS_GoldLineInfo<-
{
	int8 useCnt;
	int  exp;
	int  level;
};
struct U2GS_GoldResetTimer<-
{
	int8 useCnt;
};

//副本结算信息
struct GS2U_CopyMapSAData<-
{
	int  map_id;
	int  killed_count;
	int8 finish_rate;
	int  cost_time;
	int   exp;
	int   money;
	int8 level;
	int8 is_perfect;
};

//tokenStore 令牌商店
struct TokenStoreItemData
{
	int64		id;					//服务器保存id
	int		item_id;			//物品id
	int		price;				//售价
	int		tokenType;			//牌子类型
	int		isbind;				//是否购买后绑定  1是绑定，0是不绑定
};

struct GetTokenStoreItemListAck <-
{
	int store_id;
	vector<TokenStoreItemData>	itemList;
};

//请求查看玩家
struct	RequestLookPlayer->
{
	int64 playerID;
};

//查看玩家请求返回，
struct	RequestLookPlayer_Result<-
{
	PlayerBaseInfo		baseInfo;			//基础属性
	vector<CharPropertyData>	propertyList;	//属性列表	 
	vector<PetProperty>	petList;		//宠物列表
	vector<PlayerEquipNetData>	equipList; //装备列表
	int	fightCapacity;	//战斗力
};

//查看玩家请求失败返回
struct	RequestLookPlayerFailed_Result<-
{
	int8 result;
};

struct U2GS_PlayerClientInfo->
{
	int64 playerid;
	string platform;
	string machine;
};

//请求玩家活跃信息
struct U2GS_RequestActiveCount->
{
	int8	n;
};

struct	ActiveCountData 
{
	int	daily_id;
	int	count;
};

//玩家请求活跃度的返回
struct GS2U_ActiveCount<-
{
	int	activeValue;			//活跃值
	vector<ActiveCountData>	dailyList;
};

//玩家请求兑换活跃值
struct	U2GS_RequestConvertActive->
{
	int	n;
};


//询问是否把以前的充值转到某一角色
struct GS2U_WhetherTransferOldRecharge<-
{
	int64		playerID;
	string name;
	int rechargeRmb;
};
//把以前的充值转到某一角色
struct	U2GS_TransferOldRechargeToPlayer->
{
	int64 playerId;
	int8 isTransfer; //0:不转；1：转到些角色
};
//转移老的充值的结果
struct GS2U_TransferOldRechargeResult<-
{
	int errorCode;
};

//	装备激活失败原因
struct PlayerEquipActiveFailReason <-
{
	int reason;
};

//	装备等级变化广播
struct PlayerEquipMinLevelChange<-
{
	int64		playerid;
	int8		minEquipLevel;
};
//输入仓库密码
struct PlayerImportPassWord ->
{
	string passWord;
	int passWordType;
};

//输入仓库密码结果
struct PlayerImportPassWordResult <-
{
	int result;
};

struct  GS2U_UpdatePlayerGuildInfo<-
{
	int64	player_id;
	int64	guild_id;
	string	guild_name;
	int8		guild_rank;
};

struct U2GS_RequestBazzarItemPrice->
{
	int	item_id;
};

struct U2GS_RequestBazzarItemPrice_Result<-
{
	vector<BazzarItem> item;
};

//元宝密码变化请求
struct RequestChangeGoldPassWord ->
{
	string  oldGoldPassWord;
	string  newGoldPassWord;
	int status ;
};

//元宝密码变化结果
struct PlayerGoldPassWordChanged <-
{
	int	result; 	
};
//输入元宝密码结果
struct PlayerImportGoldPassWordResult <-
{
	int result;
};
//返回强制解锁的剩余时间
struct PlayerGoldUnlockTimesChanged <-
{
	int	unlockTimes;
};

struct GS2U_LeftSmallMonsterNumber <-
{
	int16 leftMonsterNum;
};

//VIP信息
struct GS2U_VipInfo <-
{
	int vipLevel;
	int vipTime;
	int vipTimeExpire;
	int vipTimeBuy;
};

//告诉玩家，当前进入的是第几线
struct GS2U_TellMapLineID <-
{
	int8 iLineID;
};

//请求打开远程商店，VIP玩家
struct VIPPlayerOpenVIPStoreRequest ->
{
	int request;
};

struct VIPPlayerOpenVIPStoreFail <-
{
	int fail;
}

//同步VIP等级给玩家
struct UpdateVIPLevelInfo<-
{
	int64	playerID;
	int8		vipLevel;
};

//激活码请求
struct ActiveCodeRequest->
{
	string	active_code;
};

//激活码请求结果
struct ActiveCodeResult<-
{
	int		result;
};

//请求出战宠物的具体属性
struct  U2GS_RequestOutFightPetPropetry->
{
	int8	n;
};

//请求出战宠物的具体属性
struct  GS2U_RequestOutFightPetPropetryResult<-
{
	int64	pet_id;

	int	attack;
	int	defence;
	int	hit;
	int	dodge;
	int	block;
	int	tough;
	int	crit;
	int	crit_damage_rate;
	int	attack_speed;
	int	pierce;
	int	ph_def;
	int	fire_def;
	int	ice_def;
	int	elec_def;
	int	poison_def;
	int	coma_def;
	int	hold_def;
	int	silent_def;
	int	move_def;
	int	max_life;
};


//玩家请求摇杆移动
struct	PlayerDirMove->
{
	int16	pos_x;
	int16	pos_y;
	int8		dir;
}

//玩家摇杆移动
struct	PlayerDirMove_S2C<-
{
	int64	player_id;
	int16	pos_x;
	int16	pos_y;
	int8		dir;
};

//报名协议
struct  U2GS_EnRollCampusBattle->
{
	int64 npcID;//交互的npc id
	int16 battleID;//报名的战场ID
};

struct GSWithU_GameSetMenu_3 <->
{
	int8 joinTeamOnoff;
	int8 inviteGuildOnoff;
	int8 tradeOnoff;
	int8 applicateFriendOnoff;
	int8 singleKeyOperateOnoff;
	int8 musicPercent;
	int8 soundEffectPercent;
	int8 shieldEnermyCampPlayer;
	int8 shieldSelfCampPlayer;
	int8 shieldOthersPet;
	int8 shieldOthersName;
	int8 shieldSkillEffect;
	int8 dispPlayerLimit;
	int8 shieldOthersSoundEff;
	int8 noAttackGuildMate;
	int8 reserve1;
	int8 reserve2;
};

//合成相关
struct StartCompound->
{
	int makeItemID;
	int8 compounBindedType;
	int8 isUseDoubleRule;
}

//返回码
struct StartCompoundResult<-
{
	int8 retCode;
};

struct CompoundBaseInfo<-
{
	int exp;
	int level;
	int makeItemID;
};

struct RequestEquipFastUpQuality ->
{
	int equipId;
};

struct	EquipQualityFastUPByTypeBack <-
{
	int result;
};

struct	PlayerTeleportMove->
{
	int16	pos_x;
	int16	pos_y;
};

struct	PlayerTeleportMove_S2C<-
{
	int64	player_id;
	int16	pos_x;
	int16	pos_y;
};


//请求离开报名
struct  U2GS_leaveCampusBattle->
{
	int8 unUsed;//没啥有效数据
};

//请求离开战场
struct  U2GS_LeaveBattleScene->
{
	int8 unUsed;//没啥有效数据
};

struct  battleResult
{
	string name;//名字
	int8 campus;//阵营
	int16 killPlayerNum;//击杀数
	int16 beenKiiledNum;//被击杀次数 
	int64 playerID;
	int harm;
	int harmed;
};

//战场结算，分数击杀信息
struct	BattleResultList<- 
{
	vector<battleResult>	resultList;
};

//报名的结果
struct	GS2U_BattleEnrollResult<- 
{
	int8 enrollResult;//报名结果
	int16 mapDataID;
};

//客户端告知服务器玩家要报名情况
struct U2GS_requestEnrollInfo->
{
	int8 unUsed;//没啥有效数据
};

//告知客户端报名人数
struct GS2U_sendEnrollInfo <- 
{
	int16 enrollxuanzong;//报名结果
	int16 enrolltianji;//报名结果
};

//告知客户端，玩家现在可以进入战场了
struct GS2U_NowCanEnterBattle <- 
{
	int16 battleID;
};

//玩家点确认进入战场
struct U2GS_SureEnterBattle->
{
	int8 unUsed;//没啥有效数据
};

//进入地图结果
struct GS2U_EnterBattleResult<-
{
	int8 faileReason;//进入失败原因
};

//战场分数
struct GS2U_BattleScore<-
{
	int16 xuanzongScore;
	int16 tianjiScore;
};

//请求战场分数击杀神马的
struct U2GS_RequestBattleResultList->
{
	int8 unUsed;//没啥有效数据
};


//战场结束
struct GS2U_BattleEnd<-
{
	int8 unUsed;//没啥有效数据
};

//战场剩余开启时间
struct GS2U_LeftOpenTime<-
{
	int leftOpenTime;
};

//心跳包返回，用于网络延迟
struct  GS2U_HeartBeatAck<-
{
};