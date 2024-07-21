%% Author: yaogang
%% Created: 2013-1-23
%% Description: TODO: Add description to forbidden
-module(forbidden).

%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% Include files
%%
-include("db.hrl").
-include("hdlt_logger.hrl").
-include("globalDefine.hrl").

%%加载屏蔽字str表和bin表
loadforbiddenCfg() ->
	db:loadOffsetString("offstring.str"),
	case db:openBinData( "offstring.bin" ) of
		[] ->
			?ERROR_OUT( "loadforbiddenCfg openBinData offstring.bin failed!" );
		ForbiddenCfgData ->
			db:loadBinData(ForbiddenCfgData, forbiddenCfg),
			

			ets:new( ?ForbiddenCfgTableAtom, [set,protected, named_table, {read_concurrency,true}, { keypos, #forbiddenCfg.id }] ),


			%db:changeFiled( globalMain, ?GlobalMainID, #globalMain.forbiddenCfgTable, ForbiddenCfgTable),
			ForbiddenCfgDataList = db:matchObject(forbiddenCfg,  #forbiddenCfg{_='_'} ),
			
			Fun = fun( Record ) ->
						  		  String = db:getOffsetString(Record#forbiddenCfg.context,"offstring.str"),
								  Record1 = setelement( #forbiddenCfg.context, Record, String),
								  etsBaseFunc:insertRecord(?ForbiddenCfgTableAtom, Record1)
						  end,
			lists:map(Fun, ForbiddenCfgDataList),		
			?DEBUG_OUT( "ForbiddenCfgTable load succ" )
	end.
%%检查一个字串是否包含屏蔽字
checkForbidden(String)->
	put("findforbidden",false),
	MyFunc = fun( Record )->
					 case Record#forbiddenCfg.context of
						 []->ok;
						 _->
							 Index = string:str(String, Record#forbiddenCfg.context),
							 case Index>0 of
								true->
									put("findforbidden",true);
								false->
									ok
							 end
					 end
			 end,
	etsBaseFunc:etsFor(getforbiddenCfgTable(), MyFunc),
	case get("findforbidden") of
		true->
			true;
		false->
			false
	end.
%%获取屏蔽字ets表
getforbiddenCfgTable() ->
	?ForbiddenCfgTableAtom.
%% 	ForbiddenCfg = get("ForbiddenCfgTable"),
%% 	case ForbiddenCfg of
%% 		undefined ->db:getFiled(globalMain, ?GlobalMainID, #globalMain.forbiddenCfgTable);
%% 		_->ForbiddenCfg
%% 	end.
