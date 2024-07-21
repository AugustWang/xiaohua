-module(systemMessage).

-compile(export_all). 

-include("package.hrl").
-include("chat.hrl").

%% add by yueliangyou [2013-04-23]
sendErrMessage(PlayerID,M)->
	sendSysMessage(PlayerID,?SYSTEM_MESSAGE_ERROR,M).

sendBoxMessage(PlayerID,M)->
	sendSysMessage(PlayerID,?SYSTEM_MESSAGE_BOX,M).

sendPromptMessage(PlayerID,M)->
	sendSysMessage(PlayerID,?SYSTEM_MESSAGE_PROMPT,M).

sendTipsMessage(PlayerID,M)->
	sendSysMessage(PlayerID,?SYSTEM_MESSAGE_TIPS,M).

sendSysMessage(PlayerID,Type,Message)->
	player:sendToPlayer(PlayerID,#pk_SysMessage{type=Type,text = Message}).

sendErrMessageToMe(M)->
	sendSysMessageToMe(?SYSTEM_MESSAGE_ERROR,M).

sendBoxMessageToMe(M)->
	sendSysMessageToMe(?SYSTEM_MESSAGE_BOX,M).

sendPromptMessageToMe(M)->
	sendSysMessageToMe(?SYSTEM_MESSAGE_PROMPT,M).

sendTipsMessageToMe(M)->
	sendSysMessageToMe(?SYSTEM_MESSAGE_TIPS,M).

sendSysMessageToMe(Type,Message)->
	player:send(#pk_SysMessage{type=Type,text = Message}).

sendSysMsgToAllPlayer( Text )->
	player:sendToAllOnLinePlayer(#pk_SysMessage{type=?SYSTEM_MESSAGE_ANNOUNCE,text = Text}).
