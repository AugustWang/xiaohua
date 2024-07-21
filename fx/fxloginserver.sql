-- phpMyAdmin SQL Dump
-- version 4.1.14
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: 2014-10-11 08:03:15
-- 服务器版本： 5.0.87-community-nt
-- PHP Version: 5.5.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `fxloginserver`
--

-- --------------------------------------------------------

--
-- 表的结构 `forbidden`
--

CREATE TABLE IF NOT EXISTS `forbidden` (
  `account` char(32) NOT NULL,
  `flag` int(4) NOT NULL default '0',
  `reason` int(4) NOT NULL default '0',
  `timeBegin` int(4) NOT NULL default '0',
  `timeEnd` int(4) NOT NULL default '0',
  UNIQUE KEY `account` USING BTREE (`account`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `gsconfig`
--

CREATE TABLE IF NOT EXISTS `gsconfig` (
  `serverid` int(6) NOT NULL default '0' COMMENT 'GS的ID',
  `name` varchar(50) default NULL COMMENT '名称',
  `isnew` tinyint(4) default NULL COMMENT '是否新服',
  `begintime` int(128) default NULL COMMENT '开服时间',
  `recommend` tinyint(4) NOT NULL default '0' COMMENT '是否推荐',
  `hot` tinyint(4) NOT NULL default '0' COMMENT '火爆程度',
  `showState` tinyint(4) default '5' COMMENT '显示状态,默认值为测试人员可见',
  `showIndex` int(11) default '0' COMMENT '服务器排序，默认为0',
  PRIMARY KEY  (`serverid`),
  UNIQUE KEY `serverid` USING BTREE (`serverid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `platform_test`
--

CREATE TABLE IF NOT EXISTS `platform_test` (
  `account` varchar(32) NOT NULL default '',
  `ip` varchar(32) NOT NULL default ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `role`
--

CREATE TABLE IF NOT EXISTS `role` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `gold` int(11) unsigned NOT NULL default '0',
  `diamond` int(11) unsigned NOT NULL default '0',
  `essence` int(11) unsigned NOT NULL default '0',
  `lev` tinyint(3) unsigned NOT NULL,
  `tollgate_id` smallint(5) unsigned NOT NULL default '1' COMMENT '关卡ID',
  `aid` varchar(64) NOT NULL,
  `name` varchar(64) NOT NULL,
  `password` varchar(255) default NULL,
  `kvs` blob NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `aid` (`aid`),
  UNIQUE KEY `name` (`name`),
  KEY `lev` (`lev`,`aid`,`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='角色数据' AUTO_INCREMENT=4 ;

-- --------------------------------------------------------

--
-- 表的结构 `user`
--

CREATE TABLE IF NOT EXISTS `user` (
  `id` bigint(8) NOT NULL,
  `platformId` int(4) default NULL,
  `userName` char(32) default NULL,
  `resVer` int(4) default NULL,
  `exeVer` int(4) default NULL,
  `gameVer` int(4) default NULL,
  `protocolVer` int(4) default NULL,
  `lastLogintime` int(4) default NULL,
  `createTime` int(4) NOT NULL default '0',
  UNIQUE KEY `id` USING BTREE (`id`),
  UNIQUE KEY `platAndName` USING BTREE (`platformId`,`userName`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `user4test`
--

CREATE TABLE IF NOT EXISTS `user4test` (
  `id` bigint(8) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
