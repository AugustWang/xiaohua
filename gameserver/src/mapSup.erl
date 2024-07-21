-module(mapSup).
-author('wenziyong').
-behaviour(supervisor).
-export([start_child/1, start_link/0, init/1]).
-define(MAX_RESTART,    5).
-define(MAX_TIME,      60).

%% 启动map sup 进程
start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% 启动map进程
start_child(MapObject) ->
    supervisor:start_child(?MODULE, [MapObject]).


init([]) ->
    {ok,
        {_SupFlags = {simple_one_for_one, ?MAX_RESTART, ?MAX_TIME},
            [
              % map process
              {   undefined,                               % Id       = internal id
                  {map, start_link, []},                % StartFun = {M, F, A}
                  temporary,                               % Restart  = permanent | transient | temporary (不会重启)
                  2000,                                    % Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  % Type     = worker | supervisor
                  []                                       % Modules  = [Module] | dynamic
              }
            ]
        }
    }.