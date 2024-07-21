%% Author: yueliangyou
%% Created: 2013-3-7
%% Description: TODO: 
-module(platformPP).

%%
%% Include files
%%
-include("db.hrl").
-include("userDefine.hrl").
-include("platformDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("gameServerDefine.hrl").
-include("globalDef.hrl").
-include_lib("stdlib/include/ms_transform.hrl").


%%
%% Exported Functions
%%
-compile(export_all).



initModule(IP,Port)->
	?LOG_OUT( "platform PP module supported." ),
	ets:insert(platformtable,#platformTable{platformID=?PLATFORM_PP,isSupport=1,ip=IP,port=Port}),
        ?LOG_OUT( "platform PP:~p",[ets:lookup(platformtable,?PLATFORM_PP)] ).

isPPSupport()->
        ?DEBUG_OUT( "platform PP:~p",[ets:lookup(platformtable,?PLATFORM_PP)] ),
	Ret=ets:lookup(platformtable,?PLATFORM_PP),
        case Ret of
                [] ->no;
                [H|[]]->[{_,_,Support,_,_}|_Set]=Ret,
                        case Support of
                                1->yes;
                                _->no
                        end
        end.

getPlatformPPSocket()->
	Ret=ets:lookup(platformtable,?PLATFORM_PP),
        case Ret of
                [] ->0;
                [H|[]]->[{_,_,_,IPString,Port}|_Set]=Ret,
			case gen_tcp:connect(IPString, Port, ?CONNECT_TCP_OPTIONS ) of
        		{ok, Socket} ->
                        	?DEBUG_OUT( "connect to platform PP success ." ),
                        	inet:setopts(Socket,?TCP_OPTIONS),
                        	Socket;
        		{error, Reason} ->
                        	?LOG_OUT( "connect to platform PP failed.reason[~p] .",[Reason] ),
				0
			end
	end.

sendMsg(Socket,#pk_LS2PlatformPP_Verify{}=P)->
        Bin0=messageBase:write_int(P#pk_LS2PlatformPP_Verify.len),
        Bin3=messageBase:write_int(P#pk_LS2PlatformPP_Verify.commmand),
        Token=P#pk_LS2PlatformPP_Verify.token_key,
        Bin = <<Bin0/binary,Bin3/binary,Token/binary>>,
	Result=gen_tcp:send(Socket,Bin),
	Result.

waitForResponsePP(Account,Socket)->
	receive 
	{tcp,Socket,Data}->
		?DEBUG_OUT( "platform pp have returned data:[~p]",[Data] ),
		doMsg(Account,Socket,Data);
	{tcp_error, _Socket, Reason}->
		?ERROR_OUT( "platform PP socket[~p] error reson[~p]", [Socket, Reason] ),
		error;
	{tcp_closed,_Socket}->
		?LOG_OUT( "platform PP socket[~p] closed ", [Socket] ),
		closed
	after 30000->
		?LOG_OUT( "platform PP socket[~p] timeout", [Socket] ),
		timeout
        end.

verifyRequestPP(Account,Token)->
	Socket = getPlatformPPSocket(),
        case Socket of
        	0->
				?LOG_OUT( "verifyRequestPP getPlatformPPSocket=0" ),
				error;
            _->
				Msg = #pk_LS2PlatformPP_Verify{len=24,commmand=2852126754,token_key=Token},
				%%Msg = #pk_LS2PlatformPP_Verify{len=24,commmand=16#AA000022,token_key=Token},
				?DEBUG_OUT( "verifyRequestPP sending MSG:[~p]. ",[Msg] ),
	            sendMsg(Socket, Msg),
				?DEBUG_OUT( "verifyRequestPP send request,waiting for response ..." ),
				%等待消息返回
				waitForResponsePP(Account,Socket)
        end.

doMsg(Account,_S, Data) ->
        {Len,Count1} = common:binary_read_int(0,Data),
        {Cmd, Count2} = common:binary_read_int(Count1,Data),
        {Status, Count3} = common:binary_read_int(Count2+Count1,Data),
	?DEBUG_OUT( "platform PP doMsg Len[~p],Cmd[~p],Status[~p]",[Len,Cmd,Status] ),
	case Cmd of 
		-1442779102->
			case Status of
				0->success;
				_->failed
			end;
		_->
            ?LOG_OUT( "platform PP returned invalid Cmd :[~p]",[Cmd] ),
			error
        end.
