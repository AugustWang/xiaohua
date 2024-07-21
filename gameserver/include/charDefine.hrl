
%%角色每一项属性基本数据
%%base=角色等级属性值
%%equip=装备影响值
%%skill=技能影响值
-record( charBaseProperty, {base, equip, skill} ).

%%角色每一项属性记录
%%fix=固定值记录值(charBaseProperty)
%%per=万分比记录值(charBaseProperty)
-record( charOneProperty, { fix, per } ).

%%角色属性记录值，每一个属性=charOneProperty
-define( attack, 0).%%攻击力
-define( defence, 1).%%防御力
-define( ph_def, 2).%%物理抗性
-define( fire_def, 3).%%火抗性
-define( ice_def, 4).%%冰抗性
-define( elec_def, 5).%%电抗性
-define( poison_def, 6).%%毒抗性
-define( max_life, 7).%%生命值上限
-define( life_recover, 8).%%生命秒回
-define( been_attack_recover, 9).%%击中回血
-define( damage_recover, 10).%%伤害回血
-define( coma_def, 11).%%昏迷抵抗
-define( hold_def, 12).%%定身抵抗
-define( silent_def, 13).%%沉默抵抗
-define( move_def, 14).%%减速抵抗
-define( hit, 15).%%命中
-define( dodge, 16).%%闪避
-define( block, 17).%%格挡
-define( crit, 18).%%暴击
-define( pierce, 19).%%穿透
-define( attack_speed, 20).%%攻速
-define( tough, 21).%%坚韧
-define( crit_damage_rate, 22).%%暴击伤害倍率
-define( block_dec_damage, 23).%%格挡减伤
-define( phy_attack_rate, 24).%%物理伤害乘数
-define( fire_attack_rate, 25).%%火伤害乘数
-define( ice_attack_rate, 26).%%冰伤害乘数
-define( elec_attack_rate, 27).%%电伤害乘数
-define( poison_attack_rate, 28).%%毒伤害乘数
-define( phy_def_rate, 29).%%防物理伤害乘数
-define( fire_def_rate, 30).%%防火伤害乘数
-define( ice_def_rate, 31).%%防冰伤害乘数
-define( elec_def_rate, 32).%%防电伤害乘数
-define( poison_def_rate, 33).%%防毒伤害乘数
-define( treat_rate, 34).%%施法治疗效果乘数
-define( treat_rate_been, 35).%%被治疗效果乘数
-define( life_recover_MaxLife, 36).%%生命秒回按总生命值的百分比恢复
-define( move_speed, 37).%%移动速度
-define( coma_def_rate, 38).%%昏迷抵抗率
-define( hold_def_rate, 39).%%定身抵抗率
-define( silent_def_rate, 40).%%沉默抵抗率
-define( move_def_rate, 41).%%减速抵抗率
-define( hit_rate_rate, 42).%%命中率
-define( dodge_rate, 43).%%闪避率
-define( block_rate, 44).%%格挡率
-define( crit_rate, 45).%%暴击率
-define( pierce_rate, 46).%%穿透率
-define( attack_speed_rate, 47).%%攻速率
-define( tough_rate, 48).%%坚韧率

-define( all_def, 49).%%全抗性
-define( all_exception, 50).%%全异常
-define( all_exception_rate, 51).%%全异常率
-define( all_damage, 52).%%攻全伤害
-define( all_def_damage, 53).%%防全伤害

-define( property_count, 54 ).%%属性个数

-record( charProperty, { id, attack, defence, ph_def, fire_def, ice_def, elec_def, poison_def, 
						 max_life, life_recover, been_attack_recover, damage_recover, coma_def, 
						 hold_def, silent_def, move_def, hit, dodge, block, crit, pierce, 
						 attack_speed, tough, crit_damage_rate, block_dec_damage,
						 phy_attack_rate, fire_attack_rate, ice_attack_rate, elec_attack_rate,poison_attack_rate,
						 phy_def_rate, fire_def_rate, ice_def_rate, elec_def_rate, poison_def_rate,
						 treat_rate, treat_rate_been, life_recover_MaxLife, move_speed, all_def, all_exception, 
						 all_damage, all_def_damage } ).

%%charProperty数据项类型
-define( CharProperty_Type_S, 1 ).	%%单数据项
-define( CharProperty_Type_M, 2 ).	%%多数据项

%%攻击因子类型
-define( AttackFator_Fighter, 0 ).	%%战士
-define( AttackFator_Shooter, 1 ).	%%弓手
-define( AttackFator_Master, 2 ).	%%法师
-define( AttackFator_Pastor, 3 ).	%%牧师
-define( AttackFator_Pet, 4 ).		%%宠物
-define( AttackFator_Monster, 5 ).	%%怪物
-define( AttackFator_Normal, 6 ).	%%标准

-record( attackFatorCfg, {id, type, min, max} ).

%%万分比值
-define(Ratio_Value, 10000).






