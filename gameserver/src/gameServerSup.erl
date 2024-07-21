-module(gameServerSup).
-author('wenziyong').
-behaviour(supervisor).
-export([ start_link/0, init/1]).
-define(SERVER, ?MODULE).
-define(MAP_SUP, mapSup).
-define(MAX_RESTART,    0). %% usually 4, now set not restart
-define(MAX_TIME,      3600).


start_link() ->
	supervisor:start_link({local, ?SERVER}, ?MODULE, []).



init([]) ->
	%% æ¥å¿è¿ç¨
	HdltLogger = {hdlt_logger,                         		% Id       = internal id
                  {hdlt_logger, start_link, ["server"]},	% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [hdlt_logger]                           		% Modules  = [Module] | dynamic
              },
	
	%timer:sleep(1000),
	
	%% mysql driverè¿ç¨
	Mysql = {mysql,                         		% Id       = internal id
                  {mysql, start_link, []},	% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [mysql]                           		% Modules  = [Module] | dynamic
              },
	

	%timer:sleep(1000),	

	%% mapSup
	MapSup = {?MAP_SUP,
			  {mapSup, start_link, []},
              permanent,
              infinity,
              supervisor,
              [mapSup]
          },
	
	
	%% dbProcess
	DbProcess = {dbProcess,                         		% Id       = internal id
                  {dbProcess, start_link, []},				% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [dbProcess]                           		% Modules  = [Module] | dynamic
              },
		
	
	%% guild
	Guild = {guild,                         		% Id       = internal id
                  {guild, start_link, []},				% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [guild]                           		% Modules  = [Module] | dynamic
              },
	
	
	%% mapManager
	MapManager = {mapManager,                         		% Id       = internal id
                  {mapManager, start_link, []},				% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [mapManager]                           		% Modules  = [Module] | dynamic
              },
	
	%%	chat
	Chat = {chat,                         		% Id       = internal id
                  {chat, start_link, []},				% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [chat]                           		% Modules  = [Module] | dynamic
              },
	%%	team
	Team = {team,                         		% Id       = internal id
                  {team, start_link, []},				% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [team]                           		% Modules  = [Module] | dynamic
              },
	%%	mail
	Mail = {mail,                         		% Id       = internal id
                  {mail, start_link, []},				% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [mail]                           		% Modules  = [Module] | dynamic
              },
	
	%% mainPIDè¿ç¨
	Main = {main,                         		% Id       = internal id
                  {main, start_link, []},				% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [main]                           		% Modules  = [Module] | dynamic
              },
	
	
	%%	loginServer
	LoginServer = {loginServer,                         		% Id       = internal id
                  {loginServer, start_link, []},				% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [loginServer]                           		% Modules  = [Module] | dynamic
              },
	%%	conSalesBank
	ConSalesBank = {conSalesBank,                         		% Id       = internal id
                  {conSalesBank, start_link, []},				% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [conSalesBank]                           		% Modules  = [Module] | dynamic
              },
	
	%%	Bazzar
	Bazzar = {bazzar,                         		% Id       = internal id
                  {bazzar, start_link, []},				% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [bazzar]                           		% Modules  = [Module] | dynamic
              },
	
	%netServerSup:start_link(ListenToUserPort, netUsers),
	NetServerSup = {netServerSup,
			  {netServerSup, start_link, [9999,netUsers]}, %9999 is unused
              permanent,
              infinity,
              supervisor,
              [netServerSup]
          },
	
	%%	toplist process
	TopProc = {topProc,                         		% Id       = internal id
                  {topProc, start_link, []},				% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [topProc]                           		% Modules  = [Module] | dynamic
              },
	
	%%	answer process
	AnswerProc = {answerProc,                         		% Id       = internal id
                  {answerProc, start_link, []},				% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [answerProc]                           		% Modules  = [Module] | dynamic
              },
	
	%%活动
	ActiveProc = {active,                         		% Id       = internal id
                  {active, start_link, []},				% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [active]                           		% Modules  = [Module] | dynamic
              },
	
	%%	check
	Check = {check,                         		% Id       = internal id
                  {check, start_link, []},				% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [check]                           		% Modules  = [Module] | dynamic
              },

	{ok,
        {{one_for_one, ?MAX_RESTART, ?MAX_TIME},
            [HdltLogger,Mysql,MapSup,DbProcess,Guild,MapManager,Chat,Team,Mail,Main,LoginServer,ConSalesBank,NetServerSup,Bazzar,TopProc,AnswerProc,ActiveProc,Check]
        }
    }.



