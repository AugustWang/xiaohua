%% Author: Administrator
%% Created: 2012-7-9
%% Description: TODO: Add description to db
-module(db).

%%
%% Include files
%%
-include("mysql.hrl").
-include("db.hrl").
-include("version.hrl").
-include("hdlt_logger.hrl").
-include("mapDefine.hrl").
-include("globalDefine.hrl").
-include_lib("stdlib/include/qlc.hrl").


%%
%% Exported Functions
%%
%%-export([init/0,createTable/2,writeRecord/1,keyIndex/1,matchObject/3, select/2, delete/2]).
-compile(export_all). 

%%
%% API Functions
%%

checkDbVersion() ->
	%% -> 0 or version
	case mySqlProcess:getDbVersion() of
		0->
			mySqlProcess:sqldb_write_record(#dbInfo{name="vesion", value=?DBVersion});	
		?DBVersion ->
			?LOG_OUT( "dbversion check succ" ),
			ok;
		BadVersion ->
			common:messageBox("mysql db version[~p] is not matched to server db version[~p]", [BadVersion,?DBVersion]),
			erlang:exit(0)
	end.


init() ->
try
	case mnesia:create_schema([node()]) of
		ok->ok;
		{error,{_, {already_exists, _}}} ->ok;
		{error,Reason1}->
			io:format("error,mnesia:create_schema,reason:~p ~n",[Reason1]),
			throw(-1)
	end,
	
	case mnesia:start() of	
		ok->ok;
		{error,Reason2}->
			io:format("error,mnesia:start,reason:~p ~n",[Reason2]),
			throw(-1)
	end,
	
	timer:sleep(100),
	
	case createMemTables( ?MemTables ) of
		true -> ok;
		_ -> throw(-1)
	end,
	
	
	setStartIndexForPersistentKeys(),
	
	%% for uniqueId init bug. maybe has other way to do this!!!!
	timer:sleep(100),  
	



	%mySqlProcess:sqldb_init(?GAMEDB_CONNECT_POOL), %% will start mysql driver by gameServerSup
	checkDbVersion(),
	ets:new( ?GlobalMainAtom, [set,public, named_table, {read_concurrency,true}, { keypos, #globalMain.id }] ),
	ets:insert( ?GlobalMainAtom, #globalMain{ id=?GlobalMainID, 
 								 is_forbid_login=false, 
 								 loginServerSocket=0, 
 								 gmLevel=mySqlProcess:getDbGmLevel(),
 								dailyTargetTypeTable=[] } ),

	
	%deleteTables( ?MemTables ),
	
	
			
					

	mapManager:loadMapCfg(),
	mapManager:loadSkillBuff(),
	worldBoss:loadPartyCfg(),
	active_battle:loadBattleCfg(),
	
	%% init task base
	task:taskBaseLoad(),
	
	itemModule:itemCfgLoad(),
	npcStore:npcStoreCfgLoad(),
	
	equipment:loadEquipmentConfig(),
	drop:loadDrop(),
	player:init(),
	vipFun:loadVipFunInfo(),
	guild:guildCfgLoad(),
	equipProperty:equipPropertyCfgLoad(),
	pet:loadPetCfg(),
	charDefine:loadAttributeRegentCfg(),
	charDefine:loadAttackFactorCfg(),
	globalSetup:loadGlobalSetup(),
	globalSetup:loadGlobalHPContainer(),
	globalSetup:loadGlobalCopyMapSA(),
	mount:loadMountBinTable(),
	daily:loadDailyCfg(),
	forbidden:loadforbiddenCfg(),
	playerSignIn:loadSignCfgTable(),
	convoy:loadCarriageCfg(),
	reasureBowl:loadReasureBowlCfg(),
	compound:loadCompoundCfg(),
	%mnesia:add_table_index( socketData, userId ),
	%mnesia:add_table_index( socketData, playerId ),
	
%% 	mnesia:add_table_index( playerTask, playerID ),
%% 	mnesia:add_table_index( playerTask, taskID ),
	
	true
catch
	_->false
end.









%% deleteTables( [] ) ->
%% 	ok;
%% 
%% deleteTables( Tables ) ->
%% 	[T|Tables1] = Tables,
%% 	[_|Tables2] = Tables1,
%% 	mnesia:delete_table(T),
%% 	deleteTables( Tables2 ),
%% 	ok.

createTables( [] ) ->
	true;

createTables( Tables ) ->
	[T|Tables1] = Tables,
	[B|Tables2] = Tables1,
	case createTable( T, B ) of
		true -> createTables(Tables2);
		_ -> false
	end.


createMemTables( [] ) ->
	true;
createMemTables( Tables ) ->
	[T|Tables1] = Tables,
	[B|Tables2] = Tables1,
	case createMemTable( T, B ) of
		true -> createMemTables(Tables2);
		_ -> false
	end.


openBinData( Name ) ->
	case file:read_file(Name) of
		{ok,Bin} ->
			binary_to_list(Bin);
		_ ->
			[]
	end.
openBinRawData( Name ) ->
	case file:read_file(Name) of
		{ok,Bin} ->
			 Bin;
		_ ->
			<<>>
	end.

loadFiled( Bin, 0) ->
	{[],Bin}
	;

loadFiled( Bin, Count) ->
	{Data1,Bin1}= messageBase:read_int(Bin),
	{Data2,Bin2} = loadFiled(Bin1,Count-1),
 	{[Data1|Data2],Bin2}
	.

loadString(Bin,Count,ArrayName)->
	case binary:split(Bin,<<"^">>) of
 	[<<Bin1/binary>>,<<BinLeft/binary>>]->
		OffStringArray = get(ArrayName),
		String = binary_to_list(Bin1),
		OffStringArray1 = array:set(Count,String,OffStringArray),
		put(ArrayName,OffStringArray1),
		loadString(BinLeft,Count+1,ArrayName);
	_->
		ok
	end.
%%获取str数组中Index偏移处的字串
getOffsetString(Index,ArrayName)->
	Array = get(ArrayName),
	array:get(Index, Array)
	.
%%读取.str文件，保存到数组里面
loadOffsetString(Name)->
	case file:read_file(Name) of
		{ok,Bin} ->
			 OffStringArray = array:new({default,null}),
			 put(Name,OffStringArray),
			 {_,<<Bin1/binary>>} =split_binary(Bin,3),
 			 loadString(Bin1,1,Name)
			 ;
		_ ->
			<<>>
	end.


loadRecord(0, _, _, Bin ) ->
	Bin;

loadRecord(N, FiledCount, Table, Bin ) ->
	
	{Data,Bin1} = loadFiled(Bin,FiledCount),
	
	Data1 = [ Table ] ++ [memKeyIndex(Table)] ++ Data, % not persistent
	
	R =  list_to_tuple(Data1),
	
	WriteResult = writeRecord( R ),
	case WriteResult of
		{atomic, ok}->ok;
		Error->?ERROR_OUT( "loadRecord Table[~p] false, Error[~p]", [Table, Error] )
	end,

	loadRecord(N-1, FiledCount, Table, Bin1 )
	.
	
seek(Bin, 0) ->
	Bin;

seek(Bin, Count) ->
	[_|Bin1] = Bin,
	seek(Bin1,Count-1)
	.

loadBinData( Bin, Table ) ->
	{_,Bin1}= messageBase:read_int(Bin),
	{FiledCount,Bin2}= messageBase:read_int(Bin1),
	{RecordCount,Bin3}= messageBase:read_int(Bin2),
	Bin4 =  seek( Bin3, FiledCount * 4 ),
	loadRecord( RecordCount, FiledCount, Table, Bin4 )
	.

loadRecordEx(0, _, _, _, _, Bin ) ->
	Bin;

loadRecordEx(N, Index, FiledCount, TableIndex, Table, Bin ) ->
	
	{Data,Bin1} = loadFiled(Bin,FiledCount),
	
	Data1 =  [ Table ] ++ [TableIndex*?PlayerBaseID+Index] ++ [TableIndex] ++ Data,
	
	R =  list_to_tuple(Data1),
	
	writeRecord( R ),
	
	loadRecordEx(N-1, Index+1, FiledCount, TableIndex, Table, Bin1 )
	.

loadBinDataEx( Bin, TableIndex, Table ) ->
	{_,Bin1}= messageBase:read_int(Bin),
	{FiledCount,Bin2}= messageBase:read_int(Bin1),
	{RecordCount,Bin3}= messageBase:read_int(Bin2),
	Bin4 =  seek( Bin3, FiledCount * 4 ),
	loadRecordEx( RecordCount, 1, FiledCount, TableIndex, Table, Bin4 )
	.

loadBinDataAllEx( [], _, _ ) ->
	[];

loadBinDataAllEx( Bin, TableIndex, Table) ->
	Bin1 = loadBinDataEx(Bin, TableIndex, Table),
	loadBinDataAllEx(Bin1, TableIndex+1, Table)
	.

readRecord(Tab, Key) ->
	Fun = fun()-> 
		mnesia:read(Tab,Key)		  
	end,	
	Result = mnesia:transaction(Fun),
	case Result of
		{atomic, ResultOfFun} ->
			ResultOfFun;
		_ ->
			[]		  
	end.
		
 

writeRecord(R) ->
	Fun = fun()-> 
		_Result = mnesia:write(R),
		ok
	end,	
	mnesia:transaction(Fun).

indexRead(Table, KeyValue, KeyName  ) ->
	Fun = fun()-> 
		mnesia:index_read(Table, KeyValue, KeyName)
	end,	
	Result = mnesia:transaction(Fun),
	case Result of
		{atomic, ResultOfFun} ->
			ResultOfFun;
		_ ->
			[]		  
	end.
	

matchObject(Table, Con) ->
	matchObject(Table,Con,read).

matchObject(Table, Con, Type) ->
	Fun = fun()-> 
		mnesia:match_object(Table, Con, Type)
	end,	
	{_,Data} = mnesia:transaction(Fun),
	Data.

setTableStartIndex(T,Index) ->
	mnesia:dirty_update_counter(uniqueId, T, Index)
	.




memKeyIndex(Name) ->
	Fun = fun()-> 
		mnesia:dirty_update_counter(uniqueIdMem, Name, 1)
	end,
	Result = mnesia:transaction(Fun),
	case Result of
		{atomic, ResultOfFun} ->
			ResultOfFun;
		{aborted, Reason} ->
			?ERROR_OUT( "memKeyIndex fail[~p]", [Reason] ),
			throw(-1)
	end.

%% memKeyIndex(Name) ->
%% 	mnesia:dirty_update_counter(uniqueIdMem, Name, 1)
%% 	.

%% createTable(T,F,Index) ->
%%   	case mnesia:create_table( T,  [{attributes, F}]) of
%% 	{atomic, ok} ->
%% 		setTableStartIndex( player, Index );		
%% 	_	->
%% 		ok		
%% 	end,
%% 	
%% 	mnesia:change_table_copy_type(T, node(), disc_copies)	
%% 	.

createTable(T,F) ->
	put("createTable_return",true),
  	case mnesia:create_table( T,  [{attributes, F}]) of
		{atomic, ok} -> true;
		{aborted, {already_exists, _}} ->true;
		{aborted, Reason} -> 
			io:format("error createTable,reason:~p ~n ",Reason),
			put("createTable_return",false)	
	end,
	mnesia:change_table_copy_type(T, node(), disc_copies),		
	get("createTable_return").

createMemTable(T,F) ->
 	case mnesia:delete_table(T) of
 		{atomic, ok} -> ok;
 		{aborted, Reason1} -> io:format("error,mnesia:delete_table,reason:~p ~n",[Reason1])
 	end,
	
	case T of
		uniqueIdMem -> Ret = mnesia:create_table( T,  [{type,set},{attributes, F}]);
		_ -> Ret = mnesia:create_table( T,  [{attributes, F}])
	end,
	
	
  	case Ret of
		{atomic, ok} -> true;
		{aborted, Reason2} -> 
			io:format("error,mnesia:create_table,reason:~p ~n",[Reason2]),
			false
	end.



select(T,F) ->
  	Fun = fun()-> 
		 mnesia:select(T,F)
	end,	
	mnesia:transaction(Fun).
 

delete(T, Key) ->
	Fun = fun()-> 
		 mnesia:delete({T,Key})
	end,	
	mnesia:transaction(Fun).


%% return all record in table
findAll(Table) ->
    Q = qlc:q([X || X <- mnesia:table(Table)]),
    Fun = fun() -> qlc:e(Q) end,
    case mnesia:transaction(Fun) of
		{atomic, Result} ->
			Result;
		_ ->
		  []
    end.


changeFiled( Table, Key, Field, Value ) ->
    Fun = fun()-> 
		DataList = mnesia:read(Table, Key),	  
		
		case DataList of
			[A] ->
				A1 = setelement( Field, A, Value ),
				mnesia:write(A1);
			_   ->
				noFoundData
		end		
	end,	
	mnesia:transaction(Fun).

getFiled( Table, Key, Field )->
    Fun = fun()-> 
		DataList = mnesia:read(Table, Key),	  
		case DataList of
			[A] ->
				element( Field, A );
			_   ->
				0
		end		
	end,	
	case mnesia:transaction(Fun) of
		{ atomic, Result }->Result;
		_->0
	end.

doQuery( Query )->
	MyFunc = fun()->qlc:e( Query ) end,
	{ SuccOrFail, Result } = mnesia:transaction( MyFunc ),
	case SuccOrFail of
		atomic->Result;
		_->[]
	end.


adjustMaxId(ObjectType,MaxId) ->
	case MaxId of
		0->map:makeObjectID( ObjectType, MaxId );
		_->MaxId
	end.

setStartIndexForOnePersistentKey(TableNameStr,IdName,ObjectType,Key) ->
	MaxId = getMaxIdFromDB(TableNameStr,IdName),
	MaxId1 = adjustMaxId(ObjectType,MaxId),
	mnesia:dirty_update_counter(uniqueIdMem, Key, MaxId1).

%% add by wenziyong
setStartIndexForPersistentKeys() ->
	%% init indexs which isn't persistent
	%mnesia:dirty_update_counter(uniqueIdMem, objectTimer, 0),
	%mnesia:dirty_update_counter(uniqueIdMem, objectEventManager, 0),
	%mnesia:dirty_update_counter(uniqueIdMem, mapObject, 0),
	%mnesia:dirty_update_counter(uniqueIdMem, mapMonster, 0),
	%mnesia:dirty_update_counter(uniqueIdMem, mapNpc, 0),
	%mnesia:dirty_update_counter(uniqueIdMem, mapObjectActor, 0),
	%mnesia:dirty_update_counter(uniqueIdMem, teamInfo, 0).

	%% init indexs which is persistent
	setStartIndexForOnePersistentKey("consalesitemdb","conSalesId",?Object_Type_consalesitemdb,consalesitemdb),	
	setStartIndexForOnePersistentKey("friend_gamedata","id",?Object_Type_friend_gamedata,friend_gamedata),
	setStartIndexForOnePersistentKey("guildapplicant","id",?Object_Type_guildapplicant,guildapplicant),	
	setStartIndexForOnePersistentKey("guildbaseinfo_gamedata","id",?Object_Type_Guild,guildbaseinfo_gamedata),	
	setStartIndexForOnePersistentKey("guildmember_gamedata","id",?Object_Type_guildmember_gamedata,guildmember_gamedata),	
	setStartIndexForOnePersistentKey("mailrecord","id",?Object_Type_Mail,mailrecord),	
	setStartIndexForOnePersistentKey("petproperty_gamedata","id",?Object_Type_Pet,petproperty_gamedata),	
	setStartIndexForOnePersistentKey("player_gamedata","id",?Object_Type_Player,player_gamedata),	
	%%setStartIndexForOnePersistentKey("playerdaily","id",?Object_Type_Daily,playerdaily),
	
	%% don't need allocate id of playerequipitem,in fact, the id is item id
	%Max_playerequipitem = getMaxIdFromDB("playerequipitem","id"),	
	%mnesia:dirty_update_counter(uniqueIdMem, playerequipitem, Max_playerequipitem),

	%% don't need allocate id of objectBuffDB because id of objectBuffDB is pet id or player id
	%-record( objectBuffDB, {id, buffList}),
	
	%% not save id of playerskill
	%Max_playerskill = getMaxIdFromDB("playerskill","id"),
	% getPlayerSkillID( PlayerID, SkillID ) not need it
	%mnesia:dirty_update_counter(uniqueIdMem, playerskill, Max_playerskill),
	
	setStartIndexForOnePersistentKey("playertask_gamedata","id",?Object_Type_Task,playertask_gamedata),
	setStartIndexForOnePersistentKey("r_itemdb","id",?Object_Type_Item,r_itemdb),
	setStartIndexForOnePersistentKey("r_playerbag","id",?Object_Type_r_playerbag,r_playerbag).


getMaxIdFromDB(TableName,FieldIdName)->
	% select max(conSalesId) from consalesitemdb;
	Sql = io_lib:format( "select max(~s) from ~s", [FieldIdName,TableName]),
	case mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, Sql,true) of
		{error, _ } ->throw(-1); 
		{_Ret,DbList1} ->
			case DbList1 of
				[] -> 0;
				[FirstRow|_] ->
					[MaxId|_] = FirstRow,
					case MaxId of
						undefined -> 0;
						_ ->MaxId
					end 					
			end
	end.
	


loadBinDataNotAddExtrafield( Bin, Table ) ->
	{_,Bin1}= messageBase:read_int(Bin),
	{FiledCount,Bin2}= messageBase:read_int(Bin1),
	{RecordCount,Bin3}= messageBase:read_int(Bin2),
	Bin4 =  seek( Bin3, FiledCount * 4 ),
	loadRecordNotAddExtrafield( RecordCount, FiledCount, Table, Bin4 )
	.

loadRecordNotAddExtrafield(0, _, _, Bin ) ->
	Bin;
loadRecordNotAddExtrafield(N, FiledCount, Table, Bin ) ->
	
	{Data,Bin1} = loadFiled(Bin,FiledCount),
	
	Data1 = [ Table ] ++ Data, 
	
	R =  list_to_tuple(Data1),
	
	WriteResult = writeRecord( R ),
	case WriteResult of
		{atomic, ok}->ok;
		Error->?ERROR_OUT( "loadRecord Table[~p] false, Error[~p]", [Table, Error] )
	end,

	loadRecordNotAddExtrafield(N-1, FiledCount, Table, Bin1 )
	.


%%
%% Local Functions
%%

