%% Author: yueliangyou
%% Created: 2013-4-13
%% Description: TODO: 
-module(platformUC).

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
	?LOG_OUT( "platform UC module supported." ),
	ets:insert(platformtable,#platformTable{platformID=?PLATFORM_UC_android,isSupport=1,ip=IP,port=Port}),
    ?LOG_OUT( "platform UC:~p",[ets:lookup(platformtable,?PLATFORM_UC_android)] ).

isUCSupport()->
    ?DEBUG_OUT( "platform UC:~p",[ets:lookup(platformtable,?PLATFORM_UC_android)] ),
	Ret=ets:lookup(platformtable,?PLATFORM_UC_android),
        case Ret of
                [] ->no;
                [H|[]]->[{_,_,Support,_,_}|_Set]=Ret,
                        case Support of
                                1->yes;
                                _->no
                        end
        end.

getUCServerIP()->
	Record = etsBaseFunc:readRecord(platformtable, ?PLATFORM_UC_android),
	case Record of
		{}->
			?ERROR_OUT( "getUCServerIP = {}" ),
			"";
		_->Record#platformTable.ip
	end.

getUCServerPort()->
	Record = etsBaseFunc:readRecord(platformtable, ?PLATFORM_UC_android),
	case Record of
		{}->
			?ERROR_OUT( "getUCServerPort = {}" ),
			0;
		_->Record#platformTable.port
	end.

makePostUCJson( ID, Service, Data_sid )->
	UCPort = getUCServerPort(),
	case UCPort =:= 0 of
		true->
			AppKey = ?UC_Officially_apiKey,
			Game_cpid = ?UC_Officially_CPID,
			Game_gameid = ?UC_Officially_GameID,
			Game_channelId = ?UC_Officially_ChannelID,
			Game_serverId = ?UC_Officially_ServerID;
		false->
			AppKey = ?UC_Test_apiKey,
			Game_cpid = ?UC_Test_CPID,
			Game_gameid = ?UC_Test_GameID,
			Game_channelId = ?UC_Test_ChannelID,
			Game_serverId = ?UC_Test_ServerID
	end,
	
	?DEBUG_OUT( "makePostUCJson ID[~p], Service[~p], Data_sid[~p] UCPort[~p]",
				[ID, Service, Data_sid, UCPort] ),
	
	Md5String = common:formatString( Game_cpid ) ++ "sid=" ++ Data_sid ++ AppKey,
	?DEBUG_OUT( "makePostUCJson Md5String:~p", [Md5String] ),
	
	Sign = md5:encrypt(Md5String),
	
	Data = { obj, [{"id",ID},
				   {"service",list_to_binary(Service)},
				   {"data",{obj, [
									{"sid",list_to_binary(Data_sid)}
								]
							}
					},
				   {"game",{obj, [
									{"cpId",Game_cpid},
									{"gameId",Game_gameid},
									{"channelId",list_to_binary(Game_channelId)},
									{"serverId",Game_serverId}
								]
							}
					},
					{"sign",list_to_binary(Sign)}
				   ]
			},
	
	DataOut = rfc4627:encode(Data),
	?DEBUG_OUT( "makePostUCJson Data[~p]", [DataOut] ),
	DataOut.

verifyRequestUC(Code)->
	URL = getUCServerIP(),
	%URL = "http://sdk.test4.g.uc.cn/ss",
	Request_Body = makePostUCJson( common:timestamp(), "ucid.user.sidInfo", Code ),
	Request_Header = [],
	Request_Type = "application/json",
	Request_HTTPOptions = [],
	Request_Options = [],
	
	?DEBUG_OUT("verifyRequestUC URL:~p",[URL]),
	
	case httpc:request(post,{URL, Request_Header, Request_Type, Request_Body}, Request_HTTPOptions, Request_Options) of
		{error,Reason}->
			?DEBUG_OUT("verifyRequestUC failed.Reason is:~p",[Reason]),
			error;
		{ok,Result}->
			{Header,Options,Content}=Result,
			?DEBUG_OUT("verifyRequestUC ok.Header:~p,Options:~p,Content:~p",[Header,Options,Content]),
			Bin=unicode:characters_to_binary(Content),
			{ok,JsonObj,_}=rfc4627:decode(Bin),
			try
				State_Record=rfc4627:get_field(JsonObj,"state",{}),
				State_code = rfc4627:get_field(State_Record,"code",<<"0">>),
				
				case State_code of
					1->
						Data_Record=rfc4627:get_field(JsonObj,"data",{}),
						Data_ucid = rfc4627:get_field(Data_Record,"ucid",<<"0">>),
						Data_nickName = binary_to_list(rfc4627:get_field(Data_Record,"nickName",<<"null">>)),
						Data_nickName2 = lists:flatten( Data_nickName ),
						{success,State_code,Data_ucid,Data_nickName2};
					_->
						?DEBUG_OUT( "verifyRequestUC Code[~p] State_code[~p] false", [Code, State_code] ),
						failed
				end
			catch
				_:Why->
				?DEBUG_OUT("verifyRequestUC exception.Why:~p",[Why]),
				failed
			end
        end.

