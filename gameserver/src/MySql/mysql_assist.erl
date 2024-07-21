-module(mysql_assist).

-include("mysql.hrl").
-include("logdb.hrl").
-include("hdlt_logger.hrl").
-include("db.hrl").


-define(IsJustForTest, false).

%%
%% Exported Functions
%%
-compile(export_all).



%% add by wenziyong
startlink() ->
	case ?IsJustForTest of
		false->
			MySQLHostAddress = loginServer:ini_ReadString( "GameServerSetup.txt", "MySQLHostAddress", "localhost" ),
			MySQLUserName = loginServer:ini_ReadString( "GameServerSetup.txt", "MySQLUserName", "root" ),
			MySQLPassword  = loginServer:ini_ReadString( "GameServerSetup.txt", "MySQLPassword", "123" ),
			MySQLPort  = loginServer:ini_ReadInt( "GameServerSetup.txt", "MySQLPort", 3306 ),
			MySQLDbName  = loginServer:ini_ReadString( "GameServerSetup.txt", "MySQLDbName", "test" ),		
			%% start driver and create a gamedb connect to pool
			mysql:start_link(?GAMEDB_CONNECT_POOL,MySQLHostAddress,MySQLPort,MySQLUserName,MySQLPassword,MySQLDbName,fun mysql:log_fun_for_server/4,utf8);
		true->
			%% just for test and create a test connect to pool
    		mysql:start_link(p1, "192.168.1.10", undefined,"root", "bear", "test",fun mysql:log_fun_example/4,utf8)
	end.





add_another_connections(PoolId, Host, Port, User, Password, Database, Encoding,LogFun,NewState) ->
	%% add by wenziyong, add another connections
	case ?IsJustForTest of
	false->
		%% add another two game db connects
		case mysql:add_connects_in_init(PoolId, Host, Port, User, Password, Database, Encoding, true,LogFun,NewState,?GAMEDB_CONNECT_NUM) of
		{ok, NewState1}->
			%% add two log db connects
			LogDbName  = loginServer:ini_ReadString( "GameServerSetup.txt", "LogDbName", "fxserverlog" ),
			case mysql:add_connects_in_init(?LOGDB_CONNECT_POOL, Host, Port, User, Password, LogDbName, Encoding, true,LogFun,NewState1,?LOGDB_CONNECT_NUM) of	
				{ok, NewState2}->
					PublicDbHostAddress = loginServer:ini_ReadString( "GameServerSetup.txt", "PublicDbHostAddress", "localhost" ),
					PublicDbUserName = loginServer:ini_ReadString( "GameServerSetup.txt", "PublicDbUserName", "root" ),
					PublicDbPassword  = loginServer:ini_ReadString( "GameServerSetup.txt", "PublicDbPassword", "123" ),
					PublicDbPort  = loginServer:ini_ReadInt( "GameServerSetup.txt", "PublicDbPort", 3306 ),
					PublicDbName  = loginServer:ini_ReadString( "GameServerSetup.txt", "PublicDbName", "fxpublicdb" ),		
					case mysql:add_connects_in_init(?PUBLICDB_CONNECT_POOL, PublicDbHostAddress, PublicDbPort, PublicDbUserName, PublicDbPassword, PublicDbName, Encoding, true,LogFun,NewState2,?PUBLIC_DB_CONNECT_NUM) of
						{ok, NewState3}->				
							NewState4 = mySqlProcess:register_prepared_stats(NewState3),
							NewState5 = logdbProcess:register_prepared_stats(NewState4),
							NewState6 = publicdbProcess:register_prepared_stats(NewState5),
							{ok,NewState6};
						Err->
							Err
					end;
					
					
				Err->
					Err
			end;
			%{ok, NewState1};
		Err->
    		Err
		end;
	true->
		%mysql_test:register_prepared_stats(), %% should write this in this file
		mysql:add_connects_in_init(PoolId, Host, Port, User, Password, Database, Encoding, true,LogFun,NewState,9)	
	end.

