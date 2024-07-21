/*
Navicat MySQL Data Transfer

Source Server         : dell
Source Server Version : 50524
Source Host           : 192.168.0.199:3306
Source Database       : fxservergamedata

Target Server Type    : MYSQL
Target Server Version : 50524
File Encoding         : 65001

Date: 2013-08-01 10:52:47
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `bazzaritem`
-- ----------------------------
DROP TABLE IF EXISTS `bazzaritem`;
CREATE TABLE `bazzaritem` (
  `db_id` int(4) NOT NULL,
  `item_data_id` int(4) NOT NULL,
  `item_column` int(4) NOT NULL,
  `gold` int(4) DEFAULT '0',
  `binded_gold` int(4) DEFAULT '0',
  `init_count` int(4) DEFAULT '0',
  `remain_count` int(4) DEFAULT '0',
  `end_time` int(4) NOT NULL,
  UNIQUE KEY `bazzar_db_id` (`db_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of bazzaritem
-- ----------------------------
INSERT INTO `bazzaritem` VALUES ('1', '510', '1', '88', '88', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('2', '100', '1', '2', '2', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('3', '72', '1', '3', '3', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('4', '7103', '4', '100', '100', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('5', '120', '3', '2', '2', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('6', '110', '2', '300', '300', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('7', '116', '2', '10', '10', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('8', '121', '3', '8', '8', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('9', '14', '1', '8', '8', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('10', '71', '1', '20', '20', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('11', '2012', '0', '698', '792', '299', '299', '1375314003');
INSERT INTO `bazzaritem` VALUES ('12', '7104', '4', '500', '500', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('13', '513', '1', '2988', '2988', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('15', '25', '1', '4', '4', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('16', '2013', '0', '1488', '1782', '99', '99', '1375314003');
INSERT INTO `bazzaritem` VALUES ('17', '2011', '0', '188', '198', '499', '499', '1375314003');
INSERT INTO `bazzaritem` VALUES ('19', '117', '2', '10', '10', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('20', '12', '1', '2', '2', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('21', '7106', '4', '3000', '3000', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('22', '70', '1', '10', '10', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('24', '26', '1', '8', '8', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('25', '109', '2', '100', '100', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('26', '6002', '2', '688', '688', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('27', '115', '3', '10', '10', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('30', '7105', '4', '1000', '1000', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('31', '511', '1', '588', '588', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('32', '257', '1', '10', '10', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('33', '7102', '4', '50', '50', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('34', '509', '1', '48', '48', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('35', '11', '1', '1', '1', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('36', '122', '3', '18', '18', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('37', '13', '1', '5', '5', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('38', '123', '3', '38', '38', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('39', '256', '2', '10', '10', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('40', '512', '1', '1688', '1688', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('41', '103', '1', '1', '1', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('42', '6004', '2', '688', '688', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('43', '108', '2', '50', '50', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('44', '107', '2', '20', '20', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('45', '27', '1', '18', '18', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('46', '28', '1', '28', '28', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('47', '106', '2', '5', '5', '-1', '-1', '-1');
INSERT INTO `bazzaritem` VALUES ('48', '5224', '5', '1588', '1588', '19', '19', '1375314003');
INSERT INTO `bazzaritem` VALUES ('49', '5228', '5', '1588', '1588', '19', '19', '1375314003');
INSERT INTO `bazzaritem` VALUES ('50', '5227', '5', '1968', '1968', '19', '19', '1375314003');

-- ----------------------------
-- Table structure for `consalesitemdb`
-- ----------------------------
DROP TABLE IF EXISTS `consalesitemdb`;
CREATE TABLE `consalesitemdb` (
  `conSalesId` bigint(8) NOT NULL,
  `conSalesMoney` int(4) DEFAULT NULL,
  `groundingTime` int(4) DEFAULT NULL,
  `timeType` int(4) DEFAULT NULL,
  `playerId` bigint(8) DEFAULT NULL,
  `itemDBId` bigint(8) DEFAULT NULL,
  UNIQUE KEY `conSalesId` (`conSalesId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of consalesitemdb
-- ----------------------------

-- ----------------------------
-- Table structure for `dbinfo`
-- ----------------------------
DROP TABLE IF EXISTS `dbinfo`;
CREATE TABLE `dbinfo` (
  `name` char(64) DEFAULT NULL,
  `value` int(4) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of dbinfo
-- ----------------------------
INSERT INTO `dbinfo` VALUES ('vesion', '6');

-- ----------------------------
-- Table structure for `friend_gamedata`
-- ----------------------------
DROP TABLE IF EXISTS `friend_gamedata`;
CREATE TABLE `friend_gamedata` (
  `id` bigint(8) NOT NULL,
  `playerID` bigint(8) DEFAULT NULL,
  `friendType` int(4) DEFAULT NULL,
  `friendID` bigint(8) DEFAULT NULL,
  `friendName` char(32) DEFAULT NULL,
  `friendSex` int(4) DEFAULT NULL,
  `friendFace` int(4) DEFAULT NULL,
  `friendClassType` int(4) DEFAULT NULL,
  `friendValue` int(4) DEFAULT NULL,
  UNIQUE KEY `id` (`id`),
  KEY `playerID` (`playerID`),
  KEY `K_friend_gamedata_friendID` (`friendID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of friend_gamedata
-- ----------------------------

-- ----------------------------
-- Table structure for `guildapplicant`
-- ----------------------------
DROP TABLE IF EXISTS `guildapplicant`;
CREATE TABLE `guildapplicant` (
  `id` bigint(8) NOT NULL,
  `guildID` bigint(8) DEFAULT NULL,
  `playerID` bigint(8) DEFAULT NULL,
  `playerName` char(32) DEFAULT NULL,
  `zhanli` int(4) DEFAULT NULL,
  `level` int(4) DEFAULT NULL,
  `class` int(4) DEFAULT NULL,
  `joinTime` int(4) DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of guildapplicant
-- ----------------------------

-- ----------------------------
-- Table structure for `guildbaseinfo_gamedata`
-- ----------------------------
DROP TABLE IF EXISTS `guildbaseinfo_gamedata`;
CREATE TABLE `guildbaseinfo_gamedata` (
  `id` bigint(8) NOT NULL,
  `chairmanPlayerID` bigint(8) DEFAULT NULL,
  `level` int(4) DEFAULT NULL,
  `faction` int(4) DEFAULT NULL,
  `exp` int(4) DEFAULT NULL,
  `chairmanPlayerName` char(32) DEFAULT NULL,
  `guildName` char(32) DEFAULT NULL,
  `affiche` varchar(255) DEFAULT NULL,
  `createTime` int(4) DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of guildbaseinfo_gamedata
-- ----------------------------

-- ----------------------------
-- Table structure for `guildmember_gamedata`
-- ----------------------------
DROP TABLE IF EXISTS `guildmember_gamedata`;
CREATE TABLE `guildmember_gamedata` (
  `id` bigint(8) NOT NULL,
  `guildID` bigint(8) DEFAULT NULL,
  `playerID` bigint(8) DEFAULT NULL,
  `rank` int(4) DEFAULT NULL,
  `playerName` char(32) DEFAULT NULL,
  `playerLevel` int(4) DEFAULT NULL,
  `playerClass` int(4) DEFAULT NULL,
  `contribute` int(4) DEFAULT NULL,
  `contributeMoney` int(4) DEFAULT NULL,
  `contributeTime` int(4) DEFAULT NULL,
  `joinTime` int(4) DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of guildmember_gamedata
-- ----------------------------

-- ----------------------------
-- Table structure for `mailrecord`
-- ----------------------------
DROP TABLE IF EXISTS `mailrecord`;
CREATE TABLE `mailrecord` (
  `id` bigint(8) NOT NULL,
  `type` int(4) DEFAULT NULL,
  `recvPlayerID` bigint(8) DEFAULT NULL,
  `isOpened` int(4) DEFAULT NULL,
  `tiemOut` int(4) DEFAULT NULL,
  `idSender` bigint(8) DEFAULT NULL,
  `nameSender` char(32) DEFAULT NULL,
  `title` char(255) DEFAULT NULL,
  `content` char(255) DEFAULT NULL,
  `attachItemDBID1` bigint(8) DEFAULT NULL,
  `attachItemDBID2` bigint(8) DEFAULT NULL,
  `moneySend` int(4) DEFAULT NULL,
  `moneyPay` int(4) DEFAULT NULL,
  `mailTimerType` int(4) DEFAULT NULL,
  `mailRecTime` int(4) DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of mailrecord
-- ----------------------------

-- ----------------------------
-- Table structure for `objectbuffdb`
-- ----------------------------
DROP TABLE IF EXISTS `objectbuffdb`;
CREATE TABLE `objectbuffdb` (
  `id` bigint(8) NOT NULL,
  `buffList` varbinary(2048) DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of objectbuffdb
-- ----------------------------
INSERT INTO `objectbuffdb` VALUES ('31595566135771137', 0x836A);

-- ----------------------------
-- Table structure for `petproperty_gamedata`
-- ----------------------------
DROP TABLE IF EXISTS `petproperty_gamedata`;
CREATE TABLE `petproperty_gamedata` (
  `id` bigint(8) NOT NULL,
  `data_id` int(4) DEFAULT NULL,
  `masterId` bigint(8) DEFAULT NULL,
  `level` int(4) DEFAULT NULL,
  `exp` int(4) DEFAULT NULL,
  `name` char(32) DEFAULT NULL,
  `titleId` int(4) DEFAULT NULL,
  `aiState` int(4) DEFAULT NULL,
  `showModel` int(4) DEFAULT NULL,
  `exModelId` int(4) DEFAULT NULL,
  `soulLevel` int(4) DEFAULT NULL,
  `soulRate` int(4) DEFAULT NULL,
  `attackGrowUp` int(4) DEFAULT NULL,
  `defGrowUp` int(4) DEFAULT NULL,
  `lifeGrowUp` int(4) DEFAULT NULL,
  `isWashGrow` int(4) DEFAULT NULL,
  `attackGrowUpWash` int(4) DEFAULT NULL,
  `defGrowUpWash` int(4) DEFAULT NULL,
  `lifeGrowUpWash` int(4) DEFAULT NULL,
  `convertRatio` int(4) DEFAULT NULL,
  `exerciseLevel` int(4) DEFAULT NULL,
  `moneyExrciseNum` int(4) DEFAULT NULL,
  `exerciseExp` int(4) DEFAULT NULL,
  `maxSkillNum` int(4) DEFAULT NULL,
  `skills` varbinary(2048) DEFAULT NULL,
  `life` int(4) DEFAULT NULL,
  `atkPowerGrowUp_Max` int(4) NOT NULL DEFAULT '0',
  `defClassGrowUp_Max` int(4) NOT NULL DEFAULT '0',
  `hpGrowUp_Max` int(4) NOT NULL DEFAULT '0',
  `benison_Value` int(4) NOT NULL DEFAULT '0',
  UNIQUE KEY `id` (`id`),
  KEY `masterId` (`masterId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of petproperty_gamedata
-- ----------------------------

-- ----------------------------
-- Table structure for `platform_senditem`
-- ----------------------------
DROP TABLE IF EXISTS `platform_senditem`;
CREATE TABLE `platform_senditem` (
  `id` int(4) NOT NULL AUTO_INCREMENT,
  `levelMin` int(4) NOT NULL,
  `levelMax` int(4) NOT NULL,
  `itemList` varchar(32) NOT NULL,
  `money` int(4) NOT NULL,
  `money_b` int(4) NOT NULL,
  `gold` int(4) NOT NULL,
  `gold_b` int(4) NOT NULL,
  `exp` int(4) NOT NULL,
  `flag` int(4) NOT NULL,
  `timeBegin` bigint(8) NOT NULL,
  `timeEnd` bigint(8) NOT NULL,
  `title` varchar(255) NOT NULL DEFAULT '',
  `content` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of platform_senditem
-- ----------------------------

-- ----------------------------
-- Table structure for `playercompletedtask`
-- ----------------------------
DROP TABLE IF EXISTS `playercompletedtask`;
CREATE TABLE `playercompletedtask` (
  `playerID` bigint(8) NOT NULL,
  `taskIDList` varbinary(4096) DEFAULT NULL,
  UNIQUE KEY `playerID` (`playerID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of playercompletedtask
-- ----------------------------
INSERT INTO `playercompletedtask` VALUES ('31595566135771137', 0x836B000464656667);
INSERT INTO `playercompletedtask` VALUES ('31595566135771138', 0x836B000164);

-- ----------------------------
-- Table structure for `playerconvoy`
-- ----------------------------
DROP TABLE IF EXISTS `playerconvoy`;
CREATE TABLE `playerconvoy` (
  `playerID` bigint(8) NOT NULL,
  `taskID` int(4) NOT NULL,
  `beginTime` int(4) NOT NULL DEFAULT '0',
  `remainTime` int(4) NOT NULL DEFAULT '0',
  `lowConvoyCD` tinyint(4) NOT NULL DEFAULT '0',
  `highConvoyCD` tinyint(4) NOT NULL DEFAULT '0',
  `curConvoyType` tinyint(4) NOT NULL DEFAULT '0',
  `curCarriageQuality` tinyint(4) NOT NULL DEFAULT '0',
  `deadCnt` tinyint(4) NOT NULL DEFAULT '0',
  `remainConvoyFreeRefreshCnt` tinyint(4) NOT NULL DEFAULT '0',
  UNIQUE KEY `playerID` (`playerID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of playerconvoy
-- ----------------------------
INSERT INTO `playerconvoy` VALUES ('31595566135771137', '0', '0', '0', '2', '1', '0', '0', '0', '3');

-- ----------------------------
-- Table structure for `playerdaily`
-- ----------------------------
DROP TABLE IF EXISTS `playerdaily`;
CREATE TABLE `playerdaily` (
  `playerID` bigint(8) DEFAULT NULL,
  `activeValue` int(4) DEFAULT '0',
  `resetTime` int(4) DEFAULT '0',
  `dailyList` varbinary(1024) DEFAULT NULL,
  UNIQUE KEY `playerID` (`playerID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of playerdaily
-- ----------------------------
INSERT INTO `playerdaily` VALUES ('31595566135771137', '0', '1375243200', 0x835000000119789CCB616060E0CE604E61104849CCCCA974CBCCCB2CCE70CE2FCD2B49E44C64C02EC1864B821D97042B2E09165C121CB82498714930E192E0C625C1854B823191210B000D525A6E);
INSERT INTO `playerdaily` VALUES ('31595566135771138', '0', '1374897600', 0x835000000119789CCB616060E0CE604E61104849CCCCA974CBCCCB2CCE70CE2FCD2B49E44C64C02EC1864B821D97042B2E09165C121CB82498714930E192E0C625C1854B823191210B000D525A6E);

-- ----------------------------
-- Table structure for `playerequipenhancelevel`
-- ----------------------------
DROP TABLE IF EXISTS `playerequipenhancelevel`;
CREATE TABLE `playerequipenhancelevel` (
  `playerId` bigint(8) DEFAULT NULL,
  `ring` binary(64) DEFAULT NULL,
  `weapon` binary(64) DEFAULT NULL,
  `cap` binary(64) DEFAULT NULL,
  `shoulder` binary(64) DEFAULT NULL,
  `pants` binary(64) DEFAULT NULL,
  `hand` binary(64) DEFAULT NULL,
  `coat` binary(64) DEFAULT NULL,
  `belt` binary(64) DEFAULT NULL,
  `shoe` binary(64) DEFAULT NULL,
  `accessories` binary(64) DEFAULT NULL,
  `wing` binary(64) DEFAULT NULL,
  `fashion` binary(64) DEFAULT NULL,
  UNIQUE KEY `playerId` (`playerId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of playerequipenhancelevel
-- ----------------------------
INSERT INTO `playerequipenhancelevel` VALUES ('31595566135771137', 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000);
INSERT INTO `playerequipenhancelevel` VALUES ('31595566135771138', 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000, 0x836804640014706C6179657245717569704C6576656C496E666F6100610061000000000000000000000000000000000000000000000000000000000000000000);

-- ----------------------------
-- Table structure for `playerequipitem`
-- ----------------------------
DROP TABLE IF EXISTS `playerequipitem`;
CREATE TABLE `playerequipitem` (
  `id` int(4) NOT NULL,
  `playerId` bigint(8) DEFAULT NULL,
  `equipid` int(4) DEFAULT NULL,
  `type` int(4) DEFAULT NULL,
  `quality` int(4) DEFAULT NULL,
  `isEquiped` int(4) DEFAULT NULL,
  `propertyTypeValueArray` varbinary(1024) DEFAULT NULL,
  UNIQUE KEY `id` (`id`,`playerId`),
  KEY `K_equipitem_playerId` (`playerId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of playerequipitem
-- ----------------------------
INSERT INTO `playerequipitem` VALUES ('1', '31595566135771137', '1', '1', '0', '1', 0x836805640005617272617961056100680464001170726F70657274795479706556616C7565610061006100610A);
INSERT INTO `playerequipitem` VALUES ('23', '31595566135771138', '23', '1', '0', '1', 0x836805640005617272617961056100680464001170726F70657274795479706556616C7565610061006100610A);

-- ----------------------------
-- Table structure for `playeronhook`
-- ----------------------------
DROP TABLE IF EXISTS `playeronhook`;
CREATE TABLE `playeronhook` (
  `PlayerID` bigint(8) NOT NULL COMMENT '用户ＩＤ值',
  `content` varbinary(255) NOT NULL COMMENT '设置内容',
  UNIQUE KEY `PlayerID` (`PlayerID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of playeronhook
-- ----------------------------
INSERT INTO `playeronhook` VALUES ('31595566135771137', 0x320000003200000000000000000000000000000000000000000000000000000000000000000000000000000000000000);
INSERT INTO `playeronhook` VALUES ('31595566135771138', 0x320000003200000000000000000000000000000000000000000000000000000000000000000000000000000000000000);

-- ----------------------------
-- Table structure for `playerpetsealahs`
-- ----------------------------
DROP TABLE IF EXISTS `playerpetsealahs`;
CREATE TABLE `playerpetsealahs` (
  `playerId` bigint(8) NOT NULL,
  `skillIds` varbinary(2048) DEFAULT NULL,
  UNIQUE KEY `playerId` (`playerId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of playerpetsealahs
-- ----------------------------
INSERT INTO `playerpetsealahs` VALUES ('31595566135771137', 0x836A);
INSERT INTO `playerpetsealahs` VALUES ('31595566135771138', 0x836A);

-- ----------------------------
-- Table structure for `playersignin`
-- ----------------------------
DROP TABLE IF EXISTS `playersignin`;
CREATE TABLE `playersignin` (
  `playerID` bigint(8) NOT NULL,
  `alreadyDays` int(4) NOT NULL DEFAULT '0',
  `lastSignTime` int(4) NOT NULL DEFAULT '0',
  UNIQUE KEY `playerID` (`playerID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of playersignin
-- ----------------------------

-- ----------------------------
-- Table structure for `playerskill_gamedata`
-- ----------------------------
DROP TABLE IF EXISTS `playerskill_gamedata`;
CREATE TABLE `playerskill_gamedata` (
  `playerId` bigint(8) DEFAULT NULL,
  `skillId` int(4) DEFAULT NULL,
  `coolDownTime` int(4) DEFAULT NULL,
  `activationSkillID1` int(4) DEFAULT NULL,
  `activationSkillID2` int(4) DEFAULT NULL,
  `curBindedSkillID` int(4) DEFAULT NULL,
  UNIQUE KEY `playerIdandSkillId` (`playerId`,`skillId`),
  KEY `playerId` (`playerId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of playerskill_gamedata
-- ----------------------------
INSERT INTO `playerskill_gamedata` VALUES ('31595566135771137', '1', '1375198423', '0', '0', '0');
INSERT INTO `playerskill_gamedata` VALUES ('31595566135771138', '141', '0', '0', '0', '0');

-- ----------------------------
-- Table structure for `playertask_gamedata`
-- ----------------------------
DROP TABLE IF EXISTS `playertask_gamedata`;
CREATE TABLE `playertask_gamedata` (
  `id` bigint(8) NOT NULL,
  `taskID` int(4) DEFAULT NULL,
  `playerID` bigint(8) DEFAULT NULL,
  `state` int(4) DEFAULT NULL,
  `aimProgressList` varbinary(2048) DEFAULT NULL,
  UNIQUE KEY `id` (`id`),
  KEY `playerID` (`playerID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of playertask_gamedata
-- ----------------------------
INSERT INTO `playertask_gamedata` VALUES ('32439991065903111', '104', '31595566135771137', '0', 0x836C00000001680564000B61696D50726F677265737361016100610061006A);
INSERT INTO `playertask_gamedata` VALUES ('32439991065903107', '101', '31595566135771138', '0', 0x836C00000001680564000B61696D50726F677265737361016100610061006A);

-- ----------------------------
-- Table structure for `player_gamedata`
-- ----------------------------
DROP TABLE IF EXISTS `player_gamedata`;
CREATE TABLE `player_gamedata` (
  `id` bigint(8) NOT NULL,
  `NAME` char(32) DEFAULT NULL,
  `userId` bigint(8) DEFAULT NULL,
  `map_data_id` int(4) DEFAULT NULL,
  `mapId` bigint(8) DEFAULT NULL,
  `X` int(4) DEFAULT NULL,
  `Y` int(4) DEFAULT NULL,
  `LEVEL` int(4) DEFAULT NULL,
  `camp` int(4) DEFAULT NULL,
  `faction` int(4) DEFAULT NULL,
  `sex` int(4) DEFAULT NULL,
  `crossServerHonor` int(4) DEFAULT NULL,
  `unionContribute` int(4) DEFAULT NULL,
  `competMoney` int(4) DEFAULT NULL,
  `weekCompet` int(4) DEFAULT NULL,
  `battleHonor` int(4) DEFAULT NULL,
  `aura` int(4) DEFAULT NULL,
  `charm` int(4) DEFAULT NULL,
  `vip` int(4) DEFAULT NULL,
  `maxEnabledBagCells` int(4) DEFAULT NULL,
  `maxEnabledStorageBagCells` int(4) DEFAULT NULL,
  `storageBagPassWord` char(32) DEFAULT '',
  `unlockTimes` int(4) DEFAULT NULL,
  `money` int(4) DEFAULT NULL,
  `moneyBinded` int(4) DEFAULT NULL,
  `gold` int(4) DEFAULT '0',
  `goldBinded` int(4) DEFAULT NULL,
  `ticket` int(4) DEFAULT NULL,
  `guildContribute` int(4) DEFAULT NULL,
  `honor` int(4) DEFAULT NULL,
  `credit` int(4) DEFAULT NULL,
  `life` int(4) DEFAULT NULL,
  `exp` int(4) DEFAULT NULL,
  `lastOnlineTime` int(4) DEFAULT NULL,
  `lastOfflineTime` int(4) DEFAULT NULL,
  `isOnline` int(4) DEFAULT NULL,
  `createTime` int(4) DEFAULT NULL,
  `guildID` bigint(8) DEFAULT NULL,
  `conBankLastFindTime` int(4) DEFAULT NULL,
  `chatLastSpeakTime` int(4) DEFAULT NULL,
  `outFightPet` bigint(8) DEFAULT NULL,
  `mapCDInfoList` varbinary(1024) DEFAULT NULL,
  `pK_Kill_Value` int(4) DEFAULT NULL,
  `pK_Kill_OpenTime` int(4) DEFAULT NULL,
  `pk_Kill_Punish` tinyint(4) NOT NULL DEFAULT '0',
  `playerMountInfo` varbinary(1024) DEFAULT NULL,
  `playerItemCDInfo` varbinary(1024) DEFAULT NULL,
  `bloodPoolLife` int(4) DEFAULT '0',
  `playerItem_DailyCountInfo` varbinary(1024) DEFAULT NULL,
  `gmLevel` int(4) DEFAULT '0',
  `petBloodPoolLife` int(4) DEFAULT '0',
  `fightingCapacity` int(4) NOT NULL DEFAULT '0',
  `fightingCapacityTop` int(4) NOT NULL DEFAULT '0',
  `platSendItemBits` varbinary(100) DEFAULT NULL,
  `gameSetMenu` varbinary(128) DEFAULT NULL,
  `rechargeAmmount` int(4) NOT NULL DEFAULT '0',
  `varArray` varbinary(512) DEFAULT NULL,
  `forbidChatFlag` int(4) NOT NULL DEFAULT '0',
  `protectPwd` char(32) NOT NULL DEFAULT '',
  `reasureBowlData` varbinary(40) DEFAULT NULL,
  `taskSpecialData` varbinary(80) DEFAULT NULL,
  `exp15add` int(4) NOT NULL DEFAULT '0' COMMENT '1.5倍经验加成',
  `exp20add` int(4) NOT NULL DEFAULT '0' COMMENT '2.0倍经验加成',
  `exp30add` int(4) NOT NULL DEFAULT '0' COMMENT '3.0倍经验加成',
  `isDelete` tinyint(4) NOT NULL DEFAULT '0',
  `goldPassWord` char(32) NOT NULL DEFAULT '',
  `goldPassWordUnlockTimes` int(4) NOT NULL DEFAULT '0',
  `vipLevel` int(4) NOT NULL DEFAULT '0',
  `vipTimeExpire` int(4) NOT NULL DEFAULT '0',
  `vipTimeBuy` int(4) NOT NULL DEFAULT '0',
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `NAME` (`NAME`),
  KEY `userId` (`userId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of player_gamedata
-- ----------------------------
INSERT INTO `player_gamedata` VALUES ('31595566135771137', '占流觞', '4943404278480897', '1', '32369622321729320', '1553', '2353', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '36', '20', '', '0', '0', '69', '0', '0', '0', '0', '0', '0', '273', '182', '1375198275', '1375227261', '0', '1374620110', '0', '0', '0', '0', 0x836A, '0', '0', '0', 0x836A, 0x836A, '0', 0x836A, '0', '0', '478', '478', '', 0x83500000003F789CCB104A619028C88E770F0ECF2CC9088D774FCC4D0D4E2DF14DCD2B8D374E6484C31420648043109B11C40200658F118B, '0', 0x835000000118789CCB604D61604D2C2A4AAC4C344B4C4961E02CCD4B494DCBCC4B4DC9E0CEE042E6E362273201216322034E79860CAE4406306484D04499CA058244BA80281389B71504011ED45894, '0', '', 0x83680564000F72656173757265426F776C446174616100610061006100, 0x83680864000F7461736B5370656369616C446174616101610062000019786100610061006100, '0', '0', '0', '0', '', '0', '0', '0', '0');
INSERT INTO `player_gamedata` VALUES ('31595566135771138', '大大佩洲', '4943404278480898', '1', '32369622321729320', '2230', '1650', '1', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '36', '20', '', '0', '0', '2', '0', '0', '0', '0', '0', '0', '199', '4', '1374789586', '1374818987', '0', '1374789584', '0', '0', '0', '0', 0x836A, '0', '0', '0', 0x836A, 0x836A, '0', 0x836A, '0', '0', '441', '441', '', 0x83500000003F789CCB104A619028C88E770F0ECF2CC9088D774FCC4D0D4E2DF14DCD2B8D374E6484C31420648043109B11C40200658F118B, '0', 0x8350000000F0789CCB604D61604D2C2A4AAC4CE44B4C4961E02CCD4B494DCBCC4B4DC9E0CEE042E6E3622732012123312A514CC769762203E9A6E1348B0B1D02009A8C4D1F, '0', '', 0x83680564000F72656173757265426F776C446174616100610061006100, 0x83680864000F7461736B5370656369616C446174616101610062000019646100610061006100, '0', '0', '0', '0', '', '0', '0', '0', '0');

-- ----------------------------
-- Table structure for `r_itemdb`
-- ----------------------------
DROP TABLE IF EXISTS `r_itemdb`;
CREATE TABLE `r_itemdb` (
  `id` bigint(8) NOT NULL,
  `owner_type` int(4) DEFAULT NULL,
  `owner_id` bigint(8) DEFAULT NULL,
  `location` int(4) DEFAULT NULL,
  `cell` int(4) DEFAULT NULL,
  `amount` int(4) DEFAULT NULL,
  `item_data_id` int(4) DEFAULT NULL,
  `param1` int(4) DEFAULT NULL,
  `param2` int(4) DEFAULT NULL,
  `binded` int(4) DEFAULT NULL,
  `expiration_time` int(4) DEFAULT NULL,
  UNIQUE KEY `id` (`id`),
  KEY `owner_id` (`owner_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of r_itemdb
-- ----------------------------
INSERT INTO `r_itemdb` VALUES ('32791834786791425', '1', '31595566135771138', '0', '0', '1', '2020', '71', '0', '1', '0');
INSERT INTO `r_itemdb` VALUES ('32791834786791426', '1', '31595566135771137', '0', '0', '1', '2020', '71', '0', '1', '0');
INSERT INTO `r_itemdb` VALUES ('32791834786791427', '1', '31595566135771137', '0', '1', '99', '15', '23', '0', '1', '0');
INSERT INTO `r_itemdb` VALUES ('32791834786791428', '1', '31595566135771137', '0', '2', '1', '15', '23', '0', '1', '0');

-- ----------------------------
-- Table structure for `r_playerbag`
-- ----------------------------
DROP TABLE IF EXISTS `r_playerbag`;
CREATE TABLE `r_playerbag` (
  `id` bigint(8) NOT NULL,
  `location` int(4) DEFAULT NULL,
  `cell` int(4) DEFAULT NULL,
  `playerID` bigint(8) DEFAULT NULL,
  `itemDBID` bigint(8) DEFAULT NULL,
  `enable` int(4) DEFAULT NULL,
  `lockID` int(4) DEFAULT NULL,
  UNIQUE KEY `id` (`id`),
  KEY `playerID` (`playerID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of r_playerbag
-- ----------------------------
INSERT INTO `r_playerbag` VALUES ('33214047251857409', '0', '0', '31595566135771137', '32791834786791426', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857410', '0', '1', '31595566135771137', '32791834786791427', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857411', '0', '2', '31595566135771137', '32791834786791428', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857412', '0', '3', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857413', '0', '4', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857414', '0', '5', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857415', '0', '6', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857416', '0', '7', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857417', '0', '8', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857418', '0', '9', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857419', '0', '10', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857420', '0', '11', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857421', '0', '12', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857422', '0', '13', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857423', '0', '14', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857424', '0', '15', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857425', '0', '16', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857426', '0', '17', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857427', '0', '18', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857428', '0', '19', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857429', '0', '20', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857430', '0', '21', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857431', '0', '22', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857432', '0', '23', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857433', '0', '24', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857434', '0', '25', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857435', '0', '26', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857436', '0', '27', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857437', '0', '28', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857438', '0', '29', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857439', '0', '30', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857440', '0', '31', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857441', '0', '32', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857442', '0', '33', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857443', '0', '34', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857444', '0', '35', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857445', '0', '36', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857446', '0', '37', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857447', '0', '38', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857448', '0', '39', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857449', '0', '40', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857450', '0', '41', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857451', '0', '42', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857452', '0', '43', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857453', '0', '44', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857454', '0', '45', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857455', '0', '46', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857456', '0', '47', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857457', '0', '48', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857458', '0', '49', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857459', '0', '50', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857460', '0', '51', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857461', '0', '52', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857462', '0', '53', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857463', '0', '54', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857464', '0', '55', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857465', '0', '56', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857466', '0', '57', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857467', '0', '58', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857468', '0', '59', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857469', '0', '60', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857470', '0', '61', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857471', '0', '62', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857472', '0', '63', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857473', '0', '64', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857474', '0', '65', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857475', '0', '66', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857476', '0', '67', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857477', '0', '68', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857478', '0', '69', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857479', '0', '70', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857480', '0', '71', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857481', '0', '72', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857482', '0', '73', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857483', '0', '74', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857484', '0', '75', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857485', '0', '76', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857486', '0', '77', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857487', '0', '78', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857488', '0', '79', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857489', '0', '80', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857490', '0', '81', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857491', '0', '82', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857492', '0', '83', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857493', '0', '84', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857494', '0', '85', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857495', '0', '86', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857496', '0', '87', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857497', '0', '88', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857498', '0', '89', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857499', '1', '0', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857500', '1', '1', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857501', '1', '2', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857502', '1', '3', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857503', '1', '4', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857504', '1', '5', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857505', '1', '6', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857506', '1', '7', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857507', '1', '8', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857508', '1', '9', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857509', '1', '10', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857510', '1', '11', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857511', '1', '12', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857512', '1', '13', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857513', '1', '14', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857514', '1', '15', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857515', '1', '16', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857516', '1', '17', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857517', '1', '18', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857518', '1', '19', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857519', '1', '20', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857520', '1', '21', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857521', '1', '22', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857522', '1', '23', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857523', '1', '24', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857524', '1', '25', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857525', '1', '26', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857526', '1', '27', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857527', '1', '28', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857528', '1', '29', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857529', '1', '30', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857530', '1', '31', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857531', '1', '32', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857532', '1', '33', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857533', '1', '34', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857534', '1', '35', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857535', '1', '36', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857536', '1', '37', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857537', '1', '38', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857538', '1', '39', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857539', '1', '40', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857540', '1', '41', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857541', '1', '42', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857542', '1', '43', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857543', '1', '44', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857544', '1', '45', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857545', '1', '46', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857546', '1', '47', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857547', '1', '48', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857548', '1', '49', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857549', '1', '50', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857550', '1', '51', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857551', '1', '52', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857552', '1', '53', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857553', '1', '54', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857554', '1', '55', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857555', '1', '56', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857556', '1', '57', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857557', '1', '58', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857558', '1', '59', '31595566135771137', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857559', '2', '0', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857560', '2', '1', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857561', '2', '2', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857562', '2', '3', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857563', '2', '4', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857564', '2', '5', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857565', '2', '6', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857566', '2', '7', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857567', '2', '8', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857568', '2', '9', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857569', '2', '10', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857570', '2', '11', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857571', '2', '12', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857572', '2', '13', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857573', '2', '14', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857574', '2', '15', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857575', '2', '16', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857576', '2', '17', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857577', '2', '18', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857578', '2', '19', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857579', '2', '20', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857580', '2', '21', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857581', '2', '22', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857582', '2', '23', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857583', '2', '24', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857584', '2', '25', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857585', '2', '26', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857586', '2', '27', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857587', '2', '28', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857588', '2', '29', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857589', '5', '0', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857590', '5', '1', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857591', '5', '2', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857592', '5', '3', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857593', '5', '4', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857594', '5', '5', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857595', '5', '6', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857596', '5', '7', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857597', '5', '8', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857598', '5', '9', '31595566135771137', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857599', '0', '0', '31595566135771138', '32791834786791425', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857600', '0', '1', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857601', '0', '2', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857602', '0', '3', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857603', '0', '4', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857604', '0', '5', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857605', '0', '6', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857606', '0', '7', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857607', '0', '8', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857608', '0', '9', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857609', '0', '10', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857610', '0', '11', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857611', '0', '12', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857612', '0', '13', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857613', '0', '14', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857614', '0', '15', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857615', '0', '16', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857616', '0', '17', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857617', '0', '18', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857618', '0', '19', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857619', '0', '20', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857620', '0', '21', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857621', '0', '22', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857622', '0', '23', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857623', '0', '24', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857624', '0', '25', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857625', '0', '26', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857626', '0', '27', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857627', '0', '28', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857628', '0', '29', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857629', '0', '30', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857630', '0', '31', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857631', '0', '32', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857632', '0', '33', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857633', '0', '34', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857634', '0', '35', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857635', '0', '36', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857636', '0', '37', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857637', '0', '38', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857638', '0', '39', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857639', '0', '40', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857640', '0', '41', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857641', '0', '42', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857642', '0', '43', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857643', '0', '44', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857644', '0', '45', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857645', '0', '46', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857646', '0', '47', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857647', '0', '48', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857648', '0', '49', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857649', '0', '50', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857650', '0', '51', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857651', '0', '52', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857652', '0', '53', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857653', '0', '54', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857654', '0', '55', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857655', '0', '56', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857656', '0', '57', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857657', '0', '58', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857658', '0', '59', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857659', '0', '60', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857660', '0', '61', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857661', '0', '62', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857662', '0', '63', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857663', '0', '64', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857664', '0', '65', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857665', '0', '66', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857666', '0', '67', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857667', '0', '68', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857668', '0', '69', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857669', '0', '70', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857670', '0', '71', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857671', '0', '72', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857672', '0', '73', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857673', '0', '74', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857674', '0', '75', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857675', '0', '76', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857676', '0', '77', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857677', '0', '78', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857678', '0', '79', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857679', '0', '80', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857680', '0', '81', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857681', '0', '82', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857682', '0', '83', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857683', '0', '84', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857684', '0', '85', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857685', '0', '86', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857686', '0', '87', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857687', '0', '88', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857688', '0', '89', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857689', '1', '0', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857690', '1', '1', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857691', '1', '2', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857692', '1', '3', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857693', '1', '4', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857694', '1', '5', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857695', '1', '6', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857696', '1', '7', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857697', '1', '8', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857698', '1', '9', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857699', '1', '10', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857700', '1', '11', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857701', '1', '12', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857702', '1', '13', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857703', '1', '14', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857704', '1', '15', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857705', '1', '16', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857706', '1', '17', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857707', '1', '18', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857708', '1', '19', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857709', '1', '20', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857710', '1', '21', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857711', '1', '22', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857712', '1', '23', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857713', '1', '24', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857714', '1', '25', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857715', '1', '26', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857716', '1', '27', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857717', '1', '28', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857718', '1', '29', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857719', '1', '30', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857720', '1', '31', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857721', '1', '32', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857722', '1', '33', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857723', '1', '34', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857724', '1', '35', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857725', '1', '36', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857726', '1', '37', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857727', '1', '38', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857728', '1', '39', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857729', '1', '40', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857730', '1', '41', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857731', '1', '42', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857732', '1', '43', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857733', '1', '44', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857734', '1', '45', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857735', '1', '46', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857736', '1', '47', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857737', '1', '48', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857738', '1', '49', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857739', '1', '50', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857740', '1', '51', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857741', '1', '52', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857742', '1', '53', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857743', '1', '54', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857744', '1', '55', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857745', '1', '56', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857746', '1', '57', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857747', '1', '58', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857748', '1', '59', '31595566135771138', '0', '0', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857749', '2', '0', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857750', '2', '1', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857751', '2', '2', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857752', '2', '3', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857753', '2', '4', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857754', '2', '5', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857755', '2', '6', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857756', '2', '7', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857757', '2', '8', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857758', '2', '9', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857759', '2', '10', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857760', '2', '11', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857761', '2', '12', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857762', '2', '13', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857763', '2', '14', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857764', '2', '15', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857765', '2', '16', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857766', '2', '17', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857767', '2', '18', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857768', '2', '19', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857769', '2', '20', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857770', '2', '21', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857771', '2', '22', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857772', '2', '23', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857773', '2', '24', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857774', '2', '25', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857775', '2', '26', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857776', '2', '27', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857777', '2', '28', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857778', '2', '29', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857779', '5', '0', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857780', '5', '1', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857781', '5', '2', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857782', '5', '3', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857783', '5', '4', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857784', '5', '5', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857785', '5', '6', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857786', '5', '7', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857787', '5', '8', '31595566135771138', '0', '1', '0');
INSERT INTO `r_playerbag` VALUES ('33214047251857788', '5', '9', '31595566135771138', '0', '1', '0');

-- ----------------------------
-- Table structure for `shortcut`
-- ----------------------------
DROP TABLE IF EXISTS `shortcut`;
CREATE TABLE `shortcut` (
  `playerID` bigint(8) NOT NULL,
  `index1ID` int(4) DEFAULT NULL,
  `index2ID` int(4) DEFAULT NULL,
  `index3ID` int(4) DEFAULT NULL,
  `index4ID` int(4) DEFAULT NULL,
  `index5ID` int(4) DEFAULT NULL,
  `index6ID` int(4) DEFAULT NULL,
  `index7ID` int(4) DEFAULT NULL,
  `index8ID` int(4) DEFAULT NULL,
  `index9ID` int(4) DEFAULT NULL,
  `index10ID` int(4) DEFAULT NULL,
  `index11ID` int(4) DEFAULT NULL,
  `index12ID` int(4) DEFAULT NULL,
  UNIQUE KEY `playerID` (`playerID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of shortcut
-- ----------------------------
INSERT INTO `shortcut` VALUES ('31595566135771137', '16777217', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `shortcut` VALUES ('31595566135771138', '16777357', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');

-- ----------------------------
-- Table structure for `top_player_fighting_capacity`
-- ----------------------------
DROP TABLE IF EXISTS `top_player_fighting_capacity`;
CREATE TABLE `top_player_fighting_capacity` (
  `top` int(4) NOT NULL AUTO_INCREMENT,
  `playerid` bigint(8) NOT NULL,
  `name` varchar(32) NOT NULL,
  `camp` int(4) NOT NULL,
  `level` int(4) NOT NULL,
  `fighting_capacity` int(4) NOT NULL,
  `sex` int(4) NOT NULL DEFAULT '0',
  `weapon` int(4) NOT NULL DEFAULT '0',
  `coat` int(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`top`),
  UNIQUE KEY `id` (`playerid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of top_player_fighting_capacity
-- ----------------------------

-- ----------------------------
-- Table structure for `top_player_level`
-- ----------------------------
DROP TABLE IF EXISTS `top_player_level`;
CREATE TABLE `top_player_level` (
  `top` int(4) NOT NULL AUTO_INCREMENT,
  `playerid` bigint(8) NOT NULL,
  `name` char(32) NOT NULL,
  `camp` int(4) NOT NULL,
  `level` int(4) NOT NULL,
  `fighting_capacity` int(4) NOT NULL,
  `sex` int(4) NOT NULL DEFAULT '0',
  `weapon` int(4) NOT NULL DEFAULT '0',
  `coat` int(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`top`),
  UNIQUE KEY `id` (`playerid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of top_player_level
-- ----------------------------

-- ----------------------------
-- Table structure for `top_player_money`
-- ----------------------------
DROP TABLE IF EXISTS `top_player_money`;
CREATE TABLE `top_player_money` (
  `top` int(4) NOT NULL AUTO_INCREMENT,
  `playerid` bigint(8) NOT NULL,
  `name` char(32) NOT NULL,
  `camp` int(4) NOT NULL,
  `level` int(4) NOT NULL,
  `money` int(4) NOT NULL,
  `sex` int(4) NOT NULL DEFAULT '0',
  `weapon` int(4) NOT NULL DEFAULT '0',
  `coat` int(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`top`),
  UNIQUE KEY `id` (`playerid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of top_player_money
-- ----------------------------

-- ----------------------------
-- Table structure for `transfer_account_recharge`
-- ----------------------------
DROP TABLE IF EXISTS `transfer_account_recharge`;
CREATE TABLE `transfer_account_recharge` (
  `account` char(32) NOT NULL DEFAULT '',
  `platId` int(4) NOT NULL DEFAULT '0',
  `rechargeRmb` int(4) DEFAULT '0',
  PRIMARY KEY (`account`,`platId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of transfer_account_recharge
-- ----------------------------

-- ----------------------------
-- Table structure for `worldvar_data`
-- ----------------------------
DROP TABLE IF EXISTS `worldvar_data`;
CREATE TABLE `worldvar_data` (
  `id` int(4) NOT NULL,
  `varArray` varbinary(1024) DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of worldvar_data
-- ----------------------------
INSERT INTO `worldvar_data` VALUES ('1', 0x8350000000FD789CCB604D61604D2C2A4AAC4C34494C4961E02CCD4B494DCBCC4B4DC9E0CEE042E627322405FEF23D90C8802C48093B910B02D1AC61A496F984EC4DE4020086595357);

-- ----------------------------
-- Procedure structure for `sp_name`
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_name`;
DELIMITER ;;
CREATE DEFINER=``@`` PROCEDURE `sp_name`()
select * from player
;;
DELIMITER ;
