%% Author: yueliangyou
%% Created: 2013-4-13
%% Description: TODO: 
-module(platform360).

%%
%% Include files
%%
-include("db.hrl").
-include("userDefine.hrl").
-include("platformDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include("gameServerDefine.hrl").
-include_lib("stdlib/include/ms_transform.hrl").


%%
%% Exported Functions
%%
-compile(export_all).



initModule(IP,Port)->
	?LOG_OUT( "platform 360 module supported." ),
	ets:insert(platformtable,#platformTable{platformID=?PLATFORM_360,isSupport=1,ip=IP,port=Port}),
        ?LOG_OUT( "platform 360:~p",[ets:lookup(platformtable,?PLATFORM_360)] ).

is360Support()->
        ?DEBUG_OUT( "platform 360:~p",[ets:lookup(platformtable,?PLATFORM_360)] ),
	Ret=ets:lookup(platformtable,?PLATFORM_360),
        case Ret of
                [] ->no;
                [H|[]]->[{_,_,Support,_,_}|_Set]=Ret,
                        case Support of
                                1->yes;
                                _->no
                        end
        end.

verifyRequest360(Code)->
	RequestString="https://openapi.360.cn/oauth2/access_token?grant_type=authorization_code&code="++Code++"&client_id="++?APP_KEY_360++"&client_secret="++?APP_SECRET_360++"&redirect_uri=oob",
	?DEBUG_OUT("verifyRequest360 ready.RequestString is:~p",[RequestString]),
	case httpc:request(get,{RequestString,[{"connection","false"}]},[],[]) of
		{error,Reason}->
			?DEBUG_OUT("verifyRequest360 failed.Reason is:~p",[Reason]),
			error;
		{ok,Result}->
			{Header,Options,Content}=Result,
			?DEBUG_OUT("verifyRequest360 ok.Header:~p,Options:~p,Content:~p",[Header,Options,Content]),
			Bin=unicode:characters_to_binary(Content),
			{ok,JsonObj,_}=rfc4627:decode(Bin),
			try
				Value0=rfc4627:get_field(JsonObj,"error_code",<<"0">>),
				Value1=rfc4627:get_field(JsonObj,"access_token",<<"null">>),
				Value2=rfc4627:get_field(JsonObj,"refresh_token",<<"null">>),
				{ErrorCode,_}=string:to_integer(binary_to_list(Value0)),
				Access_Token=binary_to_list(Value1),
				Refresh_Token=binary_to_list(Value2),
				?DEBUG_OUT("verifyRequest360 ok.error_code:~p,AccessToken:~p,RefreshToken:~p",[ErrorCode,Access_Token,Refresh_Token]),
				case ErrorCode of
					0->requestUserInfo(Access_Token,Refresh_Token);
					_->failed	
				end
			catch
				_:Why->
				?DEBUG_OUT("verifyRequest360 exception.Why:~p",[Why]),
				failed
			end
        end.

requestUserInfo(Access_Token,Refresh_Token)->
	RequestString="https://openapi.360.cn/user/me.json?access_token="++Access_Token++"&fields=id,name",
	?DEBUG_OUT("verifyRequest360 requestUserInfo ready.RequestString is:~p",[RequestString]),
	case httpc:request(get,{RequestString,[{"connection","false"}]},[],[]) of
		{error,Reason}->
			?LOG_OUT("verifyRequest360 requestUserInfo failed.Reason is:~p",[Reason]),
			error;
		{ok,Result}->
			{Header,Options,Content}=Result,
			?DEBUG_OUT("verifyRequest360 requestUserInfo ok.Header:~p,Options:~p,Content:~p",[Header,Options,Content]),
			Bin=unicode:characters_to_binary(Content),
			{ok,JsonObj,_}=rfc4627:decode(Bin),
			try
				Value0=rfc4627:get_field(JsonObj,"error_code",<<"0">>),
				Value1=rfc4627:get_field(JsonObj,"id",<<"null">>),
				Value2=rfc4627:get_field(JsonObj,"name",<<"null">>),
				{ErrorCode,_}=string:to_integer(binary_to_list(Value0)),
				UserId=binary_to_list(Value1),
				UserName=binary_to_list(Value2),
				?DEBUG_OUT("verifyRequest360 requestUserInfo ok.error_code:~p,Id:~p,Name:~p",[ErrorCode,UserId,UserName]),
				case ErrorCode of
					0->{success,UserId,UserName,Access_Token,Refresh_Token};
					_->failed	
				end
			catch
				_:Why->
				?DEBUG_OUT("verifyRequest360 requestUserInfo exception.Why:~p",[Why]),
				failed
			end
        end.

