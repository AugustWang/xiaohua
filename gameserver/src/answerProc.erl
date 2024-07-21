%% Author: yueliangyou
%% Created: 2013-5-28
%% Description: TODO: Add description to main
-module(answerProc).

%% add by yueliangyou for gen server
-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%
%% Include files
%%
-include("db.hrl").
-include("answer.hrl").
-include("playerDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("condition_compile.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

-define(TIMER_REFRESH_OFFSET,12*3600-?READY_TIME).

start_link() ->
	gen_server:start_link({local,answerProcPID},?MODULE, [], [{timeout,?Start_Link_TimeOut_ms}]).

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
	%% 答题系统初始化
	answer:init(),
	Delay=getRefreshTimerSeconds(),
	timer:send_after(Delay, {answerTimer_Start} ),
	%timer:send_after(1000, {answerTimer_Start} ),
	?DEBUG_OUT( "answer process start ...", [] ),
	{ok,{}}.

%% 处理同步消息 gen_server:call消息
handle_call({'getTopTen'}, _From, State) ->
    {reply,answer:getTopTen(), State};
handle_call({'getSystemInfo'}, _From, State) ->
    {reply,answer:getSystemInfo(), State};
handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

%% 处理异步消息 gen_server:cast消息
handle_cast({'start'},State) ->
	answer:start(),
    {noreply,State};
handle_cast({'commitScore',PlayerID,PlayerName,Score},State) ->
	answer:commitScore(PlayerID,PlayerName,Score),
    {noreply,State};
handle_cast(_Msg, State) ->
    {noreply, State}.

%% 进程终止
terminate(_Reason, _State) ->
	?LOG_OUT( "answer process teminate ...", [] ),
    ok.

%% ....
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% 处理 带外消息
handle_info(Info, State)->	
	put("answerRecieve",true),
	try
		case Info of
			{answerTimer_Start}->
				%% 开启答题系统
				answer:start(),
				Delay=getNextRefreshTimerSeconds(),
				timer:send_after(Delay, {answerTimer_Start} );
				%timer:send_after(15000, {answerTimer_Start} );
			{answerTimer_Question}->
				%% 发放题目
				answer:question();
			_-> ok
		end,

		case get( "answerRecieve" ) of
			true->{noreply,State};
			false->{stop,normal,State}
		end

	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[?MODULE,_Why, erlang:get_stacktrace()] ),
			{noreply, State}
	end.




