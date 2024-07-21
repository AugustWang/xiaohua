


-module(message).
-export([send/2,dealMsg/2]).
-import(messageBase, [read_string/1, read_int/1,  read_int8/1,  read_int16/1, write_array/2,
             		 write_string/1, write_int/1,  write_int8/1,  write_int16/1, read_array/2, sendPackage/3] ).

-include("package.hrl").


%% don't catch exception in this function
send( S, P ) ->
	case msg_player:send(S,P) of
		noMatch->
			case msg_team:send(S,P) of
				noMatch->
					case msg_task:send(S,P) of
						noMatch->
							case msg_battle:send(S,P) of
								noMatch->
									case msg_guild:send(S, P) of
										noMatch->
											case msg_friend:send(S, P) of
												noMatch->
													case msg_mount:send(S, P) of 
														noMatch->
															case msg_toplist:send(S, P) of
																noMatch->sendFail;
																_->ok
															end;
														_->ok
													end;
												_->ok
											end;
										_->ok
									end;
								_->ok
							end;
						_->ok
					end;
				_->ok
			end;
		_->ok
	end.
	
  
dealMsg(Socket,Bin) -> 
	%% forbid catch exception in this function,add by wenziyong
	{CmdGet,Count}  = common:binary_read_int16(0, Bin),
	Cmd = ( CmdGet band 16#7FF ),
	{_,<<Bin2/binary>>} = split_binary(Bin,Count),
	case msg_player:dealMsg(Socket,Cmd,Bin2) of
		noMatch->
			case msg_team:dealMsg(Socket,Cmd,Bin2) of
				noMatch->
					case msg_task:dealMsg(Socket,Cmd,Bin2) of
						noMatch->
							case msg_battle:dealMsg(Socket,Cmd,Bin2) of
								noMatch->
									case msg_guild:dealMsg(Socket, Cmd, Bin2) of
										noMatch->
											case msg_friend:dealMsg(Socket, Cmd, Bin2) of
												noMatch->
													case msg_mount:dealMsg(Socket, Cmd, Bin2) of
														noMatch->
															case msg_toplist:dealMsg(Socket, Cmd, Bin2) of
																noMatch->dealFail;
																_->ok
															end;
														_->ok
													end;
												_->ok
											end;
										_->ok
									end;
								_->ok
							end;
						_->ok
					end;
				_->ok
			end;
		_->ok
	end.

