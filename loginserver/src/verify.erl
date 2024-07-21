%% Author: yueliangyou
%% Created: 2013-3-6
%% Description: TODO: platform verify
-module(verify).

%%
%% Include files
%%
-include("platformDefine.hrl").
-include("hdlt_logger.hrl").


%%
%% Exported Functions
%%
-compile(export_all).

%% 测试平台验证
verifyTest(Account,IP)->
	?DEBUG_OUT("verifyTest Account=~p,IP=~p",[Account,IP]),
	case platform553:isTestCheck() of
		true->
			case loginMysqlProc:get_platform_test(Account,IP) > 0 of
				true->success;
				false->
					?LOG_OUT("verifyTest failed. Account:[~p],IP:[~p]",[Account,IP]),failed
			end;
		false->
			success
	end.

%%553平台验证
verify553(Account,Time,Sign)->
	?DEBUG_OUT("verify553 Account:[~p],Time[~p],Sign[~p]",[Account,Time,Sign]),
	case md5:encrypt(common:formatString(Time)++Account++?KEY_PLATFORM_553_VERIFY) of 
	Sign->
		success;
	_->
		?LOG_OUT("verify553 TimeString:[~p],Key:[~p],md5:encrypt[~p]",[common:formatString(Time),?KEY_PLATFORM_553_VERIFY,md5:encrypt(common:formatString(Time)++Account++?KEY_PLATFORM_553_VERIFY)]),
		failed
	end.

verify553_android(Account,Time,Sign)->
	?DEBUG_OUT("verify553_android Account:[~p],Time[~p],Sign[~p]",[Account,Time,Sign]),
	case md5:encrypt(common:formatString(Time)++Account++?KEY_PLATFORM_553_ANDROID_VERIFY) of 
	Sign->
		success;
	_->
		?LOG_OUT("verify553_android TimeString:[~p],Key:[~p],md5:encrypt[~p]",[common:formatString(Time),?KEY_PLATFORM_553_ANDROID_VERIFY,md5:encrypt(common:formatString(Time)++Account++?KEY_PLATFORM_553_ANDROID_VERIFY)]),
		failed
	end.

%%苹果平台验证
verifyAPPS(Account,Time,Sign)->
	?DEBUG_OUT("verifyAPPS Account:[~p],Time[~p],Sign[~p]",[Account,Time,Sign]),
	case md5:encrypt(common:formatString(Time)++Account++?KEY_PLATFORM_APPS_VERIFY) of 
	Sign->
		success;
	_->
		?LOG_OUT("verify553 TimeString:[~p],Key:[~p],md5:encrypt[~p]",[common:formatString(Time),?KEY_PLATFORM_APPS_VERIFY,md5:encrypt(common:formatString(Time)++Account++?KEY_PLATFORM_APPS_VERIFY)]),
		failed
	end.

%%皮皮平台验证
verifyPP(Account,Token1,Token2)->
	?LOG_OUT("verifyPP Account:[~p],Token1[~p],Token2[~p]",[Account,Token1,Token2]),
	%% 合成Token串
	Bin0 = messageBase:write_int64(Token1),
	Bin1 = messageBase:write_int64(Token2),
	Token= <<Bin0/binary,Bin1/binary>>,
	?DEBUG_OUT("verifyPP Token[~p]",[Token]),
	platformPP:verifyRequestPP(Account,Token).

%%360平台验证
verify360(Code)->
	?LOG_OUT("verify360 Code[~p]",[Code]),
	platform360:verifyRequest360(Code).

%%UC平台验证
verifyUC(Code)->
	?LOG_OUT("verifyUC Code[~p]",[Code]),
	platformUC:verifyRequestUC(Code).

%% 91平台验证
verify91(Platform,Uin,SessionID)->
	?LOG_OUT("verify91 Platform[~p],Uin[~p],SessionID[~p]",[Platform,Uin,SessionID]),
	platform91:verifyRequest91(Platform,Uin,SessionID).


