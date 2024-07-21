


-module(msg_LS2GS).
-export([send/2,dealMsg/3]).
-import(messageBase, [read_string/1, read_int/1,  read_int8/1,  read_int16/1, write_array/2,
             		 write_string/1, write_int/1,  write_int8/1,  write_int16/1, write_int64/1,read_array/2, sendPackage/3] ).
-import(common, [binary_read_int64/1,binary_read_int64/2,binary_read_int16/2, binary_read_int16/1,binary_read_int/2, binary_read_int/1, binary_read_int8/2,  binary_read_string/2, binary_read_array_head16/3]).
-include("package.hrl").


write_LS2GS_LoginResult(#pk_LS2GS_LoginResult{}=P) -> 
	Bin0=write_int(P#pk_LS2GS_LoginResult.reserve),
	<<Bin0/binary
	>>.

binary_read_LS2GS_LoginResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_LS2GS_LoginResult{
		reserve=D3
	},
	Left,
	Count3
	}.

write_LS2GS_QueryUserMaxLevel(#pk_LS2GS_QueryUserMaxLevel{}=P) -> 
	Bin0=write_int64(P#pk_LS2GS_QueryUserMaxLevel.userID),
	<<Bin0/binary
	>>.

binary_read_LS2GS_QueryUserMaxLevel(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_LS2GS_QueryUserMaxLevel{
		userID=D3
	},
	Left,
	Count3
	}.

write_LS2GS_UserReadyToLogin(#pk_LS2GS_UserReadyToLogin{}=P) -> 
	Bin0=write_int64(P#pk_LS2GS_UserReadyToLogin.userID),
	Bin3=write_string(P#pk_LS2GS_UserReadyToLogin.username),
	Bin6=write_string(P#pk_LS2GS_UserReadyToLogin.identity),
	Bin9=write_int(P#pk_LS2GS_UserReadyToLogin.platId),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_LS2GS_UserReadyToLogin(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_LS2GS_UserReadyToLogin{
		userID=D3,
		username=D6,
		identity=D9,
		platId=D12
	},
	Left,
	Count12
	}.

write_LS2GS_KickOutUser(#pk_LS2GS_KickOutUser{}=P) -> 
	Bin0=write_int64(P#pk_LS2GS_KickOutUser.userID),
	Bin3=write_string(P#pk_LS2GS_KickOutUser.identity),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_LS2GS_KickOutUser(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_LS2GS_KickOutUser{
		userID=D3,
		identity=D6
	},
	Left,
	Count6
	}.

write_LS2GS_ActiveCode(#pk_LS2GS_ActiveCode{}=P) -> 
	Bin0=write_string(P#pk_LS2GS_ActiveCode.pidStr),
	Bin3=write_string(P#pk_LS2GS_ActiveCode.activeCode),
	Bin6=write_string(P#pk_LS2GS_ActiveCode.playerName),
	Bin9=write_int(P#pk_LS2GS_ActiveCode.type),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_LS2GS_ActiveCode(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_LS2GS_ActiveCode{
		pidStr=D3,
		activeCode=D6,
		playerName=D9,
		type=D12
	},
	Left,
	Count12
	}.

write_GS2LS_Request_Login(#pk_GS2LS_Request_Login{}=P) -> 
	Bin0=write_string(P#pk_GS2LS_Request_Login.serverID),
	Bin3=write_string(P#pk_GS2LS_Request_Login.name),
	Bin6=write_string(P#pk_GS2LS_Request_Login.ip),
	Bin9=write_int(P#pk_GS2LS_Request_Login.port),
	Bin12=write_int(P#pk_GS2LS_Request_Login.remmond),
	Bin15=write_int(P#pk_GS2LS_Request_Login.showInUserGameList),
	Bin18=write_int(P#pk_GS2LS_Request_Login.hot),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary
	>>.

binary_read_GS2LS_Request_Login(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int(Count18,Bin0),
	Count21=C21+Count18,
	{_,Left} = split_binary(Bin0,Count21),
	{#pk_GS2LS_Request_Login{
		serverID=D3,
		name=D6,
		ip=D9,
		port=D12,
		remmond=D15,
		showInUserGameList=D18,
		hot=D21
	},
	Left,
	Count21
	}.

write_GS2LS_ReadyToAcceptUser(#pk_GS2LS_ReadyToAcceptUser{}=P) -> 
	Bin0=write_int(P#pk_GS2LS_ReadyToAcceptUser.reserve),
	<<Bin0/binary
	>>.

binary_read_GS2LS_ReadyToAcceptUser(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2LS_ReadyToAcceptUser{
		reserve=D3
	},
	Left,
	Count3
	}.

write_GS2LS_OnlinePlayers(#pk_GS2LS_OnlinePlayers{}=P) -> 
	Bin0=write_int(P#pk_GS2LS_OnlinePlayers.playerCount),
	<<Bin0/binary
	>>.

binary_read_GS2LS_OnlinePlayers(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2LS_OnlinePlayers{
		playerCount=D3
	},
	Left,
	Count3
	}.

write_GS2LS_QueryUserMaxLevelResult(#pk_GS2LS_QueryUserMaxLevelResult{}=P) -> 
	Bin0=write_int64(P#pk_GS2LS_QueryUserMaxLevelResult.userID),
	Bin3=write_int(P#pk_GS2LS_QueryUserMaxLevelResult.maxLevel),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2LS_QueryUserMaxLevelResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2LS_QueryUserMaxLevelResult{
		userID=D3,
		maxLevel=D6
	},
	Left,
	Count6
	}.

write_GS2LS_UserReadyLoginResult(#pk_GS2LS_UserReadyLoginResult{}=P) -> 
	Bin0=write_int64(P#pk_GS2LS_UserReadyLoginResult.userID),
	Bin3=write_int(P#pk_GS2LS_UserReadyLoginResult.result),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2LS_UserReadyLoginResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2LS_UserReadyLoginResult{
		userID=D3,
		result=D6
	},
	Left,
	Count6
	}.

write_GS2LS_UserLoginGameServer(#pk_GS2LS_UserLoginGameServer{}=P) -> 
	Bin0=write_int64(P#pk_GS2LS_UserLoginGameServer.userID),
	<<Bin0/binary
	>>.

binary_read_GS2LS_UserLoginGameServer(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2LS_UserLoginGameServer{
		userID=D3
	},
	Left,
	Count3
	}.

write_GS2LS_UserLogoutGameServer(#pk_GS2LS_UserLogoutGameServer{}=P) -> 
	Bin0=write_int64(P#pk_GS2LS_UserLogoutGameServer.userID),
	Bin3=write_string(P#pk_GS2LS_UserLogoutGameServer.identity),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2LS_UserLogoutGameServer(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2LS_UserLogoutGameServer{
		userID=D3,
		identity=D6
	},
	Left,
	Count6
	}.

write_GS2LS_ActiveCode(#pk_GS2LS_ActiveCode{}=P) -> 
	Bin0=write_string(P#pk_GS2LS_ActiveCode.pidStr),
	Bin3=write_string(P#pk_GS2LS_ActiveCode.activeCode),
	Bin6=write_int(P#pk_GS2LS_ActiveCode.retcode),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_GS2LS_ActiveCode(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_GS2LS_ActiveCode{
		pidStr=D3,
		activeCode=D6,
		retcode=D9
	},
	Left,
	Count9
	}.

write_LS2GS_Announce(#pk_LS2GS_Announce{}=P) -> 
	Bin0=write_string(P#pk_LS2GS_Announce.pidStr),
	Bin3=write_string(P#pk_LS2GS_Announce.announceInfo),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_LS2GS_Announce(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_LS2GS_Announce{
		pidStr=D3,
		announceInfo=D6
	},
	Left,
	Count6
	}.

write_LS2GS_Command(#pk_LS2GS_Command{}=P) -> 
	Bin0=write_string(P#pk_LS2GS_Command.pidStr),
	Bin3=write_int(P#pk_LS2GS_Command.num),
	Bin6=write_int(P#pk_LS2GS_Command.cmd),
	Bin9=write_string(P#pk_LS2GS_Command.params),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_LS2GS_Command(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_string(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_LS2GS_Command{
		pidStr=D3,
		num=D6,
		cmd=D9,
		params=D12
	},
	Left,
	Count12
	}.

write_GS2LS_Command(#pk_GS2LS_Command{}=P) -> 
	Bin0=write_string(P#pk_GS2LS_Command.pidStr),
	Bin3=write_int(P#pk_GS2LS_Command.num),
	Bin6=write_int(P#pk_GS2LS_Command.cmd),
	Bin9=write_int(P#pk_GS2LS_Command.retcode),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_GS2LS_Command(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_GS2LS_Command{
		pidStr=D3,
		num=D6,
		cmd=D9,
		retcode=D12
	},
	Left,
	Count12
	}.

write_LS2GS_Recharge(#pk_LS2GS_Recharge{}=P) -> 
	Bin0=write_string(P#pk_LS2GS_Recharge.pidStr),
	Bin3=write_string(P#pk_LS2GS_Recharge.orderid),
	Bin6=write_int(P#pk_LS2GS_Recharge.platform),
	Bin9=write_string(P#pk_LS2GS_Recharge.account),
	Bin12=write_int64(P#pk_LS2GS_Recharge.userid),
	Bin15=write_int64(P#pk_LS2GS_Recharge.playerid),
	Bin18=write_int(P#pk_LS2GS_Recharge.ammount),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary
	>>.

binary_read_LS2GS_Recharge(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_string(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int64(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int64(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int(Count18,Bin0),
	Count21=C21+Count18,
	{_,Left} = split_binary(Bin0,Count21),
	{#pk_LS2GS_Recharge{
		pidStr=D3,
		orderid=D6,
		platform=D9,
		account=D12,
		userid=D15,
		playerid=D18,
		ammount=D21
	},
	Left,
	Count21
	}.

write_GS2LS_Recharge(#pk_GS2LS_Recharge{}=P) -> 
	Bin0=write_string(P#pk_GS2LS_Recharge.pidStr),
	Bin3=write_string(P#pk_GS2LS_Recharge.orderid),
	Bin6=write_int(P#pk_GS2LS_Recharge.platform),
	Bin9=write_int(P#pk_GS2LS_Recharge.retcode),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_GS2LS_Recharge(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_GS2LS_Recharge{
		pidStr=D3,
		orderid=D6,
		platform=D9,
		retcode=D12
	},
	Left,
	Count12
	}.


send(Socket,#pk_LS2GS_LoginResult{}=P) ->

	Bin = write_LS2GS_LoginResult(P),
	sendPackage(Socket,?CMD_LS2GS_LoginResult,Bin);


send(Socket,#pk_LS2GS_QueryUserMaxLevel{}=P) ->

	Bin = write_LS2GS_QueryUserMaxLevel(P),
	sendPackage(Socket,?CMD_LS2GS_QueryUserMaxLevel,Bin);


send(Socket,#pk_LS2GS_UserReadyToLogin{}=P) ->

	Bin = write_LS2GS_UserReadyToLogin(P),
	sendPackage(Socket,?CMD_LS2GS_UserReadyToLogin,Bin);


send(Socket,#pk_LS2GS_KickOutUser{}=P) ->

	Bin = write_LS2GS_KickOutUser(P),
	sendPackage(Socket,?CMD_LS2GS_KickOutUser,Bin);


send(Socket,#pk_LS2GS_ActiveCode{}=P) ->

	Bin = write_LS2GS_ActiveCode(P),
	sendPackage(Socket,?CMD_LS2GS_ActiveCode,Bin);


send(Socket,#pk_GS2LS_Request_Login{}=P) ->

	Bin = write_GS2LS_Request_Login(P),
	sendPackage(Socket,?CMD_GS2LS_Request_Login,Bin);


send(Socket,#pk_GS2LS_ReadyToAcceptUser{}=P) ->

	Bin = write_GS2LS_ReadyToAcceptUser(P),
	sendPackage(Socket,?CMD_GS2LS_ReadyToAcceptUser,Bin);


send(Socket,#pk_GS2LS_OnlinePlayers{}=P) ->

	Bin = write_GS2LS_OnlinePlayers(P),
	sendPackage(Socket,?CMD_GS2LS_OnlinePlayers,Bin);


send(Socket,#pk_GS2LS_QueryUserMaxLevelResult{}=P) ->

	Bin = write_GS2LS_QueryUserMaxLevelResult(P),
	sendPackage(Socket,?CMD_GS2LS_QueryUserMaxLevelResult,Bin);


send(Socket,#pk_GS2LS_UserReadyLoginResult{}=P) ->

	Bin = write_GS2LS_UserReadyLoginResult(P),
	sendPackage(Socket,?CMD_GS2LS_UserReadyLoginResult,Bin);


send(Socket,#pk_GS2LS_UserLoginGameServer{}=P) ->

	Bin = write_GS2LS_UserLoginGameServer(P),
	sendPackage(Socket,?CMD_GS2LS_UserLoginGameServer,Bin);


send(Socket,#pk_GS2LS_UserLogoutGameServer{}=P) ->

	Bin = write_GS2LS_UserLogoutGameServer(P),
	sendPackage(Socket,?CMD_GS2LS_UserLogoutGameServer,Bin);


send(Socket,#pk_GS2LS_ActiveCode{}=P) ->

	Bin = write_GS2LS_ActiveCode(P),
	sendPackage(Socket,?CMD_GS2LS_ActiveCode,Bin);


send(Socket,#pk_LS2GS_Announce{}=P) ->

	Bin = write_LS2GS_Announce(P),
	sendPackage(Socket,?CMD_LS2GS_Announce,Bin);


send(Socket,#pk_LS2GS_Command{}=P) ->

	Bin = write_LS2GS_Command(P),
	sendPackage(Socket,?CMD_LS2GS_Command,Bin);


send(Socket,#pk_GS2LS_Command{}=P) ->

	Bin = write_GS2LS_Command(P),
	sendPackage(Socket,?CMD_GS2LS_Command,Bin);


send(Socket,#pk_LS2GS_Recharge{}=P) ->

	Bin = write_LS2GS_Recharge(P),
	sendPackage(Socket,?CMD_LS2GS_Recharge,Bin);


send(Socket,#pk_GS2LS_Recharge{}=P) ->

	Bin = write_GS2LS_Recharge(P),
	sendPackage(Socket,?CMD_GS2LS_Recharge,Bin);

send(_,_)-> 
	noMatch.


dealMsg(Socket,Cmd,Bin2) -> 
	case Cmd of
	?CMD_LS2GS_LoginResult->
		{Pk,_,_} = binary_read_LS2GS_LoginResult(Bin2),
		messageOn:on_LS2GS_LoginResult(Socket,Pk);
	?CMD_LS2GS_QueryUserMaxLevel->
		{Pk,_,_} = binary_read_LS2GS_QueryUserMaxLevel(Bin2),
		messageOn:on_LS2GS_QueryUserMaxLevel(Socket,Pk);
	?CMD_LS2GS_UserReadyToLogin->
		{Pk,_,_} = binary_read_LS2GS_UserReadyToLogin(Bin2),
		messageOn:on_LS2GS_UserReadyToLogin(Socket,Pk);
	?CMD_LS2GS_KickOutUser->
		{Pk,_,_} = binary_read_LS2GS_KickOutUser(Bin2),
		messageOn:on_LS2GS_KickOutUser(Socket,Pk);
	?CMD_LS2GS_ActiveCode->
		{Pk,_,_} = binary_read_LS2GS_ActiveCode(Bin2),
		messageOn:on_LS2GS_ActiveCode(Socket,Pk);
	?CMD_GS2LS_Request_Login->
		{Pk,_,_} = binary_read_GS2LS_Request_Login(Bin2),
		messageOn:on_GS2LS_Request_Login(Socket,Pk);
	?CMD_GS2LS_ReadyToAcceptUser->
		{Pk,_,_} = binary_read_GS2LS_ReadyToAcceptUser(Bin2),
		messageOn:on_GS2LS_ReadyToAcceptUser(Socket,Pk);
	?CMD_GS2LS_OnlinePlayers->
		{Pk,_,_} = binary_read_GS2LS_OnlinePlayers(Bin2),
		messageOn:on_GS2LS_OnlinePlayers(Socket,Pk);
	?CMD_GS2LS_QueryUserMaxLevelResult->
		{Pk,_,_} = binary_read_GS2LS_QueryUserMaxLevelResult(Bin2),
		messageOn:on_GS2LS_QueryUserMaxLevelResult(Socket,Pk);
	?CMD_GS2LS_UserReadyLoginResult->
		{Pk,_,_} = binary_read_GS2LS_UserReadyLoginResult(Bin2),
		messageOn:on_GS2LS_UserReadyLoginResult(Socket,Pk);
	?CMD_GS2LS_UserLoginGameServer->
		{Pk,_,_} = binary_read_GS2LS_UserLoginGameServer(Bin2),
		messageOn:on_GS2LS_UserLoginGameServer(Socket,Pk);
	?CMD_GS2LS_UserLogoutGameServer->
		{Pk,_,_} = binary_read_GS2LS_UserLogoutGameServer(Bin2),
		messageOn:on_GS2LS_UserLogoutGameServer(Socket,Pk);
	?CMD_GS2LS_ActiveCode->
		{Pk,_,_} = binary_read_GS2LS_ActiveCode(Bin2),
		messageOn:on_GS2LS_ActiveCode(Socket,Pk);
	?CMD_LS2GS_Announce->
		{Pk,_,_} = binary_read_LS2GS_Announce(Bin2),
		messageOn:on_LS2GS_Announce(Socket,Pk);
	?CMD_LS2GS_Command->
		{Pk,_,_} = binary_read_LS2GS_Command(Bin2),
		messageOn:on_LS2GS_Command(Socket,Pk);
	?CMD_GS2LS_Command->
		{Pk,_,_} = binary_read_GS2LS_Command(Bin2),
		messageOn:on_GS2LS_Command(Socket,Pk);
	?CMD_LS2GS_Recharge->
		{Pk,_,_} = binary_read_LS2GS_Recharge(Bin2),
		messageOn:on_LS2GS_Recharge(Socket,Pk);
	?CMD_GS2LS_Recharge->
		{Pk,_,_} = binary_read_GS2LS_Recharge(Bin2),
		messageOn:on_GS2LS_Recharge(Socket,Pk);
		_-> 
		noMatch
	end.
