%% Author: yueliangyou
%% Created: 2012-6-29
%% Description: TODO: 
-module(platform553).

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



initModuleTest(IP,Port)->
        ?LOG_OUT( "platform Test module supported." ),
	ets:insert(platformtable,#platformTable{platformID=?PLATFORM_TEST,isSupport=1,ip=IP,port=Port}),
        ?LOG_OUT( "platform Test:~p",[ets:lookup(platformtable,?PLATFORM_TEST)] ).

isTestSupport()->
        ?DEBUG_OUT( "platform Test:~p",[ets:lookup(platformtable,?PLATFORM_TEST)] ),
	Ret=ets:lookup(platformtable,?PLATFORM_TEST),
	case Ret of
		[] ->no;
		[H|[]]->[{_,_,Support,_,_}|_Set]=Ret,
			case Support of 
				1->yes;
				_->no
			end
	end.

isTestCheck()->
	PlatformTestCheck = main:ini_ReadInt("LoginServer.txt","PlatformTestCheck",1),
	PlatformTestCheck /= 0.

initModule(IP,Port)->
        ?LOG_OUT( "platform 553 module supported." ),
	ets:insert(platformtable,#platformTable{platformID=?PLATFORM_553,isSupport=1,ip=IP,port=Port}),
        ?LOG_OUT( "platform 553:~p",[ets:lookup(platformtable,?PLATFORM_553)] ).


is553Support()->
        ?DEBUG_OUT( "platform 553:~p",[ets:lookup(platformtable,?PLATFORM_553)] ),
	Ret=ets:lookup(platformtable,?PLATFORM_553),
	case Ret of
		[] ->no;
		[H|[]]->[{_,_,Support,_,_}|_Set]=Ret,
			case Support of 
				1->yes;
				_->no
			end
	end.

initModule553Android(IP,Port)->
        ?LOG_OUT( "platform 553 android module supported." ),
	ets:insert(platformtable,#platformTable{platformID=?PLATFORM_553_android,isSupport=1,ip=IP,port=Port}),
        ?LOG_OUT( "platform 553 android :~p",[ets:lookup(platformtable,?PLATFORM_553_android)] ).

is553AndroidSupport()->
        ?DEBUG_OUT( "platform 553 android:~p",[ets:lookup(platformtable,?PLATFORM_553_android)] ),
	Ret=ets:lookup(platformtable,?PLATFORM_553_android),
	case Ret of
		[] ->no;
		[H|[]]->[{_,_,Support,_,_}|_Set]=Ret,
			case Support of 
				1->yes;
				_->no
			end
	end.

