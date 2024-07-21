%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(userDB).


%%
%% Include files
%%
-include("db.hrl").
-include("userDefine.hrl").
-include("pc_LS2User.hrl").
-include("hdlt_logger.hrl").
-include("logindb.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 


%% init()->
%% 	PID = proc_lib:spawn( ?MODULE, procUserDB, [0] ),
%% 	?DEBUG_OUT( "userDB thread spawn PID[~p]", [PID] ),
%% 	ok.
%% 
%% 
%% procUserDB( Param )->
%% 	register( userDB_PID, self() ),
%% 	
%% 	proc_lib:init_ack(self()),
%% 	
%% 	common:beginTryCatchFunc( userDB, recvUserDB, 0, userDB, userDB_ExceptionFunc ),
%% 
%% 	unregister( userDB_PID ),
%% 	?DEBUG_OUT( "procUserDB exited [~p]", self() ),
%% 	ok.


%% recvUserDB()->
%% 	put( "recvUserDB", true ),
%% 	receive
%% 		{login, FromPID, UserSocket, Msg }->
%% 			onUserLogin( FromPID, UserSocket, Msg ),
%% 			ok;
%% 		{quit}->
%% 			put( "recvUserDB", false );
%% 		_->ok
%% 	end,
%% 	case get( "recvUserDB" ) of
%% 		true->recvUserDB();
%% 		false->ok
%% 	end.

%% userDB_ExceptionFunc()->
%% 	?ERROR_OUT("userDB_ExceptionFunc").

checkUserName( Name )->
	put( "checkUserName_SuccOrFail", false ),
	try
		Len = string:len( Name ),
		case ( Len >= 1 ) and ( Len =< 16 ) of
			true->put( "checkUserName_SuccOrFail", true );
			false->ok
		end,
		get( "checkUserName_SuccOrFail" )
	catch
		_->get( "checkUserName_SuccOrFail" )
	end.

checkUserPassword( PassWord )->
	put( "checkUserPassword_SuccOrFail", false ),
	try
		Len = string:len( PassWord ),
		case ( Len >= 1 ) and ( Len =< 16 ) of
			true->put( "checkUserPassword_SuccOrFail", true );
			false->ok
		end,
		get( "checkUserPassword_SuccOrFail" )
	catch
		_->get( "checkUserPassword_SuccOrFail" )
	end.

%%onUserLogin( FromPID, UserSocket, Msg )->
onUserLogin( _UserSocket, Params )->
	Account = Params#userDBLogin.account,
	PlatformID = Params#userDBLogin.platformID,
	VersionRes = Params#userDBLogin.versionRes,
	VersionExe = Params#userDBLogin.versionExe,
	VersionGame = Params#userDBLogin.versionGame,
	VersionPro = Params#userDBLogin.versionPro,

	put( "onUserLogin_Result", ?Login_LS_Result_Fail_UserNameOrPassword ),
	try
		
		%% ->{error,0}  means query error,{ok,0} means no this user, {ok,id} 
		% set platform id as 0, must modify
		case loginMysqlProc:get_userId(PlatformID,Account) of 
			{error,0}->
				put( "onUserLogin_Result", ?Login_LS_Result_Fail_DbError ),
				throw(-1);
			{ok,0} -> 
				Id = db:memKeyIndex(PlatformID),
				Now = common:timestamp(), %seconds
				loginLogdbProc:insertLogAccountLogin(#user{id=Id, platformId=PlatformID, userName=Account, resVer=VersionRes, 
											exeVer=VersionExe,gameVer=VersionGame,protocolVer=VersionPro,lastLogintime=Now},
													get("UserIP") ),
				case loginMysqlProc:insertUser(#user{id=Id, platformId=PlatformID, userName=Account, resVer=VersionRes, 
											exeVer=VersionExe,gameVer=VersionGame,protocolVer=VersionPro,lastLogintime=Now,createTime=Now}) of
					{error,_} ->
						put( "onUserLogin_Result", ?Login_LS_Result_Fail_DbError ),
						throw(-1);
					_ ->
						#userDBLoginResult{resultCode=?Login_LS_Result_Succ,account=Account,userID=Id,platId=PlatformID}
				end;
			{ok,Id} ->
				% should update db
				Now = common:timestamp(), %seconds
				loginMysqlProc:replaceUser(#user{id=Id, platformId=PlatformID, userName=Account, resVer=VersionRes, 
											exeVer=VersionExe,gameVer=VersionGame,protocolVer=VersionPro,lastLogintime=Now}),
				loginLogdbProc:insertLogAccountLogin(#user{id=Id, platformId=PlatformID, userName=Account, resVer=VersionRes, 
											exeVer=VersionExe,gameVer=VersionGame,protocolVer=VersionPro,lastLogintime=Now},
													 get("UserIP") ),
				#userDBLoginResult{resultCode=?Login_LS_Result_Succ,account=Account,userID=Id,platId=PlatformID}
		end
	catch
		_->#userDBLoginResult{ resultCode=get("onUserLogin_Result"),account=Account,userID=0,platId=PlatformID}
	end.
