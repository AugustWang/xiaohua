
-module(loginMysqlProc).

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

%%记录转化成列表
record_to_list(Record)->
	List1 = tuple_to_list(Record),
	[_RecordName|List] = List1,
	List.

get_platform_test(Account,IP)->
	L=[Account,IP],
	case mysqlCommon:sqldb_exec_prepared_stat(?LOGINDB_CONNECT_POOL,select_platform_test,L,true) of
		{error,_} -> 0;
		{ok,[]} -> 0;
		{ok,[Row|_]} ->
			[Count|_] = Row,
			Count
	end.	

get_forbidden_user(Account) ->
	L=[Account,common:timestamp()],
	case mysqlCommon:sqldb_exec_prepared_stat(?LOGINDB_CONNECT_POOL,select_forbidden,L,true) of
		{error,_} -> {error,0};
		{ok,[]} -> {ok,0};
		{ok,[Row|_]} ->
			[Count|_] = Row,
			{ok,Count}
	end.	

%% ->{error,0}  means query error,{ok,0} means no this user, {ok,id} 
get_userId(PlatformId,UserName) ->
	L=[PlatformId,UserName],
	case mysqlCommon:sqldb_exec_prepared_stat(?LOGINDB_CONNECT_POOL,select_user_id,L,true) of
		{error, _ } -> {error,0};
		{ok, [] } -> {ok,0};
		{ok,[Row|_]} ->
			[Id|_] = Row,
			{ok,Id}
	end.	

insertUser(#user{}=R)->
	%Gamedata1 = setelement( #objectBuffDB.buffList, R, term_to_binary(R#objectBuffDB.buffList) ),
 	L = record_to_list(R),
 	mysqlCommon:sqldb_exec_prepared_stat(?LOGINDB_CONNECT_POOL,insert_user,L,true).
replaceUser(#user{id=ID, platformId=PID, userName=Name, resVer=V0, exeVer=V1,gameVer=V2,protocolVer=V3,lastLogintime=T}=R)->
	%Gamedata1 = setelement( #objectBuffDB.buffList, R, term_to_binary(R#objectBuffDB.buffList) ),
 	%L = record_to_list(R),
	L = [PID,Name,V0,V1,V2,V3,T,ID],
 	mysqlCommon:sqldb_exec_prepared_stat(?LOGINDB_CONNECT_POOL,replace_user,L,true).

insertUser4Test(#user4test{}=R)->
	L = record_to_list(R),
	mysqlCommon:sqldb_exec_prepared_stat(?LOGINDB_CONNECT_POOL,insert_user4test,L,true).

deleteUser4TestById(#user4test{}=R)->
	L = record_to_list(R),
	mysqlCommon:sqldb_exec_prepared_stat(?LOGINDB_CONNECT_POOL,delete_user4test_by_id,L,true).

insertForbidden(#forbidden{}=R)->
	L = record_to_list(R),
	mysqlCommon:sqldb_exec_prepared_stat(?LOGINDB_CONNECT_POOL,insert_forbidden,L,true).

deleteForbiddenByAccount(Account)->
	L = [Account],
	mysqlCommon:sqldb_exec_prepared_stat(?LOGINDB_CONNECT_POOL,delete_forbidden_by_account,L,true).

insertPlatFormTest(#platform_test{}=R)->
	L = record_to_list(R),
	mysqlCommon:sqldb_exec_prepared_stat(?LOGINDB_CONNECT_POOL,insert_platform_test,L,true).

deletePlatFormTestByAccountAndIp(#platform_test{}=R)->
	L = record_to_list(R),
	mysqlCommon:sqldb_exec_prepared_stat(?LOGINDB_CONNECT_POOL,delete_platform_test_by_account_and_ip,L,true).




%%列表转化成记录
list_to_record(List,Record)->
	case List of
	[]->
		{};
	_->
		List1 = [Record] ++ List,
		list_to_tuple(List1)
	end.

%% gs config
gsConfig_list_to_record(List)->
	R=list_to_record(List,gsConfig),
	R1 = setelement( #gsConfig.serverID, R, binary_to_list(R#gsConfig.serverID)),
	R2 = setelement( #gsConfig.name, R1, binary_to_list(R#gsConfig.name)),
	R3 = setelement( #gsConfig.begintime, R2, binary_to_list(R#gsConfig.begintime)),
	R4 = setelement( #gsConfig.recommend, R3, R#gsConfig.recommend),
	setelement( #gsConfig.hot, R4, R#gsConfig.hot).

get_allGsConfig() ->
	{_,GsConfigList1} = mysqlCommon:sqldb_query(?LOGINDB_CONNECT_POOL,"select * from gsconfig ",true),
	lists:map(fun(List) -> gsConfig_list_to_record(List) end, GsConfigList1).

insert_gsConfig(#gsConfig{}=R)->	
 	L = record_to_list(R),
 	mysqlCommon:sqldb_exec_prepared_stat(?LOGINDB_CONNECT_POOL,insert_gsconfig,L,true).

delete_gsConfig(ServerID) ->
	mysqlCommon:sqldb_query(?LOGINDB_CONNECT_POOL, "delete from gsconfig where serverid='"++ServerID++"'",true).

update_gsConfig(#gsConfigUpdate{}=R)->	
 	L = record_to_list(R),
 	mysqlCommon:sqldb_exec_prepared_stat(?LOGINDB_CONNECT_POOL,update_gsconfig,L,true).

isGSConfigExistById(  Serverid )->
	{_,GSList} = mysqlCommon:sqldb_query(?LOGINDB_CONNECT_POOL,"select * from gsconfig where serverid = '"++Serverid++"'",true),
	case GSList of
		[]->false;
		_->true
	end.

isUser4TestById(Id)->
	{_,IdList} = mysqlCommon:sqldb_query(?LOGINDB_CONNECT_POOL,"select * from user4test where id = "++integer_to_list(Id),true),
	case IdList of
		[]->false;
		_->true
	end.

%% register_prepared_stats() ->	
%% 	%-record(user, {id, platformId, userName, resVer, exeVer,gameVer,protocolVer,lastLogintime}).
%% 	mysql:prepare(insert_user,
%%           <<"INSERT INTO user(id, platformId, userName, resVer, exeVer,gameVer,protocolVer,lastLogintime)
%% 			 VALUES (?,?,?,?,?,?,?,?)">>),
%% 	mysql:prepare(replace_user,
%%           <<"REPLACE INTO user(id, platformId, userName, resVer, exeVer,gameVer,protocolVer,lastLogintime)
%% 			 VALUES (?,?,?,?,?,?,?,?)">>),
%% 	mysql:prepare(select_user_id,
%%           <<"SELECT id from user where platformId=? and userName=?">>),
%% 	mysql:prepare(insert_user_log,
%%           <<"INSERT INTO user_log(id, platformId, userName, resVer, exeVer,gameVer,protocolVer,logintime)
%% 			 VALUES (?,?,?,?,?,?,?,?)">>).

register_prepared_stats(State) ->	
	%-record(user, {id, platformId, userName, resVer, exeVer,gameVer,protocolVer,lastLogintime}).
	State1 = mysql:add_prepare({prepare,insert_user,
          <<"INSERT INTO user(id, platformId, userName, resVer, exeVer,gameVer,protocolVer,lastLogintime,createTime)
			 VALUES (?,?,?,?,?,?,?,?,?)">>}, State),
	%State2 = mysql:add_prepare({prepare,replace_user,
        %  <<"REPLACE INTO user(id, platformId, userName, resVer, exeVer,gameVer,protocolVer,lastLogintime)
	%		 VALUES (?,?,?,?,?,?,?,?)">>}, State1),
	State2 = mysql:add_prepare({prepare,replace_user,
          <<"UPDATE user set platformId=?, userName=?, resVer=?, exeVer=?,gameVer=?,protocolVer=?,lastLogintime=?
			 WHERE id=?">>}, State1),
	State3 = mysql:add_prepare({prepare,select_user_id,
          <<"SELECT id from user where platformId=? and userName=?">>}, State2),
	State4 = mysql:add_prepare({prepare,insert_gsconfig,
          <<"INSERT INTO gsconfig(serverid, name, isnew, begintime, recommend, hot) VALUES (?,?,?,?,?,?)">>}, State3),
	State5 = mysql:add_prepare({prepare,update_gsconfig,
          <<"UPDATE gsconfig set   serverid=?, name=?, begintime=?, recommend=?, hot=?   where serverid=? ">>}, State4),
	State6 = mysql:add_prepare({prepare,select_forbidden,
          <<"SELECT count(*) FROM forbidden where account=? and (timeEnd>? or flag=1)">>}, State5),
	State7 = mysql:add_prepare({prepare,select_platform_test,
          <<"SELECT count(*) FROM platform_test where account=? and ip=?">>}, State6),
	State8 = mysql:add_prepare({prepare,update_gsconfig,
          <<"UPDATE gsconfig set name=?, isnew=?, begintime=?, recommend=?, hot=?   where serverid=? ">>}, State7),
	State9 = mysql:add_prepare({prepare,insert_user4test,
      <<"INSERT INTO user4test(id) VALUES (?)">>}, State8),
	State10 = mysql:add_prepare({prepare,delete_user4test_by_id,
      <<"DELETE FROM user4test where id = ?">>}, State9),	
	State11 = mysql:add_prepare({prepare,insert_forbidden,
      <<"INSERT INTO forbidden(account, flag, reason, timeBegin, timeEnd) VALUES (?,?,?,?,?)">>}, State10),
	State12 = mysql:add_prepare({prepare,delete_forbidden_by_account,
      <<"DELETE FROM forbidden where account = ?">>}, State11),	
	State13 = mysql:add_prepare({prepare,insert_platform_test,
      <<"INSERT INTO platform_test(account, ip) VALUES (?,?)">>}, State12),
	_State14 = mysql:add_prepare({prepare,delete_platform_test_by_account_and_ip,
      <<"DELETE FROM platform_test where account = ? and ip = ?">>}, State13).
	




	
