


-module(msg_team).
-export([send/2,dealMsg/3]).
-import(messageBase, [read_string/1, read_int/1,  read_int8/1,  read_int16/1, write_array/2,
             		 write_string/1, write_int/1,  write_int8/1,  write_int16/1, write_int64/1,read_array/2, sendPackage/3] ).
-import(common, [binary_read_int64/1,binary_read_int64/2,binary_read_int16/2, binary_read_int16/1,binary_read_int/2, binary_read_int/1, binary_read_int8/2,  binary_read_string/2, binary_read_array_head16/3]).
-include("package.hrl").


write_inviteCreateTeam(#pk_inviteCreateTeam{}=P) -> 
	Bin0=write_int64(P#pk_inviteCreateTeam.targetPlayerID),
	<<Bin0/binary
	>>.

binary_read_inviteCreateTeam(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_inviteCreateTeam{
		targetPlayerID=D3
	},
	Left,
	Count3
	}.

write_teamOPResult(#pk_teamOPResult{}=P) -> 
	Bin0=write_int64(P#pk_teamOPResult.targetPlayerID),
	Bin3=write_string(P#pk_teamOPResult.targetPlayerName),
	Bin6=write_int(P#pk_teamOPResult.result),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_teamOPResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_teamOPResult{
		targetPlayerID=D3,
		targetPlayerName=D6,
		result=D9
	},
	Left,
	Count9
	}.

write_beenInviteCreateTeam(#pk_beenInviteCreateTeam{}=P) -> 
	Bin0=write_int64(P#pk_beenInviteCreateTeam.inviterPlayerID),
	Bin3=write_string(P#pk_beenInviteCreateTeam.inviterPlayerName),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_beenInviteCreateTeam(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_beenInviteCreateTeam{
		inviterPlayerID=D3,
		inviterPlayerName=D6
	},
	Left,
	Count6
	}.

write_ackInviteCreateTeam(#pk_ackInviteCreateTeam{}=P) -> 
	Bin0=write_int64(P#pk_ackInviteCreateTeam.inviterPlayerID),
	Bin3=write_int8(P#pk_ackInviteCreateTeam.agree),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_ackInviteCreateTeam(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_ackInviteCreateTeam{
		inviterPlayerID=D3,
		agree=D6
	},
	Left,
	Count6
	}.

write_teamMemberInfo(#pk_teamMemberInfo{}=P) -> 
	Bin0=write_int64(P#pk_teamMemberInfo.playerID),
	Bin3=write_string(P#pk_teamMemberInfo.playerName),
	Bin6=write_int16(P#pk_teamMemberInfo.level),
	Bin9=write_int16(P#pk_teamMemberInfo.posx),
	Bin12=write_int16(P#pk_teamMemberInfo.posy),
	Bin15=write_int8(P#pk_teamMemberInfo.map_data_id),
	Bin18=write_int8(P#pk_teamMemberInfo.isOnline),
	Bin21=write_int8(P#pk_teamMemberInfo.camp),
	Bin24=write_int8(P#pk_teamMemberInfo.sex),
	Bin27=write_int8(P#pk_teamMemberInfo.life_percent),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary
	>>.

binary_read_teamMemberInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int16(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int16(Count12,Bin0),
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
	{_,Left} = split_binary(Bin0,Count30),
	{#pk_teamMemberInfo{
		playerID=D3,
		playerName=D6,
		level=D9,
		posx=D12,
		posy=D15,
		map_data_id=D18,
		isOnline=D21,
		camp=D24,
		sex=D27,
		life_percent=D30
	},
	Left,
	Count30
	}.

write_teamInfo(#pk_teamInfo{}=P) -> 
	Bin0=write_int64(P#pk_teamInfo.teamID),
	Bin3=write_int64(P#pk_teamInfo.leaderPlayerID),
	Bin6=write_array(P#pk_teamInfo.info_list,fun(X)-> write_teamMemberInfo(X) end),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_teamInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_array_head16(Count6,Bin0,fun(X)-> binary_read_teamMemberInfo(X) end),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_teamInfo{
		teamID=D3,
		leaderPlayerID=D6,
		info_list=D9
	},
	Left,
	Count9
	}.

write_teamPlayerOffline(#pk_teamPlayerOffline{}=P) -> 
	Bin0=write_int64(P#pk_teamPlayerOffline.playerID),
	<<Bin0/binary
	>>.

binary_read_teamPlayerOffline(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_teamPlayerOffline{
		playerID=D3
	},
	Left,
	Count3
	}.

write_teamQuitRequest(#pk_teamQuitRequest{}=P) -> 
	Bin0=write_int8(P#pk_teamQuitRequest.reserve),
	<<Bin0/binary
	>>.

binary_read_teamQuitRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_teamQuitRequest{
		reserve=D3
	},
	Left,
	Count3
	}.

write_teamPlayerQuit(#pk_teamPlayerQuit{}=P) -> 
	Bin0=write_int64(P#pk_teamPlayerQuit.playerID),
	<<Bin0/binary
	>>.

binary_read_teamPlayerQuit(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_teamPlayerQuit{
		playerID=D3
	},
	Left,
	Count3
	}.

write_teamKickOutPlayer(#pk_teamKickOutPlayer{}=P) -> 
	Bin0=write_int64(P#pk_teamKickOutPlayer.playerID),
	<<Bin0/binary
	>>.

binary_read_teamKickOutPlayer(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_teamKickOutPlayer{
		playerID=D3
	},
	Left,
	Count3
	}.

write_teamPlayerKickOut(#pk_teamPlayerKickOut{}=P) -> 
	Bin0=write_int64(P#pk_teamPlayerKickOut.playerID),
	<<Bin0/binary
	>>.

binary_read_teamPlayerKickOut(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_teamPlayerKickOut{
		playerID=D3
	},
	Left,
	Count3
	}.

write_inviteJoinTeam(#pk_inviteJoinTeam{}=P) -> 
	Bin0=write_int64(P#pk_inviteJoinTeam.playerID),
	<<Bin0/binary
	>>.

binary_read_inviteJoinTeam(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_inviteJoinTeam{
		playerID=D3
	},
	Left,
	Count3
	}.

write_beenInviteJoinTeam(#pk_beenInviteJoinTeam{}=P) -> 
	Bin0=write_int64(P#pk_beenInviteJoinTeam.playerID),
	Bin3=write_string(P#pk_beenInviteJoinTeam.playerName),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_beenInviteJoinTeam(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_beenInviteJoinTeam{
		playerID=D3,
		playerName=D6
	},
	Left,
	Count6
	}.

write_ackInviteJointTeam(#pk_ackInviteJointTeam{}=P) -> 
	Bin0=write_int64(P#pk_ackInviteJointTeam.playerID),
	Bin3=write_int8(P#pk_ackInviteJointTeam.agree),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_ackInviteJointTeam(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_ackInviteJointTeam{
		playerID=D3,
		agree=D6
	},
	Left,
	Count6
	}.

write_applyJoinTeam(#pk_applyJoinTeam{}=P) -> 
	Bin0=write_int64(P#pk_applyJoinTeam.playerID),
	<<Bin0/binary
	>>.

binary_read_applyJoinTeam(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_applyJoinTeam{
		playerID=D3
	},
	Left,
	Count3
	}.

write_queryApplyJoinTeam(#pk_queryApplyJoinTeam{}=P) -> 
	Bin0=write_int64(P#pk_queryApplyJoinTeam.playerID),
	Bin3=write_string(P#pk_queryApplyJoinTeam.playerName),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_queryApplyJoinTeam(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_queryApplyJoinTeam{
		playerID=D3,
		playerName=D6
	},
	Left,
	Count6
	}.

write_ackQueryApplyJoinTeam(#pk_ackQueryApplyJoinTeam{}=P) -> 
	Bin0=write_int64(P#pk_ackQueryApplyJoinTeam.playerID),
	Bin3=write_int8(P#pk_ackQueryApplyJoinTeam.agree),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_ackQueryApplyJoinTeam(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_ackQueryApplyJoinTeam{
		playerID=D3,
		agree=D6
	},
	Left,
	Count6
	}.

write_addTeamMember(#pk_addTeamMember{}=P) -> 
	Bin0=write_teamMemberInfo(P#pk_addTeamMember.info),
	<<Bin0/binary
	>>.

binary_read_addTeamMember(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_teamMemberInfo(Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_addTeamMember{
		info=D3
	},
	Left,
	Count3
	}.

write_shortTeamMemberInfo(#pk_shortTeamMemberInfo{}=P) -> 
	Bin0=write_int64(P#pk_shortTeamMemberInfo.playerID),
	Bin3=write_int16(P#pk_shortTeamMemberInfo.level),
	Bin6=write_int16(P#pk_shortTeamMemberInfo.posx),
	Bin9=write_int16(P#pk_shortTeamMemberInfo.posy),
	Bin12=write_int8(P#pk_shortTeamMemberInfo.map_data_id),
	Bin15=write_int8(P#pk_shortTeamMemberInfo.isOnline),
	Bin18=write_int8(P#pk_shortTeamMemberInfo.life_percent),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary
	>>.

binary_read_shortTeamMemberInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int16(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int8(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int8(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int8(Count18,Bin0),
	Count21=C21+Count18,
	{_,Left} = split_binary(Bin0,Count21),
	{#pk_shortTeamMemberInfo{
		playerID=D3,
		level=D6,
		posx=D9,
		posy=D12,
		map_data_id=D15,
		isOnline=D18,
		life_percent=D21
	},
	Left,
	Count21
	}.

write_updateTeamMemberInfo(#pk_updateTeamMemberInfo{}=P) -> 
	Bin0=write_array(P#pk_updateTeamMemberInfo.info_list,fun(X)-> write_shortTeamMemberInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_updateTeamMemberInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_shortTeamMemberInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_updateTeamMemberInfo{
		info_list=D3
	},
	Left,
	Count3
	}.

write_teamDisbanded(#pk_teamDisbanded{}=P) -> 
	Bin0=write_int8(P#pk_teamDisbanded.reserve),
	<<Bin0/binary
	>>.

binary_read_teamDisbanded(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_teamDisbanded{
		reserve=D3
	},
	Left,
	Count3
	}.

write_teamQueryLeaderInfo(#pk_teamQueryLeaderInfo{}=P) -> 
	Bin0=write_int64(P#pk_teamQueryLeaderInfo.playerID),
	Bin3=write_string(P#pk_teamQueryLeaderInfo.playerName),
	Bin6=write_int16(P#pk_teamQueryLeaderInfo.level),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_teamQueryLeaderInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_teamQueryLeaderInfo{
		playerID=D3,
		playerName=D6,
		level=D9
	},
	Left,
	Count9
	}.

write_teamQueryLeaderInfoOnMyMap(#pk_teamQueryLeaderInfoOnMyMap{}=P) -> 
	Bin0=write_array(P#pk_teamQueryLeaderInfoOnMyMap.info_list,fun(X)-> write_teamQueryLeaderInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_teamQueryLeaderInfoOnMyMap(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_teamQueryLeaderInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_teamQueryLeaderInfoOnMyMap{
		info_list=D3
	},
	Left,
	Count3
	}.

write_teamQueryLeaderInfoRequest(#pk_teamQueryLeaderInfoRequest{}=P) -> 
	Bin0=write_int64(P#pk_teamQueryLeaderInfoRequest.mapID),
	<<Bin0/binary
	>>.

binary_read_teamQueryLeaderInfoRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_teamQueryLeaderInfoRequest{
		mapID=D3
	},
	Left,
	Count3
	}.

write_teamChangeLeader(#pk_teamChangeLeader{}=P) -> 
	Bin0=write_int64(P#pk_teamChangeLeader.playerID),
	<<Bin0/binary
	>>.

binary_read_teamChangeLeader(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_teamChangeLeader{
		playerID=D3
	},
	Left,
	Count3
	}.

write_teamChangeLeaderRequest(#pk_teamChangeLeaderRequest{}=P) -> 
	Bin0=write_int64(P#pk_teamChangeLeaderRequest.playerID),
	<<Bin0/binary
	>>.

binary_read_teamChangeLeaderRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_teamChangeLeaderRequest{
		playerID=D3
	},
	Left,
	Count3
	}.

write_beenInviteState(#pk_beenInviteState{}=P) -> 
	Bin0=write_int8(P#pk_beenInviteState.state),
	<<Bin0/binary
	>>.

binary_read_beenInviteState(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_beenInviteState{
		state=D3
	},
	Left,
	Count3
	}.



send(Socket,#pk_teamOPResult{}=P) ->

	Bin = write_teamOPResult(P),
	sendPackage(Socket,?CMD_teamOPResult,Bin);


send(Socket,#pk_beenInviteCreateTeam{}=P) ->

	Bin = write_beenInviteCreateTeam(P),
	sendPackage(Socket,?CMD_beenInviteCreateTeam,Bin);




send(Socket,#pk_teamInfo{}=P) ->

	Bin = write_teamInfo(P),
	sendPackage(Socket,?CMD_teamInfo,Bin);


send(Socket,#pk_teamPlayerOffline{}=P) ->

	Bin = write_teamPlayerOffline(P),
	sendPackage(Socket,?CMD_teamPlayerOffline,Bin);



send(Socket,#pk_teamPlayerQuit{}=P) ->

	Bin = write_teamPlayerQuit(P),
	sendPackage(Socket,?CMD_teamPlayerQuit,Bin);



send(Socket,#pk_teamPlayerKickOut{}=P) ->

	Bin = write_teamPlayerKickOut(P),
	sendPackage(Socket,?CMD_teamPlayerKickOut,Bin);



send(Socket,#pk_beenInviteJoinTeam{}=P) ->

	Bin = write_beenInviteJoinTeam(P),
	sendPackage(Socket,?CMD_beenInviteJoinTeam,Bin);




send(Socket,#pk_queryApplyJoinTeam{}=P) ->

	Bin = write_queryApplyJoinTeam(P),
	sendPackage(Socket,?CMD_queryApplyJoinTeam,Bin);



send(Socket,#pk_addTeamMember{}=P) ->

	Bin = write_addTeamMember(P),
	sendPackage(Socket,?CMD_addTeamMember,Bin);



send(Socket,#pk_updateTeamMemberInfo{}=P) ->

	Bin = write_updateTeamMemberInfo(P),
	sendPackage(Socket,?CMD_updateTeamMemberInfo,Bin);


send(Socket,#pk_teamDisbanded{}=P) ->

	Bin = write_teamDisbanded(P),
	sendPackage(Socket,?CMD_teamDisbanded,Bin);



send(Socket,#pk_teamQueryLeaderInfoOnMyMap{}=P) ->

	Bin = write_teamQueryLeaderInfoOnMyMap(P),
	sendPackage(Socket,?CMD_teamQueryLeaderInfoOnMyMap,Bin);



send(Socket,#pk_teamChangeLeader{}=P) ->

	Bin = write_teamChangeLeader(P),
	sendPackage(Socket,?CMD_teamChangeLeader,Bin);



send(_,_)-> 
	noMatch.


dealMsg(Socket,Cmd,Bin2) -> 
	case Cmd of
	?CMD_inviteCreateTeam->
		{Pk,_,_} = binary_read_inviteCreateTeam(Bin2),
		messageOn:on_inviteCreateTeam(Socket,Pk);
	?CMD_ackInviteCreateTeam->
		{Pk,_,_} = binary_read_ackInviteCreateTeam(Bin2),
		messageOn:on_ackInviteCreateTeam(Socket,Pk);
	?CMD_teamQuitRequest->
		{Pk,_,_} = binary_read_teamQuitRequest(Bin2),
		messageOn:on_teamQuitRequest(Socket,Pk);
	?CMD_teamKickOutPlayer->
		{Pk,_,_} = binary_read_teamKickOutPlayer(Bin2),
		messageOn:on_teamKickOutPlayer(Socket,Pk);
	?CMD_inviteJoinTeam->
		{Pk,_,_} = binary_read_inviteJoinTeam(Bin2),
		messageOn:on_inviteJoinTeam(Socket,Pk);
	?CMD_ackInviteJointTeam->
		{Pk,_,_} = binary_read_ackInviteJointTeam(Bin2),
		messageOn:on_ackInviteJointTeam(Socket,Pk);
	?CMD_applyJoinTeam->
		{Pk,_,_} = binary_read_applyJoinTeam(Bin2),
		messageOn:on_applyJoinTeam(Socket,Pk);
	?CMD_ackQueryApplyJoinTeam->
		{Pk,_,_} = binary_read_ackQueryApplyJoinTeam(Bin2),
		messageOn:on_ackQueryApplyJoinTeam(Socket,Pk);
	?CMD_teamQueryLeaderInfoRequest->
		{Pk,_,_} = binary_read_teamQueryLeaderInfoRequest(Bin2),
		messageOn:on_teamQueryLeaderInfoRequest(Socket,Pk);
	?CMD_teamChangeLeaderRequest->
		{Pk,_,_} = binary_read_teamChangeLeaderRequest(Bin2),
		messageOn:on_teamChangeLeaderRequest(Socket,Pk);
	?CMD_beenInviteState->
		{Pk,_,_} = binary_read_beenInviteState(Bin2),
		messageOn:on_beenInviteState(Socket,Pk);
		_-> 
		noMatch
	end.
