


-module(msg_task).
-export([send/2,dealMsg/3]).
-import(messageBase, [read_string/1, read_int/1,  read_int8/1,  read_int16/1, write_array/2,
             		 write_string/1, write_int/1,  write_int8/1,  write_int16/1, write_int64/1,read_array/2, sendPackage/3] ).
-import(common, [binary_read_int64/1,binary_read_int64/2,binary_read_int16/2, binary_read_int16/1,binary_read_int/2, binary_read_int/1, binary_read_int8/2,  binary_read_string/2, binary_read_array_head16/3]).
-include("package.hrl").


write_MsgCollectGoods(#pk_MsgCollectGoods{}=P) -> 
	Bin0=write_int(P#pk_MsgCollectGoods.goodsID),
	Bin3=write_int8(P#pk_MsgCollectGoods.collectFlag),
	Bin6=write_int(P#pk_MsgCollectGoods.collectTime),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_MsgCollectGoods(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_MsgCollectGoods{
		goodsID=D3,
		collectFlag=D6,
		collectTime=D9
	},
	Left,
	Count9
	}.

write_GMTaskStateChange(#pk_GMTaskStateChange{}=P) -> 
	Bin0=write_int(P#pk_GMTaskStateChange.taskID),
	Bin3=write_int(P#pk_GMTaskStateChange.state),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GMTaskStateChange(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GMTaskStateChange{
		taskID=D3,
		state=D6
	},
	Left,
	Count6
	}.

write_GMRefreshAllTask(#pk_GMRefreshAllTask{}=P) -> 
	<<
	>>.

binary_read_GMRefreshAllTask(Bin0)->
	Count0=0,
	{_,Left} = split_binary(Bin0,Count0),
	{#pk_GMRefreshAllTask{
	},
	Left,
	Count0
	}.

write_TaskProgess(#pk_TaskProgess{}=P) -> 
	Bin0=write_int(P#pk_TaskProgess.nCurCount),
	<<Bin0/binary
	>>.

binary_read_TaskProgess(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_TaskProgess{
		nCurCount=D3
	},
	Left,
	Count3
	}.

write_AcceptTask(#pk_AcceptTask{}=P) -> 
	Bin0=write_int16(P#pk_AcceptTask.nTaskID),
	Bin3=write_array(P#pk_AcceptTask.list_progress,fun(X)-> write_TaskProgess(X) end),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_AcceptTask(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_array_head16(Count3,Bin0,fun(X)-> binary_read_TaskProgess(X) end),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_AcceptTask{
		nTaskID=D3,
		list_progress=D6
	},
	Left,
	Count6
	}.

write_GS2U_AcceptedTaskList(#pk_GS2U_AcceptedTaskList{}=P) -> 
	Bin0=write_array(P#pk_GS2U_AcceptedTaskList.list_accepted,fun(X)-> write_AcceptTask(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_AcceptedTaskList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_AcceptTask(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_AcceptedTaskList{
		list_accepted=D3
	},
	Left,
	Count3
	}.

write_GS2U_CompletedTaskIDList(#pk_GS2U_CompletedTaskIDList{}=P) -> 
	Bin0=write_array(P#pk_GS2U_CompletedTaskIDList.list_completed_id,fun(X)-> write_int16(X) end),
	<<Bin0/binary
	>>.

binary_read_GS2U_CompletedTaskIDList(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_array_head16(Count0,Bin0,fun(X)-> binary_read_int16(X) end),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_CompletedTaskIDList{
		list_completed_id=D3
	},
	Left,
	Count3
	}.

write_U2GS_AcceptTaskRequest(#pk_U2GS_AcceptTaskRequest{}=P) -> 
	Bin0=write_int16(P#pk_U2GS_AcceptTaskRequest.nQuestID),
	Bin3=write_int64(P#pk_U2GS_AcceptTaskRequest.nNpcActorID),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_U2GS_AcceptTaskRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int64(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_U2GS_AcceptTaskRequest{
		nQuestID=D3,
		nNpcActorID=D6
	},
	Left,
	Count6
	}.

write_GS2U_PlayerTaskProgressChanged(#pk_GS2U_PlayerTaskProgressChanged{}=P) -> 
	Bin0=write_int16(P#pk_GS2U_PlayerTaskProgressChanged.nQuestID),
	Bin3=write_array(P#pk_GS2U_PlayerTaskProgressChanged.list_progress,fun(X)-> write_TaskProgess(X) end),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_PlayerTaskProgressChanged(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_array_head16(Count3,Bin0,fun(X)-> binary_read_TaskProgess(X) end),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_PlayerTaskProgressChanged{
		nQuestID=D3,
		list_progress=D6
	},
	Left,
	Count6
	}.

write_GS2U_AcceptTaskResult(#pk_GS2U_AcceptTaskResult{}=P) -> 
	Bin0=write_int16(P#pk_GS2U_AcceptTaskResult.nQuestID),
	Bin3=write_int(P#pk_GS2U_AcceptTaskResult.nResult),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_AcceptTaskResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int16(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_AcceptTaskResult{
		nQuestID=D3,
		nResult=D6
	},
	Left,
	Count6
	}.

write_U2GS_TalkToNpc(#pk_U2GS_TalkToNpc{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_TalkToNpc.nNpcActorID),
	<<Bin0/binary
	>>.

binary_read_U2GS_TalkToNpc(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_TalkToNpc{
		nNpcActorID=D3
	},
	Left,
	Count3
	}.

write_GS2U_TalkToNpcResult(#pk_GS2U_TalkToNpcResult{}=P) -> 
	Bin0=write_int8(P#pk_GS2U_TalkToNpcResult.nResult),
	Bin3=write_int(P#pk_GS2U_TalkToNpcResult.nNpcDataID),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_TalkToNpcResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int8(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_TalkToNpcResult{
		nResult=D3,
		nNpcDataID=D6
	},
	Left,
	Count6
	}.

write_U2GS_CollectRequest(#pk_U2GS_CollectRequest{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_CollectRequest.nObjectActorID),
	Bin3=write_int(P#pk_U2GS_CollectRequest.nObjectDataID),
	Bin6=write_int(P#pk_U2GS_CollectRequest.nTaskID),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_U2GS_CollectRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_U2GS_CollectRequest{
		nObjectActorID=D3,
		nObjectDataID=D6,
		nTaskID=D9
	},
	Left,
	Count9
	}.

write_U2GS_CompleteTaskRequest(#pk_U2GS_CompleteTaskRequest{}=P) -> 
	Bin0=write_int64(P#pk_U2GS_CompleteTaskRequest.nNpcActorID),
	Bin3=write_int(P#pk_U2GS_CompleteTaskRequest.nQuestID),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_U2GS_CompleteTaskRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int64(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_U2GS_CompleteTaskRequest{
		nNpcActorID=D3,
		nQuestID=D6
	},
	Left,
	Count6
	}.

write_GS2U_CompleteTaskResult(#pk_GS2U_CompleteTaskResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_CompleteTaskResult.nQuestID),
	Bin3=write_int(P#pk_GS2U_CompleteTaskResult.nResult),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_CompleteTaskResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_CompleteTaskResult{
		nQuestID=D3,
		nResult=D6
	},
	Left,
	Count6
	}.

write_U2GS_GiveUpTaskRequest(#pk_U2GS_GiveUpTaskRequest{}=P) -> 
	Bin0=write_int(P#pk_U2GS_GiveUpTaskRequest.nQuestID),
	<<Bin0/binary
	>>.

binary_read_U2GS_GiveUpTaskRequest(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_U2GS_GiveUpTaskRequest{
		nQuestID=D3
	},
	Left,
	Count3
	}.

write_GS2U_GiveUpTaskResult(#pk_GS2U_GiveUpTaskResult{}=P) -> 
	Bin0=write_int(P#pk_GS2U_GiveUpTaskResult.nQuestID),
	Bin3=write_int(P#pk_GS2U_GiveUpTaskResult.nResult),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_GiveUpTaskResult(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_GiveUpTaskResult{
		nQuestID=D3,
		nResult=D6
	},
	Left,
	Count6
	}.

write_GS2U_NoteTask(#pk_GS2U_NoteTask{}=P) -> 
	Bin0=write_int(P#pk_GS2U_NoteTask.nTaskID),
	<<Bin0/binary
	>>.

binary_read_GS2U_NoteTask(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{_,Left} = split_binary(Bin0,Count3),
	{#pk_GS2U_NoteTask{
		nTaskID=D3
	},
	Left,
	Count3
	}.

write_GS2U_TellRandomDailyInfo(#pk_GS2U_TellRandomDailyInfo{}=P) -> 
	Bin0=write_int(P#pk_GS2U_TellRandomDailyInfo.randDailyTaskID),
	Bin3=write_int8(P#pk_GS2U_TellRandomDailyInfo.finishedTime),
	Bin6=write_int8(P#pk_GS2U_TellRandomDailyInfo.process),
	<<Bin0/binary,Bin3/binary,Bin6/binary
	>>.

binary_read_GS2U_TellRandomDailyInfo(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int8(Count3,Bin0),
	Count6=C6+Count3,
	{D9,C9}=binary_read_int8(Count6,Bin0),
	Count9=C9+Count6,
	{_,Left} = split_binary(Bin0,Count9),
	{#pk_GS2U_TellRandomDailyInfo{
		randDailyTaskID=D3,
		finishedTime=D6,
		process=D9
	},
	Left,
	Count9
	}.

write_GS2U_TellReputationTask(#pk_GS2U_TellReputationTask{}=P) -> 
	Bin0=write_int(P#pk_GS2U_TellReputationTask.taskID),
	Bin3=write_int(P#pk_GS2U_TellReputationTask.process),
	<<Bin0/binary,Bin3/binary
	>>.

binary_read_GS2U_TellReputationTask(Bin0)->
	Count0=0,
	{D3,C3}=binary_read_int(Count0,Bin0),
	Count3=C3+Count0,
	{D6,C6}=binary_read_int(Count3,Bin0),
	Count6=C6+Count3,
	{_,Left} = split_binary(Bin0,Count6),
	{#pk_GS2U_TellReputationTask{
		taskID=D3,
		process=D6
	},
	Left,
	Count6
	}.



send(Socket,#pk_GMTaskStateChange{}=P) ->

	Bin = write_GMTaskStateChange(P),
	sendPackage(Socket,?CMD_GMTaskStateChange,Bin);


send(Socket,#pk_GMRefreshAllTask{}=P) ->

	Bin = write_GMRefreshAllTask(P),
	sendPackage(Socket,?CMD_GMRefreshAllTask,Bin);




send(Socket,#pk_GS2U_AcceptedTaskList{}=P) ->

	Bin = write_GS2U_AcceptedTaskList(P),
	sendPackage(Socket,?CMD_GS2U_AcceptedTaskList,Bin);


send(Socket,#pk_GS2U_CompletedTaskIDList{}=P) ->

	Bin = write_GS2U_CompletedTaskIDList(P),
	sendPackage(Socket,?CMD_GS2U_CompletedTaskIDList,Bin);



send(Socket,#pk_GS2U_PlayerTaskProgressChanged{}=P) ->

	Bin = write_GS2U_PlayerTaskProgressChanged(P),
	sendPackage(Socket,?CMD_GS2U_PlayerTaskProgressChanged,Bin);


send(Socket,#pk_GS2U_AcceptTaskResult{}=P) ->

	Bin = write_GS2U_AcceptTaskResult(P),
	sendPackage(Socket,?CMD_GS2U_AcceptTaskResult,Bin);



send(Socket,#pk_GS2U_TalkToNpcResult{}=P) ->

	Bin = write_GS2U_TalkToNpcResult(P),
	sendPackage(Socket,?CMD_GS2U_TalkToNpcResult,Bin);




send(Socket,#pk_GS2U_CompleteTaskResult{}=P) ->

	Bin = write_GS2U_CompleteTaskResult(P),
	sendPackage(Socket,?CMD_GS2U_CompleteTaskResult,Bin);



send(Socket,#pk_GS2U_GiveUpTaskResult{}=P) ->

	Bin = write_GS2U_GiveUpTaskResult(P),
	sendPackage(Socket,?CMD_GS2U_GiveUpTaskResult,Bin);


send(Socket,#pk_GS2U_NoteTask{}=P) ->

	Bin = write_GS2U_NoteTask(P),
	sendPackage(Socket,?CMD_GS2U_NoteTask,Bin);


send(Socket,#pk_GS2U_TellRandomDailyInfo{}=P) ->

	Bin = write_GS2U_TellRandomDailyInfo(P),
	sendPackage(Socket,?CMD_GS2U_TellRandomDailyInfo,Bin);


send(Socket,#pk_GS2U_TellReputationTask{}=P) ->

	Bin = write_GS2U_TellReputationTask(P),
	sendPackage(Socket,?CMD_GS2U_TellReputationTask,Bin);

send(_,_)-> 
	noMatch.


dealMsg(Socket,Cmd,Bin2) -> 
	case Cmd of
	?CMD_MsgCollectGoods->
		{Pk,_,_} = binary_read_MsgCollectGoods(Bin2),
		messageOn:on_MsgCollectGoods(Socket,Pk);
	?CMD_U2GS_AcceptTaskRequest->
		{Pk,_,_} = binary_read_U2GS_AcceptTaskRequest(Bin2),
		messageOn:on_U2GS_AcceptTaskRequest(Socket,Pk);
	?CMD_U2GS_TalkToNpc->
		{Pk,_,_} = binary_read_U2GS_TalkToNpc(Bin2),
		messageOn:on_U2GS_TalkToNpc(Socket,Pk);
	?CMD_U2GS_CollectRequest->
		{Pk,_,_} = binary_read_U2GS_CollectRequest(Bin2),
		messageOn:on_U2GS_CollectRequest(Socket,Pk);
	?CMD_U2GS_CompleteTaskRequest->
		{Pk,_,_} = binary_read_U2GS_CompleteTaskRequest(Bin2),
		messageOn:on_U2GS_CompleteTaskRequest(Socket,Pk);
	?CMD_U2GS_GiveUpTaskRequest->
		{Pk,_,_} = binary_read_U2GS_GiveUpTaskRequest(Bin2),
		messageOn:on_U2GS_GiveUpTaskRequest(Socket,Pk);
		_-> 
		noMatch
	end.
