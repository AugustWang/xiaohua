%% Author: Administrator
%% Created: 2012-12-5
%% Description: TODO: Add description to pet
-module(petSealStore).

%%
%% Include files
%%
-include("mysql.hrl").
-include("db.hrl").
-include("hdlt_logger.hrl").
-include("playerDefine.hrl").
-include("package.hrl").
-include("itemDefine.hrl").
-include("mapDefine.hrl").
-include("logdb.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
onCreatePlayerSealStore(PlayerID) ->
	Store = #playerPetSealAhs{playerId=PlayerID, skillIds=[]},
	mySqlProcess:insertOrReplacePetSealAhs(Store,false).

onPlayerOnlineInit() ->
	PetList2 = mySqlProcess:get_playerPetSealAhsListByPlayerID(player:getCurPlayerID()),
	case PetList2 of
		[] ->ok;
		[R|_] ->
			put("PlayerPetSealAhsStore", R#playerPetSealAhs.skillIds)
	end.

getPlayerPetSealAhs() ->
	get("PlayerPetSealAhsStore").

savePlayerPetSealAhs() ->
	Store = #playerPetSealAhs{playerId=player:getCurPlayerID(), skillIds=getPlayerPetSealAhs()},
	mySqlProcess:insertOrReplacePetSealAhs(Store,true).

sendSealAhsStoreDataToClient() ->
	player:send(#pk_PetUpdateSealAhsStore{petSkillBag=getPlayerPetSealAhs()}).

onPetSkillSealAhs(PetId, SkillId) ->
	Result = petSkillSealAhs(PetId, SkillId),
	player:send(#pk_PetSkillSealAhs_Result{result=Result, petId=PetId, skillid=SkillId}).

petSkillSealAhs(PetId, SkillId )->
	try
		%%判断仓库是否满了
		case length(getPlayerPetSealAhs()) < ?Pet_SealAhsStore_Max_Count of
			true ->ok;
			false ->throw(?PetSkill_SealAhs_Failed_StoreFull)
		end,
		
		Pet = pet:getPet(PetId),
		case Pet of
			{}->throw(?PetSkill_SealAhs_Failed_NotPet);
			_ ->ok
		end,
		
		SkillCfg = etsBaseFunc:readRecord(main:getGlobalSkillCfgTable(), SkillId),
		case SkillCfg of
			{} ->throw(?PetSkill_SealAhs_Failed_NotFindSkill);
			_->ok
		end,
		
		case SkillCfg#skillCfg.petskill_del of
			0->ok;
			_->throw( ?PetSkill_SealAhs_Failed_CanNot )
		end,
		
		case lists:keyfind(SkillId, #petSkill.skillId, Pet#petProperty.skills) of
			false ->throw(?PetSkill_SealAhs_Failed_NotFindSkill);
			_->ok
		end,
		
		case SkillCfg#skillCfg.sealAhsItem =:= 0 of
			true ->ok;
			false ->
				[DecResult|DecItem] = playerItems:canDecItemInBag(?Item_Location_Bag, SkillCfg#skillCfg.sealAhsItem, SkillCfg#skillCfg.sealAhsIten_Num, "all"),
				case DecResult of
					false ->throw(?PetSkill_SealAhs_Failed_NotItem);
					true ->
						%%删除技能
						case pet:onPetDelSkill(PetId, SkillId) of
							?Pet_DelSkill_Succ->ok;
							_->throw(?PetSkill_SealAhs_Failed_NotFindSkill)
						end,
						%%删除物品
						playerItems:decItemInBag(DecItem, ?Destroy_Item_Reason_PetSealAhsSkill),
						%%写入兽魂仓库
						put("PlayerPetSealAhsStore", get("PlayerPetSealAhsStore") ++ [SkillId]),
						
						PlayerBase = player:getCurPlayerRecord(),
						ParamLog = #skillah_param{skillbaseid = SkillId,											 	
											 	decitem = SkillCfg#skillCfg.sealAhsItem,
											 	number = SkillCfg#skillCfg.sealAhsIten_Num},										
				
						logdbProcess:write_log_player_event(?EVENT_PET_SKILLAH,ParamLog,PlayerBase),

						?PetSkill_SealAhs_Succ
				end
		end
	
	catch
		Return->Return
end.











