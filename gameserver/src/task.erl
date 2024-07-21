%% Description: TODO: Add description to task
-module(task).

%%
%% Include files
%%
-include("mysql.hrl").
-include("package.hrl").
-include("db.hrl").
-include("logdb.hrl").
-include("playerDefine.hrl").
-include("itemDefine.hrl").
-include("hdlt_logger.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("mapDefine.hrl").
-include("taskDefine.hrl").
-include("variant.hrl").
-include("daily.hrl").
-include("globalDefine.hrl").
-include("textDefine.hrl").
-include("active.hrl").


%%
%% Exported Functions
%%
%-export([]).
-compile(export_all).

%%
%% API Functions
%%

loadTaskBase( B ) ->
    put( "Count", 0),
	{TaskID,_} = common:binary_read_int16(get("Count"),B),
	put("Count", get("Count") + 2),
	{Npc1ID,_} = common:binary_read_int16(get("Count"),B),
	put("Count", get("Count") + 2),
	{_Npc1MapID,_} = common:binary_read_int16(get("Count"),B),
	put("Count", get("Count") + 2),
	{_Npc1PosX,_} = common:binary_read_int16(get("Count"),B),
	put("Count", get("Count") + 2),
	{_Npc1PosY,_} = common:binary_read_int16(get("Count"),B),
	put("Count", get("Count") + 2),
	{Npc2ID,_} = common:binary_read_int16(get("Count"),B),
	put("Count", get("Count") + 2),
	{_Npc2MapID,_} = common:binary_read_int16(get("Count"),B),
	put("Count", get("Count") + 2),
	{_Npc2PosX,_} = common:binary_read_int16(get("Count"),B),
	put("Count", get("Count") + 2),
	{_Npc2PosY,_} = common:binary_read_int16(get("Count"),B),
	put("Count", get("Count") + 2),
	{Type,_} = common:binary_read_int8(get("Count"),B),
	put("Count", get("Count") + 1),
	{PlayerClass,_} = common:binary_read_int16(get("Count"),B),
	put("Count", get("Count") + 2),
	
	%%{PlayerLvlStr,_LevelCount} = common:binary_read_string(get("Count"),B),
	%%PlayerLvSplit=string:tokens(PlayerLvlStr, "&"),
	%%case erlang:length(PlayerLvSplit) >=2 of
	%%	true->
	%%		PlayerLvl=lists:nth(1, PlayerLvSplit),
	%%		PlayerLvMax=lists:nth(2, PlayerLvSplit);
	%%	false->
	%%		PlayerLvl=0,
	%%		PlayerLvMax=0
	%%end,
	%%put("Count", get("Count") + _LevelCount),

	{PlayerLvl,_} = common:binary_read_int16(get("Count"),B),
	put("Count", get("Count") + 2),
	
	{PlayerLvMaxTmp,_} = common:binary_read_int16(get("Count"),B),
	case PlayerLvMaxTmp=:=0 of
		true->
			PlayerLvMax=10000;
		false->
			PlayerLvMax=PlayerLvMaxTmp
	end,
	put("Count", get("Count") + 2),
	
	{GuildLvl,_} = common:binary_read_int16(get("Count"),B),
	put("Count", get("Count") + 2),
	{Camp,_} = common:binary_read_int16(get("Count"),B),
	put("Count", get("Count") + 2),
	{PrevTask,_} = common:binary_read_int16(get("Count"),B),
	put("Count", get("Count") + 2),
	
 	{_Name,CountName} = common:binary_read_string(get("Count"),B),
	
	put("Count", get("Count") + CountName),
	{_Desc1,CountDesc1} = common:binary_read_string(get("Count"),B),
	put("Count", get("Count") + CountDesc1),
	{_Desc2,CountDesc2} = common:binary_read_string(get("Count"),B),
	put("Count", get("Count") + CountDesc2),
%% 	{MegaSecs,Secs,MicroSecs} =erlang:now(),
%%  	?DEBUG_OUT( "yaogang_now:~p,~p,~p", [MegaSecs,Secs,MicroSecs] ),
	{Aim, CountAim} = common:binary_read_array_head8(get("Count"),B, fun(X) -> readAim(X) end),
%% 	{MegaSecs1,Secs1,MicroSecs1} =erlang:now(),
%% 	?DEBUG_OUT( "yaogang_now1:~p,~p,~p", [MegaSecs1,Secs1,MicroSecs1] ),
	put("Count", get("Count") + CountAim),
	{Bonus, CountBonus} = common:binary_read_array_head8(get("Count"),B, fun(X) -> readBonus(X) end),
	put("Count", get("Count") + CountBonus),
	{_StoryDesc, CountStoryDesc} = common:binary_read_array_head16(get("Count"),B, fun(X) -> readStoryDesc(X) end),
	put("Count", get("Count") + CountStoryDesc),
	{_StoryDesc1, CountStoryDesc1} = common:binary_read_array_head16(get("Count"),B, fun(X) -> readStoryDesc(X) end),
	put("Count", get("Count") + CountStoryDesc1),
%% 	{IsAutoRun, Left,CountIsAutoRun} = common:binary_read_int16_left(get("Count"),B),
%% 	put("Count", get("Count") + CountIsAutoRun),
	{IsAutoRun,_} = common:binary_read_int16(get("Count"),B),
	put("Count", get("Count") + 2),
	%{_AnimIndex,Left, _CountAnimIndex} = common:binary_read_int16_left(get("Count"), B),
	{_AnimIndex,CountAnimIndex} = common:binary_read_string(get("Count"),B),
	put("Count", get("Count") + CountAnimIndex),	
	{_Conditions,CountConditions} = common:binary_read_string(get("Count"),B),
	put("Count", get("Count") + CountConditions),
	{_AimMapID,Left, _CountAimMapID} = common:binary_read_int16_left(get("Count"), B),
	
%% 	put("Count", get("Count") + 2),
%% 	{AimDestination, CountAimDestination,Left} = common:binary_read_array_head8_left(get("Count"),B, fun(X) -> readAimDestination(X) end),
	T = #taskBase{taskID = TaskID, npc1ID = Npc1ID, npc2ID = Npc2ID, type = Type, playerClass = PlayerClass,
				  playerLvl = PlayerLvl, playerLvMax=PlayerLvMax,guildLvl = GuildLvl, camp = Camp, prevTask = PrevTask, aim = Aim,
				  bonus = list_to_tuple(Bonus), isAutoRun = IsAutoRun},
	db:writeRecord( T ),
	{Left}.

readAim(B) ->
	<<Type:?INT16,Index:?INT16,Count:?INT,TargetID:?INT16,DropRate:?INT16,DropCount:?INT16,_S1:?INT16,_S2:?INT16,_S3:?INT16,_S4:?INT16,_S5:?INT16,B3/binary>> = B,
	{#taskAim{type=Type, index=Index, count=Count, targetID=TargetID, dropRate=DropRate, dropCount=DropCount }, B3,24}
	.

readBonus(B1) ->
	<<Index:?INT16,Count:?INT,B3/binary>> = B1,
	{{Index, Count}, B3,6}
	.

%% readAimDestination(B) ->
%% 	<<MapID:?WORD,PosX:?WORD,PosY:?WORD,B3/binary>> = B,
%% 	{{MapID, PosX, PosY}, B3,6}.

readStoryDesc(B) ->
	{StoryContent,Count1} = common:binary_read_string(0,B),
	{StoryContinue,Count2} = common:binary_read_string(Count1,B),
	{_,B2} = split_binary(B,Count1+Count2),
	{{StoryContent, StoryContinue}, B2,Count1+Count2}.


loadTaskBaseAll(<<>>) ->
	ok;
loadTaskBaseAll( Bin ) ->
	{Bin1} = loadTaskBase(Bin),
	loadTaskBaseAll(Bin1).

%%
%% Local Functions
%%

%%加载任务配置表
taskBaseLoad()->
	case db:openBinRawData( "task.bin" ) of
		<<>>->
			?ERROR_OUT("taskBaseLoad openBinData task.bin false []");
		TaskData ->
			loadTaskBaseAll(TaskData),

			ets:new( ?TaskBaseTableAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #taskBase.taskID }] ),
			TaskBaseList = db:matchObject(taskBase, #taskBase{_='_'}),
			MyFun = fun(Record) ->
							etsBaseFunc:insertRecord(?TaskBaseTableAtom, Record)
					end,
			lists:map(MyFun, TaskBaseList),
			%db:changeFiled(globalMain, ?GlobalMainID, #globalMain.taskBaseTable, TaskBaseTable),
			?DEBUG_OUT("taskBaseLoad success")
	end.

%%玩家任务索引
%% getPlayerTaskIndex()->
%% 	map:makeObjectID( ?Object_Type_Task,db:memKeyIndex(playertask_gamedata) ).% persistent

%%返回任务记录
getTaskBaseByID(ID) ->
	etsBaseFunc:readRecord( main:getGlobalTaskBaseTable(), ID).

%%返回任务ID是否有效
isValidTaskID( TaskID )->
	case getTaskBaseByID( TaskID ) of
		{}->
			false;
		_ ->
			true
	end.

%%------------------------------------------------playerTaskDB------------------------------------------------
%%返回当前进程的任务表
getCurTaskTable()->
	TaskTable = get( "TaskTable" ),
	case TaskTable of
		undefined->0;
		_->TaskTable
	end.

%%获得随机任务配置表格
getCurrentRandDailyTable()->
	RandDailyTable = get( "RandomDailyTable" ),
	case RandDailyTable of
		undefined->0;
		_->RandDailyTable
	end.

%%返回当前进程已完成任务的ID列表
getCompletedTaskIDList()->
	CompletedTaskIDList = get( "CompletedTaskIDList" ),
	case CompletedTaskIDList of
		undefined->[];
		_->CompletedTaskIDList
	end.

%%返回玩家是否已接这个任务
isAcceptedTask(ID)->
	case etsBaseFunc:readRecord( getCurTaskTable(), ID ) of
		{}->false;
		_->true
	end.


%%通过任务ID来获取一条玩家任务记录
getPlayerTaskByID(ID)->
	etsBaseFunc:readRecord( getCurTaskTable(), ID ).

%%返回是否已完成任务
isCompletedTask(ID)->
	put( "isCompleteTask_return", false ),
	try
		MyFunc = fun( Record )->
						 case Record =:= ID of
							 true->put( "isCompleteTask_return", true ),throw(-1);
							 false->ok
						 end
				 end,
		lists:foreach( MyFunc, getCompletedTaskIDList() ),
		false
	catch
		_->get("isCompleteTask_return")
	end.

%%专门用于护送任务
giveUp_Convory_Task_Of_Online( _TaskID )->
	try
		QuestBase = etsBaseFunc:readRecord( main:getGlobalTaskBaseTable(), _TaskID ),
		case QuestBase of
			{}->
				?DEBUG_OUT( "on_U2GS_GiveUpTaskRequest QuestBase[~p] = {}", [_TaskID] ),
				throw(-1);
			_->ok
		end,
		
		dealTaskItemDelete(QuestBase),
		
		WillDeleteTask = etsBaseFunc:readRecord( getCurTaskTable(), _TaskID ),
		case WillDeleteTask of
			{}->
				?DEBUG_OUT( "on_U2GS_GiveUpTaskRequest QuestBase[~p] = {}", [_TaskID] );
			_->
				etsBaseFunc:deleteRecord( getCurTaskTable(), _TaskID ),
				%dbProcess_PID ! { deleteRecord, playerTask, _TaskID},
				mySqlProcess:deleteRecordByTableNameAndId("playertask_gamedata",WillDeleteTask#playerTask.id),
		
				
				player:send( #pk_GS2U_GiveUpTaskResult{nQuestID=_TaskID, nResult=0} ),
				
				%task:savePlayerTask(),
				
				?DEBUG_OUT( "player[~p] giveup task[~p]", [player:getPlayerShortLog(player:getCurPlayerID()), _TaskID] ),
				
				Player=player:getCurPlayerRecord(),
				PlayerID = Player#player.id,
				UserID = Player#player.userId,
				Level = Player#player.level,
				%% 写放弃任务日志
				logdbProcess:write_log_player_task(?LOG_PLAYER_TASK_CANCEL,UserID,PlayerID,_TaskID,Level)
				
%% 				ParamTuple = #task_param{	playeraction = 2,
%% 											tasktype = QuestBase#taskBase.type,
%% 											taskid = _TaskID},
%% 				logdbProcess:write_log_player_event(?EVENT_PLAYER_TASK, ParamTuple, Player)
		end,
		
		ok
	catch
		_->ok
	end.


%%玩家上线任务初始化
onPlayerOnlineLoadTaskData( DBInitData )->
	{ AcceptedTaskList, PlayerCompletedTask } = DBInitData,
	
	TaskTable = getCurTaskTable(),
	MyFunc = fun( Record )->
				etsBaseFunc:insertRecord(TaskTable, Record)	 
			 end,
	lists:foreach( MyFunc, AcceptedTaskList ),
	
	case PlayerCompletedTask of
		[]->
			PlayerCompletedTaskIDList = [];
		_->
			[CompletedTask|_] = PlayerCompletedTask,
			PlayerCompletedTaskIDList = CompletedTask#playerCompletedTask.taskIDList
	end,
	
	put( "CompletedTaskIDList", PlayerCompletedTaskIDList ),
	
	sendAcceptedTaskListToPlayer(),
	sendCompletedTaskIDListToPlayer().

%%发送已接收任务信息给玩家
sendAcceptedTaskListToPlayer() ->
	put( "sendAcceptedTaskListToPlayer_AcceptTask", [] ),
	
 	MyFunc1 = fun( Record )->
					  #pk_TaskProgess{nCurCount=Record#aimProgress.curCount}
			  end,
	
	MyFunc2 = fun( Record )->
					 AcceptTask = #pk_AcceptTask{nTaskID=Record#playerTask.taskID, list_progress=lists:map(MyFunc1, Record#playerTask.aimProgressList)},
					 put( "sendAcceptedTaskListToPlayer_AcceptTask", get( "sendAcceptedTaskListToPlayer_AcceptTask" )++[AcceptTask] )
			 end,
	etsBaseFunc:etsFor( getCurTaskTable(), MyFunc2 ),
	player:send( #pk_GS2U_AcceptedTaskList{list_accepted=get( "sendAcceptedTaskListToPlayer_AcceptTask" )} ).

%%发送已完成任务信息给玩家
sendCompletedTaskIDListToPlayer()->
	player:send( #pk_GS2U_CompletedTaskIDList{ list_completed_id=getCompletedTaskIDList() } ).

%%测试更新任务条件
updateTaskProgress( Type, Index, Value )->
	MyFunc = fun( Record )->
		put( "updateTaskProgress", {} ),
		MyFunc2 = fun( Progress )->
				   case ( Progress#aimProgress.type =:= Type ) andalso 
						( Progress#aimProgress.index =:= Index ) andalso
						( Progress#aimProgress.maxCount > Progress#aimProgress.curCount ) of
					    	true->
							   NewProgress = setelement( #aimProgress.curCount, Progress, Progress#aimProgress.curCount + Value ),
							   put( "updateTaskProgress", NewProgress ),
							   ok;
							false->ok
					   end
			   end,
		lists:foreach( MyFunc2, Record#playerTask.aimProgressList ),
		case get( "updateTaskProgress" ) of
			{}->ok;
			NewProgress2 ->
				MyFunc3 = fun( Progress2 )->
								  case ( Progress2#aimProgress.type =:= NewProgress2#aimProgress.type ) andalso
									   ( Progress2#aimProgress.index =:= NewProgress2#aimProgress.index ) of
									  true->NewProgress2;
									  false->Progress2
								  end
						  end,
				NewList = lists:map(MyFunc3, Record#playerTask.aimProgressList ),
				etsBaseFunc:changeFiled( getCurTaskTable(), Record#playerTask.taskID, #playerTask.aimProgressList, NewList ),
				
				%%通知客户端
				MyFunc4 = fun( Progress3 )->
								  #pk_TaskProgess{nCurCount=Progress3#aimProgress.curCount}
						  end,
				MsgList = lists:map( MyFunc4, NewList ),
				player:send( #pk_GS2U_PlayerTaskProgressChanged{nQuestID=Record#playerTask.taskID,
																list_progress=MsgList} ),
				ok
		end
	end,
	etsBaseFunc:etsFor( getCurTaskTable(), MyFunc ).
%%购买物品任务目标变化
updateBuyItemTaskProcess(ItemID,ItemNum)->
	?DEBUG_OUT( "updateBuyItemTaskProcess[~p] ~p", [ItemID,ItemNum] ),
	updateTaskProgress(?TASKTYPE_BUYITEM,ItemID,ItemNum).
%%MyFun = fun(Record)->
%%					MyFunForAim = fun(Aim)->
%%										  case Aim#taskAim.type =:=?TASKTYPE_BUYITEM of
%%											  false->
%%												  ok;
%%											  true->
%%												  case Aim#taskAim.index =:= ItemID of
%%													  true->
%%														  %%根据背包中物品数量修改进度
%%															%%Count = playerItems:getItemCountByItemData(ItemID, true)
%%														  	%%			+ playerItems:getItemCountByItemData( ItemID, true),
%%															Count=ItemNum,
%%															updateTaskProgress(?TASKTYPE_BUYITEM,ItemID,Count);
%%													  false->
%%														  ok
%%												  end
%%										 end
%%								  end,
%%					lists:map(MyFunForAim, Record#playerTask.taskBase#taskBase.aim)
%%			end,
%%	etsBaseFunc:etsFor(getCurTaskTable(), MyFun).



%%处理杀怪掉落任务品
updateTaskGatherGoods( DataID )->
	MyFun = fun(Record)->
					MyFunForAim = fun(Aim)->
										  case Aim#taskAim.targetID =:= DataID of
											  true->
												  case random:uniform(100) < Aim#taskAim.dropRate of
													  true->
															Count = playerItems:getItemCountByItemData(?Item_Location_Bag, Aim#taskAim.index, true)
												  				+ playerItems:getItemCountByItemData( ?Item_Location_TempBag, Aim#taskAim.index, true),
															case Count >= Aim#taskAim.count of
																true->
																	ok;
																false->
																	playerItems:addItemToPlayerByItemDataID(Aim#taskAim.index, Aim#taskAim.dropCount, true, ?Get_Item_Reson_Task)
															end; 
													  false->
														  ok
												  end,
												  Msg = #pk_GS2U_NoteTask{nTaskID=Record#playerTask.taskID},
												  player:send(Msg);
											  false->
												  ok
										  end
								  end,
					lists:map(MyFunForAim, Record#playerTask.taskBase#taskBase.aim)
			end,
	etsBaseFunc:etsFor(getCurTaskTable(), MyFun).
		
%%玩家任务存盘
%savePlayerTask()->
%	Rule = ets:fun2ms(fun(#playerTask{} = Record)->Record end),
%	AcceptedTaskList = ets:select(getCurTaskTable(), Rule),
%	CompletedTaskIDList = getCompletedTaskIDList(),
	%dbProcess_PID ! { playerSaveTask, player:getCurPlayerID(), AcceptedTaskList, CompletedTaskIDList }.
%	dbProcess:on_playerSaveTask(player:getCurPlayerID(), AcceptedTaskList, CompletedTaskIDList).

%%返回玩家存盘数据
getSavePlayerTaskDataList()->
	Rule = ets:fun2ms(fun(#playerTask{} = Record)->Record end),
	AcceptedTaskList = ets:select(getCurTaskTable(), Rule),
	CompletedTaskIDList = getCompletedTaskIDList(),
	
	%RuleRandomDaily=ets:fun2ms(fun(#randomDailyRecord{} = Record)->Record end),
	%RandomDailyList=ets:select(getCurrentRandDailyTable(), RuleRandomDaily),
	{AcceptedTaskList, CompletedTaskIDList}.

%%角色创建时玩家自动接任务，DB进程
onCreatePlayerToAcceptTask( #player{}=Player )->
	case Player#player.faction of
		?CAMP_TIANJI->
			QuestID = 100,
			ok;
		?CAMP_XUANZONG->
			QuestID = 1,
			ok;
		_->
			QuestID = 1,
			ok
	end,

	TaskBase = etsBaseFunc:readRecord( main:getGlobalTaskBaseTable(), QuestID ),
	MyFunc = fun( Record )->
					 #aimProgress{type=Record#taskAim.type, 
								  index=Record#taskAim.index, 
								  maxCount=Record#taskAim.count, 
								  curCount=0 }
			 end,

	AimProgressList = lists:map( MyFunc, TaskBase#taskBase.aim ),

	TaskDBData = #playerTask{ 	  id = db:memKeyIndex(playertask_gamedata),
							 	  taskID=QuestID,
								  playerID=Player#player.id,
								  taskBase = TaskBase,
								  state = ?TASKSTATE_UNDO,
								  aimProgressList = AimProgressList },
	dbProcess:on_playerSaveTask( Player#player.id, [TaskDBData], [] ).

%%------------------------------------------------playerTaskMsg------------------------------------------------
%%玩家能否接受某任务
canAcceptQuest( #player{}=Player, #taskBase{}=TaseBase )->
	put( "canAcceptQuest_return", false ),
	try	
		%%玩家职业检测，待加
		%%。。。。魏进龙
		
		case TaseBase#taskBase.playerLvl > 0 of
			true->
				case TaseBase#taskBase.playerLvl > Player#player.level of
					true->throw(-1);
					false->ok
				end;
			false->ok
		end,
		%%附带最大等级检测
		case TaseBase#taskBase.playerLvMax> 0 of
			true->
				case TaseBase#taskBase.playerLvMax < Player#player.level of
					true->throw(-1);
					false->ok
				end;
			false->ok
		end,
		
		%%工会等级检测
%% 		case TaseBase#taskBase.guildLvl > 0 of
%% 			true->
%% 				case TaseBase#taskBase.playerLvl > Player#mapPlayer.level of
%% 					true->throw(-1);
%% 					false->ok
%% 				end;
%% 			false->ok
%% 		end,

		%%阵营检测
		case TaseBase#taskBase.camp > 0 of
			true->
				case TaseBase#taskBase.camp =:= Player#player.faction of
					true->ok;
					false->throw(-1)
				end;
			false->ok
		end,
		
		%%前置任务检测
		%%茶馆任务前置任务是循环任务，蛋疼
		case isRandomDaily( TaseBase#taskBase.taskID ) of
			true->
				ok;
			false->
				case TaseBase#taskBase.prevTask > 0 of
					true->
						case isCompletedTask(TaseBase#taskBase.prevTask) of
							true->ok;
							false->throw(-1)
						end;
					false->ok
				end
		end,

		%%已经接受了该任务
		case isAcceptedTask( TaseBase#taskBase.taskID ) of
			true->throw(-1);
			false->ok
		end,
		
		%%已接任务数量检测
		case ets:info( getCurTaskTable(), size ) >= ?Max_Player_Accepte_Task of
			true->throw(-1);
			false->ok
		end,
		
		
		case canGatherAccept(TaseBase#taskBase.taskID,Player#player.level) of
			false-> 
				throw(-1);
			_->
				ok
		end,
		case canAccReputationTask(TaseBase#taskBase.taskID) of
			false-> 
				throw(-1);
			_->
				ok
		end,
		case randomDailyCheck(TaseBase#taskBase.taskID,Player#player.level) of
			false->
				throw(-1);
			_->
				ok
		end,
		
		%%判断是否已完成过该任务，或可以重复做
		case isCompletedTask( TaseBase#taskBase.taskID ) of
			true->
				%%?这里如果判断如果是重复型任务，是可以接的
				%%wjl，看到请加加加加加加加加加加加加加加加加加加加加加加加
				case TaseBase#taskBase.type =:= ?TASK_LOOP of
					true->
						ok;
					false->
						throw(-1)
				end;
			false->ok
		end,

		true
	catch
		_->get( "canAcceptQuest_return" )
	end.

%%玩家能否归还某任务
canCompleteTask( TaskBase, TalkingNpcCfg )->
	put( "canCompleteTask", false ),
	try
		%%已经接受了该任务
		PlayerTask = etsBaseFunc:readRecord( getCurTaskTable(), TaskBase#taskBase.taskID ),
		case PlayerTask of
			{}->throw(-1);
			_->ok
		end,
		
		MyFunc = fun( Record )->
					case (Record#aimProgress.type =:= ?TASKTYPE_COLLECT) or (Record#aimProgress.type =:= ?TASKTYPE_ITEM) of
						true->
							ItemCount = playerItems:getItemCountByItemData( ?Item_Location_Bag, Record#aimProgress.index, true)
								+ playerItems:getItemCountByItemData( ?Item_Location_TempBag, Record#aimProgress.index, true),
							case ItemCount >= Record#aimProgress.maxCount of
								true->
									ok;
								false->
									throw(-1)
							end;
						false->
							case (Record#aimProgress.type =:= ?TASKTYPE_PRMRY_ESCORT) or (Record#aimProgress.type =:= ?TASKTYPE_ADVN_ESCORT) of %% 护送任务
								true ->
									case convoy:canCompleteConvoyTask() of
										true ->
											ok;
										false ->
											throw(-1)
									end;
								false ->
									 case Record#aimProgress.curCount >= Record#aimProgress.maxCount of
										 true->
											 %%如果是Npc对话任务，要检测TalkingNpcCfg是否是正在对话的Npc
											 case Record#aimProgress.type =:= ?TASKTYPE_TALK of
												 true->
													 case TalkingNpcCfg of
														 {}->throw(-1);
														 _->
															 ok
																%%case Record#aimProgress.index =:= TalkingNpcCfg#npcCfg.npcID of临时
																%%true->ok;
																%%false->throw(-1)
																%%end
													 end,
													 ok;
												 false->ok
											 end,
			
											 ok;
										 false->throw(-1)
									 end
							end
					end
				 end,
		lists:foreach( MyFunc, PlayerTask#playerTask.aimProgressList ),
		
		true
	catch
		_->get( "canCompleteTask" )
	end.


%%玩家接受任务请求
on_U2GS_AcceptTaskRequest( #pk_U2GS_AcceptTaskRequest{nQuestID=QuestID}=Msg )->
	try
		QuestBase = etsBaseFunc:readRecord( main:getGlobalTaskBaseTable(), QuestID ),
		case QuestBase of
			{}->
				?DEBUG_OUT( "on_U2GS_AcceptTaskRequest QuestBase[~p] = {}", [QuestID] ),
				throw(-1);
			_->ok
		end,
		
		case canAcceptQuest( player:getCurPlayerRecord(), QuestBase ) of
			true->ok;
			false->throw(-1)
		end,
		
		player:sendMsgToMap( {playerMsg_U2GS_AcceptTaskRequest, self(), player:getCurPlayerID(), Msg} ),
		ok
	catch
		_->ok
	end.

%%玩家归还任务
on_U2GS_CompleteTaskRequest( #pk_U2GS_CompleteTaskRequest{}=Msg, TalkingNpcCfg )->
	try
		QuestID = Msg#pk_U2GS_CompleteTaskRequest.nQuestID,
		QuestBase = etsBaseFunc:readRecord( main:getGlobalTaskBaseTable(), QuestID ),
		case QuestBase of
			{}->
				?LOG_OUT( "on_U2GS_CompleteTaskRequest QuestBase[~p] = {}", [QuestID] ),
				throw(-1);
			_->ok
		end,
		
		case ( TalkingNpcCfg =:= {} ) andalso ( Msg#pk_U2GS_CompleteTaskRequest.nNpcActorID > 0 ) of
			true->player:sendMsgToMap( {playerMsg_U2GS_CompleteTaskRequest, self(), player:getCurPlayerID(), Msg} ), throw(-1);
			false->ok
		end,
		
		case canCompleteTask( QuestBase, TalkingNpcCfg ) of
			true->ok;
			false->throw(-1)
		end,
		
		SpaceCellCount = playerItems:getPlayerBagSpaceCellCount(),
		case SpaceCellCount < 2 of
			true->
				player:send( #pk_GS2U_CompleteTaskResult{nQuestID=Msg#pk_U2GS_CompleteTaskRequest.nQuestID, nResult=?Commit_FullBag} ),
				throw(-1);
			false->
				ok
		end,
		
		PlayerTask = etsBaseFunc:readRecord(getCurTaskTable(), QuestID),
		etsBaseFunc:deleteRecord( getCurTaskTable(), QuestID ),
		mySqlProcess:deleteRecordByTableNameAndId("playertask_gamedata",PlayerTask#playerTask.id),
		
		case isCompletedTask( QuestID ) of
			true->ok;
			false->
				case QuestBase#taskBase.type =:= ?TASK_LOOP of
					true->%%如果是循环任务，则不放入已完成列表中
						ok;
					false->
						CompletedQuestIDList = getCompletedTaskIDList(),
						case CompletedQuestIDList of
							[]->put( "CompletedTaskIDList", [QuestID] );
							_->put( "CompletedTaskIDList", CompletedQuestIDList++[QuestID] )
						end
				end
		end,

		%% 护送任务奖励
		case QuestBase#taskBase.aim of
			[FirstAim|_]->
				case (FirstAim#taskAim.type =:= ?TASKTYPE_PRMRY_ESCORT) or (FirstAim#taskAim.type =:= ?TASKTYPE_ADVN_ESCORT) of %% 护送任务
					true ->
						convoy:finish_Convoy(QuestID);
					false->
						ok
				end;
			_->ok
		end,
		
		Player=player:getCurPlayerRecord(),
		PlayerID = Player#player.id,
		UserID = Player#player.userId,
		Level = Player#player.level,

		updateRandomProcessWhenSubmit(QuestID,Player#player.level),

		player:send( #pk_GS2U_CompleteTaskResult{nQuestID=QuestID, nResult=?Commit_Success} ),
		dealTaskItemDeleteAll(QuestBase),
		
		

		
		%%如果是采集任务或者茶馆任务，走采集任务奖励，否则走老的奖励
		AwardGaved= gaveTeaHouseExp(QuestID,Level) orelse requestgaveGatherExp(QuestID,Level,PlayerID) orelse gaveReputationAward(QuestID,Level),

		case AwardGaved of
			true->
				ok;
			false->
				dealTaskBonus(QuestBase)
		end,
		%%
		%%case requestgaveGatherExp(QuestID,Level,PlayerID) of
		%%	false->
		%%		dealTaskBonus(QuestBase);
		%%	true->
		%%		ok
		%%end,
		%%dealTaskBonus(QuestBase),
		
		%task:savePlayerTask(),

		%%日常检测
		daily:onDailyFinishCheck(?DailyType_Task, QuestID),
		
		%%声望任务检测
		onReputationTaskFinish(QuestID,Level),

		?DEBUG_OUT( "player[~p] completed task[~p]", [player:getPlayerShortLog(player:getCurPlayerID()), QuestID] ),
		
		%% 写完成任务日志
		logdbProcess:write_log_player_task(?LOG_PLAYER_TASK_COMMIT,UserID,PlayerID,QuestID,Level),
		
%% 		ParamTuple = #task_param{	playeraction = 1,
%% 									tasktype = QuestBase#taskBase.type,
%% 									taskid = QuestID},
%% 		logdbProcess:write_log_player_event(?EVENT_PLAYER_TASK, ParamTuple, Player),
		ok
	catch
		_->
			ok
	end.

%%玩家放弃任务
on_U2GS_GiveUpTaskRequest( #pk_U2GS_GiveUpTaskRequest{nQuestID=QuestID} = _Msg )->
	try
		QuestBase = etsBaseFunc:readRecord( main:getGlobalTaskBaseTable(), QuestID ),
		case QuestBase of
			{}->
				?LOG_OUT( "on_U2GS_GiveUpTaskRequest QuestBase[~p] = {}", [QuestID] ),
				throw(-1);
			_->ok
		end,

		%%声望任务（仙盟任务）不可以放弃 add by yueliangyou [2013-04-26]
		case isReputationTask(QuestID) of
			true->throw(-1);
			false->ok
		end,
		
		%%已经接受了该任务
		case isAcceptedTask( QuestBase#taskBase.taskID ) of
			true->ok;
			false->throw(-1)
		end,
		
		dealTaskItemDelete(QuestBase),
		
		WillDeleteTask = etsBaseFunc:readRecord( getCurTaskTable(), QuestID ),
		etsBaseFunc:deleteRecord( getCurTaskTable(), QuestID ),
		%dbProcess_PID ! { deleteRecord, playerTask, QuestID},
		mySqlProcess:deleteRecordByTableNameAndId("playertask_gamedata",WillDeleteTask#playerTask.id),

		%% 放弃护送任务
		case QuestBase#taskBase.aim of
			[FirstAim|_]->
				case (FirstAim#taskAim.type =:= ?TASKTYPE_PRMRY_ESCORT) or (FirstAim#taskAim.type =:= ?TASKTYPE_ADVN_ESCORT) of %% 护送任务
					true ->
						convoy:giveUp_Convoy_Task();
					false->
						ok
				end;
			_->ok
		end,
		
		player:send( #pk_GS2U_GiveUpTaskResult{nQuestID=QuestID, nResult=0} ),
		
		%task:savePlayerTask(),
		
		?DEBUG_OUT( "player[~p] giveup task[~p]", [player:getPlayerShortLog(player:getCurPlayerID()), QuestID] ),
		
		Player=player:getCurPlayerRecord(),
		PlayerID = Player#player.id,
		UserID = Player#player.userId,
		Level = Player#player.level,
		%% 写放弃任务日志
		logdbProcess:write_log_player_task(?LOG_PLAYER_TASK_CANCEL,UserID,PlayerID,QuestID,Level),
		
%% 		ParamTuple = #task_param{	playeraction = 2,
%% 									tasktype = QuestBase#taskBase.type,
%% 									taskid = QuestID},
%% 		logdbProcess:write_log_player_event(?EVENT_PLAYER_TASK, ParamTuple, Player),
		
		ok
	catch
		_->ok
	end.


%%玩家对话Npc
on_U2GS_TalkToNpc( #pk_U2GS_TalkToNpc{}=Msg )->
	player:sendMsgToMap( {playerMsg_U2GS_TalkToNpc, player:getCurPlayerID(), Msg } ).

%%玩家采集
on_U2GS_CollectRequest( #pk_U2GS_CollectRequest{}=Msg )->
	player:sendMsgToMap( {playerMsg_U2GS_CollectRequest, player:getCurPlayerID(), Msg } ).

%%------------------------------------------------地图进程------------------------------------------------
%%玩家接受任务请求
on_playerMsg_U2GS_AcceptTaskRequest( FromePID, PlayerID, #pk_U2GS_AcceptTaskRequest{nQuestID=QuestID, nNpcActorID=NpcActorID}=Msg )->
	try
		QuestBase = etsBaseFunc:readRecord( main:getGlobalTaskBaseTable(), QuestID ),
		case QuestBase of
			{}->
				?LOG_OUT( "on_playerMsg_U2GS_AcceptTaskRequest[~p] = {}", [QuestID] ),
				throw({return});
			_->ok
		end,
		
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->
				?LOG_OUT( "on_playerMsg_U2GS_AcceptTaskRequest PlayerID[~p] = {}", [PlayerID] ),
				throw({return});
			_->ok				
		end,

		%% 如果是声望任务（仙盟任务），不需要检查NPC，面板直接接 add by yueliangyou [2013-04-26]
		case isReputationTask(QuestID) of
			true->throw({guildTask});
			false->ok
		end,
		
		Npc = etsBaseFunc:readRecord( map:getMapNpcTable(), NpcActorID ),
		case Npc of
			{}->
				?LOG_OUT( "on_playerMsg_U2GS_AcceptTaskRequest NpcActorID[~p] = {}", [NpcActorID] ),
				throw({return});
			_->ok
		end,
		
		case QuestBase#taskBase.npc1ID =:= Npc#mapNpc.npc_data_id of
			true->ok;
			false->
				?LOG_OUT( "on_playerMsg_U2GS_AcceptTaskRequest task npc[~p] = npc_data_id[~p] false", [QuestBase#taskBase.npc1ID, Npc#mapNpc.npc_data_id] ),
				throw({return})
		end,
		
		DistSQ = monster:getDistSQFromTo( Player#mapPlayer.pos#posInfo.x,
											Player#mapPlayer.pos#posInfo.y,
											Npc#mapNpc.x,
											Npc#mapNpc.y
											),
		case DistSQ > ?TalkToNpc_Distance_SQ of
			true->
				?LOG_OUT( "on_playerMsg_U2GS_AcceptTaskRequest DistSQ[~p] false", [DistSQ] ),
				throw({return});
			false->ok
		end,

		%%状态不允许
		NotAcceptState = ( ?Actor_State_Flag_Dead bor ?Player_State_Flag_ChangingMap ),
		case mapActorStateFlag:isStateFlag(Player#mapPlayer.id, NotAcceptState) of
			true->
				throw({return});
			false->ok
		end,
		
		FromePID ! { mapMsg_U2GS_AcceptTaskRequest, Msg, true },
		objectEvent:onEvent( map:getMapObjectByID(NpcActorID), ?Npc_Event_GetedTask, 0),
		ok
	catch
		{guildTask}->
			FromePID ! { mapMsg_U2GS_AcceptTaskRequest, Msg, true };
		
		{return}->
			FromePID ! { mapMsg_U2GS_AcceptTaskRequest, Msg, false }
	end.

%%玩家对话Npc
on_playerMsg_U2GS_TalkToNpc( PlayerID, #pk_U2GS_TalkToNpc{}=Msg )->
	try
		
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->
				?DEBUG_OUT( "on_playerMsg_U2GS_TalkToNpc PlayerID[~p] = {}", [PlayerID] ),
				throw(-1);
			_->ok				
		end,
		
		Npc = etsBaseFunc:readRecord( map:getMapNpcTable(), Msg#pk_U2GS_TalkToNpc.nNpcActorID ),
		case Npc of
			{}->
				?DEBUG_OUT( "on_playerMsg_U2GS_TalkToNpc NpcActorID[~p] = {}", [Msg#pk_U2GS_TalkToNpc.nNpcActorID] ),
				throw(-1);
			_->ok
		end,
		
		DistSQ = monster:getDistSQFromTo( Player#mapPlayer.pos#posInfo.x,
											Player#mapPlayer.pos#posInfo.y,
											Npc#mapNpc.x,
											Npc#mapNpc.y
											),
		case DistSQ > ?TalkToNpc_Distance_SQ of
			true->
				?DEBUG_OUT( "on_playerMsg_U2GS_TalkToNpc DistSQ[~p] false", [DistSQ] ),
				throw(-1);
			false->ok
		end,

		%%状态不允许
		NotAcceptState = ( ?Actor_State_Flag_Dead bor ?Player_State_Flag_ChangingMap ),
		case mapActorStateFlag:isStateFlag(Player#mapPlayer.id, NotAcceptState) of
			true->throw(-1);
			false->ok
		end,
		
		NpcCfg = etsBaseFunc:readRecord( main:getGlobalNpcCfgTable(), Npc#mapNpc.npc_data_id ),
		case NpcCfg of
			{}->throw(-1);
			_->ok
		end,
		objectEvent:onEvent( Npc, ?Npc_Event_Talk, Msg),
		Player#mapPlayer.pid ! { mapMsg_U2GS_TalkToNpc, NpcCfg, true },
		
		ok
	catch
		_->ok
	end.

%%玩家采集
on_playerMsg_U2GS_CollectRequest( PlayerID, #pk_U2GS_CollectRequest{nObjectActorID=ObjectActorID}=Msg )->
	try
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->
				?LOG_OUT( "on_playerMsg_U2GS_CollectRequest PlayerID[~p] = {}", [PlayerID] ),
				throw(-1);
			_->ok				
		end,
		
		Object = etsBaseFunc:readRecord( map:getObjectTable(), ObjectActorID ),
		case Object of
			{}->
				?LOG_OUT( "on_playerMsg_U2GS_TalkToNpc ObjectActorID[~p] = {}", [ObjectActorID] ),
				throw(-1);
			_->ok
		end,
		
		DistSQ = monster:getDistSQFromTo( Player#mapPlayer.pos#posInfo.x,
											Player#mapPlayer.pos#posInfo.y,
											Object#mapObjectActor.x,
											Object#mapObjectActor.y
											),
		case DistSQ > ?TalkToNpc_Distance_SQ of
			true->
				?DEBUG_OUT( "on_playerMsg_U2GS_CollectRequest DistSQ[~p] false", [DistSQ] ),
				throw(-1);
			false->ok
		end,
		
		%%状态不允许
		NotAcceptState = ( ?Actor_State_Flag_Dead bor ?Player_State_Flag_ChangingMap ),
		case mapActorStateFlag:isStateFlag(Player#mapPlayer.id, NotAcceptState) of
			true->throw(-1);
			false->ok
		end,
		
		case objectActor:canBeenCollect(Player, Object) of
			true->ok;
			false->throw(-1)
		end,

		ObjectCfg = etsBaseFunc:readRecord( main:getGlobalObjectCfgTable(), Object#mapObjectActor.object_data_id ),
		case ObjectCfg of
			{}->throw(-1);
			_->ok
		end,
		
		objectActor:onCollected( Object,PlayerID ),
		
		Player#mapPlayer.pid ! { mapMsg_U2GS_CollectRequest, ObjectCfg, Msg#pk_U2GS_CollectRequest.nTaskID },
		
		ok
	catch
		_->ok
	end.

%%玩家归还任务
on_playerMsg_U2GS_CompleteTaskRequest(FromPID, PlayerID, #pk_U2GS_CompleteTaskRequest{}=Msg )->
	try
		Player = etsBaseFunc:readRecord( map:getMapPlayerTable(), PlayerID ),
		case Player of
			{}->
				?DEBUG_OUT( "on_playerMsg_U2GS_CompleteTaskRequest PlayerID[~p] = {}", [PlayerID] ),
				throw({return});
			_->ok				
		end,
		
		Npc = etsBaseFunc:readRecord( map:getMapNpcTable(), Msg#pk_U2GS_CompleteTaskRequest.nNpcActorID ),
		case Npc of
			{}->
				?DEBUG_OUT( "on_playerMsg_U2GS_CompleteTaskRequest NpcActorID[~p] = {}", [Msg#pk_U2GS_CompleteTaskRequest.nNpcActorID] ),
				throw({return});
			_->ok
		end,
		
		DistSQ = monster:getDistSQFromTo( Player#mapPlayer.pos#posInfo.x,
											Player#mapPlayer.pos#posInfo.y,
											Npc#mapNpc.x,
											Npc#mapNpc.y
											),
		case DistSQ > ?TalkToNpc_Distance_SQ of
			true->
				?DEBUG_OUT( "on_playerMsg_U2GS_CompleteTaskRequest DistSQ[~p] false", [DistSQ] ),
				throw({return});
			false->ok
		end,

		%%状态不允许
		NotAcceptState = ( ?Actor_State_Flag_Dead bor ?Player_State_Flag_ChangingMap ),
		case mapActorStateFlag:isStateFlag(Player#mapPlayer.id, NotAcceptState) of
			true->
				throw({return});
			false->ok
		end,
		
		NpcCfg = etsBaseFunc:readRecord( main:getGlobalNpcCfgTable(), Npc#mapNpc.npc_data_id ),
		case NpcCfg of
			{}->
				throw({return});
			_->ok
		end,
		
		FromPID ! { mapMsg_U2GS_CompleteTaskRequest, Msg, NpcCfg, true },
		objectEvent:onEvent( map:getMapObjectByID(Msg#pk_U2GS_CompleteTaskRequest.nNpcActorID), ?Npc_Event_GiveBackTask, 0),
		ok
	catch
		{return}->FromPID ! { mapMsg_U2GS_CompleteTaskRequest, Msg, {}, false }
	end.

on_mapMsg_KillMonster( MonsterDataID )->
	updateTaskGatherGoods(MonsterDataID),
	task:updateTaskProgress( ?TASKTYPE_MONSTER, MonsterDataID, 1 ).

%%------------------------------------------------玩家进程------------------------------------------------
%%地图回复，可以接收任务
on_mapMsg_U2GS_AcceptTaskRequest( #pk_U2GS_AcceptTaskRequest{nQuestID=QuestID, nNpcActorID=_NpcActorID}=_Msg, SuccOrFaile)->
	try
		case SuccOrFaile of
			true->ok;
			false->throw(-1)
		end,
		
		QuestBase = etsBaseFunc:readRecord( main:getGlobalTaskBaseTable(), QuestID ),
		case QuestBase of
			{}->
				throw(-1);
			_->ok
		end,
		
		case canAcceptQuest( player:getCurPlayerRecord(), QuestBase ) of
			true->
				ok;
			false->
				throw(-1)
		end,
		
		MyFunc = fun( Record )->
						 #aimProgress{type=Record#taskAim.type, 
									  index=Record#taskAim.index, 
									  maxCount=Record#taskAim.count, 
									  curCount=0 }
				 end,

		AimProgressList = lists:map( MyFunc, QuestBase#taskBase.aim ),
		
		TaskDBData = #playerTask{ id = db:memKeyIndex(playertask_gamedata),
								  taskID=QuestID,
								  playerID=player:getCurPlayerID(),
								  taskBase = QuestBase,
								  state = ?TASKSTATE_UNDO,
								  aimProgressList = AimProgressList },
		etsBaseFunc:insertRecord(getCurTaskTable(), TaskDBData),
		mySqlProcess:insertPlayerTaskGamedata(TaskDBData),
	
		%% 是护送任务
		case QuestBase#taskBase.aim of
			[FirstAim|_]->
				case (FirstAim#taskAim.type =:= ?TASKTYPE_PRMRY_ESCORT) or (FirstAim#taskAim.type =:= ?TASKTYPE_ADVN_ESCORT) of %% 护送任务
					true ->
						convoy:saveConvoyInfoToWorkBook();
					false->
						ok
				end;
			_->ok
		end,
		

		player:send( #pk_GS2U_AcceptTaskResult{nQuestID=QuestID, nResult=0} ),
		
		
		%task:savePlayerTask(),
		?DEBUG_OUT( "player[~p] accepted task[~p]", [player:getPlayerShortLog(player:getCurPlayerID()), QuestID] ),
		
		Player=player:getCurPlayerRecord(),
		PlayerID = Player#player.id,
		UserID = Player#player.userId,
		Level = Player#player.level,
		%% 写完成任务日志
		logdbProcess:write_log_player_task(?LOG_PLAYER_TASK_ACCEPT,UserID,PlayerID,QuestID,Level),
		
		
%% 		ParamTuple = #task_param{	playeraction = 0,
%% 									tasktype = QuestBase#taskBase.type,
%% 									taskid = QuestID},
%% 		logdbProcess:write_log_player_event(?EVENT_PLAYER_TASK, ParamTuple, Player),
		

		true
	catch
		_->
			player:send( #pk_GS2U_AcceptTaskResult{nQuestID=QuestID, nResult=-1} ),
			false
	end.

%%地图回复，可以归还任务
on_mapMsg_U2GS_CompleteTaskRequest( Msg, NpcCfg, SuccOrFaile )->
	try
		case SuccOrFaile of
			true->ok;
			false->throw(-1)
		end,
		
		on_U2GS_CompleteTaskRequest( Msg, NpcCfg ),
		
		ok
	catch
		_->
			player:send( #pk_GS2U_CompleteTaskResult{nQuestID=Msg#pk_U2GS_CompleteTaskRequest.nQuestID, nResult=-2} ),
			NoteMsg = #pk_GS2U_NoteTask{nTaskID=Msg#pk_U2GS_CompleteTaskRequest.nQuestID},
			player:send(NoteMsg)
	end.


%%地图回复玩家与Npc对话
on_mapMsg_U2GS_TalkToNpc( NpcCfg, SuccOrFaile )->
	try
		case SuccOrFaile of
			true->ok;
			false->throw(-1)
		end,
		
	    Msg = #pk_GS2U_TalkToNpcResult{nResult=0, nNpcDataID=NpcCfg#npcCfg.npcID},
	    player:send(Msg),
		%%检测对话任务
%% 	    updateTaskProgress(?TASKTYPE_TALK, NpcCfg#npcCfg.npcID, 1 ),
		
		ok
	catch
		_->ok
	end.

%%地图回复采集结果
on_mapMsg_U2GS_CollectRequest( ObjectCfg, TaskID)->
	try
		?DEBUG_OUT("TaskID ~p",[TaskID]),
		%%检测采集任务
		QuestBase = etsBaseFunc:readRecord( main:getGlobalTaskBaseTable(), TaskID ),
		MyFun = fun(Record)->
						case Record#taskAim.targetID =:= ObjectCfg#objectCfg.objectID of
							true->
								case random:uniform(100) =< Record#taskAim.dropRate of	%%掉率处理
									true->
										playerItems:addItemToPlayerByItemDataID(Record#taskAim.index, Record#taskAim.dropCount, true, ?Get_Item_Reson_Task);
									false->
										ok
								end,
								Msg = #pk_GS2U_NoteTask{nTaskID=TaskID},
								player:send(Msg);
							false->
								ok
						end
				end,
		case QuestBase of
			{}->
				ok;
			_->
				lists:foreach(MyFun, QuestBase#taskBase.aim)
		end
	catch
		_->ok
	end.

%%返回玩家是否可以采集某种采集物
canCollectGoods( _GoodsDataID )->
	ok.

%%任务奖励处理
dealTaskBonus(#taskBase{} = TB) ->
	Bonus = tuple_to_list(TB#taskBase.bonus),
	lists:map(fun(B) -> dealSingleBonus(B,TB#taskBase.taskID) end, Bonus).

%%单个奖励处理
dealSingleBonus({ID, Count},TaskId) ->
	case ID of
		1->
			ParamTuple = #exp_param{changetype = ?Exp_Change_Task,param1=TaskId},
			player:addPlayerEXP(Count, ?Exp_Change_Task, ParamTuple);
		2->
			ParamTuple = #token_param{changetype = ?Money_Change_Task,
									  param1=TaskId},
			
			playerMoney:addPlayerBindedMoney(Count, ?Money_Change_Task, ParamTuple);
			%%playerMoney:addPlayerMoney(Count, ?Money_Change_Task, ParamTuple);
		%%nnd 物品到底被转换为了几
		%%4->
		%%	player:addPlayerHonor(Count, ?Honor_Change_Task);
		_->
			playerItems:addItemToPlayerByItemDataID(ID, Count, true, ?Get_Item_Reson_Task)		%%物品添加在这处理
	end.

%%处理任务物品清除
dealTaskItemDeleteAll(Task)->
	MyFun = fun(Aim)->
					case (Aim#taskAim.type =:= ?TASKTYPE_COLLECT) or (Aim#taskAim.type =:= ?TASKTYPE_ITEM)  or (Aim#taskAim.type=:=?TASKTYPE_BUYITEM)of
						true->
							[CanDec|CanDecItemInBagResult] = playerItems:canDecItemInBag(?Item_Location_Bag, Aim#taskAim.index, Aim#taskAim.count, "all"),
							case CanDec of
								true->
									playerItems:decItemInBag(CanDecItemInBagResult, ?Destroy_Item_Reson_CommitTask);
								false->
									ok
							end;
						false->
							ok
					end
			end,
	lists:map(MyFun, Task#taskBase.aim).

dealTaskItemDelete(Task)->
	try
		MyFun = fun(Aim)->
						case (Aim#taskAim.type =:= ?TASKTYPE_COLLECT) or (Aim#taskAim.type =:= ?TASKTYPE_ITEM) of
							true->
								ItemCount = playerItems:getItemCountByItemData(?Item_Location_Bag, Aim#taskAim.index, true),%%先为不绑定
								Result = playerItems:canDecItemInBag(?Item_Location_Bag, Aim#taskAim.index, ItemCount, "all"),
								case Result of
									[true|CanDecItemInBagResult]->playerItems:decItemInBag(CanDecItemInBagResult, ?Destroy_Item_Reson_CommitTask);
									[false|_]->throw(-1)
								end;
							false->
								ok
						end
				end,
		lists:map(MyFun, Task#taskBase.aim)
	catch
		_->ok
	end.

%% %%---------------------------task gm instruction----------------------------
gmRefreshAllTask()->
	ets:delete_all_objects(getCurTaskTable()),
	ets:delete_all_objects(playerTask),
%% 	sendAcceptedTaskListToPlayer(),
%% 	sendCompletedTaskIDListToPlayer(),
	ok.
%% 
%% gmRefreshOneTask(PlayerID, TaskID, State)->
%% 	TaskTable = getCurTaskTable(),
%% 	Rule = ets:fun2ms(fun(#playerTask{taskID=ID} = Record) when (ID =:=TaskID) ->Record end),
%% 	PlayerTask = ets:select(TaskTable, Rule),
%% 	case PlayerTask of
%% 		[]->
%% 			ok;
%% 		[TB|_]->
%% 			etsBaseFunc:changeFiled(TaskTable, TB#playerTask.id, #playerTask.state, State),
%% 			etsBaseFunc:changeFiled(playerTask, TB#playerTask.id, #playerTask.state, State),
%% 			Msg = #pk_GMTaskStateChange{taskID = TaskID,
%% 										state = State},
%% 			player:getPlayerPID(PlayerID) ! player:sendToPlayer(PlayerID, Msg)
%% 	end.
%% 
gmGetTaskByID(_PlayerID, TaskID)->
	case getTaskBaseByID(TaskID) of
				{}->
					0;
				_->
					case isAcceptedTask(TaskID) of
						false ->
							gmGetTask(TaskID);
						true ->
							ok
					end
			end.

gmGetTask(TaskID)->
	try
		QuestBase = etsBaseFunc:readRecord( main:getGlobalTaskBaseTable(), TaskID ),
		case QuestBase of
			{}->
				throw(-1);
			_->ok
		end,
		
		MyFunc = fun( Record )->
						 #aimProgress{type=Record#taskAim.type, 
									  index=Record#taskAim.index, 
									  maxCount=Record#taskAim.count, 
									  curCount=0 }
				 end,

		AimProgressList = lists:map( MyFunc, QuestBase#taskBase.aim ),
		
		TaskDBData = #playerTask{ id = db:memKeyIndex(playertask_gamedata),
								  taskID=TaskID,
								  playerID=player:getCurPlayerID(),
								  taskBase = QuestBase,
								  state = ?TASKSTATE_UNDO,
								  aimProgressList = AimProgressList },
		etsBaseFunc:insertRecord(getCurTaskTable(), TaskDBData),
		mySqlProcess:insertPlayerTaskGamedata(TaskDBData),
	
		player:send( #pk_GS2U_AcceptTaskResult{nQuestID=TaskID, nResult=0} ),
		
		%task:savePlayerTask(),
		
		?DEBUG_OUT( "player[~p] accepted task[~p]", [player:getPlayerShortLog(player:getCurPlayerID()), TaskID] ),
		
		ok
	catch
		_->ok
	end.
%%随机日常相关,写成了一种机制，但是实际上就一个茶馆任务 坑

%%获取随机日常的配置
getRandDailyCfg(RandomDailyID)->
	put("RandomDailyCfgTmp",[]),
	FunChose=fun(RandomDailyCfg)->
				case RandomDailyCfg of
						[]->
							 ok;
						_->
							case RandomDailyID=:=lists:nth(1, RandomDailyCfg) of
									false->
										ok;
									true->
										put("RandomDailyCfgTmp",RandomDailyCfg)
							end
				end
			end,
	lists:foreach(FunChose, ?AllRandomDaily),
	get("RandomDailyCfgTmp").


resetOneRandomDaily(RandomDailyID)->
	%%TaskGroupID=(RandomDailyID div 10)*10,
	FunReset=fun(RandomDailyRecord)->
					%%?DEBUG_OUT( "resetOneRandomDaily enter", [RandomDailyID] ),
						case RandomDailyRecord of
							{}->
								ok;
							_->
								case RandomDailyRecord#randomDailyRecord.randomDailyID=:=RandomDailyID of
									false ->
										%%?DEBUG_OUT( "resetOneRandomDaily 11", [RandomDailyID] ),
										ok;
									true->
										RandomDailyCfg=getRandDailyCfg(RandomDailyID),
										case RandomDailyCfg of
											[]->
												%%?DEBUG_OUT( "resetOneRandomDaily 2", [RandomDailyID] ),
												ok;
											_->
													ChoseAble=lists:nth(2, RandomDailyCfg),
													RandGroudID=lists:nth(random:uniform( erlang:length(ChoseAble) ), ChoseAble),
													%%完成次数不能清掉
													%%ets:update_element(getCurrentRandDailyTable(), RandomDailyRecord#randomDailyRecord.randomDailyID, 
													%%				   {#randomDailyRecord.randDailyFinishNum,0}),
													ets:update_element(getCurrentRandDailyTable(), RandomDailyRecord#randomDailyRecord.randomDailyID, 
																	   {#randomDailyRecord.randDailyProcess,0}),
													ets:update_element(getCurrentRandDailyTable(), RandomDailyRecord#randomDailyRecord.randomDailyID, 
																	   {#randomDailyRecord.randDailygroudID,RandGroudID}),
													%%?DEBUG_OUT( "resetOneRandomDaily 3", [RandomDailyID] ),
													ok
										end
								end
						end
			end,
	etsBaseFunc:etsFor( getCurrentRandDailyTable(), FunReset ),
	ok.
%%是否有随机日常没交（茶馆任务）
hasRandomDailyUndo()->
	try
		FunLookfor=fun(TaskRecord)->
					RecordTaskID=TaskRecord#playerTask.taskID,
					case (RecordTaskID>=?RandomDailyMinID) andalso (RecordTaskID=<?RandomDailyMaxID) of
						true->
							throw({-1,true});
						false->
							ok
					end
				   end,
		etsBaseFunc:etsFor(getCurTaskTable(), FunLookfor),
		false
	catch
		{_,Result}->
			Result
	end.
	
%%把所有日常的进度给重置了，重新给随机几个
resetAllRandomDaily()->
	HasRandomDailyUndo=hasRandomDailyUndo(),
	case HasRandomDailyUndo of
		true->
			ok;
		false->
			initrandomDailyTable()
	end,
	FunReset=fun(RandomDailyRecord)->
					 	?DEBUG_OUT( "resetAllRandomDaily 0"),
						case RandomDailyRecord of
							{}->
								%%?DEBUG_OUT( "resetAllRandomDaily 2"),
								ok;
							_->
								RandomDailyID=RandomDailyRecord#randomDailyRecord.randomDailyID,
								?DEBUG_OUT( "resetAllRandomDaily 1"),
								RandomDailyCfg=getRandDailyCfg(RandomDailyID),
								case RandomDailyCfg of
									[]->
										?DEBUG_OUT( "resetAllRandomDaily 3"),
										ok;
									_->
										?DEBUG_OUT( "resetAllRandomDaily 4"),
										%%如果有随机茶馆没交，那么进度就不管了，明天接着做这一组
										case HasRandomDailyUndo of
											true->
												%%这种情况，就把完成次数改了
												?DEBUG_OUT( "resetAllRandomDaily 5"),
												ets:update_element(getCurrentRandDailyTable(), RandomDailyRecord#randomDailyRecord.randomDailyID, 
														   {#randomDailyRecord.randDailyFinishNum,0});
											false->
												%%重新给随机个
												?DEBUG_OUT( "resetAllRandomDaily 6"),
												ChoseAble=lists:nth(2, RandomDailyCfg),
												RandGroudID=lists:nth(random:uniform( erlang:length(ChoseAble) ), ChoseAble),
												ets:update_element(getCurrentRandDailyTable(), RandomDailyRecord#randomDailyRecord.randomDailyID, 
																   {#randomDailyRecord.randDailyFinishNum,0}),
												ets:update_element(getCurrentRandDailyTable(), RandomDailyRecord#randomDailyRecord.randomDailyID, 
																   {#randomDailyRecord.randDailyProcess,0}),
												ets:update_element(getCurrentRandDailyTable(), RandomDailyRecord#randomDailyRecord.randomDailyID, 
																   {#randomDailyRecord.randDailygroudID,RandGroudID})
										end,
										ok
								end
						end
			end,
	etsBaseFunc:etsFor( getCurrentRandDailyTable(), FunReset ),
	sendAllRandomDailyToClient(),
	%%?DEBUG_OUT( "resetAllRandomDaily 10"),
ok.

initrandomDailyTable()->
	case getCurrentRandDailyTable() of
		undefined->
			put("RandomDailyTable",ets:new('RandomDailyTable', [protected, {keypos, #randomDailyRecord.randomDailyID}]));
		_->
			ets:delete_all_objects(getCurrentRandDailyTable())
	end,
	InserrFun=fun(RandomDailyCfg)->
					  NewRecord=#randomDailyRecord{randomDailyID=lists:nth(1, RandomDailyCfg),
												   randDailyFinishNum=0,randDailygroudID=0,randDailyProcess=0},
					  ets:insert(getCurrentRandDailyTable(), NewRecord)
			  end,
	lists:foreach(InserrFun, ?AllRandomDaily).

%%貌似没啥用了
randomDailyFirstLogin()->
	initrandomDailyTable(),
	resetAllRandomDaily().

%%登陆的时候调用
resetRandomDailyWhenLogin(LastLogoutTime)->
	?DEBUG_OUT( "resetRandomDailyWhenLogin" ),
	NowSecond=common:getNowSeconds(),
	NowTime= NowSecond rem  86400,
	ResetTimeToday=NowSecond -NowTime+?RandomDailyResetTime,
	case ResetTimeToday<NowSecond of
		true->
			LastResetTime= ResetTimeToday;
		false->
			LastResetTime=ResetTimeToday -86400
	end,
	?DEBUG_OUT( "resetRandomDailyWhenLogin ~p ~p ~p ~p",[ResetTimeToday,LastResetTime,LastLogoutTime,NowSecond] ),
	case LastLogoutTime=<LastResetTime of
		true->
			%%需要重置
			resetAllRandomDaily();
		false->
			ok
	end,
ok.

%%判定接的一个任务是否符合随机日常规则
randomDailyCheck(TaskID,PlayerLevel)->
	try
	QuestBase = etsBaseFunc:readRecord( main:getGlobalTaskBaseTable(), TaskID ),
	case QuestBase of
		{}->
			throw({-1,false});
		_->
			ok
	end,
	GroupStartTaskID=  ( TaskID div 10 )*10,
	
	
	
	case getRandDailyCfgByGroupID(GroupStartTaskID) of
		[]->
			throw({1,true});
		RandDailyCfg->
			%%附加等级检测
			case ?RandomDailyMinLevel>PlayerLevel of
				 false->
					 ok;
				true->
					throw({-1,false})
			end,
			case ets:lookup( getCurrentRandDailyTable() , lists:nth(1, RandDailyCfg) ) of
				[FirstRecord|_]->
					case FirstRecord#randomDailyRecord.randDailygroudID=:= GroupStartTaskID of
						true->
							throw({1,true});
						false->
							throw({-1,false})
					end;
				__->
				throw({-1,false})
			end
	end
	
	catch
		{_,Return}->
		Return
	end.

%%根据一个随机日常的组ID获取配置
getRandDailyCfgByGroupID(RandomDailyGroupID)->
	put("RandomDailyCfgTmp",[]),
	FunChose=fun(RandomDailyCfg)->
				case RandomDailyCfg of
						[]->
							 ok;
						_->
							case lists:member(RandomDailyGroupID, lists:nth(2,  RandomDailyCfg )) of
									false->
										ok;
									true->
										put("RandomDailyCfgTmp",RandomDailyCfg)
							end
				end
			end,
	lists:foreach(FunChose, ?AllRandomDaily),
	get("RandomDailyCfgTmp").

%%在交任务的时候更改进度
updateRandomProcessWhenSubmit(TaskID,PlayerLevel)->
	try
	QuestBase = etsBaseFunc:readRecord( main:getGlobalTaskBaseTable(), TaskID ),
	case QuestBase of
		{}->
			throw({-1,false});
		_->
			ok
	end,
	GroupStartTaskID=  ( TaskID div 10 )*10,
	
	case getRandDailyCfgByGroupID(GroupStartTaskID) of
		[]->
			throw({1,true});
		RandDailyCfg->
			case ets:lookup( getCurrentRandDailyTable() , lists:nth(1, RandDailyCfg) ) of
				[FirstRecord|_]->
					case FirstRecord#randomDailyRecord.randDailygroudID=:= GroupStartTaskID of
						true->
							%%更新进度
							OldProcess=FirstRecord#randomDailyRecord.randDailyProcess,
							case OldProcess+1>= lists:nth(3, RandDailyCfg) of
								true->
									OldFinishTime=FirstRecord#randomDailyRecord.randDailyFinishNum,
									ets:update_element(getCurrentRandDailyTable(), lists:nth(1, RandDailyCfg) , 
													   {#randomDailyRecord.randDailyFinishNum,OldFinishTime+1}),
									ets:update_element(getCurrentRandDailyTable(), lists:nth(1, RandDailyCfg) ,
														{#randomDailyRecord.randDailyProcess,0}),
									%%如果是没轮最后一环，给物品
									ConvoyAwardList=convoy:getAwardByLevel(PlayerLevel),
									case ConvoyAwardList of
										{} ->
											?DEBUG_OUT( "gaveTeaHouseExp no level cfg Level= ~p",[PlayerLevel] );
										_->
											?DEBUG_OUT( "gaveTeaHouseExp gaveitem= ~p",[ConvoyAwardList#convoyAwardCfg.tea_item] ),
											playerItems:addItemToPlayerByItemDataID(ConvoyAwardList#convoyAwardCfg.tea_item, 1, true, ?Get_Item_Reson_Task)
									end,
									
									case OldFinishTime+1 >= lists:nth(4, RandDailyCfg) of
										false->
											resetOneRandomDaily( lists:nth(1, RandDailyCfg) );
										true->
											ets:update_element(getCurrentRandDailyTable(), lists:nth(1, RandDailyCfg) ,
															    {#randomDailyRecord.randDailygroudID,0})
									end,
									ok;
								false->
									ets:update_element(getCurrentRandDailyTable(), lists:nth(1, RandDailyCfg) , {#randomDailyRecord.randDailyProcess,OldProcess+1}),
									ok
							end,
							sendRandomDailyToClient(lists:nth(1, RandDailyCfg)),
							throw({1,true});
						false->
							throw({-1,false})
					end;
				__->
				throw({-1,false})
			end
	end
	
	catch
		{_,Return}->Return
	end.
%%发送某条随机日常记录到客户端
sendRandomDailyToClient(RandomDailyID)->
		case ets:lookup( getCurrentRandDailyTable() , RandomDailyID ) of
			[]->
				ok;
			[FirstRecord|_]->
				player:send( #pk_GS2U_TellRandomDailyInfo{
							randDailyTaskID=FirstRecord#randomDailyRecord.randDailygroudID+FirstRecord#randomDailyRecord.randDailyProcess,
							finishedTime=FirstRecord#randomDailyRecord.randDailyFinishNum,
							process=FirstRecord#randomDailyRecord.randDailyProcess}
						    )
		end,
	ok.

%%获取某条记录
getRandomDaily(RandomDailyID)->
	case ets:lookup( getCurrentRandDailyTable() , RandomDailyID ) of
			[]->
				Result=#randomDailyRecord{randomDailyID=RandomDailyID,randDailyFinishNum=0,randDailygroudID=0,randDailyProcess=0};
			[FirstRecord|_]->
				Result=FirstRecord
		end,
	Result.

isRandomDaily(TaskID)->
 Result= (TaskID>=?RandomDailyMinID) andalso (TaskID=<?RandomDailyMaxID),
 Result.

%%发送所有随机日常记录到客户端
sendAllRandomDailyToClient()->
	
	FunSend=fun(RandomDaily)->
						  sendRandomDailyToClient(RandomDaily#randomDailyRecord.randomDailyID)
			end,
	AllRoleRule = ets:fun2ms(fun(#randomDailyRecord{} = Record)->Record end),
	AllRandomTask=ets:select(getCurrentRandDailyTable(), AllRoleRule),
	lists:foreach(FunSend,AllRandomTask ),
	ok.

gaveTeaHouseExp(TaskID,Level)->
	case task:isRandomDaily(TaskID) of
		true->
			ConvoyAwardList=convoy:getAwardByLevel(Level),
			case ConvoyAwardList of
				{} ->
					?DEBUG_OUT( "gaveGatherExp no level cfg Level= ~p",[Level] );
					_->
					Exp=ConvoyAwardList#convoyAwardCfg.tea_exp,
					Money=ConvoyAwardList#convoyAwardCfg.tea_money,
					ParamTupleExp = #exp_param{changetype = ?Exp_Change_Task,param1=TaskID},
					player:addPlayerEXP(Exp, ?Exp_Change_Task, ParamTupleExp),
					ParamTuple = #token_param{changetype = ?Money_Change_Task,
									  param1=TaskID},
			
					playerMoney:addPlayerBindedMoney(Money, ?Money_Change_Task, ParamTuple),
					
					Text = io_lib:format(?TASK_ADDMONEY, [Exp,Money]),
					Text2 = lists:flatten(Text),
					systemMessage:sendTipsMessageToMe(Text2),
					?DEBUG_OUT( "gaveGatherExp money~p exp ~p",[Money,Exp] ),

					ok
			end,
			Result=true;
		false->
			Result=false
	end,
	Result.

%%----------------------------------------------------------------------------------------
%%---------------声望任务（仙盟任务） start modified by yueliangyou [2013-04-06] ---------
%% 获得声望任务详情
getReputationInfo()->
	case get("ReputationInfo") of
	undefined->
		NewRecord=#reputationInfo{taskID=0,process=0},
		put("ReputationInfo",NewRecord),
		NewRecord;
	Info->
		Info
	end.

%% 记录声望任务信息
putReputationInfo(Info)->
	put("ReputationInfo",Info),
	sendReputationToClient().

%% 是否是声望任务
isReputationTask(TaskID)->
	Result = (TaskID>=?ReputationStartID) andalso (TaskID=<?ReputationEndID),
	Result.

%%声望任务是否可接受
canAccReputationTask(TaskID)->
	try
		case isReputationTask(TaskID) of
			true->
				ok;
			false->
				throw({notReputationTask,true})
		end,

		%%是否达到完成次数
		ReputationInfo=getReputationInfo(),
		case ReputationInfo#reputationInfo.process<?ReputationMaxTime of
			false->
				throw({maxTaskLimit,false});
			true->
				ok
		end,
		
		%%任务中有没有未完成的声望任务ID
		FunLookfor=fun(TaskRecord)->
			RecordTaskID=TaskRecord#playerTask.taskID,
			case isReputationTask(RecordTaskID) of
				true->
					throw({unFinish,false});
				false->
					ok
			end
		end,
		etsBaseFunc:etsFor(getCurTaskTable(), FunLookfor),
		
		%%在接的声望任务不是被分配的声望任务
		case TaskID=:=ReputationInfo#reputationInfo.taskID of
			true->
				ok;
			false->
				throw({notAssigned,false})
		end,

		true
	catch
		{_,Return}->Return;
		_:_->false
	end.

%%声望任务完成,完成后立即刷新新的任务
onReputationTaskFinish(TaskID,PlayerLevel)->
	case isReputationTask(TaskID) of
		true->
			ReputationInfo=getReputationInfo(),
			%%分配个新的ID
			case ReputationInfo#reputationInfo.process<?ReputationMaxTime of
				true->
					NewProcess=ReputationInfo#reputationInfo.process+1,
					case NewProcess<?ReputationMaxTime of
						true->
							putReputationInfo(getNewReputationTask(PlayerLevel,NewProcess));
						false->
							putReputationInfo(#reputationInfo{process=?ReputationMaxTime,taskID=0})
					end;
				false->
					putReputationInfo(#reputationInfo{process=?ReputationMaxTime,taskID=0})
			end;
		false->ok
	end.

%% 获取一个新的声望任务,随机产生,RPC调用公会进程产生
getNewReputationTask(PlayerLevel,Process)->
	TaskID = gen_server:call(guildProcess_PID,{'randomGuildTask',PlayerLevel}),
	?DEBUG_OUT("getNewReputationTask PlayerLevel:~p,TaskID:~p,Process:~p",[PlayerLevel,TaskID,Process]),
	#reputationInfo{process=Process,taskID=TaskID}.

%%声望任务重置
resetReputationTask(PlayerLevel)->
	?DEBUG_OUT("resetReputationTask"),
	putReputationInfo(getNewReputationTask(PlayerLevel,0)),
	sendReputationToClient().

%%声望任务重置
resetReputationTaskEx(PlayerLevel)->
	?DEBUG_OUT("resetReputationTaskEx"),
	ReputationInfo=getReputationInfo(),
	case ReputationInfo#reputationInfo.taskID of 
		0->
			putReputationInfo(getNewReputationTask(PlayerLevel,ReputationInfo#reputationInfo.process));
		_-> ok
	end,
	sendReputationToClient().

%%登陆的时候调用,是不是要重新给个声望任务
resetReputationWhenLogin(LastLogoutTime,PlayerLevel)->
	%% 获取当前时间
	NowSecond=common:getNowSeconds(),
	%% 取当天12点的时间
	NowTime= NowSecond rem  86400,
	%% 计算当天重置时间
	ResetTimeToday=NowSecond-NowTime+?ReputationResetTime,
		
	%% 重置时间未到	
	case ResetTimeToday<NowSecond of
		true->
			LastResetTime= ResetTimeToday;
		false->
			LastResetTime= ResetTimeToday -86400
	end,
	
	?DEBUG_OUT( "resetReputationWhenLogin ~p ~p ~p ~p",[ResetTimeToday,LastResetTime,LastLogoutTime,NowSecond] ),
	case LastLogoutTime=<LastResetTime of
		true->
			%%需要重置
			resetReputationTask(PlayerLevel);
		false-> ok
	end.

%%是否有声望任务没提交
hasReputationUndo()->
	try
		FunLookfor=fun(TaskRecord)->
			TaskID=TaskRecord#playerTask.taskID,
			case isReputationTask(TaskID) of
				true->
					throw({reputationUndo});
				false->
					ok
			end
		end,
		etsBaseFunc:etsFor(getCurTaskTable(), FunLookfor),
		false
	catch
		{reputationUndo}->true
	end.

%% 将当前声望任务发送给客户端
sendReputationToClient()->
	ReputationInfo=getReputationInfo(),
	?DEBUG_OUT("sendReputationToClient taskID:~p,process:~p",[ReputationInfo#reputationInfo.taskID,ReputationInfo#reputationInfo.process]),
	player:send(#pk_GS2U_TellReputationTask
			{taskID=ReputationInfo#reputationInfo.taskID,process=ReputationInfo#reputationInfo.process}).

%% 给声望任务奖励
gaveReputationAward(TaskID,Level)->
	case  task:isReputationTask(TaskID) of
		true->
			ConvoyAwardList=convoy:getAwardByLevel(Level),
			case ConvoyAwardList of
				{} ->
					?LOG_OUT("gaveReputationAward no level cfg.TaskID=~p,Level= ~p",[TaskID,Level]),false;
				_->
					%% 玩家声望
					Reputation=ConvoyAwardList#convoyAwardCfg.taskGuild_userRep,
					%% 玩家经验
					Exp=ConvoyAwardList#convoyAwardCfg.taskGuild_userExp,
					%% 玩家贡献度
					Contribution=ConvoyAwardList#convoyAwardCfg.taskGuild_contribution,
					%% 仙盟经验
					GuildExp=ConvoyAwardList#convoyAwardCfg.taskGuild_guildExp,
					
					Player = player:getCurPlayerRecord(),
					case Player of
                        			{}->?LOG_OUT("gaveReputationAward player not found"),false;
                        			_->
							GuildID = Player#player.guildID,
							PlayerID = Player#player.id,

							player:addCurPlayerCredit(Reputation, true,?Credit_Change_Task),

							ParamTupleExp = #exp_param{changetype = ?Exp_Change_Task,param1=TaskID},
							player:addPlayerEXP(Exp, ?Exp_Change_Task, ParamTupleExp),
							
							%% 增加仙盟经验，增加仙盟成员贡献度
							gen_server:cast(guildProcess_PID,{'addGuildExp',GuildID,GuildExp}),
							gen_server:cast(guildProcess_PID,{'addGuildMemberContribution',GuildID,PlayerID,Contribution}),
							?DEBUG_OUT( "gaveReputationAward GuildID:~p,PlayerID:~p,Reputation:~p,Exp:~p,Contribution:~p,GuildExp:~p",[GuildID,PlayerID,Reputation,Exp,Contribution,GuildExp]),
							true
                			end
			end;
		false->false
	end.

%% ================待屏蔽函数==============start===================================
%%判定是否有后续
haReputationPredeccessor(TaskID)->
	put("ReputationPredeccessor",0),
	FunC=fun([A,P])->
				 case A=:=TaskID of
					 true->
						 put("ReputationPredeccessor",P);
					 false->
						 ok
				 end
		 end,
	lists:foreach(FunC, ?PredeccessorTask),
	case get("ReputationPredeccessor") of
		0->
			Result=false;
		_->
			Result=true
	end,
	Result.

%%获取声望任务后续，如果没后续就随机生成一个(有后续表示2个任务实际是一个)
getReputationPredeccessor(TaskID,PlayerLevel)->
	put("ReputationPredeccessor",0),
	FunC=fun([A,P])->
				 case A=:=TaskID of
					 true->
						 put("ReputationPredeccessor",P);
					 false->
						 ok
				 end
		 end,
	lists:foreach(FunC, ?PredeccessorTask),
	case get("ReputationPredeccessor") of
		0->
			Result=genarateReputationTaskID(PlayerLevel);
		NextTaskID->
			Result=NextTaskID
	end,
	Result.

%%生成声望任务ID
genarateReputationTaskID(NowPlayerLevel)->
	try
		case ?ReputationMinLevel> NowPlayerLevel of
			true->
				PlayerLevel=?ReputationMinLevel;
			false->
				PlayerLevel=NowPlayerLevel
		end,
	put("TempReputationState",now()),
	TaskIDSpan=?ReputationEndID-?ReputationStartID+1,
	FunGenerate=fun(_I)->
		{Rand, State1}=random:uniform_s(TaskIDSpan,get("TempReputationState")),
		TaskID=?ReputationStartID-1+Rand,
		TaseBase = getTaskBaseByID(TaskID),
		put("TempReputationState",State1),
		case TaseBase of
			{}->
				ok;
			_->
				%%有前置任务的，pass 
				case TaseBase#taskBase.prevTask =:=0 of
					false->
						ok;
					true->
						%%没有前置任务
						case TaseBase#taskBase.playerLvMax> 0 of
						true->
							case TaseBase#taskBase.playerLvMax >= PlayerLevel of
								true->
									%%满足等级上限了
									case TaseBase#taskBase.playerLvl> 0 of
										true->
											case TaseBase#taskBase.playerLvl =< PlayerLevel of
												true->
													throw({1,TaskID});
												false->
													ok
											end;
										false->
											throw({1,TaskID})%%等级下限没配置，那么我认为是可以的
									end;
								false->ok
							end;
						false->ok
					end
						
						
				end
						
				
		end
	end,
	
	common:for(1, 10000, FunGenerate),
	ReturnV=0,
	ReturnV
	catch
		{_,Return}->Return
	end.

%% ================待屏蔽函数============end=====================================

%%---------------声望任务（仙盟任务） end ----------------------------------------
%%--------------------------------------------------------------------------------

%%获取采集任务次数
getGatherTime()->
	case get( "GatherTime" ) of
		undefined->
			setGatherTime(0),
			Num=0;
		_Num->
			Num=_Num
	end,
	Num.

%%设置采集任务次数
setGatherTime(Time)->
	put("GatherTime",Time),
	sendGatherDetailToClient().

%%采集任务是否可接受
canGatherAccept(TaskID,PlayerLevel)->
	%%?DEBUG_OUT( "canGatherAccept enter" ),
	case TaskID=:= ?GatherTaskID of
		true->
			case PlayerLevel< ?GatherTaskMinLevel of
				true->
					Result=false;
				_->
					
					case isNowGahter() of
						true->
							%%次数检测
							case  getGatherTime()>=?GatherTaskMaxTime of
								true->
									?DEBUG_OUT( "canGatherAccept time out" ),
									Result=false;
								_->
									Result=true
							end,
							ok;
						false->
							Result=false
					end
			end;
		false->
			%%?DEBUG_OUT( "canGatherAccept not" ),
			Result=true
	end,
	Result.
%%

gaveGatherExp(TaskID,Level)->
	ConvoyAwardList=convoy:getAwardByLevel(Level),
	case ConvoyAwardList of
		{} ->
			?DEBUG_OUT( "gaveGatherExp no level cfg Level= ~p",[Level] );
			_->
			Exp=ConvoyAwardList#convoyAwardCfg.gather30_exp1,
			Money=ConvoyAwardList#convoyAwardCfg.gather30_money1,
			ParamTupleExp = #exp_param{changetype = ?Exp_Change_Task,param1=TaskID},
			player:addPlayerEXP(Exp, ?Exp_Change_Task, ParamTupleExp),
					ParamTuple = #token_param{changetype = ?Money_Change_Task,
									  param1=TaskID},

			%%改成绑定的
			playerMoney:addPlayerBindedMoney(Money, ?Money_Change_Task, ParamTuple),
			
			Text = io_lib:format(?TASK_ADDMONEY, [Exp,Money]),
			Text2 = lists:flatten(Text),
			systemMessage:sendTipsMessageToMe(Text2),
			?DEBUG_OUT( "gaveGatherExp money~p exp ~p",[Money,Exp] )
	end.

%%采集任务给经验
requestgaveGatherExp(TaskID,Level,PlayerID)->
		?DEBUG_OUT( "gaveGatherExp enter" ),
		case TaskID=:= ?GatherTaskID of
			false->
				Result=false;
			true->
				?DEBUG_OUT( "gaveGatherExp" ),
				%%是采集任务，增加次数
				setGatherTime(getGatherTime()+1),
				%%发送消息告诉玩家，可以得奖励
				Msg={gaveGatherExp,Level,TaskID},
				player:sendToPlayerProc(PlayerID, Msg),
				Result=true
		end,
	Result.

%%护送活动是否开启
isConvoyPeriod1()->
try
	StartTimer = convoy:getConvoyStartActiveTimer1(),
	EndTimer = convoy:getConvoyEndActiveTimer1(),
	case StartTimer =:= -1 of
		true -> throw(-1);
		false -> ok
	end,
	case EndTimer =:= -1 of
		true -> throw(-1);
		false -> ok
	end,
	
	NowSecond = common:getNowSeconds(),
	NowTime = NowSecond rem 86400,
	case  (NowTime >= StartTimer*3600) andalso (NowTime < EndTimer*3600) of
		true-> true;
		false-> throw(-1)
	end
catch
	_-> false
end.

isConvoyPeriod2()->
try
	StartTimer = convoy:getConvoyStartActiveTimer2(),
	EndTimer = convoy:getConvoyEndActiveTimer2(),
	case StartTimer =:= -1 of
		true -> throw(-1);
		false -> ok
	end,
	case EndTimer =:= -1 of
		true -> throw(-1);
		false -> ok
	end,
	
	NowSecond = common:getNowSeconds(),
	NowTime = NowSecond rem 86400,
	case  (NowTime >= StartTimer*3600) andalso (NowTime < EndTimer*3600) of
		true-> true;
		false-> throw(-1)
	end
catch
	_-> false
end.

%%现在采集活动是否开启
isGatherPeriod1()->
try
	NowSecond=common:getNowSeconds(),
	NowTime= NowSecond rem  86400,
	case  (NowTime>=?GatherTaskStartTime) andalso (NowTime<?GatherTaskEndTime) of
		true->
			throw({1,true});
		false->
			ok
	end,
	false
	catch
		{_,Return}->
			Return
	end.

isGatherPeriod2()->
try
	NowSecond=common:getNowSeconds(),
	NowTime= NowSecond rem  86400,
	
	case  (NowTime>=?GatherTaskStartTime2) andalso (NowTime<?GatherTaskEndTime2) of
		true->
			throw({1,true});
		false->
			ok
	end,
	
	false
	catch
		{_,Return}->
			Return
	end.

isNowGahter()->
	case isGatherPeriod1() orelse isGatherPeriod2() of
		true->
			Result=true;
		false->
			Result=false
	end,
Result.
%%上线的时候判定是否清空声望获取的量记录
resetCreditLimitWhenLogin(LastLogoutTime)->
	NowSecond=common:getNowSeconds(),
	NowTime= NowSecond rem  86400,
	ResetTimeToday=NowSecond -NowTime+?CreditAggressiveResetTime,
	case ResetTimeToday<NowSecond of
		true->
			LastResetTime= ResetTimeToday;
		false->
			LastResetTime=ResetTimeToday -86400
	end,
	
	case LastLogoutTime=<LastResetTime of
		true->
			%%需要重置
			variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index4_Credit_Get_Today_P, 0),
			variant:setPlayerVarValueFromPlayer(?PlayerVariant_Index_Honor_Get_Today_P, 0);
		false->
			ok
	end,
	ok.
%%上线的时候完成次数重置
resetGatherWhenLogin(LastLogoutTime)->
	?DEBUG_OUT( "resetGatherWhenLogin enter" ),
	NowSecond=common:getNowSeconds(),
	NowTime= NowSecond rem  86400,
	ResetTimeToday=NowSecond -NowTime+?GatherResetTime,
	case ResetTimeToday<NowSecond of
		true->
			LastResetTime= ResetTimeToday;
		false->
			LastResetTime=ResetTimeToday -86400
	end,
	
	case LastLogoutTime=<LastResetTime of
		true->
			%%需要重置
			resetGather();
		false->
			ok
	end,
ok.

%%采集任务，完成次数重置
resetGather()->
	?DEBUG_OUT( "resetGather" ),
	setGatherTime(0).

%%采集任务，告知客户端能不能接
sendGatherDetailToClient()->
	case getGatherTime()>= ?GatherTaskMaxTime of
		true->
			variant:setPlayerVarFlagFromPlayer(?PlayerVariant_Index_3_Active_P, ?PlayerVariant_Index_3_Active_Gather, 0);
		false->
			variant:setPlayerVarFlagFromPlayer(?PlayerVariant_Index_3_Active_P, ?PlayerVariant_Index_3_Active_Gather, 1)
	end,
	%%FinishedTime=getGatherTime(),
	%%case FinishedTime>=4 of
	%%	true->
	%%		variant:setPlayerVarFlagFromPlayer(?PlayerVariant_Index_3_Active_P, ?PlayerVariant_Index_3_Active_Gather2, 1);
	%%	false->
	%%		variant:setPlayerVarFlagFromPlayer(?PlayerVariant_Index_3_Active_P, ?PlayerVariant_Index_3_Active_Gather2, 0)
	%%end,
	%%
	%%case (FinishedTime rem 4 )>=2 of
	%%	true->
	%%		variant:setPlayerVarFlagFromPlayer(?PlayerVariant_Index_3_Active_P, ?PlayerVariant_Index_3_Active_Gather1, 1);
	%%	false->
	%%		variant:setPlayerVarFlagFromPlayer(?PlayerVariant_Index_3_Active_P, ?PlayerVariant_Index_3_Active_Gather1, 0)
	%%end,
	%%
	%%case (FinishedTime rem 2) >=1 of
	%%	true->
	%%		variant:setPlayerVarFlagFromPlayer(?PlayerVariant_Index_3_Active_P, ?PlayerVariant_Index_3_Active_Gather0, 1);
	%%	false->
	%%		variant:setPlayerVarFlagFromPlayer(?PlayerVariant_Index_3_Active_P, ?PlayerVariant_Index_3_Active_Gather0, 0)
	%%end,
	ok.

%%上面3种任务的数据库初始化
taskSpecialInit()->
	RandomDailyID=?RandomDailyTeahousesGroupID,
	RandDailyFinishNum=0,
	
	TeaHouseStartIDList=lists:nth(2, ?RandomDailyTeahousesGroupInfo),
	RandDailygroudID=lists:nth( random:uniform(erlang:length(TeaHouseStartIDList)) , TeaHouseStartIDList),
	
	RandDailyProcess=0,
	%%ReputationtaskID=genarateReputationTaskID(?ReputationMinLevel),
	ReputationtaskID=0,
	Reputationprocess=0,
	GatherFinshedTime=0,
	Result=#taskSpecialData{randomDailyID=RandomDailyID,randDailyFinishNum=RandDailyFinishNum,
							randDailygroudID=RandDailygroudID,randDailyProcess=RandDailyProcess,reputationtaskID=ReputationtaskID,
							reputationprocess=Reputationprocess,gatherFinshedTime=GatherFinshedTime},
	Result.

%% 读取上线任务特殊数据
onPlayerOnlineLoadSpecialTaskInfo(SpecailInfo,Level,LastLogout)->
	initrandomDailyTable(),
	%%先把记录放进去，再考虑重置否
	RandomDailyID=SpecailInfo#taskSpecialData.randomDailyID,
	RandDailyFinishNum=SpecailInfo#taskSpecialData.randDailyFinishNum,
	RandDailygroudID=SpecailInfo#taskSpecialData.randDailygroudID,
	RandDailyProcess=SpecailInfo#taskSpecialData.randDailyProcess,
	ets:update_element(getCurrentRandDailyTable(), RandomDailyID, 
					{#randomDailyRecord.randDailyFinishNum,RandDailyFinishNum}),
	ets:update_element(getCurrentRandDailyTable(), RandomDailyID, 
					 {#randomDailyRecord.randDailyProcess,RandDailyProcess}),
	ets:update_element(getCurrentRandDailyTable(), RandomDailyID, 
					{#randomDailyRecord.randDailygroudID,RandDailygroudID}),
	
	ReputationtaskID=SpecailInfo#taskSpecialData.reputationtaskID,
	Reputationprocess=SpecailInfo#taskSpecialData.reputationprocess,
	ReputationInfo=#reputationInfo{taskID=ReputationtaskID,process=Reputationprocess},
	putReputationInfo(ReputationInfo),
	
	GatherFinshedTime=SpecailInfo#taskSpecialData.gatherFinshedTime,
	setGatherTime(GatherFinshedTime),

	resetRandomDailyWhenLogin(LastLogout),
	sendAllRandomDailyToClient(),
	resetReputationWhenLogin(LastLogout,Level),
	resetGatherWhenLogin(LastLogout),
	resetCreditLimitWhenLogin(LastLogout),
ok.

%%保存上线任务特殊数据
playerOfflineGetSpecialTaskInfo()->
	TeaHouseInfo=getRandomDaily(?RandomDailyTeahousesGroupID),
	RandomDailyID=TeaHouseInfo#randomDailyRecord.randomDailyID,
	RandDailyFinishNum=TeaHouseInfo#randomDailyRecord.randDailyFinishNum,
	RandDailygroudID=TeaHouseInfo#randomDailyRecord.randDailygroudID,
	RandDailyProcess=TeaHouseInfo#randomDailyRecord.randDailyProcess,
	
	
	ReputationInfo=getReputationInfo(),
	?DEBUG_OUT("saveReputation taskID:~p,process:~p",[ReputationInfo#reputationInfo.taskID,ReputationInfo#reputationInfo.process]),
	ReputationtaskID=ReputationInfo#reputationInfo.taskID,
	Reputationprocess=ReputationInfo#reputationInfo.process,
	
	GatherFinshedTime=getGatherTime(),
	
	Result=#taskSpecialData{randomDailyID=RandomDailyID,randDailyFinishNum=RandDailyFinishNum,
							randDailygroudID=RandDailygroudID,randDailyProcess=RandDailyProcess,reputationtaskID=ReputationtaskID,
							reputationprocess=Reputationprocess,gatherFinshedTime=GatherFinshedTime},
	Result.
%% %%---------------------------end--------------------------------------------


