%% Author: yueliangyou
%% Created: 2013-3-26
%% Description: TODO: Add description to main
-module(topProc).

%% add by yueliangyou for gen server
-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%
%% Include files
%%
-include("db.hrl").
-include("top.hrl").
-include("playerDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("condition_compile.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

-define(TIMER_REFRESH_OFFSET,4*3600).

start_link() ->
	gen_server:start_link({local,topProcPID},?MODULE, [], [{timeout,?Start_Link_TimeOut_ms}]).

getRefreshTimerSeconds()->
	NowSeconds=common:getNowSeconds(),
	RefreshTimerSeconds=common:getTodayBeginSeconds()+?TIMER_REFRESH_OFFSET,
	RefreshTimerSeconds_Next=common:getTodayBeginSeconds()+?TIMER_REFRESH_OFFSET+86400,
	case NowSeconds > RefreshTimerSeconds of
		true->
			(RefreshTimerSeconds_Next-NowSeconds)*1000;
		false->
			(RefreshTimerSeconds-NowSeconds)*1000+1
	end.
	
getNextRefreshTimerSeconds()->
	NowSeconds=common:getNowSeconds(),
	RefreshTimerSeconds_Next=common:getTodayBeginSeconds()+?TIMER_REFRESH_OFFSET+86400,
	(RefreshTimerSeconds_Next-NowSeconds)*1000.

init([]) ->
	%% 排名系统初始化
	top:init(),
	Delay=getRefreshTimerSeconds(),
	erlang:send_after(Delay, self(),{topTimer_Refresh} ),
	?DEBUG_OUT( "top process start ...", [] ),
	{ok,{}}.

%% 处理同步消息 gen_server:call消息
handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

%% 处理异步消息 gen_server:cast消息
handle_cast(_Msg, State) ->
    {noreply, State}.

%% 进程终止
terminate(_Reason, _State) ->
	?LOG_OUT( "top process teminate ...", [] ),
    ok.

%% ....
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% 处理 带外消息
handle_info(Info, State)->	
	put("topRecieve",true),
	try
		case Info of
			{topTimer_Refresh}->
				top:on_Refresh(),
				Delay=getNextRefreshTimerSeconds(),
				erlang:send_after(Delay, self(),{topTimer_Refresh} );
			_-> ok
		end,

		case get( "topRecieve" ) of
			true->{noreply,State};
			false->{stop,normal,State}
		end

	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[?MODULE,_Why, erlang:get_stacktrace()] ),
			{noreply, State}
	end.




