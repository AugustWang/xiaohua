
-module(globalSetup).

-include("db.hrl").
-include("hdlt_logger.hrl").

-compile(export_all). 

loadGlobalSetup() ->
	case db:openBinData( "globalSetup.bin" ) of
		[] ->
			?ERROR_OUT( "loadGlobalSetup openBinData globalSetup.bin failed!" );
		Data ->
			db:loadBinData(Data, globalSetup),
		
			?DEBUG_OUT( "globalSetup load succ" )
	end.

getGlobalSetup() ->
	GlobSetup = get("GlobalSetup"),
	case GlobSetup of
		undefined->
			[R|_]=db:matchObject(globalSetup, #globalSetup{_='_'}),
			put("GlobalSetup",R),
			R;
		_->GlobSetup
	end.

getGlobalSetupValue(Field) ->
	case getGlobalSetup() of
		{} ->
			0;
		GlobSetup ->
			element(Field, GlobSetup)
	end.

loadGlobalHPContainer()->
	case db:openBinData( "hpcontainer.bin" ) of
		[] ->
			?ERROR_OUT( "loadGlobalHPContainer openBinData hpcontainer.bin failed!" );
		Data ->
			db:loadBinData(Data, hpContainerCfg),
			
			CfgTable = ets:new(hpContainerCfgTable, [public, named_table, {read_concurrency,true}, { keypos, #hpContainerCfg.level }]),
			
			CfgDatalist = db:matchObject(hpContainerCfg, #hpContainerCfg{ _='_' } ),
			
			Fun = fun(Record) ->
						  etsBaseFunc:insertRecord(CfgTable, Record)
				  end,
			lists:map(Fun, CfgDatalist),
		
			?DEBUG_OUT( "loadGlobalHPContainer succ" )
	end.

getGlobalHPContainerTable()->
	hpContainerCfgTable.

loadGlobalCopyMapSA()->
	case db:openBinData( "dungeonschallenge.bin" ) of
		[] ->
			?ERROR_OUT( "loadGlobalCopyMapSA openBinData dungeonschallenge.bin failed!" );
		Data ->
			db:loadBinData(Data, copyMapSettleAccounts),
			
			CfgTable = ets:new(copyMapSATable, [public, named_table,{read_concurrency,true},  { keypos, #copyMapSettleAccounts.map_id }]),
			
			CfgDatalist = db:matchObject(copyMapSettleAccounts, #copyMapSettleAccounts{ _='_' } ),
			
			Fun = fun(Record) ->
						  etsBaseFunc:insertRecord(CfgTable, Record)
				  end,
			lists:map(Fun, CfgDatalist),
		
			?DEBUG_OUT( "loadGlobalCopyMapSA succ" )
	end.

getGlobalCopyMapSATable()->
	copyMapSATable.

