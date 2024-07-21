%% 排名类型
-define(TOP_TYPE_PLAYER_LEVEL,1).
-define(TOP_TYPE_PLAYER_MONEY,2).
-define(TOP_TYPE_PLAYER_FIGHTING_CAPACITY,3).

%% 排名相关
-record(top_record,{toptype,toplist}).
-record(top_player_level,{top,playerid,name,camp,level,fightingcapacity,sex,weapon,coat}).
-record(top_player_money,{top,playerid,name,camp,level,money,sex,weapon,coat}).
-record(top_player_fighting_capacity,{top,playerid,name,camp,level,fightingcapacity,sex,weapon,coat}).

%% 排名前50，用于显示
-define(TOP_PLAYER_LEVEL_LOAD_LIMIT,50).
-define(TOP_PLAYER_MONEY_LOAD_LIMIT,50).
-define(TOP_PLAYER_FIGHTING_CAPACITY_LOAD_LIMIT,50).

%% 排名数量限制
-define(TOP_PLAYER_LEVEL_LIMIT,100).
-define(TOP_PLAYER_MONEY_LIMIT,100).
-define(TOP_PLAYER_FIGHTING_CAPACITY_LIMIT,100).

%% 排名资格
-define(TOP_PLAYER_LEVEL_NEED,20).
-define(TOP_PLAYER_MONEY_NEED,100000).
-define(TOP_PLAYER_FIGHTING_CAPACITY_NEED,999).

