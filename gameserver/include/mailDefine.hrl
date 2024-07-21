-ifndef(mailDefine_hrl).

-define( Max_Player_Mail_Light, 50 ).%%玩家邮件数量，明格
-define( Max_Player_Mail_Dark, 50 ).%%玩家邮件数量，暗格
-define( Max_Player_Mail_Count, ?Max_Player_Mail_Light + ?Max_Player_Mail_Dark ). %%玩家邮件数量，总量

-define( Mail_Type_Normal, 0 ).%%普通邮件
-define( Mail_Type_System, 1 ).%%系统邮件

-define( Max_Mail_Title_Len, 30 ).%%邮件标题长度
-define( Max_Mail_Content_Len, 210 ).%%邮件内容长度



-define( Time_Mail_NoAttach, 5*24*60*60 ).%%未带附件的邮件系统默认存在时间为5天
-define( Time_Mail_Attach, 10*24*60*60 ).%%带附件的邮件系统默认存在时间为10天
-define( Time_Pay_Mail, 24*60*60 ).%%付费取物邮件系统默认为存在时间为24小时

-define( Mail_Updater_Timer,60*60*1000).  %%1小时

-define( MailSenderID_System, 1000000000 ).%%系统邮件发送者ID	

-define( MaileTimer_5, 1 ).%%邮件时间类型，5天
-define( MaileTimer_10, 2 ).%%邮件时间类型，10天
-define( MaileTimer_24, 3 ).%%邮件时间类型，24小时

%%邮件发送结果
-define( SendMailResult_Succ, 0 ).%%发送成功
-define( SendMailResult_Fail_SendMoney, -1 ).%%发送失败，发送铜币不够
-define( SendMailResult_Fail_SendItem, -2 ).%%发送失败，发送物品错误
-define( SendMailResult_Fail_TargetUnvalid, -3 ).%%发送失败，接收者无效
-define( SendMailResult_Fail_TargetFull, -4 ).%%发送失败，接收者邮箱已满
-define( SendMailResult_Fail_SystemBusy, -5 ).%%发送失败，系统忙
-define( SendMailResult_Fail_SendDataUnvalid, -6 ).%%发送失败，发送数据错误
-define( SendMailResult_Fail_SendForbiddenString, -7 ).%%发送失败，发送数据含敏感字符
-define( SendMailResult_Switch_Process, 1).%%邮件中的进程跳转，无关乎邮件成功失败


-record( msgPlayerRecvMail, { moneyRecv, itemRecv1, itemRecv2 } ).%%玩家收取邮件后，邮件进程通知玩家进程
-record( msgPlayerSetBagLock, { location, cell, lockID } ).%%玩家进程接收消息，设置背包格子锁定
-record( mailTimer, {id,time} ).%%时间顺序的邮件列表

-endif. % -ifdef(mailDefine_hrl).