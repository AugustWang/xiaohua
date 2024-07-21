
%% log_online_record
-record(log_online_record,{time,count}).
%% log_player_task
-record(log_player_task,{userid,playerid,taskid, level,flag,time}).
%% log_player_login
-record(log_player_login,{userid,playerid,level,money,money_b,gold,gold_b,exp,life,flag,time}).
%% log_player
-record(log_player,{playerid,name,camp,sex,time}).

%% log_player_event
-record(log_player_event,{userid,playerid,level,money,money_b,gold,gold_b,exp,life,time,eventtype,content}).

%% log_recharge
-record(log_recharge,{orderid,platform,account,userid,playerid,ammount,flag,time}).
%% log_gold
-record(log_gold,{playerid,flag,gold_old,gold_mod,gold_new,reason,desc,time}).


-define(LOG_PLAYER_ONLINE,0).
-define(LOG_PLAYER_OFFLINE,1).

-define(LOG_PLAYER_TASK_ACCEPT,0).
-define(LOG_PLAYER_TASK_COMMIT,1).
-define(LOG_PLAYER_TASK_CANCEL,2).

-define(LOG_RECHARGE_SUCC,0).
-define(LOG_RECHARGE_FAIL,1).

-define(EVENT_PLAYER_LOGIN,0).		%%玩家登入 paramlist 登入时间
-record(login_param,{logintime}).

-define(EVENT_PLAYER_LOGOUT,1).		%%玩家登出 paramlist 登出事件
-record(logout_param,{logouttime}).

-define(EVENT_PLAYER_USEITEM,2).	%%使用物品 paramlist 物品ID 物品数量  物品功效   		%%-define( Item_Use_PrepareHPMP, 1 )
-record(useitem_param,{itemid,number,usetype}).

-define(EVENT_PLAYER_BUYITEM,3).	%%购买物品 paramlist 商店ID  物品ID  购买数量     消耗货币  消耗绑定货币
-record(buyitem_param,{storeid,itemid,number,money,money_b}).

-define(EVENT_PLAYER_FLY,4).	%%地图切换使用飞行道具 paramlist NULL
-record(fly_param,{nullparam}).


-define(EVENT_ITEM_STRENGTHEN,5).	%%强化装备 paramlist 强化部位 当前等级 强化结果  消耗物品 物品数量  消耗货币 消耗绑定币 
-record(strengthen_param,{equiptype,level,result,decitem,number,money=0,money_b}).

-define(EVENT_ITEM_STRANGALL,6).	%%一键强化装备 paramlist 强化部位 当前等级 强化结果  消耗物品 物品数量  消耗货币 消耗绑定币 
-record(strengall_param,{equiptype,level,result,decitem,number,money=0,money_b}).

-define(EVENT_PLAYER_DEAD,7).	%%角色死亡 paramlist  凶手阵营     凶手ID 职业
-record(dead_param,{killertype,killerid,killercamp}).

-define(EVENT_PLAYER_RELIVE,8).	%%复活 paramlist 复活方式 1道具 0回城    
-record(relive_param,{type}).

-define(EVENT_PLAYER_TASK,9).	%%任务  paramlist 任务动作（接受,完成,放弃） 任务类型(主线 日常) 任务id
-record(task_param,{playeraction,tasktype,taskid}).

-define(EVENT_ITEM_CProperty,10). %%装备洗练 paramlist 洗练部位 消耗物品 数量 消耗货币 消耗绑定币
-record(ceproperty_param,{equiptype,decitem,number,money=0,money_b}).

-define(EVENT_ITEM_QUALITYUP,11). %%装备品质提升 paramlist 提升部位 当前品质 结果  消耗物品1 数量 消耗物品2 数量  消耗物品3 数量  消耗物品4 数量 消耗货币 消耗绑定币
-record(qualityup_param,{equiptype,quality,result,decitem1,number1,decitem2,number2,decitem3,number3,decitem4,number4,money=0,money_b}).

-define(EVENT_PET_WASHGROW,12).	%%宠物洗成长 paramlist 宠物baseid 消耗道具id 数量  消耗货币 消耗绑定币
-record(washgrow_param,{petbaseid,decitem,number,money=0,money_b}).

-define(EVENT_PET_STRENGTHEN,13).	%%宠物灵性强化 paramlist 强化部位 当前等级 强化结果 小步骤  消耗物品 物品数量  消耗货币 消耗绑定币 
-record(petstrengthen_param,{petbaseid,level,result,soule,decitem,number,money=0,money_b}).

-define(EVENT_PET_STRANGALL,14).	%%一键强化宠物灵性 paramlist 强化部位 当前等级 强化结果  消耗物品 物品数量  消耗货币 消耗绑定币 
-record(petstrengall_param,{petbaseid,level,result,soule,decitem,number,money=0,money_b}).

-define(EVENT_PET_SKILLAH,15).	%%宠物技能存放 paramlist 技能ID  消耗物品 物品数量 
-record(skillah_param,{skillbaseid,decitem,number}).

-define(EVENT_PET_REMOVE,16).	%%宠物放生 paramlist 宠物baseid
-record(petremove_param,{petbaseid}).

-define(EVENT_PALYER_CONBANK,17). %%交易行 paramlist 交易id 卖家id 消耗货币     系统手续费
-record(conbank_param,{tradid,sellerid,money,promoney,itemid,amount}).


-define(EVENT_PALYER_TRAD,18). %%交易行 paramlist 交易id 交易行为(出0/入1) 消耗货币 
-record(tard_param,{action,money}).

-define(EVENT_PALYER_COPY,19). %%副本 paramlist 状态1/0
-record(copy_param,{mapId,finishRate,costTime,level,isPerfect}).

-define(LOG_RECHARGE_NEW,0).
-define(LOG_RECHARGE_OK,1).

-define(LOG_GOLD_ADD,0).
-define(LOG_GOLD_DEC,1).

-record(token_param,{changetype,param0=1,param1=0,param2=0,param3=0,param4=0,param5=0}).
%% log_token_change
-record(log_token_change,{userid,playerid,level,money,money_b,gold,gold_b,exp,life,time,tokentype,relust,changetype,content,number}).
-define(Token_Type_Money_Bind,0).
-define(Token_Type_Money,1).
-define(Token_Type_Gold_Bind,2).
-define(Token_Type_Gold,3).

%% log_exp_change
-record(log_exp_change,{userid,playerid,level,money,money_b,gold,gold_b,exp,life,time,changetype,content,number}).
-record(exp_param,{changetype,param0=1,param1=0,param2=0,param3=0,param4=0,param5=0}).


%% log_item_change
-record(log_item_change,{userid,playerid,itemdataid,itemid,ownerid,cell,amount,binded,time,changetype,changereson,content}).
-define(OnPlayerItemAmountChanged,0).	%%	叠加数量改变
-define(OnPlayerItemDestoyed,1).		%%  消亡
-define(AddItemToPlayerByItemDataID,2). %%  新增加一个物品ID

-record( log_mail_change, {changetype, id, type, recvPlayerID, isOpened, tiemOut, idSender, nameSender, title, attachItemDBID1, attachItemDBID2, moneySend, moneyPay, mailTimerType ,mailRecTime} ).
-define(Mail_Change_Type_Add,0).		%%	新增邮件
-define(Mail_Change_Type_Open,1).		%%	打开邮件
-define(Mail_Change_Type_Rev,2).		%%	收取邮件
-define(Mail_Change_Type_Delete,3).		%%	删除邮件

-record( log_player_machine, {playerid, userid, platform, machine, timelogin, timelogout} ).
