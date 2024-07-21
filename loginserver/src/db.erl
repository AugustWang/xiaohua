%% Author: Administrator
%% Created: 2012-7-9
%% Description: TODO: Add description to db
-module(db).

%%
%% Include files
%%
-include("mysql.hrl").
-include("db.hrl").
-include("hdlt_logger.hrl").
-include_lib("stdlib/include/qlc.hrl").

%%
%% Exported Functions
%%
%%-export([init/0,createTable/2,writeRecord/1,keyIndex/1,matchObject/3, select/2, delete/2]).
-compile(export_all). 

%%
%% API Functions
%%
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
	
	db:writeRecord( #globalMain{ id=?GlobalMainID, globalUserSocket=0, globalLoginUserTable=0 } ),
	
		
	true
catch
	_->false
end.




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


adjustMaxId(_ObjectType,LoginServerId,PlatformId,MaxId) ->
	case MaxId of
		0->
		   common:getMinValueByLsIdAndPlatformId(LoginServerId, PlatformId);
		_->MaxId
	end.



loadPlatformIdList(ListInfo,0)->
	ListInfo;
loadPlatformIdList(ListInfo,Num)->
	PlatformID = main:ini_ReadInt("LoginServer.txt",common:catStringID("PlatformID",Num),0),
	ListInfo1=[PlatformID|ListInfo],
	loadPlatformIdList(ListInfo1,Num-1).


%% add by wenziyong
setStartIndexForPersistentKeys() ->
	%% init indexs which is persistent	
	LoginServerId = main:ini_ReadInt("LoginServer.txt","LoginServerId",1 ),
	PlatformCount = main:ini_ReadInt("LoginServer.txt","PlatformCount",1 ),
	PlatformIdList = loadPlatformIdList([],PlatformCount),
	MyFunc = fun( PlatId )->
				setStartIndexForOnePersistentKey("user","id",LoginServerId,PlatId,0,PlatId)  %%key is platform id				 
			 end,
	lists:foreach( MyFunc, PlatformIdList ).
	
setStartIndexForOnePersistentKey(TableNameStr,IdName,LoginServerId,PlatformId,ObjectType,Key) ->
	MaxId = getMaxIdFromDB(TableNameStr,IdName,LoginServerId,PlatformId),
	MaxId1 = adjustMaxId(ObjectType,LoginServerId,PlatformId,MaxId),
	?DEBUG_OUT( "setStartIndexForOnePersistentKey key:~p,id:~p ", [Key,MaxId1] ),
	mnesia:dirty_update_counter(uniqueIdMem, Key, MaxId1).

getMaxIdFromDB(TableName,FieldIdName,LoginServerId,PlatformId)->
	Min = common:getMinValueByLsIdAndPlatformId(LoginServerId, PlatformId),
	Max = common:getMaxValueByLsIdAndPlatformId(LoginServerId, PlatformId),
	Sql = io_lib:format( "select max(~s) from ~s where ~s >= ~p and ~s <= ~p ", [FieldIdName,TableName,FieldIdName,Min,FieldIdName,Max]),
	?DEBUG_OUT( "getMaxIdFromDB sql ~s", [Sql] ),
	case mysqlCommon:sqldb_query(?LOGINDB_CONNECT_POOL, Sql,true) of
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
	

%%
%% Local Functions
%%

