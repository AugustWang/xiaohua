
-define(CMD_CharProperty,701).
-record(pk_CharProperty, {
	attack,
	defence,
	ph_def,
	fire_def,
	ice_def,
	elec_def,
	poison_def,
	max_life,
	life_recover,
	been_attack_recover,
	damage_recover,
	coma_def,
	hold_def,
	silent_def,
	move_def,
	hit,
	dodge,
	block,
	crit,
	pierce,
	attack_speed,
	tough,
	crit_damage_rate,
	block_dec_damage,
	phy_attack_rate,
	fire_attack_rate,
	ice_attack_rate,
	elec_attack_rate,
	poison_attack_rate,
	phy_def_rate,
	fire_def_rate,
	ice_def_rate,
	elec_def_rate,
	poison_def_rate,
	treat_rate,
	on_treat_rate,
	move_speed
	}).
-define(CMD_ObjectBuff,702).
-record(pk_ObjectBuff, {
	buff_id,
	allValidTime,
	remainTriggerCount
	}).
-define(CMD_PlayerBaseInfo,703).
-record(pk_PlayerBaseInfo, {
	id,
	name,
	x,
	y,
	sex,
	face,
	weapon,
	level,
	camp,
	faction,
	vip,
	maxEnabledBagCells,
	maxEnabledStorageBagCells,
	storageBagPassWord,
	unlockTimes,
	money,
	moneyBinded,
	gold,
	goldBinded,
	rechargeAmmount,
	ticket,
	guildContribute,
	honor,
	credit,
	exp,
	bloodPool,
	petBloodPool,
	life,
	lifeMax,
	guildID,
	mountDataID,
	pK_Kill_RemainTime,
	exp15Add,
	exp20Add,
	exp30Add,
	pk_Kill_Value,
	pkFlags,
	minEquipLevel,
	guild_name,
	guild_rank,
	goldPassWord
	}).
-define(CMD_rideInfo,704).
-record(pk_rideInfo, {
	mountDataID,
	rideFlage
	}).
-define(CMD_LookInfoPlayer,705).
-record(pk_LookInfoPlayer, {
	id,
	name,
	lifePercent,
	x,
	y,
	move_target_x,
	move_target_y,
	move_dir,
	move_speed,
	level,
	value_flags,
	charState,
	weapon,
	coat,
	buffList,
	convoyFlags,
	guild_id,
	guild_name,
	guild_rank,
	vip
	}).
-define(CMD_LookInfoPlayerList,706).
-record(pk_LookInfoPlayerList, {
	info_list
	}).
-define(CMD_LookInfoPet,707).
-record(pk_LookInfoPet, {
	id,
	masterId,
	data_id,
	name,
	titleid,
	modelId,
	lifePercent,
	level,
	x,
	y,
	move_target_x,
	move_target_y,
	move_speed,
	charState,
	buffList
	}).
-define(CMD_LookInfoPetList,708).
-record(pk_LookInfoPetList, {
	info_list
	}).
-define(CMD_LookInfoMonster,709).
-record(pk_LookInfoMonster, {
	id,
	move_target_x,
	move_target_y,
	move_speed,
	x,
	y,
	monster_data_id,
	lifePercent,
	faction,
	charState,
	buffList
	}).
-define(CMD_LookInfoMonsterList,710).
-record(pk_LookInfoMonsterList, {
	info_list
	}).
-define(CMD_LookInfoNpc,711).
-record(pk_LookInfoNpc, {
	id,
	x,
	y,
	npc_data_id,
	move_target_x,
	move_target_y
	}).
-define(CMD_LookInfoNpcList,712).
-record(pk_LookInfoNpcList, {
	info_list
	}).
-define(CMD_LookInfoObject,713).
-record(pk_LookInfoObject, {
	id,
	x,
	y,
	object_data_id,
	object_type,
	param
	}).
-define(CMD_LookInfoObjectList,714).
-record(pk_LookInfoObjectList, {
	info_list
	}).
-define(CMD_ActorDisapearList,715).
-record(pk_ActorDisapearList, {
	info_list
	}).
-define(CMD_PosInfo,716).
-record(pk_PosInfo, {
	x,
	y
	}).
-define(CMD_PlayerMoveTo,717).
-record(pk_PlayerMoveTo, {
	posX,
	posY,
	posInfos
	}).
-define(CMD_PlayerStopMove,718).
-record(pk_PlayerStopMove, {
	posX,
	posY
	}).
-define(CMD_PlayerStopMove_S2C,719).
-record(pk_PlayerStopMove_S2C, {
	id,
	posX,
	posY
	}).
-define(CMD_MoveInfo,720).
-record(pk_MoveInfo, {
	id,
	posX,
	posY,
	posInfos
	}).
-define(CMD_PlayerMoveInfo,721).
-record(pk_PlayerMoveInfo, {
	ids
	}).
-define(CMD_ChangeFlyState,722).
-record(pk_ChangeFlyState, {
	flyState
	}).
-define(CMD_ChangeFlyState_S2C,723).
-record(pk_ChangeFlyState_S2C, {
	id,
	flyState
	}).
-define(CMD_MonsterMoveInfo,724).
-record(pk_MonsterMoveInfo, {
	ids
	}).
-define(CMD_MonsterStopMove,725).
-record(pk_MonsterStopMove, {
	id,
	x,
	y
	}).
-define(CMD_PetMoveInfo,726).
-record(pk_PetMoveInfo, {
	ids
	}).
-define(CMD_PetStopMove,727).
-record(pk_PetStopMove, {
	id,
	x,
	y
	}).
-define(CMD_ChangeMap,728).
-record(pk_ChangeMap, {
	mapDataID,
	mapId,
	x,
	y
	}).
-define(CMD_CollectFail,729).
-record(pk_CollectFail, {
	}).
-define(CMD_RequestGM,730).
-record(pk_RequestGM, {
	strCMD
	}).
-define(CMD_PlayerPropertyChangeValue,731).
-record(pk_PlayerPropertyChangeValue, {
	proType,
	value
	}).
-define(CMD_PlayerPropertyChanged,732).
-record(pk_PlayerPropertyChanged, {
	changeValues
	}).
-define(CMD_PlayerMoneyChanged,733).
-record(pk_PlayerMoneyChanged, {
	changeReson,
	moneyType,
	moneyValue
	}).
-define(CMD_PlayerKickOuted,734).
-record(pk_PlayerKickOuted, {
	reserve
	}).
-define(CMD_ActorStateFlagSet,735).
-record(pk_ActorStateFlagSet, {
	nSetStateFlag
	}).
-define(CMD_ActorStateFlagSet_Broad,736).
-record(pk_ActorStateFlagSet_Broad, {
	nActorID,
	nSetStateFlag
	}).
-define(CMD_PlayerSkillInitData,737).
-record(pk_PlayerSkillInitData, {
	nSkillID,
	nCD,
	nActiveBranch1,
	nActiveBranch2,
	nBindedBranch
	}).
-define(CMD_PlayerSkillInitInfo,738).
-record(pk_PlayerSkillInitInfo, {
	info_list
	}).
-define(CMD_U2GS_StudySkill,739).
-record(pk_U2GS_StudySkill, {
	nSkillID
	}).
-define(CMD_GS2U_StudySkillResult,740).
-record(pk_GS2U_StudySkillResult, {
	nSkillID,
	nResult
	}).
-define(CMD_activeBranchID,741).
-record(pk_activeBranchID, {
	nWhichBranch,
	nSkillID,
	branchID
	}).
-define(CMD_activeBranchIDResult,742).
-record(pk_activeBranchIDResult, {
	result,
	nSkillID,
	branckID
	}).
-define(CMD_U2GS_AddSkillBranch,743).
-record(pk_U2GS_AddSkillBranch, {
	nSkillID,
	nBranchID
	}).
-define(CMD_GS2U_AddSkillBranchAck,744).
-record(pk_GS2U_AddSkillBranchAck, {
	result,
	nSkillID,
	nBranchID
	}).
-define(CMD_U2GS_UseSkillRequest,745).
-record(pk_U2GS_UseSkillRequest, {
	nSkillID,
	nTargetIDList,
	nCombatID
	}).
-define(CMD_GS2U_UseSkillToObject,746).
-record(pk_GS2U_UseSkillToObject, {
	nUserActorID,
	nSkillID,
	nTargetActorIDList,
	nCombatID
	}).
-define(CMD_GS2U_UseSkillToPos,747).
-record(pk_GS2U_UseSkillToPos, {
	nUserActorID,
	nSkillID,
	x,
	y,
	nCombatID,
	id_list
	}).
-define(CMD_GS2U_AttackDamage,748).
-record(pk_GS2U_AttackDamage, {
	nDamageTarget,
	nCombatID,
	nSkillID,
	nDamageLife,
	nTargetLifePer100,
	isBlocked,
	isCrited
	}).
-define(CMD_GS2U_CharactorDead,749).
-record(pk_GS2U_CharactorDead, {
	nDeadActorID,
	nKiller,
	nCombatNumber
	}).
-define(CMD_GS2U_AttackMiss,750).
-record(pk_GS2U_AttackMiss, {
	nActorID,
	nTargetID,
	nCombatID
	}).
-define(CMD_GS2U_AttackDodge,751).
-record(pk_GS2U_AttackDodge, {
	nActorID,
	nTargetID,
	nCombatID
	}).
-define(CMD_GS2U_AttackCrit,752).
-record(pk_GS2U_AttackCrit, {
	nActorID,
	nCombatID
	}).
-define(CMD_GS2U_AttackBlock,753).
-record(pk_GS2U_AttackBlock, {
	nActorID,
	nCombatID
	}).
-define(CMD_PlayerAllShortcut,754).
-record(pk_PlayerAllShortcut, {
	index1ID,
	index2ID,
	index3ID,
	index4ID,
	index5ID,
	index6ID,
	index7ID,
	index8ID,
	index9ID,
	index10ID,
	index11ID,
	index12ID
	}).
-define(CMD_ShortcutSet,755).
-record(pk_ShortcutSet, {
	index,
	data
	}).
-define(CMD_PlayerEXPChanged,756).
-record(pk_PlayerEXPChanged, {
	curEXP,
	changeReson
	}).
-define(CMD_ActorLifeUpdate,757).
-record(pk_ActorLifeUpdate, {
	nActorID,
	nLife,
	nMaxLife
	}).
-define(CMD_ActorMoveSpeedUpdate,758).
-record(pk_ActorMoveSpeedUpdate, {
	nActorID,
	nSpeed
	}).
-define(CMD_PlayerCombatIDInit,759).
-record(pk_PlayerCombatIDInit, {
	nBeginCombatID
	}).
-define(CMD_GS2U_CharactorRevived,760).
-record(pk_GS2U_CharactorRevived, {
	nActorID,
	nLife,
	nMaxLife
	}).
-define(CMD_U2GS_InteractObject,761).
-record(pk_U2GS_InteractObject, {
	nActorID
	}).
-define(CMD_U2GS_QueryHeroProperty,762).
-record(pk_U2GS_QueryHeroProperty, {
	nReserve
	}).
-define(CMD_CharPropertyData,763).
-record(pk_CharPropertyData, {
	nPropertyType,
	nValue
	}).
-define(CMD_GS2U_HeroPropertyResult,764).
-record(pk_GS2U_HeroPropertyResult, {
	info_list
	}).
-define(CMD_ItemInfo,765).
-record(pk_ItemInfo, {
	id,
	owner_type,
	owner_id,
	location,
	cell,
	amount,
	item_data_id,
	param1,
	param2,
	binded,
	remain_time
	}).
-define(CMD_PlayerBagInit,766).
-record(pk_PlayerBagInit, {
	items
	}).
-define(CMD_PlayerGetItem,767).
-record(pk_PlayerGetItem, {
	item_info
	}).
-define(CMD_PlayerDestroyItem,768).
-record(pk_PlayerDestroyItem, {
	itemDBID,
	reson
	}).
-define(CMD_PlayerItemLocationCellChanged,769).
-record(pk_PlayerItemLocationCellChanged, {
	itemDBID,
	location,
	cell
	}).
-define(CMD_RequestDestroyItem,770).
-record(pk_RequestDestroyItem, {
	itemDBID
	}).
-define(CMD_RequestGetItem,771).
-record(pk_RequestGetItem, {
	itemDataID,
	amount
	}).
-define(CMD_PlayerItemAmountChanged,772).
-record(pk_PlayerItemAmountChanged, {
	itemDBID,
	amount,
	reson
	}).
-define(CMD_PlayerItemParamChanged,773).
-record(pk_PlayerItemParamChanged, {
	itemDBID,
	param1,
	param2,
	reson
	}).
-define(CMD_PlayerBagOrderData,774).
-record(pk_PlayerBagOrderData, {
	itemDBID,
	amount,
	cell
	}).
-define(CMD_RequestPlayerBagOrder,775).
-record(pk_RequestPlayerBagOrder, {
	location
	}).
-define(CMD_PlayerBagOrderResult,776).
-record(pk_PlayerBagOrderResult, {
	location,
	cell
	}).
-define(CMD_PlayerRequestUseItem,777).
-record(pk_PlayerRequestUseItem, {
	location,
	cell,
	useCount
	}).
-define(CMD_PlayerUseItemResult,778).
-record(pk_PlayerUseItemResult, {
	location,
	cell,
	result
	}).
-define(CMD_RequestPlayerBagCellOpen,779).
-record(pk_RequestPlayerBagCellOpen, {
	cell,
	location
	}).
-define(CMD_RequestChangeStorageBagPassWord,780).
-record(pk_RequestChangeStorageBagPassWord, {
	oldStorageBagPassWord,
	newStorageBagPassWord,
	status
	}).
-define(CMD_PlayerStorageBagPassWordChanged,781).
-record(pk_PlayerStorageBagPassWordChanged, {
	result
	}).
-define(CMD_PlayerBagCellEnableChanged,782).
-record(pk_PlayerBagCellEnableChanged, {
	cell,
	location,
	gold,
	item_count
	}).
-define(CMD_RequestPlayerBagSellItem,783).
-record(pk_RequestPlayerBagSellItem, {
	cell
	}).
-define(CMD_RequestClearTempBag,784).
-record(pk_RequestClearTempBag, {
	reserve
	}).
-define(CMD_RequestMoveTempBagItem,785).
-record(pk_RequestMoveTempBagItem, {
	cell
	}).
-define(CMD_RequestMoveAllTempBagItem,786).
-record(pk_RequestMoveAllTempBagItem, {
	reserve
	}).
-define(CMD_RequestMoveStorageBagItem,787).
-record(pk_RequestMoveStorageBagItem, {
	cell
	}).
-define(CMD_RequestMoveBagItemToStorage,788).
-record(pk_RequestMoveBagItemToStorage, {
	cell
	}).
-define(CMD_RequestUnlockingStorageBagPassWord,789).
-record(pk_RequestUnlockingStorageBagPassWord, {
	passWordType
	}).
-define(CMD_RequestCancelUnlockingStorageBagPassWord,790).
-record(pk_RequestCancelUnlockingStorageBagPassWord, {
	passWordType
	}).
-define(CMD_PlayerUnlockTimesChanged,791).
-record(pk_PlayerUnlockTimesChanged, {
	unlockTimes
	}).
-define(CMD_ItemBagCellSetData,792).
-record(pk_ItemBagCellSetData, {
	location,
	cell,
	itemDBID
	}).
-define(CMD_ItemBagCellSet,793).
-record(pk_ItemBagCellSet, {
	cells
	}).
-define(CMD_NpcStoreItemData,794).
-record(pk_NpcStoreItemData, {
	id,
	item_id,
	price,
	isbind
	}).
-define(CMD_RequestGetNpcStoreItemList,795).
-record(pk_RequestGetNpcStoreItemList, {
	store_id
	}).
-define(CMD_GetNpcStoreItemListAck,796).
-record(pk_GetNpcStoreItemListAck, {
	store_id,
	itemList
	}).
-define(CMD_RequestBuyItem,797).
-record(pk_RequestBuyItem, {
	item_id,
	amount,
	store_id
	}).
-define(CMD_BuyItemAck,798).
-record(pk_BuyItemAck, {
	count
	}).
-define(CMD_RequestSellItem,799).
-record(pk_RequestSellItem, {
	item_cell
	}).
-define(CMD_GetNpcStoreBackBuyItemList,800).
-record(pk_GetNpcStoreBackBuyItemList, {
	count
	}).
-define(CMD_GetNpcStoreBackBuyItemListAck,801).
-record(pk_GetNpcStoreBackBuyItemListAck, {
	itemList
	}).
-define(CMD_RequestBackBuyItem,802).
-record(pk_RequestBackBuyItem, {
	item_id
	}).
-define(CMD_PlayerEquipNetData,803).
-record(pk_PlayerEquipNetData, {
	dbID,
	nEquip,
	type,
	nQuality,
	isEquiped,
	enhanceLevel,
	property1Type,
	property1FixOrPercent,
	property1Value,
	property2Type,
	property2FixOrPercent,
	property2Value,
	property3Type,
	property3FixOrPercent,
	property3Value,
	property4Type,
	property4FixOrPercent,
	property4Value,
	property5Type,
	property5FixOrPercent,
	property5Value
	}).
-define(CMD_PlayerEquipInit,804).
-record(pk_PlayerEquipInit, {
	equips
	}).
-define(CMD_RequestPlayerEquipActive,805).
-record(pk_RequestPlayerEquipActive, {
	equip_data_id
	}).
-define(CMD_PlayerEquipActiveResult,806).
-record(pk_PlayerEquipActiveResult, {
	equip
	}).
-define(CMD_RequestPlayerEquipPutOn,807).
-record(pk_RequestPlayerEquipPutOn, {
	equip_dbID
	}).
-define(CMD_PlayerEquipPutOnResult,808).
-record(pk_PlayerEquipPutOnResult, {
	equip_dbID,
	equiped
	}).
-define(CMD_RequestQueryPlayerEquip,809).
-record(pk_RequestQueryPlayerEquip, {
	playerid
	}).
-define(CMD_QueryPlayerEquipResult,810).
-record(pk_QueryPlayerEquipResult, {
	equips
	}).
-define(CMD_StudySkill,811).
-record(pk_StudySkill, {
	id,
	lvl
	}).
-define(CMD_StudyResult,812).
-record(pk_StudyResult, {
	result,
	id,
	lvl
	}).
-define(CMD_Reborn,813).
-record(pk_Reborn, {
	type
	}).
-define(CMD_RebornAck,814).
-record(pk_RebornAck, {
	x,
	y
	}).
-define(CMD_Chat2Player,815).
-record(pk_Chat2Player, {
	channel,
	sendID,
	receiveID,
	sendName,
	receiveName,
	content,
	vipLevel
	}).
-define(CMD_Chat2Server,816).
-record(pk_Chat2Server, {
	channel,
	sendID,
	receiveID,
	sendName,
	receiveName,
	content
	}).
-define(CMD_Chat_Error_Result,817).
-record(pk_Chat_Error_Result, {
	reason
	}).
-define(CMD_RequestSendMail,818).
-record(pk_RequestSendMail, {
	targetPlayerID,
	targetPlayerName,
	strTitle,
	strContent,
	attachItemDBID1,
	attachItem1Cnt,
	attachItemDBID2,
	attachItem2Cnt,
	moneySend,
	moneyPay
	}).
-define(CMD_RequestSendMailAck,819).
-record(pk_RequestSendMailAck, {
	result
	}).
-define(CMD_RequestRecvMail,820).
-record(pk_RequestRecvMail, {
	mailID,
	deleteMail
	}).
-define(CMD_RequestUnReadMail,821).
-record(pk_RequestUnReadMail, {
	playerID
	}).
-define(CMD_RequestUnReadMailAck,822).
-record(pk_RequestUnReadMailAck, {
	unReadCount
	}).
-define(CMD_RequestMailList,823).
-record(pk_RequestMailList, {
	playerID
	}).
-define(CMD_MailInfo,824).
-record(pk_MailInfo, {
	id,
	type,
	recvPlayerID,
	isOpen,
	timeOut,
	senderType,
	senderName,
	title,
	content,
	haveItem,
	moneySend,
	moneyPay,
	mailTimerType,
	mailRecTime
	}).
-define(CMD_RequestMailListAck,825).
-record(pk_RequestMailListAck, {
	mailList
	}).
-define(CMD_RequestMailItemInfo,826).
-record(pk_RequestMailItemInfo, {
	mailID
	}).
-define(CMD_RequestMailItemInfoAck,827).
-record(pk_RequestMailItemInfoAck, {
	mailID,
	mailItem
	}).
-define(CMD_RequestAcceptMailItem,828).
-record(pk_RequestAcceptMailItem, {
	mailID,
	isDeleteMail
	}).
-define(CMD_RequestAcceptMailItemAck,829).
-record(pk_RequestAcceptMailItemAck, {
	result
	}).
-define(CMD_MailReadNotice,830).
-record(pk_MailReadNotice, {
	mailID
	}).
-define(CMD_RequestDeleteMail,831).
-record(pk_RequestDeleteMail, {
	mailID
	}).
-define(CMD_InformNewMail,832).
-record(pk_InformNewMail, {
	}).
-define(CMD_RequestDeleteReadMail,833).
-record(pk_RequestDeleteReadMail, {
	readMailID
	}).
-define(CMD_RequestSystemMail,834).
-record(pk_RequestSystemMail, {
	}).
-define(CMD_U2GS_RequestLogin,835).
-record(pk_U2GS_RequestLogin, {
	userID,
	identity,
	protocolVer
	}).
-define(CMD_U2GS_SelPlayerEnterGame,836).
-record(pk_U2GS_SelPlayerEnterGame, {
	playerID
	}).
-define(CMD_U2GS_RequestCreatePlayer,837).
-record(pk_U2GS_RequestCreatePlayer, {
	name,
	camp,
	classValue,
	sex
	}).
-define(CMD_U2GS_RequestDeletePlayer,838).
-record(pk_U2GS_RequestDeletePlayer, {
	playerID
	}).
-define(CMD_GS2U_LoginResult,839).
-record(pk_GS2U_LoginResult, {
	result
	}).
-define(CMD_GS2U_SelPlayerResult,840).
-record(pk_GS2U_SelPlayerResult, {
	result
	}).
-define(CMD_UserPlayerData,841).
-record(pk_UserPlayerData, {
	playerID,
	name,
	level,
	classValue,
	sex,
	faction
	}).
-define(CMD_GS2U_UserPlayerList,842).
-record(pk_GS2U_UserPlayerList, {
	info
	}).
-define(CMD_GS2U_CreatePlayerResult,843).
-record(pk_GS2U_CreatePlayerResult, {
	errorCode
	}).
-define(CMD_GS2U_DeletePlayerResult,844).
-record(pk_GS2U_DeletePlayerResult, {
	playerID,
	errorCode
	}).
-define(CMD_ConSales_GroundingItem,845).
-record(pk_ConSales_GroundingItem, {
	dbId,
	count,
	money,
	timeType
	}).
-define(CMD_ConSales_GroundingItem_Result,846).
-record(pk_ConSales_GroundingItem_Result, {
	result
	}).
-define(CMD_ConSales_TakeDown,847).
-record(pk_ConSales_TakeDown, {
	conSalesId
	}).
-define(CMD_ConSales_TakeDown_Result,848).
-record(pk_ConSales_TakeDown_Result, {
	allTakeDown,
	result
	}).
-define(CMD_ConSales_BuyItem,849).
-record(pk_ConSales_BuyItem, {
	conSalesOderId
	}).
-define(CMD_ConSales_BuyItem_Result,850).
-record(pk_ConSales_BuyItem_Result, {
	result
	}).
-define(CMD_ConSales_FindItems,851).
-record(pk_ConSales_FindItems, {
	offsetCount,
	ignoreOption,
	type,
	detType,
	levelMin,
	levelMax,
	occ,
	quality,
	idLimit,
	idList
	}).
-define(CMD_ConSalesItem,852).
-record(pk_ConSalesItem, {
	conSalesId,
	conSalesMoney,
	groundingTime,
	timeType,
	playerId,
	playerName,
	itemDBId,
	itemId,
	itemCount,
	itemType,
	itemQuality,
	itemLevel,
	itemOcc
	}).
-define(CMD_ConSales_FindItems_Result,853).
-record(pk_ConSales_FindItems_Result, {
	result,
	allCount,
	page,
	itemList
	}).
-define(CMD_ConSales_TrunPage,854).
-record(pk_ConSales_TrunPage, {
	mode
	}).
-define(CMD_ConSales_Close,855).
-record(pk_ConSales_Close, {
	n
	}).
-define(CMD_ConSales_GetSelfSell,856).
-record(pk_ConSales_GetSelfSell, {
	n
	}).
-define(CMD_ConSales_GetSelfSell_Result,857).
-record(pk_ConSales_GetSelfSell_Result, {
	itemList
	}).
-define(CMD_TradeAsk,858).
-record(pk_TradeAsk, {
	playerID,
	playerName
	}).
-define(CMD_TradeAskResult,859).
-record(pk_TradeAskResult, {
	playerID,
	playerName,
	result
	}).
-define(CMD_CreateTrade,860).
-record(pk_CreateTrade, {
	playerID,
	playerName,
	result
	}).
-define(CMD_TradeInputItem_C2S,861).
-record(pk_TradeInputItem_C2S, {
	cell,
	itemDBID,
	count
	}).
-define(CMD_TradeInputItemResult_S2C,862).
-record(pk_TradeInputItemResult_S2C, {
	itemDBID,
	item_data_id,
	count,
	cell,
	result
	}).
-define(CMD_TradeInputItem_S2C,863).
-record(pk_TradeInputItem_S2C, {
	itemDBID,
	item_data_id,
	count
	}).
-define(CMD_TradeTakeOutItem_C2S,864).
-record(pk_TradeTakeOutItem_C2S, {
	itemDBID
	}).
-define(CMD_TradeTakeOutItemResult_S2C,865).
-record(pk_TradeTakeOutItemResult_S2C, {
	cell,
	itemDBID,
	result
	}).
-define(CMD_TradeTakeOutItem_S2C,866).
-record(pk_TradeTakeOutItem_S2C, {
	itemDBID
	}).
-define(CMD_TradeChangeMoney_C2S,867).
-record(pk_TradeChangeMoney_C2S, {
	money
	}).
-define(CMD_TradeChangeMoneyResult_S2C,868).
-record(pk_TradeChangeMoneyResult_S2C, {
	money,
	result
	}).
-define(CMD_TradeChangeMoney_S2C,869).
-record(pk_TradeChangeMoney_S2C, {
	money
	}).
-define(CMD_TradeLock_C2S,870).
-record(pk_TradeLock_C2S, {
	lock
	}).
-define(CMD_TradeLock_S2C,871).
-record(pk_TradeLock_S2C, {
	person,
	lock
	}).
-define(CMD_CancelTrade_S2C,872).
-record(pk_CancelTrade_S2C, {
	person,
	reason
	}).
-define(CMD_CancelTrade_C2S,873).
-record(pk_CancelTrade_C2S, {
	reason
	}).
-define(CMD_TradeAffirm_C2S,874).
-record(pk_TradeAffirm_C2S, {
	bAffrim
	}).
-define(CMD_TradeAffirm_S2C,875).
-record(pk_TradeAffirm_S2C, {
	person,
	bAffirm
	}).
-define(CMD_PetSkill,876).
-record(pk_PetSkill, {
	id,
	coolDownTime
	}).
-define(CMD_PetProperty,877).
-record(pk_PetProperty, {
	db_id,
	data_id,
	master_id,
	level,
	exp,
	name,
	titleId,
	aiState,
	showModel,
	exModelId,
	soulLevel,
	soulRate,
	attackGrowUp,
	defGrowUp,
	lifeGrowUp,
	isWashGrow,
	attackGrowUpWash,
	defGrowUpWash,
	lifeGrowUpWash,
	convertRatio,
	exerciseLevel,
	moneyExrciseNum,
	exerciseExp,
	maxSkillNum,
	skills,
	life,
	maxLife,
	attack,
	def,
	crit,
	block,
	hit,
	dodge,
	tough,
	pierce,
	crit_damage_rate,
	attack_speed,
	ph_def,
	fire_def,
	ice_def,
	elec_def,
	poison_def,
	coma_def,
	hold_def,
	silent_def,
	move_def,
	atkPowerGrowUp_Max,
	defClassGrowUp_Max,
	hpGrowUp_Max,
	benison_Value
	}).
-define(CMD_PlayerPetInfo,878).
-record(pk_PlayerPetInfo, {
	petSkillBag,
	petInfos
	}).
-define(CMD_UpdatePetProerty,879).
-record(pk_UpdatePetProerty, {
	petInfo
	}).
-define(CMD_DelPet,880).
-record(pk_DelPet, {
	petId
	}).
-define(CMD_PetOutFight,881).
-record(pk_PetOutFight, {
	petId
	}).
-define(CMD_PetOutFight_Result,882).
-record(pk_PetOutFight_Result, {
	result,
	petId
	}).
-define(CMD_PetTakeRest,883).
-record(pk_PetTakeRest, {
	petId
	}).
-define(CMD_PetTakeRest_Result,884).
-record(pk_PetTakeRest_Result, {
	result,
	petId
	}).
-define(CMD_PetFreeCaptiveAnimals,885).
-record(pk_PetFreeCaptiveAnimals, {
	petId
	}).
-define(CMD_PetFreeCaptiveAnimals_Result,886).
-record(pk_PetFreeCaptiveAnimals_Result, {
	result,
	petId
	}).
-define(CMD_PetCompoundModel,887).
-record(pk_PetCompoundModel, {
	petId
	}).
-define(CMD_PetCompoundModel_Result,888).
-record(pk_PetCompoundModel_Result, {
	result,
	petId
	}).
-define(CMD_PetWashGrowUpValue,889).
-record(pk_PetWashGrowUpValue, {
	petId
	}).
-define(CMD_PetWashGrowUpValue_Result,890).
-record(pk_PetWashGrowUpValue_Result, {
	result,
	petId,
	attackGrowUp,
	defGrowUp,
	lifeGrowUp
	}).
-define(CMD_PetReplaceGrowUpValue,891).
-record(pk_PetReplaceGrowUpValue, {
	petId
	}).
-define(CMD_PetReplaceGrowUpValue_Result,892).
-record(pk_PetReplaceGrowUpValue_Result, {
	result,
	petId
	}).
-define(CMD_PetIntensifySoul,893).
-record(pk_PetIntensifySoul, {
	petId
	}).
-define(CMD_PetIntensifySoul_Result,894).
-record(pk_PetIntensifySoul_Result, {
	result,
	petId,
	soulLevel,
	soulRate,
	benison_Value
	}).
-define(CMD_PetOneKeyIntensifySoul,895).
-record(pk_PetOneKeyIntensifySoul, {
	petId
	}).
-define(CMD_PetOneKeyIntensifySoul_Result,896).
-record(pk_PetOneKeyIntensifySoul_Result, {
	petId,
	result,
	itemCount,
	money
	}).
-define(CMD_PetFuse,897).
-record(pk_PetFuse, {
	petSrcId,
	petDestId
	}).
-define(CMD_PetFuse_Result,898).
-record(pk_PetFuse_Result, {
	result,
	petSrcId,
	petDestId
	}).
-define(CMD_PetJumpTo,899).
-record(pk_PetJumpTo, {
	petId,
	x,
	y
	}).
-define(CMD_ActorSetPos,900).
-record(pk_ActorSetPos, {
	actorId,
	x,
	y
	}).
-define(CMD_PetTakeBack,901).
-record(pk_PetTakeBack, {
	petId
	}).
-define(CMD_ChangePetAIState,902).
-record(pk_ChangePetAIState, {
	state
	}).
-define(CMD_PetExpChanged,903).
-record(pk_PetExpChanged, {
	petId,
	curExp,
	reason
	}).
-define(CMD_PetLearnSkill,904).
-record(pk_PetLearnSkill, {
	petId,
	skillId
	}).
-define(CMD_PetLearnSkill_Result,905).
-record(pk_PetLearnSkill_Result, {
	result,
	petId,
	oldSkillId,
	newSkillId
	}).
-define(CMD_PetDelSkill,906).
-record(pk_PetDelSkill, {
	petId,
	skillId
	}).
-define(CMD_PetDelSkill_Result,907).
-record(pk_PetDelSkill_Result, {
	result,
	petId,
	skillid
	}).
-define(CMD_PetUnLockSkillCell,908).
-record(pk_PetUnLockSkillCell, {
	petId
	}).
-define(CMD_PetUnLoctSkillCell_Result,909).
-record(pk_PetUnLoctSkillCell_Result, {
	result,
	petId,
	newSkillCellNum
	}).
-define(CMD_PetSkillSealAhs,910).
-record(pk_PetSkillSealAhs, {
	petId,
	skillid
	}).
-define(CMD_PetSkillSealAhs_Result,911).
-record(pk_PetSkillSealAhs_Result, {
	result,
	petId,
	skillid
	}).
-define(CMD_PetUpdateSealAhsStore,912).
-record(pk_PetUpdateSealAhsStore, {
	petSkillBag
	}).
-define(CMD_PetlearnSealAhsSkill,913).
-record(pk_PetlearnSealAhsSkill, {
	petId,
	skillId
	}).
-define(CMD_PetlearnSealAhsSkill_Result,914).
-record(pk_PetlearnSealAhsSkill_Result, {
	result,
	petId,
	oldSkillId,
	newSkillId
	}).
-define(CMD_RequestGetPlayerEquipEnhanceByType,915).
-record(pk_RequestGetPlayerEquipEnhanceByType, {
	type
	}).
-define(CMD_GetPlayerEquipEnhanceByTypeBack,916).
-record(pk_GetPlayerEquipEnhanceByTypeBack, {
	type,
	level,
	progress,
	blessValue
	}).
-define(CMD_RequestEquipEnhanceByType,917).
-record(pk_RequestEquipEnhanceByType, {
	type
	}).
-define(CMD_EquipEnhanceByTypeBack,918).
-record(pk_EquipEnhanceByTypeBack, {
	result
	}).
-define(CMD_RequestEquipOnceEnhanceByType,919).
-record(pk_RequestEquipOnceEnhanceByType, {
	type
	}).
-define(CMD_EquipOnceEnhanceByTypeBack,920).
-record(pk_EquipOnceEnhanceByTypeBack, {
	result,
	times,
	itemnumber,
	money
	}).
-define(CMD_RequestGetPlayerEquipQualityByType,921).
-record(pk_RequestGetPlayerEquipQualityByType, {
	type
	}).
-define(CMD_GetPlayerEquipQualityByTypeBack,922).
-record(pk_GetPlayerEquipQualityByTypeBack, {
	type,
	quality
	}).
-define(CMD_RequestEquipQualityUPByType,923).
-record(pk_RequestEquipQualityUPByType, {
	type
	}).
-define(CMD_EquipQualityUPByTypeBack,924).
-record(pk_EquipQualityUPByTypeBack, {
	result
	}).
-define(CMD_RequestEquipOldPropertyByType,925).
-record(pk_RequestEquipOldPropertyByType, {
	type
	}).
-define(CMD_GetEquipOldPropertyByType,926).
-record(pk_GetEquipOldPropertyByType, {
	type,
	property1Type,
	property1FixOrPercent,
	property1Value,
	property2Type,
	property2FixOrPercent,
	property2Value,
	property3Type,
	property3FixOrPercent,
	property3Value,
	property4Type,
	property4FixOrPercent,
	property4Value,
	property5Type,
	property5FixOrPercent,
	property5Value
	}).
-define(CMD_RequestEquipChangePropertyByType,927).
-record(pk_RequestEquipChangePropertyByType, {
	type,
	property1,
	property2,
	property3,
	property4,
	property5
	}).
-define(CMD_GetEquipNewPropertyByType,928).
-record(pk_GetEquipNewPropertyByType, {
	type,
	property1Type,
	property1FixOrPercent,
	property1Value,
	property2Type,
	property2FixOrPercent,
	property2Value,
	property3Type,
	property3FixOrPercent,
	property3Value,
	property4Type,
	property4FixOrPercent,
	property4Value,
	property5Type,
	property5FixOrPercent,
	property5Value
	}).
-define(CMD_RequestEquipSaveNewPropertyByType,929).
-record(pk_RequestEquipSaveNewPropertyByType, {
	type
	}).
-define(CMD_RequestEquipChangeAddSavePropertyByType,930).
-record(pk_RequestEquipChangeAddSavePropertyByType, {
	result
	}).
-define(CMD_U2GS_EnterCopyMapRequest,931).
-record(pk_U2GS_EnterCopyMapRequest, {
	npcActorID,
	enterMapID
	}).
-define(CMD_GS2U_EnterMapResult,932).
-record(pk_GS2U_EnterMapResult, {
	result
	}).
-define(CMD_U2GS_QueryMyCopyMapCD,933).
-record(pk_U2GS_QueryMyCopyMapCD, {
	reserve
	}).
-define(CMD_MyCopyMapCDInfo,934).
-record(pk_MyCopyMapCDInfo, {
	mapDataID,
	mapEnteredCount,
	mapActiveCount
	}).
-define(CMD_GS2U_MyCopyMapCDInfo,935).
-record(pk_GS2U_MyCopyMapCDInfo, {
	info_list
	}).
-define(CMD_AddBuff,936).
-record(pk_AddBuff, {
	actor_id,
	buff_data_id,
	allValidTime,
	remainTriggerCount
	}).
-define(CMD_DelBuff,937).
-record(pk_DelBuff, {
	actor_id,
	buff_data_id
	}).
-define(CMD_UpdateBuff,938).
-record(pk_UpdateBuff, {
	actor_id,
	buff_data_id,
	remainTriggerCount
	}).
-define(CMD_HeroBuffList,939).
-record(pk_HeroBuffList, {
	buffList
	}).
-define(CMD_U2GS_TransByWorldMap,940).
-record(pk_U2GS_TransByWorldMap, {
	mapDataID,
	posX,
	posY
	}).
-define(CMD_U2GS_TransForSameScence,941).
-record(pk_U2GS_TransForSameScence, {
	mapDataID,
	posX,
	posY
	}).
-define(CMD_U2GS_FastTeamCopyMapRequest,942).
-record(pk_U2GS_FastTeamCopyMapRequest, {
	npcActorID,
	mapDataID,
	enterOrQuit
	}).
-define(CMD_GS2U_FastTeamCopyMapResult,943).
-record(pk_GS2U_FastTeamCopyMapResult, {
	mapDataID,
	result,
	enterOrQuit
	}).
-define(CMD_GS2U_TeamCopyMapQuery,944).
-record(pk_GS2U_TeamCopyMapQuery, {
	nReadyEnterMapDataID,
	nCurMapID,
	nPosX,
	nPosY,
	nDistanceSQ
	}).
-define(CMD_U2GS_RestCopyMapRequest,945).
-record(pk_U2GS_RestCopyMapRequest, {
	nNpcID,
	nMapDataID
	}).
-define(CMD_GS2U_AddOrRemoveHatred,946).
-record(pk_GS2U_AddOrRemoveHatred, {
	nActorID,
	nAddOrRemove
	}).
-define(CMD_U2GS_QieCuoInvite,947).
-record(pk_U2GS_QieCuoInvite, {
	nActorID
	}).
-define(CMD_GS2U_QieCuoInviteQuery,948).
-record(pk_GS2U_QieCuoInviteQuery, {
	nActorID,
	strName
	}).
-define(CMD_U2GS_QieCuoInviteAck,949).
-record(pk_U2GS_QieCuoInviteAck, {
	nActorID,
	agree
	}).
-define(CMD_GS2U_QieCuoInviteResult,950).
-record(pk_GS2U_QieCuoInviteResult, {
	nActorID,
	result
	}).
-define(CMD_GS2U_QieCuoResult,951).
-record(pk_GS2U_QieCuoResult, {
	nWinner_ActorID,
	strWinner_Name,
	nLoser_ActorID,
	strLoser_Name,
	reson
	}).
-define(CMD_U2GS_PK_KillOpenRequest,952).
-record(pk_U2GS_PK_KillOpenRequest, {
	reserve
	}).
-define(CMD_GS2U_PK_KillOpenResult,953).
-record(pk_GS2U_PK_KillOpenResult, {
	result,
	pK_Kill_RemainTime,
	pk_Kill_Value
	}).
-define(CMD_GS2U_Player_ChangeEquipResult,954).
-record(pk_GS2U_Player_ChangeEquipResult, {
	playerID,
	equipID
	}).
-define(CMD_SysMessage,955).
-record(pk_SysMessage, {
	type,
	text
	}).
-define(CMD_GS2U_AddLifeByItem,956).
-record(pk_GS2U_AddLifeByItem, {
	actorID,
	addLife,
	percent
	}).
-define(CMD_GS2U_AddLifeBySkill,957).
-record(pk_GS2U_AddLifeBySkill, {
	actorID,
	addLife,
	percent,
	crite
	}).
-define(CMD_PlayerItemCDInfo,958).
-record(pk_PlayerItemCDInfo, {
	cdTypeID,
	remainTime,
	allTime
	}).
-define(CMD_GS2U_PlayerItemCDInit,959).
-record(pk_GS2U_PlayerItemCDInit, {
	info_list
	}).
-define(CMD_GS2U_PlayerItemCDUpdate,960).
-record(pk_GS2U_PlayerItemCDUpdate, {
	info
	}).
-define(CMD_U2GS_BloodPoolAddLife,961).
-record(pk_U2GS_BloodPoolAddLife, {
	actorID
	}).
-define(CMD_GS2U_ItemDailyCount,962).
-record(pk_GS2U_ItemDailyCount, {
	remainCount,
	task_data_id
	}).
-define(CMD_U2GS_GetSigninInfo,963).
-record(pk_U2GS_GetSigninInfo, {
	}).
-define(CMD_GS2U_PlayerSigninInfo,964).
-record(pk_GS2U_PlayerSigninInfo, {
	isAlreadySign,
	days
	}).
-define(CMD_U2GS_Signin,965).
-record(pk_U2GS_Signin, {
	}).
-define(CMD_GS2U_PlayerSignInResult,966).
-record(pk_GS2U_PlayerSignInResult, {
	nResult,
	awardDays
	}).
-define(CMD_U2GS_LeaveCopyMap,967).
-record(pk_U2GS_LeaveCopyMap, {
	reserve
	}).
-define(CMD_PetChangeModel,968).
-record(pk_PetChangeModel, {
	petId,
	modelID
	}).
-define(CMD_PetChangeName,969).
-record(pk_PetChangeName, {
	petId,
	newName
	}).
-define(CMD_PetChangeName_Result,970).
-record(pk_PetChangeName_Result, {
	result,
	petId,
	newName
	}).
-define(CMD_BazzarItem,971).
-record(pk_BazzarItem, {
	db_id,
	item_id,
	item_column,
	gold,
	binded_gold,
	remain_count,
	remain_time
	}).
-define(CMD_BazzarListRequest,972).
-record(pk_BazzarListRequest, {
	seed
	}).
-define(CMD_BazzarPriceItemList,973).
-record(pk_BazzarPriceItemList, {
	itemList
	}).
-define(CMD_BazzarItemList,974).
-record(pk_BazzarItemList, {
	seed,
	itemList
	}).
-define(CMD_BazzarItemUpdate,975).
-record(pk_BazzarItemUpdate, {
	item
	}).
-define(CMD_BazzarBuyRequest,976).
-record(pk_BazzarBuyRequest, {
	db_id,
	isBindGold,
	count
	}).
-define(CMD_BazzarBuyResult,977).
-record(pk_BazzarBuyResult, {
	result
	}).
-define(CMD_PlayerBagCellOpenResult,978).
-record(pk_PlayerBagCellOpenResult, {
	result
	}).
-define(CMD_U2GS_RemoveSkillBranch,979).
-record(pk_U2GS_RemoveSkillBranch, {
	nSkillID
	}).
-define(CMD_GS2U_RemoveSkillBranch,980).
-record(pk_GS2U_RemoveSkillBranch, {
	result,
	nSkillID
	}).
-define(CMD_U2GS_PetBloodPoolAddLife,981).
-record(pk_U2GS_PetBloodPoolAddLife, {
	n
	}).
-define(CMD_U2GS_CopyMapAddActiveCount,982).
-record(pk_U2GS_CopyMapAddActiveCount, {
	map_data_id
	}).
-define(CMD_U2GS_CopyMapAddActiveCountResult,983).
-record(pk_U2GS_CopyMapAddActiveCountResult, {
	result
	}).
-define(CMD_GS2U_CurConvoyInfo,984).
-record(pk_GS2U_CurConvoyInfo, {
	isDead,
	convoyType,
	carriageQuality,
	remainTime,
	lowCD,
	highCD,
	freeCnt
	}).
-define(CMD_U2GS_CarriageQualityRefresh,985).
-record(pk_U2GS_CarriageQualityRefresh, {
	isRefreshLegend,
	isCostGold,
	curConvoyType,
	curCarriageQuality,
	curTaskID
	}).
-define(CMD_GS2U_CarriageQualityRefreshResult,986).
-record(pk_GS2U_CarriageQualityRefreshResult, {
	retCode,
	newConvoyType,
	newCarriageQuality,
	freeCnt
	}).
-define(CMD_U2GS_ConvoyCDRequst,987).
-record(pk_U2GS_ConvoyCDRequst, {
	}).
-define(CMD_GS2U_ConvoyCDResult,988).
-record(pk_GS2U_ConvoyCDResult, {
	retCode
	}).
-define(CMD_U2GS_BeginConvoy,989).
-record(pk_U2GS_BeginConvoy, {
	nTaskID,
	curConvoyType,
	curCarriageQuality,
	nNpcActorID
	}).
-define(CMD_GS2U_BeginConvoyResult,990).
-record(pk_GS2U_BeginConvoyResult, {
	retCode,
	curConvoyType,
	curCarriageQuality,
	remainTime,
	lowCD,
	highCD
	}).
-define(CMD_GS2U_FinishConvoyResult,991).
-record(pk_GS2U_FinishConvoyResult, {
	curConvoyType,
	curCarriageQuality
	}).
-define(CMD_GS2U_GiveUpConvoyResult,992).
-record(pk_GS2U_GiveUpConvoyResult, {
	curConvoyType,
	curCarriageQuality
	}).
-define(CMD_GS2U_ConvoyNoticeTimerResult,993).
-record(pk_GS2U_ConvoyNoticeTimerResult, {
	isDead,
	remainTime
	}).
-define(CMD_GS2U_ConvoyState,994).
-record(pk_GS2U_ConvoyState, {
	convoyFlags,
	quality,
	actorID
	}).
-define(CMD_GSWithU_GameSetMenu,995).
-record(pk_GSWithU_GameSetMenu, {
	joinTeamOnoff,
	inviteGuildOnoff,
	tradeOnoff,
	applicateFriendOnoff,
	singleKeyOperateOnoff,
	musicPercent,
	soundEffectPercent,
	shieldEnermyCampPlayer,
	shieldSelfCampPlayer,
	shieldOthersPet,
	shieldOthersName,
	shieldSkillEffect,
	dispPlayerLimit
	}).
-define(CMD_U2GS_RequestRechargeGift,996).
-record(pk_U2GS_RequestRechargeGift, {
	type
	}).
-define(CMD_U2GS_RequestRechargeGift_Ret,997).
-record(pk_U2GS_RequestRechargeGift_Ret, {
	retcode
	}).
-define(CMD_U2GS_RequestPlayerFightingCapacity,998).
-record(pk_U2GS_RequestPlayerFightingCapacity, {
	}).
-define(CMD_U2GS_RequestPlayerFightingCapacity_Ret,999).
-record(pk_U2GS_RequestPlayerFightingCapacity_Ret, {
	fightingcapacity
	}).
-define(CMD_U2GS_RequestPetFightingCapacity,1000).
-record(pk_U2GS_RequestPetFightingCapacity, {
	petid
	}).
-define(CMD_U2GS_RequestPetFightingCapacity_Ret,1001).
-record(pk_U2GS_RequestPetFightingCapacity_Ret, {
	fightingcapacity
	}).
-define(CMD_U2GS_RequestMountFightingCapacity,1002).
-record(pk_U2GS_RequestMountFightingCapacity, {
	mountid
	}).
-define(CMD_U2GS_RequestMountFightingCapacity_Ret,1003).
-record(pk_U2GS_RequestMountFightingCapacity_Ret, {
	fightingcapacity
	}).
-define(CMD_VariantData,1004).
-record(pk_VariantData, {
	index,
	value
	}).
-define(CMD_GS2U_VariantDataSet,1005).
-record(pk_GS2U_VariantDataSet, {
	variant_type,
	info_list
	}).
-define(CMD_U2GS_GetRankList,1006).
-record(pk_U2GS_GetRankList, {
	mapDataID
	}).
-define(CMD_GS2U_RankList,1007).
-record(pk_GS2U_RankList, {
	mapID,
	rankNum,
	name1,
	harm1,
	name2,
	harm2,
	name3,
	harm3,
	name4,
	harm4,
	name5,
	harm5,
	name6,
	harm6,
	name7,
	harm7,
	name8,
	harm8,
	name9,
	harm9,
	name10,
	harm10
	}).
-define(CMD_GS2U_WordBossCmd,1008).
-record(pk_GS2U_WordBossCmd, {
	m_iCmd,
	m_iParam
	}).
-define(CMD_U2GS_ChangePlayerName,1009).
-record(pk_U2GS_ChangePlayerName, {
	id,
	name
	}).
-define(CMD_GS2U_ChangePlayerNameResult,1010).
-record(pk_GS2U_ChangePlayerNameResult, {
	retCode
	}).
-define(CMD_U2GS_SetProtectPwd,1011).
-record(pk_U2GS_SetProtectPwd, {
	id,
	oldpwd,
	pwd
	}).
-define(CMD_GS2U_SetProtectPwdResult,1012).
-record(pk_GS2U_SetProtectPwdResult, {
	retCode
	}).
-define(CMD_U2GS_HeartBeat,1013).
-record(pk_U2GS_HeartBeat, {
	}).
-define(CMD_GS2U_CopyProgressUpdate,1014).
-record(pk_GS2U_CopyProgressUpdate, {
	progress
	}).
-define(CMD_U2GS_QequestGiveGoldCheck,1015).
-record(pk_U2GS_QequestGiveGoldCheck, {
	}).
-define(CMD_U2GS_StartGiveGold,1016).
-record(pk_U2GS_StartGiveGold, {
	}).
-define(CMD_U2GS_StartGiveGoldResult,1017).
-record(pk_U2GS_StartGiveGoldResult, {
	goldType,
	useCnt,
	exp,
	level,
	awardMoney,
	retCode
	}).
-define(CMD_U2GS_GoldLineInfo,1018).
-record(pk_U2GS_GoldLineInfo, {
	useCnt,
	exp,
	level
	}).
-define(CMD_U2GS_GoldResetTimer,1019).
-record(pk_U2GS_GoldResetTimer, {
	useCnt
	}).
-define(CMD_GS2U_CopyMapSAData,1020).
-record(pk_GS2U_CopyMapSAData, {
	map_id,
	killed_count,
	finish_rate,
	cost_time,
	exp,
	money,
	level,
	is_perfect
	}).
-define(CMD_TokenStoreItemData,1021).
-record(pk_TokenStoreItemData, {
	id,
	item_id,
	price,
	tokenType,
	isbind
	}).
-define(CMD_GetTokenStoreItemListAck,1022).
-record(pk_GetTokenStoreItemListAck, {
	store_id,
	itemList
	}).
-define(CMD_RequestLookPlayer,1023).
-record(pk_RequestLookPlayer, {
	playerID
	}).
-define(CMD_RequestLookPlayer_Result,1024).
-record(pk_RequestLookPlayer_Result, {
	baseInfo,
	propertyList,
	petList,
	equipList,
	fightCapacity
	}).
-define(CMD_RequestLookPlayerFailed_Result,1025).
-record(pk_RequestLookPlayerFailed_Result, {
	result
	}).
-define(CMD_U2GS_PlayerClientInfo,1026).
-record(pk_U2GS_PlayerClientInfo, {
	playerid,
	platform,
	machine
	}).
-define(CMD_U2GS_RequestActiveCount,1027).
-record(pk_U2GS_RequestActiveCount, {
	n
	}).
-define(CMD_ActiveCountData,1028).
-record(pk_ActiveCountData, {
	daily_id,
	count
	}).
-define(CMD_GS2U_ActiveCount,1029).
-record(pk_GS2U_ActiveCount, {
	activeValue,
	dailyList
	}).
-define(CMD_U2GS_RequestConvertActive,1030).
-record(pk_U2GS_RequestConvertActive, {
	n
	}).
-define(CMD_GS2U_WhetherTransferOldRecharge,1031).
-record(pk_GS2U_WhetherTransferOldRecharge, {
	playerID,
	name,
	rechargeRmb
	}).
-define(CMD_U2GS_TransferOldRechargeToPlayer,1032).
-record(pk_U2GS_TransferOldRechargeToPlayer, {
	playerId,
	isTransfer
	}).
-define(CMD_GS2U_TransferOldRechargeResult,1033).
-record(pk_GS2U_TransferOldRechargeResult, {
	errorCode
	}).
-define(CMD_PlayerEquipActiveFailReason,1034).
-record(pk_PlayerEquipActiveFailReason, {
	reason
	}).
-define(CMD_PlayerEquipMinLevelChange,1035).
-record(pk_PlayerEquipMinLevelChange, {
	playerid,
	minEquipLevel
	}).
-define(CMD_PlayerImportPassWord,1036).
-record(pk_PlayerImportPassWord, {
	passWord,
	passWordType
	}).
-define(CMD_PlayerImportPassWordResult,1037).
-record(pk_PlayerImportPassWordResult, {
	result
	}).
-define(CMD_GS2U_UpdatePlayerGuildInfo,1038).
-record(pk_GS2U_UpdatePlayerGuildInfo, {
	player_id,
	guild_id,
	guild_name,
	guild_rank
	}).
-define(CMD_U2GS_RequestBazzarItemPrice,1039).
-record(pk_U2GS_RequestBazzarItemPrice, {
	item_id
	}).
-define(CMD_U2GS_RequestBazzarItemPrice_Result,1040).
-record(pk_U2GS_RequestBazzarItemPrice_Result, {
	item
	}).
-define(CMD_RequestChangeGoldPassWord,1041).
-record(pk_RequestChangeGoldPassWord, {
	oldGoldPassWord,
	newGoldPassWord,
	status
	}).
-define(CMD_PlayerGoldPassWordChanged,1042).
-record(pk_PlayerGoldPassWordChanged, {
	result
	}).
-define(CMD_PlayerImportGoldPassWordResult,1043).
-record(pk_PlayerImportGoldPassWordResult, {
	result
	}).
-define(CMD_PlayerGoldUnlockTimesChanged,1044).
-record(pk_PlayerGoldUnlockTimesChanged, {
	unlockTimes
	}).
-define(CMD_GS2U_LeftSmallMonsterNumber,1045).
-record(pk_GS2U_LeftSmallMonsterNumber, {
	leftMonsterNum
	}).
-define(CMD_GS2U_VipInfo,1046).
-record(pk_GS2U_VipInfo, {
	vipLevel,
	vipTime,
	vipTimeExpire,
	vipTimeBuy
	}).
-define(CMD_GS2U_TellMapLineID,1047).
-record(pk_GS2U_TellMapLineID, {
	iLineID
	}).
-define(CMD_VIPPlayerOpenVIPStoreRequest,1048).
-record(pk_VIPPlayerOpenVIPStoreRequest, {
	request
	}).
-define(CMD_VIPPlayerOpenVIPStoreFail,1049).
-record(pk_VIPPlayerOpenVIPStoreFail, {
	fail
	}).
-define(CMD_UpdateVIPLevelInfo,1050).
-record(pk_UpdateVIPLevelInfo, {
	playerID,
	vipLevel
	}).
-define(CMD_ActiveCodeRequest,1051).
-record(pk_ActiveCodeRequest, {
	active_code
	}).
-define(CMD_ActiveCodeResult,1052).
-record(pk_ActiveCodeResult, {
	result
	}).
-define(CMD_U2GS_RequestOutFightPetPropetry,1053).
-record(pk_U2GS_RequestOutFightPetPropetry, {
	n
	}).
-define(CMD_GS2U_RequestOutFightPetPropetryResult,1054).
-record(pk_GS2U_RequestOutFightPetPropetryResult, {
	pet_id,
	attack,
	defence,
	hit,
	dodge,
	block,
	tough,
	crit,
	crit_damage_rate,
	attack_speed,
	pierce,
	ph_def,
	fire_def,
	ice_def,
	elec_def,
	poison_def,
	coma_def,
	hold_def,
	silent_def,
	move_def,
	max_life
	}).
-define(CMD_PlayerDirMove,1055).
-record(pk_PlayerDirMove, {
	pos_x,
	pos_y,
	dir
	}).
-define(CMD_PlayerDirMove_S2C,1056).
-record(pk_PlayerDirMove_S2C, {
	player_id,
	pos_x,
	pos_y,
	dir
	}).
-define(CMD_U2GS_EnRollCampusBattle,1057).
-record(pk_U2GS_EnRollCampusBattle, {
	npcID,
	battleID
	}).
-define(CMD_GSWithU_GameSetMenu_3,1058).
-record(pk_GSWithU_GameSetMenu_3, {
	joinTeamOnoff,
	inviteGuildOnoff,
	tradeOnoff,
	applicateFriendOnoff,
	singleKeyOperateOnoff,
	musicPercent,
	soundEffectPercent,
	shieldEnermyCampPlayer,
	shieldSelfCampPlayer,
	shieldOthersPet,
	shieldOthersName,
	shieldSkillEffect,
	dispPlayerLimit,
	shieldOthersSoundEff,
	noAttackGuildMate,
	reserve1,
	reserve2
	}).
-define(CMD_StartCompound,1059).
-record(pk_StartCompound, {
	makeItemID,
	compounBindedType,
	isUseDoubleRule
	}).
-define(CMD_StartCompoundResult,1060).
-record(pk_StartCompoundResult, {
	retCode
	}).
-define(CMD_CompoundBaseInfo,1061).
-record(pk_CompoundBaseInfo, {
	exp,
	level,
	makeItemID
	}).
-define(CMD_RequestEquipFastUpQuality,1062).
-record(pk_RequestEquipFastUpQuality, {
	equipId
	}).
-define(CMD_EquipQualityFastUPByTypeBack,1063).
-record(pk_EquipQualityFastUPByTypeBack, {
	result
	}).
-define(CMD_PlayerTeleportMove,1064).
-record(pk_PlayerTeleportMove, {
	pos_x,
	pos_y
	}).
-define(CMD_PlayerTeleportMove_S2C,1065).
-record(pk_PlayerTeleportMove_S2C, {
	player_id,
	pos_x,
	pos_y
	}).
-define(CMD_U2GS_leaveCampusBattle,1066).
-record(pk_U2GS_leaveCampusBattle, {
	unUsed
	}).
-define(CMD_U2GS_LeaveBattleScene,1067).
-record(pk_U2GS_LeaveBattleScene, {
	unUsed
	}).
-define(CMD_battleResult,1068).
-record(pk_battleResult, {
	name,
	campus,
	killPlayerNum,
	beenKiiledNum,
	playerID,
	harm,
	harmed
	}).
-define(CMD_BattleResultList,1069).
-record(pk_BattleResultList, {
	resultList
	}).
-define(CMD_GS2U_BattleEnrollResult,1070).
-record(pk_GS2U_BattleEnrollResult, {
	enrollResult,
	mapDataID
	}).
-define(CMD_U2GS_requestEnrollInfo,1071).
-record(pk_U2GS_requestEnrollInfo, {
	unUsed
	}).
-define(CMD_GS2U_sendEnrollInfo,1072).
-record(pk_GS2U_sendEnrollInfo, {
	enrollxuanzong,
	enrolltianji
	}).
-define(CMD_GS2U_NowCanEnterBattle,1073).
-record(pk_GS2U_NowCanEnterBattle, {
	battleID
	}).
-define(CMD_U2GS_SureEnterBattle,1074).
-record(pk_U2GS_SureEnterBattle, {
	unUsed
	}).
-define(CMD_GS2U_EnterBattleResult,1075).
-record(pk_GS2U_EnterBattleResult, {
	faileReason
	}).
-define(CMD_GS2U_BattleScore,1076).
-record(pk_GS2U_BattleScore, {
	xuanzongScore,
	tianjiScore
	}).
-define(CMD_U2GS_RequestBattleResultList,1077).
-record(pk_U2GS_RequestBattleResultList, {
	unUsed
	}).
-define(CMD_GS2U_BattleEnd,1078).
-record(pk_GS2U_BattleEnd, {
	unUsed
	}).
-define(CMD_GS2U_LeftOpenTime,1079).
-record(pk_GS2U_LeftOpenTime, {
	leftOpenTime
	}).
-define(CMD_GS2U_HeartBeatAck,1080).
-record(pk_GS2U_HeartBeatAck, {
	}).