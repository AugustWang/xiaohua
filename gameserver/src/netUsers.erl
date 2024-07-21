%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(netUsers).

%% add by wenziyong for gen server
-behaviour(gen_server).
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
%-record(state, {socket, addr}).
-record(state, {socket}).
-define(TIMEOUT, 120000).





%%
%% Include files
%%
-include("db.hrl").
-include("playerDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("mailDefine.hrl").
-include("globalDefine.hrl").
-include("condition_compile.hrl").
-include("logdb.hrl").
-include("variant.hrl").


%%
%% Exported Functions
%%
-compile(export_all).

start_link(Socket) ->
	gen_server:start_link(?MODULE, [Socket], [{timeout,?Start_Link_TimeOut_ms}]).



init([Socket]) ->
%% 	case inet:setopts(Socket, ?TCP_OPTIONS) of
%% 		ok->ok;
%% 		{error, Reason} ->?ERROR_OUT("netUsers, inet:setopts fail,reason:~p ~n",[Reason])
%% 	end,
	initUser( Socket ),
    %{ok, {IP, _Port}} = inet:peername(Socket),
    {ok, #state{socket=Socket}}.






handle_call({createTrade, {PlayerPID, PlayerID, PlayerName}}, _from, Status) ->
	Result = playerTrade:createTradeAsk(PlayerPID, PlayerID, PlayerName),
    {reply, {ok,Result}, Status};

handle_call({isAffirmTrade}, _from, Status) ->
	Result = playerTrade:isAffirmTrade(),
    {reply, {ok,Result}, Status};

handle_call({testCanSwap, ItemList}, _from, Status) ->
	{ReCode, CellList} = playerTrade:testCanSwap(get("SelfTradeItem"), ItemList, get("SelfTradeMoney")),
    {reply, {ok,ReCode, CellList, get("SelfTradeItem")}, Status};

handle_call({delTradeItem}, _from, Status) ->
	Result = playerTrade:onTradeDeleteSelf(get("SelfTradeItem"), get("SelfTradeMoney")),
    {reply, {ok,Result}, Status};

handle_call({addTradeItem, ItemList, Money, Cells}, _from, Status) ->
	Result = playerTrade:onAddTradeItem(ItemList, Money, Cells),
    {reply, {ok,Result}, Status};

handle_call({lookPlayerInfo}, _from, Status) ->
	Result = player:onOtherLookSelf(),
    {reply, {ok,Result}, Status};

handle_call({callVip,Fun,Value}, _from, Status) ->
	?DEBUG_OUT("gen_server:call callVip ---Fun=~p,Value=~p",[Fun,Value]),
	Result = vipFun:callVip(Fun,Value),
    {reply, Result, Status};

handle_call({getVipInfo}, _from, Status) ->
	?DEBUG_OUT("gen_server:call getVipInfo ---",[]),
	Result = vip:getVipInfo(),
    {reply, Result, Status};

handle_call({isinBattleScene}, _from, Status) ->
	?DEBUG_OUT("gen_server:call isinBattleScene ---",[]),
	Result = active_battle:inBattleScene(),
    {reply, Result, Status};




handle_call({checkProcessAlive}, _from, Status) ->
    {reply, ok, Status};
handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

handle_cast({'answerQuestion',Qid,Num,Max,A,B,C,D,E1,E2}, State) ->
	answer:onQuestion(Qid,Num,Max,A,B,C,D,E1,E2),
    {noreply,State};
handle_cast({'answerReady',Time}, State) ->
	answer:onAnswerReady(Time),
    {noreply,State};
handle_cast({'answerClose'}, State) ->
	answer:onAnswerClose(),
    {noreply,State};
handle_cast(_Msg, State) ->
    {noreply,State}.



terminate(_Reason, #state{socket=Socket}) ->
    (catch gen_tcp:close(Socket)),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% modified by wenziyong, to support gen_server
%%每一个User的Socket进程
%procUser( UserSocket )->
initUser( UserSocket )->
	case inet:peername(UserSocket) of
		{ok, {IP, Port}}->
			{A,B,C,D}=IP,
			IPString=integer_to_list(A)++"."++integer_to_list(B)++"."++integer_to_list(C)++"."++integer_to_list(D),
			?LOG_OUT( "initUser self[~p] Socket[~p] IP[~p] Port[~p]",
					  [self(), UserSocket, IPString, Port] ),
			
			put( "UserIP", IPString ),
			
			ok;
		_->put( "UserIP", "0.0.0.0" ), ok
	end,
	
	%%当前进程可直接访问socket
	put( "UserSocket", UserSocket ),

	put( "NextRecvPackCount", 0 ),
	put( "NextSendPackCount", 0 ),

	%%半包数据
	put( "user_half_packge", <<>> ),
	put( "user_half_packge_size", 0 ),


	%%当前Socket是否已经通过验证
	put( "IsSocketCheckPass", false ),
	
	put( "IsPlayerProcess", true ),
	put( "UserState", ?User_State_UnCheckPass ),
	put( "UserID", 0 ),
	put( "UserName", "" ),
	put( "PlayerID", 0 ),
	put("netUsers_platId",0),
	
%% 	put( "ItemCfgTable", main:getGlobalItemCfgTable() ),
%% 	put( "AllStoreTable", main:getGlobalAllStoreTable() ),
%% 	put( "EquipEnhancePropertyTable", main:getGlobalEquipEnhancePropertyTable() ),
%% 	put( "EquipmentqualityTable", main:getGlobalequipmentqualityTable() ),
%% 	put( "EquipmentqualityfactorTable", main:getGlobalequipmentqualityfactorTable() ),
%% 	put( "EquipmentqualityattributeTable", main:getGlobalequipmentqualityattributeTable() ),			   
%% 	put( "EquipmentqualityweightTable", main:getGlobalequipmentqualityweightTable() ),						
%% 	put( "EquipmentActiveItemNeedTable", main:getGlobalequipmentActiveItemNeedTable() ),				
%% 	put( "EquipwashupMoneyTable", main:getGlobalequipmentWashupMoneyTable() ),
%% 
%% 	put( "EquipCfgTable", main:getGlobalEquipCfgTable() ),
%% 	put( "EquipTreeCfgTable", main:getGlobalEquipTreeCfgTable() ),
%% 	put( "mailTable", mail:getMailTable() ),
%% 	put( "mailPlayerTable", mail:getMailPlayerTable() ),
%% 	put( "mailItemTable", mail:getMailItemTable()),
%% 	put( "PlayerBaseCfgTable", player:getPlayerBaseCfgTable() ),
%% 
%% 	put("SkillCfgTable",main:getGlobalSkillCfgTable()),
%% 	put("BuffCfgTable",main:getGlobalBuffCfgTable()),
%% 	put("SkillEffectCfgTable",main:getGlobalSkillEffectCfgTable()),
%% 
%% 	put( "PlayerEXPCfgTable", main:getGlobalPlayerEXPCfgTable() ),
%% 	
%% 	%%属性转换表
%% 	put( "AttributeRegentCfgTable", charDefine:getAttributeRegentCfgTable()),
%% 	
	%%宠物
	put("PetCfgTable", pet:getPetCfgTable()),
	put("PetLevelPropertyCfgTable", pet:getPetLevelPropertyCfgTable()),
	put("PetSoulUpCfgTable", pet:getPetSoulUpCfgTable()),
	
	put( "ItemTable", 0 ),
	put( "ItemBagTable", 0 ),
	put( "EquipTable", 0 ),
	put( "Identity", "" ),
	%%屏蔽字
	put("ForbiddenCfgTable",forbidden:getforbiddenCfgTable()),
	%%交易
	put( "TradeTargetPid", 0 ),
	put( "TradePlayerID", 0),
	put( "TradePlayerName", ""),
	put( "SelfTradeItem", []),
	put( "SelfTradeMoney", 0),
	put( "SelfLockTrade", false),
	put( "SelfAffirmTrade", false),

	%%搜索到的订单列表
	put( "FindConBankOderList", []),
	put( "ConBankNoncePage", 0),

	%%生成随机种子
	{S1,S2,S3} = erlang:now(),
	random:seed(S1, S2, S3),
	
	%%全局socket表
	SocketData = #socketData{socket=UserSocket ,userId = 0,playerId = 0, pid=self()},
	%db:writeRecord( SocketData ),
	gen_server:call(mainPID,{insertSocketData,SocketData }),

	
	

	%% 网关初始化
	gateway:initialize(),

	%proc_lib:init_ack(self()),
	
	?DEBUG_OUT( "accept user socket[~p] userPID[~p] ", [getCurUserSocket(), self()] ),
	ok.



%% modified by wenziyong, to support gen_server
%%每一个User的recieve
handle_info(Info, StateData)->	
	put( "receiveUser", true ),

	try
	case Info of
   	{tcp,UserSocket,Data}->	
			case inet:setopts(UserSocket,[{active,once}]) of
				ok->ok;
				{error, Reason} ->?ERROR_OUT("netUsers, inet:setopts fail,reason:~p ~n",[Reason])
			end,
 			doMsg(UserSocket,Data);		
	{onHeartBeatCheck}->
		gateway:on_HeartBeatCheck();
	{onHeartBeatRateCheck}->
		gateway:on_HeartBeatRateCheck();
 	{onPacketCountCheck}->
 		gateway:on_PacketCountCheck();
	 { judgeTaskChange, TASKTYPE_MONSTER, Name }->
		 task:judgeTaskChange( TASKTYPE_MONSTER, Name);
	 %%玩家未读取邮件
	 { msgPlayerUnReadMail, PlayerID} ->
		 mail:getUnReadMailCount(PlayerID);
		%%随即装备
	{randomEquip,PlayerID}->
		equipment:onGM_RandomEquip(PlayerID);
	{resetRandomDaily}->
		?DEBUG_OUT( "resetRandomDaily"),
		task:resetAllRandomDaily();
	{resetReputation}->
		task:resetReputationTask(player:getCurPlayerProperty(#player.level));
	{resetVipData}->
		vipFun:resetVipFunData();
	{resetGatherTask}->
		task:resetGather();
	{resetCreditLimit}->
		variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index4_Credit_Get_Today_P, 0),
		variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index_Honor_Get_Today_P, 0);
	{request_change_Credit,Value,Reason}->
		case Value>0 of
			true->
				player:addCurPlayerCredit(Value,true, Reason);
			false->
				player:costCurPlayerCredit(-Value, Reason)
		end;
	{resetConvoyTask}->
		convoy:resetConvoy();
	{gaveGatherExp,Level,TaskID}->
		task:gaveGatherExp(TaskID,Level);
	 %%玩家邮件发送结果
	 { msgPlayerMsgSendMail, Msg}->
		 %mail:onPlayerMsgSendMail(Msg, false);
		mail:onPlayerMsgSendMail(Msg);
	 %%邮件设置背包格子锁定
	 { msgPlayerSetBagLock, #msgPlayerSetBagLock{}=Msg }->
		 mail:onMsgPlayerSetBagLock(Msg);
	 %%玩家收取邮件中的附件
	 { msgPlayerRecvMail, #msgPlayerRecvMail{}=Msg }->
		 mail:onPlayerRecvMailAttach( Msg );
	 %%玩家有新邮件通知
	 { informNewMail, #pk_InformNewMail{} = Msg} ->
		 player:send(Msg);
 	 %%获得玩家角色列表结果
	 %% modify for insert mysql directly
	 %{ getPlayerList, PlayerList }->
	 %	 userHandle:on_getPlayerList( PlayerList );
     %%创建角色结果
	 %{ createPlayerResult, Result, PlayerInfo }->
	%	 userHandle:on_createPlayerResult( Result, PlayerInfo );
	 %%删除玩家角色结果
	 %{ deletePlayerResult, Result, PlayerID }->
	%	 userHandle:on_deletePlayerResult( Result, PlayerID );
	 %%玩家被选中进入游戏
	 %% modify for insert mysql directly
	 %{ selPlayerResult, Result, PlayerOnlineDBData }->
		% userHandle:on_selPlayerResult( Result, PlayerOnlineDBData );
	 %%查询玩家名字是否存在
	 %{ queryPlayerNameEixtResult, PlayerID, Msg }->
		% Msg2 = setelement( #pk_RequestSendMail.targetPlayerID, Msg, PlayerID ),
		 %mail:onPlayerMsgSendMail(Msg2, true);
	 %%玩家被踢下线操作
	 { kickOut, Reson }->
		 userHandle:onKickOut( Reson ),
		 doUserOffline( 0 ),
		 put( "receiveUser", false );
	 %%玩家状态设置
	 { actorStateFlag, OP, Value }->
		 playerStateFlag:on_actorStateFlag( OP, Value );
	 %%掉落物品
     { dropItemToPlayer, DropId,MapdropID,WorlddropID,Reason,MosterID} ->
		 player:onDropItemToPlayer(DropId,MapdropID,WorlddropID, Reason,MosterID);
	 %%给玩家添加一个计时器
	 { timerPlayer, CallBackFunc, Param1, Param2, Param3 }->
			CallBackFunc( Param1, Param2, Param3 );
	 %%---------------------------------地图--------------------------------	
	 %%玩家已经进入地图
	 { playerEnteredMap, MapDataID, MapID, MapPID }->
		 player:on_playerEnteredMap( MapDataID, MapID, MapPID );
	 %%增加玩家的经验
     { addEXP, AddValue, Reson }->								
		ParamTuple = #exp_param{changetype = ?Exp_Change_Unknow},
		player:addPlayerEXP( AddValue, Reson, ParamTuple);
	{ addMoney, AddValue, Bind, Reson, ParamTuple}->
		case Bind of
			true->playerMoney:addPlayerBindedMoney(AddValue, Reson, ParamTuple);
			_->playerMoney:addPlayerMoney(AddValue, Reson, ParamTuple)
		end;
	{writelog,Type,ParamLog}->
		PlayerBase = player:getCurPlayerRecord(),
		logdbProcess:write_log_player_event(Type,ParamLog,PlayerBase);
	%%其他进程发送给玩家进程的网络消息，由玩家进程发送
	 { msgSendToPlayer, SendMsg }->
		 player:send( SendMsg );
	 { mapMsg_KillMonster, MonsterDataID, EXP, MapDataID, DropRadio }->
		 playerMap:on_mapMsg_KillMonster( MonsterDataID, EXP, MapDataID, DropRadio );

	 { mapMsg_PlayerDead, WhoKillMe }->
		 playerMap:on_mapMsg_PlayerDead( WhoKillMe );

	 { mapMsg_U2GS_CompleteTaskRequest, Msg, NpcCfg, SuccOrFaile }->
		 task:on_mapMsg_U2GS_CompleteTaskRequest(Msg, NpcCfg, SuccOrFaile);
	 { mapMsg_ReviveResult, ItemLock, SuccOrFaile }->
		 playerMap:on_mapMsg_ReviveResult( ItemLock, SuccOrFaile );
	 {mapMsg_UseBoolbagResult,SuccOrFaile,ItemCfg, ItemDBData,Location, Cell, UseCount,RealAddBood}->
		playerUseItem:on_mapMsg_UseBoolbagResult(SuccOrFaile,ItemCfg, ItemDBData,Location,Cell, UseCount,RealAddBood);
	 {mapMsg_UsePetBoolbagResult,SuccOrFaile,ItemCfg, ItemDBData,Location, Cell, UseCount,RealAddBood}->
		playerUseItem:on_mapMsg_UsePetBoolbagResult(SuccOrFaile,ItemCfg, ItemDBData,Location,Cell, UseCount,RealAddBood);
	 {mapMsg_UseBloodPoolResult,SuccOrFaile, SetBloodPoolValue }->
		playerUseItem:on_mapMsg_UseBloodPoolResult(SuccOrFaile, SetBloodPoolValue);
	 {mapMsg_UsePetBloodPoolResult,SuccOrFaile, SetBloodPoolValue }->
		playerUseItem:on_mapMsg_UsePetBloodPoolResult(SuccOrFaile, SetBloodPoolValue);
	 {mapMsg_UseHpMpResult,SuccOrFaile,ItemCfg, ItemDBData,Location, Cell, UseCount,RealAddBood}->
		playerUseItem:on_mapMsg_UseHpMpResult( SuccOrFaile,ItemCfg, ItemDBData,Location, Cell,UseCount, RealAddBood);
		
	 {on_playerUseItem_Msg_CreateBuff_Result,SuccOrFaile,ItemCfg, ItemDBData,Location, Cell, UseCount,FailCode}->
		playerUseItem:on_playerUseItem_Msg_CreateBuff_Result( SuccOrFaile,ItemCfg, ItemDBData,Location, Cell, UseCount,FailCode);
	
	 %%杀戮冷却时间更新	
	 { playerMapMsg_changePKKillTime, Value }->
		player:setCurPlayerProperty( #player.pK_Kill_OpenTime, Value );
	 %%杀戮值更新	
	 { playerMapMsg_changePKKillValue, Value }->
		player:setCurPlayerProperty( #player.pK_Kill_Value, Value );
	 { playerMapMsg_changePKKillPunish, Value }->
		player:setCurPlayerProperty( #player.pk_Kill_Punish, Value );

	 { playerMapMsg_U2GS_TransForSameScence_Result, CanDecItemInBagResult, SuccOrFail }->
		playerChangeMap:on_playerMapMsg_U2GS_TransForSameScence_Result(CanDecItemInBagResult, SuccOrFail);
		
	 { playerTimeOut_TransByWorldMap_DecItem }->
		playerChangeMap:on_playerTimeOut_TransByWorldMap_DecItem();

		%%上马的地图进程返回
	{playerOnMountResult, Result, MountDataID}->
		mount:on_M2U_MountUpResult(Result, MountDataID);
		%%下马的地图进程返回
	{playerDownMountResult, Result }->
		mount:on_M2U_MountDownResult(Result);
		%%增加副本活跃次数的返回
	{ addActiveCount_Result, Result, DecItemData, IsVIPCount }->
		playerChangeMap:on_AddActiveCountResult(Result, DecItemData, IsVIPCount);
		
	
	 %%---------------------------------仙盟--------------------------------
	{createGuildResult, GuildID, Result}->
		guild:on_createGuildResult(GuildID, Result);
	 {setPlayerGuildID, GuildID}->
		 guild:setPlayerGuildID( GuildID );
	 {guildMemberContributeSet, ContributeMoney, ContributeTime }->
		 guild:on_guildMemberContributeSet( ContributeMoney, ContributeTime );
	 { guild_U2GS_RequestJoinGuld_Result, Result, PlayerID }->
		 guild:on_guild_U2GS_RequestJoinGuld_Result( Result, PlayerID );
	 { msg_guildInformPlayerResult, GuildID, GuildName}->	%%to player
		 player:guildApplyResult(GuildID, GuildName);
	 {msg_applicantAllowComplete, TargetPlayerID }->
		 player:guildApplicantAllowComplete(TargetPlayerID);
	 {guildLevelChanged,GuildID,NewLevel}->
		 player:on_guildLevelChanged(GuildID,NewLevel);
	
	 { updateGuildInfoToMap, GuildID, GuildName, GuildRank }->
		 player:sendMsgToMap( {updateGuildInfo, player:getCurPlayerID(), GuildID, GuildName, GuildRank} );
	 %{ guild_U2GS_RequestGuildApplicantAllow_Result, -1, GuildID } ->

	 %%---------------------------------交易--------------------------------
	 %%交易请求
	 {tradeAsk, PID, PlayerID, PlayerName} ->
		 playerTrade:onTradeAsk_S2S(PID, PlayerID, PlayerName);
	 %%交易请求返回 （接受or拒绝）
	 {tradeAskReturn, PlayerID, PlayerName, Result} ->
		 playerTrade:onTradeAskResult_S2S(PlayerID, PlayerName, Result);
	 %%建立交易
	 {createTrade, TradePid, PlayerID, PlayerName, Result} ->
		 playerTrade:onCreateTrade_S2S(TradePid, PlayerID, PlayerName, Result);
	 %%对方取下物品
	 {tradeTakeOutItem, ItemDB} ->
		 playerTrade:onTradeTakeOutItem_S2S(ItemDB);
     %%自己取下物品返回
	 {tradeTakeOutItemResult, ItemDB, Result} ->
		 playerTrade:onTradeTakeOutItemResult_S2S(ItemDB, Result);
	 %%金钱改变
	 {tradeChangeMoney, Money} ->
		 playerTrade:onTradeChangeMoney_S2S(Money);
	 %%对方取消交易
	 {targetCancelTrage, Reason}->
		 playerTrade:onTargetCancelTrade_S2S( Reason);
	 %%锁定
	 {tradeLock, Person, Lock} ->
		 playerTrade:onTradeLock_S2S(Person,Lock);
	 %%确认交易
	 {tradeAffirm, Person, BAffirm} ->
		 playerTrade:onTradeAffirm_S2S(Person, BAffirm);
	 %%确认交易询问
     {tradeAffirmAsk, SelfItem, SelfMoney, OtherItem, OtherMoney} ->
		 playerTrade:onTradeAffirmAsk_S2S(SelfItem, SelfMoney, OtherItem, OtherMoney);
	 %%---------------------------------交易--------------------------------

	 %%---------------------------------交易行--------------------------------
	 {groundingAskResult, Count, Pk} ->
		 playerConBank:onGroundingItemToConSale(Count, Pk);
	 {findResult, L} ->
		 playerConBank:onFindResult(L);
	 {conBankDelOder, R} ->
		 playerConBank:onDelOder(R);
	 %%购买请求返回
	 {buyAskReturn, R} ->
		 playerConBank:onBuyAskReturn(R);
		%%商城购买请求返回
	{ buyAskResult, ReturnValue, ReturnItem, ItemCount, IsBindGold}->
		bazzar:onBazzarMsgBuyAskResult(  ReturnValue, ReturnItem, ItemCount, IsBindGold );

	 %%---------------------------------交易行--------------------------------

	 %%---------------------------------任务--------------------------------
	 {mapMsg_U2GS_AcceptTaskRequest, Msg, SuccOrFail } ->
		 task:on_mapMsg_U2GS_AcceptTaskRequest( Msg, SuccOrFail );
	 {mapMsg_U2GS_CollectRequest, ObjectCfg, TaskID} ->
		 task:on_mapMsg_U2GS_CollectRequest( ObjectCfg, TaskID );
	 {mapMsg_U2GS_TalkToNpc, NpcCfg, SuccOrFaile } ->
		 task:on_mapMsg_U2GS_TalkToNpc( NpcCfg, SuccOrFaile );
	 %%---------------------------------任务--------------------------------

	 %%---------------------------------宠物--------------------------------
	 {petOutFight_Result, PetId, Result} ->
		 pet:onPetOutFight_result(PetId, Result);
	 {petDead, Pet} ->
		 pet:onPetDead(Pet);
	 {petTakeBack, Pet} ->
		 pet:onMapPetTakeBack(Pet);
	 {petChangeAIState, Result, PetId, State} ->
		 pet:onChangePetAIState_S2S(Result, PetId, State);
	 {petTakeRestResult, Pet, Result}->
		 pet:onPetTakeRestResult_S2S(Pet, Result);
	 %{getPetBuffData_Result, BuffData, Pet, PetCfg} ->
	%	 pet:petOutFight(BuffData, Pet, PetCfg);
	 %%---------------------------------宠物--------------------------------

	 %%---------------------------------skill----------------------------------
	 {msg_playerHasSkillResult, SkillID, Result}->
		 playerSkill:u2gs_PlayerStudySkill(SkillID, Result);
	 {msg_studySkillSuccess, SkillID}->
		 playerSkill:playerStudySkillSucess(SkillID);
	 %%---------------------------------skill---------------------------------- 	

	%% -------------------------------好友------------------------------
	{msg_accept_Agreement, AcceptData} ->
		friend:on_accept_toSend(AcceptData);
	{msg_add_FriendValue, ValueData} ->
		friend:on_add_FriendValue(ValueData);
	{changeFriendMess, Pinfo} ->
		friend:on_send_friendInfo( Pinfo);
	{ netUsersTimer_savePlayerData }->
		player:savePlayerAll(),
		erlang:send_after(?SavePlayerDataTimer,self(), {netUsersTimer_savePlayerData} );
	%% --------------------------------end ----------------------------

	%% -------------------------------充值------------------------------
	{refreshGold}->
		playerMoney:refreshPlayerGold(?Money_Change_Recharge);	
	%% --------------------------------end ----------------------------
	
	%% -------------------------------排行榜刷新-----------------------
	{refreshTopList}->
		top:onPlayerOnlineInitTopList();
	%%世界boss 查看了榜单
	{viewedWorldBoss,Value}->
		%%PlayerVarArray=player:getPlayerProperty( player:getCurPlayerID(),#player.varArray ),
		variant:setPlayerVarValueFromPlayer( ?PlayerVariant_Index_WorldBossLastViewTime_P,Value),
		ok;
	%%战场相关
		{playerNowEnterBattleScene}->
			put("InbattleScene",true),
			messageOn:on_teamQuitRequest(player:getCurPlayerID(), #pk_teamQuitRequest{reserve=0});
		{playerNowLeaveBattleScene}->
			put("InbattleScene",false),
			ok;
	%% --------------------------------end ----------------------------

	%% -------------------------------后台发放物品---------------------
	{platformLoadAndSendItem}->
		platformSendItem:loadAndSendItem();
	{changeForbidChatFlag,ForbidChatFlag} ->
		player:changePlayerForbidChatFlag( ForbidChatFlag );	
	%% --------------------------------end ----------------------------

	%% 护送
	{netUsersTimer_noticeConvoyLeftTime} ->	
		convoy:set_Timer();
	{syncPlayerVariant,VariantData} ->
		variant:syncPlayerVarValueByPlayerProc(VariantData) ;

	{msgletplayerEnterMap,PlayerCampus,MapDataID,Posx,Posy,OwerPlayerID}->
		active_battle:letplayerEnterMap(player:getCurPlayerID(), PlayerCampus,MapDataID, Posx, Posy, OwerPlayerID),
	ok;

	%%日常检测
	 {  dailyCheck, TypeID, DataID }->
		daily:onDailyFinishCheck(TypeID, DataID);
	 {mapMsg_EnrollAck,Result}->
		 %%报名成功，不过貌似没啥处理必要
		active_battle:tellClientEnrollResult(player:getCurPlayerID(),Result),
		ok;
		
	{playerRequestAddHonor,Honor,IsTakeupLimit,Reason}->
		case Honor> 0 of
			true->
				player:addCurPlayerHonor(Honor,IsTakeupLimit, Reason);
			_->
				player:costCurPlayerHonor(-Honor, Reason)
		end;
	
	 {tcp_error, _Socket, Reason}->
		 ?ERROR_OUT( "user socket[~p] closed reson[~p]", [getCurUserSocket(), Reason] ),
		 doUserOffline( 0 ),
		 put( "receiveUser", false );
     {tcp_closed,_Socket}->
		 ?LOG_OUT( "user socket[~p] closed ", [getCurUserSocket()] ),
		 doUserOffline( 0 ),
		 put( "receiveUser", false );
	{quit}->
		 ?LOG_OUT( "player not on line and ping time out" ),
		 doUserOffline( 0 ),
		 put( "receiveUser", false );	
	Unkown ->
		?ERROR_OUT("netUsers handle_info, recv unkown msg:~p",[Unkown])
	

	end,
	
	case get( "receiveUser" ) of
		%true->receiveUser( UserSocket );
		%false->ok
		true->{noreply, StateData};
		false->{stop, normal, StateData}
	end
	
	catch
		{'sendErrorBySocket', ErrorReason}->
			?LOG_OUT( "ExceptionFunc_Module:netUser ExceptionFunc[hande_info] reason[~p] userid[~p]", 
						[ErrorReason, getCurUserID()] ),
			doUserOffline( 0 ),
			{stop, normal, StateData};	
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:netUser ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[_Why, erlang:get_stacktrace()] ),
	
			doUserOffline( 0 ),
			{stop, normal, StateData}
	end.

%%user下线处理
doUserOffline( Reson )->
try
	setCurUserState( ?User_State_Closing ),
	player:onPlayerOffline(),
	%db:delete( socketData, getCurUserSocket() ),
	main:deleteSocketDataBySocket_rpc(getCurUserSocket()),
	
	case getCurUserID() > 0 of
		true->loginServer:sendToLoginServer( #pk_GS2LS_UserLogoutGameServer{ userID=getCurUserID(), identity=get( "Identity" ) } );
		false->ok
	end,

	timer:sleep(1000*1),
	
	?LOG_OUT( "doUserOffline socket[~p] userid[~p] Reson[~p]", [getCurUserSocket(), getCurUserID(), Reson] )
catch
	_:_Why->
		StringValue = io_lib:format( "ExceptionFunc_Module:doUserOffline ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[_Why, erlang:get_stacktrace()] ),
		StringValue2 = lists:flatten(StringValue),			
		?ERROR_OUT( "~p", [StringValue2] ),	
		
		case getCurUserID() > 0 of
			true->loginServer:sendToLoginServer( #pk_GS2LS_UserLogoutGameServer{ userID=getCurUserID(), identity=get( "Identity" ) } );
			false->ok
		end,
		
		%db:delete( socketData, getCurUserSocket() )
		main:deleteSocketDataBySocket_rpc(getCurUserSocket())
end.

checkHalfPackge( Data, DataSize )->
	case ( DataSize > 0 ) andalso ( DataSize =< 1024*1024 ) of
		true->
			User_half_packge_size = get( "user_half_packge_size" ),
			case User_half_packge_size > 0 of
				true->%%有半包，先把半包拼起来
					User_half_packge = get("user_half_packge"),
					NewData = <<User_half_packge/binary, Data/binary>>,
					NewDataSize = DataSize + User_half_packge_size,
					setHalfPackge( <<>>, 0 );
				false->	
					NewData = Data,
					NewDataSize = DataSize
			end,
			case NewDataSize < 4 of
				true->%%包头2字节+2字节协议号，半包
					setHalfPackge( NewData, NewDataSize ),
					{ halfPackge, 0, 0, 0, <<>>, false };
				false->
					{Len,Count1} = common:binary_read_int16(0,NewData),
					case ( Len >= 4 ) andalso ( Len =< 4096 ) of
						true->
							case Len > NewDataSize of
								true->%%半包
									setHalfPackge( NewData, NewDataSize ),
									{ halfPackge, 0, 0, 0, <<>>, false };
								false->
									{Cmd, _Count2} = common:binary_read_int16(Count1,NewData),
									{_,<<Data1/binary>>} = split_binary(NewData,2),
									{ ok, NewDataSize, Len, Cmd, Data1, ( DataSize =/= NewDataSize ) }
							end;
						false->
							{ error, 0, 0, 0, <<>>, false }
					end
			end;
		false->%%超过1MB了，即便是tcp累积，也不对了
			{ error, 0, 0, 0, <<>>, false }
	end.


setHalfPackge( Data, DataSize )->
	put( "user_half_packge", Data ),
	put( "user_half_packge_size", DataSize ).


doMsg(_S, <<>>) ->
	ok;

doMsg(S, Data) ->
	%% forbid catch exception in this function,add by wenziyong
	DataSize2 = byte_size( Data ),
	{ Result, DataSize, Len, CmdGet, Data_NoSizeHead, HasHalfPackge } = checkHalfPackge( Data, DataSize2 ),
	case Result of
		error->
			?LOG_OUT( "recve socket[~p] DataSize[~p] error data", [getCurUserSocket(), DataSize] ),
			throw ( {'Recv Error Data', DataSize} );
		halfPackge->
			?DEBUG_OUT("halfPackge"),
			ok;
		_->
			RecvPackCount = ( CmdGet band 16#F800 ) bsr 11,
			Cmd = ( CmdGet band 16#7FF ),
			
			NextRecvPackCount = get( "NextRecvPackCount" ),
			case RecvPackCount =:= NextRecvPackCount of
				true->ok;
				false->
					?ERROR_OUT( "user:~p Cmd[~p] RecvPackCount[~p] =/= NextRecvPackCount[~p]",
								[Cmd, RecvPackCount, NextRecvPackCount] )
			end,
			
			case NextRecvPackCount + 1 > 31 of
				true->put( "NextRecvPackCount", 0 );
				false->put( "NextRecvPackCount", NextRecvPackCount + 1 )
			end,

			%%检查是否第一个消息是CMD_Login
			case get( "IsSocketCheckPass" ) of
				true->ok;
				false->
					case Cmd of
						?CMD_U2GS_RequestLogin->ok;
						_->
							?ERROR_OUT( "recve socket[~p] Cmd[~p] not check pass", [getCurUserSocket(), Cmd] ),
							throw ( {'Error Cmd', Cmd} )
					end,
					ok
			end,
			gateway:on_RecvPacket(),
			
			message:dealMsg(S, Data_NoSizeHead),
			
			case HasHalfPackge of
				true->put( "user_half_packge", <<>> ),put( "user_half_packge_size", 0 );
				false->ok
			end,
			
			LenLeft = DataSize - Len,
			if LenLeft > 0 ->
				{_,<<DataLeft/binary>>} = split_binary(Data_NoSizeHead,Len-2), 
				doMsg(S, DataLeft);
			true ->
				ok
			end,
			ok
	end.

sendToUser( Msg )->
	Socket = getCurUserSocket(),
	case Socket of
		0->?LOG_OUT( "sendToUser Msg[~p] Socket = 0", [Msg] );
		_->message:send(Socket, Msg)
	end.

%%------------------------------------------------cur proc get------------------------------------------------
%%返回当前进程的UserSocket
getCurUserSocket()->
	UserSocket = get( "UserSocket" ),
	case UserSocket of
		undefined->0;
		_->UserSocket
	end.



%%返回当前进程的userid
getCurUserID()->
	UserID = get( "UserID" ),
	case UserID of
		undefined->0;
		_->UserID
	end.

%%返回当前在线用户数量
getOnlineUserCounts()->
	try 
		%mnesia:table_info( socketData, size )
		etsBaseFunc:getCount(?SocketDataTableAtom)
	catch
		_:_Why->
			StringValue = io_lib:format( "Why[~p]", [ _Why] ),
			StringValue2 = lists:flatten(StringValue),		
			?ERROR_OUT( "~p", [StringValue2] )
	end.


getCurUserState()->
	State = get( "UserState" ),
	case State of
		undefined->0;
		_->
			State
	end.

setCurUserState( NewState )->
	OldState = get( "UserState" ),
	case OldState of
		undefined->0;
		_->
			?DEBUG_OUT( "user ~p setCurUserState old ~p new ~p", [getCurUserID(), OldState, NewState] ),
			put( "UserState", NewState )
	end.





