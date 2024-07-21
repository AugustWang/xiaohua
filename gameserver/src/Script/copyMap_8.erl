%% Author: niko
%% Created: 2012-8-3
%% Description: TODO: Add description to monster
-module(copyMap_8).

-include("db.hrl").
-include("package.hrl").
-include("mapDefine.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("monsterDefine.hrl").
-include("scriptDefine.hrl").

-compile(export_all). 



%% 世界boss 副本 




init()->
	%% 注意此函数的执行与副本进程不是在同一进程 
	BossInfo=worldBoss:getBossInfo(),
	BossConfigList=ets:tab2list('globleBossCfgTable'),
	RegisterFun=fun(#worldBossCfg{mapid=MapID}=_Cfg)->
					scriptManager:registerScript( ?Object_Type_Map, MapID, ?Map_Event_Init, ?MODULE, map_8_Map_Event_Init, MapID )
				end,
	lists:foreach(RegisterFun, BossConfigList),
	
	

	%%注册事件
	scriptManager:registerScript( ?Object_Type_Monster, BossInfo#worldBossCfg.bossid,
								   ?Monster_Event_Init, ?MODULE, copyMap_8__Boss_Come_Init, 0 ),
	scriptManager:registerScript( ?Object_Type_Monster, BossInfo#worldBossCfg.bossid,
								   ?Char_Event_OnDamage, ?MODULE, copyMap_8__Boss_Blood_Change_Event_Init, 0 ),
	scriptManager:registerScript( ?Object_Type_Monster, BossInfo#worldBossCfg.bossid,
								   ?Char_Event_Dead, ?MODULE, copyMap_8__Boss_Dead_Event, 0 ),
	%%计算第一波小怪的死亡
	scriptManager:registerScript( ?Object_Type_Monster, BossInfo#worldBossCfg.incident1,
								   ?Char_Event_Dead, ?MODULE, copyMap_8__SmallMonster_Dead_Event, 0 ),
	%%玩家进入地图
	%%scriptManager:registerScript( ?Object_Type_Player, ?Global_Object_Player,
	%%							   ?Char_Event_Enter_Map, ?MODULE, copyMap_8_Player_EnterMap, 0 ),
	?DEBUG_OUT( "map_8_Map_Event_Init init"),

	ok.
map_8_Map_Event_Init( _Object, _EventParam, _RegParam )->
	
	objectEvent:registerObjectEvent(_Object, 
									?Map_Event_Player_Enter, 
									?Object_Type_Map, 
									_RegParam, 
									?MODULE, 
									copyMap_8_Player_EnterMap, 0),
	ok.
%%boss 第一次出来
copyMap_8__Boss_Come_Init( _Object, _EventParam, _RegParam )->
	put("SmallMonster1Come",false),
	put("SmallMonster2Come",false),
	put( "copyMap_8_SmallMonster",[] ),
	
ok.
%%回调函数
copyMap_8__Boss_Blood_Change_Event_Init( Object, _EventParam, _RegParam )->
	copyMap_8__Boss_Blood_10( Object, _EventParam, _RegParam ),
	copyMap_8__Boss_Blood_50( Object, _EventParam, _RegParam ).

%%boss 死亡，杀掉小怪
copyMap_8__Boss_Dead_Event( _Object, _EventParam, _RegParam )->
	Monsters = get( "copyMap_8_SmallMonster" ),
	MyFunc = fun( Record )->
					 Monster = map:getMapObjectByID( Record ),
					 case Monster of
						 {}->
							 Monsters2 = get( "copyMap_8_SmallMonster" ),
							 Monsters3 = Monsters2 -- [Record],
							 put( "copyMap_8_SmallMonster", Monsters3 );
						 _->
							 map:despellObject(Monster#mapMonster.id, 0)
					 end
			 end,
	lists:foreach( MyFunc, Monsters ),
	ok.

copyMap_8__SmallMonster_Dead_Event( _Object, _EventParam, _RegParam )->
	put("MapLeftSmallMonsterNum",get("MapLeftSmallMonsterNum")-1),
	case get("MapLeftSmallMonsterNum")=:=0 of
		true->
			worldBossManagerPID!{firstStageAllMonsterKill,self()},
			sendFirstStageLeftSmallMonsterNum(0);
		false->
			BossInfo=worldBoss:getBossInfo(),
			erlang:send_after(BossInfo#worldBossCfg.refreshtime*1000, self(),{worldBossSmallMonsterReborn,_Object}),
			sendFirstStageLeftSmallMonsterNum( get("MapLeftSmallMonsterNum") ),
			ok
	end,
	ok.

copyMap_8_Player_EnterMap( Object, _EventParam, _RegParam )->
	?DEBUG_OUT( "copyMap_8_Player_EnterMap"),
	case element( 1, _EventParam ) of
		mapPlayer->
					SendMonsterNum=#pk_GS2U_LeftSmallMonsterNumber{leftMonsterNum=get("MapLeftSmallMonsterNum") },
					player:sendToPlayer(_EventParam#mapPlayer.id,SendMonsterNum ),
					ok;
		_->
			ok
	end,
	ok.

sendFirstStageLeftSmallMonsterNum(LeftNum)->
	SendMonsterNum=#pk_GS2U_LeftSmallMonsterNumber{leftMonsterNum=LeftNum},
	FunPlayer = fun(Player) ->
						player:sendToPlayer(Player#mapPlayer.id, SendMonsterNum)
				end,
	etsBaseFunc:etsFor(map:getMapPlayerTable(), FunPlayer),
	ok.

%%世界boss 血量降低到10%
copyMap_8__Boss_Blood_10( Object, _EventParam, _RegParam )->
	%%检查配置是否一致
 	case get("SmallMonster2Come") of
		true->
			ok;
		false->
%%			MonsterDataID = Object#mapMonster.monster_data_id,
			MonsterBloodMax= array:get( ?max_life, Object#mapMonster.finalProperty),
			BossInfo=worldBoss:getBossInfo(),
			MonsterBlood=Object#mapMonster.life,
			BlooaPercent=MonsterBlood*100 div MonsterBloodMax,
			case BlooaPercent <BossInfo#worldBossCfg.bossblood3 of
				true->
					%%刷小怪
					put("SmallMonster2Come",true),
					
					%%生成小怪
					FunBormMonster=fun(_N)->
										BornPos=lists:nth(random:uniform(length(BossInfo#worldBossCfg.resfreshxy1)), BossInfo#worldBossCfg.resfreshxy1),   
										on_Refresh(BossInfo#worldBossCfg.incident3,BornPos,
							   				1)
								   end,
					case BossInfo#worldBossCfg.incnum2>1 of
						true->
							common:for(1, BossInfo#worldBossCfg.incnum3, FunBormMonster);
						false->
							ok
					end,
					
					ok;
				false->
					ok
			end
	end.

%%世界boss 血量降低到50%
copyMap_8__Boss_Blood_50( Object, _EventParam, _RegParam )->
	%%?DEBUG_OUT( "copyMap_8__Boss_Blood_10_Event_Init 50"),
	%%检查配置是否一致
 	case get("SmallMonster1Come") of
		true->
			ok;
		false->
			
%%			MonsterDataID = Object#mapMonster.monster_data_id,
			MonsterBloodMax= array:get( ?max_life, Object#mapMonster.finalProperty),
			MonsterBlood=Object#mapMonster.life,
			BossInfo=worldBoss:getBossInfo(),
			BlooaPercent=MonsterBlood*100 div MonsterBloodMax,
			case BlooaPercent <BossInfo#worldBossCfg.bossblood2 of
				true->
					%%刷小怪
					put("SmallMonster1Come",true),
					
					%%生成小怪
					FunBormMonster=fun(_N)->
										BornPos=lists:nth(random:uniform(length(BossInfo#worldBossCfg.resfreshxy1)), BossInfo#worldBossCfg.resfreshxy1),   
										on_Refresh(BossInfo#worldBossCfg.incident2,BornPos,
							   				1)
								   end,
					case BossInfo#worldBossCfg.incnum2>1 of
						true->
							common:for(1, BossInfo#worldBossCfg.incnum2, FunBormMonster);
						false->
							ok
					end,
					ok;
				false->
					ok
			end
	end.

on_Refresh(MonsterID,TargetPos,MonsterNum)->
	RefreshWorldBossMonster=
		fun(_N)->
				
				MapSpawn = #mapSpawn{
				id = 0,
				 mapId=map:getMapDataID(),
				 type=?Object_Type_Monster,
				 typeId = MonsterID,
				 x = TargetPos#posInfo.x,
				 y = TargetPos#posInfo.x,
				 param = 0,
				 isExist = true
				},
				Monster = monster:createMonster( MapSpawn ),
				map:enterMapMonster(Monster),
				
				Monsters2 = get( "copyMap_8_SmallMonster" ),
				Monsters3 = Monsters2 ++ [Monster#mapMonster.id],
				put( "copyMap_8_SmallMonster", Monsters3 ),
				%%设置移动
				monster:moveAttackFollow(Monster, TargetPos, 5),
				ok
		end,
	common:for(1, MonsterNum, RefreshWorldBossMonster),
ok.
					