%% 与平台对接的消息结构定义

-module(msg_LS2Platform).
-export([readMsg/1,sendMsg/2,dealMsg/4]).
-import(messageBase, [read_string/1, read_int/1,  read_int8/1,  read_int16/1, write_array/2,
             		 write_string/1, write_int/1,  write_int8/1,  write_int16/1, write_int64/1,read_array/2, sendPackage/3] ).
-import(common, [binary_read_int64/1,binary_read_int64/2,binary_read_int16/2, binary_read_int16/1,binary_read_int/2, binary_read_int/1, binary_read_int8/2,  binary_read_string/2, binary_read_array_head16/3]).

-include("package.hrl").
-include("platformDefine.hrl").
-include("hdlt_logger.hrl").
-include("logindb.hrl").

readMsg(Data)->
	DataSize = binary:referenced_byte_size(Data),
	{Len,Count1} = common:binary_read_int(0,Data),
	{Cmd,Count2} = common:binary_read_int(Count1,Data),

	case (Len < ?CMD_PLATFORM_553_HEADER_SIZE) or (Len > ?CMD_PLATFORM_553_MAX_SIZE) or (Len > DataSize) of
		true->
			{error,0,0,0};
		false->
			{_,<<Data1/binary>>} = split_binary(Data,Count1+Count2),
			{ok,Len,Cmd,Data1}
	end.

readPlatform553Command(Bin)->
	IndexIn0=0,
        {GSID,IndexOut0}=common:binary_read_int(IndexIn0,Bin),
        IndexIn1=IndexIn0+IndexOut0,
        {Num,IndexOut1}=common:binary_read_int(IndexIn1,Bin),
        IndexIn2=IndexIn1+IndexOut1,
        {Cmd,IndexOut2}=common:binary_read_int(IndexIn2,Bin),
        IndexIn3=IndexIn2+IndexOut2,
        {Params,IndexOut3}=common:binary_read_string(IndexIn3,Bin),
        IndexIn4=IndexIn3+IndexOut3,
        {Time,IndexOut4}=common:binary_read_string(IndexIn4,Bin),
        IndexIn5=IndexIn4+IndexOut4,
        {Sign,IndexOut5}=common:binary_read_string(IndexIn5,Bin),
        IndexIn6=IndexIn5+IndexOut5,

        {_,LeftBin} = split_binary(Bin,IndexIn6),
        {#pk_LS2Platform553_Command{
		len=0,
		commmand=0,
		gsid=GSID,
                num=Num,
                cmd=Cmd,
                params=Params,
		time=Time,
		sign=Sign
        },
        LeftBin,
        IndexIn6
        }.

readPlatform553Announce(Bin)->
	IndexIn0=0,
        {GSID,IndexOut0}=common:binary_read_int(IndexIn0,Bin),
        IndexIn1=IndexIn0+IndexOut0,
        {AnnounceInfo,IndexOut1}=common:binary_read_string(IndexIn1,Bin),
        IndexIn2=IndexIn1+IndexOut1,

        {_,LeftBin} = split_binary(Bin,IndexIn2),
        {#pk_LS2Platform553_Announce{
		len=0,
		commmand=0,
		gsid=GSID,
                announceinfo=AnnounceInfo
        },
        LeftBin,
        IndexIn2
        }.

readPlatform553AddGsConfig(Bin)->
	IndexIn0=0,
        {Serverid,IndexOut0}=common:binary_read_string(IndexIn0,Bin),
        IndexIn1=IndexIn0+IndexOut0,
        {Name,IndexOut1}=common:binary_read_string(IndexIn1,Bin),
        IndexIn2=IndexIn1+IndexOut1,
        {Isnew,IndexOut2}=common:binary_read_int(IndexIn2,Bin),
        IndexIn3=IndexIn2+IndexOut2,
        {Begintime,IndexOut3}=common:binary_read_string(IndexIn3,Bin),
        IndexIn4=IndexIn3+IndexOut3,
		{Recommend,IndexOut4}=common:binary_read_int(IndexIn4,Bin),
        IndexIn5=IndexIn4+IndexOut4,
		{Hot,IndexOut5}=common:binary_read_int(IndexIn5,Bin),
        IndexIn6=IndexIn5+IndexOut5,
        {_,LeftBin} = split_binary(Bin,IndexIn6),
        {#pk_LS2Platform553_Add_GsConfig{
		len=0,
		commmand=0,
                serverid=Serverid,
		name=Name,
                isnew=Isnew,
		begintime =Begintime,
				recommend = Recommend,
		hot= Hot	 
        },
        LeftBin,
        IndexIn6
        }.

readPlatform553SubGsConfig(Bin)->
	IndexIn0=0,
        {Serverid,IndexOut0}=common:binary_read_string(IndexIn0,Bin),
        IndexIn1=IndexIn0+IndexOut0,
        {_,LeftBin} = split_binary(Bin,IndexIn1),
        {#pk_LS2Platform553_Sub_GsConfig{
		len=0,
		commmand=0,
                serverid=Serverid		
        },
        LeftBin,
        IndexIn1
        }.


readPlatform553ActiveCode(Bin)->
	IndexIn0=0,
        {ActiveCode,IndexOut0}=common:binary_read_string(IndexIn0,Bin),
        IndexIn1=IndexIn0+IndexOut0,
        {GSID,IndexOut1}=common:binary_read_int(IndexIn1,Bin),
        IndexIn2=IndexIn1+IndexOut1,
        {PlayerName,IndexOut2}=common:binary_read_string(IndexIn2,Bin),
        IndexIn3=IndexIn2+IndexOut2,
        {Type,IndexOut3}=common:binary_read_int(IndexIn3,Bin),
        IndexIn4=IndexIn3+IndexOut3,

        {_,LeftBin} = split_binary(Bin,IndexIn4),
        {#pk_LS2Platform553_Active_Code{
		len=0,
		commmand=0,
                activecode=ActiveCode,
		gsid=GSID,
                player=PlayerName,
		type=Type
        },
        LeftBin,
        IndexIn4
        }.

readPlatform553Recharge(Bin)->
	IndexIn0=0,
        {OrderID,IndexOut0}=common:binary_read_string(IndexIn0,Bin),
        IndexIn1=IndexIn0+IndexOut0,
        {Platform,IndexOut1}=common:binary_read_int(IndexIn1,Bin),
        IndexIn2=IndexIn1+IndexOut1,
        {LSID,IndexOut2}=common:binary_read_int(IndexIn2,Bin),
        IndexIn3=IndexIn2+IndexOut2,
        {GSID,IndexOut3}=common:binary_read_int(IndexIn3,Bin),
        IndexIn4=IndexIn3+IndexOut3,
        {Account,IndexOut4}=common:binary_read_string(IndexIn4,Bin),
        IndexIn5=IndexIn4+IndexOut4,
        {UserID,IndexOut5}=common:binary_read_string(IndexIn5,Bin),
        IndexIn6=IndexIn5+IndexOut5,
        {PlayerID,IndexOut6}=common:binary_read_string(IndexIn6,Bin),
        IndexIn7=IndexIn6+IndexOut6,
        {Ammount,IndexOut7}=common:binary_read_int(IndexIn7,Bin),
        IndexIn8=IndexIn7+IndexOut7,
        {Time,IndexOut8}=common:binary_read_string(IndexIn8,Bin),
        IndexIn9=IndexIn8+IndexOut8,
        {Sign,IndexOut9}=common:binary_read_string(IndexIn9,Bin),
        IndexIn10=IndexIn9+IndexOut9,

        {_,LeftBin} = split_binary(Bin,IndexIn10),
        {#pk_LS2Platform553_Recharge{
		len=0,
		commmand=0,
                orderid=OrderID,
		platform=Platform,
		lsid=LSID,
		gsid=GSID,
                account=Account,
		userid=UserID,
		playerid=PlayerID,
                ammount=Ammount,
		time=Time,
		sign=Sign
        },
        LeftBin,
        IndexIn10
        }.

sendMsg(Socket,#pk_LS2Platform553_Command_Ret{}=P)->
        Bin0=messageBase:write_int(P#pk_LS2Platform553_Command_Ret.len),
        Bin1=messageBase:write_int(P#pk_LS2Platform553_Command_Ret.commmand),
        Bin2=messageBase:write_int(P#pk_LS2Platform553_Command_Ret.num),
        Bin3=messageBase:write_int(P#pk_LS2Platform553_Command_Ret.cmd),
        Bin4=messageBase:write_int(P#pk_LS2Platform553_Command_Ret.retcode),
        Bin = <<Bin0/binary,Bin1/binary,Bin2/binary,Bin3/binary,Bin4/binary>>,
		?DEBUG_OUT("-----send platform command ret:~p",[Bin]),
	Result=gen_tcp:send(Socket,Bin),
	Result;

sendMsg(Socket,#pk_LS2Platform553_Active_Code_Ret{}=P)->
        Bin0=messageBase:write_int(P#pk_LS2Platform553_Active_Code_Ret.len),
        Bin1=messageBase:write_int(P#pk_LS2Platform553_Active_Code_Ret.commmand),
        Bin2=messageBase:write_string(P#pk_LS2Platform553_Active_Code_Ret.activecode),
        Bin3=messageBase:write_int(P#pk_LS2Platform553_Active_Code_Ret.retcode),
        Bin = <<Bin0/binary,Bin1/binary,Bin2/binary,Bin3/binary>>,
		?LOG_OUT("-----send active code ret:~p",[Bin]),
	Result=gen_tcp:send(Socket,Bin),
	Result;

sendMsg(Socket,#pk_LS2Platform553_Recharge_Ret{}=P)->
        Bin0=messageBase:write_int(P#pk_LS2Platform553_Recharge_Ret.len),
        Bin1=messageBase:write_int(P#pk_LS2Platform553_Recharge_Ret.commmand),
        Bin2=messageBase:write_string(P#pk_LS2Platform553_Recharge_Ret.orderid),
        Bin3=messageBase:write_int(P#pk_LS2Platform553_Recharge_Ret.platform),
        Bin4=messageBase:write_int(P#pk_LS2Platform553_Recharge_Ret.retcode),
        Bin = <<Bin0/binary,Bin1/binary,Bin2/binary,Bin3/binary,Bin4/binary>>,
	Result=gen_tcp:send(Socket,Bin),
	Result;

sendMsg(Socket,#pk_LS2Platform553_Add_GsConfig_Ret{}=P)->
        Bin0=messageBase:write_int(P#pk_LS2Platform553_Add_GsConfig_Ret.len),
        Bin1=messageBase:write_int(P#pk_LS2Platform553_Add_GsConfig_Ret.commmand),
        Bin2=messageBase:write_string(P#pk_LS2Platform553_Add_GsConfig_Ret.serverid),
        Bin3=messageBase:write_int(P#pk_LS2Platform553_Add_GsConfig_Ret.ret),        
        Bin = <<Bin0/binary,Bin1/binary,Bin2/binary,Bin3/binary>>,
	Result=gen_tcp:send(Socket,Bin),
	Result;
sendMsg(Socket,#pk_LS2Platform553_Sub_GsConfig_Ret{}=P)->
        Bin0=messageBase:write_int(P#pk_LS2Platform553_Sub_GsConfig_Ret.len),
        Bin1=messageBase:write_int(P#pk_LS2Platform553_Sub_GsConfig_Ret.commmand),
        Bin2=messageBase:write_string(P#pk_LS2Platform553_Sub_GsConfig_Ret.serverid),
        Bin3=messageBase:write_int(P#pk_LS2Platform553_Sub_GsConfig_Ret.ret),        
        Bin = <<Bin0/binary,Bin1/binary,Bin2/binary,Bin3/binary>>,
	Result=gen_tcp:send(Socket,Bin),
	Result;

sendMsg(_,_)->
	ok.

dealMsg(Socket,Len,Cmd,Data)->
	case Cmd of
		?CMD_PLATFORM_553_RECHARGE->
			?DEBUG_OUT("platform 553 dealMsg 000...",[]),
			try
				{P,_,_}=readPlatform553Recharge(Data),
				onMessage(Socket,P)
			catch
				_-> 
				?LOG_OUT("platform 553 dealMsg recharge exception...",[])
			end;
		?CMD_PLATFORM_553_ACTIVE_CODE->
			?DEBUG_OUT("---platform 553 dealMsg active code...",[]),
			try
				{P,_,_}=readPlatform553ActiveCode(Data),
				onMessage(Socket,P)
			catch
				_-> 
				?LOG_OUT("platform 553 dealMsg active code exception...",[])
			end;
		?CMD_PLATFORM_553_ANNOUNCE->
			?DEBUG_OUT("---platform 553 dealMsg announce ...",[]),
			try
				%% 消息最大长度检查
				case Len > ?CMD_PLATFORM_553_ANNOUNCE_MAX_SIZE of
					true->throw(-1);
					false->ok
				end,

				{P,_,_}=readPlatform553Announce(Data),
				onMessage(Socket,P)
			catch
				-1->
				?LOG_OUT("platform 553 dealMsg announce too long...",[]);
				_-> 
				?LOG_OUT("platform 553 dealMsg announce exception...",[])
			end;
		?CMD_PLATFORM_553_COMMAND->
			?DEBUG_OUT("---platform 553 dealMsg GM command...",[]),
			try
				{P,_,_}=readPlatform553Command(Data),
				onMessage(Socket,P)
			catch
				_-> 
				?LOG_OUT("platform 553 dealMsg GM command exception...",[])
			end;
		?CMD_PLATFORM_553_ADD_GSCONFIG->
			?DEBUG_OUT("---platform 553 dealMsg add gs config ...",[]),
			try
				{P,_,_}=readPlatform553AddGsConfig(Data),
				onMessage(Socket,P)
			catch
				_-> 
				?LOG_OUT("platform 553 dealMsg add gs config exception...",[])
			end;
		?CMD_PLATFORM_553_SUB_GSCONFIG->
			?DEBUG_OUT("---platform 553 dealMsg sub gs config ...",[]),
			try
				{P,_,_}=readPlatform553SubGsConfig(Data),
				onMessage(Socket,P)
			catch
				_-> 
				?LOG_OUT("platform 553 dealMsg sub gs config exception...",[])
			end;
		_->
			?LOG_OUT("platform 553 dealMsg Socket[~p] recved invalid Cmd[~p].",[Socket,Cmd])
	end.

onMessage(Socket,#pk_LS2Platform553_Command{}=P)->
	GSID=P#pk_LS2Platform553_Command.gsid,
	Num=P#pk_LS2Platform553_Command.num,
	Cmd=P#pk_LS2Platform553_Command.cmd,
	Params=P#pk_LS2Platform553_Command.params,
	Time=P#pk_LS2Platform553_Command.time,
	Sign=P#pk_LS2Platform553_Command.sign,
	?DEBUG_OUT("platform 553 onMessage command :[~p],[~p],[~p],[~p],[~p],[~p]",[GSID,Num,Cmd,Params,Time,Sign]),

	case Cmd of
		?PLATFORM_COMMAND_ADD_WHITE_USER -> %% 设置白名单
			try
				%% platformId; playerName
				StringTokens = string:tokens(Params, ";"),
				ParamCount = length(StringTokens),
				%% 参数格式检查
				case ParamCount =:= 3 of
					true-> ok;
					false-> throw(?PLATFORM_RCODE_COMMAND_ERROR_PARAMS)
				end,
				[FlagValue, PlatformId, UserName] = StringTokens,
				Flag = list_to_integer(FlagValue),
				?LOG_OUT( "login server GM cmd add white user--------PlatformId:~p, UserName: ~p", [PlatformId,UserName]),
				case loginMysqlProc:get_userId(PlatformId, UserName) of %%取出userID
					{ok,UserID}->
						case UserID =:= 0 of
							true -> throw(?PLATFORM_RCODE_RECHARGE_NOPLAYER);
							false -> ok
						end,
						case Flag =:= 1 of
							true ->
								case loginMysqlProc:insertUser4Test(#user4test{id = UserID}) of %%插入user4test表中
									{error, _} -> throw(?PLATFORM_RCODE_RECHARGE_FAILED);
									_ -> ok
								end;
							false ->
								case loginMysqlProc:deleteUser4TestById(#user4test{id = UserID}) of %%从user4test表中删除指定userID
									{error, _} -> throw(?PLATFORM_RCODE_RECHARGE_FAILED);
									_ -> ok
								end								
						end,
						?DEBUG_OUT("add white user succ PlatformId: ~p, UserID: ~p, UserName:~p",[PlatformId,UserID,UserName]),
						throw(?PLATFORM_RCODE_COMMAND_OK);
					{error, _ }-> throw(?PLATFORM_RCODE_RECHARGE_FAILED)
				end
			catch
				ReturnCode ->
					PkResult = #pk_LS2Platform553_Command_Ret{ len=20,commmand=?CMD_PLATFORM_553_COMMAND_RET,
							num=Num, cmd=Cmd, retcode= ReturnCode},
					sendMsg(Socket, PkResult)	
			end;
		
		?PLATFORM_COMMAND_ADD_FORBIDDEN_USER_LOGIN -> %% 禁止帐户登陆
			try
				%% account; flag; timeEnd
				StringTokens = string:tokens(Params, ";"),
				ParamCount = length(StringTokens),
				%% 参数格式检查
				case ParamCount =:= 4 of
					true-> ok;
					false-> throw(?PLATFORM_RCODE_COMMAND_ERROR_PARAMS)
				end,
				[FlagValue, Account, Flag, TimeEnd] = StringTokens,
				DeleteFlag = list_to_integer(FlagValue),
				?LOG_OUT( "login server GM cmd forbidden user login--------Account:~p, Flag:~p, TimeEnd: ~p", [Account, Flag, TimeEnd]),
				case DeleteFlag =:= 1 of
					true ->
						case loginMysqlProc:insertForbidden(#forbidden{account = Account, flag = Flag, reason = "", timeBegin = 0, timeEnd = TimeEnd}) of %%插入forbidden表中
							{error, _} -> throw(?PLATFORM_RCODE_RECHARGE_FAILED);
							_ -> ok
						end;
					false ->
						case loginMysqlProc:deleteForbiddenByAccount(Account) of %%从forbidden表中删除指定帐号
							{error, _} -> throw(?PLATFORM_RCODE_RECHARGE_FAILED);
							_ -> ok
						end
				end,
				?DEBUG_OUT("forbidden user login succ Account: ~p, Flag:~p, TimeEnd:~p",[Account,Flag,TimeEnd]),
				throw(?PLATFORM_RCODE_COMMAND_OK)
			catch
				ReturnCode ->
					PkResult = #pk_LS2Platform553_Command_Ret{ len=20,commmand=?CMD_PLATFORM_553_COMMAND_RET,
							num=Num, cmd=Cmd, retcode= ReturnCode},
					sendMsg(Socket, PkResult)	
			end;
		
		?PLATFORM_COMMAND_FORBIDDEN_ACCOUNT -> %% 限定帐号
			try
				%% account; Ip
				StringTokens = string:tokens(Params, ";"),
				ParamCount = length(StringTokens),
				%% 参数格式检查
				case ParamCount =:= 3 of
					true-> ok;
					false-> throw(?PLATFORM_RCODE_COMMAND_ERROR_PARAMS)
				end,
				[FlagValue, Account, Ip] = StringTokens,
				Flag = list_to_integer(FlagValue),
				?LOG_OUT( "login server GM forbidden account--------Account:~p, Ip:~p", [Account, Ip]),
				case Flag =:= 1 of
					true ->
						case loginMysqlProc:insertPlatFormTest(#platform_test{account = Account, ip = Ip}) of %%插入platform_test表中
							{error, _} -> throw(?PLATFORM_RCODE_RECHARGE_FAILED);
							_ -> ok
						end;
					false ->
						case loginMysqlProc:deletePlatFormTestByAccountAndIp(#platform_test{account = Account, ip = Ip}) of %%从platform_test表中删除指定ip的指定帐号
							{error, _} -> throw(?PLATFORM_RCODE_RECHARGE_FAILED);
							_ -> ok
						end
				end,
				?DEBUG_OUT("forbidden account Account: ~p, Ip:~p",[Account,Ip]),
				throw(?PLATFORM_RCODE_COMMAND_OK)
			catch
				ReturnCode ->
					PkResult = #pk_LS2Platform553_Command_Ret{ len=20,commmand=?CMD_PLATFORM_553_COMMAND_RET,
							num=Num, cmd=Cmd, retcode= ReturnCode},
					sendMsg(Socket, PkResult)	
			end;
		
		?PLATFORM_COMMAND_SWITCH_USERID -> %% 将某帐号下某角色的userid转换到某帐号下
			try
				%% platformSrcId;userSrcName;platformDesId;userDesName
				StringTokens = string:tokens(Params, ";"),
				ParamCount = length(StringTokens),
				%% 参数格式检查
				case ParamCount =:= 4 of
					true-> ok;
					false-> throw(?PLATFORM_RCODE_COMMAND_ERROR_PARAMS)
				end,
				[PlatformSrcId,UserSrcName,PlatformDesId,UserDesName] = StringTokens, 
				?LOG_OUT( "login server GM cmd switch userid--------StringTokens: ~p", [StringTokens]),
				case loginMysqlProc:get_userId(PlatformSrcId, UserSrcName) of %%取出userID
					{ok,SrcUserID}->
						case SrcUserID =:= 0 of
							true -> throw(?PLATFORM_RCODE_RECHARGE_FAILED);
							false -> ok
						end,
						?LOG_OUT( "login server GM cmd switch userSrcid--------UserSrcID: ~p", [SrcUserID]),
						case loginMysqlProc:get_userId(PlatformDesId, UserDesName) of %%取出userID
							{ok,DesUserID}->
								case DesUserID =:= 0 of
									true -> throw(?PLATFORM_RCODE_RECHARGE_FAILED);
									false -> 
										?LOG_OUT( "login server GM cmd switch userSrcid--------UserDesID: ~p", [DesUserID]),
										Params1 = integer_to_list(SrcUserID)++";"++integer_to_list(DesUserID),
										sendMessageToGameServer(Num, Cmd, Time, Sign, GSID, Params1, Socket, P),
										throw(0)
								end;
							{error, _ }-> throw(?PLATFORM_RCODE_RECHARGE_FAILED)
						end;					
					{error, _ }-> throw(?PLATFORM_RCODE_RECHARGE_FAILED)
				end
			catch
				0 -> ok;
				ReturnCode ->
					PkResult = #pk_LS2Platform553_Command_Ret{ len=20,commmand=?CMD_PLATFORM_553_COMMAND_RET,
							num=Num, cmd=Cmd, retcode= ReturnCode},
					sendMsg(Socket, PkResult)	
			end;
		_ ->
			%% 将消息转发至GameServer
			sendMessageToGameServer(Num, Cmd, Time, Sign, GSID, Params, Socket, P)
	end,
	ok;


onMessage(Socket,#pk_LS2Platform553_Announce{}=P)->
	GSID=P#pk_LS2Platform553_Announce.gsid,
	AnnounceInfo=P#pk_LS2Platform553_Announce.announceinfo,
	?DEBUG_OUT("platform 553 onMessage announce :[~p],[~p]",[GSID,AnnounceInfo]),
	%% 将消息转发至GameServer
	try 
		Gsidstr = common:formatString( GSID ),
		GameServer = gameServer:getGameServerRecord( Gsidstr ),
		case GameServer of
			{}->throw(-1);
			_->ok
		end,	
		PidStr = pid_to_list(self()),
		gameServer:sendToGameServerByServerID( Gsidstr, #pk_LS2GS_Announce{pidStr=PidStr,announceInfo=AnnounceInfo})
	catch
		_-> 
			% send msg to platform, the gs is not online
			?LOG_OUT("---the gs not online,no need send announce msg to platform ")
			%Pkt = #pk_LS2Platform553_Active_Code_Ret{ len=string:len(ActiveCode)+12+2,commmand=?CMD_PLATFORM_553_ACTIVE_CODE_RET,
			%		activecode=ActiveCode,retcode=?PLATFORM_RCODE_ACTIVE_CODE_NOGS},
			%sendMsg(Socket,Pkt)
	end,

	ok;

onMessage(Socket,#pk_LS2Platform553_Active_Code{}=P)->
	ActiveCode=P#pk_LS2Platform553_Active_Code.activecode,
	GSID=P#pk_LS2Platform553_Active_Code.gsid,
	PlayerName=P#pk_LS2Platform553_Active_Code.player,
	Type=P#pk_LS2Platform553_Active_Code.type,
	?DEBUG_OUT("platform 553 onMessage active code:[~p],[~p],[~p],[~p]",[ActiveCode,GSID,PlayerName,Type]),
	%% 将消息转发至GameServer
	try 
		Gsidstr = common:formatString( GSID ),
		GameServer = gameServer:getGameServerRecord( Gsidstr ),
		case GameServer of
			{}->throw(-1);
			_->ok
		end,	

		PidStr = pid_to_list(self()),
		gameServer:sendToGameServerByServerID( Gsidstr, #pk_LS2GS_ActiveCode{pidStr=PidStr,activeCode=ActiveCode,playerName=PlayerName, type=Type})
	catch
		_-> 
			% send msg to platform, the gs is not online
			?LOG_OUT("---the gs not online,send msg to platform "),
			Pkt = #pk_LS2Platform553_Active_Code_Ret{ len=string:len(ActiveCode)+12+2,commmand=?CMD_PLATFORM_553_ACTIVE_CODE_RET,
					activecode=ActiveCode,retcode=?PLATFORM_RCODE_ACTIVE_CODE_NOGS},
			sendMsg(Socket,Pkt)
	end,

	ok;

onMessage(Socket,#pk_LS2Platform553_Recharge{}=P)->
	OrderID=P#pk_LS2Platform553_Recharge.orderid,
	Platform=P#pk_LS2Platform553_Recharge.platform,
	LSID=P#pk_LS2Platform553_Recharge.lsid,
	GSID=P#pk_LS2Platform553_Recharge.gsid,
	Account=P#pk_LS2Platform553_Recharge.account,
	UserID=P#pk_LS2Platform553_Recharge.userid,
	PlayerID=P#pk_LS2Platform553_Recharge.playerid,
	Ammount=P#pk_LS2Platform553_Recharge.ammount,
	Time=P#pk_LS2Platform553_Recharge.time,
	Sign=P#pk_LS2Platform553_Recharge.sign,
	?DEBUG_OUT("platform 553 onMessage recharge:[~p],[~p],[~p],[~p],[~p],[~p],[~p],[~p],[~p],[~p]",[OrderID,Platform,LSID,GSID,Account,UserID,PlayerID,Ammount,Time,Sign]),

	%% 将消息转发至GameServer
	try 
		case md5:encrypt(OrderID++common:formatString(Ammount)++Time++?KEY_PLATFORM_553_RECHARGE) of
        		Sign->
                		ok;
        		_->
                		throw(-9)
		end,

		Gsidstr = common:formatString( GSID ),
		GameServer = gameServer:getGameServerRecord( Gsidstr ),

		case GameServer of
			{}->throw(-1);
			_->ok
		end,	

		?DEBUG_OUT("---send msg to gameserver---- "),
		{UserID0,Left}=string:to_integer(UserID),
		{PlayerID0,Left}=string:to_integer(PlayerID),
		PidStr = pid_to_list(self()),
		gameServer:sendToGameServerByServerID( Gsidstr, #pk_LS2GS_Recharge{	pidStr=PidStr,
											orderid=OrderID,
											platform=Platform, 
											account=Account, 
											userid=UserID0, 
											playerid=PlayerID0, 
											ammount=Ammount})
	catch
		-9->
			?LOG_OUT("invalid platform recharge packet[~p]",[P]);
		_-> 
			% send msg to platform, the gs is not online
			?LOG_OUT("---the gs not online,send msg to platform "),
			Pkt = #pk_LS2Platform553_Recharge_Ret{ len=string:len(OrderID)+16+2,commmand=?CMD_PLATFORM_553_RECHARGE_RET,
					orderid=OrderID,platform=Platform,retcode=?PLATFORM_RCODE_RECHARGE_NOGS},
			sendMsg(Socket,Pkt)
	end,

	ok;

onMessage(Socket,#pk_LS2Platform553_Add_GsConfig{}=P)->
	Serverid=P#pk_LS2Platform553_Add_GsConfig.serverid,
	Name=P#pk_LS2Platform553_Add_GsConfig.name,
	Isnew=P#pk_LS2Platform553_Add_GsConfig.isnew,
	Begintime=P#pk_LS2Platform553_Add_GsConfig.begintime,
	Recommend=P#pk_LS2Platform553_Add_GsConfig.recommend,
	Hot=P#pk_LS2Platform553_Add_GsConfig.hot,
	?DEBUG_OUT("platform 553 onMessage add gs config:[~p],[~p],[~p],[~p],[~p],[~p]",[Serverid,Name,Isnew,Begintime,Recommend,Hot]),
	
	gameServer:addGsConfig( Serverid, Name, Isnew, Begintime,Recommend,Hot),
	ok;

onMessage(Socket,#pk_LS2Platform553_Sub_GsConfig{}=P)->
	Serverid=P#pk_LS2Platform553_Sub_GsConfig.serverid,	
	?DEBUG_OUT("platform 553 onMessage sub gs config:[~p]",[Serverid]),
	
	gameServer:subGsConfig( Serverid ),
	ok;

onMessage(_,_)->
	ok.

sendMessageToGameServer(Num, Cmd, Time, Sign, GSID, Params, Socket, P) ->
	%% 将消息转发至GameServer
	try 
		case md5:encrypt(common:formatString(Num)++common:formatString(Cmd)++Time++?KEY_PLATFORM_553_COMMAND) of
        		Sign->
                		ok;
        		_->
                		throw(-9)
		end,

		Gsidstr = common:formatString( GSID ),
		GameServer = gameServer:getGameServerRecord( Gsidstr ),

		case GameServer of
			{}->throw(-1);
			_->ok
		end,	
		PidStr = pid_to_list(self()),
		gameServer:sendToGameServerByServerID( Gsidstr, #pk_LS2GS_Command{pidStr=PidStr,num=Num,cmd=Cmd,params=Params})
	catch
		-9->
			?LOG_OUT("invalid platform command packet[~p] ",[P]);
		_-> 
			% send msg to platform, the gs is not online
			?LOG_OUT("---the gs not online,send command msg to platform "),
			Pkt = #pk_LS2Platform553_Command_Ret{ len=20,commmand=?CMD_PLATFORM_553_COMMAND_RET,
					num=Num,cmd=Cmd,retcode=?PLATFORM_RCODE_COMMAND_NOGS},
			sendMsg(Socket,Pkt)
	end.
