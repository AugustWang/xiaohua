-module(messageOn).

-compile(export_all). 

-include("package.hrl").

-include("db.hrl").
-include("itemDefine.hrl").
-include("conSalesBank.hrl").
-include("chat.hrl").
-include("hdlt_logger.hrl").
-include("variant.hrl").
-include("active_battle.hrl").


%%------------------------------------------------------Task------------------------------------------------------
on_U2GS_AcceptTaskRequest(S,#pk_U2GS_AcceptTaskRequest{}=P) ->
	task:on_U2GS_AcceptTaskRequest(P). 

on_U2GS_CompleteTaskRequest(S, #pk_U2GS_CompleteTaskRequest{} = P) ->
	task:on_U2GS_CompleteTaskRequest(P, {}).

on_U2GS_GiveUpTaskRequest(S, #pk_U2GS_GiveUpTaskRequest{} = P) ->
	task:on_U2GS_GiveUpTaskRequest(P).

on_U2GS_CollectRequest(Socket,#pk_U2GS_CollectRequest{}=Pk) ->
	task:on_U2GS_CollectRequest(Pk).

on_U2GS_TalkToNpc( _S, #pk_U2GS_TalkToNpc{}=P )->
	task:on_U2GS_TalkToNpc( P ).

%%------------------------------------------------------Task End------------------------------------------------------

%%----------------------------player move------------------------------------------
on_PlayerMoveTo(_S, #pk_PlayerMoveTo{}=P) ->
	player:sendMsgToMap({playerMove,player:getCurPlayerID(), P}).

on_PlayerStopMove(_Socket,Pk) ->
	player:sendMsgToMap({playerStopMove,player:getCurPlayerID(), Pk}).

on_ChangeFlyState(_Socket,Pk) ->
	player:sendMsgToMap({playerChangeFlyState,player:getCurPlayerID(), Pk}).

on_PlayerDirMove(_Socket,Pk)->
	player:sendMsgToMap({playerDirMove,player:getCurPlayerID(), Pk}).

on_PlayerTeleportMove(Socket,Pk)->
	player:sendMsgToMap({playerTeleportMove,player:getCurPlayerID(), Pk}).
%%----------------------------player move------------------------------------------

on_U2GS_UseSkillRequest(Socket, #pk_U2GS_UseSkillRequest{}=P) ->
	player:sendMsgToMap( {msgplayerUseSkill,player:getCurPlayerID(), P } ).

%%study skill
on_U2GS_StudySkill(Socket,Pk)->
	playerSkill:studySkillMsgSendToMap(Pk#pk_U2GS_StudySkill.nSkillID).

on_activeBranchID(Socket,Pk)->
	PlayerID = player:socketToPlayer(Socket),
	playerSkill:playerSkillBranchActived(PlayerID, Pk#pk_activeBranchID.nSkillID, Pk#pk_activeBranchID.branchID, Pk#pk_activeBranchID.nWhichBranch).

on_U2GS_AddSkillBranch(Socket,Pk)->
	PlayerID = player:socketToPlayer(Socket),
	playerSkill:on_U2GS_playerSkillBranchAdd(PlayerID, Pk#pk_U2GS_AddSkillBranch.nSkillID, Pk#pk_U2GS_AddSkillBranch.nBranchID).

on_U2GS_RemoveSkillBranch(Socket,Pk)->
	PlayerID = player:socketToPlayer(Socket),
	playerSkill:on_U2GS_playerSkillBranchRemove(PlayerID, Pk#pk_U2GS_RemoveSkillBranch.nSkillID).


%%------------------------------------------------------Item------------------------------------------------------
on_RequestGetItem(_Socket, #pk_RequestGetItem{}=P) ->
	playerItems:onMsgGMGetItem(P#pk_RequestGetItem.itemDataID, P#pk_RequestGetItem.amount ).

on_RequestPlayerBagOrder(_Socket,#pk_RequestPlayerBagOrder{}=P)->
	playerItems:onMsgPlayerBagOrder(P#pk_RequestPlayerBagOrder.location ).

on_PlayerRequestUseItem(_Socket,#pk_PlayerRequestUseItem{}=P)->
	playerUseItem:onMsgPlayerUseItem(P#pk_PlayerRequestUseItem.location, P#pk_PlayerRequestUseItem.cell, P#pk_PlayerRequestUseItem.useCount ).
	
on_RequestDestroyItem(_Socket,#pk_RequestDestroyItem{}=P)->
	playerItems:onMsgDestroyItem(P#pk_RequestDestroyItem.itemDBID ).

on_RequestPlayerBagCellOpen(_Socket,#pk_RequestPlayerBagCellOpen{}=P)->
	playerItems:onMsgPlayerBagCellOpen(P#pk_RequestPlayerBagCellOpen.cell, P#pk_RequestPlayerBagCellOpen.location).

on_RequestChangeStorageBagPassWord(_Socket,#pk_RequestChangeStorageBagPassWord{}=P)->
	playerItems:onMsgChangeStorageBagPassWord(P#pk_RequestChangeStorageBagPassWord.oldStorageBagPassWord,
											  P#pk_RequestChangeStorageBagPassWord.newStorageBagPassWord,
											  P#pk_RequestChangeStorageBagPassWord.status).
	
on_RequestPlayerBagSellItem(_Socket,#pk_RequestPlayerBagSellItem{}=P)->
	playerItems:onMsgPlayerBagSellItem(P#pk_RequestPlayerBagSellItem.cell ).

on_RequestClearTempBag(_Socket,#pk_RequestClearTempBag{}=_P)->
	playerItems:onMsgClearTempBag().

on_RequestMoveTempBagItem(_Socket,#pk_RequestMoveTempBagItem{}=P)->
	playerItems:onMsgPutInBag(P#pk_RequestMoveTempBagItem.cell).

on_RequestMoveAllTempBagItem(_Socket,#pk_RequestMoveAllTempBagItem{}=_P)->
	playerItems:onMsgAllPutInBag().

on_RequestMoveStorageBagItem(_Socket,#pk_RequestMoveStorageBagItem{}=P)->
	playerItems:onMsgRequestMoveStorageBagItem(P#pk_RequestMoveStorageBagItem.cell).

on_RequestMoveBagItemToStorage(_Socket,#pk_RequestMoveBagItemToStorage{}=P)->
	playerItems:onMsgRequestMoveBagItemToStorage(P#pk_RequestMoveBagItemToStorage.cell).

on_RequestUnlockingStorageBagPassWord(_Socket,#pk_RequestUnlockingStorageBagPassWord{}=P)->
	playerItems:onMsgRequestUnlockingStorageBagPassWord(P#pk_RequestUnlockingStorageBagPassWord.passWordType).

on_RequestCancelUnlockingStorageBagPassWord(_Socket,#pk_RequestCancelUnlockingStorageBagPassWord{}=P)->
	playerItems:onMsgRequestCancelUnlockingStorageBagPassWord(P#pk_RequestCancelUnlockingStorageBagPassWord.passWordType).

%%------------------------------------------------------NPCStore------------------------------------------------------
on_RequestGetNpcStoreItemList(_Socket,#pk_RequestGetNpcStoreItemList{}=P)->
	npcStore:onMsgRequestGetNpcStoreItemList(P#pk_RequestGetNpcStoreItemList.store_id).

on_RequestBuyItem(_Socket,#pk_RequestBuyItem{}=P)->
	npcStore:onMsgRequestBuyItem(P#pk_RequestBuyItem.item_id,P#pk_RequestBuyItem.store_id,P#pk_RequestBuyItem.amount).

on_RequestSellItem(_Socket,#pk_RequestSellItem{}=P)->
	npcStore:onMsgRequestSellItem(P#pk_RequestSellItem.item_cell).

on_GetNpcStoreBackBuyItemList(_Socket,#pk_GetNpcStoreBackBuyItemList{}=P)->
	npcStore:onMsgGetNpcStoreBackBuyItemList(P#pk_GetNpcStoreBackBuyItemList.count).

on_RequestBackBuyItem(_Socket,#pk_RequestBackBuyItem{}=P)->
	npcStore:onMsgRequestBackBuyItem(P#pk_RequestBackBuyItem.item_id).
%%------------------------------------------------------Equip------------------------------------------------------
on_RequestPlayerEquipActive(_Socket,#pk_RequestPlayerEquipActive{}=P)->
	equipment:activePlayerEquipment(P#pk_RequestPlayerEquipActive.equip_data_id ).

on_RequestPlayerEquipPutOn(_Socket,#pk_RequestPlayerEquipPutOn{}=P)->
	equipment:playerPutonEquipment(P#pk_RequestPlayerEquipPutOn.equip_dbID ).

on_RequestQueryPlayerEquip(_Socket,#pk_RequestQueryPlayerEquip{}=P)->
	equipment:onMsgQueryPlayerEquip(P#pk_RequestQueryPlayerEquip.playerid ).

on_RequestGetPlayerEquipEnhanceByType(_Socket,#pk_RequestGetPlayerEquipEnhanceByType{}=P)->
	equipProperty:getPlayerEquipEnHanceInfoByType(P#pk_RequestGetPlayerEquipEnhanceByType.type ).

on_RequestEquipEnhanceByType(_Socket,#pk_RequestEquipEnhanceByType{}=P)->
	equipProperty:playerEquipEnHance(P#pk_RequestEquipEnhanceByType.type).

on_RequestEquipOnceEnhanceByType(_Socket,#pk_RequestEquipOnceEnhanceByType{}=P)->
	PlayerID = player:socketToPlayer(_Socket),
	equipProperty:playerEquipOnceEnHance(PlayerID,P#pk_RequestEquipOnceEnhanceByType.type).

on_RequestGetPlayerEquipQualityByType(Socket,#pk_RequestGetPlayerEquipQualityByType{}=P)->
	equipProperty:getPlayerEquipQuality(P#pk_RequestGetPlayerEquipQualityByType.type).
	
 on_RequestEquipQualityUPByType(_Socket,#pk_RequestEquipQualityUPByType{}=P)->
	equipProperty:playerEquipQualityUP(P#pk_RequestEquipQualityUPByType.type).
%%洗髓的网络交互
on_RequestEquipOldPropertyByType(_Socket,#pk_RequestEquipOldPropertyByType{}=P)->
	equipProperty:getEquipOldPropertyByType(P#pk_RequestEquipOldPropertyByType.type).

on_RequestEquipChangePropertyByType(_Socket,#pk_RequestEquipChangePropertyByType{}=P)->
	equipProperty:changeEquipPropertyByType(P#pk_RequestEquipChangePropertyByType.type,
											P#pk_RequestEquipChangePropertyByType.property1, 
											P#pk_RequestEquipChangePropertyByType.property2,
											P#pk_RequestEquipChangePropertyByType.property3,
											P#pk_RequestEquipChangePropertyByType.property4,
											P#pk_RequestEquipChangePropertyByType.property5).

on_RequestEquipSaveNewPropertyByType(_Socket,#pk_RequestEquipSaveNewPropertyByType{}=P)->
	equipProperty:saveNewProperty(P#pk_RequestEquipSaveNewPropertyByType.type).


%%------------------------------------------------------Player------------------------------------------------------
on_RequestGM(_Socket,#pk_RequestGM{}=P)->
	gmHandle:onMsgGM(P#pk_RequestGM.strCMD ).


on_ChangeMap(S,Pk) ->
	player:sendMsgToMap({changeMap, player:getCurPlayerID(), Pk}).


on_ShortcutSet(_Socket, #pk_ShortcutSet{}=P) ->
	player:on_ShortcutSet(P).


on_StudySkill(_Socket,#pk_StudySkill{}=P) ->
	skill:studyskill(P#pk_StudySkill{}).
	
on_Reborn(Socket,#pk_Reborn{}=P) ->
	playerMap:on_Reborn( P ).


	
on_Chat2Server(_Socket, #pk_Chat2Server{}=P) ->
	chat:onChatMsg(P).
	
	
	
%%------------------------------------------------------Team------------------------------------------------------
on_beenInviteState( _Socket,Pk )->
	variant:setPlayerVarFlagFromPlayer(?PlayerVariant_Index_3_Team_P, ?PlayerVariant_Index_3_Team_State, Pk#pk_beenInviteState.state).
on_inviteCreateTeam( _Socket,Pk )->
	teamThread ! { u2s_msg_Team, player:getCurPlayerID(), Pk }.
on_ackInviteCreateTeam( _Socket,Pk )->
	teamThread ! { u2s_msg_Team, player:getCurPlayerID(), Pk }.
on_teamQuitRequest( _Socket,Pk )->
	teamThread ! { u2s_msg_Team, player:getCurPlayerID(), Pk }.
on_teamKickOutPlayer( _Socket,Pk )->
	teamThread ! { u2s_msg_Team, player:getCurPlayerID(), Pk }.
on_inviteJoinTeam( _Socket,Pk )->
	teamThread ! { u2s_msg_Team, player:getCurPlayerID(), Pk }.
on_ackInviteJointTeam( _Socket,Pk )->
	teamThread ! { u2s_msg_Team, player:getCurPlayerID(), Pk }.
on_applyJoinTeam( _Socket,Pk )->
	teamThread ! { u2s_msg_Team, player:getCurPlayerID(), Pk }.
on_ackQueryApplyJoinTeam( _Socket,Pk )->
	teamThread ! { u2s_msg_Team, player:getCurPlayerID(), Pk }.
on_teamQueryLeaderInfoRequest( _Socket,Pk )->
	teamThread ! { u2s_msg_Team, player:getCurPlayerID(), Pk }.
on_teamChangeLeaderRequest( _Socket,Pk )->
	teamThread ! { u2s_msg_Team, player:getCurPlayerID(), Pk }.


%%------------------------------------------------------Team------------------------------------------------------


on_RequestSendMail(Socket, Pk) ->
	Id = player:socketToPlayer(Socket),
	player:sendMsgToPlayerProcess(Id, {msgPlayerMsgSendMail, Pk#pk_RequestSendMail{}}).

on_RequestUnReadMail(Socket,Pk) ->
%% 	Id = player:socketToPlayer(Socket),
	mail:getUnReadMailCount(Pk#pk_RequestUnReadMail.playerID).

on_RequestMailList(Socket,Pk) ->
%% 	Id = player:socketToPlayer(Socket),
	mail:getPlayerMailList(Pk#pk_RequestMailList.playerID).

on_RequestMailItemInfo(Socket,Pk) ->
	Id = player:socketToPlayer(Socket),
	mail:getMailItemInfo(Id, Pk#pk_RequestMailItemInfo.mailID).

on_RequestAcceptMailItem(_Socket,Pk) ->
	%Id = player:socketToPlayer(Socket),
	mail:onPlayerMsgRecvMail(Pk).

on_MailReadNotice(_Socket,Pk) ->
	%Id = player:socketToPlayer(Socket),
	mail:changeMailReadFlag(Pk).

on_RequestDeleteMail(_Socket,Pk) ->
	%Id = player:socketToPlayer(Socket),
	mail:onPlayerRequestDeleteMail(Pk#pk_RequestDeleteMail.mailID).

on_RequestDeleteReadMail(_Socket,Pk)->
	%Id = player:socketToPlayer(Socket),
	mail:onPlayerRequestDeleteReadMail(Pk) .

on_RequestSystemMail(_Socket,_Pk) ->
	mail:systemMailTest().
	
%%------------------------------------------------------LS2GS------------------------------------------------------
on_LS2GS_LoginResult(_Socket,Pk)->
	loginServer:on_pk_LS2GS_LoginResult(Pk).

on_LS2GS_QueryUserMaxLevel(_Socket,Pk)->
	loginServer:on_LS2GS_QueryUserMaxLevel(Pk).

on_LS2GS_UserReadyToLogin(_Socket,Pk)->
	loginServer:ok_LS2GS_UserReadyToLogin(Pk).

on_LS2GS_KickOutUser(_Socket,Pk)->
	loginServer:on_LS2GS_KickOutUser(Pk).

on_LS2GS_ActiveCode(_Socket,Pk)->
	loginServer:on_LS2GS_ActiveCode(Pk).

on_LS2GS_Announce(_Socket,Pk)->
	loginServer:on_LS2GS_Announce(Pk).

on_LS2GS_Command(_Socket,Pk)->
	loginServer:on_LS2GS_Command(Pk).

on_LS2GS_Recharge(_Socket,Pk)->
	loginServer:on_LS2GS_Recharge(Pk).

%%------------------------------------------------------U2GS------------------------------------------------------
on_U2GS_RequestLogin(_Socket,Pk)->
	userHandle:on_U2GS_RequestLogin( Pk ).
on_U2GS_SelPlayerEnterGame(_Socket,Pk)->
	userHandle:on_U2GS_SelPlayerEnterGame( Pk,true ).
on_U2GS_RequestCreatePlayer(_Socket,Pk)->
	userHandle:on_U2GS_RequestCreatePlayer( Pk ).

on_U2GS_RequestDeletePlayer(_Socket,Pk)->
	userHandle:on_U2GS_RequestDeletePlayer( Pk ).
on_U2GS_InteractObject( _Socket, Pk )->
	player:sendMsgToMap( {msgFromPlayerSocket, player:getCurPlayerID(), Pk } ).
on_U2GS_QueryHeroProperty( _Socket, Pk )->
	player:sendMsgToMap( {msgFromPlayerSocket, player:getCurPlayerID(), Pk } ).

on_U2GS_EnterCopyMapRequest( _Socket, Pk )->
	player:sendMsgToMap( {msgFromPlayerSocket, player:getCurPlayerID(), Pk } ).

on_U2GS_QueryMyCopyMapCD( _Socket, Pk )->
	player:sendMsgToMap( {msgFromPlayerSocket, player:getCurPlayerID(), Pk } ).

on_U2GS_FastTeamCopyMapRequest( _Socket, Pk )->
	player:sendMsgToMap( {msgFromPlayerSocket, player:getCurPlayerID(), Pk } ).

on_U2GS_QieCuoInvite( _Socket, Pk )->
	player:sendMsgToMap( {msgFromPlayerSocket, player:getCurPlayerID(), Pk } ).

on_U2GS_QieCuoInviteAck( _Socket, Pk )->
	player:sendMsgToMap( {msgFromPlayerSocket, player:getCurPlayerID(), Pk } ).

on_U2GS_PK_KillOpenRequest( _Socket, Pk )->
	player:sendMsgToMap( {msgFromPlayerSocket, player:getCurPlayerID(), Pk } ).
on_U2GS_BloodPoolAddLife(_Socket,Pk)->
	playerUseItem:on_UseBloodPool().

on_U2GS_RestCopyMapRequest( _Socket, Pk )->
	player:sendMsgToMap( {msgFromPlayerSocket, player:getCurPlayerID(), Pk } ).

on_U2GS_GetSigninInfo(_Socket,_Pk) ->
	playerSignIn:onGetSigninInfo(player:getCurPlayerID()).

on_U2GS_Signin(_Socket,_Pk) ->
	playerSignIn:onSignin(player:getCurPlayerID()).

on_U2GS_PetBloodPoolAddLife(Socket,Pk)->
	playerUseItem:on_UsePetBloodPool().
	


%% 	player:sendMsgToMap( {msgFromPlayerSocket, player:getCurPlayerID(), Pk } ).
%%------------------------------------------------------Guild------------------------------------------------------
on_U2GS_RequestCreateGuild(_Socket, Pk )->
	guild:on_U2GS_RequestCreateGuild(Pk).

on_U2GS_QueryGuildList(Socket,Pk)->
	guild:on_U2GS_QueryGuildList(Pk).

on_U2GS_GetMyGuildInfo(Socket,Pk)->
	guild:on_U2GS_GetMyGuildInfo(Pk).

on_U2GS_RequestChangeGuildAffiche(Socket,Pk)->
	guild:on_U2GS_RequestChangeGuildAffiche(Pk).

on_U2GS_RequestJoinGuld(Socket,Pk)->
	guild:on_U2GS_RequestJoinGuld(Pk).

on_U2GS_RequestGuildApplicantAllow(Socket,Pk)->
	guild:on_U2GS_RequestGuildApplicantAllow(Pk).

on_U2GS_QueryGuildShortInfoEx(Socket,Pk)->
	guild:on_U2GS_QueryGuildShortInfoEx(Pk).

on_U2GS_RequestGuildContribute(Socket,Pk)->
	guild:on_U2GS_RequestGuildContribute(Pk).

on_U2GS_RequestGuildKickOutMember(Socket,Pk)->
	guild:on_U2GS_RequestGuildKickOutMember(Pk).

on_U2GS_RequestGuildQuit(Socket,Pk)->
	guild:on_U2GS_RequestGuildQuit(Pk).

on_U2GS_RequestGuildMemberRankChange(Socket,Pk)->
	guild:on_U2GS_RequestGuildMemberRankChange(Pk).

on_U2GS_GetMyGuildApplicantShortInfo(Socket,Pk)->
	guild:on_U2GS_GetMyGuildApplicantShortInfo(Pk).

on_U2GS_RequestGuildApplicantRefuse(Socket,Pk)->
	guild:on_U2GS_RequestGuildApplicantRefuse(Pk).

on_U2GS_RequestGuildApplicantOPAll(Socket,Pk)->
	guild:on_U2GS_RequestGuildApplicantOPAll(Pk).

%%------------------------------------------------------Guild end------------------------------------------------------

%%------------------------------------------------------Wrold map-------------------------------------------------
on_U2GS_TransByWorldMap(Socket,Pk)->
	playerChangeMap:on_U2GS_TransByWorldMap(Pk).

on_U2GS_TransForSameScence(Socket,Pk)->
	playerChangeMap:on_U2GS_TransForSameScence(Pk).
%%------------------------------------------------------World map end---------------------------------------------
	
%%----------------------------------consignment sales bank-----------------------------------------


on_ConSales_GroundingItem(Socket,Pk) ->
	playerConBank:onGroundingItemAsk(Pk).

on_ConSales_TakeDown(Socket,Pk) ->
	conSalesBank:getPid() ! {takeDown, self(), player:getCurPlayerID(), Pk#pk_ConSales_TakeDown.conSalesId}.

on_ConSales_BuyItem(Socket,Pk) ->
	playerConBank:buyAsk(Pk#pk_ConSales_BuyItem.conSalesOderId).

on_ConSales_FindItems(Socket,Pk) ->
	TimeNow = common:timestamp(),
	case TimeNow - player:getCurPlayerProperty(#player.conBankLastFindTime) >= ?conBank_Find_Colding_Time of
		true ->
			player:setCurPlayerProperty(#player.conBankLastFindTime, TimeNow),
			conSalesBank:getPid() !{find, #findOption{
													  ignoreOption=Pk#pk_ConSales_FindItems.ignoreOption,
													  offsetCount=Pk#pk_ConSales_FindItems.offsetCount,
													  type=Pk#pk_ConSales_FindItems.type,
													  detType = Pk#pk_ConSales_FindItems.detType,
													  levelMin=Pk#pk_ConSales_FindItems.levelMin,
													  levelMax=Pk#pk_ConSales_FindItems.levelMax,
													  occ = Pk#pk_ConSales_FindItems.occ,
													  quality = Pk#pk_ConSales_FindItems.quality,
													  idLimit = Pk#pk_ConSales_FindItems.idLimit,
													  idList=Pk#pk_ConSales_FindItems.idList },
									self()};
		false ->
			player:send(#pk_ConSales_FindItems_Result{result=?conBank_Find_Failed_Colding, allCount=0, page=0, itemList=[]})
	end.

on_ConSales_GetSelfSell(Socket,Pk) ->
	conSalesBank:getPid() ! {getSellList, player:getCurPlayerID()}.

on_ConSales_TrunPage(Socket,Pk)->
	playerConBank:onConSalesTrunPage(Pk#pk_ConSales_TrunPage.mode).

on_ConSales_Close(Socket,Pk) ->
	playerConBank:onConbankClose().


%%----------------------------trade--------------------------------------

on_TradeAsk(Socket,Pk) ->
	playerTrade:on_TradeAsk_C2S(Socket, Pk).
		

on_TradeAskResult(Socket,Pk) ->
	playerTrade:on_TradeAskResult_C2S(Socket,Pk).

on_CancelTrade_C2S(Socket,Pk) ->
	playerTrade:cancelTrade(Pk#pk_CancelTrade_C2S.reason).


on_TradeInputItem_C2S(Socket,Pk) ->
	playerTrade:onTradeInputItem_C2S(Pk).

on_TradeTakeOutItem_C2S(Socket,Pk) ->
	playerTrade:onTradeTakeOutItem_C2S(Pk).

on_TradeChangeMoney_C2S(Socket,Pk) ->
	playerTrade:onTradeChangeMoney_C2S(Pk).

on_TradeLock_C2S(Socket,Pk) ->
	playerTrade:onTradeLock_C2S(Pk).

on_TradeAffirm_C2S(Socket,Pk) ->
	playerTrade:onTradeAffirm_C2S(Pk).

%%---------------------------------------pet--------------------------------------
on_PetOutFight(Socket,Pk) ->
	pet:onPetLetOutFight(Pk#pk_PetOutFight.petId).

on_PetTakeRest(Socket,Pk) ->
	pet:onPetTakeRest(Pk#pk_PetTakeRest.petId).

on_PetFreeCaptiveAnimals(Socket,Pk)->
	pet:onPetFreeCaptiveAnimals(Pk#pk_PetFreeCaptiveAnimals.petId).

on_PetCompoundModel(Socket,Pk) ->
	pet:onPetCompoundModel(Pk#pk_PetCompoundModel.petId).

on_PetWashGrowUpValue(Socket,Pk) ->
	pet:onPetWashGrowUpValue(Pk#pk_PetWashGrowUpValue.petId).

on_PetReplaceGrowUpValue(Socket,Pk) ->
	pet:onPetReplaceGrowUpValue(Pk#pk_PetReplaceGrowUpValue.petId).

on_PetIntensifySoul(Socket,Pk) ->
	pet:onPetIntensifySoul(Pk#pk_PetIntensifySoul.petId).

on_PetFuse(Socket,Pk) ->
	pet:onPetFuse(Pk#pk_PetFuse.petSrcId,Pk#pk_PetFuse.petDestId).

on_PetOneKeyIntensifySoul(Socket,Pk)->
	pet:onOneKeyIntensifySoul(Pk#pk_PetOneKeyIntensifySoul.petId).

on_ChangePetAIState(Socket,Pk) ->
	pet:onChangePetAIState(Pk#pk_ChangePetAIState.state).

on_PetLearnSkill(Socket,Pk) ->
	pet:onPetLearnSkill(Pk#pk_PetLearnSkill.petId, Pk#pk_PetLearnSkill.skillId).

on_PetDelSkill(Socket,Pk) ->
	pet:onPetDelSkill(Pk#pk_PetDelSkill.petId, Pk#pk_PetDelSkill.skillId).

on_PetUnLockSkillCell(Socket,Pk) ->
	pet:onPetUnLockSkillCell(Pk#pk_PetUnLockSkillCell.petId).

on_PetSkillSealAhs(Socket,Pk) ->
	petSealStore:onPetSkillSealAhs(Pk#pk_PetSkillSealAhs.petId, Pk#pk_PetSkillSealAhs.skillid).

on_PetlearnSealAhsSkill(Socket,Pk) ->
	pet:onPetlearnSealAhsSkill(Pk#pk_PetlearnSealAhsSkill.petId, Pk#pk_PetlearnSealAhsSkill.skillId).

on_PetChangeName(Socket,Pk) ->
	pet:petChangeName(Pk#pk_PetChangeName.petId, Pk#pk_PetChangeName.newName).

%%--------------------------------------------------Friend--------------------------------------

on_U2GS_QueryFriend(Socket,Pk) ->
 	friend:sendFriendListToPlayer().

on_U2GS_QueryBlack(Socket,Pk) ->
	friend:sendBlackListToPlayer().

on_U2GS_QueryTemp(Socket,Pk) ->
	friend:sendTempListToPlayer().


on_U2GS_AddFriend(Socket,Pk) ->
	friend:on_U2GS_AddFriend(Pk).


on_U2GS_AcceptFriend(Socket,Pk) ->
	friend:on_GS2U_AcceptSuccess(Pk).

on_U2GS_DeleteFriend(Socket,Pk) ->
	friend:on_U2GS_DeleteFriend(Pk).

on_GS2U_Net_Message(_Socket,Pk) ->
	friend:testMess(Pk).

on_GS2U_OnHookSet_Mess(_Socket, Pk) ->
	playerOnHook:processMsg(Pk).

%%--------------------------------------------------Friend End------------------------

on_upMount(Socket,Pk)->
	mount:msg_playerOnorDownMount(1),
	PlayerID = player:socketToPlayer(Socket),
	player:sendMsgToMap({playerOnMount,PlayerID,1001}).

on_downMount(Socket,Pk)->
	mount:msg_playerOnorDownMount(0),
	PlayerID = player:socketToPlayer(Socket),
	player:sendMsgToMap({playerDownMount,PlayerID,1001}).

%%--------------------------------------------------Mount Start------------------------
on_U2GS_QueryMyMountInfo( _Socket, _Pk )->
	mount:on_U2GS_QueryMyMountInfo().

on_U2GS_MountEquipRequest( _Socket, Pk )->
	mount:on_U2GS_MountEquipRequest(Pk).

on_U2GS_Cancel_MountEquipRequest( _Socket, _Pk )->
	mount:on_U2GS_Cancel_MountEquipRequest().

on_U2GS_MountUpRequest( _Socket, _Pk )->
	mount:on_U2GS_MountUpRequest().

on_U2GS_MountDownRequest( _Socket, _Pk )->
	mount:on_U2GS_MountDownRequest().

on_U2GS_LevelUpRequest( _Socket, Pk )->
	mount:on_U2GS_LevelUpRequest(Pk).

%%--------------------------------------------------Mount End------------------------


on_U2GS_LeaveCopyMap(Socket,Pk)->
	player:sendMsgToMap({ playerLeaveCopyMap, player:getCurPlayerID() }).





%%----------------------------------------------商城------------------------------------
on_BazzarListRequest(Socket,Pk)->
	bazzar:onNetMsgRequestItemList( Pk#pk_BazzarListRequest.seed ).

on_BazzarBuyRequest(Socket,Pk)->
	bazzar:onNetMsgBuyItemFromBazzar(Pk#pk_BazzarBuyRequest.db_id, Pk#pk_BazzarBuyRequest.count, Pk#pk_BazzarBuyRequest.isBindGold).

%%-----------------------------------------商城------------------------------------

on_U2GS_CopyMapAddActiveCount(Socket,Pk)->
	playerChangeMap:on_PlayerCopyAddActiveCount( Pk#pk_U2GS_CopyMapAddActiveCount.map_data_id ).

%%----------------------------------------------护送------------------------------------
on_U2GS_CarriageQualityRefresh(_Socket,Pk)->
	convoy:refreshCarriageQuality(Pk).
on_U2GS_ConvoyCDRequst(_Socket,Pk) ->
	convoy:requestConvoyCD(Pk).
on_U2GS_BeginConvoy(_Socket,Pk) ->
	convoy:beginConvoy(Pk).

%%----------------------------------------------世界boss------------------------------------
on_U2GS_GetRankList(Socket,_Pk)->
	PlayerVarArray=player:getPlayerProperty( player:getCurPlayerID(),#player.varArray ),
	BossRanVied=variant:getPlayerVarValue(PlayerVarArray, ?PlayerVariant_Index_WorldBossLastViewTime_P),
	worldBossManagerPID!{sendRankList,player:getCurPlayerID(),player:getCurPlayerProperty(#player.mapPID),BossRanVied,Socket}.

on_GSWithU_GameSetMenu(_Socket,Pk) ->
	GameSetMenu_3 = transfProtocol:transfGameSetMenuTo3(Pk),
	player:setCurPlayerProperty( #player.gameSetMenu, GameSetMenu_3 ).

on_U2GS_RequestRechargeGift(_Socket,Pk)->
	player:onPlayerRequestGetRechargeGift(Pk).

on_U2GS_RequestPlayerFightingCapacity(_Socket,_Pk)->
	playerFightingCapacity:on_Request_Fighting_Capacity_Player().

on_U2GS_RequestPetFightingCapacity(_Socket,Pk)->
	playerFightingCapacity:on_Request_Fighting_Capacity_Pet(Pk).

on_U2GS_RequestMountFightingCapacity(_Socket,Pk)->
	playerFightingCapacity:on_Request_Fighting_Capacity_Mount(Pk).

on_U2GS_ChangePlayerName(_Socket,Pk)->
	userHandle:on_U2GS_ChangePlayerName( Pk ).


on_U2GS_SetProtectPwd(_Socket,Pk)->
	userHandle:on_U2GS_SetProtectPwd( Pk ).

on_U2GS_StartGiveGold(Socket,Pk) ->
	reasureBowl:useReasureBowl(Pk).

on_U2GS_QequestGiveGoldCheck(Socket,Pk) ->
	reasureBowl:questGiveReasureBowlCheck(Pk).
	
 on_U2GS_HeartBeat(Socket,Pk)->
 	gateway:on_HeartBeat(),
 	player:send(#pk_GS2U_HeartBeatAck{}).

on_U2GS_PlayerClientInfo(_Socket,Pk)->
	userHandle:on_U2GS_PlayerClientInfo( Pk ).


on_RequestLookPlayer(Socket,Pk)->
	player:on_RequestLookPlayer(Pk#pk_RequestLookPlayer.playerID).

on_U2GS_RequestActiveCount(Socket,Pk)->
	daily:on_U2GS_RequestActiveCount().

on_U2GS_RequestConvertActive(Socket,Pk)->
	daily:on_U2GS_RequestConvertActive().

on_U2GS_TransferOldRechargeToPlayer(_Socket,Pk)->
	userHandle:on_U2GS_TransferOldRechargeToPlayer( Pk ).

on_U2GS_LoadTopPlayerLevelList(Socket,Pk)->
	top:sendTopPlayerLevelListToPlayer().
on_U2GS_LoadTopPlayerFightingCapacityList(Socket,Pk)->
	top:sendTopPlayerFightingCapacityListToPlayer().
on_U2GS_LoadTopPlayerMoneyList(Socket,Pk)->
	top:sendTopPlayerMoneyListToPlayer().

on_U2GS_AnswerCommit(Socket,Pk)->
        answer:onPlayerCommitAnswer(Pk#pk_U2GS_AnswerCommit.num,Pk#pk_U2GS_AnswerCommit.answer,Pk#pk_U2GS_AnswerCommit.time).
on_U2GS_AnswerSpecial(Socket,Pk)->
        answer:onPlayerUseSpecial(Pk#pk_U2GS_AnswerSpecial.type).

on_RequestChangeGoldPassWord(_Socket,#pk_RequestChangeGoldPassWord{}=P)->
	playerItems:onMsgChangeGoldPassWord(P#pk_RequestChangeGoldPassWord.oldGoldPassWord,
										P#pk_RequestChangeGoldPassWord.newGoldPassWord,
										P#pk_RequestChangeGoldPassWord.status).

on_PlayerImportPassWord(Socket,#pk_PlayerImportPassWord{}=P)->
	playerItems:onMsgPlayerImportPassWord(P#pk_PlayerImportPassWord.passWord,P#pk_PlayerImportPassWord.passWordType).

on_U2GS_RequestBazzarItemPrice(Socket,Pk)->
	bazzar:getPid() ! { requestBazzarItemPrice, self(), Pk#pk_U2GS_RequestBazzarItemPrice.item_id}.
	
on_VIPPlayerOpenVIPStoreRequest(Socket,Pk)->
	npcStore:vipPlayerOpenVIPStoreRequest(Pk#pk_VIPPlayerOpenVIPStoreRequest.request ).

on_ActiveCodeRequest(_,Pk)->
	player:on_ActiveCodeRequest( Pk ).


on_GSWithU_GameSetMenu_3(_Socket,Pk) ->
	player:setCurPlayerProperty( #player.gameSetMenu, Pk ),
	player:sendMsgToMap( { gameSetupChanged, player:getCurPlayerID(), Pk } ).

%%战场相关
on_U2GS_EnRollCampusBattle(_Socket,_Pk)->
	Result=active_battle:canEnrollBattleActive(player:getCurPlayerID()),
	case  Result=:= ?Cannot_Enroll_Success of
		true->
			%%报名次数+1，比较好是进入战场的时候+1
			%%次数取消
			%%PlayerVarArray=player:getCurPlayerProperty(#player.varArray),
			%%VarValue=variant:getPlayerVarValue(PlayerVarArray, ?PlayerVariant_Index_3_Active_P),
			%%BattleJoinOldTime=(VarValue rem 32) div  4,
			%%BattleJoinNewTime=BattleJoinOldTime+1,
			%%variant:setPlayerVarFlagFromPlayer(?PlayerVariant_Index_3_Active_P,
			%%								    ?PlayerVariant_Index_3_Active_Battle1, BattleJoinNewTime rem 2),
			%%variant:setPlayerVarFlagFromPlayer(?PlayerVariant_Index_3_Active_P,
			%%								    ?PlayerVariant_Index_3_Active_Battle2, (BattleJoinNewTime div 2) rem 2),
			%%variant:setPlayerVarFlagFromPlayer(?PlayerVariant_Index_3_Active_P,
			%%								    ?PlayerVariant_Index_3_Active_Battle3, (BattleJoinNewTime div 4) rem 2),
			%%去报名
			%%定义丢这里，万一要恢复
			%%-define( PlayerVariant_Index_3_Active_Battle1,2).   %%战场次数，第一位
			%%-define( PlayerVariant_Index_3_Active_Battle2,3).   %%战场次数，第二位
			%%-define( PlayerVariant_Index_3_Active_Battle3,4).   %%战场次数，第三位，0-7次 应该够了
			active_battle:onRequestCheckEnrollNPC(_Pk#pk_U2GS_EnRollCampusBattle.npcID),
			ok;
		false->
			active_battle:tellClientEnrollResult(player:getCurPlayerID(),Result),
			ok
	end,
	ok.

on_U2GS_leaveCampusBattle(_Socket,_Pk)->
	active_battle:leaveBattleActive(player:getCurPlayerID()),
ok.

on_U2GS_LeaveBattleScene(_Socket,_Pk)->
	active_battle:leaveBattleScene(),
ok.

on_U2GS_requestEnrollInfo(_Socket,_Pk)->
	active_battle:onRequestEnrollInfo(player:getCurPlayerID()),
ok.

on_U2GS_SureEnterBattle(_Socket,_Pk)->
	active_battle:on_requestEnterBattleMap(player:getCurPlayerID(),player:getCurPlayerProperty(#player.faction)),
ok.

on_U2GS_RequestBattleResultList(_Socket,_Pk)->
	copyMap_Battle:request_Battle_Result_list(),
ok.


on_U2GS_RequestOutFightPetPropetry(_Socket,_Pk)->
	PetID = player:getCurPlayerProperty(#player.outFightPet),
	case PetID of
		0->ok;
		_->player:sendMsgToMap( { requestOutFightPetPropetry, self(), PetID } )
	end.




on_RequestEquipFastUpQuality(Socket,#pk_RequestEquipFastUpQuality{} = P)->
	equipProperty:playerEquipFastQualityUP(P#pk_RequestEquipFastUpQuality.equipId).

%%-----------------------------合成----------------------------------
on_StartCompound(Socket,Pk)->
	compound:startCompound(Pk).
%%-----------------------------合成----------------------------------
