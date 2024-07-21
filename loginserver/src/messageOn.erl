%% Author: Administrator
%% Created: 2012-6-29
%% Description: TODO: Add description to main
-module(messageOn).

%%
%% Include files
%%
-include("db.hrl").
-include("userDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("gameServerDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

%%------------------------------------------------------LS2GS------------------------------------------------------
on_GS2LS_Request_Login(_Socket,Pk)->
	gameServerHandle:onMsgGS2LS_Request_Login(Pk).
on_GS2LS_ReadyToAcceptUser(_Socket,Pk)->
	gameServerHandle:onMsgGS2LS_ReadyToAcceptUser(Pk).
on_GS2LS_OnlinePlayers(_Socket,Pk)->
	gameServerHandle:onMsgGS2LS_OnlinePlayers(Pk).
on_GS2LS_QueryUserMaxLevelResult(_Socket,Pk)->
	gameServerHandle:on_GS2LS_QueryUserMaxLevelResult(Pk).
on_GS2LS_UserReadyLoginResult(_Socket,Pk)->
	gameServerHandle:on_GS2LS_UserReadyLoginResult(Pk).
on_GS2LS_UserLoginGameServer(_Socket,Pk)->
	gameServerHandle:on_GS2LS_UserLoginGameServer(Pk).
on_GS2LS_UserLogoutGameServer(_Socket,Pk)->
	gameServerHandle:on_GS2LS_UserLogoutGameServer(Pk).
on_GS2LS_ActiveCode(_Socket,Pk) ->
	gameServerHandle:on_GS2LS_ActiveCode(Pk).
on_GS2LS_Command(_Socket,Pk) ->
	gameServerHandle:on_GS2LS_Command(Pk).
on_GS2LS_Recharge(_Socket,Pk) ->
	gameServerHandle:on_GS2LS_Recharge(Pk).



%%------------------------------------------------------LS2User------------------------------------------------------
on_U2LS_Login(_Socket,Pk)->
	userHandle:on_Login(Pk).
on_U2LS_Login_553(_Socket,Pk)->
	userHandle:on_Login_553(Pk).
on_U2LS_Login_APPS(_Socket,Pk)->
	userHandle:on_Login_APPS(Pk).
on_U2LS_Login_PP(_Socket,Pk)->
	userHandle:on_Login_PP(Pk).
on_U2LS_Login_360(_Socket,Pk)->
	userHandle:on_Login_360(Pk).
on_U2LS_Login_91(_Socket,Pk)->
	userHandle:on_Login_91(Pk).
on_U2LS_RequestGameServerList(_Socket,_Pk)->
	userHandle:onMsgRequestGameServerList().
on_U2LS_RequestSelGameServer(_Socket,Pk)->
	userHandle:on_U2LS_RequestSelGameServer(Pk).
on_U2LS_Login_UC(_Socket,Pk)->
	userHandle:on_U2LS_Login_UC(Pk).

