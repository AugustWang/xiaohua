%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(loginServer).

%% add by wenziyong for gen server
-behaviour(gen_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-record(state, {socket}).

%%
%% Include files
%%
-include("db.hrl").
-include("playerDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("platformDefine.hrl").
-include("mailDefine.hrl").
-include("condition_compile.hrl").
-include("globalDefine.hrl").

-define(Reconnect_LoginServer_Interval_ms,5*1000).

%%
%% Exported Functions
%%
-compile(export_all).



start_link() ->
	gen_server:start_link({local,netLoginServer_PID},?MODULE, [], [{timeout,?Start_Link_TimeOut_ms}]).



init([]) ->
	IP = ini_ReadString( "GameServerSetup.txt", "LSIP", "127.0.0.1" ),
	Port = ini_ReadInt( "GameServerSetup.txt", "LSPort", 44802 ),
	%%开始面向loginserver的网络连接
	?LOG_OUT( "beginNetLoginServer start connect ip[~p] port:~p", [IP, Port] ),
	put("ConnectIP",IP),
	put("ConnectPort",Port),
	reconnectLoginUser().	

	


handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.



terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.




ini_ReadKey( IniFile, File, Key )->
	case io:get_line(File, '') of
		eof->
			throw(-1);
		{error, Reason }->
			?LOG_OUT( "ini_ReadKey IniFile[~p] Key[~p] getline false[~p]", [IniFile, Key, Reason] ),
			throw(-1);
		LineString->
			Tokens = string:tokens(LineString, "=\n"),
			case length( Tokens ) >= 2 of
				true->
					[ReadKey|Tokens2] = Tokens,
					case length( Tokens2 ) > 1 of
						true->[ReadValue|_] = Tokens2;
						false->ReadValue=Tokens2
					end,
					case ReadKey =:= Key of
						true->ReadValue;
						false->ini_ReadKey(IniFile, File, Key)
					end;
				false->ini_ReadKey(IniFile, File, Key)
			end
	end.

ini_ReadString( IniFile, Key, Default )->
	try
		put( "ini_ReadString_File", 0 ),
		case file:open(IniFile, read ) of
			{ok, File }->
				put( "ini_ReadString_File", File ),
				ReadValue = ini_ReadKey( IniFile, File, Key ),
				file:close(File),
				[Return|_] = ReadValue,
				Return;
			{error, Reason}->
				?LOG_OUT( "ini_ReadString IniFile[~p] Key[~p] file open false[~p]", [IniFile, Key, Reason] ),
				throw(-1);
			_->
				throw(-1)
		end
	catch
		_->
			File2 = get( "ini_ReadString_File" ),
			case File2 of
				0->ok;
				_->file:close(File2)
			end,
			Default
	end.

ini_ReadInt( IniFile, Key, Default )->
	ReadString = ini_ReadString( IniFile, Key, Default ),
	case ReadString =:= Default of
		true->Default;
		false->
			{Return,_}=string:to_integer( ReadString ),
			Return
	end.

%%loginserver的recieve
handle_info(Info, #state{socket=Socket} = StateData)->	
	put( "receiveLoginServer", true ),
	put("handle_info_state",StateData),
	

	try
	case Info of
	  {tcp,Socket,Data}->
		  case Socket of
			  undefined -> ok;
			  _ ->
				  inet:setopts(Socket,[{active,once}]),
				  doMsg(Socket,Data)
		  end;
	  { db_GS2LS_QueryUserMaxLevelResult, ToLS }->
		sendToLoginServer( ToLS );
	 {tcp_error, _Socket, Reason}->
		 ?ERROR_OUT( "receiveLoginServer closed reson[~p]", [Reason] ),
		 doLoginServerSocketClose(Socket, 0 );
		 %put( "receiveLoginServer", false );
     {tcp_closed,_Socket}->
		 ?LOG_OUT( "receiveLoginServer closed normal " ),
		 doLoginServerSocketClose(Socket, 0 );
		 %put( "receiveLoginServer", false );
	{ lsTimer_reconnectLoginserver }->
		case reconnectLoginUser() of
			{ok, State1}->put("handle_info_state",State1);
			_ -> erlang:send_after(?Reconnect_LoginServer_Interval_ms, self(),{lsTimer_reconnectLoginserver} )
		end;
	Unkown->
		?LOG_OUT("recv unkown msg:~p",Unkown)
	end,

	case get( "receiveLoginServer" ) of
		true->{noreply, get("handle_info_state")};
		false->{stop, normal, get("handle_info_state")}
	end

	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[?MODULE,_Why, erlang:get_stacktrace()] ),
			{noreply, get("handle_info_state")}
	end.




doLoginServerSocketClose(Socket, Reson )->
	?DEBUG_OUT( " the socket(to gs) is closed,reson:~p",[Reson] ),
	case Socket of
		undefined->ok;
		_ -> gen_tcp:close(Socket)
	end,
	etsBaseFunc:changeFiled( ?GlobalMainAtom, ?GlobalMainID, #globalMain.loginServerSocket, 0 ),
	put( "LoginServerSocket", undefined ),
	erlang:send_after(?Reconnect_LoginServer_Interval_ms,self(), {lsTimer_reconnectLoginserver} ),
	put("handle_info_state",#state{socket=undefined}).
	
reconnectLoginUser() ->
	IP = get( "ConnectIP" ),
	Port = get( "ConnectPort" ),
	case gen_tcp:connect(IP, Port, ?CONNECT_TCP_OPTIONS ) of
        {ok, Socket} ->
			PID = self(),
			gen_tcp:controlling_process(Socket, PID),	
			put( "LoginServerSocket", Socket ),	
			etsBaseFunc:changeFiled( ?GlobalMainAtom, ?GlobalMainID, #globalMain.loginServerSocket, Socket ),
			?LOG_OUT( "loginserver connected ." ),
			%%链接成功，发验证消息给loginserver
			timer:sleep( 1000 ),
			sendLoginMsg(),	
			inet:setopts(Socket,?TCP_OPTIONS),
			{ok, #state{socket=Socket}};
        {error, Reason} ->
            ?ERROR_OUT( "connect to loginserver error ~p", [Reason] ),
			{error, Reason};
		_->
           ?ERROR_OUT( "connect to loginserver error uknown" ),
		   {error,{init,unknow}}
    end.


doMsg(_S,<<>>) ->
	ok;

doMsg(S, Data) ->
	{Len,Count1} = common:binary_read_int16(0,Data),
	{CmdGet, Count2} = common:binary_read_int16(Count1,Data),

	Cmd = ( CmdGet band 16#7FF ),

	{_,<<Data1/binary>>} = split_binary(Data,Count1+Count2),
	msg_LS2GS:dealMsg(S, Cmd, Data1),
	Len2 = binary:referenced_byte_size(Data) - Len,
	if Len2 > 0 ->
		{_,<<Data2/binary>>} = split_binary(Data,Len), 
		doMsg(S,Data2);
	true ->
		ok
	end.

getLoginServerSocket()->
	Socket = get( "LoginServerSocket" ),
	case Socket of
		undefined->
			etsBaseFunc:getRecordField(?GlobalMainAtom,?GlobalMainID, #globalMain.loginServerSocket );
		_->Socket
	end.

sendToLoginServer( Msg )->
	Socket = getLoginServerSocket(),
	case Socket of
		0->
			?LOG_OUT( "sendToLoginServer Socket=0 Msg[~p]", [Msg] );
		_->
			msg_LS2GS:send(Socket, Msg)
	end.


ip_address() ->
    {ok, Hostname} = inet:gethostname(),
    {ok, Address}  = inet:getaddr(Hostname, inet),
	AList = tuple_to_list(Address),
	[A1|AList1] = AList,
	[A2|AList2] = AList1,
	[A3|AList3] = AList2,
	[A4|_] = AList3,
	String = io_lib:format( "~w.~w.~w.~w", [A1,A2,A3,A4] ),
	String2 = lists:flatten(String),
	String2.

sendLoginMsg()->
	DefaultIP = ip_address(),
	MyIP = ini_ReadString( "GameServerSetup.txt", "ListenToUserIP", DefaultIP ),
	Name = ini_ReadString( "GameServerSetup.txt", "name", MyIP ),
	ListenToUserPort = ini_ReadInt( "GameServerSetup.txt", "ListenToUserPort", 6789 ),
	Recommend = ini_ReadInt( "GameServerSetup.txt", "Recommend", 0 ),
	Hot = ini_ReadInt( "GameServerSetup.txt", "Hot", 0 ),
	Msg = #pk_GS2LS_Request_Login{serverID=common:formatString(main:getServerID()), name=Name, ip=MyIP, port=ListenToUserPort, remmond=Recommend, showInUserGameList=1,hot = Hot },
	sendToLoginServer( Msg ),
	ok.


on_pk_LS2GS_LoginResult(#pk_LS2GS_LoginResult{}=_Msg)->
	?LOG_OUT( "loginserver check pass " ),

	mainPID ! { loginServerCheckPass },
	
	ok.

on_LS2GS_QueryUserMaxLevel( #pk_LS2GS_QueryUserMaxLevel{}=Msg )->
	dbProcess_PID ! { ls_LS2GS_QueryUserMaxLevel, self(), Msg },
	?DEBUG_OUT( "on_LS2GS_QueryUserMaxLevel Msg[~p]  ", [Msg] ),
	ok.

ok_LS2GS_UserReadyToLogin( #pk_LS2GS_UserReadyToLogin{}=Msg )->
	?DEBUG_OUT( "ok_LS2GS_UserReadyToLogin Msg[~p] to main proc", [Msg] ),
	mainPID ! { onLS2GS_UserReadyToLogin, Msg }.

on_LS2GS_KickOutUser( #pk_LS2GS_KickOutUser{}=Msg )->
	mainPID ! { onLS2GS_KickOutUser, Msg }.

%%LS通知激活码发邮件给玩家
on_LS2GS_ActiveCode( #pk_LS2GS_ActiveCode{pidStr=PidStr,activeCode=ActiveCode, playerName=PlayerName, type=_} = _Msg )->
	try
		?LOG_OUT( "LS2GS_ActiveCode ActiveCode[~p] PlayerName[~p] begin", [ActiveCode, PlayerName] ),
		PlayerID = mySqlProcess:isPlayerExistByName( PlayerName ),
		case PlayerID =:= 0 of
			true->throw({return,?PLATFORM_RCODE_ACTIVE_CODE_NOPLAYER});
			false->ok
		end,
		
		ItemDataID = 2001,
		
		Ret = mail:sendSystemMailToPlayer( PlayerID, "system", "title", "", ItemDataID, 1, true, 0, 0, true, 0 ),
		case Ret =:= ?SendMailResult_Succ of
			true->throw( {return, 0} );
			false->throw( {return, ?PLATFORM_RCODE_ACTIVE_CODE_MAIL_FAILED})
		end,
		
		ok
	catch
		{ return, ReturnCode }->
			?LOG_OUT( "LS2GS_ActiveCode ActiveCode[~p] PlayerName[~p] ReturnCode[~p]", [ActiveCode, PlayerName, ReturnCode] ),
			MsgToLS = #pk_GS2LS_ActiveCode{pidStr=PidStr, activeCode=ActiveCode, retcode=ReturnCode },
			sendToLoginServer( MsgToLS ),
			ok
	end.

%%系统公告
on_LS2GS_Announce( #pk_LS2GS_Announce{pidStr=_PidStr,announceInfo = AnnounceInfo} = _Msg )->
	systemMessage:sendSysMsgToAllPlayer( AnnounceInfo ),
	ok.

%%平台充值
on_LS2GS_Recharge( #pk_LS2GS_Recharge{pidStr=PidStr,orderid=OrderID,platform=Platform,account=Account,userid=UserID,playerid=PlayerID,ammount=Ammount} = Msg )->
	?LOG_OUT( "on_LS2GS_Recharge  pkt[~p] ", [Msg] ),

	%% 获取玩家原有的金币数量
	{Ret,Gold_Old}=mySqlProcess:getGoldByPlayerID(PlayerID),
	case Ret of
		ok->
			Gold_Mod=Ammount*?RMB_GOLD_RATIO,
			%% 更改金币数量
			case mySqlProcess:addGoldForChargeByPlayerID(PlayerID,Gold_Mod) of
				{error,_}->
					%% 留日志
					logdbProcess:write_log_recharge_fail(OrderID,Platform,Account,UserID,PlayerID,Ammount),
					%% 给平台返回失败消息
					MsgToLS = #pk_GS2LS_Recharge{ pidStr=PidStr, orderid=OrderID, platform=Platform,retcode=?PLATFORM_RCODE_RECHARGE_FAILED},
					sendToLoginServer( MsgToLS );
				{ok,_}->
					%% 留日志
					logdbProcess:write_log_recharge_succ(OrderID,Platform,Account,UserID,PlayerID,Ammount),
					%{_,Gold_New}=mySqlProcess:getGoldByPlayerID(PlayerID),
					Gold_New=Gold_Old+Gold_Mod,
					%% 更改金币日志
					?LOG_OUT( "write_log_gold_add:[~p,~p,~p,~p,~p,~p] ", [PlayerID,Gold_Old,Gold_Mod,Gold_New,?Money_Change_Recharge,"Recharge"] ),
					logdbProcess:write_log_gold_add(PlayerID,Gold_Old,Gold_Mod,Gold_New,?Money_Change_Recharge,"Recharge"),
					%% 给平台返回充值成功消息
					MsgToLS = #pk_GS2LS_Recharge{ pidStr=PidStr, orderid=OrderID, platform=Platform,retcode=?PLATFORM_RCODE_RECHARGE_OK},
					sendToLoginServer( MsgToLS ),
			
					%% 玩家在线，给玩家进程发送消息，通知玩家进程刷新金币数量
					case player:getPlayerIsOnlineByID(PlayerID) of
						true->
							%% 在线玩家将消息转发到玩家进程
							case player:getPlayerPID(PlayerID) of 
								0->ok;
								PID->
									PID ! {refreshGold}
							end;

						false->ok
					end
			
			end;

		error->
			%% 留日志
			logdbProcess:write_log_recharge_fail(OrderID,Platform,Account,UserID,PlayerID,Ammount),
			%% 给平台返回失败消息
			MsgToLS = #pk_GS2LS_Recharge{ pidStr=PidStr, orderid=OrderID, platform=Platform,retcode=?PLATFORM_RCODE_RECHARGE_FAILED},
			sendToLoginServer( MsgToLS )
	end.

%%响应平台GM指令
on_LS2GS_Command( #pk_LS2GS_Command{pidStr=PidStr,num=Num,cmd=CMD,params=Params} = _Msg )->

	?LOG_OUT( "login server GM cmd[~p,~p,~p] ", [Num,CMD,Params] ),
	case CMD of
		?PLATFORM_COMMAND_SENDITEM->
		try
			%% playerName;itemList;Title;Content
			%% itemList:itemid,cnt,bind|itemid,cnt,bind
			StringTokens = string:tokens(Params, ";" ),
			ParamCount=length(StringTokens),
			%% 参数格式检查
			case ParamCount =:= 4 of
				true->ok;
				false->throw({return,?PLATFORM_RCODE_COMMAND_ERROR_PARAMS})
			end,
			[PlayerName,ItemList,Title,Content]=StringTokens, 
			?DEBUG_OUT( "login server GM cmd--------StringTokens:~p", [StringTokens] ),

			Ret = platformSendItem:sendItemToPlayerByPlayerName(PlayerName,ItemList,Title,Content),
			case Ret of
				noPlayer->throw({return,?PLATFORM_RCODE_COMMAND_NOPLAYER});
				exception->throw( {return, ?PLATFORM_RCODE_COMMAND_FAILED});
				fail->throw( {return, ?PLATFORM_RCODE_COMMAND_FAILED});
				ok->throw( {return, ?PLATFORM_RCODE_COMMAND_OK} )
			end,
			ok
		catch
			{ return, ReturnCode }->
				?LOG_OUT( "LS2GS_Command Num[~p] Cmd[~p] Params[~p] RetCode[~p]", [Num,CMD,Params,ReturnCode] ),
				MsgToLS = #pk_GS2LS_Command{pidStr=PidStr, num=Num,cmd=CMD,retcode=ReturnCode },
				sendToLoginServer( MsgToLS ),
				ok;
			_:_Why->
				?LOG_OUT( "LS2GS_Command Num[~p] Cmd[~p] exception", [Num,CMD] ),
				MsgToLS_ = #pk_GS2LS_Command{pidStr=PidStr,num=Num,cmd=CMD,retcode=?PLATFORM_RCODE_COMMAND_FAILED },
				sendToLoginServer( MsgToLS_ ),
				ok
		end;
		%% 给玩家发送物品扩展
		?PLATFORM_COMMAND_SENDITEM_EX->
		try
			%% levelMin;levelMax;itemList;money;money_b;gold;gold_b;exp;timeBegin;timeEnd;title;content
			%% itemList:itemid,cnt,bind|itemid,cnt,bind
			StringTokens = string:tokens(Params, ";" ),
			ParamCount=length(StringTokens),
			%% 参数格式检查
			case ParamCount =:= 12 of
				true->ok;
				false->throw({return,?PLATFORM_RCODE_COMMAND_ERROR_PARAMS})
			end,
			[LevelMin,LevelMax,ItemList,Money,MoneyB,Gold,GoldB,Exp,TimeBegin,TimeEnd,Title,Content]=StringTokens, 
			?DEBUG_OUT( "login server GM cmd--------StringTokens:~p", [StringTokens] ),
			{LevelMin_I,_}=string:to_integer(LevelMin),
			{LevelMax_I,_}=string:to_integer(LevelMax),
			{Money_I,_}=string:to_integer(Money),
			{MoneyB_I,_}=string:to_integer(MoneyB),
			{Gold_I,_}=string:to_integer(Gold),
			{GoldB_I,_}=string:to_integer(GoldB),
			{Exp_I,_}=string:to_integer(Exp),
			{TimeBegin_I,_}=string:to_integer(TimeBegin),
			{TimeEnd_I,_}=string:to_integer(TimeEnd),
	
			%% 将数据写入数据库表 platform_sendItem
			PlatformSendItemRecord=#platform_sendItem{id=0,levelMin=LevelMin_I,levelMax=LevelMax_I,itemList=ItemList,
								money=Money_I,money_b=MoneyB_I,gold=Gold_I,gold_b=GoldB_I,
								exp=Exp_I,flag=?PLATFORM_SENDITEM_FLAG_VALID,
								timeBegin=TimeBegin_I,timeEnd=TimeEnd_I,title=Title,content=Content},

			?DEBUG_OUT( "login server GM cmd---3-----info:~p", [PlatformSendItemRecord] ),
			
			_Ret=mySqlProcess:insert_platformSendItem(PlatformSendItemRecord),

			%% 广播在线玩家发放物品
			player:sendToAllPlayerProc({platformLoadAndSendItem}),

			throw( {return, ?PLATFORM_RCODE_COMMAND_OK} ),

			ok
		catch
			{ return, ReturnCode }->
				?LOG_OUT( "LS2GS_Command Num[~p] Cmd[~p] Params[~p] RetCode[~p]", [Num,CMD,Params,ReturnCode] ),
				MsgToLS = #pk_GS2LS_Command{pidStr=PidStr, num=Num,cmd=CMD,retcode=ReturnCode },
				sendToLoginServer( MsgToLS ),
				ok;
			_:_Why->
				?ERROR_OUT( "LS2GS_Command Num[~p] Cmd[~p] exception", [Num,CMD] ),
				MsgToLS_ = #pk_GS2LS_Command{pidStr=PidStr,num=Num,cmd=CMD,retcode=?PLATFORM_RCODE_COMMAND_FAILED },
				sendToLoginServer( MsgToLS_ ),
				ok
		end;
		%% 通知商城重新加载数据
		?PLATFORM_COMMAND_BAZZAR->
			?LOG_OUT( "login server GM cmd--------reloadDBItem ", [] ),
			bazzar:getPid() ! {reloadDBItem};

		%% 设置某角色为gm
		?PLATFORM_COMMAND_ADD_GM_USER->
		try
			%% playerName
			StringTokens = string:tokens(Params, ";"),
			ParamCount=length(StringTokens),
			%% 参数格式检查
			case ParamCount =:= 2 of
				true-> ok;
				false-> throw({return,?PLATFORM_RCODE_COMMAND_ERROR_PARAMS})
			end,
			[Value,PlayerName] = StringTokens, 
			?DEBUG_OUT( "login server GM cmd add gm user--------StringTokens:~p", [StringTokens]),
			case list_to_integer(Value) =:= 1 of
				true -> GmLevel = 2; %%设置用户为gm用户
				false -> GmLevel = 0 %%取消gm权限
			end,
			mySqlProcess:update_GmByPlayerName(GmLevel,PlayerName),
			?DEBUG_OUT("add gm user succ GmLevel: ~p, PlayerName:~p",[GmLevel, PlayerName]),
			throw({return, ?PLATFORM_RCODE_COMMAND_OK})
		catch
			{ return, ReturnCode }->
				?LOG_OUT( "LS2GS_Command Num[~p] Cmd[~p] Params[~p] RetCode[~p]", [Num,CMD,Params,ReturnCode] ),
				MsgToLS = #pk_GS2LS_Command{pidStr=PidStr, num=Num,cmd=CMD,retcode=ReturnCode },
				sendToLoginServer( MsgToLS ),
				ok;
			_:_Why->
				?LOG_OUT( "LS2GS_Command Num[~p] Cmd[~p] exception", [Num,CMD] ),
				MsgToLS_ = #pk_GS2LS_Command{pidStr=PidStr,num=Num,cmd=CMD,retcode=?PLATFORM_RCODE_COMMAND_FAILED },
				sendToLoginServer( MsgToLS_ ),
				ok
		end;

		?PLATFORM_COMMAND_KILLOUT_USER ->%% 踢角色下线
		try
			%% playerName
			StringTokens = string:tokens(Params, ";"),
			ParamCount=length(StringTokens),
			%% 参数格式检查
			case ParamCount =:= 1 of
				true-> ok;
				false-> throw({return,?PLATFORM_RCODE_COMMAND_ERROR_PARAMS})
			end,
			[PlayerName] = StringTokens, 
			?DEBUG_OUT( "login server GM cmd killout user--------StringTokens:~p", [StringTokens]),
			case player:getOnlinePlayerIDByName(PlayerName) of
				0 -> throw({return,?PLATFORM_RCODE_COMMAND_NOPLAYER});
				PlayerID -> mainPID ! { kickoutByPlayerId, PlayerID}
			end,
			?DEBUG_OUT("killout user succ PlayerName:~p",[PlayerName]),
			throw({return, ?PLATFORM_RCODE_COMMAND_OK})
		catch
			{ return, ReturnCode }->
				?LOG_OUT( "LS2GS_Command Num[~p] Cmd[~p] Params[~p] RetCode[~p]", [Num,CMD,Params,ReturnCode] ),
				MsgToLS = #pk_GS2LS_Command{pidStr=PidStr, num=Num,cmd=CMD,retcode=ReturnCode },
				sendToLoginServer( MsgToLS ),
				ok;
			_:_Why->
				?LOG_OUT( "LS2GS_Command Num[~p] Cmd[~p] exception", [Num,CMD] ),
				MsgToLS_ = #pk_GS2LS_Command{pidStr=PidStr,num=Num,cmd=CMD,retcode=?PLATFORM_RCODE_COMMAND_FAILED },
				sendToLoginServer( MsgToLS_ ),
				ok
		end;

		?PLATFORM_COMMAND_FORBIDDEN_USER_CHAT ->%% 禁止角色聊天
		try
			%% playerName
			StringTokens = string:tokens(Params, ";"),
			ParamCount=length(StringTokens),
			%% 参数格式检查
			case ParamCount =:= 2 of
				true-> ok;
				false-> throw({return,?PLATFORM_RCODE_COMMAND_ERROR_PARAMS})
			end,
			[Value, PlayerName] = StringTokens, 
			?DEBUG_OUT( "login server GM cmd forbidden user chat--------StringTokens:~p", [StringTokens]),
			ChatValue = list_to_integer(Value),
			case player:getOnlinePlayerIDByName(PlayerName) of
				0 -> ok;
				PlayerID -> %% notify online player to modify forbidChatFlag
					player:sendMsgToPlayerProcess(PlayerID, {changeForbidChatFlag, ChatValue})
			end,
			%% modify ForbidChatFlag in db
			mySqlProcess:update_forbidChatFlagByPlayerName(PlayerName, ChatValue),
			?DEBUG_OUT("forbidden user chat succ ChatValue: ~p, PlayerName:~p",[ChatValue, PlayerName]),
			throw({return, ?PLATFORM_RCODE_COMMAND_OK})
		catch
			{ return, ReturnCode }->
				?LOG_OUT( "LS2GS_Command Num[~p] Cmd[~p] Params[~p] RetCode[~p]", [Num,CMD,Params,ReturnCode] ),
				MsgToLS = #pk_GS2LS_Command{pidStr=PidStr, num=Num,cmd=CMD,retcode=ReturnCode },
				sendToLoginServer( MsgToLS ),
				ok;
			_:_Why->
				?LOG_OUT( "LS2GS_Command Num[~p] Cmd[~p] exception", [Num,CMD] ),
				MsgToLS_ = #pk_GS2LS_Command{pidStr=PidStr,num=Num,cmd=CMD,retcode=?PLATFORM_RCODE_COMMAND_FAILED },
				sendToLoginServer( MsgToLS_ ),
				ok
		end;

		?PLATFORM_COMMAND_SWITCH_USERID -> %% 将某帐号下某角色的userid转换到某帐号下
		try
			%% SrcUserID; DesUserID
			StringTokens = string:tokens(Params, ";"),
			ParamCount=length(StringTokens),
			%% 参数格式检查
			case ParamCount =:= 2 of
				true-> ok;
				false-> throw({return,?PLATFORM_RCODE_COMMAND_ERROR_PARAMS})
			end,
			[SrcUserID, DesUserID] = StringTokens, 
			?DEBUG_OUT( "login server GM cmd switch userid--------StringTokens:~p", [StringTokens]),
			mySqlProcess:update_userIDByPlatUserId(SrcUserID, DesUserID),
			?LOG_OUT("switch userid succ SrcUserID:~p, DesUserID:~p",[SrcUserID,DesUserID]),
			throw({return, ?PLATFORM_RCODE_COMMAND_OK})
		catch
			{ return, ReturnCode }->
				?LOG_OUT( "LS2GS_Command Num[~p] Cmd[~p] Params[~p] RetCode[~p]", [Num,CMD,Params,ReturnCode] ),
				MsgToLS = #pk_GS2LS_Command{pidStr=PidStr, num=Num,cmd=CMD,retcode=ReturnCode },
				sendToLoginServer( MsgToLS ),
				ok;
			_:_Why->
				?LOG_OUT( "LS2GS_Command Num[~p] Cmd[~p] exception", [Num,CMD] ),
				MsgToLS_ = #pk_GS2LS_Command{pidStr=PidStr,num=Num,cmd=CMD,retcode=?PLATFORM_RCODE_COMMAND_FAILED },
				sendToLoginServer( MsgToLS_ ),
				ok
		end;

		_->
			?LOG_OUT( "login server received invalid GM cmd[~p,~p,~p] ", [Num,CMD,Params] )
	end.
		








