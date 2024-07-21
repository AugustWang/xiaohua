-module(network_reload_module).

-export([network_reload/1]).

%% Param : [Node,Module]
network_reload(Param)->
	%Node = 'gameserver@localhost',
	[Node|LeftParm] = Param,
	[Module|_] = LeftParm,
	io:format(" Node: ~p, Module: ~p  ~n",[Node,Module]),
	case code:get_object_code(Module) of
		{_Module, Binary, Filename} ->
			case rpc:call(Node, code, load_binary, [Module, Filename, Binary]) of
				{module, Module} ->
					io:format("reload  ~p success   ~n",[Module]);
				{error, What} ->
					io:format("reload  ~p fail,reason:~p   ~n",[Module,What])
			end;		
		error ->
			io:format(" get_object_code ~p fail  ~n",[Module])
	end,
    ok.
