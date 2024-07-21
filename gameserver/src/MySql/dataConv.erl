-module(dataConv).

-include("db.hrl").
-include("gamedatadb.hrl").
-include("playerDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 


fillPlayerByplayerGamedata(#player_gamedata{}=P) ->
	#player{id=P#player_gamedata.id,
			name=P#player_gamedata.name,
			userId=P#player_gamedata.userId, 
			map_data_id=P#player_gamedata.map_data_id,
			mapId=P#player_gamedata.mapId, 
			mapPID=undefined,
			x=P#player_gamedata.x,
			y=P#player_gamedata.y,
			level=P#player_gamedata.level, 
			camp=P#player_gamedata.camp, 
			faction=P#player_gamedata.faction, 
			sex=P#player_gamedata.sex, 
			crossServerHonor=P#player_gamedata.crossServerHonor, 
			unionContribute=P#player_gamedata.unionContribute, 
		    competMoney=P#player_gamedata.competMoney, 
			weekCompet=P#player_gamedata.weekCompet, 
			battleHonor=P#player_gamedata.battleHonor, 
			aura=P#player_gamedata.aura, 
			charm=P#player_gamedata.charm, 
			vip=P#player_gamedata.vip, 
		    maxEnabledBagCells=P#player_gamedata.maxEnabledBagCells,
			maxEnabledStorageBagCells=P#player_gamedata.maxEnabledStorageBagCells,
			storageBagPassWord=P#player_gamedata.storageBagPassWord,
			unlockTimes=P#player_gamedata.unlockTimes, 
		    money=P#player_gamedata.money, 
			moneyBinded=P#player_gamedata.moneyBinded, 
			gold=P#player_gamedata.gold, 
			goldBinded=P#player_gamedata.goldBinded, 
			ticket=P#player_gamedata.ticket, 
			guildContribute=P#player_gamedata.guildContribute, 
			honor=P#player_gamedata.honor, 
			credit=P#player_gamedata.credit,
			life=P#player_gamedata.life,
			exp=P#player_gamedata.exp, 
			lastOnlineTime=P#player_gamedata.lastOnlineTime, 
			lastOfflineTime=P#player_gamedata.lastOfflineTime, 
			isOnline=P#player_gamedata.isOnline, 
			createTime=P#player_gamedata.createTime, 
			stateFlag=0,%%P#player_gamedata.stateFlag, 
			guildID=P#player_gamedata.guildID,
			conBankLastFindTime=P#player_gamedata.conBankLastFindTime, 
			chatLastSpeakTime=P#player_gamedata.chatLastSpeakTime,
			outFightPet=P#player_gamedata.outFightPet, 
			mapCDInfoList=P#player_gamedata.mapCDInfoList,
			pK_Kill_Value=P#player_gamedata.pK_Kill_Value,
			pK_Kill_OpenTime=P#player_gamedata.pK_Kill_OpenTime,
			pk_Kill_Punish=P#player_gamedata.pk_Kill_Punish,
			bloodPoolLife=P#player_gamedata.bloodPoolLife,
			gmLevel=P#player_gamedata.gmLevel,
			petBloodPoolLife=P#player_gamedata.petBloodPoolLife,
			fightingCapacity=P#player_gamedata.fightingCapacity,
		    fightingCapacityTop=P#player_gamedata.fightingCapacityTop,
			platSendItemBits=P#player_gamedata.platSendItemBits,
			gameSetMenu=P#player_gamedata.gameSetMenu,
			rechargeAmmount=P#player_gamedata.rechargeAmmount,
			varArray=P#player_gamedata.varArray,
			forbidChatFlag=P#player_gamedata.forbidChatFlag,
			protectPwd = P#player_gamedata.protectPwd,
			reasureBowlData = P#player_gamedata.reasureBowlData,
			taskSpecialData = P#player_gamedata.taskSpecialData,
			exp15Add = P#player_gamedata.exp15Add,
			exp20Add = P#player_gamedata.exp20Add,
			exp30Add = P#player_gamedata.exp30Add,
			goldPassWord = P#player_gamedata.goldPassWord,
			goldPassWordUnlockTimes = P#player_gamedata.goldPassWordUnlockTimes,
			vipLevel=P#player_gamedata.vipLevel, 
			vipTimeExpire=P#player_gamedata.vipTimeExpire, 
			vipTimeBuy=P#player_gamedata.vipTimeBuy 
			
			
  		}.

fillPlayerGamedataByPlayerAndOthers(#player{}=P,PlayerMountInfo,PlayerItemCDInfo,PlayerItem_DailyCountInfo) ->
  	#player_gamedata{id=P#player.id,
					 name=P#player.name,
					 userId=P#player.userId, 
					 map_data_id=P#player.map_data_id,
					 mapId=P#player.mapId,
					 x=P#player.x,
					 y=P#player.y,
				level=P#player.level,
					 camp=P#player.camp, 
					 faction=P#player.faction, 
					 sex=P#player.sex, 
					 crossServerHonor=P#player.crossServerHonor, 
					 unionContribute=P#player.unionContribute, 
				competMoney=P#player.competMoney,
					 weekCompet=P#player.weekCompet, 
					 battleHonor=P#player.battleHonor, 
					 aura=P#player.aura, 
					 charm=P#player.charm, 
					 vip=P#player.vip, 
				maxEnabledBagCells=P#player.maxEnabledBagCells,
					 maxEnabledStorageBagCells=P#player.maxEnabledStorageBagCells,
					 storageBagPassWord=P#player.storageBagPassWord,
					 unlockTimes=P#player.unlockTimes, 
				money=P#player.money, 
					 moneyBinded=P#player.moneyBinded, 
					 gold=P#player.gold, 
					 goldBinded=P#player.goldBinded, 
					 ticket=P#player.ticket, 
					 guildContribute=P#player.guildContribute, 
					 honor=P#player.honor, 
					 credit=P#player.credit,
				life=P#player.life, 
					 exp=P#player.exp, 
					 lastOnlineTime=P#player.lastOnlineTime, 
					 lastOfflineTime=P#player.lastOfflineTime, 
					 isOnline=P#player.isOnline, 
					 createTime=P#player.createTime, 
					 guildID=P#player.guildID,
				conBankLastFindTime=P#player.conBankLastFindTime, 
					 chatLastSpeakTime=P#player.chatLastSpeakTime,
				outFightPet=P#player.outFightPet, 
					 mapCDInfoList=P#player.mapCDInfoList,
					 pK_Kill_Value=P#player.pK_Kill_Value,
					 pK_Kill_OpenTime=P#player.pK_Kill_OpenTime,
					 pk_Kill_Punish=P#player.pk_Kill_Punish,
					 playerMountInfo=PlayerMountInfo,
					 playerItemCDInfo=PlayerItemCDInfo,
					 bloodPoolLife=P#player.bloodPoolLife,
					 playerItem_DailyCountInfo=PlayerItem_DailyCountInfo,
					 gmLevel=P#player.gmLevel,
					 petBloodPoolLife=P#player.petBloodPoolLife,
					 fightingCapacity=P#player.fightingCapacity,
					 fightingCapacityTop=P#player.fightingCapacityTop,
					 platSendItemBits=P#player.platSendItemBits,
					 gameSetMenu=P#player.gameSetMenu,
					 rechargeAmmount=P#player.rechargeAmmount,
					 varArray=P#player.varArray,
					 forbidChatFlag=P#player.forbidChatFlag,
					 protectPwd  = P#player.protectPwd,
					 reasureBowlData  = P#player.reasureBowlData,
					 taskSpecialData  = P#player.taskSpecialData,
					 exp15Add = P#player.exp15Add,
					 exp20Add = P#player.exp20Add,
					 exp30Add = P#player.exp30Add,
					 isDelete = 0,
					 goldPassWord = P#player.goldPassWord,
					 goldPassWordUnlockTimes = P#player.goldPassWordUnlockTimes,
					 vipLevel = P#player.vipLevel,
					 vipTimeExpire = P#player.vipTimeExpire,
					 vipTimeBuy = P#player.vipTimeBuy

	}.



fillGuildBaseInfoGamedataByGuildBaseInfo(#guildBaseInfo{}=R) ->
	#guildBaseInfo_gamedata{id=R#guildBaseInfo.id, 
							chairmanPlayerID=R#guildBaseInfo.chairmanPlayerID, 
							level=R#guildBaseInfo.level, 
							faction=R#guildBaseInfo.faction, 
							exp=R#guildBaseInfo.exp,
						chairmanPlayerName=R#guildBaseInfo.chairmanPlayerName, 
							guildName=R#guildBaseInfo.guildName, 
							affiche=R#guildBaseInfo.affiche, 
							createTime=R#guildBaseInfo.createTime							
	}.
	

fillGuildBaseInfoByGuildBaseInfoGamedata(#guildBaseInfo_gamedata{}=R) ->
	#guildBaseInfo{id=R#guildBaseInfo_gamedata.id, 
							chairmanPlayerID=R#guildBaseInfo_gamedata.chairmanPlayerID, 
							level=R#guildBaseInfo_gamedata.level, 
							faction=R#guildBaseInfo_gamedata.faction, 
							exp=R#guildBaseInfo_gamedata.exp,
						chairmanPlayerName=R#guildBaseInfo_gamedata.chairmanPlayerName, 
							guildName=R#guildBaseInfo_gamedata.guildName, 
							affiche=R#guildBaseInfo_gamedata.affiche, 
							createTime=R#guildBaseInfo_gamedata.createTime,
				   memberTable=undefined, 
				   applicantTable=undefined				  
	}.
	

fillGuildMemberGamedataByGuildMember(#guildMember{}=R) ->
	#guildMember_gamedata{id=R#guildMember.id, 
						  guildID=R#guildMember.guildID, 
						  playerID=R#guildMember.playerID, 
						  rank=R#guildMember.rank, 
						  playerName=R#guildMember.playerName, 
						  playerLevel=R#guildMember.playerLevel, 
						  playerClass=R#guildMember.playerClass, 
					contribute=R#guildMember.contribute, 
						  contributeMoney=R#guildMember.contributeMoney, 
						  contributeTime=R#guildMember.contributeTime, 
						  joinTime=R#guildMember.joinTime 
	}.
	
fillGuildMemberByGuildMemberGamedata(#guildMember_gamedata{}=R) ->
	#guildMember{id=R#guildMember_gamedata.id, 
						  guildID=R#guildMember_gamedata.guildID, 
						  playerID=R#guildMember_gamedata.playerID, 
						  rank=R#guildMember_gamedata.rank, 
						  playerName=R#guildMember_gamedata.playerName, 
						  playerLevel=R#guildMember_gamedata.playerLevel, 
						  playerClass=R#guildMember_gamedata.playerClass, 
				 		isOnline=0,	
					contribute=R#guildMember_gamedata.contribute, 
						  contributeMoney=R#guildMember_gamedata.contributeMoney, 
						  contributeTime=R#guildMember_gamedata.contributeTime, 
						  joinTime=R#guildMember_gamedata.joinTime 
	}.

fillPlayerTaskGamedataByPlayerTask(#playerTask{}=P) ->
  	#playerTask_gamedata{id=P#playerTask.id,
						 taskID=P#playerTask.taskID, 
						 playerID=P#playerTask.playerID, 
						 state=P#playerTask.state, 
						 aimProgressList=P#playerTask.aimProgressList
	}.


fillPlayerTaskByPlayerTaskGamedataAndBase(#playerTask_gamedata{}=P,TaskBase) ->
	#playerTask{id=P#playerTask_gamedata.id, 
				taskID=P#playerTask_gamedata.taskID, 
				playerID=P#playerTask_gamedata.playerID, 
				taskBase=TaskBase, 
				state=P#playerTask_gamedata.state, 
				aimProgressList=P#playerTask_gamedata.aimProgressList
	}.

fillPetPropertyGamedataByPetProperty(#petProperty{}=P) ->
	#petProperty_gamedata{id=P#petProperty.id, 
					   data_id=P#petProperty.data_id,							%%配置文件ID
					   masterId=P#petProperty.masterId,							%%主人ID
					   level=P#petProperty.level,									%%等级
					   exp=P#petProperty.exp,									%%当前经验
					   name=P#petProperty.name,								%%名字
					   titleId=P#petProperty.titleId,								%%称号ID
					   aiState=P#petProperty.aiState,								%%ai状态
					   showModel=P#petProperty.showModel,						%%显示的模型，取值为PetShowModel_Model(自身模型)或者PetShowModel_ExModel(幻化模型)
					   exModelId=P#petProperty.exModelId,						%%幻化模型ID
					   soulLevel=P#petProperty.soulLevel,							%%灵性等级
					   soulRate=P#petProperty.soulRate,							%%灵性进度
					   attackGrowUp=P#petProperty.attackGrowUp,					%%攻击成长
					   defGrowUp=P#petProperty.defGrowUp,						%%防御成长
					   lifeGrowUp=P#petProperty.lifeGrowUp,						%%生命成长
					   isWashGrow=P#petProperty.isWashGrow,					%%是否洗了成长率
					   attackGrowUpWash=P#petProperty.attackGrowUpWash,		%%洗出来的攻击成长
					   defGrowUpWash=P#petProperty.defGrowUpWash,			%%洗出来的防御成长
					   lifeGrowUpWash=P#petProperty.lifeGrowUpWash,				%%洗出来的生命成长
					   convertRatio=P#petProperty.convertRatio,					%%属性转换率
					   exerciseLevel=P#petProperty.exerciseLevel,					%%历练等级
					   moneyExrciseNum=P#petProperty.moneyExrciseNum,			%%铜币历练次数
					   exerciseExp=P#petProperty.exerciseExp,						%%历练经验
					   maxSkillNum=P#petProperty.maxSkillNum,					%%最大技能数
					   skills=P#petProperty.skills,									%%学会的技能表  目前把skill cfg也存了， can improve
					   life=P#petProperty.life,
					   atkPowerGrowUp_Max=P#petProperty.atkPowerGrowUp_Max,
					   defClassGrowUp_Max=P#petProperty.defClassGrowUp_Max,
					   hpGrowUp_Max=P#petProperty.hpGrowUp_Max,	
					   benison_Value=P#petProperty.benison_Value			   
	}.

fillPetPropertyByPetPropertyGamedata(#petProperty_gamedata{}=P) ->
	#petProperty{id=P#petProperty_gamedata.id, 
					   data_id=P#petProperty_gamedata.data_id,							%%配置文件ID
					   masterId=P#petProperty_gamedata.masterId,							%%主人ID
					   level=P#petProperty_gamedata.level,									%%等级
					   exp=P#petProperty_gamedata.exp,									%%当前经验
					   name=P#petProperty_gamedata.name,								%%名字
					   titleId=P#petProperty_gamedata.titleId,								%%称号ID
					   aiState=P#petProperty_gamedata.aiState,								%%ai状态
					   showModel=P#petProperty_gamedata.showModel,						%%显示的模型，取值为PetShowModel_Model(自身模型)或者PetShowModel_ExModel(幻化模型)
					   exModelId=P#petProperty_gamedata.exModelId,						%%幻化模型ID
					   soulLevel=P#petProperty_gamedata.soulLevel,							%%灵性等级
					   soulRate=P#petProperty_gamedata.soulRate,							%%灵性进度
					   attackGrowUp=P#petProperty_gamedata.attackGrowUp,					%%攻击成长
					   defGrowUp=P#petProperty_gamedata.defGrowUp,						%%防御成长
					   lifeGrowUp=P#petProperty_gamedata.lifeGrowUp,						%%生命成长
					   isWashGrow=P#petProperty_gamedata.isWashGrow,					%%是否洗了成长率
					   attackGrowUpWash=P#petProperty_gamedata.attackGrowUpWash,		%%洗出来的攻击成长
					   defGrowUpWash=P#petProperty_gamedata.defGrowUpWash,			%%洗出来的防御成长
					   lifeGrowUpWash=P#petProperty_gamedata.lifeGrowUpWash,				%%洗出来的生命成长
					   convertRatio=P#petProperty_gamedata.convertRatio,					%%属性转换率
					   exerciseLevel=P#petProperty_gamedata.exerciseLevel,					%%历练等级
					   moneyExrciseNum=P#petProperty_gamedata.moneyExrciseNum,			%%铜币历练次数
					   exerciseExp=P#petProperty_gamedata.exerciseExp,						%%历练经验
					   maxSkillNum=P#petProperty_gamedata.maxSkillNum,					%%最大技能数
					   skills=P#petProperty_gamedata.skills,									%%学会的技能表  目前把skill cfg也存了， can improve
					   life=P#petProperty_gamedata.life,
				       atkPowerGrowUp_Max=P#petProperty_gamedata.atkPowerGrowUp_Max,
					   defClassGrowUp_Max=P#petProperty_gamedata.defClassGrowUp_Max,
					   hpGrowUp_Max=P#petProperty_gamedata.hpGrowUp_Max,
				       benison_Value=P#petProperty_gamedata.benison_Value,	
				 	propertyArray=[]									
	}.
