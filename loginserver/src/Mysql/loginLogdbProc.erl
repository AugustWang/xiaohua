-module(loginLogdbProc).


%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% Include files
%%
-include("db.hrl").
-include("hdlt_logger.hrl").
-include("mysql.hrl").
-include("logindb.hrl").




insertLogAccountLogin(#user{}=R, IP)->
 	%L = loginMysqlProc:record_to_list(R),
	%record(user, {id, platformId, userName, resVer, exeVer,gameVer,protocolVer,lastLogintime}).
	L = [R#user.userName,R#user.id,R#user.platformId,R#user.resVer,R#user.exeVer,R#user.gameVer,R#user.protocolVer,R#user.lastLogintime, IP],
 	mysqlCommon:sqldb_exec_prepared_stat(?LOGIN_LOG_DB_CONNECT_POOL,insert_log_account_login,L,true).

register_prepared_stats(State) ->	
	mysql:add_prepare({prepare,insert_log_account_login,
          <<"INSERT INTO log_account_login(account, userid, platform, version_res, version_exe,version_game,version_pro,time_login, ip)
			 VALUES (?,?,?,?,?,?,?,?,?)">>}, State).
