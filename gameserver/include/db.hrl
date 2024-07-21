-include("charDefine.hrl").
-include("pet.hrl").
-include("equip.hrl").
-include("skillDefine.hrl").
-include("objectEventDefine.hrl").
-include("mountDefine.hrl").


-define( ProcessTimeOut, 50000000).
-record( dbInfo, {name, value} ).

-record( call_back, {module, call_func} ).

-define( GlobalMainID, 1 ).
-record( globalMain, {id, 
						is_forbid_login,
						loginServerSocket, 						
						gmLevel,
						varArray, 
						dailyTargetTypeTable} ).

-record(globalSetup, {
					  id,
					  pet_ResetGUR_Item,														%%宠物重置成长率道具
					  pet_ResetGUR_ItemNum,												%%宠物重置成长率道具数量
					  pet_ResetGUR_Money,													%%宠物重置成长率需要的金钱
					  pet_Soul_Item,																%%宠物灵性强化道具
					  pet_Soul_ItemNum,														%%宠物灵性强化道具数量
					  pet_Call_CoolDownTime,												%%宠物召唤冷却时间
					  pulsc_Money_1,															%%宠物解锁第一个技能格子需要金钱
					  pulsc_Money_2,															%%宠物解锁第二个技能格子需要金钱
					  pulsc_Money_3,															%%宠物解锁第三个技能格子需要金钱
					  pulsc_SoulLevel_1,														%%宠物解锁第一个技能格子需要灵性等级
					  pulsc_SoulLevel_2,														%%宠物解锁第二个技能格子需要灵性等级
					  pulsc_SoulLevel_3,														%%宠物解锁第三个技能格子需要灵性等级
					  def_NoDamage,																%%抗性免伤
					  attack_dist_time,															%%标准攻击力间隔
					  changeProperty_item,											%%洗练石
					  changeProperty_itemNum,										%%洗练石数目
					  propertyLock_Money1,
					  propertyLock_Money2,
					  propertyLock_Money3,
					  propertyLock_Money4,
					  propertyLock_itemNum1,
					  propertyLock_itemNum2,
					  propertyLock_itemNum3,
					  propertyLock_itemNum4,
					  pk_KillTime,													%%杀戮模式时间(单位，秒）
					  killPlayerPoint,												%%杀戮模式击杀一名玩家获得杀气值
					  killPlayerPoint_Red,											%%杀气值红名
					  onlineDec_KillPlayerPoint,									%%玩家在线一分钟，减少杀气值
					  min_KillPlayerPoint,											%%玩家杀气值低于此值解除惩罚
					  max_KillPlayerPoint,											%%玩家杀气值最高
					  teamEXP,														%%队伍经验修正倍率
					  teamDrop,														%%队伍掉落修真倍率
					  base_run_speed,												%%基础移动速度
					  maxPlayerBloodPool,											%%玩家血池最大值
					  cdPlayerBloodPool,  											%%玩家血池CD时间，单位：秒
					  attackDefence,												%%防御调整值
					  attackResistance,												%%防御调整值
					  globalDropList,												%%全局掉落表
					  bagCellLockItem,											%%背包锁
					  storageCellLockItem,									%%仓库锁
					  cellLockGoldNum,											%%解锁一个格子需要的元宝数量
					  copyMap_NotActiveRatio,										%%副本在不活跃情况下的收益系数（掉落和经验）
					  convoyGold,													%%刷新护送任务所需元宝
					  commonGold,                                             %%聚宝盆普通权重
					  smallCritGold,                                          %%聚宝盆小暴击权重
					  bigCritGold,                                            %%聚宝盆小大暴击权重
					  commonGoldScale,                                        %%聚宝盆普通倍率
					  smallCritGoldScale,                                     %%聚宝盆小暴击倍率
					  bigCritGoldScale,                                        %%聚宝盆大暴击倍率
					  token_Man_id,	
					  token_Land_id,
					  token_Sky_id,                                             %%
					  max_ActiveValue,									%%玩家可获得的最大活跃值                                           %%
					  token_Max_Credit_Perday,									%%每天能获得的贡献上限
					  trumpet_Chat_Item,									%%传音使用的道具
					  bazzar_UpdateTime,									%%商城刷新时间
					  bazzar_RandomPrice_Count,				%%商城每次随机刷新的优惠物品数量
					  pierce_tiaozhen,						%%穿透调整值
					  token_Max_Honor_Perday				%%每日获得的荣誉上限

					 
}).

%% user table
%-record(user,{id,name,password}).
-define( ReadyLoginUserUnableTime, 30 ).
-define( MaxOnlineUsers, 1000 ).
-define( MaxUserPlayerCount, 3 ).
-record( readyLoginUser, {userID, unable_time, identitity, name,platId } ).
-record(socketData,{socket,userId,playerId, pid}).
-define( KickoutUserKillTime, 90 ).  %% unit: second
-record( kickoutUser, {pid, kill_time,socket, userId,playerId,identitity } ).

-record(reasureBowlData, {curUseCnt, curExp, curLevel, resetTimer} ).
-record(taskSpecialData,{randomDailyID,randDailyFinishNum,randDailygroudID,randDailyProcess,reputationtaskID,reputationprocess,gatherFinshedTime}).

%% player table  camp:职业 faction:阵营
%%worldBossLastViewTime 世界boss 上次查看时间，查看过后会被置为下次刷boss时间
-record(player,{id,name,userId, map_data_id,mapId, mapPID,x,y,
				level, camp, faction, sex, crossServerHonor, unionContribute, 
				competMoney, weekCompet, battleHonor, aura, charm, vip, 
				maxEnabledBagCells,maxEnabledStorageBagCells,storageBagPassWord,unlockTimes, 
				money, moneyBinded, gold, goldBinded, ticket, guildContribute, honor, credit,
				life, exp, lastOnlineTime, lastOfflineTime, isOnline, createTime, stateFlag, guildID,
				conBankLastFindTime, chatLastSpeakTime,
				outFightPet, mapCDInfoList,pK_Kill_Value,pK_Kill_OpenTime,pk_Kill_Punish,bloodPoolLife,gmLevel, petBloodPoolLife,
				fightingCapacity,fightingCapacityTop,platSendItemBits,gameSetMenu,rechargeAmmount,varArray,
				forbidChatFlag,protectPwd,reasureBowlData,taskSpecialData,exp15Add,exp20Add,exp30Add,
				goldPassWord,goldPassWordUnlockTimes,vipLevel,vipTimeExpire,vipTimeBuy
  		}).

-record( playerMapProperty, {id, level, lifeMax, physicAttack, magicAttack, physicDefense, magicDefense,
						hit, crit, block, tough, dodge, pierce} ).

-record( playerMapCDInfo, {map_data_id, cur_count, cd_time, sys_active_count, player_active_count} ).

%% bloodPoolLife is redundency, will delete it 
-record( playerMapDBInfo, {id, hp, x, y, mapCDInfoList,bloodPoolLife} ).

-record( playerGlobal, {id, userSocket, pid, player } ).

-record( playerBaseCfg, {id, level, camp, attack, defence, ph_def, fire_def, ice_def, elec_def, poison_def, 
						 max_life, hit, dodge, block, crit, pierce, 
						 attack_speed, tough, crit_damage_rate, block_dec_damage,
						 point} ). %% 战斗力评分，add by yueliangyou [2013-3-29]

-record(playerbattledata,{playerid,mapId,life, lifeMax, physicAttack, magicAttack, physicDefense, magicDefense,
				hit, crit, block, tough, dodge, pierce}).

%%player pet seal ahs store
-record(playerPetSealAhs, {playerId, skillIds}).


%% player shortcut
-record(shortcut, {playerID, index1ID, index2ID, index3ID, index4ID, index5ID, index6ID, index7ID, index8ID,
				   index9ID, index10ID, index11ID, index12ID}).
%%player exp
-record(playerEXP, {id,level, exp} ).

%%player recharge gift
-record(playerRechargeGift,{id,type,ammount,item0,count0,bind0,
					item1,count1,bind1,
					item2,count2,bind2,
					item3,count3,bind3,
					item4,count4,bind4,
					item5,count5,bind5}).

%%属性转换配置表
-record(attributeRegentCfg, {id,
							level,							%%等级
							def_Regent,					%%防御转换数
							physicRes_Regent,		%%物抗转换数
							fireRes_Regent,			%%火抗转换数
							iceRes_Regent,			%%冰抗转换数
							lightingRes_Regent,	%%电抗转换数
							poisonRes_Regent,		%%毒抗转换数
							hit_Regent,					%%命中转换数
							dodge_Regent,			%%闪避转换数
							block_Regent,				%%格挡转换数
							critical_Regent,			%%暴击转换数
							penetrate_Regent,		%%穿透转换数
							haste_Regent,				%%攻速转换数
							tough_Regent,			%%坚韧转换数
							stunRes_Regent,			%%昏迷抗性转换数
							fastenRes_Regent,		%%定身抵抗转换数
							forbidRes_Regent,		%%沉默抵抗转换数
							flowRes_Regent			%%减速抵抗转换数
							 }).


-record(uniqueId, {item, uid}).
-record(uniqueIdMem, {item, uid}).



-define(INT16,16/signed-little-integer).
-define(INT8,8/signed-little-integer).
-define(INT,32/signed-little-integer).
-define(INT64,64/signed-little-integer).
-define(UINT,32/unsigned-little-integer).
%%---------------------------- mount  -----------------------------------
-record(palyerMountView,{mountDataID,mountSpeed}).
%%-----------------------------------------------------------------------
%%-----------------------------player set -----------------------------
-record(playerOnHook,{playerID,playerHP,petHP, skillID1,skillID2,skillID3,skillID4,skillID5,skillID6,getThing,hpThing,other,isAutoDrug }).
%%----------------------------end------------------------------------
%%------------------------------------------Friend--------------------------------------------------------------------
%% Friend table
-record(friendDB, {id,playerID,friendType,friendID,friendName,friendSex,friendFace,friendClassType,friendLevel,friendVip,friendValue,friendOnline}).
%%------------------------------------------End-----------------------------------------------------------------------

-record(taskAim, {type, index, count, targetID, dropRate, dropCount} ).
-record(taskBase, {taskID, npc1ID, npc2ID, type, playerClass, playerLvl,playerLvMax, guildLvl, camp, prevTask, aim, bonus, isAutoRun}).

-record(signCfg, {continuousDay,item_1,num_1,item_2,num_2,item_3,num_3,item_4,num_4,spitem_1,spnum_1,spitem_2,spnum_2,spitem_3,spnum_3}).




%%世界boss，经验表
-record(partyCfg, {id,level,bossinvade_35, active_exp}).
-record(worldBossCfg, {id,number,bossid,mapid,posx,posy,starttime,overtime,incident1,incnum1,incident2,bossblood2,incnum2,
				  incident3,bossblood3,incnum3,incident4,bossblood4,incnum4,firstitem,firstnum,
				  seconditem,secondnum,thirditem,thirdnum,luckitem,lucknum,
				  refreshtime,resfreshxy1,resfreshxy2,resfreshxy3,resfreshxy4,resfreshxy5,resfreshxy6,resfreshxy7,
				  resfreshxy8,resfreshxy9,resfreshxy10,resfreshxy11,resfreshxy12,resfreshxy13,resfreshxy14,resfreshxy15,
				  resfreshxy16,resfreshxy17,resfreshxy18,resfreshxy19,resfreshxy20,resfreshxy21,resfreshxy22,resfreshxy23,
				  resfreshxy24,resfreshxy25,resfreshxy26,resfreshxy27,resfreshxy28,resfreshxy29,resfreshxy30}).
%%仙踪林战场配置
-record(battleXianzonglinCfg,{id,win_honor,lose_honor,normal_kill,kill_10,kill_50,kill_100,time_each_battle,
			win_point,flag_10s,boss_point,norma_Open_Number,min_open_Num,reborn_delay,waiting_time,fewer_Open_Minute
}).


%%玩家已接任务
-record(playerTask, {id, taskID, playerID, taskBase, state, aimProgressList}).
%%玩家随机日常，目前只有茶馆
-record(randomDailyRecord, {randomDailyID,randDailyFinishNum,randDailygroudID,randDailyProcess} ).
%%玩家已完成任务DB
-record(playerCompletedTask, {playerID, taskIDList} ).

%%------------------------------------------Item--------------------------------------------------------------------
%% itemDB table
-record(r_itemDB, {id, owner_type, owner_id, location, cell, amount, item_data_id, param1, param2, 
					binded, expiration_time } ).
%% itemCfg table
-record(r_itemCfg, {id, item_data_id, name, desc, iconPath, maxAmount, itemType, detailedType,
					isQuestItem, useType, useParam1, useParam2, useParam3, 
					useParam4, useMaxCount,level, usePlayerClass, price, quality, cdTime, 
					cdTypeID, dailyCDTypeID, dailyCDCount, bindType, usefulLife,needSaveLog, operate,needBrodcast} ).
%% bag table
-record(r_playerBag, {id, location, cell, playerID, itemDBID, enable, lockID } ).

%%------------------------------------------NpcStore--------------------------------------------------------------------
%% NpcStore table
%%
-record(r_AllStoreCfg, {id, store_id,store_type} ).

-record(r_AllStoreTable, {store_id,store_type, itemTable}).

%%普通商店
-record(r_NpcStoreItemCfg, {id, item_id, price, isbind } ).
%%令牌商店
-record(r_TokenStoreItemCfg, {id, item_id, price,type,isbind } ).



%%------------------------------------------NpcStore--------------------------------------------------------------------
%%------------------------------------------Team -----------------------------------------------------------------------
%%判断变量 用于向地图提取邀请者当前的组队信息
%% -record(judgeInfo, {hasTeam,isLeader,camp,mapId,mapdateId}).
%% 
%% %%当前队伍中的队员信息
%% -record(teamMemberInfo,{teamPlayerId,     		 %%玩家ID 作为key值
%% 						playerLineMark,   		 %%玩家在线标示
%% 						playerOffLineTimeOut,    %%玩家离线计时
%% 						playerName,      		 %%玩家名字
%% 						sex,             		 %%玩家性别
%% 						career,          		 %%玩家职业
%% 						faction}).      		 %%玩家阵营
%% 
%% %%地图进程保存的玩家队伍信息
-record(teamData,{teamID,leaderID,membersID}).
%% 
%% %%组队进程对外通信flag
%% -define(On_addMember,1).
%% -define(On_deleteMember,2).
%% -define(On_DeleteTeam,3).

%%------------------------------------------Equip--------------------------------------------------------------------

%%------------------------------------------mail--------------------------------------------------------------------
-record( mailRecord, {id, type, recvPlayerID, isOpened, tiemOut, idSender, nameSender, title, content, attachItemDBID1, attachItemDBID2, moneySend, moneyPay, mailTimerType ,mailRecTime} ).
-record( mailPlayer, {id, mailIDList, allMailCount, hasAttachMailCount } ).
%%------------------------------------------mail--------------------------------------------------------------------

%%------------------------------------------daily---------------------------------------------------------- 
-record(dailyCfg, {id, dailyID, name, type, level, time1, time2, time3,  partyguide, partytime1, partytime2, guideinterval, maxtimes, protimes, 
				   active, briefDesc, dstType, dstDataID, 
				   bonus1, bonus2, bonus3,
				   bonus4, bonus5, bonus6, bonus7, bonus8, icon, flying, walking}).

%%完成日常配置数据
-record( dailyTargetCfg, {id, type, dailyID, data_id} ).
-record( daliyTargetTypeCfg, { dailyID, dailyList }).

%%日常完成次数的存档数据
-record( dailyFinishCount, {dailyID, count }).

-record(playerDaily, { playerID, activeValue, resetTime, dailyList }).
%%------------------------------------------daily end------------------------------------------------------ 
%%------------------------------------------map--------------------------------------------------------------------
-record(mapSetting,		{id, mapID, type, name, descript,res, miniMap, mapScn, initPosX, initPosY, mapdroplist, maxPlayerCount, resetTime,
						 playerEnter_MinLevel, playerEnter_MaxLevel, playerActiveEnter_Times, playerActiveTime_Item, playerEnter_Times,	
						 dropItem1, dropItem2, dropItem3, dropItem4, dropItem5, dropItem6, dropItem7, dropItem8, 
						quitMapID, quitMapPosX, quitMapPosY, pkFlag_Camp, pkFlag_Kill, pkFlag_QieCuo, mapFaction, music,
						autoFightInCopyMapRoutPosX, autoFightInCopyMapRoutPosY } ).

-record( npcCfg, {id, npcID, name, type, animation, npcico,commonTalk, collectTime, cdTime, ncphead,shopid,title} ).

-record( monsterCfg, {id, monsterID, name,animation,mobhead,level,
					exp, attack_speed, attack, defence, max_life, ph_def, fire_def, ice_def, elec_def, poison_def,
					hit_rate, dodge_rate, block_rate, crit_rate, coma_def_rate, hold_def_rate, silent_def_rate, move_def_rate,baseRun_Speed,
					monsterCd,patrolRadius, watchRadius,followRadius,active, droplist, faction, attack_mode,skillid, modelscal} ).

%%--------------------------------buff----------------------------------
-define(Buff_Save_MinTime, 2*60*1000).
-record( objectBuffDataDB, {buff_id, casterID, isEnable, startTime, allValidTime, lastDotEffectTime, remainTriggerCount}).
-record( objectBuffDB, {id, buffList}).
%%--------------------------------buff----------------------------------


-record( objectCfg, {id, objectID, name, type, animation, icon, param1, param2, param3, param4} ).

%%------------------------------------------map--------------------------------------------------------------------
-define(PlayerBaseID,1000).
%%------------------------------------------drop--------------------------------------------------------------------

-record(dropPackageItem, {id, packageId, itemId, min, max, weight}).
-record(dropPackage, {id, maxWeight, itemList}).

-define(DROP_TYPE_ITEM, 0).
-define(DROP_TYPE_PACKAGE, 1).
-define(World_drop_list,1).

-record(dropElement,{id,dropId,dropType,dataId,probability,min,max, itemBinded}).
-record(drop,{id, dropList}).

-record(monsterDeadEXP, {id, levelDist, percent} ).

%%------------------------------------------drop--------------------------------------------------------------------


%%------------------------------------------交易行--------------------------------------------------------------------
-record(conSalesItemDB, {conSalesId, conSalesMoney, groundingTime, timeType, 
						playerId, itemDBId}).

-record(conSalesItem, {conSalesId, conSalesMoney, groundingTime, timeType, 
						playerId, playerName, 
						itemDB, itemType, itemDetType, itemQuality, itemLevel, itemOcc,
					   lockPlayerId, lockTime}).

%%------------------------------------------交易行--------------------------------------------------------------------

%%------------------------------------------工会--------------------------------------------------------------------
-record(guildLevelCfg, {id, level, maxMember, buffID, exp,viceChairmanCount,elderCount,addExp_Percent} ).
-record(guildSkillCfg, {id, level, skillGroupID, contribute} ).
-record(guildTaskCfg,  {id, task3,task4,task5} ).
-record(guildBaseInfo, {id, chairmanPlayerID, level, faction, exp, chairmanPlayerName, guildName, affiche, createTime, memberTable, applicantTable}).
-record(guildMember, {id, guildID, playerID, rank, playerName, playerLevel, playerClass, isOnline, contribute, contributeMoney, contributeTime, joinTime}).
-record(guildApplicant, {id, guildID, playerID, playerName, zhanli, level, class, joinTime}).
%%------------------------------------------工会--------------------------------------------------------------------

%% ----禁语----
-record(forbiddenCfg,{id,forbiddenId,context}).
%% ----禁语----
%-define( Tables, [%uniqueId, record_info(fields,uniqueId),
				  %player,	record_info(fields,player),
				  %playerMapDBInfo,	record_info(fields,playerMapDBInfo),
				  %user, 	record_info(fields,user),
				  %mailRecord,	record_info(fields,mailRecord),
				  %playerTask,	record_info(fields,playerTask),
				  %playerCompletedTask,	record_info(fields,playerCompletedTask),
				  %r_playerBag,	record_info(fields,r_playerBag),
				  %r_itemDB,	record_info(fields,r_itemDB),
				  %playerSkill,	record_info(fields,playerSkill), 				  
				  %playerEquipItem, record_info(fields,playerEquipItem),
				  %shortcut, record_info(fields, shortcut),
				  %conSalesItemDB, record_info(fields, conSalesItemDB),
				  %guildBaseInfo, record_info(fields, guildBaseInfo),
				  %guildMember, record_info(fields, guildMember),
				  %guildApplicant, record_info(fields, guildApplicant),
				  %petProperty, record_info(fields, petProperty),
				  %playerPetSealAhs, record_info(fields, playerPetSealAhs),
				  %playerEquipEnhanceLevel, record_info(fields, playerEquipEnhanceLevel),
				  %friendDB,record_info(fields,friendDB),
				  %objectBuffDB,record_info(fields,objectBuffDB)   %% lets erlang db to save buff info
%				 ] ).

%%---------------------------------------商城-------------------------------------------------------------

-record( bazzarItemCfg, {
					db_id,
					item_data_id, 					%%物品ID
					item_column,								%%类型，取值为（0，优惠；1，常用道具；2，宠物坐骑；3装备强化；4，元宝卡； 5，随机优惠
					gold, 								%%元宝
					binded_gold, 					%%绑定元宝
					remain_count,					%%剩余数量 （-1表示没有数量限制，只在优惠类型下有效）
					remain_time,					%%剩余时间 （-1表示没有时间限制，单位秒，只在优惠类型下有效）
					weight								%%随机权重，只在随机优惠类型下有效
  } ).

-record( bazzarItem, {
					db_id,
					item_data_id, 					%%物品ID
					item_column,								%%类型，取值为（0，优惠；1，常用道具；2，宠物坐骑；3装备强化
					gold, 								%%元宝
					binded_gold, 					%%绑定元宝
					init_count,
					remain_count,					%%剩余数量 （-1表示没有数量限制，只在优惠类型下有效）
					end_time							%%结束时间 （-1表示没有时间限制，单位秒，只在优惠类型下有效）
  } ).
%%---------------------------------------商城-------------------------------------------------------------

%%---------------------------------------镖车-------------------------------------------------------------
-record( convoyCfg, {id,convoyTypeName, convoyType,name,carriageQuality,artID,
 		awardBindGold,	awardBindMoney,awardExp,refreshMoney,refreshConsumeID,
 		refreshConsumeCnt,	refreshPercent,	taskTime,	specialHourMin1,
 		specialHourMax1,	specialAward1,	specialHourMin2,	specialHourMax2,specialAward2
   } ).
-record(convoyAwardCfg, {id, level, 
task30_exp1, task30_money1, task30_exp2, task30_money2, task30_exp3, task30_money3, task30_exp4, task30_money4,
task50_exp1, task50_money1, task50_exp2, task50_money2, task50_exp3, task50_money3, task50_exp4, task50_money4,
gather30_exp1,gather30_money1,tea_exp,tea_money,tea_item,taskGuild_userRep,taskGuild_userExp,
taskGuild_contribution,taskGuild_guildExp,item_exp,battle_exp_win,battle_exp_lose,answer_exp}).
%%---------------------------------------镖车-------------------------------------------------------------

%%---------------------------------------合成-------------------------------------------------------------
-record( compoundCfg, {id, makeItemID, mixTypeID, mixTypeName, detailTypeID, detailTypeName, mixMaterial1ID, material1Amount,
					   mixMaterial2ID, material2Amount, mixMaterial3ID, material3Amount, mixExp, mixMoney, mixHonour, mixCredit,
					   mixLevel, minAmount, maxAmount, runeID       
   } ).

-record( compoundLevelCfg, {id, level, exp
   } ).
%%---------------------------------------合成-------------------------------------------------------------

%%---------------------------------------聚宝盆相关配制表------------------------------------------------------------
-record( goldneedCfg, {id, times, goldneed, goldrate} ).
-record( goldupgradeCfg, {id, goldlevel, goldexp, givemoney} ).
%%---------------------------------------聚宝盆------------------------------------------------------------

%%---------------------------------------血池回血表------------------------------------------------------

-record(hpContainerCfg, { id, level, player_value, pet_value}).

%%---------------------------------------血池回血表------------------------------------------------------

%%---------------------------------------副本结算表------------------------------------------------------
-record(copyMapSettleAccounts, {id, map_id, name,
								exp1, money1, time1, p_exp1, p_money1,
								exp2, money2, time2, p_exp2, p_money2,
								exp3, money3, time3, p_exp3, p_money3,
								exp4, money4, time4, p_exp4, p_money4
								}).
%%---------------------------------------副本结算表------------------------------------------------------
-record(vipFun,{id,funType,level,value}).
-record(vipAddProperty,{id,index,type,per,value}).

-record(question,{id,qid,type,desc,c1,c2,c3,c4}).

-define( MemTables, [uniqueIdMem,	record_info(fields,uniqueIdMem),
					 %socketData,	record_info(fields,socketData),
					 
					 %playerGlobal,	record_info(fields,playerGlobal),
					 %globalMain,	record_info(fields,globalMain),
					%% playerInMap,	record_info(fields,playerInMap),
					%% monsterInMap,	record_info(fields,monsterInMap),
					 playerBaseCfg, record_info(fields,playerBaseCfg),
					 playerEXP,		record_info(fields,playerEXP),
					 playerRechargeGift,	record_info(fields,playerRechargeGift),
					 vipFun,	record_info(fields,vipFun),
					 vipAddProperty,	record_info(fields,vipAddProperty),
					 monsterCfg,		record_info(fields,monsterCfg),
					 npcCfg,			record_info(fields,npcCfg),
					 mapSetting,	record_info(fields,mapSetting),
					 r_itemCfg,		record_info(fields,r_itemCfg),
					 r_AllStoreCfg,		record_info(fields,r_AllStoreCfg),
					 r_NpcStoreItemCfg,		record_info(fields,r_NpcStoreItemCfg),
					 r_TokenStoreItemCfg,   record_info(fields,r_TokenStoreItemCfg),
					 guildLevelCfg,		record_info(fields,guildLevelCfg),
					 guildSkillCfg,		record_info(fields,guildSkillCfg),
					 guildTaskCfg,		record_info(fields,guildTaskCfg),
					 skillCfg,		record_info(fields,skillCfg),
					 buffCfg,		record_info(fields,buffCfg),
					 skill_effect_data,		record_info(fields,skill_effect_data),
					 objectCfg,		record_info(fields,objectCfg),
					 dailyCfg,		record_info(fields, dailyCfg),
					 mountCfg,		record_info(fields, mountCfg),
					 mountLevelCfg,		record_info(fields, mountLevelCfg),
					 mountHanceCfg,		record_info(fields, mountHanceCfg),
					 
					equipEnhance,	record_info(fields,equipEnhance),
					equipmentquality,   record_info(fields,equipmentquality),
					propertyAddValueCfgRead,   record_info(fields,propertyAddValueCfgRead),
					propertyValueSizeCfgRead,   record_info(fields,propertyValueSizeCfgRead),
					propertyWeightCfgRead,   record_info(fields,propertyWeightCfgRead),
					equipwashupmoney,		record_info(fields,equipwashupmoney),
					 equipitem,		record_info(fields,equipitem),	
					 equipTreeCell,	record_info(fields,equipTreeCell),	
					 taskBase,		record_info(fields, taskBase),
					 dropPackageItem,		record_info(fields,dropPackageItem),
					 dropElement,		record_info(fields,dropElement),
					 conSalesItem,		record_info(fields,conSalesItem),
					 petCfg,		record_info(fields,petCfg),
					 petLevelPropertyCfg,		record_info(fields,petLevelPropertyCfg),
					 petSoulUpCfg,		record_info(fields,petSoulUpCfg),
					 attackFatorCfg,		record_info(fields,attackFatorCfg),
					 monsterDeadEXP,		record_info(fields,monsterDeadEXP),
					 equipmentactivebonus_cfg,		record_info(fields,equipmentactivebonus_cfg),
					 equipMinLevelPropertyCfg,		record_info(fields,equipMinLevelPropertyCfg),


					 attributeRegentCfg, 		record_info(fields,attributeRegentCfg),
					 globalSetup, record_info(fields,globalSetup),
					 equipmentActiveItem, record_info(fields,equipmentActiveItem),
					 forbiddenCfg, record_info(fields,forbiddenCfg),
					 signCfg,record_info(fields, signCfg),
					 bazzarItemCfg, record_info(fields, bazzarItemCfg),
					 convoyCfg,record_info(fields, convoyCfg),
					 hpContainerCfg, record_info(fields, hpContainerCfg),
					 partyCfg,record_info(fields, partyCfg),
					 convoyAwardCfg,record_info(fields,convoyAwardCfg),
					 goldneedCfg,record_info(fields,goldneedCfg),
					 goldupgradeCfg,record_info(fields,goldupgradeCfg),
					 copyMapSettleAccounts,record_info(fields, copyMapSettleAccounts),
					 dailyTargetCfg, record_info(fields, dailyTargetCfg),
					 worldBossCfg, record_info(fields, worldBossCfg),
					 compoundCfg, record_info(fields, compoundCfg),
					 question, record_info(fields, question),
					 compoundLevelCfg, record_info(fields, compoundLevelCfg),
					 battleXianzonglinCfg,record_info(fields, battleXianzonglinCfg)
					] ).



	

%% --- 充值延时处理记录表 ----
-record( rechargeInfo, {orderid, platform,account,userid,playerid,ammount,flag} ).
-define( RECHARGE_INFO_FLAG_NEW,0).
-define( RECHARGE_INFO_FLAG_FAIL,1).
-define( RECHARGE_INFO_FLAG_OK,2).

%% --- 平台发放物品记录表 ----
-record( platform_sendItem, {id,levelMin,levelMax,itemList,money,money_b,gold,gold_b,exp,flag,timeBegin,timeEnd,title,content} ).
-define( PLATFORM_SENDITEM_FLAG_INVALID,0).
-define( PLATFORM_SENDITEM_FLAG_VALID,1).



