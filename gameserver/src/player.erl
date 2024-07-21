%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(player).

%%
%% Include files
%%
-include("db.hrl").
-include("logdb.hrl").
-include("playerDefine.hrl").
-include("vipDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("conSalesBank.hrl").
-include("itemDefine.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include_lib("stdlib/include/ms_transform.hrl").

-include("trade.hrl").
-include("variant.hrl").
-include("guildDefine.hrl").
-include("globalDefine.hrl").
-include("textDefine.hrl").
-include("chat.hrl").
-include("publicdb.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
init() ->
	case db:openBinData( "player_base.bin" ) of
		[] ->
			?ERROR_OUT( "openBinData openBinData player_base.bin false []" );
		PlayerBaseData ->
			db:loadBinData( PlayerBaseData, playerBaseCfg ),
			
			
			ets:new( ?PlayerBaseCfgTableAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #playerBaseCfg.id }] ),
			
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.playerBaseCfgTable, PlayerBaseCfgTable),
			
			PlayerBaseCfgList = db:matchObject(playerBaseCfg,  #playerBaseCfg{_='_'} ),
			MyFunc = fun( Record )->
							 etsBaseFunc:insertRecord(?PlayerBaseCfgTableAtom, Record)
					 end,
			lists:map( MyFunc, PlayerBaseCfgList ),
			?DEBUG_OUT( "player_base load succ" )
	end,
	case db:openBinData( "player_exp.bin" ) of
		[] ->
			?ERROR_OUT( "openBinData openBinData player_exp.bin false []" );
		PlayerExpData ->
			db:loadBinData( PlayerExpData, playerEXP ),
			
			
			ets:new( ?PlayerEXPCfgTableAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #playerEXP.level }] ),
			
			
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.playerEXPCfg, PlayerEXPCfgTable),
			
			PlayerExpCfgList = db:matchObject(playerEXP,  #playerEXP{_='_'} ),
			MyFunc2 = fun( Record )->
							 etsBaseFunc:insertRecord(?PlayerEXPCfgTableAtom, Record)
					 end,
			lists:map( MyFunc2, PlayerExpCfgList ),
			?DEBUG_OUT( "player_exp load succ" )
	end,	
	case db:openBinData( "player_recharge_gift.bin" ) of
		[] ->
			?ERROR_OUT( "openBinData openBinData player_recharge_gift.bin false []" );
		PlayerRechargeGiftData ->
			db:loadBinData( PlayerRechargeGiftData, playerRechargeGift ),
			
			
			ets:new( ?PlayerRechargeGiftTableAtom, [set,protected, named_table,{read_concurrency,true},  { keypos, #playerRechargeGift.type }] ),
			
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.playerRechargeGiftTable, PlayerRechargeGiftTable),
			
			PlayerRechargeGiftList = db:matchObject(playerRechargeGift,  #playerRechargeGift{_='_'} ),
			MyFunc3 = fun( Record )->
							 etsBaseFunc:insertRecord(?PlayerRechargeGiftTableAtom, Record)
					 end,
			lists:map( MyFunc3, PlayerRechargeGiftList ),
			?DEBUG_OUT( "player_recharge_gift load succ" )
	end.	

getPlayerRechargeGiftTable()->
	?PlayerRechargeGiftTableAtom.


getPlayerRechargeGiftRecord(Type)->
	etsBaseFunc:readRecord( getPlayerRechargeGiftTable(), Type).

getPlayerBaseCfgTable()->
	?PlayerBaseCfgTableAtom.
	

%%返回是否在玩家进程
isPlayerProcess()->
	case get( "IsPlayerProcess" ) of
		true->true;
		_->false
	end.

%%返回当前玩家基本属性
getCurPlayerBaseCfg( Level, Class )->
	CfgID = ( Class )*?Max_Player_Level + Level,
	etsBaseFunc:readRecord( getPlayerBaseCfgTable(), CfgID).


%%------------------------------------------------Player socket------------------------------------------------
socketToPlayer(Socket)->
	CurSocket = netUsers:getCurUserSocket(),
	case CurSocket of
		Socket->getCurPlayerID();
		_->
			?ERROR_OUT( "error can not socketToPlayer from other process" ),
			%assert ?
			0
	end.

%%改为发到玩家进程，由玩家进程发送，不再支持立即发送
sendToPlayer(PlayerID,Data) ->
	PID = getPlayerPID(PlayerID),	
	sendToPlayerByPID( PID, Data ).


%%发到玩家进程，由玩家进程发送，不再支持立即发送
sendToPlayerByPID(PlayerPID,Data) ->
	case PlayerPID of 
		0 ->
			?LOG_OUT( "sendToPlayerByPID PlayerPID[~p] = 0", [PlayerPID] ),
			ok;
		_ ->
			PlayerPID ! { msgSendToPlayer, Data }
	end.


%%阻塞调用玩家进程
callPlayerProcessByPID(PlayerPID,Data) ->
	case PlayerPID of 
		0 ->
			?LOG_OUT( "callPlayerProcessByPID[~p] = 0", [PlayerPID] ),
			{error,errPid};
		_ ->
			try
				gen_server:call(PlayerPID,Data) 
			catch
				_:_->{error,errPid}
			end
	end.

%%立即发送消息给玩家, 不再支持
%% sendToPlayerNow(PlayerID,Data) ->
%% 	Socket = getSocketIDByPlayerID(PlayerID),	
%% 	
%% 	case Socket of 
%% 		0 ->
%% 			?LOG_OUT( "sendToPlayerNow PlayerID[~p] socket = 0", [PlayerID] ),
%% 			ok;
%% 		_ ->
%% 			message:send(Socket, Data)
%% 	end.

castToAllOnlinePlayer(Msg)->
	AllPlayerPids = getAllOnlinePlayerPids(),
	lists:foreach( fun(Pid)-> gen_server:cast(Pid,Msg) end, AllPlayerPids ).

sendToAllOnLinePlayer(Msg) ->
	%AllPlayer = db:matchObject(playerGlobal, #playerGlobal{_='_'} ),
%% 	AllPlayer = etsBaseFunc:getAllRecord( ?PlayerGlobalTableAtom ),
%% 	lists:foreach( fun(Record)-> sendToPlayer(Record#playerGlobal.id,Msg) end, AllPlayer ).
	AllPlayerPids = getAllOnlinePlayerPids(),
	lists:foreach( fun(Pid)-> sendToPlayerByPID(Pid,Msg) end, AllPlayerPids ).

	

%% 发送消息到指定玩家进程
sendToPlayerProc(PlayerID,Message) ->
	PID = getPlayerPID(PlayerID),	
	case PID of 
		0 ->
			?LOG_OUT( "sendToPlayerProc PID[~p] = 0", [PID] ),
			ok;
		_ ->
			PID ! Message 
	end.

sendToPlayerProcByPID(PlayerPID,Message) ->
	case PlayerPID of 
		0 ->
			?LOG_OUT( "sendToPlayerProcByPID PlayerPID[~p] = 0", [PlayerPID] ),
			ok;
		_ ->
			PlayerPID ! Message
	end.

%% 发送消息到所有玩家进程
sendToAllPlayerProc(Message) ->
	%AllPlayer = db:matchObject(playerGlobal, #playerGlobal{_='_'} ),
%% 	AllPlayer = etsBaseFunc:getAllRecord( ?PlayerGlobalTableAtom ),
%% 	lists:foreach( fun(Record)-> sendToPlayerProc(Record#playerGlobal.id,Message) end, AllPlayer ).
	AllPlayerPids = getAllOnlinePlayerPids(),
	lists:foreach( fun(Pid)-> sendToPlayerProcByPID(Pid,Message) end, AllPlayerPids ).

%% don't catch exception in this function
send(Data) ->
	Socket = netUsers:getCurUserSocket(),	
	
	case Socket of 
		0 ->
			?LOG_OUT( "send PlayerID[~p] socket = 0", [getCurPlayerID()] ),
			ok;
		_ ->
			message:send(Socket, Data)
	end.
	

bostcast([],_) ->
	ok;
  
bostcast(PlayerList,Msg) ->
  	[PlayerID|PlayerList1] = PlayerList,
	sendToPlayer(PlayerID,Msg),
	bostcast(PlayerList1,Msg) 
  	.

%%------------------------------------------------Player property------------------------------------------------
%%返回玩家某属性值
getPlayerProperty( PlayerID, PropertyIndex )->
	case getCurPlayerID() of
		PlayerID->
			%etsBaseFunc:getRecordField( getCurPlayerTable(), PlayerID, PropertyIndex);
			 element( PropertyIndex, get("curPlayerRecord") );
		_->
			%Player = db:getFiled( playerGlobal, PlayerID, #playerGlobal.player ),
			Player = etsBaseFunc:getRecordField( ?PlayerGlobalTableAtom, PlayerID, #playerGlobal.player ),
			case Player of
				0->0;
				_->			
					%etsBaseFunc:getRecordField(PlayerTable, PlayerID, PropertyIndex)
					element(PropertyIndex,Player)
			end
	end.

%%返回某玩家记录，注意：可能返回为{}，表示该玩家不在线
getPlayerRecord( PlayerID )->
	case getCurPlayerID() of
		PlayerID->
			%etsBaseFunc:readRecord( getCurPlayerTable(), PlayerID );
			get("curPlayerRecord");
		_->
			%Player = db:getFiled( playerGlobal, PlayerID, #playerGlobal.player ),
			Player = etsBaseFunc:getRecordField( ?PlayerGlobalTableAtom, PlayerID, #playerGlobal.player ),
			case Player of
				0->{};
				_->			
					%etsBaseFunc:readRecord( PlayerTable, PlayerID )
					Player
			end
	end.

%%返回当前进程玩家某属性值
getCurPlayerProperty( PropertyIndex )->
	%etsBaseFunc:getRecordField( getCurPlayerTable(), getCurPlayerID(), PropertyIndex).
	case get("curPlayerRecord") of
		undefined ->0;
		Player->element(PropertyIndex,Player)
	end.

%%设置当前进程玩家某属性值
setCurPlayerProperty( PropertyIndex, Value )->
	%etsBaseFunc:changeFiled( getCurPlayerTable(), getCurPlayerID(), PropertyIndex, Value ).
	case get("curPlayerRecord") of
		undefined ->0;
		Player->
			Player1 = setelement( PropertyIndex, Player,  Value),
			put("curPlayerRecord",Player1)
	end.

%%获得玩家声望
getCurPlayerCredit()->
	try
		Player = getCurPlayerRecord(),
		case Player of
			{}->throw({-1,0});
			_->ok
		end,
		Credit = Player#player.credit,
		Credit
	catch
		{_,Return}->
			Return
end.

%%玩家声望改变
addPlayerCreditByID(PlayerID,Credit, _Reson )->
	player:sendMsgToPlayerProcess(PlayerID, {request_change_Credit,Credit,_Reson}),
	ok.


%%玩家声望消耗
costCurPlayerCredit( Credit, _Reson )->
try
		case Credit>0 of
			false->
				ok;
			true->
				NewCredit = getCurPlayerProperty(#player.credit ) - Credit,
				case NewCredit<0 of
					true->
						setCurPlayerProperty( #player.credit, 0 );
					false->
						setCurPlayerProperty( #player.credit, NewCredit )
				end,
				%%告知mapplayer
				player:sendMsgToMap( {playerMap_Credit, player:getCurPlayerID(), player:getCurPlayerProperty(#player.credit)} ),
				SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_credit, value=player:getCurPlayerProperty(#player.credit)}] },
				send( SendMsg ),
				ok
		end
	catch
		_->0
	end.


%%玩家声望增加
addCurPlayerCredit( Credit,IsTakeupLimit, _Reson )->
	try
		case Credit =<0 of
			true->
				throw(-1);
			_->ok
		end,
		case IsTakeupLimit of
			true->
				PlayerVarArray=player:getCurPlayerProperty( #player.varArray ),
				CreditGetedToday0=variant:getPlayerVarValue(PlayerVarArray, ?PlayerVariant_Index4_Credit_Get_Today_P),
				case CreditGetedToday0 of
					undefined->
						CreditGetedToday=0;
					_->
						CreditGetedToday=CreditGetedToday0
				end,
				MaxAddedThisTime=globalSetup:getGlobalSetupValue(#globalSetup.token_Max_Credit_Perday)-CreditGetedToday,
				case Credit> MaxAddedThisTime of
					true->
						RealAdd=MaxAddedThisTime;
					false->
						RealAdd=Credit
				end,
				
				case RealAdd=:=0 of
					true->
						systemMessage:sendSysMessage(player:getCurPlayerID(), ?SYSTEM_MESSAGE_PROMPT,?REPUTATION_UPERLIMIT ),
						systemMessage:sendSysMessage(player:getCurPlayerID(), ?SYSTEM_MESSAGE_TIPS,?REPUTATION_UPERLIMIT ),
						throw(-1);
					_->
						ok
				end,
				
				variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index4_Credit_Get_Today_P, RealAdd+CreditGetedToday),
		
				NewCredit = player:getCurPlayerProperty(#player.credit) + RealAdd,
				put( "addPlayerCredit_P1", NewCredit ),
				case NewCredit < 0 of
					true->put( "addPlayerCredit_P1", 0 );
					_->ok
				end,
				SetCredit = get( "addPlayerCredit_P1" ),
				setCurPlayerProperty( #player.credit, SetCredit ),
		
				%%发送公告
				Text = io_lib:format(?REPUTATION_GAINED, [RealAdd,globalSetup:getGlobalSetupValue(#globalSetup.token_Max_Credit_Perday)-(RealAdd+CreditGetedToday)]),
				systemMessage:sendSysMessage(player:getCurPlayerID(), ?SYSTEM_MESSAGE_PROMPT,Text ),
				systemMessage:sendSysMessage(player:getCurPlayerID(), ?SYSTEM_MESSAGE_TIPS,Text ),
				
				%%告知mapplayer
				player:sendMsgToMap( {playerMap_Credit, player:getCurPlayerID(), player:getCurPlayerProperty(#player.credit)} ),
				SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_credit, value=SetCredit}] },
				send( SendMsg ),
				ok;
			false->
				RealAdd=Credit,
				NewCredit = player:getCurPlayerProperty(#player.credit) + RealAdd,
				setCurPlayerProperty( #player.credit, NewCredit ),
		
				%%发送公告
				Text = io_lib:format(?REPUTATION_GAINED2, [RealAdd]),
				systemMessage:sendSysMessage(player:getCurPlayerID(), ?SYSTEM_MESSAGE_PROMPT,Text ),
				
				%%告知mapplayer
				player:sendMsgToMap( {playerMap_Credit, player:getCurPlayerID(), player:getCurPlayerProperty(#player.credit)} ),
				SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_credit, value=NewCredit}] },
				send( SendMsg ),
				ok
		end,
		ok
	catch
		_->0
	end.


%%玩家血量改变
changePlayerHP( HP, _Reson )->
	try
		Player = getCurPlayerRecord(),
		case Player of
			{}->throw(-1);
			_->ok
		end,
		setCurPlayerProperty( #player.life, HP),
		SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_Life, value=HP}] },
		send( SendMsg ),
		HP
	catch
		_->0
	end.



changePlayerForbidChatFlag( ForbidChatFlag )->
	case getCurPlayerRecord() of
		{}->ok;
		_->
			setCurPlayerProperty( #player.forbidChatFlag, ForbidChatFlag)	
	end.


%%玩家血池改变
changePlayerBloodPool( HP, _Reson )->
	try
		Player = getCurPlayerRecord(),
		case Player of
			{}->throw(-1);
			_->ok
		end,
		setCurPlayerProperty( #player.bloodPoolLife, HP),
		SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_BloodPool, value=HP}] },
		send( SendMsg ),
		HP
	catch
		_->0
	end.

%%玩家宠物血池改变
changePlayerPetBloodPool( HP, _Reson )->
	try
		Player = getCurPlayerRecord(),
		case Player of
			{}->throw(-1);
			_->ok
		end,
		setCurPlayerProperty( #player.petBloodPoolLife, HP),
		SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_PetBloodPool, value=HP}] },
		send( SendMsg ),
		HP
	catch
		_->0
	end.

%%其他进程请求增加荣誉
addPlayerHonor(PlayerID,Honor,IsTakeupLimit, _Reson )->
	player:sendMsgToPlayerProcess(PlayerID, {playerRequestAddHonor,Honor,IsTakeupLimit, _Reson}).

%%玩家荣誉获得
addCurPlayerHonor( Honor,IsTakeupLimit,_Reson )->
	?ERROR_OUT("addCurPlayerHonor ~p ~p",[player:getCurPlayerID(),Honor]),
	try
		case Honor =<0 of
			true->
				throw(-1);
			_->ok
		end,
		case IsTakeupLimit of
			true->
				PlayerVarArray=player:getCurPlayerProperty( #player.varArray ),
				HonorGetedToday0=variant:getPlayerVarValue(PlayerVarArray, ?PlayerVariant_Index_Honor_Get_Today_P),
				case HonorGetedToday0 of
					undefined->
						HonorGetedToday=0;
					_->
						HonorGetedToday=HonorGetedToday0
				end,
				MaxAddedThisTime=globalSetup:getGlobalSetupValue(#globalSetup.token_Max_Honor_Perday)-HonorGetedToday,
				case Honor> MaxAddedThisTime of
					true->
						RealAdd=MaxAddedThisTime;
					false->
						RealAdd=Honor
				end,
				
				case RealAdd=:=0 of
					true->
						systemMessage:sendSysMessage(player:getCurPlayerID(), ?SYSTEM_MESSAGE_PROMPT,?HONOR_UPERLIMIT ),
						systemMessage:sendSysMessage(player:getCurPlayerID(), ?SYSTEM_MESSAGE_TIPS,?HONOR_UPERLIMIT ),
						throw(-1);
					_->
						ok
				end,
				
				variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index_Honor_Get_Today_P, RealAdd+HonorGetedToday),
		
				NewHonor = player:getCurPlayerProperty(#player.honor) + RealAdd,
				case NewHonor < 0 of
					true->
						SetHonor=0;
					_->
						SetHonor=NewHonor
				end,
				setCurPlayerProperty( #player.credit, SetHonor ),
		
				%%发送公告
				Text = io_lib:format(?HONOR_GAINED, [RealAdd,globalSetup:getGlobalSetupValue(#globalSetup.token_Max_Honor_Perday)-(RealAdd+HonorGetedToday)]),
				systemMessage:sendSysMessage(player:getCurPlayerID(), ?SYSTEM_MESSAGE_PROMPT,Text ),
				systemMessage:sendSysMessage(player:getCurPlayerID(), ?SYSTEM_MESSAGE_TIPS,Text ),
				
				%%告知mapplayer,目前没这个属性
				%%player:sendMsgToMap( {playerMap_Credit, player:getCurPlayerID(), player:getCurPlayerProperty(#player.credit)} ),
				SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_honor, value=SetHonor}] },
				send( SendMsg ),
				ok;
			false->
				RealAdd=Honor,
				NewHonor = player:getCurPlayerProperty(#player.honor) + RealAdd,
				setCurPlayerProperty( #player.honor, NewHonor ),
		
				%%发送公告
				Text = io_lib:format(?HONOR_GAINED2, [RealAdd]),
				systemMessage:sendSysMessage(player:getCurPlayerID(), ?SYSTEM_MESSAGE_PROMPT,Text ),
				
				%%告知mapplayer,目前没这个属性
				%%player:sendMsgToMap( {playerMap_Credit, player:getCurPlayerID(), player:getCurPlayerProperty(#player.credit)} ),
				SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_honor, value=NewHonor}] },
				send( SendMsg ),
				ok
		end,
		ok
	catch
		_->0
	end.

%%玩家声望消耗,如果不够扣，就扣到0
costCurPlayerHonor( Honor,_Reson)->
	try
		case Honor>0 of
			false->
				ok;
			true->
				NewHonor = getCurPlayerProperty(#player.honor ) - Honor,
				case NewHonor<0 of
					true->
						setCurPlayerProperty( #player.honor, 0 );
					false->
						setCurPlayerProperty( #player.honor, NewHonor )
				end,
				%%告知mapplayer,目前没这个属性
				%%player:sendMsgToMap( {playerMap_Credit, player:getCurPlayerID(), player:getCurPlayerProperty(#player.credit)} ),
				SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_honor, value=player:getCurPlayerProperty(#player.honor)}] },
				send( SendMsg ),
				ok
		end
	catch
		_->0
	end.
	


%%玩家进程调用，使用物品增加多倍经验时间
addMultyExpTimeByItem(AddTime)->
	case AddTime>=0 of
		true->
			PlayerVarArray=player:getCurPlayerProperty( #player.varArray ),
			case variant:getPlayerVarValue(PlayerVarArray, ?PlayerVariant_Index7_Multy_Exp_M) of
				undefined->
					MultyExpEndTime=0;
				EndTime->
					MultyExpEndTime=EndTime
			end,
			%%NowSecond=common:getNowSeconds(),
			NowSecond=common:getNowUTCSeconds(),
			case MultyExpEndTime =< NowSecond of
				true->
					LeftTime=0;
				_->
					LeftTime=MultyExpEndTime- NowSecond
			end,
			variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index7_Multy_Exp_M, LeftTime+AddTime+NowSecond);
		_->
			ok
	end,
	ok.

getItemAddMultyExpPercent()->
	PlayerVarArray=player:getCurPlayerProperty( #player.varArray ),
	MultyExpEndTime=variant:getPlayerVarValue(PlayerVarArray, ?PlayerVariant_Index7_Multy_Exp_M),
	%%NowSecond=common:getNowSeconds(),
	NowSecond=common:getNowUTCSeconds(),
	case MultyExpEndTime =< NowSecond of
		true->
			Result=0;
		_->
			Result=1
	end,
	Result.

getadditionalExpPercent()->
	%%vip的
	Result0=getExpAdd(),
	%%公会加成
	GuildID=player:getCurPlayerProperty( #player.guildID ),
	Result1 = Result0+gen_server:call(guildProcess_PID,{'getAddExpPercent',GuildID}) div 10000,
	%%多倍经验丹加成
	Result2=Result1+getItemAddMultyExpPercent(),
	Result2.

%%玩家经验改变
addPlayerEXP( ChangeEXP, Reson ,ParamTuple)->
	OldLevel = player:getCurPlayerProperty( #player.level ),
	
	case  Reson =:= ?Exp_Change_KillMonster of		
		true->AddPercent=getadditionalExpPercent(),
			  NewChangeEXP = round(ChangeEXP+ChangeEXP*AddPercent);			
		false->NewChangeEXP = ChangeEXP
	end,	
	
	?DEBUG_OUT( "send ChangeEXP [~p] NewChangeEXP [~p]", [ChangeEXP,NewChangeEXP] ),
	PlayerBase = getCurPlayerRecord(),
	PlayerCurEXPCfg = etsBaseFunc:readRecord( main:getGlobalPlayerEXPCfgTable(), OldLevel ),
	case PlayerCurEXPCfg of
		{}->ok;
		_->
			doAddPlayerEXP(NewChangeEXP , Reson,OldLevel,PlayerCurEXPCfg#playerEXP.exp),
		    %%经验变化大于此次升级所需的50%时才写日志
			case (NewChangeEXP > PlayerCurEXPCfg#playerEXP.exp/2) andalso (ParamTuple#exp_param.param0 =:= 1) of
				true->logdbProcess:write_log_exp_change(Reson,ParamTuple,NewChangeEXP,PlayerBase);
				_->ok
			end
	end,
	
	NewLevel = player:getCurPlayerProperty( #player.level ),
	case OldLevel =:= NewLevel of
		false->
			%%升过级了，通知地图
			player:sendMsgToMap( {playerMap_Level, player:getCurPlayerID(), NewLevel} ),

			%%升级了，需要通知帮会进程 add by yueliangyou [2013-04-27]
			case PlayerBase#player.guildID > 0 of 
				true->
					task:resetReputationTaskEx(NewLevel),
					gen_server:cast(guildProcess_PID,{'guildMemberLevel',PlayerBase#player.guildID,PlayerBase#player.id,NewLevel});
				false->ok
			end,
			%% 升级了，重新计算玩家战斗力评分
			PFC=playerFightingCapacity:get_Fighting_Capacity_Player(),
			PFCT=PFC+playerFightingCapacity:get_Fighting_Capacity_PetActive()+playerFightingCapacity:get_Fighting_Capacity_MountEquiped(),
			player:setCurPlayerProperty(#player.fightingCapacity,PFC),
			player:setCurPlayerProperty(#player.fightingCapacityTop,PFCT),

			
			SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_Level, value=player:getCurPlayerProperty( #player.level )}] },
			player:send( SendMsg ),
			ok;
		true->ok
	end,
	
%%  	?DEBUG_OUT( "addPlayerEXP player[~p] ChangeEXP[~p] Reson[~p] OldLevel[~p] NewLevel[~p]",
%%  				[player:getCurPlayerID(),
%%  				 ChangeEXP,
%%  				 Reson,
%%  				 OldLevel,
%%  				 NewLevel]),
	
	%%经验变化通知
	SendMsg2 = #pk_PlayerEXPChanged{ curEXP=player:getCurPlayerProperty(#player.exp), changeReson=Reson },
	send( SendMsg2 ).



doAddPlayerEXP( ChangeEXP, Reson,CurLevel,CfgCurMaxExp )->
	try
		Player = getCurPlayerRecord(),
		case Player of
			{}->throw(-1);
			_->ok
		end,
		
		NextLevel = CurLevel + 1,	
		case ( CurLevel >= ?Max_Player_Level_Cur ) of
			true->
				case Player#player.exp >= CfgCurMaxExp of
					true->throw(-1);
					false->ok
				end;
			false->ok
		end,
		
		NewExp = Player#player.exp + ChangeEXP,
		put( "addPlayerEXP_P1", NewExp ),
		case NewExp < 0 of
			true->put( "addPlayerEXP_P1", 0 );
			_->ok
		end,
		
		case get( "addPlayerEXP_P1" ) >= CfgCurMaxExp of
			true->
				%%升级了
				case NextLevel >= ?Max_Player_Level_Cur of
					true->
						%%满级
						setCurPlayerProperty( #player.exp, CfgCurMaxExp ),
						setCurPlayerProperty( #player.level, ?Max_Player_Level_Cur );
					false->
						%%未满级
						RemainEXP = get( "addPlayerEXP_P1" ) - CfgCurMaxExp,
						setCurPlayerProperty( #player.exp, 0 ),
						setCurPlayerProperty( #player.level, NextLevel ),
						PlayerCurEXPCfg = etsBaseFunc:readRecord( main:getGlobalPlayerEXPCfgTable(), NextLevel ),
						case PlayerCurEXPCfg of
							{}->ok;
							_->
								case RemainEXP < PlayerCurEXPCfg#playerEXP.exp of
									true->setCurPlayerProperty( #player.exp, RemainEXP );
									false->doAddPlayerEXP(RemainEXP , Reson,NextLevel,PlayerCurEXPCfg#playerEXP.exp)
								end
						end
				end,
				
				onPlayerLevelChanged(),
				
				ok;
			false->
				SetExp = get( "addPlayerEXP_P1" ),
				setCurPlayerProperty( #player.exp, SetExp ),
				SetExp
		end
	catch
		_->0
	end.	

%%玩家等级变化了
onPlayerLevelChanged()->
	%%在线变化
	friend:on_my_Change(1),
	playerMap:onPlayer_LevelEquipPet_Changed(),
	%% save player when player level change
	player:savePlayerAll().


%%------------------------------------------------Player get------------------------------------------------
%%返回一个玩家Log字符串
getPlayerShortLog( PlayerID )->
	PlayerName = getPlayerProperty( PlayerID, #player.name ),
	case PlayerName of
		0->
			String = io_lib:format( "Unkown Player PlayerID ~p", [PlayerID] ),
			lists:flatten(String);
		_->
			String = io_lib:format( "Player ~p Name ~p", [PlayerID, PlayerName] ),
			String2 = lists:flatten(String),
			String2
	end.

%%返回所有在线玩家ID列表
getAllOnlinePlayerIDs()->
	%AllPlayer = db:matchObject(playerGlobal, #playerGlobal{_='_'} ),
%% 	AllPlayer = etsBaseFunc:getAllRecord( ?PlayerGlobalTableAtom ),
%% 	lists:map( fun(Record)-> Record#playerGlobal.id end, AllPlayer ).
	Q = ets:fun2ms( fun( Record )-> Record#playerGlobal.id end),
	ets:select(?PlayerGlobalTableAtom, Q).

getAllOnlinePlayerPids()->
	Q = ets:fun2ms( fun( Record )-> Record#playerGlobal.pid end),
	ets:select(?PlayerGlobalTableAtom, Q).

%%返回在线玩家ID，根据玩家名字
getOnlinePlayerIDByName( PlayerName )->
	try
		put( "getOnlinePlayerIDByName", 0 ),
		%AllPlayer = db:matchObject(playerGlobal, #playerGlobal{_='_'} ),
		AllPlayer = etsBaseFunc:getAllRecord( ?PlayerGlobalTableAtom ),
		MyFun = fun( Record )->
					GetName = getPlayerProperty( Record#playerGlobal.id, #player.name ),
					case GetName of
						PlayerName->
							put( "getOnlinePlayerIDByName", Record#playerGlobal.id ),
							throw(-1);
						_->0
					end
				end,
		lists:map( MyFun, AllPlayer ),
		0
	catch
		_->get( "getOnlinePlayerIDByName" )
	end.


%%通过玩家ID来判断玩家是否在线
getPlayerIsOnlineByID(PlayerID) ->
%% 	FindePlayer = db:matchObject(playerGlobal, #playerGlobal{id=PlayerID, _='_'} ),
%% 	case FindePlayer of
%% 		[]->false;
%% 		_->true
%% 	end.
	FindePlayer = etsBaseFunc:readRecord( ?PlayerGlobalTableAtom, PlayerID ),
	case FindePlayer of
		{}->false;
		_->true
	end.
	
	



%%返回玩家的SocketID
getSocketIDByPlayerID( PlayerID )->
	MyPlayerID = getCurPlayerID(),
	case MyPlayerID of 
		PlayerID->get( "UserSocket" );
		_->
			%UserSocket = db:getFiled(playerGlobal, PlayerID, #playerGlobal.userSocket),
			etsBaseFunc:getRecordField( ?PlayerGlobalTableAtom, PlayerID, #playerGlobal.userSocket )
	end.

%%返回玩家所在进程PID
getPlayerPID( PlayerID )->
	%db:getFiled( playerGlobal, PlayerID, #playerGlobal.pid ).
	etsBaseFunc:getRecordField( ?PlayerGlobalTableAtom, PlayerID, #playerGlobal.pid ).

%%发送消息到玩家进程
sendMsgToPlayerProcess( PlayerID, Msg )->
	PlayerPID = player:getPlayerPID( PlayerID ),
	case PlayerPID of
		0->?LOG_OUT("sendMsgToPlayerProcess PlayerID:~p Msg[~p] PID=0", [PlayerID, Msg] );
		_->PlayerPID ! Msg
	end.
	

%%返回当前进程的玩家记录
getCurPlayerRecord()->
	%etsBaseFunc:readRecord( getCurPlayerTable(), getCurPlayerID() ).
	get("curPlayerRecord").
	

%%返回当前进程的playerid
getCurPlayerID()->
	PlayerID = get( "PlayerID" ),
	case PlayerID of
		undefined->0;
		_->PlayerID
	end.

%%返回当前进程的playerid
getCurPlayerName()->
	PlayerName = get( "PlayerName" ),
	case PlayerName of
		undefined->"";
		_->PlayerName
	end.

%%返回当前进程的player_table
%% getCurPlayerTable()->
%% 	PlayerTable = get( "PlayerTable" ),
%% 	case PlayerTable of
%% 		undefined->0;
%% 		_->PlayerTable
%% 	end.


%%------------------------------------------------玩家快捷键------------------------------------------------
%%玩家上线快捷键初始化
onPlayerOnlineInitShortcut( ShortcutList )->
	case ShortcutList of
		[]->ok;
		_->
			[Record|_] = ShortcutList,
			
			etsBaseFunc:insertRecord( get("ShortCutTable"), Record),
			
			player:send(#pk_PlayerAllShortcut{index1ID=Record#shortcut.index1ID, index2ID=Record#shortcut.index2ID,
										index3ID=Record#shortcut.index3ID,index4ID=Record#shortcut.index4ID,index5ID=Record#shortcut.index5ID,
										index6ID=Record#shortcut.index6ID,index7ID=Record#shortcut.index7ID,index8ID=Record#shortcut.index8ID,
										index9ID=Record#shortcut.index9ID,index10ID=Record#shortcut.index10ID,
										index11ID=Record#shortcut.index11ID,index12ID=Record#shortcut.index12ID} )
	end.

%%发送游戏设置菜单信息
sendGameSetMenu( #pk_GSWithU_GameSetMenu_3{}=GameSetMenu )->
	case get("PlayerProtocolVersion") of
		2->
			GameSetMenuOld = transfProtocol:transfGameSetMenu3ToOld(GameSetMenu),
			player:send(GameSetMenuOld);
		_->player:send(GameSetMenu)
	end;
sendGameSetMenu( GameSetMenu )->
	?LOG_OUT("sendGameSetMenu error,GameSetMenu:~p",[GameSetMenu]),
	case get("PlayerProtocolVersion") of
		2->
			player:send(#pk_GSWithU_GameSetMenu{joinTeamOnoff=1, inviteGuildOnoff=1, tradeOnoff=1, 
												   applicateFriendOnoff=1, singleKeyOperateOnoff=1, musicPercent=100, 
												   soundEffectPercent=100, shieldEnermyCampPlayer=0, 
												   shieldSelfCampPlayer=0, shieldOthersPet=0, shieldOthersName=0,
												   shieldSkillEffect=0,dispPlayerLimit=100  });
		_->player:send(#pk_GSWithU_GameSetMenu_3{joinTeamOnoff=1, inviteGuildOnoff=1, tradeOnoff=1, 
												   applicateFriendOnoff=1, singleKeyOperateOnoff=1, musicPercent=100, 
												   soundEffectPercent=100, shieldEnermyCampPlayer=0, 
												   shieldSelfCampPlayer=0, shieldOthersPet=0, shieldOthersName=0,
												   shieldSkillEffect=0,dispPlayerLimit=100,
												   shieldOthersSoundEff=0,noAttackGuildMate=1,reserve1=0,reserve2=0})
	end.
	




getShortcutList()->
	Q = ets:fun2ms( fun( #shortcut{}=Record )-> Record end),
	ets:select(get("ShortCutTable"), Q).
	 

on_ShortcutSet( #pk_ShortcutSet{}=P)->
	ShortcutTable = get( "ShortCutTable" ),
	PlayerID = getCurPlayerID(),
	case P#pk_ShortcutSet.index of
		1 ->
			etsBaseFunc:changeFiled( ShortcutTable, PlayerID, #shortcut.index1ID, P#pk_ShortcutSet.data);
			2 ->
			etsBaseFunc:changeFiled( ShortcutTable, PlayerID, #shortcut.index2ID, P#pk_ShortcutSet.data);
			3 ->
			etsBaseFunc:changeFiled( ShortcutTable, PlayerID, #shortcut.index3ID, P#pk_ShortcutSet.data);
			4 ->
			etsBaseFunc:changeFiled( ShortcutTable, PlayerID, #shortcut.index4ID, P#pk_ShortcutSet.data);
			5 ->
			etsBaseFunc:changeFiled( ShortcutTable, PlayerID, #shortcut.index5ID, P#pk_ShortcutSet.data);
			6 ->
			etsBaseFunc:changeFiled( ShortcutTable, PlayerID, #shortcut.index6ID, P#pk_ShortcutSet.data);
			7 ->
			etsBaseFunc:changeFiled( ShortcutTable, PlayerID, #shortcut.index7ID, P#pk_ShortcutSet.data);
			8 ->
			etsBaseFunc:changeFiled( ShortcutTable, PlayerID, #shortcut.index8ID, P#pk_ShortcutSet.data);
			9 ->
			etsBaseFunc:changeFiled( ShortcutTable, PlayerID, #shortcut.index9ID, P#pk_ShortcutSet.data);
			10 ->
			etsBaseFunc:changeFiled( ShortcutTable, PlayerID, #shortcut.index10ID, P#pk_ShortcutSet.data);
			11 ->
			etsBaseFunc:changeFiled( ShortcutTable, PlayerID, #shortcut.index11ID, P#pk_ShortcutSet.data);
			12 ->
			etsBaseFunc:changeFiled( ShortcutTable, PlayerID, #shortcut.index12ID, P#pk_ShortcutSet.data)
	end.

%%------------------------------------------------玩家操作------------------------------------------------
makePlayerBaseInfoMsg( #player{}=P ) ->
	EquipMinLevel = equipment:getPlayerEquipMinLevel(),
	Timestamp = common:timestamp(),
	case P#player.exp15Add > Timestamp of
		true->Exp15Add=P#player.exp15Add-Timestamp;
		false->Exp15Add=0
	end,
	case P#player.exp20Add > Timestamp of
		true->Exp20Add=P#player.exp20Add-Timestamp;
		false->Exp20Add=0
	end,	
	case P#player.exp30Add > Timestamp of
		true->Exp30Add=P#player.exp30Add-Timestamp;
		false->Exp30Add=0
	end,
	
	case P#player.pK_Kill_OpenTime =:= 0 of
		true->PK_Remain_Time = 0;
		false->PK_Remain_Time = globalSetup:getGlobalSetupValue( #globalSetup.pk_KillTime ) - ( common:timestamp() - P#player.pK_Kill_OpenTime )
	end,

	GuildResult = gen_server:call(guildProcess_PID,{'getGuildInfo',P#player.guildID, P#player.id}),
	{ GuildInfo, MemberInfo}= GuildResult,
	case GuildInfo /= {} andalso MemberInfo /= {} of
		true->
			GuildName = GuildInfo#guildBaseInfo.guildName,
			%GulidID = GuildInfo#guildBaseInfo.id,
			Rank = MemberInfo#guildMember.rank;
		_->
			GuildName = [],
			%GulidID = 0,
			Rank = -1
	end,
	#pk_PlayerBaseInfo{  id = P#player.id, 
				name = P#player.name,
				x = erlang:trunc( P#player.x ),
				y = erlang:trunc( P#player.y ),
				sex = P#player.sex,
				face = 0,
				weapon = 0,
				level=P#player.level,
				camp = P#player.camp,
				faction = P#player.faction,
				vip = P#player.vip,
				maxEnabledBagCells = P#player.maxEnabledBagCells,
				maxEnabledStorageBagCells = P#player.maxEnabledStorageBagCells,
				storageBagPassWord = P#player.storageBagPassWord,
				unlockTimes = P#player.unlockTimes,
				goldPassWord = P#player.goldPassWord,
				money = P#player.money,
				moneyBinded = P#player.moneyBinded,
				gold = P#player.gold,
				goldBinded = P#player.goldBinded,
				rechargeAmmount = P#player.rechargeAmmount,
				ticket = P#player.ticket,
				guildContribute = P#player.guildContribute,
				honor = P#player.honor,
				credit = P#player.credit,
				life = P#player.life,
				lifeMax = P#player.life,
				exp=P#player.exp,
				guildID=P#player.guildID,
				guild_name=GuildName,
				guild_rank=Rank,
				mountDataID = 0,
				pK_Kill_RemainTime=PK_Remain_Time,
				pk_Kill_Value=P#player.pK_Kill_Value,
				pkFlags = P#player.pk_Kill_Punish,
				bloodPool=P#player.bloodPoolLife,
				minEquipLevel=EquipMinLevel,
				petBloodPool=P#player.petBloodPoolLife,
						 exp15Add=Exp15Add,
						 exp20Add=Exp20Add,
						 exp30Add=Exp30Add
						 }.



%%玩家上线初始化
onPlayerOnline( #playerOnlineDBData{}=PlayerOnlineDBData )->
	Player2 = PlayerOnlineDBData#playerOnlineDBData.playerBase,
	Player3 = setelement( #player.lastOnlineTime, Player2, common:timestamp() ),
	Player = setelement( #player.mapPID, Player3, 0 ),
	
	PlayerID = Player#player.id,
	PlayerName = Player#player.name,
	?LOG_OUT( "onPlayerOnline Player[~p] PlayerName[~s] begin", [PlayerID, PlayerName] ),

	%%设置当前进程的玩家ID快速访问
	put( "PlayerID", PlayerID ),
	put( "PlayerName", PlayerName ),
	%db:changeFiled( socketData, netUsers:getCurUserSocket(), #socketData.playerId,PlayerID  ),
	main:changeSocketData_rpc({netUsers:getCurUserSocket(), #socketData.playerId,PlayerID}),
	

	
	
	%%建立物品表
	ItemTable = ets:new( 'itemTable', [protected, { keypos, #r_itemDB.id }] ),
	put( "ItemTable", ItemTable ),
	%%建立背包表
	ItemBagTable = ets:new( 'itemBagTable', [protected, { keypos, #r_playerBag.id }] ),
	put( "ItemBagTable", ItemBagTable ),
	%%建立装备表
	EquipTable = ets:new( 'equipTable', [protected, { keypos, #playerEquipItem.id }] ),
	put( "EquipTable", EquipTable ),
	%%建立任务表	wjl add
	TaskTable = ets:new( 'taskTable', [protected, {keypos, #playerTask.taskID}]),
	put( "TaskTable", TaskTable ),

	%%建立随机日常表

	RandomDailyTable = ets:new( 'randomDailyTable', [protected, {keypos, #randomDailyRecord.randomDailyID}]),
	put( "RandomDailyTable", RandomDailyTable ),


	
	%%建立快捷栏表
	ShortCutTable = ets:new( 'shortCutTable', [protected, { keypos, #shortcut.playerID }] ),
	put( "ShortCutTable", ShortCutTable ),

	%%建立装备强化情况表：
	EquipEnhanceInfoTable = ets:new( 'EquipEnhanceInfoTable', [protected, { keypos, #playerEquipEnhanceLevel.playerId }] ),
	put( "EquipEnhanceInfoTable", EquipEnhanceInfoTable ),

	%%建立好友信息表：
	FriendTable = ets:new( 'friendTable', [protected, { keypos, #friendDB.friendID }] ),
	put( "FriendTable", FriendTable ),

	TempFriendTable = ets:new('TempFriend', [protected, {keypos,#friendDB.friendID}]),
	put("TempFriendTable", TempFriendTable),

	%%建立SKILL 技能表
	SkillTable = ets:new( 'skill', [protected, {keypos,#playerSkill.id}]),
	put("SkillTable",SkillTable),

	%%玩家内存表从db:player建立
	%etsBaseFunc:insertRecord( TablePlayer, Player ),
	put("curPlayerRecord",Player),
	
	

	%%脚本初始化
	%scriptManager:onObjectCreateScript( etsBaseFunc:readRecord( TablePlayer, PlayerID) ),
	scriptManager:onObjectCreateScript( Player ),
	%%建立玩家ID索引的全局表，注意顺序，此操作应该在所有建表之后
	%GlobalePlayerTables = #playerGlobal{ id=PlayerID, userSocket=netUsers:getCurUserSocket(), pid=self(), player=TablePlayer },
	PlayerGlobal = #playerGlobal{ id=PlayerID, userSocket=netUsers:getCurUserSocket(), pid=self(), player=Player },
	%db:writeRecord( GlobalePlayer ),
	gen_server:call(mainPID,{insertPlayerGlobal, PlayerGlobal}),
	
	case Player#player.life =< 0 of
		true->
			player:setCurPlayerProperty(#player.life, 100 ),
			MapCfg = etsBaseFunc:readRecord( main:getGlobalMapCfgTable(), Player#player.map_data_id ),
			case MapCfg of
				{}->%%所在地图不存在，回默认出生点
					?ERROR_OUT( "Player[~p] onPlayerOnline map_data_id[~p] MapCfg={}",
								 [Player#player.id, Player#player.map_data_id] );
				_->
					RevivePosX = MapCfg#mapCfg.initPosX,
					RevivePosY = MapCfg#mapCfg.initPosY,
					player:setCurPlayerProperty(#player.x, RevivePosX),
					player:setCurPlayerProperty(#player.y, RevivePosY)
			end;			
		false->ok
	end,
	
	%%玩家上线初始化player var array
	playerUseItem:onPlayerOnlineInitVarArray(Player#player.varArray ),
	%%玩家上线转档还是怎么转档
	%%variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index7_Multy_Exp_M, 0),

	%%玩家上线装备强化情况初始化
	equipProperty:onPlayerOnlineEquipEnhanceInfoInit( PlayerOnlineDBData#playerOnlineDBData.equipEnhanceInfoList ),

	%%装备初始化
	equipment:onPlayerOnlineToEquipInit( PlayerOnlineDBData#playerOnlineDBData.equipedList ),
	
	%%发送玩家详细信息
	MsgPlayerBaseInfo = makePlayerBaseInfoMsg( getCurPlayerRecord() ),
	send( MsgPlayerBaseInfo ),
	
	?LOG_OUT( "onPlayerOnline Player[~p] sended BaseInfoMsg", [PlayerID] ),
	
	playerStateFlag:addStateFlag( ?Actor_State_Flag_Loading ),

	%%发送解锁仓库密码的时间
	playerItems:onPlayerOnlineToUnlockTimes(),
	playerItems:onPlayerOnlineToGoldPassWordUnlockTimes(),

	
	%%背包初始化
	itemModule:onPlayerOnlineLoadItemData( PlayerOnlineDBData#playerOnlineDBData.allItemDBDataList, PlayerOnlineDBData#playerOnlineDBData.allItemBagDataList ),
	%%任务初始化
	task:onPlayerOnlineLoadTaskData( PlayerOnlineDBData#playerOnlineDBData.allTaskDBDataList ),
	task:onPlayerOnlineLoadSpecialTaskInfo(Player#player.taskSpecialData,Player#player.level,Player#player.lastOfflineTime),
	%%task:resetRandomDailyWhenLogin(PlayerOnlineDBData#playerOnlineDBData.playerBase#player.lastOfflineTime),
	
	%%公会上线处理
	guild:onPlayerOnline(PlayerID),

	%% 加载VIP信息
	vip:loadVipInfo(Player#player.vipLevel,Player#player.vipTimeExpire,Player#player.vipTimeBuy),

	%% 重置VIP信息
	vipFun:resetVipFunDataWhenLogin(Player#player.lastOfflineTime),
	
	%%玩家上线快捷键初始化
	onPlayerOnlineInitShortcut( PlayerOnlineDBData#playerOnlineDBData.allShortcutList ),
	
	%%玩家上线发送好友和黑名单信息
	friend:onPlayerOnlineLoadFriendDB(PlayerOnlineDBData#playerOnlineDBData.allFriendGamedataList),
	%%处理玩家上线后的挂机设置处理 
	playerOnHook:onPlayerInitData(),
	%%技能初始化
	FunConvertSkillCd=fun(#playerSkill{coolDownTime=CdTime}=Recrod)->
							case CdTime > 1431263602 of
								true->Recrod#playerSkill{coolDownTime=0};
								false->Recrod#playerSkill{coolDownTime=CdTime*1000}
							end
					 end,
	SkillList=lists:map(FunConvertSkillCd, PlayerOnlineDBData#playerOnlineDBData.allSkillList),
	playerSkill:onPlayerOnlineSkillInit(SkillList),
	
	%%发送玩家buff
	buff:playerOnline_SendBuffList( PlayerOnlineDBData#playerOnlineDBData.allBuff ),

	%%兽魂仓库初始化
	petSealStore:onPlayerOnlineInit(),

	%%宠物初始化
	pet:onPlayerOnlineInitPet(),
    
	%%坐骑初始化
	mount:onPlayerOnlineInitMount( PlayerOnlineDBData#playerOnlineDBData.playerMountInfo ),
	
	%%物品使用CD初始化
	playerUseItem:onPlayerOnlineInitItemCD( PlayerOnlineDBData#playerOnlineDBData.playerItemCDInfo ),
	%%玩家上线初始化每日使用物品次数CD
	playerUseItem:onPlayerOnlineInitItemDailyCountCD(PlayerOnlineDBData#playerOnlineDBData.playerItem_DailyCountInfo),

	%%护送初始化
	convoy:initPlayerConvoyAndSendCurConvoy(PlayerID),
    %%聚宝盆初始化
	reasureBowl:initPlayerOnLine(Player#player.reasureBowlData),
	%%合成初始化
	compound:initPlayerOnLine(),


	%% 充值延时处理
	%RechargeInfoList=mySqlProcess:get_RechargeInfo(PlayerID),
	%lists:map(fun(List) ->on_Recharge_Delay(List) end, RechargeInfoList),	
	
	netUsers:setCurUserState( ?User_State_Gaming ),
	
	playerStateFlag:removeStateFlag( ?Actor_State_Flag_Loading ),
	
	WeaponRecord = equipment:getPlayerEquipedEquipInfo( ?EquipType_Weapon ),
	case WeaponRecord of
		{}->WeaponID = 0;
		_->WeaponID = WeaponRecord#playerEquipItem.equipid
	end,
	CoatRecord = equipment:getPlayerEquipedEquipInfo( ?EquipType_Coat ),
	case CoatRecord of
		{}->CoatID = 0;
		_->CoatID = CoatRecord#playerEquipItem.equipid
	end,
	EquipMinLevel = equipment:getPlayerEquipMinLevel(),

	%% 计算玩家战斗力评分
	PFC=playerFightingCapacity:get_Fighting_Capacity_Player(),
	PFCT=PFC+playerFightingCapacity:get_Fighting_Capacity_PetActive()+playerFightingCapacity:get_Fighting_Capacity_MountEquiped(),
	%%PFCT=PFC,
	player:setCurPlayerProperty(#player.fightingCapacity,PFC),
	player:setCurPlayerProperty(#player.fightingCapacityTop,PFCT),

	%% 发送排名信息 注释掉，消息内容太多，在这里发送不好。add by yueliangyou[2013-04-27]
	%%top:onPlayerOnlineInitTopList(),
	
	%% 发送游戏设置菜单信息
	player:sendGameSetMenu(Player#player.gameSetMenu),

	%%初始化日常数据
	daily:onPlayerOnLineDailyInit(PlayerOnlineDBData#playerOnlineDBData.dailyCount_Info),

	%% 答题数据处理
	answer:onPlayerOnline(Player#player.lastOfflineTime),

	%%active_battle:on_tellPlayerOnline(PlayerID,Player#player.faction),

	%% 处理平台发放物品 新加功能最好放在我的前面，add by yueliangyou [2013-04-27]
	platformSendItem:loadAndSendItem(),
	
	%%上线初始化进地图
	ConvoyQuality = get("ConvoyRealQulity"),
	ConvoyRemainTimer = get("ConvoyRemainTime"),
	case ConvoyRemainTimer > 0 of
		true -> ConvoyFlags = 1;
		false -> ConvoyFlags = 0
	end,
	Credit=Player#player.credit,
	mapManagerPID ! { playerOnlineToEnterMap, getCurPlayerRecord(), self(),
					  SkillList, PlayerOnlineDBData#playerOnlineDBData.allBuff,
					  charDefine:getPlayerPropertyArray(), WeaponID, CoatID, ConvoyQuality, ConvoyFlags,Credit, EquipMinLevel, vip:getVipInfo()},

	?LOG_OUT( "onPlayerOnline Player[~p] send to mapmanager", [PlayerID] ),

	%% 写上线日志
	logdbProcess:write_log_player_login(?LOG_PLAYER_ONLINE,Player),
	%%objectEvent:onEvent( getCurPlayerRecord(), ?Player_Event_Online, 0 ),
	
	ParamLog = #login_param{logintime = common:timestamp()},
	logdbProcess:write_log_player_event(?EVENT_PLAYER_LOGIN,ParamLog,Player),

	%%初始化进程字典，用途为标记玩家是否报名参加了战斗活动，如果参加了那么玩家下线的时候会给活动管理进程发个消息
	put("EnrollBattleActive",false),

	ok.


%%玩家下线
onPlayerOffline()->
	PlayerID = getCurPlayerID(),
	case PlayerID of
		0->ok;
		_->
			?LOG_OUT( "onPlayerOffline Player[~p] begin", [PlayerID] ),
			
			PlayerBase = player:getCurPlayerRecord(),
			UserID = netUsers:getCurUserID(),
			
			case is15ExpAdd() of
				true->ok;
				false->setCurPlayerProperty( #player.exp15Add, 0)
			end,		
			
			case is20ExpAdd() of
				true->ok;
				false->setCurPlayerProperty( #player.exp20Add, 0)
			end,
			
			case is30ExpAdd() of
				true->ok;
				false->setCurPlayerProperty( #player.exp30Add, 0)
			end,
			
			savePlayerAll(),
			%%好友下线
			friend:on_my_Change(0),
			%%通知地图下线
			player:sendMsgToAllMap( { mapPlayerOffline, PlayerID} ),
			%%通知地图管理进程，玩家下线
			mapManagerPID ! { playerOffeLine, PlayerID }, 
			%%仙盟处理
			guild:onPlayerOffline(PlayerID),
			%%宠物下线处理
			pet:onPlayerOffline(),

			%%交易下线处理
			playerTrade:onPlayerOffLine(),
			
			%%护送下线
			convoy:savePlayerConvoyWhenOffline(),
			
			%%删除玩家全局记录表
			%db:delete(playerGlobal, PlayerID ),
			gen_server:call(mainPID,{deletePlayerGlobal, {PlayerID}}),

			%%通知地图进程，玩家下线
			teamThread ! {playerMsg_Offline,PlayerID},
			
			%dbProcess_PID ! { playeroffline, PlayerID },
			dbProcess:on_playeroffline( PlayerID ),
			
			logdbProcess:write_log_player_login(?LOG_PLAYER_OFFLINE,PlayerBase),
			
			ParamLog = #logout_param{logouttime = common:timestamp()},
			logdbProcess:write_log_player_event(?EVENT_PLAYER_LOGOUT,ParamLog,PlayerBase),
			
			
			LogMachineId = logdbProcess:isMachineExistByID(PlayerID,UserID),
			case LogMachineId of
				0 -> ok;
				_->	logdbProcess:update_playerMachineLogout(LogMachineId)
			end,
			
			case get("EnrollBattleActive") of
				true->
					active_battle:leaveBattleActive(PlayerID),
					ok;
				false->
					ok
			end,
			
			?LOG_OUT( "onPlayerOffline ~p end", [PlayerID] )
			
			
			
	end,
	ok.

%%玩家存盘
savePlayerAll()->
	PlayerBase = player:getCurPlayerRecord(),
	PlayerBase2 = setelement( #player.mapCDInfoList, PlayerBase, [] ),
	%% use local time for lastOfflineTime
	PlayerBase3 = setelement( #player.lastOfflineTime, PlayerBase2, common:getNowSeconds()),
	%% 增加战斗力评分计算 add by yueliangyou[2013-3-30]
	PFC=playerFightingCapacity:get_Fighting_Capacity_Player(),
	PFCT=PFC+playerFightingCapacity:get_Fighting_Capacity_PetActive()+playerFightingCapacity:get_Fighting_Capacity_MountEquiped(),
	%%PFCT=PFC,
	PlayerBase4 = setelement( #player.fightingCapacity,PlayerBase3,PFC),
	PlayerBase5 = setelement( #player.fightingCapacityTop,PlayerBase4,PFCT),
	
	TaskDBSpecial = task:playerOfflineGetSpecialTaskInfo(),
	PlayerBase6=erlang:setelement(#player.taskSpecialData, PlayerBase5, TaskDBSpecial),

	%% 保存VIP信息
	{VipLevel,VipTimeExpire,VipTimeBuy}=vip:getVipInfo(),
	PlayerBase7=erlang:setelement(#player.vipLevel, PlayerBase6, VipLevel),
	PlayerBase8=erlang:setelement(#player.vipTimeExpire, PlayerBase7, VipTimeExpire),
	PlayerBase9=erlang:setelement(#player.vipTimeBuy, PlayerBase8, VipTimeBuy),
	
	EquipedList = equipment:getPlayerActivedEquipList(),
			
	AllItemDBDataList = itemModule:getCurItemDBDataList(),
			
	AllItemBagDataList = playerItems:getPlayerAllBagList(),
			
	AllTaskDBDataList = task:getSavePlayerTaskDataList(),
			
	AllShortcutList = getShortcutList(),

			
	EquipEnhanceInfoList = equipProperty:getEquipEnhanceInfoTable(),
	
	%% modified by wenziyong, add table friend_gamedata, not save friend here, update friend when add or delete friend
	%AllFriendDBList = friend:getSavePlayerFriendDataList(),
	PlayerOnlineDBData = #playerOnlineDBData{ playerBase=PlayerBase9, 
											 equipedList = EquipedList, 
											 allItemDBDataList = AllItemDBDataList, 
											 allItemBagDataList = AllItemBagDataList,
											 allTaskDBDataList = AllTaskDBDataList,
								  			 allShortcutList = AllShortcutList,
											 equipEnhanceInfoList = EquipEnhanceInfoList,
											 allFriendGamedataList = {},
											 playerMountInfo = mount:getPlayerMountInfoList(),
											 playerItemCDInfo = playerUseItem:getPlayerItemCDInfoSaveDB(),
											 playerItem_DailyCountInfo = playerUseItem:getPlayerItemDailyCountCDInfoSaveDB(),
											 dailyCount_Info=daily:getDailyCountInfo()
											},
	%dbProcess_PID ! { savePlayerAll, PlayerOnlineDBData }.
	dbProcess:on_savePlayerAll(PlayerOnlineDBData).



%%------------------------------掉落物品----------------------------------------------
%%掉落物品给玩家
onDropItemToPlayer(DropId,MapdropID,WorlddropID,Reason,_MosterID) ->
	case drop:getDropListByDropId(DropId) of
		[] ->
			false;
		ItemList ->
			playerItems:addItemToPlayerByItemList(ItemList, Reason)
	end,
	case drop:getDropListByDropId(MapdropID) of
		[]->
			false;
		ItemList_map ->
			playerItems:addItemToPlayerByItemList(ItemList_map, Reason)
	end,
	case drop:getDropListByDropId(WorlddropID) of
		[]->
			false;
		ItemList_world ->
			playerItems:addItemToPlayerByItemList(ItemList_world, Reason)
	end.
	

	
%%发送消息给当前地图
sendMsgToMap( Msg )->
	MapPID = player:getCurPlayerProperty(#player.mapPID),
	case MapPID of
		0->?ERROR_OUT( "sendMsgToMap Msg[~p] mapPID=0", [Msg] );
		undefined->?ERROR_OUT( "sendMsgToMap Msg[~p] mapPID=undefined", [Msg] );
		_->MapPID ! Msg
	end.

%%发送消息给所有地图
sendMsgToAllMap( Msg )->
	mapManagerPID ! { playerSendMsgToAllMap, Msg }.
%%-----------------------------------仙盟----------------------------------------
%%仙盟申请通过
guildApplyResult(GuildID, GuildName)->
	setCurPlayerProperty( #player.guildID, GuildID ),
	

	%% 加入帮会成功，重置帮会任务
	task:resetReputationTaskEx(getCurPlayerProperty(#player.level)),
	Msg = #pk_GS2U_JoinGuildSuccess{guildID=GuildID, guildName=GuildName},
	send(Msg).

%%仙门操作申请列表之后
guildApplicantAllowComplete(PlayerID)->
	Msg = #pk_GS2U_AllowOpComplete{playerID=PlayerID},
	send(Msg).

on_guildLevelChanged(_GuildID,_NewLevel)->
	
	ok.

%%玩家已经进入地图
on_playerEnteredMap( MapDataID, MapID, MapPID )->
	player:setCurPlayerProperty( #player.mapId, MapID ),
	player:setCurPlayerProperty( #player.map_data_id, MapDataID ),
	player:setCurPlayerProperty( #player.mapPID, MapPID ),
	
	%%告知战场活动进程，玩家上线并且进入地图了
	active_battle:on_tellPlayerOnline(player:getCurPlayerID(),player:getCurPlayerProperty(#player.faction)),

	%%检测是否需要删除物品
	playerChangeMap:on_playerEnteredMap_TransByWorldMap_DecItem( MapDataID ),

	%%召唤宠物
	pet:onPlayeEnterMapOutFight(),
	
	%%切换地图坐骑处理
	mount:onChangeMap(MapDataID),
	
	%% 玩家进入地图有护送任务时先设置状态
	convoy:sendOnlineMsgToMap().	

%% on_playerMapMsg_changePKKillTime( Value )->
%% 	etsBaseFunc:changeFiled( ?MODULE:getCurPlayerTable(), ?MODULE:getCurPlayerID(), #player.pK_Kill_OpenTime, Value).


%% on_playerMapMsg_changePKKillValue( Value )->
%% 	etsBaseFunc:changeFiled( ?MODULE:getCurPlayerTable(), ?MODULE:getCurPlayerID(), #player.pK_Kill_Value, Value).

%%玩家充值延时处理
on_Recharge_Delay(#rechargeInfo{orderid=OrderID,platform=Platform,account=Account,userid=UserID,playerid=PlayerID,ammount=Ammount}=_P)->
	?DEBUG_OUT( "recharge delay process ... orderid:[~p],platform[~p]",[OrderID,Platform] ),
	try
		case mySqlProcess:updateRechargeInfoOK(OrderID,Platform) of
			{ok,_}->ok;
			{error,_}->throw(-1)
		end,

		%% 加钱
		AdGold=Ammount*?RMB_GOLD_RATIO,
		ParamTuple = #token_param{changetype = ?Money_Change_Recharge,param1=OrderID,param2=Platform,param3=Account},	
		case 0 < playerMoney:addPlayerGold(AdGold,?Money_Change_Recharge, ParamTuple) of
			true->
				%% 写入日志	
				?DEBUG_OUT( "recharge delay process suc orderid:[~p],platform[~p]",[OrderID,Platform] ),
				logdbProcess:write_log_recharge_ok(OrderID,Platform,Account,UserID,PlayerID,Ammount);
			false->
				?DEBUG_OUT( "recharge delay process failed.orderid:[~p],platform[~p]",[OrderID,Platform] )
		end
	catch
		_->
			?DEBUG_OUT( "recharge delay process ignored orderid:[~p],platform[~p]",[OrderID,Platform] )
	end,
	ok.


%%玩家充值处理
on_Recharge(#pk_LS2GS_Recharge{orderid=OrderID,platform=Platform,account=Account,userid=UserID,playerid=PlayerID,ammount=Ammount}=_P)->
	
	?LOG_OUT( "recharge process ... orderid:[~p],platform[~p]",[OrderID,Platform] ),
	%% 加钱
	AdGold=Ammount*?RMB_GOLD_RATIO,
	ParamTuple = #token_param{changetype = ?Money_Change_Recharge,param1=OrderID,param2=Platform,param3=Account},	
	case 0 < playerMoney:addPlayerGold(AdGold,?Money_Change_Recharge,ParamTuple) of
		true->
			%% 写入日志	
			?LOG_OUT( "recharge process suc orderid:[~p],platform[~p]",[OrderID,Platform] ),
			logdbProcess:write_log_recharge_ok(OrderID,Platform,Account,UserID,PlayerID,Ammount);
		false->
			%% 写入延时处理记录表
                        Record = #rechargeInfo{ orderid=OrderID,platform=Platform,
                                                account=Account,userid=UserID,playerid=PlayerID,        
                                                ammount=Ammount,flag=?RECHARGE_INFO_FLAG_FAIL },
                        case mySqlProcess:insertRechargeInfo(Record) of
                                {ok,_}->ok;
                                {error,_}->
					?ERROR_OUT( "recharge process failed.orderid:[~p],platform[~p]",[OrderID,Platform] )
                        end
	end,
	ok.

%%------------充值礼包领取相关--------------------------
%%------------------------------------------------------
%% 获取玩家充值总金额,从内存读取
getPlayerRechargeAmmount()->	
	getCurPlayerProperty(#player.rechargeAmmount).

%% 获取玩家充值总金额从数据库直接读取，并更新内存，不需要了，整合到gold一起了。
refreshPlayerRechargeAmmount()->
	ok.

%% 增加玩家充值总金额，非玩家进程调用，需要直接读写数据库，不需要了，整合到gold一起了。
addPlayerRechargeAmmount(_PlayerID,_Ammount)->
	ok.

%% 获取玩家领取充值礼包标志位 ->true or false
getPlayerRechargeGiftFlag(Type)->
	PlayerVarArray = player:getCurPlayerProperty( #player.varArray ),
	variant:getPlayerVarFlag(PlayerVarArray,?PlayerVariant_Index_CZLBLQ_P, Type).

%% 设置玩家领取充值礼包标志位
setPlayerRechargeGiftFlag(Type)->
	variant:setPlayerVarFlagFromPlayer(?PlayerVariant_Index_CZLBLQ_P, Type,1).


%% 玩家请求领取充值礼包 type,ammount,itemid,count,bind
onPlayerRequestGetRechargeGift(#pk_U2GS_RequestRechargeGift{type=Type}=_Pkt)->
	try
	%% 检查type值，最大支持32位
	case Type > ?RECHARGE_GIFT_MAX of
		true->throw({invalidTypeValue});
		false->ok
	end,
	%% 获取充值礼包配置表
	RechargeGiftRecord=getPlayerRechargeGiftRecord(Type),	
	case RechargeGiftRecord of
		{}->throw({invalidTypeValue});
		[]->throw({invalidTypeValue});
		_->ok
	end,

	AmmountNeed=RechargeGiftRecord#playerRechargeGift.ammount,
	?DEBUG_OUT("Ammount:~p,AmmountNeed:~p",[getPlayerRechargeAmmount(),AmmountNeed]),
	%% 检查玩家充值金额	
	case getPlayerRechargeAmmount()<AmmountNeed of
		true->throw({notEnoughAmmount});
		false->ok
	end,
	
	%% 检查玩家标志位
	case getPlayerRechargeGiftFlag(Type) of
		true->throw({alreadyGet});
		false->ok
	end,

	ItemID0=RechargeGiftRecord#playerRechargeGift.item0,
	Count0=RechargeGiftRecord#playerRechargeGift.count0,
	case RechargeGiftRecord#playerRechargeGift.bind0 of
		0->Binded0=false;
		_->Binded0=true
	end,	
	ItemID1=RechargeGiftRecord#playerRechargeGift.item1,
	Count1=RechargeGiftRecord#playerRechargeGift.count1,
	case RechargeGiftRecord#playerRechargeGift.bind1 of
		0->Binded1=false;
		_->Binded1=true
	end,	
	ItemID2=RechargeGiftRecord#playerRechargeGift.item2,
	Count2=RechargeGiftRecord#playerRechargeGift.count2,
	case RechargeGiftRecord#playerRechargeGift.bind2 of
		0->Binded2=false;
		_->Binded2=true
	end,	
	ItemID3=RechargeGiftRecord#playerRechargeGift.item3,
	Count3=RechargeGiftRecord#playerRechargeGift.count3,
	case RechargeGiftRecord#playerRechargeGift.bind3 of
		0->Binded3=false;
		_->Binded3=true
	end,	
	ItemID4=RechargeGiftRecord#playerRechargeGift.item4,
	Count4=RechargeGiftRecord#playerRechargeGift.count4,
	case RechargeGiftRecord#playerRechargeGift.bind4 of
		0->Binded4=false;
		_->Binded4=true
	end,	
	ItemID5=RechargeGiftRecord#playerRechargeGift.item5,
	Count5=RechargeGiftRecord#playerRechargeGift.count5,
	case RechargeGiftRecord#playerRechargeGift.bind5 of
		0->Binded5=false;
		_->Binded5=true
	end,	
	Item0=#itemForAdd{id=ItemID0,count=Count0,binded=Binded0},
	Item1=#itemForAdd{id=ItemID1,count=Count1,binded=Binded1},
	Item2=#itemForAdd{id=ItemID2,count=Count2,binded=Binded2},
	Item3=#itemForAdd{id=ItemID3,count=Count3,binded=Binded3},
	Item4=#itemForAdd{id=ItemID4,count=Count4,binded=Binded4},
	Item5=#itemForAdd{id=ItemID5,count=Count5,binded=Binded5},

	ItemList=[Item0,Item1,Item2,Item3,Item4,Item5],
		
	%% 给玩家发物品
	case playerItems:addItemToPlayerByItemList(ItemList,?Get_Item_Reson_RechargeGift) of
		true->ok;
		false->throw({bagIsFull})
	end,

	%% 设置玩家变量,并发送消息给客户端
	setPlayerRechargeGiftFlag(Type),	
	send(#pk_U2GS_RequestRechargeGift_Ret{retcode=?RCODE_RECHARGE_GIFT_SUC})

	catch
		{notEnoughAmmount}->send(#pk_U2GS_RequestRechargeGift_Ret{retcode=?RCODE_RECHARGE_GIFT_NOTENOUGH_AMMOUNT});
		{alreadyGet}->send(#pk_U2GS_RequestRechargeGift_Ret{retcode=?RCODE_RECHARGE_GIFT_ALREADY_GET});
		{bagIsFull}->send(#pk_U2GS_RequestRechargeGift_Ret{retcode=?RCODE_RECHARGE_GIFT_BAG_ISFULL});
		{invalidTypeValue}->
			send(#pk_U2GS_RequestRechargeGift_Ret{retcode=?RCODE_RECHARGE_GIFT_INVALID_TYPE}),
			?LOG_OUT("invalidTypeValue:~p",[Type]);
		_:Why->
			send(#pk_U2GS_RequestRechargeGift_Ret{retcode=?RCODE_RECHARGE_GIFT_EXCEPTION}),
			?LOG_OUT("PlayerRequestGetRechargeGift exception.why:~p",[Why])	
	end.

%%------------------------------------------------------
%%------------充值礼包领取相关---end--------------------


%%查看其它玩家属性
on_RequestLookPlayer( PlayerID )->
	try
		case PlayerID =:= player:getCurPlayerID() of
			true->throw(?LookPlayerInfo_Failed_Self);
			_->ok
		end,
		
		PID = player:getPlayerPID(PlayerID),
		case PID of
			0->throw(?LookPlayerInfo_Failed_NotOnline);
			_->ok
		end,
		case player:callPlayerProcessByPID(PID, {lookPlayerInfo}) of
			{ok, {MapPID, Msg}}->
				%%将本消息发送到地图进程填充玩家在地图上的属性
				MapPID ! {lookPlayerInfo, self(), PlayerID, Msg};
			_->throw(?LookPlayerInfo_Failed_UnKnow)
		end
		
	catch
		FailCode->player:send(#pk_RequestLookPlayerFailed_Result{result=FailCode})
end.



%%------------经验加成相关--------------------------
%%------------------------------------------------------
is15ExpAdd()->
	Player = getCurPlayerRecord(),
	Timestamp = common:timestamp(),
	case Player of
		{}->false;
		_->
			case Player#player.exp15Add >= Timestamp of
				true->true;
				false->false
			end
	end.

is20ExpAdd()->
	Player = getCurPlayerRecord(),
	Timestamp = common:timestamp(),
	case Player of
		{}->false;
		_->
			case Player#player.exp20Add >= Timestamp of
				true->true;
				false->false
			end
	end.
	
is30ExpAdd()->
	Player = getCurPlayerRecord(),
	Timestamp = common:timestamp(),
	case Player of
		{}->false;
		_->
			case Player#player.exp30Add >= Timestamp of
				true->true;
				false->false
			end
	end.

getExpAdd()->
	Player = getCurPlayerRecord(),
	Timestamp = common:timestamp(),
	put("add15",0),
	put("add20",0),
	put("add30",0),
	case Player of
		{}->ok;
		_->
			case Player#player.exp15Add >= Timestamp of
				true->put("add15",0.5);
				false->ok
			end,
			case Player#player.exp20Add >= Timestamp of
				true->put("add20",1);
				false->ok
			end,
			case Player#player.exp30Add >= Timestamp of
				true->put("add30",2);
				false->ok
			end
	end,
	get("add15")+get("add20")+get("add30").



%%处理其它玩家查看自己的属性，返回一条自己的属性协议
onOtherLookSelf()->
	BaseInfoPackage = makePlayerBaseInfoMsg( getCurPlayerRecord() ),
	FunPet = fun( Pet )->
					 pet:makePetPropetryPackage(Pet)
			 end,
	PetPackage = lists:map(FunPet, pet:getPlayerPetList()),
	
%% 	PlayerActiveEquipList = equipment:getPlayerActivedEquipList(),
%% 	PlayerEquipList = lists:filter( fun(Equip)->
%% 											Equip#playerEquipItem.isEquiped =:= 1
%% 									end, PlayerActiveEquipList),
	PlayerEquipList = equipment:getPlayerEquipedEquipList(),
	
	FuncEquip = fun( Equip )->
						equipment:transPlayerEquipToMsg( Equip )
				end,
	EquipPackage = lists:map(FuncEquip, PlayerEquipList),
	
	{player:getCurPlayerProperty(#player.mapPID),
	 #pk_RequestLookPlayer_Result{
									   baseInfo=BaseInfoPackage,
									   petList=PetPackage,
									   equipList=EquipPackage,
									   fightCapacity=playerFightingCapacity:get_Fighting_Capacity_Top()}}.


add15ExpSeconds(Seconds) when Seconds > 0 ->
	Player = getCurPlayerRecord(),
	Timestamp = common:timestamp(),
	case Player of
		{}->false;
		_->
			case Player#player.exp15Add >= Timestamp of
				true->	SetTimestamp = Player#player.exp15Add+Seconds,						
					  	Seconds;
				false->	SetTimestamp = Timestamp+Seconds,
						Seconds
			end,			
			setCurPlayerProperty( #player.exp15Add, SetTimestamp),
			SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_Exp15Add, value=SetTimestamp}] },
			send( SendMsg )
	end.

add20ExpSeconds(Seconds) when Seconds > 0 ->
	Player = getCurPlayerRecord(),
	Timestamp = common:timestamp(),
	case Player of
		{}->false;
		_->
			case Player#player.exp20Add >= Timestamp of
				true->	SetTimestamp = Player#player.exp20Add+Seconds,						
					  	Seconds;
				false->	SetTimestamp = Timestamp+Seconds,
						Seconds
			end,			
			setCurPlayerProperty( #player.exp20Add, SetTimestamp),
			SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_Exp20Add, value=SetTimestamp}] },
			send( SendMsg )
	end.

add30ExpSeconds(Seconds) when Seconds > 0 ->
	Player = getCurPlayerRecord(),
	Timestamp = common:timestamp(),
	case Player of
		{}->false;
		_->
			case Player#player.exp30Add >= Timestamp of
				true->	SetTimestamp = Player#player.exp30Add+Seconds,						
					  	Seconds;
				false->	SetTimestamp = Timestamp+Seconds,
						Seconds
			end,			
			setCurPlayerProperty( #player.exp30Add, SetTimestamp),
			SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_Exp30Add, value=SetTimestamp}] },
			send( SendMsg )
	end.


%%激活码领取
on_ActiveCodeRequest( #pk_ActiveCodeRequest{ active_code= Active_code } = _MsgIn )->
	try
		
		Activecode_data_list = publicdbProcess:getActivecodeData( Active_code ),
		case Activecode_data_list of
			[]->throw( {return, ?ACTIVE_CODE_GET_FAIL_NOT_EXIST} );
			_->ok
		end,
		
		[Activecode_data|_] = Activecode_data_list,
		case Activecode_data#activecode_data.get_time =:= 0 of
			true->ok;
			false->throw( {return, ?ACTIVE_CODE_GET_FAIL_GETED} )
		end,

		ItemID = Activecode_data#activecode_data.item_id,
		ItemCount = Activecode_data#activecode_data.item_count,
		_ParamValue = Activecode_data#activecode_data.param,
		
		Activecode_data_list2 = publicdbProcess:getActivecodeDataByPlayerID( player:getCurPlayerID(), ItemID ),
		case Activecode_data_list2 of
			[]->ok;
			_->throw( {return, ?ACTIVE_CODE_GET_FAIL_INVALID} )
		end,
		
		ItemData = itemModule:getItemCfgDataByID( ItemID ),
		case ItemData of
			{}->throw( {return, ?ACTIVE_CODE_GET_FAIL_INVALID} );
			_->ok
		end,
		
		case ItemCount < 0 of
			true->throw( {return, ?ACTIVE_CODE_GET_FAIL_INVALID} );
			false->ok
		end,
		
		case playerItems:getPlayerBagSpaceCellCount(?Item_Location_Bag) > ItemCount of
			true->
				MyFunc = fun( _Record )->
								 playerItems:addItemToPlayerByItemDataID( ItemID, 1, true, ?Destroy_Item_Reson_ActiveCode)
						 end,
				common:for(1, ItemCount, MyFunc),
				
				publicdbProcess:updateActiveCode(netUsers:getCurUserID(), player:getCurPlayerID(), Active_code ),
				
				?LOG_OUT( "player[~p] get activecod[~p] ItemID[~p] ItemCount[~p] succ",
						  [player:getCurPlayerID(),
						  Active_code,
						  ItemID,
						  ItemCount] ),
				
				throw( {return, ?ACTIVE_CODE_GET_SUCC }),
				
				ok;
			false->
				throw( {return, ?ACTIVE_CODE_GET_FAIL_FULLBAG })
		end,

		ok
	catch
		{ return, ReturnCode }->
			?DEBUG_OUT( "on_ActiveCodeRequest Active_code[~p] player[~p] ReturnCode[~p]", 
								[Active_code, player:getCurPlayerID(), ReturnCode] ),
			MsgToUser = #pk_ActiveCodeResult{ result=ReturnCode },
			player:send( MsgToUser ),
			ok
	end.








