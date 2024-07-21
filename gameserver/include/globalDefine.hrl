%%全局定义

%%运营平台类型定义

-define(CONNECT_TCP_OPTIONS, [binary, {packet, 0}, {active, false} ] ). 
-define(TCP_OPTIONS,[binary, {packet, 0}, {active, once}, {send_timeout, 30000}, {send_timeout_close, true},{exit_on_close, true},{keepalive, true}]).
-define(LISTEN_TCP_OPTIONS,[binary, {packet, 0},{reuseaddr, true}, {keepalive, true}, {backlog, 30}, {active, false} ]).

%% timer 定义 
-define( SavePlayerDataTimer, 300000 ). %unit ms  : 5 minutes
-define( UpdateKickOutTableTimer, 30000 ). 
-define(CountOnlinePlayerTimer,300000). % 5 minutes
-define(RecoverMnesiaGarbTimer,1200000). % 20 minutes
-define(CheckPlayerProcessTimer,600000). % 10 minutes


%% named ets
-define(SocketDataTableAtom,'socketDataTableAtom').
-define(PlayerGlobalTableAtom,'playerGlobalTableAtom').
-define(SkillCfgTableAtom,'skillCfgTableTableAtom').
-define(SkillEffectCfgTableAtom,'skillEffectCfgTableAtom').
-define(BuffCfgTableAtom,'buffCfgTableAtom').
-define(ScriptObjectTableAtom,'scriptObjectTableAtom').
-define(AttributeRegentCfgTableAtom,'attributeRegentCfgTableAtom').
-define(AttackFatorCfgTableAtom,'attackFatorCfgTableAtom').
-define(DailyCfgTableAtom,'dailyCfgTableAtom').
-define(DropPackageTableAtom,'dropPackageTableAtom').

-define(DropTableAtom,'dropTableAtom').
-define(EquipTreeCfgTableAtom,'equipTreeCfgTableAtom').

-define(EquipCfgTableAtom,'equipCfgTableAtom').
-define(EquipmentActivebonusCfgTableAtom,'equipmentActivebonusCfgTableAtom').
-define(EquipMinLevelPropertyCfgTableAtom,'equipMinLevelPropertyCfgTableAtom').

-define(EquipEnhancePropertyTableAtom,'equipEnhancePropertyTableAtom').
-define(EquipmentqualityTableAtom,'equipmentqualityTableAtom').
-define(EquipwashupMoneyTableAtom,'equipwashupMoneyTableAtom').

-define(EquipmentqualityfactorTableAtom,'equipmentqualityfactorTableAtom').
-define(EquipmentqualityattributeTableAtom,'equipmentqualityattributeTableAtom').

-define(EquipmentqualityweightTableAtom,'equipmentqualityweightTableAtom').

-define(EquipmentActiveItemNeedTableAtom,'equipmentActiveItemNeedTableAtom').

-define(ForbiddenCfgTableAtom,'forbiddenCfgTableAtom').

-define(GuildLevelCfgTableAtom,'guildLevelCfgTableAtom').
-define(GuildTaskCfgTableAtom,'guildTaskCfgTableAtom').


-define(ItemCfgTableAtom,'itemCfgTableAtom').

-define(MailTableAtom,'mailTableAtom').
-define(MailPlayerTableAtom,'mailPlayerTableAtom').

-define(MailItemTableAtom,'mailItemTableAtom').

-define(ReadyLoginUserTableAtom,'readyLoginUserTableAtom').
-define(MonsterCfgTableAtom,'monsterCfgTableAtom').
-define(NpcCfgTableAtom,'npcCfgTableAtom').

-define(MapCfgTableAtom,'mapCfgTableAtom').
-define(ObjectCfgTableAtom,'objectCfgTableAtom').

-define(AllStoreTableAtom,'allStoreTableAtom').

-define(PetCfgTableAtom,'petCfgTableAtom').

-define(PetLevelPropertyCfgTableAtom,'petLevelPropertyCfgTableAtom').

-define(PetSoulUpCfgTableAtom,'petSoulUpCfgTableAtom').

-define(PlayerBaseCfgTableAtom,'playerBaseCfgTableAtom').
-define(PlayerEXPCfgTableAtom,'playerEXPCfgTableAtom').
-define(PlayerRechargeGiftTableAtom,'playerRechargeGiftTableAtom').

-define(TaskBaseTableAtom,'taskBaseTableAtom').
-define(GlobalMainAtom,'globalMainAtom').

-define(VipFunAtom,'vipFunAtom').
-define(VipAddPropertyAtom,'VipAddPropertyAtom').

-define(QuestionsAtom,'questionsAtom').























