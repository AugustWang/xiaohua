%% Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(worldMap_1).

-include("db.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("monsterDefine.hrl").
-include("scriptDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 

init()->
	scriptManager:registerScript( ?Object_Type_Map, 1, ?Map_Event_Init, ?MODULE, map_1_Map_Event_Init, 0 ),
	
	scriptManager:registerScript( ?Object_Type_Npc, 1001, ?Npc_Event_EnterCopyMapID, ?MODULE, npc_1001_Npc_Event_EnterCopyMapID, 0 ),
	
	scriptManager:registerScript( ?Object_Type_Npc, 87, ?Npc_Event_EnterCopyMapID, ?MODULE, npc_87_Npc_Event_EnterCopyMapID, 0 ),
	scriptManager:registerScript( ?Object_Type_Npc, 97, ?Npc_Event_EnterCopyMapID, ?MODULE, npc_97_Npc_Event_EnterCopyMapID, 0 ),
	
	
	scriptManager:registerScript( ?Object_Type_Npc, 44, ?Npc_Event_EnterCopyMapID, ?MODULE, npc_44_Npc_Event_EnterCopyMapID, 0 ),
	scriptManager:registerScript( ?Object_Type_Npc, 49, ?Npc_Event_EnterCopyMapID, ?MODULE, npc_49_Npc_Event_EnterCopyMapID, 0 ),
	scriptManager:registerScript( ?Object_Type_Npc, 85, ?Npc_Event_EnterCopyMapID, ?MODULE, npc_85_Npc_Event_EnterCopyMapID, 0 ),
	scriptManager:registerScript( ?Object_Type_Npc, 69, ?Npc_Event_EnterCopyMapID, ?MODULE, npc_69_Npc_Event_EnterCopyMapID, 0 ),
	scriptManager:registerScript( ?Object_Type_Npc, 74, ?Npc_Event_EnterCopyMapID, ?MODULE, npc_74_Npc_Event_EnterCopyMapID, 0 ),
	
	scriptManager:registerScript( ?Object_Type_Npc, 89, ?Npc_Event_EnterCopyMapID, ?MODULE, npc_89_Npc_Event_EnterCopyMapID, 0 ),
	scriptManager:registerScript( ?Object_Type_Npc, 90, ?Npc_Event_EnterCopyMapID, ?MODULE, npc_90_Npc_Event_EnterCopyMapID, 0 ),
	scriptManager:registerScript( ?Object_Type_Npc, 81, ?Npc_Event_EnterCopyMapID, ?MODULE, npc_81_Npc_Event_EnterCopyMapID, 0 ),
	ok.

map_1_Map_Event_Init( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "map_1_Map_Event_Init" ),
	ok.

%%进入副本Npc
npc_1001_Npc_Event_EnterCopyMapID( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "npc_1001_Npc_Event_EnterCopyMapID" ),
	{ eventCallBackReturn, [22] }.

%%进入副本Npc
npc_87_Npc_Event_EnterCopyMapID( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "npc_87_Npc_Event_EnterCopyMapID" ),
	{ eventCallBackReturn, [16] }.
	
%%进入副本Npc
npc_97_Npc_Event_EnterCopyMapID( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "npc_97_Npc_Event_EnterCopyMapID" ),
	{ eventCallBackReturn, [22] }.

%%进入副本Npc
npc_44_Npc_Event_EnterCopyMapID( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "npc_44_Npc_Event_EnterCopyMapID" ),
	{ eventCallBackReturn, [17,24] }.

%%进入副本Npc
npc_49_Npc_Event_EnterCopyMapID( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "npc_49_Npc_Event_EnterCopyMapID" ),
	{ eventCallBackReturn, [18,25] }.

%%进入副本Npc
npc_85_Npc_Event_EnterCopyMapID( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "npc_85_Npc_Event_EnterCopyMapID" ),
	{ eventCallBackReturn, [19,20,26,27] }.

%%进入副本Npc
npc_69_Npc_Event_EnterCopyMapID( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "npc_69_Npc_Event_EnterCopyMapID" ),
	{ eventCallBackReturn, [21,28] }.

%%进入副本Npc
npc_74_Npc_Event_EnterCopyMapID( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "npc_74_Npc_Event_EnterCopyMapID" ),
	{ eventCallBackReturn, [23,29] }.

npc_89_Npc_Event_EnterCopyMapID( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "npc_89_Npc_Event_EnterCopyMapID" ),
	{ eventCallBackReturn, [34,35,36,37] }.

npc_90_Npc_Event_EnterCopyMapID( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "npc_89_Npc_Event_EnterCopyMapID" ),
	{ eventCallBackReturn, [30,31,32,33] }.

npc_81_Npc_Event_EnterCopyMapID( _Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "npc_81_Npc_Event_EnterCopyMapID" ),
	{ eventCallBackReturn, [39, 40] }.
