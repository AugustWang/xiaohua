%% file: mysql_test.erl
%% author: Yariv Sadan (yarivvv@gmail.com)
%% for license see COPYING

-module(mysql_test).
-compile(export_all).

-include("gamedatadb.hrl").
-include("db.hrl").

-define( fetchTimeOut, 20000).
%-define( fetchTimeOut, undefine).
-record(developer,{name,country}).
-record(developern,{id,value}).
-record(er_type_record,{name,value}).
-record(er_more_record,{name,country,more}).
-record(er_less_record,{name}).
-record(binary_table,{id,binary1}).


%#playerMapCDInfo{map_data_id=MapDataID, cur_count=0, cd_time=MapCDTime};

start_test()->
	init_connections_and_tables(),
	register_prepared_stats(),
	call_ini(1),
	timer:sleep(infinity),
	
	ok.


call_ini(0)->
	ok;
call_ini(Num)->	
	case Num rem 11 of
		0->init("binary_table",true,true); %%-record(binary_table,{id,binary1}).
		1->init("binary_table",true,true);
		2->init("developer2",false,true);
		3->init("developer3",false,true);
		4->init("developer4",false,true);
		5->init("developer5",false,true);
		6->init("developer6",false,true);
		7->init("developer7",false,true);
		8->init("developer8",false,true);
		9->init("developer9",false,true);
		10->init("developer10",false,true);
		_->ok
	end,
	call_ini(Num-1).
	

log_fun(Module, Line, Level, FormatFun) ->
	case Level of
		
		error->
		%debug->
    		{Format, Arguments} = FormatFun(),
    		io:format("~w:~b: "++ Format ++ "~n", [Module, Line] ++ Arguments);
		_->ok
	end.


init_connections_and_tables()->
 %% Start the MySQL dispatcher and create the first connection
    %% to the database. 'p1' is the connection pool identifier.
	mysql:start_link(),

    mysql:fetch(p1, <<"DELETE FROM developer">>),
	mysql:fetch(p1, <<"DELETE FROM friend_gamedata">>),
	mysql:fetch(p1, <<"DELETE FROM playermapdbinfo">>),
	
    mysql:fetch(p1, <<"DELETE FROM developer1">>),
	mysql:fetch(p1, <<"DELETE FROM developer2">>),
	mysql:fetch(p1, <<"DELETE FROM developer3">>),
	mysql:fetch(p1, <<"DELETE FROM developer4">>),
	mysql:fetch(p1, <<"DELETE FROM developer5">>),	
	mysql:fetch(p1, <<"DELETE FROM developer6">>),
	mysql:fetch(p1, <<"DELETE FROM developer7">>),
	mysql:fetch(p1, <<"DELETE FROM developer8">>),
	mysql:fetch(p1, <<"DELETE FROM developer9">>),
	mysql:fetch(p1, <<"DELETE FROM developer10">>),

	ok.


init(TableName,IsJustInsert,IsPrepareStat)->
	proc_lib:start(?MODULE, start_loop, [TableName,IsJustInsert,IsPrepareStat]),
	ok.

start_loop(TableName,IsJustInsert,IsPrepareStat)->
	proc_lib:init_ack(self()),
	loop(1,TableName,IsJustInsert,IsPrepareStat),
	ok.

insert_a_line(Times,TableName) ->
	Sql = io_lib:format("INSERT INTO ~s(id,value)
				VALUES (~p,~p)",[TableName,Times,Times]),
	mysqlCommon:sqldb_query(p1,Sql,true).







register_prepared_stats() ->	
	%% Register a prepared statement, example
    %mysql:prepare(insert_developer_country,
    %      <<"insert into developer values(?,?)">>),
	%mysql:prepare(insert_developer,<<"INSERT INTO developer(name,country) VALUES (?,?)">>),
	%-record(binary_table,{id,binary1}).
	mysql:prepare(insert_binary_table, <<"INSERT INTO binary_table(id,binary1) VALUES (?,?)">>),
	mysql:prepare(insert_friend_gamedata,
          <<"INSERT INTO friend_gamedata(id,playerID,friendType,friendID,friendName,friendSex,friendFace,friendClassType,friendValue) VALUES (?,?,?,?,?,?,?,?,?)">>),
	mysql:prepare(insert_developer1, <<"INSERT INTO developer1(id,value) VALUES (?,?)">>),
	mysql:prepare(insert_developer2,<<"INSERT INTO developer2(id,value) VALUES (?,?)">>),
	mysql:prepare(insert_developer3,<<"INSERT INTO developer3(id,value) VALUES (?,?)">>),
	mysql:prepare(insert_developer4, <<"INSERT INTO developer4(id,value) VALUES (?,?)">>),
	mysql:prepare(insert_developer5,<<"INSERT INTO developer5(id,value) VALUES (?,?)">>),
	mysql:prepare(insert_developer6,<<"INSERT INTO developer6(id,value) VALUES (?,?)">>),
	mysql:prepare(insert_developer7, <<"INSERT INTO developer7(id,value) VALUES (?,?)">>),
	mysql:prepare(insert_developer8,<<"INSERT INTO developer8(id,value) VALUES (?,?)">>),
	mysql:prepare(insert_developer9,<<"INSERT INTO developer9(id,value) VALUES (?,?)">>),
	mysql:prepare(insert_developer10,<<"INSERT INTO developer10(id,value) VALUES (?,?)">>),
	
	mysql:prepare(update_developer1,
          <<"UPDATE developer1 set value=? where id=?">>).
	
	



execute_prepared_statement(PoolId,PreparedStat,L) ->
	%mysql:execute(PoolId, PreparedStat, L).
	mysqlCommon:sqldb_exec_prepared_stat(PoolId, PreparedStat, L,true).
	
%loop(2147483647,_,_IsJustInsert,_IsPrepareStat)->
loop(2,_,_IsJustInsert,_IsPrepareStat)->
	io:format("exit from loop, success"),
	ok;
loop(Times,TableName,IsJustInsert,IsPrepareStat)->	
	case IsPrepareStat of
		true->
			case TableName of
			"binary_table" ->
				Str="abc0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789abc",
				Bin = term_to_binary(Str,[compressed]),
				execute_prepared_statement(p1,insert_binary_table,[Times,Bin]),
				{_,BinaryTableList} =  mysqlCommon:sqldb_query(p1,"SELECT * FROM binary_table where id=1",false),
				case BinaryTableList of
					[]->ok;
					[BinaryTableList1|_]->
						BinaryTableRecord = mySqlProcess:list_to_record(BinaryTableList1,binary_table),
						try 
							Str1 = binary_to_term(BinaryTableRecord#binary_table.binary1),
							io:format("Str1:~p ~n",[Str1])
						catch
							_:Why->io:format("binary_to_term exception why:~p ~n",[Why])
						end,
							
						timer:sleep(100000)
					
				end;

					
				
			"playermapdbinfo"-> 
				%-record(friend_gamedata, {id,playerID,friendType,friendID,friendName,friendSex,friendFace,friendClassType,friendValue}).
				%FRecord = #friend_gamedata{id=1,playerID=829384,friendType=1,friendID=1737498,friendName="testplayer",
				%		friendSex=1,friendFace=1,friendClassType=0,friendValue=0},	
				%execute_prepared_statement(p1,insert_friend_gamedata,mySqlProcess:record_to_list(FRecord));

				%-record( playerMapDBInfo, {id, hp, x, y, mapCDInfoList} ).
				%#playerMapCDInfo{map_data_id=MapDataID, cur_count=0, cd_time=MapCDTime};
				MapCDInfoList = [#playerMapCDInfo{map_data_id=1, cur_count=2, cd_time=3},#playerMapCDInfo{map_data_id=4, cur_count=5, cd_time=6}],
				%MapCDInfoList1 = term_to_binary(MapCDInfoList),
				Record = #playerMapDBInfo{id=1, hp=100, x=200, y=300, mapCDInfoList=MapCDInfoList},
				
				%Record2 = setelement( #playerMapDBInfo.mapCDInfoList, Record, MapCDInfoList),
				L1 = mySqlProcess:record_to_list(Record),
				mysql:prepare(insert_playermapdbinfo,<<"INSERT INTO playerMapDBInfo(id, hp, x, y, mapCDInfoList) VALUES (?,?,?,?,?)">>),
				execute_prepared_statement(p1,insert_playermapdbinfo,L1),
				timer:sleep(100),
				{_SuccOrErr0,PlayerMapInfoList} =  mysqlCommon:sqldb_query(p1,"SELECT * FROM playerMapDBInfo where id=1",false),
				case PlayerMapInfoList of
					[]->ok;
					[PlayerMapInfoList1|_]->
						PlayerMapInfoRecord = mySqlProcess:list_to_record(PlayerMapInfoList1,playerMapDBInfo),
						case PlayerMapInfoRecord#playerMapDBInfo.mapCDInfoList of
							undefined->put( "on_selPlayer_mapCDInfoList,", [] );
							0->put( "on_selPlayer_mapCDInfoList,", [] );
							_->
								MapCDInfoList = binary_to_term(PlayerMapInfoRecord#playerMapDBInfo.mapCDInfoList),
								%{ MapCDInfoList } = mySqlProcess:unSerializationData( PlayerMapInfoRecord#playerMapDBInfo.mapCDInfoList ),
								put( "on_selPlayer_mapCDInfoList,", MapCDInfoList )
						end
				end;

				
				
				 
				%DeveloperRecord = #developer{name="Swe''den",country="%W,iger,"},
				%-record(er_more_record,{name,country,more}).
				%DeveloperRecord = #er_more_record{name="Swe''den",country="%W,iger,",more=Times},	
				%execute_prepared_statement(p1,insert_developer,mySqlProcess:record_to_list(DeveloperRecord)),
				%DeveloperRecord1 = #developer{name="Swe''den",country="%W,iger,"},
				%execute_prepared_statement(p1,insert_developer,mySqlProcess:record_to_list(DeveloperRecord1));

			"developer1" ->
				%DevelopernRecord = #developern{id=Times,value=Times},
				%-record(er_type_record,{name,value}).
				DevelopernRecord = #developern{id=2,value=2},
				execute_prepared_statement(p1,insert_developer1,mySqlProcess:record_to_list(DevelopernRecord)),
				mysqlCommon:sqldb_query(p1, "delete from developer1 where id="++integer_to_list(3),true),
				mysqlCommon:sqldb_exec_prepared_stat(p1,update_developer1, [100,3],true),
				DevelopernRecord100 = #er_type_record{name="abc",value=5},			
				execute_prepared_statement(p1,insert_developer1,mySqlProcess:record_to_list(DevelopernRecord100));
				
			"developer2"->
				%DevelopernRecord = #developern{id=Times,value=Times},
				%-record(er_less_record,{name}).
				DevelopernRecord = #er_less_record{name=Times},
				execute_prepared_statement(p1,insert_developer2,mySqlProcess:record_to_list(DevelopernRecord));
			"developer3"->
				DevelopernRecord = #developern{id=Times,value=Times},
				execute_prepared_statement(p1,insert_developer3,mySqlProcess:record_to_list(DevelopernRecord));
			"developer4"->
				DevelopernRecord = #developern{id=Times,value=Times},
				execute_prepared_statement(p1,insert_developer4,mySqlProcess:record_to_list(DevelopernRecord));
			"developer5"->
				DevelopernRecord = #developern{id=Times,value=Times},
				execute_prepared_statement(p1,insert_developer5,mySqlProcess:record_to_list(DevelopernRecord));

			"developer6"->
				DevelopernRecord = #developern{id=Times,value=Times},
				execute_prepared_statement(p1,insert_developer6,mySqlProcess:record_to_list(DevelopernRecord));
			"developer7"->
				DevelopernRecord = #developern{id=Times,value=Times},
				execute_prepared_statement(p1,insert_developer7,mySqlProcess:record_to_list(DevelopernRecord));
			"developer8"->
				DevelopernRecord = #developern{id=Times,value=Times},
				execute_prepared_statement(p1,insert_developer8,mySqlProcess:record_to_list(DevelopernRecord));
			"developer9"->
				DevelopernRecord = #developern{id=Times,value=Times},
				execute_prepared_statement(p1,insert_developer9,mySqlProcess:record_to_list(DevelopernRecord));
			"developer10"->
				DevelopernRecord = #developern{id=Times,value=Times},
				execute_prepared_statement(p1,insert_developer10,mySqlProcess:record_to_list(DevelopernRecord));
			_->
				ok
			end;
		false->
			insert_a_line(Times,TableName)
	end,
	
	try
	case IsJustInsert of 
		true->ok;
		false->
			timer:sleep(100),
			%% Execute a query (using a binary)
			Sql2 = io_lib:format("SELECT * FROM ~s where id=~p",[TableName,Times]),
			Sql3 = list_to_binary(Sql2),
			case mysql:fetch(p1, Sql3,?fetchTimeOut) of
				{data, MysqlRes1}->
					AllRows   = mysql:get_result_rows(MysqlRes1),
					case AllRows of
						%%[Row|[]]->
						[Row|_]->
							case lists:nth(2, Row) =:= Times of
								true->
									%io:format("--------Value: ~p~n", [lists:nth(2, Row)]),
									ok;
								false->
									io:format("--------error,value:~p,Times:~p ~n", [lists:nth(2, Row),Times])
									%erlang:exit(valueError)
							end;
						_->
							io:format("--------error,don't get any row,~p,Times:~p MysqlRes:~p ~n", [AllRows,Times,MysqlRes1])
							%erlang:exit(valueError)
					end;
			
				{error, MysqlRes1}->
					%io:format("------select--error MysqlRes1: ~p~n", [MysqlRes1]),
					Reason1    = mysql:get_result_reason(MysqlRes1),
					ErrCode1   = mysql:get_result_err_code(MysqlRes1),
					SqlState1 = mysql:get_result_err_sql_state(MysqlRes1),
					io:format("------insert--error: ~s ,~p,  ~s~n", [Reason1,ErrCode1,SqlState1]);
					%erlang:exit(fetchError);
				{updated, _MysqlRes1}->
					io:format("ERROR------select--error return insert result,~n");
				Unkown1->
					io:format("------select--error Unkown: ~p~n", [Unkown1])
		end
	end

	catch
        _:Why1->
            io:format( "select exeption ~p ~n",[Why1])		
    end,
	loop(Times+1,TableName,IsJustInsert,IsPrepareStat).





test() ->
    
    %% Start the MySQL dispatcher and create the first connection
    %% to the database. 'p1' is the connection pool identifier.
    mysql:start_link(p1, "192.168.1.10", "root", "bear", "test"),

    %% Add 2 more connections to the connection pool
    mysql:connect(p1, "192.168.1.10", undefined, "root", "bear", "test",
		  true),
    mysql:connect(p1, "192.168.1.10", undefined, "root", "bear", "test",
		  true),
    
    mysql:fetch(p1, <<"DELETE FROM developer">>),

    mysql:fetch(p1, <<"INSERT INTO developer(name, country) VALUES "
		     "('Claes (Klacke) Wikstrom', 'Sweden'),"
		     "('Ulf Wiger', 'USA')">>),

	%% Register a prepared statement
    mysql:prepare(insert_developer_country,
          <<"insert into developer values(?,?)">>),

    %% Execute the prepared statement
    mysql:execute(p1, insert_developer_country, [<<"Swe''den">>, <<"%W''iger">>]),

    %% Execute a query (using a binary)
    Result1 = mysql:fetch(p1, <<"SELECT * FROM developer">>),
    io:format("Result1: ~p~n", [Result1]),
    
    %% Register a prepared statement
    mysql:prepare(update_developer_country,
		  <<"UPDATE developer SET country=? where name like ?">>),
    
    %% Execute the prepared statement
    mysql:execute(p1, update_developer_country, [<<"Sweden">>, <<"%Wiger">>]),
    
    Result2 = mysql:fetch(p1, <<"SELECT * FROM developer">>),
    io:format("Result2: ~p~n", [Result2]),
    
    mysql:transaction(
      p1,
      fun() -> mysql:fetch(<<"INSERT INTO developer(name, country) VALUES "
			    "('Joe Armstrong', 'USA')">>),
	       mysql:fetch(<<"DELETE FROM developer WHERE name like "
			    "'Claes%'">>)
      end),

    Result3 = mysql:fetch(p1, <<"SELECT * FROM developer">>),
    io:format("Result3: ~p~n", [Result3]),

    ok.
    
    
