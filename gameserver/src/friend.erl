%% Author: Administrator
%% Created: 2012-12-24
%% Description: TODO: Add description to friend

-module(friend).

%%
%% Include files
%%

-include("package.hrl").
-include("db.hrl").
-include("gamedatadb.hrl").
-include("playerDefine.hrl").
-include("hdlt_logger.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("friendDefine.hrl").


%%
%% Exported Functions
%%
%-export([]).
-compile(export_all).

%%
%% API Functions
%%

%%返回当前进程的好友表
getCurFriendTable()->
	FriendTable = get( "FriendTable" ),
	case FriendTable of
		undefined->0;
		_->FriendTable
	end.
%%返回临时好友表
getCurFriendTable(?Friend_Type_T) ->
	TempFriend = get("TempFriendTable"),
	case TempFriend of
		undefined -> 0;
		_ -> TempFriend
	end.
	
fillFriendDbByOnline(#friend_gamedata{}=F) ->
	PlayerInfo = player:getPlayerRecord(F#friend_gamedata.friendID),
	case PlayerInfo of
		{} -> %玩家不在线
			#friendDB{id=F#friend_gamedata.id,
				playerID=F#friend_gamedata.playerID,
				friendType = F#friend_gamedata.friendType,
			    friendID = F#friend_gamedata.friendID,
			    friendName = F#friend_gamedata.friendName,
			    friendSex = F#friend_gamedata.friendSex,
			    friendFace = F#friend_gamedata.friendFace, 
			    friendClassType=F#friend_gamedata.friendClassType, 
			    friendLevel = 1,
			    friendVip= 0,
			    friendValue= F#friend_gamedata.friendValue,
			    friendOnline = 0};
		_->
			#friendDB{id=F#friend_gamedata.id,
				playerID=F#friend_gamedata.playerID,
				friendType = F#friend_gamedata.friendType,
			    friendID = F#friend_gamedata.friendID,		
			    friendName = PlayerInfo#player.name,
			    friendSex = PlayerInfo#player.sex,
			    friendFace = PlayerInfo#player.faction, 
			    friendClassType=PlayerInfo#player.camp, 
			    friendLevel = PlayerInfo#player.level,
			    friendVip= PlayerInfo#player.vip,
			    friendValue= F#friend_gamedata.friendValue,
			    friendOnline = 1}
	end.
	
fillFriendGamedataByFriendDb(#friendDB{}=F) ->
	#friend_gamedata{id=F#friendDB.id,
				playerID=F#friendDB.playerID,
				friendType = F#friendDB.friendType,
			    friendID = F#friendDB.friendID,
			    friendName = F#friendDB.friendName,
			    friendSex = F#friendDB.friendSex,
			    friendFace = F#friendDB.friendFace, 
			    friendClassType=F#friendDB.friendClassType, 
			    friendValue= F#friendDB.friendValue}.

	
  
%玩家上线加载好友 以及黑名单  
onPlayerOnlineLoadFriendDB(DBInitData) ->	
	FriendTable = getCurFriendTable(),
	MyFunc = fun( Record )->
				%% modified by wenziyong, add table friend_gamedata 
				%Online = player:getPlayerIsOnlineByID(Record#friendDB.friendID),
				%case Online of
				%	false ->MyR = Record#friendDB{friendOnline = 0};
				%	true -> MyR = Record#friendDB{friendOnline = 1}
				%end,
				
				MyR = fillFriendDbByOnline(Record),
				case mySqlProcess:isPlayerExistById( MyR#friendDB.friendID ) of
					0-> %%玩家不存在，删除好友
						dbProcess:on_delete_Friend({MyR#friendDB.friendID,player:getCurPlayerID() });
					_->
						etsBaseFunc:insertRecord(FriendTable, MyR)	 
				end
			 end,
		
	lists:foreach( MyFunc, DBInitData ),
	
	%选择发送时机 
	sendFriendListToPlayer(),
	sendBlackListToPlayer(),
	%%发送上线通知
	on_my_Change(1).

%%发送好友信息给玩家
sendFriendListToPlayer() -> %%player:send( #pk_GS2U_LoadFriend{friendList=[]} ).
	FriendDBlist = getSavePlayerFriendDataList(),
	case FriendDBlist of
		[]-> player:send( #pk_GS2U_LoadFriend{info_list=[]} );
		_ -> player:send( #pk_GS2U_LoadFriend{info_list=[switchDB(X)||X<-FriendDBlist,X#friendDB.friendType==?Friend_Type_F]} )
	end.

%%发送黑名单信息给玩家
sendBlackListToPlayer()-> %player:send( #pk_GS2U_LoadBlack{ blackList=[] } ).
	FriendDBlist = getSavePlayerFriendDataList(),
	case FriendDBlist of
		[]-> player:send( #pk_GS2U_LoadBlack{ info_list=[] } );
		_ -> player:send( #pk_GS2U_LoadBlack{ info_list=[switchDB(X)||X<-FriendDBlist,X#friendDB.friendType==?Friend_Type_B] } )
	end.

%%发送临时好友信息给玩家
sendTempListToPlayer()-> %player:send( #pk_GS2U_LoadBlack{ blackList=[] } ).
	FriendDBlist = getSavePlayerFriendDataList(),
	case FriendDBlist of
		[]-> player:send( #pk_GS2U_LoadBlack{ info_list=[] } );
		_ -> player:send( #pk_GS2U_LoadBlack{ info_list=[switchDB(X)||X<-FriendDBlist,X#friendDB.friendType==?Friend_Type_T] } )
	end.

%%发送提示信息
sendTipsToPlayer(Type,Tips)->	
	player:send(#pk_GS2U_FriendTips{ type=Type, tips= Tips} ).


%%添加好友(黑名单/临时好友)
addFriend(InfoDB,AddType) ->
	FriendTable = getCurFriendTable(),
	HasType = isFriend(InfoDB#friendDB.friendID),
	delTempFriend(InfoDB#friendDB.friendID, false),
	case  HasType == AddType of
		true  -> sendTipsToPlayer(AddType,?Friend_Tips_Exist); %%列表已经有该玩家  发送提示信息
		false -> 
			case isMaxFriendSize(AddType) of
				true-> sendTipsToPlayer(AddType,?Friend_Tips_Max);			%%达到最大数量  发送提示信息
				false->
					case AddType of
						?Friend_Type_T ->addTempFriend(InfoDB, HasType);
						_ -> 
							case HasType of
								?Friend_Type_N -> 	%%没有就添加
									etsBaseFunc:insertRecord(FriendTable, InfoDB), 
									%% modified by wenziyong, add table friend_gamedata 
									mySqlProcess:addFriend(fillFriendGamedataByFriendDb(InfoDB));							
								_ -> 				%%存在就更新 			
									etsBaseFunc:changeFiled(FriendTable, InfoDB#friendDB.friendID,#friendDB.friendType,HasType),	
									%% modified by wenziyong, add table friend_gamedata 
									mySqlProcess:replaceFriend(fillFriendGamedataByFriendDb(InfoDB))
							end,
							player:send( #pk_GS2U_FriendInfo { friendInfo = switchDB(InfoDB)})					%%通知客户端
							%savePlayerFriend()
					end
			end
	end,
	
	?DEBUG_OUT( "player[~p] addFriend [~p]", [player:getPlayerShortLog(player:getCurPlayerID()), InfoDB#friendDB.friendName] ).

%%添加临时好友信息
addTempFriend(InfoDB, HasType) ->
	TempFriend = getCurFriendTable(?Friend_Type_T),
	case HasType of
		?Friend_Type_N -> %% 
			etsBaseFunc:insertRecord(TempFriend, InfoDB),
			player:send(#pk_GS2U_FriendInfo {friendInfo = switchDB(InfoDB)});
		_ -> ok
	end.

switchDB(P) ->
	#pk_FriendInfo{friendType = P#friendDB.friendType,
				   friendID = P#friendDB.friendID,
				   friendName = P#friendDB.friendName,
				   friendSex = P#friendDB.friendSex,
				   friendFace = P#friendDB.friendFace, 
				   friendClassType=P#friendDB.friendClassType, 
				   friendLevel = P#friendDB.friendLevel,
				   friendVip= P#friendDB.friendVip,
				   friendValue= P#friendDB.friendValue,
				   friendOnline = P#friendDB.friendOnline}.

%%是否为临时好友
isTempFriend(FriendID) ->
	TempFriend = getCurFriendTable(?Friend_Type_T),
	FriendData = etsBaseFunc:readRecord( TempFriend, FriendID),
	case FriendData of
		{} -> 0;
		_  -> FriendData#friendDB.friendType
	end.
%%删除临时好友
delTempFriend(DeleteID,IsSend) ->
	IsTemp = isTempFriend(DeleteID),
	case IsTemp of 
		?Friend_Type_N ->
			case IsSend of
				true ->sendTipsToPlayer(?Friend_Type_N,?Friend_Tips_NotExist); 	%%表示不是好友   发送提示信息
				false -> ok
			end;
		_ -> etsBaseFunc:deleteRecord(getCurFriendTable(?Friend_Type_T), DeleteID),
			player:send( #pk_GS2U_DeteFriendBack{type = ?Friend_Type_T, friendID=DeleteID} )
	end.


%%删除好友(黑名单/临时好友)
deleteFriend(DeleteID)->
	FriendTable = getCurFriendTable(),
	HasType = isFriend(DeleteID),
	case  HasType  of
		?Friend_Type_N  ->
			delTempFriend(DeleteID, true);
		_ -> 
			etsBaseFunc:deleteRecord(FriendTable, DeleteID),  				%%  删除 
			player:send( #pk_GS2U_DeteFriendBack{type = HasType, friendID=DeleteID} ),						%%通知客户端  扩展下提示信息 通知统一用提示信息发送
			%dbProcess_PID ! {playerDelFriend, {player:getCurPlayerID(),DeleteID }} % 删除物理记录
			dbProcess:on_delete_Friend({DeleteID,player:getCurPlayerID() })
			%db:delete(friendDB, Frid) %#friendDB{playerID = player:getCurPlayerID(),friendID=DeleteID,_='_'})
	end.

%%发送玩家的等级，ＶＩＰ，及离线等信息
on_send_friendInfo(Pinfo) ->
	 {Friendid, Level, Vip, Online} = Pinfo,
	 FriendTable = getCurFriendTable(),
	 HasType = isFriend(Friendid),
	 case HasType of
		 ?Friend_Type_N -> 0;
		 _-> 
			% NewRecord = MyRecord#friendDB{friendLevel=Level, friendVip = Vip, friendOnline=Online},
			%?DEBUG_OUT("new Record ~p",[NewRecord]), 改变内存表
			 etsBaseFunc:changeFiled(FriendTable, Friendid,#friendDB.friendLevel,Level),
			etsBaseFunc:changeFiled(FriendTable, Friendid,#friendDB.friendVip,Vip),
			etsBaseFunc:changeFiled(FriendTable, Friendid,#friendDB.friendOnline,Online),
		%	etsBaseFunc:changeFiled(FriendTable, Playerid,#friendDB.friendLevel,Level),
			 MyRecord = etsBaseFunc:readRecord(FriendTable, Friendid),
			 player:send(#pk_GS2U_FriendInfo{friendInfo = switchDB(MyRecord)})
			 %% commented by wenziyong, just save to mysql db when add or delete friend
			 %savePlayerFriend()
	 end.
	
  
%%更新好友信息(黑名单/临时好友)  服务器行为 只更新在线/下线  等级等信息,不需要写db
updateFriend(UpdateInfo)->
	FriendTable = getCurFriendTable(),
	HasType = isFriend(UpdateInfo#friendDB.friendID),
	case  HasType  of
		?Friend_Type_N   -> 0; 	%%表示不是好友  服务器log  
		_ -> 					%%是好友  更新信息
			etsBaseFunc:changeFiled(FriendTable, UpdateInfo#friendDB.friendID,#friendDB{},UpdateInfo),  	
			player:send( #pk_GS2U_FriendInfo{friendInfo = switchDB(UpdateInfo)} )
			%savePlayerFriend()
	end.

%%检查是否好友(黑名单/临时好友)
isFriend(FriendID)->
		FriendTable = getCurFriendTable(),
		FriendData = etsBaseFunc:readRecord( FriendTable, FriendID),
			case FriendData of
					{} -> ?Friend_Type_N;		%%不是好友
					_  -> FriendData#friendDB.friendType
			end.

%%检查最大数量好友(黑名单/临时好友)
isMaxFriendSize(Type)->
		FriendTable = getCurFriendTable(),
		case length([X||X<-etsBaseFunc:getAllRecord(FriendTable),X#friendDB.friendType==Type]) > ?Max_Friend of
			true -> true;
			false -> false
		end.

%%获取当前好友数量(黑名单/临时好友)
getFriendCount(Type)->
	FriendTable = getCurFriendTable(),
	length([X||X<-FriendTable,X#friendDB.friendType==Type]) 
	.

%% juse save to mysql when add or delete or update friend
%%玩家好友信息存盘
%savePlayerFriend()->
%	FriendTable = getCurFriendTable(),
%	Rule = ets:fun2ms(fun(Record)->Record end),
%	FriendDBList = ets:select(FriendTable, Rule).
	%dbProcess_PID ! { playerSaveFriend, FriendDBList}. %%[X||X<-FriendDBList,X#friendDB.friendType =/= ?Friend_Type_T]}.
	% delete erlang table frienddb,maybe should add other function
	%dbProcess:on_playerSaveFriendList(FriendDBList).

%%返回玩家存盘数据
getSavePlayerFriendDataList()->
	FriendTable = getCurFriendTable(),
	Rule = ets:fun2ms(fun(Record)->Record end),
	FriendDBList = ets:select(FriendTable, Rule),
	FriendDBList.

%%添加好友
on_U2GS_AddFriend(Msg)->
		try
			{Frid, Fname, Ftype} = {Msg#pk_U2GS_AddFriend.friendID,Msg#pk_U2GS_AddFriend.friendName, Msg#pk_U2GS_AddFriend.type},
			case isMaxFriendSize(Ftype) of
				true -> throw( { Ftype, ?Friend_Tips_Max });		%%此好友列表已满
				false ->ok
			end,
			
			if
				Frid > 0 ->
					Fid = mySqlProcess:isPlayerExistById( Frid ),
					PlayerPID = player:getPlayerPID(Frid);
				true ->
					Fid = mySqlProcess:isPlayerExistByName( Fname ),
					PlayerPID = player:getPlayerPID(Fid)
			end,
			
			case Fid of
				0->throw( {Ftype, ?Friend_Tips_NotPlayer} );
				_->ok
			end,
			
			case Fid =:= player:getCurPlayerID() of
				true->throw( {Ftype, ?Friend_Tips_NotMe});
				_->ok
			end,
			
			HasType = isFriend(Fid),
			case Ftype =:= HasType of
				true->
					throw( {Ftype, ?Friend_Tips_Exist} );
				_->ok
			end,
								
			case Ftype of
				?Friend_Type_F->		%%如果是加好友，发送确认信息给对方
						case PlayerPID of
							0->
								%%判断是否关闭好友申请		 Fid			 		
								case mySqlProcess:get_gameSetMenuBy_id(Fid) of
									{} ->ok;
									GameSetMenu1->
										case GameSetMenu1#pk_GSWithU_GameSetMenu_3.applicateFriendOnoff =:= 0 of		
						 					true ->%% 目标玩家关闭好友申请
						 						throw( {Ftype, ?Friend_Tips_TargetCloseApplicateFriend });										
						 					false ->
						 						ok		
						 				end
								end;
							_->
								%%判断是否关闭好友申请
						 		case player:getPlayerProperty( Fid, #player.gameSetMenu )  of
						 			0 ->
										throw( {Ftype, ?Friend_Tips_TargetCloseApplicateFriend} );
									{} -> ok;
						 			GameSetMenu->
						 				case GameSetMenu#pk_GSWithU_GameSetMenu_3.applicateFriendOnoff =:= 0 of		
						 					true ->%% 目标玩家关闭好友申请
						 						throw( {Ftype, ?Friend_Tips_TargetCloseApplicateFriend });										
						 					false ->
						 						ok		
						 				end
						 		end,
								PlayerPID !  {msg_accept_Agreement , { player:getCurPlayerID(), player:getCurPlayerProperty(#player.name)}}
						end;
				_->ok
			end,
			
			case HasType of
				?Friend_Type_N->
					ready_addFriend(Fid, Ftype);
				_->
					change_friend_type(Fid, Ftype)
			end,
			
			throw( {Ftype, ?Friend_Tips_OK} )
		
		catch
			{Type, Value}->sendTipsToPlayer(Type, Value)
	end.

%%更改好友的类型
change_friend_type(Friendid,Type) ->
	FriendTable = getCurFriendTable(),
	FriendinfoDelete = etsBaseFunc:readRecord(FriendTable, Friendid),
	player:send( #pk_GS2U_DeteFriendBack{ type=FriendinfoDelete#friendDB.friendType, friendID=Friendid }),
	etsBaseFunc:changeFiled(FriendTable, Friendid,#friendDB.friendType,Type),
	etsBaseFunc:changeFiled(FriendTable, Friendid,#friendDB.friendValue,0),
	Friendinfo = etsBaseFunc:readRecord(FriendTable, Friendid),
	player:send(#pk_GS2U_FriendInfo{friendInfo = switchDB(Friendinfo)}),
	%% modified by wenziyong, add table friend_gamedata 
	mySqlProcess:replaceFriend(fillFriendGamedataByFriendDb(Friendinfo)).
	%savePlayerFriend().

%%发送同意加好友的提示框
on_accept_toSend(Data) ->
	{Fid, Fname} = Data,
	?DEBUG_OUT("accept friend id ~p  name ~p",[Fid, Fname]),
	case isMaxFriendSize(?Friend_Type_F) of
		true ->ok;
		false -> 
			player:send( #pk_GS2U_AddAcceptResult{isSuccess = 0, type = Fid, fname = Fname } )
	end.


%%删除好友
on_U2GS_DeleteFriend(Msg)->
	Fid = Msg#pk_U2GS_DeleteFriend.friendID, 
	Type = Msg#pk_U2GS_DeleteFriend.type,
	deleteFriend(Fid).


%%加入好友列表（黑名单/临时好友）
ready_addFriend(Fid, Type) ->
	try
		Player = player:getPlayerRecord(Fid),
		case Player of
			{} ->
				Online = 0,
				PlayerGamedataList = mySqlProcess:get_playerGamedata_list_by_id(Fid),
				case PlayerGamedataList of
					[]->
						PlayerInfo = {},
						throw(-1);
					[PlayerGamedata|_]->
						PlayerInfo = dataConv:fillPlayerByplayerGamedata(PlayerGamedata)
				end;
			_->
				Online = 1,
				PlayerInfo = Player
		end,
		InfoDB = #friendDB{id = db:memKeyIndex(friend_gamedata), % persistent 
						playerID = player:getCurPlayerID(),
						   friendID = Fid, 
						   friendType = Type, 
						   friendName = PlayerInfo#player.name, 
						   friendSex=PlayerInfo#player.sex,
						   friendFace=PlayerInfo#player.faction,
						   friendClassType=PlayerInfo#player.camp,
						   friendLevel = PlayerInfo#player.level,
						   friendVip=PlayerInfo#player.vip,
						   friendValue =0,
						   friendOnline =Online},
			?DEBUG_OUT("jia friend ~p",[InfoDB]),
			addFriend(InfoDB, Type)
	catch
		_->ok
end.
	
%%同意加好友
on_GS2U_AcceptSuccess(Msg) ->
	Fid= Msg#pk_U2GS_AcceptFriend.friendID,
	?DEBUG_OUT("u2gs F id =~p",[Fid]),
	
	case Msg#pk_U2GS_AcceptFriend.result /=0 of
		true->
			case  isFriend(Fid) of
				?Friend_Type_N->
					ready_addFriend(Fid, ?Friend_Type_F);
				?Friend_Type_F->
					sendTipsToPlayer(?Friend_Type_F,?Friend_Tips_Exist); %%列表已经有该玩家  发送提示信息;
				_->
					change_friend_type(Fid, ?Friend_Type_F)
			end;
		_->ok
	end.


%%给好友加友好度
on_add_FriendValue(Data) ->
	{Fid, Value} = Data,
	FriendTable = getCurFriendTable(),
	case Fid of
		N when N =< 0 -> 0;
		_ -> Type = isFriend(Fid),
			 case Type of
				 ?Friend_Type_F ->InfoDB = etsBaseFunc:readRecord( FriendTable, Fid),
						NewValue = InfoDB#friendDB.friendValue + Value,
				 		put("addFriendValue", NewValue),
				 		case NewValue < 0 of
							true -> put("addFriendValue", 0);
							_->ok
						end,
						NewValue2 = get("addFriendValue"),
					etsBaseFunc:changeFiled(FriendTable, Fid ,#friendDB.friendValue,NewValue2),
					player:send( #pk_GS2U_FriendInfo{friendInfo = etsBaseFunc:readRecord(FriendTable, Fid)} ),
					%% modified by wenziyong, add table friend_gamedata 
			 		%savePlayerFriend();					
					Friendinfo = etsBaseFunc:readRecord(FriendTable, Fid),
					mySqlProcess:updateFriend([Friendinfo#friendDB.friendType, Friendinfo#friendDB.friendValue,  Friendinfo#friendDB.id]);
				 _-> 0
			 end
	end.

%%我的属性的改变通知我的好友
%%参数Online　值为１　代表在线，0为不在线
on_my_Change(Online) ->
	PlayerInfor = player:getCurPlayerRecord(),
	Pinfo = {PlayerInfor#player.id,PlayerInfor#player.level, PlayerInfor#player.vip, Online},
	FriendList = mySqlProcess:get_playerIdListWhichAddMeAsFriend(PlayerInfor#player.id),
	WTK = fun(Record) ->
				  case player:getPlayerRecord(Record) of
					  {}->ok;
					  _->
						  player:sendMsgToPlayerProcess(Record, {changeFriendMess, Pinfo})
				  end
		  end,
	lists:foreach(WTK, FriendList),
	0.




%%测试消息函数
testMess(_Msg) ->
	Socket = netUsers:getCurUserSocket(),
	Len = 16,
	Cmd = ?CMD_GS2U_Net_Message,
	Bin= <<Len:32/little,Cmd:32/little>>,
	Bin1 = <<Len:16/little, Cmd:16/little, Bin/binary>>,
	_Result = gen_tcp:send(Socket,Bin1),
	timer:sleep(1000),
	Bin2 = <<Len:32/little>>,
	_Res = gen_tcp:send(Socket, Bin2),
	ok.


  