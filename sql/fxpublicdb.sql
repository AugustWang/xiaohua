/*
Navicat MySQL Data Transfer

Source Server         : dell
Source Server Version : 50524
Source Host           : 192.168.0.199:3306
Source Database       : fxpublicdb

Target Server Type    : MYSQL
Target Server Version : 50524
File Encoding         : 65001

Date: 2013-08-01 10:52:39
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `activecode`
-- ----------------------------
DROP TABLE IF EXISTS `activecode`;
CREATE TABLE `activecode` (
  `active_code` char(64) DEFAULT NULL,
  `item_id` int(4) DEFAULT NULL,
  `item_count` int(4) DEFAULT NULL,
  `param` int(4) DEFAULT NULL,
  `create_time` int(4) DEFAULT NULL,
  `get_time` int(4) DEFAULT '0',
  `get_userid` bigint(8) DEFAULT '0',
  `get_playerid` bigint(8) DEFAULT '0',
  UNIQUE KEY `index_active_code` (`active_code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of activecode
-- ----------------------------
