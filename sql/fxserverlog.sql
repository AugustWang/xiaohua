/*
Navicat MySQL Data Transfer

Source Server         : dell
Source Server Version : 50524
Source Host           : 192.168.0.199:3306
Source Database       : fxserverlog

Target Server Type    : MYSQL
Target Server Version : 50524
File Encoding         : 65001

Date: 2013-08-01 10:53:04
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `log_exp_change`
-- ----------------------------
DROP TABLE IF EXISTS `log_exp_change`;
CREATE TABLE `log_exp_change` (
  `userid` bigint(8) DEFAULT NULL COMMENT '账号ID',
  `playerid` bigint(8) DEFAULT NULL COMMENT '角色ID',
  `level` int(4) DEFAULT NULL COMMENT '等级',
  `money` int(4) DEFAULT NULL COMMENT '游戏币',
  `money_b` int(4) DEFAULT NULL COMMENT '游戏币2',
  `gold` int(4) DEFAULT NULL COMMENT '元宝',
  `gold_b` int(4) DEFAULT NULL COMMENT '元宝2',
  `exp` int(4) DEFAULT NULL COMMENT '经验',
  `life` int(4) DEFAULT NULL COMMENT '生命值',
  `time` int(4) DEFAULT NULL COMMENT '存表时间',
  `changetype` int(4) DEFAULT NULL COMMENT '改变类型',
  `content` varchar(255) DEFAULT NULL COMMENT '事件参数',
  `number` int(8) DEFAULT NULL COMMENT '经验数量'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of log_exp_change
-- ----------------------------

-- ----------------------------
-- Table structure for `log_gold`
-- ----------------------------
DROP TABLE IF EXISTS `log_gold`;
CREATE TABLE `log_gold` (
  `playerid` bigint(8) NOT NULL,
  `flag` int(4) NOT NULL,
  `gold_old` int(4) NOT NULL,
  `gold_mod` int(4) NOT NULL,
  `gold_new` int(4) NOT NULL,
  `reason` int(4) NOT NULL,
  `desc0` varchar(64) NOT NULL,
  `time` int(4) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of log_gold
-- ----------------------------

-- ----------------------------
-- Table structure for `log_item_change`
-- ----------------------------
DROP TABLE IF EXISTS `log_item_change`;
CREATE TABLE `log_item_change` (
  `userid` bigint(8) DEFAULT NULL COMMENT '账号ID',
  `playerid` bigint(8) DEFAULT NULL COMMENT '角色ID',
  `itemdataid` int(4) DEFAULT NULL COMMENT '物品ID',
  `itemid` bigint(8) DEFAULT NULL COMMENT '物品唯一ID',
  `ownerid` bigint(8) DEFAULT NULL COMMENT '拥有者ID',
  `cell` int(4) DEFAULT NULL COMMENT '格子',
  `amount` int(4) DEFAULT NULL COMMENT '数量',
  `binded` int(4) DEFAULT NULL COMMENT '绑定状态',
  `time` int(4) DEFAULT NULL COMMENT '存表时间',
  `changetype` int(4) DEFAULT NULL COMMENT '类型',
  `changereson` int(4) DEFAULT NULL COMMENT '改变类型',
  `content` varchar(255) DEFAULT NULL COMMENT '事件参数'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of log_item_change
-- ----------------------------
INSERT INTO `log_item_change` VALUES ('4943404278480898', '31595566135771138', '2020', '32791834786791425', '31595566135771138', '0', '1', '0', '1374789833', '2', '6', '{1}');
INSERT INTO `log_item_change` VALUES ('4943404278480897', '31595566135771137', '2020', '32791834786791426', '31595566135771137', '0', '1', '0', '1375198394', '2', '6', '{1}');

-- ----------------------------
-- Table structure for `log_mail_change`
-- ----------------------------
DROP TABLE IF EXISTS `log_mail_change`;
CREATE TABLE `log_mail_change` (
  `changetype` int(4) DEFAULT NULL COMMENT '改变类型(增加 OPEN 拿钱 支付钱 拿物品1 拿物品2 删邮件)',
  `id` bigint(8) NOT NULL COMMENT '邮件ID',
  `type` int(4) DEFAULT NULL COMMENT '邮件类型',
  `recvPlayerID` bigint(8) DEFAULT NULL COMMENT '收信人ID',
  `isOpened` int(4) DEFAULT NULL COMMENT '是否已经查看',
  `tiemOut` int(4) DEFAULT NULL COMMENT '查看时间',
  `idSender` bigint(8) DEFAULT NULL COMMENT '寄件人ID',
  `nameSender` char(255) DEFAULT NULL COMMENT '寄件人名字',
  `title` char(255) DEFAULT NULL COMMENT '标题',
  `attachItemDBID1` bigint(8) DEFAULT NULL COMMENT '夹档道具1 ID',
  `attachItemDBID2` bigint(8) DEFAULT NULL COMMENT '夹档道具2 ID',
  `moneySend` int(4) DEFAULT NULL COMMENT '夹档货币 ',
  `moneyPay` int(4) DEFAULT NULL COMMENT '收取邮件需要 货币',
  `mailTimerType` int(4) DEFAULT NULL COMMENT '时间类型',
  `mailRecTime` int(4) DEFAULT NULL COMMENT '接收邮件时间',
  KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of log_mail_change
-- ----------------------------

-- ----------------------------
-- Table structure for `log_online_record`
-- ----------------------------
DROP TABLE IF EXISTS `log_online_record`;
CREATE TABLE `log_online_record` (
  `time` int(4) DEFAULT NULL,
  `count` int(4) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of log_online_record
-- ----------------------------
INSERT INTO `log_online_record` VALUES ('1374619702', '0');
INSERT INTO `log_online_record` VALUES ('1374620371', '1');
INSERT INTO `log_online_record` VALUES ('1374620671', '1');
INSERT INTO `log_online_record` VALUES ('1374620971', '1');
INSERT INTO `log_online_record` VALUES ('1374621271', '0');
INSERT INTO `log_online_record` VALUES ('1374621571', '0');
INSERT INTO `log_online_record` VALUES ('1374621871', '0');
INSERT INTO `log_online_record` VALUES ('1374622171', '0');
INSERT INTO `log_online_record` VALUES ('1374622471', '0');
INSERT INTO `log_online_record` VALUES ('1374622771', '0');
INSERT INTO `log_online_record` VALUES ('1374623071', '0');
INSERT INTO `log_online_record` VALUES ('1374623371', '0');
INSERT INTO `log_online_record` VALUES ('1374623671', '0');
INSERT INTO `log_online_record` VALUES ('1374623971', '0');
INSERT INTO `log_online_record` VALUES ('1374624271', '0');
INSERT INTO `log_online_record` VALUES ('1374624571', '0');
INSERT INTO `log_online_record` VALUES ('1374624871', '0');
INSERT INTO `log_online_record` VALUES ('1374625171', '0');
INSERT INTO `log_online_record` VALUES ('1374625471', '0');
INSERT INTO `log_online_record` VALUES ('1374625771', '0');
INSERT INTO `log_online_record` VALUES ('1374626071', '0');
INSERT INTO `log_online_record` VALUES ('1374626371', '0');
INSERT INTO `log_online_record` VALUES ('1374626671', '0');
INSERT INTO `log_online_record` VALUES ('1374626971', '0');
INSERT INTO `log_online_record` VALUES ('1374627271', '0');
INSERT INTO `log_online_record` VALUES ('1374627571', '0');
INSERT INTO `log_online_record` VALUES ('1374627871', '0');
INSERT INTO `log_online_record` VALUES ('1374628171', '0');
INSERT INTO `log_online_record` VALUES ('1374628471', '0');
INSERT INTO `log_online_record` VALUES ('1374628771', '0');
INSERT INTO `log_online_record` VALUES ('1374629071', '0');
INSERT INTO `log_online_record` VALUES ('1374629371', '0');
INSERT INTO `log_online_record` VALUES ('1374629671', '0');
INSERT INTO `log_online_record` VALUES ('1374629971', '0');
INSERT INTO `log_online_record` VALUES ('1374630271', '0');
INSERT INTO `log_online_record` VALUES ('1374630571', '0');
INSERT INTO `log_online_record` VALUES ('1374630871', '0');
INSERT INTO `log_online_record` VALUES ('1374631171', '0');
INSERT INTO `log_online_record` VALUES ('1374631471', '0');
INSERT INTO `log_online_record` VALUES ('1374631771', '0');
INSERT INTO `log_online_record` VALUES ('1374632071', '0');
INSERT INTO `log_online_record` VALUES ('1374632371', '0');
INSERT INTO `log_online_record` VALUES ('1374632671', '0');
INSERT INTO `log_online_record` VALUES ('1374632971', '0');
INSERT INTO `log_online_record` VALUES ('1374633271', '0');
INSERT INTO `log_online_record` VALUES ('1374633571', '0');
INSERT INTO `log_online_record` VALUES ('1374633871', '0');
INSERT INTO `log_online_record` VALUES ('1374634171', '0');
INSERT INTO `log_online_record` VALUES ('1374634471', '0');
INSERT INTO `log_online_record` VALUES ('1374634771', '0');
INSERT INTO `log_online_record` VALUES ('1374635071', '0');
INSERT INTO `log_online_record` VALUES ('1374635371', '0');
INSERT INTO `log_online_record` VALUES ('1374635671', '0');
INSERT INTO `log_online_record` VALUES ('1374635971', '0');
INSERT INTO `log_online_record` VALUES ('1374636271', '0');
INSERT INTO `log_online_record` VALUES ('1374636571', '0');
INSERT INTO `log_online_record` VALUES ('1374636871', '0');
INSERT INTO `log_online_record` VALUES ('1374637171', '0');
INSERT INTO `log_online_record` VALUES ('1374637471', '0');
INSERT INTO `log_online_record` VALUES ('1374637771', '0');
INSERT INTO `log_online_record` VALUES ('1374638071', '0');
INSERT INTO `log_online_record` VALUES ('1374638371', '0');
INSERT INTO `log_online_record` VALUES ('1374638671', '0');
INSERT INTO `log_online_record` VALUES ('1374638971', '0');
INSERT INTO `log_online_record` VALUES ('1374639271', '0');
INSERT INTO `log_online_record` VALUES ('1374639571', '0');
INSERT INTO `log_online_record` VALUES ('1374639871', '0');
INSERT INTO `log_online_record` VALUES ('1374640171', '0');
INSERT INTO `log_online_record` VALUES ('1374640471', '0');
INSERT INTO `log_online_record` VALUES ('1374640771', '0');
INSERT INTO `log_online_record` VALUES ('1374641071', '0');
INSERT INTO `log_online_record` VALUES ('1374641371', '0');
INSERT INTO `log_online_record` VALUES ('1374641671', '0');
INSERT INTO `log_online_record` VALUES ('1374641971', '0');
INSERT INTO `log_online_record` VALUES ('1374642271', '0');
INSERT INTO `log_online_record` VALUES ('1374642571', '0');
INSERT INTO `log_online_record` VALUES ('1374642871', '0');
INSERT INTO `log_online_record` VALUES ('1374643172', '0');
INSERT INTO `log_online_record` VALUES ('1374643472', '0');
INSERT INTO `log_online_record` VALUES ('1374643772', '0');
INSERT INTO `log_online_record` VALUES ('1374644072', '0');
INSERT INTO `log_online_record` VALUES ('1374644372', '0');
INSERT INTO `log_online_record` VALUES ('1374644672', '0');
INSERT INTO `log_online_record` VALUES ('1374644972', '0');
INSERT INTO `log_online_record` VALUES ('1374645272', '0');
INSERT INTO `log_online_record` VALUES ('1374645572', '0');
INSERT INTO `log_online_record` VALUES ('1374645872', '0');
INSERT INTO `log_online_record` VALUES ('1374646172', '0');
INSERT INTO `log_online_record` VALUES ('1374646472', '0');
INSERT INTO `log_online_record` VALUES ('1374646772', '0');
INSERT INTO `log_online_record` VALUES ('1374647072', '0');
INSERT INTO `log_online_record` VALUES ('1374647372', '0');
INSERT INTO `log_online_record` VALUES ('1374647672', '0');
INSERT INTO `log_online_record` VALUES ('1374647972', '0');
INSERT INTO `log_online_record` VALUES ('1374648272', '0');
INSERT INTO `log_online_record` VALUES ('1374648572', '0');
INSERT INTO `log_online_record` VALUES ('1374648872', '0');
INSERT INTO `log_online_record` VALUES ('1374649172', '0');
INSERT INTO `log_online_record` VALUES ('1374649472', '0');
INSERT INTO `log_online_record` VALUES ('1374649772', '0');
INSERT INTO `log_online_record` VALUES ('1374650072', '0');
INSERT INTO `log_online_record` VALUES ('1374650372', '0');
INSERT INTO `log_online_record` VALUES ('1374650672', '0');
INSERT INTO `log_online_record` VALUES ('1374650972', '0');
INSERT INTO `log_online_record` VALUES ('1374651272', '0');
INSERT INTO `log_online_record` VALUES ('1374651572', '0');
INSERT INTO `log_online_record` VALUES ('1374651872', '0');
INSERT INTO `log_online_record` VALUES ('1374652172', '0');
INSERT INTO `log_online_record` VALUES ('1374652472', '0');
INSERT INTO `log_online_record` VALUES ('1374652772', '0');
INSERT INTO `log_online_record` VALUES ('1374653072', '0');
INSERT INTO `log_online_record` VALUES ('1374653372', '0');
INSERT INTO `log_online_record` VALUES ('1374653672', '0');
INSERT INTO `log_online_record` VALUES ('1374653972', '0');
INSERT INTO `log_online_record` VALUES ('1374654272', '0');
INSERT INTO `log_online_record` VALUES ('1374654572', '0');
INSERT INTO `log_online_record` VALUES ('1374654872', '0');
INSERT INTO `log_online_record` VALUES ('1374655172', '0');
INSERT INTO `log_online_record` VALUES ('1374655472', '0');
INSERT INTO `log_online_record` VALUES ('1374655772', '0');
INSERT INTO `log_online_record` VALUES ('1374656072', '0');
INSERT INTO `log_online_record` VALUES ('1374656372', '0');
INSERT INTO `log_online_record` VALUES ('1374656672', '0');
INSERT INTO `log_online_record` VALUES ('1374656972', '0');
INSERT INTO `log_online_record` VALUES ('1374657272', '0');
INSERT INTO `log_online_record` VALUES ('1374657572', '0');
INSERT INTO `log_online_record` VALUES ('1374657872', '0');
INSERT INTO `log_online_record` VALUES ('1374658172', '0');
INSERT INTO `log_online_record` VALUES ('1374658472', '0');
INSERT INTO `log_online_record` VALUES ('1374658772', '0');
INSERT INTO `log_online_record` VALUES ('1374659072', '0');
INSERT INTO `log_online_record` VALUES ('1374659372', '0');
INSERT INTO `log_online_record` VALUES ('1374659672', '0');
INSERT INTO `log_online_record` VALUES ('1374659972', '0');
INSERT INTO `log_online_record` VALUES ('1374660272', '0');
INSERT INTO `log_online_record` VALUES ('1374660572', '0');
INSERT INTO `log_online_record` VALUES ('1374660872', '0');
INSERT INTO `log_online_record` VALUES ('1374661172', '0');
INSERT INTO `log_online_record` VALUES ('1374661472', '0');
INSERT INTO `log_online_record` VALUES ('1374661772', '0');
INSERT INTO `log_online_record` VALUES ('1374662072', '0');
INSERT INTO `log_online_record` VALUES ('1374662372', '0');
INSERT INTO `log_online_record` VALUES ('1374662672', '0');
INSERT INTO `log_online_record` VALUES ('1374662972', '0');
INSERT INTO `log_online_record` VALUES ('1374663272', '0');
INSERT INTO `log_online_record` VALUES ('1374663572', '0');
INSERT INTO `log_online_record` VALUES ('1374663872', '0');
INSERT INTO `log_online_record` VALUES ('1374664172', '0');
INSERT INTO `log_online_record` VALUES ('1374664472', '0');
INSERT INTO `log_online_record` VALUES ('1374664772', '0');
INSERT INTO `log_online_record` VALUES ('1374665072', '0');
INSERT INTO `log_online_record` VALUES ('1374665372', '0');
INSERT INTO `log_online_record` VALUES ('1374665672', '0');
INSERT INTO `log_online_record` VALUES ('1374665972', '0');
INSERT INTO `log_online_record` VALUES ('1374666272', '0');
INSERT INTO `log_online_record` VALUES ('1374666572', '0');
INSERT INTO `log_online_record` VALUES ('1374666872', '0');
INSERT INTO `log_online_record` VALUES ('1374667172', '0');
INSERT INTO `log_online_record` VALUES ('1374667472', '0');
INSERT INTO `log_online_record` VALUES ('1374667772', '0');
INSERT INTO `log_online_record` VALUES ('1374668072', '1');
INSERT INTO `log_online_record` VALUES ('1374668372', '0');
INSERT INTO `log_online_record` VALUES ('1374668672', '0');
INSERT INTO `log_online_record` VALUES ('1374668972', '0');
INSERT INTO `log_online_record` VALUES ('1374669272', '0');
INSERT INTO `log_online_record` VALUES ('1374669572', '0');
INSERT INTO `log_online_record` VALUES ('1374669872', '0');
INSERT INTO `log_online_record` VALUES ('1374670172', '0');
INSERT INTO `log_online_record` VALUES ('1374670472', '0');
INSERT INTO `log_online_record` VALUES ('1374670772', '0');
INSERT INTO `log_online_record` VALUES ('1374671072', '0');
INSERT INTO `log_online_record` VALUES ('1374671372', '0');
INSERT INTO `log_online_record` VALUES ('1374788688', '0');
INSERT INTO `log_online_record` VALUES ('1374788988', '0');
INSERT INTO `log_online_record` VALUES ('1374789288', '0');
INSERT INTO `log_online_record` VALUES ('1374789588', '1');
INSERT INTO `log_online_record` VALUES ('1374789888', '2');
INSERT INTO `log_online_record` VALUES ('1374790188', '2');
INSERT INTO `log_online_record` VALUES ('1374790701', '0');
INSERT INTO `log_online_record` VALUES ('1374791001', '0');
INSERT INTO `log_online_record` VALUES ('1375141502', '1');
INSERT INTO `log_online_record` VALUES ('1375141802', '0');
INSERT INTO `log_online_record` VALUES ('1375142102', '0');
INSERT INTO `log_online_record` VALUES ('1375142402', '0');
INSERT INTO `log_online_record` VALUES ('1375142702', '0');
INSERT INTO `log_online_record` VALUES ('1375143002', '0');
INSERT INTO `log_online_record` VALUES ('1375143302', '0');
INSERT INTO `log_online_record` VALUES ('1375143602', '0');
INSERT INTO `log_online_record` VALUES ('1375143902', '0');
INSERT INTO `log_online_record` VALUES ('1375144202', '0');
INSERT INTO `log_online_record` VALUES ('1375144502', '0');
INSERT INTO `log_online_record` VALUES ('1375144802', '0');
INSERT INTO `log_online_record` VALUES ('1375145102', '0');
INSERT INTO `log_online_record` VALUES ('1375194589', '0');
INSERT INTO `log_online_record` VALUES ('1375194889', '1');
INSERT INTO `log_online_record` VALUES ('1375195189', '1');
INSERT INTO `log_online_record` VALUES ('1375195489', '0');
INSERT INTO `log_online_record` VALUES ('1375195789', '0');
INSERT INTO `log_online_record` VALUES ('1375196089', '1');
INSERT INTO `log_online_record` VALUES ('1375196389', '0');
INSERT INTO `log_online_record` VALUES ('1375196689', '0');
INSERT INTO `log_online_record` VALUES ('1375196989', '0');
INSERT INTO `log_online_record` VALUES ('1375197289', '0');
INSERT INTO `log_online_record` VALUES ('1375197589', '1');
INSERT INTO `log_online_record` VALUES ('1375197889', '0');
INSERT INTO `log_online_record` VALUES ('1375198189', '0');
INSERT INTO `log_online_record` VALUES ('1375198489', '0');
INSERT INTO `log_online_record` VALUES ('1375198789', '0');
INSERT INTO `log_online_record` VALUES ('1375199089', '0');
INSERT INTO `log_online_record` VALUES ('1375199389', '0');
INSERT INTO `log_online_record` VALUES ('1375199689', '0');
INSERT INTO `log_online_record` VALUES ('1375199989', '0');
INSERT INTO `log_online_record` VALUES ('1375200289', '0');
INSERT INTO `log_online_record` VALUES ('1375200589', '0');
INSERT INTO `log_online_record` VALUES ('1375200889', '0');
INSERT INTO `log_online_record` VALUES ('1375201189', '0');
INSERT INTO `log_online_record` VALUES ('1375201489', '0');
INSERT INTO `log_online_record` VALUES ('1375201789', '0');
INSERT INTO `log_online_record` VALUES ('1375202089', '0');
INSERT INTO `log_online_record` VALUES ('1375202389', '0');
INSERT INTO `log_online_record` VALUES ('1375202689', '0');
INSERT INTO `log_online_record` VALUES ('1375202989', '0');
INSERT INTO `log_online_record` VALUES ('1375203289', '0');
INSERT INTO `log_online_record` VALUES ('1375203589', '0');
INSERT INTO `log_online_record` VALUES ('1375203889', '0');
INSERT INTO `log_online_record` VALUES ('1375204189', '0');
INSERT INTO `log_online_record` VALUES ('1375204489', '0');
INSERT INTO `log_online_record` VALUES ('1375204789', '0');
INSERT INTO `log_online_record` VALUES ('1375205089', '0');
INSERT INTO `log_online_record` VALUES ('1375205389', '0');
INSERT INTO `log_online_record` VALUES ('1375205689', '0');
INSERT INTO `log_online_record` VALUES ('1375205989', '0');
INSERT INTO `log_online_record` VALUES ('1375206289', '0');
INSERT INTO `log_online_record` VALUES ('1375206589', '0');
INSERT INTO `log_online_record` VALUES ('1375206889', '0');
INSERT INTO `log_online_record` VALUES ('1375207189', '0');
INSERT INTO `log_online_record` VALUES ('1375207489', '0');
INSERT INTO `log_online_record` VALUES ('1375207789', '0');
INSERT INTO `log_online_record` VALUES ('1375208089', '0');
INSERT INTO `log_online_record` VALUES ('1375208389', '0');
INSERT INTO `log_online_record` VALUES ('1375208689', '0');
INSERT INTO `log_online_record` VALUES ('1375208989', '0');
INSERT INTO `log_online_record` VALUES ('1375209289', '0');
INSERT INTO `log_online_record` VALUES ('1375209589', '0');
INSERT INTO `log_online_record` VALUES ('1375209889', '0');
INSERT INTO `log_online_record` VALUES ('1375210189', '0');
INSERT INTO `log_online_record` VALUES ('1375210489', '0');
INSERT INTO `log_online_record` VALUES ('1375210789', '0');
INSERT INTO `log_online_record` VALUES ('1375211089', '0');
INSERT INTO `log_online_record` VALUES ('1375211389', '0');
INSERT INTO `log_online_record` VALUES ('1375211689', '0');
INSERT INTO `log_online_record` VALUES ('1375211989', '0');
INSERT INTO `log_online_record` VALUES ('1375212289', '0');
INSERT INTO `log_online_record` VALUES ('1375212589', '0');
INSERT INTO `log_online_record` VALUES ('1375212889', '0');
INSERT INTO `log_online_record` VALUES ('1375213189', '0');
INSERT INTO `log_online_record` VALUES ('1375213489', '0');
INSERT INTO `log_online_record` VALUES ('1375213789', '0');
INSERT INTO `log_online_record` VALUES ('1375214089', '0');
INSERT INTO `log_online_record` VALUES ('1375214389', '0');
INSERT INTO `log_online_record` VALUES ('1375214689', '0');
INSERT INTO `log_online_record` VALUES ('1375214989', '0');
INSERT INTO `log_online_record` VALUES ('1375215289', '0');
INSERT INTO `log_online_record` VALUES ('1375215589', '0');
INSERT INTO `log_online_record` VALUES ('1375215889', '0');
INSERT INTO `log_online_record` VALUES ('1375216189', '0');
INSERT INTO `log_online_record` VALUES ('1375216489', '0');
INSERT INTO `log_online_record` VALUES ('1375216789', '0');
INSERT INTO `log_online_record` VALUES ('1375217089', '0');
INSERT INTO `log_online_record` VALUES ('1375217389', '0');
INSERT INTO `log_online_record` VALUES ('1375217689', '0');
INSERT INTO `log_online_record` VALUES ('1375217989', '0');
INSERT INTO `log_online_record` VALUES ('1375218289', '0');
INSERT INTO `log_online_record` VALUES ('1375218589', '0');
INSERT INTO `log_online_record` VALUES ('1375218889', '0');
INSERT INTO `log_online_record` VALUES ('1375219189', '0');
INSERT INTO `log_online_record` VALUES ('1375219489', '0');
INSERT INTO `log_online_record` VALUES ('1375219789', '0');
INSERT INTO `log_online_record` VALUES ('1375220089', '0');
INSERT INTO `log_online_record` VALUES ('1375220389', '0');
INSERT INTO `log_online_record` VALUES ('1375220689', '0');
INSERT INTO `log_online_record` VALUES ('1375220989', '0');
INSERT INTO `log_online_record` VALUES ('1375221289', '0');
INSERT INTO `log_online_record` VALUES ('1375221589', '0');
INSERT INTO `log_online_record` VALUES ('1375221889', '0');
INSERT INTO `log_online_record` VALUES ('1375222189', '0');
INSERT INTO `log_online_record` VALUES ('1375222489', '0');
INSERT INTO `log_online_record` VALUES ('1375222790', '0');
INSERT INTO `log_online_record` VALUES ('1375223090', '0');
INSERT INTO `log_online_record` VALUES ('1375223390', '0');
INSERT INTO `log_online_record` VALUES ('1375223690', '0');
INSERT INTO `log_online_record` VALUES ('1375223990', '0');
INSERT INTO `log_online_record` VALUES ('1375224290', '0');
INSERT INTO `log_online_record` VALUES ('1375224590', '0');
INSERT INTO `log_online_record` VALUES ('1375224890', '0');
INSERT INTO `log_online_record` VALUES ('1375225190', '0');
INSERT INTO `log_online_record` VALUES ('1375225490', '0');
INSERT INTO `log_online_record` VALUES ('1375225790', '0');
INSERT INTO `log_online_record` VALUES ('1375226090', '0');
INSERT INTO `log_online_record` VALUES ('1375226390', '0');
INSERT INTO `log_online_record` VALUES ('1375226690', '0');
INSERT INTO `log_online_record` VALUES ('1375226990', '0');
INSERT INTO `log_online_record` VALUES ('1375227290', '0');
INSERT INTO `log_online_record` VALUES ('1375227590', '0');
INSERT INTO `log_online_record` VALUES ('1375227890', '0');
INSERT INTO `log_online_record` VALUES ('1375228190', '0');
INSERT INTO `log_online_record` VALUES ('1375228490', '0');
INSERT INTO `log_online_record` VALUES ('1375228790', '0');
INSERT INTO `log_online_record` VALUES ('1375229090', '0');
INSERT INTO `log_online_record` VALUES ('1375229390', '0');
INSERT INTO `log_online_record` VALUES ('1375229690', '0');
INSERT INTO `log_online_record` VALUES ('1375229990', '0');
INSERT INTO `log_online_record` VALUES ('1375230290', '0');
INSERT INTO `log_online_record` VALUES ('1375230590', '0');
INSERT INTO `log_online_record` VALUES ('1375230890', '0');
INSERT INTO `log_online_record` VALUES ('1375231190', '0');
INSERT INTO `log_online_record` VALUES ('1375231490', '0');
INSERT INTO `log_online_record` VALUES ('1375231790', '0');
INSERT INTO `log_online_record` VALUES ('1375232090', '0');
INSERT INTO `log_online_record` VALUES ('1375232390', '0');
INSERT INTO `log_online_record` VALUES ('1375232690', '0');

-- ----------------------------
-- Table structure for `log_player`
-- ----------------------------
DROP TABLE IF EXISTS `log_player`;
CREATE TABLE `log_player` (
  `playerid` bigint(8) DEFAULT NULL,
  `name` varchar(32) DEFAULT NULL,
  `camp` int(4) DEFAULT NULL,
  `sex` int(4) DEFAULT NULL,
  `time` int(4) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of log_player
-- ----------------------------
INSERT INTO `log_player` VALUES ('4943404278480897', '占流觞', '0', '0', '1374620112');
INSERT INTO `log_player` VALUES ('4943404278480898', '大大佩洲', '1', '0', '1374789584');

-- ----------------------------
-- Table structure for `log_player_event`
-- ----------------------------
DROP TABLE IF EXISTS `log_player_event`;
CREATE TABLE `log_player_event` (
  `userid` bigint(8) DEFAULT NULL COMMENT '账号ID',
  `playerid` bigint(8) DEFAULT NULL COMMENT '角色ID',
  `level` int(4) DEFAULT NULL COMMENT '等级',
  `money` int(4) DEFAULT NULL COMMENT '游戏币',
  `money_b` int(4) DEFAULT NULL COMMENT '游戏币2',
  `gold` int(4) DEFAULT NULL COMMENT '元宝',
  `gold_b` int(4) DEFAULT NULL COMMENT '元宝2',
  `exp` int(4) DEFAULT NULL COMMENT '经验',
  `life` int(4) DEFAULT NULL COMMENT '生命值',
  `time` int(4) DEFAULT NULL COMMENT '存表时间',
  `eventtype` int(4) DEFAULT NULL COMMENT '事件类型',
  `content` varchar(255) DEFAULT NULL COMMENT '事件参数'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of log_player_event
-- ----------------------------
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '1', '0', '0', '0', '0', '0', '231', '1374620113', '0', '{login_param,1374620113}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '231', '1374621010', '1', '{logout_param,1374621010}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374668062', '0', '{login_param,1374668062}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374668108', '1', '{logout_param,1374668108}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374668156', '0', '{login_param,1374668156}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374668170', '1', '{logout_param,1374668170}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374668186', '0', '{login_param,1374668186}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374668205', '1', '{logout_param,1374668205}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374668207', '0', '{login_param,1374668207}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374668228', '1', '{logout_param,1374668228}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374668297', '0', '{login_param,1374668297}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374668358', '1', '{logout_param,1374668358}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374788479', '0', '{login_param,1374788479}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374788499', '1', '{logout_param,1374788499}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374789454', '0', '{login_param,1374789454}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374789477', '1', '{logout_param,1374789477}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374789516', '0', '{login_param,1374789516}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374789564', '1', '{logout_param,1374789564}');
INSERT INTO `log_player_event` VALUES ('4943404278480898', '31595566135771138', '1', '0', '0', '0', '0', '0', '199', '1374789586', '0', '{login_param,1374789586}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374789599', '0', '{login_param,1374789599}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374789605', '1', '{logout_param,1374789605}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374789622', '0', '{login_param,1374789622}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374789746', '1', '{logout_param,1374789746}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1374789883', '0', '{login_param,1374789883}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1375141418', '0', '{login_param,1375141418}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1375141658', '1', '{logout_param,1375141658}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1375194399', '0', '{login_param,1375194399}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1375194566', '1', '{logout_param,1375194566}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1375194874', '0', '{login_param,1375194874}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1375194911', '1', '{logout_param,1375194911}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1375195055', '0', '{login_param,1375195055}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1375195304', '1', '{logout_param,1375195304}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1375195389', '0', '{login_param,1375195389}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1375195449', '1', '{logout_param,1375195449}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1375195899', '0', '{login_param,1375195899}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1375196200', '1', '{logout_param,1375196200}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1375197186', '0', '{login_param,1375197186}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1375197246', '1', '{logout_param,1375197246}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1375197440', '0', '{login_param,1375197440}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1375197531', '1', '{logout_param,1375197531}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1375197553', '0', '{login_param,1375197553}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1375197620', '1', '{logout_param,1375197620}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1375197657', '0', '{login_param,1375197657}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1375197710', '1', '{logout_param,1375197710}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1375198275', '0', '{login_param,1375198275}');
INSERT INTO `log_player_event` VALUES ('4943404278480897', '31595566135771137', '6', '0', '69', '0', '0', '182', '52', '1375198462', '1', '{logout_param,1375198462}');

-- ----------------------------
-- Table structure for `log_player_login`
-- ----------------------------
DROP TABLE IF EXISTS `log_player_login`;
CREATE TABLE `log_player_login` (
  `userid` bigint(8) DEFAULT NULL,
  `playerid` bigint(8) DEFAULT NULL,
  `level` int(4) DEFAULT NULL,
  `money` int(4) DEFAULT NULL,
  `money_b` int(4) DEFAULT NULL,
  `gold` int(4) DEFAULT NULL,
  `gold_b` int(4) DEFAULT NULL,
  `exp` int(4) DEFAULT NULL,
  `life` int(4) DEFAULT NULL,
  `flag` int(4) DEFAULT NULL,
  `time` int(4) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of log_player_login
-- ----------------------------
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '1', '0', '0', '0', '0', '0', '231', '0', '1374620113');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '231', '1', '1374621010');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '0', '1374668062');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1', '1374668108');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '0', '1374668156');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1', '1374668170');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '0', '1374668186');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1', '1374668205');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '0', '1374668207');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1', '1374668228');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '0', '1374668297');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1', '1374668358');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '0', '1374788479');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1', '1374788499');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '0', '1374789454');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1', '1374789477');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '0', '1374789516');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1', '1374789564');
INSERT INTO `log_player_login` VALUES ('4943404278480898', '31595566135771138', '1', '0', '0', '0', '0', '0', '199', '0', '1374789586');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '0', '1374789599');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1', '1374789605');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '0', '1374789622');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1', '1374789746');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '0', '1374789883');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '0', '1375141418');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1', '1375141658');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '0', '1375194399');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '56', '1', '1375194566');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '0', '1375194874');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1', '1375194911');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '0', '1375195055');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1', '1375195304');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '0', '1375195389');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1', '1375195449');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '0', '1375195899');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1', '1375196200');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '0', '1375197186');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1', '1375197246');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '0', '1375197440');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1', '1375197531');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '0', '1375197553');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1', '1375197620');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '0', '1375197657');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '1', '1375197710');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '179', '52', '0', '1375198275');
INSERT INTO `log_player_login` VALUES ('4943404278480897', '31595566135771137', '6', '0', '69', '0', '0', '182', '52', '1', '1375198462');

-- ----------------------------
-- Table structure for `log_player_machine`
-- ----------------------------
DROP TABLE IF EXISTS `log_player_machine`;
CREATE TABLE `log_player_machine` (
  `id` bigint(8) NOT NULL AUTO_INCREMENT,
  `playerid` bigint(8) NOT NULL,
  `userid` bigint(8) NOT NULL,
  `platform` varchar(255) DEFAULT NULL,
  `machine` varchar(255) DEFAULT NULL,
  `timelogin` int(11) DEFAULT NULL,
  `timelogout` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of log_player_machine
-- ----------------------------

-- ----------------------------
-- Table structure for `log_player_task`
-- ----------------------------
DROP TABLE IF EXISTS `log_player_task`;
CREATE TABLE `log_player_task` (
  `userid` bigint(8) DEFAULT NULL,
  `playerid` bigint(8) DEFAULT NULL,
  `taskid` int(4) DEFAULT NULL,
  `level` int(4) DEFAULT NULL,
  `flag` int(4) DEFAULT NULL,
  `time` int(4) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of log_player_task
-- ----------------------------
INSERT INTO `log_player_task` VALUES ('4943404278480898', '31595566135771138', '100', '1', '1', '1374789833');
INSERT INTO `log_player_task` VALUES ('4943404278480898', '31595566135771138', '101', '1', '0', '1374790032');
INSERT INTO `log_player_task` VALUES ('4943404278480897', '31595566135771137', '100', '5', '1', '1375198394');
INSERT INTO `log_player_task` VALUES ('4943404278480897', '31595566135771137', '101', '5', '0', '1375198406');
INSERT INTO `log_player_task` VALUES ('4943404278480897', '31595566135771137', '101', '5', '1', '1375198410');
INSERT INTO `log_player_task` VALUES ('4943404278480897', '31595566135771137', '102', '5', '0', '1375198411');
INSERT INTO `log_player_task` VALUES ('4943404278480897', '31595566135771137', '102', '6', '1', '1375198429');
INSERT INTO `log_player_task` VALUES ('4943404278480897', '31595566135771137', '103', '6', '0', '1375198430');
INSERT INTO `log_player_task` VALUES ('4943404278480897', '31595566135771137', '103', '6', '1', '1375198441');
INSERT INTO `log_player_task` VALUES ('4943404278480897', '31595566135771137', '104', '6', '0', '1375198442');

-- ----------------------------
-- Table structure for `log_recharge`
-- ----------------------------
DROP TABLE IF EXISTS `log_recharge`;
CREATE TABLE `log_recharge` (
  `orderid` varchar(64) NOT NULL,
  `platform` int(4) NOT NULL,
  `account` varchar(32) NOT NULL,
  `userid` bigint(8) NOT NULL,
  `playerid` bigint(8) NOT NULL,
  `ammount` int(4) NOT NULL,
  `flag` int(4) NOT NULL,
  `time` int(4) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of log_recharge
-- ----------------------------

-- ----------------------------
-- Table structure for `log_token_change`
-- ----------------------------
DROP TABLE IF EXISTS `log_token_change`;
CREATE TABLE `log_token_change` (
  `userid` bigint(8) DEFAULT NULL COMMENT '账号ID',
  `playerid` bigint(8) DEFAULT NULL COMMENT '角色ID',
  `level` int(4) DEFAULT NULL COMMENT '等级',
  `money` int(4) DEFAULT NULL COMMENT '游戏币',
  `money_b` int(4) DEFAULT NULL COMMENT '游戏币2',
  `gold` int(4) DEFAULT NULL COMMENT '元宝',
  `gold_b` int(4) DEFAULT NULL COMMENT '元宝2',
  `exp` int(4) DEFAULT NULL COMMENT '经验',
  `life` int(4) DEFAULT NULL COMMENT '生命值',
  `time` int(4) DEFAULT NULL COMMENT '存表时间',
  `tokentype` int(4) DEFAULT NULL COMMENT '货币类型',
  `relust` int(4) DEFAULT NULL COMMENT '改变结果(增加或减少)',
  `changetype` int(4) DEFAULT NULL COMMENT '改变类型',
  `content` varchar(255) DEFAULT NULL COMMENT '事件参数',
  `number` int(8) DEFAULT NULL COMMENT '货币数量'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of log_token_change
-- ----------------------------
INSERT INTO `log_token_change` VALUES ('4943404278480898', '31595566135771138', '1', '0', '0', '0', '0', '4', '199', '1374789833', '0', '1', '2', '{token_param,2,1,100,0,0,0,0}', '2');
INSERT INTO `log_token_change` VALUES ('4943404278480897', '31595566135771137', '5', '0', '0', '0', '0', '183', '52', '1375198394', '0', '1', '2', '{token_param,2,1,100,0,0,0,0}', '2');
INSERT INTO `log_token_change` VALUES ('4943404278480897', '31595566135771137', '5', '0', '2', '0', '0', '187', '52', '1375198410', '0', '1', '2', '{token_param,2,1,101,0,0,0,0}', '2');
INSERT INTO `log_token_change` VALUES ('4943404278480897', '31595566135771137', '6', '0', '4', '0', '0', '178', '52', '1375198429', '0', '1', '2', '{token_param,2,1,102,0,0,0,0}', '63');
INSERT INTO `log_token_change` VALUES ('4943404278480897', '31595566135771137', '6', '0', '67', '0', '0', '182', '52', '1375198441', '0', '1', '2', '{token_param,2,1,103,0,0,0,0}', '2');
