/*
Navicat MySQL Data Transfer

Source Server         : dell
Source Server Version : 50524
Source Host           : 192.168.0.199:3306
Source Database       : fxloginserver

Target Server Type    : MYSQL
Target Server Version : 50524
File Encoding         : 65001

Date: 2013-08-01 10:52:22
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `forbidden`
-- ----------------------------
DROP TABLE IF EXISTS `forbidden`;
CREATE TABLE `forbidden` (
  `account` char(32) NOT NULL,
  `flag` int(4) NOT NULL DEFAULT '0',
  `reason` int(4) NOT NULL DEFAULT '0',
  `timeBegin` int(4) NOT NULL DEFAULT '0',
  `timeEnd` int(4) NOT NULL DEFAULT '0',
  UNIQUE KEY `account` (`account`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of forbidden
-- ----------------------------

-- ----------------------------
-- Table structure for `gsconfig`
-- ----------------------------
DROP TABLE IF EXISTS `gsconfig`;
CREATE TABLE `gsconfig` (
  `serverid` char(6) DEFAULT NULL COMMENT 'GS的ID',
  `name` varchar(50) DEFAULT NULL COMMENT '名称',
  `isnew` int(4) DEFAULT NULL COMMENT '是否新服',
  `begintime` varchar(128) DEFAULT NULL COMMENT '开服时间',
  `recommend` int(4) NOT NULL DEFAULT '0' COMMENT '是否推荐',
  `hot` int(4) NOT NULL DEFAULT '0' COMMENT '火爆程度',
  UNIQUE KEY `serverid` (`serverid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of gsconfig
-- ----------------------------

-- ----------------------------
-- Table structure for `platform_test`
-- ----------------------------
DROP TABLE IF EXISTS `platform_test`;
CREATE TABLE `platform_test` (
  `account` varchar(32) NOT NULL DEFAULT '',
  `ip` varchar(32) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of platform_test
-- ----------------------------

-- ----------------------------
-- Table structure for `user`
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` bigint(8) NOT NULL,
  `platformId` int(4) DEFAULT NULL,
  `userName` char(32) DEFAULT NULL,
  `resVer` int(4) DEFAULT NULL,
  `exeVer` int(4) DEFAULT NULL,
  `gameVer` int(4) DEFAULT NULL,
  `protocolVer` int(4) DEFAULT NULL,
  `lastLogintime` int(4) DEFAULT NULL,
  `createTime` int(4) NOT NULL DEFAULT '0',
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `platAndName` (`platformId`,`userName`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of user
-- ----------------------------

-- ----------------------------
-- Table structure for `user4test`
-- ----------------------------
DROP TABLE IF EXISTS `user4test`;
CREATE TABLE `user4test` (
  `id` bigint(8) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of user4test
-- ----------------------------
