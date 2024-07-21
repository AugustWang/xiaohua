-ifndef(guildDefine_hrl).

%%ä»çåå»ºç©å®¶ç­çº§éæ±
-define( GuildCreate_PlayerLevel,	31 ).
%%ä»çåå»ºéå¸éæ±
-define( GuildCreate_Money, 200000 ).
%%ä»çåå­æå°å­ç¬¦æ°
-define( Min_GuildName_CharCount, 2 ).
%%ä»çåå­æå¤§å­ç¬¦æ°
-define( Max_GuildName_CharCount, 6 ).
%%ä»çåå­æå¤§å­èæ°
-define( Max_GuildName_Len, 12 ).

%%ä»çå¬åæå¤§å­ç¬¦æ°
-define( Max_GuildAffiche_CharCount, 300 ).
%%ä»çæå¤§ç­çº§
-define( Max_GuildLevel, 10 ).


%%ä»çèä½GuildRankType
-define( GuildRank_Normal, 0 ).	%%	æ®é
-define( GuildRank_Elder, 1 ).	%%	é¿è
-define( GuildRank_ViceChairman, 2 ). %%	å¯çä¸»
-define( GuildRank_Chairman, 3 ). %%	çä¸»

%%å¯çä¸»æ°é
-define( Max_Guild_ViceChairman_Count, 2 ). %%	å¯çä¸»
%%é¿èæ°é
-define( Max_Guild_Elder_Count, 6 ).	%%	é¿è


%%ä»çè´¡ç®åº¦æç®ææç±»åGuildContributeType
-define( GuildContribute_Money, 0 ).%%	éå¸
-define( GuildContribute_Gold, 1 ).%%	åå®
-define( GuildContribute_Item, 2 ).%%	ç©å

%%æç®éå¸ä»çç»éªåæ¢
-define( GuildContributeMoneyConvertExp, 0 ).
%%æç®åå®ä»çç»éªåæ¢
-define( GuildContributeGoldConvertExp, 1 ).
%%æç®çµç³ä»çç»éªåæ¢
-define( GuildContributeStoneConvertExp, 1).
%%ä»çæç®éå¸åæ¢å£°ææ¯ä¾
-define( GuildContributeMoneyConvertRep, 0 ).
%%ä»çæç®åå®åæ¢å£°ææ¯ä¾
-define( GuildContributeGoldConvertRep, 1 ).
%%ä»çæç®ç©ååæ¢å£°ææ¯ä¾
-define( GuildContributeItemConvertRep, 1 ).
%%ä»çè´¡ç®åº¦æç®éå¸åæ¢
-define( GuildContributeMoneyConvert, 0 ).
%%ä»çè´¡ç®åº¦æç®åå®åæ¢
-define( GuildContributeGoldConvert, 1 ).
%%ä»çè´¡ç®åº¦æç®ç©ååæ¢
-define( GuildContributeItemConvert, 1 ).
%%ä»çè´¡ç®åº¦æç®ç©åID
-define( GuildContributeItemID, 104 ).
%%ä»çä»¤ç©åID
-define( GuildTokenItemID, 84 ).

%%ä»çè´¡ç®åº¦æç®éå¸ï¼æ¯å¤©æå¤æå¤å°
-define( Max_GuildContributeMoney_Day, 1000 ).

%%ä»çç³è¯·åè¡¨æåæå¤§æ°é
-define( Max_GuildApplicantCount, 100 ).

%%ä»çåå»ºç»æ
-define( Guild_CreateResult_Success, 0).		%%åå»ºæå
-define( Guild_CreateResult_PlayerLvl, -1).		%%ç©å®¶çº§å«ä¸å¤
-define( Guild_CreateResult_PlayerMoney, -2).	%%ç©å®¶é±ä¸å¤
-define( Guild_CreateResult_HasGuild, -3).		%%ç©å®¶å·²å¨å·¥ä¼ä¸­
-define( Guild_CreateResult_NameIllegal, -4).	%%å¬ä¼åä¸åæ³
-define( GS2U_CreateGuildResult_Fail_Name_Multy, -5).	%%å¬ä¼åä¸åæ³
-define( Guild_CreateResult_NameForbidden, -6).	%%å¬ä¼åå«ææå­
-define( Guild_CreateResult_NoGuildToken, -7).	%%æ²¡æå»ºçä»¤

%%ä»çç³è¯·ç»æ
-define( Guild_ApplyResult_Success, 0).				%%åå»ºæå
-define( Guild_ApplyResult_NoExist, -1).			%%å¬ä¼ä¸å­å¨
-define( Guild_ApplyResult_DiffCamp, -2).			%%éµè¥ä¸å
-define( Guild_ApplyResult_AlreadyAMember, -3).		%%å·²å¨å¬ä¼
-define( Guild_ApplyResult_AlreadyApply, -4).		%%å·²ç³è¯·
-define( Guild_ApplyResult_MaxApplyCount, -5).		%%å¬ä¼ç³è¯·åè¡¨å·²æ»¡
-define( Guild_ApplyResult_MaxCount, -6).		%%公会成员已满

-define( Guild_MultiExp_BuffID, 47).		%%加入家族获得的buffID

-endif. % -ifdef(guildDefine_hrl).
