-- phpMyAdmin SQL Dump
-- version 4.1.14
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: 2014-10-11 08:03:44
-- 服务器版本： 5.0.87-community-nt
-- PHP Version: 5.5.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `fxserverlog`
--

-- --------------------------------------------------------

--
-- 表的结构 `log_exp_change`
--

CREATE TABLE IF NOT EXISTS `log_exp_change` (
  `userid` bigint(8) default NULL COMMENT '账号ID',
  `playerid` bigint(8) default NULL COMMENT '角色ID',
  `level` int(4) default NULL COMMENT '等级',
  `money` int(4) default NULL COMMENT '游戏币',
  `money_b` int(4) default NULL COMMENT '游戏币2',
  `gold` int(4) default NULL COMMENT '元宝',
  `gold_b` int(4) default NULL COMMENT '元宝2',
  `exp` int(4) default NULL COMMENT '经验',
  `life` int(4) default NULL COMMENT '生命值',
  `time` int(4) default NULL COMMENT '存表时间',
  `changetype` int(4) default NULL COMMENT '改变类型',
  `content` varchar(255) default NULL COMMENT '事件参数',
  `number` int(8) default NULL COMMENT '经验数量',
  `tmonth` tinyint(4) default '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `log_gold`
--

CREATE TABLE IF NOT EXISTS `log_gold` (
  `playerid` bigint(8) NOT NULL,
  `flag` int(4) NOT NULL,
  `gold_old` int(4) NOT NULL,
  `gold_mod` int(4) NOT NULL,
  `gold_new` int(4) NOT NULL,
  `reason` int(4) NOT NULL,
  `desc0` varchar(64) NOT NULL,
  `time` int(4) NOT NULL,
  `tmonth` tinyint(4) default '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `log_item_change`
--

CREATE TABLE IF NOT EXISTS `log_item_change` (
  `userid` bigint(8) default NULL COMMENT '账号ID',
  `playerid` bigint(8) default NULL COMMENT '角色ID',
  `itemdataid` int(4) default NULL COMMENT '物品ID',
  `itemid` bigint(8) default NULL COMMENT '物品唯一ID',
  `ownerid` bigint(8) default NULL COMMENT '拥有者ID',
  `cell` int(4) default NULL COMMENT '格子',
  `amount` int(4) default NULL COMMENT '数量',
  `binded` int(4) default NULL COMMENT '绑定状态',
  `time` int(4) default NULL COMMENT '存表时间',
  `changetype` int(4) default NULL COMMENT '类型',
  `changereson` int(4) default NULL COMMENT '改变类型',
  `content` varchar(255) default NULL COMMENT '事件参数',
  `tmonth` tinyint(4) default '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `log_mail_change`
--

CREATE TABLE IF NOT EXISTS `log_mail_change` (
  `changetype` int(4) default NULL COMMENT '改变类型(增加 OPEN 拿钱 支付钱 拿物品1 拿物品2 删邮件)',
  `id` bigint(8) NOT NULL COMMENT '邮件ID',
  `type` int(4) default NULL COMMENT '邮件类型',
  `recvPlayerID` bigint(8) default NULL COMMENT '收信人ID',
  `isOpened` int(4) default NULL COMMENT '是否已经查看',
  `tiemOut` int(4) default NULL COMMENT '查看时间',
  `idSender` bigint(8) default NULL COMMENT '寄件人ID',
  `nameSender` char(255) default NULL COMMENT '寄件人名字',
  `title` char(255) default NULL COMMENT '标题',
  `attachItemDBID1` bigint(8) default NULL COMMENT '夹档道具1 ID',
  `attachItemDataID1` int(11) default '0' COMMENT '附件1物品定义ID',
  `attachItemCount1` int(11) default '0' COMMENT '附件1物品数量',
  `attachItemDBID2` bigint(8) default NULL COMMENT '夹档道具2 ID',
  `attachItemDataID2` int(11) default '0' COMMENT '附件2物品定义ID',
  `attachItemCount2` int(11) default '0' COMMENT '附件1物品数量',
  `moneySend` int(4) default NULL COMMENT '夹档货币 ',
  `moneyPay` int(4) default NULL COMMENT '收取邮件需要 货币',
  `goldSend` int(4) default '0' COMMENT '夹档元宝',
  `mailTimerType` int(4) default NULL COMMENT '时间类型',
  `mailRecTime` int(4) default NULL COMMENT '接收邮件时间',
  `tmonth` tinyint(4) default '0',
  KEY `id` USING BTREE (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `log_online_record`
--

CREATE TABLE IF NOT EXISTS `log_online_record` (
  `time` int(4) default NULL,
  `count` int(4) default NULL,
  `tmonth` tinyint(4) default '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `log_player`
--

CREATE TABLE IF NOT EXISTS `log_player` (
  `playerid` bigint(8) default NULL,
  `name` varchar(32) default NULL,
  `camp` int(4) default NULL,
  `sex` int(4) default NULL,
  `time` int(4) default NULL,
  `tmonth` tinyint(4) default '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `log_player_event`
--

CREATE TABLE IF NOT EXISTS `log_player_event` (
  `userid` bigint(8) default NULL COMMENT '账号ID',
  `playerid` bigint(8) default NULL COMMENT '角色ID',
  `level` int(4) default NULL COMMENT '等级',
  `money` int(4) default NULL COMMENT '游戏币',
  `money_b` int(4) default NULL COMMENT '游戏币2',
  `gold` int(4) default NULL COMMENT '元宝',
  `gold_b` int(4) default NULL COMMENT '元宝2',
  `exp` int(4) default NULL COMMENT '经验',
  `life` int(4) default NULL COMMENT '生命值',
  `time` int(4) default NULL COMMENT '存表时间',
  `eventtype` int(4) default NULL COMMENT '事件类型',
  `content` varchar(255) default NULL COMMENT '事件参数',
  `tmonth` tinyint(4) default '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `log_player_login`
--

CREATE TABLE IF NOT EXISTS `log_player_login` (
  `userid` bigint(8) default NULL,
  `playerid` bigint(8) default NULL,
  `level` int(4) default NULL,
  `money` int(4) default NULL,
  `money_b` int(4) default NULL,
  `gold` int(4) default NULL,
  `gold_b` int(4) default NULL,
  `exp` int(4) default NULL,
  `life` int(4) default NULL,
  `flag` int(4) default NULL,
  `time` int(4) default NULL,
  `tmonth` tinyint(4) default '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `log_player_machine`
--

CREATE TABLE IF NOT EXISTS `log_player_machine` (
  `id` bigint(20) unsigned NOT NULL auto_increment,
  `playerid` bigint(8) NOT NULL,
  `playerlevel` int(11) NOT NULL default '0',
  `userid` bigint(8) NOT NULL,
  `platform` varchar(255) default NULL,
  `machine` varchar(255) default NULL,
  `deviceid` varchar(255) default NULL COMMENT '设备唯一码',
  `imei` varchar(255) default NULL COMMENT '手机IEMI码',
  `resolution` varchar(255) default NULL COMMENT '分辨率',
  `timelogin` int(11) default NULL,
  `timelogout` int(11) default NULL,
  `tmonth` tinyint(4) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `log_player_task`
--

CREATE TABLE IF NOT EXISTS `log_player_task` (
  `userid` bigint(8) default NULL,
  `playerid` bigint(8) default NULL,
  `taskid` int(4) default NULL,
  `level` int(4) default NULL,
  `flag` int(4) default NULL,
  `time` int(4) default NULL,
  `tmonth` tinyint(4) default '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `log_recharge`
--

CREATE TABLE IF NOT EXISTS `log_recharge` (
  `orderid` varchar(64) NOT NULL,
  `platform` int(4) NOT NULL,
  `account` varchar(32) NOT NULL,
  `userid` bigint(8) NOT NULL,
  `playerid` bigint(8) NOT NULL,
  `gold` int(11) NOT NULL default '0' COMMENT '充值获得钻石数',
  `gold_ex` int(11) NOT NULL default '0' COMMENT '充值获得额外钻石数',
  `ammount` int(4) NOT NULL,
  `flag` int(4) NOT NULL,
  `time` int(4) NOT NULL,
  `type` tinyint(4) default '0' COMMENT '充值商品类型,0为一次性充值,1为月卡'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `log_token_change`
--

CREATE TABLE IF NOT EXISTS `log_token_change` (
  `userid` bigint(8) default NULL COMMENT '账号ID',
  `playerid` bigint(8) default NULL COMMENT '角色ID',
  `level` int(4) default NULL COMMENT '等级',
  `money` int(4) default NULL COMMENT '游戏币',
  `money_b` int(4) default NULL COMMENT '游戏币2',
  `gold` int(4) default NULL COMMENT '元宝',
  `gold_ex` int(11) NOT NULL default '0' COMMENT '赠送钻石',
  `gold_b` int(4) default NULL COMMENT '元宝2',
  `gold_b_ex` int(11) NOT NULL default '0' COMMENT '赠送绑钻',
  `exp` int(4) default NULL COMMENT '经验',
  `life` int(4) default NULL COMMENT '生命值',
  `time` int(4) default NULL COMMENT '存表时间',
  `tokentype` int(4) default NULL COMMENT '货币类型',
  `relust` int(4) default NULL COMMENT '改变结果(增加或减少)',
  `changetype` int(4) default NULL COMMENT '改变类型',
  `content` varchar(255) default NULL COMMENT '事件参数',
  `number` int(8) default NULL COMMENT '货币数量',
  `tmonth` tinyint(4) default '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
