


-module(msg_player).
-export([send/2,dealMsg/3]).
-import(messageBase, [read_string/1, read_int/1,  read_int8/1,  read_int16/1, write_array/2,
             		 write_string/1, write_int/1,  write_int8/1,  write_int16/1, write_int64/1,read_array/2, sendPackage/3] ).
-import(common, [binary_read_int64/1,binary_read_int64/2,binary_read_int16/2, binary_read_int16/1,binary_read_int/2, binary_read_int/1, binary_read_int8/2,  binary_read_string/2, binary_read_array_head16/3]).
-include("package.hrl").


write_CharProperty(#pk_CharProperty{}=P) -> 
	Bin0=write_int(P#pk_CharProperty.attack),
	Bin3=write_int(P#pk_CharProperty.defence),
	Bin6=write_int(P#pk_CharProperty.ph_def),
	Bin9=write_int(P#pk_CharProperty.fire_def),
	Bin12=write_int(P#pk_CharProperty.ice_def),
	Bin15=write_int(P#pk_CharProperty.elec_def),
	Bin18=write_int(P#pk_CharProperty.poison_def),
	Bin21=write_int(P#pk_CharProperty.max_life),
	Bin24=write_int(P#pk_CharProperty.life_recover),
	Bin27=write_int(P#pk_CharProperty.been_attack_recover),
	Bin30=write_int(P#pk_CharProperty.damage_recover),
	Bin33=write_int(P#pk_CharProperty.coma_def),
	Bin36=write_int(P#pk_CharProperty.hold_def),
	Bin39=write_int(P#pk_CharProperty.silent_def),
	Bin42=write_int(P#pk_CharProperty.move_def),
	Bin45=write_int(P#pk_CharProperty.hit),
	Bin48=write_int(P#pk_CharProperty.dodge),
	Bin51=write_int(P#pk_CharProperty.block),
	Bin54=write_int(P#pk_CharProperty.crit),
	Bin57=write_int(P#pk_CharProperty.pierce),
	Bin60=write_int(P#pk_CharProperty.attack_speed),
	Bin63=write_int(P#pk_CharProperty.tough),
	Bin66=write_int(P#pk_CharProperty.crit_damage_rate),
	Bin69=write_int(P#pk_CharProperty.block_dec_damage),
	Bin72=write_int(P#pk_CharProperty.phy_attack_rate),
	Bin75=write_int(P#pk_CharProperty.fire_attack_rate),
	Bin78=write_int(P#pk_CharProperty.ice_attack_rate),
	Bin81=write_int(P#pk_CharProperty.elec_attack_rate),
	Bin84=write_int(P#pk_CharProperty.poison_attack_rate),
	Bin87=write_int(P#pk_CharProperty.phy_def_rate),
	Bin90=write_int(P#pk_CharProperty.fire_def_rate),
	Bin93=write_int(P#pk_CharProperty.ice_def_rate),
	Bin96=write_int(P#pk_CharProperty.elec_def_rate),
	Bin99=write_int(P#pk_CharProperty.poison_def_rate),
	Bin102=write_int(P#pk_CharProperty.treat_rate),
	Bin105=write_int(P#pk_CharProperty.on_treat_rate),
	Bin108=write_int(P#pk_CharProperty.move_speed),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary,Bin33/binary,Bin36/binary,Bin39/binary,Bin42/binary,Bin45/binary,Bin48/binary,Bin51/binary,Bin54/binary,Bin57/binary,Bin60/binary,Bin63/binary,Bin66/binary,Bin69/binary,Bin72/binary,Bin75/binary,Bin78/binary,Bin81/binary,Bin84/binary,Bin87/binary,Bin90/binary,Bin93/binary,Bin96/binary,Bin99/binary,Bin102/binary,Bin105/binary,Bin108/binary
	>>.

binary_read_CharProperty(Bin0)->
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
	{D39,C39}=binary_read_int(Count36,Bin0),
	Count39=C39+Count36,
	{D42,C42}=binary_read_int(Count39,Bin0),
	Count42=C42+Count39,
	{D45,C45}=binary_read_int(Count42,Bin0),
	Count45=C45+Count42,
	{D48,C48}=binary_read_int(Count45,Bin0),
	Count48=C48+Count45,
	{D51,C51}=binary_read_int(Count48,Bin0),
	Count51=C51+Count48,
	{D54,C54}=binary_read_int(Count51,Bin0),
	Count54=C54+Count51,
	{D57,C57}=binary_read_int(Count54,Bin0),
	Count57=C57+Count54,
	{D60,C60}=binary_read_int(Count57,Bin0),
	Count60=C60+Count57,
	{D63,C63}=binary_read_int(Count60,Bin0),
	Count63=C63+Count60,
	{D66,C66}=binary_read_int(Count63,Bin0),
	Count66=C66+Count63,
	{D69,C69}=binary_read_int(Count66,Bin0),
	Count69=C69+Count66,
	{D72,C72}=binary_read_int(Count69,Bin0),
	Count72=C72+Count69,
	{D75,C75}=binary_read_int(Count72,Bin0),
	Count75=C75+Count72,
	{D78,C78}=binary_read_int(Count75,Bin0),
	Count78=C78+Count75,
	{D81,C81}=binary_read_int(Count78,Bin0),
	Count81=C81+Count78,
	{D84,C84}=binary_read_int(Count81,Bin0),
	Count84=C84+Count81,
	{D87,C87}=binary_read_int(Count84,Bin0),
	Count87=C87+Count84,
	{D90,C90}=binary_read_int(Count87,Bin0),
	Count90=C90+Count87,
	{D93,C93}=binary_read_int(Count90,Bin0),
	Count93=C93+Count90,
	{D96,C96}=binary_read_int(Count93,Bin0),
	Count96=C96+Count93,
	{D99,C99}=binary_read_int(Count96,Bin0),
	Count99=C99+Count96,
	{D102,C102}=binary_read_int(Count99,Bin0),
	Count102=C102+Count99,
	{D105,C105}=binary_read_int(Count102,Bin0),
	Count105=C105+Count102,
	{D108,C108}=binary_read_int(Count105,Bin0),
	Count108=C108+Count105,
	{D111,C111}=binary_read_int(Count108,Bin0),
	Count111=C111+Count108,
	{_,Left} = split_binary(Bin0,Count111),
	{#pk_CharProperty{
		attack=D3,
		defence=D6,
		ph_def=D9,
		fire_def=D12,
		ice_def=D15,
		elec_def=D18,
		poison_def=D21,
		max_life=D24,
		life_recover=D27,
		been_attack_recover=D30,
		damage_recover=D33,
		coma_def=D36,
		hold_def=D39,
		silent_def=D42,
		move_def=D45,
		hit=D48,
		dodge=D51,
		block=D54,
		crit=D57,
		pierce=D60,
		attack_speed=D63,
		tough=D66,
		crit_damage_rate=D69,
		block_dec_damage=D72,
		phy_attack_rate=D75,
		fire_attack_rate=D78,
		ice_attack_rate=D81,
		elec_attack_rate=D84,
		poison_attack_rate=D87,
		phy_def_rate=D90,
		fire_def_rate=D93,
		ice_def_rate=D96,
		elec_def_rate=D99,
		poison_def_rate=D102,
		treat_rate=D105,
		on_treat_rate=D108,
		move_speed=D111
	},
	Left,
	Count111
	}.

write_ObjectBuff(#pk_ObjectBuff{}=P) -> 
	Bin0=write_int16(P#pk_ObjectBuff.buff_id),
	Bin3=write_int16(P#pk_ObjectBuff.allValidTime),
	Bin6=write_int8(P#pk_ObjectBuff.remainTriggerCount),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_ObjectBuff(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_ObjectBuff{
		buff_id=D3,
		allValidTime=D6,
		remainTriggerCount=D9
	},
	Left,
	Count9
	}.

write_PlayerBaseInfo(#pk_PlayerBaseInfo{}=P) -> 
	Bin0=write_int64(P#pk_PlayerBaseInfo.id),
	Bin3=write_string(P#pk_PlayerBaseInfo.name),
	Bin6=write_int16(P#pk_PlayerBaseInfo.x),
	Bin9=write_int16(P#pk_PlayerBaseInfo.y),
	Bin12=write_int8(P#pk_PlayerBaseInfo.sex),
	Bin15=write_int8(P#pk_PlayerBaseInfo.face),
	Bin18=write_int8(P#pk_PlayerBaseInfo.weapon),
	Bin21=write_int16(P#pk_PlayerBaseInfo.level),
	Bin24=write_int8(P#pk_PlayerBaseInfo.camp),
	Bin27=write_int8(P#pk_PlayerBaseInfo.faction),
	Bin30=write_int8(P#pk_PlayerBaseInfo.vip),
	Bin33=write_int16(P#pk_PlayerBaseInfo.maxEnabledBagCells),
	Bin36=write_int16(P#pk_PlayerBaseInfo.maxEnabledStorageBagCells),
	Bin39=write_string(P#pk_PlayerBaseInfo.storageBagPassWord),
	Bin42=write_int(P#pk_PlayerBaseInfo.unlockTimes),
	Bin45=write_int(P#pk_PlayerBaseInfo.money),
	Bin48=write_int(P#pk_PlayerBaseInfo.moneyBinded),
	Bin51=write_int(P#pk_PlayerBaseInfo.gold),
	Bin54=write_int(P#pk_PlayerBaseInfo.goldBinded),
	Bin57=write_int(P#pk_PlayerBaseInfo.rechargeAmmount),
	Bin60=write_int(P#pk_PlayerBaseInfo.ticket),
	Bin63=write_int(P#pk_PlayerBaseInfo.guildContribute),
	Bin66=write_int(P#pk_PlayerBaseInfo.honor),
	Bin69=write_int(P#pk_PlayerBaseInfo.credit),
	Bin72=write_int(P#pk_PlayerBaseInfo.exp),
	Bin75=write_int(P#pk_PlayerBaseInfo.bloodPool),
	Bin78=write_int(P#pk_PlayerBaseInfo.petBloodPool),
	Bin81=write_int(P#pk_PlayerBaseInfo.life),
	Bin84=write_int(P#pk_PlayerBaseInfo.lifeMax),
	Bin87=write_int64(P#pk_PlayerBaseInfo.guildID),
	Bin90=write_int(P#pk_PlayerBaseInfo.mountDataID),
	Bin93=write_int(P#pk_PlayerBaseInfo.pK_Kill_RemainTime),
	Bin96=write_int(P#pk_PlayerBaseInfo.exp15Add),
	Bin99=write_int(P#pk_PlayerBaseInfo.exp20Add),
	Bin102=write_int(P#pk_PlayerBaseInfo.exp30Add),
	Bin105=write_int(P#pk_PlayerBaseInfo.pk_Kill_Value),
	Bin108=write_int8(P#pk_PlayerBaseInfo.pkFlags),
	Bin111=write_int8(P#pk_PlayerBaseInfo.minEquipLevel),
	Bin114=write_string(P#pk_PlayerBaseInfo.guild_name),
	Bin117=write_int8(P#pk_PlayerBaseInfo.guild_rank),
	Bin120=write_string(P#pk_PlayerBaseInfo.goldPassWord),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary,Bin33/binary,Bin36/binary,Bin39/binary,Bin42/binary,Bin45/binary,Bin48/binary,Bin51/binary,Bin54/binary,Bin57/binary,Bin60/binary,Bin63/binary,Bin66/binary,Bin69/binary,Bin72/binary,Bin75/binary,Bin78/binary,Bin81/binary,Bin84/binary,Bin87/binary,Bin90/binary,Bin93/binary,Bin96/binary,Bin99/binary,Bin102/binary,Bin105/binary,Bin108/binary,Bin111/binary,Bin114/binary,Bin117/binary,Bin120/binary
	>>.

binary_read_PlayerBaseInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
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
	{D24,C24}=binary_read_int16(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_int8(Count24,Bin0),
	Count27=C27+Count24,
	{D30,C30}=binary_read_int8(Count27,Bin0),
	Count30=C30+Count27,
	{D33,C33}=binary_read_int8(Count30,Bin0),
	Count33=C33+Count30,
	{D36,C36}=binary_read_int16(Count33,Bin0),
	Count36=C36+Count33,
	{D39,C39}=binary_read_int16(Count36,Bin0),
	Count39=C39+Count36,
	{D42,C42}=binary_read_string(Count39,Bin0),
	Count42=C42+Count39,
	{D45,C45}=binary_read_int(Count42,Bin0),
	Count45=C45+Count42,
	{D48,C48}=binary_read_int(Count45,Bin0),
	Count48=C48+Count45,
	{D51,C51}=binary_read_int(Count48,Bin0),
	Count51=C51+Count48,
	{D54,C54}=binary_read_int(Count51,Bin0),
	Count54=C54+Count51,
	{D57,C57}=binary_read_int(Count54,Bin0),
	Count57=C57+Count54,
	{D60,C60}=binary_read_int(Count57,Bin0),
	Count60=C60+Count57,
	{D63,C63}=binary_read_int(Count60,Bin0),
	Count63=C63+Count60,
	{D66,C66}=binary_read_int(Count63,Bin0),
	Count66=C66+Count63,
	{D69,C69}=binary_read_int(Count66,Bin0),
	Count69=C69+Count66,
	{D72,C72}=binary_read_int(Count69,Bin0),
	Count72=C72+Count69,
	{D75,C75}=binary_read_int(Count72,Bin0),
	Count75=C75+Count72,
	{D78,C78}=binary_read_int(Count75,Bin0),
	Count78=C78+Count75,
	{D81,C81}=binary_read_int(Count78,Bin0),
	Count81=C81+Count78,
	{D84,C84}=binary_read_int(Count81,Bin0),
	Count84=C84+Count81,
	{D87,C87}=binary_read_int(Count84,Bin0),
	Count87=C87+Count84,
	{D90,C90}=binary_read_int64(Count87,Bin0),
	Count90=C90+Count87,
	{D93,C93}=binary_read_int(Count90,Bin0),
	Count93=C93+Count90,
	{D96,C96}=binary_read_int(Count93,Bin0),
	Count96=C96+Count93,
	{D99,C99}=binary_read_int(Count96,Bin0),
	Count99=C99+Count96,
	{D102,C102}=binary_read_int(Count99,Bin0),
	Count102=C102+Count99,
	{D105,C105}=binary_read_int(Count102,Bin0),
	Count105=C105+Count102,
	{D108,C108}=binary_read_int(Count105,Bin0),
	Count108=C108+Count105,
	{D111,C111}=binary_read_int8(Count108,Bin0),
	Count111=C111+Count108,
	{D114,C114}=binary_read_int8(Count111,Bin0),
	Count114=C114+Count111,
	{D117,C117}=binary_read_string(Count114,Bin0),
	Count117=C117+Count114,
	{D120,C120}=binary_read_int8(Count117,Bin0),
	Count120=C120+Count117,
	{D123,C123}=binary_read_string(Count120,Bin0),
	Count123=C123+Count120,
	{_,Left} = split_binary(Bin0,Count123),
	{#pk_PlayerBaseInfo{
		id=D3,
		name=D6,
		x=D9,
		y=D12,
		sex=D15,
		face=D18,
		weapon=D21,
		level=D24,
		camp=D27,
		faction=D30,
		vip=D33,
		maxEnabledBagCells=D36,
		maxEnabledStorageBagCells=D39,
		storageBagPassWord=D42,
		unlockTimes=D45,
		money=D48,
		moneyBinded=D51,
		gold=D54,
		goldBinded=D57,
		rechargeAmmount=D60,
		ticket=D63,
		guildContribute=D66,
		honor=D69,
		credit=D72,
		exp=D75,
		bloodPool=D78,
		petBloodPool=D81,
		life=D84,
		lifeMax=D87,
		guildID=D90,
		mountDataID=D93,
		pK_Kill_RemainTime=D96,
		exp15Add=D99,
		exp20Add=D102,
		exp30Add=D105,
		pk_Kill_Value=D108,
		pkFlags=D111,
		minEquipLevel=D114,
		guild_name=D117,
		guild_rank=D120,
		goldPassWord=D123
	},
	Left,
	Count123
	}.

write_rideInfo(#pk_rideInfo{}=P) -> 
	Bin0=write_int(P#pk_rideInfo.mountDataID),
	Bin3=write_int(P#pk_rideInfo.rideFlage),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_rideInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_rideInfo{
		mountDataID=D3,
		rideFlage=D6
	},
	Left,
	Count6
	}.

write_LookInfoPlayer(#pk_LookInfoPlayer{}=P) -> 
	Bin0=write_int64(P#pk_LookInfoPlayer.id),
	Bin3=write_string(P#pk_LookInfoPlayer.name),
	Bin6=write_int8(P#pk_LookInfoPlayer.lifePercent),
	Bin9=write_int16(P#pk_LookInfoPlayer.x),
	Bin12=write_int16(P#pk_LookInfoPlayer.y),
	Bin15=write_int16(P#pk_LookInfoPlayer.move_target_x),
	Bin18=write_int16(P#pk_LookInfoPlayer.move_target_y),
	Bin21=write_int8(P#pk_LookInfoPlayer.move_dir),
	Bin24=write_int16(P#pk_LookInfoPlayer.move_speed),
	Bin27=write_int16(P#pk_LookInfoPlayer.level),
	Bin30=write_int(P#pk_LookInfoPlayer.value_flags),
	Bin33=write_int(P#pk_LookInfoPlayer.charState),
	Bin36=write_int16(P#pk_LookInfoPlayer.weapon),
	Bin39=write_int16(P#pk_LookInfoPlayer.coat),
	Bin42=write_array(P#pk_LookInfoPlayer.buffList,fun(X)-> write_ObjectBuff(X) end),
	Bin45=write_int8(P#pk_LookInfoPlayer.convoyFlags),
	Bin48=write_int64(P#pk_LookInfoPlayer.guild_id),
	Bin51=write_string(P#pk_LookInfoPlayer.guild_name),
	Bin54=write_int8(P#pk_LookInfoPlayer.guild_rank),
	Bin57=write_int8(P#pk_LookInfoPlayer.vip),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary,Bin33/binary,Bin36/binary,Bin39/binary,Bin42/binary,Bin45/binary,Bin48/binary,Bin51/binary,Bin54/binary,Bin57/binary
	>>.

binary_read_LookInfoPlayer(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int16(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int16(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int16(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int16(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_int8(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_int16(Count24,Bin0),
	Count27=C27+Count24,
	{D30,C30}=binary_read_int16(Count27,Bin0),
	Count30=C30+Count27,
	{D33,C33}=binary_read_int(Count30,Bin0),
	Count33=C33+Count30,
	{D36,C36}=binary_read_int(Count33,Bin0),
	Count36=C36+Count33,
	{D39,C39}=binary_read_int16(Count36,Bin0),
	Count39=C39+Count36,
	{D42,C42}=binary_read_int16(Count39,Bin0),
	Count42=C42+Count39,
	{D45,C45}=binary_read_array_head16(Count42,Bin0,fun(X)-> binary_read_ObjectBuff(X) end),
	Count45=C45+Count42,
	{D48,C48}=binary_read_int8(Count45,Bin0),
	Count48=C48+Count45,
	{D51,C51}=binary_read_int64(Count48,Bin0),
	Count51=C51+Count48,
	{D54,C54}=binary_read_string(Count51,Bin0),
	Count54=C54+Count51,
	{D57,C57}=binary_read_int8(Count54,Bin0),
	Count57=C57+Count54,
	{D60,C60}=binary_read_int8(Count57,Bin0),
	Count60=C60+Count57,
	{_,Left} = split_binary(Bin0,Count60),
	{#pk_LookInfoPlayer{
		id=D3,
		name=D6,
		lifePercent=D9,
		x=D12,
		y=D15,
		move_target_x=D18,
		move_target_y=D21,
		move_dir=D24,
		move_speed=D27,
		level=D30,
		value_flags=D33,
		charState=D36,
		weapon=D39,
		coat=D42,
		buffList=D45,
		convoyFlags=D48,
		guild_id=D51,
		guild_name=D54,
		guild_rank=D57,
		vip=D60
	},
	Left,
	Count60
	}.

write_LookInfoPlayerList(#pk_LookInfoPlayerList{}=P) -> 
	Bin0=write_array(P#pk_LookInfoPlayerList.info_list,fun(X)-> write_LookInfoPlayer(X) end),
	<<Bin0/binary
	>>.

binary_read_LookInfoPlayerList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_LookInfoPlayer(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_LookInfoPlayerList{
		info_list=D3
	},
	Left,
	Count3
	}.

write_LookInfoPet(#pk_LookInfoPet{}=P) -> 
	Bin0=write_int64(P#pk_LookInfoPet.id),
	Bin3=write_int64(P#pk_LookInfoPet.masterId),
	Bin6=write_int16(P#pk_LookInfoPet.data_id),
	Bin9=write_string(P#pk_LookInfoPet.name),
	Bin12=write_int16(P#pk_LookInfoPet.titleid),
	Bin15=write_int16(P#pk_LookInfoPet.modelId),
	Bin18=write_int8(P#pk_LookInfoPet.lifePercent),
	Bin21=write_int16(P#pk_LookInfoPet.level),
	Bin24=write_int16(P#pk_LookInfoPet.x),
	Bin27=write_int16(P#pk_LookInfoPet.y),
	Bin30=write_int16(P#pk_LookInfoPet.move_target_x),
	Bin33=write_int16(P#pk_LookInfoPet.move_target_y),
	Bin36=write_int16(P#pk_LookInfoPet.move_speed),
	Bin39=write_int(P#pk_LookInfoPet.charState),
	Bin42=write_array(P#pk_LookInfoPet.buffList,fun(X)-> write_ObjectBuff(X) end),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary,Bin33/binary,Bin36/binary,Bin39/binary,Bin42/binary
	>>.

binary_read_LookInfoPet(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_string(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int16(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int16(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int8(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_int16(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_int16(Count24,Bin0),
	Count27=C27+Count24,
	{D30,C30}=binary_read_int16(Count27,Bin0),
	Count30=C30+Count27,
	{D33,C33}=binary_read_int16(Count30,Bin0),
	Count33=C33+Count30,
	{D36,C36}=binary_read_int16(Count33,Bin0),
	Count36=C36+Count33,
	{D39,C39}=binary_read_int16(Count36,Bin0),
	Count39=C39+Count36,
	{D42,C42}=binary_read_int(Count39,Bin0),
	Count42=C42+Count39,
	{D45,C45}=binary_read_array_head16(Count42,Bin0,fun(X)-> binary_read_ObjectBuff(X) end),
	Count45=C45+Count42,
	{_,Left} = split_binary(Bin0,Count45),
	{#pk_LookInfoPet{
		id=D3,
		masterId=D6,
		data_id=D9,
		name=D12,
		titleid=D15,
		modelId=D18,
		lifePercent=D21,
		level=D24,
		x=D27,
		y=D30,
		move_target_x=D33,
		move_target_y=D36,
		move_speed=D39,
		charState=D42,
		buffList=D45
	},
	Left,
	Count45
	}.

write_LookInfoPetList(#pk_LookInfoPetList{}=P) -> 
	Bin0=write_array(P#pk_LookInfoPetList.info_list,fun(X)-> write_LookInfoPet(X) end),
	<<Bin0/binary
	>>.

binary_read_LookInfoPetList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_LookInfoPet(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_LookInfoPetList{
		info_list=D3
	},
	Left,
	Count3
	}.

write_LookInfoMonster(#pk_LookInfoMonster{}=P) -> 
	Bin0=write_int64(P#pk_LookInfoMonster.id),
	Bin3=write_int16(P#pk_LookInfoMonster.move_target_x),
	Bin6=write_int16(P#pk_LookInfoMonster.move_target_y),
	Bin9=write_int16(P#pk_LookInfoMonster.move_speed),
	Bin12=write_int16(P#pk_LookInfoMonster.x),
	Bin15=write_int16(P#pk_LookInfoMonster.y),
	Bin18=write_int16(P#pk_LookInfoMonster.monster_data_id),
	Bin21=write_int8(P#pk_LookInfoMonster.lifePercent),
	Bin24=write_int8(P#pk_LookInfoMonster.faction),
	Bin27=write_int(P#pk_LookInfoMonster.charState),
	Bin30=write_array(P#pk_LookInfoMonster.buffList,fun(X)-> write_ObjectBuff(X) end),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary
	>>.

binary_read_LookInfoMonster(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int16(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int16(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int16(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int16(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_int8(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_int8(Count24,Bin0),
	Count27=C27+Count24,
	{D30,C30}=binary_read_int(Count27,Bin0),
	Count30=C30+Count27,
	{D33,C33}=binary_read_array_head16(Count30,Bin0,fun(X)-> binary_read_ObjectBuff(X) end),
	Count33=C33+Count30,
	{_,Left} = split_binary(Bin0,Count33),
	{#pk_LookInfoMonster{
		id=D3,
		move_target_x=D6,
		move_target_y=D9,
		move_speed=D12,
		x=D15,
		y=D18,
		monster_data_id=D21,
		lifePercent=D24,
		faction=D27,
		charState=D30,
		buffList=D33
	},
	Left,
	Count33
	}.

write_LookInfoMonsterList(#pk_LookInfoMonsterList{}=P) -> 
	Bin0=write_array(P#pk_LookInfoMonsterList.info_list,fun(X)-> write_LookInfoMonster(X) end),
	<<Bin0/binary
	>>.

binary_read_LookInfoMonsterList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_LookInfoMonster(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_LookInfoMonsterList{
		info_list=D3
	},
	Left,
	Count3
	}.

write_LookInfoNpc(#pk_LookInfoNpc{}=P) -> 
	Bin0=write_int64(P#pk_LookInfoNpc.id),
	Bin3=write_int16(P#pk_LookInfoNpc.x),
	Bin6=write_int16(P#pk_LookInfoNpc.y),
	Bin9=write_int16(P#pk_LookInfoNpc.npc_data_id),
	Bin12=write_int16(P#pk_LookInfoNpc.move_target_x),
	Bin15=write_int16(P#pk_LookInfoNpc.move_target_y),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary
	>>.

binary_read_LookInfoNpc(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int16(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int16(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int16(Count15,Bin0),
	Count18=C18+Count15,
	{_,Left} = split_binary(Bin0,Count18),
	{#pk_LookInfoNpc{
		id=D3,
		x=D6,
		y=D9,
		npc_data_id=D12,
		move_target_x=D15,
		move_target_y=D18
	},
	Left,
	Count18
	}.

write_LookInfoNpcList(#pk_LookInfoNpcList{}=P) -> 
	Bin0=write_array(P#pk_LookInfoNpcList.info_list,fun(X)-> write_LookInfoNpc(X) end),
	<<Bin0/binary
	>>.

binary_read_LookInfoNpcList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_LookInfoNpc(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_LookInfoNpcList{
		info_list=D3
	},
	Left,
	Count3
	}.

write_LookInfoObject(#pk_LookInfoObject{}=P) -> 
	Bin0=write_int64(P#pk_LookInfoObject.id),
	Bin3=write_int16(P#pk_LookInfoObject.x),
	Bin6=write_int16(P#pk_LookInfoObject.y),
	Bin9=write_int16(P#pk_LookInfoObject.object_data_id),
	Bin12=write_int16(P#pk_LookInfoObject.object_type),
	Bin15=write_int(P#pk_LookInfoObject.param),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary
	>>.

binary_read_LookInfoObject(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int16(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int16(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int(Count15,Bin0),
	Count18=C18+Count15,
	{_,Left} = split_binary(Bin0,Count18),
	{#pk_LookInfoObject{
		id=D3,
		x=D6,
		y=D9,
		object_data_id=D12,
		object_type=D15,
		param=D18
	},
	Left,
	Count18
	}.

write_LookInfoObjectList(#pk_LookInfoObjectList{}=P) -> 
	Bin0=write_array(P#pk_LookInfoObjectList.info_list,fun(X)-> write_LookInfoObject(X) end),
	<<Bin0/binary
	>>.

binary_read_LookInfoObjectList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_LookInfoObject(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_LookInfoObjectList{
		info_list=D3
	},
	Left,
	Count3
	}.

write_ActorDisapearList(#pk_ActorDisapearList{}=P) -> 
	Bin0=write_array(P#pk_ActorDisapearList.info_list,fun(X)-> write_int64(X) end),
	<<Bin0/binary
	>>.

binary_read_ActorDisapearList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_int64(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_ActorDisapearList{
		info_list=D3
	},
	Left,
	Count3
	}.

write_PosInfo(#pk_PosInfo{}=P) -> 
	Bin0=write_int16(P#pk_PosInfo.x),
	Bin3=write_int16(P#pk_PosInfo.y),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PosInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PosInfo{
		x=D3,
		y=D6
	},
	Left,
	Count6
	}.

write_PlayerMoveTo(#pk_PlayerMoveTo{}=P) -> 
	Bin0=write_int16(P#pk_PlayerMoveTo.posX),
	Bin3=write_int16(P#pk_PlayerMoveTo.posY),
	Bin6=write_array(P#pk_PlayerMoveTo.posInfos,fun(X)-> write_PosInfo(X) end),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PlayerMoveTo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_array_head16(Count6,Bin0,fun(X)-> binary_read_PosInfo(X) end),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PlayerMoveTo{
		posX=D3,
		posY=D6,
		posInfos=D9
	},
	Left,
	Count9
	}.

write_PlayerStopMove(#pk_PlayerStopMove{}=P) -> 
	Bin0=write_int16(P#pk_PlayerStopMove.posX),
	Bin3=write_int16(P#pk_PlayerStopMove.posY),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PlayerStopMove(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PlayerStopMove{
		posX=D3,
		posY=D6
	},
	Left,
	Count6
	}.

write_PlayerStopMove_S2C(#pk_PlayerStopMove_S2C{}=P) -> 
	Bin0=write_int64(P#pk_PlayerStopMove_S2C.id),
	Bin3=write_int16(P#pk_PlayerStopMove_S2C.posX),
	Bin6=write_int16(P#pk_PlayerStopMove_S2C.posY),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PlayerStopMove_S2C(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PlayerStopMove_S2C{
		id=D3,
		posX=D6,
		posY=D9
	},
	Left,
	Count9
	}.

write_MoveInfo(#pk_MoveInfo{}=P) -> 
	Bin0=write_int64(P#pk_MoveInfo.id),
	Bin3=write_int16(P#pk_MoveInfo.posX),
	Bin6=write_int16(P#pk_MoveInfo.posY),
	Bin9=write_array(P#pk_MoveInfo.posInfos,fun(X)-> write_PosInfo(X) end),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_MoveInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_array_head16(Count9,Bin0,fun(X)-> binary_read_PosInfo(X) end),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_MoveInfo{
		id=D3,
		posX=D6,
		posY=D9,
		posInfos=D12
	},
	Left,
	Count12
	}.

write_PlayerMoveInfo(#pk_PlayerMoveInfo{}=P) -> 
	Bin0=write_array(P#pk_PlayerMoveInfo.ids,fun(X)-> write_MoveInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_PlayerMoveInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_MoveInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PlayerMoveInfo{
		ids=D3
	},
	Left,
	Count3
	}.

write_ChangeFlyState(#pk_ChangeFlyState{}=P) -> 
	Bin0=write_int(P#pk_ChangeFlyState.flyState),
	<<Bin0/binary
	>>.

binary_read_ChangeFlyState(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_ChangeFlyState{
		flyState=D3
	},
	Left,
	Count3
	}.

write_ChangeFlyState_S2C(#pk_ChangeFlyState_S2C{}=P) -> 
	Bin0=write_int64(P#pk_ChangeFlyState_S2C.id),
	Bin3=write_int(P#pk_ChangeFlyState_S2C.flyState),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_ChangeFlyState_S2C(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_ChangeFlyState_S2C{
		id=D3,
		flyState=D6
	},
	Left,
	Count6
	}.

write_MonsterMoveInfo(#pk_MonsterMoveInfo{}=P) -> 
	Bin0=write_array(P#pk_MonsterMoveInfo.ids,fun(X)-> write_MoveInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_MonsterMoveInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_MoveInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_MonsterMoveInfo{
		ids=D3
	},
	Left,
	Count3
	}.

write_MonsterStopMove(#pk_MonsterStopMove{}=P) -> 
	Bin0=write_int64(P#pk_MonsterStopMove.id),
	Bin3=write_int16(P#pk_MonsterStopMove.x),
	Bin6=write_int16(P#pk_MonsterStopMove.y),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_MonsterStopMove(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_MonsterStopMove{
		id=D3,
		x=D6,
		y=D9
	},
	Left,
	Count9
	}.

write_PetMoveInfo(#pk_PetMoveInfo{}=P) -> 
	Bin0=write_array(P#pk_PetMoveInfo.ids,fun(X)-> write_MoveInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_PetMoveInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_MoveInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PetMoveInfo{
		ids=D3
	},
	Left,
	Count3
	}.

write_PetStopMove(#pk_PetStopMove{}=P) -> 
	Bin0=write_int64(P#pk_PetStopMove.id),
	Bin3=write_int16(P#pk_PetStopMove.x),
	Bin6=write_int16(P#pk_PetStopMove.y),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PetStopMove(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PetStopMove{
		id=D3,
		x=D6,
		y=D9
	},
	Left,
	Count9
	}.

write_ChangeMap(#pk_ChangeMap{}=P) -> 
	Bin0=write_int(P#pk_ChangeMap.mapDataID),
	Bin3=write_int64(P#pk_ChangeMap.mapId),
	Bin6=write_int16(P#pk_ChangeMap.x),
	Bin9=write_int16(P#pk_ChangeMap.y),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_ChangeMap(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int16(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_ChangeMap{
		mapDataID=D3,
		mapId=D6,
		x=D9,
		y=D12
	},
	Left,
	Count12
	}.

write_CollectFail(#pk_CollectFail{}=P) -> 
	<<
	>>.

binary_read_CollectFail(Bin0)->
	Count0=0,
	{_,Left} = split_binary(Bin0,Count0),
	{#pk_CollectFail{
	},
	Left,
	Count0
	}.

write_RequestGM(#pk_RequestGM{}=P) -> 
	Bin0=write_string(P#pk_RequestGM.strCMD),
	<<Bin0/binary
	>>.

binary_read_RequestGM(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestGM{
		strCMD=D3
	},
	Left,
	Count3
	}.

write_PlayerPropertyChangeValue(#pk_PlayerPropertyChangeValue{}=P) -> 
	Bin0=write_int8(P#pk_PlayerPropertyChangeValue.proType),
	Bin3=write_int(P#pk_PlayerPropertyChangeValue.value),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PlayerPropertyChangeValue(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PlayerPropertyChangeValue{
		proType=D3,
		value=D6
	},
	Left,
	Count6
	}.

write_PlayerPropertyChanged(#pk_PlayerPropertyChanged{}=P) -> 
	Bin0=write_array(P#pk_PlayerPropertyChanged.changeValues,fun(X)-> write_PlayerPropertyChangeValue(X) end),
	<<Bin0/binary
	>>.

binary_read_PlayerPropertyChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_PlayerPropertyChangeValue(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PlayerPropertyChanged{
		changeValues=D3
	},
	Left,
	Count3
	}.

write_PlayerMoneyChanged(#pk_PlayerMoneyChanged{}=P) -> 
	Bin0=write_int8(P#pk_PlayerMoneyChanged.changeReson),
	Bin3=write_int8(P#pk_PlayerMoneyChanged.moneyType),
	Bin6=write_int(P#pk_PlayerMoneyChanged.moneyValue),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PlayerMoneyChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PlayerMoneyChanged{
		changeReson=D3,
		moneyType=D6,
		moneyValue=D9
	},
	Left,
	Count9
	}.

write_PlayerKickOuted(#pk_PlayerKickOuted{}=P) -> 
	Bin0=write_int(P#pk_PlayerKickOuted.reserve),
	<<Bin0/binary
	>>.

binary_read_PlayerKickOuted(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PlayerKickOuted{
		reserve=D3
	},
	Left,
	Count3
	}.

write_ActorStateFlagSet(#pk_ActorStateFlagSet{}=P) -> 
	Bin0=write_int(P#pk_ActorStateFlagSet.nSetStateFlag),
	<<Bin0/binary
	>>.

binary_read_ActorStateFlagSet(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_ActorStateFlagSet{
		nSetStateFlag=D3
	},
	Left,
	Count3
	}.

write_ActorStateFlagSet_Broad(#pk_ActorStateFlagSet_Broad{}=P) -> 
	Bin0=write_int64(P#pk_ActorStateFlagSet_Broad.nActorID),
	Bin3=write_int(P#pk_ActorStateFlagSet_Broad.nSetStateFlag),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_ActorStateFlagSet_Broad(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_ActorStateFlagSet_Broad{
		nActorID=D3,
		nSetStateFlag=D6
	},
	Left,
	Count6
	}.

write_PlayerSkillInitData(#pk_PlayerSkillInitData{}=P) -> 
	Bin0=write_int16(P#pk_PlayerSkillInitData.nSkillID),
	Bin3=write_int(P#pk_PlayerSkillInitData.nCD),
	Bin6=write_int16(P#pk_PlayerSkillInitData.nActiveBranch1),
	Bin9=write_int16(P#pk_PlayerSkillInitData.nActiveBranch2),
	Bin12=write_int16(P#pk_PlayerSkillInitData.nBindedBranch),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary
	>>.

binary_read_PlayerSkillInitData(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int16(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int16(Count12,Bin0),
	Count15=C15+Count12,
	{_,Left} = split_binary(Bin0,Count15),
	{#pk_PlayerSkillInitData{
		nSkillID=D3,
		nCD=D6,
		nActiveBranch1=D9,
		nActiveBranch2=D12,
		nBindedBranch=D15
	},
	Left,
	Count15
	}.

write_PlayerSkillInitInfo(#pk_PlayerSkillInitInfo{}=P) -> 
	Bin0=write_array(P#pk_PlayerSkillInitInfo.info_list,fun(X)-> write_PlayerSkillInitData(X) end),
	<<Bin0/binary
	>>.

binary_read_PlayerSkillInitInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_PlayerSkillInitData(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PlayerSkillInitInfo{
		info_list=D3
	},
	Left,
	Count3
	}.

write_U2GS_StudySkill(#pk_U2GS_StudySkill{}=P) -> 
	Bin0=write_int(P#pk_U2GS_StudySkill.nSkillID),
	<<Bin0/binary
	>>.

binary_read_U2GS_StudySkill(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_StudySkill{
		nSkillID=D3
	},
	Left,
	Count3
	}.

write_GS2U_StudySkillResult(#pk_GS2U_StudySkillResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_StudySkillResult.nSkillID),
	Bin3=write_int(P#pk_GS2U_StudySkillResult.nResult),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_StudySkillResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_StudySkillResult{
		nSkillID=D3,
		nResult=D6
	},
	Left,
	Count6
	}.

write_activeBranchID(#pk_activeBranchID{}=P) -> 
	Bin0=write_int8(P#pk_activeBranchID.nWhichBranch),
	Bin3=write_int(P#pk_activeBranchID.nSkillID),
	Bin6=write_int(P#pk_activeBranchID.branchID),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_activeBranchID(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_activeBranchID{
		nWhichBranch=D3,
		nSkillID=D6,
		branchID=D9
	},
	Left,
	Count9
	}.

write_activeBranchIDResult(#pk_activeBranchIDResult{}=P) -> 
	Bin0=write_int(P#pk_activeBranchIDResult.result),
	Bin3=write_int(P#pk_activeBranchIDResult.nSkillID),
	Bin6=write_int(P#pk_activeBranchIDResult.branckID),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_activeBranchIDResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_activeBranchIDResult{
		result=D3,
		nSkillID=D6,
		branckID=D9
	},
	Left,
	Count9
	}.

write_U2GS_AddSkillBranch(#pk_U2GS_AddSkillBranch{}=P) -> 
	Bin0=write_int(P#pk_U2GS_AddSkillBranch.nSkillID),
	Bin3=write_int(P#pk_U2GS_AddSkillBranch.nBranchID),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_U2GS_AddSkillBranch(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_U2GS_AddSkillBranch{
		nSkillID=D3,
		nBranchID=D6
	},
	Left,
	Count6
	}.

write_GS2U_AddSkillBranchAck(#pk_GS2U_AddSkillBranchAck{}=P) -> 
	Bin0=write_int(P#pk_GS2U_AddSkillBranchAck.result),
	Bin3=write_int(P#pk_GS2U_AddSkillBranchAck.nSkillID),
	Bin6=write_int(P#pk_GS2U_AddSkillBranchAck.nBranchID),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_GS2U_AddSkillBranchAck(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_GS2U_AddSkillBranchAck{
		result=D3,
		nSkillID=D6,
		nBranchID=D9
	},
	Left,
	Count9
	}.

write_U2GS_UseSkillRequest(#pk_U2GS_UseSkillRequest{}=P) -> 
	Bin0=write_int(P#pk_U2GS_UseSkillRequest.nSkillID),
	Bin3=write_array(P#pk_U2GS_UseSkillRequest.nTargetIDList,fun(X)-> write_int64(X) end),
	Bin6=write_int(P#pk_U2GS_UseSkillRequest.nCombatID),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_U2GS_UseSkillRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_array_head16(Count3,Bin0,fun(X)-> binary_read_int64(X) end),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_U2GS_UseSkillRequest{
		nSkillID=D3,
		nTargetIDList=D6,
		nCombatID=D9
	},
	Left,
	Count9
	}.

write_GS2U_UseSkillToObject(#pk_GS2U_UseSkillToObject{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_UseSkillToObject.nUserActorID),
	Bin3=write_int16(P#pk_GS2U_UseSkillToObject.nSkillID),
	Bin6=write_array(P#pk_GS2U_UseSkillToObject.nTargetActorIDList,fun(X)-> write_int64(X) end),
	Bin9=write_int(P#pk_GS2U_UseSkillToObject.nCombatID),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_GS2U_UseSkillToObject(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_array_head16(Count6,Bin0,fun(X)-> binary_read_int64(X) end),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_GS2U_UseSkillToObject{
		nUserActorID=D3,
		nSkillID=D6,
		nTargetActorIDList=D9,
		nCombatID=D12
	},
	Left,
	Count12
	}.

write_GS2U_UseSkillToPos(#pk_GS2U_UseSkillToPos{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_UseSkillToPos.nUserActorID),
	Bin3=write_int16(P#pk_GS2U_UseSkillToPos.nSkillID),
	Bin6=write_int16(P#pk_GS2U_UseSkillToPos.x),
	Bin9=write_int16(P#pk_GS2U_UseSkillToPos.y),
	Bin12=write_int(P#pk_GS2U_UseSkillToPos.nCombatID),
	Bin15=write_array(P#pk_GS2U_UseSkillToPos.id_list,fun(X)-> write_int64(X) end),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary
	>>.

binary_read_GS2U_UseSkillToPos(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int16(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_array_head16(Count15,Bin0,fun(X)-> binary_read_int64(X) end),
	Count18=C18+Count15,
	{_,Left} = split_binary(Bin0,Count18),
	{#pk_GS2U_UseSkillToPos{
		nUserActorID=D3,
		nSkillID=D6,
		x=D9,
		y=D12,
		nCombatID=D15,
		id_list=D18
	},
	Left,
	Count18
	}.

write_GS2U_AttackDamage(#pk_GS2U_AttackDamage{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_AttackDamage.nDamageTarget),
	Bin3=write_int(P#pk_GS2U_AttackDamage.nCombatID),
	Bin6=write_int16(P#pk_GS2U_AttackDamage.nSkillID),
	Bin9=write_int(P#pk_GS2U_AttackDamage.nDamageLife),
	Bin12=write_int8(P#pk_GS2U_AttackDamage.nTargetLifePer100),
	Bin15=write_int8(P#pk_GS2U_AttackDamage.isBlocked),
	Bin18=write_int8(P#pk_GS2U_AttackDamage.isCrited),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary
	>>.

binary_read_GS2U_AttackDamage(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int8(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int8(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int8(Count18,Bin0),
	Count21=C21+Count18,
	{_,Left} = split_binary(Bin0,Count21),
	{#pk_GS2U_AttackDamage{
		nDamageTarget=D3,
		nCombatID=D6,
		nSkillID=D9,
		nDamageLife=D12,
		nTargetLifePer100=D15,
		isBlocked=D18,
		isCrited=D21
	},
	Left,
	Count21
	}.

write_GS2U_CharactorDead(#pk_GS2U_CharactorDead{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_CharactorDead.nDeadActorID),
	Bin3=write_int64(P#pk_GS2U_CharactorDead.nKiller),
	Bin6=write_int(P#pk_GS2U_CharactorDead.nCombatNumber),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_GS2U_CharactorDead(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_GS2U_CharactorDead{
		nDeadActorID=D3,
		nKiller=D6,
		nCombatNumber=D9
	},
	Left,
	Count9
	}.

write_GS2U_AttackMiss(#pk_GS2U_AttackMiss{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_AttackMiss.nActorID),
	Bin3=write_int64(P#pk_GS2U_AttackMiss.nTargetID),
	Bin6=write_int(P#pk_GS2U_AttackMiss.nCombatID),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_GS2U_AttackMiss(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_GS2U_AttackMiss{
		nActorID=D3,
		nTargetID=D6,
		nCombatID=D9
	},
	Left,
	Count9
	}.

write_GS2U_AttackDodge(#pk_GS2U_AttackDodge{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_AttackDodge.nActorID),
	Bin3=write_int64(P#pk_GS2U_AttackDodge.nTargetID),
	Bin6=write_int(P#pk_GS2U_AttackDodge.nCombatID),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_GS2U_AttackDodge(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_GS2U_AttackDodge{
		nActorID=D3,
		nTargetID=D6,
		nCombatID=D9
	},
	Left,
	Count9
	}.

write_GS2U_AttackCrit(#pk_GS2U_AttackCrit{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_AttackCrit.nActorID),
	Bin3=write_int(P#pk_GS2U_AttackCrit.nCombatID),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_AttackCrit(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_AttackCrit{
		nActorID=D3,
		nCombatID=D6
	},
	Left,
	Count6
	}.

write_GS2U_AttackBlock(#pk_GS2U_AttackBlock{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_AttackBlock.nActorID),
	Bin3=write_int(P#pk_GS2U_AttackBlock.nCombatID),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_AttackBlock(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_AttackBlock{
		nActorID=D3,
		nCombatID=D6
	},
	Left,
	Count6
	}.

write_PlayerAllShortcut(#pk_PlayerAllShortcut{}=P) -> 
	Bin0=write_int(P#pk_PlayerAllShortcut.index1ID),
	Bin3=write_int(P#pk_PlayerAllShortcut.index2ID),
	Bin6=write_int(P#pk_PlayerAllShortcut.index3ID),
	Bin9=write_int(P#pk_PlayerAllShortcut.index4ID),
	Bin12=write_int(P#pk_PlayerAllShortcut.index5ID),
	Bin15=write_int(P#pk_PlayerAllShortcut.index6ID),
	Bin18=write_int(P#pk_PlayerAllShortcut.index7ID),
	Bin21=write_int(P#pk_PlayerAllShortcut.index8ID),
	Bin24=write_int(P#pk_PlayerAllShortcut.index9ID),
	Bin27=write_int(P#pk_PlayerAllShortcut.index10ID),
	Bin30=write_int(P#pk_PlayerAllShortcut.index11ID),
	Bin33=write_int(P#pk_PlayerAllShortcut.index12ID),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary,Bin33/binary
	>>.

binary_read_PlayerAllShortcut(Bin0)->
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
	{#pk_PlayerAllShortcut{
		index1ID=D3,
		index2ID=D6,
		index3ID=D9,
		index4ID=D12,
		index5ID=D15,
		index6ID=D18,
		index7ID=D21,
		index8ID=D24,
		index9ID=D27,
		index10ID=D30,
		index11ID=D33,
		index12ID=D36
	},
	Left,
	Count36
	}.

write_ShortcutSet(#pk_ShortcutSet{}=P) -> 
	Bin0=write_int8(P#pk_ShortcutSet.index),
	Bin3=write_int(P#pk_ShortcutSet.data),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_ShortcutSet(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_ShortcutSet{
		index=D3,
		data=D6
	},
	Left,
	Count6
	}.

write_PlayerEXPChanged(#pk_PlayerEXPChanged{}=P) -> 
	Bin0=write_int(P#pk_PlayerEXPChanged.curEXP),
	Bin3=write_int8(P#pk_PlayerEXPChanged.changeReson),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PlayerEXPChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PlayerEXPChanged{
		curEXP=D3,
		changeReson=D6
	},
	Left,
	Count6
	}.

write_ActorLifeUpdate(#pk_ActorLifeUpdate{}=P) -> 
	Bin0=write_int64(P#pk_ActorLifeUpdate.nActorID),
	Bin3=write_int(P#pk_ActorLifeUpdate.nLife),
	Bin6=write_int(P#pk_ActorLifeUpdate.nMaxLife),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_ActorLifeUpdate(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_ActorLifeUpdate{
		nActorID=D3,
		nLife=D6,
		nMaxLife=D9
	},
	Left,
	Count9
	}.

write_ActorMoveSpeedUpdate(#pk_ActorMoveSpeedUpdate{}=P) -> 
	Bin0=write_int64(P#pk_ActorMoveSpeedUpdate.nActorID),
	Bin3=write_int(P#pk_ActorMoveSpeedUpdate.nSpeed),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_ActorMoveSpeedUpdate(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_ActorMoveSpeedUpdate{
		nActorID=D3,
		nSpeed=D6
	},
	Left,
	Count6
	}.

write_PlayerCombatIDInit(#pk_PlayerCombatIDInit{}=P) -> 
	Bin0=write_int(P#pk_PlayerCombatIDInit.nBeginCombatID),
	<<Bin0/binary
	>>.

binary_read_PlayerCombatIDInit(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PlayerCombatIDInit{
		nBeginCombatID=D3
	},
	Left,
	Count3
	}.

write_GS2U_CharactorRevived(#pk_GS2U_CharactorRevived{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_CharactorRevived.nActorID),
	Bin3=write_int(P#pk_GS2U_CharactorRevived.nLife),
	Bin6=write_int(P#pk_GS2U_CharactorRevived.nMaxLife),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_GS2U_CharactorRevived(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_GS2U_CharactorRevived{
		nActorID=D3,
		nLife=D6,
		nMaxLife=D9
	},
	Left,
	Count9
	}.

write_U2GS_InteractObject(#pk_U2GS_InteractObject{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_InteractObject.nActorID),
	<<Bin0/binary
	>>.

binary_read_U2GS_InteractObject(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_InteractObject{
		nActorID=D3
	},
	Left,
	Count3
	}.

write_U2GS_QueryHeroProperty(#pk_U2GS_QueryHeroProperty{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_QueryHeroProperty.nReserve),
	<<Bin0/binary
	>>.

binary_read_U2GS_QueryHeroProperty(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_QueryHeroProperty{
		nReserve=D3
	},
	Left,
	Count3
	}.

write_CharPropertyData(#pk_CharPropertyData{}=P) -> 
	Bin0=write_int8(P#pk_CharPropertyData.nPropertyType),
	Bin3=write_int(P#pk_CharPropertyData.nValue),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_CharPropertyData(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_CharPropertyData{
		nPropertyType=D3,
		nValue=D6
	},
	Left,
	Count6
	}.

write_GS2U_HeroPropertyResult(#pk_GS2U_HeroPropertyResult{}=P) -> 
	Bin0=write_array(P#pk_GS2U_HeroPropertyResult.info_list,fun(X)-> write_CharPropertyData(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_HeroPropertyResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_CharPropertyData(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_HeroPropertyResult{
		info_list=D3
	},
	Left,
	Count3
	}.

write_ItemInfo(#pk_ItemInfo{}=P) -> 
	Bin0=write_int64(P#pk_ItemInfo.id),
	Bin3=write_int8(P#pk_ItemInfo.owner_type),
	Bin6=write_int64(P#pk_ItemInfo.owner_id),
	Bin9=write_int8(P#pk_ItemInfo.location),
	Bin12=write_int16(P#pk_ItemInfo.cell),
	Bin15=write_int(P#pk_ItemInfo.amount),
	Bin18=write_int(P#pk_ItemInfo.item_data_id),
	Bin21=write_int(P#pk_ItemInfo.param1),
	Bin24=write_int(P#pk_ItemInfo.param2),
	Bin27=write_int8(P#pk_ItemInfo.binded),
	Bin30=write_int(P#pk_ItemInfo.remain_time),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary
	>>.

binary_read_ItemInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int64(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int16(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_int(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_int(Count24,Bin0),
	Count27=C27+Count24,
	{D30,C30}=binary_read_int8(Count27,Bin0),
	Count30=C30+Count27,
	{D33,C33}=binary_read_int(Count30,Bin0),
	Count33=C33+Count30,
	{_,Left} = split_binary(Bin0,Count33),
	{#pk_ItemInfo{
		id=D3,
		owner_type=D6,
		owner_id=D9,
		location=D12,
		cell=D15,
		amount=D18,
		item_data_id=D21,
		param1=D24,
		param2=D27,
		binded=D30,
		remain_time=D33
	},
	Left,
	Count33
	}.

write_PlayerBagInit(#pk_PlayerBagInit{}=P) -> 
	Bin0=write_array(P#pk_PlayerBagInit.items,fun(X)-> write_ItemInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_PlayerBagInit(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_ItemInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PlayerBagInit{
		items=D3
	},
	Left,
	Count3
	}.

write_PlayerGetItem(#pk_PlayerGetItem{}=P) -> 
	Bin0=write_ItemInfo(P#pk_PlayerGetItem.item_info),
	<<Bin0/binary
	>>.

binary_read_PlayerGetItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_ItemInfo(Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PlayerGetItem{
		item_info=D3
	},
	Left,
	Count3
	}.

write_PlayerDestroyItem(#pk_PlayerDestroyItem{}=P) -> 
	Bin0=write_int64(P#pk_PlayerDestroyItem.itemDBID),
	Bin3=write_int8(P#pk_PlayerDestroyItem.reson),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PlayerDestroyItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PlayerDestroyItem{
		itemDBID=D3,
		reson=D6
	},
	Left,
	Count6
	}.

write_PlayerItemLocationCellChanged(#pk_PlayerItemLocationCellChanged{}=P) -> 
	Bin0=write_int64(P#pk_PlayerItemLocationCellChanged.itemDBID),
	Bin3=write_int8(P#pk_PlayerItemLocationCellChanged.location),
	Bin6=write_int16(P#pk_PlayerItemLocationCellChanged.cell),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PlayerItemLocationCellChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PlayerItemLocationCellChanged{
		itemDBID=D3,
		location=D6,
		cell=D9
	},
	Left,
	Count9
	}.

write_RequestDestroyItem(#pk_RequestDestroyItem{}=P) -> 
	Bin0=write_int64(P#pk_RequestDestroyItem.itemDBID),
	<<Bin0/binary
	>>.

binary_read_RequestDestroyItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestDestroyItem{
		itemDBID=D3
	},
	Left,
	Count3
	}.

write_RequestGetItem(#pk_RequestGetItem{}=P) -> 
	Bin0=write_int(P#pk_RequestGetItem.itemDataID),
	Bin3=write_int(P#pk_RequestGetItem.amount),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_RequestGetItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_RequestGetItem{
		itemDataID=D3,
		amount=D6
	},
	Left,
	Count6
	}.

write_PlayerItemAmountChanged(#pk_PlayerItemAmountChanged{}=P) -> 
	Bin0=write_int64(P#pk_PlayerItemAmountChanged.itemDBID),
	Bin3=write_int(P#pk_PlayerItemAmountChanged.amount),
	Bin6=write_int(P#pk_PlayerItemAmountChanged.reson),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PlayerItemAmountChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PlayerItemAmountChanged{
		itemDBID=D3,
		amount=D6,
		reson=D9
	},
	Left,
	Count9
	}.

write_PlayerItemParamChanged(#pk_PlayerItemParamChanged{}=P) -> 
	Bin0=write_int64(P#pk_PlayerItemParamChanged.itemDBID),
	Bin3=write_int(P#pk_PlayerItemParamChanged.param1),
	Bin6=write_int(P#pk_PlayerItemParamChanged.param2),
	Bin9=write_int(P#pk_PlayerItemParamChanged.reson),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_PlayerItemParamChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_PlayerItemParamChanged{
		itemDBID=D3,
		param1=D6,
		param2=D9,
		reson=D12
	},
	Left,
	Count12
	}.

write_PlayerBagOrderData(#pk_PlayerBagOrderData{}=P) -> 
	Bin0=write_int64(P#pk_PlayerBagOrderData.itemDBID),
	Bin3=write_int(P#pk_PlayerBagOrderData.amount),
	Bin6=write_int(P#pk_PlayerBagOrderData.cell),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PlayerBagOrderData(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PlayerBagOrderData{
		itemDBID=D3,
		amount=D6,
		cell=D9
	},
	Left,
	Count9
	}.

write_RequestPlayerBagOrder(#pk_RequestPlayerBagOrder{}=P) -> 
	Bin0=write_int(P#pk_RequestPlayerBagOrder.location),
	<<Bin0/binary
	>>.

binary_read_RequestPlayerBagOrder(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestPlayerBagOrder{
		location=D3
	},
	Left,
	Count3
	}.

write_PlayerBagOrderResult(#pk_PlayerBagOrderResult{}=P) -> 
	Bin0=write_int(P#pk_PlayerBagOrderResult.location),
	Bin3=write_int(P#pk_PlayerBagOrderResult.cell),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PlayerBagOrderResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PlayerBagOrderResult{
		location=D3,
		cell=D6
	},
	Left,
	Count6
	}.

write_PlayerRequestUseItem(#pk_PlayerRequestUseItem{}=P) -> 
	Bin0=write_int16(P#pk_PlayerRequestUseItem.location),
	Bin3=write_int16(P#pk_PlayerRequestUseItem.cell),
	Bin6=write_int16(P#pk_PlayerRequestUseItem.useCount),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PlayerRequestUseItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PlayerRequestUseItem{
		location=D3,
		cell=D6,
		useCount=D9
	},
	Left,
	Count9
	}.

write_PlayerUseItemResult(#pk_PlayerUseItemResult{}=P) -> 
	Bin0=write_int16(P#pk_PlayerUseItemResult.location),
	Bin3=write_int16(P#pk_PlayerUseItemResult.cell),
	Bin6=write_int(P#pk_PlayerUseItemResult.result),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PlayerUseItemResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PlayerUseItemResult{
		location=D3,
		cell=D6,
		result=D9
	},
	Left,
	Count9
	}.

write_RequestPlayerBagCellOpen(#pk_RequestPlayerBagCellOpen{}=P) -> 
	Bin0=write_int(P#pk_RequestPlayerBagCellOpen.cell),
	Bin3=write_int(P#pk_RequestPlayerBagCellOpen.location),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_RequestPlayerBagCellOpen(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_RequestPlayerBagCellOpen{
		cell=D3,
		location=D6
	},
	Left,
	Count6
	}.

write_RequestChangeStorageBagPassWord(#pk_RequestChangeStorageBagPassWord{}=P) -> 
	Bin0=write_string(P#pk_RequestChangeStorageBagPassWord.oldStorageBagPassWord),
	Bin3=write_string(P#pk_RequestChangeStorageBagPassWord.newStorageBagPassWord),
	Bin6=write_int(P#pk_RequestChangeStorageBagPassWord.status),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_RequestChangeStorageBagPassWord(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_RequestChangeStorageBagPassWord{
		oldStorageBagPassWord=D3,
		newStorageBagPassWord=D6,
		status=D9
	},
	Left,
	Count9
	}.

write_PlayerStorageBagPassWordChanged(#pk_PlayerStorageBagPassWordChanged{}=P) -> 
	Bin0=write_int(P#pk_PlayerStorageBagPassWordChanged.result),
	<<Bin0/binary
	>>.

binary_read_PlayerStorageBagPassWordChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PlayerStorageBagPassWordChanged{
		result=D3
	},
	Left,
	Count3
	}.

write_PlayerBagCellEnableChanged(#pk_PlayerBagCellEnableChanged{}=P) -> 
	Bin0=write_int(P#pk_PlayerBagCellEnableChanged.cell),
	Bin3=write_int(P#pk_PlayerBagCellEnableChanged.location),
	Bin6=write_int(P#pk_PlayerBagCellEnableChanged.gold),
	Bin9=write_int(P#pk_PlayerBagCellEnableChanged.item_count),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_PlayerBagCellEnableChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_PlayerBagCellEnableChanged{
		cell=D3,
		location=D6,
		gold=D9,
		item_count=D12
	},
	Left,
	Count12
	}.

write_RequestPlayerBagSellItem(#pk_RequestPlayerBagSellItem{}=P) -> 
	Bin0=write_int(P#pk_RequestPlayerBagSellItem.cell),
	<<Bin0/binary
	>>.

binary_read_RequestPlayerBagSellItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestPlayerBagSellItem{
		cell=D3
	},
	Left,
	Count3
	}.

write_RequestClearTempBag(#pk_RequestClearTempBag{}=P) -> 
	Bin0=write_int(P#pk_RequestClearTempBag.reserve),
	<<Bin0/binary
	>>.

binary_read_RequestClearTempBag(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestClearTempBag{
		reserve=D3
	},
	Left,
	Count3
	}.

write_RequestMoveTempBagItem(#pk_RequestMoveTempBagItem{}=P) -> 
	Bin0=write_int(P#pk_RequestMoveTempBagItem.cell),
	<<Bin0/binary
	>>.

binary_read_RequestMoveTempBagItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestMoveTempBagItem{
		cell=D3
	},
	Left,
	Count3
	}.

write_RequestMoveAllTempBagItem(#pk_RequestMoveAllTempBagItem{}=P) -> 
	Bin0=write_int(P#pk_RequestMoveAllTempBagItem.reserve),
	<<Bin0/binary
	>>.

binary_read_RequestMoveAllTempBagItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestMoveAllTempBagItem{
		reserve=D3
	},
	Left,
	Count3
	}.

write_RequestMoveStorageBagItem(#pk_RequestMoveStorageBagItem{}=P) -> 
	Bin0=write_int(P#pk_RequestMoveStorageBagItem.cell),
	<<Bin0/binary
	>>.

binary_read_RequestMoveStorageBagItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestMoveStorageBagItem{
		cell=D3
	},
	Left,
	Count3
	}.

write_RequestMoveBagItemToStorage(#pk_RequestMoveBagItemToStorage{}=P) -> 
	Bin0=write_int(P#pk_RequestMoveBagItemToStorage.cell),
	<<Bin0/binary
	>>.

binary_read_RequestMoveBagItemToStorage(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestMoveBagItemToStorage{
		cell=D3
	},
	Left,
	Count3
	}.

write_RequestUnlockingStorageBagPassWord(#pk_RequestUnlockingStorageBagPassWord{}=P) -> 
	Bin0=write_int(P#pk_RequestUnlockingStorageBagPassWord.passWordType),
	<<Bin0/binary
	>>.

binary_read_RequestUnlockingStorageBagPassWord(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestUnlockingStorageBagPassWord{
		passWordType=D3
	},
	Left,
	Count3
	}.

write_RequestCancelUnlockingStorageBagPassWord(#pk_RequestCancelUnlockingStorageBagPassWord{}=P) -> 
	Bin0=write_int(P#pk_RequestCancelUnlockingStorageBagPassWord.passWordType),
	<<Bin0/binary
	>>.

binary_read_RequestCancelUnlockingStorageBagPassWord(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestCancelUnlockingStorageBagPassWord{
		passWordType=D3
	},
	Left,
	Count3
	}.

write_PlayerUnlockTimesChanged(#pk_PlayerUnlockTimesChanged{}=P) -> 
	Bin0=write_int(P#pk_PlayerUnlockTimesChanged.unlockTimes),
	<<Bin0/binary
	>>.

binary_read_PlayerUnlockTimesChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PlayerUnlockTimesChanged{
		unlockTimes=D3
	},
	Left,
	Count3
	}.

write_ItemBagCellSetData(#pk_ItemBagCellSetData{}=P) -> 
	Bin0=write_int(P#pk_ItemBagCellSetData.location),
	Bin3=write_int(P#pk_ItemBagCellSetData.cell),
	Bin6=write_int64(P#pk_ItemBagCellSetData.itemDBID),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_ItemBagCellSetData(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int64(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_ItemBagCellSetData{
		location=D3,
		cell=D6,
		itemDBID=D9
	},
	Left,
	Count9
	}.

write_ItemBagCellSet(#pk_ItemBagCellSet{}=P) -> 
	Bin0=write_array(P#pk_ItemBagCellSet.cells,fun(X)-> write_ItemBagCellSetData(X) end),
	<<Bin0/binary
	>>.

binary_read_ItemBagCellSet(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_ItemBagCellSetData(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_ItemBagCellSet{
		cells=D3
	},
	Left,
	Count3
	}.

write_NpcStoreItemData(#pk_NpcStoreItemData{}=P) -> 
	Bin0=write_int64(P#pk_NpcStoreItemData.id),
	Bin3=write_int(P#pk_NpcStoreItemData.item_id),
	Bin6=write_int(P#pk_NpcStoreItemData.price),
	Bin9=write_int(P#pk_NpcStoreItemData.isbind),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_NpcStoreItemData(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_NpcStoreItemData{
		id=D3,
		item_id=D6,
		price=D9,
		isbind=D12
	},
	Left,
	Count12
	}.

write_RequestGetNpcStoreItemList(#pk_RequestGetNpcStoreItemList{}=P) -> 
	Bin0=write_int(P#pk_RequestGetNpcStoreItemList.store_id),
	<<Bin0/binary
	>>.

binary_read_RequestGetNpcStoreItemList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestGetNpcStoreItemList{
		store_id=D3
	},
	Left,
	Count3
	}.

write_GetNpcStoreItemListAck(#pk_GetNpcStoreItemListAck{}=P) -> 
	Bin0=write_int(P#pk_GetNpcStoreItemListAck.store_id),
	Bin3=write_array(P#pk_GetNpcStoreItemListAck.itemList,fun(X)-> write_NpcStoreItemData(X) end),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GetNpcStoreItemListAck(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_array_head16(Count3,Bin0,fun(X)-> binary_read_NpcStoreItemData(X) end),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GetNpcStoreItemListAck{
		store_id=D3,
		itemList=D6
	},
	Left,
	Count6
	}.

write_RequestBuyItem(#pk_RequestBuyItem{}=P) -> 
	Bin0=write_int(P#pk_RequestBuyItem.item_id),
	Bin3=write_int(P#pk_RequestBuyItem.amount),
	Bin6=write_int(P#pk_RequestBuyItem.store_id),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_RequestBuyItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_RequestBuyItem{
		item_id=D3,
		amount=D6,
		store_id=D9
	},
	Left,
	Count9
	}.

write_BuyItemAck(#pk_BuyItemAck{}=P) -> 
	Bin0=write_int(P#pk_BuyItemAck.count),
	<<Bin0/binary
	>>.

binary_read_BuyItemAck(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_BuyItemAck{
		count=D3
	},
	Left,
	Count3
	}.

write_RequestSellItem(#pk_RequestSellItem{}=P) -> 
	Bin0=write_int64(P#pk_RequestSellItem.item_cell),
	<<Bin0/binary
	>>.

binary_read_RequestSellItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestSellItem{
		item_cell=D3
	},
	Left,
	Count3
	}.

write_GetNpcStoreBackBuyItemList(#pk_GetNpcStoreBackBuyItemList{}=P) -> 
	Bin0=write_int(P#pk_GetNpcStoreBackBuyItemList.count),
	<<Bin0/binary
	>>.

binary_read_GetNpcStoreBackBuyItemList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GetNpcStoreBackBuyItemList{
		count=D3
	},
	Left,
	Count3
	}.

write_GetNpcStoreBackBuyItemListAck(#pk_GetNpcStoreBackBuyItemListAck{}=P) -> 
	Bin0=write_array(P#pk_GetNpcStoreBackBuyItemListAck.itemList,fun(X)-> write_ItemInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_GetNpcStoreBackBuyItemListAck(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_ItemInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GetNpcStoreBackBuyItemListAck{
		itemList=D3
	},
	Left,
	Count3
	}.

write_RequestBackBuyItem(#pk_RequestBackBuyItem{}=P) -> 
	Bin0=write_int64(P#pk_RequestBackBuyItem.item_id),
	<<Bin0/binary
	>>.

binary_read_RequestBackBuyItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestBackBuyItem{
		item_id=D3
	},
	Left,
	Count3
	}.

write_PlayerEquipNetData(#pk_PlayerEquipNetData{}=P) -> 
	Bin0=write_int(P#pk_PlayerEquipNetData.dbID),
	Bin3=write_int(P#pk_PlayerEquipNetData.nEquip),
	Bin6=write_int8(P#pk_PlayerEquipNetData.type),
	Bin9=write_int8(P#pk_PlayerEquipNetData.nQuality),
	Bin12=write_int8(P#pk_PlayerEquipNetData.isEquiped),
	Bin15=write_int16(P#pk_PlayerEquipNetData.enhanceLevel),
	Bin18=write_int8(P#pk_PlayerEquipNetData.property1Type),
	Bin21=write_int8(P#pk_PlayerEquipNetData.property1FixOrPercent),
	Bin24=write_int(P#pk_PlayerEquipNetData.property1Value),
	Bin27=write_int8(P#pk_PlayerEquipNetData.property2Type),
	Bin30=write_int8(P#pk_PlayerEquipNetData.property2FixOrPercent),
	Bin33=write_int(P#pk_PlayerEquipNetData.property2Value),
	Bin36=write_int8(P#pk_PlayerEquipNetData.property3Type),
	Bin39=write_int8(P#pk_PlayerEquipNetData.property3FixOrPercent),
	Bin42=write_int(P#pk_PlayerEquipNetData.property3Value),
	Bin45=write_int8(P#pk_PlayerEquipNetData.property4Type),
	Bin48=write_int8(P#pk_PlayerEquipNetData.property4FixOrPercent),
	Bin51=write_int(P#pk_PlayerEquipNetData.property4Value),
	Bin54=write_int8(P#pk_PlayerEquipNetData.property5Type),
	Bin57=write_int8(P#pk_PlayerEquipNetData.property5FixOrPercent),
	Bin60=write_int(P#pk_PlayerEquipNetData.property5Value),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary,Bin33/binary,Bin36/binary,Bin39/binary,Bin42/binary,Bin45/binary,Bin48/binary,Bin51/binary,Bin54/binary,Bin57/binary,Bin60/binary
	>>.

binary_read_PlayerEquipNetData(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
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
	{D24,C24}=binary_read_int8(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_int(Count24,Bin0),
	Count27=C27+Count24,
	{D30,C30}=binary_read_int8(Count27,Bin0),
	Count30=C30+Count27,
	{D33,C33}=binary_read_int8(Count30,Bin0),
	Count33=C33+Count30,
	{D36,C36}=binary_read_int(Count33,Bin0),
	Count36=C36+Count33,
	{D39,C39}=binary_read_int8(Count36,Bin0),
	Count39=C39+Count36,
	{D42,C42}=binary_read_int8(Count39,Bin0),
	Count42=C42+Count39,
	{D45,C45}=binary_read_int(Count42,Bin0),
	Count45=C45+Count42,
	{D48,C48}=binary_read_int8(Count45,Bin0),
	Count48=C48+Count45,
	{D51,C51}=binary_read_int8(Count48,Bin0),
	Count51=C51+Count48,
	{D54,C54}=binary_read_int(Count51,Bin0),
	Count54=C54+Count51,
	{D57,C57}=binary_read_int8(Count54,Bin0),
	Count57=C57+Count54,
	{D60,C60}=binary_read_int8(Count57,Bin0),
	Count60=C60+Count57,
	{D63,C63}=binary_read_int(Count60,Bin0),
	Count63=C63+Count60,
	{_,Left} = split_binary(Bin0,Count63),
	{#pk_PlayerEquipNetData{
		dbID=D3,
		nEquip=D6,
		type=D9,
		nQuality=D12,
		isEquiped=D15,
		enhanceLevel=D18,
		property1Type=D21,
		property1FixOrPercent=D24,
		property1Value=D27,
		property2Type=D30,
		property2FixOrPercent=D33,
		property2Value=D36,
		property3Type=D39,
		property3FixOrPercent=D42,
		property3Value=D45,
		property4Type=D48,
		property4FixOrPercent=D51,
		property4Value=D54,
		property5Type=D57,
		property5FixOrPercent=D60,
		property5Value=D63
	},
	Left,
	Count63
	}.

write_PlayerEquipInit(#pk_PlayerEquipInit{}=P) -> 
	Bin0=write_array(P#pk_PlayerEquipInit.equips,fun(X)-> write_PlayerEquipNetData(X) end),
	<<Bin0/binary
	>>.

binary_read_PlayerEquipInit(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_PlayerEquipNetData(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PlayerEquipInit{
		equips=D3
	},
	Left,
	Count3
	}.

write_RequestPlayerEquipActive(#pk_RequestPlayerEquipActive{}=P) -> 
	Bin0=write_int(P#pk_RequestPlayerEquipActive.equip_data_id),
	<<Bin0/binary
	>>.

binary_read_RequestPlayerEquipActive(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestPlayerEquipActive{
		equip_data_id=D3
	},
	Left,
	Count3
	}.

write_PlayerEquipActiveResult(#pk_PlayerEquipActiveResult{}=P) -> 
	Bin0=write_PlayerEquipNetData(P#pk_PlayerEquipActiveResult.equip),
	<<Bin0/binary
	>>.

binary_read_PlayerEquipActiveResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_PlayerEquipNetData(Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PlayerEquipActiveResult{
		equip=D3
	},
	Left,
	Count3
	}.

write_RequestPlayerEquipPutOn(#pk_RequestPlayerEquipPutOn{}=P) -> 
	Bin0=write_int(P#pk_RequestPlayerEquipPutOn.equip_dbID),
	<<Bin0/binary
	>>.

binary_read_RequestPlayerEquipPutOn(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestPlayerEquipPutOn{
		equip_dbID=D3
	},
	Left,
	Count3
	}.

write_PlayerEquipPutOnResult(#pk_PlayerEquipPutOnResult{}=P) -> 
	Bin0=write_int(P#pk_PlayerEquipPutOnResult.equip_dbID),
	Bin3=write_int8(P#pk_PlayerEquipPutOnResult.equiped),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PlayerEquipPutOnResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PlayerEquipPutOnResult{
		equip_dbID=D3,
		equiped=D6
	},
	Left,
	Count6
	}.

write_RequestQueryPlayerEquip(#pk_RequestQueryPlayerEquip{}=P) -> 
	Bin0=write_int64(P#pk_RequestQueryPlayerEquip.playerid),
	<<Bin0/binary
	>>.

binary_read_RequestQueryPlayerEquip(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestQueryPlayerEquip{
		playerid=D3
	},
	Left,
	Count3
	}.

write_QueryPlayerEquipResult(#pk_QueryPlayerEquipResult{}=P) -> 
	Bin0=write_array(P#pk_QueryPlayerEquipResult.equips,fun(X)-> write_PlayerEquipNetData(X) end),
	<<Bin0/binary
	>>.

binary_read_QueryPlayerEquipResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_PlayerEquipNetData(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_QueryPlayerEquipResult{
		equips=D3
	},
	Left,
	Count3
	}.

write_StudySkill(#pk_StudySkill{}=P) -> 
	Bin0=write_int(P#pk_StudySkill.id),
	Bin3=write_int(P#pk_StudySkill.lvl),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_StudySkill(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_StudySkill{
		id=D3,
		lvl=D6
	},
	Left,
	Count6
	}.

write_StudyResult(#pk_StudyResult{}=P) -> 
	Bin0=write_int8(P#pk_StudyResult.result),
	Bin3=write_int(P#pk_StudyResult.id),
	Bin6=write_int(P#pk_StudyResult.lvl),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_StudyResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_StudyResult{
		result=D3,
		id=D6,
		lvl=D9
	},
	Left,
	Count9
	}.

write_Reborn(#pk_Reborn{}=P) -> 
	Bin0=write_int8(P#pk_Reborn.type),
	<<Bin0/binary
	>>.

binary_read_Reborn(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_Reborn{
		type=D3
	},
	Left,
	Count3
	}.

write_RebornAck(#pk_RebornAck{}=P) -> 
	Bin0=write_int(P#pk_RebornAck.x),
	Bin3=write_int(P#pk_RebornAck.y),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_RebornAck(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_RebornAck{
		x=D3,
		y=D6
	},
	Left,
	Count6
	}.

write_Chat2Player(#pk_Chat2Player{}=P) -> 
	Bin0=write_int8(P#pk_Chat2Player.channel),
	Bin3=write_int64(P#pk_Chat2Player.sendID),
	Bin6=write_int64(P#pk_Chat2Player.receiveID),
	Bin9=write_string(P#pk_Chat2Player.sendName),
	Bin12=write_string(P#pk_Chat2Player.receiveName),
	Bin15=write_string(P#pk_Chat2Player.content),
	Bin18=write_int8(P#pk_Chat2Player.vipLevel),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary
	>>.

binary_read_Chat2Player(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int64(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_string(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_string(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_string(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int8(Count18,Bin0),
	Count21=C21+Count18,
	{_,Left} = split_binary(Bin0,Count21),
	{#pk_Chat2Player{
		channel=D3,
		sendID=D6,
		receiveID=D9,
		sendName=D12,
		receiveName=D15,
		content=D18,
		vipLevel=D21
	},
	Left,
	Count21
	}.

write_Chat2Server(#pk_Chat2Server{}=P) -> 
	Bin0=write_int8(P#pk_Chat2Server.channel),
	Bin3=write_int64(P#pk_Chat2Server.sendID),
	Bin6=write_int64(P#pk_Chat2Server.receiveID),
	Bin9=write_string(P#pk_Chat2Server.sendName),
	Bin12=write_string(P#pk_Chat2Server.receiveName),
	Bin15=write_string(P#pk_Chat2Server.content),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary
	>>.

binary_read_Chat2Server(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int64(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_string(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_string(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_string(Count15,Bin0),
	Count18=C18+Count15,
	{_,Left} = split_binary(Bin0,Count18),
	{#pk_Chat2Server{
		channel=D3,
		sendID=D6,
		receiveID=D9,
		sendName=D12,
		receiveName=D15,
		content=D18
	},
	Left,
	Count18
	}.

write_Chat_Error_Result(#pk_Chat_Error_Result{}=P) -> 
	Bin0=write_int(P#pk_Chat_Error_Result.reason),
	<<Bin0/binary
	>>.

binary_read_Chat_Error_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_Chat_Error_Result{
		reason=D3
	},
	Left,
	Count3
	}.

write_RequestSendMail(#pk_RequestSendMail{}=P) -> 
	Bin0=write_int64(P#pk_RequestSendMail.targetPlayerID),
	Bin3=write_string(P#pk_RequestSendMail.targetPlayerName),
	Bin6=write_string(P#pk_RequestSendMail.strTitle),
	Bin9=write_string(P#pk_RequestSendMail.strContent),
	Bin12=write_int64(P#pk_RequestSendMail.attachItemDBID1),
	Bin15=write_int(P#pk_RequestSendMail.attachItem1Cnt),
	Bin18=write_int64(P#pk_RequestSendMail.attachItemDBID2),
	Bin21=write_int(P#pk_RequestSendMail.attachItem2Cnt),
	Bin24=write_int(P#pk_RequestSendMail.moneySend),
	Bin27=write_int(P#pk_RequestSendMail.moneyPay),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary
	>>.

binary_read_RequestSendMail(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_string(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int64(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int64(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_int(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_int(Count24,Bin0),
	Count27=C27+Count24,
	{D30,C30}=binary_read_int(Count27,Bin0),
	Count30=C30+Count27,
	{_,Left} = split_binary(Bin0,Count30),
	{#pk_RequestSendMail{
		targetPlayerID=D3,
		targetPlayerName=D6,
		strTitle=D9,
		strContent=D12,
		attachItemDBID1=D15,
		attachItem1Cnt=D18,
		attachItemDBID2=D21,
		attachItem2Cnt=D24,
		moneySend=D27,
		moneyPay=D30
	},
	Left,
	Count30
	}.

write_RequestSendMailAck(#pk_RequestSendMailAck{}=P) -> 
	Bin0=write_int8(P#pk_RequestSendMailAck.result),
	<<Bin0/binary
	>>.

binary_read_RequestSendMailAck(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestSendMailAck{
		result=D3
	},
	Left,
	Count3
	}.

write_RequestRecvMail(#pk_RequestRecvMail{}=P) -> 
	Bin0=write_int64(P#pk_RequestRecvMail.mailID),
	Bin3=write_int(P#pk_RequestRecvMail.deleteMail),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_RequestRecvMail(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_RequestRecvMail{
		mailID=D3,
		deleteMail=D6
	},
	Left,
	Count6
	}.

write_RequestUnReadMail(#pk_RequestUnReadMail{}=P) -> 
	Bin0=write_int64(P#pk_RequestUnReadMail.playerID),
	<<Bin0/binary
	>>.

binary_read_RequestUnReadMail(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestUnReadMail{
		playerID=D3
	},
	Left,
	Count3
	}.

write_RequestUnReadMailAck(#pk_RequestUnReadMailAck{}=P) -> 
	Bin0=write_int(P#pk_RequestUnReadMailAck.unReadCount),
	<<Bin0/binary
	>>.

binary_read_RequestUnReadMailAck(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestUnReadMailAck{
		unReadCount=D3
	},
	Left,
	Count3
	}.

write_RequestMailList(#pk_RequestMailList{}=P) -> 
	Bin0=write_int64(P#pk_RequestMailList.playerID),
	<<Bin0/binary
	>>.

binary_read_RequestMailList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestMailList{
		playerID=D3
	},
	Left,
	Count3
	}.

write_MailInfo(#pk_MailInfo{}=P) -> 
	Bin0=write_int64(P#pk_MailInfo.id),
	Bin3=write_int(P#pk_MailInfo.type),
	Bin6=write_int64(P#pk_MailInfo.recvPlayerID),
	Bin9=write_int(P#pk_MailInfo.isOpen),
	Bin12=write_int(P#pk_MailInfo.timeOut),
	Bin15=write_int(P#pk_MailInfo.senderType),
	Bin18=write_string(P#pk_MailInfo.senderName),
	Bin21=write_string(P#pk_MailInfo.title),
	Bin24=write_string(P#pk_MailInfo.content),
	Bin27=write_int8(P#pk_MailInfo.haveItem),
	Bin30=write_int(P#pk_MailInfo.moneySend),
	Bin33=write_int(P#pk_MailInfo.moneyPay),
	Bin36=write_int(P#pk_MailInfo.mailTimerType),
	Bin39=write_int(P#pk_MailInfo.mailRecTime),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary,Bin33/binary,Bin36/binary,Bin39/binary
	>>.

binary_read_MailInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int64(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_string(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_string(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_string(Count24,Bin0),
	Count27=C27+Count24,
	{D30,C30}=binary_read_int8(Count27,Bin0),
	Count30=C30+Count27,
	{D33,C33}=binary_read_int(Count30,Bin0),
	Count33=C33+Count30,
	{D36,C36}=binary_read_int(Count33,Bin0),
	Count36=C36+Count33,
	{D39,C39}=binary_read_int(Count36,Bin0),
	Count39=C39+Count36,
	{D42,C42}=binary_read_int(Count39,Bin0),
	Count42=C42+Count39,
	{_,Left} = split_binary(Bin0,Count42),
	{#pk_MailInfo{
		id=D3,
		type=D6,
		recvPlayerID=D9,
		isOpen=D12,
		timeOut=D15,
		senderType=D18,
		senderName=D21,
		title=D24,
		content=D27,
		haveItem=D30,
		moneySend=D33,
		moneyPay=D36,
		mailTimerType=D39,
		mailRecTime=D42
	},
	Left,
	Count42
	}.

write_RequestMailListAck(#pk_RequestMailListAck{}=P) -> 
	Bin0=write_array(P#pk_RequestMailListAck.mailList,fun(X)-> write_MailInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_RequestMailListAck(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_MailInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestMailListAck{
		mailList=D3
	},
	Left,
	Count3
	}.

write_RequestMailItemInfo(#pk_RequestMailItemInfo{}=P) -> 
	Bin0=write_int64(P#pk_RequestMailItemInfo.mailID),
	<<Bin0/binary
	>>.

binary_read_RequestMailItemInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestMailItemInfo{
		mailID=D3
	},
	Left,
	Count3
	}.

write_RequestMailItemInfoAck(#pk_RequestMailItemInfoAck{}=P) -> 
	Bin0=write_int64(P#pk_RequestMailItemInfoAck.mailID),
	Bin3=write_array(P#pk_RequestMailItemInfoAck.mailItem,fun(X)-> write_ItemInfo(X) end),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_RequestMailItemInfoAck(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_array_head16(Count3,Bin0,fun(X)-> binary_read_ItemInfo(X) end),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_RequestMailItemInfoAck{
		mailID=D3,
		mailItem=D6
	},
	Left,
	Count6
	}.

write_RequestAcceptMailItem(#pk_RequestAcceptMailItem{}=P) -> 
	Bin0=write_int64(P#pk_RequestAcceptMailItem.mailID),
	Bin3=write_int(P#pk_RequestAcceptMailItem.isDeleteMail),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_RequestAcceptMailItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_RequestAcceptMailItem{
		mailID=D3,
		isDeleteMail=D6
	},
	Left,
	Count6
	}.

write_RequestAcceptMailItemAck(#pk_RequestAcceptMailItemAck{}=P) -> 
	Bin0=write_int(P#pk_RequestAcceptMailItemAck.result),
	<<Bin0/binary
	>>.

binary_read_RequestAcceptMailItemAck(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestAcceptMailItemAck{
		result=D3
	},
	Left,
	Count3
	}.

write_MailReadNotice(#pk_MailReadNotice{}=P) -> 
	Bin0=write_int64(P#pk_MailReadNotice.mailID),
	<<Bin0/binary
	>>.

binary_read_MailReadNotice(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_MailReadNotice{
		mailID=D3
	},
	Left,
	Count3
	}.

write_RequestDeleteMail(#pk_RequestDeleteMail{}=P) -> 
	Bin0=write_int64(P#pk_RequestDeleteMail.mailID),
	<<Bin0/binary
	>>.

binary_read_RequestDeleteMail(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestDeleteMail{
		mailID=D3
	},
	Left,
	Count3
	}.

write_InformNewMail(#pk_InformNewMail{}=P) -> 
	<<
	>>.

binary_read_InformNewMail(Bin0)->
	Count0=0,
	{_,Left} = split_binary(Bin0,Count0),
	{#pk_InformNewMail{
	},
	Left,
	Count0
	}.

write_RequestDeleteReadMail(#pk_RequestDeleteReadMail{}=P) -> 
	Bin0=write_array(P#pk_RequestDeleteReadMail.readMailID,fun(X)-> write_int64(X) end),
	<<Bin0/binary
	>>.

binary_read_RequestDeleteReadMail(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_int64(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestDeleteReadMail{
		readMailID=D3
	},
	Left,
	Count3
	}.

write_RequestSystemMail(#pk_RequestSystemMail{}=P) -> 
	<<
	>>.

binary_read_RequestSystemMail(Bin0)->
	Count0=0,
	{_,Left} = split_binary(Bin0,Count0),
	{#pk_RequestSystemMail{
	},
	Left,
	Count0
	}.

write_U2GS_RequestLogin(#pk_U2GS_RequestLogin{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_RequestLogin.userID),
	Bin3=write_string(P#pk_U2GS_RequestLogin.identity),
	Bin6=write_int(P#pk_U2GS_RequestLogin.protocolVer),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_U2GS_RequestLogin(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_U2GS_RequestLogin{
		userID=D3,
		identity=D6,
		protocolVer=D9
	},
	Left,
	Count9
	}.

write_U2GS_SelPlayerEnterGame(#pk_U2GS_SelPlayerEnterGame{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_SelPlayerEnterGame.playerID),
	<<Bin0/binary
	>>.

binary_read_U2GS_SelPlayerEnterGame(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_SelPlayerEnterGame{
		playerID=D3
	},
	Left,
	Count3
	}.

write_U2GS_RequestCreatePlayer(#pk_U2GS_RequestCreatePlayer{}=P) -> 
	Bin0=write_string(P#pk_U2GS_RequestCreatePlayer.name),
	Bin3=write_int8(P#pk_U2GS_RequestCreatePlayer.camp),
	Bin6=write_int8(P#pk_U2GS_RequestCreatePlayer.classValue),
	Bin9=write_int8(P#pk_U2GS_RequestCreatePlayer.sex),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_U2GS_RequestCreatePlayer(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_U2GS_RequestCreatePlayer{
		name=D3,
		camp=D6,
		classValue=D9,
		sex=D12
	},
	Left,
	Count12
	}.

write_U2GS_RequestDeletePlayer(#pk_U2GS_RequestDeletePlayer{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_RequestDeletePlayer.playerID),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestDeletePlayer(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestDeletePlayer{
		playerID=D3
	},
	Left,
	Count3
	}.

write_GS2U_LoginResult(#pk_GS2U_LoginResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_LoginResult.result),
	<<Bin0/binary
	>>.

binary_read_GS2U_LoginResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_LoginResult{
		result=D3
	},
	Left,
	Count3
	}.

write_GS2U_SelPlayerResult(#pk_GS2U_SelPlayerResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_SelPlayerResult.result),
	<<Bin0/binary
	>>.

binary_read_GS2U_SelPlayerResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_SelPlayerResult{
		result=D3
	},
	Left,
	Count3
	}.

write_UserPlayerData(#pk_UserPlayerData{}=P) -> 
	Bin0=write_int64(P#pk_UserPlayerData.playerID),
	Bin3=write_string(P#pk_UserPlayerData.name),
	Bin6=write_int(P#pk_UserPlayerData.level),
	Bin9=write_int8(P#pk_UserPlayerData.classValue),
	Bin12=write_int8(P#pk_UserPlayerData.sex),
	Bin15=write_int8(P#pk_UserPlayerData.faction),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary
	>>.

binary_read_UserPlayerData(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int8(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int8(Count15,Bin0),
	Count18=C18+Count15,
	{_,Left} = split_binary(Bin0,Count18),
	{#pk_UserPlayerData{
		playerID=D3,
		name=D6,
		level=D9,
		classValue=D12,
		sex=D15,
		faction=D18
	},
	Left,
	Count18
	}.

write_GS2U_UserPlayerList(#pk_GS2U_UserPlayerList{}=P) -> 
	Bin0=write_array(P#pk_GS2U_UserPlayerList.info,fun(X)-> write_UserPlayerData(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_UserPlayerList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_UserPlayerData(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_UserPlayerList{
		info=D3
	},
	Left,
	Count3
	}.

write_GS2U_CreatePlayerResult(#pk_GS2U_CreatePlayerResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_CreatePlayerResult.errorCode),
	<<Bin0/binary
	>>.

binary_read_GS2U_CreatePlayerResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_CreatePlayerResult{
		errorCode=D3
	},
	Left,
	Count3
	}.

write_GS2U_DeletePlayerResult(#pk_GS2U_DeletePlayerResult{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_DeletePlayerResult.playerID),
	Bin3=write_int(P#pk_GS2U_DeletePlayerResult.errorCode),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_DeletePlayerResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_DeletePlayerResult{
		playerID=D3,
		errorCode=D6
	},
	Left,
	Count6
	}.

write_ConSales_GroundingItem(#pk_ConSales_GroundingItem{}=P) -> 
	Bin0=write_int64(P#pk_ConSales_GroundingItem.dbId),
	Bin3=write_int(P#pk_ConSales_GroundingItem.count),
	Bin6=write_int(P#pk_ConSales_GroundingItem.money),
	Bin9=write_int(P#pk_ConSales_GroundingItem.timeType),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_ConSales_GroundingItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_ConSales_GroundingItem{
		dbId=D3,
		count=D6,
		money=D9,
		timeType=D12
	},
	Left,
	Count12
	}.

write_ConSales_GroundingItem_Result(#pk_ConSales_GroundingItem_Result{}=P) -> 
	Bin0=write_int(P#pk_ConSales_GroundingItem_Result.result),
	<<Bin0/binary
	>>.

binary_read_ConSales_GroundingItem_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_ConSales_GroundingItem_Result{
		result=D3
	},
	Left,
	Count3
	}.

write_ConSales_TakeDown(#pk_ConSales_TakeDown{}=P) -> 
	Bin0=write_int64(P#pk_ConSales_TakeDown.conSalesId),
	<<Bin0/binary
	>>.

binary_read_ConSales_TakeDown(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_ConSales_TakeDown{
		conSalesId=D3
	},
	Left,
	Count3
	}.

write_ConSales_TakeDown_Result(#pk_ConSales_TakeDown_Result{}=P) -> 
	Bin0=write_int(P#pk_ConSales_TakeDown_Result.allTakeDown),
	Bin3=write_int(P#pk_ConSales_TakeDown_Result.result),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_ConSales_TakeDown_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_ConSales_TakeDown_Result{
		allTakeDown=D3,
		result=D6
	},
	Left,
	Count6
	}.

write_ConSales_BuyItem(#pk_ConSales_BuyItem{}=P) -> 
	Bin0=write_int64(P#pk_ConSales_BuyItem.conSalesOderId),
	<<Bin0/binary
	>>.

binary_read_ConSales_BuyItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_ConSales_BuyItem{
		conSalesOderId=D3
	},
	Left,
	Count3
	}.

write_ConSales_BuyItem_Result(#pk_ConSales_BuyItem_Result{}=P) -> 
	Bin0=write_int8(P#pk_ConSales_BuyItem_Result.result),
	<<Bin0/binary
	>>.

binary_read_ConSales_BuyItem_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_ConSales_BuyItem_Result{
		result=D3
	},
	Left,
	Count3
	}.

write_ConSales_FindItems(#pk_ConSales_FindItems{}=P) -> 
	Bin0=write_int(P#pk_ConSales_FindItems.offsetCount),
	Bin3=write_int8(P#pk_ConSales_FindItems.ignoreOption),
	Bin6=write_int8(P#pk_ConSales_FindItems.type),
	Bin9=write_int8(P#pk_ConSales_FindItems.detType),
	Bin12=write_int(P#pk_ConSales_FindItems.levelMin),
	Bin15=write_int(P#pk_ConSales_FindItems.levelMax),
	Bin18=write_int(P#pk_ConSales_FindItems.occ),
	Bin21=write_int(P#pk_ConSales_FindItems.quality),
	Bin24=write_int(P#pk_ConSales_FindItems.idLimit),
	Bin27=write_array(P#pk_ConSales_FindItems.idList,fun(X)-> write_int(X) end),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary
	>>.

binary_read_ConSales_FindItems(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
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
	{D30,C30}=binary_read_array_head16(Count27,Bin0,fun(X)-> binary_read_int(X) end),
	Count30=C30+Count27,
	{_,Left} = split_binary(Bin0,Count30),
	{#pk_ConSales_FindItems{
		offsetCount=D3,
		ignoreOption=D6,
		type=D9,
		detType=D12,
		levelMin=D15,
		levelMax=D18,
		occ=D21,
		quality=D24,
		idLimit=D27,
		idList=D30
	},
	Left,
	Count30
	}.

write_ConSalesItem(#pk_ConSalesItem{}=P) -> 
	Bin0=write_int64(P#pk_ConSalesItem.conSalesId),
	Bin3=write_int(P#pk_ConSalesItem.conSalesMoney),
	Bin6=write_int(P#pk_ConSalesItem.groundingTime),
	Bin9=write_int(P#pk_ConSalesItem.timeType),
	Bin12=write_int(P#pk_ConSalesItem.playerId),
	Bin15=write_string(P#pk_ConSalesItem.playerName),
	Bin18=write_int(P#pk_ConSalesItem.itemDBId),
	Bin21=write_int(P#pk_ConSalesItem.itemId),
	Bin24=write_int(P#pk_ConSalesItem.itemCount),
	Bin27=write_int(P#pk_ConSalesItem.itemType),
	Bin30=write_int(P#pk_ConSalesItem.itemQuality),
	Bin33=write_int(P#pk_ConSalesItem.itemLevel),
	Bin36=write_int(P#pk_ConSalesItem.itemOcc),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary,Bin33/binary,Bin36/binary
	>>.

binary_read_ConSalesItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_string(Count15,Bin0),
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
	{D39,C39}=binary_read_int(Count36,Bin0),
	Count39=C39+Count36,
	{_,Left} = split_binary(Bin0,Count39),
	{#pk_ConSalesItem{
		conSalesId=D3,
		conSalesMoney=D6,
		groundingTime=D9,
		timeType=D12,
		playerId=D15,
		playerName=D18,
		itemDBId=D21,
		itemId=D24,
		itemCount=D27,
		itemType=D30,
		itemQuality=D33,
		itemLevel=D36,
		itemOcc=D39
	},
	Left,
	Count39
	}.

write_ConSales_FindItems_Result(#pk_ConSales_FindItems_Result{}=P) -> 
	Bin0=write_int(P#pk_ConSales_FindItems_Result.result),
	Bin3=write_int(P#pk_ConSales_FindItems_Result.allCount),
	Bin6=write_int(P#pk_ConSales_FindItems_Result.page),
	Bin9=write_array(P#pk_ConSales_FindItems_Result.itemList,fun(X)-> write_ConSalesItem(X) end),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_ConSales_FindItems_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_array_head16(Count9,Bin0,fun(X)-> binary_read_ConSalesItem(X) end),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_ConSales_FindItems_Result{
		result=D3,
		allCount=D6,
		page=D9,
		itemList=D12
	},
	Left,
	Count12
	}.

write_ConSales_TrunPage(#pk_ConSales_TrunPage{}=P) -> 
	Bin0=write_int(P#pk_ConSales_TrunPage.mode),
	<<Bin0/binary
	>>.

binary_read_ConSales_TrunPage(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_ConSales_TrunPage{
		mode=D3
	},
	Left,
	Count3
	}.

write_ConSales_Close(#pk_ConSales_Close{}=P) -> 
	Bin0=write_int(P#pk_ConSales_Close.n),
	<<Bin0/binary
	>>.

binary_read_ConSales_Close(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_ConSales_Close{
		n=D3
	},
	Left,
	Count3
	}.

write_ConSales_GetSelfSell(#pk_ConSales_GetSelfSell{}=P) -> 
	Bin0=write_int(P#pk_ConSales_GetSelfSell.n),
	<<Bin0/binary
	>>.

binary_read_ConSales_GetSelfSell(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_ConSales_GetSelfSell{
		n=D3
	},
	Left,
	Count3
	}.

write_ConSales_GetSelfSell_Result(#pk_ConSales_GetSelfSell_Result{}=P) -> 
	Bin0=write_array(P#pk_ConSales_GetSelfSell_Result.itemList,fun(X)-> write_ConSalesItem(X) end),
	<<Bin0/binary
	>>.

binary_read_ConSales_GetSelfSell_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_ConSalesItem(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_ConSales_GetSelfSell_Result{
		itemList=D3
	},
	Left,
	Count3
	}.

write_TradeAsk(#pk_TradeAsk{}=P) -> 
	Bin0=write_int64(P#pk_TradeAsk.playerID),
	Bin3=write_string(P#pk_TradeAsk.playerName),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_TradeAsk(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_TradeAsk{
		playerID=D3,
		playerName=D6
	},
	Left,
	Count6
	}.

write_TradeAskResult(#pk_TradeAskResult{}=P) -> 
	Bin0=write_int64(P#pk_TradeAskResult.playerID),
	Bin3=write_string(P#pk_TradeAskResult.playerName),
	Bin6=write_int8(P#pk_TradeAskResult.result),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_TradeAskResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_TradeAskResult{
		playerID=D3,
		playerName=D6,
		result=D9
	},
	Left,
	Count9
	}.

write_CreateTrade(#pk_CreateTrade{}=P) -> 
	Bin0=write_int64(P#pk_CreateTrade.playerID),
	Bin3=write_string(P#pk_CreateTrade.playerName),
	Bin6=write_int8(P#pk_CreateTrade.result),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_CreateTrade(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_CreateTrade{
		playerID=D3,
		playerName=D6,
		result=D9
	},
	Left,
	Count9
	}.

write_TradeInputItem_C2S(#pk_TradeInputItem_C2S{}=P) -> 
	Bin0=write_int(P#pk_TradeInputItem_C2S.cell),
	Bin3=write_int64(P#pk_TradeInputItem_C2S.itemDBID),
	Bin6=write_int(P#pk_TradeInputItem_C2S.count),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_TradeInputItem_C2S(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_TradeInputItem_C2S{
		cell=D3,
		itemDBID=D6,
		count=D9
	},
	Left,
	Count9
	}.

write_TradeInputItemResult_S2C(#pk_TradeInputItemResult_S2C{}=P) -> 
	Bin0=write_int64(P#pk_TradeInputItemResult_S2C.itemDBID),
	Bin3=write_int(P#pk_TradeInputItemResult_S2C.item_data_id),
	Bin6=write_int(P#pk_TradeInputItemResult_S2C.count),
	Bin9=write_int(P#pk_TradeInputItemResult_S2C.cell),
	Bin12=write_int8(P#pk_TradeInputItemResult_S2C.result),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary
	>>.

binary_read_TradeInputItemResult_S2C(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int8(Count12,Bin0),
	Count15=C15+Count12,
	{_,Left} = split_binary(Bin0,Count15),
	{#pk_TradeInputItemResult_S2C{
		itemDBID=D3,
		item_data_id=D6,
		count=D9,
		cell=D12,
		result=D15
	},
	Left,
	Count15
	}.

write_TradeInputItem_S2C(#pk_TradeInputItem_S2C{}=P) -> 
	Bin0=write_int64(P#pk_TradeInputItem_S2C.itemDBID),
	Bin3=write_int(P#pk_TradeInputItem_S2C.item_data_id),
	Bin6=write_int(P#pk_TradeInputItem_S2C.count),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_TradeInputItem_S2C(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_TradeInputItem_S2C{
		itemDBID=D3,
		item_data_id=D6,
		count=D9
	},
	Left,
	Count9
	}.

write_TradeTakeOutItem_C2S(#pk_TradeTakeOutItem_C2S{}=P) -> 
	Bin0=write_int64(P#pk_TradeTakeOutItem_C2S.itemDBID),
	<<Bin0/binary
	>>.

binary_read_TradeTakeOutItem_C2S(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_TradeTakeOutItem_C2S{
		itemDBID=D3
	},
	Left,
	Count3
	}.

write_TradeTakeOutItemResult_S2C(#pk_TradeTakeOutItemResult_S2C{}=P) -> 
	Bin0=write_int(P#pk_TradeTakeOutItemResult_S2C.cell),
	Bin3=write_int64(P#pk_TradeTakeOutItemResult_S2C.itemDBID),
	Bin6=write_int8(P#pk_TradeTakeOutItemResult_S2C.result),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_TradeTakeOutItemResult_S2C(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_TradeTakeOutItemResult_S2C{
		cell=D3,
		itemDBID=D6,
		result=D9
	},
	Left,
	Count9
	}.

write_TradeTakeOutItem_S2C(#pk_TradeTakeOutItem_S2C{}=P) -> 
	Bin0=write_int64(P#pk_TradeTakeOutItem_S2C.itemDBID),
	<<Bin0/binary
	>>.

binary_read_TradeTakeOutItem_S2C(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_TradeTakeOutItem_S2C{
		itemDBID=D3
	},
	Left,
	Count3
	}.

write_TradeChangeMoney_C2S(#pk_TradeChangeMoney_C2S{}=P) -> 
	Bin0=write_int(P#pk_TradeChangeMoney_C2S.money),
	<<Bin0/binary
	>>.

binary_read_TradeChangeMoney_C2S(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_TradeChangeMoney_C2S{
		money=D3
	},
	Left,
	Count3
	}.

write_TradeChangeMoneyResult_S2C(#pk_TradeChangeMoneyResult_S2C{}=P) -> 
	Bin0=write_int(P#pk_TradeChangeMoneyResult_S2C.money),
	Bin3=write_int8(P#pk_TradeChangeMoneyResult_S2C.result),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_TradeChangeMoneyResult_S2C(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_TradeChangeMoneyResult_S2C{
		money=D3,
		result=D6
	},
	Left,
	Count6
	}.

write_TradeChangeMoney_S2C(#pk_TradeChangeMoney_S2C{}=P) -> 
	Bin0=write_int(P#pk_TradeChangeMoney_S2C.money),
	<<Bin0/binary
	>>.

binary_read_TradeChangeMoney_S2C(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_TradeChangeMoney_S2C{
		money=D3
	},
	Left,
	Count3
	}.

write_TradeLock_C2S(#pk_TradeLock_C2S{}=P) -> 
	Bin0=write_int8(P#pk_TradeLock_C2S.lock),
	<<Bin0/binary
	>>.

binary_read_TradeLock_C2S(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_TradeLock_C2S{
		lock=D3
	},
	Left,
	Count3
	}.

write_TradeLock_S2C(#pk_TradeLock_S2C{}=P) -> 
	Bin0=write_int8(P#pk_TradeLock_S2C.person),
	Bin3=write_int8(P#pk_TradeLock_S2C.lock),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_TradeLock_S2C(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_TradeLock_S2C{
		person=D3,
		lock=D6
	},
	Left,
	Count6
	}.

write_CancelTrade_S2C(#pk_CancelTrade_S2C{}=P) -> 
	Bin0=write_int8(P#pk_CancelTrade_S2C.person),
	Bin3=write_int8(P#pk_CancelTrade_S2C.reason),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_CancelTrade_S2C(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_CancelTrade_S2C{
		person=D3,
		reason=D6
	},
	Left,
	Count6
	}.

write_CancelTrade_C2S(#pk_CancelTrade_C2S{}=P) -> 
	Bin0=write_int8(P#pk_CancelTrade_C2S.reason),
	<<Bin0/binary
	>>.

binary_read_CancelTrade_C2S(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_CancelTrade_C2S{
		reason=D3
	},
	Left,
	Count3
	}.

write_TradeAffirm_C2S(#pk_TradeAffirm_C2S{}=P) -> 
	Bin0=write_int(P#pk_TradeAffirm_C2S.bAffrim),
	<<Bin0/binary
	>>.

binary_read_TradeAffirm_C2S(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_TradeAffirm_C2S{
		bAffrim=D3
	},
	Left,
	Count3
	}.

write_TradeAffirm_S2C(#pk_TradeAffirm_S2C{}=P) -> 
	Bin0=write_int8(P#pk_TradeAffirm_S2C.person),
	Bin3=write_int8(P#pk_TradeAffirm_S2C.bAffirm),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_TradeAffirm_S2C(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_TradeAffirm_S2C{
		person=D3,
		bAffirm=D6
	},
	Left,
	Count6
	}.

write_PetSkill(#pk_PetSkill{}=P) -> 
	Bin0=write_int64(P#pk_PetSkill.id),
	Bin3=write_int(P#pk_PetSkill.coolDownTime),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PetSkill(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PetSkill{
		id=D3,
		coolDownTime=D6
	},
	Left,
	Count6
	}.

write_PetProperty(#pk_PetProperty{}=P) -> 
	Bin0=write_int64(P#pk_PetProperty.db_id),
	Bin3=write_int(P#pk_PetProperty.data_id),
	Bin6=write_int64(P#pk_PetProperty.master_id),
	Bin9=write_int(P#pk_PetProperty.level),
	Bin12=write_int(P#pk_PetProperty.exp),
	Bin15=write_string(P#pk_PetProperty.name),
	Bin18=write_int(P#pk_PetProperty.titleId),
	Bin21=write_int8(P#pk_PetProperty.aiState),
	Bin24=write_int8(P#pk_PetProperty.showModel),
	Bin27=write_int(P#pk_PetProperty.exModelId),
	Bin30=write_int(P#pk_PetProperty.soulLevel),
	Bin33=write_int(P#pk_PetProperty.soulRate),
	Bin36=write_int(P#pk_PetProperty.attackGrowUp),
	Bin39=write_int(P#pk_PetProperty.defGrowUp),
	Bin42=write_int(P#pk_PetProperty.lifeGrowUp),
	Bin45=write_int8(P#pk_PetProperty.isWashGrow),
	Bin48=write_int(P#pk_PetProperty.attackGrowUpWash),
	Bin51=write_int(P#pk_PetProperty.defGrowUpWash),
	Bin54=write_int(P#pk_PetProperty.lifeGrowUpWash),
	Bin57=write_int(P#pk_PetProperty.convertRatio),
	Bin60=write_int(P#pk_PetProperty.exerciseLevel),
	Bin63=write_int(P#pk_PetProperty.moneyExrciseNum),
	Bin66=write_int(P#pk_PetProperty.exerciseExp),
	Bin69=write_int(P#pk_PetProperty.maxSkillNum),
	Bin72=write_array(P#pk_PetProperty.skills,fun(X)-> write_PetSkill(X) end),
	Bin75=write_int(P#pk_PetProperty.life),
	Bin78=write_int(P#pk_PetProperty.maxLife),
	Bin81=write_int(P#pk_PetProperty.attack),
	Bin84=write_int(P#pk_PetProperty.def),
	Bin87=write_int(P#pk_PetProperty.crit),
	Bin90=write_int(P#pk_PetProperty.block),
	Bin93=write_int(P#pk_PetProperty.hit),
	Bin96=write_int(P#pk_PetProperty.dodge),
	Bin99=write_int(P#pk_PetProperty.tough),
	Bin102=write_int(P#pk_PetProperty.pierce),
	Bin105=write_int(P#pk_PetProperty.crit_damage_rate),
	Bin108=write_int(P#pk_PetProperty.attack_speed),
	Bin111=write_int(P#pk_PetProperty.ph_def),
	Bin114=write_int(P#pk_PetProperty.fire_def),
	Bin117=write_int(P#pk_PetProperty.ice_def),
	Bin120=write_int(P#pk_PetProperty.elec_def),
	Bin123=write_int(P#pk_PetProperty.poison_def),
	Bin126=write_int(P#pk_PetProperty.coma_def),
	Bin129=write_int(P#pk_PetProperty.hold_def),
	Bin132=write_int(P#pk_PetProperty.silent_def),
	Bin135=write_int(P#pk_PetProperty.move_def),
	Bin138=write_int(P#pk_PetProperty.atkPowerGrowUp_Max),
	Bin141=write_int(P#pk_PetProperty.defClassGrowUp_Max),
	Bin144=write_int(P#pk_PetProperty.hpGrowUp_Max),
	Bin147=write_int(P#pk_PetProperty.benison_Value),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary,Bin33/binary,Bin36/binary,Bin39/binary,Bin42/binary,Bin45/binary,Bin48/binary,Bin51/binary,Bin54/binary,Bin57/binary,Bin60/binary,Bin63/binary,Bin66/binary,Bin69/binary,Bin72/binary,Bin75/binary,Bin78/binary,Bin81/binary,Bin84/binary,Bin87/binary,Bin90/binary,Bin93/binary,Bin96/binary,Bin99/binary,Bin102/binary,Bin105/binary,Bin108/binary,Bin111/binary,Bin114/binary,Bin117/binary,Bin120/binary,Bin123/binary,Bin126/binary,Bin129/binary,Bin132/binary,Bin135/binary,Bin138/binary,Bin141/binary,Bin144/binary,Bin147/binary
	>>.

binary_read_PetProperty(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int64(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_string(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_int8(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_int8(Count24,Bin0),
	Count27=C27+Count24,
	{D30,C30}=binary_read_int(Count27,Bin0),
	Count30=C30+Count27,
	{D33,C33}=binary_read_int(Count30,Bin0),
	Count33=C33+Count30,
	{D36,C36}=binary_read_int(Count33,Bin0),
	Count36=C36+Count33,
	{D39,C39}=binary_read_int(Count36,Bin0),
	Count39=C39+Count36,
	{D42,C42}=binary_read_int(Count39,Bin0),
	Count42=C42+Count39,
	{D45,C45}=binary_read_int(Count42,Bin0),
	Count45=C45+Count42,
	{D48,C48}=binary_read_int8(Count45,Bin0),
	Count48=C48+Count45,
	{D51,C51}=binary_read_int(Count48,Bin0),
	Count51=C51+Count48,
	{D54,C54}=binary_read_int(Count51,Bin0),
	Count54=C54+Count51,
	{D57,C57}=binary_read_int(Count54,Bin0),
	Count57=C57+Count54,
	{D60,C60}=binary_read_int(Count57,Bin0),
	Count60=C60+Count57,
	{D63,C63}=binary_read_int(Count60,Bin0),
	Count63=C63+Count60,
	{D66,C66}=binary_read_int(Count63,Bin0),
	Count66=C66+Count63,
	{D69,C69}=binary_read_int(Count66,Bin0),
	Count69=C69+Count66,
	{D72,C72}=binary_read_int(Count69,Bin0),
	Count72=C72+Count69,
	{D75,C75}=binary_read_array_head16(Count72,Bin0,fun(X)-> binary_read_PetSkill(X) end),
	Count75=C75+Count72,
	{D78,C78}=binary_read_int(Count75,Bin0),
	Count78=C78+Count75,
	{D81,C81}=binary_read_int(Count78,Bin0),
	Count81=C81+Count78,
	{D84,C84}=binary_read_int(Count81,Bin0),
	Count84=C84+Count81,
	{D87,C87}=binary_read_int(Count84,Bin0),
	Count87=C87+Count84,
	{D90,C90}=binary_read_int(Count87,Bin0),
	Count90=C90+Count87,
	{D93,C93}=binary_read_int(Count90,Bin0),
	Count93=C93+Count90,
	{D96,C96}=binary_read_int(Count93,Bin0),
	Count96=C96+Count93,
	{D99,C99}=binary_read_int(Count96,Bin0),
	Count99=C99+Count96,
	{D102,C102}=binary_read_int(Count99,Bin0),
	Count102=C102+Count99,
	{D105,C105}=binary_read_int(Count102,Bin0),
	Count105=C105+Count102,
	{D108,C108}=binary_read_int(Count105,Bin0),
	Count108=C108+Count105,
	{D111,C111}=binary_read_int(Count108,Bin0),
	Count111=C111+Count108,
	{D114,C114}=binary_read_int(Count111,Bin0),
	Count114=C114+Count111,
	{D117,C117}=binary_read_int(Count114,Bin0),
	Count117=C117+Count114,
	{D120,C120}=binary_read_int(Count117,Bin0),
	Count120=C120+Count117,
	{D123,C123}=binary_read_int(Count120,Bin0),
	Count123=C123+Count120,
	{D126,C126}=binary_read_int(Count123,Bin0),
	Count126=C126+Count123,
	{D129,C129}=binary_read_int(Count126,Bin0),
	Count129=C129+Count126,
	{D132,C132}=binary_read_int(Count129,Bin0),
	Count132=C132+Count129,
	{D135,C135}=binary_read_int(Count132,Bin0),
	Count135=C135+Count132,
	{D138,C138}=binary_read_int(Count135,Bin0),
	Count138=C138+Count135,
	{D141,C141}=binary_read_int(Count138,Bin0),
	Count141=C141+Count138,
	{D144,C144}=binary_read_int(Count141,Bin0),
	Count144=C144+Count141,
	{D147,C147}=binary_read_int(Count144,Bin0),
	Count147=C147+Count144,
	{D150,C150}=binary_read_int(Count147,Bin0),
	Count150=C150+Count147,
	{_,Left} = split_binary(Bin0,Count150),
	{#pk_PetProperty{
		db_id=D3,
		data_id=D6,
		master_id=D9,
		level=D12,
		exp=D15,
		name=D18,
		titleId=D21,
		aiState=D24,
		showModel=D27,
		exModelId=D30,
		soulLevel=D33,
		soulRate=D36,
		attackGrowUp=D39,
		defGrowUp=D42,
		lifeGrowUp=D45,
		isWashGrow=D48,
		attackGrowUpWash=D51,
		defGrowUpWash=D54,
		lifeGrowUpWash=D57,
		convertRatio=D60,
		exerciseLevel=D63,
		moneyExrciseNum=D66,
		exerciseExp=D69,
		maxSkillNum=D72,
		skills=D75,
		life=D78,
		maxLife=D81,
		attack=D84,
		def=D87,
		crit=D90,
		block=D93,
		hit=D96,
		dodge=D99,
		tough=D102,
		pierce=D105,
		crit_damage_rate=D108,
		attack_speed=D111,
		ph_def=D114,
		fire_def=D117,
		ice_def=D120,
		elec_def=D123,
		poison_def=D126,
		coma_def=D129,
		hold_def=D132,
		silent_def=D135,
		move_def=D138,
		atkPowerGrowUp_Max=D141,
		defClassGrowUp_Max=D144,
		hpGrowUp_Max=D147,
		benison_Value=D150
	},
	Left,
	Count150
	}.

write_PlayerPetInfo(#pk_PlayerPetInfo{}=P) -> 
	Bin0=write_array(P#pk_PlayerPetInfo.petSkillBag,fun(X)-> write_int(X) end),
	Bin3=write_array(P#pk_PlayerPetInfo.petInfos,fun(X)-> write_PetProperty(X) end),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PlayerPetInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_int(X) end),
	Count3=C3+Count0,
	{D6,C6}=binary_read_array_head16(Count3,Bin0,fun(X)-> binary_read_PetProperty(X) end),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PlayerPetInfo{
		petSkillBag=D3,
		petInfos=D6
	},
	Left,
	Count6
	}.

write_UpdatePetProerty(#pk_UpdatePetProerty{}=P) -> 
	Bin0=write_PetProperty(P#pk_UpdatePetProerty.petInfo),
	<<Bin0/binary
	>>.

binary_read_UpdatePetProerty(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_PetProperty(Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_UpdatePetProerty{
		petInfo=D3
	},
	Left,
	Count3
	}.

write_DelPet(#pk_DelPet{}=P) -> 
	Bin0=write_int64(P#pk_DelPet.petId),
	<<Bin0/binary
	>>.

binary_read_DelPet(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_DelPet{
		petId=D3
	},
	Left,
	Count3
	}.

write_PetOutFight(#pk_PetOutFight{}=P) -> 
	Bin0=write_int64(P#pk_PetOutFight.petId),
	<<Bin0/binary
	>>.

binary_read_PetOutFight(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PetOutFight{
		petId=D3
	},
	Left,
	Count3
	}.

write_PetOutFight_Result(#pk_PetOutFight_Result{}=P) -> 
	Bin0=write_int8(P#pk_PetOutFight_Result.result),
	Bin3=write_int64(P#pk_PetOutFight_Result.petId),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PetOutFight_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PetOutFight_Result{
		result=D3,
		petId=D6
	},
	Left,
	Count6
	}.

write_PetTakeRest(#pk_PetTakeRest{}=P) -> 
	Bin0=write_int64(P#pk_PetTakeRest.petId),
	<<Bin0/binary
	>>.

binary_read_PetTakeRest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PetTakeRest{
		petId=D3
	},
	Left,
	Count3
	}.

write_PetTakeRest_Result(#pk_PetTakeRest_Result{}=P) -> 
	Bin0=write_int8(P#pk_PetTakeRest_Result.result),
	Bin3=write_int64(P#pk_PetTakeRest_Result.petId),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PetTakeRest_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PetTakeRest_Result{
		result=D3,
		petId=D6
	},
	Left,
	Count6
	}.

write_PetFreeCaptiveAnimals(#pk_PetFreeCaptiveAnimals{}=P) -> 
	Bin0=write_int64(P#pk_PetFreeCaptiveAnimals.petId),
	<<Bin0/binary
	>>.

binary_read_PetFreeCaptiveAnimals(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PetFreeCaptiveAnimals{
		petId=D3
	},
	Left,
	Count3
	}.

write_PetFreeCaptiveAnimals_Result(#pk_PetFreeCaptiveAnimals_Result{}=P) -> 
	Bin0=write_int8(P#pk_PetFreeCaptiveAnimals_Result.result),
	Bin3=write_int64(P#pk_PetFreeCaptiveAnimals_Result.petId),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PetFreeCaptiveAnimals_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PetFreeCaptiveAnimals_Result{
		result=D3,
		petId=D6
	},
	Left,
	Count6
	}.

write_PetCompoundModel(#pk_PetCompoundModel{}=P) -> 
	Bin0=write_int64(P#pk_PetCompoundModel.petId),
	<<Bin0/binary
	>>.

binary_read_PetCompoundModel(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PetCompoundModel{
		petId=D3
	},
	Left,
	Count3
	}.

write_PetCompoundModel_Result(#pk_PetCompoundModel_Result{}=P) -> 
	Bin0=write_int8(P#pk_PetCompoundModel_Result.result),
	Bin3=write_int64(P#pk_PetCompoundModel_Result.petId),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PetCompoundModel_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PetCompoundModel_Result{
		result=D3,
		petId=D6
	},
	Left,
	Count6
	}.

write_PetWashGrowUpValue(#pk_PetWashGrowUpValue{}=P) -> 
	Bin0=write_int64(P#pk_PetWashGrowUpValue.petId),
	<<Bin0/binary
	>>.

binary_read_PetWashGrowUpValue(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PetWashGrowUpValue{
		petId=D3
	},
	Left,
	Count3
	}.

write_PetWashGrowUpValue_Result(#pk_PetWashGrowUpValue_Result{}=P) -> 
	Bin0=write_int8(P#pk_PetWashGrowUpValue_Result.result),
	Bin3=write_int64(P#pk_PetWashGrowUpValue_Result.petId),
	Bin6=write_int(P#pk_PetWashGrowUpValue_Result.attackGrowUp),
	Bin9=write_int(P#pk_PetWashGrowUpValue_Result.defGrowUp),
	Bin12=write_int(P#pk_PetWashGrowUpValue_Result.lifeGrowUp),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary
	>>.

binary_read_PetWashGrowUpValue_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{_,Left} = split_binary(Bin0,Count15),
	{#pk_PetWashGrowUpValue_Result{
		result=D3,
		petId=D6,
		attackGrowUp=D9,
		defGrowUp=D12,
		lifeGrowUp=D15
	},
	Left,
	Count15
	}.

write_PetReplaceGrowUpValue(#pk_PetReplaceGrowUpValue{}=P) -> 
	Bin0=write_int64(P#pk_PetReplaceGrowUpValue.petId),
	<<Bin0/binary
	>>.

binary_read_PetReplaceGrowUpValue(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PetReplaceGrowUpValue{
		petId=D3
	},
	Left,
	Count3
	}.

write_PetReplaceGrowUpValue_Result(#pk_PetReplaceGrowUpValue_Result{}=P) -> 
	Bin0=write_int8(P#pk_PetReplaceGrowUpValue_Result.result),
	Bin3=write_int64(P#pk_PetReplaceGrowUpValue_Result.petId),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PetReplaceGrowUpValue_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PetReplaceGrowUpValue_Result{
		result=D3,
		petId=D6
	},
	Left,
	Count6
	}.

write_PetIntensifySoul(#pk_PetIntensifySoul{}=P) -> 
	Bin0=write_int64(P#pk_PetIntensifySoul.petId),
	<<Bin0/binary
	>>.

binary_read_PetIntensifySoul(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PetIntensifySoul{
		petId=D3
	},
	Left,
	Count3
	}.

write_PetIntensifySoul_Result(#pk_PetIntensifySoul_Result{}=P) -> 
	Bin0=write_int8(P#pk_PetIntensifySoul_Result.result),
	Bin3=write_int64(P#pk_PetIntensifySoul_Result.petId),
	Bin6=write_int(P#pk_PetIntensifySoul_Result.soulLevel),
	Bin9=write_int(P#pk_PetIntensifySoul_Result.soulRate),
	Bin12=write_int(P#pk_PetIntensifySoul_Result.benison_Value),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary
	>>.

binary_read_PetIntensifySoul_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{_,Left} = split_binary(Bin0,Count15),
	{#pk_PetIntensifySoul_Result{
		result=D3,
		petId=D6,
		soulLevel=D9,
		soulRate=D12,
		benison_Value=D15
	},
	Left,
	Count15
	}.

write_PetOneKeyIntensifySoul(#pk_PetOneKeyIntensifySoul{}=P) -> 
	Bin0=write_int64(P#pk_PetOneKeyIntensifySoul.petId),
	<<Bin0/binary
	>>.

binary_read_PetOneKeyIntensifySoul(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PetOneKeyIntensifySoul{
		petId=D3
	},
	Left,
	Count3
	}.

write_PetOneKeyIntensifySoul_Result(#pk_PetOneKeyIntensifySoul_Result{}=P) -> 
	Bin0=write_int64(P#pk_PetOneKeyIntensifySoul_Result.petId),
	Bin3=write_int8(P#pk_PetOneKeyIntensifySoul_Result.result),
	Bin6=write_int(P#pk_PetOneKeyIntensifySoul_Result.itemCount),
	Bin9=write_int(P#pk_PetOneKeyIntensifySoul_Result.money),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_PetOneKeyIntensifySoul_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_PetOneKeyIntensifySoul_Result{
		petId=D3,
		result=D6,
		itemCount=D9,
		money=D12
	},
	Left,
	Count12
	}.

write_PetFuse(#pk_PetFuse{}=P) -> 
	Bin0=write_int64(P#pk_PetFuse.petSrcId),
	Bin3=write_int64(P#pk_PetFuse.petDestId),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PetFuse(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PetFuse{
		petSrcId=D3,
		petDestId=D6
	},
	Left,
	Count6
	}.

write_PetFuse_Result(#pk_PetFuse_Result{}=P) -> 
	Bin0=write_int8(P#pk_PetFuse_Result.result),
	Bin3=write_int64(P#pk_PetFuse_Result.petSrcId),
	Bin6=write_int64(P#pk_PetFuse_Result.petDestId),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PetFuse_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int64(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PetFuse_Result{
		result=D3,
		petSrcId=D6,
		petDestId=D9
	},
	Left,
	Count9
	}.

write_PetJumpTo(#pk_PetJumpTo{}=P) -> 
	Bin0=write_int64(P#pk_PetJumpTo.petId),
	Bin3=write_int(P#pk_PetJumpTo.x),
	Bin6=write_int(P#pk_PetJumpTo.y),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PetJumpTo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PetJumpTo{
		petId=D3,
		x=D6,
		y=D9
	},
	Left,
	Count9
	}.

write_ActorSetPos(#pk_ActorSetPos{}=P) -> 
	Bin0=write_int64(P#pk_ActorSetPos.actorId),
	Bin3=write_int(P#pk_ActorSetPos.x),
	Bin6=write_int(P#pk_ActorSetPos.y),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_ActorSetPos(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_ActorSetPos{
		actorId=D3,
		x=D6,
		y=D9
	},
	Left,
	Count9
	}.

write_PetTakeBack(#pk_PetTakeBack{}=P) -> 
	Bin0=write_int64(P#pk_PetTakeBack.petId),
	<<Bin0/binary
	>>.

binary_read_PetTakeBack(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PetTakeBack{
		petId=D3
	},
	Left,
	Count3
	}.

write_ChangePetAIState(#pk_ChangePetAIState{}=P) -> 
	Bin0=write_int8(P#pk_ChangePetAIState.state),
	<<Bin0/binary
	>>.

binary_read_ChangePetAIState(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_ChangePetAIState{
		state=D3
	},
	Left,
	Count3
	}.

write_PetExpChanged(#pk_PetExpChanged{}=P) -> 
	Bin0=write_int64(P#pk_PetExpChanged.petId),
	Bin3=write_int(P#pk_PetExpChanged.curExp),
	Bin6=write_int8(P#pk_PetExpChanged.reason),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PetExpChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PetExpChanged{
		petId=D3,
		curExp=D6,
		reason=D9
	},
	Left,
	Count9
	}.

write_PetLearnSkill(#pk_PetLearnSkill{}=P) -> 
	Bin0=write_int64(P#pk_PetLearnSkill.petId),
	Bin3=write_int(P#pk_PetLearnSkill.skillId),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PetLearnSkill(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PetLearnSkill{
		petId=D3,
		skillId=D6
	},
	Left,
	Count6
	}.

write_PetLearnSkill_Result(#pk_PetLearnSkill_Result{}=P) -> 
	Bin0=write_int8(P#pk_PetLearnSkill_Result.result),
	Bin3=write_int64(P#pk_PetLearnSkill_Result.petId),
	Bin6=write_int(P#pk_PetLearnSkill_Result.oldSkillId),
	Bin9=write_int(P#pk_PetLearnSkill_Result.newSkillId),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_PetLearnSkill_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_PetLearnSkill_Result{
		result=D3,
		petId=D6,
		oldSkillId=D9,
		newSkillId=D12
	},
	Left,
	Count12
	}.

write_PetDelSkill(#pk_PetDelSkill{}=P) -> 
	Bin0=write_int64(P#pk_PetDelSkill.petId),
	Bin3=write_int(P#pk_PetDelSkill.skillId),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PetDelSkill(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PetDelSkill{
		petId=D3,
		skillId=D6
	},
	Left,
	Count6
	}.

write_PetDelSkill_Result(#pk_PetDelSkill_Result{}=P) -> 
	Bin0=write_int8(P#pk_PetDelSkill_Result.result),
	Bin3=write_int64(P#pk_PetDelSkill_Result.petId),
	Bin6=write_int(P#pk_PetDelSkill_Result.skillid),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PetDelSkill_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PetDelSkill_Result{
		result=D3,
		petId=D6,
		skillid=D9
	},
	Left,
	Count9
	}.

write_PetUnLockSkillCell(#pk_PetUnLockSkillCell{}=P) -> 
	Bin0=write_int64(P#pk_PetUnLockSkillCell.petId),
	<<Bin0/binary
	>>.

binary_read_PetUnLockSkillCell(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PetUnLockSkillCell{
		petId=D3
	},
	Left,
	Count3
	}.

write_PetUnLoctSkillCell_Result(#pk_PetUnLoctSkillCell_Result{}=P) -> 
	Bin0=write_int8(P#pk_PetUnLoctSkillCell_Result.result),
	Bin3=write_int64(P#pk_PetUnLoctSkillCell_Result.petId),
	Bin6=write_int(P#pk_PetUnLoctSkillCell_Result.newSkillCellNum),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PetUnLoctSkillCell_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PetUnLoctSkillCell_Result{
		result=D3,
		petId=D6,
		newSkillCellNum=D9
	},
	Left,
	Count9
	}.

write_PetSkillSealAhs(#pk_PetSkillSealAhs{}=P) -> 
	Bin0=write_int64(P#pk_PetSkillSealAhs.petId),
	Bin3=write_int(P#pk_PetSkillSealAhs.skillid),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PetSkillSealAhs(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PetSkillSealAhs{
		petId=D3,
		skillid=D6
	},
	Left,
	Count6
	}.

write_PetSkillSealAhs_Result(#pk_PetSkillSealAhs_Result{}=P) -> 
	Bin0=write_int8(P#pk_PetSkillSealAhs_Result.result),
	Bin3=write_int64(P#pk_PetSkillSealAhs_Result.petId),
	Bin6=write_int(P#pk_PetSkillSealAhs_Result.skillid),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PetSkillSealAhs_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PetSkillSealAhs_Result{
		result=D3,
		petId=D6,
		skillid=D9
	},
	Left,
	Count9
	}.

write_PetUpdateSealAhsStore(#pk_PetUpdateSealAhsStore{}=P) -> 
	Bin0=write_array(P#pk_PetUpdateSealAhsStore.petSkillBag,fun(X)-> write_int(X) end),
	<<Bin0/binary
	>>.

binary_read_PetUpdateSealAhsStore(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_int(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PetUpdateSealAhsStore{
		petSkillBag=D3
	},
	Left,
	Count3
	}.

write_PetlearnSealAhsSkill(#pk_PetlearnSealAhsSkill{}=P) -> 
	Bin0=write_int64(P#pk_PetlearnSealAhsSkill.petId),
	Bin3=write_int(P#pk_PetlearnSealAhsSkill.skillId),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PetlearnSealAhsSkill(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PetlearnSealAhsSkill{
		petId=D3,
		skillId=D6
	},
	Left,
	Count6
	}.

write_PetlearnSealAhsSkill_Result(#pk_PetlearnSealAhsSkill_Result{}=P) -> 
	Bin0=write_int8(P#pk_PetlearnSealAhsSkill_Result.result),
	Bin3=write_int64(P#pk_PetlearnSealAhsSkill_Result.petId),
	Bin6=write_int(P#pk_PetlearnSealAhsSkill_Result.oldSkillId),
	Bin9=write_int(P#pk_PetlearnSealAhsSkill_Result.newSkillId),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_PetlearnSealAhsSkill_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_PetlearnSealAhsSkill_Result{
		result=D3,
		petId=D6,
		oldSkillId=D9,
		newSkillId=D12
	},
	Left,
	Count12
	}.

write_RequestGetPlayerEquipEnhanceByType(#pk_RequestGetPlayerEquipEnhanceByType{}=P) -> 
	Bin0=write_int(P#pk_RequestGetPlayerEquipEnhanceByType.type),
	<<Bin0/binary
	>>.

binary_read_RequestGetPlayerEquipEnhanceByType(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestGetPlayerEquipEnhanceByType{
		type=D3
	},
	Left,
	Count3
	}.

write_GetPlayerEquipEnhanceByTypeBack(#pk_GetPlayerEquipEnhanceByTypeBack{}=P) -> 
	Bin0=write_int(P#pk_GetPlayerEquipEnhanceByTypeBack.type),
	Bin3=write_int(P#pk_GetPlayerEquipEnhanceByTypeBack.level),
	Bin6=write_int(P#pk_GetPlayerEquipEnhanceByTypeBack.progress),
	Bin9=write_int(P#pk_GetPlayerEquipEnhanceByTypeBack.blessValue),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_GetPlayerEquipEnhanceByTypeBack(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_GetPlayerEquipEnhanceByTypeBack{
		type=D3,
		level=D6,
		progress=D9,
		blessValue=D12
	},
	Left,
	Count12
	}.

write_RequestEquipEnhanceByType(#pk_RequestEquipEnhanceByType{}=P) -> 
	Bin0=write_int(P#pk_RequestEquipEnhanceByType.type),
	<<Bin0/binary
	>>.

binary_read_RequestEquipEnhanceByType(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestEquipEnhanceByType{
		type=D3
	},
	Left,
	Count3
	}.

write_EquipEnhanceByTypeBack(#pk_EquipEnhanceByTypeBack{}=P) -> 
	Bin0=write_int(P#pk_EquipEnhanceByTypeBack.result),
	<<Bin0/binary
	>>.

binary_read_EquipEnhanceByTypeBack(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_EquipEnhanceByTypeBack{
		result=D3
	},
	Left,
	Count3
	}.

write_RequestEquipOnceEnhanceByType(#pk_RequestEquipOnceEnhanceByType{}=P) -> 
	Bin0=write_int(P#pk_RequestEquipOnceEnhanceByType.type),
	<<Bin0/binary
	>>.

binary_read_RequestEquipOnceEnhanceByType(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestEquipOnceEnhanceByType{
		type=D3
	},
	Left,
	Count3
	}.

write_EquipOnceEnhanceByTypeBack(#pk_EquipOnceEnhanceByTypeBack{}=P) -> 
	Bin0=write_int(P#pk_EquipOnceEnhanceByTypeBack.result),
	Bin3=write_int(P#pk_EquipOnceEnhanceByTypeBack.times),
	Bin6=write_int(P#pk_EquipOnceEnhanceByTypeBack.itemnumber),
	Bin9=write_int(P#pk_EquipOnceEnhanceByTypeBack.money),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_EquipOnceEnhanceByTypeBack(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_EquipOnceEnhanceByTypeBack{
		result=D3,
		times=D6,
		itemnumber=D9,
		money=D12
	},
	Left,
	Count12
	}.

write_RequestGetPlayerEquipQualityByType(#pk_RequestGetPlayerEquipQualityByType{}=P) -> 
	Bin0=write_int(P#pk_RequestGetPlayerEquipQualityByType.type),
	<<Bin0/binary
	>>.

binary_read_RequestGetPlayerEquipQualityByType(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestGetPlayerEquipQualityByType{
		type=D3
	},
	Left,
	Count3
	}.

write_GetPlayerEquipQualityByTypeBack(#pk_GetPlayerEquipQualityByTypeBack{}=P) -> 
	Bin0=write_int(P#pk_GetPlayerEquipQualityByTypeBack.type),
	Bin3=write_int(P#pk_GetPlayerEquipQualityByTypeBack.quality),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GetPlayerEquipQualityByTypeBack(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GetPlayerEquipQualityByTypeBack{
		type=D3,
		quality=D6
	},
	Left,
	Count6
	}.

write_RequestEquipQualityUPByType(#pk_RequestEquipQualityUPByType{}=P) -> 
	Bin0=write_int(P#pk_RequestEquipQualityUPByType.type),
	<<Bin0/binary
	>>.

binary_read_RequestEquipQualityUPByType(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestEquipQualityUPByType{
		type=D3
	},
	Left,
	Count3
	}.

write_EquipQualityUPByTypeBack(#pk_EquipQualityUPByTypeBack{}=P) -> 
	Bin0=write_int(P#pk_EquipQualityUPByTypeBack.result),
	<<Bin0/binary
	>>.

binary_read_EquipQualityUPByTypeBack(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_EquipQualityUPByTypeBack{
		result=D3
	},
	Left,
	Count3
	}.

write_RequestEquipOldPropertyByType(#pk_RequestEquipOldPropertyByType{}=P) -> 
	Bin0=write_int(P#pk_RequestEquipOldPropertyByType.type),
	<<Bin0/binary
	>>.

binary_read_RequestEquipOldPropertyByType(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestEquipOldPropertyByType{
		type=D3
	},
	Left,
	Count3
	}.

write_GetEquipOldPropertyByType(#pk_GetEquipOldPropertyByType{}=P) -> 
	Bin0=write_int(P#pk_GetEquipOldPropertyByType.type),
	Bin3=write_int8(P#pk_GetEquipOldPropertyByType.property1Type),
	Bin6=write_int8(P#pk_GetEquipOldPropertyByType.property1FixOrPercent),
	Bin9=write_int(P#pk_GetEquipOldPropertyByType.property1Value),
	Bin12=write_int8(P#pk_GetEquipOldPropertyByType.property2Type),
	Bin15=write_int8(P#pk_GetEquipOldPropertyByType.property2FixOrPercent),
	Bin18=write_int(P#pk_GetEquipOldPropertyByType.property2Value),
	Bin21=write_int8(P#pk_GetEquipOldPropertyByType.property3Type),
	Bin24=write_int8(P#pk_GetEquipOldPropertyByType.property3FixOrPercent),
	Bin27=write_int(P#pk_GetEquipOldPropertyByType.property3Value),
	Bin30=write_int8(P#pk_GetEquipOldPropertyByType.property4Type),
	Bin33=write_int8(P#pk_GetEquipOldPropertyByType.property4FixOrPercent),
	Bin36=write_int(P#pk_GetEquipOldPropertyByType.property4Value),
	Bin39=write_int8(P#pk_GetEquipOldPropertyByType.property5Type),
	Bin42=write_int8(P#pk_GetEquipOldPropertyByType.property5FixOrPercent),
	Bin45=write_int(P#pk_GetEquipOldPropertyByType.property5Value),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary,Bin33/binary,Bin36/binary,Bin39/binary,Bin42/binary,Bin45/binary
	>>.

binary_read_GetEquipOldPropertyByType(Bin0)->
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
	{D21,C21}=binary_read_int(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_int8(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_int8(Count24,Bin0),
	Count27=C27+Count24,
	{D30,C30}=binary_read_int(Count27,Bin0),
	Count30=C30+Count27,
	{D33,C33}=binary_read_int8(Count30,Bin0),
	Count33=C33+Count30,
	{D36,C36}=binary_read_int8(Count33,Bin0),
	Count36=C36+Count33,
	{D39,C39}=binary_read_int(Count36,Bin0),
	Count39=C39+Count36,
	{D42,C42}=binary_read_int8(Count39,Bin0),
	Count42=C42+Count39,
	{D45,C45}=binary_read_int8(Count42,Bin0),
	Count45=C45+Count42,
	{D48,C48}=binary_read_int(Count45,Bin0),
	Count48=C48+Count45,
	{_,Left} = split_binary(Bin0,Count48),
	{#pk_GetEquipOldPropertyByType{
		type=D3,
		property1Type=D6,
		property1FixOrPercent=D9,
		property1Value=D12,
		property2Type=D15,
		property2FixOrPercent=D18,
		property2Value=D21,
		property3Type=D24,
		property3FixOrPercent=D27,
		property3Value=D30,
		property4Type=D33,
		property4FixOrPercent=D36,
		property4Value=D39,
		property5Type=D42,
		property5FixOrPercent=D45,
		property5Value=D48
	},
	Left,
	Count48
	}.

write_RequestEquipChangePropertyByType(#pk_RequestEquipChangePropertyByType{}=P) -> 
	Bin0=write_int(P#pk_RequestEquipChangePropertyByType.type),
	Bin3=write_int8(P#pk_RequestEquipChangePropertyByType.property1),
	Bin6=write_int8(P#pk_RequestEquipChangePropertyByType.property2),
	Bin9=write_int8(P#pk_RequestEquipChangePropertyByType.property3),
	Bin12=write_int8(P#pk_RequestEquipChangePropertyByType.property4),
	Bin15=write_int8(P#pk_RequestEquipChangePropertyByType.property5),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary
	>>.

binary_read_RequestEquipChangePropertyByType(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int8(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int8(Count15,Bin0),
	Count18=C18+Count15,
	{_,Left} = split_binary(Bin0,Count18),
	{#pk_RequestEquipChangePropertyByType{
		type=D3,
		property1=D6,
		property2=D9,
		property3=D12,
		property4=D15,
		property5=D18
	},
	Left,
	Count18
	}.

write_GetEquipNewPropertyByType(#pk_GetEquipNewPropertyByType{}=P) -> 
	Bin0=write_int(P#pk_GetEquipNewPropertyByType.type),
	Bin3=write_int8(P#pk_GetEquipNewPropertyByType.property1Type),
	Bin6=write_int8(P#pk_GetEquipNewPropertyByType.property1FixOrPercent),
	Bin9=write_int(P#pk_GetEquipNewPropertyByType.property1Value),
	Bin12=write_int8(P#pk_GetEquipNewPropertyByType.property2Type),
	Bin15=write_int8(P#pk_GetEquipNewPropertyByType.property2FixOrPercent),
	Bin18=write_int(P#pk_GetEquipNewPropertyByType.property2Value),
	Bin21=write_int8(P#pk_GetEquipNewPropertyByType.property3Type),
	Bin24=write_int8(P#pk_GetEquipNewPropertyByType.property3FixOrPercent),
	Bin27=write_int(P#pk_GetEquipNewPropertyByType.property3Value),
	Bin30=write_int8(P#pk_GetEquipNewPropertyByType.property4Type),
	Bin33=write_int8(P#pk_GetEquipNewPropertyByType.property4FixOrPercent),
	Bin36=write_int(P#pk_GetEquipNewPropertyByType.property4Value),
	Bin39=write_int8(P#pk_GetEquipNewPropertyByType.property5Type),
	Bin42=write_int8(P#pk_GetEquipNewPropertyByType.property5FixOrPercent),
	Bin45=write_int(P#pk_GetEquipNewPropertyByType.property5Value),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary,Bin33/binary,Bin36/binary,Bin39/binary,Bin42/binary,Bin45/binary
	>>.

binary_read_GetEquipNewPropertyByType(Bin0)->
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
	{D21,C21}=binary_read_int(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_int8(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_int8(Count24,Bin0),
	Count27=C27+Count24,
	{D30,C30}=binary_read_int(Count27,Bin0),
	Count30=C30+Count27,
	{D33,C33}=binary_read_int8(Count30,Bin0),
	Count33=C33+Count30,
	{D36,C36}=binary_read_int8(Count33,Bin0),
	Count36=C36+Count33,
	{D39,C39}=binary_read_int(Count36,Bin0),
	Count39=C39+Count36,
	{D42,C42}=binary_read_int8(Count39,Bin0),
	Count42=C42+Count39,
	{D45,C45}=binary_read_int8(Count42,Bin0),
	Count45=C45+Count42,
	{D48,C48}=binary_read_int(Count45,Bin0),
	Count48=C48+Count45,
	{_,Left} = split_binary(Bin0,Count48),
	{#pk_GetEquipNewPropertyByType{
		type=D3,
		property1Type=D6,
		property1FixOrPercent=D9,
		property1Value=D12,
		property2Type=D15,
		property2FixOrPercent=D18,
		property2Value=D21,
		property3Type=D24,
		property3FixOrPercent=D27,
		property3Value=D30,
		property4Type=D33,
		property4FixOrPercent=D36,
		property4Value=D39,
		property5Type=D42,
		property5FixOrPercent=D45,
		property5Value=D48
	},
	Left,
	Count48
	}.

write_RequestEquipSaveNewPropertyByType(#pk_RequestEquipSaveNewPropertyByType{}=P) -> 
	Bin0=write_int(P#pk_RequestEquipSaveNewPropertyByType.type),
	<<Bin0/binary
	>>.

binary_read_RequestEquipSaveNewPropertyByType(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestEquipSaveNewPropertyByType{
		type=D3
	},
	Left,
	Count3
	}.

write_RequestEquipChangeAddSavePropertyByType(#pk_RequestEquipChangeAddSavePropertyByType{}=P) -> 
	Bin0=write_int(P#pk_RequestEquipChangeAddSavePropertyByType.result),
	<<Bin0/binary
	>>.

binary_read_RequestEquipChangeAddSavePropertyByType(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestEquipChangeAddSavePropertyByType{
		result=D3
	},
	Left,
	Count3
	}.

write_U2GS_EnterCopyMapRequest(#pk_U2GS_EnterCopyMapRequest{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_EnterCopyMapRequest.npcActorID),
	Bin3=write_int(P#pk_U2GS_EnterCopyMapRequest.enterMapID),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_U2GS_EnterCopyMapRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_U2GS_EnterCopyMapRequest{
		npcActorID=D3,
		enterMapID=D6
	},
	Left,
	Count6
	}.

write_GS2U_EnterMapResult(#pk_GS2U_EnterMapResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_EnterMapResult.result),
	<<Bin0/binary
	>>.

binary_read_GS2U_EnterMapResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_EnterMapResult{
		result=D3
	},
	Left,
	Count3
	}.

write_U2GS_QueryMyCopyMapCD(#pk_U2GS_QueryMyCopyMapCD{}=P) -> 
	Bin0=write_int(P#pk_U2GS_QueryMyCopyMapCD.reserve),
	<<Bin0/binary
	>>.

binary_read_U2GS_QueryMyCopyMapCD(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_QueryMyCopyMapCD{
		reserve=D3
	},
	Left,
	Count3
	}.

write_MyCopyMapCDInfo(#pk_MyCopyMapCDInfo{}=P) -> 
	Bin0=write_int16(P#pk_MyCopyMapCDInfo.mapDataID),
	Bin3=write_int8(P#pk_MyCopyMapCDInfo.mapEnteredCount),
	Bin6=write_int8(P#pk_MyCopyMapCDInfo.mapActiveCount),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_MyCopyMapCDInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_MyCopyMapCDInfo{
		mapDataID=D3,
		mapEnteredCount=D6,
		mapActiveCount=D9
	},
	Left,
	Count9
	}.

write_GS2U_MyCopyMapCDInfo(#pk_GS2U_MyCopyMapCDInfo{}=P) -> 
	Bin0=write_array(P#pk_GS2U_MyCopyMapCDInfo.info_list,fun(X)-> write_MyCopyMapCDInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_MyCopyMapCDInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_MyCopyMapCDInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_MyCopyMapCDInfo{
		info_list=D3
	},
	Left,
	Count3
	}.

write_AddBuff(#pk_AddBuff{}=P) -> 
	Bin0=write_int64(P#pk_AddBuff.actor_id),
	Bin3=write_int16(P#pk_AddBuff.buff_data_id),
	Bin6=write_int16(P#pk_AddBuff.allValidTime),
	Bin9=write_int8(P#pk_AddBuff.remainTriggerCount),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_AddBuff(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_AddBuff{
		actor_id=D3,
		buff_data_id=D6,
		allValidTime=D9,
		remainTriggerCount=D12
	},
	Left,
	Count12
	}.

write_DelBuff(#pk_DelBuff{}=P) -> 
	Bin0=write_int64(P#pk_DelBuff.actor_id),
	Bin3=write_int16(P#pk_DelBuff.buff_data_id),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_DelBuff(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_DelBuff{
		actor_id=D3,
		buff_data_id=D6
	},
	Left,
	Count6
	}.

write_UpdateBuff(#pk_UpdateBuff{}=P) -> 
	Bin0=write_int64(P#pk_UpdateBuff.actor_id),
	Bin3=write_int16(P#pk_UpdateBuff.buff_data_id),
	Bin6=write_int8(P#pk_UpdateBuff.remainTriggerCount),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_UpdateBuff(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_UpdateBuff{
		actor_id=D3,
		buff_data_id=D6,
		remainTriggerCount=D9
	},
	Left,
	Count9
	}.

write_HeroBuffList(#pk_HeroBuffList{}=P) -> 
	Bin0=write_array(P#pk_HeroBuffList.buffList,fun(X)-> write_ObjectBuff(X) end),
	<<Bin0/binary
	>>.

binary_read_HeroBuffList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_ObjectBuff(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_HeroBuffList{
		buffList=D3
	},
	Left,
	Count3
	}.

write_U2GS_TransByWorldMap(#pk_U2GS_TransByWorldMap{}=P) -> 
	Bin0=write_int(P#pk_U2GS_TransByWorldMap.mapDataID),
	Bin3=write_int(P#pk_U2GS_TransByWorldMap.posX),
	Bin6=write_int(P#pk_U2GS_TransByWorldMap.posY),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_U2GS_TransByWorldMap(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_U2GS_TransByWorldMap{
		mapDataID=D3,
		posX=D6,
		posY=D9
	},
	Left,
	Count9
	}.

write_U2GS_TransForSameScence(#pk_U2GS_TransForSameScence{}=P) -> 
	Bin0=write_int(P#pk_U2GS_TransForSameScence.mapDataID),
	Bin3=write_int(P#pk_U2GS_TransForSameScence.posX),
	Bin6=write_int(P#pk_U2GS_TransForSameScence.posY),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_U2GS_TransForSameScence(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_U2GS_TransForSameScence{
		mapDataID=D3,
		posX=D6,
		posY=D9
	},
	Left,
	Count9
	}.

write_U2GS_FastTeamCopyMapRequest(#pk_U2GS_FastTeamCopyMapRequest{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_FastTeamCopyMapRequest.npcActorID),
	Bin3=write_int(P#pk_U2GS_FastTeamCopyMapRequest.mapDataID),
	Bin6=write_int8(P#pk_U2GS_FastTeamCopyMapRequest.enterOrQuit),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_U2GS_FastTeamCopyMapRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_U2GS_FastTeamCopyMapRequest{
		npcActorID=D3,
		mapDataID=D6,
		enterOrQuit=D9
	},
	Left,
	Count9
	}.

write_GS2U_FastTeamCopyMapResult(#pk_GS2U_FastTeamCopyMapResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_FastTeamCopyMapResult.mapDataID),
	Bin3=write_int(P#pk_GS2U_FastTeamCopyMapResult.result),
	Bin6=write_int8(P#pk_GS2U_FastTeamCopyMapResult.enterOrQuit),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_GS2U_FastTeamCopyMapResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_GS2U_FastTeamCopyMapResult{
		mapDataID=D3,
		result=D6,
		enterOrQuit=D9
	},
	Left,
	Count9
	}.

write_GS2U_TeamCopyMapQuery(#pk_GS2U_TeamCopyMapQuery{}=P) -> 
	Bin0=write_int(P#pk_GS2U_TeamCopyMapQuery.nReadyEnterMapDataID),
	Bin3=write_int(P#pk_GS2U_TeamCopyMapQuery.nCurMapID),
	Bin6=write_int(P#pk_GS2U_TeamCopyMapQuery.nPosX),
	Bin9=write_int(P#pk_GS2U_TeamCopyMapQuery.nPosY),
	Bin12=write_int(P#pk_GS2U_TeamCopyMapQuery.nDistanceSQ),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary
	>>.

binary_read_GS2U_TeamCopyMapQuery(Bin0)->
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
	{_,Left} = split_binary(Bin0,Count15),
	{#pk_GS2U_TeamCopyMapQuery{
		nReadyEnterMapDataID=D3,
		nCurMapID=D6,
		nPosX=D9,
		nPosY=D12,
		nDistanceSQ=D15
	},
	Left,
	Count15
	}.

write_U2GS_RestCopyMapRequest(#pk_U2GS_RestCopyMapRequest{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_RestCopyMapRequest.nNpcID),
	Bin3=write_int(P#pk_U2GS_RestCopyMapRequest.nMapDataID),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_U2GS_RestCopyMapRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_U2GS_RestCopyMapRequest{
		nNpcID=D3,
		nMapDataID=D6
	},
	Left,
	Count6
	}.

write_GS2U_AddOrRemoveHatred(#pk_GS2U_AddOrRemoveHatred{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_AddOrRemoveHatred.nActorID),
	Bin3=write_int8(P#pk_GS2U_AddOrRemoveHatred.nAddOrRemove),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_AddOrRemoveHatred(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_AddOrRemoveHatred{
		nActorID=D3,
		nAddOrRemove=D6
	},
	Left,
	Count6
	}.

write_U2GS_QieCuoInvite(#pk_U2GS_QieCuoInvite{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_QieCuoInvite.nActorID),
	<<Bin0/binary
	>>.

binary_read_U2GS_QieCuoInvite(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_QieCuoInvite{
		nActorID=D3
	},
	Left,
	Count3
	}.

write_GS2U_QieCuoInviteQuery(#pk_GS2U_QieCuoInviteQuery{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_QieCuoInviteQuery.nActorID),
	Bin3=write_string(P#pk_GS2U_QieCuoInviteQuery.strName),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_QieCuoInviteQuery(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_QieCuoInviteQuery{
		nActorID=D3,
		strName=D6
	},
	Left,
	Count6
	}.

write_U2GS_QieCuoInviteAck(#pk_U2GS_QieCuoInviteAck{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_QieCuoInviteAck.nActorID),
	Bin3=write_int8(P#pk_U2GS_QieCuoInviteAck.agree),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_U2GS_QieCuoInviteAck(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_U2GS_QieCuoInviteAck{
		nActorID=D3,
		agree=D6
	},
	Left,
	Count6
	}.

write_GS2U_QieCuoInviteResult(#pk_GS2U_QieCuoInviteResult{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_QieCuoInviteResult.nActorID),
	Bin3=write_int8(P#pk_GS2U_QieCuoInviteResult.result),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_QieCuoInviteResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_QieCuoInviteResult{
		nActorID=D3,
		result=D6
	},
	Left,
	Count6
	}.

write_GS2U_QieCuoResult(#pk_GS2U_QieCuoResult{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_QieCuoResult.nWinner_ActorID),
	Bin3=write_string(P#pk_GS2U_QieCuoResult.strWinner_Name),
	Bin6=write_int64(P#pk_GS2U_QieCuoResult.nLoser_ActorID),
	Bin9=write_string(P#pk_GS2U_QieCuoResult.strLoser_Name),
	Bin12=write_int8(P#pk_GS2U_QieCuoResult.reson),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary
	>>.

binary_read_GS2U_QieCuoResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int64(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_string(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int8(Count12,Bin0),
	Count15=C15+Count12,
	{_,Left} = split_binary(Bin0,Count15),
	{#pk_GS2U_QieCuoResult{
		nWinner_ActorID=D3,
		strWinner_Name=D6,
		nLoser_ActorID=D9,
		strLoser_Name=D12,
		reson=D15
	},
	Left,
	Count15
	}.

write_U2GS_PK_KillOpenRequest(#pk_U2GS_PK_KillOpenRequest{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_PK_KillOpenRequest.reserve),
	<<Bin0/binary
	>>.

binary_read_U2GS_PK_KillOpenRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_PK_KillOpenRequest{
		reserve=D3
	},
	Left,
	Count3
	}.

write_GS2U_PK_KillOpenResult(#pk_GS2U_PK_KillOpenResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_PK_KillOpenResult.result),
	Bin3=write_int(P#pk_GS2U_PK_KillOpenResult.pK_Kill_RemainTime),
	Bin6=write_int(P#pk_GS2U_PK_KillOpenResult.pk_Kill_Value),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_GS2U_PK_KillOpenResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_GS2U_PK_KillOpenResult{
		result=D3,
		pK_Kill_RemainTime=D6,
		pk_Kill_Value=D9
	},
	Left,
	Count9
	}.

write_GS2U_Player_ChangeEquipResult(#pk_GS2U_Player_ChangeEquipResult{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_Player_ChangeEquipResult.playerID),
	Bin3=write_int(P#pk_GS2U_Player_ChangeEquipResult.equipID),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_Player_ChangeEquipResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_Player_ChangeEquipResult{
		playerID=D3,
		equipID=D6
	},
	Left,
	Count6
	}.

write_SysMessage(#pk_SysMessage{}=P) -> 
	Bin0=write_int(P#pk_SysMessage.type),
	Bin3=write_string(P#pk_SysMessage.text),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_SysMessage(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_SysMessage{
		type=D3,
		text=D6
	},
	Left,
	Count6
	}.

write_GS2U_AddLifeByItem(#pk_GS2U_AddLifeByItem{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_AddLifeByItem.actorID),
	Bin3=write_int(P#pk_GS2U_AddLifeByItem.addLife),
	Bin6=write_int8(P#pk_GS2U_AddLifeByItem.percent),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_GS2U_AddLifeByItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_GS2U_AddLifeByItem{
		actorID=D3,
		addLife=D6,
		percent=D9
	},
	Left,
	Count9
	}.

write_GS2U_AddLifeBySkill(#pk_GS2U_AddLifeBySkill{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_AddLifeBySkill.actorID),
	Bin3=write_int(P#pk_GS2U_AddLifeBySkill.addLife),
	Bin6=write_int8(P#pk_GS2U_AddLifeBySkill.percent),
	Bin9=write_int8(P#pk_GS2U_AddLifeBySkill.crite),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_GS2U_AddLifeBySkill(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_GS2U_AddLifeBySkill{
		actorID=D3,
		addLife=D6,
		percent=D9,
		crite=D12
	},
	Left,
	Count12
	}.

write_PlayerItemCDInfo(#pk_PlayerItemCDInfo{}=P) -> 
	Bin0=write_int8(P#pk_PlayerItemCDInfo.cdTypeID),
	Bin3=write_int(P#pk_PlayerItemCDInfo.remainTime),
	Bin6=write_int(P#pk_PlayerItemCDInfo.allTime),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PlayerItemCDInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PlayerItemCDInfo{
		cdTypeID=D3,
		remainTime=D6,
		allTime=D9
	},
	Left,
	Count9
	}.

write_GS2U_PlayerItemCDInit(#pk_GS2U_PlayerItemCDInit{}=P) -> 
	Bin0=write_array(P#pk_GS2U_PlayerItemCDInit.info_list,fun(X)-> write_PlayerItemCDInfo(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_PlayerItemCDInit(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_PlayerItemCDInfo(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_PlayerItemCDInit{
		info_list=D3
	},
	Left,
	Count3
	}.

write_GS2U_PlayerItemCDUpdate(#pk_GS2U_PlayerItemCDUpdate{}=P) -> 
	Bin0=write_PlayerItemCDInfo(P#pk_GS2U_PlayerItemCDUpdate.info),
	<<Bin0/binary
	>>.

binary_read_GS2U_PlayerItemCDUpdate(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_PlayerItemCDInfo(Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_PlayerItemCDUpdate{
		info=D3
	},
	Left,
	Count3
	}.

write_U2GS_BloodPoolAddLife(#pk_U2GS_BloodPoolAddLife{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_BloodPoolAddLife.actorID),
	<<Bin0/binary
	>>.

binary_read_U2GS_BloodPoolAddLife(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_BloodPoolAddLife{
		actorID=D3
	},
	Left,
	Count3
	}.

write_GS2U_ItemDailyCount(#pk_GS2U_ItemDailyCount{}=P) -> 
	Bin0=write_int(P#pk_GS2U_ItemDailyCount.remainCount),
	Bin3=write_int(P#pk_GS2U_ItemDailyCount.task_data_id),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_ItemDailyCount(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_ItemDailyCount{
		remainCount=D3,
		task_data_id=D6
	},
	Left,
	Count6
	}.

write_U2GS_GetSigninInfo(#pk_U2GS_GetSigninInfo{}=P) -> 
	<<
	>>.

binary_read_U2GS_GetSigninInfo(Bin0)->
	Count0=0,
	{_,Left} = split_binary(Bin0,Count0),
	{#pk_U2GS_GetSigninInfo{
	},
	Left,
	Count0
	}.

write_GS2U_PlayerSigninInfo(#pk_GS2U_PlayerSigninInfo{}=P) -> 
	Bin0=write_int8(P#pk_GS2U_PlayerSigninInfo.isAlreadySign),
	Bin3=write_int8(P#pk_GS2U_PlayerSigninInfo.days),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_PlayerSigninInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_PlayerSigninInfo{
		isAlreadySign=D3,
		days=D6
	},
	Left,
	Count6
	}.

write_U2GS_Signin(#pk_U2GS_Signin{}=P) -> 
	<<
	>>.

binary_read_U2GS_Signin(Bin0)->
	Count0=0,
	{_,Left} = split_binary(Bin0,Count0),
	{#pk_U2GS_Signin{
	},
	Left,
	Count0
	}.

write_GS2U_PlayerSignInResult(#pk_GS2U_PlayerSignInResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_PlayerSignInResult.nResult),
	Bin3=write_int8(P#pk_GS2U_PlayerSignInResult.awardDays),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_PlayerSignInResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_PlayerSignInResult{
		nResult=D3,
		awardDays=D6
	},
	Left,
	Count6
	}.

write_U2GS_LeaveCopyMap(#pk_U2GS_LeaveCopyMap{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_LeaveCopyMap.reserve),
	<<Bin0/binary
	>>.

binary_read_U2GS_LeaveCopyMap(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_LeaveCopyMap{
		reserve=D3
	},
	Left,
	Count3
	}.

write_PetChangeModel(#pk_PetChangeModel{}=P) -> 
	Bin0=write_int64(P#pk_PetChangeModel.petId),
	Bin3=write_int(P#pk_PetChangeModel.modelID),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PetChangeModel(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PetChangeModel{
		petId=D3,
		modelID=D6
	},
	Left,
	Count6
	}.

write_PetChangeName(#pk_PetChangeName{}=P) -> 
	Bin0=write_int64(P#pk_PetChangeName.petId),
	Bin3=write_string(P#pk_PetChangeName.newName),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PetChangeName(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PetChangeName{
		petId=D3,
		newName=D6
	},
	Left,
	Count6
	}.

write_PetChangeName_Result(#pk_PetChangeName_Result{}=P) -> 
	Bin0=write_int8(P#pk_PetChangeName_Result.result),
	Bin3=write_int64(P#pk_PetChangeName_Result.petId),
	Bin6=write_string(P#pk_PetChangeName_Result.newName),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PetChangeName_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PetChangeName_Result{
		result=D3,
		petId=D6,
		newName=D9
	},
	Left,
	Count9
	}.

write_BazzarItem(#pk_BazzarItem{}=P) -> 
	Bin0=write_int(P#pk_BazzarItem.db_id),
	Bin3=write_int16(P#pk_BazzarItem.item_id),
	Bin6=write_int8(P#pk_BazzarItem.item_column),
	Bin9=write_int16(P#pk_BazzarItem.gold),
	Bin12=write_int16(P#pk_BazzarItem.binded_gold),
	Bin15=write_int16(P#pk_BazzarItem.remain_count),
	Bin18=write_int(P#pk_BazzarItem.remain_time),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary
	>>.

binary_read_BazzarItem(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int16(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int16(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int16(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int(Count18,Bin0),
	Count21=C21+Count18,
	{_,Left} = split_binary(Bin0,Count21),
	{#pk_BazzarItem{
		db_id=D3,
		item_id=D6,
		item_column=D9,
		gold=D12,
		binded_gold=D15,
		remain_count=D18,
		remain_time=D21
	},
	Left,
	Count21
	}.

write_BazzarListRequest(#pk_BazzarListRequest{}=P) -> 
	Bin0=write_int(P#pk_BazzarListRequest.seed),
	<<Bin0/binary
	>>.

binary_read_BazzarListRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_BazzarListRequest{
		seed=D3
	},
	Left,
	Count3
	}.

write_BazzarPriceItemList(#pk_BazzarPriceItemList{}=P) -> 
	Bin0=write_array(P#pk_BazzarPriceItemList.itemList,fun(X)-> write_BazzarItem(X) end),
	<<Bin0/binary
	>>.

binary_read_BazzarPriceItemList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_BazzarItem(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_BazzarPriceItemList{
		itemList=D3
	},
	Left,
	Count3
	}.

write_BazzarItemList(#pk_BazzarItemList{}=P) -> 
	Bin0=write_int(P#pk_BazzarItemList.seed),
	Bin3=write_array(P#pk_BazzarItemList.itemList,fun(X)-> write_BazzarItem(X) end),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_BazzarItemList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_array_head16(Count3,Bin0,fun(X)-> binary_read_BazzarItem(X) end),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_BazzarItemList{
		seed=D3,
		itemList=D6
	},
	Left,
	Count6
	}.

write_BazzarItemUpdate(#pk_BazzarItemUpdate{}=P) -> 
	Bin0=write_BazzarItem(P#pk_BazzarItemUpdate.item),
	<<Bin0/binary
	>>.

binary_read_BazzarItemUpdate(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_BazzarItem(Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_BazzarItemUpdate{
		item=D3
	},
	Left,
	Count3
	}.

write_BazzarBuyRequest(#pk_BazzarBuyRequest{}=P) -> 
	Bin0=write_int(P#pk_BazzarBuyRequest.db_id),
	Bin3=write_int16(P#pk_BazzarBuyRequest.isBindGold),
	Bin6=write_int16(P#pk_BazzarBuyRequest.count),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_BazzarBuyRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_BazzarBuyRequest{
		db_id=D3,
		isBindGold=D6,
		count=D9
	},
	Left,
	Count9
	}.

write_BazzarBuyResult(#pk_BazzarBuyResult{}=P) -> 
	Bin0=write_int8(P#pk_BazzarBuyResult.result),
	<<Bin0/binary
	>>.

binary_read_BazzarBuyResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_BazzarBuyResult{
		result=D3
	},
	Left,
	Count3
	}.

write_PlayerBagCellOpenResult(#pk_PlayerBagCellOpenResult{}=P) -> 
	Bin0=write_int8(P#pk_PlayerBagCellOpenResult.result),
	<<Bin0/binary
	>>.

binary_read_PlayerBagCellOpenResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PlayerBagCellOpenResult{
		result=D3
	},
	Left,
	Count3
	}.

write_U2GS_RemoveSkillBranch(#pk_U2GS_RemoveSkillBranch{}=P) -> 
	Bin0=write_int(P#pk_U2GS_RemoveSkillBranch.nSkillID),
	<<Bin0/binary
	>>.

binary_read_U2GS_RemoveSkillBranch(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RemoveSkillBranch{
		nSkillID=D3
	},
	Left,
	Count3
	}.

write_GS2U_RemoveSkillBranch(#pk_GS2U_RemoveSkillBranch{}=P) -> 
	Bin0=write_int(P#pk_GS2U_RemoveSkillBranch.result),
	Bin3=write_int(P#pk_GS2U_RemoveSkillBranch.nSkillID),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_RemoveSkillBranch(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_RemoveSkillBranch{
		result=D3,
		nSkillID=D6
	},
	Left,
	Count6
	}.

write_U2GS_PetBloodPoolAddLife(#pk_U2GS_PetBloodPoolAddLife{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_PetBloodPoolAddLife.n),
	<<Bin0/binary
	>>.

binary_read_U2GS_PetBloodPoolAddLife(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_PetBloodPoolAddLife{
		n=D3
	},
	Left,
	Count3
	}.

write_U2GS_CopyMapAddActiveCount(#pk_U2GS_CopyMapAddActiveCount{}=P) -> 
	Bin0=write_int16(P#pk_U2GS_CopyMapAddActiveCount.map_data_id),
	<<Bin0/binary
	>>.

binary_read_U2GS_CopyMapAddActiveCount(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_CopyMapAddActiveCount{
		map_data_id=D3
	},
	Left,
	Count3
	}.

write_U2GS_CopyMapAddActiveCountResult(#pk_U2GS_CopyMapAddActiveCountResult{}=P) -> 
	Bin0=write_int16(P#pk_U2GS_CopyMapAddActiveCountResult.result),
	<<Bin0/binary
	>>.

binary_read_U2GS_CopyMapAddActiveCountResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_CopyMapAddActiveCountResult{
		result=D3
	},
	Left,
	Count3
	}.

write_GS2U_CurConvoyInfo(#pk_GS2U_CurConvoyInfo{}=P) -> 
	Bin0=write_int8(P#pk_GS2U_CurConvoyInfo.isDead),
	Bin3=write_int(P#pk_GS2U_CurConvoyInfo.convoyType),
	Bin6=write_int(P#pk_GS2U_CurConvoyInfo.carriageQuality),
	Bin9=write_int(P#pk_GS2U_CurConvoyInfo.remainTime),
	Bin12=write_int(P#pk_GS2U_CurConvoyInfo.lowCD),
	Bin15=write_int(P#pk_GS2U_CurConvoyInfo.highCD),
	Bin18=write_int(P#pk_GS2U_CurConvoyInfo.freeCnt),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary
	>>.

binary_read_GS2U_CurConvoyInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
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
	{_,Left} = split_binary(Bin0,Count21),
	{#pk_GS2U_CurConvoyInfo{
		isDead=D3,
		convoyType=D6,
		carriageQuality=D9,
		remainTime=D12,
		lowCD=D15,
		highCD=D18,
		freeCnt=D21
	},
	Left,
	Count21
	}.

write_U2GS_CarriageQualityRefresh(#pk_U2GS_CarriageQualityRefresh{}=P) -> 
	Bin0=write_int(P#pk_U2GS_CarriageQualityRefresh.isRefreshLegend),
	Bin3=write_int(P#pk_U2GS_CarriageQualityRefresh.isCostGold),
	Bin6=write_int(P#pk_U2GS_CarriageQualityRefresh.curConvoyType),
	Bin9=write_int(P#pk_U2GS_CarriageQualityRefresh.curCarriageQuality),
	Bin12=write_int(P#pk_U2GS_CarriageQualityRefresh.curTaskID),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary
	>>.

binary_read_U2GS_CarriageQualityRefresh(Bin0)->
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
	{_,Left} = split_binary(Bin0,Count15),
	{#pk_U2GS_CarriageQualityRefresh{
		isRefreshLegend=D3,
		isCostGold=D6,
		curConvoyType=D9,
		curCarriageQuality=D12,
		curTaskID=D15
	},
	Left,
	Count15
	}.

write_GS2U_CarriageQualityRefreshResult(#pk_GS2U_CarriageQualityRefreshResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_CarriageQualityRefreshResult.retCode),
	Bin3=write_int(P#pk_GS2U_CarriageQualityRefreshResult.newConvoyType),
	Bin6=write_int(P#pk_GS2U_CarriageQualityRefreshResult.newCarriageQuality),
	Bin9=write_int(P#pk_GS2U_CarriageQualityRefreshResult.freeCnt),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_GS2U_CarriageQualityRefreshResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_GS2U_CarriageQualityRefreshResult{
		retCode=D3,
		newConvoyType=D6,
		newCarriageQuality=D9,
		freeCnt=D12
	},
	Left,
	Count12
	}.

write_U2GS_ConvoyCDRequst(#pk_U2GS_ConvoyCDRequst{}=P) -> 
	<<
	>>.

binary_read_U2GS_ConvoyCDRequst(Bin0)->
	Count0=0,
	{_,Left} = split_binary(Bin0,Count0),
	{#pk_U2GS_ConvoyCDRequst{
	},
	Left,
	Count0
	}.

write_GS2U_ConvoyCDResult(#pk_GS2U_ConvoyCDResult{}=P) -> 
	Bin0=write_int8(P#pk_GS2U_ConvoyCDResult.retCode),
	<<Bin0/binary
	>>.

binary_read_GS2U_ConvoyCDResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_ConvoyCDResult{
		retCode=D3
	},
	Left,
	Count3
	}.

write_U2GS_BeginConvoy(#pk_U2GS_BeginConvoy{}=P) -> 
	Bin0=write_int(P#pk_U2GS_BeginConvoy.nTaskID),
	Bin3=write_int(P#pk_U2GS_BeginConvoy.curConvoyType),
	Bin6=write_int(P#pk_U2GS_BeginConvoy.curCarriageQuality),
	Bin9=write_int64(P#pk_U2GS_BeginConvoy.nNpcActorID),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_U2GS_BeginConvoy(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int64(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_U2GS_BeginConvoy{
		nTaskID=D3,
		curConvoyType=D6,
		curCarriageQuality=D9,
		nNpcActorID=D12
	},
	Left,
	Count12
	}.

write_GS2U_BeginConvoyResult(#pk_GS2U_BeginConvoyResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_BeginConvoyResult.retCode),
	Bin3=write_int(P#pk_GS2U_BeginConvoyResult.curConvoyType),
	Bin6=write_int(P#pk_GS2U_BeginConvoyResult.curCarriageQuality),
	Bin9=write_int(P#pk_GS2U_BeginConvoyResult.remainTime),
	Bin12=write_int(P#pk_GS2U_BeginConvoyResult.lowCD),
	Bin15=write_int(P#pk_GS2U_BeginConvoyResult.highCD),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary
	>>.

binary_read_GS2U_BeginConvoyResult(Bin0)->
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
	{_,Left} = split_binary(Bin0,Count18),
	{#pk_GS2U_BeginConvoyResult{
		retCode=D3,
		curConvoyType=D6,
		curCarriageQuality=D9,
		remainTime=D12,
		lowCD=D15,
		highCD=D18
	},
	Left,
	Count18
	}.

write_GS2U_FinishConvoyResult(#pk_GS2U_FinishConvoyResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_FinishConvoyResult.curConvoyType),
	Bin3=write_int(P#pk_GS2U_FinishConvoyResult.curCarriageQuality),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_FinishConvoyResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_FinishConvoyResult{
		curConvoyType=D3,
		curCarriageQuality=D6
	},
	Left,
	Count6
	}.

write_GS2U_GiveUpConvoyResult(#pk_GS2U_GiveUpConvoyResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_GiveUpConvoyResult.curConvoyType),
	Bin3=write_int(P#pk_GS2U_GiveUpConvoyResult.curCarriageQuality),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_GiveUpConvoyResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_GiveUpConvoyResult{
		curConvoyType=D3,
		curCarriageQuality=D6
	},
	Left,
	Count6
	}.

write_GS2U_ConvoyNoticeTimerResult(#pk_GS2U_ConvoyNoticeTimerResult{}=P) -> 
	Bin0=write_int8(P#pk_GS2U_ConvoyNoticeTimerResult.isDead),
	Bin3=write_int(P#pk_GS2U_ConvoyNoticeTimerResult.remainTime),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_ConvoyNoticeTimerResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_ConvoyNoticeTimerResult{
		isDead=D3,
		remainTime=D6
	},
	Left,
	Count6
	}.

write_GS2U_ConvoyState(#pk_GS2U_ConvoyState{}=P) -> 
	Bin0=write_int8(P#pk_GS2U_ConvoyState.convoyFlags),
	Bin3=write_int(P#pk_GS2U_ConvoyState.quality),
	Bin6=write_int64(P#pk_GS2U_ConvoyState.actorID),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_GS2U_ConvoyState(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int64(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_GS2U_ConvoyState{
		convoyFlags=D3,
		quality=D6,
		actorID=D9
	},
	Left,
	Count9
	}.

write_GSWithU_GameSetMenu(#pk_GSWithU_GameSetMenu{}=P) -> 
	Bin0=write_int8(P#pk_GSWithU_GameSetMenu.joinTeamOnoff),
	Bin3=write_int8(P#pk_GSWithU_GameSetMenu.inviteGuildOnoff),
	Bin6=write_int8(P#pk_GSWithU_GameSetMenu.tradeOnoff),
	Bin9=write_int8(P#pk_GSWithU_GameSetMenu.applicateFriendOnoff),
	Bin12=write_int8(P#pk_GSWithU_GameSetMenu.singleKeyOperateOnoff),
	Bin15=write_int8(P#pk_GSWithU_GameSetMenu.musicPercent),
	Bin18=write_int8(P#pk_GSWithU_GameSetMenu.soundEffectPercent),
	Bin21=write_int8(P#pk_GSWithU_GameSetMenu.shieldEnermyCampPlayer),
	Bin24=write_int8(P#pk_GSWithU_GameSetMenu.shieldSelfCampPlayer),
	Bin27=write_int8(P#pk_GSWithU_GameSetMenu.shieldOthersPet),
	Bin30=write_int8(P#pk_GSWithU_GameSetMenu.shieldOthersName),
	Bin33=write_int8(P#pk_GSWithU_GameSetMenu.shieldSkillEffect),
	Bin36=write_int8(P#pk_GSWithU_GameSetMenu.dispPlayerLimit),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary,Bin33/binary,Bin36/binary
	>>.

binary_read_GSWithU_GameSetMenu(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
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
	{#pk_GSWithU_GameSetMenu{
		joinTeamOnoff=D3,
		inviteGuildOnoff=D6,
		tradeOnoff=D9,
		applicateFriendOnoff=D12,
		singleKeyOperateOnoff=D15,
		musicPercent=D18,
		soundEffectPercent=D21,
		shieldEnermyCampPlayer=D24,
		shieldSelfCampPlayer=D27,
		shieldOthersPet=D30,
		shieldOthersName=D33,
		shieldSkillEffect=D36,
		dispPlayerLimit=D39
	},
	Left,
	Count39
	}.

write_U2GS_RequestRechargeGift(#pk_U2GS_RequestRechargeGift{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_RequestRechargeGift.type),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestRechargeGift(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestRechargeGift{
		type=D3
	},
	Left,
	Count3
	}.

write_U2GS_RequestRechargeGift_Ret(#pk_U2GS_RequestRechargeGift_Ret{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_RequestRechargeGift_Ret.retcode),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestRechargeGift_Ret(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestRechargeGift_Ret{
		retcode=D3
	},
	Left,
	Count3
	}.

write_U2GS_RequestPlayerFightingCapacity(#pk_U2GS_RequestPlayerFightingCapacity{}=P) -> 
	<<
	>>.

binary_read_U2GS_RequestPlayerFightingCapacity(Bin0)->
	Count0=0,
	{_,Left} = split_binary(Bin0,Count0),
	{#pk_U2GS_RequestPlayerFightingCapacity{
	},
	Left,
	Count0
	}.

write_U2GS_RequestPlayerFightingCapacity_Ret(#pk_U2GS_RequestPlayerFightingCapacity_Ret{}=P) -> 
	Bin0=write_int(P#pk_U2GS_RequestPlayerFightingCapacity_Ret.fightingcapacity),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestPlayerFightingCapacity_Ret(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestPlayerFightingCapacity_Ret{
		fightingcapacity=D3
	},
	Left,
	Count3
	}.

write_U2GS_RequestPetFightingCapacity(#pk_U2GS_RequestPetFightingCapacity{}=P) -> 
	Bin0=write_int(P#pk_U2GS_RequestPetFightingCapacity.petid),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestPetFightingCapacity(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestPetFightingCapacity{
		petid=D3
	},
	Left,
	Count3
	}.

write_U2GS_RequestPetFightingCapacity_Ret(#pk_U2GS_RequestPetFightingCapacity_Ret{}=P) -> 
	Bin0=write_int(P#pk_U2GS_RequestPetFightingCapacity_Ret.fightingcapacity),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestPetFightingCapacity_Ret(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestPetFightingCapacity_Ret{
		fightingcapacity=D3
	},
	Left,
	Count3
	}.

write_U2GS_RequestMountFightingCapacity(#pk_U2GS_RequestMountFightingCapacity{}=P) -> 
	Bin0=write_int(P#pk_U2GS_RequestMountFightingCapacity.mountid),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestMountFightingCapacity(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestMountFightingCapacity{
		mountid=D3
	},
	Left,
	Count3
	}.

write_U2GS_RequestMountFightingCapacity_Ret(#pk_U2GS_RequestMountFightingCapacity_Ret{}=P) -> 
	Bin0=write_int(P#pk_U2GS_RequestMountFightingCapacity_Ret.fightingcapacity),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestMountFightingCapacity_Ret(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestMountFightingCapacity_Ret{
		fightingcapacity=D3
	},
	Left,
	Count3
	}.

write_VariantData(#pk_VariantData{}=P) -> 
	Bin0=write_int16(P#pk_VariantData.index),
	Bin3=write_int(P#pk_VariantData.value),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_VariantData(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_VariantData{
		index=D3,
		value=D6
	},
	Left,
	Count6
	}.

write_GS2U_VariantDataSet(#pk_GS2U_VariantDataSet{}=P) -> 
	Bin0=write_int8(P#pk_GS2U_VariantDataSet.variant_type),
	Bin3=write_array(P#pk_GS2U_VariantDataSet.info_list,fun(X)-> write_VariantData(X) end),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_VariantDataSet(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_array_head16(Count3,Bin0,fun(X)-> binary_read_VariantData(X) end),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_VariantDataSet{
		variant_type=D3,
		info_list=D6
	},
	Left,
	Count6
	}.

write_U2GS_GetRankList(#pk_U2GS_GetRankList{}=P) -> 
	Bin0=write_int(P#pk_U2GS_GetRankList.mapDataID),
	<<Bin0/binary
	>>.

binary_read_U2GS_GetRankList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_GetRankList{
		mapDataID=D3
	},
	Left,
	Count3
	}.

write_GS2U_RankList(#pk_GS2U_RankList{}=P) -> 
	Bin0=write_int(P#pk_GS2U_RankList.mapID),
	Bin3=write_int(P#pk_GS2U_RankList.rankNum),
	Bin6=write_string(P#pk_GS2U_RankList.name1),
	Bin9=write_int(P#pk_GS2U_RankList.harm1),
	Bin12=write_string(P#pk_GS2U_RankList.name2),
	Bin15=write_int(P#pk_GS2U_RankList.harm2),
	Bin18=write_string(P#pk_GS2U_RankList.name3),
	Bin21=write_int(P#pk_GS2U_RankList.harm3),
	Bin24=write_string(P#pk_GS2U_RankList.name4),
	Bin27=write_int(P#pk_GS2U_RankList.harm4),
	Bin30=write_string(P#pk_GS2U_RankList.name5),
	Bin33=write_int(P#pk_GS2U_RankList.harm5),
	Bin36=write_string(P#pk_GS2U_RankList.name6),
	Bin39=write_int(P#pk_GS2U_RankList.harm6),
	Bin42=write_string(P#pk_GS2U_RankList.name7),
	Bin45=write_int(P#pk_GS2U_RankList.harm7),
	Bin48=write_string(P#pk_GS2U_RankList.name8),
	Bin51=write_int(P#pk_GS2U_RankList.harm8),
	Bin54=write_string(P#pk_GS2U_RankList.name9),
	Bin57=write_int(P#pk_GS2U_RankList.harm9),
	Bin60=write_string(P#pk_GS2U_RankList.name10),
	Bin63=write_int(P#pk_GS2U_RankList.harm10),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary,Bin33/binary,Bin36/binary,Bin39/binary,Bin42/binary,Bin45/binary,Bin48/binary,Bin51/binary,Bin54/binary,Bin57/binary,Bin60/binary,Bin63/binary
	>>.

binary_read_GS2U_RankList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_string(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_string(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_int(Count21,Bin0),
	Count24=C24+Count21,
	{D27,C27}=binary_read_string(Count24,Bin0),
	Count27=C27+Count24,
	{D30,C30}=binary_read_int(Count27,Bin0),
	Count30=C30+Count27,
	{D33,C33}=binary_read_string(Count30,Bin0),
	Count33=C33+Count30,
	{D36,C36}=binary_read_int(Count33,Bin0),
	Count36=C36+Count33,
	{D39,C39}=binary_read_string(Count36,Bin0),
	Count39=C39+Count36,
	{D42,C42}=binary_read_int(Count39,Bin0),
	Count42=C42+Count39,
	{D45,C45}=binary_read_string(Count42,Bin0),
	Count45=C45+Count42,
	{D48,C48}=binary_read_int(Count45,Bin0),
	Count48=C48+Count45,
	{D51,C51}=binary_read_string(Count48,Bin0),
	Count51=C51+Count48,
	{D54,C54}=binary_read_int(Count51,Bin0),
	Count54=C54+Count51,
	{D57,C57}=binary_read_string(Count54,Bin0),
	Count57=C57+Count54,
	{D60,C60}=binary_read_int(Count57,Bin0),
	Count60=C60+Count57,
	{D63,C63}=binary_read_string(Count60,Bin0),
	Count63=C63+Count60,
	{D66,C66}=binary_read_int(Count63,Bin0),
	Count66=C66+Count63,
	{_,Left} = split_binary(Bin0,Count66),
	{#pk_GS2U_RankList{
		mapID=D3,
		rankNum=D6,
		name1=D9,
		harm1=D12,
		name2=D15,
		harm2=D18,
		name3=D21,
		harm3=D24,
		name4=D27,
		harm4=D30,
		name5=D33,
		harm5=D36,
		name6=D39,
		harm6=D42,
		name7=D45,
		harm7=D48,
		name8=D51,
		harm8=D54,
		name9=D57,
		harm9=D60,
		name10=D63,
		harm10=D66
	},
	Left,
	Count66
	}.

write_GS2U_WordBossCmd(#pk_GS2U_WordBossCmd{}=P) -> 
	Bin0=write_int(P#pk_GS2U_WordBossCmd.m_iCmd),
	Bin3=write_int(P#pk_GS2U_WordBossCmd.m_iParam),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_WordBossCmd(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_WordBossCmd{
		m_iCmd=D3,
		m_iParam=D6
	},
	Left,
	Count6
	}.

write_U2GS_ChangePlayerName(#pk_U2GS_ChangePlayerName{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_ChangePlayerName.id),
	Bin3=write_string(P#pk_U2GS_ChangePlayerName.name),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_U2GS_ChangePlayerName(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_U2GS_ChangePlayerName{
		id=D3,
		name=D6
	},
	Left,
	Count6
	}.

write_GS2U_ChangePlayerNameResult(#pk_GS2U_ChangePlayerNameResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_ChangePlayerNameResult.retCode),
	<<Bin0/binary
	>>.

binary_read_GS2U_ChangePlayerNameResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_ChangePlayerNameResult{
		retCode=D3
	},
	Left,
	Count3
	}.

write_U2GS_SetProtectPwd(#pk_U2GS_SetProtectPwd{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_SetProtectPwd.id),
	Bin3=write_string(P#pk_U2GS_SetProtectPwd.oldpwd),
	Bin6=write_string(P#pk_U2GS_SetProtectPwd.pwd),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_U2GS_SetProtectPwd(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_U2GS_SetProtectPwd{
		id=D3,
		oldpwd=D6,
		pwd=D9
	},
	Left,
	Count9
	}.

write_GS2U_SetProtectPwdResult(#pk_GS2U_SetProtectPwdResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_SetProtectPwdResult.retCode),
	<<Bin0/binary
	>>.

binary_read_GS2U_SetProtectPwdResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_SetProtectPwdResult{
		retCode=D3
	},
	Left,
	Count3
	}.

write_U2GS_HeartBeat(#pk_U2GS_HeartBeat{}=P) -> 
	<<
	>>.

binary_read_U2GS_HeartBeat(Bin0)->
	Count0=0,
	{_,Left} = split_binary(Bin0,Count0),
	{#pk_U2GS_HeartBeat{
	},
	Left,
	Count0
	}.

write_GS2U_CopyProgressUpdate(#pk_GS2U_CopyProgressUpdate{}=P) -> 
	Bin0=write_int8(P#pk_GS2U_CopyProgressUpdate.progress),
	<<Bin0/binary
	>>.

binary_read_GS2U_CopyProgressUpdate(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_CopyProgressUpdate{
		progress=D3
	},
	Left,
	Count3
	}.

write_U2GS_QequestGiveGoldCheck(#pk_U2GS_QequestGiveGoldCheck{}=P) -> 
	<<
	>>.

binary_read_U2GS_QequestGiveGoldCheck(Bin0)->
	Count0=0,
	{_,Left} = split_binary(Bin0,Count0),
	{#pk_U2GS_QequestGiveGoldCheck{
	},
	Left,
	Count0
	}.

write_U2GS_StartGiveGold(#pk_U2GS_StartGiveGold{}=P) -> 
	<<
	>>.

binary_read_U2GS_StartGiveGold(Bin0)->
	Count0=0,
	{_,Left} = split_binary(Bin0,Count0),
	{#pk_U2GS_StartGiveGold{
	},
	Left,
	Count0
	}.

write_U2GS_StartGiveGoldResult(#pk_U2GS_StartGiveGoldResult{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_StartGiveGoldResult.goldType),
	Bin3=write_int8(P#pk_U2GS_StartGiveGoldResult.useCnt),
	Bin6=write_int(P#pk_U2GS_StartGiveGoldResult.exp),
	Bin9=write_int(P#pk_U2GS_StartGiveGoldResult.level),
	Bin12=write_int(P#pk_U2GS_StartGiveGoldResult.awardMoney),
	Bin15=write_int(P#pk_U2GS_StartGiveGoldResult.retCode),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary
	>>.

binary_read_U2GS_StartGiveGoldResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int(Count15,Bin0),
	Count18=C18+Count15,
	{_,Left} = split_binary(Bin0,Count18),
	{#pk_U2GS_StartGiveGoldResult{
		goldType=D3,
		useCnt=D6,
		exp=D9,
		level=D12,
		awardMoney=D15,
		retCode=D18
	},
	Left,
	Count18
	}.

write_U2GS_GoldLineInfo(#pk_U2GS_GoldLineInfo{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_GoldLineInfo.useCnt),
	Bin3=write_int(P#pk_U2GS_GoldLineInfo.exp),
	Bin6=write_int(P#pk_U2GS_GoldLineInfo.level),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_U2GS_GoldLineInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_U2GS_GoldLineInfo{
		useCnt=D3,
		exp=D6,
		level=D9
	},
	Left,
	Count9
	}.

write_U2GS_GoldResetTimer(#pk_U2GS_GoldResetTimer{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_GoldResetTimer.useCnt),
	<<Bin0/binary
	>>.

binary_read_U2GS_GoldResetTimer(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_GoldResetTimer{
		useCnt=D3
	},
	Left,
	Count3
	}.

write_GS2U_CopyMapSAData(#pk_GS2U_CopyMapSAData{}=P) -> 
	Bin0=write_int(P#pk_GS2U_CopyMapSAData.map_id),
	Bin3=write_int(P#pk_GS2U_CopyMapSAData.killed_count),
	Bin6=write_int8(P#pk_GS2U_CopyMapSAData.finish_rate),
	Bin9=write_int(P#pk_GS2U_CopyMapSAData.cost_time),
	Bin12=write_int(P#pk_GS2U_CopyMapSAData.exp),
	Bin15=write_int(P#pk_GS2U_CopyMapSAData.money),
	Bin18=write_int8(P#pk_GS2U_CopyMapSAData.level),
	Bin21=write_int8(P#pk_GS2U_CopyMapSAData.is_perfect),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary
	>>.

binary_read_GS2U_CopyMapSAData(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int8(Count18,Bin0),
	Count21=C21+Count18,
	{D24,C24}=binary_read_int8(Count21,Bin0),
	Count24=C24+Count21,
	{_,Left} = split_binary(Bin0,Count24),
	{#pk_GS2U_CopyMapSAData{
		map_id=D3,
		killed_count=D6,
		finish_rate=D9,
		cost_time=D12,
		exp=D15,
		money=D18,
		level=D21,
		is_perfect=D24
	},
	Left,
	Count24
	}.

write_TokenStoreItemData(#pk_TokenStoreItemData{}=P) -> 
	Bin0=write_int64(P#pk_TokenStoreItemData.id),
	Bin3=write_int(P#pk_TokenStoreItemData.item_id),
	Bin6=write_int(P#pk_TokenStoreItemData.price),
	Bin9=write_int(P#pk_TokenStoreItemData.tokenType),
	Bin12=write_int(P#pk_TokenStoreItemData.isbind),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary
	>>.

binary_read_TokenStoreItemData(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{_,Left} = split_binary(Bin0,Count15),
	{#pk_TokenStoreItemData{
		id=D3,
		item_id=D6,
		price=D9,
		tokenType=D12,
		isbind=D15
	},
	Left,
	Count15
	}.

write_GetTokenStoreItemListAck(#pk_GetTokenStoreItemListAck{}=P) -> 
	Bin0=write_int(P#pk_GetTokenStoreItemListAck.store_id),
	Bin3=write_array(P#pk_GetTokenStoreItemListAck.itemList,fun(X)-> write_TokenStoreItemData(X) end),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GetTokenStoreItemListAck(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_array_head16(Count3,Bin0,fun(X)-> binary_read_TokenStoreItemData(X) end),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GetTokenStoreItemListAck{
		store_id=D3,
		itemList=D6
	},
	Left,
	Count6
	}.

write_RequestLookPlayer(#pk_RequestLookPlayer{}=P) -> 
	Bin0=write_int64(P#pk_RequestLookPlayer.playerID),
	<<Bin0/binary
	>>.

binary_read_RequestLookPlayer(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestLookPlayer{
		playerID=D3
	},
	Left,
	Count3
	}.

write_RequestLookPlayer_Result(#pk_RequestLookPlayer_Result{}=P) -> 
	Bin0=write_PlayerBaseInfo(P#pk_RequestLookPlayer_Result.baseInfo),
	Bin3=write_array(P#pk_RequestLookPlayer_Result.propertyList,fun(X)-> write_CharPropertyData(X) end),
	Bin6=write_array(P#pk_RequestLookPlayer_Result.petList,fun(X)-> write_PetProperty(X) end),
	Bin9=write_array(P#pk_RequestLookPlayer_Result.equipList,fun(X)-> write_PlayerEquipNetData(X) end),
	Bin12=write_int(P#pk_RequestLookPlayer_Result.fightCapacity),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary
	>>.

binary_read_RequestLookPlayer_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_PlayerBaseInfo(Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_array_head16(Count3,Bin0,fun(X)-> binary_read_CharPropertyData(X) end),
	Count6=C6+Count3,
	{D9,C9}=binary_read_array_head16(Count6,Bin0,fun(X)-> binary_read_PetProperty(X) end),
	Count9=C9+Count6,
	{D12,C12}=binary_read_array_head16(Count9,Bin0,fun(X)-> binary_read_PlayerEquipNetData(X) end),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int(Count12,Bin0),
	Count15=C15+Count12,
	{_,Left} = split_binary(Bin0,Count15),
	{#pk_RequestLookPlayer_Result{
		baseInfo=D3,
		propertyList=D6,
		petList=D9,
		equipList=D12,
		fightCapacity=D15
	},
	Left,
	Count15
	}.

write_RequestLookPlayerFailed_Result(#pk_RequestLookPlayerFailed_Result{}=P) -> 
	Bin0=write_int8(P#pk_RequestLookPlayerFailed_Result.result),
	<<Bin0/binary
	>>.

binary_read_RequestLookPlayerFailed_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestLookPlayerFailed_Result{
		result=D3
	},
	Left,
	Count3
	}.

write_U2GS_PlayerClientInfo(#pk_U2GS_PlayerClientInfo{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_PlayerClientInfo.playerid),
	Bin3=write_string(P#pk_U2GS_PlayerClientInfo.platform),
	Bin6=write_string(P#pk_U2GS_PlayerClientInfo.machine),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_U2GS_PlayerClientInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_U2GS_PlayerClientInfo{
		playerid=D3,
		platform=D6,
		machine=D9
	},
	Left,
	Count9
	}.

write_U2GS_RequestActiveCount(#pk_U2GS_RequestActiveCount{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_RequestActiveCount.n),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestActiveCount(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestActiveCount{
		n=D3
	},
	Left,
	Count3
	}.

write_ActiveCountData(#pk_ActiveCountData{}=P) -> 
	Bin0=write_int(P#pk_ActiveCountData.daily_id),
	Bin3=write_int(P#pk_ActiveCountData.count),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_ActiveCountData(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_ActiveCountData{
		daily_id=D3,
		count=D6
	},
	Left,
	Count6
	}.

write_GS2U_ActiveCount(#pk_GS2U_ActiveCount{}=P) -> 
	Bin0=write_int(P#pk_GS2U_ActiveCount.activeValue),
	Bin3=write_array(P#pk_GS2U_ActiveCount.dailyList,fun(X)-> write_ActiveCountData(X) end),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_ActiveCount(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_array_head16(Count3,Bin0,fun(X)-> binary_read_ActiveCountData(X) end),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_ActiveCount{
		activeValue=D3,
		dailyList=D6
	},
	Left,
	Count6
	}.

write_U2GS_RequestConvertActive(#pk_U2GS_RequestConvertActive{}=P) -> 
	Bin0=write_int(P#pk_U2GS_RequestConvertActive.n),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestConvertActive(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestConvertActive{
		n=D3
	},
	Left,
	Count3
	}.

write_GS2U_WhetherTransferOldRecharge(#pk_GS2U_WhetherTransferOldRecharge{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_WhetherTransferOldRecharge.playerID),
	Bin3=write_string(P#pk_GS2U_WhetherTransferOldRecharge.name),
	Bin6=write_int(P#pk_GS2U_WhetherTransferOldRecharge.rechargeRmb),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_GS2U_WhetherTransferOldRecharge(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_GS2U_WhetherTransferOldRecharge{
		playerID=D3,
		name=D6,
		rechargeRmb=D9
	},
	Left,
	Count9
	}.

write_U2GS_TransferOldRechargeToPlayer(#pk_U2GS_TransferOldRechargeToPlayer{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_TransferOldRechargeToPlayer.playerId),
	Bin3=write_int8(P#pk_U2GS_TransferOldRechargeToPlayer.isTransfer),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_U2GS_TransferOldRechargeToPlayer(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_U2GS_TransferOldRechargeToPlayer{
		playerId=D3,
		isTransfer=D6
	},
	Left,
	Count6
	}.

write_GS2U_TransferOldRechargeResult(#pk_GS2U_TransferOldRechargeResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_TransferOldRechargeResult.errorCode),
	<<Bin0/binary
	>>.

binary_read_GS2U_TransferOldRechargeResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_TransferOldRechargeResult{
		errorCode=D3
	},
	Left,
	Count3
	}.

write_PlayerEquipActiveFailReason(#pk_PlayerEquipActiveFailReason{}=P) -> 
	Bin0=write_int(P#pk_PlayerEquipActiveFailReason.reason),
	<<Bin0/binary
	>>.

binary_read_PlayerEquipActiveFailReason(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PlayerEquipActiveFailReason{
		reason=D3
	},
	Left,
	Count3
	}.

write_PlayerEquipMinLevelChange(#pk_PlayerEquipMinLevelChange{}=P) -> 
	Bin0=write_int64(P#pk_PlayerEquipMinLevelChange.playerid),
	Bin3=write_int8(P#pk_PlayerEquipMinLevelChange.minEquipLevel),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PlayerEquipMinLevelChange(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PlayerEquipMinLevelChange{
		playerid=D3,
		minEquipLevel=D6
	},
	Left,
	Count6
	}.

write_PlayerImportPassWord(#pk_PlayerImportPassWord{}=P) -> 
	Bin0=write_string(P#pk_PlayerImportPassWord.passWord),
	Bin3=write_int(P#pk_PlayerImportPassWord.passWordType),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PlayerImportPassWord(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PlayerImportPassWord{
		passWord=D3,
		passWordType=D6
	},
	Left,
	Count6
	}.

write_PlayerImportPassWordResult(#pk_PlayerImportPassWordResult{}=P) -> 
	Bin0=write_int(P#pk_PlayerImportPassWordResult.result),
	<<Bin0/binary
	>>.

binary_read_PlayerImportPassWordResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PlayerImportPassWordResult{
		result=D3
	},
	Left,
	Count3
	}.

write_GS2U_UpdatePlayerGuildInfo(#pk_GS2U_UpdatePlayerGuildInfo{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_UpdatePlayerGuildInfo.player_id),
	Bin3=write_int64(P#pk_GS2U_UpdatePlayerGuildInfo.guild_id),
	Bin6=write_string(P#pk_GS2U_UpdatePlayerGuildInfo.guild_name),
	Bin9=write_int8(P#pk_GS2U_UpdatePlayerGuildInfo.guild_rank),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_GS2U_UpdatePlayerGuildInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_string(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_GS2U_UpdatePlayerGuildInfo{
		player_id=D3,
		guild_id=D6,
		guild_name=D9,
		guild_rank=D12
	},
	Left,
	Count12
	}.

write_U2GS_RequestBazzarItemPrice(#pk_U2GS_RequestBazzarItemPrice{}=P) -> 
	Bin0=write_int(P#pk_U2GS_RequestBazzarItemPrice.item_id),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestBazzarItemPrice(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestBazzarItemPrice{
		item_id=D3
	},
	Left,
	Count3
	}.

write_U2GS_RequestBazzarItemPrice_Result(#pk_U2GS_RequestBazzarItemPrice_Result{}=P) -> 
	Bin0=write_array(P#pk_U2GS_RequestBazzarItemPrice_Result.item,fun(X)-> write_BazzarItem(X) end),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestBazzarItemPrice_Result(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_BazzarItem(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestBazzarItemPrice_Result{
		item=D3
	},
	Left,
	Count3
	}.

write_RequestChangeGoldPassWord(#pk_RequestChangeGoldPassWord{}=P) -> 
	Bin0=write_string(P#pk_RequestChangeGoldPassWord.oldGoldPassWord),
	Bin3=write_string(P#pk_RequestChangeGoldPassWord.newGoldPassWord),
	Bin6=write_int(P#pk_RequestChangeGoldPassWord.status),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_RequestChangeGoldPassWord(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_string(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_RequestChangeGoldPassWord{
		oldGoldPassWord=D3,
		newGoldPassWord=D6,
		status=D9
	},
	Left,
	Count9
	}.

write_PlayerGoldPassWordChanged(#pk_PlayerGoldPassWordChanged{}=P) -> 
	Bin0=write_int(P#pk_PlayerGoldPassWordChanged.result),
	<<Bin0/binary
	>>.

binary_read_PlayerGoldPassWordChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PlayerGoldPassWordChanged{
		result=D3
	},
	Left,
	Count3
	}.

write_PlayerImportGoldPassWordResult(#pk_PlayerImportGoldPassWordResult{}=P) -> 
	Bin0=write_int(P#pk_PlayerImportGoldPassWordResult.result),
	<<Bin0/binary
	>>.

binary_read_PlayerImportGoldPassWordResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PlayerImportGoldPassWordResult{
		result=D3
	},
	Left,
	Count3
	}.

write_PlayerGoldUnlockTimesChanged(#pk_PlayerGoldUnlockTimesChanged{}=P) -> 
	Bin0=write_int(P#pk_PlayerGoldUnlockTimesChanged.unlockTimes),
	<<Bin0/binary
	>>.

binary_read_PlayerGoldUnlockTimesChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_PlayerGoldUnlockTimesChanged{
		unlockTimes=D3
	},
	Left,
	Count3
	}.

write_GS2U_LeftSmallMonsterNumber(#pk_GS2U_LeftSmallMonsterNumber{}=P) -> 
	Bin0=write_int16(P#pk_GS2U_LeftSmallMonsterNumber.leftMonsterNum),
	<<Bin0/binary
	>>.

binary_read_GS2U_LeftSmallMonsterNumber(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_LeftSmallMonsterNumber{
		leftMonsterNum=D3
	},
	Left,
	Count3
	}.

write_GS2U_VipInfo(#pk_GS2U_VipInfo{}=P) -> 
	Bin0=write_int(P#pk_GS2U_VipInfo.vipLevel),
	Bin3=write_int(P#pk_GS2U_VipInfo.vipTime),
	Bin6=write_int(P#pk_GS2U_VipInfo.vipTimeExpire),
	Bin9=write_int(P#pk_GS2U_VipInfo.vipTimeBuy),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_GS2U_VipInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_GS2U_VipInfo{
		vipLevel=D3,
		vipTime=D6,
		vipTimeExpire=D9,
		vipTimeBuy=D12
	},
	Left,
	Count12
	}.

write_GS2U_TellMapLineID(#pk_GS2U_TellMapLineID{}=P) -> 
	Bin0=write_int8(P#pk_GS2U_TellMapLineID.iLineID),
	<<Bin0/binary
	>>.

binary_read_GS2U_TellMapLineID(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_TellMapLineID{
		iLineID=D3
	},
	Left,
	Count3
	}.

write_VIPPlayerOpenVIPStoreRequest(#pk_VIPPlayerOpenVIPStoreRequest{}=P) -> 
	Bin0=write_int(P#pk_VIPPlayerOpenVIPStoreRequest.request),
	<<Bin0/binary
	>>.

binary_read_VIPPlayerOpenVIPStoreRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_VIPPlayerOpenVIPStoreRequest{
		request=D3
	},
	Left,
	Count3
	}.

write_VIPPlayerOpenVIPStoreFail(#pk_VIPPlayerOpenVIPStoreFail{}=P) -> 
	Bin0=write_int(P#pk_VIPPlayerOpenVIPStoreFail.fail),
	<<Bin0/binary
	>>.

binary_read_VIPPlayerOpenVIPStoreFail(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_VIPPlayerOpenVIPStoreFail{
		fail=D3
	},
	Left,
	Count3
	}.

write_UpdateVIPLevelInfo(#pk_UpdateVIPLevelInfo{}=P) -> 
	Bin0=write_int64(P#pk_UpdateVIPLevelInfo.playerID),
	Bin3=write_int8(P#pk_UpdateVIPLevelInfo.vipLevel),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_UpdateVIPLevelInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_UpdateVIPLevelInfo{
		playerID=D3,
		vipLevel=D6
	},
	Left,
	Count6
	}.

write_ActiveCodeRequest(#pk_ActiveCodeRequest{}=P) -> 
	Bin0=write_string(P#pk_ActiveCodeRequest.active_code),
	<<Bin0/binary
	>>.

binary_read_ActiveCodeRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_ActiveCodeRequest{
		active_code=D3
	},
	Left,
	Count3
	}.

write_ActiveCodeResult(#pk_ActiveCodeResult{}=P) -> 
	Bin0=write_int(P#pk_ActiveCodeResult.result),
	<<Bin0/binary
	>>.

binary_read_ActiveCodeResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_ActiveCodeResult{
		result=D3
	},
	Left,
	Count3
	}.

write_U2GS_RequestOutFightPetPropetry(#pk_U2GS_RequestOutFightPetPropetry{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_RequestOutFightPetPropetry.n),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestOutFightPetPropetry(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestOutFightPetPropetry{
		n=D3
	},
	Left,
	Count3
	}.

write_GS2U_RequestOutFightPetPropetryResult(#pk_GS2U_RequestOutFightPetPropetryResult{}=P) -> 
	Bin0=write_int64(P#pk_GS2U_RequestOutFightPetPropetryResult.pet_id),
	Bin3=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.attack),
	Bin6=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.defence),
	Bin9=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.hit),
	Bin12=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.dodge),
	Bin15=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.block),
	Bin18=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.tough),
	Bin21=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.crit),
	Bin24=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.crit_damage_rate),
	Bin27=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.attack_speed),
	Bin30=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.pierce),
	Bin33=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.ph_def),
	Bin36=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.fire_def),
	Bin39=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.ice_def),
	Bin42=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.elec_def),
	Bin45=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.poison_def),
	Bin48=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.coma_def),
	Bin51=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.hold_def),
	Bin54=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.silent_def),
	Bin57=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.move_def),
	Bin60=write_int(P#pk_GS2U_RequestOutFightPetPropetryResult.max_life),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary,Bin33/binary,Bin36/binary,Bin39/binary,Bin42/binary,Bin45/binary,Bin48/binary,Bin51/binary,Bin54/binary,Bin57/binary,Bin60/binary
	>>.

binary_read_GS2U_RequestOutFightPetPropetryResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
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
	{D39,C39}=binary_read_int(Count36,Bin0),
	Count39=C39+Count36,
	{D42,C42}=binary_read_int(Count39,Bin0),
	Count42=C42+Count39,
	{D45,C45}=binary_read_int(Count42,Bin0),
	Count45=C45+Count42,
	{D48,C48}=binary_read_int(Count45,Bin0),
	Count48=C48+Count45,
	{D51,C51}=binary_read_int(Count48,Bin0),
	Count51=C51+Count48,
	{D54,C54}=binary_read_int(Count51,Bin0),
	Count54=C54+Count51,
	{D57,C57}=binary_read_int(Count54,Bin0),
	Count57=C57+Count54,
	{D60,C60}=binary_read_int(Count57,Bin0),
	Count60=C60+Count57,
	{D63,C63}=binary_read_int(Count60,Bin0),
	Count63=C63+Count60,
	{_,Left} = split_binary(Bin0,Count63),
	{#pk_GS2U_RequestOutFightPetPropetryResult{
		pet_id=D3,
		attack=D6,
		defence=D9,
		hit=D12,
		dodge=D15,
		block=D18,
		tough=D21,
		crit=D24,
		crit_damage_rate=D27,
		attack_speed=D30,
		pierce=D33,
		ph_def=D36,
		fire_def=D39,
		ice_def=D42,
		elec_def=D45,
		poison_def=D48,
		coma_def=D51,
		hold_def=D54,
		silent_def=D57,
		move_def=D60,
		max_life=D63
	},
	Left,
	Count63
	}.

write_PlayerDirMove(#pk_PlayerDirMove{}=P) -> 
	Bin0=write_int16(P#pk_PlayerDirMove.pos_x),
	Bin3=write_int16(P#pk_PlayerDirMove.pos_y),
	Bin6=write_int8(P#pk_PlayerDirMove.dir),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PlayerDirMove(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PlayerDirMove{
		pos_x=D3,
		pos_y=D6,
		dir=D9
	},
	Left,
	Count9
	}.

write_PlayerDirMove_S2C(#pk_PlayerDirMove_S2C{}=P) -> 
	Bin0=write_int64(P#pk_PlayerDirMove_S2C.player_id),
	Bin3=write_int16(P#pk_PlayerDirMove_S2C.pos_x),
	Bin6=write_int16(P#pk_PlayerDirMove_S2C.pos_y),
	Bin9=write_int8(P#pk_PlayerDirMove_S2C.dir),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary
	>>.

binary_read_PlayerDirMove_S2C(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
	Count12=C12+Count9,
	{_,Left} = split_binary(Bin0,Count12),
	{#pk_PlayerDirMove_S2C{
		player_id=D3,
		pos_x=D6,
		pos_y=D9,
		dir=D12
	},
	Left,
	Count12
	}.

write_U2GS_EnRollCampusBattle(#pk_U2GS_EnRollCampusBattle{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_EnRollCampusBattle.npcID),
	Bin3=write_int16(P#pk_U2GS_EnRollCampusBattle.battleID),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_U2GS_EnRollCampusBattle(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_U2GS_EnRollCampusBattle{
		npcID=D3,
		battleID=D6
	},
	Left,
	Count6
	}.

write_GSWithU_GameSetMenu_3(#pk_GSWithU_GameSetMenu_3{}=P) -> 
	Bin0=write_int8(P#pk_GSWithU_GameSetMenu_3.joinTeamOnoff),
	Bin3=write_int8(P#pk_GSWithU_GameSetMenu_3.inviteGuildOnoff),
	Bin6=write_int8(P#pk_GSWithU_GameSetMenu_3.tradeOnoff),
	Bin9=write_int8(P#pk_GSWithU_GameSetMenu_3.applicateFriendOnoff),
	Bin12=write_int8(P#pk_GSWithU_GameSetMenu_3.singleKeyOperateOnoff),
	Bin15=write_int8(P#pk_GSWithU_GameSetMenu_3.musicPercent),
	Bin18=write_int8(P#pk_GSWithU_GameSetMenu_3.soundEffectPercent),
	Bin21=write_int8(P#pk_GSWithU_GameSetMenu_3.shieldEnermyCampPlayer),
	Bin24=write_int8(P#pk_GSWithU_GameSetMenu_3.shieldSelfCampPlayer),
	Bin27=write_int8(P#pk_GSWithU_GameSetMenu_3.shieldOthersPet),
	Bin30=write_int8(P#pk_GSWithU_GameSetMenu_3.shieldOthersName),
	Bin33=write_int8(P#pk_GSWithU_GameSetMenu_3.shieldSkillEffect),
	Bin36=write_int8(P#pk_GSWithU_GameSetMenu_3.dispPlayerLimit),
	Bin39=write_int8(P#pk_GSWithU_GameSetMenu_3.shieldOthersSoundEff),
	Bin42=write_int8(P#pk_GSWithU_GameSetMenu_3.noAttackGuildMate),
	Bin45=write_int8(P#pk_GSWithU_GameSetMenu_3.reserve1),
	Bin48=write_int8(P#pk_GSWithU_GameSetMenu_3.reserve2),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary,Bin21/binary,Bin24/binary,Bin27/binary,Bin30/binary,Bin33/binary,Bin36/binary,Bin39/binary,Bin42/binary,Bin45/binary,Bin48/binary
	>>.

binary_read_GSWithU_GameSetMenu_3(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int8(Count9,Bin0),
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
	{D42,C42}=binary_read_int8(Count39,Bin0),
	Count42=C42+Count39,
	{D45,C45}=binary_read_int8(Count42,Bin0),
	Count45=C45+Count42,
	{D48,C48}=binary_read_int8(Count45,Bin0),
	Count48=C48+Count45,
	{D51,C51}=binary_read_int8(Count48,Bin0),
	Count51=C51+Count48,
	{_,Left} = split_binary(Bin0,Count51),
	{#pk_GSWithU_GameSetMenu_3{
		joinTeamOnoff=D3,
		inviteGuildOnoff=D6,
		tradeOnoff=D9,
		applicateFriendOnoff=D12,
		singleKeyOperateOnoff=D15,
		musicPercent=D18,
		soundEffectPercent=D21,
		shieldEnermyCampPlayer=D24,
		shieldSelfCampPlayer=D27,
		shieldOthersPet=D30,
		shieldOthersName=D33,
		shieldSkillEffect=D36,
		dispPlayerLimit=D39,
		shieldOthersSoundEff=D42,
		noAttackGuildMate=D45,
		reserve1=D48,
		reserve2=D51
	},
	Left,
	Count51
	}.

write_StartCompound(#pk_StartCompound{}=P) -> 
	Bin0=write_int(P#pk_StartCompound.makeItemID),
	Bin3=write_int8(P#pk_StartCompound.compounBindedType),
	Bin6=write_int8(P#pk_StartCompound.isUseDoubleRule),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_StartCompound(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_StartCompound{
		makeItemID=D3,
		compounBindedType=D6,
		isUseDoubleRule=D9
	},
	Left,
	Count9
	}.

write_StartCompoundResult(#pk_StartCompoundResult{}=P) -> 
	Bin0=write_int8(P#pk_StartCompoundResult.retCode),
	<<Bin0/binary
	>>.

binary_read_StartCompoundResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_StartCompoundResult{
		retCode=D3
	},
	Left,
	Count3
	}.

write_CompoundBaseInfo(#pk_CompoundBaseInfo{}=P) -> 
	Bin0=write_int(P#pk_CompoundBaseInfo.exp),
	Bin3=write_int(P#pk_CompoundBaseInfo.level),
	Bin6=write_int(P#pk_CompoundBaseInfo.makeItemID),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_CompoundBaseInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_CompoundBaseInfo{
		exp=D3,
		level=D6,
		makeItemID=D9
	},
	Left,
	Count9
	}.

write_RequestEquipFastUpQuality(#pk_RequestEquipFastUpQuality{}=P) -> 
	Bin0=write_int(P#pk_RequestEquipFastUpQuality.equipId),
	<<Bin0/binary
	>>.

binary_read_RequestEquipFastUpQuality(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_RequestEquipFastUpQuality{
		equipId=D3
	},
	Left,
	Count3
	}.

write_EquipQualityFastUPByTypeBack(#pk_EquipQualityFastUPByTypeBack{}=P) -> 
	Bin0=write_int(P#pk_EquipQualityFastUPByTypeBack.result),
	<<Bin0/binary
	>>.

binary_read_EquipQualityFastUPByTypeBack(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_EquipQualityFastUPByTypeBack{
		result=D3
	},
	Left,
	Count3
	}.

write_PlayerTeleportMove(#pk_PlayerTeleportMove{}=P) -> 
	Bin0=write_int16(P#pk_PlayerTeleportMove.pos_x),
	Bin3=write_int16(P#pk_PlayerTeleportMove.pos_y),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_PlayerTeleportMove(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_PlayerTeleportMove{
		pos_x=D3,
		pos_y=D6
	},
	Left,
	Count6
	}.

write_PlayerTeleportMove_S2C(#pk_PlayerTeleportMove_S2C{}=P) -> 
	Bin0=write_int64(P#pk_PlayerTeleportMove_S2C.player_id),
	Bin3=write_int16(P#pk_PlayerTeleportMove_S2C.pos_x),
	Bin6=write_int16(P#pk_PlayerTeleportMove_S2C.pos_y),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_PlayerTeleportMove_S2C(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_PlayerTeleportMove_S2C{
		player_id=D3,
		pos_x=D6,
		pos_y=D9
	},
	Left,
	Count9
	}.

write_U2GS_leaveCampusBattle(#pk_U2GS_leaveCampusBattle{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_leaveCampusBattle.unUsed),
	<<Bin0/binary
	>>.

binary_read_U2GS_leaveCampusBattle(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_leaveCampusBattle{
		unUsed=D3
	},
	Left,
	Count3
	}.

write_U2GS_LeaveBattleScene(#pk_U2GS_LeaveBattleScene{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_LeaveBattleScene.unUsed),
	<<Bin0/binary
	>>.

binary_read_U2GS_LeaveBattleScene(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_LeaveBattleScene{
		unUsed=D3
	},
	Left,
	Count3
	}.

write_battleResult(#pk_battleResult{}=P) -> 
	Bin0=write_string(P#pk_battleResult.name),
	Bin3=write_int8(P#pk_battleResult.campus),
	Bin6=write_int16(P#pk_battleResult.killPlayerNum),
	Bin9=write_int16(P#pk_battleResult.beenKiiledNum),
	Bin12=write_int64(P#pk_battleResult.playerID),
	Bin15=write_int(P#pk_battleResult.harm),
	Bin18=write_int(P#pk_battleResult.harmed),
	<<Bin0/binary,Bin3/binary,Bin6/binary,Bin9/binary,Bin12/binary,Bin15/binary,Bin18/binary
	>>.

binary_read_battleResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_string(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int16(Count6,Bin0),
	Count9=C9+Count6,
	{D12,C12}=binary_read_int16(Count9,Bin0),
	Count12=C12+Count9,
	{D15,C15}=binary_read_int64(Count12,Bin0),
	Count15=C15+Count12,
	{D18,C18}=binary_read_int(Count15,Bin0),
	Count18=C18+Count15,
	{D21,C21}=binary_read_int(Count18,Bin0),
	Count21=C21+Count18,
	{_,Left} = split_binary(Bin0,Count21),
	{#pk_battleResult{
		name=D3,
		campus=D6,
		killPlayerNum=D9,
		beenKiiledNum=D12,
		playerID=D15,
		harm=D18,
		harmed=D21
	},
	Left,
	Count21
	}.

write_BattleResultList(#pk_BattleResultList{}=P) -> 
	Bin0=write_array(P#pk_BattleResultList.resultList,fun(X)-> write_battleResult(X) end),
	<<Bin0/binary
	>>.

binary_read_BattleResultList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_battleResult(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_BattleResultList{
		resultList=D3
	},
	Left,
	Count3
	}.

write_GS2U_BattleEnrollResult(#pk_GS2U_BattleEnrollResult{}=P) -> 
	Bin0=write_int8(P#pk_GS2U_BattleEnrollResult.enrollResult),
	Bin3=write_int16(P#pk_GS2U_BattleEnrollResult.mapDataID),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_BattleEnrollResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_BattleEnrollResult{
		enrollResult=D3,
		mapDataID=D6
	},
	Left,
	Count6
	}.

write_U2GS_requestEnrollInfo(#pk_U2GS_requestEnrollInfo{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_requestEnrollInfo.unUsed),
	<<Bin0/binary
	>>.

binary_read_U2GS_requestEnrollInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_requestEnrollInfo{
		unUsed=D3
	},
	Left,
	Count3
	}.

write_GS2U_sendEnrollInfo(#pk_GS2U_sendEnrollInfo{}=P) -> 
	Bin0=write_int16(P#pk_GS2U_sendEnrollInfo.enrollxuanzong),
	Bin3=write_int16(P#pk_GS2U_sendEnrollInfo.enrolltianji),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_sendEnrollInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_sendEnrollInfo{
		enrollxuanzong=D3,
		enrolltianji=D6
	},
	Left,
	Count6
	}.

write_GS2U_NowCanEnterBattle(#pk_GS2U_NowCanEnterBattle{}=P) -> 
	Bin0=write_int16(P#pk_GS2U_NowCanEnterBattle.battleID),
	<<Bin0/binary
	>>.

binary_read_GS2U_NowCanEnterBattle(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_NowCanEnterBattle{
		battleID=D3
	},
	Left,
	Count3
	}.

write_U2GS_SureEnterBattle(#pk_U2GS_SureEnterBattle{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_SureEnterBattle.unUsed),
	<<Bin0/binary
	>>.

binary_read_U2GS_SureEnterBattle(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_SureEnterBattle{
		unUsed=D3
	},
	Left,
	Count3
	}.

write_GS2U_EnterBattleResult(#pk_GS2U_EnterBattleResult{}=P) -> 
	Bin0=write_int8(P#pk_GS2U_EnterBattleResult.faileReason),
	<<Bin0/binary
	>>.

binary_read_GS2U_EnterBattleResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_EnterBattleResult{
		faileReason=D3
	},
	Left,
	Count3
	}.

write_GS2U_BattleScore(#pk_GS2U_BattleScore{}=P) -> 
	Bin0=write_int16(P#pk_GS2U_BattleScore.xuanzongScore),
	Bin3=write_int16(P#pk_GS2U_BattleScore.tianjiScore),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_BattleScore(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int16(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_BattleScore{
		xuanzongScore=D3,
		tianjiScore=D6
	},
	Left,
	Count6
	}.

write_U2GS_RequestBattleResultList(#pk_U2GS_RequestBattleResultList{}=P) -> 
	Bin0=write_int8(P#pk_U2GS_RequestBattleResultList.unUsed),
	<<Bin0/binary
	>>.

binary_read_U2GS_RequestBattleResultList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_RequestBattleResultList{
		unUsed=D3
	},
	Left,
	Count3
	}.

write_GS2U_BattleEnd(#pk_GS2U_BattleEnd{}=P) -> 
	Bin0=write_int8(P#pk_GS2U_BattleEnd.unUsed),
	<<Bin0/binary
	>>.

binary_read_GS2U_BattleEnd(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_BattleEnd{
		unUsed=D3
	},
	Left,
	Count3
	}.

write_GS2U_LeftOpenTime(#pk_GS2U_LeftOpenTime{}=P) -> 
	Bin0=write_int(P#pk_GS2U_LeftOpenTime.leftOpenTime),
	<<Bin0/binary
	>>.

binary_read_GS2U_LeftOpenTime(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_LeftOpenTime{
		leftOpenTime=D3
	},
	Left,
	Count3
	}.

write_GS2U_HeartBeatAck(#pk_GS2U_HeartBeatAck{}=P) -> 
	<<
	>>.

binary_read_GS2U_HeartBeatAck(Bin0)->
	Count0=0,
	{_,Left} = split_binary(Bin0,Count0),
	{#pk_GS2U_HeartBeatAck{
	},
	Left,
	Count0
	}.




send(Socket,#pk_PlayerBaseInfo{}=P) ->

	Bin = write_PlayerBaseInfo(P),
	sendPackage(Socket,?CMD_PlayerBaseInfo,Bin);




send(Socket,#pk_LookInfoPlayerList{}=P) ->

	Bin = write_LookInfoPlayerList(P),
	sendPackage(Socket,?CMD_LookInfoPlayerList,Bin);



send(Socket,#pk_LookInfoPetList{}=P) ->

	Bin = write_LookInfoPetList(P),
	sendPackage(Socket,?CMD_LookInfoPetList,Bin);



send(Socket,#pk_LookInfoMonsterList{}=P) ->

	Bin = write_LookInfoMonsterList(P),
	sendPackage(Socket,?CMD_LookInfoMonsterList,Bin);



send(Socket,#pk_LookInfoNpcList{}=P) ->

	Bin = write_LookInfoNpcList(P),
	sendPackage(Socket,?CMD_LookInfoNpcList,Bin);



send(Socket,#pk_LookInfoObjectList{}=P) ->

	Bin = write_LookInfoObjectList(P),
	sendPackage(Socket,?CMD_LookInfoObjectList,Bin);


send(Socket,#pk_ActorDisapearList{}=P) ->

	Bin = write_ActorDisapearList(P),
	sendPackage(Socket,?CMD_ActorDisapearList,Bin);





send(Socket,#pk_PlayerStopMove_S2C{}=P) ->

	Bin = write_PlayerStopMove_S2C(P),
	sendPackage(Socket,?CMD_PlayerStopMove_S2C,Bin);



send(Socket,#pk_PlayerMoveInfo{}=P) ->

	Bin = write_PlayerMoveInfo(P),
	sendPackage(Socket,?CMD_PlayerMoveInfo,Bin);



send(Socket,#pk_ChangeFlyState_S2C{}=P) ->

	Bin = write_ChangeFlyState_S2C(P),
	sendPackage(Socket,?CMD_ChangeFlyState_S2C,Bin);


send(Socket,#pk_MonsterMoveInfo{}=P) ->

	Bin = write_MonsterMoveInfo(P),
	sendPackage(Socket,?CMD_MonsterMoveInfo,Bin);


send(Socket,#pk_MonsterStopMove{}=P) ->

	Bin = write_MonsterStopMove(P),
	sendPackage(Socket,?CMD_MonsterStopMove,Bin);


send(Socket,#pk_PetMoveInfo{}=P) ->

	Bin = write_PetMoveInfo(P),
	sendPackage(Socket,?CMD_PetMoveInfo,Bin);


send(Socket,#pk_PetStopMove{}=P) ->

	Bin = write_PetStopMove(P),
	sendPackage(Socket,?CMD_PetStopMove,Bin);


send(Socket,#pk_ChangeMap{}=P) ->

	Bin = write_ChangeMap(P),
	sendPackage(Socket,?CMD_ChangeMap,Bin);


send(Socket,#pk_CollectFail{}=P) ->

	Bin = write_CollectFail(P),
	sendPackage(Socket,?CMD_CollectFail,Bin);




send(Socket,#pk_PlayerPropertyChanged{}=P) ->

	Bin = write_PlayerPropertyChanged(P),
	sendPackage(Socket,?CMD_PlayerPropertyChanged,Bin);


send(Socket,#pk_PlayerMoneyChanged{}=P) ->

	Bin = write_PlayerMoneyChanged(P),
	sendPackage(Socket,?CMD_PlayerMoneyChanged,Bin);


send(Socket,#pk_PlayerKickOuted{}=P) ->

	Bin = write_PlayerKickOuted(P),
	sendPackage(Socket,?CMD_PlayerKickOuted,Bin);


send(Socket,#pk_ActorStateFlagSet{}=P) ->

	Bin = write_ActorStateFlagSet(P),
	sendPackage(Socket,?CMD_ActorStateFlagSet,Bin);


send(Socket,#pk_ActorStateFlagSet_Broad{}=P) ->

	Bin = write_ActorStateFlagSet_Broad(P),
	sendPackage(Socket,?CMD_ActorStateFlagSet_Broad,Bin);



send(Socket,#pk_PlayerSkillInitInfo{}=P) ->

	Bin = write_PlayerSkillInitInfo(P),
	sendPackage(Socket,?CMD_PlayerSkillInitInfo,Bin);



send(Socket,#pk_GS2U_StudySkillResult{}=P) ->

	Bin = write_GS2U_StudySkillResult(P),
	sendPackage(Socket,?CMD_GS2U_StudySkillResult,Bin);



send(Socket,#pk_activeBranchIDResult{}=P) ->

	Bin = write_activeBranchIDResult(P),
	sendPackage(Socket,?CMD_activeBranchIDResult,Bin);



send(Socket,#pk_GS2U_AddSkillBranchAck{}=P) ->

	Bin = write_GS2U_AddSkillBranchAck(P),
	sendPackage(Socket,?CMD_GS2U_AddSkillBranchAck,Bin);



send(Socket,#pk_GS2U_UseSkillToObject{}=P) ->

	Bin = write_GS2U_UseSkillToObject(P),
	sendPackage(Socket,?CMD_GS2U_UseSkillToObject,Bin);


send(Socket,#pk_GS2U_UseSkillToPos{}=P) ->

	Bin = write_GS2U_UseSkillToPos(P),
	sendPackage(Socket,?CMD_GS2U_UseSkillToPos,Bin);


send(Socket,#pk_GS2U_AttackDamage{}=P) ->

	Bin = write_GS2U_AttackDamage(P),
	sendPackage(Socket,?CMD_GS2U_AttackDamage,Bin);


send(Socket,#pk_GS2U_CharactorDead{}=P) ->

	Bin = write_GS2U_CharactorDead(P),
	sendPackage(Socket,?CMD_GS2U_CharactorDead,Bin);


send(Socket,#pk_GS2U_AttackMiss{}=P) ->

	Bin = write_GS2U_AttackMiss(P),
	sendPackage(Socket,?CMD_GS2U_AttackMiss,Bin);


send(Socket,#pk_GS2U_AttackDodge{}=P) ->

	Bin = write_GS2U_AttackDodge(P),
	sendPackage(Socket,?CMD_GS2U_AttackDodge,Bin);


send(Socket,#pk_GS2U_AttackCrit{}=P) ->

	Bin = write_GS2U_AttackCrit(P),
	sendPackage(Socket,?CMD_GS2U_AttackCrit,Bin);


send(Socket,#pk_GS2U_AttackBlock{}=P) ->

	Bin = write_GS2U_AttackBlock(P),
	sendPackage(Socket,?CMD_GS2U_AttackBlock,Bin);


send(Socket,#pk_PlayerAllShortcut{}=P) ->

	Bin = write_PlayerAllShortcut(P),
	sendPackage(Socket,?CMD_PlayerAllShortcut,Bin);



send(Socket,#pk_PlayerEXPChanged{}=P) ->

	Bin = write_PlayerEXPChanged(P),
	sendPackage(Socket,?CMD_PlayerEXPChanged,Bin);


send(Socket,#pk_ActorLifeUpdate{}=P) ->

	Bin = write_ActorLifeUpdate(P),
	sendPackage(Socket,?CMD_ActorLifeUpdate,Bin);


send(Socket,#pk_ActorMoveSpeedUpdate{}=P) ->

	Bin = write_ActorMoveSpeedUpdate(P),
	sendPackage(Socket,?CMD_ActorMoveSpeedUpdate,Bin);


send(Socket,#pk_PlayerCombatIDInit{}=P) ->

	Bin = write_PlayerCombatIDInit(P),
	sendPackage(Socket,?CMD_PlayerCombatIDInit,Bin);


send(Socket,#pk_GS2U_CharactorRevived{}=P) ->

	Bin = write_GS2U_CharactorRevived(P),
	sendPackage(Socket,?CMD_GS2U_CharactorRevived,Bin);





send(Socket,#pk_GS2U_HeroPropertyResult{}=P) ->

	Bin = write_GS2U_HeroPropertyResult(P),
	sendPackage(Socket,?CMD_GS2U_HeroPropertyResult,Bin);



send(Socket,#pk_PlayerBagInit{}=P) ->

	Bin = write_PlayerBagInit(P),
	sendPackage(Socket,?CMD_PlayerBagInit,Bin);


send(Socket,#pk_PlayerGetItem{}=P) ->

	Bin = write_PlayerGetItem(P),
	sendPackage(Socket,?CMD_PlayerGetItem,Bin);


send(Socket,#pk_PlayerDestroyItem{}=P) ->

	Bin = write_PlayerDestroyItem(P),
	sendPackage(Socket,?CMD_PlayerDestroyItem,Bin);


send(Socket,#pk_PlayerItemLocationCellChanged{}=P) ->

	Bin = write_PlayerItemLocationCellChanged(P),
	sendPackage(Socket,?CMD_PlayerItemLocationCellChanged,Bin);




send(Socket,#pk_PlayerItemAmountChanged{}=P) ->

	Bin = write_PlayerItemAmountChanged(P),
	sendPackage(Socket,?CMD_PlayerItemAmountChanged,Bin);


send(Socket,#pk_PlayerItemParamChanged{}=P) ->

	Bin = write_PlayerItemParamChanged(P),
	sendPackage(Socket,?CMD_PlayerItemParamChanged,Bin);




send(Socket,#pk_PlayerBagOrderResult{}=P) ->

	Bin = write_PlayerBagOrderResult(P),
	sendPackage(Socket,?CMD_PlayerBagOrderResult,Bin);



send(Socket,#pk_PlayerUseItemResult{}=P) ->

	Bin = write_PlayerUseItemResult(P),
	sendPackage(Socket,?CMD_PlayerUseItemResult,Bin);




send(Socket,#pk_PlayerStorageBagPassWordChanged{}=P) ->

	Bin = write_PlayerStorageBagPassWordChanged(P),
	sendPackage(Socket,?CMD_PlayerStorageBagPassWordChanged,Bin);


send(Socket,#pk_PlayerBagCellEnableChanged{}=P) ->

	Bin = write_PlayerBagCellEnableChanged(P),
	sendPackage(Socket,?CMD_PlayerBagCellEnableChanged,Bin);










send(Socket,#pk_PlayerUnlockTimesChanged{}=P) ->

	Bin = write_PlayerUnlockTimesChanged(P),
	sendPackage(Socket,?CMD_PlayerUnlockTimesChanged,Bin);



send(Socket,#pk_ItemBagCellSet{}=P) ->

	Bin = write_ItemBagCellSet(P),
	sendPackage(Socket,?CMD_ItemBagCellSet,Bin);




send(Socket,#pk_GetNpcStoreItemListAck{}=P) ->

	Bin = write_GetNpcStoreItemListAck(P),
	sendPackage(Socket,?CMD_GetNpcStoreItemListAck,Bin);



send(Socket,#pk_BuyItemAck{}=P) ->

	Bin = write_BuyItemAck(P),
	sendPackage(Socket,?CMD_BuyItemAck,Bin);




send(Socket,#pk_GetNpcStoreBackBuyItemListAck{}=P) ->

	Bin = write_GetNpcStoreBackBuyItemListAck(P),
	sendPackage(Socket,?CMD_GetNpcStoreBackBuyItemListAck,Bin);




send(Socket,#pk_PlayerEquipInit{}=P) ->

	Bin = write_PlayerEquipInit(P),
	sendPackage(Socket,?CMD_PlayerEquipInit,Bin);



send(Socket,#pk_PlayerEquipActiveResult{}=P) ->

	Bin = write_PlayerEquipActiveResult(P),
	sendPackage(Socket,?CMD_PlayerEquipActiveResult,Bin);



send(Socket,#pk_PlayerEquipPutOnResult{}=P) ->

	Bin = write_PlayerEquipPutOnResult(P),
	sendPackage(Socket,?CMD_PlayerEquipPutOnResult,Bin);



send(Socket,#pk_QueryPlayerEquipResult{}=P) ->

	Bin = write_QueryPlayerEquipResult(P),
	sendPackage(Socket,?CMD_QueryPlayerEquipResult,Bin);



send(Socket,#pk_StudyResult{}=P) ->

	Bin = write_StudyResult(P),
	sendPackage(Socket,?CMD_StudyResult,Bin);



send(Socket,#pk_RebornAck{}=P) ->

	Bin = write_RebornAck(P),
	sendPackage(Socket,?CMD_RebornAck,Bin);


send(Socket,#pk_Chat2Player{}=P) ->

	Bin = write_Chat2Player(P),
	sendPackage(Socket,?CMD_Chat2Player,Bin);



send(Socket,#pk_Chat_Error_Result{}=P) ->

	Bin = write_Chat_Error_Result(P),
	sendPackage(Socket,?CMD_Chat_Error_Result,Bin);



send(Socket,#pk_RequestSendMailAck{}=P) ->

	Bin = write_RequestSendMailAck(P),
	sendPackage(Socket,?CMD_RequestSendMailAck,Bin);




send(Socket,#pk_RequestUnReadMailAck{}=P) ->

	Bin = write_RequestUnReadMailAck(P),
	sendPackage(Socket,?CMD_RequestUnReadMailAck,Bin);




send(Socket,#pk_RequestMailListAck{}=P) ->

	Bin = write_RequestMailListAck(P),
	sendPackage(Socket,?CMD_RequestMailListAck,Bin);



send(Socket,#pk_RequestMailItemInfoAck{}=P) ->

	Bin = write_RequestMailItemInfoAck(P),
	sendPackage(Socket,?CMD_RequestMailItemInfoAck,Bin);



send(Socket,#pk_RequestAcceptMailItemAck{}=P) ->

	Bin = write_RequestAcceptMailItemAck(P),
	sendPackage(Socket,?CMD_RequestAcceptMailItemAck,Bin);




send(Socket,#pk_InformNewMail{}=P) ->

	Bin = write_InformNewMail(P),
	sendPackage(Socket,?CMD_InformNewMail,Bin);








send(Socket,#pk_GS2U_LoginResult{}=P) ->

	Bin = write_GS2U_LoginResult(P),
	sendPackage(Socket,?CMD_GS2U_LoginResult,Bin);


send(Socket,#pk_GS2U_SelPlayerResult{}=P) ->

	Bin = write_GS2U_SelPlayerResult(P),
	sendPackage(Socket,?CMD_GS2U_SelPlayerResult,Bin);



send(Socket,#pk_GS2U_UserPlayerList{}=P) ->

	Bin = write_GS2U_UserPlayerList(P),
	sendPackage(Socket,?CMD_GS2U_UserPlayerList,Bin);


send(Socket,#pk_GS2U_CreatePlayerResult{}=P) ->

	Bin = write_GS2U_CreatePlayerResult(P),
	sendPackage(Socket,?CMD_GS2U_CreatePlayerResult,Bin);


send(Socket,#pk_GS2U_DeletePlayerResult{}=P) ->

	Bin = write_GS2U_DeletePlayerResult(P),
	sendPackage(Socket,?CMD_GS2U_DeletePlayerResult,Bin);



send(Socket,#pk_ConSales_GroundingItem_Result{}=P) ->

	Bin = write_ConSales_GroundingItem_Result(P),
	sendPackage(Socket,?CMD_ConSales_GroundingItem_Result,Bin);



send(Socket,#pk_ConSales_TakeDown_Result{}=P) ->

	Bin = write_ConSales_TakeDown_Result(P),
	sendPackage(Socket,?CMD_ConSales_TakeDown_Result,Bin);



send(Socket,#pk_ConSales_BuyItem_Result{}=P) ->

	Bin = write_ConSales_BuyItem_Result(P),
	sendPackage(Socket,?CMD_ConSales_BuyItem_Result,Bin);




send(Socket,#pk_ConSales_FindItems_Result{}=P) ->

	Bin = write_ConSales_FindItems_Result(P),
	sendPackage(Socket,?CMD_ConSales_FindItems_Result,Bin);





send(Socket,#pk_ConSales_GetSelfSell_Result{}=P) ->

	Bin = write_ConSales_GetSelfSell_Result(P),
	sendPackage(Socket,?CMD_ConSales_GetSelfSell_Result,Bin);


send(Socket,#pk_TradeAsk{}=P) ->

	Bin = write_TradeAsk(P),
	sendPackage(Socket,?CMD_TradeAsk,Bin);


send(Socket,#pk_TradeAskResult{}=P) ->

	Bin = write_TradeAskResult(P),
	sendPackage(Socket,?CMD_TradeAskResult,Bin);


send(Socket,#pk_CreateTrade{}=P) ->

	Bin = write_CreateTrade(P),
	sendPackage(Socket,?CMD_CreateTrade,Bin);



send(Socket,#pk_TradeInputItemResult_S2C{}=P) ->

	Bin = write_TradeInputItemResult_S2C(P),
	sendPackage(Socket,?CMD_TradeInputItemResult_S2C,Bin);


send(Socket,#pk_TradeInputItem_S2C{}=P) ->

	Bin = write_TradeInputItem_S2C(P),
	sendPackage(Socket,?CMD_TradeInputItem_S2C,Bin);



send(Socket,#pk_TradeTakeOutItemResult_S2C{}=P) ->

	Bin = write_TradeTakeOutItemResult_S2C(P),
	sendPackage(Socket,?CMD_TradeTakeOutItemResult_S2C,Bin);


send(Socket,#pk_TradeTakeOutItem_S2C{}=P) ->

	Bin = write_TradeTakeOutItem_S2C(P),
	sendPackage(Socket,?CMD_TradeTakeOutItem_S2C,Bin);



send(Socket,#pk_TradeChangeMoneyResult_S2C{}=P) ->

	Bin = write_TradeChangeMoneyResult_S2C(P),
	sendPackage(Socket,?CMD_TradeChangeMoneyResult_S2C,Bin);


send(Socket,#pk_TradeChangeMoney_S2C{}=P) ->

	Bin = write_TradeChangeMoney_S2C(P),
	sendPackage(Socket,?CMD_TradeChangeMoney_S2C,Bin);



send(Socket,#pk_TradeLock_S2C{}=P) ->

	Bin = write_TradeLock_S2C(P),
	sendPackage(Socket,?CMD_TradeLock_S2C,Bin);


send(Socket,#pk_CancelTrade_S2C{}=P) ->

	Bin = write_CancelTrade_S2C(P),
	sendPackage(Socket,?CMD_CancelTrade_S2C,Bin);




send(Socket,#pk_TradeAffirm_S2C{}=P) ->

	Bin = write_TradeAffirm_S2C(P),
	sendPackage(Socket,?CMD_TradeAffirm_S2C,Bin);




send(Socket,#pk_PlayerPetInfo{}=P) ->

	Bin = write_PlayerPetInfo(P),
	sendPackage(Socket,?CMD_PlayerPetInfo,Bin);


send(Socket,#pk_UpdatePetProerty{}=P) ->

	Bin = write_UpdatePetProerty(P),
	sendPackage(Socket,?CMD_UpdatePetProerty,Bin);


send(Socket,#pk_DelPet{}=P) ->

	Bin = write_DelPet(P),
	sendPackage(Socket,?CMD_DelPet,Bin);



send(Socket,#pk_PetOutFight_Result{}=P) ->

	Bin = write_PetOutFight_Result(P),
	sendPackage(Socket,?CMD_PetOutFight_Result,Bin);



send(Socket,#pk_PetTakeRest_Result{}=P) ->

	Bin = write_PetTakeRest_Result(P),
	sendPackage(Socket,?CMD_PetTakeRest_Result,Bin);



send(Socket,#pk_PetFreeCaptiveAnimals_Result{}=P) ->

	Bin = write_PetFreeCaptiveAnimals_Result(P),
	sendPackage(Socket,?CMD_PetFreeCaptiveAnimals_Result,Bin);



send(Socket,#pk_PetCompoundModel_Result{}=P) ->

	Bin = write_PetCompoundModel_Result(P),
	sendPackage(Socket,?CMD_PetCompoundModel_Result,Bin);



send(Socket,#pk_PetWashGrowUpValue_Result{}=P) ->

	Bin = write_PetWashGrowUpValue_Result(P),
	sendPackage(Socket,?CMD_PetWashGrowUpValue_Result,Bin);



send(Socket,#pk_PetReplaceGrowUpValue_Result{}=P) ->

	Bin = write_PetReplaceGrowUpValue_Result(P),
	sendPackage(Socket,?CMD_PetReplaceGrowUpValue_Result,Bin);



send(Socket,#pk_PetIntensifySoul_Result{}=P) ->

	Bin = write_PetIntensifySoul_Result(P),
	sendPackage(Socket,?CMD_PetIntensifySoul_Result,Bin);



send(Socket,#pk_PetOneKeyIntensifySoul_Result{}=P) ->

	Bin = write_PetOneKeyIntensifySoul_Result(P),
	sendPackage(Socket,?CMD_PetOneKeyIntensifySoul_Result,Bin);



send(Socket,#pk_PetFuse_Result{}=P) ->

	Bin = write_PetFuse_Result(P),
	sendPackage(Socket,?CMD_PetFuse_Result,Bin);


send(Socket,#pk_PetJumpTo{}=P) ->

	Bin = write_PetJumpTo(P),
	sendPackage(Socket,?CMD_PetJumpTo,Bin);


send(Socket,#pk_ActorSetPos{}=P) ->

	Bin = write_ActorSetPos(P),
	sendPackage(Socket,?CMD_ActorSetPos,Bin);


send(Socket,#pk_PetTakeBack{}=P) ->

	Bin = write_PetTakeBack(P),
	sendPackage(Socket,?CMD_PetTakeBack,Bin);


send(Socket,#pk_ChangePetAIState{}=P) ->

	Bin = write_ChangePetAIState(P),
	sendPackage(Socket,?CMD_ChangePetAIState,Bin);


send(Socket,#pk_PetExpChanged{}=P) ->

	Bin = write_PetExpChanged(P),
	sendPackage(Socket,?CMD_PetExpChanged,Bin);



send(Socket,#pk_PetLearnSkill_Result{}=P) ->

	Bin = write_PetLearnSkill_Result(P),
	sendPackage(Socket,?CMD_PetLearnSkill_Result,Bin);



send(Socket,#pk_PetDelSkill_Result{}=P) ->

	Bin = write_PetDelSkill_Result(P),
	sendPackage(Socket,?CMD_PetDelSkill_Result,Bin);



send(Socket,#pk_PetUnLoctSkillCell_Result{}=P) ->

	Bin = write_PetUnLoctSkillCell_Result(P),
	sendPackage(Socket,?CMD_PetUnLoctSkillCell_Result,Bin);



send(Socket,#pk_PetSkillSealAhs_Result{}=P) ->

	Bin = write_PetSkillSealAhs_Result(P),
	sendPackage(Socket,?CMD_PetSkillSealAhs_Result,Bin);


send(Socket,#pk_PetUpdateSealAhsStore{}=P) ->

	Bin = write_PetUpdateSealAhsStore(P),
	sendPackage(Socket,?CMD_PetUpdateSealAhsStore,Bin);



send(Socket,#pk_PetlearnSealAhsSkill_Result{}=P) ->

	Bin = write_PetlearnSealAhsSkill_Result(P),
	sendPackage(Socket,?CMD_PetlearnSealAhsSkill_Result,Bin);



send(Socket,#pk_GetPlayerEquipEnhanceByTypeBack{}=P) ->

	Bin = write_GetPlayerEquipEnhanceByTypeBack(P),
	sendPackage(Socket,?CMD_GetPlayerEquipEnhanceByTypeBack,Bin);



send(Socket,#pk_EquipEnhanceByTypeBack{}=P) ->

	Bin = write_EquipEnhanceByTypeBack(P),
	sendPackage(Socket,?CMD_EquipEnhanceByTypeBack,Bin);



send(Socket,#pk_EquipOnceEnhanceByTypeBack{}=P) ->

	Bin = write_EquipOnceEnhanceByTypeBack(P),
	sendPackage(Socket,?CMD_EquipOnceEnhanceByTypeBack,Bin);



send(Socket,#pk_GetPlayerEquipQualityByTypeBack{}=P) ->

	Bin = write_GetPlayerEquipQualityByTypeBack(P),
	sendPackage(Socket,?CMD_GetPlayerEquipQualityByTypeBack,Bin);



send(Socket,#pk_EquipQualityUPByTypeBack{}=P) ->

	Bin = write_EquipQualityUPByTypeBack(P),
	sendPackage(Socket,?CMD_EquipQualityUPByTypeBack,Bin);



send(Socket,#pk_GetEquipOldPropertyByType{}=P) ->

	Bin = write_GetEquipOldPropertyByType(P),
	sendPackage(Socket,?CMD_GetEquipOldPropertyByType,Bin);



send(Socket,#pk_GetEquipNewPropertyByType{}=P) ->

	Bin = write_GetEquipNewPropertyByType(P),
	sendPackage(Socket,?CMD_GetEquipNewPropertyByType,Bin);



send(Socket,#pk_RequestEquipChangeAddSavePropertyByType{}=P) ->

	Bin = write_RequestEquipChangeAddSavePropertyByType(P),
	sendPackage(Socket,?CMD_RequestEquipChangeAddSavePropertyByType,Bin);



send(Socket,#pk_GS2U_EnterMapResult{}=P) ->

	Bin = write_GS2U_EnterMapResult(P),
	sendPackage(Socket,?CMD_GS2U_EnterMapResult,Bin);




send(Socket,#pk_GS2U_MyCopyMapCDInfo{}=P) ->

	Bin = write_GS2U_MyCopyMapCDInfo(P),
	sendPackage(Socket,?CMD_GS2U_MyCopyMapCDInfo,Bin);


send(Socket,#pk_AddBuff{}=P) ->

	Bin = write_AddBuff(P),
	sendPackage(Socket,?CMD_AddBuff,Bin);


send(Socket,#pk_DelBuff{}=P) ->

	Bin = write_DelBuff(P),
	sendPackage(Socket,?CMD_DelBuff,Bin);


send(Socket,#pk_UpdateBuff{}=P) ->

	Bin = write_UpdateBuff(P),
	sendPackage(Socket,?CMD_UpdateBuff,Bin);


send(Socket,#pk_HeroBuffList{}=P) ->

	Bin = write_HeroBuffList(P),
	sendPackage(Socket,?CMD_HeroBuffList,Bin);





send(Socket,#pk_GS2U_FastTeamCopyMapResult{}=P) ->

	Bin = write_GS2U_FastTeamCopyMapResult(P),
	sendPackage(Socket,?CMD_GS2U_FastTeamCopyMapResult,Bin);


send(Socket,#pk_GS2U_TeamCopyMapQuery{}=P) ->

	Bin = write_GS2U_TeamCopyMapQuery(P),
	sendPackage(Socket,?CMD_GS2U_TeamCopyMapQuery,Bin);



send(Socket,#pk_GS2U_AddOrRemoveHatred{}=P) ->

	Bin = write_GS2U_AddOrRemoveHatred(P),
	sendPackage(Socket,?CMD_GS2U_AddOrRemoveHatred,Bin);



send(Socket,#pk_GS2U_QieCuoInviteQuery{}=P) ->

	Bin = write_GS2U_QieCuoInviteQuery(P),
	sendPackage(Socket,?CMD_GS2U_QieCuoInviteQuery,Bin);



send(Socket,#pk_GS2U_QieCuoInviteResult{}=P) ->

	Bin = write_GS2U_QieCuoInviteResult(P),
	sendPackage(Socket,?CMD_GS2U_QieCuoInviteResult,Bin);


send(Socket,#pk_GS2U_QieCuoResult{}=P) ->

	Bin = write_GS2U_QieCuoResult(P),
	sendPackage(Socket,?CMD_GS2U_QieCuoResult,Bin);



send(Socket,#pk_GS2U_PK_KillOpenResult{}=P) ->

	Bin = write_GS2U_PK_KillOpenResult(P),
	sendPackage(Socket,?CMD_GS2U_PK_KillOpenResult,Bin);


send(Socket,#pk_GS2U_Player_ChangeEquipResult{}=P) ->

	Bin = write_GS2U_Player_ChangeEquipResult(P),
	sendPackage(Socket,?CMD_GS2U_Player_ChangeEquipResult,Bin);


send(Socket,#pk_SysMessage{}=P) ->

	Bin = write_SysMessage(P),
	sendPackage(Socket,?CMD_SysMessage,Bin);


send(Socket,#pk_GS2U_AddLifeByItem{}=P) ->

	Bin = write_GS2U_AddLifeByItem(P),
	sendPackage(Socket,?CMD_GS2U_AddLifeByItem,Bin);


send(Socket,#pk_GS2U_AddLifeBySkill{}=P) ->

	Bin = write_GS2U_AddLifeBySkill(P),
	sendPackage(Socket,?CMD_GS2U_AddLifeBySkill,Bin);



send(Socket,#pk_GS2U_PlayerItemCDInit{}=P) ->

	Bin = write_GS2U_PlayerItemCDInit(P),
	sendPackage(Socket,?CMD_GS2U_PlayerItemCDInit,Bin);


send(Socket,#pk_GS2U_PlayerItemCDUpdate{}=P) ->

	Bin = write_GS2U_PlayerItemCDUpdate(P),
	sendPackage(Socket,?CMD_GS2U_PlayerItemCDUpdate,Bin);



send(Socket,#pk_GS2U_ItemDailyCount{}=P) ->

	Bin = write_GS2U_ItemDailyCount(P),
	sendPackage(Socket,?CMD_GS2U_ItemDailyCount,Bin);



send(Socket,#pk_GS2U_PlayerSigninInfo{}=P) ->

	Bin = write_GS2U_PlayerSigninInfo(P),
	sendPackage(Socket,?CMD_GS2U_PlayerSigninInfo,Bin);



send(Socket,#pk_GS2U_PlayerSignInResult{}=P) ->

	Bin = write_GS2U_PlayerSignInResult(P),
	sendPackage(Socket,?CMD_GS2U_PlayerSignInResult,Bin);



send(Socket,#pk_PetChangeModel{}=P) ->

	Bin = write_PetChangeModel(P),
	sendPackage(Socket,?CMD_PetChangeModel,Bin);


send(Socket,#pk_PetChangeName{}=P) ->

	Bin = write_PetChangeName(P),
	sendPackage(Socket,?CMD_PetChangeName,Bin);


send(Socket,#pk_PetChangeName_Result{}=P) ->

	Bin = write_PetChangeName_Result(P),
	sendPackage(Socket,?CMD_PetChangeName_Result,Bin);




send(Socket,#pk_BazzarPriceItemList{}=P) ->

	Bin = write_BazzarPriceItemList(P),
	sendPackage(Socket,?CMD_BazzarPriceItemList,Bin);


send(Socket,#pk_BazzarItemList{}=P) ->

	Bin = write_BazzarItemList(P),
	sendPackage(Socket,?CMD_BazzarItemList,Bin);


send(Socket,#pk_BazzarItemUpdate{}=P) ->

	Bin = write_BazzarItemUpdate(P),
	sendPackage(Socket,?CMD_BazzarItemUpdate,Bin);



send(Socket,#pk_BazzarBuyResult{}=P) ->

	Bin = write_BazzarBuyResult(P),
	sendPackage(Socket,?CMD_BazzarBuyResult,Bin);


send(Socket,#pk_PlayerBagCellOpenResult{}=P) ->

	Bin = write_PlayerBagCellOpenResult(P),
	sendPackage(Socket,?CMD_PlayerBagCellOpenResult,Bin);



send(Socket,#pk_GS2U_RemoveSkillBranch{}=P) ->

	Bin = write_GS2U_RemoveSkillBranch(P),
	sendPackage(Socket,?CMD_GS2U_RemoveSkillBranch,Bin);




send(Socket,#pk_U2GS_CopyMapAddActiveCountResult{}=P) ->

	Bin = write_U2GS_CopyMapAddActiveCountResult(P),
	sendPackage(Socket,?CMD_U2GS_CopyMapAddActiveCountResult,Bin);


send(Socket,#pk_GS2U_CurConvoyInfo{}=P) ->

	Bin = write_GS2U_CurConvoyInfo(P),
	sendPackage(Socket,?CMD_GS2U_CurConvoyInfo,Bin);



send(Socket,#pk_GS2U_CarriageQualityRefreshResult{}=P) ->

	Bin = write_GS2U_CarriageQualityRefreshResult(P),
	sendPackage(Socket,?CMD_GS2U_CarriageQualityRefreshResult,Bin);



send(Socket,#pk_GS2U_ConvoyCDResult{}=P) ->

	Bin = write_GS2U_ConvoyCDResult(P),
	sendPackage(Socket,?CMD_GS2U_ConvoyCDResult,Bin);



send(Socket,#pk_GS2U_BeginConvoyResult{}=P) ->

	Bin = write_GS2U_BeginConvoyResult(P),
	sendPackage(Socket,?CMD_GS2U_BeginConvoyResult,Bin);


send(Socket,#pk_GS2U_FinishConvoyResult{}=P) ->

	Bin = write_GS2U_FinishConvoyResult(P),
	sendPackage(Socket,?CMD_GS2U_FinishConvoyResult,Bin);


send(Socket,#pk_GS2U_GiveUpConvoyResult{}=P) ->

	Bin = write_GS2U_GiveUpConvoyResult(P),
	sendPackage(Socket,?CMD_GS2U_GiveUpConvoyResult,Bin);


send(Socket,#pk_GS2U_ConvoyNoticeTimerResult{}=P) ->

	Bin = write_GS2U_ConvoyNoticeTimerResult(P),
	sendPackage(Socket,?CMD_GS2U_ConvoyNoticeTimerResult,Bin);


send(Socket,#pk_GS2U_ConvoyState{}=P) ->

	Bin = write_GS2U_ConvoyState(P),
	sendPackage(Socket,?CMD_GS2U_ConvoyState,Bin);


send(Socket,#pk_GSWithU_GameSetMenu{}=P) ->

	Bin = write_GSWithU_GameSetMenu(P),
	sendPackage(Socket,?CMD_GSWithU_GameSetMenu,Bin);



send(Socket,#pk_U2GS_RequestRechargeGift_Ret{}=P) ->

	Bin = write_U2GS_RequestRechargeGift_Ret(P),
	sendPackage(Socket,?CMD_U2GS_RequestRechargeGift_Ret,Bin);



send(Socket,#pk_U2GS_RequestPlayerFightingCapacity_Ret{}=P) ->

	Bin = write_U2GS_RequestPlayerFightingCapacity_Ret(P),
	sendPackage(Socket,?CMD_U2GS_RequestPlayerFightingCapacity_Ret,Bin);



send(Socket,#pk_U2GS_RequestPetFightingCapacity_Ret{}=P) ->

	Bin = write_U2GS_RequestPetFightingCapacity_Ret(P),
	sendPackage(Socket,?CMD_U2GS_RequestPetFightingCapacity_Ret,Bin);



send(Socket,#pk_U2GS_RequestMountFightingCapacity_Ret{}=P) ->

	Bin = write_U2GS_RequestMountFightingCapacity_Ret(P),
	sendPackage(Socket,?CMD_U2GS_RequestMountFightingCapacity_Ret,Bin);



send(Socket,#pk_GS2U_VariantDataSet{}=P) ->

	Bin = write_GS2U_VariantDataSet(P),
	sendPackage(Socket,?CMD_GS2U_VariantDataSet,Bin);



send(Socket,#pk_GS2U_RankList{}=P) ->

	Bin = write_GS2U_RankList(P),
	sendPackage(Socket,?CMD_GS2U_RankList,Bin);


send(Socket,#pk_GS2U_WordBossCmd{}=P) ->

	Bin = write_GS2U_WordBossCmd(P),
	sendPackage(Socket,?CMD_GS2U_WordBossCmd,Bin);



send(Socket,#pk_GS2U_ChangePlayerNameResult{}=P) ->

	Bin = write_GS2U_ChangePlayerNameResult(P),
	sendPackage(Socket,?CMD_GS2U_ChangePlayerNameResult,Bin);



send(Socket,#pk_GS2U_SetProtectPwdResult{}=P) ->

	Bin = write_GS2U_SetProtectPwdResult(P),
	sendPackage(Socket,?CMD_GS2U_SetProtectPwdResult,Bin);



send(Socket,#pk_GS2U_CopyProgressUpdate{}=P) ->

	Bin = write_GS2U_CopyProgressUpdate(P),
	sendPackage(Socket,?CMD_GS2U_CopyProgressUpdate,Bin);




send(Socket,#pk_U2GS_StartGiveGoldResult{}=P) ->

	Bin = write_U2GS_StartGiveGoldResult(P),
	sendPackage(Socket,?CMD_U2GS_StartGiveGoldResult,Bin);


send(Socket,#pk_U2GS_GoldLineInfo{}=P) ->

	Bin = write_U2GS_GoldLineInfo(P),
	sendPackage(Socket,?CMD_U2GS_GoldLineInfo,Bin);


send(Socket,#pk_U2GS_GoldResetTimer{}=P) ->

	Bin = write_U2GS_GoldResetTimer(P),
	sendPackage(Socket,?CMD_U2GS_GoldResetTimer,Bin);


send(Socket,#pk_GS2U_CopyMapSAData{}=P) ->

	Bin = write_GS2U_CopyMapSAData(P),
	sendPackage(Socket,?CMD_GS2U_CopyMapSAData,Bin);



send(Socket,#pk_GetTokenStoreItemListAck{}=P) ->

	Bin = write_GetTokenStoreItemListAck(P),
	sendPackage(Socket,?CMD_GetTokenStoreItemListAck,Bin);



send(Socket,#pk_RequestLookPlayer_Result{}=P) ->

	Bin = write_RequestLookPlayer_Result(P),
	sendPackage(Socket,?CMD_RequestLookPlayer_Result,Bin);


send(Socket,#pk_RequestLookPlayerFailed_Result{}=P) ->

	Bin = write_RequestLookPlayerFailed_Result(P),
	sendPackage(Socket,?CMD_RequestLookPlayerFailed_Result,Bin);





send(Socket,#pk_GS2U_ActiveCount{}=P) ->

	Bin = write_GS2U_ActiveCount(P),
	sendPackage(Socket,?CMD_GS2U_ActiveCount,Bin);



send(Socket,#pk_GS2U_WhetherTransferOldRecharge{}=P) ->

	Bin = write_GS2U_WhetherTransferOldRecharge(P),
	sendPackage(Socket,?CMD_GS2U_WhetherTransferOldRecharge,Bin);



send(Socket,#pk_GS2U_TransferOldRechargeResult{}=P) ->

	Bin = write_GS2U_TransferOldRechargeResult(P),
	sendPackage(Socket,?CMD_GS2U_TransferOldRechargeResult,Bin);


send(Socket,#pk_PlayerEquipActiveFailReason{}=P) ->

	Bin = write_PlayerEquipActiveFailReason(P),
	sendPackage(Socket,?CMD_PlayerEquipActiveFailReason,Bin);


send(Socket,#pk_PlayerEquipMinLevelChange{}=P) ->

	Bin = write_PlayerEquipMinLevelChange(P),
	sendPackage(Socket,?CMD_PlayerEquipMinLevelChange,Bin);



send(Socket,#pk_PlayerImportPassWordResult{}=P) ->

	Bin = write_PlayerImportPassWordResult(P),
	sendPackage(Socket,?CMD_PlayerImportPassWordResult,Bin);


send(Socket,#pk_GS2U_UpdatePlayerGuildInfo{}=P) ->

	Bin = write_GS2U_UpdatePlayerGuildInfo(P),
	sendPackage(Socket,?CMD_GS2U_UpdatePlayerGuildInfo,Bin);



send(Socket,#pk_U2GS_RequestBazzarItemPrice_Result{}=P) ->

	Bin = write_U2GS_RequestBazzarItemPrice_Result(P),
	sendPackage(Socket,?CMD_U2GS_RequestBazzarItemPrice_Result,Bin);



send(Socket,#pk_PlayerGoldPassWordChanged{}=P) ->

	Bin = write_PlayerGoldPassWordChanged(P),
	sendPackage(Socket,?CMD_PlayerGoldPassWordChanged,Bin);


send(Socket,#pk_PlayerImportGoldPassWordResult{}=P) ->

	Bin = write_PlayerImportGoldPassWordResult(P),
	sendPackage(Socket,?CMD_PlayerImportGoldPassWordResult,Bin);


send(Socket,#pk_PlayerGoldUnlockTimesChanged{}=P) ->

	Bin = write_PlayerGoldUnlockTimesChanged(P),
	sendPackage(Socket,?CMD_PlayerGoldUnlockTimesChanged,Bin);


send(Socket,#pk_GS2U_LeftSmallMonsterNumber{}=P) ->

	Bin = write_GS2U_LeftSmallMonsterNumber(P),
	sendPackage(Socket,?CMD_GS2U_LeftSmallMonsterNumber,Bin);


send(Socket,#pk_GS2U_VipInfo{}=P) ->

	Bin = write_GS2U_VipInfo(P),
	sendPackage(Socket,?CMD_GS2U_VipInfo,Bin);


send(Socket,#pk_GS2U_TellMapLineID{}=P) ->

	Bin = write_GS2U_TellMapLineID(P),
	sendPackage(Socket,?CMD_GS2U_TellMapLineID,Bin);



send(Socket,#pk_VIPPlayerOpenVIPStoreFail{}=P) ->

	Bin = write_VIPPlayerOpenVIPStoreFail(P),
	sendPackage(Socket,?CMD_VIPPlayerOpenVIPStoreFail,Bin);


send(Socket,#pk_UpdateVIPLevelInfo{}=P) ->

	Bin = write_UpdateVIPLevelInfo(P),
	sendPackage(Socket,?CMD_UpdateVIPLevelInfo,Bin);



send(Socket,#pk_ActiveCodeResult{}=P) ->

	Bin = write_ActiveCodeResult(P),
	sendPackage(Socket,?CMD_ActiveCodeResult,Bin);



send(Socket,#pk_GS2U_RequestOutFightPetPropetryResult{}=P) ->

	Bin = write_GS2U_RequestOutFightPetPropetryResult(P),
	sendPackage(Socket,?CMD_GS2U_RequestOutFightPetPropetryResult,Bin);



send(Socket,#pk_PlayerDirMove_S2C{}=P) ->

	Bin = write_PlayerDirMove_S2C(P),
	sendPackage(Socket,?CMD_PlayerDirMove_S2C,Bin);



send(Socket,#pk_GSWithU_GameSetMenu_3{}=P) ->

	Bin = write_GSWithU_GameSetMenu_3(P),
	sendPackage(Socket,?CMD_GSWithU_GameSetMenu_3,Bin);



send(Socket,#pk_StartCompoundResult{}=P) ->

	Bin = write_StartCompoundResult(P),
	sendPackage(Socket,?CMD_StartCompoundResult,Bin);


send(Socket,#pk_CompoundBaseInfo{}=P) ->

	Bin = write_CompoundBaseInfo(P),
	sendPackage(Socket,?CMD_CompoundBaseInfo,Bin);



send(Socket,#pk_EquipQualityFastUPByTypeBack{}=P) ->

	Bin = write_EquipQualityFastUPByTypeBack(P),
	sendPackage(Socket,?CMD_EquipQualityFastUPByTypeBack,Bin);



send(Socket,#pk_PlayerTeleportMove_S2C{}=P) ->

	Bin = write_PlayerTeleportMove_S2C(P),
	sendPackage(Socket,?CMD_PlayerTeleportMove_S2C,Bin);





send(Socket,#pk_BattleResultList{}=P) ->

	Bin = write_BattleResultList(P),
	sendPackage(Socket,?CMD_BattleResultList,Bin);


send(Socket,#pk_GS2U_BattleEnrollResult{}=P) ->

	Bin = write_GS2U_BattleEnrollResult(P),
	sendPackage(Socket,?CMD_GS2U_BattleEnrollResult,Bin);



send(Socket,#pk_GS2U_sendEnrollInfo{}=P) ->

	Bin = write_GS2U_sendEnrollInfo(P),
	sendPackage(Socket,?CMD_GS2U_sendEnrollInfo,Bin);


send(Socket,#pk_GS2U_NowCanEnterBattle{}=P) ->

	Bin = write_GS2U_NowCanEnterBattle(P),
	sendPackage(Socket,?CMD_GS2U_NowCanEnterBattle,Bin);



send(Socket,#pk_GS2U_EnterBattleResult{}=P) ->

	Bin = write_GS2U_EnterBattleResult(P),
	sendPackage(Socket,?CMD_GS2U_EnterBattleResult,Bin);


send(Socket,#pk_GS2U_BattleScore{}=P) ->

	Bin = write_GS2U_BattleScore(P),
	sendPackage(Socket,?CMD_GS2U_BattleScore,Bin);



send(Socket,#pk_GS2U_BattleEnd{}=P) ->

	Bin = write_GS2U_BattleEnd(P),
	sendPackage(Socket,?CMD_GS2U_BattleEnd,Bin);


send(Socket,#pk_GS2U_LeftOpenTime{}=P) ->

	Bin = write_GS2U_LeftOpenTime(P),
	sendPackage(Socket,?CMD_GS2U_LeftOpenTime,Bin);


send(Socket,#pk_GS2U_HeartBeatAck{}=P) ->

	Bin = write_GS2U_HeartBeatAck(P),
	sendPackage(Socket,?CMD_GS2U_HeartBeatAck,Bin);

send(_,_)-> 
	noMatch.


dealMsg(Socket,Cmd,Bin2) -> 
	case Cmd of
	?CMD_PlayerMoveTo->
		{Pk,_,_} = binary_read_PlayerMoveTo(Bin2),
		messageOn:on_PlayerMoveTo(Socket,Pk);
	?CMD_PlayerStopMove->
		{Pk,_,_} = binary_read_PlayerStopMove(Bin2),
		messageOn:on_PlayerStopMove(Socket,Pk);
	?CMD_ChangeFlyState->
		{Pk,_,_} = binary_read_ChangeFlyState(Bin2),
		messageOn:on_ChangeFlyState(Socket,Pk);
	?CMD_ChangeMap->
		{Pk,_,_} = binary_read_ChangeMap(Bin2),
		messageOn:on_ChangeMap(Socket,Pk);
	?CMD_RequestGM->
		{Pk,_,_} = binary_read_RequestGM(Bin2),
		messageOn:on_RequestGM(Socket,Pk);
	?CMD_U2GS_StudySkill->
		{Pk,_,_} = binary_read_U2GS_StudySkill(Bin2),
		messageOn:on_U2GS_StudySkill(Socket,Pk);
	?CMD_activeBranchID->
		{Pk,_,_} = binary_read_activeBranchID(Bin2),
		messageOn:on_activeBranchID(Socket,Pk);
	?CMD_U2GS_AddSkillBranch->
		{Pk,_,_} = binary_read_U2GS_AddSkillBranch(Bin2),
		messageOn:on_U2GS_AddSkillBranch(Socket,Pk);
	?CMD_U2GS_UseSkillRequest->
		{Pk,_,_} = binary_read_U2GS_UseSkillRequest(Bin2),
		messageOn:on_U2GS_UseSkillRequest(Socket,Pk);
	?CMD_ShortcutSet->
		{Pk,_,_} = binary_read_ShortcutSet(Bin2),
		messageOn:on_ShortcutSet(Socket,Pk);
	?CMD_U2GS_InteractObject->
		{Pk,_,_} = binary_read_U2GS_InteractObject(Bin2),
		messageOn:on_U2GS_InteractObject(Socket,Pk);
	?CMD_U2GS_QueryHeroProperty->
		{Pk,_,_} = binary_read_U2GS_QueryHeroProperty(Bin2),
		messageOn:on_U2GS_QueryHeroProperty(Socket,Pk);
	?CMD_RequestDestroyItem->
		{Pk,_,_} = binary_read_RequestDestroyItem(Bin2),
		messageOn:on_RequestDestroyItem(Socket,Pk);
	?CMD_RequestGetItem->
		{Pk,_,_} = binary_read_RequestGetItem(Bin2),
		messageOn:on_RequestGetItem(Socket,Pk);
	?CMD_RequestPlayerBagOrder->
		{Pk,_,_} = binary_read_RequestPlayerBagOrder(Bin2),
		messageOn:on_RequestPlayerBagOrder(Socket,Pk);
	?CMD_PlayerRequestUseItem->
		{Pk,_,_} = binary_read_PlayerRequestUseItem(Bin2),
		messageOn:on_PlayerRequestUseItem(Socket,Pk);
	?CMD_RequestPlayerBagCellOpen->
		{Pk,_,_} = binary_read_RequestPlayerBagCellOpen(Bin2),
		messageOn:on_RequestPlayerBagCellOpen(Socket,Pk);
	?CMD_RequestChangeStorageBagPassWord->
		{Pk,_,_} = binary_read_RequestChangeStorageBagPassWord(Bin2),
		messageOn:on_RequestChangeStorageBagPassWord(Socket,Pk);
	?CMD_RequestPlayerBagSellItem->
		{Pk,_,_} = binary_read_RequestPlayerBagSellItem(Bin2),
		messageOn:on_RequestPlayerBagSellItem(Socket,Pk);
	?CMD_RequestClearTempBag->
		{Pk,_,_} = binary_read_RequestClearTempBag(Bin2),
		messageOn:on_RequestClearTempBag(Socket,Pk);
	?CMD_RequestMoveTempBagItem->
		{Pk,_,_} = binary_read_RequestMoveTempBagItem(Bin2),
		messageOn:on_RequestMoveTempBagItem(Socket,Pk);
	?CMD_RequestMoveAllTempBagItem->
		{Pk,_,_} = binary_read_RequestMoveAllTempBagItem(Bin2),
		messageOn:on_RequestMoveAllTempBagItem(Socket,Pk);
	?CMD_RequestMoveStorageBagItem->
		{Pk,_,_} = binary_read_RequestMoveStorageBagItem(Bin2),
		messageOn:on_RequestMoveStorageBagItem(Socket,Pk);
	?CMD_RequestMoveBagItemToStorage->
		{Pk,_,_} = binary_read_RequestMoveBagItemToStorage(Bin2),
		messageOn:on_RequestMoveBagItemToStorage(Socket,Pk);
	?CMD_RequestUnlockingStorageBagPassWord->
		{Pk,_,_} = binary_read_RequestUnlockingStorageBagPassWord(Bin2),
		messageOn:on_RequestUnlockingStorageBagPassWord(Socket,Pk);
	?CMD_RequestCancelUnlockingStorageBagPassWord->
		{Pk,_,_} = binary_read_RequestCancelUnlockingStorageBagPassWord(Bin2),
		messageOn:on_RequestCancelUnlockingStorageBagPassWord(Socket,Pk);
	?CMD_RequestGetNpcStoreItemList->
		{Pk,_,_} = binary_read_RequestGetNpcStoreItemList(Bin2),
		messageOn:on_RequestGetNpcStoreItemList(Socket,Pk);
	?CMD_RequestBuyItem->
		{Pk,_,_} = binary_read_RequestBuyItem(Bin2),
		messageOn:on_RequestBuyItem(Socket,Pk);
	?CMD_RequestSellItem->
		{Pk,_,_} = binary_read_RequestSellItem(Bin2),
		messageOn:on_RequestSellItem(Socket,Pk);
	?CMD_GetNpcStoreBackBuyItemList->
		{Pk,_,_} = binary_read_GetNpcStoreBackBuyItemList(Bin2),
		messageOn:on_GetNpcStoreBackBuyItemList(Socket,Pk);
	?CMD_RequestBackBuyItem->
		{Pk,_,_} = binary_read_RequestBackBuyItem(Bin2),
		messageOn:on_RequestBackBuyItem(Socket,Pk);
	?CMD_RequestPlayerEquipActive->
		{Pk,_,_} = binary_read_RequestPlayerEquipActive(Bin2),
		messageOn:on_RequestPlayerEquipActive(Socket,Pk);
	?CMD_RequestPlayerEquipPutOn->
		{Pk,_,_} = binary_read_RequestPlayerEquipPutOn(Bin2),
		messageOn:on_RequestPlayerEquipPutOn(Socket,Pk);
	?CMD_RequestQueryPlayerEquip->
		{Pk,_,_} = binary_read_RequestQueryPlayerEquip(Bin2),
		messageOn:on_RequestQueryPlayerEquip(Socket,Pk);
	?CMD_StudySkill->
		{Pk,_,_} = binary_read_StudySkill(Bin2),
		messageOn:on_StudySkill(Socket,Pk);
	?CMD_Reborn->
		{Pk,_,_} = binary_read_Reborn(Bin2),
		messageOn:on_Reborn(Socket,Pk);
	?CMD_Chat2Server->
		{Pk,_,_} = binary_read_Chat2Server(Bin2),
		messageOn:on_Chat2Server(Socket,Pk);
	?CMD_RequestSendMail->
		{Pk,_,_} = binary_read_RequestSendMail(Bin2),
		messageOn:on_RequestSendMail(Socket,Pk);
	?CMD_RequestRecvMail->
		{Pk,_,_} = binary_read_RequestRecvMail(Bin2),
		messageOn:on_RequestRecvMail(Socket,Pk);
	?CMD_RequestUnReadMail->
		{Pk,_,_} = binary_read_RequestUnReadMail(Bin2),
		messageOn:on_RequestUnReadMail(Socket,Pk);
	?CMD_RequestMailList->
		{Pk,_,_} = binary_read_RequestMailList(Bin2),
		messageOn:on_RequestMailList(Socket,Pk);
	?CMD_RequestMailItemInfo->
		{Pk,_,_} = binary_read_RequestMailItemInfo(Bin2),
		messageOn:on_RequestMailItemInfo(Socket,Pk);
	?CMD_RequestAcceptMailItem->
		{Pk,_,_} = binary_read_RequestAcceptMailItem(Bin2),
		messageOn:on_RequestAcceptMailItem(Socket,Pk);
	?CMD_MailReadNotice->
		{Pk,_,_} = binary_read_MailReadNotice(Bin2),
		messageOn:on_MailReadNotice(Socket,Pk);
	?CMD_RequestDeleteMail->
		{Pk,_,_} = binary_read_RequestDeleteMail(Bin2),
		messageOn:on_RequestDeleteMail(Socket,Pk);
	?CMD_RequestDeleteReadMail->
		{Pk,_,_} = binary_read_RequestDeleteReadMail(Bin2),
		messageOn:on_RequestDeleteReadMail(Socket,Pk);
	?CMD_RequestSystemMail->
		{Pk,_,_} = binary_read_RequestSystemMail(Bin2),
		messageOn:on_RequestSystemMail(Socket,Pk);
	?CMD_U2GS_RequestLogin->
		{Pk,_,_} = binary_read_U2GS_RequestLogin(Bin2),
		messageOn:on_U2GS_RequestLogin(Socket,Pk);
	?CMD_U2GS_SelPlayerEnterGame->
		{Pk,_,_} = binary_read_U2GS_SelPlayerEnterGame(Bin2),
		messageOn:on_U2GS_SelPlayerEnterGame(Socket,Pk);
	?CMD_U2GS_RequestCreatePlayer->
		{Pk,_,_} = binary_read_U2GS_RequestCreatePlayer(Bin2),
		messageOn:on_U2GS_RequestCreatePlayer(Socket,Pk);
	?CMD_U2GS_RequestDeletePlayer->
		{Pk,_,_} = binary_read_U2GS_RequestDeletePlayer(Bin2),
		messageOn:on_U2GS_RequestDeletePlayer(Socket,Pk);
	?CMD_ConSales_GroundingItem->
		{Pk,_,_} = binary_read_ConSales_GroundingItem(Bin2),
		messageOn:on_ConSales_GroundingItem(Socket,Pk);
	?CMD_ConSales_TakeDown->
		{Pk,_,_} = binary_read_ConSales_TakeDown(Bin2),
		messageOn:on_ConSales_TakeDown(Socket,Pk);
	?CMD_ConSales_BuyItem->
		{Pk,_,_} = binary_read_ConSales_BuyItem(Bin2),
		messageOn:on_ConSales_BuyItem(Socket,Pk);
	?CMD_ConSales_FindItems->
		{Pk,_,_} = binary_read_ConSales_FindItems(Bin2),
		messageOn:on_ConSales_FindItems(Socket,Pk);
	?CMD_ConSales_TrunPage->
		{Pk,_,_} = binary_read_ConSales_TrunPage(Bin2),
		messageOn:on_ConSales_TrunPage(Socket,Pk);
	?CMD_ConSales_Close->
		{Pk,_,_} = binary_read_ConSales_Close(Bin2),
		messageOn:on_ConSales_Close(Socket,Pk);
	?CMD_ConSales_GetSelfSell->
		{Pk,_,_} = binary_read_ConSales_GetSelfSell(Bin2),
		messageOn:on_ConSales_GetSelfSell(Socket,Pk);
	?CMD_TradeAsk->
		{Pk,_,_} = binary_read_TradeAsk(Bin2),
		messageOn:on_TradeAsk(Socket,Pk);
	?CMD_TradeAskResult->
		{Pk,_,_} = binary_read_TradeAskResult(Bin2),
		messageOn:on_TradeAskResult(Socket,Pk);
	?CMD_TradeInputItem_C2S->
		{Pk,_,_} = binary_read_TradeInputItem_C2S(Bin2),
		messageOn:on_TradeInputItem_C2S(Socket,Pk);
	?CMD_TradeTakeOutItem_C2S->
		{Pk,_,_} = binary_read_TradeTakeOutItem_C2S(Bin2),
		messageOn:on_TradeTakeOutItem_C2S(Socket,Pk);
	?CMD_TradeChangeMoney_C2S->
		{Pk,_,_} = binary_read_TradeChangeMoney_C2S(Bin2),
		messageOn:on_TradeChangeMoney_C2S(Socket,Pk);
	?CMD_TradeLock_C2S->
		{Pk,_,_} = binary_read_TradeLock_C2S(Bin2),
		messageOn:on_TradeLock_C2S(Socket,Pk);
	?CMD_CancelTrade_C2S->
		{Pk,_,_} = binary_read_CancelTrade_C2S(Bin2),
		messageOn:on_CancelTrade_C2S(Socket,Pk);
	?CMD_TradeAffirm_C2S->
		{Pk,_,_} = binary_read_TradeAffirm_C2S(Bin2),
		messageOn:on_TradeAffirm_C2S(Socket,Pk);
	?CMD_PetOutFight->
		{Pk,_,_} = binary_read_PetOutFight(Bin2),
		messageOn:on_PetOutFight(Socket,Pk);
	?CMD_PetTakeRest->
		{Pk,_,_} = binary_read_PetTakeRest(Bin2),
		messageOn:on_PetTakeRest(Socket,Pk);
	?CMD_PetFreeCaptiveAnimals->
		{Pk,_,_} = binary_read_PetFreeCaptiveAnimals(Bin2),
		messageOn:on_PetFreeCaptiveAnimals(Socket,Pk);
	?CMD_PetCompoundModel->
		{Pk,_,_} = binary_read_PetCompoundModel(Bin2),
		messageOn:on_PetCompoundModel(Socket,Pk);
	?CMD_PetWashGrowUpValue->
		{Pk,_,_} = binary_read_PetWashGrowUpValue(Bin2),
		messageOn:on_PetWashGrowUpValue(Socket,Pk);
	?CMD_PetReplaceGrowUpValue->
		{Pk,_,_} = binary_read_PetReplaceGrowUpValue(Bin2),
		messageOn:on_PetReplaceGrowUpValue(Socket,Pk);
	?CMD_PetIntensifySoul->
		{Pk,_,_} = binary_read_PetIntensifySoul(Bin2),
		messageOn:on_PetIntensifySoul(Socket,Pk);
	?CMD_PetOneKeyIntensifySoul->
		{Pk,_,_} = binary_read_PetOneKeyIntensifySoul(Bin2),
		messageOn:on_PetOneKeyIntensifySoul(Socket,Pk);
	?CMD_PetFuse->
		{Pk,_,_} = binary_read_PetFuse(Bin2),
		messageOn:on_PetFuse(Socket,Pk);
	?CMD_ChangePetAIState->
		{Pk,_,_} = binary_read_ChangePetAIState(Bin2),
		messageOn:on_ChangePetAIState(Socket,Pk);
	?CMD_PetLearnSkill->
		{Pk,_,_} = binary_read_PetLearnSkill(Bin2),
		messageOn:on_PetLearnSkill(Socket,Pk);
	?CMD_PetDelSkill->
		{Pk,_,_} = binary_read_PetDelSkill(Bin2),
		messageOn:on_PetDelSkill(Socket,Pk);
	?CMD_PetUnLockSkillCell->
		{Pk,_,_} = binary_read_PetUnLockSkillCell(Bin2),
		messageOn:on_PetUnLockSkillCell(Socket,Pk);
	?CMD_PetSkillSealAhs->
		{Pk,_,_} = binary_read_PetSkillSealAhs(Bin2),
		messageOn:on_PetSkillSealAhs(Socket,Pk);
	?CMD_PetlearnSealAhsSkill->
		{Pk,_,_} = binary_read_PetlearnSealAhsSkill(Bin2),
		messageOn:on_PetlearnSealAhsSkill(Socket,Pk);
	?CMD_RequestGetPlayerEquipEnhanceByType->
		{Pk,_,_} = binary_read_RequestGetPlayerEquipEnhanceByType(Bin2),
		messageOn:on_RequestGetPlayerEquipEnhanceByType(Socket,Pk);
	?CMD_RequestEquipEnhanceByType->
		{Pk,_,_} = binary_read_RequestEquipEnhanceByType(Bin2),
		messageOn:on_RequestEquipEnhanceByType(Socket,Pk);
	?CMD_RequestEquipOnceEnhanceByType->
		{Pk,_,_} = binary_read_RequestEquipOnceEnhanceByType(Bin2),
		messageOn:on_RequestEquipOnceEnhanceByType(Socket,Pk);
	?CMD_RequestGetPlayerEquipQualityByType->
		{Pk,_,_} = binary_read_RequestGetPlayerEquipQualityByType(Bin2),
		messageOn:on_RequestGetPlayerEquipQualityByType(Socket,Pk);
	?CMD_RequestEquipQualityUPByType->
		{Pk,_,_} = binary_read_RequestEquipQualityUPByType(Bin2),
		messageOn:on_RequestEquipQualityUPByType(Socket,Pk);
	?CMD_RequestEquipOldPropertyByType->
		{Pk,_,_} = binary_read_RequestEquipOldPropertyByType(Bin2),
		messageOn:on_RequestEquipOldPropertyByType(Socket,Pk);
	?CMD_RequestEquipChangePropertyByType->
		{Pk,_,_} = binary_read_RequestEquipChangePropertyByType(Bin2),
		messageOn:on_RequestEquipChangePropertyByType(Socket,Pk);
	?CMD_RequestEquipSaveNewPropertyByType->
		{Pk,_,_} = binary_read_RequestEquipSaveNewPropertyByType(Bin2),
		messageOn:on_RequestEquipSaveNewPropertyByType(Socket,Pk);
	?CMD_U2GS_EnterCopyMapRequest->
		{Pk,_,_} = binary_read_U2GS_EnterCopyMapRequest(Bin2),
		messageOn:on_U2GS_EnterCopyMapRequest(Socket,Pk);
	?CMD_U2GS_QueryMyCopyMapCD->
		{Pk,_,_} = binary_read_U2GS_QueryMyCopyMapCD(Bin2),
		messageOn:on_U2GS_QueryMyCopyMapCD(Socket,Pk);
	?CMD_U2GS_TransByWorldMap->
		{Pk,_,_} = binary_read_U2GS_TransByWorldMap(Bin2),
		messageOn:on_U2GS_TransByWorldMap(Socket,Pk);
	?CMD_U2GS_TransForSameScence->
		{Pk,_,_} = binary_read_U2GS_TransForSameScence(Bin2),
		messageOn:on_U2GS_TransForSameScence(Socket,Pk);
	?CMD_U2GS_FastTeamCopyMapRequest->
		{Pk,_,_} = binary_read_U2GS_FastTeamCopyMapRequest(Bin2),
		messageOn:on_U2GS_FastTeamCopyMapRequest(Socket,Pk);
	?CMD_U2GS_RestCopyMapRequest->
		{Pk,_,_} = binary_read_U2GS_RestCopyMapRequest(Bin2),
		messageOn:on_U2GS_RestCopyMapRequest(Socket,Pk);
	?CMD_U2GS_QieCuoInvite->
		{Pk,_,_} = binary_read_U2GS_QieCuoInvite(Bin2),
		messageOn:on_U2GS_QieCuoInvite(Socket,Pk);
	?CMD_U2GS_QieCuoInviteAck->
		{Pk,_,_} = binary_read_U2GS_QieCuoInviteAck(Bin2),
		messageOn:on_U2GS_QieCuoInviteAck(Socket,Pk);
	?CMD_U2GS_PK_KillOpenRequest->
		{Pk,_,_} = binary_read_U2GS_PK_KillOpenRequest(Bin2),
		messageOn:on_U2GS_PK_KillOpenRequest(Socket,Pk);
	?CMD_U2GS_BloodPoolAddLife->
		{Pk,_,_} = binary_read_U2GS_BloodPoolAddLife(Bin2),
		messageOn:on_U2GS_BloodPoolAddLife(Socket,Pk);
	?CMD_U2GS_GetSigninInfo->
		{Pk,_,_} = binary_read_U2GS_GetSigninInfo(Bin2),
		messageOn:on_U2GS_GetSigninInfo(Socket,Pk);
	?CMD_U2GS_Signin->
		{Pk,_,_} = binary_read_U2GS_Signin(Bin2),
		messageOn:on_U2GS_Signin(Socket,Pk);
	?CMD_U2GS_LeaveCopyMap->
		{Pk,_,_} = binary_read_U2GS_LeaveCopyMap(Bin2),
		messageOn:on_U2GS_LeaveCopyMap(Socket,Pk);
	?CMD_PetChangeName->
		{Pk,_,_} = binary_read_PetChangeName(Bin2),
		messageOn:on_PetChangeName(Socket,Pk);
	?CMD_BazzarListRequest->
		{Pk,_,_} = binary_read_BazzarListRequest(Bin2),
		messageOn:on_BazzarListRequest(Socket,Pk);
	?CMD_BazzarBuyRequest->
		{Pk,_,_} = binary_read_BazzarBuyRequest(Bin2),
		messageOn:on_BazzarBuyRequest(Socket,Pk);
	?CMD_U2GS_RemoveSkillBranch->
		{Pk,_,_} = binary_read_U2GS_RemoveSkillBranch(Bin2),
		messageOn:on_U2GS_RemoveSkillBranch(Socket,Pk);
	?CMD_U2GS_PetBloodPoolAddLife->
		{Pk,_,_} = binary_read_U2GS_PetBloodPoolAddLife(Bin2),
		messageOn:on_U2GS_PetBloodPoolAddLife(Socket,Pk);
	?CMD_U2GS_CopyMapAddActiveCount->
		{Pk,_,_} = binary_read_U2GS_CopyMapAddActiveCount(Bin2),
		messageOn:on_U2GS_CopyMapAddActiveCount(Socket,Pk);
	?CMD_U2GS_CarriageQualityRefresh->
		{Pk,_,_} = binary_read_U2GS_CarriageQualityRefresh(Bin2),
		messageOn:on_U2GS_CarriageQualityRefresh(Socket,Pk);
	?CMD_U2GS_ConvoyCDRequst->
		{Pk,_,_} = binary_read_U2GS_ConvoyCDRequst(Bin2),
		messageOn:on_U2GS_ConvoyCDRequst(Socket,Pk);
	?CMD_U2GS_BeginConvoy->
		{Pk,_,_} = binary_read_U2GS_BeginConvoy(Bin2),
		messageOn:on_U2GS_BeginConvoy(Socket,Pk);
	?CMD_GSWithU_GameSetMenu->
		{Pk,_,_} = binary_read_GSWithU_GameSetMenu(Bin2),
		messageOn:on_GSWithU_GameSetMenu(Socket,Pk);
	?CMD_U2GS_RequestRechargeGift->
		{Pk,_,_} = binary_read_U2GS_RequestRechargeGift(Bin2),
		messageOn:on_U2GS_RequestRechargeGift(Socket,Pk);
	?CMD_U2GS_RequestPlayerFightingCapacity->
		{Pk,_,_} = binary_read_U2GS_RequestPlayerFightingCapacity(Bin2),
		messageOn:on_U2GS_RequestPlayerFightingCapacity(Socket,Pk);
	?CMD_U2GS_RequestPetFightingCapacity->
		{Pk,_,_} = binary_read_U2GS_RequestPetFightingCapacity(Bin2),
		messageOn:on_U2GS_RequestPetFightingCapacity(Socket,Pk);
	?CMD_U2GS_RequestMountFightingCapacity->
		{Pk,_,_} = binary_read_U2GS_RequestMountFightingCapacity(Bin2),
		messageOn:on_U2GS_RequestMountFightingCapacity(Socket,Pk);
	?CMD_U2GS_GetRankList->
		{Pk,_,_} = binary_read_U2GS_GetRankList(Bin2),
		messageOn:on_U2GS_GetRankList(Socket,Pk);
	?CMD_U2GS_ChangePlayerName->
		{Pk,_,_} = binary_read_U2GS_ChangePlayerName(Bin2),
		messageOn:on_U2GS_ChangePlayerName(Socket,Pk);
	?CMD_U2GS_SetProtectPwd->
		{Pk,_,_} = binary_read_U2GS_SetProtectPwd(Bin2),
		messageOn:on_U2GS_SetProtectPwd(Socket,Pk);
	?CMD_U2GS_HeartBeat->
		{Pk,_,_} = binary_read_U2GS_HeartBeat(Bin2),
		messageOn:on_U2GS_HeartBeat(Socket,Pk);
	?CMD_U2GS_QequestGiveGoldCheck->
		{Pk,_,_} = binary_read_U2GS_QequestGiveGoldCheck(Bin2),
		messageOn:on_U2GS_QequestGiveGoldCheck(Socket,Pk);
	?CMD_U2GS_StartGiveGold->
		{Pk,_,_} = binary_read_U2GS_StartGiveGold(Bin2),
		messageOn:on_U2GS_StartGiveGold(Socket,Pk);
	?CMD_RequestLookPlayer->
		{Pk,_,_} = binary_read_RequestLookPlayer(Bin2),
		messageOn:on_RequestLookPlayer(Socket,Pk);
	?CMD_U2GS_PlayerClientInfo->
		{Pk,_,_} = binary_read_U2GS_PlayerClientInfo(Bin2),
		messageOn:on_U2GS_PlayerClientInfo(Socket,Pk);
	?CMD_U2GS_RequestActiveCount->
		{Pk,_,_} = binary_read_U2GS_RequestActiveCount(Bin2),
		messageOn:on_U2GS_RequestActiveCount(Socket,Pk);
	?CMD_U2GS_RequestConvertActive->
		{Pk,_,_} = binary_read_U2GS_RequestConvertActive(Bin2),
		messageOn:on_U2GS_RequestConvertActive(Socket,Pk);
	?CMD_U2GS_TransferOldRechargeToPlayer->
		{Pk,_,_} = binary_read_U2GS_TransferOldRechargeToPlayer(Bin2),
		messageOn:on_U2GS_TransferOldRechargeToPlayer(Socket,Pk);
	?CMD_PlayerImportPassWord->
		{Pk,_,_} = binary_read_PlayerImportPassWord(Bin2),
		messageOn:on_PlayerImportPassWord(Socket,Pk);
	?CMD_U2GS_RequestBazzarItemPrice->
		{Pk,_,_} = binary_read_U2GS_RequestBazzarItemPrice(Bin2),
		messageOn:on_U2GS_RequestBazzarItemPrice(Socket,Pk);
	?CMD_RequestChangeGoldPassWord->
		{Pk,_,_} = binary_read_RequestChangeGoldPassWord(Bin2),
		messageOn:on_RequestChangeGoldPassWord(Socket,Pk);
	?CMD_VIPPlayerOpenVIPStoreRequest->
		{Pk,_,_} = binary_read_VIPPlayerOpenVIPStoreRequest(Bin2),
		messageOn:on_VIPPlayerOpenVIPStoreRequest(Socket,Pk);
	?CMD_ActiveCodeRequest->
		{Pk,_,_} = binary_read_ActiveCodeRequest(Bin2),
		messageOn:on_ActiveCodeRequest(Socket,Pk);
	?CMD_U2GS_RequestOutFightPetPropetry->
		{Pk,_,_} = binary_read_U2GS_RequestOutFightPetPropetry(Bin2),
		messageOn:on_U2GS_RequestOutFightPetPropetry(Socket,Pk);
	?CMD_PlayerDirMove->
		{Pk,_,_} = binary_read_PlayerDirMove(Bin2),
		messageOn:on_PlayerDirMove(Socket,Pk);
	?CMD_U2GS_EnRollCampusBattle->
		{Pk,_,_} = binary_read_U2GS_EnRollCampusBattle(Bin2),
		messageOn:on_U2GS_EnRollCampusBattle(Socket,Pk);
	?CMD_GSWithU_GameSetMenu_3->
		{Pk,_,_} = binary_read_GSWithU_GameSetMenu_3(Bin2),
		messageOn:on_GSWithU_GameSetMenu_3(Socket,Pk);
	?CMD_StartCompound->
		{Pk,_,_} = binary_read_StartCompound(Bin2),
		messageOn:on_StartCompound(Socket,Pk);
	?CMD_RequestEquipFastUpQuality->
		{Pk,_,_} = binary_read_RequestEquipFastUpQuality(Bin2),
		messageOn:on_RequestEquipFastUpQuality(Socket,Pk);
	?CMD_PlayerTeleportMove->
		{Pk,_,_} = binary_read_PlayerTeleportMove(Bin2),
		messageOn:on_PlayerTeleportMove(Socket,Pk);
	?CMD_U2GS_leaveCampusBattle->
		{Pk,_,_} = binary_read_U2GS_leaveCampusBattle(Bin2),
		messageOn:on_U2GS_leaveCampusBattle(Socket,Pk);
	?CMD_U2GS_LeaveBattleScene->
		{Pk,_,_} = binary_read_U2GS_LeaveBattleScene(Bin2),
		messageOn:on_U2GS_LeaveBattleScene(Socket,Pk);
	?CMD_U2GS_requestEnrollInfo->
		{Pk,_,_} = binary_read_U2GS_requestEnrollInfo(Bin2),
		messageOn:on_U2GS_requestEnrollInfo(Socket,Pk);
	?CMD_U2GS_SureEnterBattle->
		{Pk,_,_} = binary_read_U2GS_SureEnterBattle(Bin2),
		messageOn:on_U2GS_SureEnterBattle(Socket,Pk);
	?CMD_U2GS_RequestBattleResultList->
		{Pk,_,_} = binary_read_U2GS_RequestBattleResultList(Bin2),
		messageOn:on_U2GS_RequestBattleResultList(Socket,Pk);
		_-> 
		noMatch
	end.
