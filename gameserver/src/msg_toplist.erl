


-module(msg_toplist).
-export([send/2,dealMsg/3]).
-import(messageBase, [read_string/1, read_int/1,  read_int8/1,  read_int16/1, write_array/2,
             		 write_string/1, write_int/1,  write_int8/1,  write_int16/1, write_int64/1,read_array/2, sendPackage/3] ).
-import(common, [binary_read_int64/1,binary_read_int64/2,binary_read_int16/2, binary_read_int16/1,binary_read_int/2, binary_read_int/1, binary_read_int8/2,  binary_read_string/2, binary_read_array_head16/3]).
-include("package.hrl").


write_TopPlayerLevelInfo(#pk_TopPlayerLevelInfo{}=P) -> 
	Bin0=write_int(P#pk_TopPlayerLevelInfo.top),
	Bin3=write_int64(P#pk_TopPlayerLevelInfo.playerid),
	Bin6=write_string(P#pk_TopPlayerLevelInfo.name),
	Bin9=write_int(P#pk_TopPlayerLevelInfo.camp),
	Bin12=write_int(P#pk_TopPlayerLevelInfo.level),
	Bin15=write_int(P#pk_TopPlayerLevelInfo.fightingcapacity),
	Bin18=write_int(P#pk_TopPlayerLevelInfo.sex),
	Bin21=write_int(P#pk_TopPlayerLevelInfo.weapon),
	Bin24=write_int(P#pk_TopPlayerLevelInfo.coat),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary
	>>.

binary_read_TopPlayerLevelInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
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
	{D24,C24}=binary_read_int(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_int(Count24,Bin0),
	Count27=C27+Count24,
	{_,Left} = split_binary(Bin0,Count27),
	{#pk_TopPlayerLevelInfo{
		top=D3,
		playerid=D6,
		name=D9,
		camp=D12,
		level=D15,
		fightingcapacity=D18,
		sex=D21,
		weapon=D24,
		coat=D27
	},
	Left,
	Count27
	}.

write_TopPlayerFightingCapacityInfo(#pk_TopPlayerFightingCapacityInfo{}=P) -> 
	Bin0=write_int(P#pk_TopPlayerFightingCapacityInfo.top),
	Bin3=write_int64(P#pk_TopPlayerFightingCapacityInfo.playerid),
	Bin6=write_string(P#pk_TopPlayerFightingCapacityInfo.name),
	Bin9=write_int(P#pk_TopPlayerFightingCapacityInfo.camp),
	Bin12=write_int(P#pk_TopPlayerFightingCapacityInfo.level),
	Bin15=write_int(P#pk_TopPlayerFightingCapacityInfo.fightingcapacity),
	Bin18=write_int(P#pk_TopPlayerFightingCapacityInfo.sex),
	Bin21=write_int(P#pk_TopPlayerFightingCapacityInfo.weapon),
	Bin24=write_int(P#pk_TopPlayerFightingCapacityInfo.coat),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary
	>>.

binary_read_TopPlayerFightingCapacityInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
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
	{D24,C24}=binary_read_int(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_int(Count24,Bin0),
	Count27=C27+Count24,
	{_,Left} = split_binary(Bin0,Count27),
	{#pk_TopPlayerFightingCapacityInfo{
		top=D3,
		playerid=D6,
		name=D9,
		camp=D12,
		level=D15,
		fightingcapacity=D18,
		sex=D21,
		weapon=D24,
		coat=D27
	},
	Left,
	Count27
	}.

write_TopPlayerMoneyInfo(#pk_TopPlayerMoneyInfo{}=P) -> 
	Bin0=write_int(P#pk_TopPlayerMoneyInfo.top),
	Bin3=write_int64(P#pk_TopPlayerMoneyInfo.playerid),
	Bin6=write_string(P#pk_TopPlayerMoneyInfo.name),
	Bin9=write_int(P#pk_TopPlayerMoneyInfo.camp),
	Bin12=write_int(P#pk_TopPlayerMoneyInfo.level),
	Bin15=write_int(P#pk_TopPlayerMoneyInfo.money),
	Bin18=write_int(P#pk_TopPlayerMoneyInfo.sex),
	Bin21=write_int(P#pk_TopPlayerMoneyInfo.weapon),
	Bin24=write_int(P#pk_TopPlayerMoneyInfo.coat),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary
	>>.

binary_read_TopPlayerMoneyInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
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
	{D24,C24}=binary_read_int(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_int(Count24,Bin0),
	Count27=C27+Count24,
	{_,Left} = split_binary(Bin0,Count27),
	{#pk_TopPlayerMoneyInfo{
		top=D3,
		playerid=D6,
		name=D9,
		camp=D12,
		level=D15,
		money=D18,
		sex=D21,
		weapon=D24,
		coat=D27
	},
	Left,
	Count27
	}.

write_GS2U_LoadTopPlayerLevelList(#pk_GS2U_LoadTopPlayerLevelList{}=P) -> 
	Bin0=write_array(P#pk_GS2U_LoadTopPlayerLevelList.info_list,fun(X)-> write_TopPlayerLevelInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_LoadTopPlayerLevelList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_TopPlayerLevelInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_LoadTopPlayerLevelList{
		info_list=D3
	},
	Left,
	Count3
	}.

write_GS2U_LoadTopPlayerFightingCapacityList(#pk_GS2U_LoadTopPlayerFightingCapacityList{}=P) -> 
	Bin0=write_array(P#pk_GS2U_LoadTopPlayerFightingCapacityList.info_list,fun(X)-> write_TopPlayerFightingCapacityInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_LoadTopPlayerFightingCapacityList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_TopPlayerFightingCapacityInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_LoadTopPlayerFightingCapacityList{
		info_list=D3
	},
	Left,
	Count3
	}.

write_GS2U_LoadTopPlayerMoneyList(#pk_GS2U_LoadTopPlayerMoneyList{}=P) -> 
	Bin0=write_array(P#pk_GS2U_LoadTopPlayerMoneyList.info_list,fun(X)-> write_TopPlayerMoneyInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_LoadTopPlayerMoneyList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_TopPlayerMoneyInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_LoadTopPlayerMoneyList{
		info_list=D3
	},
	Left,
	Count3
	}.

write_U2GS_LoadTopPlayerLevelList(#pk_U2GS_LoadTopPlayerLevelList{}=P) -> 
	<<
	>>.

binary_read_U2GS_LoadTopPlayerLevelList(Bin0)->
	Count0=0,
	{_,Left} = split_binary(Bin0,Count0),
	{#pk_U2GS_LoadTopPlayerLevelList{
	},
	Left,
	Count0
	}.

write_U2GS_LoadTopPlayerFightingCapacityList(#pk_U2GS_LoadTopPlayerFightingCapacityList{}=P) -> 
	<<
	>>.

binary_read_U2GS_LoadTopPlayerFightingCapacityList(Bin0)->
	Count0=0,
	{_,Left} = split_binary(Bin0,Count0),
	{#pk_U2GS_LoadTopPlayerFightingCapacityList{
	},
	Left,
	Count0
	}.

write_U2GS_LoadTopPlayerMoneyList(#pk_U2GS_LoadTopPlayerMoneyList{}=P) -> 
	<<
	>>.

binary_read_U2GS_LoadTopPlayerMoneyList(Bin0)->
	Count0=0,
	{_,Left} = split_binary(Bin0,Count0),
	{#pk_U2GS_LoadTopPlayerMoneyList{
	},
	Left,
	Count0
	}.

write_AnswerTopInfo(#pk_AnswerTopInfo{}=P) -> 
	Bin0=write_int(P#pk_AnswerTopInfo.top),
	Bin3=write_int64(P#pk_AnswerTopInfo.playerid),
	Bin6=write_string(P#pk_AnswerTopInfo.name),
	Bin9=write_int(P#pk_AnswerTopInfo.core),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_AnswerTopInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_AnswerTopInfo{
		top=D3,
		playerid=D6,
		name=D9,
		core=D12
	},
	Left,
	Count12
	}.

write_GS2U_AnswerQuestion(#pk_GS2U_AnswerQuestion{}=P) -> 
	Bin0=write_int(P#pk_GS2U_AnswerQuestion.id),
	Bin3=write_int8(P#pk_GS2U_AnswerQuestion.num),
	Bin6=write_int8(P#pk_GS2U_AnswerQuestion.maxnum),
	Bin9=write_int(P#pk_GS2U_AnswerQuestion.core),
	Bin12=write_int8(P#pk_GS2U_AnswerQuestion.special_double),
	Bin15=write_int8(P#pk_GS2U_AnswerQuestion.special_right),
	Bin18=write_int8(P#pk_GS2U_AnswerQuestion.special_exclude),
	Bin21=write_int8(P#pk_GS2U_AnswerQuestion.a),
	Bin24=write_int8(P#pk_GS2U_AnswerQuestion.b),
	Bin27=write_int8(P#pk_GS2U_AnswerQuestion.c),
	Bin30=write_int8(P#pk_GS2U_AnswerQuestion.d),
	Bin33=write_int8(P#pk_GS2U_AnswerQuestion.e1),
	Bin36=write_int8(P#pk_GS2U_AnswerQuestion.e2),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary,Bin33/binary,Bin36/binary
	>>.

binary_read_GS2U_AnswerQuestion(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int8(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int8(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int8(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_int8(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_int8(Count24,Bin0),
	Count27=C27+Count24,
	{D30,C30}=binary_read_int8(Count27,Bin0),
	Count30=C30+Count27,
	{D33,C33}=binary_read_int8(Count30,Bin0),
	Count33=C33+Count30,
	{D36,C36}=binary_read_int8(Count33,Bin0),
	Count36=C36+Count33,
	{D39,C39}=binary_read_int8(Count36,Bin0),
	Count39=C39+Count36,
	{_,Left} = split_binary(Bin0,Count39),
	{#pk_GS2U_AnswerQuestion{
		id=D3,
		num=D6,
		maxnum=D9,
		core=D12,
		special_double=D15,
		special_right=D18,
		special_exclude=D21,
		a=D24,
		b=D27,
		c=D30,
		d=D33,
		e1=D36,
		e2=D39
	},
	Left,
	Count39
	}.

write_GS2U_AnswerReady(#pk_GS2U_AnswerReady{}=P) -> 
	Bin0=write_int(P#pk_GS2U_AnswerReady.time),
	<<Bin0/binary
	>>.

binary_read_GS2U_AnswerReady(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_AnswerReady{
		time=D3
	},
	Left,
	Count3
	}.

write_GS2U_AnswerClose(#pk_GS2U_AnswerClose{}=P) -> 
	<<
	>>.

binary_read_GS2U_AnswerClose(Bin0)->
	Count0=0,
	{_,Left} = split_binary(Bin0,Count0),
	{#pk_GS2U_AnswerClose{
	},
	Left,
	Count0
	}.

write_GS2U_AnswerTopList(#pk_GS2U_AnswerTopList{}=P) -> 
	Bin0=write_array(P#pk_GS2U_AnswerTopList.info_list,fun(X)-> write_AnswerTopInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_AnswerTopList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_AnswerTopInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_AnswerTopList{
		info_list=D3
	},
	Left,
	Count3
	}.

write_U2GS_AnswerCommit(#pk_U2GS_AnswerCommit{}=P) -> 
	Bin0=write_int(P#pk_U2GS_AnswerCommit.num),
	Bin3=write_int(P#pk_U2GS_AnswerCommit.answer),
	Bin6=write_int(P#pk_U2GS_AnswerCommit.time),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_U2GS_AnswerCommit(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_U2GS_AnswerCommit{
		num=D3,
		answer=D6,
		time=D9
	},
	Left,
	Count9
	}.

write_U2GS_AnswerCommitRet(#pk_U2GS_AnswerCommitRet{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_AnswerCommitRet.ret),
	Bin3=write_int(P#pk_U2GS_AnswerCommitRet.score),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_U2GS_AnswerCommitRet(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_U2GS_AnswerCommitRet{
		ret=D3,
		score=D6
	},
	Left,
	Count6
	}.

write_U2GS_AnswerSpecial(#pk_U2GS_AnswerSpecial{}=P) -> 
	Bin0=write_int(P#pk_U2GS_AnswerSpecial.type),
	<<Bin0/binary
	>>.

binary_read_U2GS_AnswerSpecial(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_AnswerSpecial{
		type=D3
	},
	Left,
	Count3
	}.

write_U2GS_AnswerSpecialRet(#pk_U2GS_AnswerSpecialRet{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_AnswerSpecialRet.ret),
	<<Bin0/binary
	>>.

binary_read_U2GS_AnswerSpecialRet(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_AnswerSpecialRet{
		ret=D3
	},
	Left,
	Count3
	}.





send(Socket,#pk_GS2U_LoadTopPlayerLevelList{}=P) ->

	Bin = write_GS2U_LoadTopPlayerLevelList(P),
	sendPackage(Socket,?CMD_GS2U_LoadTopPlayerLevelList,Bin);


send(Socket,#pk_GS2U_LoadTopPlayerFightingCapacityList{}=P) ->

	Bin = write_GS2U_LoadTopPlayerFightingCapacityList(P),
	sendPackage(Socket,?CMD_GS2U_LoadTopPlayerFightingCapacityList,Bin);


send(Socket,#pk_GS2U_LoadTopPlayerMoneyList{}=P) ->

	Bin = write_GS2U_LoadTopPlayerMoneyList(P),
	sendPackage(Socket,?CMD_GS2U_LoadTopPlayerMoneyList,Bin);






send(Socket,#pk_GS2U_AnswerQuestion{}=P) ->

	Bin = write_GS2U_AnswerQuestion(P),
	sendPackage(Socket,?CMD_GS2U_AnswerQuestion,Bin);


send(Socket,#pk_GS2U_AnswerReady{}=P) ->

	Bin = write_GS2U_AnswerReady(P),
	sendPackage(Socket,?CMD_GS2U_AnswerReady,Bin);


send(Socket,#pk_GS2U_AnswerClose{}=P) ->

	Bin = write_GS2U_AnswerClose(P),
	sendPackage(Socket,?CMD_GS2U_AnswerClose,Bin);


send(Socket,#pk_GS2U_AnswerTopList{}=P) ->

	Bin = write_GS2U_AnswerTopList(P),
	sendPackage(Socket,?CMD_GS2U_AnswerTopList,Bin);



send(Socket,#pk_U2GS_AnswerCommitRet{}=P) ->

	Bin = write_U2GS_AnswerCommitRet(P),
	sendPackage(Socket,?CMD_U2GS_AnswerCommitRet,Bin);



send(Socket,#pk_U2GS_AnswerSpecialRet{}=P) ->

	Bin = write_U2GS_AnswerSpecialRet(P),
	sendPackage(Socket,?CMD_U2GS_AnswerSpecialRet,Bin);

send(_,_)-> 
	noMatch.


dealMsg(Socket,Cmd,Bin2) -> 
	case Cmd of
	?CMD_U2GS_LoadTopPlayerLevelList->
		{Pk,_,_} = binary_read_U2GS_LoadTopPlayerLevelList(Bin2),
		messageOn:on_U2GS_LoadTopPlayerLevelList(Socket,Pk);
	?CMD_U2GS_LoadTopPlayerFightingCapacityList->
		{Pk,_,_} = binary_read_U2GS_LoadTopPlayerFightingCapacityList(Bin2),
		messageOn:on_U2GS_LoadTopPlayerFightingCapacityList(Socket,Pk);
	?CMD_U2GS_LoadTopPlayerMoneyList->
		{Pk,_,_} = binary_read_U2GS_LoadTopPlayerMoneyList(Bin2),
		messageOn:on_U2GS_LoadTopPlayerMoneyList(Socket,Pk);
	?CMD_U2GS_AnswerCommit->
		{Pk,_,_} = binary_read_U2GS_AnswerCommit(Bin2),
		messageOn:on_U2GS_AnswerCommit(Socket,Pk);
	?CMD_U2GS_AnswerSpecial->
		{Pk,_,_} = binary_read_U2GS_AnswerSpecial(Bin2),
		messageOn:on_U2GS_AnswerSpecial(Socket,Pk);
		_-> 
		noMatch
	end.
