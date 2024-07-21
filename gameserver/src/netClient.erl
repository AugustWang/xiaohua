-module(netClient).
-behaviour(gen_server).
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-record(state, {socket, addr}).
-define(TIMEOUT, 120000).


-include("condition_compile.hrl").
-include("globalDefine.hrl").
%% just a template, not use it 

start_link(Socket) ->
	gen_server:start_link(?MODULE, [Socket], [{timeout,?Start_Link_TimeOut_ms}]).



init([Socket]) ->
	inet:setopts(Socket, ?TCP_OPTIONS),
    {ok, {IP, _Port}} = inet:peername(Socket),
    {ok, #state{socket=Socket, addr=IP}}.

handle_call(Request, From, State) ->
    {noreply, ok, State}.

handle_cast(Msg, State) ->
    {noreply, State}.

handle_info({tcp, Socket, Data}, State) ->
    inet:setopts(Socket, [{active, once}]),
    {noreply, State};

handle_info({tcp_closed, _Socket}, #state{addr=Addr} = StateData) ->
    error_logger:info_msg("~p Client ~p disconnected.\n", [self(), Addr]),
    {stop, normal, StateData};

handle_info(_Info, StateData) ->
    {noreply, StateData}.

terminate(_Reason, #state{socket=Socket}) ->
    (catch gen_tcp:close(Socket)),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


