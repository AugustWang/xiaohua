%% Author: Administrator
%% Created: 2012-9-25
%% Description: TODO: Add description to drop
-module(petMove).

%%
%% Include files
%%
-include("mapDefine.hrl").
-include("pc_player.hrl").
-include("playerDefine.hrl").
-include("charDefine.hrl").
%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% API Functions
%%

moveUpdate(Pet, TimeDt) ->
	case canMove(Pet) of
		true ->
			case Pet#mapPet.moveTargetList of
				[] ->
					%%移动数据处理完毕，停止移动
					setMoveState(Pet, ?Object_MoveState_Stand);
				_ ->
					[M|L] = Pet#mapPet.moveTargetList,
				case M of
					{} ->
						setMoveTargetList(Pet, L),
						moveUpdate(Pet, TimeDt);
					_ ->
					updatePos(Pet, M, TimeDt)
				end
			end;
		false ->
			stopMove(Pet)
	end.

setPos(Pet, X_In, Y_In) ->
	X=erlang:trunc(X_In),
	Y=erlang:trunc(Y_In),
	stopMove(Pet),
	PetNew = mapView:setObjectPos(Pet, X, Y),
	mapView:broadcast(#pk_ActorSetPos{actorId=Pet#mapPet.id, x=X, y=Y}, PetNew, 0).

canMove(Pet) ->
	State = ?Actor_State_Flag_Dead bor ?Actor_State_Flag_Disable_Move bor ?Actor_State_Flag_Disable_Hold,
	case (Pet#mapPet.stateFlag band State) /= 0 of
		true ->
			false;
		false ->
			true
	end.

canMoveById(PetId) ->
	case etsBaseFunc:readRecord(map:getMapPetTable(), PetId) of
		{} ->
			failed;
		Pet ->
			canMove(Pet)
	end.

getCurMoveTargetPos(Pet) ->
	case Pet#mapPet.moveTargetList of
		[] ->{};
		[MoveInfo|_] ->
			MoveInfo 
	end.

getCurMoveTargetPosById(PetId) ->
	case etsBaseFunc:readRecord(map:getMapPetTable(), PetId) of
		{} ->{};
		Pet->
			getCurMoveTargetPos(Pet)
	end.

moveTo(Pet, X_In, Y_In ) ->
	case canMove(Pet) of
		true ->
			X = erlang:trunc( X_In ),
			Y = erlang:trunc( Y_In ),
			
			setMoveState(Pet, ?Object_MoveState_Moving),
			setMoveTargetList(Pet, [#posInfo{x=X, y=Y}]),
			
			PetNew = mapView:setObjectPos(Pet, Pet#mapPet.pos#posInfo.x, Pet#mapPet.pos#posInfo.y),
			%%发送消息给客户端
			Msg=#pk_PetMoveInfo{ids=[#pk_MoveInfo{
													  id=Pet#mapPet.id,
													  posX=erlang:trunc(Pet#mapPet.pos#posInfo.x),
													  posY=erlang:trunc(Pet#mapPet.pos#posInfo.y),
													  posInfos=[#pk_PosInfo{x=X,y=Y}]}
												 ]},
			mapView:broadcast(Msg, PetNew, 0);
		false ->
			ok
	end.

%%宠物瞬移
jumpTo(Pet, X_In, Y_In) ->
	X = erlang:trunc(X_In),
	Y = erlang:trunc(Y_In),
	case (X<0) or (Y < 0) of
		true->ok;
		false ->
			stopMove(Pet),
			PetNew = mapView:setObjectPos(Pet, X, Y),
			
			%%通知客户端
			Msg = #pk_PetJumpTo{petId=Pet#mapPet.id, x=X, y=Y},
			mapView:broadcast(Msg, PetNew, 0)
	end.
	

moveToById(PetId, X, Y) ->
	case etsBaseFunc:readRecord(map:getMapPetTable(), PetId) of
		{} ->failed;
		Pet ->
			moveTo(Pet, X, Y),
			succeed
	end.

stopMove(Pet) ->
	setMoveState(Pet, ?Object_MoveState_Stand),
	setMoveTargetList(Pet, []),
	%%广播停止移动的消息
	Msg = #pk_PetStopMove{
			  id=Pet#mapPet.id, 
			  x=erlang:trunc(Pet#mapPet.pos#posInfo.x), 
			  y=erlang:trunc(Pet#mapPet.pos#posInfo.y)},
	mapView:broadcast(Msg, Pet, 0).

stopMoveById(PetId) ->
	case etsBaseFunc:readRecord(map:getMapPetTable(), PetId) of
		{} ->failed;
		Pet ->
			stopMove(Pet),
			succeed
	end.

isMoving(Pet) ->
	case Pet#mapPet.moveState of
		?Object_MoveState_Moving ->
			true;
		_ ->false
	end.

isMovingById(PetId) -> 
	case etsBaseFunc:readRecord(map:getMapPetTable(), PetId) of
		{} ->failed;
		Pet ->
			isMoving(Pet)
	end.
	

setMoveState(Pet, State) ->
	etsBaseFunc:changeFiled(map:getMapPetTable(), Pet#mapPet.id, #mapPet.moveState, State).

setMoveStateById(PetId, State) ->
	case etsBaseFunc:readRecord(map:getMapPetTable(), PetId) of
		{} ->failed;
		Pet ->
			setMoveState(Pet, State)
	end.

setMoveTargetList(Pet, List) ->
	etsBaseFunc:changeFiled(map:getMapPetTable(), Pet#mapPet.id, #mapPet.moveTargetList, List).

setMoveTargetListById(PetId, List) ->
	case etsBaseFunc:readRecord(map:getMapPetTable(), PetId) of
		{} ->failed;
		Pet->
			setMoveTargetList(Pet,List)
	end.


updatePos(Pet, DestPos, TimeDt) ->
	DirX = DestPos#posInfo.x-Pet#mapPet.pos#posInfo.x,
	DirY = DestPos#posInfo.y-Pet#mapPet.pos#posInfo.y,
	L = math:sqrt(DirX*DirX + DirY*DirY),
	Speed = array:get(?move_speed, Pet#mapPet.finalProperty),
	case L /= 0 of
		true->
			Pos = #posInfo{x=Pet#mapPet.pos#posInfo.x+DirX/L*TimeDt*Speed,
						   y=Pet#mapPet.pos#posInfo.y+DirY/L*TimeDt*Speed};
		false->
			Pos = #posInfo{x=Pet#mapPet.pos#posInfo.x,
						   y=Pet#mapPet.pos#posInfo.y}
	end,
	
	DirX2 = DestPos#posInfo.x-Pos#posInfo.x,
	DirY2 = DestPos#posInfo.y-Pos#posInfo.y,
	L2 = math:sqrt(DirX2*DirX2+DirY2*DirY2),
	
	case L2 < Speed*TimeDt of
		true ->
			%%移动到目标点
			PetNew = mapView:setObjectPos(Pet, DestPos#posInfo.x, DestPos#posInfo.y),
			
			[_|TargetList] = Pet#mapPet.moveTargetList,
			case TargetList of
				[] ->
					%%移动数据处理完了，停止移动
					stopMoveById(Pet#mapPet.id);
				_ ->
					setMoveTargetList(PetNew,TargetList)
			end;
		false ->
			mapView:setObjectPos(Pet, Pos#posInfo.x, Pos#posInfo.y)
	end,
	ok.