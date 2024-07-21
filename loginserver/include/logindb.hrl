
%%user
%% CREATE TABLE `user` (
%%   `id` bigint(8) NOT NULL,
%%   `platformId` int(4) DEFAULT NULL,
%%   `userName` char(32) DEFAULT NULL,
%%   `resVer` int(4) DEFAULT NULL,
%%   `exeVer` int(4) DEFAULT NULL,
%%   `gameVer` int(4) DEFAULT NULL,
%%   `protocolVer` int(4) DEFAULT NULL,
%%   `lastLogintime` int(4) DEFAULT NULL,
%%   UNIQUE KEY `id` (`id`),
%%   UNIQUE KEY `platAndName` (`platformId`,`userName`)
%% ) ENGINE=MyISAM DEFAULT CHARSET=utf8;
-record(user, {id, platformId, userName, resVer, exeVer,gameVer,protocolVer,lastLogintime,createTime}).

%%user4test
%% CREATE TABLE `user4test` (
%%   `id` bigint(8) NOT NULL,
%%   PRIMARY KEY (`id`)
%% ) ENGINE=MyISAM DEFAULT CHARSET=utf8
-record(user4test, {id}).

%%forbidden
%% CREATE TABLE `forbidden` (
%%   `account` char(32) NOT NULL,
%%   `flag` int(4) NOT NULL DEFAULT '0',
%%   `reason` int(4) NOT NULL DEFAULT '0',
%%   `timeBegin` int(4) NOT NULL DEFAULT '0',
%%   `timeEnd` int(4) NOT NULL DEFAULT '0',
%%   UNIQUE KEY `account` (`account`)
%% ) ENGINE=MyISAM DEFAULT CHARSET=utf8
-record(forbidden, {account, flag, reason, timeBegin, timeEnd}).

%%platform_test
%% CREATE TABLE `platform_test` (
%%   `account` varchar(32) NOT NULL DEFAULT '',
%%   `ip` varchar(32) NOT NULL DEFAULT ''
%% ) ENGINE=MyISAM DEFAULT CHARSET=utf8
-record(platform_test, {account, ip}).

-record(activedMachine, {codeStr, activeTime, extra}).

-record(gsConfig,{serverID,name,isnew,begintime,recommend,hot}).
-record(gsConfigUpdate,{name,isnew,begintime,recommend,hot,serverID}).
