-- phpMyAdmin SQL Dump
-- version 4.1.14
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: 2014-10-11 08:03:34
-- 服务器版本： 5.0.87-community-nt
-- PHP Version: 5.5.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `fxservergamedata`
--

-- --------------------------------------------------------

--
-- 表的结构 `across_continue_win_rank`
--

CREATE TABLE IF NOT EXISTS `across_continue_win_rank` (
  `player_id` bigint(20) NOT NULL default '0' COMMENT '玩家ID',
  `continue_win_num` int(11) default '0' COMMENT '连胜场数',
  `win_time` int(11) default '0' COMMENT '完成连胜时间',
  PRIMARY KEY  (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `across_win_rank`
--

CREATE TABLE IF NOT EXISTS `across_win_rank` (
  `player_id` bigint(20) NOT NULL default '0' COMMENT '玩家ID',
  `win_num` int(11) default '0' COMMENT '胜利场数',
  `win_time` int(11) default '0' COMMENT '达到胜利时间',
  PRIMARY KEY  (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `active_value`
--

CREATE TABLE IF NOT EXISTS `active_value` (
  `player_Id` bigint(20) NOT NULL default '0' COMMENT '玩家ID',
  `active_info` text COMMENT '活跃信息',
  `award_info` text COMMENT '奖励信息',
  PRIMARY KEY  (`player_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `bazzaritem`
--

CREATE TABLE IF NOT EXISTS `bazzaritem` (
  `db_id` int(4) NOT NULL,
  `item_data_id` int(4) NOT NULL,
  `item_column` int(4) NOT NULL,
  `gold` int(4) default '0',
  `binded_gold` int(4) default '0',
  `init_count` int(4) default '0',
  `remain_count` int(4) default '0',
  `end_time` int(4) NOT NULL,
  UNIQUE KEY `bazzar_db_id` USING BTREE (`db_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `consalesitemdb`
--

CREATE TABLE IF NOT EXISTS `consalesitemdb` (
  `conSalesId` bigint(8) NOT NULL,
  `conSalesType` int(4) default '0',
  `conSalesMoney` int(4) default NULL,
  `groundingTime` int(4) default NULL,
  `timeType` int(4) default NULL,
  `playerId` bigint(8) default NULL,
  `itemDBId` bigint(8) default NULL,
  UNIQUE KEY `conSalesId` USING BTREE (`conSalesId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `coupongift`
--

CREATE TABLE IF NOT EXISTS `coupongift` (
  `playerId` bigint(20) NOT NULL,
  `daysRechargeGift` tinyint(4) default NULL,
  `daysRechargeTime` int(11) default NULL,
  `firstRechargeGift` tinyint(4) default NULL,
  PRIMARY KEY  (`playerId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `dbinfo`
--

CREATE TABLE IF NOT EXISTS `dbinfo` (
  `name` char(64) default NULL,
  `value` int(4) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 转存表中的数据 `dbinfo`
--

INSERT INTO `dbinfo` (`name`, `value`) VALUES
('vesion', 6);

-- --------------------------------------------------------

--
-- 表的结构 `drawreward`
--

CREATE TABLE IF NOT EXISTS `drawreward` (
  `playerId` bigint(20) default NULL,
  `itemList` varbinary(1000) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- 表的结构 `equipment`
--

CREATE TABLE IF NOT EXISTS `equipment` (
  `playerId` bigint(8) default NULL,
  `equipid` int(4) default NULL,
  `enhanceLv` smallint(6) default NULL,
  `blessing` smallint(6) default NULL,
  `level` smallint(6) default NULL,
  `levelPlan` smallint(6) default NULL,
  `inlayList` varbinary(2000) default NULL,
  `quality` smallint(6) default NULL,
  `type` smallint(6) default NULL,
  `career` smallint(6) default NULL,
  `fight` int(11) default NULL,
  `isActivate` tinyint(4) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- 表的结构 `flower`
--

CREATE TABLE IF NOT EXISTS `flower` (
  `player_id` bigint(20) NOT NULL default '0' COMMENT '玩家ID',
  `level` int(8) default '1' COMMENT '等级',
  `exp` int(8) default '0' COMMENT '经验',
  `progress` int(8) default '0' COMMENT '能量进度',
  `visit_flower_num` int(8) default '0' COMMENT '今天访问次数',
  `next_visit_time` int(11) default '0' COMMENT '下次可访问时间',
  `visited_friends_today` varbinary(4096) default 'NULL' COMMENT '今天已访问的好友',
  `next_harvest_time` int(11) default '0' COMMENT '下次可收获时节',
  `sum_visit_num` int(8) default '0' COMMENT '总访问次数',
  `rate_award_num` int(8) default '0' COMMENT '翻牌领奖次数',
  `next_award_time` int(11) default '0' COMMENT '下次可翻牌领奖时间',
  `visit_log` text character set utf8 COMMENT '访问日志',
  PRIMARY KEY  (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- 表的结构 `friendbless`
--

CREATE TABLE IF NOT EXISTS `friendbless` (
  `playerId` bigint(11) NOT NULL,
  `charmTotal` int(11) NOT NULL default '0' COMMENT '总魅力',
  `charmWeek` int(11) NOT NULL default '0' COMMENT '周魅力',
  `newCharmWeek` int(11) NOT NULL,
  `reputation` int(11) NOT NULL default '0' COMMENT '声望',
  `freeBless` tinyint(4) NOT NULL default '1' COMMENT '每天免费赠送次数',
  `sex` tinyint(4) NOT NULL,
  `level` smallint(6) NOT NULL,
  `name` char(200) NOT NULL,
  `career` smallint(6) NOT NULL default '0',
  `weapon` int(4) NOT NULL default '0',
  `coat` int(4) NOT NULL default '0',
  `rank` smallint(6) NOT NULL,
  `spareWheel` varbinary(1000) default NULL,
  `enableBless` tinyint(4) NOT NULL default '1',
  `flower` int(11) default '0',
  `faction` smallint(6) default '0' COMMENT '职业',
  `photoID` bigint(20) default '0',
  PRIMARY KEY  (`playerId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `friend_gamedata`
--

CREATE TABLE IF NOT EXISTS `friend_gamedata` (
  `id` bigint(8) NOT NULL,
  `playerID` bigint(8) default NULL,
  `friendType` int(4) default NULL,
  `friendID` bigint(8) default NULL,
  `friendName` char(32) default NULL,
  `friendSex` int(4) default NULL,
  `friendFace` int(4) default NULL,
  `friendClassType` int(4) default NULL,
  `friendValue` int(4) default NULL,
  `photoID` bigint(20) default '0' COMMENT '用户头像ID',
  UNIQUE KEY `id` USING BTREE (`id`),
  KEY `playerID` USING BTREE (`playerID`),
  KEY `K_friend_gamedata_friendID` USING BTREE (`friendID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `gemstone`
--

CREATE TABLE IF NOT EXISTS `gemstone` (
  `id` bigint(20) default NULL,
  `itemId` int(11) default NULL,
  `type` smallint(6) default NULL,
  `star` smallint(6) default NULL,
  `quality` smallint(6) default NULL,
  `playerId` bigint(20) default NULL,
  `location` smallint(6) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- 表的结构 `guildapplicant`
--

CREATE TABLE IF NOT EXISTS `guildapplicant` (
  `id` bigint(8) NOT NULL,
  `guildID` bigint(8) default NULL,
  `playerID` bigint(8) default NULL,
  `playerName` char(32) default NULL,
  `playerSex` int(4) default NULL,
  `zhanli` int(4) default NULL,
  `level` int(4) default NULL,
  `class` int(4) default NULL,
  `joinTime` int(4) default NULL,
  `photoID` bigint(20) default '0' COMMENT '用户头像ID',
  UNIQUE KEY `id` USING BTREE (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `guildbaseinfo_gamedata`
--

CREATE TABLE IF NOT EXISTS `guildbaseinfo_gamedata` (
  `id` bigint(8) NOT NULL,
  `chairmanPlayerID` bigint(8) default NULL,
  `level` int(4) default NULL,
  `faction` int(4) default NULL,
  `exp` int(4) default NULL,
  `chairmanPlayerName` char(32) default NULL,
  `guildName` char(32) default NULL,
  `affiche` varchar(255) default NULL,
  `createTime` int(4) default NULL,
  UNIQUE KEY `id` USING BTREE (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `guildmember_gamedata`
--

CREATE TABLE IF NOT EXISTS `guildmember_gamedata` (
  `id` bigint(8) NOT NULL,
  `guildID` bigint(8) default NULL,
  `playerID` bigint(8) default NULL,
  `rank` int(4) default NULL,
  `playerName` char(32) default NULL,
  `playerLevel` int(4) default NULL,
  `playerClass` int(4) default NULL,
  `playerSex` int(4) default NULL,
  `contribute` int(4) default NULL,
  `contributeMoney` int(4) default NULL,
  `contributeTime` int(4) default NULL,
  `joinTime` int(4) default NULL,
  `photoID` bigint(20) default '0' COMMENT '用户头像ID',
  `fight` int(11) default '0' COMMENT '战斗力',
  `totalContribute` int(11) default NULL,
  UNIQUE KEY `id` USING BTREE (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `innodb_lock_monitor`
--

CREATE TABLE IF NOT EXISTS `innodb_lock_monitor` (
  `x` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `innodb_monitor`
--

CREATE TABLE IF NOT EXISTS `innodb_monitor` (
  `a` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `mailrecord`
--

CREATE TABLE IF NOT EXISTS `mailrecord` (
  `id` bigint(8) NOT NULL,
  `type` int(4) default NULL,
  `recvPlayerID` bigint(8) default NULL,
  `isOpened` int(4) default NULL,
  `tiemOut` int(4) default NULL,
  `idSender` bigint(8) default NULL,
  `nameSender` char(32) default NULL,
  `title` char(255) default NULL,
  `content` char(255) default NULL,
  `attachItemDBID1` bigint(8) default NULL,
  `attachItemDataID1` int(11) default '0' COMMENT '附件1物品定义ID',
  `attachItemCount1` int(11) default '0' COMMENT '附件1物品数量',
  `attachItemDBID2` bigint(8) default NULL,
  `attachItemDataID2` int(11) default '0' COMMENT '附件2物品定义ID',
  `attachItemCount2` int(11) default '0' COMMENT '附件2物品数量',
  `moneySend` int(4) default NULL,
  `moneyPay` int(4) default NULL,
  `goldSend` int(4) default '0',
  `mailTimerType` int(4) default NULL,
  `mailRecTime` int(4) default NULL,
  UNIQUE KEY `id` USING BTREE (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `mine`
--

CREATE TABLE IF NOT EXISTS `mine` (
  `playerID` bigint(20) NOT NULL,
  `type` smallint(6) default NULL,
  `location` smallint(6) default NULL,
  `beginTime` int(11) default NULL,
  `time` int(11) default NULL,
  `totalTime` int(11) default NULL,
  `name` varbinary(255) default NULL,
  `sex` tinyint(4) default NULL,
  `vipLv` smallint(6) default NULL,
  `level` smallint(6) default NULL,
  `faction` smallint(6) default NULL,
  `weaponDataID` int(11) default NULL,
  `coatDataID` int(11) default NULL,
  `fightNum` smallint(6) default NULL,
  `buyNum` smallint(6) default NULL,
  `tarlocation` smallint(6) default NULL,
  `tartype` smallint(6) default NULL,
  PRIMARY KEY  (`playerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `objectbuffdb`
--

CREATE TABLE IF NOT EXISTS `objectbuffdb` (
  `id` bigint(8) NOT NULL,
  `buffList` varbinary(2048) default NULL,
  UNIQUE KEY `id` USING BTREE (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `petproperty_gamedata`
--

CREATE TABLE IF NOT EXISTS `petproperty_gamedata` (
  `id` bigint(8) NOT NULL,
  `data_id` int(4) default NULL,
  `masterId` bigint(8) default NULL,
  `level` int(4) default NULL,
  `exp` int(4) default NULL,
  `name` char(32) default NULL,
  `titleId` int(4) default NULL,
  `aiState` int(4) default NULL,
  `showModel` int(4) default NULL,
  `exModelId` int(4) default NULL,
  `soulLevel` int(4) default NULL,
  `soulRate` int(4) default NULL,
  `attackGrowUp` int(4) default NULL,
  `defGrowUp` int(4) default NULL,
  `lifeGrowUp` int(4) default NULL,
  `isWashGrow` int(4) default NULL,
  `attackGrowUpWash` int(4) default NULL,
  `defGrowUpWash` int(4) default NULL,
  `lifeGrowUpWash` int(4) default NULL,
  `convertRatio` int(4) default NULL,
  `exerciseLevel` int(4) default NULL,
  `moneyExrciseNum` int(4) default NULL,
  `exerciseExp` int(4) default NULL,
  `skills` varbinary(2048) default NULL,
  `life` int(4) default NULL,
  `atkPowerGrowUp_Max` int(4) NOT NULL default '0',
  `defClassGrowUp_Max` int(4) NOT NULL default '0',
  `hpGrowUp_Max` int(4) NOT NULL default '0',
  `benison_Value` int(4) NOT NULL default '0',
  `state` smallint(4) default '0' COMMENT '宠物状态（正常,出战,护法）',
  `star_num` smallint(4) default '0' COMMENT '星数',
  `star_exp` int(8) default '0' COMMENT '星经验',
  `itemAddAttackNum` int(8) default '0' COMMENT '道具增加攻击力上限次数',
  `itemAddDefNum` int(8) default '0' COMMENT '道具增加防御力上限次数',
  `itemAddHpNum` int(8) default '0' COMMENT '道具增加血量上限次数',
  `qualityUp_progross` int(8) default '0' COMMENT '宠物进阶进度',
  `skill1` int(11) default '-1' COMMENT '技能栏1',
  `skill2` int(11) default '-1' COMMENT '技能栏2',
  `skill3` int(11) default '-1' COMMENT '技能栏3',
  `skill4` int(11) default '-1' COMMENT '技能栏4',
  `skill5` int(11) default '-1' COMMENT '技能栏5',
  `skill6` int(11) default '-1' COMMENT '技能栏6',
  `developLv` int(11) default '0' COMMENT '培养等级',
  `developExp` int(11) default '0' COMMENT '培养经验',
  `point` int(11) default '0' COMMENT '战斗力',
  UNIQUE KEY `id` USING BTREE (`id`),
  KEY `masterId` USING BTREE (`masterId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `platform_senditem`
--

CREATE TABLE IF NOT EXISTS `platform_senditem` (
  `id` int(4) NOT NULL auto_increment,
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
  `title` varchar(255) NOT NULL default '',
  `content` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `playercompletedtask`
--

CREATE TABLE IF NOT EXISTS `playercompletedtask` (
  `playerID` bigint(8) NOT NULL,
  `taskIDList` varbinary(4096) default NULL,
  UNIQUE KEY `playerID` USING BTREE (`playerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `playerconvoy`
--

CREATE TABLE IF NOT EXISTS `playerconvoy` (
  `playerID` bigint(8) NOT NULL,
  `taskID` int(4) NOT NULL,
  `beginTime` int(4) NOT NULL default '0',
  `remainTime` int(4) NOT NULL default '0',
  `lowConvoyCD` tinyint(4) NOT NULL default '0',
  `highConvoyCD` tinyint(4) NOT NULL default '0',
  `curConvoyType` tinyint(4) NOT NULL default '0',
  `curCarriageQuality` tinyint(4) NOT NULL default '0',
  `deadCnt` tinyint(4) NOT NULL default '0',
  `remainConvoyFreeRefreshCnt` tinyint(4) NOT NULL default '0',
  `insurance` tinyint(4) NOT NULL default '0' COMMENT '是否购买保险,1已购买，0未购买',
  UNIQUE KEY `playerID` USING BTREE (`playerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `playerdaily`
--

CREATE TABLE IF NOT EXISTS `playerdaily` (
  `playerID` bigint(8) default NULL,
  `activeValue` int(4) default '0',
  `resetTime` int(4) default '0',
  `dailyList` varbinary(1024) default NULL,
  UNIQUE KEY `playerID` USING BTREE (`playerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `playerequipenhancelevel`
--

CREATE TABLE IF NOT EXISTS `playerequipenhancelevel` (
  `playerId` bigint(8) default NULL,
  `ring` binary(64) default NULL,
  `weapon` binary(64) default NULL,
  `cap` binary(64) default NULL,
  `shoulder` binary(64) default NULL,
  `pants` binary(64) default NULL,
  `hand` binary(64) default NULL,
  `coat` binary(64) default NULL,
  `belt` binary(64) default NULL,
  `shoe` binary(64) default NULL,
  `accessories` binary(64) default NULL,
  `wing` binary(64) default NULL,
  `fashion` binary(64) default NULL,
  UNIQUE KEY `playerId` USING BTREE (`playerId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `playerequipitem`
--

CREATE TABLE IF NOT EXISTS `playerequipitem` (
  `id` bigint(8) NOT NULL,
  `playerId` bigint(8) default NULL,
  `equipid` int(4) default NULL,
  `type` int(4) default NULL,
  `quality` int(4) default NULL,
  `isEquiped` int(4) default NULL,
  `propertyTypeValueArray` varbinary(1024) default NULL,
  `gemPropertyTypeValueArray` varbinary(1024) default NULL,
  `enhanceLevel` binary(64) default NULL,
  UNIQUE KEY `id` USING BTREE (`id`,`playerId`),
  KEY `K_equipitem_playerId` USING BTREE (`playerId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `playeronhook`
--

CREATE TABLE IF NOT EXISTS `playeronhook` (
  `PlayerID` bigint(8) NOT NULL COMMENT '用户ＩＤ值',
  `content` varbinary(255) NOT NULL COMMENT '设置内容',
  UNIQUE KEY `PlayerID` USING BTREE (`PlayerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `playerpetsealahs`
--

CREATE TABLE IF NOT EXISTS `playerpetsealahs` (
  `playerId` bigint(20) NOT NULL default '0' COMMENT '玩家ID',
  `unlock_cell_num` int(8) default '0' COMMENT '宠物仓库格子数',
  `skillIds` text character set utf8 COMMENT '仓库技能信息[{自增ID,skillID,petID(已被某宠物学习)}]',
  PRIMARY KEY  (`playerId`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- 表的结构 `playersignin`
--

CREATE TABLE IF NOT EXISTS `playersignin` (
  `playerID` bigint(8) NOT NULL,
  `alreadyDays` int(4) NOT NULL default '0',
  `lastSignTime` int(4) NOT NULL default '0',
  UNIQUE KEY `playerID` USING BTREE (`playerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `playerskill_gamedata`
--

CREATE TABLE IF NOT EXISTS `playerskill_gamedata` (
  `playerId` bigint(8) default NULL,
  `skillId` int(4) default NULL,
  `coolDownTime` int(4) default NULL,
  `activationSkillID1` int(4) default NULL,
  `activationSkillID2` int(4) default NULL,
  `curBindedSkillID` int(4) default NULL,
  UNIQUE KEY `playerIdandSkillId` USING BTREE (`playerId`,`skillId`),
  KEY `playerId` USING BTREE (`playerId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `playertask_gamedata`
--

CREATE TABLE IF NOT EXISTS `playertask_gamedata` (
  `id` bigint(8) NOT NULL,
  `taskID` int(4) default NULL,
  `playerID` bigint(8) default NULL,
  `state` int(4) default NULL,
  `aimProgressList` varbinary(2048) default NULL,
  UNIQUE KEY `id` USING BTREE (`id`),
  KEY `playerID` USING BTREE (`playerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `playertitle`
--

CREATE TABLE IF NOT EXISTS `playertitle` (
  `playerId` bigint(20) default NULL,
  `titleList` varbinary(400) default NULL COMMENT '玩家称号列表',
  `title` smallint(6) default NULL COMMENT '玩家显示的称号'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- 表的结构 `player_arenadata`
--

CREATE TABLE IF NOT EXISTS `player_arenadata` (
  `player_id` bigint(20) NOT NULL default '0' COMMENT '玩家ID',
  `today_challenge_num` tinyint(5) default '0' COMMENT '今日挑战次数',
  `score` int(11) default '0' COMMENT '单人竞技场积分',
  `cool_time` int(11) default '0' COMMENT '冷却时间',
  `vip_buy_num` smallint(5) default '0' COMMENT 'vip购买次数',
  `multi_arena_num` int(10) default '0' COMMENT '多人竞技场次数',
  `multi_win_num` int(8) default '0' COMMENT '今日多人竞技场胜利次数',
  `multi_lose_num` int(8) default '0' COMMENT '今日多人竞技场失败场次',
  `arena_log` text character set utf8 COMMENT '竞技日志',
  `across_num` tinyint(3) default '0' COMMENT '一天跨服次数',
  `across_win` int(10) default '0' COMMENT '跨服连胜数',
  `max_across_win_num` int(10) default '0' COMMENT '今日跨服最大连胜数',
  `sum_win_num` int(11) default '0' COMMENT '今日胜场',
  `get_across_award_info` varbinary(1024) default NULL COMMENT '跨服已领奖的连胜场数',
  `across_player_info` text character set utf8 COMMENT '跨服挑战玩家信息',
  `across_server_id` int(10) default '0' COMMENT '跨服服务器ID',
  PRIMARY KEY  (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- 表的结构 `player_copymap_info`
--

CREATE TABLE IF NOT EXISTS `player_copymap_info` (
  `player_id` bigint(20) NOT NULL default '0' COMMENT '玩家ID',
  `spirit` int(11) NOT NULL default '0' COMMENT '体力值',
  `lastRecoveryTime` int(11) NOT NULL default '0' COMMENT '体力值',
  `vip_buy_num` smallint(5) default '0' COMMENT 'vip购买次数',
  `pet_map_power_type` tinyint(3) NOT NULL default '0' COMMENT '宠物岛战力选择类型',
  `pet_map_star` text NOT NULL COMMENT '宠物岛刷星',
  `pet_box_reset_time` int(11) NOT NULL default '0' COMMENT '宠物岛宝箱重置时间',
  `gold_map_power_type` tinyint(3) NOT NULL default '0' COMMENT '金银到战力选择类型',
  `gold_map_star` text NOT NULL COMMENT '金银岛刷星情况',
  `gold_box_reset_time` int(11) NOT NULL default '0' COMMENT '金银岛宝箱开启重置时间',
  `jingyuan_map_power_type` tinyint(4) NOT NULL default '0' COMMENT '精元岛战力选择情况',
  `jingyuan_map_star` text NOT NULL COMMENT '精元岛刷星情况',
  `jingyuan_box_reset_time` int(11) NOT NULL default '0' COMMENT '精元岛宝箱开启重置时间',
  `jingyuan_free_num` tinyint(3) default '0' COMMENT '精元岛免费刷星数',
  `gold_free_num` tinyint(3) default '0' COMMENT '金银岛免费刷星数',
  `pet_free_num` tinyint(3) default '0' COMMENT '宠物岛免费刷星数',
  `pet_enter_num` int(11) NOT NULL default '0' COMMENT '宠物岛进入次数',
  `gold_enter_num` int(11) NOT NULL default '0' COMMENT '金银岛进入次数',
  `jingyuan_enter_num` int(11) NOT NULL default '0' COMMENT '精元岛进入次数',
  `exp_map_power_type` tinyint(3) default '0' COMMENT '经验岛战力选择类型',
  `exp_map_star` text NOT NULL COMMENT '经验岛刷星',
  `exp_free_num` tinyint(3) default '0' COMMENT '经验岛免费次数',
  `exp_enter_num` tinyint(3) default '0' COMMENT '经验岛免费次数',
  `can_clear_map_id` varbinary(512) default NULL COMMENT '可扫荡的副本地图',
  `vip_buy_pet_num` tinyint(3) default '0' COMMENT 'vip购买宠物岛次数',
  `vip_buy_gold_num` tinyint(3) default '0' COMMENT 'vip购买金银岛次数',
  `vip_buy_exp_num` tinyint(3) default '0' COMMENT 'vip购买经验岛次数',
  `vip_buy_jingyuan_num` tinyint(3) default '0' COMMENT 'vip购买精元岛次数',
  `pet_full_star_award` tinyint(3) default '0' COMMENT '宠物岛5星奖励',
  `pet_full_star_time` int(11) default '0' COMMENT '宠物岛剩余时间',
  `gold_full_star_award` tinyint(3) default '0' COMMENT '金银岛5星奖励',
  `gold_full_star_time` int(11) default '0' COMMENT '金银岛剩余时间',
  `exp_full_star_award` tinyint(3) default '0' COMMENT '经验岛5星奖励',
  `exp_full_star_time` int(11) default '0' COMMENT '经验岛剩余时间',
  `jingyuan_full_star_award` tinyint(3) default '0' COMMENT '精元岛5星奖励',
  `jingyuan_full_star_time` int(11) default '0' COMMENT '精元岛剩余时间',
  `is_new_hand` tinyint(3) default '0' COMMENT '是否新手',
  PRIMARY KEY  (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `player_enemytrack`
--

CREATE TABLE IF NOT EXISTS `player_enemytrack` (
  `player_Id` bigint(20) NOT NULL default '0' COMMENT '玩家ID',
  `trackNum` int(11) default '0' COMMENT '追踪次数',
  `trackTime` int(11) default '0' COMMENT '时间',
  `enemyList` varchar(100) NOT NULL COMMENT '每次领取金钱',
  PRIMARY KEY  (`player_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- 表的结构 `player_gamedata`
--

CREATE TABLE IF NOT EXISTS `player_gamedata` (
  `id` bigint(8) NOT NULL,
  `NAME` char(32) default NULL,
  `userId` bigint(8) default NULL,
  `map_data_id` int(4) default NULL,
  `mapId` bigint(8) default NULL,
  `X` int(4) default NULL,
  `Y` int(4) default NULL,
  `LEVEL` int(4) default NULL,
  `camp` int(4) default NULL,
  `faction` int(4) default NULL,
  `sex` int(4) default NULL,
  `crossServerHonor` int(4) default NULL,
  `unionContribute` int(4) default NULL,
  `competMoney` int(4) default NULL,
  `weekCompet` int(4) default NULL,
  `battleHonor` int(4) default NULL,
  `aura` int(4) default NULL,
  `charm` int(4) default NULL,
  `vip` int(4) default NULL,
  `maxEnabledBagCells` int(4) default NULL,
  `maxEnabledStorageBagCells` int(4) default NULL,
  `storageBagPassWord` char(32) default '',
  `unlockTimes` int(4) default NULL,
  `money` int(4) default NULL,
  `moneyBinded` int(4) default NULL,
  `gold` int(4) default '0',
  `gold_ex` int(4) default '0',
  `goldBinded` int(4) default NULL,
  `goldBinded_ex` int(4) default '0',
  `ticket` int(4) default NULL,
  `guildContribute` int(4) default NULL,
  `honor` int(4) default NULL,
  `credit` int(4) default NULL,
  `life` int(4) default NULL,
  `exp` int(4) default NULL,
  `lastOnlineTime` int(4) default NULL,
  `lastOfflineTime` int(4) default NULL,
  `isOnline` int(4) default NULL,
  `createTime` int(4) default NULL,
  `guildID` bigint(8) default NULL,
  `conBankLastFindTime` int(4) default NULL,
  `chatLastSpeakTime` int(4) default NULL,
  `outFightPet` bigint(8) default NULL,
  `mapCDInfoList` varbinary(1024) default NULL,
  `pk_mode` tinyint(5) default '0' COMMENT 'Pk模式',
  `pK_Kill_Value` int(4) default NULL,
  `pK_Kill_OpenTime` int(4) default NULL,
  `pk_Kill_Punish` tinyint(4) NOT NULL default '0',
  `playerMountInfo` varbinary(1024) default NULL,
  `playerItemCDInfo` varbinary(1024) default NULL,
  `bloodPoolLife` int(4) default '0',
  `playerItem_DailyCountInfo` varbinary(1024) default NULL,
  `gmLevel` int(4) default '0',
  `petBloodPoolLife` int(4) default '0',
  `fightingCapacity` int(4) NOT NULL default '0',
  `fightingCapacityTop` int(4) NOT NULL default '0',
  `platSendItemBits` varbinary(100) default NULL,
  `gameSetMenu` varbinary(128) default NULL,
  `rechargeAmmount` int(4) NOT NULL default '0',
  `varArray` varbinary(512) default NULL,
  `forbidChatFlag` int(4) NOT NULL default '0',
  `protectPwd` char(32) NOT NULL default '',
  `reasureBowlData` varbinary(40) default NULL,
  `taskSpecialData` varbinary(80) default NULL,
  `exp15add` int(4) NOT NULL default '0' COMMENT '1.5倍经验加成',
  `exp20add` int(4) NOT NULL default '0' COMMENT '2.0倍经验加成',
  `exp30add` int(4) NOT NULL default '0' COMMENT '3.0倍经验加成',
  `isDelete` tinyint(4) NOT NULL default '0',
  `goldPassWord` char(32) NOT NULL default '',
  `goldPassWordUnlockTimes` int(4) NOT NULL default '0',
  `vipLevel` int(4) NOT NULL default '0',
  `vipTimeExpire` int(4) NOT NULL default '0',
  `vipTimeBuy` int(4) NOT NULL default '0',
  `recharge_reward_amount` varchar(50) default '[]' COMMENT '累积充值奖励领取',
  `vip_week_reward` varchar(50) default '[]' COMMENT 'Vip每周奖励',
  `photoStatus` tinyint(4) NOT NULL default '0' COMMENT '用户头像审核状态(0:未提交，1:审核中，2:审核成功，3:已有照片，提交新照片审核中，4:审核失败，5:已有照片，重新提交审核失败)',
  `nextPhotoUploadTime` int(11) default NULL,
  `photoID` bigint(20) default '0' COMMENT '用户头像ID',
  `guildTask` varbinary(100) default NULL COMMENT '帮会任务列表',
  `killNum` int(11) default '0' COMMENT '击杀人数',
  `menuShield` tinyint(4) default '0' COMMENT '菜单屏蔽相关选项',
  UNIQUE KEY `id` USING BTREE (`id`),
  UNIQUE KEY `NAME` USING BTREE (`NAME`),
  KEY `userId` USING BTREE (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `player_month_card_info`
--

CREATE TABLE IF NOT EXISTS `player_month_card_info` (
  `orderID` bigint(20) NOT NULL,
  `playerID` bigint(20) NOT NULL,
  `getNum` int(11) default '0' COMMENT '月卡已领取天数',
  `nextGetTime` int(11) default '0' COMMENT '下次领取时间',
  `expiryDate` int(11) default '0' COMMENT '月卡到期时间',
  `onceGold` int(11) default '0' COMMENT '每次领取金钱',
  PRIMARY KEY  (`orderID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家月卡领取相关信息';

-- --------------------------------------------------------

--
-- 表的结构 `player_mountdata`
--

CREATE TABLE IF NOT EXISTS `player_mountdata` (
  `playerid` bigint(20) NOT NULL COMMENT '玩家ID',
  `mount_data_id` int(11) NOT NULL COMMENT '当前坐骑ID',
  `mount_level` int(11) NOT NULL COMMENT '强化等级',
  `exp` int(11) NOT NULL COMMENT '当前强化等级经验',
  `point` int(11) NOT NULL COMMENT '战斗力',
  PRIMARY KEY  (`playerid`),
  UNIQUE KEY `playerid` USING BTREE (`playerid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `player_mount_illusion`
--

CREATE TABLE IF NOT EXISTS `player_mount_illusion` (
  `playerid` bigint(20) NOT NULL COMMENT '玩家ID',
  `mount_data_id` int(11) NOT NULL COMMENT '坐骑ID',
  `timeout` int(11) NOT NULL COMMENT '超时时间',
  UNIQUE KEY `mainid` USING BTREE (`playerid`,`mount_data_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `player_petlottery`
--

CREATE TABLE IF NOT EXISTS `player_petlottery` (
  `player_id` bigint(20) NOT NULL default '0' COMMENT '玩家ID',
  `free_num` smallint(5) default '0' COMMENT '已免费刷新次数',
  `in_hundred_time` int(10) default '0' COMMENT '百里挑一时间',
  `in_thousand_time` int(10) default '0' COMMENT '千里挑一时间',
  `is_first_thousand` tinyint(3) default '0' COMMENT '是否首次千里挑一',
  `in_million_time` int(10) default '0' COMMENT '万里挑一时间',
  `is_first_million` tinyint(3) default '0' COMMENT '是否首次万里挑一',
  PRIMARY KEY  (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `player_realm`
--

CREATE TABLE IF NOT EXISTS `player_realm` (
  `playerID` bigint(20) default NULL,
  `realmID` int(11) default NULL,
  `blessing` int(6) default NULL,
  UNIQUE KEY `playerID` USING BTREE (`playerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `player_recharge_order`
--

CREATE TABLE IF NOT EXISTS `player_recharge_order` (
  `orderID` bigint(20) default NULL,
  `playerID` bigint(20) default NULL,
  `gold` int(11) default NULL,
  `gold_ex` int(11) default '0' COMMENT '赠送钻石',
  `rmb` int(11) default NULL,
  `state` tinyint(4) default NULL,
  `orderDate` int(11) default NULL,
  `completeDate` int(11) default NULL,
  `receiveReward` int(4) default '0',
  `type` tinyint(4) default '0' COMMENT '充值商品类型,0为一次性充值,1为月卡',
  `warseID` tinyint(4) default '0' COMMENT '充值商品类型,0为一次性充值,1为月卡',
  UNIQUE KEY `orderID` USING BTREE (`orderID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `player_reward_task`
--

CREATE TABLE IF NOT EXISTS `player_reward_task` (
  `playerID` bigint(20) default NULL,
  `taskList` varbinary(500) default NULL,
  `resetTime` int(11) default NULL,
  `freeRefreshCount` tinyint(4) default NULL,
  `completedCount` tinyint(4) default NULL,
  `todayBegin` int(11) default NULL,
  UNIQUE KEY `playerID` USING BTREE (`playerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `rechargeactive`
--

CREATE TABLE IF NOT EXISTS `rechargeactive` (
  `id` int(11) NOT NULL COMMENT '目前进行的充值活动ID',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `r_itemdb`
--

CREATE TABLE IF NOT EXISTS `r_itemdb` (
  `id` bigint(8) NOT NULL,
  `owner_type` int(4) default NULL,
  `owner_id` bigint(8) default NULL,
  `location` int(4) default NULL,
  `cell` int(4) default NULL,
  `amount` int(4) default NULL,
  `item_data_id` int(4) default NULL,
  `param1` int(4) default NULL,
  `param2` int(4) default NULL,
  `binded` int(4) default NULL,
  `expiration_time` int(4) default NULL,
  UNIQUE KEY `id` USING BTREE (`id`),
  KEY `owner_id` USING BTREE (`owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `r_playerbag`
--

CREATE TABLE IF NOT EXISTS `r_playerbag` (
  `id` bigint(8) NOT NULL,
  `location` int(4) default NULL,
  `cell` int(4) default NULL,
  `playerID` bigint(8) default NULL,
  `itemDBID` bigint(8) default NULL,
  `enable` int(4) default NULL,
  `lockID` int(4) default NULL,
  UNIQUE KEY `id` USING BTREE (`id`),
  KEY `playerID` USING BTREE (`playerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `shortcut`
--

CREATE TABLE IF NOT EXISTS `shortcut` (
  `playerID` bigint(8) NOT NULL,
  `index1ID` int(4) default NULL,
  `index2ID` int(4) default NULL,
  `index3ID` int(4) default NULL,
  `index4ID` int(4) default NULL,
  `index5ID` int(4) default NULL,
  `index6ID` int(4) default NULL,
  `index7ID` int(4) default NULL,
  `index8ID` int(4) default NULL,
  `index9ID` int(4) default NULL,
  `index10ID` int(4) default NULL,
  `index11ID` int(4) default NULL,
  `index12ID` int(4) default NULL,
  UNIQUE KEY `playerID` USING BTREE (`playerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `single_arena_rank`
--

CREATE TABLE IF NOT EXISTS `single_arena_rank` (
  `rank` int(11) NOT NULL default '0' COMMENT '排名',
  `player_id` bigint(20) default '0' COMMENT '玩家ID',
  `score` int(11) default '0' COMMENT '积分',
  `power` int(11) default '0' COMMENT '战力',
  `rank_time` int(11) default '0' COMMENT '排名时间',
  `box_id` smallint(5) default '0' COMMENT '宝箱ID',
  `award_left_time` int(11) default '0' COMMENT '奖励宝箱重置时间',
  PRIMARY KEY  (`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `top_mount_power_rank`
--

CREATE TABLE IF NOT EXISTS `top_mount_power_rank` (
  `rank` int(11) NOT NULL auto_increment COMMENT '排行',
  `mount_id` int(11) default '0' COMMENT '坐骑ID',
  `mount_power` int(11) default '0' COMMENT '坐骑战力',
  `progress` int(11) default '0' COMMENT '喂养进度',
  `reach_time` int(11) default '0' COMMENT '到达当前战斗力时间',
  `player_id` bigint(20) default '0' COMMENT '玩家ID',
  `player_name` char(128) default NULL COMMENT '玩家名',
  `camp` smallint(5) default '0' COMMENT '职业',
  `faction` smallint(5) default '0' COMMENT '阵营',
  `level` int(11) default '0' COMMENT '等级',
  `player_power` int(11) default '0' COMMENT '玩家战力',
  `sex` smallint(5) default '0' COMMENT '性别',
  `weapon` int(11) default '0' COMMENT '武器',
  `coat` int(11) default '0' COMMENT '衣服',
  PRIMARY KEY  (`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `top_pet_power_rank`
--

CREATE TABLE IF NOT EXISTS `top_pet_power_rank` (
  `rank` int(11) NOT NULL auto_increment COMMENT '排行',
  `pet_id` bigint(20) default '0' COMMENT '宠物ID',
  `pet_name` char(128) default NULL COMMENT '宠物名',
  `pet_power` int(11) default '0' COMMENT '宠物战力',
  `pet_data_id` int(11) default '0' COMMENT '宠物配置ID',
  `pet_level` int(11) default '0' COMMENT '宠物等级',
  `player_id` bigint(20) default '0' COMMENT '玩家ID',
  `player_name` char(128) default NULL COMMENT '玩家名',
  `camp` smallint(5) default '0' COMMENT '职业',
  `faction` smallint(5) default '0' COMMENT '阵营',
  `level` int(11) default '0' COMMENT '等级',
  `player_power` int(11) default '0' COMMENT '玩家战力',
  `sex` smallint(5) default '0' COMMENT '性别',
  `weapon` int(11) default '0' COMMENT '武器',
  `coat` int(11) default '0' COMMENT '衣服',
  PRIMARY KEY  (`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `top_player_fighting_capacity`
--

CREATE TABLE IF NOT EXISTS `top_player_fighting_capacity` (
  `top` int(4) NOT NULL auto_increment,
  `playerid` bigint(8) NOT NULL,
  `name` varchar(32) NOT NULL,
  `camp` int(4) NOT NULL,
  `faction` int(4) NOT NULL,
  `level` int(4) NOT NULL,
  `fighting_capacity` int(4) NOT NULL,
  `sex` int(4) NOT NULL default '0',
  `weapon` int(4) NOT NULL default '0',
  `coat` int(4) NOT NULL default '0',
  PRIMARY KEY  (`top`),
  UNIQUE KEY `id` USING BTREE (`playerid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `top_player_level`
--

CREATE TABLE IF NOT EXISTS `top_player_level` (
  `top` int(4) NOT NULL auto_increment,
  `playerid` bigint(8) NOT NULL,
  `name` char(32) NOT NULL,
  `camp` int(4) NOT NULL,
  `faction` int(4) NOT NULL,
  `level` int(4) NOT NULL,
  `fighting_capacity` int(4) NOT NULL,
  `sex` int(4) NOT NULL default '0',
  `weapon` int(4) NOT NULL default '0',
  `coat` int(4) NOT NULL default '0',
  PRIMARY KEY  (`top`),
  UNIQUE KEY `id` USING BTREE (`playerid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `top_player_money`
--

CREATE TABLE IF NOT EXISTS `top_player_money` (
  `top` int(4) NOT NULL auto_increment,
  `playerid` bigint(8) NOT NULL,
  `name` char(32) NOT NULL,
  `camp` int(4) NOT NULL,
  `faction` int(4) NOT NULL,
  `level` int(4) NOT NULL,
  `money` int(4) NOT NULL,
  `sex` int(4) NOT NULL default '0',
  `weapon` int(4) NOT NULL default '0',
  `coat` int(4) NOT NULL default '0',
  PRIMARY KEY  (`top`),
  UNIQUE KEY `id` USING BTREE (`playerid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `train`
--

CREATE TABLE IF NOT EXISTS `train` (
  `playerID` bigint(20) NOT NULL,
  `type` smallint(6) default NULL,
  `location` smallint(6) default NULL,
  `beginTime` int(11) default NULL,
  `time` int(11) default NULL,
  `totalTime` int(11) default NULL,
  `name` varbinary(255) default NULL,
  `sex` tinyint(4) default NULL,
  `vipLv` smallint(6) default NULL,
  `level` smallint(6) default NULL,
  `faction` smallint(6) default NULL,
  `weaponDataID` int(11) default NULL,
  `coatDataID` int(11) default NULL,
  `fightNum` smallint(6) default NULL,
  `buyNum` smallint(6) default NULL,
  `tarlocation` smallint(6) default NULL,
  `tartype` smallint(6) default NULL,
  PRIMARY KEY  (`playerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `transfer_account_recharge`
--

CREATE TABLE IF NOT EXISTS `transfer_account_recharge` (
  `account` char(32) NOT NULL default '',
  `platId` int(4) NOT NULL default '0',
  `rechargeRmb` int(4) default '0',
  PRIMARY KEY  (`account`,`platId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `worldvar_data`
--

CREATE TABLE IF NOT EXISTS `worldvar_data` (
  `id` int(4) NOT NULL,
  `varArray` varbinary(1024) default NULL,
  UNIQUE KEY `id` USING BTREE (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
