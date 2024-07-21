-ifndef(muntDef_hrl).


%%坐骑基础属性
-record( mountCfg, { id, mount_data_id, mountName, mountModelID, mountHeadIco, 
					 
					life_recover_MaxLife,
					damage_recover,
					hit_rate_rate,
					dodge_rate,
					block_rate,
					crit_rate,
					pierce_rate,
					attack_speed_rate,
					tough_rate,
					crit_damage_rate,
					block_dec_damage,
					coma_def_rate,
					hold_def_rate,
					silent_def_rate,
					move_def_rate,
					 
					attack,
					defence,
					max_life,
					ph_def,
					fire_def,
					ice_def,
					elec_def,
					poison_def,
					 
					move_speed,
					 
					phy_attack_rate,
					fire_attack_rate,
					ice_attack_rate,
					elec_attack_rate,
					poison_attack_rate,
					phy_def_rate,
					fire_def_rate,
					ice_def_rate,
					elec_def_rate,
					poison_def_rate,
					treat_rate,
					treat_rate_been,
					point_factor,				%% 坐骑战斗力评分系数 add by yueliangyou[2013-3-30]
					player_layer,
					mountHeight
					} ).

%%坐骑等级信息
-record( mountLevelCfg, {
					id,
					mountLevel,
					
					life_recover_MaxLife,
					damage_recover,
					hit_rate_rate,
					dodge_rate,
					block_rate,
					crit_rate,
					pierce_rate,
					attack_speed_rate,
					tough_rate,
					crit_damage_rate,
					block_dec_damage,
					coma_def_rate,
					hold_def_rate,
					silent_def_rate,
					move_def_rate,
					
					attack,
					defence,
					max_life,
					ph_def,
					fire_def,
					ice_def,
					elec_def,
					poison_def,
					
					move_speed,
					
					phy_attack_rate,
					fire_attack_rate,
					ice_attack_rate,
					elec_attack_rate,
					poison_attack_rate,
					phy_def_rate,
					fire_def_rate,
					ice_def_rate,
					elec_def_rate,
					poison_def_rate,
					treat_rate,
					treat_rate_been,
					point				%% 坐骑战斗力评分 add by yueliangyou[2013-3-30]
					} ).


%%坐骑升级消耗表
-record( mountHanceCfg,{
						 id,
						 mountlevel,
						 enhanceCost,
						 itemId,      
						 itemnumber,
						 enhanceRate,
						 progress,
						 benison_Max
						 }).

%%玩家坐骑信息
-record( playerMountInfo, {
						   mount_data_id,
						   playerID,
						   level,
						   progress,
						   equiped,
						   benison_Value
						   } ).

%%坐骑操作结果返回码
-define( PlayerMountOP_Result_Succ, 0 ).	%%操作成功
-define( PlayerMountOP_Result_LevelUP, 1 ).	%%喂养成功并且等级提升
-define( PlayerMountOP_Result_BenisonLevelUP, 2 ).	%%喂养成功并且通过祝福值等级提升
-define( PlayerMountOP_Result_Fail_InvalidCall, -1 ).	%%无效的操作
-define( PlayerMountOP_Result_Fail_EquipedFirst, -2 ).	%%骑上坐骑需要先装备坐骑
-define( PlayerMountOP_Result_Fail_ExistUP, -3 ).	%%已经骑上坐骑了
-define( PlayerMountOP_Result_Fail_MaxLevel, -4 ).	%%已经是最高级了
-define( PlayerMountOP_Result_Fail_LevelUp_Item, -5 ).	%%喂养所需物品不足
-define( PlayerMountOP_Result_Fail_LevelUp_Money, -6 ).	%%喂养所需铜币不足
-define( PlayerMountOP_Result_Fail_LevelUp_Rate, -7 ).	%%喂养失败，进度降为0
-define( PlayerMountOP_Result_Fail_Copy, -8 ).	%%副本中不能上马
-define( PlayerMountOP_Result_Fail_Convoy, -9). %%护送中不能上马
-define( PlayerMountOP_Result_Fail_NoTip, -10 ).	%%不给提示文字

%%坐骑最高等级
-define( MaxMountLevel, 20 ).

-endif.
