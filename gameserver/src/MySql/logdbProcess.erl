%% Author: wenziyong
%% Created: 2013-2-6
%% Description: TODO: Add description to main
-module(logdbProcess).

%%
%% Include files
%%
-include("mysql.hrl").
-include("logdb.hrl").
-include("hdlt_logger.hrl").
-include("db.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

%-behaviour(gen_server).

%-export([start_link/0]).
%-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
%-export([register_prepared_stats/0]).


%start_link() ->
%	gen_server:start_link({local,logdbProcess_PID},?MODULE, [], [{timeout,5000}]).

%init([]) ->
%    {ok, {}}.


%handle_call(_Request, _From, State) ->
%    {noreply, ok, State}.

%handle_cast(_Msg, State) ->
%    {noreply, State}.

%terminate(_Reason, _State) ->
%    ok.

%code_change(_OldVsn, State, _Extra) ->
%    {ok, State}.



%handle_info(Info, StateData)->	
%	put( "infoResult", true ),
%	try
%	case Info of
%		{playerlogout_log, Msg }->
%			on_playerlogout_log( Msg );
%		{quit}->
%			put( "infoResult", false );
%		_->?DEBUG_OUT( "logdbProcess receive error msg" )
%	end,
	
%	case get( "infoResult" )of
%		true->{noreply, StateData};
%		false->{stop, normal, StateData}
%	end
	
%	catch
%		_:_Why->	
%			common:messageBox("ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
%						[?MODULE,_Why, erlang:get_stacktrace()] ),

%			{noreply, StateData}
%	end.

%on_playerlogout_log( Msg )->
%	sqldb_write_record(Msg).



%sqldb_write_record(Record)->
%	case element( 1, Record ) of
		%% add by wenziyong, when create db, please uncomment
		%playerlogout_log->
		%	sqldb_write_playerlogout_log(Record);
%		_->
%			?DEBUG_OUT("module:[~p],sqldb_write_record not handle msg:[~p]", [?MODULE,Record])
%	end.



%sqldb_write_playerlogout_log(Playerlogout_log)->
%    try
%		Sql = io_lib:format("INSERT INTO playerlogout_log(inserttime,userId,rolename, rolelevel,money,moneyBinded,gold,goldBinded,life,exp)
%				VALUES (~p,~p,'~s',~p, ~p,~p, ~p,~p,~p, ~p)",mySqlProcess:record_to_list(Playerlogout_log)),
%		mysqlCommon:sqldb_query( ?LOGDB_CONNECT_POOL,lists:flatten(Sql),false )
%	catch
%	  _->{error, [] }
%    end.


write_log_online_record(Count) ->
	Log = #log_online_record{time=common:timestamp(),count = Count},
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_online_record, mySqlProcess:record_to_list(Log),false).    

write_log_player_task(?LOG_PLAYER_TASK_ACCEPT,UserID,PlayerID,TaskID,Level) ->
	Log = #log_player_task{ userid=UserID,playerid=PlayerID,taskid=TaskID,level=Level,flag=?LOG_PLAYER_TASK_ACCEPT,time=common:timestamp()}, 
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_player_task,mySqlProcess:record_to_list(Log),false);
write_log_player_task(?LOG_PLAYER_TASK_COMMIT,UserID,PlayerID,TaskID,Level) ->
	Log = #log_player_task{ userid=UserID,playerid=PlayerID,taskid=TaskID,level=Level,flag=?LOG_PLAYER_TASK_COMMIT,time=common:timestamp()}, 
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_player_task,mySqlProcess:record_to_list(Log),false);
write_log_player_task(?LOG_PLAYER_TASK_CANCEL,UserID,PlayerID,TaskID,Level) ->
	Log = #log_player_task{ userid=UserID,playerid=PlayerID,taskid=TaskID,level=Level,flag=?LOG_PLAYER_TASK_CANCEL,time=common:timestamp()}, 
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_player_task,mySqlProcess:record_to_list(Log),false).    

write_log_player_login(?LOG_PLAYER_ONLINE,#player{}=Player) ->
	Log = #log_player_login{ userid = Player#player.userId, 
				 playerid = Player#player.id,
				 level = Player#player.level,
				 money = Player#player.money,
				 money_b = Player#player.moneyBinded,
				 gold = Player#player.gold,
				 gold_b = Player#player.goldBinded,
				 exp = Player#player.exp,
				 life = Player#player.life,
				 flag=?LOG_PLAYER_ONLINE,
				 time=common:timestamp()},
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_player_login, mySqlProcess:record_to_list(Log),false);
write_log_player_login(?LOG_PLAYER_OFFLINE,#player{}=Player) ->
	Log = #log_player_login{ userid = Player#player.userId, 
				 playerid = Player#player.id,
				 level = Player#player.level,
				 money = Player#player.money,
				 money_b = Player#player.moneyBinded,
				 gold = Player#player.gold,
				 gold_b = Player#player.goldBinded,
				 exp = Player#player.exp,
				 life = Player#player.life,
				 flag=?LOG_PLAYER_OFFLINE,
				 time=common:timestamp()},
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_player_login, mySqlProcess:record_to_list(Log),false).    

write_log_player(PlayerID,Name,Camp,Sex) ->
	Log = #log_player{ playerid=PlayerID,name=Name,camp=Camp,sex=Sex, time=common:timestamp()},
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_player,mySqlProcess:record_to_list(Log),false).    

write_log_recharge_succ(OrderID,Platform,Account,UserID,PlayerID,Ammount) ->
	Log = #log_recharge{ orderid=OrderID,platform=Platform,account=Account,
				userid=UserID,playerid=PlayerID,ammount=Ammount,
				flag=?LOG_RECHARGE_SUCC,time=common:timestamp()},
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_recharge,mySqlProcess:record_to_list(Log),false).    

write_log_recharge_fail(OrderID,Platform,Account,UserID,PlayerID,Ammount) ->
	Log = #log_recharge{ orderid=OrderID,platform=Platform,account=Account,
				userid=UserID,playerid=PlayerID,ammount=Ammount,
				flag=?LOG_RECHARGE_FAIL,time=common:timestamp()},
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_recharge,mySqlProcess:record_to_list(Log),false).    

write_log_player_event(EventType,ParamTuple,#player{}=Player) when is_tuple(ParamTuple) ->
	Log = #log_player_event{userid = Player#player.userId,
							playerid = Player#player.id,
							level = Player#player.level,
							money = Player#player.money,
							money_b = Player#player.moneyBinded,
							gold = Player#player.gold,
							gold_b = Player#player.goldBinded,
							exp = Player#player.exp,
							life = Player#player.life,
							time = common:timestamp(),
						   	eventtype = EventType,									
							content = common:formatString(ParamTuple)
						   },			
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_player_event, mySqlProcess:record_to_list(Log),false).

%% 金币更改日志
write_log_gold_add(PlayerID,Gold_Old,Gold_Mod,Gold_New,Reason,Desc) ->
	Log = #log_gold{ playerid=PlayerID,flag=?LOG_GOLD_ADD,gold_old=Gold_Old,
				gold_mod=Gold_Mod,gold_new=Gold_New,reason=Reason,
				desc=Desc,time=common:timestamp()},
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_gold,mySqlProcess:record_to_list(Log),false).    

write_log_gold_dec(PlayerID,Gold_Old,Gold_Mod,Gold_New,Reason,Desc) ->
	Log = #log_gold{ playerid=PlayerID,flag=?LOG_GOLD_DEC,gold_old=Gold_Old,
				gold_mod=Gold_Mod,gold_new=Gold_New,reason=Reason,
				desc=Desc,time=common:timestamp()},
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_gold,mySqlProcess:record_to_list(Log),false).    

write_log_token_change(Tokentype,Relust,ChangeType,ParamTuple,Number,#player{}=Player) when is_tuple(ParamTuple) ->
	Log = #log_token_change{userid = Player#player.userId,
							playerid = Player#player.id,
							level = Player#player.level,
							money = Player#player.money,
							money_b = Player#player.moneyBinded,
							gold = Player#player.gold,
							gold_b = Player#player.goldBinded,
							exp = Player#player.exp,
							life = Player#player.life,
							time = common:timestamp(),
							tokentype = Tokentype,
							relust = Relust,
						   	changetype = ChangeType,									
							content = common:formatString(ParamTuple),
							number = Number
						   },			
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_token_change, mySqlProcess:record_to_list(Log),false).

write_log_exp_change(ChangeType,ParamTuple,Number,#player{}=Player) when is_tuple(ParamTuple) ->
	Log = #log_exp_change{userid = Player#player.userId,
							playerid = Player#player.id,
							level = Player#player.level,
							money = Player#player.money,
							money_b = Player#player.moneyBinded,
							gold = Player#player.gold,
							gold_b = Player#player.goldBinded,
							exp = Player#player.exp,
							life = Player#player.life,
							time = common:timestamp(),							
						   	changetype = ChangeType,									
							content = common:formatString(ParamTuple),
							number = Number
						   },			
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_exp_change, mySqlProcess:record_to_list(Log),false).

write_log_item_change(ChangeType,ChangeReson,ParamTuple,#r_itemDB{}=ItemDBData,#player{}=Player) ->
	case itemModule:getNeedSaveLogByDataId(ItemDBData#r_itemDB.item_data_id) of
		0->{ok, [] };
		_->
			Log = #log_item_change{userid = Player#player.userId,
									playerid = Player#player.id,							
									itemdataid = ItemDBData#r_itemDB.item_data_id,
								  	itemid = ItemDBData#r_itemDB.id,
									ownerid = ItemDBData#r_itemDB.owner_id,
									cell = ItemDBData#r_itemDB.cell,
									amount = ItemDBData#r_itemDB.amount,
									binded = ItemDBData#r_itemDB.binded,							
									time = common:timestamp(),							
								   	changetype = ChangeType,
								  	changereson = ChangeReson,								
									content = common:formatString(ParamTuple)
								   },			
			mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_item_change, mySqlProcess:record_to_list(Log),false)
	end.

write_log_recharge_ok(OrderID,Platform,Account,UserID,PlayerID,Ammount) ->
	Log = #log_recharge{ orderid=OrderID,platform=Platform,account=Account,
				userid=UserID,playerid=PlayerID,ammount=Ammount,
				flag=?LOG_RECHARGE_OK,time=common:timestamp()},
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_recharge,mySqlProcess:record_to_list(Log),false).    

write_log_mail_change(ChangeType,#mailRecord{}=Mail) ->
	Log = #log_mail_change{changetype = ChangeType,
						   id = Mail#mailRecord.id,
						   type = Mail#mailRecord.type,
						   recvPlayerID = Mail#mailRecord.recvPlayerID,
						   isOpened = Mail#mailRecord.isOpened,
						   tiemOut = Mail#mailRecord.tiemOut,
						   idSender = Mail#mailRecord.idSender,
						   nameSender = Mail#mailRecord.nameSender,
						   title = Mail#mailRecord.title,
						   attachItemDBID1 = Mail#mailRecord.attachItemDBID1,
						   attachItemDBID2 = Mail#mailRecord.attachItemDBID2,
						   moneySend = Mail#mailRecord.moneySend,
						   moneyPay = Mail#mailRecord.moneyPay,
						   mailTimerType = Mail#mailRecord.mailTimerType,
						   mailRecTime = Mail#mailRecord.mailRecTime},			
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_mail_change, mySqlProcess:record_to_list(Log),false).

write_log_player_machine(PlayerID,UserID,Platform,Machine) ->
	Log = #log_player_machine{playerid = PlayerID,
						   userid = UserID,						 
						   platform = Platform,
						   machine = Machine,
						   timelogin = common:timestamp(),
						   timelogout= 0 },			
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,insert_log_player_machine, mySqlProcess:record_to_list(Log),false).			


update_playerMachineLogout(Id) ->
	Timelogout = common:timestamp(),
	L = [Timelogout,Id],
	mysqlCommon:sqldb_exec_prepared_stat(?LOGDB_CONNECT_POOL,updata_player_machine_logout,L,true).

%% register_prepared_stats() ->	
%% 	mysql:prepare(insert_playerlogout_log,
%%           <<"INSERT INTO playerlogout_log(inserttime,userId,rolename, rolelevel,money,moneyBinded,gold,goldBinded,life,exp) 
%% 				VALUES (?,?,?,?, ?,?, ?,?,?,?)">>).

register_prepared_stats(State) ->	
	State1 = mysql:add_prepare({prepare,insert_log_online_record,
          <<"INSERT INTO log_online_record(time,count)
				VALUES (?,?)">>}, State),
	%-record(log_player_task,{userid,playerid,taskid, level,flag,time}).
	State2 = mysql:add_prepare({prepare,insert_log_player_task,
          <<"INSERT INTO log_player_task(userid,playerid,taskid,level,flag,time)
				VALUES (?,?,?,?,?,?)">>}, State1),
	State3 = mysql:add_prepare({prepare,insert_log_player_login,
          <<"INSERT INTO log_player_login(userid,playerid,level,money,money_b,gold,gold_b,exp,life,flag,time) 
				VALUES (?,?,?,?,?,?,?,?,?,?,?)">>}, State2),
	State4 = mysql:add_prepare({prepare,insert_log_player,
          <<"INSERT INTO log_player(playerid,name,camp,sex,time) 
				VALUES (?,?,?,?,?)">>}, State3),
	State5 = mysql:add_prepare({prepare,insert_log_recharge,
          <<"INSERT INTO log_recharge(orderid,platform,account,userid,playerid,ammount,flag,time) 
				VALUES (?,?,?,?,?,?,?,?)">>}, State4),
	State6 = mysql:add_prepare({prepare,insert_log_gold,
          <<"INSERT INTO log_gold(playerid,flag,gold_old,gold_mod,gold_new,reason,desc0,time) 
				VALUES (?,?,?,?,?,?,?,?)">>}, State5),
	State7 = mysql:add_prepare({prepare,insert_log_player_event,
          <<"INSERT INTO log_player_event(userid,playerid,level,money,money_b,gold,gold_b,exp,life,time,eventtype,content) 
				VALUES (?,?,?,?,?,?,?,?,?,?,?,?)">>}, State6),
	State8 = mysql:add_prepare({prepare,insert_log_token_change,
          <<"INSERT INTO log_token_change(userid,playerid,level,money,money_b,gold,gold_b,exp,life,time,tokentype,relust,changetype,content,number) 
				VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)">>}, State7),	
	State9 = mysql:add_prepare({prepare,insert_log_exp_change,
          <<"INSERT INTO log_exp_change(userid,playerid,level,money,money_b,gold,gold_b,exp,life,time,changetype,content,number) 
				VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)">>}, State8),
	State10 = mysql:add_prepare({prepare,insert_log_item_change,
          <<"INSERT INTO log_item_change(userid,playerid,itemdataid,itemid,ownerid,cell,amount,binded,time,changetype,changereson,content) 
				VALUES (?,?,?,?,?,?,?,?,?,?,?,?)">>}, State9),
	State11 = mysql:add_prepare({prepare,insert_log_mail_change,
          <<"INSERT INTO log_mail_change(`changetype`,`id`,`type`,`recvPlayerID`,`isOpened`,`tiemOut`,`idSender`,`nameSender`,`title`,`attachItemDBID1`,`attachItemDBID2`,`moneySend`,`moneyPay`,`mailTimerType`,`mailRecTime`) 
				VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)">>}, State10),
	State12 = mysql:add_prepare({prepare,insert_log_player_machine,
	          <<"INSERT INTO log_player_machine(`playerid`,`userid`,`platform`,`machine`,`timelogin`,`timelogout`) 
					VALUES (?,?,?,?,?,?)">>}, State11),
	_State13 = mysql:add_prepare({prepare,updata_player_machine_logout,
	          <<"UPDATE log_player_machine set  timelogout=? where id=? ">>}, State12).

isMachineExistByID(  Playerid,  Userid)->
	{_SuccOrErr,IdList} = mysqlCommon:sqldb_query(?LOGDB_CONNECT_POOL,"select id from log_player_machine where playerid = "++integer_to_list(Playerid)++" and userid="++integer_to_list(Userid)++" order by id desc limit 1 ",true),
	case IdList of
		[]->
			0;
		[IList|_]->
			case IList of
				[] -> 0;
				[Id|_] -> Id
			end
	end.

%% will use a process to create log table, and notice mysql dispatch process to register log prepare stats
%% %%创建log数据表
%% create_log_table(State,TimeStr)->
%%  	Sql = io_lib:format("CREATE TABLE `playerlogout_log~s` (
%% 		  `inserttime` int(4) DEFAULT NULL,
%% 		  `userId` int(4) DEFAULT NULL,
%% 		  `rolename` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
%% 		  `rolelevel` int(4) DEFAULT NULL,
%% 		  `money` int(4) DEFAULT NULL,
%% 		  `moneyBinded` int(4) DEFAULT NULL,
%% 		  `gold` int(4) DEFAULT NULL,
%% 		  `goldBinded` int(4) DEFAULT NULL,
%% 		  `life` int(4) DEFAULT NULL,
%% 		  `exp` int(4) DEFAULT NULL
%% 		) ENGINE=MyISAM DEFAULT CHARSET=utf8",[TimeStr]), 
%% 	Sql1 = list_to_binary(Sql),	
%% 	mysql:fetch_queries(?LOGDB_CONNECT_POOL, self(), State, [Sql1]).
