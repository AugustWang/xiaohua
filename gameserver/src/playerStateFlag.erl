%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(playerStateFlag).

%%
%% Include files
%%
-include("db.hrl").
-include("playerDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").


-include("trade.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%è¿åæç¶ææ¯å¦å­å¨ï¼å­å¨åè¿åä¸ºtrueï¼å¦åä¸ºfalse
isStateFlag( PlayerID, StateFlag )->
	CurStateFlag = player:getPlayerProperty(PlayerID, #player.stateFlag),
	case CurStateFlag of
		0->false;
		_->
			State = CurStateFlag band StateFlag,
			State > 0
	end.

%%è®¾ç½®ç¶æä¸ºæå¼ï¼åé¨ä¼èªå¨æ£æµæå¢å æç§»é¤æç¶æçæåµï¼è°ç¨onStateFlagChanged
setStateFlag( StateSet )->
	CurStateFlag = player:getCurPlayerProperty( #player.stateFlag ),
	%etsBaseFunc:changeFiled( player:getCurPlayerTable(), player:getCurPlayerID(), #player.stateFlag, StateSet ),
	player:setCurPlayerProperty( #player.stateFlag, StateSet ),
	
	MyFunc = fun( I )->
					 State = 1 bsl I,
					 SetOnOrOff = ( State band StateSet ) /= 0,
					 OldOnOrOff = ( State band CurStateFlag ) /= 0,
					 case SetOnOrOff of
						 true->
							 case OldOnOrOff of
								 true->ok;
								 false->onStateFlagChanged( State, true )
							 end;
						 false->
							 case OldOnOrOff of
								 true->onStateFlagChanged( State, false );
								 false->ok	   
							 end
					 end
			 end,
	playerItems:for( 0, 31, MyFunc ),

	MsgToUser = #pk_ActorStateFlagSet{ nSetStateFlag = StateSet },
	player:send( MsgToUser ),
	ok.
%%å¢å ä¸ç¶æï¼è§%%//	çç©ç¶ææ ç­¾ï¼é»è¾æå³ç³»Actor_State_Flag_Type
addStateFlag( StateFlag )->
	CurStateFlag = player:getCurPlayerProperty( #player.stateFlag ),
	NewStateFlag = CurStateFlag bor StateFlag,
	%etsBaseFunc:changeFiled( player:getCurPlayerTable(), player:getCurPlayerID(), #player.stateFlag, NewStateFlag ),
	player:setCurPlayerProperty( #player.stateFlag, NewStateFlag ),
	onStateFlagChanged( StateFlag, true ),

	MsgToUser = #pk_ActorStateFlagSet{ nSetStateFlag = NewStateFlag },
	player:send( MsgToUser ),
	ok.

%%å é¤ä¸ç¶æï¼è§%%//	çç©ç¶ææ ç­¾ï¼é»è¾æå³ç³»Actor_State_Flag_Type
removeStateFlag( StateFlag )->
	CurStateFlag = player:getCurPlayerProperty( #player.stateFlag ),
	NewStateFlag = CurStateFlag band ( bnot StateFlag ),
	%etsBaseFunc:changeFiled( player:getCurPlayerTable(), player:getCurPlayerID(), #player.stateFlag, NewStateFlag ),
	player:setCurPlayerProperty( #player.stateFlag, NewStateFlag ),
	onStateFlagChanged( StateFlag, false ),

	MsgToUser = #pk_ActorStateFlagSet{ nSetStateFlag = NewStateFlag },
	player:send( MsgToUser ),
	ok.

%%æç¶ææ¹åååºåè°
onStateFlagChanged( _ChangeStateFlag, _AddOrRemove )->
	ok.

%%å¶ä»è¿ç¨éç¥ç¶ææ¹å
on_actorStateFlag( OP, Value )->
	case OP of
		?Actor_State_Flag_OP_Add->addStateFlag( Value );
		?Actor_State_Flag_OP_Remove->removeStateFlag( Value );
		?Actor_State_Flag_OP_Set->setStateFlag( Value );
		_->ok
	end.