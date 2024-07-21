
-module(messageBase).
-compile(export_all). 

read_string(Bin) -> 
	{N, Bin1} = read_int16(Bin),
    lists:split(N,Bin1)
    .

read_bytes(Bin,Len) -> 
    lists:split(Len,Bin)
    .

read_int(Bin) -> 
	[Data1|Bin1] = Bin,
	[Data2|Bin2] = Bin1,
	[Data3|Bin3] = Bin2,
	[Data4|Bin4] = Bin3,
	
	Data5 = Data4*256*256*256+Data3*256*256+Data2*256+Data1,
	
	if Data5 >= 128*256*256*256 ->
		{-256*256*256*256+Data5,Bin4};	   
	true ->
		{Data5,Bin4}	
	end.


read_int16(Bin) -> 
    [Data1|Bin1] = Bin,
	[Data2|Bin2] = Bin1,
	
	Data3 = Data2*256+Data1,
	
	if Data3 >= 128*256 ->
		{-256*256+Data3,Bin2};	   
	true ->
		{Data3,Bin2}	
	end.



read_int8(Bin) -> 
	[Data1|Bin1] = Bin,
	if Data1 >= 128 ->
		{-256+Data1,Bin1};	   
	true ->
		{Data1,Bin1}	
	end.

read_n(0, Bin, _) ->  
	{[],Bin};

read_n(N, Bin, Fun) ->  
    {Data1,Bin1} = Fun(Bin),
	{Data2,Bin2} = read_n(N-1, Bin1, Fun),
	{[Data1]++Data2,Bin2}
	.

read_array(Bin,Fun) -> 
	{N,Bin1} = read_int16(Bin),
	read_n(N,Bin1,Fun)
    .

read_array2(Bin,Fun) -> 
	{N,Bin1} = read_int8(Bin),
	read_n(N,Bin1,Fun)
	.


write_string(Data) -> 
    Len = lists:flatlength(Data),
	Bin = list_to_binary(Data),
	<<Len:16/little,Bin/binary>>
	.

write_int(Data) -> 
    <<Data:32/little>>
	.

write_int16(Data) -> 
    <<Data:16/little>>        
    .

write_int8(Data) -> 
    <<Data:8>>        
    .
write_int64(Data) -> 
    <<Data:64/little>>        
    .

write_bytes(Data) -> 
    Bin = list_to_binary(Data),
    <<Bin/binary>>        
    .

write_array_data([],_) -> 
    <<>>
    ;

write_array_data(Data,Fun) -> 
	[Data1|Data2] = Data,
    Bin1 = Fun(Data1),
	Bin2 = write_array_data(Data2,Fun),
	<<Bin1/binary,Bin2/binary>>
    .

write_array(Data,Fun) -> 
	Len = lists:flatlength(Data),
	Bin2 = write_array_data(Data,Fun),
	<<Len:16/little,Bin2/binary>>
    .


sendPackage(Socket,Cmd,Bin)-> 
    Len = byte_size(Bin) + 4,	
	
	case get( "UserSocket" ) of
		Socket->
			NextSendPackCount = get( "NextSendPackCount" ),
			Cmd2 = ( Cmd bor ( NextSendPackCount bsl 11 ) ),
			case NextSendPackCount + 1 > 31 of
				true->put( "NextSendPackCount", 0 );
				false->put( "NextSendPackCount", NextSendPackCount + 1 )
			end;
		_->Cmd2 = Cmd
	end,

	Bin1 = <<Len:16/little, Cmd2:16/little, Bin/binary>>,
	case gen_tcp:send(Socket,Bin1) of
		ok ->ok;
		{error, Reason} -> 
			throw ( {'sendErrorBySocket', Reason} )
	end.


%%test

