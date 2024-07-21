/*
Navicat MySQL Data Transfer

Source Server         : dell
Source Server Version : 50524
Source Host           : 192.168.0.199:3306
Source Database       : fxloginserverlog

Target Server Type    : MYSQL
Target Server Version : 50524
File Encoding         : 65001

Date: 2013-08-01 10:52:31
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `log_account_login`
-- ----------------------------
DROP TABLE IF EXISTS `log_account_login`;
CREATE TABLE `log_account_login` (
  `account` char(32) DEFAULT NULL,
  `userid` bigint(8) NOT NULL,
  `platform` int(4) DEFAULT NULL,
  `version_res` int(4) DEFAULT NULL,
  `version_exe` int(4) DEFAULT NULL,
  `version_game` int(4) DEFAULT NULL,
  `version_pro` int(4) DEFAULT NULL,
  `time_login` int(4) DEFAULT NULL,
  `ip` char(32) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of log_account_login
-- ----------------------------
