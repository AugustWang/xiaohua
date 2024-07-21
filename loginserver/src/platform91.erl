%% Author: yueliangyou
%% Created: 2013-5-20
%% Description: TODO: 
-module(platform91).

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
	?LOG_OUT( "platform 91 module supported." ),
	ets:insert(platformtable,#platformTable{platformID=?PLATFORM_91_IOS,isSupport=1,ip=IP,port=Port}),
        ?LOG_OUT( "platform 91:~p",[ets:lookup(platformtable,?PLATFORM_91_IOS)] ).

initModuleAndroid(IP,Port)->
	?LOG_OUT( "platform 91 android module supported." ),
	ets:insert(platformtable,#platformTable{platformID=?PLATFORM_91_android,isSupport=1,ip=IP,port=Port}),
        ?LOG_OUT( "platform 91:~p",[ets:lookup(platformtable,?PLATFORM_91_android)] ).

isSupport()->
        ?DEBUG_OUT( "platform 91:~p",[ets:lookup(platformtable,?PLATFORM_91_IOS)] ),
	Ret=ets:lookup(platformtable,?PLATFORM_91_IOS),
        case Ret of
                [] ->no;
                [H|[]]->[{_,_,Support,_,_}|_Set]=Ret,
                        case Support of
                                1->yes;
                                _->no
                        end
        end.

isSupportAndroid()->
        ?DEBUG_OUT( "platform 91:~p",[ets:lookup(platformtable,?PLATFORM_91_android)] ),
	Ret=ets:lookup(platformtable,?PLATFORM_91_android),
        case Ret of
                [] ->no;
                [H|[]]->[{_,_,Support,_,_}|_Set]=Ret,
                        case Support of
                                1->yes;
                                _->no
                        end
        end.

verifyRequest91(?PLATFORM_91_IOS,Uin,SessionID)->
	Sign = md5:encrypt(?APP_ID_91++"4"++Uin++SessionID++?APP_KEY_91),
	?DEBUG_OUT("verifyRequest91 Sign is:~p",[Sign]),
	RequestString="http://service.sj.91.com/usercenter/AP.aspx?AppId="++?APP_ID_91++"&Act=4&Uin="++Uin++"&Sign="++Sign++"&SessionID="++SessionID,
	?DEBUG_OUT("verifyRequest91 ready.RequestString is:~p",[RequestString]),
	case httpc:request(get,{RequestString,[{"connection","false"}]},[],[]) of
		{error,Reason}->
			?DEBUG_OUT("verifyRequest91 failed.Reason is:~p",[Reason]),
			error;
		{ok,Result}->
			{Header,Options,Content}=Result,
			?DEBUG_OUT("verifyRequest91 ok.Header:~p,Options:~p,Content:~p",[Header,Options,Content]),
			Bin=unicode:characters_to_binary(Content),
			{ok,JsonObj,_}=rfc4627:decode(Bin),
			try
				Value0=rfc4627:get_field(JsonObj,"ErrorCode",<<"0">>),
				Value1=rfc4627:get_field(JsonObj,"ErrorDesc",<<"null">>),
				{ErrorCode,_}=string:to_integer(binary_to_list(Value0)),
				ErrorDesc=binary_to_list(Value1),
				?DEBUG_OUT("verifyRequest91 ok.ErrorCode:~p,ErrorDesc:~p",[ErrorCode,ErrorDesc]),
				case ErrorCode of
					1->success;
					_->failed	
				end
			catch
				_:Why->
				?DEBUG_OUT("verifyRequest91 exception.Why:~p",[Why]),
				failed
			end
        end;
verifyRequest91(?PLATFORM_91_android,Uin,SessionID)->
	Sign = md5:encrypt(?APP_ID_91_android++"4"++Uin++SessionID++?APP_KEY_91_android),
	?DEBUG_OUT("verifyRequest91 Sign is:~p",[Sign]),
	RequestString="http://service.sj.91.com/usercenter/AP.aspx?AppId="++?APP_ID_91_android++"&Act=4&Uin="++Uin++"&Sign="++Sign++"&SessionID="++SessionID,
	?DEBUG_OUT("verifyRequest91 android ready.RequestString is:~p",[RequestString]),
	case httpc:request(get,{RequestString,[{"connection","false"}]},[],[]) of
		{error,Reason}->
			?DEBUG_OUT("verifyRequest91 failed.Reason is:~p",[Reason]),
			error;
		{ok,Result}->
			{Header,Options,Content}=Result,
			?DEBUG_OUT("verifyRequest91 ok.Header:~p,Options:~p,Content:~p",[Header,Options,Content]),
			Bin=unicode:characters_to_binary(Content),
			{ok,JsonObj,_}=rfc4627:decode(Bin),
			try
				Value0=rfc4627:get_field(JsonObj,"ErrorCode",<<"0">>),
				Value1=rfc4627:get_field(JsonObj,"ErrorDesc",<<"null">>),
				{ErrorCode,_}=string:to_integer(binary_to_list(Value0)),
				ErrorDesc=binary_to_list(Value1),
				?DEBUG_OUT("verifyRequest91 ok.ErrorCode:~p,ErrorDesc:~p",[ErrorCode,ErrorDesc]),
				case ErrorCode of
					1->success;
					_->failed	
				end
			catch
				_:Why->
				?DEBUG_OUT("verifyRequest91 exception.Why:~p",[Why]),
				failed
			end
        end.
