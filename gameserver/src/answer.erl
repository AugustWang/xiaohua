%% Author: yueliangyou
%% Created: 2013-5-28
%% Description: TODO: 
-module(answer).

%%
%% Include files
%%
-include("db.hrl").
-include("logdb.hrl").
-include("answer.hrl").
-include("variant.hrl").
-include("playerDefine.hrl").
-include("mailDefine.hrl").
-include("globalDefine.hrl").
-include("package.hrl").
-include("hdlt_logger.hrl").
-include_lib("stdlib/include/ms_transform.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

init()->
	?DEBUG_OUT("answer proc init ...",[]),
	%% 创建答题排名的ets表
	AnswerTopList=ets:new( 'answerTopList', [set,named_table,protected, {read_concurrency,true}, { keypos, #answer_top.playerid }] ),
	put("AnswerTopList",AnswerTopList),
	%% 加载题目信息
	loadQuestions(),
	%% 初始状态
	put("AnswerStatus",?ANSWER_STATUS_NONE),
	%% 答题系统开启时间
	put("AnswerStartTime",0),
	%% 当前题目
	put("Question",{}),
	%% 当前题目数量
	put("QuestionCount",0),
	ok.

%% 开启答题系统，测试用
startEx()->
	gen_server:cast(answerProcPID,{'start'}).

%% 开启答题系统
start()->
	?LOG_OUT("answer system started.",[]),
	%% 答题系统开启时间
	put("AnswerStartTime",common:timestamp()),
	%% 检查答题系统当前状态
	case get("AnswerStatus") of 
		?ANSWER_STATUS_NONE->
			%% 当前题目
			put("Question",{}),
			%% 当前题目数量
			put("QuestionCount",0),
			%% 清理掉之前的答题排名数据
			ets:delete_all_objects(get("AnswerTopList")),
			%% 进入答题准备阶段
			ready();
		_->ok
	end.

%% 答题准备
ready()->
	%% 进入准备状态
	put("AnswerStatus",?ANSWER_STATUS_READY),
	%% 提问timer
	timer:send_after(?READY_TIME, {answerTimer_Question} ),
	%% 通知玩家做好答题准备
	broadcastAnswerReady(),
	ok.

sortAnswers()->
	case random:uniform(4) of
		1->{1,2,3,4};
		2->{2,1,3,4};
		3->{3,2,1,4};
		4->{4,2,3,1};
		_->{1,2,3,4}	
	end.

randExclude()->
	case random:uniform(3)+1 of
		2->{3,4};
		3->{2,4};
		4->{2,3};
		_->{2,3}	
	end.

%% 提问
question()->
	?DEBUG_OUT("answer system question ...",[]),
	%% 进入答题状态
	put("AnswerStatus",?ANSWER_STATUS_QUESTION),
	%% 广播排名信息
	broadcastTopList(),

	case get("QuestionCount") < ?QUESTION_LIMIT of
		true->
			put("Question",randQuestion()),
			?DEBUG_OUT("randQuestion is:~p",[get("Question")]),
			%% 广播题目
			broadcastQuestion(),
			%% 题目数+1
			put("QuestionCount",get("QuestionCount")+1),
			?DEBUG_OUT("QuestionCount=~p",[get("QuestionCount")]),
			%% 提问timer
			timer:send_after(?QUESTION_INTERVAL, {answerTimer_Question} );
		false->
			close()
	end.

%% 关闭答题系统
close()->
	?DEBUG_OUT("answer system closing ...",[]),
	%% 进入休眠状态
	put("AnswerStatus",?ANSWER_STATUS_NONE),
	%% 当前题目
	put("Question",{}),
	%% 当前题目数量
	put("QuestionCount",0),
	%% 广播答题结束
	broadcastClose(),
	ok.

randQuestion()->
	case get("QuestionCount") < ?QUESTION_GAME of
		true->
			Query = ets:fun2ms( fun(#question{type=T}=Record ) when (T =:= ?QUESTION_TYPE_GAME) -> Record end);
		false->
			Query = ets:fun2ms( fun(#question{type=T}=Record ) when (T =:= ?QUESTION_TYPE_OTHER) -> Record end)
	end,
		
        QuestionList = ets:select( ?QuestionsAtom, Query),
        %%?DEBUG_OUT("QuestionList=~p",[QuestionList]),
	case length(QuestionList)>0 of
		false->#question{id=0,type=0,desc=0,c1=0,c2=0,c3=0,c4=0};
		true->lists:nth(random:uniform(length(QuestionList)),QuestionList)
	end.

%% 加载前50排名到内存
loadQuestions()->
	case db:openBinData( "question.bin" ) of
                [] ->
                        ?ERROR_OUT( "answer proc openBinData question.bin false []" );
                QuestionData ->
                        db:loadBinData( QuestionData, question ),

			ets:new( ?QuestionsAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #question.id } ] ),

                        QuestionCfgList = db:matchObject(question,  #question{_='_'} ),
                        MyFunc1 = fun( Record )->
                                etsBaseFunc:insertRecord(?QuestionsAtom, Record)
                        end,
                        lists:map( MyFunc1, QuestionCfgList ),
                        ?DEBUG_OUT( "answer proc load question succ" )
        end.

%% 提交答题分数
commitScore(PlayerID,Name,Score)->
	?DEBUG_OUT("commitScore PlayerID=~p,Name=~p,Score=~p",[PlayerID,Name,Score]),
	etsBaseFunc:insertRecord(?QuestionsAtom,#answer_top{playerid=PlayerID,name=Name,score=Score}),
	ok.

getReadyTime()->
	get("AnswerStartTime")+?READY_TIME div 1000-common:timestamp().

getSystemInfo()->
	StartTime = get("AnswerStartTime"),
	ReadyTime = getReadyTime(),
	Status = get("AnswerStatus"),
	Num = get("QuestionCount"),
	Max = ?QUESTION_LIMIT,
	Que = get("Question"),
	{A,B,C,D} = sortAnswers(),
	{E1,E2} = randExclude(),
	case Que of
		{}->
			?DEBUG_OUT("getSystemInfo Info:~p",[{Status,StartTime,ReadyTime,0,Num,Max}]),
			{Status,StartTime,ReadyTime,0,Num,Max,A,B,C,D,E1,E2};
		_->
			?DEBUG_OUT("getSystemInfo Info:~p",[{Status,StartTime,ReadyTime,Que#question.id,Num,Max}]),
			{Status,StartTime,ReadyTime,Que#question.qid,Num,Max,A,B,C,D,E1,E2}
	end.


%% 获取排名列表
getTopList()->
	Query = ets:fun2ms( fun(#answer_top{}=Record ) -> Record end),
	AnswerTopList = ets:select( ?QuestionsAtom, Query),
	TopList = lists:sort(fun(A,B)-> A#answer_top.score<B#answer_top.score end,AnswerTopList),
	?DEBUG_OUT("TopList=~p",[TopList]),
	case length(TopList) < ?TOP_ANSWER_LIMIT of 
		true->lists:reverse(TopList);
		false->lists:reverse(lists:nthtail(length(TopList)-?TOP_ANSWER_LIMIT,TopList))
	end.

%% 获取前10玩家
getTopTen()->
	Query = ets:fun2ms( fun(#answer_top{}=Record ) -> Record end),
	AnswerTopList = ets:select( ?QuestionsAtom, Query),
	TopList = lists:sort(fun(A,B)-> A#answer_top.score<B#answer_top.score end,AnswerTopList),
	?DEBUG_OUT("TopList=~p",[TopList]),
	case length(TopList) < 10 of 
		true->lists:reverse(TopList);
		false->lists:reverse(lists:nthtail(length(TopList)-10,TopList))
	end.

%% 广播答题准备
broadcastAnswerReady()->
	?DEBUG_OUT("broadcastAnswerReady readyTime=~p",[getReadyTime()]),
	player:castToAllOnlinePlayer({'answerReady',getReadyTime()}),
	ok.

%% 广播题目信息
broadcastQuestion()->
	Que = get("Question"),
	Num = get("QuestionCount"),
	Max = ?QUESTION_LIMIT,
	{A,B,C,D} = sortAnswers(),
	{E1,E2} = randExclude(),
	player:castToAllOnlinePlayer({'answerQuestion',Que#question.qid,Num,Max,A,B,C,D,E1,E2}),
	ok.

convertAnswerTopList(List)->
	NewList=#pk_AnswerTopInfo{ top=get("TopListCount"),
                                        playerid=List#answer_top.playerid,
                                        name=List#answer_top.name,
                                        core=List#answer_top.score},
	put("TopListCount",get("TopListCount")-1),
        NewList.

%% 广播排名
broadcastTopList()->
	TopList = getTopList(),
	put("TopListCount",length(TopList)),
        TopListNew=lists:map(fun(List) -> convertAnswerTopList(List) end, TopList),
	?DEBUG_OUT("TopListNew is:~p",[TopListNew]),
	case TopListNew of
                []-> player:sendToAllOnLinePlayer( #pk_GS2U_AnswerTopList{info_list=[]} );
                _ -> player:sendToAllOnLinePlayer( #pk_GS2U_AnswerTopList{info_list=TopListNew})
        end.

%% 广播答题结束
broadcastClose()->
	player:castToAllOnlinePlayer({'answerClose'}),
	ok.

%%%%%%%%%%%============================================================
%%%%%%%%%%% 玩家进程 ==================================================
commitAnswerScore(PlayerID,Name,Score)->
	gen_server:cast(answerProcPID,{'commitScore',PlayerID,Name,Score}).

%% 获取答题系统信息
getAnswerSystemInfo()->
	gen_server:call(answerProcPID,{'getSystemInfo'}).

%% 获取答题系统排名前10
getAnswerSystemTopTen()->
	gen_server:call(answerProcPID,{'getTopTen'}).


%% 判断是否为正确答案
isRightAnswer(Answer)->
	Answer =:= 1.

getBaseScore()->
	case get("UseSpecialDouble") of
		1->20;
		_->10
	end.

%% 获取答题积分
getScoreByTime(Time)->
	case (Time >= 0) and (Time =< 10) of
		true->getBaseScore()+10-Time;
		false->getBaseScore()
	end.

%% 重置答题数据
resetAnswerInfo()->
	setQuestionNum(0),
	setAnswerState(?ANSWER_USER_STATE_NONE),
	setAnswerScore(0).

%% 玩家上线处理
onPlayerOnline(LastOfflineTime)->
	{Status,StartTime,ReadyTime,Qid,Num,Max,A,B,C,D,E1,E2} = getAnswerSystemInfo(),
	case StartTime > LastOfflineTime of
		true->resetAnswerInfo();
		false->ok
	end,
	case Status of
		?ANSWER_STATUS_NONE->ok;
		?ANSWER_STATUS_READY->onAnswerReady(ReadyTime);
		?ANSWER_STATUS_QUESTION->
			case getQuestionNum() =:= Num of
				true->ok;
				false->onQuestion(Qid,Num,Max,A,B,C,D,E1,E2)
			end;
		_->ok
	end.

%% 答题准备处理
onAnswerReady(Time)->
	case vip:isVipPlayer() of
		true->Count = 2;
		false->Count = 1
	end,
	setAnswerSpecial(?ANSWER_SPECIAL_DOUBLE,Count),
	setAnswerSpecial(?ANSWER_SPECIAL_RIGHT,Count),
	setAnswerSpecial(?ANSWER_SPECIAL_EXCLUDE,Count),
	sendAnswerReady(Time).

%% 答题结束处理
onAnswerClose()->
	%% 给予奖励
	TopTen = getAnswerSystemTopTen(),
	put("AwardTopNo",1),
	AwardFun = fun(Top)->
		case get("AwardTopNo") of
			1->ItemCount=?ANSWER_TOP_AWARD_COUNT1,MailContent=?ANSWER_TOP_AWARD_MAIL1;
			2->ItemCount=?ANSWER_TOP_AWARD_COUNT2,MailContent=?ANSWER_TOP_AWARD_MAIL2;
			_->ItemCount=?ANSWER_TOP_AWARD_COUNT10,MailContent=?ANSWER_TOP_AWARD_MAIL10
		end,
		Ret = mail:sendSystemMailToPlayer(Top#answer_top.playerid,"system",?ANSWER_TOP_AWARD_MAIL_TITLE,MailContent,?ANSWER_TOP_AWARD_ITEMID,ItemCount,true,0,0,true,0),
                case Ret =:= ?SendMailResult_Succ of
                	true->ok;
                	false->
                                ?LOG_OUT("onAnswerClose AwardTop10 fail.Top:~p,PlayerID:~p,ItemID:~p,Count:~p",[get("AwardTopNo"),Top#answer_top.playerid,?ANSWER_TOP_AWARD_ITEMID,ItemCount])
        	end,
		put("AwardTopNo",get("AwardTopNo")+1)
	end,
	lists:foreach(AwardFun,TopTen),
	resetAnswerInfo(),
	sendAnswerClose().

onQuestion(QID,Num,Max,A,B,C,D,E1,E2)->
	put("UseSpecialDouble",0),
	put("UseSpecialRight",0),
	put("UseSpecialExclude",0),
	setAnswerState(?ANSWER_USER_STATE_WAITCOMMIT),
	setQuestionNum(Num),
	sendQuestion(QID,Num,Max,A,B,C,D,E1,E2),
	ok.

onAnswerAward(Num)->
	Level = player:getCurPlayerProperty( #player.level ),
	ConvoyAwardList=convoy:getAwardByLevel(Level),
	case ConvoyAwardList of
		{}->?LOG_OUT("onAnswerAward no level cfg Level= ~p",[Level]);
		_->
			ParamTuple = #exp_param{changetype = ?Exp_Change_Answer,param1=Num},
			player:addPlayerEXP(ConvoyAwardList#convoyAwardCfg.answer_exp*getAnswerScore(), ?Exp_Change_Answer, ParamTuple)
	end.		

%% 玩家提交答案
onPlayerCommitAnswer(Num,Answer,Time)->
	?DEBUG_OUT("onPlayerCommitAnswer Num=~p,Answer=~p,Time=~p",[Num,Answer,Time]),
	%% 确定提交的是当前题目的答案
	case (getQuestionNum() =:= Num) and (getAnswerState() =:= ?ANSWER_USER_STATE_WAITCOMMIT) of
		true->
			case isRightAnswer(Answer) of
				true->
					Score=getScoreByTime(Time),
					setAnswerScore(getAnswerScore()+Score),
					?DEBUG_OUT("onPlayerCommitAnswer Num=~p,Answer=~p,Time=~p,Score=~p",[Num,Answer,Time,Score]),
					player:send(#pk_U2GS_AnswerCommitRet{ret=0,score=Score}),	
					onAnswerAward(Num),
					%% 向答题进程提交分数，用于排名
					commitAnswerScore(player:getCurPlayerID(),player:getCurPlayerName(),getAnswerScore());
				false->
					?DEBUG_OUT("onPlayerCommitAnswer Num=~p,Answer=~p,Time=~p,Score=~p",[Num,Answer,Time,0]),
					player:send(#pk_U2GS_AnswerCommitRet{ret=1,score=0})
			end;
		false->ok
	end,
	setAnswerState(?ANSWER_USER_STATE_COMMITED),
	ok.

%% 玩家使用特殊功能
onPlayerUseSpecial(Type)->
	?DEBUG_OUT("onPlayerUseSpecial Type=~p",[Type]),
	case getAnswerSpecial(Type) > 0 of
		true->useAnswerSpecial(Type),player:send(#pk_U2GS_AnswerSpecialRet{ret=0});
		false->player:send(#pk_U2GS_AnswerSpecialRet{ret=1})
	end.

%% 通知玩家答题倒计时
sendAnswerReady(Time)->
	player:send(#pk_GS2U_AnswerReady{time=Time}),
	ok.

%% 发送题目信息给玩家
sendQuestion(QID,Num,Max,A,B,C,D,E1,E2)->
	Msg = #pk_GS2U_AnswerQuestion{id=QID,num=Num,maxnum=Max,core=getAnswerScore(),
                        special_double=getAnswerSpecial(?ANSWER_SPECIAL_DOUBLE),
                        special_right=getAnswerSpecial(?ANSWER_SPECIAL_RIGHT),
                        special_exclude=getAnswerSpecial(?ANSWER_SPECIAL_EXCLUDE),
                        a=A,b=B,c=C,d=D,e1=E1,e2=E2},
	player:send(Msg),
	?DEBUG_OUT("sendQuestion Msg:~p",[Msg]),
	ok.

%% 通知玩家答题倒计时
sendAnswerClose()->
	player:send(#pk_GS2U_AnswerClose{}),
	ok.

%% 获取当前题目序号
getQuestionNum()->
        PlayerVarArray = player:getCurPlayerProperty( #player.varArray ),
        Ret = variant:getPlayerVarValue(PlayerVarArray,?PlayerVariant_Index_14_Answer_Num),
        case Ret of
                undefined->0;
                _->Ret
        end.

%% 设置当前题目ID
setQuestionNum(Value)->
        variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index_14_Answer_Num,Value).

%% 获取当前答题状态
getAnswerState()->
        PlayerVarArray = player:getCurPlayerProperty( #player.varArray ),
        Ret = variant:getPlayerVarValue(PlayerVarArray,?PlayerVariant_Index_14_Answer_State),
        case Ret of
                undefined->0;
                _->Ret
        end.

%% 设置当前答题状态
setAnswerState(Value)->
        variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index_14_Answer_State,Value).

%% 获取当前答题得分
getAnswerScore()->
        PlayerVarArray = player:getCurPlayerProperty( #player.varArray ),
        Ret = variant:getPlayerVarValue(PlayerVarArray,?PlayerVariant_Index_14_Answer_Score),
        case Ret of
                undefined->0;
                _->Ret
        end.

%% 设置当前答题得分
setAnswerScore(Value)->
        variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index_14_Answer_Score,Value).

%% 获取当前答题特殊功能使用次数
getAnswerSpecial(?ANSWER_SPECIAL_DOUBLE)->
        PlayerVarArray = player:getCurPlayerProperty( #player.varArray ),
        Ret = variant:getPlayerVarValue(PlayerVarArray,?PlayerVariant_Index_14_Answer_Special_Double),
        case Ret of
                undefined->0;
                _->Ret
        end;
getAnswerSpecial(?ANSWER_SPECIAL_RIGHT)->
        PlayerVarArray = player:getCurPlayerProperty( #player.varArray ),
        Ret = variant:getPlayerVarValue(PlayerVarArray,?PlayerVariant_Index_14_Answer_Special_Right),
        case Ret of
                undefined->0;
                _->Ret
        end;
getAnswerSpecial(?ANSWER_SPECIAL_EXCLUDE)->
        PlayerVarArray = player:getCurPlayerProperty( #player.varArray ),
        Ret = variant:getPlayerVarValue(PlayerVarArray,?PlayerVariant_Index_14_Answer_Special_Exclude),
        case Ret of
                undefined->0;
                _->Ret
        end;
getAnswerSpecial(_)->
	0.

%% 设置当前答题得分
setAnswerSpecial(?ANSWER_SPECIAL_DOUBLE,Value)->
        variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index_14_Answer_Special_Double,Value);
setAnswerSpecial(?ANSWER_SPECIAL_RIGHT,Value)->
        variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index_14_Answer_Special_Right,Value);
setAnswerSpecial(?ANSWER_SPECIAL_EXCLUDE,Value)->
        variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index_14_Answer_Special_Exclude,Value);
setAnswerSpecial(_,_Value)->
	ok.

%% 使用特殊功能
useAnswerSpecial(?ANSWER_SPECIAL_DOUBLE)->
	?DEBUG_OUT("useAnswerSpecial double"),
	put("UseSpecialDouble",1),
	setAnswerSpecial(?ANSWER_SPECIAL_DOUBLE,getAnswerSpecial(?ANSWER_SPECIAL_DOUBLE)-1),
	ok;
useAnswerSpecial(?ANSWER_SPECIAL_RIGHT)->
	?DEBUG_OUT("useAnswerSpecial right"),
	put("UseSpecialRight",1),
	setAnswerSpecial(?ANSWER_SPECIAL_RIGHT,getAnswerSpecial(?ANSWER_SPECIAL_RIGHT)-1),
	ok;
useAnswerSpecial(?ANSWER_SPECIAL_EXCLUDE)->
	?DEBUG_OUT("useAnswerSpecial exclude"),
	put("UseSpecialExclude",1),
	setAnswerSpecial(?ANSWER_SPECIAL_EXCLUDE,getAnswerSpecial(?ANSWER_SPECIAL_EXCLUDE)-1),
	ok;
useAnswerSpecial(_)->
	ok.


