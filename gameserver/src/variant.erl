%% Author: Administrator
%% Created: 2012-10-9
%% Description: TODO: Add description to trade
-module(variant).

%%
%% Include files
%%
-include("db.hrl").
-include("trade.hrl").
-include("hdlt_logger.hrl").
-include("variant.hrl").
-include("pc_player.hrl").
-include("mapDefine.hrl").
-include("globalDefine.hrl").
-include("condition_compile.hrl").

%%
%% Exported Functions
%%
-compile(export_all).




%% BitIndex is from 0 to 31
setBit(OldValue,BitIndex,BitValue) ->
	case (BitIndex >= 0) andalso (BitIndex < 32) of
		true ->
			case OldValue =:= undefined of
				true -> 
					case BitValue =:= 0 of
						true -> 0;
						false -> ( 1 bsl BitIndex)
					end;
				false ->
					case BitValue =:= 0 of
						true ->  (OldValue band (16#ffffffff bxor (1 bsl BitIndex)));
						false -> (OldValue bor ( 1 bsl BitIndex) )
					end
			end;
		false ->
			?LOG_OUT("variant:setBit param error, Index:~p",[BitIndex]),
			OldValue
	end.


%% -> true or false
%% BitIndex is from 0 to 31
isBitOn(Value,BitIndex) ->
	case (BitIndex >= 0) andalso (BitIndex < 32) of
		true ->
			if 
				Value =:= undefined ->
					false;
				(Value band ( 1 bsl BitIndex) ) > 0 ->
					true;
				true ->
					false
			end;				 
		false ->
			?LOG_OUT("variant:isBitOn param error, BitIndex:~p",[BitIndex]),
			false
	end.



%% -> true or false
getPlayerVarFlag(PlayerVarArray,Index, BitIndex) ->
	case ( (Index>0) andalso (Index < ?Max_PlayerVariant_Count) ) of
		true ->
			case array:get(Index, PlayerVarArray) of
				undefined -> false;
				Value -> isBitOn(Value,BitIndex) 
			end;
		false ->
			?LOG_OUT("variant:getPlayerFlag param error, Index:~p",[Index]),
			false
	end.


%% revoked by player process 
setPlayerVarFlagFromPlayer(Index, BitIndex, BitValue) ->
	case ( (Index>0) andalso (Index < ?Max_PlayerVariant_Count) ) of
		true ->
			PlayerVarArray = player:getCurPlayerProperty( #player.varArray ),
			case array:get(Index, PlayerVarArray) of
				undefined -> 
					NewValue = setBit(0,BitIndex,BitValue);
				Value -> 
					NewValue = setBit(Value,BitIndex,BitValue)			
			end,
			NewPlayerVarArray = array:set(Index, NewValue, PlayerVarArray),
			player:setCurPlayerProperty( #player.varArray,  NewPlayerVarArray),	
			case Index =< ?Max_PlayerVariant_Syn_Client_Count of
				true ->	
					VariantData_List = [#pk_VariantData{index=Index,value=NewValue}],
					player:send( #pk_GS2U_VariantDataSet{variant_type=?Variant_Type_Player,
											info_list=VariantData_List} );
					
				false -> ok
			end;
		false ->
			?LOG_OUT("variant:setPlayerVarFlagFromPlayer param error, Index:~p",[Index]),
			false
	end.

%% -> int32 or undefined
getPlayerVarValue(PlayerVarArray,Index) ->
	case ( (Index>0) andalso (Index < ?Max_PlayerVariant_Count) ) of
		true ->
			array:get(Index, PlayerVarArray);
		false ->
			?LOG_OUT("variant:getPlayerVarValue param error, Index:~p",[Index]),
			undefined
	end.

%% revoked by player process 
setPlayerVarValueFromPlayer(Index,NewValue) ->
	case ( (Index>0) andalso (Index < ?Max_PlayerVariant_Count) ) of
		true ->
			PlayerVarArray = player:getCurPlayerProperty( #player.varArray ),
			NewPlayerVarArray = array:set(Index, NewValue, PlayerVarArray),
			player:setCurPlayerProperty( #player.varArray,  NewPlayerVarArray),
			case Index =< ?Max_PlayerVariant_Syn_Client_Count of
				true ->	
					VariantData_List = [#pk_VariantData{index=Index,value=NewValue}],
					?DEBUG_OUT("---------VariantData_List:~p",[VariantData_List]),
					player:send( #pk_GS2U_VariantDataSet{variant_type=?Variant_Type_Player,
											info_list=VariantData_List} );			
				false -> ok
			end;
		false ->
			?LOG_OUT("variant:setPlayerVarValueFromPlayer param error, Index:~p",[Index]),
			false
	end.



%% revoked by map process  
setPlayerVarValueFromMap(#mapPlayer{id=PlayerID}=_Player,Index,NewValue) ->
	case ( (Index>0) andalso (Index < ?Max_PlayerVariant_Count) ) of
		true ->
			%PlayerVarArray = Player#mapPlayer.varArray,
			PlayerVarArray = etsBaseFunc:getRecordField( map:getMapPlayerTable(), PlayerID, #mapPlayer.varArray ),			
			NewPlayerVarArray = array:set(Index, NewValue, PlayerVarArray),			
			etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.varArray, NewPlayerVarArray ),
	
			case Index =< ?Max_PlayerVariant_Syn_Client_Count of
				true ->	
					VariantData_List = [#pk_VariantData{index=Index,value=NewValue}],
					player:sendToPlayer(PlayerID, #pk_GS2U_VariantDataSet{variant_type=?Variant_Type_Player,
											info_list=VariantData_List} );			
				false -> ok
			end,
			%% sync to player process
			player:sendToPlayerProc(PlayerID,{syncPlayerVariant,#pk_VariantData{index=Index,value=NewValue} });
		false ->
			?LOG_OUT("variant:setPlayerVarValueFromMap param error, Index:~p",[Index]),
			false
	end.


%% revoked by map process  
setPlayerVarFlagFromMap(#mapPlayer{id=PlayerID}=_Player, Index, BitIndex,BitValue) ->
	case ( (Index>0) andalso (Index < ?Max_PlayerVariant_Count) ) of
		true ->
			%PlayerVarArray = Player#mapPlayer.varArray,
			PlayerVarArray = etsBaseFunc:getRecordField( map:getMapPlayerTable(), PlayerID, #mapPlayer.varArray ),	
			case array:get(Index, PlayerVarArray) of
				undefined -> 
					NewValue = setBit(0,BitIndex,BitValue);
				Value -> 
					NewValue = setBit(Value,BitIndex,BitValue)			
			end,
			NewPlayerVarArray = array:set(Index, NewValue, PlayerVarArray),
			etsBaseFunc:changeFiled( map:getMapPlayerTable(), PlayerID, #mapPlayer.varArray, NewPlayerVarArray ),
			
			case Index =< ?Max_PlayerVariant_Syn_Client_Count of
				true ->	
					VariantData_List = [#pk_VariantData{index=Index,value=NewValue}],
					player:sendToPlayer(PlayerID, #pk_GS2U_VariantDataSet{variant_type=?Variant_Type_Player,
											info_list=VariantData_List} );				
				false -> ok
			end,
			%% sync to player process
			player:sendToPlayerProc(PlayerID,{syncPlayerVariant,#pk_VariantData{index=Index,value=NewValue} });
		false ->
			?LOG_OUT("variant:setPlayerVarFlagFromMap param error, Index:~p",[Index]),
			false
	end.


%% sync player var 
syncPlayerVarValueByPlayerProc(#pk_VariantData{index=Index,value=NewValue}) ->
	case ( (Index>0) andalso (Index < ?Max_PlayerVariant_Count) ) of
		true ->
			PlayerVarArray = player:getCurPlayerProperty( #player.varArray ),
			NewPlayerVarArray = array:set(Index, NewValue, PlayerVarArray),
			player:setCurPlayerProperty( #player.varArray,  NewPlayerVarArray);	
		false ->
			?LOG_OUT("variant:setPlayerVarValueFromPlayer param error, Index:~p",[Index]),
			false
	end.


%%----------------------world var ----------------------
%% init world var
initWorldVarArray() ->
	case mySqlProcess:getWordVarArray() of
		{}->WorldArray = array:new();
		WorldArray->ok
	end,
	etsBaseFunc:changeFiled( ?GlobalMainAtom, ?GlobalMainID, #globalMain.varArray,WorldArray ),
	%% if the world var not save to db, please init these world var here
	case ?Is_Debug_version of
		true->variant:setWorldVarFlag(?WorldVariant_Index_51, ?WorldVariant_Index_51_PingFlag_Bit0,0);
		false->variant:setWorldVarFlag(?WorldVariant_Index_51, ?WorldVariant_Index_51_PingFlag_Bit0,1)
	end,
	variant:setWorldVarFlag(?WorldVariant_Index_51, ?WorldVariant_Index_51_PingFlag_Bit0,1),
	%%免战初始化
	{_,{Hour,Minute,Second}}=calendar:now_to_local_time(erlang:now()),
	Current=Hour*3600+Minute*60+Second,
	case (Current >=?PKProctedStartTime) and (Current <?PKProctedEndTime ) of
		true->
			?LOG_OUT("WorldVariant_Index_1_PeriodPkProt_Bit0 init to 1"),
			variant:setWorldVarFlag(?WorldVariant_Index_1, ?WorldVariant_Index_1_PeriodPkProt_Bit0,1),
			ok;
		false->
			?LOG_OUT("WorldVariant_Index_1_PeriodPkProt_Bit0 init to 0"),
			variant:setWorldVarFlag(?WorldVariant_Index_1, ?WorldVariant_Index_1_PeriodPkProt_Bit0,0),
			ok
	end,
	
	%%这个东西不能提交啊
	%%variant:setWorldVarValue(?WorldVariant__Num_Of_Player_Can_Join_Battle,0),
	

	ok.
	


%% modify one bit for world var
%% just revoked by main process, please send a msg to main process if other process wanna change the bit
setWorldVarFlag(Index, BitIndex,BitValue) ->
	case ( (Index>0) andalso (Index < ?Max_WorldVariant_Count) ) of
		true ->
			WorldVarArray = etsBaseFunc:getRecordField( ?GlobalMainAtom, ?GlobalMainID, #globalMain.varArray ),
			case array:get(Index, WorldVarArray) of
				undefined -> 
					NewValue = setBit(0,BitIndex,BitValue);
				Value -> 
					NewValue = setBit(Value,BitIndex,BitValue)			
			end,
			NewWorldVarArray = array:set(Index, NewValue, WorldVarArray),
			etsBaseFunc:changeFiled( ?GlobalMainAtom, ?GlobalMainID, #globalMain.varArray,NewWorldVarArray ),

			case Index =< ?Max_WorldVariant_Syn_Client_Count of
				true ->	
					VariantData_List = [#pk_VariantData{index=Index,value=NewValue}],
					%% broadcast
					player:sendToAllOnLinePlayer(#pk_GS2U_VariantDataSet{variant_type=?Variant_Type_World,
											info_list=VariantData_List} );		
				false -> ok
			end;
		false ->
			?LOG_OUT("variant:setWorldVarFlag param error, Index:~p",[Index]),
			false
	end.


%% modify one world var
%% just revoked by main process, please send a msg to main process if other process wanna change the world var
setWorldVarValue(Index, NewValue) ->
	case ( (Index>0) andalso (Index < ?Max_WorldVariant_Count) ) of
		true ->
			WorldVarArray = etsBaseFunc:getRecordField( ?GlobalMainAtom, ?GlobalMainID, #globalMain.varArray ),
			NewWorldVarArray = array:set(Index, NewValue, WorldVarArray),
			etsBaseFunc:changeFiled( ?GlobalMainAtom, ?GlobalMainID, #globalMain.varArray,NewWorldVarArray ),

			case Index =< ?Max_WorldVariant_Syn_Client_Count of
				true ->	
					VariantData_List = [#pk_VariantData{index=Index,value=NewValue}],
					%% broadcast
					player:sendToAllOnLinePlayer(#pk_GS2U_VariantDataSet{variant_type=?Variant_Type_World,
											info_list=VariantData_List} );		
				false -> ok
			end;
		false ->
			?LOG_OUT("variant:setWorldVarValue param error, Index:~p",[Index]),
			false
	end.



%% -> true or false
getWorldVarFlag(Index, BitIndex) ->
	case ( (Index>0) andalso (Index < ?Max_WorldVariant_Count) ) of
		true ->
			WorldVarArray = etsBaseFunc:getRecordField( ?GlobalMainAtom, ?GlobalMainID, #globalMain.varArray ),
			case array:get(Index, WorldVarArray) of
				undefined -> false;
				Value -> isBitOn(Value,BitIndex) 
			end;
		false ->
			?LOG_OUT("variant:getWorldVarFlag param error, Index:~p",[Index]),
			false
	end.

%% -> int32 or undefined
getWorldVarValue(Index) ->
	case ( (Index>0) andalso (Index < ?Max_WorldVariant_Count) ) of
		true ->
			WorldVarArray = etsBaseFunc:getRecordField( ?GlobalMainAtom, ?GlobalMainID, #globalMain.varArray ),
			array:get(Index, WorldVarArray);
		false ->
			?LOG_OUT("variant:getWorldVarValue param error, Index:~p",[Index]),
			undefined
	end.


