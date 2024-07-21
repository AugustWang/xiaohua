-module(loginserver_app).

-behaviour(application).

-export([
		 start/2,
		 stop/1
		]).

start(_Type,_StartArgs) ->
	case loginServerSup:start_link() of
		{ok,Pid1}->
			{ok,Pid1};
		Other->
			io:format("------------error ~p ~n",[Other]),
			{error,Other}
	end.

stop(_State)->
	erlang:halt(),
	ok.
	