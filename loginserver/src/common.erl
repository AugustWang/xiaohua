%% Author: Zhangdong
%% Created: 2012-8-8
%% Description: TODO: Add description to itemDB
-module(common).

%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% Include files
%%
-include("db.hrl").
-include("hdlt_logger.hrl").
-include("condition_compile.hrl").
for(N,N,F)->
	[F(N)];
for(I,N,F)->
	[F(I)|for(I+1,N,F)].

for_parama(N,N,F,Parama)->
	[F(N,Parama)];
for_parama(I,N,F,Parama)->
	[F(I,Parama)|for_parama(I+1,N,F,Parama)].

catStringID( String, ID )->
	StringValue = io_lib:format( "~p", [ID] ),
	StringValue2 = lists:flatten(StringValue),
	String2 = String ++ StringValue2,
	String2.

formatString( Value )->
	StringValue = io_lib:format( "~p", [Value] ),
	lists:flatten(StringValue).

messageBox(FormatString,ParamList)->
	StringValue = io_lib:format( FormatString, ParamList),
    StringValue2 = lists:flatten(StringValue),
    ?ERROR_OUT( "~p", [StringValue2] ),
	case ?Is_Debug_version of
		true->
			Widget = io_widget:start( self() ),
			io_widget:set_title(Widget, "error!" ),
			io_widget:insert( Widget, StringValue2);
		false->ok
	end.
	
testZero( Value )->
	case ( Value >= -0.0001 ) andalso ( Value < 0.0001 ) of
		true->0;
		false->Value
	end.

%%返回一个列表中某值是否存在
%%如果CallBack=0，表示直接查找Value在列表中的相等对象
findInList( List, Value, CallBack )->
	try
		case List =:= [] of
			true->throw({ false, {} });
			false->ok
		end,

		MyFunc = fun( Record )->
						 case CallBack =:= 0 of
							 true->
								 case Record =:= Value of
									 true->throw({ true, Record });
									 false->ok
								 end;
							 false->
								 case CallBack( Record, Value ) of
									 true->throw({ true, Record });
									 false->ok
								 end
						 end
				 end,
		lists:foreach( MyFunc, List ),
		{ false, {} }
	catch
		{ true, Return }->{ true, Return };
		_->{ false, {} }
	end.

%%实现两个list的 ++
addTwoList(L1,[Head|RemainList])->
	ResultList = [Head|L1],
	addTwoList(ResultList,RemainList);
addTwoList(L1,[])->
	L1.
	
%%对List遍历，返回结果是个List，并且是++拼接结果
listForEachAdd( PreFunc, [Head|RemainList],AccList)->
	AccList1 = addTwoList(AccList,PreFunc( Head )),
	listForEachAdd( PreFunc,RemainList ,AccList1);
listForEachAdd( _PreFunc, [],AccList )->
	AccList.


%% testthefunction()->
%% 	MyFunc = fun( Record )->
%% 					 A=Record*2,
%% 					 B=Record*3,
%% 					 [A|[B]]
%% 			 end,
%% 	List = common:listForEachAdd( MyFunc, [1,7,21] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 日期时间
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%返回UNIX时间，秒  sql中用UNIX_TIMESTAMP() FROM_UNIXTIME(1363425715) 转成日期字符串
timestamp() ->
    {M, S, _} = erlang:now(),  
    M * 1000000 + S.

%% 毫秒
milliseconds()->
	{M,S,U}  = erlang:now(),
    M*1000000000+1000*S + trunc(U/1000).

millisecondsByTime(Time)->
	{M,S,U}  = Time,
    M*1000000000+1000*S + trunc(U/1000).

%% 返回现在的unix时间 (秒)  %% seconds per day (86400)
getNowSeconds() ->
	datetime_to_timestamp(calendar:local_time()).

%%返回UTC时间，如果用到的时间跟客户端有些关系，还是utc比较好
getNowUTCSeconds()->
	datetime_to_timestamp(calendar:universal_time()).

%%根据date,time，返回unix时间
datetime_to_timestamp({Date, Time}) ->
    Seconds1 = calendar:datetime_to_gregorian_seconds({Date, Time}),
    Seconds2 = calendar:datetime_to_gregorian_seconds({{1970,1,1}, {0,0,0}}),
    Seconds1 - Seconds2.
%%返回今天开始的unix时间
getTodayBeginSeconds()->
	{{Year,Month,Day},{_Hour,_Min,_Sec}}=calendar:local_time(),
	datetime_to_timestamp( {{Year,Month,Day},{0,0,0}} ).

%%返回今天的小时
getNowHour() ->
	{_,{Hour,_Minute,_Second}}=calendar:now_to_local_time(erlang:now()),
	Hour.

%%由异常包裹的执行函数
beginTryCatchFunc( Func_Module, Func, Param, ExceptionFunc_Module, ExceptionFunc )->
	try
		case Param =:= 0 of
			true->Func_Module:Func();
			false->Func_Module:Func( Param )
		end
	catch
		_:_Why->
			messageBox( "Func_Module[~p] Func[~p] Param[~p] Why[~p] ExceptionFunc_Module[~p] ExceptionFunc[~p] stack[~p]", 
						[Func_Module, Func, Param, _Why, ExceptionFunc_Module, ExceptionFunc, erlang:get_stacktrace()] ),
			
			case (ExceptionFunc_Module =:= 0) or ( ExceptionFunc =:= 0) of
				true->ok;
				false->ExceptionFunc_Module:ExceptionFunc()
			end
	end.


%%读取列表中N偏移处的2字节有符号数据
list_get_int16(N,Bin)->
	{_,List} = lists:split(N,Bin),
	[Data1|Bin1] = List,
	[Data2|_Bin2] = Bin1,
	Data3 = Data2*256+Data1,
	if Data3 >= 128*256 ->
		-256*256+Data3;	   
	true ->
		Data3
	end.
%%读取列表中N偏移处的1字节有符号数据
list_get_int8(N,Bin)->
    {_,List} = lists:split(N,Bin),
    [Data1|_Bin1] = List,
	if Data1 >= 128 ->
		-256+Data1;	   
	true ->
		Data1
	end.
%%读取列表中N偏移处的字符串,返回字符串和长度,长度=字符串长度+2
list_get_string(N,Bin)->
	Count = list_get_int16(N,Bin),
	{_,List} = lists:split(N+2,Bin),
    {String,_} = lists:split(Count,List),
	{String,Count+2}.

%%读取列表数量为N的可变长列表,返回总列表,剩余列表,读取元素个数
list_get_n(0, Bin, _) ->  
	{[],Bin,0};

list_get_n(N, Bin, Fun) ->  
    {Data1,Bin1,Count} = Fun(Bin),
	{Data2,Bin2,Count1} = list_get_n(N-1, Bin1, Fun),
	Count3 = Count + Count1,
	{[Data1]++Data2,Bin2,Count3}.
%%读取列表中N偏移处的数组,数组头部2字节,返回数组数据,长度+2
list_get_array(N,Bin,Fun) -> 
	Count = list_get_int16(N,Bin),
	{_,List} = lists:split(N+2,Bin),
	{Data,_,Countn} = list_get_n(Count,List,Fun),
	{Data,Countn+2}
    .
%%读取列表中N偏移处的数组,数组头部1字节,返回数组数据,长度+1
list_get_array2(N,Bin,Fun) -> 
	Count = list_get_int8(N,Bin),
	{_,List} = lists:split(N+1,Bin),
	{Data,_,Countn} =list_get_n(Count,List,Fun),
	{Data,Countn+1}
	.
%%读取列表中N偏移处的数组,数组头部1字节,返回数组数据,长度+1,剩余列表
list_get_array3(N,Bin,Fun) -> 
	Count = list_get_int8(N,Bin),
	{_,List} = lists:split(N+1,Bin),
	{Data,Left,Countn} =list_get_n(Count,List,Fun),
	{Data,Countn+1,Left}
	.
%%读取列表中的字符串,头部2字节,返回字符串,剩余列表,长度+2
list_get_string(Bin) -> 
	{N, Bin1} = messageBase:read_int16(Bin),
    {String,Left} = lists:split(N,Bin1),
	{String,Left,N+2}
    .


%%读取bin数据中N偏移处的双字节
binary_read_int16(N,Bin)->
 	<<C:?INT16,_/binary>> = binary:part(Bin, N, 2),  
	{C,2}.
binary_read_int16(Bin)->
	<<C:?INT,_/binary>> = binary:part(Bin, 0, 2), 
    {_,<<Left/binary>>} = split_binary(Bin,2),
	{C,Left,2}.


binary_read_int16_left(N,Bin)->
	<<C:?INT16,_/binary>> = binary:part(Bin, N, 2),
	 {_,<<Left/binary>>} = split_binary(Bin,N+2),
	{C,Left,2}.


%%读取bin数据中N偏移处的64字节
binary_read_int64(N,Bin)->
 	<<C:?INT64,_/binary>> = binary:part(Bin, N, 8),  
	{C,8}.

binary_read_int64(Bin)->
	<<C:?INT64,_/binary>> = binary:part(Bin, 0, 8), 
    {_,<<Left/binary>>} = split_binary(Bin,8),
	{C,Left,8}.
%%读取bin数据中N偏移处的的单字节
binary_read_int8(N,Bin)->
	<<C:?INT8,_/binary>> = binary:part(Bin, N, 1),
	{C,1}.
binary_read_int(N,Bin)->
 	<<C:?INT,_/binary>> = binary:part(Bin, N, 4),  
	{C,4}.

binary_read_int(Bin)->
	<<C:?INT,_/binary>> = binary:part(Bin, 0, 4), 
    {_,<<Left/binary>>} = split_binary(Bin,4),
	{C,Left,4}.

binary_read_uint(N,Bin)->
 	<<C:?UINT,_/binary>> = binary:part(Bin, N, 4),  
	{C,4}.

binary_read_uint(Bin)->
	<<C:?UINT,_/binary>> = binary:part(Bin, 0, 4), 
    {_,<<Left/binary>>} = split_binary(Bin,4),
	{C,Left,4}.

%%读取bin数据中N偏移处的的字串 
binary_read_string(N,Bin) ->  
	<<Len:16/little,_/binary>> = binary:part(Bin,N,2),
	case Len of        
		0 ->            
			{[],2};      
		_ ->   
			Str = binary:part(Bin,N+2,Len),
			{binary_to_list(Str), Len+2}
	end.
	

%%读取bin数据中用户自定义的N个数据项
binary_read_n(0, Bin, _) ->  
	{[],Bin,0};

binary_read_n(N, Bin, Fun) ->  
    {Data1,Bin1,Count} = Fun(Bin),
	{Data2,Bin2,Count1} = binary_read_n(N-1, Bin1, Fun),
	Count3 = Count + Count1,
	{[Data1]++Data2,Bin2,Count3}.
%%读取bin数据中N偏移处的的头部是8位的变长数组
binary_read_array_head8(N,Bin,Fun) ->
	{_,<<Bin0/binary>>} = split_binary(Bin,N),
	case Bin0 of  
		<<Len:8/little, Bin1/binary>> ->       
			{Data,_Bin2,Count} = binary_read_n(Len,Bin1,Fun),
			{Data,Count+1};                  
		_R1 ->            
			{[],0}    
	end.
%%读取bin数据中N偏移处的的头部是16位的变长数组
binary_read_array_head16(N,Bin,Fun) ->
	{_,<<Bin0/binary>>} = split_binary(Bin,N),
	case Bin0 of  
		<<Len:16/little, Bin1/binary>> ->                   
			{Data,_Bin2,Count} = binary_read_n(Len,Bin1,Fun),
			{Data,Count+2};               
		_R1 ->            
			{[],0}    
	end.
%%读取bin数据中N偏移处的的头部是8位的变长数组,返回剩余的bin
binary_read_array_head8_left(N,Bin,Fun) ->
	{_,<<Bin0/binary>>} = split_binary(Bin,N),
	case Bin0 of  
		<<Len:8/little, Bin1/binary>> ->                   
			{Data,Bin2,Count} = binary_read_n(Len,Bin1,Fun),
			{Data,Count+1,Bin2};                  
		_R1 ->            
			{[],0,<<>>}    
	end.


%%构建用户ID 64位(前1位永为0保持正数(64)，11位服务器ID(53-63)，10位平台ID(43-52)，1位预留(42), 41位ID值(1-41))
makeUserId( LoginServerId, PlatformId, ID )->
	%%2047=11位服务器IDMask
	%%1023=10位平台IDMask
	%%16#1FFFFFFFFFF=41位ID值Mask
	OutID = ( ( LoginServerId band 2047 ) bsl 52 ) bor ( ( PlatformId band 1023 ) bsl 42 ) bor ( ID band 16#1FFFFFFFFFF ),
	OutID.

getMinValueByLsIdAndPlatformId(LoginServerId, PlatformId) ->
	OutID = ( ( LoginServerId band 2047 ) bsl 52 ) bor ( ( PlatformId band 1023 ) bsl 42 ),
	OutID.

getMaxValueByLsIdAndPlatformId(LoginServerId, PlatformId) ->
	OutID = ( ( LoginServerId band 2047 ) bsl 52 ) bor ( ( PlatformId band 1023 ) bsl 42 ) bor 16#1FFFFFFFFFF ,
	OutID.
