-module(stop_gameserver).

-export([stop/1]).

stop(Param)->
	%Node = 'gameserverwzy@sz1',
	[Node|_] = Param,
	io:format(" Node: ~p ~n",[Node]),
	ForbidLoginAndKickRet = rpc:call(Node,gmHandle,forbidLoginAndKickall,[]),
	io:format("forbidlogin and kick: ~p ~n",[ForbidLoginAndKickRet]),
	timer:sleep(1000*120),
	StopRet = rpc:call(Node,server,stop,[]),
	io:format("StopRet: ~p ~n",[StopRet]),
	erlang:halt().
	
