%%
%% Author: Hannibal.LCF
%%
-ifndef(mapView_hrl_).

%% 9 grid width and height.
-define(MapViewNineGrid_Width,  2048).

-define(MapViewNineGrid_Height, 768).

%% From left top to right bottom
%% parameters: aroundCellList -> cells' index around this cell,
%% playerList -> players' id in this cell,
%% otherList -> monsters, npcs, collections etc. in this cell
-record(mapViewCell, {index,mapID, aroundCellList, mapCellWidhtCount, mapCellHeightCount, mapViewCellInfo, playerList, otherList}).

%% Hold a table of mapview cells, 
%% 
-define( DIR_N, 0 ).
-define( DIR_NE, 1 ).
-define( DIR_E, 2 ).
-define( DIR_ES, 3 ).
-define( DIR_S, 4 ).
-define( DIR_SW, 5 ).
-define( DIR_W, 6 ).
-define( DIR_WN, 7 ).
-define( DIR_COUNT, 8 ).
-define( DIR_NOT_MOVE, 9 ).

-define( MAP_CELL_WIDTH, 480 ).
-define( MAP_CELL_HEIGHT, 320 ).


-record( mapViewCellInfo, {index, cellIndexX, cellIndexY, leftBottomX, leftBottomY, rightTopX, rightTopY, 
							aroundCellIndexs, moveDirAppearCellIndexs, moveDirDisappearCellIndexs} ).


-endif.