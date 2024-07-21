%% 启动整个应用的开启模块 server.erl

-module(server).
-export([start/0,stop/0]).

%%
%% API Functions
%%
%% 启动应用
start() ->
    case application:start(server) of
        ok ->
            ok;
        Msg ->
            {failur, Msg}
    end.

%% 关闭应用
stop() ->
	mySqlProcess:saveWorldVarArray(),
	case application:stop(server) of
		ok ->
			ok;
		Msg ->
			{failure, Msg}
	end,
	erlang:halt().

