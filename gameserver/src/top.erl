%% Author: yueliangyou
%% Created: 2013-3-29
%% Description: TODO: 
-module(top).

%%
%% Include files
%%
-include("db.hrl").
-include("top.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("variant.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

ini_ReadKey( IniFile, File, Key )->
	case io:get_line(File, '') of
		eof->
			throw(-1);
		{error, Reason }->
			?DEBUG_OUT( "ini_ReadKey IniFile[~p] Key[~p] getline false[~p]", [IniFile, Key, Reason] ),
			throw(-1);
		LineString->
			Tokens = string:tokens(LineString, "=\n"),
			case length( Tokens ) >= 2 of
				true->
					[ReadKey|Tokens2] = Tokens,
					case length( Tokens2 ) > 1 of
						true->[ReadValue|_] = Tokens2;
						false->ReadValue=Tokens2
					end,
					case ReadKey =:= Key of
						true->ReadValue;
						false->ini_ReadKey(IniFile, File, Key)
					end;
				false->ini_ReadKey(IniFile, File, Key)
			end
	end.

ini_ReadString( IniFile, Key, Default )->
	try
		put( "ini_ReadString_File", 0 ),
		case file:open(IniFile, read ) of
			{ok, File }->
				put( "ini_ReadString_File", File ),
				ReadValue = ini_ReadKey( IniFile, File, Key ),
				file:close(File),
				[Return|_] = ReadValue,
				Return;
			{error, Reason}->
				?DEBUG_OUT( "ini_ReadString IniFile[~p] Key[~p] file open false[~p]", [IniFile, Key, Reason] ),
				throw(-1);
			_->
				throw(-1)
		end
	catch
		_->
			File2 = get( "ini_ReadString_File" ),
			case File2 of
				0->ok;
				_->file:close(File2)
			end,
			Default
	end.

ini_ReadInt( IniFile, Key, Default )->
	ReadString = ini_ReadString( IniFile, Key, Default ),
	case ReadString =:= Default of
		true->Default;
		false->
			{Return,_}=string:to_integer( ReadString ),
			Return
	end.

init()->
	%% IP = ini_ReadString( "GameServerSetup.txt", "LSIP", "127.0.0.1" ),
	%% Port = ini_ReadInt( "GameServerSetup.txt", "LSPort", 44802 ),
	?DEBUG_OUT("top proc init ...",[]),
	%% 创建支持排名的ets表
	TopListTableUsing=ets:new( 'toplisttableusing', [set,named_table,protected,{read_concurrency,true},  { keypos, #top_record.toptype }] ),
    TopListTableReady=ets:new( 'toplisttableready', [set,named_table,protected, {read_concurrency,true}, { keypos, #top_record.toptype }] ),
	put("TopListTableUsing",TopListTableUsing),
	put("TopListTableReady",TopListTableReady),
	%% 加载排行部分数据至内存
	loadTopList(),
	ok.

on_Refresh()->
	%% 刷新排名数据库表
	refreshTopList(),
	%% 重新加载内存排名数据
	reloadTopList().
	%logTopList().

%% 刷新排名数据表 每天定时执行
refreshTopList()->
	try
		%%也顺便把等级满足开启战场的玩家数量检索出来
		PlayerNum=mySqlProcess:get_Player_Num_Of_Leve_High_than(active_battle:getMinJoinLevel()),
		variant:setWorldVarValue(?WorldVariant__Num_Of_Player_Can_Join_Battle, PlayerNum),
		?DEBUG_OUT("the number of player that  can join battle ~p",[PlayerNum]),

		case mySqlProcess:refresh_TopList_Level(?TOP_PLAYER_LEVEL_NEED) of
			{error,_}->
				?LOG_OUT("refresh top list level failed",[]);
			{ok,_}->ok
		end,
		case mySqlProcess:refresh_TopList_Money(?TOP_PLAYER_MONEY_NEED) of
			{error,_}->
				?LOG_OUT("refresh top list money failed",[]);
			{ok,_}->ok
		end,
		case mySqlProcess:refresh_TopList_Fighting_Capacity(?TOP_PLAYER_FIGHTING_CAPACITY_NEED) of 
			{error,_}->
				?LOG_OUT("refresh top list fighting capacity failed",[]);
			{ok,_}->ok
		end,
		ok
	catch
		_:_->
			?LOG_OUT("refresh top list failed",[])
	end.

%% 通知玩家更新排名信息
broadcastTopListRefresh()->
	ok.

%% 加载前50排名到内存
loadTopList()->
	?DEBUG_OUT("load top list start...",[]),
	%% 将数据加载进正在使用的ets表
	TopListPlayerLevel=mySqlProcess:get_TopList_Level(),
	TopListPlayerMoney=mySqlProcess:get_TopList_Money(),
	TopListPlayerFightingCapacity=mySqlProcess:get_TopList_Fighting_Capacity(),
	ets:insert(get("TopListTableUsing"),#top_record{toptype=?TOP_TYPE_PLAYER_LEVEL,toplist=TopListPlayerLevel}),
	ets:insert(get("TopListTableUsing"),#top_record{toptype=?TOP_TYPE_PLAYER_MONEY,toplist=TopListPlayerMoney}),
	ets:insert(get("TopListTableUsing"),#top_record{toptype=?TOP_TYPE_PLAYER_FIGHTING_CAPACITY,toplist=TopListPlayerFightingCapacity}),
	?DEBUG_OUT("load top list complete...",[]).

%% 加载前50排名到内存
reloadTopList()->
	%% 将数据加载进备用ets表，并将备用ets表置为正在使用
	TopListPlayerLevel=mySqlProcess:get_TopList_Level(),
	TopListPlayerMoney=mySqlProcess:get_TopList_Money(),
	TopListPlayerFightingCapacity=mySqlProcess:get_TopList_Fighting_Capacity(),
	ets:insert(get("TopListTableReady"),#top_record{toptype=?TOP_TYPE_PLAYER_LEVEL,toplist=TopListPlayerLevel}),
	ets:insert(get("TopListTableReady"),#top_record{toptype=?TOP_TYPE_PLAYER_MONEY,toplist=TopListPlayerMoney}),
	ets:insert(get("TopListTableReady"),#top_record{toptype=?TOP_TYPE_PLAYER_FIGHTING_CAPACITY,toplist=TopListPlayerFightingCapacity}),
	TabUsing=get("TopListTableUsing"),
	put("TopListTableUsing",get("TopListTableReady")),
	%% 删除用过的ets表，并创建新的备用ets表
	ets:delete(TabUsing),
	TabReady=ets:new( TabUsing, [set,named_table,protected, { keypos, #top_record.toptype }] ),
	put("TopListTableReady",TabReady),
	%% 通知所有在线玩家更新排行榜
	player:sendToAllPlayerProc({refreshTopList}),
	?DEBUG_OUT("reload top list complete...",[]).

logTopList()->
	TopListPlayerLevel=ets:lookup(get("TopListTableUsing"),?TOP_TYPE_PLAYER_LEVEL),
	?DEBUG_OUT("top list level:~p",[TopListPlayerLevel]),
	TopListPlayerMoney=ets:lookup(get("TopListTableUsing"),?TOP_TYPE_PLAYER_MONEY),
	?DEBUG_OUT("top list money:~p",[TopListPlayerMoney]),
	TopListPlayerFightingCapacity=ets:lookup(get("TopListTableUsing"),?TOP_TYPE_PLAYER_FIGHTING_CAPACITY),
	?DEBUG_OUT("top list fighting capacity:~p",[TopListPlayerFightingCapacity]).

getTopList(Type)->
	TopList=ets:lookup(toplisttableusing,Type),
	case TopList of
		[]->ets:lookup(toplisttableready,Type);
		_->TopList
	end.

convertTopPlayerLevelList(List)->
	NewList=#pk_TopPlayerLevelInfo{	top=List#top_player_level.top,		
					playerid=List#top_player_level.playerid,	
					name=List#top_player_level.name,	
					camp=List#top_player_level.camp,	
					level=List#top_player_level.level,	
					sex=List#top_player_level.sex,	
					weapon=List#top_player_level.weapon,	
					coat=List#top_player_level.coat,	
					fightingcapacity=List#top_player_level.fightingcapacity},
	NewList.

convertTopPlayerFightingCapacityList(List)->
	NewList=#pk_TopPlayerFightingCapacityInfo{top=List#top_player_fighting_capacity.top,		
					playerid=List#top_player_fighting_capacity.playerid,	
					name=List#top_player_fighting_capacity.name,	
					camp=List#top_player_fighting_capacity.camp,	
					level=List#top_player_fighting_capacity.level,	
					sex=List#top_player_fighting_capacity.sex,	
					weapon=List#top_player_fighting_capacity.weapon,	
					coat=List#top_player_fighting_capacity.coat,	
					fightingcapacity=List#top_player_fighting_capacity.fightingcapacity},
	NewList.

convertTopPlayerMoneyList(List)->
	NewList=#pk_TopPlayerMoneyInfo{	top=List#top_player_money.top,		
					playerid=List#top_player_money.playerid,	
					name=List#top_player_money.name,	
					camp=List#top_player_money.camp,	
					level=List#top_player_money.level,	
					sex=List#top_player_money.sex,	
					weapon=List#top_player_money.weapon,	
					coat=List#top_player_money.coat,	
					money=List#top_player_money.money},
	NewList.

%%发送等级排名信息给玩家
sendTopPlayerLevelListToPlayer() ->
        [TopRecord|_] = getTopList(?TOP_TYPE_PLAYER_LEVEL),
	%?DEBUG_OUT("TopRecord:~p",[TopRecord]),
	TopList=TopRecord#top_record.toplist,
	%?DEBUG_OUT("TopList:~p",[TopList]),
	TopListNew=lists:map(fun(List) -> convertTopPlayerLevelList(List) end, TopList),
	%?DEBUG_OUT("TopListNew:~p",[TopListNew]),
        case TopList of
                []-> player:send( #pk_GS2U_LoadTopPlayerLevelList{info_list=[]} );
                _ -> player:send( #pk_GS2U_LoadTopPlayerLevelList{info_list=TopListNew})
        end.

%%发送战斗力排名信息给玩家
sendTopPlayerFightingCapacityListToPlayer() -> 
        [TopRecord|_] = getTopList(?TOP_TYPE_PLAYER_FIGHTING_CAPACITY),
	TopList=TopRecord#top_record.toplist,
	TopListNew=lists:map(fun(List) -> convertTopPlayerFightingCapacityList(List) end, TopList),
	%?DEBUG_OUT("TopList:~p",[TopListNew]),
        case TopList of
                []-> player:send( #pk_GS2U_LoadTopPlayerFightingCapacityList{info_list=[]} );
                _ -> player:send( #pk_GS2U_LoadTopPlayerFightingCapacityList{info_list=TopListNew})
        end.

%%发送金钱排名信息给玩家
sendTopPlayerMoneyListToPlayer() -> 
        [TopRecord|_] = getTopList(?TOP_TYPE_PLAYER_MONEY),
	TopList=TopRecord#top_record.toplist,
	TopListNew=lists:map(fun(List) -> convertTopPlayerMoneyList(List) end, TopList),
	%?DEBUG_OUT("TopList:~p",[TopListNew]),
        case TopList of
                []-> player:send( #pk_GS2U_LoadTopPlayerMoneyList{info_list=[]} );
                _ -> player:send( #pk_GS2U_LoadTopPlayerMoneyList{info_list=TopListNew})
        end.

%% 玩家上线发送排名数据
onPlayerOnlineInitTopList()->
	sendTopPlayerLevelListToPlayer(),
	sendTopPlayerFightingCapacityListToPlayer(),
	sendTopPlayerMoneyListToPlayer().

