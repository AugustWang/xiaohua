

-define( DBVersion, 002  ).
-define(PlayerBaseID,1000).

-define(INT16,16/signed-little-integer).
-define(INT8,8/signed-little-integer).
-define(INT,32/signed-little-integer).
-define(INT64,64/signed-little-integer).
-define(UINT,32/unsigned-little-integer).

-record( dbInfo, {name, value} ).

-define( GlobalMainID, 1 ).
-record( globalMain, {id, globalUserSocket, globalLoginUserTable } ).

-record( gameServerRecord, { serverID, state, showInUserGameList, name, ip, port, socket, remmond, onlinePlayers, showState,
	isnew,begintime,hot } ).

%%登录服务器信息
-record( loginServerInfo, {index,loginServerID} ).

%%全局用户Socket
-record( globalUserSocket,{socket, userID } ).

%%全局已登录用户
-record( globalLoginUser, {userID, loginGameServer, socket, userProcPID, randIdentity, waitForKickoutUserPID, waitForLoginGSID} ).

%% user table
-record(userDBRecord,{id,name,password}).


-record(uniqueId, {item, uid}).
-record(uniqueIdMem, {item, uid}).


%% -define( Tables, [uniqueId, record_info(fields,uniqueId),
%%  				  userDBRecord, 	record_info(fields,userDBRecord)
%%  				 ] ).

-define( MemTables, [uniqueIdMem,	record_info(fields,uniqueIdMem),
					 globalMain, record_info(fields,globalMain),
					 gameServerRecord, record_info(fields,gameServerRecord)
					] ).
