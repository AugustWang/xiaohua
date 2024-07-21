%% Author: Administrator
%% Created: 2012-9-25
%% Description: TODO: Add description to drop
-module(playerMove).

%%
%% Include files
%%
-include("playerDefine.hrl").
-include("pc_player.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("charDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% API Functions
%%

moveUpdate(Player, TimeDt) ->
	case canMove(Player) of
		true ->
			case Player#mapPlayer.moveTargetList=:=[] andalso Player#mapPlayer.moveDir=:=?eDirection_NULL of
				true->
					%%移动数据已经处理完了，改变状态
					setMoveState(Player, ?Object_MoveState_Stand);
				_ ->
					case Player#mapPlayer.moveTargetList of
						[]->
							case Player#mapPlayer.moveDir=:=?eDirection_NULL of
								true->
									setMoveState(Player, ?Object_MoveState_Stand);
								_->
									case updatePosByDir( Player, Player#mapPlayer.moveDir, TimeDt, true) of
										true->ok;
										_->ok
									end
							end;
						_->
							[M|L] = Player#mapPlayer.moveTargetList,
							case M of
								{} ->
									setMoveTargetList(Player, L),
									moveUpdate(Player, TimeDt);
								_ ->
									updatePos(Player, M, TimeDt)							
							end
					end
			end;
		false ->
			stopMove(Player)
	end.

setPos(Player, X_In, Y_In) ->
	X=erlang:trunc(X_In),
	Y=erlang:trunc(Y_In),
	stopMove(Player),	

	Player2 = mapView:setObjectPos(Player, X, Y),
	mapView:broadcast(#pk_ActorSetPos{actorId=Player#mapPlayer.id, x=X, y=Y}, Player2, 0).

canMove(Player) ->
	State = ?Actor_State_Flag_Dead bor ?Actor_State_Flag_Disable_Move bor ?Actor_State_Flag_Disable_Hold bor ?Player_State_Flag_Just_Disable_Move,
	case (Player#mapPlayer.stateFlag band State) /= 0 of
		true ->
			false;
		false ->
			true
	end.

canMoveById(PlayerId) ->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerId) of
		{} ->
			failed;
		Player ->
			canMove(Player)
	end.

isMoving(Player) ->
	case Player#mapPlayer.moveState bsr 2 of
		?Object_MoveState_Moving->
			true;
		_->false
	end.

isMovingById(PlayerId) ->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerId) of
		{} -> failed;
		Player ->
			isMoving(Player),
			succeed
	end.

isFlying(Player) ->
	case Player#mapPlayer.moveState band 1 of
		?Object_FlyState_Flying->
			true;
		_->false
	end.

isFlyingById(PlayerId) ->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerId) of
		{} ->failed;
		Player ->
			isFlying(Player),
			succeed
	end.

%%返回物件的移动速度
getMoveSpeed( Object )->
	case element( 1, Object ) of
		mapPlayer->array:get( ?move_speed, Object#mapPlayer.finalProperty );
		mapMonster->array:get( ?move_speed, Object#mapMonster.finalProperty );
		mapPet->array:get( ?move_speed, Object#mapPet.finalProperty );
		_->0
	end.

setMoveState(Player, State) ->
	FlyState = Player#mapPlayer.moveState band 1,
	S = (State bsl 2) bor FlyState, 
	etsBaseFunc:changeFiled(map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.moveState, S).

setMoveStateById(PlayerId, State) ->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerId) of
		{} -> falied;
		Player ->
			setMoveState(Player, State),
			succeed
	end.

setFlyState(Player, State) ->
	MoveState = Player#mapPlayer.moveState bsr 2,
	S = (MoveState bsl 2) bor State, 
	etsBaseFunc:changeFiled(map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.moveState, S).

setFlyStateById(PlayerId, State) ->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerId) of
		{}->failed;
		Player ->
			setFlyState(Player, State),
			succeed
	end.

setMoveTargetList(Player, List) ->
	etsBaseFunc:changeFiled(map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.moveTargetList, List).

setMoveTargetListById(PlayerId, List) ->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerId) of
		{} ->
			failed;
		Player ->
			setMoveTargetList(Player, List),
			succeed
	end.

setMoveDir( Player, Dir )->
	etsBaseFunc:changeFiled(map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.moveDir, Dir).

setMoveDirByID( PlayerID, Dir )->
	etsBaseFunc:changeFiled(map:getMapPlayerTable(), PlayerID, #mapPlayer.moveDir, Dir).

getCurMoveTargetPos(Player) ->
	case Player#mapPlayer.moveTargetList of
		[] ->{};
		[MoveInfo|_] ->
			MoveInfo 
	end.

getCurMoveTargetPosById(PlayerId) ->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerId) of
		{} ->{};
		Player->
			getCurMoveTargetPos(Player)
	end.

moveTo(Player, TargetList) ->
	case (TargetList/=[]) andalso canMove(Player) of
		false ->
			ok;
		true ->
			setMoveState(Player, ?Object_MoveState_Moving),
			setMoveTargetList(Player, TargetList),
			
			Fun = fun(P) ->
						  #pk_PosInfo{x=P#posInfo.x, y=P#posInfo.y}
				  end,
			
			%%广播移动消息
			Msg = #pk_PlayerMoveInfo{ids = [#pk_MoveInfo{
														 id=Player#mapPlayer.id,
														 posX=erlang:trunc(Player#mapPlayer.pos#posInfo.x),
														 posY=erlang:trunc(Player#mapPlayer.pos#posInfo.y),
														 posInfos=lists:map(Fun, TargetList) }]},
			
			%%?DEBUG_OUT( "player[~p] moveTo Msg[~p]", [Player#mapPlayer.name, Msg] ),
			
			mapView:broadcast(Msg, Player, Player#mapPlayer.id)
			
			%%?DEBUG_OUT( "player[~p] moveTo pass", [Player#mapPlayer.name] )
	end.

moveToById(PlayerId, TargetList) ->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerId) of
		{} ->
			failed;
		Player ->
			moveTo(Player, TargetList),
			succeed
	end.

dirMoveTo( Player, Dir )->
	case canMove(Player) of
		false->ok;
		_->
			setMoveState(Player, ?Object_MoveState_Moving),
			setMoveDir(Player, Dir),
			etsBaseFunc:changeFiled(map:getMapPlayerTable(), Player#mapPlayer.id, #mapPlayer.moveRealDir, ?eDirection_NULL),
			
			%%广播移动消息
			Msg = #pk_PlayerDirMove_S2C{
										player_id=Player#mapPlayer.id, 
										pos_x=Player#mapPlayer.pos#posInfo.x, 
										pos_y=Player#mapPlayer.pos#posInfo.y,
										dir=Dir},
			mapView:broadcast(Msg, Player, Player#mapPlayer.id)
	end.

dirMoveToByID( PlayerID, Dir )->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerID) of
		{} ->
			failed;
		Player ->
			dirMoveTo(Player, Dir),
			succeed
	end.

stopMove(Player) ->
	setMoveState(Player, ?Object_MoveState_Stand),
	setMoveTargetList(Player, []),
	setMoveDir( Player, ?eDirection_NULL),
	etsBaseFunc:changeFiled(map:getMapPlayerTable(), #mapPlayer.id, #mapPlayer.moveRealDir, ?eDirection_NULL),
	%%广播消息
	Msg = #pk_PlayerStopMove_S2C{id=Player#mapPlayer.id, posX=erlang:trunc(Player#mapPlayer.pos#posInfo.x), posY=erlang:trunc(Player#mapPlayer.pos#posInfo.y)},
	mapView:broadcast(Msg, Player, Player#mapPlayer.id).

stopMoveById(PlayerId) ->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerId) of
		{} ->
			failed;
		Player ->
			stopMove(Player),
			succeed
	end.
		
%%摇杆移动
updatePosByDir( PlayerIn, Dir, TimeDt, IsEnter ) ->
	case map:getPlayerDirValue(Dir) of
		{}->false;
		DirValue->
			DirX = DirValue#posInfo.x,
			DirY = DirValue#posInfo.y,
			Speed = array:get(?move_speed, PlayerIn#mapPlayer.finalProperty),
			Dist = Speed*TimeDt,
			Pos = #posInfo{ 
						   x=erlang:trunc(PlayerIn#mapPlayer.pos#posInfo.x+DirX*Dist),
						   y=erlang:trunc(PlayerIn#mapPlayer.pos#posInfo.y+DirY*Dist) },
			
			ColX = Pos#posInfo.x,
			RowY = Pos#posInfo.y,
			
			case Dist > 5 of
				true->
					put( "IsPassByBlock", false ),
					Fun = fun( Index )->
								  Col2 = erlang:trunc(PlayerIn#mapPlayer.pos#posInfo.x+DirX*Index*5),
								  Row2 = erlang:trunc(PlayerIn#mapPlayer.pos#posInfo.y+DirY*Index*5),
								  case mapView:isBlock( map:getMapDataID(), Col2, Row2 ) of
									  true->
										  put( "IsPassByBlock", true );
									  _->ok
								  end
						  end,
					common:for(1, erlang:trunc(Dist) div 5, Fun),
					IsPassByBlock=get( "IsPassByBlock" );
				_->
					IsPassByBlock=false
			end,
			
			%%目标点是阻挡，尝试向侧方移动
			case mapView:isBlock( map:getMapDataID(), ColX, RowY ) orelse IsPassByBlock of
				true->
					case IsEnter of
						true->
							case PlayerIn#mapPlayer.moveRealDir /= PlayerIn#mapPlayer.moveDir andalso PlayerIn#mapPlayer.moveRealDir /= ?eDirection_NULL of
								true->
									case updatePosByDir( PlayerIn, PlayerIn#mapPlayer.moveRealDir, TimeDt, false ) of
										true->IsGoOn = false;
										_->IsGoOn = true
									end;
								_->IsGoOn = true
							end,
							case IsGoOn of
								true->
									case Dir of
										?eDirection_Left->
											Dir1 = ?eDirection_Up,
											Dir2 = ?eDirection_Down;
										?eDirection_Right->
											Dir1 = ?eDirection_Down,
											Dir2 = ?eDirection_Up;
										?eDirection_Up->
											Dir1 = ?eDirection_Right,
											Dir2 = ?eDirection_Left;
										?eDirection_Down->
											Dir1 = ?eDirection_Left,
											Dir2 = ?eDirection_Right;
										?eDirection_LeftUp->
											Dir1 = ?eDirection_Up,
											Dir2 = ?eDirection_Left;
										?eDirection_RightUp->
											Dir1 = ?eDirection_Right,
											Dir2 = ?eDirection_Up;
										?eDirection_LeftDown->
											Dir1 = ?eDirection_Left,
											Dir2 = ?eDirection_Down;
										?eDirection_RightDown->
											Dir1 = ?eDirection_Down,
											Dir2 = ?eDirection_Right;
										_->
											Dir1 = ?eDirection_NULL,
											Dir2 = ?eDirection_NULL
									end,
									
									case Dir1 /= ?eDirection_NULL andalso Dir2 /= ?eDirection_NULL of
										true->
											case updatePosByDir(PlayerIn, Dir1, TimeDt, false ) of
												true->
													true;
												_->
													updatePosByDir(PlayerIn, Dir2, TimeDt, false )
											end;
										_->false
									end;
								_->true
							end;
						_->
							false
					end;
				_->
					etsBaseFunc:changeFiled(map:getMapPlayerTable(), PlayerIn#mapPlayer.id, #mapPlayer.moveRealDir, Dir),
					mapView:setObjectPos(PlayerIn, Pos#posInfo.x, Pos#posInfo.y ),
					true
			end
	end.


updatePos(PlayerIn, DestPos, TimeDt) ->
	DirX = DestPos#posInfo.x-PlayerIn#mapPlayer.pos#posInfo.x,
	DirY = DestPos#posInfo.y-PlayerIn#mapPlayer.pos#posInfo.y,
	L = math:sqrt(DirX*DirX + DirY*DirY),
	Speed = array:get(?move_speed, PlayerIn#mapPlayer.finalProperty),
	Dist = TimeDt*Speed,
	case L /= 0 of
		true ->
				Pos = #posInfo{x=PlayerIn#mapPlayer.pos#posInfo.x+DirX/L*Dist,
				  		 y=PlayerIn#mapPlayer.pos#posInfo.y+DirY/L*Dist};
		false ->
				Pos = #posInfo{x=PlayerIn#mapPlayer.pos#posInfo.x,
				  		 y=PlayerIn#mapPlayer.pos#posInfo.y}
	end,
	
	DirX2 = DestPos#posInfo.x-Pos#posInfo.x,
	DirY2 = DestPos#posInfo.y-Pos#posInfo.y,
	L2 = math:sqrt(DirX2*DirX2+DirY2*DirY2),
	
	%Log = false,
	
	case L2 < Dist of
		true ->
			%%移动到当前目标点，删除当前目标点
			Player = mapView:setObjectPos(PlayerIn, DestPos#posInfo.x, DestPos#posInfo.y),
			
			[_|TargetList] = Player#mapPlayer.moveTargetList,
			case TargetList of
				[] ->
					%%移动数据已经处理完了，停止移动
%% 					case Log of
%% 						true ->
%% 							?DEBUG_OUT("【playerMove】playerId=~p, stop move", [Player#mapPlayer.id]);
%% 						false->
%% 							ok
%% 					end,
					stopMoveById(Player#mapPlayer.id);
				_ ->
					setMoveTargetList(Player,TargetList)
			end;
		false ->
			mapView:setObjectPos(PlayerIn, Pos#posInfo.x, Pos#posInfo.y)
	end,
	ok.
	
	

onPlayerMoveTo(PlayerId, #pk_PlayerMoveTo{}=P) ->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerId) of
		{} ->
			ok;
		Player ->
			%IsFightState = mapActorStateFlag:isStateFlag(PlayerId, ?Actor_State_Flag_Fighting),
			Fun = fun(MoveInfo) ->
						  #posInfo{x=MoveInfo#pk_PosInfo.x, y=MoveInfo#pk_PosInfo.y}
				  end,
			TargetList = lists:map(Fun, P#pk_PlayerMoveTo.posInfos),
			
			%%位置验证
			DirX = Player#mapPlayer.pos#posInfo.x-P#pk_PlayerMoveTo.posX,
			DirY = Player#mapPlayer.pos#posInfo.y-P#pk_PlayerMoveTo.posY,
			L = math:sqrt(DirX*DirX+DirY*DirY),
			
			try
				case L < ?Client_Server_Max_Deviation of
					true ->
						throw({P#pk_PlayerMoveTo.posX, P#pk_PlayerMoveTo.posY});
					false ->
						?ERROR_OUT("[onPlayerMoveTo]pos check failed id=~p, posX=~p, posY=~p", [PlayerId, P#pk_PlayerMoveTo.posX, P#pk_PlayerMoveTo.posY]),
						throw({P#pk_PlayerMoveTo.posX, P#pk_PlayerMoveTo.posY})
				end
			
			catch
				{X,Y}->
					%%通过位置点移动，取消方向移动
					setMoveDir( Player, ?eDirection_NULL),
					Player2 = mapView:setObjectPos(Player, X, Y),
					moveToById(Player2#mapPlayer.id, TargetList)
			end
	end.

onPlayerDirMove( PlayerID, P )->
	case map:getPlayerDirValue(P#pk_PlayerDirMove.dir) of
		{}->ok;		%%方向不正确。
		_->
			case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerID) of
				{} ->
					ok;
				Player ->
					%%IsFightState = mapActorStateFlag:isStateFlag(PlayerID, ?Actor_State_Flag_Fighting),
					
					%%位置验证
					DirX = Player#mapPlayer.pos#posInfo.x-P#pk_PlayerDirMove.pos_x,
					DirY = Player#mapPlayer.pos#posInfo.y-P#pk_PlayerDirMove.pos_y,
					L = math:sqrt(DirX*DirX+DirY*DirY),
					
					try
						case L < ?Client_Server_Max_Deviation of
							true ->
								throw({P#pk_PlayerDirMove.pos_x, P#pk_PlayerDirMove.pos_y});
							false ->
								?ERROR_OUT("[onPlayerMoveTo]pos check failed id=~p, posX=~p, posY=~p", [PlayerID, P#pk_PlayerDirMove.pos_x, P#pk_PlayerDirMove.pos_y]),
								throw({P#pk_PlayerDirMove.pos_x, P#pk_PlayerDirMove.pos_y})
						end
					
					catch
						{X,Y}->
							%%通过方向移动，取消位置点移动
							setMoveTargetList(Player, []),
							mapView:setObjectPos(Player, X, Y),
							dirMoveToByID(PlayerID, P#pk_PlayerDirMove.dir)
					end
			end
end.

onPlayerTeleportMove( PlayerID, P )->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerID) of
		{}->ok;
		Player->
			case playerMove:canMove(Player) of
				true->
					PosX = P#pk_PlayerTeleportMove.pos_x,
					PosY = P#pk_PlayerTeleportMove.pos_y,
					CurPosX = Player#mapPlayer.pos#posInfo.x,
					CurPosY = Player#mapPlayer.pos#posInfo.y,
					Dis = (PosX-CurPosX)*(PosX-CurPosX)+(PosY-CurPosY)*(PosY-CurPosY),
					case Dis < ?MaxTeleportMoveDis*?MaxTeleportMoveDis of
						true->
							case mapView:isBlock( map:getMapDataID(), PosX, PosY ) of
								true->ok;
								_->
									mapView:setObjectPos(Player, PosX, PosY ),
									mapView:broadcast(#pk_PlayerTeleportMove_S2C{
																				 player_id=PlayerID,
																				 pos_x=PosX,
																				 pos_y=PosY}, Player, 0)
							end;
						_->
							ok
					end;
				_->ok
			end
	end.
		
onPlayerStopMove(PlayerId, P)->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerId) of
		{} ->
			ok;
		Player ->
			%%位置验证
			DirX = Player#mapPlayer.pos#posInfo.x-P#pk_PlayerStopMove.posX,
			DirY = Player#mapPlayer.pos#posInfo.y-P#pk_PlayerStopMove.posY,
			L = math:sqrt(DirX*DirX+DirY*DirY),
			
			try
				case L < ?Client_Server_Max_Deviation of
					true ->
						throw({P#pk_PlayerStopMove.posX,P#pk_PlayerStopMove.posY});
					false ->
						?ERROR_OUT("[onPlayerStopMove]pos check failed id=~p, posX=~p, posY=~p", [PlayerId, P#pk_PlayerStopMove.posX, P#pk_PlayerStopMove.posY]),
						throw({P#pk_PlayerStopMove.posX,P#pk_PlayerStopMove.posY})
				end
			catch
				{X,Y}->
					%%改变位置
					mapView:setObjectPos(Player, X, Y),

					stopMoveById(PlayerId)
			end,
			ok
	end.

onChangeFlyState(PlayerId, P) ->
	case etsBaseFunc:readRecord(map:getMapPlayerTable(), PlayerId) of
		{} ->
			ok;
		Player ->
			setFlyState(Player, P#pk_ChangeFlyState.flyState),
			%%广播
			Msg = #pk_ChangeFlyState_S2C{id=PlayerId, flyState=P#pk_ChangeFlyState.flyState},
			mapView:broadcast(Msg, Player, 0)
	end.

		