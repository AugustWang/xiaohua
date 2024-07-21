%% Author: Zhangdong
%% Created: 2012-8-8
%% Description: TODO: Add description to itemDB
-module(gmHandle).

%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% Include files
%%
-include("db.hrl").
-include("hdlt_logger.hrl").
-include("itemDefine.hrl").
-include("package.hrl").
-include("playerDefine.hrl").
-include("logdb.hrl").
-include("globalDefine.hrl").
-include("active_battle.hrl").

%%响应玩家GM指令
onMsgGM( StringCMD )->
	try
		StringTokens = string:tokens(StringCMD, " " ),
		case StringTokens of
			[]->throw(-1);
			_->ok
		end,

		PlayerRecord = player:getCurPlayerRecord(),
		ServerGMLevel = etsBaseFunc:getRecordField(?GlobalMainAtom, ?GlobalMainID, #globalMain.gmLevel),
		case PlayerRecord#player.gmLevel > ServerGMLevel of
			true->ok;
			false->throw(-1)
		end,
		
		CMDCount = length( StringTokens ),
		case CMDCount > 1 of
			true->[CMD|Params] = StringTokens;
			false->[CMD|_] = StringTokens, Params = []
		end,
		
		?DEBUG_OUT( "player[~p] cmd[~p] ", [player:getCurPlayerID(), CMD] ),
		
		case CMD of
			"#RandomEquip"->
				%equipment:onGM_RandomEquip(player:getCurPlayerID());
				PlayerID = player:getCurPlayerID(),
				PlayerRec=player:getPlayerRecord( PlayerID ),
				PlayerClass=PlayerRec#player.camp,
				equipment:onGM_RandomEquipWzy(PlayerID,PlayerClass );
				
%% 				AllPlayerID=player:getAllOnlinePlayerIDs(),
%% 				MyFunc = fun( IplayerID )->
%% 					IPid=player:getPlayerPID(IplayerID),
%% 					IPid!{randomEquip,IplayerID}
%% 				end,
%% 				lists:map(MyFunc, AllPlayerID);
			
				
			"#getitem"->
				ParamCount = length( Params ),
				case ParamCount < 1 of
					true->throw(-1);
					false->ok
				end,

				[ItemID|Params1] = Params,
				put( "onMsgGM_P1", -1 ),
				put( "onMsgGM_getitem_binded", false ),
				case Params1 of
					[]->ok;
					_->
						[Amount|Binded] = Params1,
						{Amount2, _} = string:to_integer( Amount ),
						put( "onMsgGM_P1", Amount2 ),
						case Binded of
							[]->ok;
							_->put( "onMsgGM_getitem_binded", true )
						end
				end,
				{ItemID2, _} = string:to_integer( ItemID ),
				playerItems:onMsgGMGetItem( ItemID2, get("onMsgGM_P1"), get("onMsgGM_getitem_binded") ),
				ok;
			"#money"->
				[Money|_] = Params,
				{MoneyValue, _} = string:to_integer( Money ),
				ParamTuple = #token_param{changetype = ?Money_Change_GM},
				playerMoney:addPlayerMoney(MoneyValue, ?Money_Change_GM,ParamTuple),
				
				SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_money, value=player:getCurPlayerProperty( #player.money )}] },
				player:send( SendMsg ),
				ok;
			"#moneyBinded"->
				[Money|_] = Params,
				{MoneyValue, _} = string:to_integer( Money ),
				ParamTuple = #token_param{changetype = ?Money_Change_GM},
				playerMoney:addPlayerBindedMoney(MoneyValue, ?Money_Change_GM,ParamTuple),
				
				SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_moneyBinded, value=player:getCurPlayerProperty( #player.moneyBinded )}] },
				player:send( SendMsg ),
				ok;
			"#level"->
				[Money|_] = Params,
				{MoneyValue, _} = string:to_integer( Money ),
				case MoneyValue <?Max_Player_Level_Cur of
					true->
						Level = MoneyValue;
					false->
						Level = ?Max_Player_Level_Cur
				end,
				player:setCurPlayerProperty(#player.level, Level ),
				
				SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_Level, value=player:getCurPlayerProperty(#player.level)}] },
				player:send( SendMsg ),
				
				player:onPlayerLevelChanged(),
				
				ok;
			"#addexp"->
				[Money|_] = Params,
				{EXPValue, _} = string:to_integer( Money ),
				ParamTuple = #exp_param{changetype = ?Exp_Change_GM},
				player:addPlayerEXP(EXPValue, ?Exp_Change_GM, ParamTuple ),			
				ok;
			"#gold"->
				[Money|_] = Params,
				{MoneyValue, _} = string:to_integer( Money ),
				ParamTuple = #token_param{changetype = ?Money_Change_GM},	
				playerMoney:addPlayerGold(MoneyValue, ?Money_Change_GM,ParamTuple),
				playerMoney:addPlayerBindedGold(MoneyValue, ?Money_Change_GM,ParamTuple),
				
				SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_gold, value=player:getCurPlayerProperty(#player.gold)}] },
				SendMsg2 = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_goldBinded, value=player:getCurPlayerProperty(#player.goldBinded)}] },
				player:send( SendMsg ),
				player:send( SendMsg2 ),
				ok;
			"#credit"->
				[Credit|_] = Params,
				{CreditValue, _} = string:to_integer( Credit ),
				
				player:setCurPlayerProperty(#player.credit, player:getCurPlayerProperty(#player.credit) + CreditValue ),
				
				SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_credit, value=player:getCurPlayerProperty(#player.credit)}] },
				player:send( SendMsg ),
				ok;
			"#honor"->
				[Honor|_] = Params,
				{HonorValue, _} = string:to_integer( Honor ),
				
				player:setCurPlayerProperty(#player.honor, player:getCurPlayerProperty(#player.honor) + HonorValue ),
				
				SendMsg = #pk_PlayerPropertyChanged{ changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_honor, value=player:getCurPlayerProperty(#player.honor)}] },
				player:send( SendMsg ),
				ok;
			"#queryequip"->
				[QueryTargetPlayerID|_] = Params,
				{QueryTargetPlayerIDValue, _} = string:to_integer( QueryTargetPlayerID ),
				equipment:onMsgQueryPlayerEquip(QueryTargetPlayerIDValue );
			"#droptest" ->
				[DropId|Params1] = Params,
				case DropId of
					[] -> ok;
					_->
						[Amount|_] = Params1,
						{Amount2, _} = string:to_integer( Amount ),
						{DropId2,_} = string:to_integer(DropId),
						drop:gmDropTest(DropId2, Amount2)
				end;
			"#drop" ->
				[DropId|_] = Params,
				{_DropId2,_} = string:to_integer(DropId);
				%%player:onDropItemToPlayer(DropId2, ?Get_Item_Reson_Pick);
			
			"#getmail" ->
				PlayerID = player:getCurPlayerID(),
				PlayerName = player:getPlayerProperty(PlayerID, #player.name),
				[Title|Params1] = Params,
				[Content|Params2] = Params1,
				[ItemID1|Params3] = Params2,
				{ItemID11, _} = string:to_integer( ItemID1 ),
				[Amount1|Params4] = Params3,
				{Amount11, _} = string:to_integer( Amount1 ),
				[Binded1|Params5] = Params4,
				{Binded11, _} = string:to_integer( Binded1 ),
				[ItemID2|Params6] = Params5,
				{ItemID21, _} = string:to_integer( ItemID2 ),
				[Amount2|Params7] = Params6,
				{Amount21, _} = string:to_integer( Amount2 ),
				[Binded2|Params8] = Params7,
				{Binded21, _} = string:to_integer( Binded2 ),
				[Money|_] = Params8,
				{Money1, _} = string:to_integer( Money ),
				mail:sendSystemMailToPlayer(PlayerID, PlayerName, Title, Content, ItemID11, Amount11, Binded11, ItemID21, Amount21, Binded21, Money1);
			"#refreshalltask" ->
				task:gmRefreshAllTask();
			"#gettask" ->
				PlayerID = player:getCurPlayerID(),
				[ID|_] = Params,
				{TaskID,_} = string:to_integer(ID),
				task:gmGetTaskByID(PlayerID, TaskID);
			"#getreputationtask" ->
				PlayerID = player:getCurPlayerID(),
				PlayerLevel=player:getCurPlayerProperty(#player.level),
				TaskID=task:genarateReputationTaskID(PlayerLevel),
				task:gmGetTaskByID(PlayerID, TaskID);
%% 			"#refresh" ->
%% 				PlayerID = player:getCurPlayerID(),
%% 				[ID|Params1] = Params,
%% 				[State|_] = Params1,
%% 				{TaskID,_} = string:to_integer(ID),
%% 				{TaskState,_} = string:to_integer(State),
%% 				task:gmRefreshOneTask(PlayerID, TaskID, TaskState);
%% %% 				TaskTable = task:getCurTaskTable();
%% %% 				etsBaseFunc:changeFiled(TaskTable, Key, #, Value)

			"#getpet" ->
				[PetId|_] = Params,
				{PetId2,_} = string:to_integer(PetId),
				Pet = pet:onCreatePet(PetId2),
				pet:sendOnePetToClient(Pet);
			"#addpetexp" ->
				[Exp|_] = Params,
				{Exp2,_} = string:to_integer(Exp),
				pet:addPetExp(Exp2, ?Exp_Change_GM);
			"#entermap"->
				[Exp|_] = Params,
				{MapDataID,_} = string:to_integer(Exp),
				player:sendMsgToMap( {enterMapByGM, player:getCurPlayerID(), MapDataID} );
			"#sysmsg" ->
				[Text|_] = Params,
				systemMessage:sendSysMsgToAllPlayer(Text);
			"#getmonster"->
				[MonsterID|_] = Params,
				{ MonsterID_Value, _ } = string:to_integer(MonsterID),
				player:sendMsgToMap( {playerMsg_CreateMonsterByGM, player:getCurPlayerID(), MonsterID_Value } );
			"#forbidlogin"->
				mainPID ! { onGm_forbidlogin };
			"#kickoutallplayers"->
				mainPID ! { onGm_KickOutAllPlayers };
			"#kickout"->
				ParamCount = length( Params ),
				case ParamCount =:= 1 of
					true->ok;
					false->throw(-1)
				end,

				[PlayerName|_] = Params,
				case player:getOnlinePlayerIDByName(PlayerName) of
					0 ->ok;
					PlayerID -> mainPID ! { kickoutByPlayerId, PlayerID}
				end;
			"#forbidchat"->
				ParamCount = length( Params ),
				case ParamCount =:= 2 of
					true->ok;
					false->throw(-1)
				end,
				[PlayerName|Params1] = Params,
				[ForbidChatFlagStr|_] = Params1,			
				case string:to_integer(ForbidChatFlagStr) of
					{error,_} ->ForbidChatFlag=0,throw(-1);
					{ ForbidChatFlag, _ } ->ok
				end,
						
				case player:getOnlinePlayerIDByName(PlayerName) of
					0 ->ok;
					PlayerID -> %% notify online player to modify forbidChatFlag
						player:sendMsgToPlayerProcess( PlayerID, {changeForbidChatFlag,ForbidChatFlag} )
				end,
				%% modify ForbidChatFlag in db
				mySqlProcess:update_forbidChatFlagByPlayerName(PlayerName,ForbidChatFlag);
			"#add15exp"->
				[Min|_] = Params,
				{Val, _} = string:to_integer( Min ),				
				player:add15ExpSeconds(Val*60),			
				ok;
			"#add20exp"->
				[Min|_] = Params,
				{Val, _} = string:to_integer( Min ),			
				player:add20ExpSeconds(Val*60),			
				ok;
			"#add30exp"->
				[Min|_] = Params,
				{Val, _} = string:to_integer( Min ),				
				player:add30ExpSeconds(Val*60),			
				ok;
			"#setworldvar"->
				[VarIndex|RemainParam] = Params,
				{IndexInt, _} = string:to_integer( VarIndex ),	
				[VarValue|_] = RemainParam,
				{ValueInt, _} = string:to_integer( VarValue ),	
				variant:setWorldVarValue(IndexInt, ValueInt),		
				ok;
			"#randomattack"->
				PlayerClass=player:getCurPlayerProperty(#player.camp),
				case PlayerClass of
					?Player_Class_Fighter->SillID = 1;
					?Player_Class_Shooter->SillID = 141;
					?Player_Class_Master->SillID = 281;
					?Player_Class_Pastor->SillID = 421;
					_->SillID = 0
				end,
				player:getCurPlayerProperty(#player.mapPID)!{gm_RandomAttack,player:getCurPlayerID(),SillID},
				ok;
			"#battleenroll"->
				case active_battle:canEnrollBattleActive(player:getCurPlayerID())  of
					?Cannot_Enroll_Success->
						active_battle:gm_enrollBattleActive(player:getCurPlayerID());
					Reason->
						active_battle:tellClientEnrollResult(player:getCurPlayerID(), Reason),
						ok
				end,
				ok;
			_->ok
		end,

		ok
	catch
		_->ok
	end,
	ok.


forbidLoginAndKickall() ->
	mainPID ! { onGm_forbidlogin },
	mainPID ! { onGm_KickOutAllPlayers },
	ok.	

