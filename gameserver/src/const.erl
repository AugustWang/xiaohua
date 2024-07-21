%% Author: Zhangdong
%% Created: 2012-8-8
%% Description: TODO: Add description to itemDB
-module(const).

%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% Include files
%%
-include("db.hrl").
-include("hdlt_logger.hrl").



%%返回玩家等级属性表的属性对应下标记录
getPlayerBaseCfg_ProIndex()->
	{?attack, ?defence, ?ph_def, ?fire_def, ?ice_def, ?elec_def, ?poison_def,
	 ?max_life, ?hit_rate_rate, ?dodge_rate, ?block_rate, ?crit_rate, ?pierce_rate, ?attack_speed_rate, ?tough_rate, 
	 ?crit_damage_rate, ?block_dec_damage }.

%%返回宠物等级属性表的属性对应下标记录
getPetBaseCfg_ProIndex()->
	{?attack, ?defence, ?max_life ,?ph_def, ?fire_def, ?ice_def, ?elec_def, ?poison_def,
	 ?hit_rate_rate, ?dodge_rate, ?block_rate, ?crit_rate, ?pierce_rate, ?attack_speed_rate, ?tough_rate, 
	 ?crit_damage_rate, ?block_dec_damage, ?coma_def_rate, ?hold_def_rate, ?silent_def_rate,
	 ?move_def_rate }.

%%将一个记录的偏移值加到数组上
addRecordValueIntoArray( Array, RecordValue, RecordAdd_BeginIndex, RecordIndexs )->
%% 	put( "addRecordValueIntoArray", Array ),
%% 	MyFunc = fun( Index )->
%% 					 ArrayIndex = element( Index, RecordIndexs ),
%% 					 Value = element( RecordAdd_BeginIndex + Index - 1, RecordValue ),
%% 					 New = array:set( ArrayIndex, Value + array:get( ArrayIndex, Array), get("addRecordValueIntoArray") ),
%% 					 put( "addRecordValueIntoArray", New )
%% 			 end,
%% 	common:for( 1, size(RecordIndexs), MyFunc ),
%% 	get("addRecordValueIntoArray").
	addRecordValueIntoArray2( Array, RecordValue, RecordAdd_BeginIndex, RecordIndexs, 1, size(RecordIndexs) ).

addRecordValueIntoArray2( Array, RecordValue, RecordAdd_BeginIndex, RecordIndexs, Index, Max )when Index =< Max->
	ArrayIndex = element( Index, RecordIndexs ),
	Value = element( RecordAdd_BeginIndex + Index - 1, RecordValue ),
	New = array:set( ArrayIndex, Value + array:get( ArrayIndex, Array), Array ),
	addRecordValueIntoArray2( New, RecordValue, RecordAdd_BeginIndex, RecordIndexs, Index+1, Max );
addRecordValueIntoArray2( Array, _RecordValue, _RecordAdd_BeginIndex, _RecordIndexs, Index, Max )when Index > Max->
	Array.

%%设置数组的某些元素值，根据一个元组
setArrayByRecord( Array, Record, SetValue )->
%% 	put( "setArrayByRecord", Array ),
%% 	MyFunc = fun( Index )->
%% 					 ArrayIndex = element( Index, Record ),
%% 					 NewArray = array:set( ArrayIndex, SetValue, get("setArrayByRecord") ),
%% 					 put( "setArrayByRecord", NewArray )
%% 			 end,
%% 	common:for( 1, size(Record), MyFunc ),
%% 	get("setArrayByRecord").
	setArrayByRecord2( Array, Record, SetValue, 1, size(Record) ).

setArrayByRecord2( Array, Record, SetValue, Index, Max )when Index =< Max ->
	ArrayIndex = element( Index, Record ),
	NewArray = array:set( ArrayIndex, SetValue, Array ),
	setArrayByRecord2( NewArray, Record, SetValue, Index+1, Max );

setArrayByRecord2( Array, _Record, _SetValue, Index, Max )when Index > Max->
	Array.


%%将两个属性数组的值相加
addPropertyArray( FromArray, ToArray )->
%%  	put( "addPropertyArray", FromArray ),
%%  	MyFunc = fun( Index )->
%%  					 Value = array:get( Index, FromArray) + array:get( Index, ToArray),
%%  					 NewArray = array:set( Index, Value, get("addPropertyArray") ),
%%  					 put( "addPropertyArray", NewArray )
%%  			 end,
%%  	common:for( 0, array:size(FromArray)-1, MyFunc ),
%%  	get("addPropertyArray").
	addPropertyArray2( FromArray, ToArray, 0, array:size(FromArray)-1).

addPropertyArray2( FromArray, ToArray, Index, Max )when Index =< Max->
	 Value = array:get( Index, FromArray) + array:get( Index, ToArray),
	 NewArray = array:set( Index, Value, FromArray ),
	 addPropertyArray2( NewArray, ToArray, Index+1, Max );
addPropertyArray2( FromArray, _ToArray, Index, Max )when Index > Max->
	 FromArray.

%%将两个属性数组的值合并
mergPropertyArray( FromArray, ToArray )	->
%% 	put( "mergPropertyArray", FromArray ),
%% 	MyFunc = fun( Index )->
%% 					 FromValue = array:get( Index, FromArray),
%% 					 ToValue = array:get( Index, ToArray),
%% 					 case FromValue of
%% 						 []->
%% 							 case ToValue of
%% 								 []->NewValue = [];
%% 								 _->NewValue = ToValue
%% 							 end;
%% 						 _->
%% 							 case ToValue of
%% 								 []->NewValue = FromValue;
%% 								 _->NewValue = FromValue ++ ToValue
%% 							 end
%% 					 end,
%% 			 		 case NewValue of
%% 						 []->ok;
%% 						 _->
%% 							 NewArray = array:set( Index, NewValue, get("mergPropertyArray") ),
%% 							 put( "mergPropertyArray", NewArray )
%% 					 end
%% 			 end,
%% 	common:for( 0, array:size(FromArray)-1, MyFunc ),
%% 	get("mergPropertyArray").
	mergPropertyArray2( FromArray, ToArray, 0, array:size(FromArray)-1 ).

mergPropertyArray2( FromArray, ToArray, Index, Max )when Index =< Max->
	 FromValue = array:get( Index, FromArray),
	 ToValue = array:get( Index, ToArray),
	 case FromValue of
		 []->
			 case ToValue of
				 []->NewValue = [];
				 _->NewValue = ToValue
			 end;
		 _->
			 case ToValue of
				 []->NewValue = FromValue;
				 _->NewValue = FromValue ++ ToValue
			 end
	 end,
	 case NewValue of
		 []->mergPropertyArray2( FromArray, ToArray, Index+1, Max );
		 _->
			 NewArray = array:set( Index, NewValue, FromArray ),
			 mergPropertyArray2( NewArray, ToArray, Index+1, Max )
	 end;
mergPropertyArray2( FromArray, _ToArray, Index, Max )when Index > Max->
	FromArray.
