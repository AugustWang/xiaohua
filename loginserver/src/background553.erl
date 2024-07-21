%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(background553).

%% because background 553 always use short connection, not use gen_server 
%% add by wenziyong for gen server
%% -behaviour(gen_server).
%% -export([start_link/1]).
%% -export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
%% -record(state, {socket, addr}).
%% -define(TIMEOUT, 120000).



%%
%% Include files
%%
-include("db.hrl").
-include("userDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
%-include("gameServerDefine.hrl").
-include("condition_compile.hrl").
-include("platformDefine.hrl").
-include("gameServerDefine.hrl").
-include("globalDef.hrl").
-include_lib("stdlib/include/ms_transform.hrl").


%%
%% Exported Functions
%%
-compile(export_all).


%% start_link(Socket) ->
%% 	gen_server:start_link({local,background553SocketPID},?MODULE, [Socket], [{timeout,?Start_Link_TimeOut_ms}]).



%% init([Socket]) ->
%% 	inet:setopts(Socket, ?TCP_OPTIONS),
%% 	initbackground553( Socket ),
%%     {ok, {IP, _Port}} = inet:peername(Socket),
%%     {ok, #state{socket=Socket, addr=IP}}.
%% 
%% handle_call(_Request, _From, State) ->
%%     {noreply, ok, State}.
%% 
%% handle_cast(_Msg, State) ->
%%     {noreply, State}.
%% 
%% 
%% 
%% terminate(_Reason, #state{socket=Socket}) ->
%%     (catch gen_tcp:close(Socket)),
%% 	unregister(background553SocketPID),
%%     ok.
%% 
%% code_change(_OldVsn, State, _Extra) ->
%%     {ok, State}.
%% 
%% 
%% 
%% %%553平台的Socket进程
%% initbackground553( PlatformSocket )->
%% 	%%当前进程可直接访问socket
%% 	put( "PlatformSocket", PlatformSocket ),
%% 	%%当前连接是否已经通过验证
%% 	put( "IsPlatformSocketChecked", false ),
%% 	%register( background553_socket_PID, self() ),
%% 	?DEBUG_OUT( "accept platform 553 socket[~p] PID[~p] ", [PlatformSocket, self()] ),
%% 	ok.
%% 
%% %%553平台的recieve
%% %receivePlatform553( PlatformSocket )->
%% handle_info(Info, StateData)->	
%% 	put( "receivePlatform553", true ),
%% 	try
%% 	case Info of	
%% %	receive
%% 	{tcp,PlatformSocket,Data}->
%% 		%%?DEBUG_OUT("platform 553 receivePlatform553 recved MSG[~p].",[Data]),
%% 		inet:setopts(PlatformSocket,[{active,once}]),
%% 		doMsg(PlatformSocket,Data);
%% 	{tcp_error, PlatformSocket, Reason}->
%% 		?DEBUG_OUT( "platform 553 socket error[~p] reson[~p]", [PlatformSocket, Reason] ),
%% 		put( "receivePlatform553", false ),
%% 		gen_tcp:close( PlatformSocket);
%% 	{tcp_closed,PlatformSocket}->
%% 		?DEBUG_OUT( "platform 553 socket[~p] closed ", [PlatformSocket] ),
%% 		put( "receivePlatform553", false ),
%% 		gen_tcp:close( PlatformSocket);
%% 
%% 	%% 激活码处理完成
%% 	{activeCodeProcComplete,Pk_GS2LS_ActiveCode}->
%% 		?DEBUG_OUT( "------activeCodeProcComplete"),
%% 		PlatformSocket = get( "PlatformSocket" ),
%% 		Pkt = #pk_LS2Platform553_Active_Code_Ret{ len=string:len(Pk_GS2LS_ActiveCode#pk_GS2LS_ActiveCode.activeCode)+12+2,commmand=?CMD_PLATFORM_553_ACTIVE_CODE_RET,
%% 					activecode=Pk_GS2LS_ActiveCode#pk_GS2LS_ActiveCode.activeCode,
%% 					retcode=Pk_GS2LS_ActiveCode#pk_GS2LS_ActiveCode.retcode},
%% 		msg_LS2Platform:sendMsg(PlatformSocket,Pkt);
%% 
%% 	%% 执行平台发送的命令处理完成响应
%% 	{commandComplete,Pk_GS2LS_Command}->
%% 		?DEBUG_OUT( "------commandComplete-------"),
%% 		PlatformSocket = get( "PlatformSocket" ),
%% 		Pkt = #pk_LS2Platform553_Command_Ret{ len=20,commmand=?CMD_PLATFORM_553_COMMAND_RET,
%% 					num=Pk_GS2LS_Command#pk_GS2LS_Command.num,
%% 					cmd=Pk_GS2LS_Command#pk_GS2LS_Command.cmd,
%% 					retcode=Pk_GS2LS_Command#pk_GS2LS_Command.retcode},
%% 		?DEBUG_OUT( "------commandComplete------[~p]",[Pkt]),
%% 		msg_LS2Platform:sendMsg(PlatformSocket,Pkt);
%% 	
%% 	%% 充值处理完成响应
%% 	{rechargeComplete,Pk_GS2LS_Recharge}->
%% 		?DEBUG_OUT( "------rechargeComplete------"),
%% 		PlatformSocket = get( "PlatformSocket" ),
%% 		Pkt = #pk_LS2Platform553_Recharge_Ret{ len=string:len(Pk_GS2LS_Recharge#pk_GS2LS_Recharge.orderid)+16+2,
%% 					commmand=?CMD_PLATFORM_553_RECHARGE_RET,
%% 					orderid=Pk_GS2LS_Recharge#pk_GS2LS_Recharge.orderid,
%% 					platform=Pk_GS2LS_Recharge#pk_GS2LS_Recharge.platform,
%% 					retcode=Pk_GS2LS_Recharge#pk_GS2LS_Recharge.retcode},
%% 		?DEBUG_OUT( "------rechargeComplete------[~p]",[Pkt]),
%% 		msg_LS2Platform:sendMsg(PlatformSocket,Pkt)
%% 	end,
%% 
%% 	case get( "receivePlatform553" ) of
%% %% 		true->receivePlatform553( PlatformSocket );
%% %% 		false->
%% %% 			ok
%% 		true->{noreply, StateData};
%% 		false->{stop, normal, StateData}
%% 	end
%% 	
%% 	catch
%% 		_:_Why->
%% 			common:messageBox( "ExceptionFunc_Module:background553 ExceptionFunc[hande_info] Why[~p] stack[~p]", 
%% 						[_Why, erlang:get_stacktrace()] ),
%% 			PlatformSocket1 = get( "PlatformSocket"),
%% 			gen_tcp:close( PlatformSocket1),
%% 			{stop, normal, StateData}
%% 	end.

%% 检查连接IP地址是否正常
checkSocket(PlatformSocket)->
	Platform553IP = main:ini_ReadString( "LoginServer.txt", "Background553IP", "127.0.0.1" ),
	IPTokens=string:tokens(Platform553IP,"."),	
	[IP_S0,IP_S1,IP_S2,IP_S3]=IPTokens,
	{IP_0,_}=string:to_integer(IP_S0),
	{IP_1,_}=string:to_integer(IP_S1),
	{IP_2,_}=string:to_integer(IP_S2),
	{IP_3,_}=string:to_integer(IP_S3),
	IPCheck={IP_0,IP_1,IP_2,IP_3},
	{ok, {IP, _Port}} = inet:peername(PlatformSocket),
    ?DEBUG_OUT( "IPCheck[~p],IP[~p] ", [IPCheck, IP] ),
	case IP =:= IPCheck of
		true->yes;
		_->no
	end.	

procBackground553( PlatformSocket )->
    %%当前进程可直接访问socket
    put( "PlatformSocket", PlatformSocket ),
    %%当前连接是否已经通过验证
    put( "IsPlatformSocketChecked", false ),
    proc_lib:init_ack(self()),

    inet:setopts(PlatformSocket,?TCP_OPTIONS),

    ?DEBUG_OUT( "accept Background 553 socket[~p] PID[~p] ", [PlatformSocket, self()] ),

    try
%%  not check ip now
%% 	case checkSocket(PlatformSocket) of
%% 		yes->ok;
%% 		_->throw(-9)
%% 	end,

        receiveBackground553(PlatformSocket)
    catch
		-9->
			{ok, {IP, _Port}} = inet:peername(PlatformSocket),
        	?ERROR_OUT("Background 553 invalid ip[~p] connect .",[IP]),
        	gen_tcp:close( PlatformSocket );
        _:Why->
        	?ERROR_OUT("Background 553 exception .why:~p",[Why]),
        	gen_tcp:close( PlatformSocket )
    end,

    ?DEBUG_OUT("Background 553 process exited .",[]),
    ok.


%%553平台的recieve
receiveBackground553( PlatformSocket )->
    put( "receivePlatform553", true ),
    
    receive
    {tcp,PlatformSocket,Data}->
		inet:setopts(PlatformSocket,[{active,once}]),
        %%?DEBUG_OUT("platform 553 receivePlatform553 recved MSG[~p].",[Data]),
        doMsg(PlatformSocket,Data);
    {tcp_error, _Socket, Reason}->
        ?ERROR_OUT( "Background 553 socket error[~p] reson[~p]", [PlatformSocket, Reason] ),
        put( "receivePlatform553", false ),
        gen_tcp:close( PlatformSocket );
    {tcp_closed,_Socket}->
        ?DEBUG_OUT( "Background 553 socket[~p] closed ", [PlatformSocket] ),
        put( "receivePlatform553", false ),
        gen_tcp:close( PlatformSocket );

	%% 激活码处理完成
	{activeCodeProcComplete,Pk_GS2LS_ActiveCode}->
		?LOG_OUT( "------activeCodeProcComplete"),
		PlatformSocket = get( "PlatformSocket" ),
		Pkt = #pk_LS2Platform553_Active_Code_Ret{ len=string:len(Pk_GS2LS_ActiveCode#pk_GS2LS_ActiveCode.activeCode)+12+2,commmand=?CMD_PLATFORM_553_ACTIVE_CODE_RET,
					activecode=Pk_GS2LS_ActiveCode#pk_GS2LS_ActiveCode.activeCode,
					retcode=Pk_GS2LS_ActiveCode#pk_GS2LS_ActiveCode.retcode},
		msg_LS2Platform:sendMsg(PlatformSocket,Pkt);

	%% 执行平台发送的命令处理完成响应
	{commandComplete,Pk_GS2LS_Command}->
		PlatformSocket = get( "PlatformSocket" ),
		Pkt = #pk_LS2Platform553_Command_Ret{ len=20,commmand=?CMD_PLATFORM_553_COMMAND_RET,
					num=Pk_GS2LS_Command#pk_GS2LS_Command.num,
					cmd=Pk_GS2LS_Command#pk_GS2LS_Command.cmd,
					retcode=Pk_GS2LS_Command#pk_GS2LS_Command.retcode},
		?LOG_OUT( "------commandComplete------[~p]",[Pkt]),
		msg_LS2Platform:sendMsg(PlatformSocket,Pkt);
	
	%% 充值处理完成响应
	{rechargeComplete,Pk_GS2LS_Recharge}->
		?DEBUG_OUT( "------rechargeComplete------"),
		PlatformSocket = get( "PlatformSocket" ),
		Pkt = #pk_LS2Platform553_Recharge_Ret{ len=string:len(Pk_GS2LS_Recharge#pk_GS2LS_Recharge.orderid)+16+2,
					commmand=?CMD_PLATFORM_553_RECHARGE_RET,
					orderid=Pk_GS2LS_Recharge#pk_GS2LS_Recharge.orderid,
					platform=Pk_GS2LS_Recharge#pk_GS2LS_Recharge.platform,
					retcode=Pk_GS2LS_Recharge#pk_GS2LS_Recharge.retcode},
		?LOG_OUT( "------rechargeComplete------[~p]",[Pkt]),
		msg_LS2Platform:sendMsg(PlatformSocket,Pkt)

    end,

    case get( "receivePlatform553" ) of
        true->receiveBackground553( PlatformSocket );
        false->ok
    end.


doMsg(_S, <<>>) ->
	ok;

doMsg(S, Data) ->
	HEADER_SIZE=8,
	MAX_PACKET_SIZE=1024,
	DataSize = binary:referenced_byte_size(Data),

	case DataSize < HEADER_SIZE of
		true->throw( {'Error Data',Data} );
		false->ok
	end,
	
	case msg_LS2Platform:readMsg(Data) of
		{ok,Len,Cmd,Data1}->
			?LOG_OUT( "recve platform 553 socket[~p] MSG:Len[~p],Cmd[~p],Data[~p]", [S,Len,Cmd,Data1] ),
			msg_LS2Platform:dealMsg(S,Len,Cmd,Data1),
			LenLeft = DataSize - Len,
			if LenLeft >= HEADER_SIZE ->
				{_,<<Data2/binary>>} = split_binary(Data,Len),
				doMsg(S, Data2);
			true -> ok
			end;
		{error,0,0,0}->
			throw( {'Error Packet',Data} )
	end.

