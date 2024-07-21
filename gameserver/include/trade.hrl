

-record(tradeItem, {itemDBID, itemDB, count}).

%%一次最大交易物品的数量
-define(tradeItemMaxCount, 6).

%%交易请求失败
-define(tradeAskResult_Fail, 1).
%%交易请求成功
-define(tradeAskResult_Agree, 2).
%%交易请求拒绝
-define(tradeAskResult_notAgree, 3).
%%正忙
-define(tradeAskResult_busy, 4).
%%对方关闭了交易功能
%-define(tradeAskResult_targetCloseTradeFun, 4).

%%自己
-define(tradePerson_Self, 0).
%%对方
-define(tradePerson_Other, 1).
%%交易进程
-define(tradePerson_Trade, 2).

%%取消交易，原因为玩家主动取消
-define(tradeCancel_Player, 0).
%%取消交易，原因为交易进程等待超时
-define(tradeCancel_TimeOut, 1).
%%取消交易，原因为背包不足
-define(tradeCancel_PlayerBagNotEnough,2).
%%取消交易，原因为金钱不足
-define(tradeCancel_PlayerMoneyNotEnough,3).
%%取消交易，原因为物品不足
-define(tradeCancel_PlayerItemNotEnough,4).
%%取消交易，原因为玩家下线
-define(tradeCancel_PlayerOffLine,5).
%%取消交易，原因为未知
-define(tradeCancel_UnKnow,6).
%%取消交易，原因为交易以完成
-define(tradeCancel_Finish,7).
%%取消交易，因为关服了
-define(tradeCancel_ServerClose,8).

%%确认交易返回， 成功
-define(tradeAffirmAskResult_Success,0).
%%确认交易返回，失败（金钱不足）
-define(tradeAffirmAskResult_MoneyNotEnough,1).
%%确认交易返回，失败（背包空格不足）
-define(tradeAffirmAskResult_BagNotEnough,2).
%%确认交易返回，失败（自己物品不足）
-define(tradeAffirmAskResult_ItemNotEnough,3).


-define(createTrade_Fail, 0).
-define(createTrade_success, 1).

%%放入物品失败，不明原因
-define(putInItem_Fail_None, 0).
%%放入物品失败，交易栏已满
-define(putInItem_Fail_Full, 1).
%%放入物品失败，数量不足
-define(putInItem_Fail_Notenough, 2).
%%放入物品失败，物品不存在
-define(putInItem_Fail_NonExistent, 3).
%%放入物品成功
-define(putInItem_Success, 4).
%%放入物品失败，不能进行交易
-define(putInItem_Fail_CannotTrade, 5).