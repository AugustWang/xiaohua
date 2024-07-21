%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(etsBaseFunc).

%%
%% Include files
%%
-include("hdlt_logger.hrl").
-include_lib("stdlib/include/ms_transform.hrl").

-compile(export_all).

changeFiled( Table, Key, Field, Value ) ->
	ets:update_element(Table, Key, {Field,Value}).

insertRecord( Table, Record ) ->
	ets:insert( Table, Record)    
	.

deleteRecord(Table, Key ) ->
	ets:delete( Table, Key)    
	.

%% -> {} or R
readRecord( Table, Key ) ->
	%%check Table 
	case is_atom(Table) =:= false of
		true ->
			case Table =:= 0 of
				true ->?ERROR_OUT("---error,Table:~p, Key:~p",[Table,Key]);
				false->ok
			end;
		false->ok
	end,

    RecordList = ets:lookup(Table, Key),
	case RecordList of
		[]->{};
		[R]->R
	end.

getRecordField( Table, Key, Field )->
	Record = readRecord( Table, Key ),
	case Record of
		{}->
			?DEBUG_OUT( "getRecordField Table[~p], Key[~p], Field[~p] {}", [Table, Key, Field] ),
			0;
		_->
			SizeRecord = size( Record ),
			case ( Field > 0 ) andalso ( Field =< SizeRecord ) of
				false->
					?ERROR_OUT( "getRecordField Table[~p], Key[~p], Field[~p] SizeRecord[~p]", [Table, Key, Field, SizeRecord] ),
					0;
				true->
					element( Field, Record )
			end
	end.

etsFor( Table, Func )->
	etsForeach( Table, Func, ets:first(Table) ).
	
etsForeach( Table, Func, Key )->
	case Key of
		'$end_of_table'->ok;
		_->
			[R|_]=ets:lookup(Table, Key), 
			Func( R ),
			etsForeach( Table, Func, ets:next(Table, Key ) )
	end.

getAllRecord( Table )->
	Q = ets:fun2ms( fun( Record )-> Record end),
	ets:select(Table, Q).

getCount(Table)->
	Q = ets:fun2ms( fun( Record )-> true end),
	ets:select_count(Table, Q).

	
