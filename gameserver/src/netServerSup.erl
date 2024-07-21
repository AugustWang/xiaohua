-module(netServerSup).
-author('wenziyong').
-behaviour(supervisor).
-export([start_child/1, start_link/2, init/1]).
-define(SERVER, ?MODULE).
-define(CLIENT_SUP, netClientSup).
-define(MAX_RESTART,    5).
-define(MAX_TIME,      60).

%% 启动socket连接处理进程
start_child(Socket) ->
    supervisor:start_child(?CLIENT_SUP, [Socket]).
%% 启动netListener进程，并设置socket连接处理模块
start_link(_ListenPort, HandleMoudle) ->
	ListenToUserPort = loginServer:ini_ReadInt( "GameServerSetup.txt", "ListenToUserPort", 6789 ),
	supervisor:start_link({local, ?SERVER}, ?MODULE, [ListenToUserPort, HandleMoudle]).

%% one_for_one包括了一个监听进程NetListener，还包含了一个NetClientSupervisor进程树(simple_one_for_one策略)
init([Port, Module]) ->
	NetListener = {netServerSup,                         		% Id       = internal id
                  {netListener, start_link, [Port, Module]},	% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [netListener]                           		% Modules  = [Module] | dynamic
              },
	
	NetClientSupervisor = {?CLIENT_SUP,
                  {supervisor, start_link, [{local, ?CLIENT_SUP}, ?MODULE, [Module]]},
                  permanent,
                  infinity,
                  supervisor,
                  [netUsers]
              },
	{ok,
        {{one_for_one, ?MAX_RESTART, ?MAX_TIME},
            [NetListener, NetClientSupervisor]
        }
    };

init([Module]) ->
    {ok,
        {_SupFlags = {simple_one_for_one, ?MAX_RESTART, ?MAX_TIME},
            [
              % net Client
              {   undefined,                               % Id       = internal id
                  {Module, start_link, []},                % StartFun = {M, F, A}
                  temporary,                               % Restart  = permanent | transient | temporary (不会重启)
                  2000,                                    % Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  % Type     = worker | supervisor
                  []                                       % Modules  = [Module] | dynamic
              }
            ]
        }
    }.