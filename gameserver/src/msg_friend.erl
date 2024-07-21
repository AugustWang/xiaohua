


-module(msg_friend).
-export([send/2,dealMsg/3]).
-import(messageBase, [read_string/1, read_int/1,  read_int8/1,  read_int16/1, write_array/2,
             		 write_string/1, write_int/1,  write_int8/1,  write_int16/1, write_int64/1,read_array/2, sendPackage/3] ).
-import(common, [binary_read_int64/1,binary_read_int64/2,binary_read_int16/2, binary_read_int16/1,binary_read_int/2, binary_read_int/1, binary_read_int8/2,  binary_read_string/2, binary_read_array_head16/3]).
-include("package.hrl").


write_FriendInfo(#pk_FriendInfo{}=P) -> 
	Bin0=write_int8(P#pk_FriendInfo.friendType),
	Bin3=write_int64(P#pk_FriendInfo.friendID),
	Bin6=write_string(P#pk_FriendInfo.friendName),
	Bin9=write_int8(P#pk_FriendInfo.friendSex),
	Bin12=write_int8(P#pk_FriendInfo.friendFace),
	Bin15=write_int8(P#pk_FriendInfo.friendClassType),
	Bin18=write_int16(P#pk_FriendInfo.friendLevel),
	Bin21=write_int8(P#pk_FriendInfo.friendVip),
	Bin24=write_int(P#pk_FriendInfo.friendValue),
	Bin27=write_int8(P#pk_FriendInfo.friendOnline),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary
	>>.

binary_read_FriendInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int8(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int8(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int16(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_int8(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_int(Count24,Bin0),
	Count27=C27+Count24,
	{D30,C30}=binary_read_int8(Count27,Bin0),
	Count30=C30+Count27,
	{_,Left} = split_binary(Bin0,Count30),
	{#pk_FriendInfo{
		friendType=D3,
		friendID=D6,
		friendName=D9,
		friendSex=D12,
		friendFace=D15,
		friendClassType=D18,
		friendLevel=D21,
		friendVip=D24,
		friendValue=D27,
		friendOnline=D30
	},
	Left,
	Count30
	}.

write_GS2U_LoadFriend(#pk_GS2U_LoadFriend{}=P) -> 
	Bin0=write_array(P#pk_GS2U_LoadFriend.info_list,fun(X)-> write_FriendInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_LoadFriend(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_FriendInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_LoadFriend{
		info_list=D3
	},
	Left,
	Count3
	}.

write_U2GS_QueryFriend(#pk_U2GS_QueryFriend{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_QueryFriend.playerid),
	<<Bin0/binary
	>>.

binary_read_U2GS_QueryFriend(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_QueryFriend{
		playerid=D3
	},
	Left,
	Count3
	}.

write_GS2U_FriendTips(#pk_GS2U_FriendTips{}=P) -> 
	Bin0=write_int8(P#pk_GS2U_FriendTips.type),
	Bin3=write_int8(P#pk_GS2U_FriendTips.tips),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_FriendTips(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_FriendTips{
		type=D3,
		tips=D6
	},
	Left,
	Count6
	}.

write_GS2U_LoadBlack(#pk_GS2U_LoadBlack{}=P) -> 
	Bin0=write_array(P#pk_GS2U_LoadBlack.info_list,fun(X)-> write_FriendInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_LoadBlack(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_FriendInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_LoadBlack{
		info_list=D3
	},
	Left,
	Count3
	}.

write_U2GS_QueryBlack(#pk_U2GS_QueryBlack{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_QueryBlack.playerid),
	<<Bin0/binary
	>>.

binary_read_U2GS_QueryBlack(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_QueryBlack{
		playerid=D3
	},
	Left,
	Count3
	}.

write_GS2U_LoadTemp(#pk_GS2U_LoadTemp{}=P) -> 
	Bin0=write_array(P#pk_GS2U_LoadTemp.info_list,fun(X)-> write_FriendInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_LoadTemp(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_FriendInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_LoadTemp{
		info_list=D3
	},
	Left,
	Count3
	}.

write_U2GS_QueryTemp(#pk_U2GS_QueryTemp{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_QueryTemp.playerid),
	<<Bin0/binary
	>>.

binary_read_U2GS_QueryTemp(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_QueryTemp{
		playerid=D3
	},
	Left,
	Count3
	}.

write_GS2U_FriendInfo(#pk_GS2U_FriendInfo{}=P) -> 
	Bin0=write_FriendInfo(P#pk_GS2U_FriendInfo.friendInfo),
	<<Bin0/binary
	>>.

binary_read_GS2U_FriendInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_FriendInfo(Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_FriendInfo{
		friendInfo=D3
	},
	Left,
	Count3
	}.

write_U2GS_AddFriend(#pk_U2GS_AddFriend{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_AddFriend.friendID),
	Bin3=write_string(P#pk_U2GS_AddFriend.friendName),
	Bin6=write_int8(P#pk_U2GS_AddFriend.type),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_U2GS_AddFriend(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_U2GS_AddFriend{
		friendID=D3,
		friendName=D6,
		type=D9
	},
	Left,
	Count9
	}.

write_GS2U_AddAcceptResult(#pk_GS2U_AddAcceptResult{}=P) -> 
	Bin0=write_int8(P#pk_GS2U_AddAcceptResult.isSuccess),
	Bin3=write_int64(P#pk_GS2U_AddAcceptResult.type),
	Bin6=write_string(P#pk_GS2U_AddAcceptResult.fname),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_GS2U_AddAcceptResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_GS2U_AddAcceptResult{
		isSuccess=D3,
		type=D6,
		fname=D9
	},
	Left,
	Count9
	}.

write_U2GS_DeleteFriend(#pk_U2GS_DeleteFriend{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_DeleteFriend.friendID),
	Bin3=write_int8(P#pk_U2GS_DeleteFriend.type),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_U2GS_DeleteFriend(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_U2GS_DeleteFriend{
		friendID=D3,
		type=D6
	},
	Left,
	Count6
	}.

write_U2GS_AcceptFriend(#pk_U2GS_AcceptFriend{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_AcceptFriend.result),
	Bin3=write_int64(P#pk_U2GS_AcceptFriend.friendID),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_U2GS_AcceptFriend(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_U2GS_AcceptFriend{
		result=D3,
		friendID=D6
	},
	Left,
	Count6
	}.

write_GS2U_DeteFriendBack(#pk_GS2U_DeteFriendBack{}=P) -> 
	Bin0=write_int8(P#pk_GS2U_DeteFriendBack.type),
	Bin3=write_int64(P#pk_GS2U_DeteFriendBack.friendID),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_DeteFriendBack(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_DeteFriendBack{
		type=D3,
		friendID=D6
	},
	Left,
	Count6
	}.

write_GS2U_Net_Message(#pk_GS2U_Net_Message{}=P) -> 
	Bin0=write_int(P#pk_GS2U_Net_Message.mswerHead),
	Bin3=write_int(P#pk_GS2U_Net_Message.skno),
	Bin6=write_int(P#pk_GS2U_Net_Message.rel),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_GS2U_Net_Message(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_GS2U_Net_Message{
		mswerHead=D3,
		skno=D6,
		rel=D9
	},
	Left,
	Count9
	}.

write_GS2U_OnHookSet_Mess(#pk_GS2U_OnHookSet_Mess{}=P) -> 
	Bin0=write_int(P#pk_GS2U_OnHookSet_Mess.playerHP),
	Bin3=write_int(P#pk_GS2U_OnHookSet_Mess.petHP),
	Bin6=write_int(P#pk_GS2U_OnHookSet_Mess.skillID1),
	Bin9=write_int(P#pk_GS2U_OnHookSet_Mess.skillID2),
	Bin12=write_int(P#pk_GS2U_OnHookSet_Mess.skillID3),
	Bin15=write_int(P#pk_GS2U_OnHookSet_Mess.skillID4),
	Bin18=write_int(P#pk_GS2U_OnHookSet_Mess.skillID5),
	Bin21=write_int(P#pk_GS2U_OnHookSet_Mess.skillID6),
	Bin24=write_int(P#pk_GS2U_OnHookSet_Mess.getThing),
	Bin27=write_int(P#pk_GS2U_OnHookSet_Mess.hpThing),
	Bin30=write_int(P#pk_GS2U_OnHookSet_Mess.other),
	Bin33=write_int(P#pk_GS2U_OnHookSet_Mess.isAutoDrug),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary,Bin33/binary
	>>.

binary_read_GS2U_OnHookSet_Mess(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_int(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_int(Count24,Bin0),
	Count27=C27+Count24,
	{D30,C30}=binary_read_int(Count27,Bin0),
	Count30=C30+Count27,
	{D33,C33}=binary_read_int(Count30,Bin0),
	Count33=C33+Count30,
	{D36,C36}=binary_read_int(Count33,Bin0),
	Count36=C36+Count33,
	{_,Left} = split_binary(Bin0,Count36),
	{#pk_GS2U_OnHookSet_Mess{
		playerHP=D3,
		petHP=D6,
		skillID1=D9,
		skillID2=D12,
		skillID3=D15,
		skillID4=D18,
		skillID5=D21,
		skillID6=D24,
		getThing=D27,
		hpThing=D30,
		other=D33,
		isAutoDrug=D36
	},
	Left,
	Count36
	}.



send(Socket,#pk_GS2U_LoadFriend{}=P) ->

	Bin = write_GS2U_LoadFriend(P),
	sendPackage(Socket,?CMD_GS2U_LoadFriend,Bin);



send(Socket,#pk_GS2U_FriendTips{}=P) ->

	Bin = write_GS2U_FriendTips(P),
	sendPackage(Socket,?CMD_GS2U_FriendTips,Bin);


send(Socket,#pk_GS2U_LoadBlack{}=P) ->

	Bin = write_GS2U_LoadBlack(P),
	sendPackage(Socket,?CMD_GS2U_LoadBlack,Bin);



send(Socket,#pk_GS2U_LoadTemp{}=P) ->

	Bin = write_GS2U_LoadTemp(P),
	sendPackage(Socket,?CMD_GS2U_LoadTemp,Bin);



send(Socket,#pk_GS2U_FriendInfo{}=P) ->

	Bin = write_GS2U_FriendInfo(P),
	sendPackage(Socket,?CMD_GS2U_FriendInfo,Bin);



send(Socket,#pk_GS2U_AddAcceptResult{}=P) ->

	Bin = write_GS2U_AddAcceptResult(P),
	sendPackage(Socket,?CMD_GS2U_AddAcceptResult,Bin);




send(Socket,#pk_GS2U_DeteFriendBack{}=P) ->

	Bin = write_GS2U_DeteFriendBack(P),
	sendPackage(Socket,?CMD_GS2U_DeteFriendBack,Bin);


send(Socket,#pk_GS2U_Net_Message{}=P) ->

	Bin = write_GS2U_Net_Message(P),
	sendPackage(Socket,?CMD_GS2U_Net_Message,Bin);


send(Socket,#pk_GS2U_OnHookSet_Mess{}=P) ->

	Bin = write_GS2U_OnHookSet_Mess(P),
	sendPackage(Socket,?CMD_GS2U_OnHookSet_Mess,Bin);

send(_,_)-> 
	noMatch.


dealMsg(Socket,Cmd,Bin2) -> 
	case Cmd of
	?CMD_U2GS_QueryFriend->
		{Pk,_,_} = binary_read_U2GS_QueryFriend(Bin2),
		messageOn:on_U2GS_QueryFriend(Socket,Pk);
	?CMD_U2GS_QueryBlack->
		{Pk,_,_} = binary_read_U2GS_QueryBlack(Bin2),
		messageOn:on_U2GS_QueryBlack(Socket,Pk);
	?CMD_U2GS_QueryTemp->
		{Pk,_,_} = binary_read_U2GS_QueryTemp(Bin2),
		messageOn:on_U2GS_QueryTemp(Socket,Pk);
	?CMD_U2GS_AddFriend->
		{Pk,_,_} = binary_read_U2GS_AddFriend(Bin2),
		messageOn:on_U2GS_AddFriend(Socket,Pk);
	?CMD_U2GS_DeleteFriend->
		{Pk,_,_} = binary_read_U2GS_DeleteFriend(Bin2),
		messageOn:on_U2GS_DeleteFriend(Socket,Pk);
	?CMD_U2GS_AcceptFriend->
		{Pk,_,_} = binary_read_U2GS_AcceptFriend(Bin2),
		messageOn:on_U2GS_AcceptFriend(Socket,Pk);
	?CMD_GS2U_Net_Message->
		{Pk,_,_} = binary_read_GS2U_Net_Message(Bin2),
		messageOn:on_GS2U_Net_Message(Socket,Pk);
	?CMD_GS2U_OnHookSet_Mess->
		{Pk,_,_} = binary_read_GS2U_OnHookSet_Mess(Bin2),
		messageOn:on_GS2U_OnHookSet_Mess(Socket,Pk);
		_-> 
		noMatch
	end.
