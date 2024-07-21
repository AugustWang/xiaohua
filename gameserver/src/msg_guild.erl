


-module(msg_guild).
-export([send/2,dealMsg/3]).
-import(messageBase, [read_string/1, read_int/1,  read_int8/1,  read_int16/1, write_array/2,
             		 write_string/1, write_int/1,  write_int8/1,  write_int16/1, write_int64/1,read_array/2, sendPackage/3] ).
-import(common, [binary_read_int64/1,binary_read_int64/2,binary_read_int16/2, binary_read_int16/1,binary_read_int/2, binary_read_int/1, binary_read_int8/2,  binary_read_string/2, binary_read_array_head16/3]).
-include("package.hrl").


write_U2GS_RequestCreateGuild(#pk_U2GS_RequestCreateGuild{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_RequestCreateGuild.useToken),
	Bin3=write_string(P#pk_U2GS_RequestCreateGuild.strGuildName),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_U2GS_RequestCreateGuild(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_U2GS_RequestCreateGuild{
		useToken=D3,
		strGuildName=D6
	},
	Left,
	Count6
	}.

write_U2GS_QueryGuildList(#pk_U2GS_QueryGuildList{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_QueryGuildList.bFirst),
	<<Bin0/binary
	>>.

binary_read_U2GS_QueryGuildList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_QueryGuildList{
		bFirst=D3
	},
	Left,
	Count3
	}.

write_U2GS_QueryGuildShortInfoEx(#pk_U2GS_QueryGuildShortInfoEx{}=P) -> 
	Bin0=write_array(P#pk_U2GS_QueryGuildShortInfoEx.vGuilds,fun(X)-> write_int64(X) end),
	<<Bin0/binary
	>>.

binary_read_U2GS_QueryGuildShortInfoEx(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_int64(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_QueryGuildShortInfoEx{
		vGuilds=D3
	},
	Left,
	Count3
	}.

write_U2GS_GetMyGuildInfo(#pk_U2GS_GetMyGuildInfo{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_GetMyGuildInfo.reserve),
	<<Bin0/binary
	>>.

binary_read_U2GS_GetMyGuildInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_GetMyGuildInfo{
		reserve=D3
	},
	Left,
	Count3
	}.

write_U2GS_GetMyGuildApplicantShortInfo(#pk_U2GS_GetMyGuildApplicantShortInfo{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_GetMyGuildApplicantShortInfo.reserve),
	<<Bin0/binary
	>>.

binary_read_U2GS_GetMyGuildApplicantShortInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_GetMyGuildApplicantShortInfo{
		reserve=D3
	},
	Left,
	Count3
	}.

write_U2GS_RequestChangeGuildAffiche(#pk_U2GS_RequestChangeGuildAffiche{}=P) -> 
	Bin0=write_string(P#pk_U2GS_RequestChangeGuildAffiche.strAffiche),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestChangeGuildAffiche(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestChangeGuildAffiche{
		strAffiche=D3
	},
	Left,
	Count3
	}.

write_U2GS_RequestGuildContribute(#pk_U2GS_RequestGuildContribute{}=P) -> 
	Bin0=write_int(P#pk_U2GS_RequestGuildContribute.nMoney),
	Bin3=write_int(P#pk_U2GS_RequestGuildContribute.nGold),
	Bin6=write_int(P#pk_U2GS_RequestGuildContribute.nItemCount),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_U2GS_RequestGuildContribute(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_U2GS_RequestGuildContribute{
		nMoney=D3,
		nGold=D6,
		nItemCount=D9
	},
	Left,
	Count9
	}.

write_U2GS_RequestGuildMemberRankChange(#pk_U2GS_RequestGuildMemberRankChange{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_RequestGuildMemberRankChange.nPlayerID),
	Bin3=write_int8(P#pk_U2GS_RequestGuildMemberRankChange.nRank),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_U2GS_RequestGuildMemberRankChange(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_U2GS_RequestGuildMemberRankChange{
		nPlayerID=D3,
		nRank=D6
	},
	Left,
	Count6
	}.

write_U2GS_RequestGuildKickOutMember(#pk_U2GS_RequestGuildKickOutMember{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_RequestGuildKickOutMember.nPlayerID),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestGuildKickOutMember(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestGuildKickOutMember{
		nPlayerID=D3
	},
	Left,
	Count3
	}.

write_U2GS_RequestGuildQuit(#pk_U2GS_RequestGuildQuit{}=P) -> 
	Bin0=write_int(P#pk_U2GS_RequestGuildQuit.reserve),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestGuildQuit(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestGuildQuit{
		reserve=D3
	},
	Left,
	Count3
	}.

write_U2GS_RequestGuildStudySkill(#pk_U2GS_RequestGuildStudySkill{}=P) -> 
	Bin0=write_int(P#pk_U2GS_RequestGuildStudySkill.nSkillGroupID),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestGuildStudySkill(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestGuildStudySkill{
		nSkillGroupID=D3
	},
	Left,
	Count3
	}.

write_U2GS_RequestJoinGuld(#pk_U2GS_RequestJoinGuld{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_RequestJoinGuld.nGuildID),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestJoinGuld(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestJoinGuld{
		nGuildID=D3
	},
	Left,
	Count3
	}.

write_U2GS_RequestGuildApplicantAllow(#pk_U2GS_RequestGuildApplicantAllow{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_RequestGuildApplicantAllow.nPlayerID),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestGuildApplicantAllow(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestGuildApplicantAllow{
		nPlayerID=D3
	},
	Left,
	Count3
	}.

write_U2GS_RequestGuildApplicantRefuse(#pk_U2GS_RequestGuildApplicantRefuse{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_RequestGuildApplicantRefuse.nPlayerID),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestGuildApplicantRefuse(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestGuildApplicantRefuse{
		nPlayerID=D3
	},
	Left,
	Count3
	}.

write_U2GS_RequestGuildApplicantOPAll(#pk_U2GS_RequestGuildApplicantOPAll{}=P) -> 
	Bin0=write_int(P#pk_U2GS_RequestGuildApplicantOPAll.nAllowOrRefuse),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestGuildApplicantOPAll(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestGuildApplicantOPAll{
		nAllowOrRefuse=D3
	},
	Left,
	Count3
	}.

write_GS2U_CreateGuildResult(#pk_GS2U_CreateGuildResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_CreateGuildResult.result),
	Bin3=write_int64(P#pk_GS2U_CreateGuildResult.guildID),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_CreateGuildResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_CreateGuildResult{
		result=D3,
		guildID=D6
	},
	Left,
	Count6
	}.

write_GS2U_GuildInfoSmall(#pk_GS2U_GuildInfoSmall{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_GuildInfoSmall.nGuildID),
	Bin3=write_int64(P#pk_GS2U_GuildInfoSmall.nChairmanPlayerID),
	Bin6=write_int8(P#pk_GS2U_GuildInfoSmall.nLevel),
	Bin9=write_int16(P#pk_GS2U_GuildInfoSmall.nMemberCount),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_GS2U_GuildInfoSmall(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int16(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_GS2U_GuildInfoSmall{
		nGuildID=D3,
		nChairmanPlayerID=D6,
		nLevel=D9,
		nMemberCount=D12
	},
	Left,
	Count12
	}.

write_GS2U_GuildInfoSmallList(#pk_GS2U_GuildInfoSmallList{}=P) -> 
	Bin0=write_array(P#pk_GS2U_GuildInfoSmallList.info_list,fun(X)-> write_GS2U_GuildInfoSmall(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_GuildInfoSmallList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_GS2U_GuildInfoSmall(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_GuildInfoSmallList{
		info_list=D3
	},
	Left,
	Count3
	}.

write_GS2U_GuildShortInfoEx(#pk_GS2U_GuildShortInfoEx{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_GuildShortInfoEx.nGuildID),
	Bin3=write_int8(P#pk_GS2U_GuildShortInfoEx.nFaction),
	Bin6=write_string(P#pk_GS2U_GuildShortInfoEx.strGuildName),
	Bin9=write_string(P#pk_GS2U_GuildShortInfoEx.strChairmanPlayerName),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_GS2U_GuildShortInfoEx(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_string(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_GS2U_GuildShortInfoEx{
		nGuildID=D3,
		nFaction=D6,
		strGuildName=D9,
		strChairmanPlayerName=D12
	},
	Left,
	Count12
	}.

write_GS2U_GuildShortInfoExList(#pk_GS2U_GuildShortInfoExList{}=P) -> 
	Bin0=write_array(P#pk_GS2U_GuildShortInfoExList.info_list,fun(X)-> write_GS2U_GuildShortInfoEx(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_GuildShortInfoExList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_GS2U_GuildShortInfoEx(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_GuildShortInfoExList{
		info_list=D3
	},
	Left,
	Count3
	}.

write_GS2U_GuildAllShortInfo(#pk_GS2U_GuildAllShortInfo{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_GuildAllShortInfo.nGuildID),
	Bin3=write_int64(P#pk_GS2U_GuildAllShortInfo.nChairmanPlayerID),
	Bin6=write_string(P#pk_GS2U_GuildAllShortInfo.strChairmanPlayerName),
	Bin9=write_int8(P#pk_GS2U_GuildAllShortInfo.nLevel),
	Bin12=write_int16(P#pk_GS2U_GuildAllShortInfo.nMemberCount),
	Bin15=write_int8(P#pk_GS2U_GuildAllShortInfo.nFaction),
	Bin18=write_string(P#pk_GS2U_GuildAllShortInfo.strGuildName),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary
	>>.

binary_read_GS2U_GuildAllShortInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int16(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int8(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_string(Count18,Bin0),
	Count21=C21+Count18,
	{_,Left} = split_binary(Bin0,Count21),
	{#pk_GS2U_GuildAllShortInfo{
		nGuildID=D3,
		nChairmanPlayerID=D6,
		strChairmanPlayerName=D9,
		nLevel=D12,
		nMemberCount=D15,
		nFaction=D18,
		strGuildName=D21
	},
	Left,
	Count21
	}.

write_GS2U_GuildAllShortInfoList(#pk_GS2U_GuildAllShortInfoList{}=P) -> 
	Bin0=write_array(P#pk_GS2U_GuildAllShortInfoList.info_list,fun(X)-> write_GS2U_GuildAllShortInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_GuildAllShortInfoList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_GS2U_GuildAllShortInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_GuildAllShortInfoList{
		info_list=D3
	},
	Left,
	Count3
	}.

write_GS2U_GuildBaseData(#pk_GS2U_GuildBaseData{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_GuildBaseData.nGuildID),
	Bin3=write_int64(P#pk_GS2U_GuildBaseData.nChairmanPlayerID),
	Bin6=write_int8(P#pk_GS2U_GuildBaseData.nFaction),
	Bin9=write_int8(P#pk_GS2U_GuildBaseData.nLevel),
	Bin12=write_int16(P#pk_GS2U_GuildBaseData.nExp),
	Bin15=write_int(P#pk_GS2U_GuildBaseData.memberCount),
	Bin18=write_string(P#pk_GS2U_GuildBaseData.strChairmanPlayerName),
	Bin21=write_string(P#pk_GS2U_GuildBaseData.strGuildName),
	Bin24=write_string(P#pk_GS2U_GuildBaseData.strAffiche),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary
	>>.

binary_read_GS2U_GuildBaseData(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int16(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_string(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_string(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_string(Count24,Bin0),
	Count27=C27+Count24,
	{_,Left} = split_binary(Bin0,Count27),
	{#pk_GS2U_GuildBaseData{
		nGuildID=D3,
		nChairmanPlayerID=D6,
		nFaction=D9,
		nLevel=D12,
		nExp=D15,
		memberCount=D18,
		strChairmanPlayerName=D21,
		strGuildName=D24,
		strAffiche=D27
	},
	Left,
	Count27
	}.

write_GS2U_GuildMemberData(#pk_GS2U_GuildMemberData{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_GuildMemberData.nPlayerID),
	Bin3=write_string(P#pk_GS2U_GuildMemberData.strPlayerName),
	Bin6=write_int16(P#pk_GS2U_GuildMemberData.nPlayerLevel),
	Bin9=write_int8(P#pk_GS2U_GuildMemberData.nRank),
	Bin12=write_int8(P#pk_GS2U_GuildMemberData.nClass),
	Bin15=write_int(P#pk_GS2U_GuildMemberData.nContribute),
	Bin18=write_int8(P#pk_GS2U_GuildMemberData.bOnline),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary
	>>.

binary_read_GS2U_GuildMemberData(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int8(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int8(Count18,Bin0),
	Count21=C21+Count18,
	{_,Left} = split_binary(Bin0,Count21),
	{#pk_GS2U_GuildMemberData{
		nPlayerID=D3,
		strPlayerName=D6,
		nPlayerLevel=D9,
		nRank=D12,
		nClass=D15,
		nContribute=D18,
		bOnline=D21
	},
	Left,
	Count21
	}.

write_GS2U_GuildApplicantData(#pk_GS2U_GuildApplicantData{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_GuildApplicantData.nPlayerID),
	Bin3=write_string(P#pk_GS2U_GuildApplicantData.strPlayerName),
	Bin6=write_int16(P#pk_GS2U_GuildApplicantData.nPlayerLevel),
	Bin9=write_int8(P#pk_GS2U_GuildApplicantData.nClass),
	Bin12=write_int(P#pk_GS2U_GuildApplicantData.nZhanLi),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary
	>>.

binary_read_GS2U_GuildApplicantData(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{_,Left} = split_binary(Bin0,Count15),
	{#pk_GS2U_GuildApplicantData{
		nPlayerID=D3,
		strPlayerName=D6,
		nPlayerLevel=D9,
		nClass=D12,
		nZhanLi=D15
	},
	Left,
	Count15
	}.

write_GS2U_GuildFullInfo(#pk_GS2U_GuildFullInfo{}=P) -> 
	Bin0=write_GS2U_GuildBaseData(P#pk_GS2U_GuildFullInfo.stBase),
	Bin3=write_array(P#pk_GS2U_GuildFullInfo.member_list,fun(X)-> write_GS2U_GuildMemberData(X) end),
	Bin6=write_array(P#pk_GS2U_GuildFullInfo.applicant_list,fun(X)-> write_GS2U_GuildApplicantData(X) end),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_GS2U_GuildFullInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_GS2U_GuildBaseData(Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_array_head16(Count3,Bin0,fun(X)-> binary_read_GS2U_GuildMemberData(X) end),
	Count6=C6+Count3,
	{D9,C9}=binary_read_array_head16(Count6,Bin0,fun(X)-> binary_read_GS2U_GuildApplicantData(X) end),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_GS2U_GuildFullInfo{
		stBase=D3,
		member_list=D6,
		applicant_list=D9
	},
	Left,
	Count9
	}.

write_GS2U_GuildApplicantShortData(#pk_GS2U_GuildApplicantShortData{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_GuildApplicantShortData.nPlayerID),
	Bin3=write_int16(P#pk_GS2U_GuildApplicantShortData.nPlayerLevel),
	Bin6=write_int(P#pk_GS2U_GuildApplicantShortData.nZhanLi),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_GS2U_GuildApplicantShortData(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_GS2U_GuildApplicantShortData{
		nPlayerID=D3,
		nPlayerLevel=D6,
		nZhanLi=D9
	},
	Left,
	Count9
	}.

write_GS2U_GuildApplicantShortList(#pk_GS2U_GuildApplicantShortList{}=P) -> 
	Bin0=write_array(P#pk_GS2U_GuildApplicantShortList.info_list,fun(X)-> write_GS2U_GuildApplicantShortData(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_GuildApplicantShortList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_GS2U_GuildApplicantShortData(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_GuildApplicantShortList{
		info_list=D3
	},
	Left,
	Count3
	}.

write_GS2U_GuildLevelEXPChanged(#pk_GS2U_GuildLevelEXPChanged{}=P) -> 
	Bin0=write_int16(P#pk_GS2U_GuildLevelEXPChanged.nLevel),
	Bin3=write_int(P#pk_GS2U_GuildLevelEXPChanged.nEXP),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_GuildLevelEXPChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_GuildLevelEXPChanged{
		nLevel=D3,
		nEXP=D6
	},
	Left,
	Count6
	}.

write_GS2U_GuildAfficheChanged(#pk_GS2U_GuildAfficheChanged{}=P) -> 
	Bin0=write_string(P#pk_GS2U_GuildAfficheChanged.strAffiche),
	<<Bin0/binary
	>>.

binary_read_GS2U_GuildAfficheChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_GuildAfficheChanged{
		strAffiche=D3
	},
	Left,
	Count3
	}.

write_GS2U_GuildMemberContributeChanged(#pk_GS2U_GuildMemberContributeChanged{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_GuildMemberContributeChanged.nPlayerID),
	Bin3=write_int(P#pk_GS2U_GuildMemberContributeChanged.nContribute),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_GuildMemberContributeChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_GuildMemberContributeChanged{
		nPlayerID=D3,
		nContribute=D6
	},
	Left,
	Count6
	}.

write_GS2U_GuildMemberLevelChanged(#pk_GS2U_GuildMemberLevelChanged{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_GuildMemberLevelChanged.nPlayerID),
	Bin3=write_int16(P#pk_GS2U_GuildMemberLevelChanged.nLevel),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_GuildMemberLevelChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_GuildMemberLevelChanged{
		nPlayerID=D3,
		nLevel=D6
	},
	Left,
	Count6
	}.

write_GS2U_GuildMemberOnlineChanged(#pk_GS2U_GuildMemberOnlineChanged{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_GuildMemberOnlineChanged.nPlayerID),
	Bin3=write_int8(P#pk_GS2U_GuildMemberOnlineChanged.nOnline),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_GuildMemberOnlineChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_GuildMemberOnlineChanged{
		nPlayerID=D3,
		nOnline=D6
	},
	Left,
	Count6
	}.

write_GS2U_GuildMemberRankChanged(#pk_GS2U_GuildMemberRankChanged{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_GuildMemberRankChanged.nPlayerID),
	Bin3=write_int8(P#pk_GS2U_GuildMemberRankChanged.nRank),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_GuildMemberRankChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_GuildMemberRankChanged{
		nPlayerID=D3,
		nRank=D6
	},
	Left,
	Count6
	}.

write_GS2U_GuildMemberAdd(#pk_GS2U_GuildMemberAdd{}=P) -> 
	Bin0=write_GS2U_GuildMemberData(P#pk_GS2U_GuildMemberAdd.stData),
	<<Bin0/binary
	>>.

binary_read_GS2U_GuildMemberAdd(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_GS2U_GuildMemberData(Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_GuildMemberAdd{
		stData=D3
	},
	Left,
	Count3
	}.

write_GS2U_GuildMemberQuit(#pk_GS2U_GuildMemberQuit{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_GuildMemberQuit.nPlayerID),
	Bin3=write_int8(P#pk_GS2U_GuildMemberQuit.bKickOut),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_GuildMemberQuit(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_GuildMemberQuit{
		nPlayerID=D3,
		bKickOut=D6
	},
	Left,
	Count6
	}.

write_GS2U_JoinGuildSuccess(#pk_GS2U_JoinGuildSuccess{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_JoinGuildSuccess.guildID),
	Bin3=write_string(P#pk_GS2U_JoinGuildSuccess.guildName),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_JoinGuildSuccess(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_JoinGuildSuccess{
		guildID=D3,
		guildName=D6
	},
	Left,
	Count6
	}.

write_GS2U_AllowOpComplete(#pk_GS2U_AllowOpComplete{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_AllowOpComplete.playerID),
	<<Bin0/binary
	>>.

binary_read_GS2U_AllowOpComplete(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_AllowOpComplete{
		playerID=D3
	},
	Left,
	Count3
	}.

















send(Socket,#pk_GS2U_CreateGuildResult{}=P) ->

	Bin = write_GS2U_CreateGuildResult(P),
	sendPackage(Socket,?CMD_GS2U_CreateGuildResult,Bin);



send(Socket,#pk_GS2U_GuildInfoSmallList{}=P) ->

	Bin = write_GS2U_GuildInfoSmallList(P),
	sendPackage(Socket,?CMD_GS2U_GuildInfoSmallList,Bin);



send(Socket,#pk_GS2U_GuildShortInfoExList{}=P) ->

	Bin = write_GS2U_GuildShortInfoExList(P),
	sendPackage(Socket,?CMD_GS2U_GuildShortInfoExList,Bin);



send(Socket,#pk_GS2U_GuildAllShortInfoList{}=P) ->

	Bin = write_GS2U_GuildAllShortInfoList(P),
	sendPackage(Socket,?CMD_GS2U_GuildAllShortInfoList,Bin);





send(Socket,#pk_GS2U_GuildFullInfo{}=P) ->

	Bin = write_GS2U_GuildFullInfo(P),
	sendPackage(Socket,?CMD_GS2U_GuildFullInfo,Bin);



send(Socket,#pk_GS2U_GuildApplicantShortList{}=P) ->

	Bin = write_GS2U_GuildApplicantShortList(P),
	sendPackage(Socket,?CMD_GS2U_GuildApplicantShortList,Bin);


send(Socket,#pk_GS2U_GuildLevelEXPChanged{}=P) ->

	Bin = write_GS2U_GuildLevelEXPChanged(P),
	sendPackage(Socket,?CMD_GS2U_GuildLevelEXPChanged,Bin);


send(Socket,#pk_GS2U_GuildAfficheChanged{}=P) ->

	Bin = write_GS2U_GuildAfficheChanged(P),
	sendPackage(Socket,?CMD_GS2U_GuildAfficheChanged,Bin);


send(Socket,#pk_GS2U_GuildMemberContributeChanged{}=P) ->

	Bin = write_GS2U_GuildMemberContributeChanged(P),
	sendPackage(Socket,?CMD_GS2U_GuildMemberContributeChanged,Bin);


send(Socket,#pk_GS2U_GuildMemberLevelChanged{}=P) ->

	Bin = write_GS2U_GuildMemberLevelChanged(P),
	sendPackage(Socket,?CMD_GS2U_GuildMemberLevelChanged,Bin);


send(Socket,#pk_GS2U_GuildMemberOnlineChanged{}=P) ->

	Bin = write_GS2U_GuildMemberOnlineChanged(P),
	sendPackage(Socket,?CMD_GS2U_GuildMemberOnlineChanged,Bin);


send(Socket,#pk_GS2U_GuildMemberRankChanged{}=P) ->

	Bin = write_GS2U_GuildMemberRankChanged(P),
	sendPackage(Socket,?CMD_GS2U_GuildMemberRankChanged,Bin);


send(Socket,#pk_GS2U_GuildMemberAdd{}=P) ->

	Bin = write_GS2U_GuildMemberAdd(P),
	sendPackage(Socket,?CMD_GS2U_GuildMemberAdd,Bin);


send(Socket,#pk_GS2U_GuildMemberQuit{}=P) ->

	Bin = write_GS2U_GuildMemberQuit(P),
	sendPackage(Socket,?CMD_GS2U_GuildMemberQuit,Bin);


send(Socket,#pk_GS2U_JoinGuildSuccess{}=P) ->

	Bin = write_GS2U_JoinGuildSuccess(P),
	sendPackage(Socket,?CMD_GS2U_JoinGuildSuccess,Bin);


send(Socket,#pk_GS2U_AllowOpComplete{}=P) ->

	Bin = write_GS2U_AllowOpComplete(P),
	sendPackage(Socket,?CMD_GS2U_AllowOpComplete,Bin);

send(_,_)-> 
	noMatch.


dealMsg(Socket,Cmd,Bin2) -> 
	case Cmd of
	?CMD_U2GS_RequestCreateGuild->
		{Pk,_,_} = binary_read_U2GS_RequestCreateGuild(Bin2),
		messageOn:on_U2GS_RequestCreateGuild(Socket,Pk);
	?CMD_U2GS_QueryGuildList->
		{Pk,_,_} = binary_read_U2GS_QueryGuildList(Bin2),
		messageOn:on_U2GS_QueryGuildList(Socket,Pk);
	?CMD_U2GS_QueryGuildShortInfoEx->
		{Pk,_,_} = binary_read_U2GS_QueryGuildShortInfoEx(Bin2),
		messageOn:on_U2GS_QueryGuildShortInfoEx(Socket,Pk);
	?CMD_U2GS_GetMyGuildInfo->
		{Pk,_,_} = binary_read_U2GS_GetMyGuildInfo(Bin2),
		messageOn:on_U2GS_GetMyGuildInfo(Socket,Pk);
	?CMD_U2GS_GetMyGuildApplicantShortInfo->
		{Pk,_,_} = binary_read_U2GS_GetMyGuildApplicantShortInfo(Bin2),
		messageOn:on_U2GS_GetMyGuildApplicantShortInfo(Socket,Pk);
	?CMD_U2GS_RequestChangeGuildAffiche->
		{Pk,_,_} = binary_read_U2GS_RequestChangeGuildAffiche(Bin2),
		messageOn:on_U2GS_RequestChangeGuildAffiche(Socket,Pk);
	?CMD_U2GS_RequestGuildContribute->
		{Pk,_,_} = binary_read_U2GS_RequestGuildContribute(Bin2),
		messageOn:on_U2GS_RequestGuildContribute(Socket,Pk);
	?CMD_U2GS_RequestGuildMemberRankChange->
		{Pk,_,_} = binary_read_U2GS_RequestGuildMemberRankChange(Bin2),
		messageOn:on_U2GS_RequestGuildMemberRankChange(Socket,Pk);
	?CMD_U2GS_RequestGuildKickOutMember->
		{Pk,_,_} = binary_read_U2GS_RequestGuildKickOutMember(Bin2),
		messageOn:on_U2GS_RequestGuildKickOutMember(Socket,Pk);
	?CMD_U2GS_RequestGuildQuit->
		{Pk,_,_} = binary_read_U2GS_RequestGuildQuit(Bin2),
		messageOn:on_U2GS_RequestGuildQuit(Socket,Pk);
	?CMD_U2GS_RequestGuildStudySkill->
		{Pk,_,_} = binary_read_U2GS_RequestGuildStudySkill(Bin2),
		messageOn:on_U2GS_RequestGuildStudySkill(Socket,Pk);
	?CMD_U2GS_RequestJoinGuld->
		{Pk,_,_} = binary_read_U2GS_RequestJoinGuld(Bin2),
		messageOn:on_U2GS_RequestJoinGuld(Socket,Pk);
	?CMD_U2GS_RequestGuildApplicantAllow->
		{Pk,_,_} = binary_read_U2GS_RequestGuildApplicantAllow(Bin2),
		messageOn:on_U2GS_RequestGuildApplicantAllow(Socket,Pk);
	?CMD_U2GS_RequestGuildApplicantRefuse->
		{Pk,_,_} = binary_read_U2GS_RequestGuildApplicantRefuse(Bin2),
		messageOn:on_U2GS_RequestGuildApplicantRefuse(Socket,Pk);
	?CMD_U2GS_RequestGuildApplicantOPAll->
		{Pk,_,_} = binary_read_U2GS_RequestGuildApplicantOPAll(Bin2),
		messageOn:on_U2GS_RequestGuildApplicantOPAll(Socket,Pk);
		_-> 
		noMatch
	end.
