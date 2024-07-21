%% Author: yueliangyou
%% Created: 2013-4-17
%% Description: TODO: 
-module(gateway).

%%
%% Include files
%%
-include("db.hrl").
-include("gateway.hrl").
-include("playerDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("variant.hrl").
-include_lib("stdlib/include/ms_transform.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

%% 重置心跳
resetHeartBeat()->
	%% 上次心跳时间
	put("LastHeartBeatTime",0),
	erlang:send_after(?HEART_BEAT_TIMEOUT,self(),{onHeartBeatCheck}),
	ok.

%% 重置心跳次数
resetHeartBeatCount()->
	put("HeartBeatCount",0),
	erlang:send_after(?HEART_BEAT_RATE*?HEART_BEAT_COUNT,self(),{onHeartBeatRateCheck}),
	ok.

%% 重置收包统计
resetPacketCount()->
 	%% 收包统计数量
 	put("PacketCount",0),
 	erlang:send_after(?PACKET_COUNT_INTERVAL,self(),{onPacketCountCheck}),
 	ok.

initialize()->
	resetHeartBeat(),
	resetHeartBeatCount(),
	resetPacketCount(),
	?LOG_OUT("user gateway initialize ok."),
	ok.

%% 收到消息包
on_RecvPacket()->
	PacketCount=get("PacketCount")+1,
 	put("PacketCount",PacketCount),
 	ok.

%% 收到心跳包处理
on_HeartBeat()->
	put("LastHeartBeatTime",common:milliseconds()),
	put("HeartBeatCount",get("HeartBeatCount")+1),
	%?DEBUG_OUT("Socket[~p] heart beat ...",[netUsers:getCurUserSocket()]),
	ok.

on_HeartBeatRateCheck()->
	?DEBUG_OUT("on_HeartBeatRateCheck HeartBeatCount=~p",[get("HeartBeatCount")]),
	case get("HeartBeatCount") > ?HEART_BEAT_COUNT+?HEART_BEAT_GREATER_COUNT of
		true->
			Player=player:getCurPlayerRecord(),
			case Player of 
				undefined->
					%% player is not online, should notice the player process exit
					self() ! {quit},
					ok;
				_->
					PlayerName=Player#player.name,
					?ERROR_OUT("Socket[~p],Player:~p heart beat too quick.",[netUsers:getCurUserSocket(),PlayerName]),
					%% 踢玩家下线
					case variant:getWorldVarFlag(?WorldVariant_Index_51, ?WorldVariant_Index_51_PingFlag_Bit0) of
						true ->
							self() ! { kickOut, ?KickoutUser_Reson_HeartBeat_Timeout };
						false ->
							ok
					end
			end;
		false->ok
	end,
	resetHeartBeatCount().

%% 心跳检查
on_HeartBeatCheck()->
	%% just for test, must comment it
%% 	case variant:getWorldVarFlag(?WorldVariant_Index_51, ?WorldVariant_Index_51_PingFlag_Bit0) of
%% 		true ->
%% 			?DEBUG_OUT("enable ping"),
%% 			self() ! { kickOut, ?KickoutUser_Reson_HeartBeat_Timeout };
%% 		false ->
%% 			?DEBUG_OUT("disable ping"),
%% 			ok
%% 	end,

	%?DEBUG_OUT("Socket[~p] heart beat check...",[netUsers:getCurUserSocket()]),
	case get("LastHeartBeatTime") =:= 0 of
		true->
			Player=player:getCurPlayerRecord(),
			case Player of 
				undefined->
					%% player is not online, should notice the player process exit
					?ERROR_OUT( "Socket[~p] on_HeartBeatCheck Player=undefined timeout", [netUsers:getCurUserSocket()] ),
					case variant:getWorldVarFlag(?WorldVariant_Index_51, ?WorldVariant_Index_51_PingFlag_Bit0) of
						true ->
							self() ! { kickOut, ?KickoutUser_Reson_HeartBeat_Timeout };
						false ->
							ok
					end,
					ok;
				_->
					PlayerName=Player#player.name,
					?ERROR_OUT("Socket[~p],Player:~p heart beat timeout.",[netUsers:getCurUserSocket(),PlayerName]),
					%% 踢玩家下线
					case variant:getWorldVarFlag(?WorldVariant_Index_51, ?WorldVariant_Index_51_PingFlag_Bit0) of
						true ->
							self() ! { kickOut, ?KickoutUser_Reson_HeartBeat_Timeout };
						false ->
							ok
					end
			end;
		false->ok
	end,
	resetHeartBeat(),
	ok.

%% 网络包数量检查
on_PacketCountCheck()->
 	?DEBUG_OUT("Socket[~p] packet count check...[~p]",[netUsers:getCurUserSocket(),get("PacketCount")]),
 	case get("PacketCount") > ?PACKET_COUNT_LIMIT of
 		true->
 			Player=player:getCurPlayerRecord(),
 			PlayerName=Player#player.name,
 			?LOG_OUT("Socket[~p],Player:~p packet count[~p],max[~p].",[netUsers:getCurUserSocket(),PlayerName,get("PacketCount"),?PACKET_COUNT_LIMIT]),
 			?ERROR_OUT("Socket[~p],Player:~p packet count[~p],max[~p].",[netUsers:getCurUserSocket(),PlayerName,get("PacketCount"),?PACKET_COUNT_LIMIT]);
 			%% 踢玩家下线 暂时不做
 			%% self() ! { kickOut, ?KickoutUser_Reson_GM }
 		false->ok
 	end,
 	resetPacketCount(),
 	ok.

%% 时钟同步 暂不实现
sendClockSynchronize()->
	ok.

