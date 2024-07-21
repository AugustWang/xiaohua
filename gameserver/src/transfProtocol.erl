-module(transfProtocol).


-include("pc_player.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 


%%->pk_GSWithU_GameSetMenu_3
transfGameSetMenuTo3(#pk_GSWithU_GameSetMenu{}=P)->
	#pk_GSWithU_GameSetMenu_3{
		joinTeamOnoff=P#pk_GSWithU_GameSetMenu.joinTeamOnoff,
		inviteGuildOnoff=P#pk_GSWithU_GameSetMenu.inviteGuildOnoff,
		tradeOnoff=P#pk_GSWithU_GameSetMenu.tradeOnoff,
		applicateFriendOnoff=P#pk_GSWithU_GameSetMenu.applicateFriendOnoff,
		singleKeyOperateOnoff=P#pk_GSWithU_GameSetMenu.singleKeyOperateOnoff,
		musicPercent=P#pk_GSWithU_GameSetMenu.musicPercent,
		soundEffectPercent=P#pk_GSWithU_GameSetMenu.soundEffectPercent,
		shieldEnermyCampPlayer=P#pk_GSWithU_GameSetMenu.shieldEnermyCampPlayer,
		shieldSelfCampPlayer=P#pk_GSWithU_GameSetMenu.shieldSelfCampPlayer,
		shieldOthersPet=P#pk_GSWithU_GameSetMenu.shieldOthersPet,
		shieldOthersName=P#pk_GSWithU_GameSetMenu.shieldOthersName,
		shieldSkillEffect=P#pk_GSWithU_GameSetMenu.shieldSkillEffect,
		dispPlayerLimit=P#pk_GSWithU_GameSetMenu.dispPlayerLimit,
		shieldOthersSoundEff=0,
		noAttackGuildMate=1,
		reserve1=0,
		reserve2=0
	}.
	
%%->pk_GSWithU_GameSetMenu
transfGameSetMenu3ToOld(#pk_GSWithU_GameSetMenu_3{}=P)->
	#pk_GSWithU_GameSetMenu{
		joinTeamOnoff=P#pk_GSWithU_GameSetMenu_3.joinTeamOnoff,
		inviteGuildOnoff=P#pk_GSWithU_GameSetMenu_3.inviteGuildOnoff,
		tradeOnoff=P#pk_GSWithU_GameSetMenu_3.tradeOnoff,
		applicateFriendOnoff=P#pk_GSWithU_GameSetMenu_3.applicateFriendOnoff,
		singleKeyOperateOnoff=P#pk_GSWithU_GameSetMenu_3.singleKeyOperateOnoff,
		musicPercent=P#pk_GSWithU_GameSetMenu_3.musicPercent,
		soundEffectPercent=P#pk_GSWithU_GameSetMenu_3.soundEffectPercent,
		shieldEnermyCampPlayer=P#pk_GSWithU_GameSetMenu_3.shieldEnermyCampPlayer,
		shieldSelfCampPlayer=P#pk_GSWithU_GameSetMenu_3.shieldSelfCampPlayer,
		shieldOthersPet=P#pk_GSWithU_GameSetMenu_3.shieldOthersPet,
		shieldOthersName=P#pk_GSWithU_GameSetMenu_3.shieldOthersName,
		shieldSkillEffect=P#pk_GSWithU_GameSetMenu_3.shieldSkillEffect,
		dispPlayerLimit=P#pk_GSWithU_GameSetMenu_3.dispPlayerLimit
	}.
