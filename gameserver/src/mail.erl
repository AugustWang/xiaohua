%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(mail).

%% add by wenziyong for gen server
-behaviour(gen_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%
%% Include files
%%
-include("mysql.hrl").
-include("db.hrl").
-include("itemDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("mailDefine.hrl").
-include("playerDefine.hrl").
-include("mapDefine.hrl").
-include("condition_compile.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("logdb.hrl").
-include("proto_ret.hrl").
-include("globalDefine.hrl").


%%
%% Exported Functions
%%
-compile(export_all).

start_link() ->
	gen_server:start_link({local,mailPID},?MODULE, [], [{timeout,?Start_Link_TimeOut_ms}]).



init([]) ->
	%register( mailPID, self() ),

	ets:new( ?MailTableAtom, [set,protected, named_table,  { keypos, #mailRecord.id  }] ),
	%put( "mailTable", MailTable ),

  	ets:new( ?MailItemTableAtom, [set,protected, named_table, { keypos, #r_itemDB.id  }] ),
	%put( "mailItemTable", MailItemTable ),

	ets:new( ?MailPlayerTableAtom, [set,protected, named_table, { keypos, #mailPlayer.id  }] ),
	%put( "mailPlayerTable", MailPlayer ),

	MailTimer_5 = ets:new( 'mailTimer_5', [ordered_set, protected, { keypos, #mailTimer.id }] ),
	put( "MailTimer_5", MailTimer_5 ),
	MailTimer_10 = ets:new( 'mailTimer_10', [ordered_set, protected, { keypos, #mailTimer.id }] ),
	put( "MailTimer_10", MailTimer_10 ),
	MailTimer_24 = ets:new( 'mailTimer_24', [ordered_set, protected, { keypos, #mailTimer.id }] ),
	put( "MailTimer_24", MailTimer_24 ),
	
	%timer:sleep( 1000*5 ),
	%mySqlProcess:sqldb_connect(pMail),
	getAllMailFromDB(),
	
	%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.mailPID, self() ),
	%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.mailTable, getMailTable() ),
	%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.mailPlayerTable, getMailPlayerTable() ),
	%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.mailItemTable, getMailItemTable()),
	
	%proc_lib:init_ack(self()),
	?DEBUG_OUT( "procMail started [~p]", [self()] ),
	erlang:send_after( ?Mail_Updater_Timer,self(), {timeUpdate} ),
	
    {ok, {}}.


handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.



terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.





%%返回邮件进程ID
getMailPID()->
	mailPID.



%%邮件进程循环
handle_info(Info, StateData)->	
	put("mailRecieve", true),

	try
	case Info of
		{quit}->
			?LOG_OUT("mailRecieve quit"),
			put("mailRecieve", false);
		{addMail, Msg}->
			onMsgAddMail(Msg);
		{recvMail, PlayerID, LockBagCell_1, LockBagCell_2, Msg}->
			onMsgRecvMail(PlayerID, LockBagCell_1, LockBagCell_2, Msg);
		{changeMailReadFlag, MailData}->
		  mailReadFlagChange(MailData);
		{deleteMail, _PlayerID, Msg}->
			doDeleteMail(Msg);
		{timeUpdate}->
			erlang:send_after( ?Mail_Updater_Timer,self(), {timeUpdate} ),
			updateMail();
		_->
			?LOG_OUT("mailRecieve unkown")
	end,
	case get("mailRecieve") of
		true->{noreply, StateData};
		false->{stop, normal, StateData}
	end

	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[?MODULE,_Why, erlang:get_stacktrace()] ),

			{noreply, StateData}
	end.




%%返回当前进程的邮件table
getMailTable()->
	?MailTableAtom.
%% 	MailTable = get("mailTable"),
%% 	case MailTable of
%% 		undefined ->db:getFiled(globalMain, ?GlobalMainID, #globalMain.mailTable);
%% 		_->MailTable
%% 	end.
%%返回当前进程的邮件物品table
getMailItemTable()->
	?MailItemTableAtom.
%% 	MailItemTable = get("mailItemTable"),
%% 	case MailItemTable of
%% 		undefined->db:getFiled(globalMain, ?GlobalMainID, #globalMain.mailItemTable);
%% 		_->MailItemTable
%% 	end.
%%返回当前进程的邮件玩家table
getMailPlayerTable()->
	?MailPlayerTableAtom.
%% 	MailPlayerTable = get("mailPlayerTable"),
%% 	case MailPlayerTable of
%% 		undefined->db:getFiled(globalMain, ?GlobalMainID, #globalMain.mailPlayerTable);
%% 		_->MailPlayerTable
%% 	end.

%%从DB读取所有邮件到内存
getAllMailFromDB()->
	?DEBUG_OUT( "begin getAllMailFromDB" ),
	
	MailTable = getMailTable(),
	MailItemTable = getMailItemTable(),
	
%% 	AllMailList = db:matchObject(mailRecord, #mailRecord{_='_'} ),
	AllMailList = mySqlProcess:get_allMail(),
	MyFunc = fun( Record )->
					 etsBaseFunc:insertRecord( MailTable, Record),
					 case Record#mailRecord.attachItemDBID1 of
						 0->ok;
						 _->
							 ItemDBData = itemModule:getItemDBDataByDBIDFromDB( Record#mailRecord.attachItemDBID1 ),
							 case ItemDBData of
								 {}->
									 ?ERROR_OUT( "getAllMailFromDB mail[~p] attachItemDBID1[~p] can not get from db", [Record#mailRecord.id, Record#mailRecord.attachItemDBID1] ),
									 etsBaseFunc:changeFiled( MailTable, Record#mailRecord.id, #mailRecord.attachItemDBID1, 0);
								 _->
									 etsBaseFunc:insertRecord( MailItemTable, ItemDBData )
							 end
					 end,
					 case Record#mailRecord.attachItemDBID2 of
						 0->ok;
						 _->
							 ItemDBData2 = itemModule:getItemDBDataByDBIDFromDB( Record#mailRecord.attachItemDBID2 ),
							 case ItemDBData2 of
								 {}->
									 ?ERROR_OUT( "getAllMailFromDB mail[~p] attachItemDBID2[~p] can not get from db", [Record#mailRecord.id, Record#mailRecord.attachItemDBID2] ),
									 etsBaseFunc:changeFiled( MailTable, Record#mailRecord.id, #mailRecord.attachItemDBID2, 0);
								 _->
									 etsBaseFunc:insertRecord( MailItemTable, ItemDBData2 )
							 end
					 end,
					 updateMailPlayerByAdd( Record ),
					 onAddMailToTimer( Record ),
					 ok
			 end,
	lists:map( MyFunc, AllMailList ),
	
	MailSize = ets:info( MailTable, size),
	MailItemSize = ets:info( MailItemTable, size),
	MailPlayerSize = ets:info( getMailPlayerTable(), size),
	?DEBUG_OUT( "getAllMailFromDB MailSize[~p] MailItemSize[~p] MailPlayerSize[~p] ", [MailSize, MailItemSize, MailPlayerSize] ),
	ok.

%%返回某邮件是否有附件
%% return true if has attach
hasAttach( MailData )->
	(MailData#mailRecord.attachItemDBID1 =/= 0 ) or (MailData#mailRecord.attachItemDBID2 =/= 0 ) or (MailData#mailRecord.moneySend =/= 0 ).

%%新增邮件时玩家邮件数据跟新
updateMailPlayerByAdd( MailData )->
	put( "updateMailPlayerByAdd", 0 ),
	case hasAttach( MailData ) of
		true->put( "updateMailPlayerByAdd", 1 );
		false->ok
	end,
	
	HasAttachMailCount = get( "updateMailPlayerByAdd" ),
	
	MailPlayerTable = getMailPlayerTable(),
	MailPlayerData = etsBaseFunc:readRecord( MailPlayerTable, MailData#mailRecord.recvPlayerID ),
	case MailPlayerData of
		{}->
			MailPlayer = #mailPlayer{ id=MailData#mailRecord.recvPlayerID, mailIDList=[MailData#mailRecord.id], allMailCount=1, hasAttachMailCount=HasAttachMailCount },
			etsBaseFunc:insertRecord( MailPlayerTable, MailPlayer ),
			ok;
		_->
			etsBaseFunc:changeFiled( MailPlayerTable, MailData#mailRecord.recvPlayerID, #mailPlayer.mailIDList, MailPlayerData#mailPlayer.mailIDList ++ [MailData#mailRecord.id] ),
			etsBaseFunc:changeFiled( MailPlayerTable, MailData#mailRecord.recvPlayerID, #mailPlayer.allMailCount, MailPlayerData#mailPlayer.allMailCount + 1 ),
			etsBaseFunc:changeFiled( MailPlayerTable, MailData#mailRecord.recvPlayerID, #mailPlayer.hasAttachMailCount, MailPlayerData#mailPlayer.hasAttachMailCount + HasAttachMailCount ),
			ok
	end,
	%Record = etsBaseFunc:readRecord(MailPlayerTable, MailData#mailRecord.recvPlayerID),
%% 	db:writeRecord(Record),
	
	ok.

%%新增邮件时，增加邮件时间列表
onAddMailToTimer( MailData )->
	case MailData#mailRecord.mailTimerType of
		?MaileTimer_5->etsBaseFunc:insertRecord( get("MailTimer_5"), #mailTimer{id=MailData#mailRecord.id, time=MailData#mailRecord.tiemOut} );
		?MaileTimer_10->etsBaseFunc:insertRecord( get("MailTimer_10"), #mailTimer{id=MailData#mailRecord.id, time=MailData#mailRecord.tiemOut} );
		?MaileTimer_24->etsBaseFunc:insertRecord( get("MailTimer_24"), #mailTimer{id=MailData#mailRecord.id, time=MailData#mailRecord.tiemOut} );
		_->ok
	end,
	ok.

%%删除邮件时，删除邮件时间列表
onDeleteMailToTimer( MailData )->
	case MailData#mailRecord.mailTimerType of
		?MaileTimer_5->etsBaseFunc:deleteRecord( get("MailTimer_5"), MailData#mailRecord.id );
		?MaileTimer_10->etsBaseFunc:deleteRecord( get("MailTimer_10"), MailData#mailRecord.id );
		?MaileTimer_24->etsBaseFunc:deleteRecord( get("MailTimer_24"), MailData#mailRecord.id );
		_->ok
	end,
	ok.

%%返回某玩家可接收普通邮件数量
getPlayerCanRecvNormalMailCount( PlayerID )->
	MailPlayerData = etsBaseFunc:readRecord( getMailPlayerTable(), PlayerID ),
	case MailPlayerData of
		{}->?Max_Player_Mail_Count;
		_->
			case MailPlayerData#mailPlayer.allMailCount >= ?Max_Player_Mail_Count of
				true->0;
				false->?Max_Player_Mail_Count - MailPlayerData#mailPlayer.allMailCount
			end
	end.

onPlayerMsgSendMail_DBCallBack( _PlayerID, _Param1, _Param2, _Param3 )->
	ok.

%% modify for insert mysql directly
%%玩家进程，处理玩家发送邮件消息
%onPlayerMsgSendMail( #pk_RequestSendMail{}=Msg, IsDBCallBack )->
onPlayerMsgSendMail( #pk_RequestSendMail{}=Msg)->
	put( "onMsgSendMail_Return", ?SendMailResult_Succ ),
	try
		put( "onPlayerMsgSendMail_TargetPlayerID", Msg#pk_RequestSendMail.targetPlayerID ),
		case Msg#pk_RequestSendMail.targetPlayerID =:= 0 of
			true->
				PlayerID = mySqlProcess:isPlayerExistByName( Msg#pk_RequestSendMail.targetPlayerName ),
				case PlayerID =:= 0 of
					true->
						put( "onMsgSendMail_Return", ?SendMailResult_Fail_TargetUnvalid ),
						TargetPlayerID = 0,
						throw(-1);
					false->
						TargetPlayerID = PlayerID
				end;
			false->
				TargetPlayerID = Msg#pk_RequestSendMail.targetPlayerID
		end,
		

		case player:getCurPlayerID() =:= TargetPlayerID of
			true->put( "onMsgSendMail_Return", ?SendMailResult_Fail_SendDataUnvalid ),throw(-1);
			false->ok
		end,

%% 		MailPID = db:getFiled( globalMain, ?GlobalMainID, #globalMain.mailPID ),
%% 		case MailPID of
%% 			0->put( "onMsgSendMail_Return", ?SendMailResult_Fail_SystemBusy ),throw(-1);
%% 			_->ok
%% 		end,

		case Msg#pk_RequestSendMail.moneySend >= 0 of
			false->put( "onMsgSendMail_Return", ?SendMailResult_Fail_SendMoney ),throw(-1);
			true->
				case playerMoney:canDecPlayerMoney( Msg#pk_RequestSendMail.moneySend ) of
					false->put( "onMsgSendMail_Return", ?SendMailResult_Fail_SendMoney ),throw(-1);
					true->ok
				end
		end,

		case ( Msg#pk_RequestSendMail.moneyPay < 0 ) or (Msg#pk_RequestSendMail.moneyPay >= ?Max_Money) of
			true->put( "onMsgSendMail_Return", ?SendMailResult_Fail_SendDataUnvalid ),throw(-1);
			false->ok
		end,

		case string:len( Msg#pk_RequestSendMail.strTitle ) > ?Max_Mail_Title_Len of
			true->put( "onMsgSendMail_Return", ?SendMailResult_Fail_SendDataUnvalid ),throw(-1);
			false->ok
		end,
		case forbidden:checkForbidden(Msg#pk_RequestSendMail.strTitle) of
			true->put( "onMsgSendMail_Return", ?SendMailResult_Fail_SendForbiddenString ),throw(-1);
			false->ok
		end,
			
		case string:len( Msg#pk_RequestSendMail.strContent ) > ?Max_Mail_Content_Len of
			true->put( "onMsgSendMail_Return", ?SendMailResult_Fail_SendDataUnvalid ),throw(-1);
			false->ok
		end,
		
		case forbidden:checkForbidden(Msg#pk_RequestSendMail.strContent) of
			true->put( "onMsgSendMail_Return", ?SendMailResult_Fail_SendForbiddenString ),throw(-1);
			false->ok
		end,
		
		case Msg#pk_RequestSendMail.attachItemDBID1 =:= Msg#pk_RequestSendMail.attachItemDBID2 of
			true -> %%two attachments is the same item
				AttachItem1 = itemModule:getItemDBDataByDBID( Msg#pk_RequestSendMail.attachItemDBID1 ),
				AttachItem2 = {},
				case AttachItem1 of
					{}->ok;
					_->
						case isItemCanBeSendToMail( AttachItem1, Msg#pk_RequestSendMail.attachItem1Cnt+Msg#pk_RequestSendMail.attachItem2Cnt) of
							false->put( "onMsgSendMail_Return", ?SendMailResult_Fail_SendItem ),throw(-1);
							true->ok
						end
				end;
			false ->			
				AttachItem1 = itemModule:getItemDBDataByDBID( Msg#pk_RequestSendMail.attachItemDBID1 ),
				case AttachItem1 of
					{}->ok;
					_->
						case isItemCanBeSendToMail( AttachItem1, Msg#pk_RequestSendMail.attachItem1Cnt) of
							false->put( "onMsgSendMail_Return", ?SendMailResult_Fail_SendItem ),throw(-1);
							true->ok
						end
				end,
		
				AttachItem2 = itemModule:getItemDBDataByDBID( Msg#pk_RequestSendMail.attachItemDBID2 ),
				case AttachItem2 of
					{}->ok;
					_->
						case isItemCanBeSendToMail( AttachItem2,Msg#pk_RequestSendMail.attachItem2Cnt ) of
							false->put( "onMsgSendMail_Return", ?SendMailResult_Fail_SendItem ),throw(-1);
							true->ok
						end
				end
		end,

		case getPlayerCanRecvNormalMailCount( TargetPlayerID ) > 0 of
			false->put( "onMsgSendMail_Return", ?SendMailResult_Fail_TargetFull ),throw(-1);
			true->ok
		end,

		%%检查完了，开始扣
		case Msg#pk_RequestSendMail.moneySend > 0 of
			false->ok;
			true->
				ParamTuple = #token_param{changetype = ?Money_Change_MailSend},
				playerMoney:decPlayerMoney(Msg#pk_RequestSendMail.moneySend, ?Money_Change_MailSend, ParamTuple)
		end,
		
		case Msg#pk_RequestSendMail.attachItemDBID1 =:= Msg#pk_RequestSendMail.attachItemDBID2 of
			true -> %%two attachments is the same item
				put( "onPlayerMsgSendMail_AttachItem1", AttachItem1 ),
				put( "onPlayerMsgSendMail_AttachItem2", {} ),
				TotalCnt = Msg#pk_RequestSendMail.attachItem1Cnt + Msg#pk_RequestSendMail.attachItem2Cnt,
				case AttachItem1 of
					{}->ok;
					_->
						case TotalCnt < AttachItem1#r_itemDB.amount of
				 			true ->AttachItem1_new = playerItems:splitItem(AttachItem1, TotalCnt),
								   case AttachItem1_new of
									   {}->AttachItem1_new2 = AttachItem1_new;
									   _->AttachItem1_new1 = setelement( #r_itemDB.owner_type, AttachItem1_new,?item_owner_type_mail ),
										  AttachItem1_new2 = setelement( #r_itemDB.owner_id, AttachItem1_new1,?Item_Owner_Mail_ID )
								   end,
								   put( "onPlayerMsgSendMail_AttachItem1", AttachItem1_new2 );
								  %% ItemAmountChanged msg is sent in splitItem
							false->
								   AttachItem12 = itemModule:changeItemOwner( AttachItem1, ?item_owner_type_mail, ?Item_Owner_Mail_ID, ?Destroy_Item_Reson_SendMail ),
								   put( "onPlayerMsgSendMail_AttachItem1", AttachItem12 )
								   %% Item destroy msg is sent in changeItemOwner
								   %player:send( #pk_PlayerDestroyItem{ itemDBID=AttachItem1#r_itemDB.id, reson=?Destroy_Item_Reson_SendMail } )
						end		
				end;
			false ->
				put( "onPlayerMsgSendMail_AttachItem1", AttachItem1 ),
				case AttachItem1 of
					{}->ok;
					_->
						case Msg#pk_RequestSendMail.attachItem1Cnt < AttachItem1#r_itemDB.amount of
				 			true ->AttachItem1_new = playerItems:splitItem(AttachItem1, Msg#pk_RequestSendMail.attachItem1Cnt),
								   case AttachItem1_new of
									   {}->AttachItem1_new2 = AttachItem1_new;
									   _->AttachItem1_new1 = setelement( #r_itemDB.owner_type, AttachItem1_new,?item_owner_type_mail ),
										  AttachItem1_new2 = setelement( #r_itemDB.owner_id, AttachItem1_new1,?Item_Owner_Mail_ID )
								   end,
								   put( "onPlayerMsgSendMail_AttachItem1", AttachItem1_new2 );
								  %% ItemAmountChanged msg is sent in splitItem
							false->
								   AttachItem12 = itemModule:changeItemOwner( AttachItem1, ?item_owner_type_mail, ?Item_Owner_Mail_ID, ?Destroy_Item_Reson_SendMail ),
								   put( "onPlayerMsgSendMail_AttachItem1", AttachItem12 )
								   %% Item destroy msg is sent in changeItemOwner
								   %player:send( #pk_PlayerDestroyItem{ itemDBID=AttachItem1#r_itemDB.id, reson=?Destroy_Item_Reson_SendMail } )
						end		
				end,
				put( "onPlayerMsgSendMail_AttachItem2", AttachItem2 ),
				case AttachItem2 of
					{}->ok;
					_->
						case Msg#pk_RequestSendMail.attachItem2Cnt < AttachItem2#r_itemDB.amount of
				 			true ->AttachItem2_new = playerItems:splitItem(AttachItem2, Msg#pk_RequestSendMail.attachItem2Cnt),
								   case AttachItem2_new of
									   {}->AttachItem2_new2 = AttachItem2_new;
									   _->AttachItem2_new1 = setelement( #r_itemDB.owner_type, AttachItem2_new,?item_owner_type_mail ),
										  AttachItem2_new2 = setelement( #r_itemDB.owner_id, AttachItem2_new1,?Item_Owner_Mail_ID )
								   end,
								   put( "onPlayerMsgSendMail_AttachItem2", AttachItem2_new2 );
									%% ItemAmountChanged msg is sent in splitItem
							false->
								   AttachItem22 = itemModule:changeItemOwner( AttachItem2, ?item_owner_type_mail, ?Item_Owner_Mail_ID, ?Destroy_Item_Reson_SendMail ),
								   put( "onPlayerMsgSendMail_AttachItem2", AttachItem22 )
								   %% Item destroy msg is sent in changeItemOwner
								   %player:send( #pk_PlayerDestroyItem{ itemDBID=AttachItem2#r_itemDB.id, reson=?Destroy_Item_Reson_SendMail } )
						end
				end
		end,

		MailAdd = #mailRecord{  id=0,
							  	type=?Mail_Type_Normal,
								recvPlayerID=TargetPlayerID,
								isOpened=0,
								tiemOut=0,
								idSender=player:getCurPlayerID(),
								nameSender=player:getCurPlayerProperty(#player.name),
								title=Msg#pk_RequestSendMail.strTitle,
								content=Msg#pk_RequestSendMail.strContent,
								attachItemDBID1=get("onPlayerMsgSendMail_AttachItem1"),
								attachItemDBID2=get("onPlayerMsgSendMail_AttachItem2"),
								moneySend=Msg#pk_RequestSendMail.moneySend,
								moneyPay=Msg#pk_RequestSendMail.moneyPay,
								mailTimerType=?MaileTimer_5,
								mailRecTime = common:timestamp()
							},
		mailPID ! { addMail, MailAdd },
		
%% 		player:getPlayerPID(Msg#pk_RequestSendMail.targetPlayerID) ! {}
		
		%%补充log
		?DEBUG_OUT( "player [~p] send mail to mailProcess sucess", [player:getCurPlayerID()] ),
		ResultMsg = #pk_RequestSendMailAck{result = get("onMsgSendMail_Return")},
		player:sendToPlayer(player:getCurPlayerID(), ResultMsg )
	catch
		_->
			Return = get( "onMsgSendMail_Return" ),
			case Return of
				?SendMailResult_Switch_Process ->
					ok;
				_ ->
					Result = #pk_RequestSendMailAck{result = Return},
					player:sendToPlayer(player:getCurPlayerID(), Result )
			end
	end.

%%返回某物品能否被邮寄
isItemCanBeSendToMail( ItemDBData,Cnt )->
	try
		case ItemDBData#r_itemDB.location =:= ?Item_Location_Bag of
			false->throw(-1);
			true->ok
		end,

		case ItemDBData#r_itemDB.binded of
			true->throw(-1);
			false->ok
		end,

		%%
		case playerItems:canMail(ItemDBData#r_itemDB.item_data_id) of
			true->ok;
			_->throw(-1)
		end,
		
		case playerItems:isLockedPlayerBagCell( ItemDBData#r_itemDB.location, ItemDBData#r_itemDB.cell ) of
			true->throw(-1);
			false->ok
		end,
		
		case (Cnt > ItemDBData#r_itemDB.amount) or (Cnt =< 0) of
			true -> throw(-1);
			false->ok
		end,

		true
	catch
		_->false
	end.

%%邮件进程，处理发送邮件
onMsgAddMail( #mailRecord{}=MailAdd )->
	try
		MailPlayerData = etsBaseFunc:readRecord( getMailPlayerTable(), MailAdd#mailRecord.recvPlayerID ),
		case MailPlayerData of
			{}->
				case mySqlProcess:isPlayerExistById( MailAdd#mailRecord.recvPlayerID ) of
					0->
						?ERROR_OUT( "onMsgAddMail not exist recvPlayerID[~p]", [MailAdd#mailRecord.recvPlayerID] ),
						throw(-1);
					_->ok
				end,
				MailPlayer = #mailPlayer{ id=MailAdd#mailRecord.recvPlayerID, mailIDList=[], allMailCount=0, hasAttachMailCount=0 },
				etsBaseFunc:insertRecord( getMailPlayerTable(), MailPlayer );
			_->ok
		end,
		
		%% add by wenziyong, MailAdd 's attachItemDBID1 and attachItemDBID2  is a item, not id, so can't revoke hasAttach to judge whether has attachment
		%% But attachItemDBID1 and attachItemDBID2  of getMailTable 's mail iks id
		%MailHasAttach = hasAttach( MailAdd ),
		case (MailAdd#mailRecord.attachItemDBID1 =/= {} ) or (MailAdd#mailRecord.attachItemDBID2 =/= {} ) or (MailAdd#mailRecord.moneySend =/= 0 ) of
			true ->MailHasAttach = true;
			false -> MailHasAttach = false
		end,
		
		MailPlayerData2 = etsBaseFunc:readRecord( getMailPlayerTable(), MailAdd#mailRecord.recvPlayerID ),
		case ( MailPlayerData2#mailPlayer.allMailCount >= ?Max_Player_Mail_Count ) andalso
			 ( MailPlayerData2#mailPlayer.hasAttachMailCount >= ?Max_Player_Mail_Count ) andalso
			 ( not MailHasAttach ) of
			true->
				%%玩家邮箱已满，且带附件的邮件数量也满，且新邮件不带附件，直接抛弃
				?ERROR_OUT( "onMsgAddMail full to giveup target[~p]", [MailAdd#mailRecord.recvPlayerID] ),
				throw(-1);
			false->ok
		end,
		
		case ( MailPlayerData2#mailPlayer.allMailCount >= ?Max_Player_Mail_Count ) andalso
			 ( MailPlayerData2#mailPlayer.hasAttachMailCount < ?Max_Player_Mail_Count ) of
			false->ok;
			true->
				%%需要删除一封没有附件的邮件
				try
					MyFunc = fun( Record )->
									 Mail = etsBaseFunc:readRecord( getMailPlayerTable(), Record ),
									 case Mail of
										 {}->ok;
										 _->
											 case hasAttach( Mail ) of
												 true->ok;
												 false->
													 doDeleteMail( Record ),
													 throw(-1)
											 end
									 end
							 end,
					lists:map( MyFunc, MailPlayerData2#mailPlayer.mailIDList ),
					ok
				catch
					_->ok
				end,
				ok
		end,
		
		MailAdd1 = setelement( #mailRecord.id, MailAdd,db:memKeyIndex(mailrecord)  ),% persistent
		
		put( "onMsgAddMail_Time", 0 ),
		put( "onMsgAddMail_TimerType", ?MaileTimer_5 ),
		
		case MailAdd#mailRecord.moneyPay > 0 of
			true->
				put( "onMsgAddMail_TimerType", ?MaileTimer_24 ),
				put( "onMsgAddMail_Time", ?Time_Pay_Mail );
			false->
				case MailHasAttach of
					true->
						put( "onMsgAddMail_TimerType", ?MaileTimer_10 ),
						put( "onMsgAddMail_Time", ?Time_Mail_Attach );			
					false->
						put( "onMsgAddMail_TimerType", ?MaileTimer_5 ),
						put( "onMsgAddMail_Time", ?Time_Mail_NoAttach )
						
				end
		end,
		
		MailAdd2 = setelement( #mailRecord.tiemOut, MailAdd1, common:timestamp() + get( "onMsgAddMail_Time" ) ),
		MailAdd3 = setelement( #mailRecord.mailTimerType, MailAdd2, get( "onMsgAddMail_TimerType" ) ),

		put( "onMsgAddMail_attachItemDBID1", 0 ),
		case MailAdd3#mailRecord.attachItemDBID1 of
			{}->ok;
			_->
				put( "onMsgAddMail_attachItemDBID1", MailAdd3#mailRecord.attachItemDBID1#r_itemDB.id ),
				etsBaseFunc:insertRecord( getMailItemTable(), MailAdd3#mailRecord.attachItemDBID1 )
		end,
		put( "onMsgAddMail_attachItemDBID2", 0 ),
		case MailAdd3#mailRecord.attachItemDBID2 of
			{}->ok;
			_->
				put( "onMsgAddMail_attachItemDBID2", MailAdd3#mailRecord.attachItemDBID2#r_itemDB.id ),
				etsBaseFunc:insertRecord( getMailItemTable(), MailAdd3#mailRecord.attachItemDBID2 )
		end,

		MailAdd4 = setelement( #mailRecord.attachItemDBID1, MailAdd3, get( "onMsgAddMail_attachItemDBID1" ) ),
		MailAdd5 = setelement( #mailRecord.attachItemDBID2, MailAdd4, get( "onMsgAddMail_attachItemDBID2" ) ),
		
		%%存盘
%% 		db:writeRecord( MailAdd5 ),
		mySqlProcess:insertMailRecord(MailAdd5),
		etsBaseFunc:insertRecord( getMailTable(), MailAdd5 ),

		%%更新玩家邮件列表
		updateMailPlayerByAdd( MailAdd5 ),

		%%增加邮件进时间列表
		onAddMailToTimer( MailAdd5 ),

		%%send to player
		case player:getPlayerIsOnlineByID(MailAdd5#mailRecord.recvPlayerID) of%%等处理了玩家在线信息后再处理true消息
			false->
				ok;
			true->
				Msg = #pk_InformNewMail{},
				player:sendMsgToPlayerProcess(MailAdd5#mailRecord.recvPlayerID, {informNewMail, Msg})
		end,
		
		logdbProcess:write_log_mail_change(?Mail_Change_Type_Add,MailAdd5),

		%%成功，补充log
		?DEBUG_OUT( "Mail [~p] send to player [~p] success,", [MailAdd5#mailRecord.id, MailAdd5#mailRecord.recvPlayerID] ),
		ok
	catch
		_->
		%%失败，异常了
		?ERROR_OUT( "Mail [~p] send to player [~p] fail,", [MailAdd#mailRecord.id, MailAdd#mailRecord.recvPlayerID] ),
		ok
	end.

%%其他进程，发送系统邮件给玩家，完整参数
sendSystemMailToPlayer( RecvPlayerID, NameSender, Title, Content, ItemID1, ItemAmount1, ItemBinded1, ItemID2, ItemAmount2, ItemBinded2, MoneySend )->
	put( "sendSystemMailToPlayer_Return", 0 ),
	try
%% 		MailPID = db:getFiled( globalMain, ?GlobalMainID, #globalMain.mailPID ),
%% 		case MailPID of
%% 			0->put( "sendSystemMailToPlayer_Return", ?SendMailResult_Fail_SystemBusy ),throw(-1);
%% 			_->ok
%% 		end,

		case ( MoneySend >= 0 ) andalso ( MoneySend =< ?Max_Money ) of
			false->put( "sendSystemMailToPlayer_Return", ?SendMailResult_Fail_SendMoney ),throw(-1);
			true->ok
		end,

		case string:len( Title ) > ?Max_Mail_Title_Len of
			true->put( "sendSystemMailToPlayer_Return", ?SendMailResult_Fail_SendDataUnvalid ),throw(-1);
			false->ok
		end,

		case string:len( Content ) > ?Max_Mail_Content_Len of
			true->put( "sendSystemMailToPlayer_Return", ?SendMailResult_Fail_SendDataUnvalid ),throw(-1);
			false->ok
		end,

		MailPlayerData = etsBaseFunc:readRecord( ?MailPlayerTableAtom, RecvPlayerID ),
		case MailPlayerData of
			{}->ok;
			_->
				case MailPlayerData#mailPlayer.hasAttachMailCount >= ?Max_Player_Mail_Count of
					true->
						%%目标玩家邮箱已满，抛弃，补充log
						put( "sendSystemMailToPlayer_Return", ?SendMailResult_Fail_TargetFull ),throw(-1);
					false->ok
				end
		end,	
		
		put( "sendSystemMailToPlayer_Item1", {} ),
		case ItemID1 > 0 of
			false->ok;
			true->
				AttachItem1 = itemModule:initItemDBDataByItemID( ItemID1 ),
				case AttachItem1 of
					{}->put( "sendSystemMailToPlayer_Return", ?SendMailResult_Fail_SendDataUnvalid ),throw(-1);
					_->
						case ( not (AttachItem1#r_itemDB.amount =:= ItemAmount1) ) andalso
							 ( ItemAmount1 > 0 ) andalso ( ItemAmount1 < AttachItem1#r_itemDB.amount ) of
							false->
									put( "sendSystemMailToPlayer_Item1", AttachItem1 );
							true->
									AttachItem2 = setelement( #r_itemDB.amount, AttachItem1, ItemAmount1),
									put( "sendSystemMailToPlayer_Item1", AttachItem2 )
						end,
						case ItemBinded1 of
							true->
								AttachItem3 = get( "sendSystemMailToPlayer_Item1" ),
								AttachItem4 = setelement( #r_itemDB.binded, AttachItem3, ItemBinded1 ),
								put( "sendSystemMailToPlayer_Item1", AttachItem4 );
							false->ok;
							_->ok
					    end,
						AttachItem5 = get( "sendSystemMailToPlayer_Item1" ),
						AttachItem6 = setelement( #r_itemDB.owner_type, AttachItem5, ?item_owner_type_mail ),
						AttachItem7 = setelement( #r_itemDB.owner_id, AttachItem6, ?Item_Owner_Mail_ID ),
						mySqlProcess:insertOrReplaceR_itemDB(AttachItem7,false),
						put( "sendSystemMailToPlayer_Item1", AttachItem7 )
				end
		end,
		
		put( "sendSystemMailToPlayer_Item2", {} ),
		case ItemID2 > 0 of
			false->ok;
			true->
				AttachItem21 = itemModule:initItemDBDataByItemID( ItemID2 ),
				case AttachItem21 of
					{}->put( "sendSystemMailToPlayer_Return", ?SendMailResult_Fail_SendDataUnvalid ),throw(-1);
					_->
						case ( not (AttachItem21#r_itemDB.amount =:= ItemAmount2) ) andalso
							 ( ItemAmount2 > 0 ) andalso ( ItemAmount2 < AttachItem21#r_itemDB.amount ) of
							false->ok;
							true->
									AttachItem22 = setelement( #r_itemDB.amount, AttachItem21, ItemAmount2),
									put( "sendSystemMailToPlayer_Item2", AttachItem22 )
						end,
						case ItemBinded2 of
							true->
								AttachItem23 = get( "sendSystemMailToPlayer_Item2" ),
								AttachItem24 = setelement( #r_itemDB.binded, AttachItem23, ItemBinded2 ),
								put( "sendSystemMailToPlayer_Item2", AttachItem24 );
							false->ok;
							_->ok
					    end,
						AttachItem25 = get( "sendSystemMailToPlayer_Item2" ),
						AttachItem26 = setelement( #r_itemDB.owner_type, AttachItem25, ?item_owner_type_mail ),
						AttachItem27 = setelement( #r_itemDB.owner_id, AttachItem26, ?Item_Owner_Mail_ID ),
						mySqlProcess:insertOrReplaceR_itemDB(AttachItem27,false),
						put( "sendSystemMailToPlayer_Item2", AttachItem27 )
				end
		end,
		
		MailAdd = #mailRecord{  id=0,
							  	type=?Mail_Type_System,
								recvPlayerID=RecvPlayerID,
								isOpened=0,
								tiemOut=0,
								idSender=?MailSenderID_System,
								nameSender=NameSender,
								title=Title,
								content=Content,
								attachItemDBID1=get( "sendSystemMailToPlayer_Item1" ),
								attachItemDBID2=get( "sendSystemMailToPlayer_Item2" ),
								moneySend=MoneySend,
								moneyPay=0,
								mailTimerType=?MaileTimer_5,
								mailRecTime = common:timestamp()
							},
		mailPID ! { addMail, MailAdd },

		%%发送成功
		?SendMailResult_Succ
	catch
		_:Why->
		Return = get( "sendSystemMailToPlayer_Return" ),
		%%失败，补充log
		?ERROR_OUT( "sendSystemMailToPlayer fail,err code:~p,RecvPlayerID:~p, ItemID1:~p, ItemAmount1:~p, ItemBinded1:~p, ItemID2:~p, ItemAmount2:~p, ItemBinded2:~p, MoneySend:~p,Why:~p",
			[Return,RecvPlayerID,  ItemID1, ItemAmount1, ItemBinded1, ItemID2, ItemAmount2, ItemBinded2, MoneySend,Why] ),

		
		Return
	end.

%%其他进程，发送系统邮件给玩家，其中item为已有记录
sendSystemMailToPlayer_ItemRecord( RecvPlayerID, NameSender, Title, Content, ItemRecord1, ItemRecord2, MoneySend)->
	put( "sendSystemMailToPlayer_Return", 0 ),
	try
%% 		MailPID = db:getFiled( globalMain, ?GlobalMainID, #globalMain.mailPID ),
%% 		case MailPID of
%% 			0->put( "sendSystemMailToPlayer_Return", ?SendMailResult_Fail_SystemBusy ),throw(-1);
%% 			_->ok
%% 		end,

		case ( MoneySend >= 0 ) andalso ( MoneySend =< ?Max_Money ) of
			false->put( "sendSystemMailToPlayer_Return", ?SendMailResult_Fail_SendMoney ),throw(-1);
			true->ok
		end,

		case string:len( Title ) > ?Max_Mail_Title_Len of
			true->put( "sendSystemMailToPlayer_Return", ?SendMailResult_Fail_SendDataUnvalid ),throw(-1);
			false->ok
		end,

		case string:len( Content ) > ?Max_Mail_Content_Len of
			true->put( "sendSystemMailToPlayer_Return", ?SendMailResult_Fail_SendDataUnvalid ),throw(-1);
			false->ok
		end,

		MailPlayerData = etsBaseFunc:readRecord( ?MailPlayerTableAtom, RecvPlayerID ),
		case MailPlayerData of
			{}->ok;
			_->
				case MailPlayerData#mailPlayer.hasAttachMailCount >= ?Max_Player_Mail_Count of
					true->
						%%目标玩家邮箱已满，抛弃，补充log
						put( "sendSystemMailToPlayer_Return", ?SendMailResult_Fail_TargetFull ),throw(-1);
					false->ok
				end
		end,	
		
		put( "sendSystemMailToPlayer_Item1", {} ),
		case ItemRecord1 of
			{}->put( "sendSystemMailToPlayer_Return", ?SendMailResult_Fail_SendDataUnvalid ),throw(-1);
			_->
				AttachItem6 = setelement( #r_itemDB.owner_type, ItemRecord1, ?item_owner_type_mail ),
				AttachItem7 = setelement( #r_itemDB.owner_id, AttachItem6, ?Item_Owner_Mail_ID ),
%% 				db:writeRecord(AttachItem7),
				itemModule:saveItemDB( AttachItem7),
				put( "sendSystemMailToPlayer_Item1", AttachItem7 )
		end,
		
		put( "sendSystemMailToPlayer_Item2", {} ),
		case ItemRecord2 of
			{}->put( "sendSystemMailToPlayer_Return", ?SendMailResult_Fail_SendDataUnvalid ),
				ok;
			_->
				AttachItem26 = setelement( #r_itemDB.owner_type, ItemRecord2, ?item_owner_type_mail ),
				AttachItem27 = setelement( #r_itemDB.owner_id, AttachItem26, ?Item_Owner_Mail_ID ),
%% 				db:writeRecord(AttachItem27),
				itemModule:saveItemDB( AttachItem27),
				put( "sendSystemMailToPlayer_Item2", AttachItem27 )
		end,
		
		MailAdd = #mailRecord{  id=0,
							  	type=?Mail_Type_System,
								recvPlayerID=RecvPlayerID,
								isOpened=0,
								tiemOut=0,
								idSender=?MailSenderID_System,
								nameSender=NameSender,
								title=Title,
								content=Content,
								attachItemDBID1=get( "sendSystemMailToPlayer_Item1" ),
								attachItemDBID2=get( "sendSystemMailToPlayer_Item2" ),
								moneySend=MoneySend,
								moneyPay=0,
								mailTimerType=?MaileTimer_5,
								mailRecTime = common:timestamp()
							},
		mailPID ! { addMail, MailAdd },
		
		%%发送成功
		?SendMailResult_Succ
	catch
		_->
		Return = get( "sendSystemMailToPlayer_Return" ),
		%%失败
		?ERROR_OUT( "sendSystemMailToPlayer_ItemRecord fail,err code:~p,RecvPlayerID:~p,NameSender:~p, ItemRecord1:~p, ItemRecord2:~p, MoneySend:~p",
			[Return,RecvPlayerID, NameSender, ItemRecord1, ItemRecord2, MoneySend] ),
		Return
	end.

%%其他进程，发送系统邮件给玩家，发一个已有记录Item
sendSystemMailToPlayer_ItemRecord( RecvPlayerID, NameSender, Title, Content, ItemRecord1, MoneySend)->
	sendSystemMailToPlayer_ItemRecord( RecvPlayerID, NameSender, Title, Content, ItemRecord1, {}, MoneySend).

%%其他进程，发送系统邮件给玩家，只发钱
sendSystemMailToPlayer_Money( RecvPlayerID, NameSender, Title, Content, MoneySend )->
	sendSystemMailToPlayer( RecvPlayerID, NameSender, Title, Content, 0,0,0, 0,0,0, MoneySend ).
  
%%其他进程，发送系统邮件给玩家，只发一件物品，和钱
sendSystemMailToPlayer_Item_Money( RecvPlayerID, NameSender, Title, Content, ItemID1, ItemAmount1, ItemBinded1, MoneySend )->
	sendSystemMailToPlayer( RecvPlayerID, NameSender, Title, Content, ItemID1, ItemAmount1, ItemBinded1, 0,0,0, MoneySend ).
  



%%玩家进程，处理收取邮件中的item请求
onPlayerMsgRecvMail( #pk_RequestAcceptMailItem{}=Msg )->  
	%%错误消息，补充定义
	try
		put( "onPlayerMsgRecvMail_LockCell_1", {} ),
		put( "onPlayerMsgRecvMail_LockCell_2", {} ),
		
		PlayerID = player:getCurPlayerID(),
%% 		MailPID = db:getFiled( globalMain, ?GlobalMainID, #globalMain.mailPID ),
%% 		case MailPID of
%% 			0->put( "onPlayerMsgRecvMail_Return", ?SendMailResult_Fail_SystemBusy ),throw(?AcceptMailItem_NoThisMail);
%% 			_->ok
%% 		end,

		MailPlayerData = etsBaseFunc:readRecord( ?MailPlayerTableAtom, PlayerID ),
		case MailPlayerData of
			{}->put( "onPlayerMsgRecvMail_Return", ?SendMailResult_Fail_SystemBusy ),throw(?AcceptMailItem_NoThisMail);
			_->
				put( "onPlayerMsgRecvMail_HasMail", 0 ),
				try
					MyFunc = fun( Record )->
								case Record =:= Msg#pk_RequestAcceptMailItem.mailID of
									true->put( "onPlayerMsgRecvMail_HasMail", 1 ), throw(-1);
									false->ok
								end
							 end,
					lists:foreach( MyFunc, MailPlayerData#mailPlayer.mailIDList )
				catch
					_->ok
				end,

				case get( "onPlayerMsgRecvMail_HasMail" ) =:= 1 of
					false->put( "onPlayerMsgRecvMail_Return", ?SendMailResult_Fail_SystemBusy ),throw(?AcceptMailItem_NoThisMail);
					true->ok
				end
		end,	
		
		Mail = etsBaseFunc:readRecord( ?MailTableAtom, Msg#pk_RequestAcceptMailItem.mailID ),
		case Mail of
			{}->put( "onPlayerMsgRecvMail_Return", ?SendMailResult_Fail_SystemBusy ),throw(?AcceptMailItem_NoThisMail);
			_->ok
		end,

		
		case Mail#mailRecord.attachItemDBID1 of
			0->ok;
			_->
				SpaceCell = playerItems:getPlayerBagSpaceCell( ?Item_Location_Bag ),%%先判断了玩家背包，应该返回{Location, SpaceCell}
				case SpaceCell >= 0 of
					false->
							DarkSpaceCell = playerItems:getPlayerBagSpaceCell( ?Item_Location_TempBag), %%再判断临时背包，
							case DarkSpaceCell >= 0 of
								false->
									put( "onPlayerMsgRecvMail_Return", ?SendMailResult_Fail_SystemBusy ),throw(?AcceptMailItem_NoCell);
								true->
									playerItems:setLockPlayerBagCell(?Item_Location_TempBag, DarkSpaceCell, 1),
									put( "onPlayerMsgRecvMail_LockCell_1", {?Item_Location_TempBag,DarkSpaceCell})
							end;
					true->
							playerItems:setLockPlayerBagCell( ?Item_Location_Bag, SpaceCell, 1 ),
							put( "onPlayerMsgRecvMail_LockCell_1", {?Item_Location_Bag,SpaceCell} )
				end
		end,
		
		case Mail#mailRecord.attachItemDBID2 of
			0->ok;
			_->
				SpaceCell2 = playerItems:getPlayerBagSpaceCell( ?Item_Location_Bag ),
				case SpaceCell2 >= 0 of
					false->
							DarkSpaceCell2 = playerItems:getPlayerBagSpaceCell( ?Item_Location_TempBag),
							case DarkSpaceCell2 >= 0 of
								false->
									put( "onPlayerMsgRecvMail_Return", ?SendMailResult_Fail_SystemBusy ),throw(?AcceptMailItem_NoCell);
								true->
									playerItems:setLockPlayerBagCell(?Item_Location_TempBag, DarkSpaceCell2, 1),
									put( "onPlayerMsgRecvMail_LockCell_2", {?Item_Location_TempBag,DarkSpaceCell2})
							end;
					true->
							playerItems:setLockPlayerBagCell( ?Item_Location_Bag, SpaceCell2, 1 ),
							put( "onPlayerMsgRecvMail_LockCell_2", {?Item_Location_Bag,SpaceCell2} )
				end
		end,

		case Mail#mailRecord.moneyPay > 0 of
			false->ok;
			true->
				case playerMoney:canDecPlayerMoney( Mail#mailRecord.moneyPay ) of
					false->put( "onPlayerMsgRecvMail_Return", ?SendMailResult_Fail_SystemBusy ),throw(?AcceptMailItem_NotEnoughMoney);
					true->
						ParamTuple = #token_param{changetype = ?Money_Change_MailPay},
						playerMoney:decPlayerMoney(Mail#mailRecord.moneyPay, ?Money_Change_MailPay, ParamTuple)
				end
		end,

		mailPID ! { recvMail, PlayerID, get( "onPlayerMsgRecvMail_LockCell_1" ), get( "onPlayerMsgRecvMail_LockCell_2" ), Msg },
		%%收取成功，补log
		ok
	catch
		ErrCode->
		case get( "onPlayerMsgRecvMail_LockCell_1" )  of
			{} -> ok;
			{Location_tmp1,Cell_tmp1}->playerItems:setLockPlayerBagCell( Location_tmp1, Cell_tmp1, 0 )
		end,
		case get( "onPlayerMsgRecvMail_LockCell_2" ) of
			{} -> ok;
			{Location_tmp2,Cell_tmp2}->playerItems:setLockPlayerBagCell( Location_tmp2, Cell_tmp2, 0 )
		end,
		player:send( #pk_RequestAcceptMailItemAck{result = ErrCode} ),
		ok
	end.
	




%%邮件进程，处理收取邮件请求 
%%LockBagCell_1 is  {Location,Cell}, LockBagCell_2 is {Location,Cell}
onMsgRecvMail( PlayerID, LockBagCell_1, LockBagCell_2, #pk_RequestAcceptMailItem{}=Msg )->  
	%%错误消息，补充定义
	try
		Mail = etsBaseFunc:readRecord( getMailTable(), Msg#pk_RequestAcceptMailItem.mailID ),
		case Mail of
			{}->put( "onPlayerMsgRecvMail_Return", ?SendMailResult_Fail_SystemBusy ),throw(?AcceptMailItem_NoThisMail);
			_->ok
		end,
		
		MailPlayer = etsBaseFunc:readRecord( getMailPlayerTable(), PlayerID ),
		case MailPlayer of
			{}->put( "onPlayerMsgRecvMail_Return", ?SendMailResult_Fail_SystemBusy ),throw(?AcceptMailItem_NoThisMail);
			_->ok
		end,
		
		HasAttach = hasAttach( Mail ),

		put( "onMsgRecvMail_Item1", {} ),
		case Mail#mailRecord.attachItemDBID1 > 0 of
			false->ok;
			true->
				Item1 = etsBaseFunc:readRecord( getMailItemTable(), Mail#mailRecord.attachItemDBID1 ),
				case Item1 of
					{}->put( "onPlayerMsgRecvMail_Return", ?SendMailResult_Fail_SystemBusy ),throw(?AcceptMailItem_NoThisItem);
					_->ok
				end,
				{Location1,Cell1} = LockBagCell_1,
				etsBaseFunc:changeFiled(getMailItemTable(), Mail#mailRecord.attachItemDBID1, #r_itemDB.location, Location1),
				etsBaseFunc:changeFiled(getMailItemTable(), Mail#mailRecord.attachItemDBID1, #r_itemDB.cell, Cell1),
				put( "onMsgRecvMail_Item1", etsBaseFunc:readRecord( getMailItemTable(), Mail#mailRecord.attachItemDBID1 ) )
		end,
		
		put( "onMsgRecvMail_Item2", {} ),
		case Mail#mailRecord.attachItemDBID2 > 0 of
			false->ok;
			true->
				Item2 = etsBaseFunc:readRecord( getMailItemTable(), Mail#mailRecord.attachItemDBID2 ),
				case Item2 of
					{}->put( "onPlayerMsgRecvMail_Return", ?SendMailResult_Fail_SystemBusy ),throw(?AcceptMailItem_NoThisItem);
					_->ok
				end,
				{Location2,Cell2} = LockBagCell_2,
				etsBaseFunc:changeFiled(getMailItemTable(), Mail#mailRecord.attachItemDBID2, #r_itemDB.location, Location2),
				etsBaseFunc:changeFiled(getMailItemTable(), Mail#mailRecord.attachItemDBID2, #r_itemDB.cell, Cell2),
				put( "onMsgRecvMail_Item2", etsBaseFunc:readRecord( getMailItemTable(), Mail#mailRecord.attachItemDBID2 ) )
		end,
		
		MsgToPlayer = #msgPlayerRecvMail{ 
										 moneyRecv=Mail#mailRecord.moneySend, 
										 itemRecv1=get( "onMsgRecvMail_Item1" ),
										 itemRecv2=get( "onMsgRecvMail_Item2" ) 
										},

		player:sendMsgToPlayerProcess(PlayerID, { msgPlayerRecvMail, MsgToPlayer }),

		case MsgToPlayer#msgPlayerRecvMail.itemRecv1 of
			{}->ok;
			_->
				etsBaseFunc:deleteRecord(getMailItemTable(), MsgToPlayer#msgPlayerRecvMail.itemRecv1#r_itemDB.id )
		end,
		case MsgToPlayer#msgPlayerRecvMail.itemRecv2 of
			{}->ok;
			_->
				etsBaseFunc:deleteRecord(getMailItemTable(), MsgToPlayer#msgPlayerRecvMail.itemRecv2#r_itemDB.id )
		end,

		case Msg#pk_RequestAcceptMailItem.isDeleteMail =:= 0 of				%%删除邮件，临时注释
			true->
				%%不删除邮件，清空附件
				etsBaseFunc:changeFiled( getMailTable(), Mail#mailRecord.id, #mailRecord.attachItemDBID1, 0 ),
				etsBaseFunc:changeFiled( getMailTable(), Mail#mailRecord.id, #mailRecord.attachItemDBID2, 0 ),
				etsBaseFunc:changeFiled( getMailTable(), Mail#mailRecord.id, #mailRecord.moneySend, 0 ),
				etsBaseFunc:changeFiled( getMailTable(), Mail#mailRecord.id, #mailRecord.moneyPay, 0 ),
				
				case HasAttach of
					true->etsBaseFunc:changeFiled( getMailPlayerTable(), PlayerID, #mailPlayer.hasAttachMailCount, MailPlayer#mailPlayer.hasAttachMailCount - 1 );
					false->ok
				end,
				
				%%立即存盘
				CurMail = etsBaseFunc:readRecord(getMailTable(), Mail#mailRecord.id),
%% 				db:writeRecord( CurMail );
				mySqlProcess:updatemailRecord(CurMail);
			false->
				%%删除邮件
				NetList = MailPlayer#mailPlayer.mailIDList -- [Mail#mailRecord.id],
				etsBaseFunc:changeFiled( getMailPlayerTable(), PlayerID, #mailPlayer.mailIDList, NetList ),
			
				case HasAttach of
					true->etsBaseFunc:changeFiled( getMailPlayerTable(), PlayerID, #mailPlayer.hasAttachMailCount, MailPlayer#mailPlayer.hasAttachMailCount - 1 );
					false->ok
				end,

				etsBaseFunc:changeFiled( getMailPlayerTable(), PlayerID, #mailPlayer.allMailCount, MailPlayer#mailPlayer.allMailCount - 1 ),
				
				etsBaseFunc:deleteRecord(getMailTable(), Mail#mailRecord.id ),
%% 				db:delete( mailRecord, Mail#mailRecord.id )
				mySqlProcess:deleteRecordByTableNameAndId("mailrecord",Mail#mailRecord.id)
		end,

		MsgResult = #pk_RequestAcceptMailItemAck{result = ?AcceptMailItem_Success},
		player:sendToPlayer(PlayerID, MsgResult),
		%%收取成功，补log
		logdbProcess:write_log_mail_change(?Mail_Change_Type_Rev,Mail),
		ok
	catch
		ErrCode->
			 {Location_tmp1,Cell_tmp1} = LockBagCell_1,
			case Cell_tmp1 >= 0 of
				true->
					player:sendMsgToPlayerProcess(PlayerID, { msgPlayerSetBagLock, #msgPlayerSetBagLock{location=Location_tmp1, cell=Cell_tmp1, lockID=0}});
				false->ok
			end,
			{Location_tmp2,Cell_tmp2} = LockBagCell_2,
			case Cell_tmp2 >= 0 of
				true->
					player:sendMsgToPlayerProcess(PlayerID, { msgPlayerSetBagLock, #msgPlayerSetBagLock{location=Location_tmp2, cell=Cell_tmp2, lockID=0} });
				false->ok
			end,

			player:sendToPlayer(PlayerID, #pk_RequestAcceptMailItemAck{result = ErrCode}),
		ok
	end.	
	
%%玩家进程，处理邮件进程通知收邮件的附件
onPlayerRecvMailAttach( #msgPlayerRecvMail{}=MsgPlayerRecvMail )->
	try
		PlayerID = player:getCurPlayerID(),
		
		case MsgPlayerRecvMail#msgPlayerRecvMail.moneyRecv > 0 of
			false->ok;
			true->
				ParamTuple = #token_param{changetype = ?Money_Change_MailRecv},
				playerMoney:addPlayerMoney(MsgPlayerRecvMail#msgPlayerRecvMail.moneyRecv,  ?Money_Change_MailRecv, ParamTuple)
		end,
		
		case MsgPlayerRecvMail#msgPlayerRecvMail.itemRecv1 of
			{}->ok;
			_->
				Item1 = MsgPlayerRecvMail#msgPlayerRecvMail.itemRecv1,
				case playerItems:isPlayerBagCellEmpty( Item1#r_itemDB.location, Item1#r_itemDB.cell ) of
					false->ok;%%物品丢失，补log
					true->
						Item2 = setelement( #r_itemDB.owner_type, Item1, ?item_owner_type_player ),
						Item3 = setelement( #r_itemDB.owner_id, Item2, PlayerID ),
						
						etsBaseFunc:insertRecord( itemModule:getCurItemTable(), Item3 ),
						%%立即存盘
						itemModule:saveItemDB( Item3 ),
						playerItems:setPlayerBagCell( Item1#r_itemDB.location, Item1#r_itemDB.cell, Item3#r_itemDB.id, 0),
						
						put( "onPlayerRecvMailAttach_Item_Bind_1", "" ),
						case Item3#r_itemDB.binded of
							true->put( "onPlayerRecvMailAttach_Item_Bind_1", ?Get_Item_Param_Bind_Set_Binded );
							false->ok
						end,

						GetParam = [ ?Get_Item_Reson_Mail, get("onPlayerRecvMailAttach_Item_Bind_1"), "" ],
						playerItems:onPlayerGetItem(Item3, GetParam),
						ItemData1 = etsBaseFunc:readRecord(itemModule:getCurItemTable(), Item3#r_itemDB.id),
						playerItems:sendToPlayer_GetItem( ItemData1, ?Get_Item_Reson_Mail )
				end,

				ok
		end,
		
		case MsgPlayerRecvMail#msgPlayerRecvMail.itemRecv2 of
			{}->ok;
			_->
				Item21 = MsgPlayerRecvMail#msgPlayerRecvMail.itemRecv2,
				case playerItems:isPlayerBagCellEmpty( Item21#r_itemDB.location, Item21#r_itemDB.cell ) of
					false->ok;%%物品丢失，补log
					true->
						Item22 = setelement( #r_itemDB.owner_type, Item21, ?item_owner_type_player ),
						Item23 = setelement( #r_itemDB.owner_id, Item22, PlayerID ),
						
						etsBaseFunc:insertRecord( itemModule:getCurItemTable(), Item23 ),
						%%立即存盘
						itemModule:saveItemDB( Item23 ),
						playerItems:setPlayerBagCell( Item21#r_itemDB.location, Item21#r_itemDB.cell, Item23#r_itemDB.id, 0),
						
						put( "onPlayerRecvMailAttach_Item_Bind_2", "" ),
						case Item23#r_itemDB.binded of
							true->put( "onPlayerRecvMailAttach_Item_Bind_2", ?Get_Item_Param_Bind_Set_Binded );
							false->ok
						end,

						GetParam2 = [ ?Get_Item_Reson_Mail, get("onPlayerRecvMailAttach_Item_Bind_2"), "" ],
						playerItems:onPlayerGetItem(Item23, GetParam2),
						ItemData23 = etsBaseFunc:readRecord(itemModule:getCurItemTable(), Item23#r_itemDB.id),
						playerItems:sendToPlayer_GetItem( ItemData23, ?Get_Item_Reson_Mail )
				end,

				ok
		end,
		
		%%成功收取物品，补log
		ok
	catch
		_->
		ok
	end.

%%玩家进程接收消息，设置背包格子锁定
onMsgPlayerSetBagLock( #msgPlayerSetBagLock{}=Msg )->
	playerItems:setLockPlayerBagCell( Msg#msgPlayerSetBagLock.location, Msg#msgPlayerSetBagLock.cell, Msg#msgPlayerSetBagLock.lockID ),
	ok.

%%邮件进程，定时更新邮件有效时间
updateMail()->
	try
		Now = common:timestamp(),
	
		%Query5 = ets:fun2ms( fun(#mailRecord{id=_, type=_, recvPlayerID=_, isOpened=_, tiemOut=TimeOut} = Record ) when TimeOut >= Now -> Record end),
		Query = ets:fun2ms( fun(#mailTimer{id=_, time=TimeOut} = Record ) when Now  >= TimeOut -> Record end),
		MailIDList_5 = ets:select( get("MailTimer_5"), Query),

		%Query10 = ets:fun2ms( fun(#mailRecord{id=_, type=_, recvPlayerID=_, isOpened=_, tiemOut=TimeOut} = Record ) when TimeOut >= Now -> Record end),
		MailIDList_10 = ets:select( get("MailTimer_10"), Query),

		%Query24 = ets:fun2ms( fun(#mailRecord{id=_, type=_, recvPlayerID=_, isOpened=_, tiemOut=TimeOut} = Record ) when TimeOut >= Now -> Record end),
		MailIDList_24 = ets:select( get("MailTimer_24"), Query),

		MyFunc = fun( Record )->
					%%过期的邮件，删除
					doDeleteMail( Record#mailTimer.id ),
					ok
				 end,

		lists:map( MyFunc, MailIDList_5 ),
		lists:map( MyFunc, MailIDList_10 ),
		lists:map( MyFunc, MailIDList_24 ),

		ok
	catch
		_->ok
	end.

%%玩家进程，处理玩家请求删除邮件
onPlayerRequestDeleteMail( MailID )->
	try
%% 		MailPID = db:getFiled( globalMain, ?GlobalMainID, #globalMain.mailPID ),
%% 		case MailPID of
%% 			0->put( "onPlayerRequestDeleteMail_Return", ?SendMailResult_Fail_SystemBusy ),throw(-1);
%% 			_->ok
%% 		end,

		MailData = etsBaseFunc:readRecord( ?MailTableAtom, MailID ),
		case MailData of
			{}->put( "onPlayerRequestDeleteMail_Return", ?SendMailResult_Fail_SystemBusy ),throw(-1);
			_->ok
		end,	
		mailPID ! { deleteMail, player:getCurPlayerID(), MailID },
		ok
	catch
		_->ok
	end.

%%玩家进程，处理玩家请求删除已读邮件
onPlayerRequestDeleteReadMail(Msg)->
	lists:map(fun (Record) -> onPlayerRequestDeleteMail(Record) end, Msg#pk_RequestDeleteReadMail.readMailID).

%%邮件进程，删除邮件
doDeleteMail( MailID )->
	try
		MailData = etsBaseFunc:readRecord( getMailTable(), MailID ),
		case MailData of
			{}->throw(-1);
			_->ok
		end,
		
		HasAttach = hasAttach( MailData ),
		put( "doDeleteMail", 0 ),
		case HasAttach of
			true->put( "doDeleteMail", 1 );
			false->ok
		end,
		HasAttachMailCount = get( "doDeleteMail" ),

		case MailData#mailRecord.attachItemDBID1 > 0 of
			false->ok;
			true->
				%%物品删除，补log
				etsBaseFunc:deleteRecord( getMailItemTable(), MailData#mailRecord.attachItemDBID1 ),
				mySqlProcess:deleteRecordByTableNameAndId("r_itemdb",MailData#mailRecord.attachItemDBID1)
		end,
		case MailData#mailRecord.attachItemDBID2 > 0 of
			false->ok;
			true->
				%%物品删除，补log
				etsBaseFunc:deleteRecord( getMailItemTable(), MailData#mailRecord.attachItemDBID2 ),
				mySqlProcess:deleteRecordByTableNameAndId("r_itemdb",MailData#mailRecord.attachItemDBID2)
		end,
		
		MailPlayerTable = getMailPlayerTable(),
		MailPlayerData = etsBaseFunc:readRecord( MailPlayerTable, MailData#mailRecord.recvPlayerID ),
		case MailPlayerData of
			{}->ok;
			_->
				etsBaseFunc:changeFiled( MailPlayerTable, MailData#mailRecord.recvPlayerID, #mailPlayer.mailIDList, MailPlayerData#mailPlayer.mailIDList -- [MailData#mailRecord.id] ),
				etsBaseFunc:changeFiled( MailPlayerTable, MailData#mailRecord.recvPlayerID, #mailPlayer.allMailCount, MailPlayerData#mailPlayer.allMailCount - 1 ),
				etsBaseFunc:changeFiled( MailPlayerTable, MailData#mailRecord.recvPlayerID, #mailPlayer.hasAttachMailCount, MailPlayerData#mailPlayer.hasAttachMailCount - HasAttachMailCount ),
				ok
		end,
		
		onDeleteMailToTimer( MailData ),
		
		etsBaseFunc:deleteRecord( getMailTable(), MailData#mailRecord.id ),
%% 		db:delete( mailRecord, MailData#mailRecord.id ),
		mySqlProcess:deleteRecordByTableNameAndId("mailRecord",MailData#mailRecord.id),
		
		%%邮件删除成功，log
		logdbProcess:write_log_mail_change(?Mail_Change_Type_Delete,MailData),

		ok
	catch
		_->ok
	end.
  
  getUnReadMailCount(PlayerID) ->		%%获得未读邮件个数并发送给Player
	MailPlayerData = etsBaseFunc:readRecord( getMailPlayerTable(), PlayerID ),
	case MailPlayerData of
		{}->
			MailIDList = [];
		_->
			MailIDList = MailPlayerData#mailPlayer.mailIDList
	end,
	
	AllMailList = lists:map(fun(Record)->etsBaseFunc:readRecord(getMailTable(), Record) end, MailIDList),
	UnReadMailList = lists:filter(fun(Record) -> (Record#mailRecord.isOpened =:= 0) end, AllMailList),
	UnReadMailCount = size(list_to_tuple(UnReadMailList)),
	Msg = #pk_RequestUnReadMailAck{unReadCount = UnReadMailCount},
	player:sendToPlayer(PlayerID, Msg).

getPlayerMailList(PlayerID)->		%%获得玩家邮件并发送给Player
	MailPlayerData = etsBaseFunc:readRecord( getMailPlayerTable(), PlayerID ),
	case MailPlayerData of
		{}->
			MailIDList = [];
		_->
			MailIDList = MailPlayerData#mailPlayer.mailIDList
	end,
	case MailIDList of
		[]->
			PlayerMailList = [];
		_->
			MailTable = getMailTable(),
			Rule = fun(Record)->
						   ARecord = etsBaseFunc:readRecord(MailTable, Record),
						   Flag = ARecord#mailRecord.attachItemDBID1 + ARecord#mailRecord.attachItemDBID2,
						   case Flag of
							   0->
								   HaveItem = 0;
							   _->
								   HaveItem = 1
						   end,
						   #pk_MailInfo{id = ARecord#mailRecord.id,
										type = ARecord#mailRecord.type,
										recvPlayerID = ARecord#mailRecord.recvPlayerID,
										isOpen = ARecord#mailRecord.isOpened,
										timeOut = ARecord#mailRecord.tiemOut,
										senderType = ARecord#mailRecord.idSender,
										senderName = ARecord#mailRecord.nameSender,
										title = ARecord#mailRecord.title,
										content = ARecord#mailRecord.content,
										haveItem = HaveItem,
										moneySend = ARecord#mailRecord.moneySend,
										moneyPay = ARecord#mailRecord.moneyPay,
										mailTimerType = ARecord#mailRecord.mailTimerType,
										mailRecTime = ARecord#mailRecord.mailRecTime
										}
						   end,
			PlayerMailList = lists:map(Rule, MailIDList)
	end,
	Msg = #pk_RequestMailListAck{mailList = PlayerMailList},
	player:sendToPlayer(PlayerID, Msg).

getMailItemInfo(PlayerID, MailID) ->
	MailData = etsBaseFunc:readRecord(getMailTable(), MailID),
	case MailData of
		{}->
			ok;
		_->
			ItemID1 = MailData#mailRecord.attachItemDBID1,
			ItemInfo1 = itemModule:getItemDBDataByDBIDFromDB(ItemID1),
			case ItemInfo1 of
				{}->
					MsgInfo1 = [];
				_->
					ItemInfo1_new = setelement(#r_itemDB.location, ItemInfo1, ?Item_Location_Mail),
					MsgInfo1 = [itemModule:makeItemToMsgItemInfo(ItemInfo1_new)]
			end,
			ItemID2 = MailData#mailRecord.attachItemDBID2,
			ItemInfo2 = itemModule:getItemDBDataByDBIDFromDB(ItemID2),
			case ItemInfo2 of
				{}->
					MsgInfo2 = [];
				_->
					ItemInfo2_new = setelement(#r_itemDB.location, ItemInfo2, ?Item_Location_Mail),
					MsgInfo2 = [itemModule:makeItemToMsgItemInfo(ItemInfo2_new)]
			end,
			MsgInfo = MsgInfo1 ++ MsgInfo2,
			Msg = #pk_RequestMailItemInfoAck{mailID = MailID,
											 mailItem = MsgInfo},
			player:sendToPlayer(PlayerID, Msg)
	end.

%%玩家进程	
changeMailReadFlag(#pk_MailReadNotice{} = Msg)->
	MailID = Msg#pk_MailReadNotice.mailID,
	case etsBaseFunc:readRecord(getMailTable(), MailID) of 
		{} ->
			%% the mail is delete, maybe expired
			ok;
		MailData ->
			case MailData#mailRecord.isOpened of
				0->			
					mail:getMailPID() ! {changeMailReadFlag, MailData};
				_->
					ok
			end
	end.

%%邮件进程
  mailReadFlagChange(#mailRecord{} = MailData)->
	etsBaseFunc:changeFiled(getMailTable(), MailData#mailRecord.id, #mailRecord.isOpened, 1),
%% 	db:changeFiled( mailRecord, MailData#mailRecord.id, #mailRecord.isOpened, 1 ).
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"UPDATE mailRecord SET isOpened=1 WHERE id="++integer_to_list(MailData#mailRecord.id),true),
	logdbProcess:write_log_mail_change(?Mail_Change_Type_Open,MailData).
%%测试函数
systemMailTest()->
	AttachItem1 = itemModule:initItemDBDataByItemID( 11 ),
	mySqlProcess:insertOrReplaceR_itemDB(AttachItem1,false),
	sendSystemMailToPlayer_ItemRecord( 1001, "System", "title", "content", AttachItem1, 10).
	
