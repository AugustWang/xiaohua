%% Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(playerSkill).

-include("db.hrl").
-include("taskDefine.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("monsterDefine.hrl").
-include("itemDefine.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("logdb.hrl").


%%
%% Exported Functions
%%
-compile(export_all). 

%%--------------------------------------地图进程-------------------------------------------------------
%%返回玩家ID与技能ID的组合值
%%构建物件ID，64位(前1位永为0保持正数(64)，9位服务器ID(55-63)，5位类型ID(50-54)，14位SkillID值(35-49)，35位PlayerID值(1-34))

%%构建物件ID，64位(前1位永为0保持正数(64)，11位服务器ID(53-63)，14位SkillID值(39-52)，38位PlayerID值(1-38))
getPlayerSkillID( PlayerID, SkillID )->
	OutID = ( ( main:getServerID() band 16#7FF ) bsl 52 ) bor ( ( SkillID band 16#3FFF ) bsl 38 ) bor ( PlayerID band 16#3FFFFFFFFF ) ,
	OutID.

%%返回玩家IDValue
getPlayerIDValueByPSkillID( PSkillID )->
	%%34359738367=0x7ffffffff
	OutID = ( PSkillID band 16#3FFFFFFFFF ),
	OutID.

%%玩家所有被动技能生效
doAllPlayerPassiveSkill({}) ->
	ok;
doAllPlayerPassiveSkill(#mapPlayer{}=Player) ->
	Q = ets:fun2ms( fun(#playerSkill{id=_,playerId=PlayerId} = Record ) when ( PlayerId=:=Player#mapPlayer.id ) -> Record end),
	Skilllist = ets:select(map:getPlayerSkillTable(), Q),
	
	Fun = fun(Skill) ->
		%%如果有绑定的技能，使用绑定的技能效果
		case Skill#playerSkill.curBindedSkillID of
			0->
			SkillCfg =  etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), Skill#playerSkill.skillId);
			_->
			SkillCfg =  etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), Skill#playerSkill.curBindedSkillID)
		end, 
		case SkillCfg of
			{}->ok;
			_->	
				case SkillCfg#skillCfg.skillTriggerType of
					?SkillTrigger_Passive->
						case SkillCfg#skillCfg.skillUseTargetType of
							?SkillUseTarget_Self->
								%%对自己使用
								objectAttack:doPassiveSkillEffect(Player, SkillCfg, Player);
							_->ok
						end;
					_->ok
				end
		end
	end,
	lists:foreach(Fun, Skilllist).

%%玩家单个被动技能生效
doPlayerPassiveSkill(#mapPlayer{}=Player, #playerSkill{}=PlayerSkill)->
	%%如果有绑定的技能，使用绑定的技能效果
	case PlayerSkill#playerSkill.curBindedSkillID of
		0-> 
			SkillCfg =  etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), PlayerSkill#playerSkill.skillId);
		_->
			SkillCfg =  etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), PlayerSkill#playerSkill.curBindedSkillID) 
	end, 
	case SkillCfg of
		{}->ok; 
		_->
			case SkillCfg#skillCfg.skillTriggerType of
				?SkillTrigger_Passive-> 
					case SkillCfg#skillCfg.skillUseTargetType of
						?SkillUseTarget_Self->
							%%对自己使用 	
							objectAttack:doPassiveSkillEffect(Player, SkillCfg, Player); 
						_->ok
					end;
				_->ok
			end
	end.


unDoAllPassiveSkill({}) ->
	ok;
%%删除玩家所有被动技能效果
unDoAllPassiveSkill(#mapPlayer{}=Player) ->
	Q = ets:fun2ms( fun(#playerSkill{id=_,playerId=PlayerId} = Record ) when ( PlayerId=:=Player#mapPlayer.id ) -> Record end),
	Skilllist = ets:select(map:getPlayerSkillTable(), Q),
	
	Fun = fun(Skill) ->
				  %%如果有绑定的技能，删除绑定的技能效果
				  case Skill#playerSkill.curBindedSkillID of
					  0->
						  SkillCfg =  etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), Skill#playerSkill.skillId);
					  _->
						  SkillCfg =  etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), Skill#playerSkill.curBindedSkillID)
				  end, 
				  case SkillCfg of
					  {}->ok;
					  _->
						  case SkillCfg#skillCfg.skillTriggerType of
							  ?SkillTrigger_Passive->
								  case SkillCfg#skillCfg.skillUseTargetType of
									  ?SkillUseTarget_Self->
										  %%对自己使用 											
										  objectAttack:doRemovePassiveSkillEffect(Player, SkillCfg);
									  _->ok
								  end;
							  _->ok
						  end
				  end
		  end,
	lists:foreach(Fun, Skilllist).

%%删除玩家一个被动技能效果
unDoPassiveSkill(#mapPlayer{}=Player,  #playerSkill{}=Skill) ->
	%%如果有绑定的技能，删除绑定的技能效果 
	case Skill#playerSkill.curBindedSkillID of
		0->
			SkillCfg =  etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), Skill#playerSkill.skillId);
		_->
			SkillCfg =  etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), Skill#playerSkill.curBindedSkillID)
	end,  
	case SkillCfg of
		{}->ok;
		_->
			case SkillCfg#skillCfg.skillTriggerType of
				?SkillTrigger_Passive->
					case SkillCfg#skillCfg.skillUseTargetType of
						?SkillUseTarget_Self->
							%%对自己使用
							objectAttack:doRemovePassiveSkillEffect(Player, SkillCfg);
						_->ok
					end;
				_->ok
			end
	end.

%%初始化玩家技能
onPlayerEnterMapInitSkill( #mapPlayer{}=_Player, SkillList )->
	MyFunc = fun( Record )->
					 etsBaseFunc:insertRecord( map:getPlayerSkillTable(), Record )
			 end,
	lists:foreach( MyFunc, SkillList ).

%%返回玩家是否学会某技能
hasPlayerSkill( PlayerID, SkillID )->
	case etsBaseFunc:readRecord( map:getPlayerSkillTable(), getPlayerSkillID( PlayerID, SkillID ) ) of
		{}->false;
		_->true
	end.

%%返回玩家的技能是否在CD中
isPlayerSkillCDing( PlayerID, SkillID )->
	PlayerSkill = etsBaseFunc:readRecord( map:getPlayerSkillTable(), getPlayerSkillID( PlayerID, SkillID ) ),
	case PlayerSkill of
		{}->true;
		_->
			TimeDist = common:milliseconds() - PlayerSkill#playerSkill.coolDownTime,
			case TimeDist > 0 of
				true->false;
				false->true
			end
	end.

%%设置玩家技能CD
setPlayerSkillCDBegin( PlayerID, SkillCfg, CoolDown )->
	etsBaseFunc:changeFiled( map:getPlayerSkillTable(), 
							 getPlayerSkillID( PlayerID, SkillCfg#skillCfg.skill_id ), 
							 #playerSkill.coolDownTime, 
							 common:milliseconds() + CoolDown ).

%%设置玩家技能CD
setPlayerSkillCDBegin( PlayerID, SkillCfg )->
	etsBaseFunc:changeFiled( map:getPlayerSkillTable(), 
							 getPlayerSkillID( PlayerID, SkillCfg#skillCfg.skill_id ), 
							 #playerSkill.coolDownTime, 
							 common:milliseconds() + SkillCfg#skillCfg.skillCoolDown ).

%%--------------------------------------玩家进程-------------------------------------------------------
%%返回玩家技能表
getSkillTable()->
	SkillTable = get( "SkillTable" ),
	case SkillTable of
		undefined->0;
		_->SkillTable
	end.

%%返回玩家技能列表
getSkillList()->
	Q = ets:fun2ms(fun(#playerSkill{_ = '_'} = Record) -> Record end),
	ets:select(getSkillTable(), Q).


%%角色创建时赠送玩家技能
onPlayerCreateSkillInit( PlayerID, PlayerClass )->
	case PlayerClass of
		?Player_Class_Fighter->
			Skill = #playerSkill { id=getPlayerSkillID(PlayerID, 1 ), playerId=PlayerID, skillId=1, coolDownTime=0,
								 activationSkillID1=0, activationSkillID2=0, curBindedSkillID=0};
		?Player_Class_Shooter->
			Skill = #playerSkill { id=getPlayerSkillID(PlayerID, 141 ), playerId=PlayerID, skillId=141, coolDownTime=0,
								   activationSkillID1=0, activationSkillID2=0, curBindedSkillID=0};
		?Player_Class_Master->
			Skill = #playerSkill { id=getPlayerSkillID(PlayerID, 281 ), playerId=PlayerID, skillId=281, coolDownTime=0,
								   activationSkillID1=0, activationSkillID2=0, curBindedSkillID=0};
		?Player_Class_Pastor->
			Skill = #playerSkill { id=getPlayerSkillID(PlayerID, 421 ), playerId=PlayerID, skillId=421, coolDownTime=0,
								   activationSkillID1=0, activationSkillID2=0, curBindedSkillID=0};
		_->Skill=0,ok
	end,
	mySqlProcess:insertPlayerSkillGamedata(Skill),
	Skill.


%%玩家上线技能初始化
onPlayerOnlineSkillInit( SkillList )->
	try
		MyFunc = fun( Record )->
						 etsBaseFunc:insertRecord( getSkillTable(), Record ),
						 %SkillCfg =  etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), Record#playerSkill.skillId),
						 NowMilliSecond=common:milliseconds(),
						 RemainTime = Record#playerSkill.coolDownTime - NowMilliSecond,
						case RemainTime >0 of
							 true->
								 SkillCD = (RemainTime div 1000) + 1;						 
							 false->
								SkillCD = 0						 
						 end,
						 #pk_PlayerSkillInitData{ nSkillID=Record#playerSkill.skillId, nCD=SkillCD, 
												  nActiveBranch1=Record#playerSkill.activationSkillID1,
												  nActiveBranch2=Record#playerSkill.activationSkillID2,
												  nBindedBranch=Record#playerSkill.curBindedSkillID}
				 end,
		MsgList = lists:map( MyFunc, SkillList ),
		player:send( #pk_PlayerSkillInitInfo{info_list=MsgList} ),
		ok
	catch
		_->ok
	end.

%%玩家进程 
studySkillMsgSendToMap(SkillID)->
	try
		case get("player_study_skill_wait") of
				undefined->ok;
				1->throw(-1);
				_->ok
		end,
		player:sendMsgToMap({msg_u2gs_PlayerStudySkill, self(), player:getCurPlayerID(), SkillID})
	catch
		_->
			Msg = #pk_GS2U_StudySkillResult{nSkillID = SkillID,
											nResult = ?StudyResult_OPFrequent},
			player:send(Msg)
	end.
%%地图进程，判断技能是否学过
playerHasStudySkill(FromPid, PlayerID, SkillID)->
	FromPid ! {msg_playerHasSkillResult, SkillID, hasPlayerSkill(PlayerID, SkillID)}.

%%是否是仙盟技能
isGuildSkill(Skill)->
	Skill#skillCfg.skillClass =:= ?SkillClass_Guild.

%%玩家学习技能
u2gs_PlayerStudySkill(SkillID, Result)->
	try
		put("U2GS_PlayerStudySkillResult", ?StudyResult_Success),
		
		SkillCfg = etsBaseFunc:readRecord( main:getGlobalSkillCfgTable(), SkillID ),
		case SkillCfg of
			{}->
				put("U2GS_PlayerStudySkillResult", ?StudyResult_NoSkill),
				throw(-1);
			_->ok
		end,
		
		case Result of
			true->
				put("U2GS_PlayerStudySkillResult", ?StudyResult_AlreadyStuey),
				throw(-1);
			false->
				ok
		end,

		%% 增加仙盟技能学习仙盟的检查 add by yueliangyou [2013-05-04]
		case isGuildSkill(SkillCfg) of 
			true->
				GuildID = player:getCurPlayerProperty(#player.guildID),
				case GuildID > 0 of
					true->ok;
					false->
						put("U2GS_PlayerStudySkillResult", ?StudyResult_NoGuild),
						throw(-1)
				end,

				%% 获取仙盟等级
				GuildLevel = gen_server:call(guildProcess_PID,{'getGuildLevel',GuildID}),
				NeedGuildLevel = (SkillCfg#skillCfg.level-1) div 2,
				case GuildLevel > NeedGuildLevel of
					true->ok;
					false->
						put("U2GS_PlayerStudySkillResult", ?StudyResult_GuildLevel),
						throw(-1)
				end;
			false->ok
		end,
		
		case player:getCurPlayerProperty(#player.level) < SkillCfg#skillCfg.studylevel of
			true->
				put("U2GS_PlayerStudySkillResult", ?StudyResult_PlayerLvl),
				throw(-1);
			false->
				ok
		end,
		
		case player:getCurPlayerProperty(#player.money) + player:getCurPlayerProperty(#player.moneyBinded) < SkillCfg#skillCfg.castMoney of
			true->
				put("U2GS_PlayerStudySkillResult", ?StudyResult_Money),
				throw(-1);
			false->
				ok
		end,
			
		%% 增加仙盟技能的声望检查 add by yueliangyou [2013-05-04]	
		case player:getCurPlayerProperty(#player.credit) < SkillCfg#skillCfg.castCredit of
			true->
				put("U2GS_PlayerStudySkillResult", ?StudyResult_Credit),
				throw(-1);
			false->
				ok
		end,
				
%%相关操作
		player:sendMsgToMap({msg_PlayerStudySkill, self(), player:getCurPlayerID(), SkillID}),

		Rule = ets:fun2ms(fun(#playerSkill{_='_',skillId = RuleSkillID} = Record) when (RuleSkillID =:= (SkillID-1))->Record end),
		PreSkillList = ets:select(getSkillTable(), Rule),
		case PreSkillList of
			[]->
				PlayerSkill = #playerSkill{id = getPlayerSkillID(player:getCurPlayerID(), SkillID), 
							   playerId = player:getCurPlayerID(), 
							   skillId = SkillID,
							   coolDownTime = 0,
							   activationSkillID1=0, 
							   activationSkillID2=0, 
							   curBindedSkillID=0
							  };
			[PreSkill|_]->
				%%===============================================================================================
				%% 修改技能学习的bug，add by yueliangyou [2013-05-22]
				SkillGroup0=SkillCfg#skillCfg.skill_group,
				SkillCfg1 = etsBaseFunc:readRecord( main:getGlobalSkillCfgTable(), PreSkill#playerSkill.skillId),
				case SkillCfg1 of
					{}->SkillGroup1=0;
					_->SkillGroup1=SkillCfg1#skillCfg.skill_group
				end,
				?DEBUG_OUT("SkillGroup0=~p,SkillGroup1=~p",[SkillGroup0,SkillGroup1]),
				case SkillGroup0 =:= SkillGroup1 of
					false->
						PlayerSkill = #playerSkill{id = getPlayerSkillID(player:getCurPlayerID(), SkillID), 
						   playerId = player:getCurPlayerID(), 
						   skillId = SkillID,
						   coolDownTime = 0,
						   activationSkillID1=0, 
						   activationSkillID2=0, 
						   curBindedSkillID=0};
					true->
			%%===============================================================================================
						case PreSkill#playerSkill.activationSkillID1 =:= 0 of
							true->
								ActivationSkillID1 = PreSkill#playerSkill.activationSkillID1;
							false->
								ActivationSkillID1 = PreSkill#playerSkill.activationSkillID1 + 1
						end,
						case PreSkill#playerSkill.activationSkillID2 =:= 0 of
							true->
								ActivationSkillID2 = PreSkill#playerSkill.activationSkillID2;
							false->
								ActivationSkillID2 = PreSkill#playerSkill.activationSkillID2 + 1
						end,
						case PreSkill#playerSkill.curBindedSkillID =:= 0 of
							true->
								CurBindedSkillID = PreSkill#playerSkill.curBindedSkillID;
							false->
								CurBindedSkillID = PreSkill#playerSkill.curBindedSkillID + 1
						end,
						PlayerSkill = #playerSkill{id = getPlayerSkillID(player:getCurPlayerID(), SkillID), 
							   playerId = player:getCurPlayerID(), 
							   skillId = SkillID,
							   coolDownTime = 0,
							   activationSkillID1=ActivationSkillID1, 
							   activationSkillID2=ActivationSkillID2, 
							   curBindedSkillID=CurBindedSkillID
							  },
						etsBaseFunc:deleteRecord(getSkillTable(), PreSkill#playerSkill.id),
						mySqlProcess:deletePlayerSkillGamedata(PreSkill#playerSkill.playerId, PreSkill#playerSkill.skillId) 
				end
		end,
		
		etsBaseFunc:insertRecord(getSkillTable(), PlayerSkill),
		mySqlProcess:insertPlayerSkillGamedata(PlayerSkill)

	catch
		_->
			put("player_study_skill_wait", 0),
			StudyResult = get("U2GS_PlayerStudySkillResult"),
			Msg = #pk_GS2U_StudySkillResult{nSkillID = SkillID,
											nResult = StudyResult},
			player:send(Msg)
	end.

%%地图进程，玩家学习技能
%% 在玩家进程里调用的方法已更新了db,所以地图进程中的调用都不再需要更新db
 onMsgPlayerStudySkill(FromPID, PlayerID, SkillID)->
%% 	etsBaseFunc:readRecord( map:getPlayerSkillTable(), getPlayerSkillID( PlayerID, SkillID ) ),
	Rule = ets:fun2ms(fun(#playerSkill{_='_',skillId = RuleSkillID} = Record) when (RuleSkillID =:= (SkillID-1))->Record end),
	PreSkillList = ets:select(map:getPlayerSkillTable(), Rule),
	case PreSkillList of
		[]->
			PlayerSkill = #playerSkill{id = getPlayerSkillID(PlayerID, SkillID), 
						   playerId = PlayerID, 
						   skillId = SkillID,
						   coolDownTime = 0,
						   activationSkillID1=0, 
						   activationSkillID2=0, 
						   curBindedSkillID=0
						  };
		[PreSkill|_]->
			%%===============================================================================================
			%% 修改技能学习的bug，add by yueliangyou [2013-05-22]
			SkillCfg0 = etsBaseFunc:readRecord( main:getGlobalSkillCfgTable(), SkillID ),
			case SkillCfg0 of
				{}->SkillGroup0=0;
				_->SkillGroup0=SkillCfg0#skillCfg.skill_group
			end,
			SkillCfg1 = etsBaseFunc:readRecord( main:getGlobalSkillCfgTable(), PreSkill#playerSkill.skillId),
			case SkillCfg1 of
				{}->SkillGroup1=0;
				_->SkillGroup1=SkillCfg1#skillCfg.skill_group
			end,
			?DEBUG_OUT("SkillGroup0=~p,SkillGroup1=~p",[SkillGroup0,SkillGroup1]),
			case SkillGroup0 =:= SkillGroup1 of
				false->
					PlayerSkill = #playerSkill{id = getPlayerSkillID(PlayerID, SkillID), 
						   playerId = PlayerID, 
						   skillId = SkillID,
						   coolDownTime = 0,
						   activationSkillID1=0, 
						   activationSkillID2=0, 
						   curBindedSkillID=0};
				true->
			%%===============================================================================================
					case PreSkill#playerSkill.activationSkillID1 =:= 0 of
						true->
							ActivationSkillID1 = PreSkill#playerSkill.activationSkillID1;
						false->
							ActivationSkillID1 = PreSkill#playerSkill.activationSkillID1 + 1
					end,
					case PreSkill#playerSkill.activationSkillID2 =:= 0 of
						true->
							ActivationSkillID2 = PreSkill#playerSkill.activationSkillID2;
						false->
							ActivationSkillID2 = PreSkill#playerSkill.activationSkillID2 + 1
					end,
					case PreSkill#playerSkill.curBindedSkillID =:= 0 of
						true->
							CurBindedSkillID = PreSkill#playerSkill.curBindedSkillID;
						false->
							CurBindedSkillID = PreSkill#playerSkill.curBindedSkillID + 1
					end,
					PlayerSkill = #playerSkill{id = getPlayerSkillID(PlayerID, SkillID), 
						   playerId = PlayerID, 
						   skillId = SkillID,
						   coolDownTime = 0,
						   activationSkillID1=ActivationSkillID1, 
						   activationSkillID2=ActivationSkillID2, 
						   curBindedSkillID=CurBindedSkillID},
					etsBaseFunc:deleteRecord(map:getPlayerSkillTable(), PreSkill#playerSkill.id)
			end
	end,
	etsBaseFunc:insertRecord(map:getPlayerSkillTable(), PlayerSkill),
	FromPID ! {msg_studySkillSuccess, SkillID}.

%%玩家进程，技能学习成功
playerStudySkillSucess(SkillID)->
	?DEBUG_OUT("playerStudySkillSucess ..."),
	SkillCfg = etsBaseFunc:readRecord( main:getGlobalSkillCfgTable(), SkillID ),
	case SkillCfg of
		{}->
			ok;
		_->
			case playerMoney:canUsePlayerBindedMoney(SkillCfg#skillCfg.castMoney) of
				true->
					ParamTuple = #token_param{changetype = ?Money_Change_StudySkill,param1=SkillCfg#skillCfg.skill_id},
					playerMoney:usePlayerBindedMoney(SkillCfg#skillCfg.castMoney, ?Money_Change_StudySkill, ParamTuple);
				false->
					ParamTuple = #token_param{changetype = ?Money_Change_StudySkill,param1=SkillCfg#skillCfg.skill_id},
					playerMoney:addPlayerMoney(-(SkillCfg#skillCfg.castMoney), ?Money_Change_StudySkill,ParamTuple)
			end,

			%% 减少玩家声望 add by yueliangyou [2013-05-04]
			%%player:addCurPlayerCredit(-(SkillCfg#skillCfg.castCredit),0)
			player:costCurPlayerCredit(SkillCfg#skillCfg.castCredit, 0)
			
	end,
	
	?DEBUG_OUT("playerStudySkillSucess ..."),
	%%玩家被动技能生效
	gen_server:cast(player:getCurPlayerProperty(#player.mapPID),{'reloadPassiveSkill',player:getCurPlayerID()}),

	put("player_study_skill_wait", 0),
	Msg = #pk_GS2U_StudySkillResult{nSkillID = SkillID,nResult = ?StudyResult_Success},
	player:send(Msg),
	task:updateTaskProgress(?TASKTYPE_LEARNSKILL, SkillID, 1).

%%实现分支技能的技能改变
%% playerSkillChange(PlayerID, SkillID, DstSkillID)->
%% 	PlayerSkill = etsBaseFunc:readRecord(map:getPlayerSkillTable(), getPlayerSkillID(PlayerID, SkillID)),
%% 	case PlayerSkill of
%% 		{}->
%% 			ok;
%% 		_->
%% 			etsBaseFunc:changeFiled(map:getPlayerSkillTable(), getPlayerSkillID(PlayerID, SkillID), #playerSkill.skillId, DstSkillID),
%% 			etsBaseFunc:changeFiled(getSkillTable(), getPlayerSkillID(PlayerID, SkillID), #playerSkill.skillId, DstSkillID),
%% 			%-record(playerSkill, {id, playerId, skillId,coolDownTime, activationSkillID1, activationSkillID2, curBindedSkillID} ).
%% 			%PlayerChangedSkill = etsBaseFunc:readRecord(map:getPlayerSkillTable(), getPlayerSkillID(PlayerID, SkillID)),
%% 			ok
%% 	end.

%%玩家激活技能
playerSkillBranchActived(PlayerID, SkillID, BranchID, WhichBranch)->
	try
		put("SkillActived_Result", ?Skill_Active_Success),
		PlayerSkill = etsBaseFunc:readRecord(getSkillTable(), getPlayerSkillID(PlayerID, SkillID)),
		case PlayerSkill of
			{}->
				put("SkillActived_Result", ?Skill_Active_TrunkNo_Study),
				throw(-1);
			_->
				ok
		end,
		
		case isBranchSkill(SkillID, BranchID) of
			true->
				ok;
			false->
				put("SkillActived_Result", ?Skill_Active_NotBelong_Trunk),
				throw(-1)
		end,
		
		%%判断消耗的道具
		BranchSkillCfg = etsBaseFunc:readRecord( main:getGlobalSkillCfgTable(), BranchID ),
		put("SkillActived_ItemList", []),
		case BranchSkillCfg of
			{}->
				put("SkillActived_Result", ?Skill_Active_NotItem),
				throw(-1);
			_->
				[CanDec|CanDecItemInBagResult] = playerItems:canDecItemInBag(?Item_Location_Bag, BranchSkillCfg#skillCfg.useItemID, 1, "all"),
				case CanDec of
					true->
						put("SkillActived_ItemList", CanDecItemInBagResult);
					false->
						put("SkillActived_Result", ?Skill_Active_NotItem),
						throw(-1)
				end
		end,
		
		case WhichBranch of
			1->
				etsBaseFunc:changeFiled(getSkillTable(), getPlayerSkillID(PlayerID, SkillID), #playerSkill.activationSkillID1, BranchID),
				%% must update db,activationSkillID1 changed
				PlayerChangedSkill = etsBaseFunc:readRecord(getSkillTable(), getPlayerSkillID(PlayerID, SkillID)),
				mySqlProcess:updatePlayerSkillGamedata(PlayerChangedSkill);
				
			2->
				etsBaseFunc:changeFiled(getSkillTable(), getPlayerSkillID(PlayerID, SkillID), #playerSkill.activationSkillID2, BranchID),
				%% must update db,activationSkillID1 changed
				PlayerChangedSkill = etsBaseFunc:readRecord(getSkillTable(), getPlayerSkillID(PlayerID, SkillID)),
				mySqlProcess:updatePlayerSkillGamedata(PlayerChangedSkill);
			_->
				put("SkillActived_Result", ?Skill_Active_Unknown),
				throw(-1)
		end,
		
		player:sendMsgToMap({msg_PlayerSkillActive, self(), PlayerID, SkillID, BranchID, WhichBranch}),
		
		case get("SkillActived_ItemList") of
			[]->
				ok;
			_->
				playerItems:decItemInBag( get("SkillActived_ItemList"), ?Destroy_Item_Reson_ActiveSkill )
		end,
		
		MsgSuccess = #pk_activeBranchIDResult{result = 0,
									   nSkillID = SkillID,
									   branckID = BranchID},
		player:send(MsgSuccess)
	catch
		_->
			Result = get( "SkillActived_Result" ),
			MsgFail = #pk_activeBranchIDResult{result = Result,
											nSkillID = SkillID,
											branckID = BranchID},
			player:send(MsgFail)
	end.

%%地图进程，玩家激活技能
%% 在玩家进程里调用的方法已更新了db,所以地图进程中的调用都不再需要更新db
mapPlayerSkillActived(_FromPID, PlayerID, TrunkID, BranchID, WhichBranch )->
	case WhichBranch of
		1->
			etsBaseFunc:changeFiled(map:getPlayerSkillTable(), getPlayerSkillID(PlayerID, TrunkID), #playerSkill.activationSkillID1, BranchID);
		2->
			etsBaseFunc:changeFiled(map:getPlayerSkillTable(), getPlayerSkillID(PlayerID, TrunkID), #playerSkill.activationSkillID2, BranchID);
		_->
			ok
	end.
	

%%判断是否属于分支技能 
isBranchSkill(TrunkID, BranchID)->
	try
		TrunkSkill = etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), TrunkID),
		case TrunkSkill of
			{}->
				throw(-1);
			_->
				ok
		end,
		
		BranchSkill = etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), BranchID),
		case BranchSkill of
			{}->
				throw(-1);
			_->
				ok
		end,
		
		case BranchSkill#skillCfg.branchof =:= TrunkSkill#skillCfg.skill_group of
			true->
				ok;
			false->
				throw(-1)
		end,
		
		true
	catch
		_->
			false
	end.

%%玩家装备分支技能
on_U2GS_playerSkillBranchAdd(PlayerID, TrunkID, BranchID)->
	try
%% 		put("SkillActived_Result", ?Skill_Active_Success),
		PlayerSkill = etsBaseFunc:readRecord(getSkillTable(), getPlayerSkillID(PlayerID, TrunkID)),
		case PlayerSkill of
			{}->
%% 				put("SkillActived_Result", ?Skill_Active_TrunkNo_Study),
				throw(-1);
			_->
				ok
		end,
		
		case isBranchSkill(TrunkID, BranchID) of
			true->
				ok;
			false->
%% 				put("SkillActived_Result", ?Skill_Active_NotBelong_Trunk),
				throw(-1)
		end,
		
		player:sendMsgToMap({msg_PlayerAddSkillBranch, self(), PlayerID, TrunkID, BranchID}),
%% 		
		etsBaseFunc:changeFiled(getSkillTable(), getPlayerSkillID(PlayerID, TrunkID), #playerSkill.curBindedSkillID, BranchID),
		%% must update db,
		PlayerChangedSkill = etsBaseFunc:readRecord(getSkillTable(), getPlayerSkillID(PlayerID, TrunkID)),
		mySqlProcess:updatePlayerSkillGamedata(PlayerChangedSkill),
		
		MsgSuccess = #pk_GS2U_AddSkillBranchAck{result = 0,
									   			nSkillID = TrunkID,
									   			nBranchID = BranchID},
		player:send(MsgSuccess)
	catch
		_->
			Result = get( "SkillActived_Result" ),
			MsgFail = #pk_GS2U_AddSkillBranchAck{result = Result,
													nSkillID = TrunkID,
													nBranchID = BranchID},
			player:send(MsgFail)
	end.

%%地图进程，玩家绑定分支技能  
%% 在玩家进程里调用的方法已更新了db,所以地图进程中的调用都不再需要更新db
mapPlayerAddSkillBranch(_FromPID, PlayerID, TrunkID, BranchID )->
	etsBaseFunc:changeFiled(map:getPlayerSkillTable(), getPlayerSkillID(PlayerID, TrunkID), #playerSkill.curBindedSkillID, BranchID).

%%玩家拆除分支技能
on_U2GS_playerSkillBranchRemove(PlayerID, SkillID)->
	try
		PlayerSkill = etsBaseFunc:readRecord(getSkillTable(), getPlayerSkillID(PlayerID, SkillID)),
		case PlayerSkill of
			{}->
				throw(-1);
			_->
				ok
		end,
	
		case PlayerSkill#playerSkill.curBindedSkillID =:= 0 of
			true->
				throw(-1);
			false->
				ok
		end,
		
		player:sendMsgToMap({msg_PlayerRemoveSkillBranch, self(), PlayerID, SkillID}),
		
		etsBaseFunc:changeFiled(getSkillTable(), getPlayerSkillID(PlayerID, SkillID), #playerSkill.curBindedSkillID, 0),
		
		%%update db
		PlayerChangedSkill = etsBaseFunc:readRecord(getSkillTable(), getPlayerSkillID(PlayerID, SkillID)),
		mySqlProcess:updatePlayerSkillGamedata(PlayerChangedSkill),
	
		MsgSuccess = #pk_GS2U_RemoveSkillBranch{result = 0,
									   			nSkillID = SkillID},
		player:send(MsgSuccess)
	catch
		_->
			MsgFail = #pk_GS2U_AddSkillBranchAck{result = -1,
													nSkillID = SkillID},
			player:send(MsgFail)
	end.

%%地图进程，玩家拆除分支技能
mapPlayerRemoveSkillBranch(_FromPID, PlayerID, SkillID )->
	etsBaseFunc:changeFiled(map:getPlayerSkillTable(), getPlayerSkillID(PlayerID, SkillID), #playerSkill.curBindedSkillID, 0).
