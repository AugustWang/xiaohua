


-module(msg_mount).
-export([send/2,dealMsg/3]).
-import(messageBase, [read_string/1, read_int/1,  read_int8/1,  read_int16/1, write_array/2,
             		 write_string/1, write_int/1,  write_int8/1,  write_int16/1, write_int64/1,read_array/2, sendPackage/3] ).
-import(common, [binary_read_int64/1,binary_read_int64/2,binary_read_int16/2, binary_read_int16/1,binary_read_int/2, binary_read_int/1, binary_read_int8/2,  binary_read_string/2, binary_read_array_head16/3]).
-include("package.hrl").


write_mountInfo(#pk_mountInfo{}=P) -> 
	Bin0=write_int8(P#pk_mountInfo.mountDataID),
	Bin3=write_int8(P#pk_mountInfo.level),
	Bin6=write_int8(P#pk_mountInfo.equiped),
	Bin9=write_int8(P#pk_mountInfo.progress),
	Bin12=write_int(P#pk_mountInfo.benison_Value),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary
	>>.

binary_read_mountInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{_,Left} = split_binary(Bin0,Count15),
	{#pk_mountInfo{
		mountDataID=D3,
		level=D6,
		equiped=D9,
		progress=D12,
		benison_Value=D15
	},
	Left,
	Count15
	}.

write_U2GS_QueryMyMountInfo(#pk_U2GS_QueryMyMountInfo{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_QueryMyMountInfo.reserve),
	<<Bin0/binary
	>>.

binary_read_U2GS_QueryMyMountInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_QueryMyMountInfo{
		reserve=D3
	},
	Left,
	Count3
	}.

write_GS2U_QueryMyMountInfoResult(#pk_GS2U_QueryMyMountInfoResult{}=P) -> 
	Bin0=write_array(P#pk_GS2U_QueryMyMountInfoResult.mounts,fun(X)-> write_mountInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_QueryMyMountInfoResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_mountInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_QueryMyMountInfoResult{
		mounts=D3
	},
	Left,
	Count3
	}.

write_GS2U_MountInfoUpdate(#pk_GS2U_MountInfoUpdate{}=P) -> 
	Bin0=write_mountInfo(P#pk_GS2U_MountInfoUpdate.mounts),
	<<Bin0/binary
	>>.

binary_read_GS2U_MountInfoUpdate(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_mountInfo(Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_MountInfoUpdate{
		mounts=D3
	},
	Left,
	Count3
	}.

write_GS2U_MountOPResult(#pk_GS2U_MountOPResult{}=P) -> 
	Bin0=write_int8(P#pk_GS2U_MountOPResult.mountDataID),
	Bin3=write_int(P#pk_GS2U_MountOPResult.result),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_MountOPResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_MountOPResult{
		mountDataID=D3,
		result=D6
	},
	Left,
	Count6
	}.

write_U2GS_MountEquipRequest(#pk_U2GS_MountEquipRequest{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_MountEquipRequest.mountDataID),
	<<Bin0/binary
	>>.

binary_read_U2GS_MountEquipRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_MountEquipRequest{
		mountDataID=D3
	},
	Left,
	Count3
	}.

write_U2GS_Cancel_MountEquipRequest(#pk_U2GS_Cancel_MountEquipRequest{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_Cancel_MountEquipRequest.reserve),
	<<Bin0/binary
	>>.

binary_read_U2GS_Cancel_MountEquipRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_Cancel_MountEquipRequest{
		reserve=D3
	},
	Left,
	Count3
	}.

write_U2GS_MountUpRequest(#pk_U2GS_MountUpRequest{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_MountUpRequest.reserve),
	<<Bin0/binary
	>>.

binary_read_U2GS_MountUpRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_MountUpRequest{
		reserve=D3
	},
	Left,
	Count3
	}.

write_GS2U_MountUp(#pk_GS2U_MountUp{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_MountUp.actorID),
	Bin3=write_int8(P#pk_GS2U_MountUp.mount_data_id),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_MountUp(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_MountUp{
		actorID=D3,
		mount_data_id=D6
	},
	Left,
	Count6
	}.

write_U2GS_MountDownRequest(#pk_U2GS_MountDownRequest{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_MountDownRequest.reserve),
	<<Bin0/binary
	>>.

binary_read_U2GS_MountDownRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_MountDownRequest{
		reserve=D3
	},
	Left,
	Count3
	}.

write_GS2U_MountDown(#pk_GS2U_MountDown{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_MountDown.actorID),
	<<Bin0/binary
	>>.

binary_read_GS2U_MountDown(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_MountDown{
		actorID=D3
	},
	Left,
	Count3
	}.

write_U2GS_LevelUpRequest(#pk_U2GS_LevelUpRequest{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_LevelUpRequest.mountDataID),
	Bin3=write_int8(P#pk_U2GS_LevelUpRequest.isAuto),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_U2GS_LevelUpRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_U2GS_LevelUpRequest{
		mountDataID=D3,
		isAuto=D6
	},
	Left,
	Count6
	}.




send(Socket,#pk_GS2U_QueryMyMountInfoResult{}=P) ->

	Bin = write_GS2U_QueryMyMountInfoResult(P),
	sendPackage(Socket,?CMD_GS2U_QueryMyMountInfoResult,Bin);


send(Socket,#pk_GS2U_MountInfoUpdate{}=P) ->

	Bin = write_GS2U_MountInfoUpdate(P),
	sendPackage(Socket,?CMD_GS2U_MountInfoUpdate,Bin);


send(Socket,#pk_GS2U_MountOPResult{}=P) ->

	Bin = write_GS2U_MountOPResult(P),
	sendPackage(Socket,?CMD_GS2U_MountOPResult,Bin);





send(Socket,#pk_GS2U_MountUp{}=P) ->

	Bin = write_GS2U_MountUp(P),
	sendPackage(Socket,?CMD_GS2U_MountUp,Bin);



send(Socket,#pk_GS2U_MountDown{}=P) ->

	Bin = write_GS2U_MountDown(P),
	sendPackage(Socket,?CMD_GS2U_MountDown,Bin);


send(_,_)-> 
	noMatch.


dealMsg(Socket,Cmd,Bin2) -> 
	case Cmd of
	?CMD_U2GS_QueryMyMountInfo->
		{Pk,_,_} = binary_read_U2GS_QueryMyMountInfo(Bin2),
		messageOn:on_U2GS_QueryMyMountInfo(Socket,Pk);
	?CMD_U2GS_MountEquipRequest->
		{Pk,_,_} = binary_read_U2GS_MountEquipRequest(Bin2),
		messageOn:on_U2GS_MountEquipRequest(Socket,Pk);
	?CMD_U2GS_Cancel_MountEquipRequest->
		{Pk,_,_} = binary_read_U2GS_Cancel_MountEquipRequest(Bin2),
		messageOn:on_U2GS_Cancel_MountEquipRequest(Socket,Pk);
	?CMD_U2GS_MountUpRequest->
		{Pk,_,_} = binary_read_U2GS_MountUpRequest(Bin2),
		messageOn:on_U2GS_MountUpRequest(Socket,Pk);
	?CMD_U2GS_MountDownRequest->
		{Pk,_,_} = binary_read_U2GS_MountDownRequest(Bin2),
		messageOn:on_U2GS_MountDownRequest(Socket,Pk);
	?CMD_U2GS_LevelUpRequest->
		{Pk,_,_} = binary_read_U2GS_LevelUpRequest(Bin2),
		messageOn:on_U2GS_LevelUpRequest(Socket,Pk);
		_-> 
		noMatch
	end.
