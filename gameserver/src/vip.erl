%% Author: yueliangyou
%% Created: 2013-5-7
%% Description: TODO: vip function
-module(vip).

%%
%% Include files
%%
-include("db.hrl").
-include("playerDefine.hrl").
-include("vipDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("logdb.hrl").

%% 通过VIP购买时长计算VIP等级	
getVipLevelByTime(Time)->
	LevelInfo = [	{0,?VIP_LEVEL_NONE},
			{3*24*3600,?VIP_LEVEL_TRIAL},
			{30*24*3600,?VIP_LEVEL_BRONZE},
			{90*24*3600,?VIP_LEVEL_SILVER},
			{180*24*3600,?VIP_LEVEL_GOLD},
			{360*24*3600,?VIP_LEVEL_DIAMOND}],

	put("LevelByTime",?VIP_LEVEL_NONE),
	Fun = fun(X)->
		{T,L}=X,
		case Time >= T of
			true->put("LevelByTime",L);
			false->ok
		end
	end,
	lists:foreach(Fun,LevelInfo),
	get("LevelByTime").

%% 此函数不需要了
getVipCardTime(Type)->
	CardInfo = [	{?VIP_CARD_TRIAL,3*24*3600},
			{?VIP_CARD_10,10*24*3600},
			{?VIP_CARD_30,30*24*3600},
			{?VIP_CARD_180,180*24*3600},
			{?VIP_CARD_360,360*24*3600}],
	Result  = lists:keysearch(Type,1,CardInfo),
	case Result of
		false->0;
		true->{_,T}=Result,T
	end.
%%
%% Exported Functions
%%
-compile(export_all).

%% 加载玩家的VIP信息
loadVipInfo(Level,Expire,Buy)->
	?DEBUG_OUT("loadVipInfo Level=~p,Expire=~p,Buy=~p",[Level,Expire,Buy]),
	put("VipInfo",#vipInfo{level=Level,timeExpire=Expire,timeBuy=Buy}),
	sendVipInfo().

%% 是否是VIP玩家
isVipPlayer()->
	case isVipExpire() of
		true->false;
		false->getVipLevel() > ?VIP_LEVEL_NONE
	end.

%% 获取VIP信息
getVipInfo()->
	VipInfo = get("VipInfo"),
	{VipInfo#vipInfo.level,VipInfo#vipInfo.timeExpire,VipInfo#vipInfo.timeBuy}.

%% 获取VIP信息
getVipInfoEx(PlayerID)->
	ProcessID = player:getPlayerPID(PlayerID),
	try
        	gen_server:call(ProcessID,{'getVipInfo'})
	catch
		_:_->{0,0,0}
	end.

%% 获取VIP等级
getVipLevel()->
	{Level,_,_} = getVipInfo(),
	Level.		

%% 获取VIP名称
getVipName(Level)->
	case Level of
		?VIP_LEVEL_NONE->"非VIP";
		?VIP_LEVEL_TRIAL->"试用VIP";
		?VIP_LEVEL_BRONZE->"青铜VIP";
		?VIP_LEVEL_SILVER->"白银VIP";
		?VIP_LEVEL_GOLD->"黄金VIP";
		?VIP_LEVEL_DIAMOND->"钻石VIP";
		_->""
	end.
%% 获取VIP名称
getVipName()->
	case getVipLevel() of
		?VIP_LEVEL_NONE->"非VIP";
		?VIP_LEVEL_TRIAL->"试用VIP";
		?VIP_LEVEL_BRONZE->"青铜VIP";
		?VIP_LEVEL_SILVER->"白银VIP";
		?VIP_LEVEL_GOLD->"黄金VIP";
		?VIP_LEVEL_DIAMOND->"钻石VIP";
		_->""
	end.

getVipTimeExpire()->
	{_,TimeExpire,_} = getVipInfo(),
	TimeExpire.		

getVipTimeBuy()->
	{_,_,TimeBuy} = getVipInfo(),
	TimeBuy.		

%% 获取VIP有效时长
getVipValidTime()->
	getVipTimeExpire()-common:getNowSeconds().

%% 检查VIP是否过期
isVipExpire()->
	?DEBUG_OUT("Now=~p,Expire=~p,Result=~p",[common:getNowSeconds(),getVipTimeExpire(),common:getNowSeconds() > getVipTimeExpire()]),
	common:getNowSeconds() > getVipTimeExpire().

%% 设置VIP信息
setVipInfo(Level,TimeExpire,TimeBuy)->
	put("VipInfo",#vipInfo{level=Level,timeExpire=TimeExpire,timeBuy=TimeBuy}),
	player:sendMsgToMap({msg_PlayerVipChanged,player:getCurPlayerID(),Level,TimeExpire,TimeBuy}),
	playerMap:onPlayer_LevelEquipPet_Changed(),
	sendVipInfo(),	
	saveVipInfo().

%% 设置VIP等级
setVipLevel(Level)->
	VipInfo = get("VipInfo"),
	case Level > VipInfo#vipInfo.level of
		true->
			setVipInfo(Level,VipInfo#vipInfo.timeExpire,VipInfo#vipInfo.timeBuy);
		false->ok
	end.

%% 设置为体验VIP
setTrialVip()->
	Time = 3*24*3600,
	addVipTime(Time).
		
%% VIP增加时长
addVipTime(Time)->
	case Time > 0 of
		true->
			{Level,TimeExpire,TimeBuy} = getVipInfo(),
			TimeBuyNew = TimeBuy + Time,
			%% 如果已经过期，需要重置到期时间
			case isVipExpire() of
				true-> TimeExpireNew = common:getNowSeconds() + Time;
				false->TimeExpireNew = TimeExpire + Time
			end,
			%% 刷新VIP等级
			LevelNew = getVipLevelByTime(TimeBuyNew),
			case Level < LevelNew of 
				true->
					case LevelNew =:= ?VIP_LEVEL_DIAMOND of
						true->systemMessage:sendSysMsgToAllPlayer("恭喜" ++ player:getCurPlayerName() ++ "成为钻石VIP，从此上天入地唯我独尊！");
						false->ok
					end,
					?MessagePromptMe("VIP等级提升至" ++ getVipName(LevelNew));
				false->ok
			end,
			setVipInfo(LevelNew,TimeExpireNew,TimeBuyNew);
		false->ok
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 通知客户端VIP信息
sendVipInfo()->
	{Level,TimeExpire,TimeBuy} = getVipInfo(),
	case TimeExpire > common:getNowSeconds() of
		true->Time = TimeExpire-common:getNowSeconds();
		false->Time = 0
	end,
	Msg = #pk_GS2U_VipInfo{vipLevel=Level,vipTime=Time,vipTimeExpire=TimeExpire,vipTimeBuy=TimeBuy},
	?DEBUG_OUT("sendVipInfo Msg:~p",[Msg]),
	player:send(Msg).
	
%% 保存玩家的VIP信息
saveVipInfo()->
	{Lv,TE,TB} = getVipInfo(),
	?DEBUG_OUT("saveVipInfo Level=~p,TimeExpire=~p,TimeBuy=~p",[Lv,TE,TB]),
	mySqlProcess:update_playerVipInfo(player:getCurPlayerID(),Lv,TE,TB).

%% 玩家使用VIP卡片
useVipCard(Days)->
	Time = Days*24*3600,
	addVipTime(Time),
	?MessageTipsMe("您使用了VIP卡片，成功增加VIP时长" ++ integer_to_list(Days) ++ "天").





