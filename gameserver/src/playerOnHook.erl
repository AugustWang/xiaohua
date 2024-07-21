%% @author soko
%% @doc @todo Add description to PlayerOnHook.
%% 处理玩家的挂机配置信息

-module(playerOnHook).


%% ====================================================================
%% API functions
%% ====================================================================
-compile(export_all).
-import(messageBase,[write_int/1, read_int/1]).

-include("package.hrl").
-include("db.hrl").
-include("mysql.hrl").



%% ====================================================================
%% Internal functions
%%-record(playerOnHook,{playerID,playerHP,petHP, skillID1,
%%skillID2,skillID3,skillID4,skillID5,skillID6,getThing,hpThing,other }).
%% ====================================================================
%%初始化数据
onPlayerInitData() ->
	PlayerID = player:getCurPlayerID(),
	Sql = "select * from `playeronhook` where `PlayerID`='"++integer_to_list(PlayerID)++"';",
	{ok,MyRes} = mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, Sql,true),
	case MyRes of %%查询数据
		[] -> Record = switchInfoToRecord(asdf), 
			  %Sql1="REPLACE into `playeronhook` (`PlayerID`,`Content`) values ('"++integer_to_list(PlayerID)++"','"++binary_to_list(switchDBToBin(Record))++"')",
			  %mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, Sql1,true) ;
			  mySqlProcess:replacePlayeronhook(PlayerID,switchDBToBin(Record));
		_ ->[[_Pid,Content]] = MyRes,
			Record = switchInfoToRecord(Content),
			 ok 
	end,
	%插入内存表中的数据
	%MyTable = ets:new('playerOnHook', [protected, { keypos, #playerOnHook.playerID }] ),
	%etsBaseFunc:insertRecord(MyTable, Record),
	put("PlayerOnHook", Record),
	
	sendMsg(), %发送信息

	ok.


 %% 转化到二进制
switchDBToBin(#playerOnHook{} = Info) ->
	Bin0=write_int(Info#playerOnHook.playerHP),
	Bin3=write_int(Info#playerOnHook.petHP),
	Bin6=write_int(Info#playerOnHook.skillID1),
	Bin9=write_int(Info#playerOnHook.skillID2),
	Bin12=write_int(Info#playerOnHook.skillID3),
	Bin14=write_int(Info#playerOnHook.skillID4),
	Bin16=write_int(Info#playerOnHook.skillID5),
	Bin18=write_int(Info#playerOnHook.skillID6),
	Bin21=write_int(Info#playerOnHook.getThing),
	Bin23=write_int(Info#playerOnHook.hpThing),
	Bin25=write_int(Info#playerOnHook.other),
	Bin27=write_int(Info#playerOnHook.isAutoDrug),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin14/binary,Bin16/binary,Bin18/binary,Bin21/binary,Bin23/binary,Bin25/binary,Bin27/binary>>.

switchInfoToRecord( BinInfo) ->
	case is_binary(BinInfo) of
		false ->Info =#playerOnHook{playerID = player:getCurPlayerID(),playerHP=50,petHP=50,skillID1=0,skillID2=0,skillID3=0,skillID4=0,skillID5=0,skillID6=0,getThing=0,hpThing=0,isAutoDrug=0, other=0};
		true ->
			<<Php:32/little,PetHp:32/little,SkillID1:32/little,SkillID2:32/little,SkillID3:32/little,SkillID4:32/little,SkillID5:32/little,SkillID6:32/little,GetThing:32/little,HpThing:32/little,Other:32/little,Left/binary>> = BinInfo,
			case Left =:= <<>> of
				true->
					IsAutoDrug = 0;
				false->
					<<IsAutoDrug:32/little>>=Left
			end,
		    Info = #playerOnHook{playerID= player:getCurPlayerID(),playerHP=Php,
								petHP= PetHp,
								skillID1=SkillID1,
								skillID2=SkillID2,
								skillID3=SkillID3,
								skillID4=SkillID4,
								skillID5=SkillID5,
								skillID6=SkillID6,
								getThing=GetThing,
								isAutoDrug=IsAutoDrug,
								hpThing=HpThing,
								other=Other}
	end,
	Info.


%%保存数据到数据库
save_data() ->
	TT = get("PlayerOnHook"),
	case TT of 
		{} -> off;
		_ -> 
			%mysqlCommon:sqldb_query(?GAMEDB_CONNECT_POOL, "update `playeronhook` set `Content`='"++binary_to_list(switchDBToBin(TT))++"' where `PlayerID`='"++integer_to_list(TT#playerOnHook.playerID)++"'",true)
			mySqlProcess:updatePlayeronhook(TT#playerOnHook.playerID,switchDBToBin(TT))
	end.



%%发送配置信息
sendMsg() ->
	_Tset = get("PlayerOnHook"), %得到内存数据
	player:send(#pk_GS2U_OnHookSet_Mess{playerHP = _Tset#playerOnHook.playerHP,
										petHP = _Tset#playerOnHook.petHP,
										skillID1 = _Tset#playerOnHook.skillID1,
										skillID2 = _Tset#playerOnHook.skillID2,
										skillID3 = _Tset#playerOnHook.skillID3,
										skillID4 = _Tset#playerOnHook.skillID4,
										skillID5 = _Tset#playerOnHook.skillID5,
										skillID6 = _Tset#playerOnHook.skillID6,
										getThing = _Tset#playerOnHook.getThing,
										hpThing = _Tset#playerOnHook.hpThing,
										other = _Tset#playerOnHook.other,
										isAutoDrug = _Tset#playerOnHook.isAutoDrug
										}), %发送数据
	ok.

%%处理保存设置信息
processMsg(Msg) ->
	case Msg of
		{} -> off;
		_ ->
		{_,PlayerHP,PetHP,SkillID1,SkillID2,SkillID3,SkillID4,SkillID5,SkillID6,GetThing,HpThing,Other,IsAutoDrug} = Msg,
		put("PlayerOnHook", #playerOnHook{playerID= player:getCurPlayerID(),
								playerHP = PlayerHP,
							   petHP=PetHP,
							   skillID1=SkillID1,
							   skillID2=SkillID2,
							   skillID3=SkillID3,
							   skillID4=SkillID4,
							   skillID5=SkillID5,
							   skillID6=SkillID6,
							   getThing = GetThing,
							   hpThing = HpThing,
							   other = Other,
							   isAutoDrug = IsAutoDrug}),
		save_data()
	end,
	ok.


