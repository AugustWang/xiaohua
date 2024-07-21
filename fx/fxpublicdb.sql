-- phpMyAdmin SQL Dump
-- version 4.1.14
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: 2014-10-11 08:03:27
-- 服务器版本： 5.0.87-community-nt
-- PHP Version: 5.5.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `fxpublicdb`
--

-- --------------------------------------------------------

--
-- 表的结构 `activecode`
--

CREATE TABLE IF NOT EXISTS `activecode` (
  `active_code` varchar(20) NOT NULL,
  `type` smallint(6) default '1',
  `dropId` int(11) default NULL,
  `create_time` int(4) default NULL,
  `get_time` int(4) default '0',
  `get_userid` bigint(8) default '0',
  `get_playerid` bigint(8) default '0',
  PRIMARY KEY  (`active_code`),
  UNIQUE KEY `index_active_code` USING BTREE (`active_code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `announcement`
--

CREATE TABLE IF NOT EXISTS `announcement` (
  `id` smallint(6) NOT NULL default '0',
  `time` int(11) default NULL,
  `title` varchar(32) NOT NULL,
  `content` varchar(2000) NOT NULL,
  `type` int(11) NOT NULL,
  `server` varchar(20) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `userphoto`
--

CREATE TABLE IF NOT EXISTS `userphoto` (
  `id` bigint(20) NOT NULL auto_increment,
  `serverid` int(11) NOT NULL,
  `playerid` bigint(20) NOT NULL,
  `status` tinyint(4) NOT NULL default '0' COMMENT '0未审核，1审核通过',
  `uploadTime` int(11) NOT NULL,
  `approveTime` int(11) default '0',
  `reason` int(11) default NULL,
  `updateSuc` tinyint(4) NOT NULL default '0' COMMENT '状态更新是否成功',
  UNIQUE KEY `id` USING BTREE (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
