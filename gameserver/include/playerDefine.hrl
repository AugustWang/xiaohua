
-ifndef(playerDefine_hrl).

-record( playerOnlineDBData, { playerBase, equipedList, allItemDBDataList, allItemBagDataList, allTaskDBDataList,
							   allSkillList, allShortcutList, equipEnhanceInfoList, allFriendGamedataList, allBuff,
								playerMountInfo,playerItemCDInfo,playerItem_DailyCountInfo, dailyCount_Info } ).%%玩家上线初始化，从DB拿到的数据


-define(MessagePrompt(W,M),systemMessage:sendPromptMessage(W,M)).
-define(MessageError(W,M),systemMessage:sendErrMessage(W,M)).
-define(MessageBox(W,M),systemMessage:sendBoxMessage(W,M)).
-define(MessageTips(W,M),systemMessage:sendTipsMessage(W,M)).

-define(MessagePromptMe(M),systemMessage:sendPromptMessageToMe(M)).
-define(MessageErrorMe(M),systemMessage:sendErrMessageToMe(M)).
-define(MessageBoxMe(M),systemMessage:sendBoxMessageToMe(M)).
-define(MessageTipsMe(M),systemMessage:sendTipsMessageToMe(M)).

%% 玩家领取充值礼包结果返回码
-define( RCODE_RECHARGE_GIFT_SUC,0).
-define( RCODE_RECHARGE_GIFT_INVALID_TYPE,1).
-define( RCODE_RECHARGE_GIFT_NOTENOUGH_AMMOUNT,2).
-define( RCODE_RECHARGE_GIFT_ALREADY_GET,3).
-define( RCODE_RECHARGE_GIFT_EXCEPTION,4).
-define( RCODE_RECHARGE_GIFT_BAG_ISFULL,5).

%%玩家的物品CD信息
-record( playerItemCDInfo, { cdTypeID, cd_time, all_time } ).

%%玩家的每日使用物品次数CD
-record( playerItem_DailyCountInfo, { cdTypeID, curCount, maxCount, cd_time } ).

-define( User_State_UnCheckPass, 0 ).
-define( User_State_WaitClose, 1 ).
-define( User_State_WaitCheck, 2 ).
-define( User_State_WaitPlayerList, 3 ).
-define( User_State_LobbyChar, 4 ).
-define( User_State_WaitCreatePlayer, 5 ).
-define( User_State_WaitDeletePlayer, 6 ).
-define( User_State_WaitSelPlayer, 7 ).
-define( User_State_WaitEnterMap, 8 ).
-define( User_State_Gaming, 9 ).
-define( User_State_Closing, 10 ).

%%//	生物状态标签，逻辑或关系Actor_State_Flag_Type
%%// player、npc共享部分
-define( Actor_State_Flag_Unkown, 0 ).%%	//	未初始化
-define( Actor_State_Flag_Loading, 1 ).%%	//	加载中
-define( Actor_State_Flag_WaitEnterMap, 2 ).%%	//	等待玩家进入地图
-define( Actor_State_Flag_EnteredMap, 4 ).%%	//	玩家已经进入地图
-define( Actor_State_Flag_Dead, 8 ).%%	//	已死亡
-define( Actor_State_Flag_Fighting, 32 ).%%	//	战斗状态
-define( Actor_State_Flag_God, 64 ).%%	//	无敌状态
-define( Actor_State_Flag_Disable_Attack, 128 ).%%	//	禁止攻击状态
-define( Actor_State_Flag_Disable_Move, 256 ).%%	//	禁止移动状态
-define( Actor_State_Flag_Disable_Hold, 512 ).%%	//	昏迷状态

%%// 玩家专享部分( 0x400--0x100000)
-define( Player_State_Flag_TalkingWithNpc, 1024 ).%%	//	Npc对话中
-define( Player_State_Flag_CollectingWithNpc, 2048 ).%%	//	Npc采集中
-define( Player_State_Flag_TradeWithPlayer, 4096 ).%%	//	与玩家交互中（玩家交易）
-define( Player_State_Flag_ChangingMap, 8192 ). %%0x2000	//	地图切换中
-define( Player_State_Flag_PK_Kill, 16384 ). %%0x4000	//	杀戮模式开启中
-define( Player_State_Flag_PK_Kill_Value, 32768 ). %%0x8000	//	杀戮值达到被杀戮状态
-define( Player_State_Flag_Convoy, 65536). %%0x10000 // 护送状态
-define( Player_State_Flag_Just_Disable_Move, 131072 ).%%	//	禁止移动状态，直接设置，技能不能解

%%// Monster专享状态( 0x200000--0x4000000 )
-define( Monster_State_Flag_GoBacking, 2097152 ).%%0x200000 // 往回跑重置

%%生物状态操作
-define( Actor_State_Flag_OP_Add, 1 ).%%增加状态
-define( Actor_State_Flag_OP_Remove, 2 ).%%移除状态
-define( Actor_State_Flag_OP_Set, 3 ).%%设置状态

%%玩家属性类型枚举Player_Pro_Type
-define( Player_Pro_Level, 0).%%	//等级
-define( Player_Pro_Life, 1).%%	//生命
-define( Player_Pro_LifeMax, 2).%%	//生命
-define( Player_Pro_PhysicAttack, 3).%%	//物理攻击
-define( Player_Pro_MagicAttack, 4).%%	//法术攻击
-define( Player_Pro_PhysicDefense, 5).%%	//法术防御
-define( Player_Pro_Hit, 6).%%	//命中
-define( Player_Pro_Crit, 7).%%	//暴击
-define( Player_Pro_Block, 8).%%	//格挡
-define( Player_Pro_Tough, 9).%%	//坚韧
-define( Player_Pro_Dodge, 10).%%	//闪避
-define( Player_Pro_Pierce, 11).%%	//穿透
-define( Player_Pro_money, 12).%%	//铜币
-define( Player_Pro_moneyBinded, 13).%%	//绑定铜币
-define( Player_Pro_gold, 14).%%	//元宝
-define( Player_Pro_goldBinded, 15).%%	//绑定元宝
-define( Player_Pro_ticket, 16).%%	//点券
-define( Player_Pro_guildContribute, 17).%%	//帮贡
-define( Player_Pro_honor, 18).%%	//荣誉
-define( Player_Pro_credit, 19).%%	//声望
-define( Player_Pro_MagicDefense, 20).%%	//法术防御
-define( Player_Pro_GuildID, 21).%%	//仙盟ID
-define( Player_Pro_BloodPool, 22).%%	//血池
-define( Player_Pro_AttackSpeed, 23).%%	//攻击速度
-define( Player_Pro_PetBloodPool, 24).%%	//宠物血池
-define( Player_Pro_Exp15Add, 25).%%	//1.5倍经验加成
-define( Player_Pro_Exp20Add, 26).%%	//2.0倍经验加成
-define( Player_Pro_Exp30Add, 27).%%	//3.0倍经验加成



%% 玩家最高等级
-define( Max_Player_Level, 99 ).

%%玩家职业类型Player_Class_Type
-define( Player_Class_Fighter, 0).						%%战士
-define( Player_Class_Shooter, 1).						%%弓手
-define( Player_Class_Master, 2).						%%法师
-define( Player_Class_Pastor, 3).						%%牧师
-define( Player_Class_Count, 4).						%%职业类型数量

%%阵营天玑
-define( CAMP_TIANJI, 0 ).
%%阵营玄宗
-define( CAMP_XUANZONG, 1 ).
%%阵营数量
-define( CAMP_COUNT, 2 ).

%%玩家性别男
-define( Player_Sex_Man, 0 ).
%%玩家性别女
-define( Player_Sex_Woman, 1 ).

%%玩家最大钱数量，包括铜币、绑定铜币、元宝、绑定元宝
-define( Max_Money, 2000000000 ).

%%玩家充值RMD兑换游戏金币的比例
-define( RMB_GOLD_RATIO, 10 ).

%%钱类型Money_Type
-define( Money_Money, 0 ).%%	//	铜币
-define( Money_BindedMoney, 1 ).%%	//	绑定铜币
-define( Money_Gold, 2 ).%%	//	元宝
-define( Money_BindedGold, 3 ).%%	//	绑定元宝
-define( Money_RechargeAmmount, 4 ).%%	//	充值总金额
-define( Money_Count, 5 ).

%%钱变化原因Money_Change_Type
-define( Money_Change_Equip, 0 ).%%	//	装备激活
-define( Money_Change_GM, 1 ).%%	//	GM
-define( Money_Change_Task, 2).	%%	//	任务
-define( Money_Change_MailSend, 3).	%%	//	邮件发送
-define( Money_Change_MailPay, 4).	%%	//	邮件付费收取
-define( Money_Change_MailRecv, 5).	%%	//	邮件收取
-define( Money_Change_ConSalesBuy, 6).	%%	//	交易行购买物品
-define( Money_Change_ConSales_CustodianFee, 7).	%%	//	交易行保管费
-define( Money_Change_Player_Trade, 8).	%%	//	玩家之间的交易
-define( Money_Change_NPCStore, 9).	%%	//	NPC商店交易
-define( Money_Change_CreateGuild, 10).	%%	//	仙盟创建
-define( Money_Change_GuildContribute, 11).	%%	//	仙盟捐献
-define( Money_Change_NPCStore_BackBuy, 12).	%%	//	NPC商店交易_回购
-define( Gold_Change_BagOpenCell, 13). %% //扩充背包格子 
-define( Gold_Change_StoreOpenCell, 14). %% //扩充仓库格子 
-define( Money_Change_PetWashGrowUp, 15).	%%宠物刷新成长率
-define( Money_Change_PetIntensifySoul, 16).	%%宠物灵性强化
-define( Money_Change_PetLearnSkill, 17).	%%宠物学习技能
-define( Money_Change_StudySkill, 18).	%%玩家学习技能
-define( Money_Change_EquipEnHance, 19).	%%强化装备
-define( Money_Change_EquipQualityUP, 20).	%%装备升品
-define( Money_Change_EquipChangeProperty, 21).	%%装备升品
-define( Money_Change_MountLevelUp, 22).	%%坐骑喂养
-define( Money_Change_UseItem, 23).	%%使用物品获得
-define( Money_Change_BazzarBuy, 24).	%%商城购买
-define( Money_Change_Recharge, 25).	%%充值
-define( Money_Change_PetUnLockSkillCell, 26).	%%宠物 UnLockSkillCell
-define( Money_Change_PlatformSend, 27).	%%平台发放 
-define( Money_Change_Convoy, 28).  %%护送
-define( Gold_Change_Convoy, 29). %%护送
-define( Money_Change_Refrsh, 30). %%刷新护送
-define( Money_Change_Gold, 31). %%聚宝盆
-define( Money_Change_CopymapFinish, 32). %%副本结算
-define( Money_Change_Compound, 33). %%合成

%%经验变化原因Exp_Change_Type
-define( Exp_Change_Task, 0).	%%	//任务获得经验
-define( Exp_Change_KillMonster, 1).	%%	//杀怪获得经验
-define( Exp_Change_GM, 2).	%%	//GM经验
-define( Exp_Change_UseItem, 3).	%%	//使用物品获得
-define( Exp_Change_PlatformSend, 4).			%%平台发放
-define( Exp_Change_Convoy, 5).     %% //护送获得经验
-define( Exp_Change_Active, 6).     %% //活跃值兑换
-define( Exp_Change_Answer, 7).     %% //答题兑换
-define( Exp_Change_Unknow, 8).			%%
-define( Exp_Change_Battle, 8).			%%战场

%%声望变更原因
-define( Credit_Change_Task, 0).	%%	//任务获得声望
-define( Credit_Change_Contribute, 1).	%%	//仙盟捐赠获得声望

%%角色创建结果
-define( CreatePlayer_Result_Succ, 0 ).%%成功
-define( CreatePlayer_Result_Fail_Full, -1 ).%%满
-define( CreatePlayer_Result_Fail_Name_Unvalid, -2 ).%%名字不合法
-define( CreatePlayer_Result_Fail_Name_Exist, -3 ).%%重名
-define( CreatePlayer_Result_Fail_Name_Forbidden, -4 ).%%名字里有敏感字符

-define( Min_CreatePlayerName_Len, 2 ).%%角色创建名字最小字符
-define( Max_CreatePlayerName_Len, 7 ).%%角色创建名字最大字符

%%角色改名结果
-define( ChangePlayerName_Result_Succ, 0 ).%%成功
-define( ChangePlayerName_Result_Fail_Error, -1 ).%%其它错误
-define( ChangePlayerName_Result_Fail_Name_Unvalid, -2 ).%%名字不合法
-define( ChangePlayerName_Result_Fail_Name_Exist, -3 ).%%重名
-define( ChangePlayerName_Result_Fail_Name_Forbidden, -4 ).%%名字里有敏感字符

%%角色删除结果
-define( DeletePlayer_Result_Succ, 0 ).%%成功
-define( DeletePlayer_Result_Fail, -1 ).%%失败

%%玩家被踢下线原因
-define( KickoutUser_Reson_ReLogin, 0 ).%%重复登录
-define( KickoutUser_Reson_GM, 1 ).%%GM
-define( KickoutUser_Reson_HeartBeat_Timeout, 2 ).%%GM

%%玩家角色登陆结果
-define( SelPlayer_Result_Succ, 0 ).%%登陆成功
-define( SelPlayer_Result_PlayerCount_Fail, -1 ).%%玩家角色数量大于1个
-define( SelPlayer_Result_UserId_Fail, -2 ).%%账号下无此角色
-define( SelPlayer_Result_Player_IsOnline, -3 ).%%角色在线

%%
%%当前全服玩家最高等级
-define( Max_Player_Level_Cur, 60 ).

%%物理进战攻击技能ID
-define( Melee_SkillID, 1 ).
%%物理远程攻击技能ID
-define( Remote_SkillID, 2 ).

%%玩家宠物栏数量
-define( Player_Pet_Max_Num, 6 ).
%%宠物基础转换率(万分比)
-define( Pet_Base_ConvertRatio, 800).

%%快捷栏上ID的类型
-define( Short_Skill , 1 ).%%技能

%%角色改保护密码
-define( SetProtectPwd_Result_Succ, 0 ).%%成功
-define( SetProtectPwd_Result_Fail_Error, -1 ).%%其它错误
-define( SetProtectPwd_Result_Fail_Length, -2 ).%%长度太长
-define( SetProtectPwd_Result_Fail_Old_Error, -3 ).%%老密码错误


%%查看装备返回
-define( LookPlayerInfo_Failed_NotOnline, -1 ).		%%对方不在线
-define( LookPlayerInfo_Failed_Self,		-2 ).		%%不能查看自己
-define( LookPlayerInfo_Failed_UnKnow,		-3 ).	%%未知错误

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%仓库密码
%%仓库密码改变原因
-define(PlayerSetStorageBagPassWord, 0 ).	%%玩家set仓库密码
-define(PlayerChangeStorageBagPassWord, 1 ).	%%玩家修改仓库密码
-define(PlayerUnlockStorageBagPassWord, 2 ).	%%玩家强制解锁仓库密码

%%修改仓库密码结果
-define(PlayerSetPassWordSuccess, 0). %%设置密码成功
-define(PlayerChangePassWordSuccess ,1).	%%玩家修改仓库密成功
-define(PlayerClearPassWordSuccess,2).%%重置密码成功
-define(PlayerChange_OldPassSuccessWrong , 3).	%%旧密码错误

%%输入密码类型
-define(StorageBagPassWord ,0).
-define(GoldPassWord,1).
%%输入密码结果
-define(PlayerPassWord_Success, 0). %%密码正确
-define(PlayerPassWord_Fail, 1).%%密码错误
-define(PlayerImportPassWord,2).%%请输入密码

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%元宝密码
%%元宝密码改变原因
-define(PlayerSetGoldPassWord, 0 ).	%%玩家设置元宝密码
-define(PlayerChangeGoldPassWord, 1 ).	%%玩家修改元宝密码
-define(PlayerUnlockGoldPassWord, 2 ).	%%玩家强制解锁元宝密码
-define(PlayerCancelGoldPassWord, 3 ).	%%玩家取消元宝密码

%%修改元宝密码结果
-define(PlayerSetGoldPassWordSuccess, 0). %%设置密码成功
-define(PlayerChangeGoldPassWordSuccess ,1).	%%玩家修改元宝密成功
-define(PlayerClearGoldPassWordSuccess,2).%%重置密码成功
-define(PlayerChange_OldGoldPassSuccessWrong , 3).	%%旧密码错误
-define(PlayerCancelGoldPassWordSuccess , 4).	%%取消密码成功
-define(PlayerCancelGoldPassWordFail , 5).	%%取消密码失败



%%输入密码结果
-define(PlayerGoldPassWordSuccess, 0). %%密码正确
-define(PlayerGoldPassWordFail, 1).%%密码错误

%%//激活码领取结果返回
%%enum ACTIVE_CODE_GET_RESULT
%%{
-define(ACTIVE_CODE_GET_SUCC,0 ).%%	//	激活码领取成功
-define(ACTIVE_CODE_GET_FAIL_NOT_EXIST,1 ).%%	//	激活码不存在
-define(ACTIVE_CODE_GET_FAIL_GETED,2 ).%%	//	激活码已经领取过
-define(ACTIVE_CODE_GET_FAIL_INVALID,3 ).%%	//	操作失败
-define(ACTIVE_CODE_GET_FAIL_FULLBAG,4 ).%%	//	背包已满
%%};

-endif. % -ifdef(playerDefine_hrl).
