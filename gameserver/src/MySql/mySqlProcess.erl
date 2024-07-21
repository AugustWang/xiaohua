%% Author: Yaogang
%% Created: 2012-8-8
%% Description: TODO: Add description to itemDB
-module(mySqlProcess).

%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% Include files
%%
-include("mysql.hrl").
-include("db.hrl").
-include("top.hrl").
-include("gamedatadb.hrl").
-include("hdlt_logger.hrl").
-include("itemDefine.hrl").
-include("playerDefine.hrl").
-include("globalDefine.hrl").

-define(WorldVarArray_DbId,1).

%%数据库表主键id生成
%% keyIndex(Table)->
%% 	{_,DbList1} = mySqlProcess:sqldb_query(?GAMEDB_CONNECT_POOL, "select * from dbInfo where name='"++atom_to_list(Table)++"'"),
%% 	DbList = lists:map(fun(List) -> mySqlProcess:dbInfo_list_to_record(List) end, DbList1),
%% 	case DbList of
%% 		[]->
%% 			sqldb_write_record(#dbInfo{name=Table, value=1}),
%% 			0;
%% 		_->
%% 			[Ver|_] = DbList,
%% 			Sql = lists:flatten(io_lib:format("UPDATE dbInfo SET value=value+1 where name='~s'",[atom_to_list(Table)])),
%% 			sqldb_query(?GAMEDB_CONNECT_POOL,Sql),
%% 			Ver#dbInfo.value
%% 	end.

%%mysql查询接口
%% sqldb_query(PoolId,Query)->
%% 	try
%% 		Sql1 = list_to_binary(Query),
%% 		{Data, MySQLRes} = mysql:fetch(PoolId,Sql1),
%% 		case Data of
%% 			error->
%% 				?ERROR_OUT( "sqldb_query:error[~s,~s]",[Query,MySQLRes] ),
%%  				common:messageBox("sqldb_query:error[~s]", [MySQLRes]),
%% %%  				erlang:exit(0),
%% 				{ok, [] };
%% 			_->
%% 				AllRows = mysql:get_result_rows(MySQLRes),
%% 				{ok, AllRows }
%% 		end
%% 	    
%% 	catch
%% 		_->{error, []}
%% 	end.

sqldb_log(Module, Line, Level, FormatFun) ->
     case Level of
     error ->
         {Format, Arguments} = FormatFun(),
         ?ERROR_OUT("~w:~b: "++ Format ++ "~n", [Module, Line] ++ Arguments);
     _ -> ok
    end
 .


%%创建数据表
%% sqldb_create_dbInfo_table()->
%% 	Sql = "CREATE TABLE dbInfo (name CHAR(255) CHARACTER SET utf8,value INT(4))",  
%% 	sqldb_query(?GAMEDB_CONNECT_POOL,Sql). 
%sqldb_create_db_table()->
%	sqldb_create_dbInfo_table().

sqldb_write_dbInfo(Record)->
	Sql = lists:flatten(io_lib:format("REPLACE INTO dbInfo (name, value) VALUES ('~s',~p)",record_to_list(Record))),
 	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,Sql,true).
dbInfo_list_to_record(List)->
	R=list_to_record(List,dbInfo),
	setelement( #dbInfo.name, R, binary_to_list(R#dbInfo.name)).

sqldb_write_record(Record)->
	case element( 1, Record ) of
		dbInfo->
			sqldb_write_dbInfo(Record);
		_->
			common:messageBox("sqldb_write_record:error,no function to insert this record[~p]",[sqldb_write_record] )
			%ok
	end.



my_binary_to_term(Bin,TypeAtom) ->
	case (Bin =:= <<>>) or (Bin =:= undefined) of
		true ->
			case TypeAtom of
				list->[];
				_->{}
			end;
		false-> binary_to_term(Bin)
	end. 

player_gamedata_list_to_record(PlayerGamedataList)->
	R = list_to_record(PlayerGamedataList,player_gamedata),
	P1 = setelement( #player_gamedata.name, R, binary_to_list(R#player_gamedata.name)),
	P2 = setelement( #player_gamedata.storageBagPassWord, P1, binary_to_list(P1#player_gamedata.storageBagPassWord)),
	P3 = setelement( #player_gamedata.mapCDInfoList, P2, my_binary_to_term(P2#player_gamedata.mapCDInfoList,list)),
	P4 = setelement( #player_gamedata.playerMountInfo, P3, my_binary_to_term(P3#player_gamedata.playerMountInfo,list)),
	P5 = setelement( #player_gamedata.playerItemCDInfo, P4, my_binary_to_term(P4#player_gamedata.playerItemCDInfo,list)),
	P6 = setelement( #player_gamedata.playerItem_DailyCountInfo, P5, my_binary_to_term(P5#player_gamedata.playerItem_DailyCountInfo,list)),
	P7 = setelement( #player_gamedata.gameSetMenu, P6, my_binary_to_term(P6#player_gamedata.gameSetMenu,tuple)),
	P8 = setelement( #player_gamedata.varArray, P7, my_binary_to_term(P7#player_gamedata.varArray,tuple)),
	P9 = setelement( #player_gamedata.protectPwd , P8, binary_to_list(P8#player_gamedata.protectPwd )),
	P10 = setelement( #player_gamedata.reasureBowlData , P9, my_binary_to_term(P9#player_gamedata.reasureBowlData,tuple )),
	P11 = setelement( #player_gamedata.taskSpecialData , P10, my_binary_to_term(P10#player_gamedata.taskSpecialData,tuple )),
	setelement( #player_gamedata.goldPassWord, P11, binary_to_list(P11#player_gamedata.goldPassWord)).

	

		

%%列表转化成记录
list_to_record(List,Record)->
	case List of
	[]->
		{};
	_->
		List1 = [Record] ++ List,
		list_to_tuple(List1)
	end.
%%记录转化成列表
record_to_list(Record)->
	List1 = tuple_to_list(Record),
	[_RecordName|List] = List1,
	List.

bool_to_int(Bool)->
	case Bool of
		true->
			A = 1;
		false->
			A = 0
		end,
	A.

int_to_bool(Int)->
	case Int of
		1->
			A=true;
		0->
			A=false
		end,
	A.


%% serializationData(Data)->
%% 	B = term_to_binary(Data),
%% 	binary_to_list(B).

	

%% unSerializationData(Data)->
%% 	case Data of
%% 		<<>>->
%% 			B = [];
%% 		_->
%% 			B =binary_to_term(Data)
%% 	end,
%% 	B.


%%坐骑基础表
%%坐骑逻辑层使用之record
%% -record(mountInfo,{mountID,      %%64位唯一ID
%% 				   masterID,     %%64位主人ID
%% 				   mountDataID,  %%坐骑配表ID
%% 				   mountLevel,   %%坐骑等级
%% 				   mountprogress %%坐骑当前升级进度
%% 				   }).


%% add by wenziyong
%%好友
addFriend(#friend_gamedata{}=F) ->
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_friend_gamedata, mySqlProcess:record_to_list(F),true).
replaceFriend(#friend_gamedata{}=F) ->
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,replace_friend_gamedata, mySqlProcess:record_to_list(F),true).
%% L=[friendType, friendValue,  id]
updateFriend(L) ->
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,update_friend_gamedata, L,true).
friendGamedata_list_to_record(List)->
	R=list_to_record(List,friend_gamedata),
	%% maybe not need to do the next line
	setelement(#friend_gamedata.friendName, R, binary_to_list(R#friend_gamedata.friendName)).
get_friendGamedataListByPlayerID(PlayerID) ->
	{_,AllFriendGamedataList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,
										 "SELECT * FROM friend_gamedata where playerID="++integer_to_list(PlayerID),true),	
  	lists:map(fun(List) -> mySqlProcess:friendGamedata_list_to_record(List) end, AllFriendGamedataList1).

get_playerIdListWhichAddMeAsFriend(PlayerID) ->
	{_,AllPlayerIdlistList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,
										 "SELECT playerID FROM friend_gamedata where friendID="++integer_to_list(PlayerID),true),	
  	lists:map(fun(List) -> [Id|_] = List,Id  end, AllPlayerIdlistList1).

%%交易行
%%上架物品 保存
insert_conSalesItemDB(#conSalesItemDB{}=Record)->
	Sql=lists:flatten(io_lib:format("INSERT INTO conSalesItemDB 
		(conSalesId, conSalesMoney, groundingTime, timeType, playerId, itemDBId) 
		VALUES (~p, ~p, ~p, ~p, ~p, ~p)",record_to_list(Record))),
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,Sql,true).
%% 物品下架
delete_conSalesItemDB(ConSalesId) ->
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, "delete from conSalesItemDB where conSalesId="++integer_to_list(ConSalesId),true).
%% 
get_all_conSalesItemDB() ->
	{_,ConItemDB1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM conSalesItemDB",true ),
	lists:map(fun(List) -> mySqlProcess:list_to_record(List,conSalesItemDB) end, ConItemDB1).

%% ->[] or [player]
%get_playerList_by_id(PlayerId) ->
%	{_,PlayerList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM player WHERE id="++integer_to_list(PlayerId),true),
%	lists:map(fun(List) -> player_list_to_record(List) end, PlayerList1).

get_playerGamedata_list_by_id(PlayerId) ->
	{_,PlayerGamedataList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM player_gamedata WHERE id="++integer_to_list(PlayerId)++" and isDelete=0",true),
	lists:map(fun(List) -> player_gamedata_list_to_record(List) end, PlayerGamedataList1).

%% -> name or []
get_playerName_by_id(PlayerId) ->
	{_,PlayerNameList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT name FROM player_gamedata WHERE id="++integer_to_list(PlayerId)++" and isDelete=0",true),
	case getColumnBySelectColumnResult(PlayerNameList1) of
		0->[];
		Name->binary_to_list(Name)
	end.



isPlayerExistByNameIncludeWithDeleteFlagPlayer(PlayerName )->
	{_SuccOrErr,PlayerIdList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"select id from player_gamedata where name = '"++PlayerName++"'",true),
	getColumnBySelectColumnResult(PlayerIdList).

%% -> 0 or id  (0: mean not exist this player)
isPlayerExistByName(  PlayerName )->
	{_SuccOrErr,PlayerIdList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"select id from player_gamedata where name = '"++PlayerName++"'"++" and isDelete=0",true),
	getColumnBySelectColumnResult(PlayerIdList).


%% -> {} or GameSetMenu
get_gameSetMenuBy_id(PlayerId) ->
	{_SuccOrErr,PlayerGameSetMenuList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT gameSetMenu FROM player_gamedata WHERE id="++integer_to_list(PlayerId),true),
	case PlayerGameSetMenuList of
		[]->
			{};
		[GameSetMenuList|_]->
			case GameSetMenuList of
				[] -> {};
				[GameSetMenu|_] -> my_binary_to_term(GameSetMenu,tuple)
			end
	end.

%% -> 0 or id  (0: mean not exist this player)
isPlayerExistById(PlayerId) ->
	{_,PlayerIdList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT id FROM player_gamedata WHERE id="++integer_to_list(PlayerId)++" and isDelete=0",true),
	getColumnBySelectColumnResult(PlayerIdList).

%% -> 0 or version
getDbVersion()->
	{_,DbVersionList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, "select value from dbInfo where name='vesion'",true),
	getColumnBySelectColumnResult(DbVersionList).

getDbGmLevel()->
	{_,DbLevelList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, "select value from dbInfo where name='gmLevel'",true),
	getColumnBySelectColumnResult(DbLevelList).



%% 玩家
updatePlayerGamedataByPlayerAndOthers(#player{}=P,PlayerMountInfo,PlayerItemCDInfo,PlayerItem_DailyCountInfo)->
	L = [P#player.map_data_id,P#player.mapId,
		 P#player.level, P#player.camp, P#player.faction, P#player.sex, P#player.crossServerHonor, P#player.unionContribute, 
		P#player.competMoney, P#player.weekCompet, P#player.battleHonor, P#player.aura, P#player.charm, P#player.vip, 
		P#player.maxEnabledBagCells,P#player.maxEnabledStorageBagCells,P#player.storageBagPassWord,P#player.unlockTimes, 
		P#player.money, P#player.moneyBinded,  P#player.goldBinded, P#player.ticket, P#player.guildContribute, P#player.honor, P#player.credit,
		P#player.exp, P#player.lastOnlineTime, P#player.lastOfflineTime, P#player.isOnline, P#player.guildID,
		P#player.conBankLastFindTime, P#player.chatLastSpeakTime,
		P#player.outFightPet,P#player.pK_Kill_Value,P#player.pK_Kill_OpenTime,P#player.pk_Kill_Punish,
		term_to_binary(PlayerMountInfo,[compressed]),term_to_binary(PlayerItemCDInfo,[compressed]),
		P#player.bloodPoolLife,
		term_to_binary(PlayerItem_DailyCountInfo,[compressed]),
		P#player.petBloodPoolLife,
		P#player.fightingCapacity,P#player.fightingCapacityTop,P#player.platSendItemBits,
		term_to_binary(P#player.gameSetMenu,[compressed]), term_to_binary(P#player.varArray,[compressed]),P#player.protectPwd,
		term_to_binary(P#player.reasureBowlData,[compressed]),term_to_binary(P#player.taskSpecialData,[compressed]),P#player.exp15Add,P#player.exp20Add,P#player.exp30Add,
		P#player.goldPassWord,P#player.goldPassWordUnlockTimes,
		P#player.vipLevel,P#player.vipTimeExpire,P#player.vipTimeBuy,
		P#player.id],
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,update_player_gamedata_by_player_and_others,L,true).

updatePlayerVarArray(PlayerID,VarArray)->
	L = [ term_to_binary(VarArray,[compressed]),PlayerID],
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,update_player_var_array,L,true).


updateGuidIdOfPlayerGamedata(#player_gamedata{}=P) ->
	L = [P#player_gamedata.guildID,P#player_gamedata.id],
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,update_guidid_of_player_gamedata,L,true).

updatePlayerGamedataByPlayerMapDBInfo(#playerMapDBInfo{}=P)->
	L = [P#playerMapDBInfo.hp,P#playerMapDBInfo.x,P#playerMapDBInfo.y,
		 term_to_binary(P#playerMapDBInfo.mapCDInfoList,[compressed]),P#playerMapDBInfo.bloodPoolLife,P#playerMapDBInfo.id],
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,update_player_gamedata_by_playerMapDBInfo,L,true).

insertPlayerGamedata(#player{}=P,PlayerMountInfo,PlayerItemCDInfo,PlayerItem_DailyCountInfo)->
	PlayerGamedata = dataConv:fillPlayerGamedataByPlayerAndOthers(P,PlayerMountInfo,PlayerItemCDInfo,PlayerItem_DailyCountInfo),
	PlayerGamedata1 = setelement( #player_gamedata.mapCDInfoList, PlayerGamedata, term_to_binary(PlayerGamedata#player_gamedata.mapCDInfoList,[compressed]) ),
	PlayerGamedata2 = setelement( #player_gamedata.playerMountInfo, PlayerGamedata1, term_to_binary(PlayerGamedata1#player_gamedata.playerMountInfo,[compressed]) ),
	PlayerGamedata3 = setelement( #player_gamedata.playerItemCDInfo, PlayerGamedata2, term_to_binary(PlayerGamedata2#player_gamedata.playerItemCDInfo,[compressed]) ),
	PlayerGamedata4 = setelement( #player_gamedata.playerItem_DailyCountInfo, PlayerGamedata3, term_to_binary(PlayerGamedata3#player_gamedata.playerItem_DailyCountInfo,[compressed]) ),
	PlayerGamedata5 = setelement( #player_gamedata.gameSetMenu, PlayerGamedata4, term_to_binary(PlayerGamedata4#player_gamedata.gameSetMenu,[compressed]) ),
	PlayerGamedata6 = setelement( #player_gamedata.varArray, PlayerGamedata5, term_to_binary(PlayerGamedata5#player_gamedata.varArray,[compressed]) ),
	PlayerGamedata7 = setelement( #player_gamedata.reasureBowlData, PlayerGamedata6, term_to_binary(PlayerGamedata6#player_gamedata.reasureBowlData,[compressed]) ),
	PlayerGamedata8 = setelement( #player_gamedata.taskSpecialData, PlayerGamedata7, term_to_binary(PlayerGamedata7#player_gamedata.taskSpecialData,[compressed]) ),

	L = mySqlProcess:record_to_list(PlayerGamedata8),
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_player_gamedata,L,true).

%% 仙盟(工会)
%-record(guildBaseInfo, {id, chairmanPlayerID, level, faction, exp, chairmanPlayerName, guildName, affiche, createTime, memberTable, applicantTable}).
% delete memberTable, applicantTable
%-record(guildBaseInfo_gamedata, {id, chairmanPlayerID, level, faction, exp,
%						 chairmanPlayerName, guildName, affiche, createTime}).
insertGuildBaseInfoGamedata(#guildBaseInfo{}=R)->
	Gamedata = dataConv:fillGuildBaseInfoGamedataByGuildBaseInfo(R),
	L = mySqlProcess:record_to_list(Gamedata),
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_guildBaseInfo_gamedata,L,true).

updateGuildBaseInfoGamedata(#guildBaseInfo{}=R)->
	L = [R#guildBaseInfo.chairmanPlayerID,R#guildBaseInfo.level,R#guildBaseInfo.faction,R#guildBaseInfo.exp,
		R#guildBaseInfo.chairmanPlayerName,R#guildBaseInfo.guildName,R#guildBaseInfo.affiche, R#guildBaseInfo.id],
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,update_guildBaseInfo_gamedata,L,true).

get_allGuidBase() ->
	{_,GamedataList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM guildbaseinfo_gamedata",true),
	GamedataList2 = lists:map(fun(List) -> guildBaseInfoGamedata_list_to_record(List) end, GamedataList1),
	lists:map(fun(R) -> dataConv:fillGuildBaseInfoByGuildBaseInfoGamedata(R) end, GamedataList2).

guildBaseInfoGamedata_list_to_record(List)->
	R=list_to_record(List,guildBaseInfo_gamedata),
	P1 = setelement( #guildBaseInfo_gamedata.chairmanPlayerName, R, binary_to_list(R#guildBaseInfo_gamedata.chairmanPlayerName)),
	P2 = setelement( #guildBaseInfo_gamedata.guildName, P1, binary_to_list(P1#guildBaseInfo_gamedata.guildName)),
	setelement( #guildBaseInfo_gamedata.affiche, P2, binary_to_list(P2#guildBaseInfo_gamedata.affiche)).



insertGuildMemberGamedata(#guildMember{}=R)->
	Gamedata = dataConv:fillGuildMemberGamedataByGuildMember(R),
	L = mySqlProcess:record_to_list(Gamedata),
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_guildMember_gamedata,L,true).
updateGuildMemberGamedata(#guildMember{}=R)->
	L = [R#guildMember.rank, R#guildMember.playerLevel, R#guildMember.playerClass, 
				R#guildMember.contribute, R#guildMember.contributeMoney, R#guildMember.contributeTime,
				R#guildMember.id],
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,update_guildMember_gamedata,L,true).
%-record(guildMember, {id, guildID, playerID, rank, playerName, playerLevel, playerClass, isOnline, contribute, contributeMoney, contributeTime, joinTime}).
% delete isOnline
%-record(guildMember_gamedata, {id, guildID, playerID, rank, playerName, playerLevel, playerClass, 
%	contribute, contributeMoney, contributeTime, joinTime}).
get_guidMembersByGuidId(Id) ->
	{_,GamedataList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"select * from guildmember_gamedata where guildID="++integer_to_list(Id),true),
	GamedataList2 = lists:map(fun(List) -> guildMemberGamedata_list_to_record(List) end, GamedataList1),
	lists:map(fun(R) -> dataConv:fillGuildMemberByGuildMemberGamedata(R) end, GamedataList2).
guildMemberGamedata_list_to_record(List)->
	R=list_to_record(List,guildMember_gamedata),
	setelement( #guildMember_gamedata.playerName, R, binary_to_list(R#guildMember_gamedata.playerName)).
deleteGuildMemberGamedata(Id) ->
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, "delete from guildmember_gamedata where id="++integer_to_list(Id), true).


insertGuildApplicant(#guildApplicant{}=R)->
	L = mySqlProcess:record_to_list(R),
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_guildApplicant,L,true).
get_guidApplicantByGuidId(Id) ->
	{_,List1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"select * from guildapplicant where guildID="++integer_to_list(Id),true),
	lists:map(fun(List) -> guildApplicant_list_to_record(List) end, List1).
guildApplicant_list_to_record(List)->
	R=list_to_record(List,guildApplicant),
	setelement( #guildApplicant.playerName, R, binary_to_list(R#guildApplicant.playerName)).

deleteGuildApplicant(Id) ->
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, "delete from guildapplicant where id="++integer_to_list(Id), true).

deleteRecordByTableNameAndId(TableNm,Id)	->
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, "delete from " ++ TableNm ++" where id="++integer_to_list(Id), true).

%%邮件
mailRecord_list_to_record(MailRecordList)->
		R = list_to_record(MailRecordList,mailRecord),
		P1 = setelement( #mailRecord.nameSender, R, binary_to_list(R#mailRecord.nameSender)),
		P2 = setelement( #mailRecord.title, P1, binary_to_list(P1#mailRecord.title)),
		setelement( #mailRecord.content, P2, binary_to_list(P2#mailRecord.content)).
insertMailRecord(#mailRecord{}=R)->
	L = mySqlProcess:record_to_list(R),
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_mailRecord,L,true).

get_allMail() ->
	{_,AllMailList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM mailRecord",true),
	lists:map(fun(List) -> mySqlProcess:mailRecord_list_to_record(List) end, AllMailList1).
updatemailRecord(#mailRecord{}=R)->
	L = [R#mailRecord.attachItemDBID1, R#mailRecord.attachItemDBID2,R#mailRecord.moneySend,R#mailRecord.moneyPay,R#mailRecord.id],
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,update_mailRecord,L,true).

%% 任务
% playertask_gamedata
%-record(playerTask, {id, taskID, playerID, taskBase, state, aimProgressList}).
% delete taskBase, get taskBase from configure table 
%-record(playerTask_gamedata, {id, taskID, playerID, state, aimProgressList}).
insertPlayerTaskGamedata(#playerTask{}=R)->
	Gamedata = dataConv:fillPlayerTaskGamedataByPlayerTask(R),
	Gamedata1 = setelement( #playerTask_gamedata.aimProgressList, Gamedata, term_to_binary(Gamedata#playerTask_gamedata.aimProgressList,[compressed]) ),
 	L = mySqlProcess:record_to_list(Gamedata1),
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_playerTask_gamedata,L,true).
replacePlayerTaskGamedata(#playerTask{}=R)->
	Gamedata = dataConv:fillPlayerTaskGamedataByPlayerTask(R),
	Gamedata1 = setelement( #playerTask_gamedata.aimProgressList, Gamedata, term_to_binary(Gamedata#playerTask_gamedata.aimProgressList,[compressed]) ),
 	L = mySqlProcess:record_to_list(Gamedata1),
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,replace_playerTask_gamedata,L,true).
 
playerTask_gamedata_list_to_record(PlayerTaskGamedataList)->
	R = list_to_record(PlayerTaskGamedataList,playerTask_gamedata),
	setelement( #playerTask_gamedata.aimProgressList, R, my_binary_to_term(R#playerTask_gamedata.aimProgressList,list)).

get_allPlayerTaskByPlayerId(PlayerID) ->
	{_,AllAcceptedTaskDBDataList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,
														  "SELECT * FROM playertask_gamedata where playerID="++integer_to_list(PlayerID),true),	
	playerTaskGamedataList_to_PlayerTaskList(AllAcceptedTaskDBDataList1).

playerTaskGamedataList_to_PlayerTaskList([])-> [];
playerTaskGamedataList_to_PlayerTaskList([H|T]) -> 
	PlayerTaskGamedata = playerTask_gamedata_list_to_record(H),
	QuestBase = etsBaseFunc:readRecord( main:getGlobalTaskBaseTable(), PlayerTaskGamedata#playerTask_gamedata.taskID ),
	case QuestBase of
		{} ->[playerTaskGamedataList_to_PlayerTaskList(T)];
		_->[dataConv:fillPlayerTaskByPlayerTaskGamedataAndBase(PlayerTaskGamedata,QuestBase) | playerTaskGamedataList_to_PlayerTaskList(T)]
	end.
	
%-record(playerCompletedTask, {playerID, taskIDList} ).
insertPlayerCompletedTask(#playerCompletedTask{}=R)->
	Gamedata1 = setelement( #playerCompletedTask.taskIDList, R, term_to_binary(R#playerCompletedTask.taskIDList,[compressed]) ),
 	L = mySqlProcess:record_to_list(Gamedata1),
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_playerCompletedTask,L,true).
replacePlayerCompletedTask(#playerCompletedTask{}=R)->
	Gamedata1 = setelement( #playerCompletedTask.taskIDList, R, term_to_binary(R#playerCompletedTask.taskIDList,[compressed]) ),
 	L = mySqlProcess:record_to_list(Gamedata1),
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,replace_playerCompletedTask,L,true).
playerCompletedTask_list_to_record(PlayerCompletedTaskList)->
	R = list_to_record(PlayerCompletedTaskList,playerCompletedTask),
	setelement( #playerCompletedTask.taskIDList, R, my_binary_to_term(R#playerCompletedTask.taskIDList,list)).
get_playerCompletedTaskListByPlayerID(PlayerID) ->	
	{_,AllCompletedTaskDBDataList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM playerCompletedTask where playerID="++integer_to_list(PlayerID),true),	
  	lists:map(fun(List) -> mySqlProcess:playerCompletedTask_list_to_record(List) end, AllCompletedTaskDBDataList1).


%% pet
petProperty_gamedata_list_to_record(List)->
	R=list_to_record(List,petProperty_gamedata),
	P1 = setelement(#petProperty_gamedata.name, R, binary_to_list(R#petProperty_gamedata.name)),
	setelement(#petProperty_gamedata.skills, P1, my_binary_to_term(P1#petProperty_gamedata.skills,list)).
insertPetPropertyGamedata(#petProperty{}=R)->
	Gamedata = dataConv:fillPetPropertyGamedataByPetProperty(R),
	Gamedata1 = setelement( #petProperty_gamedata.skills, Gamedata, term_to_binary(Gamedata#petProperty_gamedata.skills,[compressed]) ),
 	L = mySqlProcess:record_to_list(Gamedata1),
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_petProperty_gamedata,L,true).
replacePetPropertyGamedata(#petProperty{}=R)->
	Gamedata = dataConv:fillPetPropertyGamedataByPetProperty(R),
	Gamedata1 = setelement( #petProperty_gamedata.skills, Gamedata, term_to_binary(Gamedata#petProperty_gamedata.skills,[compressed]) ),
 	L = mySqlProcess:record_to_list(Gamedata1),
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,replace_petProperty_gamedata,L,true).
get_petsByMasterId(PlayerID) ->
	{_,PetList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, "select * from petProperty_gamedata where masterId="++integer_to_list(PlayerID),true),
	PetList2=lists:map( fun(List)->mySqlProcess:petProperty_gamedata_list_to_record(List) end, PetList1),
	lists:map( fun(Record)->dataConv:fillPetPropertyByPetPropertyGamedata(Record) end, PetList2).

%% playerskill_gamedata
% delete id from playerskill
% 	-record(playerSkill_gamedata, {playerId, skillId,coolDownTime, activationSkillID1, activationSkillID2, curBindedSkillID} ).
convPlayerSkillGamedataListToplayerSkillList(L) ->
	[PlayerID|L1] = L,
	[SkillID|_] = L1,
	Id = playerSkill:getPlayerSkillID( PlayerID, SkillID ),
	[Id] ++ L.	
get_playerSkillsByPlayerID(PlayerID) ->
	{_,AllSkillList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM playerSkill_gamedata where playerID="++integer_to_list(PlayerID),true),
	AllSkillList2 = lists:map(fun(List) -> convPlayerSkillGamedataListToplayerSkillList(List) end, AllSkillList1),	
	lists:map(fun(List) -> mySqlProcess:list_to_record(List,playerSkill) end, AllSkillList2).
insertPlayerSkillGamedata(#playerSkill{}=R)->
 	L = mySqlProcess:record_to_list(R),
	%%transfer playerSkill to playerSkill_gamedata (delete id)
	[_H|L1] = L,
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_playerSkill_gamedata,L1,true).
updatePlayerSkillGamedata(#playerSkill{}=R)->
	L = [R#playerSkill.coolDownTime, R#playerSkill.activationSkillID1, R#playerSkill.activationSkillID2, 
		 R#playerSkill.curBindedSkillID, R#playerSkill.playerId,R#playerSkill.skillId],
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,update_playerSkill_gamedata,L,true).
deletePlayerSkillGamedata(PlayerID,SkillID) ->
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, 
		"delete from playerskill_gamedata where playerId="++integer_to_list(PlayerID)++" and skillId="++integer_to_list(SkillID), true).


%% CREATE TABLE `playerskill_gamedata` (
%%   `playerId` bigint(8) DEFAULT NULL,
%%   `skillId` int(4) DEFAULT NULL,
%%   `coolDownTime` int(4) DEFAULT NULL,
updatePlayerSkillCD(PlayerID,SkillID,CoolDownTime)->
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, 
		"update playerskill_gamedata set coolDownTime="++integer_to_list(CoolDownTime)++" where playerId="++integer_to_list(PlayerID)++
								" and skillId="++integer_to_list(SkillID), true).



%% equip
%-record(playerEquipItem,{id, playerId, equipid,type, quality, isEquiped,  propertyTypeValueArray}).
playerEquipItem_list_to_record(List)->
	R=list_to_record(List,playerEquipItem),
	setelement( #playerEquipItem.propertyTypeValueArray, R, my_binary_to_term(R#playerEquipItem.propertyTypeValueArray,list)).
get_equipListByPlayerID(PlayerID) ->
	{_,EquipedList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM playerequipitem where playerID="++integer_to_list(PlayerID),true),
	lists:map(fun(List) -> mySqlProcess:playerEquipItem_list_to_record(List) end, EquipedList1).

insertOrReplacePlayerEquipItem(#playerEquipItem{}=R,IsReplace)->
	Gamedata1 = setelement( #playerEquipItem.propertyTypeValueArray, R, term_to_binary(R#playerEquipItem.propertyTypeValueArray,[compressed]) ),
 	L = mySqlProcess:record_to_list(Gamedata1),
	case IsReplace of
		true ->mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,replace_playerEquipItem,L,true);
		_ -> mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_playerEquipItem,L,true)
	end.

% can improved, now just save it when player offline, should update when playerEquipEnhanceLevel is changed, secondly should not use binary
%-record(playerEquipEnhanceLevel,{ playerId, ring, weapon,cap, shoulder, pants, hand, coat, belt, shoe, accessories, wing, fashion} ).
playerEquipEnhanceLevel_list_to_record(List)->
	R=list_to_record(List,playerEquipEnhanceLevel),
	P1 = setelement(#playerEquipEnhanceLevel.ring, R, my_binary_to_term(R#playerEquipEnhanceLevel.ring,tuple)),
	P2 = setelement(#playerEquipEnhanceLevel.weapon, P1, my_binary_to_term(P1#playerEquipEnhanceLevel.weapon,tuple)),
	P3 = setelement(#playerEquipEnhanceLevel.cap, P2, my_binary_to_term(P2#playerEquipEnhanceLevel.cap,tuple)),
	P4 = setelement(#playerEquipEnhanceLevel.shoulder, P3, my_binary_to_term(P3#playerEquipEnhanceLevel.shoulder,tuple)),
	P5 = setelement(#playerEquipEnhanceLevel.pants, P4, my_binary_to_term(P4#playerEquipEnhanceLevel.pants,tuple)),
	P6 = setelement(#playerEquipEnhanceLevel.hand, P5, my_binary_to_term(P5#playerEquipEnhanceLevel.hand,tuple)),
	P7 = setelement(#playerEquipEnhanceLevel.coat, P6, my_binary_to_term(P6#playerEquipEnhanceLevel.coat,tuple)),
	P8 = setelement(#playerEquipEnhanceLevel.belt, P7, my_binary_to_term(P7#playerEquipEnhanceLevel.belt,tuple)),
	P9 = setelement(#playerEquipEnhanceLevel.shoe, P8, my_binary_to_term(P8#playerEquipEnhanceLevel.shoe,tuple)),
	P10 = setelement(#playerEquipEnhanceLevel.accessories, P9, my_binary_to_term(P9#playerEquipEnhanceLevel.accessories,tuple)),
	P11 = setelement(#playerEquipEnhanceLevel.wing, P10, my_binary_to_term(P10#playerEquipEnhanceLevel.wing,tuple)),
	setelement(#playerEquipEnhanceLevel.fashion, P11, my_binary_to_term(P11#playerEquipEnhanceLevel.fashion,tuple)).

get_playerEquipEnhanceLevelListByPlayerID(PlayerID) ->
		{_,EquipEnhanceInfoList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,
										"SELECT * FROM playerEquipEnhanceLevel where playerID="++integer_to_list(PlayerID),true),	
  	    lists:map(fun(List) -> mySqlProcess:playerEquipEnhanceLevel_list_to_record(List) end, 
										 EquipEnhanceInfoList1).
insertOrReplacePlayerEquipEnhanceLevel(#playerEquipEnhanceLevel{}=R,IsReplace)->
	% the following binary is very small, don't need compress
	P1 = setelement(#playerEquipEnhanceLevel.ring, R, term_to_binary(R#playerEquipEnhanceLevel.ring)),
	P2 = setelement(#playerEquipEnhanceLevel.weapon, P1, term_to_binary(P1#playerEquipEnhanceLevel.weapon)),
	P3 = setelement(#playerEquipEnhanceLevel.cap, P2, term_to_binary(P2#playerEquipEnhanceLevel.cap)),
	P4 = setelement(#playerEquipEnhanceLevel.shoulder, P3, term_to_binary(P3#playerEquipEnhanceLevel.shoulder)),
	P5 = setelement(#playerEquipEnhanceLevel.pants, P4, term_to_binary(P4#playerEquipEnhanceLevel.pants)),
	P6 = setelement(#playerEquipEnhanceLevel.hand, P5, term_to_binary(P5#playerEquipEnhanceLevel.hand)),
	P7 = setelement(#playerEquipEnhanceLevel.coat, P6, term_to_binary(P6#playerEquipEnhanceLevel.coat)),
	P8 = setelement(#playerEquipEnhanceLevel.belt, P7, term_to_binary(P7#playerEquipEnhanceLevel.belt)),
	P9 = setelement(#playerEquipEnhanceLevel.shoe, P8, term_to_binary(P8#playerEquipEnhanceLevel.shoe)),
	P10 = setelement(#playerEquipEnhanceLevel.accessories, P9, term_to_binary(P9#playerEquipEnhanceLevel.accessories)),
	P11 = setelement(#playerEquipEnhanceLevel.wing, P10, term_to_binary(P10#playerEquipEnhanceLevel.wing)),
	P12 = setelement(#playerEquipEnhanceLevel.fashion, P11, term_to_binary(P11#playerEquipEnhanceLevel.fashion)),
 	L = mySqlProcess:record_to_list(P12),
	case IsReplace of
		true ->mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,replace_playerEquipEnhanceLevel,L,true);
		_ -> mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_playerEquipEnhanceLevel,L,true)
	end.

%-record(playerPetSealAhs, {playerId, skillIds}).
playerPetSealAhs_list_to_record(List)->
	R=list_to_record(List,playerPetSealAhs),
	setelement(#playerPetSealAhs.skillIds, R, my_binary_to_term(R#playerPetSealAhs.skillIds,list)).
get_playerPetSealAhsListByPlayerID(PlayerID) ->
	{_,PetList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, "select * from playerPetSealAhs where playerId="++integer_to_list(PlayerID),true),
	lists:map( fun(List)->mySqlProcess:playerPetSealAhs_list_to_record(List) end, PetList1).
insertOrReplacePetSealAhs(#playerPetSealAhs{}=R,IsReplace)->
	P1 = setelement(#playerPetSealAhs.skillIds, R, term_to_binary(R#playerPetSealAhs.skillIds,[compressed])),
 	L = mySqlProcess:record_to_list(P1),
	case IsReplace of
		true ->mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,replace_playerPetSealAhs,L,true);
		_ -> mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_playerPetSealAhs,L,true)
	end.

%% r_itemdb 
r_itemDB_list_to_record(List)->
	R=list_to_record(List,r_itemDB),
	setelement( #r_itemDB.binded, R, int_to_bool(R#r_itemDB.binded)).
get_r_itemDBListByPlayerID(PlayerID) ->
	{_,AllItemDBDataList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM r_itemDB where owner_id="++integer_to_list(PlayerID)++" and owner_type="++integer_to_list(?item_owner_type_player),true),
 	lists:map(fun(List) -> mySqlProcess:r_itemDB_list_to_record(List) end, AllItemDBDataList1).
get_itemDbList_by_id(ItemDBId) ->
	{_,ItemDBList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,
		"SELECT * FROM r_itemDB WHERE id="++integer_to_list(ItemDBId),true),
	lists:map(fun(List) -> mySqlProcess:r_itemDB_list_to_record(List) end, ItemDBList1).
insertOrReplaceR_itemDB(#r_itemDB{}=R,IsReplace) ->
	P1 = setelement( #r_itemDB.binded, R, bool_to_int(R#r_itemDB.binded)),
 	L = mySqlProcess:record_to_list(P1),
	case IsReplace of
		true ->mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,replace_r_itemDB,L,true);
		_ -> mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_r_itemDB,L,true)
	end.

%% r_playerbag
r_playerBag_list_to_record(List)->
	R=list_to_record(List,r_playerBag),
	setelement( #r_playerBag.enable, R, int_to_bool(R#r_playerBag.enable)).
get_playerBagDataLisByPlayerID(PlayerID) ->
	{_,AllItemBagDataList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM r_playerBag where playerID="++integer_to_list(PlayerID),true),	
  	lists:map(fun(List) -> mySqlProcess:r_playerBag_list_to_record(List) end, AllItemBagDataList1).
insertOrReplaceR_playerBag(#r_playerBag{}=R,IsReplace) ->
	P1 = setelement( #r_playerBag.enable, R, bool_to_int(R#r_playerBag.enable)),
 	L = mySqlProcess:record_to_list(P1),
	case IsReplace of
		true ->mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,replace_r_playerBag,L,true);
		_ -> mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_r_playerBag,L,true)
	end.
%% shoutcut
% -record(shortcut, {playerID, index1ID, index2ID, index3ID, index4ID, index5ID, index6ID, index7ID, index8ID,
%				   index9ID, index10ID, index11ID, index12ID}).
insertOrReplaceShortcut(#shortcut{}=Record,IsReplace)->
	case IsReplace of
		true ->
			Sql = lists:flatten(io_lib:format("REPLACE INTO shortcut 
				(playerID, index1ID, index2ID, index3ID, index4ID, index5ID, index6ID, index7ID, index8ID,index9ID, index10ID, index11ID, index12ID) 
				VALUES (~p,~p,~p,~p,~p,~p,~p,~p,~p,~p,~p,~p,~p)",record_to_list(Record)));
		false ->
			Sql = lists:flatten(io_lib:format("INSERT INTO shortcut 
				(playerID, index1ID, index2ID, index3ID, index4ID, index5ID, index6ID, index7ID, index8ID,index9ID, index10ID, index11ID, index12ID) 
				VALUES (~p,~p,~p,~p,~p,~p,~p,~p,~p,~p,~p,~p,~p)",record_to_list(Record)))
	end,		
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,Sql,true).

get_shortcutListByPlayerID(PlayerID) ->
	{_,AllShortcutList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM shortcut where playerID="++integer_to_list(PlayerID),true),	
  	lists:map(fun(List) -> mySqlProcess:list_to_record(List,shortcut) end, AllShortcutList1).

%% playerdaily, will continue
%-record(playerDaily, {id, playerID, dailyList}).
playerDaily_list_to_record(List)->
	R=list_to_record(List,playerDaily),
	setelement(#playerDaily.dailyList, R, my_binary_to_term(R#playerDaily.dailyList,list)).
get_playerDailyListByPlayerID(PlayerID) ->
	{_,DailyList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM playerDaily where playerID="++integer_to_list(PlayerID),true),	
  	lists:map(fun(List) -> mySqlProcess:playerDaily_list_to_record(List) end, DailyList1).
insertOrReplacePlayerDaily(#playerDaily{}=R,IsReplace) ->
	P1 = setelement(#playerDaily.dailyList, R, term_to_binary(R#playerDaily.dailyList,[compressed])),
 	L = mySqlProcess:record_to_list(P1),
	case IsReplace of
		true ->mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,replace_playerDaily,L,true);
		_ -> mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_playerDaily,L,true)
	end.

%%objectBuffDB
%-record( objectBuffDB, {id, buffList}).
objectBuffDB_list_to_record(List)->
	R = list_to_record(List,objectBuffDB),
	setelement( #objectBuffDB.buffList, R, my_binary_to_term(R#objectBuffDB.buffList,list)).
get_objectBuffDBListById(Id) ->
	{_,ObjectBuffDBList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM objectbuffdb where id="++integer_to_list(Id),true),	
  	lists:map(fun(List) -> mySqlProcess:objectBuffDB_list_to_record(List) end, ObjectBuffDBList).

insertObjectBuffDB(#objectBuffDB{}=R)->
	Gamedata1 = setelement( #objectBuffDB.buffList, R, term_to_binary(R#objectBuffDB.buffList,[compressed]) ),
 	L = mySqlProcess:record_to_list(Gamedata1),
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_objectBuffDB,L,true).
replaceObjectBuffDB(#objectBuffDB{}=R)->
	Gamedata1 = setelement( #objectBuffDB.buffList, R, term_to_binary(R#objectBuffDB.buffList,[compressed]) ),
 	L = mySqlProcess:record_to_list(Gamedata1),
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,replace_objectBuffDB,L,true).


%% playeronhook
replacePlayeronhook(PlayerID,ContentBinary) ->
 	L = [PlayerID,ContentBinary],
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,replace_playeronhook,L,true).
updatePlayeronhook(PlayerID,ContentBinary) ->
 	L = [ContentBinary,PlayerID],
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,update_playeronhook,L,true).

%-record(playerSignin, {playerId, alreadyDays,lastSignTime} ).
get_playerSignin(PlayerID) ->
	{_,PlayerSigninList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM playersignin where playerId="++integer_to_list(PlayerID),true),	
  	lists:map(fun(List) -> list_to_record(List,playerSignin) end, PlayerSigninList).
replacePlayerSignin(#playerSignin{}=R)->
 	L = mySqlProcess:record_to_list(R),
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,replace_playerSignin,L,true).

	
%% 商城
insertBazzarItem(#bazzarItem{}=R)->
 	L = mySqlProcess:record_to_list(R),
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_bazzarItem,L,true).
replaceBazzarItem(#bazzarItem{}=R)->
 	L = mySqlProcess:record_to_list(R),
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,replace_bazzarItem,L,true).
%% Cnt为Db_id对应出减少的个数    return -> {ok,[]} or {error,[]}
reduceRemainCountForBazzarItem(Db_id,Cnt) ->
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"update bazzarItem set  remain_count=remain_count-"++integer_to_list(Cnt)++"  where db_id="++integer_to_list(Db_id),true).
%% ->[] or [#bazzarItem{}]
get_AllBazzarItem() ->
	{_,BazzarItemList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM bazzarItem",true),	
  	lists:map(fun(List) -> list_to_record(List,bazzarItem) end, BazzarItemList).
	

%% 获取金币的数量    return -> {ok,Gold} or {error,0}
getGoldByPlayerID(PlayerID) ->
	case mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT gold FROM player_gamedata WHERE id="++integer_to_list(PlayerID),true) of
		{ok,Result}->
			case Result of 
				[]->{error,0};
				[GoldList|_]->
					case GoldList of
						[]->{error,0};
						[Gold|_]->{ok,Gold}
					end
			end;
		{error,_}->{error,0}
	end.

%% 获取金币的数量和充值总额    return ->{ok,{Gold,RechargeAmmount}}  or {error,0}
getGoldAndRechargeAmmountByPlayerID(PlayerID) ->
	case mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT gold,rechargeAmmount FROM player_gamedata WHERE id="++integer_to_list(PlayerID),true) of
		{ok,Result}->
			case Result of 
				[]->{error,{}};
				[RowList|_]->
					case RowList of
						[]->{error,{}};
						_->
							[Gold|RemainRow] = RowList,
							case RemainRow of
								[]->{error,{}};
								[RechargeAmmount|_]->{ok,{Gold,RechargeAmmount}}
							end			
					end
			end;
		{error,_}->{error,{}}
	end.

%% 处理金币的变化 Cnt为gold减少的数量    return -> {ok,[]} or {error,[]}
reduceGoldByPlayerID(PlayerID,Cnt) ->
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"update player_gamedata set  gold=gold-"++integer_to_list(Cnt)++"  where id="++integer_to_list(PlayerID),true).
%% Cnt为gold增加的数量    return -> {ok,[]} or {error,[]}
addGoldByPlayerID(PlayerID,Cnt) ->
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"update player_gamedata set  gold=gold+"++integer_to_list(Cnt)++"  where id="++integer_to_list(PlayerID),true).
%% 充值时调用 Cnt为gold增加的数量    return -> {ok,[]} or {error,[]}
addGoldForChargeByPlayerID(PlayerID,Cnt) ->
	Ammount=Cnt,
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"update player_gamedata set  gold=gold+"++integer_to_list(Cnt)++
								" ,rechargeAmmount=rechargeAmmount+"++integer_to_list(Ammount)++
								"  where id="++integer_to_list(PlayerID),true).



%% 充值延时处理表
insertRechargeInfo(#rechargeInfo{}=R)->
 	L = mySqlProcess:record_to_list(R),
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_recharge_info,L,true).

updateRechargeInfoFail(OrderID,Platform)->
 	L = [?RECHARGE_INFO_FLAG_FAIL,OrderID,Platform],
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,update_recharge_info,L,true).

updateRechargeInfoOK(OrderID,Platform)->
 	L = [?RECHARGE_INFO_FLAG_OK,OrderID,Platform],
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,update_recharge_info,L,true).

rechargeInfo_list_to_record(List)->
	R=list_to_record(List,rechargeInfo),
	R1=setelement( #rechargeInfo.orderid, R, binary_to_list(R#rechargeInfo.orderid)),
	_R2=setelement( #rechargeInfo.account, R1, binary_to_list(R#rechargeInfo.account)).

get_RechargeInfo(PlayerID) ->
	{_,RechargeInfoList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM recharge_info WHERE playerid="++integer_to_list(PlayerID),true),	
  	lists:map(fun(List) -> rechargeInfo_list_to_record(List) end, RechargeInfoList).

%% ---------------------------------------------------
%% ------------排名相关 start ------------------------
%% 刷新排名表
refresh_TopList_Level(Level) ->
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"TRUNCATE TABLE top_player_level",true),
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"INSERT INTO top_player_level SELECT 0,id,`name`,camp,`level`,fightingCapacity,sex,
	(SELECT equipid FROM playerequipitem WHERE playerId=player_gamedata.id AND type=1 AND isEquiped=1) weapon,
	(SELECT equipid FROM playerequipitem WHERE playerId=player_gamedata.id AND type=6 AND isEquiped=1) coat
	FROM player_gamedata 
		WHERE `level`>="++integer_to_list(Level)++" and isDelete=0"++
		" ORDER BY `level` DESC,exp DESC LIMIT "++integer_to_list(?TOP_PLAYER_LEVEL_LIMIT),true).
	
refresh_TopList_Money(Money) ->
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"TRUNCATE TABLE top_player_money",true),
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"INSERT INTO top_player_money SELECT 0,id,`name`,camp,`level`,money,sex,
	(SELECT equipid FROM playerequipitem WHERE playerId=player_gamedata.id AND type=1 AND isEquiped=1) weapon,
	(SELECT equipid FROM playerequipitem WHERE playerId=player_gamedata.id AND type=6 AND isEquiped=1) coat
	FROM player_gamedata 
		WHERE `money`>="++integer_to_list(Money)++" and isDelete=0"++" ORDER BY `money` DESC,id LIMIT "++integer_to_list(?TOP_PLAYER_MONEY_LIMIT),true).

refresh_TopList_Fighting_Capacity(FightingCapacity) ->
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"TRUNCATE TABLE top_player_fighting_capacity",true),
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"INSERT INTO top_player_fighting_capacity SELECT 0,id,`name`,camp,`level`,fightingCapacity,sex, 
	(SELECT equipid FROM playerequipitem WHERE playerId=player_gamedata.id AND type=1 AND isEquiped=1) weapon,
	(SELECT equipid FROM playerequipitem WHERE playerId=player_gamedata.id AND type=6 AND isEquiped=1) coat
	FROM player_gamedata 
		WHERE `fightingCapacity`>="++integer_to_list(FightingCapacity)++" and isDelete=0"++
		" ORDER BY `fightingCapacity` DESC,id LIMIT "++integer_to_list(?TOP_PLAYER_FIGHTING_CAPACITY_LIMIT),true).

%% 排名，名称，排行，职业，等级，战斗力
top_level_list_to_record(List)->
	R=list_to_record(List,top_player_level),
	_R1=setelement( #top_player_level.name, R, binary_to_list(R#top_player_level.name)).

%% 排名，名称，排行，职业，金额
top_money_list_to_record(List)->
	R=list_to_record(List,top_player_money),
	_R1=setelement( #top_player_money.name, R, binary_to_list(R#top_player_money.name)).

%% 排名，名称，排行，职业，等级，战斗力
top_fighting_capacity_list_to_record(List)->
	R=list_to_record(List,top_player_fighting_capacity),
	_R1=setelement( #top_player_fighting_capacity.name, R, binary_to_list(R#top_player_fighting_capacity.name)).

get_TopList_Level() ->
	{_,TopList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT top,playerid,`name`,camp,`level`,fighting_capacity,sex,weapon,coat FROM top_player_level ORDER BY `top` LIMIT "++integer_to_list(?TOP_PLAYER_LEVEL_LOAD_LIMIT),true),
	lists:map(fun(List) -> top_level_list_to_record(List) end,TopList).
get_TopList_Money() ->
	{_,TopList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT top,playerid,`name`,camp,`level`,money,sex,weapon,coat FROM top_player_money ORDER BY `top` LIMIT "++integer_to_list(?TOP_PLAYER_MONEY_LOAD_LIMIT),true),
	lists:map(fun(List) -> top_money_list_to_record(List) end,TopList).
get_TopList_Fighting_Capacity() ->
	{_,TopList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT top,playerid,`name`,camp,`level`,fighting_capacity,sex,weapon,coat FROM top_player_fighting_capacity ORDER BY `top` LIMIT "++integer_to_list(?TOP_PLAYER_FIGHTING_CAPACITY_LOAD_LIMIT),true),
	lists:map(fun(List) -> top_fighting_capacity_list_to_record(List) end,TopList).

get_Player_Num_Of_Leve_High_than(Level)->
	{_,PlayerNum}=mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT count(*) as playerNum  FROM player_gamedata WHERE `level`>="++integer_to_list(Level),true),
	getColumnBySelectColumnResult(PlayerNum).

get_TopPlayer_Level(PlayerID)->
	{_,TopList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT top FROM top_player_level WHERE playerid="++integer_to_list(PlayerID),true),
	getColumnBySelectColumnResult(TopList).

	
get_TopPlayer_Money(PlayerID)->
	{_,TopList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT top FROM top_player_money WHERE playerid="++integer_to_list(PlayerID),true),
	getColumnBySelectColumnResult(TopList).


get_TopPlayer_Fighting_Capacity(PlayerID)->
	{_,TopList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT top FROM top_player_fighting_capacity WHERE playerid="++integer_to_list(PlayerID),true),
	getColumnBySelectColumnResult(TopList).

%% -----------------排名相关 end----------------------

%% ---------------------------------------------------
%% ------------平台发放物品相关 start ------------------------
%% 平台发放物品
insert_platformSendItem(#platform_sendItem{}=R)->
 	L = mySqlProcess:record_to_list(R),
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_platform_sendItem,L,true).

insert_platformSendItemEx(LevelMin,LevelMax,ItemList,Money,MoneyB,Gold,GoldB,Exp,TimeBegin,TimeEnd,Title,Content)->
 	L = {0,LevelMin,LevelMax,ItemList,Money,MoneyB,Gold,GoldB,Exp,?PLATFORM_SENDITEM_FLAG_VALID,TimeBegin,TimeEnd,Title,Content},
 	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,insert_platform_sendItem,L,true).

platform_sendItem_list_to_record(List)->
	?DEBUG_OUT("List:~p",[List]),
	R=list_to_record(List,platform_sendItem),
	?DEBUG_OUT("ListR:~p",[R]),
	R1=setelement( #platform_sendItem.itemList, R, binary_to_list(R#platform_sendItem.itemList)),
	R2=setelement( #platform_sendItem.title, R1, binary_to_list(R#platform_sendItem.title)),
	_R3=setelement( #platform_sendItem.content,R2, binary_to_list(R#platform_sendItem.content)).

get_platformSendItem()->
	{_,SendItemList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM platform_sendItem WHERE flag=1 AND timeBegin<"++integer_to_list(common:timestamp())++" AND timeEnd>"++integer_to_list(common:timestamp()),true),	
	
	?DEBUG_OUT("SendItemList:~p",[SendItemList]),
  	lists:map(fun(List) -> platform_sendItem_list_to_record(List) end, SendItemList).

%%设置某用户为gm
update_GmByPlayerName(GmLevel, PlayerName) ->
	L = [GmLevel,PlayerName],
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,set_playerGm,L,true).

%% 改userID
update_userIDByPlatUserId(SrcUserID,DesUserID) ->
	L = [SrcUserID,DesUserID],
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,updata_userIDByPlatUserId,L,true).
%% -----------------平台发放物品相关 end----------------------

%%护送
get_playerConvoy(PlayerID) ->
	{_,PlayerConvoyList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM playerconvoy where playerId="++integer_to_list(PlayerID),true),	
  	lists:map(fun(List) -> list_to_record(List,playerConvoy) end, PlayerConvoyList).
replacePlayerConvoy(#playerConvoy{}=R)->
 	L = mySqlProcess:record_to_list(R),
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,replace_playerconvoy,L,true).


%%禁言
update_forbidChatFlagByPlayerName(PlayerName,ForbidChatFlag) ->
	L = [ForbidChatFlag,PlayerName],
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,updata_forbitChatFlag,L,true).

%% 角色改名
update_playerNameByPlayerID(PlayerID,UserID,PlayerName) ->
	L = [PlayerName,PlayerID,UserID],
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,updata_playNameById,L,true).

%% 角色改保护密码
update_playerProtectPwdByPlayerID(PlayerID,UserID,Pwd) ->
	L = [Pwd,PlayerID,UserID],
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,updata_playProtectPwdById,L,true).

update_playerVipInfo(PlayerID,VipLevel,VipTimeExpire,VipTimeBuy) ->
	L = [VipLevel,VipTimeExpire,VipTimeBuy,PlayerID],
	mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,updata_playerVipInfo,L,true).

%% 旧保护密码是否正确
isRightOldProtectPwd(PlayerID,UserID,OldPwd)->
	{_,PlayerIdList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"select id from player_gamedata where userId = "++UserID++" and id ="++PlayerID++" and protectPwd ='"++OldPwd++"'",true),
	getColumnBySelectColumnResult(PlayerIdList).




%% -> 0 or MaxLevel
getMaxLevelByUserID(UserID) ->
	{_,PlayerLevelList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT max(LEVEL) FROM player_gamedata 
				WHERE userId="++integer_to_list(UserID)++" and isDelete=0",true),
	case getColumnBySelectColumnResult(PlayerLevelList) of
		undefined->0;
		Cnt->Cnt
	end.



getColumnBySelectColumnResult(ColumnResult)->
	case ColumnResult of
		[]->
			0;
		[ColumnList|_]->
			case ColumnList of
				[] -> 0;
				[Column|_] -> Column
			end
	end.

getOldRechargeRmbByAccount(Account,PlatId) ->
	{_,RechargeRmblList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT rechargeRmb FROM transfer_account_recharge where account = '"++Account++"'"++" and platId="++integer_to_list(PlatId),true),
	getColumnBySelectColumnResult(RechargeRmblList).

%% 0: not exist
isPlayerExistByIdAndUserId(PlayerId,UserId) ->
	{_,PlayerIdList} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT id FROM player_gamedata 
		WHERE id="++integer_to_list(PlayerId)++" and userId="++integer_to_list(UserId)++" and isDelete=0",true),
	getColumnBySelectColumnResult(PlayerIdList).


deleteTransferAccountRechargeRecord(Account,PlatId) ->
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"delete FROM transfer_account_recharge where account = '"++Account++"'"++" and platId="++integer_to_list(PlatId),true).



%% delete player, just set field isDelete = 1
deletePlayerById(PlayerID) ->
	mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"update player_gamedata set isDelete=1 where id="++integer_to_list(PlayerID),true).


getPlayerCntByUserId(UserID)->
	{_SuccOrErr,PlayerCntList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"select count(*) from player_gamedata 
			where userId = "++integer_to_list(UserID)++" and isDelete=0",true),
 	case getColumnBySelectColumnResult(PlayerCntList1) of
		undefined->0;
		Cnt->Cnt
	end.


%% ->{} or WordVarArray
getWordVarArray()->
	{_,WorldvarList1} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT varArray FROM worldvar_data where id="++integer_to_list(?WorldVarArray_DbId),true),
	case getColumnBySelectColumnResult(WorldvarList1) of
		0->{};
		Column->my_binary_to_term(Column,tuple )
	end.

saveWorldVarArray() ->
	case etsBaseFunc:getRecordField( ?GlobalMainAtom, ?GlobalMainID, #globalMain.varArray ) of
		undefined->ok;
		WorldVarArray->
			L = [?WorldVarArray_DbId,term_to_binary(WorldVarArray,[compressed])],
 			mysqlCommon:sqldb_exec_prepared_stat(?GAMEDB_CONNECT_POOL,replace_worldvar_data,L,true)
	end.
	
 	

	

register_prepared_stats(State) ->	
	State1 = mysql:add_prepare({prepare,insert_friend_gamedata,
          <<"INSERT INTO friend_gamedata(id,playerID,friendType,friendID,friendName,friendSex,friendFace,friendClassType,friendValue)
			 VALUES (?,?,?,?,?,?,?,?,?)">>}, State),
	State2 = mysql:add_prepare({prepare,replace_friend_gamedata,
          <<"REPLACE INTO friend_gamedata(id,playerID,friendType,friendID,friendName,friendSex,friendFace,friendClassType,friendValue) 
			VALUES (?,?,?,?,?,?,?,?,?)">>}, State1),
	State3 = mysql:add_prepare({prepare,update_friend_gamedata,
          <<"UPDATE friend_gamedata set friendType=?, friendValue=? where id=?">>}, State2),
	
	State4 = mysql:add_prepare({prepare,update_player_gamedata_by_player_and_others,
          <<"UPDATE player_gamedata set  map_data_id=?,mapId=?,
				level=?, camp=?, faction=?, sex=?, crossServerHonor=?, unionContribute=?, 
				competMoney=?, weekCompet=?, battleHonor=?, aura=?, charm=?, vip=?, 
				maxEnabledBagCells=?,maxEnabledStorageBagCells=?,storageBagPassWord=?,unlockTimes=?, 
				money=?, moneyBinded=?,  goldBinded=?, ticket=?, guildContribute=?, honor=?, credit=?,
				exp=?, lastOnlineTime=?, lastOfflineTime=?, isOnline=?, guildID=?,
				conBankLastFindTime=?, chatLastSpeakTime=?,
				outFightPet=?,pK_Kill_Value=?,pK_Kill_OpenTime=?,pk_Kill_Punish=?,playerMountInfo=?, 
				playerItemCDInfo=?,bloodPoolLife=?,playerItem_DailyCountInfo=?,petBloodPoolLife=?,
				fightingCapacity=?,fightingCapacityTop=?,platSendItemBits=?,gameSetMenu=?, varArray=?, protectPwd=?,
				reasureBowlData=?,taskSpecialData=?,exp15add=?,exp20add=?,exp30add=?,goldPassWord=?,goldPassWordUnlockTimes=?,
				vipLevel=?,vipTimeExpire=?,vipTimeBuy=?
				where id=?">>}, State3),
	State5 = mysql:add_prepare({prepare,update_guidid_of_player_gamedata,
          <<"UPDATE player_gamedata set   guildID=? where id=?">>}, State4),	
	State6 = mysql:add_prepare({prepare,update_player_gamedata_by_playerMapDBInfo,
          <<"UPDATE player_gamedata set life=?,x=?,y=?,mapCDInfoList=?,bloodPoolLife=? where id=?">>}, State5),
	State7 = mysql:add_prepare({prepare,insert_player_gamedata,
          <<"INSERT INTO  player_gamedata(id,name,userId, map_data_id,mapId,x,y,
				level, camp, faction, sex, crossServerHonor, unionContribute, 
				competMoney, weekCompet, battleHonor, aura, charm, vip, 
				maxEnabledBagCells,maxEnabledStorageBagCells,storageBagPassWord,unlockTimes, 
				money, moneyBinded, gold, goldBinded, ticket, guildContribute, honor, credit,
				life, exp, lastOnlineTime, lastOfflineTime, isOnline, createTime, guildID,
				conBankLastFindTime, chatLastSpeakTime,
				outFightPet, mapCDInfoList,pK_Kill_Value,pK_Kill_OpenTime,pk_Kill_Punish,playerMountInfo,
				playerItemCDInfo,bloodPoolLife,playerItem_DailyCountInfo,gmLevel,petBloodPoolLife,fightingCapacity,fightingCapacityTop,platSendItemBits,
				gameSetMenu,rechargeAmmount,varArray,forbidChatFlag,protectPwd,reasureBowlData,taskSpecialData,exp15add,exp20add,exp30add,isDelete,
				goldPassWord,goldPassWordUnlockTimes,vipLevel,vipTimeExpire,vipTimeBuy) 
				values(?,?,?,?,?,?,?,?,?,?,  ?,?,?,?,?,?,?,?,?,?,  ?,?,?,?,?,?,?,?,?,?,  ?,?,?,?,?,?,?,?,?,?,  ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?, ?,?,?,?,?,?,?,?,?,?, ?,?,?,?,?)">>}, State6),
	
	%-record(guildBaseInfo_gamedata, {id, chairmanPlayerID, level, faction, exp,
%						 chairmanPlayerName, guildName, affiche, createTime}).
	State8 = mysql:add_prepare({prepare,insert_guildBaseInfo_gamedata,
          <<"INSERT INTO  guildbaseinfo_gamedata(id, chairmanPlayerID, level, faction, exp,
				chairmanPlayerName, guildName, affiche, createTime) 
				values(?,?,?,?,?,?,?,?,?)">>}, State7),
	State9 = mysql:add_prepare({prepare,update_guildBaseInfo_gamedata,
          <<"UPDATE  guildbaseinfo_gamedata set chairmanPlayerID=?,level=?,faction=?,exp=?,chairmanPlayerName=?,guildName=?,affiche=? 
				where id=?">>}, State8),

	State10 = mysql:add_prepare({prepare,insert_guildMember_gamedata,
          <<"INSERT INTO  guildmember_gamedata(id, guildID, playerID, rank, playerName, playerLevel, playerClass, 
				contribute, contributeMoney, contributeTime, joinTime) 
				values(?,?,?,?,?,?,?,?,?,?,?)">>}, State9),
	State11 = mysql:add_prepare({prepare,update_guildMember_gamedata,
          <<"UPDATE  guildmember_gamedata set rank=?, playerLevel=?, playerClass=?, 
				contribute=?, contributeMoney=?, contributeTime=?
				where id=?">>}, State10),

	%-record(guildApplicant, {id, guildID, playerID, playerName, zhanli, level, class, joinTime}).
	State12 = mysql:add_prepare({prepare,insert_guildApplicant,
          <<"INSERT INTO  guildapplicant(id, guildID, playerID, playerName, zhanli, level, class, joinTime) 
				values(?,?,?,?,?,?,?,?)">>}, State11),

	State13 = mysql:add_prepare({prepare,insert_mailRecord,
          <<"INSERT INTO  mailRecord(id, type, recvPlayerID, isOpened, tiemOut, idSender, nameSender, 
				title, content, attachItemDBID1, attachItemDBID2, moneySend, moneyPay, mailTimerType ,mailRecTime) 
				values(?,?,?,?,?,?,?,?,?,?,  ?,?,?,?,?)">>}, State12),
	State14 = mysql:add_prepare({prepare,update_mailRecord,
          <<"UPDATE mailRecord set attachItemDBID1=?, attachItemDBID2=?,moneySend=?,moneyPay=? where id=?">>}, State13),
	
	%-record(playertask_gamedata, {id, taskID, playerID, state, aimProgressList}).
	State15 = mysql:add_prepare({prepare,insert_playerTask_gamedata,
          <<"INSERT INTO  playertask_gamedata(id, taskID, playerID, state, aimProgressList) 
				values(?,?,?,?,?)">>}, State14),
	State16 = mysql:add_prepare({prepare,replace_playerTask_gamedata,
          <<"REPLACE INTO  playertask_gamedata(id, taskID, playerID, state, aimProgressList) 
				values(?,?,?,?,?)">>}, State15),
	%-record(playerCompletedTask, {playerID, taskIDList} ).
	State17 = mysql:add_prepare({prepare,insert_playerCompletedTask,
          <<"INSERT INTO  playercompletedtask(playerID, taskIDList) values(?,?)">>}, State16),
	State18 = mysql:add_prepare({prepare,replace_playerCompletedTask,
          <<"REPLACE INTO  playercompletedtask(playerID, taskIDList) values(?,?)">>}, State17),
	
	State19 = mysql:add_prepare({prepare,insert_petProperty_gamedata,
          <<"INSERT INTO  petproperty_gamedata(id, data_id,	masterId,
						level, exp,	 name,titleId,	aiState,showModel,exModelId,soulLevel,soulRate,
					   attackGrowUp,defGrowUp,lifeGrowUp,isWashGrow,attackGrowUpWash,defGrowUpWash,lifeGrowUpWash,
					   convertRatio,exerciseLevel, moneyExrciseNum,exerciseExp, maxSkillNum,skills,life,
					   atkPowerGrowUp_Max,defClassGrowUp_Max,hpGrowUp_Max,benison_Value) 
			values(?,?,?,?,?,?,?,?,?,?,  ?,?,?,?,?,?,?,?,?,?,  ?,?,?,?,?,?,  ?,?,?,?)">>}, State18),
	State20 = mysql:add_prepare({prepare,replace_petProperty_gamedata,
          <<"REPLACE INTO  petproperty_gamedata(id, data_id,	masterId,
						level, exp,	 name,titleId,	aiState,showModel,exModelId,soulLevel,soulRate,
					   attackGrowUp,defGrowUp,lifeGrowUp,isWashGrow,attackGrowUpWash,defGrowUpWash,lifeGrowUpWash,
					   convertRatio,exerciseLevel, moneyExrciseNum,exerciseExp, maxSkillNum,skills,life,
					   atkPowerGrowUp_Max,defClassGrowUp_Max,hpGrowUp_Max,benison_Value) 
			values(?,?,?,?,?,?,?,?,?,?,  ?,?,?,?,?,?,?,?,?,?,  ?,?,?,?,?,?, ?,?,?,?)">>}, State19),
	%-record(playerSkill_gamedata, {playerId, skillId,coolDownTime, activationSkillID1, activationSkillID2, curBindedSkillID} ).
	State21 = mysql:add_prepare({prepare,insert_playerSkill_gamedata,
          <<"INSERT INTO  playerskill_gamedata(playerId, skillId,coolDownTime, activationSkillID1, activationSkillID2, curBindedSkillID) 
			values(?,?,?,?,?,?)">>}, State20),
	State22 = mysql:add_prepare({prepare,update_playerSkill_gamedata,
          <<"UPDATE playerskill_gamedata set coolDownTime=?, activationSkillID1=?, activationSkillID2=?, 
				curBindedSkillID=? where playerId=? and skillId=?">>}, State21),
	%-record(playerEquipItem,{id, playerId, equipid,type, quality, isEquiped,  propertyTypeValueArray}).
	State23 = mysql:add_prepare({prepare,insert_playerEquipItem,
          <<"INSERT INTO  playerEquipItem(id, playerId, equipid,type, quality, isEquiped,  propertyTypeValueArray) 
			values(?,?,?,?,?,?)">>}, State22),
	State24 = mysql:add_prepare({prepare,replace_playerEquipItem,
          <<"REPLACE INTO  playerEquipItem(id, playerId, equipid,type, quality, isEquiped,  propertyTypeValueArray) 
			values(?,?,?,?,?,?,?)">>}, State23),
	%record(playerEquipEnhanceLevel,{ playerId, ring, weapon,cap, shoulder, pants, hand, coat, belt, shoe, accessories, wing, fashion} ).
	State25 = mysql:add_prepare({prepare,insert_playerEquipEnhanceLevel,
          <<"INSERT INTO  playerEquipEnhanceLevel(playerId, ring, weapon,cap, shoulder, pants, hand, coat, belt, shoe, 
				accessories, wing, fashion) 
			values(?,?,?,?,?,?,?,?,?,?,  ?,?,?)">>}, State24),
	State26 = mysql:add_prepare({prepare,replace_playerEquipEnhanceLevel,
          <<"REPLACE INTO  playerEquipEnhanceLevel(playerId, ring, weapon,cap, shoulder, pants, hand, coat, belt, shoe, 
				accessories, wing, fashion) 
			values(?,?,?,?,?,?,?,?,?,?,  ?,?,?)">>}, State25),
	%-record(playerPetSealAhs, {playerId, skillIds}).
	State27 = mysql:add_prepare({prepare,insert_playerPetSealAhs,
          <<"INSERT INTO  playerPetSealAhs(playerId, skillIds) values(?,?)">>}, State26),
	State28 = mysql:add_prepare({prepare,replace_playerPetSealAhs,
          <<"REPLACE INTO  playerPetSealAhs(playerId, skillIds) values(?,?)">>}, State27),
	
	State29 = mysql:add_prepare({prepare,insert_r_itemDB,
          <<"INSERT INTO  r_itemDB(id, owner_type, owner_id, location, cell, amount, item_data_id, param1, param2,binded,expiration_time) 
			 values(?,?,?,?,?,?,?,?,?,?,  ?)">>}, State28),
	State30 = mysql:add_prepare({prepare,replace_r_itemDB,
          <<"REPLACE INTO  r_itemDB(id, owner_type, owner_id, location, cell, amount, item_data_id, param1, param2,binded,expiration_time) 
			 values(?,?,?,?,?,?,?,?,?,?,  ?)">>}, State29),
	% -record(r_playerBag, {id, location, cell, playerID, itemDBID, enable, lockID } ).
	State31 = mysql:add_prepare({prepare,insert_r_playerBag,
          <<"INSERT INTO  r_playerBag(id, location, cell, playerID, itemDBID, enable, lockID) values(?,?,?,?,?,?,?)">>}, State30),
	State32 = mysql:add_prepare({prepare,replace_r_playerBag,
          <<"REPLACE INTO  r_playerBag(id, location, cell, playerID, itemDBID, enable, lockID) values(?,?,?,?,?,?,?)">>}, State31),
	%-record(playerDaily, {id, playerID, dailyList}).
	State33 = mysql:add_prepare({prepare,insert_playerDaily,
          <<"INSERT INTO  playerDaily(playerID, activeValue, resetTime,dailyList) values(?,?,?,?)">>}, State32),
	State34 = mysql:add_prepare({prepare,replace_playerDaily,
          <<"REPLACE INTO  playerDaily( playerID, activeValue, resetTime,dailyList) values(?,?,?,?)">>}, State33),
	%-record( objectBuffDB, {id, buffList}),
	State35 = mysql:add_prepare({prepare,insert_objectBuffDB,
          <<"INSERT INTO  objectBuffDB(id, buffList) values(?,?)">>}, State34),
	State36 = mysql:add_prepare({prepare,replace_objectBuffDB,
          <<"REPLACE INTO  objectBuffDB(id, buffList) values(?,?)">>}, State35),
	State37 = mysql:add_prepare({prepare,replace_playeronhook,
          <<"REPLACE INTO  playeronhook(PlayerID, Content) values(?,?)">>}, State36),
	State38 = mysql:add_prepare({prepare,update_playeronhook,
          <<"UPDATE  playeronhook set Content=? where PlayerID=?">>}, State37),
	%-record(playerSignin, {playerId, alreadyDays,lastSignTime} ).
	State39 = mysql:add_prepare({prepare,replace_playerSignin,
          <<"REPLACE INTO  playerSignin(playerId, alreadyDays,lastSignTime) values(?,?,?)">>}, State38),
	%bazzarItem, {db_id,item_data_id,item_column, gold, binded_gold,init_count,remain_count,end_time} 
	State40 = mysql:add_prepare({prepare,insert_bazzarItem,
          <<"INSERT INTO  bazzarItem(db_id,item_data_id,item_column, gold, binded_gold,init_count,remain_count,end_time) values(?,?,?,?,?,?,?,?)">>}, State39),
	State41 = mysql:add_prepare({prepare,insert_recharge_info,
          <<"INSERT INTO  recharge_info(orderid,platform,account, userid, playerid,ammount,flag) values(?,?,?,?,?,?,?)">>}, State40),
	State42 = mysql:add_prepare({prepare,update_recharge_info,
          <<"UPDATE recharge_info SET flag=? WHERE orderid=? AND platform=?">>}, State41),
%% 	-record(playerConvoy, {playerId, taskID, beginTime,  remainTime, lowConvoyCD, highConvoyCD, 
%% 		curConvoyType, curCarriageQuality, deadCnt,  remainConvoyFreeRefreshCnt} ).
	State43 = mysql:add_prepare({prepare,replace_playerconvoy,
          <<"REPLACE INTO  playerconvoy(playerId, taskID, beginTime,  remainTime, lowConvoyCD, highConvoyCD,curConvoyType, curCarriageQuality, deadCnt,  remainConvoyFreeRefreshCnt) 
				values(?,?,?,?,?,?,?,?,?,?)">>}, State42),
	State44 = mysql:add_prepare({prepare,insert_platform_sendItem,
          <<"INSERT INTO  platform_sendItem(id,levelMin, levelMax, itemList,money,money_b,gold,gold_b,exp,`flag`,timeBegin,timeEnd,title,content) 
		values(?,?,?,?,?,?,?,?,?,?,?,?,?,?)">>}, State43),
	State45 = mysql:add_prepare({prepare,updata_forbitChatFlag,
          <<"UPDATE player_gamedata set  forbidChatFlag=? where NAME=?">>}, State44),
	State46 = mysql:add_prepare({prepare,updata_playNameById,
          <<"UPDATE player_gamedata set  NAME=? where id=? and userId=?">>}, State45),
	State47 = mysql:add_prepare({prepare,updata_playProtectPwdById,
          <<"UPDATE player_gamedata set  protectPwd=? where id=? and userId=?">>}, State46),
	State48 = mysql:add_prepare({prepare,updata_playerVipInfo,
          <<"UPDATE player_gamedata set  vipLevel=?,vipTimeExpire=?,vipTimeBuy=? where id=?">>}, State47),
	State49 = mysql:add_prepare({prepare,replace_bazzarItem,
          <<"REPLACE INTO  bazzarItem(db_id,item_data_id,item_column, gold, binded_gold,init_count,remain_count,end_time) values(?,?,?,?,?,?,?,?)">>}, State48),
	State50 = mysql:add_prepare({prepare,replace_worldvar_data,
          <<"REPLACE INTO  worldvar_data(id,varArray) values(?,?)">>}, State49),
	State51 = mysql:add_prepare({prepare,updata_userIDByPlatUserId,
          <<"UPDATE player_gamedata set  userId=? where userId=?">>}, State50),
	State52 = mysql:add_prepare({prepare,set_playerGm,
          <<"UPDATE player_gamedata SET gmLevel=? WHERE name = ?">>}, State51),
	_State53 = mysql:add_prepare({prepare,update_player_var_array,
          <<"UPDATE player_gamedata set  varArray=? where id=?">>}, State52).








	





	








