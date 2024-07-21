-module(check).
-behaviour(gen_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
%-record(state, {}).
-define(TIMEOUT, 120000).


-include("condition_compile.hrl").
-include("globalDefine.hrl").
-include("db.hrl").
-include("hdlt_logger.hrl").


start_link() ->
	gen_server:start_link({local,checkPid},?MODULE, [], [{timeout,?Start_Link_TimeOut_ms}]).

init([]) ->
	erlang:send_after(?CheckPlayerProcessTimer,self(), {checkTimer_CheckPlayerProcessTimer} ),
    {ok, {}}.

handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

handle_info(Info, StateData)->			
	try
		
	case Info of
		{ checkTimer_CheckPlayerProcessTimer }->
			checkAllPlayerProcess(),
			erlang:send_after(?CheckPlayerProcessTimer, self(),{checkTimer_CheckPlayerProcessTimer} ),
			{noreply, StateData}
	end
	
	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[?MODULE,_Why, erlang:get_stacktrace()] ),	

			{noreply, StateData}
	end.

checkAllPlayerProcess()->
	LoginUserList = etsBaseFunc:getAllRecord( ?SocketDataTableAtom ),
	%LoginUserList = db:matchObject(socketData, #socketData{_ = '_'}),
	?DEBUG_OUT("checkAllPlayerProcess LoginUserList len:~p",[length(LoginUserList)]),
	CheckFunc = fun( Record )->
					 case  Record#socketData.pid of
						 0->
							 ?ERROR_OUT( "zomb player process,pid:~p,playerId:~p, userId:~p",[Record#socketData.pid,Record#socketData.playerId,Record#socketData.userId]),
							 %db:delete( socketData, Record#socketData.socket );			 
						 	 main:deleteSocketDataBySocket_rpc(Record#socketData.socket);
						 Pid->
							 case is_pid(Pid) and is_process_alive(Pid) of
								true->
									case gen_server:call(Pid, {checkProcessAlive}, 30000) of
										ok->?DEBUG_OUT("checkAllPlayerProcess ok for playerid:~p",[Record#socketData.playerId]),
											ok;
										_->
											?ERROR_OUT( "zomb player process,timeout,pid:~p,playerId:~p, userId:~p",[Record#socketData.pid,Record#socketData.playerId,Record#socketData.userId]),
											%db:delete( socketData, Record#socketData.socket ),
											main:deleteSocketDataBySocket_rpc(Record#socketData.socket),
											exit(Record#socketData.pid,kill)
									end;
								_->
									 ?ERROR_OUT( "zomb player process,pid:~p,playerId:~p, userId:~p",[Record#socketData.pid,Record#socketData.playerId,Record#socketData.userId]),
									%db:delete( socketData, Record#socketData.socket )
							 		main:deleteSocketDataBySocket_rpc(Record#socketData.socket)
							 end							 
					 end
			 end,
	lists:foreach( CheckFunc, LoginUserList ).
