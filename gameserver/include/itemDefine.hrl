
-ifndef(itemDefine_hrl).

%%用于添加的Item
-record(itemForAdd, {id, count, binded}).

%%
-define( ProcTempValue1, "ProcTempValue1" ).
-define( ProcTempValue2, "ProcTempValue2" ).
-define( ProcTempValue3, "ProcTempValue3" ).
-define( ProcTempValue4, "ProcTempValue4" ).
-define( ProcTempValue5, "ProcTempValue5" ).

-define( Max_Bag_Cells_PerLine,	9 ).
-define( Max_Bag_Cell_Lines,	10 ).
-define( Max_Bag_Cells,	?Max_Bag_Cells_PerLine * ?Max_Bag_Cell_Lines ).

-define( Max_StorageBag_Cells_PerLine,	4 ).
-define( Max_StorageBag_Cell_Lines,	15 ).
-define( Max_StorageBag_Cells,	?Max_StorageBag_Cells_PerLine * ?Max_StorageBag_Cell_Lines ).

-define( Max_TempBag_Cells_PerLine,	6 ).
-define( Max_TempBag_Cell_Lines,	5 ).
-define( Max_TempBag_Cells,	?Max_TempBag_Cells_PerLine * ?Max_TempBag_Cell_Lines ).

-define(Max_BackBuy_Cells, 10).

-define( item_owner_type_unkown, 0 ).
-define( item_owner_type_player, 1 ).
-define( item_owner_type_mail, 2 ).
-define( item_owner_type_conSales, 3 ).

-define( Item_Owner_Mail_ID, 10000000000 ).

-define( PlayerCreateEnableBagCells, 36 ).

-define( PlayerCreateEnableStorageBagCells, 20 ).

%%ç©å®¶ä½¿ç¨èåçåºå®ç©åVipç­çº§è¦æ±
-define( PlayerBag_SellItem_Vip_Level, 0 ).

%% Item_Location_Type
-define( Item_Location_Bag,	0 ).
-define( Item_Location_Storage,	1 ).
-define( Item_Location_TempBag,	2 ).
-define( Item_Location_Mail, 3).
-define( Item_Location_Trade, 4).
-define( Item_Location_BackBuy,	5 ).
-define( Item_Location_Count,	6 ).
-define( Item_Location_ErrorItem,	100 ).

%% Item_Bind_Type 
-define( Item_Bind_Unkown,	0 ).
-define( Item_Bind_Geted,	1 ).
-define( Item_Bind_Pick,	2 ).
-define( Item_Bind_Use,	3 ).


%% Get item reson
-define( Get_Item_Param_Bind_Set_Binded, "set binded" ).
-define( Get_Item_Param_Bind_Set_UnBinded, "set unbinded" ).
-define( Get_Item_Param_NotSet_UsefulLife, "not set usefullife" ).

-define( Get_Item_Reson_Pick, 1 ).		%%	杀怪掉落和包裹掉落
-define( Get_Item_Reson_BuyFromNpc, 2 ).%%	Npc购买
-define( Get_Item_Reson_TradeFromPlayer, 3 ).	%% 玩家与玩家交易
-define( Get_Item_Reson_GM, 4 ).		%%	GM指令获得
-define( Get_Item_Reson_BagOrder, 5 ).	%%	整理背包获得
-define( Get_Item_Reson_Task, 6).		%%	任务
-define( Get_Item_Reson_Mail, 7).		%%	邮件
-define( Get_Item_Reson_ItemUse, 8).	%%	使用物品
-define( Get_Item_Reson_Split, 9).		%%	拆分
-define( Get_Item_Reson_Signin, 10).	%%	签到
-define( Get_Item_Reson_BazzarBuy, 11).	%%	商城购买
-define( Get_Item_Reson_PlatformSend, 12).%%	平台发放
-define( Get_Item_Reson_RechargeGift, 13).%%	充值赠送
-define( Get_Item_Reson_BuyFromToken, 14).%%	令牌商店购买
-define( Get_Item_Reson_Compound, 15).    %%    合成得到


%% Destroy item reson
-define( Destroy_Item_Reson_Player, 1 ).		%	玩家手动
-define( Destroy_Item_Reson_BagOrder, 2 ).		%	整理背包
-define( Destroy_Item_Reson_ActiveEquip, 3 ).	%	激活装备
-define( Destroy_Item_Reson_Sell, 4 ).			%	卖出到NPC
-define( Destroy_Item_Reson_Player_ClearTempBag, 5 ).			%	购买临时背包
-define( Destroy_Item_Reson_SendMail, 6 ).			%	邮件发送
-define( Destroy_Item_Reson_groundingToConSalse, 7 ).			%	上架到交易行
-define( Destroy_Item_Reson_TradeToPlayer, 8 ).			%	交易给其他玩家
-define( Destroy_Item_Reson_SellToNpcStore, 9 ).			%	卖出
-define( Destroy_Item_Reson_BackBuy, 10 ).			%	被回购
-define( Destroy_Item_Reson_BackBuyCellsFull, 11 ).			%	回购的格子满了
-define( Destroy_Item_Reson_GuildContribute, 12 ).			%	仙盟捐献
-define( Destroy_Item_Reson_PetWashGrowUp, 13 ).			%	宠物刷新成长率
-define( Destroy_Item_Reson_PetIntensifySoul, 14 ).			%	宠物灵性强化
-define( Destroy_Item_Reson_CommitTask, 15 ).				%	归还任务
-define( Destroy_Item_Reson_Revive, 16 ).				%	复活
-define( Destroy_Item_Reason_PetLearnSkill,  17).		%%宠物学习技能
-define( Destroy_Item_Reason_PetSealAhsSkill,  18).		%%宠物封印技能
-define( Destroy_Item_Reson_EquipEnHance,  19).		%%装备强化
-define( Destroy_Item_Reson_EquipQualityUP,  20).		%%装备升品
-define( Destroy_Item_Reson_EquipChangeProperty,  21).		%%装备升品
-define( Destroy_Item_Reson_UseHpMp,  22).		%%使用药品
-define( Destroy_Item_Reson_MountLevelUp,  23).		%%骑乘喂养
-define( Destroy_Item_Reson_Teleporte,  24).		%%地图传送
-define( Destroy_Item_Reson_ActiveSkill,  25).		%%技能激活
-define( Destroy_Item_Reson_LockBagCell,  26).		%%解锁背包格子
-define( Destroy_Item_Reson_LockStorageCell,  27).		%%解锁仓库格子
-define( Destroy_Item_Reson_AddCopyMapActiveCount, 28).	%%增加副本活跃次数
-define( Destroy_Item_Reson_TokenStoreBuyItem, 29).	%%以物换物商店，购买物品
-define( Destroy_Item_Reson_GuildCreate, 30 ).		%仙盟创建
-define( Destroy_Item_Reson_Chat, 31 ).		%仙盟创建
-define( Destroy_Item_Reson_ActiveCode, 32 ).		%激活码领取
-define( Destroy_Item_Reson_Compound, 33).  %合成



%% Item_OP_Result
-define( Item_OP_Result_Succ, 0 ).				%æä½æå
-define( Item_OP_Result_False_InvalidCall,-1 ).	%	æ ææä½
-define( Item_OP_Result_False_Level, -2).		%	ä½¿ç¨ç­çº§ä¸å¤
-define( Item_OP_Result_False_Locked, -3).		%	æ ¼å­éå®
-define( Item_OP_Result_False_Class, -4).		%	èä¸ä¸ç¬¦
-define( Item_OP_Result_False_Dead, -5). %%死亡或昏迷状态下不能使用
-define( Item_OP_Result_False_Full_Life, -6).%%满血状态下不能使用
-define( Item_OP_Result_False_Full_BloodPool, -7).%%血池已满
-define( Item_OP_Result_False_Full_Pet, -8).%%宠物栏已满
-define( Item_OP_Result_False_Full_Bag, -9).%%背包已满
-define( Item_OP_Result_False_CDIng, -10).%%物品CD中
-define( Item_OP_Result_False_GetTask, -11).%%获得任务失败
-define( Item_OP_Result_False_PetGetEXP, -12).%%使用失败，需要宠物出战
-define( Item_OP_Result_False_PetAddGrowUP, -13).%%增加成长率最大值失败，需要宠物出战


%%Item_UseTypeç©åä½¿ç¨åè½ç±»å
-define( Item_Use_PrepareHPMP, 1 ).				%	é¢å­HPMPï¼Param1:1:HP 2:MP 3:HP and MP; Param2:Value
-define( Item_Use_Buffer, 2 ).					%	ç»ç®æ å¢å ä¸ä¸ªBufferï¼Param1:BufferID
-define( Item_Use_HPMP, 3).						%	ç«å³æ¢å¤HPMPï¼Param1:1:HP 2:MP 3:HP and MP; Param2:Value
-define( Item_Use_Skill, 4).					%	ä½¿ç¨ä¸ä¸ªæè½ï¼Param1:SkillID
-define( Item_Use_PetEgg, 5).					%	è·å¾å® ç©ï¼Param1:PetID
-define( Item_Use_OpenGift, 6).					%	å¼åè£¹ï¼Param1:DropID
-define( Item_Use_MountEgg, 7).                  %   使用坐骑蛋,Param1:坐骑ID      
-define( Item_Use_LiBao, 8).                    %   使用礼包，Param1:DropListID
-define( Item_Use_GetTask, 9).                    %   获得任务，Param1:任务ID
-define( Item_Use_GetMoney, 10).                    %   获得钱，Param1:钱数量(1-20亿)，Param2:(0=绑定，1=不绑定)
-define( Item_Use_GetEXP, 11).                    %   获得经验，Param1:经验数量
-define( Item_Use_AddCopyMapCD, 12).                    %   增加副本CD次数，Param1:增加次数
-define( Item_Use_Pet_GetEXP, 13).                    %   给出站的宠物加经验，Param1:经验数量
-define( Item_Use_PetPrepareHPMP, 14).		%给宠物血包增加
-define( Item_Use_AddPetMapGrowUP, 15).			%%给宠物增加最大成长值
-define( Item_Use_GetBindedGold, 16).			%%获得绑定元宝,Param1:钱数量(1-20亿)
-define( Item_Use_AddVIPDay, 17).			%%增加VIP天数，Param1：天数
-define( Item_Use_AddReputation, 18).			%%增加声望
-define( Item_Use_AddHonor, 19).			%%增加荣誉
-define( Item_Use_AddExpByLevel, 20).			%%根据等级给经验
-define( Item_Use_MultyExp, 21).			%%多倍经验

%%物品品质
-define(Item_Quality_Normal, 0).	%%普通
-define(Item_Quality_Excellent, 1).	%%优秀
-define(Item_Quality_Well, 2).	  %%精良
-define(Item_Quality_Epic, 3).		%%史诗
-define(Item_Quality_Legend, 4).	%%传说
-define(Item_Quality_Mythology, 5).	%%神话
-define(Item_Quality_Count, 6 ).


%% 物品类型
-define( Item_Unkown, 0). %%未知
-define( Item_Normal, 1). %%普通
-define( Item_HPMP, 2). %%药品
-define( Item_PetEgg, 3). %%宠物蛋
-define( Item_Func, 4). %%功能消耗
-define( Item_Jewel, 5). %%宝石
-define( Item_GiftBag, 6). %%礼包
-define( Item_Spec, 7). %%特殊
-define( Item_Mounts, 8). %%坐骑
-define( Item_GoldCard, 9). %%元宝卡
-define( Item_Task, 10). %%任务品
-define( Item_SkillBook, 11). %%技能书
-define( Item_Stone, 12). %%装备材料
-define( Item_VIP_Card, 13).	%%VIP卡片
-define( Item_Type_Count, 14).
	

%%药品详细类型
-define( HPMP_Type_Normal, 0). %%普通药品
-define( HPMP_Type_MiddleIntensify, 1). %%中级强化
-define( HPMP_Type_HighIntensify, 2). %%高级强化
-define( HPMP_Type_Count, 3).

%%功能消耗类物品详细类型
-define( Func_Type_Strengthen, 0). %%强化石
-define( Func_Type_WashStone, 1). %%洗练石
-define( Func_Type_SoulDrug, 2).%%灵性丹
-define( Func_Type_WashSoul, 3). %%洗灵石头
-define( Func_Type_Other, 4). %%其他
-define( Func_Type_Count, 5). 

%%技能书详细类型
-define( SkillBook_Type_Player, 0).	%%玩家技能书
-define( SkillBook_Type_Pet, 1).	%%宠物技能书
-define( SkillBook_Type_Count, 2).


-define( Item_Stone_Type_KuangShi, 0 ).		%%矿石
-define( Item_Stone_Type_XuanJin,	1).		%%玄晶
-define( Item_Stone_Type_YaoLeiShi, 2).		%%妖泪石
-define( Item_Stone_Type_NvWanShi, 3).		%%女娲石
-define( Item_Stone_Type_Count, 4).		%%女娲石


%%元宝卡详细类型
-define( GoldCard_Little, 0). %%小额（100）
-define( GoldCard_Middle, 1). %%中额（500）
-define( GoldCard_High, 2). %%高额（1000）
-define( GoldCard_Type_Count, 3). 

%%开启格子返回
-define( PlayerBagCellOpen_Result_Succ, 1).		%%开启成功
-define( PlayerBagCellOpen_Result_Full, -1).		%%开启格子失败，没有可开启的格子
-define( PlayerBagCellOpen_Result_NotEnough, -2).	%%开启格子失败，元宝或者钥匙不足


%%物品保护取值
-define( ItemProtect_Cannot_Trade, 			1).		%%不能交易
-define( ItemProtect_Cannot_Discard,			2).		%%不能丢弃
-define( ItemProtect_Cannot_Mail,				4).		%%不能邮寄
-define( ItemProtect_Cannot_Sale,				8).		%%不能拍卖
-define( ItemProtect_Cannot_Sell,				16).		%%不能出售

%%购买兑换物品结果
-define(BuyItem_Success_NPCStore, 0 ).	 	%%购买成功,卖出成功
-define(BuyItem_Success_TokenStore, 1 ).	%%兑换成功	
-define(BuyItem_Fail_Bag, 2 ).				%%背包已满，操作失败
-define(BuyItem_Fail_Money, 3 ).			%%购买失败，金钱不够
-define(BuyItem_Fail_ManToken, 4 ).			%%兑换失败，人运令不够
-define(BuyItem_Fail_LandToken, 5 ).		%%兑换失败，地运令不够
-define(BuyItem_Fail_SkyToken, 6 ).				%%兑换失败，天运令不够

%%商店的类型
-define(Item_NPCStore, 0 ).	 	%%普通商店
-define(Item_TokenStore, 1 ).	%%令牌商店

%%令牌商店的令牌的类型
-define(TokenStore_ManToken, 0 ).	%%人运令
-define(TokenStore_LandToken, 1 ).	%%地运令
-define(TokenStore_SkyToken, 2 ).	%%天运令

-define(ItemUsedCountCdTime, 4*3600 ).	%%有使用次数限制的物品，使用次数cd time

-endif. % -ifdef(itemDefine_hrl).

