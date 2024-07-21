%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(guild).

%% add by wenziyong for gen server
-behaviour(gen_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%
%% Include files
%%
-include("mysql.hrl").
-include("db.hrl").
-include("chat.hrl").
-include("game_str_cn.hrl").
-include("playerDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("guildDefine.hrl").
-include("itemDefine.hrl").
-include("mapDefine.hrl").
-include("condition_compile.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("logdb.hrl").
-include("textDefine.hrl").
-include("globalDefine.hrl").


%%
%% Exported Functions
%%
-compile(export_all).

start_link() ->
	gen_server:start_link({local,guildProcess_PID},?MODULE, [], [{timeout,?Start_Link_TimeOut_ms}]).



init([]) ->
	%put( "GuildLevelCfgTable", db:getFiled( globalMain, ?GlobalMainID, #globalMain.guildLevelCfgTable) ),
	%put( "GuildTaskCfgTable", db:getFiled( globalMain, ?GlobalMainID, #globalMain.guildTaskCfgTable) ),
	%mySqlProcess:sqldb_connect(pguild),
	loadAllGuildFromDB(),
    {ok, {}}.


handle_call({'randomGuildTask',PlayerLevel}, _From, State) ->
	{reply,randomGuildTaskByPlayerLevel(PlayerLevel),State};

handle_call( {'getGuildInfo',GuildID, PlayerID}, _From, State) ->
	?DEBUG_OUT("getGuildInfo cast,GuildID:~p",[GuildID]),
	GuildInfo = getGuildBaseRecord(GuildID),
	MemberInfo = getGuildMemberRecord( GuildID, PlayerID ),
	 {reply, {GuildInfo,MemberInfo}, State};


handle_call({'getGuildLevel',GuildID}, _From, State) ->
	?DEBUG_OUT("getGuildLevel call,GuildID:~p",[GuildID]),
	case GuildID > 0 of
		true->{reply,getGuildLevel(GuildID),State};
		false->{reply,0,State}
	end;

handle_call({'getAddExpPercent',GuildID}, _From, State) ->
	?DEBUG_OUT("getAddExpPercent call,GuildID:~p",[GuildID]),
	case GuildID > 0 of
		true->
			{reply,
			 etsBaseFunc:getRecordField(?GuildLevelCfgTableAtom, getGuildLevel(GuildID),#guildLevelCfg.addExp_Percent),
			 State};
		false->
			{reply,0,State}
	end;

handle_call(_Request, _From, State) ->
	{reply, ok, State}.

handle_cast({'guildMemberLevel',GuildID,PlayerID,Level},State) ->
	?DEBUG_OUT("guildMemberLevel cast,GuildID:~p,PlayerID:~p,Level:~p",[GuildID,PlayerID,Level]),
	on_guildMemberLevelChanged( PlayerID, GuildID, Level ),
	{noreply,State};

handle_cast({'addGuildExp',GuildID,Value},State) ->
	?DEBUG_OUT("addGuildExp cast,GuildID:~p,Value:~p",[GuildID,Value]),
	addGuildExp(GuildID,Value), 
	{noreply,State};

handle_cast({'addGuildMemberContribution',GuildID,PlayerID,Value},State) ->
	?DEBUG_OUT("addGuildMemberContribution cast,GuildID:~p,PlayerID:~p,Value:~p",[GuildID,PlayerID,Value]),
	addGuildMemberContributionByID(GuildID,PlayerID,Value), 
	{noreply,State};

handle_cast(_Msg, State) ->
    {noreply, State}.



terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%加载仙盟配置表
guildCfgLoad()->
	case db:openBinData( "guild_level.bin" ) of
		[] ->
			?ERROR_OUT( "guildCfgLoad openBinData guild_level.bin false []" );
		GuildLevelData ->
			db:loadBinData( GuildLevelData, guildLevelCfg ),
			

			ets:new( ?GuildLevelCfgTableAtom, [set,protected, named_table,{read_concurrency,true},  { keypos, #guildLevelCfg.level }] ),
			

			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.guildLevelCfgTable, GuildLevelCfgTable),
			
			GuildLevelCfgList = db:matchObject(guildLevelCfg,  #guildLevelCfg{_='_'} ),
			MyFunc = fun( Record )->
							 etsBaseFunc:insertRecord(?GuildLevelCfgTableAtom, Record)
					 end,
			lists:map( MyFunc, GuildLevelCfgList ),
			?DEBUG_OUT( "guild_levelCfgLoad succ" )
	end,
	case db:openBinData( "guild_task.bin" ) of
		[] ->
			?ERROR_OUT( "guildCfgLoad openBinData guild_task.bin false []" );
		GuildTaskData ->
			db:loadBinData( GuildTaskData, guildTaskCfg ),
			

			ets:new( ?GuildTaskCfgTableAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #guildTaskCfg.id }] ),
			
			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.guildTaskCfgTable, GuildTaskCfgTable),
			
			GuildTaskCfgList = db:matchObject(guildTaskCfg,  #guildTaskCfg{_='_'} ),
			MyFunc1 = fun( Record )->
							 etsBaseFunc:insertRecord(?GuildTaskCfgTableAtom, Record)
					 end,
			lists:map( MyFunc1, GuildTaskCfgList ),
			?DEBUG_OUT( "guild_TaskCfgLoad succ" )
	end.

getGuildTable()->
	GuildBaseTable = get( "GuildBaseTable" ),
	case GuildBaseTable of
		undefined->0;
		_->GuildBaseTable
	end.

getGuildLevelRecord(Level)->
	etsBaseFunc:readRecord( ?GuildLevelCfgTableAtom, Level ).

getGuildTaskRecord(ID)->
	etsBaseFunc:readRecord(?GuildTaskCfgTableAtom,ID).

getGuildMemberTableName(GuildID)->
	StringValue = io_lib:format( "GuildMemberTable_~p", [GuildID] ),
	StringValue2 = lists:flatten(StringValue),
	StringValue2.

getGuildApplicantTableName(GuildID)->
	StringValue = io_lib:format( "GuildApplicantTable_~p", [GuildID] ),
	StringValue2 = lists:flatten(StringValue),
	StringValue2.

%%返回某仙盟基本信息记录
getGuildBaseRecord( GuildID )->
	etsBaseFunc:readRecord( getGuildTable(), GuildID ).

%%返回某仙盟成员列表
getGuildMemberList( GuildID )->
	GuildBase = getGuildBaseRecord( GuildID ),
	case GuildBase of
		{}->[];
		_->Q = ets:fun2ms( fun(#guildMember{}=Record)->Record end ),
		   ets:select(GuildBase#guildBaseInfo.memberTable, Q)
	end.
%%返回某仙盟成员信息记录
getGuildMemberRecord( GuildID, PlayerID )->
	GuildBase = getGuildBaseRecord( GuildID ),
	case GuildBase of
		{}->{};
		_->Q = ets:fun2ms( fun(#guildMember{id='_',playerID=PlayerIDDB}=Record) when PlayerIDDB=:= PlayerID ->Record end ),
		   PlayerList = ets:select(GuildBase#guildBaseInfo.memberTable, Q),
		   case PlayerList of
			   []->{};
			   [Player|_]->Player
		   end
	end.

%%返回某仙盟申请成员信息记录
getGuildApplicatnRecord( GuildID, PlayerID )->
	GuildBase = getGuildBaseRecord( GuildID ),
	case GuildBase of
		{}->{};
		_->Q = ets:fun2ms( fun(#guildApplicant{id='_',playerID=PlayerIDDB}=Record) when PlayerIDDB=:= PlayerID ->Record end ),
		   PlayerList = ets:select(GuildBase#guildBaseInfo.applicantTable, Q),
		   case PlayerList of
			   []->{};
			   [Player|_]->Player
		   end
	end.

%%发送消息给仙盟所有成员
sendMsgToAllMember( Guild, Msg )->
	MyFunc = fun( Record )->
					 case Record#guildMember.isOnline =:= 0 of
						 true->ok;
						 false->player:sendToPlayer( Record#guildMember.playerID, Msg )
					 end
			 end,
	etsBaseFunc:etsFor( Guild#guildBaseInfo.memberTable, MyFunc ).

%%发送消息给仙盟所有成员
sendMsgToAllMemberByGulidID( GuildID, Msg )->
	case etsBaseFunc:readRecord(getGuildTable(), GuildID ) of
		{}->ok;
		Gulid->
			sendMsgToAllMember( Gulid, Msg)
	end.

%%发送消息到仙盟在线玩家进程
sendMsgToAllOnLineMemberProcess( Guild, Msg )->
	MyFunc = fun( Record )->
					 case Record#guildMember.isOnline =:= 0 of
						 true->ok;
						 false->player:sendToPlayerProc( Record#guildMember.playerID, Msg )
					 end
			 end,
	etsBaseFunc:etsFor( Guild#guildBaseInfo.memberTable, MyFunc ).

%init()->
%	proc_lib:start(?MODULE, procGuild, [0], ?ProcessTimeOut),
%	ok.




loadAllGuildFromDB()->
	%%仙盟表
	GuildBaseTable =  ets:new( 'guildBaseInfo', [protected,{read_concurrency,true}, { keypos, #guildBaseInfo.id }] ),
	put( "GuildBaseTable", GuildBaseTable ),
	

	GuildList=mySqlProcess:get_allGuidBase(),
	MyFunc = fun( Record )->
						%%仙盟表
						GuildMemberTable =  ets:new( 'guildMember1', [{ keypos, #guildMember.playerID }] ),
					 	Guild2 = setelement( #guildBaseInfo.memberTable, Record, GuildMemberTable ),
						GuildMemberList = mySqlProcess:get_guidMembersByGuidId(Record#guildBaseInfo.id),
						lists:map( fun(RecordMember)->
										   etsBaseFunc:insertRecord( GuildMemberTable, RecordMember )
								   end,
								   GuildMemberList ),
						
						%%仙盟申请表
						GuildApplicantTable =  ets:new( 'guildApplicant', [protected, { keypos, #guildApplicant.playerID }] ),
					 	Guild3 = setelement( #guildBaseInfo.applicantTable, Guild2, GuildApplicantTable ),
						GuildApplicantList  = mySqlProcess:get_guidApplicantByGuidId(Record#guildBaseInfo.id),
						lists:map( fun(RecordApplicant)->
										   etsBaseFunc:insertRecord( GuildApplicantTable, RecordApplicant )
								   end,
								   GuildApplicantList ),
						
						etsBaseFunc:insertRecord( getGuildTable(), Guild3 ),
						ok
				 end,
	lists:map( MyFunc, GuildList ),
	ok.


handle_info(Info, StateData)->	
	
	put( "guildLoop", true ),

	try
	case Info of
		{ msg_U2GS_RequestJoinGuld, FromPID, PlayerID, PlayerName, ZhanLi, Level, Class, Faction, GuildID }->
		  on_msg_U2GS_RequestJoinGuld( FromPID, PlayerID, PlayerName, ZhanLi, Level, Class, Faction, GuildID );
		{ msg_U2GS_RequestGuildQuit, FromPID, PlayerID, GuildID }->
			on_msg_U2GS_RequestGuildQuit( FromPID, PlayerID, GuildID );
		{ msg_U2GS_RequestGuildKickOutMember, FromPID, PlayerID, GuildID, #pk_U2GS_RequestGuildKickOutMember{}=Msg }->
			on_msg_U2GS_RequestGuildKickOutMember( FromPID, PlayerID, GuildID, Msg );
		{ msg_U2GS_RequestGuildMemberRankChange, PlayerID, GuildID, #pk_U2GS_RequestGuildMemberRankChange{}=Msg }->
			on_msg_U2GS_RequestGuildMemberRankChange( PlayerID, GuildID, Msg );
		{ msg_U2GS_RequestGuildContribute, PlayerID, GuildID, #pk_U2GS_RequestGuildContribute{}=Msg }->
			on_msg_U2GS_RequestGuildContribute( PlayerID, GuildID,Msg );
		{ msg_U2GS_RequestChangeGuildAffiche, PlayerID, GuildID, Msg }->
			on_msg_U2GS_RequestChangeGuildAffiche( PlayerID, GuildID, Msg );
		{ msg_U2GS_GetMyGuildApplicantShortInfo, FromPID, PlayerID, GuildID }->
			on_msg_U2GS_GetMyGuildApplicantShortInfo( FromPID, PlayerID, GuildID );
		{ msg_U2GS_GetMyGuildInfo, FromPID, PlayerID, GuildID }->
			on_msg_U2GS_GetMyGuildInfo( FromPID, PlayerID, GuildID );
		{ msg_U2GS_QueryGuildShortInfoEx, FromPID, PlayerID, Msg }->
			on_msg_U2GS_QueryGuildShortInfoEx( FromPID, PlayerID, Msg );
		{ msg_U2GS_QueryGuildList, FromPID, PlayerID, #pk_U2GS_QueryGuildList{}=Msg }->
			on_msg_U2GS_QueryGuildList( FromPID, PlayerID, #pk_U2GS_QueryGuildList{}=Msg );
		{ onPlayerOnline, FromPID, PlayerID, GuildID, PlayerLevel }->
			on_onPlayerOnline( FromPID, PlayerID, GuildID, PlayerLevel );
		{ msg_U2GS_RequestGuildApplicantAllow, FromPID, PlayerID, GuildID, TargetPlayerID, IsSingleProcess }->
			on_msg_U2GS_RequestGuildApplicantAllow(FromPID, PlayerID, GuildID, TargetPlayerID, IsSingleProcess );
		{ msg_U2GS_RequestGuildApplicantRefuse, FromPID, PlayerID, GuildID, TargetPlayerID }->
			on_msg_U2GS_RequestGuildApplicantRefuse(FromPID, PlayerID, GuildID, TargetPlayerID);
		{ onPlayerOffline, PlayerID, GuildID }->
			on_onPlayerOffline( PlayerID, GuildID );
		%{ checkPlayerGuildIDResult, PlayerID, Result, TargetPlayerID, GuildID, IsSingleProcess }->
		%	on_checkPlayerGuildIDResult(PlayerID, Result, TargetPlayerID, GuildID, IsSingleProcess );
		%{ kickoutPlayerResult,PlayerID, Result, TargetPlayerID, GuildID}->
		%	on_kickoutPlayerResult(PlayerID, Result, TargetPlayerID, GuildID);
		{msg_U2GS_RequestCreateGuild, FromPID,GuildLevel,PlayerID, PlayerName, Faction, PlayerLevel, PlayerClass, Msg }->
			guild_on_U2GS_RequestCreateGuild( FromPID,GuildLevel,PlayerID, PlayerName, Faction, PlayerLevel, PlayerClass, Msg );
		{ msg_U2GS_RequestGuildApplicantOPAll, FromPID, PlayerID, GuildID, Flag }->
			on_msg_U2GS_RequestGuildApplicantOPAll( FromPID, PlayerID, GuildID, Flag );
		 {chat, GuildID, Msg}->
			sendMsgToAllMemberByGulidID(GuildID, Msg);
		{quit}->
			put( "guildLoop", false );
		_->?LOG_OUT( "guildLoop error" )
	end,
	
	case get( "guildLoop" )of
		true->{noreply, StateData};
		false->{stop, normal, StateData}
	end

	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[?MODULE,_Why, erlang:get_stacktrace()] ),
				

			{noreply, StateData}
	end.


guildLoop_Exception()->
	?ERROR_OUT("guild:guildLoop_Exception").

%%玩家上线，玩家进程
onPlayerOnline( PlayerID )->
	GuildID = player:getCurPlayerProperty( #player.guildID ),
	case GuildID =:= 0 of
		true->ok;
		false->guildProcess_PID ! { onPlayerOnline, self(), PlayerID, GuildID, player:getCurPlayerProperty( #player.level ) }
	end.
%%玩家上线，仙盟进程	
on_onPlayerOnline( FromPID, PlayerID, GuildID, PlayerLevel )->
	try
%% 		GuildList = db:matchObject(guildBaseInfo, #guildBaseInfo{_='_', chairmanPlayerID=PlayerID}),
		Rule = ets:fun2ms(fun(#guildBaseInfo{id=RuleGuildID}=Record) when (RuleGuildID =:=GuildID) -> Record end),
		GuildList = ets:select(getGuildTable(), Rule),
		case GuildList of
			[]->FromPID ! { setPlayerGuildID, 0 }, throw(-1);
			[Guild|_]->
				case GuildID =:= -1 of
					true->FromPID ! { setPlayerGuildID, Guild#guildBaseInfo.id };
					false->ok
				end,
				GuildMemberRecord = etsBaseFunc:readRecord( Guild#guildBaseInfo.memberTable, PlayerID),
				case GuildMemberRecord of
					{}->?ERROR_OUT( "on_onPlayerOnline PlayerID, GuildID[~p ~p] can not find memberrecord", [PlayerID, GuildID] );
					_->etsBaseFunc:changeFiled( Guild#guildBaseInfo.memberTable, PlayerID, #guildMember.isOnline, 1),
					   etsBaseFunc:changeFiled( Guild#guildBaseInfo.memberTable, PlayerID, #guildMember.playerLevel, PlayerLevel),
					   FromPID ! { guildMemberContributeSet, GuildMemberRecord#guildMember.contributeMoney, GuildMemberRecord#guildMember.contributeTime }
				end,
				
				ToMsg = #pk_GS2U_GuildMemberOnlineChanged{nPlayerID=PlayerID, nOnline=1},
				sendMsgToAllMember( Guild, ToMsg ),
				
				ok				
		end,
		ok
	catch
		_->ok
	end.
%%玩家进程，设置玩家仙盟ID
setPlayerGuildID( GuildID )->
	%% 设置了帮会ID，要立即更新数据库 add by yueliangyou[2013-04-28]
	OldGuildID=player:getCurPlayerProperty( #player.guildID),
	player:setCurPlayerProperty( #player.guildID, GuildID),
	player:savePlayerAll(),
	player:send( #pk_PlayerPropertyChanged{changeValues=[#pk_PlayerPropertyChangeValue{proType=?Player_Pro_GuildID, value=GuildID}]}).
	
%%玩家进程，设置玩家在仙盟中捐献铜币信息
on_guildMemberContributeSet( ContributeMoney, ContributeTime )->
	put( "ContributeMoney", ContributeMoney ),
	put( "ContributeTime", ContributeTime ).

%%玩家下线，玩家进程
onPlayerOffline( PlayerID )->
	GuildID = player:getCurPlayerProperty( #player.guildID ),
	case GuildID =:= 0 of
		true->ok;
		false->guildProcess_PID ! { onPlayerOffline, PlayerID, GuildID }
	end.
%%玩家下线，仙盟进程	
on_onPlayerOffline( PlayerID, GuildID )->
	try
%% 		GuildList = db:matchObject(guildBaseInfo, #guildBaseInfo{_='_', chairmanPlayerID=PlayerID}),
		Rule = ets:fun2ms(fun(#guildBaseInfo{id=RuleGuildID}=Record) when (RuleGuildID =:=GuildID) -> Record end),
		GuildList = ets:select(getGuildTable(), Rule),
		case GuildList of
			[]->ok;
			[Guild|_]->
				GuildMemberRecord = etsBaseFunc:readRecord( Guild#guildBaseInfo.memberTable, PlayerID),
				case GuildMemberRecord of
					{}->?ERROR_OUT( "on_onPlayerOffline, GuildID[~p ~p] can not find memberrecord", [PlayerID, GuildID] );
					_->etsBaseFunc:changeFiled( Guild#guildBaseInfo.memberTable, PlayerID, #guildMember.isOnline, 0)
				end,
				
				ToMsg = #pk_GS2U_GuildMemberOnlineChanged{nPlayerID=PlayerID, nOnline=0},
				sendMsgToAllMember( Guild, ToMsg ),
				ok				
		end,
		ok
	catch
		_->ok
	end.

%%玩家进程处理仙盟创建请求
on_U2GS_RequestCreateGuild(#pk_U2GS_RequestCreateGuild{useToken=GuildToken}=Msg)->
	put( "on_U2GS_RequestCreateGuild_Return", 0 ),
	try
		case get("player_create_guild_wait") of
			undefined->ok;
			1->put( "on_U2GS_RequestCreateGuild_Return", ?Guild_CreateResult_HasGuild ),throw(-1);
			_->ok
		end,

		Name = Msg#pk_U2GS_RequestCreateGuild.strGuildName,
		NameLen = string:len( Name ),
		case ( NameLen < ?Min_CreatePlayerName_Len ) or ( NameLen > ?Max_CreatePlayerName_Len*3 ) of
			true->
				put( "on_U2GS_RequestCreateGuild_Return", ?Guild_CreateResult_NameIllegal ),
				throw(-1);
			false->ok				
		end,

		case forbidden:checkForbidden(Name) of
			false->
				ok;
			true->
				put( "on_U2GS_RequestCreateGuild_Return", ?Guild_CreateResult_NameForbidden ),
				throw(-1)
		end,
		
		case player:getCurPlayerProperty( #player.level ) < ?GuildCreate_PlayerLevel of
			true->put( "on_U2GS_RequestCreateGuild_Return", ?Guild_CreateResult_PlayerLvl ),throw(-1);
			false->ok
		end,
		
		case player:getCurPlayerProperty( #player.guildID ) =:= 0 of
			true->ok;
			false->put( "on_U2GS_RequestCreateGuild_Return", ?Guild_CreateResult_HasGuild ),throw(-1)
		end,

		put("GuildCreateLevel",1),
		case GuildToken of
			0->
				case playerMoney:canDecPlayerMoney( ?GuildCreate_Money ) of
					true->ok;
					false->put( "on_U2GS_RequestCreateGuild_Return", ?Guild_CreateResult_PlayerMoney ),throw(-1)
				end,
				ParamTuple = #token_param{changetype = ?Money_Change_CreateGuild},
				playerMoney:decPlayerMoney( ?GuildCreate_Money, ?Money_Change_CreateGuild, ParamTuple);
				%%player:setCurPlayerProperty( #player.guildID, -1);
			
			_->%% 仙盟令创建
				ResultList = playerItems:canDecItemInBag(?Item_Location_Bag, ?GuildTokenItemID, 1, "all" ),
				case ResultList of
					[true|DecItemList]->
						playerItems:decItemInBag( DecItemList, ?Destroy_Item_Reson_GuildCreate),
						put("GuildCreateLevel",2);
					[false|_]->
						put( "on_U2GS_RequestCreateGuild_Return", ?Guild_CreateResult_NoGuildToken ),
						?MessageTipsMe(?GUILD_STR_NOGUILDTOKEN),throw(-1) 
				end
		end,
		
		put( "player_create_guild_wait", 1 ),
		
		guildProcess_PID ! { msg_U2GS_RequestCreateGuild, self(),get("GuildCreateLevel"), 
							 player:getCurPlayerID(), 
							 player:getCurPlayerProperty( #player.name ),
							 player:getCurPlayerProperty( #player.faction ), 
							 player:getCurPlayerProperty( #player.level ), 
							 player:getCurPlayerProperty( #player.camp ), 
							 Msg },
		
		ok
	catch
		_:_->
			MsgResult = #pk_GS2U_CreateGuildResult{result=get("on_U2GS_RequestCreateGuild_Return"), guildID=0},
			player:send( MsgResult ),
			ok
	end.
 
%%仙盟进程处理仙盟创建请求
guild_on_U2GS_RequestCreateGuild(FromPID,GuildLevel,PlayerID,PlayerName,Faction,PlayerLevel,PlayerClass, #pk_U2GS_RequestCreateGuild{}=Msg )->
	try
		%% should improve, should check whether exist this guid by ets 
		{_,GuildList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, "select * from guildBaseInfo_gamedata where guildName="++"'"++Msg#pk_U2GS_RequestCreateGuild.strGuildName++"'",true),
		GuildList = lists:map(fun(List) -> mySqlProcess:guildBaseInfoGamedata_list_to_record(List) end, GuildList1),
		case GuildList of
			[]->ok;
			_->FromPID ! { createGuildResult, 0, -5 },
			   throw(-1)
		end,
		
		GuildID = db:memKeyIndex(guildbaseinfo_gamedata), % persistent 
		GuildMemberTable =  ets:new( 'guildMember', [protected, { keypos, #guildMember.playerID }] ),
		GuildApplicantTable =  ets:new( 'guildApplicant', [protected, { keypos, #guildApplicant.playerID }] ),
		
		NewGuild = #guildBaseInfo{ id=GuildID,
								   chairmanPlayerID=PlayerID,
								   level=GuildLevel,
								   faction=Faction,
								   exp=0,
								   chairmanPlayerName=PlayerName,
								   guildName=Msg#pk_U2GS_RequestCreateGuild.strGuildName,
								   affiche="",
								   createTime=common:timestamp(),
								   memberTable=GuildMemberTable,
								   applicantTable=GuildApplicantTable },
		etsBaseFunc:insertRecord(getGuildTable(), NewGuild),
		
		mySqlProcess:insertGuildBaseInfoGamedata(NewGuild),
		
		NewMember = #guildMember{ id=db:memKeyIndex(guildmember_gamedata), % persistent
								  guildID=GuildID,
								  playerID=PlayerID,
								  rank=?GuildRank_Chairman,
								  playerName=PlayerName,
								  playerLevel=PlayerLevel,
								  playerClass=PlayerClass,
								  isOnline=1,
								  contribute=0,
								  contributeMoney=0,
								  contributeTime=0,
								  joinTime=common:timestamp() },
		
		etsBaseFunc:insertRecord(NewGuild#guildBaseInfo.memberTable, NewMember),
		mySqlProcess:insertGuildMemberGamedata(NewMember),
	
		FromPID ! { createGuildResult, GuildID, 0 },
		
		FromPID ! { updateGuildInfoToMap, GuildID, Msg#pk_U2GS_RequestCreateGuild.strGuildName, ?GuildRank_Chairman },

		
		%% 全服通告条件
		
		Str = io_lib:format(?TEXT_SYSTEM_SPECIAL_BROADCAST_CREATE_GUILD, [PlayerName, Msg#pk_U2GS_RequestCreateGuild.strGuildName]),
		systemMessage:sendSysMsgToAllPlayer(Str),
		

		
		?DEBUG_OUT( "Player[~p] create guild [~p] succ", [PlayerName, Msg#pk_U2GS_RequestCreateGuild.strGuildName] ),
		
		ok
	catch
		_->
			ok
	end.

%%玩家进程，仙盟创建结果
on_createGuildResult( GuildID, Result )->
	put( "player_create_guild_wait", 0 ),
	case Result >= 0 of
		true->
			player:setCurPlayerProperty( #player.guildID, GuildID ),
			player:send( #pk_GS2U_CreateGuildResult{result=0, guildID=GuildID} ),
			
			%%on_U2GS_GetMyGuildInfo(#pk_U2GS_GetMyGuildInfo{reserve=0}),
			
			%% 创建帮会成功，重置帮会任务
			task:resetReputationTaskEx(player:getCurPlayerProperty(#player.level));
		
			
		false->
			ParamTuple = #token_param{changetype = ?Money_Change_CreateGuild},
			playerMoney:addPlayerMoney( ?GuildCreate_Money, ?Money_Change_CreateGuild, ParamTuple),
			player:send( #pk_GS2U_CreateGuildResult{result=Result, guildID=0} )
	end.

%%玩家进程，客户端查询仙盟列表
on_U2GS_QueryGuildList( #pk_U2GS_QueryGuildList{}=Msg )->
	guildProcess_PID ! { msg_U2GS_QueryGuildList, self(), player:getCurPlayerID(), Msg }.
%%仙盟进程，客户端查询仙盟列表
on_msg_U2GS_QueryGuildList( _FromPID, PlayerID, #pk_U2GS_QueryGuildList{}=Msg )->
	try
		case Msg#pk_U2GS_QueryGuildList.bFirst =:= 1 of
			true->
				Q = ets:fun2ms( fun(#guildBaseInfo{}=Record)->Record end ),
		   		AllGuildList = ets:select(getGuildTable(), Q),
				ResultList = lists:map( fun(Record)->
												#pk_GS2U_GuildAllShortInfo{nGuildID=Record#guildBaseInfo.id,
																		   nChairmanPlayerID=Record#guildBaseInfo.chairmanPlayerID,
																		   strChairmanPlayerName=Record#guildBaseInfo.chairmanPlayerName,
																		   nLevel=Record#guildBaseInfo.level,
																		   nMemberCount=ets:info( Record#guildBaseInfo.memberTable, size),
																		   nFaction=Record#guildBaseInfo.faction,
																		   strGuildName=Record#guildBaseInfo.guildName
																		   }
										end,
										AllGuildList ),
				player:sendToPlayer(PlayerID, #pk_GS2U_GuildAllShortInfoList{info_list=ResultList}),
				ok;
			false->
				Q = ets:fun2ms( fun(#guildBaseInfo{}=Record)->Record end ),
		   		AllGuildList = ets:select(getGuildTable(), Q),
				ResultList = lists:map( fun(Record)->
												#pk_GS2U_GuildInfoSmall{nGuildID=Record#guildBaseInfo.id,
																		   nChairmanPlayerID=Record#guildBaseInfo.chairmanPlayerID,
																		   nLevel=Record#guildBaseInfo.level,
																		   nMemberCount=ets:info( Record#guildBaseInfo.memberTable, size)
																		   }
										end,
										AllGuildList ),
				player:sendToPlayer(PlayerID, #pk_GS2U_GuildInfoSmallList{info_list=ResultList}),
				ok
		end,

		ok
	catch
		_->ok
	end.

%%玩家进程，查询仙盟简略扩展信息
on_U2GS_QueryGuildShortInfoEx( #pk_U2GS_QueryGuildShortInfoEx{}=Msg )->
	guildProcess_PID ! { msg_U2GS_QueryGuildShortInfoEx, self(), player:getCurPlayerID(), Msg }.
%%仙盟进程，查询仙盟简略扩展信息	
on_msg_U2GS_QueryGuildShortInfoEx( _FromPID, PlayerID, #pk_U2GS_QueryGuildShortInfoEx{}=Msg )->
	put( "on_msg_U2GS_QueryGuildShortInfoEx_Result", [] ),
	lists:map( fun(GuildID)->
					GuildFind = etsBaseFunc:readRecord( getGuildTable(), GuildID ),
					case GuildFind of
						{}->ok;
						_->
							ToMsg = #pk_GS2U_GuildShortInfoEx{nGuildID=GuildFind#guildBaseInfo.id,
													   strChairmanPlayerName=GuildFind#guildBaseInfo.chairmanPlayerName,
													   nFaction=GuildFind#guildBaseInfo.faction,
													   strGuildName=GuildFind#guildBaseInfo.guildName
													   },
							put("on_msg_U2GS_QueryGuildShortInfoEx_Result", get( "on_msg_U2GS_QueryGuildShortInfoEx_Result" ) ++ [ToMsg] )
					end
			   end,
			   Msg#pk_U2GS_QueryGuildShortInfoEx.vGuilds ),
	player:sendToPlayer(PlayerID, #pk_GS2U_GuildShortInfoExList{info_list=get( "on_msg_U2GS_QueryGuildShortInfoEx_Result" )}).

%%玩家进程，查询自己仙盟的信息
on_U2GS_GetMyGuildInfo( #pk_U2GS_GetMyGuildInfo{}=_Msg )->
	guildProcess_PID ! { msg_U2GS_GetMyGuildInfo, self(), player:getCurPlayerID(), player:getCurPlayerProperty( #player.guildID ) }.
%%仙盟进程，查询自己仙盟的信息
on_msg_U2GS_GetMyGuildInfo( _FromPID, PlayerIDIn, GuildID )->
	Guild = etsBaseFunc:readRecord( getGuildTable(), GuildID ),
	case Guild of
		{}->ok;
		_->
			MsgGuildBase = #pk_GS2U_GuildBaseData{nGuildID=Guild#guildBaseInfo.id,
													nChairmanPlayerID=Guild#guildBaseInfo.chairmanPlayerID,
													strChairmanPlayerName=Guild#guildBaseInfo.chairmanPlayerName,
													nLevel=Guild#guildBaseInfo.level,
												  	memberCount=ets:info( Guild#guildBaseInfo.memberTable, size),
													nFaction=Guild#guildBaseInfo.faction,
													nExp=Guild#guildBaseInfo.exp,
													strAffiche=Guild#guildBaseInfo.affiche,
													strGuildName=Guild#guildBaseInfo.guildName
												},
			
			Q_Member = ets:fun2ms( fun(#guildMember{id='_',
											 guildID='_',
											 playerID=PlayerID,
											 playerName=PlayerName,
											 playerLevel=PlayerLevel,
											 rank=Rank,
											 playerClass=PlayerClass,
											 contribute=Contribute,
											 isOnline=IsOnline
											 }=_Record)->
									#pk_GS2U_GuildMemberData{
															 nPlayerID=PlayerID,
															 strPlayerName=PlayerName,
															 nPlayerLevel=PlayerLevel,
															 nRank=Rank,
															 nClass=PlayerClass,
															 nContribute=Contribute,
															 bOnline=IsOnline
															 }
							end ),
		   	MemberList = ets:select(Guild#guildBaseInfo.memberTable, Q_Member),
			
			Q_Applicant = ets:fun2ms( fun(#guildApplicant{id='_',
											 playerID=PlayerID_A,
											 playerName=PlayerName_A,
											 zhanli=Zhanli,
											 level=Level_A,
											 class=Class_A
											 }=_Record)->
									#pk_GS2U_GuildApplicantData{
															 nPlayerID=PlayerID_A,
															 strPlayerName=PlayerName_A,
															 nPlayerLevel=Level_A,
															 nClass=Class_A,
															 nZhanLi=Zhanli
															 }
							end ),
		   	ApplicantList = ets:select(Guild#guildBaseInfo.applicantTable, Q_Applicant),

			player:sendToPlayer(PlayerIDIn, #pk_GS2U_GuildFullInfo{stBase=MsgGuildBase,
																	member_list=MemberList,
																	applicant_list=ApplicantList}),
			ok
	end,
	ok.

%%玩家进程，查询仙盟申请成员列表实时信息
on_U2GS_GetMyGuildApplicantShortInfo( #pk_U2GS_GetMyGuildApplicantShortInfo{}=_Msg )->
	guildProcess_PID ! { msg_U2GS_GetMyGuildApplicantShortInfo, self(), player:getCurPlayerID(), player:getCurPlayerProperty( #player.guildID ) }.
%%仙盟进程，查询仙盟申请成员列表实时信息
on_msg_U2GS_GetMyGuildApplicantShortInfo( _FromPID, PlayerIDIn, GuildID )->
	Guild = etsBaseFunc:readRecord( getGuildTable(), GuildID ),
	case Guild of
		{}->ok;
		_->
			Q_Applicant = ets:fun2ms( fun(#guildApplicant{id='_',
											 playerID=PlayerID_A,
											 playerName='_',
											 zhanli=Zhanli,
											 level=Level_A
											 }=_Record)->
									#pk_GS2U_GuildApplicantShortData{
															 nPlayerID=PlayerID_A,
															 nPlayerLevel=Level_A,
															 nZhanLi=Zhanli
															 }
							end ),
		   	ApplicantList = ets:select(Guild#guildBaseInfo.applicantTable, Q_Applicant),

			player:sendToPlayer(PlayerIDIn, #pk_GS2U_GuildApplicantShortList{info_list=ApplicantList}),
			ok
	end,
	ok.

%%玩家进程，修改仙盟公告
on_U2GS_RequestChangeGuildAffiche( #pk_U2GS_RequestChangeGuildAffiche{}=Msg )->
	guildProcess_PID ! { msg_U2GS_RequestChangeGuildAffiche, player:getCurPlayerID(), player:getCurPlayerProperty( #player.guildID ), Msg }.
%%仙盟进程，修改仙盟公告	
on_msg_U2GS_RequestChangeGuildAffiche( PlayerID, GuildID, #pk_U2GS_RequestChangeGuildAffiche{strAffiche=SetAffiche}=_Msg )->
	try
		Guild = etsBaseFunc:readRecord( getGuildTable(), GuildID ),
		case Guild of
			{}->ok;
			_->
				AfficheLen = string:len( SetAffiche ),
				case AfficheLen > ?Max_GuildAffiche_CharCount of
					true->
						throw({tooLong});
					false->ok				
				end,
				case forbidden:checkForbidden(SetAffiche) of
					true->
						throw({forbiddenWord});
					false->ok				
				end,
				
				Member = etsBaseFunc:readRecord( Guild#guildBaseInfo.memberTable, PlayerID ),
				case Member of
					{}->throw({noMember});
					_->ok
				end,
				
				case ( Member#guildMember.rank =:= ?GuildRank_ViceChairman ) or ( Member#guildMember.rank =:= ?GuildRank_Chairman ) of
					true->ok;
					false->throw({noPermit})
				end,
				
				etsBaseFunc:changeFiled( getGuildTable(), GuildID, #guildBaseInfo.affiche, SetAffiche ),
				ToAll = #pk_GS2U_GuildAfficheChanged{strAffiche=SetAffiche},
				saveGuildInfo(GuildID),
				sendMsgToAllMember( Guild, ToAll )
		end
	catch
		{tooLong}->?MessageTips(PlayerID,?GUILD_STR_TOOLONG);
		{forbiddenWord}->?MessageTips(PlayerID,?GUILD_STR_FORBIDDENWORD);
		{noMember}->?MessageTips(PlayerID,?GUILD_STR_NOMEMBER);
		{noPermit}->?MessageTips(PlayerID,?GUILD_STR_NOPERMIT);
		_:Why->
			?LOG_OUT("on_msg_U2GS_RequestChangeGuildAffiche exception.Why:~p",Why)
	end.

%%玩家进程，贡献度捐献 %% 应策划要求去掉铜币的捐献 add by yueliangyou [2013-04-24]
on_U2GS_RequestGuildContribute( #pk_U2GS_RequestGuildContribute{nMoney=Money, nGold=Gold, nItemCount=ItemCount}=Msg )->
	try
		GuildID = player:getCurPlayerProperty( #player.guildID ),
		case GuildID > 0 of
			true->ok;
			false->
				?MessagePromptMe(?GUILD_STR_NOGUILD),
				throw(-1)
		end,

		case ( Gold > 0 ) of
			true->
				case playerMoney:canDecPlayerGold(Gold) of
					true->ok;
					false->
						?MessagePromptMe(?GUILD_STR_NOGOLD),
						throw(-1)
				end,
				ParamTuple2 = #token_param{changetype = ?Money_Change_GuildContribute},	
				playerMoney:decPlayerGold( Gold, ?Money_Change_GuildContribute, ParamTuple2 );
			false->ok
		end,
		
		case ItemCount > 0 of
			true->
				ResultList = playerItems:canDecItemInBag(?Item_Location_Bag, ?GuildContributeItemID, ItemCount, "all" ),
				case ResultList of
					[true|_]->put( "on_U2GS_RequestGuildContribute_DecItemList", ResultList );
					[false|_]->
						?MessagePromptMe(?GUILD_STR_NOITEM),
						throw(-1)
				end,
				[true|DecItemList] = get( "on_U2GS_RequestGuildContribute_DecItemList" ),
				playerItems:decItemInBag( DecItemList, ?Destroy_Item_Reson_GuildContribute );
			false->ok
		end,

		guildProcess_PID ! { msg_U2GS_RequestGuildContribute,player:getCurPlayerID(),GuildID,Msg },

		?DEBUG_OUT( "player[~p] ready to contribute guild[~p] Money[~p] Gold[~p] ItemCount[~p]",
					[player:getCurPlayerProperty( #player.name ),
					 GuildID,
					 Money, Gold, ItemCount] )
		
	catch
		-1->ok;
		_:Why->
			?LOG_OUT("on_U2GS_RequestGuildContribute exception.Why:~p",[Why])
	end.

%%仙盟进程，贡献度捐献
on_msg_U2GS_RequestGuildContribute( PlayerID, GuildID, #pk_U2GS_RequestGuildContribute{nMoney=Money, nGold=Gold, nItemCount=ItemCount}=_Msg )->
	try
		?DEBUG_OUT("on_msg_U2GS_RequestGuildContribute"),
		Guild = etsBaseFunc:readRecord( getGuildTable(), GuildID ),
		case Guild of
			{}->
				?MessageTips(PlayerID,?GUILD_STR_NOGUILD),
				throw(-1);
			_->ok
		end,
		
		%%成员信息记录
		MemberRecord = getGuildMemberRecord( GuildID, PlayerID ),
		case MemberRecord of
			{}->
				?MessageTips(PlayerID,?GUILD_STR_NOMEMBER),
				throw(-1);
			_->ok
		end,
		
		put( "GuildContributeExp", 0 ),
		put( "GuildContributeContribution", 0 ),
		put( "GuildContributeReputation", 0 ),

		case Gold > 0 of
			true->
				put("GuildContributeExp",get( "GuildContributeExp" )+?GuildContributeGoldConvertExp*Gold ),
				put("GuildContributeContribution",get("GuildContributeContribution") + ?GuildContributeGoldConvert*Gold ),
				put("GuildContributeReputation", get("GuildContributeReputation") + ?GuildContributeGoldConvertRep*Gold ),
				GoldString=integer_to_list(Gold) ++ ?GUILD_STR_GOLD;
			false->GoldString="",ok
		end,
		
		case ItemCount > 0 of
			true->
				put("GuildContributeExp",get( "GuildContributeExp" ) + ?GuildContributeStoneConvertExp*ItemCount),
				put("GuildContributeContribution",get("GuildContributeContribution" )+?GuildContributeItemConvert*ItemCount ),
				put("GuildContributeReputation", get("GuildContributeReputation" )+?GuildContributeItemConvertRep*ItemCount ),
				ItemString=integer_to_list(ItemCount) ++ ?GUILD_STR_ITEM;
			false->ItemString="",ok
		end,

		addGuildMemberContribution(Guild,PlayerID,get("GuildContributeContribution")),
		addGuildExp(GuildID,get("GuildContributeExp")),
		%% 增加玩家声望
		player:addPlayerCreditByID(PlayerID,get("GuildContributeReputation"),?Credit_Change_Contribute),
		
		?DEBUG_OUT( "Guild[~p] member[~p] contribute Money[~p] Gold[~p] ItemCount[~p] SetContribute[~p]",
					[Guild#guildBaseInfo.guildName,
					 MemberRecord#guildMember.playerName,
					 Money, Gold, ItemCount, getGuildMemberContribution(Guild,PlayerID)]),
		
		PlayerName = MemberRecord#guildMember.playerName,
		broadcastMessagePrompt(Guild,PlayerName ++ ?GUILD_STR_CONTRIBUTE0 ++ GoldString ++ ItemString ++ ?GUILD_STR_CONTRIBUTE1)
	catch
		-1->ok;
		_:Why->
			?LOG_OUT("on_msg_U2GS_RequestGuildContribute exception.Why:~p",[Why])
	end.

%%玩家进程，职位调整
on_U2GS_RequestGuildMemberRankChange( #pk_U2GS_RequestGuildMemberRankChange{}=Msg )->
	guildProcess_PID ! {msg_U2GS_RequestGuildMemberRankChange,player:getCurPlayerID(),player:getCurPlayerProperty(#player.guildID),Msg}.

%%仙盟进程，返回某仙盟成员某官职玩家ID列表
getGuildMemberRankPlayerIDList( Guild, Rank )->
	Q = ets:fun2ms( fun(#guildMember{id='_', playerID=PlayerID, rank=RankDB}=_Record) when RankDB=:=Rank ->PlayerID end ),
	PlayerIDList = ets:select(Guild#guildBaseInfo.memberTable, Q),
	PlayerIDList.

%%仙盟进程，职位调整
on_msg_U2GS_RequestGuildMemberRankChange(PlayerID,GuildID,#pk_U2GS_RequestGuildMemberRankChange{nPlayerID=TargetPlayerID,nRank=TargetRank}=_Msg)->
	try
		case PlayerID =:= TargetPlayerID of
			true->throw({samePlayer});
			false->ok
		end,

		%%仙盟记录
		Guild = etsBaseFunc:readRecord( getGuildTable(), GuildID ),
		case Guild of
			{}->throw({noGuild});
			_->ok
		end,
		
		%%仙盟当前等级信息记录
		GuildLevelCfg = etsBaseFunc:readRecord( ?GuildLevelCfgTableAtom, Guild#guildBaseInfo.level ),
		case GuildLevelCfg of
			{}->throw({noGuildLevelCfg});
			_->ok
		end,
		
		%%任命者成员信息记录
		MemberRecord = getGuildMemberRecord( GuildID, PlayerID ),
		case MemberRecord of
			{}->throw(noPlayer);
			_->ok
		end,

		%%目标玩家的成员信息记录
		TargetMemberRecord = getGuildMemberRecord( GuildID, TargetPlayerID ),
		case TargetMemberRecord of
			{}->throw({noTarget});
			_->ok
		end,

		%% 权限检查
		case MemberRecord#guildMember.rank < TargetMemberRecord#guildMember.rank of 
			true->throw({noPermit});
			false->ok
		end,

		%%权限及官职个数检查
		PlayerIDList = getGuildMemberRankPlayerIDList( Guild, TargetRank ),
		ExistRankCount = length( PlayerIDList ),
		case TargetRank of
			?GuildRank_Elder->
				RankName = "长老",
				%%只有盟主和副盟主可以任命
				case MemberRecord#guildMember.rank of
					?GuildRank_Chairman->ok; 
					?GuildRank_ViceChairman->ok;
					_->throw({noPermit})
				end,
				
				case ExistRankCount >= GuildLevelCfg#guildLevelCfg.elderCount of
					true->throw({rankLimit});
					false->ok
				end;
			?GuildRank_ViceChairman->
				RankName = "副盟主",
				%%只有盟主可以任命
				case MemberRecord#guildMember.rank =:= ?GuildRank_Chairman of
					false->throw({notChairman});
					true->ok
				end,

				%%任命为副盟主
				case ExistRankCount >= GuildLevelCfg#guildLevelCfg.elderCount of
					true->throw({rankLimit});
					false->ok
				end;
			?GuildRank_Chairman->
				RankName = "盟主",
				%%只有盟主可以任命
				case MemberRecord#guildMember.rank =:= ?GuildRank_Chairman of
					false->throw(-1);
					true->ok
				end;
			?GuildRank_Normal->
				RankName = "普通会员",
				%%副盟主不能任命盟主和副盟主为普通
				case MemberRecord#guildMember.rank of
					?GuildRank_Chairman->ok;
					?GuildRank_ViceChairman->
						case TargetMemberRecord#guildMember.rank of
							?GuildRank_Chairman->throw({noPermit});
							?GuildRank_ViceChairman->throw({noPermit});
							_->ok
						end;
					_->throw({noPermit})
				end
		end,
		
		%%检查完毕，执行操作
		case TargetRank of
			?GuildRank_Chairman->%%盟主移交要特别处理
				etsBaseFunc:changeFiled( getGuildTable(), GuildID, #guildBaseInfo.chairmanPlayerID,TargetPlayerID ),
				etsBaseFunc:changeFiled( getGuildTable(), GuildID, #guildBaseInfo.chairmanPlayerName,TargetMemberRecord#guildMember.playerName ),
				etsBaseFunc:changeFiled(Guild#guildBaseInfo.memberTable,TargetPlayerID,#guildMember.rank,?GuildRank_Chairman),
				etsBaseFunc:changeFiled(Guild#guildBaseInfo.memberTable,PlayerID,#guildMember.rank,?GuildRank_Normal),
				
				saveGuildInfo(GuildID),	
				saveGuildMemberInfo(GuildID,PlayerID),
				saveGuildMemberInfo(GuildID,TargetPlayerID),
			
				%% 盟主变为成员	
				ToMsg0 = #pk_GS2U_GuildMemberRankChanged{nPlayerID=PlayerID, nRank=?GuildRank_Normal},
				
				%%更新玩家的职位信息给地图进程
				case player:getPlayerPID(PlayerID) of
					0->ok;  %%玩家不在线，不需要更新
					PlayerPID->
						PlayerPID ! { updateGuildInfoToMap, GuildID, Guild#guildBaseInfo.guildName, ?GuildRank_Normal }
				end,
				
				sendMsgToAllMember(Guild, ToMsg0),
				
				?DEBUG_OUT( "Guild[~p] Chairman transfer to player[~p] by player[~p]", [Guild#guildBaseInfo.guildName, TargetMemberRecord#guildMember.playerName, MemberRecord#guildMember.playerName]);
			_->
				etsBaseFunc:changeFiled(Guild#guildBaseInfo.memberTable,TargetPlayerID,#guildMember.rank,TargetRank),
				saveGuildMemberInfo(GuildID,TargetPlayerID)
		end,
	
		ToMsg = #pk_GS2U_GuildMemberRankChanged{nPlayerID=TargetPlayerID, nRank=TargetRank},
		sendMsgToAllMember(Guild, ToMsg),

		TargetName = TargetMemberRecord#guildMember.playerName,
		PlayerName = MemberRecord#guildMember.playerName,
		broadcastMessagePrompt(Guild,PlayerName ++ ?GUILD_STR_ASSIGN0 ++ TargetName ++ ?GUILD_STR_ASSIGN1 ++ RankName ++ "'"),
		
		%%更新玩家的职位信息给地图进程
		case player:getPlayerPID(TargetPlayerID) of
			0->ok;  %%玩家不在线，不需要更新
			TargetPlayerPID->
				TargetPlayerPID ! { updateGuildInfoToMap, GuildID, Guild#guildBaseInfo.guildName, TargetRank }
		end,
		
		?DEBUG_OUT( "Guild[~p] member[~p] been set rank[~p] by player[~p]", [Guild#guildBaseInfo.guildName, TargetMemberRecord#guildMember.playerName, TargetRank, MemberRecord#guildMember.playerName] )
	catch
		{samePlayer}->?MessageTips(PlayerID,?GUILD_STR_ASSIGNSELF);
		{noGuild}->?MessageTips(PlayerID,?GUILD_STR_NOGUILD);
		{noGuildLevelCfg}->?MessageTips(PlayerID,?GUILD_STR_NOGUILD);
		{noPlayer}->?MessageTips(PlayerID,?GUILD_STR_NOMEMBER);
		{noTarget}->?MessageTips(PlayerID,?GUILD_STR_NOMEMBER);
		{noPermit}->?MessageTips(PlayerID,?GUILD_STR_NOPERMIT);
		{rankLimit}->?MessageTips(PlayerID,?GUILD_STR_RANKLIMIT);
		_:Why->
			?LOG_OUT("on_msg_U2GS_RequestGuildMemberRankChange exception.Why:~p",[Why])
	end.

%%仙盟进程，成员等级变化
on_guildMemberLevelChanged( PlayerID, GuildID, Level )->
	Guild = etsBaseFunc:readRecord( getGuildTable(), GuildID ),
	case Guild of
		{}->ok;
		_->
			MemberRecord = getGuildMemberRecord( GuildID, PlayerID ),
			case MemberRecord of
				{}->ok;
				_->
					etsBaseFunc:changeFiled( Guild#guildBaseInfo.memberTable, PlayerID, #guildMember.playerLevel, Level ),
					saveGuildMemberInfo(GuildID, PlayerID),
					ToMsg = #pk_GS2U_GuildMemberLevelChanged{nPlayerID=PlayerID, nLevel=Level},
					sendMsgToAllMember( Guild, ToMsg )
			end
	end.

%%玩家进程，踢成员
on_U2GS_RequestGuildKickOutMember( #pk_U2GS_RequestGuildKickOutMember{}=Msg)->
	guildProcess_PID ! { msg_U2GS_RequestGuildKickOutMember, self(), player:getCurPlayerID(), player:getCurPlayerProperty( #player.guildID ), Msg }.
%%仙盟进程，踢成员
on_msg_U2GS_RequestGuildKickOutMember( _FromPID, PlayerID, GuildID, #pk_U2GS_RequestGuildKickOutMember{nPlayerID=TargetPlayerID}=_Msg )->
	try
		case PlayerID =:= TargetPlayerID of
			true->throw({samePlayer});
			false->ok
		end,

		%%仙盟记录
		Guild = etsBaseFunc:readRecord( getGuildTable(), GuildID ),
		case Guild of
			{}->throw({noGuild});
			_->ok
		end,
		
		%%任命者成员信息记录
		MemberRecord = getGuildMemberRecord( GuildID, PlayerID ),
		case MemberRecord of
			{}->throw({noPlayer});
			_->ok
		end,

		%%目标玩家的成员信息记录
		TargetMemberRecord = getGuildMemberRecord( GuildID, TargetPlayerID ),
		case TargetMemberRecord of
			{}->throw({noTarget});
			_->ok
		end,
		
		case MemberRecord#guildMember.rank of
			?GuildRank_Chairman->ok;
			?GuildRank_ViceChairman->
				case TargetMemberRecord#guildMember.rank of
					?GuildRank_Normal->ok;
					_->throw({noPermit})
				end;
			_->throw({noPermit})
		end,

		ToMsg = #pk_GS2U_GuildMemberQuit{nPlayerID=TargetPlayerID, bKickOut=1},
		sendMsgToAllMember( Guild, ToMsg ),

		TargetName = TargetMemberRecord#guildMember.playerName,
		PlayerName = MemberRecord#guildMember.playerName,
		broadcastMessagePrompt(Guild,TargetName ++ ?GUILD_STR_TICK0 ++ PlayerName ++ ?GUILD_STR_TICK1),

		etsBaseFunc:deleteRecord(Guild#guildBaseInfo.memberTable,TargetPlayerID),
		mySqlProcess:deleteGuildMemberGamedata(TargetMemberRecord#guildMember.id),
		
		%dbProcess_PID ! { kickoutPlayer, self(), PlayerID, GuildID, TargetPlayerID},
		{PlayerID, Result, TargetPlayerID, GuildID} = 
			dbProcess:on_kickoutPlayer(PlayerID, GuildID, TargetPlayerID),
		on_kickoutPlayerResult(PlayerID, Result, TargetPlayerID, GuildID),

%% 		case player:getPlayerIsOnlineByID(TargetPlayerID) of
%% 			true->
%% 				player:getPlayerPID(TargetPlayerID) ! { setPlayerGuildID, 0 };
%% 			false->
%% 				db:changeFiled(player, TargetPlayerID, #player.guildID, 0)
%% 		end,
%% 		FromPID ! { setPlayerGuildID, 0 },

		?DEBUG_OUT( "guild[~p] member[~p] been kickout by player[~p]", [Guild#guildBaseInfo.guildName, TargetMemberRecord#guildMember.playerName, MemberRecord#guildMember.playerName] ),
		
		ok
	catch
		{samePlayer}->?MessageTips(PlayerID,?GUILD_STR_TICKSELF);
		{noGuild}->?MessageTips(PlayerID,?GUILD_STR_NOGUILD);
		{noPlayer}->?MessageTips(PlayerID,?GUILD_STR_NOMEMBER);
		{noTarget}->?MessageTips(PlayerID,?GUILD_STR_NOMEMBER);
		_->ok
	end.

%%踢成员数据库返回结果
on_kickoutPlayerResult(_PlayerID, Result, TargetPlayerID, GuildID)->
	try
		case Result of
			noPlayer->ok;
			notGuildMember->ok;
			ok->
				Guild = etsBaseFunc:readRecord(getGuildTable(), GuildID),
				case Guild of
					{}->throw(-1);
					_->ok
				end,
				
				case player:getPlayerIsOnlineByID(TargetPlayerID) of
					false->
						ok;
					true->
						player:sendMsgToPlayerProcess(TargetPlayerID,{setPlayerGuildID,0}),
						player:sendMsgToPlayerProcess(TargetPlayerID,{ updateGuildInfoToMap, 0, [], 0 })
				end;
			_->
				ok
		end
	catch
		_->ok
	end.

%%玩家进程，退出
on_U2GS_RequestGuildQuit( #pk_U2GS_RequestGuildQuit{}=_Msg )->
	guildProcess_PID ! { msg_U2GS_RequestGuildQuit, self(), player:getCurPlayerID(), player:getCurPlayerProperty( #player.guildID ) }.	
%%仙盟进程，退出
on_msg_U2GS_RequestGuildQuit( FromPID, PlayerID, GuildID )->
	try
		%%仙盟记录
		Guild = etsBaseFunc:readRecord( getGuildTable(), GuildID ),
		case Guild of
			{}->throw({noGuild});
			_->ok
		end,
		
		%%成员信息记录
		MemberRecord = getGuildMemberRecord( GuildID, PlayerID ),
		case MemberRecord of
			{}->throw({noPlayer});
			_->ok
		end,
		
		case MemberRecord#guildMember.rank of
			%%盟主退出，要移交或解散
			?GuildRank_Chairman->
				case ets:info(Guild#guildBaseInfo.memberTable,size) > 1 of
					true->
						NewChairman = getGuildMemberMaxContribute(Guild#guildBaseInfo.memberTable,PlayerID),
						case NewChairman of
							{}->throw(noNewChairman);
							_->
								etsBaseFunc:changeFiled(getGuildTable(), GuildID, #guildBaseInfo.chairmanPlayerID, NewChairman#guildMember.playerID ),
								etsBaseFunc:changeFiled(getGuildTable(), GuildID, #guildBaseInfo.chairmanPlayerName, NewChairman#guildMember.playerName ),
								etsBaseFunc:changeFiled(Guild#guildBaseInfo.memberTable, NewChairman#guildMember.playerID, #guildMember.rank, ?GuildRank_Chairman ),
								
								etsBaseFunc:deleteRecord( Guild#guildBaseInfo.memberTable, PlayerID ),
								%db:delete( guildMember, PlayerID ),
								mySqlProcess:deleteGuildMemberGamedata(MemberRecord#guildMember.id),
								
								case FromPID =:= 0 of
									true->ok;
									false->FromPID ! { setPlayerGuildID, 0 }
								end,
								
								ToMsg = #pk_GS2U_GuildMemberQuit{nPlayerID=PlayerID, bKickOut=0},
								sendMsgToAllMember( Guild, ToMsg ),

								PlayerName = MemberRecord#guildMember.playerName,
								ChairmanName = NewChairman#guildMember.playerName,
								broadcastMessagePrompt(Guild,"盟主 " ++ PlayerName ++ " 退出了仙盟，并由 " ++ ChairmanName ++ "接任盟主之位"),
								
								?DEBUG_OUT( "guild[~p] quit player[~p] transfer chairman to player[~p]",
											[Guild#guildBaseInfo.guildName,
											 MemberRecord#guildMember.playerName,
											 NewChairman#guildMember.playerName] )
						end,
						ok;
					false->%%解散
						PlayerName = MemberRecord#guildMember.playerName,
						broadcastMessagePrompt(Guild,PlayerName ++ " 解散了仙盟"),
						on_DisbandGuild( GuildID ),
						case FromPID =:= 0 of
							true->ok;
							false->FromPID ! { setPlayerGuildID, 0 }
						end,
						?DEBUG_OUT( "guild[~p] player[~p] quit to disband", [Guild#guildBaseInfo.guildName,MemberRecord#guildMember.playerName] ),
						ok
				end,
				ok;
			_->
				ToMsg = #pk_GS2U_GuildMemberQuit{nPlayerID=PlayerID, bKickOut=0},
				sendMsgToAllMember( Guild, ToMsg ),
				
				PlayerName = MemberRecord#guildMember.playerName,
				broadcastMessagePrompt(Guild,PlayerName ++ ?GUILD_STR_QUIT),

				etsBaseFunc:deleteRecord( Guild#guildBaseInfo.memberTable, PlayerID ),
				%db:delete( guildMember, PlayerID ),
				mySqlProcess:deleteGuildMemberGamedata(MemberRecord#guildMember.id),
								
				case FromPID =:= 0 of
					true->ok;
					false->
						FromPID ! { setPlayerGuildID, 0 },
						FromPID ! { updateGuildInfoToMap, 0, [], 0 }
				end,
				
				
				
				?DEBUG_OUT( "guild[~p] player[~p] quited", [Guild#guildBaseInfo.guildName,MemberRecord#guildMember.playerName] )
		end,

		ok
	catch
		_->ok
	end.

%%仙盟进程，返回仙盟中贡献度最高的成员记录
getGuildMemberMaxContribute( MemberTable, ExecptPlayerID )->
	put( "getGuildMemberMaxContribute_MaxContribute", 0 ),
	put( "getGuildMemberMaxContribute_Return", {} ),
	MyFunc = fun( Record )->
					 case Record#guildMember.playerID =:= ExecptPlayerID of
						 true->ok;
						 _->
							 case Record#guildMember.contribute >= get( "getGuildMemberMaxContribute_MaxContribute" ) of
								 true->
									 put("getGuildMemberMaxContribute_MaxContribute", Record#guildMember.contribute ),
									 put("getGuildMemberMaxContribute_Return", Record);
								 false->ok
							 end
					 end
			 end,
	etsBaseFunc:etsFor( MemberTable, MyFunc ),
	get( "getGuildMemberMaxContribute_Return" ).

%%仙盟进程，解散
on_DisbandGuild( GuildID )->
	%%仙盟记录
	Guild = etsBaseFunc:readRecord( getGuildTable(), GuildID ),
	case Guild of
		{}->ok;
		_->
			MemberFun = fun( Record )->
							%db:delete( guildMember, Record#guildMember.playerID )	
							mySqlProcess:deleteGuildMemberGamedata(Record#guildMember.id)
						end,
			etsBaseFunc:etsFor( Guild#guildBaseInfo.memberTable, MemberFun ),
			ets:delete( Guild#guildBaseInfo.memberTable ),

			ApplicantFun = fun( Record )->
							%db:delete( guildApplicant, Record#guildApplicant.playerID )
							mySqlProcess:deleteGuildApplicant(Record#guildApplicant.id)	
						end,
			etsBaseFunc:etsFor( Guild#guildBaseInfo.applicantTable, ApplicantFun ),
			ets:delete( Guild#guildBaseInfo.applicantTable ),
			
			mySqlProcess:deleteRecordByTableNameAndId("guildbaseinfo_gamedata",Guild#guildBaseInfo.id),
			etsBaseFunc:deleteRecord(getGuildTable(),Guild#guildBaseInfo.id),

			ok
	end.
	
%%玩家进程，申请入盟
on_U2GS_RequestJoinGuld( #pk_U2GS_RequestJoinGuld{nGuildID=GuildID}=_Msg )->
	try
		case get( "on_U2GS_RequestJoinGuld_WaitResult" ) of
			1->throw({waitResult});
			_->ok
		end,

		case player:getCurPlayerProperty( #player.guildID ) =:= 0 of
			true->ok;
			false->throw({isGuildMember})
		end,
		
		?DEBUG_OUT("JoinGold fightingCapacity:~p",[player:getCurPlayerProperty( #player.fightingCapacity )]),
		
		guildProcess_PID ! { msg_U2GS_RequestJoinGuld, 
							 self(), 
							 player:getCurPlayerID(), 
							 player:getCurPlayerProperty( #player.name ),
							 player:getCurPlayerProperty( #player.fightingCapacity ),
							 player:getCurPlayerProperty( #player.level ),
							 player:getCurPlayerProperty( #player.camp ),
							 player:getCurPlayerProperty( #player.faction ),
							  GuildID },
	
		put("on_U2GS_RequestJoinGuld_WaitResult",1)
	catch
		{waitResult}->?MessageBoxMe(?GUILD_STR_WAIT);
		{isGuildMember}->?MessageBoxMe(?GUILD_STR_ISGUILDMEMBER);
		_:Why->
			?LOG_OUT("on_U2GS_RequestJoinGuild exception.Why:~p",[Why])
	end.
	
%%仙盟进程，申请入盟
on_msg_U2GS_RequestJoinGuld( FromPID, PlayerID, PlayerName, ZhanLi, Level, Class, Faction, GuildID )->
	try
		put( "player_Apply_Result", ?Guild_ApplyResult_Success),
		%%仙盟记录
		Guild = etsBaseFunc:readRecord( getGuildTable(), GuildID ),
		case Guild of
			{}->put( "player_Apply_Result", ?Guild_ApplyResult_NoExist), throw(-1);
			_->ok
		end,
		
		%%玩家是否相同阵营
		case Guild#guildBaseInfo.faction =:= Faction of
			true->ok;
			false->put( "player_Apply_Result", ?Guild_ApplyResult_DiffCamp), throw(-1)
		end,
		
		%%成员信息记录
		MemberRecord = getGuildMemberRecord( GuildID, PlayerID ),
		case MemberRecord of
			{}->ok;
			_->put( "player_Apply_Result", ?Guild_ApplyResult_AlreadyAMember), throw(-1)
		end,
		
		%%申请成员记录
		ApplicantRecord = getGuildApplicatnRecord( GuildID, PlayerID ),
		case ApplicantRecord of
			{}->ok;
			_->put( "player_Apply_Result", ?Guild_ApplyResult_AlreadyApply), throw(-1)
		end,
		
		ApplicantCount = ets:info( Guild#guildBaseInfo.applicantTable, size ),
		case ApplicantCount >= ?Max_GuildApplicantCount of
			true->put( "player_Apply_Result", ?Guild_ApplyResult_MaxApplyCount), throw(-1);
			false->ok
		end,
		
		%% 最大人数限制 add by yueliangyou [2013-04-22]	
		CurGuildCfg = etsBaseFunc:readRecord(main:getGuildLevelCfgTable(), Guild#guildBaseInfo.level),
		MemberCount=ets:info(Guild#guildBaseInfo.memberTable, size),
		MaxMemberCount = CurGuildCfg#guildLevelCfg.maxMember,
		%MaxMemberCount = 1,
		case MemberCount < MaxMemberCount of
			true->ok;
			false->put( "player_Apply_Result", ?Guild_ApplyResult_MaxCount), throw(-1)
		end,

		NewApplicantRecord = #guildApplicant{ id=db:memKeyIndex(guildapplicant), % persistent
											  guildID = GuildID,
											  playerID=PlayerID, 
											  playerName = PlayerName,
											  zhanli = ZhanLi,
											  level = Level,
											  class = Class,
											  joinTime = common:timestamp()
											  },
		etsBaseFunc:insertRecord( Guild#guildBaseInfo.applicantTable, NewApplicantRecord ),
		mySqlProcess:insertGuildApplicant(NewApplicantRecord),

		%% 如果帮主在线，要通知帮主
		case player:getPlayerIsOnlineByID(Guild#guildBaseInfo.chairmanPlayerID) of
					false->
						ok;
					true->
						?MessagePrompt(Guild#guildBaseInfo.chairmanPlayerID,PlayerName ++ ?GUILD_STR_APPLY)
		end,
		
		FromPID ! { guild_U2GS_RequestJoinGuld_Result, 0, PlayerID }
	catch
		_->
			Result = get( "player_Apply_Result" ),
			case Result of
				0->
					ok;
				_->
					FromPID ! { guild_U2GS_RequestJoinGuld_Result, Result, PlayerID}
			end
	end.

%%玩家进程，处理仙盟进程回复申请结果
on_guild_U2GS_RequestJoinGuld_Result(Result,PlayerID )->
	put( "on_U2GS_RequestJoinGuld_WaitResult", 0 ),
	case Result of
		0->?MessageTips(PlayerID,?GUILD_STR_APPLYSUC);
		?Guild_ApplyResult_AlreadyAMember->?MessageTips(PlayerID,?GUILD_STR_ISGUILDMEMBER);
		?Guild_ApplyResult_DiffCamp->?MessageTips(PlayerID,?GUILD_STR_DIFFCAMP);
		?Guild_ApplyResult_NoExist->?MessageTips(PlayerID,?GUILD_STR_GUILDNOTFOUND);
		?Guild_ApplyResult_AlreadyApply->?MessageTips(PlayerID,?GUILD_STR_ALREADYAPPLY);
		?Guild_ApplyResult_MaxApplyCount->?MessageTips(PlayerID,?GUILD_STR_TOOMANYAPPLY);
		?Guild_ApplyResult_MaxCount->?MessageTips(PlayerID,?GUILD_STR_MEMBERLIMIT)
	end.

%%玩家进程，批准申请者入盟
on_U2GS_RequestGuildApplicantAllow( #pk_U2GS_RequestGuildApplicantAllow{nPlayerID=TargetPlayerID}=_Msg )->
	try
		case player:getCurPlayerProperty( #player.guildID ) =:= 0 of
			true->throw({noGuild});
			false->ok
		end,
		
		guildProcess_PID ! { msg_U2GS_RequestGuildApplicantAllow, self(), player:getCurPlayerID(), player:getCurPlayerProperty( #player.guildID ), TargetPlayerID, true }
	catch
		{waitResult}->?MessageBoxMe(?GUILD_STR_WAIT);
		{noGuild}->?MessageBoxMe(?GUILD_STR_NOGUILD);
		_:Why->
			?LOG_OUT("on_U2GS_RequestGuildApplicantAllow exception.Why:~p",[Why])
	end.

%%仙盟进程，批准申请者入盟
on_msg_U2GS_RequestGuildApplicantAllow( _FromPID, PlayerID, GuildID, TargetPlayerID, IsSingleProcess )->
	try
		%%仙盟记录
		Guild = etsBaseFunc:readRecord( getGuildTable(), GuildID ),
		case Guild of
			{}->throw({noGuildRecord});
			_->ok
		end,

		%%成员信息记录
		MemberRecord = getGuildMemberRecord( GuildID, PlayerID ),
		case MemberRecord of
			{}->throw({noMemberRecord});
			_->ok
		end,
		
		%%申请成员记录
		ApplicantRecord = getGuildApplicatnRecord( GuildID, TargetPlayerID ),
		case ApplicantRecord of
			{}->throw({noApplyRecord});
			_->ok
		end,
	
		%% 最大人数限制 add by yueliangyou [2013-04-22]	
		CurGuildCfg = etsBaseFunc:readRecord(main:getGuildLevelCfgTable(), Guild#guildBaseInfo.level),
		MemberCount=ets:info(Guild#guildBaseInfo.memberTable, size),
		MaxMemberCount = CurGuildCfg#guildLevelCfg.maxMember,
		%MaxMemberCount = 3,
		case MemberCount < MaxMemberCount of
			true->ok;
			false->throw({maxMemberLimit})
		end,
		
		%% modify for insert mysql directly
		%dbProcess_PID ! { checkPlayerGuildID, self(), PlayerID, GuildID, TargetPlayerID, IsSingleProcess},
		{PlayerID, Result, TargetPlayerID, GuildID, IsSingleProcess} = 
			dbProcess:on_checkPlayerGuildID( PlayerID, GuildID, TargetPlayerID, IsSingleProcess),
		on_checkPlayerGuildIDResult(PlayerID, Result, TargetPlayerID, GuildID, IsSingleProcess )

	catch
		{noGuildRecord}->?MessageTips(PlayerID,?GUILD_STR_GUILDNOTFOUND);
		{noMemberRecord}->?MessageTips(PlayerID,?GUILD_STR_NOMEMBER);
		{noApplyRecord}->?MessageTips(PlayerID,?GUILD_STR_NOAPPLY);
		{maxMemberLimit}->?MessageTips(PlayerID,?GUILD_STR_TOOMANYMEMBER);
		_:_Why->ok
			%FromPID ! { guild_U2GS_RequestGuildApplicantAllow_Result, -1, GuildID }
	end.

%%仙盟进程，批准加入仙盟的结果
on_checkPlayerGuildIDResult(PlayerID, Result, TargetPlayerID, GuildID, IsSingleProcess )->
	try
		%ApplyRecord = etsBaseFunc:readRecord(Guild#guildBaseInfo.applicantTable, TargetPlayerID),
		%etsBaseFunc:deleteRecord(Guild#guildBaseInfo.applicantTable, TargetPlayerID),
		%mySqlProcess:deleteGuildApplicant(ApplyRecord#guildApplicant.id),
		case Result of
			noPlayer->?MessageTips(PlayerID,?GUILD_STR_NOPLAYER);
			isGuildMember->?MessageTips(PlayerID,?GUILD_STR_OTHERGUILDMEMBER);
			ok->
				Guild = etsBaseFunc:readRecord(getGuildTable(), GuildID),
				case Guild of
					{}->throw(-1);
					_->ok
				end,
				
				ApplyRecord = etsBaseFunc:readRecord(Guild#guildBaseInfo.applicantTable, TargetPlayerID),
				case ApplyRecord of
					{}->
						throw(-1);
					_->ok
				end,
				
				case player:getPlayerIsOnlineByID(TargetPlayerID) of
					false->
						TargetPlayerIsOnline = 0;
					true->
						TargetPlayerIsOnline = 1
				end,
				NewMember = #guildMember{ id=db:memKeyIndex(guildmember_gamedata), % persistent
								  guildID=GuildID,
								  playerID=TargetPlayerID,
								  rank=?GuildRank_Normal,
								  playerName=ApplyRecord#guildApplicant.playerName,
								  playerLevel=ApplyRecord#guildApplicant.level,
								  playerClass=ApplyRecord#guildApplicant.class,
								  isOnline=TargetPlayerIsOnline,
								  contribute=0,
								  contributeMoney=0,
								  contributeTime=0,
								  joinTime=common:timestamp() },
				
				NewMemberData = #pk_GS2U_GuildMemberData{
															 nPlayerID=TargetPlayerID,
															 strPlayerName=ApplyRecord#guildApplicant.playerName,
															 nPlayerLevel=ApplyRecord#guildApplicant.level,
															 nRank=?GuildRank_Normal,
															 nClass=ApplyRecord#guildApplicant.class,
															 nContribute=0,
															 bOnline=TargetPlayerIsOnline
															 },
				
				ToMsg = #pk_GS2U_GuildMemberAdd{stData=NewMemberData},
				sendMsgToAllMember( Guild, ToMsg ),
		
				etsBaseFunc:insertRecord(Guild#guildBaseInfo.memberTable, NewMember),
				mySqlProcess:insertGuildMemberGamedata(NewMember),
				
				ApplyRecord = etsBaseFunc:readRecord(Guild#guildBaseInfo.applicantTable, TargetPlayerID),
				etsBaseFunc:deleteRecord(Guild#guildBaseInfo.applicantTable, TargetPlayerID),
				mySqlProcess:deleteGuildApplicant(ApplyRecord#guildApplicant.id),
				
				PlayerName = Guild#guildBaseInfo.chairmanPlayerName,
				TargetName = ApplyRecord#guildApplicant.playerName,
				broadcastMessagePrompt(Guild,PlayerName ++ ?GUILD_STR_ALLOW0 ++ TargetName ++ ?GUILD_STR_ALLOW1),

				case player:getPlayerIsOnlineByID(PlayerID) of
					false->
						ok;
					true->
						player:sendMsgToPlayerProcess(PlayerID, { msg_applicantAllowComplete, TargetPlayerID }),
						case IsSingleProcess of
							true->
								ok;
							false->
								on_msg_U2GS_RequestGuildApplicantOPAll( player:getPlayerPID(PlayerID), PlayerID, GuildID, 0 )
						end
				end,
				case player:getPlayerIsOnlineByID(TargetPlayerID) of
					false->
						ok;
					true->
						player:sendMsgToPlayerProcess(TargetPlayerID, {msg_guildInformPlayerResult, GuildID, Guild#guildBaseInfo.guildName}),
						player:sendMsgToPlayerProcess(TargetPlayerID, {updateGuildInfoToMap, GuildID, Guild#guildBaseInfo.guildName, ?GuildRank_Normal})
				end;
			_->
				ok
		end
	catch
		_->ok
	end.

%%玩家进程，拒绝申请者入盟
on_U2GS_RequestGuildApplicantRefuse( #pk_U2GS_RequestGuildApplicantRefuse{nPlayerID=TargetPlayerID}=_Msg )->
	try
		case player:getCurPlayerProperty( #player.guildID ) =:= 0 of
			true->throw(-1);
			false->ok
		end,
		
		guildProcess_PID ! { msg_U2GS_RequestGuildApplicantRefuse, self(), player:getCurPlayerID(), player:getCurPlayerProperty( #player.guildID ), TargetPlayerID }
	catch
		_:_->ok
	end.

%%仙盟进程，拒绝申请者入盟
on_msg_U2GS_RequestGuildApplicantRefuse(_FromPID, PlayerID, GuildID, TargetPlayerID)->
		try
		%%仙盟记录
		Guild = etsBaseFunc:readRecord( getGuildTable(), GuildID ),
		case Guild of
			{}->throw(-1);
			_->ok
		end,
		
		%%成员信息记录
		MemberRecord = getGuildMemberRecord( GuildID, PlayerID ),
		case MemberRecord of
			{}->throw(-1);
			_->ok
		end,
		
		%%申请成员记录
		ApplicantRecord = getGuildApplicatnRecord( GuildID, TargetPlayerID ),
		case ApplicantRecord of
			{}->throw(-1);
			_->ok
		end,
		
		ApplyRecord = etsBaseFunc:readRecord(Guild#guildBaseInfo.applicantTable, TargetPlayerID),
		etsBaseFunc:deleteRecord(Guild#guildBaseInfo.applicantTable, TargetPlayerID),
		%db:delete(guildApplicant, ApplyRecord#guildApplicant.id),
		mySqlProcess:deleteGuildApplicant(ApplyRecord#guildApplicant.id),

		?MessagePrompt(TargetPlayerID,MemberRecord#guildMember.playerName ++ ?GUILD_STR_REFUSE),
		
%% 		dbProcess_PID ! { checkPlayerGuildID, self(), PlayerID, GuildID, TargetPlayerID},
		
		ok
	catch
		_->
			ok
			%FromPID ! { guild_U2GS_RequestGuildApplicantAllow_Result, -1, GuildID }
	end.

%%玩家进程，批量处理请求列表
on_U2GS_RequestGuildApplicantOPAll(#pk_U2GS_RequestGuildApplicantOPAll{nAllowOrRefuse=Flag}=_Msg)->
	try
		case player:getCurPlayerProperty(#player.guildID) =:= 0 of
			true->
				throw(-1);
			false->
				ok
		end,
		
		
		guildProcess_PID ! { msg_U2GS_RequestGuildApplicantOPAll, self(), player:getCurPlayerID(), player:getCurPlayerProperty( #player.guildID ), Flag }
	catch
		_->ok
	end.
%%仙盟进程，批量处理请求列表
on_msg_U2GS_RequestGuildApplicantOPAll( FromPID, PlayerID, GuildID, Flag )->
	try
		%%仙盟记录
		Guild = etsBaseFunc:readRecord( getGuildTable(), GuildID ),
		case Guild of
			{}->throw(-1);
			_->ok
		end,
		
		%%成员信息记录
		MemberRecord = getGuildMemberRecord( GuildID, PlayerID ),
		case MemberRecord of
			{}->throw(-1);
			_->ok
		end,
		
		%%判断成员是否有操作的权利
		case MemberRecord#guildMember.rank of
			_->ok
		end,
		
		Rule = ets:fun2ms(fun(#guildApplicant{}=Record)->Record end),
		ApplicantList = ets:select(Guild#guildBaseInfo.applicantTable, Rule),
		case Flag of
			0->
				case ApplicantList of
					[]->
						ok;
					[Applicant|_]->
						on_msg_U2GS_RequestGuildApplicantAllow( FromPID, PlayerID, GuildID, Applicant#guildApplicant.playerID, false )
				end;
			1->
				lists:map(fun(ApplicantRecord) -> on_msg_U2GS_RequestGuildApplicantRefuse(FromPID, PlayerID, GuildID, ApplicantRecord#guildApplicant.playerID) end, ApplicantList)
		end,
		
		ok
	catch
		_->ok
	end.




%% -------------------------------------------------------------------
%% --------------add by yueliangyou [2013-04-23]---------------
%% -------------------------------------------------------------------
%% 获取帮派属性
getGuildProperty(GuildID,Index)->
	etsBaseFunc:getRecordField(getGuildTable(),GuildID,Index).

%% 更改帮派属性
setGuildProperty(GuildID,Index,Value)->
	etsBaseFunc:changeFiled(getGuildTable(),GuildID,Index,Value),
	saveGuildInfo(GuildID).

%% 获取帮派成员属性
getGuildMemberProperty(Guild,PlayerID,Index)->
	etsBaseFunc:getRecordField(Guild#guildBaseInfo.memberTable,PlayerID,Index).

%% 更改帮派成员属性
setGuildMemberProperty(Guild,PlayerID,Index,Value)->
	etsBaseFunc:changeFiled(Guild#guildBaseInfo.memberTable,PlayerID,Index,Value),
	saveGuildMemberInfoEx(Guild,PlayerID).

%% 获取帮派成员属性
getGuildMemberPropertyByGuildID(GuildID,PlayerID,Index)->
	Guild = getGuildBaseRecord(GuildID),
	case Guild of
		{}->{};
		_->
			etsBaseFunc:getRecordField(Guild#guildBaseInfo.memberTable,PlayerID,Index)
	end.

%% 更改帮派成员属性
setGuildMemberPropertyByGuildID(GuildID,PlayerID,Index,Value)->
	Guild = getGuildBaseRecord(GuildID),
	case Guild of
		{}->ok;
		_->
			etsBaseFunc:changeFiled(Guild#guildBaseInfo.memberTable,PlayerID,Index,Value),
			saveGuildMemberInfoEx(Guild,PlayerID)
	end.

getGuildExp(GuildID)->
	getGuildProperty(GuildID,#guildBaseInfo.exp).

getGuildLevel(GuildID)->
	getGuildProperty(GuildID,#guildBaseInfo.level).

%% 增加帮会经验
addGuildExp(GuildID,ExpVar)->
	?DEBUG_OUT("addGuildExp ready ..."),
	try
	case ExpVar > 0 of 
		true->ok;
		false->throw({invalidExpVar})
	end,

	Guild = getGuildBaseRecord(GuildID),
	case Guild of
		{}->throw({noGuild});
		_->ok
	end,

	Level = Guild#guildBaseInfo.level,
	GuildLevel = getGuildLevelRecord(Level),
	case GuildLevel of 
		{}->throw({noGuildLevelConfig});
		_->ok
	end,

	case Level >= ?Max_GuildLevel of 
		true->throw({maxLevel});
		false->ok
	end,

	ExpOld = Guild#guildBaseInfo.exp,
	ExpNew = Guild#guildBaseInfo.exp+ExpVar,
	ExpLevel = GuildLevel#guildLevelCfg.exp,
	case ExpNew >= ExpLevel of 
		true->
			setGuildProperty(GuildID,#guildBaseInfo.level,Level+1),
			setGuildProperty(GuildID,#guildBaseInfo.exp,0),
			LevelNew = getGuildLevel(GuildID),
			broadcastMessagePrompt(Guild,?GUILD_STR_LEVEL0 ++ integer_to_list(LevelNew) ++ ?GUILD_STR_LEVEL1),
			sendMsgToAllMember(Guild,#pk_GS2U_GuildLevelEXPChanged{ nLevel=LevelNew,nEXP=0}),
			sendMsgToAllOnLineMemberProcess(Guild,{guildLevelChanged,GuildID,LevelNew}),
		
			case LevelNew =:= ?Max_GuildLevel of
				true->ok;
				false->
					addGuildExp(GuildID,ExpNew-ExpLevel)
			end;
		false-> 
			setGuildProperty(GuildID,#guildBaseInfo.exp,ExpNew),
			sendMsgToAllMember(Guild,#pk_GS2U_GuildLevelEXPChanged{ nLevel=Guild#guildBaseInfo.level, nEXP=ExpNew })
	end,

	?DEBUG_OUT("addGuildExp ok. ExpOld:~p,ExpVar:~p,ExpLevel:~p,ExpNew:~p",[ExpOld,ExpVar,ExpLevel,getGuildExp(GuildID)])

	catch
		{maxLevel}->ok;
		{invalidExpVar}->ok;
		_:Why->
			?LOG_OUT("addGuildExp exception. Why:~p",[Why])
	end.

%% 获得帮会成员贡献度
getGuildMemberContribution(Guild,PlayerID)->
	getGuildMemberProperty(Guild,PlayerID,#guildMember.contribute).

%% 增加帮会成员贡献度
addGuildMemberContribution(Guild,PlayerID,ConVar)->
	ValueNew = ConVar+getGuildMemberProperty(Guild,PlayerID,#guildMember.contribute),
	setGuildMemberProperty(Guild,PlayerID,#guildMember.contribute,ValueNew),
	ToMsg = #pk_GS2U_GuildMemberContributeChanged{nContribute=ValueNew, nPlayerID=PlayerID},
	sendMsgToAllMember(Guild,ToMsg ).

%% 增加帮会成员贡献度
addGuildMemberContributionByID(GuildID,PlayerID,ConVar)->
	Guild = getGuildBaseRecord(GuildID),
	case Guild of
		{}->{};
		_->
			addGuildMemberContribution(Guild,PlayerID,ConVar)
	end.

%% 广播提示信息
broadcastMessagePrompt(Guild,Message)->
	sendMsgToAllMember(Guild,#pk_SysMessage{type=?SYSTEM_MESSAGE_PROMPT,text = Message}).

broadcastMessagePromptEx(GuildID,Message)->
	sendMsgToAllMemberByGulidID(GuildID,#pk_SysMessage{type=?SYSTEM_MESSAGE_PROMPT,text = Message}).

broadcastMessageError(Guild,Message)->
	sendMsgToAllMember(Guild,#pk_SysMessage{type=?SYSTEM_MESSAGE_ERROR,text = Message}).

broadcastMessageErrorEx(GuildID,Message)->
	sendMsgToAllMemberByGulidID(GuildID,#pk_SysMessage{type=?SYSTEM_MESSAGE_ERROR,text = Message}).

broadcastMessageBox(Guild,Message)->
	sendMsgToAllMember(Guild,#pk_SysMessage{type=?SYSTEM_MESSAGE_BOX,text = Message}).

broadcastMessageBoxEx(GuildID,Message)->
	sendMsgToAllMemberByGulidID(GuildID,#pk_SysMessage{type=?SYSTEM_MESSAGE_BOX,text = Message}).

%%公会信息变化存储
saveGuildInfo(GuildID)->
	Guild = etsBaseFunc:readRecord(getGuildTable(), GuildID),
	case Guild of
		{}->
			ok;
		_->
			mySqlProcess:updateGuildBaseInfoGamedata(Guild)
	end.

%%公会信息变化存储
saveGuildInfoEx(Guild)->
	mySqlProcess:updateGuildBaseInfoGamedata(Guild).

%%公会成员信息变化存储
saveGuildMemberInfo(GuildID, PlayerID)->
	Guild = etsBaseFunc:readRecord(getGuildTable(), GuildID),
	case Guild of
		{}->
			ok;
		_->
			AMember = etsBaseFunc:readRecord(Guild#guildBaseInfo.memberTable, PlayerID),
			case AMember of
				{}->
					ok;
				_->
					mySqlProcess:updateGuildMemberGamedata(AMember)
			end
	end.

%%公会成员信息变化存储
saveGuildMemberInfoEx(Guild, PlayerID)->
	Member = etsBaseFunc:readRecord(Guild#guildBaseInfo.memberTable, PlayerID),
	case Member of
		{}->ok;
		_->
			mySqlProcess:updateGuildMemberGamedata(Member)
	end.

%%随机一个任务ID
randomGuildTaskByPlayerLevel(PlayerLevel)->
	try
	%GuildTaskTable = get("GuildTaskCfgTable"),
	?DEBUG_OUT("randomGuildTaskByPlayerLevel GuildTaskTable:~p",[?GuildTaskCfgTableAtom]),
	TaskCount = ets:info(?GuildTaskCfgTableAtom, size),
	N = random:uniform(TaskCount),
	?DEBUG_OUT("randomGuildTaskByPlayerLevel N:~p,TaskCount:~p",[N,TaskCount]),

	GuildTask = getGuildTaskRecord(N),
	?DEBUG_OUT("randomGuildTaskByPlayerLevel N:~p,PlayerLevel:~p,TaskList:~p",[N,PlayerLevel,GuildTask]),
	case GuildTask of 
		{}->0;
		_->	%% 31-40,41-50,51-60
			case (PlayerLevel-1) div 10 of
				0->throw({invalidLevel});
				1->throw({invalidLevel});
				2->throw({invalidLevel});
				3->
					GuildTask#guildTaskCfg.task3;
				4->
					GuildTask#guildTaskCfg.task4;
				_->
					GuildTask#guildTaskCfg.task5
			end
	end
	catch
		{invalidLevel}->0;
		_:Why->
			?LOG_OUT("randomGuildTaskByPlayerLevel exception.Why:~p",[Why]),0
	end.




