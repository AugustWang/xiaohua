-module(mysqlCommon).

%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% Include files
%%
-include("mysql.hrl").
%-include("logdb.hrl").
-include("hdlt_logger.hrl").

-define( sqlRetryInterval, 30000).
-define( excuteSqlTimeOut, 40000).
%% now, don't retry, in the future will retry serval times when timeout


sqldb_query(PoolId,Query,IsRetry)->
	try
		Sql1 = list_to_binary(Query),		
		case mysql:fetch(PoolId,Sql1,?excuteSqlTimeOut) of
			{data, MysqlRes} ->
				AllRows = mysql:get_result_rows(MysqlRes),
				{ok, AllRows };
			{updated, _MysqlRes}->
				{ok, [] };		
			{error, {no_connection_in_pool, PoolId} } ->
				common:messageBox("sqldb_query:error[~s]", [{no_connection_in_pool, PoolId}]),
				case IsRetry of
%% 					true ->
%% 						timer:sleep(?sqlRetryInterval), 
%% 						sqldb_query(PoolId,Query,IsRetry);
					_->
						{error, [] }
				end;
			{error, #mysql_result{error=Reason,errcode=ErrCode,errsqlstate=SqlState}} ->
 				common:messageBox("sqldb_query:error[~s,~s,~p,~s]",[Query,Reason,ErrCode,SqlState] ),
				case IsRetry of
%% 					true ->
%% 						%% 据错误码做不同的处理
%% 						case ErrCode of
%% 							1210 -> %% 参数个数错误，不能检查参数类型错误 
%% 								{error, [] };
%% 							_->
%% 								timer:sleep(?sqlRetryInterval), 
%% 								sqldb_query(PoolId,Query,IsRetry)
%% 						end;				
					_->
						{error, [] }
				end;
			Unkown ->	
				common:messageBox("sqldb_query:error[~s,~p]",[Query,Unkown] ),
 				case IsRetry of
%% 					true ->
%% 						timer:sleep(?sqlRetryInterval), 
%% 						sqldb_query(PoolId,Query,IsRetry);
					_->
						{error, [] }
				end
		end				
	catch
        _:Why1->	
			common:messageBox("sqldb_query exeption(timeout) ~p ~n",[Why1]),
			case IsRetry of
%% 					true ->
%% 						timer:sleep(?sqlRetryInterval), 
%% 						sqldb_query(PoolId,Query,IsRetry);
					_->
						{error, [] }
			end
    end.	

		
sqldb_exec_prepared_stat(PoolId,PreparedStat,DataList,IsRetry) ->
	try
		case mysql:execute(PoolId, PreparedStat, DataList,?excuteSqlTimeOut) of
			{data, MysqlRes} ->
				AllRows = mysql:get_result_rows(MysqlRes),
				{ok, AllRows };
			{updated, _MysqlRes1}->
				{ok, [] };	
			{error, {no_such_statement, Name} } ->
				common:messageBox("sqldb_exec_prepared_stat:error[~s]", [{no_such_statement, Name}]),
				case IsRetry of
%% 					true ->
%% 						timer:sleep(?sqlRetryInterval), 
%% 						sqldb_exec_prepared_stat(PoolId,PreparedStat,DataList,IsRetry);
					_->
						{error, [] }
				end;
			{error, {no_connection_in_pool, PoolId} } ->
				common:messageBox("sqldb_exec_prepared_stat:error[~s]", [{no_connection_in_pool, PoolId}]),
				case IsRetry of
%% 					true ->
%% 						timer:sleep(?sqlRetryInterval), 
%% 						sqldb_exec_prepared_stat(PoolId,PreparedStat,DataList,IsRetry);
					_->
						{error, [] }
				end;
			{error, #mysql_result{error=Reason,errcode=ErrCode,errsqlstate=SqlState}} ->
 				common:messageBox("sqldb_exec_prepared_stat:error[~s,~s,~p,~s]",[PreparedStat,Reason,ErrCode,SqlState] ),
				case IsRetry of
%% 					true ->
%% 						%% 据错误码做不同的处理
%% 						case ErrCode of
%% 							1210 -> %% 参数个数错误，不能检查参数类型错误 
%% 								{error, [] };
%% 							1062 -> %% Duplicate entry
%% 								{error, [] };
%% 							_->
%% 								timer:sleep(?sqlRetryInterval), 
%% 								sqldb_exec_prepared_stat(PoolId,PreparedStat,DataList,IsRetry)
%% 						end;
					_->
						{error, [] }
				end;
			Unkown ->	
				common:messageBox("sqldb_exec_prepared_stat:error[~s,~p]",[PreparedStat,Unkown] ),
				case IsRetry of
%% 					true ->
%% 						timer:sleep(?sqlRetryInterval), 
%% 						sqldb_exec_prepared_stat(PoolId,PreparedStat,DataList,IsRetry);
					_->
						{error, [] }
				end
		end				
	catch
        _:Why1->	
			common:messageBox("sqldb_exec_prepared_stat exeption, why: ~p, PreparedStat:~s ~n",[Why1,PreparedStat]),
			case IsRetry of
%% 					true ->
%% 						timer:sleep(?sqlRetryInterval), 
%% 						sqldb_exec_prepared_stat(PoolId,PreparedStat,DataList,IsRetry);
					_->
						{error, [] }
			end
    end.	

