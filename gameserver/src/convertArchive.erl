-module(convertArchive).

-include("mysql.hrl").
-include("db.hrl").
-include("variant.hrl").
-include("gamedatadb.hrl").

-compile(export_all). 


%%/* id is playerid or petid */
%% CREATE TABLE `objectbuffdb` (
%%   `id` bigint(8) NOT NULL,
%%   `buffList` varbinary(2048) DEFAULT NULL,
%%   UNIQUE KEY `id` (`id`)
%% ) ENGINE=MyISAM DEFAULT CHARSET=utf8;


start() ->
	mysql:start_link(),
	
	io:format("begin convert data, it's a long time, waiting....~n"),
	timer:sleep(1000*10),
	
	convertArchiveFrom5to6().


convertArchiveFrom5to6()->
		%% get all objectbuffdb
	case mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL,"SELECT * FROM objectbuffdb",true) of
		{error, _ } ->
			io:format("SELECT * FROM objectbuffdb fail ~n"),
			erlang:exit(selectFail);
		{ok,ObjectBuffDBList} ->
			ObjectBuffDBRecordList = lists:map(fun(List) -> mySqlProcess:objectBuffDB_list_to_record(List) end, ObjectBuffDBList),		
			Fun = fun(Record)->
					 Id = Record#objectBuffDB.id,
					 put("Start_Is_Changed",false),
					 MakeNewListFun = fun(Buff) ->
							BuffId = Buff#objectBuffDataDB.buff_id,												
							case BuffId of
								%%id是47->56, 的buff直接删掉，
							  	47->put("Start_Is_Changed",true),{};
							  	48->put("Start_Is_Changed",true),{};
							  	49->put("Start_Is_Changed",true),{};
							  	50->put("Start_Is_Changed",true),{};
							  	51->put("Start_Is_Changed",true),{};
							  	52->put("Start_Is_Changed",true),{};
							  	53->put("Start_Is_Changed",true),{};
							  	54->put("Start_Is_Changed",true),{};
							  	55->put("Start_Is_Changed",true),{};
							  	56->put("Start_Is_Changed",true),{};
								%%61->63的buff删掉，并给玩家变量增加持续时间
							  	61->
									put("Start_Is_Changed",true),
									updatePlayerVariantMultyExpByPlayerIDFor5to6(Id,Buff),		
									{};
							  	62->
									put("Start_Is_Changed",true),
									updatePlayerVariantMultyExpByPlayerIDFor5to6(Id,Buff),
									{};
							  	63->
									put("Start_Is_Changed",true),
									updatePlayerVariantMultyExpByPlayerIDFor5to6(Id,Buff),
									{};
								_->Buff
							end
					  end,
					  NewObjectBuffDBRecordList1 = lists:map(MakeNewListFun, Record#objectBuffDB.buffList),
					  case get("Start_Is_Changed") of
						  true->
							  io:format("player id:~p, buff be archived ~n",[Id]),
							  NewObjectBuffDBRecordList2 = lists:filter( fun(Record)-> Record /= {} end, NewObjectBuffDBRecordList1 ),
							  SaveBuff = #objectBuffDB{
									 id=Id,
									 buffList=NewObjectBuffDBRecordList2},
							  mySqlProcess:replaceObjectBuffDB(SaveBuff);
						  false->
							  ok
					  end
			end,
			lists:foreach(Fun, ObjectBuffDBRecordList),
			timer:sleep(1000*10),
			ok	
	end.
			

%%PlayerVariant_Index7_Multy_Exp_M 双倍经验丹使用的玩家变量是这个。存的是双倍经验结束的时间。用的是utc
updatePlayerVariantMultyExpByPlayerIDFor5to6(PlayerID,Buff)->
	%record( objectBuffDataDB, {buff_id, casterID, isEnable, startTime, allValidTime, lastDotEffectTime, remainTriggerCount}).
	%startTime, allValidTime,是根据这2个算buff结束时间吧
	Now = erlang:now(),
	TimeLost = timer:now_diff( Now, Buff#objectBuffDataDB.startTime ) div 1000,
	RemainTime=Buff#objectBuffDataDB.allValidTime-TimeLost,
	io:format("player id:~p, update MultyExp,RemainTime:~p  ~n",[PlayerID,RemainTime]),
	case RemainTime > 0 of
		true->
			ExpEndTime = common:getNowUTCSeconds() + RemainTime,
			PlayerGamedataList = mySqlProcess:get_playerGamedata_list_by_id(PlayerID),
			case PlayerGamedataList of
				[]->ok;
				[PlayerGamedata|_]->
					PlayerVarArray = PlayerGamedata#player_gamedata.varArray ,
					NewPlayerVarArray = array:set(?PlayerVariant_Index7_Multy_Exp_M, ExpEndTime, PlayerVarArray),
					io:format("player id:~p, update MultyExp,ExpEndTime:~p  ~n",[PlayerID,ExpEndTime]),
					mySqlProcess:updatePlayerVarArray(PlayerID,NewPlayerVarArray)				
			end;
		false->ok
	end.
  


	