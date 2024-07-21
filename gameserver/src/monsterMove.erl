%% Author: Administrator
%% Created: 2012-9-25
%% Description: TODO: Add description to drop
-module(monsterMove).

%%
%% Include files
%%
-include("mapDefine.hrl").
-include("pc_player.hrl").
-include("playerDefine.hrl").
-include("hdlt_logger.hrl").
-include("charDefine.hrl").
-include("monsterDefine.hrl").
%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% API Functions
%%

%%//      A                               
%%//       \                        
%%//        M                  
%%//         \                        
%%//          B                 
%%// æ±å·²ç¥ç¹A(pos_beg)ï¼ç¹B(pos_end)ï¼fDistLä¸ç­äº0.0fï¼è¡¨ç¤ºå·²ç¥AMï¼æ±Mç¹åæ ï¼å¦åæ¯å·²ç¥MBï¼fDistRï¼æ±Mç¹åæ 
getDingBiFengDian( #posInfo{}=Pos_beg, #posInfo{}=Pos_end, DistL, DistR )->
	try
		DX = Pos_beg#posInfo.x - Pos_end#posInfo.x,
		DY = Pos_beg#posInfo.y - Pos_end#posInfo.y,
		DistSQ = DX*DX + DY*DY,
		Sqr = math:sqrt( DistSQ ),
		case ( Sqr >= -0.0001 ) andalso ( Sqr =< 0.0001 ) of
			true->throw(-1);
			false->ok
		end,
		
		case DistL =:= 0 of
			true->
				case ( DistR >= -0.0001 ) andalso ( DistR =< 0.0001 ) of
					true->throw(-1);
					false->ok
				end,
				DistL2 = Sqr - DistR,
				Sqr_DiskL = Sqr - DistL2,
				case ( Sqr_DiskL >= -0.0001 ) andalso ( Sqr_DiskL =< 0.0001 ) of
					true->throw(-1);
					false->ok
				end,
				R = DistL2 / Sqr_DiskL,
				#posInfo{ x=erlang:trunc( ( Pos_beg#posInfo.x + R * Pos_end#posInfo.x ) / ( 1+R) ), 
						  y=erlang:trunc( ( Pos_beg#posInfo.y + R * Pos_end#posInfo.y ) / ( 1+R) )};
			false->
				DistL3 = Sqr - DistL,
				Sqr_DiskL2 = Sqr - DistL3,
				case ( Sqr_DiskL2 >= -0.0001 ) andalso ( Sqr_DiskL2 =< 0.0001 ) of
					true->throw(-1);
					false->ok
				end,
				R2 = DistL3 / Sqr_DiskL2,
				#posInfo{ x=erlang:trunc( ( Pos_beg#posInfo.x + R2 * Pos_end#posInfo.x ) / ( 1+R2) ), 
						  y=erlang:trunc( ( Pos_beg#posInfo.y + R2 * Pos_end#posInfo.y ) / ( 1+R2) )}
				
		end
	catch
		_->Pos_end
	end.


moveUpdate(Monster, TimeDt) ->
	case canMove(Monster) of
		true ->
			case Monster#mapMonster.moveTargetList of
				[] ->
					%%ç§»å¨æ°æ®å·²ç»å¤çå®äºï¼æ¹åç¶æ
					setMoveState(Monster, ?Object_MoveState_Stand);
				_ ->
					[M|L] = Monster#mapMonster.moveTargetList,
				case M of
					{} ->
						setMoveTargetList(Monster, L),
						moveUpdate(Monster, TimeDt);
					_ ->
						updatePos(Monster, M, TimeDt)
				end
			end;
		false ->
			stopMove(Monster, false)
	end.

canMove(Monster) ->
	State = ?Actor_State_Flag_Dead bor ?Actor_State_Flag_Disable_Move bor ?Actor_State_Flag_Disable_Hold,
	case (Monster#mapMonster.stateFlag band State) /= 0 of
		true ->
			%% add by wenziyong for dummy monster
			case (?Monster_State_Flag_GoBacking band Monster#mapMonster.stateFlag ) /= 0 of
				true ->
					?ERROR_OUT("---for dummy monster,canMove stateFlag error:~p ",
							[Monster#mapMonster.stateFlag]),
					true;
				false ->
					false
			end;
		false ->
			true
	end.

canMoveById(MonsterId) ->
	case etsBaseFunc:readRecord(map:getMapMonsterTable(), MonsterId) of
		{} ->
			failed;
		Monster ->
			canMove(Monster)
	end.

getCurMoveTargetPos(Monster) ->
	case Monster#mapMonster.moveTargetList of
		[] ->{};
		[MoveInfo|_] ->
			MoveInfo 
	end.

getCurMoveTargetPosById(MonsterId) ->
	case etsBaseFunc:readRecord(map:getMapMonsterTable(), MonsterId) of
		{} ->{};
		Monster->
			getCurMoveTargetPos(Monster)
	end.

moveTo(Monster, X_In, Y_In ) ->
	case canMove(Monster) of
		true ->
			X = erlang:trunc( X_In ),
			Y = erlang:trunc( Y_In ),
			case mapManager:getMapView(Monster#mapMonster.map_data_id) of
				{} ->
					ok;
				MapView ->
					case X>=0 andalso Y>=0 andalso X=<MapView#mapView.width andalso Y=<MapView#mapView.height of
						true ->
							setMoveState(Monster, ?Object_MoveState_Moving),
							setMoveTargetList(Monster, [#posInfo{x=X, y=Y}]),
							%%å¹¿æ­æªç©ç§»å¨
							Msg=#pk_MonsterMoveInfo{ids=[#pk_MoveInfo{
																	  id=Monster#mapMonster.id,
																	  posX=erlang:trunc(Monster#mapMonster.pos#posInfo.x),
																	  posY=erlang:trunc(Monster#mapMonster.pos#posInfo.y),
																	  posInfos=[#pk_PosInfo{x=X,y=Y}]}]},
							mapView:broadcast(Msg, Monster, 0);
						false ->
							ok
					end
			end;
		false ->ok
	end.

setPos(Monster, X_In, Y_In) ->
	X=erlang:trunc(X_In),
	Y=erlang:trunc(Y_In),
	stopMove(Monster),

	MonsterNew = mapView:setObjectPos(Monster, X, Y),
	mapView:broadcast(#pk_ActorSetPos{actorId=Monster#mapMonster.id, x=X, y=Y}, MonsterNew, 0).

moveToById(MonsterId, X, Y) ->
	case etsBaseFunc:readRecord(map:getMapMonsterTable(), MonsterId) of
		{} ->failed;
		Monster ->
			moveTo(Monster, X, Y),
			succeed
	end.

stopMove(Monster)->
	stopMove( Monster, true ).

stopMove(Monster, IsBroadcast) ->
	setMoveState(Monster, ?Object_MoveState_Stand),
	setMoveTargetList(Monster, []),
	%%å¹¿æ­æªç©åæ­¢ç§»å¨
	case IsBroadcast of
		true->
			Msg = #pk_MonsterStopMove{
					  id=Monster#mapMonster.id, 
					  x=erlang:trunc(Monster#mapMonster.pos#posInfo.x), 
					  y=erlang:trunc(Monster#mapMonster.pos#posInfo.y)},
			mapView:broadcast(Msg, Monster, 0);
		_->ok
	end.

stopMoveById(MonsterId) ->
	case etsBaseFunc:readRecord(map:getMapMonsterTable(), MonsterId) of
		{} ->failed;
		Monster ->
			stopMove(Monster),
			succeed
	end.

isMoving(Monster) ->
	case Monster#mapMonster.moveState of
		?Object_MoveState_Moving ->
			true;
		_ ->false
	end.

isMovingById(MonsterId) -> 
	case etsBaseFunc:readRecord(map:getMapMonsterTable(), MonsterId) of
		{} ->failed;
		Monster ->
			isMoving(Monster)
	end.
	

setMoveState(Monster, State) ->
	etsBaseFunc:changeFiled(map:getMapMonsterTable(), Monster#mapMonster.id, #mapMonster.moveState, State).

setMoveStateById(MonsterId, State) ->
	case etsBaseFunc:readRecord(map:getMapMonsterTable(), MonsterId) of
		{} ->failed;
		Monster ->
			setMoveState(Monster, State)
	end.

setMoveTargetList(Monster, List) ->
	etsBaseFunc:changeFiled(map:getMapMonsterTable(), Monster#mapMonster.id, #mapMonster.moveTargetList, List).

setMoveTargetListById(MonsterId, List) ->
	case etsBaseFunc:readRecord(map:getMapMonsterTable(), MonsterId) of
		{} ->failed;
		Monster->
			setMoveTargetList(Monster,List)
	end.


updatePos(Monster, DestPos, TimeDt) ->
	try
			DirX = DestPos#posInfo.x-Monster#mapMonster.pos#posInfo.x,
			DirY = DestPos#posInfo.y-Monster#mapMonster.pos#posInfo.y,
			L = math:sqrt(DirX*DirX + DirY*DirY),
			Speed = array:get(?move_speed, Monster#mapMonster.finalProperty),
			case L /= 0 of
				true->
					Pos = #posInfo{x=Monster#mapMonster.pos#posInfo.x+DirX/L*TimeDt*Speed,
								   y=Monster#mapMonster.pos#posInfo.y+DirY/L*TimeDt*Speed};
				false->
					Pos = #posInfo{x=Monster#mapMonster.pos#posInfo.x,
								   y=Monster#mapMonster.pos#posInfo.y}
			end,
	
			case Monster#mapMonster.aiState of
				?Monster_AI_State_Idle->
					case mapView:isBlock(map:getMapDataID(), erlang:trunc(Pos#posInfo.x), erlang:trunc(Pos#posInfo.y)) of
						true->
							stopMove(Monster),
							throw(-1);
						false->ok
					end;
				_->ok
			end,
	
			DirX2 = DestPos#posInfo.x-Pos#posInfo.x,
			DirY2 = DestPos#posInfo.y-Pos#posInfo.y,
			L2 = math:sqrt(DirX2*DirX2+DirY2*DirY2),

			_Log = false,
	
			case L2 < Speed*TimeDt of
				true ->
					%%ç§»å¨å°å½åç®æ ç¹ï¼å é¤å½åç®æ ç¹
					MonsterNew = mapView:setObjectPos( Monster, DestPos#posInfo.x, DestPos#posInfo.y),

%% 			case Log of
%% 				true ->
%% 					?DEBUG_OUT("[monsterMove]monsterId=~p, frontPos={x=~p; y=~p}, noncePos={x=~p; y=~p}, destPos={x=~p,y=~p}, speed=~p, timeDt=~p",
%% 							   [Monster#mapMonster.id, Monster#mapMonster.pos#posInfo.x, Monster#mapMonster.pos#posInfo.y, DestPos#posInfo.x, DestPos#posInfo.y, 
%% 								DestPos#posInfo.x, DestPos#posInfo.y, Monster#mapMonster.speed, TimeDt]);
%% 				false->
%% 					ok
%% 			end,
			
					[_|TargetList] = MonsterNew#mapMonster.moveTargetList,
					case TargetList of
						[] ->
							%%ç§»å¨æ°æ®å·²ç»å¤çå®äºï¼åæ­¢ç§»å¨
							stopMoveById(MonsterNew#mapMonster.id);
						_ ->
							setMoveTargetList(MonsterNew,TargetList)
					end;
				false ->
					mapView:setObjectPos( Monster, Pos#posInfo.x, Pos#posInfo.y)

%% 			case Log of
%% 				true ->
%% 					?DEBUG_OUT("[monsterMove]monsterId=~p, frontPos={x=~p; y=~p}, noncePos={x=~p; y=~p}, destPos={x=~p,y=~p}, speed=~p, timeDt=~p",
%% 							   [Monster#mapMonster.id, Monster#mapMonster.pos#posInfo.x, Monster#mapMonster.pos#posInfo.y, erlang:trunc(Pos#posInfo.x), erlang:trunc(Pos#posInfo.y), 
%% 								DestPos#posInfo.x, DestPos#posInfo.y, Monster#mapMonster.speed, TimeDt]);
%% 				false->
%% 					ok
%% 			end
			end
	catch 
		_->ok
end.