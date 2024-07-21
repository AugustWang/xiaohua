-define( LOGDB_CONNECT_POOL, logdbConnectPool).
-define( GAMEDB_CONNECT_POOL, gamedbConnectPool).
-define(LOGINDB_CONNECT_POOL, logindbConnectPool).
-define(LOGIN_LOG_DB_CONNECT_POOL, loginlogdbConnectPool).
-define( PUBLICDB_CONNECT_POOL, publicdbConnectPool).

-define( LOGDB_CONNECT_NUM, 4).
-define( GAMEDB_CONNECT_NUM, 4).
-define(LOGINDB_CONNECT_NUM, 2).
-define(LOGIN_LOG_DB_CONNECT_NUM, 2).
-define(PUBLIC_DB_CONNECT_NUM, 1).

%% MySQL result record:
-record(mysql_result,
	{fieldinfo=[],
	 rows=[],
	 affectedrows=0,
	 insertid=0,
	 error="",
	 errcode=0,
	 errsqlstate=""}).
