%% Author: yueliangyou
%% Created: 2013-3-6
%% Description: TODO: platform starter
-module(platform).

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

init()->
	%% 创建支持平台的ets表
	inets:start(),
	ssl:start(),
	httpc:set_options([]),
    PlatformTable=ets:new( 'platformtable', [named_table,protected, { keypos, #platformTable.platformID }] ),
	loadPlatform(),
	ok.

loadPlatformList(ListInfo,0)->
	ListInfo;
loadPlatformList(ListInfo,Num)->
	PlatformID = main:ini_ReadInt("LoginServer.txt",common:catStringID("PlatformID",Num),0),
	PlatformIP = main:ini_ReadString("LoginServer.txt",common:catStringID("PlatformIP",Num),"127.0.0.1"),
	PlatformPort = main:ini_ReadInt("LoginServer.txt",common:catStringID("PlatformPort",Num),0),
	Item={PlatformID,PlatformIP,PlatformPort},
	?DEBUG_OUT( "Platform:~p,~p,~p", [PlatformID,PlatformIP,PlatformPort] ),
	ListInfo1=[Item|ListInfo],
	loadPlatformList(ListInfo1,Num-1).

beginPlatform(?PLATFORM_TEST,IP,Port)->
	platform553:initModuleTest(IP,Port),
	{ok,0};
beginPlatform(?PLATFORM_553,IP,Port)->
	platform553:initModule(IP,Port),
	{ok,0};
beginPlatform(?PLATFORM_553_android,IP,Port)->
	platform553:initModule553Android(IP,Port),
	{ok,0};
beginPlatform(?PLATFORM_APPS,IP,Port)->
	platformAPPS:initModule(IP,Port),
	{ok,0};
beginPlatform(?PLATFORM_PP,IP,Port)->
	platformPP:initModule(IP,Port),
	{ok,0};
beginPlatform(?PLATFORM_360,IP,Port)->
	platform360:initModule(IP,Port),
	{ok,0};
beginPlatform(?PLATFORM_UC_android,IP,Port)->
	platformUC:initModule(IP,Port),
	{ok,0};
beginPlatform(?PLATFORM_91_IOS,IP,Port)->
	platform91:initModule(IP,Port),
	{ok,0};
beginPlatform(?PLATFORM_91_android,IP,Port)->
	platform91:initModuleAndroid(IP,Port),
	{ok,0};
beginPlatform(_,IP,Port)->
	{ok,0}.

beginPlatforms([])->
	ok;
beginPlatforms(PlatformItemList)->
	[PlatformItem|PlatformItemList1] = PlatformItemList,
	{PlatformID,PlatformIP,PlatformPort} = PlatformItem,
	beginPlatform(PlatformID,PlatformIP,PlatformPort),
	beginPlatforms(PlatformItemList1).

%%启动平台函数
loadPlatform()->
	PlatformCount = main:ini_ReadInt("LoginServer.txt","PlatformCount",1 ),
	PlatformList = loadPlatformList([],PlatformCount),
	?DEBUG_OUT( "PlatformList:~p", [PlatformList] ),
	beginPlatforms(PlatformList).

