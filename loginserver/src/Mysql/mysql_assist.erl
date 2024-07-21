-module(mysql_assist).

-include("mysql.hrl").
%-include("logdb.hrl").
-include("hdlt_logger.hrl").
-include("db.hrl").



%%
%% Exported Functions
%%
-compile(export_all).



%% add by wenziyong
startlink() ->
	MySQLHostAddress = main:ini_ReadString( "LoginServer.txt", "MySQLHostAddress", "localhost" ),
	MySQLUserName = main:ini_ReadString( "LoginServer.txt", "MySQLUserName", "root" ),
	MySQLPassword  = main:ini_ReadString( "LoginServer.txt", "MySQLPassword", "123" ),
	MySQLPort  = main:ini_ReadInt( "LoginServer.txt", "MySQLPort", 3306 ),
	MySQLDbName  = main:ini_ReadString( "LoginServer.txt", "MySQLDbName", "test" ),		
	%% start driver and create a gamedb connect to pool
	mysql:start_link(?LOGINDB_CONNECT_POOL,MySQLHostAddress,MySQLPort,MySQLUserName,MySQLPassword,MySQLDbName,fun mysql:log_fun_for_server/4,utf8).



add_another_connections(PoolId, Host, Port, User, Password, Database, Encoding,LogFun,NewState) ->
	%% add by wenziyong, add another connections
	case mysql:add_connects_in_init(PoolId, Host, Port, User, Password, Database, Encoding, true,LogFun,NewState,?LOGINDB_CONNECT_NUM) of
		{ok, NewState1}->
			%% add two log db connects
			LogDbName  = main:ini_ReadString( "LoginServer.txt", "LogDbName", "fxloginserverlog" ),
			case mysql:add_connects_in_init(?LOGIN_LOG_DB_CONNECT_POOL, Host, Port, User, Password, LogDbName, Encoding, true,LogFun,NewState1,?LOGIN_LOG_DB_CONNECT_NUM) of	
				{ok, NewState2}->
					NewState3 = loginMysqlProc:register_prepared_stats(NewState2),
					NewState4 = loginLogdbProc:register_prepared_stats(NewState3),
					
					{ok,NewState4};
				Err->
					Err
			end;
		Err->
			Err
	end.

