%% Author: yueliangyou
%% Created: 2013-4-10
%% Description: TODO: user login forbidden check
-module(forbidden).

%%
%% Include files
%%
-include("hdlt_logger.hrl").


%%
%% Exported Functions
%%
-compile(export_all).

%% 封号检查
forbiddenCheck(Account)->
	?DEBUG_OUT("forbiddenCheck Account:[~p]",[Account]),
	case loginMysqlProc:get_forbidden_user(Account) of
		{error,_}->false;
		{ok,Count}->
			case Count =:= 0 of
				true->false;
				false->true
			end
	end.
	
