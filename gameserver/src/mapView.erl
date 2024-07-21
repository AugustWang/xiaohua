%% Author: Administrator
%% Created: 2012-7-9
%% Description: TODO: Add description to db
-module(mapView).

%%
%% Include files
%%
-include("package.hrl").
-include("db.hrl").
-include("hdlt_logger.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include("playerDefine.hrl").
-include("mapDefine.hrl").
-include("mapView.hrl").

%%
%% Exported Functions
%%
-compile(export_all). 

%%获取是否阻挡  
isBlock(MapDataId, PosX, PosY) ->
	case mapManager:getMapView(MapDataId) of
 		{} ->
 			false;
 		MapView ->
 			Col = PosX div ?Map_Pixel_Title_Width,
 			Row = ( MapView#mapView.height - PosY ) div ?Map_Pixel_Title_Height,
 			if PosX < 0 ->
 				   true;
 			   PosY < 0 ->
 				   true;
 			   PosX >= MapView#mapView.width ->
 				   true;
 			   PosY >= MapView#mapView.height ->
 				   true;
 			   true ->
 				   Index = Col * ( MapView#mapView.height div ?Map_Pixel_Title_Height ) + Row,
 				   Size = byte_size(MapView#mapView.phy),
 				   case ( Index < Size ) of
 					   true->
 						   case binary:at(MapView#mapView.phy, Index ) of
 					   			?MAP_TILE_FLAG_PHY ->true;
 					   			_ -> false
 						   end;
 					   false->true
 				   end
 			end
 	end.

%-record( mapViewCellInfo, {index, leftBottomX, leftBottomY, rightTopX, rightTopY, aroundCellIndexs, moveDirAppearCellIndexs, moveDirDisappearCellIndexs} ).
%%地图管理进程，初始化全局地图格子
makeMapViewCellArea( Width, Height )->
	case ( Width rem ?MAP_CELL_WIDTH ) > 0 of
		true->IncWidthValue = 1;
		false->IncWidthValue = 0
	end,
	case ( Height rem ?MAP_CELL_HEIGHT ) > 0 of
		true->IncHeightValue = 1;
		false->IncHeightValue = 0
	end,
	CellWidthCount = (Width div ?MAP_CELL_WIDTH) + IncWidthValue,
	CellHeightCount = (Height div ?MAP_CELL_HEIGHT) + IncHeightValue,
	put( "makeMapViewCellArea_CellInfoArray", array:new( CellWidthCount*CellHeightCount, {default, 0} ) ),
	
	InitCellFunc_Y = fun( Index_Y, Index_X )->
							 case ( Index_X =:= 1 ) andalso ( Index_Y =:= 1 ) of
								 true->
									 ok;
								 false->ok
							 end,

							 LeftBottomX = Index_X * ?MAP_CELL_WIDTH,
							 LeftBottomY = Index_Y * ?MAP_CELL_HEIGHT,
							 RightTopX = LeftBottomX + ?MAP_CELL_WIDTH,
							 RightTopY = LeftBottomY + ?MAP_CELL_HEIGHT,
							 Index = Index_Y *CellWidthCount + Index_X,
							 
							 {AppearCellIndexs, DisappearCellIndexs} = getMoveDirCellIndexs( Index_X, Index_Y, CellWidthCount, CellHeightCount ),
							 
							 MapViewCellInfo = #mapViewCellInfo{ index=Index,
																 cellIndexX = Index_X, 
																 cellIndexY = Index_Y, 
																 leftBottomX = LeftBottomX, 
																 leftBottomY = LeftBottomY, 
																 rightTopX = RightTopX, 
																 rightTopY = RightTopY, 
																 aroundCellIndexs = getAroundCellIndexList( Index_X, Index_Y, CellWidthCount, CellHeightCount ), 
																 moveDirAppearCellIndexs = AppearCellIndexs,
																 moveDirDisappearCellIndexs = DisappearCellIndexs },
							 Array = get( "makeMapViewCellArea_CellInfoArray" ),
							 Array2 = array:set( Index, MapViewCellInfo, Array ),
							 put( "makeMapViewCellArea_CellInfoArray", Array2 ),
							 ok
					 end,
	InitCellFunc_X = fun( Index_X )->
						   common:for_parama(0, CellHeightCount-1, InitCellFunc_Y, Index_X)
				   end,
	
	common:for(0, CellWidthCount-1, InitCellFunc_X),

	{ CellWidthCount, CellHeightCount, get( "makeMapViewCellArea_CellInfoArray" ) }.

%%返回某索引格的周围9格索引列表,Index_X、Index_Y从0开始，CellWidthCount=横向格子个数，CellHeightCount=纵向格子行数
getAroundCellIndexList( Index_X, Index_Y, CellWidthCount, CellHeightCount )->
	Index_N = { Index_X, Index_Y + 1 },
	Index_NE = { Index_X + 1, Index_Y + 1 },
	Index_E = { Index_X + 1, Index_Y },
	Index_ES = { Index_X + 1, Index_Y - 1 },
	Index_S = { Index_X, Index_Y - 1 },
	Index_SW = { Index_X - 1, Index_Y - 1 },
	Index_W = { Index_X - 1, Index_Y },
	Index_WN = { Index_X - 1, Index_Y + 1 },
	List = [Index_N,Index_NE,Index_E,Index_ES,Index_S,Index_SW,Index_W,Index_WN],
	getValidCellIndexList( List, CellWidthCount, CellHeightCount ).


%%检查一个List[ {Index_X, Index_Y},... ]，返回有效的List
getValidCellIndexList( List, CellWidthCount, CellHeightCount )->
	MyFunc = fun( CheckIndex )->
					 { X, Y } = CheckIndex,
					 ( X >= 0 ) andalso ( X < CellWidthCount ) andalso
					 ( Y >= 0 ) andalso ( Y < CellHeightCount )
			 end,
	Return = lists:filter( MyFunc, List ),
	MyFunc2 = fun( CheckIndex )->
					  { X, Y } = CheckIndex,
					  IndexValue = (Y*CellWidthCount) + X,
					  IndexValue
			  end,
	Return2 = lists:map( MyFunc2, Return ),
	Return2.

%%返回8格方向的移动，出现、消失格子索引数组列表
getMoveDirCellIndexs( Index_X, Index_Y, CellWidthCount, CellHeightCount )->
	%N
	A_N_1 = { Index_X - 1, Index_Y + 2 },
	A_N_2 = { Index_X, Index_Y + 2 },
	A_N_3 = { Index_X + 1, Index_Y + 2 },
	A_N_List = getValidCellIndexList( [A_N_1, A_N_2, A_N_3], CellWidthCount, CellHeightCount ),
	%NE
	A_NE_1 = { Index_X, Index_Y + 2 },
	A_NE_2 = { Index_X + 1, Index_Y + 2 },
	A_NE_3 = { Index_X + 2, Index_Y + 2 },
	A_NE_4 = { Index_X + 2, Index_Y + 1 },
	A_NE_5 = { Index_X + 2, Index_Y },
	A_NE_List = getValidCellIndexList( [A_NE_1, A_NE_2, A_NE_3, A_NE_4, A_NE_5], CellWidthCount, CellHeightCount ),

	%E
	A_E_1 = { Index_X + 2, Index_Y + 1 },
	A_E_2 = { Index_X + 2, Index_Y },
	A_E_3 = { Index_X + 2, Index_Y - 1 },
	A_E_List = getValidCellIndexList( [A_E_1, A_E_2, A_E_3], CellWidthCount, CellHeightCount ),
	%ES
	A_ES_1 = { Index_X + 2, Index_Y },
	A_ES_2 = { Index_X + 2, Index_Y - 1 },
	A_ES_3 = { Index_X + 2, Index_Y - 2 },
	A_ES_4 = { Index_X + 1, Index_Y - 2 },
	A_ES_5 = { Index_X, Index_Y - 2 },
	A_ES_List = getValidCellIndexList( [A_ES_1, A_ES_2, A_ES_3, A_ES_4, A_ES_5], CellWidthCount, CellHeightCount ),

	%S
	A_S_1 = { Index_X - 1, Index_Y - 2 },
	A_S_2 = { Index_X, Index_Y - 2},
	A_S_3 = { Index_X + 1, Index_Y - 2 },
	A_S_List = getValidCellIndexList( [A_S_1, A_S_2, A_S_3], CellWidthCount, CellHeightCount ),
	%SW
	A_SW_1 = { Index_X, Index_Y - 2 },
	A_SW_2 = { Index_X - 1, Index_Y - 2 },
	A_SW_3 = { Index_X - 2, Index_Y - 2 },
	A_SW_4 = { Index_X - 2, Index_Y - 1 },
	A_SW_5 = { Index_X - 2, Index_Y },
	A_SW_List = getValidCellIndexList( [A_SW_1, A_SW_2, A_SW_3, A_SW_4, A_SW_5], CellWidthCount, CellHeightCount ),

	%W
	A_W_1 = { Index_X - 2, Index_Y - 1 },
	A_W_2 = { Index_X - 2, Index_Y},
	A_W_3 = { Index_X - 2, Index_Y + 1 },
	A_W_List = getValidCellIndexList( [A_W_1, A_W_2, A_W_3], CellWidthCount, CellHeightCount ),
	%WN
	A_WN_1 = { Index_X - 2, Index_Y },
	A_WN_2 = { Index_X - 2, Index_Y + 1 },
	A_WN_3 = { Index_X - 2, Index_Y + 2 },
	A_WN_4 = { Index_X - 1, Index_Y + 2 },
	A_WN_5 = { Index_X, Index_Y + 2 },
	A_WN_List = getValidCellIndexList( [A_WN_1, A_WN_2, A_WN_3, A_WN_4, A_WN_5], CellWidthCount, CellHeightCount ),
	
	AppearArray = array:new( ?DIR_COUNT ),
	AppearArray1 = array:set( ?DIR_N, A_N_List, AppearArray),
	AppearArray2 = array:set( ?DIR_NE, A_NE_List, AppearArray1),
	AppearArray3 = array:set( ?DIR_E, A_E_List, AppearArray2),
	AppearArray4 = array:set( ?DIR_ES, A_ES_List, AppearArray3),
	AppearArray5 = array:set( ?DIR_S, A_S_List, AppearArray4),
	AppearArray6 = array:set( ?DIR_SW, A_SW_List, AppearArray5),
	AppearArray7 = array:set( ?DIR_W, A_W_List, AppearArray6),
	AppearArray8 = array:set( ?DIR_WN, A_WN_List, AppearArray7),

	%N
	D_N_1 = { Index_X - 1, Index_Y - 1 },
	D_N_2 = { Index_X, Index_Y - 1 },
	D_N_3 = { Index_X + 1, Index_Y - 1 },
	D_N_List = getValidCellIndexList( [D_N_1, D_N_2, D_N_3], CellWidthCount, CellHeightCount ),
	%NE
	D_NE_1 = { Index_X - 1, Index_Y + 1 },
	D_NE_2 = { Index_X - 1, Index_Y },
	D_NE_3 = { Index_X - 1, Index_Y - 1 },
	D_NE_4 = { Index_X, Index_Y - 1 },
	D_NE_5 = { Index_X + 1, Index_Y - 1 },
	D_NE_List = getValidCellIndexList( [D_NE_1, D_NE_2, D_NE_3, D_NE_4, D_NE_5], CellWidthCount, CellHeightCount ),

	%E
	D_E_1 = { Index_X - 1, Index_Y + 1 },
	D_E_2 = { Index_X - 1, Index_Y },
	D_E_3 = { Index_X - 1, Index_Y - 1 },
	D_E_List = getValidCellIndexList( [D_E_1, D_E_2, D_E_3], CellWidthCount, CellHeightCount ),
	%ES
	D_ES_1 = { Index_X - 1, Index_Y - 1 },
	D_ES_2 = { Index_X - 1, Index_Y },
	D_ES_3 = { Index_X - 1, Index_Y + 1 },
	D_ES_4 = { Index_X, Index_Y + 1 },
	D_ES_5 = { Index_X + 1, Index_Y + 1 },
	D_ES_List = getValidCellIndexList( [D_ES_1, D_ES_2, D_ES_3, D_ES_4, D_ES_5], CellWidthCount, CellHeightCount ),

	%S
	D_S_1 = { Index_X - 1, Index_Y + 1 },
	D_S_2 = { Index_X, Index_Y + 1 },
	D_S_3 = { Index_X + 1, Index_Y + 1 },
	D_S_List = getValidCellIndexList( [D_S_1, D_S_2, D_S_3], CellWidthCount, CellHeightCount ),
	%SW
	D_SW_1 = { Index_X - 1, Index_Y + 1 },
	D_SW_2 = { Index_X, Index_Y + 1 },
	D_SW_3 = { Index_X + 1, Index_Y + 1 },
	D_SW_4 = { Index_X + 1, Index_Y },
	D_SW_5 = { Index_X + 1, Index_Y - 1 },
	D_SW_List = getValidCellIndexList( [D_SW_1, D_SW_2, D_SW_3, D_SW_4, D_SW_5], CellWidthCount, CellHeightCount ),

	%W
	D_W_1 = { Index_X + 1, Index_Y + 1 },
	D_W_2 = { Index_X + 1, Index_Y},
	D_W_3 = { Index_X + 1, Index_Y - 1 },
	D_W_List = getValidCellIndexList( [D_W_1, D_W_2, D_W_3], CellWidthCount, CellHeightCount ),
	%WN
	D_WD_1 = { Index_X - 1, Index_Y - 1 },
	D_WD_2 = { Index_X, Index_Y - 1 },
	D_WD_3 = { Index_X + 1, Index_Y - 1 },
	D_WD_4 = { Index_X + 1, Index_Y },
	D_WD_5 = { Index_X + 1, Index_Y + 1 },
	D_WD_List = getValidCellIndexList( [D_WD_1, D_WD_2, D_WD_3, D_WD_4, D_WD_5], CellWidthCount, CellHeightCount ),
	
	DisappearArray = array:new( ?DIR_COUNT ),
	DisappearArray1 = array:set( ?DIR_N, D_N_List, DisappearArray),
	DisappearArray2 = array:set( ?DIR_NE, D_NE_List, DisappearArray1),
	DisappearArray3 = array:set( ?DIR_E, D_E_List, DisappearArray2),
	DisappearArray4 = array:set( ?DIR_ES, D_ES_List, DisappearArray3),
	DisappearArray5 = array:set( ?DIR_S, D_S_List, DisappearArray4),
	DisappearArray6 = array:set( ?DIR_SW, D_SW_List, DisappearArray5),
	DisappearArray7 = array:set( ?DIR_W, D_W_List, DisappearArray6),
	DisappearArray8 = array:set( ?DIR_WN, D_WD_List, DisappearArray7),
	{AppearArray8, DisappearArray8 }.

%%地图创建时初始化mapView
onMapInit( MapDataID )->
	%%每张地图都有自己的格子表，从mapManager那边初始化一份
	put("MapViewCellsTable", ets:new('MapViewCellsTable', [protected, {keypos, #mapViewCell.index}])),
	
	MapView = mapManager:getMapView(MapDataID),
	MyFunc = fun( Index )->
					 MapViewCell = #mapViewCell{ index=Index, 
												 mapID=MapDataID, 
												 mapCellWidhtCount = MapView#mapView.widthCellCount, 
												 mapCellHeightCount = MapView#mapView.heightCellCount, 
												 mapViewCellInfo=array:get(Index, MapView#mapView.aroundCellIndexArray),
												 playerList=[], 
												 otherList=[] },
					 etsBaseFunc:insertRecord( map:getMapViewCellsTable(), MapViewCell ),
					 ok
			 end,
	common:for( 0, array:size(MapView#mapView.aroundCellIndexArray) - 1, MyFunc ),
	ok.
	
%%返回一个坐标对应的MapCellIndex，从0开始计算
getPosCellIndex( X, Y, WidthCellCount )->
 	IX = X div ?MAP_CELL_WIDTH,
 	IY = Y div ?MAP_CELL_HEIGHT,
 	IY * WidthCellCount + IX.
%%返回某坐标对应的MapView,MapViewCell
getMapViewCell( X, Y )->
	MapView = mapManager:getMapView(map:getMapDataID()),
	CellIndex = getPosCellIndex( X, Y, MapView#mapView.widthCellCount ),
	case ( CellIndex >= 0 andalso CellIndex < array:size( MapView#mapView.aroundCellIndexArray ) ) of
		true->{ MapView, etsBaseFunc:readRecord( map:getMapViewCellsTable(), CellIndex) };
		false->{{},{}}
	end.

%%返回某物件坐标对应的MapViewCell
getObjectMapViewCell( Object, MapView )->
	Pos = map:getObjectPos(Object),
	CellIndex = getPosCellIndex( Pos#posInfo.x, Pos#posInfo.y, MapView#mapView.widthCellCount ),
	case ( CellIndex >= 0 andalso CellIndex < array:size( MapView#mapView.aroundCellIndexArray ) ) of
		true->etsBaseFunc:readRecord( map:getMapViewCellsTable(), CellIndex);
		false->{}
	end.

%%返回某物件坐标对应的MapViewCell
getObjectMapViewCell( Object )->
	case Object of
		{}->{};
		_->
			Pos = map:getObjectPos(Object),
		
			{ _MapView, MapViewCell } = getMapViewCell( Pos#posInfo.x, Pos#posInfo.y ),
			MapViewCell
	end.

pushObjectIntoCell( Object, MapViewCell )->
	ObjectID = element( ?object_id_index, Object ),
	case element( 1, Object ) of
		mapPlayer->
			%{ Find, _ } = common:findInList( MapViewCell#mapViewCell.playerList, ObjectID, 0 ),
			Find = lists:member(ObjectID,MapViewCell#mapViewCell.playerList),
			case Find of
				true->MapViewCell;
				false->
					%NewList = MapViewCell#mapViewCell.playerList ++ [ObjectID],
					NewList = [ObjectID|MapViewCell#mapViewCell.playerList],
					etsBaseFunc:changeFiled( map:getMapViewCellsTable(), MapViewCell#mapViewCell.index, #mapViewCell.playerList, NewList ),
					NewMapViewCell = setelement( #mapViewCell.playerList, MapViewCell, NewList ),
					NewMapViewCell
			end;
		_->
			%{ Find, _ } = common:findInList( MapViewCell#mapViewCell.otherList, ObjectID, 0 ),
			Find = lists:member(ObjectID,MapViewCell#mapViewCell.otherList),
			case Find of
				true->MapViewCell;
				false->
					%NewList = MapViewCell#mapViewCell.otherList ++ [ObjectID],
					NewList = [ObjectID|MapViewCell#mapViewCell.otherList],
					etsBaseFunc:changeFiled( map:getMapViewCellsTable(), MapViewCell#mapViewCell.index, #mapViewCell.otherList, NewList ),
					NewMapViewCell = setelement( #mapViewCell.otherList, MapViewCell, NewList ),
					NewMapViewCell
			end
	end.
removeObject( Object, MapViewCell )->
	ObjectID = element( ?object_id_index, Object ),
	case element( 1, Object ) of
		mapPlayer->
			NewList = MapViewCell#mapViewCell.playerList -- [ObjectID],
			etsBaseFunc:changeFiled( map:getMapViewCellsTable(), MapViewCell#mapViewCell.index, #mapViewCell.playerList, NewList ),
			NewMapViewCell = setelement( #mapViewCell.playerList, MapViewCell, NewList ),
			NewMapViewCell;
		_->
			NewList = MapViewCell#mapViewCell.otherList -- [ObjectID],
			etsBaseFunc:changeFiled( map:getMapViewCellsTable(), MapViewCell#mapViewCell.index, #mapViewCell.otherList, NewList ),
			NewMapViewCell = setelement( #mapViewCell.otherList, MapViewCell, NewList ),
			NewMapViewCell
	end.
	

%%返回某格子周围的玩家列表
getAroundPlayerList( Object, MapViewCell, ExceptObject )->
	case ExceptObject =/= 0 of
		true->
			ObjectID = element( ?object_id_index, Object ),
			case element( 1, Object ) of
				mapPlayer->MyCell = MapViewCell#mapViewCell.playerList -- [ObjectID];
				_->MyCell = MapViewCell#mapViewCell.playerList
			end;
		false->
			MyCell = MapViewCell#mapViewCell.playerList
	end,
	MyFunc = fun( Record )->
					 MapViewCell2 = etsBaseFunc:readRecord( map:getMapViewCellsTable(), Record ),
					 MapViewCell2#mapViewCell.playerList
			 end,
	List = common:listForEachAdd( MyFunc, MapViewCell#mapViewCell.mapViewCellInfo#mapViewCellInfo.aroundCellIndexs,[] ),
	%List ++ MyCell.
	common:addTwoList(List,MyCell).

%%返回某格子周围的所有物件列表
getAroundObjectList(Object, MapViewCell, ExceptObject )->
	case ExceptObject =/= 0 of
		true->
			ObjectID = element( ?object_id_index, Object ),
			case element( 1, Object ) of
				mapPlayer->
					%MyCell = ( MapViewCell#mapViewCell.playerList -- [ObjectID] ) ++ MapViewCell#mapViewCell.otherList;
					MyCell = common:addTwoList(MapViewCell#mapViewCell.otherList,( MapViewCell#mapViewCell.playerList -- [ObjectID] ));
				_->
					%MyCell = MapViewCell#mapViewCell.playerList ++ ( MapViewCell#mapViewCell.otherList -- [ObjectID] )
					MyCell = common:addTwoList(( MapViewCell#mapViewCell.otherList -- [ObjectID] ),MapViewCell#mapViewCell.playerList )
			end;
		false->
			%MyCell = MapViewCell#mapViewCell.playerList ++ MapViewCell#mapViewCell.otherList
			MyCell = common:addTwoList(MapViewCell#mapViewCell.playerList, MapViewCell#mapViewCell.otherList)
	end,
	MyFunc = fun( Record )->
					 MapViewCell2 = etsBaseFunc:readRecord( map:getMapViewCellsTable(), Record ),
					 %List = MapViewCell2#mapViewCell.playerList ++ MapViewCell2#mapViewCell.otherList,
					 List = common:addTwoList(MapViewCell2#mapViewCell.otherList,MapViewCell2#mapViewCell.playerList),
					 List
			 end,
	List = common:listForEachAdd( MyFunc, MapViewCell#mapViewCell.mapViewCellInfo#mapViewCellInfo.aroundCellIndexs,[] ),
	%List ++ MyCell.
	common:addTwoList(List,MyCell).

%%返回某格子周围的所有非玩家物件列表
getAroundNotPlayerObjectList(Object, MapViewCell, ExceptObject )->
	case ExceptObject =/= 0 of
		true->
			ObjectID = element( ?object_id_index, Object ),
			case element( 1, Object ) of
				mapPlayer->MyCell = MapViewCell#mapViewCell.otherList;
				_->MyCell = MapViewCell#mapViewCell.otherList -- [ObjectID]
			end;
		false->
			MyCell = MapViewCell#mapViewCell.otherList
	end,
	MyFunc = fun( Record )->
					 MapViewCell2 = etsBaseFunc:readRecord( map:getMapViewCellsTable(), Record ),
					 MapViewCell2#mapViewCell.otherList
			 end,
	List = common:listForEachAdd( MyFunc, MapViewCell#mapViewCell.mapViewCellInfo#mapViewCellInfo.aroundCellIndexs,[] ),
	%List ++ MyCell.
	common:addTwoList(List, MyCell).

%%返回某格子周围的所有NPC列表
getAroundNpcList(Object, IDOrObject)->
	MapViewCell = getObjectMapViewCell( Object ),
	case MapViewCell of
		{}->ok;
		_->
			ListOtherIDs = getAroundNotPlayerObjectList(Object, MapViewCell, 0 ),
			MyFunc = fun( Record )->
							 map:getObjectID_TypeID(Record) =:= ?Object_Type_Npc
					 end,
			ListReturn = lists:filter(MyFunc, ListOtherIDs),
			case IDOrObject of
				true->ListReturn;
				false->
					MyFunc2 = fun( Record )->
									 map:getMapObjectByID(Record)
							 end,
					ListReturn2 = lists:map(MyFunc2, ListReturn),
					ListReturn2
			end
	end.



%%返回某格子周围的所有可攻击物件列表
getAroundCanAttackList(PosX, PosY, IDOrObject)->
	{ _MapView, MapViewCell } = getMapViewCell( PosX, PosY ),
	case MapViewCell of
		{}->[];
		_->
			ListOtherIDs = getAroundObjectList(0, MapViewCell, 0 ),
			MyFunc = fun( Record )->
							 ObjectType = map:getObjectID_TypeID(Record),
							 ( ObjectType =:= ?Object_Type_Player ) orelse
							 ( ObjectType =:= ?Object_Type_Monster ) orelse
							 ( ObjectType =:= ?Object_Type_Pet )
					 end,
			ListReturn = lists:filter(MyFunc, ListOtherIDs),
			case IDOrObject of
				true->ListReturn;
				false->
					%% modified by wenziyong, fix bug: 九宫格里的id列表与对象表不一致
					getMapObjectListByIdList(ListReturn,PosX, PosY)					
			end
	end.


getMapObjectListByIdList([],_AroundPosX, _AroundPosY) -> [];
getMapObjectListByIdList([H|T],AroundPosX, AroundPosY) -> 
	Obj = map:getMapObjectByID(H),
	case (Obj =:= {}) or (Obj =:= 0) of
		true -> 
			%% 九宫格里的id列表与对象表出现了不一致的情况，所以应该把这个id从九宫格里清理掉
			?ERROR_OUT( "---can't find object by id:~p", [H] ),
			removeObjectIdFrom9Cells(H,AroundPosX, AroundPosY),
			[getMapObjectListByIdList(T,AroundPosX, AroundPosY)];
		false->
			[Obj | getMapObjectListByIdList(T,AroundPosX, AroundPosY)]
	end.


removeObjectIdFrom9Cells( ObjectID, AroundPosX, AroundPosY )->
	ObjectType = map:getObjectID_TypeID(ObjectID),
	{ _MapView, MapViewCellSelf } = getMapViewCell( AroundPosX, AroundPosY ),
	case MapViewCellSelf of
		{}->
			?ERROR_OUT( "---removeObjectIdFrom9Cells error,can't get MapViewCell by pos (~p,~p)", [AroundPosX, AroundPosY] ),
			ok;
		_->
			
			case ObjectType =:= ?Object_Type_Player of
				true ->
					MyFunc = fun( Record )->
							MapViewCell = etsBaseFunc:readRecord( map:getMapViewCellsTable(), Record ),
							NewList = MapViewCell#mapViewCell.playerList -- [ObjectID],
							etsBaseFunc:changeFiled( map:getMapViewCellsTable(), MapViewCell#mapViewCell.index, #mapViewCell.playerList, NewList )			 
					end,
					lists:foreach( MyFunc, MapViewCellSelf#mapViewCell.mapViewCellInfo#mapViewCellInfo.aroundCellIndexs ),
					
					NewList1 = MapViewCellSelf#mapViewCell.playerList -- [ObjectID],
					etsBaseFunc:changeFiled( map:getMapViewCellsTable(), MapViewCellSelf#mapViewCell.index, #mapViewCell.playerList, NewList1 );
				false ->
					MyFunc = fun( Record )->
							MapViewCell = etsBaseFunc:readRecord( map:getMapViewCellsTable(), Record ),
							NewList = MapViewCell#mapViewCell.otherList -- [ObjectID],
							etsBaseFunc:changeFiled( map:getMapViewCellsTable(), MapViewCell#mapViewCell.index, #mapViewCell.otherList, NewList )			 
					end,
					lists:foreach( MyFunc, MapViewCellSelf#mapViewCell.mapViewCellInfo#mapViewCellInfo.aroundCellIndexs ),
					
					NewList1 = MapViewCellSelf#mapViewCell.otherList -- [ObjectID],
					etsBaseFunc:changeFiled( map:getMapViewCellsTable(), MapViewCellSelf#mapViewCell.index, #mapViewCell.otherList, NewList1 )	
			end
	end.

removeObjectIdFromCell(MapViewCell,ObjectID) ->
	ObjectType = map:getObjectID_TypeID(ObjectID),	
	case ObjectType =:= ?Object_Type_Player of
		true ->
			NewList = MapViewCell#mapViewCell.playerList -- [ObjectID],
			etsBaseFunc:changeFiled( map:getMapViewCellsTable(), MapViewCell#mapViewCell.index, #mapViewCell.playerList, NewList );
		false ->
			NewList = MapViewCell#mapViewCell.otherList -- [ObjectID],
			etsBaseFunc:changeFiled( map:getMapViewCellsTable(), MapViewCell#mapViewCell.index, #mapViewCell.otherList, NewList )			 
	end.

%%发送消息，以Object为中心
broadcast( Msg, Object, ExeptPlayerID )->	
	MapViewCell = getObjectMapViewCell( Object ),
	case MapViewCell of
		{}->ok;
		_->
			broadcastByMapViewCell( Msg, MapViewCell, ExeptPlayerID )
	end.


%%发送消息，以MapViewCell为中心
broadcastByMapViewCell( Msg, MapViewCell, ExeptPlayerID )->	
	MyFunc = fun( Record )->
					 MapViewCell2 = etsBaseFunc:readRecord( map:getMapViewCellsTable(), Record ),
					 MyFunc2 = fun( PlayerID )->
									   case ( ExeptPlayerID =/= 0 ) andalso ( ExeptPlayerID =:= PlayerID ) of
										   true->ok;
										   false->
												%% modified by wenziyong,九宫格里的id 与 对象表不一致
											    case map:isExistPlayer( PlayerID ) of
												   true->
														player:sendToPlayer(PlayerID, Msg);
													_ ->
														%% can't get this player
														?ERROR_OUT( "---not exist player, id:~p", [PlayerID] ),
														removeObjectIdFromCell(MapViewCell2,PlayerID)		
												end	
									   end
							   end,
					 lists:foreach(MyFunc2, MapViewCell2#mapViewCell.playerList)
					 
			 end,
	lists:foreach( MyFunc, MapViewCell#mapViewCell.mapViewCellInfo#mapViewCellInfo.aroundCellIndexs ),
	
	
	MyFunc3 = fun( PlayerID )->
				   case ( ExeptPlayerID =/= 0 ) andalso ( ExeptPlayerID =:= PlayerID ) of
					   true->ok;
					   false->
				   			%% modified by wenziyong,九宫格里的id 与 对象表不一致
						    case map:isExistPlayer( PlayerID ) of
							   true->
									player:sendToPlayer(PlayerID, Msg);
								_ ->
									%% can't get this player
									?ERROR_OUT( "---not exist player, id:~p", [PlayerID] ),
									removeObjectIdFromCell(MapViewCell,PlayerID)		
							end	
				   end
			 end,
	lists:foreach( MyFunc3, MapViewCell#mapViewCell.playerList).


%% -> true or false 
isExistPlayerAroundMonster(#mapMonster{}=Monster)->
	case getObjectMapViewCell( Monster ) of
		{}->false;
		MapViewCell->
			case MapViewCell#mapViewCell.playerList of
				[]->
					try					
						MyFunc = fun( CellIndex )->
								 case etsBaseFunc:readRecord( map:getMapViewCellsTable(), CellIndex ) of
									 {}->ok;
									 MapViewCell2->
										case MapViewCell2#mapViewCell.playerList of
											 []->ok;
											 _->throw(true)
										end
								 end
						end,	
						lists:foreach( MyFunc, MapViewCell#mapViewCell.mapViewCellInfo#mapViewCellInfo.aroundCellIndexs),	
						false
					catch
						true->true;
						_->false
					end;
				_->
					true
			end
	end.


%%响应物件进入格子事件
on_ObjectEnterCell( _Object, _MapViewCell )->
	ok.
%%响应物件离开格子事件
on_ObjectLeaveCell( _Object, _MapViewCell )->
	ok.

%%返回物件的出现消息
getObjectAppearMsg( Object )->
	case element( 1, Object ) of
		mapPlayer->#pk_LookInfoPlayerList{info_list=[map:makeLookInfoPlayer( Object )]};
		mapNpc->#pk_LookInfoNpcList{ info_list=[map:makeLookInfoNpc(Object)] };
		mapMonster->#pk_LookInfoMonsterList{ info_list=[map:makeLookInfoMonster(Object)] };
		mapPet->#pk_LookInfoPetList{ info_list=[map:makeLookInfoPet(Object)] };
		mapObjectActor->#pk_LookInfoObjectList{ info_list=[map:makeLookInfoObject(Object)] };
		_->{}
	end.


%%物件进入某格子
charEnterCell( Object, MapViewCellIn )->
try
	case MapViewCellIn =:= 0 of
		true->
			MapViewCell = getObjectMapViewCell( Object );
		false->MapViewCell = MapViewCellIn	
	end,
	case MapViewCell of
		{}->throw(-1);
		_->ok
	end,

	%%将物件推入列表
	MapViewCell2 = pushObjectIntoCell( Object, MapViewCell ),
	
	%%格子响应物件进入格子事件
	on_ObjectEnterCell( Object, MapViewCell2 ),
	%%物件响应物件进入格子事件
	charDefine:on_ObjectEnterCell( Object, MapViewCell2 ),
	
	%%如果是玩家，要发送周围的信息
	case element( 1, Object ) of
		mapPlayer->
			%%周围所有物件的信息要给玩家，玩家的信息也要广播给周围的玩家
			LookInfoPlayer = #pk_LookInfoPlayerList{info_list=[map:makeLookInfoPlayer( Object )] },
			
			PlayerID = element(?object_id_index, Object),
			
			MyFunc = fun( Record )->
							 MapViewCell3 = etsBaseFunc:readRecord( map:getMapViewCellsTable(), Record ),
							 MyFunc2 = fun( OtherPlayerID )->
											    OtherPlayer = map:getPlayer(OtherPlayerID),
												case OtherPlayer of
													{}->ok;
													_->
														player:sendToPlayer(OtherPlayerID, LookInfoPlayer),
														OtherPlayerLookInfo = #pk_LookInfoPlayerList{info_list=[map:makeLookInfoPlayer( OtherPlayer )]},
														player:sendToPlayer(PlayerID, OtherPlayerLookInfo)
												end
									   end,
							 lists:foreach(MyFunc2, MapViewCell3#mapViewCell.playerList),
							 
							 MyFunc3 = fun( OtherObjectID )->
											    OtherObject = map:getMapObjectByID(OtherObjectID),
												case OtherObject of
													{}->ok;
													_->
														%%  check monster whether change from sleep to idle state
														monster:changeToIdleIfNeed(OtherObject),
														OtherObjectLookInfo = getObjectAppearMsg( OtherObject ),
														player:sendToPlayer(PlayerID, OtherObjectLookInfo)
												end
									   end,
							 lists:foreach( MyFunc3, MapViewCell3#mapViewCell.otherList )
					 end,
			lists:foreach( MyFunc, MapViewCell2#mapViewCell.mapViewCellInfo#mapViewCellInfo.aroundCellIndexs ),
			
			MyFunc4 = fun( OtherPlayerID )->
							case OtherPlayerID =:= PlayerID of
								true->ok;
								_->
								    OtherPlayer = map:getPlayer(OtherPlayerID),
									case OtherPlayer of
										{}->ok;
										_->
											player:sendToPlayer(OtherPlayerID, LookInfoPlayer),
											OtherPlayerLookInfo = #pk_LookInfoPlayerList{info_list=[map:makeLookInfoPlayer( OtherPlayer )]},
											player:sendToPlayer(PlayerID, OtherPlayerLookInfo)
									end
							end
					 end,
			lists:foreach( MyFunc4, MapViewCell2#mapViewCell.playerList),
			
			 MyFunc5 = fun( OtherObjectID )->
							    OtherObject = map:getMapObjectByID(OtherObjectID),
								case OtherObject of
									{}->ok;
									_->
										%%  check monster whether change from sleep to idle state
										monster:changeToIdleIfNeed(OtherObject),
										OtherObjectLookInfo = getObjectAppearMsg( OtherObject ),
										player:sendToPlayer(PlayerID, OtherObjectLookInfo)
								end
					   end,
			 lists:foreach( MyFunc5, MapViewCell2#mapViewCell.otherList ),
		
			ok;
		_->
			%%直接将自己的信息发给周围玩家即可
			LookInfo = getObjectAppearMsg( Object ),
			broadcastByMapViewCell( LookInfo, MapViewCell2, 0 ),
			ok
	end,
	ok
catch
	_->ok
end.


%%物件离开格子
charLeaveCell( Object, MapViewCellIn )->
try
	case MapViewCellIn =:= 0 of
		true->
			MapViewCell = getObjectMapViewCell( Object );
		false->MapViewCell = MapViewCellIn	
	end,
	case MapViewCell of
		{}->throw(-1);
		_->ok
	end,

	%%将物件从格子列表中删除
	MapViewCell2 = removeObject( Object, MapViewCell ),
	
	%%格子响应物件离开格子事件
	on_ObjectLeaveCell( Object, MapViewCell2 ),
	%%物件响应物件离开格子事件
	charDefine:on_ObjectLeaveCell( Object, MapViewCell2 ),
	
	%%向周围玩家广播物件消失消息信息
	ObjectID = element( ?object_id_index, Object ),
	MsgToUser = #pk_ActorDisapearList{ info_list=[ObjectID] },
	broadcastByMapViewCell( MsgToUser, MapViewCell2, ObjectID ),
	
	case element( 1, Object ) of
		mapPlayer->
			%%向玩家自己发送周围物件消失消息
			AroundObjectList = getAroundObjectList( Object, MapViewCell2, 0 ),
			case length( AroundObjectList ) > 0 of
				true->
					MsgToUser2 = #pk_ActorDisapearList{ info_list=AroundObjectList },
					player:sendToPlayer(ObjectID, MsgToUser2);
				false->ok
			end;
		_->ok
	end,

	
	ok
catch
	_->ok
end.

%%返回两个MoveViewCell的相邻方向，如果超过一格表示不相邻，返回DIR_COUNT，如果相同，返回DIR_NOT_MOVE
getMoveViewCellDir( MapViewCell_From, MapViewCell_To )->
	DX = MapViewCell_From#mapViewCell.mapViewCellInfo#mapViewCellInfo.cellIndexX -  MapViewCell_To#mapViewCell.mapViewCellInfo#mapViewCellInfo.cellIndexX,
	DY = MapViewCell_From#mapViewCell.mapViewCellInfo#mapViewCellInfo.cellIndexY -  MapViewCell_To#mapViewCell.mapViewCellInfo#mapViewCellInfo.cellIndexY,
	case DX of
		0->
			case DY of
				0->?DIR_NOT_MOVE;
				1->?DIR_S;
				-1->?DIR_N;
				_->?DIR_COUNT
			end;
		1->
			case DY of
				0->?DIR_W;
				1->?DIR_SW;
				-1->?DIR_WN;
				_->?DIR_COUNT
			end;
		-1->
			case DY of
				0->?DIR_E;
				1->?DIR_ES;
				-1->?DIR_NE;
				_->?DIR_COUNT
			end;
		_->?DIR_COUNT
	end.

%%设置物件的新坐标
setObjectPos( Object, SetPosX, SetPosY )->
	OldPos = map:getObjectPos(Object),
	ObjectID = element( ?object_id_index, Object ),
	case element( 1, Object ) of
		mapPlayer->
			etsBaseFunc:changeFiled(map:getMapPlayerTable(), ObjectID, #mapPlayer.pos, #posInfo{x=erlang:trunc(SetPosX), y=erlang:trunc(SetPosY)});
		mapMonster->
			etsBaseFunc:changeFiled(map:getMapMonsterTable(), ObjectID, #mapMonster.pos, #posInfo{x=erlang:trunc(SetPosX), y=erlang:trunc(SetPosY)});
		mapNpc->
			etsBaseFunc:changeFiled(map:getMapNpcTable(), ObjectID, #mapNpc.x, erlang:trunc(SetPosX) ),
			etsBaseFunc:changeFiled(map:getMapNpcTable(), ObjectID, #mapNpc.y, erlang:trunc(SetPosY) );
		mapPet->
			etsBaseFunc:changeFiled(map:getMapPetTable(), ObjectID, #mapPet.pos, #posInfo{x=erlang:trunc(SetPosX), y=erlang:trunc(SetPosY)});
		mapObjectActor->
			etsBaseFunc:changeFiled(map:getObjectTable(), ObjectID, #mapObjectActor.x, erlang:trunc(SetPosX) ),
			etsBaseFunc:changeFiled(map:getObjectTable(), ObjectID, #mapObjectActor.y, erlang:trunc(SetPosY) );
		_->ok
	end,
	NewObject = map:getMapObjectByID( ObjectID ),
	onCharMove( OldPos#posInfo.x, OldPos#posInfo.y, NewObject ),
	NewObject.


%%物件位置移动
onCharMove( FromX, FromY, Object )->
try
	{ MapView_From, MapViewCell_From } = getMapViewCell( FromX, FromY ),
	case MapView_From of
		{}->throw(-1);
		_->ok
	end,
	
	ObjectPos = map:getObjectPos(Object),
	{ MapView_To, MapViewCell_To } = getMapViewCell( ObjectPos#posInfo.x, ObjectPos#posInfo.y ),
	case MapView_To of
		{}->throw(-1);
		_->ok
	end,
	
	Dir = getMoveViewCellDir( MapViewCell_From, MapViewCell_To ),
	case Dir of
		?DIR_COUNT->%%移动超过了相邻一格，需要离开现有的格子，进入新格子
			charLeaveCell( Object, MapViewCell_From ),
			charEnterCell( Object, MapViewCell_To ),
			throw(-1);
		?DIR_NOT_MOVE->%%相同的格子，不做处理
			throw(-1);
		_->ok
	end,
	
	ObjectID = element( ?object_id_index, Object ),
	case element( 1, Object )of
		mapPlayer->
			ok;
		_->ok
	end,

	%%相邻一格，要广播DIR方向的出现和相应的物件可视信息
	LookInfo = getObjectAppearMsg( Object ),
	AppearPlayerCellList = array:get( Dir, MapViewCell_From#mapViewCell.mapViewCellInfo#mapViewCellInfo.moveDirAppearCellIndexs ),
	MyFunc = fun( Record )->
					 MapViewCell = etsBaseFunc:readRecord( map:getMapViewCellsTable(), Record ),
					 MyFunc2 = fun( PlayerID )->
									   %%给新格子玩家，该物件出现信息
									   player:sendToPlayer(PlayerID, LookInfo),
									   %%如果该物件是玩家，给该玩家新格子物件的信息
										%% modified by wenziyong,九宫格里的id 与 对象表不一致
										case element( 1, Object ) of
											mapPlayer->
												case map:getPlayer(PlayerID) of
													{} ->
														%% can't get this player
														?ERROR_OUT( "---can't getPlayer by id:~p", [PlayerID] ),
														removeObjectIdFromCell(MapViewCell,PlayerID);
													Player->
														LookInfoPlayer = getObjectAppearMsg( Player ),
														player:sendToPlayer(ObjectID, LookInfoPlayer)
												end,
												ok;
											_->ok
										end
 							   end,
					 lists:foreach( MyFunc2, MapViewCell#mapViewCell.playerList),
					 %%如果该物件是玩家，给该玩家新格子物件的信息
					 case element( 1, Object ) of
						mapPlayer->
							 MyFunc3 = fun( OtherObjectID )->
											%% modified by wenziyong,九宫格里的id 与 对象表不一致
											case map:getMapObjectByID(OtherObjectID) of
												{} ->
													%% can't get this player
													?ERROR_OUT( "---can't getMapObjectByID by id:~p", [OtherObjectID] ),
													removeObjectIdFromCell(MapViewCell,OtherObjectID);
												OtherObject ->
													%%  check monster whether change from sleep to idle state
													monster:changeToIdleIfNeed(OtherObject),
													LookInfoOtherObject = getObjectAppearMsg( OtherObject ),
													player:sendToPlayer(ObjectID, LookInfoOtherObject)
											end
									   end,
							 lists:foreach( MyFunc3, MapViewCell#mapViewCell.otherList),
							 ok;
						_->ok
					 end
			 end,
	lists:foreach( MyFunc, AppearPlayerCellList ),

	%%消失
	MsgToUser = #pk_ActorDisapearList{ info_list=[ObjectID] },
	
	DisappearPlayerCellList = array:get( Dir, MapViewCell_From#mapViewCell.mapViewCellInfo#mapViewCellInfo.moveDirDisappearCellIndexs ),
	MyFunc3 = fun( Record )->
					 MapViewCell = etsBaseFunc:readRecord( map:getMapViewCellsTable(), Record ),
					 MyFunc2 = fun( PlayerID )->
									   %% modified by wenziyong,九宫格里的id 与 对象表不一致
									   case map:isExistPlayer( PlayerID ) of
										   true->
												player:sendToPlayer(PlayerID, MsgToUser);
											_ ->
												%% can't get this player
												?ERROR_OUT( "---not exist player, id:~p", [PlayerID] ),
												removeObjectIdFromCell(MapViewCell,PlayerID)		
										end				   
 							   end,
					 lists:foreach( MyFunc2, MapViewCell#mapViewCell.playerList),
					 
					 %%如果是玩家，要向玩家发送物件消失
					 case element( 1, Object ) of
						 mapPlayer->
							 case MapViewCell#mapViewCell.playerList of
								 []->
									 ok;
								 _->ok
							 end,
							 case MapViewCell#mapViewCell.otherList of
								 []->
									 ok;
								 _->ok
							 end,

							 %CellAllObject =  MapViewCell#mapViewCell.playerList ++ MapViewCell#mapViewCell.otherList,
							 CellAllObject =  common:addTwoList(MapViewCell#mapViewCell.otherList,MapViewCell#mapViewCell.playerList ),
							 case length( CellAllObject ) > 0 of
								 true->
									 MsgToUser2 = #pk_ActorDisapearList{ info_list=CellAllObject },
									 player:sendToPlayer(ObjectID, MsgToUser2);
								 false->ok
							 end;
						 _->ok
					 end
			 end,
	lists:foreach( MyFunc3, DisappearPlayerCellList ),
	
	%%进入新格
	%%将物件推入列表
	MapViewCell_To2 = pushObjectIntoCell( Object, MapViewCell_To ),
	
	%%格子响应物件进入格子事件
	on_ObjectEnterCell( Object, MapViewCell_To2 ),
	%%物件响应物件进入格子事件
	charDefine:on_ObjectEnterCell( Object, MapViewCell_To2 ),
	
	%%老格子删除
	%%将物件从格子列表中删除
	MapViewCell_From2 = removeObject( Object, MapViewCell_From ),
	
	%%格子响应物件离开格子事件
	on_ObjectLeaveCell( Object, MapViewCell_From2 ),
	%%物件响应物件离开格子事件
	charDefine:on_ObjectLeaveCell( Object, MapViewCell_From2 ),
	
	ok
catch
	_->ok
end.




	
	

