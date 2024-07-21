%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(main).

%% add to support gen_server
-behaviour(gen_server).
-export([start_link/0,start/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%%
%% Include files
%%


-include("package.hrl").
-include("hdlt_logger.hrl").
-include("db.hrl").
-include("condition_compile.hrl").
-include("playerDefine.hrl").
-include("globalDefine.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include( "daily.hrl" ).


%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% API Functions
%%
start() ->
	gameServerSup:start_link(),
	timer:sleep(infinity).

	


start_link() ->
	gen_server:start_link({local,mainPID},?MODULE, [], [{timeout,?Start_Link_TimeOut_ms}]).

init([]) ->

	ets:new( ?ReadyLoginUserTableAtom, [set,protected, named_table, { keypos, #readyLoginUser.userID }] ),
	%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.readyLoginUserTable, ReadyLoginUser ),
	%put( "ReadyLoginUser", ReadyLoginUser ),
	
	
	ets:new( ?SocketDataTableAtom, [set,protected, named_table,{read_concurrency,true},  { keypos, #socketData.socket }] ),
	ets:new( ?PlayerGlobalTableAtom, [set,protected, named_table,{read_concurrency,true},  { keypos, #playerGlobal.id }] ),
	
	

	
	
	variant:initWorldVarArray(),
	erlang:send_after(2000, self(),{mainTimer_updateReadyLoginUser} ),
	ets:new( 'kickOutTableAtom', [set,protected,named_table, { keypos, #kickoutUser.pid }] ),
	erlang:send_after(?UpdateKickOutTableTimer,self(), {mainTimer_updateKickOutTable} ),
	erlang:send_after(?CountOnlinePlayerTimer,self(), {mainTimer_countOnlinePlayer} ),
	erlang:send_after(?RecoverMnesiaGarbTimer, self(),{mainTimer_recoverMnesiaGarb} ),
    {ok, {}}.

deleteSocketDataBySocket_rpc(Socket)->
	gen_server:call(mainPID,{deleteSocketData, {Socket}}).
changeSocketData_rpc({Socket,Field,Value})->
	gen_server:call(mainPID,{changeSocketData, {Socket,Field,Value}}).



handle_call({deleteSocketData, {Socket}}, _from, Status) ->
	ets:delete( ?SocketDataTableAtom, Socket),
    {reply, {ok,true}, Status};
handle_call({insertSocketData, #socketData{} = Record}, _from, Status) ->
	ets:insert( ?SocketDataTableAtom, Record),
    {reply, {ok,true}, Status};
handle_call({changeSocketData, {Socket,Field,Value}}, _from, Status) ->
	etsBaseFunc:changeFiled( ?SocketDataTableAtom, Socket, Field, Value ),
    {reply, {ok,true}, Status};

handle_call({deletePlayerGlobal, {PlayerID}}, _from, Status) ->
	ets:delete( ?PlayerGlobalTableAtom, PlayerID),
    {reply, {ok,true}, Status};
handle_call({insertPlayerGlobal, #playerGlobal{} = Record}, _from, Status) ->
	ets:insert( ?PlayerGlobalTableAtom, Record),
    {reply, {ok,true}, Status};
handle_call({changePlayerGlobal, {PlayerID,Field,Value}}, _from, Status) ->
	etsBaseFunc:changeFiled( ?PlayerGlobalTableAtom, PlayerID, Field, Value ),
    {reply, {ok,true}, Status};


handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%返回该服ID
getServerID()->
	case get("main_GameServerId") of
		undefined -> 
			Id1 = loginServer:ini_ReadInt( "GameServerSetup.txt", "GameServerId", 1 ),
			put("main_GameServerId",Id1),
			Id1;
		Id->Id
	end.
    
getGlobalItemCfgTable()->
	?ItemCfgTableAtom.

%%返回玩家装备强化及其加成列表，
getGlobalEquipEnhancePropertyTable()->
	?EquipEnhancePropertyTableAtom.


%%返回玩家装备品质提升，基础属性加成列表，
getGlobalequipmentqualityTable()->
	?EquipmentqualityTableAtom.



%%返回玩家装备品质提升时，附加属性的改变列表
getGlobalequipmentqualityfactorTable()->
	?EquipmentqualityfactorTableAtom.


%%返回附加属性的取值范围列表
getGlobalequipmentqualityattributeTable()->
	?EquipmentqualityattributeTableAtom.
			   
					
%%返回各类附加属性出现的几率列表
getGlobalequipmentqualityweightTable()->
	?EquipmentqualityweightTableAtom.

			
%%返回玩家装备激活和品质提升，需要的材料及数量列表
getGlobalequipmentActiveItemNeedTable()->
	?EquipmentActiveItemNeedTableAtom.
	
%%返回装备升品及洗髓所消耗的游戏币列表
getGlobalequipmentWashupMoneyTable()->
	?EquipwashupMoneyTableAtom.
	

%%返回商店Table
getGlobalAllStoreTable()->
	?AllStoreTableAtom.


getGlobalEquipCfgTable()->
	?EquipCfgTableAtom.
	
getGlobalEquipTreeCfgTable()->
	?EquipTreeCfgTableAtom.

getGlobalTaskBaseTable()->
	?TaskBaseTableAtom.


getGlobalDropPackageTable() ->
	?DropPackageTableAtom.


getGlobalDropTable() ->
	?DropTableAtom.


getCurPlayerOrderTable()->
 	_OrderTable = get( "playerOrderTable" ).


getGlobalMonsterCfgTable()->
	?MonsterCfgTableAtom.
	

getGlobalNpcCfgTable()->
	?NpcCfgTableAtom.
	
getGlobalMapCfgTable()->
	?MapCfgTableAtom.
	

getGlobalObjectCfgTable()->
	?ObjectCfgTableAtom.
	

getGlobalPlayerEXPCfgTable()->
	?PlayerEXPCfgTableAtom.


getGlobalSkillCfgTable()->
	?SkillCfgTableAtom.
	

getGlobalDailyCfgTable()->
	?DailyCfgTableAtom.


getSkillCfgByGroupAndLevel(Group, Level )->
	Q = ets:fun2ms( fun(#skillCfg{level=LevelValue,
								  skill_group=GroupId} = Record ) when (GroupId=:=Group) and (LevelValue=:=Level) -> Record end),
	SkillList = ets:select(getGlobalSkillCfgTable(), Q),
	case SkillList of
		[SkillCfg|_] ->SkillCfg;
		[]->{}
	end.

getSkillCfgListByGroup( Group )->
	Q = ets:fun2ms( fun(#skillCfg{skill_group=GroupId} = Record ) when (GroupId=:=Group)-> Record end),
	ets:select(getGlobalSkillCfgTable(), Q).

getGlobalSkillEffectCfgTable()->
	?SkillEffectCfgTableAtom.
	

getGlobalBuffCfgTable()->
	?BuffCfgTableAtom.


getAttackFactorCfgTable()->
	?AttackFatorCfgTableAtom.
	

getAttributeRegentCfgTable()->
	?AttributeRegentCfgTableAtom.
	

getScriptObjectTable()->
	?ScriptObjectTableAtom.


getGuildLevelCfgTable()->
	?GuildLevelCfgTableAtom.


%% getGuildSkillCfgTable()->
%% 	db:getFiled( globalMain, ?GlobalMainID, #globalMain.guildSkillCfgTable).


getMonsterDeadEXPTable()->
	'MonsterDeadEXPTable'.

getDailyTargetCfgByType(Type)->
	case Type > ?DailyType_Num of
		true->0;
		_->
			array:get(Type, etsBaseFunc:getRecordField( ?GlobalMainAtom, ?GlobalMainID, #globalMain.dailyTargetTypeTable))
	end.

getGlobalPartyCfgTable()->
	'globlePartyCfgTable'.



handle_info(Info, StateData)->	
	put( "mainRecieve", true ),

	try
	case Info of
		{quit}->
			?LOG_OUT( "main quit" ),
			put( "mainRecieve", false );	 	
		{loginServerCheckPass}->
			on_loginServerCheckPass();
		{ onLS2GS_UserReadyToLogin, Msg }->
			on_LS2GS_UserReadyToLogin( Msg );
		{userLogin, UserID}->
			onUserLogin(UserID);
		{ onLS2GS_KickOutUser, Msg }->
			main_on_LS2GS_KickOutUser( Msg );
		{ onGm_KickOutAllPlayers }->
			main_kickout_allPlayers(  );
		{ onGm_forbidlogin }->
			main_forbidlogin(  );
		{ mainTimer_updateReadyLoginUser }->
			updateReadyLoginUser(),
			erlang:send_after(2000, self(),{mainTimer_updateReadyLoginUser} );
		{ mainTimer_updateKickOutTable }->
			updateKickOutTable(),
			erlang:send_after(?UpdateKickOutTableTimer,self(), {mainTimer_updateKickOutTable} );
		{ mainTimer_countOnlinePlayer }->
			countOnlinePlayer(),
			erlang:send_after(?CountOnlinePlayerTimer, self(),{mainTimer_countOnlinePlayer} );
		{ kickoutByPlayerId, PlayerID }->
			main_on_kickoutByPlayerId( PlayerID );
		{mainTimer_recoverMnesiaGarb} ->
			try
				mnesia_recover:allow_garb(),
				mnesia_recover:start_garb()	
			catch
				_:Why1->
					common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[mnesia_recover:start_garb] Why[~p] stack[~p]", 
						[?MODULE,Why1, erlang:get_stacktrace()] )
			end,
			erlang:send_after(?RecoverMnesiaGarbTimer,self(), {mainTimer_recoverMnesiaGarb} );
		{setWorldVarFlag,Index, BitIndex,BitValue} ->
			variant:setWorldVarFlag(Index, BitIndex,BitValue);
		{setWorldVarValue,Index, NewValue} ->
			variant:setWorldVarValue(Index, NewValue);
		_->
			?LOG_OUT( "mainRecieve unkown" )
	end,
	case get("mainRecieve") of
		true->{noreply, StateData};
		false->{stop, normal, StateData}
	end
	
	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[?MODULE,_Why, erlang:get_stacktrace()] ),
			{noreply, StateData}
	end.

on_loginServerCheckPass()->
	%%修改配置文件端口方式处理外部连接
	%ListenToUserPort = loginServer:ini_ReadInt( "GameServerSetup.txt", "ListenToUserPort", 6789 ),
	
	%% move it to gameServerSup
	%netServerSup:start_link(ListenToUserPort, netUsers),
	
	loginServer:sendToLoginServer( #pk_GS2LS_ReadyToAcceptUser{reserve=0} ),
	
	%%全服启动成功
	?ERROR_OUT( "---info: all start succ." ),
	
	ok.


getReadyLoginUserTable()->
	?ReadyLoginUserTableAtom.
%% 	ReadyLoginUser = get( "ReadyLoginUser" ),
%% 	case ReadyLoginUser of
%% 		undefined->db:getFiled( globalMain, ?GlobalMainID, #globalMain.readyLoginUserTable );
%% 		_->ReadyLoginUser
%% 	end.

getReadyLoginUserRecord( UserID )->
	etsBaseFunc:readRecord( getReadyLoginUserTable(), UserID ).

updateReadyLoginUser()->
	try
		Now = common:timestamp(),
		
		Q = ets:fun2ms( fun(#readyLoginUser{userID='_', unable_time=Unable_time } = Record ) when ( Unable_time =< Now ) -> Record end),
		UnableList = ets:select(getReadyLoginUserTable(), Q),
		
		lists:foreach(fun(Record)-> 
						  ToLS = #pk_GS2LS_UserLogoutGameServer{userID=Record#readyLoginUser.userID, identity=Record#readyLoginUser.identitity},
						  loginServer:sendToLoginServer(ToLS),
						  ?LOG_OUT( "updateReadyLoginUser user[~p] time out ", [Record#readyLoginUser.userID] ),
						  etsBaseFunc:deleteRecord( getReadyLoginUserTable(), Record#readyLoginUser.userID) 
				  end, UnableList ),
		
		ok
	catch
		_->ok
	end.


updateKickOutTable()->
	try
		Now = common:timestamp(),
		Q = ets:fun2ms( fun(#kickoutUser{pid='_', kill_time=Kill_time } = Record ) when ( Kill_time =< Now ) -> Record end),
		KillList = ets:select(kickOutTableAtom, Q),

		lists:map(fun(Record)-> 
					etsBaseFunc:deleteRecord( kickOutTableAtom, Record#kickoutUser.pid),
					case is_pid(Record#kickoutUser.pid) and is_process_alive(Record#kickoutUser.pid) of
						true-> 
							?LOG_OUT( "UpdateKickOutTableTimer kill:~p, userid:~p", [Record#kickoutUser.pid,Record#kickoutUser.userId] ),
							%db:delete( socketData, Record#kickoutUser.socket ),
							ets:delete( ?SocketDataTableAtom, Record#kickoutUser.socket),
							loginServer:sendToLoginServer( #pk_GS2LS_UserLogoutGameServer{
										userID=Record#kickoutUser.userId,identity=Record#kickoutUser.identitity} ),
							%Record#kickoutUser.pid ! kill;		
							exit(Record#kickoutUser.pid,kill);
								
						_->
							ok
					end	
				end,KillList),
		ok
	catch
		_->ok
	end.

countOnlinePlayer()->
	Count = netUsers:getOnlineUserCounts(), 
	logdbProcess:write_log_online_record(Count),
	mySqlProcess:saveWorldVarArray().



on_LS2GS_UserReadyToLogin( #pk_LS2GS_UserReadyToLogin{}=Msg )->
	try
		%% there is a timer to update, so comment the next line
		%updateReadyLoginUser(),
		
		AllUsers = netUsers:getOnlineUserCounts() + ets:info( getReadyLoginUserTable(), size ),
		case AllUsers >= ?MaxOnlineUsers of
			true->
				GS2LS_UserReadyLoginResult = #pk_GS2LS_UserReadyLoginResult{userID=Msg#pk_LS2GS_UserReadyToLogin.userID, result=-1},
				loginServer:sendToLoginServer( GS2LS_UserReadyLoginResult ),
				?LOG_OUT( "on_LS2GS_UserReadyToLogin user[~p] false full", [Msg#pk_LS2GS_UserReadyToLogin.userID] ),
				throw(-1);
			false->ok
		end,
		
		ReadyLoginUser = #readyLoginUser{userID=Msg#pk_LS2GS_UserReadyToLogin.userID, 
										 unable_time=common:timestamp()+?ReadyLoginUserUnableTime, 
										 identitity=Msg#pk_LS2GS_UserReadyToLogin.identity,
										 name=Msg#pk_LS2GS_UserReadyToLogin.username,
										 platId=Msg#pk_LS2GS_UserReadyToLogin.platId},
		etsBaseFunc:insertRecord( getReadyLoginUserTable(), ReadyLoginUser ),
		GS2LS_UserReadyLoginResult2 = #pk_GS2LS_UserReadyLoginResult{userID=Msg#pk_LS2GS_UserReadyToLogin.userID, result=0},
		loginServer:sendToLoginServer( GS2LS_UserReadyLoginResult2 ),
		?LOG_OUT( "on_LS2GS_UserReadyToLogin user[~p] identity[~p] name[~p]", [Msg#pk_LS2GS_UserReadyToLogin.userID, Msg#pk_LS2GS_UserReadyToLogin.identity, Msg#pk_LS2GS_UserReadyToLogin.username] ),
		ok
	catch
		_->ok
	end.

onUserLogin(UserID)->
	try
		ReadyLoginUser = getReadyLoginUserRecord( UserID ),
		case ReadyLoginUser of
			{}->throw(-1);
			_->ok
		end,
		
		etsBaseFunc:deleteRecord( getReadyLoginUserTable(), UserID),
		GS2LS_UserLoginGameServer = #pk_GS2LS_UserLoginGameServer{userID=UserID},
		loginServer:sendToLoginServer( GS2LS_UserLoginGameServer ),
		?DEBUG_OUT( "onUserLogin ~p to delete", [UserID] ),
		ok
	catch
		_->ok
	end.

main_on_LS2GS_KickOutUser( #pk_LS2GS_KickOutUser{userID=UserID,identity=Identity}=Msg )->
	?LOG_OUT( "main_on_LS2GS_KickOutUser Msg[~p]", [Msg] ),
	etsBaseFunc:deleteRecord( getReadyLoginUserTable(), UserID),	
	%LoginUserList = db:matchObject(socketData, #socketData{_ = '_', userId=UserID}),
	%% maybe need improve performance
	Q = ets:fun2ms( fun(Record) when (Record#socketData.userId =:= UserID)->Record end ),
	LoginUserList = ets:select(?SocketDataTableAtom, Q),
	
	case LoginUserList of
		[]->
			?DEBUG_OUT( "main_on_LS2GS_KickOutUser to ls" ),
			loginServer:sendToLoginServer( #pk_GS2LS_UserLogoutGameServer{userID=UserID,identity=Identity} );
		[User|_]->
			?DEBUG_OUT( "main_on_LS2GS_KickOutUser to user [~p]", [User] ),
			%% add kick out user to kickOutTableAtom
			case etsBaseFunc:readRecord( kickOutTableAtom, User#socketData.pid) of
				{} ->
					KickoutUser = #kickoutUser{pid=User#socketData.pid, 
											kill_time=common:timestamp()+?KickoutUserKillTime,
											socket=User#socketData.socket, 
											userId=User#socketData.userId,
											playerId=User#socketData.playerId,
											identitity=Identity },
					etsBaseFunc:insertRecord( kickOutTableAtom, KickoutUser );
				_ -> ok
			end,

			%% modified by wenziyong, special handle the use process is die
			case is_pid(User#socketData.pid) and is_process_alive(User#socketData.pid) of
				true->
					?LOG_OUT( "main_on_LS2GS_KickOutUser  user[~p] is live to wait", [User] ),
					User#socketData.pid ! { kickOut, ?KickoutUser_Reson_ReLogin };
				_->
					?LOG_OUT( "main_on_LS2GS_KickOutUser  user process is died [~p]", [User] ),
					%db:delete( socketData, User#socketData.socket ),
					ets:delete( ?SocketDataTableAtom, User#socketData.socket),
					loginServer:sendToLoginServer( #pk_GS2LS_UserLogoutGameServer{userID=UserID,identity=Identity} )
			end
	end,
	ok.


main_kickout_allPlayers() ->
	?LOG_OUT( "main_kickout_allPlayers" ),
	%PlayerList = db:matchObject(socketData, #socketData{_ = '_'}),
	Q = ets:fun2ms( fun(Record)->Record end ),
	PlayerList = ets:select(?SocketDataTableAtom, Q),
	%-record(socketData,{socket,userId,playerId, pid}).
	ReadyLoginUserTable = getReadyLoginUserTable(),
	MyFunc = fun( Record )->
					 ?DEBUG_OUT( "main_kickout_allPlayers to user [~p]", [Record] ),
					 etsBaseFunc:deleteRecord( ReadyLoginUserTable, Record#socketData.userId),
					 Record#socketData.pid ! { kickOut, ?KickoutUser_Reson_GM }
			 end,
	lists:foreach( MyFunc, PlayerList ),
	ok.

main_forbidlogin() ->
	etsBaseFunc:changeFiled( ?GlobalMainAtom, ?GlobalMainID, #globalMain.is_forbid_login, true ).
	%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.is_forbid_login, true).

getIsForbidLogin()->
	etsBaseFunc:getRecordField( ?GlobalMainAtom, ?GlobalMainID, #globalMain.is_forbid_login ).
	%db:getFiled( globalMain, ?GlobalMainID, #globalMain.is_forbid_login ).




main_on_kickoutByPlayerId( PlayerID )->
	?LOG_OUT( "main_on_kickoutByPlayerId PlayerID[~p]", [PlayerID] ),
	
	%FindePlayer = db:matchObject(playerGlobal, #playerGlobal{id=PlayerID, _='_'} ),
	FindePlayer = etsBaseFunc:readRecord( ?PlayerGlobalTableAtom, PlayerID ),
	case FindePlayer of
		{}->?LOG_OUT( "main_on_kickoutByPlayerId PlayerID[~p], can't find the player", [PlayerID] );
		PlayerGlobal->
			ReadyLoginUserTable = getReadyLoginUserTable(),
			UserId = player:getPlayerProperty( PlayerGlobal#playerGlobal.id, #player.userId ),
			etsBaseFunc:deleteRecord( ReadyLoginUserTable, UserId),
			PlayerGlobal#playerGlobal.pid ! { kickOut, ?KickoutUser_Reson_GM }		
	end.



