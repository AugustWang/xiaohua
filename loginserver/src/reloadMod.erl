-module(reloadMod).

-export([reload/1]).


reload(Module)->
    io:format(" reload Module: ~p  ~n",[Module]),
	code:purge(Module),
	case code:get_object_code(Module) of
		{_Module, Binary, Filename} ->
			case code:load_binary(Module, Filename, Binary) of
            	{module, Module} ->
					io:format("reload  ~p success   ~n",[Module]);
				{error, What} ->
					io:format("reload  ~p fail,reason:~p   ~n",[Module,What])
			end;		
		error ->
			io:format(" get_object_code ~p fail  ~n",[Module])
	end.


