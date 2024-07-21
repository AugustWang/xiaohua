%% Author: wenziyong
%% Created: 2013-2-6
%% Description: TODO: Add description to main
-module(publicdbProcess).

%%
%% Include files
%%
-include("mysql.hrl").
-include("publicdb.hrl").
-include("hdlt_logger.hrl").
%-include("db.hrl").

%%
%% Exported Functions
%%
-compile(export_all).



		

activecode_data_list_to_record(ActivecodeDataList)->
	R = mySqlProcess:list_to_record(ActivecodeDataList,activecode_data),
	setelement( #activecode_data.active_code, R, binary_to_list(R#activecode_data.active_code)).

%-record( activecode_data, {active_code, item_id, item_count, param, create_time, get_time,get_userid,get_playerid} ).

%-> [activecode_data]
getActivecodeData(  ActiveCode )->
	{_SuccOrErr,ActivecodeDataList} = mysqlCommon:sqldb_query(?PUBLICDB_CONNECT_POOL,"select * from activecode where active_code = '"++ActiveCode++"'",true),
	lists:map(fun(List) -> activecode_data_list_to_record(List) end, ActivecodeDataList).

getActivecodeDataByPlayerID(  PlayerID, ItemID )->
	{_SuccOrErr,ActivecodeDataList} = mysqlCommon:sqldb_query(?PUBLICDB_CONNECT_POOL,"select * from activecode where get_playerid = "++common:formatString( PlayerID ) ++ " and item_id = "++common:formatString( ItemID ),true),
	lists:map(fun(List) -> activecode_data_list_to_record(List) end, ActivecodeDataList).

updateActiveCode(UserId,PlayerId,ActiveCode) ->
	Now = common:timestamp(),
	L = [Now,UserId,PlayerId,ActiveCode],
	mysqlCommon:sqldb_exec_prepared_stat(?PUBLICDB_CONNECT_POOL,update_activecode_data,L,true).


register_prepared_stats(State) ->	
	_State1 = mysql:add_prepare({prepare,update_activecode_data,
          <<"UPDATE activecode set get_time=?,get_userid=?,get_playerid=? where active_code=?">>}, State).
%% 	State1 = mysql:add_prepare({prepare,insert_activecode_data,
%%           <<"INSERT INTO activecode(active_code,item_id,item_count,param,create_time,get_time,get_userid,get_playerid)
%% 				VALUES (?,?,?,?, ?,?,?,?)">>}, State),

	