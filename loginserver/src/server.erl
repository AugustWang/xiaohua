%% 启动整个应用的开启模块 server.erl

-module(server).
-export([start/0,stop/0]).

%%
%% API Functions
%%
%% 启动应用
start() ->
    case application:start(loginserver) of
        ok ->
            ok;
        Msg ->
            {failur, Msg}
    end.

%% 关闭应用
stop() ->
	case application:stop(loginserver) of
		ok ->
			ok;
		Msg ->
			{failure, Msg}
	end,
	erlang:halt().

