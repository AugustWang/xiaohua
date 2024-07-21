

%%商城栏位类型
-define( BazzarColumn_Favorable_Price, 0).	%%优惠
-define( BazzarColumn_NormalItem, 1).			%%常用道具
-define( BazzarColumn_Pet_Ride, 2).				%%宠物坐骑
-define( BazzarColumn_Strengthen, 3).			%%装备强化
-define( BazzarColumn_YuanBaoKa, 4).			%%元宝卡
-define( BazzarColumn_RandomPrice, 5).		%%随机优惠的道具
-define( BazzarColumn_Count, 5).					%%栏位总数



%%购买物品返回值
-define( Bazzar_Buy_Return_Succ,  0).					%%购买成功
-define( Bazzar_Buy_Return_NotItem,  -1).			%%购买失败，物品已下架
-define( Bazzar_Buy_Return_TimeOut,  -2).			%%购买失败，物品已到期
-define( Bazzar_Buy_Return_NotEnough,  -3).		%%购买失败，物品剩余数量不足
-define( Bazzar_Buy_Return_NotBindGold,  -4).	%%购买失败，不能通过绑定元宝购买
-define( Bazzar_Buy_Return_BagFull,  -5).			%%购买失败，背包已满
-define( Bazzar_Buy_Return_BindGold_NotEnough,  -6).			%%购买失败，绑定元宝不足
-define( Bazzar_Buy_Return_Gold_NotEnough,  -7).			%%购买失败，元宝不足
-define( Bazzar_Buy_Return_ItemMax,  -8).			%%购买失败，数量超过每次最大的购买量
-define( Bazzar_Buy_Return_GoldPassWord,  -9).			%%密码错误

%%检查刷新的时间
-define( Bazzar_CheckUpdateTime, 300000 ).

