%%------------------------------------宠物-------------------------------------------------------
%%宠物配置
-record( petCfg,{
								id, 								%%
								petID, 							%%宠物ID
								petName,					%%宠物名称
								petModelID,				%%宠物模型
								petHeadIco,				%%宠物头像小图标ID
								baseAtk_Delay,			%%攻速
								baseSkill_ID,				%%基础攻击技能ID
								atkPower_GUR1,			%%攻击成长初始最小值
								atkPower_GUR2,			%%攻击成长初始最大值
								atkPower_MaxGUR1,	%%攻击成长最大值1
								atkPower_MaxGUR2,  %%攻击成长最大值2
								defClass_GUR1,			%%防御成长初始最小值
								defClass_GUR2,			%%防御成长初始最大值
								defClass_MaxGUR1,	%%防御成长最大值1
								defClass_MaxGUR2,	%%防御成长最大值2
								hp_GUR1,					%%生命成长初始最小值
								hp_GUR2,					%%生命成长初始最大值
								hp_MaxGUR1,				%%生命成长最大值1
								hp_MaxGUR2,				%%生命成长最大值2
								petBorn_Skill1,			%%出生技能1
								petBorn_Skill2,			%%出生技能2
								petBorn_Skill3,			%%出生技能3
								petBorn_Skill4,			%%出生技能4
								petBorn_Skill5,			%%出生技能5
								petBorn_Skill6,			%%出生技能6
								hpSecRate_Plus,			%%宠物生命秒回比倾向加值
								hPSteal_Plus,				%%宠物击中回血倾向加值
								physicRes_Multi,			%%宠物物抗倾向乘数
								fireRes_Multi,				%%宠物火抗倾向乘数
								iceRes_Multi,				%%宠物冰抗倾向乘数
								lightingRes_Multi,		%%宠物电抗倾向乘数
								poisonRes_Multi,		%%宠物毒抗倾向乘数
								hitRate_Plus,				%%宠物命中率加值
								dodgeRate_Plus,		%%宠物闪避倾向加值
								blockRate_Plus,			%%宠物格挡率倾向加值
								criticalRate_Plus,		%%宠物 暴击率倾向加值
								penetrateRate_Plus,	%%宠物穿透率加值
								hasteRate_Plus,			%%宠物加速率倾向加值
								toughRate_Plus,			%%宠物坚韧率倾向加值
								criticalFactor_Plus,		%%宠物暴击伤害系数加值
								blockFactor_Plus,		%%宠物格挡减伤洗漱加值
								atkPhyFactor_Plus,		%%宠物物理伤害乘数加值
								atkFireFactor_Plus,		%%宠物火伤害乘数加值
								atkIceFactor_Plus,		%%宠物冰伤害乘数加值
								atkLigFactor_Plus,		%%宠物电伤害乘数加值
								atkPoiFactor_Plus,		%%宠物毒伤害乘数加值
								defPhyFactor_Plus,		%%宠物防物理伤害乘数加值
								defFireFactor_Plus,		%%宠物防火伤害乘数加值
								defIceFactor_Plus,		%%宠物防冰伤害乘数加值
								defLigFactor_Plus,		%%宠物防电伤害乘数加值
								defPoiFactor_Plus,		%%宠物防毒伤害乘数加值
								castHealFactor_Plus,	%%宠物治疗效果乘数加值
								tagHealFactor_Plus,	%%宠物受治疗效果乘数加值
								stunResRate_Plus,		%%宠物昏迷抵抗率加值
								fastenResRate_Plus,	%%宠物定身抵抗率加值
								forbidResRate_Plus,	%%宠物沉默抵抗率加值
								slowResRate_Plus,		%%宠物减速抵抗率加值
								runSpeed_Multi,			%%宠物移动速度乘数
								minGUR,						%%成长率随机最小值
								maxGUR,						%%成长率随机最大值
								pointFactor			%%战斗力评分系数 add by yueliangyou[2013-3-30]
				} ).
%%宠物每个等级的基础属性配置
-record( petLevelPropertyCfg, {id, 	%%数据库ID
								level, 							%%等级
								exp,								%%经验
								fuseNeedMoney,		%%宠物融合需要金钱
								baseAtk_Power,  		%%基础攻击
								baseDef_Class, 			%%基础防御
								baseMax_HP, 				%%基础生命上限
								basePhysic_Res, 			%%基础物抗
								baseFire_Res,				%%基础火抗
								baseIce_Res, 				%%基础冰抗
								baseLighting_Res, 		%%基础电抗
								basePoison_Res, 		%%基础毒抗
								baseHit_Rate, 				%%基础命中率
								baseDodge_Rate, 		%%基础闪避率
								baseBlock_Rate, 			%%基础格挡率
								baseCritical_Rate, 		%%基础暴击率
								basePenetrate_Rate,	%%基础穿透率
								baseHaste_Rate, 		%%基础攻速率
								baseTough_Rate, 		%%基础坚韧率
								baseCritical_Factor, 	%%基础暴击伤害系数
								baseBlock_Factor, 		%%基础格挡减伤系数
								baseStunRes_Rate, 	%%基础昏迷抵抗率
								baseFastenRes_Rate, 	%%基础定身抵抗率
								baseForbidRes_Rate, 	%%基础沉默抵抗率
								baseSlowRes_Rate,	%%基础减速抵抗率
								basePoint		%%战斗力评分 add by yueliangyou[2013-3-30]
				}).

%%宠物灵性强化配置表
-record( petSoulUpCfg, {
						id,									%%数据库ID
						soul_Level,						%%灵性等级
						soule_Step,						%%强化阶段
						soul_Rate,						%%成功几率
						soul_Money,					%%游戏币
						soulAtkPower_Multi,
						soulDefClass_Multi,
						soulMaxHp_Multi,
						soul_pointFactor	,		%%战斗力评分 add by yueliangyou[2013-3-30]
						benison_Max
				}).

%%宠物的存档属性
-record( petProperty, {
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
					   skills,									%%学会的技能表
					   life,									%%当前生命
					   atkPowerGrowUp_Max,	%%最大攻击成长率
					   defClassGrowUp_Max,		%%最大防御成长率
					   hpGrowUp_Max,				%%最大生命成长率
					   benison_Value,				%%当前祝福值
					   propertyArray					%%角色基础属性属性，不存档，每次载入都必须从新计算属性值，数据类型为数组
  				}).	

-record(petSkill, { skillId, coolDownTime} ). 

%%宠物出战返回
-define(Pet_OutFight_Result_Succ, 1).			%%出战成功
-define(Pet_OutFight_Result_Failed_NotPet, -1).		%%出战失败，没有找到宠物
-define(Pet_OutFight_Result_Failed_AlreadyOutFight, -2). %%出战失败，宠物已经出战
-define(Pet_OutFight_Result_Failed_CoolDown, -3). %%出战失败，冷却中
-define(Pet_OutFight_Result_Failed_UnKnow, -4). %%出战失败，未知错误

%%宠物休息返回
-define(Pet_TakeRest_Result_Succ, 1).			%%收回成功
-define(Pet_TakeRest_Result_Failed_NotPet, -1). %%收回失败没有找到宠物
-define(Pet_TakeRest_Result_Failed_PetNotOutFight, -2). %%宠物没有出战
-define(Pet_TakeRest_Result_Failed_CoolDown, -3). %%冷却中

%%宠物放生成功
-define(PetFreeCaptiveAnimals_Result_Succ, 0).
%%宠物放生失败，没有找到宠物
-define(PetFreeCaptiveAnimals_Result_Failed_Not, -1).
%%宠物放生失败，宠物正在出战状态
-define(PetFreeCaptiveAnimals_Result_Failed_OutFight, -2).

%%宠物显示的外形
-define(PetShowModel_Model, 0). %%自身模型
-define(PetShowModel_ExModel,1). %%幻化的模型

%%宠物幻化返回
-define(PetCompoundModel_Result_Succ, 0).		%%幻化成功
-define(PetCompoundModel_Result_Failed_Not, -1). %%幻化失败，没有找到宠物
-define(PetCompoundModel_Result_Failed_NotExModel, -2). %%幻化失败，宠物没有幻化后的模型

%%宠物刷新成长率返回
-define(PetWashGrowUpValue_Result_Succ, 0).		%%刷新成功
-define(PetWashGrowUpValue_Result_Failed_NotPet, -1).	%%刷新失败,没有找到宠物信息
-define(PetWashGrowUpValue_Result_Failed_Money, -2).	%%刷新失败,金钱不足
-define(PetWashGrowUpValue_Result_Failed_Item, -3).	%%刷新失败, 道具不足

%%是否洗了成长率
-define(PetWashGrowUpValue_YES, 1).  %%洗过成长率
-define(PetWashGrowUpValue_NO, 0).  %%没有洗过成长率

%%替换成长率返回
-define(PetReplaceGrowUpValue_Succ, 0). %%替换成长率成功
-define(PetReplaceGrowUpValue_Not, -1). %%替换成长率失败，没有找到宠物
-define(PetReplaceGrowUpValue_NotWash, -2). %%替换成长率失败，没有洗过成长率

%%灵性最大等级
-define(PetIntensifySoul_Max_Level, 20).
%%宠物灵性强化返回
-define(PetIntensifySoul_Succ, 1). %%宠物灵性强化成功，强化进度+1
-define(PetIntensifySoul_BenisonSucc, 2). %%宠物灵性通过祝福值强化成功
-define(PetIntensifySoul_Failed, 0). %%宠物灵性强化失败，强化进度归0
-define(PetIntensifySoul_Failed_Not, -1). %%宠物灵性强化失败，没有找到宠物
-define(PetIntensifySoul_Failed_Money, -2). %%宠物灵性强化失败，金钱不足
-define(PetIntensifySoul_Failed_Item, -3). %%宠物灵性强化失败，道具不足
-define(PetIntensifySoul_Failed_LevelMax, -4). %%宠物灵性强化失败，已经达到最大等级

%%宠物融合返回
-define(PetFuse_Succ, 0). %%宠物融合成功
-define(PetFuse_Failed_NotSrc, -1). %%宠物融合失败，源宠物不存在
-define(PetFuse_Failed_NotDest, -2). %%宠物融合失败，目标宠物不存在
-define(PetFuse_Failed_SrcEqualDest, -3). %%宠物融合失败，源宠物与目标宠物不能一样
-define(PetFuse_Failed_OutFight, -4). %%宠物融合失败，宠物正在出战


%%宠物AI状态
-define(Pet_AI_State_Follow, 1).						%%跟随
-define(Pet_AI_State_PassiveFight, 2).				%%被动战斗
-define(Pet_AI_State_InitiativeFight, 3).			%%主动战斗

%%宠物默认最大技能数量
-define(Pet_SkillDefaultMax_Num, 3).
%%宠物最大技能数量
-define(Pet_MaxSkill_Num,	6).
%%宠物学习技能返回
-define(Pet_LearnSkill_Succ,		1).					%%学习技能成功
-define(Pet_LevelUpSkill_Succ,	2).					%%技能升级成功
-define(Pet_LearnSkill_Failed_NotPet,	-1).		%%学习技能失败，没有找到宠物
-define(Pet_LearnSkill_Failed_AlreadyLearn, -2). %%学习技能失败，技能已经学习
-define(Pet_LearnSkill_Failed_NotFindSkill, -3).	%%学习技能失败，没有找到技能配置
-define(Pet_LearnSkill_Failed_LevelNotEnough, -4). %%学习技能失败，本宠物等级不足
-define(Pet_LearnSkill_Failed_MoneyNotEnough, -5).	%%学习技能失败，金钱不足
-define(Pet_LearnSkill_Failed_ItemNotEnough, -6).	%%学习技能失败，没有技能书
-define(Pet_LearnSkill_Failed_NotSpace, -7).		%%学习技能失败，没有剩余的技能栏
-define(Pet_LearnSkill_Failed_NotLearnFrontSkill, -8).	%%学习技能失败，没有学习前置技能
-define(Pet_LearnSkill_Failed_NotPetClass, -9).		%%学习技能失败，不是宠物技能
-define(Pet_LearnSkill_Failed_AlreadyLearnMax, -10).	%%宠物技能学习失败，已经学习了更高等级的技能

%%删除技能返回
-define(Pet_DelSkill_Succ,  1).		%%删除技能成功
-define(Pet_DelSkill_Failed_NotPet,  -1). %%删除技能失败，没有找到宠物
-define(Pey_DelSkill_Failed_NotFindSkill, -2). %%删除技能失败，没有找到技能
-define(Pet_DelSkill_Failed_CanNotDel, -3). %%删除技能失败，技能不能删除

%%宠物技能仓库最大数量
-define(Pet_SealAhsStore_Max_Count,		20).
%%封印宠物技能返回
-define(PetSkill_SealAhs_Succ, 1).		%%封印成功
-define(PetSkill_SealAhs_Failed_StoreFull, -1).  %%封印失败，仓库已满
-define(PetSkill_SealAhs_Failed_NotPet,		-2).	%%封印失败，没有找到宠物
-define(PetSkill_SealAhs_Failed_NotFindSkill,	-3).	%%封印失败，没有找到技能
-define(PetSkill_SealAhs_Failed_NotItem,  -4).		%%封印失败，道具不足
-define(PetSkill_SealAhs_Failed_CanNot,  -5).		%%封印失败，技能不能封印

%%宠物解锁技能栏返回
-define(Pet_UnLockSkillCell_Succ, 1).			%%解锁技能栏成功
-define(Pet_UnLockSkillCell_Failed_NotPet, -1).		%%解锁技能栏失败，没有找到宠物
-define(Pet_UnLockSkillCell_Failed_CellFull, -2).		%%解锁技能栏失败，宠物技能格子已满
-define(Pet_UnLockSkillCell_Failed_MoneyNot, -3).	%%解锁技能栏失败，金钱不足
-define(Pet_UnLockSkillCell_Failed_UnKnow,  -4).		%%解锁技能栏失败，未知错误
-define(Pet_UnLockSkillCell_Failed_SoulLevelNot,  -5).		%%解锁技能栏失败，灵性等级不足

%%宠物学习封印技能返回
-define(Pet_LearnSealAhsSkill_Succ,  1).		%%学习成功
-define(Pet_LearnSealAhsSkill_Failed_NotCfg, -1).  %%没有找到技能配置
-define(Pet_LearnSealAhsSkill_Failed_NotPet, -2).  %%没有找到宠物
-define(Pet_LearnSealAhsSkill_Failed_NotInStore, -3). %%仓库中没有此技能
-define(Pet_LearnSealAhsSkill_Failed_AlreadyLearn, -4). %%技能已经学习
-define(Pet_LearnSealAhsSkill_Failed_NotPetClass, -5).  %%不是宠物技能
-define(Pet_LearnSealAhsSkill_Failed_LevelNotEnough, -6). %%宠物等级不足
-define(Pet_LearnSealAhsSkill_Failed_NotSpace, -7). %%宠物技能栏已满
-define(Pet_LearnSealAhsSkill_Failed_NotLearnFrontSkill, -8). %%没有学习前置技能
-define(Pet_LearnSealAhsSkill_AlreadyLearnMax, -9).	%%宠物技能学习失败，已经学习了更高等级的技能

%%宠物改名返回
-define(Pet_ChangeName_Succ, 1). %%改名成功
-define(Pet_ChangeName_Failed_Not, -1).	%%宠物改名失败，没有找到宠物
-define(Pet_ChangeName_Failed_NameError, -2).	%%宠物改名失败，名字错误


%%------------------------------------宠物-------------------------------------------------------
