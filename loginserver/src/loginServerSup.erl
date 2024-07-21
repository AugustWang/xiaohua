-module(loginServerSup).
-author('wenziyong').
-behaviour(supervisor).
-export([ start_link/0, init/1]).
-define(SERVER, ?MODULE).
-define(MAX_RESTART,    0). %% usually 4, now set not restart
-define(MAX_TIME,      3600).


start_link() ->
	supervisor:start_link({local, ?SERVER}, ?MODULE, []).



init([]) ->
	%% 日志进程
	HdltLogger = {hdlt_logger,                         		% Id       = internal id
                  {hdlt_logger, start_link, ["server"]},	% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [hdlt_logger]                           		% Modules  = [Module] | dynamic
              },
	
	
	%% mysql driver进程
	Mysql = {mysql,                         		% Id       = internal id
                  {mysql, start_link, []},	% StartFun = {M, F, A}
                  permanent,                               		% Restart  = permanent | transient | temporary
                  2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                  worker,                                  		% Type     = worker | supervisor
                  [mysql]                           		% Modules  = [Module] | dynamic
              },
	


	
	%% main进程
 	Main = {main,                         		% Id       = internal id
                   {main, start_link, []},				% StartFun = {M, F, A}
                   permanent,                               		% Restart  = permanent | transient | temporary
                   2000,                                    		% Shutdown = brutal_kill | int() >= 0 | infinity
                   worker,                                  		% Type     = worker | supervisor
                   [main]                           		% Modules  = [Module] | dynamic
               },
	
	


	%% netServerSup   listenPort 9999 will be replaced
 	NetServerSup = {netServerSup,
 			  {netServerSup, start_link, [9999,netUsers]},
               permanent,
               infinity,
               supervisor,
               [netServerSup]
           },
	
	
	%% gsNetServerSup   listenPort 9999 will be replaced
 	GsNetServerSup = {gsNetServerSup,
 			  {gsNetServerSup, start_link, [9999,gameServer]},
               permanent,
               infinity,
               supervisor,
               [gsNetServerSup]
           },

	%% ----------------------------------------------------------------------------	
	%% 这个必须放在最后 
	Background553NetServerSup = {background553NetServerSup,
 			  {background553NetServerSup, start_link, [9999,background553]},
               permanent,
               infinity,
               supervisor,
               [background553NetServerSup]
           },
	

	{ok,
        {{one_for_one, ?MAX_RESTART, ?MAX_TIME},
            [HdltLogger,Mysql,Main,NetServerSup,GsNetServerSup,Background553NetServerSup]
        }
    }.
