%% Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(scriptCommon).

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

%%创建一个Monseter,-record( mapSpawn, {id, mapId,type,typeId,x,y,param,isExist } ).
createMonster( MonsterDataID, PosX, PosY, Param )->
	MapSpawn = #mapSpawn{
						 id = 0,
						 mapId=map:getMapDataID(),
						 type=?Object_Type_Monster,
						 typeId = MonsterDataID,
						 x = PosX,
						 y = PosY,
						 param = Param,
						 isExist = true
						},
	Monster = monster:createMonster( MapSpawn ),
	case Monster of
		{}->ok;
		_->
			map:enterMapMonster(Monster)
	end.

%% 刷出传送点
refresh_New_Transport( TransportDataID,PosX, PosY, TransToMapID, TransToPosX, TransToPosY )->
	try
		ObjectCfg = etsBaseFunc:readRecord( main:getGlobalObjectCfgTable(), TransportDataID),
		case ObjectCfg of
			{}->throw(-1);
			_->ok
		end,

		MapSpawn = #mapSpawn{
							 id = 0,
							 mapId=map:getMapDataID(),
							 type=?Object_Type_TRANSPORT,
							 typeId = TransportDataID,
							 x = PosX,
							 y = PosY,
							 param =  [TransToMapID,TransToPosX, TransToPosY,0],
							 isExist = true
							},
		objectActor:spawnObjectActor( MapSpawn ),
		true
	catch
		_->false
	end.


%% 在Monster以R为半径的周围内的随机位置刷出小怪
rand_Refresh_New_Monsters_Around_Monster(#mapMonster{}=_Monster,_NewMonsterId,_R,0)->
	ok;
rand_Refresh_New_Monsters_Around_Monster(#mapMonster{}=Monster,NewMonsterId,R,Num)->
	{X,Y} = getRandomPositionInRegion(Monster,R),
	scriptCommon:createMonster( NewMonsterId, X, Y, 0 ),
	rand_Refresh_New_Monsters_Around_Monster(Monster,NewMonsterId,R,Num-1).

%%以点位中心，R为半径的周围内随机刷出小怪
rand_Refresh_New_Monsters_Around_Pos(_Pos, _R, _NewMonsterId, 0)->
	ok;
rand_Refresh_New_Monsters_Around_Pos(Pos, R, NewMonsterId, Num)->
	Pos2 = rand_Pos_ByPosAndRadius(Pos, R),
	scriptCommon:createMonster( NewMonsterId, Pos2#posInfo.x, Pos2#posInfo.y, 0 ),
	rand_Refresh_New_Monsters_Around_Pos(Pos, R, NewMonsterId, Num-1).

%%在固定点及半径中随机一个位置
rand_Pos_ByPosAndRadius( Pos, Radius )->
	DirX = random:uniform(20),
	DirY = random:uniform(20),
	Dis = math:sqrt(DirX*DirX+DirY*DirY),
	DirX2 = DirX / Dis,
	DirY2 = DirY / Dis,
	
	case Radius > 0 of
		true->
			Dis2 = random:uniform(Radius);
		_->Dis2=0
	end,
	
	#posInfo{x=erlang:trunc(Pos#posInfo.x+DirX2*Dis2),y=erlang:trunc(Pos#posInfo.y+DirY2*Dis2)}.

getRandomPositionInRegion(#mapMonster{}=Monster,R)->
	Delta_x1 = random:uniform(R),
	Delta_y1 = random:uniform(R),
	case (Delta_x1 rem 2) =:= 0 of
		true->Delta_x2 = Delta_x1;
		false->Delta_x2 = -Delta_x1
	end,
	
	case (Delta_y1 rem 2) =:= 0 of
		true->Delta_y2 = Delta_y1;
		false->Delta_y2 = -Delta_y1
	end,
	
	X1 = Monster#mapMonster.pos#posInfo.x + Delta_x2,
	Y1 = Monster#mapMonster.pos#posInfo.y + Delta_y2,

	case mapManager:getMapView (Monster#mapMonster.map_data_id) of
		{} ->
			X2=Monster#mapMonster.pos#posInfo.x,
			Y2=Monster#mapMonster.pos#posInfo.y;
		MapView ->
			case X1 < 0 of
				true->X2=0;
				false->
					case X1 >= MapView#mapView.width of
						true->X2=MapView#mapView.width-1;
						false->X2=X1
					end
			end,
			case Y1 < 0 of
				true->Y2=0;
				false->
					case Y1 >= MapView#mapView.height of
						true->Y2=MapView#mapView.height-1;
						false->Y2=Y1
					end
			end
	end,
	{X2,Y2}.


%%monster使用技能，返回true ,false ,follow
scriptUseSkill(AttackObj, TargetObj, SkillCfg, PosX, PosY, SkillEffectCount, IsFollow)->
	try
		CombatID = map:getMapCombatID(),
		case SkillCfg#skillCfg.skillUseTargetType of
			?SkillUseTarget_Enemy->
				CheckDis = true;
			?SkillUseTarget_Self->
				CheckDis = false;
			?SkillUseTarget_Friend->
				CheckDis = false;
			?SkillUseTarget_SelfPosEnemy->
				CheckDis = false;
		_->
			CheckDis = false,
			throw(false)
		end,
		
		case SkillCfg#skillCfg.skillRangeSquare > 0 of
			true->
				TargetList = [];
			_->
				TargetList = [TargetObj]
		end,

		case CheckDis of
			true->ok;
			false->
				case skillUse:useSkill(AttackObj, TargetList, SkillCfg, PosX, PosY, SkillEffectCount, CombatID) of
					true->
						case SkillCfg#skillCfg.skill_GlobeCoolDown of
							0->ok;
							_->
								%%使用成功，写入公共CD
								etsBaseFunc:changeFiled(map:getMapMonsterTable(), 
														AttackObj#mapMonster.id, 
														#mapMonster.lastUsePhysicAttackTime, 
														erlang:now())
						end,
						throw(true);
					_->throw(false)
				end
		end,

		case SkillCfg#skillCfg.skillRangeSquare > 0 of
			true->
				MPos = map:getObjectPos(AttackObj),
				Dx = MPos#posInfo.x - PosX,
				Dy = MPos#posInfo.y - PosY,
				DistPhysicAttackSQ = SkillCfg#skillCfg.rangerSquare,
				case IsFollow =:= false orelse (Dx*Dx+Dy*Dy) =< DistPhysicAttackSQ of
					true->
						case skillUse:useSkill(AttackObj, TargetList, SkillCfg, PosX, PosY, SkillEffectCount, CombatID) of
							true->
								case SkillCfg#skillCfg.skill_GlobeCoolDown of
									0->ok;
									_->
										%%使用成功，写入公共CD
										etsBaseFunc:changeFiled(map:getMapMonsterTable(), 
																AttackObj#mapMonster.id, 
																#mapMonster.lastUsePhysicAttackTime, 
																erlang:now())
								end,
								true;
							_->false
						end;
					false->
						monster:moveAttackFollow( AttackObj, #posInfo{x=PosX, y=PosY}, DistPhysicAttackSQ ),
						follow
				end;
			false->
				MPos = map:getObjectPos(AttackObj),
				TPos = map:getObjectPos(TargetObj),
				Dx = MPos#posInfo.x - TPos#posInfo.x,
				Dy = MPos#posInfo.y - TPos#posInfo.y,
				DistPhysicAttackSQ = SkillCfg#skillCfg.rangerSquare,
				case IsFollow =:= false orelse (Dx*Dx+Dy*Dy) =< DistPhysicAttackSQ  of
					true->
						case skillUse:useSkill(AttackObj, TargetList, SkillCfg, 0, 0, SkillEffectCount, CombatID) of
							true->
								%%使用成功，写入公共CD
								etsBaseFunc:changeFiled(map:getMapMonsterTable(), 
														AttackObj#mapMonster.id, 
														#mapMonster.lastUsePhysicAttackTime, 
														erlang:now()),
								true;
							_->false
						end;
					false->
						monster:moveAttackFollow( AttackObj, TPos, DistPhysicAttackSQ ),
						follow
				end
		end
	catch
		Return->Return
end.

%%给某个object添加buff
scriptAddBuff(ObjectID, CasterID, BuffID, RemainTime) ->
	case etsBaseFunc:readRecord(main:getGlobalBuffCfgTable(), BuffID) of
		{}->ok;
		BuffCfg->
			buff:addBuffer(ObjectID, BuffCfg, CasterID, RemainTime, 0, 0)
	end.


