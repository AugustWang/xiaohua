
%% friend_gamedata table
%-record(friendDB, {id,playerID,friendType,friendID,friendName,friendSex,friendFace,friendClassType,friendLevel,friendVip,friendValue,friendOnline}).
-record(friend_gamedata, {id,playerID,friendType,friendID,friendName,friendSex,friendFace,friendClassType,friendValue}).

%% player table
% delete mapPID,stateFlag from player
-record(player_gamedata,{id,name,userId, map_data_id,mapId,x,y,
				level, camp, faction, sex, crossServerHonor, unionContribute, 
				competMoney, weekCompet, battleHonor, aura, charm, vip, 
				maxEnabledBagCells,maxEnabledStorageBagCells,storageBagPassWord,unlockTimes, 
				money, moneyBinded, gold, goldBinded, ticket, guildContribute, honor, credit,
				life, exp, lastOnlineTime, lastOfflineTime, isOnline, createTime, guildID,
				conBankLastFindTime, chatLastSpeakTime,
				outFightPet, mapCDInfoList,pK_Kill_Value,pK_Kill_OpenTime,pk_Kill_Punish,playerMountInfo,
				playerItemCDInfo,bloodPoolLife,playerItem_DailyCountInfo,gmLevel,petBloodPoolLife,
				fightingCapacity,fightingCapacityTop,platSendItemBits,gameSetMenu,rechargeAmmount,varArray,forbidChatFlag,
				protectPwd,reasureBowlData,taskSpecialData,exp15Add,exp20Add,exp30Add,isDelete,
				goldPassWord,goldPassWordUnlockTimes,vipLevel,vipTimeExpire,vipTimeBuy
  		}).

%-record(guildBaseInfo, {id, chairmanPlayerID, level, faction, exp, chairmanPlayerName, guildName, affiche, createTime, memberTable, applicantTable}).
% delete memberTable, applicantTable
-record(guildBaseInfo_gamedata, {id, chairmanPlayerID, level, faction, exp,
						 chairmanPlayerName, guildName, affiche, createTime}).

%-record(guildMember, {id, guildID, playerID, rank, playerName, playerLevel, playerClass, isOnline, contribute, contributeMoney, contributeTime, joinTime}).
% delete isOnline
-record(guildMember_gamedata, {id, guildID, playerID, rank, playerName, playerLevel, playerClass, 
	contribute, contributeMoney, contributeTime, joinTime}).

%%玩家已接任务
%-record(playerTask, {id, taskID, playerID, taskBase, state, aimProgressList}).
% delete taskBase, get taskBase from configure table 
-record(playerTask_gamedata, {id, taskID, playerID, state, aimProgressList}).

%%宠物的存档属性
%% -record( petProperty, {
%% 					   id, 									%%数据库ID
%% 					   data_id,							%%配置文件ID
%% 					   masterId,							%%主人ID
%% 					   level,									%%等级
%% 					   exp,									%%当前经验
%% 					   name,								%%名字
%% 					   titleId,								%%称号ID
%% 					   aiState,								%%ai状态
%% 					   showModel,						%%显示的模型，取值为PetShowModel_Model(自身模型)或者PetShowModel_ExModel(幻化模型)
%% 					   exModelId,						%%幻化模型ID
%% 					   soulLevel,							%%灵性等级
%% 					   soulRate,							%%灵性进度
%% 					   attackGrowUp,					%%攻击成长
%% 					   defGrowUp,						%%防御成长
%% 					   lifeGrowUp,						%%生命成长
%% 					   isWashGrow,					%%是否洗了成长率
%% 					   attackGrowUpWash,		%%洗出来的攻击成长
%% 					   defGrowUpWash,			%%洗出来的防御成长
%% 					   lifeGrowUpWash,				%%洗出来的生命成长
%% 					   convertRatio,					%%属性转换率
%% 					   exerciseLevel,					%%历练等级
%% 					   moneyExrciseNum,			%%铜币历练次数
%% 					   exerciseExp,						%%历练经验
%% 					   maxSkillNum,					%%最大技能数
%% 					   skills,									%%学会的技能表
%% 					   life,									%%当前生命
%% 					   propertyArray					%%角色基础属性属性，不存档，每次载入都必须从新计算属性值，数据类型为数组
%%   				}).	
% delete propertyArray
-record( petProperty_gamedata, {
					   id, 									%%数据库ID
					   data_id,							%%配置文件ID
					   masterId,							%%主人ID
					   level,									%%等级
					   exp,									%%当前经验
					   name,								%%名字
					   titleId,								%%称号ID
					   aiState,								%%ai状态
					   showModel,						%%显示的模型，取值为PetShowModel_Model(自身模型)或者PetShowModel_ExModel(幻化模型)
					   exModelId,						%%幻化模型ID
					   soulLevel,							%%灵性等级
					   soulRate,							%%灵性进度
					   attackGrowUp,					%%攻击成长
					   defGrowUp,						%%防御成长
					   lifeGrowUp,						%%生命成长
					   isWashGrow,					%%是否洗了成长率
					   attackGrowUpWash,		%%洗出来的攻击成长
					   defGrowUpWash,			%%洗出来的防御成长
					   lifeGrowUpWash,				%%洗出来的生命成长
					   convertRatio,					%%属性转换率
					   exerciseLevel,					%%历练等级
					   moneyExrciseNum,			%%铜币历练次数
					   exerciseExp,						%%历练经验
					   maxSkillNum,					%%最大技能数
					   skills,									%%学会的技能表  目前把skill cfg也存了， can improve
					   life,									%%当前生命
					   atkPowerGrowUp_Max,	%%最大攻击成长率
					   defClassGrowUp_Max,		%%最大防御成长率
					   hpGrowUp_Max,				%%最大生命成长率
                       benison_Value
  				}).	

%-record(playerSkill, {id, playerId, skillId,coolDownTime, activationSkillID1, activationSkillID2, curBindedSkillID} ).
% delete id
-record(playerSkill_gamedata, {playerId, skillId,coolDownTime, activationSkillID1, activationSkillID2, curBindedSkillID} ).
 
-record(playerSignin, {playerId, alreadyDays,lastSignTime} ).

-record(playerConvoy, {playerId, taskID, beginTime, remainTime, lowConvoyCD, highConvoyCD,
 			curConvoyType, curCarriageQuality, deadCnt, remainConvoyFreeRefreshCnt} ).

-record(playerTreasureBowl, {playerId, curUseCnt, curExp, curLevel} ).
