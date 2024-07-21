%% Author: yueliangyou
%% Created: 2013-5-7
%% Description: TODO: vip functions
-module(vipFun).

%%
%% Include files
%%
-include("db.hrl").
-include("variant.hrl").
-include("playerDefine.hrl").
-include("vipDefine.hrl").
-include("globalDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("logdb.hrl").
-include_lib("stdlib/include/ms_transform.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

%% 获取VIP免费小喇叭次数
getVipTrumpetCount()->
        PlayerVarArray = player:getCurPlayerProperty( #player.varArray ),
        Ret = variant:getPlayerVarValue(PlayerVarArray,?PlayerVariant_Index_9_VIP_TRUMPET_P),
	case Ret of
		undefined->0;
		_->Ret
	end.
	

%% 设置VIP免费小喇叭次数
setVipTrumpetCount(Value)->
        variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index_9_VIP_TRUMPET_P,Value).

%% 获取VIP免费飞行次数
getVipFlyCount()->
        PlayerVarArray = player:getCurPlayerProperty( #player.varArray ),
        Ret = variant:getPlayerVarValue(PlayerVarArray,?PlayerVariant_Index_9_VIP_FLY_P),
	case Ret of
		undefined->0;
		_->Ret
	end.
	

%% 设置VIP免费飞行次数
setVipFlyCount(Value)->
        variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index_9_VIP_FLY_P,Value).

%% 获取VIP免费副本次数
getVipFubenCount()->
        PlayerVarArray = player:getCurPlayerProperty( #player.varArray ),
        Ret = variant:getPlayerVarValue(PlayerVarArray,?PlayerVariant_Index_9_VIP_FUBEN_P),
	case Ret of
		undefined->0;
		_->Ret
	end.
	

%% 设置VIP免费副本次数
setVipFubenCount(Value)->
        variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index_9_VIP_FUBEN_P,Value).

%% 增加VIP免费副本次数
addVipFubenCount()->
	Value = getVipFubenCount()+1,
        variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index_9_VIP_FUBEN_P,Value).

%%----------------------------------------------------------------------------
%%----------------------------------------------------------------------------

loadVipFunInfo()->
	case db:openBinData( "vipFun.bin" ) of
                [] ->
                        ?ERROR_OUT( "loadVipFunInfo openBinData vipFun.bin false []" );
                VipFunData ->
                        db:loadBinData( VipFunData, vipFun ),

						ets:new( ?VipFunAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #vipFun.id }] ),

                        VipFunCfgList = db:matchObject(vipFun,  #vipFun{_='_'} ),
                        MyFunc1 = fun( Record )->
				etsBaseFunc:insertRecord(?VipFunAtom, Record)
			end,
                        lists:map( MyFunc1, VipFunCfgList ),
                        ?DEBUG_OUT( "loadVipFunInfo succ" )
        end,
	case db:openBinData( "vipAddProperty.bin" ) of
                [] ->
                        ?ERROR_OUT( "loadVipFunInfo openBinData vipAddProperty.bin false []" );
                VipAddPropertyData ->
                        db:loadBinData( VipAddPropertyData, vipAddProperty ),

						ets:new( ?VipAddPropertyAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #vipAddProperty.id }] ),

                        VipAddPropertyCfgList = db:matchObject(vipAddProperty,  #vipAddProperty{_='_'} ),
                        MyFunc2 = fun( Record )->
				etsBaseFunc:insertRecord(?VipAddPropertyAtom, Record)
			end,
                        lists:map( MyFunc2, VipAddPropertyCfgList ),
                        ?DEBUG_OUT( "loadVipAddPropertyInfo succ" )
        end.
	
%% 获取VIP功能配置信息,传入VIP功能ID，和玩家VIP等级，找出最匹配的记录。
getVipAddProperty(Index)->
	Query = ets:fun2ms( fun(#vipAddProperty{index=In}=Record ) when (Index =:= In) -> Record end),
	VipAddPropertyList = ets:select( ?VipAddPropertyAtom, Query),
	?DEBUG_OUT("VipAddPropertyList=~p",[VipAddPropertyList]),
	VipAddPropertyList.

%% 获取VIP功能配置信息,传入VIP功能ID，和玩家VIP等级，找出最匹配的记录。
getVipFunInfo(Fun,Level)->
	Query = ets:fun2ms( fun(#vipFun{id=_,funType=Type,level=Lv,value=_}=Record ) when (Type =:= Fun) and (Level >= Lv) -> Record end),
	VipFunList = ets:select( ?VipFunAtom, Query),
	?DEBUG_OUT("VipFunList=~p",[VipFunList]),
	case VipFunList of
		[]->{};
		_->
			VipFunList2 = lists:sort(fun(A,B)-> A#vipFun.level<B#vipFun.level end,VipFunList),
			?DEBUG_OUT("VipFunListSorted=~p",[VipFunList2]),
			lists:last(VipFunList2)
	end.
%%登陆的时候调用,是不是要重新给个声望任务
resetVipFunDataWhenLogin(LastLogoutTime)->
        %% 获取当前时间
        NowSecond=common:getNowSeconds(),
        %% 取当天12点的时间
        NowTime= NowSecond rem  86400,
        %% 计算当天重置时间
        ResetTimeToday=NowSecond-NowTime+?VIP_RESET_TIME,

        %% 重置时间未到 
        case ResetTimeToday<NowSecond of
                true->
                        LastResetTime= ResetTimeToday;
                false->
                        LastResetTime= ResetTimeToday -86400
        end,
        ?DEBUG_OUT( "resetVipFunDataWhenLogin ~p ~p ~p ~p",[ResetTimeToday,LastResetTime,LastLogoutTime,NowSecond] ),
        case LastLogoutTime=<LastResetTime of
                true->
                        %%需要重置
                        resetVipFunData();
                false-> ok
        end.

%% 重置VIP玩家VIP相关功能数据
resetVipFunData()->
	?DEBUG_OUT("resetVipFunData --------"),
	setVipFlyCount(0),
	setVipTrumpetCount(0),
	setVipFubenCount(0),
	ok.

callVipEx(PlayerID,Fun,Value)->
	ProcessID = player:getPlayerPID(PlayerID),
	try
		gen_server:call(ProcessID,{'callVip',Fun,Value})
	catch
		_:_->{error,0}
	end.

%% 调用VIP函数，成功返回处理后的值，失败返回传入值
callVip(Fun,Value)->
	try

	?DEBUG_OUT("callVip Fun=~p,Value=~p",[Fun,Value]),
	case vip:isVipPlayer() of 
		false->throw({notVipPlayer});
		true->ok
	end,

	VipFun = getVipFunInfo(Fun,vip:getVipLevel()),
	?DEBUG_OUT("VipFun=~p",[VipFun]),
	case VipFun of
		{}->throw({noVipFun});
		_->ok
	end,

	Ret = callVipFun(Fun,#vipFunParam{value=Value,param=VipFun#vipFun.value}),
	case Ret of
		{ok,P}->{ok,P};
		{_,_}->{error,Value}
	end
	catch
		{noVipFun}->{error,Value};
		{notVipPlayer}->{error,Value};
		_:Why->?LOG_OUT("callVip exception.Why:~p",[Why]),{error,Value}
	end.
	
callVipFun(?VIP_FUN_TEST,#vipFunParam{value=Value,param=Param}=Params)->
	?DEBUG_OUT("callVipFun Test,Value[~p],Param[~p]",[Value,Param]),
	{ok,Value+Param};

%% 打怪经验加成
callVipFun(?VIP_FUN_EXP_KILLMONSTER,#vipFunParam{value=Value,param=Param}=Params)->
	?DEBUG_OUT("callVipFun VIP_FUN_EXP_KILLMONSTER,Value[~p],Param[~p]",[Value,Param]),
	Inc = Value*Param div 10000,
	case Inc > 1 of
		true->{ok,Value+Inc};
		false->{ok,Value+1}
	end;

%% 活跃度经验加成
callVipFun(?VIP_FUN_EXP_ACTIVE,#vipFunParam{value=Value,param=Param}=Params)->
	?DEBUG_OUT("callVipFun VIP_FUN_EXP_ACTIVE,Value[~p],Param[~p]",[Value,Param]),
	Inc = Value*Param div 10000,
	case Inc > 1 of
		true->{ok,Value+Inc};
		false->{ok,Value+1}
	end;

%% 飞行符
callVipFun(?VIP_FUN_FLY,#vipFunParam{value=Value,param=Param}=Params)->
	?DEBUG_OUT("callVipFun(?VIP_FUN_FLY) ---"),
	case Param =:= -1 of
		true->{ok,0};
		false->
			%% 判定次数
			FlyCount = getVipFlyCount(),
			?DEBUG_OUT("callVipFun(?VIP_FUN_FLY) ---FlyCount=~p",[FlyCount]),
			case FlyCount < Param of
				true->
					?MessageTipsMe("还剩余" ++ integer_to_list(Param-FlyCount-1) ++ "次免费飞行。"),
					setVipFlyCount(FlyCount+1),{ok,0};
				false->{error,0}
			end
	end;

%% 小喇叭
callVipFun(?VIP_FUN_TRUMPET,#vipFunParam{value=Value,param=Param}=Params)->
	?DEBUG_OUT("callVipFun(?VIP_FUN_TRUMPET) ---"),
	case Param =:= -1 of
		true->{ok,0};
		false->
			%% 判定次数
			TrumpetCount = getVipTrumpetCount(),
			?DEBUG_OUT("callVipFun(?VIP_FUN_TRUMPET) ---TrumpetCount=~p",[TrumpetCount]),
			case TrumpetCount < Param of
				true->
					?MessageTipsMe("还剩余" ++ integer_to_list(Param-TrumpetCount-1) ++ "次免费使用。"),
					setVipTrumpetCount(TrumpetCount+1),{ok,0};
				false->{error,0}
			end
	end;

%% 副本收益次数
callVipFun(?VIP_FUN_FUBEN,#vipFunParam{value=Value,param=Param}=Params)->
	?DEBUG_OUT("callVipFun(?VIP_FUN_FUBEN) ---Value=~p,Param=~p",[Value,Param]),
	case Value of
		0->
			case Param =:= -1 of
				true->{ok,0};
				false->
					%% 判定次数
					FubenCount = getVipFubenCount(),
					?DEBUG_OUT("callVipFun(?VIP_FUN_FUBEN) ---FubenCount=~p",[FubenCount]),
					case FubenCount < Param of
						true->{ok,0};
						false->{error,0}
					end
			end;
		1->
			case Param =:= -1 of
				true->{ok,0};
				false->
					%% 判定次数
					FubenCount1 = getVipFubenCount(),
					?DEBUG_OUT("callVipFun(?VIP_FUN_FUBEN) ---FubenCount1=~p",[FubenCount1]),
					case FubenCount1 < Param of
						true->
							?MessageTipsMe("还剩余" ++ integer_to_list(Param-FubenCount1-1) ++ "次免费活跃次数。"),
							setVipFubenCount(FubenCount1+1),{ok,0};
						false->{error,0}
					end
			end
			
	end;

%% 远程商店
callVipFun(?VIP_FUN_REMOTE_SHOP,#vipFunParam{value=Value,param=Param}=Params)->
	{ok,Param};
%% 远程仓库
callVipFun(?VIP_FUN_REMOTE_STORE,#vipFunParam{value=Value,param=Param}=Params)->
	{ok,Param};
%% 加玩家属性
callVipFun(?VIP_FUN_PROPERTY,#vipFunParam{value=Value,param=Param}=Params)->
	VipFix = array:new( ?property_count, {default, 0} ),
       	VipPer = array:new( ?property_count, {default, [] } ),
	put("VipAddFix",VipFix),
	put("VipAddPer",VipPer),
	PropertyList = getVipAddProperty(Param),
	?DEBUG_OUT("callVipFun(?VIP_FUN_PROPERTY) Param=~p,PropertyList:~p",[Param,PropertyList]),
	case PropertyList of
		[]->ok;
		_->	
			MyFun = fun(Property)->
				case Property#vipAddProperty.per of
					0->
						ArrayFix=get("VipAddFix"),
                            			Value0=array:get(Property#vipAddProperty.type,ArrayFix),
                            			ArrayFix2=array:set(Property#vipAddProperty.type,Property#vipAddProperty.value+Value0,ArrayFix),
                            			put( "VipAddFix",ArrayFix2);
					_->
                             			ArrayPer = get("VipAddPer"),
                             			Value0 = [Property#vipAddProperty.value] ++ array:get(Property#vipAddProperty.type,ArrayPer),
                             			ArrayPer2 = array:set(Property#vipAddProperty.type,Value0,ArrayPer),
                             			put( "VipAddPer", ArrayPer2)
				end
			end,
			lists:foreach(MyFun,PropertyList)
	end,
	?DEBUG_OUT("VipAddFix:~p,VipAddPer:~p",[get("VipAddFix"),get("VipAddPer")]),
	{ok,{get("VipAddFix"),get("VipAddPer")}};

callVipFun(_,#vipFunParam{}=Params)->
	{ok,0}.











