%%------------------------------------------Equip--------------------------------------------------------------------
-record(equipTreeCell, {id, cellIndex, prevCell } ).

%%玩家装备信息，需要保存的
%%附加属性
-record(propertyTypeValue, {type,fixOrPercent, value} ).
-record(playerEquipItem,{id, playerId, equipid,type, quality, isEquiped,  propertyTypeValueArray}).

%%玩家装备强化等级，需初始化，需保存
-record(playerEquipLevelInfo, {level, progress, blessValue} ).
-record(playerEquipEnhanceLevel,{ playerId, ring, weapon,cap, shoulder, pants, hand, coat, belt, shoe, accessories, wing, fashion} ).

%%---------------------------------------------------玩家装备品质提升时，附加属性的改变
%% 增加战斗力评分point 字段 add by yueliangyou[2013-3-29]
-record( propertyAddValueCfgRead, {id,quality_Level, propertyType, relativeValue,absoluteValue,fixOrPercent,point} ).%%读取格式，

-record( propertyAddValueExtern, {propertyType,fixOrPercent,relativeValue,absoluteValue,pointFactor } ).
-record( propertyAddValueCfg, {quality_Level, propertyArray} ).%%保存格式，

%%------------------------------------------------------附加属性的取值范围
%% 增加战斗力评分point 字段 add by yueliangyou[2013-3-29]
-record( propertyValueSizeCfgRead, {id,equip_Level, propertyType, minValue, maxValue, fixOrPercent,mindivisor,point} ).%%读取格式，

-record( valueSizeExtern, {propertyType,fixOrPercent,minValue, maxValue,mindivisor,point} ).
-record( propertyValueSizeCfg, {equip_Level, propertyArray } ).%%保存格式，

%%------------------------------------------------------附加属性的出现的几率
-record( propertyWeightCfgRead, {id,equip_Type, propertyType, value, fixOrPercent} ).%%读取格式，

-record( weightExtern, {propertyType,fixOrPercent,value} ).
-record( propertyWeightCfg, {equip_Type, propertyArray, ratetotal} ).%%保存格式，


%%------------------------------------------------------玩家装备激活和品质提升，需要的材料及数量
-record(equipmentActiveItem,{id,quality_ID,equipName,
					whiteID_1,whiteNum_1,whiteID_2,whiteNum_2,whiteID_3,whiteNum_3,whiteID_4,whiteNum_4,
					greenID_1,greenNum_1,greenID_2,greenNum_2,greenID_3,greenNum_3,greenID_4,greenNum_4,
					blueID_1,blueNum_1,blueID_2,blueNum_2,blueID_3,blueNum_3,blueID_4,blueNum_4,
					purID_1,purNum_1,purID_2,purNum_2,purID_3,purNum_3,purID_4,purNum_4,
					orangeID_1,orangeNum_1,orangeID_2,orangeNum_2,orangeID_3,orangeNum_3,orangeID_4,orangeNum_4,
					redID_1,redNum_1,redID_2,redNum_2,redID_3,redNum_3,redID_4,redNum_4}).%%读取格式，

%%保存格式
-record(itemNeed,{itemID_1,itemNum_1,itemID_2,itemNum_2,itemID_3,itemNum_3,itemID_4,itemNum_4}).
-record(equipmentActiveItemNeed,{ quality_ID, itemNeedArray}).%%保存格式，这里保存的是数组嵌套数组

%%装备基础属性
-record(equipitem, {	
					id,
					equipid, 								%%装备id
					type, 									%%装备类型
					camp, 									%%职业限定
					name, 									%%名字
					icon,									%%显示图标
					atk_Delay, 								%%攻击间隔
					baseAtk_Power, 							%%基础攻击
					baseDef_Class,  						%%基础防御
					baseMax_HP, 							%%基础血量
					baseALL_Res, 							%%基础全抗性
					basePhysic_Res, 						%%基础物理抗性
					baseFire_Res,  							%%基础火抗
					baseIce_Res, 							%%基础冰抗
					baseLighting_Res, 						%%基础电抗
					basePoison_Res,		 					%%基础毒抗
					baseHit_Value, 							%%基础命中值
					baseDodge_Value, 						%%基础闪避值
					baseBlock_Value, 						%%基础格挡值
					baseCritical_Value,  					%%基础暴击值
					basePenetrate_Value, 					%%基础穿透值
					baseHaste_Value, 						%%基础加速值
					baseTough_Value,  						%%基础坚韧值
					baseUNRes_Value, 						%%基础全异常抵抗值
					baseStunRes_Value, 						%%基础昏迷抵抗值
					baseFastenRes_Value, 					%%基础定身抵抗值
					baseForbidRes_Value, 					%%基础沉默抵抗值
					baseSlowRes_Value, 						%%基础减速抵抗值
					basePoint, 						%%基础战斗力评分 add by yueliangyou[2013-3-29]
					cellInTree,  							%%在装备树中所在格子ID
					activeLevel,  							%%激活玩家等级,即使用等级
					activeCredit, 							%%激活声望值
					activeHonour,  							%%激活荣誉值
					activePreEquipID,  						%%激活前置装备ID
					useSpriteID								%%对于的美术资源ID，即 使用哪套动画
					} ).

%%玩家装备强化及其加成，
-record(equipEnhance,{
					id,
					level, 									%%装备强化等级
					enhanceCost,							%%强化所需游戏币
					enhanceItem,							%%强化石
					itemMunber,								%%强化石数量
					enhanceRate,  							%%单次强化成功率
					times,  								%%需要强化的次数
					extra_times,							%%保底次数，也就是祝福值，
					atkPower_Factor,  						%%提升的基础攻击力
					defClass_Factor,  						%%提升的基础防御力
					maxHP_Factor,  							%%提升的基础生命
					aLLRes_Factor,  						%%提升的基础全抗性
					physicRes_Factor, 						%%提升的基础物理抗性
					fireRes_Factor,  						%%提升的基础火炕
					iceRes_Factor,	 						%%提升的基础冰抗
					lightingRes_Factor,  					%%提升的基础电抗
					poisonRes_Factor,  						%%提升的基础毒抗
					hitValue_Factor,  						%%提升的基础命中
					dodgeValue_Factor,  					%%提升的基础闪避
					blockValue_Factor, 						%%提升的基础格挡
					criticalValue_Factor,  					%%提升的基础暴击
					penetrateValue_Factor,  				%%提升的基础穿透
					hasteValue_Factor,  					%%提升的基础加速值
					toughValue_Factor,  					%%提升的基础坚韧
					unResValue_Factor,  					%%提升的基础全异常抵抗
					stunResValue_Factor, 					%%提升的基础昏迷抵抗值
					fastenResValue_Factor,  				%%提升的基础定身抵抗值
					forbidResValue_Factor,  				%%提升的基础沉默抵抗值
					slowResValue_Factor, 					%%提升的基础减速抵抗值
					point_Factor 					%%战斗力评分系数 add by yueliangyou[2013-3-29]
					} ).

%%玩家装备品质提升，基础属性加成，
-record(equipmentquality,{
					id,
					qualityLevel,							%%装备品质等级
					credit_Factor,							%%升到此品阶所消耗的声望值
					honor_Factor,							%%升到此品阶所消耗的荣誉值
					atkPower_Factor,  						%%提升的基础攻击力
					defClass_Factor,  						%%提升的基础防御力
					maxHP_Factor,  							%%提升的基础生命
					aLLRes_Factor,  						%%提升的基础全抗性
					physicRes_Factor, 						%%提升的基础物理抗性
					fireRes_Factor,  						%%提升的基础火炕
					iceRes_Factor,	 						%%提升的基础冰抗
					lightingRes_Factor,  					%%提升的基础电抗
					poisonRes_Factor,  						%%提升的基础毒抗
					hitValue_Factor,  						%%提升的基础命中
					dodgeValue_Factor,  					%%提升的基础闪避
					blockValue_Factor, 						%%提升的基础格挡
					criticalValue_Factor,  					%%提升的基础暴击
					penetrateValue_Factor,  				%%提升的基础穿透
					hasteValue_Factor,  					%%提升的基础加速值
					toughValue_Factor,  					%%提升的基础坚韧
					unResValue_Factor,  					%%提升的基础全异常抵抗
					stunResValue_Factor, 					%%提升的基础昏迷抵抗值
					fastenResValue_Factor,  				%%提升的基础定身抵抗值
					forbidResValue_Factor,  				%%提升的基础沉默抵抗值
					slowResValue_Factor, 					%%提升的基础减速抵抗值
					point_Factor 						%%战斗力评分系数 add by yueliangyou[2013-3-29]
					} ).


%%装备升品及洗髓所消耗的游戏币
-record(equipwashupmoney,{
						  id,
						equipid, 								%%装备id
						equip_name,								%%物品名称，服务器不使用，只是结构需要	
						wash_white,								%%白色装备洗髓需要的基础金币，	不使用，只是结构需要
						wash_green,								%%绿色装备洗髓需要的基础金币	
						wash_blue,								%%蓝色装备洗髓需要的基础金币
						wash_pur,								%%紫色装备洗髓需要的基础金币
						wash_orange,							%%橙色装备洗髓需要的基础金币
						wash_red,								%%红色装备洗髓需要的基础金币	
						upgrade_white,							%%激活装备所需金币
						upgrade_green,							%%升品到绿色所需金币
						upgrade_blue,							%%升品到蓝色所需金币
						upgrade_pur,							%%升品到紫色所需金币
						upgrade_orange,							%%升品到橙色所需金币
						upgrade_red								%%升品到红色所需金币
						  }).


%%已激活装备，未装备属性加成
-record(equipmentactivebonus_cfg, {
									id,
									equipid,
									name,
									greenAtk_Power,
									greenDef_Class,
									greenMax_HP,
									greenALL_Res,
									blueAtk_Power,
									blueDef_Class,
									blueMax_HP,
									blueALL_Res,
									purpleAtk_Power,
									purpleDef_Class,
									purpleMax_HP,
									purpleALL_Res,
									orangeAtk_Power,
									orangeDef_Class,
									orangeMax_HP,
									orangeALL_Res,
									redAtk_Power,
									redDef_Class,
									redMax_HP,
									redALL_Res,	
									green_point,
									blue_point,
									purple_point,
									orange_point,
									red_point
									}).

%%最小装备等级加成
-record( equipMinLevelPropertyCfg, {
									id,
									level,
									effectID,
									propertyType1,
									value1,
									fixOrPercent1,
									propertyType2,
									value2,
									fixOrPercent2
									} ).

%%装备类型EquipType
-define( EquipType_Ring, 0 ).%%				//戒指
-define( EquipType_Weapon, 1 ).%%				//武器
-define( EquipType_Cap, 2 ).%%				//帽子
-define( EquipType_Shoulder, 3 ).%%				//肩膀
-define( EquipType_Pants, 4 ).%%				//裤子
-define( EquipType_Hand	, 5 ).%%				//护手
-define( EquipType_Coat, 6 ).%%				//衣服
-define( EquipType_Belt, 7 ).%%				//腰带
-define( EquipType_Shoe, 8 ).%%				//靴子
-define( EquipType_Accessories, 9 ).%%				//饰品
-define( EquipType_Wing, 10 ).%%				//翅膀
-define( EquipType_Fashion, 11 ).%%				//时装
-define( EquipType_Max, 12 ).%%装备类型数量

%%装备品质
-define( Equip_Quality_White, 0 ). %%白
-define( Equip_Quality_Green, 1 ). %%绿
-define( Equip_Quality_Blue, 2 ). %%蓝
-define( Equip_Quality_Purple, 3 ). %%紫
-define( Equip_Quality_Orange, 4 ). %%橙
-define( Equip_Quality_Red, 5 ). %%红

-define( Equip_Quality_count, 6 ). %%装备品级数，目前6个

-define( Equip_Active_Item_Count, 4 ). %%激活装备和升品所需物品数

%%装备使用等级
-define( Equip_Level_one, 0 ). %%物品使用等级，1~10级装备 
-define( Equip_Level_two, 1 ). %%物品使用等级，10~20级装备 
-define( Equip_Level_three, 2 ). %%物品使用等级，20~30级装备 
-define( Equip_Level_four, 3 ). %%物品使用等级，30~40级装备 
-define( Equip_Level_five, 4 ). %%物品使用等级，40~50级装备 
-define( Equip_Level_six, 5 ). %%物品使用等级，50~60级装备 

-define( Equip_Level_count, 6 ). %%物品使用等级数，目前6个， 

-define( Equip_Strengthen_MaxLevel, 20 ).%%装备强化的最大等级

%%装备强化结果
-define( EquipEnhance_Success_Level	, 0).		%%强化成功，等级+1
-define( EquipEnhance_Success_Progress , 1).	%%强化成功，进度+1
-define( EquipEnhance_Success_ByBless , 2).		%%祝福值满，强化成功 等级+1
-define( EquipEnhance_Fail_Random , 3).			%%强化失败，
-define( EquipEnhance_Fail_MaxLevel	, 4).		%%操作失败，装备已经是最高强化等级了
-define( EquipEnhance_Fail_NotEnough_Item , 5).	%%操作失败，强化石不够
-define( EquipEnhance_Fail_NotEnough_Money , 6).%%操作失败，游戏币不够

%%装备一键强化结果
-define( EquipOnceEnhance_Success_Level	, 0).		%%强化成功，等级+1
-define( EquipOnceEnhance_Success_ByBless , 1).		%%祝福值满，强化成功 等级+1
-define( EquipOnceEnhance_Fail_NotEnough_Item , 2).	%%强化失败，强化石耗尽
-define( EquipOnceEnhance_Fail_NotEnough_Money , 3).%%强化失败，金钱耗尽

%%装备升品结果
-define( EquipQuality_Success , 0).%%升品成功
-define( EquipQuality_Fail_MaxQuality , 1).%%操作失败，装备已经是最品质了
-define( EquipQuality_Fail_NotEnough_Item , 2).%%操作失败，你的材料不够
-define( EquipQuality_Fail_NotEnough_Money , 3).%%操作失败，你没有足够的游戏币
-define( EquipQuality_Fail_NotEnough_Credit , 4).%%操作失败，你没有足够的声望值
-define( EquipQuality_Fail_NotEnough_Honor , 5).%%操作失败，你没有足够的荣誉值

%%装备洗髓的结果
-define( EquipChangeProperty_Success , 0 ).			%%洗髓，保存成功
-define( EquipChangeProperty_NotEnough_Item	, 1).	%%操作失败，洗髓石不够
-define( EquipChangeProperty_NotEnough_Money , 2).	%%操作失败，你没有足够的游戏币
-define( EquipChangeProperty_NotProperty , 3).		%%操作失败：至少要保证一条属性不被锁定！

%%装备激活失败的原因
-define( EquipActive_Fail_NotEnough_Level , 0).			%%操作失败，你的等级不够
-define( EquipActive_Fail_NotEnough_Money , 1).			%%操作失败，你没有足够的游戏币
-define( EquipActive_Fail_NotEnough_Item , 2).			%%操作失败，你的材料不够
-define( EquipActive_Fail_NotEnough_Credit , 3).		%%操作失败，你没有足够的声望值
-define( EquipActive_Fail_NotEnough_Honor , 4).			%%操作失败，你没有足够的荣誉值
-define( EquipActive_Fail_NotEnough_BeforeEquip , 5).	%%操作失败，你的前置装备没激活
