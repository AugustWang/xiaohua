-- phpMyAdmin SQL Dump
-- version 4.1.14
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: 2014-10-11 08:03:22
-- 服务器版本： 5.0.87-community-nt
-- PHP Version: 5.5.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `fxloginserverlog`
--

-- --------------------------------------------------------

--
-- 表的结构 `log_account_login`
--

CREATE TABLE IF NOT EXISTS `log_account_login` (
  `account` char(32) default NULL,
  `userid` bigint(8) NOT NULL,
  `platform` int(4) default NULL,
  `version_res` int(4) default NULL,
  `version_exe` int(4) default NULL,
  `version_game` int(4) default NULL,
  `version_pro` int(4) default NULL,
  `time_login` int(4) default NULL,
  `ip` char(32) default NULL,
  `tmonth` tinyint(4) default '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
