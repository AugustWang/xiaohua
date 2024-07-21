%% Author: Administrator
%% Created: 2012-9-10
%% Description: TODO: Add description to chat
-module(chat).

%% add by wenziyong for gen server
-behaviour(gen_server).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%
%% Include files
%%
-include("chat.hrl").
-include("package.hrl").
-include("db.hrl").
-include("vipDefine.hrl").
-include("hdlt_logger.hrl").
-include("condition_compile.hrl").
-include("itemDefine.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

start_link() ->
	?DEBUG_OUT("chat thread begin"),
	gen_server:start_link({local,chatPid},?MODULE, [], [{timeout,?Start_Link_TimeOut_ms}]).



init([]) ->
    {ok, {}}.


handle_call(_Request, _From, State) ->
    {noreply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.



terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.



%%
%% API Functions
%%
handle_info(Info, StateData)->			
	put("ChatRecieve", true),

	try
	case Info of
		{quit}->
			?LOG_OUT( "Chat Recieve quit" ),
			put( "ChatRecieve", false );
		{chat, PlayerID, VIPLevel, P} ->
			on_chatMsg(PlayerID, VIPLevel, P)
	end,
	case get("ChatRecieve") of
		true->{noreply, StateData};
		false->{stop, normal, StateData}
	end

	catch
		_:_Why->
			common:messageBox( "ExceptionFunc_Module:[~p] ExceptionFunc[hande_info] Why[~p] stack[~p]", 
						[?MODULE,_Why, erlang:get_stacktrace()] ),	

			{noreply, StateData}
	end.


getPid() -> 
	chatPid.

%%玩家进程，聊天处理
onChatMsg(#pk_Chat2Server{}=P)->
	LenContent = string:len( P#pk_Chat2Server.content ),
	case LenContent > 0 of
		true->
			[FirstString|_] = P#pk_Chat2Server.content,
			case FirstString of
				35->gmHandle:onMsgGM( P#pk_Chat2Server.content ),
					Chat2Server2 = setelement( #pk_Chat2Server.channel, P, 2 ),
					Chat2Server3 = setelement( #pk_Chat2Server.receiveID, Chat2Server2, Chat2Server2#pk_Chat2Server.sendID ),
					Chat2Server = setelement( #pk_Chat2Server.receiveName, Chat2Server3, Chat2Server3#pk_Chat2Server.sendName );
				_->Chat2Server = P
			end;
		_->Chat2Server = P
	end,

	try
		%%错误处理，如果客户端发送过来的内容太长，直接返回
		case length(Chat2Server#pk_Chat2Server.content) > 1024 of
			true->throw(-1);
			_->ok
		end,
		
		case Chat2Server#pk_Chat2Server.channel =:= ?CHAT_CHANNEL_Trumpet of
			true->
				TimeNow = common:timestamp(),
				case TimeNow-player:getCurPlayerProperty(#player.chatLastSpeakTime) >=5 of
					true ->
						%% VIP免费送喇叭次数
						case vipFun:callVip(?VIP_FUN_TRUMPET,0) of
							{ok,_}->
								chat:getPid() ! {chat, player:getCurPlayerID(), vip:getVipLevel(), Chat2Server};
							{_,_}->
								ItemID = globalSetup:getGlobalSetupValue(#globalSetup.trumpet_Chat_Item),
								[CanDecItem|DecItems] = playerItems:canDecItemInBag( ?Item_Location_Bag, ItemID, 1, "all" ),
								case CanDecItem of
									true->
										playerItems:decItemInBag(DecItems, ?Destroy_Item_Reson_Chat),
										chat:getPid() ! {chat, player:getCurPlayerID(), vip:getVipLevel(), Chat2Server};
									false->
										player:send(#pk_Chat_Error_Result{reason=?Speak_Error_NotItem})
								end
						end;
					false ->
						player:send(#pk_Chat_Error_Result{reason=?Speak_Error_Colding})
				end;
			_->
				%% 是否禁言
				case player:getCurPlayerProperty(#player.forbidChatFlag) =:= 0 of
					true -> 
						TimeNow = common:timestamp(),
						case TimeNow-player:getCurPlayerProperty(#player.chatLastSpeakTime) >=5 of
							true ->
								player:setCurPlayerProperty(#player.chatLastSpeakTime, TimeNow),
								chat:getPid() ! {chat, player:getCurPlayerID(), vip:getVipLevel(), Chat2Server};
							false ->
								player:send(#pk_Chat_Error_Result{reason=?Speak_Error_Colding})
						end;
					false ->
						%% 禁言了
						ok
				end
		end
	catch
	_->ok
	end.

on_chatMsg(_PlayerID, VIPLevel, #pk_Chat2Server{}=P) ->
	case P#pk_Chat2Server.channel of
		?CHAT_CHANNEL_WORD ->
            on_ChatWord(P, VIPLevel);
		?CHAT_CHANNEL_PRIVATE ->
			on_ChatPrivate(P, VIPLevel);
		?CHAT_CHANNEL_TEAM ->
			on_ChatTeam(P, VIPLevel);
		?CHAT_CHANNEL_LEAGUE ->
			on_ChatLeague( P, VIPLevel);
		?CHAT_CHANNEL_SYSTEM ->
			on_ChatSystem( P );
		?CHAT_CHANNEL_Trumpet->
			on_ChatTrumpet( P, VIPLevel )
	end.

on_ChatTrumpet( #pk_Chat2Server{}=P, VIPLevel ) ->
		P2 = #pk_Chat2Player{channel=?CHAT_CHANNEL_Trumpet, sendID=P#pk_Chat2Server.sendID, receiveID = 0, 
				sendName = P#pk_Chat2Server.sendName, receiveName="", content=P#pk_Chat2Server.content, vipLevel=VIPLevel},
	player:sendToAllOnLinePlayer(P2).

on_ChatWord(#pk_Chat2Server{}=P, VIPLevel ) ->
	P2 = #pk_Chat2Player{channel=?CHAT_CHANNEL_WORD, sendID=P#pk_Chat2Server.sendID, receiveID = 0, 
				sendName = P#pk_Chat2Server.sendName, receiveName="", content=P#pk_Chat2Server.content, vipLevel=VIPLevel},
	player:sendToAllOnLinePlayer(P2)
.

on_ChatPrivate( #pk_Chat2Server{}=P, VIPLevel ) ->
	Id = player:getOnlinePlayerIDByName(P#pk_Chat2Server.receiveName),
	case Id of 
		0 ->
			player:sendToPlayer(P#pk_Chat2Server.sendID, #pk_Chat_Error_Result{reason=?Speak_Error_TargetNotOnline});
		_ ->
			P2 = #pk_Chat2Player{channel=?CHAT_CHANNEL_PRIVATE, sendID=P#pk_Chat2Server.sendID, receiveID = Id, 
					sendName = P#pk_Chat2Server.sendName, receiveName=P#pk_Chat2Server.receiveName, content=P#pk_Chat2Server.content, vipLevel=VIPLevel},
			player:sendToPlayer(Id, P2),
			case Id /= P#pk_Chat2Server.sendID of
				true->
					player:sendToPlayer(P#pk_Chat2Server.sendID, P2);
				_->ok
			end
	end.

on_ChatTeam(#pk_Chat2Server{}=P, VIPLevel ) ->
	Msg = #pk_Chat2Player{channel=?CHAT_CHANNEL_TEAM, sendID = P#pk_Chat2Server.sendID, receiveID=P#pk_Chat2Server.receiveID, 
						  sendName=P#pk_Chat2Server.sendName, receiveName="", content=P#pk_Chat2Server.content, vipLevel=VIPLevel},
	teamThread ! {chat, P#pk_Chat2Server.receiveID, Msg}.

on_ChatLeague(#pk_Chat2Server{}=P, VIPLevel ) ->
	Msg = #pk_Chat2Player{channel=?CHAT_CHANNEL_LEAGUE, sendID = P#pk_Chat2Server.sendID, receiveID=P#pk_Chat2Server.receiveID, 
						  sendName=P#pk_Chat2Server.sendName, receiveName="", content=P#pk_Chat2Server.content, vipLevel=VIPLevel},
	guildProcess_PID ! {chat, P#pk_Chat2Server.receiveID, Msg}.

on_ChatSystem(#pk_Chat2Server{}=P) ->
	P2 = #pk_Chat2Player{channel=?CHAT_CHANNEL_SYSTEM, sendID=0, receiveID = 0, 
						 sendName = "", receiveName="", content=P#pk_Chat2Server.content, vipLevel=0 },
	player:sendToAllOnLinePlayer(P2)
.

