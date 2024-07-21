


-module(msg_LS2User).
-export([send/2,dealMsg/3]).
-import(messageBase, [read_string/1, read_int/1,  read_int8/1,  read_int16/1, write_array/2,
             		 write_string/1, write_int/1,  write_int8/1,  write_int16/1, write_int64/1,read_array/2, sendPackage/3] ).
-import(common, [binary_read_int64/1,binary_read_int64/2,binary_read_int16/2, binary_read_int16/1,binary_read_int/2, binary_read_int/1, binary_read_int8/2,  binary_read_string/2, binary_read_array_head16/3]).
-include("package.hrl").


write_LS2U_LoginResult(#pk_LS2U_LoginResult{}=P) -> 
	Bin0=write_int8(P#pk_LS2U_LoginResult.result),
	Bin3=write_int64(P#pk_LS2U_LoginResult.userID),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_LS2U_LoginResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_LS2U_LoginResult{
		result=D3,
		userID=D6
	},
	Left,
	Count6
	}.

write_GameServerInfo(#pk_GameServerInfo{}=P) -> 
	Bin0=write_string(P#pk_GameServerInfo.serverID),
	Bin3=write_string(P#pk_GameServerInfo.name),
	Bin6=write_int8(P#pk_GameServerInfo.state),
	Bin9=write_int8(P#pk_GameServerInfo.showIndex),
	Bin12=write_int8(P#pk_GameServerInfo.remmond),
	Bin15=write_int16(P#pk_GameServerInfo.maxPlayerLevel),
	Bin18=write_int8(P#pk_GameServerInfo.isnew),
	Bin21=write_string(P#pk_GameServerInfo.begintime),
	Bin24=write_int8(P#pk_GameServerInfo.hot),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary
	>>.

binary_read_GameServerInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int8(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int16(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int8(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_string(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_int8(Count24,Bin0),
	Count27=C27+Count24,
	{_,Left} = split_binary(Bin0,Count27),
	{#pk_GameServerInfo{
		serverID=D3,
		name=D6,
		state=D9,
		showIndex=D12,
		remmond=D15,
		maxPlayerLevel=D18,
		isnew=D21,
		begintime=D24,
		hot=D27
	},
	Left,
	Count27
	}.

write_LS2U_GameServerList(#pk_LS2U_GameServerList{}=P) -> 
	Bin0=write_array(P#pk_LS2U_GameServerList.gameServers,fun(X)-> write_GameServerInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_LS2U_GameServerList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_GameServerInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_LS2U_GameServerList{
		gameServers=D3
	},
	Left,
	Count3
	}.

write_LS2U_SelGameServerResult(#pk_LS2U_SelGameServerResult{}=P) -> 
	Bin0=write_int64(P#pk_LS2U_SelGameServerResult.userID),
	Bin3=write_string(P#pk_LS2U_SelGameServerResult.ip),
	Bin6=write_int(P#pk_LS2U_SelGameServerResult.port),
	Bin9=write_string(P#pk_LS2U_SelGameServerResult.identity),
	Bin12=write_int(P#pk_LS2U_SelGameServerResult.errorCode),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary
	>>.

binary_read_LS2U_SelGameServerResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_string(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{_,Left} = split_binary(Bin0,Count15),
	{#pk_LS2U_SelGameServerResult{
		userID=D3,
		ip=D6,
		port=D9,
		identity=D12,
		errorCode=D15
	},
	Left,
	Count15
	}.

write_U2LS_Login_553(#pk_U2LS_Login_553{}=P) -> 
	Bin0=write_string(P#pk_U2LS_Login_553.account),
	Bin3=write_int16(P#pk_U2LS_Login_553.platformID),
	Bin6=write_int64(P#pk_U2LS_Login_553.time),
	Bin9=write_string(P#pk_U2LS_Login_553.sign),
	Bin12=write_int(P#pk_U2LS_Login_553.versionRes),
	Bin15=write_int(P#pk_U2LS_Login_553.versionExe),
	Bin18=write_int(P#pk_U2LS_Login_553.versionGame),
	Bin21=write_int(P#pk_U2LS_Login_553.versionPro),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary
	>>.

binary_read_U2LS_Login_553(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int64(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_string(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_int(Count21,Bin0),
	Count24=C24+Count21,
	{_,Left} = split_binary(Bin0,Count24),
	{#pk_U2LS_Login_553{
		account=D3,
		platformID=D6,
		time=D9,
		sign=D12,
		versionRes=D15,
		versionExe=D18,
		versionGame=D21,
		versionPro=D24
	},
	Left,
	Count24
	}.

write_U2LS_Login_PP(#pk_U2LS_Login_PP{}=P) -> 
	Bin0=write_string(P#pk_U2LS_Login_PP.account),
	Bin3=write_int16(P#pk_U2LS_Login_PP.platformID),
	Bin6=write_int64(P#pk_U2LS_Login_PP.token1),
	Bin9=write_int64(P#pk_U2LS_Login_PP.token2),
	Bin12=write_int(P#pk_U2LS_Login_PP.versionRes),
	Bin15=write_int(P#pk_U2LS_Login_PP.versionExe),
	Bin18=write_int(P#pk_U2LS_Login_PP.versionGame),
	Bin21=write_int(P#pk_U2LS_Login_PP.versionPro),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary
	>>.

binary_read_U2LS_Login_PP(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int64(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int64(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_int(Count21,Bin0),
	Count24=C24+Count21,
	{_,Left} = split_binary(Bin0,Count24),
	{#pk_U2LS_Login_PP{
		account=D3,
		platformID=D6,
		token1=D9,
		token2=D12,
		versionRes=D15,
		versionExe=D18,
		versionGame=D21,
		versionPro=D24
	},
	Left,
	Count24
	}.

write_U2LS_RequestGameServerList(#pk_U2LS_RequestGameServerList{}=P) -> 
	Bin0=write_int(P#pk_U2LS_RequestGameServerList.reserve),
	<<Bin0/binary
	>>.

binary_read_U2LS_RequestGameServerList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2LS_RequestGameServerList{
		reserve=D3
	},
	Left,
	Count3
	}.

write_U2LS_RequestSelGameServer(#pk_U2LS_RequestSelGameServer{}=P) -> 
	Bin0=write_string(P#pk_U2LS_RequestSelGameServer.serverID),
	<<Bin0/binary
	>>.

binary_read_U2LS_RequestSelGameServer(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2LS_RequestSelGameServer{
		serverID=D3
	},
	Left,
	Count3
	}.

write_LS2U_ServerInfo(#pk_LS2U_ServerInfo{}=P) -> 
	Bin0=write_int16(P#pk_LS2U_ServerInfo.lsid),
	Bin3=write_string(P#pk_LS2U_ServerInfo.client_ip),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_LS2U_ServerInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_LS2U_ServerInfo{
		lsid=D3,
		client_ip=D6
	},
	Left,
	Count6
	}.

write_U2LS_Login_APPS(#pk_U2LS_Login_APPS{}=P) -> 
	Bin0=write_string(P#pk_U2LS_Login_APPS.account),
	Bin3=write_int16(P#pk_U2LS_Login_APPS.platformID),
	Bin6=write_int64(P#pk_U2LS_Login_APPS.time),
	Bin9=write_string(P#pk_U2LS_Login_APPS.sign),
	Bin12=write_int(P#pk_U2LS_Login_APPS.versionRes),
	Bin15=write_int(P#pk_U2LS_Login_APPS.versionExe),
	Bin18=write_int(P#pk_U2LS_Login_APPS.versionGame),
	Bin21=write_int(P#pk_U2LS_Login_APPS.versionPro),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary
	>>.

binary_read_U2LS_Login_APPS(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int64(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_string(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_int(Count21,Bin0),
	Count24=C24+Count21,
	{_,Left} = split_binary(Bin0,Count24),
	{#pk_U2LS_Login_APPS{
		account=D3,
		platformID=D6,
		time=D9,
		sign=D12,
		versionRes=D15,
		versionExe=D18,
		versionGame=D21,
		versionPro=D24
	},
	Left,
	Count24
	}.

write_U2LS_Login_360(#pk_U2LS_Login_360{}=P) -> 
	Bin0=write_string(P#pk_U2LS_Login_360.account),
	Bin3=write_int16(P#pk_U2LS_Login_360.platformID),
	Bin6=write_string(P#pk_U2LS_Login_360.authoCode),
	Bin9=write_int(P#pk_U2LS_Login_360.versionRes),
	Bin12=write_int(P#pk_U2LS_Login_360.versionExe),
	Bin15=write_int(P#pk_U2LS_Login_360.versionGame),
	Bin18=write_int(P#pk_U2LS_Login_360.versionPro),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary
	>>.

binary_read_U2LS_Login_360(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
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
	{#pk_U2LS_Login_360{
		account=D3,
		platformID=D6,
		authoCode=D9,
		versionRes=D12,
		versionExe=D15,
		versionGame=D18,
		versionPro=D21
	},
	Left,
	Count21
	}.

write_LS2U_Login_360(#pk_LS2U_Login_360{}=P) -> 
	Bin0=write_string(P#pk_LS2U_Login_360.account),
	Bin3=write_string(P#pk_LS2U_Login_360.userid),
	Bin6=write_string(P#pk_LS2U_Login_360.access_token),
	Bin9=write_string(P#pk_LS2U_Login_360.refresh_token),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_LS2U_Login_360(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_string(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_LS2U_Login_360{
		account=D3,
		userid=D6,
		access_token=D9,
		refresh_token=D12
	},
	Left,
	Count12
	}.

write_U2LS_Login_UC(#pk_U2LS_Login_UC{}=P) -> 
	Bin0=write_string(P#pk_U2LS_Login_UC.account),
	Bin3=write_int16(P#pk_U2LS_Login_UC.platformID),
	Bin6=write_string(P#pk_U2LS_Login_UC.authoCode),
	Bin9=write_int(P#pk_U2LS_Login_UC.versionRes),
	Bin12=write_int(P#pk_U2LS_Login_UC.versionExe),
	Bin15=write_int(P#pk_U2LS_Login_UC.versionGame),
	Bin18=write_int(P#pk_U2LS_Login_UC.versionPro),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary
	>>.

binary_read_U2LS_Login_UC(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
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
	{#pk_U2LS_Login_UC{
		account=D3,
		platformID=D6,
		authoCode=D9,
		versionRes=D12,
		versionExe=D15,
		versionGame=D18,
		versionPro=D21
	},
	Left,
	Count21
	}.

write_LS2U_Login_UC(#pk_LS2U_Login_UC{}=P) -> 
	Bin0=write_string(P#pk_LS2U_Login_UC.account),
	Bin3=write_int64(P#pk_LS2U_Login_UC.userid),
	Bin6=write_string(P#pk_LS2U_Login_UC.nickName),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_LS2U_Login_UC(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_LS2U_Login_UC{
		account=D3,
		userid=D6,
		nickName=D9
	},
	Left,
	Count9
	}.

write_U2LS_Login_91(#pk_U2LS_Login_91{}=P) -> 
	Bin0=write_string(P#pk_U2LS_Login_91.account),
	Bin3=write_int16(P#pk_U2LS_Login_91.platformID),
	Bin6=write_string(P#pk_U2LS_Login_91.uin),
	Bin9=write_string(P#pk_U2LS_Login_91.sessionID),
	Bin12=write_int(P#pk_U2LS_Login_91.versionRes),
	Bin15=write_int(P#pk_U2LS_Login_91.versionExe),
	Bin18=write_int(P#pk_U2LS_Login_91.versionGame),
	Bin21=write_int(P#pk_U2LS_Login_91.versionPro),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary
	>>.

binary_read_U2LS_Login_91(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_string(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_int(Count21,Bin0),
	Count24=C24+Count21,
	{_,Left} = split_binary(Bin0,Count24),
	{#pk_U2LS_Login_91{
		account=D3,
		platformID=D6,
		uin=D9,
		sessionID=D12,
		versionRes=D15,
		versionExe=D18,
		versionGame=D21,
		versionPro=D24
	},
	Left,
	Count24
	}.

write_LS2U_Login_91(#pk_LS2U_Login_91{}=P) -> 
	Bin0=write_string(P#pk_LS2U_Login_91.account),
	Bin3=write_string(P#pk_LS2U_Login_91.userid),
	Bin6=write_string(P#pk_LS2U_Login_91.access_token),
	Bin9=write_string(P#pk_LS2U_Login_91.refresh_token),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_LS2U_Login_91(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_string(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_LS2U_Login_91{
		account=D3,
		userid=D6,
		access_token=D9,
		refresh_token=D12
	},
	Left,
	Count12
	}.


send(Socket,#pk_LS2U_LoginResult{}=P) ->

	Bin = write_LS2U_LoginResult(P),
	sendPackage(Socket,?CMD_LS2U_LoginResult,Bin);



send(Socket,#pk_LS2U_GameServerList{}=P) ->

	Bin = write_LS2U_GameServerList(P),
	sendPackage(Socket,?CMD_LS2U_GameServerList,Bin);


send(Socket,#pk_LS2U_SelGameServerResult{}=P) ->

	Bin = write_LS2U_SelGameServerResult(P),
	sendPackage(Socket,?CMD_LS2U_SelGameServerResult,Bin);






send(Socket,#pk_LS2U_ServerInfo{}=P) ->

	Bin = write_LS2U_ServerInfo(P),
	sendPackage(Socket,?CMD_LS2U_ServerInfo,Bin);




send(Socket,#pk_LS2U_Login_360{}=P) ->

	Bin = write_LS2U_Login_360(P),
	sendPackage(Socket,?CMD_LS2U_Login_360,Bin);



send(Socket,#pk_LS2U_Login_UC{}=P) ->

	Bin = write_LS2U_Login_UC(P),
	sendPackage(Socket,?CMD_LS2U_Login_UC,Bin);



send(Socket,#pk_LS2U_Login_91{}=P) ->

	Bin = write_LS2U_Login_91(P),
	sendPackage(Socket,?CMD_LS2U_Login_91,Bin);

send(_,_)-> 
	noMatch.


dealMsg(Socket,Cmd,Bin2) -> 
	case Cmd of
	?CMD_U2LS_Login_553->
		{Pk,_,_} = binary_read_U2LS_Login_553(Bin2),
		messageOn:on_U2LS_Login_553(Socket,Pk);
	?CMD_U2LS_Login_PP->
		{Pk,_,_} = binary_read_U2LS_Login_PP(Bin2),
		messageOn:on_U2LS_Login_PP(Socket,Pk);
	?CMD_U2LS_RequestGameServerList->
		{Pk,_,_} = binary_read_U2LS_RequestGameServerList(Bin2),
		messageOn:on_U2LS_RequestGameServerList(Socket,Pk);
	?CMD_U2LS_RequestSelGameServer->
		{Pk,_,_} = binary_read_U2LS_RequestSelGameServer(Bin2),
		messageOn:on_U2LS_RequestSelGameServer(Socket,Pk);
	?CMD_U2LS_Login_APPS->
		{Pk,_,_} = binary_read_U2LS_Login_APPS(Bin2),
		messageOn:on_U2LS_Login_APPS(Socket,Pk);
	?CMD_U2LS_Login_360->
		{Pk,_,_} = binary_read_U2LS_Login_360(Bin2),
		messageOn:on_U2LS_Login_360(Socket,Pk);
	?CMD_U2LS_Login_UC->
		{Pk,_,_} = binary_read_U2LS_Login_UC(Bin2),
		messageOn:on_U2LS_Login_UC(Socket,Pk);
	?CMD_U2LS_Login_91->
		{Pk,_,_} = binary_read_U2LS_Login_91(Bin2),
		messageOn:on_U2LS_Login_91(Socket,Pk);
		_-> 
		noMatch
	end.
