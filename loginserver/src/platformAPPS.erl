%% Author: yueliangyou
%% Created: 2013-4-13
%% Description: TODO: 
-module(platformAPPS).

%%
%% Include files
%%
-include("db.hrl").
-include("userDefine.hrl").
-include("platformDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("gameServerDefine.hrl").
-include_lib("stdlib/include/ms_transform.hrl").


%%
%% Exported Functions
%%
-compile(export_all).

initModule(IP,Port)->
        ?LOG_OUT( "platform APPS module supported." ),
	ets:insert(platformtable,#platformTable{platformID=?PLATFORM_APPS,isSupport=1,ip=IP,port=Port}),
        ?LOG_OUT( "platform APPS:~p",[ets:lookup(platformtable,?PLATFORM_APPS)] ).


isAPPSSupport()->
        ?DEBUG_OUT( "platform APPS:~p",[ets:lookup(platformtable,?PLATFORM_APPS)] ),
	Ret=ets:lookup(platformtable,?PLATFORM_APPS),
	case Ret of
		[] ->no;
		[H|[]]->[{_,_,Support,_,_}|_Set]=Ret,
			case Support of 
				1->yes;
				_->no
			end
	end.


