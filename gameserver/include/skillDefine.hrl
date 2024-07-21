%%------------------------------------------Skill--------------------------------------------------------------------

%%// 技能触发类型
-define( SkillTrigger_Passive, 0 ).	%%,	//	被动
-define( SkillTrigger_Init, 1 ). %%,	//	主动

%%// 技能使用目标类型

-define( SkillUseTarget_Enemy, 0). %%	敌人（适用于玩家，宠物，怪物）
-define( SkillUseTarget_Self, 1). %%,自己（适用于玩家，宠物，怪物）
-define( SkillUseTarget_Friend, 2). %%友方（适用于玩家，怪物（怪物只适用于群体技能）
-define( SkillUseTarget_SelfPosEnemy, 3). %%自身位置的敌人 （适用于玩家, 怪物，必须是群攻技能）

-define( SkillUseTarget_Master, 4). %%主人 （只适用于宠物）
-define( SkillUseTarget_Pet, 5). %%宠物（只适用于玩家）

-define( SkillUseTarget_Team, 6). %%队伍（适用于玩家，宠物）
-define( SkillUseTarget_Guild, 7). %%帮会（只适用于玩家）


%%// 技能击中特殊判断

-define( SkillHitSpec_Normal, 0 ). %%,	//	攻击做正常判定
-define( SkillHitSpec_Not_HitTest, 1 ). %%,	//	不做命中判定
-define( SkillHitSpec_Not_DodgeTest, 2 ). %%,	//	不做闪避判定
-define( SkillHitSpec_Not_Block, 4 ). %%,	//	不做格挡判定
-define( SkillHitSpec_Not_Crit, 8 ). %%,	//	不做暴击判定

%%// 技能特殊情况使用
-define( SkillUseSpec_Normal, 0 ). %%,	//	不做特殊使用判断
-define( SkillUseSpec_Comal, 1 ). %%,	//	昏迷时可以使用
-define( SkillUseSpec_Silent, 2 ). %%,	//	沉默时可以使用
-define( SkillUseSpec_Dead, 4 ). %%,	//	死亡后使用
-define( SkillUseSpec_xxx, 8 ). %%,	//	无视免疫攻击

%%伤害类型0所有，1物理， 2火，4冰，8电，16毒
-define( DamageType_All, 0 ).
-define( DamageType_Phy, 1 ).
-define( DamageType_Fire, 2 ).
-define( DamageType_Ice, 4 ).
-define( DamageType_Elec, 8 ).
-define( DamageType_Poison, 16 ).

%% 技能所属职业
-define(SkillClass_Fighter,	0).		%%战士
-define(SkillClass_Shooter, 1).		%%弓手
-define(SkillClass_Master,	2).		%%法师
-define(SkillClass_Pastor,	3).		%%牧师
-define(SkillClass_Monster,	4).	%%怪物
-define(SkillClass_Pet,		5).		%%	宠物
-define(SkillClass_Guild,	6).		%%	帮派
-define(SkillClass_Item,		7).		%%物品
-define(SkillClass_System,	8).		%%系统
%%技能学习结果
-define( StudyResult_Success, 0).			%%学习成功
-define( StudyResult_PlayerLvl, -1).		%%玩家级别不够
-define( StudyResult_Money, -2).			%%玩家钱不够
-define( StudyResult_NoItem, -3).			%%没有所需物品
-define( StudyResult_AlreadyStuey, -4).		%%以学过该技能
-define( StudyResult_NoSkill, -5).			%%技能不存在
-define( StudyResult_OPFrequent, -6).		%%操作频繁
-define( StudyResult_Credit, -7).		%%声望不够
-define( StudyResult_NoGuild, -8).		%%没有加入仙盟
-define( StudyResult_GuildLevel, -9).		%%仙盟等级不够

%%技能激活结果
-define( Skill_Active_Success, 0 ).			%%激活成功
-define( Skill_Active_TrunkNo_Study, -1 ).	%%主技能没有学习
-define( Skill_Active_NotBelong_Trunk, -2 ).%%分支技能不属于该主干
-define( Skill_Active_Unknown, -3).			%%未知 
-define( Skill_Active_NotItem, -4).			%%没有激活分支技能的道具

%%buff类型
-define(Buff_Type_BUFF, 0).			%%增益
-define(Buff_Type_DEBUFF, 1).		%%减益

%%技能效果目标类型
-define(Effect_Target_Type_Target, 0). %%目标
-define(Effect_Target_Type_Self, 1).		%%自己

%%buff效果类型
%%改变属性
-define(Buff_Effect_Type_Change_Attribute, 1).
%%昏迷：不能移动，不能攻击，不能使用任何主动技能，不能格挡，闪避，
%%不能使用任何物品，除了有特殊定义在昏迷状态下可用的技能和物品除外，
%%昏迷时被动技能，触发技能，仍然有效
-define(Buff_Effect_Type_Stun, 2).
%%沉默：不能攻击，不能使用任何主动技能，被动技能，触发技能仍然有效
-define(Buff_Effect_Type_Forbid, 3).
%%定身：不能移动，不能格挡，闪避
-define(Buff_Effect_Type_Fasten, 4).
%%无敌：不能被攻击
-define(Buff_Effect_Type_Immortal, 5).	
%%喝药加血
-define(Buff_Effect_Type_AddLifeByItem, 6).
%%技能加血
-define(Buff_Effect_Type_AddLifeBySkill, 7).
%%血池加血
-define(Buff_Effect_Type_AddLifeByBloodPool, 8).
%%pk保护buff
-define(Buff_Effect_Type_PKProcted, 9).
%%buff效果数量
-define(Buff_Effect_Type_Num, 10).

%%buff改变属性的值类型
-define(BuffChangeAttribute_Type_Fix, 0).  %%增加固定值
-define(BuffChangeAttribute_Type_Per, 1).	%%增加百分比


-record(attack_value,{id,level,life, lifeMax, physicAttack, magicAttack, physicDefense, magicDefense,
				hit, crit, block, tough, dodge, pierce}).


-record(skill_effect_data, {id, skill_id, skillName, effect_type, effect_target_type, param1, param2, param3, param4 } ).
-record(skill_effect, { skill_id, effect_list } ).

-record(buffCfg, {id, buff_id, name, buff_group, level, type, 
					bUFF_Show_Front, bUFF_Show_Front_Pos, bUFF_Show_Back, bUFF_Show_Back_Pos,
					canBeenVisable, bUFF_ICON,
					bUFF_Rate,bUFF_AllTime,bUFF_SingleTime,
				  	effect_Type, effect_Type_Param1, effect_Type_Param2, 
					bUFF_HowManyTimes, triggerType,triggerParam,
					damageType,damagePercent,damageFixValue,
					propertyType1, propertyValue1,propertyFixOrPercent1,
				  	propertyType2, propertyValue2,propertyFixOrPercent2, 
					propertyType3, propertyValue3,propertyFixOrPercent3,
					propertyType4, propertyValue4,propertyFixOrPercent4,
					propertyType5, propertyValue5,propertyFixOrPercent5,
				    buff_deathdel, buffdescribe} ).

-record(skillCfg, {id, skill_id, name, skillClass, studylevel, castMoney, castCredit, useItemID, 
					sealAhsItem, sealAhsIten_Num, petskill_del, skill_group, level,branchof, skillIcon, skillAct, effectGroup, effectID,
					flyType, rangerSquare, skillRangeSquare,skillCoolDown, skillCoolDownGroup, skill_GlobeCoolDown,
					skillTriggerType, damageType, damagePercent,damageFixValue,effectTimes, 
					creatAOE, aoeDelay, aoeEffect, aoeBind, skillUseTargetType, 
					skill_Hate, hit_Spec, use_Spec, skill_school, skillAttackType, maxEffectCount, 
					shakeType, shakeRate, skillInfo,point,  attack_Start, attack_Succeed, hit_Sound} ). %% 增加战斗力评分point add by yueliangyou[2013-3-29]

-record(playerSkill, {id, playerId, skillId,coolDownTime, activationSkillID1, activationSkillID2, curBindedSkillID} ).


