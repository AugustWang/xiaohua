%% Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(battleMap).

-include("db.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("monsterDefine.hrl").
-include("scriptDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 

%%战场ID生成，32=0，31=1表示红方，=0表示蓝方，1--30表示ID值
makeBattleID( RedOrBlue, ID )->
	case RedOrBlue of
		true->RedOrBlue_Value = 1;
		false->RedOrBlue_Value = 0
	end,
	%%1073741823=0x3FFFFFFF
	Value = ( RedOrBlue_Value bsl 31 ) bor ( 1073741823 band ID ),
	Value.

%%返回是否两个是同一战场
isSameBattle( LeftBattleID, RightBattleID )->
	( LeftBattleID /= 0 ) andalso ( RightBattleID /= 0) andalso
	( (1073741823 band LeftBattleID) =:= (1073741823 band RightBattleID) ).

%%返回是否两个是同一战场的同一方
isBattleFriend( LeftBattleID, RightBattleID )->
	%%1073741824 = 0x40000000
	( isSameBattle( LeftBattleID, RightBattleID ) ) andalso
	( ( 1073741824 band LeftBattleID ) =:= ( 1073741824 band RightBattleID ) ).

%%返回是否两个是同一战场的敌对方
isBattleEnemy( LeftBattleID, RightBattleID )->
	%%1073741824 = 0x40000000
	( isSameBattle( LeftBattleID, RightBattleID ) ) andalso
	( ( 1073741824 band LeftBattleID ) /= ( 1073741824 band RightBattleID ) ).

