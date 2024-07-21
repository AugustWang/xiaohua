%% Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(monster).

-include("db.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("monsterDefine.hrl").
-include("variant.hrl").
-include("mapView.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% API Functions
%%

%%加载地图配置表中的monster
loadMapMonster()->
	try
		MapCfg = map:getMapCfg(),
		MyFunc = fun( Record )->
						 case Record#mapSpawn.type of
							 ?Object_Type_Monster->
								 Monster = createMonster( Record ),
								 case Monster of
									 {}->?ERROR_OUT( "~p create monster[~p] false", [map:getMapLog(), Record] );
									 _->
										 map:enterMapMonster(Monster)
								 end,
								 ok;
							 _->ok
						 end
				 end,
		etsBaseFunc:etsFor( MapCfg#mapCfg.mapSpawnTable, MyFunc ),
		ok
	catch
		_->ok
	end.

%%返回是否已经死亡
isDead( MonsterID )->
	mapActorStateFlag:isStateFlag( MonsterID, ?Actor_State_Flag_Dead ).

%%创建一个monster
createMonster( #mapSpawn{} = Spawn )->
	try
		MonsterCfg = etsBaseFunc:readRecord( main:getGlobalMonsterCfgTable(), Spawn#mapSpawn.typeId ),
		case MonsterCfg of
			{}->throw(-1);
			_->ok
		end,
		
		BaseProperty = charDefine:getMonsterBasePropertyArray(MonsterCfg),

		MapMonster = #mapMonster{id= map:makeObjectID( ?Object_Type_Monster, db:memKeyIndex(mapMonster) ), % not persistent
								 event_array=undefined,
								 objType = ?Object_Type_Monster,
								 ets_table=map:getMapMonsterTable(),
								 timerList=undefined,
								 moveState = ?Object_MoveState_Stand,
								 isSleeping = 0,
								 stateFlag=?Actor_State_Flag_Unkown,
								 stateRefArray=array:new(?Buff_Effect_Type_Num, {default, 0}),
								 aiState=?Monster_AI_State_Sleep,
								 posBeginFollowX=Spawn#mapSpawn.x,
								 posBeginFollowY=Spawn#mapSpawn.y,
								 faction=MonsterCfg#monsterCfg.faction,
								 lastAITime=erlang:now(),
								 lastUsePhysicAttackTime=erlang:now(),
								 deadTime=0,
								 freeMoveTime=common:milliseconds()+5000,
								 firstHatredObjectID=0,
								 firstHatredObjectPos=#posInfo{x=Spawn#mapSpawn.x,y=Spawn#mapSpawn.y},
								 finalProperty=array:new( ?property_count, {default,0} ),
								 base_quip_ProFix = BaseProperty,
								 skill_ProFix = array:new( ?property_count, {default,0} ),
								 skill_ProPer = array:new( ?property_count, {default,[]} ),
								 map_data_id=Spawn#mapSpawn.mapId,
								 spawnData=Spawn,
								 monster_data_id = Spawn#mapSpawn.typeId,										 
								 level =  MonsterCfg#monsterCfg.level,
								 pos = #posInfo{x=Spawn#mapSpawn.x, y=Spawn#mapSpawn.y},
								 life = array:get( ?max_life, BaseProperty ),		
								 moveTargetList = [],
								 mapViewCellIndex = 0
								 },
		MapMonster
	catch
		_->{}
	end.


%%返回是否在活动范围
isMyPosInPatrol( #mapMonster{}=Monster,MonsterCfg )->
	case MonsterCfg of
		{}->false;
		_->
			SpawnCfg = Monster#mapMonster.spawnData,
			DX = Monster#mapMonster.pos#posInfo.x - SpawnCfg#mapSpawn.x,
			DY = Monster#mapMonster.pos#posInfo.y - SpawnCfg#mapSpawn.y,
			DX * DX + DY * DY =< MonsterCfg#monsterCfg.patrolRadius * MonsterCfg#monsterCfg.patrolRadius
	end.

%%返回是否在追击范围
isMyPosInFollow( #mapMonster{}=Monster )->
	MonsterCfg = etsBaseFunc:readRecord( main:getGlobalMonsterCfgTable(), Monster#mapMonster.monster_data_id ),
	case MonsterCfg of
		{}->false;
		_->
			DX = Monster#mapMonster.pos#posInfo.x - Monster#mapMonster.posBeginFollowX,
			DY = Monster#mapMonster.pos#posInfo.y - Monster#mapMonster.posBeginFollowY,
			DX * DX + DY * DY =< MonsterCfg#monsterCfg.followRadius * MonsterCfg#monsterCfg.followRadius
	end.

%%返回是否在可观察范围 目前没有使用
isMyPosInWatch( #mapMonster{}=Monster, TargetX, TargetY )->
	MonsterCfg = etsBaseFunc:readRecord( main:getGlobalMonsterCfgTable(), Monster#mapMonster.monster_data_id ),
	case MonsterCfg of
		{}->false;
		_->
			DX = Monster#mapMonster.pos#posInfo.x - TargetX,
			DY = Monster#mapMonster.pos#posInfo.y - TargetY,
			DX * DX + DY * DY =< MonsterCfg#monsterCfg.watchRadius * MonsterCfg#monsterCfg.watchRadius
	end.

%%返回是否有攻击能力
hasAttackMode( #mapMonster{}=_Monster )->
	true.

%%返回Monster与Target的距离SQ
getDistSQToTarget( #mapMonster{}=Monster, Target )->
	case element(1, Target) of
		mapPlayer->
			X = Target#mapPlayer.pos#posInfo.x,
			Y = Target#mapPlayer.pos#posInfo.y;
		mapMonster->
			X = Target#mapMonster.pos#posInfo.x,
			Y = Target#mapMonster.pos#posInfo.y;
		mapPet->
			X = Target#mapPet.pos#posInfo.x,
			Y = Target#mapPet.pos#posInfo.y
	end,
	
	XDis = Monster#mapMonster.pos#posInfo.x - X,
	YDis = Monster#mapMonster.pos#posInfo.y - Y,
	XDis*XDis + YDis*YDis.

%%返回From To的距离SQ
getDistSQFromTo( FromX, FromY, ToX, ToY )->
	DX = FromX - ToX,
	DY = FromY - ToY,
	DX * DX + DY * DY.


%%Monster心跳
onHeart( #mapMonster{}=Monster, Now )->
	try
		case Monster#mapMonster.aiState of
			?Monster_AI_State_Sleep->
				ok;
			?Monster_AI_State_Idle->
				onIdle( Monster, Now );
			?Monster_AI_State_Fighting->
				onFighting( Monster, Now );
			?Monster_AI_State_GoBack->
				onGoBack( Monster, Now );
			?Monster_AI_State_Body->
				TimeLostOfDead = timer:now_diff( Now, Monster#mapMonster.deadTime ),
				case TimeLostOfDead >= ?Monster_Dead_Disapear_Time of
					true->%%消失时间到
						map:despellObject( Monster#mapMonster.id, 0 ),
						%%重生
						MonsterCfg = etsBaseFunc:readRecord( main:getGlobalMonsterCfgTable(), Monster#mapMonster.monster_data_id ),
						case MonsterCfg of
							{}->
								ok;
							_->
								case MonsterCfg#monsterCfg.monsterCd > 0 of
									true->
										%%通知地图进程，延后出生Monster
										erlang:send_after( MonsterCfg#monsterCfg.monsterCd, self(),
														  {mapMonsterRespawnTimer, Monster#mapMonster.spawnData } ),
										ok;
									false->ok
								end,
								ok
						end;
					false->ok	
				end;
			_->ok
		end
	catch
		_->ok
	end.

%%切换AI状态
changeAIState( #mapMonster{}=Monster, AIState )->
	try
		case AIState of
			?Monster_AI_State_Sleep->
				etsBaseFunc:changeFiled( map:getMapMonsterTable(), Monster#mapMonster.id, #mapMonster.aiState, AIState ),
				case monsterMove:isMoving( Monster ) of
					true->
						monsterMove:stopMove( Monster );
					false->ok
				end;
			?Monster_AI_State_Idle->
%				OldState = Monster#mapMonster.aiState,
				etsBaseFunc:changeFiled( map:getMapMonsterTable(), Monster#mapMonster.id, #mapMonster.aiState, AIState ),
				case monsterMove:isMoving( Monster ) of
					true->
						monsterMove:stopMove( Monster );
					false->ok
				end;

%% 				case OldState /= AIState of
%% 					true->
%% 						onIdle( Monster, erlang:now() );
%% 					false->ok
%% 				end,
%%				ok;
			?Monster_AI_State_Fighting->
				%OldState2 = Monster#mapMonster.aiState,
				etsBaseFunc:changeFiled( map:getMapMonsterTable(), Monster#mapMonster.id, #mapMonster.aiState, AIState ),
				case monsterMove:isMoving( Monster ) of
					true->
						monsterMove:stopMove( Monster );
					false->ok
				end,
				
%% 				case OldState2 /= AIState of
%% 					true->
%% 						%%技能初始化
%% 						%%onInitSkill
%% 						ok;
%% 					false->ok
%% 				end,
				ok;
			?Monster_AI_State_GoBack->
				%_OldState3 = Monster#mapMonster.aiState,
				etsBaseFunc:changeFiled( map:getMapMonsterTable(), Monster#mapMonster.id, #mapMonster.aiState, AIState ),
				ok;
			?Monster_AI_State_Body->
				%_OldState4 = Monster#mapMonster.aiState,
				etsBaseFunc:changeFiled( map:getMapMonsterTable(), Monster#mapMonster.id, #mapMonster.aiState, AIState ),
				ok;
			_->ok
		end,
		ok
	catch
		_->ok
	end.

%%monster自由移动, just revoked by onIdle
freeMove(#mapMonster{}=Monster,MonsterCfg)->	
%% 	case isMyPosInPatrol( Monster,MonsterCfg ) of
%% 			true->
				case monsterMove:isMoving(Monster) of
					false->
						case MonsterCfg of
							{}->false;
							_->
								MapCfg = map:getMapCfg(),
								SpawnCfg = Monster#mapMonster.spawnData,
								case SpawnCfg of
									{}->false;
									_->
										RandomX = random:uniform(10000),
										%% check whether enter sleep state
										case (RandomX rem 10 =:= 0 ) andalso (mapView:isExistPlayerAroundMonster(Monster) =:= false) of
											true->
												%% change to sleep state
												changeAIState( Monster, ?Monster_AI_State_Sleep );
											_->	
												%% set destination
												%DX = RandomX rem MonsterCfg#monsterCfg.patrolRadius*7/10,
												DX = RandomX rem MonsterCfg#monsterCfg.patrolRadius,
												RandomY = random:uniform(10000),
												%DY = RandomY rem MonsterCfg#monsterCfg.patrolRadius*7/10,
												DY = RandomY rem MonsterCfg#monsterCfg.patrolRadius,
												case RandomX rem 2 of
													0->
														DestX = SpawnCfg#mapSpawn.x + DX;
													_->
														DestX = SpawnCfg#mapSpawn.x - DX
												end,
												case RandomY rem 2 of
													0->
														DestY = SpawnCfg#mapSpawn.y + DY;
													_->
														DestY = SpawnCfg#mapSpawn.y - DY
												end,
												
												case mapView:isBlock(MapCfg#mapCfg.mapID, erlang:trunc(DestX), erlang:trunc(DestY)) of
													true->
														ok;
													false->
														monsterMove:moveTo(Monster, DestX, DestY)
												end
										end
								end
						end;
				    true->ok
				 end.
%% 			false->ok
%% 	end.


%% revoke it when object enter player's 9grid range
changeToIdleIfNeed(Object)->	
	case element( 1, Object ) of
		mapMonster->
			case Object#mapMonster.aiState of
				?Monster_AI_State_Sleep->
					changeAIState( Object, ?Monster_AI_State_Idle );
				_->ok
			end;
		_->ok
	end.


%%休闲
onIdle( #mapMonster{}=Monster, Now )->
	try
		TimeLost = timer:now_diff( Now, Monster#mapMonster.lastAITime ),
		case TimeLost < 3*1000*1000 of
			true->throw(-1);
			false->ok
		end,
		
		etsBaseFunc:changeFiled( map:getMapMonsterTable(), Monster#mapMonster.id, #mapMonster.lastAITime, Now ),

		MonsterCfg = etsBaseFunc:readRecord( main:getGlobalMonsterCfgTable(), Monster#mapMonster.monster_data_id ),
		
		%% comment the below codes by wenzy
		%%不在自由活动范围内，回家
%% 		case isMyPosInPatrol( Monster,MonsterCfg ) of
%% 			true->ok;
%% 			false->
%% 				goBackToBeginTargetPos( Monster ),
%% 				throw(-1)
%% 		end,
		
		
		case MonsterCfg of
			{}->throw(-1);
			_->ok
		end,
		
		NowMillSec = common:millisecondsByTime(Now),
		case MonsterCfg#monsterCfg.active =:= 0 of
			true->
				%%非主动怪
				case  (NowMillSec >= Monster#mapMonster.freeMoveTime) andalso random:uniform(2) =:= 1 of
					true->
						freeMove(Monster,MonsterCfg),
						etsBaseFunc:changeFiled(map:getMapMonsterTable(), Monster#mapMonster.id, #mapMonster.freeMoveTime, NowMillSec+7500);
					false ->
						ok
				end;
			false->
				%%主动怪，搜索目标
				AttackTarget = getActiveAttackTarget( Monster, MonsterCfg ),
				case AttackTarget of
					{}->
						case (NowMillSec >= Monster#mapMonster.freeMoveTime)  andalso random:uniform(2) =:= 1 of
							true ->
								freeMove(Monster,MonsterCfg),
								etsBaseFunc:changeFiled(map:getMapMonsterTable(), Monster#mapMonster.id, #mapMonster.freeMoveTime, NowMillSec+7500);
							false ->ok
						end;
					_->
						%%仇恨目标，自动引发战斗状态
						objectHatred:addHatredIntoObject( Monster#mapMonster.id, AttackTarget#mapPlayer.id, 0 )
				end
		end
	catch
		_->ok
	end.


%%找Monster周围可攻击玩家
getActiveAttackTarget( #mapMonster{}=Monster, #monsterCfg{}=MonsterCfg )->
	put( "monster_getActiveAttackTarget_Return", {} ),
	try
		WatchDist = MonsterCfg#monsterCfg.watchRadius * MonsterCfg#monsterCfg.watchRadius,
		put( "monster_getActiveAttackTarget_MinDist", WatchDist ),
		MX = Monster#mapMonster.pos#posInfo.x,
		MY = Monster#mapMonster.pos#posInfo.y,
		
		SkillCfg = etsBaseFunc:readRecord( main:getGlobalSkillCfgTable(), ?Melee_SkillID ),
		
		MapPlayerTable = map:getMapPlayerTable(),
		MyFunc = fun( PlayerID )->
					     case etsBaseFunc:readRecord( MapPlayerTable,PlayerID) of
							{}->ok;
							Player ->	
								 case objectAttack:canAttack( Monster, Player, SkillCfg, false ) of
									 true->
										 DX = Player#mapPlayer.pos#posInfo.x - MX,
										 DY = Player#mapPlayer.pos#posInfo.y - MY,
										 Dist = DX * DX + DY * DY,
										 case Dist =< WatchDist of
											 true->
												 case Dist =< get( "monster_getActiveAttackTarget_MinDist" ) of
													 true->
														 put( "monster_getActiveAttackTarget_Return", Player ),
														 put( "monster_getActiveAttackTarget_MinDist", Dist ),
														 ok;
													 false->ok
												 end;
											 false->ok
										 end;
									 false->ok
								 end
						 end					
				 end,
		%% first check the cell where the monster locate in
		{ _MapView, MapViewCell } = mapView:getMapViewCell( MX, MY ),
		case MapViewCell of
			{}->throw(-1);
			_->
				ok
		end,
		lists:foreach(MyFunc, MapViewCell#mapViewCell.playerList),
		case get( "monster_getActiveAttackTarget_Return") of
			{}->
				%% secondly check the monster's around cells
				GetPlayerListFunc = fun( Record )->
					 MapViewCell2 = etsBaseFunc:readRecord( map:getMapViewCellsTable(), Record ),
					 MapViewCell2#mapViewCell.playerList
			 	end,
				List = common:listForEachAdd( GetPlayerListFunc, MapViewCell#mapViewCell.mapViewCellInfo#mapViewCellInfo.aroundCellIndexs,[] ),
				lists:foreach(MyFunc, List);		
			_->throw(-1)
		end,

		%%暂时遍历全地图玩家
%% 		MyFunc = fun( Record )->
%% 						 case objectAttack:canAttack( Monster, Record, SkillCfg, false ) of
%% 							 true->
%% 								 DX = Record#mapPlayer.pos#posInfo.x - MX,
%% 								 DY = Record#mapPlayer.pos#posInfo.y - MY,
%% 								 Dist = DX * DX + DY * DY,
%% 								 case Dist =< WatchDist of
%% 									 true->
%% 										 case Dist =< get( "monster_getActiveAttackTarget_MinDist" ) of
%% 											 true->
%% 												 put( "monster_getActiveAttackTarget_Return", Record ),
%% 												 put( "monster_getActiveAttackTarget_MinDist", Dist ),
%% 												 ok;
%% 											 false->ok
%% 										 end,
%% 										 ok;
%% 									 false->ok
%% 								 end,
%% 								 ok;
%% 							 false->ok
%% 						 end
%% 				 end,
%% 		etsBaseFunc:etsFor( map:getMapPlayerTable(), MyFunc ),
						
		get( "monster_getActiveAttackTarget_Return" )
	catch
		_->get( "monster_getActiveAttackTarget_Return" )
	end.

%%回到首次战斗发生的地点，并重置
goBackToBeginTargetPos( #mapMonster{}=Monster )->
	try
		case mapActorStateFlag:isStateFlag( Monster#mapMonster.id, ?Monster_State_Flag_GoBacking ) of
			true->throw(-1);
			false->ok
		end,

		
		%%清仇恨
		objectHatred:clearHatred( Monster#mapMonster.id ),
		%%清buff
		buff:clearAllOtherCasterBuff( Monster#mapMonster.id ),
		
		%% modified by wenziyong for dummy monster, clear stateFlag
		case (?Actor_State_Flag_Disable_Move band Monster#mapMonster.stateFlag ) /= 0 of
			true -> %禁止移动状态
				?ERROR_OUT("---for dummy monster,goBackToBeginTargetPos stateFlag error:~p ",
						[Monster#mapMonster.stateFlag]),
				mapActorStateFlag:removeStateFlag( Monster#mapMonster.id, ?Actor_State_Flag_Disable_Move );
			false ->
				ok
		end,
		case (?Actor_State_Flag_Disable_Hold band Monster#mapMonster.stateFlag ) /= 0 of
			true ->  %昏迷状态
				?ERROR_OUT("---for dummy monster,goBackToBeginTargetPos stateFlag error:~p ",
						[Monster#mapMonster.stateFlag]),
				mapActorStateFlag:removeStateFlag( Monster#mapMonster.id, ?Actor_State_Flag_Disable_Hold );
			false ->
				ok
		end,

		mapActorStateFlag:addStateFlag( Monster#mapMonster.id, ?Monster_State_Flag_GoBacking ),
		mapActorStateFlag:addStateFlag( Monster#mapMonster.id, ?Actor_State_Flag_God ),
		
		case ( Monster#mapMonster.pos#posInfo.x =:= Monster#mapMonster.firstHatredObjectPos#posInfo.x ) andalso
			 ( Monster#mapMonster.pos#posInfo.y =:= Monster#mapMonster.firstHatredObjectPos#posInfo.y ) of
			true->ok;
			false->
				monsterMove:moveTo(Monster, Monster#mapMonster.firstHatredObjectPos#posInfo.x, Monster#mapMonster.firstHatredObjectPos#posInfo.y ),
				ok
		end,
		
		changeAIState( Monster, ?Monster_AI_State_GoBack ),
		
		ok
	catch
		_->ok
	end.

%%回重置点
onGoBack( #mapMonster{}=Monster, _Now )->
	try
		DX = Monster#mapMonster.pos#posInfo.x - Monster#mapMonster.firstHatredObjectPos#posInfo.x,
		DY = Monster#mapMonster.pos#posInfo.y - Monster#mapMonster.firstHatredObjectPos#posInfo.y,
		DistSQ = DX*DX + DY*DY,
		case DistSQ =< ?Map_Pixel_Title_Width_SQ of
			true->%%到了
				ok;
			false->
				%% modified by wenziyong for dummy monster, 
				case (Monster#mapMonster.moveState =:= ?Object_MoveState_Stand) or  (Monster#mapMonster.moveTargetList =:= []) of
					true ->
						?ERROR_OUT("---for dummy monster,onGoBack moveState ~p or moveTargetList ~p error ",
							[Monster#mapMonster.moveState,Monster#mapMonster.moveTargetList]);
					false -> throw(-1)
				end	
		end,
		
		case monsterMove:isMoving(Monster) of
			true->monsterMove:stopMove(Monster);
			false->ok
		end,
		
		mapActorStateFlag:removeStateFlag( Monster#mapMonster.id, ?Monster_State_Flag_GoBacking ),
		mapActorStateFlag:removeStateFlag( Monster#mapMonster.id, ?Actor_State_Flag_God ),
		
		etsBaseFunc:changeFiled( map:getMapMonsterTable(), Monster#mapMonster.id, #mapMonster.firstHatredObjectID, 0 ),
		%%广播一下血量变化
		MaxLife = array:get( ?max_life, Monster#mapMonster.finalProperty),
		etsBaseFunc:changeFiled( map:getMapMonsterTable(), Monster#mapMonster.id, #mapMonster.life, MaxLife ),
		
		playerMap:sendObjectLifeToClient(Monster, true),
 
		changeAIState( Monster, ?Monster_AI_State_Idle ),
		
		ok
	catch
		_->ok
	end.


%%获得怪物的普通技能ID -> 0 or skillid
getNormalSkillId( #mapMonster{}=Monster )->
	MonsterCfg = etsBaseFunc:readRecord( main:getGlobalMonsterCfgTable(), Monster#mapMonster.monster_data_id ),
	case MonsterCfg of
		{}->0;
		_->
			MonsterCfg#monsterCfg.skillid
	end.

%%战斗
onFighting( #mapMonster{}=Monster, Now )->
	try
		case isMyPosInFollow( Monster ) of
			true->ok;
			false->%%已离开自已的追击范围
				goBackToBeginTargetPos( Monster ),
				throw(-1)
		end,

		case hasAttackMode( Monster ) of
			true->ok;
			false->%%没有攻击能力
				throw(-1)
		end,
		
%% 		TargetList = objectHatred:getObjectAllHatredTargets(Monster#mapMonster.id),
%% 		case TargetList of
%% 			[]->%%没有目标，应该不可能，没有目标，应该要切换到idle状态
%% 				throw(-1);
%% 			_->ok
%% 		end,
		
		case objectHatred:existHatredTarget( Monster#mapMonster.id ) of
			true->ok;
			false->
				%%没有目标，应该不可能，没有目标，应该要切换到idle状态
				throw(-1)
		end,
		
		%%只使用普通攻击
		%% 发送Monster_Event_FightHeart，在此事件的脚本中据monster AI条件选择技能或执行AI动作
		FightHeartResult = objectEvent:onEvent( Monster, ?Monster_Event_FightHeart, 0),
		case FightHeartResult of
			{ eventCallBackReturn, none }-> 
				throw(-1);    %%跳出
			_->
				%%使用怪物普攻
				SkillID = getNormalSkillId( Monster ),
				case SkillID =:= 0 of
					true->throw(-1);
					false->ok
				end,
				
				TimeLost = timer:now_diff( Now, Monster#mapMonster.lastUsePhysicAttackTime ) / 1000,
				case TimeLost < array:get(?attack_speed, Monster#mapMonster.finalProperty) of
					true->%%攻击cd中
						throw(-1);
					false->
						case useMonsterSkillBySkillID(Monster,SkillID, -1) of
							true-> %%技能使用成功，写入公共CD
								etsBaseFunc:changeFiled(map:getMapMonsterTable(), Monster#mapMonster.id, #mapMonster.lastUsePhysicAttackTime, Now);
							_->ok
						end
				end
		end,
		ok
	catch
		_->ok
	end.

useMonsterSkillBySkillID(Monster,SkillID, SkillEffectCount)->
	try
		SkillCfg = etsBaseFunc:readRecord( main:getGlobalSkillCfgTable(), SkillID ),
		case SkillCfg =:= {} of
			true->
				?ERROR_OUT( "monster:onFighting error,can't get SkillCfg, SkillID[~p],please check skill configure ", [SkillID] ),
				throw(-1);
			false->ok
		end,
		
		%% 获取怪物技能的目标列表  targetObj, , pos
		case getSkillTarget(Monster,SkillCfg) of
			{}->throw(false);
			{pos, Pos}->				%%对单个目标点使用技能，需要检测距离
				MPos = map:getObjectPos(Monster),
				Dx = MPos#posInfo.x - Pos#posInfo.x,
				Dy = MPos#posInfo.y - Pos#posInfo.y,
				DistPhysicAttackSQ = SkillCfg#skillCfg.rangerSquare,
				case (Dx*Dx+Dy*Dy) =< DistPhysicAttackSQ of
					true->
						ReturnValue = skillUse:useSkill(Monster, [], SkillCfg, Pos#posInfo.x, Pos#posInfo.y, SkillEffectCount, map:getMapCombatID()),
						throw(ReturnValue);
					false->moveAttackFollow( Monster, Pos, DistPhysicAttackSQ )
				end;
			{targetObj, TargetObj}->	%%对单个目标使用技能，需要检测距离
				MPos = map:getObjectPos(Monster),
				TPos = map:getObjectPos(TargetObj),
				Dx = MPos#posInfo.x - TPos#posInfo.x,
				Dy = MPos#posInfo.y - TPos#posInfo.y,
				DistPhysicAttackSQ = SkillCfg#skillCfg.rangerSquare,
				case (Dx*Dx+Dy*Dy) =< DistPhysicAttackSQ of
					true->
						ReturnValue = skillUse:useSkill(Monster, [TargetObj], SkillCfg, 0, 0, SkillEffectCount, map:getMapCombatID()),
						throw(ReturnValue);
					false->moveAttackFollow( Monster, TPos, DistPhysicAttackSQ )
				end
		end,
		false	
	catch
		Return->Return
	end.

%%攻击追随移动
moveAttackFollow( #mapMonster{}=Monster, TargetPos, DistAttackSQ )->
	try
		%%追击到距离目标DistAttackSQ少一点的位置
		FollowTargetDist = math:sqrt( DistAttackSQ )*0.81,
		MonsterCurTargetPos = monsterMove:getCurMoveTargetPos(Monster),
		case MonsterCurTargetPos of	
			{}->
				MoveTo = monsterMove:getDingBiFengDian( Monster#mapMonster.pos, TargetPos, 0, FollowTargetDist ),
				monsterMove:moveTo(Monster, MoveTo#posInfo.x, MoveTo#posInfo.y );
			_->
				CurTargetDistSQ = getDistSQFromTo( MonsterCurTargetPos#posInfo.x, MonsterCurTargetPos#posInfo.y, 
											   TargetPos#posInfo.x, TargetPos#posInfo.y ),
				case CurTargetDistSQ < DistAttackSQ of
					true->
						case monsterMove:isMoving(Monster) of
							true->ok;
							false->monsterMove:moveTo(Monster, MonsterCurTargetPos#posInfo.x, MonsterCurTargetPos#posInfo.y )
						end;
					false->
						MoveTo2 = monsterMove:getDingBiFengDian( Monster#mapMonster.pos, TargetPos, 0, FollowTargetDist ),
						monsterMove:moveTo(Monster, MoveTo2#posInfo.x, MoveTo2#posInfo.y )
				end
		end,

		ok
	catch
		_->ok
	end.


%% 获取怪物技能的目标列表 ->{type, Value}   type取值 targetObj, pos
getSkillTarget(#mapMonster{}=Monster,SkillCfg)->
	try
		MonsterID = Monster#mapMonster.id,		
		
		case SkillCfg#skillCfg.skillRangeSquare > 0 of
			true->		%%群体技能,返回目标位置
				case SkillCfg#skillCfg.skillUseTargetType of
					?SkillUseTarget_Enemy->
						Target = objectHatred:getObjectMaxHatredTarget(MonsterID),
						case Target of
							{}->throw({pos, map:getObjectPos(Monster)});
							_->throw({pos, map:getObjectPos(Target)})
						end;
					?SkillUseTarget_Self->
						throw({pos, map:getObjectPos(Monster)});
					?SkillUseTarget_Friend->
						throw({pos, map:getObjectPos(Monster)});
					?SkillUseTarget_SelfPosEnemy->
						throw({pos, map:getObjectPos(Monster)});
					_->throw({})
				end,
				ok;
			false->		%%单体技能
				case SkillCfg#skillCfg.skillUseTargetType of
					?SkillUseTarget_Enemy->
						Target = objectHatred:getObjectMaxHatredTarget(MonsterID),
						case Target of
							{}->throw({});
							_->throw({ targetObj, Target })
						end;
					?SkillUseTarget_Self->
						throw({ targetObj, Monster});
					_->throw({})
				end
		end
	catch
		ReturnValue->ReturnValue
end.

%%技能使用成功事件响应
onUsedSkill( #mapMonster{}=_Monster, _SkillCfg, _Target )->
	try
		ok
	catch
		_->ok
	end.

	
%%执行死亡动作
doDead( #mapMonster{}=Monster, WhoKillMe, CombatID)->
	try
		case mapActorStateFlag:isStateFlag(Monster#mapMonster.id, ?Actor_State_Flag_Dead ) of
			true->throw(-1);%%重复死亡
			false->ok
		end,
		
		case monsterMove:isMoving(Monster) of
			true->monsterMove:stopMove(Monster);
			false->ok
		end,
		
		mapActorStateFlag:addStateFlag( Monster#mapMonster.id, ?Actor_State_Flag_Dead ),

		%%清buff
		buff:deathClearBuff(Monster#mapMonster.id),
		
		%%清仇恨
		objectHatred:clearHatred( Monster#mapMonster.id ),
		
		%%广播死亡事件
		%%_Return = objectEvent:onEvent( Monster, ?Monster_Event_Dead, 0),
		
		%%广播死亡消息
		%%?
		case element(1, WhoKillMe) of
			mapPlayer->
				KillerId = WhoKillMe#mapPlayer.id;
			mapPet->
				KillerId = WhoKillMe#mapPet.id;
			mapMonster->
				KillerId = WhoKillMe#mapMonster.id;
			_->KillerId = 0
		end,
		
		Msg = #pk_GS2U_CharactorDead{
					nDeadActorID = Monster#mapMonster.id,
					nKiller      = KillerId,
					nCombatNumber =CombatID},
		
		mapView:broadcast(Msg, WhoKillMe, 0),
		
		%%响应死亡事件
		onDead( Monster, WhoKillMe ),
		map:onObjectDead( ?Object_Type_Monster, Monster, WhoKillMe ),
		
		etsBaseFunc:changeFiled( map:getMapMonsterTable(), Monster#mapMonster.id, #mapMonster.deadTime, erlang:now() ),
		
%% 		case WhoKillMe of
%% 			{}->
%% 				?DEBUG_OUT( "monster[~p] dead by whokillme={}", [map:getObjectLogName(Monster)] );
%% 			_->?DEBUG_OUT( "monster[~p] dead by whokillme[~p]", [map:getObjectLogName(Monster), map:getObjectLogName(WhoKillMe)] )
%% 		end,
		
		%%切换AI状态，由AI状态切换执行退地图重生
		changeAIState( Monster, ?Monster_AI_State_Body ),
		
		ok
	catch
		_->ok
	end.

%%响应死亡事件
onDead( #mapMonster{}=Monster, WhoKillMe )->
	GetEXPPlayerList = getMonsterDeadEXP( Monster, WhoKillMe ),
	MapDataID = map:getMapDataID(),

	MyFunc = fun( Record )->
					 { Player, EXP, DropRadio } = Record,
					Player#mapPlayer.pid ! { mapMsg_KillMonster, Monster#mapMonster.monster_data_id,EXP , MapDataID, DropRadio }
			 end,
	lists:foreach( MyFunc, GetEXPPlayerList ).

%%返回Monster死亡可获得经验的玩家列表，如[ {Player1, EXP, Radio}, {Player2, EXP, Radio},... ]
getMonsterDeadEXP( #mapMonster{}=MonsterIn, WhoKillMe )->
	try
		Monster = map:getMonster( MonsterIn#mapMonster.id ),
		case Monster of
			{}->throw( {return, []} );
			_->ok
		end,

		MonsterCfg = etsBaseFunc:readRecord( main:getGlobalMonsterCfgTable(), Monster#mapMonster.monster_data_id ),
		case MonsterCfg of
			{}->throw( {return, []} );
			_->ok
		end,
		
		MapCfg = map:getMapCfg(),

		%%如果是副本并且有活跃次数判定
		case MapCfg#mapCfg.type =:= ?Map_Type_Normal_Copy andalso MapCfg#mapCfg.playerActiveEnter_Times > 0 of
			true->
				IsActive = true;
			_->IsActive = false
		end,
		
		%%第一仇恨为怪物拥有者
		FirstHatredObject = map:getMapObjectByID( Monster#mapMonster.firstHatredObjectID ),
		
		%%脚本是否接管，如果有接管，以脚本为准，直接返回
		Return = objectEvent:onEvent( Monster, ?Monster_Event_DeadEXP, {FirstHatredObject, WhoKillMe} ),
		case Return of
			{ eventCallBackReturn, EXPValue }->
				case EXPValue >= 0 of
					true->throw( {return, EXPValue } );
					false->ok
				end,
				ok;
			_->ok
		end,
		
		case FirstHatredObject of
			{}->throw( {return, []} );
			_->ok
		end,
		%%先拿到怪物拥有者玩家
		case element( 1, FirstHatredObject ) of
			mapPlayer->
				FirstHatredPlayer = FirstHatredObject;
			mapPet->
				FirstHatredPlayer = etsBaseFunc:readRecord(map:getMapPlayerTable(), FirstHatredObject#mapPet.masterId),
				case FirstHatredPlayer of
					{}->throw( {return, []} );
					_->ok
				end;
			_->FirstHatredPlayer = 0, throw( {return, []} )
		end,
		
		%%不能获得经验的状态
		NotEXPState = ?Actor_State_Flag_Dead bor ?Player_State_Flag_ChangingMap,
		
		%%是否队伍拥有
		TeamID = playerMap:getPlayerTeamID(FirstHatredPlayer),
		case TeamID =/= 0 of
			true->%%
				MyFunc = fun( Record )->
								 map:getPlayer(Record)
						 end,
				PlayerLists = lists:map( MyFunc, FirstHatredPlayer#mapPlayer.teamDataInfo#teamData.membersID ),
				PlayerLists2 = lists:filter( fun(Record)-> Record /= {} end, PlayerLists ),

				TeamMemberCounts = length( PlayerLists2 ),
				MonsterEXP = MonsterCfg#monsterCfg.exp * ( 1 + (TeamMemberCounts -1)*globalSetup:getGlobalSetupValue( #globalSetup.teamEXP )/10000 ),
				
				TeamDropRadio = 10000 - (globalSetup:getGlobalSetupValue(#globalSetup.teamDrop)*(TeamMemberCounts-1)),
				
				MyFunc2 = fun( Record )->
								case IsActive of
									true->
										case lists:keyfind(map:getMapDataID(), #playerMapCDInfo.map_data_id, Record#mapPlayer.mapCDInfoList) of
											false->
												ActiveRatio=10000;
											MapCDInfo->
												case MapCDInfo#playerMapCDInfo.sys_active_count < 0 of
													true->
														case MapCDInfo#playerMapCDInfo.player_active_count < 0 of
															true->
																ActiveRatio = globalSetup:getGlobalSetupValue(#globalSetup.copyMap_NotActiveRatio);
															_->
																ActiveRatio = 10000
														end;
													_->
														ActiveRatio = 10000
												end
										end;
									_->ActiveRatio=10000
								end,
								LevelDist = Record#mapPlayer.level - Monster#mapMonster.level,
								
								LevelDistEXPRecord = etsBaseFunc:readRecord( main:getMonsterDeadEXPTable(), LevelDist ),
								case LevelDistEXPRecord of
									{}->LevelDistEXP = 100;
									_->LevelDistEXP = LevelDistEXPRecord#monsterDeadEXP.percent
								end,
								PlayerEXP = erlang:trunc( MonsterEXP/TeamMemberCounts*LevelDistEXP/10000*ActiveRatio/10000 ),
								case PlayerEXP > 0 of
									true->PlayerEXP2 = PlayerEXP;
									false->PlayerEXP2 = 1
								end,
								case mapActorStateFlag:isStateFlag( Record#mapPlayer.id, NotEXPState ) of
									true->PlayerEXP3 = 0;
									false->PlayerEXP3 = PlayerEXP2
								end,

								{Record, PlayerEXP3, TeamDropRadio*ActiveRatio/10000}
						  end,
				PlayerEXPList = lists:map( MyFunc2, PlayerLists2 ),
				throw( {return, PlayerEXPList} );
			false->
				case IsActive of
					true->
						case lists:keyfind(map:getMapDataID(), #playerMapCDInfo.map_data_id, FirstHatredPlayer#mapPlayer.mapCDInfoList) of
							false->
								ActiveRatio=10000;
							MapCDInfo->
								case MapCDInfo#playerMapCDInfo.sys_active_count < 0 of
									true->
										case MapCDInfo#playerMapCDInfo.player_active_count < 0 of
											true->
												ActiveRatio = globalSetup:getGlobalSetupValue(#globalSetup.copyMap_NotActiveRatio);
											_->
												ActiveRatio = 10000
										end;
									_->
										ActiveRatio = 10000
								end
						end;
					_->ActiveRatio=10000
				end,
				LevelDist = FirstHatredPlayer#mapPlayer.level - Monster#mapMonster.level,
				
				LevelDistEXPRecord = etsBaseFunc:readRecord( main:getMonsterDeadEXPTable(), LevelDist ),
				case LevelDistEXPRecord of
					{}->LevelDistEXP = 100;
					_->LevelDistEXP = LevelDistEXPRecord#monsterDeadEXP.percent
				end,
				PlayerEXP = erlang:trunc( MonsterCfg#monsterCfg.exp*LevelDistEXP/10000*ActiveRatio/10000 ),
				case PlayerEXP > 0 of
					true->PlayerEXP2 = PlayerEXP;
					false->PlayerEXP2 = 1
				end,
				case mapActorStateFlag:isStateFlag( FirstHatredPlayer#mapPlayer.id, NotEXPState ) of
					true->PlayerEXP3 = 0;
					false->PlayerEXP3 = PlayerEXP2
				end,

				throw( {return, [{FirstHatredPlayer, PlayerEXP3, ActiveRatio}]} )
		end,
		ok
	catch
		{ return, ReturnPlayerEXPList }->ReturnPlayerEXPList
	end.


%%响应从地图中消失事件
onExitedMap( #mapMonster{}=Monster )->
	objectEvent:onEvent( Monster, ?Char_Event_Leave_Map, 0 ),
	
	objectHatred:clearHatred( Monster#mapMonster.id ),
	%%移除内存，别漏了
	etsBaseFunc:deleteRecord( map:getObjectBuffTable(), Monster#mapMonster.id ),
	etsBaseFunc:deleteRecord( map:getObjectHatredTable(), Monster#mapMonster.id ),
	
	etsBaseFunc:deleteRecord( map:getMapMonsterTable(), Monster#mapMonster.id ),
	
	ok.

%%重生时间到
onMapMonsterRespawnTimer( SpawnCfg )->
	Monster = createMonster( SpawnCfg ),
	case Monster of
		{}->ok;
		_->
			map:enterMapMonster(Monster)
			
			%%这个要删掉 chendc	测试用
	
			%%objectEvent:registerObjectEvent(Monster, ?Char_Event_Dead, 
			%%	?Object_Type_Monster, Monster#mapMonster.monster_data_id,
			%%	 map, worldBossDie, 0)
					
	end.

%%响应Monster血量变化
onHPChanged( #mapMonster{}=_Monster )->
	ok.

%%地图进程，GM指令创建Monster
on_playerMsg_CreateMonsterByGM( PlayerID, MonsterID )->
	try
		Player = map:getPlayer(PlayerID),
		case Player of
			{}->throw(-1);
			_->ok
		end,

		MonsterCfg = etsBaseFunc:readRecord( main:getGlobalMonsterCfgTable(), MonsterID ),
		case MonsterCfg of
			{}->throw(-1);
			_->ok
		end,

		PlayerPosX = playerMap:getPlayerPosX(Player),
		PlayerPosY = playerMap:getPlayerPosY(Player),
		MapSpawn = #mapSpawn{ id = 0, 
							  mapId = map:getMapDataID(),
							  type = ?Object_Type_Monster,
							  typeId = MonsterID,
							  x = PlayerPosX,
							  y = PlayerPosY,
							  param = [],
							  isExist = 1  },
		
		Monster = createMonster( MapSpawn ),
	 	case Monster of
		 	{}->throw(-1);
		 	_->
			 	map:enterMapMonster(Monster),
				?DEBUG_OUT( "on_playerMsg_CreateMonsterByGM PlayerID[~p] MapSpawn[~p]", [PlayerID, MapSpawn] )
	 	end,
				
		ok
	catch
		_->ok
	end.



%%杀死一个怪
%% killMonster( #mapMonster{}=Monster)->
%% 	try
%% 		case mapActorStateFlag:isStateFlag(Monster#mapMonster.id, ?Actor_State_Flag_Dead ) of
%% 			true->throw(-1);%%重复死亡
%% 			false->ok
%% 		end,
%% 		
%% 		case monsterMove:isMoving(Monster) of
%% 			true->monsterMove:stopMove(Monster);
%% 			false->ok
%% 		end,
%% 		
%% 		mapActorStateFlag:addStateFlag( Monster#mapMonster.id, ?Actor_State_Flag_Dead ),
%% 
%% 		%%清buff
%% 		buff:deathClearBuff(Monster#mapMonster.id),
%% 		
%% 		%%清仇恨
%% 		objectHatred:clearHatred( Monster#mapMonster.id ),
%% 		
%% 		%%广播死亡事件
%% 		%%_Return = objectEvent:onEvent( Monster, ?Monster_Event_Dead, []),
%% 		
%% 		%%广播死亡消息
%% 		%%?
%% 		
%% 		Msg = #pk_GS2U_CharactorDead{
%% 					nDeadActorID = Monster#mapMonster.id,
%% 					nKiller      = 0,
%% 					nCombatNumber =0},
%% 		
%% 		mapView:broadcast(Msg, Monster, 0),
%% 		
%% 		%%死亡事件
%% 		%%map:onObjectDead( ?Object_Type_Monster, Monster, WhoKillMe ),
%% 		
%% 		etsBaseFunc:changeFiled( map:getMapMonsterTable(), Monster#mapMonster.id, #mapMonster.deadTime, erlang:now() ),
%% 		
%% 		
%% 		%%切换AI状态，由AI状态切换执行退地图重生
%% 		changeAIState( Monster, ?Monster_AI_State_Body ),
%% 		
%% 		ok
%% 	catch
%% 		_->ok
%% 	end.