%% Author: Administrator
%% Created: 2012-7-9
%% Description: TODO: Add description to db
-module(map_Msg).

%%
%% Include files
%%
-include("package.hrl").
-include("db.hrl").
-include("hdlt_logger.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("playerDefine.hrl").
-include("mapDefine.hrl").


%%
%% Exported Functions
%%
-compile(export_all). 

on_msgFromPlayerSocket( PlayerID, Msg )->
	case element( 1, Msg ) of
		pk_U2GS_InteractObject->
			objectActor:onMsg_U2GS_InteractObject( PlayerID, Msg );
		pk_U2GS_QueryHeroProperty->
			playerMap:on_U2GS_QueryHeroProperty( PlayerID );
		pk_U2GS_EnterCopyMapRequest->
			playerChangeMap:on_U2GS_EnterCopyMapRequest( PlayerID, Msg );
		pk_U2GS_QueryMyCopyMapCD->
			playerChangeMap:on_U2GS_QueryMyCopyMapCD( PlayerID, Msg );
		pk_U2GS_TransByWorldMap->
			playerChangeMap:transPlayerByWorldMap(PlayerID, Msg);
		pk_U2GS_FastTeamCopyMapRequest->
			playerChangeMap:on_U2GS_FastTeamCopyMapRequest( PlayerID, Msg );
		pk_U2GS_QieCuoInvite->
			qieCuo:on_U2GS_QieCuoInvite( PlayerID, Msg );
		pk_U2GS_QieCuoInviteAck->
			qieCuo:on_U2GS_QieCuoInviteAck( PlayerID, Msg );
		pk_U2GS_PK_KillOpenRequest->
			qieCuo:on_U2GS_PK_KillOpenRequest( PlayerID, Msg );
		pk_U2GS_RestCopyMapRequest->
			playerChangeMap:on_U2GS_RestCopyMapRequest(PlayerID, Msg);
		_->
			?LOG_OUT( "on_msgFromPlayerSocket unkown PlayerID[~p] Msg[~p]", [PlayerID, Msg] )
	end.


