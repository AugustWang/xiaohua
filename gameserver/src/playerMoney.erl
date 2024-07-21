%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(playerMoney).

%%
%% Include files
%%
-include("db.hrl").
-include("playerDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("logdb.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

%%------------------------------------------------money------------------------------------------------
%%返回能否扣money
canDecPlayerMoney( DecMoney )->
	case DecMoney < 0 of
		true->false;
		_->
			player:getCurPlayerProperty( #player.money ) >= DecMoney
	end.


%%扣Money
decPlayerMoney( DecMoney, Reson ,ParamTuple)->
	try
		Player = player:getCurPlayerRecord(),
		case Player of
			{}->throw(-1);
			_->
				case Player#player.money >= DecMoney of
					false->throw(-1);
					true->
						player:setCurPlayerProperty(#player.money, Player#player.money - DecMoney),
						player:send( #pk_PlayerMoneyChanged{ changeReson=Reson, moneyType=?Money_Money, moneyValue=Player#player.money - DecMoney } ),
						%% LOG TokenChange				
						case ParamTuple#token_param.param0 of
							1->logdbProcess:write_log_token_change(?Token_Type_Money,0,Reson,ParamTuple,DecMoney,Player);
							_->ok
						end
				end
		end,
		true
	catch
		_->false
	end.

%%增加Money
addPlayerMoney( AddMoney, Reson ,ParamTuple)->
	try
		put( "addPlayerMoney_P1", 0 ),
		Player = player:getCurPlayerRecord(),
		case Player of
			{}->throw(-1);
			_->
				case AddMoney > ?Max_Money of
					true->throw(-1);
					false->ok
				end,

				NewMoney = Player#player.money + AddMoney,
				put( "addPlayerMoney_P2", NewMoney ),
				
				case NewMoney > ?Max_Money of
					true->put( "addPlayerMoney_P2", ?Max_Money );
					false->ok
				end,
				case NewMoney < 0 of
					true->put( "addPlayerMoney_P2", 0 );
					false->ok
				end,
				
				NewMoney2 = get( "addPlayerMoney_P2" ),
				player:setCurPlayerProperty(#player.money, NewMoney2),
				player:send( #pk_PlayerMoneyChanged{ changeReson=Reson, moneyType=?Money_Money, moneyValue=NewMoney2 } ),
				
				%% LOG TokenChange				
				case ParamTuple#token_param.param0 of
					1->logdbProcess:write_log_token_change(?Token_Type_Money,1,Reson,ParamTuple,AddMoney,Player);
					_->ok
				end,

				NewMoney2
		end
	catch
		_->get( "addPlayerMoney_P1" )
	end.

%%返回能否增加绑定Money
canAddPlayerBindedMoney( AddBindedMoney )->
	Player = player:getCurPlayerRecord(),
	case Player of
		{}->false;
		_->
			case Player#player.moneyBinded+AddBindedMoney > ?Max_Money of
				true->false;
				false->true
			end
	end.

%%增加BindedMoney
addPlayerBindedMoney( AddMoney, Reson, ParamTuple )->
	try
		put( "addPlayerBindedMoney_P1", 0 ),
		Player = player:getCurPlayerRecord(),
		case Player of
			{}->throw(-1);
			_->
				case AddMoney > ?Max_Money of
					true->throw(-1);
					false->ok
				end,

				NewMoney = Player#player.moneyBinded + AddMoney,
				put( "addPlayerBindedMoney__P2", NewMoney ),
				
				case NewMoney > ?Max_Money of
					true->put( "addPlayerBindedMoney__P2", ?Max_Money );
					false->ok
				end,
				case NewMoney < 0 of
					true->put( "addPlayerBindedMoney__P2", 0 );
					false->ok
				end,
				
				NewMoney2 = get( "addPlayerBindedMoney__P2" ),
				player:setCurPlayerProperty(#player.moneyBinded, NewMoney2),
				player:send( #pk_PlayerMoneyChanged{ changeReson=Reson, moneyType=?Money_BindedMoney, moneyValue=NewMoney2 } ),
				
				
				%% LOG TokenChange				
				case ParamTuple#token_param.param0 of
					1->logdbProcess:write_log_token_change(?Token_Type_Money_Bind,1,Reson,ParamTuple,AddMoney,Player);
					_->ok
				end,
				
				
				NewMoney2
		end
	catch
		_->get( "addPlayerBindedMoney_P1" )
	end.

%%返回能否使用绑定money，如果绑定money不够，会自动检测使用money
canUsePlayerBindedMoney( UseMoney )->
	Player = player:getCurPlayerRecord(),
	case Player of
		{}->false;
		_->
			case UseMoney < 0 of
				true->false;
				_->
					case Player#player.moneyBinded >= UseMoney of
						true->true;
						false->
							case Player#player.moneyBinded + Player#player.money >= UseMoney of
								true->true;
								false->false
							end
					end
			end
	end.

%%使用绑定money
usePlayerBindedMoney( UseMoney, Reson ,ParamTuple)->
	try
		Player = player:getCurPlayerRecord(),
		case Player of
			{}->throw(-1);
			_->ok
		end,
		
		put( "usePlayerBindedMoney_P1", 0 ),
		put( "usePlayerBindedMoney_P2", 0 ),
		
		case Player#player.moneyBinded >= UseMoney of
			true->put( "usePlayerBindedMoney_P1", UseMoney );
			false->
					case Player#player.moneyBinded + Player#player.money >= UseMoney of
						true->
							put( "usePlayerBindedMoney_P1", Player#player.moneyBinded ),
							put( "usePlayerBindedMoney_P2", UseMoney - Player#player.moneyBinded );
						false->throw(-1)
					end
		end,
		
		DecBindedMoney = get( "usePlayerBindedMoney_P1" ),
		DecMoney = get( "usePlayerBindedMoney_P2" ),
		case DecMoney > 0 of
			true->
					player:setCurPlayerProperty(#player.money, Player#player.money - DecMoney),
					player:send( #pk_PlayerMoneyChanged{ changeReson=Reson, moneyType=?Money_Money, moneyValue=Player#player.money - DecMoney } ),
					%% LOG TokenChange				
					case ParamTuple#token_param.param0 of
						1->logdbProcess:write_log_token_change(?Token_Type_Money,0,Reson,ParamTuple,DecMoney,Player);
						_->ok
					end;
			false->ok
		end,

		case DecBindedMoney > 0 of
			true->
					player:setCurPlayerProperty(#player.moneyBinded, Player#player.moneyBinded - DecBindedMoney),
					player:send( #pk_PlayerMoneyChanged{ changeReson=Reson, moneyType=?Money_BindedMoney, moneyValue=Player#player.moneyBinded - DecBindedMoney } ),
					%% LOG TokenChange				
					case ParamTuple#token_param.param0 of
						1->logdbProcess:write_log_token_change(?Token_Type_Money_Bind,0,Reson,ParamTuple,DecBindedMoney,Player);
						_->ok
					end;
			false->ok
		end,	
		

		true
	catch
		_->false
	end.

%%返回能否扣绑定money
canDecPlayerBindedMoney( DecMoney )->
	Player = player:getCurPlayerRecord(),
	case Player of
		{}->false;
		_->
			case DecMoney < 0 of
				true->false;
				_->
					case Player#player.moneyBinded >= DecMoney of
						true->true;
						false->false
					end
			end
	end.


%%扣绑定Money
decPlayerBindedMoney( DecMoney, Reson, ParamTuple )->
	try
		Player = player:getCurPlayerRecord(),
		case Player of
			{}->throw(-1);
			_->
				case Player#player.moneyBinded >= DecMoney of
					false->throw(-1);
					true->
						player:setCurPlayerProperty(#player.moneyBinded, Player#player.moneyBinded - DecMoney),
						player:send( #pk_PlayerMoneyChanged{ changeReson=Reson, moneyType=?Money_BindedMoney, moneyValue=Player#player.moneyBinded - DecMoney } ),
						case ParamTuple#token_param.param0 of
							1->logdbProcess:write_log_token_change(?Token_Type_Money_Bind,0,Reson,ParamTuple,DecMoney,Player);
							_->ok
						end
				end
		end,
		true
	catch
		_->false
	end.

%%绑定元宝与非绑定元宝一起算，1元宝=1绑定元宝，
getPlayerGoldAndBindGold()->
TotalGold=getPlayerGold()+getPlayerBindedGold(),
TotalGold.

%%能否扣除一定数量的绑定元宝+元宝 1元宝=1绑定元宝，
canDecPlayerGoldAndBindGold(DecGold)->
	case DecGold < 0 of
		true->false;
		_->
			Result=getPlayerGoldAndBindGold()>=DecGold,
			Result
	end.

%%扣除元宝+绑定元宝，优先扣除绑定元宝 1元宝=1绑定元宝， 采用尽力扣除的方式,不够的情况下能扣多少算多少
decPlayerGoldAndBindGold(TotalDecGold,Reson, ParamTuple)->
		BindGold=getPlayerBindedGold(),
		case BindGold>=TotalDecGold of
			true->
				DecBindGold=TotalDecGold,
				DecGold=0;
			false->
				DecBindGold=BindGold,
				DecGold=TotalDecGold-BindGold
		end,
		case DecBindGold>0 of
			true->
				case canDecPlayerBindedGold(DecBindGold) of
					true->
						decPlayerBindedGold(DecBindGold,Reson, ParamTuple);
					false->
						ok		
				end;
			false->
				ok
		end,
		case DecGold>0 of
			true->
				case canDecPlayerGold(DecGold) of
					true->
						decPlayerGold(DecGold,Reson, ParamTuple);
					false->
						ok		
				end;
			false->
				ok
		end.

decPlayerMoneyAndBindMoney(TotalDecMoney, Reson, ParamTuple)->
	try
		Player = player:getCurPlayerRecord(),
		PlayBagMoney = Player#player.money,
		PlayBagBindMoney = Player#player.moneyBinded,
		case PlayBagBindMoney >= TotalDecMoney of
			true -> 
				playerMoney:decPlayerBindedMoney(TotalDecMoney, Reson, ParamTuple),
				true; %%绑定铜币足够
			false ->
				case PlayBagMoney+PlayBagBindMoney >= TotalDecMoney of
					true ->
						playerMoney:decPlayerBindedMoney(PlayBagBindMoney, Reson, ParamTuple), %%先扣除绑定铜币
						RemainCostMoney = TotalDecMoney-PlayBagBindMoney, %%再扣除普通铜币
						playerMoney:decPlayerMoney(RemainCostMoney, Reson, ParamTuple); %%普通铜币足够
					false -> throw(-1)
				end
		end,
		true
	catch
		_ ->false
	end.

%%带检测的 扣除绑定元宝+元宝 1绑定元宝=1元宝，成功返回true 失败返回false
decPlayerGoldAndBindGoldWithCheck(TotalDecGold,Reson, ParamTuple)->
	case getPlayerGoldAndBindGold()>= TotalDecGold of
		true->
			Result=true,
			decPlayerGoldAndBindGold(TotalDecGold,Reson, ParamTuple);
		false->
			Result=false
	end,
	Result.

%%获取玩家金币数量
getPlayerGold()->
	Player = player:getCurPlayerRecord(),
	case Player of
		{}->0;
		_->Player#player.gold
	end.

%%返回能否增加金币
canAddPlayerGold( AddGold )->
	Player = player:getCurPlayerRecord(),
	case Player of
		{}->false;
		_->
			case Player#player.gold+AddGold > ?Max_Money of
				true->false;
				false->true
			end
	end.

%%返回能否扣除gold
canDecPlayerGold( DecGold )->
	Player = player:getCurPlayerRecord(),
	case Player of
		{}->false;
		_->
			case DecGold < 0 of
				true->false;
				_->
					case Player#player.gold >= DecGold of
						true->true;
						false->false
					end
			end
	end.

%%刷新玩家金币数量
refreshPlayerGold(Reason)->
	Player = player:getCurPlayerRecord(),
	case Player of
		{}->0;
		_->
			case mySqlProcess:getGoldAndRechargeAmmountByPlayerID(Player#player.id) of
				{error,_}->0;
				{ok,{Gold,RechargeAmmount}}->
					case Gold =:= #player.gold of
						true->ok;
						false->
							player:setCurPlayerProperty(#player.gold, Gold),
							player:send(#pk_PlayerMoneyChanged{changeReson=Reason,moneyType=?Money_Gold, moneyValue=Gold})
					end,
					case RechargeAmmount =:= #player.rechargeAmmount of
						true->ok;
						false->
							player:setCurPlayerProperty(#player.rechargeAmmount, RechargeAmmount),
							player:send(#pk_PlayerMoneyChanged{changeReson=Reason,moneyType=?Money_RechargeAmmount, moneyValue=RechargeAmmount})
					end,
					Gold
			end
	end.
	

%%扣除玩家gold
decPlayerGold( DecGold, Reson, _ )->
	Player = player:getCurPlayerRecord(),
	PlayerID = Player#player.id,
	Gold_Old=Player#player.gold,
	Gold_Mod=DecGold,
	case Player of
		{}->fail;
		_->
			case Player#player.gold >= DecGold of
				false->fail;
				true->
					case mySqlProcess:reduceGoldByPlayerID(PlayerID,Gold_Mod) of
						{error,_}->fail;
						{ok,_}->
							refreshPlayerGold(Reson),
							Gold_New=getPlayerGold(), %% 写入日志
							logdbProcess:write_log_gold_dec(PlayerID,Gold_Old,Gold_Mod,Gold_New,Reson,"decPlayerGold")
					end
			end
	end.

%%增加玩家gold
addPlayerGold( AddMoney, Reson, _ )->
	Player = player:getCurPlayerRecord(),
	PlayerID = Player#player.id,
	Gold_Old=Player#player.gold,
	Gold_Mod=AddMoney,
	case Player of
		{}->fail;
		_->
			case Gold_Old + Gold_Mod =< ?Max_Money of
				false->fail;
				true->
					case mySqlProcess:addGoldByPlayerID(PlayerID,Gold_Mod) of
						{error,_}->fail;
						{ok,_}->
							refreshPlayerGold(Reson),
							Gold_New=getPlayerGold(), %% 写入日志
							logdbProcess:write_log_gold_add(PlayerID,Gold_Old,Gold_Mod,Gold_New,Reson,"addPlayerGold")
					end
			end
	end.

%%获取玩家绑定金币数量
getPlayerBindedGold()->
	Player = player:getCurPlayerRecord(),
	case Player of
		{}->0;
		_->Player#player.goldBinded
	end.

%%返回能否扣绑定gold
canDecPlayerBindedGold( DecGold )->
	Player = player:getCurPlayerRecord(),
	case Player of
		{}->false;
		_->
			case DecGold < 0 of
				true->false;
				_->
					case Player#player.goldBinded >= DecGold of
						true->true;
						false->false
					end
			end
	end.

%%扣绑定gold
decPlayerBindedGold( DecGold, Reson, ParamTuple )->
	try
		Player = player:getCurPlayerRecord(),
		case Player of
			{}->throw(-1);
			_->
				case Player#player.goldBinded >= DecGold of
					false->throw(-1);
					true->
						
						player:setCurPlayerProperty(#player.goldBinded, Player#player.goldBinded - DecGold),
						player:send( #pk_PlayerMoneyChanged{ changeReson=Reson, moneyType=?Money_BindedGold, moneyValue=Player#player.goldBinded - DecGold } ),
						%% LOG TokenChange				
						case ParamTuple#token_param.param0 of
							1->logdbProcess:write_log_token_change(?Token_Type_Gold_Bind,0,Reson,ParamTuple,DecGold,Player);
							_->ok
						end
				end
			end,
		true
	catch
		_->false
	end.

%%增加绑定gold
addPlayerBindedGold( AddMoney, Reson, ParamTuple )->
	try
		put( "addPlayerBindedGold_P1", 0 ),
		Player = player:getCurPlayerRecord(),
		case Player of
			{}->throw(-1);
			_->
				case AddMoney > ?Max_Money of
					true->throw(-1);
					false->ok
				end,

				NewMoney = Player#player.goldBinded + AddMoney,
				put( "addPlayerBindedGold__P2", NewMoney ),
				
				case NewMoney > ?Max_Money of
					true->put( "addPlayerBindedGold__P2", ?Max_Money );
					false->ok
				end,
				case NewMoney < 0 of
					true->put( "addPlayerBindedGold__P2", 0 );
					false->ok
				end,
				NewMoney2 = get( "addPlayerBindedGold__P2" ),
				player:setCurPlayerProperty(#player.goldBinded, NewMoney2),
				player:send( #pk_PlayerMoneyChanged{ changeReson=Reson, moneyType=?Money_BindedGold, moneyValue=NewMoney2 } ),
				
				%% LOG TokenChange				
				case ParamTuple#token_param.param0 of
					1->logdbProcess:write_log_token_change(?Token_Type_Gold_Bind,1,Reson,ParamTuple,AddMoney,Player);
					_->ok
				end,
				
				NewMoney2
		end
	catch
		_->get( "addPlayerBindedGold_P1" )
	end.

