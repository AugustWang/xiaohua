

%%上架数据
-record(groundingItem, {itemDB, itemCfg, count, money, timeType, playerId, playerName}).

%%查找选项 （偏移数量，类型，最小等级，最大等级，职业，品质，关键字）
-record(findOption, {ignoreOption, offsetCount, type, detType, levelMin, levelMax, occ, quality, idLimit, idList}).

%%玩家出售订单列表
-record(playerOrderTable, {playerId, orderList}).

%%计时数据
-record(itemTimer, {startTime, dataID}).

%%购买超时时间
-define(buyConSalesOvertime, 5).

%%查找冷却时间
-define(conBank_Find_Colding_Time, 5).
%%查找返回
-define(conBank_Find_Succ, 0).
-define(conBank_Find_Failed_Colding, 1).
-define(conBank_Find_Failed_CannotTrunPage, 2).

%%更新订单时间，
-define(ConBank_UpdateTimer_Time, 60*1000).

%%
-define(conSales_delete_Reason_timeOut, 0). %%寄售时间到了
-define(conSales_delete_Reason_takeDown, 1). %%玩家下架
-define(conSales_delete_Reason_buy, 2). %%被购买

%%寄售时间类型
-define(ConSales_SellTime_Type_8H, 0). 
-define(ConSales_SellTime_Type_12H, 1).
-define(ConSales_SellTime_Type_24H, 2).

%%时间值（秒）
-define(ConSales_Time_8H, 8*60*60).
-define(ConSales_Time_12H, 12*60*60).
-define(ConSales_Time_24H, 24*60*60).

%%下架保护时间
-define(TakeDown_Protect_Time, 600).

%%寄售收费
-define(Bank_LookMoney_8H, 0.01).	%%保管费4%
-define(Bank_LookMoney_12H, 0.015).	%%保管费5%
-define(Bank_LookMoney_24H, 0.02).	%%保管费6%
%%交易税
-define(BankTrade_Money, 0.01).

%%每次发送给客户端的最大订单数量
-define(sendToPlayerMaxOrderCount, 12).

%%上架返回
-define(Grounding_Result_Succ, 0).
-define(Grounding_Result_Failed_NoItem, 1).
-define(Grounding_Result_Failed_CountError, 2).
-define(Grounding_Result_Failed_MoneyError, 3).
-define(Grounding_Result_Failed_MoneyNotEnough, 4).
-define(Grounding_Result_Filed_Full, 5).

%%购买返回
-define(ConBank_Buy_Succ, 0). %%购买成功
-define(ConBank_Buy_Failed_Other, 1). %%正在被别人购买
-define(ConBank_Buy_Failed_MoneyNotEnough, 2). %%金钱不足

%%下架返回
-define(ConBank_TakeDown_Succ, 0).  %%下架成功
-define(ConBank_TakeDown_Buying, 1). %%下架失败，正在被购买中
-define(ConBank_TakeDown_AlreadySell, 2). %%下架失败，已经被买走
-define(ConBank_TakeDown_NotSeller, 3). %%下架失败，不是本订单的卖家
-define(ConBank_TakeDown_ProtectTime, 4). %%下架失败，还在下架保护时间

%%翻页方式
-define(TrunPage_Mode_Front, 0). %%上一页
-define(TrunPage_Mode_Next, 1).	 %%下一页


