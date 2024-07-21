-module(stop_loginserver).

-export([stop/1]).

stop(Param)->
	[Node|_]=Param,
	Ret = rpc:call(Node,server,stop,[]),
	io:format("stop return: ~p ~n",[Ret]),
	erlang:halt().

