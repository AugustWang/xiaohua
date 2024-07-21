%% Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(buff).

-include("db.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("monsterDefine.hrl").
-include("variant.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 

%%数据库进程
%%载入objectbuff, 返回{#objectBuff} 
loadObjectBuffDataFromDB(ObjectID) ->
	%case db:matchObject(objectBuffDB, #objectBuffDB{id=ObjectID}) of
	case mySqlProcess:get_objectBuffDBListById(ObjectID) of
		[]->{};
		[ObjectBuffDB|_]->
			put("TempList", []),
			Fun = fun(Record)->
						  case etsBaseFunc:readRecord(main:getGlobalBuffCfgTable(), Record#objectBuffDataDB.buff_id) of
							  {}->ok;
							  BuffCfg->
								  Data = #objectBuffData{
														 buff_id = Record#objectBuffDataDB.buff_id,
														 buffCfg = BuffCfg, 
												 		 casterID = Record#objectBuffDataDB.casterID, 
												  		isEnable = Record#objectBuffDataDB.isEnable, 
												  		startTime = Record#objectBuffDataDB.startTime, 
												  		allValidTime = Record#objectBuffDataDB.allValidTime, 
												 		lastDotEffectTime = Record#objectBuffDataDB.lastDotEffectTime, 
												  		remainTriggerCount = Record#objectBuffDataDB.remainTriggerCount,
														skillDamageID = 0
												  },
								  put("TempList", get("TempList")++[Data])
						  end
				  end,
			lists:foreach(Fun, ObjectBuffDB#objectBuffDB.buffList),
			Result = #objectBuff{
								 id=ObjectID,
								 dataList=get("TempList")},
			Result
	end.

%%数据库进程
%%保存objectBuff 
saveObjectBuffDataToDB(#objectBuff{}=ObjectBuff)->
	TempValue = get("TempList"),
	put("TempList", []),
	Fun = fun(Record) ->
				  case Record#objectBuffData.allValidTime >= ?Buff_Save_MinTime of
					  true->
						  Data = #objectBuffDataDB{
												   buff_id=Record#objectBuffData.buff_id, 
												   casterID=Record#objectBuffData.casterID, 
												   isEnable=Record#objectBuffData.isEnable, 
												   startTime=Record#objectBuffData.startTime, 
												   allValidTime=Record#objectBuffData.allValidTime, 
												   lastDotEffectTime=Record#objectBuffData.lastDotEffectTime, 
												   remainTriggerCount=Record#objectBuffData.remainTriggerCount},
						  put("TempList", get("TempList") ++ [Data]);
					  false->
						  ok
				  end
		  end,
	lists:foreach(Fun, ObjectBuff#objectBuff.dataList),
	
	SaveBuff = #objectBuffDB{
							 id=ObjectBuff#objectBuff.id,
							 buffList=get("TempList")},
	%db:writeRecord(SaveBuff),
	mySqlProcess:replaceObjectBuffDB(SaveBuff),
	put("TempList", TempValue).


%%地图进程，保存objectbuff  
onSaveObjectBuffData(ObjectId) ->
	case etsBaseFunc:readRecord(map:getObjectBuffTable(), ObjectId) of
		{}->ok;
		BuffData->
			etsBaseFunc:deleteRecord(map:getObjectBuffTable(), ObjectId),
			dbProcess_PID ! { saveObjectBuffData, BuffData }
	end.

%%玩家进程，玩家上线buff发送给客户端
playerOnline_SendBuffList( ObjectBuff )->
	case ObjectBuff of
		{}->ok;
		_->
			player:send(#pk_HeroBuffList{ buffList=buff:makeMsg_pk_ObjectBuff_List( ObjectBuff#objectBuff.dataList ) } )
	end.

%%地图进程，创建bufflist消息包
makeObjectBuffPackage(ObjectID)->
	case etsBaseFunc:readRecord(map:getObjectBuffTable(), ObjectID) of
		{}->[];
		BuffData->
			case BuffData#objectBuff.dataList of
				[]->[];
				_->makeMsg_pk_ObjectBuff_List( BuffData#objectBuff.dataList )
			end
	end.

%%根据objectBuffData的list，返回pk_ObjectBuff的list
makeMsg_pk_ObjectBuff_List( ObjectBuffDataList )->
	Now = erlang:now(),
	
	Fun = fun(Buff)->
				  case Buff#objectBuffData.buffCfg#buffCfg.canBeenVisable =/= 0 of
					  true->
						  TimeLost = timer:now_diff( Now, Buff#objectBuffData.startTime ) div 1000,
						  RemainTime=Buff#objectBuffData.allValidTime-TimeLost,
						  
						  case ( Buff#objectBuffData.buffCfg#buffCfg.bUFF_AllTime =:= 0 ) or 
							    ( RemainTime > 0 ) of
							  true->
								  #pk_ObjectBuff{
												 buff_id = Buff#objectBuffData.buff_id,
												 allValidTime = RemainTime div 1000,
												 remainTriggerCount = Buff#objectBuffData.remainTriggerCount
												 };
							  false->{}	  
						  end;
					  false->{}
				  end
		  end,
	List = lists:map(Fun, ObjectBuffDataList),
	MyFunc = fun( Record )->
					Record =/= {}
			 end,
	lists:filter(MyFunc, List).

%%Buffer列表响应伤害计算前
onDamageCalcForBufferList( ObjectID, _SkillData, _FromObject )->
	try
		MyFunc = fun( Record )->
						case Record#objectBuffData.buffCfg#buffCfg.triggerType of
							1->
								doBuffEffect( ObjectID, Record, false ),
								ok;
							_->ok
						end
				 end,
		
		ObjectBuffRecord = etsBaseFunc:readRecord( map:getObjectBuffTable(), ObjectID ),
		case ObjectBuffRecord of
			{}->ok;
			_->
				case ObjectBuffRecord#objectBuff.dataList of
					{}->ok;
					_->
						lists:foreach( MyFunc, ObjectBuffRecord#objectBuff.dataList )
				end
		end,
		ok
	catch
		_->ok
	end.

%%Buffer列表响应伤害目标
onDamageTargetForBufferList( ObjectID, _SkillData, _FromObject )->
	try
		MyFunc = fun( Record )->
						case Record#objectBuffData.buffCfg#buffCfg.triggerType of
							2->
								doBuffEffect( ObjectID, Record, false ),
								ok;
							_->ok
						end
				 end,
		
		ObjectBuffRecord = etsBaseFunc:readRecord( map:getObjectBuffTable(), ObjectID ),
		case ObjectBuffRecord of
			{}->ok;
			_->
				case ObjectBuffRecord#objectBuff.dataList of
					{}->ok;
					_->
						lists:foreach( MyFunc, ObjectBuffRecord#objectBuff.dataList )
				end
		end,
		ok
	catch
		_->ok
	end.

%%Buffer列表响应受到伤害
onDamageForBufferList( ObjectID, _SkillData, _FromObject, _DamageHP, _MeIsDead )->
	try
		MyFunc = fun( Record )->
						case Record#objectBuffData.buffCfg#buffCfg.triggerType of
							3->
								doBuffEffect( ObjectID, Record, false ),
								ok;
							_->ok
						end
				 end,
		
		ObjectBuffRecord = etsBaseFunc:readRecord( map:getObjectBuffTable(), ObjectID ),
		case ObjectBuffRecord of
			{}->ok;
			_->
				case ObjectBuffRecord#objectBuff.dataList of
					{}->ok;
					_->
						lists:foreach( MyFunc, ObjectBuffRecord#objectBuff.dataList )
				end
		end,
		ok
	catch
		_->ok
	end.


%%创建Buffer
addBuffer( ObjectID, AddBuffCfg, CasterID, RemainTime, SkillCfg, SkillDamageID )->
	try
		%%创建机率
		%%?
		case random:uniform(10000) =< AddBuffCfg#buffCfg.bUFF_Rate of
			false->throw(-1);
			_->ok
		end,

		ObjectValid = map:getMapObjectByID(ObjectID),
		case ObjectValid of
			{}->throw(-1);
			_->ok
		end,
		
		ObjectBuffRecord = etsBaseFunc:readRecord( map:getObjectBuffTable(), ObjectID ),
		
		put( "player_createBufferToPlayer_valid_count", 0 ),
		put( "player_createBufferToPlayer_first_visable", 0 ),

		%%先考虑更新、替换、有更高级
		MyFunc = fun( Record )->
						case Record#objectBuffData.isEnable of
							false->ok;%%无效buff
							true->
								case Record#objectBuffData.buffCfg#buffCfg.buff_group =:= AddBuffCfg#buffCfg.buff_group of
									true->%%同组的buff
										case Record#objectBuffData.buffCfg#buffCfg.level > AddBuffCfg#buffCfg.level of
											true->%%已存的buff比新来的等级高，直接跳出，新增无效
												throw(-1);
											false->%%更新，先删除老的，然后添加新的
												removeBuff( ObjectID, Record#objectBuffData.buff_id )
										end;
									false->
										%%统计可见buff个数
										case Record#objectBuffData.buffCfg#buffCfg.canBeenVisable =:= 0 of
											true->ok;
											false->
												case get( "player_createBufferToPlayer_first_visable" ) =:= 0 of
													true->put( "player_createBufferToPlayer_first_visable", Record#objectBuffData.buff_id );
													false->ok
												end,
												put( "player_createBufferToPlayer_valid_count", get("player_createBufferToPlayer_valid_count")+1 )
										end
								end
						end
				 end,
		
		case ObjectBuffRecord of
			{}->ok;
			_->
				lists:foreach( MyFunc, ObjectBuffRecord#objectBuff.dataList )
		end,

		%%新增buff
		%%先考虑是否需要顶掉
		case get("player_createBufferToPlayer_valid_count") >= ?Max_Visable_Buff_Count of
			true->removeBuff( ObjectID, get( "player_createBufferToPlayer_first_visable" ) );
			false->ok
		end,
		
		%%计算buff有效时间
		case RemainTime > 0 of
			true->AllValidTime = RemainTime;
			false->AllValidTime = AddBuffCfg#buffCfg.bUFF_AllTime
		end,
		

		ObjectBuffData = #objectBuffData{
										 		 buff_id=AddBuffCfg#buffCfg.buff_id,
										 		 buffCfg=AddBuffCfg, 
												 skillCfg=SkillCfg,
												 casterID=CasterID, 
										 		 isEnable=true,
												 startTime = erlang:now(),
										 		 allValidTime = AllValidTime,
												 lastDotEffectTime = erlang:now(),
												 remainTriggerCount = AddBuffCfg#buffCfg.bUFF_HowManyTimes,
												 skillDamageID = SkillDamageID
												 },
	
		case etsBaseFunc:readRecord(map:getObjectBuffTable(), ObjectID) of
			{}->
				etsBaseFunc:insertRecord( map:getObjectBuffTable(), #objectBuff{id=ObjectID, 
																				dataList=[ObjectBuffData]} );
			ObjectBuffRecord2->
				etsBaseFunc:changeFiled( map:getObjectBuffTable(), ObjectID, #objectBuff.dataList, 
										 ObjectBuffRecord2#objectBuff.dataList ++ [ObjectBuffData])
		end,

		%%获得buff消息广播
		case ObjectBuffData#objectBuffData.buffCfg#buffCfg.canBeenVisable =:= 0 of
			true->ok;
			false->	
				Msg = #pk_AddBuff{
								  actor_id=ObjectID,
								  buff_data_id=AddBuffCfg#buffCfg.buff_id,
								  allValidTime=ObjectBuffData#objectBuffData.allValidTime div 1000,
								  remainTriggerCount=ObjectBuffData#objectBuffData.remainTriggerCount},
				Object = map:getMapObjectByID(ObjectID),
				mapView:broadcast(Msg, Object, 0)
		end,
	

		%%事件响应，获得buff
		onAddBuff( ObjectID, AddBuffCfg ),

		%%持续作用类的buff第一次不执行
		case AddBuffCfg#buffCfg.bUFF_SingleTime =< 0 of
			true->
				doBuffEffect( ObjectID, ObjectBuffData, false );
			_->ok
		end,
		
		true
	catch
		_->false
	end.


%%执行buff改变属性效果
doBuff_Change_Attribute( ObjectID, ObjectBuff ) ->
	try
		Object = map:getMapObjectByID(ObjectID),
		case Object of
			{}->throw(-1);
			_ ->ok
		end,
		
		TempFix = get("Skill_ProFix"),
		TempPer = get("Skill_ProPer"),
		
		case element(1, Object) of
			mapPlayer->
				put("Skill_ProFix", Object#mapPlayer.skill_ProFix),
				put("Skill_ProPer", Object#mapPlayer.skill_ProPer);
			mapMonster->
				put("Skill_ProFix", Object#mapMonster.skill_ProFix),
				put("Skill_ProPer", Object#mapMonster.skill_ProPer);
			mapPet->
				put("Skill_ProFix", Object#mapPet.skill_ProFix),
				put("Skill_ProPer", Object#mapPet.skill_ProPer);
			_->ok
		end,
		
		ProIndex1 = ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyType1,
		case ProIndex1>=0 andalso ProIndex1<?property_count of
			false->ok; 		%%不改变任何值
			true->
				case ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyFixOrPercent1 of
					?BuffChangeAttribute_Type_Fix->
						Value1 = array:get(ProIndex1, get("Skill_ProFix"))+ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue1,
						put("Skill_ProFix", array:set(ProIndex1, Value1, get("Skill_ProFix")));
					?BuffChangeAttribute_Type_Per->
						Value1 = array:get(ProIndex1, get("Skill_ProPer")) ++ [ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue1],
						put("Skill_ProPer", array:set(ProIndex1, Value1, get("Skill_ProPer")));
					_ ->ok
				end
		end,
		
		ProIndex2 = ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyType2,
		case ProIndex2>=0 andalso ProIndex2 < ?property_count of
			false->ok; 		%%不改变任何值
			true->
				case ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyFixOrPercent2 of
					?BuffChangeAttribute_Type_Fix->
						Value2 = array:get(ProIndex2, get("Skill_ProFix"))+ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue2,
						put("Skill_ProFix", array:set(ProIndex2, Value2, get("Skill_ProFix")));
					?BuffChangeAttribute_Type_Per->
						Value2 = array:get(ProIndex2, get("Skill_ProPer")) ++ [ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue2],
						put("Skill_ProPer", array:set(ProIndex2, Value2, get("Skill_ProPer")));
					_ ->ok
				end
		end,
		
		ProIndex3 = ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyType3,
		case ProIndex3>=0 andalso ProIndex3<?property_count of
			false->ok; 		%%不改变任何值
			true->
				case ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyFixOrPercent3 of
					?BuffChangeAttribute_Type_Fix->
						Value3 = array:get(ProIndex3, get("Skill_ProFix"))+ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue3,
						put("Skill_ProFix", array:set(ProIndex3, Value3, get("Skill_ProFix")));
					?BuffChangeAttribute_Type_Per->
						Value3 = array:get(ProIndex3, get("Skill_ProPer")) ++ [ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue3],
						put("Skill_ProPer", array:set(ProIndex3, Value3, get("Skill_ProPer")));
					_ ->ok
				end
		end,
		
		ProIndex4 = ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyType4,
		case ProIndex4>=0 andalso ProIndex4<?property_count of
			false->ok; 		%%不改变任何值
			true->
				case ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyFixOrPercent4 of
					?BuffChangeAttribute_Type_Fix->
						Value4 = array:get(ProIndex4, get("Skill_ProFix"))+ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue4,
						put("Skill_ProFix", array:set(ProIndex4, Value4, get("Skill_ProFix")));
					?BuffChangeAttribute_Type_Per->
						Value4 = array:get(ProIndex4, get("Skill_ProPer")) ++ [ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue4],
						put("Skill_ProPer", array:set(ProIndex4, Value4, get("Skill_ProPer")));
					_ ->ok
				end
		end,
		
		ProIndex5 = ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyType5,
		case ProIndex5>=0 andalso ProIndex5<?property_count of
			false->ok; 		%%不改变任何值
			true->
				case ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyFixOrPercent5 of
					?BuffChangeAttribute_Type_Fix->
						Value5 = array:get(ProIndex5, get("Skill_ProFix"))+ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue5,
						put("Skill_ProFix", array:set(ProIndex5, Value5, get("Skill_ProFix")));
					?BuffChangeAttribute_Type_Per->
						Value5 = array:get(ProIndex5, get("Skill_ProPer")) ++ [ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue5],
						put("Skill_ProPer", array:set(ProIndex5, Value5, get("Skill_ProPer")));
					_ ->ok
				end
		end,
		
		case element(1, Object) of
			mapPlayer->
				etsBaseFunc:changeFiled(map:getMapPlayerTable(), Object#mapPlayer.id, #mapPlayer.skill_ProFix, get("Skill_ProFix")),
				etsBaseFunc:changeFiled(map:getMapPlayerTable(), Object#mapPlayer.id, #mapPlayer.skill_ProPer, get("Skill_ProPer")),
				ObjectNew = etsBaseFunc:readRecord(map:getMapPlayerTable(), Object#mapPlayer.id);
			mapMonster->
				etsBaseFunc:changeFiled(map:getMapMonsterTable(), Object#mapMonster.id, #mapMonster.skill_ProFix, get("Skill_ProFix")),
				etsBaseFunc:changeFiled(map:getMapMonsterTable(), Object#mapMonster.id, #mapMonster.skill_ProPer, get("Skill_ProPer")),
				ObjectNew = etsBaseFunc:readRecord(map:getMapMonsterTable(), Object#mapMonster.id);
			mapPet->
				etsBaseFunc:changeFiled(map:getMapPetTable(), Object#mapPet.id, #mapPet.skill_ProFix, get("Skill_ProFix")),
				etsBaseFunc:changeFiled(map:getMapPetTable(), Object#mapPet.id, #mapPet.skill_ProPer, get("Skill_ProPer")),
				ObjectNew = etsBaseFunc:readRecord(map:getMapPetTable(), Object#mapPet.id);
			_->ObjectNew = {}
		end,
		
		%%计算最终属性
		case ObjectNew of
			{}->ok;
			_->
				damageCalculate:calcFinaProperty(ObjectID)
		end,
		
		put("Skill_ProFix", TempFix),
		put("Skill_ProPer", TempPer)
	catch
		_->ok
end.

%%执行buff昏迷效果
doBuff_Stun( ObjectID, _ObjectBuff ) ->
	mapActorStateFlag:addStateRes(ObjectID, ?Buff_Effect_Type_Stun),
	ok.

%%执行buff沉默效果
doBuff_Forbid( ObjectID, _ObjectBuff ) ->
	mapActorStateFlag:addStateRes(ObjectID, ?Buff_Effect_Type_Forbid),
	ok.

%%执行buff定身效果
doBuff_Fasten( ObjectID, _ObjectBuff )->
	mapActorStateFlag:addStateRes(ObjectID, ?Buff_Effect_Type_Fasten),
	ok.

%%执行buff无敌效果
doBuff_Immortal( ObjectID, _ObjectBuff )->
	mapActorStateFlag:addStateRes(ObjectID, ?Buff_Effect_Type_Immortal),
	ok.

%%buff效果生效		%%IsRemove=是否是移除时生效的buff
doBuffEffect( ObjectID, ObjectBuff, IsRemove )->
	try
		case (ObjectBuff#objectBuffData.buffCfg#buffCfg.bUFF_HowManyTimes > 0) of
			true->
				case (ObjectBuff#objectBuffData.remainTriggerCount > 0) of
					true->%%有触发次数限定，并且还有触发次数
						NewObjectBuff = setelement( #objectBuffData.remainTriggerCount, ObjectBuff, ObjectBuff#objectBuffData.remainTriggerCount - 1 ),
						
						%%广播buff次数更新消息
						case ObjectBuff#objectBuffData.buffCfg#buffCfg.canBeenVisable =:= 0 of
							true->ok;
							false->
								Msg = #pk_UpdateBuff{
													 actor_id=ObjectID,
													 buff_data_id=ObjectBuff#objectBuffData.buff_id,
													 remainTriggerCount=NewObjectBuff#objectBuffData.remainTriggerCount},
								Object = map:getMapObjectByID(ObjectID),
								mapView:broadcast(Msg, Object, 0)
						end,
	
						updateSetBuff( ObjectID, NewObjectBuff );
					false->
						case IsRemove of
							true->throw(-1);
							false->removeBuff(ObjectID, ObjectBuff#objectBuffData.buff_id)
						end,
						NewObjectBuff = ObjectBuff
				end;
			false->
				NewObjectBuff = ObjectBuff
		end,

		%%根据buff类型，生效
		case NewObjectBuff#objectBuffData.buffCfg#buffCfg.effect_Type of
			?Buff_Effect_Type_Change_Attribute->		%%改变属性
				doBuff_Change_Attribute(ObjectID, NewObjectBuff);
			?Buff_Effect_Type_Stun->								%%昏迷
				doBuff_Stun(ObjectID, NewObjectBuff);
			?Buff_Effect_Type_Forbid->							%%沉默
				doBuff_Forbid(ObjectID, NewObjectBuff);
			?Buff_Effect_Type_Fasten->							%%定身
				doBuff_Fasten(ObjectID, NewObjectBuff);
			?Buff_Effect_Type_Immortal->						%%无敌
				doBuff_Immortal(ObjectID, NewObjectBuff);
			?Buff_Effect_Type_AddLifeByItem->					%%喝药加血
				doBuff_AddLifeByItem(ObjectID, NewObjectBuff);		
			?Buff_Effect_Type_AddLifeBySkill->					%%技能加血
				doBuff_AddLifeBySkill(ObjectID, NewObjectBuff);
			?Buff_Effect_Type_AddLifeByBloodPool->
				doBuff_AddLifeByBloodPool(ObjectID, NewObjectBuff);
			?Buff_Effect_Type_PKProcted->ok;
			0->ok;
			_->throw(-1)
		end,

		%%有伤害
		case NewObjectBuff#objectBuffData.buffCfg#buffCfg.damageType =:= 0 of
			true->ok;
			false->doBuffDamage( ObjectID, NewObjectBuff )
		end,
		
		case (NewObjectBuff#objectBuffData.buffCfg#buffCfg.bUFF_HowManyTimes > 0) andalso
				 (NewObjectBuff#objectBuffData.remainTriggerCount =< 0 ) of
			true->%%有触发次数限定
				case IsRemove of
					true->throw(-1);
					false->removeBuff( ObjectID, NewObjectBuff#objectBuffData.buff_id )
				end;
			false->ok
		end
	catch
		_->ok
	end.

%%返回能否buff伤害
canDamage( SrcObject, TargetObject )->
	try
		case SrcObject of
			{}->throw( {return, false} );
			_->ok
		end,
		case TargetObject of
			{}->throw( {return, false} );
			_->ok
		end,
		
		TargetObjectID = element( ?object_id_index, TargetObject ),
		
		CanNotState = ( ?Actor_State_Flag_Dead ) bor ( ?Player_State_Flag_ChangingMap ) bor
	                  ( ?Actor_State_Flag_God ),
		case ( mapActorStateFlag:isStateFlag(TargetObjectID, CanNotState ) ) of
			true->throw( {return, false} );
			false->ok
		end,
		
		%%检测是不是由于pk 保护不能被攻击
		case element( 1, TargetObject ) of
			mapPlayer->
				case element(1,SrcObject) of
					mapPlayer->
						%%继续判定
						%%TargetObjectID=map:getObjectID( Target ), 
						case buff:hasPkProcted(TargetObjectID) of
							true ->
								throw({return, false} ); %%不能攻击
							false->
								%%免战保护，并且是和平模式，不能被攻击
								case variant:getWorldVarFlag(?WorldVariant_Index_1, ?WorldVariant_Index_1_PeriodPkProt_Bit0) of
									true->
										PKKillState = ( ?Player_State_Flag_PK_Kill bor ?Player_State_Flag_PK_Kill_Value ),
										case ( (SrcObject#mapPlayer.stateFlag =:= ?Player_State_Flag_PK_Kill) andalso
											(( TargetObject#mapPlayer.stateFlag band PKKillState ) /= 0) ) of
											true -> 
												ok;
											false->
												throw({return, false} ) %%不能攻击
										end;
									false->
										ok
								end
						end,
						ok;
					_->
						ok
				end;
			_->
			ok
		end,
		

		true
	catch
		{ return, Return }->Return
	end.

hasPkProcted(MapPlayerID)->
	LeftProctedTime=playerMap:pKProctLeftTime(MapPlayerID),
	_Result=LeftProctedTime>0.

%%执行buff伤害
doBuffDamage( ObjectID, ObjectBuff )->
	try
	SrcObject = map:getMapObjectByID( ObjectBuff#objectBuffData.casterID ),
	TargetObject = map:getMapObjectByID( ObjectID ),
	SkillCfg = ObjectBuff#objectBuffData.skillCfg,
	case ( canDamage( SrcObject, TargetObject ) ) andalso
		 ( ObjectBuff#objectBuffData.skillCfg =/= 0 ) of
		true->
			DamageInfo = #damageInfo{ attackerID=element( ?object_id_index, SrcObject ),
								  beenAttackerID=element( ?object_id_index, TargetObject ),
								  skillDamageID=ObjectBuff#objectBuffData.skillDamageID,
								  damage=0,
								  isBlocked=false,
								  isCrited=false
								  },
			
			SkillCfg2 = setelement( #skillCfg.damageType, SkillCfg, ObjectBuff#objectBuffData.buffCfg#buffCfg.damageType ),
			SkillCfg3 = setelement( #skillCfg.damagePercent, SkillCfg2, ObjectBuff#objectBuffData.buffCfg#buffCfg.damagePercent ),
			SkillCfg4 = setelement( #skillCfg.damageFixValue, SkillCfg3, ObjectBuff#objectBuffData.buffCfg#buffCfg.damageFixValue ),
			SkillCfg5 = setelement( #skillCfg.hit_Spec, SkillCfg4, ( SkillCfg#skillCfg.hit_Spec bor ?SkillHitSpec_Not_Block ) ),
			
			DamageInfo2 = damageCalculate:calc_Skill_Damage( SrcObject, SkillCfg5, TargetObject, DamageInfo ),
			
			objectAttack:doSkillDamage(SrcObject, SkillCfg5, TargetObject, DamageInfo2, ObjectBuff#objectBuffData.skillDamageID),
			
			%%如果自己已经死亡或目标已经死亡，跳出
			case map:isObjectDead( SrcObject ) or map:isObjectDead( TargetObject ) of
				true->throw(-1);
				false->ok
			end,
			
			ok;
		false->false
	end,
		ok
	catch
		_->ok
	end.

%%执行删除改变属性的效果
unDoBuff_Change_Attribute(ObjectID, ObjectBuff)->
	try
		Object = map:getMapObjectByID(ObjectID),
		case Object of
			{}->throw(-1);
			_ ->ok
		end,
		
		TempFix = get("Skill_ProFix"),
		TempPer = get("Skill_ProPer"),
		
		case element(1, Object) of
			mapPlayer->
				put("Skill_ProFix", Object#mapPlayer.skill_ProFix),
				put("Skill_ProPer", Object#mapPlayer.skill_ProPer);
			mapMonster->
				put("Skill_ProFix", Object#mapMonster.skill_ProFix),
				put("Skill_ProPer", Object#mapMonster.skill_ProPer);
			mapPet->
				put("Skill_ProFix", Object#mapPet.skill_ProFix),
				put("Skill_ProPer", Object#mapPet.skill_ProPer);
			_->ok
		end,
		
		ProIndex1 = ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyType1,
		case ProIndex1>=0 andalso ProIndex1<?property_count of
			false->ok; 		%%不改变任何值
			true->
				case ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyFixOrPercent1 of
					?BuffChangeAttribute_Type_Fix->
						Value1 = array:get(ProIndex1, get("Skill_ProFix")) - ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue1,
						put("Skill_ProFix", array:set(ProIndex1, Value1, get("Skill_ProFix")));
					?BuffChangeAttribute_Type_Per->
						Value1 = array:get(ProIndex1, get("Skill_ProPer")) -- [ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue1],
						put("Skill_ProPer", array:set(ProIndex1, Value1, get("Skill_ProPer")));
					_ ->ok
				end
		end,
		
		ProIndex2 = ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyType2,
		case ProIndex2>=0 andalso ProIndex2 < ?property_count of
			false->ok; 		%%不改变任何值
			true->
				case ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyFixOrPercent2 of
					?BuffChangeAttribute_Type_Fix->
						Value2 = array:get(ProIndex2, get("Skill_ProFix")) - ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue2,
						put("Skill_ProFix", array:set(ProIndex2, Value2, get("Skill_ProFix")));
					?BuffChangeAttribute_Type_Per->
						Value2 = array:get(ProIndex2, get("Skill_ProPer")) -- [ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue2],
						put("Skill_ProPer", array:set(ProIndex2, Value2, get("Skill_ProPer")));
					_ ->ok
				end
		end,
		
		ProIndex3 = ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyType3,
		case ProIndex3>=0 andalso ProIndex3<?property_count of
			false->ok; 		%%不改变任何值
			true->
				case ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyFixOrPercent3 of
					?BuffChangeAttribute_Type_Fix->
						Value3 = array:get(ProIndex3, get("Skill_ProFix")) - ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue3,
						put("Skill_ProFix", array:set(ProIndex3, Value3, get("Skill_ProFix")));
					?BuffChangeAttribute_Type_Per->
						Value3 = array:get(ProIndex3, get("Skill_ProPer")) -- [ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue3],
						put("Skill_ProPer", array:set(ProIndex3, Value3, get("Skill_ProPer")));
					_ ->ok
				end
		end,
		
		ProIndex4 = ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyType4,
		case ProIndex4>=0 andalso ProIndex4<?property_count of
			false->ok; 		%%不改变任何值
			true->
				case ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyFixOrPercent4 of
					?BuffChangeAttribute_Type_Fix->
						Value4 = array:get(ProIndex4, get("Skill_ProFix")) - ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue4,
						put("Skill_ProFix", array:set(ProIndex4, Value4, get("Skill_ProFix")));
					?BuffChangeAttribute_Type_Per->
						Value4 = array:get(ProIndex4, get("Skill_ProPer")) -- [ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue4],
						put("Skill_ProPer", array:set(ProIndex4, Value4, get("Skill_ProPer")));
					_ ->ok
				end
		end,
		
		ProIndex5 = ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyType5,
		case ProIndex5>=0 andalso ProIndex5<?property_count of
			false->ok; 		%%不改变任何值
			true->
				case ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyFixOrPercent5 of
					?BuffChangeAttribute_Type_Fix->
						Value5 = array:get(ProIndex5, get("Skill_ProFix")) - ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue5,
						put("Skill_ProFix", array:set(ProIndex5, Value5, get("Skill_ProFix")));
					?BuffChangeAttribute_Type_Per->
						Value5 = array:get(ProIndex5, get("Skill_ProPer")) -- [ObjectBuff#objectBuffData.buffCfg#buffCfg.propertyValue5],
						put("Skill_ProPer", array:set(ProIndex5, Value5, get("Skill_ProPer")));
					_ ->ok
				end
		end,
		
		case element(1, Object) of
			mapPlayer->
				etsBaseFunc:changeFiled(map:getMapPlayerTable(), Object#mapPlayer.id, #mapPlayer.skill_ProFix, get("Skill_ProFix")),
				etsBaseFunc:changeFiled(map:getMapPlayerTable(), Object#mapPlayer.id, #mapPlayer.skill_ProPer, get("Skill_ProPer")),
				ObjectNew = etsBaseFunc:readRecord(map:getMapPlayerTable(), Object#mapPlayer.id);
			mapMonster->
				etsBaseFunc:changeFiled(map:getMapMonsterTable(), Object#mapMonster.id, #mapMonster.skill_ProFix, get("Skill_ProFix")),
				etsBaseFunc:changeFiled(map:getMapMonsterTable(), Object#mapMonster.id, #mapMonster.skill_ProPer, get("Skill_ProPer")),
				ObjectNew = etsBaseFunc:readRecord(map:getMapMonsterTable(), Object#mapMonster.id);
			mapPet->
				etsBaseFunc:changeFiled(map:getMapPetTable(), Object#mapPet.id, #mapPet.skill_ProFix, get("Skill_ProFix")),
				etsBaseFunc:changeFiled(map:getMapPetTable(), Object#mapPet.id, #mapPet.skill_ProPer, get("Skill_ProPer")),
				ObjectNew = etsBaseFunc:readRecord(map:getMapPetTable(), Object#mapPet.id);
			_->ObjectNew = {}
		end,
		
		%%计算最终属性
		case ObjectNew of
			{}->ok;
			_->
				damageCalculate:calcFinaProperty(ObjectID)
		end,
		
		put("Skill_ProFix", TempFix),
		put("Skill_ProPer", TempPer)
	catch
		_->ok
end.

%%执行删除昏迷效果
unDoBuff_Stun(ObjectID, _ObjectBuff) ->
	mapActorStateFlag:reduceStateRes(ObjectID, ?Buff_Effect_Type_Stun),
	ok.

%%执行删除沉默效果
unDoBuff__Forbid(ObjectID, _ObjectBuff)->
	mapActorStateFlag:reduceStateRes(ObjectID, ?Buff_Effect_Type_Forbid),
	ok.

%%执行删除定身效果
unDoBuff_Fasten(ObjectID, _ObjectBuff)->
	mapActorStateFlag:reduceStateRes(ObjectID, ?Buff_Effect_Type_Fasten),
	ok.

%%执行删除无敌效果
unDoBuff_Immortal(ObjectID, _ObjectBuff)->
	mapActorStateFlag:reduceStateRes(ObjectID, ?Buff_Effect_Type_Immortal),
	ok.

%%buff效果失效
unDoBuffEffect( ObjectID, ObjectBuff )->
	%%根据buff类型，失效
	case ObjectBuff#objectBuffData.buffCfg#buffCfg.effect_Type of
		?Buff_Effect_Type_Change_Attribute->		%%改变属性
			unDoBuff_Change_Attribute(ObjectID, ObjectBuff);
		?Buff_Effect_Type_Stun->								%%昏迷
			unDoBuff_Stun(ObjectID, ObjectBuff);
		?Buff_Effect_Type_Forbid->							%%沉默
			unDoBuff__Forbid(ObjectID, ObjectBuff);
		?Buff_Effect_Type_Fasten->							%%定身
			unDoBuff_Fasten(ObjectID, ObjectBuff);
		?Buff_Effect_Type_Immortal->						%%无敌
			unDoBuff_Immortal(ObjectID, ObjectBuff);
		_->ok
	end.

%%更新物件的buff
updateSetBuff( ObjectID, ObjectBuff )->
	case  etsBaseFunc:readRecord( map:getObjectBuffTable(), ObjectID ) of
		{}->ok;
		ObjectBuffRecord->
			NewList = lists:keyreplace(ObjectBuff#objectBuffData.buff_id, #objectBuffData.buff_id, ObjectBuffRecord#objectBuff.dataList, ObjectBuff),
			etsBaseFunc:changeFiled( map:getObjectBuffTable(), ObjectID, #objectBuff.dataList, NewList )
	end.
	
%%移除一种类型的buff
removeBuffByEffectType(ObjectID,EffectType)->
	?DEBUG_OUT( "removeBuffByEffectType 1" ),
	ObjectBuffRecord = etsBaseFunc:readRecord( map:getObjectBuffTable(), ObjectID ),
	case ObjectBuffRecord of
			{}->
				ok;
			_->
				?DEBUG_OUT( "removeBuffByEffectType 2" ),
				case ObjectBuffRecord#objectBuff.dataList of
					{}->
						ok;
					_->
						?DEBUG_OUT( "removeBuffByEffectType 3" ),
						MyFunc=fun(#objectBuffData{buffCfg=BuffCfg,buff_id=BuffID}=_Par)->
								case BuffCfg of
									{}->
										ok;
									_->
										?DEBUG_OUT( "removeBuffByEffectType 4" ),
										BuffType=BuffCfg#buffCfg.effect_Type,
										case ( BuffType=:= EffectType) of
											true->
												?DEBUG_OUT( "removeBuffByEffectType 5" ),
												removeBuff(ObjectID,BuffID);
											false->
												ok
										end
								end
						end,
						
						lists:foreach( MyFunc, ObjectBuffRecord#objectBuff.dataList )
				end
	end.
%%移除buff
removeBuff( ObjectID, BuffId )->
	try		
		ObjectBuffRecord = etsBaseFunc:readRecord( map:getObjectBuffTable(), ObjectID ),
		case ObjectBuffRecord of
			{}->throw(-1);
			_->ok
		end,
		
		case lists:keyfind(BuffId, #objectBuffData.buff_id, ObjectBuffRecord#objectBuff.dataList) of
			false->
				throw(-1);
			RemoveBuff->
				%%检查buff配置移除时生效
				case RemoveBuff#objectBuffData.buffCfg#buffCfg.triggerType of
					4->%%移除时生效
						doBuffEffect( ObjectID, RemoveBuff, true );
					_->ok
				end,
				
				%%删除buff
				NewBuffList = lists:keydelete(BuffId, #objectBuffData.buff_id, ObjectBuffRecord#objectBuff.dataList),
				etsBaseFunc:changeFiled(map:getObjectBuffTable(), ObjectID, #objectBuff.dataList, NewBuffList),
				
				%%删除buff消息广播
				case RemoveBuff#objectBuffData.buffCfg#buffCfg.canBeenVisable =:= 0 of
					true->ok;
					false->
						Msg = #pk_DelBuff{
								  actor_id=ObjectID,
								  buff_data_id=BuffId},
						Object = map:getMapObjectByID(ObjectID),
						mapView:broadcast(Msg, Object, 0)
				end,
				
				%%使buff效果失效
				unDoBuffEffect(ObjectID, RemoveBuff),
				%%事件响应，移除buff
				onRemoveBuff( ObjectID, RemoveBuff#objectBuffData.buffCfg )
		end
	
	catch
		_->ok
	end.

%%事件响应，获得buff
onAddBuff( ObjectID, _BuffCfg )->
	try
		objectEvent:onEvent( map:getMapObjectByID(ObjectID), ?Char_Event_Add_Buff, 0),
		ok
	catch
		_->ok
	end.

%%事件响应，移除buff
onRemoveBuff( ObjectID, _BuffCfg )->
	try
		objectEvent:onEvent( map:getMapObjectByID(ObjectID), ?Char_Event_Remove_Buff, 0),
		ok
	catch
		_->ok
	end.

%%返回Buff的SkillID的objectBuffData
getObjectBuffData( ObjectID, SkillID )->
	put( "player_getObjectBuffData_return", {} ),
	try
		MyFunc = fun( Record )->
						case Record#objectBuffData.buffCfg#buffCfg.buff_id =:= SkillID of
							false->ok;
							true->put( "player_getObjectBuffData_return", Record ),throw(-1)
						end
				 end,
		
		ObjectBuffRecord = etsBaseFunc:readRecord( map:getObjectBuffTable(), ObjectID ),
		case ObjectBuffRecord of
			{}->ok;
			_->
				case ObjectBuffRecord#objectBuff.dataList of
					{}->ok;
					_->
						lists:foreach( MyFunc, ObjectBuffRecord#objectBuff.dataList )
				end
		end,
		{}
		catch
		_->get( "player_getObjectBuffData_return" )
	end.

onTimeUpdateBuff( ObjectID, ObjectBuffData, TimeLost )->
		TimeDist = TimeLost - ObjectBuffData#objectBuffData.buffCfg#buffCfg.bUFF_SingleTime,
		case TimeDist > 0 of
			true->
				doBuffEffect( ObjectID, ObjectBuffData, false ),
				RemainTime = ObjectBuffData#objectBuffData.allValidTime - ObjectBuffData#objectBuffData.buffCfg#buffCfg.bUFF_SingleTime,
				NewObjectBuffData = setelement( #objectBuffData.allValidTime, ObjectBuffData, RemainTime ),
				case ( TimeDist >= ObjectBuffData#objectBuffData.buffCfg#buffCfg.bUFF_SingleTime ) andalso
					 ( RemainTime > 0 ) of
					true->onTimeUpdateBuff( ObjectID, NewObjectBuffData, TimeDist );
					false->NewObjectBuffData#objectBuffData.allValidTime
				end;
			false->ObjectBuffData#objectBuffData.allValidTime
		end.


%%定时更新Buff
onUpdateBuff( #objectBuff{}=ObjectBuff, Now )->
	try
		MyFunc = fun( Record )->
						case Record#objectBuffData.buffCfg#buffCfg.bUFF_SingleTime > 0 of
							true->%%dot效果buff
								TimeLost = timer:now_diff( Now, Record#objectBuffData.lastDotEffectTime )/1000, 
								case TimeLost > Record#objectBuffData.buffCfg#buffCfg.bUFF_SingleTime of
									true->%%单次dot时间有效
										RemainTime = onTimeUpdateBuff( ObjectBuff#objectBuff.id, Record, TimeLost ),
										case RemainTime > 0 of
											true->%%还剩余时间
												NewRecord1 = setelement( #objectBuffData.lastDotEffectTime, Record, Now ),
												NewRecord2 = setelement( #objectBuffData.allValidTime, NewRecord1, RemainTime ),
												updateSetBuff( ObjectBuff#objectBuff.id, NewRecord2 ),
												ok;
											false->%%存活时间已完
												removeBuff( ObjectBuff#objectBuff.id, Record#objectBuffData.buff_id ),
												ok
										end;
									false->ok
								end,
								ok;
							false->
								case Record#objectBuffData.buffCfg#buffCfg.bUFF_AllTime > 0 of
									true->%%有时效的buff
										TimeLost = timer:now_diff( Now, Record#objectBuffData.startTime )/1000, 
										case TimeLost >= Record#objectBuffData.allValidTime of
											true->%%时间到
 												removeBuff( ObjectBuff#objectBuff.id, Record#objectBuffData.buff_id );
											false->ok
										end,
										ok;
									false->ok
								end,
								ok
						end
				 end,
		lists:foreach( MyFunc, ObjectBuff#objectBuff.dataList ),
		ok
	catch
		_->ok
	end.

%%清除所有不是自己给自己加的buff
clearAllOtherCasterBuff( ObjectID )->
	MyFunc = fun( Record )->
					 case Record#objectBuffData.casterID /= ObjectID of
						 true->
							 removeBuff( ObjectID, Record#objectBuffData.buff_id );
						 false->ok
					 end
			 end,
	ObjectBuffRecord = etsBaseFunc:readRecord( map:getObjectBuffTable(), ObjectID ),
	case ObjectBuffRecord of
		{}->ok;
		_->
			lists:foreach( MyFunc, ObjectBuffRecord#objectBuff.dataList )
	end.

%%清除所有debuff
clearAllDebuff( ObjectID )->
	case etsBaseFunc:readRecord( map:getObjectBuffTable(), ObjectID ) of
		{}->ok;
		BuffRecord->
			Func = fun(Record)->
						   case Record#objectBuffData.buffCfg#buffCfg.type of
							   ?Buff_Type_DEBUFF->
								   	buff:removeBuff(ObjectID, Record#objectBuffData.buff_id);
							   _->ok
						   end
				   end,
			lists:foreach( Func, BuffRecord#objectBuff.dataList )
	end.

%%死亡清除buff
deathClearBuff( ObjectID )->
	case etsBaseFunc:readRecord( map:getObjectBuffTable(), ObjectID ) of
		{}->ok;
		BuffRecord->
			Func = fun(Record)->
						   case Record#objectBuffData.buffCfg#buffCfg.buff_deathdel > 0 of
							   true->
								   buff:removeBuff(ObjectID, Record#objectBuffData.buff_id);
							   _->ok
						   end
				   end,
			lists:foreach( Func, BuffRecord#objectBuff.dataList )
	end.

%%获取object是否拥有buff
isObjectHaveBuff( ObjectID, BuffID )->
	try
		case etsBaseFunc:readRecord( map:getObjectBuffTable(), ObjectID ) of
			{}->throw(false);
			BuffRecord->
				MyFunc = fun( Record )->
										case Record#objectBuffData.buff_id =:= BuffID of
											true->
												throw(true);
											false->ok
										end
								end,
				lists:foreach(MyFunc, BuffRecord#objectBuff.dataList),
				throw(false)
		end
	catch
		Return->Return
end.

%%返回能否对某目标加血
canAddLife( SrcObject, TargetObject )->
	try
		case SrcObject of
			{}->throw( {return, false} );
			_->ok
		end,
		case TargetObject of
			{}->throw( {return, false} );
			_->ok
		end,
		
		SrcObjectID = element( ?object_id_index, SrcObject ),
		TargetObjectID = element( ?object_id_index, TargetObject ),
		
		CanNotState = ( ?Actor_State_Flag_Dead ) bor ( ?Actor_State_Flag_Disable_Hold ) bor
	                  ( ?Player_State_Flag_ChangingMap ),
		case ( mapActorStateFlag:isStateFlag(SrcObjectID, CanNotState ) ) or
			  ( mapActorStateFlag:isStateFlag(TargetObjectID, CanNotState ) ) of
			true->throw( {return, false} );
			false->ok
		end,

		{ CanAttack, _FailCode } = objectAttack:getAttackRelation(SrcObject, TargetObject),
		case CanAttack of
			true->throw( {return, false} );
			false->ok
		end,

		true
	catch
		{ return, Return }->Return
	end.

%%喝药加血buff
doBuff_AddLifeByItem(ObjectID, NewObjectBuff)->
	SrcObject = map:getMapObjectByID( NewObjectBuff#objectBuffData.casterID ),
	TargetObject = map:getMapObjectByID( ObjectID ),
	case canAddLife( SrcObject, TargetObject ) of
		true->
			MaxLife = charDefine:getObjectProperty(TargetObject, ?max_life ),
			CurLife = charDefine:getObjectLife(TargetObject),
			CanAddLife = MaxLife - CurLife,
			AddLife = NewObjectBuff#objectBuffData.buffCfg#buffCfg.damageFixValue,
			case AddLife > CanAddLife of
				true->RealAddLife = CanAddLife;
				false->RealAddLife = AddLife
			end,
			
			charDefine:changeSetLife(TargetObject, RealAddLife + CurLife, false ),
			
			MsgToUser = #pk_GS2U_AddLifeByItem{ actorID=ObjectID,addLife=AddLife, percent=charDefine:getObjectLifePercent( map:getMapObjectByID( ObjectID ) ) },
			mapView:broadcast(MsgToUser, TargetObject, 0),

			ok;
		false->false
	end.

%%技能加血
doBuff_AddLifeBySkill(ObjectID, NewObjectBuff)->
	SrcObject = map:getMapObjectByID( NewObjectBuff#objectBuffData.casterID ),
	TargetObject = map:getMapObjectByID( ObjectID ),
	case ( canAddLife( SrcObject, TargetObject ) ) andalso
		 ( NewObjectBuff#objectBuffData.skillCfg =/= 0 ) of
		true->
			MaxLife = charDefine:getObjectProperty(TargetObject, ?max_life ),
			CurLife = charDefine:getObjectLife(TargetObject),
			CanAddLife = MaxLife - CurLife,
			
			DamageInfo = #damageInfo{ attackerID=element( ?object_id_index, SrcObject ),
								  beenAttackerID=element( ?object_id_index, TargetObject ),
								  skillDamageID=0,
								  damage=0,
								  isBlocked=false,
								  isCrited=false
								  },
			
			SkillCfg = NewObjectBuff#objectBuffData.skillCfg,
			SkillCfg2 = setelement( #skillCfg.damageType, SkillCfg, NewObjectBuff#objectBuffData.buffCfg#buffCfg.damageType ),
			SkillCfg3 = setelement( #skillCfg.damagePercent, SkillCfg2, NewObjectBuff#objectBuffData.buffCfg#buffCfg.damagePercent ),
			SkillCfg4 = setelement( #skillCfg.damageFixValue, SkillCfg3, NewObjectBuff#objectBuffData.buffCfg#buffCfg.damageFixValue ),
			DamageInfo2 = damageCalculate:calc_Skill_Damage( SrcObject, SkillCfg4, TargetObject, DamageInfo ),
			case DamageInfo2#damageInfo.isCrited of
				true->Crited = 1;
				false->Crited = 0
			end,

			AddLife = DamageInfo2#damageInfo.damage,
			
			case AddLife > CanAddLife of
				true->RealAddLife = CanAddLife;
				false->RealAddLife = AddLife
			end,
			
			charDefine:changeSetLife(TargetObject, RealAddLife + CurLife, false ),
			
			MsgToUser = #pk_GS2U_AddLifeBySkill{
												actorID = ObjectID,
												 addLife=AddLife, 
												 percent=charDefine:getObjectLifePercent( map:getMapObjectByID( ObjectID ) ),
												 crite=Crited },
			mapView:broadcast(MsgToUser, TargetObject, 0),

			ok;
		false->false
	end.

%%血池加血
doBuff_AddLifeByBloodPool(ObjectID, _NewObjectBuff)->
	try
		Object = map:getMapObjectByID(ObjectID),
		case Object =:= {} of
			true->throw(-1);
			false->ok
		end,
		
		ObjectType = element(1, Object),
		case ObjectType of
			mapPlayer->
				Level = Object#mapPlayer.level;
			mapPet->
				Level = Object#mapPet.level;
			_->
				Level = 0,
				throw(-1)
		end,
		
		HPCfg = etsBaseFunc:readRecord(globalSetup:getGlobalHPContainerTable(), Level),
		case HPCfg of
			{}->throw(-1);
			_->ok
		end,
		
		case ObjectType of
			mapPlayer->
				AddLife = HPCfg#hpContainerCfg.player_value;
			mapPet->
				AddLife = HPCfg#hpContainerCfg.pet_value
		end,
		
		MaxLife = charDefine:getObjectProperty(Object, ?max_life ),
		CurLife = charDefine:getObjectLife(Object),
		CanAddLife = MaxLife - CurLife,
		case AddLife > CanAddLife of
			true->RealAddLife = CanAddLife;
			false->RealAddLife = AddLife
		end,
			
		charDefine:changeSetLife(Object, RealAddLife + CurLife, true ),
		
		MsgToUser = #pk_GS2U_AddLifeByItem{ actorID=ObjectID,addLife=AddLife, percent=charDefine:getObjectLifePercent( map:getMapObjectByID( ObjectID ) ) },
		mapView:broadcast(MsgToUser, Object, 0)
	
	catch
		_->ok
end.

